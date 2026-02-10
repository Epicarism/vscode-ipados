import SwiftUI
import SwiftUI

// MARK: - Git View (Source Control Panel)

struct GitView: View {
    @ObservedObject private var gitManager = GitManager.shared
    @EnvironmentObject var editorCore: EditorCore
    @State private var commitMessage = ""
    @State private var selectedEntry: GitStatusEntry?
    @State private var showingDiffEntry: GitStatusEntry?
    @State private var showBranchPicker = false
    
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
                }
                
                Button(action: refreshGit) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .disabled(gitManager.isLoading)
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
                            .foregroundColor(.orange)
                        }
                        if gitManager.behindCount > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.down")
                                Text("\(gitManager.behindCount)")
                            }
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
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
                        .background(canCommit ? Color.accentColor : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    .disabled(!canCommit)
                    .buttonStyle(.plain)
                    
                    Menu {
                        Button(action: { Task { try? await gitManager.stageAll() } }) {
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
                }
            }
            .padding(12)
            
            Divider()
            
            // Changes list
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    // Staged changes
                    if !gitManager.stagedChanges.isEmpty {
                        sectionHeader("Staged Changes", count: gitManager.stagedChanges.count, color: .green)
                        ForEach(gitManager.stagedChanges) { entry in
                            changeRow(entry, isStaged: true)
                        }
                    }
                    
                    // Unstaged changes
                    if !gitManager.unstagedChanges.isEmpty {
                        sectionHeader("Changes", count: gitManager.unstagedChanges.count, color: .orange)
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
                    
                    // No changes
                    if gitManager.stagedChanges.isEmpty &&
                        gitManager.unstagedChanges.isEmpty &&
                        gitManager.untrackedFiles.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            Text("No changes")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
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
                        .foregroundColor(.red)
                    Text(error)
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                        .lineLimit(2)
                }
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
                .padding(.horizontal, 12)
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
                                .foregroundColor(.blue)
                        }
                    }
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                
                Button(action: pushChanges) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle")
                        Text("Push")
                        if gitManager.aheadCount > 0 {
                            Text("(\(gitManager.aheadCount))")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                
                Button(action: fetchChanges) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(12)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showBranchPicker) {
            BranchPickerSheet(gitManager: gitManager)
        }
        .fullScreenCover(item: $showingDiffEntry) { entry in
            GitDiffSheet(entry: entry)
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
    }
    
    private func changeRow(_ entry: GitStatusEntry, isStaged: Bool) -> some View {
        HStack(spacing: 8) {
            // Status indicator
            Text(entry.kind.rawValue.prefix(1).uppercased())
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(entry.kind.color)
                .frame(width: 16)
            
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
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: { stageFile(entry.path) }) {
                    Image(systemName: "plus")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(selectedEntry?.id == entry.id ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(4)
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
                    Task { try? await gitManager.discardChanges(file: entry.path) }
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
    }
    
    // MARK: - Actions
    
    private func refreshGit() {
        Task { await gitManager.refresh() }
    }
    
    private func stageFile(_ path: String) {
        Task { try? await gitManager.stage(file: path) }
    }
    
    private func unstageFile(_ path: String) {
        Task { try? await gitManager.unstage(file: path) }
    }
    
    private func commitChanges() {
        guard canCommit else { return }
        Task {
            try? await gitManager.commit(message: commitMessage)
            await MainActor.run { commitMessage = "" }
        }
    }
    
    private func commitAndPush() {
        guard canCommit else { return }
        Task {
            try? await gitManager.commit(message: commitMessage)
            await MainActor.run { commitMessage = "" }
            try? await gitManager.push()
        }
    }
    
    private func pullChanges() {
        Task { try? await gitManager.pull() }
    }
    
    private func pushChanges() {
        Task { try? await gitManager.push() }
    }
    
    private func fetchChanges() {
        Task { try? await gitManager.fetch() }
    }
}

// MARK: - Branch Picker Sheet

struct BranchPickerSheet: View {
    @ObservedObject var gitManager: GitManager
    @Environment(\.dismiss) private var dismiss
    @State private var newBranchName = ""
    @State private var showCreateBranch = false
    
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
        }
    }
    
    private func checkout(_ branch: String) {
        Task {
            try? await gitManager.checkout(branch: branch)
            await MainActor.run { dismiss() }
        }
    }
    
    private func createBranch() {
        guard !newBranchName.isEmpty else { return }
        Task {
            try? await gitManager.createBranch(name: newBranchName)
            await MainActor.run {
                newBranchName = ""
                showCreateBranch = false
                dismiss()
            }
        }
    }
}
