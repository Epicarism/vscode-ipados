import Foundation

// MARK: - Swift Error Types

enum SwiftRunnerError: Error, LocalizedError {
    case swiftNotFound
    case packageNotFound
    case buildFailed(String)
    case compilationError(String)
    case syntaxError(line: Int, message: String)
    case typeError(message: String)
    case versionMismatch(required: String, found: String)
    
    var errorDescription: String? {
        switch self {
        case .swiftNotFound:
            return "Swift compiler is not installed or not in PATH"
        case .packageNotFound:
            return "No Package.swift found in project"
        case .buildFailed(let reason):
            return "Build failed: \(reason)"
        case .compilationError(let reason):
            return "Compilation error: \(reason)"
        case .syntaxError(let line, let message):
            return "Syntax error at line \(line): \(message)"
        case .typeError(let message):
            return "Type error: \(message)"
        case .versionMismatch(let required, let found):
            return "Swift version mismatch. Required: \(required), Found: \(found)"
        }
    }
}

// MARK: - Supporting Types

/// Swift execution mode
enum SwiftExecutionMode {
    case swiftRun           // swift run for SPM projects
    case direct             // swift <file>.swift for single files
    case swiftc             // swiftc compilation then execution
    
    var description: String {
        switch self {
        case .swiftRun: return "swift run (SPM)"
        case .direct: return "swift <file>"
        case .swiftc: return "swiftc compile & run"
        }
    }
}

/// SPM Package structure
struct SwiftPackage {
    let name: String
    let path: String
    let targets: [String]
    let hasExecutable: Bool
}

/// Parsed error from Swift compiler output
struct SwiftError {
    let type: String
    let message: String
    let file: String?
    let line: Int?
    let column: Int?
    let suggestion: String?
    let notes: [String]
}

/// Swift build configuration
struct SwiftBuildConfig {
    let optimization: OptimizationLevel
    let target: String?
    let additionalFlags: [String]
    
    enum OptimizationLevel: String {
        case none = "-Onone"
        case size = "-Osize"
        case speed = "-O"
        case unchecked = "-Ounchecked"
    }
    
    static let `default` = SwiftBuildConfig(
        optimization: .none,
        target: nil,
        additionalFlags: []
    )
}

// MARK: - SwiftRunner

/// Specialized runner for Swift code execution via SSH
struct SwiftRunner {
    let name = "Swift"
    let supportedExtensions = ["swift"]
    let languageId = "swift"
    
    private var ssh: SSHManager
    private var executionMode: SwiftExecutionMode
    private var buildConfig: SwiftBuildConfig
    private var detectedSwiftVersion: String?
    
    /// Represents a parsed Swift compiler error/warning
    struct CompilerDiagnostic {
        let severity: Severity
        let message: String
        let file: String
        let line: Int
        let column: Int
        let category: String?
        
        enum Severity: String {
            case error = "error"
            case warning = "warning"
            case note = "note"
        }
    }
    
    /// Represents a parsed Swift error with context
    struct SwiftCompilerError {
        let errorType: String
        let message: String
        let file: String
        let line: Int
        let column: Int
        let context: String?
        let suggestions: [String]
        let fullOutput: String
    }
    
    init(
        ssh: SSHManager,
        executionMode: SwiftExecutionMode = .direct,
        buildConfig: SwiftBuildConfig = .default
    ) {
        self.ssh = ssh
        self.executionMode = executionMode
        self.buildConfig = buildConfig
    }
    
    // MARK: - Runner Protocol Conformance
    
    func canRun(file: String) -> Bool {
        let ext = (file as NSString).pathExtension.lowercased()
        return supportedExtensions.contains(ext)
    }
    
    /// Build command for executing Swift code
    func buildCommand(for file: String, args: [String]) -> String {
        let filePath = escapePath(file)
        var command = ""
        
        // Determine execution mode based on file/project structure
        let mode = determineExecutionMode(for: file)
        
        switch mode {
        case .swiftRun:
            // SPM project - use swift run
            command = "swift run"
            if let target = buildConfig.target {
                command += " \(target)"
            }
            // Add additional flags
            if !buildConfig.additionalFlags.isEmpty {
                command += " \(buildConfig.additionalFlags.joined(separator: " "))"
            }
            
        case .direct:
            // Single file - use swift directly
            command = "swift \(filePath)"
            
        case .swiftc:
            // Compile then execute
            let binaryName = "swift_binary_\(UUID().uuidString.prefix(8))"
            let tempBinary = "/tmp/\(binaryName)"
            
            // Build compilation command
            var compileFlags = [buildConfig.optimization.rawValue]
            if !buildConfig.additionalFlags.isEmpty {
                compileFlags.append(contentsOf: buildConfig.additionalFlags)
            }
            
            command = "swiftc \(compileFlags.joined(separator: " ")) \(filePath) -o \(tempBinary) && \(tempBinary)"
        }
        
        // Add arguments
        if !args.isEmpty {
            let escapedArgs = args.map { escapeArgument($0) }.joined(separator: " ")
            command += " \(escapedArgs)"
        }
        
        return command
    }
    
    func execute(file: String, args: [String]) async throws -> ExecutionResult {
        let command = buildCommand(for: file, args: args)
        let output = try await ssh.execute(command: command)
        
        // Check for Swift compiler errors in stderr
        if let swiftError = parseCompilerErrors(output.stderr) {
            return ExecutionResult(
                stdout: output.stdout,
                stderr: output.stderr,
                exitCode: 1,
                error: RunnerError.executionFailed("\(swiftError.errorType): \(swiftError.message)")
            )
        }
        
        return ExecutionResult(
            stdout: output.stdout,
            stderr: output.stderr,
            exitCode: output.exitCode,
            error: nil
        )
    }
    
    // MARK: - Swift-Specific Methods
    
    /// Detects the Swift version available on the remote system
    func detectSwiftVersion(via ssh: SSHManager) async throws -> String {
        do {
            let output = try await ssh.execute(command: "swift --version 2>&1")
            if output.exitCode == 0 {
                // Parse Swift version output (e.g., "Swift version 5.9.2 (swift-5.9.2-RELEASE)")
                let versionOutput = output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                if let version = parseSwiftVersionOutput(versionOutput) {
                    self.detectedSwiftVersion = version
                    return version
                }
            }
        } catch {
            // Try swiftc as fallback
        }
        
        // Try swiftc
        let output = try await ssh.execute(command: "swiftc --version 2>&1")
        if output.exitCode == 0 {
            let versionOutput = output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            if let version = parseSwiftVersionOutput(versionOutput) {
                self.detectedSwiftVersion = version
                return version
            }
        }
        
        throw RunnerError.executionFailed("No Swift installation found on remote system")
    }
    
    /// Run an SPM package using swift run
    func runPackage(
        in directory: String,
        target: String? = nil,
        args: [String] = []
    ) async throws -> ExecutionResult {
        let dirPath = escapePath(directory)
        
        // Check for Package.swift
        let checkOutput = try await ssh.execute(command: "test -f \(dirPath)/Package.swift && echo 'exists' || echo 'not found'")
        guard checkOutput.stdout.trimmingCharacters(in: .whitespacesAndNewlines) == "exists" else {
            throw SwiftRunnerError.packageNotFound
        }
        
        var command = "cd \(dirPath) && swift run"
        if let target = target {
            command += " \(target)"
        }
        if !buildConfig.additionalFlags.isEmpty {
            command += " \(buildConfig.additionalFlags.joined(separator: " "))"
        }
        if !args.isEmpty {
            command += " \(args.map { escapeArgument($0) }.joined(separator: " "))"
        }
        
        let output = try await ssh.execute(command: command)
        
        // Check for build errors
        if let swiftError = parseCompilerErrors(output.stderr) {
            return ExecutionResult(
                stdout: output.stdout,
                stderr: output.stderr,
                exitCode: 1,
                error: RunnerError.executionFailed("Build failed: \(swiftError.message)")
            )
        }
        
        return ExecutionResult(
            stdout: output.stdout,
            stderr: output.stderr,
            exitCode: output.exitCode,
            error: nil
        )
    }
    
    /// Build SPM package
    func buildPackage(in directory: String, config: SwiftBuildConfig? = nil) async throws -> ExecutionResult {
        let dirPath = escapePath(directory)
        let buildConfig = config ?? self.buildConfig
        
        var command = "cd \(dirPath) && swift build"
        command += " \(buildConfig.optimization.rawValue)"
        if !buildConfig.additionalFlags.isEmpty {
            command += " \(buildConfig.additionalFlags.joined(separator: " "))"
        }
        
        let output = try await ssh.execute(command: command)
        
        return ExecutionResult(
            stdout: output.stdout,
            stderr: output.stderr,
            exitCode: output.exitCode,
            error: output.exitCode != 0 ? RunnerError.executionFailed("Build failed") : nil
        )
    }
    
    /// Test SPM package
    func testPackage(in directory: String) async throws -> ExecutionResult {
        let dirPath = escapePath(directory)
        let command = "cd \(dirPath) && swift test"
        
        let output = try await ssh.execute(command: command)
        return ExecutionResult(
            stdout: output.stdout,
            stderr: output.stderr,
            exitCode: output.exitCode,
            error: output.exitCode != 0 ? RunnerError.executionFailed("Tests failed") : nil
        )
    }
    
    /// Compile single file with swiftc and execute
    func compileAndRun(file: String, args: [String] = []) async throws -> ExecutionResult {
        let filePath = escapePath(file)
        let binaryName = "swift_\(UUID().uuidString.prefix(8))"
        let tempBinary = "/tmp/\(binaryName)"
        
        // Build compile command
        var compileFlags = [buildConfig.optimization.rawValue]
        if !buildConfig.additionalFlags.isEmpty {
            compileFlags.append(contentsOf: buildConfig.additionalFlags)
        }
        
        let compileCommand = "swiftc \(compileFlags.joined(separator: " ")) \(filePath) -o \(tempBinary)"
        let compileOutput = try await ssh.execute(command: compileCommand)
        
        if compileOutput.exitCode != 0 {
            if let error = parseCompilerErrors(compileOutput.stderr) {
                return ExecutionResult(
                    stdout: compileOutput.stdout,
                    stderr: compileOutput.stderr,
                    exitCode: 1,
                    error: RunnerError.executionFailed("Compilation error: \(error.message)")
                )
            }
            return ExecutionResult(
                stdout: compileOutput.stdout,
                stderr: compileOutput.stderr,
                exitCode: 1,
                error: RunnerError.executionFailed("Compilation failed")
            )
        }
        
        // Run the compiled binary
        var runCommand = tempBinary
        if !args.isEmpty {
            runCommand += " \(args.map { escapeArgument($0) }.joined(separator: " "))"
        }
        
        let runOutput = try await ssh.execute(command: runCommand)
        
        // Clean up
        _ = try? await ssh.execute(command: "rm \(tempBinary)")
        
        return ExecutionResult(
            stdout: runOutput.stdout,
            stderr: runOutput.stderr,
            exitCode: runOutput.exitCode,
            error: nil
        )
    }
    
    // MARK: - Swift Compiler Error Parsing
    
    /// Parses Swift compiler errors/warnings from output
    func parseCompilerErrors(_ output: String) -> SwiftCompilerError? {
        let lines = output.components(separatedBy: .newlines)
        var errors: [CompilerDiagnostic] = []
        var notes: [String] = []
        var contextLines: [String] = []
        
        // Swift error format: "file.swift:10:5: error: message"
        // Or: "file.swift:10:5: warning: message"
        let errorPattern = #"^(.*):(\d+):(\d+):\s*(error|warning|note):\s*(.*)$"#
        
        for line in lines {
            // Try to match standard Swift error format
            if let regex = try? NSRegularExpression(pattern: errorPattern, options: []),
               let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
                
                let fileRange = Range(match.range(at: 1), in: line)
                let lineRange = Range(match.range(at: 2), in: line)
                let colRange = Range(match.range(at: 3), in: line)
                let severityRange = Range(match.range(at: 4), in: line)
                let messageRange = Range(match.range(at: 5), in: line)
                
                let file = fileRange.map { String(line[$0]) } ?? ""
                let lineNum = lineRange.flatMap { Int(line[$0]) } ?? 0
                let colNum = colRange.flatMap { Int(line[$0]) } ?? 0
                let severity = severityRange.map { String(line[$0]) } ?? "error"
                let message = messageRange.map { String(line[$0]) } ?? ""
                
                if severity == "error" {
                    errors.append(CompilerDiagnostic(
                        severity: .error,
                        message: message,
                        file: file,
                        line: lineNum,
                        column: colNum,
                        category: nil
                    ))
                }
            } else if line.contains("error:") || line.contains("Error:") {
                // Try to parse non-standard error format
                if let errorInfo = parseGenericError(line) {
                    errors.append(errorInfo)
                }
            } else if !line.isEmpty && !line.contains(":") {
                // Could be context/suggestion line
                contextLines.append(line)
            }
        }
        
        // Return the first error as the main error
        guard let firstError = errors.first else {
            return nil
        }
        
        // Extract suggestions from context lines
        let suggestions = contextLines.filter { line in
            line.contains("did you mean") ||
            line.contains("replace with") ||
            line.contains("insert") ||
            line.contains("remove")
        }
        
        return SwiftCompilerError(
            errorType: "SwiftCompilerError",
            message: firstError.message,
            file: firstError.file,
            line: firstError.line,
            column: firstError.column,
            context: contextLines.first,
            suggestions: suggestions,
            fullOutput: output
        )
    }
    
    /// Format Swift error for display in IDE
    func formatErrorForDisplay(_ error: SwiftCompilerError) -> String {
        var output = "[\(error.errorType)] \(error.message)"
        
        output += "\n  File: \(error.file)"
        output += ":\(error.line)"
        if error.column > 0 {
            output += ":\(error.column)"
        }
        
        if let context = error.context {
            output += "\n\n  \(context)"
        }
        
        if !error.suggestions.isEmpty {
            output += "\n\nSuggestions:\n"
            for suggestion in error.suggestions.prefix(3) {
                output += "  • \(suggestion)\n"
            }
        }
        
        return output
    }
    
    /// Extract all diagnostics (errors and warnings) from output
    func extractDiagnostics(_ output: String) -> [CompilerDiagnostic] {
        var diagnostics: [CompilerDiagnostic] = []
        let lines = output.components(separatedBy: .newlines)
        
        let pattern = #"^(.*):(\d+):(\d+):\s*(error|warning|note):\s*(.*)$"#
        
        for line in lines {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
                
                let fileRange = Range(match.range(at: 1), in: line)
                let lineRange = Range(match.range(at: 2), in: line)
                let colRange = Range(match.range(at: 3), in: line)
                let severityRange = Range(match.range(at: 4), in: line)
                let messageRange = Range(match.range(at: 5), in: line)
                
                let file = fileRange.map { String(line[$0]) } ?? ""
                let lineNum = lineRange.flatMap { Int(line[$0]) } ?? 0
                let colNum = colRange.flatMap { Int(line[$0]) } ?? 0
                let severityStr = severityRange.map { String(line[$0]) } ?? "error"
                let message = messageRange.map { String(line[$0]) } ?? ""
                
                let severity: CompilerDiagnostic.Severity
                switch severityStr.lowercased() {
                case "error": severity = .error
                case "warning": severity = .warning
                case "note": severity = .note
                default: severity = .error
                }
                
                diagnostics.append(CompilerDiagnostic(
                    severity: severity,
                    message: message,
                    file: file,
                    line: lineNum,
                    column: colNum,
                    category: nil
                ))
            }
        }
        
        return diagnostics
    }
    
    // MARK: - Private Helpers
    
    private func determineExecutionMode(for file: String) -> SwiftExecutionMode {
        // Check if file is in a directory with Package.swift
        let dir = (file as NSString).deletingLastPathComponent
        let checkCommand = "test -f \(escapePath(dir))/Package.swift && echo 'spm' || echo 'single'"
        
        // In real implementation, this would be async - for now return configured mode
        // or default to direct execution for single files
        if executionMode == .swiftRun {
            // Verify Package.swift exists
            // This would need to be done async in practice
            return .swiftRun
        }
        
        return executionMode
    }
    
    private func parseSwiftVersionOutput(_ output: String) -> String? {
        // Parse "Swift version 5.9.2" or similar
        let pattern = #"Swift\s+version\s+(\d+\.\d+(?:\.\d+)?)"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: output, options: [], range: NSRange(location: 0, length: output.utf16.count)),
           let range = Range(match.range(at: 1), in: output) {
            return String(output[range])
        }
        return nil
    }
    
    private func parseGenericError(_ line: String) -> CompilerDiagnostic? {
        // Try to extract error info from lines like "error: message" or "Error: message"
        if let colonIndex = line.firstIndex(of: ":") {
            let message = String(line[colonIndex...].dropFirst()).trimmingCharacters(in: .whitespaces)
            return CompilerDiagnostic(
                severity: .error,
                message: message,
                file: "",
                line: 0,
                column: 0,
                category: nil
            )
        }
        return nil
    }
    
    private func escapePath(_ path: String) -> String {
        return path.replacingOccurrences(of: " ", with: "\\ ")
                   .replacingOccurrences(of: "\"", with: "\\\"")
                   .replacingOccurrences(of: "'", with: "'\"'\"'")
                   .replacingOccurrences(of: "$", with: "\\$")
                   .replacingOccurrences(of: "`", with: "\\`")
    }
    
    private func escapeArgument(_ arg: String) -> String {
        if arg.contains(" ") || arg.contains("\"") || arg.contains("'") {
            return "\"\(arg.replacingOccurrences(of: "\"", with: "\\\""))\""
        }
        return arg
    }
}

// MARK: - Supporting Types (if not defined elsewhere)

struct ExecutionResult {
    let stdout: String
    let stderr: String
    let exitCode: Int
    let error: RunnerError?
    
    var isSuccess: Bool { exitCode == 0 && error == nil }
}

enum RunnerError: Error, LocalizedError {
    case executionFailed(String)
    case notSupported(String)
    
    var errorDescription: String? {
        switch self {
        case .executionFailed(let reason):
            return "Execution failed: \(reason)"
        case .notSupported(let reason):
            return "Not supported: \(reason)"
        }
    }
}

// MARK: - SwiftRunner Extensions

extension SwiftRunner {
    /// Common Swift error categories for syntax highlighting
    static let commonErrorTypes = [
        "error",
        "warning",
        "note",
        "fatal error",
        "runtime error",
        "linker error"
    ]
    
    /// Swift keywords that might indicate issues
    static let swiftKeywords = [
        "func", "var", "let", "class", "struct", "enum",
        "protocol", "extension", "import", "typealias",
        "associatedtype", "init", "deinit", "subscript",
        "operator", "precedencegroup", "infix", "prefix", "postfix"
    ]
}

// MARK: - SwiftRunner + SSHManager Extension

extension SSHManager {
    /// Convenience method for SwiftRunner compatibility
    func execute(command: String) async throws -> (stdout: String, stderr: String, exitCode: Int) {
        return try await withCheckedThrowingContinuation { continuation in
            self.executeCommand(command: command) { result in
                switch result {
                case .success(let output):
                    continuation.resume(returning: (
                        stdout: output.stdout,
                        stderr: output.stderr,
                        exitCode: output.exitCode
                    ))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Runner Protocol Definition

/// Protocol that all language runners must conform to
protocol Runner {
    var name: String { get }
    var supportedExtensions: [String] { get }
    var languageId: String { get }
    
    func canRun(file: String) -> Bool
    func buildCommand(for file: String, args: [String]) -> String
    func execute(file: String, args: [String]) async throws -> ExecutionResult
}

// MARK: - SwiftRunner Conformance

extension SwiftRunner: Runner {
    // Already implemented above
}

// MARK: - Package.swift Parsing

extension SwiftRunner {
    /// Parse Package.swift to extract package information
    func parsePackageManifest(at path: String, via ssh: SSHManager) async throws -> SwiftPackage {
        let manifestPath = "\(path)/Package.swift"
        
        // Read Package.swift content
        let output = try await ssh.execute(command: "cat \(escapePath(manifestPath))")
        let content = output.stdout
        
        // Extract package name
        let namePattern = #"name:\s*\"([^\"]+)\""#
        var packageName = "Unknown"
        if let regex = try? NSRegularExpression(pattern: namePattern, options: []),
           let match = regex.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count)),
           let range = Range(match.range(at: 1), in: content) {
            packageName = String(content[range])
        }
        
        // Extract target names (simplified)
        let targetPattern = #"\.target\(name:\s*\"([^\"]+)\""#
        var targets: [String] = []
        if let regex = try? NSRegularExpression(pattern: targetPattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
            for match in matches {
                if let range = Range(match.range(at: 1), in: content) {
                    targets.append(String(content[range]))
                }
            }
        }
        
        // Check for executable products
        let hasExecutable = content.contains(".executable(") ||
                           content.contains("products: [.executable")
        
        return SwiftPackage(
            name: packageName,
            path: path,
            targets: targets,
            hasExecutable: hasExecutable
        )
    }
}
