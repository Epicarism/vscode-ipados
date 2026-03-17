//
//  GitManager.swift
//  VSCodeiPadOS
//
//  Git Manager - hybrid local/SSH implementation
//

// MARK: - Merge Conflict Notification Name

extension Notification.Name {
    /// Posted when a `git pull` or `git merge` encounters merge conflicts.
    /// The `userInfo` dictionary contains the key `"conflictedFiles"` with
    /// an `[String]` value listing the affected file paths.
    static let gitMergeConflictsDetected = Notification.Name("GitMergeConflictsDetected")
}

// MARK: - Merge Conflict Resolution

/// Describes how a single conflicted file should be resolved.
enum MergeConflictResolution {
    /// Keep the version from the current branch (HEAD / "ours").
    case ours
    /// Keep the version from the incoming branch ("theirs").
    case theirs
    /// Open the file in the editor so the user can manually resolve markers.
    case manual
}

import SwiftUI
import Combine
import Compression
import CommonCrypto

// MARK: - Shell Escaping

private extension String {
    /// Escapes single quotes for safe interpolation into shell commands.
    var shellEscaped: String {
        self.replacingOccurrences(of: "'", with: "'\\''")
    }
}

// MARK: - Git Errors

enum GitManagerError: Error, LocalizedError {
    case noRepository
    case gitExecutableNotFound
    case commandFailed(args: String, exitCode: Int, message: String)
    case notAvailableOnIOS
    case sshNotConnected
    case invalidRepository
    case cloneFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noRepository:
            return "No git repository configured"
        case .gitExecutableNotFound:
            return "Git executable not found"
        case let .commandFailed(args, exitCode, message):
            return "git \(args) failed (\(exitCode)): \(message)"
        case .notAvailableOnIOS:
            return "Git is not available on iOS"
        case .sshNotConnected:
            return "SSH connection required for git operations"
        case .invalidRepository:
            return "Invalid git repository"
        case .cloneFailed(let reason):
            return "Clone failed: \(reason)"
        }
    }
}

// MARK: - Git Types

enum GitChangeKind: String, Codable, Hashable {
    case modified = "M"
    case added = "A"
    case deleted = "D"
    case renamed = "R"
    case copied = "C"
    case untracked = "?"
    case ignored = "!"
    case unmerged = "U"
    case typeChanged = "T"
    case unknown = "X"
    
    var icon: String {
        switch self {
        case .modified: return "pencil"
        case .added: return "plus"
        case .deleted: return "minus"
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .untracked: return "questionmark"
        case .ignored: return "eye.slash"
        case .unmerged: return "exclamationmark.triangle"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        case .unknown: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .modified: return .orange
        case .added: return .green
        case .deleted: return .red
        case .renamed: return .blue
        case .copied: return .blue
        case .untracked: return .gray
        case .ignored: return .gray
        case .unmerged: return .yellow
        case .typeChanged: return .purple
        case .unknown: return .gray
        }
    }
}

struct GitBranch: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let isRemote: Bool
    let isCurrent: Bool
    
    init(name: String, isRemote: Bool = false, isCurrent: Bool = false) {
        self.name = name
        self.isRemote = isRemote
        self.isCurrent = isCurrent
    }
}

struct GitCommit: Identifiable, Hashable {
    let id: String // SHA
    let message: String
    let author: String
    let date: Date
    
    var shortSHA: String {
        String(id.prefix(7))
    }
}

struct GitFileChange: Identifiable, Hashable {
    var id: String { "\(staged ? "staged" : "unstaged")-\(path)" }
    let path: String
    let kind: GitChangeKind
    let staged: Bool
    
    init(path: String, kind: GitChangeKind, staged: Bool = false) {
        self.path = path
        self.kind = kind
        self.staged = staged
    }
}

struct GitStashEntry: Identifiable, Hashable {
    let id = UUID()
    let index: Int
    let message: String
    let branch: String
}

/// Represents a single line in git blame output
struct BlameLine: Identifiable, Hashable {
    let id = UUID()
    let lineNumber: Int
    let commitSHA: String      // Short SHA (7 chars)
    let author: String
    let date: Date
    let lineContent: String
}

/// Represents a git tag
struct GitTag: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let commitSHA: String
    let message: String?       // Only for annotated tags
    let isAnnotated: Bool
}

// Type alias for compatibility with GitView
typealias GitStatusEntry = GitFileChange

// MARK: - Git Manager

@MainActor
final class GitManager: ObservableObject {
    static let shared = GitManager()
    
    // MARK: - Published State
    
    @Published var isRepository: Bool = false
    @Published var currentBranch: String = "main"
    @Published var branches: [GitBranch] = []
    @Published var remoteBranches: [GitBranch] = []
    @Published var stagedChanges: [GitFileChange] = []
    @Published var unstagedChanges: [GitFileChange] = []
    @Published var untrackedFiles: [GitFileChange] = []
    @Published var recentCommits: [GitCommit] = []
    @Published var stashes: [GitStashEntry] = []
    @Published var isLoading: Bool = false
    @Published var lastError: String?
    @Published var aheadCount: Int = 0
    @Published var behindCount: Int = 0
    /// Files currently in a merge-conflict state (updated after pull/merge).
    @Published var mergeConflicts: [String] = []

    var totalChanges: Int {
        stagedChanges.count + unstagedChanges.count + untrackedFiles.count
    }

    /// The file-system path of the current working directory (exposed for timeline handlers).
    var workingDirectoryPath: String? { workingDirectory?.path }

    private var workingDirectory: URL?
    private var nativeReader: NativeGitReader?
    private var nativeWriter: NativeGitWriter?
    
    /// Data structure for passing refresh results from background to main thread
    private struct RefreshData: Sendable {
        let currentBranch: String
        let branches: [GitBranch]
        let remoteBranches: [GitBranch]
        let fileStatuses: [GitFileStatus]
        let recentCommits: [GitCommit]
        let aheadCount: Int
        let behindCount: Int
    }
    
    /// Task tracking for cancellation and debouncing
    private var refreshTask: Task<(error: String?, data: RefreshData?), Never>?
    private var debounceTask: Task<Void, Never>?
    
    private init() {}
    
    // MARK: - Repository Setup
    
    func setWorkingDirectory(_ url: URL?) {
        self.workingDirectory = url
        
        if let url {
            self.nativeReader = NativeGitReader(repositoryURL: url)
            self.nativeWriter = NativeGitWriter(repositoryURL: url)
            self.isRepository = (self.nativeReader != nil)
        } else {
            self.nativeReader = nil
            self.nativeWriter = nil
            self.isRepository = false
        }
        
        if isRepository {
            Task { await refresh() }
        } else {
            clearRepository()
        }
    }
    
    func clearRepository() {
        isRepository = false
        currentBranch = "main"
        branches = []
        remoteBranches = []
        stagedChanges = []
        unstagedChanges = []
        untrackedFiles = []
        recentCommits = []
        stashes = []
        mergeConflicts = []
        lastError = nil
    }
    
    // MARK: - Git Operations
    
    func refresh() async {
        // Cancel any in-flight refresh
        refreshTask?.cancel()
        
        // Capture the repo URL to create reader in background
        guard let repoURL = workingDirectory else {
            lastError = "No git repository found"
            return
        }
        
        isLoading = true
        lastError = nil
        
        // Run all heavy I/O on a background thread
        refreshTask = Task.detached { [weak self] in
            // Create reader inside detached task (NativeGitReader is not Sendable)
            guard let reader = NativeGitReader(repositoryURL: repoURL) else {
                return (error: "No git repository found", data: nil as RefreshData?)
            }
            
            // Current branch
            let branch = reader.currentBranch() ?? "HEAD"
            
            // Branches
            let localBranchNames = reader.localBranches()
            let localBranches = localBranchNames.map { name in
                GitBranch(name: name, isRemote: false, isCurrent: name == branch)
            }
            
            let remoteBranchPairs = reader.remoteBranches()
            let remoteBranches = remoteBranchPairs.map { (remote, br) in
                GitBranch(name: "\(remote)/\(br)", isRemote: true, isCurrent: false)
            }
            
            // Status
            let fileStatuses = reader.status()
            
            // Recent commits
            let commits = reader.recentCommits(count: 20)
            let recentCommits = commits.map { commit in
                GitCommit(id: commit.sha, message: commit.message, author: commit.author, date: commit.authorDate)
            }
            
            // Ahead/behind counting
            var aheadCount = 0
            var behindCount = 0
            
            if let headSHA = reader.headSHA() {
                // Look for a remote tracking branch matching the current branch
                let trackingRemote = remoteBranches.first { $0.name.hasSuffix("/\(branch)") }
                if let tracking = trackingRemote {
                    let refPath = repoURL.appendingPathComponent(".git/refs/remotes/\(tracking.name)")
                    var remoteSHA: String?
                    if let data = try? Data(contentsOf: refPath) {
                        remoteSHA = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        // Fallback: check packed-refs
                        let packedRefPath = repoURL.appendingPathComponent(".git/packed-refs")
                        if let packedContent = try? String(contentsOf: packedRefPath, encoding: .utf8) {
                            for line in packedContent.components(separatedBy: .newlines) {
                                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                                guard !trimmedLine.isEmpty, !trimmedLine.hasPrefix("#") else { continue }
                                let parts = trimmedLine.components(separatedBy: .whitespaces)
                                guard parts.count >= 2 else { continue }
                                if parts[1] == "refs/remotes/\(tracking.name)" {
                                    remoteSHA = parts[0]
                                    break
                                }
                            }
                        }
                    }
                    if let remoteSHA, remoteSHA != headSHA {
                        let (ahead, behind) = Self.countAheadBehindStatic(
                            headSHA: headSHA,
                            remoteSHA: remoteSHA,
                            reader: reader
                        )
                        aheadCount = ahead
                        behindCount = behind
                    }
                }
            }
            
            
            let data = RefreshData(
                currentBranch: branch,
                branches: localBranches,
                remoteBranches: remoteBranches,
                fileStatuses: fileStatuses,
                recentCommits: recentCommits,
                aheadCount: aheadCount,
                behindCount: behindCount
            )
            return (error: nil, data: data)
        }
        
        // Await background work and update @Published on MainActor
        let result = await refreshTask?.value
        
        guard let (error, data) = result else {
            isLoading = false
            return
        }
        
        if let error = error {
            lastError = error
            isLoading = false
            return
        }
        
        guard let data = data else {
            isLoading = false
            return
        }
        
        // Update all @Published properties on MainActor
        currentBranch = data.currentBranch
        branches = data.branches
        remoteBranches = data.remoteBranches
        
        stagedChanges = data.fileStatuses.compactMap { status -> GitFileChange? in
            guard let staged = status.staged else { return nil }
            return GitFileChange(path: status.path, kind: mapStatusType(staged), staged: true)
        }
        
        unstagedChanges = data.fileStatuses.compactMap { status -> GitFileChange? in
            guard let working = status.working, working != .untracked else { return nil }
            return GitFileChange(path: status.path, kind: mapStatusType(working), staged: false)
        }
        
        untrackedFiles = data.fileStatuses.compactMap { status -> GitFileChange? in
            guard status.working == .untracked else { return nil }
            return GitFileChange(path: status.path, kind: .untracked, staged: false)
        }
        
        recentCommits = data.recentCommits
        aheadCount = data.aheadCount
        behindCount = data.behindCount
        
        isLoading = false
    }
    
    /// Debounced refresh - waits 300ms before actually refreshing, canceling any pending refresh.
    /// Use this for rapid operations to avoid queuing multiple refreshes.
    func debouncedRefresh() async {
        // Cancel any pending debounce
        debounceTask?.cancel()
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            guard !Task.isCancelled else { return }
            await refresh()
        }
        
        await debounceTask?.value
    }
    
    /// Static version of countAheadBehind for use from detached context
    nonisolated private static func countAheadBehindStatic(headSHA: String, remoteSHA: String, reader: NativeGitReader) -> (ahead: Int, behind: Int) {
        var ahead: Int = 0
        var behind: Int = 0
        let maxWalk: Int = 200
        
        // Walk from HEAD towards the remote tracking branch
        var visited = Set<String>()
        var queue = [headSHA]
        var foundRemote = false
        while !queue.isEmpty && ahead < maxWalk {
            let sha = queue.removeFirst()
            guard !visited.contains(sha) else { continue }
            visited.insert(sha)
            if sha == remoteSHA {
                foundRemote = true
                break
            }
            ahead += 1
            if let commit = reader.parseCommit(sha: sha), let parent = commit.parentSHA {
                queue.append(parent)
            }
        }
        if !foundRemote {
            ahead = max(ahead, 1)
        }
        
        // Walk from remote towards HEAD
        visited.removeAll()
        queue = [remoteSHA]
        var foundHead = false
        while !queue.isEmpty && behind < maxWalk {
            let sha = queue.removeFirst()
            guard !visited.contains(sha) else { continue }
            visited.insert(sha)
            if sha == headSHA {
                foundHead = true
                break
            }
            behind += 1
            if let commit = reader.parseCommit(sha: sha), let parent = commit.parentSHA {
                queue.append(parent)
            }
        }
        if !foundHead {
            behind = max(behind, 1)
        }
        
        return (ahead, behind)
    }
    
    private func mapStatusType(_ status: GitStatusType) -> GitChangeKind {
        switch status {
        case .modified: return .modified
        case .added: return .added
        case .deleted: return .deleted
        case .renamed: return .renamed
        case .copied: return .copied
        case .untracked: return .untracked
        case .ignored: return .ignored
        }
    }
    
    /// Build a real diff for a working-copy file against HEAD (offline, using NativeGitReader).
    func diffWorkingCopyToHEAD(path: String, kind: GitChangeKind) async -> DiffFile? {
        guard let repoURL = workingDirectory else { return nil }
        
        return await Task.detached {
            guard let reader = NativeGitReader(repositoryURL: repoURL) else { return nil }
            
            let headSha = reader.headSHA()
            let oldText = reader.fileContentsString(atPath: path, commitSHA: headSha) ?? ""
            
            let workingURL = repoURL.appendingPathComponent(path)
            let newText = (try? String(contentsOf: workingURL, encoding: .utf8)) ?? ""
            
            return DiffBuilder.build(
                fileName: path,
                status: kind.rawValue,
                old: oldText,
                new: newText
            )
        }.value
    }
    
    func stage(file: String) async throws {
        guard let writer = nativeWriter else {
            throw GitManagerError.invalidRepository
        }
        try writer.stageFile(path: file)
        await refresh()
    }
    
    func stageAll() async throws {
        guard let writer = nativeWriter else {
            throw GitManagerError.invalidRepository
        }
        try writer.stageAll()
        await refresh()
    }
    
    func unstage(file: String) async throws {
        guard let writer = nativeWriter else {
            throw GitManagerError.invalidRepository
        }
        try writer.unstageFile(path: file)
        await refresh()
    }
    
    func commit(message: String) async throws {
        guard workingDirectory != nil else {
            throw GitManagerError.noRepository
        }
        guard let writer = nativeWriter else {
            throw GitManagerError.invalidRepository
        }
        let _ = try writer.commit(message: message)
        await refresh()
    }
    
    func checkout(branch: String) async throws {
        // Local branch checkout via ref file manipulation
        guard let repoURL = workingDirectory else {
            throw GitManagerError.noRepository
        }
        
        // Validate branch name to prevent path traversal and corruption
        guard isValidBranchName(branch) else {
            throw GitManagerError.commandFailed(args: "checkout", exitCode: 1, message: "Invalid branch name: contains forbidden characters")
        }
        
        let refPath = repoURL.appendingPathComponent(".git/refs/heads/\(branch)")
        guard FileManager.default.fileExists(atPath: refPath.path) else {
            throw GitManagerError.invalidRepository
        }
        
        // Update HEAD to point to the branch
        let headPath = repoURL.appendingPathComponent(".git/HEAD")
        try "ref: refs/heads/\(branch)\n".write(to: headPath, atomically: true, encoding: .utf8)
        
        // Update the working tree via SSH if connected
        let ssh = SSHManager.shared
        if ssh.isConnected, let dir = workingDirectory?.path {
            let result = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git checkout '\(branch.shellEscaped)'", timeout: 60)
            if result.exitCode != 0 {
                throw GitManagerError.commandFailed(
                    args: "checkout \(branch)",
                    exitCode: result.exitCode,
                    message: result.stderr
                )
            }
        } else {
            // No SSH — HEAD is updated but working tree is not.
            // Post a warning so the user knows a full checkout requires SSH.
            AppLogger.git.warning("[GitManager] checkout: SSH not connected — HEAD updated but working tree may be stale. Connect SSH for full checkout.")
        }
        
        currentBranch = branch
        await refresh()
    }
    
    func createBranch(name: String) async throws {
        guard let repoURL = workingDirectory,
              let reader = nativeReader,
              let headSHA = reader.headSHA() else {
            throw GitManagerError.invalidRepository
        }
        
        // Validate branch name using full git-check-ref-format rules
        guard isValidBranchName(name) else {
            throw GitManagerError.commandFailed(args: "branch", exitCode: 1, message: "Invalid branch name")
        }
        
        // Create branch ref file
        let refPath = repoURL.appendingPathComponent(".git/refs/heads/\(name)")
        try headSHA.write(to: refPath, atomically: true, encoding: .utf8)
        
        await refresh()
    }
    
    func deleteBranch(name: String) async throws {
        guard let repoURL = workingDirectory else {
            throw GitManagerError.noRepository
        }
        
        // Can't delete current branch
        guard name != currentBranch else {
            throw GitManagerError.invalidRepository
        }
        
        // Validate branch name to prevent path traversal
        guard !name.contains("..") && !name.contains("/") else {
            throw GitManagerError.commandFailed(args: "branch -d", exitCode: 1, message: "Invalid branch name")
        }
        
        let refPath = repoURL.appendingPathComponent(".git/refs/heads/\(name)")
        try FileManager.default.removeItem(at: refPath)
        
        await refresh()
    }
    
    // MARK: - Remote Operations (SSH-aware)
    
    func pull() async throws {
        // Prefer SSH when available and a working directory is configured
        let ssh = SSHManager.shared
        if ssh.isConnected, let dir = workingDirectory?.path {
            // Step 1: Fetch from remote
            let fetchResult = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git fetch", timeout: 60)
            if fetchResult.exitCode != 0 {
                throw GitManagerError.commandFailed(
                    args: "fetch",
                    exitCode: fetchResult.exitCode,
                    message: fetchResult.stderr
                )
            }
            
            // Step 2: Merge the tracking branch into current branch
            let branch = currentBranch
            guard !branch.isEmpty else {
                throw GitManagerError.invalidRepository
            }
            let mergeResult = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git merge 'origin/\(branch.shellEscaped)'", timeout: 60)
            if mergeResult.exitCode != 0 {
                // Check whether the failure is due to merge conflicts.
                let combinedOutput = mergeResult.stdout + "\n" + mergeResult.stderr
                if combinedOutput.contains("CONFLICT") || combinedOutput.contains("Automatic merge failed") {
                    let conflictedFiles = parseConflictedFiles(from: combinedOutput)
                    mergeConflicts = conflictedFiles
                    // Notify the UI so it can present a conflict-resolution dialog.
                    NotificationCenter.default.post(
                        name: .gitMergeConflictsDetected,
                        object: self,
                        userInfo: ["conflictedFiles": conflictedFiles]
                    )
                    await refresh()
                    return
                }
                throw GitManagerError.commandFailed(
                    args: "merge origin/\(branch)",
                    exitCode: mergeResult.exitCode,
                    message: mergeResult.stderr
                )
            }
            
            await refresh()
            return
        }
        
        // HTTPS fallback: fetch + fast-forward merge
        try await fetchViaHTTPS()
        
        // After fetch, try fast-forward merge with remote tracking branch
        guard let repoURL = workingDirectory else { throw GitManagerError.noRepository }
        let gitDir = repoURL.appendingPathComponent(".git")
        let branch = currentBranch
        guard !branch.isEmpty else { throw GitManagerError.invalidRepository }
        
        let remoteRefPath = gitDir.appendingPathComponent("refs/remotes/origin/\(branch)")
        guard FileManager.default.fileExists(atPath: remoteRefPath.path),
              let remoteSHA = try? String(contentsOf: remoteRefPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines) else {
            // No remote tracking branch - fetch was enough
            return
        }
        
        let localRefPath = gitDir.appendingPathComponent("refs/heads/\(branch)")
        let localSHA = (try? String(contentsOf: localRefPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)) ?? ""
        
        guard remoteSHA != localSHA else {
            // Already up to date
            return
        }
        
        // Fast-forward: update local ref to remote SHA and re-checkout
        try (remoteSHA + "\n").write(to: localRefPath, atomically: true, encoding: .utf8)
        let _ = try checkoutWorkingTree(gitDir: gitDir, to: repoURL)
        await refresh()
    }
    
    func push() async throws {
        // Prefer SSH when available and a working directory is configured
        let ssh = SSHManager.shared
        if ssh.isConnected, let dir = workingDirectory?.path {
            let branch = currentBranch
            guard !branch.isEmpty else {
                throw GitManagerError.invalidRepository
            }
            // Push current branch to origin with explicit branch name
            let result = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git push origin '\(branch.shellEscaped)'", timeout: 60)
            if result.exitCode != 0 {
                throw GitManagerError.commandFailed(
                    args: "push origin \(branch)",
                    exitCode: result.exitCode,
                    message: result.stderr
                )
            }
            await refresh()
            return
        }
        
        // HTTPS push via git-receive-pack smart protocol
        try await pushViaHTTPS()
    }
    
    func stashPush(message: String?) async throws {
        let ssh = SSHManager.shared
        if ssh.isConnected, let dir = workingDirectory?.path {
            let msg = (message ?? "Stash from CodePad").shellEscaped
            let result = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git stash push -m '\(msg)'")
            if result.exitCode != 0 {
                throw GitManagerError.commandFailed(args: "stash push", exitCode: result.exitCode, message: result.stderr)
            }
            await refresh()
            return
        }
        throw GitManagerError.notAvailableOnIOS
    }
    
    func stashPop(index: Int) async throws {
        guard index >= 0 else {
            throw GitManagerError.invalidRepository
        }
        let ssh = SSHManager.shared
        if ssh.isConnected, let dir = workingDirectory?.path {
            let result = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git stash pop stash@{\(index)}")
            if result.exitCode != 0 {
                throw GitManagerError.commandFailed(args: "stash pop", exitCode: result.exitCode, message: result.stderr)
            }
            await refresh()
            return
        }
        throw GitManagerError.notAvailableOnIOS
    }
    
    func stashDrop(index: Int) async throws {
        guard index >= 0 else {
            throw GitManagerError.invalidRepository
        }
        let ssh = SSHManager.shared
        if ssh.isConnected, let dir = workingDirectory?.path {
            let result = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git stash drop stash@{\(index)}")
            if result.exitCode != 0 {
                throw GitManagerError.commandFailed(args: "stash drop", exitCode: result.exitCode, message: result.stderr)
            }
            await refresh()
            return
        }
        throw GitManagerError.notAvailableOnIOS
    }
    
    func discard(file: String) async throws {
        try discardFileWithoutRefresh(file: file)
        await refresh()
    }
    
    private func discardFileWithoutRefresh(file: String) throws {
        // Discard changes by restoring from HEAD
        guard let repoURL = workingDirectory,
              let reader = nativeReader else {
            throw GitManagerError.invalidRepository
        }
        
        // Get file content from HEAD
        if let headSHA = reader.headSHA(),
           let content = reader.fileContentsString(atPath: file, commitSHA: headSHA) {
            let filePath = repoURL.appendingPathComponent(file)
            try content.write(to: filePath, atomically: true, encoding: .utf8)
        } else {
            // File doesn't exist in HEAD - delete it
            let filePath = repoURL.appendingPathComponent(file)
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                AppLogger.git.warning("[GitManager] discardFileWithoutRefresh: failed to delete untracked file '\(file)': \(error)")
            }
        }
    }
    
    func discardAll() async throws {
        // Discard all unstaged changes using the no-refresh helper,
        // then refresh once at the end.
        for change in unstagedChanges {
            try discardFileWithoutRefresh(file: change.path)
        }
        for file in untrackedFiles {
            guard let repoURL = workingDirectory else { continue }
            let filePath = repoURL.appendingPathComponent(file.path)
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                AppLogger.git.warning("[GitManager] discardAll: failed to delete untracked file '\(file.path)': \(error)")
            }
        }
        await refresh()
    }
    
    func discardChanges(file: String) async throws {
        try await discard(file: file)
    }
    
    func fetch() async throws {
        let ssh = SSHManager.shared
        if ssh.isConnected, let dir = workingDirectory?.path {
            let result = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git fetch", timeout: 60)
            if result.exitCode != 0 {
                throw GitManagerError.commandFailed(
                    args: "fetch",
                    exitCode: result.exitCode,
                    message: result.stderr
                )
            }
            await refresh()
            return
        }
        
        // HTTPS fallback: use Smart HTTP protocol
        try await fetchViaHTTPS()
    }
    
    /// Fetch updates from remote using Smart HTTP protocol (no SSH needed)
    private func fetchViaHTTPS() async throws {
        guard let repoURL = workingDirectory else {
            throw GitManagerError.noRepository
        }
        
        // Read remote URL from .git/config
        guard let remoteURL = try await getConfig(key: "remote.origin.url") else {
            throw GitManagerError.commandFailed(args: "fetch", exitCode: 1, message: "No remote 'origin' configured")
        }
        
        let baseURL = remoteURL.hasSuffix(".git") ? remoteURL : remoteURL + ".git"
        
        // Read stored auth token if available
        let authToken = try await getConfig(key: "http.token")
        
        // 1. Discover remote refs
        let remoteRefs = try await discoverRefs(baseURL: baseURL, authToken: authToken)
        guard !remoteRefs.isEmpty else { return }
        
        // 2. Read local refs to find what we already have
        let gitDir = repoURL.appendingPathComponent(".git")
        // NativeGitReader available if needed for object lookups
        var localSHAs = Set<String>()
        
        // Collect all known object SHAs from local refs
        let refsDir = gitDir.appendingPathComponent("refs")
        if let enumerator = FileManager.default.enumerator(at: refsDir, includingPropertiesForKeys: nil) {
            while let fileURL = enumerator.nextObject() as? URL {
                if let sha = try? String(contentsOf: fileURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines),
                   sha.count == 40, sha.allSatisfy({ $0.isHexDigit }) {
                    localSHAs.insert(sha)
                }
            }
        }
        
        // 3. Determine which remote refs we need
        let wantSHAs = remoteRefs
            .filter { $0.sha.count == 40 && !localSHAs.contains($0.sha) }
            .map { $0.sha }
        let uniqueWants = Array(Set(wantSHAs))
        
        guard !uniqueWants.isEmpty else {
            // Already up to date - just update remote tracking refs
            for ref in remoteRefs where ref.name.hasPrefix("refs/heads/") {
                let remoteName = ref.name.replacingOccurrences(of: "refs/heads/", with: "refs/remotes/origin/")
                let refPath = gitDir.appendingPathComponent(remoteName)
                try FileManager.default.createDirectory(at: refPath.deletingLastPathComponent(), withIntermediateDirectories: true)
                try (ref.sha + "\n").write(to: refPath, atomically: true, encoding: .utf8)
            }
            await refresh()
            return
        }
        
        // 4. Fetch pack file with objects we need
        let haveSHAs = Array(localSHAs)
        let packData = try await fetchPackFileWithHaves(baseURL: baseURL, wants: uniqueWants, haves: haveSHAs, authToken: authToken)
        
        // 5. Parse and write objects
        let objectCount = try parseAndWritePackFile(packData: packData, gitDir: gitDir)
        AppLogger.git.info("HTTPS fetch: unpacked \(objectCount) objects")
        
        // 6. Update remote tracking refs
        for ref in remoteRefs where ref.name.hasPrefix("refs/heads/") {
            let remoteName = ref.name.replacingOccurrences(of: "refs/heads/", with: "refs/remotes/origin/")
            let refPath = gitDir.appendingPathComponent(remoteName)
            try FileManager.default.createDirectory(at: refPath.deletingLastPathComponent(), withIntermediateDirectories: true)
            try (ref.sha + "\n").write(to: refPath, atomically: true, encoding: .utf8)
        }
        
        await refresh()
    }
    
    /// Push local commits to remote via HTTPS git-receive-pack
    private func pushViaHTTPS() async throws {
        guard let repoURL = workingDirectory else {
            throw GitManagerError.noRepository
        }
        
        guard let remoteURL = try await getConfig(key: "remote.origin.url") else {
            throw GitManagerError.commandFailed(args: "push", exitCode: 1, message: "No remote 'origin' configured")
        }
        
        let baseURL = remoteURL.hasSuffix(".git") ? remoteURL : remoteURL + ".git"
        let authToken = try await getConfig(key: "http.token")
        
        guard authToken != nil else {
            throw GitManagerError.commandFailed(
                args: "push",
                exitCode: 1,
                message: "HTTPS push requires an auth token. Set it in .git/config under [http] token = <your-token>, or connect via SSH."
            )
        }
        
        let gitDir = repoURL.appendingPathComponent(".git")
        let branch = currentBranch
        guard !branch.isEmpty else { throw GitManagerError.invalidRepository }
        
        // 1. Read local HEAD SHA
        let localRefPath = gitDir.appendingPathComponent("refs/heads/\(branch)")
        guard let localSHA = try? String(contentsOf: localRefPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines),
              localSHA.count == 40 else {
            throw GitManagerError.invalidRepository
        }
        
        // 2. Discover remote refs to find remote HEAD for this branch
        let remoteRefs = try await discoverReceivePackRefs(baseURL: baseURL, authToken: authToken)
        let remoteBranchRef = "refs/heads/\(branch)"
        let remoteSHA = remoteRefs.first(where: { $0.name == remoteBranchRef })?.sha ?? String(repeating: "0", count: 40)
        
        guard remoteSHA != localSHA else {
            AppLogger.git.info("HTTPS push: already up to date")
            return
        }
        
        // 3. Collect objects to send (walk from local HEAD to remote SHA)
        guard let reader = NativeGitReader(repositoryURL: repoURL) else {
            throw GitManagerError.invalidRepository
        }
        let objectSHAs = collectObjectsForPush(reader: reader, localSHA: localSHA, remoteSHA: remoteSHA)
        
        guard !objectSHAs.isEmpty else {
            AppLogger.git.info("HTTPS push: no new objects to send")
            return
        }
        
        // 4. Build pack file
        let packData = try buildPackFile(reader: reader, objectSHAs: objectSHAs)
        AppLogger.git.info("HTTPS push: built pack with \(objectSHAs.count) objects (\(packData.count) bytes)")
        
        // 5. Send via git-receive-pack
        try await sendReceivePack(
            baseURL: baseURL,
            authToken: authToken,
            oldSHA: remoteSHA,
            newSHA: localSHA,
            refName: remoteBranchRef,
            packData: packData
        )
        
        // 6. Update remote tracking ref
        let remoteRefPath = gitDir.appendingPathComponent("refs/remotes/origin/\(branch)")
        try FileManager.default.createDirectory(at: remoteRefPath.deletingLastPathComponent(), withIntermediateDirectories: true)
        try (localSHA + "\n").write(to: remoteRefPath, atomically: true, encoding: .utf8)
        
        await refresh()
        AppLogger.git.info("HTTPS push: successfully pushed \(branch) to origin")
    }
    
    /// Discover refs from git-receive-pack endpoint (for push)
    private func discoverReceivePackRefs(baseURL: String, authToken: String?) async throws -> [GitRef] {
        guard let url = URL(string: "\(baseURL)/info/refs?service=git-receive-pack") else {
            throw GitManagerError.cloneFailed("Invalid receive-pack refs URL")
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw GitManagerError.commandFailed(args: "push", exitCode: 1, message: "Authentication failed. Check your auth token.")
            }
            if httpResponse.statusCode != 200 {
                throw GitManagerError.commandFailed(args: "push", exitCode: 1, message: "Server returned \(httpResponse.statusCode)")
            }
        }
        
        guard let text = String(data: data, encoding: .utf8) else {
            throw GitManagerError.cloneFailed("Invalid response encoding")
        }
        
        return parseSmartHTTPRefs(text)
    }
    
    /// Walk commit graph from localSHA backwards, collecting all objects until we hit remoteSHA
    private func collectObjectsForPush(reader: NativeGitReader, localSHA: String, remoteSHA: String) -> [String] {
        var objectSHAs = Set<String>()
        var commitQueue = [localSHA]
        var visitedCommits = Set<String>()
        let zeroSHA = String(repeating: "0", count: 40)
        
        while !commitQueue.isEmpty {
            let sha = commitQueue.removeFirst()
            guard !visitedCommits.contains(sha), sha != remoteSHA, sha != zeroSHA else { continue }
            visitedCommits.insert(sha)
            
            guard let obj = reader.readObject(sha: sha) else { continue }
            objectSHAs.insert(sha)
            
            if obj.type == .commit {
                // Parse commit to get tree and parents
                if let content = String(data: obj.data, encoding: .utf8) {
                    for line in content.components(separatedBy: "\n") {
                        if line.hasPrefix("tree ") {
                            let treeSHA = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                            collectTreeObjects(reader: reader, sha: treeSHA, into: &objectSHAs)
                        } else if line.hasPrefix("parent ") {
                            let parentSHA = String(line.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                            if parentSHA != remoteSHA && parentSHA != zeroSHA {
                                commitQueue.append(parentSHA)
                            }
                        } else if line.isEmpty {
                            break // End of header
                        }
                    }
                }
            }
        }
        
        return Array(objectSHAs)
    }
    
    /// Recursively collect all tree and blob objects
    private func collectTreeObjects(reader: NativeGitReader, sha: String, into objects: inout Set<String>) {
        guard !objects.contains(sha) else { return }
        guard let obj = reader.readObject(sha: sha) else { return }
        objects.insert(sha)
        
        if obj.type == .tree {
            // Parse tree entries
            var offset = 0
            let data = obj.data
            while offset < data.count {
                // Format: <mode> <name>\0<20-byte-sha>
                guard let nullIndex = data[offset...].firstIndex(of: 0) else { break }
                let entryEnd = nullIndex + 21 // 20 bytes SHA + 1 for null
                guard entryEnd <= data.count else { break }
                
                let shaBytes = data[(nullIndex + 1)..<(nullIndex + 21)]
                let entrySHA = shaBytes.map { String(format: "%02x", $0) }.joined()
                
                // Check if it's a subtree (mode starts with '4' for 40000)
                let modeStr = String(data: data[offset..<nullIndex], encoding: .ascii) ?? ""
                if modeStr.hasPrefix("40") {
                    collectTreeObjects(reader: reader, sha: entrySHA, into: &objects)
                } else {
                    objects.insert(entrySHA)
                }
                
                offset = entryEnd
            }
        }
    }
    
    /// Build a minimal pack file from a list of object SHAs
    private func buildPackFile(reader: NativeGitReader, objectSHAs: [String]) throws -> Data {
        var pack = Data()
        
        // Pack header: PACK + version 2 + object count
        pack.append(contentsOf: [0x50, 0x41, 0x43, 0x4b]) // "PACK"
        pack.append(contentsOf: withUnsafeBytes(of: UInt32(2).bigEndian) { Array($0) }) // version 2
        pack.append(contentsOf: withUnsafeBytes(of: UInt32(objectSHAs.count).bigEndian) { Array($0) }) // count
        
        let typeMap: [String: UInt8] = ["commit": 1, "tree": 2, "blob": 3, "tag": 4]
        
        for sha in objectSHAs {
            guard let obj = reader.readObject(sha: sha) else {
                throw GitManagerError.commandFailed(args: "push", exitCode: 1, message: "Cannot read object \(sha)")
            }
            
            let typeNum = typeMap[obj.type.rawValue] ?? 3 // default to blob
            let rawData = obj.data
            
            // Compress the data
            let compressedData = try compressDeflate(rawData)
            
            // Encode type+size header (variable-length encoding)
            let size = rawData.count
            var header = Data()
            var firstByte = (typeNum << 4) | UInt8(size & 0x0F)
            var remaining = size >> 4
            if remaining > 0 {
                firstByte |= 0x80
            }
            header.append(firstByte)
            while remaining > 0 {
                var byte = UInt8(remaining & 0x7F)
                remaining >>= 7
                if remaining > 0 {
                    byte |= 0x80
                }
                header.append(byte)
            }
            
            pack.append(header)
            pack.append(compressedData)
        }
        
        // Append SHA-1 checksum of the pack
        var sha1 = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        pack.withUnsafeBytes { ptr in
            _ = CC_SHA1(ptr.baseAddress, CC_LONG(pack.count), &sha1)
        }
        pack.append(contentsOf: sha1)
        
        return pack
    }
    
    /// Compress data with zlib deflate
    private func compressDeflate(_ data: Data) throws -> Data {
        let sourceSize = data.count
        let destinationSize = sourceSize + sourceSize / 10 + 12 + 256
        var destinationBuffer = Data(count: destinationSize)
        
        let compressedSize = data.withUnsafeBytes { sourcePtr -> Int in
            destinationBuffer.withUnsafeMutableBytes { destPtr -> Int in
                let result = compression_encode_buffer(
                    destPtr.bindMemory(to: UInt8.self).baseAddress!,
                    destinationSize,
                    sourcePtr.bindMemory(to: UInt8.self).baseAddress!,
                    sourceSize,
                    nil,
                    COMPRESSION_ZLIB
                )
                return result
            }
        }
        
        guard compressedSize > 0 else {
            throw GitManagerError.commandFailed(args: "push", exitCode: 1, message: "Failed to compress object")
        }
        
        return destinationBuffer.prefix(compressedSize)
    }
    
    /// Send pack data to git-receive-pack endpoint
    private func sendReceivePack(
        baseURL: String,
        authToken: String?,
        oldSHA: String,
        newSHA: String,
        refName: String,
        packData: Data
    ) async throws {
        guard let url = URL(string: "\(baseURL)/git-receive-pack") else {
            throw GitManagerError.cloneFailed("Invalid receive-pack URL")
        }
        
        // Build pkt-line body: <old-sha> <new-sha> <ref-name>\0<capabilities>\n + 0000 + pack data
        var body = Data()
        
        let refLine = "\(oldSHA) \(newSHA) \(refName)\0 report-status side-band-64k\n"
        let pktLen = String(format: "%04x", refLine.utf8.count + 4)
        body.append(Data((pktLen + refLine).utf8))
        body.append(Data("0000".utf8)) // flush
        body.append(packData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-git-receive-pack-request", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw GitManagerError.commandFailed(args: "push", exitCode: 1, message: "Push authentication failed. Check your auth token.")
            }
            if httpResponse.statusCode != 200 {
                let responseText = String(data: responseData, encoding: .utf8) ?? "Unknown error"
                throw GitManagerError.commandFailed(args: "push", exitCode: 1, message: "Push failed (\(httpResponse.statusCode)): \(responseText)")
            }
        }
        
        // Parse response to check for errors
        if let responseText = String(data: responseData, encoding: .utf8) {
            if responseText.contains("ng ") || responseText.contains("error") {
                // Extract error message
                let lines = responseText.components(separatedBy: "\n")
                let errorLines = lines.filter { $0.contains("ng ") || $0.contains("error") }
                let errorMsg = errorLines.joined(separator: "; ")
                throw GitManagerError.commandFailed(args: "push", exitCode: 1, message: "Remote rejected push: \(errorMsg)")
            }
        }
        
        AppLogger.git.info("HTTPS push: git-receive-pack completed successfully")
    }
    
    /// Fetch pack file with have/want negotiation
    private func fetchPackFileWithHaves(baseURL: String, wants: [String], haves: [String], authToken: String? = nil) async throws -> Data {
        guard let url = URL(string: "\(baseURL)/git-upload-pack") else {
            throw GitManagerError.cloneFailed("Invalid upload-pack URL")
        }
        
        var body = ""
        for (i, sha) in wants.enumerated() {
            if i == 0 {
                let line = "want \(sha) multi_ack_detailed no-done side-band-64k thin-pack ofs-delta agent=codepad/1.0\n"
                body += String(format: "%04x", line.utf8.count + 4) + line
            } else {
                let line = "want \(sha)\n"
                body += String(format: "%04x", line.utf8.count + 4) + line
            }
        }
        body += "00000009done\n"
        
        // Add haves if we have local objects
        if !haves.isEmpty {
            body = ""
            for (i, sha) in wants.enumerated() {
                if i == 0 {
                    let line = "want \(sha) multi_ack_detailed no-done side-band-64k thin-pack ofs-delta agent=codepad/1.0\n"
                    body += String(format: "%04x", line.utf8.count + 4) + line
                } else {
                    let line = "want \(sha)\n"
                    body += String(format: "%04x", line.utf8.count + 4) + line
                }
            }
            body += "0000"
            for sha in haves.prefix(256) { // Limit haves to avoid huge requests
                let line = "have \(sha)\n"
                body += String(format: "%04x", line.utf8.count + 4) + line
            }
            body += "0009done\n"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-git-upload-pack-request", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw GitManagerError.cloneFailed("Fetch failed: server returned \(httpResponse.statusCode)")
        }
        
        return extractPackFromSideBand(data)
    }
    

    // MARK: - Git Config
    
    /// Read a git config value by key (e.g., "user.name", "user.email")
    func getConfig(key: String) async throws -> String? {
        // Try reading from .git/config first
        guard let gitDir = workingDirectory else { return nil }
        let configPath = gitDir.appendingPathComponent(".git/config")
        
        guard FileManager.default.fileExists(atPath: configPath.path) else { return nil }
        let content = try String(contentsOf: configPath, encoding: .utf8)
        
        // Parse INI-style config
        let parts = key.split(separator: ".")
        guard parts.count == 2 else { return nil }
        let section = String(parts[0])  // e.g., "user"
        let keyName = String(parts[1])  // e.g., "name"
        
        var inSection = false
        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("[") {
                inSection = trimmed.lowercased().hasPrefix("[\(section)]")
                    || trimmed.lowercased().hasPrefix("[\(section) ")
                continue
            }
            if inSection {
                let kv = trimmed.split(separator: "=", maxSplits: 1)
                if kv.count == 2 {
                    let k = kv[0].trimmingCharacters(in: .whitespaces).lowercased()
                    let v = kv[1].trimmingCharacters(in: .whitespaces)
                    if k == keyName.lowercased() {
                        return v
                    }
                }
            }
        }
        
        // Fallback: try SSH if connected
        let ssh = SSHManager.shared
        if ssh.isConnected, let dir = workingDirectory?.path {
            guard isValidGitConfigKey(key) else { return nil }
            let result = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git config '\(key.shellEscaped)'", timeout: 10)
            if result.exitCode == 0 {
                let value = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                return value.isEmpty ? nil : value
            }
        }
        
        return nil
    }
    
    /// Set a git config value by key
    func setConfig(key: String, value: String) async throws {
        // Try SSH first for real git config
        let ssh = SSHManager.shared
        if ssh.isConnected, let dir = workingDirectory?.path {
            guard isValidGitConfigKey(key) else {
                throw GitManagerError.commandFailed(args: "config", exitCode: 1, message: "Invalid config key: only alphanumeric, dots, and dashes allowed")
            }
            let result = try await ssh.executeCommand("cd '\(dir.shellEscaped)' && git config '\(key.shellEscaped)' '\(value.shellEscaped)'", timeout: 10)
            if result.exitCode != 0 {
                throw GitManagerError.commandFailed(args: "config \(key)", exitCode: result.exitCode, message: result.stderr)
            }
            return
        }
        
        // Fallback: write to .git/config directly
        guard let gitDir = workingDirectory else {
            throw GitManagerError.noRepository
        }
        let configPath = gitDir.appendingPathComponent(".git/config")
        
        let parts = key.split(separator: ".")
        guard parts.count == 2 else {
            throw GitManagerError.commandFailed(args: "config", exitCode: 1, message: "Invalid config key format: \(key)")
        }
        let section = String(parts[0])
        let keyName = String(parts[1])
        var content: String
        if FileManager.default.fileExists(atPath: configPath.path) {
            do {
                content = try String(contentsOf: configPath, encoding: .utf8)
            } catch {
                throw GitManagerError.commandFailed(args: "config", exitCode: 1, message: "Failed to read .git/config: \(error.localizedDescription)")
            }
        } else {
            content = ""
        }
        
        // Check if section exists
        let sectionHeader = "[\(section)]"
        if content.contains(sectionHeader) {
            // Find and replace or append within section
            var lines = content.components(separatedBy: .newlines)
            var inSection = false
            var replaced = false
            for i in lines.indices {
                let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("[") {
                    if inSection && !replaced {
                        // Insert before next section
                        lines.insert("\t\(keyName) = \(value)", at: i)
                        replaced = true
                        break
                    }
                    inSection = trimmed.lowercased() == sectionHeader.lowercased()
                    continue
                }
                if inSection {
                    let kv = trimmed.split(separator: "=", maxSplits: 1)
                    if kv.count >= 1 && kv[0].trimmingCharacters(in: .whitespaces).lowercased() == keyName.lowercased() {
                        lines[i] = "\t\(keyName) = \(value)"
                        replaced = true
                        break
                    }
                }
            }
            if !replaced {
                // Append at end of section or file
                if let sectionIdx = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces).lowercased() == sectionHeader.lowercased() }) {
                    lines.insert("\t\(keyName) = \(value)", at: sectionIdx + 1)
                }
            }
            content = lines.joined(separator: "\n")
        } else {
            // Add new section
            content += "\n\(sectionHeader)\n\t\(keyName) = \(value)\n"
        }
        
        try content.write(to: configPath, atomically: true, encoding: .utf8)
    }
    
    /// Alias for lastError for compatibility
    var error: String? {
        return lastError
    }
    
    // MARK: - Validation Helpers
    
    /// Validate a git config key contains only safe characters (alphanumeric, dots, dashes, underscores).
    private func isValidGitConfigKey(_ key: String) -> Bool {
        guard !key.isEmpty else { return false }
        // Git config keys are in the format section.key or section.subsection.key
        // Only allow: letters, digits, dots, dashes, underscores
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".-_"))
        return key.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
    
    /// Validate a git branch name according to git-check-ref-format rules.
    private func isValidBranchName(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        // Reject dangerous characters and patterns
        let forbidden: [String] = ["..", "~", "^", ":", "\\", " ", "\t", "\n", "\r", "\0", "@{", "??", "*"]
        for pattern in forbidden {
            if name.contains(pattern) { return false }
        }
        // Must not start or end with dot, slash, or dash
        if name.hasPrefix(".") || name.hasSuffix(".") { return false }
        if name.hasPrefix("/") || name.hasSuffix("/") { return false }
        if name.hasPrefix("-") { return false }
        // Must not contain consecutive slashes
        if name.contains("//") { return false }
        // Must not end with .lock
        if name.hasSuffix(".lock") { return false }
        // Must not contain control characters
        for scalar in name.unicodeScalars {
            if scalar.value < 0x20 || scalar.value == 0x7F { return false }
        }
        return true
    }
    
    // MARK: - Merge Conflict Resolution
    
    /// Parse conflicted file paths from `git merge` / `git pull` output.
    ///
    /// Git reports conflicts in the form:
    /// ```
    /// CONFLICT (content): Merge conflict in path/to/file.swift
    /// CONFLICT (modify/delete): path/to/other.swift deleted in theirs
    /// ```
    private func parseConflictedFiles(from output: String) -> [String] {
        var files: [String] = []
        for line in output.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("CONFLICT") else { continue }
            // Format: "CONFLICT (<type>): <details> in <path>" or
            //         "CONFLICT (<type>): <path> <action>"
            // Try to extract the path after the last " in " if present.
            if let inRange = trimmed.range(of: " in ", options: .backwards) {
                let path = String(trimmed[inRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                if !path.isEmpty {
                    files.append(path)
                }
            } else {
                // Fallback: take everything after the closing paren + ": "
                if let parenClose = trimmed.range(of: "):") {
                    let remainder = String(trimmed[parenClose.upperBound...])
                        .trimmingCharacters(in: .whitespaces)
                    // Extract just the first token (the path)
                    let path = remainder.components(separatedBy: .whitespaces).first ?? remainder
                    if !path.isEmpty {
                        files.append(path)
                    }
                }
            }
        }
        return files
    }

    /// Resolve a merge conflict for the given file.
    ///
    /// - Parameters:
    ///   - file: Path of the conflicted file relative to the repository root.
    ///   - resolution: Strategy to apply (`ours`, `theirs`, or `manual`).
    ///
    /// For `manual` resolution the method does **not** modify the file;
    /// it posts an `.openFile` notification so the UI can open the file
    /// in the editor for the user to resolve conflict markers by hand.
    func resolveConflict(file: String, resolution: MergeConflictResolution) async throws {
        guard let dir = workingDirectory?.path else {
            throw GitManagerError.noRepository
        }

        let ssh = SSHManager.shared

        switch resolution {
        case .ours:
            guard ssh.isConnected else {
                throw GitManagerError.sshNotConnected
            }
            let result = try await ssh.executeCommand(
                "cd '\(dir.shellEscaped)' && git checkout --ours '\(file.shellEscaped)'",
                timeout: 30
            )
            guard result.exitCode == 0 else {
                throw GitManagerError.commandFailed(
                    args: "checkout --ours \(file)",
                    exitCode: result.exitCode,
                    message: result.stderr
                )
            }
            // Stage the resolved file so git knows the conflict is resolved.
            let stageResult = try await ssh.executeCommand(
                "cd '\(dir.shellEscaped)' && git add '\(file.shellEscaped)'",
                timeout: 30
            )
            _ = stageResult // staging failure is non-critical

        case .theirs:
            guard ssh.isConnected else {
                throw GitManagerError.sshNotConnected
            }
            let result = try await ssh.executeCommand(
                "cd '\(dir.shellEscaped)' && git checkout --theirs '\(file.shellEscaped)'",
                timeout: 30
            )
            guard result.exitCode == 0 else {
                throw GitManagerError.commandFailed(
                    args: "checkout --theirs \(file)",
                    exitCode: result.exitCode,
                    message: result.stderr
                )
            }
            let stageResult = try await ssh.executeCommand(
                "cd '\(dir.shellEscaped)' && git add '\(file.shellEscaped)'",
                timeout: 30
            )
            _ = stageResult

        case .manual:
            // Open the file in the editor for the user to resolve conflict markers.
            NotificationCenter.default.post(
                name: .openFile,
                object: nil,
                userInfo: ["path": file]
            )
            return
        }

        // Remove the file from the tracked conflict list.
        mergeConflicts.removeAll { $0 == file }
        await refresh()
    }
    
    // MARK: - Clone Repository (HTTPS Smart Protocol)
    
    /// Clone a git repository via HTTPS smart protocol.
    /// - Parameters:
    ///   - url: The repository URL (HTTPS)
    ///   - destination: Local directory to clone into
    ///   - branch: Optional branch name (defaults to remote HEAD)
    ///   - authToken: Optional auth token for private repos
    ///   - progress: Callback for progress messages
    func cloneRepository(
        url: String,
        to destination: URL,
        branch: String? = nil,
        authToken: String? = nil,
        progress: ((String) -> Void)? = nil
    ) async throws {
        progress?("Initializing clone...")
        
        // Normalize URL for smart HTTP
        let baseURL = url.hasSuffix(".git") ? url : url + ".git"
        
        guard let _ = URL(string: baseURL) else {
            throw GitManagerError.cloneFailed("Invalid URL: \(url)")
        }
        
        // 1. Discover refs via smart HTTP protocol
        progress?("Discovering refs...")
        let refs = try await discoverRefs(baseURL: baseURL, authToken: authToken)
        
        guard !refs.isEmpty else {
            throw GitManagerError.cloneFailed("No refs found at \(url)")
        }
        
        // Find default branch from symref or first refs/heads
        let symrefHead = refs.first { $0.isSymref }?.symrefTarget
        let defaultBranch: String
        if let branch = branch {
            defaultBranch = branch
        } else if let symTarget = symrefHead {
            defaultBranch = symTarget.replacingOccurrences(of: "refs/heads/", with: "")
        } else {
            defaultBranch = refs.first { $0.name.hasPrefix("refs/heads/") }?.name
                .replacingOccurrences(of: "refs/heads/", with: "") ?? "main"
        }
        
        // 2. Create .git directory structure
        progress?("Creating repository structure...")
        let gitDir = destination.appendingPathComponent(".git")
        try createGitDirectoryStructure(at: gitDir)
        
        // 3. Collect SHAs to fetch
        let wantSHAs = Array(Set(refs.filter { $0.sha.count == 40 }.map { $0.sha }))
        guard !wantSHAs.isEmpty else {
            throw GitManagerError.cloneFailed("No valid object SHAs found")
        }
        
        // 4. Fetch pack file
        progress?("Downloading objects (\(wantSHAs.count) refs)...")
        let packData = try await fetchPackFile(baseURL: baseURL, wants: wantSHAs, authToken: authToken)
        
        // 5. Parse pack file and write objects
        progress?("Unpacking objects...")
        let objectCount = try parseAndWritePackFile(packData: packData, gitDir: gitDir)
        progress?("Unpacked \(objectCount) objects")
        
        // 6. Write refs
        progress?("Writing refs...")
        for ref in refs where ref.name.hasPrefix("refs/") {
            // Write remote tracking refs
            let remoteName = ref.name.hasPrefix("refs/heads/")
                ? ref.name.replacingOccurrences(of: "refs/heads/", with: "refs/remotes/origin/")
                : ref.name
            let refPath = gitDir.appendingPathComponent(remoteName)
            try FileManager.default.createDirectory(
                at: refPath.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try (ref.sha + "\n").write(to: refPath, atomically: true, encoding: .utf8)
        }
        
        // Also write local branch ref
        let headBranchRef = refs.first { $0.name == "refs/heads/\(defaultBranch)" }
        if let headRef = headBranchRef {
            let localRef = gitDir.appendingPathComponent("refs/heads/\(defaultBranch)")
            try FileManager.default.createDirectory(
                at: localRef.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try (headRef.sha + "\n").write(to: localRef, atomically: true, encoding: .utf8)
        }
        
        // 7. Write HEAD
        try "ref: refs/heads/\(defaultBranch)\n".write(
            to: gitDir.appendingPathComponent("HEAD"),
            atomically: true,
            encoding: .utf8
        )
        
        // 8. Write config
        progress?("Writing config...")
        let config = """
        [core]
            repositoryformatversion = 0
            filemode = false
            bare = false
            logallrefupdates = true
        [remote "origin"]
            url = \(url)
            fetch = +refs/heads/*:refs/remotes/origin/*
        [branch "\(defaultBranch)"]
            remote = origin
            merge = refs/heads/\(defaultBranch)
        """
        try config.write(to: gitDir.appendingPathComponent("config"), atomically: true, encoding: .utf8)
        
        // 9. Checkout working tree
        progress?("Checking out files...")
        let fileCount = try checkoutWorkingTree(gitDir: gitDir, to: destination)
        progress?("Checked out \(fileCount) files")
        
        progress?("Clone complete!")
    }
    
    // MARK: - Remote Branch Discovery
    
    /// Discover remote branches from an HTTPS git URL.
    /// Returns a tuple of (branch names, default branch name).
    func discoverRemoteBranches(url: String, authToken: String? = nil) async throws -> ([String], String) {
        let baseURL = url.hasSuffix(".git") ? url : url + ".git"
        let refs = try await discoverRefs(baseURL: baseURL, authToken: authToken)
        
        // Extract branch names from refs/heads/
        let branches = refs
            .filter { $0.name.hasPrefix("refs/heads/") }
            .map { $0.name.replacingOccurrences(of: "refs/heads/", with: "") }
        
        // Find default branch from symref
        let symrefHead = refs.first { $0.isSymref }?.symrefTarget
        let defaultBranch: String
        if let symTarget = symrefHead {
            defaultBranch = symTarget.replacingOccurrences(of: "refs/heads/", with: "")
        } else {
            defaultBranch = branches.first ?? "main"
        }
        
        return (branches, defaultBranch)
    }
    
    // MARK: - Clone Helpers
    
    private struct GitRef {
        let sha: String
        let name: String
        var isSymref = false
        var symrefTarget: String?
    }
    
    private func createGitDirectoryStructure(at gitDir: URL) throws {
        let fm = FileManager.default
        let dirs = [
            "", "objects", "objects/pack", "objects/info",
            "refs", "refs/heads", "refs/tags", "refs/remotes", "refs/remotes/origin",
            "hooks", "info"
        ]
        for dir in dirs {
            try fm.createDirectory(
                at: gitDir.appendingPathComponent(dir),
                withIntermediateDirectories: true
            )
        }
        // Write description and info/exclude
        try "Unnamed repository; edit this file 'description' to name the repository.\n"
            .write(to: gitDir.appendingPathComponent("description"), atomically: true, encoding: .utf8)
        try "# git ls-files --others --exclude-from=.git/info/exclude\n"
            .write(to: gitDir.appendingPathComponent("info/exclude"), atomically: true, encoding: .utf8)
    }
    
    /// Discover refs from a smart HTTP git server
    private func discoverRefs(baseURL: String, authToken: String? = nil) async throws -> [GitRef] {
        guard let url = URL(string: "\(baseURL)/info/refs?service=git-upload-pack") else {
            throw GitManagerError.cloneFailed("Invalid refs URL")
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw GitManagerError.cloneFailed("Server returned \(httpResponse.statusCode)")
        }
        
        guard let text = String(data: data, encoding: .utf8) else {
            throw GitManagerError.cloneFailed("Invalid response encoding")
        }
        
        return parseSmartHTTPRefs(text)
    }
    
    /// Parse pkt-line formatted ref discovery response
    private func parseSmartHTTPRefs(_ text: String) -> [GitRef] {
        var refs: [GitRef] = []
        let lines = text.components(separatedBy: "\n")
        
        for line in lines {
            // Skip pkt-line length prefixes, flush packets, and service lines
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed == "0000" || trimmed.contains("# service=") {
                continue
            }
            
            // Extract SHA and ref name from pkt-line
            // Format: XXXX<sha> <refname>\0<capabilities> or XXXX<sha> <refname>
            var content = trimmed
            // Strip 4-char pkt-line length prefix if present
            if content.count > 4, content.prefix(4).allSatisfy({ $0.isHexDigit }) {
                content = String(content.dropFirst(4))
            }
            
            // Split on null byte (capabilities) and take first part
            let parts = content.components(separatedBy: "\0")
            let refPart = parts[0]
            let capabilities = parts.count > 1 ? parts[1] : ""
            
            // Parse SHA and name
            let components = refPart.split(separator: " ", maxSplits: 1)
            guard components.count == 2 else { continue }
            
            let sha = String(components[0])
            let name = String(components[1])
            
            // Validate SHA (40 hex chars)
            guard sha.count == 40, sha.allSatisfy({ $0.isHexDigit }) else { continue }
            
            var ref = GitRef(sha: sha, name: name)
            
            // Check for symref capability (HEAD -> refs/heads/main)
            if name == "HEAD", capabilities.contains("symref=HEAD:") {
                if let symrefRange = capabilities.range(of: "symref=HEAD:") {
                    let afterSymref = capabilities[symrefRange.upperBound...]
                    let target = afterSymref.prefix(while: { $0 != " " && $0 != "\0" })
                    ref.isSymref = true
                    ref.symrefTarget = String(target)
                }
            }
            
            refs.append(ref)
        }
        
        return refs
    }
    
    /// Fetch pack file from smart HTTP server
    private func fetchPackFile(baseURL: String, wants: [String], authToken: String? = nil) async throws -> Data {
        guard let url = URL(string: "\(baseURL)/git-upload-pack") else {
            throw GitManagerError.cloneFailed("Invalid upload-pack URL")
        }
        
        // Build request body in pkt-line format
        var body = ""
        for (i, sha) in wants.enumerated() {
            if i == 0 {
                // First want includes capabilities
                let line = "want \(sha) multi_ack_detailed no-done side-band-64k thin-pack ofs-delta agent=codepad/1.0\n"
                body += pktLine(line)
            } else {
                body += pktLine("want \(sha)\n")
            }
        }
        body += "0000" // flush
        body += pktLine("done\n")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-git-upload-pack-request", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        request.timeoutInterval = 120
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw GitManagerError.cloneFailed("Upload-pack failed with status \(httpResponse.statusCode)")
        }
        
        // Extract pack data from side-band response
        return extractPackFromSideBand(data)
    }
    
    /// Format a pkt-line string
    private func pktLine(_ content: String) -> String {
        let length = content.utf8.count + 4
        return String(format: "%04x", length) + content
    }
    
    /// Extract PACK data from side-band-64k response
    private func extractPackFromSideBand(_ data: Data) -> Data {
        var packData = Data()
        var offset = 0
        
        while offset < data.count {
            // Read 4 hex chars for pkt-line length
            guard offset + 4 <= data.count else { break }
            let lengthBytes = data[offset..<offset+4]
            guard let lengthStr = String(data: lengthBytes, encoding: .ascii),
                  let length = Int(lengthStr, radix: 16) else {
                // Not a valid pkt-line, try to find PACK header directly
                if let packRange = data.range(of: Data("PACK".utf8), in: offset..<data.count) {
                    return Data(data[packRange.lowerBound...])
                }
                break
            }
            
            if length == 0 {
                // Flush packet
                offset += 4
                continue
            }
            
            if length <= 4 {
                offset += 4
                continue
            }
            
            let payloadStart = offset + 4
            let payloadEnd = min(offset + length, data.count)
            guard payloadStart < payloadEnd else {
                offset += 4
                continue
            }
            
            let band = data[payloadStart]
            
            switch band {
            case 1:
                // Pack data channel
                if payloadStart + 1 < payloadEnd {
                    packData.append(data[payloadStart+1..<payloadEnd])
                }
            case 2:
                // Progress channel - ignore
                break
            case 3:
                // Error channel
                if let errorMsg = String(data: data[payloadStart+1..<payloadEnd], encoding: .utf8) {
                    AppLogger.git.error("Server error: \(errorMsg)")
                }
            default:
                // No side-band, raw data
                packData.append(data[payloadStart..<payloadEnd])
            }
            
            offset += length
        }
        
        // If we couldn't parse side-band, look for raw PACK header
        if packData.isEmpty, let packRange = data.range(of: Data("PACK".utf8)) {
            return Data(data[packRange.lowerBound...])
        }
        
        return packData
    }
    
    /// Parse a pack file and write objects to .git/objects as loose objects
    @discardableResult
    private func parseAndWritePackFile(packData: Data, gitDir: URL) throws -> Int {
        guard packData.count >= 12 else {
            throw GitManagerError.cloneFailed("Pack data too small (\(packData.count) bytes)")
        }
        
        // Verify PACK header
        let header = packData.prefix(4)
        guard String(data: header, encoding: .ascii) == "PACK" else {
            throw GitManagerError.cloneFailed("Invalid pack header")
        }
        
        // Read version (4 bytes, big-endian)
        let version = packData.withUnsafeBytes { buf -> UInt32 in
            buf.load(fromByteOffset: 4, as: UInt32.self).bigEndian
        }
        guard version == 2 || version == 3 else {
            throw GitManagerError.cloneFailed("Unsupported pack version \(version)")
        }
        
        // Read object count (4 bytes, big-endian)
        let objectCount = packData.withUnsafeBytes { buf -> UInt32 in
            buf.load(fromByteOffset: 8, as: UInt32.self).bigEndian
        }
        
        var offset = 12
        var writtenCount = 0
        let objectsDir = gitDir.appendingPathComponent("objects")
        
        // Track resolved objects by their pack offset for OFS_DELTA resolution
        var resolvedObjects: [Int: (type: String, data: Data)] = [:]
        // Track resolved objects by SHA for REF_DELTA resolution (objects resolved in this pack)
        var resolvedBySHA: [String: (type: String, data: Data)] = [:]
        
        for _ in 0..<objectCount {
            guard offset < packData.count else { break }
            
            // Save offset before reading header (needed for OFS_DELTA base lookup)
            let objectStartOffset = offset
            
            // Read object header (variable-length encoding)
            var byte = packData[offset]
            let objectType = (byte >> 4) & 0x07
            var size: UInt64 = UInt64(byte & 0x0F)
            var shift: UInt64 = 4
            offset += 1
            
            while byte & 0x80 != 0 {
                guard offset < packData.count else { break }
                byte = packData[offset]
                size |= UInt64(byte & 0x7F) << shift
                shift += 7
                offset += 1
            }
            
            switch objectType {
            case 1, 2, 3, 4:
                // commit, tree, blob, tag — zlib compressed data
                let typeStr: String
                switch objectType {
                case 1: typeStr = "commit"
                case 2: typeStr = "tree"
                case 3: typeStr = "blob"
                case 4: typeStr = "tag"
                default: typeStr = "unknown"
                }
                
                // Decompress zlib data
                let remaining = Data(packData[offset...])
                guard let (decompressed, consumed) = zlibDecompress(remaining, expectedSize: Int(size)) else {
                    // Skip this object if decompression fails
                    offset += Int(size) // rough skip
                    continue
                }
                offset += consumed
                
                // Compute SHA for REF_DELTA lookups
                let sha = computeGitObjectSHA(type: typeStr, data: decompressed)
                
                // Store resolved object for delta base lookups (by offset and SHA)
                resolvedObjects[objectStartOffset] = (type: typeStr, data: decompressed)
                resolvedBySHA[sha] = (type: typeStr, data: decompressed)
                
                // Write as loose object
                try writeLooseObject(
                    type: typeStr,
                    data: decompressed,
                    objectsDir: objectsDir
                )
                writtenCount += 1
                
            case 6:
                // OFS_DELTA — resolve against base object at negative offset
                // Read negative offset
                var oByte = packData[offset]
                var negOffset: UInt64 = UInt64(oByte & 0x7F)
                offset += 1
                while oByte & 0x80 != 0 {
                    guard offset < packData.count else { break }
                    oByte = packData[offset]
                    negOffset = ((negOffset + 1) << 7) | UInt64(oByte & 0x7F)
                    offset += 1
                }
                
                // Decompress delta instructions
                let remaining = Data(packData[offset...])
                guard let (deltaData, consumed) = zlibDecompress(remaining, expectedSize: Int(size)) else {
                    offset = packData.count // bail
                    continue
                }
                offset += consumed
                
                // Look up base object — recursively resolve if the base is itself a delta
                let baseOffset = objectStartOffset - Int(negOffset)
                if let baseData = recursivelyResolveObject(at: baseOffset, packData: packData, resolvedObjects: &resolvedObjects, resolvedBySHA: &resolvedBySHA, objectsDir: objectsDir),
                   let resolved = applyDelta(base: baseData.data, delta: deltaData) {
                    // Compute SHA for REF_DELTA lookups
                    let sha = computeGitObjectSHA(type: baseData.type, data: resolved)
                    
                    // Store resolved object (by offset and SHA)
                    resolvedObjects[objectStartOffset] = (type: baseData.type, data: resolved)
                    resolvedBySHA[sha] = (type: baseData.type, data: resolved)
                    
                    // Write as loose object
                    try writeLooseObject(
                        type: baseData.type,
                        data: resolved,
                        objectsDir: objectsDir
                    )
                    writtenCount += 1
                }
                
            case 7:
                // REF_DELTA — resolve against base object by SHA
                guard offset + 20 <= packData.count else {
                    offset = packData.count
                    continue
                }
                let baseSHABytes = packData[offset..<(offset + 20)]
                let baseSHA = baseSHABytes.map { String(format: "%02x", $0) }.joined()
                offset += 20
                
                // Decompress delta instructions
                let remaining = Data(packData[offset...])
                guard let (deltaData, consumed) = zlibDecompress(remaining, expectedSize: Int(size)) else {
                    offset = packData.count
                    continue
                }
                offset += consumed
                
                // Look up base object: check in-pack resolved first, then fall back to disk
                let baseData: (type: String, data: Data)?
                if let inPack = resolvedBySHA[baseSHA] {
                    baseData = inPack
                } else {
                    baseData = readLooseObjectData(sha: baseSHA, objectsDir: objectsDir)
                }
                
                if let baseData = baseData,
                   let resolved = applyDelta(base: baseData.data, delta: deltaData) {
                    // Compute SHA for REF_DELTA lookups
                    let sha = computeGitObjectSHA(type: baseData.type, data: resolved)
                    
                    // Store resolved object (by offset and SHA)
                    resolvedObjects[objectStartOffset] = (type: baseData.type, data: resolved)
                    resolvedBySHA[sha] = (type: baseData.type, data: resolved)
                    
                    // Write as loose object
                    try writeLooseObject(
                        type: baseData.type,
                        data: resolved,
                        objectsDir: objectsDir
                    )
                    writtenCount += 1
                }
                
            default:
                break
            }
        }
        
        return writtenCount
    }
    
    /// Recursively resolve an object at a pack offset, following OFS_DELTA and REF_DELTA chains.
    /// This handles chained deltas (delta of delta) by recursing until a non-delta base is found.
    private func recursivelyResolveObject(at offset: Int, packData: Data, resolvedObjects: inout [Int: (type: String, data: Data)], resolvedBySHA: inout [String: (type: String, data: Data)], objectsDir: URL) -> (type: String, data: Data)? {
        // If already resolved, return cached result
        if let cached = resolvedObjects[offset] {
            return cached
        }
        
        guard offset < packData.count else { return nil }
        
        // Parse the object header at the given offset (local copy, don't mutate main offset)
        var pos = offset
        var byte = packData[pos]
        let objectType = (byte >> 4) & 0x07
        var size: UInt64 = UInt64(byte & 0x0F)
        var shift: UInt64 = 4
        pos += 1
        
        while byte & 0x80 != 0 {
            guard pos < packData.count else { return nil }
            byte = packData[pos]
            size |= UInt64(byte & 0x7F) << shift
            shift += 7
            pos += 1
        }
        
        switch objectType {
        case 1, 2, 3, 4:
            // Regular object — decompress
            let typeStr: String
            switch objectType {
            case 1: typeStr = "commit"
            case 2: typeStr = "tree"
            case 3: typeStr = "blob"
            case 4: typeStr = "tag"
            default: typeStr = "unknown"
            }
            let remaining = Data(packData[pos...])
            guard let (decompressed, _) = zlibDecompress(remaining, expectedSize: Int(size)) else { return nil }
            let result = (type: typeStr, data: decompressed)
            resolvedObjects[offset] = result
            let sha = computeGitObjectSHA(type: typeStr, data: decompressed)
            resolvedBySHA[sha] = result
            return result
            
        case 6:
            // OFS_DELTA — read negative offset and recurse
            var oByte = packData[pos]
            var negOffset: UInt64 = UInt64(oByte & 0x7F)
            pos += 1
            while oByte & 0x80 != 0 {
                guard pos < packData.count else { return nil }
                oByte = packData[pos]
                negOffset = ((negOffset + 1) << 7) | UInt64(oByte & 0x7F)
                pos += 1
            }
            
            let remaining = Data(packData[pos...])
            guard let (deltaData, _) = zlibDecompress(remaining, expectedSize: Int(size)) else { return nil }
            
            let baseOffset = offset - Int(negOffset)
            guard let baseData = recursivelyResolveObject(at: baseOffset, packData: packData, resolvedObjects: &resolvedObjects, resolvedBySHA: &resolvedBySHA, objectsDir: objectsDir) else { return nil }
            guard let resolved = applyDelta(base: baseData.data, delta: deltaData) else { return nil }
            
            let result = (type: baseData.type, data: resolved)
            resolvedObjects[offset] = result
            let sha = computeGitObjectSHA(type: baseData.type, data: resolved)
            resolvedBySHA[sha] = result
            return result
            
        case 7:
            // REF_DELTA — read base SHA and recurse
            guard pos + 20 <= packData.count else { return nil }
            let baseSHABytes = packData[pos..<(pos + 20)]
            let baseSHA = baseSHABytes.map { String(format: "%02x", $0) }.joined()
            pos += 20
            
            let remaining = Data(packData[pos...])
            guard let (deltaData, _) = zlibDecompress(remaining, expectedSize: Int(size)) else { return nil }
            
            // Look up base: in-pack first, then disk
            let baseData: (type: String, data: Data)?
            if let inPack = resolvedBySHA[baseSHA] {
                baseData = inPack
            } else {
                baseData = readLooseObjectData(sha: baseSHA, objectsDir: objectsDir)
            }
            
            guard let baseData = baseData else { return nil }
            guard let resolved = applyDelta(base: baseData.data, delta: deltaData) else { return nil }
            
            let result = (type: baseData.type, data: resolved)
            resolvedObjects[offset] = result
            let sha = computeGitObjectSHA(type: baseData.type, data: resolved)
            resolvedBySHA[sha] = result
            return result
            
        default:
            return nil
        }
    }
    
    /// Compute the SHA-1 hash of a git loose object ("<type> <size>\0<data>")
    private func computeGitObjectSHA(type: String, data: Data) -> String {
        let header = "\(type) \(data.count)\0"
        guard let headerData = header.data(using: .utf8) else { return "" }
        let objectData = headerData + data
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        objectData.withUnsafeBytes { buf in
            _ = CC_SHA1(buf.baseAddress, CC_LONG(objectData.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Apply a Git delta to a base object, producing the target object.
    /// Git delta format: [source_size][target_size][instructions...]
    /// Instructions: MSB=0 → INSERT next N bytes; MSB=1 → COPY from base
    private func applyDelta(base: Data, delta: Data) -> Data? {
        var pos = 0
        
        // Read variable-length source size
        func readVarInt() -> UInt64 {
            var result: UInt64 = 0
            var shift: UInt64 = 0
            while pos < delta.count {
                let b = delta[pos]
                pos += 1
                result |= UInt64(b & 0x7F) << shift
                shift += 7
                if b & 0x80 == 0 { break }
            }
            return result
        }
        
        let sourceSize = readVarInt()
        let targetSize = readVarInt()
        
        // Validate source size matches base
        guard sourceSize == UInt64(base.count) else { return nil }
        
        var target = Data()
        target.reserveCapacity(Int(targetSize))
        
        while pos < delta.count {
            let cmd = delta[pos]
            pos += 1
            
            if cmd & 0x80 != 0 {
                // COPY instruction — copy from base
                var copyOffset: UInt64 = 0
                var copySize: UInt64 = 0
                
                if cmd & 0x01 != 0 { guard pos < delta.count else { return nil }; copyOffset |= UInt64(delta[pos]); pos += 1 }
                if cmd & 0x02 != 0 { guard pos < delta.count else { return nil }; copyOffset |= UInt64(delta[pos]) << 8; pos += 1 }
                if cmd & 0x04 != 0 { guard pos < delta.count else { return nil }; copyOffset |= UInt64(delta[pos]) << 16; pos += 1 }
                if cmd & 0x08 != 0 { guard pos < delta.count else { return nil }; copyOffset |= UInt64(delta[pos]) << 24; pos += 1 }
                
                if cmd & 0x10 != 0 { guard pos < delta.count else { return nil }; copySize |= UInt64(delta[pos]); pos += 1 }
                if cmd & 0x20 != 0 { guard pos < delta.count else { return nil }; copySize |= UInt64(delta[pos]) << 8; pos += 1 }
                if cmd & 0x40 != 0 { guard pos < delta.count else { return nil }; copySize |= UInt64(delta[pos]) << 16; pos += 1 }
                
                if copySize == 0 { copySize = 0x10000 } // special case in git
                
                let start = Int(copyOffset)
                let length = Int(copySize)
                guard start + length <= base.count else { return nil }
                target.append(base[start..<(start + length)])
                
            } else if cmd > 0 {
                // INSERT instruction — next cmd bytes are literal data
                let insertSize = Int(cmd)
                guard pos + insertSize <= delta.count else { return nil }
                target.append(delta[pos..<(pos + insertSize)])
                pos += insertSize
                
            } else {
                // cmd == 0 is reserved/invalid
                return nil
            }
        }
        
        guard UInt64(target.count) == targetSize else { return nil }
        return target
    }
    
    /// Read a loose git object from disk, returning its type and decompressed content data.
    /// Loose objects are stored as zlib-compressed "<type> <size>\0<data>" at .git/objects/xx/yyyy
    private func readLooseObjectData(sha: String, objectsDir: URL) -> (type: String, data: Data)? {
        let prefix = String(sha.prefix(2))
        let suffix = String(sha.dropFirst(2))
        let objectPath = objectsDir.appendingPathComponent(prefix).appendingPathComponent(suffix)
        
        guard let compressedData = try? Data(contentsOf: objectPath) else { return nil }
        
        // Decompress — loose objects can be large, try generous buffer
        let bufferSize = max(compressedData.count * 4, 65536)
        var decompressed = Data(count: bufferSize)
        
        let result = decompressed.withUnsafeMutableBytes { destBuf -> Int in
            compressedData.withUnsafeBytes { srcBuf -> Int in
                guard let destPtr = destBuf.baseAddress,
                      let srcPtr = srcBuf.baseAddress else { return 0 }
                return compression_decode_buffer(
                    destPtr.assumingMemoryBound(to: UInt8.self),
                    bufferSize,
                    srcPtr.assumingMemoryBound(to: UInt8.self),
                    compressedData.count,
                    nil,
                    COMPRESSION_ZLIB
                )
            }
        }
        
        guard result > 0 else { return nil }
        decompressed = decompressed.prefix(result)
        
        // Parse "<type> <size>\0<data>"
        guard let nullIndex = decompressed.firstIndex(of: 0) else { return nil }
        let headerBytes = decompressed[decompressed.startIndex..<nullIndex]
        guard let headerStr = String(data: headerBytes, encoding: .utf8) else { return nil }
        
        let parts = headerStr.split(separator: " ", maxSplits: 1)
        guard parts.count == 2 else { return nil }
        let type = String(parts[0])
        let data = decompressed[(nullIndex + 1)...]
        
        return (type: type, data: Data(data))
    }

    /// Decompress zlib data, returning (decompressed, bytesConsumed)
    private func zlibDecompress(_ data: Data, expectedSize: Int) -> (Data, Int)? {
        // Use Compression framework
        let bufferSize = max(expectedSize, 4096)
        var decompressed = Data(count: bufferSize)
        
        // Try progressively larger chunks of input
        for trySize in stride(from: min(data.count, max(expectedSize + 64, 256)), through: data.count, by: 256) {
            let inputSize = min(trySize, data.count)
            let result = decompressed.withUnsafeMutableBytes { destBuf -> Int in
                data.withUnsafeBytes { srcBuf -> Int in
                    guard let destPtr = destBuf.baseAddress,
                          let srcPtr = srcBuf.baseAddress else { return 0 }
                    return compression_decode_buffer(
                        destPtr.assumingMemoryBound(to: UInt8.self),
                        bufferSize,
                        srcPtr.assumingMemoryBound(to: UInt8.self),
                        inputSize,
                        nil,
                        COMPRESSION_ZLIB
                    )
                }
            }
            
            if result > 0 {
                decompressed = decompressed.prefix(result)
                return (decompressed, inputSize)
            }
        }
        
        return nil
    }
    
    /// Write a loose git object (type + data → SHA1 → .git/objects/xx/yyyy)
    private func writeLooseObject(type: String, data: Data, objectsDir: URL) throws {
        
        // Build git object: "<type> <size>\0<data>"
        let header = "\(type) \(data.count)\0"
        guard let headerData = header.data(using: .utf8) else { return }
        let objectData = headerData + data
        
        // SHA1 hash
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        objectData.withUnsafeBytes { buf in
            _ = CC_SHA1(buf.baseAddress, CC_LONG(objectData.count), &hash)
        }
        let sha = hash.map { String(format: "%02x", $0) }.joined()
        
        let prefix = String(sha.prefix(2))
        let suffix = String(sha.dropFirst(2))
        let objectDir = objectsDir.appendingPathComponent(prefix)
        let objectPath = objectDir.appendingPathComponent(suffix)
        
        // Skip if already exists
        guard !FileManager.default.fileExists(atPath: objectPath.path) else { return }
        
        // Create directory
        try FileManager.default.createDirectory(at: objectDir, withIntermediateDirectories: true)
        
        // Compress with zlib
        let compressedSize = objectData.count + 512
        var compressed = Data(count: compressedSize)
        let result = compressed.withUnsafeMutableBytes { destBuf -> Int in
            objectData.withUnsafeBytes { srcBuf -> Int in
                guard let destPtr = destBuf.baseAddress,
                      let srcPtr = srcBuf.baseAddress else { return 0 }
                return compression_encode_buffer(
                    destPtr.assumingMemoryBound(to: UInt8.self),
                    compressedSize,
                    srcPtr.assumingMemoryBound(to: UInt8.self),
                    objectData.count,
                    nil,
                    COMPRESSION_ZLIB
                )
            }
        }
        
        if result > 0 {
            compressed = compressed.prefix(result)
            try compressed.write(to: objectPath)
        }
    }
    
    /// Checkout the HEAD tree to the working directory
    @discardableResult
    private func checkoutWorkingTree(gitDir: URL, to destination: URL) throws -> Int {
        // NativeGitReader expects the repo root (parent of .git)
        let repoRoot = gitDir.deletingLastPathComponent()
        guard let reader = NativeGitReader(repositoryURL: repoRoot) else {
            throw GitManagerError.cloneFailed("Could not open repository at \(repoRoot.path)")
        }
        
        // Get HEAD commit SHA
        guard let headSHA = reader.headSHA() else {
            throw GitManagerError.cloneFailed("Could not resolve HEAD")
        }
        
        // Read commit to get tree SHA
        guard let commitObj = reader.readObject(sha: headSHA),
              commitObj.type == .commit,
              let commitStr = String(data: commitObj.data, encoding: .utf8),
              let treeLine = commitStr.components(separatedBy: "\n").first(where: { $0.hasPrefix("tree ") }) else {
            throw GitManagerError.cloneFailed("Could not read HEAD commit")
        }
        
        let treeSHA = String(treeLine.dropFirst(5))
        
        // Recursively checkout tree
        return try checkoutTree(sha: treeSHA, at: destination, reader: reader)
    }
    
    /// Recursively checkout a tree object
    private func checkoutTree(sha: String, at directory: URL, reader: NativeGitReader) throws -> Int {
        guard let treeObj = reader.readObject(sha: sha), treeObj.type == .tree else { return 0 }
        
        var fileCount = 0
        var offset = 0
        let bytes = [UInt8](treeObj.data)
        
        while offset < bytes.count {
            // Parse tree entry: "<mode> <name>\0<20-byte-sha>"
            // Find space (end of mode)
            guard let spaceIdx = bytes[offset...].firstIndex(of: 0x20) else { break }
            let modeStr = String(bytes: Array(bytes[offset..<spaceIdx]), encoding: .ascii) ?? ""
            offset = spaceIdx + 1
            
            // Find null (end of name)
            guard let nullIdx = bytes[offset...].firstIndex(of: 0x00) else { break }
            let name = String(bytes: Array(bytes[offset..<nullIdx]), encoding: .utf8) ?? ""
            offset = nullIdx + 1
            
            // Read 20-byte SHA
            guard offset + 20 <= bytes.count else { break }
            let entrySHA = bytes[offset..<offset+20].map { String(format: "%02x", $0) }.joined()
            offset += 20
            
            let entryPath = directory.appendingPathComponent(name)
            
            if modeStr.hasPrefix("4") {
                // Directory (tree) — recurse
                try FileManager.default.createDirectory(at: entryPath, withIntermediateDirectories: true)
                fileCount += try checkoutTree(sha: entrySHA, at: entryPath, reader: reader)
            } else {
                // File (blob) — write
                if let blobObj = reader.readObject(sha: entrySHA), blobObj.type == .blob {
                    try blobObj.data.write(to: entryPath)
                    fileCount += 1
                }
            }
        }
        
        return fileCount
    }
    
    // MARK: - Git Blame/Annotate
    
    /// Get line-by-line commit information for a file.
    /// This is a simplified implementation that returns the HEAD commit info for all lines.
    /// A full implementation would walk the commit history to find when each line was last modified.
    /// - Parameter file: Path to the file relative to repository root
    /// - Returns: Array of BlameLine with commit info for each line
    func blame(file: String) async throws -> [BlameLine] {
        guard let _ = workingDirectory,
              let reader = nativeReader else {
            throw GitManagerError.noRepository
        }
        
        // Get HEAD commit info
        guard let headSHA = reader.headSHA(),
              let commit = reader.parseCommit(sha: headSHA) else {
            throw GitManagerError.invalidRepository
        }
        
        // Read file contents from HEAD
        guard let content = reader.fileContentsString(atPath: file, commitSHA: headSHA) else {
            throw GitManagerError.commandFailed(args: "blame", exitCode: 1, message: "File not found: \(file)")
        }
        
        let lines = content.components(separatedBy: "\n")
        let shortSHA = String(headSHA.prefix(7))
        
        return lines.enumerated().map { index, lineContent in
            BlameLine(
                lineNumber: index + 1,
                commitSHA: shortSHA,
                author: commit.author,
                date: commit.authorDate,
                lineContent: lineContent
            )
        }
    }
    
    // MARK: - Tag Management
    
    /// List all tags in the repository
    /// - Returns: Array of GitTag sorted by name
    func listTags() async throws -> [GitTag] {
        guard let repoURL = workingDirectory,
              let reader = nativeReader else {
            throw GitManagerError.noRepository
        }
        
        let tagsDir = repoURL.appendingPathComponent(".git/refs/tags")
        var tags: [GitTag] = []
        
        // Read loose tags from .git/refs/tags/
        if FileManager.default.fileExists(atPath: tagsDir.path) {
            let looseTags = try listTagsRecursively(at: tagsDir, prefix: "", reader: reader)
            tags.append(contentsOf: looseTags)
        }
        
        // Read tags from packed-refs
        let packedTags = readPackedTags(repoURL: repoURL, reader: reader)
        for packedTag in packedTags {
            // Only add if not already found as loose tag
            if !tags.contains(where: { $0.name == packedTag.name }) {
                tags.append(packedTag)
            }
        }
        
        return tags.sorted { $0.name < $1.name }
    }
    
    /// Recursively list tags from a directory
    private func listTagsRecursively(at url: URL, prefix: String, reader: NativeGitReader) throws -> [GitTag] {
        var tags: [GitTag] = []
        
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path) else {
            return tags
        }
        
        for item in contents {
            let itemURL = url.appendingPathComponent(item)
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir)
            
            let fullName = prefix.isEmpty ? item : "\(prefix)/\(item)"
            
            if isDir.boolValue {
                // Recurse into subdirectory (for nested tags)
                let subTags = try listTagsRecursively(at: itemURL, prefix: fullName, reader: reader)
                tags.append(contentsOf: subTags)
            } else {
                // Read tag ref to get commit SHA
                if let content = try? String(contentsOf: itemURL, encoding: .utf8) {
                    let sha = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !sha.isEmpty {
                        // Check if it's an annotated tag (points to tag object)
                        let (commitSHA, message, isAnnotated) = resolveTagObject(sha: sha, reader: reader)
                        tags.append(GitTag(
                            name: fullName,
                            commitSHA: commitSHA,
                            message: message,
                            isAnnotated: isAnnotated
                        ))
                    }
                }
            }
        }
        
        return tags
    }
    
    /// Read tags from packed-refs file
    private func readPackedTags(repoURL: URL, reader: NativeGitReader) -> [GitTag] {
        var tags: [GitTag] = []
        let packedRefsFile = repoURL.appendingPathComponent(".git/packed-refs")
        
        guard let content = try? String(contentsOf: packedRefsFile, encoding: .utf8) else {
            return tags
        }
        
        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") || trimmed.hasPrefix("^") {
                continue
            }
            
            let parts = trimmed.split(separator: " ", maxSplits: 1)
            if parts.count == 2, String(parts[1]).hasPrefix("refs/tags/") {
                let sha = String(parts[0])
                let tagName = String(parts[1].dropFirst("refs/tags/".count))
                
                let (commitSHA, message, isAnnotated) = resolveTagObject(sha: sha, reader: reader)
                tags.append(GitTag(
                    name: tagName,
                    commitSHA: commitSHA,
                    message: message,
                    isAnnotated: isAnnotated
                ))
            }
        }
        
        return tags
    }
    
    /// Resolve a tag SHA to its commit SHA and message (if annotated)
    private func resolveTagObject(sha: String, reader: NativeGitReader) -> (commitSHA: String, message: String?, isAnnotated: Bool) {
        // Try to read as a tag object (annotated tag)
        if let obj = reader.readObject(sha: sha), obj.type == .tag {
            // Parse tag object to get target commit and message
            if let content = String(data: obj.data, encoding: .utf8) {
                var targetCommitSHA: String?
                var message: String?
                
                let lines = content.components(separatedBy: "\n")
                var inMessage = false
                var messageLines: [String] = []
                
                for line in lines {
                    if inMessage {
                        messageLines.append(line)
                        continue
                    }
                    
                    if line.isEmpty {
                        inMessage = true
                        continue
                    }
                    
                    if line.hasPrefix("object ") {
                        targetCommitSHA = String(line.dropFirst(7))
                    }
                }
                
                message = messageLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let commitSHA = targetCommitSHA {
                    return (commitSHA, message, true)
                }
            }
        }
        
        // Lightweight tag - the SHA is the commit SHA
        return (sha, nil, false)
    }
    
    /// Create a new tag
    /// - Parameters:
    ///   - name: Tag name
    ///   - message: Optional message for annotated tag (nil for lightweight tag)
    ///   - commitSHA: Commit to tag (defaults to HEAD)
    func createTag(name: String, message: String? = nil, commitSHA: String? = nil) async throws {
        guard let repoURL = workingDirectory,
              let reader = nativeReader else {
            throw GitManagerError.noRepository
        }
        
        // Validate tag name to prevent path traversal
        guard isValidTagName(name) else {
            throw GitManagerError.commandFailed(args: "tag", exitCode: 1, message: "Invalid tag name: contains forbidden characters")
        }
        
        // Get the commit SHA to tag
        let targetSHA: String
        if let sha = commitSHA {
            targetSHA = sha
        } else {
            guard let headSHA = reader.headSHA() else {
                throw GitManagerError.invalidRepository
            }
            targetSHA = headSHA
        }
        
        let tagsDir = repoURL.appendingPathComponent(".git/refs/tags")
        try FileManager.default.createDirectory(at: tagsDir, withIntermediateDirectories: true)
        
        let tagFile = tagsDir.appendingPathComponent(name)
        
        // Check if tag already exists
        if FileManager.default.fileExists(atPath: tagFile.path) {
            throw GitManagerError.commandFailed(args: "tag", exitCode: 1, message: "Tag '\(name)' already exists")
        }
        
        if let message = message, !message.isEmpty {
            // Create annotated tag (tag object)
            guard let writer = nativeWriter else {
                throw GitManagerError.invalidRepository
            }
            
            // Create tag object
            let tagObjectSHA = try createTagObject(
                targetSHA: targetSHA,
                name: name,
                message: message,
                writer: writer
            )
            
            // Write ref pointing to tag object
            try "\(tagObjectSHA)\n".write(to: tagFile, atomically: true, encoding: .utf8)
        } else {
            // Create lightweight tag (ref points directly to commit)
            try "\(targetSHA)\n".write(to: tagFile, atomically: true, encoding: .utf8)
        }
    }
    
    /// Create a tag object for annotated tags
    private func createTagObject(targetSHA: String, name: String, message: String, writer: NativeGitWriter) throws -> String {
        // Get config for tagger info
        let config = readGitConfigForWriter()
        let taggerName = config.name ?? "VSCodeiPadOS"
        let taggerEmail = config.email ?? "vscode@localhost"
        
        let now = Date()
        let timestamp = Int(now.timeIntervalSince1970)
        let tz = formatTimezoneForTag(secondsFromGMT: TimeZone.current.secondsFromGMT(for: now))
        
        // Build tag object content
        var tagContent = ""
        tagContent += "object \(targetSHA)\n"
        tagContent += "type commit\n"
        tagContent += "tag \(name)\n"
        tagContent += "tagger \(taggerName) <\(taggerEmail)> \(timestamp) \(tz)\n"
        tagContent += "\n"
        tagContent += message
        if !message.hasSuffix("\n") {
            tagContent += "\n"
        }
        
        // Write tag object using NativeGitWriter's internal writeObject
        return try writeTagObject(type: .tag, content: Data(tagContent.utf8), writer: writer)
    }
    
    /// Write a git object (for tag creation)
    private func writeTagObject(type: GitObjectType, content: Data, writer: NativeGitWriter) throws -> String {
        // Use NativeGitWriter's writeObject via reflection or create a helper
        // Since writeObject is private, we'll write the object directly
        let header = "\(type.rawValue) \(content.count)\u{0}"
        var store = Data(header.utf8)
        store.append(content)
        
        let sha = sha1Hex(store)
        
        guard let repoURL = workingDirectory else {
            throw GitManagerError.noRepository
        }
        
        let gitDir = repoURL.appendingPathComponent(".git")
        let objectDir = gitDir.appendingPathComponent("objects").appendingPathComponent(String(sha.prefix(2)))
        let objectFile = objectDir.appendingPathComponent(String(sha.dropFirst(2)))
        
        if FileManager.default.fileExists(atPath: objectFile.path) {
            return sha
        }
        
        try FileManager.default.createDirectory(at: objectDir, withIntermediateDirectories: true)
        
        let compressed = try compressZlibData(store)
        try compressed.write(to: objectFile, options: [.atomic])
        
        return sha
    }
    
    /// Delete a tag
    /// - Parameter name: Tag name to delete
    func deleteTag(name: String) async throws {
        guard let repoURL = workingDirectory else {
            throw GitManagerError.noRepository
        }
        
        // Validate tag name to prevent path traversal
        guard isValidTagName(name) else {
            throw GitManagerError.commandFailed(args: "tag", exitCode: 1, message: "Invalid tag name")
        }
        
        // Delete loose tag ref
        let tagFile = repoURL.appendingPathComponent(".git/refs/tags/\(name)")
        
        if FileManager.default.fileExists(atPath: tagFile.path) {
            try FileManager.default.removeItem(at: tagFile)
        } else {
            // Tag might be in packed-refs - we can't easily remove from packed-refs
            // without rewriting the entire file, so we'll create an empty loose ref
            // which takes precedence (though git won't show it)
            throw GitManagerError.commandFailed(args: "tag", exitCode: 1, message: "Tag '\(name)' not found or is packed")
        }
    }
    
    // MARK: - Tag Helper Methods
    
    /// Validate tag name (prevent path traversal and invalid characters)
    private func isValidTagName(_ name: String) -> Bool {
        // Tag names cannot contain spaces, control chars, or path components
        if name.isEmpty { return false }
        if name.contains("..") { return false }
        if name.contains("/") { return false }
        if name.contains("\\") { return false }
        if name.contains(" ") { return false }
        if name.hasPrefix(".") { return false }
        if name.hasSuffix(".") { return false }
        if name.contains("~") { return false }
        if name.contains("^") { return false }
        if name.contains(":") { return false }
        if name.contains("?") { return false }
        if name.contains("*") { return false }
        if name.contains("[") { return false }
        return true
    }
    
    /// Read git config for tagger info
    private func readGitConfigForWriter() -> (name: String?, email: String?) {
        guard let repoURL = workingDirectory else { return (nil, nil) }
        let configFile = repoURL.appendingPathComponent(".git/config")
        guard let content = try? String(contentsOf: configFile, encoding: .utf8) else {
            return (nil, nil)
        }
        
        var name: String?
        var email: String?
        var inUserSection = false
        
        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("[") {
                inUserSection = trimmed.hasPrefix("[user]") || trimmed.hasPrefix("[user \t")
                continue
            }
            
            if inUserSection {
                let parts = trimmed.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                if parts.count == 2 {
                    let key = parts[0].lowercased()
                    if key == "name" {
                        name = parts[1]
                    } else if key == "email" {
                        email = parts[1]
                    }
                }
            }
        }
        
        return (name, email)
    }
    
    /// Format timezone for tag object
    private func formatTimezoneForTag(secondsFromGMT: Int) -> String {
        let sign = secondsFromGMT >= 0 ? "+" : "-"
        let absSeconds = abs(secondsFromGMT)
        let hours = absSeconds / 3600
        let minutes = (absSeconds % 3600) / 60
        return String(format: "%@%02d%02d", sign, hours, minutes)
    }
    
    /// SHA1 hash to hex string
    private func sha1Hex(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { ptr in
            _ = CC_SHA1(ptr.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Compress data using zlib
    private func compressZlibData(_ data: Data) throws -> Data {
        var destSize = max(data.count / 2, 1024)
        for _ in 0..<6 {
            let destBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destSize)
            defer { destBuffer.deallocate() }
            
            let written: Int = data.withUnsafeBytes { sourcePtr in
                guard let base = sourcePtr.baseAddress else { return 0 }
                return compression_encode_buffer(
                    destBuffer,
                    destSize,
                    base.assumingMemoryBound(to: UInt8.self),
                    data.count,
                    nil,
                    COMPRESSION_ZLIB
                )
            }
            
            if written > 0 {
                return Data(bytes: destBuffer, count: written)
            }
            
            destSize *= 2
        }
        
        throw GitManagerError.invalidRepository
    }
    
    // MARK: - Revert Commit
    
    /// Revert a commit by creating a new commit that undoes the changes from the specified commit.
    /// This reads the commit's parent tree and restores files to their parent state.
    /// - Parameter sha: The SHA of the commit to revert
    /// - Throws: GitManagerError if the operation fails
    func revertCommit(sha: String) async throws {
        guard let reader = nativeReader else {
            throw GitManagerError.invalidRepository
        }
        guard let writer = nativeWriter else {
            throw GitManagerError.invalidRepository
        }
        guard let repoURL = workingDirectory else {
            throw GitManagerError.noRepository
        }
        
        // Parse the commit to revert
        guard let commit = reader.parseCommit(sha: sha) else {
            throw GitManagerError.commandFailed(args: "revert", exitCode: 1, message: "Could not find commit \(sha)")
        }
        
        guard let parentSHA = commit.parentSHA else {
            throw GitManagerError.commandFailed(args: "revert", exitCode: 1, message: "Cannot revert root commit (no parent)")
        }
        
        guard let commitTreeSHA = commit.treeSHA else {
            throw GitManagerError.commandFailed(args: "revert", exitCode: 1, message: "Could not read commit tree")
        }
        
        // Get parent commit's tree
        guard let parentCommit = reader.parseCommit(sha: parentSHA),
              let parentTreeSHA = parentCommit.treeSHA else {
            throw GitManagerError.commandFailed(args: "revert", exitCode: 1, message: "Could not read parent commit tree")
        }
        
        // Get all files from both trees
        let commitTree = getFlatTree(sha: commitTreeSHA, reader: reader)
        let parentTree = getFlatTree(sha: parentTreeSHA, reader: reader)
        
        // Find files that changed in the commit (exist in commit tree but differ from parent)
        var changedFiles: [(path: String, oldSHA: String?, newSHA: String?)] = []
        
        // Files modified or deleted in the commit
        for (path, parentFileSHA) in parentTree {
            let commitFileSHA = commitTree[path]
            if commitFileSHA != parentFileSHA {
                // File was modified or deleted - restore to parent version
                changedFiles.append((path: path, oldSHA: parentFileSHA, newSHA: commitFileSHA))
            }
        }
        
        // Files added in the commit (exist in commit but not in parent)
        for (path, commitFileSHA) in commitTree {
            if parentTree[path] == nil {
                // File was added in commit - need to delete it (restore = not exist)
                changedFiles.append((path: path, oldSHA: nil, newSHA: commitFileSHA))
            }
        }
        
        if changedFiles.isEmpty {
            throw GitManagerError.commandFailed(args: "revert", exitCode: 1, message: "No changes to revert")
        }
        
        // Check for conflicts with working directory
        let currentTree = getCurrentTreeEntries(reader: reader)
        let workingStatus = reader.status()
        
        for change in changedFiles {
            // Check if file has uncommitted changes
            if let status = workingStatus.first(where: { $0.path == change.path }),
               status.working != nil || status.staged != nil {
                // File has local modifications that might conflict
                let hasConflict = checkForRevertConflict(
                    path: change.path,
                    currentTree: currentTree,
                    revertFromSHA: change.newSHA,
                    revertToSHA: change.oldSHA
                )
                if hasConflict {
                    throw GitManagerError.commandFailed(
                        args: "revert",
                        exitCode: 1,
                        message: "Conflict: file '\(change.path)' has local modifications that would be overwritten. Commit or stash your changes first."
                    )
                }
            }
        }
        
        // Apply the revert: restore files to parent state
        for change in changedFiles {
            let filePath = repoURL.appendingPathComponent(change.path)
            
            if let parentFileSHA = change.oldSHA {
                // Restore parent version of the file
                guard let blobObj = reader.readObject(sha: parentFileSHA),
                      blobObj.type == .blob else {
                    throw GitManagerError.commandFailed(
                        args: "revert",
                        exitCode: 1,
                        message: "Could not read file blob for \(change.path)"
                    )
                }
                
                // Ensure parent directory exists
                let parentDir = filePath.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: parentDir.path) {
                    try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
                }
                
                try blobObj.data.write(to: filePath)
                
            } else {
                // File was added in commit - delete it to revert
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try FileManager.default.removeItem(at: filePath)
                }
            }
        }
        
        // Stage all changes
        try writer.stageAll()
        
        // Create the revert commit
        let revertMessage = "Revert \"\(commit.message)\"\n\nThis reverts commit \(sha)."
        let _ = try writer.commit(message: revertMessage)
        
        await refresh()
    }
    
    // MARK: - Cherry-pick
    
    /// Cherry-pick a commit by applying its changes to the current branch.
    /// This reads the commit's changes and applies them to the working directory.
    /// - Parameter sha: The SHA of the commit to cherry-pick
    /// - Throws: GitManagerError if the operation fails
    func cherryPick(sha: String) async throws {
        guard let reader = nativeReader else {
            throw GitManagerError.invalidRepository
        }
        guard let writer = nativeWriter else {
            throw GitManagerError.invalidRepository
        }
        guard let repoURL = workingDirectory else {
            throw GitManagerError.noRepository
        }
        
        // Parse the commit to cherry-pick
        guard let commit = reader.parseCommit(sha: sha) else {
            throw GitManagerError.commandFailed(args: "cherry-pick", exitCode: 1, message: "Could not find commit \(sha)")
        }
        
        guard let parentSHA = commit.parentSHA else {
            throw GitManagerError.commandFailed(args: "cherry-pick", exitCode: 1, message: "Cannot cherry-pick root commit (no parent)")
        }
        
        guard let commitTreeSHA = commit.treeSHA else {
            throw GitManagerError.commandFailed(args: "cherry-pick", exitCode: 1, message: "Could not read commit tree")
        }
        
        // Get parent commit's tree
        guard let parentCommit = reader.parseCommit(sha: parentSHA),
              let parentTreeSHA = parentCommit.treeSHA else {
            throw GitManagerError.commandFailed(args: "cherry-pick", exitCode: 1, message: "Could not read parent commit tree")
        }
        
        // Get all files from both trees
        let commitTree = getFlatTree(sha: commitTreeSHA, reader: reader)
        let parentTree = getFlatTree(sha: parentTreeSHA, reader: reader)
        
        // Find files that changed in the commit
        var changedFiles: [(path: String, parentSHA: String?, commitSHA: String?)] = []
        
        // Files modified or added in the commit
        for (path, commitFileSHA) in commitTree {
            let parentFileSHA = parentTree[path]
            if parentFileSHA != commitFileSHA {
                // File was modified or added
                changedFiles.append((path: path, parentSHA: parentFileSHA, commitSHA: commitFileSHA))
            }
        }
        
        // Files deleted in the commit
        for (path, parentFileSHA) in parentTree {
            if commitTree[path] == nil {
                // File was deleted in commit
                changedFiles.append((path: path, parentSHA: parentFileSHA, commitSHA: nil))
            }
        }
        
        if changedFiles.isEmpty {
            throw GitManagerError.commandFailed(args: "cherry-pick", exitCode: 1, message: "No changes to cherry-pick")
        }
        
        // Check for conflicts with current working directory
        let currentTree = getCurrentTreeEntries(reader: reader)
        let workingStatus = reader.status()
        
        for change in changedFiles {
            // Check if file has uncommitted changes
            if let status = workingStatus.first(where: { $0.path == change.path }),
               status.working != nil || status.staged != nil {
                // File has local modifications - check for conflict
                let hasConflict = checkForCherryPickConflict(
                    path: change.path,
                    currentTree: currentTree,
                    sourceParentSHA: change.parentSHA,
                    sourceCommitSHA: change.commitSHA
                )
                if hasConflict {
                    throw GitManagerError.commandFailed(
                        args: "cherry-pick",
                        exitCode: 1,
                        message: "Conflict: file '\(change.path)' has local modifications that conflict with the cherry-pick. Commit or stash your changes first."
                    )
                }
            }
        }
        
        // Apply the cherry-pick: copy commit's file versions to working directory
        for change in changedFiles {
            let filePath = repoURL.appendingPathComponent(change.path)
            
            if let commitFileSHA = change.commitSHA {
                // Copy file from commit
                guard let blobObj = reader.readObject(sha: commitFileSHA),
                      blobObj.type == .blob else {
                    throw GitManagerError.commandFailed(
                        args: "cherry-pick",
                        exitCode: 1,
                        message: "Could not read file blob for \(change.path)"
                    )
                }
                
                // Ensure parent directory exists
                let parentDir = filePath.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: parentDir.path) {
                    try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
                }
                
                try blobObj.data.write(to: filePath)
                
            } else {
                // File was deleted in commit - delete it
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try FileManager.default.removeItem(at: filePath)
                }
            }
        }
        
        // Stage all changes
        try writer.stageAll()
        
        // Create the cherry-pick commit with the original message
        let cherryPickMessage = "\(commit.message)\n\n(cherry picked from commit \(sha))"
        let _ = try writer.commit(message: cherryPickMessage)
        
        await refresh()
    }
    
    // MARK: - Helper Methods for Revert/Cherry-pick
    
    /// Get a flattened dictionary of all files in a tree (path -> blob SHA)
    private func getFlatTree(sha: String, reader: NativeGitReader) -> [String: String] {
        guard let treeObj = reader.readObject(sha: sha), treeObj.type == .tree else {
            return [:]
        }
        
        var results: [String: String] = [:]
        let entries = parseTreeEntriesForRevert(treeData: treeObj.data)
        
        for entry in entries {
            if entry.mode.hasPrefix("4") {
                // Directory - recurse
                let subtree = getFlatTree(sha: entry.sha, reader: reader)
                for (subPath, subSHA) in subtree {
                    results["\(entry.name)/\(subPath)"] = subSHA
                }
            } else {
                // File
                results[entry.name] = entry.sha
            }
        }
        
        return results
    }
    
    /// Parse tree entries from raw tree data
    private func parseTreeEntriesForRevert(treeData: Data) -> [(mode: String, name: String, sha: String)] {
        var entries: [(String, String, String)] = []
        var offset = 0
        let bytes = [UInt8](treeData)
        
        while offset < bytes.count {
            // Find space (end of mode)
            guard let spaceIdx = bytes[offset...].firstIndex(of: 0x20) else { break }
            let modeStr = String(bytes: Array(bytes[offset..<spaceIdx]), encoding: .ascii) ?? ""
            offset = spaceIdx + 1
            
            // Find null (end of name)
            guard let nullIdx = bytes[offset...].firstIndex(of: 0x00) else { break }
            let name = String(bytes: Array(bytes[offset..<nullIdx]), encoding: .utf8) ?? ""
            offset = nullIdx + 1
            
            // Read 20-byte SHA
            guard offset + 20 <= bytes.count else { break }
            let shaBytes = bytes[offset..<offset+20]
            let sha = shaBytes.map { String(format: "%02x", $0) }.joined()
            offset += 20
            
            entries.append((modeStr, name, sha))
        }
        
        return entries
    }
    
    /// Get current HEAD tree entries
    private func getCurrentTreeEntries(reader: NativeGitReader) -> [String: String] {
        guard let headSHA = reader.headSHA(),
              let commit = reader.parseCommit(sha: headSHA),
              let treeSHA = commit.treeSHA else {
            return [:]
        }
        return getFlatTree(sha: treeSHA, reader: reader)
    }
    
    /// Check if reverting a file would conflict with current working directory
    private func checkForRevertConflict(
        path: String,
        currentTree: [String: String],
        revertFromSHA: String?,
        revertToSHA: String?
    ) -> Bool {
        // If the current HEAD version differs from what we're reverting from,
        // and we're trying to restore a different version, there's a potential conflict
        guard let currentSHA = currentTree[path] else {
            // File doesn't exist in current HEAD
            // If we're reverting an addition, that's fine (we'll delete it)
            // If we're reverting a modification, check if working dir has the file
            return false
        }
        
        // If current HEAD matches what we're reverting from, no conflict
        if currentSHA == revertFromSHA {
            return false
        }
        
        // If current HEAD already matches what we're reverting to, no conflict
        if currentSHA == revertToSHA {
            return false
        }
        
        // Current HEAD differs from both - potential conflict
        // The file has been modified since the commit we're reverting
        return true
    }
    
    /// Check if cherry-picking a file would conflict with current working directory
    private func checkForCherryPickConflict(
        path: String,
        currentTree: [String: String],
        sourceParentSHA: String?,
        sourceCommitSHA: String?
    ) -> Bool {
        guard let currentSHA = currentTree[path] else {
            // File doesn't exist in current HEAD - no conflict
            return false
        }
        
        // If current HEAD matches the source parent, no conflict
        if currentSHA == sourceParentSHA {
            return false
        }
        
        // If current HEAD already matches the source commit, no conflict (already applied)
        if currentSHA == sourceCommitSHA {
            return false
        }
        
        // Current HEAD differs from source parent - potential conflict
        // The file has been modified differently than what we're cherry-picking onto
        return true
    }
}
