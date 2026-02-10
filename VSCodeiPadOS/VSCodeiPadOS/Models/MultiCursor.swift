//
//  MultiCursor.swift
//  VSCodeiPadOS
//
//  Multi-cursor editing support
//

import Foundation
import UIKit

// MARK: - Cursor

/// Represents a single cursor with optional selection
struct Cursor: Identifiable, Equatable {
    let id: UUID
    
    /// Character offset in the text
    var position: Int
    
    /// Selection anchor (if different from position, text is selected)
    var anchor: Int?
    
    /// Whether this is the primary cursor
    var isPrimary: Bool
    
    init(position: Int, anchor: Int? = nil, isPrimary: Bool = false) {
        self.id = UUID()
        self.position = position
        self.anchor = anchor
        self.isPrimary = isPrimary
    }
    
    /// The selection range if text is selected
    var selectionRange: NSRange? {
        guard let anchor = anchor, anchor != position else { return nil }
        let start = min(position, anchor)
        let length = abs(position - anchor)
        return NSRange(location: start, length: length)
    }
    
    /// Whether this cursor has a selection
    var hasSelection: Bool {
        guard let anchor = anchor else { return false }
        return anchor != position
    }
    
    /// The selected text given the full text
    func selectedText(in text: String) -> String? {
        guard let range = selectionRange,
              let swiftRange = Range(range, in: text) else { return nil }
        return String(text[swiftRange])
    }
}

// MARK: - MultiCursorState

/// Manages multiple cursors in the editor
class MultiCursorState: ObservableObject {
    @Published var cursors: [Cursor] = []
    
    /// The primary cursor (first one or the explicitly marked one)
    var primaryCursor: Cursor? {
        cursors.first(where: { $0.isPrimary }) ?? cursors.first
    }
    
    /// Whether we're in multi-cursor mode
    var isMultiCursor: Bool {
        cursors.count > 1
    }
    
    init() {
        // Start with a single cursor at position 0
        cursors = [Cursor(position: 0, isPrimary: true)]
    }
    
    // MARK: - Cursor Management
    
    /// Resets to a single cursor at the given position
    func reset(to position: Int) {
        cursors = [Cursor(position: position, isPrimary: true)]
    }
    
    /// Adds a cursor at the given position (Option+Click)
    func addCursor(at position: Int) {
        // Don't add duplicate cursors at the same position
        guard !cursors.contains(where: { $0.position == position && $0.anchor == nil }) else { return }
        
        // Remove primary from existing cursors
        cursors = cursors.map { cursor in
            var updated = cursor
            updated.isPrimary = false
            return updated
        }
        
        // Add new primary cursor
        cursors.append(Cursor(position: position, isPrimary: true))
        sortCursors()
    }
    
    /// Adds a cursor with selection
    func addCursorWithSelection(position: Int, anchor: Int) {
        // Remove primary from existing cursors
        cursors = cursors.map { cursor in
            var updated = cursor
            updated.isPrimary = false
            return updated
        }
        
        cursors.append(Cursor(position: position, anchor: anchor, isPrimary: true))
        sortCursors()
    }
    
    /// Removes a cursor at the given position
    func removeCursor(at position: Int) {
        guard cursors.count > 1 else { return } // Keep at least one cursor
        cursors.removeAll { $0.position == position }
        
        // Ensure we have a primary cursor
        if !cursors.contains(where: { $0.isPrimary }), !cursors.isEmpty {
            cursors[0].isPrimary = true
        }
    }
    
    /// Updates the position of all cursors
    func updatePositions(_ transform: (Int) -> Int) {
        cursors = cursors.map { cursor in
            var updated = cursor
            updated.position = transform(cursor.position)
            if let anchor = cursor.anchor {
                updated.anchor = transform(anchor)
            }
            return updated
        }
    }
    
    /// Clears all selections but keeps cursors
    func clearSelections() {
        cursors = cursors.map { cursor in
            var updated = cursor
            updated.anchor = nil
            return updated
        }
    }
    
    /// Sort cursors by position
    private func sortCursors() {
        cursors.sort { $0.position < $1.position }
    }
    
    // MARK: - Text Operations
    
    /// Insert text at all cursor positions
    func insertText(_ text: String, in fullText: inout String) {
        // Process from start -> end while tracking how prior edits shift later cursor positions.
        let sortedCursors = cursors.sorted { $0.position < $1.position }
        var delta = 0

        for cursor in sortedCursors {
            guard let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id }) else { continue }

            if let selectionRange = cursor.selectionRange {
                let effectiveLocation = selectionRange.location + delta
                let effectiveRange = NSRange(location: effectiveLocation, length: selectionRange.length)

                guard let swiftRange = Range(effectiveRange, in: fullText) else { continue }

                fullText.replaceSubrange(swiftRange, with: text)

                // Cursor ends after inserted text; selection cleared.
                cursors[cursorIndex].position = effectiveLocation + text.count
                cursors[cursorIndex].anchor = nil

                delta += (text.count - selectionRange.length)
            } else {
                let effectivePosition = cursor.position + delta
                let clamped = min(max(0, effectivePosition), fullText.count)
                let stringIndex = fullText.index(fullText.startIndex, offsetBy: clamped)

                fullText.insert(contentsOf: text, at: stringIndex)

                cursors[cursorIndex].position = clamped + text.count
                delta += text.count
            }
        }

        // Keep state sane if multiple edits collapse cursors onto the same location.
        removeDuplicateCursors()
    }
    
    /// Delete text at all cursor positions (backspace)
    func deleteBackward(in fullText: inout String) {
        let sortedCursors = cursors.sorted { $0.position < $1.position }
        var delta = 0

        for cursor in sortedCursors {
            guard let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id }) else { continue }

            if let selectionRange = cursor.selectionRange {
                let effectiveLocation = selectionRange.location + delta
                let effectiveRange = NSRange(location: effectiveLocation, length: selectionRange.length)
                guard let swiftRange = Range(effectiveRange, in: fullText) else { continue }

                fullText.removeSubrange(swiftRange)

                cursors[cursorIndex].position = effectiveLocation
                cursors[cursorIndex].anchor = nil

                delta -= selectionRange.length
            } else {
                let effectivePosition = cursor.position + delta
                guard effectivePosition > 0 else { continue }

                let deleteOffset = effectivePosition - 1
                let deleteIndex = fullText.index(fullText.startIndex, offsetBy: deleteOffset)
                fullText.remove(at: deleteIndex)

                cursors[cursorIndex].position = deleteOffset
                delta -= 1
            }
        }

        removeDuplicateCursors()
    }
    
    private func adjustCursorPositions(afterInsertion length: Int) {
        // Already handled in insertText
    }
    
    private func removeDuplicateCursors() {
        var seen = Set<Int>()
        cursors = cursors.filter { cursor in
            if seen.contains(cursor.position) {
                return false
            }
            seen.insert(cursor.position)
            return true
        }
        
        // Ensure primary cursor exists
        if !cursors.contains(where: { $0.isPrimary }), !cursors.isEmpty {
            cursors[0].isPrimary = true
        }
    }
}

// MARK: - Occurrence Finding

extension String {
    /// Find all occurrences of a substring
    func findAllOccurrences(of searchString: String, caseSensitive: Bool = true) -> [NSRange] {
        var ranges: [NSRange] = []
        var searchRange = startIndex..<endIndex
        let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
        
        while let range = self.range(of: searchString, options: options, range: searchRange) {
            let nsRange = NSRange(range, in: self)
            ranges.append(nsRange)
            searchRange = range.upperBound..<endIndex
        }
        
        return ranges
    }
    
    /// Find the next occurrence after a given position
    func findNextOccurrence(of searchString: String, after position: Int, caseSensitive: Bool = true) -> NSRange? {
        guard position < count else { return nil }
        let startIdx = index(startIndex, offsetBy: position)
        let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
        
        // Search from current position to end
        if let range = self.range(of: searchString, options: options, range: startIdx..<endIndex) {
            return NSRange(range, in: self)
        }
        
        // Wrap around: search from beginning to current position
        if let range = self.range(of: searchString, options: options, range: startIndex..<startIdx) {
            return NSRange(range, in: self)
        }
        
        return nil
    }
}
