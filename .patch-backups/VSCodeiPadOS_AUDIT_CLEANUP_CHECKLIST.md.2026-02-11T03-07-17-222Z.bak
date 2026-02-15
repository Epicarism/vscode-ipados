# ✅ Cleanup Checklist

Follow this step-by-step to clean up the codebase.

## Phase 1: Delete Obvious Garbage (5 minutes)

### Backup Files
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Services/ThemeManager.swift.bak`
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/ContentView.swift.bak`
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Commands/AppCommands.swift.bak`
- [ ] `rm -rf VSCodeiPadOS/VSCodeiPadOS/Menus.bak/` (entire folder)

### Duplicate Files
- [ ] `rm 'VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift'`
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.existing.swift`
- [ ] `rm VSCodeiPadOS/TreeSitterLanguages.swift` (keep the one in Services/)
- [ ] `rm VSCodeiPadOS/FeatureFlags.swift` (keep the one in Utils/)

### Patch Files
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/ContentView_shift_arrow.patch`

### Broken/Old Files  
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift.broken`
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift.broken`
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/AIAssistantView.swift.bak`
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/AIAssistantView.swift.backup`
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift.bak`

### Build Logs
- [ ] `rm VSCodeiPadOS/build_output.log`
- [ ] `rm VSCodeiPadOS/build_output2.log`
- [ ] `rm VSCodeiPadOS/build.log`

---

## Phase 2: Review Before Deleting (15 minutes)

### Potentially Orphaned Views
Check if these are actually used before deleting:

- [ ] `EditorSplitView.swift` - Markdown preview? Check ContentView references
- [ ] `JSONTreeView.swift` - JSON tree view, might be disabled
- [ ] `MergeConflictView.swift` - Git merge UI, check if wired up
- [ ] `ColorPickerView.swift` - Check if used anywhere
- [ ] `HoverInfoView.swift` - LSP hover, probably orphaned
- [ ] `InlayHintsOverlay.swift` - LSP inlay hints, probably orphaned
- [ ] `InlineSuggestionView.swift` - AI suggestions, check usage
- [ ] `PeekDefinitionView.swift` - Check if used

### Potentially Orphaned Services
- [ ] `GitService.swift` - OLD mock service, superseded by GitManager
- [ ] `LSPService.swift` - Was this ever implemented?
- [ ] `RemoteExecutionService.swift` - Check if used or planned

---

## Phase 3: Consolidate Duplicate Code (30 minutes)

### Syntax Highlighting Duplication
Two systems exist:
1. `SyntaxHighlightingTextView.swift` - Regex-based (~2300 lines)
2. `RunestoneEditorView.swift` - TreeSitter-based (~740 lines)

**Decision needed:** Keep both? Runestone is better but SyntaxHighlighting is fallback.

### File Extensions
- [ ] Merge `FileManager+Extension.swift` and `FileManager+Extensions.swift`
- [ ] Or delete one if duplicate

---

## Phase 4: Organize Loose Files (10 minutes)

### Move Markdown Files
These are in wrong locations:
- [ ] Move `VSCodeiPadOS/bugs.md` → `VSCodeiPadOS/Docs/`
- [ ] Move root `update.md` → `VSCodeiPadOS/Docs/` or keep at root
- [ ] Consolidate all docs in one place

### Clean Root Directory
Files at `VSCodeiPadOS/` root that might belong elsewhere:
- [ ] `TypingLagTest.swift` - Move to Tests/?
- [ ] Review what else is at root level

---

## Phase 5: Update Documentation (15 minutes)

- [ ] Update `README.md` - It references non-existent files
- [ ] Archive old docs to `Docs/Archive/`
- [ ] Create fresh "Getting Started" doc

---

## Phase 6: Build & Test

- [ ] `xcodebuild clean` and rebuild
- [ ] Run on simulator
- [ ] Test: Open file, edit, save
- [ ] Test: Git status panel
- [ ] Test: Syntax highlighting (JSON, Swift, Python)

---

## 🎉 Done!

After cleanup, you should have:
- ~70 active Swift files (down from 117+)
- No backup/duplicate files
- Clear folder structure
- Working app
