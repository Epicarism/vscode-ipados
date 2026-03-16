import SwiftUI
import UIKit
import UniformTypeIdentifiers

// MARK: - Helper Functions
// Moved to Extensions/FileHelpers.swift

// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var editorCore: EditorCore
    @StateObject private var fileNavigator = FileSystemNavigator()
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var showingDocumentPicker = false
    @State private var showingFolderPicker = false
    @State private var showSettings = false
    @State private var showTerminal = false
    @State private var terminalHeight: CGFloat = 200
    @State private var aiPanelWidth: CGFloat = 400
    // sidebar tab now synced via editorCore.focusedSidebarTab (not local @State)
    @State private var pendingTrustURL: URL?
    @State private var windowTitle: String = "CodePad"
    
    @StateObject private var trustManager = WorkspaceTrustManager.shared
    
    private var theme: Theme { themeManager.currentTheme }
    
    var body: some View {
        contentWithSheets
            .modifier(NavigationHandlers(editorCore: editorCore, showTerminal: $showTerminal, showSettings: $showSettings))
            .modifier(EditorActionHandlers(editorCore: editorCore))
            .modifier(CursorAndZoomHandlers(editorCore: editorCore))
            .environmentObject(themeManager)
            .environmentObject(editorCore)
    }

    // MARK: - Notification Handler Modifiers (split to help type-checker)

    private struct NavigationHandlers: ViewModifier {
        @ObservedObject var editorCore: EditorCore
        @Binding var showTerminal: Bool
        @Binding var showSettings: Bool

        func body(content: Content) -> some View {
            content
                .onReceive(NotificationCenter.default.publisher(for: .showCommandPalette)) { _ in editorCore.showCommandPalette = true }
                .onReceive(NotificationCenter.default.publisher(for: .toggleTerminal)) { _ in showTerminal.toggle() }
                .onReceive(NotificationCenter.default.publisher(for: .toggleSidebar)) { _ in editorCore.toggleSidebar() }
                .onReceive(NotificationCenter.default.publisher(for: .showQuickOpen)) { _ in editorCore.showQuickOpen = true }
                .onReceive(NotificationCenter.default.publisher(for: .showGoToSymbol)) { _ in editorCore.showGoToSymbol = true }
                .onReceive(NotificationCenter.default.publisher(for: .showGoToLine)) { _ in editorCore.showGoToLine = true }
                .onReceive(NotificationCenter.default.publisher(for: .showAIAssistant)) { _ in editorCore.showAIAssistant = true }
                .onReceive(NotificationCenter.default.publisher(for: .showSettings)) { _ in showSettings = true }
        }
    }

    private struct EditorActionHandlers: ViewModifier {
        @ObservedObject var editorCore: EditorCore

        func body(content: Content) -> some View {
            content
                .onReceive(NotificationCenter.default.publisher(for: .newFile)) { _ in editorCore.addTab() }
                .onReceive(NotificationCenter.default.publisher(for: .saveFile)) { _ in editorCore.saveActiveTab() }
                .onReceive(NotificationCenter.default.publisher(for: .closeTab)) { _ in if let id = editorCore.activeTabId { editorCore.closeTab(id: id) } }
                .onReceive(NotificationCenter.default.publisher(for: .showFind)) { _ in editorCore.showSearch = true }
                .onReceive(NotificationCenter.default.publisher(for: .showReplace)) { _ in editorCore.showSearch = true }
                .onReceive(NotificationCenter.default.publisher(for: .saveAllFiles)) { _ in editorCore.saveAllTabs() }
                .onReceive(NotificationCenter.default.publisher(for: .goToDefinition)) { _ in editorCore.goToDefinitionAtCursor() }
        }
    }

    private struct CursorAndZoomHandlers: ViewModifier {
        @ObservedObject var editorCore: EditorCore

        func body(content: Content) -> some View {
            content
                .onReceive(NotificationCenter.default.publisher(for: .zoomIn)) { _ in editorCore.zoomIn() }
                .onReceive(NotificationCenter.default.publisher(for: .zoomOut)) { _ in editorCore.zoomOut() }
                .onReceive(NotificationCenter.default.publisher(for: .goBack)) { _ in editorCore.navigateBack() }
                .onReceive(NotificationCenter.default.publisher(for: .goForward)) { _ in editorCore.navigateForward() }
                .onReceive(NotificationCenter.default.publisher(for: .addCursorAbove)) { _ in editorCore.addCursorAbove() }
                .onReceive(NotificationCenter.default.publisher(for: .addCursorBelow)) { _ in editorCore.addCursorBelow() }
        }
    }

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
                .onChange(of: editorCore.showFilePicker) { show in showingDocumentPicker = show }
                .onChange(of: editorCore.activeTab?.fileName) { _ in updateTitle() }
                .onChange(of: editorCore.tabs.count) { _ in updateTitle() }
                .onChange(of: editorCore.activeTabId) { _ in updateTitle() }
                .onChange(of: editorCore.activeTab?.isUnsaved) { _ in updateTitle() }
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
                .onChange(of: editorCore.tabs.map { $0.id }) { _ in
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
                    // WASM execution handled via notification
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
    
    // MARK: - Extracted View Components
    
    @ObservedObject private var tunnelManager = TunnelManager.shared
    
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
                IDEActivityBar(editorCore: editorCore, selectedTab: $editorCore.focusedSidebarTab, showSettings: $showSettings, showTerminal: $showTerminal)
                
                if editorCore.showSidebar {
                    sidebarContent.frame(width: editorCore.sidebarWidth)
                }
                
                VStack(spacing: 0) {
                    IDETabBar(editorCore: editorCore, theme: theme)
                    
                    if let tab = editorCore.activeTab {
                        IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
                            .id(tab.id)
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
                                    editorCore.openFile(from: url)
                                }
                            }
                        }
                    }
                    return true
                }
            }
            
            if showTerminal {
                PanelView(isVisible: $showTerminal, height: $terminalHeight)
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
    
    private func updateWindowTitle() {
        if let activeTab = editorCore.activeTab {
            let fileName = activeTab.fileName
            let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
            windowTitle = "\(unsavedIndicator)\(fileName) - CodePad"
        } else if !editorCore.tabs.isEmpty {
            windowTitle = "CodePad"
        } else {
            windowTitle = "Welcome - CodePad"
        }
        
        // Notify the app of the title change
        NotificationCenter.default.post(
            name: .windowTitleDidChange,
            object: nil,
            userInfo: ["title": windowTitle]
        )
    }
    
    @ViewBuilder
    private var sidebarContent: some View {
        switch editorCore.focusedSidebarTab {
        case 0:
            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
        case 1:
            if let rootURL = fileNavigator.rootURL {
                SearchView(
                    onResultSelected: { filePath, lineNumber in
                        // Open file and go to line
                        if let url = URL(fileURLWithPath: filePath) as URL? {
                            editorCore.openFile(from: url)
                            editorCore.requestedGoToLine = lineNumber
                        }
                    },
                    rootURL: rootURL
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
        case 2:
            GitView()
        case 3:
            DebugView()
        case 4:
            RemoteExplorerView(editorCore: editorCore)
        case 5:
            ExtensionsPanel()
        case 6:
            TestView()
        default:
            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
        }
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
                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
                Button(action: { editorCore.showFilePicker = true }) {
                    Image(systemName: "doc.badge.plus").font(.caption)
                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
                if fileNavigator.fileTree != nil {
                    Button(action: { fileNavigator.refreshFileTree() }) {
                        Image(systemName: "arrow.clockwise").font(.caption)
                    }.foregroundColor(theme.sidebarForeground.opacity(0.7))
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
    }
}

// MARK: - Tab Bar

struct IDETabBar: View {
    @ObservedObject var editorCore: EditorCore
    let theme: Theme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(editorCore.tabs) { tab in
                    IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
                }
                Button(action: { editorCore.addTab() }) {
                    Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
                }
                .accessibilityLabel("New tab")
                .accessibilityHint("Double tap to open a new editor tab")
            }.padding(.horizontal, 4)
        }.frame(height: 36).background(theme.tabBarBackground)
    }
}

struct IDETabItem: View {
    let tab: Tab
    let isSelected: Bool
    @ObservedObject var editorCore: EditorCore
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
            Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
                .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
            if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
            Button(action: { editorCore.closeTab(id: tab.id) }) {
                Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
                    .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
                    .accessibilityLabel("Close tab")
                    .accessibilityHint("Double tap to close \(tab.fileName)")
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
        .onTapGesture { editorCore.selectTab(id: tab.id) }
        .accessibilityLabel("Tab: \(tab.fileName)\(tab.isUnsaved ? ", unsaved changes" : "")")
        .accessibilityHint("Double tap to switch to this tab")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Editor with Syntax Highlighting + Autocomplete + Folding

struct IDEEditorView: View {
    @ObservedObject var editorCore: EditorCore
    let tab: Tab
    let theme: Theme
    
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

    @StateObject private var autocomplete = AutocompleteManager()
    @State private var showAutocomplete = false
    // Code folding removed - will use VS Code tunnel for real folding
    @StateObject private var findViewModel = FindViewModel()
    
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
                FindReplaceView(viewModel: findViewModel)
                    .background(theme.tabBarBackground)
            }
            
            BreadcrumbsView(editorCore: editorCore, tab: tab)
            
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    // Simple line numbers gutter (folding/breakpoints removed)
                    if lineNumbersStyle != "off" {
                        LineNumbers(
                            totalLines: totalLines,
                            currentLine: currentLineNumber,
                            scrollOffset: scrollOffset,
                            lineHeight: lineHeight,
                            requestedLineSelection: $requestedLineSelection,
                            theme: theme
                        )
                        .frame(width: 44)
                        .background(theme.sidebarBackground.opacity(0.5))
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
                                    isActive: true,
                                    fontSize: editorCore.editorFontSize,
                                    onAcceptAutocomplete: { self.handleAcceptAutocomplete() },
                                    onDismissAutocomplete: { self.handleDismissAutocomplete() }
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
                                    isActive: true,
                                    fontSize: editorCore.editorFontSize,
                                    requestedLineSelection: $requestedLineSelection,
                                    requestedCursorIndex: $requestedCursorIndex,
                                    onAcceptAutocomplete: { self.handleAcceptAutocomplete() },
                                    onDismissAutocomplete: { self.handleDismissAutocomplete() }
                                )
                            }
                        }
                        .onChange(of: text) { newValue in
                            editorCore.updateActiveTabContent(newValue)
                            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
                            autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
                            showAutocomplete = autocomplete.showSuggestions
                            // Folding removed - using VS Code tunnel for real folding
                        }
                        .onChange(of: cursorIndex) { newCursor in
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
                        .frame(width: 80)
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
                    .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
                }
            }
        }
        }
        .onAppear {
            text = tab.content
            // Folding detection removed
        }
        .onChange(of: tab.id) { _ in
            text = tab.content
            // Folding detection removed
        }
        .onChange(of: currentLineNumber) { line in
            editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
        }
        .onChange(of: currentColumn) { col in
            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
        }
        .onChange(of: editorCore.editorFontSize) { newSize in
            // Update lineHeight to match Runestone's line height (~1.4x font size)
            lineHeight = ceil(newSize * 1.4)
        }
        .onChange(of: editorCore.requestedGoToLine) { line in
            if let line = line {
                requestedLineSelection = line - 1  // Convert 1-indexed to 0-indexed
                editorCore.requestedGoToLine = nil  // Clear the request
            }
        }
        .onAppear {
            findViewModel.editorCore = editorCore
            // Set initial lineHeight based on font size
            lineHeight = ceil(editorCore.editorFontSize * 1.4)
        }
    }
    
    // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
}

// MARK: - Line Numbers (Simple)

struct LineNumbers: View {
    let totalLines: Int
    let currentLine: Int
    let scrollOffset: CGFloat
    let lineHeight: CGFloat
    @Binding var requestedLineSelection: Int?
    let theme: Theme

    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(0..<totalLines, id: \.self) { lineIndex in
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
            .padding(.top, 8)
            .offset(y: -scrollOffset)
        }
        .scrollDisabled(true)
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
    @ObservedObject var recentFiles: RecentFileManager = .shared
    @Binding var showFolderPicker: Bool
    let theme: Theme
    
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
                
                // Main content in columns
                HStack(alignment: .top, spacing: 48) {
                    // Left: Start actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Start")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.editorForeground.opacity(0.5))
                            .textCase(.uppercase)
                        
                        WelcomeLink(icon: "doc.badge.plus", title: "New File", shortcut: "\u{2318}N", theme: theme) { editorCore.addTab() }
                        WelcomeLink(icon: "folder", title: "Open Folder...", shortcut: "\u{2318}\u{21E7}O", theme: theme) { showFolderPicker = true }
                        WelcomeLink(icon: "doc", title: "Open File...", shortcut: "\u{2318}O", theme: theme) { editorCore.showFilePicker = true }
                        WelcomeLink(icon: "arrow.triangle.branch", title: "Clone Repository...", shortcut: nil, theme: theme) {
                            editorCore.focusedSidebarTab = 1
                            editorCore.showSidebar = true
                        }
                        WelcomeLink(icon: "network", title: "Connect to SSH Host...", shortcut: nil, theme: theme) {
                            editorCore.showPanel = true
                            NotificationCenter.default.post(name: .toggleTerminal, object: nil)
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
                                    let content = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                                    editorCore.addTab(fileName: url.lastPathComponent, content: content, url: url)
                                    RecentFileManager.shared.addRecentFile(url)
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
        
        deinit {
            if let url = scopedURL {
                url.stopAccessingSecurityScopedResource()
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


// MARK: - Local Code Execution

extension ContentView {
    /// Run the bundled test.wasm sample
    func runSampleWASM() async {
        // Find the bundled test.wasm
        guard let wasmURL = Bundle.main.url(forResource: "test", withExtension: "wasm") else {
            await MainActor.run {
                showTerminal = true
                NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "❌ Error: test.wasm not found in bundle\n"])
            }
            return
        }
        
        await MainActor.run {
            showTerminal = true
            NotificationCenter.default.post(name: .switchToOutputPanel, object: nil)
            NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "▶ Running bundled WASM: test.wasm\n─────────────────────────────────────\n"])
        }
        
        do {
            let config = WASMConfiguration.default
            let runner = try WASMRunner(configuration: config)
            
            try await runner.load(from: wasmURL)
            await MainActor.run {
                NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "✓ Module loaded\n"])
            }
            
            // Call main() which returns 42
            let result = try await runner.execute(function: "main", args: [])
            
            await MainActor.run {
                NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "─────────────────────────────────────\n⮐ Result: \(result)\n✓ Completed\n"])
            }
            
            await runner.unload()
        } catch {
            await MainActor.run {
                NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "❌ Error: \(error.localizedDescription)\n"])
            }
        }
    }
    
    /// Run JavaScript code using JSRunner
    func runJavaScript(code: String, fileName: String) async {
        await MainActor.run {
            showTerminal = true
            NotificationCenter.default.post(name: .switchToOutputPanel, object: nil)
            NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "▶ Running JavaScript: \(fileName)\n─────────────────────────────────────\n"])
        }
        
        let runner = JSRunner()
        
        // Capture console output
        runner.setConsoleHandler { message in
            Task { @MainActor in
                NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "\(message)\n"])
            }
        }
        
        do {
            let result = try await runner.execute(code: code)
            await MainActor.run {
                NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "─────────────────────────────────────\n⮐ Result: \(result)\n✓ Completed\n"])
            }
        } catch {
            await MainActor.run {
                NotificationCenter.default.post(name: .appendOutput, object: nil, userInfo: ["text": "❌ Error: \(error.localizedDescription)\n"])
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
