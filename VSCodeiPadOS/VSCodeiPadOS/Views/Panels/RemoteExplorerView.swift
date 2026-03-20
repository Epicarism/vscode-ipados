import SwiftUI

// MARK: - Remote Explorer View

struct RemoteExplorerView: View {
    @ObservedObject var editorCore: EditorCore
    @ObservedObject private var connectionStore = SSHConnectionStore.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @StateObject private var remoteFileNavigator = RemoteFileNavigator()
    
    @State private var showConnectionSheet = false
    @State private var selectedConnection: SSHConnectionConfig?
    @State private var activeTerminal: TerminalManager?
    @State private var connectionTask: Task<Void, Never>?
    @State private var isConnecting = false

    // Toolbar new file/folder alerts
    @State private var remoteShowingNewFileAlert = false
    @State private var remoteNewFileName = ""
    @State private var remoteNewFileTargetPath = "~"
    @State private var remoteShowingNewFolderAlert = false
    @State private var remoteNewFolderName = ""
    @State private var remoteNewFolderTargetPath = "~"
    @State private var remoteToolbarOperationError: String?
    @State private var remoteShowingToolbarOperationError = false
    
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
        .overlay {
            if isConnecting {
                VStack {
                    ProgressView()
                    Text("Connecting...")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
            }
        }
        .onDisappear {
            connectionTask?.cancel()
            connectionTask = nil
        }
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
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                SSHConnectionStore.shared.savedConnections.removeAll(where: { $0.id == config.id })
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
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
                // New File / New Folder menu
                Menu {
                    Button {
                        remoteNewFileName = "untitled.txt"
                        remoteNewFileTargetPath = remoteFileNavigator.rootNode?.path ?? "~"
                        remoteShowingNewFileAlert = true
                    } label: {
                        Label("New File", systemImage: "doc.badge.plus")
                    }
                    Button {
                        remoteNewFolderName = "New Folder"
                        remoteNewFolderTargetPath = remoteFileNavigator.rootNode?.path ?? "~"
                        remoteShowingNewFolderAlert = true
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                        .foregroundColor(theme.sidebarForeground.opacity(0.7))
                }
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
        .alert("New File", isPresented: $remoteShowingNewFileAlert) {
            TextField("File name", text: $remoteNewFileName)
            Button("Cancel", role: .cancel) { }
            Button("Create") {
                guard !remoteNewFileName.isEmpty else { return }
                remoteFileNavigator.createFile(name: remoteNewFileName, inDirectory: remoteNewFileTargetPath) { result in
                    Task { @MainActor in
                        switch result {
                        case .success:
                            remoteFileNavigator.refreshRoot()
                        case .failure(let error):
                            remoteToolbarOperationError = error.localizedDescription
                            remoteShowingToolbarOperationError = true
                        }
                    }
                }
            }
        }
        .alert("New Folder", isPresented: $remoteShowingNewFolderAlert) {
            TextField("Folder name", text: $remoteNewFolderName)
            Button("Cancel", role: .cancel) { }
            Button("Create") {
                guard !remoteNewFolderName.isEmpty else { return }
                remoteFileNavigator.createRemoteDirectory(name: remoteNewFolderName, inDirectory: remoteNewFolderTargetPath) { result in
                    Task { @MainActor in
                        switch result {
                        case .success:
                            remoteFileNavigator.refreshRoot()
                        case .failure(let error):
                            remoteToolbarOperationError = error.localizedDescription
                            remoteShowingToolbarOperationError = true
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: $remoteShowingToolbarOperationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(remoteToolbarOperationError ?? "An unknown error occurred.")
        }
    }
    
    // MARK: - Helper Methods
    
    private func connectToSaved(_ config: SSHConnectionConfig) {
        isConnecting = true
        
        let terminal = TerminalManager()
        activeTerminal = terminal
        
        // Cancel any previous connection attempt
        connectionTask?.cancel()
        
        // Connect and wait for actual connection status
        terminal.connect(to: config)
        
        // Monitor connection status with proper cancellation handling
        connectionTask = Task {
            defer {
                DispatchQueue.main.async {
                    self.isConnecting = false
                }
            }
            
            // Wait up to 10 seconds for connection
            for _ in 0..<20 {
                if Task.isCancelled { return }
                if terminal.isConnected {
                    await MainActor.run {
                        loadRemoteFiles()
                    }
                    return
                }
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
            // Connection timeout - let user know
            guard !Task.isCancelled else { return }
            await MainActor.run {
                remoteFileNavigator.errorMessage = "SSH connection timeout after 10 seconds"
                activeTerminal = nil
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
    
    private var sftpManager: SFTPManager?
    private var terminal: TerminalManager?
    
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
        
        // Create temporary file URL
        let tempDir = FileManager.default.temporaryDirectory
        let localURL = tempDir.appendingPathComponent(node.name)
        
        // Download file via SFTP
        sftpManager.downloadFile(remotePath: node.path, localURL: localURL) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success:
                    // Open the downloaded file in editor
                    do {
                        let content = try String(contentsOf: localURL, encoding: .utf8)
                        let hostIdentifier = self.terminal?.title ?? SSHManager.shared.connectedHostName ?? "remote"
                        editorCore.addTab(fileName: node.name, content: content, remotePath: node.path, remoteHost: hostIdentifier)
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
    
    func clearFiles() {
        rootNode = nil
        expandedPaths.removeAll()
        errorMessage = nil
        sftpManager?.disconnect()
        sftpManager = nil
        terminal = nil
    }

    // MARK: - File Operations

    func createFile(name: String, inDirectory dirPath: String, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard let sftpManager = sftpManager else {
            completion(.failure(NSError(domain: "SFTP", code: -1, userInfo: [NSLocalizedDescriptionKey: "SFTP not initialized"])))
            return
        }
        let remotePath = dirPath == "~" ? "~/\(name)" : "\(dirPath)/\(name)"
        sftpManager.writeTextFile(remotePath: remotePath, content: "") { result in
            completion(result)
        }
    }

    func createRemoteDirectory(name: String, inDirectory dirPath: String, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard let sftpManager = sftpManager else {
            completion(.failure(NSError(domain: "SFTP", code: -1, userInfo: [NSLocalizedDescriptionKey: "SFTP not initialized"])))
            return
        }
        let remotePath = dirPath == "~" ? "~/\(name)" : "\(dirPath)/\(name)"
        sftpManager.createDirectory(remotePath: remotePath) { result in
            completion(result)
        }
    }

    func renameItem(at oldPath: String, to newName: String, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard let sftpManager = sftpManager else {
            completion(.failure(NSError(domain: "SFTP", code: -1, userInfo: [NSLocalizedDescriptionKey: "SFTP not initialized"])))
            return
        }
        let parentPath = (oldPath as NSString).deletingLastPathComponent
        let newPath = parentPath.isEmpty ? newName : "\(parentPath)/\(newName)"
        sftpManager.rename(from: oldPath, to: newPath) { result in
            completion(result)
        }
    }

    func deleteItem(at path: String, isDirectory: Bool, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard let sftpManager = sftpManager else {
            completion(.failure(NSError(domain: "SFTP", code: -1, userInfo: [NSLocalizedDescriptionKey: "SFTP not initialized"])))
            return
        }
        sftpManager.delete(remotePath: path, recursive: isDirectory) { result in
            completion(result)
        }
    }

    func refreshParentDirectory(of path: String) {
        let parentPath = (path as NSString).deletingLastPathComponent
        let resolvedParent: String
        if parentPath.isEmpty || parentPath == "." {
            resolvedParent = rootNode?.path ?? "~"
        } else {
            resolvedParent = parentPath
        }
        if let root = rootNode {
            let parentNode = Self.findNode(in: root, path: resolvedParent)
            listDirectory(path: resolvedParent, parent: parentNode)
        }
    }

    func refreshRoot() {
        guard let root = rootNode else { return }
        listDirectory(path: root.path, parent: nil)
    }

    private static func findNode(in node: RemoteFileNode, path: String) -> RemoteFileNode? {
        if node.path == path { return node }
        for child in node.children {
            if let found = findNode(in: child, path: path) { return found }
        }
        return nil
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

    // MARK: - Alert state
    @State private var showingNewFileAlert = false
    @State private var newFileName = ""
    @State private var showingNewFolderAlert = false
    @State private var newFolderName = ""
    @State private var showingRenameAlert = false
    @State private var newName = ""
    @State private var showingDeleteConfirmation = false
    @State private var operationError: String?
    @State private var showingOperationError = false

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
            .contextMenu {
                // New File / New Folder (only for directories)
                if node.isDirectory {
                    Button {
                        newFileName = "untitled.txt"
                        showingNewFileAlert = true
                    } label: {
                        Label("New File", systemImage: "doc.badge.plus")
                    }

                    Button {
                        newFolderName = "New Folder"
                        showingNewFolderAlert = true
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }

                    Divider()
                }

                // Rename
                Button {
                    newName = node.name
                    showingRenameAlert = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                }

                // Delete
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }

                Divider()

                // Copy Path
                Button {
                    UIPasteboard.general.string = node.path
                } label: {
                    Label("Copy Path", systemImage: "doc.on.doc")
                }
            }
            // MARK: - Alerts
            .alert("New File", isPresented: $showingNewFileAlert) {
                TextField("File name", text: $newFileName)
                Button("Cancel", role: .cancel) { }
                Button("Create") {
                    guard !newFileName.isEmpty else { return }
                    navigator.createFile(name: newFileName, inDirectory: node.path) { result in
                        Task { @MainActor in
                            switch result {
                            case .success:
                                navigator.refreshParentDirectory(of: node.path + "/" + newFileName)
                            case .failure(let error):
                                operationError = error.localizedDescription
                                showingOperationError = true
                            }
                        }
                    }
                }
            }
            .alert("New Folder", isPresented: $showingNewFolderAlert) {
                TextField("Folder name", text: $newFolderName)
                Button("Cancel", role: .cancel) { }
                Button("Create") {
                    guard !newFolderName.isEmpty else { return }
                    navigator.createRemoteDirectory(name: newFolderName, inDirectory: node.path) { result in
                        Task { @MainActor in
                            switch result {
                            case .success:
                                navigator.refreshParentDirectory(of: node.path + "/" + newFolderName)
                            case .failure(let error):
                                operationError = error.localizedDescription
                                showingOperationError = true
                            }
                        }
                    }
                }
            }
            .alert("Rename", isPresented: $showingRenameAlert) {
                TextField("Name", text: $newName)
                Button("Cancel", role: .cancel) { }
                Button("Rename") {
                    guard !newName.isEmpty, newName != node.name else { return }
                    navigator.renameItem(at: node.path, to: newName) { result in
                        Task { @MainActor in
                            switch result {
                            case .success:
                                navigator.refreshParentDirectory(of: node.path)
                            case .failure(let error):
                                operationError = error.localizedDescription
                                showingOperationError = true
                            }
                        }
                    }
                }
            }
            .alert("Delete \"\(node.name)\"?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    navigator.deleteItem(at: node.path, isDirectory: node.isDirectory) { result in
                        Task { @MainActor in
                            switch result {
                            case .success:
                                navigator.refreshParentDirectory(of: node.path)
                            case .failure(let error):
                                operationError = error.localizedDescription
                                showingOperationError = true
                            }
                        }
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .alert("Error", isPresented: $showingOperationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(operationError ?? "An unknown error occurred.")
            }

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
