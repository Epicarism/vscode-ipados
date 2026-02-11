# 🗑️ Files Safe to Delete

These files can be deleted without breaking the app.

## ⚠️ Before You Delete
1. Make sure you have a git commit of current state
2. Delete in small batches and rebuild to verify
3. Files marked ⚡ are definitely safe, others need quick verification

---

## Backup Files (⚡ SAFE)

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

---

## Duplicate Files (⚡ SAFE)

```bash
# Duplicate with space in name (copy-paste accident)
rm 'VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift'

# Old version superseded by RunnerSelector.swift
rm VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.existing.swift

# Duplicates at root (keep versions in proper folders)
rm VSCodeiPadOS/TreeSitterLanguages.swift  # Keep Services/TreeSitterLanguages.swift
rm VSCodeiPadOS/FeatureFlags.swift         # Keep Utils/FeatureFlags.swift
```

---

## Old Menu System (⚡ SAFE)

```bash
# Entire folder - superseded by AppCommands.swift and inline menu definitions
rm -rf VSCodeiPadOS/VSCodeiPadOS/Menus.bak/
```

Contains these obsolete files:
- EditMenu.swift
- FileMenu.swift
- FormatMenu.swift
- GoMenu.swift
- HelpMenu.swift
- KeyboardShortcuts.swift
- SearchMenu.swift
- TerminalMenu.swift
- ViewMenu.swift

---

## Patch Files (⚡ SAFE)

```bash
# Already applied patches
rm VSCodeiPadOS/VSCodeiPadOS/ContentView_shift_arrow.patch
rm VSCodeiPadOS/Views/Panels/TerminalView.swift_patch1
rm VSCodeiPadOS/Views/Panels/TerminalView.swift_patch2
```

---

## Build Logs (⚡ SAFE)

```bash
rm VSCodeiPadOS/build_output.log \
   VSCodeiPadOS/build_output2.log \
   VSCodeiPadOS/build.log
```

---

## .garbage Folder (⚡ SAFE)

```bash
# Old code moved to garbage
rm -rf VSCodeiPadOS/.garbage/
```

Contains old RunestoneEditorView and RunestoneThemeAdapter versions from before refactoring.

---

## Possibly Orphaned (⚠️ VERIFY FIRST)

These MIGHT be orphaned. Search for usages before deleting:

| File | Check For |
|------|----------|
| `GitService.swift` | Search for `GitService` - likely replaced by GitManager |
| `LSPService.swift` | Search for `LSPService` - may never have been implemented |
| `HoverInfoView.swift` | Search for `HoverInfoView` |
| `InlayHintsOverlay.swift` | Search for `InlayHintsOverlay` |
| `PeekDefinitionView.swift` | Search for `PeekDefinitionView` |

---

## Quick Verification Commands

```bash
# Check if a type is used anywhere
grep -r "GitService" VSCodeiPadOS/VSCodeiPadOS --include="*.swift" | grep -v "GitService.swift"

# Find all .bak files
find VSCodeiPadOS -name "*.bak" -o -name "*.backup" -o -name "*.broken"

# Find all duplicate-looking files
find VSCodeiPadOS -name "* 2.swift" -o -name "*.existing.swift"
```
