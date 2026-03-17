import SwiftUI
import UIKit
import Network
import Foundation

// MARK: - Terminal View (Main Container)

struct TerminalView: View {
    @ObservedObject private var workspace = TerminalWorkspace.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @FocusState.Binding var terminalFocused: Bool
    @State private var showConnectionSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Top Toolbar
            HStack(spacing: 10) {
                Text("TERMINAL")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.tabActiveForeground)
                    .padding(.horizontal, 8)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: { workspace.addTab() }) {
                        Image(systemName: "plus")
                    }
                    .help("New Terminal")
                    .accessibilityLabel("New Terminal")
                    .accessibilityHint("Double tap to create a new terminal tab")

                    Button(action: { workspace.toggleSplitActiveTab() }) {
                        Image(systemName: "square.split.2x1")
                    }
                    .disabled(workspace.tabs.isEmpty)
                    .help("Split Terminal")
                    .accessibilityLabel("Split Terminal")
                    .accessibilityHint("Double tap to split the active terminal")

                    Button(action: copyActiveTerminalToClipboard) {
                        Image(systemName: "doc.on.doc")
                    }
                    .disabled(workspace.activePane == nil)
                    .help("Copy Terminal Output")
                    .accessibilityLabel("Copy Terminal Output")
                    .accessibilityHint("Double tap to copy terminal output to clipboard")

                    Button(action: pasteClipboardToActiveTerminal) {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .disabled(workspace.activePane == nil)
                    .help("Paste")
                    .accessibilityLabel("Paste")
                    .accessibilityHint("Double tap to paste clipboard into terminal")

                    Button(action: { workspace.activePane?.clear() }) {
                        Image(systemName: "trash")
                    }
                    .disabled(workspace.activePane == nil)
                    .help("Clear Terminal")
                    .accessibilityLabel("Clear Terminal")
                    .accessibilityHint("Double tap to clear the terminal screen")

                    Button(action: { workspace.killActive() }) {
                        Image(systemName: "xmark")
                    }
                    .disabled(workspace.activePane == nil)
                    .help("Kill Terminal")
                    .accessibilityLabel("Kill Terminal")
                    .accessibilityHint("Double tap to terminate the active terminal")

                    Button(action: { showConnectionSheet = true }) {
                        Image(systemName: "network")
                    }
                    .disabled(workspace.activePane == nil)
                    .help("SSH Connect")
                    .accessibilityLabel("SSH Connect")
                    .accessibilityHint("Double tap to open SSH connection dialog")
                }
                .font(.caption)
                .foregroundColor(themeManager.currentTheme.editorForeground)
            }
            .padding(8)
            .background(themeManager.currentTheme.editorBackground)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.2)),
                alignment: .bottom
            )

            // MARK: Tab Strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(workspace.tabs) { tab in
                        if let primary = tab.panes.first {
                            TerminalTabButtonView(
                                terminal: primary,
                                isActive: workspace.activeTabId == tab.id,
                                onSelect: { workspace.activeTabId = tab.id },
                                onClose: { workspace.closeTab(id: tab.id) },
                                onRename: { workspace.activeTabId = tab.id },
                                onSplit: { workspace.activeTabId = tab.id; workspace.toggleSplitActiveTab() }
                            )
                        }
                    }

                    Button(action: { workspace.addTab() }) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(themeManager.currentTheme.editorForeground.opacity(0.08))
                            )
                    }
                    .buttonStyle(.plain)
                    .help("New Terminal")
                    .accessibilityLabel("New Terminal")
                    .accessibilityHint("Double tap to create a new terminal tab")
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .background(themeManager.currentTheme.editorBackground)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.12)),
                alignment: .bottom
            )

            // MARK: Terminal Content
            Group {
                if let tab = workspace.activeTab {
                    if tab.panes.count <= 1, let terminal = tab.panes.first {
                        SingleTerminalView(
                            terminal: terminal,
                            isActive: true,
                            onActivate: { workspace.setActivePane(terminal.id, in: tab.id) },
                            onKill: { workspace.killActive() },
                            terminalFocused: $terminalFocused
                        )
                    } else {
                        HStack(spacing: 0) {
                            ForEach(tab.panes) { pane in
                                SingleTerminalView(
                                    terminal: pane,
                                    isActive: tab.activePaneId == pane.id,
                                    onActivate: { workspace.setActivePane(pane.id, in: tab.id) },
                                    onKill: { workspace.killActive() },
                                    terminalFocused: $terminalFocused
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)

                                if pane.id != tab.panes.last?.id {
                                    Divider()
                                        .background(themeManager.currentTheme.editorForeground.opacity(0.2))
                                }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("No Open Terminals")
                            .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.5))
                        Button("Create New Terminal") {
                            workspace.addTab()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(themeManager.currentTheme.editorBackground)
                }
            }
        }
        .background(themeManager.currentTheme.editorBackground)
        .sheet(isPresented: $showConnectionSheet) {
            if let active = workspace.activePane {
                SSHConnectionView(terminal: active, isPresented: $showConnectionSheet)
            }
        }
    }

    private func copyActiveTerminalToClipboard() {
        guard let terminal = workspace.activePane else { return }
        let text = terminal.output.map(\.text).joined(separator: "\n")
        UIPasteboard.general.string = text
    }

    private func pasteClipboardToActiveTerminal() {
        guard let terminal = workspace.activePane else { return }
        guard let clip = UIPasteboard.general.string, !clip.isEmpty else { return }
        terminal.draftCommand.append(contentsOf: clip)
    }
}

struct TerminalTabButtonView: View {
    @ObservedObject var terminal: TerminalManager
    var isActive: Bool
    var onSelect: () -> Void
    var onClose: () -> Void
    var onRename: () -> Void
    var onSplit: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showRenameAlert = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                Image(systemName: "terminal")
                    .font(.caption2)

                Text(terminal.title.isEmpty ? "Terminal" : terminal.title)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(maxWidth: 200, alignment: .leading)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isActive ? themeManager.currentTheme.editorForeground.opacity(0.15) : themeManager.currentTheme.editorForeground.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isActive ? themeManager.currentTheme.tabActiveForeground.opacity(0.5) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: {
                showRenameAlert = true
            }) {
                Label("Rename Terminal", systemImage: "pencil")
            }

            Button(action: {
                onSplit()
            }) {
                Label("Split Terminal", systemImage: "square.split.2x1")
            }

            Divider()

            Button(action: {
                onClose()
            }) {
                Label("Close Terminal", systemImage: "xmark")
                    .foregroundColor(Color(UIColor.systemRed))
            }
        }
        .alert("Rename Terminal", isPresented: $showRenameAlert) {
            TextField("Terminal Name", text: $terminal.title)
            Button("OK") { }
        }
    }
}

// MARK: - Single Terminal View

struct SingleTerminalView: View {
    @ObservedObject var terminal: TerminalManager
    var isActive: Bool
    var onActivate: () -> Void
    var onKill: () -> Void
    @FocusState.Binding var terminalFocused: Bool

    @ObservedObject private var themeManager = ThemeManager.shared
    @FocusState private var isInputFocused: Bool
    @State private var userIsScrolledUp = false

    var body: some View {
        VStack(spacing: 0) {
            #if canImport(SwiftTerm)
            if terminal.isConnected {
                // Real terminal via SwiftTerm for SSH sessions
                VStack(spacing: 0) {
                    SwiftTerminalView(terminalManager: terminal)
                    
                    // Mobile helper bar for SwiftTerm
                    HStack(spacing: 12) {
                        Button("Tab") {
                            Task { try? await SSHManager.shared.sendInput("\t") }
                        }
                        Button("Esc") {
                            Task { try? await SSHManager.shared.sendInput("\u{1b}") }
                        }
                        Button("Ctrl+C") {
                            Task { try? await SSHManager.shared.sendInput("\u{03}") }
                        }
                        .foregroundColor(Color(UIColor.systemRed))
                        Button("↑") {
                            Task { try? await SSHManager.shared.sendInput("\u{1b}[A") }
                        }
                        Button("↓") {
                            Task { try? await SSHManager.shared.sendInput("\u{1b}[B") }
                        }
                        Spacer()
                    }
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(themeManager.currentTheme.editorForeground.opacity(0.1))
                }
            } else {
                legacyTerminalContent
            }
            #else
            legacyTerminalContent
            #endif
        }
        .background(themeManager.currentTheme.editorBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(isActive ? themeManager.currentTheme.tabActiveForeground.opacity(0.35) : .clear, lineWidth: 1)
        )
        .onAppear {
            if isActive {
                terminalFocused = true
            }
        }
        .onChange(of: isInputFocused) { _, newValue in
            if newValue {
                terminalFocused = true
            }
        }
        .onChange(of: terminalFocused) { _, newValue in
            if !newValue {
                isInputFocused = false
            }
        }
    }

    @ViewBuilder
    private var legacyTerminalContent: some View {
        VStack(spacing: 0) {
            // Terminal Output
            ScrollViewReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(terminal.output) { line in
                                TerminalLineView(line: line)
                                    .id(line.id)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: geometry.frame(in: .named("terminalScroll")).origin.y
                                )
                            }
                        )
                    }
                    .coordinateSpace(name: "terminalScroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { offset in
                        // Negative offset means the content has been scrolled up.
                        // A small threshold accounts for overscroll / rounding.
                        let isAtBottom = offset >= -20
                        userIsScrolledUp = !isAtBottom
                    }
                    .onChange(of: terminal.output.count) { _, _ in
                        if !userIsScrolledUp {
                            withAnimation(.easeOut(duration: 0.1)) {
                                proxy.scrollTo(terminal.output.last?.id, anchor: .bottom)
                            }
                        }
                    }

                    // Scroll-to-bottom button: appears when user has scrolled up
                    if userIsScrolledUp {
                        Button {
                            userIsScrolledUp = false
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(terminal.output.last?.id, anchor: .bottom)
                            }
                        } label: {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .background(
                                    Circle()
                                        .fill(Color(UIColor.systemBackground))
                                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                                )
                        }
                        .padding(.trailing, 12)
                        .padding(.bottom, 8)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
            }
            .contentShape(Rectangle())
            .contextMenu {
                Button(action: {
                    let text = terminal.output.map(\.text).joined(separator: "\n")
                    UIPasteboard.general.string = text
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }

                Button(action: {
                    if let clip = UIPasteboard.general.string, !clip.isEmpty {
                        terminal.draftCommand.append(contentsOf: clip)
                    }
                }) {
                    Label("Paste", systemImage: "doc.on.clipboard")
                }

                Divider()

                Button(action: {
                    terminal.clear()
                }) {
                    Label("Clear Terminal", systemImage: "trash")
                }

                Divider()

                Button(action: {
                    onKill()
                }) {
                    Label("Kill Terminal", systemImage: "xmark.circle")
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            .onTapGesture {
                onActivate()
                terminalFocused = true
                // Focus the terminal input field after a brief delay
                // to allow any editor to resign first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isInputFocused = true
                }
            }

            // Input Area
            HStack(spacing: 0) {
                Text(terminal.promptString)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(themeManager.currentTheme.type)
                    .padding(.leading, 8)

                TextField("", text: $terminal.draftCommand)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(themeManager.currentTheme.editorForeground)
                    .accentColor(themeManager.currentTheme.cursor)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isInputFocused)
                    .onSubmit { executeCommand() }
                    .padding(8)
            }
            .background(themeManager.currentTheme.editorBackground)

            // Mobile Helper Bar (optional)
            if isInputFocused {
                HStack(spacing: 12) {
                    Button("Tab") { terminal.sendTab() }
                    Button("Esc") { terminal.sendEscape() }
                    Button("Ctrl+C") { terminal.sendInterrupt() }
                        .foregroundColor(Color(UIColor.systemRed))
                    Button("↑") { if let cmd = terminal.previousCommand() { terminal.draftCommand = cmd } }
                    Button("↓") { if let cmd = terminal.nextCommand() { terminal.draftCommand = cmd } }
                    Spacer()
                    Button("ls") { terminal.draftCommand = "ls -la" }
                    Button("git status") { terminal.draftCommand = "git status" }
                }
                .font(.caption)
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(themeManager.currentTheme.editorForeground.opacity(0.1))
            }
        }
    }

    private func executeCommand() {
        let command = terminal.draftCommand.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }
        terminal.executeCommand(command)
        terminal.draftCommand = ""
    }
}

struct TerminalLineView: View {
    let line: TerminalLine
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        if line.isANSI {
            ANSIText(line.text, segments: line.segments)
        } else {
            Text(line.text)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(colorForType(line.type))
                .textSelection(.enabled)
        }
    }
    
    func colorForType(_ type: LineType) -> Color {
        switch type {
        case .command: return themeManager.currentTheme.editorForeground
        case .output: return themeManager.currentTheme.editorForeground.opacity(0.9)
        case .error:
            // Theme has no dedicated errorColor property; use red adapted to theme brightness
            return themeManager.currentTheme.isDark
                ? Color(red: 0.96, green: 0.35, blue: 0.35)
                : Color(red: 0.80, green: 0.19, blue: 0.19)
        case .system: return themeManager.currentTheme.comment
        case .prompt: return themeManager.currentTheme.type
        }
    }
}

// MARK: - Terminal Workspace Manager

@MainActor struct TerminalTab: Identifiable {
    let id: UUID
    var panes: [TerminalManager]
    var activePaneId: UUID

    init(panes: [TerminalManager]) {
        self.id = UUID()
        self.panes = panes
        self.activePaneId = panes.first?.id ?? UUID()
    }

    var title: String {
        panes.first?.title ?? "Terminal"
    }

    nonisolated static func == (lhs: TerminalTab, rhs: TerminalTab) -> Bool {
        lhs.id == rhs.id
    }
}

extension TerminalTab: Equatable {}

@MainActor final class TerminalWorkspace: ObservableObject {
    static let shared = TerminalWorkspace()

    @Published var tabs: [TerminalTab] = []
    @Published var activeTabId: UUID?

    var activeTabIndex: Int? {
        guard let id = activeTabId else { return nil }
        return tabs.firstIndex(where: { $0.id == id })
    }

    var activeTab: TerminalTab? {
        guard let idx = activeTabIndex else { return nil }
        return tabs[idx]
    }

    var activePane: TerminalManager? {
        guard let tab = activeTab else { return nil }
        return tab.panes.first(where: { $0.id == tab.activePaneId }) ?? tab.panes.first
    }

    init() {
        addTab() // start with one
    }

    func addTab() {
        let term = TerminalManager()
        term.title = "Terminal \(tabs.count + 1)"
        let tab = TerminalTab(panes: [term])
        tabs.append(tab)
        activeTabId = tab.id
    }

    func closeTab(id: UUID) {
        guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
        for pane in tabs[idx].panes {
            pane.disconnect()
        }
        tabs.remove(at: idx)
        if activeTabId == id {
            activeTabId = tabs.last?.id
        }
    }

    func setActivePane(_ paneId: UUID, in tabId: UUID) {
        guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }
        tabs[tabIndex].activePaneId = paneId
    }

    func toggleSplitActiveTab() {
        guard let tabId = activeTabId else { return }
        guard let idx = tabs.firstIndex(where: { $0.id == tabId }) else { return }

        if tabs[idx].panes.count <= 1 {
            // Split: add a second pane (max 2 panes for now)
            let newPane = TerminalManager()
            newPane.title = "Terminal \(tabs.count).2"
            tabs[idx].panes.append(newPane)
            tabs[idx].activePaneId = newPane.id
        } else {
            // Unsplit: remove all panes except the first
            let extraPanes = tabs[idx].panes.dropFirst()
            for pane in extraPanes {
                pane.disconnect()
            }
            tabs[idx].panes = Array(tabs[idx].panes.prefix(1))
            tabs[idx].activePaneId = tabs[idx].panes.first?.id ?? tabs[idx].activePaneId
        }
    }

    func killActive() {
        guard let tabId = activeTabId else { return }
        guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }

        let paneId = tabs[tabIndex].activePaneId
        if tabs[tabIndex].panes.count > 1 {
            // If split, kill the active pane only.
            if let paneIndex = tabs[tabIndex].panes.firstIndex(where: { $0.id == paneId }) {
                tabs[tabIndex].panes[paneIndex].disconnect()
                tabs[tabIndex].panes.remove(at: paneIndex)
            }
            tabs[tabIndex].activePaneId = tabs[tabIndex].panes.first?.id ?? tabs[tabIndex].activePaneId

            if tabs[tabIndex].panes.isEmpty {
                closeTab(id: tabId)
            }
        } else {
            // If not split, kill the tab.
            closeTab(id: tabId)
        }
    }
}

// MARK: - Terminal Manager

@MainActor class TerminalManager: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String = "Terminal"
    
    @Published var output: [TerminalLine] = [
        TerminalLine(text: "CodePad Terminal v2.0", type: .system),
        TerminalLine(text: "Type 'help' for commands or connect via SSH (SwiftNIO).", type: .system),
        TerminalLine(text: "", type: .output)
    ]
    @Published var isConnected = false
    @Published var isConnecting = false
    @Published var connectionStatus = "Not connected"
    @Published var promptString = "$ "
    @Published var draftCommand: String = ""
    
    private var sshManager: SSHManager?
    private var currentConfig: SSHConnectionConfig?
    private var commandHistory: [String] = []
    private var historyIndex = 0
    private var currentDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSHomeDirectory())
    
    // Persistent ANSI state across line boundaries
    // Used by parseANSIWithState for cross-line ANSI state continuity
    var ansiColor: Color? = nil
    var ansiBgColor: Color? = nil
    var ansiBold = false
    var ansiItalic = false
    var ansiUnderline = false
    var ansiReverseVideo = false
    
    /// Callback for SwiftTerm integration — when set, SSH output is fed here
    /// instead of (or in addition to) being appended to the output array.
    var swiftTermFeedHandler: ((String) -> Void)?
    
    func clear() {
        output = []
    }
    
    func connect(to config: SSHConnectionConfig) {
        currentConfig = config
        isConnecting = true
        connectionStatus = "Connecting to \(config.host)..."
        title = "\(config.username)@\(config.host)"
        
        appendOutput("Connecting to \(config.username)@\(config.host):\(config.port)...", type: .system)
        appendOutput("Using SwiftNIO SSH (real SSH protocol)", type: .system)
        
        sshManager = SSHManager.shared
        sshManager?.delegate = self
        sshManager?.connect(config: config) { [weak self] result in
            switch result {
            case .success:
                // Connection successful - delegate will handle UI update
                Task { @MainActor in SSHConnectionStore.shared.updateLastUsed(config) }
            case .failure(let error):
                Task { @MainActor in
                    self?.appendOutput("Connection failed: \(error.localizedDescription)", type: .error)
                    self?.isConnecting = false
                    self?.connectionStatus = "Connection failed"
                }
            }
        }
    }
    
    // Legacy connect method for backward compatibility
    @available(*, deprecated, message: "Use SSHConnectionConfig instead")
    func connect(to connection: SSHConnection) {
        let authMethod: SSHConnectionConfig.SSHAuthMethod
        if let privateKey = connection.privateKey, !privateKey.isEmpty {
            authMethod = .privateKey(key: privateKey, passphrase: nil)
        } else {
            authMethod = .password(connection.password ?? "")
        }
        
        let config = SSHConnectionConfig(
            name: "\(connection.username)@\(connection.host)",
            host: connection.host,
            port: connection.port,
            username: connection.username,
            authMethod: authMethod
        )
        connect(to: config)
    }
    
    func disconnect() {
        sshManager?.disconnect()
        sshManager = nil
        isConnected = false
        isConnecting = false
        connectionStatus = "Disconnected"
        promptString = "$ "
        title = "Terminal (Disconnected)"
        appendOutput("Disconnected from server.", type: .system)
    }
    
    func executeCommand(_ command: String) {
        commandHistory.append(command)
        if commandHistory.count > 1000 { commandHistory.removeFirst(commandHistory.count - 1000) }
        historyIndex = commandHistory.count
        
        if isConnected {
            // Don't echo command - server will echo it back
            sshManager?.send(command: command)
        } else {
            appendOutput(promptString + command, type: .command)
            processLocalCommand(command)
        }
    }
    
    func sendInterrupt() {
        if isConnected {
            sshManager?.sendInterrupt()
        } else {
            appendOutput("^C", type: .system)
        }
    }
    
    func sendTab() {
        if isConnected {
            sshManager?.sendTab()
        }
    }
    
    func sendEscape() {
        if isConnected {
            sshManager?.sendEscape()
        }
    }
    
    func previousCommand() -> String? {
        guard !commandHistory.isEmpty else { return nil }
        if historyIndex > 0 {
            historyIndex -= 1
        }
        return commandHistory[historyIndex]
    }
    
    func nextCommand() -> String? {
        guard !commandHistory.isEmpty else { return nil }
        if historyIndex < commandHistory.count - 1 {
            historyIndex += 1
            return commandHistory[historyIndex]
        } else {
            historyIndex = commandHistory.count
            return nil  // Return nil when past end of history to preserve draft
        }
    }
    
    // MARK: - Pipe-aware local command dispatcher
    private func processLocalCommand(_ rawCommand: String) {
        // Split on | to support piping between built-in commands
        let segments = rawCommand.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        if segments.count > 1 {
            var pipedLines: [String]? = nil
            for (idx, segment) in segments.enumerated() {
                let isLast = idx == segments.count - 1
                let result = executeBuiltinCommand(segment, stdinLines: pipedLines)
                if isLast {
                    for line in result.output {
                        appendOutput(line, type: result.isError ? .error : .output)
                    }
                } else {
                    pipedLines = result.output
                }
            }
        } else {
            let result = executeBuiltinCommand(rawCommand.trimmingCharacters(in: .whitespaces), stdinLines: nil)
            for line in result.output {
                appendOutput(line, type: result.isError ? .error : .output)
            }
        }
    }

    // Result wrapper for built-in command execution
    private struct CommandResult {
        var output: [String]
        var isError: Bool
        init(_ lines: [String], error: Bool = false) { self.output = lines; self.isError = error }
        static func err(_ msg: String) -> CommandResult { CommandResult([msg], error: true) }
        static func out(_ msg: String) -> CommandResult { CommandResult([msg]) }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func executeBuiltinCommand(_ command: String, stdinLines: [String]?) -> CommandResult {
        // Tokenise, respecting single and double quoted strings
        var tokens: [String] = []
        var current = ""
        var inQuote: Character? = nil
        for ch in command {
            if let q = inQuote {
                if ch == q { inQuote = nil } else { current.append(ch) }
            } else if ch == "'" || ch == "\"" {
                inQuote = ch
            } else if ch == " " {
                if !current.isEmpty { tokens.append(current); current = "" }
            } else {
                current.append(ch)
            }
        }
        if !current.isEmpty { tokens.append(current) }

        guard let cmd = tokens.first?.lowercased() else { return CommandResult([]) }
        let args = Array(tokens.dropFirst())
        let rawArg = args.joined(separator: " ")

        switch cmd {

        // ── help ──────────────────────────────────────────────────────────
        case "help":
            return CommandResult(["""
            Local Built-in Commands:
              help              - Show this help
              clear             - Clear terminal
              echo <text>       - Echo text
              date              - Show current date
              whoami            - Show current user
              uname [-a]        - System information
              history           - Show command history
              pwd               - Print working directory
              ls [-la] [path]   - List files
              cd <path>         - Change directory
              cat <file>        - Display file contents
              head [-n N] <file>- Show first N lines (default 10)
              tail [-n N] <file>- Show last N lines (default 10)
              wc <file>         - Word / line count
              grep [-in] <pat> <file> - Search for pattern
              find <pattern>    - Find files matching pattern
              tree [path]       - Show directory tree
              stat <file>       - Show file information
              du [-h] [path]    - Estimate disk usage
              which <cmd>       - Show built-in command path
              mkdir <name>      - Create directory
              touch <name>      - Create empty file
              rm <name>         - Remove file
              cp <src> <dst>    - Copy file
              mv <src> <dst>    - Move / rename file
              cal [month year]  - Show calendar
              env               - Show environment info
              ssh               - Show SSH connection info

            Tip: Pipe built-in commands with |  e.g.  ls | grep .swift
            For a full Unix shell, tap the network icon to connect via SSH.
            """])

        // ── clear ─────────────────────────────────────────────────────────
        case "clear":
            Task { @MainActor in self.clear() }
            return CommandResult([])

        // ── echo ──────────────────────────────────────────────────────────
        case "echo":
            return .out(rawArg)

        // ── date ──────────────────────────────────────────────────────────
        case "date":
            let fmt = DateFormatter()
            fmt.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
            return .out(fmt.string(from: Date()))

        // ── whoami ────────────────────────────────────────────────────────
        case "whoami":
            return .out(ProcessInfo.processInfo.hostName.components(separatedBy: ".").first ?? "ipad-user")

        // ── uname ─────────────────────────────────────────────────────────
        case "uname":
            let all = args.contains("-a") || args.contains("--all")
            let device = UIDevice.current
            if all {
                return .out("Darwin \(device.name) \(device.systemVersion) iPadOS \(device.systemVersion) \(device.model) (built-in terminal)")
            } else {
                return .out("Darwin")
            }

        // ── history ───────────────────────────────────────────────────────
        case "history":
            var lines: [String] = []
            for (index, h) in commandHistory.enumerated() {
                lines.append("  \(index + 1)  \(h)")
            }
            return CommandResult(lines)

        // ── ssh ───────────────────────────────────────────────────────────
        case "ssh":
            return CommandResult(["""
            SSH Status: \(isConnected ? "Connected" : "Not connected")
            Implementation: SwiftNIO SSH (apple/swift-nio-ssh)
            Features: Password auth, Key auth, PTY support, Shell sessions
            """])

        // ── pwd ───────────────────────────────────────────────────────────
        case "pwd":
            return .out(currentDirectory.path)

        // ── ls ────────────────────────────────────────────────────────────
        case "ls":
            var showHidden = false
            var showLong = false
            var targetPath = currentDirectory
            for arg in args {
                if arg.hasPrefix("-") {
                    if arg.contains("a") { showHidden = true }
                    if arg.contains("l") { showLong = true }
                } else if arg.hasPrefix("/") {
                    targetPath = URL(fileURLWithPath: arg)
                } else if arg == ".." {
                    targetPath = currentDirectory.deletingLastPathComponent()
                } else if arg == "~" {
                    targetPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSHomeDirectory())
                } else {
                    targetPath = currentDirectory.appendingPathComponent(arg)
                }
            }
            do {
                var options: FileManager.DirectoryEnumerationOptions = []
                if !showHidden { options.insert(.skipsHiddenFiles) }
                let items = try FileManager.default.contentsOfDirectory(
                    at: targetPath,
                    includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey],
                    options: options)
                if items.isEmpty { return .out("(empty directory)") }
                let dateFmt = DateFormatter()
                dateFmt.dateFormat = "MMM dd HH:mm"
                var lines: [String] = []
                for item in items.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                    let isDir = (try? item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                    let name = item.lastPathComponent + (isDir ? "/" : "")
                    if showLong {
                        let size = (try? item.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                        let modDate = (try? item.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
                        let sizeStr = isDir ? "-" : ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
                        let dateStr = dateFmt.string(from: modDate)
                        let typeChar = isDir ? "d" : "-"
                        lines.append("\(typeChar)rwxr-xr-x  \(sizeStr.padding(toLength: 10, withPad: " ", startingAt: 0)) \(dateStr)  \(name)")
                    } else {
                        lines.append("  \(name)")
                    }
                }
                return CommandResult(lines)
            } catch {
                return .err("ls: \(error.localizedDescription)")
            }

        // ── cd ────────────────────────────────────────────────────────────
        case "cd":
            let arg = args.first ?? "~"
            let targetPath: URL
            if arg == ".." {
                targetPath = currentDirectory.deletingLastPathComponent()
            } else if arg == "~" {
                targetPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSHomeDirectory())
            } else if arg.hasPrefix("/") {
                targetPath = URL(fileURLWithPath: arg)
            } else {
                targetPath = currentDirectory.appendingPathComponent(arg)
            }
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: targetPath.path, isDirectory: &isDir), isDir.boolValue {
                currentDirectory = targetPath
                promptString = "\(targetPath.lastPathComponent) $ "
                return .out(targetPath.path)
            } else {
                return .err("cd: no such directory: \(arg)")
            }

        // ── cat ───────────────────────────────────────────────────────────
        case "cat":
            guard !args.isEmpty else { return .err("cat: missing file operand") }
            let filePath = args[0].hasPrefix("/") ? URL(fileURLWithPath: args[0]) : currentDirectory.appendingPathComponent(args[0])
            do {
                let content = try String(contentsOf: filePath, encoding: .utf8)
                return CommandResult(content.components(separatedBy: .newlines))
            } catch {
                return .err("cat: \(args[0]): \(error.localizedDescription)")
            }

        // ── head ──────────────────────────────────────────────────────────
        case "head":
            guard !args.isEmpty else { return .err("head: missing file operand") }
            var nLines = 10
            var fileArg = ""
            var i = 0
            while i < args.count {
                if args[i] == "-n", i + 1 < args.count {
                    nLines = Int(args[i + 1]) ?? 10; i += 2
                } else {
                    fileArg = args[i]; i += 1
                }
            }
            if fileArg.isEmpty { fileArg = args[0] }
            let headPath = fileArg.hasPrefix("/") ? URL(fileURLWithPath: fileArg) : currentDirectory.appendingPathComponent(fileArg)
            do {
                let content = try String(contentsOf: headPath, encoding: .utf8)
                return CommandResult(Array(content.components(separatedBy: .newlines).prefix(nLines)))
            } catch {
                return .err("head: \(fileArg): \(error.localizedDescription)")
            }

        // ── tail ──────────────────────────────────────────────────────────
        case "tail":
            guard !args.isEmpty else { return .err("tail: missing file operand") }
            var nLines = 10
            var fileArg = ""
            var i = 0
            while i < args.count {
                if args[i] == "-n", i + 1 < args.count {
                    nLines = Int(args[i + 1]) ?? 10; i += 2
                } else {
                    fileArg = args[i]; i += 1
                }
            }
            if fileArg.isEmpty { fileArg = args[0] }
            let tailPath = fileArg.hasPrefix("/") ? URL(fileURLWithPath: fileArg) : currentDirectory.appendingPathComponent(fileArg)
            do {
                let content = try String(contentsOf: tailPath, encoding: .utf8)
                return CommandResult(Array(content.components(separatedBy: .newlines).suffix(nLines)))
            } catch {
                return .err("tail: \(fileArg): \(error.localizedDescription)")
            }

        // ── wc ────────────────────────────────────────────────────────────
        case "wc":
            guard !args.isEmpty else { return .err("wc: missing file operand") }
            let filePath = args[0].hasPrefix("/") ? URL(fileURLWithPath: args[0]) : currentDirectory.appendingPathComponent(args[0])
            do {
                let content = try String(contentsOf: filePath, encoding: .utf8)
                let lineCount = content.filter { $0 == "\n" }.count
                let wordCount = content.split(whereSeparator: { $0.isWhitespace }).count
                let charCount = content.count
                return .out("  \(lineCount) lines  \(wordCount) words  \(charCount) chars  \(args[0])")
            } catch {
                return .err("wc: \(error.localizedDescription)")
            }

        // ── find ──────────────────────────────────────────────────────────
        case "find":
            guard !args.isEmpty else { return .err("find: missing pattern") }
            let pattern = args[0].lowercased()
            var lines: [String] = []
            if let enumerator = FileManager.default.enumerator(at: currentDirectory, includingPropertiesForKeys: nil) {
                while let url = enumerator.nextObject() as? URL {
                    if url.lastPathComponent.lowercased().contains(pattern) {
                        let rel = url.path.replacingOccurrences(of: currentDirectory.path + "/", with: "")
                        lines.append("  \(rel)")
                        if lines.count >= 100 { lines.append("  ... (limited to 100 results)"); break }
                    }
                }
            }
            if lines.isEmpty { lines.append("No files matching '\(pattern)'") }
            return CommandResult(lines)

        // ── grep ──────────────────────────────────────────────────────────
        case "grep":
            // Usage: grep [-in] pattern [file]
            // When receiving piped input, file argument is optional
            var caseInsensitive = false
            var showLineNums = false
            var remainingArgs = args
            if let first = remainingArgs.first, first.hasPrefix("-") {
                if first.contains("i") { caseInsensitive = true }
                if first.contains("n") { showLineNums = true }
                remainingArgs.removeFirst()
            }
            guard !remainingArgs.isEmpty else { return .err("grep: missing pattern") }
            let searchPattern = remainingArgs[0]
            remainingArgs.removeFirst()

            var sourceLines: [String]
            if let piped = stdinLines {
                sourceLines = piped
            } else if !remainingArgs.isEmpty {
                let fp = remainingArgs[0].hasPrefix("/") ? URL(fileURLWithPath: remainingArgs[0]) : currentDirectory.appendingPathComponent(remainingArgs[0])
                guard let content = try? String(contentsOf: fp, encoding: .utf8) else {
                    return .err("grep: \(remainingArgs[0]): no such file")
                }
                sourceLines = content.components(separatedBy: .newlines)
            } else {
                return .err("grep: missing file argument (or use a pipe)")
            }

            var output: [String] = []
            for (idx, line) in sourceLines.enumerated() {
                let matches = caseInsensitive
                    ? line.lowercased().contains(searchPattern.lowercased())
                    : line.contains(searchPattern)
                if matches {
                    let prefix = showLineNums ? "\(idx + 1):" : ""
                    output.append("\(prefix)\(line)")
                    if output.count >= 500 { output.append("... (truncated at 500 matches)"); break }
                }
            }
            if output.isEmpty { output.append("(no matches)") }
            return CommandResult(output)

        // ── tree ──────────────────────────────────────────────────────────
        case "tree":
            let rootURL: URL
            if let r = args.first {
                rootURL = r.hasPrefix("/") ? URL(fileURLWithPath: r) : currentDirectory.appendingPathComponent(r)
            } else {
                rootURL = currentDirectory
            }
            var lines: [String] = [rootURL.lastPathComponent + "/"]
            var dirCount = 0
            var fileCount = 0
            func addTree(dir: URL, prefix: String) {
                guard let items = try? FileManager.default.contentsOfDirectory(
                    at: dir,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: .skipsHiddenFiles
                ).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) else { return }
                for (i, item) in items.enumerated() {
                    guard lines.count < 300 else { return }
                    let isLast = i == items.count - 1
                    let connector = isLast ? "└── " : "├── "
                    let isDir = (try? item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                    lines.append(prefix + connector + item.lastPathComponent + (isDir ? "/" : ""))
                    if isDir {
                        dirCount += 1
                        addTree(dir: item, prefix: prefix + (isLast ? "    " : "│   "))
                    } else {
                        fileCount += 1
                    }
                }
            }
            addTree(dir: rootURL, prefix: "")
            lines.append("")
            lines.append("\(dirCount) director\(dirCount == 1 ? "y" : "ies"), \(fileCount) file\(fileCount == 1 ? "" : "s")")
            return CommandResult(lines)

        // ── stat ──────────────────────────────────────────────────────────
        case "stat":
            guard !args.isEmpty else { return .err("stat: missing file operand") }
            let filePath = args[0].hasPrefix("/") ? URL(fileURLWithPath: args[0]) : currentDirectory.appendingPathComponent(args[0])
            do {
                let keys: Set<URLResourceKey> = [
                    .fileSizeKey, .isDirectoryKey, .isSymbolicLinkKey,
                    .creationDateKey, .contentModificationDateKey, .contentAccessDateKey
                ]
                let res = try filePath.resourceValues(forKeys: keys)
                let dateFmt = DateFormatter()
                dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let size  = res.fileSize ?? 0
                let isDir = res.isDirectory ?? false
                let isSym = res.isSymbolicLink ?? false
                let ftype = isSym ? "symbolic link" : (isDir ? "directory" : "regular file")
                let cdate = dateFmt.string(from: res.creationDate ?? Date())
                let mdate = dateFmt.string(from: res.contentModificationDate ?? Date())
                let adate = dateFmt.string(from: res.contentAccessDate ?? Date())
                let attrs = try FileManager.default.attributesOfItem(atPath: filePath.path)
                let perms = attrs[.posixPermissions] as? Int ?? 0
                let permStr = String(format: "%o", perms)
                return CommandResult([
                    "  File: \(filePath.path)",
                    "  Type: \(ftype)",
                    "  Size: \(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)) (\(size) bytes)",
                    "  Mode: 0\(permStr)",
                    " Birth: \(cdate)",
                    "Modify: \(mdate)",
                    "Access: \(adate)"
                ])
            } catch {
                return .err("stat: \(args[0]): \(error.localizedDescription)")
            }

        // ── du ────────────────────────────────────────────────────────────
        case "du":
            let pathArg = args.first(where: { !$0.hasPrefix("-") })
            let targetURL = pathArg.map {
                $0.hasPrefix("/") ? URL(fileURLWithPath: $0) : currentDirectory.appendingPathComponent($0)
            } ?? currentDirectory
            let humanReadable = !args.contains("-b")

            func dirSize(_ url: URL) -> Int64 {
                var total: Int64 = 0
                if let enumerator = FileManager.default.enumerator(
                    at: url, includingPropertiesForKeys: [.fileSizeKey],
                    options: [.skipsHiddenFiles]) {
                    while let fileURL = enumerator.nextObject() as? URL {
                        let s = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                        total += Int64(s)
                    }
                }
                return total
            }

            guard let items = try? FileManager.default.contentsOfDirectory(
                at: targetURL,
                includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey],
                options: .skipsHiddenFiles) else {
                return .err("du: cannot access \(targetURL.path)")
            }

            var lines: [String] = []
            for item in items.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                let isDir = (try? item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let sz: Int64 = isDir
                    ? dirSize(item)
                    : Int64((try? item.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
                let szStr = humanReadable
                    ? ByteCountFormatter.string(fromByteCount: sz, countStyle: .file)
                    : "\(sz)"
                lines.append("\(szStr.padding(toLength: 12, withPad: " ", startingAt: 0))  \(item.lastPathComponent)")
            }
            let total = dirSize(targetURL)
            let totalStr = humanReadable
                ? ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
                : "\(total)"
            lines.append("")
            lines.append("\(totalStr.padding(toLength: 12, withPad: " ", startingAt: 0))  total")
            return CommandResult(lines)

        // ── which ─────────────────────────────────────────────────────────
        case "which":
            guard !args.isEmpty else { return .err("which: missing argument") }
            let builtins: Set<String> = [
                "help", "clear", "echo", "date", "whoami", "uname", "history",
                "ssh", "pwd", "ls", "cd", "cat", "head", "tail", "wc", "find",
                "grep", "tree", "stat", "du", "which", "mkdir", "touch", "rm",
                "cp", "mv", "cal", "env"
            ]
            var lines: [String] = []
            for arg in args {
                if builtins.contains(arg.lowercased()) {
                    lines.append("built-in: \(arg.lowercased())")
                } else {
                    lines.append("\(arg): not found (built-in shell only)")
                }
            }
            return CommandResult(lines)

        // ── cal ───────────────────────────────────────────────────────────
        case "cal":
            let cal = Calendar.current
            var components = cal.dateComponents([.year, .month], from: Date())
            if args.count == 2, let m = Int(args[0]), let y = Int(args[1]) {
                components.month = m; components.year = y
            } else if args.count == 1, let y = Int(args[0]) {
                components.year = y
            }
            guard let firstDay = cal.date(from: components),
                  let range = cal.range(of: .day, in: .month, for: firstDay) else {
                return .err("cal: invalid date")
            }
            let hdrFmt = DateFormatter()
            hdrFmt.dateFormat = "MMMM yyyy"
            let title = hdrFmt.string(from: firstDay)
            let header = title.count < 20
                ? String(repeating: " ", count: (20 - title.count) / 2) + title
                : title
            var lines: [String] = [header, "Su Mo Tu We Th Fr Sa"]
            let startWeekday = cal.component(.weekday, from: firstDay) - 1  // 0=Sun
            var dayLine = String(repeating: "   ", count: startWeekday)
            var col = startWeekday
            for day in range {
                let dayStr = "\(day)"
                dayLine += dayStr.count == 1 ? " \(dayStr)" : dayStr
                col += 1
                if col == 7 {
                    lines.append(dayLine)
                    dayLine = ""
                    col = 0
                } else {
                    dayLine += " "
                }
            }
            if !dayLine.trimmingCharacters(in: .whitespaces).isEmpty {
                lines.append(dayLine)
            }
            return CommandResult(lines)

        // ── mkdir ─────────────────────────────────────────────────────────
        case "mkdir":
            guard !args.isEmpty else { return .err("mkdir: missing operand") }
            let dirPath = currentDirectory.appendingPathComponent(args[0])
            do {
                try FileManager.default.createDirectory(at: dirPath, withIntermediateDirectories: true)
                return .out("Created directory: \(args[0])")
            } catch {
                return .err("mkdir: \(error.localizedDescription)")
            }

        // ── touch ─────────────────────────────────────────────────────────
        case "touch":
            guard !args.isEmpty else { return .err("touch: missing operand") }
            let filePath = currentDirectory.appendingPathComponent(args[0])
            if !FileManager.default.fileExists(atPath: filePath.path) {
                FileManager.default.createFile(atPath: filePath.path, contents: nil)
                return .out("Created: \(args[0])")
            } else {
                return .out("File already exists: \(args[0])")
            }

        // ── rm ────────────────────────────────────────────────────────────
        case "rm":
            guard !args.isEmpty else { return .err("rm: missing operand") }
            let filePath = currentDirectory.appendingPathComponent(args[0])
            do {
                try FileManager.default.removeItem(at: filePath)
                return .out("Removed: \(args[0])")
            } catch {
                return .err("rm: \(error.localizedDescription)")
            }

        // ── cp ────────────────────────────────────────────────────────────
        case "cp":
            guard args.count >= 2 else { return .err("cp: usage: cp <source> <destination>") }
            let src = currentDirectory.appendingPathComponent(args[0])
            let dst = currentDirectory.appendingPathComponent(args[1])
            do {
                try FileManager.default.copyItem(at: src, to: dst)
                return .out("Copied \(args[0]) → \(args[1])")
            } catch {
                return .err("cp: \(error.localizedDescription)")
            }

        // ── mv ────────────────────────────────────────────────────────────
        case "mv":
            guard args.count >= 2 else { return .err("mv: usage: mv <source> <destination>") }
            let src = currentDirectory.appendingPathComponent(args[0])
            let dst = currentDirectory.appendingPathComponent(args[1])
            do {
                try FileManager.default.moveItem(at: src, to: dst)
                return .out("Moved \(args[0]) → \(args[1])")
            } catch {
                return .err("mv: \(error.localizedDescription)")
            }

        // ── env ───────────────────────────────────────────────────────────
        case "env":
            return CommandResult(["""
            PLATFORM: iPadOS \(UIDevice.current.systemVersion)
            DEVICE: \(UIDevice.current.model)
            APP: CodePad Terminal v2.0
            PWD: \(currentDirectory.path)
            HOME: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? "~")
            SSH: \(isConnected ? "Connected" : "Not connected")
            """])

        // ── unknown command ───────────────────────────────────────────────
        default:
            return CommandResult([
                "\(cmd): command not found",
                "This is a sandboxed built-in shell; '\(cmd)' is not available locally.",
                "Tip: Connect via SSH (tap the network \u{1F4F6} icon in the toolbar) for a full Unix shell.",
                "     Type 'help' to see all available built-in commands."
            ], error: true)
        }
    }
    func appendOutput(_ text: String, type: LineType, isANSI: Bool = false) {
        // Split multi-line output into separate lines
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            if !line.isEmpty || lines.count == 1 {
                let hasANSI = isANSI || line.contains("\u{1B}")
                if hasANSI {
                    // Use stateful ANSI parsing to maintain cross-line state
                    let result = ANSIText.parseANSIWithState(
                        line,
                        initialColor: ansiColor,
                        initialBgColor: ansiBgColor,
                        initialBold: ansiBold,
                        initialItalic: ansiItalic,
                        initialUnderline: ansiUnderline,
                        initialReverseVideo: ansiReverseVideo
                    )
                    // Update persistent state with final state from parsing
                    ansiColor = result.finalColor
                    ansiBgColor = result.finalBgColor
                    ansiBold = result.finalBold
                    ansiItalic = result.finalItalic
                    ansiUnderline = result.finalUnderline
                    ansiReverseVideo = result.finalReverseVideo
                    // Store pre-parsed segments
                    self.output.append(TerminalLine(text: line, type: type, isANSI: true, segments: result.segments))
                } else {
                    self.output.append(TerminalLine(text: line, type: type, isANSI: false, segments: nil))
                }
            }
        }
        if self.output.count > 10000 {
            self.output = Array(self.output.suffix(10000))
        }
    }
}

// MARK: - SSH Manager Delegate
extension TerminalManager: SSHManagerDelegate {
    nonisolated func sshManagerDidConnect(_ manager: SSHManager) {
        Task { @MainActor in
            self.isConnected = true
            self.isConnecting = false
            self.connectionStatus = "Connected"
            self.promptString = "" // Shell will provide prompt
            self.appendOutput("Connected successfully via SwiftNIO SSH!", type: .system)
        }
    }
    
    nonisolated func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?) {
        Task { @MainActor in
            self.isConnected = false
            self.isConnecting = false
            self.connectionStatus = "Disconnected"
            self.promptString = "$ "
            if let error = error {
                self.appendOutput("Connection lost: \(error.localizedDescription)", type: .error)
            }
        }
    }
    
    nonisolated func sshManager(_ manager: SSHManager, didReceiveOutput text: String) {
        Task { @MainActor in
            // Feed to SwiftTerm if available, otherwise use legacy output
            if let feedHandler = self.swiftTermFeedHandler {
                feedHandler(text)
            } else {
                self.appendOutput(text, type: .output)
            }
        }
    }
    
    nonisolated func sshManager(_ manager: SSHManager, didReceiveError text: String) {
        Task { @MainActor in
            // Feed to SwiftTerm if available, otherwise use legacy output
            if let feedHandler = self.swiftTermFeedHandler {
                feedHandler(text)
            } else {
                self.appendOutput(text, type: .error)
            }
        }
    }
}

// MARK: - SSH Connection View (Enhanced with Saved Connections)

// MARK: - Document Picker for SSH Key Import

final class SSHKeyDocumentPickerDelegate: NSObject,
    UIDocumentPickerDelegate, ObservableObject {

    var onPick: ((URL) -> Void)?

    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        onPick?(url)
    }
}

struct SSHKeyDocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeCoordinator() -> SSHKeyDocumentPickerDelegate {
        let delegate = SSHKeyDocumentPickerDelegate()
        delegate.onPick = onPick
        return delegate
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Allow all file types — SSH keys have no standardised UTI
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController,
                                context: Context) {}
}

struct SSHConnectionView: View {
    @ObservedObject var terminal: TerminalManager
    @Binding var isPresented: Bool
    @ObservedObject private var connectionStore = SSHConnectionStore.shared
    @ObservedObject private var importedKeyStore = SSHImportedKeyStore.shared
    @ObservedObject private var themeManager = ThemeManager.shared

    @State private var connectionName = ""
    @State private var host = ""
    @State private var port = "22"
    @State private var username = ""
    @State private var password = ""
    @State private var useKey = false
    @State private var privateKey = ""
    @State private var keyPassphrase = ""
    @State private var saveConnection = true
    @State private var showSavedConnections = true
    @State private var errorMessage: String?
    @State private var showDocumentPicker = false
    @State private var importSuccessMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                // Saved Connections Section
                if !connectionStore.savedConnections.isEmpty {
                    Section(header: Text("Saved Connections")) {
                        ForEach(connectionStore.savedConnections) { config in
                            Button(action: { connectToSaved(config) }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(config.name)
                                            .font(.headline)
                                            .foregroundColor(themeManager.currentTheme.editorForeground)
                                        Text("\(config.username)@\(config.host):\(config.port)")
                                            .font(.caption)
                                            .foregroundColor(themeManager.currentTheme.comment)
                                    }
                                    Spacer()
                                    if case .privateKey = config.authMethod {
                                        Image(systemName: "key.fill")
                                            .foregroundColor(Color(UIColor.systemOrange))
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    connectionStore.delete(config)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                
                // New Connection Section
                Section(header: Text("New Connection")) {
                    TextField("Connection Name (optional)", text: $connectionName)
                        .textInputAutocapitalization(.never)
                    
                    TextField("Host", text: $host)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                    
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Authentication")) {
                    Picker("Method", selection: $useKey) {
                        Text("Password").tag(false)
                        Text("SSH Key").tag(true)
                    }
                    .pickerStyle(.segmented)

                    if useKey {
                        // Stored keys picker
                        if !importedKeyStore.keys.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Saved Keys")
                                    .font(.caption)
                                    .foregroundColor(themeManager.currentTheme.comment)
                                ForEach(importedKeyStore.keys) { storedKey in
                                    Button(action: {
                                        if let pem = importedKeyStore.pem(for: storedKey) {
                                            privateKey = pem
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "key.fill")
                                                .foregroundColor(Color(UIColor.systemOrange))
                                                .font(.caption)
                                            Text(storedKey.name)
                                                .font(.caption)
                                                .foregroundColor(themeManager.currentTheme.editorForeground)
                                            Spacer()
                                            Text(storedKey.addedDate, style: .date)
                                                .font(.caption2)
                                                .foregroundColor(themeManager.currentTheme.comment)
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            importedKeyStore.delete(storedKey)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }

                        // Import Key button
                        Button(action: { showDocumentPicker = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Import Key from Files…")
                            }
                            .font(.subheadline)
                        }
                        .sheet(isPresented: $showDocumentPicker) {
                            SSHKeyDocumentPicker { url in
                                showDocumentPicker = false
                                Task {
                                    do {
                                        let name = try await SSHManager.shared.importAndStoreKey(from: url)
                                        await MainActor.run {
                                            importSuccessMessage = "Key \"\(name)\" imported and saved."
                                            errorMessage = nil
                                            // Auto-fill the text editor with the newly imported key
                                            if let pem = importedKeyStore.keys.last.flatMap({ importedKeyStore.pem(for: $0) }) {
                                                privateKey = pem
                                            }
                                        }
                                    } catch {
                                        await MainActor.run {
                                            errorMessage = error.localizedDescription
                                            importSuccessMessage = nil
                                        }
                                    }
                                }
                            }
                        }

                        if let msg = importSuccessMessage {
                            Text(msg)
                                .font(.caption)
                                .foregroundColor(Color(UIColor.systemGreen))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Private Key (PEM format)")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.comment)

                            TextEditor(text: $privateKey)
                                .font(.system(.caption, design: .monospaced))
                                .frame(height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(themeManager.currentTheme.editorForeground.opacity(0.2), lineWidth: 1)
                                )

                            SecureField("Key Passphrase (if encrypted)", text: $keyPassphrase)
                        }
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                
                Section {
                    Toggle("Save Connection", isOn: $saveConnection)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(Color(UIColor.systemRed))
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: connect) {
                        HStack {
                            Spacer()
                            if terminal.isConnecting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Connecting...")
                            } else {
                                Image(systemName: "network")
                                Text("Connect")
                            }
                            Spacer()
                        }
                    }
                    .disabled(host.isEmpty || username.isEmpty || terminal.isConnecting)
                }
            }
            .navigationTitle("SSH Connection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
    
    private func connectToSaved(_ config: SSHConnectionConfig) {
        terminal.connect(to: config)
        isPresented = false
    }
    
    private func connect() {
        errorMessage = nil
        
        let authMethod: SSHConnectionConfig.SSHAuthMethod
        if useKey {
            guard !privateKey.isEmpty else {
                errorMessage = "Please enter your private key"
                return
            }
            authMethod = .privateKey(key: privateKey, passphrase: keyPassphrase.isEmpty ? nil : keyPassphrase)
        } else {
            guard !password.isEmpty else {
                errorMessage = "Please enter your password"
                return
            }
            authMethod = .password(password)
        }
        
        let name = connectionName.isEmpty ? "\(username)@\(host)" : connectionName
        
        let config = SSHConnectionConfig(
            name: name,
            host: host,
            port: Int(port) ?? 22,
            username: username,
            authMethod: authMethod
        )
        
        if saveConnection {
            connectionStore.save(config)
        }
        
        terminal.connect(to: config)
        isPresented = false
    }
}

// MARK: - Models & Helpers (Legacy support)

@available(*, deprecated, message: "Use SSHConnectionConfig instead")
struct SSHConnection {
    let host: String
    let port: Int
    let username: String
    let password: String?
    let privateKey: String?
}

struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let type: LineType
    var isANSI: Bool = false
    var segments: [ANSIText.ANSISegment]? = nil
}

enum LineType {
    case command
    case output
    case error
    case system
    case prompt
}

struct ANSIText: View {
    let text: String
    let preParsedSegments: [ANSISegment]?
    @ObservedObject private var themeManager = ThemeManager.shared
    
    private static let ansiRegex: NSRegularExpression? = try? NSRegularExpression(pattern: "\u{1B}\\[([0-9;]*)([a-zA-Z])")
    private static let oscRegex: NSRegularExpression? = try? NSRegularExpression(pattern: "\u{1B}\\][^\u{07}\u{1B}]*(\u{07}|\u{1B}\\\\)")
    
    init(_ text: String, segments: [ANSISegment]? = nil) {
        self.text = text
        self.preParsedSegments = segments
    }
    
    var body: some View {
        Text(attributedText)
            .font(.system(.body, design: .monospaced))
            .textSelection(.enabled)
    }
    
    private var attributedText: AttributedString {
        let segments = preParsedSegments ?? parseANSI(text)
        var result = AttributedString()
        let defaultFG = themeManager.currentTheme.editorForeground
        
        for segment in segments {
            var attr = AttributedString(segment.text)
            attr.foregroundColor = segment.color ?? defaultFG
            
            if segment.bold && segment.italic {
                attr.font = .system(.body, design: .monospaced).bold().italic()
            } else if segment.bold {
                attr.font = .system(.body, design: .monospaced).bold()
            } else if segment.italic {
                attr.font = .system(.body, design: .monospaced).italic()
            }
            if segment.underline {
                attr.underlineStyle = .single
            }
            if let bgColor = segment.backgroundColor {
                attr.backgroundColor = bgColor
            }
            
            result.append(attr)
        }
        
        return result
    }
    
    struct ANSISegment {
        let text: String
        let color: Color?
        let backgroundColor: Color?
        let bold: Bool
        let italic: Bool
        let underline: Bool
    }
    
    private func parseANSI(_ input: String) -> [ANSISegment] {
        // First strip OSC sequences (terminal title changes, etc.)
        let cleanedInput = Self.oscRegex?.stringByReplacingMatches(in: input, range: NSRange(location: 0, length: (input as NSString).length), withTemplate: "") ?? input
        
        var segments: [ANSISegment] = []
        var currentColor: Color? = nil
        var currentBackgroundColor: Color? = nil
        var bold = false
        var italic = false
        var underline = false
        var reverseVideo = false
        guard let regex = Self.ansiRegex else {
            // Fallback: return plain text as single segment
            return [ANSISegment(text: cleanedInput, color: nil, backgroundColor: nil, bold: false, italic: false, underline: false)]
        }
        
        let nsInput = cleanedInput as NSString
        var lastEnd = 0
        let matches = regex.matches(in: cleanedInput, range: NSRange(location: 0, length: nsInput.length))
        
        for match in matches {
            let matchRange = match.range
            
            // Text before this escape
            if matchRange.location > lastEnd {
                let textRange = NSRange(location: lastEnd, length: matchRange.location - lastEnd)
                let text = nsInput.substring(with: textRange)
                if !text.isEmpty {
                    let fg = reverseVideo ? currentBackgroundColor : currentColor
                    let bg = reverseVideo ? currentColor : currentBackgroundColor
                    segments.append(ANSISegment(text: text, color: fg, backgroundColor: bg, bold: bold, italic: italic, underline: underline))
                }
            }
            
            // Parse the escape code
            let codes = nsInput.substring(with: match.range(at: 1))
            let command = nsInput.substring(with: match.range(at: 2))
            
            if command == "m" {
                let parts = codes.split(separator: ";").compactMap { Int($0) }
                var i = 0
                while i < (parts.isEmpty ? 1 : parts.count) {
                    let code = parts.isEmpty ? 0 : parts[i]
                    switch code {
                    case 0:  // Reset
                        currentColor = nil; currentBackgroundColor = nil; bold = false; italic = false; underline = false; reverseVideo = false
                    case 1: bold = true
                    case 2: bold = false  // Dim/faint - treat as un-bold
                    case 3: italic = true
                    case 4: underline = true
                    case 7: reverseVideo = true
                    case 9: underline = true  // Strikethrough - approximate with underline
                    case 22: bold = false
                    case 23: italic = false
                    case 24: underline = false
                    case 27: reverseVideo = false
                    case 29: underline = false  // Un-strikethrough
                    // Standard foreground colors (30-37)
                    case 30: currentColor = colorForANSI(0, bold: bold)
                    case 31: currentColor = colorForANSI(1, bold: bold)
                    case 32: currentColor = colorForANSI(2, bold: bold)
                    case 33: currentColor = colorForANSI(3, bold: bold)
                    case 34: currentColor = colorForANSI(4, bold: bold)
                    case 35: currentColor = colorForANSI(5, bold: bold)
                    case 36: currentColor = colorForANSI(6, bold: bold)
                    case 37: currentColor = colorForANSI(7, bold: bold)
                    case 39: currentColor = nil  // Default foreground
                    // Standard background colors (40-47)
                    case 40: currentBackgroundColor = colorForANSI(0, bold: false)
                    case 41: currentBackgroundColor = colorForANSI(1, bold: false)
                    case 42: currentBackgroundColor = colorForANSI(2, bold: false)
                    case 43: currentBackgroundColor = colorForANSI(3, bold: false)
                    case 44: currentBackgroundColor = colorForANSI(4, bold: false)
                    case 45: currentBackgroundColor = colorForANSI(5, bold: false)
                    case 46: currentBackgroundColor = colorForANSI(6, bold: false)
                    case 47: currentBackgroundColor = colorForANSI(7, bold: false)
                    case 49: currentBackgroundColor = nil  // Default background
                    // Bright foreground colors (90-97)
                    case 90: currentColor = colorForANSI(8, bold: bold)
                    case 91: currentColor = colorForANSI(9, bold: bold)
                    case 92: currentColor = colorForANSI(10, bold: bold)
                    case 93: currentColor = colorForANSI(11, bold: bold)
                    case 94: currentColor = colorForANSI(12, bold: bold)
                    case 95: currentColor = colorForANSI(13, bold: bold)
                    case 96: currentColor = colorForANSI(14, bold: bold)
                    case 97: currentColor = colorForANSI(15, bold: bold)
                    // Bright background colors (100-107)
                    case 100: currentBackgroundColor = colorForANSI(8, bold: false)
                    case 101: currentBackgroundColor = colorForANSI(9, bold: false)
                    case 102: currentBackgroundColor = colorForANSI(10, bold: false)
                    case 103: currentBackgroundColor = colorForANSI(11, bold: false)
                    case 104: currentBackgroundColor = colorForANSI(12, bold: false)
                    case 105: currentBackgroundColor = colorForANSI(13, bold: false)
                    case 106: currentBackgroundColor = colorForANSI(14, bold: false)
                    case 107: currentBackgroundColor = colorForANSI(15, bold: false)
                    // Extended color modes
                    case 38, 48:
                        // Handle 256-color and 24-bit true color
                        // Format: 38;5;N (256-color foreground) or 38;2;R;G;B (true color foreground)
                        // Format: 48;5;N (256-color background) or 48;2;R;G;B (true color background)
                        if i + 2 < parts.count {
                            let mode = parts[i + 1]
                            if mode == 5 && i + 3 <= parts.count {
                                // 256-color mode
                                let colorIndex = parts[i + 2]
                                let color = color256(colorIndex)
                                if code == 38 {
                                    currentColor = color
                                } else {
                                    currentBackgroundColor = color
                                }
                                i += 2
                            } else if mode == 2 && i + 5 <= parts.count {
                                // 24-bit true color (RGB)
                                let r = Double(parts[i + 2]) / 255.0
                                let g = Double(parts[i + 3]) / 255.0
                                let b = Double(parts[i + 4]) / 255.0
                                let color = Color(.sRGB, red: r, green: g, blue: b)
                                if code == 38 {
                                    currentColor = color
                                } else {
                                    currentBackgroundColor = color
                                }
                                i += 4
                            }
                        }
                    default: break
                    }
                    i += 1
                }
            } else {
                // Non-SGR CSI sequences (cursor movement, erase, etc.) - strip them
                // J=erase display, K=erase line, H/f=cursor position, A/B/C/D=cursor move
            }
            
            lastEnd = matchRange.location + matchRange.length
        }
        
        // Remaining text after last escape
        if lastEnd < nsInput.length {
            let text = nsInput.substring(from: lastEnd)
            if !text.isEmpty {
                let fg = reverseVideo ? currentBackgroundColor : currentColor
                let bg = reverseVideo ? currentColor : currentBackgroundColor
                segments.append(ANSISegment(text: text, color: fg, backgroundColor: bg, bold: bold, italic: italic, underline: underline))
            }
        }
        
        if segments.isEmpty {
            // Strip raw ANSI escape codes before showing as plaintext
            let stripped = input.replacingOccurrences(of: "\u{1B}\\[[0-9;]*[a-zA-Z]", with: "", options: .regularExpression)
            segments.append(ANSISegment(text: stripped.isEmpty ? " " : stripped, color: nil, backgroundColor: nil, bold: false, italic: false, underline: false))
        }
        
        return segments
        }
        
        /// Parse ANSI with initial state and return final state for cross-line persistence
        static func parseANSIWithState(
            _ input: String,
            initialColor: Color? = nil,
            initialBgColor: Color? = nil,
            initialBold: Bool = false,
            initialItalic: Bool = false,
            initialUnderline: Bool = false,
            initialReverseVideo: Bool = false
        ) -> (segments: [ANSISegment], finalColor: Color?, finalBgColor: Color?, finalBold: Bool, finalItalic: Bool, finalUnderline: Bool, finalReverseVideo: Bool) {
            // First strip OSC sequences (terminal title changes, etc.)
            let cleanedInput = oscRegex?.stringByReplacingMatches(in: input, range: NSRange(location: 0, length: (input as NSString).length), withTemplate: "") ?? input
            
            var segments: [ANSISegment] = []
            var currentColor: Color? = initialColor
            var currentBackgroundColor: Color? = initialBgColor
            var bold = initialBold
            var italic = initialItalic
            var underline = initialUnderline
            var reverseVideo = initialReverseVideo
            guard let regex = ansiRegex else {
                // Fallback: return plain text as single segment with current state
                return ([ANSISegment(text: cleanedInput, color: currentColor, backgroundColor: currentBackgroundColor, bold: bold, italic: italic, underline: underline)],
                        currentColor, currentBackgroundColor, bold, italic, underline, reverseVideo)
            }
            
            let nsInput = cleanedInput as NSString
            var lastEnd = 0
            let matches = regex.matches(in: cleanedInput, range: NSRange(location: 0, length: nsInput.length))
            
            for match in matches {
                let matchRange = match.range
                
                // Text before this escape
                if matchRange.location > lastEnd {
                    let textRange = NSRange(location: lastEnd, length: matchRange.location - lastEnd)
                    let text = nsInput.substring(with: textRange)
                    if !text.isEmpty {
                        let fg = reverseVideo ? currentBackgroundColor : currentColor
                        let bg = reverseVideo ? currentColor : currentBackgroundColor
                        segments.append(ANSISegment(text: text, color: fg, backgroundColor: bg, bold: bold, italic: italic, underline: underline))
                    }
                }
                
                // Parse the escape code
                let codes = nsInput.substring(with: match.range(at: 1))
                let command = nsInput.substring(with: match.range(at: 2))
                
                if command == "m" {
                    let parts = codes.split(separator: ";").compactMap { Int($0) }
                    var i = 0
                    while i < (parts.isEmpty ? 1 : parts.count) {
                        let code = parts.isEmpty ? 0 : parts[i]
                        switch code {
                        case 0:  // Reset
                            currentColor = nil; currentBackgroundColor = nil; bold = false; italic = false; underline = false; reverseVideo = false
                        case 1: bold = true
                        case 2: bold = false  // Dim/faint - treat as un-bold
                        case 3: italic = true
                        case 4: underline = true
                        case 7: reverseVideo = true
                        case 9: underline = true  // Strikethrough - approximate with underline
                        case 22: bold = false
                        case 23: italic = false
                        case 24: underline = false
                        case 27: reverseVideo = false
                        case 29: underline = false  // Un-strikethrough
                        // Standard foreground colors (30-37)
                        case 30: currentColor = Self.colorForANSIStatic(0, bold: bold)
                        case 31: currentColor = Self.colorForANSIStatic(1, bold: bold)
                        case 32: currentColor = Self.colorForANSIStatic(2, bold: bold)
                        case 33: currentColor = Self.colorForANSIStatic(3, bold: bold)
                        case 34: currentColor = Self.colorForANSIStatic(4, bold: bold)
                        case 35: currentColor = Self.colorForANSIStatic(5, bold: bold)
                        case 36: currentColor = Self.colorForANSIStatic(6, bold: bold)
                        case 37: currentColor = Self.colorForANSIStatic(7, bold: bold)
                        case 39: currentColor = nil  // Default foreground
                        // Standard background colors (40-47)
                        case 40: currentBackgroundColor = Self.colorForANSIStatic(0, bold: false)
                        case 41: currentBackgroundColor = Self.colorForANSIStatic(1, bold: false)
                        case 42: currentBackgroundColor = Self.colorForANSIStatic(2, bold: false)
                        case 43: currentBackgroundColor = Self.colorForANSIStatic(3, bold: false)
                        case 44: currentBackgroundColor = Self.colorForANSIStatic(4, bold: false)
                        case 45: currentBackgroundColor = Self.colorForANSIStatic(5, bold: false)
                        case 46: currentBackgroundColor = Self.colorForANSIStatic(6, bold: false)
                        case 47: currentBackgroundColor = Self.colorForANSIStatic(7, bold: false)
                        case 49: currentBackgroundColor = nil  // Default background
                        // Bright foreground colors (90-97)
                        case 90: currentColor = Self.colorForANSIStatic(8, bold: bold)
                        case 91: currentColor = Self.colorForANSIStatic(9, bold: bold)
                        case 92: currentColor = Self.colorForANSIStatic(10, bold: bold)
                        case 93: currentColor = Self.colorForANSIStatic(11, bold: bold)
                        case 94: currentColor = Self.colorForANSIStatic(12, bold: bold)
                        case 95: currentColor = Self.colorForANSIStatic(13, bold: bold)
                        case 96: currentColor = Self.colorForANSIStatic(14, bold: bold)
                        case 97: currentColor = Self.colorForANSIStatic(15, bold: bold)
                        // Bright background colors (100-107)
                        case 100: currentBackgroundColor = Self.colorForANSIStatic(8, bold: false)
                        case 101: currentBackgroundColor = Self.colorForANSIStatic(9, bold: false)
                        case 102: currentBackgroundColor = Self.colorForANSIStatic(10, bold: false)
                        case 103: currentBackgroundColor = Self.colorForANSIStatic(11, bold: false)
                        case 104: currentBackgroundColor = Self.colorForANSIStatic(12, bold: false)
                        case 105: currentBackgroundColor = Self.colorForANSIStatic(13, bold: false)
                        case 106: currentBackgroundColor = Self.colorForANSIStatic(14, bold: false)
                        case 107: currentBackgroundColor = Self.colorForANSIStatic(15, bold: false)
                        // Extended color modes
                        case 38, 48:
                            // Handle 256-color and 24-bit true color
                            // Format: 38;5;N (256-color foreground) or 38;2;R;G;B (true color foreground)
                            // Format: 48;5;N (256-color background) or 48;2;R;G;B (true color background)
                            if i + 2 < parts.count {
                                let mode = parts[i + 1]
                                if mode == 5 && i + 3 <= parts.count {
                                    // 256-color mode
                                    let colorIndex = parts[i + 2]
                                    let color = Self.color256Static(colorIndex)
                                    if code == 38 {
                                        currentColor = color
                                    } else {
                                        currentBackgroundColor = color
                                    }
                                    i += 2
                                } else if mode == 2 && i + 5 <= parts.count {
                                    // 24-bit true color (RGB)
                                    let r = Double(parts[i + 2]) / 255.0
                                    let g = Double(parts[i + 3]) / 255.0
                                    let b = Double(parts[i + 4]) / 255.0
                                    let color = Color(.sRGB, red: r, green: g, blue: b)
                                    if code == 38 {
                                        currentColor = color
                                    } else {
                                        currentBackgroundColor = color
                                    }
                                    i += 4
                                }
                            }
                        default: break
                        }
                        i += 1
                    }
                } else {
                    // Non-SGR CSI sequences (cursor movement, erase, etc.) - strip them
                    // J=erase display, K=erase line, H/f=cursor position, A/B/C/D=cursor move
                }
                
                lastEnd = matchRange.location + matchRange.length
            }
            
            // Remaining text after last escape
            if lastEnd < nsInput.length {
                let text = nsInput.substring(from: lastEnd)
                if !text.isEmpty {
                    let fg = reverseVideo ? currentBackgroundColor : currentColor
                    let bg = reverseVideo ? currentColor : currentBackgroundColor
                    segments.append(ANSISegment(text: text, color: fg, backgroundColor: bg, bold: bold, italic: italic, underline: underline))
                }
            }
            
            if segments.isEmpty {
                // Strip raw ANSI escape codes before showing as plaintext
                let stripped = input.replacingOccurrences(of: "\u{1B}\\[[0-9;]*[a-zA-Z]", with: "", options: .regularExpression)
                segments.append(ANSISegment(text: stripped.isEmpty ? " " : stripped, color: initialColor, backgroundColor: initialBgColor, bold: initialBold, italic: initialItalic, underline: initialUnderline))
            }
            
            return (segments, currentColor, currentBackgroundColor, bold, italic, underline, reverseVideo)
        }
        
        /// Static version of colorForANSI for use in static parseANSIWithState
        private static func colorForANSIStatic(_ index: Int, bold: Bool) -> Color {
            let standardColors: [Color] = [
                Color(.sRGB, red: 0.0, green: 0.0, blue: 0.0),       // 0: Black
                Color(.sRGB, red: 0.8, green: 0.0, blue: 0.0),       // 1: Red
                Color(.sRGB, red: 0.0, green: 0.8, blue: 0.0),       // 2: Green
                Color(.sRGB, red: 0.8, green: 0.8, blue: 0.0),       // 3: Yellow
                Color(.sRGB, red: 0.0, green: 0.0, blue: 0.8),       // 4: Blue
                Color(.sRGB, red: 0.8, green: 0.0, blue: 0.8),       // 5: Magenta
                Color(.sRGB, red: 0.0, green: 0.8, blue: 0.8),       // 6: Cyan
                Color(.sRGB, red: 0.8, green: 0.8, blue: 0.8),       // 7: White
            ]
            
            let brightColors: [Color] = [
                Color(.sRGB, red: 0.4, green: 0.4, blue: 0.4),       // 8: Bright Black (Gray)
                Color(.sRGB, red: 1.0, green: 0.0, blue: 0.0),       // 9: Bright Red
                Color(.sRGB, red: 0.0, green: 1.0, blue: 0.0),       // 10: Bright Green
                Color(.sRGB, red: 1.0, green: 1.0, blue: 0.0),       // 11: Bright Yellow
                Color(.sRGB, red: 0.0, green: 0.0, blue: 1.0),       // 12: Bright Blue
                Color(.sRGB, red: 1.0, green: 0.0, blue: 1.0),       // 13: Bright Magenta
                Color(.sRGB, red: 0.0, green: 1.0, blue: 1.0),       // 14: Bright Cyan
                Color(.sRGB, red: 1.0, green: 1.0, blue: 1.0),       // 15: Bright White
            ]
            
            if index < 8 {
                return bold ? brightColors[index] : standardColors[index]
            } else {
                return brightColors[index - 8]
            }
        }
        
        /// Static version of color256 for use in static parseANSIWithState
        private static func color256Static(_ index: Int) -> Color {
            guard index >= 0 && index < 256 else { return .white }
            
            // 0-15: Standard ANSI colors (same as colorForANSI)
            if index < 16 {
                return colorForANSIStatic(index, bold: false)
            }
            
            // 16-231: 216-color cube (6x6x6 RGB)
            if index < 232 {
                let i = index - 16
                let r = (i / 36) % 6
                let g = (i / 6) % 6
                let b = i % 6
                
                let red = r == 0 ? 0.0 : (Double(r) * 40.0 + 55.0) / 255.0
                let green = g == 0 ? 0.0 : (Double(g) * 40.0 + 55.0) / 255.0
                let blue = b == 0 ? 0.0 : (Double(b) * 40.0 + 55.0) / 255.0
                
                return Color(.sRGB, red: red, green: green, blue: blue)
            }
            
            // 232-255: Grayscale (24 shades)
            let gray = (Double(index - 232) * 10.0 + 8.0) / 255.0
            return Color(.sRGB, red: gray, green: gray, blue: gray)
        }
    
    /// Returns the standard 16 ANSI colors (0-15)
    /// Index 0-7: standard colors, 8-15: bright variants
    private func colorForANSI(_ index: Int, bold: Bool) -> Color {
        let standardColors: [Color] = [
            Color(.sRGB, red: 0.0, green: 0.0, blue: 0.0),       // 0: Black
            Color(.sRGB, red: 0.8, green: 0.0, blue: 0.0),       // 1: Red
            Color(.sRGB, red: 0.0, green: 0.8, blue: 0.0),       // 2: Green
            Color(.sRGB, red: 0.8, green: 0.8, blue: 0.0),       // 3: Yellow
            Color(.sRGB, red: 0.0, green: 0.0, blue: 0.8),       // 4: Blue
            Color(.sRGB, red: 0.8, green: 0.0, blue: 0.8),       // 5: Magenta
            Color(.sRGB, red: 0.0, green: 0.8, blue: 0.8),       // 6: Cyan
            Color(.sRGB, red: 0.8, green: 0.8, blue: 0.8),       // 7: White
        ]
        
        let brightColors: [Color] = [
            Color(.sRGB, red: 0.4, green: 0.4, blue: 0.4),       // 8: Bright Black (Gray)
            Color(.sRGB, red: 1.0, green: 0.0, blue: 0.0),       // 9: Bright Red
            Color(.sRGB, red: 0.0, green: 1.0, blue: 0.0),       // 10: Bright Green
            Color(.sRGB, red: 1.0, green: 1.0, blue: 0.0),       // 11: Bright Yellow
            Color(.sRGB, red: 0.0, green: 0.0, blue: 1.0),       // 12: Bright Blue
            Color(.sRGB, red: 1.0, green: 0.0, blue: 1.0),       // 13: Bright Magenta
            Color(.sRGB, red: 0.0, green: 1.0, blue: 1.0),       // 14: Bright Cyan
            Color(.sRGB, red: 1.0, green: 1.0, blue: 1.0),       // 15: Bright White
        ]
        
        if index < 8 {
            return bold ? brightColors[index] : standardColors[index]
        } else {
            return brightColors[index - 8]
        }
    }
    
    /// Returns a color from the 256-color palette
    /// - Parameter index: Color index (0-255)
    /// - Returns: The corresponding Color
    private func color256(_ index: Int) -> Color {
        guard index >= 0 && index < 256 else { return .white }
        
        // 0-15: Standard ANSI colors (same as colorForANSI)
        if index < 16 {
            return colorForANSI(index, bold: false)
        }
        
        // 16-231: 216-color cube (6x6x6 RGB)
        if index < 232 {
            let i = index - 16
            let r = (i / 36) % 6
            let g = (i / 6) % 6
            let b = i % 6
            
            let red = r == 0 ? 0.0 : (Double(r) * 40.0 + 55.0) / 255.0
            let green = g == 0 ? 0.0 : (Double(g) * 40.0 + 55.0) / 255.0
            let blue = b == 0 ? 0.0 : (Double(b) * 40.0 + 55.0) / 255.0
            
            return Color(.sRGB, red: red, green: green, blue: blue)
        }
        
        // 232-255: Grayscale (24 shades)
        let gray = (Double(index - 232) * 10.0 + 8.0) / 255.0
        return Color(.sRGB, red: gray, green: gray, blue: gray)
    }
}


// MARK: - Scroll Preference Key
struct ScrollOffsetKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - SSH Client Implementation
// Real SSH implementation is now in Services/SSHManager.swift
// Uses SwiftNIO SSH (apple/swift-nio-ssh) for proper SSH protocol support
// Features:
// - Password authentication
// - SSH key authentication (Ed25519, ECDSA)
// - PTY allocation for interactive shells
// - Proper channel management
// - Terminal resize support
