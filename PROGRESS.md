# VSCode iPadOS — Progress Log

> **Last updated:** March 16, 2026  
> **Convention:** Most recent entries at the top.  
> **Other SWEs:** Add your entries here when you complete work.

---

## March 16, 2026 — Claude Agent

### Codebase Audit & Planning
- Full codebase audit of 157 Swift files (~62K lines)
- Identified 34 actionable TODO/FIXME/BUG comments across codebase
- Created team communication docs: `BACKLOG.md`, `PROGRESS.md`, `AGENTS.md`
- Truncated 135MB runaway error log (`logs/worker-launchd-err.log`)

### Bug Fixes (In Progress)
- **BUG-001:** AI stop/cancel button — adding cancellation support
- **BUG-002:** New Window menu command — implementing window creation
- **BUG-006:** Hardcoded notification strings — centralizing to constants
- **CONFIG-001:** README wrong project name — fixing references

### Cleanup (In Progress)
- Removing dead backup files (.bak files)
- Removing dead SceneDelegate code
- Creating centralized notification name constants
- Implementing Stage Manager configuration

---

## Prior Work (Pre-March 16)

### Features Implemented
- 18 color themes (Dark+, Light+, Monokai, Solarized, Dracula, etc.)
- Dual editor engine: SyntaxHighlightingTextView + Runestone (tree-sitter)
- 11 language syntax support
- Multi-tab editor with pinning, preview mode
- Split editor (vertical, horizontal, grid)
- Command Palette (Cmd+Shift+P)
- Quick Open (Cmd+P), Go to Symbol, Go to Line
- Find & Replace with regex, glob patterns
- Multi-cursor support
- AI Assistant with 10 providers (OpenAI, Anthropic, Google, Groq, DeepSeek, Mistral, Kimi, GLM, Ollama, on-device MLX)
- On-device LLM via Apple MLX (Qwen3, Nanbeige models)
- JavaScript execution via JavaScriptCore
- WASM runner
- Git integration (status, staging, branching via SSH stubs)
- GitHub OAuth authentication
- Terminal panel
- Debug panel (stub)
- Markdown preview
- Extensions panel UI
- Minimap, breadcrumbs, git gutter
- Hover info, peek definition, inline suggestions
- Code folding, inlay hints
- Merge conflict view, color picker, JSON tree view
- Snippets manager, tasks view
- Auto-save, workspace settings
- Multi-window / Stage Manager support
- Workspace persistence (restore tabs on launch)
- Full keyboard shortcut system via UIKeyCommand + menu bar
- Notification toasts
- File drag & drop
- VS Code icon font (Codicon) integration
- Feature flags system

### Known Issues (Pre-existing)
- SSH Manager is entirely stub (13 TODOs)
- Git pull/push via GitHub API not yet implemented
- Python on-device execution (Pyodide) not implemented
- Format document not implemented
- Find references not implemented
- Remote debugging is stub
- Extension host doesn't actually run extensions
- ContentView.swift is 1378 lines (needs refactoring)
- EditorCore.swift is 1556 lines (needs refactoring)
