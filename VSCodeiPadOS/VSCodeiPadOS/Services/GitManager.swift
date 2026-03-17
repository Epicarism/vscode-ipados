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

    private var workingDirectory: URL?
    private var nativeReader: NativeGitReader?
    private var nativeWriter: NativeGitWriter?
    
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
        isLoading = true
        defer { isLoading = false }
        lastError = nil
        
        guard let reader = nativeReader else {
            lastError = "No git repository found"
            return
        }
        
        // Current branch
        currentBranch = reader.currentBranch() ?? "HEAD"
        
        // Branches
        let localBranchNames = reader.localBranches()
        branches = localBranchNames.map { name in
            GitBranch(name: name, isRemote: false, isCurrent: name == currentBranch)
        }
        
        let remoteBranchPairs = reader.remoteBranches()
        remoteBranches = remoteBranchPairs.map { (remote, branch) in
            GitBranch(name: "\(remote)/\(branch)", isRemote: true, isCurrent: false)
        }
        
        // Status
        let fileStatuses = reader.status()
        
        stagedChanges = fileStatuses.compactMap { status -> GitFileChange? in
            guard let staged = status.staged else { return nil }
            return GitFileChange(path: status.path, kind: mapStatusType(staged), staged: true)
        }
        
        unstagedChanges = fileStatuses.compactMap { status -> GitFileChange? in
            guard let working = status.working, working != .untracked else { return nil }
            return GitFileChange(path: status.path, kind: mapStatusType(working), staged: false)
        }
        
        untrackedFiles = fileStatuses.compactMap { status -> GitFileChange? in
            guard status.working == .untracked else { return nil }
            return GitFileChange(path: status.path, kind: .untracked, staged: false)
        }
        
        // Populate ahead/behind counts (simplified)
        if let headSHA = reader.headSHA() {
            // Look for a remote tracking branch matching the current branch
            let trackingRemote = remoteBranches.first { $0.name.hasSuffix("/\(currentBranch)") }
            if let tracking = trackingRemote {
                let refPath = workingDirectory?.appendingPathComponent(".git/refs/remotes/\(tracking.name)")
                var remoteSHA: String?
                if let refPath, let data = try? Data(contentsOf: refPath) {
                    remoteSHA = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    // Fallback: check packed-refs
                    if let packedRefPath = workingDirectory?.appendingPathComponent(".git/packed-refs"),
                       let packedContent = try? String(contentsOf: packedRefPath, encoding: .utf8) {
                        for line in packedContent.components(separatedBy: .newlines) {
                            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                            guard !trimmedLine.isEmpty, !trimmedLine.hasPrefix("#") else { continue }
                            let parts = trimmedLine.components(separatedBy: .whitespaces)
                            // packed-refs format: <sha> <refname>
                            guard parts.count >= 2 else { continue }
                            if parts[1] == "refs/remotes/\(tracking.name)" {
                                remoteSHA = parts[0]
                                break
                        }
                        }
                    }
                }
                if let remoteSHA, remoteSHA != headSHA {
                    // Walk the commit chain from HEAD to count ahead/behind accurately
                    let (ahead, behind) = countAheadBehind(
                        headSHA: headSHA,
                        remoteSHA: remoteSHA,
                        reader: reader
                    )
                    aheadCount = ahead
                    behindCount = behind
                } else {
                    aheadCount = 0
                    behindCount = 0
                }
            } else {
                aheadCount = 0
                behindCount = 0
            }
        }

        // Recent commits
        let commits = reader.recentCommits(count: 20)
        recentCommits = commits.map { commit in
            GitCommit(id: commit.sha, message: commit.message, author: commit.author, date: commit.authorDate)
        }
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
    /// Walk commit chains from HEAD and remote to count ahead/behind commits.
    /// Uses the NativeGitReader's parseCommit to follow parent links.
    /// Falls back to approximate counts if the chain is too long to walk locally.
    private func countAheadBehind(headSHA: String, remoteSHA: String, reader: NativeGitReader) -> (ahead: Int, behind: Int) {
        var ahead: Int = 0
        var behind: Int = 0
        let maxWalk: Int = 200 // safety limit to avoid excessive work

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
            // Could not reach remote from HEAD — we are definitely ahead, but count is approximate
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
            print("[GitManager] checkout: SSH not connected — HEAD updated but working tree may be stale. Connect SSH for full checkout.")
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
        
        // Validate branch name to prevent path traversal
        guard !name.contains("..") && !name.contains("/") && !name.isEmpty else {
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
        
        // No SSH connection available
        throw GitManagerError.sshNotConnected
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
        
        // No SSH connection available
        throw GitManagerError.sshNotConnected
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
            try? FileManager.default.removeItem(at: filePath)
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
            try? FileManager.default.removeItem(at: filePath)
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
        // No SSH connection — cannot fetch from remote
        throw GitManagerError.sshNotConnected
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
        var content = (try? String(contentsOf: configPath, encoding: .utf8)) ?? ""
        
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
    
    // MARK: - Missing Functionality TODOs
    
    // TODO: Git blame/annotate
    // - func blame(file: String) async throws -> [BlameLine]
    // - Show line-by-line commit information for a file
    
    // TODO: Tag management
    // - func listTags() async throws -> [GitTag]
    // - func createTag(name: String, message: String?) async throws
    // - func deleteTag(name: String) async throws
    // - func pushTag(name: String) async throws
    
    // TODO: Revert commit
    // - func revertCommit(sha: String) async throws
    // - Create a new commit that undoes a previous commit
    
    // TODO: Cherry-pick
    // - func cherryPick(sha: String) async throws
    // - Apply changes from a specific commit to current branch
}
