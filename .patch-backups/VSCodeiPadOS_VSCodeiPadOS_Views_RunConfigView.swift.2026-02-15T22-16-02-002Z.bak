import SwiftUI

// MARK: - Models

/// Represents a run configuration preset
struct RunConfiguration: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var commandLineArgs: [String]
    var environmentVariables: [String: String]
    var workingDirectory: String
    var languageOptions: LanguageSpecificOptions
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         commandLineArgs: [String] = [],
         environmentVariables: [String: String] = [:],
         workingDirectory: String = "",
         languageOptions: LanguageSpecificOptions = LanguageSpecificOptions()) {
        self.id = id
        self.name = name
        self.commandLineArgs = commandLineArgs
        self.environmentVariables = environmentVariables
        self.workingDirectory = workingDirectory
        self.languageOptions = languageOptions
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// Language-specific run options
struct LanguageSpecificOptions: Codable, Equatable {
    var language: ProgrammingLanguage
    
    // Python options
    var pythonModuleMode: Bool
    var pythonUnbuffered: Bool
    var pythonOptimize: Bool
    
    // Node.js options
    var nodeInspect: Bool
    var nodeInspectBrk: Bool
    var nodeExperimentalModules: Bool
    var nodeNoWarnings: Bool
    
    // Other language options
    var goRaceDetector: Bool
    var rustRelease: Bool
    
    init(language: ProgrammingLanguage = .python,
         pythonModuleMode: Bool = false,
         pythonUnbuffered: Bool = false,
         pythonOptimize: Bool = false,
         nodeInspect: Bool = false,
         nodeInspectBrk: Bool = false,
         nodeExperimentalModules: Bool = false,
         nodeNoWarnings: Bool = false,
         goRaceDetector: Bool = false,
         rustRelease: Bool = false) {
        self.language = language
        self.pythonModuleMode = pythonModuleMode
        self.pythonUnbuffered = pythonUnbuffered
        self.pythonOptimize = pythonOptimize
        self.nodeInspect = nodeInspect
        self.nodeInspectBrk = nodeInspectBrk
        self.nodeExperimentalModules = nodeExperimentalModules
        self.nodeNoWarnings = nodeNoWarnings
        self.goRaceDetector = goRaceDetector
        self.rustRelease = rustRelease
    }
}

enum ProgrammingLanguage: String, Codable, CaseIterable, Identifiable {
    case python = "Python"
    case node = "Node.js"
    case go = "Go"
    case rust = "Rust"
    case ruby = "Ruby"
    case php = "PHP"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .python: return "🐍"
        case .node: return "🟢"
        case .go: return "🔵"
        case .rust: return "🦀"
        case .ruby: return "💎"
        case .php: return "🐘"
        case .other: return "📄"
        }
    }
}

// MARK: - View Model

@MainActor
class RunConfigViewModel: ObservableObject {
    @Published var currentConfig: RunConfiguration
    @Published var savedPresets: [RunConfiguration] = []
    @Published var newArgText: String = ""
    @Published var newEnvKey: String = ""
    @Published var newEnvValue: String = ""
    @Published var presetNameText: String = ""
    @Published var showSaveAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isExecuting: Bool = false
    @Published var executionOutput: String = ""
    
    private let presetsKey = "runConfigurationPresets"
    private var remoteRunner: RemoteRunner?
    
    init(remoteRunner: RemoteRunner? = nil) {
        self.remoteRunner = remoteRunner
        self.currentConfig = RunConfiguration(name: "New Configuration")
        loadPresets()
    }
    
    // MARK: - Command Line Arguments
    
    func addArgument() {
        let trimmed = newArgText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        currentConfig.commandLineArgs.append(trimmed)
        newArgText = ""
        updateTimestamp()
    }
    
    func removeArgument(at index: Int) {
        guard index >= 0 && index < currentConfig.commandLineArgs.count else { return }
        currentConfig.commandLineArgs.remove(at: index)
        updateTimestamp()
    }
    
    func moveArgument(from source: IndexSet, to destination: Int) {
        currentConfig.commandLineArgs.move(fromOffsets: source, toOffset: destination)
        updateTimestamp()
    }
    
    // MARK: - Environment Variables
    
    func addEnvironmentVariable() {
        let trimmedKey = newEnvKey.trimmingCharacters(in: .whitespaces)
        let trimmedValue = newEnvValue.trimmingCharacters(in: .whitespaces)
        guard !trimmedKey.isEmpty else { return }
        
        currentConfig.environmentVariables[trimmedKey] = trimmedValue
        newEnvKey = ""
        newEnvValue = ""
        updateTimestamp()
    }
    
    func removeEnvironmentVariable(key: String) {
        currentConfig.environmentVariables.removeValue(forKey: key)
        updateTimestamp()
    }
    
    func updateEnvironmentVariable(key: String, newValue: String) {
        currentConfig.environmentVariables[key] = newValue
        updateTimestamp()
    }
    
    // MARK: - Presets
    
    func savePreset() {
        let trimmedName = presetNameText.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            alertMessage = "Please enter a preset name"
            showSaveAlert = true
            return
        }
        
        var preset = currentConfig
        preset.name = trimmedName
        preset.id = UUID()
        
        // Remove existing preset with same name
        savedPresets.removeAll { $0.name == trimmedName }
        savedPresets.append(preset)
        
        savePresetsToStorage()
        presetNameText = ""
        alertMessage = "Preset '\(trimmedName)' saved successfully"
        showSaveAlert = true
    }
    
    func loadPreset(_ preset: RunConfiguration) {
        currentConfig = preset
        alertMessage = "Loaded preset '\(preset.name)'"
        showSaveAlert = true
    }
    
    func deletePreset(at indexSet: IndexSet) {
        savedPresets.remove(atOffsets: indexSet)
        savePresetsToStorage()
    }
    
    func renamePreset(_ preset: RunConfiguration, newName: String) {
        guard let index = savedPresets.firstIndex(where: { $0.id == preset.id }) else { return }
        savedPresets[index].name = newName
        savedPresets[index].updatedAt = Date()
        savePresetsToStorage()
    }
    
    private func savePresetsToStorage() {
        if let encoded = try? JSONEncoder().encode(savedPresets) {
            UserDefaults.standard.set(encoded, forKey: presetsKey)
        }
    }
    
    private func loadPresets() {
        guard let data = UserDefaults.standard.data(forKey: presetsKey),
              let decoded = try? JSONDecoder().decode([RunConfiguration].self, from: data) else {
            return
        }
        savedPresets = decoded
    }
    
    // MARK: - Execution
    
    func execute(withFile filePath: String?) async {
        guard let remoteRunner = remoteRunner else {
            alertMessage = "RemoteRunner not configured"
            showSaveAlert = true
            return
        }
        
        isExecuting = true
        executionOutput = ""
        
        do {
            let result = try await remoteRunner.execute(
                filePath: filePath,
                configuration: currentConfig
            )
            executionOutput = result.output
            if !result.success {
                alertMessage = "Execution failed with exit code \(result.exitCode)"
                showSaveAlert = true
            }
        } catch {
            alertMessage = "Execution error: \(error.localizedDescription)"
            showSaveAlert = true
        }
        
        isExecuting = false
    }
    
    // MARK: - Helpers
    
    private func updateTimestamp() {
        currentConfig.updatedAt = Date()
    }
    
    func buildCommandString(filePath: String?) -> String {
        var parts: [String] = []
        
        // Language-specific prefix
        switch currentConfig.languageOptions.language {
        case .python:
            var pythonArgs: [String] = []
            if currentConfig.languageOptions.pythonUnbuffered {
                pythonArgs.append("-u")
            }
            if currentConfig.languageOptions.pythonOptimize {
                pythonArgs.append("-O")
            }
            if currentConfig.languageOptions.pythonModuleMode {
                pythonArgs.append("-m")
            }
            parts.append("python \(pythonArgs.joined(separator: " "))".trimmingCharacters(in: .whitespaces))
            
        case .node:
            var nodeArgs: [String] = []
            if currentConfig.languageOptions.nodeInspect {
                nodeArgs.append("--inspect")
            }
            if currentConfig.languageOptions.nodeInspectBrk {
                nodeArgs.append("--inspect-brk")
            }
            if currentConfig.languageOptions.nodeExperimentalModules {
                nodeArgs.append("--experimental-modules")
            }
            if currentConfig.languageOptions.nodeNoWarnings {
                nodeArgs.append("--no-warnings")
            }
            parts.append("node \(nodeArgs.joined(separator: " "))".trimmingCharacters(in: .whitespaces))
            
        case .go:
            var goArgs: [String] = ["run"]
            if currentConfig.languageOptions.goRaceDetector {
                goArgs.append("-race")
            }
            parts.append("go \(goArgs.joined(separator: " "))")
            
        case .rust:
            var cargoArgs: [String] = ["run"]
            if currentConfig.languageOptions.rustRelease {
                cargoArgs.append("--release")
            }
            parts.append("cargo \(cargoArgs.joined(separator: " "))")
            
        default:
            parts.append(currentConfig.languageOptions.language.rawValue.lowercased())
        }
        
        // File path
        if let filePath = filePath {
            parts.append(filePath)
        }
        
        // Command line arguments
        if !currentConfig.commandLineArgs.isEmpty {
            parts.append(currentConfig.commandLineArgs.joined(separator: " "))
        }
        
        return parts.joined(separator: " ")
    }
}

// MARK: - RemoteRunner Protocol

protocol RemoteRunner {
    func execute(filePath: String?, configuration: RunConfiguration) async throws -> ExecutionResult
}

struct ExecutionResult {
    let success: Bool
    let exitCode: Int
    let output: String
    let errorOutput: String?
    let duration: TimeInterval
}

// MARK: - RunConfigView

struct RunConfigView: View {
    @StateObject private var viewModel = RunConfigViewModel()
    @State private var selectedFilePath: String?
    @State private var showWorkingDirPicker: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var presetToDelete: RunConfiguration?
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Presets Section
                Section(header: Text("Presets").font(.headline)) {
                    presetManagementView
                }
                
                // MARK: - Language Section
                Section(header: Text("Language").font(.headline)) {
                    languagePickerView
                }
                
                // MARK: - Command Line Arguments Section
                Section(header: Text("Command Line Arguments").font(.headline)) {
                    argumentsView
                }
                
                // MARK: - Environment Variables Section
                Section(header: Text("Environment Variables").font(.headline)) {
                    environmentVariablesView
                }
                
                // MARK: - Working Directory Section
                Section(header: Text("Working Directory").font(.headline)) {
                    workingDirectoryView
                }
                
                // MARK: - Language-Specific Options Section
                Section(header: Text("\(viewModel.currentConfig.languageOptions.language.rawValue) Options").font(.headline)) {
                    languageSpecificOptionsView
                }
                
                // MARK: - Command Preview Section
                Section(header: Text("Command Preview").font(.headline)) {
                    commandPreviewView
                }
                
                // MARK: - Execution Section
                Section {
                    executionButtonView
                }
            }
            .navigationTitle("Run Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $viewModel.showSaveAlert) {
                Alert(
                    title: Text("Run Configuration"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showWorkingDirPicker) {
                RemotePathPickerView(selectedPath: $viewModel.currentConfig.workingDirectory)
            }
            .confirmationDialog(
                "Delete Preset?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let preset = presetToDelete,
                       let index = viewModel.savedPresets.firstIndex(where: { $0.id == preset.id }) {
                        viewModel.savedPresets.remove(at: index)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete '\(presetToDelete?.name ?? "")'?")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var presetManagementView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Load existing presets
            if !viewModel.savedPresets.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.savedPresets) { preset in
                            PresetChip(preset: preset) {
                                viewModel.loadPreset(preset)
                            } onDelete: {
                                presetToDelete = preset
                                showDeleteConfirmation = true
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Save new preset
            HStack {
                TextField("Preset name", text: $viewModel.presetNameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: viewModel.savePreset) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .disabled(viewModel.presetNameText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
    
    private var languagePickerView: some View {
        Picker("Language", selection: $viewModel.currentConfig.languageOptions.language) {
            ForEach(ProgrammingLanguage.allCases) { language in
                HStack {
                    Text(language.icon)
                    Text(language.rawValue)
                }
                .tag(language)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    
    private var argumentsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Add new argument
            HStack {
                TextField("Add argument...", text: $viewModel.newArgText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: viewModel.addArgument) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.newArgText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            // List of arguments
            if !viewModel.currentConfig.commandLineArgs.isEmpty {
                List {
                    ForEach(viewModel.currentConfig.commandLineArgs.indices, id: \.self) { index in
                        HStack {
                            Text(viewModel.currentConfig.commandLineArgs[index])
                                .font(.system(.body, design: .monospaced))
                            Spacer()
                            Button(action: { viewModel.removeArgument(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onMove(perform: viewModel.moveArgument)
                }
                .listStyle(PlainListStyle())
                .frame(minHeight: 100, maxHeight: 200)
            } else {
                Text("No arguments added")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 8)
            }
        }
    }
    
    private var environmentVariablesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Add new env var
            HStack {
                TextField("KEY", text: $viewModel.newEnvKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 120)
                
                Text("=")
                    .foregroundColor(.secondary)
                
                TextField("value", text: $viewModel.newEnvValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: viewModel.addEnvironmentVariable) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.newEnvKey.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            // List of env vars
            if !viewModel.currentConfig.environmentVariables.isEmpty {
                List {
                    ForEach(viewModel.currentConfig.environmentVariables.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.blue)
                            Text("=")
                                .foregroundColor(.secondary)
                            Text(value)
                                .font(.system(.body, design: .monospaced))
                            Spacer()
                            Button(action: { viewModel.removeEnvironmentVariable(key: key) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(minHeight: 100, maxHeight: 200)
            } else {
                Text("No environment variables set")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 8)
            }
        }
    }
    
    private var workingDirectoryView: some View {
        HStack {
            Text(viewModel.currentConfig.workingDirectory.isEmpty ? "Default (file directory)" : viewModel.currentConfig.workingDirectory)
                .font(.system(.body, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
            
            Button(action: { showWorkingDirPicker = true }) {
                Image(systemName: "folder.badge.plus")
            }
            
            if !viewModel.currentConfig.workingDirectory.isEmpty {
                Button(action: { viewModel.currentConfig.workingDirectory = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    @ViewBuilder
    private var languageSpecificOptionsView: some View {
        switch viewModel.currentConfig.languageOptions.language {
        case .python:
            pythonOptionsView
        case .node:
            nodeOptionsView
        case .go:
            goOptionsView
        case .rust:
            rustOptionsView
        default:
            Text("No specific options available for \(viewModel.currentConfig.languageOptions.language.rawValue)")
                .foregroundColor(.secondary)
                .italic()
        }
    }
    
    private var pythonOptionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Module mode (-m)", isOn: $viewModel.currentConfig.languageOptions.pythonModuleMode)
            Toggle("Unbuffered output (-u)", isOn: $viewModel.currentConfig.languageOptions.pythonUnbuffered)
            Toggle("Optimize (-O)", isOn: $viewModel.currentConfig.languageOptions.pythonOptimize)
        }
    }
    
    private var nodeOptionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Inspect (--inspect)", isOn: $viewModel.currentConfig.languageOptions.nodeInspect)
            Toggle("Inspect with breakpoint (--inspect-brk)", isOn: $viewModel.currentConfig.languageOptions.nodeInspectBrk)
            Toggle("Experimental modules", isOn: $viewModel.currentConfig.languageOptions.nodeExperimentalModules)
            Toggle("No warnings", isOn: $viewModel.currentConfig.languageOptions.nodeNoWarnings)
        }
    }
    
    private var goOptionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Race detector (-race)", isOn: $viewModel.currentConfig.languageOptions.goRaceDetector)
        }
    }
    
    private var rustOptionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Release mode (--release)", isOn: $viewModel.currentConfig.languageOptions.rustRelease)
        }
    }
    
    private var commandPreviewView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.buildCommandString(filePath: selectedFilePath ?? "main.py"))
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .textSelection(.enabled)
            
            if !viewModel.currentConfig.environmentVariables.isEmpty {
                Text("Environment:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(viewModel.currentConfig.environmentVariables.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    Text("\(key)=\(value)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var executionButtonView: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await viewModel.execute(withFile: selectedFilePath)
                }
            }) {
                HStack {
                    if viewModel.isExecuting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "play.fill")
                    }
                    Text(viewModel.isExecuting ? "Running..." : "Run")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isExecuting ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.isExecuting)
            
            if !viewModel.executionOutput.isEmpty {
                ScrollView {
                    Text(viewModel.executionOutput)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
                .background(Color(.systemGray6))
                .cornerRadius(6)
            }
        }
    }
}

// MARK: - Supporting Views

struct PresetChip: View {
    let preset: RunConfiguration
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(preset.languageOptions.language.icon)
                Text(preset.name)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RemotePathPickerView: View {
    @Binding var selectedPath: String
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPath: String = "/"
    @State private var pathHistory: [String] = ["/"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Path")) {
                    HStack {
                        TextField("Path", text: $currentPath)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(.body, design: .monospaced))
                        
                        Button(action: { goBack() }) {
                            Image(systemName: "arrow.backward")
                        }
                        .disabled(pathHistory.count <= 1)
                    }
                }
                
                Section(header: Text("Quick Locations")) {
                    Button(action: { navigateTo("/") }) {
                        Label("Root", systemImage: "forward.fill")
                    }
                    Button(action: { navigateTo("~") }) {
                        Label("Home", systemImage: "house.fill")
                    }
                    Button(action: { navigateTo("/tmp") }) {
                        Label("Temporary", systemImage: "clock.fill")
                    }
                    Button(action: { navigateTo("/var/log") }) {
                        Label("Logs", systemImage: "doc.text.fill")
                    }
                }
                
                Section {
                    Button(action: {
                        selectedPath = currentPath
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Label("Select This Directory", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Choose Working Directory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func navigateTo(_ path: String) {
        currentPath = path
        pathHistory.append(path)
    }
    
    private func goBack() {
        guard pathHistory.count > 1 else { return }
        pathHistory.removeLast()
        currentPath = pathHistory.last ?? "/"
    }
}

// MARK: - Preview

struct RunConfigView_Previews: PreviewProvider {
    static var previews: some View {
        RunConfigView()
    }
}
