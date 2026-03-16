# VSCode for iPadOS

🚀 **An audacious project to build a native VSCode experience for iPad**

Built by 300 AI agents working in parallel, 24/7.

## Vision

A **native Swift/SwiftUI** code editor that brings the full VSCode experience to iPadOS:

- 📝 Full-featured code editor with syntax highlighting
- 🧠 Language Server Protocol (LSP) for autocomplete, errors, go-to-definition
- 🔌 Extension system (compatible with VSCode extensions where possible)
- 📁 File system: iCloud Drive, local files, SSH/SFTP, GitHub
- 🖥️ Integrated terminal emulator
- 🌳 Git integration (stage, commit, push, pull, branches)
- ⌨️ Full keyboard shortcut support
- 📱 iPad-native: Split View, Slide Over, Stage Manager
- 🎨 Themes (dark/light, custom)
- 🔍 Global search, find & replace with regex

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      VSCode iPadOS                          │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (SwiftUI)                                         │
│  ├── EditorView (syntax highlighting, cursor, selection)    │
│  ├── SidebarView (file tree, search, git, extensions)       │
│  ├── TerminalView (PTY-based terminal)                      │
│  ├── TabBarView (open files, split editors)                 │
│  └── CommandPalette (Cmd+Shift+P)                           │
├─────────────────────────────────────────────────────────────┤
│  Core Layer (Swift)                                         │
│  ├── DocumentManager (open, save, track changes)            │
│  ├── LSPClient (JSON-RPC to language servers)               │
│  ├── ExtensionHost (load & run extensions)                  │
│  ├── GitManager (libgit2 bindings)                          │
│  ├── FileSystemProvider (protocol for different backends)   │
│  └── KeybindingManager (customizable shortcuts)             │
├─────────────────────────────────────────────────────────────┤
│  Platform Layer                                             │
│  ├── iCloud integration                                     │
│  ├── SSH/SFTP client                                        │
│  ├── Terminal (local shell via ios_system or similar)       │
│  └── Keyboard extension support                             │
└─────────────────────────────────────────────────────────────┘
```

## Project Status

See [STATUS.md](./STATUS.md) for current project status.  
See [BACKLOG.md](./BACKLOG.md) for task backlog.  
See [PROGRESS.md](./PROGRESS.md) for completed work.

## Building

```bash
# Open in Xcode
open VSCodeiPadOS/VSCodeiPadOS.xcodeproj

# Or build from command line
xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj -scheme VSCodeiPadOS -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch)'
```

## License

MIT
