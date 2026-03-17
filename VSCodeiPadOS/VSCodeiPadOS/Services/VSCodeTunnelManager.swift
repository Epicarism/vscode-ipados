//
//  VSCodeTunnelManager.swift
//  VSCodeiPadOS
//
//  Extracted from SettingsView.swift and enhanced with real connection
//  validation, health monitoring, and auto-reconnect.
//

import Foundation
import Combine
import os

// MARK: - Tunnel Configuration

struct TunnelConfig: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var url: String
    var type: TunnelType
    var lastUsed: Date?
    
    enum TunnelType: String, Codable, CaseIterable {
        case vscodeDevTunnel = "VS Code Tunnel"
        case codeServer = "code-server"
        case codespaces = "GitHub Codespaces"
        case custom = "Custom URL"
        
        var icon: String {
            switch self {
            case .vscodeDevTunnel: return "bolt.fill"
            case .codeServer: return "server.rack"
            case .codespaces: return "cloud.fill"
            case .custom: return "link"
            }
        }
        
        var placeholder: String {
            switch self {
            case .vscodeDevTunnel: return "https://vscode.dev/tunnel/machine-name"
            case .codeServer: return "https://your-server.com:8080"
            case .codespaces: return "https://codespace-name.github.dev"
            case .custom: return "https://..."
            }
        }
    }
}

// MARK: - Connection State

enum TunnelConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case reconnecting(attempt: Int)
    case error(String)
    
    var isActive: Bool {
        switch self {
        case .connected, .connecting, .reconnecting:
            return true
        case .disconnected, .error:
            return false
        }
    }
    
    var statusText: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .reconnecting(let attempt): return "Reconnecting (\(attempt)/3)..."
        case .error(let msg): return "Error: \(msg)"
        }
    }
    
    var statusIcon: String {
        switch self {
        case .disconnected: return "circle"
        case .connecting, .reconnecting: return "arrow.triangle.2.circlepath"
        case .connected: return "checkmark.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Tunnel Manager

@MainActor
class TunnelManager: ObservableObject {
    static let shared = TunnelManager()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "TunnelManager")
    
    @Published var configs: [TunnelConfig] = []
    @Published var activeConfig: TunnelConfig?
    @Published var isConnected = false
    @Published var connectionState: TunnelConnectionState = .disconnected
    @Published var lastError: String?
    
    private let configsKey = "tunnelConfigs"
    private let activeConfigKey = "activeTunnelConfigId"
    private let maxReconnectAttempts = 3
    private var healthTimer: Timer?
    private var reconnectAttempts = 0
    
    private init() {
        loadConfigs()
    }
    
    // MARK: - Persistence
    
    func loadConfigs() {
        if let data = UserDefaults.standard.data(forKey: configsKey),
           let decoded = try? JSONDecoder().decode([TunnelConfig].self, from: data) {
            configs = decoded
        }
        
        if let activeId = UserDefaults.standard.string(forKey: activeConfigKey),
           let uuid = UUID(uuidString: activeId) {
            activeConfig = configs.first { $0.id == uuid }
        }
    }
    
    func saveConfigs() {
        if let encoded = try? JSONEncoder().encode(configs) {
            UserDefaults.standard.set(encoded, forKey: configsKey)
        }
    }
    
    func addConfig(_ config: TunnelConfig) {
        configs.append(config)
        saveConfigs()
    }
    
    func removeConfig(_ config: TunnelConfig) {
        configs.removeAll { $0.id == config.id }
        if activeConfig?.id == config.id {
            disconnect()
        }
        saveConfigs()
    }
    
    // MARK: - Connection
    
    func connect(to config: TunnelConfig) {
        Self.logger.info("Connecting to tunnel: \(config.name) at \(config.url)")
        
        // Validate URL
        guard let url = URL(string: config.url), url.scheme != nil else {
            connectionState = .error("Invalid URL format")
            lastError = "Invalid URL format"
            Self.logger.error("Invalid URL: \(config.url)")
            return
        }
        
        // Update state
        connectionState = .connecting
        lastError = nil
        reconnectAttempts = 0
        
        // Update config lastUsed
        var updatedConfig = config
        updatedConfig.lastUsed = Date()
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = updatedConfig
            saveConfigs()
        }
        
        activeConfig = updatedConfig
        UserDefaults.standard.set(config.id.uuidString, forKey: activeConfigKey)
        
        // Check reachability
        Task {
            await validateAndConnect(url: url)
        }
    }
    
    private func validateAndConnect(url: URL) async {
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 10
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...399).contains(httpResponse.statusCode) || httpResponse.statusCode == 401 {
                    // 401 is OK - the WebView will handle auth
                    Self.logger.info("Tunnel reachable (status: \(httpResponse.statusCode))")
                    connectionState = .connected
                    isConnected = true
                    startHealthMonitoring(url: url)
                } else {
                    let msg = "Server returned status \(httpResponse.statusCode)"
                    Self.logger.warning("\(msg)")
                    connectionState = .error(msg)
                    lastError = msg
                    isConnected = false
                }
            }
        } catch {
            Self.logger.error("Connection failed: \(error.localizedDescription)")
            // For URLs that don't respond to HEAD but work in WebView (e.g. vscode.dev),
            // still allow connection — the WebView will show any errors
            if (error as NSError).code == NSURLErrorTimedOut {
                Self.logger.info("Timed out but allowing WebView connection attempt")
                connectionState = .connected
                isConnected = true
                startHealthMonitoring(url: url)
            } else {
                connectionState = .error(error.localizedDescription)
                lastError = error.localizedDescription
                isConnected = false
            }
        }
    }
    
    func disconnect() {
        Self.logger.info("Disconnecting tunnel")
        stopHealthMonitoring()
        connectionState = .disconnected
        isConnected = false
        activeConfig = nil
        lastError = nil
        reconnectAttempts = 0
        UserDefaults.standard.removeObject(forKey: activeConfigKey)
    }
    
    // MARK: - Health Monitoring
    
    private func startHealthMonitoring(url: URL) {
        stopHealthMonitoring()
        
        healthTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.checkHealth(url: url)
            }
        }
    }
    
    private func stopHealthMonitoring() {
        healthTimer?.invalidate()
        healthTimer = nil
    }
    
    private func checkHealth(url: URL) async {
        guard connectionState == .connected else { return }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 10
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...499).contains(httpResponse.statusCode) {
                // Server is responding — reset reconnect counter
                reconnectAttempts = 0
            }
        } catch {
            Self.logger.warning("Health check failed: \(error.localizedDescription)")
            await attemptReconnect(url: url)
        }
    }
    
    private func attemptReconnect(url: URL) async {
        reconnectAttempts += 1
        
        if reconnectAttempts > maxReconnectAttempts {
            Self.logger.error("Max reconnect attempts reached, disconnecting")
            connectionState = .error("Connection lost after \(maxReconnectAttempts) retries")
            lastError = "Connection lost after \(maxReconnectAttempts) retries"
            stopHealthMonitoring()
            return
        }
        
        Self.logger.info("Reconnect attempt \(self.reconnectAttempts)/\(self.maxReconnectAttempts)")
        connectionState = .reconnecting(attempt: reconnectAttempts)
        
        // Wait before retry (exponential backoff: 2s, 4s, 8s)
        let delay = UInt64(pow(2.0, Double(reconnectAttempts))) * 1_000_000_000
        try? await Task.sleep(nanoseconds: delay)
        
        // Retry validation
        await validateAndConnect(url: url)
    }
}
