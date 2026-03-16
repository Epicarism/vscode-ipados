# Changelog

All notable changes to CodePad (VSCodeiPadOS) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-03-16

### Added

#### Core Editor
- Native iPadOS code editor powered by Runestone (O(log n) text storage)
- Split editor view for side-by-side file editing
- Code folding for collapsible code blocks
- Minimap for visual code navigation
- Breadcrumb navigation bar showing file path context
- Large file performance guard (100K character threshold with visible-range highlighting)
- UTF-16 safe text operations (proper emoji/CJK support in `findWordAtPosition`)
- Tab save/restore using relative paths

#### Syntax Highlighting
- Syntax highlighting for 20+ languages via regex-based engine
- Theme-aware syntax colors — all 19 themes correctly affect highlighting
- Supported languages include: Swift, Python, JavaScript, TypeScript, Rust, Go, C/C++, Java, Kotlin, Ruby, PHP, HTML, CSS, JSON, YAML, Markdown, Shell, SQL, XML, and more

#### Themes
- 19 built-in editor themes (dark, light, and custom)
- Dark themes: Monokai, Dracula, One Dark Pro, Solarized Dark, GitHub Dark, Nord, Tokyo Night, Vitesse Dark, and more
- Light themes: Solarized Light, GitHub Light, One Light, and more
- Theme-aware UI components (sidebar, panels, status bar)

#### AI Assistant
- Integrated AI chat assistant with 10 cloud providers:
  - OpenAI (GPT-4o, GPT-4.5 Preview, o3-mini, GPT-4o Mini, GPT-4 Turbo, GPT-3.5 Turbo)
  - Anthropic (Claude)
  - Google (Gemini)
  - Kimi
  - GLM
  - Groq
  - DeepSeek
  - Mistral
  - Ollama (local server)
- On-device AI via MLX framework (Nanbeige model) — runs entirely on iPad hardware
- Conversation history with multiple sessions
- AI rate limiting (2-second debounce between API calls)
- Streaming responses with cancel/stop support
- Code insertion from AI responses directly into the editor
- HuggingFace token support for downloading on-device models

#### Git Integration
- Native git repository viewer with status, diff, log, and branch display
- Git diff viewer with file-level and line-level changes
- Repository status tracking (modified, untracked, staged files)
- Polished empty state for repositories without git

#### Terminal
- Integrated terminal emulator
- Functional Escape key button
- Terminal session management
- 14 new file type UTIs for broader document support

#### File Management
- File system navigator with tree view
- File creation, rename, and delete operations
- Recent files tracking with workspace-aware paths
- 14 file type UTIs registered in Info.plist for broader document support
- Security-scoped resource access for sandboxed file operations

#### Workspace & Windowing
- Stage Manager support with configured geometry preferences and size restrictions
- Multi-window support via `UISceneSession` activation
- Workspace open via SceneDelegate
- Window state persistence

#### User Interface
- Command Palette (`⌘+Shift+P`) with real-time search filtering
- Quick Open file dialog (`⌘+O`) with real-time search filtering
- Theme-aware WelcomeView with CodePad branding
- About screen with app info, version, and features list
- Status bar with version indicator
- Sidebar navigation with VoiceOver accessibility labels
- Search panel with find and replace (workspace-wide Replace All with confirmation dialog)
- Problems panel with real diagnostics and error/warning count badges
- Tab bar with save/restore

#### Keyboard Shortcuts
- Full `UIKeyCommand` + menu system integration
- Comprehensive keyboard shortcut set documented in `KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md`
- Hardware keyboard support for all common editing operations

#### Accessibility
- VoiceOver labels on sidebar, welcome view, terminal toolbar (8 buttons), search view (4 hints), AI assistant (6 buttons + input), test view, git view, status bar, and content tabs
- Accessibility hints on interactive elements

#### Markdown
- Markdown preview with embedded CSS (no CDN dependency)
- Live preview rendering

#### Developer Experience
- Centralized `AppLogger` utility (`os.Logger`-based) with 7 categories: editor, git, ai, network, fileSystem, ui, general
- CrashReporter utility — catches uncaught exceptions, persists crash logs to disk, surfaces on next launch
- 36 notification constants replacing 40+ hardcoded strings
- `KeychainHelper` for secure API key storage
- Automatic migration of API keys from UserDefaults to iOS Keychain on first launch

#### Infrastructure
- GitHub Actions CI/CD pipeline (build + test + SwiftLint lint)
- SwiftLint configuration with project-appropriate rules
- `PrivacyInfo.xcprivacy` privacy manifest for App Store compliance
- App entitlements file (`VSCodeiPadOS.entitlements`)
- Launch screen storyboard

### Changed
- App display name changed from "VS Code" to "CodePad" for trademark compliance
- All 42 deprecated API calls updated (e.g., `.autocapitalization` → `.textInputAutocapitalization`)
- Info.plist version aligned to 1.0 (matching `MARKETING_VERSION`)
- `NSAllowsLocalNetworking` ATS exception added for Ollama/code-server connections

### Fixed
- AI Stop/Cancel button — now functional via `cancelStreaming()` + `AsyncStream`
- "New Window" menu command — implemented via `requestSceneSessionActivation`
- Terminal Escape button — now calls `sendEscape()`
- UTF-16 crash in `findWordAtPosition` — fixed for emoji/CJK characters
- Recent files opening with empty content — tab save/restore now uses relative paths
- Syntax highlighter ignoring themes — wired to `ThemeManager` colors
- 6 force-unwrap crashes (`as! String`) in `AIAgentTools.swift`
- 2 force-unwrap crashes (`themes.first!`) in `ThemeManager.swift`
- 10 crash points eliminated (URL force-unwraps, dict force-unwraps, array bounds)
- `ErrorParser` regex safety — `try!` replaced with `safeRegex()` guard (22 instances)
- LocalLLM conversation history — now reuses `MLXChatSession` correctly
- Settings search filter fix and duplicate import cleanup
- `MarkdownPreview` embedded CSS (no CDN dependency for offline use)
- RemoteDebugger tautological ternary expressions cleaned up

### Removed
- All `.bak` backup files
- Duplicate/dead files: `RunestoneThemeAdapter 2.swift`, `RunnerSelector.existing.swift`, `_tmp.txt`, `PythonRunnerAlt.swift`, `PythonRunner.swift` (OnDevice/)
- Dead `IDEAIAssistant` with fake canned responses
- 123 bare `print()` debug statements (replaced with `AppLogger`)
- All `.DS_Store` files
- Dead code from `ContentView.swift` (reduced bloat)

### Security
- API keys migrated from UserDefaults (plaintext) to iOS Keychain
- `KeychainHelper` singleton with `kSecAttrAccessibleAfterFirstUnlock` accessibility
- HuggingFace token stored in Keychain
- Zero `print()` statements that could leak sensitive data to console logs

---

## [Unreleased]

### Deferred (Feature-Flagged Off)
- SSH/SFTP Manager (entirely stub, 13 TODOs) — `FeatureFlags.enableSSH = false`
- iCloud Sync — `FeatureFlags.enableiCloudSync = false`
- Remote Execution — `FeatureFlags.enableRemoteExecution = false`
- Debugger — `FeatureFlags.enableDebugger = false`

### Known Issues
- Security-scoped resource edge case in `EditorCore.swift` (line 1015) — workaround in place
- Git push/pull via GitHub API not yet implemented
- Find References not implemented (`SyntaxHighlightingTextView.swift:866`)
- Format Document not implemented (`SyntaxHighlightingTextView.swift:878`)
- `ContentView.swift` and `EditorCore.swift` still large and need decomposition

---

[1.0.0]: https://github.com/<org>/vscode-ipados/releases/tag/v1.0.0
