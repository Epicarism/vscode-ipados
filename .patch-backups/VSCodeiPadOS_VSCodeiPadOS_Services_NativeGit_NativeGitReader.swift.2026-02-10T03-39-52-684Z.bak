//
//  NativeGitReader.swift
//  VSCodeiPadOS
//
//  Native Swift git repository reader - parses .git directory directly
//  Works offline without git binary (iOS compatible)
//

import Foundation
import Compression

// MARK: - Git Object Types

enum GitObjectType: String {
    case commit
    case tree
    case blob
    case tag
}

struct GitObject {
    let type: GitObjectType
    let size: Int
    let data: Data
}

// MARK: - Native Git Reader

class NativeGitReader {
    let repoURL: URL
    let gitDir: URL
    
    private var indexCache: GitIndex?
    private var headCache: String?
    
    init?(repositoryURL: URL) {
        self.repoURL = repositoryURL
        self.gitDir = repositoryURL.appendingPathComponent(".git")
        
        // Verify .git directory exists
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: gitDir.path, isDirectory: &isDir),
              isDir.boolValue else {
            return nil
        }
    }
    
    // MARK: - HEAD & Current Branch
    
    /// Read current branch name from .git/HEAD
    func currentBranch() -> String? {
        let headFile = gitDir.appendingPathComponent("HEAD")
        guard let content = try? String(contentsOf: headFile, encoding: .utf8) else {
            return nil
        }
        
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // HEAD can be:
        // 1. "ref: refs/heads/branch-name" (normal)
        // 2. A raw SHA (detached HEAD)
        if trimmed.hasPrefix("ref: refs/heads/") {
            return String(trimmed.dropFirst("ref: refs/heads/".count))
        } else if trimmed.hasPrefix("ref: ") {
            // Other ref type
            return String(trimmed.dropFirst("ref: ".count))
        } else {
            // Detached HEAD - return short SHA
            return String(trimmed.prefix(7)) + " (detached)"
        }
    }
    
    /// Get the SHA that HEAD points to
    func headSHA() -> String? {
        let headFile = gitDir.appendingPathComponent("HEAD")
        guard let content = try? String(contentsOf: headFile, encoding: .utf8) else {
            return nil
        }
        
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.hasPrefix("ref: ") {
            // Resolve the reference
            let refPath = String(trimmed.dropFirst("ref: ".count))
            return resolveRef(refPath)
        } else {
            // Direct SHA
            return trimmed
        }
    }
    
    // MARK: - Branches
    
    /// List all local branches from .git/refs/heads/
    func localBranches() -> [String] {
        let headsDir = gitDir.appendingPathComponent("refs/heads")
        return listRefsRecursively(at: headsDir, prefix: "")
    }
    
    /// List all remote branches from .git/refs/remotes/
    func remoteBranches() -> [(remote: String, branch: String)] {
        let remotesDir = gitDir.appendingPathComponent("refs/remotes")
        var results: [(String, String)] = []
        
        guard let remotes = try? FileManager.default.contentsOfDirectory(atPath: remotesDir.path) else {
            return []
        }
        
        for remote in remotes {
            let remoteDir = remotesDir.appendingPathComponent(remote)
            let branches = listRefsRecursively(at: remoteDir, prefix: "")
            for branch in branches where branch != "HEAD" {
                results.append((remote, branch))
            }
        }
        
        return results
    }
    
    private func listRefsRecursively(at url: URL, prefix: String) -> [String] {
        var results: [String] = []
        
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path) else {
            return []
        }
        
        for item in contents {
            let itemURL = url.appendingPathComponent(item)
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir)
            
            let fullName = prefix.isEmpty ? item : "\(prefix)/\(item)"
            
            if isDir.boolValue {
                results.append(contentsOf: listRefsRecursively(at: itemURL, prefix: fullName))
            } else {
                results.append(fullName)
            }
        }
        
        return results
    }
    
    // MARK: - Reference Resolution
    
    /// Resolve a ref path (like refs/heads/main) to a SHA
    func resolveRef(_ refPath: String) -> String? {
        // First check loose refs
        let refFile = gitDir.appendingPathComponent(refPath)
        if let content = try? String(contentsOf: refFile, encoding: .utf8) {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Check packed-refs
        return resolvePackedRef(refPath)
    }
    
    private func resolvePackedRef(_ refPath: String) -> String? {
        let packedRefsFile = gitDir.appendingPathComponent("packed-refs")
        guard let content = try? String(contentsOf: packedRefsFile, encoding: .utf8) else {
            return nil
        }
        
        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") || trimmed.hasPrefix("^") {
                continue
            }
            
            let parts = trimmed.split(separator: " ", maxSplits: 1)
            if parts.count == 2, String(parts[1]) == refPath {
                return String(parts[0])
            }
        }
        
        return nil
    }
    
    // MARK: - Commit Parsing
    
    /// Parse a commit object by SHA
    func parseCommit(sha: String) -> GitCommitInfo? {
        guard let object = readObject(sha: sha),
              object.type == .commit,
              let content = String(data: object.data, encoding: .utf8) else {
            return nil
        }
        
        return GitCommitInfo.parse(sha: sha, content: content)
    }
    
    /// Get recent commits from HEAD
    func recentCommits(count: Int = 20) -> [GitCommitInfo] {
        guard let headSha = headSHA() else { return [] }
        
        var commits: [GitCommitInfo] = []
        var currentSha: String? = headSha
        
        while let sha = currentSha, commits.count < count {
            guard let commit = parseCommit(sha: sha) else { break }
            commits.append(commit)
            currentSha = commit.parentSHA
        }
        
        return commits
    }
    
    // MARK: - Object Storage
    
    /// Read a git object by SHA (from loose objects or pack files)
    func readObject(sha: String) -> GitObject? {
        // First try loose objects
        if let obj = readLooseObject(sha: sha) {
            return obj
        }
        
        // Then try pack files
        return readPackedObject(sha: sha)
    }
    
    private func readLooseObject(sha: String) -> GitObject? {
        guard sha.count >= 2 else { return nil }
        
        let prefix = String(sha.prefix(2))
        let suffix = String(sha.dropFirst(2))
        let objectPath = gitDir
            .appendingPathComponent("objects")
            .appendingPathComponent(prefix)
            .appendingPathComponent(suffix)
        
        guard let compressedData = try? Data(contentsOf: objectPath) else {
            return nil
        }
        
        // Git objects are zlib compressed
        guard let decompressed = decompressZlib(compressedData) else {
            return nil
        }
        
        return parseGitObject(data: decompressed)
    }
    
    private func readPackedObject(sha: String) -> GitObject? {
        // Pack file reading is complex - for now return nil
        // Full implementation would:
        // 1. Read .git/objects/pack/*.idx files
        // 2. Find SHA in index
        // 3. Read corresponding .pack file
        // 4. Handle delta compression
        
        // For MVP, rely on loose objects + SSH fallback for packed repos
        return nil
    }
    
    private func parseGitObject(data: Data) -> GitObject? {
        // Git object format: "type size\0content"
        guard let nullIndex = data.firstIndex(of: 0) else { return nil }
        
        let headerData = data[..<nullIndex]
        guard let header = String(data: headerData, encoding: .utf8) else { return nil }
        
        let parts = header.split(separator: " ")
        guard parts.count == 2,
              let type = GitObjectType(rawValue: String(parts[0])),
              let size = Int(parts[1]) else {
            return nil
        }
        
        let contentStart = data.index(after: nullIndex)
        let content = data[contentStart...]
        
        return GitObject(type: type, size: size, data: Data(content))
    }
    
    // MARK: - Index (Staging Area)
    
    /// Read .git/index to get staged files
    func readIndex() -> GitIndex? {
        let indexPath = gitDir.appendingPathComponent("index")
        guard let data = try? Data(contentsOf: indexPath) else {
            return nil
        }
        
        return GitIndex.parse(data: data)
    }
    
    // MARK: - Working Directory Status
    
    /// Compare working directory to index and HEAD to determine status
    func status() -> [GitFileStatus] {
        var statuses: [GitFileStatus] = []
        
        // Get index entries
        let index = readIndex()
        let indexEntries = index?.entries ?? []
        let indexPaths = Set(indexEntries.map { $0.path })
        
        // Get HEAD tree entries
        let headTree = headTreeEntries()
        let headPaths = Set(headTree.keys)
        
        // Get working directory files
        let workingFiles = scanWorkingDirectory()
        let workingPaths = Set(workingFiles.keys)
        
        // Determine status for each file
        let allPaths = indexPaths.union(headPaths).union(workingPaths)
        
        for path in allPaths {
            let inIndex = indexPaths.contains(path)
            let inHead = headPaths.contains(path)
            let inWorking = workingPaths.contains(path)
            
            let indexEntry = indexEntries.first { $0.path == path }
            let headSha = headTree[path]
            let workingInfo = workingFiles[path]
            
            // Determine staged status (index vs HEAD)
            var stagedStatus: GitStatusType? = nil
            if inIndex && !inHead {
                stagedStatus = .added
            } else if !inIndex && inHead {
                stagedStatus = .deleted
            } else if inIndex && inHead {
                if indexEntry?.sha != headSha {
                    stagedStatus = .modified
                }
            }
            
            // Determine working status (working dir vs index)
            var workingStatus: GitStatusType? = nil
            if inWorking && !inIndex && !inHead {
                workingStatus = .untracked
            } else if !inWorking && inIndex {
                workingStatus = .deleted
            } else if inWorking && inIndex {
                // Compare working file to index
                if let entry = indexEntry, let info = workingInfo {
                    if info.mtime != entry.mtime || info.size != entry.size {
                        // File changed - verify with content hash if needed
                        workingStatus = .modified
                    }
                }
            }
            
            if stagedStatus != nil || workingStatus != nil {
                statuses.append(GitFileStatus(
                    path: path,
                    staged: stagedStatus,
                    working: workingStatus
                ))
            }
        }
        
        return statuses.sorted { $0.path < $1.path }
    }
    
    /// Get tree entries from HEAD commit
    private func headTreeEntries() -> [String: String] {
        guard let headSha = headSHA(),
              let commit = parseCommit(sha: headSha),
              let treeSha = commit.treeSHA else {
            return [:]
        }
        
        return flattenTree(sha: treeSha, prefix: "")
    }
    
    private func flattenTree(sha: String, prefix: String) -> [String: String] {
        guard let object = readObject(sha: sha),
              object.type == .tree else {
            return [:]
        }
        
        var results: [String: String] = [:]
        let entries = parseTreeEntries(data: object.data)
        
        for entry in entries {
            let fullPath = prefix.isEmpty ? entry.name : "\(prefix)/\(entry.name)"
            
            if entry.mode.hasPrefix("40") { // Directory (tree)
                let subtree = flattenTree(sha: entry.sha, prefix: fullPath)
                results.merge(subtree) { _, new in new }
            } else {
                results[fullPath] = entry.sha
            }
        }
        
        return results
    }
    
    private func parseTreeEntries(data: Data) -> [(mode: String, name: String, sha: String)] {
        var entries: [(String, String, String)] = []
        var offset = 0
        
        while offset < data.count {
            // Find space after mode
            guard let spaceIndex = data[offset...].firstIndex(of: 0x20) else { break }
            let modeData = data[offset..<spaceIndex]
            guard let mode = String(data: modeData, encoding: .ascii) else { break }
            
            // Find null after name
            let nameStart = spaceIndex + 1
            guard let nullIndex = data[nameStart...].firstIndex(of: 0) else { break }
            let nameData = data[nameStart..<nullIndex]
            guard let name = String(data: nameData, encoding: .utf8) else { break }
            
            // Read 20-byte SHA
            let shaStart = nullIndex + 1
            let shaEnd = shaStart + 20
            guard shaEnd <= data.count else { break }
            let shaData = data[shaStart..<shaEnd]
            let sha = shaData.map { String(format: "%02x", $0) }.joined()
            
            entries.append((mode, name, sha))
            offset = shaEnd
        }
        
        return entries
    }
    
    /// Scan working directory for files
    private func scanWorkingDirectory() -> [String: (mtime: Date, size: Int)] {
        var results: [String: (Date, Int)] = [:]
        
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: repoURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return [:]
        }
        
        while let url = enumerator.nextObject() as? URL {
            // Skip .git directory
            if url.path.contains("/.git/") || url.lastPathComponent == ".git" {
                continue
            }
            
            do {
                let values = try url.resourceValues(forKeys: [.isDirectoryKey, .contentModificationDateKey, .fileSizeKey])
                
                if values.isDirectory == true {
                    continue
                }
                
                let relativePath = url.path.replacingOccurrences(of: repoURL.path + "/", with: "")
                let mtime = values.contentModificationDate ?? Date.distantPast
                let size = values.fileSize ?? 0
                
                results[relativePath] = (mtime, size)
            } catch {
                continue
            }
        }
        
        return results
    }
    
    // MARK: - Zlib Decompression (using iOS Compression framework)
    
    private func decompressZlib(_ data: Data) -> Data? {
        // Git uses zlib compression (DEFLATE with zlib header)
        // iOS Compression framework supports COMPRESSION_ZLIB
        
        guard data.count > 2 else { return nil }
        
        // Zlib format: 1 byte CMF + 1 byte FLG + compressed data + 4 byte Adler-32
        // We need to skip the 2-byte header for raw DEFLATE
        let sourceData: Data
        if data[0] == 0x78 { // Zlib header present
            // Skip zlib header (2 bytes) and Adler-32 checksum (last 4 bytes)
            if data.count > 6 {
                sourceData = data.dropFirst(2).dropLast(4)
            } else {
                sourceData = data.dropFirst(2)
            }
        } else {
            sourceData = data
        }
        
        // Allocate destination buffer (git objects are usually small, but can be large)
        let destinationBufferSize = max(sourceData.count * 10, 65536)
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
        defer { destinationBuffer.deallocate() }
        
        let decompressedSize = sourceData.withUnsafeBytes { sourcePtr -> Int in
            guard let sourceBaseAddress = sourcePtr.baseAddress else { return 0 }
            
            return compression_decode_buffer(
                destinationBuffer,
                destinationBufferSize,
                sourceBaseAddress.assumingMemoryBound(to: UInt8.self),
                sourceData.count,
                nil,
                COMPRESSION_ZLIB
            )
        }
        
        guard decompressedSize > 0 else {
            // Try with raw DEFLATE if zlib failed
            return decompressRawDeflate(sourceData)
        }
        
        return Data(bytes: destinationBuffer, count: decompressedSize)
    }
    
    private func decompressRawDeflate(_ data: Data) -> Data? {
        let destinationBufferSize = max(data.count * 10, 65536)
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
        defer { destinationBuffer.deallocate() }
        
        let decompressedSize = data.withUnsafeBytes { sourcePtr -> Int in
            guard let sourceBaseAddress = sourcePtr.baseAddress else { return 0 }
            
            return compression_decode_buffer(
                destinationBuffer,
                destinationBufferSize,
                sourceBaseAddress.assumingMemoryBound(to: UInt8.self),
                data.count,
                nil,
                COMPRESSION_LZFSE // Try LZFSE as fallback
            )
        }
        
        guard decompressedSize > 0 else { return nil }
        return Data(bytes: destinationBuffer, count: decompressedSize)
    }
}

// MARK: - Supporting Types

struct GitCommitInfo {
    let sha: String
    let treeSHA: String?
    let parentSHA: String?
    let author: String
    let authorEmail: String
    let authorDate: Date
    let committer: String
    let committerEmail: String
    let committerDate: Date
    let message: String
    
    static func parse(sha: String, content: String) -> GitCommitInfo? {
        var treeSHA: String?
        var parentSHA: String?
        var author = "Unknown"
        var authorEmail = ""
        var authorDate = Date()
        var committer = "Unknown"
        var committerEmail = ""
        var committerDate = Date()
        var message = ""
        
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
            
            if line.hasPrefix("tree ") {
                treeSHA = String(line.dropFirst(5))
            } else if line.hasPrefix("parent ") {
                // Take first parent only
                if parentSHA == nil {
                    parentSHA = String(line.dropFirst(7))
                }
            } else if line.hasPrefix("author ") {
                let parsed = parseIdentity(String(line.dropFirst(7)))
                author = parsed.name
                authorEmail = parsed.email
                authorDate = parsed.date
            } else if line.hasPrefix("committer ") {
                let parsed = parseIdentity(String(line.dropFirst(10)))
                committer = parsed.name
                committerEmail = parsed.email
                committerDate = parsed.date
            }
        }
        
        message = messageLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        
        return GitCommitInfo(
            sha: sha,
            treeSHA: treeSHA,
            parentSHA: parentSHA,
            author: author,
            authorEmail: authorEmail,
            authorDate: authorDate,
            committer: committer,
            committerEmail: committerEmail,
            committerDate: committerDate,
            message: message
        )
    }
    
    private static func parseIdentity(_ str: String) -> (name: String, email: String, date: Date) {
        // Format: "Name <email> timestamp timezone"
        // Example: "John Doe <john@example.com> 1234567890 +0000"
        
        guard let emailStart = str.firstIndex(of: "<"),
              let emailEnd = str.firstIndex(of: ">") else {
            return (str, "", Date())
        }
        
        let name = String(str[..<emailStart]).trimmingCharacters(in: .whitespaces)
        let email = String(str[str.index(after: emailStart)..<emailEnd])
        
        // Parse timestamp
        let afterEmail = str[str.index(after: emailEnd)...]
        let parts = afterEmail.split(separator: " ")
        var date = Date()
        if let timestampStr = parts.first, let timestamp = TimeInterval(timestampStr) {
            date = Date(timeIntervalSince1970: timestamp)
        }
        
        return (name, email, date)
    }
}

enum GitStatusType {
    case modified
    case added
    case deleted
    case renamed
    case copied
    case untracked
    case ignored
}

struct GitFileStatus {
    let path: String
    let staged: GitStatusType?     // Status in index vs HEAD
    let working: GitStatusType?    // Status in working dir vs index
}

// MARK: - Git Index Parser

struct GitIndexEntry {
    let ctime: Date
    let mtime: Date
    let dev: UInt32
    let ino: UInt32
    let mode: UInt32
    let uid: UInt32
    let gid: UInt32
    let size: Int
    let sha: String
    let flags: UInt16
    let path: String
}

struct GitIndex {
    let version: UInt32
    let entries: [GitIndexEntry]
    
    static func parse(data: Data) -> GitIndex? {
        guard data.count >= 12 else { return nil }
        
        // Check signature "DIRC"
        let signature = String(data: data[0..<4], encoding: .ascii)
        guard signature == "DIRC" else { return nil }
        
        // Read version (4 bytes, big endian)
        let version = data[4..<8].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        guard version >= 2 && version <= 4 else { return nil }
        
        // Read entry count
        let entryCount = data[8..<12].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        
        // Parse entries
        var entries: [GitIndexEntry] = []
        var offset = 12
        
        for _ in 0..<entryCount {
            guard offset + 62 <= data.count else { break }
            
            // Read fixed-size fields (62 bytes for v2)
            let ctimeSec = data[offset..<offset+4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            let ctimeNano = data[offset+4..<offset+8].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            let mtimeSec = data[offset+8..<offset+12].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            let mtimeNano = data[offset+12..<offset+16].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            let dev = data[offset+16..<offset+20].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            let ino = data[offset+20..<offset+24].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            let mode = data[offset+24..<offset+28].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            let uid = data[offset+28..<offset+32].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            let gid = data[offset+32..<offset+36].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            let size = data[offset+36..<offset+40].withUnsafeBytes { Int($0.load(as: UInt32.self).bigEndian) }
            
            // SHA (20 bytes)
            let shaData = data[offset+40..<offset+60]
            let sha = shaData.map { String(format: "%02x", $0) }.joined()
            
            // Flags (2 bytes)
            let flags = data[offset+60..<offset+62].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
            let nameLen = Int(flags & 0x0FFF)
            
            offset += 62
            
            // Extended flags for v3+
            if version >= 3 && (flags & 0x4000) != 0 {
                offset += 2
            }
            
            // Read path name
            let pathEnd: Int
            if nameLen < 0xFFF {
                pathEnd = offset + nameLen
            } else {
                // Name length is >= 0xFFF, find null terminator
                if let nullIdx = data[offset...].firstIndex(of: 0) {
                    pathEnd = nullIdx
                } else {
                    break
                }
            }
            
            guard pathEnd <= data.count else { break }
            let pathData = data[offset..<pathEnd]
            guard let path = String(data: pathData, encoding: .utf8) else { break }
            
            // Entries are padded to 8 bytes
            let entryLen = 62 + path.utf8.count + 1 // +1 for null terminator
            let padding = (8 - (entryLen % 8)) % 8
            offset = pathEnd + 1 + padding
            
            let ctime = Date(timeIntervalSince1970: Double(ctimeSec) + Double(ctimeNano) / 1_000_000_000)
            let mtime = Date(timeIntervalSince1970: Double(mtimeSec) + Double(mtimeNano) / 1_000_000_000)
            
            entries.append(GitIndexEntry(
                ctime: ctime,
                mtime: mtime,
                dev: dev,
                ino: ino,
                mode: mode,
                uid: uid,
                gid: gid,
                size: size,
                sha: sha,
                flags: flags,
                path: path
            ))
        }
        
        return GitIndex(version: version, entries: entries)
    }
}
