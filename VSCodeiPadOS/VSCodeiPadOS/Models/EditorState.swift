//
//  EditorState.swift
//  VSCodeiPadOS
//
//  Created by AI Assistant
//  State management for editor view configuration and cursor position
//

import Foundation
import SwiftUI

/// Manages the state of an individual editor instance
struct EditorState: Equatable {
    // MARK: - Cursor & Selection
    
    /// Current cursor position in the editor
    var cursorPosition: CursorPosition
    
    /// Current text selection (nil if no selection)
    var selection: TextSelection?
    
    /// Line numbers that are currently folded/collapsed
    var foldedRegions: Set<Int>
    
    // MARK: - Display Settings
    
    /// Font size for editor text
    var fontSize: CGFloat
    
    /// Whether to show line numbers in the gutter
    var showLineNumbers: Bool
    
    /// Whether to show the minimap overview
    var showMinimap: Bool
    
    /// Whether to wrap long lines
    var wordWrap: Bool
    
    /// Whether to show whitespace characters
    var showWhitespace: Bool
    
    /// Number of spaces per tab
    var tabSize: Int
    
    /// Whether to use spaces instead of tabs
    var insertSpaces: Bool
    
    // MARK: - Scroll State
    
    /// Vertical scroll position (line number)
    var scrollLine: Int
    
    /// Horizontal scroll position (column)
    var scrollColumn: Int
    
    // MARK: - Initialization
    
    /// Creates a new editor state with default values
    init(
        cursorPosition: CursorPosition = CursorPosition(),
        selection: TextSelection? = nil,
        foldedRegions: Set<Int> = [],
        fontSize: CGFloat = 14,
        showLineNumbers: Bool = true,
        showMinimap: Bool = false,
        wordWrap: Bool = false,
        showWhitespace: Bool = false,
        tabSize: Int = 4,
        insertSpaces: Bool = true,
        scrollLine: Int = 0,
        scrollColumn: Int = 0
    ) {
        self.cursorPosition = cursorPosition
        self.selection = selection
        self.foldedRegions = foldedRegions
        self.fontSize = fontSize
        self.showLineNumbers = showLineNumbers
        self.showMinimap = showMinimap
        self.wordWrap = wordWrap
        self.showWhitespace = showWhitespace
        self.tabSize = tabSize
        self.insertSpaces = insertSpaces
        self.scrollLine = scrollLine
        self.scrollColumn = scrollColumn
    }
    
    // MARK: - Helper Methods
    
    /// Checks if a line is currently folded
    /// - Parameter line: Line number (0-indexed)
    /// - Returns: True if the line is folded
    func isLineFolded(_ line: Int) -> Bool {
        foldedRegions.contains(line)
    }
    
    /// Toggles folding for a line
    /// - Parameter line: Line number (0-indexed)
    mutating func toggleFolding(at line: Int) {
        if foldedRegions.contains(line) {
            foldedRegions.remove(line)
        } else {
            foldedRegions.insert(line)
        }
    }
    
    /// Clears all text selection
    mutating func clearSelection() {
        selection = nil
    }
    
    /// Sets a text selection
    /// - Parameters:
    ///   - start: Starting cursor position
    ///   - end: Ending cursor position
    mutating func setSelection(from start: CursorPosition, to end: CursorPosition) {
        selection = TextSelection(start: start, end: end)
    }
}

// MARK: - CursorPosition

/// Represents a position in the text editor
struct CursorPosition: Equatable, Codable {
    /// Line number (0-indexed)
    var line: Int
    
    /// Column number (0-indexed)
    var column: Int
    
    /// Creates a cursor position at the beginning of the document
    init(line: Int = 0, column: Int = 0) {
        self.line = line
        self.column = column
    }
    
    /// Human-readable description (1-indexed for display)
    var displayDescription: String {
        "Ln \(line + 1), Col \(column + 1)"
    }
    
    /// Alias for displayDescription for convenience
    var description: String {
        displayDescription
    }
    
    /// Short display format
    var shortDisplay: String {
        "\(line + 1):\(column + 1)"
    }
    
    /// Moves cursor to the next line
    mutating func moveToNextLine() {
        line += 1
        column = 0
    }
    
    /// Moves cursor to the previous line
    mutating func moveToPreviousLine() {
        if line > 0 {
            line -= 1
            column = 0
        }
    }
    
    /// Compares two positions
    /// - Parameter other: Position to compare with
    /// - Returns: True if this position comes before the other
    func isBefore(_ other: CursorPosition) -> Bool {
        if line < other.line { return true }
        if line > other.line { return false }
        return column < other.column
    }
    
    /// Compares two positions
    /// - Parameter other: Position to compare with
    /// - Returns: True if this position comes after the other
    func isAfter(_ other: CursorPosition) -> Bool {
        if line > other.line { return true }
        if line < other.line { return false }
        return column > other.column
    }
}

// MARK: - TextSelection

/// Represents a range of selected text in the editor
struct TextSelection: Equatable, Codable {
    /// Starting position of the selection
    let start: CursorPosition
    
    /// Ending position of the selection
    let end: CursorPosition
    
    /// Creates a text selection
    /// - Parameters:
    ///   - start: Starting cursor position
    ///   - end: Ending cursor position
    init(start: CursorPosition, end: CursorPosition) {
        // Ensure start is always before end
        if start.isBefore(end) {
            self.start = start
            self.end = end
        } else {
            self.start = end
            self.end = start
        }
    }
    
    /// Whether the selection is empty (start == end)
    var isEmpty: Bool {
        start.line == end.line && start.column == end.column
    }
    
    /// Whether the selection spans multiple lines
    var isMultiLine: Bool {
        start.line != end.line
    }
    
    /// Number of lines in the selection
    var lineCount: Int {
        end.line - start.line + 1
    }
    
    /// Human-readable description of the selection
    var displayDescription: String {
        if isEmpty {
            return "No selection"
        }
        let chars = isMultiLine ? "\(lineCount) lines" : "\(end.column - start.column) chars"
        return "\(chars) selected"
    }
    
    /// Checks if a position is within this selection
    /// - Parameter position: Position to check
    /// - Returns: True if the position is within the selection
    func contains(_ position: CursorPosition) -> Bool {
        if position.line < start.line || position.line > end.line {
            return false
        }
        if position.line == start.line && position.column < start.column {
            return false
        }
        if position.line == end.line && position.column > end.column {
            return false
        }
        return true
    }
}

// MARK: - Split View Configuration

/// Defines how the editor is split (for multi-pane editing)
enum SplitViewConfiguration: Equatable, Codable {
    /// Single editor pane
    case single
    
    /// Two panes side by side with specified ratio
    case vertical(ratio: CGFloat)
    
    /// Two panes stacked with specified ratio
    case horizontal(ratio: CGFloat)
    
    /// Four panes in a grid
    case grid
    
    /// Default vertical split (50/50)
    static var verticalDefault: SplitViewConfiguration {
        .vertical(ratio: 0.5)
    }
    
    /// Default horizontal split (50/50)
    static var horizontalDefault: SplitViewConfiguration {
        .horizontal(ratio: 0.5)
    }
    
    /// Whether this configuration shows multiple panes
    var isMultiPane: Bool {
        switch self {
        case .single:
            return false
        case .vertical, .horizontal, .grid:
            return true
        }
    }
    
    /// Number of visible panes
    var paneCount: Int {
        switch self {
        case .single:
            return 1
        case .vertical, .horizontal:
            return 2
        case .grid:
            return 4
        }
    }
}
