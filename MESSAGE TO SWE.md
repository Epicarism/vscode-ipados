# SWE Communication Log

## Last Updated: March 17, 2026 - 2:15 AM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Latest Commits (newest first):
- `e73f472` fix: Critical security fixes, undo stack, ANSI parsing, ExtensionManager singleton
- `202bd70` Fix AIAssistantView font modifier error, SplitEditorView type-check complexity + moveTab method
- `29a4f62` Fix crash risks: remove force unwraps, try!, deprecated UIScreen.main
- `ed80dde` Major quality: 65 @StateObject fixes, ANSI persistence, Git security, WelcomeView accessibility
- Previous sessions: 176+ commits

---

## ✅ What SWE Fixed This Session (March 17 2:00 AM - 2:15 AM):

### 🔴 CRITICAL Security Fixes:
1. **GitManager command injection** - getConfig/setConfig were interpolating config keys directly into SSH commands. Added `isValidGitConfigKey()` that only allows alphanumeric, dots, dashes, underscores. Keys are now also single-quoted in SSH commands.
2. **GitManager packed-refs parsing** - Was completely broken (checked refname prefix but lines start with SHA). Fixed to split by whitespace and check parts[1] for refname, return parts[0] as SHA.
3. **GitManager branch name validation** - Added comprehensive `isValidBranchName()` following git-check-ref-format rules (rejects .., ~, ^, :, control chars, etc.)
4. **SSHManager thread safety** - `isConnected = false` was set off MainActor in disconnect(). Moved to DispatchQueue.main.async.
5. **SSHManager disconnect notification** - Now posts `.sshDidDisconnect` notification (was missing).
6. **SSHManager port forwarding** - Fixed let→var for tunnel lock assignments that caused compile errors.

### Editor Improvements:
7. **Undo stack pollution fixed** - Syntax highlighting now uses `textStorage.setAttributes()` instead of replacing `attributedText`, avoiding undo stack noise.
8. **Language-aware comment toggle** - Toggle comment now uses correct prefix per language (# for Python/Ruby/Shell, -- for SQL/Lua, // for Swift/JS/C, etc.)
9. **Undo grouping for comments** - Comment toggle is now wrapped in undo grouping.
10. **SplitEditorView complexity** - Broke up body into extracted sub-views to fix type-checker timeout.
11. **SplitEditorView moveTab** - Added missing `moveTab(id:toPane:)` method for drag-and-drop.

### Terminal Fixes:
12. **Bold+italic font composition** - Was overwriting bold with italic; now properly composes both traits.
13. **cp/mv space handling** - Commands now use `maxSplits: 3` to handle filenames with spaces.

### Extension Manager:
14. **Private init** - Enforces singleton pattern.
15. **installedExtensions** - Changed from dead @Published to computed property.
16. **Error reporting** - Wire up `lastError` with `ExtensionError` enum.
17. **Loading state** - Install/uninstall now async with 0.3s delay for visible ProgressView.

### GitView UX:
18. **Discard confirmation** - Shows destructive alert before discarding changes.
19. **Commit & Push confirmation** - Shows alert before committing and pushing.
20. **Theme-aware background** - Uses `theme.editorBackground` instead of `UIColor.systemBackground`.
21. **Config error display** - loadGitConfig errors stored in state for UI display.

---

## 🔍 Known Open Issues (Priority Order):

### Critical:
- SSH private key auth broken (passes key as password - needs NIOSSHPrivateKey impl)
- Host key validation disabled (MITM risk - needs known_hosts support)

### High:
- SFTP upload limited to 100KB (base64 over SSH)
- Port forwarding is UI-only stub (no actual SSH tunneling)
- Terminal only supports one SSH session (singleton SSHManager)
- UTF-8 only file encoding (no detection/fallback)
- Split ANSI escape sequences across TCP chunks not handled
- SplitEditorView/EditorSplitView are dead code (never instantiated)

### Medium:
- No merge conflict handling in git pull
- Debug step controls are simulated stubs
- Watch expressions never auto-evaluate
- Remote debugger `onOutput` callback never wired
- Terminal auto-scroll overrides user scroll position
- SearchView theme bypass (uses UIColor.systemBackground)
- reverseVideo ANSI state not persisted across lines
- Format Document is a no-op stub
- Find References is a placeholder

### Low:
- .cornerRadius() deprecated usage (cosmetic)
- Tab completion non-functional in local terminal mode
- Bracket pair colorization doesn't skip strings/comments
- Timer leak on Coordinator deallocation

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
- `KeychainHelper` is used for SSH credentials AND API keys - SSH migration already implemented
- `ExtensionManager.init()` is now private - use `.shared`

### Files I'm Currently Working On:
- Continuing to squash bugs and improve quality
- Focus: making all panels look and work perfectly

### Commit Convention:
- `fix:` for bug fixes
- `feat:` for new features  
- `refactor:` for code cleanup
- `docs:` for documentation
