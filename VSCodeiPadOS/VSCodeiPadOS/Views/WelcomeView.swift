import SwiftUI

// MARK: - WelcomeView

/// A polished, VS Code-style welcome screen shown on startup.
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
    var onCloneRepository: (() -> Void)?
    var onOpenRecentFile: ((URL) -> Void)?

    // ── Local state ────────────────────────────────────────
    @State private var hoveredAction: String? = nil
    @State private var hoveredRecentFile: String? = nil
    @State private var showAllRecent = false
    @StateObject private var recentFileManager = RecentFileManager.shared

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

                // ── Keyboard Shortcuts Reference ──────────
                sectionHeader("Keyboard Shortcuts")
                shortcutsReference
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
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("CodePad")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundColor(theme.sidebarForeground)

                HStack(spacing: 6) {
                    Text("Code editing. Redefined.")
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(theme.lineNumber)

                    Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(theme.lineNumber)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(theme.sidebarSectionHeader)
                        )
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("CodePad v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0") - Code editing. Redefined.")
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
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Start Section

    private var startSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            actionRow(
                icon: "folder",
                title: "Open Folder…",
                subtitle: "Open a folder to browse its contents",
                shortcut: "⇧⌘O",
                actionKey: "folder"
            ) {
                if let onOpenFolder = onOpenFolder {
                    onOpenFolder()
                } else {
                    NotificationCenter.default.post(name: .sceneOpenWorkspace, object: nil)
                }
            }

            actionRow(
                icon: "doc",
                title: "Open File…",
                subtitle: "Open a single file for editing",
                shortcut: "⌘O",
                actionKey: "file"
            ) {
                if let onOpenFile = onOpenFile {
                    onOpenFile()
                } else {
                    NotificationCenter.default.post(name: .openFile, object: nil)
                }
            }

            actionRow(
                icon: "doc.badge.plus",
                title: "New File",
                subtitle: "Create a new untitled file",
                shortcut: "⌘N",
                actionKey: "newFile"
            ) {
                if let onNewFile = onNewFile {
                    onNewFile()
                } else {
                    NotificationCenter.default.post(name: .newFile, object: nil)
                }
            }

            actionRow(
                icon: "arrow.down.circle",
                title: "Clone Repository…",
                subtitle: "Clone a Git repository from URL",
                shortcut: nil,
                actionKey: "clone"
            ) {
                if let onCloneRepository = onCloneRepository {
                    onCloneRepository()
                } else {
                    NotificationCenter.default.post(name: .cloneRepository, object: nil)
                }
            }
        }
    }

    // MARK: - Recent Files Section

    private var recentFilesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if recentFileManager.recentFiles.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                        .foregroundColor(theme.lineNumber)
                        .accessibilityHidden(true)

                    Text("No recent files")
                        .font(.system(size: 14))
                        .foregroundColor(theme.lineNumber)
                }
                .padding(.vertical, 8)
                .accessibilityElement(children: .combine)

                Text("Files you open will appear here for quick access.")
                    .font(.system(size: 12))
                    .foregroundColor(theme.lineNumber)
                    .accessibilityLabel("Hint: Files you open will appear here for quick access.")
            } else {
                let filesToShow = showAllRecent ? recentFileManager.recentFiles : Array(recentFileManager.recentFiles.prefix(8))
                ForEach(filesToShow, id: \.absoluteString) { url in
                    recentFileRow(url)
                }

                HStack(spacing: 12) {
                    if recentFileManager.recentFiles.count > 8 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showAllRecent.toggle()
                            }
                        } label: {
                            Text(showAllRecent ? "Show Less…" : "Show More…")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.activityBarForeground)
                                .padding(.top, 4)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(showAllRecent ? "Show fewer recent files" : "Show all recent files")
                        .accessibilityHint("Currently showing \(filesToShow.count) of \(recentFileManager.recentFiles.count) files")
                    }

                    Spacer()

                    Button {
                        recentFileManager.clearRecentFiles()
                    } label: {
                        Text("Clear Recent")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(theme.lineNumber)
                            .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear recent files list")
                    .accessibilityHint("Removes all files from the recent files list")
                }
            }
        }
    }

    // MARK: - Recent File Row

    private func recentFileRow(_ url: URL) -> some View {
        Button {
            if let onOpenRecentFile = onOpenRecentFile {
                onOpenRecentFile(url)
            } else {
                NotificationCenter.default.post(name: .openFile, object: url)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: fileIconName(for: url.pathExtension))
                    .font(.system(size: 14))
                    .foregroundColor(theme.activityBarForeground)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(hoveredRecentFile == url.absoluteString
                                  ? theme.sidebarSelection
                                  : theme.sidebarSectionHeader)
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(url.lastPathComponent)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(theme.sidebarForeground)
                        .lineLimit(1)

                    Text(url.deletingLastPathComponent().lastPathComponent)
                        .font(.system(size: 11))
                        .foregroundColor(theme.lineNumber)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.lineNumber)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(hoveredRecentFile == url.absoluteString ? theme.sidebarSelection : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredRecentFile = hovering ? url.absoluteString : nil
        }
        .accessibilityLabel(url.lastPathComponent)
        .accessibilityHint("Double tap to open this file")
    }

    // MARK: - Learn Section

    private var learnSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            actionRow(
                icon: "keyboard",
                title: "Keyboard Shortcuts",
                subtitle: "View all available keyboard shortcuts",
                shortcut: "⌘K ⌘S",
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
                // Documentation URL - open VS Code documentation
                if let url = URL(string: "https://code.visualstudio.com/docs") {
                    UIApplication.shared.open(url)
                }
            }

            actionRow(
                icon: "questionmark.circle",
                title: "Release Notes",
                subtitle: "See what's new in CodePad v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")",
                actionKey: "releaseNotes"
            ) {
                // Release notes URL - open VS Code updates page
                if let url = URL(string: "https://code.visualstudio.com/updates") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    // MARK: - Keyboard Shortcuts Reference

    private var shortcutsReference: some View {
        VStack(alignment: .leading, spacing: 4) {
            shortcutHintRow(key: "⌘N", description: "New File")
            shortcutHintRow(key: "⌘O", description: "Open File")
            shortcutHintRow(key: "⇧⌘O", description: "Open Folder")
            shortcutHintRow(key: "⌘S", description: "Save")
            shortcutHintRow(key: "⇧⌘S", description: "Save As")
            shortcutHintRow(key: "⌘W", description: "Close Tab")
            shortcutHintRow(key: "⌘P", description: "Quick Open")
            shortcutHintRow(key: "⇧⌘P", description: "Command Palette")
            shortcutHintRow(key: "⌘F", description: "Find")
            shortcutHintRow(key: "⌥⌘F", description: "Find and Replace")
            shortcutHintRow(key: "⌘G", description: "Go to Line")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Keyboard shortcuts reference")
    }

    // MARK: - Shortcut Hint Row

    private func shortcutHintRow(key: String, description: String) -> some View {
        HStack(spacing: 12) {
            Text(key)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(theme.sidebarForeground)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.sidebarSectionHeader)
                )
                .frame(width: 72, alignment: .leading)

            Text(description)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(theme.lineNumber)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(description): \(key)")
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
        .tint(theme.keyword)
        .toggleStyle(.switch)
        .accessibilityLabel("Show Welcome on Startup")
        .accessibilityHint("Double tap to toggle whether this page shows on launch")
    }

    // MARK: - Action Row (reusable button-like row)

    private func actionRow(
        icon: String,
        title: String,
        subtitle: String,
        shortcut: String? = nil,
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
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(theme.sidebarForeground)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(theme.lineNumber)
                }

                Spacer()

                if let shortcut = shortcut {
                    Text(shortcut)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(theme.lineNumber)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(theme.sidebarSectionHeader)
                        )
                        .accessibilityLabel("Keyboard shortcut: \(shortcut)")
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.lineNumber)
                    .accessibilityHidden(true)
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

    // MARK: - File Icon Helper

    private func fileIconName(for extension: String) -> String {
        switch `extension`.lowercased() {
        case "swift":
            return "swift"
        case "js", "mjs":
            return "js"
        case "ts", "tsx":
            return "ts"
        case "json":
            return "doc.text"
        case "md", "txt", "rtf":
            return "doc.richtext"
        case "html", "htm":
            return "globe"
        case "css", "scss", "sass", "less":
            return "paintbrush"
        case "py":
            return "chevron.left.forwardslash.chevron.right"
        case "png", "jpg", "jpeg", "gif", "svg", "webp":
            return "photo"
        case "mp4", "mov", "avi":
            return "video"
        case "mp3", "wav", "aac", "flac":
            return "music.note"
        case "zip", "tar", "gz", "bz2":
            return "archivebox"
        case "sh", "bash", "zsh":
            return "terminal"
        case "xml":
            return "doc.text"
        case "yml", "yaml":
            return "doc.text"
        default:
            return "doc"
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
        .environmentObject(ThemeManager.shared)
        .frame(width: 600, height: 700)
}
