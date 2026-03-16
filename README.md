# VSCode for iPadOS

🚀 **A native code editor for iPad inspired by VS Code** — built with Swift/SwiftUI

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iPadOS%2017+-blue.svg)](https://developer.apple.com/ipados/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## ✨ Features

### Editor
- **Runestone-powered editor** with O(log n) text storage and Tree-sitter syntax highlighting
- **20+ languages** supported (Swift, Python, JavaScript, TypeScript, Rust, Go, C/C++, Java, Ruby, HTML, CSS, JSON, YAML, Markdown, and more)
- **19 built-in themes** (Dark+, Light+, Monokai, Dracula, One Dark Pro, Nord, Solarized, GitHub, Ayu, and more)
- Multi-cursor editing, code folding, bracket matching
- Minimap, breadcrumbs, git gutter, inlay hints
- Split editor (vertical, horizontal, grid)
- Inline suggestions and hover info

### IDE Features
- **Command Palette** (⌘⇧P) with fuzzy search
- **Quick Open** (⌘P) with file filtering
- **Go to Symbol** (⌘⇧O), **Go to Line** (⌘G)
- **Find & Replace** with regex support, scope control (file/workspace)
- **Full keyboard shortcut system** — 60+ shortcuts via UIKeyCommand + menu bar
- Integrated terminal panel
- File tree with drag & drop support

### AI Assistant
- **11 AI providers**: OpenAI, Anthropic, Google, DeepSeek, Groq, Mistral, Kimi, GLM, Ollama, and more
- **On-device LLM** via Apple MLX framework (Nanbeige, Qwen3 models)
- AI-powered code suggestions and chat

### Git & Collaboration
- Git status, staging, branching
- GitHub OAuth authentication
- Diff view components

### iPad-Native
- Stage Manager / multi-window support
- Split View and Slide Over
- Workspace persistence across launches
- Security-scoped file access

---

## 📋 Requirements

- **iPadOS 17.0+** (or iOS Simulator)
- **Xcode 15.0+**
- **Swift 5.9+**
- Apple Silicon Mac recommended for on-device LLM features

---

## 🔨 Building

```bash
# Open in Xcode
open VSCodeiPadOS/VSCodeiPadOS.xcodeproj

# Or build from command line
xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj \
  -scheme VSCodeiPadOS \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'
```

---

## 🏗️ Architecture

```
VSCodeiPadOS/
├── App/                    # App entry point, delegates, lifecycle
├── Views/                  # SwiftUI views
│   ├── Editor/             # Editor components (Runestone, syntax, minimap)
│   └── Panels/             # Side/bottom panels (terminal, git, search, AI)
├── Services/               # Core logic (50+ service files)
│   ├── EditorCore.swift    # Central state manager (@EnvironmentObject)
│   ├── AIManager.swift     # Multi-provider AI integration
│   ├── GitManager.swift    # Git operations
│   ├── LocalLLMService.swift # On-device MLX inference
│   ├── NativeGit/          # Native git reader/writer
│   ├── OnDevice/           # JS/WASM/Python runners
│   └── Runners/            # Language-specific code runners
├── Models/                 # Data models (Tab, Theme, FileItem, EditorState)
├── Extensions/             # Swift extensions and utilities
├── Commands/               # Menu bar commands
└── Utils/                  # Feature flags, logging, helpers
```

**Key patterns:**
- **Centralized state** via `EditorCore` (`ObservableObject` + `@EnvironmentObject`)
- **Notification-based** command dispatch from menus/shortcuts
- **Feature flags** gate experimental subsystems (SSH, iCloud, debugger)
- **Singleton services** for theme, workspace trust, auto-save, window state

---

## 📊 Project Status

See [SPRINT_STATUS.md](./SPRINT_STATUS.md) for current tasks and team coordination.  
See [BACKLOG.md](./BACKLOG.md) for the full bug/feature backlog.  
See [PROGRESS.md](./PROGRESS.md) for completed work log.

| Feature | Status |
|---------|--------|
| Runestone Editor | ✅ 95% |
| Theme System (19 themes) | ✅ 100% |
| Keyboard Shortcuts | ✅ 100% |
| Syntax Highlighting (20+ langs) | ✅ 100% |
| Multi-Window / Stage Manager | ✅ 100% |
| Command Palette & Quick Open | ✅ 100% |
| On-Device LLM (MLX) | 🟡 80% |
| Native Git | 🟡 70% |
| AI Assistant (cloud) | 🟡 60% |
| Extension System | 🟡 30% |
| SSH/SFTP | 🔴 5% |

---

## 🤝 Contributing

This project is built by AI agents working in parallel. If you're an SWE (human or AI):

1. Check [SPRINT_STATUS.md](./SPRINT_STATUS.md) for available tasks
2. Claim a task by updating the Owner column
3. Follow the keyboard shortcuts architecture in `KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md`
4. **Do NOT remove** Nanbeige template patching code (see `Docs/NANBEIGE_TEMPLATE_FIX.md`)

---

## 📄 License

[MIT](LICENSE) © 2024-2026 VSCode iPadOS Contributors
