import SwiftUI

class AutocompleteManager: ObservableObject {
    @Published var suggestions: [String] = []
    @Published var showSuggestions = false
    @Published var selectedIndex = 0
    
    private let keywords = [
        "import", "func", "var", "let", "class", "struct", "enum",
        "if", "else", "for", "while", "switch", "case", "return",
        "true", "false", "nil", "self", "super", "init", "deinit",
        "extension", "protocol", "typealias", "static", "private",
        "public", "internal", "fileprivate", "open", "final"
    ]
    
    func updateSuggestions(for text: String, cursorPosition: Int) {
        // Get the current word being typed
        let beforeCursor = String(text.prefix(cursorPosition))
        let words = beforeCursor.split { $0.isWhitespace || $0.isPunctuation }
        
        guard let currentWord = words.last, currentWord.count > 0 else {
            suggestions = []
            showSuggestions = false
            return
        }
        
        let wordString = String(currentWord).lowercased()
        suggestions = keywords.filter { $0.lowercased().hasPrefix(wordString) }
        showSuggestions = !suggestions.isEmpty
        selectedIndex = 0
    }
    
    func selectNext() {
        if selectedIndex < suggestions.count - 1 {
            selectedIndex += 1
        }
    }
    
    func selectPrevious() {
        if selectedIndex > 0 {
            selectedIndex -= 1
        }
    }
    
    func getCurrentSuggestion() -> String? {
        guard showSuggestions, selectedIndex < suggestions.count else { return nil }
        return suggestions[selectedIndex]
    }
}