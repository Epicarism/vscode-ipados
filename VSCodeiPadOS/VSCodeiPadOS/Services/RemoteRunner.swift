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

// MARK: - SSH Command Output Types

enum SSHCommandOutput: Sendable {
    case stdout(String)
    case stderr(String)
    case exit(Int32)
    case timeout
    case error(Error)
}

struct SSHCommandResult: Sendable {
    let stdout: String
    let stderr: String
    let exitCode: Int
    let isTimedOut: Bool
}

extension SSHClientError {
    static let commandExecutionFailed: (String) -> SSHClientError = { reason in
        return .connectionFailed("Command execution failed: \(reason)")
    }
}

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
class RemoteRunner: ObservableObject {
    
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
    
    private var outputStream: AsyncStream<String>?
    private var outputContinuation: AsyncStream<String>.Continuation?
    
    // MARK: - Initialization
    
    init() {
        setupDefaultEnvironment()
    }
    
    private func setupDefaultEnvironment() {
        // Default environment variables
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
        
        await MainActor.run {
            self.currentProcess = process
            self.isRunning = true
        }
        
        // Build command with working directory if specified
        let finalCommand: String
        if let cwd = workingDirectory {
            finalCommand = "cd '\(cwd)' && \(command)"
        } else {
            finalCommand = command
        }
        
        // Execute via SSH with streaming
        let stream = executeCommandStreaming(
            command: finalCommand,
            environment: environmentVariables,
            timeout: defaultTimeout,
            via: sshManager
        )
        
        // Process the stream
        var outputBuffer = ""
        var receivedExit = false
        
        do {
            for try await outputEvent in stream {
                switch outputEvent {
                case .stdout(let text):
                    outputBuffer.append(text)
                    await MainActor.run {
                        self.output.append(text)
                    }
                    
                case .stderr(let text):
                    outputBuffer.append("[stderr] \(text)")
                    await MainActor.run {
                        self.output.append("[stderr] \(text)")
                    }
                    
                case .exit(let code):
                    receivedExit = true
                    await MainActor.run {
                        self.lastExitCode = Int(code)
                        if var process = self.currentProcess {
                            process.exitCode = Int(code)
                            process.endTime = Date()
                            self.currentProcess = process
                            self.processHistory.append(process)
                        }
                        self.isRunning = false
                    }
                    
                case .timeout:
                    outputBuffer.append("\n[Command timed out after \(defaultTimeout) seconds]")
                    await MainActor.run {
                        self.output.append("\n[Command timed out after \(self.defaultTimeout) seconds]")
                        self.isRunning = false
                        self.lastExitCode = -1
                    }
                    
                case .error(let error):
                    throw error
                }
            }
            
            // If no exit code was received, mark as completed
            if !receivedExit {
                await MainActor.run {
                    self.isRunning = false
                    if var process = self.currentProcess {
                        process.exitCode = self.lastExitCode ?? 0
                        process.endTime = Date()
                        self.currentProcess = process
                        self.processHistory.append(process)
                    }
                }
            }
            
        } catch {
            await MainActor.run {
                self.isRunning = false
                self.output.append("\n[Error: \(error.localizedDescription)]")
            }
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
        let runCommand: String
        
        switch language {
        case "swift":
            // For Swift, we need to write to file then run
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "swift \(tempPath)"
            runCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
            
        case "python", "python3":
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "python3 \(tempPath)"
            runCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
            
        case "node":
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "node \(tempPath)"
            runCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
            
        case "bash", "sh":
            // For bash, we can use heredoc or direct execution
            runCommand = "bash -c '\(escapedCode)'"
            
        case "ruby":
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "ruby \(tempPath)"
            runCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
            
        default:
            let createFileCmd = "printf '%b' '\(escapedCode)' > \(tempPath)"
            let runCmd = "\(interpreter) \(tempPath)"
            runCommand = "\(createFileCmd) && \(runCmd) && rm \(tempPath)"
        }
        
        try await runCommand(command: runCommand, via: sshManager)
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
            return "node" // TypeScript can be run with ts-node or node
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
            return "objc" // Objective-C
        default:
            // Try to detect from shebang if possible
            return "bash" // Default fallback
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
    func outputStream() -> AsyncStream<String> {
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
        await MainActor.run {
            output = ""
            lastExitCode = nil
        }
    }
    
    private func fileExtension(for language: String) -> String {
        return RemoteSupportedLanguage(rawValue: language)?.fileExtension ?? ".tmp"
    }
    
    /// Execute command with streaming output using AsyncStream
    private func executeCommandStreaming(
        command: String,
        environment: [String: String]? = nil,
        timeout: TimeInterval = 60,
        via sshManager: SSHManager
    ) -> AsyncStream<SSHCommandOutput> {
        return AsyncStream { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            
            self.activeContinuation = continuation
            
            // Use SSHManager's async execution
            let stream = sshManager.executeCommandAsync(
                command: command,
                workingDirectory: nil, // Already handled in command building
                environment: environment,
                timeout: timeout
            )
            
            Task {
                do {
                    for try await event in stream {
                        continuation.yield(event)
                        
                        // Store reference to channel for kill functionality
                        if case .stdout = event, let channel = self.activeChannel {
                            // Channel is tracked
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.yield(.error(error))
                    continuation.finish()
                }
            }
            
            // Handle cancellation
            continuation.onTermination = { _ in
                self.activeContinuation = nil
            }
        }
    }
}

// MARK: - Extension to add executeCommandAsync to SSHManager if not present

extension SSHManager {
    /// Execute a command with real-time output streaming via AsyncStream
    func executeCommandAsync(
        command: String,
        workingDirectory: String? = nil,
        environment: [String: String]? = nil,
        timeout: TimeInterval = 60
    ) -> AsyncStream<SSHCommandOutput> {
        return AsyncStream { [weak self] continuation in
            guard let self = self, self.isConnected, let channel = self.channel, let sshHandler = self.sshHandler else {
                continuation.yield(.error(SSHClientError.notConnected))
                continuation.finish()
                return
            }
            
            let channelPromise = channel.eventLoop.makePromise(of: Channel.self)
            var timeoutTask: DispatchWorkItem?
            var isFinished = false
            
            func finishStream() {
                guard !isFinished else { return }
                isFinished = true
                timeoutTask?.cancel()
                continuation.finish()
            }
            
            // Create the exec channel with real-time output handler
            sshHandler.createChannel(channelPromise) { childChannel, channelType in
                guard channelType == .session else {
                    return childChannel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                }
                
                let handler = RemoteExecChannelHandler(
                    outputHandler: { output in
                        DispatchQueue.main.async {
                            guard !isFinished else { return }
                            continuation.yield(output)
                            
                            if case .exit = output {
                                finishStream()
                            }
                        }
                    },
                    completionHandler: { result in
                        DispatchQueue.main.async {
                            guard !isFinished else { return }
                            
                            if result.isTimedOut {
                                continuation.yield(.timeout)
                            } else {
                                continuation.yield(.exit(Int32(result.exitCode)))
                            }
                            finishStream()
                        }
                    }
                )
                
                let execRequest = SSHChannelRequestEvent.ExecRequest(
                    command: workingDirectory != nil ? "cd '\(workingDirectory!)' && \(command)" : command,
                    wantReply: true
                )
                
                return childChannel.pipeline.addHandler(handler).flatMap {
                    childChannel.triggerUserOutboundEvent(execRequest, promise: nil)
                    return childChannel.setOption(ChannelOptions.allowRemoteHalfClosure, value: true)
                }
            }
            
            // Handle errors
            channelPromise.futureResult.whenFailure { error in
                DispatchQueue.main.async {
                    guard !isFinished else { return }
                    continuation.yield(.error(error))
                    finishStream()
                }
            }
            
            // Set up timeout
            timeoutTask = DispatchWorkItem {
                DispatchQueue.main.async {
                    guard !isFinished else { return }
                    continuation.yield(.timeout)
                    finishStream()
                }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutTask!)
            
            // Handle cancellation
            continuation.onTermination = { _ in
                timeoutTask?.cancel()
                channelPromise.futureResult.whenSuccess { channel in
                    channel.close(promise: nil)
                }
            }
        }
    }
}

// MARK: - Remote Exec Channel Handler

private class RemoteExecChannelHandler: ChannelDuplexHandler {
    typealias InboundIn = SSHChannelData
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = SSHChannelData
    
    private var stdoutBuffer = ByteBufferAllocator().buffer(capacity: 4096)
    private var stderrBuffer = ByteBufferAllocator().buffer(capacity: 4096)
    private var exitCode: Int?
    private var outputHandler: ((SSHCommandOutput) -> Void)?
    private var completionHandler: ((SSHCommandResult) -> Void)?
    
    init(
        outputHandler: ((SSHCommandOutput) -> Void)? = nil,
        completionHandler: ((SSHCommandResult) -> Void)? = nil
    ) {
        self.outputHandler = outputHandler
        self.completionHandler = completionHandler
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let channelData = unwrapInboundIn(data)
        
        switch channelData.type {
        case .channel:
            guard case .byteBuffer(let buffer) = channelData.data else { return }
            
            // Accumulate stdout
            var mutableBuffer = buffer
            stdoutBuffer.writeBuffer(&mutableBuffer)
            
            // Notify real-time handler
            if let text = buffer.getString(at: 0, length: buffer.readableBytes) {
                outputHandler?(.stdout(text))
            }
            
        case .stdErr:
            guard case .byteBuffer(let buffer) = channelData.data else { return }
            
            // Accumulate stderr
            var mutableBuffer = buffer
            stderrBuffer.writeBuffer(&mutableBuffer)
            
            // Notify real-time handler
            if let text = buffer.getString(at: 0, length: buffer.readableBytes) {
                outputHandler?(.stderr(text))
            }
            
        default:
            break
        }
    }
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        if let exitStatus = event as? SSHChannelRequestEvent.ExitStatus {
            exitCode = Int(exitStatus.exitStatus)
            outputHandler?(.exit(exitStatus.exitStatus))
        }
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        let stdout = stdoutBuffer.getString(at: 0, length: stdoutBuffer.readableBytes) ?? ""
        let stderr = stderrBuffer.getString(at: 0, length: stderrBuffer.readableBytes) ?? ""
        let result = SSHCommandResult(
            stdout: stdout,
            stderr: stderr,
            exitCode: exitCode ?? -1,
            isTimedOut: false
        )
        completionHandler?(result)
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        outputHandler?(.error(error))
        context.close(promise: nil)
    }
}
