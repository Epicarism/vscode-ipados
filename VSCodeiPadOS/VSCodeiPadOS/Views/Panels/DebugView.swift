import SwiftUI

// MARK: - Debug Models

struct DebugVariable: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    var children: [DebugVariable]?
}

// MARK: - Debug View
struct DebugView: View {
    @StateObject private var debugManager = DebugManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    private var variables: [DebugVariable] {
        debugManager.variables.map { convertToDebugVariable($0) }
    }
    
    @State private var newWatchExpression: String = ""
    @State private var isAddingWatch: Bool = false
    
    // Expanded states for sections
    @State private var isVariablesExpanded: Bool = true
    @State private var isWatchExpanded: Bool = true
    @State private var isCallStackExpanded: Bool = true
    @State private var isBreakpointsExpanded: Bool = true
    
    // Remote debugger connection sheet
    @State private var showConnectDebuggerSheet: Bool = false
    @State private var debuggerProgramPath: String = ""
    @State private var debuggerHost: String = ""
    @State private var debuggerCustomPath: String = ""
    @State private var selectedDebuggerType: DebuggerType = .lldb
    @State private var catchExceptions: Bool = false
    @State private var uncaughtExceptions: Bool = true
    @State private var editingBreakpointId: String? = nil
    @State private var conditionText: String = ""
    @State private var showConditionEditor: Bool = false
    @State private var showConsole: Bool = true
    @State private var consoleInput: String = ""
    
    private var theme: Theme { themeManager.currentTheme }
    
    private var isDebugging: Bool {
        debugManager.state == .running || debugManager.state == .paused
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with debug controls
            header
            
            Divider()
                .background(theme.editorForeground.opacity(0.15))
            
            // Debug toolbar
            if isDebugging {
                debugToolbar
                
                Divider()
                    .background(theme.editorForeground.opacity(0.15))
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    // Variables Section
                    variablesSection
                    
                    sectionDivider
                    
                    // Watch Section
                    watchSection
                    
                    sectionDivider
                    
                    // Call Stack Section
                    callStackSection
                    
                    sectionDivider
                    
                    // Breakpoints Section
                    breakpointsSection
                    
                    sectionDivider
                    
                    // Console Section
                    consoleSection
                }
            }
        }
        .background(theme.editorBackground)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Run and Debug panel")
        .sheet(isPresented: $showConnectDebuggerSheet) {
            connectDebuggerSheet
        }
        .alert("Edit Breakpoint Condition", isPresented: $showConditionEditor) {
            TextField("Condition (e.g. x > 5)", text: $conditionText)
            Button("Save") {
                if let bpId = editingBreakpointId {
                    debugManager.setBreakpointCondition(id: bpId, condition: conditionText.isEmpty ? nil : conditionText)
                }
                editingBreakpointId = nil
                conditionText = ""
            }
            Button("Cancel", role: .cancel) {
                editingBreakpointId = nil
                conditionText = ""
            }
        } message: {
            Text("Enter an expression that must be true for the breakpoint to pause execution.")
        }
        .onReceive(NotificationCenter.default.publisher(for: .editBreakpointCondition)) { notification in
            if let bpId = notification.object as? String {
                editingBreakpointId = bpId
                // Pre-fill with existing condition if any
                if let bp = debugManager.allBreakpoints.first(where: { $0.id == bpId }) {
                    conditionText = bp.condition ?? ""
                }
                showConditionEditor = true
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Text("RUN AND DEBUG")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(theme.comment)
            
            Spacer()
            
            // Status indicator
            if isDebugging {
                HStack(spacing: 4) {
                    Circle()
                        .fill(debugManager.state == .running ? Color(UIColor.systemGreen) : Color(UIColor.systemOrange))
                        .frame(width: 6, height: 6)
                    Text(debugManager.state.displayName)
                        .font(.system(size: 10))
                        .foregroundColor(theme.comment)
                }
            }
            
            Button(action: { debugManager.play() }) {
                Image(systemName: "play.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color(UIColor.systemGreen))
                    .padding(4)
                    .background(Color(UIColor.systemGreen).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Start debugging")
            .accessibilityHint("Double tap to start or continue debugging")
            
            // Connect Debugger button (show when SSH connected but debugger not)
            if debugManager.isSSHConnected && !debugManager.isRemoteDebuggerConnected {
                Button(action: { showConnectDebuggerSheet = true }) {
                    HStack(spacing: 2) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 10))
                        Text("Connect")
                            .font(.system(size: 9))
                    }
                    .foregroundColor(Color(UIColor.systemBlue))
                    .padding(4)
                    .background(Color(UIColor.systemBlue).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Connect remote debugger")
                .accessibilityHint("Double tap to connect to LLDB/GDB over SSH")
            }
            
            // Remote debugger status indicator
            if debugManager.isRemoteDebuggerConnected {
                HStack(spacing: 2) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 8))
                        .foregroundColor(Color(UIColor.systemGreen))
                    Text("Remote")
                        .font(.system(size: 8))
                        .foregroundColor(theme.comment)
                }
            }
            
            // More debug options menu
            Menu {
                Button(action: {
                    debugManager.removeAllBreakpoints()
                }) {
                    Label("Clear All Breakpoints", systemImage: "xmark.circle")
                }
                
                Button(action: {
                    debugManager.toggleAllBreakpoints()
                }) {
                    let allEnabled = debugManager.allBreakpointsEnabled
                    Label(
                        allEnabled ? "Disable All Breakpoints" : "Enable All Breakpoints",
                        systemImage: allEnabled ? "circle" : "circle.fill"
                    )
                }
                
                Divider()
                
                Toggle(isOn: $catchExceptions) {
                    Label("Caught Exceptions", systemImage: "exclamationmark.triangle")
                }
                .onChange(of: catchExceptions) { _, newValue in
                    debugManager.consoleEntries.append(DebugManager.ConsoleEntry(
                        message: "Caught exceptions: \(newValue ? "enabled" : "disabled")",
                        kind: .system
                    ))
                    // Wire to remote debugger if connected
                    if let remote = debugManager.remoteDebugger, remote.state == .connected || remote.state == .running {
                        Task {
                            if newValue {
                                try? await remote.executeCommand("breakpoint set -E c++")
                            } else {
                                try? await remote.executeCommand("breakpoint delete -E c++")
                            }
                        }
                    }
                }
                
                Toggle(isOn: $uncaughtExceptions) {
                    Label("Uncaught Exceptions", systemImage: "exclamationmark.triangle.fill")
                }
                .onChange(of: uncaughtExceptions) { _, newValue in
                    debugManager.consoleEntries.append(DebugManager.ConsoleEntry(
                        message: "Uncaught exceptions: \(newValue ? "enabled" : "disabled")",
                        kind: .system
                    ))
                    // Wire to remote debugger if connected
                    if let remote = debugManager.remoteDebugger, remote.state == .connected || remote.state == .running {
                        Task {
                            if newValue {
                                try? await remote.executeCommand("breakpoint set -E objc")
                            } else {
                                try? await remote.executeCommand("breakpoint delete -E objc")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
                    .padding(4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More debug options")
            .accessibilityHint("Double tap to show breakpoint management options")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(theme.tabBarBackground)
    }
    
    // MARK: - Debug Toolbar
    private var debugToolbar: some View {
        HStack(spacing: 4) {
            Spacer()
            
            // Continue / Pause
            DebugToolbarButton(
                icon: debugManager.state == .paused ? "play.fill" : "pause.fill",
                color: Color(UIColor.systemBlue),
                label: debugManager.state == .paused ? "Continue" : "Pause",
                theme: theme
            ) {
                if debugManager.state == .paused {
                    debugManager.play()
                } else {
                    debugManager.pause()
                }
            }
            
            // Step Over
            DebugToolbarButton(
                icon: "arrow.right",
                color: theme.editorForeground,
                label: "Step Over",
                theme: theme
            ) {
                debugManager.stepOver()
            }
            .disabled(debugManager.state != .paused)
            
            // Step Into
            DebugToolbarButton(
                icon: "arrow.down.right",
                color: theme.editorForeground,
                label: "Step Into",
                theme: theme
            ) {
                debugManager.stepInto()
            }
            .disabled(debugManager.state != .paused)
            
            // Step Out
            DebugToolbarButton(
                icon: "arrow.up.left",
                color: theme.editorForeground,
                label: "Step Out",
                theme: theme
            ) {
                debugManager.stepOut()
            }
            .disabled(debugManager.state != .paused)
            
            Divider()
                .frame(height: 16)
                .padding(.horizontal, 4)
            
            // Restart
            DebugToolbarButton(
                icon: "arrow.clockwise",
                color: Color(UIColor.systemGreen),
                label: "Restart",
                theme: theme
            ) {
                debugManager.restart()
            }
            
            // Stop
            DebugToolbarButton(
                icon: "stop.fill",
                color: Color(UIColor.systemRed),
                label: "Stop",
                theme: theme
            ) {
                debugManager.stop()
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .background(theme.tabBarBackground.opacity(0.5))
    }
    
    // MARK: - Variables Section
    private var variablesSection: some View {
        DisclosureGroup(isExpanded: $isVariablesExpanded) {
            VStack(alignment: .leading, spacing: 0) {
                if variables.isEmpty {
                    Text(isDebugging ? "No variables available" : "Not paused")
                        .font(.caption)
                        .foregroundColor(theme.comment)
                        .padding(.vertical, 4)
                        .padding(.leading, 12)
                } else {
                    ForEach(variables) { variable in
                        VariableRow(variable: variable, theme: theme)
                    }
                }
            }
            .padding(.leading, 4)
        } label: {
            DebugSectionHeader(title: "VARIABLES", theme: theme)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Variables section, \(isVariablesExpanded ? "expanded" : "collapsed")")
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }
    
    // MARK: - Watch Section
    private var watchSection: some View {
        DisclosureGroup(isExpanded: $isWatchExpanded) {
            VStack(alignment: .leading, spacing: 0) {
                if debugManager.watchExpressions.isEmpty && !isAddingWatch {
                    Text("No watch expressions")
                        .font(.caption)
                        .foregroundColor(theme.comment)
                        .padding(.vertical, 4)
                        .padding(.leading, 12)
                }
                
                if !debugManager.watchExpressions.isEmpty {
                    List {
                        ForEach(debugManager.watchExpressions) { watch in
                            HStack {
                                Image(systemName: "eye")
                                    .font(.caption2)
                                    .foregroundColor(theme.comment)
                                    .accessibilityHidden(true)
                                Text(watch.expression)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(theme.editorForeground)
                                Text(":")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(theme.comment)
                                Spacer()
                                Text(watch.value)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(theme.comment)
                            }
                            .padding(.vertical, 4)
                            .padding(.leading, 12)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Watch: \(watch.expression), value: \(watch.value)")
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    debugManager.removeWatchExpression(id: watch.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                if isAddingWatch {
                    HStack {
                        Image(systemName: "eye")
                            .font(.caption2)
                            .foregroundColor(theme.comment)
                            .accessibilityHidden(true)
                        TextField("Expression...", text: $newWatchExpression, onCommit: {
                            if !newWatchExpression.isEmpty {
                                debugManager.addWatchExpression(newWatchExpression)
                                newWatchExpression = ""
                            }
                            isAddingWatch = false
                        })
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(4)
                        .background(theme.selection)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .accessibilityLabel("New watch expression")
                    }
                    .padding(.vertical, 4)
                    .padding(.leading, 12)
                }
                
                if !isAddingWatch {
                    Button(action: { isAddingWatch = true }) {
                        HStack {
                            Image(systemName: "plus")
                                .accessibilityHidden(true)
                            Text("Add Expression")
                        }
                        .font(.caption)
                        .foregroundColor(Color(UIColor.systemBlue))
                        .padding(.vertical, 4)
                        .padding(.leading, 12)
                    }
                    .accessibilityLabel("Add watch expression")
                    .accessibilityHint("Double tap to add a new watch expression")
                }
            }
        } label: {
            HStack {
                DebugSectionHeader(title: "WATCH", theme: theme)
                Spacer()
                Button(action: { isAddingWatch = true }) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .foregroundColor(theme.comment)
                }
                .buttonStyle(.plain)
                .opacity(isWatchExpanded ? 1 : 0)
                .accessibilityLabel("Add watch expression")
                .accessibilityHint("Double tap to add a new watch expression")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Watch section, \(isWatchExpanded ? "expanded" : "collapsed")")
        .padding(.horizontal, 8)
    }
    
    // MARK: - Call Stack Section
    private var callStackSection: some View {
        DisclosureGroup(isExpanded: $isCallStackExpanded) {
            VStack(alignment: .leading, spacing: 0) {
                if !isDebugging {
                    Text("Not debugging")
                        .font(.caption)
                        .foregroundColor(theme.comment)
                        .padding(.vertical, 4)
                        .padding(.leading, 12)
                } else if debugManager.callStack.isEmpty {
                    Text("No call stack available")
                        .font(.caption)
                        .foregroundColor(theme.comment)
                        .padding(.vertical, 4)
                        .padding(.leading, 12)
                } else {
                    ForEach(Array(debugManager.callStack.enumerated()), id: \.offset) { index, frame in
                        CallStackRow(frame: frame, isActive: index == 0, theme: theme)
                    }
                }
            }
            .padding(.leading, 4)
        } label: {
            DebugSectionHeader(title: "CALL STACK", theme: theme)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Call stack section, \(isCallStackExpanded ? "expanded" : "collapsed")")
        .padding(.horizontal, 8)
    }
    
    // MARK: - Console Section
    private var consoleSection: some View {
        DisclosureGroup(isExpanded: $showConsole) {
            VStack(alignment: .leading, spacing: 0) {
                // Console entries with auto-scroll
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            if debugManager.consoleEntries.isEmpty {
                                Text("No console output")
                                    .font(.caption)
                                    .foregroundColor(theme.comment)
                                    .padding(.vertical, 4)
                                    .padding(.leading, 12)
                            } else {
                                ForEach(debugManager.consoleEntries) { entry in
                                    HStack(alignment: .top, spacing: 4) {
                                        Text(entry.prefix)
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(colorForConsoleKind(entry.kind))
                                            .frame(width: 12, alignment: .leading)
                                        
                                        Text(entry.text)
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(colorForConsoleKind(entry.kind))
                                            .textSelection(.enabled)
                                    }
                                    .padding(.vertical, 1)
                                    .padding(.horizontal, 8)
                                    .id(entry.id)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .onChange(of: debugManager.consoleEntries.count) { _, _ in
                        if let lastEntry = debugManager.consoleEntries.last {
                            withAnimation {
                                proxy.scrollTo(lastEntry.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                    .background(theme.editorForeground.opacity(0.1))
                    .padding(.vertical, 4)
                
                // Input field
                HStack(spacing: 4) {
                    TextField("Evaluate expression...", text: $consoleInput)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(6)
                        .background(theme.selection.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .onSubmit {
                            if !consoleInput.isEmpty {
                                debugManager.submitConsole(input: consoleInput)
                                consoleInput = ""
                            }
                        }
                    
                    Button(action: {
                        if !consoleInput.isEmpty {
                            debugManager.submitConsole(input: consoleInput)
                            consoleInput = ""
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(consoleInput.isEmpty ? theme.comment : Color(UIColor.systemBlue))
                    }
                    .buttonStyle(.plain)
                    .disabled(consoleInput.isEmpty)
                    .accessibilityLabel("Send")
                    .accessibilityHint("Double tap to evaluate expression")
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            }
            .padding(.leading, 4)
        } label: {
            HStack {
                DebugSectionHeader(title: "CONSOLE", theme: theme)
                Spacer()
                Button(action: { debugManager.clearConsole() }) {
                    Image(systemName: "trash")
                        .font(.system(size: 10))
                        .foregroundColor(theme.comment)
                }
                .buttonStyle(.plain)
                .opacity(showConsole ? 1 : 0)
                .accessibilityLabel("Clear console")
                .accessibilityHint("Double tap to clear console output")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Console section, \(showConsole ? "expanded" : "collapsed")")
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
    
    // MARK: - Breakpoints Section
    private var breakpointsSection: some View {
        DisclosureGroup(isExpanded: $isBreakpointsExpanded) {
            VStack(alignment: .leading, spacing: 0) {
                if debugManager.breakpoints.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 6) {
                            Text("No breakpoints set")
                                .font(.caption)
                                .foregroundColor(theme.comment)
                            Text("Click in the editor gutter to add a breakpoint")
                                .font(.system(size: 10))
                                .foregroundColor(theme.comment.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 12)
                        Spacer()
                    }
                } else {
                    ForEach(debugManager.breakpoints) { bp in
                        BreakpointRow(breakpoint: bp, theme: theme, debugManager: debugManager)
                    }
                }
            }
            .padding(.leading, 4)
        } label: {
            HStack {
                DebugSectionHeader(title: "BREAKPOINTS", count: debugManager.breakpoints.count, theme: theme)
                Spacer()
                if !debugManager.breakpoints.isEmpty {
                    Button(action: { debugManager.toggleAllBreakpoints() }) {
                        Image(systemName: debugManager.allBreakpointsEnabled ? "circle.slash" : "circle")
                            .font(.system(size: 10))
                            .foregroundColor(theme.comment)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(debugManager.allBreakpointsEnabled ? "Disable all breakpoints" : "Enable all breakpoints")
                    .accessibilityHint("Double tap to toggle all breakpoints")
                    
                    Button(action: { debugManager.removeAllBreakpoints() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 10))
                            .foregroundColor(theme.comment)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove all breakpoints")
                    .accessibilityHint("Double tap to remove all breakpoints")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Breakpoints section, \(isBreakpointsExpanded ? "expanded" : "collapsed")")
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
    
    // MARK: - Helpers
    private var sectionDivider: some View {
        Divider()
            .background(theme.editorForeground.opacity(0.1))
            .padding(.vertical, 4)
    }
    
    private func colorForConsoleKind(_ kind: DebugManager.ConsoleEntry.Kind) -> Color {
        switch kind {
        case .error:
            return Color.red
        case .warning:
            return Color.orange
        case .output:
            return Color.green
        case .input:
            return Color(UIColor.systemBlue)
        case .system:
            return Color.gray
        case .info:
            return theme.comment
        }
    }
    
    private func convertToDebugVariable(_ variable: DebugManager.Variable, depth: Int = 0) -> DebugVariable {
        let childDepth = depth + 1
        let convertedChildren: [DebugVariable]?
        if variable.children.isEmpty {
            convertedChildren = nil
        } else if depth >= 10 {
            // Depth limit reached - add sentinel so user knows content was truncated
            convertedChildren = [DebugVariable(name: "…", value: "depth limit reached", children: nil)]
        } else {
            convertedChildren = variable.children.map { convertToDebugVariable($0, depth: childDepth) }
        }
        return DebugVariable(
            name: variable.name,
            value: variable.value,
            children: convertedChildren
        )
    }
    
    // MARK: - Connect Debugger Sheet
    private var connectDebuggerSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Debugger Type")) {
                    Picker("Type", selection: $selectedDebuggerType) {
                        Text("LLDB").tag(DebuggerType.lldb)
                        Text("GDB").tag(DebuggerType.gdb)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Program")) {
                    TextField("Program path on remote", text: $debuggerProgramPath)
                        .font(.system(size: 14, design: .monospaced))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Optional")) {
                    TextField("Remote debug server (host:port)", text: $debuggerHost)
                        .font(.system(size: 14, design: .monospaced))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.URL)
                    
                    TextField("Custom debugger path (e.g. /usr/bin/lldb)", text: $debuggerCustomPath)
                        .font(.system(size: 14, design: .monospaced))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Connect Debugger")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showConnectDebuggerSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Connect") {
                        Task {
                            await connectRemoteDebugger()
                        }
                    }
                    .disabled(debuggerProgramPath.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func connectRemoteDebugger() async {
        guard let sshConfig = SSHManager.shared.currentConfig else {
            debugManager.consoleEntries.append(DebugManager.ConsoleEntry(
                message: "No SSH connection available.",
                kind: .error
            ))
            return
        }
        
        let config = RemoteDebuggerConfig(
            name: "Remote \(selectedDebuggerType.displayName)",
            sshConnectionId: sshConfig.id,
            debuggerType: selectedDebuggerType,
            programPath: debuggerProgramPath,
            remoteTarget: debuggerHost.isEmpty ? nil : debuggerHost,
            debuggerPath: debuggerCustomPath.isEmpty ? nil : debuggerCustomPath
        )
        
        do {
            try await debugManager.connectRemoteDebugger(config: config, sshConfig: sshConfig)
            showConnectDebuggerSheet = false
        } catch {
            debugManager.consoleEntries.append(DebugManager.ConsoleEntry(
                message: "Failed to connect: \(error.localizedDescription)",
                kind: .error
            ))
        }
    }
}

// MARK: - Section Header
struct DebugSectionHeader: View {
    let title: String
    var count: Int? = nil
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(theme.comment)
            if let count {
                Text("\(count)")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(theme.comment.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Debug Toolbar Button
struct DebugToolbarButton: View {
    let icon: String
    let color: Color
    let label: String
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(theme.editorForeground.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityHint("Double tap to \(label.lowercased())")
    }
}

// MARK: - Variable Row
struct VariableRow: View {
    let variable: DebugVariable
    let theme: Theme
    var depth: Int = 0
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                if let children = variable.children, !children.isEmpty {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                        }
                        .foregroundColor(theme.comment)
                        .accessibilityLabel("\(variable.name), \(children.count) children, \(isExpanded ? "expanded" : "collapsed")")
                        .accessibilityHint("Double tap to \(isExpanded ? "collapse" : "expand")")
                        .accessibilityAddTraits(.isButton)
                } else {
                    Spacer().frame(width: 16)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(variable.name)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(theme.keyword)
                    Text(":")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(theme.comment)
                    Text(variable.value)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(theme.string)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.vertical, 2)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(variable.name): \(variable.value)")
            
            if isExpanded, let children = variable.children, depth < 11 {
                ForEach(children) { child in
                    VariableRow(variable: child, theme: theme, depth: depth + 1)
                        .padding(.leading, 16)
                }
            }
        }
    }
}

// MARK: - Call Stack Row
struct CallStackRow: View {
    let frame: DebugManager.StackFrame
    let isActive: Bool
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 6) {
            if isActive {
                Image(systemName: "play.fill")
                    .font(.system(size: 7))
                    .foregroundColor(Color(UIColor.systemYellow))
                    .accessibilityLabel("Active frame")
            } else {
                Spacer().frame(width: 10)
            }
            
            Text(frame.function)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(isActive ? theme.editorForeground : theme.comment)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(frame.fileName):\(frame.line)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(theme.comment.opacity(0.7))
                .lineLimit(1)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 8)
        .background(isActive ? theme.selection.opacity(0.3) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(isActive ? "Active frame: " : "")\(frame.function) at \(frame.fileName) line \(frame.line)")
    }
}

// MARK: - Breakpoint Row
struct BreakpointRow: View {
    let breakpoint: DebugManager.Breakpoint
    let theme: Theme
    let debugManager: DebugManager
    
    var body: some View {
        HStack(spacing: 6) {
            // Enable/disable toggle
            Button(action: {
                debugManager.toggleBreakpointEnabled(id: breakpoint.id)
            }) {
                Image(systemName: breakpoint.isEnabled ? "circle.fill" : "circle")
                    .font(.system(size: 10))
                    .foregroundColor(Color(UIColor.systemRed))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(breakpoint.isEnabled ? "Enabled breakpoint – tap to disable" : "Disabled breakpoint – tap to enable")
            .accessibilityHint("Double tap to toggle breakpoint")
            
            // File name
            Text(breakpoint.fileName)
                .font(.system(size: 12))
                .foregroundColor(theme.editorForeground)
                .lineLimit(1)
            
            // Line number (1-based for display)
            Text(":\(breakpoint.lineNumber)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(theme.comment)
            
            // Condition
            if let condition = breakpoint.condition, !condition.isEmpty {
                Text("(\(condition))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color(UIColor.systemOrange))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Delete
            Button(action: {
                debugManager.removeBreakpoint(breakpoint.id)
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 9))
                    .foregroundColor(theme.comment)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove breakpoint")
            .accessibilityHint("Double tap to remove this breakpoint")
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Breakpoint at \(breakpoint.fileName) line \(breakpoint.lineNumber), \(breakpoint.isEnabled ? "enabled" : "disabled")")
        .contextMenu {
            Button(action: {
                debugManager.toggleBreakpointEnabled(id: breakpoint.id)
            }) {
                Label(breakpoint.isEnabled ? "Disable Breakpoint" : "Enable Breakpoint",
                      systemImage: breakpoint.isEnabled ? "circle" : "circle.fill")
            }
            
            Button(action: {
                // Post notification with breakpoint ID to trigger condition editor in parent
                NotificationCenter.default.post(name: .editBreakpointCondition, object: breakpoint.id)
            }) {
                Label("Edit Condition...", systemImage: "pencil.line")
            }
            
            if breakpoint.condition != nil {
                Button(action: {
                    debugManager.setBreakpointCondition(id: breakpoint.id, condition: nil)
                }) {
                    Label("Remove Condition", systemImage: "xmark.circle")
                }
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                debugManager.removeBreakpoint(breakpoint.id)
            }) {
                Label("Delete Breakpoint", systemImage: "trash")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DebugView()
}
