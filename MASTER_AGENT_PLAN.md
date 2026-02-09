# VSCodeiPadOS MASTER AGENT DEPLOYMENT PLAN

## Overview
- **Total Agents:** 400+
- **Timeline:** NOW
- **Goal:** Make this a REAL VS Code for iPad

---

# PHASE 1: CRITICAL FIXES (50 Agents) - Deploy First

## 1A. SSH Terminal - REAL (10 Agents)
**Coordinator:** opus
**Library:** Shout (via SPM)

| Agent | Task | Files |
|-------|------|-------|
| ssh-1 | Add Shout SPM dependency | Package.swift, .xcodeproj |
| ssh-2 | Create SSHManager service | Services/SSHManager.swift (NEW) |
| ssh-3 | SSH connection UI (host, user, password/key) | Views/Panels/SSHConnectionView.swift |
| ssh-4 | SSH session management (multiple sessions) | Services/SSHSessionManager.swift (NEW) |
| ssh-5 | Terminal PTY integration with Shout | Views/Panels/TerminalView.swift |
| ssh-6 | SSH key management (generate, import) | Services/SSHKeyManager.swift (NEW) |
| ssh-7 | Known hosts management | Services/KnownHostsManager.swift (NEW) |
| ssh-8 | SFTP file browser | Views/Panels/SFTPBrowserView.swift (NEW) |
| ssh-9 | Remote file editing (open/save via SFTP) | Services/RemoteFileManager.swift (NEW) |
| ssh-10 | SSH connection persistence (recent hosts) | Services/SSHHostsManager.swift (NEW) |

## 1B. Syntax Highlighting Fix & Test (10 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| syntax-1 | Audit current syntax implementation | Views/Editor/SyntaxHighlightingTextView.swift |
| syntax-2 | Fix Swift highlighting (keywords, types) | Services/SyntaxHighlighter.swift |
| syntax-3 | Fix JavaScript/TypeScript highlighting | Services/SyntaxHighlighter.swift |
| syntax-4 | Fix Python highlighting | Services/SyntaxHighlighter.swift |
| syntax-5 | Add HTML/CSS highlighting | Services/SyntaxHighlighter.swift |
| syntax-6 | Add JSON highlighting (keys, values) | Services/SyntaxHighlighter.swift |
| syntax-7 | Add Markdown highlighting | Services/SyntaxHighlighter.swift |
| syntax-8 | Test all languages, create test files | Tests/SyntaxTests/ |
| syntax-9 | Performance optimization (large files) | Views/Editor/SyntaxHighlightingTextView.swift |
| syntax-10 | Theme color integration | Services/ThemeManager.swift |

## 1C. Drag & Split Editor - Wire It Up (10 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| split-1 | Audit SplitEditorView, find disconnects | Views/Editor/SplitEditorView.swift |
| split-2 | Wire split buttons to actual split action | Views/Editor/SplitEditorView.swift |
| split-3 | Implement drag handle resizing | Views/Editor/SplitEditorView.swift |
| split-4 | Tab drag between panes | Views/TabBarView.swift |
| split-5 | Independent scroll per pane | Views/Editor/SplitEditorView.swift |
| split-6 | Sync scroll option | Views/Editor/SplitEditorView.swift |
| split-7 | Close pane button wiring | Views/Editor/SplitEditorView.swift |
| split-8 | Split state persistence | Services/EditorStateManager.swift |
| split-9 | Keyboard shortcuts for split | ContentView.swift |
| split-10 | Test all split scenarios | Tests/SplitEditorTests/ |

## 1D. Context Menus - Right Click (10 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| ctx-1 | Editor context menu (Cut, Copy, Paste, etc.) | Views/Editor/EditorContextMenu.swift (NEW) |
| ctx-2 | File tree context menu (New, Rename, Delete) | Views/FileTreeView.swift |
| ctx-3 | Tab context menu (Close, Pin, Close Others) | Views/TabBarView.swift |
| ctx-4 | Terminal context menu (Copy, Paste, Clear) | Views/Panels/TerminalView.swift |
| ctx-5 | Search results context menu | Views/Panels/SearchView.swift |
| ctx-6 | Git changes context menu (Stage, Discard) | Views/Panels/GitView.swift |
| ctx-7 | Sidebar context menus | Views/SidebarView.swift |
| ctx-8 | Breadcrumbs context menu | Views/Editor/BreadcrumbsView.swift |
| ctx-9 | Status bar context menus | Views/StatusBarView.swift |
| ctx-10 | Test all context menus | Tests/ContextMenuTests/ |

## 1E. Keyboard Shortcuts Fix (10 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| kbd-1 | Fix duplicate Cmd+O, Cmd+F conflicts | ContentView.swift |
| kbd-2 | Add Cmd+Plus/Cmd+Minus zoom | Views/Editor/SyntaxHighlightingTextView.swift |
| kbd-3 | Add Cmd+B toggle sidebar | ContentView.swift |
| kbd-4 | Add Cmd+J toggle panel | ContentView.swift |
| kbd-5 | Add Cmd+Shift+E focus explorer | ContentView.swift |
| kbd-6 | Add Cmd+Shift+F focus search | ContentView.swift |
| kbd-7 | Add Cmd+Shift+G focus git | ContentView.swift |
| kbd-8 | Add Cmd+` toggle terminal | ContentView.swift |
| kbd-9 | Add F2 rename, F12 go to definition | ContentView.swift |
| kbd-10 | Document all shortcuts, test | Docs/KeyboardShortcuts.md |

---

# PHASE 2: NEW FEATURES (100 Agents)

## 2A. iPadOS 26 Windows Support (20 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| win-1 | Research UIWindowScene APIs | Docs/WindowsResearch.md |
| win-2 | Multi-window scene delegate | AppDelegate.swift, SceneDelegate.swift |
| win-3 | New window from menu | Views/MenuBar.swift |
| win-4 | Window state restoration | Services/WindowStateManager.swift (NEW) |
| win-5 | Window size classes | ContentView.swift |
| win-6 | Drag file to new window | Views/FileTreeView.swift |
| win-7 | Window title (filename) | SceneDelegate.swift |
| win-8 | Window toolbar | Views/WindowToolbar.swift (NEW) |
| win-9 | Stage Manager optimization | Info.plist, ContentView.swift |
| win-10 | External display support | SceneDelegate.swift |
| win-11-20 | Testing & edge cases | Tests/WindowTests/ |

## 2B. Menu Bar Integration (20 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| menu-1 | UIMenuBuilder setup | AppDelegate.swift |
| menu-2 | File menu (New, Open, Save, Close) | Menus/FileMenu.swift (NEW) |
| menu-3 | Edit menu (Undo, Redo, Cut, Copy, Paste) | Menus/EditMenu.swift (NEW) |
| menu-4 | Selection menu (Select All, Expand) | Menus/SelectionMenu.swift (NEW) |
| menu-5 | View menu (Sidebar, Panel, Zoom) | Menus/ViewMenu.swift (NEW) |
| menu-6 | Go menu (File, Symbol, Line, Definition) | Menus/GoMenu.swift (NEW) |
| menu-7 | Run menu (Start, Stop, Debug) | Menus/RunMenu.swift (NEW) |
| menu-8 | Terminal menu (New, Split, Clear) | Menus/TerminalMenu.swift (NEW) |
| menu-9 | Help menu (Welcome, Docs, About) | Menus/HelpMenu.swift (NEW) |
| menu-10 | Wire menus to actions | Services/MenuActionHandler.swift (NEW) |
| menu-11-20 | Testing & polish | Tests/MenuTests/ |

## 2C. VS Code Codicon Icons (20 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| icon-1 | Download & add Codicon.ttf | Resources/Fonts/codicon.ttf |
| icon-2 | Create Codicon enum/helper | Utils/Codicon.swift (NEW) |
| icon-3 | Replace activity bar icons | Views/SidebarView.swift |
| icon-4 | Replace file tree icons | Views/FileIconView.swift |
| icon-5 | Replace tab bar icons | Views/TabBarView.swift |
| icon-6 | Replace status bar icons | Views/StatusBarView.swift |
| icon-7 | Replace editor icons (folding, etc.) | Views/Editor/*.swift |
| icon-8 | Replace panel icons | Views/Panels/*.swift |
| icon-9 | Replace command palette icons | Views/CommandPalette.swift |
| icon-10 | Replace all remaining SF Symbols | Global search & replace |
| icon-11-20 | Verify & test all icons | Tests/IconTests/ |

## 2D. Real Git - Native Swift Attempt (20 Agents)
**Coordinator:** opus
**Fallback:** Git via SSH if native fails

| Agent | Task | Files |
|-------|------|-------|
| git-1 | Research Swift git libraries | Docs/GitResearch.md |
| git-2 | Create GitCore protocol | Services/GitCore.swift (NEW) |
| git-3 | Implement git init | Services/NativeGit/Init.swift (NEW) |
| git-4 | Implement git status (parse .git) | Services/NativeGit/Status.swift (NEW) |
| git-5 | Implement git add (staging) | Services/NativeGit/Add.swift (NEW) |
| git-6 | Implement git commit | Services/NativeGit/Commit.swift (NEW) |
| git-7 | Implement git log | Services/NativeGit/Log.swift (NEW) |
| git-8 | Implement git diff | Services/NativeGit/Diff.swift (NEW) |
| git-9 | Implement git branch | Services/NativeGit/Branch.swift (NEW) |
| git-10 | Implement git checkout | Services/NativeGit/Checkout.swift (NEW) |
| git-11 | SSH Git fallback | Services/SSHGit.swift (NEW) |
| git-12 | Git UI wiring | Views/Panels/GitView.swift |
| git-13 | Git gutter integration | Views/Editor/GitGutterView.swift |
| git-14 | Diff view integration | Views/DiffComponents.swift |
| git-15-20 | Testing all git ops | Tests/GitTests/ |

## 2E. Code Folding Full Implementation (20 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| fold-1 | Audit CodeFoldingManager | Services/CodeFoldingManager.swift |
| fold-2 | Bracket-based folding | Services/CodeFoldingManager.swift |
| fold-3 | Indentation-based folding | Services/CodeFoldingManager.swift |
| fold-4 | Region comments (#region) | Services/CodeFoldingManager.swift |
| fold-5 | Fold gutter UI | Views/Editor/FoldingGutterView.swift (NEW) |
| fold-6 | Fold/unfold animations | Views/Editor/SyntaxHighlightingTextView.swift |
| fold-7 | Collapse all / Expand all | Services/CodeFoldingManager.swift |
| fold-8 | Fold state persistence | Services/EditorStateManager.swift |
| fold-9 | Keyboard shortcuts (Cmd+Opt+[/]) | ContentView.swift |
| fold-10-20 | Test all fold scenarios | Tests/FoldingTests/ |

---

# PHASE 3: AI & REMOTE DEV (100 Agents)

## 3A. AI Models Update & Inline Suggestions (30 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| ai-1 | Research latest OpenAI models | Docs/AIModelsResearch.md |
| ai-2 | Research latest Anthropic models | Docs/AIModelsResearch.md |
| ai-3 | Research latest Google Gemini models | Docs/AIModelsResearch.md |
| ai-4 | Research latest Kimi models | Docs/AIModelsResearch.md |
| ai-5 | Research latest GLM models | Docs/AIModelsResearch.md |
| ai-6 | Update AIManager model lists | Services/AIManager.swift |
| ai-7 | Add new provider: Groq | Services/AIManager.swift |
| ai-8 | Add new provider: Mistral | Services/AIManager.swift |
| ai-9 | Add new provider: DeepSeek | Services/AIManager.swift |
| ai-10 | Inline suggestions UI (ghost text) | Views/Editor/InlineSuggestionView.swift (NEW) |
| ai-11 | Inline suggestion trigger logic | Services/InlineSuggestionManager.swift (NEW) |
| ai-12 | Tab to accept suggestion | Views/Editor/SyntaxHighlightingTextView.swift |
| ai-13 | Partial accept (word by word) | Services/InlineSuggestionManager.swift |
| ai-14 | Suggestion caching | Services/SuggestionCache.swift (NEW) |
| ai-15 | Debounce/throttle requests | Services/InlineSuggestionManager.swift |
| ai-16 | Multi-line suggestions | Views/Editor/InlineSuggestionView.swift |
| ai-17 | Copilot-style experience | Services/InlineSuggestionManager.swift |
| ai-18 | AI settings UI update | Views/Panels/AIAssistantView.swift |
| ai-19 | API key secure storage (Keychain) | Services/KeychainManager.swift (NEW) |
| ai-20-30 | Testing all AI features | Tests/AITests/ |

## 3B. Remote Code Execution (30 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| remote-1 | SSH command execution | Services/SSHManager.swift |
| remote-2 | Run current file (detect language) | Services/RemoteRunner.swift (NEW) |
| remote-3 | Run selection | Services/RemoteRunner.swift |
| remote-4 | Run with arguments | Views/Panels/RunConfigView.swift (NEW) |
| remote-5 | Output streaming to panel | Views/Panels/OutputView.swift |
| remote-6 | Error parsing & navigation | Services/ErrorParser.swift (NEW) |
| remote-7 | Kill running process | Services/RemoteRunner.swift |
| remote-8 | Debug via SSH (GDB/LLDB) | Services/RemoteDebugger.swift (NEW) |
| remote-9 | Environment variables | Services/RemoteRunner.swift |
| remote-10 | Working directory handling | Services/RemoteRunner.swift |
| remote-11 | Python runner | Services/Runners/PythonRunner.swift (NEW) |
| remote-12 | Node.js runner | Services/Runners/NodeRunner.swift (NEW) |
| remote-13 | Swift runner | Services/Runners/SwiftRunner.swift (NEW) |
| remote-14 | Run task from tasks.json | Services/TasksManager.swift |
| remote-15 | User docs: Mac as server | Docs/MacServerSetup.md |
| remote-16-30 | Testing remote execution | Tests/RemoteTests/ |

## 3C. On-Device Code Execution Research (20 Agents)
**Coordinator:** opus
**Goal:** Figure out what's possible on-device

| Agent | Task | Files |
|-------|------|-------|
| ondev-1 | Research JavaScriptCore limits | Docs/OnDeviceResearch.md |
| ondev-2 | Research PythonKit/Pyto | Docs/OnDeviceResearch.md |
| ondev-3 | Research WebAssembly runtimes | Docs/OnDeviceResearch.md |
| ondev-4 | Research Lua interpreters | Docs/OnDeviceResearch.md |
| ondev-5 | Implement JS runner (JavaScriptCore) | Services/OnDevice/JSRunner.swift (NEW) |
| ondev-6 | Implement Python (if possible) | Services/OnDevice/PythonRunner.swift (NEW) |
| ondev-7 | Implement WASM runner | Services/OnDevice/WASMRunner.swift (NEW) |
| ondev-8 | Sandbox security audit | Docs/SecurityAudit.md |
| ondev-9 | Runner selector (on-device vs remote) | Services/RunnerSelector.swift (NEW) |
| ondev-10 | Warning UI (limited functionality) | Views/Panels/RunnerWarningView.swift (NEW) |
| ondev-11-20 | Testing on-device runners | Tests/OnDeviceTests/ |

## 3D. Search - Make It Real (20 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| search-1 | Wire SearchView to SearchManager | Views/Panels/SearchView.swift |
| search-2 | Remove hardcoded mock results | Views/Panels/SearchView.swift |
| search-3 | Real-time search as you type | Views/Panels/SearchView.swift |
| search-4 | Search result highlighting | Views/Panels/SearchView.swift |
| search-5 | Navigate to search result | Views/Panels/SearchView.swift |
| search-6 | Replace in files | Views/Panels/SearchView.swift |
| search-7 | Include/exclude patterns UI | Views/Panels/SearchView.swift |
| search-8 | Search history | Services/SearchManager.swift |
| search-9 | Regex search | Services/SearchManager.swift |
| search-10 | Whole word search | Services/SearchManager.swift |
| search-11-20 | Testing search | Tests/SearchTests/ |

---

# PHASE 4: TESTING & POLISH (150 Agents)

## 4A. Automated UI Tests (50 Agents)
**Coordinator:** opus

| Agent | Task | Files |
|-------|------|-------|
| test-1-10 | Editor tests (typing, selection, scroll) | UITests/EditorTests.swift |
| test-11-20 | Navigation tests (tabs, sidebar, panels) | UITests/NavigationTests.swift |
| test-21-30 | Git UI tests | UITests/GitTests.swift |
| test-31-40 | Terminal tests | UITests/TerminalTests.swift |
| test-41-50 | Command palette & quick open tests | UITests/CommandTests.swift |

## 4B. Feature Verification (50 Agents)
**Coordinator:** opus
Each agent tests a specific feature from FULL_FEATURE_TEST_PLAN.md

| Agent | Features to Test |
|-------|------------------|
| verify-1-5 | All syntax highlighting (10 languages) |
| verify-6-10 | All editor features (folding, minimap, etc.) |
| verify-11-15 | All navigation (command palette, quick open) |
| verify-16-20 | All git features |
| verify-21-25 | All terminal features |
| verify-26-30 | All AI features |
| verify-31-35 | All settings |
| verify-36-40 | All themes |
| verify-41-45 | All keyboard shortcuts |
| verify-46-50 | All context menus |

## 4C. Bug Fixes & Polish (50 Agents)
**Coordinator:** opus
Fix issues found by verification agents

| Agent | Task |
|-------|------|
| fix-1-50 | Dynamic assignment based on bugs found |

---

# DEPLOYMENT SEQUENCE

```
STEP 1: Deploy Phase 1 (50 agents) - CRITICAL FIXES
        └── Wait for completion (~1-2 hours)
        
STEP 2: Deploy Phase 2 (100 agents) - NEW FEATURES  
        └── Wait for completion (~2-3 hours)
        
STEP 3: Deploy Phase 3 (100 agents) - AI & REMOTE
        └── Wait for completion (~2-3 hours)
        
STEP 4: Deploy Phase 4 (150 agents) - TEST & POLISH
        └── Wait for completion (~2-3 hours)
        
TOTAL TIME: ~8-12 hours with all agents parallel
```

---

# AGENT CONFIGURATION

## Coordinator Agents (Opus)
- ssh-coordinator
- syntax-coordinator  
- split-coordinator
- context-coordinator
- keyboard-coordinator
- windows-coordinator
- menu-coordinator
- icons-coordinator
- git-coordinator
- folding-coordinator
- ai-coordinator
- remote-coordinator
- ondevice-coordinator
- search-coordinator
- test-coordinator

## Worker Agents (GLM default, Opus for complex)
- All implementation agents use GLM (fast, free)
- Upgrade to Opus if task fails or is complex

---

# SUCCESS CRITERIA

1. ✅ App compiles without errors
2. ✅ All 200+ features work (verified by tests)
3. ✅ SSH terminal connects to real servers
4. ✅ Git operations work (native or SSH)
5. ✅ Syntax highlighting works for all languages
6. ✅ Split editor fully functional
7. ✅ All context menus work
8. ✅ All keyboard shortcuts work
9. ✅ iPadOS 26 windows work
10. ✅ Menu bar fully integrated
11. ✅ VS Code icons throughout
12. ✅ AI inline suggestions work
13. ✅ Remote code execution works
14. ✅ Automated UI tests pass
