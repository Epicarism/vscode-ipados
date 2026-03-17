import SwiftUI

/// UI-only debug state manager.
///
/// This provides observable state for the Debug sidebar, breakpoint gutter markers,
/// and a functional JavaScript console REPL using JSRunner.
@MainActor
final class DebugManager: ObservableObject {
    typealias CallStackFrame = StackFrame

    static let shared = DebugManager()

    enum SessionState: String {
        case stopped
        case running
        case paused

        var displayName: String {
            switch self {
            case .stopped: return "Stopped"
            case .running: return "Running"
            case .paused: return "Paused"
            }
        }

        var canStep: Bool { self == .paused }
        var canPlay: Bool { self != .running }
        var canStop: Bool { self != .stopped }
    }

    struct StackFrame: Identifiable, Hashable {
        let id = UUID()
        var function: String
        var file: String
        var line: Int

        var functionName: String { function }
        var fileName: String { file }
        var lineNumber: Int { line }
    }

    struct Breakpoint: Identifiable, Hashable {
        /// Stable id for list diffing.
        var id: String { "\(file)::\(line)" }

        /// File identifier (typically URL path, otherwise fileName).
        var file: String

        /// Line index as used by the editor UI (often 0-based).
        var line: Int

        /// Convenience for displaying in UI (1-based).
        var displayLine: Int { line + 1 }

        /// UI only for now; there is no real debugger yet.
        var isEnabled: Bool = true

        var fileName: String { (file as NSString).lastPathComponent }
        var lineNumber: Int { displayLine }
        var condition: String? = nil
    }

    struct Variable: Identifiable, Hashable {
        let id = UUID()
        var name: String
        var value: String
        var type: String
        var children: [Variable] = []
        
        /// Returns children as optional for OutlineGroup compatibility
        var optionalChildren: [Variable]? {
            children.isEmpty ? nil : children
        }
    }

    struct WatchExpression: Identifiable, Hashable {
        let id = UUID()
        var expression: String
        var value: String
    }

    struct ConsoleEntry: Identifiable, Hashable {
        let id = UUID()
        var message: String
        var kind: Kind
        var timestamp: Date = Date()
        
        enum Kind: String, Hashable {
            case input
            case output
            case error
            case warning
            case info
            case system
        }
        
        var prefix: String {
            switch kind {
            case .input: return ">"
            case .output: return "<"
            case .error: return "!"
            case .warning: return "⚠"
            case .info: return "i"
            case .system: return "•"
            }
        }
        
        var text: String {
            message
        }
    }

    // MARK: - Published state

    @Published var state: SessionState = .stopped

    /// Breakpoints by file identifier (typically URL path, otherwise fileName).
    @Published private(set) var breakpointsByFile: [String: Set<Int>] = [:]
    
    /// Breakpoint enabled states by composite id ("file::line")
    @Published private(set) var breakpointEnabledStates: [String: Bool] = [:]
    
    /// Breakpoint conditions by composite id ("file::line")
    @Published private(set) var breakpointConditions: [String: String] = [:]

    @Published var watchExpressions: [WatchExpression] = []
    @Published var variables: [Variable] = []
    @Published var callStack: [StackFrame] = []
    @Published var selectedFrameId: StackFrame.ID?
    @Published var consoleEntries: [ConsoleEntry] = []

    /// Active JSRunner instance for the current debug session (used by console eval).
    private var activeJSRunner: JSRunner?

    /// Tracks whether all breakpoints are globally enabled/disabled via toggleAllBreakpoints().
    @Published var allBreakpointsEnabled = true

    /// Remote debugger for LLDB/GDB over SSH
    var remoteDebugger: RemoteDebugger?

    /// Whether remote debugger is connected and active
    var isRemoteDebuggerConnected: Bool {
        remoteDebugger?.state.isActive ?? false
    }
    
    /// Whether SSH is connected (for showing Connect Debugger button)
    var isSSHConnected: Bool {
        SSHManager.shared.isConnected
    }

    /// Current line when paused at breakpoint (for remote debugging)
    @Published var currentLine: Int? = nil

    /// Current file when paused at breakpoint (for remote debugging)
    @Published var currentFile: String? = nil

        // MARK: - Convenience views of state (for UI plumbing)

        var allBreakpoints: [Breakpoint] {
            breakpointsByFile
                .flatMap { (file, lines) in
                    lines.map { line in
                        let id = "\(file)::\(line)"
                        var bp = Breakpoint(file: file, line: line)
                        bp.isEnabled = breakpointEnabledStates[id] ?? true
                        bp.condition = breakpointConditions[id]
                        return bp
                    }
                }
                .sorted {
                    if $0.file == $1.file { return $0.line < $1.line }
                    return $0.file < $1.file
                }
        }

        var breakpoints: [Breakpoint] { allBreakpoints }

        private init() {
            // Seed some UI data so the panels aren't empty.
            watchExpressions = [
                WatchExpression(expression: "counter", value: "0"),
                WatchExpression(expression: "user.name", value: "\"Taylor\""),
            ]
        }

        // MARK: - Console Methods

        /// Submit a console input. Handles special commands, JS evaluation, and sessions.
        func submitConsole(input: String) {
            let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            // Handle special console commands
            let lower = trimmed.lowercased()
            if lower == "clear" {
                consoleEntries.removeAll()
                consoleEntries.append(ConsoleEntry(message: "Console cleared.", kind: .system))
                return
            }
            if lower == "help" {
                consoleEntries.append(ConsoleEntry(message: "> \(trimmed)", kind: .input))
                consoleEntries.append(ConsoleEntry(
                    message: """
                    Available commands:
                      clear    – Clear the console
                      help     – Show this help
                      bp       – List all breakpoints
                    Any other input is evaluated as JavaScript.
                    """,
                    kind: .info
                ))
                return
            }
            if lower == "bp" || lower == "breakpoints" {
                consoleEntries.append(ConsoleEntry(message: "> \(trimmed)", kind: .input))
                let bps = allBreakpoints
                if bps.isEmpty {
                    consoleEntries.append(ConsoleEntry(message: "No breakpoints set.", kind: .system))
                } else {
                    for bp in bps {
                        consoleEntries.append(ConsoleEntry(
                            message: "• \(bp.fileName):\(bp.displayLine) \(bp.isEnabled ? "[enabled]" : "[disabled]")",
                            kind: .info
                        ))
                    }
                }
                return
            }

            consoleEntries.append(ConsoleEntry(message: "> \(input)", kind: .input))

            // Evaluate JavaScript in all states (stopped, paused, running)
            evaluateJavaScript(trimmed)
        }

        /// Evaluate a JavaScript expression and append the result (or error) to the console.
        private func evaluateJavaScript(_ code: String) {
            let runner: JSRunner
            if let existing = activeJSRunner {
                runner = existing
            } else {
                runner = JSRunner()
                activeJSRunner = runner
                // Forward console.log output to the debug console
                runner.setConsoleHandler { [weak self] message in
                    Task { @MainActor in
                        guard let self else { return }
                        let clean = message
                            .replacingOccurrences(of: "[LOG] ", with: "")
                            .replacingOccurrences(of: "[ERROR] ", with: "")
                            .replacingOccurrences(of: "[WARN] ", with: "")
                            .replacingOccurrences(of: "[INFO] ", with: "")
                        self.consoleEntries.append(ConsoleEntry(message: clean, kind: .output))
                    }
                }
            }
            Task {
                do {
                    let result = try await runner.execute(code: code, timeout: 10.0)
                    let resultString = result.toString() ?? "undefined"
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        if resultString.isEmpty || resultString == "undefined" {
                            self.consoleEntries.append(ConsoleEntry(message: "undefined", kind: .output))
                        } else {
                            self.consoleEntries.append(ConsoleEntry(message: resultString, kind: .output))
                        }
                    }
                } catch {
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        self.consoleEntries.append(ConsoleEntry(
                            message: "Error: \(error.localizedDescription)",
                            kind: .error
                        ))
                    }
                }
            }
        }

        func copyConsoleToClipboard() {
            let text = consoleEntries.map { $0.message }.joined(separator: "\n")
            UIPasteboard.general.string = text
        }

        func clearConsole() {
            consoleEntries.removeAll()
        }

        // MARK: - Breakpoints

        private func canonicalFileId(_ file: String) -> String {
            // Many call sites use URL.absoluteString; convert file:// URLs to paths so we
            // don't end up with duplicate breakpoint buckets for the same file.
            if let url = URL(string: file), url.isFileURL {
                return url.path
            }
            return file
        }

        /// Normalizes UI-provided line indices.
        ///
        /// The editor UI typically uses 0-based indices for line iteration. We clamp
        /// to a minimum of 0 to avoid negative values.
        private func canonicalLine(_ line: Int) -> Int {
            max(0, line)
        }

        func hasBreakpoint(file: String, line: Int) -> Bool {
            guard allBreakpointsEnabled else { return false }
            let fileId = canonicalFileId(file)
            let line = canonicalLine(line)
            return breakpointsByFile[fileId]?.contains(line) == true
        }

        func toggleBreakpoint(file: String, line: Int) {
            let fileId = canonicalFileId(file)
            let line = canonicalLine(line)

            // IMPORTANT: mutate via a copy so @Published emits reliably for collection changes.
            var dict = breakpointsByFile
            var set = dict[fileId] ?? []

            let wasPresent = set.contains(line)

            if wasPresent {
                set.remove(line)
                // Clean up state dictionaries when removing breakpoint
                let id = "\(fileId)::\(line)"
                breakpointEnabledStates.removeValue(forKey: id)
                breakpointConditions.removeValue(forKey: id)
            } else {
                set.insert(line)
            }

            if set.isEmpty {
                dict.removeValue(forKey: fileId)
            } else {
                dict[fileId] = set
            }

            breakpointsByFile = dict

            // Sync to remote debugger if connected
            // Note: remote debugger uses 1-based line numbers
            if remoteDebugger?.state.isActive == true {
                Task {
                    do {
                        if wasPresent {
                            try await remoteDebugger?.removeBreakpoint(file: fileId, line: line + 1)
                        } else {
                            _ = try await remoteDebugger?.setBreakpoint(file: fileId, line: line + 1)
                        }
                    } catch {
                        consoleEntries.append(ConsoleEntry(
                            message: "Remote breakpoint sync error: \(error.localizedDescription)",
                            kind: .error
                        ))
                    }
                }
            }

            // Log to console
            let shortName = (fileId as NSString).lastPathComponent
            if wasPresent {
                consoleEntries.append(ConsoleEntry(
                    message: "Breakpoint removed at \(shortName):\(line + 1)",
                    kind: .system
                ))
            } else {
                consoleEntries.append(ConsoleEntry(
                    message: "Breakpoint added at \(shortName):\(line + 1)",
                    kind: .system
                ))
            }
        }

        func setBreakpoint(file: String, line: Int, isEnabled: Bool) {
            // UI-only model currently treats "enabled" as "present/absent".
            // (Real debugger integration can extend this to store disabled breakpoints.)
            if isEnabled {
                if !hasBreakpoint(file: file, line: line) {
                    toggleBreakpoint(file: file, line: line)
                }
            } else {
                removeBreakpoint(file: file, line: line)
            }
        }

        func removeBreakpoint(file: String, line: Int) {
            let fileId = canonicalFileId(file)
            let line = canonicalLine(line)

            var dict = breakpointsByFile
            guard var set = dict[fileId] else { return }

            set.remove(line)
            // Clean up state dictionaries when removing breakpoint
            let id = "\(fileId)::\(line)"
            breakpointEnabledStates.removeValue(forKey: id)
            breakpointConditions.removeValue(forKey: id)
            
            if set.isEmpty {
                dict.removeValue(forKey: fileId)
            } else {
                dict[fileId] = set
            }
            breakpointsByFile = dict

            // Sync removal to remote debugger if connected
            if remoteDebugger?.state.isActive == true {
                Task {
                    do {
                        try await remoteDebugger?.removeBreakpoint(file: fileId, line: line + 1)
                    } catch {
                        consoleEntries.append(ConsoleEntry(
                            message: "Remote breakpoint remove error: \(error.localizedDescription)",
                            kind: .error
                        ))
                    }
                }
            }
        }

        func breakpoints(in file: String) -> [Breakpoint] {
            guard allBreakpointsEnabled else { return [] }
            let fileId = canonicalFileId(file)
            let lines = breakpointsByFile[fileId] ?? []
            return lines.sorted().map { Breakpoint(file: fileId, line: $0) }
        }

        // MARK: - Watch expressions

        @discardableResult
        func addWatchExpression(_ expression: String, initialValue: String = "—") -> WatchExpression? {
            let trimmed = expression.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }

            // Avoid duplicates by expression text.
            if watchExpressions.contains(where: { $0.expression == trimmed }) {
                return watchExpressions.first(where: { $0.expression == trimmed })
            }

            let watch = WatchExpression(expression: trimmed, value: initialValue)
            var watches = watchExpressions
            watches.append(watch)
            watchExpressions = watches
            return watch
        }

        func removeWatchExpression(id: WatchExpression.ID) {
            var watches = watchExpressions
            watches.removeAll { $0.id == id }
            watchExpressions = watches
        }

        func updateWatchExpression(id: WatchExpression.ID, expression: String) {
            let trimmed = expression.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            guard let idx = watchExpressions.firstIndex(where: { $0.id == id }) else { return }

            var watches = watchExpressions
            watches[idx].expression = trimmed
            watchExpressions = watches
        }

        func setWatchValue(id: WatchExpression.ID, value: String) {
            guard let idx = watchExpressions.firstIndex(where: { $0.id == id }) else { return }
            var watches = watchExpressions
            watches[idx].value = value
            watchExpressions = watches
        }

        // MARK: - Variables

        func setVariables(_ newVariables: [Variable]) {
            variables = newVariables
        }

        func clearVariables() {
            variables = []
        }

        /// Updates the first variable matching `name` at the root level.
        func setRootVariableValue(name: String, value: String) {
            guard let idx = variables.firstIndex(where: { $0.name == name }) else { return }
            var vars = variables
            vars[idx].value = value
            variables = vars
        }

        func allBreakpointsSorted() -> [(file: String, line: Int)] {
            // Keep existing return type because the current UI code uses it.
            breakpointsByFile
                .flatMap { (file, lines) in lines.map { (file: file, line: $0) } }
                .sorted {
                    if $0.file == $1.file { return $0.line < $1.line }
                    return $0.file < $1.file
                }
        }

        // MARK: - Debug controls

        /// Start or continue debugging.
    func play() {
    // If remote debugger is connected, delegate to it
    if let remote = remoteDebugger, remote.state.isActive {
    Task {
    do {
    if remote.state.canContinue {
    try await remote.continue()
    } else if remote.state == .connected {
    try await remote.run()
    }
    await updateStateFromRemoteDebugger(remote)
    } catch {
    consoleEntries.append(ConsoleEntry(
    message: "Remote debugger error: \(error.localizedDescription)",
    kind: .error
    ))
    }
    }
    return
    }

    // Simulated mode fallback
    // If paused, resume; if stopped, start a simulated session.
    if state == .stopped {
    callStack = [
    StackFrame(function: "main()", file: "App.swift", line: 12),
    StackFrame(function: "run()", file: "Runner.swift", line: 48),
    StackFrame(function: "doWork()", file: "Worker.swift", line: 103)
    ]
    selectedFrameId = callStack.first?.id

    variables = [
    Variable(name: "counter", value: "0", type: "Int"),
    Variable(
    name: "user",
    value: "User(…)",
    type: "User",
    children: [
    Variable(name: "id", value: "42", type: "Int"),
    Variable(name: "name", value: "\"Taylor\"", type: "String")
    ]
    )
    ]

    consoleEntries.append(ConsoleEntry(
    message: "Debug session started.",
    kind: .system
    ))
    }

    state = .running

    // Auto-pause quickly so step buttons make sense in the UI.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
    Task { @MainActor in
    guard let self else { return }
    if self.state == .running {
    self.state = .paused
    self.consoleEntries.append(ConsoleEntry(
    message: "Paused.",
    kind: .system
    ))
    }
    }
    }
    }

        /// Start a real JavaScript debug session
        func startDebugging(code: String, fileName: String, fileId: String) {
            // Clear previous state
            consoleEntries.removeAll()
            callStack.removeAll()
            variables.removeAll()

            // Add system message
            consoleEntries.append(ConsoleEntry(
                message: "Starting debug session for \(fileName)...",
                kind: .system
            ))

            // Set up initial call stack
            callStack = [
                StackFrame(function: "<module>", file: fileName, line: 1)
            ]
            selectedFrameId = callStack.first?.id
            state = .running

            // Run JavaScript with JSRunner
            Task {
                let runner = JSRunner()
                self.activeJSRunner = runner

                // Capture console output
                runner.setConsoleHandler { [weak self] message in
                    Task { @MainActor in
                        guard let self = self else { return }
                        let kind: ConsoleEntry.Kind
                        if message.hasPrefix("[ERROR]") {
                            kind = .error
                        } else if message.hasPrefix("[WARN]") {
                            kind = .warning
                        } else if message.hasPrefix("[INFO]") {
                            kind = .info
                        } else {
                            kind = .output
                        }
                        // Strip prefix for cleaner output
                        let cleanMessage = message
                            .replacingOccurrences(of: "[LOG] ", with: "")
                            .replacingOccurrences(of: "[ERROR] ", with: "")
                            .replacingOccurrences(of: "[WARN] ", with: "")
                            .replacingOccurrences(of: "[INFO] ", with: "")
                        self.consoleEntries.append(ConsoleEntry(message: cleanMessage, kind: kind))
                    }
                }

                do {
                    let result = try await runner.execute(code: code, timeout: 30.0)
                    let resultString = result.toString() ?? ""
                    await MainActor.run {
                        if !resultString.isEmpty && resultString != "undefined" {
                            self.consoleEntries.append(ConsoleEntry(
                                message: "→ \(resultString)",
                                kind: .output
                            ))
                        }
                        self.consoleEntries.append(ConsoleEntry(
                            message: "Debug session ended.",
                            kind: .system
                        ))
                        self.state = .stopped
                        self.callStack.removeAll()
                        self.activeJSRunner = nil
                    }
                } catch {
                    await MainActor.run {
                        self.consoleEntries.append(ConsoleEntry(
                            message: "Error: \(error.localizedDescription)",
                            kind: .error
                        ))
                        self.consoleEntries.append(ConsoleEntry(
                            message: "Debug session ended with error.",
                            kind: .system
                        ))
                        self.state = .stopped
                        self.callStack.removeAll()
                        self.activeJSRunner = nil
                    }
                }
            }
        }

    func stop() {
    // If remote debugger is connected, delegate to it
    if let remote = remoteDebugger, remote.state.isActive {
    Task {
    do {
    try await remote.stop()
    state = .stopped
    callStack = []
    variables = []
    selectedFrameId = nil
    currentLine = nil
    currentFile = nil
    consoleEntries.append(ConsoleEntry(
    message: "Remote debug session stopped.",
    kind: .system
    ))
    } catch {
    consoleEntries.append(ConsoleEntry(
    message: "Failed to stop remote debugger: \(error.localizedDescription)",
    kind: .error
    ))
    }
    }
    return
    }

    // Simulated mode fallback
    let wasActive = state != .stopped
    state = .stopped
    callStack = []
    variables = []
    selectedFrameId = nil
    activeJSRunner = nil
    if wasActive {
    consoleEntries.append(ConsoleEntry(
    message: "Debug session stopped.",
    kind: .system
    ))
    }
    }

    func pause() {
    // If remote debugger is connected and running, delegate to it
    if let remote = remoteDebugger, remote.state == .running {
    Task {
    do {
    try await remote.pause()
    await updateStateFromRemoteDebugger(remote)
    consoleEntries.append(ConsoleEntry(
    message: "Paused.",
    kind: .system
    ))
    } catch {
    consoleEntries.append(ConsoleEntry(
    message: "Failed to pause: \(error.localizedDescription)",
    kind: .error
    ))
    }
    }
    return
    }

    // Simulated mode fallback
    state = .paused
    consoleEntries.append(ConsoleEntry(
    message: "Paused.",
    kind: .system
    ))
    }

    func stepOver() {
    guard state.canStep else { return }

    // If remote debugger is connected, delegate to it
    if let remote = remoteDebugger, remote.state.canStep {
    Task {
    do {
    try await remote.stepOver()
    await updateStateFromRemoteDebugger(remote)
    consoleEntries.append(ConsoleEntry(
    message: "Stepped over.",
    kind: .system
    ))
    } catch {
    consoleEntries.append(ConsoleEntry(
    message: "Step over failed: \(error.localizedDescription)",
    kind: .error
    ))
    }
    }
    return
    }

    // Simulated mode fallback
    advanceTopFrameLine(by: 1)
    consoleEntries.append(ConsoleEntry(
    message: "Stepped over.",
    kind: .system
    ))
    }

    func stepInto() {
    guard state.canStep else { return }

    // If remote debugger is connected, delegate to it
    if let remote = remoteDebugger, remote.state.canStep {
    Task {
    do {
    try await remote.stepInto()
    await updateStateFromRemoteDebugger(remote)
    consoleEntries.append(ConsoleEntry(
    message: "Stepped into.",
    kind: .system
    ))
    } catch {
    consoleEntries.append(ConsoleEntry(
    message: "Step into failed: \(error.localizedDescription)",
    kind: .error
    ))
    }
    }
    return
    }

    // Simulated mode fallback
    advanceTopFrameLine(by: 1)
    // Pretend we stepped into a function.
    if let top = callStack.first {
    var cs = callStack
    cs.insert(StackFrame(function: "helper()", file: top.file, line: top.line), at: 0)
    callStack = cs
    selectedFrameId = callStack.first?.id
    }
    consoleEntries.append(ConsoleEntry(
    message: "Stepped into helper().",
    kind: .system
    ))
    }

    func stepOut() {
    guard state.canStep else { return }

    // If remote debugger is connected, delegate to it
    if let remote = remoteDebugger, remote.state.canStep {
    Task {
    do {
    try await remote.stepOut()
    await updateStateFromRemoteDebugger(remote)
    consoleEntries.append(ConsoleEntry(
    message: "Stepped out.",
    kind: .system
    ))
    } catch {
    consoleEntries.append(ConsoleEntry(
    message: "Step out failed: \(error.localizedDescription)",
    kind: .error
    ))
    }
    }
    return
    }

    // Simulated mode fallback
    advanceTopFrameLine(by: 1)
    if callStack.count > 1 {
    var cs = callStack
    cs.removeFirst()
    callStack = cs
    selectedFrameId = callStack.first?.id
    }
    consoleEntries.append(ConsoleEntry(
    message: "Stepped out.",
    kind: .system
    ))
    }

        func restart() {
            consoleEntries.append(ConsoleEntry(
                message: "Restarting debug session…",
                kind: .system
            ))
            stop()
            play()
        }

        func toggleAllBreakpoints() {
            allBreakpointsEnabled.toggle()
            let status = allBreakpointsEnabled ? "enabled" : "disabled"
            let count = allBreakpoints.count
            consoleEntries.append(ConsoleEntry(
                message: "All breakpoints \(status) (\(count) breakpoint\(count == 1 ? "" : "s")).",
                kind: .system
            ))
        }

        func removeAllBreakpoints() {
            let count = allBreakpoints.count
            let oldBreakpoints = breakpointsByFile
            breakpointsByFile = [:]
            breakpointEnabledStates = [:]
            breakpointConditions = [:]
            allBreakpointsEnabled = true

            // Remove all breakpoints from remote debugger if connected
            if remoteDebugger?.state.isActive == true, !oldBreakpoints.isEmpty {
                Task {
                    do {
                        // Delete all breakpoints at once via the remote debugger
                        let existing = try await remoteDebugger?.listBreakpoints() ?? []
                        for bp in existing {
                            try await remoteDebugger?.removeBreakpoint(id: bp.id)
                        }
                        consoleEntries.append(ConsoleEntry(
                            message: "Removed \(existing.count) remote breakpoint(s).",
                            kind: .system
                        ))
                    } catch {
                        consoleEntries.append(ConsoleEntry(
                            message: "Remote breakpoint clear error: \(error.localizedDescription)",
                            kind: .error
                        ))
                    }
                }
            }

            consoleEntries.append(ConsoleEntry(
                message: "All \(count) breakpoint\(count == 1 ? "" : "s") removed.",
                kind: .system
            ))
        }

        /// Toggle a breakpoint by its composite id string ("file::line").
        func toggleBreakpoint(_ id: String) {
            let parts = id.components(separatedBy: "::")
            guard parts.count == 2, let line = Int(parts[1]) else { return }
            toggleBreakpoint(file: parts[0], line: line)
        }

        /// Remove a breakpoint by its composite id string ("file::line").
        func removeBreakpoint(_ id: String) {
            let parts = id.components(separatedBy: "::")
            guard parts.count == 2, let line = Int(parts[1]) else { return }
            removeBreakpoint(file: parts[0], line: line)
        }
        
        /// Toggle the enabled state of a breakpoint by its composite id string ("file::line").
        func toggleBreakpointEnabled(id: String) {
            let parts = id.components(separatedBy: "::")
            guard parts.count == 2, let line = Int(parts[1]) else { return }
            let file = parts[0]
            
            // Only toggle if the breakpoint exists
            guard hasBreakpoint(file: file, line: line) else { return }
            
            let currentState = breakpointEnabledStates[id] ?? true
            breakpointEnabledStates[id] = !currentState
            
            let newState = !currentState
            let shortName = (file as NSString).lastPathComponent
            consoleEntries.append(ConsoleEntry(
                message: "Breakpoint at \(shortName):\(line + 1) \(newState ? "enabled" : "disabled")",
                kind: .system
            ))
        }
        
        /// Set the condition for a breakpoint by its composite id string ("file::line").
        func setBreakpointCondition(id: String, condition: String?) {
            let parts = id.components(separatedBy: "::")
            guard parts.count == 2, let line = Int(parts[1]) else { return }
            let file = parts[0]
            
            // Only set condition if the breakpoint exists
            guard hasBreakpoint(file: file, line: line) else { return }
            
            if let condition = condition, !condition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                breakpointConditions[id] = condition
            } else {
                breakpointConditions.removeValue(forKey: id)
            }
            
            let shortName = (file as NSString).lastPathComponent
            if let cond = condition, !cond.isEmpty {
                consoleEntries.append(ConsoleEntry(
                    message: "Breakpoint at \(shortName):\(line + 1) condition set to: \(cond)",
                    kind: .system
                ))
            } else {
                consoleEntries.append(ConsoleEntry(
                    message: "Breakpoint at \(shortName):\(line + 1) condition removed",
                    kind: .system
                ))
            }
        }

    private func advanceTopFrameLine(by delta: Int) {
        guard !callStack.isEmpty else { return }
        
        // IMPORTANT: mutate via a copy so @Published emits reliably for collection changes.
        var cs = callStack
        cs[0].line += delta
        callStack = cs
        
        // Make the demo watch expression change a bit.
        if let idx = watchExpressions.firstIndex(where: { $0.expression == "counter" }) {
            var watches = watchExpressions
            let n = Int(watches[idx].value) ?? 0
            watches[idx].value = "\(n + delta)"
            watchExpressions = watches
        }
        
        if let varIdx = variables.firstIndex(where: { $0.name == "counter" }) {
            var vars = variables
            let n = Int(vars[varIdx].value) ?? 0
            vars[varIdx].value = "\(n + delta)"
            variables = vars
        }
    }
    
    // MARK: - Remote Debugger Integration
    
    /// Connect to a remote debugger with the given configuration
    func connectRemoteDebugger(config: RemoteDebuggerConfig, sshConfig: SSHConnectionConfig) async throws {
        let debugger = RemoteDebugger()
        debugger.delegate = RemoteDebuggerDelegateHandler.shared
        
        try await debugger.connect(config: config, sshConfig: sshConfig)
        
        self.remoteDebugger = debugger
        
        consoleEntries.append(ConsoleEntry(
            message: "Connected to remote \(config.debuggerType.displayName) debugger.",
            kind: .system
        ))
        
        // Sync existing local breakpoints to the remote debugger
        await syncBreakpointsToRemoteDebugger()
        
        // Set up delegate handler callbacks
        RemoteDebuggerDelegateHandler.shared.onStateChanged = { [weak self] newState in
            Task { @MainActor in
                self?.handleRemoteDebuggerStateChanged(newState)
            }
        }
        
        RemoteDebuggerDelegateHandler.shared.onStackUpdated = { [weak self] frames in
            Task { @MainActor in
                self?.handleRemoteStackUpdated(frames)
            }
        }
        
        RemoteDebuggerDelegateHandler.shared.onVariablesUpdated = { [weak self] vars in
            Task { @MainActor in
                self?.handleRemoteVariablesUpdated(vars)
            }
        }
    }
    
    /// Disconnect the remote debugger
    func disconnectRemoteDebugger() async {
        await remoteDebugger?.disconnect()
        remoteDebugger = nil
        state = .stopped
        callStack = []
        variables = []
        currentLine = nil
        currentFile = nil
        
        consoleEntries.append(ConsoleEntry(
            message: "Disconnected from remote debugger.",
            kind: .system
        ))
    }

    // MARK: - Breakpoint Sync

    /// Sync all locally-stored breakpoints to the remote debugger.
    /// Called after connecting and whenever the set of breakpoints needs to be pushed.
    private func syncBreakpointsToRemoteDebugger() async {
        guard let remote = remoteDebugger else { return }

        let local = allBreakpoints
        guard !local.isEmpty else { return }

        consoleEntries.append(ConsoleEntry(
            message: "Syncing \(local.count) breakpoint(s) to remote debugger…",
            kind: .system
        ))

        do {
            for bp in local {
                // Remote debugger expects 1-based line numbers
                _ = try await remote.setBreakpoint(file: bp.file, line: bp.line + 1)
            }
            consoleEntries.append(ConsoleEntry(
                message: "Synced \(local.count) breakpoint(s) to remote debugger.",
                kind: .system
            ))
        } catch {
            consoleEntries.append(ConsoleEntry(
                message: "Failed to sync breakpoints: \(error.localizedDescription)",
                kind: .error
            ))
        }
    }
    
    /// Update local state from remote debugger state
    private func updateStateFromRemoteDebugger(_ remote: RemoteDebugger) async {
        // Map remote state to local state
        switch remote.state {
        case .running:
            state = .running
        case .stopped(_):
            state = .paused
            // Update current line/file from top of stack
            if let frame = remote.callStack.first {
                currentLine = frame.line
                currentFile = frame.file
                callStack = remote.callStack.map { remoteFrame in
                    StackFrame(
                        function: remoteFrame.function,
                        file: remoteFrame.file ?? "",
                        line: remoteFrame.line ?? 0
                    )
                }
                selectedFrameId = callStack.first?.id
            }
        case .terminated:
            state = .stopped
            currentLine = nil
            currentFile = nil
        default:
            break
        }
        
        // Update variables
        variables = remote.localVariables.map { remoteVar in
            Variable(
                name: remoteVar.name,
                value: remoteVar.value,
                type: remoteVar.type,
                children: remoteVar.children.map { child in
                    Variable(name: child.name, value: child.value, type: child.type)
                }
            )
        }
    }
    
    // MARK: - Remote Debugger Event Handlers
    
    private func handleRemoteDebuggerStateChanged(_ newState: RemoteDebuggerState) {
        switch newState {
        case .running:
            state = .running
        case .stopped(let reason):
            state = .paused
            if case .breakpoint(let id) = reason {
                consoleEntries.append(ConsoleEntry(
                    message: "Hit breakpoint \(id).",
                    kind: .system
                ))
            }
        case .terminated:
            state = .stopped
            currentLine = nil
            currentFile = nil
            consoleEntries.append(ConsoleEntry(
                message: "Remote debug session terminated.",
                kind: .system
            ))
        default:
            break
        }
    }
    
    private func handleRemoteStackUpdated(_ frames: [RemoteStackFrame]) {
        callStack = frames.map { frame in
            StackFrame(
                function: frame.function,
                file: frame.file ?? "",
                line: frame.line ?? 0
            )
        }
        if let first = callStack.first {
            selectedFrameId = first.id
            currentLine = first.line
            currentFile = first.file
        }
    }
    
    private func handleRemoteVariablesUpdated(_ remoteVars: [RemoteVariable]) {
        variables = remoteVars.map { remoteVar in
            Variable(
                name: remoteVar.name,
                value: remoteVar.value,
                type: remoteVar.type,
                children: remoteVar.children.map { child in
                    Variable(name: child.name, value: child.value, type: child.type)
                }
            )
        }
    }
}

// MARK: - Remote Debugger Delegate Handler

/// Delegate handler for RemoteDebugger events that forwards to closures
final class RemoteDebuggerDelegateHandler: RemoteDebuggerDelegate, @unchecked Sendable {
    static let shared = RemoteDebuggerDelegateHandler()
    
    var onStateChanged: ((RemoteDebuggerState) -> Void)?
    var onStackUpdated: (([RemoteStackFrame]) -> Void)?
    var onVariablesUpdated: (([RemoteVariable]) -> Void)?
    var onOutput: ((String, RemoteDebuggerEvent.OutputType) -> Void)?
    var onError: ((String) -> Void)?
    
    private init() {}
    
    nonisolated func debugger(_ debugger: RemoteDebugger, didReceiveEvent event: RemoteDebuggerEvent) {
        let capturedEvent = event
        Task { @MainActor in
            self.handleEvent(capturedEvent)
        }
    }
    
    @MainActor
    private func handleEvent(_ event: RemoteDebuggerEvent) {
        switch event {
        case .stateChanged(let state):
            onStateChanged?(state)
        case .stackUpdated(let frames):
            onStackUpdated?(frames)
        case .variablesUpdated(let vars):
            onVariablesUpdated?(vars)
        case .output(let text, let type):
            onOutput?(text, type)
        case .error(let message):
            onError?(message)
        case .breakpointHit(let bp, _):
            onStateChanged?(.stopped(reason: .breakpoint(id: bp.id)))
        case .terminated(_):
            onStateChanged?(.terminated)
        default:
            break
        }
    }
}
