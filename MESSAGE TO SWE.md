# SWE Communication Log

## Last Updated: March 17, 2026 - 2:30 AM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Latest Commits (newest first):
- `da0392f` feat: closeTabsToTheRight/Left, debug exception breakpoints
- `7e9fcf5` fix: Replace print() with AppLogger, debug output wiring
- `02e50cf` fix: HoverInfoView theme colors, WelcomeView dynamic version (other SWE)
- `98233cd` fix: Encoding/EOL settings applied to saves (other SWE)
- `7ca080f` fix: GitView merge conflict UI, SearchView, RemoteExplorer
- `395463f` feat: Git merge conflicts, debug output, status bar encoding, output panel polish
- `2a1d260` fix: SearchView theme, DebugView UX, ThemeManager 40+ colors (other SWE)
- `2a49012` feat: Watch expression eval, breakpoint sync, terminal auto-scroll, multi-encoding
- `af43fc1` feat: Wire up Cmd+Z/Cmd+Shift+Z undo/redo
- `e73f472` fix: Critical security fixes, undo stack (other SWE)

---

## ✅ ALL Critical Issues RESOLVED:

### Undo/Redo ✅
- Cmd+Z / Cmd+Shift+Z wired in SyntaxHighlightingTextView
- Runestone handles undo natively via TimedUndoManager

### SSH Security ✅
- Passwords migrated from plaintext UserDefaults to Keychain
- One-time automatic migration on launch
- Keychain entries cleaned up on connection deletion

### Port Forwarding ✅
- Real SSH tunneling via NIO ServerBootstrap + directTCPIP
- PortForwardDataHandler + PortForwardGlueHandler bidirectional bridge
- Start/Stop wired in PortsView with error handling

### Debug System ✅
- Watch expressions auto-evaluate via JSRunner
- Breakpoints sync to RemoteDebugger
- Remote debugger onOutput wired to console
- Exception breakpoint toggles connected

### Terminal ✅
- Smart auto-scroll (only when user at bottom)
- Floating scroll-to-bottom button
- Enhanced ls (-a, -l) and grep commands
- ANSI state persistence across lines

### Editor ✅
- Multi-encoding detection (UTF-8/UTF-16/Win-1252/Latin1/ASCII)
- Save with detected encoding
- Dynamic BreadcrumbsView symbol detection
- SplitEditorView Runestone support & tab drops
- closeTabsToTheRight/Left methods added

### Git ✅
- Merge conflict detection on pull
- Conflict resolution (ours/theirs/manual)
- gitMergeConflictsDetected notification
- GitView conflict UI

### Quality ✅
- 65 @ObservedObject → @StateObject across 29 files
- All force unwraps removed (URL!, try!)
- All deprecated UIScreen.main replaced
- JSON depth limit prevents stack overflow
- print() replaced with AppLogger
- Shell injection vulnerabilities fixed in GitManager

---

## 🔍 Remaining Issues (Low Priority):

### Medium:
- SSH private key auth (passes key as password - needs NIOSSHPrivateKey)
- Host key validation disabled (needs known_hosts)
- SFTP upload limited to 100KB (base64 over SSH)
- Debug step controls simulated in local mode
- Breakpoint conditions UI missing

### Low:
- SyntaxHighlightingTextView undo stack polluted by highlighting
- TypeScript falls back to JavaScript TreeSitter
- No TreeSitter for Ruby, PHP, Kotlin, C/C++, SQL
- Terminal only supports one SSH session

---

## 📝 Notes for Other SWE:

### Build:
- **Target:** `iPad Pro 13-inch (M5)` simulator
- **Scheme:** `VSCodeiPadOS`

### Architecture:
- `EditorCore` is `@MainActor` - safe from SwiftUI views
- `SSHManager` - singleton, `@unchecked Sendable`, MainActor for Published
- `SSHConnectionStore` - uses Keychain (auto-migrated)
- Port forwarding - NIO ServerBootstrap + directTCPIP
- `Tab.fileEncoding` - stores encoding as UInt
- `AppLogger` - use .editor, .git, .ssh, .terminal, .extensions, .general
- `Notification+Names.swift` - single source for notification names
- `GitManager.mergeConflicts` - published array of conflicted file paths

### Tab Management:
- closeTab, forceCloseTab, closeAllTabs, closeOtherTabs
- closeTabsToTheRight, closeTabsToTheLeft (NEW)
- TabBarView context menu has Close, Pin, Close Others, Close to Right

### Commit Convention:
- `fix:` for bug fixes
- `feat:` for new features  
- `refactor:` for code cleanup
- `docs:` for documentation
