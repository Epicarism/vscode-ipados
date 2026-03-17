# VSCode iPadOS — Progress Log

> **Last updated:** June 2025  
> **Convention:** Most recent entries at the top.  
> **Other SWEs:** Add your entries here when you complete work.

---

## Post-March 16, 2026 — Claude Agent (Sessions 4+, ~30 commits)

### New Features (Not Previously Tracked)
- **FEAT-003 DONE:** FindReferencesService for workspace-wide symbol search (`.swift`, `.js`, `.ts`, `.py`, `.go`, `.rs`), wired into EditorCore, SearchView, and context menu
- **FEAT-007 DONE:** SSH Manager substantially implemented — 1761 lines, SSH key import, connections, `enableSSH = true`
- **FEAT-008 PARTIAL:** SFTPManager created, wired into RemoteExplorerView for browsing/downloading remote files
- **Code Folding:** CodeFoldingManager implemented (TODO/FIXME region folding)
- **Snippets:** SnippetManager with trigger-based expansion
- **Emmet:** EmmetEngine for HTML/CSS abbreviation expansion
- **Clone Repo:** CloneRepositoryView for git clone from URL
- **VS Code Tunnel:** VSCodeTunnelManager + VSCodeTunnelView for remote connections
- **Onboarding:** OnboardingView for first-run experience
- **SwiftTerm:** Local SwiftTerm terminal integrated into SingleTerminalView
- **Remote File Editing:** Edit files on remote servers via SSH/SFTP
- **JS Debugger Breakpoints:** Breakpoint support in JS debugger
- **Git Pack Files:** Support for git pack file format in GitManager
- **Inline AI Suggestions:** Code suggestions inline in editor
- **Autocomplete Expansion:** 10 new types + SwiftUI modifier completions, hover docs expanded to 35 entries
- **File Loading Indicator:** Loading state while opening files
- **Unique Tab Names:** `newUntitledFile()` generates unique tab names

### Bug Fixes & Quality (Not Previously Tracked)
- Fixed all compiler warnings across the app
- Squashed high-priority bugs from audit
- SSHManager structural brace issues and compilation errors
- ColorPickerView deprecation warnings
- Minimap overlay opacity, cap visible region at 80%
- Brace issues in EditorCore/SplitEditorView
- `@StateObject` antipatterns fixed
- GitManager type corrections
- GitGutterView lcsDiff crash when tn or tm is zero
- JSRunner thread safety
- EmmetEngine force unwrap crash
- EditorCore array bounds crash
- FindViewModel bounds safety
- regexCache concurrency safety
- DebugManager optional binding
- SearchView onChange handlers

### Accessibility (Not Previously Tracked)
- DiffComponents, DebugConsole, MergeConflict, Shortcuts, GitHubLogin, Tunnel, Snippets — VoiceOver labels
- CommandPalette, OnboardingView, TrustDialog — accessibility improvements
- Terminal polish: tree/stat/du/cal/uname/pipe support

### Performance & Infrastructure (Not Previously Tracked)
- Cursor performance optimizations
- Responsive layout improvements
- Tunnel resilience improvements
- Memory warning handlers (EditorCore, AIManager, RecentFiles)
- App lifecycle improvements (scene phase, deep links, file refresh)
- NSLocalNetworkUsageDescription, LSSupportsOpeningDocumentsInPlace added to Info.plist
- AccentColor defined

### Backlog Updates (This Session)
- FEAT-003 marked ✅ DONE
- FEAT-007 marked ✅ SUBSTANTIALLY DONE (was "TODO, blocked on enableSSH flag")
- FEAT-008 marked ✅ PARTIALLY DONE (was "TODO")
- CLEANUP-004 marked MOSTLY DONE (only enableiCloudSync remains false)
- CLEANUP-006 updated with current file sizes (files restructured but largest grew)
- Added 30+ completed items from post-Mar 16 work
- Updated timestamp to June 2025

---

## March 16, 2026 — Claude Agent (Session 3)

### Bug Fixes
- **BUG-009 FIXED:** Syntax highlighter now reads colors from ThemeManager instead of hardcoded `UIColor.systemBlue` etc. All 19 themes correctly affect syntax highlighting.

### Accessibility
- Added `.accessibilityLabel` + `.accessibilityHint` to **8 TerminalView toolbar buttons** (were icon-only, invisible to VoiceOver)
- Added `.accessibilityHint` to **4 SearchView buttons** that had labels but missing hints

### Infrastructure
- Created **GitHub Actions CI/CD pipeline** (`.github/workflows/build.yml`): build, test, and SwiftLint lint jobs targeting macOS 15 + Xcode 16
- Created **`.swiftlint.yml`** configuration with sensible defaults for the project

### Documentation
- Updated **BACKLOG.md**: moved 10+ completed items from TODO sections to Done table, marked BUG-009 done
- Updated **SPRINT_STATUS.md**: added items 41-42, marked CI/CD and syntax highlighting done, updated accessibility progress

### Codebase Audit Results (clean)
- Zero `as!` force casts remaining
- Zero `try!` force tries remaining (outside test code)
- Zero `fatalError()` calls in production code
- Zero bare `print()` debug statements remaining
- All remaining TODOs are tracked in BACKLOG.md as deferred features

---

## March 16, 2026 — Claude Agent (Session 2, continued)

### Production Readiness Fixes
- **BUG-001 FIXED:** AI cancel/stop button now works - added `cancelStreaming()` to AIManager, wired stop button in AIAssistantView
- **BUG-002 FIXED:** New Window menu command now calls `requestSceneSessionActivation`
- **BUG-006 FIXED:** ALL 40+ raw notification strings replaced with centralized constants
- **BUG-011 FIXED:** Terminal Esc button now calls `sendEscape()`
- **POLISH-001 FIXED:** Stage Manager `configureStageManager()` now sets min/max window sizes
- **CONFIG-002 FIXED:** Swift version updated from 5.0 to 6.0 in project.pbxproj

### Code Quality
- Converted 123 `print()` calls to `AppLogger` across 20+ files (0 debug prints remain)
- Fixed duplicate `fetchSuggestion` method in InlineSuggestionManager
- Replaced 22 `try!` NSRegularExpression with `safeRegex()` in ErrorParser
- Deleted PythonRunnerAlt.swift duplicate (compile conflict risk)
- Deleted PythonRunner.swift (OnDevice/) dead code (509 lines)
- Fixed deprecated `.autocapitalization(.none)` -> `.textInputAutocapitalization(.never)`
- Added `PrivacyInfo.xcprivacy` Apple privacy manifest
- Consolidated file icon logic (3 copies -> 1 in FileIcons.swift)

### Cleanup Commit (438f08a)
- Deleted `App/SceneDelegate.swift` (dead code)
- Removed dead `RealFileTreeView` and `WelcomeBtn` from ContentView
- Fixed duplicate `StatusBarItem(` line in StatusBarView
- Added accessibility labels/hints to tabs and status bar items

---

## March 16, 2026 — Claude Agent (Session 1)

### Codebase Audit & Planning
- Full codebase audit of 157 Swift files (~62K lines)
- Identified 34 actionable TODO/FIXME/BUG comments across codebase
- Created team communication docs: `BACKLOG.md`, `PROGRESS.md`, `AGENTS.md`
- Truncated 135MB runaway error log (`logs/worker-launchd-err.log`)

---

## Prior Work (Pre-March 16)

### Features Implemented
- 18 color themes (Dark+, Light+, Monokai, Solarized, Dracula, etc.)
- Dual editor engine: SyntaxHighlightingTextView + Runestone (tree-sitter)
- 11 language syntax support
- Multi-tab editor with pinning, preview mode
- Split editor (vertical, horizontal, grid)
- Command Palette (Cmd+Shift+P)
- Quick Open (Cmd+P), Go to Symbol, Go to Line
- Find & Replace with regex, glob patterns
- Multi-cursor support
- AI Assistant with 10 providers
- On-device LLM via Apple MLX (Qwen3, Nanbeige models)
- JavaScript execution via JavaScriptCore
- WASM runner
- Git integration (status, staging, branching)
- GitHub OAuth authentication
- Terminal panel, Debug panel (stub)
- Markdown preview, Extensions panel UI
- Minimap, breadcrumbs, git gutter
- Hover info, peek definition, inline suggestions
- Code folding, inlay hints
- Merge conflict view, color picker, JSON tree view
- Snippets manager, tasks view
- Auto-save, workspace settings
- Multi-window / Stage Manager support
- Workspace persistence (restore tabs on launch)
- Full keyboard shortcut system
- Notification toasts, File drag & drop
- VS Code icon font (Codicon) integration
- Feature flags system

### Known Issues (Pre-existing)
- SSH Manager is entirely stub (13 TODOs) — **NOW SUBSTANTIALLY IMPLEMENTED**
- Git pull/push via GitHub API not yet implemented — **STILL PENDING**
- Format document not implemented — **STILL PENDING**
- Find references not implemented — **✅ DONE (FEAT-003)**
- Remote debugging is stub
- Extension host doesn't run real extensions
