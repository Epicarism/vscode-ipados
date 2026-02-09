//
//  SSHManager.swift
//  VSCodeiPadOS
//
//  Stub SSH Manager - TODO: Implement with SwiftNIO SSH
//  Add package: https://github.com/apple/swift-nio-ssh
//

import Foundation
import SwiftUI

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
    case commandExecutionFailed(String)
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
        case .commandExecutionFailed(let reason): return "Command execution failed: \(reason)"
        case .notImplemented: return "SSH not yet implemented - add SwiftNIO SSH package"
        }
    }
}

// MARK: - Command Output Types

/// Real-time output events from SSH command execution
enum SSHCommandOutput {
    case stdout(String)
    case stderr(String)
    case exit(Int)
    case error(Error)
    case timeout
}

/// Result of a completed SSH command
struct SSHCommandResult {
    let stdout: String
    let stderr: String
    let exitCode: Int
    let isTimedOut: Bool
    
    var isSuccess: Bool {
        return exitCode == 0 && !isTimedOut
    }
}

// MARK: - SSH Manager (Stub Implementation)

class SSHManager {
    weak var delegate: SSHManagerDelegate?
    
    private(set) var isConnected: Bool = false
    private(set) var currentConfig: SSHConnectionConfig?
    
    init() {}
    
    // MARK: - Connection Methods
    
    /// Connect with async/await
    func connect(config: SSHConnectionConfig) async throws {
        // TODO: Implement with SwiftNIO SSH
        throw SSHClientError.notImplemented
    }
    
    /// Connect with completion handler (for compatibility)
    func connect(config: SSHConnectionConfig, completion: @escaping (Result<Void, Error>) -> Void) {
        // TODO: Implement with SwiftNIO SSH
        completion(.failure(SSHClientError.notImplemented))
    }
    
    func disconnect() {
        isConnected = false
        currentConfig = nil
        delegate?.sshManagerDidDisconnect(self, error: nil)
    }
    
    // MARK: - Command Execution
    
    func executeCommand(_ command: String, timeout: TimeInterval = 30) async throws -> SSHCommandResult {
        // TODO: Implement with SwiftNIO SSH
        throw SSHClientError.notImplemented
    }
    
    func executeCommand(_ command: String, onOutput: @escaping (SSHCommandOutput) -> Void) async throws {
        // TODO: Implement with SwiftNIO SSH
        throw SSHClientError.notImplemented
    }
    
    // MARK: - Interactive Shell
    
    func startInteractiveShell() async throws {
        // TODO: Implement with SwiftNIO SSH
        throw SSHClientError.notImplemented
    }
    
    func sendInput(_ text: String) async throws {
        // TODO: Implement with SwiftNIO SSH
        throw SSHClientError.notImplemented
    }
    
    /// Send a command to the shell
    func send(command: String) {
        // TODO: Implement with SwiftNIO SSH
        delegate?.sshManager(self, didReceiveError: "SSH not implemented")
    }
    
    /// Send interrupt signal (Ctrl+C)
    func sendInterrupt() {
        // TODO: Implement with SwiftNIO SSH
    }
    
    /// Send tab for auto-completion
    func sendTab() {
        // TODO: Implement with SwiftNIO SSH
    }
    
    /// Send escape key
    func sendEscape() {
        // TODO: Implement with SwiftNIO SSH
    }
    
    func resizeTerminal(cols: Int, rows: Int) async throws {
        // TODO: Implement with SwiftNIO SSH
    }
    
    func closeShell() {
        // TODO: Implement with SwiftNIO SSH
    }
    
    deinit {
        disconnect()
    }
}

// MARK: - SSH Connection Store (Persistence)

class SSHConnectionStore: ObservableObject {
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
