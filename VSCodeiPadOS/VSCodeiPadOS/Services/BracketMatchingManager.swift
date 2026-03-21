import Foundation
import UIKit
import TreeSitter

/// Manages bracket matching and highlighting for the editor.
/// Supports: (), [], {}, <> (in certain contexts)
///
/// When a TreeSitter language is configured via ``setTreeSitterLanguage(_:)``,
/// uses AST-aware analysis to accurately detect strings and comments across
/// all supported languages. Falls back to a character-level scanner when
/// TreeSitter is unavailable.
final class BracketMatchingManager: @unchecked Sendable {
    static let shared = BracketMatchingManager()
    private init() {}

    // MARK: - TreeSitter Integration

    /// TreeSitter language pointer for the current document.
    /// Set by the editor Coordinator when a file with TreeSitter support is loaded.
    /// When nil, bracket matching falls back to the character-level scanner.
    private var _tsLanguagePointer: UnsafePointer<TSLanguage>?
    private var _tsParser: OpaquePointer?
    private var _tsTree: OpaquePointer?
    private var _tsCachedUTF16: [UInt16]?

    /// Configure the TreeSitter language for AST-aware bracket matching.
    /// Call with `nil` when switching to a file without TreeSitter support.
    func setTreeSitterLanguage(_ pointer: UnsafePointer<TSLanguage>?) {
        // Clean up old parse tree
        if let tree = _tsTree { ts_tree_delete(tree); _tsTree = nil }
        _tsCachedUTF16 = nil
        _tsLanguagePointer = pointer
        // Reset parser so it picks up the new language
        if let parser = _tsParser { ts_parser_delete(parser); _tsParser = nil }
    }

    /// Lazily create or return the cached TreeSitter parser configured with the current language.
    private func tsParser() -> OpaquePointer? {
        guard let langPtr = _tsLanguagePointer else { return nil }
        if let existing = _tsParser { return existing }
        let parser = ts_parser_new()
        ts_parser_set_language(parser, langPtr)
        _tsParser = parser
        return parser
    }

    /// Returns a cached or freshly parsed TreeSitter syntax tree for the text.
    /// Returns nil if TreeSitter is not configured or parsing fails.
    private func getCachedTree(for text: String) -> OpaquePointer? {
        guard _tsLanguagePointer != nil else { return nil }

        let utf16 = Array(text.utf16)

        // Reuse cached tree if text (UTF-16 representation) hasn't changed
        if let cached = _tsCachedUTF16, cached == utf16, let tree = _tsTree {
            return tree
        }

        // Invalidate stale tree
        if let oldTree = _tsTree { ts_tree_delete(oldTree); _tsTree = nil }

        guard let parser = tsParser() else { return nil }
        let byteCount = utf16.count * 2
        guard byteCount > 0 else { return nil }

        let newTree: OpaquePointer? = utf16.withUnsafeBufferPointer { ptr -> OpaquePointer? in
            guard let base = ptr.baseAddress else { return nil }
            let bytes = UnsafeRawPointer(base).assumingMemoryBound(to: UInt8.self)
            return ts_parser_parse_string_encoding(
                parser, nil, bytes, UInt32(byteCount), TSInputEncodingUTF16
            )
        }

        guard let tree = newTree else { return nil }
        _tsTree = tree
        _tsCachedUTF16 = utf16
        return tree
    }

    deinit {
        if let tree = _tsTree { ts_tree_delete(tree) }
        if let parser = _tsParser { ts_parser_delete(parser) }
    }

    // MARK: - TreeSitter AST Node Types

    /// Node types that represent string literals across TreeSitter grammars.
    private static let tsStringNodeTypes: Set<String> = [
        "string", "string_literal", "template_string",
        "interpreted_string_literal", "raw_string_literal",
        "char_literal", "character",
        "string_content", "template_literal", "string_expression",
        "quoted_string", "double_quoted_string", "single_quoted_string",
        "triple_quoted_string", "raw_string", "heredoc_string",
        "doc_string", "f_string", "fstring", "concatenated_string",
        "system_string_literal", "string_fragment", "escape_sequence",
    ]

    /// Node types that represent comments across TreeSitter grammars.
    private static let tsCommentNodeTypes: Set<String> = [
        "comment", "line_comment", "block_comment",
        "documentation_comment", "doc_comment",
        "multiline_comment", "single_line_comment",
    ]

    /// Check if a TreeSitter node (or any of its ancestors) represents a string or comment.
    /// Walks up the tree because brackets inside strings may appear in inner anonymous nodes
    /// (e.g. `string_content` inside `string_literal`).
    private func tsNodeIsStringOrComment(_ node: TSNode) -> Bool {
        var current = node
        // Walk up at most 8 ancestors to avoid pathological cases
        for _ in 0..<8 {
            if ts_node_is_null(current) { return false }
            if let typeStr = ts_node_type(current) {
                let nodeType = String(cString: typeStr)
                if Self.tsStringNodeTypes.contains(nodeType) || Self.tsCommentNodeTypes.contains(nodeType) {
                    return true
                }
            }
            current = ts_node_parent(current)
        }
        return false
    }

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
                // Skip brackets inside strings or comments (TreeSitter-aware)
                if Self.isInsideStringOrComment(in: text, at: checkPos, manager: self) { return nil }
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
        
        for (index, char) in chars.enumerated() {
            // Skip brackets inside strings, comments, or template strings (TreeSitter-aware)
            if Self.isInsideStringOrComment(in: text, at: index, manager: self) { continue }
            
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
    
    // MARK: - String/Comment Detection (TreeSitter + Scanner Fallback)
    
    /// Determines if a character at `position` in `text` is inside a string literal,
    /// line comment, or block comment.
    ///
    /// **TreeSitter path:** Uses the parsed syntax tree (if available) to check whether
    /// the node at the given byte offset is a string or comment type. This correctly
    /// handles language-specific string/comment syntax (e.g. Python `"""`, Go backtick
    /// raw strings, Rust `r"…"`, Swift multiline `"""`, etc.).
    ///
    /// **Fallback:** When no TreeSitter tree is available, falls back to the character-
    /// level scanner that handles C-style `//`/`/* */` comments, double/single-quoted
    /// strings, and JavaScript-style backtick template strings.
    ///
    /// - Parameters:
    ///   - text: The full source text.
    ///   - position: Character index (UTF-16 compatible) to test.
    ///   - manager: The `BracketMatchingManager` instance that holds the TreeSitter state.
    static func isInsideStringOrComment(in text: String, at position: Int, manager: BracketMatchingManager = .shared) -> Bool {
        // --- TreeSitter AST path ---
        if let tree = manager.getCachedTree(for: text) {
            let rootNode = ts_tree_root_node(tree)
            // Convert position to UTF-16 byte offset for TreeSitter
            let byteOffset = UInt32(position * 2)
            let point = TSPoint(row: 0, column: 0)
            // Use descendant_for_byte_range to find the deepest node at the byte offset
            let node = ts_node_descendant_for_byte_range(rootNode, byteOffset, byteOffset)
            if !ts_node_is_null(node) && manager.tsNodeIsStringOrComment(node) {
                return true
            }
            // TreeSitter says it's NOT inside a string/comment — trust it and return false.
            // Only fall through to the scanner if TreeSitter couldn't parse at all.
            return false
        }

        // --- Character-level scanner fallback ---
        return isInsideStringOrCommentScanner(in: text, at: position)
    }

    /// Character-level scanner for string/comment detection.
    /// Handles C-style comments, quoted strings, and backtick template strings.
    /// Used as a fallback when TreeSitter is unavailable.
    private static func isInsideStringOrCommentScanner(in text: String, at position: Int) -> Bool {
        let chars = Array(text.unicodeScalars.prefix(position + 1))
        var inLineComment = false
        var inBlockComment = false
        var inString = false
        var stringChar: UnicodeScalar = "\""
        var inTemplateString = false
        var i = 0
        while i < position {
            guard i < chars.count else { break }
            let c = chars[i]
            let next: UnicodeScalar? = (i + 1 < chars.count) ? chars[i + 1] : nil
            if inBlockComment {
                if c == "*" && next == "/" { inBlockComment = false; i += 2; continue }
                i += 1; continue
            }
            if inLineComment {
                if c == "\n" { inLineComment = false }
                i += 1; continue
            }
            if inString || inTemplateString {
                if c == "\\" { i += 2; continue }
                if inTemplateString && c == "`" { inTemplateString = false; i += 1; continue }
                if inString && c == stringChar { inString = false; i += 1; continue }
                i += 1; continue
            }
            if c == "/" && next == "/" { inLineComment = true; i += 2; continue }
            if c == "/" && next == "*" { inBlockComment = true; i += 2; continue }
            if c == "\"" || c == "'" { inString = true; stringChar = c; i += 1; continue }
            if c == "`" { inTemplateString = true; i += 1; continue }
            i += 1
        }
        return inString || inLineComment || inBlockComment || inTemplateString
    }
    
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
