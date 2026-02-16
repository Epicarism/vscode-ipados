import Foundation
import UIKit

/// Manages bracket matching and highlighting for the editor.
/// Supports: (), [], {}, <> (in certain contexts)
final class BracketMatchingManager {
    static let shared = BracketMatchingManager()
    private init() {}
    
    // MARK: - Models
    
    struct BracketPair: Equatable {
        let openIndex: Int
        let closeIndex: Int
        let type: BracketType
    }
    
    enum BracketType: Character, CaseIterable {
        case parenthesis = "("
        case square = "["
        case curly = "{"
        
        var open: Character {
            switch self {
            case .parenthesis: return "("
            case .square: return "["
            case .curly: return "{"
            }
        }
        
        var close: Character {
            switch self {
            case .parenthesis: return ")"
            case .square: return "]"
            case .curly: return "}"
            }
        }
        
        static func from(char: Character) -> (type: BracketType, isOpen: Bool)? {
            for type in BracketType.allCases {
                if char == type.open { return (type, true) }
                if char == type.close { return (type, false) }
            }
            return nil
        }
    }
    
    // MARK: - Public API
    
    /// Finds the matching bracket for the bracket at or near the given cursor position.
    /// Returns nil if no bracket is found at the cursor position.
    func findMatchingBracket(in text: String, cursorPosition: Int) -> BracketPair? {
        guard !text.isEmpty else { return nil }
        
        let chars = Array(text)
        let count = chars.count
        
        // Clamp cursor position
        let pos = max(0, min(cursorPosition, count))
        
        // Check character at cursor and before cursor
        let positionsToCheck = [pos, pos - 1].filter { $0 >= 0 && $0 < count }
        
        for checkPos in positionsToCheck {
            let char = chars[checkPos]
            
            if let (bracketType, isOpen) = BracketType.from(char: char) {
                if isOpen {
                    // Search forward for closing bracket
                    if let closeIndex = findClosingBracket(in: chars, from: checkPos, type: bracketType) {
                        return BracketPair(openIndex: checkPos, closeIndex: closeIndex, type: bracketType)
                    }
                } else {
                    // Search backward for opening bracket
                    if let openIndex = findOpeningBracket(in: chars, from: checkPos, type: bracketType) {
                        return BracketPair(openIndex: openIndex, closeIndex: checkPos, type: bracketType)
                    }
                }
            }
        }
        
        return nil
    }
    
    /// Finds all bracket pairs in the given text.
    /// Useful for rainbow bracket coloring.
    func findAllBracketPairs(in text: String) -> [BracketPair] {
        var pairs: [BracketPair] = []
        var stacks: [BracketType: [Int]] = [:]
        
        for type in BracketType.allCases {
            stacks[type] = []
        }
        
        let chars = Array(text)
        var inString = false
        var stringChar: Character = "\""
        var escapeNext = false
        
        for (index, char) in chars.enumerated() {
            // Handle escape sequences
            if escapeNext {
                escapeNext = false
                continue
            }
            
            if char == "\\" {
                escapeNext = true
                continue
            }
            
            // Handle string literals
            if char == "\"" || char == "'" {
                if !inString {
                    inString = true
                    stringChar = char
                } else if char == stringChar {
                    inString = false
                }
                continue
            }
            
            // Skip brackets inside strings
            if inString { continue }
            
            // Check for brackets
            if let (bracketType, isOpen) = BracketType.from(char: char) {
                if isOpen {
                    stacks[bracketType]?.append(index)
                } else {
                    if let openIndex = stacks[bracketType]?.popLast() {
                        pairs.append(BracketPair(openIndex: openIndex, closeIndex: index, type: bracketType))
                    }
                }
            }
        }
        
        return pairs.sorted { $0.openIndex < $1.openIndex }
    }
    
    /// Returns the nesting depth at a given position (for rainbow brackets).
    func nestingDepth(at position: Int, in text: String, type: BracketType? = nil) -> Int {
        let chars = Array(text)
        var depth = 0
        var inString = false
        var stringChar: Character = "\""
        var escapeNext = false
        
        for (index, char) in chars.enumerated() {
            if index >= position { break }
            
            if escapeNext {
                escapeNext = false
                continue
            }
            
            if char == "\\" {
                escapeNext = true
                continue
            }
            
            if char == "\"" || char == "'" {
                if !inString {
                    inString = true
                    stringChar = char
                } else if char == stringChar {
                    inString = false
                }
                continue
            }
            
            if inString { continue }
            
            if let (bracketType, isOpen) = BracketType.from(char: char) {
                if type == nil || bracketType == type {
                    depth += isOpen ? 1 : -1
                }
            }
        }
        
        return max(0, depth)
    }
    
    // MARK: - Private Helpers
    
    private func findClosingBracket(in chars: [Character], from startIndex: Int, type: BracketType) -> Int? {
        var depth = 1
        var inString = false
        var stringChar: Character = "\""
        var escapeNext = false
        
        for i in (startIndex + 1)..<chars.count {
            let char = chars[i]
            
            if escapeNext {
                escapeNext = false
                continue
            }
            
            if char == "\\" {
                escapeNext = true
                continue
            }
            
            if char == "\"" || char == "'" {
                if !inString {
                    inString = true
                    stringChar = char
                } else if char == stringChar {
                    inString = false
                }
                continue
            }
            
            if inString { continue }
            
            if char == type.open {
                depth += 1
            } else if char == type.close {
                depth -= 1
                if depth == 0 {
                    return i
                }
            }
        }
        
        return nil
    }
    
    private func findOpeningBracket(in chars: [Character], from startIndex: Int, type: BracketType) -> Int? {
        var depth = 1
        var inString = false
        var stringChar: Character = "\""
        
        // For backward search, we need a simpler approach since escape sequences are tricky
        // We'll do a basic scan that handles most common cases
        for i in stride(from: startIndex - 1, through: 0, by: -1) {
            let char = chars[i]
            
            // Simple string detection (not perfect but handles common cases)
            if char == "\"" || char == "'" {
                // Check if escaped
                if i > 0 && chars[i - 1] == "\\" {
                    continue
                }
                inString = !inString
                stringChar = char
                continue
            }
            
            if inString { continue }
            
            if char == type.close {
                depth += 1
            } else if char == type.open {
                depth -= 1
                if depth == 0 {
                    return i
                }
            }
        }
        
        return nil
    }
}

// MARK: - Rainbow Bracket Colors

extension BracketMatchingManager {
    /// Returns a color for the given nesting depth (for rainbow brackets).
    static func rainbowColor(forDepth depth: Int) -> UIColor {
        let colors: [UIColor] = [
            UIColor(red: 0.94, green: 0.78, blue: 0.18, alpha: 1.0),  // Gold
            UIColor(red: 0.85, green: 0.44, blue: 0.84, alpha: 1.0),  // Purple
            UIColor(red: 0.36, green: 0.72, blue: 0.82, alpha: 1.0),  // Cyan
            UIColor(red: 0.52, green: 0.79, blue: 0.31, alpha: 1.0),  // Green
            UIColor(red: 0.98, green: 0.55, blue: 0.38, alpha: 1.0),  // Orange
            UIColor(red: 0.64, green: 0.51, blue: 0.91, alpha: 1.0),  // Lavender
        ]
        return colors[depth % colors.count]
    }
    
    /// Highlight color for matching bracket pair
    static var matchHighlightColor: UIColor {
        UIColor.systemYellow.withAlphaComponent(0.3)
    }
    
    /// Background color for matched brackets
    static var matchBackgroundColor: UIColor {
        UIColor.systemBlue.withAlphaComponent(0.2)
    }
}
