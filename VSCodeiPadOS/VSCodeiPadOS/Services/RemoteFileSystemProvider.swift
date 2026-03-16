//
//  RemoteFileSystemProvider.swift
//  VSCodeiPadOS
//
//  Remote file system abstraction over SSH/SFTP
//  Provides workspace concept for connected remote folders
//

import SwiftUI
import Foundation
import Combine

// MARK: - Remote File Node

/// Represents a file or directory node in the remote file system tree
struct RemoteFileNode: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let isDirectory: Bool
    var children: [RemoteFileNode]
    let size: UInt64
    let permissions: String
    let modificationDate: Date?
    
    var fileExtension: String {
        (name as NSString).pathExtension.lowercased()
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RemoteFileNode, rhs: RemoteFileNode) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Remote Workspace

/// Represents a saved remote workspace (folder opened via SSH)
struct RemoteWorkspace: Identifiable, Codable {
    var id: UUID = UUID()
    var connectionId: UUID  // SSHConnectionConfig.id
    var remotePath: String
    var name: String
    var lastOpened: Date?
}

// MARK: - Remote File System Provider

/// Provides remote file system abstraction over SSH/SFTP
/// Acts as the bridge between SSH/SFTP and the editor
@MainActor final class RemoteFileSystemProvider: ObservableObject, @unchecked Sendable {
    // MARK: - Published Properties
    
    /// Tree structure of remote files
    @Published var remoteFiles: [RemoteFileNode] = []
    
    /// Current remote working directory path
    @Published var currentRemotePath: String = "~"
    
    /// Connection status
    @Published var isConnected: Bool = false
    
    /// Name of the current connection/workspace
    @Published var connectionName: String = ""
    
    /// Expanded paths in the tree view
    @Published var expandedPaths: Set<String> = []
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    /// Error message if any
    @Published var errorMessage: String?
    
    /// Recently opened remote workspaces
    @Published var recentWorkspaces: [RemoteWorkspace] = []
    
    // MARK: - Private Properties
    
    private var sftpManager: SFTPManager?
    private var currentConfig: SSHConnectionConfig?
    
    /// Cache for directory listings (path -> nodes)
    private var directoryCache: [String: [RemoteFileNode]] = [:]
    
    /// Cache expiration time (5 minutes)
    private let cacheExpirationInterval: TimeInterval = 300
    
    /// Cache timestamps
    private var cacheTimestamps: [String: Date] = [:]
    
    /// The root path of the workspace
    private(set) var workspaceRootPath: String?
    
    // MARK: - Initialization
    
    init() {
        loadRecentWorkspaces()
    }
    
    // MARK: - Connection Management
    
    /// Connect to a remote server and establish a workspace
    func connect(config: SSHConnectionConfig) async throws {
        connectionName = config.name
        currentConfig = config
        
        isLoading = true
        errorMessage = nil
        
        // Create new SFTP manager
        let manager = SFTPManager()
        sftpManager = manager
        
        // Connect using completion handler (since SFTPManager uses that pattern)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.connect(config: config) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        isConnected = true
        isLoading = false
        
        // Set initial path and load directory
        currentRemotePath = "~"
        workspaceRootPath = currentRemotePath
        try await refreshCurrentDirectory()
    }
    
    /// Disconnect from the remote server
    func disconnect() {
        sftpManager?.disconnect()
        sftpManager = nil
        currentConfig = nil
        workspaceRootPath = nil
        
        isConnected = false
        remoteFiles = []
        currentRemotePath = "~"
        connectionName = ""
        expandedPaths.removeAll()
        clearCache()
    }
    
    // MARK: - Directory Operations
    
    /// List files in a remote directory
    func listDirectory(_ path: String) async throws -> [RemoteFileNode] {
        guard isConnected else {
            throw SFTPError.notConnected
        }
        
        // Check cache first
        if let cached = getCachedDirectory(path) {
            return cached
        }
        
        guard let manager = sftpManager else {
            throw SFTPError.notConnected
        }
        
        // List directory using SFTP
        let fileInfos = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[SFTPFileInfo], Error>) in
            manager.listDirectory(path) { result in
                switch result {
                case .success(let files):
                    continuation.resume(returning: files)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Convert SFTPFileInfo to RemoteFileNode
        let nodes = fileInfos.map { info in
            RemoteFileNode(
                name: info.name,
                path: info.path,
                isDirectory: info.isDirectory,
                children: [],
                size: info.size,
                permissions: info.permissions,
                modificationDate: info.modificationDate
            )
        }.sorted { $0.name < $1.name }
        
        // Cache the result
        cacheDirectory(path, nodes: nodes)
        
        return nodes
    }
    
    /// Refresh the current directory listing
    func refreshCurrentDirectory() async {
        do {
            // Invalidate cache for current path
            invalidateCache(currentRemotePath)
            
            isLoading = true
            
            let nodes = try await listDirectory(currentRemotePath)
            
            self.remoteFiles = nodes
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    /// Navigate to a specific directory
    func navigateToDirectory(_ path: String) async {
        currentRemotePath = path
        await refreshCurrentDirectory()
    }
    
    /// Open a remote folder as workspace root
    func openRemoteFolder(_ path: String) async throws {
        guard isConnected else {
            throw SFTPError.notConnected
        }
        
        // Resolve path to absolute
        let absolutePath = try await getAbsolutePath(path)
        
        // Set as workspace root
        workspaceRootPath = absolutePath
        currentRemotePath = absolutePath
        
        // Save as recent workspace
        saveRecentWorkspace()
        
        // Load directory contents
        await refreshCurrentDirectory()
    }
    
    /// Expand a directory node (load children on demand)
    func expandDirectory(_ node: RemoteFileNode) async {
        guard node.isDirectory else { return }
        
        // Toggle expanded state
        expandedPaths.insert(node.path)
        
        // Load children if not already loaded
        if node.children.isEmpty {
            await loadChildren(for: node)
        }
    }
    
    // MARK: - File Operations
    
    /// Read a remote file's content (for editor)
    func readFile(_ path: String) async throws -> String {
        guard isConnected else {
            throw SFTPError.notConnected
        }
        
        guard let manager = sftpManager else {
            throw SFTPError.notConnected
        }
        
        // Read file using SFTP
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            manager.readTextFile(remotePath: path) { result in
                switch result {
                case .success(let content):
                    continuation.resume(returning: content)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Write content to a remote file
    func writeFile(_ path: String, content: String) async throws {
        guard isConnected else {
            throw SFTPError.notConnected
        }
        
        guard let manager = sftpManager else {
            throw SFTPError.notConnected
        }
        
        // Write file using SFTP
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.writeTextFile(remotePath: path, content: content) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Invalidate cache for parent directory
        let parentPath = (path as NSString).deletingLastPathComponent
        invalidateCache(parentPath)
    }
    
    /// Create a new empty file
    func createFile(_ path: String) async throws {
        guard isConnected else {
            throw SFTPError.notConnected
        }
        
        // Create empty file by writing empty content
        try await writeFile(path, content: "")
        
        // Refresh current directory
        await refreshCurrentDirectory()
    }
    
    /// Create a new directory
    func createDirectory(_ path: String) async throws {
        guard isConnected else {
            throw SFTPError.notConnected
        }
        
        guard let manager = sftpManager else {
            throw SFTPError.notConnected
        }
        
        // Create directory using SFTP
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.createDirectory(remotePath: path) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Invalidate cache for parent directory
        let parentPath = (path as NSString).deletingLastPathComponent
        invalidateCache(parentPath)
        
        // Refresh current directory
        await refreshCurrentDirectory()
    }
    
    /// Delete a file or directory
    func delete(_ path: String) async throws {
        guard isConnected else {
            throw SFTPError.notConnected
        }
        
        guard let manager = sftpManager else {
            throw SFTPError.notConnected
        }
        
        // Determine if it's a directory by checking our cache or current files
        let isDirectory = remoteFiles.first { $0.path == path }?.isDirectory ?? false
        
        // Delete using SFTP
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.delete(remotePath: path, recursive: isDirectory) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Invalidate cache for parent directory
        let parentPath = (path as NSString).deletingLastPathComponent
        invalidateCache(parentPath)
        
        // Refresh current directory
        await refreshCurrentDirectory()
    }
    
    /// Rename or move a file/directory
    func rename(from oldPath: String, to newPath: String) async throws {
        guard isConnected else {
            throw SFTPError.notConnected
        }
        
        guard let manager = sftpManager else {
            throw SFTPError.notConnected
        }
        
        // Rename using SFTP
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.rename(from: oldPath, to: newPath) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Invalidate cache for both old and new parent directories
        let oldParentPath = (oldPath as NSString).deletingLastPathComponent
        let newParentPath = (newPath as NSString).deletingLastPathComponent
        invalidateCache(oldParentPath)
        if oldParentPath != newParentPath {
            invalidateCache(newParentPath)
        }
        
        // Refresh current directory
        await refreshCurrentDirectory()
    }
    
    // MARK: - Tree Management
    
    /// Toggle expanded state for a path
    func toggleExpanded(path: String) {
        if expandedPaths.contains(path) {
            expandedPaths.remove(path)
        } else {
            expandedPaths.insert(path)
        }
    }
    
    /// Load children for a directory node
    func loadChildren(for node: RemoteFileNode) async {
        guard node.isDirectory else { return }
        
        do {
            let children = try await listDirectory(node.path)
            
            // Update the node in our tree
            if let index = self.remoteFiles.firstIndex(where: { $0.id == node.id }) {
                var updatedNode = self.remoteFiles[index]
                updatedNode.children = children
                self.remoteFiles[index] = updatedNode
            }
        } catch {
            self.errorMessage = "Failed to load children: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Cache Management
    
    /// Get cached directory listing if valid
    private func getCachedDirectory(_ path: String) -> [RemoteFileNode]? {
        guard let cached = directoryCache[path],
              let timestamp = cacheTimestamps[path] else {
            return nil
        }
        
        // Check if cache is still valid
        if Date().timeIntervalSince(timestamp) < cacheExpirationInterval {
            return cached
        }
        
        // Cache expired
        directoryCache.removeValue(forKey: path)
        cacheTimestamps.removeValue(forKey: path)
        return nil
    }
    
    /// Cache directory listing
    private func cacheDirectory(_ path: String, nodes: [RemoteFileNode]) {
        directoryCache[path] = nodes
        cacheTimestamps[path] = Date()
    }
    
    /// Invalidate cache for a specific path
    private func invalidateCache(_ path: String) {
        directoryCache.removeValue(forKey: path)
        cacheTimestamps.removeValue(forKey: path)
    }
    
    /// Clear all cache
    private func clearCache() {
        directoryCache.removeAll()
        cacheTimestamps.removeAll()
    }
    
    // MARK: - Workspace Management
    
    /// Check if a path is within the current workspace
    func isInWorkspace(_ path: String) -> Bool {
        guard let workspaceRoot = workspaceRootPath else {
            return false
        }
        return path.hasPrefix(workspaceRoot)
    }
    
    /// Get relative path within workspace
    func relativePathInWorkspace(_ path: String) -> String? {
        guard let workspaceRoot = workspaceRootPath,
              path.hasPrefix(workspaceRoot) else {
            return nil
        }
        
        let relativePath = String(path.dropFirst(workspaceRoot.count))
        return relativePath.hasPrefix("/") ? String(relativePath.dropFirst()) : relativePath
    }
    
    /// Get workspace display name
    var workspaceName: String {
        if let root = workspaceRootPath {
            return (root as NSString).lastPathComponent
        }
        return connectionName
    }
    
    // MARK: - Helper Methods
    
    /// Build full path from directory and filename
    func buildPath(directory: String, filename: String) -> String {
        if directory.hasSuffix("/") {
            return directory + filename
        } else {
            return directory + "/" + filename
        }
    }
    
    /// Navigate up one directory level
    func navigateUp() async {
        let parent = (currentRemotePath as NSString).deletingLastPathComponent
        if !parent.isEmpty {
            await navigateToDirectory(parent)
        }
    }
    
    /// Check if current path is the workspace root
    var isAtWorkspaceRoot: Bool {
        return currentRemotePath == workspaceRootPath
    }
    
    /// Get absolute path, resolving ~ and relative paths
    func getAbsolutePath(_ path: String) async throws -> String {
        guard isConnected else {
            throw SFTPError.notConnected
        }
        
        guard let manager = sftpManager else {
            throw SFTPError.notConnected
        }
        
        // If path starts with ~, expand it using pwd
        if path.hasPrefix("~") {
            // Execute pwd command to get home directory
            // For now, we'll use a simple substitution
            // In production, this should execute "echo ~" via SSH
            return path.replacingOccurrences(of: "~", with: "/home/\(currentConfig?.username ?? "user")")
        }
        
        // If path is already absolute, return it
        if path.hasPrefix("/") {
            return path
        }
        
        // Otherwise, make it relative to current directory
        return buildPath(directory: currentRemotePath, filename: path)
    }
    
    // MARK: - Workspace Persistence
    
    /// Save current workspace to recent workspaces
    private func saveRecentWorkspace() {
        guard let config = currentConfig,
              let workspaceRoot = workspaceRootPath else {
            return
        }
        
        let workspace = RemoteWorkspace(
            connectionId: config.id,
            remotePath: workspaceRoot,
            name: workspaceName,
            lastOpened: Date()
        )
        
        // Remove existing workspace with same path/connection
        recentWorkspaces.removeAll { ws in
            ws.connectionId == workspace.connectionId && ws.remotePath == workspace.remotePath
        }
        
        // Add to front
        recentWorkspaces.insert(workspace, at: 0)
        
        // Keep only last 10
        if recentWorkspaces.count > 10 {
            recentWorkspaces = Array(recentWorkspaces.prefix(10))
        }
        
        // Persist to UserDefaults
        persistRecentWorkspaces()
    }
    
    /// Load recent workspaces from UserDefaults
    private func loadRecentWorkspaces() {
        let key = "remote_recent_workspaces"
        guard let data = UserDefaults.standard.data(forKey: key),
              let workspaces = try? JSONDecoder().decode([RemoteWorkspace].self, from: data) else {
            return
        }
        recentWorkspaces = workspaces
    }
    
    /// Persist recent workspaces to UserDefaults
    private func persistRecentWorkspaces() {
        let key = "remote_recent_workspaces"
        guard let data = try? JSONEncoder().encode(recentWorkspaces) else {
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }
}

// MARK: - Extensions

extension RemoteFileNode {
    /// Create a flat list of all nodes (for search/filtering)
    func flatten() -> [RemoteFileNode] {
        var result = [self]
        for child in children {
            result.append(contentsOf: child.flatten())
        }
        return result
    }
}
