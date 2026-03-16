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
        let scheme = portProtocol == .https ? "https" : "http"
        return "\(scheme)://localhost:\(port)"
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
            forwardedPorts.removeAll { $0.id == id }
            NotificationCenter.default.post(name: .portStopped, object: nil, userInfo: ["port": port.port])
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
    
    func stopForwarding(id: UUID) {
        guard let index = forwardedPorts.firstIndex(where: { $0.id == id }) else { return }
        forwardedPorts[index].isActive = false
    }
    
    func startForwarding(id: UUID) {
        guard let index = forwardedPorts.firstIndex(where: { $0.id == id }) else { return }
        forwardedPorts[index].isActive = true
    }
    
    func copyLocalAddress(id: UUID) {
        guard let port = forwardedPorts.first(where: { $0.id == id }) else { return }
        UIPasteboard.general.string = port.localURL
    }
}

// MARK: - Ports View

struct PortsView: View {
    @ObservedObject private var portManager = PortForwardingManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    
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
            
            Button(action: {}) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
            }
            .accessibilityLabel("Refresh ports")
            .accessibilityHint("Double tap to refresh the list of forwarded ports")
            
            Button(action: { portManager.forwardedPorts.removeAll() }) {
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
                        .foregroundColor(.green)
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
            
            Image(systemName: "network")
                .font(.system(size: 36))
                .foregroundColor(theme.editorForeground.opacity(0.2))
                .accessibilityHidden(true)
            
            VStack(spacing: 6) {
                Text("No Forwarded Ports")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.editorForeground.opacity(0.7))
                
                Text("Forward a port to access a running process\nfrom your local machine.")
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
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Actions
    
    private func addPort() {
        guard let portNumber = Int(newPortText), portNumber > 0, portNumber <= 65535 else { return }
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
    
    @ObservedObject private var portManager = PortForwardingManager.shared
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Status dot + Port number
            HStack(spacing: 6) {
                Circle()
                    .fill(port.isActive ? Color.green : Color.red)
                    .frame(width: 6, height: 6)
                    .accessibilityLabel(port.isActive ? "Active" : "Inactive")
                
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
            
            // Local Address
            Text(port.localURL)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.accentColor)
                .lineLimit(1)
                .frame(minWidth: 120, alignment: .leading)
            
            // Origin
            Text(port.origin.rawValue)
                .font(.system(size: 10))
                .foregroundColor(theme.comment)
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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovering ? theme.editorForeground.opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .contextMenu {
            Button(action: { portManager.copyLocalAddress(id: port.id) }) {
                Label("Copy Local Address", systemImage: "doc.on.doc")
            }
            
            Button(action: { UIPasteboard.general.string = "\(port.port)" }) {
                Label("Copy Port Number", systemImage: "number")
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
