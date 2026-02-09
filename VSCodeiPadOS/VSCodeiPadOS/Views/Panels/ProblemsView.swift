import SwiftUI

struct Problem: Identifiable {
    let id = UUID()
    let message: String
    let file: String
    let line: Int
    let column: Int
    let severity: ProblemSeverity
}

enum ProblemSeverity {
    case error, warning, info
}

struct ProblemsView: View {
    @State private var problems: [Problem] = [
        Problem(message: "Use of unresolved identifier 'contentView'", file: "ContentView.swift", line: 42, column: 10, severity: .error),
        Problem(message: "Variable 'isValid' was never mutated; consider changing to 'let' constant", file: "EditorCore.swift", line: 128, column: 5, severity: .warning),
        Problem(message: "Expression implicitly coerced from 'String?' to 'Any'", file: "TerminalView.swift", line: 85, column: 22, severity: .warning)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
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
                                .lineLimit(1)
                            
                            HStack(spacing: 4) {
                                Text(problem.file)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text("[")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text("\(problem.line), \(problem.column)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text("]")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                }
            }
            .listStyle(.plain)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private func iconName(for severity: ProblemSeverity) -> String {
        switch severity {
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    private func color(for severity: ProblemSeverity) -> Color {
        switch severity {
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}
