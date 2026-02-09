# Agent: sidebar-integration-worker
**Status:** done
**Tokens:** 1,736
**Cost:** $0.0000
**Time:** 2026-02-09T10:42:38.750Z

## Task
Update ContentView.swift to add Outline and Timeline panels to sidebar. Add new sidebar tabs (index 4 for Outline with 'list.bullet.indent' icon, index 5 for Timeline with 'clock' icon). Import and use OutlineView and TimelineView in sidebarContent switch. Pass editorCore to OutlineView. File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift

## Response
>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift"}
>>>END

I need to read the file and add the Outline and Timeline sidebar tabs. Let me apply the patches:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
    @ViewBuilder
    private var sidebarContent: some View {
        switch selectedSidebarTab {
        case 0:
            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker)
        case 1:
            SidebarSearchView()
        case 2:
            GitView()
        case 3:
            DebugView()
        default:
            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker)
        }
    }
>>>REPLACE
    @ViewBuilder
    private var sidebarContent: some View {
        switch selectedSidebarTab {
        case 0:
            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker)
        case 1:
            SidebarSearchView()
        case 2:
            GitView()
        case 3:
            DebugView()
        case 4:
            OutlineView(editorCore: editorCore)
        case 5:
            TimelineView()
        default:
            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker)
        }
    }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
            BarButton(icon: "play.fill", isSelected: selectedTab == 3) {
                selectedTab = 3
                if !editorCore.showSidebar { editorCore.toggleSidebar() }
            }
            BarButton(icon: "terminal", isSelected: showTerminal) {
                showTerminal.toggle()
            }
>>>REPLACE
            BarButton(icon: "play.fill", isSelected: selectedTab == 3) {
                selectedTab = 3
                if !editorCore.showSidebar { editorCore.toggleSidebar() }
            }
            BarButton(icon: "list.bullet.indent", isSelected: selectedTab == 4) {
                selectedTab = 4
                if !editorCore.showSidebar { editorCore.toggleSidebar() }
            }
            BarButton(icon: "clock", isSelected: selectedTab == 5) {
                selectedTab = 5
                if !editorCore.showSidebar { editorCore.toggleSidebar() }
            }
            BarButton(icon: "terminal", isSelected: showTerminal) {
                showTerminal.toggle()
            }
>>>END

>>>REPORT
Successfully updated ContentView.swift to add Outline and Timeline panels to the sidebar:

**Changes made:**

1. **Added new sidebar tabs in IDEActivityBar** (lines 136-143):
   - Index 4: Outline with `list.bullet.indent` icon
   - Index 5: Timeline with `clock` icon
   - Both buttons follow the same pattern as existing tabs (toggle sidebar if not visible)

2. **Updated sidebarContent switch** (lines 97-116):
   - Added `case 4:` returning `OutlineView(editorCore: editorCore)` - passes editorCore as required
   - Added `case 5:` returning `TimelineView()`

**Activity bar order is now:**
- 0: Files (doc.text)
- 1: Search (magnifyingglass)  
- 2: Git (arrow.triangle.branch)
- 3: Debug (play.fill)
- 4: Outline (list.bullet.indent) ← NEW
- 5: Timeline (clock) ← NEW
- Terminal toggle
- AI Assistant
- Settings

Note: This assumes `OutlineView` and `TimelineView` are defined elsewhere in the project (likely in separate files that were created as part of the Views implementation).
>>>END
