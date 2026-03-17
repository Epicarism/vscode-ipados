# SWE Communication Log

## Last Updated: March 17, 2026 - 2:10 AM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Latest Commits (newest first):
- `2a49012` feat: Watch expression eval, breakpoint sync, terminal auto-scroll, multi-encoding files
- `af43fc1` feat: Wire up Cmd+Z/Cmd+Shift+Z undo/redo keyboard shortcuts
- `202bd70` Fix AIAssistantView font modifier error, SplitEditorView type-check complexity (other SWE)
- `29a4f62` Fix crash risks: remove force unwraps, try!, deprecated UIScreen.main
- `ed80dde` Major quality: 65 @StateObject fixes, ANSI persistence, Git security, WelcomeView accessibility
- `de24129` Fix deprecated UIScreen.main, multi-lang sticky headers, JSON depth limit, dead code removal
- `f46e5e3` BreadcrumbsView dynamic symbols, SplitEditorView drop handling & Runestone, themes

---

## ✅ Critical Issues RESOLVED This Session:

### Undo/Redo (was: "No undo/redo support")
- ✅ Cmd+Z / Cmd+Shift+Z wired in SyntaxHighlightingTextView keyCommands
- ✅ Runestone handles undo natively via TimedUndoManager responder chain

### SSH Keychain (was: "passwords stored in plaintext")
- ✅ SSHConnectionStore now saves credentials to Keychain (KeychainHelper)
- ✅ UserDefaults only stores sanitized configs (empty password/key fields)
- ✅ One-time migration on first launch via `migrateToKeychain()`
- ✅ Credentials restored from Keychain on `loadConnections()`
- ✅ Keychain entries deleted when connections are removed

### Port Forwarding (was: "UI-only stub")
- ✅ Real SSH tunneling via NIO ServerBootstrap + directTCPIP channels
- ✅ PortForwardDataHandler converts SSHChannelData ↔ ByteBuffer
- ✅ PortForwardGlueHandler bridges local TCP ↔ SSH channels bidirectionally
- ✅ PortsView startForwarding/stopForwarding wired to real SSHManager calls
- ✅ Proper cleanup on disconnect (all tunnels closed)

### Debug System Improvements:
- ✅ Watch expressions auto-evaluate via JSRunner after each step/play
- ✅ Breakpoints sync to RemoteDebugger when connected (set/remove/list)
- ✅ syncBreakpointsToRemoteDebugger() on connect with 0→1 line conversion

### Terminal:
- ✅ Smart auto-scroll (only when user is at bottom)
- ✅ Floating scroll-to-bottom button when scrolled up
- ✅ Enhanced ls (-a, -l flags) and grep command
- ✅ ANSI state persistence across lines

### Editor:
- ✅ Multi-encoding file detection (UTF-8/UTF-16/Win-1252/Latin1/ASCII)
- ✅ Save files using detected encoding
- ✅ 65 @StateObject fixes across 29 files
- ✅ BreadcrumbsView dynamic symbol detection
- ✅ SplitEditorView proper Runestone support & tab drop handling

---

## 🔍 Remaining Open Issues:

### Critical:
- SSH private key auth broken (passes key as password - needs NIOSSHPrivateKey impl)
- Host key validation disabled (MITM risk - needs known_hosts support)

### High:
- SFTP upload limited to 100KB (base64 over SSH)
- Terminal only supports one SSH session (singleton SSHManager)

### Medium:
- No merge conflict handling in git pull
- Debug step controls are simulated stubs in local mode (remote mode works)
- Exception breakpoints not connected
- Breakpoint conditions always nil (no UI to set conditions)
- Remote debugger onOutput callback not wired

### Low:
- SyntaxHighlightingTextView undo stack polluted by highlighting changes
- TypeScript falls back to JavaScript TreeSitter grammar
- No TreeSitter for Ruby, PHP, Kotlin, C/C++, SQL

---

## 📝 Notes for Other SWE:

### Build:
- **Target:** `iPad Pro 13-inch (M5)` simulator
- **Scheme:** `VSCodeiPadOS`

### Architecture:
- `EditorCore` is `@MainActor` - all published property access safe from SwiftUI views
- `SSHManager` is singleton with `@unchecked Sendable` - wrap Published mutations in MainActor
- `SSHConnectionStore` now uses Keychain for credentials (migration handled automatically)
- Port forwarding uses NIO ServerBootstrap + directTCPIP SSH channels
- `Tab.fileEncoding` stores detected encoding as UInt (String.Encoding.rawValue)
- `AppLogger`: use `.editor`, `.git`, `.ssh` etc.
- `Notification+Names.swift` is the single source for all notification names

### Files I'm Currently Working On:
- Continuing with remaining medium/low priority issues
- SSH private key auth, SFTP improvements

### Commit Convention:
- `fix:` for bug fixes
- `feat:` for new features  
- `refactor:` for code cleanup
- `docs:` for documentation
