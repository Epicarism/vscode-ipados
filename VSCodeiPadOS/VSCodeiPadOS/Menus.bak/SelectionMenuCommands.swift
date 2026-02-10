import SwiftUI

/// Selection menu commands for VS Code iPadOS editor.
/// Provides text selection, cursor manipulation, and line movement operations.
struct SelectionMenuCommands: Commands {
    // MARK: - Core Dependencies
    
    /// Reference to the editor core for accessing document state and executing commands.
    @ObservedObject var editorCore: EditorCore
    
    // MARK: - Command Menu Body
    
    var body: some Commands {
        CommandMenu("Selection") {
            // MARK: - Basic Selection
            
            Button("Select All") {
                editorCore.selectAll()
            }
            // Note: UITextView has built-in Cmd+A support, removed duplicate
            
            Divider()
            
            // MARK: - Expand/Shrink Selection
            
            Button("Expand Selection") {
                editorCore.expandSelection()
            }
            .keyboardShortcut("\u{2192}", modifiers: [.control, .shift, .command]) // →
            
            Button("Shrink Selection") {
                editorCore.shrinkSelection()
            }
            .keyboardShortcut("\u{2190}", modifiers: [.control, .shift, .command]) // ←
            
            Divider()
            
            // MARK: - Line Operations
            
            Button("Copy Line Up") {
                editorCore.copyLineUp()
            }
            .keyboardShortcut("\u{2191}", modifiers: [.option, .shift]) // ↑
            
            Button("Copy Line Down") {
                editorCore.copyLineDown()
            }
            .keyboardShortcut("\u{2193}", modifiers: [.option, .shift]) // ↓
            
            Button("Move Line Up") {
                editorCore.moveLineUp()
            }
            .keyboardShortcut("\u{2191}", modifiers: [.option]) // ↑
            
            Button("Move Line Down") {
                editorCore.moveLineDown()
            }
            .keyboardShortcut("\u{2193}", modifiers: [.option]) // ↓
            
            Divider()
            
            // MARK: - Multi-Cursor Operations
            
            Button("Add Cursor Above") {
                editorCore.addCursorAbove()
            }
            .keyboardShortcut("\u{2191}", modifiers: [.option, .command]) // ↑
            
            Button("Add Cursor Below") {
                editorCore.addCursorBelow()
            }
            .keyboardShortcut("\u{2193}", modifiers: [.option, .command]) // ↓
            
            Button("Add Cursors to Line Ends") {
                editorCore.addCursorsToLineEnds()
            }
            .keyboardShortcut("i", modifiers: [.option, .shift])
            
            Divider()
            
            // MARK: - Multi-Selection Occurrences
            
            Button("Add Next Occurrence") {
                editorCore.addNextOccurrence()
            }
            .keyboardShortcut("d", modifiers: [.command])
            
            Button("Select All Occurrences") {
                editorCore.selectAllOccurrences()
            }
            .keyboardShortcut("l", modifiers: [.command, .shift])
        }
    }
}

// MARK: - EditorCore Extensions for Selection Commands

extension EditorCore {
    
    // MARK: - Basic Selection
    
    /// Selects all content in the active tab.
    /// - Shortcut: ⌘A
    func selectAll() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        let allRange = NSRange(location: 0, length: content.utf16.count)
        currentSelectionRange = allRange
        currentSelection = content
        
        // Update multi-cursor state to single primary cursor at end
        multiCursorState.cursors = [
            Cursor(position: content.utf16.count, anchor: 0, isPrimary: true)
        ]
    }
    
    // MARK: - Expand/Shrink Selection
    
    /// Expands the current selection to encompass larger semantic units.
    /// Progression: word → line → block → function → document
    /// - Shortcut: ⌃⇧⌘→
    func expandSelection() {
        guard let index = activeTabIndex,
              let range = currentSelectionRange else { return }
        let content = tabs[index].content
        
        // If no selection, select the current word
        if range.length == 0 {
            if let wordRange = findWordAtPosition(range.location, in: content) {
                currentSelectionRange = wordRange
                if let swiftRange = Range(wordRange, in: content) {
                    currentSelection = String(content[swiftRange])
                }
                updateMultiCursorFromSelection(range: wordRange)
            }
            return
        }
        
        // Expand to line
        let lineRange = (content as NSString).lineRange(for: range)
        if lineRange.length > range.length {
            currentSelectionRange = lineRange
            if let swiftRange = Range(lineRange, in: content) {
                currentSelection = String(content[swiftRange])
            }
            updateMultiCursorFromSelection(range: lineRange)
            return
        }
        
        // Expand to entire document
        selectAll()
    }
    
    /// Shrinks the current selection to smaller semantic units.
    /// Progression: document → function → block → line → word → cursor
    /// - Shortcut: ⌃⇧⌘←
    func shrinkSelection() {
        guard let index = activeTabIndex,
              let range = currentSelectionRange else { return }
        let content = tabs[index].content
        
        // If entire document selected, shrink to current line
        let nsContent = content as NSString
        if range.location == 0 && range.length == nsContent.length {
            let lineRange = nsContent.lineRange(for: NSRange(location: range.location, length: 0))
            if lineRange.length < range.length {
                currentSelectionRange = lineRange
                if let swiftRange = Range(lineRange, in: content) {
                    currentSelection = String(content[swiftRange])
                }
                updateMultiCursorFromSelection(range: lineRange)
                return
            }
        }
        
        // If line selected, shrink to word
        let lineRange = nsContent.lineRange(for: range)
        if NSEqualRanges(range, lineRange) {
            let cursorPos = range.location
            if let wordRange = findWordAtPosition(cursorPos, in: content) {
                currentSelectionRange = wordRange
                if let swiftRange = Range(wordRange, in: content) {
                    currentSelection = String(content[swiftRange])
                }
                updateMultiCursorFromSelection(range: wordRange)
                return
            }
        }
        
        // Otherwise, collapse to cursor
        if let primary = multiCursorState.primaryCursor {
            resetToSingleCursor(at: primary.position)
        } else {
            resetToSingleCursor(at: range.location)
        }
    }
    
    // MARK: - Line Copy/Move Operations
    
    /// Copies the current line up, inserting a duplicate above.
    /// - Shortcut: ⌥⇧↑
    func copyLineUp() {
        guard let index = activeTabIndex else { return }
        var content = tabs[index].content
        
        guard let range = currentSelectionRange else { return }
        let lineRange = (content as NSString).lineRange(for: range)
        
        if let swiftRange = Range(lineRange, in: content) {
            let lineContent = String(content[swiftRange])
            let insertPosition = lineRange.location
            
            let nsContent = NSMutableString(string: content)
            nsContent.insert(lineContent, at: insertPosition)
            
            content = String(nsContent)
            updateActiveTabContent(content)
            
            // Update cursor position to the copied line
            let newRange = NSRange(location: insertPosition, length: lineRange.length)
            currentSelectionRange = newRange
            updateMultiCursorFromSelection(range: newRange)
        }
    }
    
    /// Copies the current line down, inserting a duplicate below.
    /// - Shortcut: ⌥⇧↓
    func copyLineDown() {
        guard let index = activeTabIndex else { return }
        var content = tabs[index].content
        
        guard let range = currentSelectionRange else { return }
        let lineRange = (content as NSString).lineRange(for: range)
        
        if let swiftRange = Range(lineRange, in: content) {
            let lineContent = String(content[swiftRange])
            let insertPosition = lineRange.location + lineRange.length
            
            let nsContent = NSMutableString(string: content)
            nsContent.insert(lineContent, at: insertPosition)
            
            content = String(nsContent)
            updateActiveTabContent(content)
            
            // Update cursor position to the copied line
            let newRange = NSRange(location: insertPosition, length: lineRange.length)
            currentSelectionRange = newRange
            updateMultiCursorFromSelection(range: newRange)
        }
    }
    
    /// Moves the current line up one position.
    /// - Shortcut: ⌥↑
    func moveLineUp() {
        guard let index = activeTabIndex else { return }
        var content = tabs[index].content
        
        guard let range = currentSelectionRange else { return }
        let lineRange = (content as NSString).lineRange(for: range)
        
        guard lineRange.location > 0 else { return } // Already at top
        
        // Find the previous line range
        let previousLineEnd = lineRange.location - 1
        let previousLineRange = (content as NSString).lineRange(
            for: NSRange(location: previousLineEnd, length: 0)
        )
        
        // Swap lines
        if let swiftLineRange = Range(lineRange, in: content),
           let swiftPreviousRange = Range(previousLineRange, in: content) {
            
            let currentLine = String(content[swiftLineRange])
            let previousLine = String(content[swiftPreviousRange])
            
            let nsContent = NSMutableString(string: content)
            nsContent.replaceCharacters(in: previousLineRange, with: currentLine)
            
            // Adjust lineRange after previous line replacement
            let adjustedLineRange = NSRange(
                location: previousLineRange.location,
                length: lineRange.length
            )
            nsContent.replaceCharacters(in: adjustedLineRange, with: previousLine)
            
            content = String(nsContent)
            updateActiveTabContent(content)
            
            // Update cursor to follow the moved line
            let newRange = NSRange(
                location: previousLineRange.location,
                length: lineRange.length
            )
            currentSelectionRange = newRange
            updateMultiCursorFromSelection(range: newRange)
        }
    }
    
    /// Moves the current line down one position.
    /// - Shortcut: ⌥↓
    func moveLineDown() {
        guard let index = activeTabIndex else { return }
        var content = tabs[index].content
        
        guard let range = currentSelectionRange else { return }
        let lineRange = (content as NSString).lineRange(for: range)
        
        let nextLineStart = lineRange.location + lineRange.length
        guard nextLineStart < (content as NSString).length else { return } // Already at bottom
        
        // Find the next line range
        let nextLineRange = (content as NSString).lineRange(
            for: NSRange(location: nextLineStart, length: 0)
        )
        
        // Swap lines
        if let swiftLineRange = Range(lineRange, in: content),
           let swiftNextRange = Range(nextLineRange, in: content) {
            
            let currentLine = String(content[swiftLineRange])
            let nextLine = String(content[swiftNextRange])
            
            let nsContent = NSMutableString(string: content)
            nsContent.replaceCharacters(in: lineRange, with: nextLine)
            
            // Adjust nextLineRange after current line replacement
            let adjustedNextRange = NSRange(
                location: lineRange.location,
                length: nextLineRange.length
            )
            nsContent.replaceCharacters(in: adjustedNextRange, with: currentLine)
            
            content = String(nsContent)
            updateActiveTabContent(content)
            
            // Update cursor to follow the moved line
            let newRange = NSRange(
                location: lineRange.location + nextLineRange.length,
                length: lineRange.length
            )
            currentSelectionRange = newRange
            updateMultiCursorFromSelection(range: newRange)
        }
    }
    
    // MARK: - Multi-Cursor Additions
    
    /// Adds a cursor at the same column on the line above.
    /// - Shortcut: ⌥⌘↑
    func addCursorAbove() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        
        let primaryCursor = multiCursorState.primaryCursor ?? 
            Cursor(position: currentSelectionRange?.location ?? 0, anchor: 0, isPrimary: true)
        
        let currentLineRange = (content as NSString).lineRange(
            for: NSRange(location: primaryCursor.position, length: 0)
        )
        
        guard currentLineRange.location > 0 else { return } // Already at top
        
        // Find the line above
        let lineAboveEnd = currentLineRange.location - 1
        let lineAboveRange = (content as NSString).lineRange(
            for: NSRange(location: lineAboveEnd, length: 0)
        )
        
        // Calculate column position
        let column = primaryCursor.position - currentLineRange.location
        let newCursorPosition = min(
            lineAboveRange.location + column,
            lineAboveRange.location + lineAboveRange.length
        )
        
        // Add cursor at new position
        multiCursorState.addCursor(at: newCursorPosition)
    }
    
    /// Adds a cursor at the same column on the line below.
    /// - Shortcut: ⌥⌘↓
    func addCursorBelow() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        
        let primaryCursor = multiCursorState.primaryCursor ?? 
            Cursor(position: currentSelectionRange?.location ?? 0, anchor: 0, isPrimary: true)
        
        let currentLineRange = (content as NSString).lineRange(
            for: NSRange(location: primaryCursor.position, length: 0)
        )
        
        let nextLineStart = currentLineRange.location + currentLineRange.length
        guard nextLineStart < (content as NSString).length else { return } // Already at bottom
        
        // Find the line below
        let nextLineRange = (content as NSString).lineRange(
            for: NSRange(location: nextLineStart, length: 0)
        )
        
        // Calculate column position
        let column = primaryCursor.position - currentLineRange.location
        let newCursorPosition = min(
            nextLineRange.location + column,
            nextLineRange.location + nextLineRange.length
        )
        
        // Add cursor at new position
        multiCursorState.addCursor(at: newCursorPosition)
    }
    
    /// Adds cursors to the end of all lines in the current selection or document.
    /// - Shortcut: ⌥⇧I
    func addCursorsToLineEnds() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        let nsContent = content as NSString
        
        var lineEnds: [Int] = []
        var currentRange = NSRange(location: 0, length: 0)
        
        while currentRange.location < nsContent.length {
            let lineRange = nsContent.lineRange(for: currentRange)
            // Add cursor at end of line (excluding newline)
            let lineEnd = lineRange.location + lineRange.length - 1
            if lineEnd >= lineRange.location {
                lineEnds.append(lineEnd)
            }
            
            currentRange.location = lineRange.location + lineRange.length
            currentRange.length = 0
        }
        
        // Create cursors at all line ends
        multiCursorState.cursors = lineEnds.enumerated().map { index, position in
            Cursor(position: position, anchor: position, isPrimary: index == 0)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Updates multi-cursor state to match a single selection range.
    private func updateMultiCursorFromSelection(range: NSRange) {
        multiCursorState.cursors = [
            Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)
        ]
    }
}
