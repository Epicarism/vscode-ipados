import SwiftUI

/// Reusable git branch selector + management menu.
struct BranchMenu<Label: View>: View {
    @ObservedObject var git: GitManager
    let label: () -> Label
    
    @State private var showCreateBranchAlert: Bool = false
    @State private var newBranchName: String = ""
    @State private var pendingDeleteBranch: String? = nil
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var showDeleteAlert: Bool = false
    
    private var localBranches: [GitBranch] {
        git.branches.filter { !$0.isRemote }
    }
    
    private var deletableBranches: [GitBranch] {
        localBranches.filter { !$0.isCurrent }
    }
    
    var body: some View {
        Menu {
            branchListSection
            Divider()
            createBranchButton
            deleteBranchMenu
        } label: {
            label()
        }
        .alert("Create Branch", isPresented: $showCreateBranchAlert) {
            createBranchAlertContent
        } message: {
            Text("Enter a new branch name")
        }
        .alert("Delete Branch", isPresented: $showDeleteAlert) {
            deleteBranchAlertContent
        } message: {
            deleteBranchAlertMessage
        }
        .alert("Git Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Branch List
    
    @ViewBuilder
    private var branchListSection: some View {
        ForEach(localBranches) { branch in
            Button {
                Task { try? await git.checkout(branch: branch.name) }
            } label: {
                HStack {
                    Text(branch.name)
                    if branch.isCurrent {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
            .disabled(git.isLoading)
        }
    }
    
    // MARK: - Create Branch
    
    private var createBranchButton: some View {
        Button("Create Branch…") {
            newBranchName = ""
            showCreateBranchAlert = true
        }
        .disabled(git.isLoading)
    }
    
    @ViewBuilder
    private var createBranchAlertContent: some View {
        TextField("Branch name", text: $newBranchName)
        Button("Cancel", role: .cancel) {}
        Button("Create") {
            Task {
                do {
                    try await git.createBranch(name: newBranchName)
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            }
        }
    }
    
    // MARK: - Delete Branch
    
    @ViewBuilder
    private var deleteBranchMenu: some View {
        Menu("Delete Branch") {
            if deletableBranches.isEmpty {
                Text("No other branches")
            } else {
                ForEach(deletableBranches) { branch in
                    Button(role: .destructive) {
                        pendingDeleteBranch = branch.name
                        showDeleteAlert = true
                    } label: {
                        Text(branch.name)
                    }
                    .disabled(git.isLoading)
                }
            }
        }
        .disabled(git.isLoading)
    }
    
    @ViewBuilder
    private var deleteBranchAlertContent: some View {
        Button("Cancel", role: .cancel) {
            pendingDeleteBranch = nil
        }
        Button("Delete", role: .destructive) {
            if let name = pendingDeleteBranch {
                Task {
                    do {
                        try await git.deleteBranch(name: name)
                    } catch {
                        await MainActor.run {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                }
                pendingDeleteBranch = nil
            }
        }
    }
    
    @ViewBuilder
    private var deleteBranchAlertMessage: some View {
        if let branch = pendingDeleteBranch {
            Text("Are you sure you want to delete \"\(branch)\"?")
        } else {
            Text("")
        }
    }
}
