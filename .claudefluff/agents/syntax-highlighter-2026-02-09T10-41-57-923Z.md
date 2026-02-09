# Agent: syntax-highlighter
**Status:** done
**Tokens:** 56,270
**Cost:** $0.0000
**Time:** 2026-02-09T10:41:57.923Z

## Task
Perfect syntax highlighting for ALL languages: Swift, JS, TS, JSX, TSX, Python, Ruby, Go, Rust, Java, Kotlin, C, C++, ObjC, HTML, CSS, SCSS, JSON, XML, YAML, SQL, Shell, Dockerfile, GraphQL, Markdown, PHP, .env

Update Extensions/NSAttributedStringSyntaxHighlighter.swift with proper regex for each. Keywords blue, types cyan, strings orange, comments gray, numbers green, functions yellow.

## Response
>>>TOOL read_file
{"path":"Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END

>>>TOOL search
{"query":"highlightCode(", "glob":"**/*"} 
>>>END>>>TOOL search
{"query":"syntaxHighlighted(code:", "glob":"**/*"} 
>>>END>>>TOOL search
{"query":"highlightCode(", "glob":"**/*"} 
>>>END
>>>TOOL search
{"query":"syntaxHighlighted(code:", "glob":"**/*"} 
>>>END

>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS"} 
>>>END

>>>TOOL search
{"query":"NSAttributedStringSyntaxHighlighter", "glob":"**/*"} 
>>>END

>>>TOOL search
{"query":"syntaxHighlighted", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END
>>>TOOL search
{"query":"highlightCode", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END
>>>TOOL search
{"query":"AttributedTextView(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END
>>>TOOL search
{"query":"NSAttributedStringSyntaxHighlighter", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Utilities/SyntaxHighlighter.swift"} 
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/SyntaxHighlighter.swift","start_line":1,"end_line":260} 
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/SyntaxHighlighter_Optimized.swift","start_line":1,"end_line":260} 
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/SyntaxHighlightedTextEditor.swift","start_line":1,"end_line":260} 
>>>END

>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions"} 
>>>END
>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Utilities"} 
>>>END
>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views"} 
>>>END

>>>TOOL search
{"query":".syntaxHighlighted(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END

>>>TOOL search
{"query":"fileExtension", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END
>>>TOOL search
{"query":"UTType", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END
>>>TOOL search
{"query":"language", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END
>>>TOOL search
{"query":"SyntaxHighlighter", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END



>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":200} 
>>>END

>>>TOOL search
{"query":"class SyntaxHighlighter", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END
>>>TOOL search
{"query":"struct SyntaxHighlighter", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END
>>>TOOL search
{"query":"SyntaxHighlighter", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":360} 
>>>END

>>>TOOL create_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift.patch","content":"placeholder"} 
>>>END>>>FILE VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift
>>>FIND
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
>>>REPLACE
import SwiftUI
import UIKit

// Efficient NSMutableAttributedString-based syntax highlighter (regex-based).
//
// Color mapping (per requirements):
// - Keywords: blue
// - Types: cyan
// - Strings: orange
// - Comments: gray
// - Numbers: green
// - Functions: yellow
final class NSAttributedStringSyntaxHighlighter {

    // MARK: - Language

    // NOTE: This file cannot use the name `Language` because the project already defines a global `Language`
    // enum elsewhere (VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift).
    enum SyntaxLanguage {
        case swift
        case javascript
        case typescript
        case jsx
        case tsx
        case python
        case ruby
        case go
        case rust
        case java
        case kotlin
        case c
        case cpp
        case objc
        case html
        case css
        case scss
        case json
        case xml
        case yaml
        case sql
        case shell
        case dockerfile
        case graphql
        case markdown
        case php
        case dotenv
        case plainText
    }

    // MARK: - Colors

    private struct ColorScheme {
        static let keyword = UIColor.systemBlue
        static let type = UIColor.systemCyan
        static let string = UIColor.systemOrange
        static let comment = UIColor.systemGray
        static let number = UIColor.systemGreen
        static let function = UIColor.systemYellow
        static let defaultText = UIColor.label
    }

    // MARK: - Public API

    /// Highlights `code`. If no `filename`/`language` is provided, defaults to Swift (to match previous behavior).
    static func highlightCode(_ code: String, filename: String? = nil, language: SyntaxLanguage? = nil) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: code)
        let fullRange = NSRange(location: 0, length: code.utf16.count)

        attributed.addAttributes([
            .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            .foregroundColor: ColorScheme.defaultText
        ], range: fullRange)

        let resolvedLanguage: SyntaxLanguage = {
            if let language { return language }
            if let filename { return detectLanguage(fromFilename: filename) }
            return .swift
        }()

        highlight(code: code, language: resolvedLanguage, into: attributed)
        return attributed
    }

    // MARK: - Core pipeline

    private static func highlight(code: String, language: SyntaxLanguage, into attributed: NSMutableAttributedString) {
        let rules = languageRules(for: language)

        // 1) Strings first
        let stringRanges: [NSRange] = rules.stringPatterns.flatMap { pattern in
            applyHighlighting(
                pattern: pattern,
                options: rules.stringRegexOptions,
                color: ColorScheme.string,
                to: attributed,
                in: code,
                captureGroup: nil,
                excluding: []
            )
        }

        // 2) Comments (exclude matches that intersect strings)
        let commentRanges: [NSRange] = rules.commentPatterns.flatMap { pattern in
            applyHighlighting(
                pattern: pattern,
                options: rules.commentRegexOptions,
                color: ColorScheme.comment,
                to: attributed,
                in: code,
                captureGroup: nil,
                excluding: stringRanges
            )
        }

        let protectedRanges = stringRanges + commentRanges

        // 3) Numbers
        if let numberPattern = rules.numberPattern {
            _ = applyHighlighting(
                pattern: numberPattern,
                options: rules.numberRegexOptions,
                color: ColorScheme.number,
                to: attributed,
                in: code,
                captureGroup: nil,
                excluding: protectedRanges
            )
        }

        // 4) Types
        for typePattern in rules.typePatterns {
            _ = applyHighlighting(
                pattern: typePattern.pattern,
                options: typePattern.options,
                color: ColorScheme.type,
                to: attributed,
                in: code,
                captureGroup: typePattern.captureGroup,
                excluding: protectedRanges
            )
        }

        // 5) Keywords
        if !rules.keywords.isEmpty {
            let keywordPattern = "\\b(?:" + rules.keywords.map(NSRegularExpression.escapedPattern).joined(separator: "|") + ")\\b"
            _ = applyHighlighting(
                pattern: keywordPattern,
                options: rules.keywordRegexOptions,
                color: ColorScheme.keyword,
                to: attributed,
                in: code,
                captureGroup: nil,
                excluding: protectedRanges
            )
        }

        // 6) Functions
        for fnPattern in rules.functionPatterns {
            _ = applyHighlighting(
                pattern: fnPattern.pattern,
                options: fnPattern.options,
                color: ColorScheme.function,
                to: attributed,
                in: code,
                captureGroup: fnPattern.captureGroup,
                excluding: protectedRanges
            )
        }
    }

    // MARK: - Rules

    private struct CapturePattern {
        let pattern: String
        let captureGroup: Int?
        let options: NSRegularExpression.Options
    }

    private struct LanguageRules {
        let keywords: [String]

        let typePatterns: [CapturePattern]

        let stringPatterns: [String]
        let stringRegexOptions: NSRegularExpression.Options

        let commentPatterns: [String]
        let commentRegexOptions: NSRegularExpression.Options

        let numberPattern: String?
        let numberRegexOptions: NSRegularExpression.Options

        let keywordRegexOptions: NSRegularExpression.Options
        let functionPatterns: [CapturePattern]
    }

    private static func languageRules(for language: SyntaxLanguage) -> LanguageRules {

        // Common numeric literal coverage (hex, float, exponent, underscores).
        // Also matches simple integers. (Does not attempt to validate all language-specific suffixes.)
        let commonNumber = "\\b(?:0x[0-9A-Fa-f_]+|\\d[\\d_]*(?:\\.\\d[\\d_]*)?(?:[eE][+-]?\\d[\\d_]*)?)\\b"

        // Common C-like strings:
        // - "..."
        // - '...'
        let cLikeStrings = [
            "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
            "'(?:[^'\\\\\\n]|\\\\.)*'"
        ]

        // Common C-like comments
        let cLikeComments = [
            "//[^\\n]*",
            "/\\*[\\s\\S]*?\\*/"
        ]

        // Common "function call" highlighting for many languages
        let commonFunctionCall = CapturePattern(
            pattern: "\\b([A-Za-z_][A-Za-z0-9_]*)\\s*(?=\\()",
            captureGroup: 1,
            options: []
        )

        switch language {

        case .swift:
            return LanguageRules(
                keywords: [
                    "func", "var", "let", "if", "else", "for", "while", "repeat", "switch", "case", "default",
                    "return", "import", "class", "struct", "enum", "protocol", "extension", "actor",
                    "private", "fileprivate", "public", "internal", "open", "static", "final", "override",
                    "self", "super", "init", "deinit",
                    "throw", "throws", "rethrows", "try", "catch", "do", "guard", "defer",
                    "async", "await",
                    "weak", "unowned", "mutating", "nonmutating",
                    "typealias", "associatedtype", "where", "in", "is", "as", "Any", "some", "any",
                    "true", "false", "nil"
                ],
                typePatterns: [
                    // Built-in common types
                    CapturePattern(
                        pattern: "\\b(?:String|Int|Int8|Int16|Int32|Int64|UInt|UInt8|UInt16|UInt32|UInt64|Double|Float|Bool|Character|Void|AnyObject|Never|Data|Date|URL|UUID|CGFloat)\\b",
                        captureGroup: nil,
                        options: []
                    ),
                    // General CamelCase type-ish identifiers
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    "\"\"\"[\\s\\S]*?\"\"\""
                ] + cLikeStrings,
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunc\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .javascript:
            return LanguageRules(
                keywords: [
                    "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete",
                    "do", "else", "export", "extends", "finally", "for", "function", "if", "import", "in",
                    "instanceof", "let", "new", "return", "super", "switch", "this", "throw", "try", "typeof",
                    "var", "void", "while", "with", "yield", "async", "await", "of", "true", "false", "null", "undefined"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings + [
                    // Template strings
                    "`(?:[^`\\\\]|\\\\.|\\$\\{[\\s\\S]*?\\})*`"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunction\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    // const foo = (...) => ...
                    CapturePattern(pattern: "\\b(?:const|let|var)\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*=\\s*(?:async\\s*)?\\(?", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .typescript, .tsx:
            return LanguageRules(
                keywords: [
                    // JS
                    "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete",
                    "do", "else", "export", "extends", "finally", "for", "function", "if", "import", "in",
                    "instanceof", "let", "new", "return", "super", "switch", "this", "throw", "try", "typeof",
                    "var", "void", "while", "with", "yield", "async", "await", "of", "true", "false", "null", "undefined",
                    // TS
                    "interface", "type", "enum", "implements", "namespace", "abstract", "declare", "readonly",
                    "private", "protected", "public", "keyof", "infer", "unknown", "never", "any", "as", "satisfies"
                ],
                typePatterns: [
                    // Built-in TS types
                    CapturePattern(pattern: "\\b(?:string|number|boolean|any|unknown|never|void|object|bigint|symbol)\\b", captureGroup: nil, options: []),
                    // PascalCase type identifiers
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings + [
                    "`(?:[^`\\\\]|\\\\.|\\$\\{[\\s\\S]*?\\})*`"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunction\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b([A-Za-z_][A-Za-z0-9_]*)\\s*<[^>]*>\\s*(?=\\()", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .jsx:
            // JSX is JavaScript + tag highlighting (handled via HTML-ish patterns in typePatterns)
            return LanguageRules(
                keywords: languageRules(for: .javascript).keywords,
                typePatterns: languageRules(for: .javascript).typePatterns + [
                    // JSX tag names: <Tag ...> or </Tag>
                    CapturePattern(pattern: "<\\/?\\s*([A-Za-z][A-Za-z0-9:_-]*)", captureGroup: 1, options: []),
                    // JSX attribute names: foo=
                    CapturePattern(pattern: "\\b([A-Za-z_:][A-Za-z0-9:._-]*)(?=\\s*=)", captureGroup: 1, options: [])
                ],
                stringPatterns: languageRules(for: .javascript).stringPatterns,
                stringRegexOptions: languageRules(for: .javascript).stringRegexOptions,
                commentPatterns: languageRules(for: .javascript).commentPatterns,
                commentRegexOptions: languageRules(for: .javascript).commentRegexOptions,
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: languageRules(for: .javascript).functionPatterns
            )

        case .python:
            return LanguageRules(
                keywords: [
                    "False", "None", "True", "and", "as", "assert", "async", "await", "break", "class",
                    "continue", "def", "del", "elif", "else", "except", "finally", "for", "from", "global",
                    "if", "import", "in", "is", "lambda", "nonlocal", "not", "or", "pass", "raise", "return",
                    "try", "while", "with", "yield", "match", "case"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:int|float|bool|str|bytes|list|tuple|set|dict|object|NoneType)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    // Triple quotes first
                    "'''[\\s\\S]*?'''",
                    "\"\"\"[\\s\\S]*?\"\"\"",
                    // Raw/byte/f-string-ish single/double
                    "(?i)\\b(?:r|u|f|fr|rf|b|br|rb)?'(?:[^'\\\\\\n]|\\\\.)*'",
                    "(?i)\\b(?:r|u|f|fr|rf|b|br|rb)?\"(?:[^\"\\\\\\n]|\\\\.)*\""
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: [
                    "#[^\\n]*"
                ],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bdef\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .ruby:
            return LanguageRules(
                keywords: [
                    "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined\\?",
                    "do", "else", "elsif", "end", "ensure", "false", "for", "if", "in", "module", "next",
                    "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super", "then",
                    "true", "undef", "unless", "until", "when", "while", "yield", "private", "protected", "public"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'",
                    // Ruby %q/%Q forms (basic)
                    "%[qQ]\\{[\\s\\S]*?\\}",
                    "%[qQ]\\([\\s\\S]*?\\)",
                    "%[qQ]\\[[\\s\\S]*?\\]"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: [
                    "#[^\\n]*",
                    "=begin[\\s\\S]*?=end"
                ],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bdef\\s+([A-Za-z_][A-Za-z0-9_]*[!?=]?)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .go:
            return LanguageRules(
                keywords: [
                    "break", "default", "func", "interface", "select", "case", "defer", "go", "map", "struct",
                    "chan", "else", "goto", "package", "switch", "const", "fallthrough", "if", "range", "type",
                    "continue", "for", "import", "return", "var", "true", "false", "nil"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:string|bool|byte|rune|int|int8|int16|int32|int64|uint|uint8|uint16|uint32|uint64|uintptr|float32|float64|complex64|complex128|error)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    // Raw strings (backticks) + interpreted
                    "`[\\s\\S]*?`",
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    // func Name(
                    CapturePattern(pattern: "\\bfunc\\s+(?:\\([^)]*\\)\\s*)?([A-Za-z_][A-Za-z0-9_]*)\\s*\\(", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .rust:
            return LanguageRules(
                keywords: [
                    "as", "break", "const", "continue", "crate", "else", "enum", "extern", "false", "fn", "for",
                    "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return",
                    "self", "Self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use",
                    "where", "while", "async", "await", "dyn"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:i8|i16|i32|i64|i128|isize|u8|u16|u32|u64|u128|usize|f32|f64|bool|char|str|String|Option|Result|Vec)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    // Raw strings r#"..."# (basic)
                    "r#\"[\\s\\S]*?\"#",
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: [
                    "//[^\\n]*",
                    "/\\*[\\s\\S]*?\\*/"
                ],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfn\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .java:
            return LanguageRules(
                keywords: [
                    "abstract", "assert", "boolean", "break", "byte", "case", "catch", "char", "class",
                    "const", "continue", "default", "do", "double", "else", "enum", "extends", "final",
                    "finally", "float", "for", "goto", "if", "implements", "import", "instanceof", "int",
                    "interface", "long", "native", "new", "package", "private", "protected", "public",
                    "return", "short", "static", "strictfp", "super", "switch", "synchronized", "this",
                    "throw", "throws", "transient", "try", "void", "volatile", "while", "true", "false", "null",
                    "var", "record", "sealed", "permits", "non-sealed"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:boolean|byte|char|short|int|long|float|double|void|String|Object)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings,
                stringRegexOptions: [],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    // Method definition: returnType name(
                    CapturePattern(pattern: "\\b(?:public|private|protected|static|final|native|synchronized|abstract|strictfp)?\\s*\\b[A-Za-z_][A-Za-z0-9_<>\\[\\]]*\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*\\(", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .kotlin:
            return LanguageRules(
                keywords: [
                    "as", "break", "class", "continue", "do", "else", "false", "for", "fun", "if", "in",
                    "interface", "is", "null", "object", "package", "return", "super", "this", "throw",
                    "true", "try", "typealias", "val", "var", "when", "while",
                    "by", "catch", "constructor", "delegate", "dynamic", "field", "file", "finally", "get",
                    "import", "init", "param", "property", "receiver", "set", "setparam", "where",
                    "actual", "abstract", "annotation", "companion", "const", "crossinline", "data", "enum",
                    "expect", "external", "final", "infix", "inline", "inner", "internal", "lateinit",
                    "noinline", "open", "operator", "out", "override", "private", "protected", "public",
                    "reified", "sealed", "suspend", "tailrec", "vararg"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:Int|Long|Short|Byte|Float|Double|Boolean|Char|String|Unit|Any|Nothing)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    "\"\"\"[\\s\\S]*?\"\"\"",
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfun\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .c:
            return LanguageRules(
                keywords: [
                    "auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else",
                    "enum", "extern", "float", "for", "goto", "if", "inline", "int", "long", "register",
                    "restrict", "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef",
                    "union", "unsigned", "void", "volatile", "while", "_Bool", "_Complex", "_Imaginary"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:char|short|int|long|float|double|void|size_t|ssize_t|bool)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings,
                stringRegexOptions: [],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\b([A-Za-z_][A-Za-z0-9_]*)\\s*\\([^;{}]*\\)\\s*\\{", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .cpp:
            return LanguageRules(
                keywords: [
                    "alignas", "alignof", "and", "and_eq", "asm", "auto", "bitand", "bitor", "bool", "break",
                    "case", "catch", "char", "char8_t", "char16_t", "char32_t", "class", "compl", "concept",
                    "const", "consteval", "constexpr", "constinit", "continue", "co_await", "co_return", "co_yield",
                    "default", "delete", "do", "double", "dynamic_cast", "else", "enum", "explicit", "export", "extern",
                    "false", "float", "for", "friend", "goto", "if", "inline", "int", "long", "mutable", "namespace",
                    "new", "noexcept", "not", "not_eq", "nullptr", "operator", "or", "or_eq", "private", "protected",
                    "public", "register", "reinterpret_cast", "requires", "return", "short", "signed", "sizeof",
                    "static", "static_assert", "static_cast", "struct", "switch", "template", "this", "thread_local",
                    "throw", "true", "try", "typedef", "typeid", "typename", "union", "unsigned", "using", "virtual",
                    "void", "volatile", "wchar_t", "while", "xor", "xor_eq", "final", "override"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:bool|char|short|int|long|float|double|void|wchar_t|size_t|ssize_t|string|std::[A-Za-z0-9_:]+)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings,
                stringRegexOptions: [],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\b([A-Za-z_][A-Za-z0-9_:~]*)\\s*\\([^;{}]*\\)\\s*(?:const\\s*)?\\{", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .objc:
            return LanguageRules(
                keywords: [
                    "@interface", "@implementation", "@end", "@property", "@synthesize", "@dynamic", "@protocol",
                    "@class", "@public", "@private", "@protected", "@package",
                    "@try", "@catch", "@finally", "@throw", "@autoreleasepool",
                    "@selector", "@encode", "@import", "@available",
                    // Also include common C/C++ keywords used in ObjC files
                    "if", "else", "for", "while", "switch", "case", "default", "break", "continue", "return",
                    "struct", "typedef", "enum", "static", "const", "void", "int", "char", "float", "double",
                    "BOOL", "YES", "NO", "nil", "self", "super"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:id|instancetype|SEL|Class|BOOL|NSInteger|NSUInteger|CGFloat|NSString|NSNumber|NSArray|NSDictionary|NSData|NSDate|NSURL|NSError)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings + [
                    // Objective-C @"..."
                    "@\"(?:[^\"\\\\\\n]|\\\\.)*\""
                ],
                stringRegexOptions: [],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    // - (ReturnType)methodName:
                    CapturePattern(pattern: "[-+]\\s*\\([^)]*\\)\\s*([A-Za-z_][A-Za-z0-9_]*)", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .html:
            return LanguageRules(
                keywords: [
                    // HTML-ish keywords / doctype
                    "DOCTYPE", "html", "head", "body", "script", "style"
                ],
                typePatterns: [
                    // Tag name
                    CapturePattern(pattern: "<\\/?\\s*([A-Za-z][A-Za-z0-9:-]*)", captureGroup: 1, options: []),
                    // Attribute name
                    CapturePattern(pattern: "\\b([A-Za-z_:][A-Za-z0-9:._-]*)(?=\\s*=)", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'"
                ],
                stringRegexOptions: [],
                commentPatterns: [
                    "<!--[\\s\\S]*?-->"
                ],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: [] // (no meaningful generic function tokens for HTML)
            )

        case .xml:
            return LanguageRules(
                keywords: [
                    "xml", "version", "encoding"
                ],
                typePatterns: [
                    CapturePattern(pattern: "<\\/?\\s*([A-Za-z_][A-Za-z0-9:._-]*)", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b([A-Za-z_:][A-Za-z0-9:._-]*)(?=\\s*=)", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'"
                ],
                stringRegexOptions: [],
                commentPatterns: [
                    "<!--[\\s\\S]*?-->",
                    "<!\\[CDATA\\[[\\s\\S]*?\\]\\]>"
                ],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: []
            )

        case .css:
            return LanguageRules(
                keywords: [
                    "@import", "@media", "@supports", "@keyframes", "@font-face", "@page", "@layer",
                    "important"
                ],
                typePatterns: [
                    // Selectors: .class, #id, tag selectors
                    CapturePattern(pattern: "(?:\\.|#)([A-Za-z_-][A-Za-z0-9_-]*)\\b", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b([A-Za-z_-][A-Za-z0-9_-]*)\\b(?=\\s*\\{)", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'"
                ],
                stringRegexOptions: [],
                commentPatterns: [
                    "/\\*[\\s\\S]*?\\*/"
                ],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: "\\b\\d[\\d_]*(?:\\.\\d[\\d_]*)?(?:%|px|em|rem|vw|vh|vmin|vmax|fr|ch|ex|cm|mm|in|pt|pc)?\\b",
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: [
                    // property names: foo:
                    CapturePattern(pattern: "\\b([A-Za-z_-][A-Za-z0-9_-]*)\\s*(?=:)", captureGroup: 1, options: []),
                    // functions: rgba(...)
                    CapturePattern(pattern: "\\b([A-Za-z_-][A-Za-z0-9_-]*)\\s*(?=\\()", captureGroup: 1, options: []),
                ]
            )

        case .scss:
            return LanguageRules(
                keywords: languageRules(for: .css).keywords + ["@mixin", "@include", "@extend", "@function", "@return", "@if", "@else", "@for", "@each", "@while"],
                typePatterns: languageRules(for: .css).typePatterns,
                stringPatterns: languageRules(for: .css).stringPatterns,
                stringRegexOptions: languageRules(for: .css).stringRegexOptions,
                commentPatterns: [
                    "/\\*[\\s\\S]*?\\*/",
                    "//[^\\n]*"
                ],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: languageRules(for: .css).numberPattern,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: languageRules(for: .css).functionPatterns
            )

        case .json:
            return LanguageRules(
                keywords: ["true", "false", "null"],
                typePatterns: [],
                stringPatterns: [
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\""
                ],
                stringRegexOptions: [],
                commentPatterns: [
                    // JSON doesn't officially support comments, but allow JSONC-style
                    "//[^\\n]*",
                    "/\\*[\\s\\S]*?\\*/"
                ],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: []
            )

        case .yaml:
            return LanguageRules(
                keywords: ["true", "false", "null", "yes", "no", "on", "off"],
                typePatterns: [
                    // Anchors & aliases
                    CapturePattern(pattern: "([&*][A-Za-z0-9_-]+)", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'"
                ],
                stringRegexOptions: [],
                commentPatterns: [
                    "#[^\\n]*"
                ],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: [
                    // Keys at line start: key:
                    CapturePattern(pattern: "^\\s*([A-Za-z0-9_-]+)\\s*:(?=\\s|$)", captureGroup: 1, options: [.anchorsMatchLines])
                ]
            )

        case .sql:
            return LanguageRules(
                keywords: [
                    "select", "from", "where", "group", "by", "having", "order", "limit", "offset",
                    "insert", "into", "values", "update", "set", "delete",
                    "join", "inner", "left", "right", "full", "outer", "cross", "on",
                    "as", "distinct", "union", "all", "and", "or", "not", "null", "is", "in", "exists", "like", "between",
                    "create", "alter", "drop", "table", "view", "index", "primary", "key", "foreign", "references",
                    "case", "when", "then", "else", "end",
                    "begin", "commit", "rollback"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:int|integer|smallint|bigint|serial|bigserial|decimal|numeric|real|double|float|money|boolean|bool|date|time|timestamp|timestamptz|varchar|char|text|uuid|json|jsonb)\\b", captureGroup: nil, options: [.caseInsensitive])
                ],
                stringPatterns: [
                    // Single-quoted strings
                    "'(?:''|[^'])*'",
                    // Double-quoted identifiers (treat as string-ish)
                    "\"(?:\"\"|[^\"])*\""
                ],
                stringRegexOptions: [],
                commentPatterns: [
                    "--[^\\n]*",
                    "/\\*[\\s\\S]*?\\*/"
                ],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: [
                    CapturePattern(pattern: "\\b([A-Za-z_][A-Za-z0-9_]*)\\s*(?=\\()", captureGroup: 1, options: [.caseInsensitive])
                ]
            )

        case .shell:
            return LanguageRules(
                keywords: [
                    "if", "then", "elif", "else", "fi", "for", "in", "do", "done", "case", "esac", "while", "until",
                    "select", "function", "time", "coproc", "break", "continue", "return", "exit", "export", "readonly",
                    "local", "declare", "typeset", "unset", "shift", "trap", "set"
                ],
                typePatterns: [],
                stringPatterns: [
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'[^'\\n]*'",
                    // ANSI-C quoting $'...'
                    "\\$'(?:[^'\\\\\\n]|\\\\.)*'"
                ],
                stringRegexOptions: [],
                commentPatterns: [
                    "#[^\\n]*"
                ],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    // foo() {
                    CapturePattern(pattern: "\\b([A-Za-z_][A-Za-z0-9_]*)\\s*\\(\\s*\\)\\s*\\{", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .dockerfile:
            return LanguageRules(
                keywords: [
                    "FROM", "RUN", "CMD", "LABEL", "MAINTAINER", "EXPOSE", "ENV", "ADD", "COPY", "ENTRYPOINT",
                    "VOLUME", "USER", "WORKDIR", "ARG", "ONBUILD", "STOPSIGNAL", "HEALTHCHECK", "SHELL"
                ],
                typePatterns: [],
                stringPatterns: [
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'"
                ],
                stringRegexOptions: [],
                commentPatterns: [
                    "#[^\\n]*"
                ],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: []
            )

        case .graphql:
            return LanguageRules(
                keywords: [
                    "query", "mutation", "subscription", "fragment", "on",
                    "schema", "type", "interface", "union", "enum", "input", "extend", "directive", "implements",
                    "scalar", "true", "false", "null"
                ],
                typePatterns: [
                    // Built-in scalar types + PascalCase types
                    CapturePattern(pattern: "\\b(?:Int|Float|String|Boolean|ID)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    "\"\"\"[\\s\\S]*?\"\"\"",
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\""
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: [
                    "#[^\\n]*"
                ],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: []
            )

        case .markdown:
            return LanguageRules(
                keywords: [],
                typePatterns: [
                    // Links: URL part in (url)
                    CapturePattern(pattern: "(?<=\\()https?:\\/\\/[^)\\s]+(?=\\))", captureGroup: nil, options: []),
                    // Headings (treat as "type-ish" for visibility)
                    CapturePattern(pattern: "^(#{1,6})\\s+.*$", captureGroup: 1, options: [.anchorsMatchLines])
                ],
                stringPatterns: [
                    // fenced code blocks
                    "```[\\s\\S]*?```",
                    "~~~[\\s\\S]*?~~~",
                    // inline code
                    "`[^`\\n]+`"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: [
                    "<!--[\\s\\S]*?-->"
                ],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: nil,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: []
            )

        case .php:
            return LanguageRules(
                keywords: [
                    "abstract", "and", "array", "as", "break", "callable", "case", "catch", "class", "clone",
                    "const", "continue", "declare", "default", "do", "echo", "else", "elseif", "enddeclare",
                    "endfor", "endforeach", "endif", "endswitch", "endwhile", "enum", "extends", "final",
                    "finally", "fn", "

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":40} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":140} 
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift
>>>FIND
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
>>>REPLACE
import SwiftUI
import UIKit

// Efficient NSMutableAttributedString-based syntax highlighter (regex-based).
//
// Color mapping (per requirements):
// - Keywords: blue
// - Types: cyan
// - Strings: orange
// - Comments: gray
// - Numbers: green
// - Functions: yellow
final class NSAttributedStringSyntaxHighlighter {

    // MARK: - Language

    // NOTE: This file cannot use the name `Language` because the project already defines a global `Language`
    // enum elsewhere (VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift).
    enum SyntaxLanguage {
        case swift, javascript, typescript, jsx, tsx
        case python, ruby, go, rust
        case java, kotlin
        case c, cpp, objc
        case html, css, scss
        case json, xml, yaml
        case sql, shell, dockerfile, graphql
        case markdown, php, dotenv
        case plainText
    }

    // MARK: - Colors

    private struct ColorScheme {
        static let keyword = UIColor.systemBlue
        static let type = UIColor.systemCyan
        static let string = UIColor.systemOrange
        static let comment = UIColor.systemGray
        static let number = UIColor.systemGreen
        static let function = UIColor.systemYellow
        static let defaultText = UIColor.label
    }

    // MARK: - Public API

    /// Backwards-compatible entrypoint (defaults to Swift).
    static func highlightCode(_ code: String) -> NSAttributedString {
        highlightCode(code, filename: nil, language: .swift)
    }

    /// Highlights `code` using either an explicit `language` or a detected one from `filename`.
    static func highlightCode(_ code: String, filename: String? = nil, language: SyntaxLanguage? = nil) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: code)
        let fullRange = NSRange(location: 0, length: code.utf16.count)

        attributed.addAttributes([
            .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            .foregroundColor: ColorScheme.defaultText
        ], range: fullRange)

        let resolvedLanguage: SyntaxLanguage = {
            if let language { return language }
            if let filename { return detectLanguage(fromFilename: filename) }
            return .plainText
        }()

        highlight(code: code, language: resolvedLanguage, into: attributed)
        return attributed
    }

    // MARK: - Language detection

    private static func detectLanguage(fromFilename filename: String) -> SyntaxLanguage {
        let lower = filename.lowercased()
        let base = (lower as NSString).lastPathComponent
        let ext = (base as NSString).pathExtension

        // Special basenames (no extension).
        if base == "dockerfile" || base.hasPrefix("dockerfile.") { return .dockerfile }
        if base == ".env" || base.hasPrefix(".env.") || ext == "env" { return .dotenv }

        switch ext {
        case "swift": return .swift
        case "js", "mjs", "cjs": return .javascript
        case "jsx": return .jsx
        case "ts": return .typescript
        case "tsx": return .tsx
        case "py", "pyw": return .python
        case "rb", "ruby": return .ruby
        case "go": return .go
        case "rs": return .rust
        case "java": return .java
        case "kt", "kts": return .kotlin
        case "c": return .c
        case "cc", "cpp", "cxx", "hpp", "hh", "hxx": return .cpp
        case "m", "mm", "h": return .objc
        case "html", "htm": return .html
        case "css": return .css
        case "scss", "sass": return .scss
        case "json", "jsonc": return .json
        case "xml", "plist", "svg": return .xml
        case "yml", "yaml": return .yaml
        case "sql": return .sql
        case "sh", "bash", "zsh", "fish": return .shell
        case "php": return .php
        case "gql", "graphql": return .graphql
        case "md", "markdown": return .markdown
        default: return .plainText
        }
    }

    // MARK: - Pipeline

    private struct CapturePattern {
        let pattern: String
        let captureGroup: Int?
        let options: NSRegularExpression.Options
    }

    private struct LanguageRules {
        let keywords: [String]
        let typePatterns: [CapturePattern]
        let stringPatterns: [String]
        let stringRegexOptions: NSRegularExpression.Options
        let commentPatterns: [String]
        let commentRegexOptions: NSRegularExpression.Options
        let numberPattern: String?
        let numberRegexOptions: NSRegularExpression.Options
        let keywordRegexOptions: NSRegularExpression.Options
        let functionPatterns: [CapturePattern]
    }

    private static func highlight(code: String, language: SyntaxLanguage, into attributed: NSMutableAttributedString) {
        let rules = languageRules(for: language)

        // 1) Strings first
        let stringRanges = rules.stringPatterns.flatMap { pattern in
            applyHighlighting(
                pattern: pattern,
                options: rules.stringRegexOptions,
                color: ColorScheme.string,
                to: attributed,
                in: code,
                captureGroup: nil,
                excluding: []
            )
        }

        // 2) Comments (exclude matches inside strings)
        let commentRanges = rules.commentPatterns.flatMap { pattern in
            applyHighlighting(
                pattern: pattern,
                options: rules.commentRegexOptions,
                color: ColorScheme.comment,
                to: attributed,
                in: code,
                captureGroup: nil,
                excluding: stringRanges
            )
        }

        let protectedRanges = stringRanges + commentRanges

        // 3) Numbers
        if let numberPattern = rules.numberPattern {
            _ = applyHighlighting(
                pattern: numberPattern,
                options: rules.numberRegexOptions,
                color: ColorScheme.number,
                to: attributed,
                in: code,
                captureGroup: nil,
                excluding: protectedRanges
            )
        }

        // 4) Types
        for typePattern in rules.typePatterns {
            _ = applyHighlighting(
                pattern: typePattern.pattern,
                options: typePattern.options,
                color: ColorScheme.type,
                to: attributed,
                in: code,
                captureGroup: typePattern.captureGroup,
                excluding: protectedRanges
            )
        }

        // 5) Keywords
        if !rules.keywords.isEmpty {
            let keywordPattern = "\\b(?:" + rules.keywords.map(NSRegularExpression.escapedPattern).joined(separator: "|") + ")\\b"
            _ = applyHighlighting(
                pattern: keywordPattern,
                options: rules.keywordRegexOptions,
                color: ColorScheme.keyword,
                to: attributed,
                in: code,
                captureGroup: nil,
                excluding: protectedRanges
            )
        }

        // 6) Functions
        for fnPattern in rules.functionPatterns {
            _ = applyHighlighting(
                pattern: fnPattern.pattern,
                options: fnPattern.options,
                color: ColorScheme.function,
                to: attributed,
                in: code,
                captureGroup: fnPattern.captureGroup,
                excluding: protectedRanges
            )
        }
    }

    // MARK: - Language rules

    private static func languageRules(for language: SyntaxLanguage) -> LanguageRules {

        // Numeric literal coverage (hex, float, exponent, underscores).
        let commonNumber = "\\b(?:0x[0-9A-Fa-f_]+|\\d[\\d_]*(?:\\.\\d[\\d_]*)?(?:[eE][+-]?\\d[\\d_]*)?)\\b"

        // C-like strings: "..." and '...'
        let cLikeStrings = [
            "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
            "'(?:[^'\\\\\\n]|\\\\.)*'"
        ]

        // C-like comments
        let cLikeComments = [
            "//[^\\n]*",
            "/\\*[\\s\\S]*?\\*/"
        ]

        // Common function call: name(
        let commonFunctionCall = CapturePattern(
            pattern: "\\b([A-Za-z_][A-Za-z0-9_]*)\\s*(?=\\()",
            captureGroup: 1,
            options: []
        )

        switch language {

        case .swift:
            return LanguageRules(
                keywords: [
                    "func", "var", "let", "if", "else", "for", "while", "repeat", "switch", "case", "default",
                    "return", "import", "class", "struct", "enum", "protocol", "extension", "actor",
                    "private", "fileprivate", "public", "internal", "open", "static", "final", "override",
                    "self", "super", "init", "deinit",
                    "throw", "throws", "rethrows", "try", "catch", "do", "guard", "defer",
                    "async", "await",
                    "weak", "unowned", "mutating", "nonmutating",
                    "typealias", "associatedtype", "where", "in", "is", "as", "Any", "some", "any",
                    "true", "false", "nil"
                ],
                typePatterns: [
                    CapturePattern(
                        pattern: "\\b(?:String|Int|Int8|Int16|Int32|Int64|UInt|UInt8|UInt16|UInt32|UInt64|Double|Float|Bool|Character|Void|AnyObject|Never|Data|Date|URL|UUID|CGFloat)\\b",
                        captureGroup: nil,
                        options: []
                    ),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: ["\"\"\"[\\s\\S]*?\"\"\""] + cLikeStrings,
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunc\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .javascript:
            return LanguageRules(
                keywords: [
                    "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete",
                    "do", "else", "export", "extends", "finally", "for", "function", "if", "import", "in",
                    "instanceof", "let", "new", "return", "super", "switch", "this", "throw", "try", "typeof",
                    "var", "void", "while", "with", "yield", "async", "await", "of", "true", "false", "null", "undefined"
                ],
                typePatterns: [CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])],
                stringPatterns: cLikeStrings + [
                    "`(?:[^`\\\\]|\\\\.|\\$\\{[\\s\\S]*?\\})*`"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunction\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b(?:const|let|var)\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*=\\s*(?:async\\s*)?(?:\\([^)]*\\)|[A-Za-z_][A-Za-z0-9_]*)?\\s*=>", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .typescript, .tsx:
            return LanguageRules(
                keywords: [
                    // JS
                    "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete",
                    "do", "else", "export", "extends", "finally", "for", "function", "if", "import", "in",
                    "instanceof", "let", "new", "return", "super", "switch", "this", "throw", "try", "typeof",
                    "var", "void", "while", "with", "yield", "async", "await", "of", "true", "false", "null", "undefined",
                    // TS
                    "interface", "type", "enum", "implements", "namespace", "abstract", "declare", "readonly",
                    "private", "protected", "public", "keyof", "infer", "unknown", "never", "any", "as", "satisfies"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:string|number|boolean|any|unknown|never|void|object|bigint|symbol)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings + ["`(?:[^`\\\\]|\\\\.|\\$\\{[\\s\\S]*?\\})*`"],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunction\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .jsx:
            // JSX = JS plus tag/attribute as "types" for cyan.
            let js = languageRules(for: .javascript)
            return LanguageRules(
                keywords: js.keywords,
                typePatterns: js.typePatterns + [
                    CapturePattern(pattern: "<\\/?\\s*([A-Za-z][A-Za-z0-9:_-]*)", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b([A-Za-z_:][A-Za-z0-9:._-]*)(?=\\s*=)", captureGroup: 1, options: [])
                ],
                stringPatterns: js.stringPatterns,
                stringRegexOptions: js.stringRegexOptions,
                commentPatterns: js.commentPatterns,
                commentRegexOptions: js.commentRegexOptions,
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: js.functionPatterns
            )

        case .python:
            return LanguageRules(
                keywords: [
                    "False", "None", "True", "and", "as", "assert", "async", "await", "break", "class",
                    "continue", "def", "del", "elif", "else", "except", "finally", "for", "from", "global",
                    "if", "import", "in", "is", "lambda", "nonlocal", "not", "or", "pass", "raise", "return",
                    "try", "while", "with", "yield", "match", "case"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:int|float|bool|str|bytes|list|tuple|set|dict|object)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: [
                    "'''[\\s\\S]*?'''",
                    "\"\"\"[\\s\\S]*?\"\"\"",
                    "(?i)\\b(?:r|u|f|fr|rf|b|br|rb)?'(?:[^'\\\\\\n]|\\\\.)*'",
                    "(?i)\\b(?:r|u|f|fr|rf|b|br|rb)?\"(?:[^\"\\\\\\n]|\\\\.)*\""
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: ["#[^\\n]*"],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bdef\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .ruby:
            return LanguageRules(
                keywords: [
                    "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined\\?",
                    "do", "else", "elsif", "end", "ensure", "false", "for", "if", "in", "module", "next",
                    "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super", "then",
                    "true", "undef", "unless", "until", "when", "while", "yield", "private", "protected", "public"
                ],
                typePatterns: [CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])],
                stringPatterns: [
                    "\"(?:[^\"\\\\\\n]|\\\\.)*\"",
                    "'(?:[^'\\\\\\n]|\\\\.)*'",
                    "%[qQ]\\{[\\s\\S]*?\\}",
                    "%[qQ]\\([\\s\\S]*?\\)",
                    "%[qQ]\\[[\\s\\S]*?\\]"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: ["#[^\\n]*", "=begin[\\s\\S]*?=end"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bdef\\s+([A-Za-z_][A-Za-z0-9_]*[!?=]?)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .go:
            return LanguageRules(
                keywords: [
                    "break", "default", "func", "interface", "select", "case", "defer", "go", "map", "struct",
                    "chan", "else", "goto", "package", "switch", "const", "fallthrough", "if", "range", "type",
                    "continue", "for", "import", "return", "var", "true", "false", "nil"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:string|bool|byte|rune|int|int8|int16|int32|int64|uint|uint8|uint16|uint32|uint64|uintptr|float32|float64|complex64|complex128|error)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: ["`[\\s\\S]*?`", "\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunc\\s+(?:\\([^)]*\\)\\s*)?([A-Za-z_][A-Za-z0-9_]*)\\s*\\(", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .rust:
            return LanguageRules(
                keywords: [
                    "as", "break", "const", "continue", "crate", "else", "enum", "extern", "false", "fn", "for",
                    "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return",
                    "self", "Self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use",
                    "where", "while", "async", "await", "dyn"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:i8|i16|i32|i64|i128|isize|u8|u16|u32|u64|u128|usize|f32|f64|bool|char|str|String|Option|Result|Vec)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: ["r#\"[\\s\\S]*?\"#", "\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: ["//[^\\n]*", "/\\*[\\s\\S]*?\\*/"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfn\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .java:
            return LanguageRules(
                keywords: [
                    "abstract", "assert", "boolean", "break", "byte", "case", "catch", "char", "class",
                    "const", "continue", "default", "do", "double", "else", "enum", "extends", "final",
                    "finally", "float", "for", "goto", "if", "implements", "import", "instanceof", "int",
                    "interface", "long", "native", "new", "package", "private", "protected", "public",
                    "return", "short", "static", "strictfp", "super", "switch", "synchronized", "this",
                    "throw", "throws", "transient", "try", "void", "volatile", "while", "true", "false", "null",
                    "var", "record", "sealed", "permits", "non-sealed"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:boolean|byte|char|short|int|long|float|double|void|String|Object)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings,
                stringRegexOptions: [],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [commonFunctionCall]
            )

        case .kotlin:
            return LanguageRules(
                keywords: [
                    "as", "break", "class", "continue", "do", "else", "false", "for", "fun", "if", "in",
                    "interface", "is", "null", "object", "package", "return", "super", "this", "throw",
                    "true", "try", "typealias", "val", "var", "when", "while",
                    "by", "catch", "constructor", "delegate", "finally", "get", "import", "init", "set", "where",
                    "actual", "abstract", "annotation", "companion", "const", "crossinline", "data", "enum",
                    "expect", "external", "final", "infix", "inline", "inner", "internal", "lateinit",
                    "noinline", "open", "operator", "out", "override", "private", "protected", "public",
                    "reified", "sealed", "suspend", "tailrec", "vararg"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:Int|Long|Short|Byte|Float|Double|Boolean|Char|String|Unit|Any|Nothing)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: ["\"\"\"[\\s\\S]*?\"\"\"", "\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfun\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .c:
            return LanguageRules(
                keywords: [
                    "auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else",
                    "enum", "extern", "float", "for", "goto", "if", "inline", "int", "long", "register",
                    "restrict", "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef",
                    "union", "unsigned", "void", "volatile", "while", "_Bool", "_Complex", "_Imaginary"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:char|short|int|long|float|double|void|size_t|ssize_t|bool)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings,
                stringRegexOptions: [],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [commonFunctionCall]
            )

        case .cpp:
            return LanguageRules(
                keywords: [
                    "alignas", "alignof", "and", "and_eq", "asm", "auto", "bitand", "bitor", "bool", "break",
                    "case", "catch", "char", "char8_t", "char16_t", "char32_t", "class", "compl", "concept",
                    "const", "consteval", "constexpr", "constinit", "continue", "co_await", "co_return", "co_yield",
                    "default", "delete", "do", "double", "dynamic_cast", "else", "enum", "explicit", "export", "extern",
                    "false", "float", "for", "friend", "goto", "if", "inline", "int", "long", "mutable", "namespace",
                    "new", "noexcept", "not", "not_eq", "nullptr", "operator", "or", "or_eq", "private", "protected",
                    "public", "register", "reinterpret_cast", "requires", "return", "short", "signed", "sizeof",
                    "static", "static_assert", "static_cast", "struct", "switch", "template", "this", "thread_local",
                    "throw", "true", "try", "typedef", "typeid", "typename", "union", "unsigned", "using", "virtual",
                    "void", "volatile", "wchar_t", "while", "xor", "xor_eq", "final", "override"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:bool|char|short|int|long|float|double|void|wchar_t|size_t|ssize_t|string|std::[A-Za-z0-9_:]+)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings,
                stringRegexOptions: [],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [commonFunctionCall]
            )

        case .objc:
            return LanguageRules(
                keywords: [
                    "@interface", "@implementation", "@end", "@property", "@synthesize", "@dynamic", "@protocol",
                    "@class", "@public", "@private", "@protected", "@package",
                    "@try", "@catch", "@finally", "@throw", "@autoreleasepool",
                    "@selector", "@encode", "@import", "@available",
                    "if", "else", "for", "while", "switch", "case", "default", "break", "continue", "return",
                    "struct", "typedef", "enum", "static", "const", "void", "int", "char", "float", "double",
                    "BOOL", "YES", "NO", "nil", "self", "super"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:id|instancetype|SEL|Class|BOOL|NSInteger|NSUInteger|CGFloat|NSString|NSNumber|NSArray|NSDictionary|NSData|NSDate|NSURL|NSError)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings + ["@\"(?:[^\"\\\\\\n]|\\\\.)*\""],
                stringRegexOptions: [],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [commonFunctionCall]
            )

        case .html:
            return LanguageRules(
                keywords: ["DOCTYPE", "html", "head", "body", "script", "style"],
                typePatterns: [
                    CapturePattern(pattern: "<\\/?\\s*([A-Za-z][A-Za-z0-9:-]*)", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b([A-Za-z_:][A-Za-z0-9:._-]*)(?=\\s*=)", captureGroup: 1, options: [])
                ],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [],
                commentPatterns: ["<!--[\\s\\S]*?-->"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: []
            )

        case .xml:
            return LanguageRules(
                keywords: ["xml", "version", "encoding", "CDATA"],
                typePatterns: [
                    CapturePattern(pattern: "<\\/?\\s*([A-Za-z_][A-Za-z0-9:._-]*)", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b([A-Za-z_:][A-Za-z0-9:._-]*)(?=\\s*=)", captureGroup: 1, options: [])
                ],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [],
                commentPatterns: ["<!--[\\s\\S]*?-->", "<!\\[CDATA\\[[\\s\\S]*?\\]\\]>"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: []
            )

        case .css:
            return LanguageRules(
                keywords: ["@import", "@media", "@supports", "@keyframes", "@font-face", "@page", "@layer", "important"],
                typePatterns: [
                    CapturePattern(pattern: "(?:\\.|#)([A-Za-z_-][A-Za-z0-9_-]*)\\b", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b([A-Za-z_-][A-Za-z0-9_-]*)\\b(?=\\s*\\{)", captureGroup: 1, options: [])
                ],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [],
                commentPatterns: ["/\\*[\\s\\S]*?\\*/"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: "\\b\\d[\\d_]*(?:\\.\\d[\\d_]*)?(?:%|px|em|rem|vw|vh|vmin|vmax|fr|ch|ex|cm|mm|in|pt|pc)?\\b",
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: [
                    CapturePattern(pattern: "\\b([A-Za-z_-][A-Za-z0-9_-]*)\\s*(?=:)", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b([A-Za-z_-][A-Za-z0-9_-]*)\\s*(?=\\()", captureGroup: 1, options: [])
                ]
            )

        case .scss:
            let css = languageRules(for: .css)
            return LanguageRules(
                keywords: css.keywords + ["@mixin", "@include", "@extend", "@function", "@return", "@if", "@else", "@for", "@each", "@while"],
                typePatterns: css.typePatterns,
                stringPatterns: css.stringPatterns,
                stringRegexOptions: css.stringRegexOptions,
                commentPatterns: ["/\\*[\\s\\S]*?\\*/", "//[^\\n]*"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: css.numberPattern,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: css.functionPatterns
            )

        case .json:
            return LanguageRules(
                keywords: ["true", "false", "null"],
                typePatterns: [],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\""],
                stringRegexOptions: [],
                commentPatterns: ["//[^\\n]*", "/\\*[\\s\\S]*?\\*/"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: []
            )

        case .yaml:
            return LanguageRules(
                keywords: ["true", "false", "null", "yes", "no", "on", "off"],
                typePatterns: [
                    CapturePattern(pattern: "([&*][A-Za-z0-9_-]+)", captureGroup: 1, options: [])
                ],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [],
                commentPatterns: ["#[^\\n]*"],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: [
                    CapturePattern(pattern: "^\\s*([A-Za-z0-9_-]+)\\s*:(?=\\s|$)", captureGroup: 1, options: [.anchorsMatchLines])
                ]
            )

        case .sql:
            return LanguageRules(
                keywords: [
                    "select", "from", "where", "group", "by", "having", "order", "limit", "offset",
                    "insert", "into", "values", "update", "set", "delete",
                    "join", "inner", "left", "right", "full", "outer", "cross", "on",
                    "as", "distinct", "union", "all", "and", "or", "not", "null", "is", "in", "exists", "like", "between",
                    "create", "alter", "drop", "table", "view", "index", "primary", "key", "foreign", "references",
                    "case", "when", "then", "else", "end",
                    "begin", "commit", "rollback"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:int|integer|smallint|bigint|serial|bigserial|decimal|numeric|real|double|float|money|boolean|bool|date|time|timestamp|timestamptz|varchar|char|text|uuid|json|jsonb)\\b", captureGroup: nil, options: [.caseInsensitive])
                ],
                stringPatterns: ["'(?:''|[^'])*'", "\"(?:\"\"|[^\"])*\""],
                stringRegexOptions: [],
                commentPatterns: ["--[^\\n]*", "/\\*[\\s\\S]*?\\*/"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: [
                    CapturePattern(pattern: "\\b([A-Za-z_][A-Za-z0-9_]*)\\s*(?=\\()", captureGroup: 1, options: [.caseInsensitive])
                ]
            )

        case .shell:
            return LanguageRules(
                keywords: [
                    "if", "then", "elif", "else", "fi", "for", "in", "do", "done", "case", "esac", "while", "until",
                    "select", "function", "time", "coproc", "break", "continue", "return", "exit", "export", "readonly",
                    "local", "declare", "typeset", "unset", "shift", "trap", "set"
                ],
                typePatterns: [],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'[^'\\n]*'", "\\$'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [],
                commentPatterns: ["#[^\\n]*"],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\b([A-Za-z_][A-Za-z0-9_]*)\\s*\\(\\s*\\)\\s*\\{", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .dockerfile:
            return LanguageRules(
                keywords: [
                    "FROM", "RUN", "CMD", "LABEL", "MAINTAINER", "EXPOSE", "ENV", "ADD", "COPY", "ENTRYPOINT",
                    "VOLUME", "USER", "WORKDIR", "ARG", "ONBUILD", "STOPSIGNAL", "HEALTHCHECK", "SHELL"
                ],
                typePatterns: [],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [],
                commentPatterns: ["#[^\\n]*"],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [.caseInsensitive],
                functionPatterns: []
            )

        case .graphql:
            return LanguageRules(
                keywords: [
                    "query", "mutation", "subscription", "fragment", "on",
                    "schema", "type", "interface", "union", "enum", "input", "extend", "directive", "implements",
                    "scalar", "true", "false", "null"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:Int|Float|String|Boolean|ID)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: ["\"\"\"[\\s\\S]*?\"\"\"", "\"(?:[^\"\\\\\\n]|\\\\.)*\""],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: ["#[^\\n]*"],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: []
            )

        case .markdown:
            return LanguageRules(
                keywords: [],
                typePatterns: [],
                stringPatterns: [
                    "```[\\s\\S]*?```",
                    "~~~[\\s\\S]*?~~~",
                    "`[^`\\n]+`"
                ],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: ["<!--[\\s\\S]*?-->"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: nil,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: []
            )

        case .php:
            return LanguageRules(
                keywords: [
                    "abstract", "and", "array", "as", "break", "callable", "case", "catch", "class", "clone",
                    "const", "continue", "declare", "default", "die", "do", "echo", "else", "elseif", "empty",
                    "enddeclare", "endfor", "endforeach", "endif", "endswitch", "endwhile", "enum", "eval", "exit",
                    "extends", "final", "finally", "fn", "for", "foreach", "function", "global", "goto", "if",
                    "implements", "include", "include_once", "instanceof", "insteadof", "interface", "isset",
                    "list", "match", "namespace", "new", "or", "print", "private", "protected", "public", "readonly",
                    "require", "require_once", "return", "static", "switch", "throw", "trait", "try", "unset", "use",
                    "var", "while", "xor", "yield", "true", "false", "null"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:int|float|string|bool|array|object|callable|iterable|mixed|void|never)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings,
                stringRegexOptions: [],
                commentPatterns: cLikeComments + ["#[^\\n]*"],
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunction\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .dotenv:
            return LanguageRules(
                keywords: [],
                typePatterns: [],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [],
                commentPatterns: ["#[^\\n]*"],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    // Highlight keys (KEY=) as "function" or "keyword"? We'll treat them as keywords via functionPatterns would be yellow.
                    // Instead: treat keys as *types* for cyan for visibility? Requirement only specifies type color, so use typePatterns:
                ]
            )

        case .plainText:
            return LanguageRules(
                keywords: [],
                typePatterns: [],
                stringPatterns: [],
                stringRegexOptions: [],
                commentPatterns: [],
                commentRegexOptions: [],
                numberPattern: nil,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: []
            )
        }
    }

    // MARK: - Regex application helpers

    @discardableResult
    private static func applyHighlighting(
        pattern: String,
        options: NSRegularExpression.Options,
        color: UIColor,
        to attributedString: NSMutableAttributedString,
        in text: String,
        captureGroup: Int?,
        excluding excludedRanges: [NSRange]
    ) -> [NSRange] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

            var applied: [NSRange] = []
            applied.reserveCapacity(matches.count)

            for match in matches {
                let range: NSRange = {
                    if let captureGroup, captureGroup <= match.numberOfRanges - 1 {
                        return match.range(at: captureGroup)
                    }
                    return match.range
                }()

                guard range.location != NSNotFound, range.length > 0 else { continue }
                if intersectsAny(range, excludedRanges) { continue }

                attributedString.addAttribute(.foregroundColor, value: color, range: range)
                applied.append(range)
            }

            return applied
        } catch {
            print("Regex error for pattern \(pattern): \(error)")
            return []
        }
    }

    private static func intersectsAny(_ range: NSRange, _ excludedRanges: [NSRange]) -> Bool {
        for ex in excludedRanges where NSIntersectionRange(range, ex).length > 0 {
            return true
        }
        return false
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
    func syntaxHighlighted(
        code: String,
        filename: String? = nil,
        language: NSAttributedStringSyntaxHighlighter.SyntaxLanguage? = nil
    ) -> some View {
        AttributedTextView(attributedText: NSAttributedStringSyntaxHighlighter.highlightCode(code, filename: filename, language: language))
    }
}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":260} 
>>>END

>>>TOOL search
{"query":"case .php", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":260,"end_line":520} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":520,"end_line":930} 
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift
>>>FIND
        case .typescript, .tsx:
            return LanguageRules(
                keywords: [
                    // JS
                    "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete",
                    "do", "else", "export", "extends", "finally", "for", "function", "if", "import", "in",
                    "instanceof", "let", "new", "return", "super", "switch", "this", "throw", "try", "typeof",
                    "var", "void", "while", "with", "yield", "async", "await", "of", "true", "false", "null", "undefined",
                    // TS
                    "interface", "type", "enum", "implements", "namespace", "abstract", "declare", "readonly",
                    "private", "protected", "public", "keyof", "infer", "unknown", "never", "any", "as", "satisfies"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:string|number|boolean|any|unknown|never|void|object|bigint|symbol)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings + ["`(?:[^`\\\\]|\\\\.|\\$\\{[\\s\\S]*?\\})*`"],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunction\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )
>>>REPLACE
        case .typescript:
            return LanguageRules(
                keywords: [
                    // JS
                    "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete",
                    "do", "else", "export", "extends", "finally", "for", "function", "if", "import", "in",
                    "instanceof", "let", "new", "return", "super", "switch", "this", "throw", "try", "typeof",
                    "var", "void", "while", "with", "yield", "async", "await", "of", "true", "false", "null", "undefined",
                    // TS
                    "interface", "type", "enum", "implements", "namespace", "abstract", "declare", "readonly",
                    "private", "protected", "public", "keyof", "infer", "unknown", "never", "any", "as", "satisfies"
                ],
                typePatterns: [
                    CapturePattern(pattern: "\\b(?:string|number|boolean|any|unknown|never|void|object|bigint|symbol)\\b", captureGroup: nil, options: []),
                    CapturePattern(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\b", captureGroup: 1, options: [])
                ],
                stringPatterns: cLikeStrings + ["`(?:[^`\\\\]|\\\\.|\\$\\{[\\s\\S]*?\\})*`"],
                stringRegexOptions: [.dotMatchesLineSeparators],
                commentPatterns: cLikeComments,
                commentRegexOptions: [.dotMatchesLineSeparators],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    CapturePattern(pattern: "\\bfunction\\s+([A-Za-z_][A-Za-z0-9_]*)\\b", captureGroup: 1, options: []),
                    commonFunctionCall
                ]
            )

        case .tsx:
            // TSX = TypeScript + JSX tags/attributes as "types" (cyan).
            let ts = languageRules(for: .typescript)
            return LanguageRules(
                keywords: ts.keywords,
                typePatterns: ts.typePatterns + [
                    CapturePattern(pattern: "<\\/?\\s*([A-Za-z][A-Za-z0-9:_-]*)", captureGroup: 1, options: []),
                    CapturePattern(pattern: "\\b([A-Za-z_:][A-Za-z0-9:._-]*)(?=\\s*=)", captureGroup: 1, options: [])
                ],
                stringPatterns: ts.stringPatterns,
                stringRegexOptions: ts.stringRegexOptions,
                commentPatterns: ts.commentPatterns,
                commentRegexOptions: ts.commentRegexOptions,
                numberPattern: ts.numberPattern,
                numberRegexOptions: ts.numberRegexOptions,
                keywordRegexOptions: ts.keywordRegexOptions,
                functionPatterns: ts.functionPatterns
            )
>>>END

>>>TOOL list_dir
{"path":".garbage"} 
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift
>>>FIND
        case .dotenv:
            return LanguageRules(
                keywords: [],
                typePatterns: [],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [],
                commentPatterns: ["#[^\\n]*"],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: [
                    // Highlight keys (KEY=) as "function" or "keyword"? We'll treat them as keywords via functionPatterns would be yellow.
                    // Instead: treat keys as *types* for cyan for visibility? Requirement only specifies type color, so use typePatterns:
                ]
            )
>>>REPLACE
        case .dotenv:
            return LanguageRules(
                keywords: [],
                typePatterns: [
                    // Keys in KEY=value or export KEY=value
                    CapturePattern(
                        pattern: "^\\s*(?:export\\s+)?([A-Za-z_][A-Za-z0-9_]*)\\s*(?==)",
                        captureGroup: 1,
                        options: [.anchorsMatchLines]
                    )
                ],
                stringPatterns: ["\"(?:[^\"\\\\\\n]|\\\\.)*\"", "'(?:[^'\\\\\\n]|\\\\.)*'"],
                stringRegexOptions: [],
                commentPatterns: ["#[^\\n]*"],
                commentRegexOptions: [],
                numberPattern: commonNumber,
                numberRegexOptions: [],
                keywordRegexOptions: [],
                functionPatterns: []
            )
>>>END

>>>TOOL move_file
{"from":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift.patch","to":".garbage/NSAttributedStringSyntaxHighlighter.swift.patch"} 
>>>END

>>>TOOL search
{"query":"swiftKeywords", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END
>>>TOOL search
{"query":"highlightComments", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END
>>>TOOL search
{"query":"applyHighlighting(pattern:", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END
>>>TOOL search
{"query":"enum SyntaxLanguage", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END
>>>TOOL search
{"query":"case .typescript, .tsx", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END>>>TOOL search
{"query":"swiftKeywords", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END
>>>TOOL search
{"query":"highlightComments", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END
>>>TOOL search
{"query":"enum SyntaxLanguage", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END
>>>TOOL search
{"query":"case .typescript, .tsx", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":285,"end_line":370} 
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift
>>>FIND
        case "cc", "cpp", "cxx", "hpp", "hh", "hxx": return .cpp
        case "m", "mm", "h": return .objc
>>>REPLACE
        case "cc", "cpp", "cxx", "hpp", "hh", "hxx", "h": return .cpp
        case "m", "mm": return .objc
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":140} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":780,"end_line":880} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":12} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":5} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":3} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":4} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":2} 
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift","start_line":1,"end_line":1} 
>>>END

>>>TOOL search
{"query":"import SwiftUI", "glob":"VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift"} 
>>>END

>>>REPORT
Updated `VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift` to support regex-based syntax highlighting across all requested languages and required color mapping.

Evidence (file/line ranges refer to the updated file):
- Added multi-language support via `SyntaxLanguage` enum including: Swift, JS, TS, JSX, TSX, Python, Ruby, Go, Rust, Java, Kotlin, C, C++, ObjC, HTML, CSS, SCSS, JSON, XML, YAML, SQL, Shell, Dockerfile, GraphQL, Markdown, PHP, .env (`dotenv`) (lines 19-28).
- Implemented required color scheme:
  - keywords blue, types cyan, strings orange, comments gray, numbers green, functions yellow (lines 33-40).
- Added language detection from filename/extension including Dockerfile and .env handling (lines 72-109).
- Implemented per-language regex rule sets for:
  - keywords, type patterns, string patterns, comment patterns, number patterns, and function patterns (rules start at line ~219; covers all `SyntaxLanguage` cases through the end of the rules section, incl. PHP and dotenv shown around lines 811-859).
- Highlighting pipeline applies strings first, then comments (excluding string ranges), then numbers/types/keywords/functions (excluding strings+comments) to prevent cross-highlighting (lines 132-215).
- Fixed TSX handling so `.tsx` is treated as TypeScript + JSX tags/attributes rather than plain TypeScript (lines ~304-351 show separate `.typescript` and `.tsx` cases).
- Improved header detection ambiguity by mapping `.h` to `.cpp` and `.m/.mm` to `.objc` (lines 93-96).

Note: The original single-language Swift-only highlighter implementation was replaced entirely by the new multi-language rule-based highlighter within the same file.
>>>END
