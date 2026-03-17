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

        /// Whether this breakpoint is active. Synced to the remote debugger when connected.
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

    /// Active JavaScript debug session (breakpoint-aware execution).
    private var activeDebugSession: JSDebugSession?

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
            // Restore any breakpoints saved in a previous session.
            restoreBreakpoints()
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
                        OutputPanelManager.shared.appendLine(clean, to: .debug, streamType: .stdout)
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
                            OutputPanelManager.shared.appendLine("undefined", to: .debug, streamType: .stdout)
                        } else {
                            self.consoleEntries.append(ConsoleEntry(message: resultString, kind: .output))
                            OutputPanelManager.shared.appendLine(resultString, to: .debug, streamType: .stdout)
                        }
                    }
                } catch {
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        self.consoleEntries.append(ConsoleEntry(
                            message: "Error: \(error.localizedDescription)",
                            kind: .error
                        ))
                        OutputPanelManager.shared.appendLine("Error: \(error.localizedDescription)", to: .debug, streamType: .stderr)
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
                        OutputPanelManager.shared.appendLine("Remote breakpoint sync error: \(error.localizedDescription)", to: .debug, streamType: .stderr)
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
            saveBreakpoints()
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
            saveBreakpoints()

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
                        OutputPanelManager.shared.appendLine("Remote breakpoint remove error: \(error.localizedDescription)", to: .debug, streamType: .stderr)
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
    OutputPanelManager.shared.appendLine("Remote debugger error: \(error.localizedDescription)", to: .debug, streamType: .stderr)
    }
    }
    return
    }

    // Local JS session — resume if paused.
    if state == .paused, let session = activeDebugSession {
        state = .running
        session.resume(mode: .continue)
        return
    }
    if state == .paused {
        // No session but UI says paused — reset.
        state = .stopped
        return
    }
    consoleEntries.append(ConsoleEntry(
        message: "Local JavaScript debugging: Use 'Run File' to start a debug session with breakpoints.",
        kind: .info
    ))
    }

        /// Start a real JavaScript debug session with breakpoint support.
        func startDebugging(code: String, fileName: String, fileId: String) {
            // Cancel any existing session
            activeDebugSession?.cancel()
            activeDebugSession = nil

            // Clear previous state
            consoleEntries.removeAll()
            callStack.removeAll()
            variables.removeAll()
            currentLine = nil
            currentFile = nil

            consoleEntries.append(ConsoleEntry(
                message: "Starting debug session for \(fileName)…",
                kind: .system
            ))

            // Collect enabled breakpoint line numbers (0-based) for this file.
            let bpLines: Set<Int> = {
                let fid = canonicalFileId(fileId)
                let raw = breakpointsByFile[fid] ?? []
                if !allBreakpointsEnabled { return [] }
                return raw.filter { line in
                    let id = "\(fid)::\(line)"
                    return breakpointEnabledStates[id] ?? true
                }
            }()

            // Set up call stack frame
            callStack = [StackFrame(function: "<module>", file: fileName, line: 1)]
            selectedFrameId = callStack.first?.id
            state = .running

            // Create and start the debug session
            let session = JSDebugSession(
                code: code,
                fileName: fileName,
                breakpointLines: bpLines
            )
            activeDebugSession = session
            activeJSRunner = session.runner

            // Forward console output from JSRunner
            session.runner.setConsoleHandler { [weak self] message in
                Task { @MainActor in
                    guard let self else { return }
                    let kind: ConsoleEntry.Kind
                    if message.hasPrefix("[ERROR]") { kind = .error }
                    else if message.hasPrefix("[WARN]") { kind = .warning }
                    else if message.hasPrefix("[INFO]") { kind = .info }
                    else { kind = .output }
                    let clean = message
                        .replacingOccurrences(of: "[LOG] ", with: "")
                        .replacingOccurrences(of: "[ERROR] ", with: "")
                        .replacingOccurrences(of: "[WARN] ", with: "")
                        .replacingOccurrences(of: "[INFO] ", with: "")
                    self.consoleEntries.append(ConsoleEntry(message: clean, kind: kind))
                    OutputPanelManager.shared.appendLine(clean, to: .debug, streamType: .stdout)
                }
            }

            Task {
                for await event in session.eventStream {
                    switch event {
                    case .paused(let line, let vars):
                        // line is 0-based internally; display as 1-based
                        let displayLine = line + 1
                        currentLine = displayLine
                        currentFile = fileName
                        var cs = callStack
                        if !cs.isEmpty { cs[0].line = displayLine }
                        callStack = cs
                        selectedFrameId = callStack.first?.id
                        variables = vars
                        state = .paused
                        consoleEntries.append(ConsoleEntry(
                            message: "Paused at \(fileName):\(displayLine)",
                            kind: .system
                        ))
                        // Refresh watch expressions
                        await refreshWatchExpressions(using: session.runner)

                    case .resumed:
                        state = .running

                    case .finished(let resultString):
                        if let r = resultString, !r.isEmpty, r != "undefined" {
                            consoleEntries.append(ConsoleEntry(message: "→ \(r)", kind: .output))
                            OutputPanelManager.shared.appendLine("→ \(r)", to: .debug, streamType: .stdout)
                        }
                        consoleEntries.append(ConsoleEntry(message: "Debug session ended.", kind: .system))
                        state = .stopped
                        callStack.removeAll()
                        variables.removeAll()
                        currentLine = nil
                        currentFile = nil
                        activeDebugSession = nil
                        activeJSRunner = nil

                    case .error(let message):
                        consoleEntries.append(ConsoleEntry(message: "Error: \(message)", kind: .error))
                        OutputPanelManager.shared.appendLine("Error: \(message)", to: .debug, streamType: .stderr)
                        consoleEntries.append(ConsoleEntry(message: "Debug session ended with error.", kind: .system))
                        state = .stopped
                        callStack.removeAll()
                        variables.removeAll()
                        currentLine = nil
                        currentFile = nil
                        activeDebugSession = nil
                        activeJSRunner = nil
                    }
                }
            }

            // Launch execution
            Task { await session.run() }
        }

        /// Evaluate all watch expressions using the current JS context.
        private func refreshWatchExpressions(using runner: JSRunner) async {
            guard !watchExpressions.isEmpty else { return }
            var updated = watchExpressions
            for i in updated.indices {
                let expr = updated[i].expression
                if let val = try? await runner.executeToString(code: expr) {
                    updated[i].value = val ?? "undefined"
                } else {
                    updated[i].value = "<error>"
                }
            }
            watchExpressions = updated
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
    OutputPanelManager.shared.appendLine("Failed to stop remote debugger: \(error.localizedDescription)", to: .debug, streamType: .stderr)
    }
    }
    return
    }

    // Local JS session fallback
    let wasActive = state != .stopped
    activeDebugSession?.cancel()
    activeDebugSession = nil
    state = .stopped
    callStack = []
    variables = []
    selectedFrameId = nil
    currentLine = nil
    currentFile = nil
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
    OutputPanelManager.shared.appendLine("Failed to pause: \(error.localizedDescription)", to: .debug, streamType: .stderr)
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
    OutputPanelManager.shared.appendLine("Step over failed: \(error.localizedDescription)", to: .debug, streamType: .stderr)
    }
    }
    return
    }

    // Local JS debug session — advance to next breakpoint.
    if let session = activeDebugSession {
        state = .running
        session.resume(mode: .stepOver)
        return
    }

    consoleEntries.append(ConsoleEntry(
        message: "No active debug session. Use Run to start debugging.",
        kind: .info
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
    OutputPanelManager.shared.appendLine("Step into failed: \(error.localizedDescription)", to: .debug, streamType: .stderr)
    }
    }
    return
    }

    // Local JS debug session — stepInto behaves like stepOver at top level.
    if let session = activeDebugSession {
        state = .running
        session.resume(mode: .stepInto)
        return
    }

    consoleEntries.append(ConsoleEntry(
        message: "No active debug session. Use Run to start debugging.",
        kind: .info
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
    OutputPanelManager.shared.appendLine("Step out failed: \(error.localizedDescription)", to: .debug, streamType: .stderr)
    }
    }
    return
    }

    // Local JS debug session — stepOut runs to next breakpoint or end.
    if let session = activeDebugSession {
        state = .running
        session.resume(mode: .stepOut)
        return
    }

    consoleEntries.append(ConsoleEntry(
        message: "No active debug session. Use Run to start debugging.",
        kind: .info
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
                        OutputPanelManager.shared.appendLine("Remote breakpoint clear error: \(error.localizedDescription)", to: .debug, streamType: .stderr)
                    }
                }
            }

            consoleEntries.append(ConsoleEntry(
                message: "All \(count) breakpoint\(count == 1 ? "" : "s") removed.",
                kind: .system
            ))
            saveBreakpoints()
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
            saveBreakpoints()
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
            saveBreakpoints()
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
        
        RemoteDebuggerDelegateHandler.shared.onOutput = { [weak self] text, type in
            Task { @MainActor in
                guard let self = self else { return }
                let kind: ConsoleEntry.Kind = (type == .stderr) ? .error : .output
                self.consoleEntries.append(ConsoleEntry(
                    message: text,
                    kind: kind
                ))
                OutputPanelManager.shared.appendLine(text, to: .debug, streamType: (type == .stderr) ? .stderr : .stdout)
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
            OutputPanelManager.shared.appendLine("Failed to sync breakpoints: \(error.localizedDescription)", to: .debug, streamType: .stderr)
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
            if case .exception(let description) = reason {
                consoleEntries.append(ConsoleEntry(
                    message: "Exception: \(description)",
                    kind: .error
                ))
                OutputPanelManager.shared.appendLine("Exception: \(description)", to: .debug, streamType: .stderr)
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

    // MARK: - Breakpoint Persistence

    /// Codable mirror of `Breakpoint` used exclusively for UserDefaults persistence.
    private struct PersistedBreakpoint: Codable {
        var file: String
        var line: Int
        var isEnabled: Bool
        var condition: String?
    }

    private static let breakpointsPersistenceKey = "DebugManager.persistedBreakpoints"

    /// Serialize the current breakpoint state and write it to UserDefaults.
    private func saveBreakpoints() {
        let records: [PersistedBreakpoint] = allBreakpoints.map { bp in
            PersistedBreakpoint(
                file: bp.file,
                line: bp.line,
                isEnabled: bp.isEnabled,
                condition: bp.condition
            )
        }
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: Self.breakpointsPersistenceKey)
        }
    }

    /// Read breakpoints from UserDefaults and restore them into the in-memory state.
    private func restoreBreakpoints() {
        guard let data = UserDefaults.standard.data(forKey: Self.breakpointsPersistenceKey),
              let records = try? JSONDecoder().decode([PersistedBreakpoint].self, from: data)
        else { return }

        var dict: [String: Set<Int>] = [:]
        var enabledStates: [String: Bool] = [:]
        var conditions: [String: String] = [:]

        for record in records {
            let fileId = canonicalFileId(record.file)
            let line   = canonicalLine(record.line)
            dict[fileId, default: []].insert(line)
            let id = "\(fileId)::\(line)"
            if !record.isEnabled {
                enabledStates[id] = false
            }
            if let cond = record.condition, !cond.isEmpty {
                conditions[id] = cond
            }
        }

        breakpointsByFile       = dict
        breakpointEnabledStates = enabledStates
        breakpointConditions    = conditions
    }
}

// MARK: - JSDebugSession

/// A self-contained JavaScript debug session that supports real breakpoint pausing.
///
/// ## How it works
/// 1. The source is split into lines.
/// 2. Lines are grouped into *segments*: each segment ends just before a breakpoint line
///    (or at the last line of the file).
/// 3. Segments are executed sequentially on a **shared** `JSRunner` context so variables
///    declared in earlier segments remain visible in later ones.
/// 4. Before executing a segment that ends at a breakpoint line, the runner pauses by
///    suspending via an `AsyncStream`. Resuming (stepOver / stepInto / stepOut / continue)
///    unblocks the awaiting task and proceeds to the next segment.
///
/// ### Limitations (deliberate simplification)
/// - Breakpoints inside function bodies only fire when the function is called sequentially in
///   the top-level execution flow (i.e., not in callbacks/promises resolved later).
/// - `stepInto` is equivalent to `stepOver` at the module level.
/// - `stepOut` runs straight to the next breakpoint.
@MainActor
final class JSDebugSession {

    // MARK: - Public types

    enum ResumeMode {
        case `continue`   // run to next breakpoint or end
        case stepOver     // same as continue at top-level
        case stepInto     // same as stepOver here
        case stepOut      // same as continue here
    }

    enum Event {
        case paused(line: Int, variables: [DebugManager.Variable])
        case resumed
        case finished(result: String?)
        case error(String)
    }

    // MARK: - Public properties

    let runner: JSRunner

    /// Async stream of events consumed by DebugManager.
    private(set) var eventStream: AsyncStream<Event>!

    // MARK: - Private state

    private let source: String
    private let fileName: String
    private let breakpointLines: Set<Int>   // 0-based line indices
    private var isCancelled = false

    /// Continuation used to suspend execution until the UI resumes the session.
    private var resumeContinuation: CheckedContinuation<ResumeMode, Never>?

    /// AsyncStream continuation used to push events to DebugManager.
    private var streamContinuation: AsyncStream<Event>.Continuation?

    // MARK: - Init

    init(code: String, fileName: String, breakpointLines: Set<Int>) {
        self.source = code
        self.fileName = fileName
        self.breakpointLines = breakpointLines
        self.runner = JSRunner()

        eventStream = AsyncStream { [weak self] continuation in
            self?.streamContinuation = continuation
        }
    }

    // MARK: - Public API

    /// Resume execution after a breakpoint pause.
    func resume(mode: ResumeMode) {
        resumeContinuation?.resume(returning: mode)
        resumeContinuation = nil
    }

    /// Cancel the session immediately.
    func cancel() {
        isCancelled = true
        resumeContinuation?.resume(returning: .continue)
        resumeContinuation = nil
        streamContinuation?.finish()
    }

    // MARK: - Execution

    /// Start executing the instrumented source. Call this from a detached Task.
    func run() async {
        guard !isCancelled else { return }

        let lines = source.components(separatedBy: "\n")
        let totalLines = lines.count

        // Build segments: a segment is a half-open range [start, end) of line indices.
        // A new segment begins after each breakpoint line; we pause *before* the breakpoint line.
        var segments: [(range: Range<Int>, pauseLine: Int?)] = []
        var segStart = 0

        // Sorted 0-based breakpoint indices that exist in the source
        let sortedBPs = breakpointLines
            .filter { $0 >= 0 && $0 < totalLines }
            .sorted()

        if sortedBPs.isEmpty {
            // No breakpoints — single segment, no pausing
            segments.append((range: 0..<totalLines, pauseLine: nil))
        } else {
            for bp in sortedBPs {
                if bp > segStart {
                    // Lines before the breakpoint (no pause at end of this group)
                    segments.append((range: segStart..<bp, pauseLine: nil))
                }
                // The breakpoint line itself is its own segment; we pause before running it
                segments.append((range: bp..<(bp + 1), pauseLine: bp))
                segStart = bp + 1
            }
            // Remaining lines after last breakpoint
            if segStart < totalLines {
                segments.append((range: segStart..<totalLines, pauseLine: nil))
            }
        }

        // Execute each segment in order
        for segment in segments {
            guard !isCancelled else { break }

            // If this segment has a pause line, pause first
            if let pauseLine = segment.pauseLine {
                // Snapshot variables from the JS context
                let vars = await captureVariables()

                // Emit paused event
                streamContinuation?.yield(.paused(line: pauseLine, variables: vars))

                // Suspend here until UI resumes
                let mode = await withCheckedContinuation { (cont: CheckedContinuation<ResumeMode, Never>) in
                    resumeContinuation = cont
                }

                guard !isCancelled else { break }
                streamContinuation?.yield(.resumed)

                // For stepOver/stepInto we still execute this line then stop at next BP.
                // For stepOut / continue we run through to next BP.
                // In all cases we just continue running the segment as normal —
                // the segment loop will naturally pause again at the next breakpoint.
                _ = mode  // All modes behave identically at top-level: run to next BP
            }

            // Build the code for this segment
            let segmentLines = Array(lines[segment.range])
            let segmentCode = segmentLines.joined(separator: "\n")

            guard !segmentCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                continue
            }

            do {
                let result = try await runner.execute(code: segmentCode, timeout: 30.0)
                // Only emit the final result on the last segment
                if segment.range.upperBound >= totalLines {
                    let str = result.isUndefined ? nil : result.toString()
                    streamContinuation?.yield(.finished(result: str))
                    streamContinuation?.finish()
                    return
                }
            } catch {
                streamContinuation?.yield(.error(error.localizedDescription))
                streamContinuation?.finish()
                return
            }
        }

        if !isCancelled {
            streamContinuation?.yield(.finished(result: nil))
        }
        streamContinuation?.finish()
    }

    // MARK: - Variable capture

    /// Snapshot the current JS global/local variables from the runner context.
    private func captureVariables() async -> [DebugManager.Variable] {
        // We ask the JS context for all non-builtin keys on the global object.
        // This is a best-effort inspection using Object.keys on the global scope.
        let script = """
        (function() {
          var __builtins = ['undefined','NaN','Infinity','eval','isFinite','isNaN',
            'parseFloat','parseInt','decodeURI','decodeURIComponent','encodeURI',
            'encodeURIComponent','Object','Function','Array','Number','parseFloat',
            'parseInt','Boolean','String','Symbol','BigInt','Math','Date','RegExp',
            'Error','Map','Set','WeakMap','WeakSet','Promise','Proxy','Reflect',
            'JSON','console','__builtins'];
          var keys = [];
          try { keys = Object.getOwnPropertyNames(this).filter(function(k){
            return __builtins.indexOf(k) === -1 && k[0] !== '_';
          }); } catch(e) {}
          var result = [];
          for (var i = 0; i < keys.length; i++) {
            var k = keys[i];
            try {
              var v = this[k];
              var t = typeof v;
              var s;
              if (v === null) { s = 'null'; t = 'null'; }
              else if (t === 'function') { s = '[Function]'; }
              else if (t === 'object') {
                try { s = JSON.stringify(v); } catch(e) { s = String(v); }
              } else { s = String(v); }
              result.push(k + '|||' + t + '|||' + s);
            } catch(e) { result.push(k + '|||unknown|||<error>'); }
          }
          return result.join(';;;');
        }).call(this);
        """

        guard let raw = try? await runner.executeToString(code: script),
              let text = raw, !text.isEmpty else {
            return []
        }

        return text.components(separatedBy: ";;;").compactMap { entry -> DebugManager.Variable? in
            let parts = entry.components(separatedBy: "|||")
            guard parts.count == 3 else { return nil }
            let name = parts[0]
            let type_ = parts[1]
            let value = parts[2]
            guard !name.isEmpty else { return nil }
            return DebugManager.Variable(name: name, value: value, type: type_)
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
