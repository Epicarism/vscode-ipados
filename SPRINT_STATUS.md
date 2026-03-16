# 🏃 Sprint Status — Production Readiness

**Last Updated:** March 16, 2026 02:05 GMT+1  
**Updated By:** Claude (AI SWE)  
**Branch:** `main` (39 commits ahead of origin)  
**Other SWEs:** Please update this file when you pick up or complete tasks.

---

## ✅ Completed This Sprint (March 16)

| # | What | Files Changed |
|---|------|---------------|
| 1 | Deleted all `.bak` files | `AppCommands.swift.bak`, `AIManager.swift.bak`, `ThemeManager.swift.bak` |
| 2 | Removed duplicate/dead files | `RunestoneThemeAdapter 2.swift`, `RunnerSelector.existing.swift`, `_tmp.txt`, `FeatureFlags.swift` stub |
| 3 | Fixed README wrong project name & dead links | `README.md` |
| 4 | Fixed LICENSE copyright years | `LICENSE` |
| 5 | Fixed 6 force-unwrap crashes (`as! String`) | `AIAgentTools.swift` |
| 6 | Fixed 2 force-unwrap crashes (`themes.first!`) | `ThemeManager.swift` |
| 7 | Fixed UTF-16 crash in `findWordAtPosition` (emoji/CJK) | `EditorCore.swift` |
| 8 | Fixed recent files opening with empty content | `ContentView.swift` |
| 9 | Added command palette search/filtering | `ContentView.swift` |
| 10 | Added quick open search/filtering | `ContentView.swift` |
| 11 | Added 5 more commands to command palette | `ContentView.swift` |
| 12 | Fixed tab save/restore using relative paths (not just filename) | `EditorCore.swift` |
| 13 | Replaced 15 bare `print()` with `os.Logger` in LocalLLMService | `LocalLLMService.swift` |
| 14 | Replaced 4 bare `print()` with `AppLogger` in FileSystemNavigator | `FileSystemNavigator.swift` |
| 15 | Created `AppLogger` utility for consistent logging | `Utils/AppLogger.swift` |
| 16 | Added workspace-wide Replace All confirmation dialog | `FindViewModel.swift` |
| 17 | Created new theme-aware WelcomeView component | `Views/WelcomeView.swift` |
| 18 | `.gitignore` already had all needed entries ✓ | `.gitignore` |
| 19 | Removed all `.DS_Store` files | (filesystem) |
| 20 | Created project communication docs | `SPRINT_STATUS.md`, `BACKLOG.md`, `PROGRESS.md` |

---

## 🔴 Critical Issues (Blocking Prod)

| # | Issue | File(s) | Status | Owner |
|---|-------|---------|--------|-------|
| 1 | ~~`.bak` files in project~~ | — | ✅ Done | Claude |
| 2 | ~~Duplicate/dead files~~ | — | ✅ Done | Claude |
| 3 | ~~README wrong project name~~ | `README.md` | ✅ Done | Claude |
| 4 | ~~Force unwrap crashes~~ | `AIAgentTools`, `ThemeManager`, `EditorCore` | ✅ Done | Claude |
| 5 | Swift version mismatch | `Package.swift` (5.9) vs `project.pbxproj` (5.0) | 🔴 TODO | — |
| 6 | No entitlements file | Missing `.entitlements` for file access | 🔴 TODO | — |
| 7 | Missing `PrivacyInfo.xcprivacy` | Required for App Store since 2024 | 🔴 TODO | — |
| 8 | AI Stop button non-functional | `AIManager.swift`, `AIAssistantView.swift` | 🟠 TODO | — |
| 9 | "New Window" menu command is no-op | `VSCodeiPadOSApp.swift` | 🟠 TODO | — |
| 10 | 30+ hardcoded `NSNotification.Name` strings | Throughout codebase | 🟠 TODO | — |
| 11 | Git diverged from origin | Need `git pull --rebase` | ⚠️ Manual | — |

## 🟡 Medium Issues (Should Fix)

| # | Issue | File(s) | Status | Owner |
|---|-------|---------|--------|-------|
| 12 | SSH Manager entirely stub (13 TODOs) | `SSHManager.swift` | 🔵 Deferred (feature-flagged) | — |
| 13 | Git Manager pull/push stubs | `GitManager.swift` | 🔵 Deferred | — |
| 14 | PythonRunner Pyodide not implemented | `OnDevice/PythonRunner.swift` | 🔵 Deferred | — |
| 15 | Find References not implemented | `SyntaxHighlightingTextView.swift:866` | 🔵 Deferred | — |
| 16 | Format Document not implemented | `SyntaxHighlightingTextView.swift:878` | 🔵 Deferred | — |
| 17 | ContentView.swift is 1395 lines | Needs decomposition | 🔵 Deferred | — |
| 18 | EditorCore.swift is 1570 lines | Needs decomposition | 🔵 Deferred | — |
| 19 | ErrorParserTests.swift won't compile | API mismatch with actual ErrorParser | 🟡 TODO | — |
| 20 | IDEAIAssistant uses fake canned responses | `ContentView.swift` lines 1148-1174 | 🟡 TODO | — |
| 21 | Duplicate hex-to-Color implementations | `Theme.swift` + `Color+Hex.swift` | 🟡 TODO | — |

## 🟢 Polish / Nice-to-Have

| # | Issue | Status | Owner |
|---|-------|--------|-------|
| 22 | App Store metadata & screenshots | 🔵 TODO | — |
| 23 | Accessibility audit (VoiceOver) | 🔵 TODO | — |
| 24 | Performance audit (large files) | 🔵 TODO | — |
| 25 | CI/CD pipeline (GitHub Actions) | 🔵 TODO | — |
| 26 | App icon finalized | 🔵 TODO | — |
| 27 | Launch screen configured | 🔵 TODO | — |
| 28 | Memory leak audit | 🔵 TODO | — |

---

## 🏗️ Feature Completion Status

| Feature | Status | Notes |
|---------|--------|-------|
| Runestone Editor | ✅ 95% | Active, feature-flagged on |
| Theme System (19 themes) | ✅ 100% | Dark/light/custom |
| Keyboard Shortcuts | ✅ 100% | Full UIKeyCommand + menu system |
| Syntax Highlighting | ✅ 100% | 20+ languages via Tree-sitter |
| Multi-Window / Stage Manager | ✅ 100% | Complete |
| Command Palette | ✅ 100% | Now with search filtering |
| Quick Open | ✅ 100% | Now with search filtering |
| On-Device LLM (MLX) | 🟡 80% | Nanbeige working, needs conversation history |
| Native Git | 🟡 70% | Reader done, write ops stub |
| AI Assistant (cloud) | 🟡 60% | 11 providers, needs cancel support |
| Extension System | 🟡 30% | Basic framework only |
| SSH/SFTP | 🔴 5% | All stubs, feature-flagged off |
| iCloud Sync | 🔴 0% | Feature-flagged off |
| Debugger | 🔴 0% | Feature-flagged off |

---

## 🗒️ Notes for Other SWEs

### Key Architecture Decisions
- **Runestone editor** is the active engine (`FeatureFlags.useRunestoneEditor = true`)
- **Keyboard shortcuts** source of truth: `KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md`
- **DO NOT REMOVE** Nanbeige template patching code — see `Docs/NANBEIGE_TEMPLATE_FIX.md`
- Feature-flagged subsystems (SSH, iCloud, Remote, Debugger) are intentionally disabled
- `EditorCore` is the central state manager (`@EnvironmentObject`) — all state flows through it

### Build Instructions
```bash
# Open in Xcode:
open VSCodeiPadOS/VSCodeiPadOS.xcodeproj

# CLI build:
xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj \
  -scheme VSCodeiPadOS \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'
```

### Git Status
- Local `main` is **39 commits ahead** of `origin/main`
- Origin has 1 divergent commit (`6b71943 chore: verify email linkage`)
- **Need to reconcile before push** — suggest `git pull --rebase origin main`

### Claiming Work
If you're picking up an item, edit this file and change the **Owner** column to your name. Set status to 🟡.

### Related Docs
- `BACKLOG.md` — Detailed bug/feature backlog with descriptions
- `PROGRESS.md` — Chronological log of completed work
- `AGENTS.md` — Agent activity tracking
- `VSCodeiPadOS/VSCodeiPadOS/KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md` — Shortcut architecture
- `VSCodeiPadOS/Docs/NANBEIGE_TEMPLATE_FIX.md` — Critical LLM fix docs

---

## Legend
- 🔴 TODO — Not started, blocking
- 🟠 TODO — Not started, high priority
- 🟡 In Progress — Someone is working on it  
- ✅ Done
- 🔵 Deferred — Not blocking prod, do later
- ⚠️ Manual — Requires manual intervention
