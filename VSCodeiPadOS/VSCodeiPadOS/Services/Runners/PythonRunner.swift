import Foundation

/// Python-specific runner for executing Python code via SSH
struct PythonRunner: Runner {
    let name = "Python"
    let supportedExtensions = ["py", "pyw", "pyi"]
    let languageId = "python"
    
    private var ssh: SSHManager
    private var useVirtualEnv: Bool
    private var virtualEnvPath: String?
    private var pythonCommand: String
    
    /// Represents a parsed Python traceback entry
    struct TracebackEntry {
        let file: String
        let line: Int
        let function: String
        let code: String?
    }
    
    /// Represents a complete Python error with traceback
    struct PythonError {
        let errorType: String
        let message: String
        let traceback: [TracebackEntry]
        let fullTraceback: String
    }
    
    /// Python environment configuration
    struct PythonEnvironment {
        let pythonPath: String
        let version: String
        let hasVirtualEnv: Bool
        let virtualEnvPath: String?
        let pipPath: String
    }
    
    init(ssh: SSHManager, useVirtualEnv: Bool = false, virtualEnvPath: String? = nil) {
        self.ssh = ssh
        self.useVirtualEnv = useVirtualEnv
        self.virtualEnvPath = virtualEnvPath
        self.pythonCommand = "python3" // Default to python3
    }
    
    // MARK: - Runner Protocol Conformance
    
    func canRun(file: String) -> Bool {
        let ext = (file as NSString).pathExtension.lowercased()
        return supportedExtensions.contains(ext)
    }
    
    func buildCommand(for file: String, args: [String]) -> String {
        let pythonCmd = determinePythonCommand()
        let filePath = escapePath(file)
        
        var command = ""
        
        // Activate virtual environment if configured
        if useVirtualEnv, let venvPath = virtualEnvPath {
            command += "source \(escapePath(venvPath))/bin/activate && "
        }
        
        // Build the Python command
        command += "\(pythonCmd) \(filePath)"
        
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
        
        // Check if output contains a Python traceback
        if let pythonError = parseTraceback(output.stderr) {
            return ExecutionResult(
                stdout: output.stdout,
                stderr: pythonError.fullTraceback,
                exitCode: 1,
                error: RunnerError.executionFailed(pythonError.errorType + ": " + pythonError.message)
            )
        }
        
        return ExecutionResult(
            stdout: output.stdout,
            stderr: output.stderr,
            exitCode: output.exitCode,
            error: nil
        )
    }
    
    // MARK: - Python-Specific Methods
    
    /// Detects the Python version available on the remote system
    func detectPythonVersion(via ssh: SSHManager) async throws -> String {
        // Try python3 first (more common on modern systems)
        do {
            let output = try await ssh.execute(command: "python3 --version 2>&1")
            if output.exitCode == 0 {
                let version = output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                if !version.isEmpty {
                    self.pythonCommand = "python3"
                    return version
                }
            }
        } catch {
            // python3 not available, try python
        }
        
        // Fallback to python
        let output = try await ssh.execute(command: "python --version 2>&1")
        if output.exitCode == 0 {
            let version = output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            if !version.isEmpty {
                self.pythonCommand = "python"
                return version
            }
        }
        
        throw RunnerError.executionFailed("No Python installation found on remote system")
    }
    
    /// Installs requirements from a requirements.txt file
    func installRequirements(file: String, via ssh: SSHManager) async throws {
        let requirementsPath = escapePath(file)
        
        // Check if requirements.txt exists
        let checkOutput = try await ssh.execute(command: "test -f \(requirementsPath) && echo 'exists' || echo 'not found'")
        guard checkOutput.stdout.trimmingCharacters(in: .whitespacesAndNewlines) == "exists" else {
            throw RunnerError.executionFailed("Requirements file not found: \(file)")
        }
        
        var installCommand = ""
        
        // Activate virtual environment if configured
        if useVirtualEnv, let venvPath = virtualEnvPath {
            installCommand += "source \(escapePath(venvPath))/bin/activate && "
        }
        
        // Determine pip command
        let pipCmd = determinePipCommand()
        installCommand += "\(pipCmd) install -r \(requirementsPath)"
        
        let output = try await ssh.execute(command: installCommand)
        
        guard output.exitCode == 0 else {
            throw RunnerError.executionFailed("Failed to install requirements: \(output.stderr)")
        }
    }
    
    /// Creates a virtual environment at the specified path
    func createVirtualEnv(at path: String, via ssh: SSHManager) async throws {
        let pythonCmd = determinePythonCommand()
        let escapedPath = escapePath(path)
        
        let command = "\(pythonCmd) -m venv \(escapedPath)"
        let output = try await ssh.execute(command: command)
        
        guard output.exitCode == 0 else {
            throw RunnerError.executionFailed("Failed to create virtual environment: \(output.stderr)")
        }
        
        self.virtualEnvPath = path
        self.useVirtualEnv = true
    }
    
    /// Detects the full Python environment
    func detectPythonEnvironment(via ssh: SSHManager) async throws -> PythonEnvironment {
        let version = try await detectPythonVersion(via: ssh)
        let pythonPath = try await whichPython(via: ssh)
        
        var hasVirtualEnv = false
        var venvPath: String? = nil
        var pipPath = determinePipCommand()
        
        // Check if we're in a virtual environment
        let venvCheck = try await ssh.execute(command: "echo \$VIRTUAL_ENV")
        let detectedVenv = venvCheck.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        if !detectedVenv.isEmpty && detectedVenv != "$VIRTUAL_ENV" {
            hasVirtualEnv = true
            venvPath = detectedVenv
            pipPath = "\(detectedVenv)/bin/pip"
        }
        
        return PythonEnvironment(
            pythonPath: pythonPath,
            version: version,
            hasVirtualEnv: hasVirtualEnv,
            virtualEnvPath: venvPath,
            pipPath: pipPath
        )
    }
    
    /// Installs a specific package
    func installPackage(_ package: String, version: String? = nil, via ssh: SSHManager) async throws {
        var packageSpec = package
        if let ver = version {
            packageSpec += "==\(ver)"
        }
        
        var command = ""
        if useVirtualEnv, let venvPath = virtualEnvPath {
            command += "source \(escapePath(venvPath))/bin/activate && "
        }
        
        let pipCmd = determinePipCommand()
        command += "\(pipCmd) install \(escapeArgument(packageSpec))"
        
        let output = try await ssh.execute(command: command)
        
        guard output.exitCode == 0 else {
            throw RunnerError.executionFailed("Failed to install package \(package): \(output.stderr)")
        }
    }
    
    // MARK: - Traceback Parsing
    
    /// Parses Python traceback output into a structured error
    func parseTraceback(_ output: String) -> PythonError? {
        let lines = output.components(separatedBy: .newlines)
        var entries: [TracebackEntry] = []
        var errorType = ""
        var errorMessage = ""
        var parsingTraceback = false
        var currentFile: String?
        var currentLine: Int?
        var currentFunction: String?
        
        var i = 0
        while i < lines.count {
            let line = lines[i]
            
            // Check for traceback header
            if line.contains("Traceback (most recent call last):") {
                parsingTraceback = true
                i += 1
                continue
            }
            
            // Parse File "...", line X, in ...
            if parsingTraceback && line.starts(with: "  File \"") {
                let pattern = #"File \"([^\"]+)\", line (\d+), in (\w+)"#
                if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                   let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
                    
                    if let fileRange = Range(match.range(at: 1), in: line) {
                        currentFile = String(line[fileRange])
                    }
                    if let lineRange = Range(match.range(at: 2), in: line),
                       let lineNum = Int(line[lineRange]) {
                        currentLine = lineNum
                    }
                    if let funcRange = Range(match.range(at: 3), in: line) {
                        currentFunction = String(line[funcRange])
                    }
                }
                i += 1
                continue
            }
            
            // Parse code line (starts with "    ")
            if parsingTraceback && line.starts(with: "    ") && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                if let file = currentFile, let lineNum = currentLine, let function = currentFunction {
                    let code = line.trimmingCharacters(in: .whitespaces)
                    entries.append(TracebackEntry(
                        file: file,
                        line: lineNum,
                        function: function,
                        code: code
                    ))
                }
                currentFile = nil
                currentLine = nil
                currentFunction = nil
                i += 1
                continue
            }
            
            // Parse error type and message (last line before blank or end)
            if parsingTraceback && !line.hasPrefix("  ") && !line.isEmpty {
                let errorPattern = #"^(\w+Error|\w+Exception|KeyboardInterrupt|SystemExit|GeneratorExit):\s*(.*)$"#
                if let regex = try? NSRegularExpression(pattern: errorPattern, options: []),
                   let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
                    if let typeRange = Range(match.range(at: 1), in: line) {
                        errorType = String(line[typeRange])
                    }
                    if let msgRange = Range(match.range(at: 2), in: line) {
                        errorMessage = String(line[msgRange])
                    }
                } else if !line.isEmpty {
                    // Custom exception class
                    let components = line.split(separator: ":", maxSplits: 1)
                    errorType = String(components.first ?? "")
                    errorMessage = components.count > 1 ? String(components[1]).trimmingCharacters(in: .whitespaces) : ""
                }
                break
            }
            
            i += 1
        }
        
        // Only return error if we found an error type
        guard !errorType.isEmpty else {
            return nil
        }
        
        return PythonError(
            errorType: errorType,
            message: errorMessage,
            traceback: entries,
            fullTraceback: output
        )
    }
    
    /// Formats a traceback entry for display
    func formatTracebackEntry(_ entry: TracebackEntry) -> String {
        var result = "File \"\(entry.file)\", line \(entry.line), in \(entry.function)"
        if let code = entry.code {
            result += "\n    \(code)"
        }
        return result
    }
    
    // MARK: - Private Helpers
    
    private func determinePythonCommand() -> String {
        if useVirtualEnv, let venvPath = virtualEnvPath {
            return "\(venvPath)/bin/python"
        }
        return pythonCommand
    }
    
    private func determinePipCommand() -> String {
        if useVirtualEnv, let venvPath = virtualEnvPath {
            return "\(venvPath)/bin/pip"
        }
        return pythonCommand == "python3" ? "pip3" : "pip"
    }
    
    private func whichPython(via ssh: SSHManager) async throws -> String {
        let cmd = "which \(determinePythonCommand())"
        let output = try await ssh.execute(command: cmd)
        return output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func escapePath(_ path: String) -> String {
        return path.replacingOccurrences(of: " ", with: "\\ ")
                   .replacingOccurrences(of: "\"", with: "\\\"")
                   .replacingOccurrences(of: "'", with: "\\'\\''")
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

// MARK: - PythonRunner Extensions

extension PythonRunner {
    /// Common Python error types for syntax highlighting
    static let commonErrorTypes = [
        "SyntaxError",
        "IndentationError",
        "TabError",
        "NameError",
        "AttributeError",
        "TypeError",
        "ValueError",
        "IndexError",
        "KeyError",
        "ZeroDivisionError",
        "OverflowError",
        "FloatingPointError",
        "MemoryError",
        "RecursionError",
        "RuntimeError",
        "NotImplementedError",
        "StopIteration",
        "StopAsyncIteration",
        "OSError",
        "IOError",
        "FileNotFoundError",
        "PermissionError",
        "IsADirectoryError",
        "NotADirectoryError",
        "ConnectionError",
        "BrokenPipeError",
        "ConnectionAbortedError",
        "ConnectionRefusedError",
        "ConnectionResetError",
        "BlockingIOError",
        "ChildProcessError",
        "InterruptedError",
        "TimeoutError",
        "ImportError",
        "ModuleNotFoundError",
        "LookupError",
        "AssertionError",
        "EOFError",
        "SystemError",
        "ReferenceError",
        "BufferError",
        "Warning",
        "UserWarning",
        "DeprecationWarning",
        "PendingDeprecationWarning",
        "SyntaxWarning",
        "RuntimeWarning",
        "FutureWarning",
        "ImportWarning",
        "UnicodeWarning",
        "BytesWarning",
        "ResourceWarning"
    ]
}
