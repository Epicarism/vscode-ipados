# On‑Device Execution Research (iOS/iPadOS)

> **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.
>
> This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.

## Table of contents

1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)
2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)
3. [Why Python can’t run “natively” (policy + platform constraints)](#why-python-cant-run-natively-policy--platform-constraints)
4. [Lua interpreter options](#lua-interpreter-options)
5. [Security sandbox restrictions](#security-sandbox-restrictions)
6. [What is possible on-device vs what requires remote execution](#what-is-possible-on-device-vs-what-requires-remote-execution)
7. [References](#references)

---

## JavaScriptCore (JSC) on iOS: capabilities & limitations

### What JSC is good for

- Embedding a JS VM (`JavaScriptCore.framework`) for:
  - User scripting / automation (macros, editor actions)
  - Light business logic, parsing, formatting
  - Rule engines / expression evaluation
  - Safe-ish plugin logic when paired with a **strict native bridge**

### Key limitations (important for “VS Code on iPad”)

1. **No browser APIs**
   - JSC is *not* a web runtime: no DOM, no `fetch`, no `XMLHttpRequest`, no WebSocket.
   - Any filesystem/network/device capability must be explicitly bridged from Swift/Obj‑C.

2. **JIT is not available to normal App Store apps**
   - iOS enforces W^X + code-signing constraints. Third-party apps generally cannot use JIT without special entitlements.
   - Consequence: CPU-heavy JS workloads can be much slower than on macOS.

3. **No native module loading / package ecosystem like Node**
   - There’s no `require('fs')` or `npm` environment.
   - ES module support in embedded JSC is not “turnkey”; apps typically implement their own module loader.

4. **Resource exhaustion is on you**
   - There is no built-in watchdog timeout; infinite loops can hang a thread.
   - You must implement your own timeouts / cancellation and memory pressure handling.

### Practical recommendation

Use JSC for:
- small, sandboxed scripting surfaces
- deterministic, user-visible automation

Avoid JSC for:
- running “real” language servers, compilers, large package ecosystems, or heavy compute

---

## WebAssembly (Wasm) runtime options

Wasm can be attractive as a portable, sandboxed compute layer. On iOS, what matters is: **where is your Wasm engine hosted** (WebView vs embedded runtime), and **what capabilities you import**.

### Option A: `WKWebView` WebAssembly

- Safari/WebKit supports WebAssembly, and `WKWebView` is the most common path if you’re already building a web-based execution environment.
- Trade-offs:
  - Wasm still has **no OS access by default** (no files/network) unless you bridge those from native.
  - Background execution and long-running compute are constrained by iOS app lifecycle rules.

### Option B: JavaScriptCore’s `WebAssembly` global (availability varies)

Depending on iOS/WebKit version and configuration, `WebAssembly` may be missing/disabled in JavaScriptCore contexts.

Evidence of availability pitfalls:
- A StackOverflow report shows `WebAssembly` not being defined in JavaScriptCore and `WKWebView` in an iOS 12.4 simulator test (historical but highlights that “it’s there everywhere” is not safe to assume):
  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc
- Wasmer’s JavaScriptCore backend post explicitly states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x.”**
  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore

**Recommendation:** treat “Wasm via JSC” as **not a dependable product requirement** unless you validate it on the exact iOS versions you target.

### Option C: Embed a standalone Wasm runtime (no WebView)

If you need Wasm without WebView, embed a runtime that works without JIT.

Common choices:

- **wasm3** (interpreter)
  - The wasm3 README explicitly calls out that on platforms like **iOS** “you can’t generate executable code pages in runtime, so JIT is unavailable.”
  - Source: https://github.com/wasm3/wasm3

- **WAMR (WebAssembly Micro Runtime)**
  - Common embedded runtime; typically configured as interpreter/AOT depending on platform needs.

- **Wasmer (interpreted backends)**
  - Wasmer is multi-backend; its JSC backend is strong on macOS but iOS has had JSC Wasm availability issues (see Wasmer blog above).

#### WASI considerations on iOS

WASI expects OS-like primitives (files, clocks, random, args/env). On iOS, you generally implement these by:
- mapping “filesystem” to the app container (Documents/Library/tmp) or an in-memory FS
- mapping networking to `URLSession` or a tightly controlled socket layer

This can work well, but you must keep the import surface minimal and audited.

---

## Why Python can’t run “natively” (policy + platform constraints)

The most important blocker is **App Store policy around executing downloaded code and changing app behavior post‑review**, plus iOS platform constraints that make “desktop Python” expectations unrealistic.

### App Store policy: Guideline 2.5.2

Apple’s App Review Guideline **2.5.2** states:

> “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they **download, install, or execute code which introduces or changes features or functionality of the app**, including other apps.”

It also provides a narrow exception:

> “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”

Source:
- https://developer.apple.com/app-store/review/guidelines/#software-requirements

**Implication for VSCodeiPadOS:**
- Shipping a general-purpose Python environment (interpreter + package installation + arbitrary code execution as a product feature) can be interpreted as enabling new functionality post‑review.
- If you want “Python on iPad”, the App Store-compliant route is usually:
  - keep it tightly scoped (often educational),
  - keep code visible/editable, and
  - avoid anything resembling “install arbitrary native capabilities.”

### Platform constraints (even if policy were satisfied)

Even with an embedded interpreter:
- iOS sandboxing blocks typical toolchain patterns (no general subprocess model like desktop, no arbitrary exec of downloaded binaries).
- Dynamic native extensions (typical `pip` wheels) are problematic in App Store constraints.
- JIT-based Python runtimes (e.g., PyPy JIT) are not generally viable in App Store apps due to iOS code execution restrictions.

### Practical recommendation

For VS Code-class workflows (toolchains, LSP servers, builds, Python packages):
- do **remote execution** (SSH / remote compute service)
- keep on-device scripting to languages designed to be embedded (JS/Lua) or sandboxed compute (Wasm)

---

## Lua interpreter options

Lua is a strong candidate for on-device scripting because it’s small, embeddable, and easy to sandbox.

### Option A: Standard PUC-Lua (recommended)

- Embed Lua 5.4/5.3 as a library.
- Provide a minimal standard library surface.
- Expose only whitelisted host functions (filesystem, settings, editor APIs).

Good for:
- macros
- editor automation
- lightweight “extensions” that are user-visible and easy to audit

### Option B: LuaJIT (usually not viable)

- LuaJIT’s main advantage depends on JIT compilation.
- On iOS, third-party JIT is generally not available without special entitlements.

### Option C: Lua on top of JS/Wasm

- Lua VM written in JS (e.g., Fengari) can run in JSC.
- Lua VM compiled to Wasm can run in an embedded Wasm runtime.

Trade-off: simpler packaging/sandboxing at the cost of performance.

---

## Security sandbox restrictions

Everything (JSC/Wasm/Lua) runs under the iOS app sandbox.

### Filesystem

- Read/write: app container only (Documents/Library/tmp)
- No access to system directories (e.g. `/System`, `/etc`) and no direct access to other apps’ containers.

Project reference:
- `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md` describes the container layout and access restrictions.

### Network

- Networking is allowed but controlled:
  - App Transport Security (ATS) rules apply (HTTPS-by-default)
  - local network access requires the appropriate privacy usage description

Project reference:
- `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md` (ATS + network attack vectors)

### Code execution model

- iOS uses code-signing and W^X style restrictions; you cannot generally allocate memory that is both writable and executable in a normal App Store app.
- This drives design choices:
  - avoid JIT runtimes
  - prefer interpreters or AOT where feasible

---

## What is possible on-device vs what requires remote execution

### On-device (realistic / App Store-friendly)

| Goal | Viable approach |
|---|---|
| User scripting & automation | JavaScriptCore + strict native bridge, or embedded Lua |
| Sandboxed compute modules | Embedded Wasm runtime (e.g., wasm3/WAMR) with minimal imports |
| Workspace file operations | Native Swift file APIs constrained to app container, bridged into runtime |
| Networking for scripts/plugins | Native `URLSession` bridged into runtime (ATS compliant) |
| Simple formatters / linters written in JS/Lua | Run on-device, enforce timeouts + memory limits |

### Remote execution (often required for “real dev environment”)

| Goal | Why remote is needed |
|---|---|
| Full Python/Node toolchains, `pip`/`npm`, native deps | Platform sandbox + policy constraints; native extensions/subprocess expectations |
| Language servers (LSP) for large ecosystems | Process model + memory footprint + filesystem scanning; better on remote host |
| Compilers/build systems (Rust/Go/C++ toolchains) | Not feasible to ship/execute full toolchains on iOS as in desktop environments |
| Running arbitrary binaries | iOS app sandbox doesn’t support executing arbitrary downloaded programs |

### Recommended remote path for this project

Use SSH to a dev machine/container and treat iPad as the IDE client.

Project reference:
- `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md` documents SwiftNIO SSH integration for terminal-style remote execution.

---

## References

- Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception)
  - https://developer.apple.com/app-store/review/guidelines/#software-requirements
- Wasmer blog (notes iOS JSC WebAssembly disabled on iOS 16.4.x)
  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore
- wasm3 README (iOS can’t generate executable code pages at runtime; interpreter rationale)
  - https://github.com/wasm3/wasm3
- StackOverflow thread on Wasm in JSC/WKWebView (availability pitfalls)
  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc
