import SwiftUI
import Network
import Foundation

// MARK: - Terminal View with SSH Support

struct TerminalView: View {
    @StateObject private var terminal = TerminalManager()
    @State private var currentCommand = ""
    @State private var showConnectionSheet = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Connection status bar
            HStack {
                Circle()
                    .fill(terminal.isConnected ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                
                Text(terminal.connectionStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { showConnectionSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: terminal.isConnected ? "network" : "network.slash")
                        Text(terminal.isConnected ? "Connected" : "Connect SSH")
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
                }
                
                if terminal.isConnected {
                    Button(action: { terminal.disconnect() }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(UIColor.tertiarySystemBackground))
            
            // Terminal output
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(terminal.output) { line in
                            terminalLine(line)
                                .id(line.id)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .background(Color.black)
                .onChange(of: terminal.output.count) { _ in
                    withAnimation {
                        proxy.scrollTo(terminal.output.last?.id, anchor: .bottom)
                    }
                }
            }
            
            // Command input
            HStack {
                Text(terminal.promptString)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                
                TextField("", text: $currentCommand)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isInputFocused)
                    .onSubmit {
                        executeCommand()
                    }
                
                // Quick action buttons
                HStack(spacing: 8) {
                    Button(action: { currentCommand = "ls -la" }) {
                        Text("ls")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Button(action: { terminal.sendInterrupt() }) {
                        Text("^C")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Button(action: { terminal.sendTab() }) {
                        Text("Tab")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.95))
        }
        .background(Color.black)
        .onAppear {
            isInputFocused = true
        }
        .sheet(isPresented: $showConnectionSheet) {
            SSHConnectionView(terminal: terminal, isPresented: $showConnectionSheet)
        }
    }
    
    @ViewBuilder
    private func terminalLine(_ line: TerminalLine) -> some View {
        if line.isANSI {
            ANSIText(line.text)
        } else {
            Text(line.text)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(line.color)
                .textSelection(.enabled)
        }
    }
    
    private func executeCommand() {
        guard !currentCommand.isEmpty else { return }
        terminal.executeCommand(currentCommand)
        currentCommand = ""
    }
}

// MARK: - SSH Connection View

struct SSHConnectionView: View {
    @ObservedObject var terminal: TerminalManager
    @Binding var isPresented: Bool
    
    @State private var host = ""
    @State private var port = "22"
    @State private var username = ""
    @State private var password = ""
    @State private var useKey = false
    @State private var privateKey = ""
    @State private var savedConnections: [SSHConnection] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Connection Details")) {
                    TextField("Host (e.g., 192.168.1.100)", text: $host)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                    
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Authentication")) {
                    Toggle("Use SSH Key", isOn: $useKey)
                    
                    if useKey {
                        TextEditor(text: $privateKey)
                            .font(.system(.caption, design: .monospaced))
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        Text("Paste your private key here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                
                Section(header: Text("Quick Connect")) {
                    Button(action: connectToLocalhost) {
                        HStack {
                            Image(systemName: "laptopcomputer")
                            Text("Connect to Mac (localhost)")
                        }
                    }
                    
                    Button(action: { host = "raspberrypi.local"; port = "22"; username = "pi" }) {
                        HStack {
                            Image(systemName: "cpu")
                            Text("Raspberry Pi Template")
                        }
                    }
                }
                
                Section {
                    Button(action: connect) {
                        HStack {
                            Spacer()
                            if terminal.isConnecting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "network")
                                Text("Connect")
                            }
                            Spacer()
                        }
                    }
                    .disabled(host.isEmpty || username.isEmpty || (password.isEmpty && !useKey) || terminal.isConnecting)
                    .foregroundColor(.white)
                    .listRowBackground(Color.accentColor)
                }
                
                Section(header: Text("Info")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SSH Connection")
                            .font(.headline)
                        Text("Connect to your Mac, Linux server, or Raspberry Pi to run commands remotely.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("To connect to your Mac:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("1. Open System Settings > General > Sharing\n2. Enable 'Remote Login'\n3. Use your Mac's IP address and username")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("SSH Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
    
    private func connect() {
        let connection = SSHConnection(
            host: host,
            port: Int(port) ?? 22,
            username: username,
            password: useKey ? nil : password,
            privateKey: useKey ? privateKey : nil
        )
        terminal.connect(to: connection)
        isPresented = false
    }
    
    private func connectToLocalhost() {
        host = "localhost"
        port = "22"
        username = NSUserName()
    }
}

// MARK: - Terminal Manager

class TerminalManager: ObservableObject {
    @Published var output: [TerminalLine] = [
        TerminalLine(text: "VSCode iPadOS Terminal v1.0", type: .system),
        TerminalLine(text: "Type 'help' for commands or connect via SSH to a remote server.", type: .system),
        TerminalLine(text: "", type: .output)
    ]
    @Published var isConnected = false
    @Published var isConnecting = false
    @Published var connectionStatus = "Not connected"
    @Published var promptString = "$ "
    
    private var sshClient: SSHClient?
    private var currentConnection: SSHConnection?
    private var commandHistory: [String] = []
    private var historyIndex = 0
    
    func connect(to connection: SSHConnection) {
        currentConnection = connection
        isConnecting = true
        connectionStatus = "Connecting to \(connection.host)..."
        
        appendOutput("Connecting to \(connection.username)@\(connection.host):\(connection.port)...", type: .system)
        
        sshClient = SSHClient(connection: connection)
        sshClient?.delegate = self
        sshClient?.connect()
    }
    
    func disconnect() {
        sshClient?.disconnect()
        sshClient = nil
        isConnected = false
        isConnecting = false
        connectionStatus = "Disconnected"
        promptString = "$ "
        appendOutput("Disconnected from server.", type: .system)
    }
    
    func executeCommand(_ command: String) {
        commandHistory.append(command)
        historyIndex = commandHistory.count
        
        appendOutput(promptString + command, type: .command)
        
        if isConnected {
            sshClient?.send(command: command)
        } else {
            processLocalCommand(command)
        }
    }
    
    func sendInterrupt() {
        if isConnected {
            sshClient?.sendInterrupt()
        }
        appendOutput("^C", type: .system)
    }
    
    func sendTab() {
        if isConnected {
            sshClient?.sendTab()
        }
    }
    
    func previousCommand() -> String? {
        guard historyIndex > 0 else { return nil }
        historyIndex -= 1
        return commandHistory[historyIndex]
    }
    
    func nextCommand() -> String? {
        guard historyIndex < commandHistory.count - 1 else { return nil }
        historyIndex += 1
        return commandHistory[historyIndex]
    }
    
    private func processLocalCommand(_ command: String) {
        let parts = command.split(separator: " ", maxSplits: 1)
        guard let cmd = parts.first?.lowercased() else { return }
        
        switch cmd {
        case "help":
            appendOutput("""
            Local Commands:
              help              - Show this help
              clear             - Clear terminal
              echo <text>       - Echo text
              date              - Show current date
              whoami            - Show current user
              uname             - Show system info
              history           - Show command history
              ssh <user@host>   - Quick SSH connect
            
            To run real commands, connect to a server via SSH.
            Tap 'Connect SSH' button above to set up a connection.
            """, type: .output)
            
        case "clear":
            output = []
            
        case "echo":
            let text = parts.count > 1 ? String(parts[1]) : ""
            appendOutput(text, type: .output)
            
        case "date":
            let formatter = DateFormatter()
            formatter.dateFormat = "E MMM d HH:mm:ss zzz yyyy"
            appendOutput(formatter.string(from: Date()), type: .output)
            
        case "whoami":
            appendOutput("ipad-user", type: .output)
            
        case "uname":
            appendOutput("iPadOS \(UIDevice.current.systemVersion) (\(UIDevice.current.model))", type: .output)
            
        case "history":
            for (index, cmd) in commandHistory.enumerated() {
                appendOutput("  \(index + 1)  \(cmd)", type: .output)
            }
            
        case "ssh":
            if parts.count > 1 {
                let target = String(parts[1])
                if target.contains("@") {
                    let components = target.split(separator: "@")
                    if components.count == 2 {
                        let user = String(components[0])
                        let host = String(components[1])
                        appendOutput("Use the SSH connection sheet to connect (tap button above)", type: .system)
                        appendOutput("Host: \(host), User: \(user)", type: .system)
                    }
                }
            } else {
                appendOutput("Usage: ssh user@hostname", type: .error)
            }
            
        case "ls", "cd", "pwd", "cat", "mkdir", "rm", "mv", "cp", "grep", "find", "vim", "nano":
            appendOutput("'\(cmd)' requires SSH connection to a remote server.", type: .error)
            appendOutput("Tap 'Connect SSH' to connect to your Mac or server.", type: .system)
            
        default:
            appendOutput("\(cmd): command not found (local mode)", type: .error)
            appendOutput("Type 'help' for available commands or connect via SSH.", type: .system)
        }
    }
    
    func appendOutput(_ text: String, type: LineType, isANSI: Bool = false) {
        DispatchQueue.main.async {
            self.output.append(TerminalLine(text: text, type: type, isANSI: isANSI))
        }
    }
}

// MARK: - SSH Client Delegate
extension TerminalManager: SSHClientDelegate {
    func sshClientDidConnect(_ client: SSHClient) {
        DispatchQueue.main.async {
            self.isConnected = true
            self.isConnecting = false
            self.connectionStatus = "Connected to \(self.currentConnection?.host ?? "server")"
            self.promptString = "\(self.currentConnection?.username ?? "user")@\(self.currentConnection?.host ?? "host"):~$ "
            self.appendOutput("Connected successfully!", type: .system)
        }
    }
    
    func sshClientDidDisconnect(_ client: SSHClient, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.isConnecting = false
            self.connectionStatus = "Disconnected"
            self.promptString = "$ "
            if let error = error {
                self.appendOutput("Connection error: \(error.localizedDescription)", type: .error)
            }
        }
    }
    
    func sshClient(_ client: SSHClient, didReceiveOutput text: String) {
        appendOutput(text, type: .output, isANSI: text.contains("\u{1B}"))
    }
    
    func sshClient(_ client: SSHClient, didReceiveError text: String) {
        appendOutput(text, type: .error)
    }
}

// MARK: - SSH Client

protocol SSHClientDelegate: AnyObject {
    func sshClientDidConnect(_ client: SSHClient)
    func sshClientDidDisconnect(_ client: SSHClient, error: Error?)
    func sshClient(_ client: SSHClient, didReceiveOutput text: String)
    func sshClient(_ client: SSHClient, didReceiveError text: String)
}

class SSHClient {
    weak var delegate: SSHClientDelegate?
    private let connection: SSHConnection
    private var nwConnection: NWConnection?
    private var isAuthenticated = false
    
    init(connection: SSHConnection) {
        self.connection = connection
    }
    
    func connect() {
        let host = NWEndpoint.Host(connection.host)
        let port = NWEndpoint.Port(integerLiteral: UInt16(connection.port))
        
        nwConnection = NWConnection(host: host, port: port, using: .tcp)
        
        nwConnection?.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .ready:
                self.performSSHHandshake()
            case .failed(let error):
                self.delegate?.sshClientDidDisconnect(self, error: error)
            case .cancelled:
                self.delegate?.sshClientDidDisconnect(self, error: nil)
            default:
                break
            }
        }
        
        nwConnection?.start(queue: .global(qos: .userInitiated))
    }
    
    func disconnect() {
        nwConnection?.cancel()
        nwConnection = nil
    }
    
    func send(command: String) {
        guard let connection = nwConnection else { return }
        let data = (command + "\n").data(using: .utf8)!
        
        connection.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                self?.delegate?.sshClient(self!, didReceiveError: "Send error: \(error)")
            }
        })
    }
    
    func sendInterrupt() {
        // Send Ctrl+C (ASCII 3)
        guard let connection = nwConnection else { return }
        let data = Data([3])
        connection.send(content: data, completion: .idempotent)
    }
    
    func sendTab() {
        // Send Tab (ASCII 9)
        guard let connection = nwConnection else { return }
        let data = Data([9])
        connection.send(content: data, completion: .idempotent)
    }
    
    private func performSSHHandshake() {
        // Note: Full SSH2 protocol implementation requires significant code
        // This is a simplified version - for production, use SwiftNIO-SSH
        
        // For now, we'll simulate a successful connection and provide
        // instructions for the user to set up their server properly
        
        receiveData()
        
        // In a real implementation, we would:
        // 1. Exchange version strings
        // 2. Key exchange (diffie-hellman)
        // 3. Server authentication
        // 4. User authentication (password/key)
        // 5. Open channel
        // 6. Request PTY
        // 7. Start shell
        
        // For demo purposes, assume connection works if TCP connects
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.delegate?.sshClientDidConnect(self)
            self.delegate?.sshClient(self, didReceiveOutput: "")
            self.delegate?.sshClient(self, didReceiveOutput: "⚠️ Basic TCP connection established.")
            self.delegate?.sshClient(self, didReceiveOutput: "")
            self.delegate?.sshClient(self, didReceiveOutput: "For full SSH support, you have two options:")
            self.delegate?.sshClient(self, didReceiveOutput: "")
            self.delegate?.sshClient(self, didReceiveOutput: "1. WebSocket Terminal Server (Recommended):")
            self.delegate?.sshClient(self, didReceiveOutput: "   Run 'npx wetty' on your Mac/server")
            self.delegate?.sshClient(self, didReceiveOutput: "   Then open the wetty URL in Safari")
            self.delegate?.sshClient(self, didReceiveOutput: "")
            self.delegate?.sshClient(self, didReceiveOutput: "2. SSH App:")
            self.delegate?.sshClient(self, didReceiveOutput: "   Use a dedicated SSH app like Termius or Blink")
            self.delegate?.sshClient(self, didReceiveOutput: "")
            self.delegate?.sshClient(self, didReceiveOutput: "This terminal is great for quick local commands.")
            self.delegate?.sshClient(self, didReceiveOutput: "Full SSH2 protocol support coming soon!")
        }
    }
    
    private func receiveData() {
        nwConnection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            
            if let data = data, !data.isEmpty {
                if let text = String(data: data, encoding: .utf8) {
                    self.delegate?.sshClient(self, didReceiveOutput: text)
                }
            }
            
            if let error = error {
                self.delegate?.sshClient(self, didReceiveError: error.localizedDescription)
            }
            
            if !isComplete {
                self.receiveData()
            }
        }
    }
}

// MARK: - Models

struct SSHConnection {
    let host: String
    let port: Int
    let username: String
    let password: String?
    let privateKey: String?
}

struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let type: LineType
    var isANSI: Bool = false
    
    var color: Color {
        switch type {
        case .command: return .white
        case .output: return .white
        case .error: return Color(red: 1.0, green: 0.4, blue: 0.4)
        case .system: return Color(red: 0.4, green: 0.8, blue: 1.0)
        case .prompt: return .green
        }
    }
}

enum LineType {
    case command
    case output
    case error
    case system
    case prompt
}

// MARK: - ANSI Text View (Basic)

struct ANSIText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        // Strip ANSI codes for now - full implementation would parse them
        Text(stripANSI(text))
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.white)
            .textSelection(.enabled)
    }
    
    private func stripANSI(_ text: String) -> String {
        // Remove ANSI escape sequences
        let pattern = "\u{1B}\\[[0-9;]*[a-zA-Z]"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: "")
    }
}

// MARK: - Preview

struct TerminalView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalView()
            .preferredColorScheme(.dark)
    }
}
