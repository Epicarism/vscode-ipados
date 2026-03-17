import SwiftUI

// MARK: - Remote Explorer View

struct RemoteExplorerView: View {
    @ObservedObject var editorCore: EditorCore
    @StateObject private var connectionStore = SSHConnectionStore.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var remoteFileNavigator = RemoteFileNavigator()
    
    @State private var showConnectionSheet = false
    @State private var selectedConnection: SSHConnectionConfig?
    @State private var activeTerminal: TerminalManager?
    
    private var theme: Theme { themeManager.currentTheme }
    
    var body: some View {
        VStack(spacing: 0) {
            if let terminal = activeTerminal, terminal.isConnected {
                // Connected - show remote file explorer
                connectedView
            } else {
                // Not connected - show connection list
                connectionListView
            }
        }
        .background(theme.sidebarBackground)
        .sheet(isPresented: $showConnectionSheet) {
            if let terminal = activeTerminal {
                SSHConnectionView(terminal: terminal, isPresented: $showConnectionSheet)
            }
        }
    }
    
    // MARK: - Connection List View
    
    @ViewBuilder
    private var connectionListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // New Connection Button
                Button(action: {
                    activeTerminal = TerminalManager()
                    showConnectionSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                        Text("New SSH Connection")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(theme.sidebarForeground)
                        Spacer()
                    }
                    .padding(12)
                    .background(theme.sidebarForeground.opacity(0.05))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                // Saved Connections
                if !connectionStore.savedConnections.isEmpty {
                    Text("SAVED CONNECTIONS")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                    
                    ForEach(connectionStore.savedConnections) { config in
                        SavedConnectionRow(config: config, theme: theme) {
                            connectToSaved(config)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(12)
        }
    }
    
    // MARK: - Connected View
    
    @ViewBuilder
    private var connectedView: some View {
        VStack(spacing: 0) {
            // Connection header with disconnect button
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(activeTerminal?.title ?? "Connected")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.sidebarForeground)
                    Text(activeTerminal?.connectionStatus ?? "")
                        .font(.system(size: 10))
                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
                }
                Spacer()
                Button(action: {
                    activeTerminal?.disconnect()
                    activeTerminal = nil
                    remoteFileNavigator.clearFiles()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.sidebarForeground.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(theme.activityBarBackground)
            
            Divider()
                .background(Color(UIColor.separator))
            
            // Remote file explorer
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    // Save status indicator
                    if remoteFileNavigator.isSaving {
                        HStack(spacing: 6) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Saving remote file…")
                                .font(.system(size: 11))
                                .foregroundColor(theme.sidebarForeground.opacity(0.7))
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                    } else if remoteFileNavigator.lastSaveSuccess {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.green)
                            Text("Saved to remote server")
                                .font(.system(size: 11))
                                .foregroundColor(.green)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                    } else if let saveError = remoteFileNavigator.lastSaveError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                            Text(saveError)
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                                .lineLimit(2)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                    }
                    
                    if remoteFileNavigator.isLoading {
                        ProgressView()
                            .padding()
                    } else if let error = remoteFileNavigator.errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundColor(theme.sidebarForeground.opacity(0.8))
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                loadRemoteFiles()
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.accentColor)
                        }
                        .padding()
                    } else if let rootNode = remoteFileNavigator.rootNode {
                        RemoteFileTreeView(
                            node: rootNode,
                            navigator: remoteFileNavigator,
                            editorCore: editorCore,
                            theme: theme
                        )
                    } else {
                        Button(action: { loadRemoteFiles() }) {
                            HStack {
                                Image(systemName: "folder")
                                Text("Browse Files")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.accentColor)
                            .padding()
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func connectToSaved(_ config: SSHConnectionConfig) {
        let terminal = TerminalManager()
        activeTerminal = terminal
        
        // Connect and wait for actual connection status
        terminal.connect(to: config)
        
        // Monitor connection status with proper async handling
        Task {
            // Wait up to 10 seconds for connection
            for _ in 0..<20 {
                if terminal.isConnected {
                    await MainActor.run {
                        loadRemoteFiles()
                    }
                    return
                }
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
            // Connection timeout - let user know
            await MainActor.run {
                remoteFileNavigator.errorMessage = "SSH connection timeout after 10 seconds"
            }
        }
    }
    
    private func loadRemoteFiles() {
        guard let terminal = activeTerminal, terminal.isConnected else { return }
        remoteFileNavigator.loadFiles(via: terminal)
    }
}

// MARK: - Saved Connection Row

struct SavedConnectionRow: View {
    let config: SSHConnectionConfig
    let theme: Theme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "server.rack")
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(config.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.sidebarForeground)
                    Text("\(config.username)@\(config.host):\(config.port)")
                        .font(.system(size: 10))
                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
                }
                
                Spacer()
                
                if case .privateKey = config.authMethod {
                    Image(systemName: "key.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                }
            }
            .padding(10)
            .background(theme.sidebarForeground.opacity(0.03))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Remote File Navigator

@MainActor class RemoteFileNavigator: ObservableObject {
    @Published var rootNode: RemoteFileNode?
    @Published var isLoading = false
    @Published var expandedPaths: Set<String> = []
    @Published var errorMessage: String?
    @Published var isSaving = false
    @Published var lastSaveError: String?
    @Published var lastSaveSuccess = false
    
    private var sftpManager: SFTPManager?
    private var terminal: TerminalManager?
    /// Maps local temp file URLs to their remote paths for save-back support
    private var remotePathMap: [URL: String] = [:]
    
    func loadFiles(via terminal: TerminalManager) {
        self.terminal = terminal
        
        // Initialize SFTP manager with SSH connection
        let ssh = SSHManager.shared
        guard ssh.isConnected else {
            errorMessage = "No SSH connection available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Create SFTP manager using the existing SSH connection
        sftpManager = SFTPManager(sshManager: ssh)
        
        // List home directory
        listDirectory(path: "~")
    }
    
    func listDirectory(path: String, parent: RemoteFileNode? = nil) {
        guard let sftpManager = sftpManager else {
            errorMessage = "SFTP not initialized"
            isLoading = false
            return
        }
        
        sftpManager.listDirectory(path) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                
                switch result {
                case .success(let sftpFiles):
                    // Convert SFTPFileInfo to RemoteFileNode
                    let nodes = sftpFiles.map { info in
                        RemoteFileNode(
                            name: info.name,
                            path: info.path,
                            isDirectory: info.isDirectory,
                            children: [],
                            size: info.size,
                            permissions: info.permissions,
                            modificationDate: info.modificationDate
                        )
                    }
                    
                    if parent != nil {
                        // Update children in the tree by finding the parent node by path
                        if var root = self.rootNode {
                            Self.updateNodeChildren(in: &root, path: path, children: nodes)
                            self.rootNode = root
                        }
                    } else {
                        // Set root node
                        let rootName = path == "~" ? "~" : (path as NSString).lastPathComponent
                        self.rootNode = RemoteFileNode(
                            name: rootName,
                            path: path,
                            isDirectory: true,
                            children: nodes,
                            size: 0,
                            permissions: "drwxr-xr-x",
                            modificationDate: nil
                        )
                    }
                    self.isLoading = false
                    self.errorMessage = nil
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadChildrenIfNeeded(for node: RemoteFileNode) {
        guard node.isDirectory && node.children.isEmpty else { return }
        listDirectory(path: node.path, parent: node)
    }
    
    func openFile(_ node: RemoteFileNode, editorCore: EditorCore) {
        guard !node.isDirectory else { return }
        guard let sftpManager = sftpManager else {
            errorMessage = "SFTP not initialized"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Create unique temporary file URL to avoid collisions
        let tempDir = FileManager.default.temporaryDirectory
        let localURL = tempDir.appendingPathComponent("\(UUID().uuidString)-\(node.name)")
        
        // Track the remote path for save-back
        remotePathMap[localURL] = node.path
        
        // Download file via SFTP
        sftpManager.downloadFile(remotePath: node.path, localURL: localURL) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success:
                    // Open the downloaded file in editor, passing the local URL
                    // so the editor can associate the tab with this remote file
                    do {
                        let content = try String(contentsOf: localURL, encoding: .utf8)
                        editorCore.addTab(fileName: node.name, content: content, url: localURL)
                        self.errorMessage = nil
                    } catch {
                        self.errorMessage = "Failed to read downloaded file: \(error.localizedDescription)"
                    }
                    
                case .failure(let error):
                    self.errorMessage = "Download failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Save an edited remote file back to the server via SFTP upload.
    /// - Parameters:
    ///   - localURL: The local temp URL of the file (used as the key in remotePathMap)
    ///   - content: The updated file content to upload
    func saveFile(localURL: URL, content: String) {
        guard let remotePath = remotePathMap[localURL] else {
            lastSaveError = "No remote path mapping found for this file"
            return
        }
        guard let sftpManager = sftpManager else {
            lastSaveError = "SFTP not initialized"
            return
        }
        
        isSaving = true
        lastSaveError = nil
        lastSaveSuccess = false
        
        // Write content to temp file first, then upload
        do {
            try content.write(to: localURL, atomically: true, encoding: .utf8)
        } catch {
            isSaving = false
            lastSaveError = "Failed to write temp file: \(error.localizedDescription)"
            return
        }
        
        sftpManager.uploadFile(localURL: localURL, remotePath: remotePath) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                self.isSaving = false
                
                switch result {
                case .success:
                    self.lastSaveSuccess = true
                    self.lastSaveError = nil
                    // Clear success flag after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.lastSaveSuccess = false
                    }
                case .failure(let error):
                    self.lastSaveError = "Upload failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Look up the remote path for a given local URL.
    func remotePathForLocalURL(_ url: URL) -> String? {
        remotePathMap[url]
    }
    
    func clearFiles() {
        rootNode = nil
        expandedPaths.removeAll()
        errorMessage = nil
        isSaving = false
        lastSaveError = nil
        lastSaveSuccess = false
        sftpManager?.disconnect()
        sftpManager = nil
        terminal = nil
        remotePathMap.removeAll()
    }
    
    /// Recursively finds a node by path in the tree and updates its children
    private static func updateNodeChildren(in node: inout RemoteFileNode, path: String, children: [RemoteFileNode]) {
        if node.path == path {
            node.children = children
            return
        }
        for i in node.children.indices {
            updateNodeChildren(in: &node.children[i], path: path, children: children)
        }
    }
}

// MARK: - Remote File Node (defined in RemoteFileSystemProvider.swift)

// MARK: - Remote File Tree View

struct RemoteFileTreeView: View {
    let node: RemoteFileNode
    @ObservedObject var navigator: RemoteFileNavigator
    @ObservedObject var editorCore: EditorCore
    let theme: Theme
    let level: Int
    
    init(node: RemoteFileNode, navigator: RemoteFileNavigator, editorCore: EditorCore, theme: Theme, level: Int = 0) {
        self.node = node
        self.navigator = navigator
        self.editorCore = editorCore
        self.theme = theme
        self.level = level
    }
    
    var isExpanded: Bool {
        navigator.expandedPaths.contains(node.path)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                if node.isDirectory {
                    toggleExpanded()
                } else {
                    // Open remote file via SFTP download
                    navigator.openFile(node, editorCore: editorCore)
                }
            }) {
                HStack(spacing: 4) {
                    if node.isDirectory {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 9))
                            .foregroundColor(theme.sidebarForeground.opacity(0.6))
                            .frame(width: 12)
                    } else {
                        Spacer()
                            .frame(width: 12)
                    }
                    
                    Image(systemName: node.isDirectory ? (isExpanded ? "folder.fill" : "folder") : "doc")
                        .font(.system(size: 12))
                        .foregroundColor(node.isDirectory ? .accentColor : theme.sidebarForeground.opacity(0.8))
                    
                    Text(node.name)
                        .font(.system(size: 12))
                        .foregroundColor(theme.sidebarForeground)
                    
                    Spacer()
                }
                .padding(.leading, CGFloat(level * 16))
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded, !node.children.isEmpty {
                ForEach(node.children) { child in
                    RemoteFileTreeView(
                        node: child,
                        navigator: navigator,
                        editorCore: editorCore,
                        theme: theme,
                        level: level + 1
                    )
                }
            }
        }
    }
    
    private func toggleExpanded() {
        if isExpanded {
            navigator.expandedPaths.remove(node.path)
        } else {
            navigator.expandedPaths.insert(node.path)
            // Load children if not already loaded
            navigator.loadChildrenIfNeeded(for: node)
        }
    }
}
