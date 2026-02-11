# 🏗️ App Architecture

## High-Level Structure

```
VSCodeiPadOS/
├── App/                    # App lifecycle
│   ├── VSCodeiPadOSApp.swift    # @main entry point
│   ├── AppDelegate.swift        # UIKit lifecycle
│   └── SceneDelegate.swift      # Multi-window support
│
├── Views/                  # UI Layer
│   ├── ContentView.swift        # Main orchestrator (1100+ lines!)
│   ├── Editor/                  # Editor components
│   │   ├── RunestoneEditorView.swift    # TreeSitter editor
│   │   ├── SyntaxHighlightingTextView.swift  # Regex fallback
│   │   ├── MinimapView.swift
│   │   └── ...
│   ├── Panels/                  # Sidebar panels
│   │   ├── FileExplorerView.swift
│   │   ├── GitView.swift
│   │   ├── SearchView.swift
│   │   └── ...
│   └── Dialogs/                 # Modals & overlays
│       ├── CommandPaletteView.swift
│       ├── SettingsView.swift
│       └── ...
│
├── Models/                 # Data models
│   ├── Theme.swift              # 19 color themes
│   ├── Tab.swift                # Editor tabs
│   ├── FileItem.swift           # File tree items
│   └── ...
│
├── Services/               # Business logic
│   ├── EditorCore.swift         # Central editor state
│   ├── ThemeManager.swift       # Theme singleton
│   ├── GitManager.swift         # Git operations
│   ├── NativeGit/               # Pure Swift git
│   ├── OnDevice/                # Code runners
│   └── ...
│
├── Extensions/             # Swift extensions
├── Utils/                  # Utilities
└── Commands/               # Keyboard commands
```

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        ContentView                          │
│  (Main orchestrator - owns most @State)                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │ Sidebar  │    │  Editor  │    │  Panel   │
    │ (File,   │    │ (Rune-   │    │ (Term,   │
    │  Git,    │    │  stone)  │    │  Output) │
    │  Search) │    │          │    │          │
    └────┬─────┘    └────┬─────┘    └────┬─────┘
         │               │               │
         └───────────────┴───────────────┘
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

| Manager | Access | Purpose |
|---------|--------|----------|
| `ThemeManager.shared` | Global | Current theme, theme switching |
| `GitManager.shared` | Global | Git status, operations |
| `EditorCore` | @EnvironmentObject | Editor settings, state |
| `SSHConnectionStore.shared` | Global | Saved SSH connections |

---

## State Management

### ContentView State (Main)
```swift
// File state
@State private var text: String = ""
@State private var tabs: [Tab] = []
@State private var selectedTabId: UUID?

// UI state  
@State private var sidebarSelection: SidebarItem = .explorer
@State private var showPanel: Bool = false
@State private var showAutocomplete: Bool = false

// Editor state
@State private var cursorIndex: Int = 0
@State private var currentLineNumber: Int = 1
@State private var scrollOffset: CGFloat = 0
```

### EditorCore (@EnvironmentObject)
```swift
class EditorCore: ObservableObject {
    @Published var editorFontSize: CGFloat = 14
    @Published var selectedTheme: Theme
    // ... other editor settings
}
```

### ThemeManager (Singleton)
```swift
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published var currentTheme: Theme
    @AppStorage("selectedThemeId") var selectedThemeId: String
}
```

---

## Editor Architecture

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
│  + AutocompletePopup (overlay)          │
│  + BreadcrumbsView (header)             │
└─────────────────────────────────────────┘
```

### Feature Flag
```swift
// FeatureFlags.swift
static let useRunestoneEditor = true  // Use TreeSitter
```

---

## Theme System

```
Theme.swift (19 themes)
    │
    ├── ThemeManager.shared.currentTheme
    │       │
    │       ├── ContentView (background colors)
    │       ├── RunestoneEditorView.makeRunestoneTheme()
    │       │       └── RunestoneEditorTheme (Runestone.Theme protocol)
    │       └── SyntaxHighlightingTextView
    │               └── VSCodeSyntaxHighlighter
    │
    └── 19 built-in themes:
        • Dark+ (default)
        • Light+
        • Monokai
        • GitHub Dark/Light
        • Dracula
        • Nord
        • Solarized
        • ... and more
```

---

## File System

```
User opens folder via iOS document picker
    │
    ▼
FileExplorerView
    │
    ├── FileItem (recursive tree structure)
    │       ├── name: String
    │       ├── url: URL
    │       ├── isDirectory: Bool
    │       └── children: [FileItem]?
    │
    └── FileSystemNavigator (service)
            ├── loadDirectory()
            ├── createFile()
            ├── createFolder()
            └── deleteItem()
```

---

## Known Architecture Issues

### 1. ContentView is too large (~1100 lines)
- Contains embedded components that should be extracted
- Many @State variables could move to view models
- Recommendation: Break into smaller SwiftUI views

### 2. Duplicate Editor Systems
- `RunestoneEditorView` (TreeSitter) - modern
- `SyntaxHighlightingTextView` (Regex) - legacy
- Both maintained, causing code duplication
- Recommendation: Deprecate regex version once Runestone stable

### 3. Inconsistent State Management
- Some state in ContentView @State
- Some in singletons (ThemeManager.shared)
- Some in @EnvironmentObject (EditorCore)
- Recommendation: Standardize on one pattern

### 4. Services Not Fully Wired
- NativeGitWriter exists but not used
- SSHManager is a stub
- Several managers have code but aren't connected to UI
