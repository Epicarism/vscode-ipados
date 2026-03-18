# SWE Communication Doc

## Last Updated: March 18, 2026 - 12:35 PM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings from our code)

### Session 3 Summary (March 18, 2026 - 12:45 AM → 12:35 PM):

**Commits:** `aa3d42a` → `cd3b302` (40+ commits)

**Major features added:**
- **Inline AI Suggestions**: Ghost text overlay, Tab to accept, partial word-by-word accept (Ctrl+Right), Escape to dismiss, cursor-move auto-dismiss
- **Language-Aware Autocomplete**: Keywords for Swift/JS/TS/Python/Go/Rust, member completions for JS (Array/String/console/Promise) and Python (list/str/dict)
- **Workspace-Aware Hover Info**: Searches open tabs for symbol definitions + doc comments, falls back to built-in stdlib docs
- **Go-to-Definition**: Wired NavigationManager symbol indexing — indexes on tab open + debounced on text change, searches all open tabs
- **Scroll-Triggered Syntax Highlighting**: Large files (>50k chars) now re-highlight visible range on scroll, not just on edit
- **Extended Tree-sitter Mappings**: Template engines→HTML, SASS/LESS→CSS, GraphQL→JS, explicit TODO comments for missing grammars
- **Conditional Breakpoints in JS Debugger**: Breakpoint conditions evaluated in JS context; falsy results skip the breakpoint
- **Chunked SFTP Uploads (up to 5MB)**: Files >100KB uploaded in 64KB base64 chunks with progress reporting
- **Emmet JSX/TSX/Vue/Svelte Support**: Language detection extended for React/Vue/Svelte/PHP/ERB files
- **Task stderr distinction**: Task output panel now correctly marks stderr output separately from stdout
- **Sidebar drag-to-resize**: 150–500px range with drag handle between sidebar and editor
- **Editor undo grouping**: All 9 editor actions (toggle comment, delete/move/duplicate/join lines, indent/outdent) wrapped in undo groups for atomic Cmd+Z
- **Format Document undoable**: Cmd+Z reverses formatting, Cmd+Shift+Z redoes
- **Autocomplete clears on tab switch**: Prevents stale popup from previous file
- **Find Enter→Next**: Enter in search field advances to next result (was re-searching)
- **Breadcrumb tap no longer copies to clipboard**: Removed accidental UIPasteboard side-effect
- **Find selection dedup fix**: Find Next/Previous always scrolls to match (even single-result case)
- **Cmd+Enter insert line below**: New line with preserved indentation (VSCode standard)
- **Cmd+Shift+Enter insert line above**: New line above with preserved indentation
- **Cmd+L select line**: Changed from Ctrl+L to match VSCode standard
- **Ctrl+Space trigger suggestions**: Manual autocomplete trigger
- **Cmd+Shift+M show problems**: Opens Problems panel
- **Cmd+. Go to Definition**: Re-added with proper shortcut (was Cmd+Enter, conflicted with insert line)
- **Fuzzy Search in Command Palette**: Subsequence matching with scoring (prefix, word boundary, consecutive bonuses)
- **Search Match Highlighting**: Search panel MatchRow highlights matched substrings with bold+accent
- **Open Editors Section**: Collapsible section at top of explorer showing all open tabs with unsaved indicators
- **File Change Indicators**: Unsaved files show accent dot in file tree
- **Lazy File Tree Loading**: Only 2 levels loaded eagerly; deeper dirs load on-demand when expanded
- **Wire All Command Palette Commands**: Cut/Copy/Paste, Open Folder, Save As, Expand/Shrink Selection, Welcome, Documentation, New Window (multi-scene), Toggle Full Screen
- **Welcome Sheet**: Command palette Welcome command opens WelcomeView as sheet
- **File Tree Filter**: Search/filter bar in explorer sidebar filters files by name
- **Tab Context Menu**: Close All, Close Saved, Copy Path, Reveal in Explorer, Pin/Unpin
- **Quick Open Recent Files**: Recently opened files shown in sections with clock icons
- **Quick Open :N Go-to-Line**: Type `:42` in Quick Open to navigate to line 42
- **Quick Open > Command Palette**: Type `>` in Quick Open to switch to Command Palette
- **Indent Guide Lines**: Vertical indent guide lines at each tab stop in editor (Canvas overlay)
- **Tab Drag-to-Reorder**: Already implemented — drag tabs to reorder + drag to new window

**Performance fixes:**
- LineNumbers scroll: O(n)→O(viewport) with binary search
- Cursor position: O(n)→O(log n) with cached newline index (both RunestoneEditorView AND SyntaxHighlightingTextView)
- Debug logging removed from hot path
- filteredEntries cached, localSaves capped at 500
- CodeFoldingManager: regex patterns compiled once as static properties (was recompiling per line)
- SearchManager: 10k results cap prevents OOM on broad searches
- SyntaxHighlightingTextView: updateLineCount replaced components(separatedBy:) with zero-allocation UTF-8 byte scan
- FileSystemNavigator: lazy tree loading reduces initial workspace open from O(entire tree) to O(2 levels)

**Bug fixes (all 14 original issues RESOLVED):**
- Build errors (GitManager NativeGitReader, ContentView scope)
- Race conditions (isApplyingHighlighting NSLock, saveActiveTab DispatchWorkItem)
- Editor: keyboard shortcuts wired, indent uses dynamic tab size, block comments for HTML/CSS, bracket colorization skips strings/comments
- Git: remote branch checkout, stash list populated, packed-refs cleanup
- UI: regex error display, NavigationStack, dynamic autocomplete position
- replaceAll error feedback, SettingsView dead code removal (~145 lines)
- All compiler warnings resolved: SSHManager infinite recursion, HapticManager @MainActor, unused results, deprecated onChange
- SearchManager: 10MB size guard added to replace (was missing, could OOM)
- SSHManager: UInt128 operator no longer causes infinite recursion
- HapticManager: @MainActor isolation for UIKit feedback generators

**🟢 All 14 original documented issues: RESOLVED ✅**

**Remaining feature gaps (not bugs — documented):**
- Extensions system is UI-only (no real loading — iOS sandbox limitation)
- No DAP debugger protocol (but real JS + LLDB/GDB over SSH work)
- SSH: no RSA keys, no known_hosts verification, no ssh-agent
- Remote→local port forwarding is stub
- No true multi-cursor editing (UI exists but limited)
- No sticky scroll or bracket pair guide lines (bracket pair coloring works)

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
**[SWE-1 | 5:56 AM]** Session 3 complete. 24 commits, 0 errors, 0 warnings. All 14 original issues resolved. Added inline AI suggestions, language-aware autocomplete, go-to-definition, hover info, conditional breakpoints, chunked SFTP, sidebar resize, undo grouping, format undo, find/replace polish. Build target updated to iPad Pro 13-inch (M5).

**[SWE-1 | 11:45 AM]** Session 3 continued. 7 more commits: fuzzy command palette search, O(log n) cursor in SyntaxHighlightingTextView, search match highlighting, Open Editors section, unsaved file indicators, lazy file tree loading, all command palette commands wired. 34 total commits this session.
