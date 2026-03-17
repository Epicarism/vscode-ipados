# SWE Communication Log

## Last Updated: March 17, 2026 - 12:45 AM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Latest Commits (newest first):
- `a7876d6` fix: SearchView brace structure restored, OutputPanelManager ANSI wired up, ExtensionManager dedup
- `19e1175` Enhance terminal ls/grep commands, fix OutputPanelManager optional handling
- `6412915` fix: TerminalView ANSI reverse video + OSC stripping, EditorCore closeTab unsaved check
- `5110474` fix: TerminalView ANSI fallback + history nav + ^C double echo, SSHManager safety, EditorCore save fix
- `a5ce05f` fix: AIAssistant API keys, PanelView GeometryReader + Source Control tab, PortsView fixes
- Previous session: 17 fixes, 470+ lines dead code removed

---

## ✅ What SWE-3 Fixed This Session (March 17 12:00 AM - 12:45 AM):

### Build Fixes:
1. **GitView missing braces** - `checkout()` and `createBranch()` in BranchPickerSheet had 4 missing closing braces. Fixed.
2. **GitView missing theme** - Added `ThemeManager` and `theme` computed property (was referencing undefined `theme`).
3. **CommandPaletteView optional crash** - `$0.shortcut.lowercased()` force-unwrapped optional String. Fixed with `?.`.
4. **OutputView TimelineView name conflict** - Custom `TimelineView` struct shadowed SwiftUI's. Fixed with `SwiftUI.TimelineView`.
5. **PortsView `portNumber` not in scope** - `addPort()` referenced nonexistent var. Fixed to use `Int(newPortText)`.
6. **ErrorParser @MainActor** - UIKit properties used from non-MainActor context. Added `@MainActor` to `ErrorHighlighter` class.
7. **SearchView brace structure** - Multiple missing/extra braces from agent edits. Fully restored correct brace nesting.
8. **ExtensionManager duplicate notifications** - Removed duplicate `Notification.Name` extension (already in Notification+Names.swift).
9. **OutputPanelManager optional** - `ansiAttributes.isEmpty` on optional. Fixed with `ansiAttributes?.isEmpty ?? true`.

### Critical Bug Fixes:
10. **TerminalView ^C double echo** - `sendInterrupt()` appended `^C` both locally AND remotely. Now only appends locally when not SSH connected.
11. **TerminalView history navigation** - `nextCommand()` returned `""` instead of `nil`, wiping user's draft input.
12. **TerminalView ANSI fallback** - Raw escape codes shown as garbage when segments empty. Now strips with regex.
13. **SSHManager connect safety** - Reconnecting without disconnect leaked EventLoopGroup. Now disconnects first.
14. **SSHManager @Published off main thread** - `isConnected` and `currentConfig` set from async context. Wrapped in `MainActor.run`.
15. **SSHManager resource leak** - Failed connections leaked EventLoopGroup. Now cleaned up in catch block.
16. **SSHManager disconnect race** - `isConnected` was set asynchronously after channels cleared. Now set synchronously first.
17. **SSHManager serviceName** - Empty string `""` per RFC should be `"ssh-connection"`. Fixed.
18. **EditorCore save mutation** - `applyFileSaveSettings` wrote cleaned content back to tab, causing scroll jumps. Now only writes to disk.

### Feature Improvements:
19. **OutputPanelManager ANSI parsing** - Added full `ANSIParser` with color detection, stripping, and attribute generation. ANSI rendering now works.
20. **ContentView sidebar enum** - Replaced magic Int indices with proper `SidebarTab` enum with accessibility labels.
21. **ExtensionsView improvements** - Touch-friendly press feedback, error alerts, operation progress indicators, enable/disable support.
22. **PanelView Source Control tab** - Added `.sourceControl` tab routing to `GitView()`.
23. **PanelView GeometryReader** - Replaced `UIScreen.main.bounds` with proper geometry-based sizing.
24. **DebugView @ObservedObject** - Changed from `@StateObject` for singleton refs (prevents ownership issues).
25. **OutputView log level colors** - `.error` now uses `Color.red` (was `theme.keyword` blue), `.warning` uses `Color.orange`.
26. **OutputView empty state** - Shows "No output yet" placeholder when channel has no lines.

---

## 🔍 Known Open Issues (Priority Order):

### Critical:
- SSH private key auth broken (passes key as password - needs NIOSSHPrivateKey impl)
- Host key validation disabled (MITM risk - needs known_hosts support)
- SSH passwords stored in plaintext in UserDefaults (needs Keychain migration)
- No undo/redo support in editor (EditorCore has zero UndoManager refs)

### High:
- SFTP upload limited to 100KB (base64 over SSH)
- Port forwarding is UI-only stub (no actual SSH tunneling)
- Terminal ANSI state doesn't carry across lines (properties added, TODO: wire to parser)
- Terminal only supports one SSH session (singleton SSHManager)
- UTF-8 only file encoding (no detection/fallback for other encodings)
- `closeTab` doesn't confirm unsaved changes

### Medium:
- No merge conflict handling in git pull
- Debug step controls are simulated stubs (only work with remote debugger)
- Watch expressions never auto-evaluate
- Remote debugger `onOutput` callback never wired
- Terminal auto-scroll overrides user scroll position

### Low:
- ContentView has limited accessibility labels
- Terminal 256-color bounds checks may crash on malformed sequences
- Various @StateObject vs @ObservedObject misuse patterns remain

---

## 📝 Notes for Other SWE:

### Build:
- **Target:** `iPad Pro 13-inch (M5)` simulator
- **Scheme:** `VSCodeiPadOS`
- Always run: `xcodebuild -scheme VSCodeiPadOS -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' build`

### Architecture:
- `EditorCore` is `@MainActor` - all published property access safe from SwiftUI views
- `SSHManager` is singleton with `@unchecked Sendable` - wrap Published mutations in MainActor
- `AppLogger`: use `.editor`, `.git`, `.ssh` etc. (no `.shared`)
- `DebugManager.breakpoints` is computed get-only
- Custom `TimelineView` struct shadows SwiftUI's - use `SwiftUI.TimelineView` when needed
- `Notification+Names.swift` is the single source for all notification names

### Files I'm NOT Currently Editing:
- (Finished with all files - free to work on anything)

### Commit Convention:
- `fix:` for bug fixes
- `feat:` for new features  
- `refactor:` for code cleanup
- `docs:` for documentation
