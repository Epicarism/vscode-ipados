//
//  GitManager.swift
//  VSCodeiPadOS
//
//  Minimal Git Manager - stub implementation
//  TODO: Implement real git operations via SSH
//

import SwiftUI
import Combine

// MARK: - Git Errors

enum GitManagerError: Error, LocalizedError {
    case noRepository
    case gitExecutableNotFound
    case commandFailed(args: [String], exitCode: Int32, message: String)
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
            return "git \(args.joined(separator: " ")) failed (\(exitCode)): \(message)"
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
    let id = UUID()
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
    let id = UUID()
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
class GitManager: ObservableObject {
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
            guard let working = status.working else { return nil }
            return GitFileChange(path: status.path, kind: mapStatusType(working), staged: false)
        }
        
        untrackedFiles = fileStatuses.compactMap { status -> GitFileChange? in
            guard status.working == .untracked else { return nil }
            return GitFileChange(path: status.path, kind: .untracked, staged: false)
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
        guard let dir = workingDirectory else {
            throw GitManagerError.noRepository
        }
        guard let writer = nativeWriter else {
            throw GitManagerError.invalidRepository
        }
        let sha = try writer.commit(message: message)
        await refresh()
    }
    
    func checkout(branch: String) async throws {
        // Local branch checkout via ref file manipulation
        guard let repoURL = workingDirectory else {
            throw GitManagerError.noRepository
        }
        
        let refPath = repoURL.appendingPathComponent(".git/refs/heads/\(branch)")
        guard FileManager.default.fileExists(atPath: refPath.path) else {
            throw GitManagerError.invalidRepository
        }
        
        // Update HEAD to point to the branch
        let headPath = repoURL.appendingPathComponent(".git/HEAD")
        try "ref: refs/heads/\(branch)\n".write(to: headPath, atomically: true, encoding: .utf8)
        
        currentBranch = branch
        await refresh()
    }
    
    func createBranch(name: String) async throws {
        guard let repoURL = workingDirectory,
              let reader = nativeReader,
              let headSHA = reader.headSHA() else {
            throw GitManagerError.invalidRepository
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
        
        let refPath = repoURL.appendingPathComponent(".git/refs/heads/\(name)")
        try FileManager.default.removeItem(at: refPath)
        
        await refresh()
    }
    
    func pull() async throws {
        // Pull requires network access to GitHub API
        // For now, mark as not available - requires GitHub token setup
        guard KeychainManager.shared.getGitHubToken() != nil else {
            throw GitManagerError.sshNotConnected
        }
        
        // TODO: Implement full pull via GitHub API when GitHubAPIClient is integrated
        throw GitManagerError.notAvailableOnIOS
    }
    
    func push() async throws {
        // Push requires network access to GitHub API
        guard KeychainManager.shared.getGitHubToken() != nil else {
            throw GitManagerError.sshNotConnected
        }
        
        // TODO: Implement full push via GitHub API when GitHubAPIClient is integrated
        throw GitManagerError.notAvailableOnIOS
    }
    
    func stashPush(message: String?) async throws {
        // Stash not implemented for native git
        throw GitManagerError.notAvailableOnIOS
    }
    
    func stashPop(index: Int) async throws {
        throw GitManagerError.notAvailableOnIOS
    }
    
    func stashDrop(index: Int) async throws {
        throw GitManagerError.notAvailableOnIOS
    }
    
    func discard(file: String) async throws {
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
        
        await refresh()
    }
    
    func discardAll() async throws {
        // Discard all changes by restoring each file from HEAD
        for change in unstagedChanges {
            try await discard(file: change.path)
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
        // Fetch requires network - same as pull
        try await pull()
    }
    
    /// Alias for lastError for compatibility
    var error: String? {
        return lastError
    }
}
