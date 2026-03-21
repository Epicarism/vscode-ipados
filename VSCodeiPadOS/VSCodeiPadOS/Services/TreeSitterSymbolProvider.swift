//
//  TreeSitterSymbolProvider.swift
//  VSCodeiPadOS
//
//  Multi-language document symbol extraction using regex-based patterns.
//  Provides structured symbols for outline panel, Go-to-Symbol, and breadcrumbs.
//  Supports Swift, TypeScript/JavaScript, Python, Go, Rust, Ruby, Java, C/C++, C#, PHP.
//

import Foundation
import os

// MARK: - Symbol Models

enum DocumentSymbolKind: String, CaseIterable, Comparable {
    case module
    case `class`
    case `struct`
    case `enum`
    case interface
    case `protocol`
    case function
    case method
    case property
    case variable
    case constant
    case constructor
    case type
    
    var icon: String {
        switch self {
        case .module:      return "shippingbox"
        case .class:       return "c.square"
        case .struct:      return "s.square"
        case .enum:        return "e.square"
        case .interface:   return "i.square"
        case .protocol:    return "p.square"
        case .function:    return "f.cursive"
        case .method:      return "m.square"
        case .property:    return "p.circle"
        case .variable:    return "v.square"
        case .constant:    return "k.square"
        case .constructor: return "hammer"
        case .type:        return "t.square"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .module: return 0
        case .class: return 1
        case .struct: return 2
        case .enum: return 3
        case .interface: return 4
        case .protocol: return 5
        case .type: return 6
        case .constructor: return 7
        case .function: return 8
        case .method: return 9
        case .property: return 10
        case .variable: return 11
        case .constant: return 12
        }
    }
    
    static func < (lhs: DocumentSymbolKind, rhs: DocumentSymbolKind) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

struct DocumentSymbol: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let kind: DocumentSymbolKind
    let line: Int       // 1-based line number
    let column: Int     // 0-based column
    let detail: String? // e.g., parameter list or type annotation
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(kind)
        hasher.combine(line)
    }
    
    static func == (lhs: DocumentSymbol, rhs: DocumentSymbol) -> Bool {
        lhs.name == rhs.name && lhs.kind == rhs.kind && lhs.line == rhs.line
    }
}

// MARK: - Symbol Provider

@MainActor
final class TreeSitterSymbolProvider: ObservableObject {
    static let shared = TreeSitterSymbolProvider()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "SymbolProvider")
    
    @Published private(set) var symbols: [DocumentSymbol] = []
    @Published private(set) var isProcessing: Bool = false
    
    /// Cache: filename -> (content hash, symbols)
    private var cache: [String: (Int, [DocumentSymbol])] = [:]
    
    // MARK: - Public API
    
    /// Extract symbols from source text for the given filename.
    /// Results are cached by content hash.
    func updateSymbols(for text: String, filename: String) {
        let hash = text.hashValue
        if let cached = cache[filename], cached.0 == hash {
            if symbols != cached.1 {
                symbols = cached.1
            }
            return
        }
        
        isProcessing = true
        let lang = detectLanguage(filename: filename)
        let extracted = extractSymbols(from: text, language: lang)
        cache[filename] = (hash, extracted)
        symbols = extracted
        isProcessing = false
    }
    
    /// Clear cached symbols (e.g., on file close)
    func clearSymbols(for filename: String? = nil) {
        if let filename = filename {
            cache.removeValue(forKey: filename)
        } else {
            cache.removeAll()
        }
        symbols = []
    }
    
    // MARK: - Language Detection
    
    private func detectLanguage(filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "swift":                              return "swift"
        case "js", "jsx", "mjs", "cjs":           return "javascript"
        case "ts", "tsx", "mts", "cts":           return "typescript"
        case "py", "pyw", "pyi":                  return "python"
        case "go":                                  return "go"
        case "rs":                                  return "rust"
        case "rb", "rake", "gemspec":              return "ruby"
        case "java":                                return "java"
        case "kt", "kts":                          return "kotlin"
        case "c", "h":                              return "c"
        case "cpp", "cc", "cxx", "hpp", "hxx":    return "cpp"
        case "cs":                                  return "csharp"
        case "php":                                 return "php"
        case "html", "htm":                        return "html"
        case "css", "scss":                        return "css"
        case "ex", "exs":                          return "elixir"
        case "hs":                                  return "haskell"
        case "lua":                                 return "lua"
        case "r":                                   return "r"
        case "jl":                                  return "julia"
        case "ml", "mli":                          return "ocaml"
        case "pl", "pm":                           return "perl"
        default:                                     return "unknown"
        }
    }
    
    // MARK: - Symbol Extraction
    
    private func extractSymbols(from text: String, language: String) -> [DocumentSymbol] {
        let lines = text.components(separatedBy: "\n")
        var results: [DocumentSymbol] = []
        
        let patterns = symbolPatterns(for: language)
        let ns = text as NSString
        let fullRange = NSRange(location: 0, length: ns.length)
        
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern.regex, options: pattern.options) else {
                continue
            }
            
            regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                guard let match = match else { return }
                
                // Extract name from capture group
                let nameGroupIndex = pattern.nameGroup
                guard nameGroupIndex < match.numberOfRanges else { return }
                let nameRange = match.range(at: nameGroupIndex)
                guard nameRange.location != NSNotFound else { return }
                let name = ns.substring(with: nameRange)
                guard !name.isEmpty else { return }
                
                // Extract detail if available
                var detail: String? = nil
                if let detailGroup = pattern.detailGroup, detailGroup < match.numberOfRanges {
                    let detailRange = match.range(at: detailGroup)
                    if detailRange.location != NSNotFound {
                        detail = ns.substring(with: detailRange)
                    }
                }
                
                // Calculate line number (1-based)
                let lineNumber = lineNumberForOffset(nameRange.location, in: lines, text: ns)
                
                results.append(DocumentSymbol(
                    name: name,
                    kind: pattern.kind,
                    line: lineNumber,
                    column: columnForOffset(nameRange.location, in: ns),
                    detail: detail
                ))
            }
        }
        
        // Sort by line, then by kind priority
        results.sort { a, b in
            if a.line != b.line { return a.line < b.line }
            return a.kind < b.kind
        }
        
        // De-duplicate (same name+kind+line)
        var seen = Set<String>()
        results = results.filter { sym in
            let key = "\(sym.name):\(sym.kind.rawValue):\(sym.line)"
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
        
        return results
    }
    
    // MARK: - Line/Column Helpers
    
    private func lineNumberForOffset(_ offset: Int, in lines: [String], text: NSString) -> Int {
        // Count newlines before offset
        let prefix = text.substring(to: min(offset, text.length))
        return prefix.components(separatedBy: "\n").count
    }
    
    private func columnForOffset(_ offset: Int, in text: NSString) -> Int {
        let prefix = text.substring(to: min(offset, text.length))
        if let lastNewline = prefix.lastIndex(of: "\n") {
            return prefix.distance(from: prefix.index(after: lastNewline), to: prefix.endIndex)
        }
        return prefix.count
    }
    
    // MARK: - Pattern Definitions
    
    private struct SymbolPattern {
        let kind: DocumentSymbolKind
        let regex: String
        let nameGroup: Int
        let detailGroup: Int?
        let options: NSRegularExpression.Options
        
        init(kind: DocumentSymbolKind, regex: String, nameGroup: Int = 1, detailGroup: Int? = nil, options: NSRegularExpression.Options = [.anchorsMatchLines]) {
            self.kind = kind
            self.regex = regex
            self.nameGroup = nameGroup
            self.detailGroup = detailGroup
            self.options = options
        }
    }
    
    private func symbolPatterns(for language: String) -> [SymbolPattern] {
        switch language {
        case "swift":
            return swiftPatterns
        case "typescript", "javascript":
            return typeScriptPatterns
        case "python":
            return pythonPatterns
        case "go":
            return goPatterns
        case "rust":
            return rustPatterns
        case "ruby":
            return rubyPatterns
        case "java", "kotlin":
            return javaPatterns
        case "c", "cpp":
            return cPatterns
        case "csharp":
            return csharpPatterns
        case "php":
            return phpPatterns
        case "elixir":
            return elixirPatterns
        case "haskell":
            return haskellPatterns
        case "lua":
            return luaPatterns
        case "r":
            return rPatterns
        case "julia":
            return juliaPatterns
        case "ocaml":
            return ocamlPatterns
        case "perl":
            return perlPatterns
        default:
            return genericPatterns
        }
    }
    
    // MARK: - Language-Specific Patterns
    
    private var swiftPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .class,       regex: #"^\s*(?:(?:public|private|internal|fileprivate|open|final)\s+)*class\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .struct,      regex: #"^\s*(?:(?:public|private|internal|fileprivate|open)\s+)*struct\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .enum,        regex: #"^\s*(?:(?:public|private|internal|fileprivate|open)\s+)*enum\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .protocol,    regex: #"^\s*(?:(?:public|private|internal|fileprivate|open)\s+)*protocol\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .function,    regex: #"^\s*(?:(?:public|private|internal|fileprivate|open|static|class|override|mutating|nonmutating)\s+)*func\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .constructor, regex: #"^\s*(?:(?:public|private|internal|fileprivate|open|convenience|required|override)\s+)*init\s*[?(]"#, nameGroup: 0),
            SymbolPattern(kind: .type,        regex: #"^\s*(?:(?:public|private|internal|fileprivate|open)\s+)*typealias\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .property,    regex: #"^\s*(?:(?:public|private|internal|fileprivate|open|static|class|lazy|weak|unowned)\s+)*(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)\s*[=:]"#),
        ]
    }
    
    private var typeScriptPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .class,     regex: #"^\s*(?:export\s+)?(?:default\s+)?(?:abstract\s+)?class\s+([A-Za-z_$][A-Za-z0-9_$]*)"#),
            SymbolPattern(kind: .interface,  regex: #"^\s*(?:export\s+)?interface\s+([A-Za-z_$][A-Za-z0-9_$]*)"#),
            SymbolPattern(kind: .type,       regex: #"^\s*(?:export\s+)?type\s+([A-Za-z_$][A-Za-z0-9_$]*)\s*[=<]"#),
            SymbolPattern(kind: .enum,       regex: #"^\s*(?:export\s+)?(?:const\s+)?enum\s+([A-Za-z_$][A-Za-z0-9_$]*)"#),
            SymbolPattern(kind: .function,   regex: #"^\s*(?:export\s+)?(?:default\s+)?(?:async\s+)?function\s*\*?\s+([A-Za-z_$][A-Za-z0-9_$]*)"#),
            SymbolPattern(kind: .function,   regex: #"^\s*(?:export\s+)?(?:const|let|var)\s+([A-Za-z_$][A-Za-z0-9_$]*)\s*=\s*(?:async\s+)?(?:\([^)]*\)|[A-Za-z_$][A-Za-z0-9_$]*)\s*=>"#),
            SymbolPattern(kind: .constant,   regex: #"^\s*(?:export\s+)?const\s+([A-Z][A-Z0-9_]*)\s*="#),
            SymbolPattern(kind: .variable,   regex: #"^\s*(?:export\s+)?(?:const|let|var)\s+([A-Za-z_$][A-Za-z0-9_$]*)\s*[=:]"#),
            SymbolPattern(kind: .method,     regex: #"^\s+(?:async\s+)?(?:static\s+)?(?:get\s+|set\s+)?([A-Za-z_$][A-Za-z0-9_$]*)\s*\("#),
            SymbolPattern(kind: .module,     regex: #"^\s*(?:export\s+)?(?:declare\s+)?(?:namespace|module)\s+([A-Za-z_$][A-Za-z0-9_$.]*)"#),
        ]
    }
    
    private var pythonPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .class,    regex: #"^\s*class\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .function, regex: #"^\s*(?:async\s+)?def\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .variable, regex: #"^([A-Z][A-Z0-9_]*)\s*="#),
        ]
    }
    
    private var goPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .function,  regex: #"^func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\("#),
            SymbolPattern(kind: .method,    regex: #"^func\s+\([^)]+\)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\("#),
            SymbolPattern(kind: .struct,    regex: #"^type\s+([A-Za-z_][A-Za-z0-9_]*)\s+struct"#),
            SymbolPattern(kind: .interface,  regex: #"^type\s+([A-Za-z_][A-Za-z0-9_]*)\s+interface"#),
            SymbolPattern(kind: .type,      regex: #"^type\s+([A-Za-z_][A-Za-z0-9_]*)\s+"#),
            SymbolPattern(kind: .constant,  regex: #"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"#),
        ]
    }
    
    private var rustPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .function, regex: #"^\s*(?:pub(?:\([^)]*\))?\s+)?(?:async\s+)?(?:unsafe\s+)?fn\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .struct,   regex: #"^\s*(?:pub(?:\([^)]*\))?\s+)?struct\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .enum,     regex: #"^\s*(?:pub(?:\([^)]*\))?\s+)?enum\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .interface, regex: #"^\s*(?:pub(?:\([^)]*\))?\s+)?trait\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .type,     regex: #"^\s*(?:pub(?:\([^)]*\))?\s+)?type\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .module,   regex: #"^\s*(?:pub(?:\([^)]*\))?\s+)?mod\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .constant, regex: #"^\s*(?:pub(?:\([^)]*\))?\s+)?(?:const|static)\s+([A-Z][A-Z0-9_]*)"#),
        ]
    }
    
    private var rubyPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .class,    regex: #"^\s*class\s+([A-Z][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .module,   regex: #"^\s*module\s+([A-Z][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .function, regex: #"^\s*def\s+(?:self\.)?([A-Za-z_][A-Za-z0-9_!?]*)"#),
            SymbolPattern(kind: .constant, regex: #"^\s*([A-Z][A-Z0-9_]*)\s*="#),
        ]
    }
    
    private var javaPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .class,     regex: #"^\s*(?:(?:public|private|protected|abstract|final|static)\s+)*class\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .interface,  regex: #"^\s*(?:(?:public|private|protected)\s+)*interface\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .enum,      regex: #"^\s*(?:(?:public|private|protected)\s+)*enum\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .method,    regex: #"^\s*(?:(?:public|private|protected|abstract|final|static|synchronized|native)\s+)*(?:[A-Za-z_<>\[\]?,\s]+)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\("#),
            SymbolPattern(kind: .constant,  regex: #"^\s*(?:(?:public|private|protected)\s+)?static\s+final\s+\S+\s+([A-Z][A-Z0-9_]*)"#),
        ]
    }
    
    private var cPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .function, regex: #"^(?:[A-Za-z_][A-Za-z0-9_*\s]+)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\([^;]*$"#),
            SymbolPattern(kind: .struct,   regex: #"^\s*(?:typedef\s+)?struct\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .enum,     regex: #"^\s*(?:typedef\s+)?enum\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .constant, regex: #"^\s*#define\s+([A-Z][A-Z0-9_]*)"#),
        ]
    }
    
    private var csharpPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .class,     regex: #"^\s*(?:(?:public|private|protected|internal|abstract|sealed|static|partial)\s+)*class\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .interface,  regex: #"^\s*(?:(?:public|private|protected|internal)\s+)*interface\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .struct,    regex: #"^\s*(?:(?:public|private|protected|internal)\s+)*struct\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .enum,      regex: #"^\s*(?:(?:public|private|protected|internal)\s+)*enum\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .method,    regex: #"^\s*(?:(?:public|private|protected|internal|abstract|virtual|override|static|async)\s+)*(?:[A-Za-z_<>\[\]?,\s]+)\s+([A-Za-z_][A-Za-z0-9_]*)\s*[(<]"#),
            SymbolPattern(kind: .property,  regex: #"^\s*(?:(?:public|private|protected|internal|static)\s+)*(?:[A-Za-z_][A-Za-z0-9_<>\[\]?]*)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{\s*(?:get|set)"#),
        ]
    }
    
    private var phpPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .class,    regex: #"^\s*(?:(?:abstract|final)\s+)?class\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .interface, regex: #"^\s*interface\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .interface, regex: #"^\s*trait\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .function, regex: #"^\s*(?:(?:public|private|protected|static|abstract|final)\s+)*function\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .constant, regex: #"^\s*(?:const|define\()\s*['"]?([A-Z][A-Z0-9_]*)"#),
        ]
    }
    
    private var elixirPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .module,   regex: #"^\s*defmodule\s+([A-Za-z_][A-Za-z0-9_.]*)"#),
            SymbolPattern(kind: .function, regex: #"^\s*(?:def|defp)\s+([A-Za-z_][A-Za-z0-9_!?]*)"#),
            SymbolPattern(kind: .function, regex: #"^\s*defmacro\s+([A-Za-z_][A-Za-z0-9_!?]*)"#),
        ]
    }
    
    private var haskellPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .type,     regex: #"^\s*(?:data|newtype|type)\s+([A-Z][A-Za-z0-9_']*)"#),
            SymbolPattern(kind: .class,    regex: #"^\s*class\s+(?:[^=>]*=>\s*)?([A-Z][A-Za-z0-9_']*)"#),
            SymbolPattern(kind: .function, regex: #"^([a-z_][A-Za-z0-9_']*)\s+::"#),
        ]
    }
    
    private var luaPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .function, regex: #"^\s*(?:local\s+)?function\s+([A-Za-z_][A-Za-z0-9_.:]*) *\("#),
            SymbolPattern(kind: .variable, regex: #"^\s*local\s+([A-Za-z_][A-Za-z0-9_]*)\s*="#),
        ]
    }
    
    private var rPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .function, regex: #"^\s*([A-Za-z_][A-Za-z0-9_.]*)\s*<-\s*function\s*\("#),
            SymbolPattern(kind: .variable, regex: #"^\s*([A-Za-z_][A-Za-z0-9_.]*)\s*<-"#),
        ]
    }
    
    private var juliaPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .function, regex: #"^\s*function\s+([A-Za-z_][A-Za-z0-9_!]*)"#),
            SymbolPattern(kind: .struct,   regex: #"^\s*(?:mutable\s+)?struct\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .module,   regex: #"^\s*module\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .type,     regex: #"^\s*(?:abstract\s+)?type\s+([A-Za-z_][A-Za-z0-9_]*)"#),
        ]
    }
    
    private var ocamlPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .function, regex: #"^\s*let\s+(?:rec\s+)?([A-Za-z_][A-Za-z0-9_']*)"#),
            SymbolPattern(kind: .type,     regex: #"^\s*type\s+(?:'[a-z]\s+)?([A-Za-z_][A-Za-z0-9_']*)"#),
            SymbolPattern(kind: .module,   regex: #"^\s*module\s+([A-Z][A-Za-z0-9_]*)"#),
        ]
    }
    
    private var perlPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .function, regex: #"^\s*sub\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .module,   regex: #"^\s*package\s+([A-Za-z_][A-Za-z0-9_:]*)"#),
        ]
    }
    
    private var genericPatterns: [SymbolPattern] {
        [
            SymbolPattern(kind: .function, regex: #"^\s*(?:func|function|def|fn|sub)\s+([A-Za-z_][A-Za-z0-9_]*)"#),
            SymbolPattern(kind: .class,    regex: #"^\s*(?:class|struct|enum)\s+([A-Za-z_][A-Za-z0-9_]*)"#),
        ]
    }
}

// MARK: - Notification for navigation

extension Notification.Name {
    static let navigateToLine = Notification.Name("navigateToLine")
    static let navigateToSymbol = Notification.Name("navigateToSymbol")
}
