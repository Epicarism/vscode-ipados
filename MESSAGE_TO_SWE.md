# SWE Communication Doc

## Last Updated: March 18, 2026 - 12:45 AM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Session 3 Summary (March 18, 2026 - 12:45 AM):

**Commit:** `aa3d42a` - fix: build errors, wire shortcuts, perf fixes, race conditions

**Key fixes this session (10 fixes):**
- **GitManager**: Fixed build errors — unwrap failable `NativeGitReader` init, `GitObjectType` enum comparisons, `var`→`let` warnings
- **ContentView**: Fixed `showCloneSheet`/`showTerminal` scope error (moved `.onReceive` from IDEEditorView to ContentView)
- **ContentView**: LineNumbers `visibleLineIndices` O(n)→O(viewport) with binary search + early termination (was iterating ALL lines per scroll frame)
- **RunestoneEditorView**: Cursor position O(n)→O(log n) with cached newline offset index + binary search (was scanning from BOF per keystroke)
- **RunestoneEditorView**: Wired `.selectLine`, `.indentLines`, `.outdentLines`, `.joinLines` notification handlers
- **RunestoneEditorView**: Removed unconditional debug logging in `textColor(for:)` hot path
- **SyntaxHighlightingTextView**: Fixed `isApplyingHighlighting` race condition with NSLock
- **EditorCore**: Fixed `saveActiveTab` race condition with cancellable DispatchWorkItem
- **SSHManager**: `print()`→`AppLogger.ssh.warning()` for RSA key warnings
- **CommandPaletteView**: Fixed force-unwrap `command.shortcut!`→`command.shortcut ?? ""`
- **TerminalView**: Wired `.clearTerminal` notification

---

### Session 2 Summary (March 16-17, 2026 - Evening):

**Commits this session (7 new):**
1. `a5ce05f` - AIAssistant add Groq/DeepSeek/Mistral API key fields, PanelView GeometryReader + Source Control tab, PortsView removeAllPorts + scan error UI, SettingsView remove duplicate import
2. `641f1eb` - DiffComponents >= boundary guard, CommandPalette remove duplicate + wrap-around nav + search shortcuts/categories
3. `fa8c0a4` - OutputView ANSI UIColor cast + timer update + search sync, GitManager stable IDs + shell escaping + fetch throws, WorkspaceManager non-optional write
4. `120b2fe` - ContentView autocomplete offset + merged onAppear + security scope transfer, EditorCore remove nonisolated(unsafe), ErrorParser @MainActor annotations, GitView theme support
5. `94bec72` - TerminalView rename alert + wc linecount + buffer trim + history limit, ProblemsView dedup, AutoSaveManager per-tab tasks, FileSystemNavigator createFile check + loop guard

**Key fixes this session (~30 fixes):**
- **OutputView**: ANSI colors now render (was casting UIColor as SwiftUI Color - always failed silently), timer updates live via TimelineView, search filter syncs on reopen
- **GitManager**: Stable identity for GitBranch/GitFileChange (was UUID() causing list flicker on every refresh), shell injection protection on all SSH commands, fetch() now throws when SSH disconnected
- **CommandPaletteView**: Removed duplicate Quick Open/Go to File, wrap-around keyboard navigation, search now matches shortcuts and categories
- **DiffComponents**: Fixed >= boundary guard on LCS algorithm memory limit
- **AIAssistantView**: Added missing API key fields for Groq, DeepSeek, Mistral
- **PanelView**: GeometryReader-based layout replacing UIScreen.main.bounds, added Source Control tab
- **ContentView**: Fixed autocomplete popup offset (now accounts for scrollOffset), merged dual .onAppear, security-scoped access transferred to EditorCore
- **EditorCore**: Removed nonisolated(unsafe) on securityScopedAccessCounts, using MainActor.assumeIsolated in deinit
- **TerminalView**: Fixed rename alert OK button role, wc line count off-by-one, moved buffer trimming outside per-line loop, added command history limit (1000)
- **ProblemsView**: Added diagnostic deduplication on single-item appends
- **AutoSaveManager**: Changed from single autoSaveTask to per-tab dictionary - prevents data loss when editing multiple tabs
- **FileSystemNavigator**: createFile now checks return value, uniqueDestinationURL has max iteration guard (1000)
- **WorkspaceManager**: Non-optional Data write prevents silent save failures
- **ErrorParser**: Added @MainActor annotations for UI-touching methods
- **PortsView**: removeAllPorts with per-port notifications, scan error UI, scanError cleared before new scan
- **SettingsView**: Removed duplicate import SwiftUI

### Session 1 Summary (March 16, 2026 - Afternoon):
- 17 fixes across 10+ files, 470+ lines dead code removed
- See commits `b9f7ce1` through `0418ffa`

### 🔴 Remaining Known Issues:
- [x] ~~SyntaxHighlightingTextView: `isApplyingHighlighting` race condition~~ ✅ Fixed (NSLock)
- [ ] SyntaxHighlightingTextView: Bracket colorization applies inside strings/comments
- [ ] SyntaxHighlightingTextView: Toggle comment only handles `//`, not language-aware
- [x] ~~RunestoneEditorView: Debug logging unconditional in production~~ ✅ Fixed (removed from hot path)
- [x] ~~RunestoneEditorView: O(n) cursor position calculation per keystroke~~ ✅ Fixed (cached newline index + binary search)
- [ ] FindViewModel: Silent regex failure (no user feedback on invalid regex)
- [ ] FindViewModel: replaceAll silently swallows write errors on workspace scope
- [ ] TimelineView: filteredEntries re-sorts on every view evaluation, localSaves unbounded
- [ ] TerminalView: SSHConnectionView uses deprecated NavigationView
- [ ] GitManager: Remote branch checkout always fails, delete branch doesn't handle packed-refs
- [ ] GitManager: Stash list never populated during refresh()
- [x] ~~EditorCore: saveActiveTab race~~ ✅ Fixed (cancellable DispatchWorkItem)
- [x] ~~ContentView: LineNumbers.visibleLineIndices O(n)~~ ✅ Fixed (viewport-aware + binary search)
- [ ] SettingsView: AIManager() vs AIManager.shared singleton mismatch, SettingsWebView onDismiss dead code

### 📝 Notes for Other SWE:
- Build target: iPad Pro 13-inch (M5) simulator
- Build command: `xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj -scheme VSCodeiPadOS -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' build`
- Please update this doc when you start/finish work on a feature

### 🔄 All Files Touched This Session:
- ContentView.swift, EditorCore.swift, ErrorParser.swift
- CommandPaletteView.swift, DiffComponents.swift
- AIAssistantView.swift, PanelView.swift, PortsView.swift, SettingsView.swift
- GitView.swift, GitManager.swift, OutputView.swift
- TerminalView.swift, ProblemsView.swift
- AutoSaveManager.swift, FileSystemNavigator.swift, WorkspaceManager.swift
- Notification+Names.swift

---

## 💬 Messages:

**[SWE-1 | 5:50 PM]** Starting systematic audit of all features. Build is clean. Will work through services first, then views. Please claim your areas below.

**[SWE-1 | 12:09 AM]** Session 2 complete. ~30 more fixes applied across 18 files. All builds clean. Major highlights: ANSI colors now work in OutputView, GitManager lists no longer flicker, AutoSaveManager handles multi-tab correctly, shell injection protected. See remaining issues list above for next session priorities.
