# SSH Implementation Setup Guide

## Overview

The terminal now uses **SwiftNIO SSH** (apple/swift-nio-ssh) for real SSH connections.
This is a pure Swift implementation that works on iOS without any C dependencies.

## Adding SwiftNIO SSH Dependency

### Method 1: Xcode Package Manager (Recommended)

1. Open `VSCodeiPadOS.xcodeproj` in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the URL: `https://github.com/apple/swift-nio-ssh`
4. Select version **0.8.0** or later
5. Choose to add **NIOSSH** product to the VSCodeiPadOS target
6. Xcode will automatically resolve and add:
   - swift-nio-ssh
   - swift-nio
   - swift-crypto

### Method 2: Manual Package.swift

A `Package.swift` file is provided at the project root for reference.
You can use Swift Package Manager from command line:

```bash
cd VSCodeiPadOS
swift package resolve
```

## Files Added

### Services/SSHManager.swift

Main SSH connection manager using SwiftNIO SSH:

```swift
// Usage example
let sshManager = SSHManager()
sshManager.delegate = self

let config = SSHConnectionConfig(
    name: "My Server",
    host: "example.com",
    port: 22,
    username: "user",
    authMethod: .password("secret")
)

sshManager.connect(config: config) { result in
    switch result {
    case .success:
        print("Connected!")
    case .failure(let error):
        print("Failed: \(error)")
    }
}

// Send commands
sshManager.send(command: "ls -la")

// Send control characters
sshManager.sendInterrupt() // Ctrl+C
sshManager.sendTab()       // Tab completion
sshManager.sendEscape()    // ESC key
```

### Services/SFTPManager.swift

Basic SFTP operations (uses shell commands as SwiftNIO SSH doesn't include SFTP subsystem):

```swift
let sftp = SFTPManager()
sftp.connect(config: config) { result in
    // Directory operations via shell commands
    sftp.createDirectory(remotePath: "~/newdir") { _ in }
    sftp.delete(remotePath: "~/oldfile") { _ in }
}
```

## Features

### Authentication Methods

1. **Password Authentication**
   ```swift
   .password("your-password")
   ```

2. **SSH Key Authentication**
   ```swift
   .privateKey(key: pemString, passphrase: nil)
   ```

### Terminal Features

- Real SSH protocol (not raw TCP)
- PTY allocation for interactive shells
- Terminal resize support
- ANSI escape sequence handling
- Command history
- Connection persistence (saved connections)

### Saved Connections

Connections are stored in UserDefaults and persist across app launches:

```swift
// Access saved connections
let store = SSHConnectionStore.shared
let connections = store.savedConnections

// Save a new connection
store.save(config)

// Delete a connection
store.delete(config)
```

## SwiftNIO SSH Notes

### Supported Algorithms

- **Key Exchange**: x25519
- **Host Keys**: Ed25519, ECDSA (P256, P384, P521)
- **Encryption**: AES-GCM
- **Authentication**: Password, Public Key

### Limitations

1. **No SFTP Subsystem**: SwiftNIO SSH doesn't include SFTP.
   Use shell commands (scp, cat, etc.) for file operations.

2. **Host Key Verification**: Current implementation accepts all host keys.
   For production, implement proper host key verification.

3. **Key Format**: Currently supports Ed25519 keys.
   Full PEM parsing for RSA/ECDSA keys needs additional implementation.

## Troubleshooting

### Connection Timeout

- Check network connectivity
- Verify host and port are correct
- Ensure firewall allows SSH (port 22)

### Authentication Failed

- Verify username/password
- For key auth, ensure private key is in correct PEM format
- Check server allows the authentication method

### Channel Errors

- Server may have closed the connection
- Check for server-side errors in SSH logs

## Architecture

```
TerminalView
    │
    ▼
TerminalManager
    │
    ▼
SSHManager ──────► NIOSSHHandler
    │                    │
    │                    ▼
    │              SSH Channel
    │                    │
    ▼                    ▼
SSHManagerDelegate    Remote Server
```

## References

- [SwiftNIO SSH GitHub](https://github.com/apple/swift-nio-ssh)
- [SwiftNIO Documentation](https://apple.github.io/swift-nio/docs/current/NIO/index.html)
- [SSH Protocol RFC 4251](https://tools.ietf.org/html/rfc4251)
