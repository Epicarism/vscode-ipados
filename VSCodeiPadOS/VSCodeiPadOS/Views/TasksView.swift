import SwiftUI
import SwiftUI

struct TasksView: View {
    @ObservedObject private var tasksManager = TasksManager.shared

    /// When `true`, renders a simpler header suitable for embedding.
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 8 : 10) {
            header

            if let error = tasksManager.lastErrorMessage, !compact {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if tasksManager.tasks.isEmpty {
                Text("No tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(tasksManager.tasks) { task in
                        TaskRow(task: task)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("TASKS")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()

            Menu {
                Menu("Add Template") {
                    ForEach(VSCodeTask.builtInTemplates) { template in
                        Button(template.label) {
                            tasksManager.addTemplate(template)
                        }
                    }
                }

                Button("Reload from .vscode/tasks.json") {
                    tasksManager.reload()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .buttonStyle(.plain)
        }
    }
}

private struct TaskRow: View {
    let task: VSCodeTask

    @ObservedObject private var tasksManager = TasksManager.shared

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(task.label)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)

                    if let group = task.group {
                        Text(group.rawValue.uppercased())
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(UIColor.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }

                Text(commandPreview)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                tasksManager.run(task)
            } label: {
                Image(systemName: isRunningThisTask ? "stop.circle" : "play.circle")
                    .font(.system(size: 16, weight: .semibold))
            }
            .buttonStyle(.plain)
            .disabled(tasksManager.isRunning && !isRunningThisTask)
            .help("Run")
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color(UIColor.tertiarySystemFill).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var commandPreview: String {
        let args = (task.args ?? []).joined(separator: " ")
        return args.isEmpty ? task.command : "\(task.command) \(args)"
    }

    private var isRunningThisTask: Bool {
        tasksManager.runningTaskLabel == task.label
    }
}

#Preview {
    TasksView()
        .padding()
}
