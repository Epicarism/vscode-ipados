# SWE Communication Doc

## Last Updated: March 18, 2026 - 4:45 AM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Session 3 Summary (March 18, 2026 - 12:45 AM → 4:45 AM):

**Commits:** `aa3d42a` → `48d0fbf` (12 commits)

**Major features added:**
- **Inline AI Suggestions**: Wired InlineSuggestionManager + InlineSuggestionView into editor — ghost text overlay, Tab to accept, 1.5s debounced trigger
- **Language-Aware Autocomplete**: Keywords for Swift/JS/TS/Python/Go/Rust, member completions for JS (Array/String/console/Promise) and Python (list/str/dict)
- **Workspace-Aware Hover Info**: Searches open tabs for symbol definitions + doc comments, falls back to built-in stdlib docs
- **Go-to-Definition**: Wired NavigationManager symbol indexing — indexes on tab open + debounced on text change, searches all open tabs
- **Scroll-Triggered Syntax Highlighting**: Large files (>50k chars) now re-highlight visible range on scroll, not just on edit
- **Extended Tree-sitter Mappings**: Template engines→HTML, SASS/LESS→CSS, GraphQL→JS, explicit TODO comments for missing grammars

**Performance fixes:**
- LineNumbers scroll: O(n)→O(viewport) with binary search
- Cursor position: O(n)→O(log n) with cached newline index
- Debug logging removed from hot path
- filteredEntries cached, localSaves capped at 500

**Bug fixes (all 14 original issues RESOLVED):**
- Build errors (GitManager NativeGitReader, ContentView scope)
- Race conditions (isApplyingHighlighting NSLock, saveActiveTab DispatchWorkItem)
- Editor: keyboard shortcuts wired, indent uses dynamic tab size, block comments for HTML/CSS, bracket colorization skips strings/comments
- Git: remote branch checkout, stash list populated, packed-refs cleanup
- UI: regex error display, NavigationStack, dynamic autocomplete position
- replaceAll error feedback, SettingsView dead code removal (~145 lines)

**🟢 All 14 original documented issues: RESOLVED ✅**

**Remaining feature gaps (not bugs):**
- Extensions system is UI-only (no real loading — iOS sandbox limitation)
- No DAP debugger protocol (but real JS + LLDB/GDB over SSH work)
- SSH passphrase-protected keys use wrong KDF (bcrypt-pbkdf approximated with PBKDF2)
- Remote→local port forwarding is stub
- Code folding is stub in Runestone (API not available in 0.5.x)
- No true multi-cursor support

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
- [x] ~~SyntaxHighlightingTextView: Bracket colorization applies inside strings/comments~~ ✅ Fixed (checks foreground color before colorizing)
- [x] ~~SyntaxHighlightingTextView: Toggle comment only handles `//`, not language-aware~~ ✅ Fixed (block comment wrap/unwrap for HTML/CSS)
- [x] ~~RunestoneEditorView: Debug logging unconditional in production~~ ✅ Fixed (removed from hot path)
- [x] ~~RunestoneEditorView: O(n) cursor position calculation per keystroke~~ ✅ Fixed (cached newline index + binary search)
- [x] ~~FindViewModel: Silent regex failure~~ ✅ Fixed (red error text displayed)
- [x] ~~FindViewModel: replaceAll silently swallows write errors~~ ✅ Fixed (tracks failed files, surfaces error to UI)
- [x] ~~TimelineView: filteredEntries re-sorts, localSaves unbounded~~ ✅ Fixed (cached + 500 cap)
- [x] ~~TerminalView: SSHConnectionView uses deprecated NavigationView~~ ✅ Fixed (NavigationStack)
- [x] ~~GitManager: Remote branch checkout always fails, delete branch doesn't handle packed-refs~~ ✅ Fixed (remote branch lookup + packed-refs cleanup)
- [x] ~~GitManager: Stash list never populated during refresh()~~ ✅ Fixed (parses .git/logs/refs/stash)
- [x] ~~EditorCore: saveActiveTab race~~ ✅ Fixed (cancellable DispatchWorkItem)
- [x] ~~ContentView: LineNumbers.visibleLineIndices O(n)~~ ✅ Fixed (viewport-aware + binary search)
- [x] ~~SettingsView: AIManager() vs AIManager.shared singleton mismatch~~ ✅ Already using .shared; SettingsWebView dead code removed (~145 lines)

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
