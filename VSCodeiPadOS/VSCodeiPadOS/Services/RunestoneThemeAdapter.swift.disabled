//
//  RunestoneThemeAdapter.swift
//  VSCodeiPadOS
//
//  Maps our Theme struct to Runestone's Theme protocol for syntax highlighting
//

import UIKit
import SwiftUI
import Runestone

// MARK: - VSCodeRunestoneTheme

/// A Runestone Theme implementation that adapts our app's Theme struct
/// to Runestone's expected theme protocol for syntax highlighting.
public final class VSCodeRunestoneTheme: Runestone.Theme {
    
    // MARK: - Properties
    
    private let theme: Models.Theme
    private let fontSize: CGFloat
    
    // MARK: - Required Theme Properties
    
    public var font: UIFont {
        .monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }
    
    public var textColor: UIColor {
        UIColor(theme.editorForeground)
    }
    
    public var gutterBackgroundColor: UIColor {
        UIColor(theme.sidebarBackground)
    }
    
    public var gutterHairlineColor: UIColor {
        UIColor(theme.sidebarBackground).withAlphaComponent(0.5)
    }
    
    public var gutterHairlineWidth: CGFloat {
        1.0 / UIScreen.main.scale
    }
    
    public var lineNumberColor: UIColor {
        UIColor(theme.lineNumber)
    }
    
    public var lineNumberFont: UIFont {
        .monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }
    
    public var selectedLineBackgroundColor: UIColor {
        UIColor(theme.currentLineHighlight)
    }
    
    public var selectedLinesLineNumberColor: UIColor {
        UIColor(theme.lineNumberActive)
    }
    
    public var selectedLinesGutterBackgroundColor: UIColor {
        UIColor(theme.sidebarBackground)
    }
    
    public var invisibleCharactersColor: UIColor {
        UIColor(theme.lineNumber).withAlphaComponent(0.4)
    }
    
    public var pageGuideHairlineColor: UIColor {
        UIColor(theme.indentGuide)
    }
    
    public var pageGuideHairlineWidth: CGFloat {
        1.0 / UIScreen.main.scale
    }
    
    public var pageGuideBackgroundColor: UIColor {
        UIColor(theme.editorBackground).withAlphaComponent(0.5)
    }
    
    public var markedTextBackgroundColor: UIColor {
        UIColor(theme.selection)
    }
    
    public var markedTextBackgroundCornerRadius: CGFloat {
        2.0
    }
    
    // MARK: - Initialization
    
    /// Creates a Runestone theme from our app's Theme struct
    /// - Parameters:
    ///   - theme: Our app's Theme struct containing colors and styles
    ///   - fontSize: Font size for editor text (default: 14)
    public init(theme: Models.Theme, fontSize: CGFloat = 14) {
        self.theme = theme
        self.fontSize = fontSize
    }
    
    // MARK: - Syntax Highlighting
    
    /// Returns the text color for a given Tree-sitter highlight name
    /// - Parameter highlightName: The Tree-sitter capture name (e.g., "keyword", "string")
    /// - Returns: The UIColor to use for that highlight, or nil for default color
    public func textColor(for highlightName: String) -> UIColor? {
        // Handle compound highlight names like "keyword.return" by checking prefixes
        let normalizedName = normalizeHighlightName(highlightName)
        
        switch normalizedName {
        // Keywords (control flow, storage, etc.)
        case "keyword", "keyword.control", "keyword.return", "keyword.function",
             "keyword.operator", "keyword.import", "keyword.storage", "keyword.type":
            return UIColor(theme.keyword)
            
        // Strings and string-like content
        case "string", "string.special", "string.escape", "string.regex":
            return UIColor(theme.string)
            
        // Comments
        case "comment", "comment.line", "comment.block", "comment.documentation":
            return UIColor(theme.comment)
            
        // Functions and method calls
        case "function", "function.call", "function.method", "function.builtin",
             "method", "method.call":
            return UIColor(theme.function)
            
        // Types, classes, and type-like constructs
        case "type", "type.builtin", "type.definition", "type.qualifier",
             "class", "struct", "enum", "interface", "namespace":
            return UIColor(theme.type)
            
        // Variables and properties
        case "variable", "variable.parameter", "variable.member",
             "property", "property.definition", "field":
            return UIColor(theme.variable)
            
        // Variable builtins (self, this, super)
        case "variable.builtin", "variable.language":
            return UIColor(theme.keyword).withAlphaComponent(0.9)
            
        // Numbers and numeric constants
        case "number", "number.float", "float", "integer":
            return UIColor(theme.number)
            
        // Constants
        case "constant", "constant.builtin", "constant.character", "boolean":
            return UIColor(theme.number)
            
        // Constructors
        case "constructor":
            return UIColor(theme.function)
            
        // Operators and punctuation
        case "operator":
            return UIColor(theme.editorForeground)
            
        case "punctuation", "punctuation.bracket", "punctuation.delimiter",
             "punctuation.special":
            return UIColor(theme.editorForeground).withAlphaComponent(0.8)
            
        // Tags (HTML/XML)
        case "tag", "tag.builtin":
            return UIColor(theme.keyword)
            
        // Attributes
        case "attribute", "attribute.builtin":
            return UIColor(theme.function)
            
        // Labels
        case "label":
            return UIColor(theme.type)
            
        // Embedded code (like template literals)
        case "embedded":
            return UIColor(theme.string)
            
        default:
            // For unrecognized names, try to match by prefix
            return textColorByPrefix(highlightName)
        }
    }
    
    /// Attempts to find a color by checking highlight name prefixes
    private func textColorByPrefix(_ highlightName: String) -> UIColor? {
        if highlightName.hasPrefix("keyword") {
            return UIColor(theme.keyword)
        } else if highlightName.hasPrefix("string") {
            return UIColor(theme.string)
        } else if highlightName.hasPrefix("comment") {
            return UIColor(theme.comment)
        } else if highlightName.hasPrefix("function") || highlightName.hasPrefix("method") {
            return UIColor(theme.function)
        } else if highlightName.hasPrefix("type") || highlightName.hasPrefix("class") {
            return UIColor(theme.type)
        } else if highlightName.hasPrefix("variable") || highlightName.hasPrefix("property") {
            return UIColor(theme.variable)
        } else if highlightName.hasPrefix("number") || highlightName.hasPrefix("constant") {
            return UIColor(theme.number)
        }
        return nil
    }
    
    /// Normalizes a highlight name by converting it to lowercase and trimming whitespace
    private func normalizeHighlightName(_ name: String) -> String {
        name.lowercased().trimmingCharacters(in: .whitespaces)
    }
    
    /// Returns the font for a given highlight name (optional override)
    /// - Parameter highlightName: The Tree-sitter capture name
    /// - Returns: A custom font, or nil to use the default font
    public func font(for highlightName: String) -> UIFont? {
        // Use default font for all highlights - traits will modify it
        return nil
    }
    
    /// Returns font traits (bold, italic) for a given highlight name
    /// - Parameter highlightName: The Tree-sitter capture name
    /// - Returns: FontTraits to apply to the text
    public func fontTraits(for highlightName: String) -> FontTraits {
        let normalizedName = normalizeHighlightName(highlightName)
        
        switch normalizedName {
        // Keywords are bold
        case let name where name.hasPrefix("keyword"):
            return .bold
            
        // Comments are italic
        case let name where name.hasPrefix("comment"):
            return .italic
            
        // Type definitions can be bold
        case "type.definition", "class", "struct", "enum", "interface":
            return .bold
            
        // Storage modifiers (static, const, etc.) are italic
        case "storage", "storage.modifier":
            return .italic
            
        default:
            return []
        }
    }
    
    /// Returns a shadow for a given highlight name (optional)
    /// - Parameter highlightName: The Tree-sitter capture name
    /// - Returns: An NSShadow to apply, or nil for no shadow
    public func shadow(for highlightName: String) -> NSShadow? {
        // No shadows by default - can be customized if needed
        return nil
    }
    
    /// Returns highlighted range styling for search results (iOS 16+)
    @available(iOS 16.0, *)
    public func highlightedRange(
        forFoundTextRange foundTextRange: NSRange,
        ofStyle style: UITextSearchFoundTextStyle
    ) -> HighlightedRange? {
        switch style {
        case .found:
            // Background for all matches
            return HighlightedRange(
                range: foundTextRange,
                color: UIColor(theme.selection).withAlphaComponent(0.4),
                cornerRadius: 2
            )
        case .highlighted:
            // Background for the current/active match
            return HighlightedRange(
                range: foundTextRange,
                color: UIColor(theme.selection),
                cornerRadius: 2
            )
        case .normal:
            return nil
        @unknown default:
            return nil
        }
    }
}

// MARK: - RunestoneThemeAdapter

/// Static helper for creating Runestone themes from our app's Theme struct
public enum RunestoneThemeAdapter {
    
    /// Creates a Runestone Theme from our app's Theme struct
    /// - Parameters:
    ///   - theme: The app's Theme to convert
    ///   - fontSize: Font size for the editor (default: 14)
    /// - Returns: A Runestone-compatible Theme
    public static func theme(from theme: Models.Theme, fontSize: CGFloat = 14) -> Runestone.Theme {
        VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
    }
    
    /// Creates a Runestone Theme from our app's Theme with customized settings
    /// - Parameters:
    ///   - theme: The app's Theme to convert
    ///   - fontSize: Font size for the editor
    /// - Returns: A VSCodeRunestoneTheme instance
    public static func createTheme(
        from theme: Models.Theme,
        fontSize: CGFloat = 14
    ) -> VSCodeRunestoneTheme {
        VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
    }
}

// MARK: - Theme Namespace Alias

/// Namespace alias to avoid conflicts between our Theme model and Runestone's Theme protocol
public enum Models {
    public typealias Theme = VSCodeiPadOS.Theme
}
