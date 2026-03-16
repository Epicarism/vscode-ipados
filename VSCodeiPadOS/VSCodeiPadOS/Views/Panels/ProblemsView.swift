import SwiftUI

// MARK: - DiagnosticItem Model

struct DiagnosticItem: Identifiable, Equatable {
    let id: UUID
    let message: String
    let file: String
    let line: Int
    let column: Int
    let severity: DiagnosticSeverity

    init(id: UUID = UUID(), message: String, file: String, line: Int, column: Int, severity: DiagnosticSeverity) {
        self.id = id
        self.message = message
        self.file = file
        self.line = line
        self.column = column
        self.severity = severity
    }

    // Parse from a notification userInfo dictionary (keyed by DiagnosticItem keys)
    init?(userInfo: [String: Any]) {
        guard let message = userInfo["message"] as? String,
              let file = userInfo["file"] as? String,
              let line = userInfo["line"] as? Int,
              let column = userInfo["column"] as? Int,
              let severityRaw = userInfo["severity"] as? String,
              let severity = DiagnosticSeverity(rawValue: severityRaw) else {
            return nil
        }
        let id = userInfo["id"] as? UUID ?? UUID()
        self.id = id
        self.message = message
        self.file = file
        self.line = line
        self.column = column
        self.severity = severity
    }
    
    var fileName: String {
        (file as NSString).lastPathComponent
    }
}

enum DiagnosticSeverity: String, CaseIterable, Identifiable {
    case error
    case warning
    case info
    
    var id: String { rawValue }
}

// MARK: - Notification Name

extension Notification.Name {
    static let diagnosticsUpdated = Notification.Name("diagnosticsUpdated")
}

// MARK: - Problem Row View

struct ProblemRowView: View {
    let problem: DiagnosticItem
    @StateObject private var themeManager = ThemeManager.shared
    
    private var theme: Theme { themeManager.currentTheme }
    
    var body: some View {
        Button(action: {
            // Navigate to file:line
            navigateToProblem()
        }) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: iconName(for: problem.severity))
                    .foregroundColor(color(for: problem.severity))
                    .font(.system(size: 12))
                    .frame(width: 16)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text(problem.message)
                        .font(.system(size: 13))
                        .foregroundColor(theme.editorForeground)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Text(problem.fileName)
                            .font(.system(size: 11))
                            .foregroundColor(theme.comment)
                        Text("[\(problem.line):\(problem.column)]")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(theme.comment.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .contextMenu {
            Button(action: {
                navigateToProblem()
            }) {
                Label("Go to File", systemImage: "arrow.right.circle")
            }
            
            Button(action: {
                UIPasteboard.general.string = problem.message
            }) {
                Label("Copy Message", systemImage: "doc.on.doc")
            }
            
            Button(action: {
                let fullText = "\(problem.severity.rawValue.uppercased()): \(problem.message)\nFile: \(problem.file)\nLine: \(problem.line), Column: \(problem.column)"
                UIPasteboard.general.string = fullText
            }) {
                Label("Copy Full Details", systemImage: "doc.on.clipboard")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(problem.severity.rawValue): \(problem.message), in \(problem.fileName) line \(problem.line)")
        .accessibilityHint("Double tap to navigate to this problem")
    }
    
    private func navigateToProblem() {
        // Post notification to open file at line
        NotificationCenter.default.post(
            name: .navigateToFile,
            object: nil,
            userInfo: [
                "file": problem.file,
                "line": problem.line,
                "column": problem.column
            ]
        )
    }
    
    private func iconName(for severity: DiagnosticSeverity) -> String {
        switch severity {
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    private func color(for severity: DiagnosticSeverity) -> Color {
        switch severity {
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

// MARK: - File Group View

struct FileGroupView: View {
    let file: String
    let problems: [DiagnosticItem]
    @State private var isExpanded: Bool = true
    @StateObject private var themeManager = ThemeManager.shared
    
    private var theme: Theme { themeManager.currentTheme }
    private var fileName: String { (file as NSString).lastPathComponent }
    private var errorCount: Int { problems.filter { $0.severity == .error }.count }
    private var warningCount: Int { problems.filter { $0.severity == .warning }.count }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // File header
            Button(action: { isExpanded.toggle() }) {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(theme.comment)
                        .frame(width: 12)
                    
                    Image(systemName: "doc.text")
                        .font(.system(size: 11))
                        .foregroundColor(theme.comment)
                    
                    Text(fileName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.editorForeground)
                    
                    Spacer()
                    
                    // Problem counts
                    HStack(spacing: 8) {
                        if errorCount > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.red)
                                Text("\(errorCount)")
                                    .font(.system(size: 10))
                                    .foregroundColor(theme.comment)
                            }
                        }
                        if warningCount > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.orange)
                                Text("\(warningCount)")
                                    .font(.system(size: 10))
                                    .foregroundColor(theme.comment)
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(theme.tabBarBackground.opacity(0.5))
            
            // Problem list
            if isExpanded {
                ForEach(problems) { problem in
                    ProblemRowView(problem: problem)
                        .padding(.horizontal, 12)
                    
                    if problem.id != problems.last?.id {
                        Divider()
                            .padding(.leading, 40)
                    }
                }
            }
        }
    }
}

// MARK: - ProblemsView

struct ProblemsView: View {
    @State private var problems: [DiagnosticItem] = []
    @State private var selectedSeverities: Set<DiagnosticSeverity> = Set(DiagnosticSeverity.allCases)
    @StateObject private var themeManager = ThemeManager.shared
    
    private var theme: Theme { themeManager.currentTheme }
    
    // Group problems by file
    private var groupedProblems: [(file: String, problems: [DiagnosticItem])] {
        let filtered = filteredProblems
        let grouped = Dictionary(grouping: filtered, by: { $0.file })
        return grouped.map { (file: $0.key, problems: $0.value.sorted { $0.line < $1.line }) }
            .sorted { $0.file < $1.file }
    }
    
    private var filteredProblems: [DiagnosticItem] {
        problems.filter { selectedSeverities.contains($0.severity) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with counts and filters
            header
            
            Divider()

            if filteredProblems.isEmpty {
                noProblemsPlaceholder
                    .accessibilityLabel("No problems detected")
            } else {
                problemList
            }
        }
        .background(theme.editorBackground)
        .onReceive(NotificationCenter.default.publisher(for: .diagnosticsUpdated)) { notification in
            handleDiagnosticsUpdate(notification)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 0) {
            HStack {
                Text("PROBLEMS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.tabActiveForeground)
                
                if !problems.isEmpty {
                    let errors = problems.filter { $0.severity == .error }.count
                    let warnings = problems.filter { $0.severity == .warning }.count
                    let infos = problems.filter { $0.severity == .info }.count
                    
                    HStack(spacing: 8) {
                        if errors > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 10))
                                Text("\(errors)")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.comment)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(errors) error\(errors == 1 ? "" : "s")")
                        }
                        if warnings > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 10))
                                Text("\(warnings)")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.comment)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(warnings) warning\(warnings == 1 ? "" : "s")")
                        }
                        if infos > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 10))
                                Text("\(infos)")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.comment)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(infos) info\(infos == 1 ? "" : "s")")
                        }
                    }
                }
                
                Spacer()
                
                // Clear button
                Button(action: {
                    problems.removeAll()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(theme.comment)
                }
                .buttonStyle(.plain)
                .disabled(problems.isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Severity filters
            if !problems.isEmpty {
                Divider()
                
                HStack(spacing: 8) {
                    Text("Filter:")
                        .font(.system(size: 11))
                        .foregroundColor(theme.comment)
                    
                    ForEach(DiagnosticSeverity.allCases) { severity in
                        let count = problems.filter { $0.severity == severity }.count
                        let isSelected = selectedSeverities.contains(severity)
                        
                        Button(action: {
                            toggleSeverity(severity)
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: iconName(for: severity))
                                    .font(.system(size: 8))
                                Text(severity.rawValue.capitalized)
                                    .font(.system(size: 10))
                                Text("(\(count))")
                                    .font(.system(size: 10))
                                    .monospacedDigit()
                            }
                            .foregroundColor(isSelected ? color(for: severity) : theme.comment.opacity(0.5))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                isSelected ? color(for: severity).opacity(0.15) : Color.clear
                            )
                            .cornerRadius(4)
                        }
                        .disabled(count == 0)
                        .accessibilityLabel("\(severity.rawValue): \(count) items")
                        .accessibilityHint(isSelected ? "Double tap to hide" : "Double tap to show")
                    }
                    
                    if selectedSeverities.count != DiagnosticSeverity.allCases.count {
                        Button(action: {
                            selectedSeverities = Set(DiagnosticSeverity.allCases)
                        }) {
                            Text("Reset")
                                .font(.system(size: 10))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
        }
        .background(theme.tabBarBackground)
    }

    private var noProblemsPlaceholder: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 32))
                .foregroundColor(theme.comment.opacity(0.5))
            Text(selectedSeverities.count == DiagnosticSeverity.allCases.count ? "No problems detected" : "No problems match filter")
                .font(.system(size: 14))
                .foregroundColor(theme.comment)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var problemList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(groupedProblems, id: \.file) { group in
                    FileGroupView(file: group.file, problems: group.problems)
                    
                    if group.file != groupedProblems.last?.file {
                        Divider()
                            .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func handleDiagnosticsUpdate(_ notification: NotificationCenter.Publisher.Output) {
        // Expect an array of dictionaries under "diagnostics" key, or a single item
        if let items = notification.userInfo?["diagnostics"] as? [[String: Any]] {
            problems = items.compactMap { DiagnosticItem(userInfo: $0) }
        } else if let item = notification.userInfo as? [String: Any], item["message"] != nil {
            // Single diagnostic item passed directly
            if let diagnostic = DiagnosticItem(userInfo: item) {
                problems.append(diagnostic)
            }
        } else if let clear = notification.userInfo?["clear"] as? Bool, clear {
            problems.removeAll()
        }
    }
    
    private func toggleSeverity(_ severity: DiagnosticSeverity) {
        if selectedSeverities.contains(severity) {
            selectedSeverities.remove(severity)
        } else {
            selectedSeverities.insert(severity)
        }
    }

    private func iconName(for severity: DiagnosticSeverity) -> String {
        switch severity {
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    private func color(for severity: DiagnosticSeverity) -> Color {
        switch severity {
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

#Preview {
    ProblemsView()
}
