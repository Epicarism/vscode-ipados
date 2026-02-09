import Foundation

// MARK: - Base Runner Protocol

/// Base protocol for all language runners
protocol Runner {
    /// The language this runner handles
    static var language: String { get }
    
    /// Execute a command
    func execute(command: String, in directory: URL, environment: [String: String]?) async throws -> ProcessResult
    
    /// Check if the required tooling is available
    func checkAvailability() async -> RunnerAvailability
}

/// Result of running a process
struct ProcessResult {
    let exitCode: Int
    let stdout: String
    let stderr: String
    let duration: TimeInterval
    
    var isSuccess: Bool { exitCode == 0 }
}

/// Availability status of a runner
struct RunnerAvailability {
    let isAvailable: Bool
    let version: String?
    let missingTools: [String]
}

// MARK: - Node.js Error Types

enum NodeRunnerError: Error, LocalizedError {
    case nodeNotFound
    case packageManagerNotFound
    case packageJsonNotFound
    case invalidScript(String)
    case moduleNotFound(String)
    case syntaxError(line: Int, message: String)
    case typeError(message: String)
    case versionMismatch(required: String, found: String)
    case nvmNotConfigured
    
    var errorDescription: String? {
        switch self {
        case .nodeNotFound:
            return "Node.js is not installed or not in PATH"
        case .packageManagerNotFound:
            return "No package manager (npm, yarn, pnpm) found"
        case .packageJsonNotFound:
            return "No package.json found in project"
        case .invalidScript(let script):
            return "Invalid npm script: \(script)"
        case .moduleNotFound(let module):
            return "Module not found: \(module)"
        case .syntaxError(let line, let message):
            return "Syntax error at line \(line): \(message)"
        case .typeError(let message):
            return "Type error: \(message)"
        case .versionMismatch(let required, let found):
            return "Node version mismatch. Required: \(required), Found: \(found)"
        case .nvmNotConfigured:
            return "nvm/n is not configured properly"
        }
    }
}

// MARK: - Supporting Types

/// Package manager types
enum PackageManager: String, CaseIterable {
    case npm = "npm"
    case yarn = "yarn"
    case pnpm = "pnpm"
    
    var lockFile: String {
        switch self {
        case .npm: return "package-lock.json"
        case .yarn: return "yarn.lock"
        case .pnpm: return "pnpm-lock.yaml"
        }
    }
    
    var installCommand: String {
        switch self {
        case .npm: return "npm install"
        case .yarn: return "yarn install"
        case .pnpm: return "pnpm install"
        }
    }
    
    var runCommand: String {
        switch self {
        case .npm: return "npm run"
        case .yarn: return "yarn"
        case .pnpm: return "pnpm"
        }
    }
}

/// TypeScript execution mode
enum TypeScriptMode {
    case tsc          // Compile then run with node
    case tsNode       // Direct execution with ts-node
    case tsx          // Fast tsx runner
    
    var command: String {
        switch self {
        case .tsc: return "tsc"
        case .tsNode: return "ts-node"
        case .tsx: return "tsx"
        }
    }
}

/// Module system type
enum ModuleSystem {
    case esm          // ES Modules (ESM)
    case commonjs     // CommonJS (CJS)
    
    var flag: String? {
        switch self {
        case .esm: return "--experimental-modules"
        case .commonjs: return nil
        }
    }
}

/// Node debug configuration
struct NodeDebugConfig {
    let enabled: Bool
    let port: Int
    let breakOnStart: Bool
    
    static let `default` = NodeDebugConfig(enabled: false, port: 9229, breakOnStart: false)
    
    var flag: String? {
        guard enabled else { return nil }
        if breakOnStart {
            return "--inspect-brk=\(port)"
        } else {
            return "--inspect=\(port)"
        }
    }
}

/// Parsed error from Node.js output
struct NodeError {
    let type: String
    let message: String
    let file: String?
    let line: Int?
    let column: Int?
    let stackTrace: [String]
}

// MARK: - NodeRunner

/// Specialized runner for Node.js/JavaScript/TypeScript execution
final class NodeRunner: Runner {
    static let language = "javascript"
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private var detectedNodeVersion: String?
    private var detectedPackageManager: PackageManager?
    private var cachedPackageScripts: [String: String] = [:]
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Runner Protocol Methods
    
    /// Execute a command in the specified directory
    func execute(
        command: String,
        in directory: URL,
        environment: [String: String]? = nil
    ) async throws -> ProcessResult {
        let startTime = Date()
        
        // Prepare environment variables
        var env = environment ?? [:]
        env["NODE_ENV"] = env["NODE_ENV"] ?? "development"
        
        // Check Node availability
        let availability = await checkAvailability()
        guard availability.isAvailable else {
            throw NodeRunnerError.nodeNotFound
        }
        
        // Execute the command
        let result = try await runProcess(
            command: command,
            in: directory,
            environment: env
        )
        
        let duration = Date().timeIntervalSince(startTime)
        return ProcessResult(
            exitCode: result.exitCode,
            stdout: result.stdout,
            stderr: result.stderr,
            duration: duration
        )
    }
    
    /// Check if Node.js and required tools are available
    func checkAvailability() async -> RunnerAvailability {
        do {
            let result = try await runProcess(command: "node --version")
            let version = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            detectedNodeVersion = version
            
            let missingTools = await findMissingTools()
            
            return RunnerAvailability(
                isAvailable: !version.isEmpty,
                version: version,
                missingTools: missingTools
            )
        } catch {
            return RunnerAvailability(
                isAvailable: false,
                version: nil,
                missingTools: ["node"]
            )
        }
    }
    
    // MARK: - Feature 1: Auto-detect Node Version and Package Manager
    
    /// Auto-detect the Node.js version from the project
    func detectNodeVersion(in directory: URL) async throws -> String {
        // Check .nvmrc first
        let nvmrcPath = directory.appendingPathComponent(".nvmrc")
        if fileManager.fileExists(atPath: nvmrcPath.path),
           let version = try? String(contentsOf: nvmrcPath, encoding: .utf8) {
            return version.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Check package.json engines
        let packageJsonPath = directory.appendingPathComponent("package.json")
        if let data = try? Data(contentsOf: packageJsonPath),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let engines = json["engines"] as? [String: String],
           let nodeVersion = engines["node"] {
            return nodeVersion
        }
        
        // Fall back to current system version
        let result = try await runProcess(command: "node --version")
        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Auto-detect the package manager used in the project
    func detectPackageManager(in directory: URL) -> PackageManager {
        // Check for lock files (most reliable)
        for pm in PackageManager.allCases {
            let lockFilePath = directory.appendingPathComponent(pm.lockFile)
            if fileManager.fileExists(atPath: lockFilePath.path) {
                detectedPackageManager = pm
                return pm
            }
        }
        
        // Default to npm
        detectedPackageManager = .npm
        return .npm
    }
    
    // MARK: - Feature 2: TypeScript Compilation
    
    /// Detect TypeScript execution mode for a file
    func detectTypeScriptMode(for file: URL) -> TypeScriptMode {
        let path = file.path
        
        // Prefer tsx for speed if available
        if isToolAvailable("tsx") {
            return .tsx
        }
        
        // Check if ts-node is configured
        if isToolAvailable("ts-node") {
            return .tsNode
        }
        
        // Default to tsc compilation
        return .tsc
    }
    
    /// Execute TypeScript file with appropriate runner
    func runTypeScript(
        file: URL,
        mode: TypeScriptMode? = nil,
        args: [String] = [],
        in directory: URL,
        environment: [String: String]? = nil
    ) async throws -> ProcessResult {
        let tsMode = mode ?? detectTypeScriptMode(for: file)
        let moduleSystem = detectModuleSystem(for: file, in: directory)
        
        var command: String
        
        switch tsMode {
        case .tsc:
            // Compile and then run
            let compiledPath = file.deletingPathExtension().appendingPathExtension("js")
            let compileCmd = "tsc \(file.path) --outDir \(directory.path)"
            let compileResult = try await execute(
                command: compileCmd,
                in: directory,
                environment: environment
            )
            
            guard compileResult.isSuccess else {
                return compileResult
            }
            
            command = "node \(compiledPath.path)"
            
        case .tsNode:
            let moduleFlag = moduleSystem == .esm ? "--esm" : ""
            command = "ts-node \(moduleFlag) \(file.path)"
            
        case .tsx:
            let moduleFlag = moduleSystem == .esm ? "--import tsx" : ""
            command = "tsx \(moduleFlag) \(file.path)"
        }
        
        if !args.isEmpty {
            command += " " + args.joined(separator: " ")
        }
        
        return try await execute(command: command, in: directory, environment: environment)
    }
    
    // MARK: - Feature 3: ESM vs CommonJS Detection
    
    /// Detect module system (ESM vs CommonJS) for a file
    func detectModuleSystem(for file: URL, in directory: URL) -> ModuleSystem {
        // Check package.json type field
        let packageJsonPath = directory.appendingPathComponent("package.json")
        if let data = try? Data(contentsOf: packageJsonPath),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let type = json["type"] as? String,
           type == "module" {
            return .esm
        }
        
        // Check file extension
        if file.pathExtension == "mjs" {
            return .esm
        } else if file.pathExtension == "cjs" {
            return .commonjs
        }
        
        // Check for ESM syntax in the file
        if let content = try? String(contentsOf: file, encoding: .utf8) {
            let esmPatterns = [
                "^\\s*import\\s+.*\\s+from\\s+['\"]",
                "^\\s*export\\s+(default\\s+)?",
                "^\\s*export\\s*\\{"
            ]
            
            for pattern in esmPatterns {
                if content.range(of: pattern, options: .regularExpression) != nil {
                    return .esm
                }
            }
        }
        
        return .commonjs
    }
    
    /// Get the appropriate Node flags for the module system
    func getModuleFlags(for file: URL, in directory: URL) -> [String] {
        let system = detectModuleSystem(for: file, in: directory)
        var flags: [String] = []
        
        if let flag = system.flag {
            flags.append(flag)
        }
        
        return flags
    }
    
    // MARK: - Feature 4: Node Inspect/Debug Support
    
    /// Run with debug configuration
    func runWithDebug(
        file: URL,
        debugConfig: NodeDebugConfig = .default,
        in directory: URL,
        environment: [String: String]? = nil
    ) async throws -> ProcessResult {
        var flags: [String] = []
        
        if let debugFlag = debugConfig.flag {
            flags.append(debugFlag)
        }
        
        flags.append(file.path)
        
        let command = "node " + flags.joined(separator: " ")
        return try await execute(command: command, in: directory, environment: environment)
    }
    
    // MARK: - Feature 5: NODE_ENV Handling
    
    /// Set up environment with appropriate NODE_ENV
    func prepareEnvironment(
        mode: NodeEnvMode,
        additionalVars: [String: String]? = nil
    ) -> [String: String] {
        var env = additionalVars ?? [:]
        
        switch mode {
        case .development:
            env["NODE_ENV"] = "development"
        case .production:
            env["NODE_ENV"] = "production"
        case .test:
            env["NODE_ENV"] = "test"
        case .custom(let value):
            env["NODE_ENV"] = value
        }
        
        return env
    }
    
    enum NodeEnvMode {
        case development
        case production
        case test
        case custom(String)
    }
    
    // MARK: - Feature 6: npm Script Execution
    
    /// Execute an npm script from package.json
    func runNpmScript(
        script: String,
        in directory: URL,
        additionalArgs: [String] = [],
        environment: [String: String]? = nil
    ) async throws -> ProcessResult {
        let pm = detectPackageManager(in: directory)
        
        var command = "\(pm.runCommand) \(script)"
        if !additionalArgs.isEmpty {
            command += " -- " + additionalArgs.joined(separator: " ")
        }
        
        return try await execute(command: command, in: directory, environment: environment)
    }
    
    /// Get all available npm scripts
    func getNpmScripts(from directory: URL) async -> [String: String] {
        let packageJsonPath = directory.appendingPathComponent("package.json")
        
        guard let data = try? Data(contentsOf: packageJsonPath),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let scripts = json["scripts"] as? [String: String] else {
            return [:]
        }
        
        cachedPackageScripts = scripts
        return scripts
    }
    
    // MARK: - Feature 7: nvm/n Switch Support
    
    /// Switch Node version using nvm or n
    func switchNodeVersion(
        to version: String,
        using manager: NodeVersionManager = .auto
    ) async throws -> ProcessResult {
        let tool = try await detectVersionManager()
        
        switch tool {
        case .nvm:
            return try await execute(command: "nvm use \(version)")
        case .n:
            return try await execute(command: "n \(version)")
        case .fnm:
            return try await execute(command: "fnm use \(version)")
        case .none:
            throw NodeRunnerError.nvmNotConfigured
        }
    }
    
    /// Install a specific Node version
    func installNodeVersion(
        _ version: String,
        using manager: NodeVersionManager = .auto
    ) async throws -> ProcessResult {
        let tool = try await detectVersionManager()
        
        switch tool {
        case .nvm:
            return try await execute(command: "nvm install \(version)")
        case .n:
            return try await execute(command: "n install \(version)")
        case .fnm:
            return try await execute(command: "fnm install \(version)")
        case .none:
            throw NodeRunnerError.nvmNotConfigured
        }
    }
    
    enum NodeVersionManager {
        case nvm
        case n
        case fnm
        case none
        case auto
    }
    
    /// Detect which version manager is available
    private func detectVersionManager() async throws -> NodeVersionManager {
        if isCommandAvailable("nvm") {
            return .nvm
        } else if isCommandAvailable("n") {
            return .n
        } else if isCommandAvailable("fnm") {
            return .fnm
        }
        return .none
    }
    
    // MARK: - Feature 8: Package.json Script Autocomplete
    
    /// Get script suggestions for autocomplete
    func getScriptSuggestions(
        prefix: String,
        in directory: URL
    ) async -> [(name: String, command: String, description: String?)] {
        let scripts = await getNpmScripts(from: directory)
        
        return scripts
            .filter { $0.key.hasPrefix(prefix) }
            .map { (name: $0.key, command: $0.value, description: extractDescription(from: $0.value)) }
            .sorted { $0.name < $1.name }
    }
    
    /// Get all available scripts
    func getAllScriptSuggestions(
        in directory: URL
    ) async -> [(name: String, command: String, description: String?)] {
        let scripts = await getNpmScripts(from: directory)
        
        return scripts
            .map { (name: $0.key, command: $0.value, description: extractDescription(from: $0.value)) }
            .sorted { $0.name < $1.name }
    }
    
    private func extractDescription(from command: String) -> String? {
        // Try to infer description from common patterns
        if command.contains("build") || command.contains("compile") {
            return "Build the project"
        } else if command.contains("test") {
            return "Run tests"
        } else if command.contains("start") || command.contains("serve") {
            return "Start the application"
        } else if command.contains("dev") || command.contains("watch") {
            return "Start development mode"
        } else if command.contains("lint") {
            return "Run linter"
        } else if command.contains("format") {
            return "Format code"
        }
        return nil
    }
    
    // MARK: - Feature 9: Node-specific Error Parsing
    
    /// Parse Node.js error output
    func parseNodeError(_ stderr: String) -> NodeError? {
        // Parse syntax errors
        if let match = stderr.range(of: "SyntaxError.*:(.+)\\n\\s+at.+(\\d+):(\\d+)", options: .regularExpression) {
            let components = String(stderr[match]).split(separator: ":")
            if components.count >= 2 {
                let message = String(components[1]).trimmingCharacters(in: .whitespaces)
                let line = Int(components[2]) ?? 0
                let column = Int(components[3]) ?? 0
                
                return NodeError(
                    type: "SyntaxError",
                    message: message,
                    file: nil,
                    line: line,
                    column: column,
                    stackTrace: extractStackTrace(from: stderr)
                )
            }
        }
        
        // Parse module not found errors
        if let match = stderr.range(of: "Error: Cannot find module '(.+)'", options: .regularExpression) {
            let module = String(stderr[match])
                .replacingOccurrences(of: "Error: Cannot find module '", with: "")
                .replacingOccurrences(of: "'", with: "")
            
            return NodeError(
                type: "ModuleNotFoundError",
                message: "Cannot find module '\(module)'",
                file: nil,
                line: nil,
                column: nil,
                stackTrace: extractStackTrace(from: stderr)
            )
        }
        
        // Parse type errors (TypeScript)
        if stderr.contains("error TS") {
            let lines = stderr.components(separatedBy: .newlines)
            for line in lines {
                if let match = line.range(of: "error TS\\d+:", options: .regularExpression) {
                    let message = String(line[match.upperBound...]).trimmingCharacters(in: .whitespaces)
                    let fileLine = line.components(separatedBy: "(")
                    let file = fileLine.first?.trimmingCharacters(in: .whitespaces)
                    
                    return NodeError(
                        type: "TypeError",
                        message: message,
                        file: file,
                        line: nil,
                        column: nil,
                        stackTrace: []
                    )
                }
            }
        }
        
        // Generic error parsing
        if let match = stderr.range(of: "Error: (.+)", options: .regularExpression) {
            let message = String(stderr[match])
                .replacingOccurrences(of: "Error: ", with: "")
            
            return NodeError(
                type: "Error",
                message: message,
                file: nil,
                line: nil,
                column: nil,
                stackTrace: extractStackTrace(from: stderr)
            )
        }
        
        return nil
    }
    
    private func extractStackTrace(from output: String) -> [String] {
        let lines = output.components(separatedBy: .newlines)
        var stackTrace: [String] = []
        var capturing = false
        
        for line in lines {
            if line.contains("at ") {
                capturing = true
                stackTrace.append(line.trimmingCharacters(in: .whitespaces))
            } else if capturing && !line.isEmpty {
                break
            }
        }
        
        return stackTrace
    }
    
    /// Format error for display in IDE
    func formatErrorForDisplay(_ error: NodeError) -> String {
        var output = "[\(error.type)] \(error.message)"
        
        if let file = error.file {
            output += "\n  File: \(file)"
        }
        
        if let line = error.line {
            output += ":\(line)"
            if let column = error.column {
                output += ":\(column)"
            }
        }
        
        if !error.stackTrace.isEmpty {
            output += "\n\nStack trace:\n"
            output += error.stackTrace.prefix(5).joined(separator: "\n")
        }
        
        return output
    }
    
    // MARK: - Helper Methods
    
    /// Run a shell process
    private func runProcess(
        command: String,
        in directory: URL? = nil,
        environment: [String: String]? = nil
    ) async throws -> (exitCode: Int, stdout: String, stderr: String) {
        let process = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        if let directory = directory {
            process.currentDirectoryURL = directory
        }
        
        if let environment = environment {
            var env = ProcessInfo.processInfo.environment
            env.merge(environment) { (_, new) in new }
            process.environment = env
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { process in
                let stdoutData = pipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
                let stderr = String(data: stderrData, encoding: .utf8) ?? ""
                
                continuation.resume(returning: (
                    exitCode: Int(process.terminationStatus),
                    stdout: stdout,
                    stderr: stderr
                ))
            }
            
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Check if a command is available in PATH
    private func isCommandAvailable(_ command: String) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        task.arguments = [command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice
        
        try? task.run()
        task.waitUntilExit()
        
        return task.terminationStatus == 0
    }
    
    /// Check if a Node tool is available
    private func isToolAvailable(_ tool: String) -> Bool {
        return isCommandAvailable(tool) || isCommandAvailable("npx \(tool)")
    }
    
    /// Find missing tools for full functionality
    private func findMissingTools() async -> [String] {
        var missing: [String] = []
        
        let tools = ["npm", "tsc", "ts-node", "tsx"]
        for tool in tools {
            if !isToolAvailable(tool) {
                missing.append(tool)
            }
        }
        
        return missing
    }
    
    /// Get project info for debugging
    func getProjectInfo(in directory: URL) async -> NodeProjectInfo {
        let nodeVersion = (try? await detectNodeVersion(in: directory)) ?? detectedNodeVersion ?? "unknown"
        let packageManager = detectedPackageManager ?? detectPackageManager(in: directory)
        let scripts = await getNpmScripts(from: directory)
        let moduleSystem = detectModuleSystem(for: directory.appendingPathComponent("index.js"), in: directory)
        
        return NodeProjectInfo(
            nodeVersion: nodeVersion,
            packageManager: packageManager,
            availableScripts: Array(scripts.keys),
            moduleSystem: moduleSystem,
            hasTypeScript: fileManager.fileExists(atPath: directory.appendingPathComponent("tsconfig.json").path)
        )
    }
}

// MARK: - Supporting Types

struct NodeProjectInfo {
    let nodeVersion: String
    let packageManager: PackageManager
    let availableScripts: [String]
    let moduleSystem: ModuleSystem
    let hasTypeScript: Bool
}

// MARK: - Convenience Extensions

extension NodeRunner {
    /// Quick run JavaScript file
    func runJavaScript(
        file: URL,
        in directory: URL,
        environment: [String: String]? = nil
    ) async throws -> ProcessResult {
        let moduleFlags = getModuleFlags(for: file, in: directory)
        let flagString = moduleFlags.isEmpty ? "" : moduleFlags.joined(separator: " ") + " "
        
        let command = "node \(flagString)\(file.path)"
        return try await execute(command: command, in: directory, environment: environment)
    }
    
    /// Install dependencies
    func installDependencies(
        in directory: URL,
        packageManager: PackageManager? = nil
    ) async throws -> ProcessResult {
        let pm = packageManager ?? detectPackageManager(in: directory)
        return try await execute(command: pm.installCommand, in: directory)
    }
    
    /// Check if a script exists
    func hasScript(_ name: String, in directory: URL) async -> Bool {
        let scripts = await getNpmScripts(from: directory)
        return scripts[name] != nil
    }
}
