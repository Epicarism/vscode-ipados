//
//  VSCodeTunnelManager.swift
//  VSCodeiPadOS
//
//  Extracted from SettingsView.swift and enhanced with real connection
//  validation, health monitoring, and auto-reconnect.
//

import Foundation
import Combine
import Network
import WebKit
import os

// MARK: - Tunnel Configuration

struct TunnelConfig: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var url: String
    var type: TunnelType
    var lastUsed: Date?
    var tunnelMode: TunnelMode = .webview
    
    enum TunnelType: String, Codable, CaseIterable {
        case vscodeDevTunnel = "VS Code Tunnel"
        case codeServer = "code-server"
        case codespaces = "GitHub Codespaces"
        case sshTunnel = "SSH Tunnel"
        case custom = "Custom URL"
        
        var icon: String {
            switch self {
            case .vscodeDevTunnel: return "bolt.fill"
            case .codeServer: return "server.rack"
            case .codespaces: return "cloud.fill"
            case .sshTunnel: return "terminal.fill"
            case .custom: return "link"
            }
        }
        
        var placeholder: String {
            switch self {
            case .vscodeDevTunnel: return "https://vscode.dev/tunnel/machine-name"
            case .codeServer: return "https://your-server.com:8080"
            case .codespaces: return "https://codespace-name.github.dev"
            case .sshTunnel: return "Configured via SSH connection"
            case .custom: return "https://..."
            }
        }
    }
}

// MARK: - Tunnel Mode

enum TunnelMode: String, Codable, CaseIterable {
    case webview = "WebView"
    case hybrid = "Hybrid"
    
    var description: String {
        switch self {
        case .webview: return "Full WebView — VS Code runs entirely in browser"
        case .hybrid: return "Hybrid — Native editor + remote file system via tunnel"
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
    @Published var connectionWarning: String?
    
    // WebView tunnel properties
    @Published var webViewURL: URL?
    @Published var isWebViewReady: Bool = false
    @Published var tunnelMode: TunnelMode = .webview
    @Published var currentRemoteFile: String?
    @Published var remoteWorkspacePath: String?
    
    private let configsKey = "tunnelConfigs"
    private let activeConfigKey = "activeTunnelConfigId"
    private let maxReconnectAttempts = 3
    private var healthTimer: Timer?
    private var networkMonitor: NWPathMonitor?
    private var connectionTask: Task<Void, Never>?
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
        
        // Cancel any previous connection attempt to prevent concurrent connections
        connectionTask?.cancel()
        connectionTask = nil

        // Check reachability
        connectionTask = Task {
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
            } else {
                connectionState = .error("Unexpected response from server")
                isConnected = false
            }
        } catch {
            Self.logger.error("Connection failed: \(error.localizedDescription)")
            // For URLs that don't respond to HEAD but work in WebView (e.g. vscode.dev),
            // still allow connection — the WebView will show any errors
            if (error as NSError).code == NSURLErrorTimedOut {
                Self.logger.info("Timed out but allowing WebView connection attempt")
                connectionState = .connected
                isConnected = true
                connectionWarning = "Server took too long to respond. The page may not load correctly."
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
        connectionTask?.cancel()
        connectionTask = nil
        networkMonitor?.cancel()
        networkMonitor = nil
        stopHealthMonitoring()
        connectionState = .disconnected
        isConnected = false
        activeConfig = nil
        lastError = nil
        connectionWarning = nil
        reconnectAttempts = 0
        UserDefaults.standard.removeObject(forKey: activeConfigKey)
    }
    
    // MARK: - SSH Bridge Integration
    
    /// Called by SSHTunnelBridge when it has a resolved URL from SSH tunnel or port forward.
    /// Skips HTTP validation since the URL was already verified via SSH.
    func connectFromBridge(config: TunnelConfig, resolvedURL: URL) {
        Self.logger.info("Connecting from SSH bridge: \(config.name) at \(resolvedURL)")
        
        // Update state
        activeConfig = config
        connectionState = .connected
        isConnected = true
        lastError = nil
        connectionWarning = nil
        reconnectAttempts = 0
        
        // Set WebView URL
        webViewURL = resolvedURL
        tunnelMode = config.tunnelMode
        
        // Add to configs if not already present
        if !configs.contains(where: { $0.id == config.id }) {
            configs.append(config)
            saveConfigs()
        }
        
        // Start health monitoring for the resolved URL
        startHealthMonitoring(url: resolvedURL)
        setupNetworkMonitor()
    }
    
    /// Connect via SSH using SSHTunnelBridge
    func connectViaSSH(config: TunnelConfig, sshConfig: SSHConnectionConfig) {
        Self.logger.info("Initiating SSH tunnel connection for: \(config.name)")
        connectionState = .connecting
        activeConfig = config
        
        SSHTunnelBridge.shared.connectViaTunnel(sshConfig: sshConfig)
    }
    
    /// Connect via SSH port forward using SSHTunnelBridge
    func connectViaSSHPortForward(config: TunnelConfig, sshConfig: SSHConnectionConfig, remotePort: Int = 8080) {
        Self.logger.info("Initiating SSH port forward for: \(config.name) to port \(remotePort)")
        connectionState = .connecting
        activeConfig = config
        
        SSHTunnelBridge.shared.connectViaPortForward(sshConfig: sshConfig, remotePort: remotePort)
    }
    
    // MARK: - Health Monitoring
    
    private func startHealthMonitoring(url: URL) {
        stopHealthMonitoring()
        
        healthTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.checkHealth(url: url)
            }
        }

        // NWPathMonitor: detect network drops and restores
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if path.status == .unsatisfied {
                    self.connectionState = .error("Network connection lost")
                } else if !self.isConnected, let config = self.activeConfig {
                    // Network restored — try reconnecting
                    self.connect(to: config)
                }
            }
        }
        monitor.start(queue: DispatchQueue(label: "tunnel.network.monitor"))
        networkMonitor = monitor
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
               (200...399).contains(httpResponse.statusCode) {
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
    
    // MARK: - WebView Bridge
    
    /// Connect in hybrid mode — use tunnel for remote file system but native editor
    func connectHybrid(to config: TunnelConfig) {
        var hybridConfig = config
        hybridConfig.tunnelMode = .hybrid
        tunnelMode = .hybrid
        connect(to: hybridConfig)
    }
    
    /// Build the VS Code URL with optional workspace/file path
    func buildTunnelURL(for config: TunnelConfig, file: String? = nil) -> URL? {
        guard var components = URLComponents(string: config.url) else { return nil }
        
        // For vscode.dev tunnels, append workspace/file path
        if let file = file {
            switch config.type {
            case .vscodeDevTunnel:
                // vscode.dev/tunnel/machine/path/to/file
                components.path = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/" + file
            case .codeServer:
                // code-server uses query params
                components.queryItems = (components.queryItems ?? []) + [
                    URLQueryItem(name: "folder", value: file)
                ]
            case .codespaces, .custom:
                // Append as path
                if !file.isEmpty {
                    components.path += "/" + file
                }
            }
        }
        
        return components.url
    }
    
    /// Open a specific file in the connected tunnel WebView
    func openRemoteFile(_ path: String) {
        currentRemoteFile = path
        guard let config = activeConfig,
              let url = buildTunnelURL(for: config, file: path) else { return }
        webViewURL = url
    }
    
    /// Open a workspace folder in the tunnel
    func openRemoteWorkspace(_ path: String) {
        remoteWorkspacePath = path
        guard let config = activeConfig,
              let url = buildTunnelURL(for: config, file: path) else { return }
        webViewURL = url
    }
    
    /// Execute a VS Code command via the WebView JS bridge
    func executeVSCodeCommand(_ command: String, args: [String: Any]? = nil, in webView: WKWebView) async -> Any? {
        let argsJSON: String
        if let args = args,
           let data = try? JSONSerialization.data(withJSONObject: args),
           let str = String(data: data, encoding: .utf8) {
            argsJSON = str
        } else {
            argsJSON = "{}"
        }
        
        let js = """
        (async () => {
            try {
                const vscode = acquireVsCodeApi ? acquireVsCodeApi() : null;
                if (vscode) {
                    return await vscode.postMessage({ command: '\(command)', args: \(argsJSON) });
                }
                // Fallback: use VS Code's command palette API if available
                if (typeof require !== 'undefined') {
                    const commands = require('vs/platform/commands/common/commands');
                    return await commands.CommandsRegistry.executeCommand('\(command)');
                }
                return null;
            } catch(e) {
                return { error: e.message };
            }
        })()
        """
        
        return try? await webView.evaluateJavaScript(js)
    }
    
    /// Get the current file content from VS Code WebView
    func getActiveEditorContent(from webView: WKWebView) async -> String? {
        let js = """
        (function() {
            try {
                const editor = document.querySelector('.monaco-editor');
                if (editor) {
                    const model = editor.__proto__?.getModel?.() || null;
                    if (model) return model.getValue();
                }
                // Fallback: try to get from textarea
                const textarea = document.querySelector('.inputarea');
                return textarea?.value || null;
            } catch(e) {
                return null;
            }
        })()
        """
        
        return try? await webView.evaluateJavaScript(js) as? String
    }
}

// MARK: - WKWebView Extension for Tunnel Bridge

extension WKWebView {
    /// Inject the native bridge script for communication between native app and VS Code WebView
    func injectTunnelBridge() {
        let bridgeScript = WKUserScript(
            source: """
            (function() {
                // Native bridge object
                window.CodePadBridge = {
                    isNative: true,
                    platform: 'iPadOS',
                    
                    // Send message to native app
                    postMessage: function(type, data) {
                        window.webkit.messageHandlers.tunnelBridge.postMessage({
                            type: type,
                            data: data || {}
                        });
                    },
                    
                    // Request file open in native editor
                    openInNativeEditor: function(path, content) {
                        this.postMessage('openNative', { path: path, content: content });
                    },
                    
                    // Notify native app of file changes
                    notifyFileChanged: function(path) {
                        this.postMessage('fileChanged', { path: path });
                    },
                    
                    // Request native file picker
                    requestFilePicker: function() {
                        this.postMessage('filePicker', {});
                    },
                    
                    // Sync theme with native app
                    syncTheme: function(theme) {
                        this.postMessage('themeSync', theme);
                    }
                };
                
                // Listen for messages from native app
                window.addEventListener('nativeBridge', function(event) {
                    const msg = event.detail;
                    if (msg.type === 'themeUpdate') {
                        document.documentElement.style.setProperty('--vscode-editor-background', msg.data.background);
                        document.documentElement.style.setProperty('--vscode-editor-foreground', msg.data.foreground);
                    }
                });
                
                console.log('[CodePad] Native bridge initialized');
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(bridgeScript)
    }
}
