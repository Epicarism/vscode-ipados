# SWE Communication Log

## Status Update - March 16, 2026 10:30 PM

### ✅ Build Status: CLEAN BUILD - Zero errors, zero warnings

### Latest Commits:
- `c9128dc` feat: Timeline panel tab, tab icons, @StateObject fixes, SearchView bug fixes, GitManager config API fix
- `49f1dc6` fix: resolve all build errors - OutputView/TimelineView/TasksView brace mismatches

### Recent Fixes Applied (This Session):
1. **OutputView.swift** - Fixed 5 missing closing braces in Button labels (accessibility modifiers were nesting inside buttons)
2. **TimelineView.swift** - Fixed missing closing brace for `loading` computed property
3. **TasksView.swift** - Fixed missing closing brace for `TasksView` struct before `TaskRow`
4. **GitView.swift** - Restored missing `commitChanges()` and `commitAndPush()` functions, replaced nonexistent `AppLogger.shared` with `print()`, changed `@ObservedObject` → `@StateObject`
5. **GitManager.swift** - Fixed `SSHCommandResult.output` → `.stdout`, fixed `GitManagerError.notARepository` → `.noRepository`, fixed `commandFailed` argument labels
6. **PanelView.swift** - Added Timeline tab with icon, added icons to ALL panel tab buttons
7. **TerminalView.swift** - Changed all 6 `@ObservedObject` for ThemeManager → `@StateObject`, fixed `Text.background()` type error in ANSI renderer
8. **DebugView.swift** - `@StateObject` for singletons, functional exception toggles (were hardcoded `.constant`)
9. **SearchView.swift** - Fixed binary extension filter bug (`.hasSuffix` → `==`), added `.onChange` handlers so toggling matchCase/matchWholeWord/useRegex re-triggers search, fixed missing `onAppear` function reference
10. **Notification+Names.swift** - Added `switchToTimelinePanel`

### Current Working Features:
- ✅ Editor with syntax highlighting (Runestone + legacy)
- ✅ File system navigation & workspace management
- ✅ Tab management with state restoration
- ✅ Terminal panel (local commands + SSH via SwiftNIO)
- ✅ Git integration (read ops + SSH write ops + config UI)
- ✅ Debug console (JavaScript REPL with JSRunner)
- ✅ Command palette, Quick Open, Go To Symbol/Line
- ✅ Find/Replace
- ✅ SSH connections (SwiftNIO)
- ✅ SFTP file operations (via SSH)
- ✅ ANSI color rendering in terminal (256-color support)
- ✅ Workspace trust management
- ✅ AI Assistant panel (11 providers)
- ✅ Code execution (JS, with TypeScript/Python via SSH)
- ✅ Extensions panel
- ✅ Settings with theme management (19 themes)
- ✅ VS Code tunnel mode
- ✅ Diagnostics/Problems panel (real-time analysis)
- ✅ Output panel with channel management
- ✅ Ports panel
- ✅ **Timeline panel** (NEW - git history + local save tracking)
- ✅ Breakpoint management
- ✅ Tasks panel (.vscode/tasks.json)

### Areas Still Needing Work:
- Terminal interactive PTY mode (currently line-at-a-time for SSH)
- Port forwarding actual SSH tunnel implementation
- Extension system deeper integration
- iCloud sync
- Performance testing with large files
- DebugView: watch expression swipeActions need List context (currently VStack)
- DebugView: VariableRow recursive rendering needs depth limit
- SearchView: processedResults computed property called too many times (needs caching)

### For Other SWE:
- Build is clean on `iPad Pro 13-inch (M5)` simulator
- Swift 6 strict concurrency enabled
- If you add new files, use iOS 17+ onChange form: `.onChange(of: X) { _, newValue in ... }`
- All UIKit delegate coordinators should be `@MainActor`
- API keys in Keychain via `KeychainHelper`
- Commit frequently with descriptive messages
- `SSHCommandResult` uses `.stdout` and `.stderr` (not `.output`)
- `GitManagerError.commandFailed` requires `(args:exitCode:message:)` params
- Use `@StateObject` (not `@ObservedObject`) when initializing singletons with `= X.shared`
- `AppLogger` exists in Utils/AppLogger.swift with `.editor`, `.network`, etc. categories
- DiagnosticsService runs on every file save - add rules for new languages as needed
