//
//  SSHGitClient.swift
//  VSCodeiPadOS
//
//  SSH-based git client - runs git commands on remote servers
//  Used when native git reading isn't sufficient (push/pull/clone)
//

import Foundation
import NIO
import NIOSSH

// MARK: - SSH Git Client

class SSHGitClient {
    private let sshManager: SSHManager
    private var outputBuffer = ""
    private var errorBuffer = ""
    private var commandCompletion: ((Result<String, Error>) -> Void)?
    
    init(sshManager: SSHManager) {
        self.sshManager = sshManager
    }
    
    // MARK: - Git Commands
    
    /// Run git status and parse output
    func status(path: String) async throws -> SSHGitStatus {
        let output = try await runGitCommand(["status", "--porcelain=v2", "--branch"], in: path)
        return SSHGitStatus.parse(output: output)
    }
    
    /// Get current branch
    func currentBranch(path: String) async throws -> String {
        let output = try await runGitCommand(["branch", "--show-current"], in: path)
        let branch = output.trimmingCharacters(in: .whitespacesAndNewlines)
        return branch.isEmpty ? "HEAD" : branch
    }
    
    /// List all branches
    func branches(path: String) async throws -> [SSHGitBranch] {
        let output = try await runGitCommand(["branch", "-a", "--format=%(refname:short)|%(objectname:short)|%(upstream:short)|%(HEAD)"], in: path)
        
        var branches: [SSHGitBranch] = []
        for line in output.components(separatedBy: "\n") where !line.isEmpty {
            let parts = line.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            guard parts.count >= 4 else { continue }
            
            let name = parts[0]
            let sha = parts[1]
            let upstream = parts[2].isEmpty ? nil : parts[2]
            let isCurrent = parts[3] == "*"
            let isRemote = name.hasPrefix("remotes/") || name.contains("/")
            
            branches.append(SSHGitBranch(
                name: name,
                sha: sha,
                upstream: upstream,
                isCurrent: isCurrent,
                isRemote: isRemote
            ))
        }
        
        return branches
    }
    
    /// Get recent commits
    func log(path: String, count: Int = 20) async throws -> [SSHGitCommit] {
        let format = "%H|%an|%ae|%at|%s"
        let output = try await runGitCommand(["log", "-\(count)", "--format=\(format)"], in: path)
        
        var commits: [SSHGitCommit] = []
        for line in output.components(separatedBy: "\n") where !line.isEmpty {
            let parts = line.split(separator: "|", maxSplits: 4, omittingEmptySubsequences: false).map(String.init)
            guard parts.count >= 5 else { continue }
            
            let sha = parts[0]
            let author = parts[1]
            let email = parts[2]
            let timestamp = TimeInterval(parts[3]) ?? 0
            let message = parts[4]
            
            commits.append(SSHGitCommit(
                sha: sha,
                author: author,
                email: email,
                date: Date(timeIntervalSince1970: timestamp),
                message: message
            ))
        }
        
        return commits
    }
    
    /// Stage a file
    func stage(file: String, in path: String) async throws {
        _ = try await runGitCommand(["add", file], in: path)
    }
    
    /// Stage all changes
    func stageAll(in path: String) async throws {
        _ = try await runGitCommand(["add", "-A"], in: path)
    }
    
    /// Unstage a file
    func unstage(file: String, in path: String) async throws {
        _ = try await runGitCommand(["reset", "HEAD", file], in: path)
    }
    
    /// Commit staged changes
    func commit(message: String, in path: String) async throws -> String {
        let output = try await runGitCommand(["commit", "-m", message], in: path)
        
        // Extract commit SHA from output
        // Format: "[branch sha] message"
        if let match = output.firstMatch(of: /\[\w+ ([a-f0-9]+)\]/) {
            return String(match.1)
        }
        return ""
    }
    
    /// Checkout a branch
    func checkout(branch: String, in path: String) async throws {
        _ = try await runGitCommand(["checkout", branch], in: path)
    }
    
    /// Create a new branch
    func createBranch(name: String, checkout: Bool, in path: String) async throws {
        if checkout {
            _ = try await runGitCommand(["checkout", "-b", name], in: path)
        } else {
            _ = try await runGitCommand(["branch", name], in: path)
        }
    }
    
    /// Delete a branch
    func deleteBranch(name: String, force: Bool, in path: String) async throws {
        let flag = force ? "-D" : "-d"
        _ = try await runGitCommand(["branch", flag, name], in: path)
    }
    
    /// Pull from remote
    func pull(remote: String = "origin", branch: String? = nil, in path: String) async throws -> String {
        var args = ["pull", remote]
        if let branch = branch {
            args.append(branch)
        }
        return try await runGitCommand(args, in: path)
    }
    
    /// Push to remote
    func push(remote: String = "origin", branch: String? = nil, force: Bool = false, in path: String) async throws -> String {
        var args = ["push"]
        if force {
            args.append("--force")
        }
        args.append(remote)
        if let branch = branch {
            args.append(branch)
        }
        return try await runGitCommand(args, in: path)
    }
    
    /// Fetch from remote
    func fetch(remote: String = "origin", prune: Bool = false, in path: String) async throws {
        var args = ["fetch", remote]
        if prune {
            args.append("--prune")
        }
        _ = try await runGitCommand(args, in: path)
    }
    
    /// Discard changes in a file
    func discardChanges(file: String, in path: String) async throws {
        _ = try await runGitCommand(["checkout", "--", file], in: path)
    }
    
    /// Get diff for a file
    func diff(file: String? = nil, staged: Bool = false, in path: String) async throws -> String {
        var args = ["diff"]
        if staged {
            args.append("--cached")
        }
        if let file = file {
            args.append("--")
            args.append(file)
        }
        return try await runGitCommand(args, in: path)
    }
    
    /// Stash changes
    func stash(message: String? = nil, in path: String) async throws {
        var args = ["stash", "push"]
        if let message = message {
            args.append("-m")
            args.append(message)
        }
        _ = try await runGitCommand(args, in: path)
    }
    
    /// List stashes
    func stashList(in path: String) async throws -> [SSHGitStash] {
        let output = try await runGitCommand(["stash", "list", "--format=%gd|%s|%at"], in: path)
        
        var stashes: [SSHGitStash] = []
        for line in output.components(separatedBy: "\n") where !line.isEmpty {
            let parts = line.split(separator: "|", maxSplits: 2).map(String.init)
            guard parts.count >= 3 else { continue }
            
            let ref = parts[0] // stash@{0}
            let message = parts[1]
            let timestamp = TimeInterval(parts[2]) ?? 0
            
            // Extract index from ref
            let index: Int
            if let match = ref.firstMatch(of: /stash@\{(\d+)\}/) {
                index = Int(match.1) ?? 0
            } else {
                index = stashes.count
            }
            
            stashes.append(SSHGitStash(
                index: index,
                message: message,
                date: Date(timeIntervalSince1970: timestamp)
            ))
        }
        
        return stashes
    }
    
    /// Apply stash
    func stashApply(index: Int, in path: String) async throws {
        _ = try await runGitCommand(["stash", "apply", "stash@{\(index)}"], in: path)
    }
    
    /// Pop stash
    func stashPop(index: Int, in path: String) async throws {
        _ = try await runGitCommand(["stash", "pop", "stash@{\(index)}"], in: path)
    }
    
    /// Drop stash
    func stashDrop(index: Int, in path: String) async throws {
        _ = try await runGitCommand(["stash", "drop", "stash@{\(index)}"], in: path)
    }
    
    // MARK: - Command Execution
    
    private func runGitCommand(_ args: [String], in path: String) async throws -> String {
        guard sshManager.isConnected else {
            throw SSHGitError.notConnected
        }
        
        // Build command with proper escaping
        let escapedArgs = args.map { escapeShellArg($0) }
        let command = "cd \(escapeShellArg(path)) && git \(escapedArgs.joined(separator: " "))"
        
        return try await withCheckedThrowingContinuation { continuation in
            self.outputBuffer = ""
            self.errorBuffer = ""
            
            // Set up completion handler
            self.commandCompletion = { result in
                continuation.resume(with: result)
            }
            
            // Send command
            sshManager.send(command: command)
            
            // Set timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
                if let completion = self?.commandCompletion {
                    self?.commandCompletion = nil
                    completion(.failure(SSHGitError.timeout))
                }
            }
        }
    }
    
    private func escapeShellArg(_ arg: String) -> String {
        // Simple shell escaping - wrap in single quotes and escape internal single quotes
        let escaped = arg.replacingOccurrences(of: "'", with: "'\\''")
        return "'\(escaped)'"
    }
    
    // MARK: - SSH Output Handling
    
    /// Call this when SSH output is received
    func handleOutput(_ text: String) {
        outputBuffer += text
        
        // Check for command completion (prompt return)
        // This is a simple heuristic - real implementation would use markers
        if text.contains("$ ") || text.contains("# ") {
            completeCommand()
        }
    }
    
    /// Call this when SSH error is received
    func handleError(_ text: String) {
        errorBuffer += text
    }
    
    private func completeCommand() {
        guard let completion = commandCompletion else { return }
        commandCompletion = nil
        
        if !errorBuffer.isEmpty && errorBuffer.contains("fatal:") {
            completion(.failure(SSHGitError.commandFailed(errorBuffer)))
        } else {
            completion(.success(outputBuffer))
        }
    }
}

// MARK: - SSH Git Types

enum SSHGitError: Error, LocalizedError {
    case notConnected
    case timeout
    case commandFailed(String)
    case parseError(String)
    
    var errorDescription: String? {
        switch self {
        case .notConnected: return "Not connected to SSH server"
        case .timeout: return "Git command timed out"
        case .commandFailed(let msg): return "Git error: \(msg)"
        case .parseError(let msg): return "Parse error: \(msg)"
        }
    }
}

struct SSHGitStatus {
    var branch: String = "HEAD"
    var upstream: String?
    var ahead: Int = 0
    var behind: Int = 0
    var staged: [SSHGitFileChange] = []
    var unstaged: [SSHGitFileChange] = []
    var untracked: [String] = []
    var conflicted: [String] = []
    
    static func parse(output: String) -> SSHGitStatus {
        var status = SSHGitStatus()
        
        for line in output.components(separatedBy: "\n") where !line.isEmpty {
            if line.hasPrefix("# branch.head ") {
                status.branch = String(line.dropFirst(14))
            } else if line.hasPrefix("# branch.upstream ") {
                status.upstream = String(line.dropFirst(18))
            } else if line.hasPrefix("# branch.ab ") {
                // Format: # branch.ab +N -M
                let parts = line.dropFirst(12).split(separator: " ")
                if parts.count >= 2 {
                    status.ahead = Int(parts[0].dropFirst()) ?? 0  // +N
                    status.behind = Int(parts[1].dropFirst()) ?? 0 // -M
                }
            } else if line.hasPrefix("1 ") || line.hasPrefix("2 ") {
                // Changed entry
                // Format: 1 XY sub mH mI mW hH hI path
                // or:     2 XY sub mH mI mW hH hI X score path\torigPath
                let parts = line.split(separator: " ", maxSplits: 8)
                guard parts.count >= 9 else { continue }
                
                let xy = String(parts[1])
                let path = String(parts[8]).components(separatedBy: "\t").first ?? String(parts[8])
                
                let indexStatus = xy.first ?? " "
                let workingStatus = xy.last ?? " "
                
                if indexStatus != "." && indexStatus != " " {
                    status.staged.append(SSHGitFileChange(
                        path: path,
                        status: parseStatusChar(indexStatus)
                    ))
                }
                
                if workingStatus != "." && workingStatus != " " {
                    status.unstaged.append(SSHGitFileChange(
                        path: path,
                        status: parseStatusChar(workingStatus)
                    ))
                }
            } else if line.hasPrefix("? ") {
                // Untracked
                let path = String(line.dropFirst(2))
                status.untracked.append(path)
            } else if line.hasPrefix("u ") {
                // Unmerged/conflicted
                let parts = line.split(separator: " ")
                if let path = parts.last {
                    status.conflicted.append(String(path))
                }
            }
        }
        
        return status
    }
    
    private static func parseStatusChar(_ char: Character) -> SSHGitChangeStatus {
        switch char {
        case "M": return .modified
        case "A": return .added
        case "D": return .deleted
        case "R": return .renamed
        case "C": return .copied
        case "T": return .typeChanged
        case "U": return .unmerged
        default: return .unknown
        }
    }
}

enum SSHGitChangeStatus: String {
    case modified
    case added
    case deleted
    case renamed
    case copied
    case typeChanged
    case unmerged
    case unknown
}

struct SSHGitFileChange {
    let path: String
    let status: SSHGitChangeStatus
}

struct SSHGitBranch {
    let name: String
    let sha: String
    let upstream: String?
    let isCurrent: Bool
    let isRemote: Bool
}

struct SSHGitCommit {
    let sha: String
    let author: String
    let email: String
    let date: Date
    let message: String
}

struct SSHGitStash {
    let index: Int
    let message: String
    let date: Date
}
