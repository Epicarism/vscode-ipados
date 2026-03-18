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
                UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil, errorHandler: nil)
                dismiss()
            },
            Command(name: "Open File", shortcut: "⌘O", icon: "doc", category: .file) {
                editorCore.showFilePicker = true
                dismiss()
            },
            Command(name: "Open Folder", shortcut: "⌘⇧O", icon: "folder", category: .file) {
                NotificationCenter.default.post(name: .openFolder, object: nil)
                dismiss()
            },
            Command(name: "Save", shortcut: "⌘S", icon: "square.and.arrow.down", category: .file) {
                editorCore.saveActiveTab()
                dismiss()
            },
            Command(name: "Save As...", shortcut: "⌘⇧S", icon: "square.and.arrow.down.on.square", category: .file) {
                NotificationCenter.default.post(name: .saveAs, object: nil)
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
                NotificationCenter.default.post(name: .performCut, object: nil)
                dismiss()
            },
            Command(name: "Copy", shortcut: "⌘C", icon: "doc.on.doc", category: .edit) {
                NotificationCenter.default.post(name: .performCopy, object: nil)
                dismiss()
            },
            Command(name: "Paste", shortcut: "⌘V", icon: "doc.on.clipboard", category: .edit) {
                NotificationCenter.default.post(name: .performPaste, object: nil)
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
            Command(name: "Duplicate Line Down", shortcut: "⌥⇧↓", icon: "plus.square.on.square", category: .edit) {
                NotificationCenter.default.post(name: .duplicateLineDown, object: nil)
                dismiss()
            },
            Command(name: "Insert Line Below", shortcut: "⌘↵", icon: "text.append", category: .edit) {
                NotificationCenter.default.post(name: .insertLineBelow, object: nil)
                dismiss()
            },
            Command(name: "Insert Line Above", shortcut: "⌘⇧↵", icon: "text.insert", category: .edit) {
                NotificationCenter.default.post(name: .insertLineAbove, object: nil)
                dismiss()
            },
            Command(name: "Select Line", shortcut: "⌘L", icon: "text.line.first.and.arrowtriangle.forward", category: .edit) {
                NotificationCenter.default.post(name: .selectLine, object: nil)
                dismiss()
            },
            Command(name: "Indent Line", shortcut: "⌘]", icon: "increase.indent", category: .edit) {
                NotificationCenter.default.post(name: .indentLines, object: nil)
                dismiss()
            },
            Command(name: "Outdent Line", shortcut: "⌘[", icon: "decrease.indent", category: .edit) {
                NotificationCenter.default.post(name: .outdentLines, object: nil)
                dismiss()
            },
            Command(name: "Join Lines", shortcut: "⌃J", icon: "arrow.right.arrow.left", category: .edit) {
                NotificationCenter.default.post(name: .joinLines, object: nil)
                dismiss()
            },

            // Selection Commands
            Command(name: "Select All", shortcut: "⌘A", icon: "selection.pin.in.out", category: .selection) {
                NotificationCenter.default.post(name: .selectAll, object: nil)
                dismiss()
            },
            Command(name: "Expand Selection", shortcut: "⌃⇧⌘→", icon: "arrow.up.left.and.arrow.down.right", category: .selection) {
                NotificationCenter.default.post(name: .expandSelection, object: nil)
                dismiss()
            },
            Command(name: "Shrink Selection", shortcut: "⌃⇧⌘←", icon: "arrow.down.right.and.arrow.up.left", category: .selection) {
                NotificationCenter.default.post(name: .shrinkSelection, object: nil)
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
                // Request full-screen via scene geometry on iPadOS 16+
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    if windowScene.activationState == .foregroundActive {
                        let geometryRequest = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .all)
                        windowScene.requestGeometryUpdate(geometryRequest) { _ in }
                    }
                }
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
            Command(name: "Go to Definition", shortcut: "⌘.", icon: "arrow.right.circle", category: .go) {
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
                NotificationCenter.default.post(name: .startDebugging, object: nil)
                dismiss()
            },
            Command(name: "Run Without Debugging", shortcut: "⌃F5", icon: "play", category: .run) {
                NotificationCenter.default.post(name: .runWithoutDebugging, object: nil)
                dismiss()
            },
            Command(name: "Run JavaScript", shortcut: nil, icon: "play.circle", category: .run) {
                NotificationCenter.default.post(name: .runJavaScript, object: nil)
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
                showSettings = true
                dismiss()
            },
            Command(name: "File Icon Theme", shortcut: nil, icon: "doc.badge.gearshape", category: .preferences) {
                showSettings = true
                dismiss()
            },

            // Git / Source Control Commands
            Command(name: "Git: Commit", shortcut: nil, icon: "checkmark.circle", category: .file) {
                editorCore.focusedSidebarTab = 2
                editorCore.showSidebar = true
                dismiss()
            },
            Command(name: "Git: Clone Repository", shortcut: nil, icon: "arrow.down.circle", category: .file) {
                NotificationCenter.default.post(name: .cloneRepository, object: nil)
                dismiss()
            },

            // Code Folding Commands
            Command(name: "Fold All", shortcut: "⌘⇧0", icon: "chevron.down.square", category: .view) {
                editorCore.collapseAllFolds()
                dismiss()
            },
            Command(name: "Unfold All", shortcut: "⌘⇧9", icon: "chevron.up.square", category: .view) {
                editorCore.expandAllFolds()
                dismiss()
            },
            Command(name: "Toggle Word Wrap", shortcut: nil, icon: "text.word.spacing", category: .view) {
                let current = UserDefaults.standard.bool(forKey: "wordWrap")
                UserDefaults.standard.set(!current, forKey: "wordWrap")
                dismiss()
            },
            Command(name: "Toggle Minimap", shortcut: nil, icon: "sidebar.right", category: .view) {
                let current = UserDefaults.standard.bool(forKey: "minimapEnabled")
                UserDefaults.standard.set(!current, forKey: "minimapEnabled")
                dismiss()
            },
            Command(name: "Show Problems", shortcut: "⌘⇧M", icon: "exclamationmark.triangle", category: .view) {
                NotificationCenter.default.post(name: .switchToProblemsPanel, object: nil)
                dismiss()
            },
            Command(name: "Trigger Suggestion", shortcut: "⌃Space", icon: "text.bubble", category: .edit) {
                NotificationCenter.default.post(name: .triggerSuggestion, object: nil)
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

    // MARK: - Fuzzy Search
    
    /// Fuzzy subsequence match: all query chars must appear in order in target.
    /// Returns (matches, score) where higher score = better match.
    private func fuzzyMatch(query: String, target: String) -> (matches: Bool, score: Int) {
        let queryChars = Array(query.lowercased())
        let targetLower = target.lowercased()
        let targetChars = Array(targetLower)
        guard !queryChars.isEmpty else { return (true, 0) }
        
        var qi = 0
        var score = 0
        var consecutive = 0
        var lastMatchIdx = -2
        
        for (ti, tc) in targetChars.enumerated() {
            if qi < queryChars.count && tc == queryChars[qi] {
                // Prefix bonus: first char matches first char of target
                if qi == 0 && ti == 0 { score += 10 }
                // Word boundary bonus: char after space/separator
                if ti > 0 {
                    let prev = targetChars[ti - 1]
                    if prev == " " || prev == ":" || prev == "-" || prev == "/" {
                        score += 5
                    }
                }
                // Consecutive match bonus
                if ti == lastMatchIdx + 1 {
                    consecutive += 1
                    score += consecutive * 2
                } else {
                    consecutive = 0
                }
                lastMatchIdx = ti
                qi += 1
                score += 1 // base point per matched char
            }
        }
        return (qi == queryChars.count, score)
    }

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

        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return allCommands }

        // Fuzzy match against name, shortcut, and category
        var scored: [(command: Command, score: Int)] = []
        for cmd in allCommands {
            let (nameMatch, nameScore) = fuzzyMatch(query: query, target: cmd.name)
            let (shortcutMatch, shortcutScore) = cmd.shortcut.map { fuzzyMatch(query: query, target: $0) } ?? (false, 0)
            let (catMatch, catScore) = fuzzyMatch(query: query, target: cmd.category.rawValue)
            
            if nameMatch || shortcutMatch || catMatch {
                // Name match gets priority, shortcut/category are secondary
                let bestScore = max(nameScore, max(shortcutScore - 3, catScore - 5))
                scored.append((cmd, bestScore))
            }
        }
        
        // Sort by score descending, then alphabetically for ties
        return scored.sorted { a, b in
            if a.score != b.score { return a.score > b.score }
            return a.command.name < b.command.name
        }.map { $0.command }
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
