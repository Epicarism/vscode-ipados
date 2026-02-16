# Agent: scout-app-structure
**Status:** done
**Tokens:** 0
**Cost:** $0.0000
**Time:** 2026-02-16T13:54:00.218Z

## Task
Read ContentView.swift structure. Find: 1) How tabs/views are switched, 2) Where settings are accessed, 3) Where a new 'Connected Mode' WebView could be added. Report key insertion points.

## Response


Based on my analysis of the ContentView.swift file, here's my report:

>>>REPORT
## ContentView.swift Structure Analysis

### 1) How Tabs/Views Are Switched

**Tab Management (EditorCore):**
- `editorCore.activeTabId` - controls which tab is active (line 124-129)
- `editorCore.selectTab(id:)` - called to switch tabs (line 416, 919)
- `editorCore.addTab()` - creates new tabs (line 64, 390, 826)
- `editorCore.closeTab(id:)` - closes tabs (line 66, 409)

**Sidebar Tab Switching:**
- `selectedSidebarTab` @State variable (line 20) - controls sidebar view
- `sidebarContent` computed property (lines 213-226) uses switch:
  - case 0: IDESidebarFiles (Explorer)
  - case 1: SidebarSearchView
  - case 2: GitView
  - case 3: DebugView
- Selection passed to `IDEActivityBar` (line 115)

**Key View Components:**
- `IDETabBar` (line 379-395) - renders tab bar with ForEach over `editorCore.tabs`
- `IDETabItem` (line 397-418) - individual tab, tap calls `editorCore.selectTab(id:)`
- Main content area shows either `IDEEditorView` for active tab or `IDEWelcomeView` (lines 124-129)

### 2) Where Settings Are Accessed

**Settings Entry Points:**
- `@State private var showSettings` (line 17) - controls settings sheet
- Sheet presentation: `.sheet(isPresented: $showSettings) { SettingsView(themeManager: themeManager) }` (line 40)
- ActivityBar passes `showSettings` binding (line 115)
- Command Palette has Settings command: `CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,")` (line 880)

### 3) Where 'Connected Mode' WebView Could Be Added

**Best Insertion Points:**

**A. As New Sidebar Tab (Recommended):**
- Add case 4 in `sidebarContent` switch (lines 214-225)
- Create `ConnectedModeView()` component
- Update `IDEActivityBar` to add 5th button icon

**B. As Overlay Panel (like AI Assistant):**
- Add in `overlayViews` (lines 142-183)
- Add `@State private var showConnectedMode = false`
- Add toggle notification handler similar to AI Assistant pattern (line 63):
  ```swift
  .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowConnectedMode"))) { _ in showConnectedMode = true }
  ```

**C. As Main Editor Tab Content:**
- Modify `IDEEditorView` or create specialized view that checks tab type
- Tab could have special URL scheme like `vscode

⛔ ABORTED by user
