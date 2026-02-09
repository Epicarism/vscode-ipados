import SwiftUI
import UIKit

// Efficient NSMutableAttributedString-based syntax highlighter
class NSAttributedStringSyntaxHighlighter {
    // Color scheme for syntax highlighting
    private struct ColorScheme {
        static let keyword = UIColor.systemBlue
        static let string = UIColor.systemGreen
        static let comment = UIColor.systemGray
        static let number = UIColor.systemPurple
        static let function = UIColor.systemYellow
        static let variable = UIColor.systemOrange
        static let defaultText = UIColor.label
    }
    
    // Common Swift keywords
    private static let swiftKeywords = Set([
        "func", "var", "let", "if", "else", "for", "while", "switch", "case",
        "return", "import", "class", "struct", "enum", "protocol", "extension",
        "private", "public", "internal", "static", "self", "init", "deinit",
        "throw", "throws", "try", "catch", "guard", "defer", "async", "await",
        "override", "final", "lazy", "weak", "unowned", "mutating", "nonmutating",
        "typealias", "associatedtype", "where", "true", "false", "nil"
    ])
    
    // Efficient highlighting using NSMutableAttributedString
    static func highlightCode(_ code: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: code)
        let fullRange = NSRange(location: 0, length: code.utf16.count)
        
        // Set default attributes
        attributedString.addAttributes([
            .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            .foregroundColor: ColorScheme.defaultText
        ], range: fullRange)
        
        // Apply syntax highlighting
        highlightComments(in: attributedString, text: code)
        highlightStrings(in: attributedString, text: code)
        highlightKeywords(in: attributedString, text: code)
        highlightNumbers(in: attributedString, text: code)
        highlightFunctions(in: attributedString, text: code)
        
        return attributedString
    }
    
    private static func highlightComments(in attributedString: NSMutableAttributedString, text: String) {
        // Single-line comments
        let singleLinePattern = "//[^\n]*"
        applyHighlighting(pattern: singleLinePattern, color: ColorScheme.comment, to: attributedString, in: text)
        
        // Multi-line comments
        let multiLinePattern = "/\\*[\\s\\S]*?\\*/"
        applyHighlighting(pattern: multiLinePattern, color: ColorScheme.comment, to: attributedString, in: text)
    }
    
    private static func highlightStrings(in attributedString: NSMutableAttributedString, text: String) {
        // Double-quoted strings
        let doubleQuotePattern = "\"(?:[^\"\\\\]|\\\\.)*\""
        applyHighlighting(pattern: doubleQuotePattern, color: ColorScheme.string, to: attributedString, in: text)
        
        // Triple-quoted strings
        let tripleQuotePattern = "\"\"\"[\\s\\S]*?\"\"\""
        applyHighlighting(pattern: tripleQuotePattern, color: ColorScheme.string, to: attributedString, in: text)
    }
    
    private static func highlightKeywords(in attributedString: NSMutableAttributedString, text: String) {
        for keyword in swiftKeywords {
            let pattern = "\\b\(keyword)\\b"
            applyHighlighting(pattern: pattern, color: ColorScheme.keyword, to: attributedString, in: text)
        }
    }
    
    private static func highlightNumbers(in attributedString: NSMutableAttributedString, text: String) {
        let numberPattern = "\\b\\d+(?:\\.\\d+)?\\b"
        applyHighlighting(pattern: numberPattern, color: ColorScheme.number, to: attributedString, in: text)
    }
    
    private static func highlightFunctions(in attributedString: NSMutableAttributedString, text: String) {
        // Function calls
        let functionCallPattern = "\\b\\w+(?=\\s*\\()"
        applyHighlighting(pattern: functionCallPattern, color: ColorScheme.function, to: attributedString, in: text)
        
        // Function definitions
        let functionDefPattern = "(?<=func\\s)\\w+"
        applyHighlighting(pattern: functionDefPattern, color: ColorScheme.function, to: attributedString, in: text)
    }
    
    private static func applyHighlighting(pattern: String, color: UIColor, to attributedString: NSMutableAttributedString, in text: String) {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                attributedString.addAttribute(.foregroundColor, value: color, range: match.range)
            }
        } catch {
            print("Regex error for pattern \(pattern): \(error)")
        }
    }
}

// SwiftUI wrapper for NSAttributedString
struct AttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }
}

// Extension to make it easy to use in SwiftUI
extension View {
    func syntaxHighlighted(code: String) -> some View {
        AttributedTextView(attributedText: NSAttributedStringSyntaxHighlighter.highlightCode(code))
    }
}