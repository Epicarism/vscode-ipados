import SwiftUI

/// UI for selecting and editing debug launch configurations.
struct LaunchConfigView: View {
    @ObservedObject private var launchManager = LaunchManager.shared

    /// When `true`, only shows the dropdown + play button (for toolbar usage).
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 0 : 10) {
            header

            if !compact {
                if let error = launchManager.lastErrorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                editor
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Menu {
                // Config list
                ForEach(launchManager.configs) { cfg in
                    Button {
                        launchManager.setActiveConfig(cfg)
                    } label: {
                        HStack {
                            Text(cfg.name)
                            if launchManager.activeConfigId == cfg.id {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }

                Divider()

                Menu("Add Template") {
                    ForEach(LaunchConfig.builtInTemplates) { template in
                        Button(template.name) {
                            launchManager.addTemplate(template)
                        }
                    }
                }

                Button("Reload from .vscode/launch.json") {
                    launchManager.reload()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape")
                    Text(launchManager.activeConfig?.name ?? "Select Launch Config")
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(UIColor.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            Button(action: { launchManager.startActiveDebugSession() }) {
                Image(systemName: "play.fill")
            }
            .buttonStyle(.plain)
            .help("Start Debug")

            if !compact {
                Spacer()
            }
        }
    }

    private var editor: some View {
        Group {
            if let idx = activeIndex {
                VStack(alignment: .leading, spacing: 10) {
                    Text("LAUNCH CONFIGURATION")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)

                    TextField("Name", text: binding(for: idx, keyPath: \.name))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 13))

                    HStack(spacing: 10) {
                        TextField("Type (swift/node/python)", text: binding(for: idx, keyPath: \.type))
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 13))

                        Picker("Request", selection: bindingRequest(for: idx)) {
                            ForEach(LaunchRequest.allCases, id: \.self) { req in
                                Text(req.rawValue).tag(req)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    TextField("Program", text: bindingOptionalString(for: idx, keyPath: \.program))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 13))

                    TextField("CWD", text: bindingOptionalString(for: idx, keyPath: \.cwd))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 13))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Args (space-separated)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("--flag value", text: bindingArgsString(for: idx))
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 13, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Env (KEY=VALUE per line)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextEditor(text: bindingEnvString(for: idx))
                            .font(.system(size: 12, design: .monospaced))
                            .frame(minHeight: 90)
                            .padding(8)
                            .background(Color(UIColor.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            } else {
                Text("No launch configurations")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var activeIndex: Int? {
        guard let id = launchManager.activeConfigId else { return nil }
        return launchManager.configs.firstIndex(where: { $0.id == id })
    }

    // MARK: - Bindings

    private func binding(for idx: Int, keyPath: WritableKeyPath<LaunchConfig, String>) -> Binding<String> {
        Binding(
            get: { launchManager.configs[idx][keyPath: keyPath] },
            set: { newValue in
                var updated = launchManager.configs[idx]
                updated[keyPath: keyPath] = newValue
                launchManager.updateConfig(updated)
            }
        )
    }

    private func bindingOptionalString(for idx: Int, keyPath: WritableKeyPath<LaunchConfig, String?>) -> Binding<String> {
        Binding(
            get: { launchManager.configs[idx][keyPath: keyPath] ?? "" },
            set: { newValue in
                var updated = launchManager.configs[idx]
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                updated[keyPath: keyPath] = trimmed.isEmpty ? nil : trimmed
                launchManager.updateConfig(updated)
            }
        )
    }

    private func bindingRequest(for idx: Int) -> Binding<LaunchRequest> {
        Binding(
            get: { launchManager.configs[idx].request },
            set: { newValue in
                var updated = launchManager.configs[idx]
                updated.request = newValue
                launchManager.updateConfig(updated)
            }
        )
    }

    private func bindingArgsString(for idx: Int) -> Binding<String> {
        Binding(
            get: {
                (launchManager.configs[idx].args ?? []).joined(separator: " ")
            },
            set: { newValue in
                var updated = launchManager.configs[idx]
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    updated.args = nil
                } else {
                    // Simple split: space-delimited.
                    updated.args = trimmed.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).map(String.init)
                }
                launchManager.updateConfig(updated)
            }
        )
    }

    private func bindingEnvString(for idx: Int) -> Binding<String> {
        Binding(
            get: {
                let env = launchManager.configs[idx].env ?? [:]
                return env
                    .sorted(by: { $0.key < $1.key })
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: "\n")
            },
            set: { newValue in
                var updated = launchManager.configs[idx]
                let lines = newValue
                    .split(whereSeparator: { $0 == "\n" || $0 == "\r" })
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                var env: [String: String] = [:]
                for line in lines {
                    let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
                    guard parts.count == 2 else { continue }
                    env[parts[0]] = parts[1]
                }

                updated.env = env.isEmpty ? nil : env
                launchManager.updateConfig(updated)
            }
        )
    }
}

#Preview {
    LaunchConfigView()
        .padding()
}
