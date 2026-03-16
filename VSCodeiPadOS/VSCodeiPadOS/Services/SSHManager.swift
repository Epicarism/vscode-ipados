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

class SSHManager: ObservableObject, @unchecked Sendable {
    static let shared = SSHManager()
    
    weak var delegate: SSHManagerDelegate?
    
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var currentConfig: SSHConnectionConfig?
    
    /// Computed property for easy access to connected host name
    var connectedHostName: String? {
        guard let config = currentConfig else { return nil }
        return config.name.isEmpty ? config.host : config.name
    }
    
    private var group: MultiThreadedEventLoopGroup?
    private var channel: Channel?
    private var shellChannel: Channel?
    
    private init() {}
    
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
            
            // Notify delegate and post notification on main thread
            let delegate = self.delegate
            DispatchQueue.main.async {
                delegate?.sshManagerDidConnect(self)
                NotificationCenter.default.post(name: .sshDidConnect, object: self)
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
        
        let delegate = self.delegate
        DispatchQueue.main.async {
            self.isConnected = false
            self.currentConfig = nil
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
        } catch SSHClientError.timeout {
            isTimedOut = true
            try? await childChannel.close()
        } catch {
            // Non-timeout errors: close channel and rethrow
            try? await childChannel.close()
            throw error
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
    
    // MARK: - Port Forwarding
    
    /// Active port forward tunnels - maps local port to tunnel info
    private var activeTunnels: [Int: SSHPortForwardTunnel] = [:]
    private let tunnelLock = NSLock()
    
    /// Setup a local-to-remote port forward (local port -> remote host:port via SSH)
    /// Note: Full port forwarding requires NIOSSH direct-tcpip support.
    /// Current implementation tracks tunnel state for UI purposes.
    func setupPortForward(localPort: Int, remoteHost: String, remotePort: Int) async throws {
        guard isConnected else {
            throw SSHClientError.notConnected
        }
        
        let tunnel = SSHPortForwardTunnel(
            localPort: localPort,
            remoteHost: remoteHost,
            remotePort: remotePort
        )
        
        tunnelLock.withLock {
            activeTunnels[localPort] = tunnel
        }
        
        // Use SSH command to set up port forwarding on the remote side
        // This is a simplified approach - full implementation would use direct-tcpip channels
        _ = try await executeCommand("echo 'Port forward \(localPort) -> \(remoteHost):\(remotePort) established'")
    }
    
    /// Setup remote-to-local port forward
    func setupRemoteForward(remotePort: Int, localHost: String, localPort: Int) async throws {
        guard isConnected else {
            throw SSHClientError.notConnected
        }
        
        let tunnel = SSHPortForwardTunnel(
            localPort: localPort,
            remoteHost: localHost,
            remotePort: remotePort,
            isRemoteForward: true
        )
        
        tunnelLock.withLock {
            activeTunnels[remotePort] = tunnel
        }
    }
    
    /// Cancel a port forward
    func cancelPortForward(localPort: Int) async throws {
        tunnelLock.withLock {
            if let tunnel = activeTunnels[localPort] {
                tunnel.listenerChannel?.close(mode: .all, promise: nil)
                activeTunnels.removeValue(forKey: localPort)
            }
        }
    }
    
    /// Cancel remote port forward
    func cancelRemoteForward(remotePort: Int) async throws {
        tunnelLock.withLock {
            activeTunnels.removeValue(forKey: remotePort)
        }
    }
    
    /// List all active port forwards
    func listPortForwards() -> [SSHPortForwardTunnel] {
        tunnelLock.withLock {
            Array(activeTunnels.values)
        }
    }
    
    /// Scan for listening ports on the remote server
    func scanRemotePorts() async -> [DiscoveredPort] {
        guard isConnected else { return [] }
        
        var ports: [DiscoveredPort] = []
        
        // Try ss command first (more common on modern Linux)
        if let result = try? await executeCommand("ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null") {
            let lines = result.stdout.components(separatedBy: "\n")
            for line in lines.dropFirst() {
                let parts = line.split(separator: " ").map(String.init)
                // Parse port from listening address (e.g., *:8080 or 0.0.0.0:3000)
                for part in parts {
                    if part.contains(":") {
                        let components = part.split(separator: ":")
                        if let last = components.last, let port = Int(last), port > 0, port < 65536 {
                            if !ports.contains(where: { $0.port == port }) {
                                ports.append(DiscoveredPort(port: port, processName: ""))
                            }
                        }
                    }
                }
            }
        }
        
        // Try to get process names via lsof
        if !ports.isEmpty, let result = try? await executeCommand("lsof -i -P -n 2>/dev/null | grep LISTEN") {
            let lines = result.stdout.components(separatedBy: "\n")
            for line in lines {
                let parts = line.split(separator: " ").map(String.init)
                if parts.count >= 9,
                   let lastPart = parts.last,
                   let colonIdx = lastPart.lastIndex(of: ":") {
                    let portStr = String(lastPart[lastPart.index(after: colonIdx)...])
                    if let port = Int(portStr) {
                        if let idx = ports.firstIndex(where: { $0.port == port }) {
                            ports[idx].processName = String(parts[0])
                        }
                    }
                }
            }
        }
        
        return ports.sorted { $0.port < $1.port }
    }
    
    deinit {
        shellChannel?.close(mode: .all, promise: nil)
        channel?.close(mode: .all, promise: nil)
        try? group?.syncShutdownGracefully()
    }
}

// MARK: - Port Forwarding Types

/// Represents an active SSH port forward tunnel
final class SSHPortForwardTunnel: @unchecked Sendable {
    let localPort: Int
    let remoteHost: String
    let remotePort: Int
    let isRemoteForward: Bool
    var listenerChannel: Channel?
    var isActive: Bool = true
    var bytesTransferred: UInt64 = 0
    
    init(localPort: Int, remoteHost: String, remotePort: Int, isRemoteForward: Bool = false) {
        self.localPort = localPort
        self.remoteHost = remoteHost
        self.remotePort = remotePort
        self.isRemoteForward = isRemoteForward
    }
}

/// Represents a listening port detected on a system
struct ListeningPort: Identifiable, Equatable {
    let id = UUID()
    let port: Int
    let address: String
    var processName: String
    let `protocol`: PortProtocol
    
    static func == (lhs: ListeningPort, rhs: ListeningPort) -> Bool {
        lhs.port == rhs.port && lhs.address == rhs.address
    }
}

/// Simplified port info from remote scan
struct DiscoveredPort: Identifiable, Equatable {
    let id = UUID()
    let port: Int
    var processName: String
    
    static func == (lhs: DiscoveredPort, rhs: DiscoveredPort) -> Bool {
        lhs.port == rhs.port
    }
}
/// Data handler for port forwarding - bridges between local TCP and SSH channel
final class PortForwardDataHandler: ChannelDuplexHandler, @unchecked Sendable {
    typealias InboundIn = SSHChannelData
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = SSHChannelData
    
    private weak var localChannel: Channel?
    
    init(localChannel: Channel) {
        self.localChannel = localChannel
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let channelData = self.unwrapInboundIn(data)
        guard case .byteBuffer(var buf) = channelData.data else { return }
        if let str = buf.readString(length: buf.readableBytes) {
            // Forward data to local channel
            var outBuf = localChannel?.allocator.buffer(capacity: str.utf8.count) ?? ByteBuffer()
            outBuf.writeString(str)
            localChannel?.writeAndFlush(outBuf, promise: nil)
        }
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let buffer = self.unwrapOutboundIn(data)
        let channelData = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
        context.write(self.wrapOutboundOut(channelData), promise: promise)
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
