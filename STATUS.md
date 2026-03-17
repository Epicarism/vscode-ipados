# VSCode iPadOS — Project Status

> **Last updated:** March 17, 2026 by Claude Agent (Session 5)
>
> This file provides a quick snapshot of the project's current state.
> For detailed task tracking, see [BACKLOG.md](BACKLOG.md).
> For chronological progress, see [PROGRESS.md](PROGRESS.md).

---

## Quick Summary

| Metric | Value |
|--------|-------|
| **Total Swift Files** | 174 (84K+ lines) |
| **Build Status** | ✅ PASSING (iOS generic) |
| **Critical Bugs Open** | 1 (BUG-005, known/workaround) |
| **Key Features** | Editor, Git, SSH, SFTP, Terminal, AI, Themes, Search, Debug, Code Folding, Tunnel |

---

## Feature Completeness

### ✅ Fully Functional
- **Syntax Highlighting Editor** — UITextView + TextKit 1 + FoldingLayoutManager, tiered debounce (80ms-1.5s), visible-range-only for large files, background thread highlighting
- **Code Folding** — 932-line CodeFoldingManager, FoldingLayoutManager integration, Cmd+Shift+[/] shortcuts
- **Code Formatter** — Multi-language (Swift, JS/TS, Python, Go, Rust, C/C++, JSON, HTML, CSS), Cmd+Shift+F
- **Comment Toggle** — Multi-language Cmd+/ with multi-line selection support
- **Git (Native)** — Pure-Swift NativeGitReader/Writer, commit, branch, diff, blame, stash, merge conflicts
- **Git Clone (HTTPS)** — Smart HTTP protocol, pack file parsing, working tree checkout, branch discovery
- **Git Fetch/Pull (HTTPS)** — Smart HTTP fallback when no SSH, fast-forward merge
- **Git Push/Pull/Fetch (SSH)** — Full remote operations via SSH connection
- **SSH Manager** — 1761 lines, SwiftNIO SSH, key-based & password auth, command execution
- **SFTP Manager** — Remote file browsing, read/write, wired into RemoteExplorerView
- **VSCode Tunnel** — Connect to existing tunnel URLs, health monitoring
- **Terminal** — 2398-line local SwiftTerm terminal with command support
- **AI Assistant** — 1629-line AIManager with chat interface
- **Search** — 912-line SearchManager, workspace-wide find/replace, regex support
- **Find References** — Workspace-wide symbol search across all open tabs
- **Diagnostics** — Per-file linting (Swift, JS/TS, Python), force unwrap/eval/var detection
- **Themes** — 1272-line theme system with multiple VSCode-like themes
- **Debug** — 1558-line DebugManager + RemoteDebugger (1503 lines)
- **AutoSave** — Automatic file saving with debounce
- **Command Palette** — Cmd+Shift+P, fuzzy search, recent commands
- **Quick Open** — Cmd+P file search
- **Go to Line** — Ctrl+G
- **Go to Symbol** — Cmd+Shift+O
- **Keyboard Shortcuts** — Comprehensive iPad keyboard support
- **Minimap** — Side scrollbar with code overview
- **Bracket Matching** — Highlight matching brackets
- **Word Occurrence Highlighting** — Highlight all occurrences of selected word
- **Multi-cursor** — Basic multi-cursor support
- **Snippets** — Code snippet insertion
- **Settings** — Font size, tab size, theme selection, feature toggles

### 🔧 Partially Done / Needs Polish
- **Git Push (HTTPS)** — Requires SSH; HTTPS push needs git-receive-pack protocol
- **Extension Manager** — Basic framework exists, no marketplace integration
- **iCloud Sync** — Feature-flagged off (enableiCloudSync=false)
- **Split Editor** — Basic split view exists, needs polish

### 📋 Remaining TODOs
- **CLEANUP-005**: Int.uuid Conversion Safety
- **CLEANUP-006**: Split Large Files (GitManager 3K, SyntaxHighlightingTextView 2.5K, EditorCore 2.5K)
- **FEAT**: Breadcrumbs navigation bar
- **FEAT**: Integrated diff viewer (side-by-side)
- **FEAT**: Git graph visualization
- **FEAT**: Extension marketplace
- **FEAT**: Collaborative editing

---

## Architecture

```
App/
├── Services/           # Core business logic
│   ├── EditorCore.swift          (2512 lines) — Central state manager
│   ├── GitManager.swift          (3018 lines) — Native git + SSH git operations
│   ├── SSHManager.swift          (1761 lines) — SwiftNIO SSH
│   ├── SFTPManager.swift         (558 lines)  — Remote file operations
│   ├── AIManager.swift           (1629 lines) — AI chat integration
│   ├── DebugManager.swift        (1558 lines) — Debug session management
│   ├── SearchManager.swift       (912 lines)  — Workspace search
│   ├── CodeFoldingManager.swift  (932 lines)  — Code folding regions
│   ├── CodeFormatter.swift       (412 lines)  — Multi-language formatting
│   ├── ThemeManager.swift        — Theme switching
│   ├── AutoSaveManager.swift     (186 lines)  — Auto-save with debounce
│   └── NativeGit/                — Pure-Swift git (reader 1160, writer)
├── Views/
│   ├── ContentView.swift         (1663 lines) — Main app layout
│   ├── Editor/
│   │   ├── SyntaxHighlightingTextView.swift (2546 lines)
│   │   ├── RunestoneEditorView.swift        (1633 lines)
│   │   └── FoldingLayoutManager.swift
│   ├── Panels/
│   │   ├── TerminalView.swift    (2398 lines)
│   │   ├── SearchView.swift      (1385 lines)
│   │   ├── GitView.swift         (1126 lines)
│   │   └── AIAssistantView.swift (939 lines)
│   └── CommandPaletteView.swift
└── Models/
    └── Theme.swift               (1272 lines)
```

---

## Build & Run

```bash
# Build for iOS
xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj \
  -scheme VSCodeiPadOS \
  -destination 'generic/platform=iOS' build

# Run in simulator
xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj \
  -scheme VSCodeiPadOS \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' \
  build
```
