# 🔌 SSH/Remote Implementation Status

## Overview

**Status: STUB ONLY - Architecture exists, implementation missing**

The SSH infrastructure is fully architected with proper interfaces, but `SSHManager` throws `.notImplemented` for all operations.

---

## File Inventory

| File | Lines | Status | Purpose |
|------|-------|--------|----------|
| `Services/SSHManager.swift` | 233 | 🔴 STUB | Core SSH connection |
| `Services/SFTPManager.swift` | 345 | 🔴 STUB | SFTP file operations |
| `Services/NativeGit/SSHGitClient.swift` | 452 | 🔴 STUB | Git over SSH |
| `Services/RemoteExecutionService.swift` | ~200 | 🔴 STUB | Run commands over SSH |
| `Views/Panels/RemoteExplorerView.swift` | 200+ | 🟡 UI Only | Remote file browser UI |
| `Views/Panels/TerminalView.swift` | 400+ | 🟡 UI Only | Terminal UI, no backend |

---

## What's Implemented (Infrastructure)

### Connection Configuration ✅
```swift
// SSHManager.swift lines 14-31
struct SSHConnectionConfig {
    let name: String
    let host: String
    let port: Int  // default 22
    let username: String
    let authMethod: SSHAuthMethod
}

enum SSHAuthMethod {
    case password(String)
    case privateKey(key: String, passphrase: String?)
}
```

### Connection Storage ✅
```swift
// SSHManager.swift lines 183-232
class SSHConnectionStore {
    func saveConnection(_ config: SSHConnectionConfig)
    func loadConnections() -> [SSHConnectionConfig]
    func deleteConnection(named: String)
}
// Uses UserDefaults - WORKS
```

### UI Components ✅
- `RemoteExplorerView.swift` - File browser UI
- `TerminalView.swift` - Terminal emulator UI
- Connection management dialogs

---

## What's NOT Implemented

### SSHManager Core 🔴
```swift
// All these methods throw SSHClientError.notImplemented:
func connect(config: SSHConnectionConfig) async throws
func executeCommand(_ command: String) async throws -> SSHCommandResult
func startInteractiveShell() throws
func sendInput(_ input: String)
func disconnect()
```

### SFTP Operations 🔴
```swift
// SFTPManager depends on SSHManager - all stub:
func listDirectory(_ path: String) async throws -> [SFTPFile]
func downloadFile(_ remotePath: String) async throws -> Data
func uploadFile(_ data: Data, to remotePath: String) async throws
func deleteFile(_ path: String) async throws
func createDirectory(_ path: String) async throws
```

---

## Implementation Plan

### Option 1: SwiftNIO SSH (Recommended)

**Package:** https://github.com/apple/swift-nio-ssh

**Pros:**
- Pure Swift, Apple maintained
- Async/await support
- Works on iOS

**Cons:**
- No SFTP subsystem (need separate implementation)
- Lower-level API

**Effort:** ~1-2 weeks for basic SSH, +1 week for SFTP

### Option 2: NMSSH (Easier but Objective-C)

**Package:** https://github.com/NMSSH/NMSSH

**Pros:**
- Built-in SFTP support
- Higher-level API
- Well documented

**Cons:**
- Objective-C wrapper around libssh2
- May have App Store issues
- Less maintained

**Effort:** ~3-5 days

### Option 3: LibSSH2 Direct

**Package:** Build libssh2 for iOS

**Pros:**
- Most complete SSH implementation
- SFTP included

**Cons:**
- C library, needs bridging
- Complex build process
- App Store uncertainty

---

## Recommended Implementation Path

### Phase 1: Basic SSH Connection (3 days)
1. Add SwiftNIO SSH package
2. Implement `SSHManager.connect()` with password auth
3. Implement `executeCommand()` for single commands
4. Test with a Linux server

### Phase 2: Interactive Shell (3 days)
1. Implement `startInteractiveShell()`
2. Wire to TerminalView
3. Handle PTY allocation
4. Handle terminal resize

### Phase 3: Key Authentication (2 days)
1. Implement private key loading from Keychain
2. Support passphrase-protected keys
3. Support ed25519 and RSA keys

### Phase 4: SFTP (1 week)
1. Either: Implement SFTP protocol over SSH channel
2. Or: Use shell commands (`ls`, `cat`, `scp`) as workaround
3. Wire to RemoteExplorerView

### Phase 5: Git Over SSH (3 days)
1. Wire SSHManager to SSHGitClient
2. Implement git-upload-pack for fetch/clone
3. Implement git-receive-pack for push

---

## Code References

### Where SSH is Called

```swift
// TerminalView.swift - wants to use SSH for remote terminal
// GitManager.swift - all write operations need SSH
// RemoteExplorerView.swift - file browsing needs SFTP
// RemoteExecutionService.swift - remote code execution
```

### Error Messages Users See

```swift
// Current error when trying SSH features:
"SSH not yet implemented - add SwiftNIO SSH package"
```

---

## Dependencies Needed

Add to Package.swift:
```swift
.package(url: "https://github.com/apple/swift-nio-ssh.git", from: "0.8.0"),
```

---

## Security Considerations

See `Docs/SecurityAudit.md` for:
- Key storage in Keychain
- Secure credential handling
- App Transport Security exemptions needed
