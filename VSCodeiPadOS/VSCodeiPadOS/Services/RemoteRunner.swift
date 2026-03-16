//
//  RemoteRunner.swift
//  VSCodeiPadOS
//
//  Remote code execution via SSH with streaming output support
//

import Foundation
import SwiftUI
import NIO
import NIOSSH
import NIOCore
import Combine

// MARK: - Process Model for Remote Execution

struct RemoteProcess: Identifiable, Equatable, Sendable {
    let id: UUID = UUID()
    let command: String
    let pid: Int?
    let startTime: Date
    var exitCode: Int?
    var endTime: Date?
    
    static func == (lhs: RemoteProcess, rhs: RemoteProcess) -> Bool {
        lhs.id == rhs.id
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    var isRunning: Bool {
        exitCode == nil
    }
}

// MARK: - Language Detection

enum RemoteSupportedLanguage: String, CaseIterable, Sendable {
    case swift = "swift"
    case python = "python"
    case python3 = "python3"
    case node = "node"
    case ruby = "ruby"
    case bash = "bash"
    case sh = "sh"
    case zsh = "zsh"
    case php = "php"
    case go = "go"
    case rust = "rust"
    case java = "java"
    case kotlin = "kotlin"
    case cpp = "c++"
    case c = "c"
    case csharp = "csharp"
    case perl = "perl"
    case lua = "lua"
    case r = "r"
    
    var interpreter: String {
        switch self {
        case .swift: return "swift"
        case .python, .python3: return "python3"
        case .node: return "node"
        case .ruby: return "ruby"
        case .bash, .sh: return "bash"
        case .zsh: return "zsh"
        case .php: return "php"
        case .go: return "go run"
        case .rust: return "rustc"
        case .java: return "java"
        case .kotlin: return "kotlin"
        case .cpp: return "g++ -o /tmp/out && /tmp/out"
        case .c: return "gcc -o /tmp/out && /tmp/out"
        case .csharp: return "dotnet run"
        case .perl: return "perl"
        case .lua: return "lua"
        case .r: return "Rscript"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .swift: return ".swift"
        case .python, .python3: return ".py"
        case .node: return ".js"
        case .ruby: return ".rb"
        case .bash, .sh: return ".sh"
        case .zsh: return ".zsh"
        case .php: return ".php"
        case .go: return ".go"
        case .rust: return ".rs"
        case .java: return ".java"
        case .kotlin: return ".kt"
        case .cpp: return ".cpp"
        case .c: return ".c"
        case .csharp: return ".cs"
        case .perl: return ".pl"
        case .lua: return ".lua"
        case .r: return ".r"
        }
    }
}

// MARK: - Remote Runner

@MainActor
final class RemoteRunner: ObservableObject, @unchecked Sendable {
    
    // MARK: - Published Properties
    
    @Published var output: String = ""
    @Published var isRunning: Bool = false
    @Published var currentProcess: RemoteProcess?
    @Published var processHistory: [RemoteProcess] = []
    @Published var lastExitCode: Int?
    
    // MARK: - Environment & Configuration
    
    var environmentVariables: [String: String] = [:]
    var workingDirectory: String?
    var defaultTimeout: TimeInterval = 300 // 5 minutes
    
    // MARK: - Private Properties
    
    private var activeContinuation: AsyncStream<SSHCommandOutput>.Continuation?
    private var activeChannel: Channel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Output Stream
    
    private var outputContinuation: AsyncStream<String>.Continuation?
    
    // MARK: - Initialization
    
    init() {
        setupDefaultEnvironment()
    }
    
    private func setupDefaultEnvironment() {
        environmentVariables = [
            "TERM": "xterm-256color",
            "LANG": "en_US.UTF-8",
            "PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        ]
    }
    
    // MARK: - Public Methods
    
    /// Run a file on the remote server
    func runFile(path: String, via sshManager: SSHManager) async throws {
        guard sshManager.isConnected else {
            throw SSHClientError.notConnected
        }
        
        let language = detectLanguage(from: path)
        let interpreter = RemoteSupportedLanguage(rawValue: language)?.interpreter ?? language
        
        // Build command based on language
        let command: String
        switch language {
        case "swift":
            command = "swift \(path)"
        case "python", "python3":
            command = "python3 \(path)"
        case "node":
            command = "node \(path)"
        case "go":
            command = "cd $(dirname \(path)) && go run $(basename \(path))"
        case "rust":
            let binaryName = (path as NSString).lastPathComponent.replacingOccurrences(of: ".rs", with: "")
            command = "rustc \(path) -o /tmp/\(binaryName) && /tmp/\(binaryName)"
        case "cpp":
            let binaryName = UUID().uuidString
            command = "g++ \(path) -o /tmp/\(binaryName) && /tmp/\(binaryName)"
        case "c":
            let binaryName = UUID().uuidString
            command = "gcc \(path) -o /tmp/\(binaryName) && /tmp/\(binaryName)"
        default:
            command = "\(interpreter) \(path)"
        }
        
        try await runCommand(command: command, via: sshManager)
    }
    
    /// Run a command on the remote server
    func runCommand(command: String, via sshManager: SSHManager) async throws {
        guard sshManager.isConnected else {
            throw SSHClientError.notConnected
        }
        
        // Reset state
        await resetState()
        
        // Create process record
        let process = RemoteProcess(
            command: command,
            pid: nil,
            startTime: Date(),
            exitCode: nil,
            endTime: nil
        )
        
        self.currentProcess = process
        self.isRunning = true
        
        // Build command with working directory and environment
        var finalCommand = command
        if let cwd = workingDirectory {
            finalCommand = "cd '\(cwd)' && \(command)"
        }
        
        // Prepend environment variables
        if !environmentVariables.isEmpty {
            let envPrefix = environmentVariables.map { "\($0.key)='\($0.value)'" }.joined(separator: " ")
            finalCommand = "\(envPrefix) \(finalCommand)"
        }
        
        // Execute via SSH with streaming output
        do {
            try await sshManager.executeCommand(finalCommand) { [weak self] outputEvent in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    
                    switch outputEvent {
                    case .stdout(let text):
                        self.output.append(text)
                        self.outputContinuation?.yield(text)
                        
                    case .stderr(let text):
                        self.output.append("[stderr] \(text)")
                        self.outputContinuation?.yield("[stderr] \(text)")
                        
                    case .exit(let code):
                        self.lastExitCode = code
                        if var proc = self.currentProcess {
                            proc.exitCode = code
                            proc.endTime = Date()
                            self.currentProcess = proc
                            self.processHistory.append(proc)
                        }
                        self.isRunning = false
                        
                    case .timeout:
                        self.output.append("\n[Command timed out after \(self.defaultTimeout) seconds]")
                        self.isRunning = false
                        self.lastExitCode = -1
                        
                    case .error(let error):
                        self.output.append("\n[Error: \(error.localizedDescription)]")
                        self.isRunning = false
                    }
                }
            }
            
            // Mark completed if not already
            if isRunning {
                isRunning = false
                if var proc = currentProcess, proc.exitCode == nil {
                    proc.exitCode = 0
                    proc.endTime = Date()
                    currentProcess = proc
                    processHistory.append(proc)
                }
            }
            
        } catch {
            self.isRunning = false
            self.output.append("\n[Error: \(error.localizedDescription)]")
            throw error
        }
    }
    
    /// Run a code selection on the remote server
    func runSelection(code: String, language: String, via sshManager: SSHManager) async throws {
        guard sshManager.isConnected else {
            throw SSHClientError.notConnected
        }
        
        // Create a temporary file with the code
        let tempFileName = "vscode_ipad_\(UUID().uuidString)\(fileExtension(for: language))"
        let tempPath = "/tmp/\(tempFileName)"
        
        // Escape the code for shell
        let escapedCode = code
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "'\"'\"'")
            .replacingOccurrences(of: "\n", with: "\\n")
        
        // Build command to create temp file and execute
        let interpreter = RemoteSupportedLanguage(rawValue: language)?.interpreter ?? language
        let shellCommand: String
        
        switch language {
        case "swift":
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "swift \(tempPath)"
            shellCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
            
        case "python", "python3":
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "python3 \(tempPath)"
            shellCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
            
        case "node":
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "node \(tempPath)"
            shellCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
            
        case "bash", "sh":
            shellCommand = "bash -c '\(escapedCode)'"
            
        case "ruby":
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "ruby \(tempPath)"
            shellCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
            
        default:
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "\(interpreter) \(tempPath)"
            shellCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
        }
        
        try await runCommand(command: shellCommand, via: sshManager)
    }
    
    /// Detect language from file path
    func detectLanguage(from path: String) -> String {
        let ext = (path as NSString).pathExtension.lowercased()
        
        switch ext {
        case "swift":
            return "swift"
        case "py", "pyw":
            return "python3"
        case "js", "mjs", "cjs":
            return "node"
        case "ts":
            return "node"
        case "rb":
            return "ruby"
        case "sh":
            return "bash"
        case "zsh":
            return "zsh"
        case "php":
            return "php"
        case "go":
            return "go"
        case "rs":
            return "rust"
        case "java":
            return "java"
        case "kt":
            return "kotlin"
        case "cpp", "cc", "cxx":
            return "c++"
        case "c":
            return "c"
        case "cs":
            return "csharp"
        case "pl", "pm":
            return "perl"
        case "lua":
            return "lua"
        case "r":
            return "r"
        case "m", "mm":
            return "objc"
        default:
            return "bash"
        }
    }
    
    /// Kill the current running process
    func kill() {
        // Close the active channel if any
        if let channel = activeChannel {
            channel.close(promise: nil)
            activeChannel = nil
        }
        
        // Signal continuation to finish
        activeContinuation?.finish()
        activeContinuation = nil
        
        // Update state
        if isRunning {
            output.append("\n[Process terminated by user]")
            isRunning = false
            
            if var process = currentProcess {
                process.exitCode = -9 // SIGKILL
                process.endTime = Date()
                currentProcess = process
                processHistory.append(process)
            }
            
            lastExitCode = -9
        }
    }
    
    /// Get output as async stream for real-time processing
    func getOutputStream() -> AsyncStream<String> {
        return AsyncStream { continuation in
            self.outputContinuation = continuation
            
            // Yield current output immediately
            continuation.yield(output)
            
            // Handle termination
            continuation.onTermination = { _ in
                self.outputContinuation = nil
            }
        }
    }
    
    /// Clear output buffer
    func clearOutput() {
        output = ""
    }
    
    /// Set environment variable
    func setEnvironmentVariable(key: String, value: String) {
        environmentVariables[key] = value
    }
    
    /// Remove environment variable
    func removeEnvironmentVariable(key: String) {
        environmentVariables.removeValue(forKey: key)
    }
    
    /// Set working directory
    func setWorkingDirectory(_ path: String?) {
        workingDirectory = path
    }
    
    /// Get available languages
    func availableLanguages() -> [String] {
        return RemoteSupportedLanguage.allCases.map { $0.rawValue }
    }
    
    // MARK: - Private Methods
    
    private func resetState() async {
        output = ""
        lastExitCode = nil
    }
    
    private func fileExtension(for language: String) -> String {
        return RemoteSupportedLanguage(rawValue: language)?.fileExtension ?? ".tmp"
    }
}
