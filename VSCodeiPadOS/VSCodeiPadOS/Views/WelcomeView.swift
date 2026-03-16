import SwiftUI

// MARK: - WelcomeView

/// A polished, VS Code–style welcome screen shown on startup.
/// Integrates via `.environmentObject(themeManager)` and stores
/// the "show on startup" preference in `@AppStorage`.
struct WelcomeView: View {

    // ── Theme ──────────────────────────────────────────────
    @EnvironmentObject var themeManager: ThemeManager

    // ── Preferences ────────────────────────────────────────
    @AppStorage("showWelcomeOnStartup") private var showWelcomeOnStartup = true

    // ── Callbacks (optional – caller can wire these up) ────
    var onOpenFolder: (() -> Void)?
    var onOpenFile: (() -> Void)?
    var onNewFile: (() -> Void)?

    // ── Local state ────────────────────────────────────────
    @State private var hoveredAction: String? = nil

    private var theme: Theme { themeManager.currentTheme }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Header ─────────────────────────────────
                header
                    .padding(.top, 40)
                    .padding(.bottom, 28)

                Divider()
                    .background(theme.sidebarSectionHeader)

                // ── Start ──────────────────────────────────
                sectionHeader("Start")
                startSection
                    .padding(.bottom, 24)

                // ── Recent Files ───────────────────────────
                Divider()
                    .background(theme.sidebarSectionHeader)
                sectionHeader("Recent Files")
                recentFilesSection
                    .padding(.bottom, 24)

                // ── Learn ──────────────────────────────────
                Divider()
                    .background(theme.sidebarSectionHeader)
                sectionHeader("Learn")
                learnSection
                    .padding(.bottom, 28)

                Divider()
                    .background(theme.sidebarSectionHeader)

                // ── Show on startup toggle ─────────────────
                toggleSection
                    .padding(.vertical, 16)
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.editorBackground)
        .foregroundColor(theme.sidebarForeground)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 38, weight: .thin))
                .foregroundColor(theme.keyword)

            VStack(alignment: .leading, spacing: 4) {
                Text("CodePad")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundColor(theme.sidebarForeground)

                Text("Code editing. Redefined.")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(theme.lineNumber)
            }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold, design: .default))
            .foregroundColor(theme.sidebarForeground)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.top, 18)
            .padding(.bottom, 10)
    }

    // MARK: - Start Section

    private var startSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            actionRow(
                icon: "folder",
                title: "Open Folder…",
                subtitle: "Open a folder to browse its contents",
                actionKey: "folder"
            ) {
                onOpenFolder?()
            }

            actionRow(
                icon: "doc",
                title: "Open File…",
                subtitle: "Open a single file for editing",
                actionKey: "file"
            ) {
                onOpenFile?()
            }

            actionRow(
                icon: "doc.badge.plus",
                title: "New File",
                subtitle: "Create a new untitled file",
                actionKey: "newFile"
            ) {
                onNewFile?()
            }
        }
    }

    // MARK: - Recent Files Section

    private var recentFilesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 13))
                    .foregroundColor(theme.lineNumber)

                Text("No recent files")
                    .font(.system(size: 14))
                    .foregroundColor(theme.lineNumber)
            }
            .padding(.vertical, 8)

            Text("Files you open will appear here for quick access.")
                .font(.system(size: 12))
                .foregroundColor(theme.lineNumber)
        }
    }

    // MARK: - Learn Section

    private var learnSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            actionRow(
                icon: "keyboard",
                title: "Keyboard Shortcuts",
                subtitle: "View all available keyboard shortcuts",
                actionKey: "shortcuts"
            ) {
                NotificationCenter.default.post(name: .showKeyboardShortcuts, object: nil)
            }

            actionRow(
                icon: "book",
                title: "Documentation",
                subtitle: "Browse CodePad documentation",
                actionKey: "docs"
            ) {
                if let url = URL(string: "https://code.visualstudio.com/docs") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    // MARK: - Toggle Section

    private var toggleSection: some View {
        Toggle(isOn: $showWelcomeOnStartup) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Show Welcome on Startup")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(theme.sidebarForeground)

                Text("Display this page when the app launches")
                    .font(.system(size: 12))
                    .foregroundColor(theme.lineNumber)
            }
        }
        .tint(theme.statusBarBackground)
        .toggleStyle(.switch)
        .accessibilityLabel("Show Welcome on Startup")
        .accessibilityHint("Double tap to toggle whether this page shows on launch")
    }

    // MARK: - Action Row (reusable button-like row)

    private func actionRow(
        icon: String,
        title: String,
        subtitle: String,
        actionKey: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(theme.activityBarForeground)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(hoveredAction == actionKey
                                  ? theme.sidebarSelection
                                  : theme.sidebarSectionHeader)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(theme.sidebarForeground)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(theme.lineNumber)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.lineNumber)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(hoveredAction == actionKey ? theme.sidebarSelection : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredAction = hovering ? actionKey : nil
        }
        .accessibilityLabel(title)
        .accessibilityHint("Double tap to \(subtitle)")
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
        .environmentObject(ThemeManager.shared)
        .frame(width: 600, height: 700)
}
