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
}

enum DiagnosticSeverity: String, CaseIterable {
    case error
    case warning
    case info
}

// MARK: - Notification Name

extension Notification.Name {
    static let diagnosticsUpdated = Notification.Name("diagnosticsUpdated")
}

// MARK: - ProblemsView

struct ProblemsView: View {
    @State private var problems: [DiagnosticItem] = []

    var body: some View {
        VStack(spacing: 0) {
            // Header with counts
            HStack {
                Text("PROBLEMS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                if !problems.isEmpty {
                    let errors = problems.filter { $0.severity == .error }.count
                    let warnings = problems.filter { $0.severity == .warning }.count
                    HStack(spacing: 8) {
                        if errors > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 10))
                                Text("\(errors)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(errors) error\(errors == 1 ? "" : "s")")
                        }
                        if warnings > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 10))
                                Text("\(warnings)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(warnings) warning\(warnings == 1 ? "" : "s")")
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))

            if problems.isEmpty {
                noProblemsPlaceholder
                    .accessibilityLabel("No problems detected")
            } else {
                problemList
            }
        }
        .background(Color(UIColor.systemBackground))
        .onReceive(NotificationCenter.default.publisher(for: .diagnosticsUpdated)) { notification in
            handleDiagnosticsUpdate(notification)
        }
    }

    // MARK: - Subviews

    private var noProblemsPlaceholder: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No problems detected")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var problemList: some View {
        List {
            ForEach(problems) { problem in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: iconName(for: problem.severity))
                        .foregroundColor(color(for: problem.severity))
                        .font(.caption)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(problem.message)
                            .font(.system(size: 13))
                            .foregroundColor(.primary)
                            .lineLimit(2)

                        HStack(spacing: 4) {
                            Text(problem.file)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text("[\(problem.line), \(problem.column)]")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 2)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(problem.severity.rawValue): \(problem.message), in \(problem.file) line \(problem.line)")
            }
        }
        .listStyle(.plain)
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
