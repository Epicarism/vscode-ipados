import SwiftUI
import Foundation
import Combine

final class FileSystemNavigator: ObservableObject {
    @Published var fileTree: FileTreeNode?
    @Published var expandedPaths: Set<String> = []

    func loadFileTree(at url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tree = self.buildFileTree(at: url)
            DispatchQueue.main.async {
                self.fileTree = tree
                if let tree = tree {
                    self.expandedPaths.insert(tree.url.path)
                }
            }
        }
    }

    // MARK: - Refresh

    /// Reload the tree for the currently opened root folder.
    ///
    /// Note: This intentionally preserves `expandedPaths` so folders don't collapse after operations.
    func refreshFileTree() {
        guard let currentTree = fileTree else { return }
        let rootURL = currentTree.url
        expandedPaths.insert(rootURL.path)
        loadFileTree(at: rootURL)
    }

    // MARK: - File Operations (Create / Rename / Move / Delete)

    /// Create a new empty file and return its URL.
    func createFile(named name: String, in folder: URL) throws -> URL {
        let didStart = folder.startAccessingSecurityScopedResource()
        defer { if didStart { folder.stopAccessingSecurityScopedResource() } }

        let fileURL = folder.appendingPathComponent(name, isDirectory: false)
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: fileURL.path) {
            throw NSError(domain: "FileSystemNavigator", code: 1, userInfo: [NSLocalizedDescriptionKey: "File already exists"])
        }

        let created = fileManager.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)
        if !created {
            throw NSError(domain: "FileSystemNavigator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create file"])
        }

        DispatchQueue.main.async { self.refreshFileTree() }
        return fileURL
    }

    /// Backwards-compatible async API.
    func createFile(name: String, in folder: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let didStart = folder.startAccessingSecurityScopedResource()
            defer { if didStart { folder.stopAccessingSecurityScopedResource() } }

            let fileURL = folder.appendingPathComponent(name, isDirectory: false)
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: fileURL.path) {
                _ = fileManager.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)
            }

            DispatchQueue.main.async { self.refreshFileTree() }
        }
    }

    /// Create a new folder and return its URL.
    func createFolder(named name: String, in folder: URL) throws -> URL {
        let didStart = folder.startAccessingSecurityScopedResource()
        defer { if didStart { folder.stopAccessingSecurityScopedResource() } }

        let folderURL = folder.appendingPathComponent(name, isDirectory: true)
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: folderURL.path) {
            throw NSError(domain: "FileSystemNavigator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Folder already exists"])
        }

        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
        DispatchQueue.main.async { self.refreshFileTree() }
        return folderURL
    }

    /// Backwards-compatible async API.
    func createFolder(name: String, in folder: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let didStart = folder.startAccessingSecurityScopedResource()
            defer { if didStart { folder.stopAccessingSecurityScopedResource() } }

            let folderURL = folder.appendingPathComponent(name, isDirectory: true)
            let fileManager = FileManager.default

            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Error creating folder at \(folderURL): \(error)")
            }

            DispatchQueue.main.async { self.refreshFileTree() }
        }
    }

    /// Rename a file or folder and return the new URL.
    func renameItem(at url: URL, to newName: String) throws -> URL {
        let parent = url.deletingLastPathComponent()

        let didStartItem = url.startAccessingSecurityScopedResource()
        let didStartParent = (!didStartItem) ? parent.startAccessingSecurityScopedResource() : false
        defer {
            if didStartItem { url.stopAccessingSecurityScopedResource() }
            if didStartParent { parent.stopAccessingSecurityScopedResource() }
        }

        let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        let destination = parent.appendingPathComponent(newName, isDirectory: isDirectory)

        try FileManager.default.moveItem(at: url, to: destination)
        DispatchQueue.main.async { self.refreshFileTree() }
        return destination
    }

    /// Move a file/folder into a destination folder and return the new URL.
    func moveItem(at source: URL, to destinationFolder: URL) throws -> URL {
        let destinationIsDirectory = (try? destinationFolder.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? destinationFolder.hasDirectoryPath
        guard destinationIsDirectory else {
            throw NSError(domain: "FileSystemNavigator", code: 4, userInfo: [NSLocalizedDescriptionKey: "Destination must be a folder"])
        }

        let isDirectory = (try? source.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? source.hasDirectoryPath
        let fileManager = FileManager.default

        // Access security scoped resources for both ends.
        let didStartSource = source.startAccessingSecurityScopedResource()
        let didStartSourceParent = (!didStartSource) ? source.deletingLastPathComponent().startAccessingSecurityScopedResource() : false
        let didStartDest = destinationFolder.startAccessingSecurityScopedResource()
        defer {
            if didStartSource { source.stopAccessingSecurityScopedResource() }
            if didStartSourceParent { source.deletingLastPathComponent().stopAccessingSecurityScopedResource() }
            if didStartDest { destinationFolder.stopAccessingSecurityScopedResource() }
        }

        let initialDest = destinationFolder.appendingPathComponent(source.lastPathComponent, isDirectory: isDirectory)
        let finalDest = uniqueDestinationURL(for: initialDest, fileManager: fileManager)

        do {
            try fileManager.moveItem(at: source, to: finalDest)
        } catch {
            // Fallback for cross-volume moves.
            try fileManager.copyItem(at: source, to: finalDest)
            try fileManager.removeItem(at: source)
        }

        DispatchQueue.main.async { self.refreshFileTree() }
        return finalDest
    }

    /// Task-required API: move `source` to `destination`.
    /// - If `destination` is a folder, the item is moved *into* that folder.
    /// - If `destination` is a file URL, the item is moved/renamed to that exact URL.
    @discardableResult
    func moveItem(from source: URL, to destination: URL) -> Bool {
        do {
            let destinationIsDirectory = (try? destination.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? destination.hasDirectoryPath
            if destinationIsDirectory {
                _ = try moveItem(at: source, to: destination)
            } else {
                let didStartSource = source.startAccessingSecurityScopedResource()
                let didStartSourceParent = (!didStartSource) ? source.deletingLastPathComponent().startAccessingSecurityScopedResource() : false
                let didStartDestParent = destination.deletingLastPathComponent().startAccessingSecurityScopedResource()
                defer {
                    if didStartSource { source.stopAccessingSecurityScopedResource() }
                    if didStartSourceParent { source.deletingLastPathComponent().stopAccessingSecurityScopedResource() }
                    if didStartDestParent { destination.deletingLastPathComponent().stopAccessingSecurityScopedResource() }
                }

                try FileManager.default.moveItem(at: source, to: destination)
                DispatchQueue.main.async { self.refreshFileTree() }
            }
            return true
        } catch {
            print("Error moving item from \(source) to \(destination): \(error)")
            return false
        }
    }

    /// Delete a file or folder and refresh the tree.
    @discardableResult
    func deleteItem(at url: URL) -> Bool {
        var success = false

        // Try to access the item directly; if that fails, try its parent folder (common for child URLs).
        let didStartItem = url.startAccessingSecurityScopedResource()
        let parentURL = url.deletingLastPathComponent()
        let didStartParent = (!didStartItem) ? parentURL.startAccessingSecurityScopedResource() : false

        defer {
            if didStartItem { url.stopAccessingSecurityScopedResource() }
            if didStartParent { parentURL.stopAccessingSecurityScopedResource() }
        }

        do {
            try FileManager.default.removeItem(at: url) // works for files and directories
            success = true
        } catch {
            print("Error deleting item at \(url): \(error)")
            success = false
        }

        DispatchQueue.main.async { self.refreshFileTree() }
        return success
    }

    // MARK: - Tree

    private func buildFileTree(at url: URL) -> FileTreeNode? {
        let fileManager = FileManager.default

        do {
            let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .nameKey])
            let isDirectory = resourceValues.isDirectory ?? false
            let name = resourceValues.name ?? url.lastPathComponent

            if isDirectory {
                let contents = try fileManager.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: [.skipsHiddenFiles]
                )
                let children = contents.compactMap { buildFileTree(at: $0) }.sorted { $0.name < $1.name }
                return FileTreeNode(url: url, name: name, isDirectory: true, children: children)
            } else {
                return FileTreeNode(url: url, name: name, isDirectory: false, children: [])
            }
        } catch {
            print("Error building file tree at \(url): \(error)")
            return nil
        }
    }

    func toggleExpanded(path: String) {
        if expandedPaths.contains(path) {
            expandedPaths.remove(path)
        } else {
            expandedPaths.insert(path)
        }
    }

    // MARK: - Helpers

    private func uniqueDestinationURL(for initial: URL, fileManager: FileManager) -> URL {
        if !fileManager.fileExists(atPath: initial.path) { return initial }

        let folder = initial.deletingLastPathComponent()
        let isDirectory = (try? initial.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? initial.hasDirectoryPath

        let baseName = initial.deletingPathExtension().lastPathComponent
        let ext = initial.pathExtension

        var counter = 1
        while true {
            let candidateName: String
            if ext.isEmpty {
                candidateName = "\(baseName) \(counter)"
            } else {
                candidateName = "\(baseName) \(counter).\(ext)"
            }

            let candidate = folder.appendingPathComponent(candidateName, isDirectory: isDirectory)
            if !fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
            counter += 1
        }
    }
}

struct FileTreeNode: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let isDirectory: Bool
    let children: [FileTreeNode]

    var fileExtension: String {
        (name as NSString).pathExtension.lowercased()
    }
}
