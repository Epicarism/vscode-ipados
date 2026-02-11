# 🔀 Git Implementation Status

## Overview

**Overall Status: 70% Read Operations, 0% Write Operations**

The app has a sophisticated native Git reader that parses `.git` directories directly (no libgit2), but all write operations (commit, push, pull) throw "SSH not connected" errors.

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐
│   GitView.swift │────▶│  GitManager.swift │ (Singleton)
│   (UI Layer)    │     │  (Coordinator)    │
└─────────────────┘     └────────┬─────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              ▼                  ▼                  ▼
    ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
    │ NativeGitReader │ │ NativeGitWriter │ │  SSHGitClient   │
    │   (✅ WORKS)    │ │  (🟡 NOT WIRED) │ │   (🔴 STUB)     │
    └─────────────────┘ └─────────────────┘ └─────────────────┘
```

---

## File Locations

| File | Lines | Purpose |
|------|-------|----------|
| `Services/GitManager.swift` | 352 | Main coordinator, singleton |
| `Services/NativeGit/NativeGitReader.swift` | 805 | Native .git parser |
| `Services/NativeGit/NativeGitWriter.swift` | 329 | Native commit writer |
| `Services/NativeGit/SSHGitClient.swift` | 452 | SSH remote operations |
| `Services/GitService.swift` | 152 | **DEPRECATED** - old mock |
| `Views/Panels/GitView.swift` | 521 | Source control UI |

---

## What Works (NativeGitReader) ✅

| Feature | Method | Notes |
|---------|--------|-------|
| Read current branch | `readHEAD()` | Parses .git/HEAD |
| List all branches | `listBranches()` | Local branches |
| Read commit history | `walkCommitHistory()` | Follows parent chain |
| File status | `computeStatus()` | Compares HEAD vs index vs working dir |
| Parse git index | `readIndex()` | Supports v2/v3/v4 formats |
| Read loose objects | `readObject()` | Blob, tree, commit |
| Decompress objects | zlib via Compression framework | iOS native |
| Resolve refs | `resolveRef()` | Handles symbolic refs |

### Limitations:
- ❌ Pack files not supported (returns nil) - Large repos won't work
- ❌ Shallow clones not tested
- ❌ Submodules not supported

---

## What's Written But Not Wired (NativeGitWriter) 🟡

| Feature | Method | Status |
|---------|--------|--------|
| Create blob | `writeBlob()` | Implemented, not used |
| Create tree | `writeTree()` | Implemented, not used |
| Create commit | `createCommit()` | Implemented, not used |
| Update refs | `updateRef()` | Implemented, not used |

**Why not wired?** Line 296 has TODO: "Wire this to GitManager".

### To Enable Local Commits:
1. Wire `NativeGitWriter` to `GitManager.commit()` method
2. Test with sample repo
3. Handle edge cases (merge commits, etc.)

---

## What's Stub Only (SSHGitClient) 🔴

All methods throw errors because `SSHManager` is a stub:

| Feature | Method | Error |
|---------|--------|-------|
| Clone | `clone()` | "SSH not connected" |
| Fetch | `fetch()` | "SSH not connected" |
| Pull | `pull()` | "SSH not connected" |
| Push | `push()` | "SSH not connected" |

### To Enable:
1. Implement `SSHManager` with SwiftNIO SSH
2. SSHGitClient calls SSHManager for git-upload-pack/git-receive-pack
3. Handle authentication (password, key)

---

## GitManager API Surface

```swift
class GitManager: ObservableObject {
    static let shared = GitManager()
    
    // Published state (for UI binding)
    @Published var currentBranch: String?
    @Published var stagedChanges: [FileStatus]
    @Published var unstagedChanges: [FileStatus]
    @Published var untrackedFiles: [String]
    @Published var recentCommits: [Commit]
    @Published var stashes: [Stash]
    
    // Read operations (✅ work)
    func refreshStatus()
    func loadCommitHistory(limit: Int)
    
    // Write operations (🔴 throw errors)
    func stageFile(_ path: String) throws    // throws sshNotConnected
    func unstageFile(_ path: String) throws  // throws sshNotConnected
    func commit(message: String) throws      // throws sshNotConnected
    func push() throws                       // throws sshNotConnected
    func pull() throws                       // throws sshNotConnected
    func createBranch(_ name: String) throws // throws sshNotConnected
    func switchBranch(_ name: String) throws // throws sshNotConnected
    func stash() throws                      // throws sshNotConnected
    func stashPop() throws                   // throws sshNotConnected
}
```

---

## Roadmap to Full Git Support

### Phase 1: Local Commits (No SSH needed)
1. Wire `NativeGitWriter` to `GitManager`
2. Implement `stageFile()` - update git index
3. Implement `commit()` - create commit object, update HEAD
4. Test with local repos

**Effort: ~2-3 days**

### Phase 2: SSH Implementation
1. Add SwiftNIO SSH package
2. Implement `SSHManager.connect()`
3. Implement `SSHManager.executeCommand()`
4. Test SSH connection to GitHub/GitLab

**Effort: ~1 week**

### Phase 3: Remote Operations
1. Implement `SSHGitClient.fetch()` - git-upload-pack protocol
2. Implement `SSHGitClient.push()` - git-receive-pack protocol
3. Handle pack file negotiation
4. Handle authentication (keys, tokens)

**Effort: ~2 weeks**

### Phase 4: Full Git
1. Pack file reading (for large repos)
2. Merge/rebase support
3. Conflict resolution UI
4. Blame support

**Effort: ~2-3 weeks**

---

## Related Documentation

- `Docs/GITFUTURE.md` - Detailed roadmap (802 lines)
- Git index format: https://git-scm.com/docs/index-format
- Git pack format: https://git-scm.com/docs/pack-format
