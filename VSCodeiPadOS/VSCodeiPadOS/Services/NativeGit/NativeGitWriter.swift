//  NativeGitWriter.swift
//  VSCodeiPadOS
//
//  Minimal native git writer - writes loose objects and updates refs.
//  Supports local commit creation from staged (index) entries.
//

import Foundation
import Compression
import CommonCrypto

final class NativeGitWriter {
    let repoURL: URL
    let gitDir: URL

    init?(repositoryURL: URL) {
        self.repoURL = repositoryURL
        self.gitDir = repositoryURL.appendingPathComponent(".git")

        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: gitDir.path, isDirectory: &isDir), isDir.boolValue else {
            return nil
        }
    }

    // MARK: - Public API

    /// Create a real local commit from the current index.
    /// - Returns: New commit SHA
    func commit(message: String, authorName: String = "VSCodeiPadOS", authorEmail: String = "vscode@localhost") throws -> String {
        // Build tree from stage-0 index entries
        let index = try readIndex()
        let entries = index.entries.filter { entry in
            // Git index stage is stored in flags bits 12-13
            let stage = (entry.flags >> 12) & 0x3
            return stage == 0
        }

        let root = TreeNode()
        for entry in entries {
            insert(entry: entry, into: root)
        }

        let treeSha = try writeTree(node: root)

        // Parent commit = current HEAD (if any)
        let parentSha = try headCommitSHA()

        // Create commit object
        let now = Date()
        let timestamp = Int(now.timeIntervalSince1970)
        let tz = Self.formatTimezone(secondsFromGMT: TimeZone.current.secondsFromGMT(for: now))

        var commitText = ""
        commitText += "tree \(treeSha)\n"
        if let parentSha {
            commitText += "parent \(parentSha)\n"
        }
        commitText += "author \(authorName) <\(authorEmail)> \(timestamp) \(tz)\n"
        commitText += "committer \(authorName) <\(authorEmail)> \(timestamp) \(tz)\n"
        commitText += "\n"
        commitText += message
        if !message.hasSuffix("\n") {
            commitText += "\n"
        }

        let commitSha = try writeObject(type: .commit, content: Data(commitText.utf8))
        try updateHEAD(to: commitSha)
        return commitSha
    }

    // MARK: - Index

    private func readIndex() throws -> GitIndex {
        let indexPath = gitDir.appendingPathComponent("index")
        let data = try Data(contentsOf: indexPath)
        guard let index = GitIndex.parse(data: data) else {
            throw GitManagerError.invalidRepository
        }
        return index
    }

    // MARK: - HEAD / refs

    private func headCommitSHA() throws -> String? {
        let headFile = gitDir.appendingPathComponent("HEAD")
        guard let content = try? String(contentsOf: headFile, encoding: .utf8) else { return nil }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("ref: ") {
            let refPath = String(trimmed.dropFirst("ref: ".count))
            if let sha = resolveRef(refPath) {
                return sha
            }
            return nil
        }

        // Detached HEAD SHA or unborn
        return trimmed.isEmpty ? nil : trimmed
    }

    private func updateHEAD(to commitSHA: String) throws {
        let headFile = gitDir.appendingPathComponent("HEAD")
        let content = (try? String(contentsOf: headFile, encoding: .utf8)) ?? ""
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("ref: ") {
            let refPath = String(trimmed.dropFirst("ref: ".count))
            let refURL = gitDir.appendingPathComponent(refPath)
            try FileManager.default.createDirectory(at: refURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try (commitSHA + "\n").write(to: refURL, atomically: true, encoding: .utf8)
        } else {
            // Detached HEAD
            try (commitSHA + "\n").write(to: headFile, atomically: true, encoding: .utf8)
        }
    }

    private func resolveRef(_ refPath: String) -> String? {
        let refFile = gitDir.appendingPathComponent(refPath)
        if let content = try? String(contentsOf: refFile, encoding: .utf8) {
            let sha = content.trimmingCharacters(in: .whitespacesAndNewlines)
            return sha.isEmpty ? nil : sha
        }
        return resolvePackedRef(refPath)
    }

    private func resolvePackedRef(_ refPath: String) -> String? {
        let packedRefsFile = gitDir.appendingPathComponent("packed-refs")
        guard let content = try? String(contentsOf: packedRefsFile, encoding: .utf8) else { return nil }

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

    private static func formatTimezone(secondsFromGMT: Int) -> String {
        let sign = secondsFromGMT >= 0 ? "+" : "-"
        let absSeconds = abs(secondsFromGMT)
        let hours = absSeconds / 3600
        let minutes = (absSeconds % 3600) / 60
        return String(format: "%@%02d%02d", sign, hours, minutes)
    }

    // MARK: - Tree building

    private final class TreeNode {
        var blobs: [String: (mode: String, sha: String)] = [:]
        var children: [String: TreeNode] = [:]
    }

    private func insert(entry: GitIndexEntry, into root: TreeNode) {
        let parts = entry.path.split(separator: "/").map(String.init)
        guard let last = parts.last else { return }

        var node = root
        if parts.count > 1 {
            for dir in parts.dropLast() {
                if let next = node.children[dir] {
                    node = next
                } else {
                    let new = TreeNode()
                    node.children[dir] = new
                    node = new
                }
            }
        }

        let mode = Self.gitModeString(fromIndexMode: entry.mode)
        node.blobs[last] = (mode: mode, sha: entry.sha)
    }

    private static func gitModeString(fromIndexMode mode: UInt32) -> String {
        // Index mode includes type bits in upper part.
        // We only need canonical tree entry modes.
        let type = mode & 0o170000
        if type == 0o120000 {
            return "120000" // symlink
        }
        if (mode & 0o111) != 0 {
            return "100755"
        }
        return "100644"
    }

    private struct TreeEntry {
        let mode: String
        let name: String
        let sha: String
        let isTree: Bool
    }

    private func writeTree(node: TreeNode) throws -> String {
        var entries: [TreeEntry] = []

        // Children trees first (hashes computed recursively)
        for (name, child) in node.children {
            let childSha = try writeTree(node: child)
            entries.append(TreeEntry(mode: "40000", name: name, sha: childSha, isTree: true))
        }

        // Blobs
        for (name, blob) in node.blobs {
            entries.append(TreeEntry(mode: blob.mode, name: name, sha: blob.sha, isTree: false))
        }

        // Git sorts entries by name, but compares directories as name + '/'
        entries.sort { a, b in
            let aKey = a.name + (a.isTree ? "/" : "")
            let bKey = b.name + (b.isTree ? "/" : "")
            return Self.lexicographicLess(aKey.utf8, bKey.utf8)
        }

        var data = Data()
        for entry in entries {
            data.append(contentsOf: "\(entry.mode) \(entry.name)\u{0}".utf8)
            data.append(contentsOf: try Self.hexToBytes(entry.sha))
        }

        return try writeObject(type: .tree, content: data)
    }

    private static func lexicographicLess(_ a: String.UTF8View, _ b: String.UTF8View) -> Bool {
        var ita = a.makeIterator()
        var itb = b.makeIterator()
        while true {
            let ca = ita.next()
            let cb = itb.next()
            switch (ca, cb) {
            case let (x?, y?):
                if x != y { return x < y }
            case (nil, nil):
                return false
            case (nil, _?):
                return true
            case (_?, nil):
                return false
            }
        }
    }

    // MARK: - Object writing

    private func writeObject(type: GitObjectType, content: Data) throws -> String {
        // Git object format: "type size\0content"
        let header = "\(type.rawValue) \(content.count)\u{0}"
        var store = Data(header.utf8)
        store.append(content)

        let sha = Self.sha1Hex(store)

        // Write loose object if not already present
        let objectDir = gitDir.appendingPathComponent("objects").appendingPathComponent(String(sha.prefix(2)))
        let objectFile = objectDir.appendingPathComponent(String(sha.dropFirst(2)))

        if FileManager.default.fileExists(atPath: objectFile.path) {
            return sha
        }

        try FileManager.default.createDirectory(at: objectDir, withIntermediateDirectories: true)

        let compressed = try Self.compressZlib(store)
        try compressed.write(to: objectFile, options: [.atomic])
        return sha
    }

    private static func sha1Hex(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { ptr in
            _ = CC_SHA1(ptr.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func compressZlib(_ data: Data) throws -> Data {
        // Compression framework needs a destination buffer large enough.
        // Start with a reasonable guess and grow if needed.
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

            // Increase and retry
            destSize *= 2
        }

        throw GitManagerError.invalidRepository
    }

    // MARK: - Staging Operations

    /// Stage a file by adding/updating its entry in the git index
    func stageFile(path: String) throws {
        // Read working directory file
        let fileURL = repoURL.appendingPathComponent(path)
        let fileData = try Data(contentsOf: fileURL)
        
        // Get file attributes
        let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        let mtime = (attrs[.modificationDate] as? Date) ?? Date()
        let size = (attrs[.size] as? Int) ?? fileData.count
        
        // Write blob object and get SHA
        let blobSha = try writeObject(type: .blob, content: fileData)
        
        // Read current index
        var entries = (try? readIndex().entries) ?? []
        
        // Determine file mode
        let mode: UInt32
        if let posixPerms = attrs[.posixPermissions] as? Int, (posixPerms & 0o111) != 0 {
            mode = 0o100755
        } else {
            mode = 0o100644
        }
        
        // Create new entry
        let newEntry = GitIndexEntry(
            ctime: mtime,
            mtime: mtime,
            dev: 0,
            ino: 0,
            mode: mode,
            uid: 0,
            gid: 0,
            size: size,
            sha: blobSha,
            flags: UInt16(min(path.utf8.count, 0xFFF)),
            path: path
        )
        
        // Update or add entry
        if let idx = entries.firstIndex(where: { $0.path == path }) {
            entries[idx] = newEntry
        } else {
            entries.append(newEntry)
        }
        
        // Sort entries by path (git requires sorted index)
        entries.sort { $0.path < $1.path }
        
        // Write updated index
        try writeIndex(entries: entries)
    }
    
    /// Unstage a file by restoring HEAD entry or removing if new file
    func unstageFile(path: String) throws {
        var entries = (try? readIndex().entries) ?? []
        
        // Get HEAD tree entry for this path
        let headSha = headTreeSHA(forPath: path)
        
        if let headSha = headSha {
            // File was in HEAD - restore that entry
            if let idx = entries.firstIndex(where: { $0.path == path }) {
                // Keep most fields but restore SHA from HEAD
                let old = entries[idx]
                let restored = GitIndexEntry(
                    ctime: old.ctime,
                    mtime: old.mtime,
                    dev: old.dev,
                    ino: old.ino,
                    mode: old.mode,
                    uid: old.uid,
                    gid: old.gid,
                    size: old.size,
                    sha: headSha,
                    flags: old.flags,
                    path: path
                )
                entries[idx] = restored
            }
        } else {
            // File was NOT in HEAD (new file) - remove from index
            entries.removeAll { $0.path == path }
        }
        
        try writeIndex(entries: entries)
    }
    
    /// Stage all modified and untracked files
    func stageAll() throws {
        guard let reader = NativeGitReader(repositoryURL: repoURL) else {
            throw GitManagerError.invalidRepository
        }
        
        let statuses = reader.status()
        
        for status in statuses {
            // Stage files that have working directory changes
            if status.working == .modified || status.working == .deleted || status.working == .untracked {
                if status.working == .deleted {
                    // For deleted files, remove from index
                    var entries = (try? readIndex().entries) ?? []
                    entries.removeAll { $0.path == status.path }
                    try writeIndex(entries: entries)
                } else {
                    try stageFile(path: status.path)
                }
            }
        }
    }
    
    /// Get the blob SHA for a path in HEAD tree
    private func headTreeSHA(forPath path: String) -> String? {
        guard let headSha = (try? headCommitSHA()) ?? nil else {
            return nil
        }
        
        guard let reader = NativeGitReader(repositoryURL: repoURL) else {
            return nil
        }
        
        guard let commit = reader.parseCommit(sha: headSha),
              let treeSha = commit.treeSHA else {
            return nil
        }
        
        return blobSHAFromTree(path: path, treeSHA: treeSha, reader: reader)
    }
    
    private func blobSHAFromTree(path: String, treeSHA: String, reader: NativeGitReader) -> String? {
        let components = path.split(separator: "/").map(String.init)
        return blobSHAFromTree(components: components, treeSHA: treeSHA, reader: reader)
    }
    
    private func blobSHAFromTree(components: [String], treeSHA: String, reader: NativeGitReader) -> String? {
        guard !components.isEmpty,
              let treeObj = reader.readObject(sha: treeSHA),
              treeObj.type == .tree else {
            return nil
        }
        
        let entries = parseTreeEntriesForWrite(data: treeObj.data)
        let head = components[0]
        
        if components.count == 1 {
            // Looking for a blob
            return entries.first { $0.name == head && !$0.mode.hasPrefix("40") }?.sha
        } else {
            // Looking for a subtree
            guard let dir = entries.first(where: { $0.name == head && $0.mode.hasPrefix("40") }) else {
                return nil
            }
            return blobSHAFromTree(components: Array(components.dropFirst()), treeSHA: dir.sha, reader: reader)
        }
    }
    
    private func parseTreeEntriesForWrite(data: Data) -> [(mode: String, name: String, sha: String)] {
        var entries: [(String, String, String)] = []
        var offset = 0
        
        while offset < data.count {
            guard let spaceIndex = data[offset...].firstIndex(of: 0x20) else { break }
            let modeData = data[offset..<spaceIndex]
            guard let mode = String(data: modeData, encoding: .ascii) else { break }
            
            let nameStart = spaceIndex + 1
            guard let nullIndex = data[nameStart...].firstIndex(of: 0) else { break }
            let nameData = data[nameStart..<nullIndex]
            guard let name = String(data: nameData, encoding: .utf8) else { break }
            
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
    
    // MARK: - Index Writing
    
    /// Write a valid git index v2 file
    private func writeIndex(entries: [GitIndexEntry]) throws {
        var data = Data()
        
        // Header: DIRC magic
        data.append(contentsOf: "DIRC".utf8)
        
        // Version 2 (4 bytes, big endian)
        var version: UInt32 = 2
        data.append(contentsOf: withUnsafeBytes(of: version.bigEndian) { Array($0) })
        
        // Entry count (4 bytes, big endian)
        var entryCount = UInt32(entries.count)
        data.append(contentsOf: withUnsafeBytes(of: entryCount.bigEndian) { Array($0) })
        
        // Write each entry
        for entry in entries {
            let entryStart = data.count
            
            // ctime seconds (4 bytes)
            var ctimeSec = UInt32(entry.ctime.timeIntervalSince1970)
            data.append(contentsOf: withUnsafeBytes(of: ctimeSec.bigEndian) { Array($0) })
            
            // ctime nanoseconds (4 bytes)
            let ctimeNano = UInt32((entry.ctime.timeIntervalSince1970 - Double(ctimeSec)) * 1_000_000_000)
            var ctimeNanoVal = ctimeNano
            data.append(contentsOf: withUnsafeBytes(of: ctimeNanoVal.bigEndian) { Array($0) })
            
            // mtime seconds (4 bytes)
            var mtimeSec = UInt32(entry.mtime.timeIntervalSince1970)
            data.append(contentsOf: withUnsafeBytes(of: mtimeSec.bigEndian) { Array($0) })
            
            // mtime nanoseconds (4 bytes)
            let mtimeNano = UInt32((entry.mtime.timeIntervalSince1970 - Double(mtimeSec)) * 1_000_000_000)
            var mtimeNanoVal = mtimeNano
            data.append(contentsOf: withUnsafeBytes(of: mtimeNanoVal.bigEndian) { Array($0) })
            
            // dev (4 bytes)
            var dev = entry.dev
            data.append(contentsOf: withUnsafeBytes(of: dev.bigEndian) { Array($0) })
            
            // ino (4 bytes)
            var ino = entry.ino
            data.append(contentsOf: withUnsafeBytes(of: ino.bigEndian) { Array($0) })
            
            // mode (4 bytes)
            var mode = entry.mode
            data.append(contentsOf: withUnsafeBytes(of: mode.bigEndian) { Array($0) })
            
            // uid (4 bytes)
            var uid = entry.uid
            data.append(contentsOf: withUnsafeBytes(of: uid.bigEndian) { Array($0) })
            
            // gid (4 bytes)
            var gid = entry.gid
            data.append(contentsOf: withUnsafeBytes(of: gid.bigEndian) { Array($0) })
            
            // size (4 bytes)
            var size = UInt32(entry.size)
            data.append(contentsOf: withUnsafeBytes(of: size.bigEndian) { Array($0) })
            
            // SHA (20 bytes)
            let shaBytes = try Self.hexToBytes(entry.sha)
            data.append(contentsOf: shaBytes)
            
            // Flags (2 bytes) - name length in lower 12 bits
            let nameLen = min(entry.path.utf8.count, 0xFFF)
            var flags = UInt16(nameLen)
            data.append(contentsOf: withUnsafeBytes(of: flags.bigEndian) { Array($0) })
            
            // Path (variable length, null terminated)
            data.append(contentsOf: entry.path.utf8)
            data.append(0) // null terminator
            
            // Padding to 8-byte boundary
            let entryLen = data.count - entryStart
            let padding = (8 - (entryLen % 8)) % 8
            for _ in 0..<padding {
                data.append(0)
            }
        }
        
        // Footer: SHA1 checksum of entire file content
        let checksum = Self.sha1Bytes(data)
        data.append(contentsOf: checksum)
        
        // Write to index file
        let indexPath = gitDir.appendingPathComponent("index")
        try data.write(to: indexPath, options: [.atomic])
    }
    
    private static func sha1Bytes(_ data: Data) -> [UInt8] {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { ptr in
            _ = CC_SHA1(ptr.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest
    }

    private static func hexToBytes(_ hex: String) throws -> [UInt8] {
        guard hex.count % 2 == 0 else { throw GitManagerError.invalidRepository }
        var bytes: [UInt8] = []
        bytes.reserveCapacity(hex.count / 2)

        var idx = hex.startIndex
        while idx < hex.endIndex {
            let nextIdx = hex.index(idx, offsetBy: 2)
            let byteStr = hex[idx..<nextIdx]
            guard let b = UInt8(byteStr, radix: 16) else { throw GitManagerError.invalidRepository }
            bytes.append(b)
            idx = nextIdx
        }
        return bytes
    }
}
