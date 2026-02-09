import Foundation
import UIKit
import SwiftUI

// MARK: - ParsedError Structure

/// Represents a parsed error with file location and severity
struct ParsedError: Identifiable, Equatable, Hashable, Codable {
    let id = UUID()
    let file: String
    let line: Int
    let column: Int
    let message: String
    let severity: ErrorSeverity
    
    enum ErrorSeverity: String, Codable, CaseIterable {
        case error = "error"
        case warning = "warning"
        case note = "note"
        case info = "info"
        case unknown = "unknown"
        
        var displayName: String {
            switch self {
            case .error: return "Error"
            case .warning: return "Warning"
            case .note: return "Note"
            case .info: return "Info"
            case .unknown: return "Unknown"
            }
        }
        
        var color: UIColor {
            switch self {
            case .error: return .systemRed
            case .warning: return .systemYellow
            case .note: return .systemBlue
            case .info: return .systemGreen
            case .unknown: return .systemGray
            }
        }
    }
    
    /// Creates a sanitized file path
    var sanitizedFile: String {
        return file.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns a display-friendly location string
    var locationString: String {
        if column > 0 {
            return "\(sanitizedFile):\(line):\(column)"
        }
        return "\(sanitizedFile):\(line)"
    }
    
    /// Converts to legacy ErrorLocation for backward compatibility
    func toErrorLocation(errorType: ErrorLocation.ErrorType = .unknown, fullOutput: String = "") -> ErrorLocation {
        return ErrorLocation(
            file: file,
            line: line,
            column: column,
            message: "[\(severity.displayName.uppercased())] \(message)",
            errorType: errorType,
            fullOutput: fullOutput
        )
    }
}

// MARK: - Static Parser Functions

/// Parse Swift compiler errors from output
func parseSwiftError(output: String) -> [ParsedError] {
    var errors: [ParsedError] = []
    let pattern = try! NSRegularExpression(
        pattern: #"^([^:]+):(\d+):(\d+):\s*(error|warning|note):\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    let nsRange = NSRange(output.startIndex..., in: output)
    let matches = pattern.matches(in: output, range: nsRange)
    
    for match in matches {
        guard let fileRange = Range(match.range(at: 1), in: output),
              let lineRange = Range(match.range(at: 2), in: output),
              let colRange = Range(match.range(at: 3), in: output),
              let severityRange = Range(match.range(at: 4), in: output),
              let messageRange = Range(match.range(at: 5), in: output) else {
            continue
        }
        
        let file = String(output[fileRange])
        let line = Int(output[lineRange]) ?? 1
        let column = Int(output[colRange]) ?? 0
        let severityString = String(output[severityRange])
        let message = String(output[messageRange])
        
        let severity = ParsedError.ErrorSeverity(rawValue: severityString) ?? .unknown
        
        errors.append(ParsedError(
            file: file,
            line: line,
            column: column,
            message: message,
            severity: severity
        ))
    }
    
    return errors
}

/// Parse Python errors from traceback output
func parsePythonError(output: String) -> [ParsedError] {
    var errors: [ParsedError] = []
    
    // Python traceback pattern: File "path", line N
    let filePattern = try! NSRegularExpression(
        pattern: #"File \"([^\"]+)\", line (\d+)(?:, in (.+))?"#,
        options: []
    )
    
    // Python exception pattern at the end of traceback
    let exceptionPattern = try! NSRegularExpression(
        pattern: #"^(\w+Error):\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    let nsRange = NSRange(output.startIndex..., in: output)
    let matches = filePattern.matches(in: output, range: nsRange)
    
    // Get exception message from the end
    var exceptionMessage = "Unknown Python error"
    if let exceptionMatch = exceptionPattern.firstMatch(in: output, range: nsRange) {
        if let messageRange = Range(exceptionMatch.range(at: 2), in: output) {
            exceptionMessage = String(output[messageRange])
        }
    }
    
    for match in matches {
        guard let fileRange = Range(match.range(at: 1), in: output),
              let lineRange = Range(match.range(at: 2), in: output) else {
            continue
        }
        
        let file = String(output[fileRange])
        let line = Int(output[lineRange]) ?? 1
        
        // Try to get function name
        var message = exceptionMessage
        if match.numberOfRanges > 3,
           let funcRange = Range(match.range(at: 3), in: output) {
            let function = String(output[funcRange])
            message = "\(exceptionMessage) (in '\(function)')"
        }
        
        errors.append(ParsedError(
            file: file,
            line: line,
            column: 0,
            message: message,
            severity: .error
        ))
    }
    
    return errors
}

/// Parse Node.js/JavaScript errors from stack trace output
func parseNodeError(output: String) -> [ParsedError] {
    var errors: [ParsedError] = []
    
    // Node.js/V8 stack trace pattern: at function (path:line:column)
    let stackPattern = try! NSRegularExpression(
        pattern: #"at\s+(?:.+?\s+)?\(?([^:]+):(\d+):(\d+)\)?"#,
        options: []
    )
    
    // Node.js error message pattern
    let errorPattern = try! NSRegularExpression(
        pattern: #"^(\w+Error):\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    let nsRange = NSRange(output.startIndex..., in: output)
    
    // Extract error message
    var errorMessage = "Unknown JavaScript error"
    if let errorMatch = errorPattern.firstMatch(in: output, range: nsRange) {
        if let typeRange = Range(errorMatch.range(at: 1), in: output),
           let messageRange = Range(errorMatch.range(at: 2), in: output) {
            let errorType = String(output[typeRange])
            let message = String(output[messageRange])
            errorMessage = "\(errorType): \(message)"
        }
    }
    
    // Find all stack trace locations
    let matches = stackPattern.matches(in: output, range: nsRange)
    
    for match in matches {
        guard let fileRange = Range(match.range(at: 1), in: output),
              let lineRange = Range(match.range(at: 2), in: output),
              let colRange = Range(match.range(at: 3), in: output) else {
            continue
        }
        
        let file = String(output[fileRange])
        let line = Int(output[lineRange]) ?? 1
        let column = Int(output[colRange]) ?? 0
        
        errors.append(ParsedError(
            file: file,
            line: line,
            column: column,
            message: errorMessage,
            severity: .error
        ))
    }
    
    return errors
}

/// Parse GCC/Clang compiler errors from output
func parseGccError(output: String) -> [ParsedError] {
    var errors: [ParsedError] = []
    
    // GCC/Clang error pattern: path:line:column: error: message
    let pattern = try! NSRegularExpression(
        pattern: #"^([^:]+):(\d+):(\d+):\s*(error|warning|note):\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    let nsRange = NSRange(output.startIndex..., in: output)
    let matches = pattern.matches(in: output, range: nsRange)
    
    for match in matches {
        guard let fileRange = Range(match.range(at: 1), in: output),
              let lineRange = Range(match.range(at: 2), in: output),
              let colRange = Range(match.range(at: 3), in: output),
              let severityRange = Range(match.range(at: 4), in: output),
              let messageRange = Range(match.range(at: 5), in: output) else {
            continue
        }
        
        let file = String(output[fileRange])
        let line = Int(output[lineRange]) ?? 1
        let column = Int(output[colRange]) ?? 0
        let severityString = String(output[severityRange])
        let message = String(output[messageRange])
        
        let severity = ParsedError.ErrorSeverity(rawValue: severityString) ?? .unknown
        
        errors.append(ParsedError(
            file: file,
            line: line,
            column: column,
            message: message,
            severity: severity
        ))
    }
    
    return errors
}

/// Parse Rust compiler errors from output
func parseRustError(output: String) -> [ParsedError] {
    var errors: [ParsedError] = []
    
    // Rust error pattern: error[EXXXX]: message
    // followed by --> path:line:column
    let errorHeaderPattern = try! NSRegularExpression(
        pattern: #"^(error|warning)\[(E\d+)\]:\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    // Rust location pattern: --> path:line:column
    let locationPattern = try! NSRegularExpression(
        pattern: #"^\s*-->\s+([^:]+):(\d+):(\d+)"#,
        options: [.anchorsMatchLines]
    )
    
    // Alternative pattern without error code: error: message
    let simpleErrorPattern = try! NSRegularExpression(
        pattern: #"^(error|warning):\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    let nsRange = NSRange(output.startIndex..., in: output)
    let lines = output.components(separatedBy: .newlines)
    
    var currentMessage: String?
    var currentSeverity: ParsedError.ErrorSeverity = .error
    
    for (index, line) in lines.enumerated() {
        let lineRange = NSRange(line.startIndex..., in: line)
        
        // Check for error header with code
        if let match = errorHeaderPattern.firstMatch(in: line, range: lineRange) {
            if let severityRange = Range(match.range(at: 1), in: line),
               let codeRange = Range(match.range(at: 2), in: line),
               let messageRange = Range(match.range(at: 3), in: line) {
                let severityString = String(line[severityRange])
                let code = String(line[codeRange])
                let message = String(line[messageRange])
                currentMessage = "[\(code)] \(message)"
                currentSeverity = ParsedError.ErrorSeverity(rawValue: severityString) ?? .error
            }
        }
        // Check for simple error without code
        else if let match = simpleErrorPattern.firstMatch(in: line, range: lineRange) {
            if let severityRange = Range(match.range(at: 1), in: line),
               let messageRange = Range(match.range(at: 2), in: line) {
                let severityString = String(line[severityRange])
                let message = String(line[messageRange])
                currentMessage = message
                currentSeverity = ParsedError.ErrorSeverity(rawValue: severityString) ?? .error
            }
        }
        // Check for location line
        else if let match = locationPattern.firstMatch(in: line, range: lineRange) {
            if let fileRange = Range(match.range(at: 1), in: line),
               let lineNumRange = Range(match.range(at: 2), in: line),
               let colRange = Range(match.range(at: 3), in: line) {
                let file = String(line[fileRange])
                let lineNum = Int(line[lineNumRange]) ?? 1
                let column = Int(line[colRange]) ?? 0
                let message = currentMessage ?? "Rust \(currentSeverity.displayName)"
                
                errors.append(ParsedError(
                    file: file,
                    line: lineNum,
                    column: column,
                    message: message,
                    severity: currentSeverity
                ))
                
                // Reset for next error
                currentMessage = nil
            }
        }
    }
    
    return errors
}

/// Generic regex fallback parser for unknown formats
func parseGeneric(output: String) -> [ParsedError] {
    var errors: [ParsedError] = []
    
    // Generic file:line:column pattern as fallback
    let pattern = try! NSRegularExpression(
        pattern: #"([^\s:]+):(\d+)(?::(\d+))?"#,
        options: []
    )
    
    let nsRange = NSRange(output.startIndex..., in: output)
    let matches = pattern.matches(in: output, range: nsRange)
    
    for match in matches {
        guard let fileRange = Range(match.range(at: 1), in: output),
              let lineRange = Range(match.range(at: 2), in: output) else {
            continue
        }
        
        let file = String(output[fileRange])
        // Skip if it doesn't look like a file path
        if !file.contains("/") && !file.contains(".") && !file.contains("\\") {
            continue
        }
        
        let line = Int(output[lineRange]) ?? 1
        var column = 0
        
        if match.numberOfRanges > 3,
           let colRange = Range(match.range(at: 3), in: output) {
            let colString = String(output[colRange])
            column = Int(colString) ?? 0
        }
        
        errors.append(ParsedError(
            file: file,
            line: line,
            column: column,
            message: "Potential error at \(file):\(line)",
            severity: .unknown
        ))
    }
    
    return errors
}

// MARK: - Legacy ErrorLocation (backward compatibility)

/// Represents the location of an error in source code
struct ErrorLocation: Identifiable, Equatable, Hashable {
    let id = UUID()
    let file: String
    let line: Int
    let column: Int
    let message: String
    let errorType: ErrorType
    let fullOutput: String
    
    enum ErrorType: String, CaseIterable {
        case python
        case nodeJS
        case swift
        case go
        case ruby
        case gcc
        case rust
        case unknown
        
        var displayName: String {
            switch self {
            case .python: return "Python"
            case .nodeJS: return "Node.js"
            case .swift: return "Swift"
            case .go: return "Go"
            case .ruby: return "Ruby"
            case .gcc: return "GCC/Clang"
            case .rust: return "Rust"
            case .unknown: return "Unknown"
            }
        }
    }
    
    /// Creates a sanitized file path
    var sanitizedFile: String {
        return file.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns a display-friendly location string
    var locationString: String {
        if column > 0 {
            return "\(sanitizedFile):\(line):\(column)"
        }
        return "\(sanitizedFile):\(line)"
    }
    
    /// Converts to new ParsedError format
    func toParsedError() -> ParsedError {
        let severity: ParsedError.ErrorSeverity
        if message.contains("[ERROR]") {
            severity = .error
        } else if message.contains("[WARNING]") {
            severity = .warning
        } else if message.contains("[NOTE]") {
            severity = .note
        } else {
            severity = .unknown
        }
        
        // Clean up message by removing severity prefix
        var cleanMessage = message
            .replacingOccurrences(of: "[ERROR] ", with: "")
            .replacingOccurrences(of: "[WARNING] ", with: "")
            .replacingOccurrences(of: "[NOTE] ", with: "")
        
        return ParsedError(
            file: file,
            line: line,
            column: column,
            message: cleanMessage,
            severity: severity
        )
    }
}

// MARK: - Protocol for error navigation delegates

protocol ErrorNavigationDelegate: AnyObject {
    func navigateToFile(_ file: String, line: Int, column: Int)
    func highlightError(in outputView: UIView, location: ErrorLocation)
}

// MARK: - Main ErrorParser Class

/// Parser for extracting error locations from various language outputs
class ErrorParser {
    
    // MARK: - Regex Patterns
    
    /// Python traceback pattern: File "path", line N
    private let pythonPattern = try! NSRegularExpression(
        pattern: #"File \"([^\"]+)\", line (\d+)(?:, in (.+))?"#,
        options: []
    )
    
    /// Python exception pattern at the end of traceback
    private let pythonExceptionPattern = try! NSRegularExpression(
        pattern: #"^(\w+Error):\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    /// Node.js/V8 stack trace pattern: at function (path:line:column)
    private let nodeJSPattern = try! NSRegularExpression(
        pattern: #"at\s+(?:.+?\s+)?\(?([^:]+):(\d+):(\d+)\)?"#,
        options: []
    )
    
    /// Node.js error message pattern
    private let nodeJSErrorPattern = try! NSRegularExpression(
        pattern: #"^(\w+Error):\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    /// Swift compiler error pattern: path:line:column: error: message
    private let swiftPattern = try! NSRegularExpression(
        pattern: #"^([^:]+):(\d+):(\d+):\s*(error|warning|note):\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    /// Go build error pattern: path:line:column: message OR path:line: message
    private let goPattern = try! NSRegularExpression(
        pattern: #"^([^:]+):(\d+)(?::(\d+))?:\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    /// Ruby error pattern: path:line:in `method': message (ErrorClass)
    private let rubyPattern = try! NSRegularExpression(
        pattern: #"^([^:]+):(\d+):in\s+`([^']+)':\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    /// Ruby traceback pattern: from path:line:in `method'
    private let rubyTracePattern = try! NSRegularExpression(
        pattern: #"from\s+([^:]+):(\d+):in\s+`([^']+)'"#,
        options: []
    )
    
    /// GCC/Clang error pattern: path:line:column: error: message
    private let gccPattern = try! NSRegularExpression(
        pattern: #"^([^:]+):(\d+):(\d+):\s*(error|warning|note):\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    /// Rust error header pattern: error[E####]: message
    private let rustErrorPattern = try! NSRegularExpression(
        pattern: #"^(error|warning)\[(E\d+)\]:\s*(.+)$"#,
        options: [.anchorsMatchLines]
    )
    
    /// Rust location pattern: --> path:line:column
    private let rustLocationPattern = try! NSRegularExpression(
        pattern: #"^\s*-->\s+([^:]+):(\d+):(\d+)"#,
        options: [.anchorsMatchLines]
    )
    
    /// Generic file:line pattern as fallback
    private let genericPattern = try! NSRegularExpression(
        pattern: #"([^\s:]+):(\d+)(?::(\d+))?"#,
        options: []
    )
    
    // MARK: - Properties
    
    weak var navigationDelegate: ErrorNavigationDelegate?
    private var errorHighlighter: ErrorHighlighter?
    
    // MARK: - Initialization
    
    init(delegate: ErrorNavigationDelegate? = nil) {
        self.navigationDelegate = delegate
        self.errorHighlighter = ErrorHighlighter()
    }
    
    // MARK: - Public Methods
    
    /// Parse error output and extract all error locations using new ParsedError format
    func parseErrorsToParsedErrors(from output: String, language: ErrorLocation.ErrorType? = nil) -> [ParsedError] {
        if let lang = language {
            switch lang {
            case .python:
                return parsePythonError(output: output)
            case .nodeJS:
                return parseNodeError(output: output)
            case .swift:
                return parseSwiftError(output: output)
            case .go:
                return parseGoErrorsToParsedErrors(output)
            case .ruby:
                return parseRubyErrorsToParsedErrors(output)
            case .gcc:
                return parseGccError(output: output)
            case .rust:
                return parseRustError(output: output)
            case .unknown:
                return parseGeneric(output: output)
            }
        } else {
            // Try all parsers and combine results
            var allErrors: [ParsedError] = []
            allErrors.append(contentsOf: parseSwiftError(output: output))
            allErrors.append(contentsOf: parsePythonError(output: output))
            allErrors.append(contentsOf: parseNodeError(output: output))
            allErrors.append(contentsOf: parseGccError(output: output))
            allErrors.append(contentsOf: parseRustError(output: output))
            allErrors.append(contentsOf: parseGoErrorsToParsedErrors(output))
            allErrors.append(contentsOf: parseRubyErrorsToParsedErrors(output))
            
            // If no specific errors found, try generic parsing
            if allErrors.isEmpty {
                allErrors.append(contentsOf: parseGeneric(output: output))
            }
            
            // Remove duplicates while preserving order
            var seen = Set<String>()
            return allErrors.filter { error in
                let key = "\(error.file):\(error.line):\(error.column)"
                if seen.contains(key) {
                    return false
                }
                seen.insert(key)
                return true
            }
        }
    }
    
    /// Parse error output and extract all error locations (legacy format)
    func parseErrors(from output: String, language: ErrorLocation.ErrorType? = nil) -> [ErrorLocation] {
        let parsedErrors = parseErrorsToParsedErrors(from: output, language: language)
        return parsedErrors.map { error in
            let type = language ?? detectLanguage(from: output)
            return error.toErrorLocation(errorType: type, fullOutput: output)
        }
    }
    
    /// Navigate to a specific error location
    func navigateToError(_ error: ErrorLocation) {
        navigationDelegate?.navigateToFile(
            error.sanitizedFile,
            line: error.line,
            column: error.column
        )
    }
    
    /// Navigate to a specific parsed error
    func navigateToParsedError(_ error: ParsedError) {
        navigationDelegate?.navigateToFile(
            error.sanitizedFile,
            line: error.line,
            column: error.column
        )
    }
    
    /// Highlight all errors in an output view
    func highlightErrors(in outputView: UIView, errors: [ErrorLocation]) {
        errorHighlighter?.highlightErrors(in: outputView, errors: errors)
    }
    
    /// Highlight all parsed errors in an output view
    func highlightParsedErrors(in outputView: UIView, errors: [ParsedError]) {
        let locations = errors.map { $0.toErrorLocation(fullOutput: "") }
        errorHighlighter?.highlightErrors(in: outputView, errors: locations)
    }
    
    /// Clear all error highlights from a view
    func clearHighlights(from view: UIView) {
        errorHighlighter?.clearHighlights(from: view)
    }
    
    // MARK: - Private Helper Methods
    
    private func detectLanguage(from output: String) -> ErrorLocation.ErrorType {
        // Auto-detect language based on patterns in output
        if output.contains("File \"") && output.contains("Traceback") {
            return .python
        } else if output.contains("at ") && output.contains(".js:") {
            return .nodeJS
        } else if output.contains(".swift:") && output.contains("error:") {
            return .swift
        } else if output.contains("error[E") && output.contains("-->") {
            return .rust
        } else if output.contains(".go:") {
            return .go
        } else if output.contains(".rb:") && output.contains("in `") {
            return .ruby
        } else if output.contains(".c:") || output.contains(".cpp:") || output.contains(".h:") {
            return .gcc
        }
        return .unknown
    }
    
    // MARK: - Legacy Parsing Methods (maintained for compatibility)
    
    private func parseGoErrorsToParsedErrors(_ output: String) -> [ParsedError] {
        var errors: [ParsedError] = []
        let nsRange = NSRange(output.startIndex..., in: output)
        let matches = goPattern.matches(in: output, range: nsRange)
        
        for match in matches {
            guard let fileRange = Range(match.range(at: 1), in: output),
                  let lineRange = Range(match.range(at: 2), in: output) else {
                continue
            }
            
            let file = String(output[fileRange])
            let line = Int(output[lineRange]) ?? 1
            var column = 0
            
            if match.numberOfRanges > 3,
               let colRange = Range(match.range(at: 3), in: output) {
                let colString = String(output[colRange])
                column = Int(colString) ?? 0
            }
            
            guard let messageRange = Range(match.range(at: 4), in: output) else {
                continue
            }
            let message = String(output[messageRange])
            
            errors.append(ParsedError(
                file: file,
                line: line,
                column: column,
                message: message,
                severity: .error
            ))
        }
        
        return errors
    }
    
    private func parseRubyErrorsToParsedErrors(_ output: String) -> [ParsedError] {
        var errors: [ParsedError] = []
        let nsRange = NSRange(output.startIndex..., in: output)
        
        // Parse main error line
        let mainMatches = rubyPattern.matches(in: output, range: nsRange)
        
        for match in mainMatches {
            guard let fileRange = Range(match.range(at: 1), in: output),
                  let lineRange = Range(match.range(at: 2), in: output),
                  let funcRange = Range(match.range(at: 3), in: output),
                  let messageRange = Range(match.range(at: 4), in: output) else {
                continue
            }
            
            let file = String(output[fileRange])
            let line = Int(output[lineRange]) ?? 1
            let function = String(output[funcRange])
            let message = String(output[messageRange])
            
            errors.append(ParsedError(
                file: file,
                line: line,
                column: 0,
                message: "\(message) (in '\(function)')",
                severity: .error
            ))
        }
        
        // Parse traceback lines
        let traceMatches = rubyTracePattern.matches(in: output, range: nsRange)
        
        for match in traceMatches {
            guard let fileRange = Range(match.range(at: 1), in: output),
                  let lineRange = Range(match.range(at: 2), in: output) else {
                continue
            }
            
            let file = String(output[fileRange])
            let line = Int(output[lineRange]) ?? 1
            
            errors.append(ParsedError(
                file: file,
                line: line,
                column: 0,
                message: "Called from traceback",
                severity: .note
            ))
        }
        
        return errors
    }
}

// MARK: - Error Highlighter

/// Handles visual highlighting of errors in output views
class ErrorHighlighter {
    
    private var highlightViews: [UIView] = []
    
    /// Highlight error locations in a text view
    func highlightErrors(in outputView: UIView, errors: [ErrorLocation]) {
        clearHighlights(from: outputView)
        
        guard let textView = outputView as? UITextView else {
            // For non-text views, add overlay highlights
            addOverlayHighlights(to: outputView, errors: errors)
            return
        }
        
        highlightInTextView(textView, errors: errors)
    }
    
    /// Clear all highlights from a view
    func clearHighlights(from view: UIView) {
        for highlightView in highlightViews {
            highlightView.removeFromSuperview()
        }
        highlightViews.removeAll()
        
        // Reset text view attributes if applicable
        if let textView = view as? UITextView {
            let text = textView.text
            textView.attributedText = NSAttributedString(string: text)
        }
    }
    
    // MARK: - Private Methods
    
    private func highlightInTextView(_ textView: UITextView, errors: [ErrorLocation]) {
        guard !errors.isEmpty else { return }
        
        let attributedText = NSMutableAttributedString(string: textView.text)
        let text = textView.text
        
        // Set default attributes
        let fullRange = NSRange(location: 0, length: text.count)
        attributedText.addAttribute(
            .foregroundColor,
            value: UIColor.label,
            range: fullRange
        )
        
        // Highlight each error location
        for error in errors {
            // Find the location string in the text
            let locationString = error.locationString
            if let range = text.range(of: locationString) {
                let nsRange = NSRange(range, in: text)
                
                // Apply error styling
                attributedText.addAttribute(
                    .backgroundColor,
                    value: UIColor.systemRed.withAlphaComponent(0.3),
                    range: nsRange
                )
                attributedText.addAttribute(
                    .foregroundColor,
                    value: UIColor.systemRed,
                    range: nsRange
                )
                attributedText.addAttribute(
                    .underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: nsRange
                )
            }
            
            // Also try to find and highlight the error message
            if let messageRange = text.range(of: error.message) {
                let nsRange = NSRange(messageRange, in: text)
                attributedText.addAttribute(
                    .foregroundColor,
                    value: UIColor.systemRed,
                    range: nsRange
                )
            }
        }
        
        textView.attributedText = attributedText
    }
    
    private func addOverlayHighlights(to view: UIView, errors: [ErrorLocation]) {
        // Add a badge showing error count
        let badge = UILabel()
        badge.text = "\(errors.count) error\(errors.count == 1 ? "" : "s")"
        badge.font = UIFont.preferredFont(forTextStyle: .caption1)
        badge.textColor = .white
        badge.backgroundColor = .systemRed
        badge.textAlignment = .center
        badge.layer.cornerRadius = 4
        badge.clipsToBounds = true
        
        badge.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(badge)
        
        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            badge.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            badge.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        highlightViews.append(badge)
    }
}

// MARK: - SwiftUI Integration

#if canImport(SwiftUI)

/// SwiftUI view modifier for error highlighting
struct ErrorHighlightModifier: ViewModifier {
    let errors: [ErrorLocation]
    let parser: ErrorParser
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ErrorBadgeView(errors: errors)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(8)
            )
    }
}

/// Badge showing error count
struct ErrorBadgeView: View {
    let errors: [ErrorLocation]
    
    var body: some View {
        if errors.isEmpty {
            EmptyView()
        } else {
            Text("\(errors.count) error\(errors.count == 1 ? "" : "s")")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(4)
        }
    }
}

/// SwiftUI view modifier for parsed error highlighting
struct ParsedErrorHighlightModifier: ViewModifier {
    let errors: [ParsedError]
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ParsedErrorBadgeView(errors: errors)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(8)
            )
    }
}

/// Badge showing parsed error count with severity breakdown
struct ParsedErrorBadgeView: View {
    let errors: [ParsedError]
    
    private var errorCount: Int {
        errors.filter { $0.severity == .error }.count
    }
    
    private var warningCount: Int {
        errors.filter { $0.severity == .warning }.count
    }
    
    var body: some View {
        if errors.isEmpty {
            EmptyView()
        } else {
            HStack(spacing: 8) {
                if errorCount > 0 {
                    Text("\(errorCount) E")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                if warningCount > 0 {
                    Text("\(warningCount) W")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.8))
                        .foregroundColor(.black)
                        .cornerRadius(4)
                }
            }
        }
    }
}

extension View {
    /// Add error highlighting to a view
    func highlightErrors(_ errors: [ErrorLocation], parser: ErrorParser = ErrorParser()) -> some View {
        modifier(ErrorHighlightModifier(errors: errors, parser: parser))
    }
    
    /// Add parsed error highlighting to a view
    func highlightParsedErrors(_ errors: [ParsedError]) -> some View {
        modifier(ParsedErrorHighlightModifier(errors: errors))
    }
}

#endif

// MARK: - Example Usage & Testing

#if DEBUG

extension ErrorParser {
    
    /// Sample Python traceback for testing
    static var samplePythonError: String {
        """
        Traceback (most recent call last):
          File "/Users/dev/project/main.py", line 42, in <module>
            result = process_data(data)
          File "/Users/dev/project/utils.py", line 15, in process_data
            return data[0] / data[1]
        ZeroDivisionError: division by zero
        """
    }
    
    /// Sample Node.js error for testing
    static var sampleNodeJSError: String {
        """
        TypeError: Cannot read property 'name' of undefined
            at Object.processUser (/Users/dev/project/src/user.js:25:15)
            at /Users/dev/project/src/app.js:42:10
            at Layer.handle [as handle_request] (/Users/dev/project/node_modules/express/lib/router/layer.js:95:5)
        """
    }
    
    /// Sample Swift error for testing
    static var sampleSwiftError: String {
        """
        /Users/dev/project/Sources/Main.swift:42:15: error: value of optional type 'String?' must be unwrapped
                print(value.uppercased())
                      ^
        /Users/dev/project/Sources/Main.swift:42:15: note: coalesce using '??' to provide a default
        """
    }
    
    /// Sample Go error for testing
    static var sampleGoError: String {
        """
        # command-line-arguments
        ./main.go:42:10: undefined: someFunction
        ./utils.go:25:5: syntax error: unexpected newline, expecting comma or )
        """
    }
    
    /// Sample Ruby error for testing
    static var sampleRubyError: String {
        """
        /Users/dev/project/lib/processor.rb:15:in `process': undefined method `split' for nil:NilClass (NoMethodError)
        \tfrom /Users/dev/project/bin/run.rb:42:in `<main>'
        """
    }
    
    /// Sample GCC error for testing
    static var sampleGCCError: String {
        """
        main.c:42:15: error: expected ';' before 'return'
             printf("Hello")\n                       ^
                        ;
             return 0;
             ~~~~~~  
        main.c:25:5: warning: unused variable 'x' [-Wunused-variable]
        """
    }
    
    /// Sample Rust error for testing
    static var sampleRustError: String {
        """
        error[E0308]: mismatched types
         --> src/main.rs:42:18
          |
        42 |     let x: i32 = "hello";
          |                  ^^^^^^^ expected `i32`, found `&str`
          |
        warning: unused import: `std::io`
         --> src/lib.rs:10:5
          |
        10 | use std::io;
          |     ^^^^^^^
        """
    }
    
    /// Test all parsers with new ParsedError format
    static func runParsedErrorTests() -> [String: [ParsedError]] {
        return [
            "Python": parsePythonError(output: samplePythonError),
            "Node.js": parseNodeError(output: sampleNodeJSError),
            "Swift": parseSwiftError(output: sampleSwiftError),
            "Go": parseGoErrorsToParsedErrors(sampleGoError),
            "Ruby": parseRubyErrorsToParsedErrors(sampleRubyError),
            "GCC": parseGccError(output: sampleGCCError),
            "Rust": parseRustError(output: sampleRustError)
        ]
    }
    
    /// Test all parsers with legacy ErrorLocation format
    static func runTests() -> [String: [ErrorLocation]] {
        let parser = ErrorParser()
        
        return [
            "Python": parser.parseErrors(from: samplePythonError, language: .python),
            "Node.js": parser.parseErrors(from: sampleNodeJSError, language: .nodeJS),
            "Swift": parser.parseErrors(from: sampleSwiftError, language: .swift),
            "Go": parser.parseErrors(from: sampleGoError, language: .go),
            "Ruby": parser.parseErrors(from: sampleRubyError, language: .ruby),
            "GCC": parser.parseErrors(from: sampleGCCError, language: .gcc),
            "Rust": parser.parseErrors(from: sampleRustError, language: .rust)
        ]
    }
}

#endif
