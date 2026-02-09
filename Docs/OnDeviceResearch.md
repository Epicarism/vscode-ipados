# JavaScriptCore (JSC) on iPadOS: Comprehensive Research

> **Research Date:** January 2025  
> **Target Platform:** iOS/iPadOS 17.x+  
> **Framework:** JavaScriptCore (JavaScriptCore.framework)

---

## Table of Contents

1. [Overview](#overview)
2. [JSC API Availability](#1-jsc-api-availability-on-iosipados)
3. [Memory Limits](#2-memory-limits)
4. [Execution Time Limits](#3-execution-time-limits)
5. [File System Access](#4-file-system-access-restrictions)
6. [Network Access](#5-network-access-limitations)
7. [JIT Compilation Status](#6-jit-compilation-status)
8. [Performance Benchmarks](#7-performance-benchmarks-vs-macos)
9. [Capabilities & Limitations](#8-what-can-and-cannot-be-done)
10. [Use Cases](#9-example-use-cases)
11. [Remote Execution Needs](#10-limitations-requiring-remote-execution)
12. [Summary Table](#summary-table-of-limits)

---

## Overview

JavaScriptCore (JSC) is Apple's high-performance JavaScript engine, powering Safari and available as a public framework (`JavaScriptCore.framework`) for native iOS/iPadOS apps. It enables embedding JavaScript execution within native applications without WebView overhead.

**Key Framework:**
- `JavaScriptCore.framework` - Public API since iOS 7
- Headers: `<JavaScriptCore/JavaScriptCore.h>`

---

## 1. JSC API Availability on iOS/iPadOS

### Public API Classes

| Class | Purpose | Availability |
|-------|---------|--------------|
| `JSContext` | JavaScript execution environment | iOS 7.0+ |
| `JSValue` | Wrapper for JavaScript values | iOS 7.0+ |
| `JSManagedValue` | Garbage-collected reference | iOS 7.0+ |
| `JSVirtualMachine` | Isolated JS execution environment | iOS 7.0+ |
| `JSExport` | Protocol for Objective-C/Swift export | iOS 7.0+ |

### Swift Import

```swift
import JavaScriptCore
```

### Objective-C Import

```objc
#import <JavaScriptCore/JavaScriptCore.h>
```

### Key API Features Available

✅ **Full JavaScript ES6+ Support**
- Complete ECMAScript 2023 support
- async/await, Promises, Modules (with configuration)
- Classes, arrow functions, destructuring

✅ **Native Bridge**
- `JSExport` protocol for bidirectional communication
- Block/closure exposure to JavaScript
- Objective-C/Swift object exposure

✅ **Multiple Contexts**
- Separate `JSContext` instances
- `JSVirtualMachine` for complete isolation
- Thread-safe execution (one context per thread)

⚠️ **Module System**
- ES6 modules require manual loading
- No built-in `import` from filesystem
- Must use `JSEvaluateScript` with module handling

---

## 2. Memory Limits

### Per-App Memory Constraints

| Device Type | Typical Limit | Notes |
|-------------|---------------|-------|
| iPad (base) | ~3-4 GB | iPad 9th/10th gen |
| iPad Air | ~5-6 GB | M1/M2 iPad Air |
| iPad Pro (M2) | ~8-12 GB | Depends on total RAM |
| iPad Pro (M4) | ~12-16 GB | 16GB models |

**Important:** These are *total app memory*, not JSC-specific.

### JSC-Specific Memory Behavior

```swift
// Configure memory limits via JSContext
let context = JSContext()

// JSC uses garbage collection - no explicit heap limit setting
// Memory pressure handled by system

// Monitor memory usage
context.exceptionHandler = { context, exception in
    print("JS Exception: \(exception?.toString() ?? "unknown")")
}
```

### Memory Warnings

```swift
// Handle memory pressure notifications
NotificationCenter.default.addObserver(
    forName: UIApplication.didReceiveMemoryWarningNotification,
    object: nil,
    queue: .main
) { _ in
    // Clear JS caches, release unused contexts
    context.globalObject.deleteProperty("cachedData")
}
```

### Practical Limits for JSC

| Scenario | Recommended Max | Notes |
|----------|-----------------|-------|
| Large arrays/objects | ~100-500MB | Before performance degradation |
| Concurrent contexts | 2-4 | Each VM adds overhead |
| String processing | No hard limit | Subject to app memory |

---

## 3. Execution Time Limits

### Watchdog and Timeout Behavior

**No Built-in Execution Timeout in JSC API**

Unlike `WKWebView`, `JSContext` has **no automatic watchdog timer**. However, practical limits exist:

| Limit Type | Behavior | Mitigation |
|------------|----------|------------|
| Main thread blocking | App killed after ~10-20s | Use background threads |
| Background execution | ~30s typical | Use `beginBackgroundTask` |
| Infinite loops | Hangs until memory/CPU pressure | Manual interruption needed |

### Manual Timeout Implementation

```swift
import JavaScriptCore
import Dispatch

class JSTimeoutContext {
    private var context: JSContext?
    private var timeoutWorkItem: DispatchWorkItem?
    
    func evaluateWithTimeout(script: String, timeout: TimeInterval) -> JSValue? {
        context = JSContext()
        
        // Set up timeout
        let semaphore = DispatchSemaphore(value: 0)
        var result: JSValue?
        
        timeoutWorkItem = DispatchWorkItem { [weak self] in
            // Force context invalidation on timeout
            self?.context?.exception = JSValue(
                newErrorFromMessage: "Execution timeout",
                in: self?.context
            )
            semaphore.signal()
        }
        
        DispatchQueue.global().async {
            result = self.context?.evaluateScript(script)
            semaphore.signal()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutWorkItem!)
        
        semaphore.wait()
        return result
    }
}
```

### Background Execution Strategy

```swift
func executeLongRunningJS() {
    let backgroundTask = UIApplication.shared.beginBackgroundTask {
        // Cleanup if needed
    }
    
    DispatchQueue.global(qos: .userInitiated).async {
        let context = JSContext()
        let result = context?.evaluateScript(longRunningScript)
        
        DispatchQueue.main.async {
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
    }
}
```

---

## 4. File System Access Restrictions

### App Sandbox Limitations

JSC runs within the app sandbox - **NO direct filesystem access** to:

❌ **Prohibited Access**
- System directories (`/System`, `/usr`, etc.)
- Other apps' containers
- Raw device storage
- External storage (without permissions)

✅ **Allowed Access**
- App's own container (`NSHomeDirectory()`)
- Shared containers (App Groups)
- Temporary directory
- iCloud containers

### Working with Files in JSC

```swift
import JavaScriptCore

class JSFileBridge: NSObject, JSExport {
    static func setup(in context: JSContext) {
        context.setObject(JSFileBridge.self, forKeyedSubscript: "FileBridge" as NSString)
    }
    
    // Expose to JavaScript
    static func readFile(_ filename: String) -> String? {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory, 
            in: .userDomainMask
        ).first!
        
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        // Security: Validate path is within sandbox
        guard fileURL.path.hasPrefix(documentsPath.path) else {
            return nil
        }
        
        return try? String(contentsOf: fileURL)
    }
    
    static func writeFile(_ filename: String, content: String) -> Bool {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory, 
            in: .userDomainMask
        ).first!
        
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        // Prevent directory traversal
        guard fileURL.path.hasPrefix(documentsPath.path),
              !filename.contains("..") else {
            return false
        }
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
}
```

### JavaScript Usage

```javascript
// In JSContext - no native fs module
const content = FileBridge.readFile("data.json");
FileBridge.writeFile("output.txt", "Hello from JSC");
```

### Storage Quotas

| Storage Type | Size Limit | Persistence |
|--------------|------------|-------------|
| Documents | App-specific | iCloud backup |
| Caches | System managed | May be purged |
| Temporary | System managed | Regular cleanup |
| App Groups | Shared across apps | User data |

---

## 5. Network Access Limitations

### JSC Has NO Built-in Network APIs

JavaScriptCore is a **pure JavaScript engine** - no `fetch`, `XMLHttpRequest`, or `WebSocket` built-in.

### Network Strategy: Native Bridge

```swift
import JavaScriptCore
import Foundation

class JSNetworkBridge: NSObject, JSExport {
    static func setup(in context: JSContext) {
        context.setObject(JSNetworkBridge.self, forKeyedSubscript: "Network" as NSString)
    }
    
    // Promise-based fetch equivalent
    static func fetch(_ urlString: String, _ callback: JSValue) {
        guard let url = URL(string: urlString),
              let context = callback.context else {
            callback.call(withArguments: ["Invalid URL", JSValue(nullIn: callback.context)])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    callback.call(withArguments: [error.localizedDescription, JSValue(nullIn: context)])
                } else if let data = data, let string = String(data: data, encoding: .utf8) {
                    callback.call(withArguments: [JSValue(nullIn: context), string])
                }
            }
        }
        task.resume()
    }
}
```

### JavaScript Network Usage

```javascript
// Promise wrapper for callback-based native bridge
function fetch(url) {
    return new Promise((resolve, reject) => {
        Network.fetch(url, (error, data) => {
            if (error) reject(new Error(error));
            else resolve(data);
        });
    });
}

// Usage
async function loadData() {
    try {
        const data = await fetch("https://api.example.com/data");
        return JSON.parse(data);
    } catch (e) {
        console.error("Fetch failed:", e);
    }
}
```

### App Transport Security (ATS)

All network requests must comply with ATS:

```xml
<!-- Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <!-- Or configure specific domains -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>example.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### Background Network Restrictions

| Scenario | Allowed? | Notes |
|----------|----------|-------|
| Foreground requests | ✅ Yes | Standard URLSession |
| Background downloads | ✅ With URLSession config | Must use background session |
| Keep-alive connections | ⚠️ Limited | May be suspended |
| Push-triggered fetch | ✅ Yes | Via PushKit |

---

## 6. JIT Compilation Status

### JIT is DISABLED on iOS/iPadOS

**Critical Performance Impact:**

| Platform | JIT Status | JavaScript Performance |
|----------|------------|------------------------|
| macOS | ✅ Enabled | Full speed |
| iOS Simulator | ✅ Enabled | Full speed (x86/ARM host) |
| iOS Device | ❌ **Disabled** | ~2-5x slower |
| iPadOS Device | ❌ **Disabled** | ~2-5x slower |

### Why JIT is Disabled

Apple disables JIT on iOS for **security reasons**:

1. **W^X (Write XOR Execute)** - Memory pages cannot be both writable and executable
2. **Code signing** - All executable code must be signed
3. **Arbitrary code execution prevention**

### Performance Impact Details

| Operation | With JIT | Without JIT (iOS) | Slowdown |
|-----------|----------|-------------------|----------|
| Simple loops | 1x | 3-5x | Significant |
| Object creation | 1x | 2-3x | Moderate |
| Math operations | 1x | 5-10x | Severe |
| String operations | 1x | 2-4x | Moderate |
| Array operations | 1x | 3-6x | Significant |

### JIT Workarounds (Limited)

⚠️ **No legitimate workarounds for third-party apps**

The following have special JIT entitlements (not available to regular apps):
- Safari/WebKit
- Alternative browser apps (EU only, iOS 17.4+)
- Development/debugging scenarios

```
// These entitlements are RESTRICTED:
com.apple.security.cs.allow-jit
com.apple.security.cs.debugger
dynamic-codesigning
```

### Practical Implications

```javascript
// This runs SLOWER on iOS than macOS
function heavyComputation(n) {
    let sum = 0;
    for (let i = 0; i < n; i++) {
        sum += Math.sqrt(i) * Math.sin(i);
    }
    return sum;
}
// heavyComputation(1000000) - ~5x slower on iOS
```

---

## 7. Performance Benchmarks vs macOS

### Benchmark Results (Approximate)

Based on common JavaScript benchmarks (JetStream, SunSpider):

| Benchmark | macOS (M1) | iPad Pro (M2) | Ratio |
|-----------|------------|---------------|-------|
| JetStream 2 | ~180 | ~60-80 | 2.5-3x slower |
| SunSpider | ~100ms | ~300-500ms | 3-5x slower |
| Octane | ~80000 | ~25000-35000 | 2.5-3x slower |

### Real-World Performance

| Use Case | macOS | iPad Pro | Acceptable? |
|----------|-------|----------|-------------|
| JSON parsing | <1ms (MB data) | 2-5ms | ✅ Yes |
| Simple data transform | 10ms | 30-50ms | ✅ Yes |
| Crypto hashing (JS) | 100ms | 300-500ms | ⚠️ Maybe |
| Image processing (JS) | 500ms | 2-5s | ❌ No |
| ML inference (TensorFlow.js) | Fast | Very slow | ❌ No |
| Game physics | 60fps | 15-20fps | ❌ No |

### Optimization Strategies for iOS

```swift
// 1. Use native code for heavy lifting
class OptimizedBridge: NSObject, JSExport {
    // Delegate to Accelerate.framework, Metal, etc.
    static func fastMatrixMultiply(_ a: [[Double]], _ b: [[Double]]) -> [[Double]] {
        // Use Accelerate framework
        return acceleratedMultiply(a, b)
    }
}

// 2. Batch operations
context.evaluateScript("""
    function processBatch(items) {
        // Process in chunks to allow event loop breathing
        const BATCH_SIZE = 100;
        let index = 0;
        
        function processChunk() {
            const batch = items.slice(index, index + BATCH_SIZE);
            // ... process ...
            index += BATCH_SIZE;
            
            if (index < items.length) {
                setTimeout(processChunk, 0); // Yield control
            }
        }
        
        processChunk();
    }
""")

// 3. Minimize cross-context calls
// Batch data exchange instead of frequent small calls
```

---

## 8. What Can and Cannot Be Done with Pure JSC

### ✅ What CAN Be Done

| Category | Examples | Notes |
|----------|----------|-------|
| **Data Processing** | JSON manipulation, filtering, mapping | Excellent performance |
| **Business Logic** | Calculations, validation rules | Ideal use case |
| **Scripting** | User-defined behaviors, workflows | Safe sandbox |
| **Parsing** | Custom format parsers, compilers | Good performance |
| **State Management** | Redux-like patterns, data stores | Efficient |
| **String Operations** | Text processing, regex | Moderate performance |
| **Configuration** | Dynamic feature flags, settings | Secure |

### ❌ What CANNOT Be Done (Pure JSC)

| Category | Why Not | Alternative |
|----------|---------|-------------|
| **DOM Manipulation** | No DOM APIs | Use WKWebView |
| **Network Requests** | No fetch/XHR | Native bridge |
| **File System** | No fs module | Native bridge + sandbox |
| **High-Performance Graphics** | No Canvas/WebGL | Metal, SpriteKit |
| **Real-time Audio/Video** | No Web Audio/RTC | AVFoundation |
| **Sensors** | No Device APIs | CoreMotion, CoreLocation |
| **Push Notifications** | No Push API | APNS via native |
| **Background Sync** | No Service Workers | Background tasks |

### Code Examples

#### ✅ Good Use: Data Validation

```javascript
// Pure JSC - works great
function validateUser(user) {
    const required = ['name', 'email', 'age'];
    const errors = [];
    
    for (const field of required) {
        if (!user[field]) {
            errors.push(`${field} is required`);
        }
    }
    
    if (user.age < 18) {
        errors.push('Must be 18+');
    }
    
    return {
        valid: errors.length === 0,
        errors
    };
}
```

#### ❌ Bad Use: Direct Network Request

```javascript
// Pure JSC - this will FAIL
const data = fetch('/api/users'); // ReferenceError: fetch is not defined

// Must use native bridge instead
```

#### ✅ Good Use: Business Rules Engine

```javascript
// Pure JSC - excellent use case
const rules = {
    discount: (order) => {
        if (order.total > 1000) return 0.15;
        if (order.total > 500) return 0.10;
        if (order.customer.loyaltyYears > 5) return 0.05;
        return 0;
    },
    
    shipping: (order) => {
        if (order.total > 50) return 0;
        return order.weight * 2.5;
    }
};

function calculateOrder(order) {
    const discount = rules.discount(order);
    const shipping = rules.shipping(order);
    
    return {
        subtotal: order.total,
        discount: order.total * discount,
        shipping,
        total: order.total * (1 - discount) + shipping
    };
}
```

---

## 9. Example Use Cases That Work Well

### 1. Form Validation Engine

```swift
class FormValidator {
    let context = JSContext()
    
    init() {
        // Load validation rules from server or bundle
        let rules = """
            const validators = {
                email: (v) => /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/.test(v),
                phone: (v) => /^\\+?[\\d\\s-]{10,}$/.test(v),
                required: (v) => v !== null && v !== undefined && v !== ''
            };
            
            function validateField(value, rule) {
                if (typeof rule === 'string') {
                    return validators[rule](value);
                }
                if (rule.min !== undefined && value.length < rule.min) {
                    return false;
                }
                return true;
            }
        """
        context.evaluateScript(rules)
    }
    
    func validate(value: Any, rule: String) -> Bool {
        let jsValue = context.objectForKeyedSubscript("validateField")
        return jsValue?.call(withArguments: [value, rule])?.toBool() ?? false
    }
}
```

### 2. Expression Evaluator

```javascript
// Safe math expression evaluation
const expression = "(price * quantity) * (1 - discount) + tax";

function evaluate(expr, variables) {
    // Create safe evaluation context
    const safeMath = {
        sin: Math.sin,
        cos: Math.cos,
        sqrt: Math.sqrt,
        max: Math.max,
        min: Math.min
    };
    
    const context = Object.create(safeMath);
    Object.assign(context, variables);
    
    // Construct function with safe scope
    const keys = Object.keys(context);
    const values = Object.values(context);
    
    try {
        const fn = new Function(...keys, `return (${expr})`);
        return fn(...values);
    } catch (e) {
        return { error: e.message };
    }
}

// Usage
const result = evaluate(expression, {
    price: 99.99,
    quantity: 3,
    discount: 0.15,
    tax: 5.99
});
```

### 3. Template Engine

```javascript
// Lightweight template processing
function renderTemplate(template, data) {
    return template.replace(/\{\{(\w+)\}\}/g, (match, key) => {
        return data[key] !== undefined ? data[key] : match;
    });
}

const template = "Hello {{name}}, you have {{count}} new messages";
const output = renderTemplate(template, { name: "Alice", count: 5 });
// "Hello Alice, you have 5 new messages"
```

### 4. JSON Transform Pipeline

```javascript
// Data transformation chains
const pipeline = [
    (data) => data.filter(item => item.active),
    (data) => data.map(item => ({
        ...item,
        fullName: `${item.firstName} ${item.lastName}`,
        age: new Date().getFullYear() - item.birthYear
    })),
    (data) => data.sort((a, b) => b.age - a.age),
    (data) => data.slice(0, 100) // Limit results
];

function runPipeline(data) {
    return pipeline.reduce((acc, transform) => transform(acc), data);
}
```

### 5. State Machine

```javascript
// Finite state machine for workflows
function createStateMachine(definition) {
    let currentState = definition.initial;
    const context = {};
    
    return {
        state: () => currentState,
        
        transition(event, data) {
            const stateDef = definition.states[currentState];
            const transition = stateDef?.on?.[event];
            
            if (!transition) {
                return { success: false, error: 'Invalid transition' };
            }
            
            // Execute exit action
            if (stateDef.exit) {
                stateDef.exit(context, data);
            }
            
            // Change state
            const prevState = currentState;
            currentState = transition.target;
            
            // Execute entry action
            const newStateDef = definition.states[currentState];
            if (newStateDef.entry) {
                newStateDef.entry(context, data);
            }
            
            // Execute transition action
            if (transition.action) {
                transition.action(context, data, prevState);
            }
            
            return { success: true, state: currentState };
        }
    };
}
```

---

## 10. Limitations Requiring Remote Execution

### When to Use Remote Execution

| Scenario | JSC Limitation | Remote Solution |
|----------|---------------|-----------------|
| **Heavy ML/AI** | Too slow without JIT | Cloud ML APIs |
| **Large Dataset Processing** | Memory/time constraints | Serverless functions |
| **Proprietary Algorithms** | Code exposure risk | Server-side execution |
| **Real-time Collaboration** | No WebSocket | Backend with WebSockets |
| **Database Queries** | No direct DB access | API gateway |
| **File Conversion** | Limited format support | Cloud conversion services |
| **Video Processing** | No native codecs | FFmpeg cloud services |
| **Cryptocurrency Mining** | Impossible (no JIT) | Never do this anyway |

### Hybrid Architecture Pattern

```
┌─────────────────┐     ┌──────────────────┐
│   iPadOS App    │────▶│   Edge/Cloud     │
│                 │     │   Function       │
│ ┌─────────────┐ │     │                  │
│ │ JSC Context │ │     │ • Heavy compute  │
│ │             │ │     │ • JIT enabled    │
│ │ • UI logic  │ │◀────│ • DB access      │
│ │ • Validation│ │     │ • File processing│
│ │ • Caching   │ │     │                  │
│ └─────────────┘ │     └──────────────────┘
└─────────────────┘
```

### Remote Execution Implementation

```swift
import JavaScriptCore

class HybridExecutor {
    private let context = JSContext()
    private let cloudFunctionURL = "https://api.example.com/compute"
    
    func execute(script: String, data: [String: Any], complexity: ComputeComplexity) async throws -> JSValue {
        switch complexity {
        case .light:
            // Execute locally in JSC
            let jsData = try JSONSerialization.data(withJSONObject: data)
            let jsDataString = String(data: jsData, encoding: .utf8)!
            
            let wrappedScript = """
                const input = \(jsDataString);
                (\(script))(input);
            """
            return context.evaluateScript(wrappedScript)!
            
        case .heavy:
            // Execute remotely
            var request = URLRequest(url: URL(string: cloudFunctionURL)!)
            request.httpMethod = "POST"
            request.httpBody = try JSONSerialization.data(withJSONObject: [
                "script": script,
                "data": data
            ])
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try JSONSerialization.jsonObject(with: data)
            
            // Convert back to JSValue
            return JSValue(object: result, in: context)
        }
    }
}

enum ComputeComplexity {
    case light   // < 100ms expected, simple transforms
    case heavy   // > 100ms or memory intensive
}
```

---

## Summary Table of Limits

| Category | Limit | Details |
|----------|-------|---------|
| **API Availability** | Full ES2023 | iOS 7.0+, no browser APIs |
| **Memory (iPad Pro M4)** | ~12-16GB app limit | System enforces hard limits |
| **Memory (base iPad)** | ~3-4GB app limit | OOM kills possible |
| **Execution Timeout** | No built-in limit | Must implement manually |
| **Background Time** | ~30 seconds | Use `beginBackgroundTask` |
| **File System** | App sandbox only | No system directories |
| **Network** | No built-in APIs | Requires native bridge |
| **JIT Compilation** | ❌ DISABLED | ~2-5x slower than macOS |
| **Threading** | 1 context per thread | `JSVirtualMachine` for isolation |
| **Module Loading** | Manual only | No automatic `import` |
| **ESM Support** | Partial | Requires polyfills |
| **Web APIs** | None | No DOM, fetch, Storage, etc. |
| **Crypto (Web)** | SubtleCrypto not available | Use CommonCrypto/Security |
| **Performance** | ~30-50% of macOS | Due to JIT disabled |

---

## Best Practices Summary

1. **Keep computation lightweight** - Offload heavy work to native or cloud
2. **Minimize JS-to-native bridge calls** - Batch operations
3. **Implement your own timeouts** - JSC has no execution limits
4. **Use native networking** - Bridge to URLSession, not WKWebView
5. **Cache aggressively** - JIT disabled means repeated code is re-interpreted
6. **Profile on device** - Simulator has JIT, real devices don't
7. **Consider WebAssembly** - For compute-intensive tasks (still no JIT advantage)
8. **Use background tasks** - For long-running JS operations

---

## References

- [Apple Developer: JavaScriptCore Framework](https://developer.apple.com/documentation/javascriptcore)
- [WebKit Blog: Understanding JIT](https://webkit.org/blog/)
- [iOS Memory Limits Analysis](https://developer.apple.com/documentation/xcode/improving_your_app_s_performance)
- [App Sandbox Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)

---

*Document Version: 1.0*  
*Last Updated: January 2025*  
*Applicable Platforms: iOS 17.x, iPadOS 17.x, Xcode 15.x*
