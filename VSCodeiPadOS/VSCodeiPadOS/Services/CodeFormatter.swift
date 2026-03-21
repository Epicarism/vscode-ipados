//
//  CodeFormatter.swift
//  VSCodeiPadOS
//
//  Production code formatter with multi-language support
//

import Foundation
import os

// MARK: - LSP Format Provider (decoupled from TunnelLSPProxy)

/// Minimal LSP text-edit types used by the formatter.
/// When TunnelLSPProxy is compiled it registers itself as the provider.
struct FormatterTextEdit: Sendable {
    let rangeStartLine: Int
    let rangeStartChar: Int
    let rangeEndLine: Int
    let rangeEndChar: Int
    let newText: String
}

/// Signature for the LSP formatting closure injected at runtime.
/// Parameters: (uri, languageId, tabSize, insertSpaces) -> [FormatterTextEdit]
typealias LSPFormatProvider = @Sendable @MainActor (String, String, Int, Bool) async throws -> [FormatterTextEdit]

// MARK: - Code Formatter

@MainActor
class CodeFormatter: ObservableObject {
    static let shared = CodeFormatter()
    
    @Published var tabSize: Int = {
        let stored = UserDefaults.standard.integer(forKey: "formatter.tabSize")
        return stored > 0 ? stored : 4
    }() {
        didSet { UserDefaults.standard.set(tabSize, forKey: "formatter.tabSize") }
    }
    
    @Published var useTabs: Bool = {
        UserDefaults.standard.bool(forKey: "formatter.useTabs")
    }() {
        didSet { UserDefaults.standard.set(useTabs, forKey: "formatter.useTabs") }
    }
    
    @Published var trimTrailingWhitespace: Bool = true
    @Published var insertFinalNewline: Bool = true
    
    /// Optional LSP formatting provider. Set by TunnelLSPProxy when available.
    private var lspProvider: LSPFormatProvider?
    
    /// Register an LSP formatting provider (called by TunnelLSPProxy at init).
    func registerLSPProvider(_ provider: @escaping LSPFormatProvider) {
        self.lspProvider = provider
    }
    
    private var indent: String {
        useTabs ? "\t" : String(repeating: " ", count: tabSize)
    }
    
    // MARK: - Public API
    
    /// Format code based on detected or specified language
    func format(code: String, language: String? = nil, filename: String? = nil) -> String {
        let lang = language ?? detectLanguage(from: filename ?? "")
        
        switch lang {
        case "json":
            return formatJSON(code)
        case "html", "xml", "svg":
            return formatHTML(code)
        case "css", "scss", "less":
            return formatCSS(code)
        case "python":
            return formatPython(code)
        case "markdown":
            return formatMarkdown(code)
        default:
            // C-style languages: Swift, JS, TS, Go, Rust, C, C++, Java, etc.
            return formatCStyle(code, language: lang)
        }
    }
    
    /// Format code using LSP if available, falling back to local formatting.
    /// - Parameters:
    ///   - uri: The document URI (e.g. "file:///path/to/file") for the LSP server.
    ///   - languageId: The LSP language identifier (e.g. "swift", "typescript").
    ///   - text: The current document text to format.
    ///   - filename: The filename used for local fallback language detection.
    /// - Returns: The formatted string.
    func formatWithLSP(uri: String, languageId: String, text: String, filename: String) async -> String {
        // Try LSP formatting first if a provider is registered
        if let provider = lspProvider {
            do {
                let edits = try await provider(uri, languageId, tabSize, !useTabs)
                if !edits.isEmpty {
                    let formatted = applyFormatterTextEdits(edits, to: text)
                    AppLogger.editor.info("Format: Applied LSP formatting (\(edits.count) edits)")
                    return formatted
                }
            } catch {
                AppLogger.editor.warning("LSP formatting failed, falling back to local: \(error)")
            }
        }
        // Fall back to local formatting
        return format(code: text, filename: filename)
    }
    
    // MARK: - Text Edit Application
    
    /// Apply an array of FormatterTextEdit to text, processing from bottom to top
    /// to preserve character offsets as edits are applied.
    private func applyFormatterTextEdits(_ edits: [FormatterTextEdit], to text: String) -> String {
        guard !edits.isEmpty else { return text }
        
        // Convert an LSP position (0-based line, 0-based character) to a String.Index
        func offset(line: Int, character: Int) -> String.Index? {
            var currentLine = 0
            var idx = text.startIndex
            while idx < text.endIndex {
                if currentLine == line {
                    let remaining = text.distance(from: idx, to: text.endIndex)
                    return text.index(idx, offsetBy: min(character, remaining))
                }
                if text[idx] == "\n" {
                    currentLine += 1
                }
                idx = text.index(after: idx)
            }
            // If we reached the end and are on the target line, return endIndex
            if currentLine == line { return text.endIndex }
            return nil
        }
        
        // Sort edits by start position descending so we apply bottom-to-top
        // (later edits don't shift the offsets of earlier ones)
        let sortedEdits = edits.sorted { a, b in
            if a.rangeStartLine != b.rangeStartLine {
                return a.rangeStartLine > b.rangeStartLine
            }
            return a.rangeStartChar > b.rangeStartChar
        }
        
        var result = text
        for edit in sortedEdits {
            guard let startIdx = offset(line: edit.rangeStartLine, character: edit.rangeStartChar),
                  let endIdx = offset(line: edit.rangeEndLine, character: edit.rangeEndChar) else {
                continue
            }
            result.replaceSubrange(startIdx..<endIdx, with: edit.newText)
        }
        
        return result
    }
    
    
    /// Detect language from filename extension
    func detectLanguage(from filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "swift": return "swift"
        case "js", "jsx", "mjs": return "javascript"
        case "ts", "tsx": return "typescript"
        case "py": return "python"
        case "go": return "go"
        case "rs": return "rust"
        case "c", "h": return "c"
        case "cpp", "cc", "cxx", "hpp": return "cpp"
        case "java": return "java"
        case "json": return "json"
        case "html", "htm": return "html"
        case "xml": return "xml"
        case "svg": return "svg"
        case "css": return "css"
        case "scss": return "scss"
        case "less": return "less"
        case "md", "markdown": return "markdown"
        case "rb": return "ruby"
        case "php": return "php"
        case "sh", "bash", "zsh": return "shell"
        case "yaml", "yml": return "yaml"
        case "sql": return "sql"
        case "lua": return "lua"
        default: return "text"
        }
    }
    
    // MARK: - JSON Formatter
    
    private func formatJSON(_ code: String) -> String {
        guard let data = code.data(using: .utf8) else { return postProcess(code) }
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let formatted = try JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
            if var result = String(data: formatted, encoding: .utf8) {
                // JSONSerialization uses 4-space indent; adjust to user preference
                if tabSize != 4 || useTabs {
                    let lines = result.components(separatedBy: "\n")
                    result = lines.map { line in
                        let stripped = line.drop(while: { $0 == " " })
                        let spaces = line.count - stripped.count
                        let indentLevel = spaces / 4
                        return String(repeating: indent, count: indentLevel) + stripped
                    }.joined(separator: "\n")
                }
                return postProcess(result)
            }
        } catch {
            // Invalid JSON - fall back to basic formatting
        }
        return postProcess(code)
    }
    
    // MARK: - HTML/XML Formatter
    
    private func formatHTML(_ code: String) -> String {
        var result: [String] = []
        var indentLevel = 0
        let lines = code.components(separatedBy: "\n")
        
        let voidElements: Set<String> = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                result.append("")
                continue
            }
            
            // Decrease indent for closing tags
            if trimmed.hasPrefix("</") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            result.append(String(repeating: indent, count: indentLevel) + trimmed)
            
            // Increase indent for opening tags (not self-closing, not void)
            if let tagMatch = trimmed.range(of: #"<([a-zA-Z][a-zA-Z0-9]*)"#, options: .regularExpression) {
                let tagName = String(trimmed[tagMatch]).dropFirst().lowercased()
                let isSelfClosing = trimmed.hasSuffix("/>") || trimmed.contains("/>")
                let hasClosingTag = trimmed.contains("</")
                let isVoid = voidElements.contains(String(tagName))
                let isComment = trimmed.hasPrefix("<!--")
                let isDoctype = trimmed.hasPrefix("<!")
                
                if !isSelfClosing && !hasClosingTag && !isVoid && !isComment && !isDoctype {
                    indentLevel += 1
                }
            }
        }
        
        return postProcess(result.joined(separator: "\n"))
    }
    
    // MARK: - CSS Formatter
    
    private func formatCSS(_ code: String) -> String {
        var result: [String] = []
        var indentLevel = 0
        let lines = code.components(separatedBy: "\n")
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                result.append("")
                continue
            }
            
            // Decrease indent for closing braces
            if trimmed.hasPrefix("}") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            result.append(String(repeating: indent, count: indentLevel) + trimmed)
            
            // Increase indent after opening braces
            if trimmed.hasSuffix("{") {
                indentLevel += 1
            }
        }
        
        return postProcess(result.joined(separator: "\n"))
    }
    
    // MARK: - Python Formatter
    
    private func formatPython(_ code: String) -> String {
        // For Python, preserve existing indentation structure but normalize indent characters
        var result: [String] = []
        let lines = code.components(separatedBy: "\n")
        
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                result.append("")
                continue
            }
            
            // Count leading whitespace
            let stripped = line.drop(while: { $0 == " " || $0 == "\t" })
            let leading = line.prefix(line.count - stripped.count)
            
            // Normalize: count effective spaces (tab = tabSize spaces)
            var effectiveSpaces = 0
            for ch in leading {
                if ch == "\t" {
                    effectiveSpaces += tabSize
                } else {
                    effectiveSpaces += 1
                }
            }
            
            let indentLevel = effectiveSpaces / tabSize
            let remainder = effectiveSpaces % tabSize
            var newIndent = String(repeating: indent, count: indentLevel)
            if remainder > 0 {
                newIndent += String(repeating: useTabs ? "\t" : " ", count: remainder)
            }
            
            result.append(newIndent + stripped)
        }
        
        return postProcess(result.joined(separator: "\n"))
    }
    
    // MARK: - Markdown Formatter
    
    private func formatMarkdown(_ code: String) -> String {
        // Light touch: trim trailing whitespace (except intentional double-space line breaks)
        var result: [String] = []
        let lines = code.components(separatedBy: "\n")
        
        for line in lines {
            if line.hasSuffix("  ") {
                // Intentional line break - preserve double space
                result.append(line.replacingOccurrences(of: "\\s+$", with: "  ", options: .regularExpression).isEmpty ? line : line)
            } else {
                result.append(line.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression))
            }
        }
        
        return postProcess(result.joined(separator: "\n"))
    }
    
    // MARK: - C-Style Formatter (Swift, JS, TS, Go, Rust, C, C++, Java)
    
    private func formatCStyle(_ code: String, language: String) -> String {
        var result: [String] = []
        var indentLevel = 0
        let lines = code.components(separatedBy: "\n")
        var inMultiLineComment = false
        var inMultiLineString = false
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty {
                result.append("")
                continue
            }
            
            // Track multi-line comments
            if !inMultiLineString {
                if trimmed.hasPrefix("/*") && !trimmed.contains("*/") {
                    inMultiLineComment = true
                }
                if trimmed.contains("*/") {
                    inMultiLineComment = false
                }
            }
            
            // Track multi-line strings (basic - triple quotes for Swift/Python)
            let tripleQuoteCount = trimmed.components(separatedBy: "\"\"\"").count - 1
            if tripleQuoteCount % 2 != 0 {
                inMultiLineString.toggle()
            }
            
            // In comments or multi-line strings, preserve relative indentation
            if inMultiLineComment || inMultiLineString {
                result.append(String(repeating: indent, count: indentLevel) + trimmed)
                continue
            }
            
            // Count braces to determine indent changes
            let openBraces = countUnquoted(trimmed, char: "{")
            let closeBraces = countUnquoted(trimmed, char: "}")
            let openBrackets = countUnquoted(trimmed, char: "[")
            let closeBrackets = countUnquoted(trimmed, char: "]")
            let openParens = countUnquoted(trimmed, char: "(")
            let closeParens = countUnquoted(trimmed, char: ")")
            
            let netClose = closeBraces + closeBrackets + closeParens
            let netOpen = openBraces + openBrackets + openParens
            
            // Decrease indent BEFORE this line if it starts with closing delimiter
            if trimmed.hasPrefix("}") || trimmed.hasPrefix("]") || trimmed.hasPrefix(")") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            // Handle case/default in switch statements
            if (language == "swift" || language == "javascript" || language == "typescript" || language == "java" || language == "c" || language == "cpp") {
                if trimmed.hasPrefix("case ") && trimmed.hasSuffix(":") {
                    // case labels at one less indent than switch body
                } else if trimmed == "default:" {
                    // default label
                }
            }
            
            result.append(String(repeating: indent, count: indentLevel) + trimmed)
            
            // Increase indent AFTER this line based on net openers
            let netDelta = netOpen - netClose
            if netDelta > 0 {
                indentLevel += netDelta
            } else if netDelta < 0 && !trimmed.hasPrefix("}") && !trimmed.hasPrefix("]") && !trimmed.hasPrefix(")") {
                indentLevel = max(0, indentLevel + netDelta)
            }
        }
        
        return postProcess(result.joined(separator: "\n"))
    }
    
    // MARK: - Helpers
    
    /// Count occurrences of a character outside of string literals
    private func countUnquoted(_ line: String, char: String) -> Int {
        var count = 0
        var inSingleQuote = false
        var inDoubleQuote = false
        var inBacktick = false
        var escaped = false
        guard let target = char.first else { return 0 }
        
        for ch in line {
            if escaped {
                escaped = false
                continue
            }
            if ch == "\\" {
                escaped = true
                continue
            }
            if ch == "'" && !inDoubleQuote && !inBacktick {
                inSingleQuote.toggle()
                continue
            }
            if ch == "\"" && !inSingleQuote && !inBacktick {
                inDoubleQuote.toggle()
                continue
            }
            if ch == "`" && !inSingleQuote && !inDoubleQuote {
                inBacktick.toggle()
                continue
            }
            if !inSingleQuote && !inDoubleQuote && !inBacktick && ch == target {
                count += 1
            }
        }
        return count
    }
    
    /// Post-process: trim trailing whitespace, ensure final newline
    private func postProcess(_ code: String) -> String {
        var lines = code.components(separatedBy: "\n")
        
        if trimTrailingWhitespace {
            lines = lines.map { line in
                // Trim trailing spaces/tabs
                var end = line.endIndex
                while end > line.startIndex {
                    let prev = line.index(before: end)
                    if line[prev] == " " || line[prev] == "\t" {
                        end = prev
                    } else {
                        break
                    }
                }
                return String(line[line.startIndex..<end])
            }
        }
        
        // Remove excessive blank lines (max 2 consecutive)
        var result: [String] = []
        var consecutiveEmpty = 0
        for line in lines {
            if line.isEmpty {
                consecutiveEmpty += 1
                if consecutiveEmpty <= 2 {
                    result.append(line)
                }
            } else {
                consecutiveEmpty = 0
                result.append(line)
            }
        }
        
        // Remove trailing blank lines
        while result.last?.isEmpty == true {
            result.removeLast()
        }
        
        var output = result.joined(separator: "\n")
        
        if insertFinalNewline && !output.hasSuffix("\n") {
            output += "\n"
        }
        
        return output
    }
}
