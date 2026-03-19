//
//  CloneRepositoryView.swift
//  VSCodeiPadOS
//
//  Clone Repository UI with URL input, destination picker, branch selector, and progress
//

import SwiftUI

// MARK: - Clone Repository View

struct CloneRepositoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var editorCore: EditorCore
    
    // Input state
    @State private var repositoryURL: String = ""
    @State private var authToken: String = ""
    @State private var selectedBranch: String = ""
    @State private var destinationURL: URL?
    @State private var customDestinationPath: String = ""
    
    // Branch discovery
    @State private var availableBranches: [String] = []
    @State private var isDiscoveringBranches = false
    @State private var discoveredDefaultBranch: String?
    
    // Clone state
    @State private var isCloning = false
    @State private var cloneProgress: String = ""
    @State private var cloneError: String?
    @State private var showCloneError = false
    @State private var cloneComplete = false
    @State private var clonedRepoURL: URL?
    
    // UI state
    @State private var showAuthField = false
    @State private var showBranchPicker = false
    @State private var showFolderPicker = false
    
    private var theme: Theme { themeManager.currentTheme }
    
    // Computed properties
    private var isValidURL: Bool {
        let trimmed = repositoryURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("https://") || trimmed.hasPrefix("http://") else { return false }
        guard let url = URL(string: trimmed) else { return false }
        return url.host != nil
    }
    
    private var suggestedFolderName: String {
        guard let url = URL(string: repositoryURL.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return "repository"
        }
        let path = url.path
        if path.hasSuffix(".git") {
            return String(path.dropLast(4).split(separator: "/").last ?? "repository")
        }
        return String(path.split(separator: "/").last ?? "repository")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Repository URL
                    urlSection
                    
                    // Authentication (optional)
                    authSection
                    
                    // Branch selection
                    branchSection
                    
                    // Destination
                    destinationSection
                    
                    // Progress
                    if isCloning || cloneComplete {
                        progressSection
                    }
                    
                    // Error
                    if let error = cloneError {
                        errorSection(error)
                    }
                }
                .padding(24)
            }
            .background(theme.editorBackground)
            .navigationTitle("Clone Repository")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isCloning)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(cloneComplete ? "Open Folder" : "Clone") {
                        if cloneComplete, let url = clonedRepoURL {
                            openClonedFolder(url)
                        } else {
                            startClone()
                        }
                    }
                    .disabled(!canStartClone || isCloning)
                    .bold(true)
                }
            }
            .sheet(isPresented: $showFolderPicker) {
                DocumentPicker(
                    mode: .folder,
                    onPick: { url in
                        destinationURL = url
                        showFolderPicker = false
                    }
                )
            }
            .alert("Clone Failed", isPresented: $showCloneError) {
                Button("OK", role: .cancel) {
                    cloneError = nil
                }
            } message: {
                Text(cloneError ?? "An unknown error occurred")
            }
        }
        .onAppear {
            // Set default destination
            if destinationURL == nil {
                destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            }
        }
        .onChange(of: repositoryURL) { _, _ in
            // Reset branch discovery when URL changes
            availableBranches = []
            discoveredDefaultBranch = nil
        }
    }
    
    // MARK: - UI Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 32))
                    .foregroundColor(theme.keyword)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clone a Git Repository")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme.editorForeground)
                    
                    Text("Enter a repository URL to clone it locally")
                        .font(.system(size: 13))
                        .foregroundColor(theme.lineNumber)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Clone a Git Repository. Enter a repository URL to clone it locally.")
    }
    
    private var urlSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repository URL")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(theme.sidebarForeground)
            
            TextField("https://github.com/user/repository.git", text: $repositoryURL)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14, design: .monospaced))
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .submitLabel(.done)
                .accessibilityLabel("Repository URL")
                .accessibilityHint("Enter the HTTPS URL of the Git repository to clone")
            
            HStack(spacing: 8) {
                Button(action: pasteFromClipboard) {
                    Label("Paste", systemImage: "doc.on.clipboard")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Paste from clipboard")
                
                if isValidURL && availableBranches.isEmpty && !isDiscoveringBranches {
                    Button(action: discoverBranches) {
                        Label("Fetch Branches", systemImage: "arrow.triangle.branch")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Fetch available branches from repository")
                }
                
                if isDiscoveringBranches {
                    ProgressView()
                        .scaleEffect(0.7)
                        .accessibilityLabel("Discovering branches")
                }
                
                Spacer()
            }
            
            // Quick links
            HStack(spacing: 4) {
                Text("Examples:")
                    .font(.system(size: 11))
                    .foregroundColor(theme.lineNumber)
                
                Button("GitHub") {
                    repositoryURL = "https://github.com/"
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .foregroundColor(theme.activityBarForeground)
                
                Text("•")
                    .font(.system(size: 11))
                    .foregroundColor(theme.lineNumber)
                
                Button("GitLab") {
                    repositoryURL = "https://gitlab.com/"
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .foregroundColor(theme.activityBarForeground)
                
                Text("•")
                    .font(.system(size: 11))
                    .foregroundColor(theme.lineNumber)
                
                Button("Bitbucket") {
                    repositoryURL = "https://bitbucket.org/"
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .foregroundColor(theme.activityBarForeground)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Quick links to GitHub, GitLab, and Bitbucket")
        }
    }
    
    private var authSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            DisclosureGroup(isExpanded: $showAuthField) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Authentication Token (Optional)")
                        .font(.system(size: 12))
                        .foregroundColor(theme.lineNumber)
                    
                    SecureField("Personal Access Token", text: $authToken)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14))
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .accessibilityLabel("Authentication token")
                        .accessibilityHint("Optional: Enter a personal access token for private repositories")
                    
                    Text("Required for private repositories. Uses Bearer authentication.")
                        .font(.system(size: 11))
                        .foregroundColor(theme.lineNumber)
                }
                .padding(.top, 8)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 12))
                        .foregroundColor(theme.lineNumber)
                    Text("Private Repository?")
                        .font(.system(size: 13))
                        .foregroundColor(theme.sidebarForeground)
                    Spacer()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Private repository authentication options")
                .accessibilityHint("Double tap to expand authentication settings")
            }
        }
    }
    
    private var branchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Branch")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(theme.sidebarForeground)
            
            if !availableBranches.isEmpty {
                // Show picker with discovered branches
                Picker("Branch", selection: $selectedBranch) {
                    Text("Default (\(discoveredDefaultBranch ?? "main"))").tag("")
                    ForEach(availableBranches, id: \.self) { branch in
                        Text(branch).tag(branch)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityLabel("Branch selection")
                .accessibilityHint("Select which branch to clone. Default uses the repository's default branch.")
            } else {
                // Manual entry
                HStack {
                    TextField("Leave empty for default branch", text: $selectedBranch)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14))
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .accessibilityLabel("Branch name")
                        .accessibilityHint("Enter a specific branch name, or leave empty to use the default branch")
                    
                    if let branch = discoveredDefaultBranch {
                        Text("(\(branch))")
                            .font(.system(size: 11))
                            .foregroundColor(theme.lineNumber)
                    }
                }
            }
            
            Text("The default branch will be used if not specified.")
                .font(.system(size: 11))
                .foregroundColor(theme.lineNumber)
        }
    }
    
    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Destination")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(theme.sidebarForeground)
            
            HStack(spacing: 12) {
                Image(systemName: "folder")
                    .font(.system(size: 16))
                    .foregroundColor(theme.activityBarForeground)
                    .frame(width: 24)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(destinationURL?.lastPathComponent ?? "Select Folder")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.editorForeground)
                    
                    Text(destinationURL?.path ?? "Tap to select a destination folder")
                        .font(.system(size: 11))
                        .foregroundColor(theme.lineNumber)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button("Browse…") {
                    showFolderPicker = true
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Browse for destination folder")
            }
            .padding(12)
            .background(theme.sidebarSelection.opacity(0.3))
            .cornerRadius(8)
            
            // Show where repo will be cloned
            if let dest = destinationURL {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 10))
                        .foregroundColor(theme.lineNumber)
                    Text("Repository will be cloned to:")
                        .font(.system(size: 11))
                        .foregroundColor(theme.lineNumber)
                }
                
                Text(dest.appendingPathComponent(suggestedFolderName).path)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(theme.lineNumber)
                    .lineLimit(2)
            }
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                if cloneComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                        .accessibilityHidden(true)
                } else {
                    ProgressView()
                        .scaleEffect(1.2)
                        .accessibilityLabel("Cloning repository")
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(cloneComplete ? "Clone Complete!" : "Cloning Repository…")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.editorForeground)
                    
                    Text(cloneProgress)
                        .font(.system(size: 12))
                        .foregroundColor(theme.lineNumber)
                        .lineLimit(3)
                }
                
                Spacer()
            }
            .padding(16)
            .background(cloneComplete ? Color.green.opacity(0.1) : theme.sidebarSelection.opacity(0.3))
            .cornerRadius(8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(cloneComplete ? "Clone complete. \(cloneProgress)" : "Cloning: \(cloneProgress)")
        }
    }
    
    private func errorSection(_ error: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundColor(theme.errorForeground)
                .accessibilityHidden(true)
            
            Text(error)
                .font(.system(size: 12))
                .foregroundColor(theme.errorForeground)
                .lineLimit(5)
        }
        .padding(12)
        .background(theme.errorBackground)
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(error)")
    }
    
    // MARK: - Actions
    
    private var canStartClone: Bool {
        isValidURL && destinationURL != nil && !isCloning && !cloneComplete
    }
    
    private func pasteFromClipboard() {
        if let clipboardString = UIPasteboard.general.string {
            repositoryURL = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private func discoverBranches() {
        guard isValidURL else { return }
        
        let url = repositoryURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let token = authToken.isEmpty ? nil : authToken
        
        isDiscoveringBranches = true
        availableBranches = []
        
        Task {
            do {
                let (branches, defaultBranch) = try await GitManager.shared.discoverRemoteBranches(
                    url: url,
                    authToken: token
                )
                
                await MainActor.run {
                    availableBranches = branches
                    discoveredDefaultBranch = defaultBranch
                    isDiscoveringBranches = false
                }
            } catch {
                await MainActor.run {
                    // Silently fail branch discovery - user can still clone
                    isDiscoveringBranches = false
                }
            }
        }
    }
    
    private func startClone() {
        guard isValidURL, let destination = destinationURL else { return }
        
        let url = repositoryURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let token = authToken.isEmpty ? nil : authToken
        let branch = selectedBranch.isEmpty ? nil : selectedBranch
        let cloneDest = destination.appendingPathComponent(suggestedFolderName)
        
        isCloning = true
        cloneError = nil
        cloneComplete = false
        cloneProgress = "Starting clone…"
        
        Task {
            do {
                try await GitManager.shared.cloneRepository(
                    url: url,
                    to: cloneDest,
                    branch: branch,
                    authToken: token
                ) { progress in
                    Task { @MainActor in
                        cloneProgress = progress
                    }
                }
                
                await MainActor.run {
                    cloneProgress = "Repository cloned successfully!"
                    cloneComplete = true
                    clonedRepoURL = cloneDest
                    isCloning = false
                    HapticManager.notification(.success)
                }
            } catch {
                await MainActor.run {
                    cloneError = error.localizedDescription
                    showCloneError = true
                    isCloning = false
                    HapticManager.notification(.error)
                }
            }
        }
    }
    
    private func openClonedFolder(_ url: URL) {
        // Post notification to open the cloned folder as workspace
        NotificationCenter.default.post(
            name: .sceneOpenWorkspace,
            object: nil,
            userInfo: ["workspaceURL": url]
        )
        dismiss()
    }
}

// MARK: - Document Picker

private struct DocumentPicker: UIViewControllerRepresentable {
    enum Mode {
        case folder
        case file
    }
    
    let mode: Mode
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker: UIDocumentPickerViewController
        
        if mode == .folder {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        } else {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: false)
        }
        
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        
        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                let didStartAccessing = url.startAccessingSecurityScopedResource()
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
                onPick(url)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CloneRepositoryView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(EditorCore())
}
