import SwiftUI
import Combine
import UIKit
import UniformTypeIdentifiers

// MARK: - Sidebar Tab Enum
/// Represents the available sidebar tabs with named cases for clarity
enum SidebarTab: Int, CaseIterable {
    case files = 0
    case search = 1
    case sourceControl = 2
    case runAndDebug = 3
    case remoteExplorer = 4
    case extensions = 5
    case testing = 6
    
    /// Accessibility label for VoiceOver
    var accessibilityLabel: String {
        switch self {
        case .files: return "File Explorer"
        case .search: return "Search in Files"
        case .sourceControl: return "Source Control - Git"
        case .runAndDebug: return "Run and Debug"
        case .remoteExplorer: return "Remote Explorer - SSH"
        case .extensions: return "Extensions"
        case .testing: return "Test Explorer"
        }
    }
    
    /// SF Symbol icon name for the tab
    var icon: String {
        switch self {
        case .files: return "folder"
        case .search: return "magnifyingglass"
        case .sourceControl: return "arrow.triangle.branch"
        case .runAndDebug: return "play.fill"
        case .remoteExplorer: return "network"
        case .extensions: return "puzzlepiece"
        case .testing: return "testtube.2"
        }
    }
    
    /// Human-readable title for the tab
    var title: String {
        switch self {
        case .files: return "Explorer"
        case .search: return "Search"
        case .sourceControl: return "Source Control"
        case .runAndDebug: return "Run & Debug"
        case .remoteExplorer: return "Remote"
        case .extensions: return "Extensions"
        case .testing: return "Testing"
        }
    }
}

// MARK: - Helper Functions
// Moved to Extensions/FileHelpers.swift

// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var editorCore: EditorCore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var fileNavigator = FileSystemNavigator()
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var showingDocumentPicker = false
    @State private var showingFolderPicker = false
    @State private var showSettings = false
    @State private var showTerminal = false
    @State private var showCloneSheet = false
    @State private var terminalHeight: CGFloat = 200
    @State private var aiPanelWidth: CGFloat = 400
    // sidebar tab now synced via editorCore.focusedSidebarTab (not local @State)
    @State private var pendingTrustURL: URL?
    @FocusState private var isTerminalFocused: Bool
    @State private var isLoadingFile = false

    
    @StateObject private var trustManager = WorkspaceTrustManager.shared
    
    private var theme: Theme { themeManager.currentTheme }
    
    var body: some View {
        contentWithSheets
            .modifier(NavigationHandlers(editorCore: editorCore, showTerminal: $showTerminal, showSettings: $showSettings))
            .modifier(EditorActionHandlers(editorCore: editorCore))
            .modifier(CursorAndZoomHandlers(editorCore: editorCore))
            .modifier(UndoRedoSelectAllHandlers())
            .environmentObject(themeManager)
            .environmentObject(editorCore)
            .onChange(of: horizontalSizeClass) { _, newValue in
                if newValue == .compact {
                    withAnimation { editorCore.showSidebar = false }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .cloneRepository)) { _ in
                showCloneSheet = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .newTerminal)) { _ in
                showTerminal = true
            }
            .onAppear {
                if horizontalSizeClass == .compact {
                    editorCore.showSidebar = false
                }
            }
    }

    // MARK: - Timeline Notification Handlers

    private struct TimelineHandlers: ViewModifier {
        @ObservedObject var editorCore: EditorCore

        func body(content: Content) -> some View {
            content
                // 1. Show diff for a git commit (userInfo: ["commitSHA": String])
                .onReceive(NotificationCenter.default.publisher(for: .showCommitDiff)) { notification in
                    guard let sha = notification.userInfo?["commitSHA"] as? String else { return }
                    let shortSHA = String(sha.prefix(7))
                    editorCore.focusedSidebarTab = 2
                    withAnimation { editorCore.showSidebar = true }
                    Task {
                        let ssh = SSHManager.shared
                        if ssh.isConnected,
                           let dir = GitManager.shared.workingDirectoryPath {
                            let escaped = dir.replacingOccurrences(of: "'", with: "'\\''")
                            let cmd = "cd '\(escaped)' && git show --stat \(sha)"
                            if let result = try? await ssh.executeCommand(cmd, timeout: 30),
                               result.isSuccess {
                                let summary = result.stdout
                                    .components(separatedBy: "\n")
                                    .prefix(4)
                                    .joined(separator: "\n")
                                await MainActor.run {
                                    NotificationManager.shared.info("Commit \(shortSHA)", detail: summary)
                                }
                                return
                            }
                        }
                        await MainActor.run {
                            NotificationManager.shared.info(
                                "Show diff for commit \(shortSHA)",
                                detail: "Connect SSH for full diff view"
                            )
                        }
                    }
                }
                // 2. Restore a local save version (userInfo: ["entryId": String])
                .onReceive(NotificationCenter.default.publisher(for: .restoreLocalVersion)) { notification in
                    guard let entryId = notification.userInfo?["entryId"] as? String else { return }
                    // LocalSaveEntry tracks save events but does not snapshot file content.
                    // Without a stored snapshot a content restore is not possible.
                    NotificationManager.shared.warning(
                        "Restore not available",
                        detail: "Local save \(String(entryId.prefix(8))): content snapshots are not stored in this version."
                    )
                }
                // 3. Checkout a git commit (userInfo: ["commitSHA": String])
                .onReceive(NotificationCenter.default.publisher(for: .checkoutCommit)) { notification in
                    guard let sha = notification.userInfo?["commitSHA"] as? String else { return }
                    let shortSHA = String(sha.prefix(7))
                    Task {
                        let ssh = SSHManager.shared
                        if ssh.isConnected,
                           let dir = GitManager.shared.workingDirectoryPath {
                            let escaped = dir.replacingOccurrences(of: "'", with: "'\\''")
                            let cmd = "cd '\(escaped)' && git checkout \(sha)"
                            do {
                                let result = try await ssh.executeCommand(cmd, timeout: 60)
                                await MainActor.run {
                                    if result.isSuccess {
                                        NotificationManager.shared.info("Checked out commit \(shortSHA)")
                                        Task { await GitManager.shared.refresh() }
                                    } else {
                                        NotificationManager.shared.error(
                                            "Checkout failed",
                                            detail: result.stderr.isEmpty
                                                ? "Exit code \(result.exitCode)"
                                                : result.stderr
                                        )
                                    }
                                }
                            } catch {
                                await MainActor.run {
                                    NotificationManager.shared.error(
                                        "Checkout error",
                                        detail: error.localizedDescription
                                    )
                                }
                            }
                        } else {
                            await MainActor.run {
                                NotificationManager.shared.warning(
                                    "Checkout commit \(shortSHA)",
                                    detail: "Connect SSH to checkout commits on the remote working tree"
                                )
                            }
                        }
                    }
                }
                // 4. Compare a local save with current (userInfo: ["entryId": String])
                .onReceive(NotificationCenter.default.publisher(for: .compareLocalVersion)) { notification in
                    guard let entryId = notification.userInfo?["entryId"] as? String else { return }
                    // LocalSaveEntry does not store a content snapshot, so a real diff is not
                    // possible. Navigate to Source Control for manual comparison.
                    editorCore.focusedSidebarTab = 2
                    withAnimation { editorCore.showSidebar = true }
                    NotificationManager.shared.info(
                        "Compare with current",
                        detail: "Local save \(String(entryId.prefix(8))): use Source Control to view working-copy changes"
                    )
                }
        }
    }

    // MARK: - Notification Handler Modifiers (split to help type-checker)

    // MARK: - Batched Notification Handlers
    // Optimized: Combined 22 separate .onReceive into 4 handlers using Publishers.MergeMany
    // This reduces cascading re-renders when multiple notifications fire in the same run loop.

    private struct NavigationHandlers: ViewModifier {
        @ObservedObject var editorCore: EditorCore
        @Binding var showTerminal: Bool
        @Binding var showSettings: Bool

        func body(content: Content) -> some View {
            content
                // Boolean toggle notifications - combined into single stream
                .onReceive(
                    Publishers.MergeMany([
                        NotificationCenter.default.publisher(for: .showCommandPalette).map { ($0, "showCommandPalette") },
                        NotificationCenter.default.publisher(for: .toggleTerminal).map { ($0, "toggleTerminal") },
                        NotificationCenter.default.publisher(for: .toggleSidebar).map { ($0, "toggleSidebar") },
                        NotificationCenter.default.publisher(for: .showQuickOpen).map { ($0, "showQuickOpen") },
                        NotificationCenter.default.publisher(for: .showGoToSymbol).map { ($0, "showGoToSymbol") },
                        NotificationCenter.default.publisher(for: .showGoToLine).map { ($0, "showGoToLine") },
                        NotificationCenter.default.publisher(for: .showAIAssistant).map { ($0, "showAIAssistant") },
                        NotificationCenter.default.publisher(for: .showSettings).map { ($0, "showSettings") }
                    ])
                ) { _, action in
                    switch action {
                    case "showCommandPalette": editorCore.showCommandPalette = true
                    case "toggleTerminal": showTerminal.toggle()
                    case "toggleSidebar": HapticManager.impact(.light); editorCore.toggleSidebar()
                    case "showQuickOpen": editorCore.showQuickOpen = true
                    case "showGoToSymbol": editorCore.showGoToSymbol = true
                    case "showGoToLine": editorCore.showGoToLine = true
                    case "showAIAssistant": editorCore.showAIAssistant = true
                    case "showSettings": showSettings = true
                    default: break
                    }
                }
        }
    }

    private struct EditorActionHandlers: ViewModifier {
        @ObservedObject var editorCore: EditorCore

        func body(content: Content) -> some View {
            content
                // Editor action notifications - combined into single stream
                .onReceive(
                    Publishers.MergeMany([
                        NotificationCenter.default.publisher(for: .newFile).map { ($0, "newFile") },
                        NotificationCenter.default.publisher(for: .saveFile).map { ($0, "saveFile") },
                        NotificationCenter.default.publisher(for: .closeTab).map { ($0, "closeTab") },
                        NotificationCenter.default.publisher(for: .showFind).map { ($0, "showFind") },
                        NotificationCenter.default.publisher(for: .showReplace).map { ($0, "showReplace") },
                        NotificationCenter.default.publisher(for: .saveAllFiles).map { ($0, "saveAllFiles") },
                        NotificationCenter.default.publisher(for: .goToDefinition).map { ($0, "goToDefinition") },
                        NotificationCenter.default.publisher(for: .showGlobalSearch).map { ($0, "showGlobalSearch") }
                    ])
                ) { _, action in
                    switch action {
                    case "newFile": editorCore.newUntitledFile()
                    case "saveFile": HapticManager.impact(.light); editorCore.saveActiveTab()
                    case "closeTab": if let id = editorCore.activeTabId { editorCore.closeTab(id: id) }
                    case "showFind": editorCore.showSearch = true
                    case "showReplace": editorCore.showSearch = true; editorCore.showReplace = true
                    case "saveAllFiles": HapticManager.impact(.light); editorCore.saveAllTabs()
                    case "goToDefinition": editorCore.goToDefinitionAtCursor()
                    case "showGlobalSearch":
                        editorCore.focusedSidebarTab = 1
                        withAnimation { editorCore.showSidebar = true }
                    default: break
                    }
                }
        }
    }

    private struct CursorAndZoomHandlers: ViewModifier {
        @ObservedObject var editorCore: EditorCore

        func body(content: Content) -> some View {
            content
                // Cursor and zoom notifications - combined into single stream
                .onReceive(
                    Publishers.MergeMany([
                        NotificationCenter.default.publisher(for: .zoomIn).map { ($0, "zoomIn") },
                        NotificationCenter.default.publisher(for: .zoomOut).map { ($0, "zoomOut") },
                        NotificationCenter.default.publisher(for: .goBack).map { ($0, "goBack") },
                        NotificationCenter.default.publisher(for: .goForward).map { ($0, "goForward") },
                        NotificationCenter.default.publisher(for: .addCursorAbove).map { ($0, "addCursorAbove") },
                        NotificationCenter.default.publisher(for: .addCursorBelow).map { ($0, "addCursorBelow") }
                    ])
                ) { _, action in
                    switch action {
                    case "zoomIn": editorCore.zoomIn()
                    case "zoomOut": editorCore.zoomOut()
                    case "goBack": editorCore.navigateBack()
                    case "goForward": editorCore.navigateForward()
                    case "addCursorAbove": editorCore.addCursorAbove()
                    case "addCursorBelow": editorCore.addCursorBelow()
                    default: break
                    }
                }
        }
    }

    // EditingHandlers removed - merged into EditorActionHandlers above


    @ViewBuilder
    private var contentWithSheets: some View {
        contentWithHandlers
            .sheet(isPresented: $showingDocumentPicker) { IDEDocumentPicker(editorCore: editorCore) }
            .sheet(isPresented: $showingFolderPicker) {
                IDEFolderPicker(fileNavigator: fileNavigator) { url in
                    if trustManager.isTrusted(url: url) {
                        finishOpeningWorkspace(url)
                    } else {
                        pendingTrustURL = url
                    }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView(themeManager: themeManager) }
            .sheet(isPresented: $editorCore.showSaveAsDialog) {
                IDESaveAsPicker(
                    editorCore: editorCore,
                    content: editorCore.saveAsContent,
                    suggestedName: editorCore.activeTab?.fileName ?? "Untitled.txt"
                )
            }
            .sheet(isPresented: $showCloneSheet) {
                CloneRepositoryView()
                    .environmentObject(themeManager)
                    .environmentObject(editorCore)
            }
    }

    @ViewBuilder
    private var contentWithHandlers: some View {
        mainContentView
            .modifier(WorkspaceStateHandlers(editorCore: editorCore, fileNavigator: fileNavigator, showingDocumentPicker: $showingDocumentPicker, finishOpeningWorkspace: finishOpeningWorkspace))
            .modifier(ExecutionHandlers(editorCore: editorCore, showTerminal: $showTerminal))
    }

    private struct WorkspaceStateHandlers: ViewModifier {
        @ObservedObject var editorCore: EditorCore
        @ObservedObject var fileNavigator: FileSystemNavigator
        @Binding var showingDocumentPicker: Bool
        let finishOpeningWorkspace: (URL) -> Void

        func body(content: Content) -> some View {
            content
                .onChange(of: editorCore.showFilePicker) { _, show in showingDocumentPicker = show }
                .onChange(of: editorCore.activeTab?.fileName) { _, _ in updateTitle() }
                .onChange(of: editorCore.tabs.count) { _, _ in updateTitle() }
                .onChange(of: editorCore.activeTabId) { _, _ in updateTitle() }
                .onChange(of: editorCore.activeTab?.isUnsaved) { _, _ in updateTitle() }
                .onAppear {
                    editorCore.fileNavigator = fileNavigator
                    updateTitle()
                    if editorCore.restoredWorkspace, let url = editorCore.restoreWorkspaceURL() {
                        let accessing = url.startAccessingSecurityScopedResource()
                        if FileManager.default.fileExists(atPath: url.path) {
                            finishOpeningWorkspace(url)
                            editorCore.restoreOpenTabs(workspaceURL: url)
                        } else {
                            editorCore.clearWorkspaceState()
                            let exampleTabs = EditorCore.createExampleTabs()
                            editorCore.tabs.append(contentsOf: exampleTabs)
                            editorCore.activeTabId = exampleTabs.first?.id
                        }
                        if accessing { url.stopAccessingSecurityScopedResource() }
                    }
                }
                .onChange(of: editorCore.tabs.map { $0.id }) { _, _ in
                    editorCore.saveOpenTabPaths()
                }
        }

        private func updateTitle() {
            if let activeTab = editorCore.activeTab {
                let fileName = activeTab.fileName
                let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
                let title = "\(unsavedIndicator)\(fileName) - CodePad"
                NotificationCenter.default.post(name: .windowTitleDidChange, object: nil, userInfo: ["title": title])
            } else if !editorCore.tabs.isEmpty {
                NotificationCenter.default.post(name: .windowTitleDidChange, object: nil, userInfo: ["title": "CodePad"])
            } else {
                NotificationCenter.default.post(name: .windowTitleDidChange, object: nil, userInfo: ["title": "Welcome - CodePad"])
            }
        }
    }

    private struct ExecutionHandlers: ViewModifier {
        @ObservedObject var editorCore: EditorCore
        @Binding var showTerminal: Bool

        func body(content: Content) -> some View {
            content
                .onReceive(NotificationCenter.default.publisher(for: .runWithoutDebugging)) { _ in
                    if let activeTab = editorCore.activeTab {
                        CodeExecutionService.shared.executeCurrentFile(fileName: activeTab.fileName, content: activeTab.content)
                        showTerminal = true
                        NotificationCenter.default.post(name: .switchToOutputPanel, object: nil)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .runSampleWASM)) { _ in
                    if let activeTab = editorCore.activeTab {
                        CodeExecutionService.shared.executeCurrentFile(fileName: activeTab.fileName, content: activeTab.content)
                        showTerminal = true
                        NotificationCenter.default.post(name: .switchToOutputPanel, object: nil)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .runJavaScript)) { _ in
                    if let activeTab = editorCore.activeTab {
                        Task {
                            let runner = JSRunner()
                            runner.setConsoleHandler { message in
                                Task { @MainActor in
                                    NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "\(message)\n"])
                                }
                            }
                            do {
                                let result = try await runner.execute(code: activeTab.content)
                                await MainActor.run {
                                    NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "⮐ Result: \(result)\n✓ Completed\n"])
                                }
                            } catch {
                                await MainActor.run {
                                    NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "❌ Error: \(error.localizedDescription)\n"])
                                }
                            }
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .startDebugging)) { _ in
                    if let activeTab = editorCore.activeTab {
                        let ext = (activeTab.fileName as NSString).pathExtension.lowercased()
                        if ext == "js" || ext == "mjs" {
                            let fileId = activeTab.url?.path ?? activeTab.fileName
                            DebugManager.shared.startDebugging(code: activeTab.content, fileName: activeTab.fileName, fileId: fileId)
                            showTerminal = true
                            NotificationCenter.default.post(name: .switchToDebugConsole, object: nil)
                        } else {
                            DebugManager.shared.consoleEntries.append(DebugManager.ConsoleEntry(message: "Debug not supported for .\(ext) files. Only .js is supported.", kind: .error))
                        }
                    }
                }
        }
    }
    
    // MARK: - Undo / Redo / Select All Handlers
    
    private struct UndoRedoSelectAllHandlers: ViewModifier {
        func body(content: Content) -> some View {
            content
                .onReceive(NotificationCenter.default.publisher(for: .performUndo)) { _ in
                    UIApplication.shared.sendAction(#selector(UndoManager.undo), to: nil, from: nil, for: nil)
                }
                .onReceive(NotificationCenter.default.publisher(for: .performRedo)) { _ in
                    UIApplication.shared.sendAction(#selector(UndoManager.redo), to: nil, from: nil, for: nil)
                }
                .onReceive(NotificationCenter.default.publisher(for: .selectAll)) { _ in
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
        }
    }
    
    // MARK: - Extracted View Components
    

    @StateObject private var tunnelManager = TunnelManager.shared
    
    @ViewBuilder
    private var mainContentView: some View {
        // Connected Mode takes over the entire screen when active
        if tunnelManager.isConnected {
            VSCodeTunnelView()
                .environmentObject(themeManager)
        } else {
            ZStack {
                mainLayout
                overlayViews
                
                // Toast notifications (bottom-right)
                NotificationToastOverlay(manager: NotificationManager.shared)
            }
            .background(theme.editorBackground)
        }
    }
    
    @ViewBuilder
    private var mainLayout: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if horizontalSizeClass == .compact {
                    // Hamburger menu button replaces full activity bar in compact (Split View / Slide Over)
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            editorCore.showSidebar.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.secondary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Toggle Sidebar")
                } else {
                    IDEActivityBar(editorCore: editorCore, selectedTab: $editorCore.focusedSidebarTab, showSettings: $showSettings)
                }
                
                if editorCore.showSidebar {
                    sidebarContent
                        .frame(width: editorCore.sidebarWidth)
                        .transition(.move(edge: .leading))
                }
                
                VStack(spacing: 0) {
                    TabBarView(tabs: $editorCore.tabs, activeTabId: $editorCore.activeTabId, editorCore: editorCore, themeManager: ThemeManager.shared)
                    
                    if let tab = editorCore.activeTab {
                        IDEEditorView(editorCore: editorCore, tab: tab, theme: theme, isTerminalFocused: Binding(get: { isTerminalFocused }, set: { isTerminalFocused = $0 }))
                            .allowsHitTesting(!isTerminalFocused)
                    } else {
                        IDEWelcomeView(editorCore: editorCore, showFolderPicker: $showingFolderPicker, theme: theme)
                    }
                    
                    StatusBarView(editorCore: editorCore)
                }
                .onDrop(of: [.fileURL, .url, .text, .data], isTargeted: nil) { providers in
                    for provider in providers {
                        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, _ in
                                guard let data = data as? Data,
                                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                                DispatchQueue.main.async {
                                    isLoadingFile = true
                                    editorCore.openFile(from: url)
                                    isLoadingFile = false
                                }
                            }
                        }
                    }
                    return true
                }
                .overlay {
                    if isLoadingFile {
                        ZStack {
                            Color.black.opacity(0.25)
                            VStack(spacing: 8) {
                                ProgressView()
                                Text("Opening file...")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            
            if showTerminal {
                PanelView(isVisible: $showTerminal, height: $terminalHeight, terminalFocused: $isTerminalFocused)
            }
        }
        .onChange(of: isTerminalFocused) { _, newValue in
            if newValue {
                // Terminal gained focus — resign any UIKit first responder (editor).
                // Use async to let SwiftUI's own focus transition complete first,
                // then resign lingering UIKit responders. The terminal's SwiftUI
                // TextField will reclaim first responder on the next key event.
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var overlayViews: some View {
        // Command Palette (Cmd+Shift+P)
        if editorCore.showCommandPalette {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showCommandPalette = false }
            CommandPaletteView(editorCore: editorCore, showSettings: $showSettings, showTerminal: $showTerminal)
        }
        
        // Quick Open (Cmd+P)
        if editorCore.showQuickOpen {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showQuickOpen = false }
            QuickOpenView(editorCore: editorCore, fileNavigator: fileNavigator)
        }
        
        // Go To Symbol (Cmd+Shift+O)
        if editorCore.showGoToSymbol {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToSymbol = false }
            GoToSymbolView(editorCore: editorCore, onGoToLine: { line in
                editorCore.requestedGoToLine = line
            })
        }
        
        // AI Assistant
        if editorCore.showAIAssistant {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    // Drag handle on left edge
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 6)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 1)
                                .onChanged { value in
                                    let newWidth = geo.size.width + value.translation.width
                                    aiPanelWidth = min(max(newWidth, 300), 600)
                                }
                        )
                    AIAssistantView(editorCore: editorCore, fileNavigator: fileNavigator)
                        .frame(width: aiPanelWidth)
                }
            }
            .ignoresSafeArea()
        }
        
        // Go To Line (Ctrl+G)
        if editorCore.showGoToLine {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToLine = false }
            GoToLineView(isPresented: $editorCore.showGoToLine, onGoToLine: { line in
                editorCore.requestedGoToLine = line
            })
        }
        
        // Workspace Trust Dialog
        if let trustURL = pendingTrustURL {
            Color.black.opacity(0.4).ignoresSafeArea()
            WorkspaceTrustDialog(workspaceURL: trustURL, onTrust: {
                trustManager.trust(url: trustURL)
                finishOpeningWorkspace(trustURL)
                pendingTrustURL = nil
            }, onCancel: {
                pendingTrustURL = nil
            })
        }
        
        // Keyboard Shortcuts sheet
        EmptyView()
            .sheet(isPresented: $editorCore.showKeyboardShortcuts) {
                KeyboardShortcutsView()
            }
    }
    
    private func finishOpeningWorkspace(_ url: URL) {
        fileNavigator.loadFileTree(at: url)
        Task { @MainActor in
            LaunchManager.shared.setWorkspaceRoot(url)
            GitManager.shared.setWorkingDirectory(url)
        }
        // Persist workspace for restore after crash
        editorCore.saveWorkspaceBookmark(url)
    }
    

    
    @ViewBuilder
    private var sidebarContent: some View {
        // Convert Int to enum, defaulting to .files for invalid values
        let sidebarTab = SidebarTab(rawValue: editorCore.focusedSidebarTab) ?? .files
        
        Group {
            switch sidebarTab {
            case .files:
                IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
            case .search:
                if let rootURL = fileNavigator.rootURL {
                    SearchView(
                        onResultSelected: { filePath, lineNumber in
                            // Open file and go to line
                            let url = URL(fileURLWithPath: filePath)
                            editorCore.openFile(from: url)
                            editorCore.requestedGoToLine = lineNumber
                        },
                        rootURL: rootURL,
                        initialQuery: editorCore.findReferencesQuery
                    )
                } else {
                    // No workspace open - show placeholder
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 40))
                            .foregroundColor(theme.sidebarForeground.opacity(0.3))
                        Text("Open a folder to search")
                            .font(.caption)
                            .foregroundColor(theme.sidebarForeground.opacity(0.6))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(theme.sidebarBackground)
                }
            case .sourceControl:
                VStack(spacing: 0) {
                    GitView()
                    Divider()
                    Button(action: { showCloneSheet = true }) {
                        HStack {
                            Image(systemName: "arrow.down.circle")
                            Text("Clone Repository...")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            case .runAndDebug:
                DebugView()
            case .remoteExplorer:
                RemoteExplorerView(editorCore: editorCore)
            case .extensions:
                ExtensionsPanel()
            case .testing:
                TestView()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(sidebarTab.accessibilityLabel)
    }

}

// MARK: - Activity Bar



struct BarButton: View {
    let icon: String
    let isSelected: Bool
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
                .frame(width: 48, height: 48)
        }
    }
}

// MARK: - Sidebar with Real File System

struct IDESidebarFiles: View {
    @ObservedObject var editorCore: EditorCore
    @ObservedObject var fileNavigator: FileSystemNavigator
    @Binding var showFolderPicker: Bool
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
                Spacer()
                Button(action: { showFolderPicker = true }) {
                    Image(systemName: "folder.badge.plus").font(.caption)
                }
                .foregroundColor(theme.sidebarForeground.opacity(0.7))
                .accessibilityLabel("Open folder")
                .accessibilityHint("Double tap to open a folder in the explorer")
                Button(action: { editorCore.showFilePicker = true }) {
                    Image(systemName: "doc.badge.plus").font(.caption)
                }
                .foregroundColor(theme.sidebarForeground.opacity(0.7))
                .accessibilityLabel("Open file")
                .accessibilityHint("Double tap to open a file")
                if fileNavigator.fileTree != nil {
                    Button(action: { fileNavigator.refreshFileTree() }) {
                        Image(systemName: "arrow.clockwise").font(.caption)
                    }
                    .foregroundColor(theme.sidebarForeground.opacity(0.7))
                    .accessibilityLabel("Refresh file tree")
                    .accessibilityHint("Double tap to refresh the file explorer")
                }
            }.padding(.horizontal, 12).padding(.vertical, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    if let tree = fileNavigator.fileTree {
                        FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
                    } else {
                        DemoFileTree(editorCore: editorCore, theme: theme)
                    }
                }.padding(.horizontal, 8)
            }
        }.background(theme.sidebarBackground)
    }
}

struct DemoFileTree: View {
    @ObservedObject var editorCore: EditorCore
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Open a folder to browse files")
                .font(.caption)
                .foregroundColor(theme.sidebarForeground.opacity(0.6))
                .padding(.vertical, 8)
            
            DemoFileRow(name: "Welcome.swift", editorCore: editorCore, theme: theme)
            DemoFileRow(name: "example.js", editorCore: editorCore, theme: theme)
            DemoFileRow(name: "example.py", editorCore: editorCore, theme: theme)
            DemoFileRow(name: "package.json", editorCore: editorCore, theme: theme)
            DemoFileRow(name: "index.html", editorCore: editorCore, theme: theme)
            DemoFileRow(name: "styles.css", editorCore: editorCore, theme: theme)
        }
    }
}

struct DemoFileRow: View {
    let name: String
    @ObservedObject var editorCore: EditorCore
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 4) {
            Spacer().frame(width: 12)
            Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
            Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if let tab = editorCore.tabs.first(where: { $0.fileName == name }) {
                editorCore.selectTab(id: tab.id)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name), \((name as NSString).pathExtension.isEmpty ? "file" : (name as NSString).pathExtension.uppercased() + " file")")
        .accessibilityHint("Double tap to open")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Editor with Syntax Highlighting + Autocomplete + Folding

struct IDEEditorView: View {
    @ObservedObject var editorCore: EditorCore
    let tab: Tab
    let theme: Theme
    var isTerminalFocused: Binding<Bool>? = nil
    
    /// Feature flag for Runestone editor - uses centralized FeatureFlags
    private var useRunestoneEditor: Bool { FeatureFlags.useRunestoneEditor }

    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
    @State private var text: String = ""
    @State private var scrollPosition: Int = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var totalLines: Int = 1
    @State private var visibleLines: Int = 20
    @State private var currentLineNumber: Int = 1
    @State private var currentColumn: Int = 1
    @State private var cursorIndex: Int = 0
    @State private var lineHeight: CGFloat = 20  // Updated dynamically based on font size
    @State private var requestedCursorIndex: Int? = nil
    @State private var requestedLineSelection: Int? = nil
    @State private var gitGutterRefreshToken: Int = 0

    @StateObject private var autocomplete = AutocompleteManager()
    @State private var showAutocomplete = false
    @StateObject private var foldingManager = CodeFoldingManager.shared
    @StateObject private var findViewModel = FindViewModel()
    @StateObject private var inlineSuggestionManager = InlineSuggestionManager()
    @State private var inlineSuggestionWorkItem: DispatchWorkItem?
    
    // MARK: - Shared Autocomplete Handlers
    private func handleAcceptAutocomplete() -> Bool {
        guard showAutocomplete else { return false }
        var tempText = text
        var tempCursor = cursorIndex
        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
        if tempText != text {
            text = tempText
            cursorIndex = tempCursor
            requestedCursorIndex = tempCursor
            showAutocomplete = false
            return true
        }
        return false
    }
    
    private func handleDismissAutocomplete() -> Bool {
        guard showAutocomplete else { return false }
        autocomplete.hideSuggestions()
        showAutocomplete = false
        return true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Find/Replace bar
            if editorCore.showSearch {
                FindReplaceView(viewModel: findViewModel, onDismiss: {
                    editorCore.showSearch = false
                    editorCore.showReplace = false
                })
                .background(theme.tabBarBackground)
            }
            
            BreadcrumbsView(editorCore: editorCore, tab: tab)
            
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    // Line numbers gutter with code folding indicators
                    if lineNumbersStyle != "off" {
                        LineNumbers(
                            totalLines: totalLines,
                            currentLine: currentLineNumber,
                            scrollOffset: scrollOffset,
                            lineHeight: lineHeight,
                            requestedLineSelection: $requestedLineSelection,
                            theme: theme,
                            foldingManager: foldingManager,
                            filePath: tab.url?.path
                        )
                        .frame(width: 58)
                        .background(theme.sidebarBackground.opacity(0.5))
                        .accessibilityHidden(true)
                    }
                    
                    // Editor content
                        // Use Runestone for O(log n) performance, or legacy view as fallback
                        Group {
                            if useRunestoneEditor {
                                RunestoneEditorView(
                                    text: $text,
                                    filename: tab.fileName,
                                    scrollOffset: $scrollOffset,
                                    totalLines: $totalLines,
                                    currentLineNumber: $currentLineNumber,
                                    currentColumn: $currentColumn,
                                    cursorIndex: $cursorIndex,
                                    lineHeight: $lineHeight,
                                    isActive: isTerminalFocused?.wrappedValue != true,
                                    fontSize: editorCore.editorFontSize,
                                    onAcceptAutocomplete: { self.handleAcceptAutocomplete() },
                                    onDismissAutocomplete: { self.handleDismissAutocomplete() },
                                    onAcceptInlineSuggestion: {
                                        guard let suggestion = inlineSuggestionManager.currentSuggestion else { return false }
                                        text.insert(contentsOf: suggestion, at: text.index(text.startIndex, offsetBy: min(cursorIndex, text.count)))
                                        cursorIndex += suggestion.count
                                        requestedCursorIndex = cursorIndex
                                        inlineSuggestionManager.clearSuggestion()
                                        return true
                                    }
                                )
                            } else {
                                // Legacy SyntaxHighlightingTextView (fallback)
                                SyntaxHighlightingTextView(
                                    text: $text,
                                    filename: tab.fileName,
                                    scrollPosition: $scrollPosition,
                                    scrollOffset: $scrollOffset,
                                    totalLines: $totalLines,
                                    visibleLines: $visibleLines,
                                    currentLineNumber: $currentLineNumber,
                                    currentColumn: $currentColumn,
                                    cursorIndex: $cursorIndex,
                                    lineHeight: $lineHeight,
                                    isActive: isTerminalFocused?.wrappedValue != true,
                                    fontSize: editorCore.editorFontSize,
                                    requestedLineSelection: $requestedLineSelection,
                                    requestedCursorIndex: $requestedCursorIndex,
                                    onAcceptAutocomplete: { self.handleAcceptAutocomplete() },
                                    onDismissAutocomplete: { self.handleDismissAutocomplete() }
                                )
                            }
                        }
                        .onChange(of: text) { _, newValue in
                            editorCore.updateActiveTabContent(newValue)
                            // Use debounced cursor update to reduce view refreshes
                            editorCore.updateCursorPosition(CursorPosition(line: currentLineNumber, column: currentColumn))
                            autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
                            showAutocomplete = autocomplete.showSuggestions
                            foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path)
                            gitGutterRefreshToken &+= 1
                            
                            // Debounced inline suggestion
                            inlineSuggestionWorkItem?.cancel()
                            inlineSuggestionManager.clearSuggestion()
                            if newValue.count > 10 && !showAutocomplete {
                                let work = DispatchWorkItem { [weak inlineSuggestionManager] in
                                    let lines = newValue.prefix(cursorIndex).split(separator: "\n", omittingEmptySubsequences: false)
                                    let line = lines.count
                                    let col = (lines.last?.count ?? 0) + 1
                                    inlineSuggestionManager?.requestSuggestion(for: newValue, at: .init(line: line, column: col), fileName: tab.url?.lastPathComponent)
                                }
                                inlineSuggestionWorkItem = work
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
                            }
                        }
                        .onChange(of: cursorIndex) { _, newCursor in
                            autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
                            showAutocomplete = autocomplete.showSuggestions
                        }
                    
                    if !tab.fileName.hasSuffix(".json") {
                        MinimapView(
                            content: text,
                            scrollOffset: scrollOffset,
                            scrollViewHeight: geometry.size.height,
                            totalContentHeight: CGFloat(totalLines) * lineHeight,
                            onScrollRequested: { newOffset in
                                // Minimap requested scroll - update editor position
                                scrollOffset = newOffset
                                // Convert back from pixels to line number
                                let newLine = Int(newOffset / max(lineHeight, 1))
                                scrollPosition = max(0, min(newLine, totalLines - 1))
                            }
                        )
                        .frame(width: 60)
                    }
                }
                .background(theme.editorBackground)

                // Sticky Header Overlay (FEAT-040)
                StickyHeaderView(
                    text: text,
                    currentLine: scrollPosition,
                    theme: theme,
                    lineHeight: lineHeight,
                    onSelect: { line in
                        requestedLineSelection = line
                    }
                )
                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)

                // Inlay Hints Overlay (type hints, parameter names)
                InlayHintsOverlay(
                    code: text,
                    language: tab.language,
                    scrollPosition: scrollPosition,
                    lineHeight: lineHeight,
                    fontSize: editorCore.editorFontSize,
                    gutterWidth: (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0,
                    rightReservedWidth: tab.fileName.hasSuffix(".json") ? 0 : 80
                )
                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)

                // FEAT-071 Git gutter indicators (added/modified/deleted)
                // Positioned as a narrow (6 pt) strip at the right edge of the line-number
                // gutter so it aligns with VSCode-style change bars.
                if let fileURL = tab.url, lineNumbersStyle != "off" {
                    let visibleCount = max(1, Int(geometry.size.height / max(lineHeight, 1)) + 2)
                    let firstVisible = max(1, Int(scrollOffset / max(lineHeight, 1)) + 1)
                    let lastVisible = min(totalLines + 1, firstVisible + visibleCount)
                    GitGutterView(
                        fileURL: fileURL,
                        visibleLineRange: firstVisible..<lastVisible,
                        lineHeight: lineHeight,
                        contentTopInset: 8,
                        selectedLine: currentLineNumber,
                        refreshToken: AnyHashable(gitGutterRefreshToken)
                    )
                    .frame(width: 6)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.leading, 52)
                    .allowsHitTesting(false)
                    .clipped()
                }
                // Inline suggestion ghost text
                if inlineSuggestionManager.currentSuggestion != nil && !showAutocomplete {
                    InlineSuggestionView(
                        code: text,
                        language: CodeLanguage(from: tab.url?.pathExtension ?? "swift"),
                        scrollPosition: max(0, Int(scrollOffset / lineHeight)),
                        lineHeight: lineHeight,
                        fontSize: editorCore.editorFontSize
                    )
                    .environmentObject(inlineSuggestionManager)
                    .allowsHitTesting(false)
                }
                if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
                    AutocompletePopup(
                        suggestions: autocomplete.suggestionItems,
                        selectedIndex: autocomplete.selectedIndex,
                        theme: theme
                    ) { index in
                        autocomplete.selectedIndex = index
                        var tempText = text
                        var tempCursor = cursorIndex
                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
                        if tempText != text {
                            text = tempText
                            cursorIndex = tempCursor
                            requestedCursorIndex = tempCursor
                        }
                        showAutocomplete = false
                    }
                    .offset(x: {
                        let gutterWidth = lineNumbersStyle != "off" ? CGFloat(max(String(totalLines).count, 2)) * 9.0 + 35.0 : 8.0
                        return gutterWidth
                    }(), y: CGFloat(currentLineNumber) * lineHeight - scrollOffset)
                }
            }
        }
        }
        .onAppear {
            text = tab.content
            foldingManager.detectFoldableRegions(in: tab.content, filePath: tab.url?.path)
            findViewModel.editorCore = editorCore
            // Set initial lineHeight based on font size
            lineHeight = ceil(editorCore.editorFontSize * 1.4)
        }
        .onChange(of: tab.id) { oldTabId, _ in
            // ── Tab switch: save outgoing state, load incoming state ──────────
            // 1. Save scroll offset + cursor of the tab we're leaving
            if let outgoingIndex = editorCore.tabs.firstIndex(where: { $0.id == oldTabId }) {
                editorCore.tabs[outgoingIndex].savedScrollOffset = scrollOffset
                editorCore.tabs[outgoingIndex].savedCursorIndex  = cursorIndex
            }

            // 2. Load new tab content
            text = tab.content
            foldingManager.detectFoldableRegions(in: tab.content, filePath: tab.url?.path)

            // 3. Restore saved scroll + cursor for the incoming tab (async so
            //    the editor has a chance to finish loading the new text first)
            let restoredScroll  = tab.savedScrollOffset
            let restoredCursor  = tab.savedCursorIndex
            DispatchQueue.main.async {
                scrollOffset = restoredScroll
                if restoredCursor > 0 {
                    requestedCursorIndex = restoredCursor
                    cursorIndex = restoredCursor
                }
            }
        }
        .onChange(of: currentLineNumber) { _, line in
            // Use debounced cursor update to reduce view refreshes
            editorCore.updateCursorPosition(CursorPosition(line: line, column: currentColumn))
        }
        .onChange(of: currentColumn) { _, col in
            // Use debounced cursor update to reduce view refreshes
            editorCore.updateCursorPosition(CursorPosition(line: currentLineNumber, column: col))
        }
        .onChange(of: editorCore.editorFontSize) { _, newSize in
            // Update lineHeight to match Runestone's line height (~1.4x font size)
            lineHeight = ceil(newSize * 1.4)
        }
        .onChange(of: editorCore.requestedGoToLine) { _, line in
            if let line = line {
                requestedLineSelection = line - 1  // Convert 1-indexed to 0-indexed
                editorCore.requestedGoToLine = nil  // Clear the request
            }
        }
        .onChange(of: editorCore.showReplace) { _, show in
            if show {
                findViewModel.isReplaceMode = true
                editorCore.showReplace = false  // consume the flag
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .hideSearch)) { _ in
            if editorCore.showSearch {
                editorCore.showSearch = false
                findViewModel.clearSearch()
            }
        }


    }
    
    // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
}

// MARK: - Line Numbers with Code Folding

struct LineNumbers: View {
    let totalLines: Int
    let currentLine: Int
    let scrollOffset: CGFloat
    let lineHeight: CGFloat
    @Binding var requestedLineSelection: Int?
    let theme: Theme
    var foldingManager: CodeFoldingManager? = nil
    var filePath: String? = nil

    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
    private static let viewportBuffer = 10

    var body: some View {
        GeometryReader { geometry in
            let viewportHeight = geometry.size.height
            let firstVisRow = max(0, Int(floor((scrollOffset - 8) / lineHeight)) - Self.viewportBuffer)
            let maxRows = Int(ceil(viewportHeight / lineHeight)) + 2 * Self.viewportBuffer
            let indices = self.computeVisibleLineIndices(firstRow: firstVisRow, maxRows: maxRows)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(indices, id: \.self) { lineIndex in
                        lineRow(for: lineIndex)
                    }
                }
                .padding(.top, 8)
                .offset(y: CGFloat(firstVisRow) * lineHeight - scrollOffset)
            }
            .scrollDisabled(true)
        }
    }

    /// Compute visible line indices — O(viewport) without folds, early-terminating with folds.
    /// Replaces the previous O(n) implementation that iterated all lines every scroll frame.
    private func computeVisibleLineIndices(firstRow: Int, maxRows: Int) -> [Int] {
        let lastRow = firstRow + maxRows

        // Fast path: no fold manager means direct 1:1 line-to-row mapping — O(viewport)
        guard let fm = foldingManager else {
            let first = max(0, firstRow)
            let last = min(totalLines - 1, lastRow)
            guard first <= last else { return [] }
            return Array(first...last)
        }

        // Fold-aware path: iterate lines counting visual rows, with early termination
        var indices: [Int] = []
        indices.reserveCapacity(maxRows + 1)
        var visualRow = 0
        var skipUntil: Int? = nil

        for i in 0..<totalLines {
            if let skip = skipUntil {
                if i <= skip { continue }
                else { skipUntil = nil }
            }

            if visualRow >= firstRow {
                indices.append(i)
            }

            // If this line starts a folded region, skip to endLine
            if let region = fm.getRegion(at: i), region.isFolded {
                skipUntil = region.endLine
            }

            visualRow += 1

            // Early termination: past the visible range
            if visualRow > lastRow { break }
        }

        return indices
    }

    @ViewBuilder
    private func lineRow(for lineIndex: Int) -> some View {
        let isFoldable = foldingManager?.isFoldable(line: lineIndex) ?? false
        let isFolded = foldingManager?.isRegionFolded(at: lineIndex) ?? false
        let foldType = foldingManager?.getRegion(at: lineIndex)?.type
        let region = foldingManager?.getRegion(at: lineIndex)

        HStack(spacing: 0) {
            // Fold indicator button
            if isFoldable {
                Button(action: {
                    foldingManager?.toggleFold(at: lineIndex)
                }) {
                    ZStack {
                        if let type = foldType {
                            Text(type.icon)
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(.blue.opacity(0.6))
                        }
                        Image(systemName: isFolded ? "chevron.right" : "chevron.down")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    .frame(width: 16, height: lineHeight)
                    .background(isFolded ? Color.secondary.opacity(0.15) : Color.clear)
                    .cornerRadius(3)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Color.clear
                    .frame(width: 16, height: lineHeight)
            }

            // Folded placeholder line showing "..." when region is collapsed
            if isFolded, let region = region {
                HStack(spacing: 4) {
                    Text(displayText(for: lineIndex))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(theme.lineNumberActive)
                    Text("⋯")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.6))
                    if let label = region.label {
                        Text(label)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary.opacity(0.5))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    Spacer()
                }
                .frame(height: lineHeight)
                .contentShape(Rectangle())
                .onTapGesture {
                    foldingManager?.toggleFold(at: lineIndex)
                }
            } else {
                Text(displayText(for: lineIndex))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
                    .frame(height: lineHeight)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        requestedLineSelection = lineIndex
                    }
            }
        }
    }

    private func displayText(for lineIndex: Int) -> String {
        switch lineNumbersStyle {
        case "relative":
            let lineNumber = lineIndex + 1
            if lineNumber == currentLine { return "\(lineNumber)" }
            return "\(abs(lineNumber - currentLine))"

        case "interval":
            let lineNumber = lineIndex + 1
            return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""

        default:
            return "\(lineIndex + 1)"
        }
    }
}

// MARK: - Autocomplete Popup

struct AutocompletePopup: View {
    let suggestions: [AutocompleteSuggestion]
    let selectedIndex: Int
    let theme: Theme
    let onSelectIndex: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions.indices, id: \.self) { index in
                let s = suggestions[index]
                HStack(spacing: 6) {
                    Image(systemName: icon(for: s.kind))
                        .font(.caption)
                        .foregroundColor(color(for: s.kind))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(s.displayText)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(theme.editorForeground)
                        if s.insertText != s.displayText && !s.insertText.isEmpty {
                            Text(s.insertText)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(theme.editorForeground.opacity(0.55))
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 8).padding(.vertical, 6)
                .background(index == selectedIndex ? theme.selection : Color.clear)
                .contentShape(Rectangle())
                .onTapGesture { onSelectIndex(index) }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(s.displayText), \(s.kind == .keyword ? "keyword" : s.kind == .symbol ? "symbol" : s.kind == .stdlib ? "standard library" : "member")")
                .accessibilityHint("Double tap to insert")
                .accessibilityAddTraits(index == selectedIndex ? [.isButton, .isSelected] : .isButton)
            }
        }
        .frame(width: 260)
        .background(theme.editorBackground)
        .cornerRadius(6)
        .shadow(radius: 8)
    }
    
    private func icon(for kind: AutocompleteSuggestionKind) -> String {
        switch kind {
        case .keyword: return "key.fill"
        case .symbol: return "cube.fill"
        case .stdlib: return "curlybraces"
        case .member: return "arrow.right.circle.fill"
        }
    }
    
    private func color(for kind: AutocompleteSuggestionKind) -> Color {
        switch kind {
        case .keyword: return .purple
        case .symbol: return .blue
        case .stdlib: return .orange
        case .member: return .green
        }
    }
}

// MARK: - Welcome View

struct IDEWelcomeView: View {
    @ObservedObject var editorCore: EditorCore
    @StateObject var recentFiles: RecentFileManager = .shared
    @Binding var showFolderPicker: Bool
    let theme: Theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)
                
                // Logo & Title
                VStack(spacing: 12) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 64, weight: .thin))
                        .foregroundColor(.accentColor.opacity(0.7))
                    Text("CodePad")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(theme.editorForeground)
                    Text("Code anywhere. Build anything.")
                        .font(.system(size: 14))
                        .foregroundColor(theme.editorForeground.opacity(0.5))
                }
                .padding(.bottom, 40)
                
                // Main content in columns — stack vertically in compact (Split View / Slide Over)
                let layout: AnyLayout = horizontalSizeClass == .compact
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 32))
                    : AnyLayout(HStackLayout(alignment: .top, spacing: 48))
                layout {
                    // Left: Start actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Start")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.editorForeground.opacity(0.5))
                            .textCase(.uppercase)
                        
                        WelcomeLink(icon: "doc.badge.plus", title: "New File", shortcut: "\u{2318}N", theme: theme) { editorCore.newUntitledFile() }
                        WelcomeLink(icon: "folder", title: "Open Folder...", shortcut: "\u{2318}\u{21E7}O", theme: theme) { showFolderPicker = true }
                        WelcomeLink(icon: "doc", title: "Open File...", shortcut: "\u{2318}O", theme: theme) { editorCore.showFilePicker = true }
                        WelcomeLink(icon: "arrow.triangle.branch", title: "Clone Repository...", shortcut: nil, theme: theme) {
                            editorCore.focusedSidebarTab = 2
                            editorCore.showSidebar = true
                        }
                        WelcomeLink(icon: "network", title: "Connect to SSH Host...", shortcut: nil, theme: theme) {
                            editorCore.focusedSidebarTab = 4
                            withAnimation { editorCore.showSidebar = true }
                        }
                    }
                    .frame(width: 260)
                    
                    // Center: Recent
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.editorForeground.opacity(0.5))
                            .textCase(.uppercase)
                        
                        if recentFiles.recentFiles.isEmpty {
                            Text("No recent files")
                                .font(.system(size: 13))
                                .foregroundColor(theme.editorForeground.opacity(0.3))
                                .padding(.vertical, 8)
                        } else {
                            ForEach(recentFiles.recentFiles.prefix(8), id: \.absoluteString) { url in
                                Button(action: {
                                    Task {
                                        let content = await Task.detached {
                                            (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                                        }.value
                                        await MainActor.run {
                                            editorCore.addTab(fileName: url.lastPathComponent, content: content, url: url)
                                            RecentFileManager.shared.addRecentFile(url)
                                        }
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: url.hasDirectoryPath ? "folder.fill" : "doc.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.accentColor)
                                            .frame(width: 16)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(url.lastPathComponent)
                                                .font(.system(size: 13))
                                                .foregroundColor(.accentColor)
                                                .lineLimit(1)
                                            Text(url.deletingLastPathComponent().path)
                                                .font(.system(size: 10))
                                                .foregroundColor(theme.editorForeground.opacity(0.4))
                                                .lineLimit(1)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(width: 280)
                    
                    // Right: Help & Tips
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Help")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.editorForeground.opacity(0.5))
                            .textCase(.uppercase)
                        
                        WelcomeLink(icon: "terminal", title: "Command Palette", shortcut: "\u{2318}\u{21E7}P", theme: theme) { editorCore.showCommandPalette = true }
                        WelcomeLink(icon: "keyboard", title: "Keyboard Shortcuts", shortcut: nil, theme: theme) { editorCore.showKeyboardShortcuts = true }
                        WelcomeLink(icon: "gear", title: "Settings", shortcut: "\u{2318},", theme: theme) {
                            NotificationCenter.default.post(name: .showSettings, object: nil)
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        Text("Tips")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.editorForeground.opacity(0.5))
                            .textCase(.uppercase)
                        
                        WelcomeTip(icon: "sparkles", text: "Use \u{2318}\u{21E7}A to open the AI assistant", theme: theme)
                        WelcomeTip(icon: "sidebar.left", text: "\u{2318}B toggles the sidebar", theme: theme)
                        WelcomeTip(icon: "magnifyingglass", text: "\u{2318}\u{21E7}F searches across all files", theme: theme)
                        WelcomeTip(icon: "arrow.triangle.branch", text: "Built-in Git with native Swift implementation", theme: theme)
                    }
                    .frame(width: 280)
                }
                .padding(.horizontal, 40)
                
                Spacer().frame(height: 60)
            }
            .frame(maxWidth: .infinity)
        }
        .background(theme.editorBackground)
    }
}

struct WelcomeLink: View {
    let icon: String
    let title: String
    let shortcut: String?
    let theme: Theme
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(.accentColor)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.accentColor)
                if let shortcut = shortcut {
                    Spacer()
                    Text(shortcut)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(theme.editorForeground.opacity(0.35))
                }
            }
            .padding(.vertical, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .opacity(isHovering ? 0.8 : 1.0)
    }
}

struct WelcomeTip: View {
    let icon: String
    let text: String
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(theme.editorForeground.opacity(0.4))
                .frame(width: 16)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(theme.editorForeground.opacity(0.5))
        }
    }
}

// MARK: - Folder Picker

struct IDEFolderPicker: UIViewControllerRepresentable {
    @ObservedObject var fileNavigator: FileSystemNavigator
    var editorCore: EditorCore? = nil
    var onPick: ((URL) -> Void)?
    
    init(fileNavigator: FileSystemNavigator, onPick: ((URL) -> Void)? = nil) {
        self.fileNavigator = fileNavigator
        self.onPick = onPick
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: IDEFolderPicker
        private var scopedURL: URL?
        init(_ parent: IDEFolderPicker) { self.parent = parent }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                let didStart = url.startAccessingSecurityScopedResource()
                if didStart {
                    scopedURL = url
                }
                parent.editorCore?.retainSecurityScopedAccess(to: url)
                if let onPick = parent.onPick {
                    onPick(url)
                } else {
                    // Default behavior if no custom handler
                    parent.fileNavigator.loadFileTree(at: url)
                    Task { @MainActor in
                        LaunchManager.shared.setWorkspaceRoot(url)
                        GitManager.shared.setWorkingDirectory(url)
                    }
                }
            }
        }
    }
}

// MARK: - Document Picker

struct IDEDocumentPicker: UIViewControllerRepresentable {
    @ObservedObject var editorCore: EditorCore
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .sourceCode, .json, .plainText, .data])
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(editorCore: editorCore) }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let editorCore: EditorCore
        init(editorCore: EditorCore) { self.editorCore = editorCore }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            for url in urls { editorCore.openFile(from: url) }
            editorCore.showFilePicker = false
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            editorCore.showFilePicker = false
        }
    }
}

// MARK: - Save As Document Picker
struct IDESaveAsPicker: UIViewControllerRepresentable {
    @ObservedObject var editorCore: EditorCore
    let content: String
    let suggestedName: String
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Create a temporary file to export
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent(suggestedName)
        try? content.write(to: tempURL, atomically: true, encoding: .utf8)
        
        let picker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: false)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(editorCore: editorCore) }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let editorCore: EditorCore
        init(editorCore: EditorCore) { self.editorCore = editorCore }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let savedURL = urls.first {
                // Update the active tab with the new URL
                if let tabId = editorCore.activeTabId,
                   let index = editorCore.tabs.firstIndex(where: { $0.id == tabId }) {
                    editorCore.tabs[index].url = savedURL
                    editorCore.tabs[index].fileName = savedURL.lastPathComponent
                    editorCore.tabs[index].isUnsaved = false
                }
            }
            editorCore.showSaveAsDialog = false
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            editorCore.showSaveAsDialog = false
        }
    }
}




// MARK: - Preview

#Preview {
    ContentView()
}
