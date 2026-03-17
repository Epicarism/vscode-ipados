# SWE Communication Log

## Last Updated: March 17, 2026 - 6:30 AM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Latest Commits (newest first):
- `4e14433` feat: Remote explorer UX (delete connections, progress, timeout cleanup), Port inline actions
- `cf76295` feat: Debug console section with REPL input
- `d878115` feat: Format Document, Find References, Output panel icon fixes, Debug channel wiring
- `4604900` fix: Build errors - NotificationCenter, onKeyPress API, isConnected, guard, binding fixes
- `dbb6c5d` fix: Replace remaining hardcoded colors across 8 more view files
- `7f513b8` fix: Cancel execution wiring, debug auto-scroll toggle, saveAll refactor
- `43af4a7` fix: RemoteDebugger termination priority, exception breakpoints, OutputPanelManager
- `a99fb37` fix: System-adaptive colors, search highlighting, multi-line comments, perf fixes
- `3751c14` fix: Comprehensive bug fixes and UI polish across 10 files
- `710b9bb` docs: Update MESSAGE TO SWE.md with comprehensive session progress

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
- **NEW: Inline play/stop/copy/delete buttons on each port row**
- **NEW: Removed broken .onHover for iPad compatibility**

### Debug System ✅
- Watch expressions auto-evaluate via JSRunner
- Breakpoints sync to RemoteDebugger
- Remote debugger onOutput wired to console
- Exception breakpoint toggles connected
- **NEW: Debug console REPL with input field in DebugView**
- **NEW: Breakpoint enable/disable toggle fixed (no longer deletes)**
- **NEW: Debug output wired to Output panel's Debug channel**

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
- **NEW: Format Document (JSON pretty-print + general indent normalization)**
- **NEW: Find References (whole-word search across open tabs, opens search panel)**

### Git ✅
- Merge conflict detection on pull
- Conflict resolution (ours/theirs/manual)
- gitMergeConflictsDetected notification
- GitView conflict UI
- **Git stash/pop/drop already wired in UI**
- **Branch delete via swipe-to-delete in BranchPickerSheet**
- **Discard All with confirmation alert**

### Remote Explorer ✅
- SSH → SFTP → File browsing → Editor pipeline fully wired
- **NEW: Swipe-to-delete on saved connections**
- **NEW: Connection progress indicator (spinner overlay)**
- **NEW: Timeout cleanup (returns to connection list on failure)**

### Output Panel ✅
- **NEW: Fixed invalid SF Symbols (js→curlybraces, snake→chevron.left.forwardslash.chevron.right)**
- **NEW: Debug channel now receives all debug console output**
- 5 channels: Output, JavaScript, Python, Remote, Debug

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
- Rename Symbol not implemented

### Low:
- SyntaxHighlightingTextView undo stack polluted by highlighting
- TypeScript falls back to JavaScript TreeSitter
- No TreeSitter for Ruby, PHP, Kotlin, C/C++, SQL
- Terminal only supports one SSH session
- Extension detail page minimal (no README/changelog)
- Git blame/tags/revert/cherry-pick not implemented

---

## 📝 Notes for Other SWE:

### Build:
- **Target:** `iPad Pro 13-inch (M5)` simulator (M4 no longer available)
- **Scheme:** `VSCodeiPadOS`
- **Status:** 0 errors, 0 warnings

### Architecture:
- `EditorCore` is `@MainActor` - safe from SwiftUI views
- `SSHManager` - singleton, `@unchecked Sendable`, MainActor for Published
- `SSHConnectionStore` - uses Keychain (auto-migrated)
- Port forwarding - NIO ServerBootstrap + directTCPIP
- `Tab.fileEncoding` - stores encoding as UInt
- `AppLogger` - use .editor, .git, .ssh, .terminal, .extensions, .general
- `Notification+Names.swift` - single source for notification names
- `GitManager.mergeConflicts` - published array of conflicted file paths
- `DebugManager.submitConsole(input:)` - REPL evaluation method
- `EditorCore.performFindReferences(symbol:)` - find references across tabs

### Tab Management:
- closeTab, forceCloseTab, closeAllTabs, closeOtherTabs
- closeTabsToTheRight, closeTabsToTheLeft
- TabBarView context menu has Close, Pin, Close Others, Close to Right

### Keyboard Shortcuts (20 via KeyCommandBridge):
- ⌘S Save, ⌘⌥S Save All, ⌘N New File, ⌘W Close Tab
- ⌘P Quick Open, ⌘⇧P Command Palette, ⌘⇧A AI Assistant
- ⌘B Toggle Sidebar, ⌘J Toggle Terminal
- ⌘F Find, ⌘⌥F Replace, ⌃G Go to Line, ⌘⇧O Go to Symbol
- ⌘= Zoom In, ⌘- Zoom Out
- ⌘↵ Go to Definition, ⌃[ Go Back, ⌃] Go Forward
- ⌘⌥↑ Add Cursor Above, ⌘⌥↓ Add Cursor Below

### Commit Convention:
- `fix:` for bug fixes
- `feat:` for new features
- `refactor:` for code cleanup
- `docs:` for documentation
