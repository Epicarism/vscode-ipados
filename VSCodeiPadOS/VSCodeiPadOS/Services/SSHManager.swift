//
//  SSHManager.swift
//  VSCodeiPadOS
//
//  Real SSH Manager using SwiftNIO SSH
//

import Foundation
import SwiftUI
import NIOCore
import NIOPosix
import NIOSSH

// MARK: - SSH Connection Model

struct SSHConnectionConfig: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var host: String
    var port: Int
    var username: String
    var authMethod: SSHAuthMethod
    var lastUsed: Date?
    
    enum SSHAuthMethod: Codable, Equatable {
        case password(String)
        case privateKey(key: String, passphrase: String?)
    }
    
    static func == (lhs: SSHConnectionConfig, rhs: SSHConnectionConfig) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - SSH Manager Delegate Protocol

protocol SSHManagerDelegate: AnyObject {
    func sshManagerDidConnect(_ manager: SSHManager)
    func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?)
    func sshManager(_ manager: SSHManager, didReceiveOutput text: String)
    func sshManager(_ manager: SSHManager, didReceiveError text: String)
}

// MARK: - SSH Client Errors

enum SSHClientError: Error, LocalizedError {
    case connectionFailed(String)
    case authenticationFailed
    case channelCreationFailed
    case invalidChannelType
    case notConnected
    case timeout
    case invalidPrivateKey
    case commandFailed(String)
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason): return "Connection failed: \(reason)"
        case .authenticationFailed: return "Authentication failed"
        case .channelCreationFailed: return "Failed to create SSH channel"
        case .invalidChannelType: return "Invalid channel type"
        case .notConnected: return "Not connected to server"
        case .timeout: return "Connection timed out"
        case .invalidPrivateKey: return "Invalid private key format"
        case .commandFailed(let reason): return "Command execution failed: \(reason)"
        case .notImplemented: return "SSH feature not yet implemented"
        }
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
        return exitCode == 0 && !isTimedOut
    }
}

// MARK: - SSH Authentication Handler

final class PasswordAuthDelegate: NIOSSHClientUserAuthenticationDelegate {
    private let username: String
    private let password: String
    private var attemptedPassword = false
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func nextAuthenticationType(
        availableMethods: NIOSSHAvailableUserAuthenticationMethods,
        nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
    ) {
        if !attemptedPassword && availableMethods.contains(.password) {
            attemptedPassword = true
            nextChallengePromise.succeed(
                NIOSSHUserAuthenticationOffer(
                    username: username,
                    serviceName: "",
                    offer: .password(.init(password: password))
                )
            )
        } else {
            nextChallengePromise.succeed(nil)
        }
    }
}

// MARK: - SSH Host Key Validator (Accept All for now)

final class AcceptAllHostKeysDelegate: NIOSSHClientServerAuthenticationDelegate {
    func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        // Accept all host keys - in production you'd verify against known_hosts
        validationCompletePromise.succeed(())
    }
}

// MARK: - SSH Shell Handler

final class ShellDataHandler: ChannelDuplexHandler, @unchecked Sendable {
    typealias InboundIn = SSHChannelData
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = SSHChannelData
    
    private let onData: @Sendable (String, Bool) -> Void
    
    init(onData: @escaping @Sendable (String, Bool) -> Void) {
        self.onData = onData
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let channelData = self.unwrapInboundIn(data)
        let isStderr = channelData.type == .stdErr
        
        guard case .byteBuffer(var buf) = channelData.data else { return }
        if let str = buf.readString(length: buf.readableBytes) {
            onData(str, isStderr)
        }
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let buffer = self.unwrapOutboundIn(data)
        let channelData = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
        context.write(self.wrapOutboundOut(channelData), promise: promise)
    }
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        // Handle channel close/EOF
        context.fireUserInboundEventTriggered(event)
    }
}

// MARK: - SSH Manager (Real Implementation)

class SSHManager: @unchecked Sendable {
    static let shared = SSHManager()
    
    weak var delegate: SSHManagerDelegate?
    
    private(set) var isConnected: Bool = false
    private(set) var currentConfig: SSHConnectionConfig?
    
    private var group: MultiThreadedEventLoopGroup?
    private var channel: Channel?
    private var shellChannel: Channel?
    
    init() {}
    
    // MARK: - Connection Methods
    
    func connect(config: SSHConnectionConfig) async throws {
        currentConfig = config
        
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.group = group
        
        let authDelegate: NIOSSHClientUserAuthenticationDelegate
        switch config.authMethod {
        case .password(let password):
            authDelegate = PasswordAuthDelegate(username: config.username, password: password)
        case .privateKey(let key, _):
            // For private key auth, we'd need to parse the key
            // For now fall back to password-style with key as password
            authDelegate = PasswordAuthDelegate(username: config.username, password: key)
        }
        
        let bootstrap = ClientBootstrap(group: group)
            .channelInitializer { channel in
                channel.pipeline.addHandlers([
                    NIOSSHHandler(
                        role: .client(
                            .init(
                                userAuthDelegate: authDelegate,
                                serverAuthDelegate: AcceptAllHostKeysDelegate()
                            )
                        ),
                        allocator: channel.allocator,
                        inboundChildChannelInitializer: nil
                    )
                ])
            }
            .connectTimeout(.seconds(15))
        
        do {
            let connection = try await bootstrap.connect(
                host: config.host,
                port: config.port
            ).get()
            
            self.channel = connection
            self.isConnected = true
            
            // Notify delegate on main thread
            let delegate = self.delegate
            DispatchQueue.main.async {
                delegate?.sshManagerDidConnect(self)
            }
            
            // Start interactive shell
            try await startInteractiveShell()
            
        } catch {
            self.isConnected = false
            throw SSHClientError.connectionFailed(error.localizedDescription)
        }
    }
    
    func connect(config: SSHConnectionConfig, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await connect(config: config)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func disconnect() {
        shellChannel?.close(mode: .all, promise: nil)
        channel?.close(mode: .all, promise: nil)
        try? group?.syncShutdownGracefully()
        
        shellChannel = nil
        channel = nil
        group = nil
        isConnected = false
        currentConfig = nil
        
        let delegate = self.delegate
        DispatchQueue.main.async {
            delegate?.sshManagerDidDisconnect(self, error: nil)
        }
    }
    
    // MARK: - Command Execution
    
    func executeCommand(_ command: String, timeout: TimeInterval = 30) async throws -> SSHCommandResult {
        guard isConnected, let channel = self.channel else {
            throw SSHClientError.notConnected
        }
        
        final class OutputCollector: @unchecked Sendable {
            private let lock = NSLock()
            private var _stdout = ""
            private var _stderr = ""
            private var _exitCode: Int?
            
            var stdout: String { lock.withLock { _stdout } }
            var stderr: String { lock.withLock { _stderr } }
            var exitCode: Int? { lock.withLock { _exitCode } }
            
            func appendStdout(_ text: String) { lock.withLock { _stdout += text } }
            func appendStderr(_ text: String) { lock.withLock { _stderr += text } }
            func setExitCode(_ code: Int) { lock.withLock { _exitCode = code } }
        }
        
        let collector = OutputCollector()
        
        let childChannel: Channel = try await channel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
            let childPromise = channel.eventLoop.makePromise(of: Channel.self)
            sshHandler.createChannel(childPromise) { childChannel, channelType in
                guard channelType == .session else {
                    return channel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                }
                return childChannel.pipeline.addHandlers([
                    ShellDataHandler { text, isStderr in
                        if isStderr {
                            collector.appendStderr(text)
                        } else {
                            collector.appendStdout(text)
                        }
                    }
                ])
            }
            return childPromise.futureResult
        }.get()
        
        // Execute the command
        let execRequest = SSHChannelRequestEvent.ExecRequest(
            command: "\(command); echo __EXIT_CODE_MARKER__$?",
            wantReply: true
        )
        try await childChannel.triggerUserOutboundEvent(execRequest).get()
        
        // Wait for channel to close with timeout
        let isTimedOut: Bool
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await childChannel.closeFuture.get()
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    throw SSHClientError.timeout
                }
                try await group.next()
                group.cancelAll()
            }
            isTimedOut = false
        } catch is SSHClientError {
            isTimedOut = true
            try? await childChannel.close()
        }
        
        // Parse exit code from marker in stdout
        var stdout = collector.stdout
        var parsedExitCode = 0
        if let markerRange = stdout.range(of: "__EXIT_CODE_MARKER__") {
            let codeStr = String(stdout[markerRange.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            parsedExitCode = Int(codeStr) ?? 0
            // Remove the marker and everything after it from stdout
            stdout = String(stdout[..<markerRange.lowerBound])
            // Remove trailing newline left by the echo
            if stdout.hasSuffix("\n") {
                stdout = String(stdout.dropLast())
            }
        }
        
        if isTimedOut {
            return SSHCommandResult(
                stdout: stdout,
                stderr: collector.stderr,
                exitCode: -1,
                isTimedOut: true
            )
        }
        
        return SSHCommandResult(
            stdout: stdout,
            stderr: collector.stderr,
            exitCode: parsedExitCode,
            isTimedOut: false
        )
    }
    
    func executeCommand(_ command: String, onOutput: @escaping (SSHCommandOutput) -> Void) async throws {
        guard isConnected else {
            throw SSHClientError.notConnected
        }
        
        let result = try await executeCommand(command)
        if !result.stdout.isEmpty {
            onOutput(.stdout(result.stdout))
        }
        if !result.stderr.isEmpty {
            onOutput(.stderr(result.stderr))
        }
        onOutput(.exit(result.exitCode))
    }
    
    // MARK: - Interactive Shell
    
    func startInteractiveShell() async throws {
        guard let channel = self.channel else {
            throw SSHClientError.notConnected
        }
        
        let delegate = self.delegate
        let manager = self
        
        let childChannel: Channel = try await channel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
            let childPromise = channel.eventLoop.makePromise(of: Channel.self)
            sshHandler.createChannel(childPromise) { childChannel, channelType in
                guard channelType == .session else {
                    return channel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                }
                return childChannel.pipeline.addHandlers([
                    ShellDataHandler { text, isStderr in
                        DispatchQueue.main.async {
                            if isStderr {
                                delegate?.sshManager(manager, didReceiveError: text)
                            } else {
                                delegate?.sshManager(manager, didReceiveOutput: text)
                            }
                        }
                    }
                ])
            }
            return childPromise.futureResult
        }.get()
        
        self.shellChannel = childChannel
        
        // Request PTY
        let ptyRequest = SSHChannelRequestEvent.PseudoTerminalRequest(
            wantReply: true,
            term: "xterm-256color",
            terminalCharacterWidth: 80,
            terminalRowHeight: 24,
            terminalPixelWidth: 0,
            terminalPixelHeight: 0,
            terminalModes: SSHTerminalModes([:])
        )
        try await childChannel.triggerUserOutboundEvent(ptyRequest).get()
        
        // Request Shell
        let shellRequest = SSHChannelRequestEvent.ShellRequest(
            wantReply: true
        )
        try await childChannel.triggerUserOutboundEvent(shellRequest).get()
    }
    
    func send(command: String) {
        guard let shellChannel = self.shellChannel else {
            delegate?.sshManager(self, didReceiveError: "Not connected to shell")
            return
        }
        
        let data = command + "\n"
        var buffer = shellChannel.allocator.buffer(capacity: data.utf8.count)
        buffer.writeString(data)
        shellChannel.writeAndFlush(buffer, promise: nil)
    }
    
    func sendInput(_ text: String) async throws {
        guard let shellChannel = self.shellChannel else {
            throw SSHClientError.notConnected
        }
        
        var buffer = shellChannel.allocator.buffer(capacity: text.utf8.count)
        buffer.writeString(text)
        try await shellChannel.writeAndFlush(buffer)
    }
    
    func sendInterrupt() {
        guard let shellChannel = self.shellChannel else { return }
        var buffer = shellChannel.allocator.buffer(capacity: 1)
        buffer.writeInteger(UInt8(3)) // Ctrl+C
        shellChannel.writeAndFlush(buffer, promise: nil)
    }
    
    func sendTab() {
        guard let shellChannel = self.shellChannel else { return }
        var buffer = shellChannel.allocator.buffer(capacity: 1)
        buffer.writeInteger(UInt8(9)) // Tab
        shellChannel.writeAndFlush(buffer, promise: nil)
    }
    
    func sendEscape() {
        guard let shellChannel = self.shellChannel else { return }
        var buffer = shellChannel.allocator.buffer(capacity: 1)
        buffer.writeInteger(UInt8(27)) // Escape
        shellChannel.writeAndFlush(buffer, promise: nil)
    }
    
    func resizeTerminal(cols: Int, rows: Int) async throws {
        guard let shellChannel = self.shellChannel else {
            throw SSHClientError.notConnected
        }
        
        let windowChange = SSHChannelRequestEvent.WindowChangeRequest(
            terminalCharacterWidth: cols,
            terminalRowHeight: rows,
            terminalPixelWidth: 0,
            terminalPixelHeight: 0
        )
        try await shellChannel.triggerUserOutboundEvent(windowChange).get()
    }
    
    func closeShell() {
        shellChannel?.close(mode: .all, promise: nil)
        shellChannel = nil
    }
    
    deinit {
        shellChannel?.close(mode: .all, promise: nil)
        channel?.close(mode: .all, promise: nil)
        try? group?.syncShutdownGracefully()
    }
}

// MARK: - SSH Connection Store (Persistence)

@MainActor
final class SSHConnectionStore: ObservableObject {
    static let shared = SSHConnectionStore()
    
    @Published var savedConnections: [SSHConnectionConfig] = []
    
    private let userDefaults = UserDefaults.standard
    private let storageKey = "ssh_saved_connections"
    
    init() {
        loadConnections()
    }
    
    func save(_ connection: SSHConnectionConfig) {
        var config = connection
        config.lastUsed = Date()
        
        if let index = savedConnections.firstIndex(where: { $0.id == config.id }) {
            savedConnections[index] = config
        } else {
            savedConnections.append(config)
        }
        
        persistConnections()
    }
    
    func delete(_ connection: SSHConnectionConfig) {
        savedConnections.removeAll { $0.id == connection.id }
        persistConnections()
    }
    
    func updateLastUsed(_ connection: SSHConnectionConfig) {
        if let index = savedConnections.firstIndex(where: { $0.id == connection.id }) {
            savedConnections[index].lastUsed = Date()
            persistConnections()
        }
    }
    
    private func loadConnections() {
        guard let data = userDefaults.data(forKey: storageKey),
              let connections = try? JSONDecoder().decode([SSHConnectionConfig].self, from: data) else {
            return
        }
        savedConnections = connections.sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }
    }
    
    private func persistConnections() {
        guard let data = try? JSONEncoder().encode(savedConnections) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
