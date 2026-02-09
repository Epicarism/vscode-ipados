# VSCodeiPadOS - COMPLETE FUNCTIONAL TEST PLAN

## CRITICAL NOTE
The iOS Simulator can only take screenshots and change appearance via `xcrun simctl`.
To TEST ACTUAL FUNCTIONALITY, we need to:
1. Analyze code for bugs
2. Check API endpoints work
3. Verify data flows
4. Run the app and observe behavior
5. Check console logs for errors

---

# COMPLETE FEATURE LIST (200+ Features)

## 1. AI ASSISTANT (AIManager.swift - 756 lines)
### Providers:
- [ ] OpenAI (GPT-4o, GPT-4o-mini, GPT-4-turbo, GPT-3.5-turbo)
- [ ] Anthropic (Claude Sonnet 4, Claude 3.5 Sonnet, Claude 3.5 Haiku, Claude 3 Opus)
- [ ] Google (Gemini 1.5 Pro, Gemini 1.5 Flash, Gemini Pro) **USER HAS API KEY**
- [ ] Kimi (Moonshot V1 8K/32K/128K)
- [ ] GLM (GLM-4, GLM-4 Flash, GLM-3 Turbo)
- [ ] Ollama Local (Code Llama, Llama 3, Mistral, DeepSeek Coder)

### AI Features to Test:
- [ ] API key storage/retrieval
- [ ] Model selection dropdown
- [ ] Send message to AI
- [ ] Receive response
- [ ] Code block extraction from responses
- [ ] Insert code from AI response
- [ ] Chat history persistence
- [ ] New chat session
- [ ] Error handling (invalid API key, network error)
- [ ] Loading indicators
- [ ] Streaming responses

### AI Code Actions:
- [ ] Explain selected code
- [ ] Fix selected code
- [ ] Generate tests for code
- [ ] Refactor code
- [ ] Document code

---

## 2. SYNTAX HIGHLIGHTING (SyntaxHighlightingTextView.swift - 1503 lines)
### Languages to Test:
- [ ] Swift - keywords (func, let, var, class, struct, enum, protocol)
- [ ] Swift - strings (colored correctly)
- [ ] Swift - comments (// and /* */)
- [ ] Swift - numbers
- [ ] Swift - types
- [ ] JavaScript - keywords (function, const, let, var)
- [ ] JavaScript - strings
- [ ] JavaScript - comments
- [ ] TypeScript - types and interfaces
- [ ] Python - keywords (def, class, import)
- [ ] Python - strings (single, double, triple quotes)
- [ ] HTML - tags, attributes
- [ ] CSS - selectors, properties
- [ ] JSON - keys, values, strings, numbers
- [ ] Markdown - headers, bold, italic, code

### Editor Features:
- [ ] Line numbers display
- [ ] Current line highlight
- [ ] Cursor blinking
- [ ] Text selection
- [ ] Copy/paste
- [ ] Undo/redo
- [ ] Scroll position tracking
- [ ] Font family setting
- [ ] Font size setting

---

## 3. MULTI-CURSOR EDITING (MultiCursorTextView.swift - 281 lines)
- [ ] Add cursor with Option+Click
- [ ] Add next occurrence (Cmd+D)
- [ ] Select all occurrences (Cmd+Shift+L)
- [ ] Type at multiple cursors simultaneously
- [ ] Delete at multiple cursors
- [ ] Cursor blinking animation
- [ ] Exit multi-cursor mode (Esc)

---

## 4. CODE FOLDING (CodeFoldingManager.swift - 131 lines)
- [ ] Detect foldable regions (functions, classes, blocks)
- [ ] Fold/unfold button in gutter
- [ ] Collapsed region indicator
- [ ] Expand all / Collapse all
- [ ] Persist fold state

---

## 5. MINIMAP (MinimapView.swift - 465 lines)
- [ ] Minimap renders code preview
- [ ] Syntax coloring in minimap
- [ ] Visible region overlay
- [ ] Click minimap to scroll
- [ ] Drag minimap to scroll
- [ ] Git diff indicators in minimap
- [ ] Toggle minimap on/off

---

## 6. SPLIT EDITOR (SplitEditorView.swift - 755 lines)
- [ ] Split editor right
- [ ] Split editor down
- [ ] Independent panes with own tabs
- [ ] Resize split with drag handle
- [ ] Close pane
- [ ] Drag tabs between panes
- [ ] Sync scroll option
- [ ] Different files in each pane

---

## 7. GIT INTEGRATION (GitManager.swift - 235 lines, GitService.swift - 152 lines)
### NOTE: iOS uses MOCK data - real git requires server backend
- [ ] Show current branch
- [ ] Branch list dropdown
- [ ] Create new branch
- [ ] Switch branch
- [ ] Delete branch
- [ ] Stage files (+)
- [ ] Unstage files (-)
- [ ] Commit with message
- [ ] View changes list
- [ ] Pull button
- [ ] Push button
- [ ] Stash save
- [ ] Stash apply
- [ ] Stash pop
- [ ] Discard changes
- [ ] View commit history

### Git Gutter (GitGutterView.swift - 622 lines):
- [ ] Added lines indicator (green)
- [ ] Modified lines indicator (blue)
- [ ] Deleted lines indicator (red triangle)
- [ ] Inline blame labels

### Diff View (DiffComponents.swift - 220 lines):
- [ ] Inline diff view
- [ ] Side-by-side diff view
- [ ] Hunk headers
- [ ] Addition highlighting
- [ ] Deletion highlighting

### Merge Conflicts (MergeConflictView.swift - 110 lines):
- [ ] Current vs Incoming display
- [ ] Accept Current button
- [ ] Accept Incoming button
- [ ] Accept Both button

---

## 8. FILE EXPLORER (FileTreeView.swift - 122 lines, FileSystemNavigator.swift - 293 lines)
- [ ] Load folder/workspace
- [ ] Display file tree hierarchy
- [ ] Expand/collapse folders
- [ ] File icons by extension
- [ ] Folder icons (open/closed)
- [ ] Create new file
- [ ] Create new folder
- [ ] Rename file/folder
- [ ] Delete file/folder
- [ ] Move file/folder
- [ ] Refresh tree
- [ ] Collapse all
- [ ] Sort (dirs first, alphabetical)
- [ ] Click to open file

### File Icons (FileIconView.swift - 162 lines):
- [ ] Swift icon
- [ ] JavaScript icon
- [ ] TypeScript icon
- [ ] Python icon
- [ ] HTML icon
- [ ] CSS icon
- [ ] JSON icon
- [ ] Markdown icon
- [ ] Image icons
- [ ] Config files (Dockerfile, .gitignore, package.json)

---

## 9. TAB BAR (TabBarView.swift - 223 lines)
- [ ] Show open file tabs
- [ ] Active tab highlight
- [ ] Close tab (X button)
- [ ] Unsaved indicator (dot)
- [ ] Pin tab
- [ ] Unpin tab
- [ ] Drag to reorder tabs
- [ ] Context menu (Close, Close Others, Close to Right)
- [ ] Preview tabs (italic)
- [ ] File type icons in tabs
- [ ] Scroll tabs horizontally

---

## 10. COMMAND PALETTE (CommandPalette.swift - 702 lines)
- [ ] Open with Cmd+Shift+P
- [ ] Fuzzy search commands
- [ ] 60+ commands available
- [ ] Keyboard shortcuts displayed
- [ ] Recent commands section
- [ ] Category badges
- [ ] Keyboard navigation (up/down/enter)
- [ ] Close with Escape
- [ ] Execute selected command

### Command Categories:
- [ ] File commands (New, Open, Save, Close)
- [ ] Edit commands (Undo, Redo, Cut, Copy, Paste)
- [ ] Selection commands (Select All, Expand Selection)
- [ ] View commands (Toggle Sidebar, Toggle Terminal)
- [ ] Go commands (Go to File, Go to Symbol, Go to Line)
- [ ] Run commands (Start Debugging, Stop)
- [ ] Terminal commands (New Terminal, Clear)
- [ ] Preferences commands (Settings, Themes)
- [ ] Help commands (Welcome, Documentation)

---

## 11. QUICK OPEN (QuickOpen.swift - 363 lines)
- [ ] Open with Cmd+P
- [ ] Fuzzy search file names
- [ ] Search file paths
- [ ] Open files section
- [ ] Workspace files section
- [ ] File type icons
- [ ] Keyboard navigation
- [ ] Open selected file

---

## 12. GO TO SYMBOL (GoToSymbol.swift - 639 lines)
- [ ] Open with Cmd+Shift+O
- [ ] Parse Swift symbols
- [ ] Parse JavaScript/TypeScript symbols
- [ ] Parse Python symbols
- [ ] Symbol type icons (function, class, property, etc.)
- [ ] Fuzzy search symbols
- [ ] Type filter with : prefix
- [ ] Group by type toggle
- [ ] Navigate to symbol line

---

## 13. SEARCH & REPLACE (SearchManager.swift - 681 lines)
- [ ] Search in current file
- [ ] Search in open files
- [ ] Search in workspace
- [ ] Case sensitive toggle
- [ ] Whole word toggle
- [ ] Regex toggle
- [ ] Include/exclude patterns
- [ ] Search results list
- [ ] Navigate to result
- [ ] Replace current
- [ ] Replace all
- [ ] Search history

---

## 14. AUTOCOMPLETE (AutocompleteManager.swift - 355 lines)
- [ ] Show suggestions popup
- [ ] Keyword suggestions
- [ ] Stdlib suggestions (Swift types, functions)
- [ ] File symbol suggestions
- [ ] Member completions (String., Array., etc.)
- [ ] Keyboard navigation
- [ ] Insert suggestion (Tab/Enter)
- [ ] Filter by prefix

---

## 15. SNIPPETS (SnippetsManager.swift - 215 lines)
- [ ] Built-in Swift snippets (func, guard, iflet, struct, class, enum)
- [ ] Snippet picker view
- [ ] Search snippets
- [ ] Insert snippet
- [ ] Placeholder expansion ($1, $2...)
- [ ] Custom snippets
- [ ] Persist custom snippets

---

## 16. HOVER INFO (HoverInfoManager.swift - 85 lines)
- [ ] Show hover on tap/hover
- [ ] Display type signature
- [ ] Display documentation
- [ ] Position at cursor
- [ ] Dismiss hover

---

## 17. INLAY HINTS (InlayHintsManager.swift - 186 lines)
- [ ] Swift type inference hints
- [ ] Display `: Type` after variables
- [ ] Detect Bool, String, Int, Double
- [ ] Detect Array, Dictionary
- [ ] Detect constructor calls
- [ ] Detect enum members

---

## 18. PEEK DEFINITION (PeekDefinitionView.swift - 100 lines)
- [ ] Show definition inline
- [ ] Display ±5 lines context
- [ ] Syntax highlighting in peek
- [ ] Open in editor button
- [ ] Close button

---

## 19. GO TO DEFINITION (NavigationManager.swift - 906 lines)
- [ ] Find definition (F12 / Cmd+Click)
- [ ] Navigate to definition
- [ ] Navigation history (back/forward)
- [ ] Multiple definitions picker
- [ ] Index files for symbols

---

## 20. BREADCRUMBS (BreadcrumbsView.swift - 75 lines)
- [ ] Show file path
- [ ] Clickable path segments
- [ ] Current symbol display
- [ ] Folder/file icons

---

## 21. STICKY HEADER (StickyHeaderView.swift - 79 lines)
- [ ] Show class/function context
- [ ] Update on scroll
- [ ] Indented by scope
- [ ] Click to navigate
- [ ] Max 3 levels

---

## 22. TERMINAL (TerminalView.swift - 778 lines)
- [ ] Terminal view display
- [ ] Multiple terminal tabs
- [ ] Split terminals
- [ ] Command input
- [ ] Command output display
- [ ] Command history
- [ ] Local commands (help, clear, echo, date, whoami)
- [ ] ANSI color support
- [ ] Copy/paste
- [ ] Mobile helper bar (Tab, Esc, Ctrl+C)
- [ ] SSH connection support

---

## 23. DEBUG VIEW (DebugView.swift - 233 lines, DebugManager.swift - 393 lines)
- [ ] Play/Stop/Restart buttons
- [ ] Variables panel (expandable tree)
- [ ] Watch expressions (add/edit/remove)
- [ ] Call stack display
- [ ] Breakpoints list
- [ ] Console output
- [ ] Step over/into/out controls

### Launch Configs (LaunchManager.swift - 257 lines):
- [ ] Load launch.json
- [ ] Config selector dropdown
- [ ] Built-in templates (Swift, Node.js, Python)
- [ ] Variable expansion (${workspaceFolder})

---

## 24. PROBLEMS PANEL (ProblemsView.swift)
- [ ] Show errors
- [ ] Show warnings
- [ ] Navigate to problem
- [ ] Filter by severity

---

## 25. OUTPUT PANEL (OutputView.swift)
- [ ] Task output
- [ ] Clear output
- [ ] Scroll to bottom

---

## 26. TASKS (TasksManager.swift - 367 lines, TasksView.swift - 124 lines)
- [ ] Load tasks.json
- [ ] Task list display
- [ ] Run task button
- [ ] Stop task button
- [ ] Built-in templates
- [ ] Task output to panel

---

## 27. SETTINGS (SettingsManager.swift - 99 lines, SettingsView.swift - 415 lines)
- [ ] Settings panel display
- [ ] Search settings
- [ ] Font size slider (8-32)
- [ ] Font family picker
- [ ] Tab size stepper (1-8)
- [ ] Word wrap toggle
- [ ] Auto save picker
- [ ] Minimap toggle
- [ ] Line numbers toggle
- [ ] Persist settings

---

## 28. THEMES (ThemeManager.swift - 186 lines)
- [ ] Dark+ theme
- [ ] Light+ theme
- [ ] Monokai theme
- [ ] Solarized Dark theme
- [ ] Theme affects editor
- [ ] Theme affects sidebar
- [ ] Theme affects status bar
- [ ] Persist theme selection

---

## 29. WORKSPACE SETTINGS (WorkspaceManager.swift - 238 lines)
- [ ] Load .vscode/settings.json
- [ ] Override global settings
- [ ] Merge settings
- [ ] Save workspace settings

---

## 30. WORKSPACE TRUST (WorkspaceTrustManager.swift - 40 lines)
- [ ] Trust dialog on open
- [ ] Trust/Don't Trust buttons
- [ ] Persist trusted paths
- [ ] Check trust status

---

## 31. STATUS BAR (StatusBarView.swift - 135 lines)
- [ ] Branch name display
- [ ] Pull/Push buttons
- [ ] Stash count
- [ ] Problems count
- [ ] Cursor position (Ln, Col)
- [ ] Indentation display
- [ ] Encoding display (UTF-8)
- [ ] EOL display (LF/CRLF)
- [ ] Language mode
- [ ] Click actions

---

## 32. SIDEBAR (SidebarView.swift - 284 lines)
- [ ] Activity bar icons (6 sections)
- [ ] Explorer panel
- [ ] Search panel
- [ ] Source Control panel
- [ ] Run & Debug panel
- [ ] Extensions panel
- [ ] Testing panel
- [ ] Resize sidebar (170-600px)
- [ ] Collapse/expand sidebar

---

## 33. JSON TREE VIEW (JSONTreeView.swift - 164 lines)
- [ ] Parse JSON file
- [ ] Display as tree
- [ ] Expand/collapse nodes
- [ ] Syntax-colored values
- [ ] Array/object indicators

---

## 34. MARKDOWN PREVIEW (MarkdownPreviewView.swift)
- [ ] Render markdown to HTML
- [ ] Split view with editor
- [ ] Headers styling
- [ ] Code blocks
- [ ] Lists
- [ ] Links
- [ ] Images

---

## 35. COLOR PICKER (ColorPickerManager.swift - 65 lines)
- [ ] Show color picker
- [ ] Color to hex conversion
- [ ] Insert color code

---

## 36. RECENT FILES (RecentFileManager.swift - 44 lines)
- [ ] Track recently opened files
- [ ] Max 10 files
- [ ] Persist to UserDefaults
- [ ] Display in welcome screen

---

## 37. SPOTLIGHT INTEGRATION (SpotlightManager.swift - 162 lines)
- [ ] Index opened files
- [ ] Search from iOS Spotlight
- [ ] File metadata
- [ ] Content preview

---

## 38. KEYBOARD SHORTCUTS
- [ ] Cmd+S - Save
- [ ] Cmd+N - New File
- [ ] Cmd+W - Close Tab
- [ ] Cmd+P - Quick Open
- [ ] Cmd+Shift+P - Command Palette
- [ ] Cmd+F - Find
- [ ] Cmd+H - Replace
- [ ] Cmd+Shift+F - Find in Files
- [ ] Cmd+B - Toggle Sidebar
- [ ] Cmd+J - Toggle Panel
- [ ] Cmd+D - Add Selection
- [ ] Cmd+G - Go to Line
- [ ] F12 - Go to Definition

---

# TESTS THAT REQUIRE ACTUAL INTERACTION

These cannot be tested with screenshots alone:

1. **AI Assistant** - Need to send a real message and verify response
2. **Syntax Highlighting** - Need to open a code file and verify colors
3. **Autocomplete** - Need to type and see suggestions
4. **Git** - Need to verify if mock or real
5. **Terminal** - Need to type commands
6. **Split Editor** - Need to drag and resize
7. **Tab Drag** - Need to drag tabs
8. **Search** - Need to type query and see results
9. **Settings** - Need to change values and verify persistence
10. **Theme Switch** - Need to apply and verify all UI updates
