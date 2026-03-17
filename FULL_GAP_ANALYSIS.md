# CodePad (VSCode iPadOS) — Full Feature Gap Analysis

**Date:** March 17, 2026  
**Prepared by:** Lead Architecture Audit  
**App Name:** CodePad - Code Editor  
**Target:** iPadOS App Store submission  
**Current State:** ~73K lines Swift, ~100 files, functional but incomplete

---

## 📊 EXECUTIVE SUMMARY

CodePad has an **impressively complete UI shell** that faithfully recreates VS Code's layout — Activity Bar, Sidebar panels, Tab Bar, Breadcrumbs, Status Bar, Bottom Panels, Command Palette, Quick Open, Minimap, and 20 themes. However, under the surface, most "smart" features are **simulated or stubbed**. The app looks like VS Code but thinks like a fancy text editor with some AI bolted on.

### The Big Picture

| Area | UI Complete? | Backend Working? | App Store Ready? |
|------|-------------|-------------------|------------------|
| Editor (syntax, folding, multi-cursor) | ✅ | ✅ (Runestone + TreeSitter) | ✅ |
| Themes (20 built-in) | ✅ | ✅ | ✅ |
| File Explorer & Operations | ✅ | ✅ | ✅ |
| Find/Replace (in files) | ✅ | ✅ | ✅ |
| Git (local: status/stage/commit/branch) | ✅ | ✅ | ✅ |
| Git (remote: push/pull/fetch) | ✅ | ⚠️ SSH-only | ⚠️ |
| Git Clone | ❌ | ❌ NOT IMPLEMENTED | 🔴 |
| Terminal (local) | ✅ | ❌ Fake (22 hardcoded cmds) | 🔴 |
| Terminal (SSH remote) | ✅ | ⚠️ Works but not real emulator | ⚠️ |
| SSH Connection | ✅ | ⚠️ Password only, no real pubkey | ⚠️ |
| Debugger | ✅ | ❌ Simulated locally, SSH-only real | ⚠️ |
| Extensions/Marketplace | ✅ | ❌ Pure UI shell, zero functionality | 🔴 |
| Autocomplete/IntelliSense | ⚠️ | ❌ No LSP, regex-only | 🔴 |
| AI Chat | ✅ | ✅ (10 providers, tool calling) | ✅ |
| AI Inline Suggestions | ✅ | ❌ Returns nil (stubbed) | 🔴 |
| Keyboard Shortcuts | ⚠️ | ⚠️ Conflicts + missing shortcuts | ⚠️ |
| VS Code Tunnel/Connected Mode | ✅ | ✅ (WKWebView → URL) | ✅ |
| App Store Metadata | ✅ | ✅ | ⚠️ Minor issues |

---

## 🔴 CRITICAL MISSING FEATURES (Must Fix Before App Store)

### 1. Git Clone — COMPLETELY MISSING
**Impact:** Users cannot create repositories from the app. They have no way to start a project from a remote repo.

**What exists:** Zero. Not even a TODO. `NativeGitReader`/`NativeGitWriter` don't have clone methods. `SSHGitClient` mentions clone in a comment but implements nothing.

**What's needed:**
- Clone via HTTPS (using `URLSession` — no git binary needed)
- Clone via SSH (already have `SSHManager`)
- UI: Clone dialog (URL input, directory picker, auth, progress)
- Pack file support in `NativeGitReader` (currently returns nil for packed objects — this means cloned repos won't work locally since `git clone` creates pack files)

**Recommendation:** Implement HTTPS clone using a pure-Swift git pack protocol client, or integrate `SwiftGit2` (libgit2 wrapper) which handles clone natively. This is the **#1 blocker**.

### 2. Terminal — Fake Local Shell
**Impact:** The terminal is one of VS Code's most-used features. Ours fakes it with 22 hardcoded commands.

**What exists:** `processLocalCommand()` — a switch statement that handles `ls`, `cd`, `cat`, `mkdir`, `touch`, `rm`, `cp`, `mv`, `grep`, `find`, `head`, `tail`, `wc`, `echo`, `date`, `whoami`, `pwd`, `history`, `env`, `help`, `clear`, `ssh`. Output rendered as SwiftUI `Text` in a `ScrollView` — not a real terminal emulator.

**What's needed:**
- Replace with **SwiftTerm** (`github.com/migueldeicaza/SwiftTerm`) — real VT100/xterm emulator with native `UIView`
- Pipe SSH output through SwiftTerm's `feed()` instead of our line buffer
- For local: Keep the simulated commands (iOS can't spawn shells) but present them properly
- Consider: Bundle a WASM-based shell (like `wasm-shell`) for local mode

**iOS Reality:** iPadOS apps CANNOT spawn `/bin/sh`. Local terminal will always be limited. SSH remote terminal is the real path. But the current rendering (SwiftUI ScrollView + TextField) needs to be SwiftTerm for proper ANSI/cursor/scrollback support.

### 3. Extensions — Pure UI Shell With Zero Functionality
**Impact:** App Store reviewers will see an Extensions panel that does nothing. Installing "ESLint" doesn't enable linting. This could be flagged as misleading.

**What exists:** `ExtensionManager.swift` — 25 fake catalog entries mimicking real VS Code extensions. Install/uninstall toggles a boolean. No effect on the app whatsoever.

**Options:**
- **Option A (Recommended for v1.0):** Remove the fake marketplace entirely. Replace with a curated "Features" panel showing what's built-in (themes, language support, AI, Git). Honest > impressive.
- **Option B (v2.0):** Build a real extension system with a custom format (theme packs, snippet packs, language grammar packs). These are safe for App Store (no executable code download).
- **Option C (v3.0+):** Support VS Code extension API subset via embedded JS runtime. Very complex, potential App Store issues (Guideline 2.5.2).

### 4. Inline AI Suggestions — Wired But Returns Nil
**Impact:** The entire inline suggestion pipeline is built (debounce, throttle, cache, ghost text rendering, Tab to accept, partial accept) but `fetchSuggestion()` returns `nil`. This is the most visible AI feature and it's dead.

**Fix:** Wire `fetchSuggestion()` to the existing `AIManager` — it already supports 10 providers. Use the FIM (Fill-in-the-Middle) prompt format. This could be a quick win.

### 5. Pack File Support in NativeGitReader
**Impact:** Any repository that has been `git gc`'d or was cloned (which creates pack files) will have missing history/objects. This breaks most real-world repos.

**What exists:** `readPackedObject()` returns `nil` with comment: "For MVP, rely on loose objects + SSH fallback for packed repos."

**What's needed:** Implement `.git/objects/pack/*.idx` and `*.pack` parsing. This is a well-documented binary format.

---

## 🟡 IMPORTANT GAPS (Should Fix Before or Shortly After Launch)

### 6. Keyboard Shortcuts — Conflicts & Missing

**Conflicts found:**
- `⌘⌥H` vs `⌘⌥F` — Two different shortcuts bound to Replace (App.swift vs KeyCommandBridge)
- `⌘/` — Bound to "Keyboard Shortcuts Help" instead of VS Code standard "Toggle Line Comment"
- Several shortcuts only in SwiftUI `.commands{}` but missing from UIKit `KeyCommandBridge` — they won't work when focus is in a UIKit text view

**Missing critical VS Code shortcuts:**
- `⌘/` — Toggle Line Comment (THE most used shortcut)
- `⌘D` — Add Next Occurrence
- `⌥↑/↓` — Move Line Up/Down
- `⌘\` — Split Editor
- `⌘⇧F` — Find in Files (panel)
- `F5/F9/F10/F11` — Debug shortcuts
- `⌘⇧U` — Toggle Output panel
- `⌘⇧M` — Toggle Problems panel

**iPadOS conflict check:** ✅ No conflicts with system shortcuts (⌘H, ⌘Tab, ⌘Space, Globe+key). The app uses `wantsPriorityOverSystemBehavior = true` appropriately.

### 7. No Language Server Protocol (LSP)
**Impact:** Without LSP, there's no real autocomplete, no compiler diagnostics, no semantic go-to-definition, no rename refactoring. Everything is regex-based approximation.

**Current state:**
- Go-to-Definition: Text search in open files only
- Autocomplete: 60 Swift keywords + 50 stdlib types only
- Diagnostics: Regex linter (trailing whitespace, long lines, TODO detection)
- Hover: Hardcoded info for 3 Swift symbols (`print`, `String`, `View`)
- Find References: Regex whole-word search across open tabs

**Recommendation for v1.0:** Bundle `sourcekit-lsp` for Swift (it's open source, runs on iOS). For JavaScript/TypeScript, consider bundling a WASM build of TypeScript language service. This is the biggest quality differentiator between "text editor" and "IDE".

**Reality check:** LSP on iOS is extremely challenging. No prior App Store app has done this. For v1.0, improve the regex-based features and lean on AI for intelligent completions.

### 8. SSH Public Key Authentication — Broken
**Impact:** Most developers use SSH keys, not passwords. Our implementation passes the private key AS the password (literally), which won't work with any real server.

**What exists:** `SSHManager.swift` line 213: `PasswordAuthDelegate(username: username, password: privateKey)` with TODO comment.

**Fix:** Implement `NIOSSHPrivateKey`-based authentication using SwiftNIO SSH's proper key auth flow. Support Ed25519, RSA, and ECDSA keys.

### 9. SSH Host Key Verification — Security Vulnerability
**Impact:** `AcceptAllHostKeysDelegate` accepts every host key. This is a MITM vulnerability. App Store reviewers or security auditors may flag this.

**Fix:** Implement known_hosts storage in Keychain. On first connect, show fingerprint and ask user to verify. On subsequent connects, verify against stored key.

### 10. No .gitignore Respect
**Impact:** Search results include `node_modules/`, `build/`, `.next/`, etc. File tree shows everything.

**Fix:** Parse `.gitignore` files and filter both file tree and search results.

### 11. File Watching — Not Implemented
**Impact:** External file changes (e.g., git operations, other apps) don't reflect in the editor until manual refresh.

**Fix:** Use `DispatchSource.makeFileSystemObjectSource` or poll on app foreground.

---

## 🟢 WHAT WORKS WELL (Ship-Ready)

### Editor Core ✅
- Runestone + TreeSitter = real syntax highlighting for 8 languages
- O(log n) rope-based text storage (comparable to Monaco's piece table)
- Multi-cursor editing (⌘⌥↑/↓, ⌘D, ⌘⇧L)
- Code folding with FoldingLayoutManager
- Bracket matching with 6-color pairs
- Minimap with visible region + git diff indicators
- Split editor (horizontal/vertical)
- Breadcrumbs navigation
- Git gutter (added/modified/deleted indicators)
- Find/Replace with regex, case, whole-word
- Sticky scope headers

### Themes ✅
- 20 built-in themes including all popular ones (Monokai, Dracula, One Dark Pro, Nord, Solarized, GitHub, Ayu, etc.)
- ~50 color properties per theme covering editor, UI, syntax, semantic, diff, brackets
- Animated theme switching
- Persisted across sessions

### Git (Local Operations) ✅
- Pure-Swift .git directory parsing (no git binary needed!)
- Status, stage, unstage, commit, branch CRUD, diff, history
- Works completely offline
- Merge conflict detection and resolution UI

### AI Chat ✅
- 10 AI providers (OpenAI, Anthropic, Google, DeepSeek, Mistral, Groq, Kimi, GLM, Ollama, on-device MLX)
- 30+ models
- Streaming responses
- Tool calling with 11 tools (read/write files, search, etc.)
- Session management
- Context injection (workspace, current file, selection)
- On-device LLM via MLX (runs on Apple Silicon iPads!)

### UI Layout ✅
- Faithful VS Code layout reproduction
- 7 Activity Bar tabs with full sidebar panels
- 7 Bottom Panel tabs (Problems, Output, Terminal, Debug Console, Ports, Timeline, Source Control)
- Command Palette (⌘⇧P)
- Quick Open (⌘P)
- Go to Symbol (⌘⇧O)
- Go to Line (⌃G)
- Status Bar with full information
- Multi-window support (Stage Manager)
- Drag-to-new-window for tabs

### File Operations ✅
- Create, delete, rename, move files and folders
- Security-scoped resource handling for iPadOS
- Recent files with bookmark persistence
- CoreSpotlight indexing

### VS Code Tunnel/Connected Mode ✅
- WKWebView-based connection to VS Code Server, code-server, or Codespaces
- Supports 4 connection types (VS Code Tunnel, code-server, Codespaces, Custom URL)
- Server management UI (add, remove, connect, disconnect)
- Desktop user agent for best experience
- This is actually the **killer feature** — see architecture recommendation below

---

## 🏗️ ARCHITECTURE RECOMMENDATION: THE TUNNEL STRATEGY

### Your Idea Is Correct — But With a Twist

You asked: "Can we connect the app to VS Code Tunnel so that OUR UI is the 'webview' but the backend connects to VS Code?"

**Short answer:** Not with native UI as the frontend. The VS Code Server protocol is proprietary and undocumented. However, there's a better path:

### Recommended Architecture: Dual-Mode App

```
┌─────────────────────────────────────────────────────┐
│                    CodePad App                        │
│                                                       │
│  ┌─────────────────┐    ┌──────────────────────────┐ │
│  │   LOCAL MODE     │    │   CONNECTED MODE          │ │
│  │   (Native UI)    │    │   (WKWebView)             │ │
│  │                  │    │                            │ │
│  │ • Runestone editor│    │ • Full VS Code in WebView │ │
│  │ • Local git ops  │    │ • Real terminal (PTY)     │ │
│  │ • AI assistant   │    │ • Real extensions         │ │
│  │ • File explorer  │    │ • Real IntelliSense       │ │
│  │ • Simulated term │    │ • Real debugger (DAP)     │ │
│  │ • SSH remote     │    │ • Everything VS Code has  │ │
│  │                  │    │                            │ │
│  │ Works offline ✈️  │    │ Needs server connection 🌐│ │
│  └─────────────────┘    └──────────────────────────┘ │
│                                                       │
│  Native shell provides:                               │
│  • iPad-native file picker integration                │
│  • Share sheet, drag & drop                           │
│  • Keyboard shortcut management                       │
│  • Theme synchronization                              │
│  • Server connection management                       │
│  • AI features (works in both modes)                  │
└─────────────────────────────────────────────────────┘
```

### Why This Works:

1. **Local Mode** = What we have now. Polish it. It works offline, is fast, native. Good for quick edits, file browsing, AI chat, local git.

2. **Connected Mode** = Full VS Code via WKWebView connecting to:
   - **code-server** (MIT licensed ✅) — self-hosted
   - **VS Code Tunnel** (user runs `code tunnel` on their machine)
   - **GitHub Codespaces** (GitHub's cloud)
   - **Gitpod, Railway, etc.**

3. **Already built!** `VSCodeTunnelView.swift` already does this — WKWebView loads a URL. `TunnelManager` manages server configs. We just need to polish the experience.

### Licensing:
- ✅ **code-server**: MIT — free to use commercially
- ✅ **VS Code web source**: MIT (with MS branding removed)
- ✅ **Dev Tunnels SDK**: MIT
- ❌ **VS Code Server binary**: Proprietary — cannot redistribute
- The key: We don't redistribute anything. User provides their own server URL.

### App Store Safety:
- We're not downloading/executing code — we're displaying a web page in WKWebView
- Precedent: Every web browser on iOS does this
- The user explicitly configures server connections
- Our app provides value even without Connected Mode (Local Mode)

---

## 🍎 APP STORE SUBMISSION CHECKLIST

### ✅ Ready
- [x] App icon (1024×1024)
- [x] Info.plist with all required keys
- [x] `ITSAppUsesNonExemptEncryption = false`
- [x] PrivacyInfo.xcprivacy (no tracking, no data collection)
- [x] 19 document type registrations
- [x] Multi-window support (Stage Manager)
- [x] All 4 iPad orientations
- [x] `UIRequiresFullScreen = false`
- [x] App Store metadata document (APPSTORE_METADATA.md)

### ⚠️ Needs Fixing Before Submission
- [ ] **Bundle ID mismatch:** Xcode says `com.vscodeipad.VSCodeiPadOS`, metadata says `com.codepad.ios` — pick one
- [ ] **Duplicate files:** Two `SceneDelegate.swift`, two `RemoteExplorerView.swift`, two `PythonRunner.swift` — remove duplicates
- [ ] **PrivacyInfo.xcprivacy:** Add `NSPrivacyAccessedAPICategoryDiskSpace` (app reads/writes files extensively)
- [ ] **Remove fake Extensions marketplace** or clearly label as "Built-in Features" — App Store reviewers will test it
- [ ] **MLX dependency size:** On-device LLM adds significant binary size. Consider making it opt-in or removing for v1.0
- [ ] **App Store screenshots:** Need 6+ iPad screenshots (12.9" and 11")
- [ ] **No onboarding flow:** First-run experience needed
- [ ] **App Review Notes:** Must explain code editor nature, reference Guideline 2.5.2 educational carve-out

### 🔴 App Store Rejection Risks
1. **Fake Extensions panel** — Could be seen as misleading functionality
2. **MLX model downloads** — Downloading ML models at runtime could trigger 2.5.2 concerns
3. **"VS Code" in any user-facing text** — Trademark issue. We're "CodePad", not VS Code
4. **Terminal executing code** — If the JS runner is discoverable, ensure all code is viewable/editable per 2.5.2

---

## 📋 PRIORITY ROADMAP

### Phase 1: App Store Submission (2-3 weeks)
**Goal:** Ship a polished v1.0 that passes App Store review

| # | Task | Effort | Impact |
|---|------|--------|--------|
| 1 | Remove/rebrand fake Extensions → "Built-in Features" | 2 days | 🔴 Blocks approval |
| 2 | Fix bundle ID, remove duplicate files | 1 day | 🔴 Blocks build |
| 3 | Wire inline AI suggestions to AIManager | 3 days | 🟡 Major feature |
| 4 | Fix ⌘/ to Toggle Line Comment | 1 day | 🟡 Most-used shortcut |
| 5 | Fix keyboard shortcut conflicts (⌘⌥H vs ⌘⌥F) | 1 day | 🟡 UX |
| 6 | Add missing UIKit keyboard fallbacks | 2 days | 🟡 Hardware keyboard |
| 7 | Fix SSH public key auth (NIOSSHPrivateKey) | 2 days | 🟡 Core feature |
| 8 | Add SSH host key verification | 1 day | 🟡 Security |
| 9 | Add PrivacyInfo disk space declaration | 0.5 day | 🔴 Blocks approval |
| 10 | Create App Store screenshots | 1 day | 🔴 Blocks submission |
| 11 | Build onboarding flow | 2 days | 🟡 UX |
| 12 | Polish Connected Mode (tunnel) experience | 2 days | 🟢 Differentiator |
| 13 | App Review Notes document | 0.5 day | 🔴 Blocks approval |

### Phase 2: Post-Launch Quality (4-6 weeks)
**Goal:** Make the core experience solid

| # | Task | Effort | Impact |
|---|------|--------|--------|
| 14 | Implement git clone (HTTPS) | 1 week | 🔴 Critical feature |
| 15 | Implement pack file reading | 1 week | 🔴 Most repos need this |
| 16 | Integrate SwiftTerm for real terminal emulation | 1 week | 🟡 Major quality |
| 17 | Parse .gitignore for file tree + search | 2 days | 🟡 Quality |
| 18 | Implement file watching | 2 days | 🟡 Quality |
| 19 | Add system dark/light mode auto-detection for themes | 1 day | 🟢 Nice touch |
| 20 | Complete missing keyboard shortcuts (⌘D, ⌥↑/↓, etc.) | 3 days | 🟡 Productivity |
| 21 | Git blame/annotate | 3 days | 🟢 Nice to have |
| 22 | Git stash/rebase/cherry-pick (local) | 1 week | 🟢 Power users |

### Phase 3: Intelligence Layer (8-12 weeks)
**Goal:** Bridge the gap from "text editor" to "IDE"

| # | Task | Effort | Impact |
|---|------|--------|--------|
| 23 | LSP client framework | 2 weeks | 🔴 IDE vs editor |
| 24 | Bundle sourcekit-lsp for Swift | 2 weeks | 🟡 Swift devs |
| 25 | AI-powered autocomplete (not just inline) | 1 week | 🟡 Productivity |
| 26 | Real diagnostics from LSP | 1 week | 🟡 Quality |
| 27 | Rename refactoring | 1 week | 🟢 IDE feature |
| 28 | Real extension system (theme/snippet packs) | 3 weeks | 🟡 Ecosystem |
| 29 | DAP (Debug Adapter Protocol) client | 3 weeks | 🟡 Debugging |
| 30 | Custom theme import (.json) | 1 week | 🟢 Customization |

---

## 💬 NOTES FOR THE OTHER SWE

Hey — here's what you need to know:

### Quick Context
- **Xcode project**, pure Swift/SwiftUI, iPadOS only
- **Editor:** Runestone (TreeSitter) — it's good, don't replace it
- **Git:** Custom pure-Swift .git parser — impressive but missing clone and pack files
- **SSH:** SwiftNIO SSH — real but pubkey auth is broken (line 213 of SSHManager.swift)
- **Terminal:** Fake local, real SSH — needs SwiftTerm integration
- **AI:** 10 providers, 30+ models, tool calling works — inline suggestions are stubbed
- **Tunnel:** WKWebView → code-server/vscode.dev — already works, needs polish

### Architecture Decisions Made
1. **Dual-mode app** (Local native + Connected WebView) — this is the strategy
2. **No redistribution of VS Code Server** — user provides their own URL
3. **code-server (MIT)** is the recommended self-hosted option
4. **Extensions panel will be rebranded** from fake marketplace to honest "Built-in Features"
5. **SwiftTerm** will replace custom terminal rendering
6. **libgit2/SwiftGit2** is the recommended path for git clone + pack files

### Files You'll Touch Most
- `Services/EditorCore.swift` (1,979 lines) — the brain, touches everything
- `Services/SSHManager.swift` (996 lines) — SSH, needs pubkey fix
- `Services/GitManager.swift` (1,027 lines) — git orchestrator
- `Services/NativeGit/NativeGitReader.swift` (805 lines) — needs pack file support
- `Views/Panels/TerminalView.swift` (1,905 lines) — needs SwiftTerm
- `Services/InlineSuggestionManager.swift` (607 lines) — wire to AIManager
- `Services/ExtensionManager.swift` (488 lines) — rebrand or gut
- `Views/KeyCommandBridge.swift` — keyboard shortcut fixes
- `App/VSCodeiPadOSApp.swift` (300 lines) — shortcut menu definitions

### Build & Run
```bash
# Open in Xcode
open VSCodeiPadOS/VSCodeiPadOS.xcodeproj
# Build for iPad Simulator (iPadOS 15+)
# Device family: iPad only
# Dependencies resolve via SPM (swift-nio-ssh, Runestone, TreeSitterLanguages)
```

### Communication
I'm available via the codebase. Leave TODOs, create issues, or just edit. The scout reports are cached in `.claudefluff/agents/` with full transcripts of every file I've read.

---

## 📊 FEATURE COMPARISON: CodePad vs Competition

| Feature | CodePad | Textastic | Buffer Editor | Codespaces (Web) |
|---------|---------|-----------|---------------|------------------|
| Syntax highlighting | ✅ 8 langs (TreeSitter) | ✅ 80+ langs | ✅ 60+ langs | ✅ All |
| Themes | ✅ 20 themes | ✅ 3 themes | ⚠️ 2 themes | ✅ All |
| Git integration | ✅ Native | ❌ None | ✅ Full | ✅ Full |
| SSH/SFTP | ✅ SwiftNIO | ✅ | ✅ | N/A |
| Terminal | ⚠️ Simulated | ❌ None | ✅ SSH term | ✅ Full |
| AI assistant | ✅ 10 providers | ❌ None | ❌ None | ✅ Copilot |
| Multi-cursor | ✅ | ❌ | ❌ | ✅ |
| Split editor | ✅ | ✅ | ❌ | ✅ |
| Command palette | ✅ | ❌ | ❌ | ✅ |
| Extensions | ❌ Fake | ❌ | ❌ | ✅ |
| Debugger | ⚠️ Simulated | ❌ | ❌ | ✅ |
| IntelliSense/LSP | ❌ | ❌ | ❌ | ✅ |
| Connected mode | ✅ (WebView) | ❌ | ❌ | N/A |
| On-device AI | ✅ MLX | ❌ | ❌ | ❌ |
| Price | TBD | $9.99 | $4.99 | Free (with GH) |
| Offline editing | ✅ | ✅ | ✅ | ❌ |

**Our differentiators:** AI (10 providers + on-device), Connected Mode (bridges to full VS Code), native Git, multi-cursor, 20 themes, Command Palette. No other iPad code editor has AI or VS Code tunnel support.

---

## 🎯 BOTTOM LINE

**Can we ship to the App Store?** Yes, with ~2-3 weeks of cleanup (Phase 1).

**Will it be a "full VS Code app"?** No — and it shouldn't try to be on the native side. The strategy is:
1. **Local Mode:** Best-in-class native code editor for iPad with AI superpowers
2. **Connected Mode:** Full VS Code experience via WebView tunnel
3. **Together:** The only app that gives you both offline native editing AND full VS Code when connected

This is a better story than trying to reimplement all of VS Code natively (which would take years and never reach parity). Ship the native editor for fast local work + AI, and let Connected Mode handle the heavy lifting (extensions, debugger, terminal, LSP).

**The honest pitch:** "CodePad: A native code editor for iPad with AI assistance. Connect to VS Code Server for the full IDE experience."
