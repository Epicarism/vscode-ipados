# 🏃 Sprint Status — Production Readiness

**Last Updated:** March 16, 2026 04:00 GMT+1  
**Updated By:** Claude (AI SWE)  
**Branch:** `main` (82 commits ahead of origin)  
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
| 21 | Created `PrivacyInfo.xcprivacy` for App Store compliance | `PrivacyInfo.xcprivacy` |
| 22 | Created 36 notification constants (replaced hardcoded strings) | `Constants/NotificationConstants.swift` |
| 23 | Fully rewritten README with accurate project info | `README.md` |
| 24 | Fixed 42 deprecated API calls across codebase | Multiple files |
| 25 | Implemented SceneDelegate workspace open (replaced no-op "New Window") | `SceneDelegate.swift`, `VSCodeiPadOSApp.swift` |
| 26 | Removed dead code from ContentView (reduced bloat) | `ContentView.swift` |
| 27 | ~~Print-to-logger migration~~ (123→0 bare `print()` calls) | Multiple files |
| 28 | ErrorParser safeRegex (guard against nil/crash patterns) | `Utils/ErrorParser.swift` |
| 29 | Deleted `PythonRunnerAlt` dead code | `OnDevice/PythonRunnerAlt.swift` (removed) |
| 30 | Fixed Terminal Esc button not working | Terminal view |
| 31 | Configured Stage Manager support | `Info.plist`, scene manifest |
| 32 | Created entitlements file for App Store | `VSCodeiPadOS.entitlements` |
| 33 | Consolidated duplicate hex-to-Color implementations | `Theme.swift`, `Color+Hex.swift` |
| 34 | Removed dead IDEAIAssistant with fake canned responses | `ContentView.swift` |
| 35 | Added VoiceOver accessibility labels | `SidebarView.swift`, `WelcomeView.swift` |
| 36 | MarkdownPreview embedded CSS + RemoteDebugger cleanup | `MarkdownPreviewView.swift`, `RemoteDebugger.swift` |
| 37 | LaunchScreen storyboard + Info.plist enhancements | `LaunchScreen.storyboard`, `Info.plist` |
| 38 | Rewrote ErrorParserTests to compile against actual API | `ErrorParserTests.swift` |
| 39 | ProblemsView improvements | `ProblemsView.swift` |
| 40 | App icon verified (1024x1024 PNG valid) | `AppIcon.appiconset` |
| 41 | Wired syntax highlighter to theme colors (BUG-009) | `NSAttributedStringSyntaxHighlighter.swift` |
| 42 | VoiceOver accessibility: TerminalView (8 buttons) + SearchView (4 hints) | `TerminalView.swift`, `SearchView.swift` |
| 43 | GitHub Actions CI/CD pipeline (build + test + lint) | `.github/workflows/build.yml` |
| 44 | SwiftLint configuration | `VSCodeiPadOS/.swiftlint.yml` |
| 45 | ProblemsView header with error/warning count badges | `ProblemsView.swift` |
| 46 | VoiceOver: AIAssistantView (6 buttons + input), TestView (rescan + empty state) | `AIAssistantView.swift`, `TestView.swift` |
| 47 | API keys migrated from UserDefaults to iOS Keychain | `KeychainHelper.swift`, `AIManager.swift`, `AppDelegate.swift` |
| 48 | Eliminated 10 crash points (URL force-unwraps, dict force-unwraps, array bounds) | `AIManager.swift`, `OutputView.swift`, `TasksManager.swift`, `NavigationManager.swift`, `CodeAnalyzer.swift` |
| 49 | LocalLLMService: conversation history fix (reuse MLXChatSession) + HF token to Keychain | `LocalLLMService.swift` |
| 50 | SettingsView: search filter fix, duplicate import cleanup | `SettingsView.swift` |
| 51 | App display name changed from "VS Code" to "CodePad" (trademark compliance) | `Info.plist`, `ContentView.swift`, `SceneDelegate.swift`, `VSCodeiPadOSApp.swift` |
| 52 | NSAllowsLocalNetworking ATS exception for Ollama/code-server | `Info.plist` |
| 53 | 14 new file type UTIs for broader document support | `Info.plist` |
| 54 | Memory leak fixes: weak delegate, dismantleUIView, [weak self] closures | `RunnerSelector.swift`, `SettingsView.swift`, `FileSystemNavigator.swift` |
| 55 | Polished empty states for SearchView and GitView | `SearchView.swift`, `GitView.swift` |

---

## 🔴 Critical Issues (Blocking Prod)

| # | Issue | File(s) | Status | Owner |
|---|-------|---------|--------|-------|
| 1 | ~~`.bak` files in project~~ | — | ✅ Done | Claude |
| 2 | ~~Duplicate/dead files~~ | — | ✅ Done | Claude |
| 3 | ~~README wrong project name~~ | `README.md` | ✅ Done | Claude |
| 4 | ~~Force unwrap crashes~~ | `AIAgentTools`, `ThemeManager`, `EditorCore` | ✅ Done | Claude |
| 5 | ~~Swift version mismatch~~ | `Package.swift` (5.9) vs `project.pbxproj` (6.0) | ✅ Done | Claude |
| 6 | ~~No entitlements file~~ | Created `VSCodeiPadOS.entitlements` | ✅ Done | Claude |
| 7 | ~~Missing `PrivacyInfo.xcprivacy`~~ | Required for App Store since 2024 | ✅ Done | Claude |
| 8 | ~~AI Stop button non-functional~~ | `AIManager.swift`, `AIAssistantView.swift` | ✅ Done | Claude |
| 9 | ~~"New Window" menu command is no-op~~ | `SceneDelegate.swift`, `VSCodeiPadOSApp.swift` | ✅ Done | Claude |
| 10 | ~~30+ hardcoded `NSNotification.Name` strings~~ | Throughout codebase | ✅ Done (36 constants) | Claude |
| 11 | Git diverged from origin | Need `git pull --rebase` | ⚠️ Manual | — |

## 🟡 Medium Issues (Should Fix)

| # | Issue | File(s) | Status | Owner |
|---|-------|---------|--------|-------|
| 12 | SSH Manager entirely stub (13 TODOs) | `SSHManager.swift` | 🔵 Deferred (feature-flagged) | — |
| 13 | Git Manager pull/push stubs | `GitManager.swift` | 🔵 Deferred | — |
| 14 | PythonRunner Pyodide not implemented | `OnDevice/PythonRunner.swift` | 🔵 Deferred | — |
| 15 | Find References not implemented | `SyntaxHighlightingTextView.swift:866` | 🔵 Deferred | — |
| 16 | Format Document not implemented | `SyntaxHighlightingTextView.swift:878` | 🔵 Deferred | — |
| 17 | ~~ContentView.swift is 1395 lines~~ — dead code removed, decomposed | `ContentView.swift` | 🟡 In Progress | Claude |
| 18 | EditorCore.swift is 1570 lines | Needs decomposition | 🔵 Deferred | — |
| 19 | ~~ErrorParserTests.swift won't compile~~ | Rewrote to match actual API | ✅ Done | Claude |
| 20 | ~~IDEAIAssistant uses fake canned responses~~ | Removed dead code, real AIAssistantView in use | ✅ Done | Claude |
| 21 | ~~Duplicate hex-to-Color implementations~~ | Consolidated to `Color+Hex.swift` | ✅ Done | Claude |

## 🟢 Polish / Nice-to-Have

| # | Issue | Status | Owner |
|---|-------|--------|-------|
| 22 | App Store metadata & screenshots | 🔵 TODO | — |
| 23 | Accessibility audit (VoiceOver) | 🟡 Partial (SidebarView, WelcomeView, TerminalView, SearchView, StatusBar, ContentView tabs done) | Claude |
| 24 | Performance audit (large files) | 🔵 TODO | — |
| 25 | ~~CI/CD pipeline (GitHub Actions)~~ | ✅ Done (build + test + lint workflow) | Claude |
| 26 | ~~App icon finalized~~ | ✅ Done (1024x1024 PNG verified) | Claude |
| 27 | ~~Launch screen configured~~ | ✅ Done (storyboard + Info.plist) | Claude |
| 28 | Memory leak audit | 🔵 TODO | — |

---

## 🏗️ Feature Completion Status

| Feature | Status | Notes |
|---------|--------|-------|
| Runestone Editor | ✅ 95% | Active, feature-flagged on |
| Theme System (19 themes) | ✅ 100% | Dark/light/custom |
| Keyboard Shortcuts | ✅ 100% | Full UIKeyCommand + menu system |
| Syntax Highlighting | ✅ 100% | 20+ languages via regex, now theme-aware |
| Multi-Window / Stage Manager | ✅ 100% | Complete, configured |
| Command Palette | ✅ 100% | Now with search filtering |
| Quick Open | ✅ 100% | Now with search filtering |
| On-Device LLM (MLX) | ✅ 90% | Nanbeige working, conversation history fixed, HF token in Keychain |
| Native Git | 🟡 70% | Reader done, write ops stub |
| AI Assistant (cloud) | ✅ 95% | 11 providers, cancel, history, Keychain keys, crash-safe URL handling |
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
- Local `main` is **~88 commits ahead** of `origin/main`
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
