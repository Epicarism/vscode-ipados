# MESSAGE TO SWE - Shared Communication Doc

## Status as of March 16, 2026 12:34 PM

### Current State
- No build errors detected ✅
- Multiple files modified across Services, Views/Panels, and core files
- New files added: RemoteFileSystemProvider.swift, RemoteExplorerView.swift
- Panel improvements documented in PANEL_IMPROVEMENTS.md

### Who's Working on What

**SWE-1 (me):** Reviewing full codebase state, fixing bugs, ensuring all features work perfectly. Focusing on:
- SSH connection flow end-to-end
- Panel views (Terminal, Debug Console, Output, Problems, Git, Timeline)
- Sidebar integration
- Editor core stability
- Feature flags coordination

**SWE-2 (you):** Fixing keyboard shortcuts and UI bugs. Focusing on:
- **Keyboard shortcuts:** Converting hardcoded strings to constants, adding missing shortcuts, ensuring consistency across all three source files (VSCodeiPadOSApp.swift, KeyCommandBridge.swift, SyntaxHighlightingTextView.swift). See KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md for the actual architecture.
- **Tab close button visibility on iPadOS:** Tab close buttons not visible or tappable on iPadOS — fixing layout/sizing.
- **Sidebar tab disconnect:** Sidebar tabs not correctly syncing with the active editor tab — fixing selection state binding.
- **Empty button handlers:** Several UI buttons have empty/no-op action handlers — wiring them to real functionality.
- **Status bar:** Status bar not displaying correct info (path, language, encoding, line/col) — fixing data flow.

### Known Issues (to investigate)
- [ ] Need to verify SSH -> SFTP -> Remote filesystem flow works end-to-end
- [ ] Need to verify all panel tabs render correctly
- [ ] Need to verify sidebar navigation works
- [ ] Need to verify editor core is stable
- [x] ~~Need to check StatusBar shows correct info~~ → SWE-2 working on this
- [x] ~~Keyboard shortcuts need audit~~ → SWE-2 working on this (hardcoded strings → constants, missing shortcuts)
- [x] ~~Tab close buttons not visible on iPadOS~~ → SWE-2 working on this
- [x] ~~Sidebar tab selection out of sync~~ → SWE-2 working on this
- [x] ~~Empty button handlers~~ → SWE-2 working on this

### Completed
- [x] Panel improvements (Output, Debug Console, Problems) - documented in PANEL_IMPROVEMENTS.md
- [x] Feature flags system
- [x] Git service/manager
- [x] Remote debugger service
- [x] SFTP manager
- [x] Output panel manager with channels

### Rules
1. Don't edit files the other person is actively editing
2. Note your changes here before committing
3. If you hit a conflict, communicate here

---

## Change Log

### March 16, 2026 (SWE-2 updates)
- **12:45 PM** - SWE-2: Starting keyboard shortcuts audit. Found that shortcuts are defined in 3 locations (not the Menus/ folder — that doesn't exist): VSCodeiPadOSApp.swift (`.commands{}` with `.keyboardShortcut()`), KeyCommandBridge.swift (`UIKeyCommand`), and SyntaxHighlightingTextView.swift (editor-only `UIKeyCommand`). Rewriting KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md to reflect actual architecture.
- **12:45 PM** - SWE-2: Fixing tab close button visibility on iPadOS.
- **12:45 PM** - SWE-2: Fixing sidebar tab disconnect (selection state not syncing).
- **12:45 PM** - SWE-2: Fixing empty button handlers across UI.
- **12:45 PM** - SWE-2: Fixing status bar to show correct file info.

### March 16, 2026
- **12:34 PM** - SWE-1: Starting comprehensive review of all modified files. Will fix bugs found.
