# VSCode iPadOS — Project Status

> **Last updated:** March 17, 2026 by Claude Agent (Session 5, final)
>
> This file provides a quick snapshot of the project's current state.
> For detailed task tracking, see [BACKLOG.md](BACKLOG.md).
> For chronological progress, see [PROGRESS.md](PROGRESS.md).

---

## Quick Summary

| Metric | Value |
|--------|-------|
| **Total Swift Files** | 174 (286K+ lines) |
| **Total Commits** | 266 |
| **Build Status** | ✅ PASSING (iOS generic) |
| **Critical Bugs Open** | 1 (BUG-005, known/workaround) |
| **Key Features** | Editor, Git, SSH, SFTP, Terminal, AI, Themes, Search, Debug, Code Folding, Tunnel, Format |

---

## Feature Completeness

### ✅ Fully Functional
- **Runestone Code Editor** — TreeSitter syntax highlighting, native line numbers, code folding support, bracket matching, word occurrence highlighting
- **Legacy Editor** — UITextView + TextKit 1 + FoldingLayoutManager, tiered debounce, visible-range-only highlighting
- **Code Folding** — 932-line CodeFoldingManager, FoldingLayoutManager integration, Cmd+Shift+[/] shortcuts, Command Palette fold/unfold
- **Code Formatter** — Multi-language (Swift, JS/TS, Python, Go, Rust, C/C++, JSON, HTML, CSS, Markdown), Alt+Shift+F shortcut, Command Palette
- **Block Comments** — HTML (`<!-- -->`), CSS (`/* */`), XML/SVG toggle comment support
- **Line Comments** — Multi-language Cmd+/ with multi-line selection support
- **Git (Native)** — Pure-Swift NativeGitReader/Writer, commit, branch, diff, blame, stash, merge conflicts
- **Git Clone (HTTPS)** — Smart HTTP protocol, pack file parsing, working tree checkout, branch discovery, CloneRepositoryView UI
- **Git Fetch/Pull (HTTPS)** — Smart HTTP fallback when no SSH, fast-forward merge
- **Git Push (HTTPS)** — Full git-receive-pack protocol with pack file building, object graph walking, zlib compression
- **Git Push/Pull/Fetch (SSH)** — Full remote operations via SSH connection
- **SSH Manager** — 1761 lines, SwiftNIO SSH, Ed25519/ECDSA key auth, password auth, port forwarding, command execution
- **SFTP Manager** — Remote file browsing, read/write, wired into RemoteExplorerView
- **VSCode Tunnel** — Connect to VS Code tunnels, code-server, GitHub Codespaces; health monitoring, auto-reconnect
- **Terminal** — SwiftTerm-based terminal emulator + 30+ built-in local commands, pipe support
- **AI Assistant** — 1629-line AIManager with chat interface
- **Search** — 912-line SearchManager, workspace-wide find/replace, regex, sort, filter by extension
- **Find References** — Workspace-wide symbol search with FindReferencesService, binary search line index
- **Diagnostics** — Per-file linting (Swift, JS/TS, Python), force unwrap/eval/var detection
- **Themes** — 1272-line theme system with multiple VSCode-like themes
- **Debug** — 1558-line DebugManager + RemoteDebugger (1503 lines), breakpoints, JS debugging
- **AutoSave** — Automatic file saving with debounce, multiple modes
- **Command Palette** — Cmd+Shift+P, fuzzy search, recent commands, 40+ commands including format/comment/fold/git
- **Quick Open** — Cmd+P file search
- **Go to Line** — Ctrl+G
- **Go to Symbol** — Cmd+Shift+O
- **Keyboard Shortcuts** — Comprehensive iPad keyboard support (20+ shortcuts via KeyCommandBridge)
- **Minimap** — Side scrollbar with code overview
- **Bracket Matching** — Highlight matching brackets
- **Word Occurrence Highlighting** — Highlight all occurrences of selected word
- **Multi-cursor** — Basic multi-cursor support
- **Snippets** — Code snippet insertion via SnippetManager
- **Emmet** — HTML/CSS abbreviation expansion
- **Settings** — Font size, tab size, theme selection, feature toggles, word wrap
- **Onboarding** — First-run experience with feature overview
- **Accessibility** — VoiceOver labels across 10+ views

### 🔧 Partially Done / Needs Polish
- **Extension Manager** — Basic framework exists, no marketplace integration
- **iCloud Sync** — Feature-flagged off (enableiCloudSync=false)
- **Split Editor** — Basic split view exists, needs polish
- **Remote Port Forwarding** — Local→Remote works, Remote→Local is stub

### 📋 Remaining TODOs
- **CLEANUP-005**: Int.uuid Conversion Safety
- **CLEANUP-006**: Split Large Files (GitManager 3.3K, SyntaxHighlightingTextView 2.5K, EditorCore 2.5K)
- **FEAT**: Breadcrumbs navigation bar
- **FEAT**: Integrated diff viewer (side-by-side)
- **FEAT**: Git graph visualization
- **FEAT**: Extension marketplace
- **FEAT**: Collaborative editing
- **FEAT**: Format on save option
- **FEAT**: Selection formatting

---

## Architecture

```
App/
├── Services/           # Core business logic
│   ├── EditorCore.swift          (2512 lines) — Central state manager
│   ├── GitManager.swift          (3330 lines) — Native git + SSH + HTTPS push/pull
│   ├── SSHManager.swift          (1761 lines) — SwiftNIO SSH
│   ├── SFTPManager.swift         (558 lines)  — Remote file operations
│   ├── AIManager.swift           (1629 lines) — AI chat integration
│   ├── DebugManager.swift        (1558 lines) — Debug session management
│   ├── SearchManager.swift       (912 lines)  — Workspace search
│   ├── CodeFoldingManager.swift  (932 lines)  — Code folding regions
│   ├── CodeFormatter.swift       (412 lines)  — Multi-language formatting
│   ├── FindReferencesService.swift (422 lines) — Symbol reference search
│   ├── ThemeManager.swift        — Theme switching
│   ├── AutoSaveManager.swift     (186 lines)  — Auto-save with debounce
│   ├── VSCodeTunnelManager.swift (322 lines)  — VS Code tunnel/Codespaces
│   └── NativeGit/                — Pure-Swift git (reader 1160, writer)
├── Views/
│   ├── ContentView.swift         (1663 lines) — Main app layout
│   ├── Editor/
│   │   ├── RunestoneEditorView.swift        (1633 lines) — TreeSitter editor
│   │   ├── SyntaxHighlightingTextView.swift (2546 lines) — Legacy editor
│   │   └── FoldingLayoutManager.swift
│   ├── Panels/
│   │   ├── TerminalView.swift    (2398 lines) — SSH + local terminal
│   │   ├── SearchView.swift      (1385 lines) — Workspace search UI
│   │   ├── GitView.swift         (1126 lines) — Source control panel
│   │   ├── PortsView.swift       (795 lines)  — Port forwarding
│   │   ├── RemoteExplorerView.swift          — SSH file browser
│   │   └── AIAssistantView.swift (939 lines)
│   ├── CommandPaletteView.swift  (460 lines)  — Cmd+Shift+P
│   ├── CloneRepositoryView.swift (597 lines)  — Git clone UI
│   ├── KeyCommandBridge.swift    (313 lines)  — Keyboard shortcuts
│   └── VSCodeTunnelView.swift    (559 lines)  — Remote VS Code WebView
└── Models/
    └── Theme.swift               (1272 lines)
```

---

## What Makes This a Real VS Code iPad App

1. **Native Code Editor** — Runestone with TreeSitter for real syntax highlighting across 8+ languages
2. **Full Git** — Clone, commit, push, pull, fetch, branch, diff, blame, stash, merge conflicts — all native, no server needed
3. **SSH Remote Development** — Connect to any server, browse files via SFTP, run commands
4. **VS Code Tunnel Support** — Connect to existing VS Code tunnels, code-server, or Codespaces
5. **Integrated Terminal** — SwiftTerm-based with SSH and local command support
6. **Professional Editor Features** — Code folding, formatting, block/line comments, bracket matching, multi-cursor, minimap, find references
7. **Command Palette** — VS Code's signature Cmd+Shift+P with 40+ commands
8. **Keyboard-First** — 20+ keyboard shortcuts matching VS Code conventions
9. **AI Integration** — Built-in AI assistant for code help
10. **Port Forwarding** — SSH tunnels for accessing remote services

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
