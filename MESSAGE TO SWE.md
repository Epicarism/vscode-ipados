# SWE Communication Log

## Last Updated: March 17, 2026 - 1:30 AM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Latest Commits (newest first):
- `29a4f62` Fix crash risks: remove force unwraps, try!, deprecated UIScreen.main
- `ed80dde` Major quality: 65 @StateObject fixes, ANSI persistence, Git security, WelcomeView accessibility
- `de24129` Fix deprecated UIScreen.main, multi-lang sticky headers, JSON depth limit, dead code removal
- `f46e5e3` BreadcrumbsView dynamic symbols, SplitEditorView drop handling & Runestone, Aurora/Tokyo Night themes
- `19e1175` Enhance terminal ls/grep commands, fix OutputPanelManager optional handling
- `a7876d6` fix: SearchView brace structure, OutputPanelManager ANSI, ExtensionManager dedup, ContentView sidebar enum
- `6412915` fix: TerminalView ANSI reverse video + OSC stripping, EditorCore closeTab unsaved check
- Previous sessions: 26+ fixes, 470+ lines dead code removed

---

## ✅ What SWE-4 Fixed This Session (March 17 1:00 AM - 1:30 AM):

### Crash Prevention:
1. **65 @ObservedObject → @StateObject** - Fixed across 29 files where views own their objects (prevents state loss on re-render)
2. **URL force unwraps** - 7 `URL(string:)!` in AIAssistantView replaced with safe `if let` bindings
3. **try! regex** - 2 `try!` patterns in TerminalView ANSI parsing replaced with `try?` + nil fallback
4. **UIScreen.main deprecated** - Replaced in StatusBarView (.scale) and EditorSplitView (.bounds.width)
5. **JSON stack overflow** - Added maxDepth=50 limit to JSONTreeView recursive parsing

### Bug Fixes:
6. **BreadcrumbsView hardcoded symbol** - Was always showing "ContentView"; now dynamically detects nearest symbol
7. **BreadcrumbsView hardcoded project name** - Was always "VSCodeiPadOS"; now uses actual folder name
8. **SplitEditorView onDrop silent failure** - Tab drops were silently lost; now properly extracts and moves tabs
9. **SplitEditorView Runestone flag ignored** - Split panes always used regex highlighter; now respects FeatureFlags.useRunestoneEditor
10. **OutputPanelManager ANSI optional crash** - `ansiAttributes.isEmpty` on nil optional fixed

### Feature Improvements:
11. **Terminal ls enhanced** - Added `-a` (show hidden) and `-l` (long format with dates/sizes) flags
12. **Terminal grep command** - New command with `-i` (case insensitive) and `-n` (line numbers) flags
13. **StickyHeaderView multi-language** - Extended from Swift-only to 8 languages (JS/TS, Python, Rust, Go, C/C++, Ruby, Java/Kotlin)
14. **ANSI state persistence** - Terminal ANSI colors now carry across line boundaries
15. **GitManager security** - Fixed shell injection vulnerabilities in branch/config operations
16. **WelcomeView accessibility** - Added comprehensive accessibility labels, Clone Repository action, Clear Recent button
17. **Aurora & Tokyo Night themes** - Added complete theme definitions with syntax highlighting colors
18. **FindViewModel context** - Search results now show 2 lines of context before/after matches
19. **MinimapView cleanup** - Removed unused makeAttributedLine dead code

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
- Terminal only supports one SSH session (singleton SSHManager)
- UTF-8 only file encoding (no detection/fallback for other encodings)

### Medium:
- No merge conflict handling in git pull
- Debug step controls are simulated stubs (only work with remote debugger)
- Watch expressions never auto-evaluate
- Remote debugger `onOutput` callback never wired
- Terminal auto-scroll overrides user scroll position

### Low (FIXED ✅):
- ~~ContentView has limited accessibility labels~~ ✅ Fixed via WelcomeView accessibility
- ~~Terminal 256-color bounds checks may crash~~ ✅ Fixed via try? fallback
- ~~Various @StateObject vs @ObservedObject misuse~~ ✅ Fixed 65 instances across 29 files
- ~~Terminal ANSI state doesn't carry across lines~~ ✅ Fixed via ANSI state persistence
- ~~closeTab doesn't confirm unsaved changes~~ ✅ Fixed in previous session

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
- `SyntaxHighlightingTextView` has a compatibility init that takes `editorCore:` directly
- `RunestoneEditorView` uses `@EnvironmentObject` for editorCore - pass via `.environmentObject()`

### Files I'm Currently Working On:
- Focusing on Critical/High priority issues next
- Working on undo/redo, SSH Keychain, port forwarding

### Commit Convention:
- `fix:` for bug fixes
- `feat:` for new features  
- `refactor:` for code cleanup
- `docs:` for documentation
