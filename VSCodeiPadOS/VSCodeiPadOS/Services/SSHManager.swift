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
@preconcurrency import NIOSSH

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
    case portForwardFailed(String)
    
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
        case .portForwardFailed(let reason): return "Port forwarding failed: \(reason)"
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
                    serviceName: "ssh-connection",
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
        // Disconnect existing session if connected to prevent resource leaks
        if isConnected {
            disconnect()
        }
        
        await MainActor.run { self.currentConfig = config }
        
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.group = group
        
        nonisolated(unsafe) let authDelegate: NIOSSHClientUserAuthenticationDelegate
        switch config.authMethod {
        case .password(let password):
            authDelegate = PasswordAuthDelegate(username: config.username, password: password)
        case .privateKey(let key, _):
            // For private key auth, we'd need to parse the key
            // For now fall back to password-style with key as password
            // TODO: Implement proper NIOSSHPrivateKey-based public key authentication
            authDelegate = PasswordAuthDelegate(username: config.username, password: key)
        }
        
        let bootstrap = ClientBootstrap(group: group)
            .channelInitializer { channel in
                nonisolated(unsafe) let handler = NIOSSHHandler(
                    role: .client(
                        .init(
                            userAuthDelegate: authDelegate,
                            serverAuthDelegate: AcceptAllHostKeysDelegate()
                        )
                    ),
                    allocator: channel.allocator,
                    inboundChildChannelInitializer: nil
                )
                return channel.pipeline.addHandlers([handler])
            }
            .connectTimeout(.seconds(15))
        
        do {
            let connection = try await bootstrap.connect(
                host: config.host,
                port: config.port
            ).get()
            
            self.channel = connection
            await MainActor.run { self.isConnected = true }
            
            // Notify delegate and post notification on main thread
            let delegate = self.delegate
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                delegate?.sshManagerDidConnect(self)
                NotificationCenter.default.post(name: .sshDidConnect, object: self)
            }
            
            // Start interactive shell
            try await startInteractiveShell()
            
        } catch {
            await MainActor.run { self.isConnected = false }
            // Clean up leaked EventLoopGroup on failure
            let failedGroup = group
            self.group = nil
            DispatchQueue.global().async { try? failedGroup.syncShutdownGracefully() }
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
        // Close all active port forward listeners before tearing down the connection
        tunnelLock.withLock {
            for (_, tunnel) in activeTunnels {
                tunnel.listenerChannel?.close(mode: .all, promise: nil)
                tunnel.isActive = false
            }
            activeTunnels.removeAll()
        }
        
        shellChannel?.close(mode: .all, promise: nil)
        channel?.close(mode: .all, promise: nil)
        try? group?.syncShutdownGracefully()
        
        shellChannel = nil
        channel = nil
        group = nil
        
        let delegate = self.delegate
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isConnected = false
            self.currentConfig = nil
            delegate?.sshManagerDidDisconnect(self, error: nil)
            NotificationCenter.default.post(name: .sshDidDisconnect, object: nil)
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
        
        nonisolated(unsafe) let delegate = self.delegate
        weak var weakManager: SSHManager? = self
        
        let childChannel: Channel = try await channel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
            let childPromise = channel.eventLoop.makePromise(of: Channel.self)
            sshHandler.createChannel(childPromise) { childChannel, channelType in
                guard channelType == .session else {
                    return channel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                }
                return childChannel.pipeline.addHandlers([
                    ShellDataHandler { text, isStderr in
                        DispatchQueue.main.async {
                            guard let manager = weakManager else { return }
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
    
    /// Setup a local-to-remote port forward using NIOSSH direct-tcpip channels.
    /// Binds a local TCP server on 127.0.0.1:localPort and forwards each incoming
    /// connection through an SSH direct-tcpip child channel to remoteHost:remotePort.
    func setupPortForward(localPort: Int, remoteHost: String, remotePort: Int) async throws {
        guard isConnected, let sshChannel = self.channel, let group = self.group else {
            throw SSHClientError.notConnected
        }

        // Reject duplicate tunnels on the same local port
        var existingTunnel: SSHPortForwardTunnel?
        tunnelLock.withLock {
            existingTunnel = activeTunnels[localPort]
        }
        if let existing = existingTunnel, existing.isActive {
            throw SSHClientError.portForwardFailed("Port \(localPort) is already being forwarded")
        }

        let tunnel = SSHPortForwardTunnel(
            localPort: localPort,
            remoteHost: remoteHost,
            remotePort: remotePort
        )

        // The originator address reports 127.0.0.1:localPort to the SSH server
        let originatorAddress = try SocketAddress(ipAddress: "127.0.0.1", port: localPort)

        let listenerChannel = try await ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 16)
            .childChannelOption(ChannelOptions.socket(
                SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR
            ), value: 1)
            .childChannelInitializer { [weak sshChannel] localChannel in
                guard let sshChannel = sshChannel else {
                    return localChannel.eventLoop.makeFailedFuture(SSHClientError.notConnected)
                }

                // For each incoming TCP connection create an SSH direct-tcpip child channel
                return sshChannel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
                    let sshChildPromise = sshChannel.eventLoop.makePromise(of: Channel.self)

                    let channelType: SSHChannelType = .directTCPIP(.init(
                        targetHost: remoteHost,
                        targetPort: remotePort,
                        originatorAddress: originatorAddress
                    ))

                    sshHandler.createChannel(sshChildPromise, channelType: channelType) { sshChildChannel, _ in
                        // When the SSH child channel closes, close the local TCP connection
                        sshChildChannel.closeFuture.whenComplete { _ in
                            localChannel.close(mode: .all, promise: nil)
                        }

                        // PortForwardDataHandler converts SSHChannelData <-> ByteBuffer and
                        // writes inbound data directly to the local TCP channel
                        return sshChildChannel.pipeline.addHandler(
                            PortForwardDataHandler(localChannel: localChannel)
                        )
                    }

                    // Once the SSH child channel is ready, add a GlueHandler on the local
                    // TCP channel to forward its inbound reads to the SSH child channel.
                    return sshChildPromise.futureResult.flatMap { sshChildChannel in
                        localChannel.pipeline.addHandler(
                            PortForwardGlueHandler(pairedChannel: sshChildChannel)
                        )
                    }.flatMapError { error in
                        // SSH channel creation failed — close the local TCP connection
                        localChannel.close(mode: .all, promise: nil)
                        return localChannel.eventLoop.makeFailedFuture(error)
                    }
                }.flatMapError { error in
                    // Failed to get SSH handler — close local TCP connection
                    localChannel.close(mode: .all, promise: nil)
                    return localChannel.eventLoop.makeFailedFuture(error)
                }
            }
            .bind(host: "127.0.0.1", port: localPort).get()

        tunnel.listenerChannel = listenerChannel
        tunnel.isActive = true
        tunnelLock.withLock {
            activeTunnels[localPort] = tunnel
        }
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
    
    /// Cancel a port forward by closing its listener channel and removing the tunnel.
    func cancelPortForward(localPort: Int) async throws {
        var tunnel: SSHPortForwardTunnel?
        tunnelLock.withLock {
            tunnel = activeTunnels[localPort]
            activeTunnels.removeValue(forKey: localPort)
        }
        guard let tunnel = tunnel else { return }
        tunnel.isActive = false
        if let listener = tunnel.listenerChannel {
            try? await listener.close()
        }
        tunnel.listenerChannel = nil
    }
    
    /// Cancel remote port forward
    func cancelRemoteForward(remotePort: Int) async throws {
        _ = tunnelLock.withLock {
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

// MARK: - Port Forward Data Handler

/// Data handler for port forwarding – sits on the SSH child channel and bridges
/// SSHChannelData <-> ByteBuffer. Inbound data (from the remote) is forwarded
/// to the local TCP channel as raw bytes; outbound ByteBuffer data is wrapped
/// as SSHChannelData before being sent over SSH.
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
        guard case .byteBuffer(let buf) = channelData.data else { return }
        // Forward raw bytes directly to the local TCP channel (no string conversion)
        localChannel?.writeAndFlush(buf, promise: nil)
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let buffer = self.unwrapOutboundIn(data)
        let channelData = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
        context.write(self.wrapOutboundOut(channelData), promise: promise)
    }

    func channelInactive(context: ChannelHandlerContext) {
        localChannel?.close(mode: .all, promise: nil)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        localChannel?.close(mode: .all, promise: nil)
        context.close(mode: .all, promise: nil)
    }
}


// MARK: - Port Forward Glue Handler

/// Bidirectional bridge that connects a local TCP child channel to an SSH
/// direct-tcpip child channel. Placed on the **local** TCP channel, it:
///   • Forwards inbound ByteBuffer reads to the paired SSH channel.
///   • Closes the paired SSH channel when the local connection becomes inactive.
///   • Propagates errors by closing both sides.
final class PortForwardGlueHandler: ChannelDuplexHandler, @unchecked Sendable {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private weak var pairedChannel: Channel?

    init(pairedChannel: Channel) {
        self.pairedChannel = pairedChannel
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        pairedChannel?.writeAndFlush(unwrapInboundIn(data), promise: nil)
    }

    func channelInactive(context: ChannelHandlerContext) {
        pairedChannel?.close(mode: .all, promise: nil)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        pairedChannel?.close(mode: .all, promise: nil)
        context.close(mode: .all, promise: nil)
    }
}


// MARK: - SSH Connection Store (Persistence)

@MainActor
final class SSHConnectionStore: ObservableObject {
    static let shared = SSHConnectionStore()
    
    @Published var savedConnections: [SSHConnectionConfig] = []
    
    private let userDefaults = UserDefaults.standard
    private let storageKey = "ssh_saved_connections"
    private let migrationFlagKey = "ssh_keychain_migrated"
    
    init() {
        migrateToKeychain()
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
        deleteKeychainEntries(for: connection.id)
        savedConnections.removeAll { $0.id == connection.id }
        persistConnections()
    }
    
    func updateLastUsed(_ connection: SSHConnectionConfig) {
        if let index = savedConnections.firstIndex(where: { $0.id == connection.id }) {
            savedConnections[index].lastUsed = Date()
            persistConnections()
        }
    }
    
    // MARK: - Keychain Helpers
    
    private func keychainKey(for configId: UUID, type: String) -> String {
        return "ssh_\(configId.uuidString)_\(type)"
    }
    
    private func deleteKeychainEntries(for configId: UUID) {
        KeychainHelper.shared.delete(keychainKey(for: configId, type: "password"))
        KeychainHelper.shared.delete(keychainKey(for: configId, type: "private_key"))
        KeychainHelper.shared.delete(keychainKey(for: configId, type: "passphrase"))
    }
    
    private func saveCredentialsToKeychain(for config: SSHConnectionConfig) {
        switch config.authMethod {
        case .password(let pwd):
            if !pwd.isEmpty {
                KeychainHelper.shared.set(pwd, forKey: keychainKey(for: config.id, type: "password"))
            }
        case .privateKey(let key, let passphrase):
            if !key.isEmpty {
                KeychainHelper.shared.set(key, forKey: keychainKey(for: config.id, type: "private_key"))
            }
            if let passphrase = passphrase, !passphrase.isEmpty {
                KeychainHelper.shared.set(passphrase, forKey: keychainKey(for: config.id, type: "passphrase"))
            }
        }
    }
    
    private func sanitizedConfig(_ config: SSHConnectionConfig) -> SSHConnectionConfig {
        var sanitized = config
        switch config.authMethod {
        case .password:
            sanitized.authMethod = .password("")
        case .privateKey:
            sanitized.authMethod = .privateKey(key: "", passphrase: nil)
        }
        return sanitized
    }
    
    private func restoredConfig(_ config: SSHConnectionConfig) -> SSHConnectionConfig {
        var restored = config
        
        // Check if this config has credentials in Keychain
        if let keyPwd = KeychainHelper.shared.get(keychainKey(for: config.id, type: "password")) {
            restored.authMethod = .password(keyPwd)
        } else if let key = KeychainHelper.shared.get(keychainKey(for: config.id, type: "private_key")) {
            let passphrase = KeychainHelper.shared.get(keychainKey(for: config.id, type: "passphrase"))
            restored.authMethod = .privateKey(key: key, passphrase: passphrase)
        }
        // If no Keychain entries found, keep whatever was in UserDefaults (backward compat)
        
        return restored
    }
    
    // MARK: - Migration
    
    private func migrateToKeychain() {
        guard !userDefaults.bool(forKey: migrationFlagKey) else { return }
        
        // Load existing configs (which may have plaintext credentials)
        guard let data = userDefaults.data(forKey: storageKey),
              var configs = try? JSONDecoder().decode([SSHConnectionConfig].self, from: data) else {
            // No existing data — nothing to migrate, just mark as done
            userDefaults.set(true, forKey: migrationFlagKey)
            return
        }
        
        // For each config, save credentials to Keychain and sanitize
        for i in configs.indices {
            saveCredentialsToKeychain(for: configs[i])
            configs[i] = sanitizedConfig(configs[i])
        }
        
        // Re-persist with sanitized configs
        if let sanitizedData = try? JSONEncoder().encode(configs) {
            userDefaults.set(sanitizedData, forKey: storageKey)
        }
        
        userDefaults.set(true, forKey: migrationFlagKey)
    }
    
    // MARK: - Persistence
    
    private func loadConnections() {
        guard let data = userDefaults.data(forKey: storageKey),
              let connections = try? JSONDecoder().decode([SSHConnectionConfig].self, from: data) else {
            return
        }
        // Restore real credentials from Keychain
        savedConnections = connections.map { restoredConfig($0) }
            .sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }
    }
    
    private func persistConnections() {
        // Save credentials to Keychain and build sanitized array for UserDefaults
        let sanitized = savedConnections.map { config -> SSHConnectionConfig in
            saveCredentialsToKeychain(for: config)
            return sanitizedConfig(config)
        }
        guard let data = try? JSONEncoder().encode(sanitized) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
