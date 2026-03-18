import SwiftUI
import Foundation
import Combine

@MainActor
final class FileSystemNavigator: ObservableObject {
    @Published var fileTree: FileTreeNode?
    @Published var expandedPaths: Set<String> = []
    @Published var isLoading: Bool = false

    /// The currently opened workspace root URL (if any).
    @Published private(set) var rootURL: URL?

    /// Convenience for callers that store paths.
    var rootPath: String? { rootURL?.path }

    func loadFileTree(at url: URL) {
        // Treat this as the workspace root.
        rootURL = url
        isLoading = true

        // Run the heavy directory enumeration on the cooperative thread pool,
        // then publish results back on MainActor.
        Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            // buildFileTree is nonisolated — runs on a background thread.
            let tree = await Task.detached(priority: .userInitiated) { [self] in
                self.buildFileTree(at: url)
            }.value

            self.fileTree = tree
            if let tree = tree {
                self.expandedPaths.insert(tree.url.path)
            }
            self.isLoading = false
        }
    }

    // MARK: - File Read/Write

    /// Write UTF-8 text to a URL, handling security-scoped access when applicable.
    func writeFile(at url: URL, content: String) throws {
        // Try to access the file; if that fails, try its parent folder (common on iPadOS).
        let didStartItem = url.startAccessingSecurityScopedResource()
        let parentURL = url.deletingLastPathComponent()
        let didStartParent = (!didStartItem) ? parentURL.startAccessingSecurityScopedResource() : false

        defer {
            if didStartItem { url.stopAccessingSecurityScopedResource() }
            if didStartParent { parentURL.stopAccessingSecurityScopedResource() }
        }

        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Create a new empty file, choosing a unique name if needed, and return its URL.
    func createFileUnique(named name: String, in folder: URL) throws -> URL {
        let didStart = folder.startAccessingSecurityScopedResource()
        defer { if didStart { folder.stopAccessingSecurityScopedResource() } }

        let initialURL = folder.appendingPathComponent(name, isDirectory: false)
        let finalURL = uniqueDestinationURL(for: initialURL, fileManager: FileManager.default)

        let created = FileManager.default.createFile(atPath: finalURL.path, contents: Data(), attributes: nil)
        if !created {
            throw NSError(domain: "FileSystemNavigator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create file"])
        }

        Task { [weak self] in self?.refreshFileTree() }
        return finalURL
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

        Task { [weak self] in self?.refreshFileTree() }
        return fileURL
    }

    /// Backwards-compatible async API.
    func createFile(name: String, in folder: URL) {
        // Security-scoped access must begin on the calling (main) thread.
        let didStart = folder.startAccessingSecurityScopedResource()
        Task(priority: .userInitiated) { [weak self] in
            guard let self else {
                if didStart { folder.stopAccessingSecurityScopedResource() }
                return
            }
            defer { if didStart { folder.stopAccessingSecurityScopedResource() } }

            let fileURL = folder.appendingPathComponent(name, isDirectory: false)
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: fileURL.path) {
                let success = fileManager.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)
                if !success {
                    AppLogger.fileSystem.error("Failed to create file at \(fileURL.path)")
                }
            }

            self.refreshFileTree()
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
        Task { [weak self] in self?.refreshFileTree() }
        return folderURL
    }

    /// Backwards-compatible async API.
    func createFolder(name: String, in folder: URL) {
        // Security-scoped access must begin on the calling (main) thread.
        let didStart = folder.startAccessingSecurityScopedResource()
        Task(priority: .userInitiated) { [weak self] in
            guard let self else {
                if didStart { folder.stopAccessingSecurityScopedResource() }
                return
            }
            defer { if didStart { folder.stopAccessingSecurityScopedResource() } }

            let folderURL = folder.appendingPathComponent(name, isDirectory: true)
            let fileManager = FileManager.default
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                AppLogger.fileSystem.error("Error creating folder at \(folderURL): \(error)")
            }

            self.refreshFileTree()
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
        Task { [weak self] in self?.refreshFileTree() }
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

        Task { [weak self] in self?.refreshFileTree() }
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
                Task { [weak self] in self?.refreshFileTree() }
            }
            return true
        } catch {
            AppLogger.fileSystem.error("Error moving item from \(source) to \(destination): \(error)")
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
            AppLogger.fileSystem.error("Error deleting item at \(url): \(error)")
            success = false
        }

        Task { [weak self] in self?.refreshFileTree() }
        return success
    }

    // MARK: - Tree

    nonisolated private func buildFileTree(at url: URL, depth: Int = 0, maxEagerDepth: Int = 2) -> FileTreeNode? {
        let fileManager = FileManager.default

        do {
            let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .nameKey])
            let isDirectory = resourceValues.isDirectory ?? false
            let name = resourceValues.name ?? url.lastPathComponent

            if isDirectory {
                // Only eagerly load children up to maxEagerDepth levels deep
                // Beyond that, create placeholder nodes that load on-demand
                if depth < maxEagerDepth {
                    let contents = try fileManager.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: [.isDirectoryKey],
                        options: [.skipsHiddenFiles]
                    )
                    let children = contents.compactMap { buildFileTree(at: $0, depth: depth + 1, maxEagerDepth: maxEagerDepth) }
                        .sorted { lhs, rhs in
                            // Directories first, then alphabetically
                            if lhs.isDirectory != rhs.isDirectory { return lhs.isDirectory }
                            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                        }
                    return FileTreeNode(url: url, name: name, isDirectory: true, children: children)
                } else {
                    // Shallow: just mark as directory with no children yet
                    // Children will be loaded when user expands this folder
                    return FileTreeNode(url: url, name: name, isDirectory: true, children: [])
                }
            } else {
                return FileTreeNode(url: url, name: name, isDirectory: false, children: [])
            }
        } catch {
            AppLogger.fileSystem.error("Error building file tree at \(url): \(error)")
            return nil
        }
    }
    
    /// Lazily load children for a directory node when it's expanded
    func loadChildrenIfNeeded(for node: FileTreeNode) {
        guard node.isDirectory, node.children.isEmpty else { return }
        
        Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            let url = node.url
            
            let children = await Task.detached(priority: .userInitiated) { [self] () -> [FileTreeNode] in
                let fileManager = FileManager.default
                do {
                    let contents = try fileManager.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: [.isDirectoryKey],
                        options: [.skipsHiddenFiles]
                    )
                    return contents.compactMap { childURL -> FileTreeNode? in
                        let resourceValues = try? childURL.resourceValues(forKeys: [.isDirectoryKey, .nameKey])
                        let isDir = resourceValues?.isDirectory ?? false
                        let childName = resourceValues?.name ?? childURL.lastPathComponent
                        if isDir {
                            return FileTreeNode(url: childURL, name: childName, isDirectory: true, children: [])
                        } else {
                            return FileTreeNode(url: childURL, name: childName, isDirectory: false, children: [])
                        }
                    }.sorted { lhs, rhs in
                        if lhs.isDirectory != rhs.isDirectory { return lhs.isDirectory }
                        return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                    }
                } catch {
                    return []
                }
            }.value
            
            // Rebuild the tree with the new children inserted
            if let root = self.fileTree {
                self.fileTree = self.insertChildren(children, for: node.url, in: root)
            }
        }
    }
    
    /// Recursively find and replace a node's children in the tree
    private func insertChildren(_ children: [FileTreeNode], for targetURL: URL, in node: FileTreeNode) -> FileTreeNode {
        if node.url == targetURL {
            return FileTreeNode(url: node.url, name: node.name, isDirectory: node.isDirectory, children: children)
        }
        guard node.isDirectory else { return node }
        let updatedChildren = node.children.map { insertChildren(children, for: targetURL, in: $0) }
        return FileTreeNode(url: node.url, name: node.name, isDirectory: node.isDirectory, children: updatedChildren)
    }

    func toggleExpanded(path: String) {
        if expandedPaths.contains(path) {
            expandedPaths.remove(path)
        } else {
            expandedPaths.insert(path)
            // Lazy load children when expanding a folder
            if let root = fileTree {
                if let node = findNode(at: path, in: root), node.isDirectory, node.children.isEmpty {
                    loadChildrenIfNeeded(for: node)
                }
            }
        }
    }
    
    /// Find a node by path in the tree
    private func findNode(at path: String, in node: FileTreeNode) -> FileTreeNode? {
        if node.url.path == path { return node }
        for child in node.children {
            if let found = findNode(at: path, in: child) { return found }
        }
        return nil
    }

    // MARK: - Helpers

    private func uniqueDestinationURL(for initial: URL, fileManager: FileManager) -> URL {
        if !fileManager.fileExists(atPath: initial.path) { return initial }

        let folder = initial.deletingLastPathComponent()
        let isDirectory = (try? initial.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? initial.hasDirectoryPath

        let baseName = initial.deletingPathExtension().lastPathComponent
        let ext = initial.pathExtension

        var counter = 1
        let maxAttempts = 1000
        while counter <= maxAttempts {
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
        // Fallback: return with counter suffix even if it exists
        let fallbackName = ext.isEmpty ? "\(baseName) \(maxAttempts + 1)" : "\(baseName) \(maxAttempts + 1).\(ext)"
        return folder.appendingPathComponent(fallbackName, isDirectory: isDirectory)
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
