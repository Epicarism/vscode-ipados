//
//  CommandPaletteView.swift
//  VSCodeiPadOS
//
//  VS Code-style Command Palette with case-insensitive substring search.
//  The filteredCommands property uses simple case-insensitive substring
//  matching on command titles instead of fuzzy matching, ensuring reliable
//  results for queries like "terminal" finding "Toggle Terminal".
//

import SwiftUI

// MARK: - Command Palette View

struct CommandPaletteView: View {
    @ObservedObject var editorCore: EditorCore
    @Binding var showSettings: Bool
    @Binding var showTerminal: Bool
    @StateObject private var recentManager = RecentCommandsManager()

    @State private var searchText = ""
    @State private var selectedIndex = 0
    @FocusState private var isSearchFocused: Bool

    private var allCommands: [Command] {
        [
            // File Commands
            Command(name: "New File", shortcut: "⌘N", icon: "doc.badge.plus", category: .file) {
                editorCore.addTab()
                dismiss()
            },
            Command(name: "New Window", shortcut: "⌘⇧N", icon: "macwindow.badge.plus", category: .file) {
                dismiss()
            },
            Command(name: "Open File", shortcut: "⌘O", icon: "doc", category: .file) {
                editorCore.showFilePicker = true
                dismiss()
            },
            Command(name: "Open Folder", shortcut: "⌘⇧O", icon: "folder", category: .file) {
                dismiss()
            },
            Command(name: "Save", shortcut: "⌘S", icon: "square.and.arrow.down", category: .file) {
                editorCore.saveActiveTab()
                dismiss()
            },
            Command(name: "Save As...", shortcut: "⌘⇧S", icon: "square.and.arrow.down.on.square", category: .file) {
                dismiss()
            },
            Command(name: "Save All", shortcut: "⌘⌥S", icon: "square.and.arrow.down.fill", category: .file) {
                editorCore.saveAllTabs()
                dismiss()
            },
            Command(name: "Close Editor", shortcut: "⌘W", icon: "xmark.square", category: .file) {
                if let tabId = editorCore.activeTabId {
                    editorCore.closeTab(id: tabId)
                }
                dismiss()
            },
            Command(name: "Close All Editors", shortcut: "⌘K ⌘W", icon: "xmark.square.fill", category: .file) {
                editorCore.closeAllTabs()
                dismiss()
            },

            // Edit Commands
            Command(name: "Undo", shortcut: "⌘Z", icon: "arrow.uturn.backward", category: .edit) {
                NotificationCenter.default.post(name: .performUndo, object: nil)
                dismiss()
            },
            Command(name: "Redo", shortcut: "⌘⇧Z", icon: "arrow.uturn.forward", category: .edit) {
                NotificationCenter.default.post(name: .performRedo, object: nil)
                dismiss()
            },
            Command(name: "Cut", shortcut: "⌘X", icon: "scissors", category: .edit) {
                dismiss()
            },
            Command(name: "Copy", shortcut: "⌘C", icon: "doc.on.doc", category: .edit) {
                dismiss()
            },
            Command(name: "Paste", shortcut: "⌘V", icon: "doc.on.clipboard", category: .edit) {
                dismiss()
            },
            Command(name: "Find", shortcut: "⌘F", icon: "magnifyingglass", category: .edit) {
                editorCore.showSearch = true
                dismiss()
            },
            Command(name: "Replace", shortcut: "⌘⌥F", icon: "arrow.left.arrow.right", category: .edit) {
                editorCore.showSearch = true
                dismiss()
            },
            Command(name: "Find in Files", shortcut: "⌘⇧F", icon: "doc.text.magnifyingglass", category: .edit) {
                editorCore.focusedSidebarTab = 1
                editorCore.showSidebar = true
                dismiss()
            },
            Command(name: "Format Document", shortcut: "⌥⇧F", icon: "text.alignleft", category: .edit) {
                NotificationCenter.default.post(name: .formatDocument, object: nil)
                dismiss()
            },
            Command(name: "Toggle Line Comment", shortcut: "⌘/", icon: "text.quote", category: .edit) {
                NotificationCenter.default.post(name: .toggleComment, object: nil)
                dismiss()
            },
            Command(name: "Delete Line", shortcut: "⌘⇧K", icon: "minus.circle", category: .edit) {
                NotificationCenter.default.post(name: .deleteLine, object: nil)
                dismiss()
            },
            Command(name: "Move Line Up", shortcut: "⌥↑", icon: "arrow.up", category: .edit) {
                NotificationCenter.default.post(name: .moveLineUp, object: nil)
                dismiss()
            },
            Command(name: "Move Line Down", shortcut: "⌥↓", icon: "arrow.down", category: .edit) {
                NotificationCenter.default.post(name: .moveLineDown, object: nil)
                dismiss()
            },

            // Selection Commands
            Command(name: "Select All", shortcut: "⌘A", icon: "selection.pin.in.out", category: .selection) {
                NotificationCenter.default.post(name: .selectAll, object: nil)
                dismiss()
            },
            Command(name: "Expand Selection", shortcut: "⌃⇧⌘→", icon: "arrow.up.left.and.arrow.down.right", category: .selection) {
                dismiss()
            },
            Command(name: "Shrink Selection", shortcut: "⌃⇧⌘←", icon: "arrow.down.right.and.arrow.up.left", category: .selection) {
                dismiss()
            },
            Command(name: "Add Cursor Above", shortcut: "⌥⌘↑", icon: "cursorarrow.and.square.on.square.dashed", category: .selection) {
                editorCore.addCursorAbove()
                dismiss()
            },
            Command(name: "Add Cursor Below", shortcut: "⌥⌘↓", icon: "cursorarrow.and.square.on.square.dashed", category: .selection) {
                editorCore.addCursorBelow()
                dismiss()
            },

            // View Commands
            Command(name: "Toggle Sidebar", shortcut: "⌘B", icon: "sidebar.left", category: .view) {
                editorCore.toggleSidebar()
                dismiss()
            },
            Command(name: "Toggle Terminal", shortcut: "⌘`", icon: "terminal", category: .view) {
                showTerminal.toggle()
                dismiss()
            },
            Command(name: "Toggle Full Screen", shortcut: "⌃⌘F", icon: "arrow.up.left.and.arrow.down.right", category: .view) {
                dismiss()
            },
            Command(name: "Zoom In", shortcut: "⌘+", icon: "plus.magnifyingglass", category: .view) {
                editorCore.zoomIn()
                dismiss()
            },
            Command(name: "Zoom Out", shortcut: "⌘-", icon: "minus.magnifyingglass", category: .view) {
                editorCore.zoomOut()
                dismiss()
            },
            Command(name: "Reset Zoom", shortcut: "⌘0", icon: "1.magnifyingglass", category: .view) {
                editorCore.resetZoom()
                dismiss()
            },
            Command(name: "Show Command Palette", shortcut: "⌘⇧P", icon: "command", category: .view) {
                dismiss()
            },

            // Go Commands
            Command(name: "Go to File", shortcut: "⌘P", icon: "doc.text.magnifyingglass", category: .go) {
                editorCore.showQuickOpen = true
                dismiss()
            },
            Command(name: "Go to Symbol", shortcut: "⌘⇧O", icon: "number", category: .go) {
                editorCore.showGoToSymbol = true
                dismiss()
            },
            Command(name: "Go to Line", shortcut: "⌘G", icon: "arrow.right.to.line", category: .go) {
                editorCore.showGoToLine = true
                dismiss()
            },
            Command(name: "Go to Definition", shortcut: "F12", icon: "arrow.right.circle", category: .go) {
                editorCore.goToDefinitionAtCursor()
                dismiss()
            },
            Command(name: "Go Back", shortcut: "⌃-", icon: "chevron.backward", category: .go) {
                editorCore.navigateBack()
                dismiss()
            },
            Command(name: "Go Forward", shortcut: "⌃⇧-", icon: "chevron.forward", category: .go) {
                editorCore.navigateForward()
                dismiss()
            },
            Command(name: "Next Editor", shortcut: "⌃Tab", icon: "arrow.right.square", category: .go) {
                editorCore.nextTab()
                dismiss()
            },
            Command(name: "Previous Editor", shortcut: "⌃⇧Tab", icon: "arrow.left.square", category: .go) {
                editorCore.previousTab()
                dismiss()
            },

            // Run Commands
            Command(name: "Start Debugging", shortcut: "F5", icon: "play.fill", category: .run) {
                dismiss()
            },
            Command(name: "Run Without Debugging", shortcut: "⌃F5", icon: "play", category: .run) {
                dismiss()
            },
            Command(name: "Stop", shortcut: "⇧F5", icon: "stop.fill", category: .run) {
                dismiss()
            },
            Command(name: "Restart", shortcut: "⌃⇧F5", icon: "arrow.clockwise", category: .run) {
                dismiss()
            },

            // Terminal Commands
            Command(name: "New Terminal", shortcut: "⌃⇧`", icon: "terminal.fill", category: .terminal) {
                NotificationCenter.default.post(name: .newTerminal, object: nil)
                showTerminal = true
                dismiss()
            },
            Command(name: "Clear Terminal", shortcut: nil, icon: "trash", category: .terminal) {
                NotificationCenter.default.post(name: .clearTerminal, object: nil)
                dismiss()
            },
            Command(name: "Kill Terminal", shortcut: nil, icon: "xmark.circle", category: .terminal) {
                showTerminal = false
                dismiss()
            },

            // Preferences Commands
            Command(name: "Settings", shortcut: "⌘,", icon: "gear", category: .preferences) {
                showSettings = true
                dismiss()
            },
            Command(name: "Keyboard Shortcuts", shortcut: "⌘K ⌘S", icon: "keyboard", category: .preferences) {
                editorCore.showKeyboardShortcuts = true
                dismiss()
            },
            Command(name: "Color Theme", shortcut: nil, icon: "paintpalette", category: .preferences) {
                dismiss()
            },
            Command(name: "File Icon Theme", shortcut: nil, icon: "doc.badge.gearshape", category: .preferences) {
                dismiss()
            },

            // Git / Source Control Commands
            Command(name: "Git: Commit", shortcut: nil, icon: "checkmark.circle", category: .file) {
                editorCore.focusedSidebarTab = 2
                editorCore.showSidebar = true
                dismiss()
            },
            Command(name: "Git: Clone Repository", shortcut: nil, icon: "arrow.down.circle", category: .file) {
                dismiss()
            },

            // Code Folding Commands
            Command(name: "Fold All", shortcut: nil, icon: "chevron.down.square", category: .view) {
                editorCore.collapseAllFolds()
                dismiss()
            },
            Command(name: "Unfold All", shortcut: nil, icon: "chevron.up.square", category: .view) {
                editorCore.expandAllFolds()
                dismiss()
            },

            // Help Commands
            Command(name: "Welcome", shortcut: nil, icon: "hand.wave", category: .help) {
                dismiss()
            },
            Command(name: "Documentation", shortcut: nil, icon: "book", category: .help) {
                dismiss()
            },
            Command(name: "AI Assistant", shortcut: "⌘⇧A", icon: "brain", category: .help) {
                editorCore.showAIAssistant = true
                dismiss()
            }
        ]
    }

    // MARK: - Filtering: Case-insensitive substring matching on command titles

    private var filteredCommands: [Command] {
        if searchText.isEmpty {
            // Show recent commands first, then all commands
            let recentNames = Set(recentManager.recentCommands)
            let recent = allCommands.filter { recentNames.contains($0.name) }
                .sorted { a, b in
                    let aIdx = recentManager.recentCommands.firstIndex(of: a.name) ?? Int.max
                    let bIdx = recentManager.recentCommands.firstIndex(of: b.name) ?? Int.max
                    return aIdx < bIdx
                }
            let others = allCommands.filter { !recentNames.contains($0.name) }
            return recent + others
        }

        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return allCommands }

        // Case-insensitive substring match on the command title (name).
        // Prefix matches rank first, then other substring matches.
        let prefixMatches = allCommands.filter { $0.name.lowercased().hasPrefix(query) }
        let containsMatches = allCommands.filter {
            !$0.name.lowercased().hasPrefix(query) &&
            ($0.name.lowercased().contains(query) ||
             ($0.shortcut?.lowercased().contains(query) ?? false) ||
             $0.category.rawValue.lowercased().contains(query))
        }

        return prefixMatches + containsMatches
    }

    private func dismiss() {
        editorCore.showCommandPalette = false
    }

    private func executeCommand(_ command: Command) {
        recentManager.addRecent(command.name)
        command.action()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Header
            HStack(spacing: 12) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                TextField("", text: $searchText, prompt: Text("Type a command or search...").foregroundColor(.secondary))
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .accessibilityLabel("Command search")
                    .accessibilityHint("Type to filter commands. Use arrow keys to navigate results, Return to execute.")
                    .onSubmit {
                        if let command = selectedIndex < filteredCommands.count ? filteredCommands[selectedIndex] : nil {
                            executeCommand(command)
                        }
                    }

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                    .accessibilityHint("Clears the current search text and shows all commands.")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))

            Divider()

            // Commands List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if searchText.isEmpty && !recentManager.recentCommands.isEmpty {
                            HStack {
                                Text("recently used")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color(UIColor.tertiarySystemBackground))
                            .accessibilityLabel("Recently used commands")
                            .accessibilityAddTraits(.isHeader)
                        }

                        ForEach(Array(filteredCommands.enumerated()), id: \.element.id) { index, command in
                            CommandRowView(
                                command: command,
                                searchQuery: searchText,
                                isSelected: index == selectedIndex,
                                isRecent: recentManager.recentCommands.contains(command.name)
                            )
                            .id(index)
                            .accessibilityLabel("\(command.name), \(command.category.rawValue) command\(command.shortcut != nil ? ", shortcut \(command.shortcut ?? "")" : "")\(recentManager.recentCommands.contains(command.name) ? ", recently used" : "")")
                            .accessibilityHint("Double-tap to execute \(command.name).")
                            .accessibilityAddTraits(.isButton)
                            .onTapGesture {
                                executeCommand(command)
                            }

                            if searchText.isEmpty &&
                               index == recentManager.recentCommands.count - 1 &&
                               !recentManager.recentCommands.isEmpty {
                                HStack {
                                    Text("all commands")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .accessibilityLabel("All commands")
                                .accessibilityAddTraits(.isHeader)
                            }
                        }
                    }
                }
                .onChange(of: selectedIndex) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }
            }
            .frame(maxHeight: 400)

            // Footer
            HStack(spacing: 16) {
                FooterHint(keys: ["↑", "↓"], description: "navigate")
                FooterHint(keys: ["↵"], description: "select")
                FooterHint(keys: ["esc"], description: "close")
                Spacer()
                Text("\(filteredCommands.count) commands")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(UIColor.tertiarySystemBackground))
        }
        .frame(width: 600)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
        .onAppear {
            isSearchFocused = true
            selectedIndex = 0
        }
        .onChange(of: searchText) { _, _ in
            selectedIndex = 0
        }
        .modifier(KeyboardNavigationModifier(
            onUp: { guard !filteredCommands.isEmpty else { return }; selectedIndex = (selectedIndex - 1 + filteredCommands.count) % filteredCommands.count },
            onDown: { guard !filteredCommands.isEmpty else { return }; selectedIndex = (selectedIndex + 1) % filteredCommands.count },
            onEscape: { dismiss() }
        ))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        ThemeManager.shared.currentTheme.overlayColor
        CommandPaletteView(
            editorCore: EditorCore(),
            showSettings: .constant(false),
            showTerminal: .constant(false)
        )
    }
}
