//
//  SSHTunnelBridge.swift
//  VSCodeiPadOS
//
//  Bridges SSH connections with VS Code tunnel/code-server.
//  Enables: SSH → detect/start code tunnel → get URL → open in WebView
//  Also supports: SSH → port forward to code-server → open localhost in WebView
//

import Foundation
import Combine
import os

// MARK: - Bridge State

enum SSHTunnelBridgeState: Equatable {
    case idle
    case connecting
    case checkingRemote
    case startingTunnel
    case portForwarding
    case ready(url: URL)
    case error(String)
    
    static func == (lhs: SSHTunnelBridgeState, rhs: SSHTunnelBridgeState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.connecting, .connecting),
             (.checkingRemote, .checkingRemote), (.startingTunnel, .startingTunnel),
             (.portForwarding, .portForwarding):
            return true
        case (.ready(let a), .ready(let b)):
            return a == b
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
    
    var isActive: Bool {
        switch self {
        case .connecting, .checkingRemote, .startingTunnel, .portForwarding, .ready:
            return true
        default:
            return false
        }
    }
    
    var statusDescription: String {
        switch self {
        case .idle: return "Disconnected"
        case .connecting: return "Connecting via SSH…"
        case .checkingRemote: return "Checking remote environment…"
        case .startingTunnel: return "Starting VS Code tunnel…"
        case .portForwarding: return "Setting up port forwarding…"
        case .ready(let url): return "Connected: \(url.host ?? url.absoluteString)"
        case .error(let msg): return "Error: \(msg)"
        }
    }
}

// MARK: - SSH Tunnel Bridge

@MainActor
final class SSHTunnelBridge: ObservableObject {
    static let shared = SSHTunnelBridge()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "SSHTunnelBridge")
    
    @Published var bridgeState: SSHTunnelBridgeState = .idle
    @Published var tunnelURL: URL?
    @Published var activeSSHConfig: SSHConnectionConfig?
    @Published var remoteLog: [String] = []
    
    private var connectionTask: Task<Void, Never>?
    private var localForwardPort: Int?
    private let sshManager = SSHManager.shared
    private let tunnelManager = TunnelManager.shared
    
    // Tunnel detection patterns — use try? to avoid crash if regex is ever rejected
    private let tunnelURLPattern: NSRegularExpression? = try? NSRegularExpression(
        pattern: "https://[a-zA-Z0-9_-]+\\.vscode\\.dev[^\\s]*",
        options: []
    )
    private let codeServerURLPattern: NSRegularExpression? = try? NSRegularExpression(
        pattern: "https?://[^\\s]+:\\d+",
        options: []
    )
    
    private init() {}
    
    // MARK: - Connect via VS Code Tunnel
    
    /// Connect to a remote machine via SSH, detect or start `code tunnel`,
    /// and return the tunnel URL for the WebView.
    func connectViaTunnel(sshConfig: SSHConnectionConfig) {
        connectionTask?.cancel()
        activeSSHConfig = sshConfig
        remoteLog = []
        
        connectionTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                // Step 1: Connect via SSH
                self.bridgeState = .connecting
                self.appendLog("Connecting to \(sshConfig.host):\(sshConfig.port)...")
                
                try await self.sshManager.connect(config: sshConfig)
                self.appendLog("SSH connection established.")
                
                try Task.checkCancellation()
                
                // Step 2: Check if code tunnel is already running
                self.bridgeState = .checkingRemote
                self.appendLog("Checking for running VS Code tunnel...")
                
                let checkResult = try await self.sshManager.executeCommand(
                    "pgrep -f 'code.*tunnel' && echo TUNNEL_RUNNING || echo TUNNEL_NOT_RUNNING"
                )
                
                try Task.checkCancellation()
                
                if checkResult.stdout.contains("TUNNEL_RUNNING") {
                    self.appendLog("VS Code tunnel is already running.")
                    // Try to get the tunnel URL from the running process
                    let urlResult = try await self.sshManager.executeCommand(
                        "code tunnel status 2>/dev/null || cat ~/.vscode-server/data/Machine/.tunnel-url 2>/dev/null || echo NO_URL"
                    )
                    
                    if let url = self.extractTunnelURL(from: urlResult.stdout) {
                        self.appendLog("Found tunnel URL: \(url.absoluteString)")
                        self.tunnelURL = url
                        self.bridgeState = .ready(url: url)
                        self.openInTunnelManager(url: url, name: sshConfig.name)
                        return
                    }
                }
                
                // Step 3: Check if VS Code CLI is available
                self.appendLog("Checking VS Code CLI availability...")
                let codeCheck = try await self.sshManager.executeCommand(
                    "which code 2>/dev/null || which code-tunnel 2>/dev/null || echo NOT_FOUND"
                )
                
                let hasCodeCLI = !codeCheck.stdout.contains("NOT_FOUND")
                
                if !hasCodeCLI {
                    // Detect remote OS/architecture for correct CLI binary
                    let archResult = try await self.sshManager.executeCommand("uname -m")
                    let arch = archResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                    let platform: String
                    switch arch {
                    case "x86_64", "amd64": platform = "cli-alpine-x64"
                    case "aarch64", "arm64": platform = "cli-alpine-arm64"
                    default: platform = "cli-linux-x64"
                    }
                    
                    // Try to install the CLI
                    self.appendLog("VS Code CLI not found. Installing for \(arch) (\(platform))...")
                    let installResult = try await self.sshManager.executeCommand(
                        "curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=\(platform)' -o /tmp/vscode_cli.tar.gz && tar -xf /tmp/vscode_cli.tar.gz -C /tmp && chmod +x /tmp/code && echo INSTALL_OK || echo INSTALL_FAIL"
                    )
                    
                    if installResult.stdout.contains("INSTALL_FAIL") {
                        throw SSHTunnelBridgeError.codeCliNotFound
                    }
                    self.appendLog("VS Code CLI installed to /tmp/code")
                }
                
                try Task.checkCancellation()
                
                // Step 4: Start the tunnel
                self.bridgeState = .startingTunnel
                self.appendLog("Starting VS Code tunnel...")
                
                let codeBin = hasCodeCLI ? "code" : "/tmp/code"
                let tunnelCmd = "\(codeBin) tunnel --accept-server-license-terms > /tmp/vscode-tunnel.log 2>&1 &"
                let startResult = try await self.sshManager.executeCommand(tunnelCmd)
                self.appendLog("Tunnel start command sent.")
                
                // Step 5: Wait for tunnel URL to appear (poll for up to 30 seconds)
                self.appendLog("Waiting for tunnel URL...")
                var tunnelFoundURL: URL?
                
                for attempt in 1...15 {
                    try Task.checkCancellation()
                    try await Task.sleep(nanoseconds: 2_000_000_000)  // 2 seconds
                    
                    let statusResult = try await self.sshManager.executeCommand(
                        "\(codeBin) tunnel status 2>/dev/null; cat ~/.vscode-server/data/Machine/.tunnel-url 2>/dev/null; echo ''"
                    )
                    
                    if let url = self.extractTunnelURL(from: statusResult.stdout) {
                        tunnelFoundURL = url
                        break
                    }
                    
                    // Also check process output
                    let logResult = try await self.sshManager.executeCommand(
                        "cat /tmp/vscode-tunnel.log 2>/dev/null || echo ''"
                    )
                    if let url = self.extractTunnelURL(from: logResult.stdout) {
                        tunnelFoundURL = url
                        break
                    }
                    
                    self.appendLog("Waiting... (attempt \(attempt)/15)")
                }
                
                guard let finalURL = tunnelFoundURL else {
                    throw SSHTunnelBridgeError.tunnelURLNotFound
                }
                
                self.appendLog("Tunnel ready: \(finalURL.absoluteString)")
                self.tunnelURL = finalURL
                self.bridgeState = .ready(url: finalURL)
                self.openInTunnelManager(url: finalURL, name: sshConfig.name)
                
            } catch is CancellationError {
                Self.logger.info("SSH tunnel connection cancelled")
                self.bridgeState = .idle
            } catch {
                let msg = error.localizedDescription
                Self.logger.error("SSH tunnel bridge error: \(msg)")
                self.appendLog("Error: \(msg)")
                self.bridgeState = .error(msg)
                // Propagate error to TunnelManager so UI shows failure
                await MainActor.run {
                    TunnelManager.shared.connectionState = .error(msg)
                    TunnelManager.shared.lastError = msg
                }
            }
        }
    }
    
    // MARK: - Connect via Port Forward
    
    /// Connect to a remote code-server via SSH port forwarding.
    /// Forwards a local port to the remote code-server port.
    func connectViaPortForward(
        sshConfig: SSHConnectionConfig,
        remotePort: Int = 8080,
        localPort: Int? = nil
    ) {
        connectionTask?.cancel()
        activeSSHConfig = sshConfig
        remoteLog = []
        
        connectionTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                // Step 1: Connect via SSH
                self.bridgeState = .connecting
                self.appendLog("Connecting to \(sshConfig.host):\(sshConfig.port)...")
                
                try await self.sshManager.connect(config: sshConfig)
                self.appendLog("SSH connection established.")
                
                try Task.checkCancellation()
                
                // Step 2: Verify remote port is open
                self.bridgeState = .checkingRemote
                self.appendLog("Checking remote port \(remotePort)...")
                
                let portCheck = try await self.sshManager.executeCommand(
                    "ss -tlnp 2>/dev/null | grep :\(remotePort) || netstat -tlnp 2>/dev/null | grep :\(remotePort) || echo PORT_NOT_FOUND"
                )
                
                if portCheck.stdout.contains("PORT_NOT_FOUND") {
                    self.appendLog("Warning: Remote port \(remotePort) does not appear to be listening.")
                }
                
                try Task.checkCancellation()
                
                // Step 3: Set up local port forwarding
                self.bridgeState = .portForwarding
                let effectiveLocalPort = localPort ?? (49152 + Int.random(in: 0...16383))
                self.localForwardPort = effectiveLocalPort
                self.appendLog("Forwarding localhost:\(effectiveLocalPort) → \(sshConfig.host):\(remotePort)...")
                
                try await self.sshManager.setupPortForward(
                    localPort: effectiveLocalPort,
                    remoteHost: "127.0.0.1",
                    remotePort: remotePort
                )
                
                self.appendLog("Port forwarding established.")
                
                // Step 4: Create local URL
                let localURL = URL(string: "http://localhost:\(effectiveLocalPort)")!
                self.tunnelURL = localURL
                self.bridgeState = .ready(url: localURL)
                self.appendLog("Ready: \(localURL.absoluteString)")
                
                self.openInTunnelManager(url: localURL, name: "\(sshConfig.name) (Port Forward)")
                
            } catch is CancellationError {
                Self.logger.info("Port forward connection cancelled")
                self.bridgeState = .idle
            } catch {
                let msg = error.localizedDescription
                Self.logger.error("Port forward error: \(msg)")
                self.appendLog("Error: \(msg)")
                self.bridgeState = .error(msg)
                // Propagate error to TunnelManager so UI shows failure
                await MainActor.run {
                    TunnelManager.shared.connectionState = .error(msg)
                    TunnelManager.shared.lastError = msg
                }
            }
        }
    }
    
    // MARK: - Disconnect
    
    func disconnect() {
        connectionTask?.cancel()
        connectionTask = nil
        
        // Stop any port forwarding
        if let port = localForwardPort {
            Task {
                try? await sshManager.cancelPortForward(localPort: port)
            }
            localForwardPort = nil
        }
        
        // Disconnect SSH
        Task {
            try? await sshManager.disconnect()
        }
        
        tunnelURL = nil
        activeSSHConfig = nil
        bridgeState = .idle
        appendLog("Disconnected.")
    }
    
    // MARK: - Remote Tunnel Management
    
    /// Stop the running VS Code tunnel on the remote machine
    func stopRemoteTunnel() async {
        guard activeSSHConfig != nil else { return }
        do {
            let _ = try await sshManager.executeCommand("pkill -f 'code.*tunnel' 2>/dev/null; echo STOPPED")
            appendLog("Remote tunnel stopped.")
        } catch {
            appendLog("Failed to stop remote tunnel: \(error.localizedDescription)")
        }
    }
    
    /// Get status of remote VS Code tunnel
    func checkRemoteTunnelStatus() async -> Bool {
        guard activeSSHConfig != nil else { return false }
        do {
            let result = try await sshManager.executeCommand("pgrep -f 'code.*tunnel' && echo RUNNING || echo STOPPED")
            return result.stdout.contains("RUNNING")
        } catch {
            return false
        }
    }
    
    // MARK: - Helpers
    
    private func extractTunnelURL(from output: String) -> URL? {
        // Try vscode.dev tunnel URL pattern
        let range = NSRange(output.startIndex..., in: output)
        if let pattern = tunnelURLPattern,
           let match = pattern.firstMatch(in: output, options: [], range: range) {
            let urlString = (output as NSString).substring(with: match.range)
            return URL(string: urlString)
        }
        
        // Try code-server URL pattern
        if let pattern = codeServerURLPattern,
           let match = pattern.firstMatch(in: output, options: [], range: range) {
            let urlString = (output as NSString).substring(with: match.range)
            return URL(string: urlString)
        }
        
        return nil
    }
    
    private func openInTunnelManager(url: URL, name: String) {
        let config = TunnelConfig(
            name: name,
            url: url.absoluteString,
            type: .sshTunnel,
            lastUsed: Date(),
            tunnelMode: .webview
        )
        tunnelManager.connectFromBridge(config: config, resolvedURL: url)
    }
    
    private func appendLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        remoteLog.append("[\(timestamp)] \(message)")
        Self.logger.info("\(message)")
    }
}

// MARK: - Bridge Errors

enum SSHTunnelBridgeError: Error, LocalizedError {
    case codeCliNotFound
    case tunnelURLNotFound
    case portNotListening(Int)
    case sshNotConnected
    
    var errorDescription: String? {
        switch self {
        case .codeCliNotFound:
            return "VS Code CLI ('code') not found on remote machine. Install VS Code or use port forwarding instead."
        case .tunnelURLNotFound:
            return "Could not detect tunnel URL after 30 seconds. The tunnel may still be starting — check remote logs."
        case .portNotListening(let port):
            return "Remote port \(port) is not listening. Ensure your code-server or VS Code server is running."
        case .sshNotConnected:
            return "SSH connection is not established."
        }
    }
}
