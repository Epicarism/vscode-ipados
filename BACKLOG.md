# VSCode iPadOS — Backlog

> **Last updated:** June 2025 by Claude Agent (Session 4)  
> **Other SWEs:** Please update this file when you pick up or complete tasks.  
> **Priority:** 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low

---

## 🔴 Critical (Must Fix Before Prod)

### BUG-005: Security-Scoped Resource Edge Case
- **File:** `Services/EditorCore.swift` (line ~1015)
- **Issue:** `startAccessingSecurityScopedResource()` may return false but file is still readable.
- **Status:** KNOWN - workaround in place

---

## 🟠 High Priority

### ~~BUG-009: Syntax Highlighter Ignores Themes~~
- **File:** `Extensions/NSAttributedStringSyntaxHighlighter.swift`
- **Issue:** ~~Hardcoded UIColor. Ignores ThemeManager entirely.~~ Fixed — now reads from ThemeManager.
- **Status:** ✅ DONE

---

## 🟡 Medium Priority

### ~~FEAT-003: Find References in Editor~~
- **File:** `Services/FindReferencesService.swift`, `Services/EditorCore.swift`
- **Status:** ✅ DONE (commits `9d7f039`, `2711a31`) — workspace-wide symbol search across .swift, .js, .ts, .py, .go, .rs; wired into EditorCore, SearchView, and context menu

### FEAT-004: Format Document
- **File:** `Views/Editor/SyntaxHighlightingTextView.swift` (line ~878)
- **Status:** TODO

### FEAT-006: Git Pull/Push via GitHub API
- **File:** `Services/GitManager.swift` (2832 lines, significantly expanded)
- **Status:** TODO

### ~~INFRA-001: Add CI/CD Pipeline~~
- **Description:** GitHub Actions for build, test, lint
- **Status:** ✅ DONE

---

## 🟢 Low Priority

### ~~FEAT-007: SSH Manager Implementation~~
- **File:** `Services/SSHManager.swift` (1761 lines)
- **Status:** ✅ SUBSTANTIALLY DONE — SSH key import, connections, structural issues fixed, `enableSSH = true`. Minor remaining TODOs.

### ~~FEAT-008: SFTP Implementation~~
- **File:** `Services/SFTPManager.swift`, `Views/Panels/RemoteExplorerView.swift`
- **Status:** ✅ PARTIALLY DONE — SFTPManager created, wired into RemoteExplorerView for browsing/downloading remote files.

### CLEANUP-004: Unused Feature Flags
- **File:** `FeatureFlags.swift` (33 lines)
- **Status:** MOSTLY DONE — only `enableiCloudSync` remains `false` (not yet implemented). All other flags are `true`.

### CLEANUP-005: Int.uuid Conversion Safety
- **File:** `App/AppDelegate.swift`
- **Status:** TODO

### CLEANUP-006: Split Large Files
- GitManager.swift (2832 lines), SyntaxHighlightingTextView.swift (2591 lines)
- EditorCore.swift (2495 lines), TerminalView.swift (2398 lines)
- SSHManager.swift (1761 lines), AIManager.swift (1629 lines)
- RunestoneEditorView.swift (1597 lines), DebugManager.swift (1558 lines)
- RemoteDebugger.swift (1503 lines), SearchView.swift (1385 lines)
- **Status:** TODO — files restructured since last review but largest files have grown

---

## Completed

| Task | Date | By |
|------|------|----|  
| BUG-001: AI Stop/Cancel button now functional (URLSessionTask.cancel + AsyncStream) | Mar 16 | Claude Agent |
| BUG-002: "New Window" menu command implemented (requestSceneSessionActivation) | Mar 16 | Claude Agent |
| BUG-003: Delete dead SceneDelegate.swift | Mar 16 | Claude Agent |
| BUG-004: WindowStateManager persistence | Mar 16 | Claude Agent |
| BUG-006: Centralize ALL notification strings (40+) | Mar 16 | Claude Agent |
| BUG-007: ProblemsView now uses notification-based real diagnostics | Mar 16 | Claude Agent |
| BUG-008: TestView scans real workspace for test functions (no more Bool.random()) | Mar 16 | Claude Agent |
| BUG-010: MarkdownPreview uses embedded CSS instead of CDN | Mar 16 | Claude Agent |
| BUG-011: TerminalView Esc button now functional | Mar 16 | Claude Agent |
| BUG-012: RemoteDebugger tautological ternaries cleaned up | Mar 16 | Claude Agent |
| CONFIG-001: README wrong project name | Mar 16 | Claude Agent |
| CONFIG-002: Swift version 5.0 to 6.0 | Mar 16 | Claude Agent |
| FEAT-001: Notification+Names.swift constants | Mar 16 | Claude Agent |
| FEAT-003: FindReferencesService — workspace-wide symbol search | Post-Mar 16 | Claude Agent |
| POLISH-001: configureStageManager() implemented with geometry preferences & size restrictions | Mar 16 | Claude Agent |
| CLEANUP-001: Remove dead backup files | Mar 16 | Claude Agent |
| CLEANUP-002: Remove duplicate SceneDelegate | Mar 16 | Claude Agent |
| CLEANUP-003: Consolidated hex-to-Color implementations (Theme.swift + Color+Hex.swift) | Mar 16 | Claude Agent |
| INFRA-002: Added entitlements file for iCloud/SSH/file access | Mar 16 | Claude Agent |
| FIX: ErrorParser try! to safeRegex (22 instances) | Mar 16 | Claude Agent |
| FIX: Duplicate fetchSuggestion in InlineSuggestionManager | Mar 16 | Claude Agent |
| FIX: IDETabItem missing closing brace | Mar 16 | Claude Agent |
| FIX: Duplicate StatusBarItem line | Mar 16 | Claude Agent |
| FIX: Delete PythonRunnerAlt.swift duplicate | Mar 16 | Claude Agent |
| FIX: Delete PythonRunner.swift (OnDevice/) dead code | Mar 16 | Claude Agent |
| POLISH: Accessibility labels on tabs + status bar | Mar 16 | Claude Agent |
| POLISH: print() to AppLogger in EditorCore | Mar 16 | Claude Agent |
| Added PrivacyInfo.xcprivacy privacy manifest | Mar 16 | Claude Agent |
| Consolidated file icon logic (3 copies to 1) | Mar 16 | Claude Agent |
| Truncate 135MB error log | Mar 16 | Claude Agent |
| Create BACKLOG.md, PROGRESS.md, AGENTS.md | Mar 16 | Claude Agent |
| BUG-009: Wired syntax highlighter to ThemeManager colors | Mar 16 | Claude Agent |
| POLISH: VoiceOver labels on TerminalView (8 buttons) + SearchView (4 hints) | Mar 16 | Claude Agent |
| SECURITY: API keys migrated from UserDefaults to iOS Keychain | Mar 16 | Claude Agent |
| FIX: Eliminated 10 crash points (URL force-unwraps, dict force-unwraps, array bounds) | Mar 16 | Claude Agent |
| FEAT: LocalLLM conversation history fix (reuse MLXChatSession) | Mar 16 | Claude Agent |
| FEAT: Context window management for LocalLLM (auto-reset at 75% capacity) | Mar 16 | Claude Agent |
| FEAT: Large file performance guard (100K threshold, isLargeFile flag) | Mar 16 | Claude Agent |
| BRAND: Renamed display name from "VS Code" to "CodePad" (trademark compliance) | Mar 16 | Claude Agent |
| FIX: HuggingFace token moved from UserDefaults to Keychain | Mar 16 | Claude Agent |
| FIX: Info.plist version aligned to 1.0 (matching MARKETING_VERSION) | Mar 16 | Claude Agent |
| FIX: Eliminate all compiler warnings across the app | Post-Mar 16 | Claude Agent |
| FIX: Squash high-priority bugs found in audit | Post-Mar 16 | Claude Agent |
| FEAT: Keyboard shortcuts, tunnel manager, git clone | Post-Mar 16 | Claude Agent |
| FEAT: App Store readiness — metadata, privacy, git delta, SwiftTerm | Post-Mar 16 | Claude Agent |
| FEAT: Git pack file support, inline AI suggestions, SSH key import | Post-Mar 16 | Claude Agent |
| FIX: SSHManager structural brace issues, ColorPicker deprecations | Post-Mar 16 | Claude Agent |
| FEAT: Expand autocomplete (10 new types + SwiftUI modifiers), hover docs to 35 entries | Post-Mar 16 | Claude Agent |
| FEAT: Persist breakpoints, JS alert handlers in tunnel, extensions UX | Post-Mar 16 | Claude Agent |
| FIX: Minimap overlay opacity, brace issues in EditorCore/SplitEditorView, @StateObject antipatterns | Post-Mar 16 | Claude Agent |
| FEAT: SnippetManager, EmmetEngine, OnboardingView, async file loading | Post-Mar 16 | Claude Agent |
| FEAT: Major quality pass — crash fixes, editor features, UX polish | Post-Mar 16 | Claude Agent |
| FEAT: FEAT-007 SSH Manager — 1761 lines, key import, connections, enableSSH=true | Post-Mar 16 | Claude Agent |
| FEAT: FEAT-008 SFTP — SFTPManager wired into RemoteExplorerView | Post-Mar 16 | Claude Agent |
| FIX: Crash risks (JSRunner thread safety, EmmetEngine force unwrap, EditorCore bounds) | Post-Mar 16 | Claude Agent |
| FIX: Accessibility — DiffComponents, DebugConsole, MergeConflict, Shortcuts, GitHubLogin, Tunnel, Snippets | Post-Mar 16 | Claude Agent |
| FEAT: Remote file editing, JS debugger breakpoints, local SwiftTerm terminal, responsive layout | Post-Mar 16 | Claude Agent |
| FIX: Build errors — regexCache concurrency safety, DebugManager optional binding | Post-Mar 16 | Claude Agent |
| FEAT: Code folding, cursor performance, block comments, clone repo view | Post-Mar 16 | Claude Agent |
| FIX: NSLocalNetworkUsageDescription, LSSupportsOpeningDocumentsInPlace, AccentColor | Post-Mar 16 | Claude Agent |
| FIX: Memory warning handlers (EditorCore, AIManager, RecentFiles), app lifecycle, scene phase | Post-Mar 16 | Claude Agent |
