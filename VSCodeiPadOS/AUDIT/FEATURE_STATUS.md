# 🚦 Feature Status Matrix

## Legend
- ✅ **Working** - Fully implemented and tested
- 🟡 **Partial** - Implemented but incomplete or has issues
- 🔴 **Broken/Stub** - Code exists but doesn't work
- ⬜ **Missing** - Not implemented

---

## 📝 Editor Features

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Syntax Highlighting (TreeSitter) | ✅ | RunestoneEditorView.swift | 8 languages supported |
| Syntax Highlighting (Regex) | ✅ | SyntaxHighlightingTextView.swift | Fallback, 15+ languages |
| Line Numbers | ✅ | Runestone built-in | Toggle in settings |
| Code Folding | 🟡 | CodeFoldingManager.swift | Basic implementation |
| Multi-cursor | 🟡 | MultiCursorTextView.swift | Partial support |
| Autocomplete | ✅ | AutocompleteManager.swift | Working |
| Find & Replace | ✅ | FindReplaceView.swift | Full implementation |
| Go to Line | ✅ | GoToLineView.swift | Cmd+G |
| Word Wrap | ✅ | Settings toggle | Works |
| Minimap | 🟡 | MinimapView.swift | Basic, may have perf issues |
| Breadcrumbs | ✅ | BreadcrumbsView.swift | File path display |
| Sticky Headers | 🟡 | StickyHeaderView.swift | Function/class headers |
| Bracket Matching | ✅ | Built into highlighter | Bracket pair colorization |
| Inlay Hints | 🔴 | InlayHintsOverlay.swift | Stub - needs LSP |
| Hover Info | 🔴 | HoverInfoView.swift | Stub - needs LSP |
| Peek Definition | 🔴 | PeekDefinitionView.swift | Stub - needs LSP |

---

## 📁 File Management

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| File Tree (Sidebar) | ✅ | FileExplorerView.swift | Full implementation |
| Open Folder | ✅ | iOS document picker | Works |
| Create File | ✅ | Context menu | Works |
| Create Folder | ✅ | Context menu | Works |
| Rename | ✅ | Context menu | Works |
| Delete | ✅ | Context menu | Works |
| File Icons | ✅ | FileIcons.swift | Extensive mapping |
| Recent Files | 🟡 | Unknown | May not persist |
| File Search (Quick Open) | ✅ | QuickOpenView.swift | Cmd+P |
| Workspace Trust | ✅ | WorkspaceTrustManager.swift | Security feature |

---

## 🔀 Git Integration

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Status Display | ✅ | GitView.swift | Shows changed files |
| Branch Display | ✅ | GitManager.swift | Current branch in status bar |
| Diff View | 🟡 | DiffView.swift | Basic implementation |
| Stage Files | 🔴 | GitManager.swift | UI exists, backend stub |
| Unstage Files | 🔴 | GitManager.swift | UI exists, backend stub |
| Commit | 🔴 | GitManager.swift | UI exists, backend stub |
| Push | 🔴 | SSHGitClient.swift | Needs SSH implementation |
| Pull | 🔴 | SSHGitClient.swift | Needs SSH implementation |
| Clone | 🔴 | Not implemented | |
| Branch Create/Switch | 🔴 | GitManager.swift | UI exists, backend stub |
| Merge | ⬜ | MergeConflictView exists | Not wired up |
| Stash | 🔴 | GitManager.swift | UI exists, backend stub |
| Blame | ⬜ | Not implemented | |
| History/Log | 🟡 | NativeGitReader.swift | Read-only works |

**See [GIT_STATUS.md](./GIT_STATUS.md) for detailed git implementation status.**

---

## 🔌 SSH/Remote

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| SSH Connection | 🔴 | SSHManager.swift | **STUB - throws notImplemented** |
| SFTP Browsing | 🔴 | SFTPManager.swift | Depends on SSH |
| Remote File Edit | 🔴 | Depends on SFTP | |
| Remote Terminal | 🔴 | TerminalView.swift | UI ready, needs SSH |
| SSH Key Management | 🟡 | KeychainManager.swift | Storage works, SSH doesn't |

**See [SSH_STATUS.md](./SSH_STATUS.md) for detailed SSH status.**

---

## 🖥️ Terminal

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Terminal UI | ✅ | TerminalView.swift | Panel at bottom |
| Local Commands | 🔴 | iOS sandbox limits | Can't run local shell |
| SSH Terminal | 🔴 | Needs SSHManager | |
| ANSI Colors | 🟡 | TerminalView.swift | Basic support |

---

## 🎨 UI/UX

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Dark/Light Themes | ✅ | ThemeManager.swift | 19 themes! |
| Tab Bar | ✅ | IDETabBar in ContentView | Full implementation |
| Split View | ✅ | SplitEditorView.swift | Horizontal split |
| Activity Bar | ✅ | IDEActivityBar | Left sidebar icons |
| Status Bar | ✅ | StatusBarView.swift | Bottom bar |
| Command Palette | ✅ | CommandPaletteView.swift | Cmd+Shift+P |
| Settings | ✅ | SettingsView.swift | Full settings UI |
| Keyboard Shortcuts | ✅ | AppCommands.swift | Extensive shortcuts |
| Multi-Window | 🟡 | SceneDelegate.swift | iPadOS multi-window |
| Drag & Drop | 🟡 | Various | Files into editor |

---

## 🔍 Search

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Find in File | ✅ | FindReplaceView.swift | Cmd+F |
| Replace in File | ✅ | FindReplaceView.swift | Cmd+H |
| Find in Workspace | ✅ | SearchView.swift | Cmd+Shift+F |
| Regex Search | ✅ | FindViewModel.swift | Toggle in UI |
| Case Sensitive | ✅ | FindViewModel.swift | Toggle in UI |
| Whole Word | ✅ | FindViewModel.swift | Toggle in UI |

---

## 🤖 AI Features

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| AI Assistant Panel | ✅ | AIAssistantView.swift | Sidebar panel |
| AI Manager | 🟡 | AIManager.swift | Backend integration unclear |
| Inline Suggestions | 🔴 | InlineSuggestionView.swift | UI exists, backend stub |

---

## 🏃 Code Execution

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| JavaScript (JSC) | 🟡 | JSRunner.swift | Uses JavaScriptCore, limited |
| Python (WASM) | 🔴 | WASMRunner.swift | Experimental |
| Swift (Local) | ⬜ | Not possible on iOS | Sandbox restriction |
| Remote Execution | 🔴 | RemoteExecutionService.swift | Needs SSH |

---

## 📊 Summary

| Category | ✅ Working | 🟡 Partial | 🔴 Stub | ⬜ Missing |
|----------|-----------|-----------|---------|----------|
| Editor | 10 | 4 | 3 | 0 |
| Files | 8 | 1 | 0 | 0 |
| Git | 3 | 2 | 8 | 2 |
| SSH | 0 | 1 | 4 | 0 |
| UI/UX | 10 | 2 | 0 | 0 |
| Search | 6 | 0 | 0 | 0 |
| **Total** | **37** | **10** | **15** | **2** |
