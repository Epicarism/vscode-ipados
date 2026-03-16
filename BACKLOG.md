# VSCode iPadOS — Backlog

> **Last updated:** March 16, 2026 03:44 GMT+1 by Claude Agent (Session 2)  
> **Other SWEs:** Please update this file when you pick up or complete tasks.  
> **Priority:** 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low

---

## 🔴 Critical (Must Fix Before Prod)

### BUG-005: Security-Scoped Resource Edge Case
- **File:** `Services/EditorCore.swift` (line 1015)
- **Issue:** `startAccessingSecurityScopedResource()` may return false but file is still readable.
- **Status:** KNOWN - workaround in place

---

## 🟠 High Priority

### BUG-009: Syntax Highlighter Ignores Themes
- **File:** `Extensions/NSAttributedStringSyntaxHighlighter.swift`
- **Issue:** Hardcoded UIColor. Ignores ThemeManager entirely.
- **Status:** 🟡 IN PROGRESS

---

## 🟡 Medium Priority

### FEAT-003: Find References in Editor
- **File:** `Views/Editor/SyntaxHighlightingTextView.swift` (line 866)
- **Status:** TODO

### FEAT-004: Format Document
- **File:** `Views/Editor/SyntaxHighlightingTextView.swift` (line 878)
- **Status:** TODO

### FEAT-006: Git Pull/Push via GitHub API
- **File:** `Services/GitManager.swift`
- **Status:** TODO

### INFRA-001: Add CI/CD Pipeline
- **Description:** GitHub Actions for build, test, lint
- **Status:** TODO

---

## 🟢 Low Priority

### FEAT-007: SSH Manager Implementation
- **File:** `Services/SSHManager.swift` (13 TODOs)
- **Status:** TODO (blocked on enableSSH flag)

### FEAT-008: SFTP Implementation
- **File:** `Services/SFTPManager.swift`
- **Status:** TODO

### CLEANUP-004: Unused Feature Flags
- **File:** `FeatureFlags.swift`
- **Status:** TODO

### CLEANUP-005: Int.uuid Conversion Safety
- **File:** `App/AppDelegate.swift`
- **Status:** TODO

### CLEANUP-006: Split Large Files
- ContentView.swift (1357 lines), EditorCore.swift (1576 lines)
- SettingsView.swift (963 lines), TerminalView.swift (981 lines)
- SearchView.swift (1240 lines)
- **Status:** TODO

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
