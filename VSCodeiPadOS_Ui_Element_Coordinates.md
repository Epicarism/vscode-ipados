# VSCodeiPadOS UI Element Coordinates Guide

## Device: iPad Pro 12.9" (Landscape: 1366x1024)

Based on code analysis, here are the UI element locations:

### 1. Activity Bar (Far Left)
- **Width**: 50px (from SidebarView.swift line 164)
- **Icons**: 
  - Explorer: ~25px X, ~100px Y
  - Search: ~25px X, ~150px Y  
  - Source Control: ~25px X, ~200px Y
  - Run & Debug: ~25px X, ~250px Y
  - Extensions: ~25px X, ~300px Y
  - Testing: ~25px X, ~350px Y
  - Settings: ~25px X, ~950px Y (bottom)
- **Accessibility IDs**: 
  - `activityBar.explorer`
  - `activityBar.search`
  - `activityBar.sourceControl`
  - `activityBar.runAndDebug`
  - `activityBar.extensions`
  - `activityBar.testing`

### 2. Sidebar Panel
- **Width**: 170-600px (resizable, default ~280px)
- **Location**: X=50 to X=330
- **Header**: "EXPLORER" text at top
- **File Tree**:
  - Indentation: 16px per level
  - Folder chevron: ~12px wide
  - First folder: ~70px X, ~150px Y
  - Folder height: ~20px per row
- **Accessibility ID**: `sidebar.panel`, `sidebar.header.title`

### 3. Tab Bar
- **Height**: 35-36px (from TabBarView.swift line 52)
- **Location**: Top of editor area (Y=~50px)
- **Tab Width**: 160px (unpinned), 40px (pinned)
- **First Tab**: X=~330px, Y=~50px
- **Second Tab**: X=~490px, Y=~50px
- **Close Button**: Right side of each tab

### 4. Editor Area
- **Location**: Below tab bar, above status bar
- **Y Range**: ~86px to ~1002px (1024 - 22px status bar)
- **X Range**: ~330px to 1366px (if sidebar visible)

### 5. Status Bar
- **Height**: 22px (from StatusBarView.swift line 96)
- **Location**: Bottom of screen (Y=~1002px to Y=~1024px)
- **Items** (left to right):
  - Branch: ~100px X
  - Pull/Push: ~150px X
  - Stash: ~200px X
  - Problems: ~250px X
  - Warnings: ~300px X
  - Cursor Position: Center
  - Language: Right side

### 6. Terminal/Panel
- **Default Height**: 200px (from ContentView.swift line 19)
- **Toggle**: Via keyboard shortcut Cmd+J or Cmd+`
- **Location**: Bottom of screen (when visible)

## Recommended idb Testing Commands

```bash
# 1. Find device
xcrun simctl list devices | grep "iPad.*Booted"

# 2. Launch app
idb launch com.vscode.ipados

# 3. Screenshot to verify coordinates
idb screenshot --output test.png

# 4. Tap Activity Bar Explorer
idb ui tap 25 100

# 5. Expand first folder in sidebar
idb ui tap 70 150

# 6. Switch to second tab
idb ui tap 490 50

# 7. Tap status bar cursor position
idb ui tap 683 1013

# 8. Check accessibility elements (if supported)
idb ui describe
```

## Key Findings from Code Analysis

### File Tree (FileTreeView.swift)
- Expand/collapse via chevron button (12px wide)
- Tap gesture on entire row expands folders
- Indentation: 16px * level
- Accessibility: No explicit IDs on individual rows

### Tab Bar (TabBarView.swift)
- Horizontal scrollable
- Tabs: 160px wide, 35px tall
- Close button: 16px x 16px
- No explicit accessibility IDs on tabs

### Status Bar (StatusBarView.swift)
- Fixed 22px height
- Multiple interactive items
- No explicit accessibility IDs on individual items

### Panel/Terminal
- Toggled via `showTerminal` state
- Keyboard shortcuts: Cmd+J, Cmd+`
- Height: 200px (resizable)

## Limitations

1. **No Accessibility IDs**: Many UI elements lack accessibility identifiers
2. **Dynamic Layout**: Sidebar is resizable (170-600px)
3. **Keyboard Shortcuts**: Many features require keyboard (Cmd+B, Cmd+J, etc.)
4. **Orientation**: Coordinates assume landscape mode

## Recommendations for Better Testing

1. **Add accessibility identifiers** to key UI elements:
   ```swift
   .accessibilityIdentifier("tab.bar.item.\(tab.id)")
   .accessibilityIdentifier("file.tree.\(node.name)")
   .accessibilityIdentifier("status.bar.cursor")
   ```

2. **Use XCTest UI Testing** instead of idb for more reliable tests

3. **Add UI testing helpers**:
   ```swift
   .accessibilityLabel("Expand folder: \(node.name)")
   .accessibilityHint("Double tap to expand")
   ```
