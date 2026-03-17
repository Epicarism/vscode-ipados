import SwiftUI

// MARK: - Git View (Source Control Panel)

struct GitView: View {
    @ObservedObject private var gitManager = GitManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var editorCore: EditorCore
    @State private var commitMessage = ""
    @State private var selectedEntry: GitStatusEntry?
    @State private var showingDiffEntry: GitStatusEntry?
    @State private var showBranchPicker = false
    @State private var showGitConfig = false
    @State private var gitConfigName = ""
    @State private var gitConfigEmail = ""
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isOperationInProgress = false
    @State private var showDiscardConfirmation = false
    @State private var pendingDiscardPath: String?
    @State private var showDiscardAllAlert = false
    @State private var showCommitPushConfirmation = false
    @State private var gitConfigError: String?

    private var theme: Theme { themeManager.currentTheme }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("SOURCE CONTROL")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                
                if gitManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                        .accessibilityLabel("Loading git status")
                }
                
                Button(action: refreshGit) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .disabled(gitManager.isLoading)
                .accessibilityLabel("Refresh")
                .accessibilityHint("Double tap to refresh git status")
                
                Button(action: { loadGitConfig(); showGitConfig = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Git settings")
                .accessibilityHint("Double tap to configure git settings")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
            
            // Branch selector
            HStack {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Button(action: { showBranchPicker = true }) {
                    HStack(spacing: 4) {
                        Text(gitManager.currentBranch)
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9))
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Branch: \(gitManager.currentBranch)")
                .accessibilityHint("Double tap to switch branch")
                
                Spacer()
                
                // Sync status
                if gitManager.aheadCount > 0 || gitManager.behindCount > 0 {
                    HStack(spacing: 4) {
                        if gitManager.aheadCount > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.up")
                                Text("\(gitManager.aheadCount)")
                            }
                            .font(.system(size: 10))
                            .foregroundColor(Color(UIColor.systemOrange))
                            .accessibilityLabel("\(gitManager.aheadCount) commit\(gitManager.aheadCount == 1 ? "" : "s") ahead of remote")
                        }
                        if gitManager.behindCount > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.down")
                                Text("\(gitManager.behindCount)")
                            }
                            .font(.system(size: 10))
                            .foregroundColor(Color(UIColor.systemBlue))
                            .accessibilityLabel("\(gitManager.behindCount) commit\(gitManager.behindCount == 1 ? "" : "s") behind remote")
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Sync status: \(gitManager.aheadCount) ahead, \(gitManager.behindCount) behind")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(themeManager.currentTheme.sidebarBackground)
            
            Divider()
            
            // Merge Conflicts Banner
            if !gitManager.mergeConflicts.isEmpty {
                mergeConflictsBanner()
            }
            
            // Commit input
            VStack(spacing: 8) {
                TextField("Message (press ⌘Enter to commit)", text: $commitMessage)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
                
                HStack(spacing: 8) {
                    Button(action: commitChanges) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Commit")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(canCommit && !isOperationInProgress ? Color.accentColor : theme.border.opacity(0.5))
                        .foregroundColor(canCommit ? theme.editorBackground : theme.editorForeground.opacity(0.5))
                        .cornerRadius(6)
                    }
                    .disabled(!canCommit || isOperationInProgress)
                    .buttonStyle(.plain)
                    .keyboardShortcut(.return, modifiers: .command)
                    .accessibilityLabel("Commit changes")
                    .accessibilityHint(canCommit ? "Double tap to commit staged changes" : "Add a commit message and stage changes to commit")
                    
                    Menu {
                        Button(action: { stageAll() }) {
                            Label("Stage All", systemImage: "plus.circle")
                        }
                        Button(action: commitAndPush) {
                            Label("Commit & Push", systemImage: "arrow.up.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("More commit actions")
                    .accessibilityHint("Double tap for stage all or commit and push")
                }
            }
            .padding(12)
            
            Divider()
            
            // Changes list
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    // Merge Conflicts section
                    if !gitManager.mergeConflicts.isEmpty {
                        sectionHeader("Merge Conflicts", count: gitManager.mergeConflicts.count, color: .yellow)
                        ForEach(gitManager.mergeConflicts, id: \.self) { path in
                            conflictRow(path)
                        }
                    }
                    
                    // Staged changes
                    if !gitManager.stagedChanges.isEmpty {
                        sectionHeader("Staged Changes", count: gitManager.stagedChanges.count, color: .green)
                        ForEach(gitManager.stagedChanges) { entry in
                            changeRow(entry, isStaged: true)
                        }
                    }
                    
                    // Unstaged changes
                    if !gitManager.unstagedChanges.isEmpty {
                        HStack {
                            sectionHeader("Changes", count: gitManager.unstagedChanges.count, color: .orange)
                            Button(action: { showDiscardAllAlert = true }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 11))
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Discard all changes")
                        }
                        ForEach(gitManager.unstagedChanges) { entry in
                            changeRow(entry, isStaged: false)
                        }
                    }
                    
                    // Untracked files
                    if !gitManager.untrackedFiles.isEmpty {
                        sectionHeader("Untracked", count: gitManager.untrackedFiles.count, color: .secondary)
                        ForEach(gitManager.untrackedFiles) { entry in
                            changeRow(entry, isStaged: false)
                        }
                    }
                    
                    // No changes - show polished empty state
                    if gitManager.stagedChanges.isEmpty &&
                        gitManager.unstagedChanges.isEmpty &&
                        gitManager.untrackedFiles.isEmpty &&
                        gitManager.mergeConflicts.isEmpty {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 32))
                                .foregroundColor(Color(UIColor.systemGreen).opacity(0.7))
                                .accessibilityHidden(true)
                            Text("No changes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("All changes have been committed")
                                .font(.caption)
                                .foregroundColor(.secondary.opacity(0.7))
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("No changes. All changes have been committed.")
                    }
                    
                    // Recent commits
                    if !gitManager.recentCommits.isEmpty {
                        Divider()
                            .padding(.vertical, 8)
                        
                        sectionHeader("Recent Commits", count: gitManager.recentCommits.count, color: .secondary)
                        ForEach(gitManager.recentCommits.prefix(5)) { commit in
                            commitRow(commit)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            
            Spacer(minLength: 0)
            
            // Error display
            if let error = gitManager.error {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(theme.errorForeground)
                    Text(error)
                        .font(.system(size: 10))
                        .foregroundColor(theme.errorForeground)
                        .lineLimit(2)
                }
                .padding(8)
                .background(theme.errorBackground)
                .cornerRadius(6)
                .padding(.horizontal, 12)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Git error: \(error)")
            }
            
            Divider()
            
            // Bottom actions
            HStack(spacing: 12) {
                Button(action: pullChanges) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle")
                        Text("Pull")
                        if gitManager.behindCount > 0 {
                            Text("(\(gitManager.behindCount))")
                                .foregroundColor(Color(UIColor.systemBlue))
                        }
                    }
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .disabled(isOperationInProgress)
                .accessibilityLabel("Pull changes")
                .accessibilityHint(gitManager.behindCount > 0 ? "Double tap to pull \(gitManager.behindCount) commit\(gitManager.behindCount == 1 ? "" : "s") from remote" : "Double tap to pull changes from remote")
                
                Button(action: pushChanges) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle")
                        Text("Push")
                        if gitManager.aheadCount > 0 {
                            Text("(\(gitManager.aheadCount))")
                                .foregroundColor(Color(UIColor.systemOrange))
                        }
                    }
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .disabled(isOperationInProgress)
                .accessibilityLabel("Push changes")
                .accessibilityHint(gitManager.aheadCount > 0 ? "Double tap to push \(gitManager.aheadCount) commit\(gitManager.aheadCount == 1 ? "" : "s") to remote" : "Double tap to push changes to remote")
                
                Button(action: fetchChanges) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .disabled(isOperationInProgress)
                .accessibilityLabel("Fetch")
                .accessibilityHint("Double tap to fetch from remote without merging")
                
                Menu {
                    Button("Stash Changes") {
                        Task { try? await gitManager.stashPush(message: nil); await gitManager.refresh() }
                    }
                    Button("Pop Stash") {
                        Task { try? await gitManager.stashPop(index: 0); await gitManager.refresh() }
                    }
                    Button("Drop Stash", role: .destructive) {
                        Task { try? await gitManager.stashDrop(index: 0); await gitManager.refresh() }
                    }
                } label: {
                    Image(systemName: "tray.and.arrow.down.fill")
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .disabled(isOperationInProgress)
                .accessibilityLabel("Stash menu")
                
                Spacer()
            }
            .padding(12)
        }
        .background(Color(theme.editorBackground))
        .alert("Git Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showBranchPicker) {
            BranchPickerSheet(gitManager: gitManager)
        }
        .sheet(isPresented: $showGitConfig) {
            GitConfigSheet(gitManager: gitManager, name: $gitConfigName, email: $gitConfigEmail)
        }
        .fullScreenCover(item: $showingDiffEntry) { entry in
            GitDiffSheet(entry: entry)
        }
        .alert("Discard Changes?", isPresented: $showDiscardConfirmation) {
            Button("Discard", role: .destructive) {
                if let path = pendingDiscardPath {
                    Task { await performGitOp { try await gitManager.discardChanges(file: path) } }
                }
            }
            Button("Cancel", role: .cancel) { pendingDiscardPath = nil }
        } message: {
            Text("This will permanently discard all changes to \(pendingDiscardPath?.components(separatedBy: "/").last ?? "this file"). This cannot be undone.")
        }
        .alert("Commit & Push?", isPresented: $showCommitPushConfirmation) {
            Button("Commit & Push") { executeCommitAndPush() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Commit \"\(commitMessage)\" and push to remote?")
        }
        .alert("Discard All Changes?", isPresented: $showDiscardAllAlert) {
            Button("Discard All", role: .destructive) {
                Task { try? await gitManager.discardAll(); await gitManager.refresh() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently discard all unstaged changes and untracked files. This cannot be undone.")
        }
    }

    private var canCommit: Bool {
        !commitMessage.isEmpty && !gitManager.stagedChanges.isEmpty
    }
    
    private func sectionHeader(_ title: String, count: Int, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
            Text("\(count)")
                .font(.system(size: 10))
                .foregroundColor(color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.2))
                .cornerRadius(8)
            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(count) item\(count == 1 ? "" : "s")")
    }
    
    private func changeRow(_ entry: GitStatusEntry, isStaged: Bool) -> some View {
        HStack(spacing: 8) {
            // Status indicator
            Text(entry.kind.rawValue.prefix(1).uppercased())
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(entry.kind.color)
                .frame(width: 16)
                .accessibilityHidden(true)
            
            // File name
            Text(entry.path.components(separatedBy: "/").last ?? entry.path)
                .font(.system(size: 12))
                .lineLimit(1)
            
            Spacer()
            
            // Stage/unstage button
            if isStaged {
                Button(action: { unstageFile(entry.path) }) {
                    Image(systemName: "minus")
                        .font(.system(size: 10))
                        .foregroundColor(theme.errorForeground)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Unstage \(entry.path.components(separatedBy: "/").last ?? entry.path)")
                .accessibilityHint("Double tap to unstage this file")
            } else {
                Button(action: { stageFile(entry.path) }) {
                    Image(systemName: "plus")
                        .font(.system(size: 10))
                        .foregroundColor(Color(UIColor.systemGreen))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Stage \(entry.path.components(separatedBy: "/").last ?? entry.path)")
                .accessibilityHint("Double tap to stage this file")
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(selectedEntry?.id == entry.id ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(entry.kind.rawValue), \(entry.path.components(separatedBy: "/").last ?? entry.path), \(isStaged ? "staged" : "unstaged")")
        .accessibilityHint("Double tap to view diff")
        .onTapGesture {
            selectedEntry = entry
            showingDiffEntry = entry
        }
        .contextMenu {
            if isStaged {
                Button(action: { unstageFile(entry.path) }) {
                    Label("Unstage Changes", systemImage: "minus.circle")
                }
            } else {
                Button(action: { stageFile(entry.path) }) {
                    Label("Stage Changes", systemImage: "plus.circle")
                }
            }
            
            if !isStaged && entry.kind != .untracked {
                Button(role: .destructive, action: {
                    pendingDiscardPath = entry.path
                    showDiscardConfirmation = true
                }) {
                    Label("Discard Changes", systemImage: "trash")
                }
            }
            
            Divider()
            
            Button(action: {
                let url = URL(fileURLWithPath: entry.path)
                editorCore.openFile(from: url)
            }) {
                Label("Open File", systemImage: "doc.text")
            }
            
            Button(action: {
                UIPasteboard.general.string = entry.path
            }) {
                Label("Copy Path", systemImage: "doc.on.doc")
            }
        }
    }
    
    // MARK: - Merge Conflict UI
    
    private func mergeConflictsBanner() -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color(UIColor.systemYellow))
                .font(.system(size: 12))
            Text("\(gitManager.mergeConflicts.count) merge conflict\(gitManager.mergeConflicts.count == 1 ? "" : "s") detected")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(UIColor.systemYellow))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(UIColor.systemYellow).opacity(0.1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Warning: \(gitManager.mergeConflicts.count) merge conflict\(gitManager.mergeConflicts.count == 1 ? "" : "s") detected")
    }
    
    private func conflictRow(_ path: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 10))
                .foregroundColor(Color(UIColor.systemYellow))
                .frame(width: 16)
                .accessibilityHidden(true)
            
            Text(path.components(separatedBy: "/").last ?? path)
                .font(.system(size: 12))
                .lineLimit(1)
            
            Spacer()
            
            Menu {
                Button(action: {
                    Task { await performGitOp { try await gitManager.resolveConflict(file: path, resolution: .ours) } }
                }) {
                    Label("Accept Current (Ours)", systemImage: "arrow.uturn.left")
                }
                Button(action: {
                    Task { await performGitOp { try await gitManager.resolveConflict(file: path, resolution: .theirs) } }
                }) {
                    Label("Accept Incoming (Theirs)", systemImage: "arrow.uturn.right")
                }
                Divider()
                Button(action: {
                    Task { await performGitOp { try await gitManager.resolveConflict(file: path, resolution: .manual) } }
                }) {
                    Label("Resolve Manually", systemImage: "pencil.tip")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Resolve conflict options for \(path.components(separatedBy: "/").last ?? path)")
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(UIColor.systemYellow).opacity(0.08))
        .cornerRadius(4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Merge conflict in \(path.components(separatedBy: "/").last ?? path)")
        .accessibilityHint("Double tap for resolve options")
        .contextMenu {
            Button(action: {
                Task { await performGitOp { try await gitManager.resolveConflict(file: path, resolution: .ours) } }
            }) {
                Label("Accept Current (Ours)", systemImage: "arrow.uturn.left")
            }
            Button(action: {
                Task { await performGitOp { try await gitManager.resolveConflict(file: path, resolution: .theirs) } }
            }) {
                Label("Accept Incoming (Theirs)", systemImage: "arrow.uturn.right")
            }
            Divider()
            Button(action: {
                Task { await performGitOp { try await gitManager.resolveConflict(file: path, resolution: .manual) } }
            }) {
                Label("Resolve Manually", systemImage: "pencil.tip")
            }
            Divider()
            Button(action: {
                UIPasteboard.general.string = path
            }) {
                Label("Copy Path", systemImage: "doc.on.doc")
            }
        }
    }
    
    private func commitRow(_ commit: GitCommit) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(commit.shortSHA)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.accentColor)
                
                Text(commit.message)
                    .font(.system(size: 11))
                    .lineLimit(1)
            }
            
            HStack {
                Text(commit.author)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(commit.date, style: .relative)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Commit \(commit.shortSHA): \(commit.message), by \(commit.author)")
    }
    
    // MARK: - Actions
    
    private func refreshGit() {
        Task { await gitManager.refresh() }
    }
    
    private func stageFile(_ path: String) {
        Task { await performGitOp { try await gitManager.stage(file: path) } }
    }
    
    private func unstageFile(_ path: String) {
        Task { await performGitOp { try await gitManager.unstage(file: path) } }
    }
    
    private func stageAll() {
        Task { await performGitOp { try await gitManager.stageAll() } }
    }
    
    private func commitChanges() {
        guard canCommit else { return }
        let message = commitMessage
        commitMessage = ""
        Task {
            await performGitOp {
                try await gitManager.commit(message: message)
            }
            if showError {
                await MainActor.run { commitMessage = message }
            }
        }
    }
    
    private func commitAndPush() {
        showCommitPushConfirmation = true
    }
    
    private func executeCommitAndPush() {
        guard canCommit else { return }
        let message = commitMessage
        commitMessage = ""
        Task {
            await performGitOp {
                try await gitManager.commit(message: message)
                try await gitManager.push()
            }
            if showError {
                await MainActor.run { commitMessage = message }
            }
        }
    }
    
    private func pullChanges() {
        Task { await performGitOp { try await gitManager.pull() } }
    }
    
    private func pushChanges() {
        Task { await performGitOp { try await gitManager.push() } }
    }
    
    private func fetchChanges() {
        Task { await performGitOp { try await gitManager.fetch() } }
    }
    
    /// Performs a git operation with proper error handling and user feedback
    private func performGitOp(_ operation: @escaping () async throws -> Void) async {
        isOperationInProgress = true
        defer { isOperationInProgress = false }
        do {
            try await operation()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            AppLogger.git.debug("[GitView] Git operation failed: \(error.localizedDescription)")
        }
    }
    
    private func loadGitConfig() {
        Task {
            do {
                let name = try await gitManager.getConfig(key: "user.name") ?? ""
                let email = try await gitManager.getConfig(key: "user.email") ?? ""
                await MainActor.run {
                    gitConfigName = name
                    gitConfigEmail = email
                    gitConfigError = nil
                }
            } catch {
                await MainActor.run {
                    gitConfigError = "Failed to load git config: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Branch Picker Sheet

struct BranchPickerSheet: View {
    @ObservedObject var gitManager: GitManager
    @Environment(\.dismiss) private var dismiss
    @State private var newBranchName = ""
    @State private var showCreateBranch = false
    @State private var branchError: String?
    @State private var showBranchError = false
    
    var localBranches: [GitBranch] {
        gitManager.branches.filter { !$0.isRemote }
    }
    
    var remoteBranches: [GitBranch] {
        gitManager.remoteBranches
    }
    
    var body: some View {
        NavigationView {
            List {
                // Create new branch
                Section {
                    if showCreateBranch {
                        HStack {
                            TextField("New branch name", text: $newBranchName)
                                .textFieldStyle(.roundedBorder)
                            
                            Button("Create") {
                                createBranch()
                            }
                            .disabled(newBranchName.isEmpty)
                            .accessibilityLabel("Create branch")
                            .accessibilityHint("Double tap to create branch with the entered name")
                        }
                    } else {
                        Button(action: { showCreateBranch = true }) {
                            Label("Create New Branch", systemImage: "plus.circle")
                        }
                    }
                }
                
                // Local branches
                    Section("Local Branches") {
                        ForEach(localBranches) { branch in
                            Button(action: { checkout(branch.name) }) {
                                HStack {
                                    if branch.isCurrent {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                    Text(branch.name)
                                        .foregroundColor(branch.isCurrent ? .accentColor : .primary)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(branch.name)\(branch.isCurrent ? ", current branch" : "")")
                            .accessibilityHint(branch.isCurrent ? "Currently selected branch" : "Double tap to switch to this branch")
                            .swipeActions(edge: .trailing) {
                                if !branch.isCurrent {
                                    Button(role: .destructive) {
                                        Task {
                                            try? await gitManager.deleteBranch(name: branch.name)
                                            await gitManager.refresh()
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                
                // Remote branches
                if !remoteBranches.isEmpty {
                    Section("Remote Branches") {
                        ForEach(remoteBranches) { branch in
                            Button(action: { checkout(branch.name) }) {
                                HStack {
                                    Text(branch.name)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(branch.name), remote")
                            .accessibilityHint("Double tap to checkout this remote branch")
                        }
                    }
                }
            }
            .navigationTitle("Branches")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Branch Error", isPresented: $showBranchError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(branchError ?? "An unknown error occurred")
            }
        }
    }
    
    private func checkout(_ branch: String) {
        Task {
            do {
                try await gitManager.checkout(branch: branch)
                await MainActor.run { dismiss() }
            } catch {
                await MainActor.run {
                    branchError = error.localizedDescription
                    showBranchError = true
                }
            }
        }
    }

    
    private func createBranch() {
        guard !newBranchName.isEmpty else { return }
        Task {
            do {
                try await gitManager.createBranch(name: newBranchName)
                await MainActor.run {
                    newBranchName = ""
                    showCreateBranch = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    branchError = error.localizedDescription
                    showBranchError = true
                }
            }
        }
    }

}


// MARK: - Git Config Sheet

struct GitConfigSheet: View {
    @ObservedObject var gitManager: GitManager
    @Binding var name: String
    @Binding var email: String
    @Environment(\.dismiss) private var dismiss
    @State private var editingName = ""
    @State private var editingEmail = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var showSaveError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Commit Author Identity") {
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                            .accessibilityHidden(true)
                        TextField("Name", text: $editingName)
                            .textContentType(.name)
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                            .accessibilityHidden(true)
                        TextField("Email", text: $editingEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                
                Section {
                    Text("This identity will be used for your commits in this repository.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Git Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveConfig()
                    }
                    .disabled(editingName.isEmpty || editingEmail.isEmpty || isSaving)
                    .bold(true)
                }
            }
            .alert("Save Error", isPresented: $showSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveError ?? "An unknown error occurred")
            }
        }
        .onAppear {
            editingName = name
            editingEmail = email
        }
    }
    
    private func saveConfig() {
        guard !editingName.isEmpty, !editingEmail.isEmpty else { return }
        isSaving = true
        Task {
            do {
                try await gitManager.setConfig(key: "user.name", value: editingName)
                try await gitManager.setConfig(key: "user.email", value: editingEmail)
                await MainActor.run {
                    name = editingName
                    email = editingEmail
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    saveError = error.localizedDescription
                    showSaveError = true
                    isSaving = false
                }
            }
        }
    }
}
