import SwiftUI

struct StatusBarView: View {
    @ObservedObject var editorCore: EditorCore
    @ObservedObject var themeManager = ThemeManager.shared
    @StateObject private var git = GitManager.shared

    // Sheet / popover state
    @State private var showGitSheet = false
    @State private var showNotificationCenter = false

    // Editor settings (persisted via AppStorage)
    @AppStorage("editor.tabSize") private var tabSize: Int = 4
    @AppStorage("editor.insertSpaces") private var insertSpaces: Bool = true
    @AppStorage("editor.encoding") private var encoding: String = "UTF-8"
    @AppStorage("editor.eol") private var eolSetting: String = "LF"

    @StateObject private var notifications = NotificationManager.shared

    var theme: Theme { themeManager.currentTheme }

    // MARK: - Computed helpers

    /// True when we have at least one tab open (controls right-side visibility).
    private var hasActiveTab: Bool { editorCore.activeTab != nil }

    /// Whether there are git sync-related changes to surface.
    private var hasGitSyncActivity: Bool {
        git.aheadCount > 0 || git.behindCount > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Subtle separator line at top (matches VSCode)
            Rectangle()
                .fill(theme.statusBarForeground.opacity(0.15))
                .frame(height: CGFloat(1) / UIScreen.main.scale)  // hairline

            HStack(spacing: 0) {
                // ── Left side ──────────────────────────────────────────
                leftSide

                Spacer()

                // ── Right side ─────────────────────────────────────────
                if hasActiveTab {
                    rightSide
                }
            }
            .padding(.horizontal, 4)
            .frame(height: 22)
            .background(theme.statusBarBackground)
            .foregroundColor(theme.statusBarForeground)
            .font(.system(size: 11))
        }
        .sheet(isPresented: $showGitSheet) {
            GitQuickActionsView()
        }
    }

    // MARK: - Left Side

    @ViewBuilder
    private var leftSide: some View {
        HStack(spacing: 0) {
            // Git branch
            if git.isRepository {
                StatusBarItem(
                    text: git.currentBranch,
                    icon: hasGitSyncActivity ? "arrow.triangle.2.circlepath" : "arrow.triangle.branch",
                    theme: theme
                ) {
                    showGitSheet = true
                }
                .accessibilityLabel("Git branch: \(git.currentBranch)")
                .accessibilityHint("Double tap to show Git actions")
                .accessibilityIdentifier("statusBar.branch")
            }

            // SSH Connection Status
            SSHStatusIndicator(theme: theme) {
                editorCore.focusedView = .explorer
                editorCore.focusedSidebarTab = 4
                withAnimation { editorCore.showSidebar = true }
            }
            
            // Errors & Warnings (Problems)
            let errorCount = editorCore.diagnosticErrorCount
            let warningCount = editorCore.diagnosticWarningCount

            if errorCount == 0 && warningCount == 0 {
                StatusBarItem(
                    text: "",
                    icon: "checkmark.circle.fill",
                    theme: theme
                ) {
                    editorCore.focusedView = .explorer
                    editorCore.focusedSidebarTab = 0
                    withAnimation { editorCore.showSidebar = true }
                }
                .accessibilityLabel("No problems")
                .accessibilityHint("Double tap to view problems panel")
                .foregroundColor(.green)
            } else {
                if errorCount > 0 {
                    StatusBarItem(
                        text: "\(errorCount)",
                        icon: "xmark.circle.fill",
                        theme: theme
                    ) {
                        editorCore.focusedView = .explorer
                        editorCore.focusedSidebarTab = 0
                        withAnimation { editorCore.showSidebar = true }
                    }
                    .accessibilityLabel("Errors, \(errorCount)")
                    .accessibilityHint("Double tap to view errors")
                    .accessibilityIdentifier("statusBar.errors")
                }

                if warningCount > 0 {
                    StatusBarItem(
                        text: "\(warningCount)",
                        icon: "exclamationmark.triangle.fill",
                        theme: theme
                    ) {
                        editorCore.focusedView = .explorer
                        editorCore.focusedSidebarTab = 0
                        withAnimation { editorCore.showSidebar = true }
                    }
                    .accessibilityLabel("Warnings, \(warningCount)")
                    .accessibilityHint("Double tap to view warnings")
                    .accessibilityIdentifier("statusBar.warnings")
                }
            }
        }
    }

    // MARK: - Right Side

    @ViewBuilder
    private var rightSide: some View {
        HStack(spacing: 0) {
            // Multi-cursor indicator
            if editorCore.multiCursorState.isMultiCursor {
                StatusBarItem(
                    text: "\(editorCore.multiCursorState.cursors.count) cursors",
                    icon: "text.cursor",
                    theme: theme
                ) {
                    editorCore.escapeMultiCursor()
                }
                .accessibilityLabel("\(editorCore.multiCursorState.cursors.count) cursors active")
                .accessibilityHint("Double tap to exit multi-cursor mode")
            }

            // Cursor position → click opens Go to Line
            StatusBarItem(
                text: "Ln \(editorCore.cursorPosition.line + 1), Col \(editorCore.cursorPosition.column + 1)",
                theme: theme
            ) {
                editorCore.showGoToLine = true
            }
            .accessibilityLabel("Line \(editorCore.cursorPosition.line + 1), Column \(editorCore.cursorPosition.column + 1)")
            .accessibilityHint("Double tap to go to line")
            .accessibilityIdentifier("statusBar.cursorPosition")

            // Indentation (Spaces / Tab size)
            Menu {
                Section("Indent Using") {
                    Button(insertSpaces ? "✓ Spaces" : "  Spaces") { insertSpaces = true }
                    Button(!insertSpaces ? "✓ Tabs" : "  Tabs") { insertSpaces = false }
                }
                Section("Tab Size") {
                    ForEach([2, 4, 6, 8], id: \.self) { size in
                        Button(tabSize == size ? "✓ \(size)" : "  \(size)") { tabSize = size }
                    }
                }
            } label: {
                StatusBarLabel(text: "\(insertSpaces ? "Spaces" : "Tab Size"): \(tabSize)", theme: theme)
            }
            .accessibilityLabel("Indentation: \(insertSpaces ? "Spaces" : "Tabs"), size \(tabSize)")
            .accessibilityHint("Double tap to change indentation settings")

            // Encoding
            Menu {
                ForEach(["UTF-8", "UTF-16", "ASCII", "ISO-8859-1", "Windows-1252", "Shift_JIS", "EUC-KR", "GB2312"], id: \.self) { enc in
                    Button(encoding == enc ? "✓ \(enc)" : "  \(enc)") { encoding = enc }
                }
            } label: {
                StatusBarLabel(text: encoding, theme: theme)
            }
            .accessibilityLabel("File Encoding: \(encoding)")
            .accessibilityHint("Double tap to change file encoding")
            .accessibilityIdentifier("statusBar.encoding")

            // EOL
            Menu {
                Button(eolSetting == "LF" ? "✓ LF (Unix)" : "  LF (Unix)") { eolSetting = "LF" }
                Button(eolSetting == "CRLF" ? "✓ CRLF (Windows)" : "  CRLF (Windows)") { eolSetting = "CRLF" }
                Button(eolSetting == "CR" ? "✓ CR (Classic Mac)" : "  CR (Classic Mac)") { eolSetting = "CR" }
            } label: {
                StatusBarLabel(text: eolSetting, theme: theme)
            }
            .accessibilityLabel("End of Line: \(eolSetting)")
            .accessibilityHint("Double tap to change end of line setting")

            // Language Mode
            if let tab = editorCore.activeTab {
                Menu {
                    Section("Select Language Mode") {
                        ForEach(CodeLanguage.allCases, id: \.self) { lang in
                            Button(action: {
                                editorCore.changeLanguage(to: lang)
                            }) {
                                HStack {
                                    Text(lang.displayName)
                                    if tab.language == lang {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    StatusBarLabel(text: tab.language.displayName, theme: theme)
                }
                .accessibilityLabel("Language Mode: \(tab.language.displayName)")
                .accessibilityHint("Double tap to change language mode")
                .accessibilityIdentifier("statusBar.language")
            }

            // Notification bell with unread badge
            ZStack(alignment: .topTrailing) {
                StatusBarItem(text: "", icon: "bell", theme: theme) {
                    showNotificationCenter.toggle()
                    notifications.markAllRead()
                }
                .accessibilityLabel("Notifications\(notifications.unreadCount > 0 ? ", \(notifications.unreadCount) unread" : "")")
                .accessibilityHint("Double tap to show notifications")
                .accessibilityIdentifier("statusBar.notifications")
                if notifications.unreadCount > 0 {
                    Text("\(min(notifications.unreadCount, 99))")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(.systemBackground))
                        .padding(.horizontal, 3)
                        .padding(.vertical, 1)
                        .background(Color.accentColor)
                        .cornerRadius(6)
                        .offset(x: -2, y: 2)
                }
            }
            .popover(isPresented: $showNotificationCenter) {
                NotificationCenterView(manager: notifications)
            }

            // App version (subtle, far right)
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("v\(version)")
                    .font(.system(size: 9))
                    .foregroundColor(theme.statusBarForeground.opacity(0.45))
                    .padding(.horizontal, 6)
                    .accessibilityLabel("Version \(version)")
            }
        }
    }
}




struct StatusBarItem: View {
    var text: String
    var icon: String? = nil
    var theme: Theme
    var action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                if !text.isEmpty {
                    Text(text)
                }
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity)
            .background(isHovering ? theme.statusBarForeground.opacity(0.12) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Non-interactive Label (used as Menu label)

/// Non-interactive label for use as Menu label in status bar
struct StatusBarLabel: View {
    var text: String
    var icon: String? = nil
    var theme: Theme

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }
            if !text.isEmpty {
                Text(text)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background(isHovering ? theme.statusBarForeground.opacity(0.12) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}

// MARK: - SSH Status Indicator

struct SSHStatusIndicator: View {
    let theme: Theme
    let action: () -> Void
    
    @ObservedObject private var connectionStore = SSHConnectionStore.shared
    @State private var isHovering = false
    
    private var activeConnection: SSHConnectionConfig? {
        connectionStore.savedConnections.first { connection in
            // In a real implementation, track active connections
            // For now, show the most recently used
            connection.lastUsed != nil
        }
    }
    
    private var displayText: String {
        if let connection = activeConnection {
            return connection.name
        } else {
            return "SSH: No Remote"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: activeConnection != nil ? "server.rack" : "circle")
                    .font(.system(size: 10))
                    .foregroundColor(activeConnection != nil ? .green : theme.statusBarForeground.opacity(0.6))
                
                Text(displayText)
                    .font(.system(size: 11))
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity)
            .background(isHovering ? theme.statusBarForeground.opacity(0.12) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
        .accessibilityLabel(displayText)
        .accessibilityHint("Double tap to manage SSH connections")
    }
}
