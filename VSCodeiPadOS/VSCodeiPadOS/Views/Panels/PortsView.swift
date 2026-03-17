//
//  PortsView.swift
//  VSCodeiPadOS
//
//  Port Forwarding panel - VS Code-style Ports management.
//

import SwiftUI

// MARK: - Port Forwarding Manager

enum PortProtocol: String, CaseIterable, Identifiable {
    case http = "HTTP"
    case https = "HTTPS"
    case tcp = "TCP"
    
    var id: String { rawValue }
}

enum PortVisibility: String, CaseIterable, Identifiable {
    case privatePort = "Private"
    case publicPort = "Public"
    
    var id: String { rawValue }
}

enum PortOrigin: String {
    case user = "User Forwarded"
    case auto = "Auto Forwarded"
}

struct ForwardedPort: Identifiable, Equatable {
    let id = UUID()
    var port: Int
    var label: String
    var portProtocol: PortProtocol
    var localAddress: String
    var runningProcess: String
    var origin: PortOrigin
    var visibility: PortVisibility
    var isActive: Bool
    
    var localURL: String {
        switch portProtocol {
        case .https:
            return "https://localhost:\(port)"
        case .http:
            return "http://localhost:\(port)"
        case .tcp:
            return "tcp://localhost:\(port)"
        }
    }
    
    static func == (lhs: ForwardedPort, rhs: ForwardedPort) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class PortForwardingManager: ObservableObject {
    static let shared = PortForwardingManager()
    
    @Published var forwardedPorts: [ForwardedPort] = []
    @Published var isAutoForwardEnabled: Bool = true
    @Published var isScanning: Bool = false
    @Published var scanError: String? = nil
    
    private nonisolated(unsafe) var sshConnectObserver: NSObjectProtocol?
    
    init() {
        setupSSHConnectListener()
    }
    
    deinit {
        if let observer = sshConnectObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - SSH Connect Listener
    
    private func setupSSHConnectListener() {
        sshConnectObserver = NotificationCenter.default.addObserver(
            forName: .sshDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.scanRemotePorts()
            }
        }
    }
    
    // MARK: - Port Management
    
    func addPort(_ port: Int, label: String = "", protocol proto: PortProtocol = .http, visibility: PortVisibility = .privatePort) {
        let newPort = ForwardedPort(
            port: port,
            label: label.isEmpty ? "Port \(port)" : label,
            portProtocol: proto,
            localAddress: "localhost:\(port)",
            runningProcess: "",
            origin: .user,
            visibility: visibility,
            isActive: true
        )
        forwardedPorts.append(newPort)
        NotificationCenter.default.post(name: .portForwarded, object: nil, userInfo: ["port": port])
    }
    
    func removePort(id: UUID) {
        if let port = forwardedPorts.first(where: { $0.id == id }) {
            // If user port was active, tear down the real SSH tunnel
            if port.isActive && port.origin == .user {
                Task {
                    try? await SSHManager.shared.cancelPortForward(localPort: port.port)
                }
            }
            forwardedPorts.removeAll { $0.id == id }
            NotificationCenter.default.post(name: .portStopped, object: nil, userInfo: ["port": port.port])
        }
    }
    /// Removes all forwarded ports, sending per-port stop notifications for each.
    func removeAllPorts() {
        // Iterate over a snapshot of IDs so we can safely mutate the array.
        let allIDs = forwardedPorts.map { $0.id }
        for id in allIDs {
            removePort(id: id)
        }
    }
    
    func toggleVisibility(id: UUID) {
        guard let index = forwardedPorts.firstIndex(where: { $0.id == id }) else { return }
        forwardedPorts[index].visibility = forwardedPorts[index].visibility == .privatePort ? .publicPort : .privatePort
    }
    
    func changeProtocol(id: UUID, to proto: PortProtocol) {
        guard let index = forwardedPorts.firstIndex(where: { $0.id == id }) else { return }
        forwardedPorts[index].portProtocol = proto
    }
    
    /// Stop forwarding a port by tearing down the real SSH tunnel.
    func stopForwarding(id: UUID) {
        guard let index = forwardedPorts.firstIndex(where: { $0.id == id }) else { return }
        let port = forwardedPorts[index]
        forwardedPorts[index].isActive = false
        
        guard port.origin == .user else { return }
        
        Task { @MainActor in
            do {
                try await SSHManager.shared.cancelPortForward(localPort: port.port)
            } catch {
                // Log but don't crash — tunnel may already be gone
                AppLogger.ssh.debug("PortForwardingManager: failed to cancel tunnel for port \(port.port): \(error.localizedDescription)")
            }
        }
    }
    
    /// Start forwarding a port by establishing a real SSH tunnel via direct-tcpip.
    func startForwarding(id: UUID) {
        guard let index = forwardedPorts.firstIndex(where: { $0.id == id }) else { return }
        let port = forwardedPorts[index]
        
        guard port.origin == .user else { return }
        
        Task { @MainActor [weak self] in
            do {
                try await SSHManager.shared.setupPortForward(
                    localPort: port.port,
                    remoteHost: "localhost",
                    remotePort: port.port
                )
                self?.forwardedPorts[index].isActive = true
            } catch SSHClientError.portForwardFailed(let reason) {
                self?.forwardedPorts[index].isActive = false
                self?.scanError = reason
            } catch SSHClientError.notConnected {
                self?.forwardedPorts[index].isActive = false
                self?.scanError = "Cannot forward port \(port.port): not connected to SSH server"
            } catch {
                self?.forwardedPorts[index].isActive = false
                self?.scanError = "Failed to forward port \(port.port): \(error.localizedDescription)"
            }
        }
    }
    
    func copyLocalAddress(id: UUID) {
        guard let port = forwardedPorts.first(where: { $0.id == id }) else { return }
        UIPasteboard.general.string = port.localURL
    }
    
    // MARK: - Remote Port Scanning
    
    /// Scans the remote host for listening ports via SSH and adds them as auto-detected ports
    func scanRemotePorts() {
        guard !isScanning else { return }
        
        Task { @MainActor in
            await performPortScan()
        }
    }
    
    private func performPortScan() async {
        guard SSHManager.shared.isConnected else {
            // Not connected - nothing to scan
            return
        }
        
        scanError = nil
        isScanning = true
        
        do {
            // Run ss or netstat to find listening ports
            let command = "ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null"
            let result = try await SSHManager.shared.executeCommand(command, timeout: 15)
            
            if result.isSuccess {
                let detectedPorts = parsePortScanOutput(result.stdout)
                updatePortsWithScanResults(detectedPorts)
            }
        } catch {
            scanError = "Port scan failed: \(error.localizedDescription)"
        }
        
        isScanning = false
    }
    
    /// Parses the output of ss -tlnp or netstat -tlnp
    private func parsePortScanOutput(_ output: String) -> [(port: Int, process: String)] {
        var ports: [(port: Int, process: String)] = []
        let lines = output.components(separatedBy: "\n")
        
        for line in lines {
            // Skip header lines
            if line.contains("State") || line.contains("Proto") || line.isEmpty {
                continue
            }
            
            // Extract port from address patterns like:
            // ss:    LISTEN  0  128  0.0.0.0:3000  0.0.0.0:*  users:(("node",pid=1234,fd=3))
            // ss:    LISTEN  0  128  [::]:8080     [::]:*      users:(("nginx",pid=5678,fd=6))
            // netstat: tcp  0  0 0.0.0.0:3000  0.0.0.0:*  LISTEN  1234/node
            
            var portNumber: Int?
            var processName: String = "unknown"
            
            // Try to find port in format like "0.0.0.0:3000" or "[::]:8080" or "*:80"
            // Regex to match :PORT pattern at word boundary
            let portPattern = #"[:\[](\d{1,5})(?:\]|(?!\d))"#
            if let portRange = line.range(of: portPattern, options: .regularExpression) {
                let portStr = String(line[portRange])
                    .replacingOccurrences(of: ":", with: "")
                    .replacingOccurrences(of: "[", with: "")
                    .replacingOccurrences(of: "]", with: "")
                portNumber = Int(portStr)
            }
            
            // Extract process name
            // ss format: users:(("processname",pid=...
            if let usersRange = line.range(of: #"users:\(\(\"([^\"]+)\""#, options: .regularExpression) {
                let usersPart = String(line[usersRange])
                if let nameStart = usersPart.range(of: #"\""#),
                   let nameEnd = usersPart.range(of: #"\","#, range: nameStart.upperBound..<usersPart.endIndex) {
                    processName = String(usersPart[nameStart.upperBound..<nameEnd.lowerBound])
                }
            }
            // netstat format: PID/processname
            else if let pidRange = line.range(of: #"\d+/([\w/-]+)"#, options: .regularExpression) {
                let pidPart = String(line[pidRange])
                if let slashIdx = pidPart.firstIndex(of: "/") {
                    processName = String(pidPart[pidPart.index(after: slashIdx)...])
                }
            }
            
            if let port = portNumber, port > 0 && port <= 65535 {
                // Avoid duplicates
                if !ports.contains(where: { $0.port == port }) {
                    ports.append((port: port, process: processName))
                }
            }
        }
        
        return ports.sorted { $0.port < $1.port }
    }
    
    /// Updates the forwardedPorts list with scan results
    private func updatePortsWithScanResults(_ detectedPorts: [(port: Int, process: String)]) {
        // Get existing user-added ports (preserve these)
        let userPorts = forwardedPorts.filter { $0.origin == .user }
        
        // Get existing auto-detected ports for comparison
        let existingAutoPorts = forwardedPorts.filter { $0.origin == .auto }
        
        // Create new auto-detected ports
        var newAutoPorts: [ForwardedPort] = []
        for detected in detectedPorts {
            // Don't add if user already added this port
            if userPorts.contains(where: { $0.port == detected.port }) {
                continue
            }
            
            // Check if we already have this as an auto port
            if let existing = existingAutoPorts.first(where: { $0.port == detected.port }) {
                // Keep the existing one but update process name if we got a better one
                var updatedPort = existing
                if !detected.process.isEmpty && detected.process != "unknown" {
                    updatedPort.runningProcess = detected.process
                }
                newAutoPorts.append(updatedPort)
            } else {
                // Create new auto-detected port
                let newPort = ForwardedPort(
                    port: detected.port,
                    label: detected.process.isEmpty ? "Port \(detected.port)" : detected.process,
                    portProtocol: .http, // Default to HTTP
                    localAddress: "localhost:\(detected.port)",
                    runningProcess: detected.process,
                    origin: .auto,
                    visibility: .privatePort,
                    isActive: true
                )
                newAutoPorts.append(newPort)
            }
        }
        
        // Combine user ports with new auto-detected ports
        forwardedPorts = userPorts + newAutoPorts
    }
}

// MARK: - Ports View

struct PortsView: View {
    @StateObject private var portManager = PortForwardingManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var showAddPort = false
    @State private var newPortText = ""
    @State private var newPortLabel = ""
    @State private var newPortProtocol: PortProtocol = .http
    
    private var theme: Theme { themeManager.currentTheme }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider()
                .background(theme.editorForeground.opacity(0.15))
            
            if portManager.forwardedPorts.isEmpty && !showAddPort {
                emptyState
            } else {
                portList
            }
        }
        .background(theme.editorBackground)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Ports panel")
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(spacing: 10) {
            Text("PORTS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(theme.tabActiveForeground)
            
            if !portManager.forwardedPorts.isEmpty {
                Text("\(portManager.forwardedPorts.count)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(theme.editorBackground)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(theme.tabActiveForeground.opacity(0.7))
                    .cornerRadius(4)
                    .accessibilityLabel("\(portManager.forwardedPorts.count) forwarded ports")
            }
            
            Spacer()
            
            Button(action: { withAnimation(.easeInOut(duration: 0.15)) { showAddPort.toggle() } }) {
                Image(systemName: "plus")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
            }
            .accessibilityLabel("Add port")
            .accessibilityHint("Double tap to add a new forwarded port")
            
            // Refresh button with tooltip and loading state
            Group {
                if portManager.isScanning {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 16, height: 16)
                        .accessibilityLabel("Scanning ports")
                } else {
                    Button(action: { portManager.scanRemotePorts() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                            .foregroundColor(SSHManager.shared.isConnected ? theme.comment : theme.comment.opacity(0.4))
                    }
                    .accessibilityLabel("Refresh ports")
                    .accessibilityHint(SSHManager.shared.isConnected ? "Double tap to scan remote ports" : "Connect via SSH to scan remote ports")
                    .help(SSHManager.shared.isConnected ? "Scan remote ports" : "Connect via SSH to scan remote ports")
                    .disabled(!SSHManager.shared.isConnected)
                }
            }
            .frame(width: 24, height: 24)
            
            Button(action: { portManager.removeAllPorts() }) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
            }
            .disabled(portManager.forwardedPorts.isEmpty)
            .accessibilityLabel("Remove all ports")
            .accessibilityHint("Double tap to stop forwarding all ports")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(theme.tabBarBackground)
    }
    
    // MARK: - Add Port Section
    
    private var addPortSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "network")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
                    .accessibilityHidden(true)
                
                TextField("Port number (e.g. 3000)", text: $newPortText)
                    .font(.system(size: 12, design: .monospaced))
                    .textFieldStyle(.plain)
                    .keyboardType(.numberPad)
                    .foregroundColor(theme.editorForeground)
                    .accessibilityLabel("Port number")
                
                Picker("Protocol", selection: $newPortProtocol) {
                    ForEach(PortProtocol.allCases) { proto in
                        Text(proto.rawValue).tag(proto)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(size: 11))
                .accessibilityLabel("Port protocol")
                
                Button(action: addPort) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(UIColor.systemGreen))
                }
                .disabled(Int(newPortText) == nil)
                .accessibilityLabel("Confirm add port")
                .accessibilityHint("Double tap to forward this port")
                
                Button(action: { showAddPort = false; newPortText = ""; newPortLabel = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(theme.comment)
                }
                .accessibilityLabel("Cancel")
                .accessibilityHint("Double tap to cancel adding a port")
            }
            
            TextField("Label (optional)", text: $newPortLabel)
                .font(.system(size: 11))
                .textFieldStyle(.plain)
                .foregroundColor(theme.editorForeground)
                .accessibilityLabel("Port label")
        }
        .padding(10)
        .background(theme.selection.opacity(0.3))
    }
    
    // MARK: - Port List
    
    private var portList: some View {
        ScrollView {
            VStack(spacing: 0) {
                if showAddPort {
                    addPortSection
                    Divider()
                        .background(theme.editorForeground.opacity(0.1))
                }
                
                // Table header
                HStack(spacing: 0) {
                    Text("Port")
                        .frame(width: 70, alignment: .leading)
                    Text("Protocol")
                        .frame(width: 65, alignment: .leading)
                    Text("Local Address")
                        .frame(minWidth: 120, alignment: .leading)
                    Text("Origin")
                        .frame(width: 100, alignment: .leading)
                    Text("Visibility")
                        .frame(width: 70, alignment: .leading)
                    Spacer()
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(theme.comment)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(theme.tabBarBackground)
                .accessibilityHidden(true)
                
                ForEach(portManager.forwardedPorts) { port in
                    PortRowView(port: port, theme: theme)
                    
                    Divider()
                        .background(theme.editorForeground.opacity(0.08))
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            if portManager.isScanning {
                // Show loading state when scanning
                ProgressView()
                    .scaleEffect(1.2)
                    .padding()
                
                Text("Scanning remote ports...")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
            } else {
                Image(systemName: "network")
                    .font(.system(size: 36))
                    .foregroundColor(theme.editorForeground.opacity(0.2))
                    .accessibilityHidden(true)
                
                VStack(spacing: 6) {
                    Text("No Forwarded Ports")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.editorForeground.opacity(0.7))
                    
                    Text("Detect listening ports on a remote server\nor track ports for your project.")
                        .font(.system(size: 12))
                        .foregroundColor(theme.comment)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: { withAnimation { showAddPort = true } }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Forward a Port")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(6)
                }
                .accessibilityLabel("Forward a port")
                .accessibilityHint("Double tap to forward a new port")
                
                // Show scan button if SSH is connected
                if SSHManager.shared.isConnected {
                    Button(action: { portManager.scanRemotePorts() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                            Text("Scan Remote Ports")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(theme.comment)
                    }
                    .accessibilityLabel("Scan remote ports")
                    .accessibilityHint("Double tap to detect listening ports on the remote host")
                }
            }
            // Display scan error if present
            if let scanError = portManager.scanError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(UIColor.systemYellow))
                    Text(scanError)
                        .font(.system(size: 11))
                        .foregroundColor(Color(UIColor.systemYellow))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 12)
                Button("Dismiss") {
                    portManager.scanError = nil
                }
                .font(.system(size: 11))
                .foregroundColor(theme.comment)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Actions
    
    private func addPort() {
        guard let portNumber = Int(newPortText), portNumber > 0, portNumber <= 65535 else { return }
        portManager.scanError = nil
        portManager.addPort(portNumber, label: newPortLabel, protocol: newPortProtocol)
        newPortText = ""
        newPortLabel = ""
        showAddPort = false
    }
}

// MARK: - Port Row View

struct PortRowView: View {
    let port: ForwardedPort
    let theme: Theme
    
    @StateObject private var portManager = PortForwardingManager.shared
    
    var body: some View {
        HStack(spacing: 0) {
            // Status dot + Port number
            HStack(spacing: 6) {
                Circle()
                    .fill(port.origin == .auto ? Color(UIColor.systemOrange) : (port.isActive ? Color(UIColor.systemGreen) : Color(UIColor.systemRed)))
                    .frame(width: 6, height: 6)
                    .accessibilityLabel(port.origin == .auto ? "Detected" : (port.isActive ? "Active" : "Inactive"))
                
                Text("\(port.port)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(theme.editorForeground)
            }
            .frame(width: 70, alignment: .leading)
            
            // Protocol
            Text(port.portProtocol.rawValue)
                .font(.system(size: 11))
                .foregroundColor(theme.comment)
                .frame(width: 65, alignment: .leading)
            
            // Local Address / Status
            if port.origin == .auto {
                Text("Detected on remote")
                    .font(.system(size: 11))
                    .foregroundColor(theme.comment.opacity(0.7))
                    .italic()
                    .lineLimit(1)
                    .frame(minWidth: 120, alignment: .leading)
            } else {
                Text(port.localURL)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.accentColor)
                    .lineLimit(1)
                    .frame(minWidth: 120, alignment: .leading)
            }
            
            // Origin
            Text(port.origin.rawValue)
                .font(.system(size: 10))
                .foregroundColor(port.origin == .auto ? theme.comment.opacity(0.7) : theme.comment)
                .frame(width: 100, alignment: .leading)
            
            // Visibility
            HStack(spacing: 3) {
                Image(systemName: port.visibility == .privatePort ? "lock.fill" : "globe")
                    .font(.system(size: 9))
                Text(port.visibility.rawValue)
                    .font(.system(size: 10))
            }
            .foregroundColor(port.visibility == .publicPort ? .orange : theme.comment)
            .frame(width: 70, alignment: .leading)
            
            Spacer()
            
            // Inline action buttons
            HStack(spacing: 8) {
                // Play/Stop button
                Button {
                    if port.isActive {
                        portManager.stopForwarding(id: port.id)
                    } else {
                        Task {
                            portManager.startForwarding(id: port.id)
                        }
                    }
                } label: {
                    Image(systemName: port.isActive ? "stop.fill" : "play.fill")
                        .foregroundColor(port.isActive ? .red : .green)
                        .font(.caption)
                }
                
                // Copy button
                Button {
                    portManager.copyLocalAddress(id: port.id)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
                
                // Delete button
                Button(role: .destructive) {
                    portManager.removePort(id: port.id)
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                if port.origin == .auto {
                    UIPasteboard.general.string = "\(port.port)"
                } else {
                    portManager.copyLocalAddress(id: port.id)
                }
            }) {
                Label(port.origin == .auto ? "Copy Port Number" : "Copy Local Address", systemImage: "doc.on.doc")
            }
            
            Button(action: { UIPasteboard.general.string = "\(port.port)" }) {
                Label("Copy Port Number", systemImage: "number")
            }
            
            // Show process name if available
            if !port.runningProcess.isEmpty {
                Divider()
                
                Text("Process: \(port.runningProcess)")
                    .font(.system(size: 10))
                    .foregroundColor(theme.comment)
            }
            
            Divider()
            
            Button(action: { portManager.toggleVisibility(id: port.id) }) {
                Label(
                    port.visibility == .privatePort ? "Make Public" : "Make Private",
                    systemImage: port.visibility == .privatePort ? "globe" : "lock.fill"
                )
            }
            
            Menu("Change Protocol") {
                ForEach(PortProtocol.allCases) { proto in
                    Button(action: { portManager.changeProtocol(id: port.id, to: proto) }) {
                        HStack {
                            Text(proto.rawValue)
                            if port.portProtocol == proto {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            if port.isActive {
                Button(action: { portManager.stopForwarding(id: port.id) }) {
                    Label("Stop Forwarding", systemImage: "stop.circle")
                }
            } else {
                Button(action: { portManager.startForwarding(id: port.id) }) {
                    Label("Start Forwarding", systemImage: "play.circle")
                }
            }
            
            Button(role: .destructive, action: { portManager.removePort(id: port.id) }) {
                Label("Remove Port", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Port \(port.port), \(port.portProtocol.rawValue), \(port.isActive ? "active" : "inactive"), \(port.visibility.rawValue)")
        .accessibilityHint("Long press for options")
    }
}

// MARK: - Preview

#Preview {
    PortsView()
        .frame(height: 400)
}
