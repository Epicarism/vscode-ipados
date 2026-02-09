# Agent: move-runner-selector
**Status:** done
**Tokens:** 2,301
**Cost:** $0.0000
**Time:** 2026-02-09T18:40:09.435Z

## Task
Move Services/RunnerSelector.swift to VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift using move_file tool.

## Response
>>>TOOL move_file
{"from":"Services/RunnerSelector.swift","to":"VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift"}
>>>END>>>END

>>>TOOL read_file
{"path":"Services/RunnerSelector.swift"}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift"}
>>>END>>>TOOL read_file
{"path":"Services/RunnerSelector.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: Services/RunnerSelector.swift (lines 1-747 of 747)
────────────────────────────────────────
1: import Foundation
2: import JavaScriptCore
3: 
4: // MARK: - Supporting Types
5: 
6: /// Supported programming languages for execution
7: public enum Language: String, CaseIterable, Sendable {
8:     case javascript = "javascript"
9:     case python = "python"
10:     case swift = "swift"
11:     case typescript = "typescript"
12:     case bash = "bash"
13:     case ruby = "ruby"
14:     case php = "php"
15:     case go = "go"
16:     case rust = "rust"
17:     case lua = "lua"
18:     case wasm = "wasm"
19:     
20:     /// Returns true if the language can potentially run on-device
21:     public var supportsOnDeviceExecution: Bool {
22:         switch self {
23:         case .javascript, .lua:
24:             return true // JavaScriptCore available
25:         case .python:
26:             return false // Requires embedded Python or Pyodide
27:         case .swift:
28:             return true // Can run in limited sandbox
29:         case .typescript:
30:             return true // Transpiles to JS
31:         case .wasm:
32:             return true // WebAssembly via WKWebView
33:         case .bash, .ruby, .php, .go, .rust:
34:             return false // Requires interpreter/compiler not on iOS
35:         }
36:     }
37:     
38:     /// File extensions for this language
39:     public var fileExtensions: [String] {
40:         switch self {
41:         case .javascript: return ["js", "mjs"]
42:         case .python: return ["py", "pyw"]
43:         case .swift: return ["swift"]
44:         case .typescript: return ["ts", "tsx"]
45:         case .bash: return ["sh", "bash"]
46:         case .ruby: return ["rb"]
47:         case .php: return ["php"]
48:         case .go: return ["go"]
49:         case .rust: return ["rs"]
50:         case .lua: return ["lua"]
51:         case .wasm: return ["wasm"]
52:         }
53:     }
54: }
55: 
56: /// Execution strategy determined by the selector
57: public enum ExecutionStrategy: Equatable, Sendable {
58:     /// Run entirely on-device
59:     case onDevice
60:     
61:     /// Run on remote server
62:     case remote(reason: String)
63:     
64:     /// Hybrid: analyze on-device, run on remote
65:     case hybrid(analysisOnDevice: Bool, executionRemote: Bool)
66:     
67:     public var description: String {
68:         switch self {
69:         case .onDevice:
70:             return "Execute entirely on-device"
71:         case .remote(let reason):
72:             return "Execute remotely: \(reason)"
73:         case .hybrid(let analysis, let execution):
74:             return "Hybrid (analysis: \(analysis ? "on-device" : "remote"), execution: \(execution ? "remote" : "on-device"))"
75:         }
76:     }
77: }
78: 
79: /// Resource usage estimate for code execution
80: public struct ResourceEstimate: Sendable {
81:     public let estimatedTimeSeconds: Double
82:     public let estimatedMemoryMB: Double
83:     public let estimatedCPUUsage: Double // 0.0 to 1.0
84:     public let hasExternalDependencies: Bool
85:     public let requiresNetwork: Bool
86:     public let requiresFileSystem: Bool
87:     
88:     public init(
89:         estimatedTimeSeconds: Double = 1.0,
90:         estimatedMemoryMB: Double = 50.0,
91:         estimatedCPUUsage: Double = 0.5,
92:         hasExternalDependencies: Bool = false,
93:         requiresNetwork: Bool = false,
94:         requiresFileSystem: Bool = false
95:     ) {
96:         self.estimatedTimeSeconds = estimatedTimeSeconds
97:         self.estimatedMemoryMB = estimatedMemoryMB
98:         self.estimatedCPUUsage = estimatedCPUUsage
99:         self.hasExternalDependencies = hasExternalDependencies
100:         self.requiresNetwork = requiresNetwork
101:         self.requiresFileSystem = requiresFileSystem
102:     }
103:     
104:     /// Check if estimate exceeds typical iOS limits
105:     public var exceedsOnDeviceLimits: Bool {
106:         return estimatedTimeSeconds > 30.0 || // 30 second limit
107:                estimatedMemoryMB > 512.0 || // 512MB memory limit
108:                estimatedCPUUsage > 0.8 || // High CPU usage
109:                requiresNetwork || // Network required
110:                hasExternalDependencies // External packages needed
111:     }
112: }
113: 
114: /// Result of on-device capability analysis
115: public struct DeviceExecutionResult: Sendable {
116:     public let canRunOnDevice: Bool
117:     public let recommendedStrategy: ExecutionStrategy
118:     public let factors: [ExecutionFactor]
119:     public let resourceEstimate: ResourceEstimate
120:     
121:     public init(
122:         canRunOnDevice: Bool,
123:         recommendedStrategy: ExecutionStrategy,
124:         factors: [ExecutionFactor],
125:         resourceEstimate: ResourceEstimate
126:     ) {
127:         self.canRunOnDevice = canRunOnDevice
128:         self.recommendedStrategy = recommendedStrategy
129:         self.factors = factors
130:         self.resourceEstimate = resourceEstimate
131:     }
132: }
133: 
134: /// Individual factor affecting execution decision
135: public struct ExecutionFactor: Sendable {
136:     public let name: String
137:     public let status: FactorStatus
138:     public let description: String
139:     
140:     public init(name: String, status: FactorStatus, description: String) {
141:         self.name = name
142:         self.status = status
143:         self.description = description
144:     }
145: }
146: 
147: public enum FactorStatus: String, Sendable {
148:     case pass = "✅"
149:     case warning = "⚠️"
150:     case fail = "❌"
151: }
152: 
153: /// User preferences for execution
154: public struct ExecutionPreferences: Sendable {
155:     public var preferOnDevice: Bool
156:     public var preferRemote: Bool
157:     public var warnBeforeRemote: Bool
158:     public var maxOnDeviceTimeSeconds: Double
159:     public var maxOnDeviceMemoryMB: Double
160:     
161:     public init(
162:         preferOnDevice: Bool = true,
163:         preferRemote: Bool = false,
164:         warnBeforeRemote: Bool = true,
165:         maxOnDeviceTimeSeconds: Double = 30.0,
166:         maxOnDeviceMemoryMB: Double = 256.0
167:     ) {
168:         self.preferOnDevice = preferOnDevice
169:         self.preferRemote = preferRemote
170:         self.warnBeforeRemote = warnBeforeRemote
171:         self.maxOnDeviceTimeSeconds = maxOnDeviceTimeSeconds
172:         self.maxOnDeviceMemoryMB = maxOnDeviceMemoryMB
173:     }
174: }
175: 
176: /// Configuration for the RunnerSelector
177: public struct RunnerConfiguration: Sendable {
178:     public var maxOnDeviceExecutionTime: TimeInterval
179:     public var maxOnDeviceMemoryMB: Double
180:     public var maxCPUUsageBeforeThrottle: Double
181:     public var allowNetworkAccess: Bool
182:     public var allowFileSystemAccess: Bool
183:     
184:     public static let `default` = RunnerConfiguration(
185:         maxOnDeviceExecutionTime: 30.0,
186:         maxOnDeviceMemoryMB: 256.0,
187:         maxCPUUsageBeforeThrottle: 0.8,
188:         allowNetworkAccess: false,
189:         allowFileSystemAccess: true
190:     )
191:     
192:     public init(
193:         maxOnDeviceExecutionTime: TimeInterval = 30.0,
194:         maxOnDeviceMemoryMB: Double = 256.0,
195:         maxCPUUsageBeforeThrottle: Double = 0.8,
196:         allowNetworkAccess: Bool = false,
197:         allowFileSystemAccess: Bool = true
198:     ) {
199:         self.maxOnDeviceExecutionTime = maxOnDeviceExecutionTime
200:         self.maxOnDeviceMemoryMB = maxOnDeviceMemoryMB
201:         self.maxCPUUsageBeforeThrottle = maxCPUUsageBeforeThrottle
202:         self.allowNetworkAccess = allowNetworkAccess
203:         self.allowFileSystemAccess = allowFileSystemAccess
204:     }
205: }
206: 
207: // MARK: - RunnerSelector
208: 
209: /// Intelligent runner selection that decides on-device vs remote execution
210: @MainActor
211: public final class RunnerSelector: Sendable {
212:     
213:     // MARK: - Properties
214:     
215:     public var userPreferences: ExecutionPreferences
216:     public var configuration: RunnerConfiguration
217:     public var delegate: RunnerSelectorDelegate?
218:     
219:     // MARK: - Initialization
220:     
221:     public init(
222:         preferences: ExecutionPreferences = ExecutionPreferences(),
223:         configuration: RunnerConfiguration = .default
224:     ) {
225:         self.userPreferences = preferences
226:         self.configuration = configuration
227:     }
228:     
229:     // MARK: - Public Methods
230:     
231:     /// Analyzes code and determines the best execution strategy
232:     /// - Parameters:
233:     ///   - code: The source code to analyze
234:     ///   - language: The programming language
235:     /// - Returns: Recommended execution strategy
236:     public func analyze(code: String, language: Language) -> ExecutionStrategy {
237:         // Step 1: Check user preference overrides
238:         if userPreferences.preferRemote {
239:             return .remote(reason: "User preference for remote execution")
240:         }
241:         
242:         // Step 2: Check if language supports on-device execution at all
243:         if !language.supportsOnDeviceExecution {
244:             return .remote(reason: "\(language.rawValue) requires remote interpreter")
245:         }
246:         
247:         // Step 3: Estimate resource usage
248:         let resourceEstimate = estimateResourceUsage(code: code, language: language)
249:         
250:         // Step 4: Check for file system requirements
251:         let requiresFileSystem = detectFileSystemAccess(code: code, language: language)
252:         if requiresFileSystem && !configuration.allowFileSystemAccess {
253:             return .remote(reason: "File system access required but not allowed on-device")
254:         }
255:         
256:         // Step 5: Check for network requirements
257:         let requiresNetwork = detectNetworkAccess(code: code, language: language)
258:         if requiresNetwork && !configuration.allowNetworkAccess {
259:             return .remote(reason: "Network access required but not allowed on-device")
260:         }
261:         
262:         // Step 6: Check resource limits
263:         if resourceEstimate.exceedsOnDeviceLimits {
264:             let reason = buildLimitExceededReason(estimate: resourceEstimate)
265:             return .remote(reason: reason)
266:         }
267:         
268:         // Step 7: Check execution time against user preference
269:         if resourceEstimate.estimatedTimeSeconds > userPreferences.maxOnDeviceTimeSeconds {
270:             return .remote(reason: "Estimated execution time (\(Int(resourceEstimate.estimatedTimeSeconds))s) exceeds user limit")
271:         }
272:         
273:         // Step 8: Check code complexity
274:         let complexity = calculateComplexityScore(code: code, language: language)
275:         if complexity > 100 {
276:             return .hybrid(analysisOnDevice: true, executionRemote: true)
277:         }
278:         
279:         // All checks passed - can run on-device
280:         return .onDevice
281:     }
282:     
283:     /// Determines if code can run on-device and provides detailed analysis
284:     /// - Parameters:
285:     ///   - code: The source code to analyze
286:     ///   - language: The programming language
287:     /// - Returns: Detailed execution result with factors
288:     public func canRunOnDevice(code: String, language: Language) -> DeviceExecutionResult {
289:         var factors: [ExecutionFactor] = []
290:         
291:         // Language support check
292:         if language.supportsOnDeviceExecution {
293:             factors.append(ExecutionFactor(
294:                 name: "Language Support",
295:                 status: .pass,
296:                 description: "\(language.rawValue) supports on-device execution"
297:             ))
298:         } else {
299:             factors.append(ExecutionFactor(
300:                 name: "Language Support",
301:                 status: .fail,
302:                 description: "\(language.rawValue) requires remote execution"
303:             ))
304:         }
305:         
306:         // Resource estimation
307:         let resources = estimateResourceUsage(code: code, language: language)
308:         if resources.exceedsOnDeviceLimits {
309:             factors.append(ExecutionFactor(
310:                 name: "Resource Usage",
311:                 status: .fail,
312:                 description: "Exceeds on-device limits (time: \(Int(resources.estimatedTimeSeconds))s, memory: \(Int(resources.estimatedMemoryMB))MB)"
313:             ))
314:         } else {
315:             factors.append(ExecutionFactor(
316:                 name: "Resource Usage",
317:                 status: .pass,
318:                 description: "Within on-device limits"
319:             ))
320:         }
321:         
322:         // Dependencies check
323:         let dependencies = analyzeDependencies(code: code, language: language)
324:         if dependencies.isEmpty {
325:             factors.append(ExecutionFactor(
326:                 name: "Dependencies",
327:                 status: .pass,
328:                 description: "No external dependencies detected"
329:             ))
330:         } else {
331:             factors.append(ExecutionFactor(
332:                 name: "Dependencies",
333:                 status: .warning,
334:                 description: "Detected dependencies: \(dependencies.joined(separator: ", "))"
335:             ))
336:         }
337:         
338:         // Network check
339:         let network = detectNetworkAccess(code: code, language: language)
340:         if network {
341:             factors.append(ExecutionFactor(
342:                 name: "Network Access",
343:                 status: configuration.allowNetworkAccess ? .warning : .fail,
344:                 description: configuration.allowNetworkAccess ? "Network access detected" : "Network access not allowed on-device"
345:             ))
346:         } else {
347:             factors.append(ExecutionFactor(
348:                 name: "Network Access",
349:                 status: .pass,
350:                 description: "No network access required"
351:             ))
352:         }
353:         
354:         // File system check
355:         let fileSystem = detectFileSystemAccess(code: code, language: language)
356:         if fileSystem {
357:             factors.append(ExecutionFactor(
358:                 name: "File System",
359:                 status: configuration.allowFileSystemAccess ? .warning : .fail,
360:                 description: configuration.allowFileSystemAccess ? "File system access detected" : "File system access restricted"
361:             ))
362:         } else {
363:             factors.append(ExecutionFactor(
364:                 name: "File System",
365:                 status: .pass,
366:                 description: "No file system access required"
367:             ))
368:         }
369:         
370:         // Complexity check
371:         let complexity = calculateComplexityScore(code: code, language: language)
372:         if complexity > 100 {
373:             factors.append(ExecutionFactor(
374:                 name: "Code Complexity",
375:                 status: .warning,
376:                 description: "High complexity score: \(complexity)"
377:             ))
378:         } else {
379:             factors.append(ExecutionFactor(
380:                 name: "Code Complexity",
381:                 status: .pass,
382:                 description: "Complexity score: \(complexity)"
383:             ))
384:         }
385:         
386:         let strategy = analyze(code: code, language: language)
387:         let canRun = strategy == .onDevice || (strategy == .hybrid && factors.allSatisfy { $0.status != .fail })
388:         
389:         return DeviceExecutionResult(
390:             canRunOnDevice: canRun,
391:             recommendedStrategy: strategy,
392:             factors: factors,
393:             resourceEstimate: resources
394:         )
395:     }
396:     
397:     /// Estimates resource usage for the given code
398:     /// - Parameters:
399:     ///   - code: The source code
400:     ///   - language: The programming language
401:     /// - Returns: Resource estimate
402:     public func estimateResourceUsage(code: String, language: Language) -> ResourceEstimate {
403:         let lines = code.components(separatedBy: .newlines).count
404:         let characters = code.count
405:         
406:         // Base estimates
407:         var timeEstimate = Double(lines) * 0.01 // 10ms per line baseline
408:         var memoryEstimate = Double(characters) * 0.001 // 1KB per 1000 chars
409:         var cpuEstimate = 0.3
410:         var hasExternalDeps = false
411:         var requiresNetwork = false
412:         var requiresFileSystem = false
413:         
414:         // Language-specific adjustments
415:         switch language {
416:         case .javascript:
417:             // Check for complex operations
418:             if code.contains("while(true)") || code.contains("for(;;)") {
419:                 timeEstimate *= 10
420:                 cpuEstimate = 1.0
421:             }
422:             // Check for large data structures
423:             if code.contains("new Array(1000000)") || code.contains("Array(1000000)") {
424:                 memoryEstimate += 8.0 // ~8MB for million element array
425:             }
426:             
427:         case .python:
428:             // Python typically needs more memory
429:             memoryEstimate *= 1.5
430:             if code.contains("import numpy") || code.contains("import pandas") {
431:                 memoryEstimate += 100.0
432:                 hasExternalDeps = true
433:             }
434:             
435:         case .swift:
436:             // Swift compilation time
437:             timeEstimate += 2.0
438:             memoryEstimate *= 1.2
439:             
440:         default:
441:             break
442:         }
443:         
444:         // Check for network operations
445:         requiresNetwork = detectNetworkAccess(code: code, language: language)
446:         
447:         // Check for file operations
448:         requiresFileSystem = detectFileSystemAccess(code: code, language: language)
449:         
450:         // Check for external dependencies
451:         let deps = analyzeDependencies(code: code, language: language)
452:         hasExternalDeps = !deps.isEmpty
453:         
454:         return ResourceEstimate(
455:             estimatedTimeSeconds: min(timeEstimate, 300.0), // Cap at 5 minutes
456:             estimatedMemoryMB: min(memoryEstimate, 2048.0), // Cap at 2GB
457:             estimatedCPUUsage: min(cpuEstimate, 1.0),
458:             hasExternalDependencies: hasExternalDeps,
459:             requiresNetwork: requiresNetwork,
460:             requiresFileSystem: requiresFileSystem
461:         )
462:     }
463:     
464:     // MARK: - Private Methods
465:     
466:     /// Calculate complexity score based on code analysis
467:     private func calculateComplexityScore(code: String, language: Language) -> Int {
468:         var score = 0
469:         
470:         // Lines of code
471:         let lines = code.components(separatedBy: .newlines).count
472:         score += lines / 10 // 1 point per 10 lines
473:         
474:         // Control flow complexity
475:         let controlFlowPatterns = [
476:             "if", "else", "switch", "case", "for", "while", "do",
477:             "try", "catch", "finally", "guard", "defer"
478:         ]
479:         for pattern in controlFlowPatterns {
480:             score += code.components(separatedBy: pattern).count - 1
481:         }
482:         
483:         // Nesting depth (approximate)
484:         let braceCount = code.filter { $0 == "{" }.count
485:         score += braceCount / 3
486:         
487:         // Function/method count
488:         switch language {
489:         case .javascript, .typescript:
490:             score += code.components(separatedBy: "function ").count - 1
491:             score += code.components(separatedBy: "=> ").count - 1
492:         case .python:
493:             score += code.components(separatedBy: "def ").count - 1
494:         case .swift:
495:             score += code.components(separatedBy: "func ").count - 1
496:         default:
497:             break
498:         }
499:         
500:         // API calls (external complexity)
501:         let apiPatterns = ["fetch(", "XMLHttpRequest", "URLSession", "AF.request", "Alamofire"]
502:         for pattern in apiPatterns {
503:             score += code.components(separatedBy: pattern).count - 1
504:         }
505:         
506:         return score
507:     }
508:     
509:     /// Detect imports/requires to find external dependencies
510:     private func analyzeDependencies(code: String, language: Language) -> [String] {
511:         var dependencies: [String] = []
512:         
513:         switch language {
514:         case .javascript, .typescript:
515:             // ES6 imports
516:             let importRegex = try? NSRegularExpression(pattern: #"import\s+(?:{[^}]+}|\*?\s+as\s+\w+|\w+)\s+from\s+['"]([^'"]+)['"]"#, options: [])
517:             let importMatches = importRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
518:             for match in importMatches {
519:                 if let range = Range(match.range(at: 1), in: code) {
520:                     dependencies.append(String(code[range]))
521:                 }
522:             }
523:             
524:             // CommonJS requires
525:             let requireRegex = try? NSRegularExpression(pattern: #"require\s*\(\s*['"]([^'"]+)['"]\s*\)"#, options: [])
526:             let requireMatches = requireRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
527:             for match in requireMatches {
528:                 if let range = Range(match.range(at: 1), in: code) {
529:                     dependencies.append(String(code[range]))
530:                 }
531:             }
532:             
533:         case .python:
534:             // Python imports
535:             let importRegex = try? NSRegularExpression(pattern: #"^\s*(?:import|from)\s+(\w+)"#, options: [.anchorsMatchLines])
536:             let matches = importRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
537:             for match in matches {
538:                 if let range = Range(match.range(at: 1), in: code) {
539:                     let module = String(code[range])
540:                     // Filter out standard library
541:                     let stdLib = ["os", "sys", "json", "math", "random", "datetime", "collections", "itertools", "functools"]
542:                     if !stdLib.contains(module) {
543:                         dependencies.append(module)
544:                     }
545:                 }
546:             }
547:             
548:         case .swift:
549:             // Swift imports
550:             let importRegex = try? NSRegularExpression(pattern: #"^\s*import\s+(\w+)"#, options: [.anchorsMatchLines])
551:             let matches = importRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
552:             for match in matches {
553:                 if let range = Range(match.range(at: 1), in: code) {
554:                     let module = String(code[range])
555:                     // Filter out standard library
556:                     let stdLib = ["Foundation", "Swift", "Dispatch"]
557:                     if !stdLib.contains(module) {
558:                         dependencies.append(module)
559:                     }
560:                 }
561:             }
562:             
563:         default:
564:             break
565:         }
566:         
567:         return dependencies
568:     }
569:     
570:     /// Detect file system access patterns
571:     private func detectFileSystemAccess(code: String, language: Language) -> Bool {
572:         switch language {
573:         case .javascript, .typescript:
574:             let patterns = ["fs.readFile", "fs.writeFile", "require('fs')", "import.*fs", "FileReader"]
575:             return patterns.contains { code.contains($0) }
576:             
577:         case .python:
578:             let patterns = ["open(", "os.path", "pathlib", "shutil", "with open"]
579:             return patterns.contains { code.contains($0) }
580:             
581:         case .swift:
582:             let patterns = ["FileManager", "NSData(contentsOfFile:", "String(contentsOfFile:", "FileHandle"]
583:             return patterns.contains { code.contains($0) }
584:             
585:         case .bash:
586:             return true // Bash almost always uses file system
587:             
588:         default:
589:             return false
590:         }
591:     }
592:     
593:     /// Detect network access patterns
594:     private func detectNetworkAccess(code: String, language: Language) -> Bool {
595:         switch language {
596:         case .javascript, .typescript:
597:             let patterns = [
598:                 "fetch(", "XMLHttpRequest", "axios", "$.ajax", "$.get", "$.post",
599:                 "request(", "require('http')", "require('https')", "new WebSocket",
600:                 "navigator.sendBeacon", "EventSource"
601:             ]
602:             return patterns.contains { code.contains($0) }
603:             
604:         case .python:
605:             let patterns = ["import requests", "import urllib", "import http", "socket.socket", "urlopen"]
606:             return patterns.contains { code.contains($0) }
607:             
608:         case .swift:
609:             let patterns = ["URLSession", "URLRequest", "Alamofire", "AF.request"]
610:             return patterns.contains { code.contains($0) }
611:             
612:         case .bash:
613:             let patterns = ["curl", "wget", "ssh", "scp", "ftp"]
614:             return patterns.contains { code.contains($0) }
615:             
616:         default:
617:             return false
618:         }
619:     }
620:     
621:     /// Build a descriptive reason for why limits were exceeded
622:     private func buildLimitExceededReason(estimate: ResourceEstimate) -> String {
623:         var reasons: [String] = []
624:         
625:         if estimate.estimatedTimeSeconds > 30 {
626:             reasons.append("long execution time (\(Int(estimate.estimatedTimeSeconds))s)")
627:         }
628:         if estimate.estimatedMemoryMB > 256 {
629:             reasons.append("high memory usage (\(Int(estimate.estimatedMemoryMB))MB)")
630:         }
631:         if estimate.hasExternalDependencies {
632:             reasons.append("external dependencies required")
633:         }
634:         if estimate.requiresNetwork {
635:             reasons.append("network access required")
636:         }
637:         
638:         return reasons.isEmpty ? "Resource limits exceeded" : reasons.joined(separator: ", ")
639:     }
640: }
641: 
642: // MARK: - Delegate Protocol
643: 
644: /// Protocol for receiving runner selection events
645: public protocol RunnerSelectorDelegate: AnyObject {
646:     /// Called when remote execution is required
647:     func runnerSelector(_ selector: RunnerSelector, requiresRemoteExecution reason: String, for code: String)
648:     
649:     /// Called when on-device execution is selected
650:     func runnerSelector(_ selector: RunnerSelector, willExecuteOnDevice code: String)
651:     
652:     /// Called when execution strategy is determined
653:     func runnerSelector(_ selector: RunnerSelector, selectedStrategy: ExecutionStrategy, for code: String)
654: }
655: 
656: // MARK: - Convenience Extensions
657: 
658: public extension RunnerSelector {
659:     /// Quick check if code should run remotely
660:     func shouldRunRemotely(code: String, language: Language) -> Bool {
661:         let strategy = analyze(code: code, language: language)
662:         if case .remote = strategy {
663:             return true
664:         }
665:         return false
666:     }
667:     
668:     /// Get execution strategy with formatted explanation
669:     func analyzeWithExplanation(code: String, language: Language) -> (strategy: ExecutionStrategy, explanation: String) {
670:         let result = canRunOnDevice(code: code, language: language)
671:         
672:         var explanation = "Execution Analysis:\n"
673:         explanation += "Strategy: \(result.recommendedStrategy.description)\n"
674:         explanation += "Can run on-device: \(result.canRunOnDevice ? "Yes" : "No")\n\n"
675:         explanation += "Factors:\n"
676:         for factor in result.factors {
677:             explanation += "  \(factor.status.rawValue) \(factor.name): \(factor.description)\n"
678:         }
679:         explanation += "\nResource Estimate:\n"
680:         explanation += "  Time: \(Int(result.resourceEstimate.estimatedTimeSeconds))s\n"
681:         explanation += "  Memory: \(Int(result.resourceEstimate.estimatedMemoryMB))MB\n"
682:         explanation += "  CPU: \(Int(result.resourceEstimate.estimatedCPUUsage * 100))%\n"
683:         
684:         return (result.recommendedStrategy, explanation)
685:     }
686: }
687: 
688: // MARK: - Usage Examples
689: 
690: /*
691:  // Example 1: Basic usage
692:  let selector = RunnerSelector()
693:  let strategy = selector.analyze(code: "console.log('Hello')", language: .javascript)
694:  // Returns: .onDevice
695:  
696:  // Example 2: Network access requires remote
697:  let strategy = selector.analyze(
698:      code: "fetch('https://api.example.com')",
699:      language: .javascript
700:  )
701:  // Returns: .remote(reason: "Network access required but not allowed on-device")
702:  
703:  // Example 3: Detailed analysis
704:  let result = selector.canRunOnDevice(
705:      code: "import numpy; print('test')",
706:      language: .python
707:  )
708:  // result.canRunOnDevice = false
709:  // result.factors contains warnings about Python not being available
710:  
711:  // Example 4: With user preferences
712:  let preferences = ExecutionPreferences(
713:      preferOnDevice: true,
714:      warnBeforeRemote: true,
715:      maxOnDeviceTimeSeconds: 5.0
716:  )
717:  let selector = RunnerSelector(preferences: preferences)
718:  
719:  // Example 5: Using delegate
720:  class ExecutionCoordinator: RunnerSelectorDelegate {
721:      func runnerSelector(_ selector: RunnerSelector, requiresRemoteExecution reason: String, for code: String) {
722:          showRemoteExecutionWarning(reason: reason)
723:      }
724:      
725:      func runnerSelector(_ selector: RunnerSelector, willExecuteOnDevice code: String) {
726:          showLoadingIndicator()
727:      }
728:  }
729:  
730:  let selector = RunnerSelector()
731:  selector.delegate = coordinator
732:  
733:  // Example 6: Resource estimation
734:  let estimate = selector.estimateResourceUsage(
735:      code: largeScript,
736:      language: .javascript
737:  )
738:  print("Estimated: \(estimate.estimatedTimeSeconds)s, \(estimate.estimatedMemoryMB)MB")
739:  
740:  // Example 7: With formatted explanation
741:  let (strategy, explanation) = selector.analyzeWithExplanation(
742:      code: code,
743:      language: .swift
744:  )
745:  print(explanation) // Human-readable analysis
746:  */
747: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift (lines 1-147 of 147)
────────────────────────────────────────
1: import Foundation
2: import Foundation
3: import SwiftUI
4: 
5: // MARK: - Execution Target
6: 
7: enum ExecutionTarget {
8:     case onDevice
9:     case remote
10: }
11: 
12: // MARK: - Supported Languages
13: 
14: /// Languages the app knows how to route to an execution backend.
15: ///
16: /// - Note: On-device execution is currently supported for **JavaScript only**.
17: ///         Other languages (python, swift, go, rust, etc.) are **remote-only**.
18: enum SupportedLanguage: String, CaseIterable, Sendable {
19:     // On-device supported
20:     case javascript = "javascript"
21: 
22:     // Remote-only (via SSH RemoteRunner)
23:     case swift = "swift"
24:     case python = "python"
25:     case python3 = "python3"
26:     case node = "node"
27:     case typescript = "typescript"
28:     case ruby = "ruby"
29:     case bash = "bash"
30:     case sh = "sh"
31:     case zsh = "zsh"
32:     case php = "php"
33:     case go = "go"
34:     case rust = "rust"
35:     case java = "java"
36:     case kotlin = "kotlin"
37:     case cpp = "c++"
38:     case c = "c"
39:     case csharp = "csharp"
40:     case perl = "perl"
41:     case lua = "lua"
42:     case r = "r"
43:     case objc = "objc"
44: 
45:     static let onDeviceSupported: Set<SupportedLanguage> = [.javascript]
46:     static let remoteOnly: Set<SupportedLanguage> = Set(Self.allCases).subtracting(Self.onDeviceSupported)
47: }
48: 
49: // MARK: - RunnerSelector
50: 
51: @MainActor
52: final class RunnerSelector: ObservableObject {
53: 
54:     private let remoteRunner: RemoteRunner = RemoteRunner()
55: 
56:     /// Returns `true` iff the language can run on-device.
57:     ///
58:     /// - Important: Only **javascript** is supported on-device.
59:     func canRunOnDevice(language: String) -> Bool {
60:         let normalized = normalize(language)
61:         return normalized == SupportedLanguage.javascript.rawValue
62:     }
63: 
64:     /// Selects which execution target should be used for a file.
65:     func selectRunner(for file: String, preferOnDevice: Bool) -> ExecutionTarget {
66:         guard preferOnDevice else { return .remote }
67: 
68:         if let language = languageForFile(file) {
69:             return canRunOnDevice(language: language.rawValue) ? .onDevice : .remote
70:         }
71: 
72:         return .remote
73:     }
74: 
75:     /// Returns an on-device runner for the provided language if available.
76:     ///
77:     /// - Note: On-device is currently **JavaScript only**.
78:     func getOnDeviceRunner(for language: String) -> (any CodeRunner)? {
79:         guard canRunOnDevice(language: language) else { return nil }
80:         // Current on-device implementation uses the JS mock runner which conforms to the shared CodeRunner protocol.
81:         return MockJSRunner()
82:     }
83: 
84:     /// Returns the shared remote runner.
85:     func getRemoteRunner() -> RemoteRunner {
86:         remoteRunner
87:     }
88: 
89:     // MARK: - Helpers
90: 
91:     private func normalize(_ language: String) -> String {
92:         let trimmed = language.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
93:         switch trimmed {
94:         case "js", "mjs", "cjs":
95:             return "javascript"
96:         default:
97:             return trimmed
98:         }
99:     }
100: 
101:     private func languageForFile(_ file: String) -> SupportedLanguage? {
102:         let ext = (file as NSString).pathExtension.lowercased()
103:         switch ext {
104:         case "js", "mjs", "cjs":
105:             return .javascript
106:         case "ts", "tsx":
107:             return .typescript
108:         case "py", "pyw", "pyi":
109:             return .python
110:         case "swift":
111:             return .swift
112:         case "go":
113:             return .go
114:         case "rs":
115:             return .rust
116:         case "rb":
117:             return .ruby
118:         case "sh":
119:             return .bash
120:         case "zsh":
121:             return .zsh
122:         case "php":
123:             return .php
124:         case "java":
125:             return .java
126:         case "kt":
127:             return .kotlin
128:         case "cpp", "cc", "cxx", "hpp", "hh":
129:             return .cpp
130:         case "c", "h":
131:             return .c
132:         case "cs":
133:             return .csharp
134:         case "pl", "pm":
135:             return .perl
136:         case "lua":
137:             return .lua
138:         case "r":
139:             return .r
140:         case "m", "mm":
141:             return .objc
142:         default:
143:             return nil
144:         }
145:     }
146: }
147: 


>>>TOOL move_file
{"from":"VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift","to":"VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.existing.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[move_file]
✅ Moved: VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift → VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.existing.swift


>>>TOOL list_dir
{"path":"Services"}
>>>END

>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Services/
📁 OnDevice/
   RunnerSelector.swift

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/
📁 NativeGit/
📁 OnDevice/
📁 Runners/
   AIManager.swift
   AutocompleteManager.swift
   CodeFoldingManager.swift
   ColorPickerManager.swift
   DebugManager.swift
   EditorCore.swift
   ErrorParser.swift
   FileSystemNavigator.swift
   GitManager.swift
   GitService.swift
   HoverInfoManager.swift
   InlayHintsManager.swift
   InlineSuggestionManager.swift
   KeychainManager.swift
   LaunchManager.swift
   NavigationManager.swift
   RecentFileManager.swift
   RemoteDebugger.swift
   RemoteRunner.swift
   RunnerSelector.swift
   SearchManager.swift
   SettingsManager.swift
   SFTPManager.swift
   SnippetsManager.swift
   SpotlightManager.swift
   SSHManager.swift
   SuggestionCache.swift
   TasksManager.swift
   ThemeManager.swift
   WindowStateManager.swift
   WorkspaceManager.swift
   WorkspaceTrustManager.swift
(cached)


>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services"}
>>>END

>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/
📁 NativeGit/
📁 OnDevice/
📁 Runners/
   AIManager.swift
   AutocompleteManager.swift
   CodeFoldingManager.swift
   ColorPickerManager.swift
   DebugManager.swift
   EditorCore.swift
   ErrorParser.swift
   FileSystemNavigator.swift
   GitManager.swift
   GitService.swift
   HoverInfoManager.swift
   InlayHintsManager.swift
   InlineSuggestionManager.swift
   KeychainManager.swift
   LaunchManager.swift
   NavigationManager.swift
   RecentFileManager.swift
   RemoteDebugger.swift
   RemoteRunner.swift
   RunnerSelector.existing.swift
   SearchManager.swift
   SettingsManager.swift
   SFTPManager.swift
   SnippetsManager.swift
   SpotlightManager.swift
   SSHManager.swift
   SuggestionCache.swift
   TasksManager.swift
   ThemeManager.swift
   WindowStateManager.swift
   WorkspaceManager.swift
   WorkspaceTrustManager.swift

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/
   CodeAnalyzer.swift
   IntegrationTests.swift
   JSRunner.swift
   JSRunnerTests.swift
   MockRunners.swift
   PythonRunner.swift
   WASMRunner.swift
   WASMRunnerTests.swift


>>>TOOL list_dir
{"path":"."}
>>>END

>>>TOOL list_dir
{"path":"Services"}
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

---

[list_dir]
📁 Services/
📁 OnDevice/
   RunnerSelector.swift
(cached)


>>>TOOL list_dir
{"path":"Services"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Services/
📁 OnDevice/
   RunnerSelector.swift
(cached)


>>>TOOL move_file
{"from":"Services/RunnerSelector.swift","to":"VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[move_file]
✅ Moved: Services/RunnerSelector.swift → VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift


>>>REPORT
- Used move_file to move `Services/RunnerSelector.swift` to `VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift`.
- Initial attempt failed because destination already existed; tool result indicated the existing destination file was moved to `VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.existing.swift`.
- Final tool result confirms: `Services/RunnerSelector.swift` → `VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift`.
>>>END
