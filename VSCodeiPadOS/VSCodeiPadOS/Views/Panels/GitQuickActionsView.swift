import SwiftUI

/// Quick actions sheet wired to GitManager for Pull/Push + Stash operations.
struct GitQuickActionsView: View {
    @ObservedObject private var git = GitManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var stashMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // Pull / Push
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

                // Status
                VStack(alignment: .leading, spacing: 8) {
                    Text("STATUS")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "arrow.triangle.branch")
                                Text("On branch \(git.currentBranch)")
                                    .fontWeight(.medium)
                            }
                            
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
                            
                            Divider()
                            
                            if git.stagedChanges.isEmpty && git.unstagedChanges.isEmpty {
                                Text("Nothing to commit, working tree clean")
                                    .foregroundColor(.secondary)
                            } else {
                                if !git.stagedChanges.isEmpty {
                                    Text("Changes to be committed:")
                                        .foregroundColor(.green)
                                    ForEach(git.stagedChanges) { entry in
                                        Text("  \(entry.kind.rawValue): \(entry.path)")
                                            .font(.system(.footnote, design: .monospaced))
                                    }
                                }
                                
                                if !git.unstagedChanges.isEmpty {
                                    Text("Changes not staged for commit:")
                                        .foregroundColor(.red)
                                    ForEach(git.unstagedChanges) { entry in
                                        Text("  \(entry.kind.rawValue): \(entry.path)")
                                            .font(.system(.footnote, design: .monospaced))
                                    }
                                }
                            }
                        }
                        .font(.system(.footnote, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                    }
                    .frame(maxHeight: 160)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .padding(.horizontal)

                // Stash Save + list
                VStack(alignment: .leading, spacing: 8) {
                    Text("STASH")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        TextField("Message (optional)", text: $stashMessage)
                            .textFieldStyle(.roundedBorder)

                        Button("Save") {
                            Task {
                                try? await git.stashSave(message: stashMessage.isEmpty ? nil : stashMessage)
                                await MainActor.run { stashMessage = "" }
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(git.isLoading || !git.hasUncommittedChanges)
                    }

                    if git.stashes.isEmpty {
                        Text("No stashes")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    } else {
                        List {
                            ForEach(git.stashes) { stash in
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

                                    Button("Apply") {
                                        Task { try? await git.stashApply(index: stash.index) }
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(git.isLoading)

                                    Button("Pop") {
                                        Task { try? await git.stashPop(index: stash.index) }
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                    .disabled(git.isLoading)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.plain)
                        .frame(maxHeight: 220)
                    }
                }
                .padding(.horizontal)

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
}

#Preview {
    GitQuickActionsView()
}
