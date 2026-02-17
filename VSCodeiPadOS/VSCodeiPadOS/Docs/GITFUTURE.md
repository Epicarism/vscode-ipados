# GITFUTURE.md - Native Swift Git Implementation Plan

## Executive Summary

**WE ARE 70% THERE!** The foundation for native git is already built:
- ✅ `NativeGitReader.swift` (759 lines) - Reads .git directory, parses commits, status, branches
- ✅ `SSHGitClient.swift` (452 lines) - Full SSH-based git operations  
- ✅ `DiffComponents.swift` (220 lines) - Inline and side-by-side diff views
- ✅ `BranchMenu.swift` (150 lines) - Branch selector UI
- ✅ `GitManager.swift` - Types and protocols defined
- ❌ `GitView.swift` - **MISSING** - The sidebar panel doesn't exist!
- ❌ Write operations - Native git is read-only
- ❌ Wiring - NativeGitReader/SSHGitClient not connected to GitManager

---

## What Exists (Detailed Analysis)

### 1. NativeGitReader.swift - READ OPERATIONS ✅

**Location:** `VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/NativeGitReader.swift`

**Capabilities:**
```swift
class NativeGitReader {
    // ✅ WORKING:
    func currentBranch() -> String?           // Reads .git/HEAD
    func headSHA() -> String?                 // Resolves HEAD to SHA
    func localBranches() -> [String]          // Reads refs/heads/
    func remoteBranches() -> [(remote: String, branch: String)]  // Reads refs/remotes/
    func resolveRef(_ refPath: String) -> String?  // Resolves refs including packed-refs
    func parseCommit(sha: String) -> GitCommitInfo?  // Parses commit objects
    func recentCommits(count: Int) -> [GitCommitInfo]  // Walks commit history
    func readObject(sha: String) -> GitObject?  // Reads loose objects with zlib
    func readIndex() -> GitIndex?             // Parses .git/index (staging area)
    func status() -> [GitFileStatus]          // Compares HEAD/index/working dir
    
    // ⚠️ PARTIAL:
    func readPackedObject(sha: String)        // Returns nil - pack files not implemented
}
```

**What's Impressive:**
- Full zlib decompression using iOS Compression framework
- Git index v2/v3/v4 parsing
- Tree traversal and flattening
- Commit parsing with author/date/message
- Working directory scanning

### 2. SSHGitClient.swift - REMOTE OPERATIONS ✅

**Location:** `VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/SSHGitClient.swift`

**Capabilities:**
```swift
class SSHGitClient {
    // Full git operations via SSH:
    func status(path: String) async throws -> SSHGitStatus
    func currentBranch(path: String) async throws -> String
    func branches(path: String) async throws -> [SSHGitBranch]
    func log(path: String, count: Int) async throws -> [SSHGitCommit]
    func stage(file: String, in path: String) async throws
    func stageAll(in path: String) async throws
    func unstage(file: String, in path: String) async throws
    func commit(message: String, in path: String) async throws -> String
    func checkout(branch: String, in path: String) async throws
    func createBranch(name: String, checkout: Bool, in path: String) async throws
    func deleteBranch(name: String, force: Bool, in path: String) async throws
    func pull(remote: String, branch: String?, in path: String) async throws -> String
    func push(remote: String, branch: String?, force: Bool, in path: String) async throws -> String
    func fetch(remote: String, prune: Bool, in path: String) async throws
    func discardChanges(file: String, in path: String) async throws
    func diff(file: String?, staged: Bool, in path: String) async throws -> String
    func stash(message: String?, in path: String) async throws
    func stashList(in path: String) async throws -> [SSHGitStash]
    func stashApply(index: Int, in path: String) async throws
    func stashPop(index: Int, in path: String) async throws
    func stashDrop(index: Int, in path: String) async throws
}
```

### 3. GitManager.swift - STUB ONLY ❌

**Location:** `VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift`

**Problem:** All methods just throw `GitManagerError.sshNotConnected`
```swift
func stage(file: String) async throws {
    throw GitManagerError.sshNotConnected  // ← This is the problem!
}
```

**Has good types:**
- `GitChangeKind`, `GitBranch`, `GitCommit`, `GitFileChange`, `GitStashEntry`
- Published state for UI binding

### 4. GitView.swift - DOES NOT EXIST ❌

**SidebarView.swift references it at line 120:**
```swift
case 2:
    GitView()  // ← This struct doesn't exist anywhere!
```

This is why clicking "Source Control" in the sidebar shows nothing or crashes.

---

## Implementation Plan

### Phase 1: Create GitView.swift (CRITICAL - Day 1)

**Priority:** 🔴 CRITICAL - App is broken without this

Create `VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift`:

```swift
import SwiftUI

struct GitView: View {
    @StateObject private var git = GitManager.shared
    @State private var commitMessage = ""
    @State private var showDiff = false
    @State private var selectedFile: GitFileChange?
    
    var body: some View {
        VStack(spacing: 0) {
            // Commit Message Input
            commitMessageSection
            
            Divider()
            
            // Changes List
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !git.stagedChanges.isEmpty {
                        changesSection(title: "STAGED CHANGES", 
                                      changes: git.stagedChanges, 
                                      staged: true)
                    }
                    
                    if !git.unstagedChanges.isEmpty {
                        changesSection(title: "CHANGES", 
                                      changes: git.unstagedChanges, 
                                      staged: false)
                    }
                    
                    if !git.untrackedFiles.isEmpty {
                        untrackedSection
                    }
                    
                    if git.stagedChanges.isEmpty && 
                       git.unstagedChanges.isEmpty && 
                       git.untrackedFiles.isEmpty {
                        emptyState
                    }
                }
            }
            
            Divider()
            
            // Branch & Sync Status
            statusBar
        }
        .onAppear {
            Task { await git.refresh() }
        }
    }
    
    // ... (full implementation below)
}
```

### Phase 2: Wire NativeGitReader to GitManager (Day 1-2)

**Goal:** Use local .git reading when available, SSH as fallback

```swift
// In GitManager.swift

private var nativeReader: NativeGitReader?
private var sshClient: SSHGitClient?

func setWorkingDirectory(_ url: URL?) {
    self.workingDirectory = url
    
    if let url = url {
        // Try native reading first
        self.nativeReader = NativeGitReader(repositoryURL: url)
        self.isRepository = nativeReader != nil
        
        if isRepository {
            Task { await refreshFromNative() }
        }
    } else {
        clearRepository()
    }
}

private func refreshFromNative() async {
    guard let reader = nativeReader else { return }
    
    isLoading = true
    defer { isLoading = false }
    
    // Read current branch
    currentBranch = reader.currentBranch() ?? "main"
    
    // Read all branches
    let localBranches = reader.localBranches().map { 
        GitBranch(name: $0, isRemote: false, isCurrent: $0 == currentBranch) 
    }
    let remoteBranches = reader.remoteBranches().map { 
        GitBranch(name: "\($0.remote)/\($0.branch)", isRemote: true, isCurrent: false) 
    }
    branches = localBranches
    self.remoteBranches = remoteBranches
    
    // Read status
    let statuses = reader.status()
    stagedChanges = statuses.compactMap { status -> GitFileChange? in
        guard let staged = status.staged else { return nil }
        return GitFileChange(path: status.path, kind: staged.toChangeKind(), staged: true)
    }
    unstagedChanges = statuses.compactMap { status -> GitFileChange? in
        guard let working = status.working, working != .untracked else { return nil }
        return GitFileChange(path: status.path, kind: working.toChangeKind(), staged: false)
    }
    untrackedFiles = statuses.compactMap { status -> GitFileChange? in
        guard status.working == .untracked else { return nil }
        return GitFileChange(path: status.path, kind: .untracked, staged: false)
    }
    
    // Read recent commits
    recentCommits = reader.recentCommits(count: 20).map {
        GitCommit(id: $0.sha, message: $0.message, author: $0.author, date: $0.authorDate)
    }
    
    lastError = nil
}
```

### Phase 3: Native Write Operations (Day 2-3)

**Create:** `VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/NativeGitWriter.swift`

```swift
import Foundation
import CryptoKit

class NativeGitWriter {
    let repoURL: URL
    let gitDir: URL
    
    init?(repositoryURL: URL) {
        self.repoURL = repositoryURL
        self.gitDir = repositoryURL.appendingPathComponent(".git")
        
        guard FileManager.default.fileExists(atPath: gitDir.path) else {
            return nil
        }
    }
    
    // MARK: - Git Add (Stage Files)
    
    /// Stage a file by updating .git/index
    func add(file: String) throws {
        let fullPath = repoURL.appendingPathComponent(file)
        
        // 1. Read file content
        let content = try Data(contentsOf: fullPath)
        
        // 2. Create blob object
        let blobSHA = try writeBlob(content: content)
        
        // 3. Update index
        try updateIndex(path: file, sha: blobSHA, mode: 0o100644)
    }
    
    /// Stage all changes
    func addAll() throws {
        // Get status and stage all modified/untracked
        guard let reader = NativeGitReader(repositoryURL: repoURL) else { return }
        let statuses = reader.status()
        
        for status in statuses {
            if status.working != nil {
                try add(file: status.path)
            }
        }
    }
    
    // MARK: - Git Commit
    
    /// Create a commit from staged changes
    func commit(message: String, author: String, email: String) throws -> String {
        guard let reader = NativeGitReader(repositoryURL: repoURL) else {
            throw GitWriteError.invalidRepository
        }
        
        // 1. Build tree from index
        guard let index = reader.readIndex() else {
            throw GitWriteError.noStagedChanges
        }
        let treeSHA = try writeTree(from: index)
        
        // 2. Get parent commit (current HEAD)
        let parentSHA = reader.headSHA()
        
        // 3. Create commit object
        let timestamp = Int(Date().timeIntervalSince1970)
        let timezone = "+0000" // TODO: Get actual timezone
        
        var commitContent = "tree \(treeSHA)\n"
        if let parent = parentSHA {
            commitContent += "parent \(parent)\n"
        }
        commitContent += "author \(author) <\(email)> \(timestamp) \(timezone)\n"
        commitContent += "committer \(author) <\(email)> \(timestamp) \(timezone)\n"
        commitContent += "\n"
        commitContent += message
        
        let commitSHA = try writeObject(type: "commit", content: commitContent.data(using: .utf8)!)
        
        // 4. Update HEAD
        try updateHead(sha: commitSHA)
        
        return commitSHA
    }
    
    // MARK: - Object Writing
    
    private func writeBlob(content: Data) throws -> String {
        return try writeObject(type: "blob", content: content)
    }
    
    private func writeObject(type: String, content: Data) throws -> String {
        // Format: "type size\0content"
        let header = "\(type) \(content.count)\0"
        var fullData = header.data(using: .utf8)!
        fullData.append(content)
        
        // Calculate SHA-1
        let sha = Insecure.SHA1.hash(data: fullData)
        let shaString = sha.map { String(format: "%02x", $0) }.joined()
        
        // Compress with zlib
        let compressed = try compressZlib(fullData)
        
        // Write to objects directory
        let prefix = String(shaString.prefix(2))
        let suffix = String(shaString.dropFirst(2))
        let objectDir = gitDir.appendingPathComponent("objects").appendingPathComponent(prefix)
        let objectPath = objectDir.appendingPathComponent(suffix)
        
        try FileManager.default.createDirectory(at: objectDir, withIntermediateDirectories: true)
        try compressed.write(to: objectPath)
        
        return shaString
    }
    
    private func writeTree(from index: GitIndex) throws -> String {
        // Build tree structure from flat index entries
        // This is simplified - real implementation needs to handle subdirectories
        var treeContent = Data()
        
        for entry in index.entries.sorted(by: { $0.path < $1.path }) {
            // Format: "mode name\0<20-byte sha>"
            let mode = String(format: "%o", entry.mode & 0o777777)
            let name = entry.path.components(separatedBy: "/").last ?? entry.path
            
            let line = "\(mode) \(name)\0"
            treeContent.append(line.data(using: .utf8)!)
            
            // Append binary SHA
            let shaBytes = stride(from: 0, to: entry.sha.count, by: 2).map {
                UInt8(entry.sha[entry.sha.index(entry.sha.startIndex, offsetBy: $0)..<entry.sha.index(entry.sha.startIndex, offsetBy: $0 + 2)], radix: 16)!
            }
            treeContent.append(contentsOf: shaBytes)
        }
        
        return try writeObject(type: "tree", content: treeContent)
    }
    
    private func updateHead(sha: String) throws {
        let headFile = gitDir.appendingPathComponent("HEAD")
        guard let content = try? String(contentsOf: headFile, encoding: .utf8) else {
            throw GitWriteError.invalidRepository
        }
        
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.hasPrefix("ref: ") {
            // Update the branch ref
            let refPath = String(trimmed.dropFirst(5))
            let refFile = gitDir.appendingPathComponent(refPath)
            try (sha + "\n").write(to: refFile, atomically: true, encoding: .utf8)
        } else {
            // Detached HEAD - update HEAD directly
            try (sha + "\n").write(to: headFile, atomically: true, encoding: .utf8)
        }
    }
    
    private func updateIndex(path: String, sha: String, mode: UInt32) throws {
        // This is complex - need to read, modify, and rewrite the index
        // For MVP, we can regenerate the entire index
        // TODO: Implement proper index update
    }
    
    private func compressZlib(_ data: Data) throws -> Data {
        // Use Compression framework for zlib
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count + 1024)
        defer { destinationBuffer.deallocate() }
        
        let compressedSize = data.withUnsafeBytes { sourcePtr -> Int in
            guard let baseAddress = sourcePtr.baseAddress else { return 0 }
            return compression_encode_buffer(
                destinationBuffer,
                data.count + 1024,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                data.count,
                nil,
                COMPRESSION_ZLIB
            )
        }
        
        guard compressedSize > 0 else {
            throw GitWriteError.compressionFailed
        }
        
        // Add zlib header (0x78 0x9C for default compression)
        var result = Data([0x78, 0x9C])
        result.append(Data(bytes: destinationBuffer, count: compressedSize))
        
        // Add Adler-32 checksum
        let checksum = adler32(data)
        result.append(contentsOf: withUnsafeBytes(of: checksum.bigEndian) { Array($0) })
        
        return result
    }
    
    private func adler32(_ data: Data) -> UInt32 {
        var a: UInt32 = 1
        var b: UInt32 = 0
        let MOD_ADLER: UInt32 = 65521
        
        for byte in data {
            a = (a + UInt32(byte)) % MOD_ADLER
            b = (b + a) % MOD_ADLER
        }
        
        return (b << 16) | a
    }
}

enum GitWriteError: Error {
    case invalidRepository
    case noStagedChanges
    case compressionFailed
    case indexUpdateFailed
}
```

### Phase 4: Pack File Support (Day 3-4)

Most git repos use pack files after `git gc`. Need to implement:

```swift
// In NativeGitReader.swift

private func readPackedObject(sha: String) -> GitObject? {
    let packDir = gitDir.appendingPathComponent("objects/pack")
    
    // Find all .idx files
    guard let contents = try? FileManager.default.contentsOfDirectory(atPath: packDir.path) else {
        return nil
    }
    
    for file in contents where file.hasSuffix(".idx") {
        let idxPath = packDir.appendingPathComponent(file)
        let packPath = packDir.appendingPathComponent(file.replacingOccurrences(of: ".idx", with: ".pack"))
        
        if let (offset, size) = findInPackIndex(sha: sha, indexPath: idxPath) {
            return readFromPackFile(offset: offset, size: size, packPath: packPath)
        }
    }
    
    return nil
}

private func findInPackIndex(sha: String, indexPath: URL) -> (offset: Int, size: Int)? {
    // Pack index format v2:
    // - 4 byte magic (\377tOc)
    // - 4 byte version (2)
    // - 256 * 4 byte fan-out table
    // - N * 20 byte SHA-1 entries (sorted)
    // - N * 4 byte CRC32
    // - N * 4 byte offset (or 8 bytes if large)
    // - 20 byte pack checksum
    // - 20 byte index checksum
    
    // Binary search in sorted SHA list
    // ...
    return nil // TODO: Implement
}

private func readFromPackFile(offset: Int, size: Int, packPath: URL) -> GitObject? {
    // Pack file format:
    // - Variable-length header (type + size)
    // - Compressed data (may be deltified)
    
    // Handle delta objects:
    // - OBJ_OFS_DELTA (6): delta against object at offset
    // - OBJ_REF_DELTA (7): delta against object by SHA
    
    // ...
    return nil // TODO: Implement
}
```

### Phase 5: Git Gutter Integration (Day 4)

**Create:** `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/GitGutterView.swift`

```swift
import SwiftUI

struct GitGutterDecoration: Identifiable {
    let id = UUID()
    let lineNumber: Int
    let type: GitGutterType
    let lineCount: Int
}

enum GitGutterType {
    case added
    case modified
    case deleted
    
    var color: Color {
        switch self {
        case .added: return .green
        case .modified: return .blue
        case .deleted: return .red
        }
    }
}

struct GitGutterView: View {
    let decorations: [GitGutterDecoration]
    let lineHeight: CGFloat
    let scrollOffset: CGFloat
    
    var body: some View {
        Canvas { context, size in
            for decoration in decorations {
                let y = CGFloat(decoration.lineNumber - 1) * lineHeight - scrollOffset
                let height = CGFloat(decoration.lineCount) * lineHeight
                
                if y + height < 0 || y > size.height { continue }
                
                let rect = CGRect(x: 0, y: y, width: 3, height: height)
                context.fill(Path(rect), with: .color(decoration.type.color))
            }
        }
        .frame(width: 4)
    }
}

class GitGutterManager: ObservableObject {
    @Published var decorations: [GitGutterDecoration] = []
    
    private var diffCache: [String: [DiffHunk]] = [:]
    
    func updateDecorations(for file: String, repoURL: URL) {
        guard let reader = NativeGitReader(repositoryURL: repoURL) else { return }
        
        // Get diff between HEAD and working file
        // ...
    }
}
```

### Phase 6: Hybrid Strategy (Ongoing)

**Strategy:** Native for read, SSH for write

```swift
// In GitManager.swift

func stage(file: String) async throws {
    // Try native first
    if let writer = NativeGitWriter(repositoryURL: workingDirectory!) {
        try writer.add(file: file)
        await refreshFromNative()
        return
    }
    
    // Fall back to SSH
    if let sshClient = sshClient, sshManager?.isConnected == true {
        try await sshClient.stage(file: file, in: remotePath!)
        return
    }
    
    throw GitManagerError.sshNotConnected
}

func commit(message: String) async throws {
    // Native commit if possible
    if let writer = NativeGitWriter(repositoryURL: workingDirectory!) {
        let config = try readGitConfig()
        let sha = try writer.commit(
            message: message,
            author: config.userName ?? "User",
            email: config.userEmail ?? "user@example.com"
        )
        await refreshFromNative()
        return
    }
    
    // SSH fallback
    if let sshClient = sshClient, sshManager?.isConnected == true {
        try await sshClient.commit(message: message, in: remotePath!)
        return
    }
    
    throw GitManagerError.sshNotConnected
}

// Push/Pull ALWAYS require SSH (need network)
func push() async throws {
    guard let sshClient = sshClient, sshManager?.isConnected == true else {
        throw GitManagerError.sshNotConnected
    }
    _ = try await sshClient.push(in: remotePath!)
}
```

---

## File Structure After Implementation

```
VSCodeiPadOS/VSCodeiPadOS/
├── Services/
│   ├── GitManager.swift           # Main interface (UPDATE)
│   ├── GitService.swift           # Remove or deprecate
│   └── NativeGit/
│       ├── NativeGitReader.swift  # ✅ EXISTS - read operations
│       ├── NativeGitWriter.swift  # NEW - write operations
│       ├── GitIndex.swift         # NEW - index manipulation
│       ├── GitPackReader.swift    # NEW - pack file support
│       └── SSHGitClient.swift     # ✅ EXISTS - remote operations
├── Views/
│   ├── Panels/
│   │   └── GitView.swift          # NEW - source control panel
│   ├── Editor/
│   │   └── GitGutterView.swift    # NEW - gutter decorations
│   ├── DiffComponents.swift       # ✅ EXISTS
│   └── BranchMenu.swift           # ✅ EXISTS
```

---

## Task Breakdown for Agents

### CRITICAL (Day 1) - 5 Agents

| Agent | Task | Files |
|-------|------|-------|
| git-view-1 | Create GitView.swift basic structure | Views/Panels/GitView.swift |
| git-view-2 | Add staged/unstaged sections | Views/Panels/GitView.swift |
| git-view-3 | Add commit message input | Views/Panels/GitView.swift |
| git-wire-1 | Wire NativeGitReader to GitManager.refresh() | Services/GitManager.swift |
| git-wire-2 | Add status display in GitView | Views/Panels/GitView.swift |

### HIGH PRIORITY (Day 2) - 5 Agents

| Agent | Task | Files |
|-------|------|-------|
| git-write-1 | Create NativeGitWriter.swift skeleton | Services/NativeGit/NativeGitWriter.swift |
| git-write-2 | Implement writeBlob, writeObject | Services/NativeGit/NativeGitWriter.swift |
| git-write-3 | Implement add() staging | Services/NativeGit/NativeGitWriter.swift |
| git-ctx-1 | Add context menus to GitView | Views/Panels/GitView.swift |
| git-diff-1 | Wire diff view to file selection | Views/Panels/GitView.swift |

### MEDIUM PRIORITY (Day 3) - 5 Agents

| Agent | Task | Files |
|-------|------|-------|
| git-commit-1 | Implement commit() with tree building | Services/NativeGit/NativeGitWriter.swift |
| git-gutter-1 | Create GitGutterView.swift | Views/Editor/GitGutterView.swift |
| git-gutter-2 | Integrate gutter with editor | Views/Editor/SyntaxHighlightingTextView.swift |
| git-pack-1 | Implement pack index reading | Services/NativeGit/NativeGitReader.swift |
| git-pack-2 | Implement pack object reading | Services/NativeGit/NativeGitReader.swift |

### POLISH (Day 4) - 5 Agents

| Agent | Task | Files |
|-------|------|-------|
| git-ssh-1 | Wire SSHGitClient to GitManager | Services/GitManager.swift |
| git-ssh-2 | Add push/pull UI | Views/Panels/GitView.swift |
| git-test-1 | Create git unit tests | Tests/GitTests/ |
| git-test-2 | Create git integration tests | Tests/GitTests/ |
| git-ux-1 | Polish animations, loading states | Views/Panels/GitView.swift |

---

## Testing Strategy

### Unit Tests

```swift
class NativeGitReaderTests: XCTestCase {
    func testCurrentBranch() throws {
        // Create test repo
        let tempDir = createTestRepo()
        let reader = NativeGitReader(repositoryURL: tempDir)!
        
        XCTAssertEqual(reader.currentBranch(), "main")
    }
    
    func testParseCommit() throws {
        // ...
    }
    
    func testReadIndex() throws {
        // ...
    }
    
    func testStatus() throws {
        // ...
    }
}

class NativeGitWriterTests: XCTestCase {
    func testAddFile() throws {
        // ...
    }
    
    func testCommit() throws {
        // ...
    }
}
```

### Integration Tests

```swift
class GitIntegrationTests: XCTestCase {
    func testFullWorkflow() throws {
        // 1. Create test repo
        // 2. Create a file
        // 3. Stage it
        // 4. Commit
        // 5. Verify commit appears in log
        // 6. Modify file
        // 7. Verify status shows modified
    }
}
```

---

## Success Criteria

1. ✅ Clicking "Source Control" in sidebar shows GitView (not crash)
2. ✅ Opening a folder with .git shows branch name
3. ✅ Status shows staged/unstaged/untracked files
4. ✅ Can stage files (native)
5. ✅ Can commit (native)
6. ✅ Can view commit history
7. ✅ Can view file diffs
8. ✅ Git gutter shows in editor
9. ✅ Push/pull works via SSH
10. ✅ Works offline for read operations

---

## Why This Approach Works on iOS

1. **No libgit2 needed** - Pure Swift, no C dependencies
2. **iOS sandbox compatible** - Only accesses user-opened folders
3. **Offline capable** - Read operations work without network
4. **SSH fallback** - Push/pull/clone use SSH to server with real git
5. **Performance** - Native file operations are fast
6. **App Store safe** - No shell execution, no unsandboxed access

---

## Conclusion

We're **70% done**. The hard parts (parsing git objects, zlib compression, index reading) are complete. What's missing is:

1. **GitView.swift** - UI to show everything
2. **Write operations** - add/commit
3. **Wiring** - Connecting existing code to GitManager
4. **Pack files** - For repos after git gc

**Estimated effort:** 20 agent-hours (5 agents × 4 days)
**Risk:** Low - foundation is solid, just needs UI and wiring
