//
//  KeyboardShortcutsView.swift
//  VSCodeiPadOS
//
//  VS Code-style Keyboard Shortcuts reference panel.
//  Shows all available shortcuts organized by category.
//  Accessed via Command Palette or Help menu.
//

import SwiftUI

// MARK: - Shortcut Model

struct KeyboardShortcut: Identifiable {
    let id = UUID()
    let name: String
    let keys: String
    let category: ShortcutCategory
    let description: String
}

enum ShortcutCategory: String, CaseIterable {
    case general = "General"
    case editing = "Editing"
    case navigation = "Navigation"
    case search = "Search & Replace"
    case view = "View"
    case debug = "Debug"
    case terminal = "Terminal"
    
    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .editing: return "pencil"
        case .navigation: return "arrow.right.arrow.left"
        case .search: return "magnifyingglass"
        case .view: return "sidebar.left"
        case .debug: return "ladybug"
        case .terminal: return "terminal"
        }
    }
}

// MARK: - All Shortcuts

struct ShortcutCatalog {
    static let all: [KeyboardShortcut] = [
        // General
        KeyboardShortcut(name: "Command Palette", keys: "⇧⌘P", category: .general, description: "Open the command palette to run any command"),
        KeyboardShortcut(name: "Quick Open", keys: "⌘P", category: .general, description: "Quickly open files by name"),
        KeyboardShortcut(name: "New File", keys: "⌘N", category: .general, description: "Create a new untitled file"),
        KeyboardShortcut(name: "Save", keys: "⌘S", category: .general, description: "Save the active file"),
        KeyboardShortcut(name: "Save All", keys: "⌥⌘S", category: .general, description: "Save all open files"),
        KeyboardShortcut(name: "Close Tab", keys: "⌘W", category: .general, description: "Close the active editor tab"),
        KeyboardShortcut(name: "Settings", keys: "⌘,", category: .general, description: "Open settings"),
        
        // Editing
        KeyboardShortcut(name: "Cut", keys: "⌘X", category: .editing, description: "Cut selected text"),
        KeyboardShortcut(name: "Copy", keys: "⌘C", category: .editing, description: "Copy selected text"),
        KeyboardShortcut(name: "Paste", keys: "⌘V", category: .editing, description: "Paste from clipboard"),
        KeyboardShortcut(name: "Undo", keys: "⌘Z", category: .editing, description: "Undo last action"),
        KeyboardShortcut(name: "Redo", keys: "⇧⌘Z", category: .editing, description: "Redo last undone action"),
        KeyboardShortcut(name: "Select All", keys: "⌘A", category: .editing, description: "Select all text in editor"),
        KeyboardShortcut(name: "Select Line", keys: "⌘L", category: .editing, description: "Select the current line"),
        KeyboardShortcut(name: "Toggle Comment", keys: "⌘/", category: .editing, description: "Toggle line comment"),
        KeyboardShortcut(name: "Delete Line", keys: "⇧⌘K", category: .editing, description: "Delete the current line"),
        KeyboardShortcut(name: "Move Line Up", keys: "⌥↑", category: .editing, description: "Move the current line up"),
        KeyboardShortcut(name: "Move Line Down", keys: "⌥↓", category: .editing, description: "Move the current line down"),
        KeyboardShortcut(name: "Duplicate Line Down", keys: "⇧⌥↓", category: .editing, description: "Duplicate the current line below"),
        KeyboardShortcut(name: "Duplicate Line Up", keys: "⇧⌥↑", category: .editing, description: "Duplicate the current line above"),
        KeyboardShortcut(name: "Insert Line Below", keys: "⌘↵", category: .editing, description: "Insert a new line below"),
        KeyboardShortcut(name: "Insert Line Above", keys: "⇧⌘↵", category: .editing, description: "Insert a new line above"),
        KeyboardShortcut(name: "Indent Line", keys: "⌘]", category: .editing, description: "Indent the current line"),
        KeyboardShortcut(name: "Outdent Line", keys: "⌘[", category: .editing, description: "Outdent the current line"),
        KeyboardShortcut(name: "Join Lines", keys: "⌃J", category: .editing, description: "Join the current line with the next"),
        KeyboardShortcut(name: "Format Document", keys: "⇧⌥F", category: .editing, description: "Format the active document"),
        KeyboardShortcut(name: "Trigger Suggestion", keys: "⌃Space", category: .editing, description: "Trigger autocomplete suggestions"),
        KeyboardShortcut(name: "Zoom In", keys: "⌘+", category: .editing, description: "Increase editor font size"),
        KeyboardShortcut(name: "Zoom Out", keys: "⌘-", category: .editing, description: "Decrease editor font size"),
        
        // Selection
        KeyboardShortcut(name: "Add Next Occurrence", keys: "⌘D", category: .editing, description: "Add next match to selection"),
        KeyboardShortcut(name: "Select All Occurrences", keys: "⇧⌘L", category: .editing, description: "Select all occurrences of selection"),
        KeyboardShortcut(name: "Add Cursor Above", keys: "⌥⌘↑", category: .editing, description: "Add cursor on the line above"),
        KeyboardShortcut(name: "Add Cursor Below", keys: "⌥⌘↓", category: .editing, description: "Add cursor on the line below"),
        
        // Navigation
        KeyboardShortcut(name: "Go to Line", keys: "⌃G", category: .navigation, description: "Jump to a specific line number"),
        KeyboardShortcut(name: "Go to Symbol", keys: "⇧⌘O", category: .navigation, description: "Navigate to a symbol in the file"),
        KeyboardShortcut(name: "Go to Definition", keys: "⌘.", category: .navigation, description: "Jump to symbol definition"),
        KeyboardShortcut(name: "Peek Definition", keys: "⌥D", category: .navigation, description: "Peek at symbol definition inline"),
        KeyboardShortcut(name: "Go Back", keys: "⌃[", category: .navigation, description: "Go to previous editor location"),
        KeyboardShortcut(name: "Go Forward", keys: "⌃]", category: .navigation, description: "Go to next editor location"),
        
        // Search
        KeyboardShortcut(name: "Find", keys: "⌘F", category: .search, description: "Find text in current file"),
        KeyboardShortcut(name: "Find and Replace", keys: "⌥⌘F", category: .search, description: "Find and replace in current file"),
        KeyboardShortcut(name: "Find in Files", keys: "⇧⌘F", category: .search, description: "Search across all files in workspace"),
        
        // View
        KeyboardShortcut(name: "Toggle Sidebar", keys: "⌘B", category: .view, description: "Show or hide the sidebar"),
        KeyboardShortcut(name: "Toggle Terminal", keys: "⌘J", category: .view, description: "Show or hide the integrated terminal"),
        KeyboardShortcut(name: "AI Assistant", keys: "⇧⌘A", category: .view, description: "Open the AI coding assistant"),
        KeyboardShortcut(name: "Show Problems", keys: "⇧⌘M", category: .view, description: "Show the problems panel"),
        KeyboardShortcut(name: "Fold All", keys: "⇧⌘0", category: .view, description: "Collapse all code folds"),
        KeyboardShortcut(name: "Unfold All", keys: "⇧⌘9", category: .view, description: "Expand all code folds"),
        
        // Debug
        KeyboardShortcut(name: "Start Debugging", keys: "⇧⌘D", category: .debug, description: "Start or continue debugging"),
        KeyboardShortcut(name: "Run Without Debugging", keys: "⇧⌘R", category: .debug, description: "Run the project"),
        
        // Terminal
        KeyboardShortcut(name: "New Terminal", keys: "⌃⇧`", category: .terminal, description: "Create a new terminal instance"),
    ]
    
    static func shortcuts(for category: ShortcutCategory) -> [KeyboardShortcut] {
        all.filter { $0.category == category }
    }
}

// MARK: - Keyboard Shortcuts View

struct KeyboardShortcutsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: ShortcutCategory? = nil
    
    var filteredShortcuts: [KeyboardShortcut] {
        var results = ShortcutCatalog.all
        
        if let category = selectedCategory {
            results = results.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(query) ||
                $0.keys.lowercased().contains(query) ||
                $0.description.lowercased().contains(query) ||
                $0.category.rawValue.lowercased().contains(query)
            }
        }
        
        return results
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))
                    
                    TextField("Search shortcuts...", text: $searchText)
                        .font(.system(size: 14))
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        categoryChip(nil, label: "All")
                        ForEach(ShortcutCategory.allCases, id: \.rawValue) { cat in
                            categoryChip(cat, label: cat.rawValue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                
                Divider()
                
                // Shortcuts list
                if filteredShortcuts.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()
                        Image(systemName: "keyboard")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No shortcuts matching '\(searchText)'")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        if selectedCategory == nil && searchText.isEmpty {
                            // Group by category
                            ForEach(ShortcutCategory.allCases, id: \.rawValue) { category in
                                let shortcuts = ShortcutCatalog.shortcuts(for: category)
                                if !shortcuts.isEmpty {
                                    Section(header: categoryHeader(category)) {
                                        ForEach(shortcuts) { shortcut in
                                            shortcutRow(shortcut)
                                        }
                                    }
                                }
                            }
                        } else {
                            ForEach(filteredShortcuts) { shortcut in
                                shortcutRow(shortcut)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Keyboard Shortcuts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "keyboard")
                        .foregroundColor(.accentColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Subviews
    
    private func categoryChip(_ category: ShortcutCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        return Button(action: { selectedCategory = category }) {
            HStack(spacing: 4) {
                if let cat = category {
                    Image(systemName: cat.icon)
                        .font(.system(size: 10))
                }
                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color(UIColor.tertiarySystemBackground))
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    private func categoryHeader(_ category: ShortcutCategory) -> some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.system(size: 12))
            Text(category.rawValue)
                .font(.system(size: 12, weight: .semibold))
        }
    }
    
    private func shortcutRow(_ shortcut: KeyboardShortcut) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.name)
                    .font(.system(size: 14))
                Text(shortcut.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Key binding display
            keyCapsView(shortcut.keys)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(shortcut.name), \(shortcut.keys), \(shortcut.description)")
    }
    
    private func keyCapsView(_ keys: String) -> some View {
        HStack(spacing: 2) {
            ForEach(Array(keys), id: \.self) { char in
                Text(String(char))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(UIColor.separator), lineWidth: 0.5)
                    )
            }
        }
    }
}
