# 🧪 Experiments & Research to Review

These are experimental features, prototypes, and research documents you should review to decide what to keep, finish, or delete.

---

## 📁 On-Device Code Execution

**Location:** `Services/OnDevice/`

**What it is:** Attempt to run code locally on iPad without a server.

| File | Purpose | Status |
|------|---------|--------|
| `JSRunner.swift` | Run JavaScript via JavaScriptCore | 🟡 Partial - works but limited |
| `WASMRunner.swift` | Run WebAssembly (Python?) | 🔴 Experimental |
| `PythonRunner.swift` | Python via Pyodide WASM | 🔴 Experimental |
| `RunnerSelector.swift` | Choose right runner for file type | 🟡 Works |
| `JSRunnerTests.swift` | Tests for JS runner | ✅ Has tests |
| `WASMRunnerTests.swift` | Tests for WASM runner | ✅ Has tests |

**Research docs:**
- `Docs/OnDeviceResearch.md` (899 lines) - Comprehensive JSC research
- `Docs/OnDeviceTesting.md` (928 lines) - Testing strategy
- `Docs/SecurityAudit.md` (508 lines) - Security considerations

**Decision needed:**
- [ ] Review JSRunner capabilities - is it useful?
- [ ] Decide if WASM Python is worth pursuing
- [ ] Security review before enabling in production

---

## 📁 Native Git Implementation

**Location:** `Services/NativeGit/`

**What it is:** Pure Swift git implementation that reads `.git` directories without libgit2.

| File | Lines | Status |
|------|-------|--------|
| `NativeGitReader.swift` | 805 | ✅ Works - reads git repos |
| `NativeGitWriter.swift` | 329 | 🟡 Implemented, not wired |
| `SSHGitClient.swift` | 452 | 🔴 Stub - needs SSH |

**Research docs:**
- `Docs/GITFUTURE.md` (802 lines) - Detailed roadmap

**Decision needed:**
- [ ] Wire NativeGitWriter to enable local commits
- [ ] Decide on SSH library for remote operations
- [ ] Test with real repos (pack files not supported)

---

## 📁 LSP (Language Server Protocol)

**Location:** Various files

**What it is:** Attempt to add IDE features via LSP servers.

| File | Purpose | Status |
|------|---------|--------|
| `Services/LSPService.swift` | LSP client | 🔴 Stub/Incomplete |
| `Views/Editor/HoverInfoView.swift` | Show hover info | 🔴 UI only |
| `Views/Editor/InlayHintsOverlay.swift` | Show inlay hints | 🔴 UI only |
| `Views/Editor/PeekDefinitionView.swift` | Go to definition | 🔴 UI only |
| `Services/HoverInfoManager.swift` | Manage hover | 🔴 Stub |
| `Services/InlayHintsManager.swift` | Manage hints | 🔴 Stub |

**Decision needed:**
- [ ] Is LSP realistic on iOS? (Need to run servers somewhere)
- [ ] Keep UI for future? Or delete as dead code?
- [ ] Consider: LSP over SSH to remote server?

---

## 📁 AI Integration

**Location:** `Services/AIManager.swift`, `Views/Panels/AIAssistantView.swift`

**What it is:** AI coding assistant panel.

| File | Status |
|------|--------|
| `AIManager.swift` | 🟡 Exists, backend unclear |
| `AIAssistantView.swift` | ✅ UI works |
| `InlineSuggestionView.swift` | 🔴 UI only |

**Decision needed:**
- [ ] What AI backend to use? (OpenAI, local, etc.)
- [ ] Is inline suggestions worth implementing?
- [ ] API key management

---

## 📁 Remote Execution

**Location:** `Services/RemoteExecutionService.swift`

**What it is:** Run code on a remote server via SSH.

**Status:** 🔴 Stub - depends on SSHManager

**Decision needed:**
- [ ] Implement after SSH is working
- [ ] Design: How to handle output streaming?
- [ ] Security: Sandboxing remote execution?

---

## 📁 Markdown Preview

**Location:** `Views/Editor/EditorSplitView.swift` (maybe)

**What it is:** Side-by-side markdown editing and preview.

**Status:** 🟡 Unclear if wired up

**Decision needed:**
- [ ] Check if EditorSplitView is used
- [ ] Test markdown preview functionality
- [ ] Keep or remove?

---

## 📁 Debug/Run Features

**Location:** `Services/DebugManager.swift`, `Services/LaunchManager.swift`

**What it is:** Running and debugging code.

| File | Status |
|------|--------|
| `DebugManager.swift` | 🟡 Partial implementation |
| `LaunchManager.swift` | 🟡 Partial implementation |
| `OutputPanelView.swift` | ✅ UI works |

**Decision needed:**
- [ ] What can actually be debugged on iOS?
- [ ] Wire to on-device runners?
- [ ] Remote debugging over SSH?

---

## 📚 Documentation to Read

### Must Read:
1. `Docs/GITFUTURE.md` - Git implementation roadmap
2. `Docs/OnDeviceResearch.md` - JSC capabilities and limits
3. `Docs/SecurityAudit.md` - Security considerations
4. `bugs.md` - 3 critical unfixed bugs!

### Optional:
- `Docs/OnDeviceTesting.md` - Testing methodology
- `Docs/SSH_SETUP.md` - SSH configuration guide
- `Docs/MacServerSetup.md` - Mac as dev server

---

## 🗑️ Likely Delete (After Review)

| Item | Reason |
|------|--------|
| `.garbage/` folder | Old code backups |
| `LSPService.swift` | Never implemented |
| Hover/InlayHints views | Dead UI without backend |
| Multiple `.bak` files | See FILES_TO_DELETE.md |

---

## ✅ Likely Keep

| Item | Reason |
|------|--------|
| NativeGitReader | Works, valuable |
| JSRunner | Works, useful for quick scripts |
| AIAssistantView | UI complete |
| All core editor code | Working |
