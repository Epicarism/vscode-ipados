import SwiftUI

struct StatusBarView: View {
    @ObservedObject var editorCore: EditorCore
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject private var git = GitManager.shared

    @State private var showGitSheet = false

    var theme: Theme { themeManager.currentTheme }

    var body: some View {
        HStack(spacing: 0) {
            // Left side items
            HStack(spacing: 0) {
                // Branch
                StatusBarItem(text: git.currentBranch, icon: "arrow.triangle.branch", theme: theme) {
                    showGitSheet = true
                }

                // Pull button with behind count
                StatusBarItem(text: git.behindCount > 0 ? String(git.behindCount) : "", icon: "arrow.down.to.line", theme: theme) {
                    guard !git.isLoading else { return }
                    Task { try? await git.pull() }
                }

                // Push button with ahead count
                StatusBarItem(text: git.aheadCount > 0 ? String(git.aheadCount) : "", icon: "arrow.up.to.line", theme: theme) {
                    guard !git.isLoading else { return }
                    Task { try? await git.push() }
                }

                // Stash indicator
                StatusBarItem(text: git.stashes.isEmpty ? "" : String(git.stashes.count), icon: "archivebox", theme: theme) {
                    showGitSheet = true
                }

                StatusBarItem(text: "0", icon: "xmark.circle.fill", theme: theme) {
                    // Future: Show problems
                }

                StatusBarItem(text: "0", icon: "exclamationmark.triangle.fill", theme: theme) {
                    // Future: Show warnings
                }
            }

            Spacer()

            // Right side items
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

                // Cursor Position
                StatusBarItem(text: "Ln \(editorCore.cursorPosition.line + 1), Col \(editorCore.cursorPosition.column + 1)", theme: theme) {
                    editorCore.showGoToLine = true
                }

                // Indentation
                StatusBarItem(text: "Spaces: 4", theme: theme) {
                    // Future: Change indentation
                }

                // Encoding
                StatusBarItem(text: "UTF-8", theme: theme) {
                    // Future: Change encoding
                }

                // EOL
                StatusBarItem(text: "LF", theme: theme) {
                    // Future: Change EOL
                }

                // Language
                if let tab = editorCore.activeTab {
                    StatusBarItem(text: tab.language.displayName, theme: theme) {
                        // Future: Change Language Mode
                    }

                    // Feedback / Notification bell
                    StatusBarItem(text: "", icon: "bell", theme: theme) {
                        // Future: Notifications
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .frame(height: 22)
        .background(theme.statusBarBackground)
        .foregroundColor(theme.statusBarForeground)
        .font(.system(size: 11))
        .sheet(isPresented: $showGitSheet) {
            GitQuickActionsView()
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
            .background(isHovering ? Color.white.opacity(0.12) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
