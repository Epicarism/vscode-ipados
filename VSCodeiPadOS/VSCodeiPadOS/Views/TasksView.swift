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
    @ObservedObject private var themeManager = ThemeManager.shared

    private var theme: Theme { themeManager.currentTheme }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(task.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.editorForeground)
                        .lineLimit(1)
                        .accessibilityLabel("Task: \(task.label)")

                    if let group = task.group {
                        Text(group.rawValue.uppercased())
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(theme.comment)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.tabBarBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .accessibilityLabel("Group: \(group.rawValue)")
                    }
                }

                Text(commandPreview)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(theme.comment)
                    .lineLimit(1)
                    .accessibilityLabel("Command: \(commandPreview)")
            }

            Spacer()

            Button {
                tasksManager.run(task)
            } label: {
                Image(systemName: isRunningThisTask ? "stop.circle" : "play.circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isRunningThisTask ? theme.keyword : theme.editorForeground)
            }
            .buttonStyle(.plain)
            .disabled(tasksManager.isRunning && !isRunningThisTask)
            .help("Run")
            .accessibilityLabel(isRunningThisTask ? "Stop task" : "Run task")
            .accessibilityHint(isRunningThisTask ? "Double tap to stop this task" : "Double tap to run this task")
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(theme.tabBarBackground.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Task: \(task.label). Command: \(commandPreview)")
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
