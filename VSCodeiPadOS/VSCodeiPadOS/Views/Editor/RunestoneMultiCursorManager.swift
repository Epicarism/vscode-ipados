//
//  RunestoneMultiCursorManager.swift
//  VSCodeiPadOS
//
//  Multi-cursor overlay and editing support for Runestone's TextView.
//  Renders additional cursors as CALayers and intercepts text input
//  to apply edits at all cursor positions simultaneously.
//

import UIKit
import Runestone

/// Represents a secondary cursor (the primary cursor is handled by Runestone natively)
struct SecondaryCursor: Identifiable, Equatable {
    let id: UUID
    /// Character offset in the text
    var position: Int
    /// Selection anchor (if different from position, text is selected)
    var anchor: Int?
    
    init(position: Int, anchor: Int? = nil) {
        self.id = UUID()
        self.position = position
        self.anchor = anchor
    }
    
    var selectionRange: NSRange? {
        guard let anchor = anchor, anchor != position else { return nil }
        let start = min(position, anchor)
        let length = abs(position - anchor)
        return NSRange(location: start, length: length)
    }
    
    var hasSelection: Bool {
        guard let anchor = anchor else { return false }
        return anchor != position
    }
}

/// Manages multiple cursors on a Runestone TextView.
/// The primary cursor is always Runestone's native `selectedRange`.
/// Secondary cursors are rendered as CALayer overlays.
@MainActor
class RunestoneMultiCursorManager {
    
    // MARK: - State
    
    /// Secondary cursors (primary is always the native Runestone selection)
    private(set) var secondaryCursors: [SecondaryCursor] = []
    
    /// Whether we're in multi-cursor mode
    var isActive: Bool { !secondaryCursors.isEmpty }
    
    /// Weak reference to the text view
    weak var textView: TextView?
    
    // MARK: - Rendering
    
    /// Layers for secondary cursor carets
    private var cursorLayers: [CALayer] = []
    /// Layers for secondary cursor selections
    private var selectionLayers: [CALayer] = []
    
    /// Cursor blink timer
    private var blinkTimer: Timer?
    private var cursorVisible = true
    
    /// Appearance
    private let cursorWidth: CGFloat = 2
    private let cursorColor = UIColor.systemCyan
    private let selectionColor = UIColor.systemCyan.withAlphaComponent(0.25)
    
    // MARK: - Init
    
    init() {}
    
    deinit {
        blinkTimer?.invalidate()
    }
    
    // MARK: - Cursor Management
    
    /// Add a cursor at the given character offset
    func addCursor(at position: Int) {
        // Don't add duplicate
        guard !secondaryCursors.contains(where: { $0.position == position && $0.anchor == nil }) else { return }
        
        // Don't add at primary cursor position
        if let tv = textView, tv.selectedRange.length == 0, tv.selectedRange.location == position {
            return
        }
        
        secondaryCursors.append(SecondaryCursor(position: position))
        sortCursors()
        startBlinkingIfNeeded()
        updateDisplay()
    }
    
    /// Add a cursor with selection
    func addCursorWithSelection(position: Int, anchor: Int) {
        // Don't add duplicate at same range
        let newRange = NSRange(location: min(position, anchor), length: abs(position - anchor))
        guard !secondaryCursors.contains(where: { $0.selectionRange == newRange }) else { return }
        
        // Don't add if it matches the primary selection
        if let tv = textView, tv.selectedRange == newRange {
            return
        }
        
        secondaryCursors.append(SecondaryCursor(position: position, anchor: anchor))
        sortCursors()
        startBlinkingIfNeeded()
        updateDisplay()
    }
    
    /// Reset to single cursor (exit multi-cursor mode)
    func reset() {
        secondaryCursors.removeAll()
        clearDisplay()
        blinkTimer?.invalidate()
        blinkTimer = nil
    }
    
    /// Remove duplicate cursors that collapsed to same position
    private func removeDuplicates() {
        var seen = Set<Int>()
        // Include primary cursor position
        if let tv = textView {
            if tv.selectedRange.length == 0 {
                seen.insert(tv.selectedRange.location)
            }
        }
        secondaryCursors = secondaryCursors.filter { cursor in
            let pos = cursor.position
            if seen.contains(pos) && cursor.anchor == nil {
                return false
            }
            seen.insert(pos)
            return true
        }
    }
    
    private func sortCursors() {
        secondaryCursors.sort { $0.position < $1.position }
    }
    
    // MARK: - Cursor Movement (Add Above/Below)
    
    /// Add a cursor on the line above the topmost cursor
    func addCursorAbove() {
        guard let tv = textView else { return }
        let text = tv.text as NSString
        
        // Find the topmost cursor position (could be primary or a secondary)
        let primaryPos = tv.selectedRange.location
        let topmostSecondary = secondaryCursors.first?.position ?? Int.max
        let topmostPos = min(primaryPos, topmostSecondary)
        
        // Find current line and column
        let lineRange = text.lineRange(for: NSRange(location: topmostPos, length: 0))
        let column = topmostPos - lineRange.location
        
        // Find previous line
        guard lineRange.location > 0 else { return }
        let prevLineEnd = lineRange.location - 1
        let prevLineRange = text.lineRange(for: NSRange(location: prevLineEnd, length: 0))
        let prevLineLength = prevLineRange.length - (text.substring(with: prevLineRange).hasSuffix("\n") ? 1 : 0)
        
        let targetPos = prevLineRange.location + min(column, prevLineLength)
        addCursor(at: targetPos)
    }
    
    /// Add a cursor on the line below the bottommost cursor
    func addCursorBelow() {
        guard let tv = textView else { return }
        let text = tv.text as NSString
        
        // Find the bottommost cursor position
        let primaryPos = tv.selectedRange.location
        let bottommostSecondary = secondaryCursors.last?.position ?? -1
        let bottommostPos = max(primaryPos, bottommostSecondary)
        
        // Find current line and column
        let lineRange = text.lineRange(for: NSRange(location: bottommostPos, length: 0))
        let column = bottommostPos - lineRange.location
        
        // Find next line
        let nextLineStart = lineRange.location + lineRange.length
        guard nextLineStart < text.length else { return }
        let nextLineRange = text.lineRange(for: NSRange(location: nextLineStart, length: 0))
        let nextLineLength = nextLineRange.length - (text.substring(with: nextLineRange).hasSuffix("\n") ? 1 : 0)
        
        let targetPos = nextLineRange.location + min(column, nextLineLength)
        addCursor(at: targetPos)
    }
    
    // MARK: - Add Next Occurrence (Cmd+D)
    
    /// Adds a cursor at the next occurrence of the currently selected text
    func addNextOccurrence() {
        guard let tv = textView else { return }
        let nsText = tv.text as NSString
        let selectedRange = tv.selectedRange
        
        // Need a selection to find occurrences
        guard selectedRange.length > 0 else {
            // Auto-select word under cursor first
            selectWordUnderCursor()
            return
        }
        
        let searchText = nsText.substring(with: selectedRange)
        
        // Collect all existing cursor selection ranges to skip
        var existingRanges: [NSRange] = [selectedRange]
        for cursor in secondaryCursors {
            if let range = cursor.selectionRange {
                existingRanges.append(range)
            }
        }
        
        // Search from after the last cursor
        let allPositions = existingRanges.map { $0.location + $0.length }.sorted()
        let searchStart = allPositions.last ?? (selectedRange.location + selectedRange.length)
        
        // Search forward from searchStart
        if let found = findNextOccurrence(of: searchText, in: nsText, after: searchStart, excluding: existingRanges) {
            addCursorWithSelection(position: found.location + found.length, anchor: found.location)
            return
        }
        
        // Wrap around from beginning
        if let found = findNextOccurrence(of: searchText, in: nsText, after: 0, excluding: existingRanges) {
            addCursorWithSelection(position: found.location + found.length, anchor: found.location)
        }
    }
    
    /// Select all occurrences of the current selection/word
    func selectAllOccurrences() {
        guard let tv = textView else { return }
        let nsText = tv.text as NSString
        var selectedRange = tv.selectedRange
        
        // If nothing selected, select word under cursor
        if selectedRange.length == 0 {
            let wordRange = wordRangeAtPosition(selectedRange.location, in: nsText)
            guard let wr = wordRange else { return }
            tv.selectedRange = wr
            selectedRange = wr
        }
        
        let searchText = nsText.substring(with: selectedRange)
        guard !searchText.isEmpty else { return }
        
        // Find all occurrences
        var occurrences: [NSRange] = []
        var searchRange = NSRange(location: 0, length: nsText.length)
        while searchRange.location < nsText.length {
            let found = nsText.range(of: searchText, options: [], range: searchRange)
            if found.location == NSNotFound { break }
            occurrences.append(found)
            searchRange.location = found.location + found.length
            searchRange.length = nsText.length - searchRange.location
        }
        
        guard occurrences.count > 1 else { return }
        
        // Primary cursor keeps the first occurrence (or current selection)
        // Add secondary cursors for all others
        reset() // Clear existing secondaries
        
        let primaryRange = selectedRange
        for occurrence in occurrences {
            if occurrence == primaryRange { continue }
            addCursorWithSelection(position: occurrence.location + occurrence.length, anchor: occurrence.location)
        }
    }
    
    // MARK: - Text Editing
    
    /// Insert text at all cursor positions. Returns true if handled (multi-cursor mode).
    func insertText(_ text: String) -> Bool {
        guard isActive, let tv = textView else { return false }
        
        // Gather all edit sites: primary + secondaries, sorted by position
        var editSites = gatherEditSites()
        
        let nsText = NSMutableString(string: tv.text)
        var delta = 0
        // FIX: Use UTF-16 length for all delta/offset math since NSRange/NSMutableString use UTF-16
        let textUTF16Len = (text as NSString).length
        
        tv.undoManager?.beginUndoGrouping()
        
        for i in 0..<editSites.count {
            let site = editSites[i]
            
            if let selRange = site.selectionRange {
                // Replace selection
                let effectiveRange = NSRange(location: selRange.location + delta, length: selRange.length)
                nsText.replaceCharacters(in: effectiveRange, with: text)
                let newPos = effectiveRange.location + textUTF16Len
                editSites[i].position = newPos - delta // Store pre-delta for later adjustment
                delta += textUTF16Len - selRange.length
            } else {
                // Insert at position
                let effectivePos = site.position + delta
                let clamped = min(max(0, effectivePos), nsText.length)
                nsText.insert(text, at: clamped)
                editSites[i].position = clamped - delta + textUTF16Len
                delta += textUTF16Len
            }
        }
        
        // Apply the combined edit
        tv.text = nsText as String
        tv.undoManager?.endUndoGrouping()
        
        // Redistribute cursor positions
        redistributeCursors(from: editSites, insertedLength: textUTF16Len)
        
        return true
    }
    
    /// Delete backward at all cursor positions. Returns true if handled.
    func deleteBackward() -> Bool {
        guard isActive, let tv = textView else { return false }
        
        var editSites = gatherEditSites()
        let nsText = NSMutableString(string: tv.text)
        var delta = 0
        
        tv.undoManager?.beginUndoGrouping()
        
        for i in 0..<editSites.count {
            let site = editSites[i]
            
            if let selRange = site.selectionRange {
                // Delete selection
                let effectiveRange = NSRange(location: selRange.location + delta, length: selRange.length)
                guard effectiveRange.location >= 0, effectiveRange.location + effectiveRange.length <= nsText.length else { continue }
                nsText.deleteCharacters(in: effectiveRange)
                editSites[i].position = effectiveRange.location - delta
                editSites[i].anchor = nil
                delta -= selRange.length
            } else {
                // FIX: Delete composed character sequence before cursor (handles emoji, CJK etc.)
                let effectivePos = site.position + delta
                guard effectivePos > 0 else { continue }
                let charRange = nsText.rangeOfComposedCharacterSequence(at: effectivePos - 1)
                guard charRange.location >= 0, charRange.location + charRange.length <= nsText.length else { continue }
                nsText.deleteCharacters(in: charRange)
                editSites[i].position = site.position - charRange.length
                delta -= charRange.length
            }
        }
        
        tv.text = nsText as String
        tv.undoManager?.endUndoGrouping()
        
        redistributeCursors(from: editSites, insertedLength: 0)
        
        return true
    }
    
    // MARK: - Edit Site Helpers
    
    private struct EditSite {
        var position: Int
        var anchor: Int?
        var isPrimary: Bool
        
        var selectionRange: NSRange? {
            guard let anchor = anchor, anchor != position else { return nil }
            let start = min(position, anchor)
            let length = abs(position - anchor)
            return NSRange(location: start, length: length)
        }
    }
    
    /// Gather all cursor positions (primary + secondary), sorted by position
    private func gatherEditSites() -> [EditSite] {
        guard let tv = textView else { return [] }
        
        var sites: [EditSite] = []
        
        // Primary cursor
        let sel = tv.selectedRange
        if sel.length > 0 {
            sites.append(EditSite(position: sel.location + sel.length, anchor: sel.location, isPrimary: true))
        } else {
            sites.append(EditSite(position: sel.location, anchor: nil, isPrimary: true))
        }
        
        // Secondary cursors
        for cursor in secondaryCursors {
            sites.append(EditSite(position: cursor.position, anchor: cursor.anchor, isPrimary: false))
        }
        
        // Sort by position (process left to right)
        sites.sort { ($0.selectionRange?.location ?? $0.position) < ($1.selectionRange?.location ?? $1.position) }
        
        return sites
    }
    
    /// After edits, redistribute cursor positions
    private func redistributeCursors(from editSites: [EditSite], insertedLength: Int) {
        guard let tv = textView else { return }
        
        var newSecondaries: [SecondaryCursor] = []
        
        // Recalculate positions accounting for cumulative deltas
        var delta = 0
        for site in editSites {
            let newPos = site.position + delta
            if site.isPrimary {
                tv.selectedRange = NSRange(location: max(0, newPos), length: 0)
            } else {
                newSecondaries.append(SecondaryCursor(position: max(0, newPos)))
            }
        }
        
        secondaryCursors = newSecondaries
        removeDuplicates()
        
        if secondaryCursors.isEmpty {
            reset()
        } else {
            updateDisplay()
        }
    }
    
    // MARK: - Occurrence Finding Helpers
    
    private func findNextOccurrence(of searchText: String, in nsText: NSString, after startPos: Int, excluding: [NSRange]) -> NSRange? {
        var searchRange = NSRange(location: startPos, length: nsText.length - startPos)
        while searchRange.location < nsText.length && searchRange.length > 0 {
            let found = nsText.range(of: searchText, options: [], range: searchRange)
            if found.location == NSNotFound { return nil }
            
            // Check if this range is already selected
            let isExcluded = excluding.contains { $0.location == found.location && $0.length == found.length }
            if !isExcluded {
                return found
            }
            
            searchRange.location = found.location + found.length
            searchRange.length = nsText.length - searchRange.location
        }
        return nil
    }
    
    private func selectWordUnderCursor() {
        guard let tv = textView else { return }
        let nsText = tv.text as NSString
        let pos = tv.selectedRange.location
        
        guard let wordRange = wordRangeAtPosition(pos, in: nsText) else { return }
        tv.selectedRange = wordRange
    }
    
    private func wordRangeAtPosition(_ pos: Int, in nsText: NSString) -> NSRange? {
        let wordChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        var wordStart = pos
        var wordEnd = pos
        
        while wordStart > 0 {
            let ch = nsText.character(at: wordStart - 1)
            guard let scalar = Unicode.Scalar(ch), wordChars.contains(scalar) else { break }
            wordStart -= 1
        }
        while wordEnd < nsText.length {
            let ch = nsText.character(at: wordEnd)
            guard let scalar = Unicode.Scalar(ch), wordChars.contains(scalar) else { break }
            wordEnd += 1
        }
        
        guard wordEnd > wordStart else { return nil }
        return NSRange(location: wordStart, length: wordEnd - wordStart)
    }
    
    // MARK: - Display / Rendering
    
    /// Update the visual display of all secondary cursors and selections
    func updateDisplay() {
        clearDisplay()
        guard let tv = textView, isActive else { return }
        
        for cursor in secondaryCursors {
            // Draw selection if present
            if let selRange = cursor.selectionRange {
                drawSelection(for: selRange, in: tv)
            }
            
            // Draw cursor caret
            drawCursor(at: cursor.position, in: tv)
        }
    }
    
    private func clearDisplay() {
        cursorLayers.forEach { $0.removeFromSuperlayer() }
        cursorLayers.removeAll()
        selectionLayers.forEach { $0.removeFromSuperlayer() }
        selectionLayers.removeAll()
    }
    
    private func drawCursor(at position: Int, in tv: TextView) {
        // Use UITextInput protocol to find caret rect
        guard let textPosition = tv.position(from: tv.beginningOfDocument, offset: position) else { return }
        let caretRect = tv.caretRect(for: textPosition)
        guard !caretRect.isNull && !caretRect.isInfinite else { return }
        
        let layer = CALayer()
        layer.backgroundColor = cursorColor.cgColor
        layer.frame = CGRect(
            x: caretRect.origin.x,
            y: caretRect.origin.y,
            width: cursorWidth,
            height: caretRect.height
        )
        layer.cornerRadius = 1
        layer.opacity = cursorVisible ? 1.0 : 0.0
        layer.name = "multiCursorCaret"
        layer.zPosition = 200
        
        tv.layer.addSublayer(layer)
        cursorLayers.append(layer)
    }
    
    private func drawSelection(for range: NSRange, in tv: TextView) {
        guard let start = tv.position(from: tv.beginningOfDocument, offset: range.location),
              let end = tv.position(from: tv.beginningOfDocument, offset: range.location + range.length),
              let textRange = tv.textRange(from: start, to: end) else { return }
        
        let rects = tv.selectionRects(for: textRange)
        
        for rect in rects {
            let selLayer = CALayer()
            selLayer.backgroundColor = selectionColor.cgColor
            selLayer.frame = rect.rect
            selLayer.name = "multiCursorSelection"
            selLayer.zPosition = 150
            
            // Insert behind text
            if let firstSublayer = tv.layer.sublayers?.first {
                tv.layer.insertSublayer(selLayer, below: firstSublayer)
            } else {
                tv.layer.addSublayer(selLayer)
            }
            selectionLayers.append(selLayer)
        }
    }
    
    // MARK: - Blink Animation
    
    private func startBlinkingIfNeeded() {
        guard blinkTimer == nil else { return }
        cursorVisible = true
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.cursorVisible.toggle()
                self.cursorLayers.forEach { $0.opacity = self.cursorVisible ? 1.0 : 0.0 }
            }
        }
    }
}
