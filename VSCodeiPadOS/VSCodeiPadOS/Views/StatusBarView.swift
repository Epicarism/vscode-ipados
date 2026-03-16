import SwiftUI

struct StatusBarView: View {
    @ObservedObject var editorCore: EditorCore
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject private var git = GitManager.shared

    // Sheet / popover state
    @State private var showGitSheet = false
    @State private var showNotificationCenter = false

    // Editor settings (persisted via AppStorage)
    @AppStorage("editor.tabSize") private var tabSize: Int = 4
    @AppStorage("editor.insertSpaces") private var insertSpaces: Bool = true
    @AppStorage("editor.encoding") private var encoding: String = "UTF-8"
    @AppStorage("editor.eol") private var eolSetting: String = "LF"

    @ObservedObject private var notifications = NotificationManager.shared

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
                .frame(height: 1 / UIScreen.main.scale)  // hairline

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
            }

            // Errors & Warnings ( Problems )
            StatusBarItem(
                text: "0",
                icon: "xmark.circle.fill",
                theme: theme
            ) {
                editorCore.focusedView = .explorer
                editorCore.focusedSidebarTab = 0
                withAnimation { editorCore.showSidebar = true }
            }
            .accessibilityLabel("Errors, 0")
            .accessibilityHint("Double tap to view errors")

            StatusBarItem(

            StatusBarItem(
                text: "0",
                icon: "exclamationmark.triangle.fill",
                theme: theme
            ) {
                editorCore.focusedView = .explorer
                editorCore.focusedSidebarTab = 0
                withAnimation { editorCore.showSidebar = true }
            }
            .accessibilityLabel("Warnings, 0")
            .accessibilityHint("Double tap to view warnings")
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
            }

            // Cursor position → click opens Go to Line
            StatusBarItem(
                text: "Ln \(editorCore.cursorPosition.line + 1), Col \(editorCore.cursorPosition.column + 1)",
                theme: theme
            ) {
                editorCore.showGoToLine = true
            }

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

            // Encoding
            Menu {
                ForEach(["UTF-8", "UTF-16", "ASCII", "ISO-8859-1", "Windows-1252", "Shift_JIS", "EUC-KR", "GB2312"], id: \.self) { enc in
                    Button(encoding == enc ? "✓ \(enc)" : "  \(enc)") { encoding = enc }
                }
            } label: {
                StatusBarLabel(text: encoding, theme: theme)
            }

            // EOL
            Menu {
                Button(eolSetting == "LF" ? "✓ LF (Unix)" : "  LF (Unix)") { eolSetting = "LF" }
                Button(eolSetting == "CRLF" ? "✓ CRLF (Windows)" : "  CRLF (Windows)") { eolSetting = "CRLF" }
                Button(eolSetting == "CR" ? "✓ CR (Classic Mac)" : "  CR (Classic Mac)") { eolSetting = "CR" }
            } label: {
                StatusBarLabel(text: eolSetting, theme: theme)
            }

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
            }

            // Notification bell with unread badge
            ZStack(alignment: .topTrailing) {
                StatusBarItem(text: "", icon: "bell", theme: theme) {
                    showNotificationCenter.toggle()
                    notifications.markAllRead()
                }
                .accessibilityLabel("Notifications\(notifications.unreadCount > 0 ? ", \(notifications.unreadCount) unread" : "")")
                .accessibilityHint("Double tap to show notifications")
                if notifications.unreadCount > 0 {
                    Text("\(min(notifications.unreadCount, 99))")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
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
        }
    }
}

// MARK: - Clickable Status Bar Item

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
            .background(isHovering ? Color.white.opacity(0.12) : Color.clear)
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
        .background(isHovering ? Color.white.opacity(0.12) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}
