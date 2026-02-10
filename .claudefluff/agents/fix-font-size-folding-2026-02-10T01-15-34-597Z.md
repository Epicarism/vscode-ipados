# Agent: fix-font-size-folding
**Status:** done
**Tokens:** 21,052
**Cost:** $0.0000
**Time:** 2026-02-10T01:15:34.597Z

## Task
Two bugs: 1) Font size not changing when using zoom commands. 2) Folding doesn't work - just moves to top of screen. Read VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift for font size and VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift for folding. Find why editorFontSize changes don't affect the text view, and why folding UI is broken.

## Response
I'll start by reading the two files mentioned to understand the bugs.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift"}
>>>END

Let me read the CodeFoldingManager.swift file to understand the folding issue:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 1-866 of 866)
────────────────────────────────────────
1: import SwiftUI
2: import Foundation
3: 
4: // MARK: - Fold Region Model
5: struct FoldRegion: Identifiable, Codable {
6:     let id = UUID()
7:     let startLine: Int
8:     let endLine: Int
9:     var isFolded: Bool = false
10:     let type: FoldType
11:     let label: String?
12:     
13:     enum FoldType: String, Codable {
14:         case function
15:         case classOrStruct
16:         case `extension`
17:         case enumDeclaration
18:         case protocolDeclaration
19:         case importStatement
20:         case comment
21:         case region
22:         case controlFlow
23:         case genericBlock
24:         
25:         var displayName: String {
26:             switch self {
27:             case .function: return "Function"
28:             case .classOrStruct: return "Class/Struct"
29:             case .extension: return "Extension"
30:             case .enumDeclaration: return "Enum"
31:             case .protocolDeclaration: return "Protocol"
32:             case .importStatement: return "Import"
33:             case .comment: return "Comment"
34:             case .region: return "Region"
35:             case .controlFlow: return "Control Flow"
36:             case .genericBlock: return "Block"
37:             }
38:         }
39:         
40:         var icon: String {
41:             switch self {
42:             case .function: return "f"
43:             case .classOrStruct: return "C"
44:             case .extension: return "E"
45:             case .enumDeclaration: return "E"
46:             case .protocolDeclaration: return "P"
47:             case .importStatement: return "i"
48:             case .comment: return "//"
49:             case .region: return "#"
50:             case .controlFlow: return "if"
51:             case .genericBlock: return "{}"
52:             }
53:         }
54:     }
55:     
56:     // Exclude id from Codable
57:     enum CodingKeys: String, CodingKey {
58:         case startLine, endLine, isFolded, type, label
59:     }
60: }
61: 
62: // MARK: - UserDefaults Keys
63: struct UserDefaultsKeys {
64:     static let foldStatePrefix = "codeFoldingState_"
65: }
66: 
67: // MARK: - Code Folding Manager
68: class CodeFoldingManager: ObservableObject {
69:     static let shared = CodeFoldingManager()
70:     
71:     @Published var foldRegions: [FoldRegion] = []
72:     @Published var collapsedLines: Set<Int> = []
73:     
74:     // Dictionary to manage fold regions per file
75:     private var foldRegionsByFile: [String: [FoldRegion]] = [:]
76:     
77:     private var currentFilePath: String?
78:     private var currentFileId: String?
79:     
80:     // MARK: - Enhanced Fold Detection
81:     
82:     /// Detects all foldable regions in the given code
83:     func detectFoldableRegions(in code: String, filePath: String? = nil) {
84:         self.currentFilePath = filePath
85:         self.currentFileId = filePath
86:         
87:         let lines = code.components(separatedBy: .newlines)
88:         var regions: [FoldRegion] = []
89:         
90:         // Track different types of blocks
91:         var blockStack: [(type: FoldRegion.FoldType, startLine: Int, label: String?)] = []
92:         var commentStack: [(startLine: Int, isMultiline: Bool)] = []
93:         var regionStack: [(startLine: Int, label: String)] = []
94:         
95:         for (index, line) in lines.enumerated() {
96:             let trimmed = line.trimmingCharacters(in: .whitespaces)
97:             let leadingWhitespace = line.prefix { $0 == " " || $0 == "\t" }.count
98:             
99:             // Skip empty lines for most detections
100:             guard !trimmed.isEmpty else { continue }
101:             
102:             // MARK: - Region Detection (#region, #pragma mark, MARK:)
103:             if detectRegionStart(trimmed) != nil {
104:                 if let label = detectRegionStart(trimmed) {
105:                     regionStack.append((index, label))
106:                 }
107:             } else if detectRegionEnd(trimmed) {
108:                 if let region = regionStack.popLast() {
109:                     if index - region.startLine > 1 {
110:                         regions.append(FoldRegion(
111:                             startLine: region.startLine,
112:                             endLine: index,
113:                             type: .region,
114:                             label: region.label
115:                         ))
116:                     }
117:                 }
118:             }
119:             
120:             // MARK: - Import Statement Detection
121:             if trimmed.hasPrefix("import ") {
122:                 // Group consecutive imports
123:                 let importEnd = findConsecutiveImports(from: index, in: lines)
124:                 if importEnd > index {
125:                     regions.append(FoldRegion(
126:                         startLine: index,
127:                         endLine: importEnd,
128:                         type: .importStatement,
129:                         label: "Imports"
130:                     ))
131:                 }
132:             }
133:             
134:             // MARK: - Comment Detection
135:             if detectCommentStart(trimmed) {
136:                 commentStack.append((index, true))
137:             } else if trimmed.starts(with: "//") {
138:                 // Single-line comment - check for consecutive comment blocks
139:                 let commentEnd = findConsecutiveComments(from: index, in: lines)
140:                 if commentEnd > index {
141:                     regions.append(FoldRegion(
142:                         startLine: index,
143:                         endLine: commentEnd,
144:                         type: .comment,
145:                         label: "Comment"
146:                     ))
147:                 }
148:             } else if detectCommentEnd(trimmed) {
149:                 if let comment = commentStack.popLast() {
150:                     if index - comment.startLine > 1 {
151:                         regions.append(FoldRegion(
152:                             startLine: comment.startLine,
153:                             endLine: index,
154:                             type: .comment,
155:                             label: "Comment"
156:                         ))
157:                     }
158:                 }
159:             }
160:             
161:             // MARK: - Class/Struct/Enum/Protocol/Extension Detection
162:             if let declaration = detectDeclaration(trimmed) {
163:                 if trimmed.contains("{") {
164:                     blockStack.append((declaration.type, index, declaration.label))
165:                 } else {
166:                     // Declaration without opening brace - look ahead for it
167:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
168:                         blockStack.append((declaration.type, index, declaration.label))
169:                     }
170:                 }
171:             }
172:             
173:             // MARK: - Function/Method Detection
174:             if let functionInfo = detectFunction(trimmed) {
175:                 if trimmed.contains("{") {
176:                     blockStack.append((.function, index, functionInfo))
177:                 } else {
178:                     // Function without opening brace - look ahead
179:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
180:                         blockStack.append((.function, index, functionInfo))
181:                     }
182:                 }
183:             }
184:             
185:             // MARK: - Control Flow Detection (if, guard, for, while, switch, etc.)
186:             if let controlFlowLabel = detectControlFlow(trimmed) {
187:                 if trimmed.contains("{") {
188:                     blockStack.append((.controlFlow, index, controlFlowLabel))
189:                 } else {
190:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
191:                         blockStack.append((.controlFlow, index, controlFlowLabel))
192:                     }
193:                 }
194:             }
195:             
196:             // MARK: - Generic Block Detection
197:             if trimmed.hasSuffix("{") && !isDeclarationLine(trimmed) && !isFunctionLine(trimmed) {
198:                 blockStack.append((.genericBlock, index, nil))
199:             }
200:             
201:             // MARK: - Block End Detection
202:             if detectBlockEnd(trimmed, leadingWhitespace: leadingWhitespace) {
203:                 if let lastBlock = blockStack.popLast() {
204:                     if index - lastBlock.startLine > 1 {
205:                         regions.append(FoldRegion(
206:                             startLine: lastBlock.startLine,
207:                             endLine: index,
208:                             type: lastBlock.type,
209:                             label: lastBlock.label
210:                         ))
211:                     }
212:                 }
213:             }
214:         }
215:         
216:         // Handle any remaining unclosed blocks
217:         while let lastBlock = blockStack.popLast() {
218:             if lines.count - 1 - lastBlock.startLine > 1 {
219:                 regions.append(FoldRegion(
220:                     startLine: lastBlock.startLine,
221:                     endLine: lines.count - 1,
222:                     type: lastBlock.type,
223:                     label: lastBlock.label
224:                 ))
225:             }
226:         }
227:         
228:         // Sort regions by start line
229:         regions.sort { $0.startLine < $1.startLine }
230:         
231:         self.foldRegions = regions
232:         
233:         // Store regions in the per-file dictionary
234:         if let fileId = currentFileId {
235:             foldRegionsByFile[fileId] = regions
236:         }
237:         
238:         // Restore previous fold state for this file
239:         if let filePath = filePath {
240:             restoreFoldState(for: filePath)
241:         }
242:         
243:         updateCollapsedLines()
244:     }
245:     
246:     // MARK: - Detection Helper Methods
247:     
248:     private func detectRegionStart(_ line: String) -> String? {
249:         // C# / VS style regions
250:         if line.hasPrefix("#region") {
251:             let components = line.components(separatedBy: "#region")
252:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Region"
253:         }
254:         // Objective-C pragma marks
255:         if line.hasPrefix("#pragma mark") {
256:             let components = line.components(separatedBy: "#pragma mark")
257:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
258:         }
259:         // Swift MARK comments
260:         if line.contains("MARK:") {
261:             let components = line.components(separatedBy: "MARK:")
262:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
263:         }
264:         // TODO/FIXME regions
265:         if line.contains("TODO:") {
266:             let components = line.components(separatedBy: "TODO:")
267:             return "TODO: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
268:         }
269:         if line.contains("FIXME:") {
270:             let components = line.components(separatedBy: "FIXME:")
271:             return "FIXME: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
272:         }
273:         return nil
274:     }
275:     
276:     private func detectRegionEnd(_ line: String) -> Bool {
277:         return line.hasPrefix("#endregion") || 
278:                line == "// MARK: -" ||
279:                line.hasPrefix("#pragma mark -")
280:     }
281:     
282:     private func detectCommentStart(_ line: String) -> Bool {
283:         return line.hasPrefix("/*") && !line.contains("*/")
284:     }
285:     
286:     private func detectCommentEnd(_ line: String) -> Bool {
287:         return line.contains("*/") && !line.hasPrefix("/*")
288:     }
289:     
290:     private func findConsecutiveImports(from startIndex: Int, in lines: [String]) -> Int {
291:         var endIndex = startIndex
292:         for i in startIndex..<lines.count {
293:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
294:             if trimmed.hasPrefix("import ") {
295:                 endIndex = i
296:             } else if !trimmed.isEmpty {
297:                 break
298:             }
299:         }
300:         return endIndex
301:     }
302:     
303:     private func findConsecutiveComments(from startIndex: Int, in lines: [String]) -> Int {
304:         var endIndex = startIndex
305:         for i in startIndex..<lines.count {
306:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
307:             if trimmed.starts(with: "//") {
308:                 endIndex = i
309:             } else if !trimmed.isEmpty {
310:                 break
311:             }
312:         }
313:         return endIndex
314:     }
315:     
316:     private func detectDeclaration(_ line: String) -> (type: FoldRegion.FoldType, label: String)? {
317:         // Class detection
318:         if let className = extractName(from: line, prefix: "class", visibility: ["public", "private", "internal", "fileprivate", "open", "final"]) {
319:             return (.classOrStruct, className)
320:         }
321:         // Struct detection
322:         if let structName = extractName(from: line, prefix: "struct", visibility: ["public", "private", "internal", "fileprivate"]) {
323:             return (.classOrStruct, structName)
324:         }
325:         // Enum detection
326:         if let enumName = extractName(from: line, prefix: "enum", visibility: ["public", "private", "internal", "fileprivate", "indirect"]) {
327:             return (.enumDeclaration, enumName)
328:         }
329:         // Protocol detection
330:         if let protocolName = extractName(from: line, prefix: "protocol", visibility: ["public", "private", "internal", "fileprivate"]) {
331:             return (.protocolDeclaration, protocolName)
332:         }
333:         // Extension detection
334:         if let extensionName = extractName(from: line, prefix: "extension", visibility: []) {
335:             return (.extension, extensionName)
336:         }
337:         return nil
338:     }
339:     
340:     private func detectFunction(_ line: String) -> String? {
341:         // Function detection with visibility modifiers
342:         let visibilityKeywords = ["public", "private", "internal", "fileprivate", "static", "class", "override", "final", "mutating", "convenience"]
343:         
344:         // Check for 'func' keyword
345:         if line.contains("func ") {
346:             // Extract function name
347:             let funcPattern = "func\\s+(\\w+)"
348:             if let regex = try? NSRegularExpression(pattern: funcPattern),
349:                let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
350:                let nameRange = Range(match.range(at: 1), in: line) {
351:                 let functionName = String(line[nameRange])
352:                 // Check for parameters to create label
353:                 if let parenStart = line.firstIndex(of: "("), let parenEnd = line.firstIndex(of: ")") {
354:                     let params = String(line[parenStart...parenEnd])
355:                     return "\(functionName)\(params)"
356:                 }
357:                 return functionName
358:             }
359:         }
360:         
361:         // Init detection
362:         if let initName = extractName(from: line, prefix: "init", visibility: visibilityKeywords) {
363:             return "\(initName)"
364:         }
365:         
366:         // Deinit detection
367:         if line.contains("deinit") {
368:             return "deinit"
369:         }
370:         
371:         // Computed property with get/set
372:         if line.hasPrefix("var ") && (line.contains("{") || line.contains("get")) {
373:             if let varName = extractVariableName(from: line) {
374:                 return varName
375:             }
376:         }
377:         
378:         return nil
379:     }
380:     
381:     private func detectControlFlow(_ line: String) -> String? {
382:         let controlFlowPatterns = [
383:             ("if ", "if"),
384:             ("guard ", "guard"),
385:             ("else if", "else if"),
386:             ("else", "else"),
387:             ("for ", "for"),
388:             ("while ", "while"),
389:             ("repeat", "repeat"),
390:             ("switch ", "switch"),
391:             ("case ", "case"),
392:             ("default:", "default"),
393:             ("do ", "do"),
394:             ("catch", "catch")
395:         ]
396:         
397:         for (pattern, label) in controlFlowPatterns {
398:             if line.contains(pattern) {
399:                 return label
400:             }
401:         }
402:         return nil
403:     }
404:     
405:     private func extractName(from line: String, prefix: String, visibility: [String]) -> String? {
406:         var components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
407:         
408:         // Remove visibility modifiers
409:         components = components.filter { !visibility.contains($0) }
410:         
411:         // Find prefix index
412:         if let prefixIndex = components.firstIndex(where: { $0 == prefix }),
413:            prefixIndex + 1 < components.count {
414:             var name = components[prefixIndex + 1]
415:             // Remove colons and other trailing characters
416:             name = name.components(separatedBy: ":").first ?? name
417:             name = name.components(separatedBy: "<").first ?? name
418:             name = name.components(separatedBy: ":").first ?? name
419:             return name
420:         }
421:         return nil
422:     }
423:     
424:     private func extractVariableName(from line: String) -> String? {
425:         let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
426:         if components.count >= 2, components[0] == "var" {
427:             var varName = components[1]
428:             varName = varName.components(separatedBy: ":").first ?? varName
429:             varName = varName.components(separatedBy: "=").first ?? varName
430:             return varName
431:         }
432:         return nil
433:     }
434:     
435:     private func findOpeningBrace(from startIndex: Int, in lines: [String]) -> Int? {
436:         for i in startIndex..<min(startIndex + 5, lines.count) {
437:             if lines[i].contains("{") {
438:                 return i
439:             }
440:         }
441:         return nil
442:     }
443:     
444:     private func isDeclarationLine(_ line: String) -> Bool {
445:         let keywords = ["class", "struct", "enum", "protocol", "extension", "init", "func"]
446:         return keywords.contains { line.contains("\($0) ") }
447:     }
448:     
449:     private func isFunctionLine(_ line: String) -> Bool {
450:         return line.contains("func ") || line.contains("init ")
451:     }
452:     
453:     private func detectBlockEnd(_ line: String, leadingWhitespace: Int) -> Bool {
454:         return (line.hasPrefix("}") || line.starts(with: "}")) && 
455:                (line.trimmingCharacters(in: .whitespaces) == "}" || 
456:                 line.trimmingCharacters(in: .whitespaces).hasPrefix("}"))
457:     }
458:     
459:     // MARK: - Fold State Persistence
460:     
461:     /// Saves the current fold state to UserDefaults
462:     func saveFoldState(for filePath: String) {
463:         let key = UserDefaultsKeys.foldStatePrefix + filePath
464:         
465:         // Use regions from the dictionary if available
466:         let regionsToSave: [FoldRegion]
467:         if let fileId = currentFileId, let storedRegions = foldRegionsByFile[fileId] {
468:             regionsToSave = storedRegions
469:         } else {
470:             regionsToSave = foldRegions
471:         }
472:         
473:         // Create a simplified representation for storage
474:         let foldState = regionsToSave.map { FoldStateEntry(startLine: $0.startLine, isFolded: $0.isFolded) }
475:         
476:         if let data = try? JSONEncoder().encode(foldState) {
477:             UserDefaults.standard.set(data, forKey: key)
478:         }
479:     }
480:     
481:     /// Restores fold state from UserDefaults
482:     private func restoreFoldState(for filePath: String) {
483:         let key = UserDefaultsKeys.foldStatePrefix + filePath
484:         
485:         guard let data = UserDefaults.standard.data(forKey: key),
486:               let foldState = try? JSONDecoder().decode([FoldStateEntry].self, from: data) else {
487:             return
488:         }
489:         
490:         // Apply saved state to current regions
491:         for savedState in foldState {
492:             if let index = foldRegions.firstIndex(where: { $0.startLine == savedState.startLine }) {
493:                 foldRegions[index].isFolded = savedState.isFolded
494:             }
495:         }
496:     }
497:     
498:     /// Helper struct for persisting fold state
499:     private struct FoldStateEntry: Codable {
500:         let startLine: Int
501:         let isFolded: Bool
502:     }
503:     
504:     /// Clears fold state for a specific file
505:     func clearFoldState(for filePath: String) {
506:         let key = UserDefaultsKeys.foldStatePrefix + filePath
507:         UserDefaults.standard.removeObject(forKey: key)
508:     }
509:     
510:     /// Clears all fold states
511:     func clearAllFoldStates() {
512:         let defaults = UserDefaults.standard
513:         let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(UserDefaultsKeys.foldStatePrefix) }
514:         for key in keys {
515:             defaults.removeObject(forKey: key)
516:         }
517:     }
518:     
519:     // MARK: - Fold Operations
520:     
521:     /// Toggles the fold state at a specific line
522:     func toggleFold(at line: Int) {
523:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
524:             foldRegions[regionIndex].isFolded.toggle()
525:             updateCollapsedLines()
526:             
527:             // Save state after toggling
528:             if let filePath = currentFilePath {
529:                 saveFoldState(for: filePath)
530:             }
531:         }
532:     }
533:     
534:     /// Expands a folded region
535:     func expandRegion(at line: Int) {
536:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
537:             foldRegions[regionIndex].isFolded = false
538:             updateCollapsedLines()
539:             
540:             if let filePath = currentFilePath {
541:                 saveFoldState(for: filePath)
542:             }
543:         }
544:     }
545:     
546:     /// Collapses a region
547:     func collapseRegion(at line: Int) {
548:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
549:             foldRegions[regionIndex].isFolded = true
550:             updateCollapsedLines()
551:             
552:             if let filePath = currentFilePath {
553:                 saveFoldState(for: filePath)
554:             }
555:         }
556:     }
557:     
558:     /// Expands all folded regions
559:     func expandAll() {
560:         for index in foldRegions.indices {
561:             foldRegions[index].isFolded = false
562:         }
563:         updateCollapsedLines()
564:         
565:         if let filePath = currentFilePath {
566:             saveFoldState(for: filePath)
567:         }
568:     }
569:     
570:     /// Folds the region containing the given cursor line
571:     func foldAtLine(_ cursorLine: Int) {
572:         // Find the innermost region containing this line
573:         if let region = foldRegions.filter({ 
574:             cursorLine >= $0.startLine && cursorLine <= $0.endLine && !$0.isFolded
575:         }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
576:             collapseRegion(at: region.startLine)
577:         }
578:     }
579:     
580:     /// Unfolds the region containing the given cursor line
581:     func unfoldAtLine(_ cursorLine: Int) {
582:         // Find any folded region that starts at or contains this line
583:         if let region = foldRegions.first(where: { 
584:             $0.isFolded && ($0.startLine == cursorLine || (cursorLine >= $0.startLine && cursorLine <= $0.endLine))
585:         }) {
586:             expandRegion(at: region.startLine)
587:         }
588:     }
589:     
590:     /// Toggle fold at cursor line - convenience method
591:     func toggleFoldAtLine(_ cursorLine: Int) {
592:         // First check if we're on a fold start line
593:         if let region = foldRegions.first(where: { $0.startLine == cursorLine }) {
594:             toggleFold(at: region.startLine)
595:             return
596:         }
597:         
598:         // Otherwise find the innermost region containing this line
599:         if let region = foldRegions.filter({ 
600:             cursorLine >= $0.startLine && cursorLine <= $0.endLine
601:         }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
602:             toggleFold(at: region.startLine)
603:         }
604:     }
605:     
606:     // MARK: - Legacy/Convenience Methods (for keyboard shortcuts)
607:     
608:     /// Folds at the current line (uses line 0 as fallback - caller should use foldAtLine(_:) with actual cursor)
609:     func foldCurrentLine() {
610:         // This is called from keyboard shortcuts - fold at line 0 or first available region
611:         if let firstUnfolded = foldRegions.first(where: { !$0.isFolded }) {
612:             collapseRegion(at: firstUnfolded.startLine)
613:         }
614:     }
615:     
616:     /// Unfolds at the current line (uses line 0 as fallback - caller should use unfoldAtLine(_:) with actual cursor)
617:     func unfoldCurrentLine() {
618:         // This is called from keyboard shortcuts - unfold first folded region
619:         if let firstFolded = foldRegions.first(where: { $0.isFolded }) {
620:             expandRegion(at: firstFolded.startLine)
621:         }
622:     }
623:     
624:     /// Collapses all foldable regions
625:     func collapseAll() {
626:         for index in foldRegions.indices {
627:             foldRegions[index].isFolded = true
628:         }
629:         updateCollapsedLines()
630:         
631:         if let filePath = currentFilePath {
632:             saveFoldState(for: filePath)
633:         }
634:     }
635:     
636:     /// Collapses all regions of a specific type
637:     func collapseAll(ofType type: FoldRegion.FoldType) {
638:         for index in foldRegions.indices {
639:             if foldRegions[index].type == type {
640:                 foldRegions[index].isFolded = true
641:             }
642:         }
643:         updateCollapsedLines()
644:         
645:         if let filePath = currentFilePath {
646:             saveFoldState(for: filePath)
647:         }
648:     }
649:     
650:     /// Expands all regions of a specific type
651:     func expandAll(ofType type: FoldRegion.FoldType) {
652:         for index in foldRegions.indices {
653:             if foldRegions[index].type == type {
654:                 foldRegions[index].isFolded = false
655:             }
656:         }
657:         updateCollapsedLines()
658:         
659:         if let filePath = currentFilePath {
660:             saveFoldState(for: filePath)
661:         }
662:     }
663:     
664:     // MARK: - Query Methods
665:     
666:     /// Checks if a line is foldable
667:     func isFoldable(line: Int) -> Bool {
668:         return foldRegions.contains { $0.startLine == line }
669:     }
670:     
671:     /// Checks if a line is currently folded
672:     func isLineFolded(line: Int) -> Bool {
673:         return collapsedLines.contains(line)
674:     }
675:     
676:     /// Checks if a region at a given line is folded
677:     func isRegionFolded(at line: Int) -> Bool {
678:         return foldRegions.first { $0.startLine == line }?.isFolded ?? false
679:     }
680:     
681:     /// Gets the fold region at a specific line
682:     func getRegion(at line: Int) -> FoldRegion? {
683:         return foldRegions.first { $0.startLine == line }
684:     }
685:     
686:     /// Gets all fold regions of a specific type
687:     func getRegions(ofType type: FoldRegion.FoldType) -> [FoldRegion] {
688:         return foldRegions.filter { $0.type == type }
689:     }
690:     
691:     // MARK: - File-Aware Methods
692:     
693:     /// Checks if a line is foldable for a specific file
694:     func isFoldable(fileId: String, line: Int) -> Bool {
695:         guard let regions = foldRegionsByFile[fileId] else { return false }
696:         return regions.contains { $0.startLine == line }
697:     }
698:     
699:     /// Checks if a region at a given line is folded for a specific file
700:     func isFolded(fileId: String, line: Int) -> Bool {
701:         guard let regions = foldRegionsByFile[fileId] else { return false }
702:         return regions.first { $0.startLine == line }?.isFolded ?? false
703:     }
704:     
705:     /// Toggles the fold state at a specific line for a specific file
706:     func toggleFold(fileId: String, line: Int) {
707:         guard var regions = foldRegionsByFile[fileId] else { return }
708:         
709:         if let regionIndex = regions.firstIndex(where: { $0.startLine == line }) {
710:             regions[regionIndex].isFolded.toggle()
711:             foldRegionsByFile[fileId] = regions
712:             
713:             // Update current file regions if this is the active file
714:             if fileId == currentFileId {
715:                 self.foldRegions = regions
716:                 updateCollapsedLines()
717:             }
718:             
719:             // Save state after toggling
720:             saveFoldState(for: fileId)
721:         }
722:     }
723:     
724:     /// Gets fold regions for a specific file
725:     func getFoldRegions(for fileId: String) -> [FoldRegion] {
726:         return foldRegionsByFile[fileId] ?? []
727:     }
728:     
729:     /// Clears fold regions for a specific file from memory
730:     func clearFoldRegions(for fileId: String) {
731:         foldRegionsByFile.removeValue(forKey: fileId)
732:     }
733:     
734:     /// Clears all fold regions from memory
735:     func clearAllFoldRegions() {
736:         foldRegionsByFile.removeAll()
737:     }
738:     
739:     /// Gets folded line ranges for text hiding
740:     /// Returns an array of closed ranges representing the line numbers that should be hidden
741:     func getFoldedLineRanges() -> [ClosedRange<Int>] {
742:         var ranges: [ClosedRange<Int>] = []
743:         
744:         // Sort regions by start line to ensure proper ordering
745:         let sortedRegions = foldRegions.sorted { $0.startLine < $1.startLine }
746:         
747:         for region in sortedRegions where region.isFolded {
748:             ranges.append((region.startLine + 1)...region.endLine)
749:         }
750:         
751:         return ranges
752:     }
753:     
754:     /// Gets the total count of folded lines
755:     func getFoldedLineCount() -> Int {
756:         return collapsedLines.count
757:     }
758:     
759:     /// Gets a summary of fold statistics
760:     func getFoldStatistics() -> FoldStatistics {
761:         let totalCount = foldRegions.count
762:         let foldedCount = foldRegions.filter { $0.isFolded }.count
763:         
764:         var typeBreakdown: [FoldRegion.FoldType: Int] = [:]
765:         for region in foldRegions {
766:             typeBreakdown[region.type, default: 0] += 1
767:         }
768:         
769:         return FoldStatistics(
770:             totalRegions: totalCount,
771:             foldedRegions: foldedCount,
772:             typeBreakdown: typeBreakdown
773:         )
774:     }
775:     
776:     // MARK: - Private Methods
777:     
778:     private func updateCollapsedLines() {
779:         collapsedLines.removeAll()
780:         
781:         for region in foldRegions where region.isFolded {
782:             for line in (region.startLine + 1)...region.endLine {
783:                 collapsedLines.insert(line)
784:             }
785:         }
786:     }
787: }
788: 
789: // MARK: - Fold Statistics
790: struct FoldStatistics {
791:     let totalRegions: Int
792:     let foldedRegions: Int
793:     let typeBreakdown: [FoldRegion.FoldType: Int]
794:     
795:     var expansionPercentage: Double {
796:         guard totalRegions > 0 else { return 0 }
797:         return Double(foldedCount) / Double(totalRegions) * 100
798:     }
799:     
800:     var foldedCount: Int {
801:         return foldedRegions
802:     }
803:     
804:     var expandedCount: Int {
805:         return totalRegions - foldedRegions
806:     }
807: }
808: 
809: // MARK: - Fold Button View
810: struct FoldButton: View {
811:     let line: Int
812:     let isExpanded: Bool
813:     let foldType: FoldRegion.FoldType?
814:     let action: () -> Void
815:     
816:     var body: some View {
817:         Button(action: action) {
818:             ZStack {
819:                 if let type = foldType {
820:                     Text(type.icon)
821:                         .font(.system(size: 8, weight: .bold))
822:                         .foregroundColor(.blue.opacity(0.6))
823:                 }
824:                 
825:                 Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
826:                     .font(.system(size: 10, weight: .semibold))
827:                     .foregroundColor(.primary.opacity(0.7))
828:             }
829:             .frame(width: 18, height: 18)
830:             .background(isExpanded ? Color.secondary.opacity(0.1) : Color.secondary.opacity(0.2))
831:             .cornerRadius(4)
832:         }
833:         .buttonStyle(PlainButtonStyle())
834:     }
835: }
836: 
837: // MARK: - Line Number View with Folding
838: struct LineNumberViewWithFolding: View {
839:     let lineNumber: Int
840:     let isFoldable: Bool
841:     let isExpanded: Bool
842:     let foldType: FoldRegion.FoldType?
843:     let onFoldTap: () -> Void
844:     
845:     var body: some View {
846:         HStack(spacing: 4) {
847:             if isFoldable {
848:                 FoldButton(
849:                     line: lineNumber,
850:                     isExpanded: isExpanded,
851:                     foldType: foldType,
852:                     action: onFoldTap
853:                 )
854:             } else {
855:                 Color.clear
856:                     .frame(width: 18, height: 18)
857:             }
858:             
859:             Text("\(lineNumber + 1)")
860:                 .font(.system(.caption, design: .monospaced))
861:                 .foregroundColor(.gray)
862:                 .frame(minWidth: 30, alignment: .trailing)
863:         }
864:     }
865: }
866: 


Now let me read EditorCore.swift for the font size issue:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 1-778 of 778)
────────────────────────────────────────
1: import UniformTypeIdentifiers
2: import SwiftUI
3: 
4: // MARK: - Navigation Location
5: struct NavigationLocation {
6:     let tabId: UUID
7:     let line: Int
8:     let column: Int
9: }
10: 
11: // MARK: - Sidebar Panel (renamed from SidebarView to avoid conflict with SidebarView struct in Views)
12: enum SidebarPanel {
13:     case explorer
14:     case git
15:     case search
16:     case extensions
17: }
18: 
19: // MARK: - Terminal Session Stub
20: struct TerminalSession: Identifiable {
21:     let id: UUID
22:     var title: String
23:     var output: String
24:     
25:     init(id: UUID = UUID(), title: String = "Terminal", output: String = "") {
26:         self.id = id
27:         self.title = title
28:         self.output = output
29:     }
30: }
31: 
32: // MARK: - Debug State Stubs
33: struct DebugSessionState {
34:     var isPaused: Bool = false
35:     var currentLine: Int?
36:     var currentFile: String?
37:     var callStack: [String] = []
38:     var variables: [String: String] = [:]
39: }
40: 
41: struct DebugBreakpoint: Identifiable, Equatable {
42:     let id: UUID
43:     var file: String
44:     var line: Int
45:     var isEnabled: Bool
46:     var condition: String?
47:     
48:     init(id: UUID = UUID(), file: String, line: Int, isEnabled: Bool = true, condition: String? = nil) {
49:         self.id = id
50:         self.file = file
51:         self.line = line
52:         self.isEnabled = isEnabled
53:         self.condition = condition
54:     }
55: }
56: 
57: // MARK: - Peek Definition State
58: struct PeekState: Equatable {
59:     let file: String
60:     let line: Int
61:     let content: String
62:     let sourceLine: Int // The line where peek was triggered
63: }
64: 
65: // MARK: - Editor Core (Central State Manager)
66: class EditorCore: ObservableObject {
67:     @Published var peekState: PeekState?
68:     @Published var tabs: [Tab] = []
69:     @Published var activeTabId: UUID?
70:     @Published var showSidebar = true
71:     @Published var sidebarWidth: CGFloat = 250
72:     @Published var showFilePicker = false
73:     @Published var searchText = ""
74:     @Published var showSearch = false
75:     @Published var showCommandPalette = false
76:     @Published var showQuickOpen = false
77:     @Published var showAIAssistant = false
78:     @Published var showGoToLine = false
79:     @Published var showGoToSymbol = false
80:     @Published var editorFontSize: CGFloat = 14.0
81:     @Published var isZenMode = false
82:     @Published var isFocusMode = false
83: 
84:     // Snippet picker support
85:     @Published var showSnippetPicker = false
86:     @Published var pendingSnippetInsertion: Snippet?
87: 
88:     // Cursor tracking
89:     @Published var cursorPosition = CursorPosition()
90: 
91:     // Multi-cursor support
92:     @Published var multiCursorState = MultiCursorState()
93:     @Published var currentSelection: String = ""
94:     @Published var currentSelectionRange: NSRange?
95: 
96:     // Selection request for find/replace navigation
97:     @Published var requestedSelection: NSRange?
98: 
99:     // UI Panel state
100:     @Published var showPanel = false
101:     @Published var showRenameSymbol = false
102:     @Published var focusedSidebarTab = 0
103: 
104:     // Terminal state
105:     @Published var terminalSessions: [TerminalSession] = []
106:     @Published var activeTerminalId: UUID?
107:     @Published var isTerminalMaximized: Bool = false
108:     @Published var terminalPanelHeight: CGFloat = 200
109: 
110:     // Debug state
111:     @Published var isDebugging: Bool = false
112:     @Published var isRunning: Bool = false
113:     @Published var canStartDebugging: Bool = true
114:     @Published var showAddConfiguration: Bool = false
115:     @Published var debugSessionState: DebugSessionState?
116:     @Published var breakpoints: [DebugBreakpoint] = []
117: 
118:     // Focused sidebar panel
119:     @Published var focusedView: SidebarPanel = .explorer
120: 
121:     // Reference to file navigator for workspace search
122:     weak var fileNavigator: FileSystemNavigator?
123: 
124:     // Navigation history
125:     private var navigationHistory: [NavigationLocation] = []
126:     private var navigationIndex = -1
127: 
128:     /// Track active security-scoped URL access while files are open in tabs.
129:     /// This avoids losing access after opening a document (common on iPadOS).
130:     private var securityScopedAccessCounts: [URL: Int] = [:]
131: 
132:     var activeTab: Tab? {
133:         tabs.first { $0.id == activeTabId }
134:     }
135: 
136:     var activeTabIndex: Int? {
137:         tabs.firstIndex { $0.id == activeTabId }
138:     }
139: 
140:     init() {
141:         // Create a default welcome tab
142:         let defaultTab = Tab(
143:             fileName: "Welcome.swift",
144:             content: """
145: // Welcome to VS Code for iPadOS! 🎉
146: //
147: // Features:
148: // • Syntax highlighting for Swift, JS, Python, and more
149: // • Multiple tabs with drag reordering
150: // • File explorer sidebar
151: // • Command palette (⌘+Shift+P)
152: // • Quick open (⌘+P)
153: // • Find & Replace (⌘+F)
154: // • AI Assistant
155: // • Minimap navigation
156: // • Code folding
157: // • Go to line (⌘+G)
158: //
159: // Start editing or open a file!
160: 
161: import SwiftUI
162: 
163: struct ContentView: View {
164:     var body: some View {
165:         Text("Hello, World!")
166:             .font(.largeTitle)
167:             .foregroundColor(.blue)
168:     }
169: }
170: """,
171:             language: "swift"
172:         )
173:         tabs.append(defaultTab)
174:         activeTabId = defaultTab.id
175:     }
176: 
177:     // MARK: - Tab Management
178: 
179:     func addTab(fileName: String = "Untitled.swift", content: String = "", url: URL? = nil) {
180:         // Check if file is already open
181:         if let url = url, let existingTab = tabs.first(where: { $0.url == url }) {
182:             activeTabId = existingTab.id
183:             return
184:         }
185: 
186:         let newTab = Tab(fileName: fileName, content: content, url: url)
187:         tabs.append(newTab)
188:         activeTabId = newTab.id
189:     }
190: 
191:     func closeTab(id: UUID) {
192:         guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
193: 
194:         // Release security-scoped access if this tab was holding it.
195:         if let url = tabs[index].url {
196:             releaseSecurityScopedAccess(to: url)
197:         }
198: 
199:         tabs.remove(at: index)
200: 
201:         // Update active tab if we closed the active one
202:         if activeTabId == id {
203:             if tabs.isEmpty {
204:                 activeTabId = nil
205:             } else if index >= tabs.count {
206:                 activeTabId = tabs[tabs.count - 1].id
207:             } else {
208:                 activeTabId = tabs[index].id
209:             }
210:         }
211:     }
212: 
213:     func closeAllTabs() {
214:         // Release security-scoped access held by any open tabs.
215:         for tab in tabs {
216:             if let url = tab.url {
217:                 releaseSecurityScopedAccess(to: url)
218:             }
219:         }
220: 
221:         tabs.removeAll()
222:         activeTabId = nil
223:     }
224: 
225:     func closeOtherTabs(except id: UUID) {
226:         // Release security-scoped access for tabs being closed.
227:         for tab in tabs where tab.id != id {
228:             if let url = tab.url {
229:                 releaseSecurityScopedAccess(to: url)
230:             }
231:         }
232: 
233:         tabs.removeAll { $0.id != id }
234:         activeTabId = id
235:     }
236: 
237:     func selectTab(id: UUID) {
238:         activeTabId = id
239:     }
240: 
241:     func nextTab() {
242:         guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
243:         let nextIndex = (currentIndex + 1) % tabs.count
244:         activeTabId = tabs[nextIndex].id
245:     }
246: 
247:     func previousTab() {
248:         guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
249:         let prevIndex = currentIndex == 0 ? tabs.count - 1 : currentIndex - 1
250:         activeTabId = tabs[prevIndex].id
251:     }
252: 
253:     func moveTab(from source: IndexSet, to destination: Int) {
254:         tabs.move(fromOffsets: source, toOffset: destination)
255:     }
256: 
257:     // MARK: - Content Management
258: 
259:     func updateActiveTabContent(_ content: String) {
260:         guard let index = activeTabIndex else { return }
261:         tabs[index].content = content
262:         if tabs[index].url != nil {
263:             tabs[index].isUnsaved = true
264:         }
265:     }
266: 
267:     func saveActiveTab() {
268:         guard let index = activeTabIndex,
269:               let url = tabs[index].url else { return }
270: 
271:         // Ensure we have access when writing, even if this URL wasn't opened via openFile().
272:         let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
273:         defer { if didStart { url.stopAccessingSecurityScopedResource() } }
274: 
275:         do {
276:             try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
277:             tabs[index].isUnsaved = false
278:         } catch {
279:             print("Error saving file: \(error)")
280:         }
281:     }
282: 
283:     func saveAllTabs() {
284:         for index in tabs.indices {
285:             guard let url = tabs[index].url, tabs[index].isUnsaved else { continue }
286: 
287:             // Ensure we have access when writing, even if this URL wasn't opened via openFile().
288:             let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
289:             defer { if didStart { url.stopAccessingSecurityScopedResource() } }
290: 
291:             do {
292:                 try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
293:                 tabs[index].isUnsaved = false
294:             } catch {
295:                 print("Error saving file: \(error)")
296:             }
297:         }
298:     }
299: 
300:     // MARK: - File Operations
301: 
302:     /// Retain security scoped access for as long as a tab referencing the URL is open.
303:     /// - Returns: `true` if access was retained (either already retained or started successfully).
304:     @discardableResult
305:     private func retainSecurityScopedAccess(to url: URL) -> Bool {
306:         if let count = securityScopedAccessCounts[url] {
307:             securityScopedAccessCounts[url] = count + 1
308:             return true
309:         }
310: 
311:         let started = url.startAccessingSecurityScopedResource()
312:         if started {
313:             securityScopedAccessCounts[url] = 1
314:             return true
315:         }
316: 
317:         // Not all URLs are security-scoped; startAccessing may legitimately return false.
318:         return false
319:     }
320: 
321:     private func releaseSecurityScopedAccess(to url: URL) {
322:         guard let count = securityScopedAccessCounts[url] else { return }
323:         if count <= 1 {
324:             securityScopedAccessCounts.removeValue(forKey: url)
325:             url.stopAccessingSecurityScopedResource()
326:         } else {
327:             securityScopedAccessCounts[url] = count - 1
328:         }
329:     }
330: 
331:     func openFile(from url: URL) {
332:         // If already open, just activate it (and avoid re-reading / re-requesting access).
333:         if let existingTab = tabs.first(where: { $0.url == url }) {
334:             activeTabId = existingTab.id
335:             return
336:         }
337: 
338:         // IMPORTANT (BUG-005):
339:         // Do not early-return if startAccessingSecurityScopedResource() fails.
340:         // For many URLs (non-security-scoped, or when parent scope is active), this may return false,
341:         // but the file is still readable. We retain access if available.
342:         let retained = retainSecurityScopedAccess(to: url)
343: 
344:         do {
345:             let content = try String(contentsOf: url, encoding: .utf8)
346:             addTab(fileName: url.lastPathComponent, content: content, url: url)
347: 
348:             // Index the file in Spotlight for search
349:             SpotlightManager.shared.indexFile(url: url, content: content, fileName: url.lastPathComponent)
350:         } catch {
351:             print("Error opening file: \(error)")
352:             if retained {
353:                 // We retained access but failed to open; release our retain.
354:                 releaseSecurityScopedAccess(to: url)
355:             }
356:         }
357:     }
358: 
359:     func openFile(_ fileItem: FileItem) {
360:         guard let url = fileItem.url else {
361:             // Try path
362:             if !fileItem.path.isEmpty {
363:                 let fileURL = URL(fileURLWithPath: fileItem.path)
364:                 openFile(from: fileURL)
365:             }
366:             return
367:         }
368:         openFile(from: url)
369:     }
370: 
371:     // MARK: - File System Event Handlers
372: 
373:     /// Called when a file or folder is moved/renamed in the file system.
374:     /// Updates any open tabs that reference the old URL.
375:     func handleFileSystemItemMoved(from oldURL: URL, to newURL: URL) {
376:         for index in tabs.indices {
377:             guard let tabURL = tabs[index].url else { continue }
378: 
379:             // Check if tab URL matches the moved item or is inside it (for folders)
380:             let oldPath = oldURL.standardizedFileURL.path
381:             let tabPath = tabURL.standardizedFileURL.path
382: 
383:             if tabPath == oldPath {
384:                 // Direct match - update URL
385:                 tabs[index].url = newURL
386:                 tabs[index].fileName = newURL.lastPathComponent
387:             } else if tabPath.hasPrefix(oldPath + "/") {
388:                 // Tab is inside a moved folder - update the path prefix
389:                 let relativePath = String(tabPath.dropFirst(oldPath.count))
390:                 let newTabURL = URL(fileURLWithPath: newURL.path + relativePath)
391:                 tabs[index].url = newTabURL
392:             }
393:         }
394:     }
395: 
396:     /// Called when a file or folder is deleted from the file system.
397:     /// Closes any open tabs that reference the deleted item.
398:     func handleFileSystemItemDeleted(at url: URL) {
399:         let deletedPath = url.standardizedFileURL.path
400: 
401:         // Find all tabs that should be closed
402:         let tabsToClose = tabs.filter { tab in
403:             guard let tabURL = tab.url else { return false }
404:             let tabPath = tabURL.standardizedFileURL.path
405:             // Close if exact match or if tab is inside deleted folder
406:             return tabPath == deletedPath || tabPath.hasPrefix(deletedPath + "/")
407:         }
408: 
409:         // Close the tabs (release security access)
410:         for tab in tabsToClose {
411:             closeTab(id: tab.id)
412:         }
413:     }
414: 
415:     // MARK: - UI Toggles
416: 
417:     func toggleSidebar() {
418:         withAnimation(.spring(response: 0.3)) {
419:             showSidebar.toggle()
420:         }
421:     }
422: 
423:     func toggleCommandPalette() {
424:         showCommandPalette.toggle()
425:     }
426: 
427:     func toggleQuickOpen() {
428:         showQuickOpen.toggle()
429:     }
430: 
431:     func toggleSearch() {
432:         showSearch.toggle()
433:     }
434: 
435:     func toggleAIAssistant() {
436:         showAIAssistant.toggle()
437:     }
438: 
439:     func toggleGoToSymbol() {
440:         showGoToSymbol.toggle()
441:     }
442: 
443:     func toggleZenMode() {
444:         isZenMode.toggle()
445:     }
446: 
447:     func toggleFocusMode() {
448:         isFocusMode.toggle()
449:     }
450: 
451:     func togglePanel() {
452:         withAnimation(.spring(response: 0.3)) {
453:             showPanel.toggle()
454:         }
455:     }
456: 
457:     func addSelectionToNextFindMatch() {
458:         addNextOccurrence()
459:     }
460: 
461:     func zoomIn() {
462:         editorFontSize = min(editorFontSize + 2, 32)
463:     }
464: 
465:     func zoomOut() {
466:         editorFontSize = max(editorFontSize - 2, 8)
467:     }
468: 
469:     func resetZoom() {
470:         editorFontSize = 14.0
471:     }
472: 
473:     func focusExplorer() {
474:         focusedView = .explorer
475:         focusedSidebarTab = 0
476:         withAnimation {
477:             showSidebar = true
478:         }
479:     }
480: 
481:     func focusGit() {
482:         focusedView = .git
483:         focusedSidebarTab = 1
484:         withAnimation {
485:             showSidebar = true
486:         }
487:     }
488: 
489:     func renameSymbol() {
490:         showRenameSymbol.toggle()
491:     }
492: 
493:     // NOTE:
494:     // goToDefinitionAtCursor(), peekDefinitionAtCursor(), navigateBack(), and navigateForward()
495:     // are implemented in an EditorCore extension in Services/NavigationManager.swift.
496: 
497:     // MARK: - Peek Definition
498: 
499:     func triggerPeekDefinition(file: String, line: Int, content: String, sourceLine: Int) {
500:         peekState = PeekState(file: file, line: line, content: content, sourceLine: sourceLine)
501:     }
502: 
503:     func closePeekDefinition() {
504:         peekState = nil
505:     }
506: 
507:     // MARK: - Multi-Cursor Operations
508: 
509:     /// Add cursor at a specific position (Option+Click)
510:     func addCursorAtPosition(_ position: Int) {
511:         multiCursorState.addCursor(at: position)
512:     }
513: 
514:     /// Add cursor on the line above (Cmd+Option+Up)
515:     func addCursorAbove() {
516:         guard let index = activeTabIndex else { return }
517:         let content = tabs[index].content
518:         
519:         guard let primary = multiCursorState.primaryCursor else { return }
520:         
521:         // Find current line and column
522:         let lines = content.components(separatedBy: "\n")
523:         var currentLine = 0
524:         var charCount = 0
525:         var columnInLine = 0
526:         
527:         for (lineIndex, line) in lines.enumerated() {
528:             let lineLength = line.count + 1 // +1 for newline
529:             if charCount + lineLength > primary.position {
530:                 currentLine = lineIndex
531:                 columnInLine = primary.position - charCount
532:                 break
533:             }
534:             charCount += lineLength
535:         }
536:         
537:         // Can't add cursor above line 0
538:         guard currentLine > 0 else { return }
539:         
540:         // Calculate position on line above
541:         let targetLine = currentLine - 1
542:         var targetPosition = 0
543:         for i in 0..<targetLine {
544:             targetPosition += lines[i].count + 1
545:         }
546:         targetPosition += min(columnInLine, lines[targetLine].count)
547:         
548:         multiCursorState.addCursor(at: targetPosition)
549:     }
550: 
551:     /// Add cursor on the line below (Cmd+Option+Down)
552:     func addCursorBelow() {
553:         guard let index = activeTabIndex else { return }
554:         let content = tabs[index].content
555:         
556:         guard let primary = multiCursorState.primaryCursor else { return }
557:         
558:         // Find current line and column
559:         let lines = content.components(separatedBy: "\n")
560:         var currentLine = 0
561:         var charCount = 0
562:         var columnInLine = 0
563:         
564:         for (lineIndex, line) in lines.enumerated() {
565:             let lineLength = line.count + 1 // +1 for newline
566:             if charCount + lineLength > primary.position {
567:                 currentLine = lineIndex
568:                 columnInLine = primary.position - charCount
569:                 break
570:             }
571:             charCount += lineLength
572:         }
573:         
574:         // Can't add cursor below last line
575:         guard currentLine < lines.count - 1 else { return }
576:         
577:         // Calculate position on line below
578:         let targetLine = currentLine + 1
579:         var targetPosition = 0
580:         for i in 0..<targetLine {
581:             targetPosition += lines[i].count + 1
582:         }
583:         targetPosition += min(columnInLine, lines[targetLine].count)
584:         
585:         multiCursorState.addCursor(at: targetPosition)
586:     }
587: 
588:     /// Add next occurrence of current selection (Cmd+D)
589:     func addNextOccurrence() {
590:         guard let index = activeTabIndex else { return }
591:         let content = tabs[index].content
592: 
593:         // Get the word/selection to search for
594:         let searchText: String
595:         let startPosition: Int
596: 
597:         if let range = currentSelectionRange, range.length > 0,
598:            let swiftRange = Range(range, in: content) {
599:             searchText = String(content[swiftRange])
600:             startPosition = range.location + range.length
601:         } else if let primary = multiCursorState.primaryCursor {
602:             // No selection - select the word under cursor
603:             let wordRange = findWordAtPosition(primary.position, in: content)
604:             if let range = wordRange, range.length > 0,
605:                let swiftRange = Range(range, in: content) {
606:                 searchText = String(content[swiftRange])
607:                 startPosition = range.location + range.length
608: 
609:                 // First Cmd+D selects the word under cursor
610:                 multiCursorState.cursors = [Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)]
611:                 currentSelectionRange = range
612:                 currentSelection = searchText
613:                 return
614:             } else {
615:                 return
616:             }
617:         } else {
618:             return
619:         }
620: 
621:         // Find next occurrence
622:         if let nextRange = content.findNextOccurrence(of: searchText, after: startPosition) {
623:             // Check if this occurrence is already selected
624:             let alreadySelected = multiCursorState.cursors.contains { cursor in
625:                 if let selRange = cursor.selectionRange {
626:                     return selRange.location == nextRange.location
627:                 }
628:                 return false
629:             }
630: 
631:             if !alreadySelected {
632:                 multiCursorState.addCursorWithSelection(
633:                     position: nextRange.location + nextRange.length,
634:                     anchor: nextRange.location
635:                 )
636:             }
637:         }
638:     }
639: 
640:     /// Select all occurrences of current selection (Cmd+Shift+L)
641:     func selectAllOccurrences() {
642:         guard let index = activeTabIndex else { return }
643:         let content = tabs[index].content
644: 
645:         // Get the word/selection to search for
646:         let searchText: String
647: 
648:         if let range = currentSelectionRange, range.length > 0,
649:            let swiftRange = Range(range, in: content) {
650:             searchText = String(content[swiftRange])
651:         } else if let primary = multiCursorState.primaryCursor {
652:             // No selection - use word under cursor
653:             let wordRange = findWordAtPosition(primary.position, in: content)
654:             if let range = wordRange, range.length > 0,
655:                let swiftRange = Range(range, in: content) {
656:                 searchText = String(content[swiftRange])
657:             } else {
658:                 return
659:             }
660:         } else {
661:             return
662:         }
663: 
664:         // Find all occurrences
665:         let allRanges = content.findAllOccurrences(of: searchText)
666: 
667:         guard !allRanges.isEmpty else { return }
668: 
669:         // Create cursors for all occurrences
670:         multiCursorState.cursors = allRanges.enumerated().map { index, range in
671:             Cursor(
672:                 position: range.location + range.length,
673:                 anchor: range.location,
674:                 isPrimary: index == 0
675:             )
676:         }
677: 
678:         currentSelection = searchText
679:     }
680: 
681:     /// Reset to single cursor
682:     func resetToSingleCursor(at position: Int) {
683:         multiCursorState.reset(to: position)
684:         currentSelectionRange = nil
685:         currentSelection = ""
686:     }
687: 
688:     /// Update selection from text view
689:     func updateSelection(range: NSRange?, text: String) {
690:         currentSelectionRange = range
691:         if let range = range, range.length > 0,
692:            let index = activeTabIndex {
693:             let content = tabs[index].content
694:             if let swiftRange = Range(range, in: content) {
695:                 currentSelection = String(content[swiftRange])
696:             }
697:         } else {
698:             currentSelection = ""
699:         }
700:     }
701: 
702:     /// Find word boundaries at a given position
703:     func findWordAtPosition(_ position: Int, in text: String) -> NSRange? {
704:         guard position >= 0 && position <= text.count else { return nil }
705: 
706:         let nsText = text as NSString
707:         let wordCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
708: 
709:         // Find start of word
710:         var start = position
711:         while start > 0 {
712:             let char = nsText.substring(with: NSRange(location: start - 1, length: 1))
713:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
714:                 start -= 1
715:             } else {
716:                 break
717:             }
718:         }
719: 
720:         // Find end of word
721:         var end = position
722:         while end < nsText.length {
723:             let char = nsText.substring(with: NSRange(location: end, length: 1))
724:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
725:                 end += 1
726:             } else {
727:                 break
728:             }
729:         }
730: 
731:         if start == end {
732:             return nil
733:         }
734: 
735:         return NSRange(location: start, length: end - start)
736:     }
737: 
738:     /// Escape multi-cursor mode
739:     func escapeMultiCursor() {
740:         if multiCursorState.isMultiCursor {
741:             if let primary = multiCursorState.primaryCursor {
742:                 resetToSingleCursor(at: primary.position)
743:             }
744:         }
745:     }
746: 
747:     // MARK: - Code Folding
748: 
749:     /// Collapse all foldable regions in the active editor
750:     func collapseAllFolds() {
751:         guard let index = activeTabIndex else { return }
752:         // Post notification that will be picked up by the editor view
753:         NotificationCenter.default.post(
754:             name: .collapseAllFolds,
755:             object: nil,
756:             userInfo: ["tabId": tabs[index].id]
757:         )
758:     }
759: 
760:     /// Expand all collapsed regions in the active editor
761:     func expandAllFolds() {
762:         guard let index = activeTabIndex else { return }
763:         // Post notification that will be picked up by the editor view
764:         NotificationCenter.default.post(
765:             name: .expandAllFolds,
766:             object: nil,
767:             userInfo: ["tabId": tabs[index].id]
768:         )
769:     }
770: }
771: 
772: // MARK: - Notification Names for Code Folding
773: 
774: extension Notification.Name {
775:     static let collapseAllFolds = Notification.Name("collapseAllFolds")
776:     static let expandAllFolds = Notification.Name("expandAllFolds")
777: }
778: 


Now I need to find where the text view actually uses `editorFontSize`. Let me search for how it's consumed:

>>>TOOL search
{"query": "editorFontSize", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "editorFontSize"


Let me search for font size references more broadly:

>>>TOOL search
{"query": "fontSize", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "fontSize"


>>>TOOL search
{"query": "font", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "font"


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/
📁 App/
📁 Assets.xcassets/
📁 Commands/
📁 Docs/
📁 Extensions/
📁 Menus/
📁 Models/
📁 Resources/
📁 Services/
📁 Tests/
📁 UITests/
📁 Utils/
📁 Views/
   .tooling_note.txt
   ContentView_shift_arrow.patch
   ContentView.swift
   ContentView.swift.bak
   FIX_SUMMARY.md
   IMPLEMENTATION_SUMMARY.md
   Info.plist
   KeyboardShortcuts.md
   MULTI_WINDOW_IMPLEMENTATION.md
   MultiWindowSupport.md
   SceneDelegate.swift
   SyntaxHighlighter_Optimizations.md


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/
📁 Editor/
📁 Panels/
   _tmp.txt
   BranchMenu.swift
   CommandPalette.swift
   CommandPaletteView.swift
   DiffComponents.swift
   FileIconView.swift
   FileTreeView.swift
   GoToSymbol.swift
   LaunchConfigView.swift
   QuickOpen.swift
   RunConfigView.swift
   SidebarView.swift
   SnippetPickerView.swift
   StatusBarView.swift
   TabBarView.swift
   TasksView.swift
   WorkspaceSettingsView.swift
   WorkspaceTrustDialog.swift


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/Editor/
   BreadcrumbsView.swift
   ColorPickerView.swift
   EditorSplitView.swift
   GitGutterView.swift
   HoverInfoView.swift
   InlayHintsOverlay.swift
   InlineSuggestionView.swift
   JSONTreeView.swift
   MergeConflictView.swift
   MinimapView.swift
   MultiCursorTextView.swift
   PeekDefinitionView.swift
   SplitEditorView.swift
   StickyHeaderView.swift
   SyntaxHighlightingTextView_Update.swift
   SyntaxHighlightingTextView.swift


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
⚠️ File too large (83502 chars, 1931 lines). Showing first 100 lines.
Use start_line/end_line to read specific sections.

File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
────────────────────────────────────────
1: //
2: //  SyntaxHighlightingTextView.swift
3: //  VSCodeiPadOS
4: //
5: //  Upgraded syntax highlighting with VSCode-like colors
6: //
7: 
8: import SwiftUI
9: import UIKit
10: 
11: /// UITextView wrapper with syntax highlighting support
12: struct SyntaxHighlightingTextView: UIViewRepresentable {
13:     @Binding var text: String
14:     let filename: String
15:     @Binding var scrollPosition: Int
16:     @Binding var totalLines: Int
17:     @Binding var visibleLines: Int
18:     @Binding var currentLineNumber: Int
19:     @Binding var currentColumn: Int
20:     @Binding var cursorIndex: Int
21:     @Binding var lineHeight: CGFloat
22:     @Binding var requestedLineSelection: Int?
23:     @Binding var requestedCursorIndex: Int?
24: 
25:     /// Autocomplete key handling hooks (return true if handled)
26:     let onAcceptAutocomplete: (() -> Bool)?
27:     let onDismissAutocomplete: (() -> Bool)?
28: 
29:     let isActive: Bool
30:     @EnvironmentObject var editorCore: EditorCore
31: 
32:     init(
33:         text: Binding<String>,
34:         filename: String,
35:         scrollPosition: Binding<Int>,
36:         totalLines: Binding<Int>,
37:         visibleLines: Binding<Int>,
38:         currentLineNumber: Binding<Int>,
39:         currentColumn: Binding<Int>,
40:         cursorIndex: Binding<Int> = .constant(0),
41:         lineHeight: Binding<CGFloat>,
42:         isActive: Bool,
43:         requestedLineSelection: Binding<Int?> = .constant(nil),
44:         requestedCursorIndex: Binding<Int?> = .constant(nil),
45:         onAcceptAutocomplete: (() -> Bool)? = nil,
46:         onDismissAutocomplete: (() -> Bool)? = nil
47:     ) {
48:         self._text = text
49:         self.filename = filename
50:         self._scrollPosition = scrollPosition
51:         self._totalLines = totalLines
52:         self._visibleLines = visibleLines
53:         self._currentLineNumber = currentLineNumber
54:         self._currentColumn = currentColumn
55:         self._cursorIndex = cursorIndex
56:         self._lineHeight = lineHeight
57:         self.isActive = isActive
58:         self._requestedLineSelection = requestedLineSelection
59:         self._requestedCursorIndex = requestedCursorIndex
60:         self.onAcceptAutocomplete = onAcceptAutocomplete
61:         self.onDismissAutocomplete = onDismissAutocomplete
62:     }
63:     
64:     // Compatibility init for older call sites (e.g. SplitEditorView) that pass editorCore explicitly.
65:     init(
66:         text: Binding<String>,
67:         filename: String,
68:         scrollPosition: Binding<Int>,
69:         totalLines: Binding<Int>,
70:         visibleLines: Binding<Int>,
71:         currentLineNumber: Binding<Int>,
72:         currentColumn: Binding<Int>,
73:         cursorIndex: Binding<Int> = .constant(0),
74:         lineHeight: Binding<CGFloat>,
75:         isActive: Bool,
76:         editorCore: EditorCore,
77:         requestedLineSelection: Binding<Int?> = .constant(nil),
78:         requestedCursorIndex: Binding<Int?> = .constant(nil),
79:         onAcceptAutocomplete: (() -> Bool)? = nil,
80:         onDismissAutocomplete: (() -> Bool)? = nil
81:     ) {
82:         self.init(
83:             text: text,
84:             filename: filename,
85:             scrollPosition: scrollPosition,
86:             totalLines: totalLines,
87:             visibleLines: visibleLines,
88:             currentLineNumber: currentLineNumber,
89:             currentColumn: currentColumn,
90:             cursorIndex: cursorIndex,
91:             lineHeight: lineHeight,
92:             isActive: isActive,
93:             requestedLineSelection: requestedLineSelection,
94:             requestedCursorIndex: requestedCursorIndex,
95:             onAcceptAutocomplete: onAcceptAutocomplete,
96:             onDismissAutocomplete: onDismissAutocomplete
97:         )
98:     }
99: 
100:     func makeCoordinator() -> Coordinator {

... [truncated - 1831 more lines]


>>>TOOL search
{"query": "font", "glob": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 25 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:164: // Set font and appearance (use editorCore.editorFontSize)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:165: textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:176: if let font = textView.font {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:178: self.lineHeight = font.lineHeight
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:200: // Update font size if changed
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:201: if let currentFont = textView.font, currentFont.pointSize != editorCore.editorFontSize {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:203: textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:208: if let font = textView.font {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:210: self.lineHeight = font.lineHeight
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:291: let fontSize = parent.editorCore.editorFontSize
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:293: .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:362: guard let font = textView.font else { return }
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:363: let lineHeight = font.lineHeight
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:425: let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:434: let fontSize = parent.editorCore.editorFontSize
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:436: .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:553: // Store the initial font size when pinch begins
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:557: // Calculate new font size based on pinch scale
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:560: // Clamp font size between 8 and 32
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:563: // Update EditorCore's font size (this will trigger updateUIView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:731: guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:759: let spaceWidth = " ".size(withAttributes: [.font: font]).width
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1215: init(theme: Theme = ThemeManager.shared.currentTheme, fontSize: CGFloat = 14) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1217: self.baseFontSize = fontSize
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1281: attributed.addAttribute(.font, value: baseFont, range: fullRange)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 150, "end_line": 250}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 151-250 of 1931)
────────────────────────────────────────
151:         textView.addGestureRecognizer(pinchGesture)
152:         context.coordinator.pinchGesture = pinchGesture
153:         
154:         // Configure text view
155:         textView.isEditable = true
156:         textView.isSelectable = true
157:         textView.autocapitalizationType = .none
158:         textView.autocorrectionType = .no
159:         textView.smartDashesType = .no
160:         textView.smartQuotesType = .no
161:         textView.smartInsertDeleteType = .no
162:         textView.spellCheckingType = .no
163:         
164:         // Set font and appearance (use editorCore.editorFontSize)
165:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
166:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
167:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
168:         textView.keyboardType = .default
169:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
170:         
171:         // Enable line wrapping
172:         textView.textContainer.lineBreakMode = .byCharWrapping
173:         textView.textContainer.widthTracksTextView = true
174:         
175:         // Calculate line height
176:         if let font = textView.font {
177:             DispatchQueue.main.async {
178:                 self.lineHeight = font.lineHeight
179:             }
180:         }
181:         
182:         // Set initial text with syntax highlighting
183:         textView.text = text
184:         context.coordinator.applySyntaxHighlighting(to: textView)
185:         context.coordinator.updateLineCount(textView)
186:         
187:         return textView
188:     }
189:     
190:     func updateUIView(_ textView: UITextView, context: Context) {
191:         // Update colors when theme changes
192:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
193:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
194:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
195:         
196:         if let editorView = textView as? EditorTextView {
197:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
198:         }
199:         
200:         // Update font size if changed
201:         if let currentFont = textView.font, currentFont.pointSize != editorCore.editorFontSize {
202:             let selectedRange = textView.selectedRange
203:             textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
204:             context.coordinator.applySyntaxHighlighting(to: textView)
205:             textView.selectedRange = selectedRange
206:             
207:             // Update line height
208:             if let font = textView.font {
209:                 DispatchQueue.main.async {
210:                     self.lineHeight = font.lineHeight
211:                 }
212:             }
213:         }
214:         
215:         // Update text if changed externally
216:         if textView.text != text {
217:             let selectedRange = textView.selectedRange
218:             textView.text = text
219:             context.coordinator.applySyntaxHighlighting(to: textView)
220:             textView.selectedRange = selectedRange
221:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
222:             // Re-apply highlighting if theme changed
223:             context.coordinator.applySyntaxHighlighting(to: textView)
224:         }
225:         
226:         // Handle minimap scrolling
227:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 {
228:             // Update lastKnownScrollPosition FIRST to prevent race condition
229:             // where user scroll gets overridden by stale binding value
230:             context.coordinator.lastKnownScrollPosition = scrollPosition
231:             context.coordinator.scrollToLine(scrollPosition, in: textView)
232:         }
233: 
234:         // Handle line selection requests (e.g. tapping line numbers)
235:         if let requested = requestedLineSelection,
236:            requested != context.coordinator.lastRequestedLineSelection {
237:             context.coordinator.lastRequestedLineSelection = requested
238:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
239:             // Defer @Binding update to avoid "Publishing changes from within view updates"
240:             DispatchQueue.main.async {
241:                 self.requestedLineSelection = nil
242:             }
243:         }
244: 
245:         // Handle cursor index requests (e.g. accepting autocomplete)
246:         if let requested = requestedCursorIndex,
247:            requested != context.coordinator.lastRequestedCursorIndex {
248:             context.coordinator.lastRequestedCursorIndex = requested
249:             textView.selectedRange = NSRange(location: max(0, requested), length: 0)
250:             // Defer @Binding update to avoid "Publishing changes from within view updates"


I found the font size update code. Now let me look at the `applySyntaxHighlighting` method to see if it's overwriting the font:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 450, "end_line": 600}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 451-600 of 1931)
────────────────────────────────────────
451:                  let prefix = String(text.prefix(location))
452:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
453:                  
454:                  parent.editorCore.triggerPeekDefinition(
455:                      file: parent.filename,
456:                      line: sourceLine,
457:                      content: text,
458:                      sourceLine: sourceLine
459:                  )
460:             }
461:         }
462:         
463:         func handleEscape() {
464:             if parent.editorCore.peekState != nil {
465:                 parent.editorCore.closePeekDefinition()
466:             } else {
467:                 parent.editorCore.escapeMultiCursor()
468:             }
469:         }
470:         
471:         func handleGoToDefinition(in textView: UITextView) {
472:             // Reuse the peek definition logic for now
473:             handlePeekDefinition(in: textView)
474:         }
475:         
476:         func handleFindReferences(in textView: UITextView) {
477:             guard let selectedRange = textView.selectedTextRange else { return }
478:             let text = textView.text ?? ""
479:             
480:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
481:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
482:                 
483:                 let prefix = String(text.prefix(location))
484:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
485:                 
486:                 // TODO: Implement find references functionality in EditorCore
487:                 // For now, just trigger peek definition as a placeholder
488:                 parent.editorCore.triggerPeekDefinition(
489:                     file: parent.filename,
490:                     line: sourceLine,
491:                     content: text,
492:                     sourceLine: sourceLine
493:                 )
494:             }
495:         }
496:         
497:         func handleFormatDocument(in textView: UITextView) {
498:             // TODO: Implement format document functionality
499:             // This would typically call a formatter in EditorCore
500:             print("Format Document: Not yet implemented")
501:         }
502:         
503:         func handleToggleComment(in textView: UITextView) {
504:             guard let selectedRange = textView.selectedTextRange else { return }
505:             let text = textView.text ?? ""
506:             
507:             // Get the current line range
508:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
509:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
510:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
511:                 let nsRange = NSRange(location: location, length: length)
512:                 
513:                 if nsRange.location + nsRange.length <= (text as NSString).length {
514:                     let lineText = (text as NSString).substring(with: nsRange)
515:                     let trimmed = lineText.trimmingCharacters(in: .whitespaces)
516:                     
517:                     // Check if line starts with a comment
518:                     let isCommented = trimmed.hasPrefix("//") || trimmed.hasPrefix("#") || trimmed.hasPrefix("/*")
519:                     
520:                     // Toggle comment
521:                     var newLineText: String
522:                     if isCommented {
523:                         // Remove comment
524:                         newLineText = lineText.replacingOccurrences(of: "//", with: "").replacingOccurrences(of: "#", with: "", options: .anchored)
525:                     } else {
526:                         // Add comment (use // for most languages)
527:                         newLineText = "//" + lineText
528:                     }
529:                     
530:                     // Replace the line
531:                     let textStorage = textView.textStorage
532:                     textStorage.replaceCharacters(in: nsRange, with: newLineText)
533:                     
534:                     // Update parent binding
535:                     parent.text = textView.text
536:                 }
537:             }
538:         }
539:         
540:         func handleFold(in textView: UITextView) {
541:             CodeFoldingManager.shared.foldCurrentLine()
542:         }
543:         
544:         func handleUnfold(in textView: UITextView) {
545:             CodeFoldingManager.shared.unfoldCurrentLine()
546:         }
547:         
548:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
549:             guard let textView = gesture.view as? UITextView else { return }
550: 
551:             switch gesture.state {
552:             case .began:
553:                 // Store the initial font size when pinch begins
554:                 initialFontSize = parent.editorCore.editorFontSize
555: 
556:             case .changed:
557:                 // Calculate new font size based on pinch scale
558:                 let newSize = initialFontSize * gesture.scale
559: 
560:                 // Clamp font size between 8 and 32
561:                 let clampedSize = min(max(newSize, 8), 32)
562: 
563:                 // Update EditorCore's font size (this will trigger updateUIView)
564:                 parent.editorCore.editorFontSize = clampedSize
565: 
566:             case .ended, .cancelled:
567:                 // Optional: snap to nearest whole number or standard size
568:                 let finalSize = round(parent.editorCore.editorFontSize)
569:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
570: 
571:             default:
572:                 break
573:             }
574:         }
575: 
576:         // MARK: - FEAT-044 Matching Bracket Highlight
577: 
578:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
579:             // Clear any existing highlights
580:             if !bracketHighlightRanges.isEmpty {
581:                 for r in bracketHighlightRanges {
582:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
583:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
584:                 }
585:                 bracketHighlightRanges.removeAll()
586:             }
587: 
588:             // Only highlight when there's a caret (no selection)
589:             let selection = textView.selectedRange
590:             guard selection.length == 0 else { return }
591: 
592:             let nsText = (textView.text ?? "") as NSString
593:             let length = nsText.length
594:             guard length > 0 else { return }
595: 
596:             let caret = selection.location
597: 
598:             // Candidate bracket location: char before caret, else at caret
599:             let candidateIndices: [Int] = [
600:                 caret - 1,


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 400, "end_line": 450}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 401-450 of 1931)
────────────────────────────────────────
401:             guard line >= 0 && line < lines.count else { return }
402: 
403:             var characterPosition = 0
404:             for i in 0..<line {
405:                 characterPosition += lines[i].count + 1
406:             }
407: 
408:             // FEAT-041: select entire line (excluding trailing newline)
409:             let lineLength = (lines[line] as NSString).length
410:             let range = NSRange(location: characterPosition, length: lineLength)
411:             textView.selectedRange = range
412: 
413:             // Ensure it's visible
414:             scrollToLine(line, in: textView)
415: 
416:             // Update SwiftUI state
417:             updateCursorPosition(textView)
418:             updateScrollPosition(textView)
419:         }
420: 
421:         func applySyntaxHighlighting(to textView: UITextView) {
422:             let theme = ThemeManager.shared.currentTheme
423:             lastThemeId = theme.id
424: 
425:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
426:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
427: 
428:             let selectedRange = textView.selectedRange
429:             textView.attributedText = attributedText
430:             textView.selectedRange = selectedRange
431: 
432:             // Set typing attributes so newly typed characters have correct base styling
433:             // This prevents flicker during the debounce period before full highlighting runs
434:             let fontSize = parent.editorCore.editorFontSize
435:             textView.typingAttributes = [
436:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
437:                 .foregroundColor: UIColor(theme.editorForeground)
438:             ]
439: 
440:             // FEAT-044: restore matching bracket highlight after re-attributing text
441:             updateMatchingBracketHighlight(textView)
442:         }
443:         
444:         func handlePeekDefinition(in textView: UITextView) {
445:             guard let selectedRange = textView.selectedTextRange else { return }
446:             let text = textView.text ?? ""
447:             
448:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
449:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
450:                  


Let me see how `SyntaxHighlightingTextView` is declared and how it observes `editorCore`:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1, "end_line": 150}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-150 of 1931)
────────────────────────────────────────
2: //  SyntaxHighlightingTextView.swift
3: //  VSCodeiPadOS
4: //
5: //  Upgraded syntax highlighting with VSCode-like colors
6: //
7: 
8: import SwiftUI
9: import UIKit
10: 
11: /// UITextView wrapper with syntax highlighting support
12: struct SyntaxHighlightingTextView: UIViewRepresentable {
13:     @Binding var text: String
14:     let filename: String
15:     @Binding var scrollPosition: Int
16:     @Binding var totalLines: Int
17:     @Binding var visibleLines: Int
18:     @Binding var currentLineNumber: Int
19:     @Binding var currentColumn: Int
20:     @Binding var cursorIndex: Int
21:     @Binding var lineHeight: CGFloat
22:     @Binding var requestedLineSelection: Int?
23:     @Binding var requestedCursorIndex: Int?
24: 
25:     /// Autocomplete key handling hooks (return true if handled)
26:     let onAcceptAutocomplete: (() -> Bool)?
27:     let onDismissAutocomplete: (() -> Bool)?
28: 
29:     let isActive: Bool
30:     @EnvironmentObject var editorCore: EditorCore
31: 
32:     init(
33:         text: Binding<String>,
34:         filename: String,
35:         scrollPosition: Binding<Int>,
36:         totalLines: Binding<Int>,
37:         visibleLines: Binding<Int>,
38:         currentLineNumber: Binding<Int>,
39:         currentColumn: Binding<Int>,
40:         cursorIndex: Binding<Int> = .constant(0),
41:         lineHeight: Binding<CGFloat>,
42:         isActive: Bool,
43:         requestedLineSelection: Binding<Int?> = .constant(nil),
44:         requestedCursorIndex: Binding<Int?> = .constant(nil),
45:         onAcceptAutocomplete: (() -> Bool)? = nil,
46:         onDismissAutocomplete: (() -> Bool)? = nil
47:     ) {
48:         self._text = text
49:         self.filename = filename
50:         self._scrollPosition = scrollPosition
51:         self._totalLines = totalLines
52:         self._visibleLines = visibleLines
53:         self._currentLineNumber = currentLineNumber
54:         self._currentColumn = currentColumn
55:         self._cursorIndex = cursorIndex
56:         self._lineHeight = lineHeight
57:         self.isActive = isActive
58:         self._requestedLineSelection = requestedLineSelection
59:         self._requestedCursorIndex = requestedCursorIndex
60:         self.onAcceptAutocomplete = onAcceptAutocomplete
61:         self.onDismissAutocomplete = onDismissAutocomplete
62:     }
63:     
64:     // Compatibility init for older call sites (e.g. SplitEditorView) that pass editorCore explicitly.
65:     init(
66:         text: Binding<String>,
67:         filename: String,
68:         scrollPosition: Binding<Int>,
69:         totalLines: Binding<Int>,
70:         visibleLines: Binding<Int>,
71:         currentLineNumber: Binding<Int>,
72:         currentColumn: Binding<Int>,
73:         cursorIndex: Binding<Int> = .constant(0),
74:         lineHeight: Binding<CGFloat>,
75:         isActive: Bool,
76:         editorCore: EditorCore,
77:         requestedLineSelection: Binding<Int?> = .constant(nil),
78:         requestedCursorIndex: Binding<Int?> = .constant(nil),
79:         onAcceptAutocomplete: (() -> Bool)? = nil,
80:         onDismissAutocomplete: (() -> Bool)? = nil
81:     ) {
82:         self.init(
83:             text: text,
84:             filename: filename,
85:             scrollPosition: scrollPosition,
86:             totalLines: totalLines,
87:             visibleLines: visibleLines,
88:             currentLineNumber: currentLineNumber,
89:             currentColumn: currentColumn,
90:             cursorIndex: cursorIndex,
91:             lineHeight: lineHeight,
92:             isActive: isActive,
93:             requestedLineSelection: requestedLineSelection,
94:             requestedCursorIndex: requestedCursorIndex,
95:             onAcceptAutocomplete: onAcceptAutocomplete,
96:             onDismissAutocomplete: onDismissAutocomplete
97:         )
98:     }
99: 
100:     func makeCoordinator() -> Coordinator {
101:         Coordinator(self)
102:     }
103:     
104:     func makeUIView(context: Context) -> UITextView {
105:         let textView = EditorTextView()
106:         textView.delegate = context.coordinator
107: 
108:         // Autocomplete hooks
109:         textView.onAcceptAutocomplete = onAcceptAutocomplete
110:         textView.onDismissAutocomplete = onDismissAutocomplete
111: 
112:         textView.onPeekDefinition = {
113:             context.coordinator.handlePeekDefinition(in: textView)
114:         }
115: 
116:         textView.onEscape = {
117:             context.coordinator.handleEscape()
118:         }
119: 
120:         textView.onGoToLine = {
121:             self.editorCore.showGoToLine = true
122:         }
123:         
124:         // Wire up custom context menu actions
125:         textView.onGoToDefinition = {
126:             context.coordinator.handleGoToDefinition(in: textView)
127:         }
128:         
129:         textView.onFindReferences = {
130:             context.coordinator.handleFindReferences(in: textView)
131:         }
132:         
133:         textView.onFormatDocument = {
134:             context.coordinator.handleFormatDocument(in: textView)
135:         }
136:         
137:         textView.onToggleComment = {
138:             context.coordinator.handleToggleComment(in: textView)
139:         }
140:         
141:         textView.onFold = {
142:             context.coordinator.handleFold(in: textView)
143:         }
144:         
145:         textView.onUnfold = {
146:             context.coordinator.handleUnfold(in: textView)
147:         }
148:         
149:         // Add pinch gesture for zoom
150:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))


>>>TOOL search
{"query": "func applySyntaxHighlighting", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "func applySyntaxHighlighting"


>>>TOOL search
{"query": "applySyntaxHighlighting", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "applySyntaxHighlighting"


>>>TOOL get_symbols
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[get_symbols]
No symbols found in VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (file may need to be opened first)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 280, "end_line": 380}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 281-380 of 1931)
────────────────────────────────────────
281:             self.parent = parent
282:         }
283:         
284:         func textViewDidChange(_ textView: UITextView) {
285:             // Update parent text
286:             parent.text = textView.text
287:             
288:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
289:             // This prevents flicker during the debounce period
290:             let theme = ThemeManager.shared.currentTheme
291:             let fontSize = parent.editorCore.editorFontSize
292:             textView.typingAttributes = [
293:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
294:                 .foregroundColor: UIColor(theme.editorForeground)
295:             ]
296:             
297:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
298:             highlightDebouncer?.invalidate()
299:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
300:                 DispatchQueue.main.async {
301:                     self?.applySyntaxHighlighting(to: textView)
302:                 }
303:             }
304:             
305:             updateLineCount(textView)
306:             updateCursorPosition(textView)
307:         }
308:         
309:         func textViewDidChangeSelection(_ textView: UITextView) {
310:             if !isUpdatingFromMinimap {
311:                 updateCursorPosition(textView)
312:                 updateScrollPosition(textView)
313: 
314:                 // FEAT-044: Matching bracket highlight
315:                 updateMatchingBracketHighlight(textView)
316: 
317:                 // Trigger redraw so current-line highlight/indent guides track the caret
318:                 (textView as? EditorTextView)?.setNeedsDisplay()
319: 
320:                 // Update selection in EditorCore for multi-cursor support
321:                 let range = textView.selectedRange
322:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
323: 
324:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
325:                 if !parent.editorCore.multiCursorState.isMultiCursor {
326:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
327:                 }
328:             }
329:         }
330:         
331:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
332:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
333:             updateScrollPosition(textView)
334:         }
335:         
336:         func updateLineCount(_ textView: UITextView) {
337:             let lines = textView.text.components(separatedBy: .newlines)
338:             DispatchQueue.main.async {
339:                 self.parent.totalLines = max(1, lines.count)
340:             }
341:         }
342:         
343:         func updateCursorPosition(_ textView: UITextView) {
344:             guard let selectedRange = textView.selectedTextRange else { return }
345:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
346:              
347:              let text = textView.text ?? ""
348:              let prefix = String(text.prefix(cursorPosition))
349:              let lines = prefix.components(separatedBy: .newlines)
350:              
351:              let lineNumber = lines.count
352:              let column = (lines.last?.count ?? 0) + 1
353:              
354:              DispatchQueue.main.async {
355:                  self.parent.currentLineNumber = lineNumber
356:                  self.parent.currentColumn = column
357:                  self.parent.cursorIndex = cursorPosition
358:              }
359:         }
360:         
361:         func updateScrollPosition(_ textView: UITextView) {
362:             guard let font = textView.font else { return }
363:             let lineHeight = font.lineHeight
364:             let scrollOffset = textView.contentOffset.y
365:             let line = Int(scrollOffset / lineHeight)
366:             
367:             lastKnownScrollPosition = line
368:             DispatchQueue.main.async {
369:                 self.parent.scrollPosition = line
370:             }
371:         }
372:         
373:         func scrollToLine(_ line: Int, in textView: UITextView) {
374:             guard !isUpdatingFromMinimap else { return }
375:             isUpdatingFromMinimap = true
376:             
377:             let lines = textView.text.components(separatedBy: .newlines)
378:             guard line >= 0 && line < lines.count else {
379:                 isUpdatingFromMinimap = false
380:                 return


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 410, "end_line": 500}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 411-500 of 1931)
────────────────────────────────────────
411:             textView.selectedRange = range
412: 
413:             // Ensure it's visible
414:             scrollToLine(line, in: textView)
415: 
416:             // Update SwiftUI state
417:             updateCursorPosition(textView)
418:             updateScrollPosition(textView)
419:         }
420: 
421:         func applySyntaxHighlighting(to textView: UITextView) {
422:             let theme = ThemeManager.shared.currentTheme
423:             lastThemeId = theme.id
424: 
425:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
426:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
427: 
428:             let selectedRange = textView.selectedRange
429:             textView.attributedText = attributedText
430:             textView.selectedRange = selectedRange
431: 
432:             // Set typing attributes so newly typed characters have correct base styling
433:             // This prevents flicker during the debounce period before full highlighting runs
434:             let fontSize = parent.editorCore.editorFontSize
435:             textView.typingAttributes = [
436:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
437:                 .foregroundColor: UIColor(theme.editorForeground)
438:             ]
439: 
440:             // FEAT-044: restore matching bracket highlight after re-attributing text
441:             updateMatchingBracketHighlight(textView)
442:         }
443:         
444:         func handlePeekDefinition(in textView: UITextView) {
445:             guard let selectedRange = textView.selectedTextRange else { return }
446:             let text = textView.text ?? ""
447:             
448:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
449:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
450:                  
451:                  let prefix = String(text.prefix(location))
452:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
453:                  
454:                  parent.editorCore.triggerPeekDefinition(
455:                      file: parent.filename,
456:                      line: sourceLine,
457:                      content: text,
458:                      sourceLine: sourceLine
459:                  )
460:             }
461:         }
462:         
463:         func handleEscape() {
464:             if parent.editorCore.peekState != nil {
465:                 parent.editorCore.closePeekDefinition()
466:             } else {
467:                 parent.editorCore.escapeMultiCursor()
468:             }
469:         }
470:         
471:         func handleGoToDefinition(in textView: UITextView) {
472:             // Reuse the peek definition logic for now
473:             handlePeekDefinition(in: textView)
474:         }
475:         
476:         func handleFindReferences(in textView: UITextView) {
477:             guard let selectedRange = textView.selectedTextRange else { return }
478:             let text = textView.text ?? ""
479:             
480:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
481:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
482:                 
483:                 let prefix = String(text.prefix(location))
484:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
485:                 
486:                 // TODO: Implement find references functionality in EditorCore
487:                 // For now, just trigger peek definition as a placeholder
488:                 parent.editorCore.triggerPeekDefinition(
489:                     file: parent.filename,
490:                     line: sourceLine,
491:                     content: text,
492:                     sourceLine: sourceLine
493:                 )
494:             }
495:         }
496:         
497:         func handleFormatDocument(in textView: UITextView) {
498:             // TODO: Implement format document functionality
499:             // This would typically call a formatter in EditorCore
500:             print("Format Document: Not yet implemented")


Now I understand the font size update mechanism. Let me check how folding is actually rendered in the UI:

>>>TOOL search
{"query": "collapsedLines", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "collapsedLines"


>>>TOOL search
{"query": "foldRegions", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "foldRegions"


>>>TOOL search
{"query": "CodeFoldingManager", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "CodeFoldingManager"


>>>TOOL search
{"query": "CodeFoldingManager.shared", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "CodeFoldingManager.shared"


>>>TOOL search
{"query": "FoldingManager", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "FoldingManager"


>>>TOOL search
{"query": "handleFold", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "handleFold"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 1, "end_line": 150}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 2-150 of 1057)
────────────────────────────────────────
2: import UIKit
3: import UniformTypeIdentifiers
4: 
5: // MARK: - Helper Functions
6: // Moved to Extensions/FileHelpers.swift
7: 
8: // MARK: - Main Content View
9: 
10: struct ContentView: View {
11:     @EnvironmentObject var editorCore: EditorCore
12:     @StateObject private var fileNavigator = FileSystemNavigator()
13:     @StateObject private var themeManager = ThemeManager.shared
14:     
15:     @State private var showingDocumentPicker = false
16:     @State private var showingFolderPicker = false
17:     @State private var showSettings = false
18:     @State private var showTerminal = false
19:     @State private var terminalHeight: CGFloat = 200
20:     @State private var selectedSidebarTab = 0
21:     @State private var pendingTrustURL: URL?
22:     @State private var windowTitle: String = "VS Code"
23:     
24:     @StateObject private var trustManager = WorkspaceTrustManager.shared
25:     
26:     private var theme: Theme { themeManager.currentTheme }
27:     
28:     var body: some View {
29:         ZStack {
30:             VStack(spacing: 0) {
31:                 HStack(spacing: 0) {
32:                     IDEActivityBar(editorCore: editorCore, selectedTab: $selectedSidebarTab, showSettings: $showSettings, showTerminal: $showTerminal)
33:                     
34:                     if editorCore.showSidebar {
35:                         sidebarContent.frame(width: editorCore.sidebarWidth)
36:                     }
37:                     
38:                     VStack(spacing: 0) {
39:                         IDETabBar(editorCore: editorCore, theme: theme)
40:                         
41:                         if let tab = editorCore.activeTab {
42:                             IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
43:                                 .id(tab.id)  // Force view recreation when tab changes
44:                         } else {
45:                             IDEWelcomeView(editorCore: editorCore, showFolderPicker: $showingFolderPicker, theme: theme)
46:                         }
47:                         
48:                         StatusBarView(editorCore: editorCore)
49:                     }
50:                 }
51:                 
52:                 if showTerminal {
53:                     PanelView(isVisible: $showTerminal, height: $terminalHeight)
54:                 }
55:             }
56:             .background(theme.editorBackground)
57:             
58:             // Overlays - Command Palette (Cmd+Shift+P)
59:             if editorCore.showCommandPalette {
60:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showCommandPalette = false }
61:                 CommandPaletteView(editorCore: editorCore, showSettings: $showSettings, showTerminal: $showTerminal)
62:             }
63:             
64:             // Quick Open (Cmd+P)
65:             if editorCore.showQuickOpen {
66:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showQuickOpen = false }
67:                 QuickOpenView(editorCore: editorCore, fileNavigator: fileNavigator)
68:             }
69:             
70:             // Go To Symbol (Cmd+Shift+O)
71:             if editorCore.showGoToSymbol {
72:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToSymbol = false }
73:                 GoToSymbolView(editorCore: editorCore, onGoToLine: { _ in })
74:             }
75:             
76:             // AI Assistant
77:             if editorCore.showAIAssistant {
78:                 HStack { Spacer(); IDEAIAssistant(editorCore: editorCore, theme: theme).frame(width: 400, height: 500).padding() }
79:             }
80:             
81:             // Go To Line (Ctrl+G)
82:             if editorCore.showGoToLine {
83:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToLine = false }
84:                 GoToLineView(isPresented: $editorCore.showGoToLine, onGoToLine: { _ in })
85:             }
86:             
87:             // Workspace Trust Dialog
88:             if let trustURL = pendingTrustURL {
89:                 Color.black.opacity(0.4).ignoresSafeArea()
90:                 WorkspaceTrustDialog(workspaceURL: trustURL, onTrust: {
91:                     trustManager.trust(url: trustURL)
92:                     finishOpeningWorkspace(trustURL)
93:                     pendingTrustURL = nil
94:                 }, onCancel: {
95:                     pendingTrustURL = nil
96:                 })
97:             }
98:         }
99:         .sheet(isPresented: $showingDocumentPicker) { IDEDocumentPicker(editorCore: editorCore) }
100:         .sheet(isPresented: $showingFolderPicker) {
101:             IDEFolderPicker(fileNavigator: fileNavigator) { url in
102:                 if trustManager.isTrusted(url: url) {
103:                     finishOpeningWorkspace(url)
104:                 } else {
105:                     pendingTrustURL = url
106:                 }
107:             }
108:         }
109:         .sheet(isPresented: $showSettings) { SettingsView(themeManager: themeManager) }
110:         .onChange(of: editorCore.showFilePicker) { show in showingDocumentPicker = show }
111:         .onChange(of: editorCore.activeTab?.fileName) { newFileName in
112:             updateWindowTitle()
113:         }
114:         .onChange(of: editorCore.tabs.count) { _ in
115:             updateWindowTitle()
116:         }
117:         .onAppear {
118:             updateWindowTitle()
119:         }
120:         // MARK: - Notification Handlers for Menu Keyboard Shortcuts
121:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowCommandPalette"))) { _ in
122:             editorCore.showCommandPalette = true
123:         }
124:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleTerminal"))) { _ in
125:             showTerminal.toggle()
126:         }
127:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleSidebar"))) { _ in
128:             editorCore.toggleSidebar()
129:         }
130:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowQuickOpen"))) { _ in
131:             editorCore.showQuickOpen = true
132:         }
133:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToSymbol"))) { _ in
134:             editorCore.showGoToSymbol = true
135:         }
136:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToLine"))) { _ in
137:             editorCore.showGoToLine = true
138:         }
139:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAIAssistant"))) { _ in
140:             editorCore.showAIAssistant = true
141:         }
142:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewFile"))) { _ in
143:             editorCore.addTab()
144:         }
145:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveFile"))) { _ in
146:             editorCore.saveActiveTab()
147:         }
148:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CloseTab"))) { _ in
149:             if let id = editorCore.activeTabId { editorCore.closeTab(id: id) }
150:         }


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 540, "end_line": 550}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 541-550 of 1931)
────────────────────────────────────────
541:             CodeFoldingManager.shared.foldCurrentLine()
542:         }
543:         
544:         func handleUnfold(in textView: UITextView) {
545:             CodeFoldingManager.shared.unfoldCurrentLine()
546:         }
547:         
548:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
549:             guard let textView = gesture.view as? UITextView else { return }
550: 


Let me search for how the folding actually renders/hides lines in the UI:

>>>TOOL search
{"query": "isFolded", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "isFolded"


>>>TOOL search
{"query": "isFolded", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "isFolded"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 1, "end_line": 100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 2-100 of 1057)
────────────────────────────────────────
2: import UIKit
3: import UniformTypeIdentifiers
4: 
5: // MARK: - Helper Functions
6: // Moved to Extensions/FileHelpers.swift
7: 
8: // MARK: - Main Content View
9: 
10: struct ContentView: View {
11:     @EnvironmentObject var editorCore: EditorCore
12:     @StateObject private var fileNavigator = FileSystemNavigator()
13:     @StateObject private var themeManager = ThemeManager.shared
14:     
15:     @State private var showingDocumentPicker = false
16:     @State private var showingFolderPicker = false
17:     @State private var showSettings = false
18:     @State private var showTerminal = false
19:     @State private var terminalHeight: CGFloat = 200
20:     @State private var selectedSidebarTab = 0
21:     @State private var pendingTrustURL: URL?
22:     @State private var windowTitle: String = "VS Code"
23:     
24:     @StateObject private var trustManager = WorkspaceTrustManager.shared
25:     
26:     private var theme: Theme { themeManager.currentTheme }
27:     
28:     var body: some View {
29:         ZStack {
30:             VStack(spacing: 0) {
31:                 HStack(spacing: 0) {
32:                     IDEActivityBar(editorCore: editorCore, selectedTab: $selectedSidebarTab, showSettings: $showSettings, showTerminal: $showTerminal)
33:                     
34:                     if editorCore.showSidebar {
35:                         sidebarContent.frame(width: editorCore.sidebarWidth)
36:                     }
37:                     
38:                     VStack(spacing: 0) {
39:                         IDETabBar(editorCore: editorCore, theme: theme)
40:                         
41:                         if let tab = editorCore.activeTab {
42:                             IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
43:                                 .id(tab.id)  // Force view recreation when tab changes
44:                         } else {
45:                             IDEWelcomeView(editorCore: editorCore, showFolderPicker: $showingFolderPicker, theme: theme)
46:                         }
47:                         
48:                         StatusBarView(editorCore: editorCore)
49:                     }
50:                 }
51:                 
52:                 if showTerminal {
53:                     PanelView(isVisible: $showTerminal, height: $terminalHeight)
54:                 }
55:             }
56:             .background(theme.editorBackground)
57:             
58:             // Overlays - Command Palette (Cmd+Shift+P)
59:             if editorCore.showCommandPalette {
60:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showCommandPalette = false }
61:                 CommandPaletteView(editorCore: editorCore, showSettings: $showSettings, showTerminal: $showTerminal)
62:             }
63:             
64:             // Quick Open (Cmd+P)
65:             if editorCore.showQuickOpen {
66:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showQuickOpen = false }
67:                 QuickOpenView(editorCore: editorCore, fileNavigator: fileNavigator)
68:             }
69:             
70:             // Go To Symbol (Cmd+Shift+O)
71:             if editorCore.showGoToSymbol {
72:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToSymbol = false }
73:                 GoToSymbolView(editorCore: editorCore, onGoToLine: { _ in })
74:             }
75:             
76:             // AI Assistant
77:             if editorCore.showAIAssistant {
78:                 HStack { Spacer(); IDEAIAssistant(editorCore: editorCore, theme: theme).frame(width: 400, height: 500).padding() }
79:             }
80:             
81:             // Go To Line (Ctrl+G)
82:             if editorCore.showGoToLine {
83:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToLine = false }
84:                 GoToLineView(isPresented: $editorCore.showGoToLine, onGoToLine: { _ in })
85:             }
86:             
87:             // Workspace Trust Dialog
88:             if let trustURL = pendingTrustURL {
89:                 Color.black.opacity(0.4).ignoresSafeArea()
90:                 WorkspaceTrustDialog(workspaceURL: trustURL, onTrust: {
91:                     trustManager.trust(url: trustURL)
92:                     finishOpeningWorkspace(trustURL)
93:                     pendingTrustURL = nil
94:                 }, onCancel: {
95:                     pendingTrustURL = nil
96:                 })
97:             }
98:         }
99:         .sheet(isPresented: $showingDocumentPicker) { IDEDocumentPicker(editorCore: editorCore) }
100:         .sheet(isPresented: $showingFolderPicker) {


---

## 💬 USER MESSAGE

keep working

---


>>>TOOL search
{"query": "toggleFold", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "toggleFold"


>>>TOOL search
{"query": "foldCurrentLine", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "foldCurrentLine"


>>>TOOL search
{"query": "LineNumberView", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "LineNumberView"


>>>TOOL search
{"query": "FoldRegion", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "FoldRegion"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 200, "end_line": 400}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 201-400 of 1057)
────────────────────────────────────────
201:             DebugView()
202:         default:
203:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
204:         }
205:     }
206: }
207: 
208: // MARK: - Activity Bar
209: 
210: 
211: 
212: struct BarButton: View {
213:     let icon: String
214:     let isSelected: Bool
215:     let theme: Theme
216:     let action: () -> Void
217:     
218:     var body: some View {
219:         Button(action: action) {
220:             Image(systemName: icon)
221:                 .font(.system(size: 22))
222:                 .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
223:                 .frame(width: 48, height: 48)
224:         }
225:     }
226: }
227: 
228: // MARK: - Sidebar with Real File System
229: 
230: struct IDESidebarFiles: View {
231:     @ObservedObject var editorCore: EditorCore
232:     @ObservedObject var fileNavigator: FileSystemNavigator
233:     @Binding var showFolderPicker: Bool
234:     let theme: Theme
235:     
236:     var body: some View {
237:         VStack(alignment: .leading, spacing: 0) {
238:             HStack {
239:                 Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
240:                 Spacer()
241:                 Button(action: { showFolderPicker = true }) {
242:                     Image(systemName: "folder.badge.plus").font(.caption)
243:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
244:                 Button(action: { editorCore.showFilePicker = true }) {
245:                     Image(systemName: "doc.badge.plus").font(.caption)
246:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
247:                 if fileNavigator.fileTree != nil {
248:                     Button(action: { fileNavigator.refreshFileTree() }) {
249:                         Image(systemName: "arrow.clockwise").font(.caption)
250:                     }.foregroundColor(theme.sidebarForeground.opacity(0.7))
251:                 }
252:             }.padding(.horizontal, 12).padding(.vertical, 8)
253:             
254:             ScrollView {
255:                 VStack(alignment: .leading, spacing: 2) {
256:                     if let tree = fileNavigator.fileTree {
257:                         FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
258:                     } else {
259:                         DemoFileTree(editorCore: editorCore, theme: theme)
260:                     }
261:                 }.padding(.horizontal, 8)
262:             }
263:         }.background(theme.sidebarBackground)
264:     }
265: }
266: 
267: struct RealFileTreeView: View {
268:     let node: FileTreeNode
269:     let level: Int
270:     @ObservedObject var fileNavigator: FileSystemNavigator
271:     @ObservedObject var editorCore: EditorCore
272:     let theme: Theme
273:     
274:     var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
275:     
276:     var body: some View {
277:         VStack(alignment: .leading, spacing: 2) {
278:             HStack(spacing: 4) {
279:                 if node.isDirectory {
280:                     Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
281:                         .font(.caption2).frame(width: 12)
282:                         .foregroundColor(theme.sidebarForeground.opacity(0.6))
283:                         .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
284:                 } else {
285:                     Spacer().frame(width: 12)
286:                 }
287:                 Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
288:                     .font(.caption)
289:                     .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
290:                 Text(node.name).font(.system(.caption)).lineLimit(1)
291:                     .foregroundColor(theme.sidebarForeground)
292:                 Spacer()
293:             }
294:             .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
295:             .contentShape(Rectangle())
296:             .onTapGesture {
297:                 if node.isDirectory {
298:                     fileNavigator.toggleExpanded(path: node.url.path)
299:                 } else {
300:                     editorCore.openFile(from: node.url)
301:                 }
302:             }
303:             
304:             if isExpanded && node.isDirectory {
305:                 ForEach(node.children) { child in
306:                     RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
307:                 }
308:             }
309:         }
310:     }
311: }
312: 
313: struct DemoFileTree: View {
314:     @ObservedObject var editorCore: EditorCore
315:     let theme: Theme
316:     
317:     var body: some View {
318:         VStack(alignment: .leading, spacing: 4) {
319:             Text("Open a folder to browse files")
320:                 .font(.caption)
321:                 .foregroundColor(theme.sidebarForeground.opacity(0.6))
322:                 .padding(.vertical, 8)
323:             
324:             DemoFileRow(name: "main.swift", editorCore: editorCore, theme: theme)
325:             DemoFileRow(name: "ContentView.swift", editorCore: editorCore, theme: theme)
326:             DemoFileRow(name: "README.md", editorCore: editorCore, theme: theme)
327:         }
328:     }
329: }
330: 
331: struct DemoFileRow: View {
332:     let name: String
333:     @ObservedObject var editorCore: EditorCore
334:     let theme: Theme
335:     
336:     var body: some View {
337:         HStack(spacing: 4) {
338:             Spacer().frame(width: 12)
339:             Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
340:             Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
341:             Spacer()
342:         }
343:         .padding(.vertical, 4)
344:         .contentShape(Rectangle())
345:         .onTapGesture {
346:             editorCore.addTab(fileName: name, content: "// \(name)\n\n")
347:         }
348:     }
349: }
350: 
351: // MARK: - Tab Bar
352: 
353: struct IDETabBar: View {
354:     @ObservedObject var editorCore: EditorCore
355:     let theme: Theme
356:     
357:     var body: some View {
358:         ScrollView(.horizontal, showsIndicators: false) {
359:             HStack(spacing: 0) {
360:                 ForEach(editorCore.tabs) { tab in
361:                     IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
362:                 }
363:                 Button(action: { editorCore.addTab() }) {
364:                     Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
365:                 }
366:             }.padding(.horizontal, 4)
367:         }.frame(height: 36).background(theme.tabBarBackground)
368:     }
369: }
370: 
371: struct IDETabItem: View {
372:     let tab: Tab
373:     let isSelected: Bool
374:     @ObservedObject var editorCore: EditorCore
375:     let theme: Theme
376:     
377:     var body: some View {
378:         HStack(spacing: 6) {
379:             Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
380:             Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
381:                 .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
382:             if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
383:             Button(action: { editorCore.closeTab(id: tab.id) }) {
384:                 Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
385:                     .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
386:             }
387:         }
388:         .padding(.horizontal, 12).padding(.vertical, 6)
389:         .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
390:         .onTapGesture { editorCore.selectTab(id: tab.id) }
391:     }
392: }
393: 
394: // MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
395: 
396: struct IDEEditorView: View {
397:     @ObservedObject var editorCore: EditorCore
398:     let tab: Tab
399:     let theme: Theme
400: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 394, "end_line": 600}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 395-600 of 1057)
────────────────────────────────────────
395: 
396: struct IDEEditorView: View {
397:     @ObservedObject var editorCore: EditorCore
398:     let tab: Tab
399:     let theme: Theme
400: 
401:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
402:     @State private var text: String = ""
403:     @State private var scrollPosition: Int = 0
404:     @State private var totalLines: Int = 1
405:     @State private var visibleLines: Int = 20
406:     @State private var currentLineNumber: Int = 1
407:     @State private var currentColumn: Int = 1
408:     @State private var cursorIndex: Int = 0
409:     @State private var lineHeight: CGFloat = 17
410:     @State private var requestedCursorIndex: Int? = nil
411:     @State private var requestedLineSelection: Int? = nil
412: 
413:     @StateObject private var autocomplete = AutocompleteManager()
414:     @State private var showAutocomplete = false
415:     @StateObject private var foldingManager = CodeFoldingManager()
416:     @StateObject private var findViewModel = FindViewModel()
417:     
418:     var body: some View {
419:         VStack(spacing: 0) {
420:             // Find/Replace bar
421:             if editorCore.showSearch {
422:                 FindReplaceView(viewModel: findViewModel)
423:                     .background(theme.tabBarBackground)
424:             }
425:             
426:             BreadcrumbsView(editorCore: editorCore, tab: tab)
427:             
428:             GeometryReader { geometry in
429:                 ZStack(alignment: .topLeading) {
430:                 HStack(spacing: 0) {
431:                     if lineNumbersStyle != "off" {
432:                         LineNumbersWithFolding(
433:                             fileId: tab.url?.path ?? tab.fileName,
434:                             totalLines: totalLines,
435:                             currentLine: currentLineNumber,
436:                             scrollOffset: CGFloat(scrollPosition) * lineHeight,
437:                             lineHeight: lineHeight,
438:                             requestedLineSelection: $requestedLineSelection,
439:                             foldingManager: foldingManager,
440:                             theme: theme
441:                         )
442:                         .frame(width: 60)
443:                         .background(theme.sidebarBackground.opacity(0.5))
444:                     }
445:                     
446:                     if tab.fileName.hasSuffix(".json") {
447:                         // JSON Tree View for .json files
448:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
449:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
450:                             .background(theme.editorBackground)
451:                     } else {
452:                         SyntaxHighlightingTextView(
453:                             text: $text,
454:                             filename: tab.fileName,
455:                             scrollPosition: $scrollPosition,
456:                             totalLines: $totalLines,
457:                             visibleLines: $visibleLines,
458:                             currentLineNumber: $currentLineNumber,
459:                             currentColumn: $currentColumn,
460:                             cursorIndex: $cursorIndex,
461:                             lineHeight: $lineHeight,
462:                             isActive: true,
463:                             requestedLineSelection: $requestedLineSelection,
464:                             requestedCursorIndex: $requestedCursorIndex,
465:                             onAcceptAutocomplete: {
466:                                 guard showAutocomplete else { return false }
467:                                 var tempText = text
468:                                 var tempCursor = cursorIndex
469:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
470:                                 if tempText != text {
471:                                     text = tempText
472:                                     cursorIndex = tempCursor
473:                                     requestedCursorIndex = tempCursor
474:                                     showAutocomplete = false
475:                                     return true
476:                                 }
477:                                 return false
478:                             },
479:                             onDismissAutocomplete: {
480:                                 guard showAutocomplete else { return false }
481:                                 autocomplete.hideSuggestions()
482:                                 showAutocomplete = false
483:                                 return true
484:                             }
485:                         )
486:                         .onChange(of: text) { newValue in
487:                             editorCore.updateActiveTabContent(newValue)
488:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
489:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
490:                             showAutocomplete = autocomplete.showSuggestions
491:                             foldingManager.detectFoldableRegions(in: newValue)
492:                         }
493:                         .onChange(of: cursorIndex) { newCursor in
494:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
495:                             showAutocomplete = autocomplete.showSuggestions
496:                         }
497:                     }
498:                     
499:                     if !tab.fileName.hasSuffix(".json") {
500:                         MinimapView(
501:                             content: text,
502:                             scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
503:                             scrollViewHeight: .constant(geometry.size.height),
504:                             totalContentHeight: CGFloat(totalLines) * lineHeight
505:                         )
506:                         .frame(width: 80)
507:                     }
508:                 }
509:                 .background(theme.editorBackground)
510: 
511:                 // Sticky Header Overlay (FEAT-040)
512:                 StickyHeaderView(
513:                     text: text,
514:                     currentLine: scrollPosition,
515:                     theme: theme,
516:                     lineHeight: lineHeight,
517:                     onSelect: { line in
518:                         requestedLineSelection = line
519:                     }
520:                 )
521:                 .padding(.leading, lineNumbersStyle != "off" ? 60 : 0)
522:                 .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
523: 
524:                 if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
525:                     AutocompletePopup(
526:                         suggestions: autocomplete.suggestionItems,
527:                         selectedIndex: autocomplete.selectedIndex,
528:                         theme: theme
529:                     ) { index in
530:                         autocomplete.selectedIndex = index
531:                         var tempText = text
532:                         var tempCursor = cursorIndex
533:                         autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
534:                         if tempText != text {
535:                             text = tempText
536:                             cursorIndex = tempCursor
537:                             requestedCursorIndex = tempCursor
538:                         }
539:                         showAutocomplete = false
540:                     }
541:                     .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
542:                 }
543:             }
544:         }
545:         }
546:         .onAppear {
547:             text = tab.content
548:             foldingManager.detectFoldableRegions(in: text)
549:         }
550:         .onChange(of: tab.id) { _ in
551:             text = tab.content
552:             foldingManager.detectFoldableRegions(in: text)
553:         }
554:         .onChange(of: currentLineNumber) { line in
555:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
556:         }
557:         .onChange(of: currentColumn) { col in
558:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
559:         }
560:         .onAppear {
561:             findViewModel.editorCore = editorCore
562:         }
563:     }
564:     
565:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
566: }
567: 
568: // MARK: - Line Numbers with Folding
569: 
570: struct LineNumbersWithFolding: View {
571:     let fileId: String
572:     let totalLines: Int
573:     let currentLine: Int
574:     let scrollOffset: CGFloat
575:     let lineHeight: CGFloat
576:     @Binding var requestedLineSelection: Int?
577:     @ObservedObject var foldingManager: CodeFoldingManager
578:     @ObservedObject private var debugManager = DebugManager.shared
579:     let theme: Theme
580: 
581:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
582: 
583:     var body: some View {
584:         ScrollView(showsIndicators: false) {
585:             VStack(alignment: .trailing, spacing: 0) {
586:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
587:                     if !foldingManager.isLineFolded(line: lineIndex) {
588:                         HStack(spacing: 2) {
589:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
590:                                 Circle()
591:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
592:                                     .overlay(
593:                                         Circle()
594:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
595:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
596:                                     )
597:                                     .frame(width: 10, height: 10)
598:                                     .padding(.leading, 2)
599:                             }
600:                             .buttonStyle(.plain)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 600, "end_line": 750}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 601-750 of 1057)
────────────────────────────────────────
601:                             .frame(width: 14, height: lineHeight)
602: 
603:                             if foldingManager.isFoldable(line: lineIndex) {
604:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
605:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
606:                                         .font(.system(size: 8))
607:                                         .foregroundColor(theme.lineNumber)
608:                                 }
609:                                 .buttonStyle(.plain)
610:                                 .frame(width: 14, height: lineHeight)
611:                             } else {
612:                                 Spacer().frame(width: 14)
613:                             }
614: 
615:                             Text(displayText(for: lineIndex))
616:                                 .font(.system(size: 12, design: .monospaced))
617:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
618:                                 .frame(height: lineHeight)
619:                                 .contentShape(Rectangle())
620:                                 .onTapGesture {
621:                                     // FEAT-041: click line number selects entire line
622:                                     requestedLineSelection = lineIndex
623:                                 }
624:                         }
625:                         .frame(maxWidth: .infinity, alignment: .trailing)
626:                         .padding(.trailing, 4)
627:                     }
628:                 }
629:             }
630:             .offset(y: -scrollOffset)
631:         }
632:     }
633: 
634:     private func displayText(for lineIndex: Int) -> String {
635:         switch lineNumbersStyle {
636:         case "relative":
637:             // VS Code-style: current line shows absolute, others show relative distance
638:             let lineNumber = lineIndex + 1
639:             if lineNumber == currentLine { return "\(lineNumber)" }
640:             return "\(abs(lineNumber - currentLine))"
641: 
642:         case "interval":
643:             let lineNumber = lineIndex + 1
644:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
645: 
646:         default:
647:             return "\(lineIndex + 1)"
648:         }
649:     }
650: }
651: 
652: // MARK: - Autocomplete Popup
653: 
654: struct AutocompletePopup: View {
655:     let suggestions: [AutocompleteSuggestion]
656:     let selectedIndex: Int
657:     let theme: Theme
658:     let onSelectIndex: (Int) -> Void
659:     
660:     var body: some View {
661:         VStack(alignment: .leading, spacing: 0) {
662:             ForEach(suggestions.indices, id: \.self) { index in
663:                 let s = suggestions[index]
664:                 HStack(spacing: 6) {
665:                     Image(systemName: icon(for: s.kind))
666:                         .font(.caption)
667:                         .foregroundColor(color(for: s.kind))
668:                     VStack(alignment: .leading, spacing: 1) {
669:                         Text(s.displayText)
670:                             .font(.system(size: 12, design: .monospaced))
671:                             .foregroundColor(theme.editorForeground)
672:                         if s.insertText != s.displayText && !s.insertText.isEmpty {
673:                             Text(s.insertText)
674:                                 .font(.system(size: 10, design: .monospaced))
675:                                 .foregroundColor(theme.editorForeground.opacity(0.55))
676:                                 .lineLimit(1)
677:                         }
678:                     }
679:                     Spacer()
680:                 }
681:                 .padding(.horizontal, 8).padding(.vertical, 6)
682:                 .background(index == selectedIndex ? theme.selection : Color.clear)
683:                 .contentShape(Rectangle())
684:                 .onTapGesture { onSelectIndex(index) }
685:             }
686:         }
687:         .frame(width: 260)
688:         .background(theme.editorBackground)
689:         .cornerRadius(6)
690:         .shadow(radius: 8)
691:     }
692:     
693:     private func icon(for kind: AutocompleteSuggestionKind) -> String {
694:         switch kind {
695:         case .keyword: return "key.fill"
696:         case .symbol: return "cube.fill"
697:         case .stdlib: return "curlybraces"
698:         case .member: return "arrow.right.circle.fill"
699:         }
700:     }
701:     
702:     private func color(for kind: AutocompleteSuggestionKind) -> Color {
703:         switch kind {
704:         case .keyword: return .purple
705:         case .symbol: return .blue
706:         case .stdlib: return .orange
707:         case .member: return .green
708:         }
709:     }
710: }
711: 
712: // MARK: - Welcome View
713: 
714: struct IDEWelcomeView: View {
715:     @ObservedObject var editorCore: EditorCore
716:     @Binding var showFolderPicker: Bool
717:     let theme: Theme
718:     
719:     var body: some View {
720:         VStack(spacing: 24) {
721:             Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 80)).foregroundColor(theme.editorForeground.opacity(0.3))
722:             Text("VS Code for iPadOS").font(.largeTitle).fontWeight(.bold).foregroundColor(theme.editorForeground)
723:             VStack(alignment: .leading, spacing: 12) {
724:                 WelcomeBtn(icon: "doc.badge.plus", title: "New File", shortcut: "⌘N", theme: theme) { editorCore.addTab() }
725:                 WelcomeBtn(icon: "folder", title: "Open Folder", shortcut: "⌘⇧O", theme: theme) { showFolderPicker = true }
726:                 WelcomeBtn(icon: "doc", title: "Open File", shortcut: "⌘O", theme: theme) { editorCore.showFilePicker = true }
727:                 WelcomeBtn(icon: "terminal", title: "Command Palette", shortcut: "⌘⇧P", theme: theme) { editorCore.showCommandPalette = true }
728:             }
729:         }.frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.editorBackground)
730:     }
731: }
732: 
733: struct WelcomeBtn: View {
734:     let icon: String
735:     let title: String
736:     let shortcut: String
737:     let theme: Theme
738:     let action: () -> Void
739:     
740:     var body: some View {
741:         Button(action: action) {
742:             HStack {
743:                 Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
744:                 Text(title).foregroundColor(theme.editorForeground)
745:                 Spacer()
746:                 Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
747:             }
748:             .padding().frame(width: 280)
749:             .background(theme.sidebarBackground)
750:             .cornerRadius(8)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 394, "end_line": 600}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 395-600 of 1057)
────────────────────────────────────────
395: 
396: struct IDEEditorView: View {
397:     @ObservedObject var editorCore: EditorCore
398:     let tab: Tab
399:     let theme: Theme
400: 
401:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
402:     @State private var text: String = ""
403:     @State private var scrollPosition: Int = 0
404:     @State private var totalLines: Int = 1
405:     @State private var visibleLines: Int = 20
406:     @State private var currentLineNumber: Int = 1
407:     @State private var currentColumn: Int = 1
408:     @State private var cursorIndex: Int = 0
409:     @State private var lineHeight: CGFloat = 17
410:     @State private var requestedCursorIndex: Int? = nil
411:     @State private var requestedLineSelection: Int? = nil
412: 
413:     @StateObject private var autocomplete = AutocompleteManager()
414:     @State private var showAutocomplete = false
415:     @StateObject private var foldingManager = CodeFoldingManager()
416:     @StateObject private var findViewModel = FindViewModel()
417:     
418:     var body: some View {
419:         VStack(spacing: 0) {
420:             // Find/Replace bar
421:             if editorCore.showSearch {
422:                 FindReplaceView(viewModel: findViewModel)
423:                     .background(theme.tabBarBackground)
424:             }
425:             
426:             BreadcrumbsView(editorCore: editorCore, tab: tab)
427:             
428:             GeometryReader { geometry in
429:                 ZStack(alignment: .topLeading) {
430:                 HStack(spacing: 0) {
431:                     if lineNumbersStyle != "off" {
432:                         LineNumbersWithFolding(
433:                             fileId: tab.url?.path ?? tab.fileName,
434:                             totalLines: totalLines,
435:                             currentLine: currentLineNumber,
436:                             scrollOffset: CGFloat(scrollPosition) * lineHeight,
437:                             lineHeight: lineHeight,
438:                             requestedLineSelection: $requestedLineSelection,
439:                             foldingManager: foldingManager,
440:                             theme: theme
441:                         )
442:                         .frame(width: 60)
443:                         .background(theme.sidebarBackground.opacity(0.5))
444:                     }
445:                     
446:                     if tab.fileName.hasSuffix(".json") {
447:                         // JSON Tree View for .json files
448:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
449:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
450:                             .background(theme.editorBackground)
451:                     } else {
452:                         SyntaxHighlightingTextView(
453:                             text: $text,
454:                             filename: tab.fileName,
455:                             scrollPosition: $scrollPosition,
456:                             totalLines: $totalLines,
457:                             visibleLines: $visibleLines,
458:                             currentLineNumber: $currentLineNumber,
459:                             currentColumn: $currentColumn,
460:                             cursorIndex: $cursorIndex,
461:                             lineHeight: $lineHeight,
462:                             isActive: true,
463:                             requestedLineSelection: $requestedLineSelection,
464:                             requestedCursorIndex: $requestedCursorIndex,
465:                             onAcceptAutocomplete: {
466:                                 guard showAutocomplete else { return false }
467:                                 var tempText = text
468:                                 var tempCursor = cursorIndex
469:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
470:                                 if tempText != text {
471:                                     text = tempText
472:                                     cursorIndex = tempCursor
473:                                     requestedCursorIndex = tempCursor
474:                                     showAutocomplete = false
475:                                     return true
476:                                 }
477:                                 return false
478:                             },
479:                             onDismissAutocomplete: {
480:                                 guard showAutocomplete else { return false }
481:                                 autocomplete.hideSuggestions()
482:                                 showAutocomplete = false
483:                                 return true
484:                             }
485:                         )
486:                         .onChange(of: text) { newValue in
487:                             editorCore.updateActiveTabContent(newValue)
488:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
489:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
490:                             showAutocomplete = autocomplete.showSuggestions
491:                             foldingManager.detectFoldableRegions(in: newValue)
492:                         }
493:                         .onChange(of: cursorIndex) { newCursor in
494:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
495:                             showAutocomplete = autocomplete.showSuggestions
496:                         }
497:                     }
498:                     
499:                     if !tab.fileName.hasSuffix(".json") {
500:                         MinimapView(
501:                             content: text,
502:                             scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
503:                             scrollViewHeight: .constant(geometry.size.height),
504:                             totalContentHeight: CGFloat(totalLines) * lineHeight
505:                         )
506:                         .frame(width: 80)
507:                     }
508:                 }
509:                 .background(theme.editorBackground)
510: 
511:                 // Sticky Header Overlay (FEAT-040)
512:                 StickyHeaderView(
513:                     text: text,
514:                     currentLine: scrollPosition,
515:                     theme: theme,
516:                     lineHeight: lineHeight,
517:                     onSelect: { line in
518:                         requestedLineSelection = line
519:                     }
520:                 )
521:                 .padding(.leading, lineNumbersStyle != "off" ? 60 : 0)
522:                 .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
523: 
524:                 if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
525:                     AutocompletePopup(
526:                         suggestions: autocomplete.suggestionItems,
527:                         selectedIndex: autocomplete.selectedIndex,
528:                         theme: theme
529:                     ) { index in
530:                         autocomplete.selectedIndex = index
531:                         var tempText = text
532:                         var tempCursor = cursorIndex
533:                         autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
534:                         if tempText != text {
535:                             text = tempText
536:                             cursorIndex = tempCursor
537:                             requestedCursorIndex = tempCursor
538:                         }
539:                         showAutocomplete = false
540:                     }
541:                     .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
542:                 }
543:             }
544:         }
545:         }
546:         .onAppear {
547:             text = tab.content
548:             foldingManager.detectFoldableRegions(in: text)
549:         }
550:         .onChange(of: tab.id) { _ in
551:             text = tab.content
552:             foldingManager.detectFoldableRegions(in: text)
553:         }
554:         .onChange(of: currentLineNumber) { line in
555:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
556:         }
557:         .onChange(of: currentColumn) { col in
558:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
559:         }
560:         .onAppear {
561:             findViewModel.editorCore = editorCore
562:         }
563:     }
564:     
565:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
566: }
567: 
568: // MARK: - Line Numbers with Folding
569: 
570: struct LineNumbersWithFolding: View {
571:     let fileId: String
572:     let totalLines: Int
573:     let currentLine: Int
574:     let scrollOffset: CGFloat
575:     let lineHeight: CGFloat
576:     @Binding var requestedLineSelection: Int?
577:     @ObservedObject var foldingManager: CodeFoldingManager
578:     @ObservedObject private var debugManager = DebugManager.shared
579:     let theme: Theme
580: 
581:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
582: 
583:     var body: some View {
584:         ScrollView(showsIndicators: false) {
585:             VStack(alignment: .trailing, spacing: 0) {
586:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
587:                     if !foldingManager.isLineFolded(line: lineIndex) {
588:                         HStack(spacing: 2) {
589:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
590:                                 Circle()
591:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
592:                                     .overlay(
593:                                         Circle()
594:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
595:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
596:                                     )
597:                                     .frame(width: 10, height: 10)
598:                                     .padding(.leading, 2)
599:                             }
600:                             .buttonStyle(.plain)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 600, "end_line": 700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 601-700 of 1057)
────────────────────────────────────────
601:                             .frame(width: 14, height: lineHeight)
602: 
603:                             if foldingManager.isFoldable(line: lineIndex) {
604:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
605:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
606:                                         .font(.system(size: 8))
607:                                         .foregroundColor(theme.lineNumber)
608:                                 }
609:                                 .buttonStyle(.plain)
610:                                 .frame(width: 14, height: lineHeight)
611:                             } else {
612:                                 Spacer().frame(width: 14)
613:                             }
614: 
615:                             Text(displayText(for: lineIndex))
616:                                 .font(.system(size: 12, design: .monospaced))
617:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
618:                                 .frame(height: lineHeight)
619:                                 .contentShape(Rectangle())
620:                                 .onTapGesture {
621:                                     // FEAT-041: click line number selects entire line
622:                                     requestedLineSelection = lineIndex
623:                                 }
624:                         }
625:                         .frame(maxWidth: .infinity, alignment: .trailing)
626:                         .padding(.trailing, 4)
627:                     }
628:                 }
629:             }
630:             .offset(y: -scrollOffset)
631:         }
632:     }
633: 
634:     private func displayText(for lineIndex: Int) -> String {
635:         switch lineNumbersStyle {
636:         case "relative":
637:             // VS Code-style: current line shows absolute, others show relative distance
638:             let lineNumber = lineIndex + 1
639:             if lineNumber == currentLine { return "\(lineNumber)" }
640:             return "\(abs(lineNumber - currentLine))"
641: 
642:         case "interval":
643:             let lineNumber = lineIndex + 1
644:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
645: 
646:         default:
647:             return "\(lineIndex + 1)"
648:         }
649:     }
650: }
651: 
652: // MARK: - Autocomplete Popup
653: 
654: struct AutocompletePopup: View {
655:     let suggestions: [AutocompleteSuggestion]
656:     let selectedIndex: Int
657:     let theme: Theme
658:     let onSelectIndex: (Int) -> Void
659:     
660:     var body: some View {
661:         VStack(alignment: .leading, spacing: 0) {
662:             ForEach(suggestions.indices, id: \.self) { index in
663:                 let s = suggestions[index]
664:                 HStack(spacing: 6) {
665:                     Image(systemName: icon(for: s.kind))
666:                         .font(.caption)
667:                         .foregroundColor(color(for: s.kind))
668:                     VStack(alignment: .leading, spacing: 1) {
669:                         Text(s.displayText)
670:                             .font(.system(size: 12, design: .monospaced))
671:                             .foregroundColor(theme.editorForeground)
672:                         if s.insertText != s.displayText && !s.insertText.isEmpty {
673:                             Text(s.insertText)
674:                                 .font(.system(size: 10, design: .monospaced))
675:                                 .foregroundColor(theme.editorForeground.opacity(0.55))
676:                                 .lineLimit(1)
677:                         }
678:                     }
679:                     Spacer()
680:                 }
681:                 .padding(.horizontal, 8).padding(.vertical, 6)
682:                 .background(index == selectedIndex ? theme.selection : Color.clear)
683:                 .contentShape(Rectangle())
684:                 .onTapGesture { onSelectIndex(index) }
685:             }
686:         }
687:         .frame(width: 260)
688:         .background(theme.editorBackground)
689:         .cornerRadius(6)
690:         .shadow(radius: 8)
691:     }
692:     
693:     private func icon(for kind: AutocompleteSuggestionKind) -> String {
694:         switch kind {
695:         case .keyword: return "key.fill"
696:         case .symbol: return "cube.fill"
697:         case .stdlib: return "curlybraces"
698:         case .member: return "arrow.right.circle.fill"
699:         }
700:     }


Now I have a clear picture. Let me verify one more thing about how the text view handles folded lines:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 450, "end_line": 500}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 451-500 of 1057)
────────────────────────────────────────
451:                     } else {
452:                         SyntaxHighlightingTextView(
453:                             text: $text,
454:                             filename: tab.fileName,
455:                             scrollPosition: $scrollPosition,
456:                             totalLines: $totalLines,
457:                             visibleLines: $visibleLines,
458:                             currentLineNumber: $currentLineNumber,
459:                             currentColumn: $currentColumn,
460:                             cursorIndex: $cursorIndex,
461:                             lineHeight: $lineHeight,
462:                             isActive: true,
463:                             requestedLineSelection: $requestedLineSelection,
464:                             requestedCursorIndex: $requestedCursorIndex,
465:                             onAcceptAutocomplete: {
466:                                 guard showAutocomplete else { return false }
467:                                 var tempText = text
468:                                 var tempCursor = cursorIndex
469:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
470:                                 if tempText != text {
471:                                     text = tempText
472:                                     cursorIndex = tempCursor
473:                                     requestedCursorIndex = tempCursor
474:                                     showAutocomplete = false
475:                                     return true
476:                                 }
477:                                 return false
478:                             },
479:                             onDismissAutocomplete: {
480:                                 guard showAutocomplete else { return false }
481:                                 autocomplete.hideSuggestions()
482:                                 showAutocomplete = false
483:                                 return true
484:                             }
485:                         )
486:                         .onChange(of: text) { newValue in
487:                             editorCore.updateActiveTabContent(newValue)
488:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
489:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
490:                             showAutocomplete = autocomplete.showSuggestions
491:                             foldingManager.detectFoldableRegions(in: newValue)
492:                         }
493:                         .onChange(of: cursorIndex) { newCursor in
494:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
495:                             showAutocomplete = autocomplete.showSuggestions
496:                         }
497:                     }
498:                     
499:                     if !tab.fileName.hasSuffix(".json") {
500:                         MinimapView(


Now I understand the structure. Let me trace how the font size is supposed to flow to the text view and verify the issue:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1, "end_line": 100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-100 of 1931)
────────────────────────────────────────
2: //  SyntaxHighlightingTextView.swift
3: //  VSCodeiPadOS
4: //
5: //  Upgraded syntax highlighting with VSCode-like colors
6: //
7: 
8: import SwiftUI
9: import UIKit
10: 
11: /// UITextView wrapper with syntax highlighting support
12: struct SyntaxHighlightingTextView: UIViewRepresentable {
13:     @Binding var text: String
14:     let filename: String
15:     @Binding var scrollPosition: Int
16:     @Binding var totalLines: Int
17:     @Binding var visibleLines: Int
18:     @Binding var currentLineNumber: Int
19:     @Binding var currentColumn: Int
20:     @Binding var cursorIndex: Int
21:     @Binding var lineHeight: CGFloat
22:     @Binding var requestedLineSelection: Int?
23:     @Binding var requestedCursorIndex: Int?
24: 
25:     /// Autocomplete key handling hooks (return true if handled)
26:     let onAcceptAutocomplete: (() -> Bool)?
27:     let onDismissAutocomplete: (() -> Bool)?
28: 
29:     let isActive: Bool
30:     @EnvironmentObject var editorCore: EditorCore
31: 
32:     init(
33:         text: Binding<String>,
34:         filename: String,
35:         scrollPosition: Binding<Int>,
36:         totalLines: Binding<Int>,
37:         visibleLines: Binding<Int>,
38:         currentLineNumber: Binding<Int>,
39:         currentColumn: Binding<Int>,
40:         cursorIndex: Binding<Int> = .constant(0),
41:         lineHeight: Binding<CGFloat>,
42:         isActive: Bool,
43:         requestedLineSelection: Binding<Int?> = .constant(nil),
44:         requestedCursorIndex: Binding<Int?> = .constant(nil),
45:         onAcceptAutocomplete: (() -> Bool)? = nil,
46:         onDismissAutocomplete: (() -> Bool)? = nil
47:     ) {
48:         self._text = text
49:         self.filename = filename
50:         self._scrollPosition = scrollPosition
51:         self._totalLines = totalLines
52:         self._visibleLines = visibleLines
53:         self._currentLineNumber = currentLineNumber
54:         self._currentColumn = currentColumn
55:         self._cursorIndex = cursorIndex
56:         self._lineHeight = lineHeight
57:         self.isActive = isActive
58:         self._requestedLineSelection = requestedLineSelection
59:         self._requestedCursorIndex = requestedCursorIndex
60:         self.onAcceptAutocomplete = onAcceptAutocomplete
61:         self.onDismissAutocomplete = onDismissAutocomplete
62:     }
63:     
64:     // Compatibility init for older call sites (e.g. SplitEditorView) that pass editorCore explicitly.
65:     init(
66:         text: Binding<String>,
67:         filename: String,
68:         scrollPosition: Binding<Int>,
69:         totalLines: Binding<Int>,
70:         visibleLines: Binding<Int>,
71:         currentLineNumber: Binding<Int>,
72:         currentColumn: Binding<Int>,
73:         cursorIndex: Binding<Int> = .constant(0),
74:         lineHeight: Binding<CGFloat>,
75:         isActive: Bool,
76:         editorCore: EditorCore,
77:         requestedLineSelection: Binding<Int?> = .constant(nil),
78:         requestedCursorIndex: Binding<Int?> = .constant(nil),
79:         onAcceptAutocomplete: (() -> Bool)? = nil,
80:         onDismissAutocomplete: (() -> Bool)? = nil
81:     ) {
82:         self.init(
83:             text: text,
84:             filename: filename,
85:             scrollPosition: scrollPosition,
86:             totalLines: totalLines,
87:             visibleLines: visibleLines,
88:             currentLineNumber: currentLineNumber,
89:             currentColumn: currentColumn,
90:             cursorIndex: cursorIndex,
91:             lineHeight: lineHeight,
92:             isActive: isActive,
93:             requestedLineSelection: requestedLineSelection,
94:             requestedCursorIndex: requestedCursorIndex,
95:             onAcceptAutocomplete: onAcceptAutocomplete,
96:             onDismissAutocomplete: onDismissAutocomplete
97:         )
98:     }
99: 
100:     func makeCoordinator() -> Coordinator {


Now I have enough information to identify both bugs. Let me verify one more thing about how the folding calls work:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 538, "end_line": 550}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 539-550 of 1931)
────────────────────────────────────────
539:         
540:         func handleFold(in textView: UITextView) {
541:             CodeFoldingManager.shared.foldCurrentLine()
542:         }
543:         
544:         func handleUnfold(in textView: UITextView) {
545:             CodeFoldingManager.shared.unfoldCurrentLine()
546:         }
547:         
548:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
549:             guard let textView = gesture.view as? UITextView else { return }
550: 


Now I have enough information to understand both bugs. Let me write my report.

>>>REPORT
## Bug Analysis Summary

### Bug 1: Font Size Not Changing When Using Zoom Commands

**Root Cause:** The `SyntaxHighlightingTextView` uses `@EnvironmentObject var editorCore: EditorCore` (line 30 of SyntaxHighlightingTextView.swift) to access `editorFontSize`. While the `updateUIView` method has correct logic to detect and update the font (lines 200-213), SwiftUI may not properly trigger `updateUIView` when only a `@Published` property on the environment object changes.

**Location:** 
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift` lines 30, 200-213

**Evidence:** The font size update code is correct:
```swift
// Line 200-203
if let currentFont = textView.font, currentFont.pointSize != editorCore.editorFontSize {
    let selectedRange = textView.selectedRange
    textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
```

But since `SyntaxHighlightingTextView` is a `UIViewRepresentable` without a `body`, SwiftUI may not detect the dependency on `editorCore.editorFontSize`.

**Fix:** Pass `editorFontSize` as an explicit parameter to `SyntaxHighlightingTextView` (e.g., `let fontSize: CGFloat`) instead of relying solely on the EnvironmentObject. This forces SwiftUI to re-render when the value changes.

---

### Bug 2: Folding Doesn't Work - Moves to Top of Screen

**Root Cause:** There are TWO separate instances of `CodeFoldingManager`:
1. **Singleton:** `CodeFoldingManager.shared` - used by fold/unfold actions in the text view coordinator
2. **Local instance:** Created with `@StateObject private var foldingManager = CodeFoldingManager()` in `IDEEditorView`

**Location:**
- `VSCodeiPadOS/VSCodeiPadOS/ContentView.swift` line 415: creates local instance
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift` lines 540-546: uses `CodeFoldingManager.shared`

**Evidence:**
```swift
// ContentView.swift line 415 - local instance
@StateObject private var foldingManager = CodeFoldingManager()

// Line 491 - regions detected on local instance
foldingManager.detectFoldableRegions(in: newValue)

// SyntaxHighlightingTextView.swift lines 540-541 - uses DIFFERENT instance!
func handleFold(in textView: UITextView) {
    CodeFoldingManager.shared.foldCurrentLine()  // <-- WRONG INSTANCE!
}
```

The local `foldingManager` has the detected regions, but `CodeFoldingManager.shared` (used for fold actions) has NO regions because `detectFoldableRegions` was never called on it.

Additionally, `foldCurrentLine()` in CodeFoldingManager.swift (line 609-614) folds the FIRST available region, not the one at the cursor position:
```swift
func foldCurrentLine() {
    if let firstUnfolded = foldRegions.first(where: { !$0.isFolded }) {
        collapseRegion(at: firstUnfolded.startLine)  // Always folds first region
    }
}
```

**Fix:** Either:
1. Use `CodeFoldingManager.shared` everywhere and call `detectFoldableRegions` on it, OR
2. Pass the local `foldingManager` instance to `SyntaxHighlightingTextView` coordinator so fold/unfold actions use the correct instance

---

### Files Examined:
- `VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift` (lines 1-778)
- `VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift` (lines 1-866)
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift` (lines 1-600)
- `VSCodeiPadOS/VSCodeiPadOS/ContentView.swift` (lines 394-650)
>>>END
