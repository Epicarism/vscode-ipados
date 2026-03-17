# VSCode iPadOS — App Store Readiness Roadmap

**Last Updated:** March 17, 2026  
**Build Status:** ✅ CLEAN (0 errors, 0 warnings from our code)

---

## 📊 Current Feature Inventory

| Feature | Status | Notes |
|---------|--------|-------|
| **Code Editor** | 🟢 Strong | Runestone engine, syntax highlighting (20+ langs), autocomplete, multi-cursor, code folding, minimap, breadcrumbs, sticky headers, inlay hints, bracket matching, peek definition |
| **File Management** | 🟢 Strong | File tree sidebar, tabs, auto-save, workspace persistence, security-scoped bookmarks, drag & drop, 50MB file limit |
| **Themes** | 🟢 Strong | 21 themes (15 dark, 6 light) — Monokai, Dracula, Nord, Solarized, One Dark, GitHub, etc. |
| **AI Integration** | 🟢 Strong | 10 providers (OpenAI, Anthropic, Google, Ollama, etc.), 40+ models, tool calling, inline Copilot-style suggestions, on-device MLX inference |
| **Search** | 🟢 Strong | Find-in-files, regex, replace-in-files, include/exclude globs, 10MB per-file limit |
| **Git** | 🟡 Partial | Init, commit, stage, unstage, branch create/switch, status, diff — but **clone is stub**, push/pull need SSH auth fixes |
| **SSH** | 🟡 Partial | SwiftNIO-based client, connect/disconnect, command execution — but **private key auth broken**, no agent forwarding |
| **Terminal** | 🔴 Weak | Custom line-based output (not a real VT100 terminal). No curses/vim/htop. No local shell (iOS sandbox). |
| **Debugging** | 🔴 Stub | JS REPL via JavaScriptCore only. No DAP, no breakpoints, no real debugging. |
| **Extensions** | 🔴 Simulated | Curated catalog with toggle on/off. iOS can't load dynamic code — extensions are pre-bundled behaviors. |
| **VS Code Tunnel** | 🔴 Stub | VSCodeTunnelView.swift exists with WKWebView shell but tunnel binary isn't bundled or connected. |
| **Keyboard Shortcuts** | 🟡 Partial | 15+ shortcuts via UIKeyCommand. Some missing (Cmd+D, Cmd+/, Cmd+Shift+L). Some may conflict with iPadOS 18+. |
| **Settings** | 🟢 Good | Font size, theme, tab size, auto-save, minimap, word wrap, AI provider config, SSH config |
| **Panels** | 🟢 Good | Terminal, Output, Problems, Debug Console — bottom panel with tabs |

---

## 🎯 Top Priorities for App Store Submission

### Priority 1: VS Code Tunnel Integration (THE KILLER FEATURE)

**What:** Connect to a VS Code Server (code-server / VS Code Tunnel) running on a remote machine, using OUR native UI as the frontend while getting full VS Code backend capabilities (extensions, IntelliSense, debugging, terminal).

**Why:** This is the only realistic way to get real VS Code extension support, real debugging, and real terminal on iPad. Apple won't allow dynamic code loading, but connecting to a remote VS Code server is perfectly fine.

**How:**
1. Bundle the `code` CLI tunnel binary for ARM64 (or use the VS Code Server HTTP API directly)
2. `VSCodeTunnelView.swift` already has WKWebView — but we want HYBRID:
   - Use the VS Code Server's **Language Server Protocol** (LSP) for IntelliSense/diagnostics
   - Use the VS Code Server's **Debug Adapter Protocol** (DAP) for debugging
   - Use the VS Code Server's **terminal** for real shell access
   - Keep OUR native Runestone editor for the actual text editing (feels native)
3. Alternatively: Full WebView mode where the entire VS Code web UI loads in WKWebView (simpler, less native feel)

**Files to modify:**
- `VSCodeTunnelView.swift` — Main tunnel view
- `VSCodeTunnelManager.swift` — Tunnel lifecycle
- New: `LSPClient.swift` — Language Server Protocol client
- New: `DAPClient.swift` — Debug Adapter Protocol client

**Estimated effort:** 2-3 weeks for hybrid, 1 week for pure WebView

---

### Priority 2: Real Terminal Emulator

**What:** Replace the custom line-based terminal with a real VT100/xterm-compatible terminal.

**Why:** Current terminal can't handle vim, htop, interactive prompts, colors, cursor movement.

**How:**
1. Add **SwiftTerm** package (MIT license, iOS-compatible, used by many apps)
2. Connect SwiftTerm to SSH sessions for remote terminal
3. For local: Use the VS Code Tunnel's terminal (iPad can't run local shell)

**Files to modify:**
- New: `SwiftTermView.swift` — SwiftTerm wrapper for SwiftUI
- `TerminalView.swift` — Replace current implementation  
- `SSHManager.swift` — Pipe SSH channel data to SwiftTerm
- `Package.swift` or SPM — Add SwiftTerm dependency

**Estimated effort:** 1 week

---

### Priority 3: Git Clone & Auth

**What:** Implement actual git clone, fix push/pull authentication.

**Why:** Without clone, users can't start working on existing repos. Without push/pull, they can't collaborate.

**How:**
1. Implement clone using the existing `NativeGitWriter` approach (create .git structure, fetch pack files)
2. OR use `libgit2` via SwiftGit2 package (more robust)
3. Fix SSH key auth in SSHManager for git operations
4. Add HTTPS auth with token/credential storage in Keychain

**Files to modify:**
- `GitManager.swift` — Implement `cloneRepository()` (currently a stub)
- `NativeGitWriter.swift` / `NativeGitReader.swift` — Pack file support
- `SSHManager.swift` — Fix private key auth
- New: `GitCredentialManager.swift` — Keychain-based credential storage

**Estimated effort:** 2 weeks

---

### Priority 4: Keyboard Shortcuts Polish

**What:** Audit and fix all keyboard shortcuts for iPadOS 18+ compatibility.

**Why:** iPad users with keyboards expect VS Code-like shortcuts. Conflicts with system shortcuts = bad UX.

**How:**
1. Fix Cmd+D (select next occurrence) — currently mapped to debug
2. Add Cmd+/ (toggle comment)
3. Add Cmd+Shift+L (select all occurrences)
4. Add Cmd+Shift+K (delete line)
5. Test all shortcuts against iPadOS 18 system shortcuts
6. Add customizable keybindings settings

**Files to modify:**
- `KeyCommandBridge.swift` — Main shortcut handler
- `EditorKeyCommands.swift` — Editor-specific shortcuts
- `ContentView.swift` — Top-level key commands
- New: `KeybindingsManager.swift` — User-customizable bindings

**Estimated effort:** 3-4 days

---

### Priority 5: SSH Private Key Auth Fix

**What:** Fix SSH authentication with private keys (ED25519, RSA).

**Why:** Most developers use SSH keys. Password-only auth is a dealbreaker.

**How:**
1. Fix the `NIOSSHPrivateKey` conversion in SSHManager
2. Support reading keys from iPad's Files app or secure enclave
3. Add SSH key generation (ED25519)
4. Support SSH agent forwarding
5. Support SSH config file parsing

**Files to modify:**
- `SSHManager.swift` — Fix `authenticateWithKey()` method
- New: `SSHKeyManager.swift` — Key storage, generation, import

**Estimated effort:** 1 week

---

## 🏗️ Architecture Notes

### Key Files (for new SWE)
```
ContentView.swift          (1336 lines) — Main layout, sidebar + editor + panels
EditorCore.swift           (1979 lines) — Central state: files, tabs, workspace
AIManager.swift            (1592 lines) — Multi-provider AI with tool calling
GitManager.swift           (1027 lines) — Git operations (native Swift impl)
SSHManager.swift           (996 lines)  — SwiftNIO SSH client
SyntaxHighlightingTextView (2525 lines) — Legacy UIKit editor (being replaced)
RunestoneEditorView.swift  (771 lines)  — Primary editor (Runestone engine)
ThemeManager.swift         (500+ lines) — 21 themes with full color tokens
SearchManager.swift                     — Find/replace in files
ExtensionManager.swift                  — Curated extension catalog
```

### Dependencies
- **Runestone** — Code editor engine (syntax highlighting, line numbers)
- **SwiftNIO + NIOSSH** — SSH client
- **KeychainAccess** — Secure credential storage
- **Splash** — Swift syntax highlighting

### iPad-Specific Considerations
- No local shell execution (iOS sandbox)
- No dynamic code loading (no real extensions)
- Security-scoped bookmarks for file access
- Stage Manager / Split View support needed
- External display support would be nice

---

## 📋 App Store Review Checklist

- [ ] Privacy policy URL
- [ ] App description & screenshots (iPad Pro, iPad Air, iPad mini)
- [ ] No private API usage
- [ ] All network calls use HTTPS (ATS compliance)
- [ ] File access uses security-scoped bookmarks correctly
- [ ] No crashes on launch (test on all supported iPad models)
- [ ] Accessibility labels on all interactive elements
- [ ] Support for Dynamic Type
- [ ] Stage Manager compatibility
- [ ] External keyboard support documented in App Store description
- [ ] In-App Purchase or subscription for AI features (if applicable)
- [ ] Age rating appropriate
- [ ] Export compliance (SSH uses encryption — need export compliance docs)

---

## 🔧 Recent Bug Fixes (March 17, 2026)

### Commit `b77da99` — Eliminate 50+ compiler warnings
- Fixed MainActor isolation issues across 24 files
- Fixed deprecated onChange syntax → iOS 17+
- Fixed async/nonisolated conflicts
- Added missing AccentColor asset

### Commit `7c9c3de` — Squash 10 high-priority bugs
- EditorCore: Surface save errors to UI
- EditorCore: 50MB file size limit (OOM prevention)
- EditorCore: Improved save timing reliability
- SearchManager: Fixed silent write failures
- SearchManager: Skip >10MB files during search
- SSHManager: Fixed retain cycles (weak self)
- GitManager: Prevented config data loss on read failure
- ContentView: Fixed clone UI opening wrong picker

### Commit `95acf37` — SSHManager cleanup
- Silenced unavoidable weak var warning in NIO handler

---

## 💡 VS Code Tunnel Strategy (Detailed)

The **hybrid approach** is recommended:

```
┌─────────────────────────────────────────────┐
│           iPad App (Native Swift)            │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │ Runestone │  │ File     │  │ Git       │  │
│  │ Editor   │  │ Explorer │  │ Panel     │  │
│  │ (native) │  │ (native) │  │ (native)  │  │
│  └────┬─────┘  └──────────┘  └───────────┘  │
│       │                                      │
│  ┌────▼──────────────────────────────────┐   │
│  │     VS Code Server Bridge (new)       │   │
│  │  • LSP Client (IntelliSense)          │   │
│  │  • DAP Client (Debugging)             │   │
│  │  • Terminal Proxy (real shell)         │   │
│  │  • Extension Host Proxy               │   │
│  └────┬──────────────────────────────────┘   │
│       │ WebSocket / HTTP                     │
└───────┼──────────────────────────────────────┘
        │
   ┌────▼────────────────────────┐
   │  Remote Machine / Cloud     │
   │  VS Code Server (code CLI)  │
   │  • Full extension runtime   │
   │  • Language servers          │
   │  • Debug adapters            │
   │  • Shell / terminal          │
   └─────────────────────────────┘
```

This gives users:
- **Native feel** (our beautiful Swift UI)
- **Full VS Code power** (extensions, debugging, terminal)
- **Works offline** for basic editing (Runestone)
- **Works online** for full IDE features (tunnel)

---

*This document is the source of truth for the VSCode iPadOS project roadmap.*
