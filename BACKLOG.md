# VSCode iPadOS — Backlog

> **Last updated:** March 16, 2026 by Claude Agent (Session 2)  
> **Other SWEs:** Please update this file when you pick up or complete tasks.  
> **Priority:** 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low

---

## 🔴 Critical (Must Fix Before Prod)

### BUG-001: AI Stop/Cancel Button Non-Functional
- **File:** `Services/AIManager.swift`, `Views/Panels/AIAssistantView.swift`
- **Issue:** Stop button shows during streaming but has no cancel logic.
- **Fix:** Add `URLSessionTask.cancel()` and `AsyncStream` cancellation support.
- **Status:** TODO

### BUG-002: "New Window" Menu Command is No-Op
- **File:** `App/VSCodeiPadOSApp.swift` (line 59-61)
- **Issue:** The "New Window" menu item handler body is empty.
- **Fix:** Implement `UIApplication.shared.requestSceneSessionActivation(nil, ...)`
- **Status:** TODO

### BUG-005: Security-Scoped Resource Edge Case
- **File:** `Services/EditorCore.swift` (line 1015)
- **Issue:** `startAccessingSecurityScopedResource()` may return false but file is still readable.
- **Status:** KNOWN - workaround in place

---

## 🟠 High Priority

### POLISH-001: configureStageManager() Implementation
- **File:** `App/AppDelegate.swift` (line 73-82)
- **Issue:** Empty no-op stub for Stage Manager configuration.
- **Status:** TODO

### BUG-007: ProblemsView Uses Hardcoded Mock Data
- **File:** `Views/Panels/ProblemsView.swift`
- **Issue:** All problems are hardcoded. No connection to real diagnostics.
- **Status:** TODO

### BUG-008: TestView Test Execution is Fake
- **File:** `Views/Panels/TestView.swift`
- **Issue:** `Bool.random()` used for test pass/fail.
- **Status:** TODO

### BUG-009: Syntax Highlighter Ignores Themes
- **File:** `Extensions/NSAttributedStringSyntaxHighlighter.swift`
- **Issue:** Hardcoded UIColor. Ignores ThemeManager entirely.
- **Status:** TODO

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

### INFRA-002: Add Entitlements File
- **Description:** Needed for iCloud sync, SSH, file access
- **Status:** TODO

### BUG-010: MarkdownPreview Requires Internet (CDN)
- **File:** `Views/Panels/MarkdownPreviewView.swift`
- **Status:** TODO

### BUG-011: TerminalView Esc Button is No-Op
- **File:** `Views/Panels/TerminalView.swift`
- **Status:** TODO

---

## 🟢 Low Priority

### FEAT-007: SSH Manager Implementation
- **File:** `Services/SSHManager.swift` (13 TODOs)
- **Status:** TODO (blocked on enableSSH flag)

### FEAT-008: SFTP Implementation
- **File:** `Services/SFTPManager.swift`
- **Status:** TODO

### CLEANUP-003: Consolidate Hex Color Utilities
- **Files:** `Theme.swift` vs `Color+Hex.swift`
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

### BUG-012: RemoteDebugger Tautological Ternaries
- **File:** `Services/RemoteDebugger.swift` (6 locations)
- **Status:** TODO

---

## Completed

| Task | Date | By |
|------|------|----|  
| BUG-003: Delete dead SceneDelegate.swift | Mar 16 | Claude Agent |
| BUG-004: WindowStateManager persistence | Mar 16 | Claude Agent |
| BUG-006: Centralize ALL notification strings (40+) | Mar 16 | Claude Agent |
| CONFIG-001: README wrong project name | Mar 16 | Claude Agent |
| CONFIG-002: Swift version 5.0 to 6.0 | Mar 16 | Claude Agent |
| FEAT-001: Notification+Names.swift constants | Mar 16 | Claude Agent |
| CLEANUP-001: Remove dead backup files | Mar 16 | Claude Agent |
| CLEANUP-002: Remove duplicate SceneDelegate | Mar 16 | Claude Agent |
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
