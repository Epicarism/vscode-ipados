//
//  BreakpointGutterView.swift
//  VSCodeiPadOS
//
//  Native breakpoint gutter overlay for the code editor.
//  Shows breakpoint indicators in the left gutter, supports
//  tap-to-toggle, long-press for conditional breakpoints,
//  and persists state per file.
//

import SwiftUI
import os

// MARK: - Breakpoint Types

enum BreakpointType: String, Codable, CaseIterable {
    case normal = "normal"
    case conditional = "conditional"
    case hitCount = "hitCount"
    case logPoint = "logPoint"
    
    var color: Color {
        switch self {
        case .normal: return .red
        case .conditional: return .orange
        case .hitCount: return .yellow
        case .logPoint: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .normal: return "circle.fill"
        case .conditional: return "questionmark.circle.fill"
        case .hitCount: return "number.circle.fill"
        case .logPoint: return "text.bubble.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .normal: return "Breakpoint"
        case .conditional: return "Conditional Breakpoint"
        case .hitCount: return "Hit Count Breakpoint"
        case .logPoint: return "Log Point"
        }
    }
}

// MARK: - Breakpoint Model

struct Breakpoint: Identifiable, Codable, Hashable {
    let id: UUID
    var line: Int              // 1-based line number
    var isEnabled: Bool
    var type: BreakpointType
    var condition: String?     // For conditional breakpoints
    var hitCount: Int?         // For hit-count breakpoints
    var logMessage: String?    // For log points
    
    init(line: Int, type: BreakpointType = .normal, isEnabled: Bool = true) {
        self.id = UUID()
        self.line = line
        self.type = type
        self.isEnabled = isEnabled
    }
}

// MARK: - Breakpoint Store

@MainActor
final class BreakpointStore: ObservableObject {
    
    static let shared = BreakpointStore()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "BreakpointStore")
    
    @Published private(set) var breakpoints: [String: [Breakpoint]] = [:] // keyed by filePath
    
    private let persistenceKey = "breakpointStore_v1"
    
    init() {
        loadFromDisk()
        // Observe DebugManager breakpoint changes to stay in sync
        NotificationCenter.default.addObserver(
            forName: .debugBreakpointsChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.syncFromDebugManager()
        }
    }
    
    /// Sync breakpoints from DebugManager into BreakpointStore
    private func syncFromDebugManager() {
        let debugManager = DebugManager.shared
        
        // Iterate all files tracked by DebugManager
        for (filePath, lineSet) in debugManager.breakpointsByFile {
            var synced: [Breakpoint] = []
            
            for line in lineSet {
                let key = "\(filePath)::\(line)"
                let isEnabled = debugManager.breakpointEnabledStates[key] ?? true
                let condition = debugManager.breakpointConditions[key]
                
                // Check if we already have this breakpoint locally
                if var existing = breakpoints[filePath]?.first(where: { $0.line == line + 1 }) {
                    // Update from debug manager (DebugManager uses 0-based, we use 1-based)
                    existing.isEnabled = isEnabled
                    if let cond = condition, !cond.isEmpty {
                        existing.type = .conditional
                        existing.condition = cond
                    }
                    synced.append(existing)
                } else {
                    // Create new breakpoint (convert 0-based to 1-based)
                    var bp = Breakpoint(line: line + 1, type: .normal, isEnabled: isEnabled)
                    if let cond = condition, !cond.isEmpty {
                        bp.type = .conditional
                        bp.condition = cond
                    }
                    synced.append(bp)
                }
            }
            
            breakpoints[filePath] = synced
        }
        
        // Remove local breakpoints for files no longer in DebugManager
        let debugFiles = Set(debugManager.breakpointsByFile.keys)
        for filePath in breakpoints.keys {
            if !debugFiles.contains(filePath) && !(debugManager.breakpointsByFile[filePath]?.isEmpty ?? true) {
                // Keep local breakpoints for files not tracked by debug manager
                // Only remove if debug manager explicitly has the file with empty set
            }
        }
        
        saveToDisk()
    }
    
    // MARK: - Query
    
    func breakpoints(for filePath: String) -> [Breakpoint] {
        breakpoints[filePath] ?? []
    }
    
    func breakpoint(at line: Int, in filePath: String) -> Breakpoint? {
        breakpoints[filePath]?.first(where: { $0.line == line })
    }
    
    func hasBreakpoint(at line: Int, in filePath: String) -> Bool {
        breakpoints[filePath]?.contains(where: { $0.line == line }) ?? false
    }
    
    func activeBreakpointLines(for filePath: String) -> Set<Int> {
        Set(breakpoints(for: filePath).filter { $0.isEnabled }.map { $0.line })
    }
    
    func disabledBreakpointLines(for filePath: String) -> Set<Int> {
        Set(breakpoints(for: filePath).filter { !$0.isEnabled }.map { $0.line })
    }
    
    // MARK: - Mutations
    
    func toggleBreakpoint(at line: Int, in filePath: String) {
        if let index = breakpoints[filePath]?.firstIndex(where: { $0.line == line }) {
            // Remove existing breakpoint
            breakpoints[filePath]?.remove(at: index)
            if breakpoints[filePath]?.isEmpty == true {
                breakpoints.removeValue(forKey: filePath)
            }
        } else {
            // Add new breakpoint
            let bp = Breakpoint(line: line)
            if breakpoints[filePath] == nil {
                breakpoints[filePath] = []
            }
            breakpoints[filePath]?.append(bp)
        }
        notifyChange(filePath: filePath)
        saveToDisk()
        // Sync to DebugManager for remote debugging
        syncToDebugManager(at: line, in: filePath, added: breakpoints[filePath]?.contains(where: { $0.line == line }) ?? false)
    }
    
    /// Forward breakpoint changes to DebugManager for remote debugger sync
    private func syncToDebugManager(at line: Int, in filePath: String, added: Bool) {
        Task { @MainActor in
            let debugManager = DebugManager.shared
            // BreakpointStore uses 1-based lines; DebugManager uses 0-based
            let debugLine = line - 1
            let hasInDebugger = debugManager.hasBreakpoint(file: filePath, line: debugLine)
            if added && !hasInDebugger {
                debugManager.toggleBreakpoint(file: filePath, line: debugLine)
            } else if !added && hasInDebugger {
                debugManager.toggleBreakpoint(file: filePath, line: debugLine)
            }
        }
    }
    
    func toggleEnabled(at line: Int, in filePath: String) {
        guard let index = breakpoints[filePath]?.firstIndex(where: { $0.line == line }) else { return }
        breakpoints[filePath]?[index].isEnabled.toggle()
        notifyChange(filePath: filePath)
        saveToDisk()
    }
    
    func setConditional(at line: Int, in filePath: String, condition: String) {
        ensureBreakpoint(at: line, in: filePath)
        guard let index = breakpoints[filePath]?.firstIndex(where: { $0.line == line }) else { return }
        breakpoints[filePath]?[index].type = .conditional
        breakpoints[filePath]?[index].condition = condition
        notifyChange(filePath: filePath)
        saveToDisk()
    }
    
    func setHitCount(at line: Int, in filePath: String, count: Int) {
        ensureBreakpoint(at: line, in: filePath)
        guard let index = breakpoints[filePath]?.firstIndex(where: { $0.line == line }) else { return }
        breakpoints[filePath]?[index].type = .hitCount
        breakpoints[filePath]?[index].hitCount = count
        notifyChange(filePath: filePath)
        saveToDisk()
    }
    
    func setLogPoint(at line: Int, in filePath: String, message: String) {
        ensureBreakpoint(at: line, in: filePath)
        guard let index = breakpoints[filePath]?.firstIndex(where: { $0.line == line }) else { return }
        breakpoints[filePath]?[index].type = .logPoint
        breakpoints[filePath]?[index].logMessage = message
        notifyChange(filePath: filePath)
        saveToDisk()
    }
    
    func removeBreakpoint(at line: Int, in filePath: String) {
        breakpoints[filePath]?.removeAll(where: { $0.line == line })
        if breakpoints[filePath]?.isEmpty == true {
            breakpoints.removeValue(forKey: filePath)
        }
        notifyChange(filePath: filePath)
        saveToDisk()
    }
    
    func removeAllBreakpoints(in filePath: String) {
        breakpoints.removeValue(forKey: filePath)
        notifyChange(filePath: filePath)
        saveToDisk()
    }
    
    func removeAllBreakpoints() {
        let files = Array(breakpoints.keys)
        breakpoints.removeAll()
        for file in files {
            notifyChange(filePath: file)
        }
        saveToDisk()
    }
    
    // MARK: - Line Shift Support
    
    /// Adjusts breakpoint lines when text is inserted/deleted above them
    func adjustForEdit(in filePath: String, editedLine: Int, linesDelta: Int) {
        guard var bps = breakpoints[filePath], !bps.isEmpty else { return }
        var changed = false
        for i in bps.indices {
            if bps[i].line > editedLine {
                bps[i].line = max(1, bps[i].line + linesDelta)
                changed = true
            } else if bps[i].line == editedLine && linesDelta < 0 {
                // Line was deleted — remove the breakpoint
                bps[i].line = -1 // mark for removal
                changed = true
            }
        }
        if changed {
            bps.removeAll(where: { $0.line < 1 })
            breakpoints[filePath] = bps.isEmpty ? nil : bps
            notifyChange(filePath: filePath)
            saveToDisk()
        }
    }
    
    // MARK: - Private
    
    private func ensureBreakpoint(at line: Int, in filePath: String) {
        if breakpoints[filePath]?.contains(where: { $0.line == line }) != true {
            if breakpoints[filePath] == nil {
                breakpoints[filePath] = []
            }
            breakpoints[filePath]?.append(Breakpoint(line: line))
        }
    }
    
    private func notifyChange(filePath: String) {
        NotificationCenter.default.post(
            name: .breakpointsDidChange,
            object: nil,
            userInfo: ["filePath": filePath]
        )
        Self.logger.debug("Breakpoints changed for \(filePath): \(self.breakpoints[filePath]?.count ?? 0) breakpoints")
    }
    
    // MARK: - Persistence
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(breakpoints)
            UserDefaults.standard.set(data, forKey: persistenceKey)
        } catch {
            Self.logger.error("Failed to save breakpoints: \(error)")
        }
    }
    
    private func loadFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey) else { return }
        do {
            breakpoints = try JSONDecoder().decode([String: [Breakpoint]].self, from: data)
            Self.logger.info("Loaded breakpoints for \(self.breakpoints.count) files")
        } catch {
            Self.logger.error("Failed to load breakpoints: \(error)")
        }
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let breakpointsDidChange = Notification.Name("breakpointsDidChange")
    static let debugBreakpointsChanged = Notification.Name("debugBreakpointsChanged")
}

// MARK: - Breakpoint Gutter View

struct BreakpointGutterView: View {
    
    let filePath: String
    let visibleLineRange: Range<Int>    // 1-based, end-exclusive
    let lineHeight: CGFloat
    let contentTopInset: CGFloat
    let scrollOffset: CGFloat
    
    @ObservedObject private var store = BreakpointStore.shared
    @State private var showingConditionEditor = false
    @State private var editingLine: Int = 0
    @State private var conditionText: String = ""
    @State private var selectedBreakpointType: BreakpointType = .conditional
    
    private let gutterWidth: CGFloat = 28
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Breakpoint indicators
            ForEach(visibleBreakpoints, id: \.line) { bp in
                breakpointIndicator(for: bp)
                    .position(
                        x: gutterWidth / 2,
                        y: yPosition(for: bp.line)
                    )
            }
            
            // Tap targets for empty gutter lines
            ForEach(visibleLineRange.lowerBound..<visibleLineRange.upperBound, id: \.self) { line in
                if !store.hasBreakpoint(at: line, in: filePath) {
                    Color.clear
                        .frame(width: gutterWidth, height: lineHeight)
                        .contentShape(Rectangle())
                        .position(
                            x: gutterWidth / 2,
                            y: yPosition(for: line)
                        )
                        .onTapGesture {
                            store.toggleBreakpoint(at: line, in: filePath)
                        }
                }
            }
        }
        .frame(width: gutterWidth)
        .sheet(isPresented: $showingConditionEditor) {
            conditionEditorSheet
        }
    }
    
    // MARK: - Computed
    
    private var visibleBreakpoints: [Breakpoint] {
        let foldingManager = CodeFoldingManager.shared
        return store.breakpoints(for: filePath).filter { bp in
            // Skip breakpoints on folded/hidden lines
            if foldingManager.isLineHidden(fileId: filePath, line: bp.line - 1) {
                return false
            }
            return visibleLineRange.contains(bp.line)
        }
    }
    
    private func yPosition(for line: Int) -> CGFloat {
        // Account for folded lines when calculating Y position
        let foldingManager = CodeFoldingManager.shared
        let displayLine = foldingManager.sourceLineToDisplayLine(fileId: filePath, sourceLine: line - 1)
        let displayStart = foldingManager.sourceLineToDisplayLine(fileId: filePath, sourceLine: visibleLineRange.lowerBound - 1)
        let lineIndex = CGFloat(displayLine - displayStart)
        return contentTopInset + (lineIndex + 0.5) * lineHeight
    }
    
    // MARK: - Breakpoint Indicator
    
    @ViewBuilder
    private func breakpointIndicator(for bp: Breakpoint) -> some View {
        let size: CGFloat = min(lineHeight - 4, 16)
        
        Group {
            if bp.isEnabled {
                Image(systemName: bp.type.icon)
                    .font(.system(size: size))
                    .foregroundColor(bp.type.color)
            } else {
                Image(systemName: "circle")
                    .font(.system(size: size))
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
        .frame(width: gutterWidth, height: lineHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            store.toggleBreakpoint(at: bp.line, in: filePath)
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            editingLine = bp.line
            conditionText = bp.condition ?? ""
            selectedBreakpointType = bp.type
            showingConditionEditor = true
        }
        .accessibilityLabel("\(bp.type.displayName) at line \(bp.line)")
        .accessibilityHint(bp.isEnabled ? "Double tap to remove" : "Double tap to remove, disabled")
    }
    
    // MARK: - Condition Editor Sheet
    
    private var conditionEditorSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Breakpoint Type")) {
                    Picker("Type", selection: $selectedBreakpointType) {
                        ForEach(BreakpointType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                switch selectedBreakpointType {
                case .conditional:
                    Section(header: Text("Condition")) {
                        TextField("e.g. count > 10", text: $conditionText)
                            .font(.system(.body, design: .monospaced))
                            .autocapitalization(.none)
                    }
                case .hitCount:
                    Section(header: Text("Hit Count")) {
                        TextField("e.g. 5", text: $conditionText)
                            .keyboardType(.numberPad)
                    }
                case .logPoint:
                    Section(header: Text("Log Message")) {
                        TextField("e.g. Value is {x}", text: $conditionText)
                            .font(.system(.body, design: .monospaced))
                            .autocapitalization(.none)
                    }
                    Section(footer: Text("Use {expression} for interpolation. The debugger will NOT pause.")) {
                        EmptyView()
                    }
                case .normal:
                    EmptyView()
                }
                
                Section {
                    Button("Toggle Enabled") {
                        store.toggleEnabled(at: editingLine, in: filePath)
                    }
                    Button("Remove Breakpoint", role: .destructive) {
                        store.removeBreakpoint(at: editingLine, in: filePath)
                        showingConditionEditor = false
                    }
                }
            }
            .navigationTitle("Edit Breakpoint — Line \(editingLine)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingConditionEditor = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        applyConditionEdit()
                        showingConditionEditor = false
                    }
                }
            }
        }
    }
    
    private func applyConditionEdit() {
        switch selectedBreakpointType {
        case .conditional:
            store.setConditional(at: editingLine, in: filePath, condition: conditionText)
        case .hitCount:
            if let count = Int(conditionText) {
                store.setHitCount(at: editingLine, in: filePath, count: count)
            }
        case .logPoint:
            store.setLogPoint(at: editingLine, in: filePath, message: conditionText)
        case .normal:
            // Just ensure it exists as normal type
            if !store.hasBreakpoint(at: editingLine, in: filePath) {
                store.toggleBreakpoint(at: editingLine, in: filePath)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct BreakpointGutterView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 0) {
            BreakpointGutterView(
                filePath: "/test/file.swift",
                visibleLineRange: 1..<30,
                lineHeight: 20,
                contentTopInset: 0,
                scrollOffset: 0
            )
            Rectangle()
                .fill(Color(.systemBackground))
        }
        .frame(height: 600)
        .preferredColorScheme(.dark)
    }
}
#endif
