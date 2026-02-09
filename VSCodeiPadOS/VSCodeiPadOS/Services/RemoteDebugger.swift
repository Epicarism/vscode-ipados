//
//  RemoteDebugger.swift
//  VSCodeiPadOS
//
//  Remote debugging via SSH using GDB/LLDB
//  Provides full debugging capabilities over SSH connections
//

import Foundation
import Combine

// MARK: - Debugger Type

enum DebuggerType: String, Codable, CaseIterable {
    case gdb = "gdb"
    case lldb = "lldb"
    
    var displayName: String {
        switch self {
        case .gdb: return "GDB"
        case .lldb: return "LLDB"
        }
    }
    
    var executableName: String {
        rawValue
    }
}

// MARK: - Remote Debugger Configuration

struct RemoteDebuggerConfig: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var sshConnectionId: UUID
    var debuggerType: DebuggerType
    var debuggerPath: String?  // Custom path to debugger executable
    var programPath: String
    var programArguments: [String]
    var workingDirectory: String?
    var environmentVariables: [String: String]
    var attachToPID: Int?  // If set, attach instead of launching
    var remoteTarget: String?  // For remote debugging (host:port)
    
    init(
        name: String,
        sshConnectionId: UUID,
        debuggerType: DebuggerType = .lldb,
        programPath: String,
        programArguments: [String] = [],
        workingDirectory: String? = nil,
        environmentVariables: [String: String] = [:],
        attachToPID: Int? = nil,
        remoteTarget: String? = nil
    ) {
        self.name = name
        self.sshConnectionId = sshConnectionId
        self.debuggerType = debuggerType
        self.programPath = programPath
        self.programArguments = programArguments
        self.workingDirectory = workingDirectory
        self.environmentVariables = environmentVariables
        self.attachToPID = attachToPID
        self.remoteTarget = remoteTarget
    }
}

// MARK: - Debugger State

enum RemoteDebuggerState: Equatable {
    case disconnected
    case connecting
    case connected
    case launching
    case running
    case stopped(reason: StopReason)
    case terminated
    
    enum StopReason: Equatable {
        case breakpoint(id: Int)
        case step
        case signal(name: String)
        case exception(description: String)
        case watchpoint(id: Int)
        case unknown
    }
    
    var isActive: Bool {
        switch self {
        case .running, .stopped: return true
        default: return false
        }
    }
    
    var canStep: Bool {
        if case .stopped = self { return true }
        return false
    }
    
    var canContinue: Bool {
        if case .stopped = self { return true }
        return false
    }
}

// MARK: - Breakpoint Model

struct RemoteBreakpoint: Identifiable, Equatable, Hashable {
    let id: Int  // Debugger-assigned ID
    var file: String
    var line: Int
    var condition: String?
    var hitCount: Int
    var isEnabled: Bool
    var isPending: Bool  // Not yet resolved by debugger
    
    init(id: Int, file: String, line: Int, condition: String? = nil, isEnabled: Bool = true) {
        self.id = id
        self.file = file
        self.line = line
        self.condition = condition
        self.hitCount = 0
        self.isEnabled = isEnabled
        self.isPending = true
    }
}

// MARK: - Stack Frame Model

struct RemoteStackFrame: Identifiable, Equatable {
    let id: Int  // Frame index
    var function: String
    var file: String?
    var line: Int?
    var address: String
    var module: String?
    var arguments: [RemoteVariable]
    
    var displayLocation: String {
        if let file = file, let line = line {
            return "\(file):\(line)"
        } else if let module = module {
            return "\(module) @ \(address)"
        }
        return address
    }
}

// MARK: - Variable Model

struct RemoteVariable: Identifiable, Equatable {
    let id: String
    var name: String
    var value: String
    var type: String
    var numChildren: Int
    var children: [RemoteVariable]
    var isExpandable: Bool { numChildren > 0 }
    var hasLoadedChildren: Bool
    
    init(id: String = UUID().uuidString, name: String, value: String, type: String, numChildren: Int = 0) {
        self.id = id
        self.name = name
        self.value = value
        self.type = type
        self.numChildren = numChildren
        self.children = []
        self.hasLoadedChildren = false
    }
}

// MARK: - Expression Result

struct ExpressionResult: Equatable {
    var expression: String
    var value: String
    var type: String
    var error: String?
    
    var isError: Bool { error != nil }
}

// MARK: - Debugger Events

enum RemoteDebuggerEvent {
    case stateChanged(RemoteDebuggerState)
    case breakpointHit(RemoteBreakpoint, RemoteStackFrame)
    case breakpointAdded(RemoteBreakpoint)
    case breakpointRemoved(Int)
    case breakpointModified(RemoteBreakpoint)
    case stackUpdated([RemoteStackFrame])
    case variablesUpdated([RemoteVariable])
    case output(String, OutputType)
    case error(String)
    case terminated(exitCode: Int?)
    
    enum OutputType {
        case stdout
        case stderr
        case debugger
        case target
    }
}

// MARK: - Remote Debugger Protocol

protocol RemoteDebuggerDelegate: AnyObject {
    func debugger(_ debugger: RemoteDebugger, didReceiveEvent event: RemoteDebuggerEvent)
}

// MARK: - Remote Debugger

@MainActor
final class RemoteDebugger: ObservableObject {
    
    // MARK: - Published State
    
    @Published private(set) var state: RemoteDebuggerState = .disconnected
    @Published private(set) var breakpoints: [Int: RemoteBreakpoint] = [:]
    @Published private(set) var callStack: [RemoteStackFrame] = []
    @Published private(set) var currentFrameIndex: Int = 0
    @Published private(set) var localVariables: [RemoteVariable] = []
    @Published private(set) var globalVariables: [RemoteVariable] = []
    @Published private(set) var registers: [RemoteVariable] = []
    @Published private(set) var consoleOutput: [String] = []
    
    // MARK: - Properties
    
    weak var delegate: RemoteDebuggerDelegate?
    
    private var config: RemoteDebuggerConfig?
    private var sshManager: SSHManager?
    private var debuggerType: DebuggerType = .lldb
    private var nextBreakpointId: Int = 1
    private var pendingCommands: [String: CheckedContinuation<String, Error>] = [:]
    private var outputBuffer: String = ""
    private var isProcessingOutput: Bool = false
    private var commandQueue: [(command: String, continuation: CheckedContinuation<String, Error>)] = []
    private var isExecutingCommand: Bool = false
    
    // MARK: - Prompt Detection
    
    private var lldbPrompt = "(lldb) "
    private var gdbPrompt = "(gdb) "
    
    private var currentPrompt: String {
        debuggerType == .lldb ? lldbPrompt : gdbPrompt
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Connection
    
    /// Connect to remote debugger via SSH
    func connect(config: RemoteDebuggerConfig, sshConfig: SSHConnectionConfig) async throws {
        self.config = config
        self.debuggerType = config.debuggerType
        
        state = .connecting
        emitEvent(.stateChanged(.connecting))
        
        // Create and configure SSH manager
        let ssh = SSHManager()
        self.sshManager = ssh
        
        // Set up SSH delegate to receive output
        let outputHandler = SSHOutputHandler(debugger: self)
        ssh.delegate = outputHandler
        
        // Connect via SSH
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ssh.connect(config: sshConfig) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        state = .connected
        emitEvent(.stateChanged(.connected))
        
        // Start the debugger
        try await startDebugger()
    }
    
    /// Disconnect from remote debugger
    func disconnect() async {
        // Send quit command if connected
        if state.isActive {
            let quitCmd = debuggerType == .lldb ? "quit" : "quit"
            try? await sendCommand(quitCmd)
        }
        
        sshManager?.disconnect()
        sshManager = nil
        
        state = .disconnected
        emitEvent(.stateChanged(.disconnected))
        
        // Clear state
        breakpoints.removeAll()
        callStack.removeAll()
        localVariables.removeAll()
        consoleOutput.removeAll()
    }
    
    // MARK: - Debugger Lifecycle
    
    private func startDebugger() async throws {
        guard let config = config else {
            throw RemoteDebuggerError.notConfigured
        }
        
        state = .launching
        emitEvent(.stateChanged(.launching))
        
        // Build debugger launch command
        let debuggerPath = config.debuggerPath ?? config.debuggerType.executableName
        var launchCommand = debuggerPath
        
        // Add program to debug
        if config.attachToPID == nil && config.remoteTarget == nil {
            launchCommand += " \"\(config.programPath)\""
        }
        
        // Send command to start debugger
        sshManager?.send(command: launchCommand)
        
        // Wait for debugger prompt
        try await waitForPrompt(timeout: 10)
        
        // Configure debugger settings
        try await configureDebugger()
        
        // Handle attach or remote target if specified
        if let pid = config.attachToPID {
            try await attach(toPID: pid)
        } else if let target = config.remoteTarget {
            try await connectToRemoteTarget(target)
        } else {
            // Set program arguments if any
            if !config.programArguments.isEmpty {
                try await setProgramArguments(config.programArguments)
            }
            
            // Set environment variables
            for (key, value) in config.environmentVariables {
                try await setEnvironmentVariable(key: key, value: value)
            }
            
            // Set working directory
            if let workDir = config.workingDirectory {
                try await setWorkingDirectory(workDir)
            }
        }
        
        state = .stopped(reason: .unknown)
        emitEvent(.stateChanged(.stopped(reason: .unknown)))
    }
    
    private func configureDebugger() async throws {
        if debuggerType == .lldb {
            // LLDB configuration
            _ = try await sendCommand("settings set stop-line-count-after 0")
            _ = try await sendCommand("settings set stop-line-count-before 0")
            _ = try await sendCommand("settings set frame-format \"frame #${frame.index}: ${frame.pc}{ ${module.file.basename}{`${function.name-with-args}{${frame.no-debug}${function.pc-offset}}}}{ at ${line.file.basename}:${line.number}}\\n\"")
        } else {
            // GDB configuration
            _ = try await sendCommand("set pagination off")
            _ = try await sendCommand("set print pretty on")
            _ = try await sendCommand("set print array on")
        }
    }
    
    // MARK: - Breakpoint Management
    
    /// Set a breakpoint at file:line
    @discardableResult
    func setBreakpoint(file: String, line: Int, condition: String? = nil) async throws -> RemoteBreakpoint {
        let command: String
        if debuggerType == .lldb {
            command = "breakpoint set --file \"\(file)\" --line \(line)"
        } else {
            command = "break \(file):\(line)"
        }
        
        let response = try await sendCommand(command)
        
        // Parse breakpoint ID from response
        let breakpointId = parseBreakpointId(from: response)
        
        var breakpoint = RemoteBreakpoint(
            id: breakpointId,
            file: file,
            line: line,
            condition: condition
        )
        
        // Set condition if provided
        if let condition = condition {
            try await setBreakpointCondition(id: breakpointId, condition: condition)
            breakpoint.condition = condition
        }
        
        breakpoint.isPending = false
        breakpoints[breakpointId] = breakpoint
        
        emitEvent(.breakpointAdded(breakpoint))
        return breakpoint
    }
    
    /// Set a breakpoint at a function name
    @discardableResult
    func setBreakpoint(function: String, condition: String? = nil) async throws -> RemoteBreakpoint {
        let command: String
        if debuggerType == .lldb {
            command = "breakpoint set --name \"\(function)\""
        } else {
            command = "break \(function)"
        }
        
        let response = try await sendCommand(command)
        let breakpointId = parseBreakpointId(from: response)
        
        var breakpoint = RemoteBreakpoint(
            id: breakpointId,
            file: "",
            line: 0,
            condition: condition
        )
        breakpoint.isPending = false
        
        if let condition = condition {
            try await setBreakpointCondition(id: breakpointId, condition: condition)
        }
        
        breakpoints[breakpointId] = breakpoint
        emitEvent(.breakpointAdded(breakpoint))
        return breakpoint
    }
    
    /// Set a breakpoint at an address
    @discardableResult
    func setBreakpoint(address: String) async throws -> RemoteBreakpoint {
        let command: String
        if debuggerType == .lldb {
            command = "breakpoint set --address \(address)"
        } else {
            command = "break *\(address)"
        }
        
        let response = try await sendCommand(command)
        let breakpointId = parseBreakpointId(from: response)
        
        var breakpoint = RemoteBreakpoint(
            id: breakpointId,
            file: "",
            line: 0
        )
        breakpoint.isPending = false
        
        breakpoints[breakpointId] = breakpoint
        emitEvent(.breakpointAdded(breakpoint))
        return breakpoint
    }
    
    /// Remove a breakpoint by ID
    func removeBreakpoint(id: Int) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "breakpoint delete \(id)"
        } else {
            command = "delete \(id)"
        }
        
        _ = try await sendCommand(command)
        breakpoints.removeValue(forKey: id)
        emitEvent(.breakpointRemoved(id))
    }
    
    /// Remove breakpoint at file:line
    func removeBreakpoint(file: String, line: Int) async throws {
        // Find breakpoint matching file:line
        guard let bp = breakpoints.values.first(where: { $0.file == file && $0.line == line }) else {
            return
        }
        try await removeBreakpoint(id: bp.id)
    }
    
    /// Enable a breakpoint
    func enableBreakpoint(id: Int) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "breakpoint enable \(id)"
        } else {
            command = "enable \(id)"
        }
        
        _ = try await sendCommand(command)
        breakpoints[id]?.isEnabled = true
        if let bp = breakpoints[id] {
            emitEvent(.breakpointModified(bp))
        }
    }
    
    /// Disable a breakpoint
    func disableBreakpoint(id: Int) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "breakpoint disable \(id)"
        } else {
            command = "disable \(id)"
        }
        
        _ = try await sendCommand(command)
        breakpoints[id]?.isEnabled = false
        if let bp = breakpoints[id] {
            emitEvent(.breakpointModified(bp))
        }
    }
    
    /// Set breakpoint condition
    func setBreakpointCondition(id: Int, condition: String) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "breakpoint modify -c \"\(condition)\" \(id)"
        } else {
            command = "condition \(id) \(condition)"
        }
        
        _ = try await sendCommand(command)
        breakpoints[id]?.condition = condition
    }
    
    /// List all breakpoints
    func listBreakpoints() async throws -> [RemoteBreakpoint] {
        let command = debuggerType == .lldb ? "breakpoint list" : "info breakpoints"
        let response = try await sendCommand(command)
        
        // Parse and update breakpoints from response
        let parsedBreakpoints = parseBreakpointList(from: response)
        for bp in parsedBreakpoints {
            breakpoints[bp.id] = bp
        }
        
        return Array(breakpoints.values)
    }
    
    // MARK: - Execution Control
    
    /// Run/continue the program
    func `continue`() async throws {
        guard state.canContinue else {
            throw RemoteDebuggerError.invalidState
        }
        
        let command = debuggerType == .lldb ? "continue" : "continue"
        
        state = .running
        emitEvent(.stateChanged(.running))
        
        let response = try await sendCommandAsync(command)
        handleStopResponse(response)
    }
    
    /// Run the program from the beginning
    func run() async throws {
        let command = debuggerType == .lldb ? "run" : "run"
        
        state = .running
        emitEvent(.stateChanged(.running))
        
        let response = try await sendCommandAsync(command)
        handleStopResponse(response)
    }
    
    /// Step over (next line)
    func stepOver() async throws {
        guard state.canStep else {
            throw RemoteDebuggerError.invalidState
        }
        
        let command = debuggerType == .lldb ? "next" : "next"
        
        state = .running
        emitEvent(.stateChanged(.running))
        
        let response = try await sendCommand(command)
        handleStopResponse(response)
        
        // Update stack and variables
        try await refreshState()
    }
    
    /// Step into function
    func stepInto() async throws {
        guard state.canStep else {
            throw RemoteDebuggerError.invalidState
        }
        
        let command = debuggerType == .lldb ? "step" : "step"
        
        state = .running
        emitEvent(.stateChanged(.running))
        
        let response = try await sendCommand(command)
        handleStopResponse(response)
        
        try await refreshState()
    }
    
    /// Step out of current function
    func stepOut() async throws {
        guard state.canStep else {
            throw RemoteDebuggerError.invalidState
        }
        
        let command = debuggerType == .lldb ? "finish" : "finish"
        
        state = .running
        emitEvent(.stateChanged(.running))
        
        let response = try await sendCommand(command)
        handleStopResponse(response)
        
        try await refreshState()
    }
    
    /// Step one instruction
    func stepInstruction() async throws {
        guard state.canStep else {
            throw RemoteDebuggerError.invalidState
        }
        
        let command = debuggerType == .lldb ? "si" : "stepi"
        
        state = .running
        emitEvent(.stateChanged(.running))
        
        let response = try await sendCommand(command)
        handleStopResponse(response)
        
        try await refreshState()
    }
    
    /// Pause/interrupt the running program
    func pause() async throws {
        guard state == .running else {
            throw RemoteDebuggerError.invalidState
        }
        
        // Send Ctrl+C to interrupt
        sshManager?.sendInterrupt()
        
        // Wait for stop
        try await waitForPrompt(timeout: 5)
        
        state = .stopped(reason: .signal(name: "SIGINT"))
        emitEvent(.stateChanged(.stopped(reason: .signal(name: "SIGINT"))))
        
        try await refreshState()
    }
    
    /// Stop/kill the debugged program
    func stop() async throws {
        let command = debuggerType == .lldb ? "process kill" : "kill"
        _ = try await sendCommand(command)
        
        state = .terminated
        emitEvent(.stateChanged(.terminated))
        emitEvent(.terminated(exitCode: nil))
    }
    
    // MARK: - Attach
    
    /// Attach to a running process by PID
    func attach(toPID pid: Int) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "process attach --pid \(pid)"
        } else {
            command = "attach \(pid)"
        }
        
        state = .running
        emitEvent(.stateChanged(.running))
        
        let response = try await sendCommand(command)
        
        if response.contains("error") || response.contains("failed") {
            throw RemoteDebuggerError.attachFailed(response)
        }
        
        state = .stopped(reason: .unknown)
        emitEvent(.stateChanged(.stopped(reason: .unknown)))
        
        try await refreshState()
    }
    
    /// Attach to a process by name
    func attach(toProcessName name: String, waitForLaunch: Bool = false) async throws {
        let command: String
        if debuggerType == .lldb {
            if waitForLaunch {
                command = "process attach --name \"\(name)\" --waitfor"
            } else {
                command = "process attach --name \"\(name)\""
            }
        } else {
            // GDB doesn't have direct name attach, need pidof first
            command = "attach $(pidof \(name))"
        }
        
        state = .running
        emitEvent(.stateChanged(.running))
        
        let response = try await sendCommandAsync(command)
        
        if response.contains("error") || response.contains("failed") {
            throw RemoteDebuggerError.attachFailed(response)
        }
        
        state = .stopped(reason: .unknown)
        emitEvent(.stateChanged(.stopped(reason: .unknown)))
        
        try await refreshState()
    }
    
    /// Connect to a remote debug server
    func connectToRemoteTarget(_ target: String) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "gdb-remote \(target)"
        } else {
            command = "target remote \(target)"
        }
        
        let response = try await sendCommand(command)
        
        if response.contains("error") || response.contains("failed") {
            throw RemoteDebuggerError.connectionFailed(response)
        }
        
        state = .stopped(reason: .unknown)
        emitEvent(.stateChanged(.stopped(reason: .unknown)))
    }
    
    /// Detach from the current process
    func detach() async throws {
        let command = debuggerType == .lldb ? "process detach" : "detach"
        _ = try await sendCommand(command)
        
        state = .connected
        emitEvent(.stateChanged(.connected))
    }
    
    // MARK: - Expression Evaluation
    
    /// Evaluate an expression
    func evaluateExpression(_ expression: String) async throws -> ExpressionResult {
        let command: String
        if debuggerType == .lldb {
            command = "expression -- \(expression)"
        } else {
            command = "print \(expression)"
        }
        
        let response = try await sendCommand(command)
        return parseExpressionResult(from: response, expression: expression)
    }
    
    /// Evaluate expression and get result as a specific type
    func evaluateExpression<T>(_ expression: String, as type: T.Type) async throws -> T? where T: LosslessStringConvertible {
        let result = try await evaluateExpression(expression)
        if result.isError {
            return nil
        }
        return T(result.value)
    }
    
    /// Execute a debugger command directly
    func executeCommand(_ command: String) async throws -> String {
        let response = try await sendCommand(command)
        appendConsoleOutput("(cmd) \(command)")
        appendConsoleOutput(response)
        return response
    }
    
    // MARK: - Stack Trace
    
    /// Get the current call stack
    func getStackTrace(maxFrames: Int = 100) async throws -> [RemoteStackFrame] {
        let command: String
        if debuggerType == .lldb {
            command = "thread backtrace -c \(maxFrames)"
        } else {
            command = "backtrace \(maxFrames)"
        }
        
        let response = try await sendCommand(command)
        let frames = parseStackTrace(from: response)
        
        callStack = frames
        emitEvent(.stackUpdated(frames))
        
        return frames
    }
    
    /// Select a specific stack frame
    func selectFrame(index: Int) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "frame select \(index)"
        } else {
            command = "frame \(index)"
        }
        
        _ = try await sendCommand(command)
        currentFrameIndex = index
        
        // Refresh variables for the new frame
        _ = try await getVariables()
    }
    
    // MARK: - Variables
    
    /// Get local variables for the current frame
    func getVariables(frame: Int? = nil) async throws -> [RemoteVariable] {
        if let frameIndex = frame {
            try await selectFrame(index: frameIndex)
        }
        
        let command: String
        if debuggerType == .lldb {
            command = "frame variable"
        } else {
            command = "info locals"
        }
        
        let response = try await sendCommand(command)
        let variables = parseVariables(from: response)
        
        localVariables = variables
        emitEvent(.variablesUpdated(variables))
        
        return variables
    }
    
    /// Get global variables
    func getGlobalVariables() async throws -> [RemoteVariable] {
        let command: String
        if debuggerType == .lldb {
            command = "target variable"
        } else {
            command = "info variables"
        }
        
        let response = try await sendCommand(command)
        let variables = parseVariables(from: response)
        
        globalVariables = variables
        return variables
    }
    
    /// Get function arguments for the current frame
    func getArguments() async throws -> [RemoteVariable] {
        let command: String
        if debuggerType == .lldb {
            command = "frame variable -a"
        } else {
            command = "info args"
        }
        
        let response = try await sendCommand(command)
        return parseVariables(from: response)
    }
    
    /// Get CPU registers
    func getRegisters() async throws -> [RemoteVariable] {
        let command: String
        if debuggerType == .lldb {
            command = "register read"
        } else {
            command = "info registers"
        }
        
        let response = try await sendCommand(command)
        let regs = parseRegisters(from: response)
        
        registers = regs
        return regs
    }
    
    /// Expand a variable to get its children
    func expandVariable(path: String) async throws -> [RemoteVariable] {
        let command: String
        if debuggerType == .lldb {
            command = "frame variable \(path)"
        } else {
            command = "print \(path)"
        }
        
        let response = try await sendCommand(command)
        return parseVariables(from: response)
    }
    
    /// Set a variable's value
    func setVariable(name: String, value: String) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "expression \(name) = \(value)"
        } else {
            command = "set var \(name) = \(value)"
        }
        
        let response = try await sendCommand(command)
        
        if response.contains("error") {
            throw RemoteDebuggerError.evaluationFailed(response)
        }
        
        // Refresh variables
        _ = try await getVariables()
    }
    
    // MARK: - Memory
    
    /// Read memory at address
    func readMemory(address: String, count: Int, format: String = "x") async throws -> String {
        let command: String
        if debuggerType == .lldb {
            command = "memory read -c \(count) -f \(format) \(address)"
        } else {
            command = "x/\(count)\(format) \(address)"
        }
        
        return try await sendCommand(command)
    }
    
    /// Write memory at address
    func writeMemory(address: String, value: String) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "memory write \(address) \(value)"
        } else {
            command = "set {int}\(address) = \(value)"
        }
        
        _ = try await sendCommand(command)
    }
    
    // MARK: - Threads
    
    /// Get all threads
    func getThreads() async throws -> [(id: Int, name: String, isCurrent: Bool)] {
        let command: String
        if debuggerType == .lldb {
            command = "thread list"
        } else {
            command = "info threads"
        }
        
        let response = try await sendCommand(command)
        return parseThreadList(from: response)
    }
    
    /// Select a thread
    func selectThread(id: Int) async throws {
        let command: String
        if debuggerType == .lldb {
            command = "thread select \(id)"
        } else {
            command = "thread \(id)"
        }
        
        _ = try await sendCommand(command)
        try await refreshState()
    }
    
    // MARK: - Configuration
    
    private func setProgramArguments(_ args: [String]) async throws {
        if debuggerType == .lldb {
            let argsString = args.map { "\"\($0)\"" }.joined(separator: " ")
            _ = try await sendCommand("settings set target.run-args \(argsString)")
        } else {
            let argsString = args.joined(separator: " ")
            _ = try await sendCommand("set args \(argsString)")
        }
    }
    
    private func setEnvironmentVariable(key: String, value: String) async throws {
        if debuggerType == .lldb {
            _ = try await sendCommand("settings set target.env-vars \(key)=\"\(value)\"")
        } else {
            _ = try await sendCommand("set environment \(key)=\(value)")
        }
    }
    
    private func setWorkingDirectory(_ path: String) async throws {
        if debuggerType == .lldb {
            _ = try await sendCommand("settings set target.process.working-directory \"\(path)\"")
        } else {
            _ = try await sendCommand("cd \(path)")
        }
    }
    
    // MARK: - State Refresh
    
    private func refreshState() async throws {
        _ = try await getStackTrace()
        if !callStack.isEmpty {
            _ = try await getVariables()
        }
    }
    
    // MARK: - Command Execution
    
    private func sendCommand(_ command: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                commandQueue.append((command: command, continuation: continuation))
                processNextCommand()
            }
        }
    }
    
    private func sendCommandAsync(_ command: String) async throws -> String {
        // For commands that may take a long time (run, continue)
        return try await sendCommand(command)
    }
    
    private func processNextCommand() {
        guard !isExecutingCommand, !commandQueue.isEmpty else { return }
        
        isExecutingCommand = true
        let (command, continuation) = commandQueue.removeFirst()
        
        outputBuffer = ""
        sshManager?.send(command: command)
        
        // Set up timeout and response handling
        Task {
            do {
                let response = try await waitForResponse(timeout: 30)
                continuation.resume(returning: response)
            } catch {
                continuation.resume(throwing: error)
            }
            
            await MainActor.run {
                isExecutingCommand = false
                processNextCommand()
            }
        }
    }
    
    private func waitForResponse(timeout: TimeInterval) async throws -> String {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            
            if outputBuffer.contains(currentPrompt) {
                // Remove the prompt from the output
                var response = outputBuffer
                if let promptRange = response.range(of: currentPrompt, options: .backwards) {
                    response = String(response[..<promptRange.lowerBound])
                }
                return response.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        throw RemoteDebuggerError.timeout
    }
    
    private func waitForPrompt(timeout: TimeInterval) async throws {
        _ = try await waitForResponse(timeout: timeout)
    }
    
    // MARK: - Output Handling
    
    func handleSSHOutput(_ text: String) {
        Task { @MainActor in
            outputBuffer += text
            appendConsoleOutput(text)
            emitEvent(.output(text, .debugger))
        }
    }
    
    private func appendConsoleOutput(_ text: String) {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        for line in lines {
            consoleOutput.append(String(line))
        }
        // Keep console output manageable
        if consoleOutput.count > 10000 {
            consoleOutput.removeFirst(consoleOutput.count - 10000)
        }
    }
    
    // MARK: - Response Parsing
    
    private func parseBreakpointId(from response: String) -> Int {
        // LLDB: "Breakpoint 1: where = ..."
        // GDB: "Breakpoint 1 at 0x..."
        
        let patterns = [
            "Breakpoint (\\d+)",
            "breakpoint (\\d+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: response, options: [], range: NSRange(response.startIndex..., in: response)),
               let range = Range(match.range(at: 1), in: response) {
                if let id = Int(response[range]) {
                    return id
                }
            }
        }
        
        // Fallback: assign next ID
        let id = nextBreakpointId
        nextBreakpointId += 1
        return id
    }
    
    private func parseBreakpointList(from response: String) -> [RemoteBreakpoint] {
        var breakpoints: [RemoteBreakpoint] = []
        let lines = response.split(separator: "\n")
        
        for line in lines {
            // Parse LLDB format: "1: file = 'path', line = 123, ..."
            // Parse GDB format: "Num Type Disp Enb Address What"
            
            if let bp = parseBreakpointLine(String(line)) {
                breakpoints.append(bp)
            }
        }
        
        return breakpoints
    }
    
    private func parseBreakpointLine(_ line: String) -> RemoteBreakpoint? {
        // LLDB format parsing
        if let regex = try? NSRegularExpression(pattern: "^(\\d+):", options: []),
           let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)),
           let idRange = Range(match.range(at: 1), in: line),
           let id = Int(line[idRange]) {
            
            var file = ""
            var lineNum = 0
            
            // Extract file
            if let fileRegex = try? NSRegularExpression(pattern: "file = '([^']+)'", options: []),
               let fileMatch = fileRegex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)),
               let fileRange = Range(fileMatch.range(at: 1), in: line) {
                file = String(line[fileRange])
            }
            
            // Extract line
            if let lineRegex = try? NSRegularExpression(pattern: "line = (\\d+)", options: []),
               let lineMatch = lineRegex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)),
               let lineRange = Range(lineMatch.range(at: 1), in: line) {
                lineNum = Int(line[lineRange]) ?? 0
            }
            
            return RemoteBreakpoint(id: id, file: file, line: lineNum)
        }
        
        return nil
    }
    
    private func parseStackTrace(from response: String) -> [RemoteStackFrame] {
        var frames: [RemoteStackFrame] = []
        let lines = response.split(separator: "\n")
        
        for line in lines {
            if let frame = parseStackFrameLine(String(line)) {
                frames.append(frame)
            }
        }
        
        return frames
    }
    
    private func parseStackFrameLine(_ line: String) -> RemoteStackFrame? {
        // LLDB format: "frame #0: 0x00001234 module`function at file.c:123"
        // GDB format: "#0  function (args) at file.c:123"
        
        let patterns: [(pattern: String, groups: (frame: Int, addr: Int, func: Int, file: Int, line: Int))] = [
            // LLDB
            ("frame #(\\d+): (0x[0-9a-fA-F]+) .*`(.+?) at (.+):(\\d+)", (1, 2, 3, 4, 5)),
            ("frame #(\\d+): (0x[0-9a-fA-F]+) .*`(.+?)$", (1, 2, 3, -1, -1)),
            // GDB
            ("#(\\d+)\\s+(.+?) \\(.*\\) at (.+):(\\d+)", (1, -1, 2, 3, 4)),
            ("#(\\d+)\\s+(0x[0-9a-fA-F]+) in (.+?) \\(", (1, 2, 3, -1, -1))
        ]
        
        for (pattern, groups) in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
                  let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)) else {
                continue
            }
            
            func extractGroup(_ index: Int) -> String? {
                guard index > 0 && index < match.numberOfRanges,
                      let range = Range(match.range(at: index), in: line) else {
                    return nil
                }
                return String(line[range])
            }
            
            guard let frameIndexStr = extractGroup(groups.frame),
                  let frameIndex = Int(frameIndexStr) else {
                continue
            }
            
            let address = extractGroup(groups.addr) ?? "0x0"
            let function = extractGroup(groups.func) ?? "<unknown>"
            let file = extractGroup(groups.file)
            let lineNum = extractGroup(groups.line).flatMap { Int($0) }
            
            return RemoteStackFrame(
                id: frameIndex,
                function: function,
                file: file,
                line: lineNum,
                address: address,
                module: nil,
                arguments: []
            )
        }
        
        return nil
    }
    
    private func parseVariables(from response: String) -> [RemoteVariable] {
        var variables: [RemoteVariable] = []
        let lines = response.split(separator: "\n")
        
        for line in lines {
            if let variable = parseVariableLine(String(line)) {
                variables.append(variable)
            }
        }
        
        return variables
    }
    
    private func parseVariableLine(_ line: String) -> RemoteVariable? {
        // LLDB format: "(type) name = value"
        // GDB format: "name = value"
        
        // Try LLDB format first
        if let regex = try? NSRegularExpression(pattern: "\\(([^)]+)\\)\\s+(\\w+)\\s*=\\s*(.+)", options: []),
           let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)) {
            
            func extract(_ index: Int) -> String? {
                guard let range = Range(match.range(at: index), in: line) else { return nil }
                return String(line[range])
            }
            
            if let type = extract(1), let name = extract(2), let value = extract(3) {
                return RemoteVariable(name: name, value: value, type: type)
            }
        }
        
        // Try GDB format
        if let regex = try? NSRegularExpression(pattern: "(\\w+)\\s*=\\s*(.+)", options: []),
           let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)) {
            
            func extract(_ index: Int) -> String? {
                guard let range = Range(match.range(at: index), in: line) else { return nil }
                return String(line[range])
            }
            
            if let name = extract(1), let value = extract(2) {
                return RemoteVariable(name: name, value: value, type: "")
            }
        }
        
        return nil
    }
    
    private func parseRegisters(from response: String) -> [RemoteVariable] {
        var registers: [RemoteVariable] = []
        let lines = response.split(separator: "\n")
        
        for line in lines {
            // Format: "rax = 0x0000000000000000"
            if let regex = try? NSRegularExpression(pattern: "(\\w+)\\s*=\\s*(0x[0-9a-fA-F]+)", options: []),
               let match = regex.firstMatch(in: String(line), options: [], range: NSRange(line.startIndex..., in: line)) {
                
                let lineStr = String(line)
                if let nameRange = Range(match.range(at: 1), in: lineStr),
                   let valueRange = Range(match.range(at: 2), in: lineStr) {
                    let name = String(lineStr[nameRange])
                    let value = String(lineStr[valueRange])
                    registers.append(RemoteVariable(name: name, value: value, type: "register"))
                }
            }
        }
        
        return registers
    }
    
    private func parseExpressionResult(from response: String, expression: String) -> ExpressionResult {
        // Check for error
        if response.lowercased().contains("error:") {
            return ExpressionResult(
                expression: expression,
                value: "",
                type: "",
                error: response
            )
        }
        
        // LLDB format: "(type) $0 = value"
        // GDB format: "$1 = value"
        
        var value = response
        var type = ""
        
        if let regex = try? NSRegularExpression(pattern: "\\(([^)]+)\\).*=\\s*(.+)", options: [.dotMatchesLineSeparators]),
           let match = regex.firstMatch(in: response, options: [], range: NSRange(response.startIndex..., in: response)) {
            
            if let typeRange = Range(match.range(at: 1), in: response) {
                type = String(response[typeRange])
            }
            if let valueRange = Range(match.range(at: 2), in: response) {
                value = String(response[valueRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else if let regex = try? NSRegularExpression(pattern: "=\\s*(.+)", options: [.dotMatchesLineSeparators]),
                  let match = regex.firstMatch(in: response, options: [], range: NSRange(response.startIndex..., in: response)),
                  let valueRange = Range(match.range(at: 1), in: response) {
            value = String(response[valueRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return ExpressionResult(
            expression: expression,
            value: value,
            type: type,
            error: nil
        )
    }
    
    private func parseThreadList(from response: String) -> [(id: Int, name: String, isCurrent: Bool)] {
        var threads: [(id: Int, name: String, isCurrent: Bool)] = []
        let lines = response.split(separator: "\n")
        
        for line in lines {
            let lineStr = String(line)
            let isCurrent = lineStr.contains("*")
            
            // LLDB: "* thread #1, name = 'main', ..."
            // GDB: "* 1 Thread 0x... \"name\""
            
            if let regex = try? NSRegularExpression(pattern: "thread #?(\\d+)", options: .caseInsensitive),
               let match = regex.firstMatch(in: lineStr, options: [], range: NSRange(lineStr.startIndex..., in: lineStr)),
               let idRange = Range(match.range(at: 1), in: lineStr),
               let id = Int(lineStr[idRange]) {
                
                var name = "Thread \(id)"
                if let nameRegex = try? NSRegularExpression(pattern: "name\\s*=\\s*'([^']+)'", options: []),
                   let nameMatch = nameRegex.firstMatch(in: lineStr, options: [], range: NSRange(lineStr.startIndex..., in: lineStr)),
                   let nameRange = Range(nameMatch.range(at: 1), in: lineStr) {
                    name = String(lineStr[nameRange])
                }
                
                threads.append((id: id, name: name, isCurrent: isCurrent))
            }
        }
        
        return threads
    }
    
    private func handleStopResponse(_ response: String) {
        // Determine stop reason from response
        var reason: RemoteDebuggerState.StopReason = .unknown
        
        if response.contains("breakpoint") {
            // Extract breakpoint ID
            if let regex = try? NSRegularExpression(pattern: "breakpoint (\\d+)", options: .caseInsensitive),
               let match = regex.firstMatch(in: response, options: [], range: NSRange(response.startIndex..., in: response)),
               let idRange = Range(match.range(at: 1), in: response),
               let id = Int(response[idRange]) {
                reason = .breakpoint(id: id)
            }
        } else if response.contains("signal") || response.contains("SIGINT") || response.contains("SIGSEGV") {
            let signalPattern = "SIG[A-Z]+"
            if let regex = try? NSRegularExpression(pattern: signalPattern, options: []),
               let match = regex.firstMatch(in: response, options: [], range: NSRange(response.startIndex..., in: response)),
               let signalRange = Range(match.range, in: response) {
                reason = .signal(name: String(response[signalRange]))
            }
        } else if response.contains("step") {
            reason = .step
        } else if response.contains("watchpoint") {
            if let regex = try? NSRegularExpression(pattern: "watchpoint (\\d+)", options: .caseInsensitive),
               let match = regex.firstMatch(in: response, options: [], range: NSRange(response.startIndex..., in: response)),
               let idRange = Range(match.range(at: 1), in: response),
               let id = Int(response[idRange]) {
                reason = .watchpoint(id: id)
            }
        } else if response.contains("exited") || response.contains("terminated") {
            state = .terminated
            emitEvent(.stateChanged(.terminated))
            return
        }
        
        state = .stopped(reason: reason)
        emitEvent(.stateChanged(.stopped(reason: reason)))
    }
    
    // MARK: - Event Emission
    
    private func emitEvent(_ event: RemoteDebuggerEvent) {
        delegate?.debugger(self, didReceiveEvent: event)
    }
}

// MARK: - SSH Output Handler

private class SSHOutputHandler: SSHManagerDelegate {
    weak var debugger: RemoteDebugger?
    
    init(debugger: RemoteDebugger) {
        self.debugger = debugger
    }
    
    func sshManagerDidConnect(_ manager: SSHManager) {}
    
    func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?) {
        Task { @MainActor in
            await debugger?.disconnect()
        }
    }
    
    func sshManager(_ manager: SSHManager, didReceiveOutput text: String) {
        debugger?.handleSSHOutput(text)
    }
    
    func sshManager(_ manager: SSHManager, didReceiveError text: String) {
        debugger?.handleSSHOutput(text)
    }
}

// MARK: - Errors

enum RemoteDebuggerError: Error, LocalizedError {
    case notConfigured
    case notConnected
    case connectionFailed(String)
    case attachFailed(String)
    case invalidState
    case timeout
    case evaluationFailed(String)
    case breakpointFailed(String)
    case commandFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Debugger not configured"
        case .notConnected:
            return "Not connected to remote debugger"
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .attachFailed(let reason):
            return "Failed to attach: \(reason)"
        case .invalidState:
            return "Invalid debugger state for this operation"
        case .timeout:
            return "Debugger command timed out"
        case .evaluationFailed(let reason):
            return "Expression evaluation failed: \(reason)"
        case .breakpointFailed(let reason):
            return "Breakpoint operation failed: \(reason)"
        case .commandFailed(let reason):
            return "Command failed: \(reason)"
        }
    }
}

// MARK: - SSH Command Extensions for RemoteDebugger

extension SSHClientError {
    static func commandExecutionFailed(_ reason: String) -> SSHClientError {
        return .connectionFailed(reason)
    }
}

// MARK: - Command Output Types

enum SSHCommandOutput {
    case stdout(String)
    case stderr(String)
    case exit(Int)
    case error(Error)
    case timeout
}

struct SSHCommandResult {
    let stdout: String
    let stderr: String
    let exitCode: Int
    let isTimedOut: Bool
    
    var isSuccess: Bool {
        exitCode == 0 && !isTimedOut
    }
    
    var combinedOutput: String {
        if stderr.isEmpty {
            return stdout
        } else if stdout.isEmpty {
            return stderr
        }
        return stdout + "\n" + stderr
    }
}
