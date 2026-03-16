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
    private let outputManager = OutputPanelManager.shared
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Execute the currently active file
    /// - Parameters:
    ///   - fileName: Name of the file to execute
    ///   - content: Content/code of the file
    func executeCurrentFile(fileName: String, content: String) {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        case "js", "mjs":
            executeJavaScript(fileName: fileName, code: content)
        case "ts", "tsx":
            outputManager.append("[ERROR] TypeScript execution requires transpilation. Coming soon!", to: OutputChannel.javascript, streamType: StreamType.stderr)
            outputManager.selectedChannel = OutputChannel.javascript
        case "py":
            outputManager.append("[ERROR] Python execution not yet available on-device.", to: OutputChannel.python, streamType: StreamType.stderr)
            outputManager.selectedChannel = OutputChannel.python
        default:
            outputManager.append("[ERROR] No runner available for .\(fileExtension) files", to: OutputChannel.output, streamType: StreamType.stderr)
            outputManager.selectedChannel = OutputChannel.output
        }
    }
    
    // MARK: - JavaScript Execution
    
    private func executeJavaScript(fileName: String, code: String) {
        // Switch to JavaScript output channel
        outputManager.selectedChannel = OutputChannel.javascript
        
        // Clear previous output and show execution header
        outputManager.clear(OutputChannel.javascript)
        outputManager.append("▶ Running: \(fileName)", to: OutputChannel.javascript)
        outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
        
        // Create a fresh JSRunner instance
        jsRunner = JSRunner()
        
        // Set up console handler to capture output
        jsRunner?.setConsoleHandler { [weak self] message in
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
        
        // Execute the code asynchronously
        Task {
            let startTime = Date()
            
            do {
                let result = try await jsRunner?.execute(code: code)
                let duration = Date().timeIntervalSince(startTime)
                
                // Show result if it's not undefined
                if let result = result, !result.isUndefined {
                    let resultString = formatJSValue(result) ?? "\(result)"
                    outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
                    outputManager.append("⮐ Result: \(resultString)", to: OutputChannel.javascript)
                }
                
                // Show completion message
                outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
                outputManager.append("✓ Completed in \(String(format: "%.2f", duration * 1000))ms", to: OutputChannel.javascript)
                
            } catch let error as JSRunnerError {
                outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
                outputManager.append("✗ Error: \(error.localizedDescription)", to: OutputChannel.javascript, streamType: StreamType.stderr)
                
            } catch {
                outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
                outputManager.append("✗ Error: \(error.localizedDescription)", to: OutputChannel.javascript, streamType: StreamType.stderr)
            }
            
            // Clean up runner
            jsRunner = nil
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
            if let n = num, n.doubleValue == Double(n.intValue) {
                return "\(n.intValue)"
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
