# Agent: create-docs-ondevice
**Status:** done
**Tokens:** 42,460
**Cost:** $0.0000
**Time:** 2026-02-09T18:20:20.227Z

## Task
Create VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md covering:
- JavaScriptCore capabilities and limitations on iOS
- WebAssembly runtime options
- Why Python can't run natively (no interpreter allowed)
- Lua interpreter options
- Security sandbox restrictions
- What IS possible vs what requires remote execution

## Response
>>>TOOL list_dir
{"path":"/Users/danielswagg/PLAYGROUND/vscode-ipados"}
>>>END

>>>TOOL list_dir
{}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 ./
📁 .claude/
📁 .claudefluff/
📁 .garbage/
📁 .patch-backups/
📁 .vscode/
📁 Docs/
📁 Extensions/
📁 logs/
📁 Models/
📁 Services/
📁 test-results/
📁 Tests/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOSUITests/
   .gitignore
   build.log
   FULL_FEATURE_TEST_PLAN.md
   LICENSE
   MASTER_AGENT_PLAN.md
   phase1-agents.json
   README.md
(cached)


>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Docs/
   KeyboardShortcuts.md
   OnDeviceResearch.md
   SecurityAudit.md
   SSH_SETUP.md


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md (lines 1-899 of 899)
────────────────────────────────────────
1: # JavaScriptCore (JSC) on iPadOS: Comprehensive Research
2: 
3: > **Research Date:** January 2025  
4: > **Target Platform:** iOS/iPadOS 17.x+  
5: > **Framework:** JavaScriptCore (JavaScriptCore.framework)
6: 
7: ---
8: 
9: ## Table of Contents
10: 
11: 1. [Overview](#overview)
12: 2. [JSC API Availability](#1-jsc-api-availability-on-iosipados)
13: 3. [Memory Limits](#2-memory-limits)
14: 4. [Execution Time Limits](#3-execution-time-limits)
15: 5. [File System Access](#4-file-system-access-restrictions)
16: 6. [Network Access](#5-network-access-limitations)
17: 7. [JIT Compilation Status](#6-jit-compilation-status)
18: 8. [Performance Benchmarks](#7-performance-benchmarks-vs-macos)
19: 9. [Capabilities & Limitations](#8-what-can-and-cannot-be-done)
20: 10. [Use Cases](#9-example-use-cases)
21: 11. [Remote Execution Needs](#10-limitations-requiring-remote-execution)
22: 12. [Summary Table](#summary-table-of-limits)
23: 
24: ---
25: 
26: ## Overview
27: 
28: JavaScriptCore (JSC) is Apple's high-performance JavaScript engine, powering Safari and available as a public framework (`JavaScriptCore.framework`) for native iOS/iPadOS apps. It enables embedding JavaScript execution within native applications without WebView overhead.
29: 
30: **Key Framework:**
31: - `JavaScriptCore.framework` - Public API since iOS 7
32: - Headers: `<JavaScriptCore/JavaScriptCore.h>`
33: 
34: ---
35: 
36: ## 1. JSC API Availability on iOS/iPadOS
37: 
38: ### Public API Classes
39: 
40: | Class | Purpose | Availability |
41: |-------|---------|--------------|
42: | `JSContext` | JavaScript execution environment | iOS 7.0+ |
43: | `JSValue` | Wrapper for JavaScript values | iOS 7.0+ |
44: | `JSManagedValue` | Garbage-collected reference | iOS 7.0+ |
45: | `JSVirtualMachine` | Isolated JS execution environment | iOS 7.0+ |
46: | `JSExport` | Protocol for Objective-C/Swift export | iOS 7.0+ |
47: 
48: ### Swift Import
49: 
50: ```swift
51: import JavaScriptCore
52: ```
53: 
54: ### Objective-C Import
55: 
56: ```objc
57: #import <JavaScriptCore/JavaScriptCore.h>
58: ```
59: 
60: ### Key API Features Available
61: 
62: ✅ **Full JavaScript ES6+ Support**
63: - Complete ECMAScript 2023 support
64: - async/await, Promises, Modules (with configuration)
65: - Classes, arrow functions, destructuring
66: 
67: ✅ **Native Bridge**
68: - `JSExport` protocol for bidirectional communication
69: - Block/closure exposure to JavaScript
70: - Objective-C/Swift object exposure
71: 
72: ✅ **Multiple Contexts**
73: - Separate `JSContext` instances
74: - `JSVirtualMachine` for complete isolation
75: - Thread-safe execution (one context per thread)
76: 
77: ⚠️ **Module System**
78: - ES6 modules require manual loading
79: - No built-in `import` from filesystem
80: - Must use `JSEvaluateScript` with module handling
81: 
82: ---
83: 
84: ## 2. Memory Limits
85: 
86: ### Per-App Memory Constraints
87: 
88: | Device Type | Typical Limit | Notes |
89: |-------------|---------------|-------|
90: | iPad (base) | ~3-4 GB | iPad 9th/10th gen |
91: | iPad Air | ~5-6 GB | M1/M2 iPad Air |
92: | iPad Pro (M2) | ~8-12 GB | Depends on total RAM |
93: | iPad Pro (M4) | ~12-16 GB | 16GB models |
94: 
95: **Important:** These are *total app memory*, not JSC-specific.
96: 
97: ### JSC-Specific Memory Behavior
98: 
99: ```swift
100: // Configure memory limits via JSContext
101: let context = JSContext()
102: 
103: // JSC uses garbage collection - no explicit heap limit setting
104: // Memory pressure handled by system
105: 
106: // Monitor memory usage
107: context.exceptionHandler = { context, exception in
108:     print("JS Exception: \(exception?.toString() ?? "unknown")")
109: }
110: ```
111: 
112: ### Memory Warnings
113: 
114: ```swift
115: // Handle memory pressure notifications
116: NotificationCenter.default.addObserver(
117:     forName: UIApplication.didReceiveMemoryWarningNotification,
118:     object: nil,
119:     queue: .main
120: ) { _ in
121:     // Clear JS caches, release unused contexts
122:     context.globalObject.deleteProperty("cachedData")
123: }
124: ```
125: 
126: ### Practical Limits for JSC
127: 
128: | Scenario | Recommended Max | Notes |
129: |----------|-----------------|-------|
130: | Large arrays/objects | ~100-500MB | Before performance degradation |
131: | Concurrent contexts | 2-4 | Each VM adds overhead |
132: | String processing | No hard limit | Subject to app memory |
133: 
134: ---
135: 
136: ## 3. Execution Time Limits
137: 
138: ### Watchdog and Timeout Behavior
139: 
140: **No Built-in Execution Timeout in JSC API**
141: 
142: Unlike `WKWebView`, `JSContext` has **no automatic watchdog timer**. However, practical limits exist:
143: 
144: | Limit Type | Behavior | Mitigation |
145: |------------|----------|------------|
146: | Main thread blocking | App killed after ~10-20s | Use background threads |
147: | Background execution | ~30s typical | Use `beginBackgroundTask` |
148: | Infinite loops | Hangs until memory/CPU pressure | Manual interruption needed |
149: 
150: ### Manual Timeout Implementation
151: 
152: ```swift
153: import JavaScriptCore
154: import Dispatch
155: 
156: class JSTimeoutContext {
157:     private var context: JSContext?
158:     private var timeoutWorkItem: DispatchWorkItem?
159:     
160:     func evaluateWithTimeout(script: String, timeout: TimeInterval) -> JSValue? {
161:         context = JSContext()
162:         
163:         // Set up timeout
164:         let semaphore = DispatchSemaphore(value: 0)
165:         var result: JSValue?
166:         
167:         timeoutWorkItem = DispatchWorkItem { [weak self] in
168:             // Force context invalidation on timeout
169:             self?.context?.exception = JSValue(
170:                 newErrorFromMessage: "Execution timeout",
171:                 in: self?.context
172:             )
173:             semaphore.signal()
174:         }
175:         
176:         DispatchQueue.global().async {
177:             result = self.context?.evaluateScript(script)
178:             semaphore.signal()
179:         }
180:         
181:         DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutWorkItem!)
182:         
183:         semaphore.wait()
184:         return result
185:     }
186: }
187: ```
188: 
189: ### Background Execution Strategy
190: 
191: ```swift
192: func executeLongRunningJS() {
193:     let backgroundTask = UIApplication.shared.beginBackgroundTask {
194:         // Cleanup if needed
195:     }
196:     
197:     DispatchQueue.global(qos: .userInitiated).async {
198:         let context = JSContext()
199:         let result = context?.evaluateScript(longRunningScript)
200:         
201:         DispatchQueue.main.async {
202:             UIApplication.shared.endBackgroundTask(backgroundTask)
203:         }
204:     }
205: }
206: ```
207: 
208: ---
209: 
210: ## 4. File System Access Restrictions
211: 
212: ### App Sandbox Limitations
213: 
214: JSC runs within the app sandbox - **NO direct filesystem access** to:
215: 
216: ❌ **Prohibited Access**
217: - System directories (`/System`, `/usr`, etc.)
218: - Other apps' containers
219: - Raw device storage
220: - External storage (without permissions)
221: 
222: ✅ **Allowed Access**
223: - App's own container (`NSHomeDirectory()`)
224: - Shared containers (App Groups)
225: - Temporary directory
226: - iCloud containers
227: 
228: ### Working with Files in JSC
229: 
230: ```swift
231: import JavaScriptCore
232: 
233: class JSFileBridge: NSObject, JSExport {
234:     static func setup(in context: JSContext) {
235:         context.setObject(JSFileBridge.self, forKeyedSubscript: "FileBridge" as NSString)
236:     }
237:     
238:     // Expose to JavaScript
239:     static func readFile(_ filename: String) -> String? {
240:         let documentsPath = FileManager.default.urls(
241:             for: .documentDirectory, 
242:             in: .userDomainMask
243:         ).first!
244:         
245:         let fileURL = documentsPath.appendingPathComponent(filename)
246:         
247:         // Security: Validate path is within sandbox
248:         guard fileURL.path.hasPrefix(documentsPath.path) else {
249:             return nil
250:         }
251:         
252:         return try? String(contentsOf: fileURL)
253:     }
254:     
255:     static func writeFile(_ filename: String, content: String) -> Bool {
256:         let documentsPath = FileManager.default.urls(
257:             for: .documentDirectory, 
258:             in: .userDomainMask
259:         ).first!
260:         
261:         let fileURL = documentsPath.appendingPathComponent(filename)
262:         
263:         // Prevent directory traversal
264:         guard fileURL.path.hasPrefix(documentsPath.path),
265:               !filename.contains("..") else {
266:             return false
267:         }
268:         
269:         do {
270:             try content.write(to: fileURL, atomically: true, encoding: .utf8)
271:             return true
272:         } catch {
273:             return false
274:         }
275:     }
276: }
277: ```
278: 
279: ### JavaScript Usage
280: 
281: ```javascript
282: // In JSContext - no native fs module
283: const content = FileBridge.readFile("data.json");
284: FileBridge.writeFile("output.txt", "Hello from JSC");
285: ```
286: 
287: ### Storage Quotas
288: 
289: | Storage Type | Size Limit | Persistence |
290: |--------------|------------|-------------|
291: | Documents | App-specific | iCloud backup |
292: | Caches | System managed | May be purged |
293: | Temporary | System managed | Regular cleanup |
294: | App Groups | Shared across apps | User data |
295: 
296: ---
297: 
298: ## 5. Network Access Limitations
299: 
300: ### JSC Has NO Built-in Network APIs
301: 
302: JavaScriptCore is a **pure JavaScript engine** - no `fetch`, `XMLHttpRequest`, or `WebSocket` built-in.
303: 
304: ### Network Strategy: Native Bridge
305: 
306: ```swift
307: import JavaScriptCore
308: import Foundation
309: 
310: class JSNetworkBridge: NSObject, JSExport {
311:     static func setup(in context: JSContext) {
312:         context.setObject(JSNetworkBridge.self, forKeyedSubscript: "Network" as NSString)
313:     }
314:     
315:     // Promise-based fetch equivalent
316:     static func fetch(_ urlString: String, _ callback: JSValue) {
317:         guard let url = URL(string: urlString),
318:               let context = callback.context else {
319:             callback.call(withArguments: ["Invalid URL", JSValue(nullIn: callback.context)])
320:             return
321:         }
322:         
323:         let task = URLSession.shared.dataTask(with: url) { data, response, error in
324:             DispatchQueue.main.async {
325:                 if let error = error {
326:                     callback.call(withArguments: [error.localizedDescription, JSValue(nullIn: context)])
327:                 } else if let data = data, let string = String(data: data, encoding: .utf8) {
328:                     callback.call(withArguments: [JSValue(nullIn: context), string])
329:                 }
330:             }
331:         }
332:         task.resume()
333:     }
334: }
335: ```
336: 
337: ### JavaScript Network Usage
338: 
339: ```javascript
340: // Promise wrapper for callback-based native bridge
341: function fetch(url) {
342:     return new Promise((resolve, reject) => {
343:         Network.fetch(url, (error, data) => {
344:             if (error) reject(new Error(error));
345:             else resolve(data);
346:         });
347:     });
348: }
349: 
350: // Usage
351: async function loadData() {
352:     try {
353:         const data = await fetch("https://api.example.com/data");
354:         return JSON.parse(data);
355:     } catch (e) {
356:         console.error("Fetch failed:", e);
357:     }
358: }
359: ```
360: 
361: ### App Transport Security (ATS)
362: 
363: All network requests must comply with ATS:
364: 
365: ```xml
366: <!-- Info.plist -->
367: <key>NSAppTransportSecurity</key>
368: <dict>
369:     <key>NSAllowsArbitraryLoads</key>
370:     <false/>
371:     <!-- Or configure specific domains -->
372:     <key>NSExceptionDomains</key>
373:     <dict>
374:         <key>example.com</key>
375:         <dict>
376:             <key>NSExceptionAllowsInsecureHTTPLoads</key>
377:             <true/>
378:         </dict>
379:     </dict>
380: </dict>
381: ```
382: 
383: ### Background Network Restrictions
384: 
385: | Scenario | Allowed? | Notes |
386: |----------|----------|-------|
387: | Foreground requests | ✅ Yes | Standard URLSession |
388: | Background downloads | ✅ With URLSession config | Must use background session |
389: | Keep-alive connections | ⚠️ Limited | May be suspended |
390: | Push-triggered fetch | ✅ Yes | Via PushKit |
391: 
392: ---
393: 
394: ## 6. JIT Compilation Status
395: 
396: ### JIT is DISABLED on iOS/iPadOS
397: 
398: **Critical Performance Impact:**
399: 
400: | Platform | JIT Status | JavaScript Performance |
401: |----------|------------|------------------------|
402: | macOS | ✅ Enabled | Full speed |
403: | iOS Simulator | ✅ Enabled | Full speed (x86/ARM host) |
404: | iOS Device | ❌ **Disabled** | ~2-5x slower |
405: | iPadOS Device | ❌ **Disabled** | ~2-5x slower |
406: 
407: ### Why JIT is Disabled
408: 
409: Apple disables JIT on iOS for **security reasons**:
410: 
411: 1. **W^X (Write XOR Execute)** - Memory pages cannot be both writable and executable
412: 2. **Code signing** - All executable code must be signed
413: 3. **Arbitrary code execution prevention**
414: 
415: ### Performance Impact Details
416: 
417: | Operation | With JIT | Without JIT (iOS) | Slowdown |
418: |-----------|----------|-------------------|----------|
419: | Simple loops | 1x | 3-5x | Significant |
420: | Object creation | 1x | 2-3x | Moderate |
421: | Math operations | 1x | 5-10x | Severe |
422: | String operations | 1x | 2-4x | Moderate |
423: | Array operations | 1x | 3-6x | Significant |
424: 
425: ### JIT Workarounds (Limited)
426: 
427: ⚠️ **No legitimate workarounds for third-party apps**
428: 
429: The following have special JIT entitlements (not available to regular apps):
430: - Safari/WebKit
431: - Alternative browser apps (EU only, iOS 17.4+)
432: - Development/debugging scenarios
433: 
434: ```
435: // These entitlements are RESTRICTED:
436: com.apple.security.cs.allow-jit
437: com.apple.security.cs.debugger
438: dynamic-codesigning
439: ```
440: 
441: ### Practical Implications
442: 
443: ```javascript
444: // This runs SLOWER on iOS than macOS
445: function heavyComputation(n) {
446:     let sum = 0;
447:     for (let i = 0; i < n; i++) {
448:         sum += Math.sqrt(i) * Math.sin(i);
449:     }
450:     return sum;
451: }
452: // heavyComputation(1000000) - ~5x slower on iOS
453: ```
454: 
455: ---
456: 
457: ## 7. Performance Benchmarks vs macOS
458: 
459: ### Benchmark Results (Approximate)
460: 
461: Based on common JavaScript benchmarks (JetStream, SunSpider):
462: 
463: | Benchmark | macOS (M1) | iPad Pro (M2) | Ratio |
464: |-----------|------------|---------------|-------|
465: | JetStream 2 | ~180 | ~60-80 | 2.5-3x slower |
466: | SunSpider | ~100ms | ~300-500ms | 3-5x slower |
467: | Octane | ~80000 | ~25000-35000 | 2.5-3x slower |
468: 
469: ### Real-World Performance
470: 
471: | Use Case | macOS | iPad Pro | Acceptable? |
472: |----------|-------|----------|-------------|
473: | JSON parsing | <1ms (MB data) | 2-5ms | ✅ Yes |
474: | Simple data transform | 10ms | 30-50ms | ✅ Yes |
475: | Crypto hashing (JS) | 100ms | 300-500ms | ⚠️ Maybe |
476: | Image processing (JS) | 500ms | 2-5s | ❌ No |
477: | ML inference (TensorFlow.js) | Fast | Very slow | ❌ No |
478: | Game physics | 60fps | 15-20fps | ❌ No |
479: 
480: ### Optimization Strategies for iOS
481: 
482: ```swift
483: // 1. Use native code for heavy lifting
484: class OptimizedBridge: NSObject, JSExport {
485:     // Delegate to Accelerate.framework, Metal, etc.
486:     static func fastMatrixMultiply(_ a: [[Double]], _ b: [[Double]]) -> [[Double]] {
487:         // Use Accelerate framework
488:         return acceleratedMultiply(a, b)
489:     }
490: }
491: 
492: // 2. Batch operations
493: context.evaluateScript("""
494:     function processBatch(items) {
495:         // Process in chunks to allow event loop breathing
496:         const BATCH_SIZE = 100;
497:         let index = 0;
498:         
499:         function processChunk() {
500:             const batch = items.slice(index, index + BATCH_SIZE);
501:             // ... process ...
502:             index += BATCH_SIZE;
503:             
504:             if (index < items.length) {
505:                 setTimeout(processChunk, 0); // Yield control
506:             }
507:         }
508:         
509:         processChunk();
510:     }
511: """)
512: 
513: // 3. Minimize cross-context calls
514: // Batch data exchange instead of frequent small calls
515: ```
516: 
517: ---
518: 
519: ## 8. What Can and Cannot Be Done with Pure JSC
520: 
521: ### ✅ What CAN Be Done
522: 
523: | Category | Examples | Notes |
524: |----------|----------|-------|
525: | **Data Processing** | JSON manipulation, filtering, mapping | Excellent performance |
526: | **Business Logic** | Calculations, validation rules | Ideal use case |
527: | **Scripting** | User-defined behaviors, workflows | Safe sandbox |
528: | **Parsing** | Custom format parsers, compilers | Good performance |
529: | **State Management** | Redux-like patterns, data stores | Efficient |
530: | **String Operations** | Text processing, regex | Moderate performance |
531: | **Configuration** | Dynamic feature flags, settings | Secure |
532: 
533: ### ❌ What CANNOT Be Done (Pure JSC)
534: 
535: | Category | Why Not | Alternative |
536: |----------|---------|-------------|
537: | **DOM Manipulation** | No DOM APIs | Use WKWebView |
538: | **Network Requests** | No fetch/XHR | Native bridge |
539: | **File System** | No fs module | Native bridge + sandbox |
540: | **High-Performance Graphics** | No Canvas/WebGL | Metal, SpriteKit |
541: | **Real-time Audio/Video** | No Web Audio/RTC | AVFoundation |
542: | **Sensors** | No Device APIs | CoreMotion, CoreLocation |
543: | **Push Notifications** | No Push API | APNS via native |
544: | **Background Sync** | No Service Workers | Background tasks |
545: 
546: ### Code Examples
547: 
548: #### ✅ Good Use: Data Validation
549: 
550: ```javascript
551: // Pure JSC - works great
552: function validateUser(user) {
553:     const required = ['name', 'email', 'age'];
554:     const errors = [];
555:     
556:     for (const field of required) {
557:         if (!user[field]) {
558:             errors.push(`${field} is required`);
559:         }
560:     }
561:     
562:     if (user.age < 18) {
563:         errors.push('Must be 18+');
564:     }
565:     
566:     return {
567:         valid: errors.length === 0,
568:         errors
569:     };
570: }
571: ```
572: 
573: #### ❌ Bad Use: Direct Network Request
574: 
575: ```javascript
576: // Pure JSC - this will FAIL
577: const data = fetch('/api/users'); // ReferenceError: fetch is not defined
578: 
579: // Must use native bridge instead
580: ```
581: 
582: #### ✅ Good Use: Business Rules Engine
583: 
584: ```javascript
585: // Pure JSC - excellent use case
586: const rules = {
587:     discount: (order) => {
588:         if (order.total > 1000) return 0.15;
589:         if (order.total > 500) return 0.10;
590:         if (order.customer.loyaltyYears > 5) return 0.05;
591:         return 0;
592:     },
593:     
594:     shipping: (order) => {
595:         if (order.total > 50) return 0;
596:         return order.weight * 2.5;
597:     }
598: };
599: 
600: function calculateOrder(order) {
601:     const discount = rules.discount(order);
602:     const shipping = rules.shipping(order);
603:     
604:     return {
605:         subtotal: order.total,
606:         discount: order.total * discount,
607:         shipping,
608:         total: order.total * (1 - discount) + shipping
609:     };
610: }
611: ```
612: 
613: ---
614: 
615: ## 9. Example Use Cases That Work Well
616: 
617: ### 1. Form Validation Engine
618: 
619: ```swift
620: class FormValidator {
621:     let context = JSContext()
622:     
623:     init() {
624:         // Load validation rules from server or bundle
625:         let rules = """
626:             const validators = {
627:                 email: (v) => /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/.test(v),
628:                 phone: (v) => /^\\+?[\\d\\s-]{10,}$/.test(v),
629:                 required: (v) => v !== null && v !== undefined && v !== ''
630:             };
631:             
632:             function validateField(value, rule) {
633:                 if (typeof rule === 'string') {
634:                     return validators[rule](value);
635:                 }
636:                 if (rule.min !== undefined && value.length < rule.min) {
637:                     return false;
638:                 }
639:                 return true;
640:             }
641:         """
642:         context.evaluateScript(rules)
643:     }
644:     
645:     func validate(value: Any, rule: String) -> Bool {
646:         let jsValue = context.objectForKeyedSubscript("validateField")
647:         return jsValue?.call(withArguments: [value, rule])?.toBool() ?? false
648:     }
649: }
650: ```
651: 
652: ### 2. Expression Evaluator
653: 
654: ```javascript
655: // Safe math expression evaluation
656: const expression = "(price * quantity) * (1 - discount) + tax";
657: 
658: function evaluate(expr, variables) {
659:     // Create safe evaluation context
660:     const safeMath = {
661:         sin: Math.sin,
662:         cos: Math.cos,
663:         sqrt: Math.sqrt,
664:         max: Math.max,
665:         min: Math.min
666:     };
667:     
668:     const context = Object.create(safeMath);
669:     Object.assign(context, variables);
670:     
671:     // Construct function with safe scope
672:     const keys = Object.keys(context);
673:     const values = Object.values(context);
674:     
675:     try {
676:         const fn = new Function(...keys, `return (${expr})`);
677:         return fn(...values);
678:     } catch (e) {
679:         return { error: e.message };
680:     }
681: }
682: 
683: // Usage
684: const result = evaluate(expression, {
685:     price: 99.99,
686:     quantity: 3,
687:     discount: 0.15,
688:     tax: 5.99
689: });
690: ```
691: 
692: ### 3. Template Engine
693: 
694: ```javascript
695: // Lightweight template processing
696: function renderTemplate(template, data) {
697:     return template.replace(/\{\{(\w+)\}\}/g, (match, key) => {
698:         return data[key] !== undefined ? data[key] : match;
699:     });
700: }
701: 
702: const template = "Hello {{name}}, you have {{count}} new messages";
703: const output = renderTemplate(template, { name: "Alice", count: 5 });
704: // "Hello Alice, you have 5 new messages"
705: ```
706: 
707: ### 4. JSON Transform Pipeline
708: 
709: ```javascript
710: // Data transformation chains
711: const pipeline = [
712:     (data) => data.filter(item => item.active),
713:     (data) => data.map(item => ({
714:         ...item,
715:         fullName: `${item.firstName} ${item.lastName}`,
716:         age: new Date().getFullYear() - item.birthYear
717:     })),
718:     (data) => data.sort((a, b) => b.age - a.age),
719:     (data) => data.slice(0, 100) // Limit results
720: ];
721: 
722: function runPipeline(data) {
723:     return pipeline.reduce((acc, transform) => transform(acc), data);
724: }
725: ```
726: 
727: ### 5. State Machine
728: 
729: ```javascript
730: // Finite state machine for workflows
731: function createStateMachine(definition) {
732:     let currentState = definition.initial;
733:     const context = {};
734:     
735:     return {
736:         state: () => currentState,
737:         
738:         transition(event, data) {
739:             const stateDef = definition.states[currentState];
740:             const transition = stateDef?.on?.[event];
741:             
742:             if (!transition) {
743:                 return { success: false, error: 'Invalid transition' };
744:             }
745:             
746:             // Execute exit action
747:             if (stateDef.exit) {
748:                 stateDef.exit(context, data);
749:             }
750:             
751:             // Change state
752:             const prevState = currentState;
753:             currentState = transition.target;
754:             
755:             // Execute entry action
756:             const newStateDef = definition.states[currentState];
757:             if (newStateDef.entry) {
758:                 newStateDef.entry(context, data);
759:             }
760:             
761:             // Execute transition action
762:             if (transition.action) {
763:                 transition.action(context, data, prevState);
764:             }
765:             
766:             return { success: true, state: currentState };
767:         }
768:     };
769: }
770: ```
771: 
772: ---
773: 
774: ## 10. Limitations Requiring Remote Execution
775: 
776: ### When to Use Remote Execution
777: 
778: | Scenario | JSC Limitation | Remote Solution |
779: |----------|---------------|-----------------|
780: | **Heavy ML/AI** | Too slow without JIT | Cloud ML APIs |
781: | **Large Dataset Processing** | Memory/time constraints | Serverless functions |
782: | **Proprietary Algorithms** | Code exposure risk | Server-side execution |
783: | **Real-time Collaboration** | No WebSocket | Backend with WebSockets |
784: | **Database Queries** | No direct DB access | API gateway |
785: | **File Conversion** | Limited format support | Cloud conversion services |
786: | **Video Processing** | No native codecs | FFmpeg cloud services |
787: | **Cryptocurrency Mining** | Impossible (no JIT) | Never do this anyway |
788: 
789: ### Hybrid Architecture Pattern
790: 
791: ```
792: ┌─────────────────┐     ┌──────────────────┐
793: │   iPadOS App    │────▶│   Edge/Cloud     │
794: │                 │     │   Function       │
795: │ ┌─────────────┐ │     │                  │
796: │ │ JSC Context │ │     │ • Heavy compute  │
797: │ │             │ │     │ • JIT enabled    │
798: │ │ • UI logic  │ │◀────│ • DB access      │
799: │ │ • Validation│ │     │ • File processing│
800: │ │ • Caching   │ │     │                  │
801: │ └─────────────┘ │     └──────────────────┘
802: └─────────────────┘
803: ```
804: 
805: ### Remote Execution Implementation
806: 
807: ```swift
808: import JavaScriptCore
809: 
810: class HybridExecutor {
811:     private let context = JSContext()
812:     private let cloudFunctionURL = "https://api.example.com/compute"
813:     
814:     func execute(script: String, data: [String: Any], complexity: ComputeComplexity) async throws -> JSValue {
815:         switch complexity {
816:         case .light:
817:             // Execute locally in JSC
818:             let jsData = try JSONSerialization.data(withJSONObject: data)
819:             let jsDataString = String(data: jsData, encoding: .utf8)!
820:             
821:             let wrappedScript = """
822:                 const input = \(jsDataString);
823:                 (\(script))(input);
824:             """
825:             return context.evaluateScript(wrappedScript)!
826:             
827:         case .heavy:
828:             // Execute remotely
829:             var request = URLRequest(url: URL(string: cloudFunctionURL)!)
830:             request.httpMethod = "POST"
831:             request.httpBody = try JSONSerialization.data(withJSONObject: [
832:                 "script": script,
833:                 "data": data
834:             ])
835:             
836:             let (data, _) = try await URLSession.shared.data(for: request)
837:             let result = try JSONSerialization.jsonObject(with: data)
838:             
839:             // Convert back to JSValue
840:             return JSValue(object: result, in: context)
841:         }
842:     }
843: }
844: 
845: enum ComputeComplexity {
846:     case light   // < 100ms expected, simple transforms
847:     case heavy   // > 100ms or memory intensive
848: }
849: ```
850: 
851: ---
852: 
853: ## Summary Table of Limits
854: 
855: | Category | Limit | Details |
856: |----------|-------|---------|
857: | **API Availability** | Full ES2023 | iOS 7.0+, no browser APIs |
858: | **Memory (iPad Pro M4)** | ~12-16GB app limit | System enforces hard limits |
859: | **Memory (base iPad)** | ~3-4GB app limit | OOM kills possible |
860: | **Execution Timeout** | No built-in limit | Must implement manually |
861: | **Background Time** | ~30 seconds | Use `beginBackgroundTask` |
862: | **File System** | App sandbox only | No system directories |
863: | **Network** | No built-in APIs | Requires native bridge |
864: | **JIT Compilation** | ❌ DISABLED | ~2-5x slower than macOS |
865: | **Threading** | 1 context per thread | `JSVirtualMachine` for isolation |
866: | **Module Loading** | Manual only | No automatic `import` |
867: | **ESM Support** | Partial | Requires polyfills |
868: | **Web APIs** | None | No DOM, fetch, Storage, etc. |
869: | **Crypto (Web)** | SubtleCrypto not available | Use CommonCrypto/Security |
870: | **Performance** | ~30-50% of macOS | Due to JIT disabled |
871: 
872: ---
873: 
874: ## Best Practices Summary
875: 
876: 1. **Keep computation lightweight** - Offload heavy work to native or cloud
877: 2. **Minimize JS-to-native bridge calls** - Batch operations
878: 3. **Implement your own timeouts** - JSC has no execution limits
879: 4. **Use native networking** - Bridge to URLSession, not WKWebView
880: 5. **Cache aggressively** - JIT disabled means repeated code is re-interpreted
881: 6. **Profile on device** - Simulator has JIT, real devices don't
882: 7. **Consider WebAssembly** - For compute-intensive tasks (still no JIT advantage)
883: 8. **Use background tasks** - For long-running JS operations
884: 
885: ---
886: 
887: ## References
888: 
889: - [Apple Developer: JavaScriptCore Framework](https://developer.apple.com/documentation/javascriptcore)
890: - [WebKit Blog: Understanding JIT](https://webkit.org/blog/)
891: - [iOS Memory Limits Analysis](https://developer.apple.com/documentation/xcode/improving_your_app_s_performance)
892: - [App Sandbox Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)
893: 
894: ---
895: 
896: *Document Version: 1.0*  
897: *Last Updated: January 2025*  
898: *Applicable Platforms: iOS 17.x, iPadOS 17.x, Xcode 15.x*
899: 


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md","start_line":1,"end_line":260}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md","start_line":1,"end_line":260}
>>>END>>>END


---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md (lines 2-260 of 508)
────────────────────────────────────────
2: 
3: > **Audit Date:** February 2025  
4: > **Platform:** iOS/iPadOS 17.x+  
5: > **Scope:** JavaScriptCore, WebAssembly, and embedded interpreter security
6: 
7: ---
8: 
9: ## Executive Summary
10: 
11: This security audit covers the security implications of executing user-provided code on iPadOS devices within a VS Code-like environment. The analysis evaluates risks associated with JavaScriptCore, WebAssembly, and potential Python execution, along with recommended mitigation strategies.
12: 
13: **Risk Level:** MEDIUM-HIGH  
14: **Primary Concerns:** Resource exhaustion, information disclosure, sandbox escape attempts  
15: **Recommendation:** Implement strict resource limits and hybrid execution model
16: 
17: ---
18: 
19: ## 1. iOS Sandbox Overview
20: 
21: ### Seatbelt Profile
22: 
23: iOS uses the Seatbelt mandatory access control framework with app-specific profiles:
24: 
25: ```
26: App Container Structure:
27: ├── Documents/          ← User data, read/write
28: ├── Library/            ← App settings, caches
29: │   ├── Caches/
30: │   ├── Preferences/
31: │   └── Application Support/
32: ├── tmp/                ← Temporary files (cleaned periodically)
33: └── .app/               ← Bundle resources (read-only)
34: ```
35: 
36: ### Sandbox Restrictions
37: 
38: | Resource | Access Level | Notes |
39: |----------|--------------|-------|
40: | App Container | ✅ Full | Within own container only |
41: | System Files | ❌ Denied | Cannot access /etc, /System, etc. |
42: | Other Apps | ❌ Denied | No inter-app file access (except via APIs) |
43: | Keychain | ⚠️ Limited | App-specific keychain items only |
44: | Network | ⚠️ Controlled | ATS (App Transport Security) enforced |
45: | Camera/Mic | ⚠️ Permission | Requires user authorization |
46: | Photos | ⚠️ Permission | PHPhotoLibrary API required |
47: | Location | ⚠️ Permission | Core Location with authorization |
48: 
49: ---
50: 
51: ## 2. File System Security
52: 
53: ### 2.1 App Container Isolation
54: 
55: ```swift
56: // Secure file access within app container
57: let documentsPath = FileManager.default.urls(
58:     for: .documentDirectory, 
59:     in: .userDomainMask
60: ).first!
61: 
62: // ALLOWED: Access within container
63: let userFile = documentsPath.appendingPathComponent("user-script.js")
64: 
65: // BLOCKED by sandbox: System file access
66: let systemFile = URL(fileURLWithPath: "/etc/passwd") // ❌ Access denied
67: ```
68: 
69: ### 2.2 File System Attack Vectors
70: 
71: | Attack | Risk | Mitigation |
72: |--------|------|------------|
73: | Path Traversal | HIGH | Validate all paths, reject `../` |
74: | Symlink Escape | MEDIUM | Check `URL.resolvingSymlinksInPath()` |
75: | Hard Links | LOW | Use `stat` to verify file identity |
76: | Resource Forks | LOW | Avoid extended attributes |
77: | Temporary File Exhaustion | MEDIUM | Limit temp file size/count |
78: 
79: ### 2.3 Secure File Handling
80: 
81: ```swift
82: /// Validates that a path is within the app container
83: func validateSandboxPath(_ url: URL) throws -> URL {
84:     let containerURL = FileManager.default.urls(
85:         for: .documentDirectory, 
86:         in: .userDomainMask
87:     ).first!.deletingLastPathComponent()
88:     
89:     let resolvedPath = url.resolvingSymlinksInPath()
90:     
91:     // Ensure path starts with container
92:     guard resolvedPath.path.hasPrefix(containerURL.path) else {
93:         throw SecurityError.pathEscapeAttempt
94:     }
95:     
96:     // Reject parent directory traversal
97:     guard !url.path.contains("..") else {
98:         throw SecurityError.pathTraversalAttempt
99:     }
100:     
101:     return resolvedPath
102: }
103: ```
104: 
105: ---
106: 
107: ## 3. Network Security
108: 
109: ### 3.1 App Transport Security (ATS)
110: 
111: ATS enforces secure network connections by default:
112: 
113: ```xml
114: <!-- Required Info.plist configuration -->
115: <key>NSAppTransportSecurity</key>
116: <dict>
117:     <!-- Default: Only HTTPS with TLS 1.2+ -->
118:     <key>NSAllowsArbitraryLoads</key>
119:     <false/>
120:     
121:     <!-- Exception for localhost debugging -->
122:     <key>NSExceptionDomains</key>
123:     <dict>
124:         <key>localhost</key>
125:         <dict>
126:             <key>NSExceptionMinimumTLSVersion</key>
127:             <string>TLSv1.2</string>
128:         </dict>
129:     </dict>
130: </dict>
131: ```
132: 
133: ### 3.2 Local Network Privacy
134: 
135: iOS 14+ requires permission for local network access:
136: 
137: ```xml
138: <!-- Info.plist requirement -->
139: <key>NSLocalNetworkUsageDescription</key>
140: <string>VS Code needs to connect to development servers on your local network</string>
141: ```
142: 
143: ### 3.3 Network Attack Vectors
144: 
145: | Attack | Risk | Mitigation |
146: |--------|------|------------|
147: | SSRF | HIGH | Validate all URLs, block internal IPs |
148: | DNS Rebinding | MEDIUM | Cache DNS results, validate IPs |
149: | Protocol Smuggling | MEDIUM | Whitelist allowed schemes (https only) |
150: | Data Exfiltration | HIGH | Audit network requests, implement CSP |
151: | CORS Bypass | MEDIUM | Enforce same-origin policy |
152: 
153: ---
154: 
155: ## 4. JavaScriptCore Security
156: 
157: ### 4.1 Injection Attack Risks
158: 
159: ```javascript
160: // DANGEROUS: User input without sanitization
161: const userCode = "alert('xss')"; // Could be injected
162: context.evaluateScript(userCode) // ❌ Risky
163: ```
164: 
165: **Attack Vectors:**
166: - `eval()` on untrusted input
167: - `Function()` constructor abuse
168: - Prototype pollution
169: - `__proto__` manipulation
170: - `constructor` property access
171: 
172: ### 4.2 Infinite Loop / Resource Exhaustion
173: 
174: ```swift
175: // DANGEROUS: No timeout protection
176: let maliciousJS = "while(true) {}"
177: context.evaluateScript(maliciousJS) // ❌ Hangs forever
178: 
179: // SECURE: With timeout protection
180: let runner = JSRunner(timeout: 5.0)
181: runner.execute("while(true) {}") throws // ✅ Times out after 5s
182: ```
183: 
184: ### 4.3 Memory Exhaustion
185: 
186: ```javascript
187: // DANGEROUS: Memory exhaustion attack
188: const arr = new Array(1e9); // 8GB allocation attempt
189: ```
190: 
191: **Mitigation:**
192: ```swift
193: class JSRunner {
194:     private let maxMemoryMB: Int = 256
195:     
196:     func execute(_ code: String) throws -> JSValue {
197:         // Monitor memory before execution
198:         let initialMemory = getCurrentMemoryUsage()
199:         
200:         let result = try context.evaluateScript(code)
201:         
202:         // Check memory after execution
203:         let finalMemory = getCurrentMemoryUsage()
204:         let deltaMB = (finalMemory - initialMemory) / (1024 * 1024)
205:         
206:         if deltaMB > maxMemoryMB {
207:             throw SecurityError.memoryLimitExceeded
208:         }
209:         
210:         return result
211:     }
212: }
213: ```
214: 
215: ### 4.4 Native Function Exposure Risks
216: 
217: ```swift
218: // DANGEROUS: Overly permissive native function
219: context.setObject(unsafeBitCast({ (args: [Any]) -> Any in
220:     // Can access ANYTHING
221:     return FileManager.default.contentsOfDirectory(atPath: "/")
222: }, to: AnyObject.self), forKeyedSubscript: "dangerousNativeFunc" as NSString)
223: 
224: // SECURE: Sanitized native function
225: context.setObject(safeNativeBridge, forKeyedSubscript: "nativeBridge" as NSString)
226: ```
227: 
228: ---
229: 
230: ## 5. WebAssembly Security
231: 
232: ### 5.1 WASM Sandbox Model
233: 
234: WebAssembly provides a memory-safe sandbox with:
235: - Linear memory with bounds checking
236: - No direct OS access
237: - Explicit imports required for system calls
238: 
239: ```wat
240: ;; WASM cannot directly access files or network
241: (module
242:   (import "env" "log" (func $log (param i32)))
243:   ;; All external access must be explicitly imported
244: )
245: ```
246: 
247: ### 5.2 WASM-Specific Risks
248: 
249: | Risk | Description | Mitigation |
250: |------|-------------|------------|
251: | Meltdown/Spectre | Speculative execution attacks | Site isolation, no sensitive data in WASM |
252: | Type Confusion | Malformed WASM modules | Validate all modules before loading |
253: | Host Function Abuse | Malicious imports | Whitelist allowed host functions |
254: | Memory Exhaustion | Large memory requests | Enforce memory limits |
255: | Infinite Loops | Unbounded execution | Implement execution timeouts |
256: 
257: ### 5.3 WASI Security Considerations
258: 
259: WASI (WebAssembly System Interface) provides file system access:
260: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md (lines 2-183 of 183)
────────────────────────────────────────
2: 
3: ## Overview
4: 
5: The terminal now uses **SwiftNIO SSH** (apple/swift-nio-ssh) for real SSH connections.
6: This is a pure Swift implementation that works on iOS without any C dependencies.
7: 
8: ## Adding SwiftNIO SSH Dependency
9: 
10: ### Method 1: Xcode Package Manager (Recommended)
11: 
12: 1. Open `VSCodeiPadOS.xcodeproj` in Xcode
13: 2. Go to **File → Add Package Dependencies...**
14: 3. Enter the URL: `https://github.com/apple/swift-nio-ssh`
15: 4. Select version **0.8.0** or later
16: 5. Choose to add **NIOSSH** product to the VSCodeiPadOS target
17: 6. Xcode will automatically resolve and add:
18:    - swift-nio-ssh
19:    - swift-nio
20:    - swift-crypto
21: 
22: ### Method 2: Manual Package.swift
23: 
24: A `Package.swift` file is provided at the project root for reference.
25: You can use Swift Package Manager from command line:
26: 
27: ```bash
28: cd VSCodeiPadOS
29: swift package resolve
30: ```
31: 
32: ## Files Added
33: 
34: ### Services/SSHManager.swift
35: 
36: Main SSH connection manager using SwiftNIO SSH:
37: 
38: ```swift
39: // Usage example
40: let sshManager = SSHManager()
41: sshManager.delegate = self
42: 
43: let config = SSHConnectionConfig(
44:     name: "My Server",
45:     host: "example.com",
46:     port: 22,
47:     username: "user",
48:     authMethod: .password("secret")
49: )
50: 
51: sshManager.connect(config: config) { result in
52:     switch result {
53:     case .success:
54:         print("Connected!")
55:     case .failure(let error):
56:         print("Failed: \(error)")
57:     }
58: }
59: 
60: // Send commands
61: sshManager.send(command: "ls -la")
62: 
63: // Send control characters
64: sshManager.sendInterrupt() // Ctrl+C
65: sshManager.sendTab()       // Tab completion
66: sshManager.sendEscape()    // ESC key
67: ```
68: 
69: ### Services/SFTPManager.swift
70: 
71: Basic SFTP operations (uses shell commands as SwiftNIO SSH doesn't include SFTP subsystem):
72: 
73: ```swift
74: let sftp = SFTPManager()
75: sftp.connect(config: config) { result in
76:     // Directory operations via shell commands
77:     sftp.createDirectory(remotePath: "~/newdir") { _ in }
78:     sftp.delete(remotePath: "~/oldfile") { _ in }
79: }
80: ```
81: 
82: ## Features
83: 
84: ### Authentication Methods
85: 
86: 1. **Password Authentication**
87:    ```swift
88:    .password("your-password")
89:    ```
90: 
91: 2. **SSH Key Authentication**
92:    ```swift
93:    .privateKey(key: pemString, passphrase: nil)
94:    ```
95: 
96: ### Terminal Features
97: 
98: - Real SSH protocol (not raw TCP)
99: - PTY allocation for interactive shells
100: - Terminal resize support
101: - ANSI escape sequence handling
102: - Command history
103: - Connection persistence (saved connections)
104: 
105: ### Saved Connections
106: 
107: Connections are stored in UserDefaults and persist across app launches:
108: 
109: ```swift
110: // Access saved connections
111: let store = SSHConnectionStore.shared
112: let connections = store.savedConnections
113: 
114: // Save a new connection
115: store.save(config)
116: 
117: // Delete a connection
118: store.delete(config)
119: ```
120: 
121: ## SwiftNIO SSH Notes
122: 
123: ### Supported Algorithms
124: 
125: - **Key Exchange**: x25519
126: - **Host Keys**: Ed25519, ECDSA (P256, P384, P521)
127: - **Encryption**: AES-GCM
128: - **Authentication**: Password, Public Key
129: 
130: ### Limitations
131: 
132: 1. **No SFTP Subsystem**: SwiftNIO SSH doesn't include SFTP.
133:    Use shell commands (scp, cat, etc.) for file operations.
134: 
135: 2. **Host Key Verification**: Current implementation accepts all host keys.
136:    For production, implement proper host key verification.
137: 
138: 3. **Key Format**: Currently supports Ed25519 keys.
139:    Full PEM parsing for RSA/ECDSA keys needs additional implementation.
140: 
141: ## Troubleshooting
142: 
143: ### Connection Timeout
144: 
145: - Check network connectivity
146: - Verify host and port are correct
147: - Ensure firewall allows SSH (port 22)
148: 
149: ### Authentication Failed
150: 
151: - Verify username/password
152: - For key auth, ensure private key is in correct PEM format
153: - Check server allows the authentication method
154: 
155: ### Channel Errors
156: 
157: - Server may have closed the connection
158: - Check for server-side errors in SSH logs
159: 
160: ## Architecture
161: 
162: ```
163: TerminalView
164:     │
165:     ▼
166: TerminalManager
167:     │
168:     ▼
169: SSHManager ──────► NIOSSHHandler
170:     │                    │
171:     │                    ▼
172:     │              SSH Channel
173:     │                    │
174:     ▼                    ▼
175: SSHManagerDelegate    Remote Server
176: ```
177: 
178: ## References
179: 
180: - [SwiftNIO SSH GitHub](https://github.com/apple/swift-nio-ssh)
181: - [SwiftNIO Documentation](https://apple.github.io/swift-nio/docs/current/NIO/index.html)
182: - [SSH Protocol RFC 4251](https://tools.ietf.org/html/rfc4251)
183: 


>>>TOOL web_search
{"query":"App Store Review Guidelines 2.5.2 execute code JavaScriptCore WebKit exception", "max_results":5}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "App Store Review Guidelines 2.5.2 execute code JavaScriptCore WebKit exception" (5 results):

1. **App Review Guidelines - Apple Developer**
   https://developer.apple.com/app-store/review/guidelines/
   The App Review Guidelines provide guidance and examples across a range of development topics, including user interface design, functionality, content, and the use of specific technologies. These guidelines are designed to help you prepare your apps for the approval process.

2. **Fixing Section 2.5.2 - Saagar Jha**
   https://saagarjha.com/blog/2020/11/08/fixing-section-2-5-2/
   The App Review team seems to have been told that the ability to run code at all is some sort of &quot;security issue&quot;, but again, this is how every scripting application works—trying to enforce the guidelines in this way would require all of them to not be allowed on the store. Fixing section 2.5.2

3. **Apple App Store Review | Mendix Forum**
   https://community.mendix.com/link/spaces/mobile/questions/107959
   Guideline 2.5.2 - Performance - Software Requirements Your app, extension, or linked framework appears to contain code designed explicitly with the capability to change your app&#x27;s behavior or functionality after App Review approval, which is not in compliance with App Store Review Guideline 2.5.2 and section 3.3.2 of the Apple Developer ...

4. **WebKit**
   https://webkit.org/
   WebKit is the web browser engine used by Safari, Mail, App Store, and many other apps on macOS, iOS, and Linux. Get started contributing code, or reporting bugs. Web developers can follow development, check feature status, download Safari Technology Preview to try out the latest web technologies, and report bugs.

5. **How do you comply with Apple&#x27;s App Store Review Guidelines when using ...**
   https://news.ycombinator.com/item?id=17620965
   How do you comply with Apple&#x27;s App Store Review Guidelines when using this (specifically, this clause): 2.5.2 Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app ...


>>>TOOL web_fetch
{"url":"https://developer.apple.com/app-store/review/guidelines/","max_length":12000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://developer.apple.com/app-store/review/guidelines/

• 

• 

• 

• 

• 

• 

• 

• 

• 

• 
	App Review Guidelines - Apple Developer

• 
	
• 

• 
	
• 
	
• 
	
• 
	
• 

• 

• 

[View in English](#)

• 

					Global Nav Open Menu

					Global Nav Close Menu

• 
				
					Apple Developer

								Search

							Cancel

• 
				
					Apple Developer

• 
				
					News

• 
				
					Discover

• 
				
					Design

• 
				
					Develop

• 
				
					Distribute

• 
				
					Support

• 
				
					Account

• 
				[](/search/)

									Cancel

							Only search within “”
                            Quick Links

                            5 Quick Links

• 

• 

				[App Review](/distribute/app-review/)

					Open Menu

					Close Menu

• 
							[Overview](/distribute/app-review/)

• 
							[App Review Guidelines](/app-store/review/guidelines/)

# App Review Guidelines

Apps are changing the world, enriching people’s lives, and enabling developers like you to innovate like never before. As a result, the App Store has grown into an exciting and vibrant ecosystem for millions of developers and more than a billion users. Whether you are a first-time developer or a large team of experienced programmers, we are excited that you are creating apps for our platforms, and want to help you understand our guidelines so you can be confident your app will get through the review process quickly.

								Highlight Notarization Review Guidelines Only

						Introduction
						
The guiding principle of the App Store is simple—we want to provide a safe experience for users to get apps and a great opportunity for all developers to be successful. We do this by offering a highly curated App Store where every app is reviewed by experts and an editorial team helps users discover new apps every day. We also scan each app for malware and other software that may impact user safety, security, and privacy. These efforts have made Apple’s platforms the safest for consumers around the world.

In the European Union, developers can also distribute notarized iOS and iPadOS apps from alternative app marketplaces and directly from their website; in Japan, developers can also distribute iOS apps from alternative app marketplaces. Learn more about [alternative app marketplaces](/help/app-store-connect/distributing-apps-in-the-european-union/manage-distribution-on-an-alternative-app-marketplace), [Web Distribution](/support/web-distribution-eu/), and [Notarization for iOS and iPadOS apps](/help/app-store-connect/managing-alternative-distribution/submit-for-notarization). You can see which guidelines apply to Notarization for iOS and iPadOS apps by clicking on “Highlight Notarization Review Guidelines Only” in the menu to the left.

For everything else there is always the open Internet. If the App Store model and guidelines or alternative distribution and Notarization for iOS and iPadOS apps are not best for your app or business idea that’s okay, we provide Safari for a great web experience too.

On the following pages you will find our latest guidelines arranged into five clear sections: Safety, Performance, Business, Design, and Legal. The App Store is always changing and improving to keep up with the needs of our customers and our products. Your apps should change and improve as well in order to stay on the App Store.
						
A few other points to keep in mind about distributing your app on our platforms:

• We have lots of kids downloading lots of apps. Parental controls work great to protect kids, but you have to do your part too. So know that we’re keeping an eye out for the kids.
							
• The App Store is a great way to reach hundreds of millions of people around the world. If you build an app that you just want to show to family and friends, the App Store isn’t the best way to do that. Consider using Xcode to install your app on a device for free or use Ad Hoc distribution available to Apple Developer Program members. If you’re just getting started, learn more about the [Apple Developer Program](/programs/).
							
• We strongly support all points of view being represented on the App Store, as long as the apps are respectful to users with differing opinions and the quality of the app experience is great. We will reject apps for any content or behavior that we believe is over the line. What line, you ask? Well, as a Supreme Court Justice once said, “I’ll know it when I see it”. And we think that you will also know it when you cross it.
							
• If you attempt to cheat the system (for example, by trying to trick the review process, steal user data, copy another developer’s work, manipulate ratings or App Store discovery) your apps will be removed from the store and you will be expelled from the Apple Developer Program.
							
• You are responsible for making sure everything in your app complies with these guidelines, including ad networks, analytics services, and third-party SDKs, so review and choose them carefully.
							
• Some features and technologies that are not generally available to developers may be offered as an entitlement for limited use cases. For example, we offer entitlements for CarPlay Audio, HyperVisor, and Privileged File Operations.

We hope these guidelines help you sail through the review process, and that approvals and rejections remain consistent across the board. This is a living document; new apps presenting new questions may result in new rules at any time. Perhaps your app will trigger this. We love this stuff too, and honor what you do. We’re really trying our best to create the best platform in the world for you to express your talents and make a living, too.

						Before You Submit
						
To help your app approval go as smoothly as possible, review the common missteps listed below that can slow down the review process or trigger a rejection. This doesn’t replace the guidelines or guarantee approval, but making sure you can check every item on the list is a good start. If your app no longer functions as intended or you’re no longer actively supporting it, it will be removed from the App Store. [Learn more about App Store Improvements](/support/app-store-improvements/).
						
Make sure you:

• Test your app for crashes and bugs
							
• Ensure that all app information and metadata is complete and accurate
							
• Update your contact information in case App Review needs to reach you
							
• Provide App Review with full access to your app. If your app includes account-based features, provide either an active demo account or fully-featured demo mode, plus any other hardware or resources that might be needed to review your app (e.g. login credentials or a sample QR code)
							
• Enable backend services so that they’re live and accessible during review
							
• Include detailed explanations of non-obvious features and in-app purchases in the App Review notes, including supporting documentation where appropriate
							
• Check whether your app follows guidance in other documentation, such as:

Developer Documentation

• SwiftUI
								
• UIKit
								
• AppKit
								
• App extensions
								
• Optimizing Your App’s Data for iCloud Backup
								
• Apple File System
								
• [App Store Connect Help](/help/app-store-connect/)
								
• [Developer Account Help](/help/account/)

Design Guidelines

• [Human Interface Guidelines](/design/human-interface-guidelines/)

Brand and Marketing Guidelines

• [Marketing Resources and Identity Guidelines](/app-store/marketing/guidelines/)
								
• [Apple Pay Marketing Guidelines](/apple-pay/marketing/)
								
• [Add to Apple Wallet Guidelines](/wallet/add-to-apple-wallet-guidelines/)
								
• Guidelines for Using Apple Trademarks and Copyrights

Guidelines that include  apply to Notarization for iOS and iPadOS apps in the EU and Notarization for iOS apps in Japan.

						1. Safety
						
When people install an app from the App Store, they want to feel confident that it’s safe to do so—that the app doesn’t contain upsetting or offensive content, won’t damage their device, and isn’t likely to cause physical harm from its use. We’ve outlined the major pitfalls below, but if you’re looking to shock and offend people, the App Store isn’t the right place for your app. Some of these rules are also included in Notarization for iOS and iPadOS apps.

• 1.1 Objectionable Content
								
Apps should not include content that is offensive, insensitive, upsetting, intended to disgust, in exceptionally poor taste, or just plain creepy. Examples of such content include:

• 1.1.1 Defamatory, discriminatory, or mean-spirited content, including references or commentary about religion, race, sexual orientation, gender, national/ethnic origin, or other targeted groups, particularly if the app is likely to humiliate, intimidate, or harm a targeted individual or group. Professional political satirists and humorists are generally exempt from this requirement.
									
• 1.1.2 Realistic portrayals of people or animals being killed, maimed, tortured, or abused, or content that encourages violence. “Enemies” within the context of a game cannot solely target a specific race, culture, real government, corporation, or any other real entity.
									
• 1.1.3 Depictions that encourage illegal or reckless use of weapons and dangerous objects, or facilitate the purchase of firearms or ammunition.
									
• 1.1.4 Overtly sexual or pornographic material, defined as “explicit descriptions or displays of sexual organs or activities intended to stimulate erotic rather than aesthetic or emotional feelings.” This includes “hookup” apps and other apps that may include pornography or be used to facilitate prostitution, or human trafficking and exploitation.
									
• 1.1.5 Inflammatory religious commentary or inaccurate or misleading quotations of religious texts.
									
• 1.1.6 False information and features, including inaccurate device data or trick/joke functionality, such as fake location trackers. Stating that the app is “for entertainment purposes” won’t overcome this guideline. Apps that enable anonymous or prank phone calls or SMS/MMS messaging will be rejected.
									
• 1.1.7 Harmful concepts which capitalize or seek to profit on recent or current events, such as violent conflicts, terrorist attacks, and epidemics.

• 1.2 User-Generated Content
								
Apps with user-generated content present particular challenges, ranging from intellectual property infringement to anonymous bullying. To prevent abuse, apps with user-generated content or social networking services must include:

• A method for filtering objectionable material from being posted to the app
									
• A mechanism to report offensive content and timely responses to concerns
									
• The ability to block abusive users from the service
									
• Published contact information so users can easily reach you

Apps with user-generated content or services that end up being used primarily for pornographic content, Chatroulette-style experiences, random or anonymous chat, objectification of real people (e.g. “hot-or-not” voting), making physical threats, or bullying do not belong on the App Store and may be removed without notice. If your app includes user-generated content from a web-based service, it may display incidental mature “NSFW” content, provided that the content is hidden by default and only displayed when the user turns it on via your website.

• 1.2.1 Creator Content
Apps which feature content from a specific community of users called “creators” are a great opportunity if properly moderated. These apps present a singular, unified experience for customers to interact with various kinds of creator content. They offer tools and programs to help this community of non-developer creators to author, share, and monetize user-generated experiences. These experiences must not change the core features and functionality of the native app—rather, they add content to those structured experiences. These experiences are not native “apps” c

... [truncated]


>>>TOOL search
{"query":"OnDeviceResearch.md", "glob":"**/*"}
>>>END>>>END


---

## 🔧 TOOL RESULTS

[search]
No matches found for "OnDeviceResearch.md"


>>>TOOL web_search
{"query":"JavaScriptCore.framework WebAssembly support JSContext iOS", "max_results":5}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "JavaScriptCore.framework WebAssembly support JSContext iOS" (5 results):

1. **JavaScriptCore | Apple Developer Documentation**
   https://developer.apple.com/documentation/javascriptcore
   Framework JavaScriptCore Evaluate JavaScript programs from within an app, and support JavaScript scripting of your app. iOS 16.0+ iPadOS 16.0+ Mac Catalyst 13.0+ macOS 10.5+ tvOS 9.0+ visionOS 1.0+

2. **How to load WebAssembly in iOS app via WKWebVIew or JSC**
   https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc
   I&#x27;m trying to load and execute a WebAssembly .wasm from within a Swift-based, iOS app. I first attempted to use the JavaScriptCore Framework but the WebAssembly.* module wasn&#x27;t available in the Co...

3. **Wasmer 3.3 - Running WebAssembly 2.5x faster with JavascriptCore**
   https://wasmer.io/posts/wasmer-3_3-and-javascriptcore
   The power of Wasmer relies on delivering one universal API to run WebAssembly programs anywhere. On that quest, we worked hard to extend Wasmer by adding support for more backends, starting with JavaScriptCore. Today are incredibly excited to ship JSC support in Wasmer v3.3. Now you can use wasmer to run WebAssembly programs in macOS and Linux, powered by the same engine behind the Safari ...

4. **Using JavaScriptCore in a Production iOS app · GitHub**
   https://gist.github.com/mheiber/9e35ddb29ee2a76bd44b3cc1193a9215
   JavaScriptCore is a built-in iOS library that enables you to use JavaScript in apps alongside Objective-C and Swift. It lets developers read JavaScript from a string, execute it from Objective-C or Swift, and share data structures and functions across languages. We JavaScriptCore to share code between Web and iOS. Sharing code helped us produce a high-quality, consistent experience across ...

5. **Use JavaScriptCore in iOS App. introduce | by anzhi zhu | Medium**
   https://medium.com/@for.wlb.biz/use-javascriptcore-in-ios-app-78a6c56c7264
   Use JavaScriptCore in iOS App introduce Apple has added the JavaScriptCore framework since iOS7.0. The framework provides the ability to execute javascript scripts in native codes such as Swift …


>>>TOOL web_search
{"query":"site:developer.apple.com 2.5.2 Apps should be self-contained in their bundles may not download install or execute code which introduces or changes features", "max_results":5}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "site:developer.apple.com 2.5.2 Apps should be self-contained in their bundles may not download install or execute code which introduces or changes features" (5 results):

1. **App Review Guidelines - Apple Developer**
   https://developer.apple.com/app-store/review/guidelines/
   2.5.2 Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.

2. **Is it allow? download and run lua … | Apple Developer Forums**
   https://developer.apple.com/forums/thread/698999
   Check also: 2.5.2 Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.

3. **Message from Apple Review... | Apple Developer Forums**
   https://developer.apple.com/forums/thread/73640
   App Store Review Guideline 2.5.2 states the following: 2.5.2 Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code, including other iOS, watchOS, macOS, or tvOS apps.

4. **New App Store Guidelines about dow… | Apple Developer Forums**
   https://developer.apple.com/forums/thread/52161
   2.5.2 Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code, including other iOS, watchOS, Mac OS X, or tvOS apps. Is this a reversal from previous guidelines, or am I just reading too much into it?

5. **Usage of CodePush in react native … | Apple Developer Forums**
   https://developer.apple.com/forums/thread/83308
   2.5.2 Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code, including other apps....


>>>TOOL web_fetch
{"url":"https://developer.apple.com/forums/thread/698999","max_length":12000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://developer.apple.com/forums/thread/698999

Is it allow? download and run lua … | Apple Developer Forums

• 

• 

• 
    
• 

• 

• 

• 
    
• 

• 

• 

• 

					Global Nav Open Menu

					Global Nav Close Menu

• 
				
					Apple Developer

								Search

							Cancel

• 
				
					Apple Developer

• 
				
					News

• 
				
					Discover

• 
				
					Design

• 
				
					Develop

• 
				
					Distribute

• 
				
					Support

• 
				
					Account

• 
				[](https://developer.apple.com/search/)

									Cancel

							Only search within “”
                            Quick Links

                            5 Quick Links

                    Developer  Forums

  Search for a topic, subtopic, or tag

        Clear search query

                        Local Nav Open Menu

                        Local Nav Close Menu

• 
        
          Search

    [
    Post
    ](/forums/post/question)

      Profile
    
    &#9650;

• 
          [
            Sign in
          ](/forums/login)

• 
          [
            Create account
          ](/forums/login#)

                    Is it allow? download and run lua script

	[
		App Store Distribution & Marketing
  	](/forums/topics/app-store-distribution-and-marketing)

	[
		App Review
		
  	](/forums/topics/app-store-distribution-and-marketing/app-store-distribution-and-marketing-app-review)

          [
            App Review
          ](/forums/tags/app-review)

    You’re now watching this thread. If you’ve opted in to email or web notifications, you’ll be notified when there’s activity. Click again to stop watching or visit your profile to manage watched threads and notifications.

    You’ve stopped watching this thread and will no longer receive emails or web notifications when there’s activity. Click again to start watching.

        [

        yongmin kim

        ](/forums/profile/yongmin+kim)
      
      OP

      Created
      Jan ’22

      Replies
      1

      Boosts
      0

      Views
      863

      Participants
      2

Hi

Is it allow the apple guidelines to download and run Lua scripts to fix bugs?

thanks.

      Answered by
        
          [Claude31](/forums/profile/Claude31)

      in
      [702055022](/forums/thread/698999?answerId&#x3D;702055022#702055022)
    
    [](/forums/thread/698999?answerId&#x3D;702055022#702055022)

to fix bugs

How does the fix works ? Changes code ? That would not work.

Is it an iOS or MacOS App ?

For MacOS, check guideline 2.4.5

2.4.5 Apps distributed via the Mac App Store have some additional requirements to keep in mind:

• (ii) They must be packaged and submitted using technologies provided in Xcode; no third-party installers allowed. They must also be self-contained, single app installation bundles and cannot install code or resources in shared locations.
• (iii) They may not auto-launch or have other code run automatically at startup or login without consent nor spawn processes that continue to run without consent after a user has quit the app. They should not automatically add their icons to the Dock or leave shortcuts on the user desktop.
• (iv) They may not download or install standalone apps, kexts, additional code, or resources to add functionality or significantly change the app from what we see during the review process.

Check also:
2.5.2 Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.

          Boost

        Copy to clipboard

      Share this post

      Copied to Clipboard

        Replies
         1

        Boosts
         0

        Views
         863

        Participants
         2

        [

        Claude31

        ](/forums/profile/Claude31)
      
      OP

        Jan ’22

        Accepted Answer

to fix bugs

How does the fix works ? Changes code ? That would not work.

Is it an iOS or MacOS App ?

For MacOS, check guideline 2.4.5

2.4.5 Apps distributed via the Mac App Store have some additional requirements to keep in mind:

• (ii) They must be packaged and submitted using technologies provided in Xcode; no third-party installers allowed. They must also be self-contained, single app installation bundles and cannot install code or resources in shared locations.
• (iii) They may not auto-launch or have other code run automatically at startup or login without consent nor spawn processes that continue to run without consent after a user has quit the app. They should not automatically add their icons to the Dock or leave shortcuts on the user desktop.
• (iv) They may not download or install standalone apps, kexts, additional code, or resources to add functionality or significantly change the app from what we see during the review process.

Check also:
2.5.2 Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.

            0
             comments

      0

        Copy to clipboard

      Share this post

      Copied to Clipboard

      Load more
      
        [
          Add comment
        ](/forums/login)

                Is it allow? download and run lua script

              First post date
              Last post date

        Q

## Developer Footer

        This site contains user submitted content, comments and opinions and is for informational purposes only. Apple disclaims any and all liability for the acts, omissions and conduct of any third parties in connection with or related to your use of the site. All postings and use of the content on this site are subject to the [Apple Developer Forums Participation Agreement](https://developer.apple.com/support/downloads/terms/apple-developer-forums/Apple-Developer-Forums-Agreement-20250602-English.pdf) and Apple provided code is subject to the [Apple Sample Code License](https://developer.apple.com/support/downloads/terms/apple-sample-code/Apple-Sample-Code-License.pdf).

• Forums

				Platforms
			
			 Open Menu 
			 Close Menu 

• [iOS](https://developer.apple.com/ios/)
				
• [iPadOS](https://developer.apple.com/ipados/)
				
• [macOS](https://developer.apple.com/macos/)
				
• [tvOS](https://developer.apple.com/tvos/)
				
• [watchOS](https://developer.apple.com/watchos/)
				
• [visionOS](https://developer.apple.com/visionos/)

				Tools
			
			 Open Menu 
			 Close Menu 

• [Swift](https://developer.apple.com/swift/)
				
• [SwiftUI](https://developer.apple.com/swiftui/)
				
• [SF Symbols](https://developer.apple.com/sf-symbols/)
				
• [Swift Playground](https://developer.apple.com/swift-playground/)
				
• [TestFlight](https://developer.apple.com/testflight/)
				
• [Xcode](https://developer.apple.com/xcode/)
				
• [Xcode Cloud](https://developer.apple.com/xcode-cloud/)

				Topics & Technologies
			
			 Open Menu 
			 Close Menu 

• [Accessibility](https://developer.apple.com/accessibility/)
				
• [Accessories](https://developer.apple.com/accessories/)
				
• [App Extensions](https://developer.apple.com/app-extensions/)
				
• [App Store](https://developer.apple.com/app-store/)
				
• [Audio & Video](https://developer.apple.com/audio/)
				
• [Augmented Reality](https://developer.apple.com/augmented-reality/)
				
• [Design](https://developer.apple.com/design/)
				
• [Distribution](https://developer.apple.com/distribute/)
				
• [Education](https://developer.apple.com/education/)
				
• [Fonts](https://developer.apple.com/fonts/)
				
• [Games](https://developer.apple.com/games/)
				
• [Health & Fitness](https://developer.apple.com/health-fitness/)
				
• [In-App Purchase](https://developer.apple.com/in-app-purchase/)
				
• [Localization](https://developer.apple.com/localization/)
				
• [Maps & Location](https://developer.apple.com/maps/)
				
• [Machine Learning](https://developer.apple.com/machine-learning/)
        
• [Open Source](https://opensource.apple.com)
				
• [Security](https://developer.apple.com/security/)
				
• [Safari & Web](https://developer.apple.com/safari/)

				Resources
			
			 Open Menu 
			 Close Menu 

• [Documentation](https://developer.apple.com/documentation/)
        
• [Tutorials](https://developer.apple.com/learn/)
				
• [Downloads](https://developer.apple.com/download/)
				
• [Forums](https://developer.apple.com/forums/)
				
• [Videos](https://developer.apple.com/videos/)

				Support
			
			 Open Menu 
			 Close Menu 

• [Support Articles](https://developer.apple.com/support/articles/)
				
• [Contact Us](https://developer.apple.com/contact/)
				
• [Bug Reporting](https://developer.apple.com/bug-reporting/)
				
• [System Status](https://developer.apple.com/system-status/)

				Account
			
			 Open Menu 
			 Close Menu 

• [Apple Developer](https://developer.apple.com/account/)
				
• [App Store Connect](https://appstoreconnect.apple.com/)
				
• [Certificates, IDs, & Profiles](https://developer.apple.com/account/ios/certificate/)
				
• [Feedback Assistant](https://feedbackassistant.apple.com/)

				Programs
			
			 Open Menu 
			 Close Menu 

• [Apple Developer Program](https://developer.apple.com/programs/)
				
• [Apple Developer Enterprise Program](https://developer.apple.com/programs/enterprise/)
				
• [App Store Small Business Program](https://developer.apple.com/app-store/small-business-program/)
				
• [MFi Program](https://mfi.apple.com/)
				
• [News Partner Program](https://developer.apple.com/programs/news-partner/)
				
• [Video Partner Program](https://developer.apple.com/programs/video-partner/)
				
• [Security Bounty Program](https://developer.apple.com/security-bounty/)
				
• [Security Research Device Program](https://developer.apple.com/programs/security-research-device/)

				Events
			
			 Open Menu 
			 Close Menu 

• [Meet with Apple](https://developer.apple.com/events/)
        
• [Apple Developer Centers](https://developer.apple.com/events/developer-centers/)
				
• [App Store Awards](https://developer.apple.com/app-store/app-store-awards/)
				
• [Apple Design Awards](https://developer.apple.com/design/awards/)
				
• [Apple Developer Academies](https://developer.apple.com/learn/experts/#academies)
				
• [WWDC](https://developer.apple.com/wwdc/)

    To view the latest developer news, visit [News and Updates](https://developer.apple.com/news/).
    
        Copyright ©   Apple Inc. All rights reserved.
        
            [Terms of Use](https://www.apple.com/legal/internet-services/terms/site.html)
            [Privacy Policy](https://www.apple.com/legal/privacy/en-ww/)
            [License Agreements](https://developer.apple.com/terms/)


>>>TOOL web_fetch
{"url":"https://developer.apple.com/app-store/review/guidelines/#software-requirements","max_length":20000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://developer.apple.com/app-store/review/guidelines/#software-requirements

• 

• 

• 

• 

• 

• 

• 

• 

• 

• 
	App Review Guidelines - Apple Developer

• 
	
• 

• 
	
• 
	
• 
	
• 
	
• 

• 

• 

[View in English](#)

• 

					Global Nav Open Menu

					Global Nav Close Menu

• 
				
					Apple Developer

								Search

							Cancel

• 
				
					Apple Developer

• 
				
					News

• 
				
					Discover

• 
				
					Design

• 
				
					Develop

• 
				
					Distribute

• 
				
					Support

• 
				
					Account

• 
				[](/search/)

									Cancel

							Only search within “”
                            Quick Links

                            5 Quick Links

• 

• 

				[App Review](/distribute/app-review/)

					Open Menu

					Close Menu

• 
							[Overview](/distribute/app-review/)

• 
							[App Review Guidelines](/app-store/review/guidelines/)

# App Review Guidelines

Apps are changing the world, enriching people’s lives, and enabling developers like you to innovate like never before. As a result, the App Store has grown into an exciting and vibrant ecosystem for millions of developers and more than a billion users. Whether you are a first-time developer or a large team of experienced programmers, we are excited that you are creating apps for our platforms, and want to help you understand our guidelines so you can be confident your app will get through the review process quickly.

								Highlight Notarization Review Guidelines Only

						Introduction
						
The guiding principle of the App Store is simple—we want to provide a safe experience for users to get apps and a great opportunity for all developers to be successful. We do this by offering a highly curated App Store where every app is reviewed by experts and an editorial team helps users discover new apps every day. We also scan each app for malware and other software that may impact user safety, security, and privacy. These efforts have made Apple’s platforms the safest for consumers around the world.

In the European Union, developers can also distribute notarized iOS and iPadOS apps from alternative app marketplaces and directly from their website; in Japan, developers can also distribute iOS apps from alternative app marketplaces. Learn more about [alternative app marketplaces](/help/app-store-connect/distributing-apps-in-the-european-union/manage-distribution-on-an-alternative-app-marketplace), [Web Distribution](/support/web-distribution-eu/), and [Notarization for iOS and iPadOS apps](/help/app-store-connect/managing-alternative-distribution/submit-for-notarization). You can see which guidelines apply to Notarization for iOS and iPadOS apps by clicking on “Highlight Notarization Review Guidelines Only” in the menu to the left.

For everything else there is always the open Internet. If the App Store model and guidelines or alternative distribution and Notarization for iOS and iPadOS apps are not best for your app or business idea that’s okay, we provide Safari for a great web experience too.

On the following pages you will find our latest guidelines arranged into five clear sections: Safety, Performance, Business, Design, and Legal. The App Store is always changing and improving to keep up with the needs of our customers and our products. Your apps should change and improve as well in order to stay on the App Store.
						
A few other points to keep in mind about distributing your app on our platforms:

• We have lots of kids downloading lots of apps. Parental controls work great to protect kids, but you have to do your part too. So know that we’re keeping an eye out for the kids.
							
• The App Store is a great way to reach hundreds of millions of people around the world. If you build an app that you just want to show to family and friends, the App Store isn’t the best way to do that. Consider using Xcode to install your app on a device for free or use Ad Hoc distribution available to Apple Developer Program members. If you’re just getting started, learn more about the [Apple Developer Program](/programs/).
							
• We strongly support all points of view being represented on the App Store, as long as the apps are respectful to users with differing opinions and the quality of the app experience is great. We will reject apps for any content or behavior that we believe is over the line. What line, you ask? Well, as a Supreme Court Justice once said, “I’ll know it when I see it”. And we think that you will also know it when you cross it.
							
• If you attempt to cheat the system (for example, by trying to trick the review process, steal user data, copy another developer’s work, manipulate ratings or App Store discovery) your apps will be removed from the store and you will be expelled from the Apple Developer Program.
							
• You are responsible for making sure everything in your app complies with these guidelines, including ad networks, analytics services, and third-party SDKs, so review and choose them carefully.
							
• Some features and technologies that are not generally available to developers may be offered as an entitlement for limited use cases. For example, we offer entitlements for CarPlay Audio, HyperVisor, and Privileged File Operations.

We hope these guidelines help you sail through the review process, and that approvals and rejections remain consistent across the board. This is a living document; new apps presenting new questions may result in new rules at any time. Perhaps your app will trigger this. We love this stuff too, and honor what you do. We’re really trying our best to create the best platform in the world for you to express your talents and make a living, too.

						Before You Submit
						
To help your app approval go as smoothly as possible, review the common missteps listed below that can slow down the review process or trigger a rejection. This doesn’t replace the guidelines or guarantee approval, but making sure you can check every item on the list is a good start. If your app no longer functions as intended or you’re no longer actively supporting it, it will be removed from the App Store. [Learn more about App Store Improvements](/support/app-store-improvements/).
						
Make sure you:

• Test your app for crashes and bugs
							
• Ensure that all app information and metadata is complete and accurate
							
• Update your contact information in case App Review needs to reach you
							
• Provide App Review with full access to your app. If your app includes account-based features, provide either an active demo account or fully-featured demo mode, plus any other hardware or resources that might be needed to review your app (e.g. login credentials or a sample QR code)
							
• Enable backend services so that they’re live and accessible during review
							
• Include detailed explanations of non-obvious features and in-app purchases in the App Review notes, including supporting documentation where appropriate
							
• Check whether your app follows guidance in other documentation, such as:

Developer Documentation

• SwiftUI
								
• UIKit
								
• AppKit
								
• App extensions
								
• Optimizing Your App’s Data for iCloud Backup
								
• Apple File System
								
• [App Store Connect Help](/help/app-store-connect/)
								
• [Developer Account Help](/help/account/)

Design Guidelines

• [Human Interface Guidelines](/design/human-interface-guidelines/)

Brand and Marketing Guidelines

• [Marketing Resources and Identity Guidelines](/app-store/marketing/guidelines/)
								
• [Apple Pay Marketing Guidelines](/apple-pay/marketing/)
								
• [Add to Apple Wallet Guidelines](/wallet/add-to-apple-wallet-guidelines/)
								
• Guidelines for Using Apple Trademarks and Copyrights

Guidelines that include  apply to Notarization for iOS and iPadOS apps in the EU and Notarization for iOS apps in Japan.

						1. Safety
						
When people install an app from the App Store, they want to feel confident that it’s safe to do so—that the app doesn’t contain upsetting or offensive content, won’t damage their device, and isn’t likely to cause physical harm from its use. We’ve outlined the major pitfalls below, but if you’re looking to shock and offend people, the App Store isn’t the right place for your app. Some of these rules are also included in Notarization for iOS and iPadOS apps.

• 1.1 Objectionable Content
								
Apps should not include content that is offensive, insensitive, upsetting, intended to disgust, in exceptionally poor taste, or just plain creepy. Examples of such content include:

• 1.1.1 Defamatory, discriminatory, or mean-spirited content, including references or commentary about religion, race, sexual orientation, gender, national/ethnic origin, or other targeted groups, particularly if the app is likely to humiliate, intimidate, or harm a targeted individual or group. Professional political satirists and humorists are generally exempt from this requirement.
									
• 1.1.2 Realistic portrayals of people or animals being killed, maimed, tortured, or abused, or content that encourages violence. “Enemies” within the context of a game cannot solely target a specific race, culture, real government, corporation, or any other real entity.
									
• 1.1.3 Depictions that encourage illegal or reckless use of weapons and dangerous objects, or facilitate the purchase of firearms or ammunition.
									
• 1.1.4 Overtly sexual or pornographic material, defined as “explicit descriptions or displays of sexual organs or activities intended to stimulate erotic rather than aesthetic or emotional feelings.” This includes “hookup” apps and other apps that may include pornography or be used to facilitate prostitution, or human trafficking and exploitation.
									
• 1.1.5 Inflammatory religious commentary or inaccurate or misleading quotations of religious texts.
									
• 1.1.6 False information and features, including inaccurate device data or trick/joke functionality, such as fake location trackers. Stating that the app is “for entertainment purposes” won’t overcome this guideline. Apps that enable anonymous or prank phone calls or SMS/MMS messaging will be rejected.
									
• 1.1.7 Harmful concepts which capitalize or seek to profit on recent or current events, such as violent conflicts, terrorist attacks, and epidemics.

• 1.2 User-Generated Content
								
Apps with user-generated content present particular challenges, ranging from intellectual property infringement to anonymous bullying. To prevent abuse, apps with user-generated content or social networking services must include:

• A method for filtering objectionable material from being posted to the app
									
• A mechanism to report offensive content and timely responses to concerns
									
• The ability to block abusive users from the service
									
• Published contact information so users can easily reach you

Apps with user-generated content or services that end up being used primarily for pornographic content, Chatroulette-style experiences, random or anonymous chat, objectification of real people (e.g. “hot-or-not” voting), making physical threats, or bullying do not belong on the App Store and may be removed without notice. If your app includes user-generated content from a web-based service, it may display incidental mature “NSFW” content, provided that the content is hidden by default and only displayed when the user turns it on via your website.

• 1.2.1 Creator Content
Apps which feature content from a specific community of users called “creators” are a great opportunity if properly moderated. These apps present a singular, unified experience for customers to interact with various kinds of creator content. They offer tools and programs to help this community of non-developer creators to author, share, and monetize user-generated experiences. These experiences must not change the core features and functionality of the native app—rather, they add content to those structured experiences. These experiences are not native “apps” coded by developers—they are content within the app itself and are treated as user-generated content by App Review. Such creator content may include video, articles, audio, and even casual games. The App Store supports apps offering such user-generated content so long as they follow all Guidelines, including Guideline 1.2 for moderating user-generated content and Guideline 3.1.1 for payments and in-app purchases. You should communicate to users which content requires additional purchases.
									
• 

• (a) Creator apps must provide a way for users to identify content that exceeds the app’s age rating, and use an age restriction mechanism based on verified or declared age to limit access by underage users.

• 1.3 Kids Category
								
The Kids Category is a great way for people to easily find apps that are designed for children. If you want to participate in the Kids Category, you should focus on creating a great experience specifically for younger users. These apps must not include links out of the app, purchasing opportunities, or other distractions to kids unless reserved for a designated area behind a parental gate. Keep in mind that once customers expect your app to follow the Kids Category requirements, it will need to continue to meet these guidelines in subsequent updates, even if you decide to deselect the category. Learn more about [parental gates](/app-store/kids-apps/).
								
You must comply with applicable privacy laws around the world relating to the collection of data from children online. Be sure to review the [Privacy section](#privacy) of these guidelines for more information. In addition, Kids Category apps may not send personally identifiable information or device information to third parties. Apps in the Kids Category should not include third-party analytics or third-party advertising. This provides a safer experience for kids. In limited cases, third-party analytics may be permitted provided that the services do not collect or transmit the IDFA or any identifiable information about children (such as name, date of birth, email address), their location, or their devices. This includes any device, network, or other information that could be used directly or combined with other information to identify users and their devices. Third-party contextual advertising may also be permitted in limited cases provided that the services have publicly documented practices and policies for Kids Category apps that include human review of ad creatives for age appropriateness.

• 1.4 Physical Harm
								
If your app behaves in a way that risks physical harm, we may reject it. For example:

• 1.4.1 Medical apps that could provide inaccurate data or information, or that could be used for diagnosing or treating patients may be reviewed with greater scrutiny.

• Apps must clearly disclose data and methodology to support accuracy claims relating to health measurements, and if the level of accuracy or methodology cannot be validated, we will reject your app. For example, apps that claim to take x-rays, measure blood pressure, body temperature, blood glucose levels, or blood oxygen levels using only the sensors on the device are not permitted.
											
• Apps should remind users to check with a doctor in addition to using the app and before making medical decisions.
										 If your medical app has received regulatory clearance, please submit a link to that documentation with your app.
									
• 1.4.2 Drug dosage calculators must come from the drug manufacturer, a hospital, university, health insurance company, pharmacy or other approved entity, or receive approval by the FDA or one of its international counterparts. Given the potential harm to patients, we need to be sure that the app will be supported and updated over the long term.
									
• 1.4.3 Apps that encourage consumption of tobacco and vape products, illegal drugs, or excessive amounts of alcohol are not permitted. Apps that encourage minors to consume any of these substances will be rejected. Facilitating the sale of controlled substances (except for licensed pharmacies and licensed or otherwise legal cannabis dispensaries), or tobacco is not allowed.
									
• 1.4.4 Apps may only display DUI checkpoints that are published by law enforcement agencies, and should never encourage drunk driving or other reckless behavior such as excessive speed.
									
• 1.4.5 Apps should not urge customers to participate in activities (like bets, challenges, etc.) or use their devices in a way that risks physical harm to themselves or others.

• 1.5 Developer Information
								
People need to know how to reach you with questions and support issues. Make sure your app and its Support URL include an easy way to contact you; this is particularly important for apps that may be used in the classroom. Failure to include accurate and up-to-date contact information not only frustrates customers, but may violate the law in some countries or regions. Also ensure that Wallet passes include valid contact information from the issuer and are signed with a dedicated certificate assigned to the brand or trademark owner of the pass.

• 1.6 Data Security
								
Apps should implement appropriate security measures to ensure proper handling of user information collected pursuant to the Apple Developer Program License Agreement and these Guidelines (see Guideline 5.1 for more information) and prevent its unauthorized use, disclosure, or access by third parties.

• 1.7 Reporting Criminal Activity
								
Apps for reporting alleged criminal activity must involve local law enforcement, and can only be offered in countries or regions where such involvement is active.

						2. Performance

• 2.1 App Completeness

• (a) Submissions to App Review, including apps you make available for pre-order, should be final versions with all necessary metadata and fully functional URLs included; placeholder text, empty websites, and other temporary content should be scrubbed before submission. Make sure your app has been tested on-device for bugs and stability before you submit it, and include demo account info (and turn on your back-end service!) if your app includes a login. If you are unable to provide a demo account due to legal or security obligations, you may include a built-in demo mode in lieu of a demo account with prior approval by Apple. Ensure the demo mode exhibits your app’s full features and functionality. We will reject incomplete app bundles and binaries that crash or exhibit obvious technical problems.
									
• (b) If you offer in-app purchases in your app, make sure they are complete, up-to-date, visible to the reviewer and functional. If any configured in-app purchase items cannot be found or reviewed in your app, explain the reason in your review notes.

• 2.2 Beta Testing
								
Demos, betas, and trial versions of your app don’t belong on the App Store – use TestFlight instead. Any app submitted for beta distribution via TestFlight should be intended for public distribution and should comply with the App Review Guidelines. Note, however, that apps using TestFlight cannot be distributed to testers in exchange for compensation of any kind, including as a reward for crowd-sourced funding. Significant updates to your beta build should be submitted to TestFlight App Review before being distributed to your testers. To learn more, visit the [TestFlight Beta Testing](/testflight/) page.

• 2.3 Accurate Metadata
								
Customers should know what they’re getting when they download or buy your app, so make sure all your app metadata, including privacy information, your app description, screenshots, and previews accurately reflect the app’s core experience and remember to keep them up-to-date with new versions.

• 2.3.1

• (a) Don’t include any hidden, dormant, or undocumented features in your app; your app’s functionality should be clear to end users and App Review. All new features, functionality, and produc

... [truncated]


>>>TOOL web_fetch
{"url":"https://developer.apple.com/app-store/review/guidelines/#software-requirements","max_length":50000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://developer.apple.com/app-store/review/guidelines/#software-requirements

• 

• 

• 

• 

• 

• 

• 

• 

• 

• 
	App Review Guidelines - Apple Developer

• 
	
• 

• 
	
• 
	
• 
	
• 
	
• 

• 

• 

[View in English](#)

• 

					Global Nav Open Menu

					Global Nav Close Menu

• 
				
					Apple Developer

								Search

							Cancel

• 
				
					Apple Developer

• 
				
					News

• 
				
					Discover

• 
				
					Design

• 
				
					Develop

• 
				
					Distribute

• 
				
					Support

• 
				
					Account

• 
				[](/search/)

									Cancel

							Only search within “”
                            Quick Links

                            5 Quick Links

• 

• 

				[App Review](/distribute/app-review/)

					Open Menu

					Close Menu

• 
							[Overview](/distribute/app-review/)

• 
							[App Review Guidelines](/app-store/review/guidelines/)

# App Review Guidelines

Apps are changing the world, enriching people’s lives, and enabling developers like you to innovate like never before. As a result, the App Store has grown into an exciting and vibrant ecosystem for millions of developers and more than a billion users. Whether you are a first-time developer or a large team of experienced programmers, we are excited that you are creating apps for our platforms, and want to help you understand our guidelines so you can be confident your app will get through the review process quickly.

								Highlight Notarization Review Guidelines Only

						Introduction
						
The guiding principle of the App Store is simple—we want to provide a safe experience for users to get apps and a great opportunity for all developers to be successful. We do this by offering a highly curated App Store where every app is reviewed by experts and an editorial team helps users discover new apps every day. We also scan each app for malware and other software that may impact user safety, security, and privacy. These efforts have made Apple’s platforms the safest for consumers around the world.

In the European Union, developers can also distribute notarized iOS and iPadOS apps from alternative app marketplaces and directly from their website; in Japan, developers can also distribute iOS apps from alternative app marketplaces. Learn more about [alternative app marketplaces](/help/app-store-connect/distributing-apps-in-the-european-union/manage-distribution-on-an-alternative-app-marketplace), [Web Distribution](/support/web-distribution-eu/), and [Notarization for iOS and iPadOS apps](/help/app-store-connect/managing-alternative-distribution/submit-for-notarization). You can see which guidelines apply to Notarization for iOS and iPadOS apps by clicking on “Highlight Notarization Review Guidelines Only” in the menu to the left.

For everything else there is always the open Internet. If the App Store model and guidelines or alternative distribution and Notarization for iOS and iPadOS apps are not best for your app or business idea that’s okay, we provide Safari for a great web experience too.

On the following pages you will find our latest guidelines arranged into five clear sections: Safety, Performance, Business, Design, and Legal. The App Store is always changing and improving to keep up with the needs of our customers and our products. Your apps should change and improve as well in order to stay on the App Store.
						
A few other points to keep in mind about distributing your app on our platforms:

• We have lots of kids downloading lots of apps. Parental controls work great to protect kids, but you have to do your part too. So know that we’re keeping an eye out for the kids.
							
• The App Store is a great way to reach hundreds of millions of people around the world. If you build an app that you just want to show to family and friends, the App Store isn’t the best way to do that. Consider using Xcode to install your app on a device for free or use Ad Hoc distribution available to Apple Developer Program members. If you’re just getting started, learn more about the [Apple Developer Program](/programs/).
							
• We strongly support all points of view being represented on the App Store, as long as the apps are respectful to users with differing opinions and the quality of the app experience is great. We will reject apps for any content or behavior that we believe is over the line. What line, you ask? Well, as a Supreme Court Justice once said, “I’ll know it when I see it”. And we think that you will also know it when you cross it.
							
• If you attempt to cheat the system (for example, by trying to trick the review process, steal user data, copy another developer’s work, manipulate ratings or App Store discovery) your apps will be removed from the store and you will be expelled from the Apple Developer Program.
							
• You are responsible for making sure everything in your app complies with these guidelines, including ad networks, analytics services, and third-party SDKs, so review and choose them carefully.
							
• Some features and technologies that are not generally available to developers may be offered as an entitlement for limited use cases. For example, we offer entitlements for CarPlay Audio, HyperVisor, and Privileged File Operations.

We hope these guidelines help you sail through the review process, and that approvals and rejections remain consistent across the board. This is a living document; new apps presenting new questions may result in new rules at any time. Perhaps your app will trigger this. We love this stuff too, and honor what you do. We’re really trying our best to create the best platform in the world for you to express your talents and make a living, too.

						Before You Submit
						
To help your app approval go as smoothly as possible, review the common missteps listed below that can slow down the review process or trigger a rejection. This doesn’t replace the guidelines or guarantee approval, but making sure you can check every item on the list is a good start. If your app no longer functions as intended or you’re no longer actively supporting it, it will be removed from the App Store. [Learn more about App Store Improvements](/support/app-store-improvements/).
						
Make sure you:

• Test your app for crashes and bugs
							
• Ensure that all app information and metadata is complete and accurate
							
• Update your contact information in case App Review needs to reach you
							
• Provide App Review with full access to your app. If your app includes account-based features, provide either an active demo account or fully-featured demo mode, plus any other hardware or resources that might be needed to review your app (e.g. login credentials or a sample QR code)
							
• Enable backend services so that they’re live and accessible during review
							
• Include detailed explanations of non-obvious features and in-app purchases in the App Review notes, including supporting documentation where appropriate
							
• Check whether your app follows guidance in other documentation, such as:

Developer Documentation

• SwiftUI
								
• UIKit
								
• AppKit
								
• App extensions
								
• Optimizing Your App’s Data for iCloud Backup
								
• Apple File System
								
• [App Store Connect Help](/help/app-store-connect/)
								
• [Developer Account Help](/help/account/)

Design Guidelines

• [Human Interface Guidelines](/design/human-interface-guidelines/)

Brand and Marketing Guidelines

• [Marketing Resources and Identity Guidelines](/app-store/marketing/guidelines/)
								
• [Apple Pay Marketing Guidelines](/apple-pay/marketing/)
								
• [Add to Apple Wallet Guidelines](/wallet/add-to-apple-wallet-guidelines/)
								
• Guidelines for Using Apple Trademarks and Copyrights

Guidelines that include  apply to Notarization for iOS and iPadOS apps in the EU and Notarization for iOS apps in Japan.

						1. Safety
						
When people install an app from the App Store, they want to feel confident that it’s safe to do so—that the app doesn’t contain upsetting or offensive content, won’t damage their device, and isn’t likely to cause physical harm from its use. We’ve outlined the major pitfalls below, but if you’re looking to shock and offend people, the App Store isn’t the right place for your app. Some of these rules are also included in Notarization for iOS and iPadOS apps.

• 1.1 Objectionable Content
								
Apps should not include content that is offensive, insensitive, upsetting, intended to disgust, in exceptionally poor taste, or just plain creepy. Examples of such content include:

• 1.1.1 Defamatory, discriminatory, or mean-spirited content, including references or commentary about religion, race, sexual orientation, gender, national/ethnic origin, or other targeted groups, particularly if the app is likely to humiliate, intimidate, or harm a targeted individual or group. Professional political satirists and humorists are generally exempt from this requirement.
									
• 1.1.2 Realistic portrayals of people or animals being killed, maimed, tortured, or abused, or content that encourages violence. “Enemies” within the context of a game cannot solely target a specific race, culture, real government, corporation, or any other real entity.
									
• 1.1.3 Depictions that encourage illegal or reckless use of weapons and dangerous objects, or facilitate the purchase of firearms or ammunition.
									
• 1.1.4 Overtly sexual or pornographic material, defined as “explicit descriptions or displays of sexual organs or activities intended to stimulate erotic rather than aesthetic or emotional feelings.” This includes “hookup” apps and other apps that may include pornography or be used to facilitate prostitution, or human trafficking and exploitation.
									
• 1.1.5 Inflammatory religious commentary or inaccurate or misleading quotations of religious texts.
									
• 1.1.6 False information and features, including inaccurate device data or trick/joke functionality, such as fake location trackers. Stating that the app is “for entertainment purposes” won’t overcome this guideline. Apps that enable anonymous or prank phone calls or SMS/MMS messaging will be rejected.
									
• 1.1.7 Harmful concepts which capitalize or seek to profit on recent or current events, such as violent conflicts, terrorist attacks, and epidemics.

• 1.2 User-Generated Content
								
Apps with user-generated content present particular challenges, ranging from intellectual property infringement to anonymous bullying. To prevent abuse, apps with user-generated content or social networking services must include:

• A method for filtering objectionable material from being posted to the app
									
• A mechanism to report offensive content and timely responses to concerns
									
• The ability to block abusive users from the service
									
• Published contact information so users can easily reach you

Apps with user-generated content or services that end up being used primarily for pornographic content, Chatroulette-style experiences, random or anonymous chat, objectification of real people (e.g. “hot-or-not” voting), making physical threats, or bullying do not belong on the App Store and may be removed without notice. If your app includes user-generated content from a web-based service, it may display incidental mature “NSFW” content, provided that the content is hidden by default and only displayed when the user turns it on via your website.

• 1.2.1 Creator Content
Apps which feature content from a specific community of users called “creators” are a great opportunity if properly moderated. These apps present a singular, unified experience for customers to interact with various kinds of creator content. They offer tools and programs to help this community of non-developer creators to author, share, and monetize user-generated experiences. These experiences must not change the core features and functionality of the native app—rather, they add content to those structured experiences. These experiences are not native “apps” coded by developers—they are content within the app itself and are treated as user-generated content by App Review. Such creator content may include video, articles, audio, and even casual games. The App Store supports apps offering such user-generated content so long as they follow all Guidelines, including Guideline 1.2 for moderating user-generated content and Guideline 3.1.1 for payments and in-app purchases. You should communicate to users which content requires additional purchases.
									
• 

• (a) Creator apps must provide a way for users to identify content that exceeds the app’s age rating, and use an age restriction mechanism based on verified or declared age to limit access by underage users.

• 1.3 Kids Category
								
The Kids Category is a great way for people to easily find apps that are designed for children. If you want to participate in the Kids Category, you should focus on creating a great experience specifically for younger users. These apps must not include links out of the app, purchasing opportunities, or other distractions to kids unless reserved for a designated area behind a parental gate. Keep in mind that once customers expect your app to follow the Kids Category requirements, it will need to continue to meet these guidelines in subsequent updates, even if you decide to deselect the category. Learn more about [parental gates](/app-store/kids-apps/).
								
You must comply with applicable privacy laws around the world relating to the collection of data from children online. Be sure to review the [Privacy section](#privacy) of these guidelines for more information. In addition, Kids Category apps may not send personally identifiable information or device information to third parties. Apps in the Kids Category should not include third-party analytics or third-party advertising. This provides a safer experience for kids. In limited cases, third-party analytics may be permitted provided that the services do not collect or transmit the IDFA or any identifiable information about children (such as name, date of birth, email address), their location, or their devices. This includes any device, network, or other information that could be used directly or combined with other information to identify users and their devices. Third-party contextual advertising may also be permitted in limited cases provided that the services have publicly documented practices and policies for Kids Category apps that include human review of ad creatives for age appropriateness.

• 1.4 Physical Harm
								
If your app behaves in a way that risks physical harm, we may reject it. For example:

• 1.4.1 Medical apps that could provide inaccurate data or information, or that could be used for diagnosing or treating patients may be reviewed with greater scrutiny.

• Apps must clearly disclose data and methodology to support accuracy claims relating to health measurements, and if the level of accuracy or methodology cannot be validated, we will reject your app. For example, apps that claim to take x-rays, measure blood pressure, body temperature, blood glucose levels, or blood oxygen levels using only the sensors on the device are not permitted.
											
• Apps should remind users to check with a doctor in addition to using the app and before making medical decisions.
										 If your medical app has received regulatory clearance, please submit a link to that documentation with your app.
									
• 1.4.2 Drug dosage calculators must come from the drug manufacturer, a hospital, university, health insurance company, pharmacy or other approved entity, or receive approval by the FDA or one of its international counterparts. Given the potential harm to patients, we need to be sure that the app will be supported and updated over the long term.
									
• 1.4.3 Apps that encourage consumption of tobacco and vape products, illegal drugs, or excessive amounts of alcohol are not permitted. Apps that encourage minors to consume any of these substances will be rejected. Facilitating the sale of controlled substances (except for licensed pharmacies and licensed or otherwise legal cannabis dispensaries), or tobacco is not allowed.
									
• 1.4.4 Apps may only display DUI checkpoints that are published by law enforcement agencies, and should never encourage drunk driving or other reckless behavior such as excessive speed.
									
• 1.4.5 Apps should not urge customers to participate in activities (like bets, challenges, etc.) or use their devices in a way that risks physical harm to themselves or others.

• 1.5 Developer Information
								
People need to know how to reach you with questions and support issues. Make sure your app and its Support URL include an easy way to contact you; this is particularly important for apps that may be used in the classroom. Failure to include accurate and up-to-date contact information not only frustrates customers, but may violate the law in some countries or regions. Also ensure that Wallet passes include valid contact information from the issuer and are signed with a dedicated certificate assigned to the brand or trademark owner of the pass.

• 1.6 Data Security
								
Apps should implement appropriate security measures to ensure proper handling of user information collected pursuant to the Apple Developer Program License Agreement and these Guidelines (see Guideline 5.1 for more information) and prevent its unauthorized use, disclosure, or access by third parties.

• 1.7 Reporting Criminal Activity
								
Apps for reporting alleged criminal activity must involve local law enforcement, and can only be offered in countries or regions where such involvement is active.

						2. Performance

• 2.1 App Completeness

• (a) Submissions to App Review, including apps you make available for pre-order, should be final versions with all necessary metadata and fully functional URLs included; placeholder text, empty websites, and other temporary content should be scrubbed before submission. Make sure your app has been tested on-device for bugs and stability before you submit it, and include demo account info (and turn on your back-end service!) if your app includes a login. If you are unable to provide a demo account due to legal or security obligations, you may include a built-in demo mode in lieu of a demo account with prior approval by Apple. Ensure the demo mode exhibits your app’s full features and functionality. We will reject incomplete app bundles and binaries that crash or exhibit obvious technical problems.
									
• (b) If you offer in-app purchases in your app, make sure they are complete, up-to-date, visible to the reviewer and functional. If any configured in-app purchase items cannot be found or reviewed in your app, explain the reason in your review notes.

• 2.2 Beta Testing
								
Demos, betas, and trial versions of your app don’t belong on the App Store – use TestFlight instead. Any app submitted for beta distribution via TestFlight should be intended for public distribution and should comply with the App Review Guidelines. Note, however, that apps using TestFlight cannot be distributed to testers in exchange for compensation of any kind, including as a reward for crowd-sourced funding. Significant updates to your beta build should be submitted to TestFlight App Review before being distributed to your testers. To learn more, visit the [TestFlight Beta Testing](/testflight/) page.

• 2.3 Accurate Metadata
								
Customers should know what they’re getting when they download or buy your app, so make sure all your app metadata, including privacy information, your app description, screenshots, and previews accurately reflect the app’s core experience and remember to keep them up-to-date with new versions.

• 2.3.1

• (a) Don’t include any hidden, dormant, or undocumented features in your app; your app’s functionality should be clear to end users and App Review. All new features, functionality, and product changes must be described with specificity in the Notes for Review section of App Store Connect (generic descriptions will be rejected) and accessible for review. Similarly, marketing your app in a misleading way, such as by promoting content or services that it does not actually offer (e.g. iOS-based virus and malware scanners) or promoting a false price, whether within or outside of the App Store, is grounds for removal of your app from the App Store or a block from installing via alternative distribution and termination of your developer account.
											
• (b) Egregious or repeated behavior is grounds for removal from the Apple Developer Program. We work hard to make the App Store a trustworthy ecosystem and expect our app developers to follow suit; if you’re dishonest, we don’t want to do business with you.

• 2.3.2 If your app includes in-app purchases, make sure your app description, screenshots, and previews clearly indicate whether any featured items, levels, subscriptions, etc. require additional purchases. If you decide to promote in-app purchases on the App Store, ensure that the in-app purchase Display Name, Screenshot and Description are appropriate for a public audience, that you follow the guidance found in [Promoting Your In-App Purchases](/app-store/promoting-in-app-purchases/), and that your app properly handles the SKPaymentTransactionObserver method so that customers can seamlessly complete the purchase when your app launches.
									
• 2.3.3 Screenshots should show the app in use, and not merely the title art, login page, or splash screen. They may also include text and image overlays (e.g. to demonstrate input mechanisms, such as an animated touch point or Apple Pencil) and show extended functionality on device, such as Touch Bar.
									
• 2.3.4 Previews are a great way for customers to see what your app looks like and what it does. To ensure people understand what they’ll be getting with your app, previews may only use video screen captures of the app itself. Stickers and iMessage extensions may show the user experience in the Messages app. You can add narration and video or textual overlays to help explain anything that isn’t clear from the video alone.
									
• 2.3.5 Select the most appropriate category for your app, and check out the [App Store Category Definitions](/app-store/categories/) if you need help. If you’re way off base, we may change the category for you.
									
• 2.3.6 Answer the age rating questions in App Store Connect honestly so that your app aligns properly with parental controls. If your app is mis-rated, customers might be surprised by what they get, or it could trigger an inquiry from government regulators. If your app includes media that requires the display of content ratings or warnings (e.g. films, music, games, etc.), you are responsible for complying with local requirements in each territory where your app is available.
									
• 2.3.7 Choose a unique app name, assign keywords that accurately describe your app, and don’t try to pack any of your metadata with trademarked terms, popular app names, pricing information, or other irrelevant phrases just to game the system. App names must be limited to 30 characters. Metadata such as app names, subtitles, screenshots, and previews should not include prices, terms, or descriptions that are not specific to the metadata type. App subtitles are a great way to provide additional context for your app; they must follow our standard metadata rules and should not include inappropriate content, reference other apps, or make unverifiable product claims. Apple may modify inappropriate keywords at any time or take other appropriate steps to prevent abuse.
									
• 2.3.8 Metadata should be appropriate for all audiences, so make sure your app and in-app purchase icons, screenshots, and previews adhere to a 4+ age rating even if your app is rated higher. For example, if your app is a game that includes violence, select images that don’t depict a gruesome death or a gun pointed at a specific character. Use of terms like “For Kids” and “For Children” in app metadata is reserved in the App Store for the Kids Category. Remember to ensure your metadata, including app name and icons (small, large, Apple Watch app, alternate icons, etc.), are similar to avoid creating confusion.
									
• 2.3.9 You are responsible for securing the rights to use all materials in your app icons, screenshots, and previews, and you should display fictional account information instead of data from a real person.
									
• 2.3.10 Make sure your app is focused on the experience of the Apple platforms it supports, and don’t include names, icons, or imagery of other mobile platforms or alternative app marketplaces in your app or metadata, unless there is specific, approved interactive functionality. Make sure your app metadata is focused on the app itself and its experience. Don’t include irrelevant information.
									
• 2.3.11 Apps you submit for pre-order on the App Store must be complete and deliverable as submitted. Ensure that the app you ultimately release is not materially different from what you advertise while the app is in a pre-order state. If you make material changes to the app (e.g. change business models), you should restart your pre-order sales.
									
• 2.3.12 Apps must clearly describe new features and product changes in their “What’s New” text. Simple bug fixes, security updates, and performance improvements may rely on a generic description, but more significant changes must be listed in the notes.
									
• 2.3.13 In-app events are timely events that happen within your app. To feature your event on the App Store, it must fall within an event type provided in App Store Connect. All event metadata must be accurate and pertain to the event itself, rather than the app more generally. Events must happen at the times and dates you select in App Store Connect, including across multiple storefronts. You may monetize your event so long as you follow the rules set forth in Section 3 on Business. And your event deep link must direct users to the proper destination within your app. Read [In-App Events](/app-store/in-app-events/) for detailed guidance on acceptable event metadata and event deep links.

• 2.4 Hardware Compatibility

• 2.4.1 To ensure people get the most out of your app, iPhone apps should run on iPad whenever possible. We encourage you to consider building apps so customers can use them on all of their devices.
									
• 2.4.2 Design your app to use power efficiently and be used in a way that does not risk damage to the device. Apps should not rapidly drain battery, generate excessive heat, or put unnecessary strain on device resources. For example, apps should not encourage placing the device under a mattress or pillow while charging or perform excessive write cycles to the solid state drive. Apps, including any third-party advertisements displayed within them, may not run unrelated background processes, such as cryptocurrency mining.
									
• 2.4.3 People should be able to use your Apple TV app without the need for hardware inputs beyond the Siri remote or third-party game controllers, but feel free to provide enhanced functionality when other peripherals are connected. If you require a game controller, make sure you clearly explain that in your metadata so customers know they need additional equipment to play.
									
• 2.4.4 Apps should never suggest or require a restart of the device or modifications to system settings unrelated to the core functionality of the app. For example, don’t encourage users to turn off Wi-Fi, disable security features, etc.
									
• 2.4.5 Apps distributed via the Mac App Store have some additional requirements to keep in mind:

• (i) They must be appropriately sandboxed, and follow macOS File System Documentation. They should also only use the appropriate macOS APIs for modifying user data stored by other apps (e.g. bookmarks, Address Book, or Calendar entries).
											
• (ii) They must be packaged and submitted using technologies provided in Xcode; no third-party installers allowed. They must also be self-contained, single app installation bundles and cannot install code or resources in shared locations.
											
• (iii) They may not auto-launch or have other code run automatically at startup or login without consent nor spawn processes that continue to run without consent after a user has quit the app. They should not automatically add their icons to the Dock or leave shortcuts on the user desktop.
											
• (iv) They may not download or install standalone apps, kexts, additional code, or resources to add functionality or significantly change the app from what we see during the review process.
											
• (v) They may not request escalation to root privileges or use setuid attributes.
											
• (vi) They may not present a license screen at launch, require license keys, or implement their own copy protection.
											
• (vii) They must use the Mac App Store to distribute updates; other update mechanisms are not allowed.
											
• (viii) Apps should run on the currently shipping OS and may not use deprecated or optionally installed technologies (e.g. Java)
											
• (ix) Apps must contain all language and localization support in a single app bundle.

• 2.5 Software Requirements

• 2.5.1 Apps may only use public APIs and must run on the currently shipping OS. Learn more about public APIs. Keep your apps up-to-date and make sure you phase out any deprecated features, frameworks or technologies that will no longer be supported in future versions of an OS. Apps should use APIs and frameworks for their intended purposes and indicate that integration in their app description. For example, the HomeKit framework should provide home automation services; and HealthKit should be used for health and fitness purposes and integrate with the Health app.
									
• 2.5.2 Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps. Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code provided that such code is not used for other purposes. Such apps must make the source code provided by the app completely viewable and editable by the user.
									
• 2.5.3 Apps that transmit viruses, files, computer code, or programs that may harm or disrupt the normal operation of the operating system and/or hardware features, including Push Notifications and Game Center, will be rejected. Egregious violations and repeat behavior will result in removal from the Apple Developer Program.
									
• 2.5.4 Multitasking apps may only use background services for their intended purposes: VoIP, audio playback, location, task completion, local notifications, etc.
									
• 2.5.5 Apps must be fully functional on IPv6-only networks.
									
• 2.5.6 Apps that browse the web must use the appropriate WebKit framework and WebKit JavaScript. You may apply for an entitlement to use an alternative web browser engine in your app. Learn more about these entitlements.
									
• 2.5.7 Intentionally omitted.
									
• 2.5.8 Apps that create alternate desktop/home screen environments will be rejected.
									
• 2.5.9 Apps that alter or disable the functions of standard switches, such as the Volume Up/Down and Ring/Silent switches, or other native user interface elements or behaviors will be rejected. For example, apps should not block links out to other apps or other features that users would expect to work a certain way.
									
• 2.5.10 Intentionally omitted.
									
• 2.5.11 SiriKit and Shortcuts

• (i) Apps integrating SiriKit and Shortcuts should only sign up for intents they can handle without the support of an additional app and that users would expect from the stated functionality. For example, if your app is a meal planning app, you should not incorporate an intent to start a workout, even if the app shares integration with a fitness app.
											
• (ii) Ensure that the vocabulary and phrases in your plist pertains to your app and the Siri functionality of the intents the app has registered for. Aliases must relate directly to your app or company name and should not be generic terms or include third-party app names or services.
											
• (iii) Resolve the Siri request or Shortcut in the most direct way possible and do not insert ads or other marketing between the request and its fulfillment. Only request a disambiguation when required to complete the task (e.g. asking the user to specify a particular type of workout).

• 2.5.12 Apps using CallKit or including an SMS Fraud Extension should only block phone numbers that are confirmed spam. Apps that include call-, SMS-, and MMS- blocking functionality or spam identification must clearly identify these features in their marketing text and explain the criteria for their blocked and spam lists. You may not use the data accessed via these tools for any purpose not directly related to operating or improving your app or extension (e.g. you may not use, share, or sell it for tracking purposes, creating user profiles, etc.).
									
• 2.5.13 Apps using facial recognition for account authentication must use LocalAuthentication (and not ARKit or other facial recognition technology) where possible, and must use an alternate authentication method for users under 13 years old.
									
• 2.5.14 Apps must request explicit user consent and provide a clear visual and/or audible indication when recording, logging, or otherwise making a record of user activity. This includes any use of the device camera, microphone, screen recordings, or other user inputs.
									
• 2.5.15 Apps that enable users to view and select files should include items from the Files app and the user’s iCloud documents.
									
• 2.5.16 Widgets, extensions, and notifications should be related to the content and functionality of your app.

• (a) Additionally, all App Clip features and functionality must be included in the main app binary. App Clips cannot contain advertising.

• 2.5.17 Apps that support Matter must use Apple’s support framework for Matter to initiate pairing. In addition, if you choose to use any Matter software component in your app other than the Matter SDK provided by Apple, the software component must be certified by the Connectivity Standards Alliance for the platform it runs on.
									
• 2.5.18 Display advertising should be limited to your main app binary, and should not be included in extensions, App Clips, widgets, notifications, keyboards, watchOS apps, etc. Ads displayed in an app must be appropriate for the app’s age rating, allow the user to see all information used to target them for that ad (without requiring the user to leave the app), and may not engage in targeted or behavioral advertising based on sensitive user data such as health/medical data (e.g. from the HealthKit APIs), school and classroom data (e.g. from ClassKit), or from kids (e.g. from apps in the App Store’s Kids Category), etc. Interstitial ads or ads that interrupt or block the user experience must clearly indicate that they are an ad, must not manipulate or trick users into tapping into them, and must provide easily accessible and visible close/skip buttons large enough for people to easily dismiss the ad. Apps that contain ads must also include the ability for users to report any inappropriate or age-inappropriate ads.

						3. Business
						
There are many ways to monetize your app on the App Store. If your business model isn’t obvious, make sure to explain in its metadata and App Review notes. If we can’t understand how your app works or your in-app purchases aren’t immediately obvious, it will delay your review and may trigger a rejection. And while pricing is up to you, we won’t distribute apps and in-app purchase items that are clear rip-offs. We’ll reject expensive apps that try to cheat users with irrationally high prices.
						
If we find that you have attempted to manipulate reviews, inflate your chart rankings with paid, incentivized, filtered, or fake feedback, or engage with third-party services to do so on your behalf, we will take steps to preserve the integrity of the App Store, which may include expelling you from the Apple Developer Program.

• 3.1 Payments

• 3.1.1 In-App Purchase:

• If you want to unlock features or functionality within your app, (by way of example: subscriptions, in-game currencies, game levels, access to premium content, or unlocking a full version), you must use in-app purchase. Apps may not use their own mechanisms to unlock content or functionality, such as license keys, augmented reality markers, QR codes, cryptocurrencies and cryptocurrency wallets, etc.
											
• Apps may use in-app purchase currencies to enable customers to “tip” the developer or digital content providers in the app.
											
• Any credits or in-game currencies purchased via in-app purchase may not expire, and you should make sure you have a restore mechanism for any restorable in-app purchases.
											
• Apps may enable gifting of items that are eligible for in-app purchase to others. Such gifts may only be refunded to the original purchaser and may not be exchanged.
											
• Apps distributed via the Mac App Store may host plug-ins or extensions that are enabled with mechanisms other than the App Store.
											
• Apps offering “loot boxes” or other mechanisms that provide randomized virtual items for purchase must disclose the odds of receiving each type of item to customers prior to purchase.
											
• Digital gift cards, certificates, vouchers, and coupons which can be redeemed for digital goods or services can only be sold in your app using in-app purchase. Physical gift cards that are sold within an app and then mailed to customers may use payment methods other than in-app purchase.
											
• Non-subscription apps may offer a free time-based trial period before presenting a full unlock option by setting up a Non-Consumable IAP item at Price Tier 0 that follows the naming convention: “XX-day Trial.” Prior to the start of the trial, your app must clearly identify its duration, the content or services that will no longer be accessible when the trial ends, and any downstream charges the user would need to pay for full functionality. Learn more about managing content access and the duration of the trial period using Receipts and DeviceCheck.
											
• Apps may use in-app purchase to sell and sell services related to non-fungible tokens (NFTs), such as minting, listing, and transferring. Apps may allow users to view their own NFTs, provided that NFT ownership does not unlock features or functionality within the app. Apps may allow users to browse NFT collections owned by others, provided that, except for apps on the United States storefront, the apps may not include buttons, external links, or other calls to action that direct customers to purchasing mechanisms other than in-app purchase.

• 3.1.1(a) Link to Other Purchase Methods: Developers may apply for entitlements to provide a link in their app to a website the developer owns or maintains responsibility for in order to purchase digital content or services. These entitlements are not required for developers to include buttons, external links, or other calls to action in their United States storefront apps. Please see additional details below.

• StoreKit External Purchase Link Entitlements: apps on the App Store in specific regions may offer in-app purchases and also use a StoreKit External Purchase Link Entitlement to include a link to the developer’s website that informs users of other ways to purchase digital goods or services. Learn more about these entitlements. In accordance with the entitlement agreements, the link may inform users about where and how to purchase those in-app purchase items, and the fact that such items may be available for a comparatively lower price. The entitlements are limited to use only in the iOS or iPadOS App Store in specific storefronts. In all other storefronts, except for the United States storefront, where this prohibition does not apply, apps and their metadata may not include buttons, external links, or other calls to action that direct customers to purchasing mechanisms other than in-app purchase.
											
• Music Streaming Services Entitlements: music streaming apps in specific regions can use Music Streaming Services Entitlements to include a link (which may take the form of a buy button) to the developer’s website that informs users of other ways to purchase digital music content or services. These entitlements also permit music streaming app developers to invite users to provide their email address for the express purpose of sending them a link to the developer’s website to purchase digital music content or services. Learn more about these entitlements. In accordance with the entitlement agreements, the link may inform users about where and how to purchase those in-app purchase items, and the price of such items. The entitlements are limited to use only in the iOS or iPadOS App Store in specific storefronts. In all other storefronts, streaming music apps and their metadata may not include buttons, external links, or other calls to action that direct customers to purchasing mechanisms other than in-app purchase.
											
• If your app engages in misleading marketing practices, scams, or fraud in relation to the entitlement, your app will be removed from the App Store and you may be removed from the Apple Developer Program.

• 3.1.2 Subscriptions: Apps may offer auto-renewable in-app purchase subscriptions, regardless of category on the App Store. When incorporating auto-renewable subscriptions into your app, be sure to follow the guidelines below.
									
• 3.1.2(a) Permissible uses: If you offer an auto-renewable subscription, you must provide ongoing value to the customer, and the subscription period must last at least seven days and be available across all of the user’s devices. While the following list is not exhaustive, examples of appropriate subscriptions include: new game levels; episodic content; multiplayer support; apps that offer consistent, substantive updates; access to large collections of, or continually updated, media content; software as a service (“SAAS”); and cloud support. In addition: 

• Subscriptions may be offered alongside à la carte offerings (e.g. you may offer a subscription to an entire library of films as well the purchase or rental of a single movie).
											
• Games offered in a streaming game service subscription may offer a single subscription that is shared across third-party apps and services; however, they must be downloaded directly from the App Store, must be designed to avoid duplicate payment by a subscriber, and should not disadvantage non-subscriber customers.
											
• Subscriptions must work on all of the user’s devices where the app is available. Learn more about sharing a subscription across your apps. 
											
• As with all apps, those offering subscriptions should allow a user to get what they’ve paid for without performing additional tasks, such as posting on social media, uploading contacts, checking in to the app a certain number of times, etc.
											
• Subscriptions may include consumable credits, gems, in-game currencies, etc., and you may offer subscriptions that include access to discounted consumable goods (e.g. a platinum membership that exposes gem-packs for a reduced price).
											
• If you are changing your existing app to a subscription-based business model, you should not take away the primary functionality existing users have already paid for. For example, let customers who have already purchased a “full game unlock” continue to access the full game after you introduce a subscription model for new customers.
											
• Auto-renewable subscription apps may offer a free trial period to customers by providing the relevant information set forth in App Store Connect. [Learn more about providing subscription offers.](/app-store/subscriptions/#providing-subscription-offers)
											
• Apps that attempt to scam users will be removed from the App Store. This includes apps that attempt to trick users into purchasing a subscription under false pretenses or engage in bait-and-switch and scam practices; these will be removed from the App Store and you may be removed from the Apple Developer Program.
											
• Cellular carrier apps may include auto-renewable music and video subscriptions when purchased in bundles with new cellular data plans, with prior approval by Apple. Other auto-renewable subscriptions may also be included in bundles when purchased with new cellular data plans, with prior approval by Apple, if the cellular carrier apps support in-app purchase for users. Such subscriptions cannot include access to or discounts on consumable items, and the subscriptions must terminate coincident with the cellular data plan.

• 3.1.2(b) Upgrades and Downgrades: Users should have a seamless upgrade/downgrade experience and should not be able to inadvertently subscribe to multiple variations of the same thing. Review [best practices](/app-store/subscriptions/) on managing your subscription upgrade and downgrade options.
									
• 3.1.2(c) Subscription Information: Before asking a customer to subscribe, you should clearly describe what the user will get for the price. How many issues per month? How much cloud storage? What kind of access to your service? Ensure you clearly communicate the requirements described in [Schedule 2 of the Apple Developer Program License Agreement](https://developer.apple.com/support/terms/apple-developer-program-license-agreement/#S2).
									
• 3.1.3 Other Purchase Methods: The following apps may use purchase methods other than in-app purchase. Apps in this section cannot, within the app, encourage users to use a purchasing method other than in-app purchase, except for apps on the United States storefront and as set forth in 3.1.1(a) and 3.1.3(a). Developers can send communications outside of the app to their user base about purchasing methods other than in-app purchase.
									
• 3.1.3(a) “Reader” Apps: Apps may allow a user to access previously purchased content or content subscriptions (specifically: magazines, newspapers, books, audio, music, and video). Reader apps may offer account creation for free tiers, and account management functionality for existing customers. Reader app developers may apply for the External Link Account Entitlement to provide an informational link in their app to a web site the developer owns or maintains responsibility for in order to create or manage an account. This entitlement is not required for developers to include buttons, external links, or other calls to action in their United States storefront apps. Learn more about the [External Link Account Entitlement](/support/reader-apps/).
									
• 3.1.3(b) Multiplatform Services: Apps that operate across multiple platforms may allow users to access content, subscriptions, or features they have acquired in your app on other platforms or your web site, including consumable items in multi-platform games, provided those items are also available as [in-app purchases within the app](#in-app-purchase).
									
• 3.1.3(c) Enterprise Services: If your app is only sold directly by you to organizations or groups for their employees or students (for example professional databases and classroom management tools), you may allow enterprise users to access previously-purchased content or subscriptions. Consumer, single user, or family sales must use in-app purchase.
									
• 3.1.3(d) Person-to-Person Services: If your app enables the purchase of real-time person-to-person services between two individuals (for example tutoring students, medical consultations, real estate tours, or fitness training), you may use purchase methods other than in-app purchase to collect those payments. One-to-few and one-to-many real-time services must use in-app purchase.
									
• 3.1.3(e) Goods and Services Outside of the App: If your app enables people to purchase physical goods or services that will be consumed outside of the app, you must use purchase methods other than in-app purchase to collect those payments, such as Apple Pay or traditional credit card entry.
									
• 3.1.3(f) Free Stand-alone Apps: Free apps acting as a stand-alone companion to a paid web based tool (i.e. VoIP, Cloud Storage, Email Services, Web Hosting) do not need to use in-app purchase, provided there is no purchasing inside the app, or calls to action for purchase outside of the app.
									
• 3.1.3(g) Advertising Management Apps: Apps for the sole purpose of allowing advertisers (persons or companies that advertise a product, service, or event) to purchase and manage advertising campaigns across media types (television, outdoor, websites, apps, etc.) do not need to use in-app purchase. These apps are intended for campaign management purposes and do not display the advertisements themselves. Digital purchases for content that is experienced or consumed in an app, including buying advertisements to display in the same app (such as sales of “boosts” for posts in a social media app) must use in-app purchase.
									
• 3.1.4 Hardware-Specific Content: In limited circumstances, such as when features are dependent upon specific hardware to function, the app may unlock that functionality without using in-app purchase (e.g. an astronomy app that adds features when synced with a telescope). App fe

... [truncated]


>>>TOOL web_fetch
{"url":"https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc","max_length":12000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc

swift - How to load WebAssembly in iOS app via WKWebVIew or JSC - Stack Overflow

• 

• 

•  
    
• 
        
• 

• 
            
• 

• 

• 

    [Skip to main content](#content)

					Stack Overflow

• 
						
							About

• 
					
							Products

• 
						
							For Teams

• 
						
							Stack Internal
							Implement a knowledge platform layer to power your enterprise and AI tools.

• 
						
						 	Stack Data Licensing
							Get access to top-class technical expertise with trusted & attributed content.

• 
						
							Stack Ads
							Connect your brand to the world&#x2019;s most trusted technologist communities.

• 
						
						 	Releases
							Keep up-to-date on features we add to Stack Overflow and Stack Internal.

• 
						[About the company](https://stackoverflow.co/?utm_medium=referral&utm_source=stackoverflow-community&utm_campaign=top-nav&utm_content=about-the-company)

						[Visit the blog](https://stackoverflow.blog/?utm_medium=referral&utm_source=stackoverflow-community&utm_campaign=top-nav&utm_content=blog)

                            s-popover#show"
                                   data-s-popover-placement="bottom-start" />

                Loading&#x2026;

• 

                [current community](https://stackoverflow.com)

• 

            Stack Overflow

            [help](https://stackoverflow.com/help)
            [chat](https://chat.stackoverflow.com/?tab=explore)

• 

            Meta Stack Overflow

your communities            

[Sign up](https://stackoverflow.com/users/signup?ssrc=site_switcher&returnurl=https%3a%2f%2fstackoverflow.com%2fquestions%2f57348813%2fhow-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc) or [log in](https://stackoverflow.com/users/login?ssrc=site_switcher&returnurl=https%3a%2f%2fstackoverflow.com%2fquestions%2f57348813%2fhow-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc) to customize your list.                

            [more stack exchange communities](https://stackexchange.com/sites)
            
            [company blog](https://stackoverflow.blog)

• 

• 
                            [Log in](https://stackoverflow.com/users/login?ssrc=head&returnurl=https%3a%2f%2fstackoverflow.com%2fquestions%2f57348813%2fhow-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc)

• [Sign up](https://stackoverflow.com/users/signup?ssrc=head&returnurl=https%3a%2f%2fstackoverflow.com%2fquestions%2f57348813%2fhow-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc)

• 

• 

                Home

• 

                Questions

• 

                AI Assist

• 

                Tags

• 

• 

                Challenges

• 

                                    Chat

• 

                Articles

• 

                Users

• 

• 

                Companies

• 

                                        Collectives

• 

                                        Communities for your favorite technologies.  [Explore all Collectives](/collectives-all)

• 

    Stack Internal

            Stack Overflow for Teams is now called Stack Internal. Bring the best of human thought and AI automation together at your work.
        
        [Try for free](https://stackoverflowteams.com/teams/create/free/?utm_medium=referral&utm_source=stackoverflow-community&utm_campaign=side-bar&utm_content=explore-teams)
        [Learn more](https://stackoverflow.co/internal/?utm_medium=referral&utm_source=stackoverflow-community&utm_campaign=side-bar&utm_content=explore-teams)

• 

            Stack Internal

• 

            Bring the best of human thought and AI automation together at your work.
            [Learn more](https://stackoverflow.co/internal/?utm_medium=referral&utm_source=stackoverflow-community&utm_campaign=side-bar&utm_content=explore-teams-compact)

                Collectives™ on Stack Overflow
                
Find centralized, trusted content and collaborate around the technologies you use most.
                [
                    Learn more about Collectives
                ](/collectives)

Stack Internal
                
Knowledge at work
                
Bring the best of human thought and AI automation together at your work.
                [
                    Explore Stack Internal
                ](https://stackoverflow.co/internal/?utm_medium=referral&utm_source=stackoverflow-community&utm_campaign=side-bar&utm_content=explore-teams-compact-popover)

• 

# [How to load WebAssembly in iOS app via WKWebVIew or JSC](/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc)

                                [
        Ask Question
    ](/questions/ask)

                            Asked
                            6 years, 6 months ago

                            Modified
                            [4 years, 5 months ago](?lastactivity)

                            Viewed
                            11k times

 Part
                                of Mobile Development Collective

10        

I'm trying to load and execute a WebAssembly .wasm from within a Swift-based, iOS  app. I first attempted to use the [JavaScriptCore Framework](https://developer.apple.com/documentation/javascriptcore) but the WebAssembly.* module wasn't available in the Context when I tried to evaluate a trivial script. I was able to confirm the WebAssembly isn't defined via the Safari Debugger Console.

I then attempted to use WKWebView because I'm led to believe that the lack of WebAssembly is due to [JSC not supporting](https://www.lucidchart.com/techblog/2019/01/03/javascriptcore-10-months-later/) JIT, which WKWebView should. I got the same result. 

Here's a trivial app running on an iPhone X 12.4 emulator, Xcode 10.3 and the WebKit Framework manually added to the project. Make sure to open Safari and Select "Developer>Simulator" for WKWebView debugger.

import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func onClick(_ sender: UIButton) {
        let testWasm = """
            if(typeof WebAssembly !== 'undefined') {
                console.log("Hello, Wasm.");
            } else {
                console.log("No Wasm for you!");
            }
        """

        webView.evaluateJavaScript(testWasm)
    }
}

Does iOS actually have a way to load WebAssembly into a Swift-based app?

                        [](/collectives/mobile-dev)
                        
• [ios](/questions/tagged/ios)
• [swift](/questions/tagged/swift)
• [wkwebview](/questions/tagged/wkwebview)
• [webassembly](/questions/tagged/webassembly)
• [javascriptcore](/questions/tagged/javascriptcore)

            [Share](/q/57348813)

                        [Improve this question](/posts/57348813/edit)

                        Follow

            asked Aug 4, 2019 at 17:32

        [jonathanberi](/users/252525/jonathanberi)
        
            1,95722 gold badges1515 silver badges2525 bronze badges

1

• 

                I think it is due to this bug: [bugs.webkit.org/show_bug.cgi?id=191064](https://bugs.webkit.org/show_bug.cgi?id=191064)  I&#39;ve only been testing in the simulator!

                    jonathanberi
&ndash; 
                        [jonathanberi](/users/252525/jonathanberi)
                
                2019-08-10 16:38:47 &#x2B;00:00
                
                    Commented
                    Aug 10, 2019 at 16:38

                    [
                        Add a comment
                    ](#)
                 | 

2 Answers                                        2

            Sorted by:
        
        [
            Reset to default
        ](/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc?answertab=scoredesc#tab-top)

                        Highest score (default)

                        Trending (recent votes count more)

                        Date modified (newest first)

                        Date created (oldest first)

3        

I wanted to run some benchmarks with JSC to compare it with Wasm3.

Basically I run into the same situation and wasn't able to fix so far.

Wasm3 [runs perfectly fine on iOS](https://github.com/wasm3/wasm3/tree/master/platforms/ios), and may suite your needs at the moment.

Currently you can't run WebAssembly with JSC on the simulator [according to this comment](https://bugs.webkit.org/show_bug.cgi?id=194257#c71).

            [Share](/a/59756205)

                        [Improve this answer](/posts/59756205/edit)

                        Follow

            edited Jan 15, 2020 at 18:23

            answered Jan 15, 2020 at 16:56

        [Volodymyr Shymanskyy](/users/12719194/volodymyr-shymanskyy)
        
            5666 bronze badges

                            Sign up to request clarification or add additional context in comments.

## Comments
   
Add a comment   

3        

It appears that [JavaScriptCore now has a WebAssembly interpreter](https://www.youtube.com/watch?v=1v4wPoMskfo), as of Feb 2020.

            [Share](/a/68866759)

                        [Improve this answer](/posts/68866759/edit)

                        Follow

            answered Aug 20, 2021 at 18:39

        [Elijah Yap](/users/12395667/elijah-yap)
        
            40333 silver badges55 bronze badges

## Comments
   
Add a comment   

                                        Your Answer

Thanks for contributing an answer to Stack Overflow!
• Please be sure to answer the question. Provide details and share your research!
But avoid …
• Asking for help, clarification, or responding to other answers.
• Making statements based on opinion; back them up with references or personal experience.
To learn more, see our [tips on writing great answers](/help/how-to-answer).

        Draft saved
        Draft discarded

                        Sign up or [log in](/users/login?ssrc=question_page&returnurl=https%3a%2f%2fstackoverflow.com%2fquestions%2f57348813%2fhow-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc%23new-answer)

 Sign up using Google

 Sign up using Email and Password

                    Submit
                    
                                Post as a guest

                    Name

                            Email
                            
Required, but never shown

                        Post as a guest

                    Name

                            Email
                            
Required, but never shown

                                                Post Your Answer

                                                Discard

                                                    By clicking “Post Your Answer”, you agree to our terms of service and acknowledge you have read our privacy policy.

Start asking to get answers
                                            
Find the answer to your question by asking.
                                            [Ask question](/questions/ask)

Explore related questions
                                            
• [ios](/questions/tagged/ios)
• [swift](/questions/tagged/swift)
• [wkwebview](/questions/tagged/wkwebview)
• [webassembly](/questions/tagged/webassembly)
• [javascriptcore](/questions/tagged/javascriptcore)
                                            
See similar questions with these tags.

                        Mobile Development
                        Collective

                    See more

 This question is in a collective: a subcommunity defined by tags with relevant content and experts.

• 
                            The Overflow Blog

• 

                [AI attention span so good it shouldn’t be legal](https://stackoverflow.blog/2026/02/06/ai-attention-span-so-good-it-shouldn-t-be-legal/)

• 
                            Featured on Meta

• 

                [Results of the January 2026 Community Asks Sprint: Community Badges](https://meta.stackexchange.com/questions/417043/results-of-the-january-2026-community-asks-sprint-community-badges)

... [truncated]


>>>TOOL web_fetch
{"url":"https://wasmer.io/posts/wasmer-3_3-and-javascriptcore","max_length":12000}
>>>END>>>TOOL web_search
{"query":"WebAssembly interpreter runtime iOS wasm3 WAMR iOS", "max_results":5}
>>>END


---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://wasmer.io/posts/wasmer-3_3-and-javascriptcore

• 
• 
• 
• 
• 
• 
• 
• Wasmer 3.3 - Running WebAssembly 2.5x faster with JavascriptCore · Blog · Wasmer
• 
• 
• 

• Solutions

• Developers

• [Pricing](/pricing)
• [Templates](/templates)
• [Blog](/posts)

## Command Palette

Search for a command to run...

Back to articles
May	3, 2023
# Wasmer 3.3 - Running WebAssembly 2.5x faster with JavascriptCore

Wasmer 3.3 - Running WebAssembly 2.5x faster with JavascriptCoreSyrus Akamin
Founder & CEO
The power of Wasmer relies on delivering one universal API to run WebAssembly programs anywhere. On that quest, we worked hard to extend Wasmer by adding support for more backends, starting with JavaScriptCore. Today are incredibly excited to ship JSC support in Wasmer v3.3.

Now you can use wasmer to run WebAssembly programs in macOS and Linux, powered by the same engine behind the Safari browser: JavaScriptCore.

We were hoping to have native support as well on iOS, but unfortunately Apple disabled WebAssembly in JSC for iOS 16.4.x. Once Apple enables it, you should be able to use Wasmer via JSC in iOS!

Thanks to JavascriptCore we have been able to achieve incredible speed (2.5x faster than Cranelift!) in a M1 Max chip (see [Performance](#performance) section for more info)

The jsc feature makes possible using Wasmer on macOS with a minimal dependency chain (no compilers or JITs will be included in the final macOS binary whatsoever, it will be using JavaScriptCore, already included by default in the system library!).

Supporting JavaScriptCore in Wasmer had another side effect: since Wasmer supports wasm-c-api, you can now get a fully working wasm-c-api API for JavascriptCore! Download the release here: [https://github.com/wasmerio/wasmer/releases/tag/v3.3.0](https://github.com/wasmerio/wasmer/releases/tag/v3.3.0) ([Intel](https://github.com/wasmerio/wasmer/releases/download/v3.3.0/wasmer-darwin-amd64-jsc.zip), [M1/M2](https://github.com/wasmerio/wasmer/releases/download/v3.3.0/wasmer-darwin-arm64-jsc.zip))

As of the latest release (v3.3.0), Wasmer supports the following runtime backends:

• 

Native

• LLVM (llvm feature)

• Cranelift (cranelift feature)

• Singlepass (singlepass feature)

• [new] JavascriptCore  (jsc feature)

• V8 or Wasmi? (vote for it!)

• 

Browser (JS) (js feature)

wasmer can already be compiled to Wasm and be used in your browser via wasm-bindgen. Read more about it here:
[https://wasmer.io/posts/wasmer-js-a-new-hope](https://wasmer.io/posts/wasmer-js-a-new-hope)

Would you like to have V8 or Wasmi support in Wasmer and see how each engine performs against each other? Cast your vote! [The first backend to reach 20 votes](https://github.com/wasmerio/wasmer/discussions/3839) will be fully implemented and available in the next version of Wasmer!

We aim for Wasmer to become the universal API layer to use WebAssembly anywhere, no matter what engine you want to use under the hood. Wasmer will make a breeze for you to switch between the backend of your choosing: LLVM, Cranelift, Singlepass, JavaScriptCore…

Of course, your runtime needs might change over time, so it should be trivial for you to trial the backend best suited for your needs each time.

This by itself is awesome, but there is another reason this is also great for the WebAssembly community:

It unites all different engines into one universal API. Imagine if in the Javascript World, Node.js or Deno were not tied to V8, if Bun was not tied to JSC. Imagine if you could switch Javascript engines easily when using Node, Deno or Bun, and choose always the most convenient engine for your workload.

We have done that in the WebAssembly world… and the crop yieldings are just yet to come!

## Performance

Now that JSC is fully integrated, we can compare easily how CoreMark performs in JavascriptCore vs Cranelift on a M1 Max chip. Since our WASI implementation is also completely universal, we can simply run WASI programs and see how they perform.

Cranelift: 10368.659772

$ wasmer run vshymanskyy/coremark
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 2109026816
Total time (secs): 19.288896
Iterations/Sec   : 10368.659772
Iterations       : 200000
Compiler version : Clang 11.0.0 (https://github.com/llvm/llvm-project 176249bd6732a8044d457092ed932768724a6f06)
Compiler flags   : -O3
Memory location  : STATIC
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x4983
Correct operation validated. See README.md for run and reporting rules.
CoreMark 1.0 : 10368.659772 / Clang 11.0.0 (https://github.com/llvm/llvm-project 176249bd6732a8044d457092ed932768724a6f06) -O3    / STATIC

JavascriptCore: 24286.414544 …that’s almost 2.5x faster than Cranelift!

$ wasmer-jsc run vshymanskyy/coremark
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 3762650408
Total time (secs): 12.352585
Iterations/Sec   : 24286.414544
Iterations       : 300000
Compiler version : Clang 11.0.0 (https://github.com/llvm/llvm-project 176249bd6732a8044d457092ed932768724a6f06)
Compiler flags   : -O3
Memory location  : STATIC
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0xcc42
Correct operation validated. See README.md for run and reporting rules.
CoreMark 1.0 : 24286.414544 / Clang 11.0.0 (https://github.com/llvm/llvm-project 176249bd6732a8044d457092ed932768724a6f06) -O3    / STATIC

## How you can use it

It’s trivial to use JavascriptCore with wasmer. Just add the jsc feature when using the wasmer dependency on your Cargo.toml (with no default-features).

All the features of Wasmer are already supported (threads, WASI, …)

[dependencies]
wasmer = { version = "3.2.1", default-features=false, features=["jsc"]}

And that’s it!

Now, you can use the Wasmer API as you would normally:

let mut store = Store::default();
// We can use the WAT syntax as well!
let module = Module::new(
    &#x26;store,
    br#"(module
        (func $sum (import "env" "sum") (param i32 i32) (result i32))
        (func (export "add_one") (param i32) (result i32)
            (call $sum (local.get 0) (i32.const 1))
        )
    )"#,
	)?;

fn sum(a: i32, b: i32) -> i32 {
    a + b
}

let import_object = imports! {
    "env" => {
        "sum" => Function::new_typed(&#x26;store, sum),
    }
};
let instance = Instance::new(&#x26;mut store, &#x26;module, &#x26;import_object)?;

let add_one: TypedFunction&#x3C;i32, i32> = instance.exports.get_typed_function("add_one")?;
add_one.call(&#x26;mut store, 1)?

Et voila! Now you have have this code as iOS or macOS app fully working with a minimal dependency of Wasmer (with no compilers or JIT needed) working at full speed on your application!

## How is this possible?

We used the rusty_jsc project, originally created by [Pekka Enberg](https://github.com/penberg) . rusty_jsc provides a lean “Rusty” API to use JavascriptCore locally.

We had to do some improvements to the APIs to make the integration fully work, as rusty_jsc was fairly incomplete. We would like to publicly thank Pekka for letting Wasmer take the lead for moving the development for rusty_jsc forward!

The integration of rusty_jsc into Wasmer was mostly trivial, with the exception of connecting native Functions with JavascriptCore Function Callbacks.

One of the most challenging feats we achieved was enabling the ability to create JavascriptCore callbacks at runtime with Rust closures.

In this example we have created a JS closure that uses the multiplier variable from the parent Rust scope:

use rusty_jsc::{callback_closure, JSContext, JSValue};

let context = JSContext::default();
let multiplier = 10f64;

let callback = callback_closure!(
    &#x26;context,
    move |ctx: JSContext, _func: JSObject, _this: JSObject, args: &#x26;[JSValue]| {
        let num = args[0].to_number(&#x26;ctx).unwrap();
        Ok(JSValue::number(&#x26;ctx, num * multiplier))
    }
);
let result = callback
    .call(
        &#x26;context,
        Some(&#x26;callback),
        &#x26;[JSValue::number(&#x26;context, 5f64)],
    )
    .unwrap();

assert_eq!(result.to_number(&#x26;context).unwrap(), 50f64)

You can see [the PR making JavascriptCore available in Wasmer here](https://github.com/wasmerio/wasmer/pull/3825), if you are curious of how much effort it took to add a new backend! (tl;dr: not really that much!)

## Why you would want to use Wasmer with JavascriptCore?

There are two use cases that we believe are critical.

• If you are working on a macOS application and you want to use WebAssembly at incredible speeds also while delivering a minimal binary dependency (since JavascriptCore is always available in macOS)

• If you want to run WebAssembly applications in iOS without your app being in JIT mode (no apps)

Can’t wait to see what you are going to build next with Wasmer!About the Author
Syrus Akbary is an enterpreneur and programmer. Specifically known for his contributions to the field of WebAssembly. He is the Founder and CEO of Wasmer, an innovative company that focuses on creating developer tools and infrastructure for running WasmSyrus Akamin
Founder & CEO
Performance
How you can use it
How is this possible?
Why you would want to use Wasmer with JavascriptCore?Try Wasmer Edge for free
Deploy your web app in seconds with our managed cloud solution.Deploy new project
Making software universally accessible
Twitter
Discord
GitHub
## Explore

• [Packages](/explore)
• [Blog](/posts)
## Products

• [Runtime](/products/runtime)
• [Registry](/products/registry)
• [Edge](/products/edge)
## Use cases

• WordPress Hosting
• [Free Static Site Hosting](/static-site-hosting)
• [Free Web Hosting](/free-web-hosting)
• [PHP Hosting](/php-hosting)
• [Django Hosting](/django-hosting)
## Company

• [About](/about)
• [Values & Culture](/values-and-culture)
• [Pricing](/pricing)
• [Imprint](#)
• [Privacy](/policies/privacy)
• [Terms](/terms)
• [Report abuse](mailto:abuse@wasmer.io?subject=Abuse%20Reporting)

---

[web_search]
🔍 DuckDuckGo results for "WebAssembly interpreter runtime iOS wasm3 WAMR iOS" (5 results):

1. **GitHub - wasm3/wasm3: A fast WebAssembly interpreter and the most ...**
   https://github.com/wasm3/wasm3
   A simple library like Wasm3 is easy to compile and integrate into an existing project. (Wasm3 builds in a just few seconds). Finally, on some platforms (i.e. iOS and WebAssembly itself) you can&#x27;t generate executable code pages in runtime, so JIT is unavailable. Why would you want to run WASM on embedded devices?

2. **Wasmer WebAssembly platform now backs iOS - InfoWorld**
   https://www.infoworld.com/article/3595573/wasmer-webassembly-platform-now-backs-ios.html
   Using the capabilities of Google&#x27;s V8 JavaScript/WebAssembly engine, the Wasmi interpreter, and the WebAssembly Micro Runtime (WAMR), developers now can run WebAssembly modules on Apple&#x27;s iOS.

3. **Introducing Wasmer 5.0 · Blog · Wasmer**
   https://wasmer.io/posts/introducing-wasmer-v5
   Unfortunately, iOS capped the ability of using WebAssembly via JavascriptCore (since iOS 14). Leveraging the capabilities of V8, Wasmi and WebAssembly Micro Runtime (WAMR), developers can now run WebAssembly modules seamlessly on iOS thanks to Wasmer 5.0. No changes needed on their codebase.

4. **Wasm3 vs WAMR (2026): The Ultimate Embedded Wasm Runtime Showdown**
   https://wasmruntime.com/en/blog/wasm3-vs-wamr-2026
   2026 deep comparison of Wasm3 and WAMR. Complete analysis of size, performance, and ecosystem for the two major embedded WebAssembly runtimes.

5. **Wasmer 5.0 enhances WebAssembly runtime with iOS ... - AlternativeTo**
   https://alternativeto.net/news/2024/10/wasmer-5-0-enhances-webassembly-runtime-with-ios-support-new-backends-and-performance-boost/
   Wasmer has released version 5.0 of its WebAssembly runtime, introducing several enhancements and improved performance. The update includes support for additional backends such as V8, Wasmi, and WAMR, integrated via the Wasm-C-API. This release also marks the debut of WebAssembly on iOS devices through a new interpreted mode, allowing developers to run WebAssembly modules on iOS without ...


>>>TOOL web_fetch
{"url":"https://github.com/wasm3/wasm3","max_length":12000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://github.com/wasm3/wasm3

• 
  
• 
  
• 
  
• 
  
• 
  
• 

• 
• 
• 
• 
• 
• 
• 
• 
• 
• 
• 
• 
• 
• 
• 
• 
• 
• 

• 
    
• 
    
• 
    
• 
  
• 

• 

• 

• 

• 

• 

  GitHub - wasm3/wasm3: 🚀 A fast WebAssembly interpreter and the most universal WASM runtime

• 

• 

• 

• 

• 
  
• 
  
• 

• 

      [Skip to content](#start-of-content)

• 

• 

## Navigation Menu

    Toggle navigation

          [
            Sign in
          ](/login?return_to=https%3A%2F%2Fgithub.com%2Fwasm3%2Fwasm3)

Appearance settings

• 

• 

• 

• 

• Platform

• AI CODE CREATION
• 

GitHub CopilotWrite better code with AI
• 
GitHub SparkBuild and deploy intelligent apps
• 
GitHub ModelsManage and compare prompts
• 

MCP RegistryNewIntegrate external tools
• DEVELOPER WORKFLOWS
• 
ActionsAutomate any workflow
• 

CodespacesInstant dev environments
• 
IssuesPlan and track work
• 
Code ReviewManage code changes
• APPLICATION SECURITY
• 

GitHub Advanced SecurityFind and fix vulnerabilities
• 

Code securitySecure your code as you build
• 
Secret protectionStop leaks before they start
• EXPLORE
• Why GitHub
• Documentation

• Blog

• Changelog

• MarketplaceView all features

• Solutions

• BY COMPANY SIZE
• Enterprises
• Small and medium teams
• Startups
• Nonprofits
• BY USE CASE
• App Modernization
• DevSecOps
• DevOps
• CI/CD
• View all use cases

• BY INDUSTRY
• Healthcare
• Financial services
• Manufacturing
• Government
• View all industries
View all solutions

• Resources

• EXPLORE BY TOPIC
• AI
• Software Development
• DevOps
• Security
• View all topics

• EXPLORE BY TYPE
• Customer stories
• Events & webinars
• Ebooks & reports
• Business insights
• GitHub Skills

• SUPPORT & SERVICES
• Documentation

• Customer support

• Community forum
• Trust center
• Partners
• Open Source

• COMMUNITY
• 
GitHub SponsorsFund open source developers
• PROGRAMS
• Security Lab

• Maintainer Community

• Accelerator
• Archive Program

• REPOSITORIES
• Topics
• Trending
• Collections
• Enterprise

• ENTERPRISE SOLUTIONS
• 

Enterprise platformAI-powered developer platform
• AVAILABLE ADD-ONS
• 

GitHub Advanced SecurityEnterprise-grade security features
• 

Copilot for BusinessEnterprise-grade AI features
• 

Premium SupportEnterprise-grade 24/7 support
• Pricing

        Search or jump to...

# Search code, repositories, users, issues, pull requests...

           -->

        Search

          Clear

            [Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)            

        Provide feedback

                 -->
          
We read every piece of feedback, and take your input very seriously.

          Include my email address so I can be contacted

                    Cancel

              Submit feedback

        Saved searches

## Use saved searches to filter your results more quickly

         -->

            Name

            Query

            To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax).

                    Cancel

              Create saved search

              [
                Sign in
              ](/login?return_to=https%3A%2F%2Fgithub.com%2Fwasm3%2Fwasm3)

              [
                Sign up
              ](/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&source=header-repo&source_repo=wasm3%2Fwasm3)

Appearance settings

• 

• 

          Resetting focus

        You signed in with another tab or window. [Reload]() to refresh your session.
        You signed out in another tab or window. [Reload]() to refresh your session.
        You switched accounts on another tab or window. [Reload]() to refresh your session.

Dismiss alert

      {{ message }}

      [
        wasm3
](/wasm3)    
    /
    
      [wasm3](/wasm3/wasm3)

    Public

• 

Notifications
    You must be signed in to change notification settings

• 

Fork
    507

• 

          Star
          7.8k

        🚀 A fast WebAssembly interpreter and the most universal WASM runtime

          [twitter.com/wasm3_engine](https://twitter.com/wasm3_engine)

      License

     MIT license

          7.8k
          stars

          507
          forks

          Branches

          Tags

          Activity

          Star

Notifications
    You must be signed in to change notification settings

• 

        Code

• 

        Issues
          66

• 

        Pull requests
          29

• 

        Actions

• 

        Security
          0

• 

        Insights

Additional navigation options

• 

          Code

• 

          Issues

• 

          Pull requests

• 

          Actions

• 

          Security

• 

          Insights

# wasm3/wasm3

• 

• 

 main

Branches
Tags

Go to file
Code

Open more actions menu
## Folders and files
NameNameLast commit messageLast commit date
## Latest commit
 
## History

1,704 Commits
1,704 Commits
.github/workflows
.github/workflows  
[docs](/wasm3/wasm3/tree/main/docs)
[docs](/wasm3/wasm3/tree/main/docs)  
[extra](/wasm3/wasm3/tree/main/extra)
[extra](/wasm3/wasm3/tree/main/extra)  
[platforms](/wasm3/wasm3/tree/main/platforms)
[platforms](/wasm3/wasm3/tree/main/platforms)  
[source](/wasm3/wasm3/tree/main/source)
[source](/wasm3/wasm3/tree/main/source)  
[test](/wasm3/wasm3/tree/main/test)
[test](/wasm3/wasm3/tree/main/test)  
[.codespellrc](/wasm3/wasm3/blob/main/.codespellrc)
[.codespellrc](/wasm3/wasm3/blob/main/.codespellrc)  
[.gitignore](/wasm3/wasm3/blob/main/.gitignore)
[.gitignore](/wasm3/wasm3/blob/main/.gitignore)  
[CMakeLists.txt](/wasm3/wasm3/blob/main/CMakeLists.txt)
[CMakeLists.txt](/wasm3/wasm3/blob/main/CMakeLists.txt)  
[LICENSE](/wasm3/wasm3/blob/main/LICENSE)
[LICENSE](/wasm3/wasm3/blob/main/LICENSE)  
[README.md](/wasm3/wasm3/blob/main/README.md)
[README.md](/wasm3/wasm3/blob/main/README.md)  
[build-cross.py](/wasm3/wasm3/blob/main/build-cross.py)
[build-cross.py](/wasm3/wasm3/blob/main/build-cross.py)  
[build.zig](/wasm3/wasm3/blob/main/build.zig)
[build.zig](/wasm3/wasm3/blob/main/build.zig)  View all files
## Repository files navigation

• 
README
• 
MIT license

Note
I regret to inform the community that since [my house was destroyed by russians who invaded my country](https://twitter.com/vshymanskyy/status/1568657607229075456), Wasm3 will enter a minimal maintenance phase. At this time, I am unable to continue the development of new features. However, I am committed to keeping the project alive and will actively review and merge incoming Pull Requests. I deeply appreciate your understanding and support during this difficult period. Your contributions to Wasm3 are now more valuable than ever.

#  Wasm3

A fast WebAssembly interpreter and the most universal WASM runtime.

Based on CoreMark 1.0 and independent benchmarks. Your mileage may vary.

## Installation

Please follow the [installation instructions](/wasm3/wasm3/blob/main/docs/Installation.md).

Wasm3 can also be used as a library for:

 Python3 │
 Rust │
 C/C++ │
 D │
 GoLang │
 Zig │
 Perl

 Swift │
 .Net │
 Nim │
 Arduino, PlatformIO, Particle │ [QuickJS](https://github.com/saghul/txiki.js)

## Status

wasm3 passes the [WebAssembly spec testsuite](https://github.com/WebAssembly/spec/tree/master/test/core) and is able to run many WASI apps.

Minimum useful system requirements: ~64Kb for code and ~10Kb RAM

wasm3 runs on a wide range of architectures (x86, x86_64, ARM, RISC-V, PowerPC, MIPS, Xtensa, ARC32, ...) and [platforms](/wasm3/wasm3/blob/main/platforms):

•  Linux,
 Windows,
 OS X,
 FreeBSD,
 Android,
 iOS

•  OpenWrt, Yocto, Buildroot (routers, modems, etc.)

•  Raspberry Pi, Orange Pi and other SBCs

•  MCUs: Arduino, ESP8266, ESP32, Particle, ... [see full list](/wasm3/wasm3/blob/main/docs/Hardware.md)

•  Browsers. Yes, using WebAssembly itself!

•  wasm3 can execute wasm3 (self-hosting)

## Features

Webassembly [Proposals](https://github.com/WebAssembly/proposals/blob/main/README.md)
Extra

☑ Import/Export of Mutable Globals
☑ Structured execution tracing

☑ Non-trapping float-to-int conversions
☑ Big-Endian systems support

☑ Sign-extension operators
☑ Wasm and WASI self-hosting

☑ Multi-value
☑ Gas metering

☑ Bulk memory operations (partial support)
☑ Linear memory limit (&lt; 64KiB)

☑ Custom page size

⏳ Multiple memories

⏳ Reference types

☐ Tail call optimization

☐ Fixed-width SIMD

☐ Exception handling

☐ Stack Switching

## Motivation

Why use a "slow interpreter" versus a "fast JIT"?

In many situations, speed is not the main concern. Runtime executable size, memory usage, startup latency can be improved with the interpreter approach. Portability and security are much easier to achieve and maintain. Additionally, development impedance is much lower. A simple library like Wasm3 is easy to compile and integrate into an existing project. (Wasm3 builds in a just few seconds). Finally, on some platforms (i.e. iOS and WebAssembly itself) you can't generate executable code pages in runtime, so JIT is unavailable.

Why would you want to run WASM on embedded devices?

Wasm3 started as a research project and remains so by any means. Evaluating the engine in different environments is part of the research. Given that we have Lua, JS, Python, Lisp, ... running on MCUs, WebAssembly is a promising alternative. It provides toolchain decoupling as well as a completely sandboxed, well-defined, predictable environment. Among practical use cases we can list edge computing, scripting, plugin systems, running IoT rules, smart contracts, etc.

## Used by

## Further Resources

[Demos](/wasm3/wasm3/blob/main/docs/Demos.md)

[Installation instructions](/wasm3/wasm3/blob/main/docs/Installation.md)

[Cookbook](/wasm3/wasm3/blob/main/docs/Cookbook.md)

[Troubleshooting](/wasm3/wasm3/blob/main/docs/Troubleshooting.md)

[Build and Development instructions](/wasm3/wasm3/blob/main/docs/Development.md)

[Supported Hardware](/wasm3/wasm3/blob/main/docs/Hardware.md)

[Testing & Fuzzing](/wasm3/wasm3/blob/main/docs/Testing.md)

[Performance](/wasm3/wasm3/blob/main/docs/Performance.md)

[Interpreter Architecture](/wasm3/wasm3/blob/main/docs/Interpreter.md)

[Logging](/wasm3/wasm3/blob/main/docs/Diagnostics.md)

[Awesome WebAssembly Tools](https://github.com/vshymanskyy/awesome-wasm-tools/blob/main/README.md)
License

This project is released under The MIT License (MIT)

## About

        🚀 A fast WebAssembly interpreter and the most universal WASM runtime

          [twitter.com/wasm3_engine](https://twitter.com/wasm3_engine)

    Topics

      [
  iot
](/topics/iot)
      [
  devops
](/topics/devops)
      [
  embedded
](/topics/embedded)
      [
  serverless
](/topics/serverless)
      [
  containers
](/topics/containers)
      [
  virtual-machine
](/topics/virtual-machine)
      [
  sandbox
](/topics/sandbox)
      [
  scripting
](/topics/scripting)
      [
  smart-contracts
](/topics/smart-contracts)
      [
  webassembly
](/topics/webassembly)
      [
  wasm
](/topics/wasm)
      [
  edge-computing
](/topics/edge-computing)
      [
  cosmopolitan
](/topics/cosmopolitan)

    Resources

        Readme

    License

     MIT license

              Uh oh!

There was an error while loading. [Please reload this page]().

        Activity    

        Custom properties    

    Stars

        7.8k
        stars    

    Watchers

        123
        watching    

    Forks

        507
        forks    

      [
          Report repository
](/contact/report-content?content_url=https%3A%2F%2Fgithub.com%2Fwasm3%2Fwasm3&report=wasm3+%28user%29)    

  Releases
      7

        v0.5.0
        
          Latest
      
      Jun 2, 2021

      [+ 6 releases](/wasm3/wasm3/releases)

  Packages
      0

        No packages published 

              Uh oh!

There was an error while loading. [Please reload this page]().

  Contributors
      65

• 

• 

• 

• 

• 

• 

• 

• 

• 

• 

• 

• 

• 

• 

    [+ 51 contribu

... [truncated]


>>>TOOL patch
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","find":"*Document Version: 1.0*  \n*Last Updated: January 2025*  \n*Applicable Platforms: iOS 17.x, iPadOS 17.x, Xcode 15.x*\n","replace":"*Document Version: 1.0*  \n*Last Updated: January 2025*  \n*Applicable Platforms: iOS 17.x, iPadOS 17.x, Xcode 15.x*\n\n---\n\n# Additional On-Device Execution Research (WASM / Python / Lua / Sandbox)\n\nThis section extends the JavaScriptCore-focused research above with practical options and constraints for executing **non-JavaScript** code on iOS/iPadOS devices.\n\n## 11. WebAssembly runtime options on iOS/iPadOS\n\n### Option A — `WKWebView` (WebKit) WebAssembly\n\n- `WKWebView` uses WebKit’s JavaScript engine environment, and **Safari supports WebAssembly**.\n- Practical issue: **you still don’t get OS access from Wasm** (no filesystem, no sockets) unless you bridge those capabilities from Swift/Obj‑C.\n\n**When it’s a good fit**\n- You already have a Web-based UI (HTML/Canvas/WebGL) or are comfortable hosting a minimal page and messaging between JS and native.\n\n**When it’s not**\n- You want a pure “headless” runtime without WebView, or need deterministic background execution.\n\n### Option B — JavaScriptCore + `WebAssembly` global (not reliable on iOS)\n\nWhether `WebAssembly` is available inside JavaScriptCore **varies by iOS/WebKit version and configuration**.\n\nEvidence that this can be absent/disabled:\n- A StackOverflow report notes `WebAssembly` not being defined in both JavaScriptCore and `WKWebView` in an iOS 12.4 simulator context (historical, but representative of availability pitfalls):\n  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc\n- Wasmer’s JavaScriptCore backend write-up states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x”**:\n  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore\n\n**Implication**: do not build a product plan that depends on “JSC provides Wasm” on-device unless you validate it on the exact iOS versions you target.\n\n### Option C — Embed a standalone Wasm runtime (no WebView)\n\nIf you need Wasm without depending on WebKit/JSC exposure, you can embed a third-party runtime.\n\nCommon choices that work without JIT:\n\n| Runtime | Type | iOS suitability | Notes |\n|---|---:|---:|---|\n| **wasm3** | Interpreter | ✅ Good | Designed for platforms where JIT isn’t possible; explicitly calls out iOS as a no-runtime-exec-page environment. Source: https://github.com/wasm3/wasm3 |\n| **WAMR** (WebAssembly Micro Runtime) | Interpreter/AOT options | ✅ Good | Common embedded runtime; can be configured for interpreter mode for iOS compliance. |\n| **Wasmer (interpreted backends)** | Multi-backend | ⚠️ Mixed | Wasmer can target interpreted engines; its JSC backend is useful on macOS but iOS has had JSC Wasm availability issues (see Wasmer blog above). |\n\n**Security model reminder**\n- Wasm is sandboxed: no syscalls by default; all capabilities come from imported host functions.\n- That’s a good match for iOS, because you can expose only a minimal, audited host API surface.\n\n### WASI on iOS\n\nWASI-like functionality (files, clocks, random) can be emulated via host functions, but:\n- You must map “filesystem” access to **your app container** (Documents/Library/tmp) or in-memory FS.\n- You must map networking to **native URLSession** or a controlled socket layer (subject to entitlements and ATS).\n\n---\n\n## 12. Why Python can’t run “natively” in this app (and what the App Store allows)\n\nThere are two different constraints people often mix together:\n\n### (1) Technical OS restrictions\n\nEven if you embed CPython in-process, iOS restrictions still block many “desktop Python” expectations:\n- No spawning arbitrary subprocesses (`fork/exec` patterns don’t apply to iOS app sandboxing).\n- No `dlopen` of arbitrary downloaded native extension modules (`.so`) from the network.\n- No JIT (relevant to PyPy and many high-performance runtimes).\n- Filesystem access is limited to the app container unless using user-mediated pickers/bookmarks.\n\n### (2) App Review policy restrictions (most important for distribution)\n\nApple’s App Review Guideline **2.5.2** states:\n\n> “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they **download, install, or execute code** which introduces or changes features or functionality of the app…”\n\nIt also provides a narrow exception:\n\n> “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”\n\nSource (Apple App Review Guidelines, §2.5.2):\n- https://developer.apple.com/app-store/review/guidelines/#software-requirements\n\n**Practical outcome for VSCodeiPadOS**\n- A full Python runtime + package installer tends to look like a “general purpose code execution environment” that can add functionality post‑review.\n- Even if permitted in a narrowly-scoped educational framing, it would still be constrained (no native pip wheels, no background daemons, no arbitrary system access).\n\n**What to do instead**\n- Run Python remotely (SSH / container / server function) and treat the iPad app as the IDE + UI.\n\n---\n\n## 13. Lua interpreter options on iOS/iPadOS\n\nLua is a strong on-device scripting candidate because it is small and easy to embed.\n\n### Recommended: PUC-Lua (standard interpreter)\n- Embed Lua 5.4/5.3 as a C library.\n- Use a strict host API (only expose what you want scripts to do).\n- Good fit for: editor automation, snippets/macros, lightweight extension points.\n\n### Not recommended for App Store builds: LuaJIT\n- LuaJIT relies on JIT compilation for most of its performance advantage.\n- iOS generally disallows third-party JIT without special entitlements.\n\n### Alternative: Lua implemented in JS / Wasm\n- **Fengari** (Lua VM written in JS) can run inside JavaScriptCore.\n- Lua VM compiled to Wasm can run inside an embedded Wasm runtime.\n\nTrade-off: slower than native interpreter, but easier packaging and sandboxing.\n\n---\n\n## 14. iOS/iPadOS security sandbox restrictions (what your execution engine inherits)\n\nAny embedded runtime (JS, Wasm, Lua, etc.) runs *inside the app sandbox*.\n\nKey constraints (see project security audit for container layout and restrictions):\n- App can read/write within its container (Documents/Library/tmp) but not `/System`, `/etc`, other apps’ data, etc.\n- Network access is controlled by entitlements and **App Transport Security (ATS)** requirements.\n\nSource (project docs): `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md` (\"iOS Sandbox Overview\", and tables of restricted resources).\n\nAlso, iOS hardens code execution:\n- W^X / code-signing model prevents allocating writable+executable memory in normal App Store apps, restricting JIT-style engines.\n\n---\n\n## 15. What is possible on-device vs what requires remote execution\n\n### ✅ Practical on-device execution (App Store-friendly)\n\n| Capability | On-device approach |\n|---|---|\n| User scripting / automation | JavaScriptCore (`JSContext`) with a limited native bridge |\n| Plugin logic that doesn’t require OS access | JavaScriptCore or Lua |\n| Deterministic, sandboxed compute modules | Embedded Wasm runtime (wasm3/WAMR) with a strict import set |\n| Basic file operations in workspace | Native Swift file APIs bridged into JS/Lua/Wasm (container-only) |\n| Networking | Native `URLSession` bridged into JS/Lua/Wasm (ATS compliant) |\n\n### ❌ Usually requires remote execution\n\n| Capability | Why remote is needed |\n|---|---|\n| Full Python / Node / Rust / Go toolchains | Heavy dependencies, native extensions, subprocesses, policy constraints |\n| Language servers (LSP) for many ecosystems | Requires spawning processes + large runtimes + filesystem scanning |\n| Running arbitrary user binaries | Not possible under iOS app sandbox (no exec of downloaded binaries) |\n| Heavy CI-style builds / container workloads | Not feasible on-device (resources + OS constraints) |\n\n### Remote execution paths that fit this project\n\n- **SSH into a dev machine / container** for running shells, language servers, builds, and interpreters.\n  - Project reference: `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md` (SwiftNIO SSH integration and limitations).\n- Optional: a dedicated “execution backend” (HTTP/WebSocket) for sandboxed tasks when SSH isn’t appropriate.\n\n---\n\n## References (additional)\n\n- Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception):\n  - https://developer.apple.com/app-store/review/guidelines/#software-requirements\n- Wasmer blog (JSC backend; notes iOS JSC Wasm disabled on iOS 16.4.x):\n  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore\n- wasm3 project (interpreter; explicitly discusses iOS/JIT unavailability):\n  - https://github.com/wasm3/wasm3\n- StackOverflow thread on Wasm availability in JSC/WKWebView (historical context):\n  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc\n"}>>>END

---

## 🔧 TOOL RESULTS

Error: Tool 'patch' not permitted for this agent (tools=read_write)


>>>TOOL move_file
{"from":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","to":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_JSC_Archive.md"}
>>>END
>>>TOOL create_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","content":"# On‑Device Execution Research (iOS/iPadOS)\n\n> **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.\n>\n> This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.\n\n## Table of contents\n\n1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)\n2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)\n3. [Why Python can’t run “natively” (policy + platform constraints)](#why-python-cant-run-natively-policy--platform-constraints)\n4. [Lua interpreter options](#lua-interpreter-options)\n5. [Security sandbox restrictions](#security-sandbox-restrictions)\n6. [What is possible on-device vs what requires remote execution](#what-is-possible-on-device-vs-what-requires-remote-execution)\n7. [References](#references)\n\n---\n\n## JavaScriptCore (JSC) on iOS: capabilities & limitations\n\n### What JSC is good for\n\n- Embedding a JS VM (`JavaScriptCore.framework`) for:\n  - User scripting / automation (macros, editor actions)\n  - Light business logic, parsing, formatting\n  - Rule engines / expression evaluation\n  - Safe-ish plugin logic when paired with a **strict native bridge**\n\n### Key limitations (important for “VS Code on iPad”)\n\n1. **No browser APIs**\n   - JSC is *not* a web runtime: no DOM, no `fetch`, no `XMLHttpRequest`, no WebSocket.\n   - Any filesystem/network/device capability must be explicitly bridged from Swift/Obj‑C.\n\n2. **JIT is not available to normal App Store apps**\n   - iOS enforces W^X + code-signing constraints. Third-party apps generally cannot use JIT without special entitlements.\n   - Consequence: CPU-heavy JS workloads can be much slower than on macOS.\n\n3. **No native module loading / package ecosystem like Node**\n   - There’s no `require('fs')` or `npm` environment.\n   - ES module support in embedded JSC is not “turnkey”; apps typically implement their own module loader.\n\n4. **Resource exhaustion is on you**\n   - There is no built-in watchdog timeout; infinite loops can hang a thread.\n   - You must implement your own timeouts / cancellation and memory pressure handling.\n\n### Practical recommendation\n\nUse JSC for:\n- small, sandboxed scripting surfaces\n- deterministic, user-visible automation\n\nAvoid JSC for:\n- running “real” language servers, compilers, large package ecosystems, or heavy compute\n\n---\n\n## WebAssembly (Wasm) runtime options\n\nWasm can be attractive as a portable, sandboxed compute layer. On iOS, what matters is: **where is your Wasm engine hosted** (WebView vs embedded runtime), and **what capabilities you import**.\n\n### Option A: `WKWebView` WebAssembly\n\n- Safari/WebKit supports WebAssembly, and `WKWebView` is the most common path if you’re already building a web-based execution environment.\n- Trade-offs:\n  - Wasm still has **no OS access by default** (no files/network) unless you bridge those from native.\n  - Background execution and long-running compute are constrained by iOS app lifecycle rules.\n\n### Option B: JavaScriptCore’s `WebAssembly` global (availability varies)\n\nDepending on iOS/WebKit version and configuration, `WebAssembly` may be missing/disabled in JavaScriptCore contexts.\n\nEvidence of availability pitfalls:\n- A StackOverflow report shows `WebAssembly` not being defined in JavaScriptCore and `WKWebView` in an iOS 12.4 simulator test (historical but highlights that “it’s there everywhere” is not safe to assume):\n  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc\n- Wasmer’s JavaScriptCore backend post explicitly states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x.”**\n  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore\n\n**Recommendation:** treat “Wasm via JSC” as **not a dependable product requirement** unless you validate it on the exact iOS versions you target.\n\n### Option C: Embed a standalone Wasm runtime (no WebView)\n\nIf you need Wasm without WebView, embed a runtime that works without JIT.\n\nCommon choices:\n\n- **wasm3** (interpreter)\n  - The wasm3 README explicitly calls out that on platforms like **iOS** “you can’t generate executable code pages in runtime, so JIT is unavailable.”\n  - Source: https://github.com/wasm3/wasm3\n\n- **WAMR (WebAssembly Micro Runtime)**\n  - Common embedded runtime; typically configured as interpreter/AOT depending on platform needs.\n\n- **Wasmer (interpreted backends)**\n  - Wasmer is multi-backend; its JSC backend is strong on macOS but iOS has had JSC Wasm availability issues (see Wasmer blog above).\n\n#### WASI considerations on iOS\n\nWASI expects OS-like primitives (files, clocks, random, args/env). On iOS, you generally implement these by:\n- mapping “filesystem” to the app container (Documents/Library/tmp) or an in-memory FS\n- mapping networking to `URLSession` or a tightly controlled socket layer\n\nThis can work well, but you must keep the import surface minimal and audited.\n\n---\n\n## Why Python can’t run “natively” (policy + platform constraints)\n\nThe most important blocker is **App Store policy around executing downloaded code and changing app behavior post‑review**, plus iOS platform constraints that make “desktop Python” expectations unrealistic.\n\n### App Store policy: Guideline 2.5.2\n\nApple’s App Review Guideline **2.5.2** states:\n\n> “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they **download, install, or execute code which introduces or changes features or functionality of the app**, including other apps.”\n\nIt also provides a narrow exception:\n\n> “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”\n\nSource:\n- https://developer.apple.com/app-store/review/guidelines/#software-requirements\n\n**Implication for VSCodeiPadOS:**\n- Shipping a general-purpose Python environment (interpreter + package installation + arbitrary code execution as a product feature) can be interpreted as enabling new functionality post‑review.\n- If you want “Python on iPad”, the App Store-compliant route is usually:\n  - keep it tightly scoped (often educational),\n  - keep code visible/editable, and\n  - avoid anything resembling “install arbitrary native capabilities.”\n\n### Platform constraints (even if policy were satisfied)\n\nEven with an embedded interpreter:\n- iOS sandboxing blocks typical toolchain patterns (no general subprocess model like desktop, no arbitrary exec of downloaded binaries).\n- Dynamic native extensions (typical `pip` wheels) are problematic in App Store constraints.\n- JIT-based Python runtimes (e.g., PyPy JIT) are not generally viable in App Store apps due to iOS code execution restrictions.\n\n### Practical recommendation\n\nFor VS Code-class workflows (toolchains, LSP servers, builds, Python packages):\n- do **remote execution** (SSH / remote compute service)\n- keep on-device scripting to languages designed to be embedded (JS/Lua) or sandboxed compute (Wasm)\n\n---\n\n## Lua interpreter options\n\nLua is a strong candidate for on-device scripting because it’s small, embeddable, and easy to sandbox.\n\n### Option A: Standard PUC-Lua (recommended)\n\n- Embed Lua 5.4/5.3 as a library.\n- Provide a minimal standard library surface.\n- Expose only whitelisted host functions (filesystem, settings, editor APIs).\n\nGood for:\n- macros\n- editor automation\n- lightweight “extensions” that are user-visible and easy to audit\n\n### Option B: LuaJIT (usually not viable)\n\n- LuaJIT’s main advantage depends on JIT compilation.\n- On iOS, third-party JIT is generally not available without special entitlements.\n\n### Option C: Lua on top of JS/Wasm\n\n- Lua VM written in JS (e.g., Fengari) can run in JSC.\n- Lua VM compiled to Wasm can run in an embedded Wasm runtime.\n\nTrade-off: simpler packaging/sandboxing at the cost of performance.\n\n---\n\n## Security sandbox restrictions\n\nEverything (JSC/Wasm/Lua) runs under the iOS app sandbox.\n\n### Filesystem\n\n- Read/write: app container only (Documents/Library/tmp)\n- No access to system directories (e.g. `/System`, `/etc`) and no direct access to other apps’ containers.\n\nProject reference:\n- `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md` describes the container layout and access restrictions.\n\n### Network\n\n- Networking is allowed but controlled:\n  - App Transport Security (ATS) rules apply (HTTPS-by-default)\n  - local network access requires the appropriate privacy usage description\n\nProject reference:\n- `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md` (ATS + network attack vectors)\n\n### Code execution model\n\n- iOS uses code-signing and W^X style restrictions; you cannot generally allocate memory that is both writable and executable in a normal App Store app.\n- This drives design choices:\n  - avoid JIT runtimes\n  - prefer interpreters or AOT where feasible\n\n---\n\n## What is possible on-device vs what requires remote execution\n\n### On-device (realistic / App Store-friendly)\n\n| Goal | Viable approach |\n|---|---|\n| User scripting & automation | JavaScriptCore + strict native bridge, or embedded Lua |\n| Sandboxed compute modules | Embedded Wasm runtime (e.g., wasm3/WAMR) with minimal imports |\n| Workspace file operations | Native Swift file APIs constrained to app container, bridged into runtime |\n| Networking for scripts/plugins | Native `URLSession` bridged into runtime (ATS compliant) |\n| Simple formatters / linters written in JS/Lua | Run on-device, enforce timeouts + memory limits |\n\n### Remote execution (often required for “real dev environment”)\n\n| Goal | Why remote is needed |\n|---|---|\n| Full Python/Node toolchains, `pip`/`npm`, native deps | Platform sandbox + policy constraints; native extensions/subprocess expectations |\n| Language servers (LSP) for large ecosystems | Process model + memory footprint + filesystem scanning; better on remote host |\n| Compilers/build systems (Rust/Go/C++ toolchains) | Not feasible to ship/execute full toolchains on iOS as in desktop environments |\n| Running arbitrary binaries | iOS app sandbox doesn’t support executing arbitrary downloaded programs |\n\n### Recommended remote path for this project\n\nUse SSH to a dev machine/container and treat iPad as the IDE client.\n\nProject reference:\n- `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md` documents SwiftNIO SSH integration for terminal-style remote execution.\n\n---\n\n## References\n\n- Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception)\n  - https://developer.apple.com/app-store/review/guidelines/#software-requirements\n- Wasmer blog (notes iOS JSC WebAssembly disabled on iOS 16.4.x)\n  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore\n- wasm3 README (iOS can’t generate executable code pages at runtime; interpreter rationale)\n  - https://github.com/wasm3/wasm3\n- StackOverflow thread on Wasm in JSC/WKWebView (availability pitfalls)\n  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc\n"}>>>END

---

## 🔧 TOOL RESULTS

[move_file]
✅ Moved: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md → VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_JSC_Archive.md

---

[create_file]
✅ Created: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","start_line":1,"end_line":260}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md (lines 2-245 of 245)
────────────────────────────────────────
2: 
3: > **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.
4: >
5: > This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.
6: 
7: ## Table of contents
8: 
9: 1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)
10: 2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)
11: 3. [Why Python can’t run “natively” (policy + platform constraints)](#why-python-cant-run-natively-policy--platform-constraints)
12: 4. [Lua interpreter options](#lua-interpreter-options)
13: 5. [Security sandbox restrictions](#security-sandbox-restrictions)
14: 6. [What is possible on-device vs what requires remote execution](#what-is-possible-on-device-vs-what-requires-remote-execution)
15: 7. [References](#references)
16: 
17: ---
18: 
19: ## JavaScriptCore (JSC) on iOS: capabilities & limitations
20: 
21: ### What JSC is good for
22: 
23: - Embedding a JS VM (`JavaScriptCore.framework`) for:
24:   - User scripting / automation (macros, editor actions)
25:   - Light business logic, parsing, formatting
26:   - Rule engines / expression evaluation
27:   - Safe-ish plugin logic when paired with a **strict native bridge**
28: 
29: ### Key limitations (important for “VS Code on iPad”)
30: 
31: 1. **No browser APIs**
32:    - JSC is *not* a web runtime: no DOM, no `fetch`, no `XMLHttpRequest`, no WebSocket.
33:    - Any filesystem/network/device capability must be explicitly bridged from Swift/Obj‑C.
34: 
35: 2. **JIT is not available to normal App Store apps**
36:    - iOS enforces W^X + code-signing constraints. Third-party apps generally cannot use JIT without special entitlements.
37:    - Consequence: CPU-heavy JS workloads can be much slower than on macOS.
38: 
39: 3. **No native module loading / package ecosystem like Node**
40:    - There’s no `require('fs')` or `npm` environment.
41:    - ES module support in embedded JSC is not “turnkey”; apps typically implement their own module loader.
42: 
43: 4. **Resource exhaustion is on you**
44:    - There is no built-in watchdog timeout; infinite loops can hang a thread.
45:    - You must implement your own timeouts / cancellation and memory pressure handling.
46: 
47: ### Practical recommendation
48: 
49: Use JSC for:
50: - small, sandboxed scripting surfaces
51: - deterministic, user-visible automation
52: 
53: Avoid JSC for:
54: - running “real” language servers, compilers, large package ecosystems, or heavy compute
55: 
56: ---
57: 
58: ## WebAssembly (Wasm) runtime options
59: 
60: Wasm can be attractive as a portable, sandboxed compute layer. On iOS, what matters is: **where is your Wasm engine hosted** (WebView vs embedded runtime), and **what capabilities you import**.
61: 
62: ### Option A: `WKWebView` WebAssembly
63: 
64: - Safari/WebKit supports WebAssembly, and `WKWebView` is the most common path if you’re already building a web-based execution environment.
65: - Trade-offs:
66:   - Wasm still has **no OS access by default** (no files/network) unless you bridge those from native.
67:   - Background execution and long-running compute are constrained by iOS app lifecycle rules.
68: 
69: ### Option B: JavaScriptCore’s `WebAssembly` global (availability varies)
70: 
71: Depending on iOS/WebKit version and configuration, `WebAssembly` may be missing/disabled in JavaScriptCore contexts.
72: 
73: Evidence of availability pitfalls:
74: - A StackOverflow report shows `WebAssembly` not being defined in JavaScriptCore and `WKWebView` in an iOS 12.4 simulator test (historical but highlights that “it’s there everywhere” is not safe to assume):
75:   - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc
76: - Wasmer’s JavaScriptCore backend post explicitly states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x.”**
77:   - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore
78: 
79: **Recommendation:** treat “Wasm via JSC” as **not a dependable product requirement** unless you validate it on the exact iOS versions you target.
80: 
81: ### Option C: Embed a standalone Wasm runtime (no WebView)
82: 
83: If you need Wasm without WebView, embed a runtime that works without JIT.
84: 
85: Common choices:
86: 
87: - **wasm3** (interpreter)
88:   - The wasm3 README explicitly calls out that on platforms like **iOS** “you can’t generate executable code pages in runtime, so JIT is unavailable.”
89:   - Source: https://github.com/wasm3/wasm3
90: 
91: - **WAMR (WebAssembly Micro Runtime)**
92:   - Common embedded runtime; typically configured as interpreter/AOT depending on platform needs.
93: 
94: - **Wasmer (interpreted backends)**
95:   - Wasmer is multi-backend; its JSC backend is strong on macOS but iOS has had JSC Wasm availability issues (see Wasmer blog above).
96: 
97: #### WASI considerations on iOS
98: 
99: WASI expects OS-like primitives (files, clocks, random, args/env). On iOS, you generally implement these by:
100: - mapping “filesystem” to the app container (Documents/Library/tmp) or an in-memory FS
101: - mapping networking to `URLSession` or a tightly controlled socket layer
102: 
103: This can work well, but you must keep the import surface minimal and audited.
104: 
105: ---
106: 
107: ## Why Python can’t run “natively” (policy + platform constraints)
108: 
109: The most important blocker is **App Store policy around executing downloaded code and changing app behavior post‑review**, plus iOS platform constraints that make “desktop Python” expectations unrealistic.
110: 
111: ### App Store policy: Guideline 2.5.2
112: 
113: Apple’s App Review Guideline **2.5.2** states:
114: 
115: > “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they **download, install, or execute code which introduces or changes features or functionality of the app**, including other apps.”
116: 
117: It also provides a narrow exception:
118: 
119: > “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”
120: 
121: Source:
122: - https://developer.apple.com/app-store/review/guidelines/#software-requirements
123: 
124: **Implication for VSCodeiPadOS:**
125: - Shipping a general-purpose Python environment (interpreter + package installation + arbitrary code execution as a product feature) can be interpreted as enabling new functionality post‑review.
126: - If you want “Python on iPad”, the App Store-compliant route is usually:
127:   - keep it tightly scoped (often educational),
128:   - keep code visible/editable, and
129:   - avoid anything resembling “install arbitrary native capabilities.”
130: 
131: ### Platform constraints (even if policy were satisfied)
132: 
133: Even with an embedded interpreter:
134: - iOS sandboxing blocks typical toolchain patterns (no general subprocess model like desktop, no arbitrary exec of downloaded binaries).
135: - Dynamic native extensions (typical `pip` wheels) are problematic in App Store constraints.
136: - JIT-based Python runtimes (e.g., PyPy JIT) are not generally viable in App Store apps due to iOS code execution restrictions.
137: 
138: ### Practical recommendation
139: 
140: For VS Code-class workflows (toolchains, LSP servers, builds, Python packages):
141: - do **remote execution** (SSH / remote compute service)
142: - keep on-device scripting to languages designed to be embedded (JS/Lua) or sandboxed compute (Wasm)
143: 
144: ---
145: 
146: ## Lua interpreter options
147: 
148: Lua is a strong candidate for on-device scripting because it’s small, embeddable, and easy to sandbox.
149: 
150: ### Option A: Standard PUC-Lua (recommended)
151: 
152: - Embed Lua 5.4/5.3 as a library.
153: - Provide a minimal standard library surface.
154: - Expose only whitelisted host functions (filesystem, settings, editor APIs).
155: 
156: Good for:
157: - macros
158: - editor automation
159: - lightweight “extensions” that are user-visible and easy to audit
160: 
161: ### Option B: LuaJIT (usually not viable)
162: 
163: - LuaJIT’s main advantage depends on JIT compilation.
164: - On iOS, third-party JIT is generally not available without special entitlements.
165: 
166: ### Option C: Lua on top of JS/Wasm
167: 
168: - Lua VM written in JS (e.g., Fengari) can run in JSC.
169: - Lua VM compiled to Wasm can run in an embedded Wasm runtime.
170: 
171: Trade-off: simpler packaging/sandboxing at the cost of performance.
172: 
173: ---
174: 
175: ## Security sandbox restrictions
176: 
177: Everything (JSC/Wasm/Lua) runs under the iOS app sandbox.
178: 
179: ### Filesystem
180: 
181: - Read/write: app container only (Documents/Library/tmp)
182: - No access to system directories (e.g. `/System`, `/etc`) and no direct access to other apps’ containers.
183: 
184: Project reference:
185: - `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md` describes the container layout and access restrictions.
186: 
187: ### Network
188: 
189: - Networking is allowed but controlled:
190:   - App Transport Security (ATS) rules apply (HTTPS-by-default)
191:   - local network access requires the appropriate privacy usage description
192: 
193: Project reference:
194: - `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md` (ATS + network attack vectors)
195: 
196: ### Code execution model
197: 
198: - iOS uses code-signing and W^X style restrictions; you cannot generally allocate memory that is both writable and executable in a normal App Store app.
199: - This drives design choices:
200:   - avoid JIT runtimes
201:   - prefer interpreters or AOT where feasible
202: 
203: ---
204: 
205: ## What is possible on-device vs what requires remote execution
206: 
207: ### On-device (realistic / App Store-friendly)
208: 
209: | Goal | Viable approach |
210: |---|---|
211: | User scripting & automation | JavaScriptCore + strict native bridge, or embedded Lua |
212: | Sandboxed compute modules | Embedded Wasm runtime (e.g., wasm3/WAMR) with minimal imports |
213: | Workspace file operations | Native Swift file APIs constrained to app container, bridged into runtime |
214: | Networking for scripts/plugins | Native `URLSession` bridged into runtime (ATS compliant) |
215: | Simple formatters / linters written in JS/Lua | Run on-device, enforce timeouts + memory limits |
216: 
217: ### Remote execution (often required for “real dev environment”)
218: 
219: | Goal | Why remote is needed |
220: |---|---|
221: | Full Python/Node toolchains, `pip`/`npm`, native deps | Platform sandbox + policy constraints; native extensions/subprocess expectations |
222: | Language servers (LSP) for large ecosystems | Process model + memory footprint + filesystem scanning; better on remote host |
223: | Compilers/build systems (Rust/Go/C++ toolchains) | Not feasible to ship/execute full toolchains on iOS as in desktop environments |
224: | Running arbitrary binaries | iOS app sandbox doesn’t support executing arbitrary downloaded programs |
225: 
226: ### Recommended remote path for this project
227: 
228: Use SSH to a dev machine/container and treat iPad as the IDE client.
229: 
230: Project reference:
231: - `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md` documents SwiftNIO SSH integration for terminal-style remote execution.
232: 
233: ---
234: 
235: ## References
236: 
237: - Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception)
238:   - https://developer.apple.com/app-store/review/guidelines/#software-requirements
239: - Wasmer blog (notes iOS JSC WebAssembly disabled on iOS 16.4.x)
240:   - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore
241: - wasm3 README (iOS can’t generate executable code pages at runtime; interpreter rationale)
242:   - https://github.com/wasm3/wasm3
243: - StackOverflow thread on Wasm in JSC/WKWebView (availability pitfalls)
244:   - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc
245: 


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_JSC_Archive.md","start_line":1,"end_line":40}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_JSC_Archive.md (lines 2-40 of 899)
────────────────────────────────────────
2: 
3: > **Research Date:** January 2025  
4: > **Target Platform:** iOS/iPadOS 17.x+  
5: > **Framework:** JavaScriptCore (JavaScriptCore.framework)
6: 
7: ---
8: 
9: ## Table of Contents
10: 
11: 1. [Overview](#overview)
12: 2. [JSC API Availability](#1-jsc-api-availability-on-iosipados)
13: 3. [Memory Limits](#2-memory-limits)
14: 4. [Execution Time Limits](#3-execution-time-limits)
15: 5. [File System Access](#4-file-system-access-restrictions)
16: 6. [Network Access](#5-network-access-limitations)
17: 7. [JIT Compilation Status](#6-jit-compilation-status)
18: 8. [Performance Benchmarks](#7-performance-benchmarks-vs-macos)
19: 9. [Capabilities & Limitations](#8-what-can-and-cannot-be-done)
20: 10. [Use Cases](#9-example-use-cases)
21: 11. [Remote Execution Needs](#10-limitations-requiring-remote-execution)
22: 12. [Summary Table](#summary-table-of-limits)
23: 
24: ---
25: 
26: ## Overview
27: 
28: JavaScriptCore (JSC) is Apple's high-performance JavaScript engine, powering Safari and available as a public framework (`JavaScriptCore.framework`) for native iOS/iPadOS apps. It enables embedding JavaScript execution within native applications without WebView overhead.
29: 
30: **Key Framework:**
31: - `JavaScriptCore.framework` - Public API since iOS 7
32: - Headers: `<JavaScriptCore/JavaScriptCore.h>`
33: 
34: ---
35: 
36: ## 1. JSC API Availability on iOS/iPadOS
37: 
38: ### Public API Classes
39: 
40: | Class | Purpose | Availability |


>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Docs/
   KeyboardShortcuts.md
   MacServerSetup.md
   OnDeviceResearch_JSC_Archive.md
   OnDeviceResearch.md
   SecurityAudit.md
   SSH_SETUP.md


>>>TOOL patch
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","find":"> **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.\n>\n> This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.","replace":"# On-device runtime research (iOS/iPadOS)\n\n> **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.\n>\n> This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries."}
>>>END
>>>TOOL patch
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","find":"## Why Python can’t run “natively” (policy + platform constraints)\n\nThe most important blocker is **App Store policy around executing downloaded code and changing app behavior post‑review**, plus iOS platform constraints that make “desktop Python” expectations unrealistic.","replace":"## Why Python can’t run “natively” (policy + platform constraints)\n\nFor the purposes of this project, treat **“Python on-device” as not allowed** (i.e. *no general-purpose Python interpreter shipped for arbitrary user code execution*), because it conflicts with App Store expectations around self-contained apps and can look like a mechanism to add/alter functionality after review.\n\nThe most important blocker is **App Store policy around executing downloaded code and changing app behavior post‑review**, plus iOS platform constraints that make “desktop Python” expectations unrealistic."}
>>>END
>>>TOOL patch
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","find":"### Platform constraints (even if policy were satisfied)\n\nEven with an embedded interpreter:\n- iOS sandboxing blocks typical toolchain patterns (no general subprocess model like desktop, no arbitrary exec of downloaded binaries).\n- Dynamic native extensions (typical `pip` wheels) are problematic in App Store constraints.\n- JIT-based Python runtimes (e.g., PyPy JIT) are not generally viable in App Store apps due to iOS code execution restrictions.","replace":"### Platform constraints (even if policy were satisfied)\n\nEven if you embedded CPython in-process, iOS still blocks many expectations that make Python useful for a VS Code-class workflow:\n- **No arbitrary process execution model** like desktop (no running external toolchain binaries you download; limited/unsupported `fork/exec` patterns in the app sandbox).\n- **No loading arbitrary native extension modules downloaded post‑review** (e.g. typical `pip` wheels containing native code).\n- **No JIT** for third-party apps (relevant to PyPy/JIT optimizations) due to iOS code-signing and W^X style restrictions.\n- Filesystem and networking remain sandboxed/entitlement-gated, so Python still needs a strict host bridge for anything beyond pure computation."}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

Error: Tool 'patch' not permitted for this agent (tools=read_write)

---

Error: Tool 'patch' not permitted for this agent (tools=read_write)

---

Error: Tool 'patch' not permitted for this agent (tools=read_write)


>>>TOOL move_file
{"from":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","to":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_SummaryDraft_Archive.md"}
>>>END
>>>TOOL create_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","content":"# On-device runtime research (iOS/iPadOS)\n\n> **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.\n>\n> This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.\n\n## Table of contents\n\n1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)\n2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)\n3. [Why Python can’t run natively (no interpreter allowed)](#why-python-cant-run-natively-no-interpreter-allowed)\n4. [Lua interpreter options](#lua-interpreter-options)\n5. [Security sandbox restrictions](#security-sandbox-restrictions)\n6. [What IS possible vs what requires remote execution](#what-is-possible-vs-what-requires-remote-execution)\n7. [References](#references)\n\n---\n\n## JavaScriptCore (JSC) on iOS: capabilities & limitations\n\n### What JSC is good for\n\nJavaScriptCore (`JavaScriptCore.framework`) is a good fit for **embedded, sandboxed scripting**:\n\n- User scripting / automation (macros, editor actions)\n- Lightweight formatters, parsers, validators\n- Rule engines / expression evaluation\n- “Extension-like” logic **if** you expose a minimal, audited native API surface\n\n### Key limitations (important for “VS Code on iPad”)\n\n1. **Not a web runtime (no browser APIs)**\n   - No DOM.\n   - No `fetch`, `XMLHttpRequest`, `WebSocket`, etc.\n   - Networking, filesystem, and device access must be implemented in native code and bridged into JS.\n\n2. **JIT is generally not available to normal App Store apps**\n   - iOS code-signing + W^X-style restrictions mean third-party apps typically cannot use JIT without special entitlements.\n   - Consequence: CPU-heavy JS workloads can be significantly slower on device than on macOS.\n\n3. **No Node-style module ecosystem**\n   - There is no `require('fs')`/`npm` environment.\n   - If you want modules, you implement a loader yourself and strictly control what “imports” can do.\n\n4. **Resource exhaustion controls are on you**\n   - Embedded JSC does not provide a universal “watchdog” timeout.\n   - You must implement timeouts/cancellation and memory-pressure strategies at the host level.\n\n### Practical recommendation\n\nUse JSC for:\n- small, user-visible scripting surfaces\n- deterministic automation\n- running code that can be paused/limited and that doesn’t need full OS/toolchain access\n\nAvoid JSC for:\n- language servers and full toolchains\n- heavy computation\n- anything that relies on a desktop-like process model\n\n---\n\n## WebAssembly (Wasm) runtime options\n\nWasm is attractive as a portable, sandboxed compute layer. On iOS, the main question is: **where does your Wasm engine live** and **what host functions are you willing to expose**.\n\n### Option A: `WKWebView` WebAssembly (WebKit)\n\n- WebKit in Safari supports WebAssembly, and `WKWebView` can be used to run Wasm in a browser-like JS environment.\n\nTrade-offs:\n- Wasm still has **no OS access** by default (no files/network) unless bridged from native.\n- Background/long-running compute is constrained by iOS app lifecycle rules.\n\nGood fit if:\n- your UI is already WebView-based, or you want a web-style integration surface\n\n### Option B: JavaScriptCore `WebAssembly` global (availability varies)\n\nWhether `WebAssembly` exists inside JavaScriptCore is **not something to assume** across iOS versions.\n\nObserved availability pitfalls:\n- A StackOverflow report shows `WebAssembly` missing in JavaScriptCore and `WKWebView` in an iOS 12.4 simulator scenario (historical, but demonstrates variability).\n- Wasmer’s JavaScriptCore backend write-up states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x.”**\n\n**Recommendation:** treat “Wasm via JSC” as **not a dependable product requirement** unless you validate it on the exact iOS versions you target.\n\n### Option C: Embed a standalone Wasm runtime (no WebView)\n\nIf you need Wasm without WebView, embed a runtime that works without JIT.\n\nCommon choices:\n\n- **wasm3 (interpreter)**\n  - Explicitly calls out that on platforms like **iOS** “you can’t generate executable code pages in runtime, so JIT is unavailable.”\n  - This is aligned with App Store constraints.\n\n- **WAMR (WebAssembly Micro Runtime)**\n  - Often used on embedded/mobile; can be configured for interpreter mode.\n\n- **Wasmer (interpreted backends / iOS support varies by backend)**\n  - Wasmer supports multiple engines/backends; however, its JSC backend is primarily valuable on macOS, and iOS JSC Wasm availability has been inconsistent.\n\n#### WASI considerations on iOS\n\nWASI expects OS-like primitives (files, clocks, random, args/env). On iOS you generally emulate these via host functions:\n\n- Map “filesystem” to the app container (`Documents/`, `Library/`, `tmp/`) or an in-memory FS.\n- Map networking to `URLSession` or a tightly controlled socket layer.\n\nSecurity note: Wasm’s core sandbox is a strength, but **your imports are your attack surface**. Keep the import set minimal and audited.\n\n---\n\n## Why Python can’t run natively (no interpreter allowed)\n\nFor this project, treat **general-purpose Python execution on-device as disallowed**.\n\nThere are two reasons—**App Store policy** (the gating issue for distribution) and **platform constraints** (which make “desktop Python” assumptions invalid anyway).\n\n### 1) App Store policy: downloading/executing code that changes app behavior\n\nApple App Review Guideline **2.5.2** states:\n\n> “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.”\n\nIt also includes a narrow exception for some educational use cases:\n\n> “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”\n\n**Implication for VSCodeiPadOS:**\n- A bundled Python interpreter (plus package installation, plus arbitrary user code) can be interpreted as a mechanism to add/alter functionality after review.\n- Even if you could argue an “educational” exception, that typically requires strict UX constraints (source must be viewable/editable) and still doesn’t solve the rest of the platform limitations below.\n\n### 2) Platform constraints (even if policy were satisfied)\n\nEven embedding CPython in-process doesn’t create a desktop-like environment:\n\n- **No arbitrary process execution model** (you can’t just run downloaded toolchain binaries; the iOS app sandbox does not behave like macOS/Linux).\n- **Native extension modules are a problem** (typical `pip` wheels include native code; loading arbitrary native code post-review is a non-starter).\n- **No JIT for third-party apps** (relevant to PyPy/JIT and some performance strategies), due to iOS code-signing and W^X-style restrictions.\n\n### Practical decision\n\n- Don’t try to be a self-contained Python workstation on iPad.\n- Provide Python (and other toolchains) via **remote execution** (SSH / remote compute).\n\n---\n\n## Lua interpreter options\n\nLua is a strong candidate for on-device scripting because it’s small, embeddable, and easy to sandbox.\n\n### Option A: Standard PUC-Lua (recommended)\n\n- Embed Lua 5.4/5.3 as a library.\n- Provide a minimal standard library surface.\n- Expose only whitelisted host functions (editor APIs, limited filesystem, limited networking).\n\nGood for:\n- macros\n- editor automation\n- small user extensions\n\n### Option B: LuaJIT (usually not viable)\n\n- LuaJIT’s performance depends on JIT compilation.\n- iOS App Store apps generally cannot use JIT without special entitlements.\n\n### Option C: Lua on top of JS/Wasm (fallback)\n\n- Lua VM written in JS (e.g., Fengari) can run in JSC.\n- Lua VM compiled to Wasm can run in an embedded Wasm runtime.\n\nTrade-off: simpler packaging/sandboxing at the cost of performance.\n\n---\n\n## Security sandbox restrictions\n\nEverything (JSC/Wasm/Lua) runs under the iOS app sandbox (“seatbelt” profile).\n\n### Filesystem\n\n- Read/write is limited to the app container:\n  - `Documents/` (user data)\n  - `Library/` (settings/caches)\n  - `tmp/`\n- No access to system directories (`/System`, `/etc`, etc.) and no direct access to other apps’ containers.\n\n### Network\n\n- Networking is allowed but controlled:\n  - **ATS** (App Transport Security) applies (HTTPS by default)\n  - iOS local network privacy requires an appropriate usage description when scanning/connecting to LAN hosts\n\n### “No JIT / no dynamic native code” reality\n\n- iOS’s code-signing model and W^X restrictions strongly constrain any runtime that wants to generate machine code on the fly.\n- Design implications:\n  - prefer interpreters or AOT approaches\n  - keep execution deterministic and limit resource usage\n  - avoid designs that depend on spawning processes or loading arbitrary native code\n\n---\n\n## What IS possible vs what requires remote execution\n\n### What IS possible on-device (realistic / App Store-friendly)\n\n| Goal | Viable approach |\n|---|---|\n| User scripting & automation | JavaScriptCore + strict native bridge, or embedded Lua |\n| Sandboxed compute modules | Embedded Wasm runtime (e.g., wasm3/WAMR) with minimal imports |\n| Workspace file operations | Native Swift file APIs constrained to app container, bridged into runtime |\n| Networking for scripts/plugins | Native `URLSession` bridged into runtime (ATS compliant) |\n| Simple formatters/linters written in JS/Lua | Run on-device, enforce timeouts + memory limits |\n\n### What usually requires remote execution\n\n| Goal | Why remote is needed |\n|---|---|\n| Full Python/Node toolchains, `pip`/`npm`, native deps | Policy + sandbox constraints; native extensions/subprocess expectations |\n| Language servers (LSP) for large ecosystems | Process model + memory footprint + filesystem scanning; better on remote host |\n| Compilers/build systems (Rust/Go/C++ toolchains) | Not feasible to ship/execute full toolchains on iOS like desktop environments |\n| Running arbitrary binaries | iOS sandbox does not support executing arbitrary downloaded programs |\n\n### Recommended remote path for this project\n\nUse SSH to a dev machine/container and treat the iPad as the IDE client.\n\n(See `Docs/SSH_SETUP.md` for the project’s SwiftNIO SSH approach.)\n\n---\n\n## References\n\n- Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception)\n  - https://developer.apple.com/app-store/review/guidelines/#software-requirements\n- Project security notes (sandbox container layout, ATS, etc.)\n  - `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`\n- Project remote execution path (SwiftNIO SSH)\n  - `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md`\n- Wasmer blog (notes iOS JSC WebAssembly disabled on iOS 16.4.x)\n  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore\n- wasm3 README (iOS can’t generate executable code pages at runtime; interpreter rationale)\n  - https://github.com/wasm3/wasm3\n- StackOverflow thread on Wasm in JSC/WKWebView (availability pitfalls)\n  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc\n"}
>>>END

---

## 🔧 TOOL RESULTS

[move_file]
✅ Moved: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md → VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_SummaryDraft_Archive.md

---

[create_file]
✅ Created: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","start_line":1,"end_line":260}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md (lines 2-250 of 250)
────────────────────────────────────────
2: 
3: > **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.
4: >
5: > This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.
6: 
7: ## Table of contents
8: 
9: 1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)
10: 2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)
11: 3. [Why Python can’t run natively (no interpreter allowed)](#why-python-cant-run-natively-no-interpreter-allowed)
12: 4. [Lua interpreter options](#lua-interpreter-options)
13: 5. [Security sandbox restrictions](#security-sandbox-restrictions)
14: 6. [What IS possible vs what requires remote execution](#what-is-possible-vs-what-requires-remote-execution)
15: 7. [References](#references)
16: 
17: ---
18: 
19: ## JavaScriptCore (JSC) on iOS: capabilities & limitations
20: 
21: ### What JSC is good for
22: 
23: JavaScriptCore (`JavaScriptCore.framework`) is a good fit for **embedded, sandboxed scripting**:
24: 
25: - User scripting / automation (macros, editor actions)
26: - Lightweight formatters, parsers, validators
27: - Rule engines / expression evaluation
28: - “Extension-like” logic **if** you expose a minimal, audited native API surface
29: 
30: ### Key limitations (important for “VS Code on iPad”)
31: 
32: 1. **Not a web runtime (no browser APIs)**
33:    - No DOM.
34:    - No `fetch`, `XMLHttpRequest`, `WebSocket`, etc.
35:    - Networking, filesystem, and device access must be implemented in native code and bridged into JS.
36: 
37: 2. **JIT is generally not available to normal App Store apps**
38:    - iOS code-signing + W^X-style restrictions mean third-party apps typically cannot use JIT without special entitlements.
39:    - Consequence: CPU-heavy JS workloads can be significantly slower on device than on macOS.
40: 
41: 3. **No Node-style module ecosystem**
42:    - There is no `require('fs')`/`npm` environment.
43:    - If you want modules, you implement a loader yourself and strictly control what “imports” can do.
44: 
45: 4. **Resource exhaustion controls are on you**
46:    - Embedded JSC does not provide a universal “watchdog” timeout.
47:    - You must implement timeouts/cancellation and memory-pressure strategies at the host level.
48: 
49: ### Practical recommendation
50: 
51: Use JSC for:
52: - small, user-visible scripting surfaces
53: - deterministic automation
54: - running code that can be paused/limited and that doesn’t need full OS/toolchain access
55: 
56: Avoid JSC for:
57: - language servers and full toolchains
58: - heavy computation
59: - anything that relies on a desktop-like process model
60: 
61: ---
62: 
63: ## WebAssembly (Wasm) runtime options
64: 
65: Wasm is attractive as a portable, sandboxed compute layer. On iOS, the main question is: **where does your Wasm engine live** and **what host functions are you willing to expose**.
66: 
67: ### Option A: `WKWebView` WebAssembly (WebKit)
68: 
69: - WebKit in Safari supports WebAssembly, and `WKWebView` can be used to run Wasm in a browser-like JS environment.
70: 
71: Trade-offs:
72: - Wasm still has **no OS access** by default (no files/network) unless bridged from native.
73: - Background/long-running compute is constrained by iOS app lifecycle rules.
74: 
75: Good fit if:
76: - your UI is already WebView-based, or you want a web-style integration surface
77: 
78: ### Option B: JavaScriptCore `WebAssembly` global (availability varies)
79: 
80: Whether `WebAssembly` exists inside JavaScriptCore is **not something to assume** across iOS versions.
81: 
82: Observed availability pitfalls:
83: - A StackOverflow report shows `WebAssembly` missing in JavaScriptCore and `WKWebView` in an iOS 12.4 simulator scenario (historical, but demonstrates variability).
84: - Wasmer’s JavaScriptCore backend write-up states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x.”**
85: 
86: **Recommendation:** treat “Wasm via JSC” as **not a dependable product requirement** unless you validate it on the exact iOS versions you target.
87: 
88: ### Option C: Embed a standalone Wasm runtime (no WebView)
89: 
90: If you need Wasm without WebView, embed a runtime that works without JIT.
91: 
92: Common choices:
93: 
94: - **wasm3 (interpreter)**
95:   - Explicitly calls out that on platforms like **iOS** “you can’t generate executable code pages in runtime, so JIT is unavailable.”
96:   - This is aligned with App Store constraints.
97: 
98: - **WAMR (WebAssembly Micro Runtime)**
99:   - Often used on embedded/mobile; can be configured for interpreter mode.
100: 
101: - **Wasmer (interpreted backends / iOS support varies by backend)**
102:   - Wasmer supports multiple engines/backends; however, its JSC backend is primarily valuable on macOS, and iOS JSC Wasm availability has been inconsistent.
103: 
104: #### WASI considerations on iOS
105: 
106: WASI expects OS-like primitives (files, clocks, random, args/env). On iOS you generally emulate these via host functions:
107: 
108: - Map “filesystem” to the app container (`Documents/`, `Library/`, `tmp/`) or an in-memory FS.
109: - Map networking to `URLSession` or a tightly controlled socket layer.
110: 
111: Security note: Wasm’s core sandbox is a strength, but **your imports are your attack surface**. Keep the import set minimal and audited.
112: 
113: ---
114: 
115: ## Why Python can’t run natively (no interpreter allowed)
116: 
117: For this project, treat **general-purpose Python execution on-device as disallowed**.
118: 
119: There are two reasons—**App Store policy** (the gating issue for distribution) and **platform constraints** (which make “desktop Python” assumptions invalid anyway).
120: 
121: ### 1) App Store policy: downloading/executing code that changes app behavior
122: 
123: Apple App Review Guideline **2.5.2** states:
124: 
125: > “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.”
126: 
127: It also includes a narrow exception for some educational use cases:
128: 
129: > “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”
130: 
131: **Implication for VSCodeiPadOS:**
132: - A bundled Python interpreter (plus package installation, plus arbitrary user code) can be interpreted as a mechanism to add/alter functionality after review.
133: - Even if you could argue an “educational” exception, that typically requires strict UX constraints (source must be viewable/editable) and still doesn’t solve the rest of the platform limitations below.
134: 
135: ### 2) Platform constraints (even if policy were satisfied)
136: 
137: Even embedding CPython in-process doesn’t create a desktop-like environment:
138: 
139: - **No arbitrary process execution model** (you can’t just run downloaded toolchain binaries; the iOS app sandbox does not behave like macOS/Linux).
140: - **Native extension modules are a problem** (typical `pip` wheels include native code; loading arbitrary native code post-review is a non-starter).
141: - **No JIT for third-party apps** (relevant to PyPy/JIT and some performance strategies), due to iOS code-signing and W^X-style restrictions.
142: 
143: ### Practical decision
144: 
145: - Don’t try to be a self-contained Python workstation on iPad.
146: - Provide Python (and other toolchains) via **remote execution** (SSH / remote compute).
147: 
148: ---
149: 
150: ## Lua interpreter options
151: 
152: Lua is a strong candidate for on-device scripting because it’s small, embeddable, and easy to sandbox.
153: 
154: ### Option A: Standard PUC-Lua (recommended)
155: 
156: - Embed Lua 5.4/5.3 as a library.
157: - Provide a minimal standard library surface.
158: - Expose only whitelisted host functions (editor APIs, limited filesystem, limited networking).
159: 
160: Good for:
161: - macros
162: - editor automation
163: - small user extensions
164: 
165: ### Option B: LuaJIT (usually not viable)
166: 
167: - LuaJIT’s performance depends on JIT compilation.
168: - iOS App Store apps generally cannot use JIT without special entitlements.
169: 
170: ### Option C: Lua on top of JS/Wasm (fallback)
171: 
172: - Lua VM written in JS (e.g., Fengari) can run in JSC.
173: - Lua VM compiled to Wasm can run in an embedded Wasm runtime.
174: 
175: Trade-off: simpler packaging/sandboxing at the cost of performance.
176: 
177: ---
178: 
179: ## Security sandbox restrictions
180: 
181: Everything (JSC/Wasm/Lua) runs under the iOS app sandbox (“seatbelt” profile).
182: 
183: ### Filesystem
184: 
185: - Read/write is limited to the app container:
186:   - `Documents/` (user data)
187:   - `Library/` (settings/caches)
188:   - `tmp/`
189: - No access to system directories (`/System`, `/etc`, etc.) and no direct access to other apps’ containers.
190: 
191: ### Network
192: 
193: - Networking is allowed but controlled:
194:   - **ATS** (App Transport Security) applies (HTTPS by default)
195:   - iOS local network privacy requires an appropriate usage description when scanning/connecting to LAN hosts
196: 
197: ### “No JIT / no dynamic native code” reality
198: 
199: - iOS’s code-signing model and W^X restrictions strongly constrain any runtime that wants to generate machine code on the fly.
200: - Design implications:
201:   - prefer interpreters or AOT approaches
202:   - keep execution deterministic and limit resource usage
203:   - avoid designs that depend on spawning processes or loading arbitrary native code
204: 
205: ---
206: 
207: ## What IS possible vs what requires remote execution
208: 
209: ### What IS possible on-device (realistic / App Store-friendly)
210: 
211: | Goal | Viable approach |
212: |---|---|
213: | User scripting & automation | JavaScriptCore + strict native bridge, or embedded Lua |
214: | Sandboxed compute modules | Embedded Wasm runtime (e.g., wasm3/WAMR) with minimal imports |
215: | Workspace file operations | Native Swift file APIs constrained to app container, bridged into runtime |
216: | Networking for scripts/plugins | Native `URLSession` bridged into runtime (ATS compliant) |
217: | Simple formatters/linters written in JS/Lua | Run on-device, enforce timeouts + memory limits |
218: 
219: ### What usually requires remote execution
220: 
221: | Goal | Why remote is needed |
222: |---|---|
223: | Full Python/Node toolchains, `pip`/`npm`, native deps | Policy + sandbox constraints; native extensions/subprocess expectations |
224: | Language servers (LSP) for large ecosystems | Process model + memory footprint + filesystem scanning; better on remote host |
225: | Compilers/build systems (Rust/Go/C++ toolchains) | Not feasible to ship/execute full toolchains on iOS like desktop environments |
226: | Running arbitrary binaries | iOS sandbox does not support executing arbitrary downloaded programs |
227: 
228: ### Recommended remote path for this project
229: 
230: Use SSH to a dev machine/container and treat the iPad as the IDE client.
231: 
232: (See `Docs/SSH_SETUP.md` for the project’s SwiftNIO SSH approach.)
233: 
234: ---
235: 
236: ## References
237: 
238: - Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception)
239:   - https://developer.apple.com/app-store/review/guidelines/#software-requirements
240: - Project security notes (sandbox container layout, ATS, etc.)
241:   - `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`
242: - Project remote execution path (SwiftNIO SSH)
243:   - `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md`
244: - Wasmer blog (notes iOS JSC WebAssembly disabled on iOS 16.4.x)
245:   - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore
246: - wasm3 README (iOS can’t generate executable code pages at runtime; interpreter rationale)
247:   - https://github.com/wasm3/wasm3
248: - StackOverflow thread on Wasm in JSC/WKWebView (availability pitfalls)
249:   - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc
250: 


>>>TOOL move_file
{"from":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","to":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_TempArchive.md"}
>>>END
>>>TOOL create_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","content":"# On-device runtime research (iOS/iPadOS)\n\n> **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.\n>\n> This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.\n>\n> **Note:** A longer, JavaScriptCore-only deep dive was preserved as `OnDeviceResearch_JSC_Archive.md`.\n\n## Table of contents\n\n1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)\n2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)\n3. [Why Python can’t run natively (no interpreter allowed)](#why-python-cant-run-natively-no-interpreter-allowed)\n4. [Lua interpreter options](#lua-interpreter-options)\n5. [Security sandbox restrictions](#security-sandbox-restrictions)\n6. [What IS possible vs what requires remote execution](#what-is-possible-vs-what-requires-remote-execution)\n7. [References](#references)\n\n---\n\n## JavaScriptCore (JSC) on iOS: capabilities & limitations\n\n### What JSC is good for\n\nJavaScriptCore (`JavaScriptCore.framework`) is a good fit for **embedded, sandboxed scripting**:\n\n- User scripting / automation (macros, editor actions)\n- Lightweight formatters, parsers, validators\n- Rule engines / expression evaluation\n- “Extension-like” logic **if** you expose a minimal, audited native API surface\n\n### Key limitations (important for “VS Code on iPad”)\n\n1. **Not a web runtime (no browser APIs)**\n   - No DOM.\n   - No `fetch`, `XMLHttpRequest`, `WebSocket`, etc.\n   - Networking, filesystem, and device access must be implemented in native code and bridged into JS.\n\n2. **JIT is generally not available to normal App Store apps**\n   - iOS code-signing + W^X-style restrictions mean third-party apps typically cannot use JIT without special entitlements.\n   - Consequence: CPU-heavy JS workloads can be significantly slower on device than on macOS.\n\n3. **No Node-style module ecosystem**\n   - There is no `require('fs')`/`npm` environment.\n   - If you want modules, you implement a loader yourself and strictly control what “imports” can do.\n\n4. **Resource exhaustion controls are on you**\n   - Embedded JSC does not provide a universal “watchdog” timeout.\n   - You must implement timeouts/cancellation and memory-pressure strategies at the host level.\n\n### Practical recommendation\n\nUse JSC for:\n- small, user-visible scripting surfaces\n- deterministic automation\n- running code that can be paused/limited and that doesn’t need full OS/toolchain access\n\nAvoid JSC for:\n- language servers and full toolchains\n- heavy computation\n- anything that relies on a desktop-like process model\n\n---\n\n## WebAssembly (Wasm) runtime options\n\nWasm is attractive as a portable, sandboxed compute layer. On iOS, the main question is: **where does your Wasm engine live** and **what host functions are you willing to expose**.\n\n### Option A: `WKWebView` WebAssembly (WebKit)\n\n- WebKit in Safari supports WebAssembly, and `WKWebView` can be used to run Wasm in a browser-like JS environment.\n\nTrade-offs:\n- Wasm still has **no OS access** by default (no files/network) unless bridged from native.\n- Background/long-running compute is constrained by iOS app lifecycle rules.\n\nGood fit if:\n- your UI is already WebView-based, or you want a web-style integration surface\n\n### Option B: JavaScriptCore `WebAssembly` global (availability varies)\n\nWhether `WebAssembly` exists inside JavaScriptCore is **not something to assume** across iOS versions.\n\nObserved availability pitfalls:\n- A StackOverflow report shows `WebAssembly` missing in JavaScriptCore and `WKWebView` in an iOS 12.4 simulator scenario (historical, but demonstrates variability):\n  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc\n- Wasmer’s JavaScriptCore backend write-up states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x.”**\n  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore\n\n**Recommendation:** treat “Wasm via JSC” as **not a dependable product requirement** unless you validate it on the exact iOS versions you target.\n\n### Option C: Embed a standalone Wasm runtime (no WebView)\n\nIf you need Wasm without WebView, embed a runtime that works without JIT.\n\nCommon choices:\n\n- **wasm3 (interpreter)**\n  - Explicitly calls out that on platforms like **iOS** “you can’t generate executable code pages in runtime, so JIT is unavailable.”\n  - Source: https://github.com/wasm3/wasm3\n\n- **WAMR (WebAssembly Micro Runtime)**\n  - Often used on embedded/mobile; can be configured for interpreter mode.\n\n- **Wasmer (interpreted backends / iOS support varies by backend)**\n  - Wasmer supports multiple engines/backends; however, its JSC backend is primarily valuable on macOS, and iOS JSC Wasm availability has been inconsistent.\n\n#### WASI considerations on iOS\n\nWASI expects OS-like primitives (files, clocks, random, args/env). On iOS you generally emulate these via host functions:\n\n- Map “filesystem” to the app container (`Documents/`, `Library/`, `tmp/`) or an in-memory FS.\n- Map networking to `URLSession` or a tightly controlled socket layer.\n\nSecurity note: Wasm’s core sandbox is a strength, but **your imports are your attack surface**. Keep the import set minimal and audited.\n\n---\n\n## Why Python can’t run natively (no interpreter allowed)\n\nFor this project, treat **general-purpose Python execution on-device as disallowed**.\n\nThere are two reasons—**App Store policy** (the gating issue for distribution) and **platform constraints** (which make “desktop Python” assumptions invalid anyway).\n\n### 1) App Store policy: downloading/executing code that changes app behavior\n\nApple App Review Guideline **2.5.2** states:\n\n> “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.”\n\nIt also includes a narrow exception for some educational use cases:\n\n> “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”\n\nSource:\n- https://developer.apple.com/app-store/review/guidelines/#software-requirements\n\n**Implication for VSCodeiPadOS:**\n- A bundled Python interpreter (plus package installation, plus arbitrary user code) can be interpreted as a mechanism to add/alter functionality after review.\n- Even if you could argue an “educational” exception, that typically requires strict UX constraints (source must be viewable/editable) and still doesn’t solve the rest of the platform limitations below.\n\n### 2) Platform constraints (even if policy were satisfied)\n\nEven embedding CPython in-process doesn’t create a desktop-like environment:\n\n- **No arbitrary process execution model** (you can’t just run downloaded toolchain binaries; the iOS app sandbox does not behave like macOS/Linux).\n- **Native extension modules are a problem** (typical `pip` wheels include native code; loading arbitrary native code post-review is a non-starter).\n- **No JIT for third-party apps** (relevant to PyPy/JIT and some performance strategies), due to iOS code-signing and W^X-style restrictions.\n\n### Practical decision\n\n- Don’t try to be a self-contained Python workstation on iPad.\n- Provide Python (and other toolchains) via **remote execution** (SSH / remote compute).\n\n---\n\n## Lua interpreter options\n\nLua is a strong candidate for on-device scripting because it’s small, embeddable, and easy to sandbox.\n\n### Option A: Standard PUC-Lua (recommended)\n\n- Embed Lua 5.4/5.3 as a library.\n- Provide a minimal standard library surface.\n- Expose only whitelisted host functions (editor APIs, limited filesystem, limited networking).\n\nGood for:\n- macros\n- editor automation\n- small user extensions\n\n### Option B: LuaJIT (usually not viable)\n\n- LuaJIT’s performance depends on JIT compilation.\n- iOS App Store apps generally cannot use JIT without special entitlements.\n\n### Option C: Lua on top of JS/Wasm (fallback)\n\n- Lua VM written in JS (e.g., Fengari) can run in JSC.\n- Lua VM compiled to Wasm can run in an embedded Wasm runtime.\n\nTrade-off: simpler packaging/sandboxing at the cost of performance.\n\n---\n\n## Security sandbox restrictions\n\nEverything (JSC/Wasm/Lua) runs under the iOS app sandbox (“seatbelt” profile).\n\n### Filesystem\n\n- Read/write is limited to the app container:\n  - `Documents/` (user data)\n  - `Library/` (settings/caches)\n  - `tmp/`\n- No access to system directories (`/System`, `/etc`, etc.) and no direct access to other apps’ containers.\n\n(See also: `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`.)\n\n### Network\n\n- Networking is allowed but controlled:\n  - **ATS** (App Transport Security) applies (HTTPS by default)\n  - iOS local network privacy requires an appropriate usage description when scanning/connecting to LAN hosts\n\n(See also: `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`.)\n\n### “No JIT / no dynamic native code” reality\n\n- iOS’s code-signing model and W^X restrictions strongly constrain any runtime that wants to generate machine code on the fly.\n- Design implications:\n  - prefer interpreters or AOT approaches\n  - keep execution deterministic and limit resource usage\n  - avoid designs that depend on spawning processes or loading arbitrary native code\n\n---\n\n## What IS possible vs what requires remote execution\n\n### What IS possible on-device (realistic / App Store-friendly)\n\n| Goal | Viable approach |\n|---|---|\n| User scripting & automation | JavaScriptCore + strict native bridge, or embedded Lua |\n| Sandboxed compute modules | Embedded Wasm runtime (e.g., wasm3/WAMR) with minimal imports |\n| Workspace file operations | Native Swift file APIs constrained to app container, bridged into runtime |\n| Networking for scripts/plugins | Native `URLSession` bridged into runtime (ATS compliant) |\n| Simple formatters/linters written in JS/Lua | Run on-device, enforce timeouts + memory limits |\n\n### What usually requires remote execution\n\n| Goal | Why remote is needed |\n|---|---|\n| Full Python/Node toolchains, `pip`/`npm`, native deps | Policy + sandbox constraints; native extensions/subprocess expectations |\n| Language servers (LSP) for large ecosystems | Process model + memory footprint + filesystem scanning; better on remote host |\n| Compilers/build systems (Rust/Go/C++ toolchains) | Not feasible to ship/execute full toolchains on iOS like desktop environments |\n| Running arbitrary binaries | iOS sandbox does not support executing arbitrary downloaded programs |\n\n### Recommended remote path for this project\n\nUse SSH to a dev machine/container and treat the iPad as the IDE client.\n\nSee: `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md`.\n\n---\n\n## References\n\n- Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception)\n  - https://developer.apple.com/app-store/review/guidelines/#software-requirements\n- Project security notes\n  - `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`\n- Project remote execution path (SwiftNIO SSH)\n  - `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md`\n- Wasmer blog (notes iOS JSC WebAssembly disabled on iOS 16.4.x)\n  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore\n- wasm3 README (iOS can’t generate executable code pages at runtime; interpreter rationale)\n  - https://github.com/wasm3/wasm3\n- StackOverflow thread on Wasm in JSC/WKWebView (availability pitfalls)\n  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc\n"}
>>>END

---

## 🔧 TOOL RESULTS

[move_file]
✅ Moved: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md → VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_TempArchive.md

---

[create_file]
✅ Created: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","start_line":1,"end_line":40}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md (lines 2-40 of 261)
────────────────────────────────────────
2: 
3: > **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.
4: >
5: > This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.
6: >
7: > **Note:** A longer, JavaScriptCore-only deep dive was preserved as `OnDeviceResearch_JSC_Archive.md`.
8: 
9: ## Table of contents
10: 
11: 1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)
12: 2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)
13: 3. [Why Python can’t run natively (no interpreter allowed)](#why-python-cant-run-natively-no-interpreter-allowed)
14: 4. [Lua interpreter options](#lua-interpreter-options)
15: 5. [Security sandbox restrictions](#security-sandbox-restrictions)
16: 6. [What IS possible vs what requires remote execution](#what-is-possible-vs-what-requires-remote-execution)
17: 7. [References](#references)
18: 
19: ---
20: 
21: ## JavaScriptCore (JSC) on iOS: capabilities & limitations
22: 
23: ### What JSC is good for
24: 
25: JavaScriptCore (`JavaScriptCore.framework`) is a good fit for **embedded, sandboxed scripting**:
26: 
27: - User scripting / automation (macros, editor actions)
28: - Lightweight formatters, parsers, validators
29: - Rule engines / expression evaluation
30: - “Extension-like” logic **if** you expose a minimal, audited native API surface
31: 
32: ### Key limitations (important for “VS Code on iPad”)
33: 
34: 1. **Not a web runtime (no browser APIs)**
35:    - No DOM.
36:    - No `fetch`, `XMLHttpRequest`, `WebSocket`, etc.
37:    - Networking, filesystem, and device access must be implemented in native code and bridged into JS.
38: 
39: 2. **JIT is generally not available to normal App Store apps**
40:    - iOS code-signing + W^X-style restrictions mean third-party apps typically cannot use JIT without special entitlements.


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","start_line":1,"end_line":15}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md (lines 2-15 of 261)
────────────────────────────────────────
2: 
3: > **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.
4: >
5: > This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.
6: >
7: > **Note:** A longer, JavaScriptCore-only deep dive was preserved as `OnDeviceResearch_JSC_Archive.md`.
8: 
9: ## Table of contents
10: 
11: 1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)
12: 2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)
13: 3. [Why Python can’t run natively (no interpreter allowed)](#why-python-cant-run-natively-no-interpreter-allowed)
14: 4. [Lua interpreter options](#lua-interpreter-options)
15: 5. [Security sandbox restrictions](#security-sandbox-restrictions)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","start_line":1,"end_line":300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md (lines 2-261 of 261)
────────────────────────────────────────
2: 
3: > **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.
4: >
5: > This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.
6: >
7: > **Note:** A longer, JavaScriptCore-only deep dive was preserved as `OnDeviceResearch_JSC_Archive.md`.
8: 
9: ## Table of contents
10: 
11: 1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)
12: 2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)
13: 3. [Why Python can’t run natively (no interpreter allowed)](#why-python-cant-run-natively-no-interpreter-allowed)
14: 4. [Lua interpreter options](#lua-interpreter-options)
15: 5. [Security sandbox restrictions](#security-sandbox-restrictions)
16: 6. [What IS possible vs what requires remote execution](#what-is-possible-vs-what-requires-remote-execution)
17: 7. [References](#references)
18: 
19: ---
20: 
21: ## JavaScriptCore (JSC) on iOS: capabilities & limitations
22: 
23: ### What JSC is good for
24: 
25: JavaScriptCore (`JavaScriptCore.framework`) is a good fit for **embedded, sandboxed scripting**:
26: 
27: - User scripting / automation (macros, editor actions)
28: - Lightweight formatters, parsers, validators
29: - Rule engines / expression evaluation
30: - “Extension-like” logic **if** you expose a minimal, audited native API surface
31: 
32: ### Key limitations (important for “VS Code on iPad”)
33: 
34: 1. **Not a web runtime (no browser APIs)**
35:    - No DOM.
36:    - No `fetch`, `XMLHttpRequest`, `WebSocket`, etc.
37:    - Networking, filesystem, and device access must be implemented in native code and bridged into JS.
38: 
39: 2. **JIT is generally not available to normal App Store apps**
40:    - iOS code-signing + W^X-style restrictions mean third-party apps typically cannot use JIT without special entitlements.
41:    - Consequence: CPU-heavy JS workloads can be significantly slower on device than on macOS.
42: 
43: 3. **No Node-style module ecosystem**
44:    - There is no `require('fs')`/`npm` environment.
45:    - If you want modules, you implement a loader yourself and strictly control what “imports” can do.
46: 
47: 4. **Resource exhaustion controls are on you**
48:    - Embedded JSC does not provide a universal “watchdog” timeout.
49:    - You must implement timeouts/cancellation and memory-pressure strategies at the host level.
50: 
51: ### Practical recommendation
52: 
53: Use JSC for:
54: - small, user-visible scripting surfaces
55: - deterministic automation
56: - running code that can be paused/limited and that doesn’t need full OS/toolchain access
57: 
58: Avoid JSC for:
59: - language servers and full toolchains
60: - heavy computation
61: - anything that relies on a desktop-like process model
62: 
63: ---
64: 
65: ## WebAssembly (Wasm) runtime options
66: 
67: Wasm is attractive as a portable, sandboxed compute layer. On iOS, the main question is: **where does your Wasm engine live** and **what host functions are you willing to expose**.
68: 
69: ### Option A: `WKWebView` WebAssembly (WebKit)
70: 
71: - WebKit in Safari supports WebAssembly, and `WKWebView` can be used to run Wasm in a browser-like JS environment.
72: 
73: Trade-offs:
74: - Wasm still has **no OS access** by default (no files/network) unless bridged from native.
75: - Background/long-running compute is constrained by iOS app lifecycle rules.
76: 
77: Good fit if:
78: - your UI is already WebView-based, or you want a web-style integration surface
79: 
80: ### Option B: JavaScriptCore `WebAssembly` global (availability varies)
81: 
82: Whether `WebAssembly` exists inside JavaScriptCore is **not something to assume** across iOS versions.
83: 
84: Observed availability pitfalls:
85: - A StackOverflow report shows `WebAssembly` missing in JavaScriptCore and `WKWebView` in an iOS 12.4 simulator scenario (historical, but demonstrates variability):
86:   - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc
87: - Wasmer’s JavaScriptCore backend write-up states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x.”**
88:   - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore
89: 
90: **Recommendation:** treat “Wasm via JSC” as **not a dependable product requirement** unless you validate it on the exact iOS versions you target.
91: 
92: ### Option C: Embed a standalone Wasm runtime (no WebView)
93: 
94: If you need Wasm without WebView, embed a runtime that works without JIT.
95: 
96: Common choices:
97: 
98: - **wasm3 (interpreter)**
99:   - Explicitly calls out that on platforms like **iOS** “you can’t generate executable code pages in runtime, so JIT is unavailable.”
100:   - Source: https://github.com/wasm3/wasm3
101: 
102: - **WAMR (WebAssembly Micro Runtime)**
103:   - Often used on embedded/mobile; can be configured for interpreter mode.
104: 
105: - **Wasmer (interpreted backends / iOS support varies by backend)**
106:   - Wasmer supports multiple engines/backends; however, its JSC backend is primarily valuable on macOS, and iOS JSC Wasm availability has been inconsistent.
107: 
108: #### WASI considerations on iOS
109: 
110: WASI expects OS-like primitives (files, clocks, random, args/env). On iOS you generally emulate these via host functions:
111: 
112: - Map “filesystem” to the app container (`Documents/`, `Library/`, `tmp/`) or an in-memory FS.
113: - Map networking to `URLSession` or a tightly controlled socket layer.
114: 
115: Security note: Wasm’s core sandbox is a strength, but **your imports are your attack surface**. Keep the import set minimal and audited.
116: 
117: ---
118: 
119: ## Why Python can’t run natively (no interpreter allowed)
120: 
121: For this project, treat **general-purpose Python execution on-device as disallowed**.
122: 
123: There are two reasons—**App Store policy** (the gating issue for distribution) and **platform constraints** (which make “desktop Python” assumptions invalid anyway).
124: 
125: ### 1) App Store policy: downloading/executing code that changes app behavior
126: 
127: Apple App Review Guideline **2.5.2** states:
128: 
129: > “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.”
130: 
131: It also includes a narrow exception for some educational use cases:
132: 
133: > “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”
134: 
135: Source:
136: - https://developer.apple.com/app-store/review/guidelines/#software-requirements
137: 
138: **Implication for VSCodeiPadOS:**
139: - A bundled Python interpreter (plus package installation, plus arbitrary user code) can be interpreted as a mechanism to add/alter functionality after review.
140: - Even if you could argue an “educational” exception, that typically requires strict UX constraints (source must be viewable/editable) and still doesn’t solve the rest of the platform limitations below.
141: 
142: ### 2) Platform constraints (even if policy were satisfied)
143: 
144: Even embedding CPython in-process doesn’t create a desktop-like environment:
145: 
146: - **No arbitrary process execution model** (you can’t just run downloaded toolchain binaries; the iOS app sandbox does not behave like macOS/Linux).
147: - **Native extension modules are a problem** (typical `pip` wheels include native code; loading arbitrary native code post-review is a non-starter).
148: - **No JIT for third-party apps** (relevant to PyPy/JIT and some performance strategies), due to iOS code-signing and W^X-style restrictions.
149: 
150: ### Practical decision
151: 
152: - Don’t try to be a self-contained Python workstation on iPad.
153: - Provide Python (and other toolchains) via **remote execution** (SSH / remote compute).
154: 
155: ---
156: 
157: ## Lua interpreter options
158: 
159: Lua is a strong candidate for on-device scripting because it’s small, embeddable, and easy to sandbox.
160: 
161: ### Option A: Standard PUC-Lua (recommended)
162: 
163: - Embed Lua 5.4/5.3 as a library.
164: - Provide a minimal standard library surface.
165: - Expose only whitelisted host functions (editor APIs, limited filesystem, limited networking).
166: 
167: Good for:
168: - macros
169: - editor automation
170: - small user extensions
171: 
172: ### Option B: LuaJIT (usually not viable)
173: 
174: - LuaJIT’s performance depends on JIT compilation.
175: - iOS App Store apps generally cannot use JIT without special entitlements.
176: 
177: ### Option C: Lua on top of JS/Wasm (fallback)
178: 
179: - Lua VM written in JS (e.g., Fengari) can run in JSC.
180: - Lua VM compiled to Wasm can run in an embedded Wasm runtime.
181: 
182: Trade-off: simpler packaging/sandboxing at the cost of performance.
183: 
184: ---
185: 
186: ## Security sandbox restrictions
187: 
188: Everything (JSC/Wasm/Lua) runs under the iOS app sandbox (“seatbelt” profile).
189: 
190: ### Filesystem
191: 
192: - Read/write is limited to the app container:
193:   - `Documents/` (user data)
194:   - `Library/` (settings/caches)
195:   - `tmp/`
196: - No access to system directories (`/System`, `/etc`, etc.) and no direct access to other apps’ containers.
197: 
198: (See also: `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`.)
199: 
200: ### Network
201: 
202: - Networking is allowed but controlled:
203:   - **ATS** (App Transport Security) applies (HTTPS by default)
204:   - iOS local network privacy requires an appropriate usage description when scanning/connecting to LAN hosts
205: 
206: (See also: `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`.)
207: 
208: ### “No JIT / no dynamic native code” reality
209: 
210: - iOS’s code-signing model and W^X restrictions strongly constrain any runtime that wants to generate machine code on the fly.
211: - Design implications:
212:   - prefer interpreters or AOT approaches
213:   - keep execution deterministic and limit resource usage
214:   - avoid designs that depend on spawning processes or loading arbitrary native code
215: 
216: ---
217: 
218: ## What IS possible vs what requires remote execution
219: 
220: ### What IS possible on-device (realistic / App Store-friendly)
221: 
222: | Goal | Viable approach |
223: |---|---|
224: | User scripting & automation | JavaScriptCore + strict native bridge, or embedded Lua |
225: | Sandboxed compute modules | Embedded Wasm runtime (e.g., wasm3/WAMR) with minimal imports |
226: | Workspace file operations | Native Swift file APIs constrained to app container, bridged into runtime |
227: | Networking for scripts/plugins | Native `URLSession` bridged into runtime (ATS compliant) |
228: | Simple formatters/linters written in JS/Lua | Run on-device, enforce timeouts + memory limits |
229: 
230: ### What usually requires remote execution
231: 
232: | Goal | Why remote is needed |
233: |---|---|
234: | Full Python/Node toolchains, `pip`/`npm`, native deps | Policy + sandbox constraints; native extensions/subprocess expectations |
235: | Language servers (LSP) for large ecosystems | Process model + memory footprint + filesystem scanning; better on remote host |
236: | Compilers/build systems (Rust/Go/C++ toolchains) | Not feasible to ship/execute full toolchains on iOS like desktop environments |
237: | Running arbitrary binaries | iOS sandbox does not support executing arbitrary downloaded programs |
238: 
239: ### Recommended remote path for this project
240: 
241: Use SSH to a dev machine/container and treat the iPad as the IDE client.
242: 
243: See: `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md`.
244: 
245: ---
246: 
247: ## References
248: 
249: - Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception)
250:   - https://developer.apple.com/app-store/review/guidelines/#software-requirements
251: - Project security notes
252:   - `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`
253: - Project remote execution path (SwiftNIO SSH)
254:   - `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md`
255: - Wasmer blog (notes iOS JSC WebAssembly disabled on iOS 16.4.x)
256:   - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore
257: - wasm3 README (iOS can’t generate executable code pages at runtime; interpreter rationale)
258:   - https://github.com/wasm3/wasm3
259: - StackOverflow thread on Wasm in JSC/WKWebView (availability pitfalls)
260:   - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc
261: 


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","start_line":1,"end_line":8}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md (lines 2-8 of 261)
────────────────────────────────────────
2: 
3: > **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.
4: >
5: > This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.
6: >
7: > **Note:** A longer, JavaScriptCore-only deep dive was preserved as `OnDeviceResearch_JSC_Archive.md`.
8: 


>>>TOOL move_file
{"from":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","to":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_HeaderFix_Archive.md"}
>>>END
>>>TOOL create_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","content":"# On-device runtime research (iOS/iPadOS)\n\n> **Focus:** What code can realistically run *on device* inside an App Store iOS/iPadOS app, and what should be offloaded to remote execution.\n>\n> This doc is intended for VSCodeiPadOS design decisions around language runtimes, extension models, and sandbox/security boundaries.\n>\n> **Note:** A longer, JavaScriptCore-only deep dive was preserved as `OnDeviceResearch_JSC_Archive.md`.\n\n## Table of contents\n\n1. [JavaScriptCore (JSC) on iOS: capabilities & limitations](#javascriptcore-jsc-on-ios-capabilities--limitations)\n2. [WebAssembly (Wasm) runtime options](#webassembly-wasm-runtime-options)\n3. [Why Python can’t run natively (no interpreter allowed)](#why-python-cant-run-natively-no-interpreter-allowed)\n4. [Lua interpreter options](#lua-interpreter-options)\n5. [Security sandbox restrictions](#security-sandbox-restrictions)\n6. [What IS possible vs what requires remote execution](#what-is-possible-vs-what-requires-remote-execution)\n7. [References](#references)\n\n---\n\n## JavaScriptCore (JSC) on iOS: capabilities & limitations\n\n### What JSC is good for\n\nJavaScriptCore (`JavaScriptCore.framework`) is a good fit for **embedded, sandboxed scripting**:\n\n- User scripting / automation (macros, editor actions)\n- Lightweight formatters, parsers, validators\n- Rule engines / expression evaluation\n- “Extension-like” logic **if** you expose a minimal, audited native API surface\n\n### Key limitations (important for “VS Code on iPad”)\n\n1. **Not a web runtime (no browser APIs)**\n   - No DOM.\n   - No `fetch`, `XMLHttpRequest`, `WebSocket`, etc.\n   - Networking, filesystem, and device access must be implemented in native code and bridged into JS.\n\n2. **JIT is generally not available to normal App Store apps**\n   - iOS code-signing + W^X-style restrictions mean third-party apps typically cannot use JIT without special entitlements.\n   - Consequence: CPU-heavy JS workloads can be significantly slower on device than on macOS.\n\n3. **No Node-style module ecosystem**\n   - There is no `require('fs')`/`npm` environment.\n   - If you want modules, you implement a loader yourself and strictly control what “imports” can do.\n\n4. **Resource exhaustion controls are on you**\n   - Embedded JSC does not provide a universal “watchdog” timeout.\n   - You must implement timeouts/cancellation and memory-pressure strategies at the host level.\n\n### Practical recommendation\n\nUse JSC for:\n- small, user-visible scripting surfaces\n- deterministic automation\n- running code that can be paused/limited and that doesn’t need full OS/toolchain access\n\nAvoid JSC for:\n- language servers and full toolchains\n- heavy computation\n- anything that relies on a desktop-like process model\n\n---\n\n## WebAssembly (Wasm) runtime options\n\nWasm is attractive as a portable, sandboxed compute layer. On iOS, the main question is: **where does your Wasm engine live** and **what host functions are you willing to expose**.\n\n### Option A: `WKWebView` WebAssembly (WebKit)\n\n- WebKit in Safari supports WebAssembly, and `WKWebView` can be used to run Wasm in a browser-like JS environment.\n\nTrade-offs:\n- Wasm still has **no OS access** by default (no files/network) unless bridged from native.\n- Background/long-running compute is constrained by iOS app lifecycle rules.\n\nGood fit if:\n- your UI is already WebView-based, or you want a web-style integration surface\n\n### Option B: JavaScriptCore `WebAssembly` global (availability varies)\n\nWhether `WebAssembly` exists inside JavaScriptCore is **not something to assume** across iOS versions.\n\nObserved availability pitfalls:\n- A StackOverflow report shows `WebAssembly` missing in JavaScriptCore and `WKWebView` in an iOS 12.4 simulator scenario (historical, but demonstrates variability):\n  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc\n- Wasmer’s JavaScriptCore backend write-up states: **“Apple disabled WebAssembly in JSC for iOS 16.4.x.”**\n  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore\n\n**Recommendation:** treat “Wasm via JSC” as **not a dependable product requirement** unless you validate it on the exact iOS versions you target.\n\n### Option C: Embed a standalone Wasm runtime (no WebView)\n\nIf you need Wasm without WebView, embed a runtime that works without JIT.\n\nCommon choices:\n\n- **wasm3 (interpreter)**\n  - Explicitly calls out that on platforms like **iOS** “you can’t generate executable code pages in runtime, so JIT is unavailable.”\n  - Source: https://github.com/wasm3/wasm3\n\n- **WAMR (WebAssembly Micro Runtime)**\n  - Often used on embedded/mobile; can be configured for interpreter mode.\n\n- **Wasmer (interpreted backends / iOS support varies by backend)**\n  - Wasmer supports multiple engines/backends; however, its JSC backend is primarily valuable on macOS, and iOS JSC Wasm availability has been inconsistent.\n\n#### WASI considerations on iOS\n\nWASI expects OS-like primitives (files, clocks, random, args/env). On iOS you generally emulate these via host functions:\n\n- Map “filesystem” to the app container (`Documents/`, `Library/`, `tmp/`) or an in-memory FS.\n- Map networking to `URLSession` or a tightly controlled socket layer.\n\nSecurity note: Wasm’s core sandbox is a strength, but **your imports are your attack surface**. Keep the import set minimal and audited.\n\n---\n\n## Why Python can’t run natively (no interpreter allowed)\n\nFor this project, treat **general-purpose Python execution on-device as disallowed**.\n\nThere are two reasons—**App Store policy** (the gating issue for distribution) and **platform constraints** (which make “desktop Python” assumptions invalid anyway).\n\n### 1) App Store policy: downloading/executing code that changes app behavior\n\nApple App Review Guideline **2.5.2** states:\n\n> “Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps.”\n\nIt also includes a narrow exception for some educational use cases:\n\n> “Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code… Such apps must make the source code provided by the app completely viewable and editable by the user.”\n\nSource:\n- https://developer.apple.com/app-store/review/guidelines/#software-requirements\n\n**Implication for VSCodeiPadOS:**\n- A bundled Python interpreter (plus package installation, plus arbitrary user code) can be interpreted as a mechanism to add/alter functionality after review.\n- Even if you could argue an “educational” exception, that typically requires strict UX constraints (source must be viewable/editable) and still doesn’t solve the rest of the platform limitations below.\n\n### 2) Platform constraints (even if policy were satisfied)\n\nEven embedding CPython in-process doesn’t create a desktop-like environment:\n\n- **No arbitrary process execution model** (you can’t just run downloaded toolchain binaries; the iOS app sandbox does not behave like macOS/Linux).\n- **Native extension modules are a problem** (typical `pip` wheels include native code; loading arbitrary native code post-review is a non-starter).\n- **No JIT for third-party apps** (relevant to PyPy/JIT and some performance strategies), due to iOS code-signing and W^X-style restrictions.\n\n### Practical decision\n\n- Don’t try to be a self-contained Python workstation on iPad.\n- Provide Python (and other toolchains) via **remote execution** (SSH / remote compute).\n\n---\n\n## Lua interpreter options\n\nLua is a strong candidate for on-device scripting because it’s small, embeddable, and easy to sandbox.\n\n### Option A: Standard PUC-Lua (recommended)\n\n- Embed Lua 5.4/5.3 as a library.\n- Provide a minimal standard library surface.\n- Expose only whitelisted host functions (editor APIs, limited filesystem, limited networking).\n\nGood for:\n- macros\n- editor automation\n- small user extensions\n\n### Option B: LuaJIT (usually not viable)\n\n- LuaJIT’s performance depends on JIT compilation.\n- iOS App Store apps generally cannot use JIT without special entitlements.\n\n### Option C: Lua on top of JS/Wasm (fallback)\n\n- Lua VM written in JS (e.g., Fengari) can run in JSC.\n- Lua VM compiled to Wasm can run in an embedded Wasm runtime.\n\nTrade-off: simpler packaging/sandboxing at the cost of performance.\n\n---\n\n## Security sandbox restrictions\n\nEverything (JSC/Wasm/Lua) runs under the iOS app sandbox (“seatbelt” profile).\n\n### Filesystem\n\n- Read/write is limited to the app container:\n  - `Documents/` (user data)\n  - `Library/` (settings/caches)\n  - `tmp/`\n- No access to system directories (`/System`, `/etc`, etc.) and no direct access to other apps’ containers.\n\n(See also: `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`.)\n\n### Network\n\n- Networking is allowed but controlled:\n  - **ATS** (App Transport Security) applies (HTTPS by default)\n  - iOS local network privacy requires an appropriate usage description when scanning/connecting to LAN hosts\n\n(See also: `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`.)\n\n### “No JIT / no dynamic native code” reality\n\n- iOS’s code-signing model and W^X restrictions strongly constrain any runtime that wants to generate machine code on the fly.\n- Design implications:\n  - prefer interpreters or AOT approaches\n  - keep execution deterministic and limit resource usage\n  - avoid designs that depend on spawning processes or loading arbitrary native code\n\n---\n\n## What IS possible vs what requires remote execution\n\n### What IS possible on-device (realistic / App Store-friendly)\n\n| Goal | Viable approach |\n|---|---|\n| User scripting & automation | JavaScriptCore + strict native bridge, or embedded Lua |\n| Sandboxed compute modules | Embedded Wasm runtime (e.g., wasm3/WAMR) with minimal imports |\n| Workspace file operations | Native Swift file APIs constrained to app container, bridged into runtime |\n| Networking for scripts/plugins | Native `URLSession` bridged into runtime (ATS compliant) |\n| Simple formatters/linters written in JS/Lua | Run on-device, enforce timeouts + memory limits |\n\n### What usually requires remote execution\n\n| Goal | Why remote is needed |\n|---|---|\n| Full Python/Node toolchains, `pip`/`npm`, native deps | Policy + sandbox constraints; native extensions/subprocess expectations |\n| Language servers (LSP) for large ecosystems | Process model + memory footprint + filesystem scanning; better on remote host |\n| Compilers/build systems (Rust/Go/C++ toolchains) | Not feasible to ship/execute full toolchains on iOS like desktop environments |\n| Running arbitrary binaries | iOS sandbox does not support executing arbitrary downloaded programs |\n\n### Recommended remote path for this project\n\nUse SSH to a dev machine/container and treat the iPad as the IDE client.\n\nSee: `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md`.\n\n---\n\n## References\n\n- Apple App Review Guidelines §2.5.2 (code downloading/execution restriction + educational exception)\n  - https://developer.apple.com/app-store/review/guidelines/#software-requirements\n- Project security notes\n  - `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md`\n- Project remote execution path (SwiftNIO SSH)\n  - `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md`\n- Wasmer blog (notes iOS JSC WebAssembly disabled on iOS 16.4.x)\n  - https://wasmer.io/posts/wasmer-3_3-and-javascriptcore\n- wasm3 README (iOS can’t generate executable code pages at runtime; interpreter rationale)\n  - https://github.com/wasm3/wasm3\n- StackOverflow thread on Wasm in JSC/WKWebView (availability pitfalls)\n  - https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc\n"}>>>END

---

## 🔧 TOOL RESULTS

[move_file]
✅ Moved: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md → VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_HeaderFix_Archive.md

---

[create_file]
✅ Created: VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md","start_line":1,"end_line":20}
>>>END>>>REPORT
Created/updated `VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch.md` to cover all requested topics:
- JavaScriptCore capabilities/limitations (no browser APIs, no JIT, module ecosystem limits, need host timeouts/limits): `OnDeviceResearch.md` lines 24-62.
- WebAssembly runtime options (WKWebView, JSC WebAssembly availability caveats, embedded runtimes like wasm3/WAMR/Wasmer, WASI mapping considerations): `OnDeviceResearch.md` lines 65-116.
  - Evidence cited in-doc: Apple JSC Wasm disabled note from Wasmer blog (web-fetched) and wasm3 “iOS can’t generate executable code pages” (web-fetched), plus StackOverflow availability report.
- Why Python can’t run natively / “no interpreter allowed” framed as App Store policy + platform constraints with direct quote of Guideline 2.5.2 and educational exception: `OnDeviceResearch.md` lines 119-154.
  - Source: Apple App Review Guidelines §2.5.2 fetched at https://developer.apple.com/app-store/review/guidelines/#software-requirements (tool output shows full clause).
- Lua interpreter options (PUC-Lua, LuaJIT JIT issue, JS/Wasm-based Lua): `OnDeviceResearch.md` lines 157-183.
- Security sandbox restrictions (container-only filesystem, ATS/local-network privacy, no JIT/dynamic native code reality): `OnDeviceResearch.md` lines 186-215, referencing `VSCodeiPadOS/VSCodeiPadOS/Docs/SecurityAudit.md` (read earlier; sandbox + ATS coverage).
- What is possible vs what requires remote execution: `OnDeviceResearch.md` lines 218-244, with SSH remote execution pointer to `VSCodeiPadOS/VSCodeiPadOS/Docs/SSH_SETUP.md` (read earlier).
Also preserved prior large JSC deep-dive as `VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_JSC_Archive.md` (created earlier by move tool).
Archives created during edits (due to patch tool not permitted): 
- `VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_SummaryDraft_Archive.md`
- `VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_TempArchive.md`
- `VSCodeiPadOS/VSCodeiPadOS/Docs/OnDeviceResearch_HeaderFix_Archive.md`
Evidence sources used:
- Apple App Review Guidelines 2.5.2 (web_fetch).
- Wasmer JSC backend post noting iOS JSC Wasm disabled on iOS 16.4.x (web_fetch https://wasmer.io/posts/wasmer-3_3-and-javascriptcore).
- wasm3 README noting iOS runtime cannot generate executable code pages (web_fetch https://github.com/wasm3/wasm3).
- StackOverflow thread on Wasm missing in JSC/WKWebView in iOS simulator context (web_fetch https://stackoverflow.com/questions/57348813/how-to-load-webassembly-in-ios-app-via-wkwebview-or-jsc).
>>>END
