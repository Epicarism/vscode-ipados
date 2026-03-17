//
//  CommandPalette.swift
//  VSCodeiPadOS
//
//  VS Code-style Command Palette with fuzzy search
//

import SwiftUI

// MARK: - Command Definition

struct Command: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let shortcut: String?
    let icon: String
    let category: CommandCategory
    let action: () -> Void
    
    static func == (lhs: Command, rhs: Command) -> Bool {
        lhs.id == rhs.id
    }
}

enum CommandCategory: String, CaseIterable {
    case file = "File"
    case edit = "Edit"
    case selection = "Selection"
    case view = "View"
    case go = "Go"
    case run = "Run"
    case terminal = "Terminal"
    case preferences = "Preferences"
    case help = "Help"
    
    var icon: String {
        switch self {
        case .file: return "doc"
        case .edit: return "pencil"
        case .selection: return "selection.pin.in.out"
        case .view: return "rectangle.3.group"
        case .go: return "arrow.right"
        case .run: return "play"
        case .terminal: return "terminal"
        case .preferences: return "gear"
        case .help: return "questionmark.circle"
        }
    }
}

// MARK: - Recent Commands Manager

class RecentCommandsManager: ObservableObject {
    @Published var recentCommands: [String] = []
    private let maxRecent = 5
    private let storageKey = "recentCommands"
    
    init() {
        loadRecent()
    }
    
    func addRecent(_ commandName: String) {
        recentCommands.removeAll { $0 == commandName }
        recentCommands.insert(commandName, at: 0)
        if recentCommands.count > maxRecent {
            recentCommands = Array(recentCommands.prefix(maxRecent))
        }
        saveRecent()
    }
    
    private func loadRecent() {
        if let saved = UserDefaults.standard.stringArray(forKey: storageKey) {
            recentCommands = saved
        }
    }
    
    private func saveRecent() {
        UserDefaults.standard.set(recentCommands, forKey: storageKey)
    }
}

// MARK: - Fuzzy Search

struct FuzzyMatcher {
    static func score(query: String, target: String) -> Int? {
        guard !query.isEmpty else { return 1000 }
        
        let queryLower = query.lowercased()
        let targetLower = target.lowercased()
        
        // Exact match gets highest score
        if targetLower == queryLower { return 10000 }
        
        // Contains full query
        if targetLower.contains(queryLower) {
            // Bonus for starting with query
            if targetLower.hasPrefix(queryLower) {
                return 5000 + (1000 - target.count)
            }
            return 3000 + (1000 - target.count)
        }
        
        // Fuzzy character matching
        var queryIndex = queryLower.startIndex
        var targetIndex = targetLower.startIndex
        var score = 0
        var consecutiveBonus = 0
        var lastMatchIndex: String.Index? = nil
        
        while queryIndex < queryLower.endIndex && targetIndex < targetLower.endIndex {
            if queryLower[queryIndex] == targetLower[targetIndex] {
                score += 100 + consecutiveBonus
                
                // Bonus for consecutive matches
                if let lastIdx = lastMatchIndex,
                   targetLower.index(after: lastIdx) == targetIndex {
                    consecutiveBonus += 50
                } else {
                    consecutiveBonus = 0
                }
                
                // Bonus for matching at word boundaries
                if targetIndex == targetLower.startIndex ||
                   !targetLower[targetLower.index(before: targetIndex)].isLetter {
                    score += 75
                }
                
                lastMatchIndex = targetIndex
                queryIndex = queryLower.index(after: queryIndex)
            }
            targetIndex = targetLower.index(after: targetIndex)
        }
        
        // All query characters must be found
        guard queryIndex == queryLower.endIndex else { return nil }
        
        return score
    }
    
    static func highlight(query: String, in text: String) -> [(String, Bool)] {
        guard !query.isEmpty else { return [(text, false)] }
        
        var result: [(String, Bool)] = []
        let queryLower = query.lowercased()
        let textLower = text.lowercased()
        
        var queryIndex = queryLower.startIndex
        var currentSegment = ""
        var isMatch = false
        
        for (i, char) in text.enumerated() {
            let textIndex = textLower.index(textLower.startIndex, offsetBy: i)
            
            if queryIndex < queryLower.endIndex && 
               textLower[textIndex] == queryLower[queryIndex] {
                if !isMatch && !currentSegment.isEmpty {
                    result.append((currentSegment, false))
                    currentSegment = ""
                }
                isMatch = true
                currentSegment.append(char)
                queryIndex = queryLower.index(after: queryIndex)
            } else {
                if isMatch && !currentSegment.isEmpty {
                    result.append((currentSegment, true))
                    currentSegment = ""
                }
                isMatch = false
                currentSegment.append(char)
            }
        }
        
        if !currentSegment.isEmpty {
            result.append((currentSegment, isMatch))
        }
        
        return result
    }
}

// MARK: - Command Row View

struct CommandRowView: View {
    let command: Command
    let searchQuery: String
    let isSelected: Bool
    let isRecent: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: command.icon)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .white : .accentColor)
                .frame(width: 24)
                .accessibilityHidden(true)
            
            // Command name with highlighting
            highlightedName
                .accessibilityHidden(true)
            
            Spacer()
            
            // Recent indicator
            if isRecent && searchQuery.isEmpty {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                    .accessibilityHidden(true)
            }
            
            // Category badge
            Text(command.category.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? Color.white.opacity(0.2) : Color(UIColor.tertiarySystemFill))
                )
                .accessibilityHidden(true)
            
            // Keyboard shortcut
            if let shortcut = command.shortcut {
                ShortcutBadge(shortcut: shortcut, isSelected: isSelected)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor : Color.clear)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 1)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private var highlightedName: some View {
        if searchQuery.isEmpty {
            Text(command.name)
                .font(.system(size: 13))
                .foregroundColor(isSelected ? .white : .primary)
        } else {
            let parts = FuzzyMatcher.highlight(query: searchQuery, in: command.name)
            HStack(spacing: 0) {
                ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                    Text(part.0)
                        .font(.system(size: 13, weight: part.1 ? .bold : .regular))
                        .foregroundColor(isSelected ? .white : (part.1 ? .accentColor : .primary))
                }
            }
        }
    }
}

// MARK: - Shortcut Badge

struct ShortcutBadge: View {
    let shortcut: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(shortcut.components(separatedBy: " "), id: \.self) { key in
                Text(key)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isSelected ? Color.white.opacity(0.2) : Color(UIColor.tertiarySystemFill))
                    )
            }
        }
    }
}

// MARK: - Footer Hint

struct FooterHint: View {
    let keys: [String]
    let description: String
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(keys, id: \.self) { key in
                Text(key)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }
            Text(description)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Keyboard Navigation Modifier

struct KeyboardNavigationModifier: ViewModifier {
    let onUp: () -> Void
    let onDown: () -> Void
    let onEscape: () -> Void
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onKeyPress(.upArrow) { onUp(); return .handled }
                .onKeyPress(.downArrow) { onDown(); return .handled }
                .onKeyPress(.escape) { onEscape(); return .handled }
        } else {
            content
        }
    }
}
