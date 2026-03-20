//
//  TunnelWebSocketClient.swift
//  VSCodeiPadOS
//
//  Production WebSocket client for VS Code tunnel communication.
//  Provides persistent bidirectional messaging with auto-reconnect,
//  message routing, heartbeat, and quality metrics.
//

import Foundation
import Combine
import os

// MARK: - Tunnel Message Protocol

enum TunnelMessageType: String, Codable {
    case fileSystemRequest = "fs.request"
    case fileSystemResponse = "fs.response"
    case fileSystemEvent = "fs.event"
    case terminalInput = "terminal.input"
    case terminalOutput = "terminal.output"
    case terminalResize = "terminal.resize"
    case lspRequest = "lsp.request"
    case lspResponse = "lsp.response"
    case lspNotification = "lsp.notification"
    case debugRequest = "debug.request"
    case debugResponse = "debug.response"
    case debugEvent = "debug.event"
    case heartbeat = "heartbeat"
    case heartbeatAck = "heartbeat.ack"
    case auth = "auth"
    case authResponse = "auth.response"
    case error = "error"
    case extensionRequest = "extension.request"
    case extensionResponse = "extension.response"
}

struct TunnelMessage: Codable, Identifiable {
    let id: String
    let type: TunnelMessageType
    let channel: String?
    let payload: [String: AnyCodable]
    let timestamp: Date
    let correlationId: String?  // For request-response matching
    
    init(
        id: String = UUID().uuidString,
        type: TunnelMessageType,
        channel: String? = nil,
        payload: [String: AnyCodable] = [:],
        correlationId: String? = nil
    ) {
        self.id = id
        self.type = type
        self.channel = channel
        self.payload = payload
        self.timestamp = Date()
        self.correlationId = correlationId
    }
}

/// Type-erased Codable wrapper for heterogeneous payloads
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal
        } else if container.decodeNil() {
            value = NSNull()
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let stringVal as String: try container.encode(stringVal)
        case let intVal as Int: try container.encode(intVal)
        case let doubleVal as Double: try container.encode(doubleVal)
        case let boolVal as Bool: try container.encode(boolVal)
        case let dictVal as [String: AnyCodable]: try container.encode(dictVal)
        case let arrayVal as [AnyCodable]: try container.encode(arrayVal)
        case let dataVal as Data: try container.encode(dataVal.base64EncodedString())
        default: try container.encodeNil()
        }
    }
    
    var stringValue: String? { value as? String }
    var intValue: Int? { value as? Int }
    var doubleValue: Double? { value as? Double }
    var boolValue: Bool? { value as? Bool }
    var dataValue: Data? {
        if let data = value as? Data { return data }
        if let str = value as? String { return Data(base64Encoded: str) }
        return nil
    }
}

// MARK: - Connection State

enum WebSocketConnectionState: Equatable {
    case disconnected
    case connecting
    case authenticating
    case connected
    case reconnecting(attempt: Int)
    case failed(String)
    
    var isActive: Bool {
        switch self {
        case .connected, .authenticating: return true
        default: return false
        }
    }
    
    var statusText: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .authenticating: return "Authenticating..."
        case .connected: return "Connected"
        case .reconnecting(let attempt): return "Reconnecting (\(attempt))..."
        case .failed(let reason): return "Failed: \(reason)"
        }
    }
    
    static func == (lhs: WebSocketConnectionState, rhs: WebSocketConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected): return true
        case (.connecting, .connecting): return true
        case (.authenticating, .authenticating): return true
        case (.connected, .connected): return true
        case (.reconnecting(let a), .reconnecting(let b)): return a == b
        case (.failed(let a), .failed(let b)): return a == b
        default: return false
        }
    }
}

// MARK: - WebSocket Errors

enum TunnelWebSocketError: Error, LocalizedError {
    case connectionFailed(String)
    case authenticationFailed(String)
    case messageSendFailed(String)
    case timeout(String)
    case notConnected
    case invalidURL(String)
    case protocolError(String)
    case serverError(Int, String)
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let msg): return "Connection failed: \(msg)"
        case .authenticationFailed(let msg): return "Auth failed: \(msg)"
        case .messageSendFailed(let msg): return "Send failed: \(msg)"
        case .timeout(let msg): return "Timeout: \(msg)"
        case .notConnected: return "Not connected to tunnel"
        case .invalidURL(let url): return "Invalid URL: \(url)"
        case .protocolError(let msg): return "Protocol error: \(msg)"
        case .serverError(let code, let msg): return "Server error \(code): \(msg)"
        }
    }
}

// MARK: - Connection Quality Metrics

struct TunnelConnectionMetrics {
    var latencyMs: Double = 0
    var avgLatencyMs: Double = 0
    var messagesPerSecond: Double = 0
    var totalMessagesSent: Int = 0
    var totalMessagesReceived: Int = 0
    var totalBytesSent: Int64 = 0
    var totalBytesReceived: Int64 = 0
    var reconnectCount: Int = 0
    var uptime: TimeInterval = 0
    var lastHeartbeatAt: Date?
}

// MARK: - Tunnel WebSocket Client

@MainActor
final class TunnelWebSocketClient: ObservableObject {
    static let shared = TunnelWebSocketClient()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "TunnelWebSocket")
    
    // MARK: - Published State
    
    @Published var state: WebSocketConnectionState = .disconnected
    @Published var metrics: TunnelConnectionMetrics = TunnelConnectionMetrics()
    @Published var lastError: String?
    
    // MARK: - Configuration
    
    private let maxReconnectAttempts = 10
    private let heartbeatInterval: TimeInterval = 30
    private let defaultTimeout: TimeInterval = 30
    private let maxQueueSize = 1000
    
    // MARK: - Internal State
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var currentURL: URL?
    private var authToken: String?
    private var reconnectAttempts = 0
    private var connectedAt: Date?
    
    // Message handling
    private var messageQueue: [TunnelMessage] = []
    private var pendingRequests: [String: CheckedContinuation<TunnelMessage, Error>] = [:]
    private var subscriptions: [TunnelMessageType: [UUID: (TunnelMessage) -> Void]] = [:]
    
    // Timers
    private var heartbeatTimer: Timer?
    private var metricsTimer: Timer?
    private var connectionTask: Task<Void, Never>?
    private var receiveTask: Task<Void, Never>?
    
    // Latency tracking
    private var latencyBuffer: [Double] = []
    private var messageCountBuffer: [Date] = []
    private var pendingHeartbeatTimestamp: Date?
    
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Connection
    
    /// Connect to a tunnel WebSocket endpoint
    func connect(to url: URL, authToken: String? = nil) async throws {
        guard state != .connected else {
            Self.logger.info("Already connected")
            return
        }
        
        self.currentURL = url
        self.authToken = authToken
        self.reconnectAttempts = 0
        
        state = .connecting
        Self.logger.info("Connecting to tunnel: \(url.absoluteString)")
        
        try await establishConnection(to: url, authToken: authToken)
    }
    
    /// Disconnect from the tunnel
    func disconnect() {
        Self.logger.info("Disconnecting from tunnel")
        
        connectionTask?.cancel()
        receiveTask?.cancel()
        heartbeatTimer?.invalidate()
        metricsTimer?.invalidate()
        
        webSocketTask?.cancel(with: .goingAway, reason: "Client disconnect".data(using: .utf8))
        webSocketTask = nil
        session?.invalidateAndCancel()
        session = nil
        
        // Fail all pending requests
        for (_, continuation) in pendingRequests {
            continuation.resume(throwing: TunnelWebSocketError.notConnected)
        }
        pendingRequests.removeAll()
        
        state = .disconnected
        connectedAt = nil
    }
    
    // MARK: - Send Messages
    
    /// Send a message (fire-and-forget)
    func send(_ message: TunnelMessage) async throws {
        guard state == .connected, let webSocketTask = webSocketTask else {
            // Queue message for later if reconnecting
            if case .reconnecting = state {
                if messageQueue.count < maxQueueSize {
                    messageQueue.append(message)
                    Self.logger.debug("Message queued (\(self.messageQueue.count) in queue)")
                    return
                } else {
                    throw TunnelWebSocketError.messageSendFailed("Queue full")
                }
            }
            throw TunnelWebSocketError.notConnected
        }
        
        let data = try encoder.encode(message)
        let wsMessage = URLSessionWebSocketTask.Message.data(data)
        
        try await webSocketTask.send(wsMessage)
        
        metrics.totalMessagesSent += 1
        metrics.totalBytesSent += Int64(data.count)
        messageCountBuffer.append(Date())
    }
    
    /// Send a request and wait for a correlated response
    func request(
        _ message: TunnelMessage,
        timeout: TimeInterval? = nil
    ) async throws -> TunnelMessage {
        let effectiveTimeout = timeout ?? defaultTimeout
        
        return try await withCheckedThrowingContinuation { continuation in
            pendingRequests[message.id] = continuation
            
            Task {
                do {
                    try await send(message)
                } catch {
                    pendingRequests.removeValue(forKey: message.id)
                    continuation.resume(throwing: error)
                    return
                }
                
                // Timeout handler
                try? await Task.sleep(nanoseconds: UInt64(effectiveTimeout * 1_000_000_000))
                if let pending = pendingRequests.removeValue(forKey: message.id) {
                    pending.resume(throwing: TunnelWebSocketError.timeout(
                        "Request \(message.id) timed out after \(effectiveTimeout)s"
                    ))
                }
            }
        }
    }
    
    // MARK: - Subscriptions
    
    /// Subscribe to messages of a specific type
    func subscribe(to type: TunnelMessageType) -> AsyncStream<TunnelMessage> {
        let subscriptionId = UUID()
        
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.subscriptions[type]?.removeValue(forKey: subscriptionId)
                }
            }
            
            if subscriptions[type] == nil {
                subscriptions[type] = [:]
            }
            
            subscriptions[type]?[subscriptionId] = { message in
                continuation.yield(message)
            }
        }
    }
    
    /// Subscribe to messages on a specific channel
    func subscribeChannel(_ channel: String, type: TunnelMessageType) -> AsyncStream<TunnelMessage> {
        let subscriptionId = UUID()
        
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.subscriptions[type]?.removeValue(forKey: subscriptionId)
                }
            }
            
            if subscriptions[type] == nil {
                subscriptions[type] = [:]
            }
            
            subscriptions[type]?[subscriptionId] = { message in
                if message.channel == channel {
                    continuation.yield(message)
                }
            }
        }
    }
    
    // MARK: - Private: Connection
    
    private func establishConnection(to url: URL, authToken: String?) async throws {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        
        session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        
        // Add auth token as header or query param
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Set WebSocket-specific headers
        request.setValue("VSCodeiPadOS/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("vscode-tunnel-protocol", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        
        webSocketTask = session?.webSocketTask(with: request)
        webSocketTask?.resume()
        
        // Authenticate if needed
        if authToken != nil {
            state = .authenticating
            try await authenticate(token: authToken!)
        }
        
        state = .connected
        connectedAt = Date()
        reconnectAttempts = 0
        
        Self.logger.info("Connected to tunnel successfully")
        
        // Start receiving messages
        startReceiving()
        
        // Start heartbeat
        startHeartbeat()
        
        // Start metrics collection
        startMetricsCollection()
        
        // Flush queued messages
        await flushMessageQueue()
    }
    
    private func authenticate(token: String) async throws {
        let authMessage = TunnelMessage(
            type: .auth,
            payload: ["token": AnyCodable(token)]
        )
        
        do {
            let response = try await request(authMessage, timeout: 10)
            
            if let error = response.payload["error"]?.stringValue {
                throw TunnelWebSocketError.authenticationFailed(error)
            }
            
            Self.logger.info("Tunnel authentication successful")
        } catch let error as TunnelWebSocketError {
            throw error
        } catch {
            throw TunnelWebSocketError.authenticationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Private: Message Receiving
    
    private func startReceiving() {
        receiveTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self, let task = await self.webSocketTask else { break }
                
                do {
                    let wsMessage = try await task.receive()
                    await self.handleReceivedMessage(wsMessage)
                } catch {
                    if !Task.isCancelled {
                        await self.handleConnectionError(error)
                    }
                    break
                }
            }
        }
    }
    
    private func handleReceivedMessage(_ wsMessage: URLSessionWebSocketTask.Message) {
        let data: Data
        
        switch wsMessage {
        case .data(let d):
            data = d
        case .string(let s):
            guard let d = s.data(using: .utf8) else {
                Self.logger.warning("Failed to decode WebSocket text message")
                return
            }
            data = d
        @unknown default:
            return
        }
        
        metrics.totalMessagesReceived += 1
        metrics.totalBytesReceived += Int64(data.count)
        
        do {
            let message = try decoder.decode(TunnelMessage.self, from: data)
            routeMessage(message)
        } catch {
            Self.logger.error("Failed to decode tunnel message: \(error.localizedDescription)")
        }
    }
    
    private func routeMessage(_ message: TunnelMessage) {
        // Handle heartbeat ack
        if message.type == .heartbeatAck {
            handleHeartbeatAck(message)
            return
        }
        
        // Check if this is a response to a pending request
        if let correlationId = message.correlationId,
           let continuation = pendingRequests.removeValue(forKey: correlationId) {
            continuation.resume(returning: message)
            return
        }
        
        // Also check by ID for direct request-response
        if let continuation = pendingRequests.removeValue(forKey: message.id) {
            continuation.resume(returning: message)
            return
        }
        
        // Route to type-based subscribers
        if let handlers = subscriptions[message.type] {
            for (_, handler) in handlers {
                handler(message)
            }
        }
    }
    
    // MARK: - Private: Heartbeat
    
    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.sendHeartbeat()
            }
        }
    }
    
    private func sendHeartbeat() async {
        let message = TunnelMessage(
            type: .heartbeat,
            payload: ["timestamp": AnyCodable(Date().timeIntervalSince1970)]
        )
        
        pendingHeartbeatTimestamp = Date()
        
        do {
            try await send(message)
        } catch {
            Self.logger.warning("Heartbeat send failed: \(error.localizedDescription)")
        }
    }
    
    private func handleHeartbeatAck(_ message: TunnelMessage) {
        if let sentAt = pendingHeartbeatTimestamp {
            let latency = Date().timeIntervalSince(sentAt) * 1000  // ms
            latencyBuffer.append(latency)
            if latencyBuffer.count > 30 {
                latencyBuffer.removeFirst()
            }
            metrics.latencyMs = latency
            metrics.avgLatencyMs = latencyBuffer.reduce(0, +) / Double(latencyBuffer.count)
            metrics.lastHeartbeatAt = Date()
        }
        pendingHeartbeatTimestamp = nil
    }
    
    // MARK: - Private: Metrics
    
    private func startMetricsCollection() {
        metricsTimer?.invalidate()
        metricsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateMetrics()
            }
        }
    }
    
    private func updateMetrics() {
        // Calculate messages per second
        let now = Date()
        messageCountBuffer.removeAll { now.timeIntervalSince($0) > 1.0 }
        metrics.messagesPerSecond = Double(messageCountBuffer.count)
        
        // Update uptime
        if let connectedAt = connectedAt {
            metrics.uptime = Date().timeIntervalSince(connectedAt)
        }
    }
    
    // MARK: - Private: Reconnection
    
    private func handleConnectionError(_ error: Error) {
        Self.logger.error("WebSocket error: \(error.localizedDescription)")
        
        guard reconnectAttempts < maxReconnectAttempts else {
            state = .failed("Max reconnection attempts (\(maxReconnectAttempts)) exceeded")
            lastError = error.localizedDescription
            return
        }
        
        reconnectAttempts += 1
        metrics.reconnectCount += 1
        state = .reconnecting(attempt: reconnectAttempts)
        
        Self.logger.info("Attempting reconnect \(self.reconnectAttempts)/\(self.maxReconnectAttempts)")
        
        connectionTask = Task { [weak self] in
            guard let self = self else { return }
            
            // Exponential backoff: 1s, 2s, 4s, 8s, 16s, 30s max
            let delay = min(pow(2.0, Double(self.reconnectAttempts - 1)), 30.0)
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            guard !Task.isCancelled, let url = await self.currentURL else { return }
            
            do {
                try await self.establishConnection(to: url, authToken: await self.authToken)
            } catch {
                await self.handleConnectionError(error)
            }
        }
    }
    
    private func flushMessageQueue() async {
        let queued = messageQueue
        messageQueue.removeAll()
        
        Self.logger.info("Flushing \(queued.count) queued messages")
        
        for message in queued {
            do {
                try await send(message)
            } catch {
                Self.logger.warning("Failed to send queued message: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Convenience Helpers
    
    /// Send a file system request and get response
    func fileSystemRequest(method: String, path: String, params: [String: AnyCodable] = [:]) async throws -> TunnelMessage {
        var payload = params
        payload["method"] = AnyCodable(method)
        payload["path"] = AnyCodable(path)
        
        let message = TunnelMessage(
            type: .fileSystemRequest,
            channel: "filesystem",
            payload: payload
        )
        
        return try await request(message)
    }
    
    /// Send terminal input
    func sendTerminalInput(_ data: Data, terminalId: String) async throws {
        let message = TunnelMessage(
            type: .terminalInput,
            channel: terminalId,
            payload: ["data": AnyCodable(data.base64EncodedString())]
        )
        try await send(message)
    }
    
    /// Send an LSP request and get response
    func lspRequest(method: String, params: [String: AnyCodable]) async throws -> TunnelMessage {
        let message = TunnelMessage(
            type: .lspRequest,
            channel: "lsp",
            payload: [
                "method": AnyCodable(method),
                "params": AnyCodable(params)
            ]
        )
        return try await request(message)
    }
}
