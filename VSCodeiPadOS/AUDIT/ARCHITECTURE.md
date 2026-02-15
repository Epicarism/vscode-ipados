# 🏗️ App Architecture

## High-Level Structure

[VERIFIED] Core structure is accurate. Some minor corrections noted below.

```
VSCodeiPadOS/VSCodeiPadOS/
├── App/                    # App lifecycle [VERIFIED]
│   ├── VSCodeiPadOSApp.swift    # @main entry point [VERIFIED]
│   ├── AppDelegate.swift        # UIKit lifecycle [VERIFIED]
│   └── SceneDelegate.swift      # Multi-window support [VERIFIED]
│
├── Views/                  # UI Layer [VERIFIED]
│   ├── ContentView.swift        # Main orchestrator (1122 lines) [VERIFIED - was "1100+"]
│   ├── Editor/                  # Editor components [VERIFIED - 19 files]
│   │   ├── RunestoneEditorView.swift    # TreeSitter editor [VERIFIED]
│   │   ├── SyntaxHighlightingTextView.swift  # Regex fallback [VERIFIED]
│   │   ├── MinimapView.swift [VERIFIED]
│   │   ├── BreadcrumbsView.swift [VERIFIED]
│   │   └── ... (15 more files)
│   ├── Panels/                  # Sidebar panels [VERIFIED - 23 files, some .bak]
│   │   ├── GitView.swift [VERIFIED]
│   │   ├── SearchView.swift [VERIFIED]
│   │   ├── SettingsView.swift [VERIFIED - was listed under Dialogs]
│   │   └── ...
│   ├── FileTreeView.swift [CORRECTION: was "FileExplorerView.swift"]
│   ├── CommandPaletteView.swift [CORRECTION: in Views/, not Dialogs/]
│   └── QuickOpen.swift [NOT MENTIONED - important file]
│   [CORRECTION: No "Dialogs/" subfolder exists]
│
├── Models/                 # Data models [VERIFIED - 8 files]
│   ├── Theme.swift              # 19 color themes [VERIFIED - 887 lines]
│   ├── Tab.swift                # Editor tabs [VERIFIED]
│   ├── FileItem.swift           # File tree items [VERIFIED]
│   ├── ThemeManager.swift       # [VERIFIED - also in Models/]
│   └── ...
│
├── Services/               # Business logic [VERIFIED - 35+ files]
│   ├── EditorCore.swift         # Central editor state (1345 lines) [VERIFIED]
│   ├── GitManager.swift         # Git operations [VERIFIED]
│   ├── NativeGit/               # Pure Swift git [VERIFIED - 3 files]
│   │   ├── NativeGitReader.swift
│   │   ├── NativeGitWriter.swift
│   │   └── SSHGitClient.swift
│   ├── OnDevice/                # Code runners [VERIFIED - 8 files]
│   │   ├── JSRunner.swift
│   │   ├── PythonRunner.swift
│   │   ├── WASMRunner.swift
│   │   └── ...
│   ├── Runners/                 # [NOT MENTIONED - 3 files]
│   │   ├── NodeRunner.swift
│   │   ├── PythonRunner.swift
│   │   └── SwiftRunner.swift
│   └── ... (25+ more service files)
│
├── Extensions/             # Swift extensions [VERIFIED - 8 files]
├── Utils/                  # Utilities [VERIFIED - 3 files]
├── Commands/               # Keyboard commands [VERIFIED - 2 files]
├── UITests/                # [NOT MENTIONED - 12 test files]
└── Tests/                  # [EXISTS but empty]
```

---

## Data Flow

[VERIFIED] Data flow diagram is accurate.

```
┌─────────────────────────────────────────────────────────────┐
│                        ContentView                          │
│  (Main orchestrator - owns most @State)                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
    ┌──────────────┐ ┌──────────┐  ┌──────────┐
    │ Sidebar      │ │  Editor  │  │  Panel   │
    │ (FileTree,   │ │ (Rune-   │  │ (Term,   │
    │  Git,        │ │  stone)  │  │  Output) │
    │  Search)     │ │          │  │          │
    └────┬─────────┘ └────┬─────┘  └────┬─────┘
         │                │              │
         └────────────────┴──────────────┘
                          │
                          ▼
               ┌─────────────────────┐
               │   Shared Managers   │
               │  (Singletons)       │
               ├─────────────────────┤
               │ • ThemeManager      │
               │ • GitManager        │
               │ • EditorCore        │
               └─────────────────────┘
```

---

## Key Singletons

[VERIFIED with corrections]

| Manager | Access | Purpose | Status |
|---------|--------|----------|--------|
| `ThemeManager.shared` | Global | Current theme, theme switching | [VERIFIED] |
| `GitManager.shared` | Global | Git status, operations | [VERIFIED] |
| `EditorCore` | @EnvironmentObject | Editor settings, state | [VERIFIED] |
| `SSHConnectionStore.shared` | Global | Saved SSH connections | [CORRECTION: Does NOT exist. SSHManager has no .shared singleton] |
| `WorkspaceTrustManager.shared` | Global | Workspace trust management | [NOT MENTIONED - exists] |

---

## State Management

### ContentView State (Main)
[VERIFIED] Actual state variables found in ContentView.swift (lines 15-26):
```swift
// File state
@StateObject private var fileNavigator = FileSystemNavigator()
@StateObject private var themeManager = ThemeManager.shared

// UI state  
@State private var showingDocumentPicker = false
@State private var showingFolderPicker = false
@State private var showSettings = false
@State private var showTerminal = false
@State private var terminalHeight: CGFloat = 200
@State private var selectedSidebarTab = 0
@State private var pendingTrustURL: URL?
@State private var windowTitle: String = "VS Code"
```
[CORRECTION: Original description had different variable names that don't exist (e.g., `text`, `tabs`, `selectedTabId`, `cursorIndex`, etc.). These may be in EditorCore instead.]

### EditorCore (@EnvironmentObject)
[VERIFIED] EditorCore exists at Services/EditorCore.swift (1345 lines)
```swift
class EditorCore: ObservableObject {
    // Published state for tabs, editor settings, UI toggles
    // Much larger than originally described
}
```

### ThemeManager (Singleton)
[VERIFIED] At Models/ThemeManager.swift (77 lines)
```swift
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published var currentTheme: Theme
    @AppStorage("selectedThemeId") var selectedThemeId: String
}
```

---

## Editor Architecture

[VERIFIED] Diagram is accurate.

```
┌─────────────────────────────────────────┐
│           ContentView.IDEEditorView     │
│  ┌───────────────────────────────────┐  │
│  │  if useRunestoneEditor:           │  │
│  │    RunestoneEditorView            │  │
│  │  else:                            │  │
│  │    SyntaxHighlightingTextView     │  │
│  └───────────────────────────────────┘  │
│  + MinimapView (overlay)                │
│  + BreadcrumbsView (header) [VERIFIED]  │
└─────────────────────────────────────────┘
```
[CORRECTION: "AutocompletePopup" mentioned originally - no component by this exact name found]

### Feature Flag
[VERIFIED] At Utils/FeatureFlags.swift
```swift
// FeatureFlags.swift
static let useRunestoneEditor = true  // Use TreeSitter
static let editorPerformanceLogging = false  // [NOT MENTIONED]
```

---

## Theme System

[VERIFIED]

```
Theme.swift (19 themes, 887 lines) [VERIFIED]
    │
    ├── ThemeManager.shared.currentTheme
    │       │
    │       ├── ContentView (background colors)
    │       ├── RunestoneEditorView.makeRunestoneTheme()
    │       │       └── RunestoneEditorTheme (Runestone.Theme protocol)
    │       └── SyntaxHighlightingTextView
    │               └── VSCodeSyntaxHighlighter
    │
    └── 19 built-in themes: [VERIFIED]
        • Dark+ (default) - darkPlus
        • Light+ - lightPlus
        • Monokai - monokai
        • Solarized Dark/Light - solarizedDark, solarizedLight
        • Dracula - dracula
        • One Dark Pro - oneDarkPro
        • Nord - nord
        • GitHub Dark/Light - githubDark, githubLight
        • Cobalt2 - cobalt2
        • Ayu Dark/Light/Mirage - ayuDark, ayuLight, ayuMirage
        • Quiet Light - quietLight
        • Red - red
        • Tomorrow Night - tomorrowNight
        • Tomorrow Night Blue - tomorrowNightBlue
        • High Contrast - highContrast
```

---

## File System

[VERIFIED with corrections]

```
User opens folder via iOS document picker
    │
    ▼
FileTreeView [CORRECTION: was "FileExplorerView"]
    │
    ├── FileTreeNode (recursive tree structure) [CORRECTION: was "FileItem"]
    │       ├── url: URL
    │       ├── isDirectory: Bool
    │       └── children: [FileTreeNode]?
    │
    └── FileSystemNavigator (service) [VERIFIED - 336 lines]
            ├── loadFileTree() [CORRECTION: was "loadDirectory()"]
            ├── createFileUnique()
            ├── createFolder()
            ├── deleteItem()
            └── writeFile()
```

---

## Known Architecture Issues

### 1. ContentView is too large (~1122 lines) [VERIFIED]
- Contains embedded components that should be extracted
- Many @State variables could move to view models
- Recommendation: Break into smaller SwiftUI views

### 2. Duplicate Editor Systems [VERIFIED]
- `RunestoneEditorView` (TreeSitter) - modern
- `SyntaxHighlightingTextView` (Regex) - legacy
- Both maintained, causing code duplication
- Recommendation: Deprecate regex version once Runestone stable

### 3. Inconsistent State Management [VERIFIED]
- Some state in ContentView @State
- Some in singletons (ThemeManager.shared)
- Some in @EnvironmentObject (EditorCore)
- Recommendation: Standardize on one pattern

### 4. Services Not Fully Wired [VERIFIED]
- NativeGitWriter exists but not used [VERIFIED - no callers found]
- SSHManager is a stub [VERIFIED - throws .notImplemented]
- Several managers have code but aren't connected to UI

---

## Components NOT Mentioned in Original Document

The following significant components were missing from the original architecture:

### Services (35+ files total):
- AIManager.swift - AI assistant integration
- AutocompleteManager.swift - Code completion
- DebugManager.swift - Debugging support
- RemoteDebugger.swift - Remote debugging
- SFTPManager.swift - SFTP file transfer
- RemoteRunner.swift - Remote code execution
- SnippetsManager.swift - Code snippets
- SpotlightManager.swift - Search indexing
- WorkspaceManager.swift - Workspace management
- WindowStateManager.swift - Multi-window state
- InlayHintsManager.swift - Editor inlay hints
- HoverInfoManager.swift - Hover documentation
- CodeFoldingManager.swift - Code folding
- ColorPickerManager.swift - Color picker
- KeychainManager.swift - Secure storage
- LaunchManager.swift - App launch configs
- TasksManager.swift - Build tasks
- RecentFileManager.swift - Recent files
- NavigationManager.swift - Navigation history
- ErrorParser.swift - Error parsing
- SearchManager.swift - Search functionality
- SettingsManager.swift - Settings persistence
- SuggestionCache.swift - Suggestion caching

### Views not mentioned:
- AIAssistantView.swift
- DebugConsoleView.swift, DebugView.swift
- OutlineView.swift
- TimelineView.swift
- ProblemsView.swift
- MarkdownPreviewView.swift
- TestView.swift
- GoToLineView.swift
- GoToSymbol.swift
- Many Editor/ views (19 total)

### UITests/ folder (12 test files):
- ActivityBarUITests.swift
- BreadcrumbsUITests.swift
- CommandPaletteUITests.swift
- EditorUITests.swift
- GitUITests.swift
- QuickOpenUITests.swift
- And 6 more...

### Backup/deprecated files:
- Multiple .bak, .broken, .backup files throughout
- Menus.bak/ folder
- Duplicate files (e.g., "RunestoneThemeAdapter 2.swift")
