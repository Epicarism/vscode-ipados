//
//  TreeSitterLanguages.swift
//  VSCodeiPadOS
//
//  Created on 2025-01-31.
//

import Foundation

// TODO: Uncomment these imports as TreeSitter Swift packages become available
// import TreeSitterSwift
// import TreeSitterJavaScript
// import TreeSitterTypeScript
// import TreeSitterPython
// import TreeSitterJSON
// import TreeSitterHTML
// import TreeSitterCSS
// import TreeSitterMarkdown
// import TreeSitterGo
// import TreeSitterRust
// import TreeSitterRuby
// import TreeSitterJava
// import TreeSitterC
// import TreeSitterCPP
// import TreeSitterBash
// import TreeSitterYAML
// import TreeSitterSQL
//
// TODO: Additional languages from the current implementation:
// import TreeSitterKotlin        // For kt, kts files
// import TreeSitterObjectiveC     // For m, mm files
// import TreeSitterSCSS           // For scss, sass files
// import TreeSitterLess           // For less files
// import TreeSitterXML            // For xml, plist, svg files
// import TreeSitterGraphQL        // For graphql, gql files
// import TreeSitterPHP            // For php files

/// Provides language modes for syntax highlighting based on file extensions.
/// This struct maps file extensions and special filenames to their appropriate
/// TreeSitter language modes for syntax highlighting.
public struct TreeSitterLanguages {
    
    /// Returns the appropriate language mode for a given filename.
    /// - Parameter filename: The filename (with or without path) to analyze
    /// - Returns: A LanguageMode instance for the detected language, or PlainTextLanguageMode() if unknown
    public static func languageMode(for filename: String) -> LanguageMode {
        let lower = filename.lowercased()
        let ext = (filename as NSString).pathExtension.lowercased()
        
        // Special-case filenames without extensions
        let lastComponent = (filename as NSString).lastPathComponent.lowercased()
        if lastComponent == "dockerfile" || lastComponent == "dockerfile.*" {
            // Dockerfile is typically bash-like, could use TreeSitterBash when available
            return bashLanguageMode() // or PlainTextLanguageMode()
        }
        if lastComponent == ".env" || lower.hasSuffix("/.env") {
            return PlainTextLanguageMode()
        }
        
        switch ext {
        // Swift
        case "swift":
            return swiftLanguageMode()
        
        // JavaScript
        case "js", "mjs", "cjs":
            return javaScriptLanguageMode()
        case "jsx":
            // JSX typically uses JavaScript grammar with JSX extensions
            return javaScriptLanguageMode()
        
        // TypeScript
        case "ts", "mts", "cts":
            return typeScriptLanguageMode()
        case "tsx":
            // TSX typically uses TypeScript grammar with JSX extensions
            return typeScriptLanguageMode()
        
        // Python
        case "py", "pyw":
            return pythonLanguageMode()
        
        // Ruby
        case "rb", "ruby":
            return rubyLanguageMode()
        
        // Go
        case "go":
            return goLanguageMode()
        
        // Rust
        case "rs":
            return rustLanguageMode()
        
        // Java
        case "java":
            return javaLanguageMode()
        
        // Kotlin (TODO: may not have Swift package yet)
        case "kt", "kts":
            return kotlinLanguageMode()
        
        // C
        case "c", "h":
            return cLanguageMode()
        
        // C++
        case "cpp", "cc", "cxx", "hpp", "hh", "hxx":
            return cppLanguageMode()
        
        // Objective-C (TODO: may not have Swift package yet)
        case "m", "mm":
            return objectiveCLanguageMode()
        
        // HTML
        case "html", "htm":
            return htmlLanguageMode()
        
        // CSS
        case "css":
            return cssLanguageMode()
        
        // SCSS/SASS (TODO: may not have Swift package yet)
        case "scss", "sass":
            return scssLanguageMode()
        
        // Less (TODO: may not have Swift package yet)
        case "less":
            return lessLanguageMode()
        
        // JSON
        case "json", "jsonc":
            return jsonLanguageMode()
        
        // XML (TODO: may not have Swift package yet)
        case "xml", "plist", "svg":
            return xmlLanguageMode()
        
        // YAML
        case "yml", "yaml":
            return yamlLanguageMode()
        
        // SQL
        case "sql":
            return sqlLanguageMode()
        
        // Shell scripts
        case "sh", "bash", "zsh", "fish":
            return bashLanguageMode()
        
        // Dockerfile (when it has an extension)
        case "dockerfile":
            return bashLanguageMode() // or PlainTextLanguageMode()
        
        // GraphQL (TODO: may not have Swift package yet)
        case "graphql", "gql":
            return graphqlLanguageMode()
        
        // Markdown
        case "md", "markdown":
            return markdownLanguageMode()
        
        // PHP (TODO: may not have Swift package yet)
        case "php":
            return phpLanguageMode()
        
        // Environment files
        case "env":
            return PlainTextLanguageMode()
        
        default:
            return PlainTextLanguageMode()
        }
    }
    
    // MARK: - Language Mode Factory Methods
    
    private static func swiftLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterSwift() when package is available
        // return TreeSitterSwift()
        return PlainTextLanguageMode()
    }
    
    private static func javaScriptLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterJavaScript() when package is available
        // return TreeSitterJavaScript()
        return PlainTextLanguageMode()
    }
    
    private static func typeScriptLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterTypeScript() when package is available
        // return TreeSitterTypeScript()
        return PlainTextLanguageMode()
    }
    
    private static func pythonLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterPython() when package is available
        // return TreeSitterPython()
        return PlainTextLanguageMode()
    }
    
    private static func jsonLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterJSON() when package is available
        // return TreeSitterJSON()
        return PlainTextLanguageMode()
    }
    
    private static func htmlLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterHTML() when package is available
        // return TreeSitterHTML()
        return PlainTextLanguageMode()
    }
    
    private static func cssLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterCSS() when package is available
        // return TreeSitterCSS()
        return PlainTextLanguageMode()
    }
    
    private static func markdownLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterMarkdown() when package is available
        // return TreeSitterMarkdown()
        return PlainTextLanguageMode()
    }
    
    private static func goLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterGo() when package is available
        // return TreeSitterGo()
        return PlainTextLanguageMode()
    }
    
    private static func rustLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterRust() when package is available
        // return TreeSitterRust()
        return PlainTextLanguageMode()
    }
    
    private static func rubyLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterRuby() when package is available
        // return TreeSitterRuby()
        return PlainTextLanguageMode()
    }
    
    private static func javaLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterJava() when package is available
        // return TreeSitterJava()
        return PlainTextLanguageMode()
    }
    
    private static func cLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterC() when package is available
        // return TreeSitterC()
        return PlainTextLanguageMode()
    }
    
    private static func cppLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterCPP() when package is available
        // return TreeSitterCPP()
        return PlainTextLanguageMode()
    }
    
    private static func bashLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterBash() when package is available
        // return TreeSitterBash()
        return PlainTextLanguageMode()
    }
    
    private static func yamlLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterYAML() when package is available
        // return TreeSitterYAML()
        return PlainTextLanguageMode()
    }
    
    private static func sqlLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterSQL() when package is available
        // return TreeSitterSQL()
        return PlainTextLanguageMode()
    }
    
    // MARK: - Additional Language Factory Methods
    
    private static func kotlinLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterKotlin() when package is available
        return PlainTextLanguageMode()
    }
    
    private static func objectiveCLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterObjectiveC() when package is available
        return PlainTextLanguageMode()
    }
    
    private static func scssLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterSCSS() when package is available
        return PlainTextLanguageMode()
    }
    
    private static func lessLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterLess() when package is available
        return PlainTextLanguageMode()
    }
    
    private static func xmlLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterXML() when package is available
        return PlainTextLanguageMode()
    }
    
    private static func graphqlLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterGraphQL() when package is available
        return PlainTextLanguageMode()
    }
    
    private static func phpLanguageMode() -> LanguageMode {
        // TODO: Return TreeSitterPHP() when package is available
        return PlainTextLanguageMode()
    }
}

// MARK: - LanguageMode Protocol

/// Protocol that all TreeSitter language modes must conform to.
/// This will be implemented by each TreeSitter language wrapper.
public protocol LanguageMode {
    /// The name of the language
    var name: String { get }
    
    /// The file extensions associated with this language
    var extensions: [String] { get }
    
    /// Create a new language mode instance
    init()
}

// MARK: - Plain Text Language Mode

/// Fallback language mode for files without specific syntax highlighting.
public struct PlainTextLanguageMode: LanguageMode {
    public let name = "Plain Text"
    public let extensions: [String] = []
    
    public init() {}
}
