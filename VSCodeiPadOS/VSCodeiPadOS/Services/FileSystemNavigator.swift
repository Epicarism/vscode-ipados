import SwiftUI

class FileSystemNavigator: ObservableObject {
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
    
    // ADD: Refresh file tree method
    func refreshFileTree() {
        guard let currentTree = fileTree else { return }
        let rootURL = currentTree.url
        
        // Clear expanded paths except root
        let rootPath = rootURL.path
        expandedPaths = expandedPaths.filter { $0 == rootPath }
        
        // Reload the tree
        loadFileTree(at: rootURL)
    }
    
    private func buildFileTree(at url: URL) -> FileTreeNode? {
        let fileManager = FileManager.default
        
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .nameKey])
            let isDirectory = resourceValues.isDirectory ?? false
            let name = resourceValues.name ?? url.lastPathComponent
            
            if isDirectory {
                let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
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
}

struct FileTreeNode: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let isDirectory: Bool
    let children: [FileTreeNode]
}
