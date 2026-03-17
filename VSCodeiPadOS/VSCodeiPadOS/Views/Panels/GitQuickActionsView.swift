import SwiftUI

/// Quick actions sheet wired to GitManager for Pull/Push + Stash operations.
struct GitQuickActionsView: View {
    @ObservedObject private var git = GitManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var stashMessage: String = ""
    
    /// Computed property for whether there are uncommitted changes
    private var hasUncommittedChanges: Bool {
        !git.stagedChanges.isEmpty || !git.unstagedChanges.isEmpty || !git.untrackedFiles.isEmpty
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                pullPushSection
                statusSection
                stashSection
                Spacer()
            }
            .padding(.top, 12)
            .navigationTitle("Git")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await git.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(git.isLoading)
                }
            }
            .overlay {
                if git.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
        }
        .onAppear {
            Task { await git.refresh() }
        }
    }
    
    // MARK: - Pull/Push Section
    
    @ViewBuilder
    private var pullPushSection: some View {
        HStack(spacing: 12) {
            Button {
                Task { try? await git.pull() }
            } label: {
                Label("Pull", systemImage: "arrow.down.to.line")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(git.isLoading)

            Button {
                Task { try? await git.push() }
            } label: {
                Label("Push", systemImage: "arrow.up.to.line")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(git.isLoading)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Status Section
    
    @ViewBuilder
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STATUS")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView {
                statusContent
            }
            .frame(maxHeight: 160)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var statusContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            branchInfoRow
            aheadBehindRow
            Divider()
            changesContent
        }
        .font(.system(.footnote, design: .monospaced))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
    }
    
    @ViewBuilder
    private var branchInfoRow: some View {
        HStack {
            Image(systemName: "arrow.triangle.branch")
            Text("On branch \(git.currentBranch)")
                .fontWeight(.medium)
        }
    }
    
    @ViewBuilder
    private var aheadBehindRow: some View {
        if git.aheadCount > 0 || git.behindCount > 0 {
            HStack {
                if git.aheadCount > 0 {
                    Text("↑\(git.aheadCount) ahead")
                        .foregroundColor(.orange)
                }
                if git.behindCount > 0 {
                    Text("↓\(git.behindCount) behind")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    @ViewBuilder
    private var changesContent: some View {
        if git.stagedChanges.isEmpty && git.unstagedChanges.isEmpty {
            Text("Nothing to commit, working tree clean")
                .foregroundColor(.secondary)
        } else {
            stagedChangesView
            unstagedChangesView
        }
    }
    
    @ViewBuilder
    private var stagedChangesView: some View {
        if !git.stagedChanges.isEmpty {
            Text("Changes to be committed:")
                .foregroundColor(.green)
            ForEach(git.stagedChanges) { entry in
                Text("  \(entry.kind.rawValue): \(entry.path)")
                    .font(.system(.footnote, design: .monospaced))
            }
        }
    }
    
    @ViewBuilder
    private var unstagedChangesView: some View {
        if !git.unstagedChanges.isEmpty {
            Text("Changes not staged for commit:")
                .foregroundColor(.red)
            ForEach(git.unstagedChanges) { entry in
                Text("  \(entry.kind.rawValue): \(entry.path)")
                    .font(.system(.footnote, design: .monospaced))
            }
        }
    }
    
    // MARK: - Stash Section
    
    @ViewBuilder
    private var stashSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STASH")
                .font(.caption)
                .foregroundStyle(.secondary)

            stashInputRow
            stashListView
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var stashInputRow: some View {
        HStack(spacing: 10) {
            TextField("Message (optional)", text: $stashMessage)
                .textFieldStyle(.roundedBorder)

            Button("Save") {
                Task {
                    try? await git.stashPush(message: stashMessage.isEmpty ? nil : stashMessage)
                    await MainActor.run { stashMessage = "" }
                }
            }
            .buttonStyle(.bordered)
            .disabled(git.isLoading || !hasUncommittedChanges)
        }
    }
    
    @ViewBuilder
    private var stashListView: some View {
        if git.stashes.isEmpty {
            emptyStashView
        } else {
            stashListContent
        }
    }
    
    @ViewBuilder
    private var emptyStashView: some View {
        Text("No stashes")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    @ViewBuilder
    private var stashListContent: some View {
        List {
            ForEach(git.stashes) { stash in
                StashRowView(stash: stash, git: git)
            }
        }
        .listStyle(.plain)
        .frame(maxHeight: 220)
    }
}

// MARK: - Stash Row View

struct StashRowView: View {
    let stash: GitStashEntry
    @ObservedObject var git: GitManager
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("stash@{\(stash.index)}")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text(stash.message)
                    .font(.footnote)
                    .lineLimit(2)
            }

            Spacer()

            Button("Pop") {
                Task { try? await git.stashPop(index: stash.index) }
            }
            .buttonStyle(.bordered)
            .disabled(git.isLoading)

            Button("Drop") {
                Task { try? await git.stashDrop(index: stash.index) }
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .disabled(git.isLoading)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GitQuickActionsView()
}
