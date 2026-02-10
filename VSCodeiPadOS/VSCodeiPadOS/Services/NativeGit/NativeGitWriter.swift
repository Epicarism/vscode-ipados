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
