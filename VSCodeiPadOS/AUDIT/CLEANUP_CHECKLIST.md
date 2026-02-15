# ✅ Cleanup Checklist

Follow this step-by-step to clean up the codebase.

**Last Verification:** Audit Agent - All items verified with actual file reads.

## Phase 1: Delete Obvious Garbage (5 minutes)

### Backup Files
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Services/ThemeManager.swift.bak` **[VERIFIED]** - File exists (186 lines)
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/ContentView.swift.bak` **[VERIFIED]** - File exists (792 lines)
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Commands/AppCommands.swift.bak` **[VERIFIED]** - File exists (335 lines)
- [ ] `rm -rf VSCodeiPadOS/VSCodeiPadOS/Menus.bak/` (entire folder) **[VERIFIED]** - Folder exists with 9 files

### Duplicate Files
- [ ] `rm 'VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift'` **[VERIFIED]** - Duplicate exists (315 lines)
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.existing.swift` **[VERIFIED]** - Old version exists (147 lines)
- [ ] `rm VSCodeiPadOS/TreeSitterLanguages.swift` (keep the one in Services/) **[VERIFIED]** - Both exist at root and Services/
- [ ] `rm VSCodeiPadOS/FeatureFlags.swift` (keep the one in Utils/) **[VERIFIED]** - Both exist at root and Utils/

### Patch Files
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/ContentView_shift_arrow.patch` **[VERIFIED]** - File exists (138 lines)

### Broken/Old Files  
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift.broken` **[VERIFIED]** - File exists in Panels/
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift.broken` **[VERIFIED]** - File exists (77 lines)
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/AIAssistantView.swift.bak` **[VERIFIED]** - File exists in Panels/
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/AIAssistantView.swift.backup` **[VERIFIED]** - File exists in Panels/
- [ ] `rm VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift.bak` **[VERIFIED]** - File exists in Panels/

### Build Logs
- [ ] `rm VSCodeiPadOS/build_output.log` **[VERIFIED]** - File exists
- [ ] `rm VSCodeiPadOS/build_output2.log` **[VERIFIED]** - File exists (182 lines)
- [ ] `rm VSCodeiPadOS/build.log` **[VERIFIED]** - File exists (104 lines)

---

## Phase 2: Review Before Deleting (15 minutes)

### Potentially Orphaned Views
Check if these are actually used before deleting:

- [ ] `EditorSplitView.swift` **[VERIFIED ORPHAN]** - Only defined, NOT used anywhere. Safe to delete.
- [ ] `JSONTreeView.swift` **[VERIFIED IN USE]** - Used in ContentView.swift:462. DO NOT DELETE.
- [ ] `MergeConflictView.swift` **[VERIFIED ORPHAN]** - Defined but never instantiated. Safe to delete.
- [ ] `ColorPickerView.swift` **[VERIFIED ORPHAN]** - Defined but never instantiated. Safe to delete.
- [ ] `HoverInfoView.swift` **[VERIFIED IN USE]** - Used in SyntaxHighlightingTextView_Update.swift:247. DO NOT DELETE.
- [ ] `InlayHintsOverlay.swift` **[VERIFIED ORPHAN]** - Defined but never instantiated. Safe to delete.
- [ ] `InlineSuggestionView.swift` **[VERIFIED ORPHAN]** - Only used in its own preview. Safe to delete.
- [ ] `PeekDefinitionView.swift` **[VERIFIED IN USE]** - Used in SplitEditorView.swift:635. DO NOT DELETE.

### Potentially Orphaned Services
- [ ] `GitService.swift` **[VERIFIED ORPHAN]** - Old mock service. GitService.shared never called anywhere. Safe to delete.
- [ ] `LSPService.swift` **[VERIFIED - DOES NOT EXIST]** - File does not exist. Remove from list.
- [ ] `RemoteExecutionService.swift` **[VERIFIED - DOES NOT EXIST]** - File does not exist. Remove from list.

---

## Phase 3: Consolidate Duplicate Code (30 minutes)

### Syntax Highlighting Duplication
Two systems exist:
1. `SyntaxHighlightingTextView.swift` - Regex-based (~2289 lines) **[VERIFIED]**
2. `RunestoneEditorView.swift` - TreeSitter-based (~746 lines) **[VERIFIED]**

**Decision needed:** Keep both? Runestone is better but SyntaxHighlighting is fallback.

### File Extensions
- [ ] ~~Merge `FileManager+Extension.swift` and `FileManager+Extensions.swift`~~ **[VERIFIED - NOT DUPLICATES]**
- **FileManager+Extension.swift** (54 lines): `documentsDirectory()`, `createProjectStructure(at:)`
- **FileManager+Extensions.swift** (113 lines): `createFileIfNeeded()`, `isDirectory()`, `contentsOfDirectory()`, plus URL extensions for icons
- **ACTION:** Keep both - they have different functionality!

---

## Phase 4: Organize Loose Files (10 minutes)

### Move Markdown Files
These are in wrong locations:
- [ ] Move `VSCodeiPadOS/bugs.md` → `VSCodeiPadOS/Docs/` **[VERIFIED]** - File exists (193 lines about critical bugs)
- [ ] Move root `update.md` → `VSCodeiPadOS/Docs/` or keep at root **[VERIFIED]** - File exists at repo root (312 lines, overnight implementation plan)
- [ ] Consolidate all docs in one place - Docs/ folder exists with only AIModelsResearch.md

### Clean Root Directory
Files at `VSCodeiPadOS/` root that might belong elsewhere:
- [ ] `TypingLagTest.swift` - Move to Tests/? **[VERIFIED]** - Test file exists (462 lines)
- [ ] Review what else is at root level **[VERIFIED]** - Also found: FeatureFlags.swift, TreeSitterLanguages.swift, bugs.md, build logs, Info.plist, Package.swift

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
