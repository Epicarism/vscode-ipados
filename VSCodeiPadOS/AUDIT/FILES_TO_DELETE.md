# 🗑️ Files Safe to Delete - VERIFIED

**Verification Date:** February 11, 2026  
**Verified by:** AI Agent Ultra Verification

These files have been individually verified for safety.

## ⚠️ Before You Delete
1. Make sure you have a git commit of current state
2. Delete in small batches and rebuild to verify
3. Files marked ✅ are VERIFIED safe, ⚠️ need caution

---

## Backup Files (✅ ALL VERIFIED SAFE)

All files exist, are NOT in project.pbxproj, have no imports:

```bash
# One-liner to delete all backup files:
rm -f VSCodeiPadOS/VSCodeiPadOS/Services/ThemeManager.swift.bak \
     VSCodeiPadOS/VSCodeiPadOS/ContentView.swift.bak \
     VSCodeiPadOS/VSCodeiPadOS/Commands/AppCommands.swift.bak \
     VSCodeiPadOS/VSCodeiPadOS/Views/Panels/AIAssistantView.swift.bak \
     VSCodeiPadOS/VSCodeiPadOS/Views/Panels/AIAssistantView.swift.backup \
     VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift.bak \
     VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift.broken \
     VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift.broken
```

| File | Status |
|------|--------|
| ThemeManager.swift.bak | ✅ [CONFIRMED SAFE] exists, not compiled |
| ContentView.swift.bak | ✅ [CONFIRMED SAFE] exists, not compiled |
| AppCommands.swift.bak | ✅ [CONFIRMED SAFE] exists, not compiled |
| AIAssistantView.swift.bak | ✅ [CONFIRMED SAFE] exists, not compiled |
| AIAssistantView.swift.backup | ✅ [CONFIRMED SAFE] exists, not compiled |
| TerminalView.swift.bak | ✅ [CONFIRMED SAFE] exists, not compiled |
| GitView.swift.broken | ✅ [CONFIRMED SAFE] exists, not compiled |
| SearchView.swift.broken | ✅ [CONFIRMED SAFE] exists, not compiled |

---

## Duplicate Files (✅ VERIFIED SAFE)

```bash
# Duplicate with space in name (copy-paste accident)
rm 'VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift'

# Old version superseded by RunnerSelector.swift  
rm VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.existing.swift

# Duplicate in Services folder - root version is compiled
rm VSCodeiPadOS/VSCodeiPadOS/Services/TreeSitterLanguages.swift
```

| File | Status |
|------|--------|
| RunestoneThemeAdapter 2.swift | ✅ [CONFIRMED SAFE] not in pbxproj |
| RunnerSelector.existing.swift | ✅ [CONFIRMED SAFE] not in pbxproj |
| Services/TreeSitterLanguages.swift | ✅ [CONFIRMED SAFE] root version (VSCodeiPadOS/TreeSitterLanguages.swift) is compiled |

### ⚠️ CORRECTION FROM ORIGINAL:

The original recommendation was WRONG. DO NOT DELETE:
- `VSCodeiPadOS/TreeSitterLanguages.swift` - **KEEP** (IS compiled in pbxproj line 101)
- `VSCodeiPadOS/FeatureFlags.swift` - **KEEP** (IS compiled in pbxproj line 102)

Instead DELETE the duplicates in subdirectories:
- `VSCodeiPadOS/VSCodeiPadOS/Services/TreeSitterLanguages.swift` - Safe to delete (not compiled)
- `VSCodeiPadOS/VSCodeiPadOS/Utils/FeatureFlags.swift` - Review first (may be intentional backup)

---

## Old Menu System (✅ VERIFIED SAFE)

```bash
# Entire folder - superseded by AppCommands.swift and inline menu definitions
rm -rf VSCodeiPadOS/VSCodeiPadOS/Menus.bak/
```

| Status | Details |
|--------|--------|
| ✅ [CONFIRMED SAFE] | Folder exists with 9 files |
| | Not in project.pbxproj |
| | No references found in codebase |

Contains these obsolete files:
- EditMenuCommands.swift
- FileMenuCommands.swift  
- GoMenuCommands.swift
- HelpMenuCommands.swift
- MenuFocusedValues.swift
- RunMenuCommands.swift
- SelectionMenuCommands.swift
- TerminalMenuCommands.swift
- ViewMenuCommands.swift

---

## Patch Files (✅ PARTIALLY VERIFIED)

```bash
# Already applied patch - VERIFIED EXISTS
rm VSCodeiPadOS/VSCodeiPadOS/ContentView_shift_arrow.patch
```

| File | Status |
|------|--------|
| ContentView_shift_arrow.patch | ✅ [CONFIRMED SAFE] exists at VSCodeiPadOS/VSCodeiPadOS/ |
| TerminalView.swift_patch1 | ❌ [FILE NOT FOUND] wrong path in original doc |
| TerminalView.swift_patch2 | ❌ [FILE NOT FOUND] wrong path in original doc |

---

## Build Logs (✅ ALL VERIFIED SAFE)

```bash
rm VSCodeiPadOS/build_output.log \
   VSCodeiPadOS/build_output2.log \
   VSCodeiPadOS/build.log
```

| File | Status |
|------|--------|
| build_output.log | ✅ [CONFIRMED SAFE] exists |
| build_output2.log | ✅ [CONFIRMED SAFE] exists |
| build.log | ✅ [CONFIRMED SAFE] exists |

---

## .garbage Folder (✅ VERIFIED SAFE)

```bash
# Old code moved to garbage
rm -rf VSCodeiPadOS/.garbage/
```

| Status | Details |
|--------|--------|
| ✅ [CONFIRMED SAFE] | Folder exists |
| | Contains subfolder 1770744061015/ |
| | Not in project.pbxproj |

---

## Possibly Orphaned (⚠️ VERIFICATION RESULTS)

| File | Original Recommendation | VERIFICATION RESULT |
|------|------------------------|---------------------|
| `GitService.swift` | Verify - may be replaced by GitManager | ⚠️ [KEEP - COMPILED] In pbxproj line 41, but no external usage found. Remove from pbxproj first if deleting. |
| `LSPService.swift` | Verify | ❌ [FILE NOT FOUND] Does not exist |
| `HoverInfoView.swift` | Verify | 🔴 [KEEP - ACTIVELY USED] Referenced in SyntaxHighlightingTextView_Update.swift:247 |
| `InlayHintsOverlay.swift` | Verify | ⚠️ [KEEP - COMPILED] In pbxproj line 87, but no external usage found. |
| `PeekDefinitionView.swift` | Verify | 🔴 [KEEP - ACTIVELY USED] Referenced in SplitEditorView.swift:635 |

### Summary of "Possibly Orphaned" Section:
- **DO NOT DELETE:** HoverInfoView.swift, PeekDefinitionView.swift (actively used)
- **CAUTION:** GitService.swift, InlayHintsOverlay.swift (compiled but unused - may be future features)
- **DOES NOT EXIST:** LSPService.swift

---

## Quick Verification Commands

```bash
# Check if a type is used anywhere
grep -r "GitService" VSCodeiPadOS/VSCodeiPadOS --include="*.swift" | grep -v "GitService.swift"

# Find all .bak files
find VSCodeiPadOS -name "*.bak" -o -name "*.backup" -o -name "*.broken"

# Find all duplicate-looking files  
find VSCodeiPadOS -name "* 2.swift" -o -name "*.existing.swift"

# Check if file is in pbxproj (compiled)
grep "filename.swift" VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj
```

---

## 📊 VERIFICATION SUMMARY

| Category | Safe to Delete | Keep | Not Found |
|----------|---------------|------|----------|
| Backup files (.bak/.backup/.broken) | 8 | 0 | 0 |
| Duplicates | 3 | 2* | 0 |
| Menus.bak folder | 1 (folder) | 0 | 0 |
| Patch files | 1 | 0 | 2 |
| Build logs | 3 | 0 | 0 |
| .garbage folder | 1 (folder) | 0 | 0 |
| Possibly orphaned | 0 | 4 | 1 |

*Original doc had wrong recommendation - corrected above.

### FINAL SAFE DELETE COUNT: 17 files/folders
### FILES TO KEEP: 6 (were incorrectly marked for deletion)
### FILES NOT FOUND: 3 (wrong paths in original)
