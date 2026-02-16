import Foundation
import UIKit

/// Highlights all occurrences of the currently selected word in the editor.
/// This is a key VSCode feature - when you select/double-click a word, all other
/// instances get a subtle background highlight.
final class WordOccurrenceHighlighter {
    static let shared = WordOccurrenceHighlighter()
    private init() {}
    
    // MARK: - Configuration
    
    /// Minimum word length to trigger highlighting
    var minimumWordLength: Int = 2
    
    /// Maximum occurrences to highlight (for performance)
    var maxOccurrences: Int = 500
    
    /// Whether highlighting is enabled
    var isEnabled: Bool = true
    
    // MARK: - Models
    
    struct Occurrence: Equatable {
        let range: NSRange
        let lineNumber: Int
    }
    
    // MARK: - Public API
    
    /// Finds all occurrences of the word at the given selection.
    /// Returns empty array if selection is not a valid word.
    func findOccurrences(in text: String, selection: NSRange) -> [Occurrence] {
        guard isEnabled else { return [] }
        guard !text.isEmpty else { return [] }
        
        // Get the selected word (or word at cursor)
        let selectedWord = getWordAtSelection(in: text, selection: selection)
        guard let word = selectedWord, word.count >= minimumWordLength else { return [] }
        
        // Don't highlight if selection spans multiple words
        if selection.length > 0 {
            let selectedText = (text as NSString).substring(with: selection)
            if selectedText.contains(" ") || selectedText.contains("\n") {
                return []
            }
        }
        
        return findAllOccurrences(of: word, in: text)
    }
    
    /// Finds all occurrences of a specific word in text.
    func findAllOccurrences(of word: String, in text: String) -> [Occurrence] {
        guard !word.isEmpty, !text.isEmpty else { return [] }
        
        var occurrences: [Occurrence] = []
        let nsText = text as NSString
        let textLength = nsText.length
        
        // Use word boundary matching for whole words only
        var searchStart = 0
        var count = 0
        
        while searchStart < textLength && count < maxOccurrences {
            let searchRange = NSRange(location: searchStart, length: textLength - searchStart)
            let foundRange = nsText.range(of: word, options: .literal, range: searchRange)
            
            if foundRange.location == NSNotFound {
                break
            }
            
            // Check word boundaries
            if isWholeWord(range: foundRange, in: nsText) {
                let lineNumber = lineNumber(at: foundRange.location, in: nsText)
                occurrences.append(Occurrence(range: foundRange, lineNumber: lineNumber))
                count += 1
            }
            
            searchStart = foundRange.location + foundRange.length
        }
        
        return occurrences
    }
    
    /// Gets the word at or around the selection/cursor position.
    func getWordAtSelection(in text: String, selection: NSRange) -> String? {
        let nsText = text as NSString
        let length = nsText.length
        
        guard length > 0 else { return nil }
        
        // If there's a selection, use it directly
        if selection.length > 0 && selection.location + selection.length <= length {
            let selectedText = nsText.substring(with: selection)
            // Validate it's a word (no spaces/newlines)
            if !selectedText.contains(" ") && !selectedText.contains("\n") && !selectedText.contains("\t") {
                return selectedText
            }
            return nil
        }
        
        // Otherwise, find the word at cursor position
        let cursorPos = min(selection.location, length)
        return wordAt(position: cursorPos, in: nsText)
    }
    
    // MARK: - Private Helpers
    
    private func wordAt(position: Int, in text: NSString) -> String? {
        let length = text.length
        guard position >= 0, position <= length else { return nil }
        
        // Find word start
        var start = position
        while start > 0 {
            let char = text.character(at: start - 1)
            if !isWordCharacter(char) {
                break
            }
            start -= 1
        }
        
        // Find word end
        var end = position
        while end < length {
            let char = text.character(at: end)
            if !isWordCharacter(char) {
                break
            }
            end += 1
        }
        
        guard end > start else { return nil }
        
        let range = NSRange(location: start, length: end - start)
        return text.substring(with: range)
    }
    
    private func isWordCharacter(_ char: unichar) -> Bool {
        // Letters, digits, underscore
        let scalar = Unicode.Scalar(char)
        if let s = scalar {
            return CharacterSet.alphanumerics.contains(s) || char == 95 // underscore
        }
        return false
    }
    
    private func isWholeWord(range: NSRange, in text: NSString) -> Bool {
        let length = text.length
        
        // Check character before
        if range.location > 0 {
            let charBefore = text.character(at: range.location - 1)
            if isWordCharacter(charBefore) {
                return false
            }
        }
        
        // Check character after
        let afterPos = range.location + range.length
        if afterPos < length {
            let charAfter = text.character(at: afterPos)
            if isWordCharacter(charAfter) {
                return false
            }
        }
        
        return true
    }
    
    private func lineNumber(at position: Int, in text: NSString) -> Int {
        var line = 0
        var pos = 0
        
        while pos < position && pos < text.length {
            if text.character(at: pos) == 10 { // newline
                line += 1
            }
            pos += 1
        }
        
        return line
    }
}

// MARK: - Highlight Colors

extension WordOccurrenceHighlighter {
    /// Background color for word occurrence highlights (matches VSCode's subtle highlight)
    static func highlightColor(for theme: Theme) -> UIColor {
        if theme.isDark {
            return UIColor(white: 1.0, alpha: 0.1)
        } else {
            return UIColor(white: 0.0, alpha: 0.07)
        }
    }
    
    /// Border color for word occurrence highlights
    static func borderColor(for theme: Theme) -> UIColor {
        if theme.isDark {
            return UIColor(white: 1.0, alpha: 0.2)
        } else {
            return UIColor(white: 0.0, alpha: 0.15)
        }
    }
}
