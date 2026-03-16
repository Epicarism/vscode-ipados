# Contributing to CodePad (VSCodeiPadOS)

Thank you for your interest in contributing to CodePad! This guide covers everything you need to get started.

---

## 📋 Table of Contents

- [Development Setup](#development-setup)
- [Building the Project](#building-the-project)
- [Coding Standards](#coding-standards)
- [Feature Flags](#feature-flags)
- [Claiming Work](#claiming-work)
- [Pull Request Process](#pull-request-process)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Getting Help](#getting-help)

---

## Development Setup

### Prerequisites

| Requirement | Minimum Version |
|-------------|-----------------|
| **Xcode** | 16.0+ |
| **iPadOS Deployment Target** | 17.0+ |
| **Swift** | 6.0 |
| **macOS (for development)** | 15.0+ (Sequoia) |
| **Git** | 2.30+ |

### Getting the Code

```bash
git clone https://github.com/<org>/vscode-ipados.git
cd vscode-ipados
```

### Opening the Project

```bash
open VSCodeiPadOS/VSCodeiPadOS.xcodeproj
```

Xcode will resolve Swift Package Manager dependencies automatically (Runestone, etc.). If dependencies fail to resolve, run:

```
File → Packages → Reset Package Caches
```

---

## Building the Project

### Xcode GUI

1. Open `VSCodeiPadOS/VSCodeiPadOS.xcodeproj`
2. Select the **VSCodeiPadOS** scheme
3. Choose a target: iPad Pro 13-inch (M4) simulator or a physical iPad
4. Press **⌘R** to build and run

### Command Line

```bash
# Build for iPad Simulator
xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj \
  -scheme VSCodeiPadOS \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'

# Run tests
xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj \
  -scheme VSCodeiPadOS \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' \
  test
```

---

## Coding Standards

### Logging — Use `AppLogger`, Never `print()`

We maintain a **zero `print()` policy** in production code. All logging goes through the centralized `AppLogger` utility backed by `os.Logger`:

```swift
// ✅ Correct
import os
AppLogger.editor.debug("File loaded: \(filename)")
AppLogger.ai.error("API request failed: \(error)")
AppLogger.general.info("User action: \(action)")

// ❌ Wrong
print("File loaded: \(filename)")
NSLog("API request failed")
```

**Available log categories** (defined in `Utils/AppLogger.swift`):
- `AppLogger.editor` — Editor operations, file handling
- `AppLogger.git` — Git operations
- `AppLogger.ai` — AI assistant, LLM inference
- `AppLogger.network` — Network requests
- `AppLogger.fileSystem` — File system operations
- `AppLogger.ui` — UI events, navigation
- `AppLogger.general` — General app lifecycle, misc

### Secrets — Use `KeychainHelper`, Never `UserDefaults`

API keys and tokens **must** be stored in the iOS Keychain via `KeychainHelper`, never in `UserDefaults` (which stores values in plaintext):

```swift
// ✅ Correct
KeychainHelper.shared.set(apiKey, forKey: KeychainHelper.openAIKey)
let key = KeychainHelper.shared.get(KeychainHelper.openAIKey)

// ❌ Wrong
UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
```

**Predefined key constants** are in `KeychainHelper` extension (line 110):
`openAIKey`, `anthropicKey`, `googleKey`, `kimiKey`, `glmKey`, `groqKey`, `deepseekKey`, `mistralKey`, `hfToken`

For new keys, add a static constant to the extension and register it in `migrateFromUserDefaults()`.

### Code Style

- **No force unwraps** (`!`) — Use `guard let`, `if let`, or provide defaults
- **No force tries** (`try!`) — Use `try?` with fallbacks or proper `do/catch`
- **No `fatalError()`** in production code
- Use `safeRegex()` (from `ErrorParser`) instead of raw `try! NSRegularExpression`
- Follow existing `// MARK: -` section organization
- Use `[weak self]` in closures to prevent retain cycles
- Prefer `@EnvironmentObject` for state — `EditorCore` is the central state manager

### Notification Names

All notification names are centralized in `Constants/NotificationConstants.swift`. Never use raw strings:

```swift
// ✅ Correct
NotificationCenter.default.post(name: .editorContentDidChange, object: nil)

// ❌ Wrong
NotificationCenter.default.post(name: Notification.Name("editorContentDidChange"), object: nil)
```

---

## Feature Flags

Feature flags are centralized in `VSCodeiPadOS/FeatureFlags.swift`. Some subsystems are intentionally disabled and should not be enabled without coordination:

| Flag | Value | Notes |
|------|-------|-------|
| `useRunestoneEditor` | `true` | **Active editor engine** — O(log n) text storage |
| `enableSSH` | `false` | SSH Manager is entirely stub (13 TODOs) |
| `enableiCloudSync` | `false` | Not implemented |
| `enableRemoteExecution` | `false` | Not implemented |
| `enableDebugger` | `false` | Not implemented |
| `editorPerformanceLogging` | `false` | Verbose logging for debugging editor perf |

> ⚠️ **Do not flip flags to `true` for SSH, iCloud, Remote, or Debugger** — these are stubs that will compile but have no real implementation. See `BACKLOG.md` for their status.

---

## Claiming Work

### Before Starting

1. **Check `SPRINT_STATUS.md`** — This is the authoritative source for what's in progress, done, or deferred
2. **Check `AGENTS.md`** — See what other SWEs are currently working on to avoid conflicts
3. **Check `BACKLOG.md`** — Browse available tasks and their priorities

### Claiming a Task

Edit `SPRINT_STATUS.md` and set the **Owner** column to your name and status to 🟡:

```markdown
| 17 | ContentView.swift decomposition | `ContentView.swift` | 🟡 In Progress | YourName |
```

### Coordination Rules (from `AGENTS.md`)

1. Before starting work, check `AGENTS.md` for active sessions and conflicts
2. List files you are modifying so others avoid them
3. Update `BACKLOG.md` status when you pick up or complete tasks
4. Update `PROGRESS.md` when you finish something
5. Commit frequently with descriptive messages
6. If you see a conflict, coordinate via `AGENTS.md`

---

## Pull Request Process

1. **Branch from `main`** — Never commit directly to `main`
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feat/your-feature-name
   ```

2. **Describe your changes** — The PR description should include:
   - What changed and why
   - Which issue(s) it addresses (e.g., `Fixes #12`, `Closes BUG-009`)
   - Any breaking changes or migration notes
   - Screenshots for UI changes

3. **Keep PRs focused** — One concern per PR. If you're fixing a bug and adding a feature, split them.

4. **Pass CI** — All PRs must pass the GitHub Actions pipeline (build + test + lint):
   - Build targets macOS 15 + Xcode 16
   - SwiftLint must pass (`.swiftlint.yml` at project root)
   - All existing tests must pass

5. **Code review** — At least one approval required before merge

6. **Commit messages** — Use conventional commit format:
   ```
   feat: add find-and-replace across workspace
   fix: resolve UTF-16 crash in findWordAtPosition
   refactor: extract theme colors from syntax highlighter
   docs: update CONTRIBUTING.md with logging standards
   ```

---

## Project Structure

```
VSCodeiPadOS/
├── VSCodeiPadOS.xcodeproj       # Xcode project file
├── FeatureFlags.swift            # Centralized feature toggles
├── VSCodeiPadOS/
│   ├── App/                      # App lifecycle (AppDelegate, SceneDelegate, VSCodeiPadOSApp)
│   ├── Constants/                # NotificationConstants and other shared constants
│   ├── Extensions/               # Syntax highlighting, NSAttributedString extensions
│   ├── OnDevice/                 # On-device code execution (MLX, runners)
│   ├── Services/                 # Core services (AIManager, EditorCore, GitManager, etc.)
│   ├── Utils/                    # Utilities (AppLogger, KeychainHelper, ErrorParser, Codicon)
│   └── Views/                    # SwiftUI views
│       ├── Editor/               # Editor views (Runestone, Split, etc.)
│       └── Panels/               # Sidebar panels (Settings, Search, Git, AI, etc.)
```

### Key Files

| File | Purpose |
|------|---------|
| `Services/EditorCore.swift` | Central state manager — all state flows through this `@EnvironmentObject` |
| `Services/AIManager.swift` | AI assistant with 10 providers + on-device MLX |
| `Services/GitManager.swift` | Git integration (reader done, write ops stub) |
| `Services/LocalLLMService.swift` | On-device LLM via MLX framework |
| `Utils/AppLogger.swift` | Centralized logging + CrashReporter |
| `Utils/KeychainHelper.swift` | Keychain wrapper for API key storage |
| `FeatureFlags.swift` | Feature toggles |

---

## Testing

Run tests via Xcode (⌘U) or command line:

```bash
xcodebuild test -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj \
  -scheme VSCodeiPadOS \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'
```

---

## Getting Help

- 📖 **`README.md`** — Project overview and feature list
- 🏃 **`SPRINT_STATUS.md`** — Current sprint tasks and ownership
- 📋 **`BACKLOG.md`** — Full bug/feature backlog with priorities
- 📝 **`PROGRESS.md`** — Chronological log of completed work
- 🤖 **`AGENTS.md`** — Agent activity and coordination
- ⌨️ **`VSCodeiPadOS/VSCodeiPadOS/KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md`** — Keyboard shortcut architecture
- 📄 **`VSCodeiPadOS/Docs/NANBEIGE_TEMPLATE_FIX.md`** — Critical LLM fix documentation

---

## Code of Conduct

Be respectful, constructive, and collaborative. Focus on making the codebase better for everyone. Review PRs generously and welcome newcomers.
