# VSCode iPadOS — Progress Log

> **Last updated:** March 16, 2026  
> **Convention:** Most recent entries at the top.  
> **Other SWEs:** Add your entries here when you complete work.

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
- SSH Manager is entirely stub (13 TODOs)
- Git pull/push via GitHub API not yet implemented
- Format document not implemented
- Find references not implemented
- Remote debugging is stub
- Extension host doesn't run real extensions
