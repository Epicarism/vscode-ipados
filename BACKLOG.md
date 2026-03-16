# VSCode iPadOS — Backlog

> **Last updated:** March 16, 2026 by Claude Agent  
> **Other SWEs:** Please update this file when you pick up or complete tasks.  
> **Priority:** 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low

---

## 🔴 Critical (Must Fix Before Prod)

### BUG-001: AI Stop/Cancel Button Non-Functional
- **File:** `Services/AIManager.swift`, `Views/Panels/AIAssistantView.swift`
- **Issue:** Stop button shows during streaming but has no cancel logic. Users can't stop AI generation.
- **Fix:** Add `URLSessionTask.cancel()` and `AsyncStream` cancellation support.
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### BUG-002: "New Window" Menu Command is No-Op
- **File:** `App/VSCodeiPadOSApp.swift` (line 59-61)
- **Issue:** The "New Window" menu item handler body is empty. No actual window creation.
- **Fix:** Implement `UIApplication.shared.requestSceneSessionActivation(nil, ...)`
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### BUG-003: SceneDelegate is Dead Code
- **File:** `App/SceneDelegate.swift`
- **Issue:** SwiftUI `WindowGroup` bypasses UIKit SceneDelegate. Lifecycle methods never execute.
- **Fix:** Either wire it up via Info.plist scene config or remove it and move logic to SwiftUI lifecycle.
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### BUG-004: WindowStateManager Has No Persistence
- **File:** `Services/WindowStateManager.swift`
- **Issue:** All window state is in-memory only. Lost on app termination.
- **Fix:** Add UserDefaults or file-based persistence.
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### BUG-005: Security-Scoped Resource Edge Case
- **File:** `Services/EditorCore.swift` (line 1015)
- **Issue:** `startAccessingSecurityScopedResource()` may return false but file is still readable. Currently documented as known issue.
- **Status:** ⚠️ KNOWN — workaround in place (don't early-return on false)

### BUG-006: Hardcoded Notification Strings
- **Files:** Throughout `Views/`, `App/VSCodeiPadOSApp.swift`, `ContentView.swift`
- **Issue:** 30+ raw `NSNotification.Name("...")` strings scattered across codebase. Typo-prone.
- **Fix:** Centralize into `Notification.Name` extension constants.
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### CONFIG-001: README References Wrong Project Name
- **File:** `README.md`
- **Issue:** Says `VSCodeiPad.xcodeproj` but actual name is `VSCodeiPadOS.xcodeproj`
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### CONFIG-002: Swift Version Mismatch
- **File:** `Package.swift` vs `project.pbxproj`
- **Issue:** Package.swift says swift-tools-version 5.9, pbxproj says SWIFT_VERSION = 5.0
- **Status:** ⏳ TODO

---

## 🟠 High Priority

### FEAT-001: Notification Constants System
- **Description:** Create `Extensions/Notification+Names.swift` with all app notification names as constants.
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### FEAT-002: AI Streaming Cancellation
- **Description:** Full cancel support for all AI providers (URLSession tasks, AsyncStream).
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### CLEANUP-001: Remove Dead Backup Files
- **Files:** `Services/ThemeManager.swift.bak`, `Commands/AppCommands.swift.bak`, `Services/RunnerSelector.existing.swift`
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### CLEANUP-002: Remove/Fix Duplicate SceneDelegate
- **Files:** `App/SceneDelegate.swift` vs `SceneDelegate.swift` (root of VSCodeiPadOS/VSCodeiPadOS/)
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

### POLISH-001: configureStageManager() Implementation
- **File:** `App/AppDelegate.swift` (line 73-82)
- **Issue:** Empty no-op stub for Stage Manager configuration.
- **Status:** 🔧 IN PROGRESS (Claude Agent - Mar 16)

---

## 🟡 Medium Priority

### FEAT-003: Find References in Editor
- **File:** `Views/Editor/SyntaxHighlightingTextView.swift` (line 866)
- **Issue:** TODO - find references functionality not implemented
- **Status:** ⏳ TODO

### FEAT-004: Format Document
- **File:** `Views/Editor/SyntaxHighlightingTextView.swift` (line 878)
- **Issue:** TODO - format document functionality not implemented
- **Status:** ⏳ TODO

### FEAT-005: Python On-Device Execution (Pyodide)
- **File:** `Services/OnDevice/PythonRunner.swift`
- **Issue:** 3 TODOs - Pyodide loading, execution, remote execution all unimplemented
- **Status:** ⏳ TODO

### FEAT-006: Git Pull/Push via GitHub API
- **File:** `Services/GitManager.swift`
- **Issue:** Pull and push are stubs awaiting GitHubAPIClient integration
- **Status:** ⏳ TODO

### INFRA-001: Add CI/CD Pipeline
- **Description:** GitHub Actions for build, test, lint
- **Status:** ⏳ TODO

### INFRA-002: Add Entitlements File
- **Description:** Needed for iCloud sync, SSH, and file access capabilities
- **Status:** ⏳ TODO

---

## 🟢 Low Priority

### FEAT-007: SSH Manager Implementation
- **File:** `Services/SSHManager.swift` (13 TODOs)
- **Issue:** Entire file is stub. All methods need SwiftNIO SSH implementation.
- **Status:** ⏳ TODO (blocked on feature flag `enableSSH`)

### FEAT-008: SFTP Implementation
- **File:** `Services/SFTPManager.swift`
- **Issue:** Workaround for missing SwiftNIO SSH SFTP subsystem
- **Status:** ⏳ TODO

### CLEANUP-003: Consolidate Hex Color Utilities
- **Files:** `Theme.swift` has `Theme.hex()`, `Color+Hex.swift` has `Color(hex:)`
- **Issue:** Two hex-to-Color implementations. Should consolidate.
- **Status:** ⏳ TODO

### CLEANUP-004: Unused Feature Flags
- **File:** `FeatureFlags.swift`
- **Issue:** `enableSSH`, `enableiCloudSync`, `enableRemoteExecution`, `enableDebugger` are defined but never referenced in code.
- **Status:** ⏳ TODO

### CLEANUP-005: Int.uuid Conversion Safety
- **File:** `App/AppDelegate.swift` (lines 100-114)
- **Issue:** Unsafe Int-to-UUID conversion may cause collisions. Swift Hasher is non-deterministic.
- **Status:** ⏳ TODO

---

## Completed

| Task | Date | By |
|------|------|----|
| Truncate 135MB error log | Mar 16 | Claude Agent |
| Create BACKLOG.md | Mar 16 | Claude Agent |
| Create PROGRESS.md | Mar 16 | Claude Agent |
| Create AGENTS.md | Mar 16 | Claude Agent |
