import SwiftUI

// MARK: - Debug Models

struct DebugVariable: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    var children: [DebugVariable]?
}

struct DebugCallFrame: Identifiable {
    let id = UUID()
    let functionName: String
    let fileName: String
    let lineNumber: Int
    let isActive: Bool
}

struct DebugBreakpointItem: Identifiable {
    let id = UUID()
    var fileName: String
    var lineNumber: Int
    var isEnabled: Bool
    var condition: String?
}

// MARK: - Debug View

struct DebugView: View {
    @ObservedObject private var debugManager = DebugManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    
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
    
    // Breakpoints state
    @State private var breakpoints: [DebugBreakpointItem] = []
    @State private var allBreakpointsEnabled: Bool = true
    
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
                }
            }
        }
        .background(theme.editorBackground)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Run and Debug panel")
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
                        .fill(debugManager.state == .running ? Color.green : Color.orange)
                        .frame(width: 6, height: 6)
                    Text(debugManager.state.displayName)
                        .font(.system(size: 10))
                        .foregroundColor(theme.comment)
                }
            }
            
            Button(action: { debugManager.play() }) {
                Image(systemName: "play.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.green)
                    .padding(4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Start debugging")
            .accessibilityHint("Double tap to start or continue debugging")
            
            Menu {
                Button(action: { debugManager.removeAllBreakpoints() }) {
                    Label("Clear All Breakpoints", systemImage: "xmark.circle")
                }
                Button(action: { debugManager.toggleAllBreakpoints() }) {
                    Label(allBreakpointsEnabled ? "Disable All Breakpoints" : "Enable All Breakpoints", systemImage: allBreakpointsEnabled ? "circle.slash" : "circle")
                }
                Divider()
                Button(action: { debugManager.play() }) {
                    Label("Exception Breakpoints", systemImage: "bolt.trianglefilled")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading, 8)
            .accessibilityLabel("More debug options")
            .accessibilityHint("Double tap to open additional debug settings")
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
                color: .blue,
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
                icon: "arrow.down",
                color: theme.editorForeground,
                label: "Step Into",
                theme: theme
            ) {
                debugManager.stepInto()
            }
            .disabled(debugManager.state != .paused)
            
            // Step Out
            DebugToolbarButton(
                icon: "arrow.up",
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
                color: .green,
                label: "Restart",
                theme: theme
            ) {
                debugManager.restart()
            }
            
            // Stop
            DebugToolbarButton(
                icon: "stop.fill",
                color: .red,
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
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 12, design: .monospaced))
                        .padding(4)
                        .background(theme.selection)
                        .cornerRadius(4)
                        .accessibilityLabel("New watch expression")
                    }
                    .padding(.vertical, 4)
                    .padding(.leading, 12)
                }
                
                Button(action: { isAddingWatch = true }) {
                    HStack {
                        Image(systemName: "plus")
                            .accessibilityHidden(true)
                        Text("Add Expression")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.vertical, 4)
                    .padding(.leading, 12)
                }
                .accessibilityLabel("Add watch expression")
                .accessibilityHint("Double tap to add a new watch expression")
                .opacity(isAddingWatch ? 0 : 1)
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
                .buttonStyle(PlainButtonStyle())
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
    
    // MARK: - Breakpoints Section
    
    private var breakpointsSection: some View {
        DisclosureGroup(isExpanded: $isBreakpointsExpanded) {
            VStack(alignment: .leading, spacing: 0) {
                if debugManager.breakpoints.isEmpty {
                    Text("No breakpoints set")
                        .font(.caption)
                        .foregroundColor(theme.comment)
                        .padding(.vertical, 4)
                        .padding(.leading, 12)
                } else {
                    ForEach(debugManager.breakpoints) { bp in
                        BreakpointRow(breakpoint: bp, theme: theme)
                    }
                }
            }
            .padding(.leading, 4)
        } label: {
            HStack {
                DebugSectionHeader(title: "BREAKPOINTS", theme: theme)
                Spacer()
                if !debugManager.breakpoints.isEmpty {
                    Button(action: { debugManager.toggleAllBreakpoints() }) {
                        Image(systemName: allBreakpointsEnabled ? "circle.slash" : "circle")
                            .font(.system(size: 10))
                            .foregroundColor(theme.comment)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(allBreakpointsEnabled ? "Disable all breakpoints" : "Enable all breakpoints")
                    .accessibilityHint("Double tap to toggle all breakpoints")
                    
                    Button(action: { debugManager.removeAllBreakpoints() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 10))
                            .foregroundColor(theme.comment)
                    }
                    .buttonStyle(PlainButtonStyle())
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
    
    private func convertToDebugVariable(_ variable: DebugManager.Variable) -> DebugVariable {
        DebugVariable(
            name: variable.name,
            value: variable.value,
            children: variable.children.isEmpty ? nil : variable.children.map { convertToDebugVariable($0) }
        )
    }
}

// MARK: - Section Header

struct DebugSectionHeader: View {
    let title: String
    let theme: Theme
    
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(theme.comment)
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
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(label)
        .accessibilityHint("Double tap to \(label.lowercased())")
    }
}

// MARK: - Variable Row

struct VariableRow: View {
    let variable: DebugVariable
    let theme: Theme
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
            
            if isExpanded, let children = variable.children {
                ForEach(children) { child in
                    VariableRow(variable: child, theme: theme)
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
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 7))
                    .foregroundColor(.yellow)
                    .accessibilityLabel("Active frame")
            } else {
                Spacer().frame(width: 10)
            }
            
            Text(frame.function)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(isActive ? theme.editorForeground : theme.comment)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(frame.file):\(frame.line)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(theme.comment.opacity(0.7))
                .lineLimit(1)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 8)
        .background(isActive ? theme.selection.opacity(0.3) : Color.clear)
        .cornerRadius(2)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(isActive ? "Active frame: " : "")\(frame.function) at \(frame.file) line \(frame.line)")
    }
}

// MARK: - Breakpoint Row

struct BreakpointRow: View {
    let breakpoint: DebugManager.Breakpoint
    let theme: Theme
    
    @ObservedObject private var debugManager = DebugManager.shared
    
    var body: some View {
        HStack(spacing: 6) {
            // Enable/disable toggle
            Button(action: { debugManager.toggleBreakpoint(breakpoint.id) }) {
                Image(systemName: breakpoint.isEnabled ? "circle.fill" : "circle")
                    .font(.system(size: 10))
                    .foregroundColor(breakpoint.isEnabled ? .red : theme.comment)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(breakpoint.isEnabled ? "Enabled" : "Disabled")
            .accessibilityHint("Double tap to toggle breakpoint")
            
            // File name
            Text(breakpoint.fileName)
                .font(.system(size: 12))
                .foregroundColor(theme.editorForeground)
                .lineLimit(1)
            
            // Line number
            Text(":\(breakpoint.lineNumber)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(theme.comment)
            
            // Condition
            if let condition = breakpoint.condition, !condition.isEmpty {
                Text("(\(condition))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.orange)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Delete
            Button(action: { debugManager.removeBreakpoint(breakpoint.id) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 9))
                    .foregroundColor(theme.comment)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Remove breakpoint")
            .accessibilityHint("Double tap to remove this breakpoint")
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Breakpoint at \(breakpoint.fileName) line \(breakpoint.lineNumber), \(breakpoint.isEnabled ? "enabled" : "disabled")")
    }
}

// MARK: - Preview

#Preview {
    DebugView()
}
