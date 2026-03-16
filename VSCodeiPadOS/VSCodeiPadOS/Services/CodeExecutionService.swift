import Foundation
import SwiftUI
import JavaScriptCore

// MARK: - CodeExecutionService

/// Service that handles code execution requests from the Run menu.
/// Routes execution to appropriate runners based on file type and outputs results to the Output panel.
@MainActor
final class CodeExecutionService {
    static let shared = CodeExecutionService()
    
    // MARK: - Properties
    
    private var jsRunner: JSRunner?
    private var currentExecutionTask: Task<Void, Never>?
    private let outputManager = OutputPanelManager.shared
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Execute the currently active file
    /// - Parameters:
    ///   - fileName: Name of the file to execute
    ///   - content: Content/code of the file
    func executeCurrentFile(fileName: String, content: String) {
        let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
        
        switch fileExtension {
        case "js", "mjs":
            executeJavaScript(fileName: fileName, code: content)
        case "ts", "tsx":
            executeTypeScript(fileName: fileName, code: content)
        case "py":
            executePython(fileName: fileName, code: content)
        case "sh":
            executeShellScript(fileName: fileName, code: content)
        default:
            outputManager.append("[ERROR] No runner available for .\(fileExtension) files", to: OutputChannel.output, streamType: StreamType.stderr)
            outputManager.selectedChannel = OutputChannel.output
        }
    }
    
    // MARK: - TypeScript Execution
    
    private func executeTypeScript(fileName: String, code: String) {
        let strippedCode = stripTypeAnnotations(code)
        executeJavaScript(fileName: fileName, code: strippedCode)
    }
    
    /// Strips TypeScript-specific syntax to produce valid JavaScript.
    /// Handles: type annotations, interface/type declarations, generics, and 'as' casts.
    ///
    /// This is a best-effort transform that covers common TypeScript patterns.
    /// It will not handle every edge case but works for typical code.
    private func stripTypeAnnotations(_ code: String) -> String {
        var result = code
        
        // 1. Remove entire interface declarations (multi-line)
        result = result.replacingOccurrences(
            of: #"interface\s+\w+(\s*extends\s+\w+(\s*,\s*\w+)*)?\s*\{[^}]*\}"#,
            with: "",
            options: .regularExpression
        )
        
        // 2. Remove entire type alias declarations
        result = result.replacingOccurrences(
            of: #"type\s+\w+(\s*<[^>]*>)?\s*=\s*[^;]+;"#,
            with: "",
            options: .regularExpression
        )
        
        // 3. Remove 'as Type' and 'as unknown as Type' casts
        result = result.replacingOccurrences(
            of: #"\bas\s+(?:unknown\s+as\s+)?\w+(?:<[^>]*>)?(?=\s*[)\];,\n+\-])"#,
            with: "",
            options: .regularExpression
        )
        
        // 4. Remove angle bracket generics (e.g., Array<string> -> Array, Map<string, number> -> Map)
        result = result.replacingOccurrences(
            of: #"<[^>]+>"#,
            with: "",
            options: .regularExpression
        )
        
        // 5. Remove type annotations after colons in parameters and variables
        //    Match colon followed by a type expression up to the next delimiter
        result = result.replacingOccurrences(
            of: #":\s*(?:\{[^}]*\}|\([^)]*\)|[\w\[\]|&\.,\s]+?)(?=\s*[),=;{>\n])"#,
            with: "",
            options: .regularExpression
        )
        
        // 6. Remove return type annotations (e.g., function foo(): string { -> function foo() {)
        result = result.replacingOccurrences(
            of: #"\)\s*:\s*[^{]+\{"#,
            with: ") {",
            options: .regularExpression
        )
        
        // 7. Remove 'export' and 'export default' keywords
        result = result.replacingOccurrences(
            of: #"\bexport\s+(?:default\s+)?"#,
            with: "",
            options: .regularExpression
        )
        
        // 8. Remove 'declare' keyword
        result = result.replacingOccurrences(
            of: #"\bdeclare\s+"#,
            with: "",
            options: .regularExpression
        )
        
        // 9. Remove 'readonly' modifier
        result = result.replacingOccurrences(
            of: #"\breadonly\s+"#,
            with: "",
            options: .regularExpression
        )
        
        // 10. Convert TypeScript enums to JavaScript const objects
        // enum Color { Red, Green, Blue } -> const Color = Object.freeze({ Red: 0, Green: 1, Blue: 2 });
        let enumPattern = try? NSRegularExpression(pattern: #"enum\s+(\w+)\s*\{([^}]*)\}"#)
        if let enumPattern = enumPattern {
            let nsResult = result as NSString
            let matches = enumPattern.matches(in: result, range: NSRange(location: 0, length: nsResult.length))
            // Process in reverse to preserve indices
            for match in matches.reversed() {
                let enumName = nsResult.substring(with: match.range(at: 1))
                let enumBody = nsResult.substring(with: match.range(at: 2))
                let members = enumBody.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                var jsMembers: [String] = []
                for (i, member) in members.enumerated() {
                    let parts = member.components(separatedBy: "=")
                    let name = parts[0].trimmingCharacters(in: .whitespaces)
                    if parts.count > 1 {
                        let val = parts[1].trimmingCharacters(in: .whitespaces)
                        jsMembers.append("\(name): \(val)")
                    } else {
                        jsMembers.append("\(name): \(i)")
                    }
                }
                let replacement = "const \(enumName) = Object.freeze({ \(jsMembers.joined(separator: ", ")) });"
                result = (result as NSString).replacingCharacters(in: match.range, with: replacement)
            }
        }
        
        return result
    }
    
    // MARK: - Python Execution
    
    private func executePython(fileName: String, code: String) {
        outputManager.selectedChannel = OutputChannel.python
        outputManager.clear(OutputChannel.python)
        outputManager.append("▶ Running: \(fileName)", to: OutputChannel.python)
        outputManager.append("─────────────────────────────────────", to: OutputChannel.python)
        
        let ssh = SSHManager.shared
        if ssh.isConnected {
            Task { @MainActor in
                let startTime = Date()
                do {
                    // Escape single quotes in the code for safe shell execution
                    let escapedCode = code.replacingOccurrences(of: "'", with: "'\\''")
                    let command = "python3 -c '\(escapedCode)'"
                    let result = try await ssh.executeCommand(command, timeout: 30)
                    let duration = Date().timeIntervalSince(startTime)
                    
                    if !result.stdout.isEmpty {
                        outputManager.append(result.stdout, to: OutputChannel.python)
                    }
                    if !result.stderr.isEmpty {
                        outputManager.append(result.stderr, to: OutputChannel.python, streamType: StreamType.stderr)
                    }
                    
                    outputManager.append("─────────────────────────────────────", to: OutputChannel.python)
                    let statusIcon = result.isSuccess ? "✓" : "✗"
                    outputManager.append("\(statusIcon) Completed in \(String(format: "%.2f", duration * 1000))ms (exit code: \(result.exitCode))", to: OutputChannel.python)
                    
                } catch {
                    outputManager.append("─────────────────────────────────────", to: OutputChannel.python)
                    outputManager.append("✗ SSH Error: \(error.localizedDescription)", to: OutputChannel.python, streamType: StreamType.stderr)
                }
            }
        } else {
            outputManager.append("[INFO] Python execution requires a remote server connection.", to: OutputChannel.python, streamType: StreamType.stderr)
            outputManager.append("[INFO] Connect to a remote server via SSH to enable Python support.", to: OutputChannel.python, streamType: StreamType.stderr)
            outputManager.append("[INFO] Open the Remote Explorer panel to configure an SSH connection.", to: OutputChannel.python, streamType: StreamType.stderr)
        }
    }
    
    // MARK: - Shell Script Execution
    
    private func executeShellScript(fileName: String, code: String) {
        outputManager.selectedChannel = OutputChannel.output
        outputManager.clear(OutputChannel.output)
        outputManager.append("▶ Running: \(fileName)", to: OutputChannel.output)
        outputManager.append("─────────────────────────────────────", to: OutputChannel.output)
        
        let ssh = SSHManager.shared
        if ssh.isConnected {
            Task { @MainActor in
                let startTime = Date()
                do {
                    // Escape single quotes in the code for safe shell execution
                    let escapedCode = code.replacingOccurrences(of: "'", with: "'\\''")
                    let command = "bash -c '\(escapedCode)'"
                    let result = try await ssh.executeCommand(command, timeout: 30)
                    let duration = Date().timeIntervalSince(startTime)
                    
                    if !result.stdout.isEmpty {
                        outputManager.append(result.stdout, to: OutputChannel.output)
                    }
                    if !result.stderr.isEmpty {
                        outputManager.append(result.stderr, to: OutputChannel.output, streamType: StreamType.stderr)
                    }
                    
                    outputManager.append("─────────────────────────────────────", to: OutputChannel.output)
                    let statusIcon = result.isSuccess ? "✓" : "✗"
                    outputManager.append("\(statusIcon) Completed in \(String(format: "%.2f", duration * 1000))ms (exit code: \(result.exitCode))", to: OutputChannel.output)
                    
                } catch {
                    outputManager.append("─────────────────────────────────────", to: OutputChannel.output)
                    outputManager.append("✗ SSH Error: \(error.localizedDescription)", to: OutputChannel.output, streamType: StreamType.stderr)
                }
            }
        } else {
            outputManager.append("[INFO] Shell script execution requires a remote server connection.", to: OutputChannel.output, streamType: StreamType.stderr)
            outputManager.append("[INFO] Connect to a remote server via SSH to enable shell script support.", to: OutputChannel.output, streamType: StreamType.stderr)
            outputManager.append("[INFO] Open the Remote Explorer panel to configure an SSH connection.", to: OutputChannel.output, streamType: StreamType.stderr)
        }
    }
    
    // MARK: - JavaScript Execution
    
    private func executeJavaScript(fileName: String, code: String) {
        // Cancel any previous execution to prevent race conditions
        currentExecutionTask?.cancel()
        jsRunner = nil
        
        // Switch to JavaScript output channel
        outputManager.selectedChannel = OutputChannel.javascript
        
        // Clear previous output and show execution header
        outputManager.clear(OutputChannel.javascript)
        outputManager.append("▶ Running: \(fileName)", to: OutputChannel.javascript)
        outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
        
        // Create a fresh JSRunner instance
        let runner = JSRunner()
        jsRunner = runner
        
        // Set up console handler to capture output
        runner.setConsoleHandler { [weak self] message in
            Task { @MainActor in
                guard let self = self else { return }
                
                // Determine stream type based on message prefix
                let streamType: StreamType = message.hasPrefix("[ERROR]") || message.hasPrefix("[EXCEPTION]") ? StreamType.stderr : StreamType.stdout
                
                // Remove the prefix for cleaner output display
                var cleanMessage = message
                for prefix in ["[LOG] ", "[INFO] ", "[WARN] ", "[ERROR] ", "[EXCEPTION] "] {
                    if message.hasPrefix(prefix) {
                        cleanMessage = String(message.dropFirst(prefix.count))
                        break
                    }
                }
                
                self.outputManager.append(cleanMessage, to: OutputChannel.javascript, streamType: streamType)
            }
        }
        
        // Execute the code asynchronously with cancellation support
        currentExecutionTask = Task { @MainActor in
            let startTime = Date()
            
            do {
                guard !Task.isCancelled else { return }
                let result = try await runner.execute(code: code)
                guard !Task.isCancelled else { return }
                let duration = Date().timeIntervalSince(startTime)
                
                // Show completion separator
                outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
                
                // Show result if it's not undefined
                if !result.isUndefined {
                    let resultString = formatJSValue(result)
                    outputManager.append("⮐ Result: \(resultString)", to: OutputChannel.javascript)
                }
                
                // Show completion message
                outputManager.append("✓ Completed in \(String(format: "%.2f", duration * 1000))ms", to: OutputChannel.javascript)
                
            } catch {
                guard !Task.isCancelled else { return }
                outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
                outputManager.append("✗ Error: \(error.localizedDescription)", to: OutputChannel.javascript, streamType: StreamType.stderr)
            }
            
            // Clean up runner only if it's still the current one
            if self.jsRunner === runner {
                self.jsRunner = nil
            }
            self.currentExecutionTask = nil
        }
    }
    
    // MARK: - Helpers
    
    /// Format a JSValue for display
    private func formatJSValue(_ value: JSValue) -> String {
        if value.isNull {
            return "null"
        } else if value.isUndefined {
            return "undefined"
        } else if value.isBoolean {
            return value.toBool() ? "true" : "false"
        } else if value.isNumber {
            let num = value.toNumber()
            // Check if it's an integer
            if let n = num, n.doubleValue.truncatingRemainder(dividingBy: 1) == 0, !n.doubleValue.isInfinite, !n.doubleValue.isNaN {
                return String(format: "%.0f", n.doubleValue)
            }
            return "\(num?.doubleValue ?? 0)"
        } else if value.isString {
            return "\"\(value.toString() ?? "")\""
        } else if value.isArray {
            if let array = value.toArray() {
                return "[\(array.map { "\($0)" }.joined(separator: ", "))]"
            }
            return "[]"
        } else if value.isObject {
            if let dict = value.toDictionary() {
                let json = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
                if let json = json, let str = String(data: json, encoding: .utf8) {
                    return str
                }
            }
            return value.toString() ?? "[object]"
        }
        return value.toString() ?? "undefined"
    }
}
