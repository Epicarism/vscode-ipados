# 📋 SWE Communication Log

## Last Updated: March 16, 2026 - 10:15 PM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Latest Commits:
- `49f1dc6` - fix: resolve all build errors - OutputView/TimelineView/TasksView brace fixes, GitView error handling, terminal keyboard, editor save race condition
- `40aa6e7` - fix: SSHManager private init, DebugView breakpoints, RemoteDebuggerEvent Sendable, SearchView debounceCancellable, RunestoneThemeAdapter

---

## ✅ What I (SWE-2) Fixed This Session:

### Build Errors Resolved:
1. **SSHManager private init** - `RemoteDebugger.swift` and `TerminalView.swift` were calling `SSHManager()` directly instead of `.shared`
2. **DebugView get-only breakpoints** - was calling `.removeAll()` on computed `breakpoints` property; now uses `removeAllBreakpoints()` and `toggleAllBreakpoints()`
3. **RemoteDebuggerEvent Sendable** - `OutputType` enum missing `Sendable` conformance for Swift 6
4. **SearchView undeclared debounceCancellable** - removed references to non-existent Combine property
5. **RunestoneThemeAdapter MainActor** - replaced `UIScreen.main.scale` with safe default for nonisolated context
6. **TimelineView missing closing brace** - `Source` enum was never closed, causing `DiffSummary` struct to be nested inside it

### Critical Bug Fixes:
7. **GitView error handling** - ALL git operations now have proper do/catch with user-visible error alerts (was silently swallowing errors with `try?`)
8. **GitManager untracked duplicates** - untracked files no longer appear in both `unstagedChanges` AND `untrackedFiles` arrays
9. **Terminal keyboard focus** - removed `resignFirstResponder` that was dismissing keyboard on tap; now properly focuses the input field
10. **Terminal command history** - fixed off-by-one error in `previousCommand()`/`nextCommand()` navigation
11. **Editor save race condition** - added `forceEditorSync` notification so `saveActiveTab()` forces RunestoneEditorView to sync text before writing to disk
12. **Line count optimization** - replaced O(n) character-by-character counting with NSString range-based search

### Theme Consistency:
13. **OutputView** - replaced hardcoded `.red`/`.orange` with theme properties, cached DateFormatter
14. **TimelineView** - replaced hardcoded `.blue`/`.orange` and system colors with theme properties
15. **TasksView** - replaced system colors with theme properties, added accessibility labels

---

## 🎯 My Focus Areas (SWE-2):
- **Build stability** - zero errors, zero warnings
- **Editor reliability** - save/sync, tab switching, text fidelity
- **Git operations** - proper error handling, no silent failures
- **Terminal** - keyboard input, command history, ANSI rendering
- **Theme consistency** - all panels use ThemeManager
- **SSH/SFTP** - connection flow, port forwarding stubs

## 🔴 Known Issues Still Open:
- [ ] SSH private key authentication is broken (falls back to password)
- [ ] SFTP upload limited to 100KB (base64 encoding over SSH)
- [ ] Port forwarding is UI-only (no actual data tunneling)
- [ ] No undo/redo integration in Runestone editor
- [ ] Host key validation disabled (accepts all - MITM risk)
- [ ] Diff algorithm is O(n*m) - may crash on large files
- [ ] No merge conflict handling in pull
- [ ] SidebarView.swift is 429 lines of completely dead code
- [ ] Dual tab bar implementations (TabBarView vs IDETabBar in ContentView)
- [ ] Dual sidebar state tracking (focusedSidebarTab Int vs focusedView enum)

## 📝 Notes for Other SWE:
- Build target: `iPad Pro 13-inch (M5)` simulator
- Build command: `cd VSCodeiPadOS && xcodebuild build -project VSCodeiPadOS.xcodeproj -scheme VSCodeiPadOS -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)'`
- AppLogger has NO `.shared` - use `AppLogger.editor`, `AppLogger.git`, etc.
- SSHManager uses singleton `SSHManager.shared` with `private init()`
- DebugManager.breakpoints is a computed GET-ONLY property - use methods like `removeAllBreakpoints()`, `toggleAllBreakpoints()`
- Please update this doc when you start/finish work on a feature
- Commit frequently with descriptive messages

---

## 💬 Messages:

**[SWE-2 | 10:15 PM]** Build is clean (0 errors, 0 warnings). Fixed 15 issues including critical save race condition, GitView silent failures, terminal keyboard, and theme consistency. Moving on to more feature polish and remaining open issues.
