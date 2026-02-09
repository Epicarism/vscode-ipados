import SwiftUI

/// UI for editing per-project `.vscode/settings.json`.
///
/// Note: This view edits *workspace overrides*. Global settings remain in the main Settings panels.
struct WorkspaceSettingsView: View {
    @ObservedObject private var workspaceManager = WorkspaceManager.shared

    @State private var draft: WorkspaceSettings = .empty

    var body: some View {
        Group {
            Section(header: Text("Workspace")) {
                HStack {
                    Text("Folder")
                    Spacer()
                    Text(workspaceManager.workspaceRootURL?.lastPathComponent ?? "None")
                        .foregroundColor(.secondary)
                }

                if let err = workspaceManager.lastErrorMessage, !err.isEmpty {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    Button("Reload") {
                        workspaceManager.reload()
                        draft = workspaceManager.workspaceSettings
                    }
                    .disabled(workspaceManager.workspaceRootURL == nil)

                    Button("Save") {
                        workspaceManager.saveWorkspaceSettings(draft)
                    }
                    .disabled(workspaceManager.workspaceRootURL == nil)

                    Spacer()

                    Button("Reset Overrides") {
                        draft = .empty
                        workspaceManager.saveWorkspaceSettings(.empty)
                    }
                    .disabled(workspaceManager.workspaceRootURL == nil)
                    .foregroundColor(.red)
                }
            }

            Section(header: Text("Editor")) {
                overrideStepper(
                    title: "Tab Size",
                    isOverriding: Binding(
                        get: { draft.tabSize != nil },
                        set: { enabled in
                            if enabled {
                                draft.tabSize = workspaceManager.globalSettings().tabSize
                            } else {
                                draft.tabSize = nil
                            }
                        }
                    ),
                    value: Binding(
                        get: { draft.tabSize ?? workspaceManager.globalSettings().tabSize },
                        set: { draft.tabSize = $0 }
                    ),
                    range: 1...8
                )

                overrideToggle(
                    title: "Insert Spaces",
                    isOverriding: Binding(
                        get: { draft.insertSpaces != nil },
                        set: { enabled in
                            if enabled {
                                draft.insertSpaces = workspaceManager.globalSettings().insertSpaces
                            } else {
                                draft.insertSpaces = nil
                            }
                        }
                    ),
                    value: Binding(
                        get: { draft.insertSpaces ?? workspaceManager.globalSettings().insertSpaces },
                        set: { draft.insertSpaces = $0 }
                    )
                )

                overrideToggle(
                    title: "Format On Save",
                    isOverriding: Binding(
                        get: { draft.formatOnSave != nil },
                        set: { enabled in
                            if enabled {
                                draft.formatOnSave = workspaceManager.globalSettings().formatOnSave
                            } else {
                                draft.formatOnSave = nil
                            }
                        }
                    ),
                    value: Binding(
                        get: { draft.formatOnSave ?? workspaceManager.globalSettings().formatOnSave },
                        set: { draft.formatOnSave = $0 }
                    )
                )

                overrideTextField(
                    title: "Font Family",
                    placeholder: workspaceManager.globalSettings().fontFamily,
                    isOverriding: Binding(
                        get: { draft.fontFamily != nil },
                        set: { enabled in
                            if enabled {
                                draft.fontFamily = workspaceManager.globalSettings().fontFamily
                            } else {
                                draft.fontFamily = nil
                            }
                        }
                    ),
                    text: Binding(
                        get: { draft.fontFamily ?? workspaceManager.globalSettings().fontFamily },
                        set: { draft.fontFamily = $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    )
                )

                overrideFontSizeSlider(
                    isOverriding: Binding(
                        get: { draft.fontSize != nil },
                        set: { enabled in
                            if enabled {
                                draft.fontSize = workspaceManager.globalSettings().fontSize
                            } else {
                                draft.fontSize = nil
                            }
                        }
                    ),
                    value: Binding(
                        get: { draft.fontSize ?? workspaceManager.globalSettings().fontSize },
                        set: { draft.fontSize = $0 }
                    )
                )
            }

            Section(header: Text("Workbench")) {
                overrideThemePicker(
                    isOverriding: Binding(
                        get: { draft.theme != nil },
                        set: { enabled in
                            if enabled {
                                draft.theme = workspaceManager.globalSettings().theme
                            } else {
                                draft.theme = nil
                            }
                        }
                    ),
                    selection: Binding(
                        get: { draft.theme ?? workspaceManager.globalSettings().theme },
                        set: { draft.theme = $0 }
                    )
                )
            }

            Section(header: Text("Effective (Global + Workspace)")) {
                let effective = workspaceManager.effectiveSettings()
                keyValueRow("Tab Size", "\(effective.tabSize)")
                keyValueRow("Insert Spaces", effective.insertSpaces ? "On" : "Off")
                keyValueRow("Format On Save", effective.formatOnSave ? "On" : "Off")
                keyValueRow("Theme", Theme.allThemes.first(where: { $0.id == effective.theme })?.name ?? effective.theme)
                keyValueRow("Font Family", effective.fontFamily)
                keyValueRow("Font Size", "\(Int(effective.fontSize))")
            }
        }
        .onAppear {
            // Ensure we reflect whatever is currently loaded.
            draft = workspaceManager.workspaceSettings
        }
        .onChange(of: workspaceManager.workspaceSettings) { newValue in
            // Keep the editor in sync with reloads / workspace changes.
            draft = newValue
        }
    }

    // MARK: - Subviews

    private func keyValueRow(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }

    private func overrideToggle(
        title: String,
        isOverriding: Binding<Bool>,
        value: Binding<Bool>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Override \(title)", isOn: isOverriding)
                .font(.subheadline)

            Toggle(title, isOn: value)
                .disabled(!isOverriding.wrappedValue)
                .opacity(isOverriding.wrappedValue ? 1 : 0.5)
        }
        .padding(.vertical, 2)
    }

    private func overrideStepper(
        title: String,
        isOverriding: Binding<Bool>,
        value: Binding<Int>,
        range: ClosedRange<Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Override \(title)", isOn: isOverriding)
                .font(.subheadline)

            Stepper("\(title): \(value.wrappedValue)", value: value, in: range)
                .disabled(!isOverriding.wrappedValue)
                .opacity(isOverriding.wrappedValue ? 1 : 0.5)
        }
        .padding(.vertical, 2)
    }

    private func overrideTextField(
        title: String,
        placeholder: String,
        isOverriding: Binding<Bool>,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Override \(title)", isOn: isOverriding)
                .font(.subheadline)

            TextField(placeholder, text: text)
                .disabled(!isOverriding.wrappedValue)
                .opacity(isOverriding.wrappedValue ? 1 : 0.5)
        }
        .padding(.vertical, 2)
    }

    private func overrideFontSizeSlider(
        isOverriding: Binding<Bool>,
        value: Binding<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Override Font Size", isOn: isOverriding)
                .font(.subheadline)

            VStack(alignment: .leading) {
                Text("Font Size: \(Int(value.wrappedValue))")
                Slider(value: value, in: 8...32, step: 1)
                    .disabled(!isOverriding.wrappedValue)
                    .opacity(isOverriding.wrappedValue ? 1 : 0.5)
            }
        }
        .padding(.vertical, 2)
    }

    private func overrideThemePicker(
        isOverriding: Binding<Bool>,
        selection: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Override Theme", isOn: isOverriding)
                .font(.subheadline)

            Picker("Color Theme", selection: selection) {
                ForEach(Theme.allThemes) { theme in
                    Text(theme.name).tag(theme.id)
                }
            }
            .disabled(!isOverriding.wrappedValue)
            .opacity(isOverriding.wrappedValue ? 1 : 0.5)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationView {
        Form {
            WorkspaceSettingsView()
        }
        .navigationTitle("Workspace Settings")
    }
}