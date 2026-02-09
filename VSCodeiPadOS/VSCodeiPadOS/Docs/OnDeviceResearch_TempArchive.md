# On-device runtime research (iOS/iPadOS)

> **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.
>
> This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.

## Table of contents

1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)
2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)
3. [Why Python can’t run natively (no interpreter allowed)](#why-python-cant-run-natively-no-interpreter-allowed)
4. [Lua interpreter options](#lua-interpreter-options)
5. [Security sandbox restrictions](#security-sandbox-restrictions)
6. [What IS possible vs what requires remote execution](#what-is-possible-vs-what-requires-remote-execution)
7. [References](#references)

---

## JavaScriptCore (JSC) on iOS: capabilities & limitations

### What JSC is good for

JavaScriptCore (`JavaScriptCore.framework`) is a good fit for **embedded, sandboxed scripting**:

- User scripting / automation (macros, editor actions)
- Lightweight formatters, parsers, validators
- Rule engines / expression evaluation
- “Extension-like” logic **if** you expose a minimal, audited native API surface

### Key limitations (important for “VS Code on iPad”)

1. **Not a web runtime (no browser APIs)**
   - No DOM.
   - No `fetch`, `XMLHttpRequest`, `WebSocket`, etc.
   - Networking, filesystem, and device access must be implemented in native code and bridged into JS.

2. **JIT is generally not available to normal App Store apps**
   - iOS code-signing + W^X-style restrictions mean third-party apps typically cannot use JIT without special entitlements.
   - Consequence: CPU-heavy JS workloads can be significantly slower on device than on macOS.

3. **No Node-style module ecosystem**
   - There is no `require('fs')`/`npm` environment.
   - If you want modules, you implement a loader yourself and strictly control what “imports” can do.

4. **Resource exhaustion controls are on you**
   - Embedded JSC does not provide a universal “watchdog” timeout.
   - You must implement timeouts/cancellation and memory-pressure strategies at the host level.

### Practical recommendation

Use JSC for:
- small, user-visible scripting surfaces
- deterministic automation
- running code that can be paused/limited and that doesn’t need full OS/toolchain access

Avoid JSC for:
- language servers and full toolchains
- heavy computation
- anything that relies on a desktop-like process model

---

## WebAssembly (Wasm) runtime options

Wasm is attractive as a portable, sandboxed compute layer. On iOS, the main question is: **where does your Wasm engine live** and **what host functions are you willing to expose**.

### Option A: `WKWebView` WebAssembly (WebKit)

- WebKit in Safari supports WebAssembly, and `WKWebView` can be used to run Wasm in a browser-like JS environment.

Trade-offs:
- Wasm still has **no OS access** by default (no files/network) unless bridged from native.
- Background/long-running compute is constrained by iOS app lifecycle rules.

Good fit if:
- your UI is already WebView-based, or you want a web-style integration surface

### Option B: JavaScriptCore `WebAssembly` global (availability varies)

Whether `WebAssembly` exists inside JavaScriptCore is **not something to assume** across iOS versions.

Observed availability pitfalls:
- A StackOverflow report shows `WebAssembly` missing in JavaScriptCore and `WKWebView` in an iOS 12.4 simulator scenario (historical, but demonstrates variability).
- Wasmer’s JavaScriptCore backend write-up states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x.”**

**Recommendation:** treat “Wasm via JSC” as **not a dependable product requirement** unless you validate it on the exact iOS versions you target.

### Option C: Embed a standalone Wasm runtime (no WebView)

If you need Wasm without WebView, embed a runtime that works without JIT.

Common choices:

- **wasm3 (interpreter)**
  - Explicitly calls out that on platforms like **iOS** “you can’t generate executable code pages in runtime, so JIT is unavailable.”
  - This is aligned with App Store constraints.

- **WAMR (WebAssembly Micro Runtime)**
  - Often used on embedded/mobile; can be configured for interpreter mode.

- **Wasmer (interpreted backends / iOS support varies by backend)**
  - Wasmer supports multiple engines/backends; however, its JSC backend is primarily valuable on macOS, and iOS JSC Wasm availability has been inconsistent.

#### WASI considerations on iOS

WASI expects OS-like primitives (files, clocks, random, args/env). On iOS you generally emulate these via host functions:

- Map “filesystem” to the app container (`Documents/`, `Library/`, `tmp/`) or an in-memory FS.
- Map networking to `URLSession` or a tightly controlled socket layer.

Security note: Wasm’s core sandbox is a strength, but **your imports are your attack surface**. Keep the import set minimal and audited.

---

## Why Python can’t run natively (no interpreter allowed)

For this project, treat **general-purpose Python execution on-device as disallowed**.

There are two reasons—**App Store policy** (the gating issue for distribution) and **platform constraints** (which make “desktop Python” assumptions invalid anyway).

### 1) App Store policy: downloading/executing code that changes app behavior

Apple App Review Guideline **2.5.2** states:

> “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.”

It also includes a narrow exception for some educational use cases:

> “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”

**Implication for VSCodeiPadOS:**
- A bundled Python interpreter (plus package installation, plus arbitrary user code) can be interpreted as a mechanism to add/alter functionality after review.
- Even if you could argue an “educational” exception, that typically requires strict UX constraints (source must be viewable/editable) and still doesn’t solve the rest of the platform limitations below.

### 2) Platform constraints (even if policy were satisfied)

Even embedding CPython in-process doesn’t create a desktop-like environment:

- **No arbitrary process execution model** (you can’t just run downloaded toolchain binaries; the iOS app sandbox does not behave like macOS/Linux).
- **Native extension modules are a problem** (typical `pip` wheels include native code; loading arbitrary native code post-review is a non-starter).
- **No JIT for third-party apps** (relevant to PyPy/JIT and some performance strategies), due to iOS code-signing and W^X-style restrictions.

### Practical decision

- Don’t try to be a self-contained Python workstation on iPad.
- Provide Python (and other toolchains) via **remote execution** (SSH / remote compute).

---

## Lua interpreter options

Lua is a strong candidate for on-device scripting because it’s small, embeddable, and easy to sandbox.

### Option A: Standard PUC-Lua (recommended)

- Embed Lua 5.4/5.3 as a library.
- Provide a minimal standard library surface.
- Expose only whitelisted host functions (editor APIs, limited filesystem, limited networking).

Good for:
- macros
- editor automation
- small user extensions

### Option B: LuaJIT (usually not viable)

- LuaJIT’s performance depends on JIT compilation.
- iOS App Store apps generally cannot use JIT without special entitlements.

### Option C: Lua on top of JS/Wasm (fallback)

- Lua VM written in JS (e.g., Fengari) can run in JSC.
- Lua VM compiled to Wasm can run in an embedded Wasm runtime.

Trade-off: simpler packaging/sandboxing at the cost of performance.

---

## Security sandbox restrictions

Everything (JSC/Wasm/Lua) runs under the iOS app sandbox (“seatbelt” profile).

### Filesystem

- Read/write is limited to the app container:
  - `Documents/` (user data)
  - `Library/` (settings/caches)
  - `tmp/`
- No access to system directories (`/System`, `/etc`, etc.) and no direct access to other apps’ containers.

### Network

- Networking is allowed but controlled:
  - **ATS** (App Transport Security) applies (HTTPS by default)
  - iOS local network privacy requires an appropriate usage description when scanning/connecting to LAN hosts

### “No JIT / no dynamic native code” reality

- iOS’s code-signing model and W^X restrictions strongly constrain any runtime that wants to generate machine code on the fly.
- Design implications:
  - prefer interpreters or AOT approaches
  - keep execution deterministic and limit resource usage
  - avoid designs that depend on spawning processes or loading arbitrary native code

---

## What IS possible vs what requires remote execution

### What IS possible on-device (realistic / App Store-friendly)

| Goal | Viable approach |
|---|---|
| User scripting & automation | JavaScriptCore + strict native bridge, or embedded Lua |
| Sandboxed compute modules | Embedded Wasm runtime (e.g., wasm3/WAMR) with minimal imports |
| Workspace file operations | Native Swift file APIs constrained to app container, bridged into runtime |
| Networking for scripts/plugins | Native `URLSession` bridged into runtime (ATS compliant) |
| Simple formatters/linters written in JS/Lua | Run on-device, enforce timeouts + memory limits |

### What usually requires remote execution

| Goal | Why remote is needed |
|---|---|
| Full Python/Node toolchains, `pip`/`npm`, native deps | Policy + sandbox constraints; native extensions/subprocess expectations |
| Language servers (LSP) for large ecosystems | Process model + memory footprint + filesystem scanning; better on remote host |
| Compilers/build systems (Rust/Go/C++ toolchains) | Not feasible to ship/execute full toolchains on iOS like desktop environments |
| Running arbitrary binaries | iOS sandbox does not support executing arbitrary downloaded programs |

### Recommended remote path for this project

Use SSH to a dev machine/container and treat the iPad as the IDE client.

(See `Docs/SSH_SETUP.md` for the project’s SwiftNIO SSH approach.)

---

## References

- Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception)
  - https://developer.apple.com/app-store/review/guidelines/#software-requirements
- Project security notes (sandbox container layout, ATS, etc.)
  - `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`
- Project remote execution path (SwiftNIO SSH)
  - `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md`
- Wasmer blog (notes iOS JSC WebAssembly disabled on iOS 16.4.x)
  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore
- wasm3 README (iOS can’t generate executable code pages at runtime; interpreter rationale)
  - https://github.com/wasm3/wasm3
- StackOverflow thread on Wasm in JSC/WKWebView (availability pitfalls)
  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc
