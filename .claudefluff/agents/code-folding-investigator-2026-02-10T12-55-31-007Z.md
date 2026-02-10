# Agent: code-folding-investigator
**Status:** done
**Tokens:** 8,602
**Cost:** $0.0000
**Time:** 2026-02-10T12:55:31.007Z

## Task
Investigate broken code folding regression in VSCodeiPadOS. Search for all code folding related code - FoldingManager, fold regions, collapse/expand logic. Find: 1) What changed recently that could break it 2) Logic errors in fold detection 3) UI not updating when folds change 4) State management issues. Report root cause with specific line numbers and fix recommendations.

## Response
I'll investigate the broken code folding regression. Let me start by searching for all folding-related code.

>>>TOOL search
{"query": "FoldingManager", "glob": "**/*.{ts,tsx,js}"}
>>>END

Let me search for other folding-related terms.

>>>TOOL search
{"query": "fold", "glob": "**/*.{ts,tsx,js}"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "fold"


Let me search for collapse/expand related code.

>>>TOOL search
{"query": "collapse", "glob": "**/*.{ts,tsx,js}"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "collapse"


Let me explore the project structure to understand the codebase.

>>>TOOL list_dir
{"path": "."}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 ./
📁 .claude/
📁 .claudefluff/
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
   idb_testing_report.md
   LICENSE
   README.md
   StressTest.swift
   test_editor_typing.sh
   update.md
   VSCodeiPadOS_idb_test_plan.sh
   VSCodeiPadOS_Ui_Element_Coordinates.md
(cached)


>>>TOOL list_dir
{"path": "VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/
📁 Docs/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOS.xcodeproj/
📁 VSCodeiPadOSTests/
   bugs.md
   build_output.log
   build_output2.log
   build.log
   Info.plist
   Package.swift
   TypingLagTest.swift
(cached)


>>>TOOL list_dir
{"path": "Views"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/
📁 Editor/
📁 Panels/
(cached)


>>>TOOL list_dir
{"path": "Views/Editor"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/Editor/
   (empty directory)
(cached)


>>>TOOL list_dir
{"path": "Services"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Services/
📁 OnDevice/


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
   KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
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
   FoldingLayoutManager.swift
   GitGutterView.swift
   HoverInfoView.swift
   InlayHintsOverlay.swift
   InlineSuggestionView.swift
   JSONTreeView.swift
   MergeConflictView.swift
   MinimapView.swift
   ModifierTapGestureRecognizer.swift
   MultiCursorTextView.swift
   PeekDefinitionView.swift
   SplitEditorView.swift
   StickyHeaderView.swift
   SyntaxHighlightingTextView_Update.swift
   SyntaxHighlightingTextView.swift


I found the folding-related file. Let me read it.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift (lines 1-71 of 71)
────────────────────────────────────────
1: import UIKit
2: 
3: /// TextKit layout manager that collapses line fragments for lines marked folded in CodeFoldingManager.
4: ///
5: /// This is a view-level folding implementation (it does NOT modify the underlying text).
6: final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
7:     weak var ownerTextView: EditorTextView?
8: 
9:     override init() {
10:         super.init()
11:         self.delegate = self
12:     }
13: 
14:     required init?(coder: NSCoder) {
15:         super.init(coder: coder)
16:         self.delegate = self
17:     }
18: 
19:     func layoutManager(
20:         _ layoutManager: NSLayoutManager,
21:         shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<CGRect>,
22:         lineFragmentUsedRect: UnsafeMutablePointer<CGRect>,
23:         baselineOffset: UnsafeMutablePointer<CGFloat>,
24:         in textContainer: NSTextContainer,
25:         forGlyphRange glyphRange: NSRange
26:     ) -> Bool {
27:         guard let owner = ownerTextView,
28:               let foldingManager = owner.foldingManager,
29:               let fileId = owner.fileId
30:         else {
31:             return false
32:         }
33: 
34:         // Convert glyphRange -> characterRange so we can compute the line index.
35:         let charRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
36:         let loc = max(0, charRange.location)
37: 
38:         let full = (self.textStorage?.string ?? "") as NSString
39:         let lineIndex = FoldingLayoutManager.lineIndex(atUTF16Location: loc, in: full)
40: 
41:         if foldingManager.isLineFolded(fileId: fileId, line: lineIndex) {
42:             // Collapse this visual line fragment.
43:             lineFragmentRect.pointee.size.height = 0
44:             lineFragmentUsedRect.pointee.size.height = 0
45:             baselineOffset.pointee = 0
46:             return true
47:         }
48: 
49:         return false
50:     }
51: 
52:     private static func lineIndex(atUTF16Location loc: Int, in text: NSString) -> Int {
53:         if loc <= 0 { return 0 }
54: 
55:         let capped = min(loc, text.length)
56:         var line = 0
57:         var searchStart = 0
58: 
59:         while searchStart < capped {
60:             let r = text.range(of: "\n", options: [], range: NSRange(location: searchStart, length: capped - searchStart))
61:             if r.location == NSNotFound { break }
62:             line += 1
63:             let next = r.location + 1
64:             if next >= capped { break }
65:             searchStart = next
66:         }
67: 
68:         return line
69:     }
70: }
71: 


Now let me search for CodeFoldingManager which is referenced in this file.

>>>TOOL search
{"query": "CodeFoldingManager", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:68: class CodeFoldingManager: ObservableObject {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:69: static let shared = CodeFoldingManager()
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:424: @ObservedObject private var foldingManager = CodeFoldingManager.shared
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:595: @ObservedObject var foldingManager: CodeFoldingManager


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 1-931 of 931)
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
95:         // If we detect a declaration/function/control-flow whose opening brace is on a later line,
96:         // we mark that brace line so it won't be treated as a standalone generic block.
97:         var braceLinesClaimed: Set<Int> = []
98: 
99:         // Used to prevent duplicate regions for grouped constructs (imports, // comments)
100:         var previousNonEmptyWasImport = false
101:         var previousNonEmptyWasSingleLineComment = false
102:         
103:         for (index, line) in lines.enumerated() {
104:             let trimmed = line.trimmingCharacters(in: .whitespaces)
105:             let leadingWhitespace = line.prefix { $0 == " " || $0 == "\t" }.count
106:             
107:             // Skip empty lines for most detections
108:             guard !trimmed.isEmpty else { continue }
109: 
110:             // MARK: - Close blocks BEFORE opening new ones (handles "} else {" correctly)
111:             if trimmed.hasPrefix("}") {
112:                 // Count consecutive leading '}' so we can pop multiple blocks for lines like "}}"
113:                 let closeCount = max(1, trimmed.prefix { $0 == "}" }.count)
114:                 for _ in 0..<closeCount {
115:                     if let lastBlock = blockStack.popLast() {
116:                         if index - lastBlock.startLine > 1 {
117:                             regions.append(FoldRegion(
118:                                 startLine: lastBlock.startLine,
119:                                 endLine: index,
120:                                 type: lastBlock.type,
121:                                 label: lastBlock.label
122:                             ))
123:                         }
124:                     }
125:                 }
126:             }
127:             
128:             // MARK: - Region Detection (#region, #pragma mark, MARK:)
129:             if let label = detectRegionStart(trimmed) {
130:                 regionStack.append((index, label))
131:             } else if detectRegionEnd(trimmed) {
132:                 if let region = regionStack.popLast() {
133:                     if index - region.startLine > 1 {
134:                         regions.append(FoldRegion(
135:                             startLine: region.startLine,
136:                             endLine: index,
137:                             type: .region,
138:                             label: region.label
139:                         ))
140:                     }
141:                 }
142:             }
143:             
144:             // MARK: - Import Statement Detection (group consecutive imports once)
145:             if trimmed.hasPrefix("import ") {
146:                 if !previousNonEmptyWasImport {
147:                     let importEnd = findConsecutiveImports(from: index, in: lines)
148:                     if importEnd > index {
149:                         regions.append(FoldRegion(
150:                             startLine: index,
151:                             endLine: importEnd,
152:                             type: .importStatement,
153:                             label: "Imports"
154:                         ))
155:                     }
156:                 }
157:                 previousNonEmptyWasImport = true
158:             } else {
159:                 previousNonEmptyWasImport = false
160:             }
161:             
162:             // MARK: - Comment Detection
163:             if detectCommentStart(trimmed) {
164:                 commentStack.append((index, true))
165:                 previousNonEmptyWasSingleLineComment = false
166:             } else if trimmed.starts(with: "//") {
167:                 // Only create a fold region at the start of a consecutive // block
168:                 if !previousNonEmptyWasSingleLineComment {
169:                     let commentEnd = findConsecutiveComments(from: index, in: lines)
170:                     if commentEnd > index {
171:                         regions.append(FoldRegion(
172:                             startLine: index,
173:                             endLine: commentEnd,
174:                             type: .comment,
175:                             label: "Comment"
176:                         ))
177:                     }
178:                 }
179:                 previousNonEmptyWasSingleLineComment = true
180:             } else if detectCommentEnd(trimmed) {
181:                 previousNonEmptyWasSingleLineComment = false
182:                 if let comment = commentStack.popLast() {
183:                     if index - comment.startLine > 1 {
184:                         regions.append(FoldRegion(
185:                             startLine: comment.startLine,
186:                             endLine: index,
187:                             type: .comment,
188:                             label: "Comment"
189:                         ))
190:                     }
191:                 }
192:             } else {
193:                 previousNonEmptyWasSingleLineComment = false
194:             }
195:             
196:             // MARK: - Class/Struct/Enum/Protocol/Extension Detection
197:             if let declaration = detectDeclaration(trimmed) {
198:                 if trimmed.contains("{") {
199:                     blockStack.append((declaration.type, index, declaration.label))
200:                 } else {
201:                     // Declaration without opening brace - look ahead for it
202:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
203:                         braceLinesClaimed.insert(braceLine)
204:                         blockStack.append((declaration.type, index, declaration.label))
205:                     }
206:                 }
207:             }
208:             
209:             // MARK: - Function/Method Detection
210:             if let functionInfo = detectFunction(trimmed) {
211:                 if trimmed.contains("{") {
212:                     blockStack.append((.function, index, functionInfo))
213:                 } else {
214:                     // Function without opening brace - look ahead
215:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
216:                         braceLinesClaimed.insert(braceLine)
217:                         blockStack.append((.function, index, functionInfo))
218:                     }
219:                 }
220:             }
221:             
222:             // MARK: - Control Flow Detection (if, guard, for, while, switch, etc.)
223:             if let controlFlowLabel = detectControlFlow(trimmed) {
224:                 if trimmed.contains("{") {
225:                     blockStack.append((.controlFlow, index, controlFlowLabel))
226:                 } else {
227:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
228:                         braceLinesClaimed.insert(braceLine)
229:                         blockStack.append((.controlFlow, index, controlFlowLabel))
230:                     }
231:                 }
232:             }
233:             
234:             // MARK: - Generic Block Detection
235:             // Avoid adding a generic block for a standalone "{" that belongs to a previously detected declaration.
236:             if trimmed.hasSuffix("{"),
237:                trimmed != "{",
238:                !braceLinesClaimed.contains(index),
239:                !isDeclarationLine(trimmed),
240:                !isFunctionLine(trimmed) {
241:                 blockStack.append((.genericBlock, index, nil))
242:             }
243: 
244:             _ = leadingWhitespace // keep param for potential future heuristics
245:         }
246:         
247:         // Handle any remaining unclosed blocks
248:         while let lastBlock = blockStack.popLast() {
249:             if lines.count - 1 - lastBlock.startLine > 1 {
250:                 regions.append(FoldRegion(
251:                     startLine: lastBlock.startLine,
252:                     endLine: lines.count - 1,
253:                     type: lastBlock.type,
254:                     label: lastBlock.label
255:                 ))
256:             }
257:         }
258:         
259:         // Sort regions by start line
260:         regions.sort { $0.startLine < $1.startLine }
261:         
262:         self.foldRegions = regions
263:         
264:         // Store regions in the per-file dictionary
265:         if let fileId = currentFileId {
266:             foldRegionsByFile[fileId] = regions
267:         }
268:         
269:         // Restore previous fold state for this file
270:         if let filePath = filePath {
271:             restoreFoldState(for: filePath)
272:         }
273:         
274:         updateCollapsedLines()
275:     }
276:     
277:     // MARK: - Detection Helper Methods
278:     
279:     private func detectRegionStart(_ line: String) -> String? {
280:         // C# / VS style regions
281:         if line.hasPrefix("#region") {
282:             let components = line.components(separatedBy: "#region")
283:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Region"
284:         }
285:         // Objective-C pragma marks
286:         if line.hasPrefix("#pragma mark") {
287:             let components = line.components(separatedBy: "#pragma mark")
288:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
289:         }
290:         // Swift MARK comments
291:         if line.contains("MARK:") {
292:             let components = line.components(separatedBy: "MARK:")
293:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
294:         }
295:         // TODO/FIXME regions
296:         if line.contains("TODO:") {
297:             let components = line.components(separatedBy: "TODO:")
298:             return "TODO: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
299:         }
300:         if line.contains("FIXME:") {
301:             let components = line.components(separatedBy: "FIXME:")
302:             return "FIXME: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
303:         }
304:         return nil
305:     }
306:     
307:     private func detectRegionEnd(_ line: String) -> Bool {
308:         return line.hasPrefix("#endregion") || 
309:                line == "// MARK: -" ||
310:                line.hasPrefix("#pragma mark -")
311:     }
312:     
313:     private func detectCommentStart(_ line: String) -> Bool {
314:         return line.hasPrefix("/*") && !line.contains("*/")
315:     }
316:     
317:     private func detectCommentEnd(_ line: String) -> Bool {
318:         return line.contains("*/") && !line.hasPrefix("/*")
319:     }
320:     
321:     private func findConsecutiveImports(from startIndex: Int, in lines: [String]) -> Int {
322:         var endIndex = startIndex
323:         for i in startIndex..<lines.count {
324:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
325:             if trimmed.hasPrefix("import ") {
326:                 endIndex = i
327:             } else if !trimmed.isEmpty {
328:                 break
329:             }
330:         }
331:         return endIndex
332:     }
333:     
334:     private func findConsecutiveComments(from startIndex: Int, in lines: [String]) -> Int {
335:         var endIndex = startIndex
336:         for i in startIndex..<lines.count {
337:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
338:             if trimmed.starts(with: "//") {
339:                 endIndex = i
340:             } else if !trimmed.isEmpty {
341:                 break
342:             }
343:         }
344:         return endIndex
345:     }
346:     
347:     private func detectDeclaration(_ line: String) -> (type: FoldRegion.FoldType, label: String)? {
348:         func matchName(pattern: String) -> String? {
349:             guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
350:             guard let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
351:                   match.numberOfRanges >= 2,
352:                   let r = Range(match.range(at: 1), in: line)
353:             else { return nil }
354:             return String(line[r])
355:         }
356: 
357:         // Allow leading attributes like "@MainActor", "@available(...)"
358:         // Allow common modifiers in any order (best-effort).
359:         let prefix = #"^(?:\s*@\w+(?:\([^\)]*\))?\s+)*(?:\s*(?:public|private|internal|fileprivate|open|final|indirect|lazy|static|override|mutating|nonmutating)\s+)*"#
360: 
361:         // IMPORTANT: avoid treating "class func"/"class var" as a type declaration.
362:         if let name = matchName(pattern: prefix + #"class\s+(?!func\b|var\b|let\b)([A-Za-z_]\w*)"#) {
363:             return (.classOrStruct, name)
364:         }
365: 
366:         // Actor (Swift concurrency) – fold like a class/struct
367:         if let name = matchName(pattern: prefix + #"actor\s+([A-Za-z_]\w*)"#) {
368:             return (.classOrStruct, name)
369:         }
370: 
371:         if let name = matchName(pattern: prefix + #"struct\s+([A-Za-z_]\w*)"#) {
372:             return (.classOrStruct, name)
373:         }
374: 
375:         if let name = matchName(pattern: prefix + #"enum\s+([A-Za-z_]\w*)"#) {
376:             return (.enumDeclaration, name)
377:         }
378: 
379:         if let name = matchName(pattern: prefix + #"protocol\s+([A-Za-z_]\w*)"#) {
380:             return (.protocolDeclaration, name)
381:         }
382: 
383:         // Extensions can include dotted names (Foo.Bar)
384:         if let name = matchName(pattern: prefix + #"extension\s+([A-Za-z_][A-Za-z0-9_\.]*)"#) {
385:             return (.extension, name)
386:         }
387: 
388:         return nil
389:     }
390:     
391:     private func detectFunction(_ line: String) -> String? {
392:         // Function detection with visibility modifiers
393:         let visibilityKeywords = ["public", "private", "internal", "fileprivate", "static", "class", "override", "final", "mutating", "convenience"]
394:         
395:         // Check for 'func' keyword
396:         if line.contains("func ") {
397:             // Extract function name
398:             let funcPattern = "func\\s+(\\w+)"
399:             if let regex = try? NSRegularExpression(pattern: funcPattern),
400:                let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
401:                let nameRange = Range(match.range(at: 1), in: line) {
402:                 let functionName = String(line[nameRange])
403:                 // Check for parameters to create label
404:                 if let parenStart = line.firstIndex(of: "("), let parenEnd = line.firstIndex(of: ")") {
405:                     let params = String(line[parenStart...parenEnd])
406:                     return "\(functionName)\(params)"
407:                 }
408:                 return functionName
409:             }
410:         }
411:         
412:         // Init detection
413:         if let initName = extractName(from: line, prefix: "init", visibility: visibilityKeywords) {
414:             return "\(initName)"
415:         }
416:         
417:         // Deinit detection
418:         if line.contains("deinit") {
419:             return "deinit"
420:         }
421:         
422:         // Computed property with get/set
423:         if line.hasPrefix("var ") && (line.contains("{") || line.contains("get")) {
424:             if let varName = extractVariableName(from: line) {
425:                 return varName
426:             }
427:         }
428:         
429:         return nil
430:     }
431:     
432:     private func detectControlFlow(_ line: String) -> String? {
433:         let controlFlowPatterns = [
434:             ("if ", "if"),
435:             ("guard ", "guard"),
436:             ("else if", "else if"),
437:             ("else", "else"),
438:             ("for ", "for"),
439:             ("while ", "while"),
440:             ("repeat", "repeat"),
441:             ("switch ", "switch"),
442:             ("case ", "case"),
443:             ("default:", "default"),
444:             ("do ", "do"),
445:             ("catch", "catch")
446:         ]
447:         
448:         for (pattern, label) in controlFlowPatterns {
449:             if line.contains(pattern) {
450:                 return label
451:             }
452:         }
453:         return nil
454:     }
455:     
456:     private func extractName(from line: String, prefix: String, visibility: [String]) -> String? {
457:         var components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
458:         
459:         // Remove visibility modifiers
460:         components = components.filter { !visibility.contains($0) }
461:         
462:         // Find prefix index
463:         if let prefixIndex = components.firstIndex(where: { $0 == prefix }),
464:            prefixIndex + 1 < components.count {
465:             var name = components[prefixIndex + 1]
466:             // Remove colons and other trailing characters
467:             name = name.components(separatedBy: ":").first ?? name
468:             name = name.components(separatedBy: "<").first ?? name
469:             name = name.components(separatedBy: ":").first ?? name
470:             return name
471:         }
472:         return nil
473:     }
474:     
475:     private func extractVariableName(from line: String) -> String? {
476:         let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
477:         if components.count >= 2, components[0] == "var" {
478:             var varName = components[1]
479:             varName = varName.components(separatedBy: ":").first ?? varName
480:             varName = varName.components(separatedBy: "=").first ?? varName
481:             return varName
482:         }
483:         return nil
484:     }
485:     
486:     private func findOpeningBrace(from startIndex: Int, in lines: [String]) -> Int? {
487:         for i in startIndex..<min(startIndex + 5, lines.count) {
488:             if lines[i].contains("{") {
489:                 return i
490:             }
491:         }
492:         return nil
493:     }
494:     
495:     private func isDeclarationLine(_ line: String) -> Bool {
496:         let keywords = ["class", "struct", "enum", "protocol", "extension", "init", "func"]
497:         return keywords.contains { line.contains("\($0) ") }
498:     }
499:     
500:     private func isFunctionLine(_ line: String) -> Bool {
501:         return line.contains("func ") || line.contains("init ")
502:     }
503:     
504:     private func detectBlockEnd(_ line: String, leadingWhitespace: Int) -> Bool {
505:         return (line.hasPrefix("}") || line.starts(with: "}")) && 
506:                (line.trimmingCharacters(in: .whitespaces) == "}" || 
507:                 line.trimmingCharacters(in: .whitespaces).hasPrefix("}"))
508:     }
509:     
510:     // MARK: - Fold State Persistence
511:     
512:     /// Saves the current fold state to UserDefaults
513:     func saveFoldState(for filePath: String) {
514:         let key = UserDefaultsKeys.foldStatePrefix + filePath
515:         
516:         // Use regions from the dictionary if available
517:         let regionsToSave: [FoldRegion]
518:         if let fileId = currentFileId, let storedRegions = foldRegionsByFile[fileId] {
519:             regionsToSave = storedRegions
520:         } else {
521:             regionsToSave = foldRegions
522:         }
523:         
524:         // Create a simplified representation for storage
525:         let foldState = regionsToSave.map { FoldStateEntry(startLine: $0.startLine, isFolded: $0.isFolded) }
526:         
527:         if let data = try? JSONEncoder().encode(foldState) {
528:             UserDefaults.standard.set(data, forKey: key)
529:         }
530:     }
531:     
532:     /// Restores fold state from UserDefaults
533:     private func restoreFoldState(for filePath: String) {
534:         let key = UserDefaultsKeys.foldStatePrefix + filePath
535:         
536:         guard let data = UserDefaults.standard.data(forKey: key),
537:               let foldState = try? JSONDecoder().decode([FoldStateEntry].self, from: data) else {
538:             return
539:         }
540:         
541:         // Apply saved state to current regions
542:         for savedState in foldState {
543:             if let index = foldRegions.firstIndex(where: { $0.startLine == savedState.startLine }) {
544:                 foldRegions[index].isFolded = savedState.isFolded
545:             }
546:         }
547:     }
548:     
549:     /// Helper struct for persisting fold state
550:     private struct FoldStateEntry: Codable {
551:         let startLine: Int
552:         let isFolded: Bool
553:     }
554:     
555:     /// Clears fold state for a specific file
556:     func clearFoldState(for filePath: String) {
557:         let key = UserDefaultsKeys.foldStatePrefix + filePath
558:         UserDefaults.standard.removeObject(forKey: key)
559:     }
560:     
561:     /// Clears all fold states
562:     func clearAllFoldStates() {
563:         let defaults = UserDefaults.standard
564:         let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(UserDefaultsKeys.foldStatePrefix) }
565:         for key in keys {
566:             defaults.removeObject(forKey: key)
567:         }
568:     }
569:     
570:     // MARK: - Fold Operations
571:     
572:     /// Toggles the fold state at a specific line
573:     func toggleFold(at line: Int) {
574:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
575:             foldRegions[regionIndex].isFolded.toggle()
576:             updateCollapsedLines()
577:             
578:             // Save state after toggling
579:             if let filePath = currentFilePath {
580:                 saveFoldState(for: filePath)
581:             }
582:         }
583:     }
584:     
585:     /// Expands a folded region
586:     func expandRegion(at line: Int) {
587:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
588:             foldRegions[regionIndex].isFolded = false
589:             updateCollapsedLines()
590:             
591:             if let filePath = currentFilePath {
592:                 saveFoldState(for: filePath)
593:             }
594:         }
595:     }
596:     
597:     /// Collapses a region
598:     func collapseRegion(at line: Int) {
599:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
600:             foldRegions[regionIndex].isFolded = true
601:             updateCollapsedLines()
602:             
603:             if let filePath = currentFilePath {
604:                 saveFoldState(for: filePath)
605:             }
606:         }
607:     }
608:     
609:     /// Expands all folded regions
610:     func expandAll() {
611:         for index in foldRegions.indices {
612:             foldRegions[index].isFolded = false
613:         }
614:         updateCollapsedLines()
615:         
616:         if let filePath = currentFilePath {
617:             saveFoldState(for: filePath)
618:         }
619:     }
620:     
621:     /// Folds the region containing the given cursor line
622:     func foldAtLine(_ cursorLine: Int) {
623:         // Find the innermost region containing this line
624:         if let region = foldRegions.filter({ 
625:             cursorLine >= $0.startLine && cursorLine <= $0.endLine && !$0.isFolded
626:         }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
627:             collapseRegion(at: region.startLine)
628:         }
629:     }
630:     
631:     /// Unfolds the region containing the given cursor line
632:     func unfoldAtLine(_ cursorLine: Int) {
633:         // Find any folded region that starts at or contains this line
634:         if let region = foldRegions.first(where: { 
635:             $0.isFolded && ($0.startLine == cursorLine || (cursorLine >= $0.startLine && cursorLine <= $0.endLine))
636:         }) {
637:             expandRegion(at: region.startLine)
638:         }
639:     }
640:     
641:     /// Toggle fold at cursor line - convenience method
642:     func toggleFoldAtLine(_ cursorLine: Int) {
643:         // First check if we're on a fold start line
644:         if let region = foldRegions.first(where: { $0.startLine == cursorLine }) {
645:             toggleFold(at: region.startLine)
646:             return
647:         }
648:         
649:         // Otherwise find the innermost region containing this line
650:         if let region = foldRegions.filter({ 
651:             cursorLine >= $0.startLine && cursorLine <= $0.endLine
652:         }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
653:             toggleFold(at: region.startLine)
654:         }
655:     }
656:     
657:     // MARK: - Legacy/Convenience Methods (for keyboard shortcuts)
658:     
659:     /// Folds at the current line (uses line 0 as fallback - caller should use foldAtLine(_:) with actual cursor)
660:     func foldCurrentLine() {
661:         // This is called from keyboard shortcuts - fold at line 0 or first available region
662:         if let firstUnfolded = foldRegions.first(where: { !$0.isFolded }) {
663:             collapseRegion(at: firstUnfolded.startLine)
664:         }
665:     }
666:     
667:     /// Unfolds at the current line (uses line 0 as fallback - caller should use unfoldAtLine(_:) with actual cursor)
668:     func unfoldCurrentLine() {
669:         // This is called from keyboard shortcuts - unfold first folded region
670:         if let firstFolded = foldRegions.first(where: { $0.isFolded }) {
671:             expandRegion(at: firstFolded.startLine)
672:         }
673:     }
674:     
675:     /// Collapses all foldable regions
676:     func collapseAll() {
677:         for index in foldRegions.indices {
678:             foldRegions[index].isFolded = true
679:         }
680:         updateCollapsedLines()
681:         
682:         if let filePath = currentFilePath {
683:             saveFoldState(for: filePath)
684:         }
685:     }
686:     
687:     /// Collapses all regions of a specific type
688:     func collapseAll(ofType type: FoldRegion.FoldType) {
689:         for index in foldRegions.indices {
690:             if foldRegions[index].type == type {
691:                 foldRegions[index].isFolded = true
692:             }
693:         }
694:         updateCollapsedLines()
695:         
696:         if let filePath = currentFilePath {
697:             saveFoldState(for: filePath)
698:         }
699:     }
700:     
701:     /// Expands all regions of a specific type
702:     func expandAll(ofType type: FoldRegion.FoldType) {
703:         for index in foldRegions.indices {
704:             if foldRegions[index].type == type {
705:                 foldRegions[index].isFolded = false
706:             }
707:         }
708:         updateCollapsedLines()
709:         
710:         if let filePath = currentFilePath {
711:             saveFoldState(for: filePath)
712:         }
713:     }
714:     
715:     // MARK: - Query Methods
716:     
717:     /// Checks if a line is foldable
718:     func isFoldable(line: Int) -> Bool {
719:         return foldRegions.contains { $0.startLine == line }
720:     }
721:     
722:     /// Checks if a line is currently folded (for the currently active file in `foldRegions`)
723:     func isLineFolded(line: Int) -> Bool {
724:         return collapsedLines.contains(line)
725:     }
726: 
727:     /// Checks if a line should be hidden for a specific file (does not rely on `collapsedLines`)
728:     func isLineFolded(fileId: String, line: Int) -> Bool {
729:         guard let regions = foldRegionsByFile[fileId] else { return false }
730:         for region in regions where region.isFolded {
731:             if line > region.startLine && line <= region.endLine {
732:                 return true
733:             }
734:         }
735:         return false
736:     }
737:     
738:     /// Checks if a region at a given line is folded
739:     func isRegionFolded(at line: Int) -> Bool {
740:         return foldRegions.first { $0.startLine == line }?.isFolded ?? false
741:     }
742:     
743:     /// Gets the fold region at a specific line
744:     func getRegion(at line: Int) -> FoldRegion? {
745:         return foldRegions.first { $0.startLine == line }
746:     }
747:     
748:     /// Gets all fold regions of a specific type
749:     func getRegions(ofType type: FoldRegion.FoldType) -> [FoldRegion] {
750:         return foldRegions.filter { $0.type == type }
751:     }
752:     
753:     // MARK: - File-Aware Methods
754:     
755:     /// Checks if a line is foldable for a specific file
756:     func isFoldable(fileId: String, line: Int) -> Bool {
757:         guard let regions = foldRegionsByFile[fileId] else { return false }
758:         return regions.contains { $0.startLine == line }
759:     }
760:     
761:     /// Checks if a region at a given line is folded for a specific file
762:     func isFolded(fileId: String, line: Int) -> Bool {
763:         guard let regions = foldRegionsByFile[fileId] else { return false }
764:         return regions.first { $0.startLine == line }?.isFolded ?? false
765:     }
766:     
767:     /// Toggles the fold state at a specific line for a specific file
768:     func toggleFold(fileId: String, line: Int) {
769:         guard var regions = foldRegionsByFile[fileId] else { return }
770:         
771:         if let regionIndex = regions.firstIndex(where: { $0.startLine == line }) {
772:             regions[regionIndex].isFolded.toggle()
773:             foldRegionsByFile[fileId] = regions
774:             
775:             // Update current file regions if this is the active file
776:             if fileId == currentFileId {
777:                 self.foldRegions = regions
778:                 updateCollapsedLines()
779:             } else {
780:                 // Ensure SwiftUI updates for gutters rendering using file-aware queries.
781:                 objectWillChange.send()
782:             }
783:             
784:             // Save state after toggling
785:             saveFoldState(for: fileId)
786:         }
787:     }
788:     
789:     /// Gets fold regions for a specific file
790:     func getFoldRegions(for fileId: String) -> [FoldRegion] {
791:         return foldRegionsByFile[fileId] ?? []
792:     }
793:     
794:     /// Clears fold regions for a specific file from memory
795:     func clearFoldRegions(for fileId: String) {
796:         foldRegionsByFile.removeValue(forKey: fileId)
797:     }
798:     
799:     /// Clears all fold regions from memory
800:     func clearAllFoldRegions() {
801:         foldRegionsByFile.removeAll()
802:     }
803:     
804:     /// Gets folded line ranges for text hiding
805:     /// Returns an array of closed ranges representing the line numbers that should be hidden
806:     func getFoldedLineRanges() -> [ClosedRange<Int>] {
807:         var ranges: [ClosedRange<Int>] = []
808:         
809:         // Sort regions by start line to ensure proper ordering
810:         let sortedRegions = foldRegions.sorted { $0.startLine < $1.startLine }
811:         
812:         for region in sortedRegions where region.isFolded {
813:             ranges.append((region.startLine + 1)...region.endLine)
814:         }
815:         
816:         return ranges
817:     }
818:     
819:     /// Gets the total count of folded lines
820:     func getFoldedLineCount() -> Int {
821:         return collapsedLines.count
822:     }
823:     
824:     /// Gets a summary of fold statistics
825:     func getFoldStatistics() -> FoldStatistics {
826:         let totalCount = foldRegions.count
827:         let foldedCount = foldRegions.filter { $0.isFolded }.count
828:         
829:         var typeBreakdown: [FoldRegion.FoldType: Int] = [:]
830:         for region in foldRegions {
831:             typeBreakdown[region.type, default: 0] += 1
832:         }
833:         
834:         return FoldStatistics(
835:             totalRegions: totalCount,
836:             foldedRegions: foldedCount,
837:             typeBreakdown: typeBreakdown
838:         )
839:     }
840:     
841:     // MARK: - Private Methods
842:     
843:     private func updateCollapsedLines() {
844:         collapsedLines.removeAll()
845:         
846:         for region in foldRegions where region.isFolded {
847:             for line in (region.startLine + 1)...region.endLine {
848:                 collapsedLines.insert(line)
849:             }
850:         }
851:     }
852: }
853: 
854: // MARK: - Fold Statistics
855: struct FoldStatistics {
856:     let totalRegions: Int
857:     let foldedRegions: Int
858:     let typeBreakdown: [FoldRegion.FoldType: Int]
859:     
860:     var expansionPercentage: Double {
861:         guard totalRegions > 0 else { return 0 }
862:         return Double(foldedCount) / Double(totalRegions) * 100
863:     }
864:     
865:     var foldedCount: Int {
866:         return foldedRegions
867:     }
868:     
869:     var expandedCount: Int {
870:         return totalRegions - foldedRegions
871:     }
872: }
873: 
874: // MARK: - Fold Button View
875: struct FoldButton: View {
876:     let line: Int
877:     let isExpanded: Bool
878:     let foldType: FoldRegion.FoldType?
879:     let action: () -> Void
880:     
881:     var body: some View {
882:         Button(action: action) {
883:             ZStack {
884:                 if let type = foldType {
885:                     Text(type.icon)
886:                         .font(.system(size: 8, weight: .bold))
887:                         .foregroundColor(.blue.opacity(0.6))
888:                 }
889:                 
890:                 Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
891:                     .font(.system(size: 10, weight: .semibold))
892:                     .foregroundColor(.primary.opacity(0.7))
893:             }
894:             .frame(width: 18, height: 18)
895:             .background(isExpanded ? Color.secondary.opacity(0.1) : Color.secondary.opacity(0.2))
896:             .cornerRadius(4)
897:         }
898:         .buttonStyle(PlainButtonStyle())
899:     }
900: }
901: 
902: // MARK: - Line Number View with Folding
903: struct LineNumberViewWithFolding: View {
904:     let lineNumber: Int
905:     let isFoldable: Bool
906:     let isExpanded: Bool
907:     let foldType: FoldRegion.FoldType?
908:     let onFoldTap: () -> Void
909:     
910:     var body: some View {
911:         HStack(spacing: 4) {
912:             if isFoldable {
913:                 FoldButton(
914:                     line: lineNumber,
915:                     isExpanded: isExpanded,
916:                     foldType: foldType,
917:                     action: onFoldTap
918:                 )
919:             } else {
920:                 Color.clear
921:                     .frame(width: 18, height: 18)
922:             }
923:             
924:             Text("\(lineNumber + 1)")
925:                 .font(.system(.caption, design: .monospaced))
926:                 .foregroundColor(.gray)
927:                 .frame(minWidth: 30, alignment: .trailing)
928:         }
929:     }
930: }
931: 


Now I need to find EditorTextView which is referenced in FoldingLayoutManager. Let me search for it.

>>>TOOL search
{"query": "EditorTextView", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/UITests/GoToLineUITests.swift:223: let editorExists = app.textViews.matching(identifier: "EditorTextView").firstMatch.exists


Let me search for where foldingManager is used on EditorTextView or similar views.

>>>TOOL search
{"query": "foldingManager", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 16 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:424: @ObservedObject private var foldingManager = CodeFoldingManager.shared
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:448: foldingManager: foldingManager,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:502: foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path ?? tab.fileName)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:566: foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:570: foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:595: @ObservedObject var foldingManager: CodeFoldingManager
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:607: if !foldingManager.isLineFolded(line: lineIndex) {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:623: if foldingManager.isFoldable(line: lineIndex) {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:624: Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:625: Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:28: let foldingManager = owner.foldingManager,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:41: if foldingManager.isLineFolded(fileId: fileId, line: lineIndex) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:489: @ObservedObject private var foldingManager = CodeFoldingManager.shared
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:518: if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:520: foldingManager.toggleFold(fileId: fileId, line: lineIndex)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:522: Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")


Let me look at SyntaxHighlightingTextView.swift since that's likely where the text view with folding support is.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
⚠️ File too large (97160 chars, 2151 lines). Showing first 100 lines.
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
16:     /// Pixel scroll offset (contentOffset.y) for smooth gutter alignment.
17:     @Binding var scrollOffset: CGFloat
18:     @Binding var totalLines: Int
19:     @Binding var visibleLines: Int
20:     @Binding var currentLineNumber: Int
21:     @Binding var currentColumn: Int
22:     @Binding var cursorIndex: Int
23:     @Binding var lineHeight: CGFloat
24:     @Binding var requestedLineSelection: Int?
25:     @Binding var requestedCursorIndex: Int?
26: 
27:     /// Autocomplete key handling hooks (return true if handled)
28:     let onAcceptAutocomplete: (() -> Bool)?
29:     let onDismissAutocomplete: (() -> Bool)?
30: 
31:     let isActive: Bool
32:     let fontSize: CGFloat  // Explicit parameter to trigger SwiftUI updates
33:     @EnvironmentObject var editorCore: EditorCore
34: 
35:     init(
36:         text: Binding<String>,
37:         filename: String,
38:         scrollPosition: Binding<Int>,
39:         scrollOffset: Binding<CGFloat> = .constant(0),
40:         totalLines: Binding<Int>,
41:         visibleLines: Binding<Int>,
42:         currentLineNumber: Binding<Int>,
43:         currentColumn: Binding<Int>,
44:         cursorIndex: Binding<Int> = .constant(0),
45:         lineHeight: Binding<CGFloat>,
46:         isActive: Bool,
47:         fontSize: CGFloat = 14.0,
48:         requestedLineSelection: Binding<Int?> = .constant(nil),
49:         requestedCursorIndex: Binding<Int?> = .constant(nil),
50:         onAcceptAutocomplete: (() -> Bool)? = nil,
51:         onDismissAutocomplete: (() -> Bool)? = nil
52:     ) {
53:         self._text = text
54:         self.filename = filename
55:         self._scrollPosition = scrollPosition
56:         self._scrollOffset = scrollOffset
57:         self._totalLines = totalLines
58:         self._visibleLines = visibleLines
59:         self._currentLineNumber = currentLineNumber
60:         self._currentColumn = currentColumn
61:         self._cursorIndex = cursorIndex
62:         self._lineHeight = lineHeight
63:         self.isActive = isActive
64:         self.fontSize = fontSize
65:         self._requestedLineSelection = requestedLineSelection
66:         self._requestedCursorIndex = requestedCursorIndex
67:         self.onAcceptAutocomplete = onAcceptAutocomplete
68:         self.onDismissAutocomplete = onDismissAutocomplete
69:     }
70:     
71:     // Compatibility init for older call sites (e.g. SplitEditorView) that pass editorCore explicitly.
72:     init(
73:         text: Binding<String>,
74:         filename: String,
75:         scrollPosition: Binding<Int>,
76:         scrollOffset: Binding<CGFloat> = .constant(0),
77:         totalLines: Binding<Int>,
78:         visibleLines: Binding<Int>,
79:         currentLineNumber: Binding<Int>,
80:         currentColumn: Binding<Int>,
81:         cursorIndex: Binding<Int> = .constant(0),
82:         lineHeight: Binding<CGFloat>,
83:         isActive: Bool,
84:         editorCore: EditorCore,
85:         requestedLineSelection: Binding<Int?> = .constant(nil),
86:         requestedCursorIndex: Binding<Int?> = .constant(nil),
87:         onAcceptAutocomplete: (() -> Bool)? = nil,
88:         onDismissAutocomplete: (() -> Bool)? = nil
89:     ) {
90:         self.init(
91:             text: text,
92:             filename: filename,
93:             scrollPosition: scrollPosition,
94:             scrollOffset: scrollOffset,
95:             totalLines: totalLines,
96:             visibleLines: visibleLines,
97:             currentLineNumber: currentLineNumber,
98:             currentColumn: currentColumn,
99:             cursorIndex: cursorIndex,
100:             lineHeight: lineHeight,

... [truncated - 2051 more lines]


Let me search for where FoldingLayoutManager is connected to the text view and look for the foldingManager property.

>>>TOOL search
{"query": "FoldingLayoutManager", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:6: final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:39: let lineIndex = FoldingLayoutManager.lineIndex(atUTF16Location: loc, in: full)


The FoldingLayoutManager exists but is only referenced within its own file. Let me search for where the text view is created and how it's connected to the layout manager.

>>>TOOL search
{"query": "NSLayoutManager", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:6: final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:20: _ layoutManager: NSLayoutManager,


Let me search for how the UITextView is created in SyntaxHighlightingTextView to see if FoldingLayoutManager is wired in.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-300 of 2151)
────────────────────────────────────────
101:             isActive: isActive,
102:             fontSize: editorCore.editorFontSize,
103:             requestedLineSelection: requestedLineSelection,
104:             requestedCursorIndex: requestedCursorIndex,
105:             onAcceptAutocomplete: onAcceptAutocomplete,
106:             onDismissAutocomplete: onDismissAutocomplete
107:         )
108:     }
109: 
110:     func makeCoordinator() -> Coordinator {
111:         Coordinator(self)
112:     }
113:     
114:     func makeUIView(context: Context) -> UITextView {
115:         let textView = EditorTextView()
116:         textView.delegate = context.coordinator
117:         textView.editorCore = editorCore
118: 
119:         // Autocomplete hooks
120:         textView.onAcceptAutocomplete = onAcceptAutocomplete
121:         textView.onDismissAutocomplete = onDismissAutocomplete
122: 
123:         textView.onPeekDefinition = {
124:             context.coordinator.handlePeekDefinition(in: textView)
125:         }
126: 
127:         textView.onEscape = {
128:             context.coordinator.handleEscape()
129:         }
130: 
131:         textView.onGoToLine = {
132:             self.editorCore.showGoToLine = true
133:         }
134:         
135:         // Wire up custom context menu actions
136:         textView.onGoToDefinition = {
137:             context.coordinator.handleGoToDefinition(in: textView)
138:         }
139:         
140:         textView.onFindReferences = {
141:             context.coordinator.handleFindReferences(in: textView)
142:         }
143:         
144:         textView.onFormatDocument = {
145:             context.coordinator.handleFormatDocument(in: textView)
146:         }
147:         
148:         textView.onToggleComment = {
149:             context.coordinator.handleToggleComment(in: textView)
150:         }
151:         
152:         textView.onFold = {
153:             context.coordinator.handleFold(in: textView)
154:         }
155:         
156:         textView.onUnfold = {
157:             context.coordinator.handleUnfold(in: textView)
158:         }
159:         
160:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
161:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
162:         pinchGesture.delegate = context.coordinator
163:         textView.addGestureRecognizer(pinchGesture)
164:         context.coordinator.pinchGesture = pinchGesture
165:         
166:         // Configure text view
167:         textView.isEditable = true
168:         textView.isSelectable = true
169:         textView.autocapitalizationType = .none
170:         textView.autocorrectionType = .no
171:         textView.smartDashesType = .no
172:         textView.smartQuotesType = .no
173:         textView.smartInsertDeleteType = .no
174:         textView.spellCheckingType = .no
175:         
176:         // Set font and appearance (use editorCore.editorFontSize)
177:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
178:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
179:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
180:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
181:         textView.keyboardType = .default
182:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
183:         
184:         // Enable line wrapping
185:         textView.textContainer.lineBreakMode = .byCharWrapping
186:         textView.textContainer.widthTracksTextView = true
187:         
188:         // Calculate line height
189:         if let font = textView.font {
190:             DispatchQueue.main.async {
191:                 self.lineHeight = font.lineHeight
192:             }
193:         }
194:         
195:         // Set initial text with syntax highlighting
196:         textView.text = text
197:         context.coordinator.applySyntaxHighlighting(to: textView)
198:         context.coordinator.updateLineCount(textView)
199:         
200:         return textView
201:     }
202:     
203:     func updateUIView(_ textView: UITextView, context: Context) {
204:         // CRITICAL: Update coordinator's parent reference to current struct
205:         // SwiftUI creates new struct instances on each update, so this keeps
206:         // coordinator in sync with current bindings and properties
207:         context.coordinator.parent = self
208:         
209:         // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
210:         // This fixes the bug where syntax highlighting only appears after typing.
211:         // makeUIView applies it, but the view may not be fully in hierarchy yet,
212:         // causing the attributed text to be lost. This ensures it's applied reliably.
213:         if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
214:             context.coordinator.applySyntaxHighlighting(to: textView)
215:             context.coordinator.hasAppliedInitialHighlighting = true
216:         }
217:         
218:         // Update colors when theme changes
219:         // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor
220:         // as it interferes with attributedText syntax highlighting colors.
221:         // The foreground color is handled entirely by the attributedText.
222:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
223:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
224:         
225:         if let editorView = textView as? EditorTextView {
226:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
227:         }
228:         
229:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
230:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
231:             let selectedRange = textView.selectedRange
232:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
233:             context.coordinator.applySyntaxHighlighting(to: textView)
234:             textView.selectedRange = selectedRange
235:             
236:             // Update line height
237:             if let font = textView.font {
238:                 DispatchQueue.main.async {
239:                     self.lineHeight = font.lineHeight
240:                 }
241:             }
242:         }
243:         
244:         // Update text if changed externally
245:         if textView.text != text {
246:             let selectedRange = textView.selectedRange
247:             textView.text = text
248:             context.coordinator.applySyntaxHighlighting(to: textView)
249:             context.coordinator.hasAppliedInitialHighlighting = true
250:             textView.selectedRange = selectedRange
251:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
252:             // Re-apply highlighting if theme changed
253:             context.coordinator.applySyntaxHighlighting(to: textView)
254:         }
255:         
256:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
257:         // This prevents the editor from fighting against user scroll due to async binding lag
258:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
259:             // Update lastKnownScrollPosition FIRST to prevent race condition
260:             // where user scroll gets overridden by stale binding value
261:             context.coordinator.lastKnownScrollPosition = scrollPosition
262:             context.coordinator.scrollToLine(scrollPosition, in: textView)
263:         }
264: 
265:         // Handle line selection requests (e.g. tapping line numbers)
266:         if let requested = requestedLineSelection,
267:            requested != context.coordinator.lastRequestedLineSelection {
268:             context.coordinator.lastRequestedLineSelection = requested
269:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
270:             // Defer @Binding update to avoid "Publishing changes from within view updates"
271:             DispatchQueue.main.async {
272:                 self.requestedLineSelection = nil
273:             }
274:         }
275: 
276:         // Handle cursor index requests (e.g. accepting autocomplete)
277:         if let requested = requestedCursorIndex,
278:            requested != context.coordinator.lastRequestedCursorIndex {
279:             context.coordinator.lastRequestedCursorIndex = requested
280:             // Use UTF-16 count for NSRange compatibility
281:             let textLength = (textView.text as NSString?)?.length ?? 0
282:             let safeIndex = max(0, min(requested, textLength))
283:             textView.selectedRange = NSRange(location: safeIndex, length: 0)
284:             
285:             // Ensure cursor is visible by scrolling to it
286:             textView.scrollRangeToVisible(textView.selectedRange)
287:             
288:             // Defer @Binding update to avoid "Publishing changes from within view updates"
289:             DispatchQueue.main.async {
290:                 self.requestedCursorIndex = nil
291:             }
292: 
293:             // Update SwiftUI state
294:             context.coordinator.updateCursorPosition(textView)
295:             context.coordinator.updateScrollPosition(textView)
296:         }
297:         
298:         // Note: updateLineCount is called in textViewDidChange, no need to call here
299:         // as it causes unnecessary state churn on every updateUIView
300:     }


>>>TOOL search
{"query": "class EditorTextView", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class EditorTextView"


>>>TOOL search
{"query": "EditorTextView:", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "EditorTextView:"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 300, "end_line": 600}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 301-600 of 2151)
────────────────────────────────────────
301:     
302:     // MARK: - Coordinator
303:     
304:     class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
305:         var parent: SyntaxHighlightingTextView
306:         var lastKnownScrollPosition: Int = 0
307:         var lastThemeId: String = ""
308:         var lastRequestedLineSelection: Int? = nil
309:         var lastRequestedCursorIndex: Int? = nil
310:         private var isUpdatingFromMinimap = false
311:         private var highlightDebouncer: Timer?
312:         weak var pinchGesture: UIPinchGestureRecognizer?
313:         private var initialFontSize: CGFloat = 0
314:         
315:         // Track user scroll to prevent programmatic scroll fighting back
316:         private var userScrollDebouncer: Timer?
317:         var isUserScrolling = false
318: 
319:         // FEAT-044: Matching bracket highlight state
320:         private var bracketHighlightRanges: [NSRange] = []
321:         
322:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
323:         var hasAppliedInitialHighlighting = false
324:         
325:         // PERFORMANCE: Large file highlighting optimization
326:         // Files larger than this threshold get deferred full highlighting
327:         private let largeFileThreshold = 10000  // 10k characters
328:         private var largeFileHighlightDebouncer: Timer?
329:         // Track if we have pending full highlight (for large files)
330:         private var hasPendingFullHighlight = false
331:         
332:         init(_ parent: SyntaxHighlightingTextView) {
333:             self.parent = parent
334:         }
335:         
336:         // MARK: - UIGestureRecognizerDelegate
337:         
338:         // Allow pinch gesture to work simultaneously with text selection gestures
339:         func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
340:             // Allow pinch to work alongside native text selection gestures
341:             return true
342:         }
343:         
344:         func textViewDidBeginEditing(_ textView: UITextView) {
345:             // Ensure syntax highlighting is current when user begins editing
346:             // This handles cases where text was set but highlighting hasn't run yet
347:             applySyntaxHighlighting(to: textView)
348:         }
349:         
350:         func textViewDidChange(_ textView: UITextView) {
351:             // Update parent text
352:             parent.text = textView.text
353:             
354:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
355:             // This prevents flicker during the debounce period
356:             let theme = ThemeManager.shared.currentTheme
357:             let fontSize = parent.editorCore.editorFontSize
358:             textView.typingAttributes = [
359:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
360:                 .foregroundColor: UIColor(theme.editorForeground)
361:             ]
362:             
363:             // PERFORMANCE FIX: Aggressive debounce strategy based on document size
364:             // For large files, syntax highlighting is EXTREMELY expensive and causes lag
365:             let textLength = textView.text.count
366:             
367:             // Large file threshold - above this, skip highlighting during active typing entirely
368:             let largeFileThreshold = 10000
369:             // Very large file threshold - above this, use extended delay
370:             let veryLargeFileThreshold = 50000
371:             
372:             highlightDebouncer?.invalidate()
373:             
374:             if textLength > veryLargeFileThreshold {
375:                 // VERY LARGE FILES (50k+): Wait 1.5 seconds of idle before highlighting
376:                 // This prevents UI blocking entirely during active typing
377:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
378:                     self?.applyVisibleRangeHighlighting(to: textView)
379:                 }
380:             } else if textLength > largeFileThreshold {
381:                 // LARGE FILES (10k-50k): Wait 1 second of idle, then highlight visible range only
382:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
383:                     self?.applyVisibleRangeHighlighting(to: textView)
384:                 }
385:             } else if textLength > 5000 {
386:                 // MEDIUM FILES (5k-10k): 300ms debounce, full highlighting on background thread
387:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
388:                     self?.applyHighlightingAsync(to: textView)
389:                 }
390:             } else {
391:                 // SMALL FILES (<5k): 80ms debounce, direct highlighting (fast enough)
392:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
393:                     DispatchQueue.main.async {
394:                         self?.applySyntaxHighlighting(to: textView)
395:                     }
396:                 }
397:             }
398:             
399:             updateLineCount(textView)
400:             updateCursorPosition(textView)
401:         }
402:         
403:         /// Async highlighting for large files - processes on background thread
404:         func applyHighlightingAsync(to textView: UITextView) {
405:             guard !isApplyingHighlighting else { return }
406:             isApplyingHighlighting = true
407:             
408:             let text = textView.text ?? ""
409:             let filename = parent.filename
410:             let theme = ThemeManager.shared.currentTheme
411:             let fontSize = parent.editorCore.editorFontSize
412:             let selectedRange = textView.selectedRange
413:             
414:             // Process highlighting on background thread
415:             DispatchQueue.global(qos: .userInitiated).async { [weak self] in
416:                 let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
417:                 let attributedText = highlighter.highlight(text, filename: filename)
418:                 
419:                 // Apply on main thread
420:                 DispatchQueue.main.async {
421:                     guard let self = self else { return }
422:                     self.isApplyingHighlighting = false
423:                     
424:                     // Only apply if text hasn't changed while we were processing
425:                     guard textView.text == text else { return }
426:                     
427:                     textView.attributedText = attributedText
428:                     textView.selectedRange = selectedRange
429:                     
430:                     textView.typingAttributes = [
431:                         .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
432:                         .foregroundColor: UIColor(theme.editorForeground)
433:                     ]
434:                     
435:                     self.lastThemeId = theme.id
436:                 }
437:             }
438:         }
439:         
440:         /// PERFORMANCE: Visible-range-only highlighting for very large files
441:         /// Only highlights the text that's currently visible on screen, dramatically reducing lag
442:         func applyVisibleRangeHighlighting(to textView: UITextView) {
443:             guard !isApplyingHighlighting else { return }
444:             isApplyingHighlighting = true
445:             
446:             let text = textView.text ?? ""
447:             let filename = parent.filename
448:             let theme = ThemeManager.shared.currentTheme
449:             let fontSize = parent.editorCore.editorFontSize
450:             let selectedRange = textView.selectedRange
451:             
452:             // Calculate visible range with buffer
453:             let visibleRect = textView.bounds
454:             let textContainer = textView.textContainer
455:             let layoutManager = textView.layoutManager
456:             
457:             // Get the glyph range for the visible rect
458:             var visibleGlyphRange = NSRange()
459:             layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs)) { (rect, usedRect, container, glyphRange, stop) in
460:                 if rect.intersects(visibleRect) {
461:                     if visibleGlyphRange.length == 0 {
462:                         visibleGlyphRange = glyphRange
463:                     } else {
464:                         visibleGlyphRange.length = glyphRange.location + glyphRange.length - visibleGlyphRange.location
465:                     }
466:                 } else if visibleGlyphRange.length > 0 && rect.minY > visibleRect.maxY {
467:                     stop.pointee = true
468:                 }
469:             }
470:             
471:             // Convert glyph range to character range
472:             var visibleCharRange = layoutManager.characterRange(forGlyphRange: visibleGlyphRange, actualGlyphRange: nil)
473:             
474:             // Add buffer of ~50 lines before and after for smooth scrolling
475:             let bufferChars = 5000
476:             let rangeStart = max(0, visibleCharRange.location - bufferChars)
477:             let rangeEnd = min(text.utf16.count, visibleCharRange.location + visibleCharRange.length + bufferChars)
478:             visibleCharRange = NSRange(location: rangeStart, length: rangeEnd - rangeStart)
479:             
480:             // Process highlighting on background thread
481:             DispatchQueue.global(qos: .userInitiated).async { [weak self] in
482:                 // Extract the visible portion of text
483:                 let nsText = text as NSString
484:                 let safeRange = NSRange(
485:                     location: visibleCharRange.location,
486:                     length: min(visibleCharRange.length, nsText.length - visibleCharRange.location)
487:                 )
488:                 guard safeRange.length > 0 else {
489:                     DispatchQueue.main.async {
490:                         self?.isApplyingHighlighting = false
491:                     }
492:                     return
493:                 }
494:                 
495:                 let visibleText = nsText.substring(with: safeRange)
496:                 
497:                 // Highlight only the visible portion
498:                 let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
499:                 let highlightedVisible = highlighter.highlight(visibleText, filename: filename)
500:                 
501:                 // Apply on main thread
502:                 DispatchQueue.main.async {
503:                     guard let self = self else { return }
504:                     self.isApplyingHighlighting = false
505:                     
506:                     // Only apply if text hasn't changed while we were processing
507:                     guard textView.text == text else { return }
508:                     
509:                     // Create full attributed string with base styling
510:                     let fullAttributed = NSMutableAttributedString(string: text)
511:                     let baseFont = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
512:                     let baseColor = UIColor(theme.editorForeground)
513:                     let fullRange = NSRange(location: 0, length: text.utf16.count)
514:                     fullAttributed.addAttribute(.font, value: baseFont, range: fullRange)
515:                     fullAttributed.addAttribute(.foregroundColor, value: baseColor, range: fullRange)
516:                     
517:                     // Apply highlighted attributes only to visible range
518:                     highlightedVisible.enumerateAttributes(in: NSRange(location: 0, length: highlightedVisible.length), options: []) { attrs, range, _ in
519:                         let targetRange = NSRange(location: safeRange.location + range.location, length: range.length)
520:                         if targetRange.location + targetRange.length <= fullAttributed.length {
521:                             for (key, value) in attrs {
522:                                 fullAttributed.addAttribute(key, value: value, range: targetRange)
523:                             }
524:                         }
525:                     }
526:                     
527:                     textView.attributedText = fullAttributed
528:                     textView.selectedRange = selectedRange
529:                     
530:                     textView.typingAttributes = [
531:                         .font: baseFont,
532:                         .foregroundColor: baseColor
533:                     ]
534:                     
535:                     self.lastThemeId = theme.id
536:                 }
537:             }
538:         }
539:         
540:         func textViewDidChangeSelection(_ textView: UITextView) {
541:             if !isUpdatingFromMinimap {
542:                 updateCursorPosition(textView)
543:                 updateScrollPosition(textView)
544: 
545:                 // FEAT-044: Matching bracket highlight
546:                 updateMatchingBracketHighlight(textView)
547: 
548:                 // Trigger redraw so current-line highlight/indent guides track the caret
549:                 (textView as? EditorTextView)?.setNeedsDisplay()
550: 
551:                 // Update selection in EditorCore for multi-cursor support
552:                 // Defer @Published property updates to avoid "Publishing changes from within view updates"
553:                 let range = textView.selectedRange
554:                 let currentText = textView.text ?? ""
555:                 let isMultiCursor = parent.editorCore.multiCursorState.isMultiCursor
556:                 
557:                 DispatchQueue.main.async { [weak self] in
558:                     guard let self = self else { return }
559:                     self.parent.editorCore.updateSelection(range: range, text: currentText)
560: 
561:                     // Keep EditorCore.multiCursorState in sync with UIKit selection.
562:                     // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
563:                     // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
564:                     if !isMultiCursor {
565:                         if range.length > 0 {
566:                             self.parent.editorCore.multiCursorState.cursors = [
567:                                 Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)
568:                             ]
569:                         } else {
570:                             self.parent.editorCore.multiCursorState.reset(to: range.location)
571:                         }
572:                     }
573:                 }
574:             }
575:         }
576:         
577:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
578:         
579:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
580:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
581:             isUserScrolling = true
582:             userScrollDebouncer?.invalidate()
583:         }
584:         
585:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
586:             // If not decelerating, user stopped scrolling
587:             if !decelerate {
588:                 // Small delay to let any final scroll events settle
589:                 userScrollDebouncer?.invalidate()
590:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
591:                     self?.isUserScrolling = false
592:                 }
593:             }
594:         }
595:         
596:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
597:             // Deceleration finished - user scroll is complete
598:             userScrollDebouncer?.invalidate()
599:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
600:                 self?.isUserScrolling = false


>>>TOOL search
{"query": "EditorTextView()", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "EditorTextView()"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1800, "end_line": 2151}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1801-2151 of 2151)
────────────────────────────────────────
1801:         highlightPattern(attributed, pattern: codeBlockPattern, color: UIColor(theme.comment), text: text)
1802:         
1803:         // Links (light blue)
1804:         let linkPattern = "\\[[^\\]]+\\]\\([^)]+\\)"
1805:         highlightPattern(attributed, pattern: linkPattern, color: UIColor(theme.variable), text: text)
1806:         
1807:         // Lists
1808:         let listPattern = "^\\s*[-*+]\\s"
1809:         highlightPattern(attributed, pattern: listPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
1810:     }
1811:     
1812:     // MARK: - Rust Highlighting
1813:     
1814:     private func highlightRust(_ attributed: NSMutableAttributedString, text: String) {
1815:         let keywords = ["fn", "let", "mut", "const", "if", "else", "match", "loop", "while", "for",
1816:                        "return", "struct", "enum", "impl", "trait", "type", "use", "mod", "pub",
1817:                        "self", "Self", "super", "crate", "as", "in", "ref", "move", "async", "await",
1818:                        "where", "unsafe", "extern", "dyn", "static", "break", "continue"]
1819:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1820:         
1821:         let types = ["i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize",
1822:                     "f32", "f64", "bool", "char", "str", "String", "Vec", "Option", "Result", "Box"]
1823:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1824:         
1825:         let constants = ["true", "false", "None", "Some", "Ok", "Err"]
1826:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1827:         
1828:         // Macros (yellow)
1829:         let macroPattern = "[a-zA-Z_][a-zA-Z0-9_]*!"
1830:         highlightPattern(attributed, pattern: macroPattern, color: UIColor(theme.function), text: text)
1831:         
1832:         // Lifetimes (orange)
1833:         let lifetimePattern = "'[a-zA-Z_][a-zA-Z0-9_]*"
1834:         highlightPattern(attributed, pattern: lifetimePattern, color: UIColor(theme.string), text: text)
1835:         
1836:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1837:         highlightStrings(attributed, text: text)
1838:         highlightNumbers(attributed, text: text)
1839:     }
1840:     
1841:     // MARK: - Go Highlighting
1842:     
1843:     private func highlightGo(_ attributed: NSMutableAttributedString, text: String) {
1844:         let keywords = ["func", "var", "const", "type", "struct", "interface", "map", "chan",
1845:                        "if", "else", "for", "range", "switch", "case", "default", "select",
1846:                        "return", "break", "continue", "goto", "fallthrough", "defer", "go",
1847:                        "package", "import"]
1848:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1849:         
1850:         let types = ["int", "int8", "int16", "int32", "int64", "uint", "uint8", "uint16", "uint32", "uint64",
1851:                     "float32", "float64", "complex64", "complex128", "byte", "rune", "string", "bool", "error"]
1852:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1853:         
1854:         let constants = ["true", "false", "nil", "iota"]
1855:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1856:         
1857:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1858:         highlightStrings(attributed, text: text)
1859:         highlightNumbers(attributed, text: text)
1860:     }
1861:     
1862:     // MARK: - Java Highlighting
1863:     
1864:     private func highlightJava(_ attributed: NSMutableAttributedString, text: String) {
1865:         let keywords = ["public", "private", "protected", "class", "interface", "extends", "implements",
1866:                        "static", "final", "abstract", "native", "synchronized", "volatile", "transient",
1867:                        "if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue",
1868:                        "return", "throw", "throws", "try", "catch", "finally", "new", "this", "super",
1869:                        "import", "package", "instanceof", "assert", "enum", "void"]
1870:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1871:         
1872:         let types = ["int", "long", "short", "byte", "float", "double", "char", "boolean",
1873:                     "String", "Integer", "Long", "Double", "Boolean", "Object", "List", "Map", "Set"]
1874:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1875:         
1876:         let constants = ["true", "false", "null"]
1877:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1878:         
1879:         // Annotations
1880:         let annotationPattern = "@[a-zA-Z][a-zA-Z0-9]*"
1881:         highlightPattern(attributed, pattern: annotationPattern, color: UIColor(theme.function), text: text)
1882:         
1883:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1884:         highlightStrings(attributed, text: text)
1885:         highlightNumbers(attributed, text: text)
1886:     }
1887:     
1888:     // MARK: - C/C++ Highlighting
1889:     
1890:     private func highlightCpp(_ attributed: NSMutableAttributedString, text: String) {
1891:         let keywords = ["auto", "break", "case", "catch", "class", "const", "continue", "default",
1892:                        "delete", "do", "else", "enum", "explicit", "extern", "for", "friend", "goto",
1893:                        "if", "inline", "mutable", "namespace", "new", "operator", "private", "protected",
1894:                        "public", "register", "return", "sizeof", "static", "struct", "switch", "template",
1895:                        "this", "throw", "try", "typedef", "typename", "union", "using", "virtual",
1896:                        "volatile", "while", "constexpr", "nullptr", "override", "final", "noexcept"]
1897:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1898:         
1899:         let types = ["void", "int", "long", "short", "char", "float", "double", "bool", "signed", "unsigned",
1900:                     "int8_t", "int16_t", "int32_t", "int64_t", "uint8_t", "uint16_t", "uint32_t", "uint64_t",
1901:                     "size_t", "string", "vector", "map", "set", "unique_ptr", "shared_ptr"]
1902:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1903:         
1904:         let constants = ["true", "false", "NULL", "nullptr"]
1905:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1906:         
1907:         // Preprocessor directives
1908:         let preprocPattern = "^\\s*#\\s*(include|define|ifdef|ifndef|endif|if|else|elif|pragma|error|warning).*$"
1909:         highlightPattern(attributed, pattern: preprocPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
1910:         
1911:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1912:         highlightStrings(attributed, text: text)
1913:         highlightNumbers(attributed, text: text)
1914:     }
1915:     
1916:     // MARK: - Ruby Highlighting
1917:     
1918:     private func highlightRuby(_ attributed: NSMutableAttributedString, text: String) {
1919:         let keywords = ["def", "class", "module", "if", "elsif", "else", "unless", "case", "when",
1920:                        "while", "until", "for", "do", "end", "begin", "rescue", "ensure", "raise",
1921:                        "return", "yield", "break", "next", "redo", "retry", "self", "super",
1922:                        "require", "require_relative", "include", "extend", "attr_reader", "attr_writer", "attr_accessor",
1923:                        "public", "private", "protected", "alias", "and", "or", "not", "in"]
1924:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1925:         
1926:         let constants = ["true", "false", "nil"]
1927:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1928:         
1929:         // Symbols (orange)
1930:         let symbolPattern = ":[a-zA-Z_][a-zA-Z0-9_]*"
1931:         highlightPattern(attributed, pattern: symbolPattern, color: UIColor(theme.string), text: text)
1932:         
1933:         // Instance variables (light blue)
1934:         let ivarPattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
1935:         highlightPattern(attributed, pattern: ivarPattern, color: UIColor(theme.variable), text: text)
1936:         
1937:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: "=begin", multiLineEnd: "=end")
1938:         highlightStrings(attributed, text: text)
1939:         highlightNumbers(attributed, text: text)
1940:     }
1941:     
1942:     // MARK: - PHP Highlighting
1943:     
1944:     private func highlightPHP(_ attributed: NSMutableAttributedString, text: String) {
1945:         let keywords = ["function", "class", "interface", "trait", "extends", "implements", "use",
1946:                        "public", "private", "protected", "static", "final", "abstract", "const",
1947:                        "if", "else", "elseif", "switch", "case", "default", "for", "foreach", "while", "do",
1948:                        "return", "break", "continue", "throw", "try", "catch", "finally",
1949:                        "new", "clone", "instanceof", "echo", "print", "die", "exit",
1950:                        "require", "require_once", "include", "include_once", "namespace"]
1951:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1952:         
1953:         let constants = ["true", "false", "null", "TRUE", "FALSE", "NULL"]
1954:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1955:         
1956:         // Variables (light blue)
1957:         let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
1958:         highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
1959:         
1960:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1961:         highlightStrings(attributed, text: text)
1962:         highlightNumbers(attributed, text: text)
1963:     }
1964:     
1965:     // MARK: - Shell Highlighting
1966:     
1967:     private func highlightShell(_ attributed: NSMutableAttributedString, text: String) {
1968:         let keywords = ["if", "then", "else", "elif", "fi", "for", "while", "do", "done", "case", "esac",
1969:                        "function", "return", "exit", "break", "continue", "local", "export", "readonly",
1970:                        "source", "alias", "unalias", "set", "unset", "shift", "eval", "exec",
1971:                        "echo", "printf", "read", "cd", "pwd", "ls", "mkdir", "rm", "cp", "mv"]
1972:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1973:         
1974:         // Variables (light blue)
1975:         let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*|\\$\\{[^}]+\\}"
1976:         highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
1977:         
1978:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1979:         highlightStrings(attributed, text: text)
1980:         highlightNumbers(attributed, text: text)
1981:     }
1982:     
1983:     // MARK: - YAML Highlighting
1984:     
1985:     private func highlightYAML(_ attributed: NSMutableAttributedString, text: String) {
1986:         // Keys (light blue)
1987:         let keyPattern = "^\\s*([a-zA-Z_][a-zA-Z0-9_-]*)\\s*:"
1988:         highlightPattern(attributed, pattern: keyPattern, color: UIColor(theme.variable), text: text, options: .anchorsMatchLines, captureGroup: 1)
1989:         
1990:         // Booleans and null
1991:         let constants = ["true", "false", "yes", "no", "on", "off", "null", "~"]
1992:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1993:         
1994:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1995:         highlightStrings(attributed, text: text)
1996:         highlightNumbers(attributed, text: text)
1997:     }
1998:     
1999:     // MARK: - SQL Highlighting
2000:     
2001:     private func highlightSQL(_ attributed: NSMutableAttributedString, text: String) {
2002:         let keywords = ["SELECT", "FROM", "WHERE", "AND", "OR", "NOT", "IN", "LIKE", "BETWEEN",
2003:                        "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE", "CREATE", "ALTER", "DROP",
2004:                        "TABLE", "INDEX", "VIEW", "DATABASE", "SCHEMA", "PRIMARY", "KEY", "FOREIGN", "REFERENCES",
2005:                        "JOIN", "INNER", "LEFT", "RIGHT", "OUTER", "FULL", "ON", "AS", "DISTINCT",
2006:                        "ORDER", "BY", "ASC", "DESC", "GROUP", "HAVING", "LIMIT", "OFFSET", "UNION",
2007:                        "NULL", "IS", "TRUE", "FALSE", "CASE", "WHEN", "THEN", "ELSE", "END",
2008:                        "COUNT", "SUM", "AVG", "MIN", "MAX", "COALESCE", "CAST",
2009:                        "select", "from", "where", "and", "or", "not", "in", "like", "between",
2010:                        "insert", "into", "values", "update", "set", "delete", "create", "alter", "drop",
2011:                        "table", "index", "view", "database", "schema", "primary", "key", "foreign", "references",
2012:                        "join", "inner", "left", "right", "outer", "full", "on", "as", "distinct",
2013:                        "order", "by", "asc", "desc", "group", "having", "limit", "offset", "union",
2014:                        "null", "is", "true", "false", "case", "when", "then", "else", "end"]
2015:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2016:         
2017:         let types = ["INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT", "FLOAT", "DOUBLE", "DECIMAL",
2018:                     "VARCHAR", "CHAR", "TEXT", "BLOB", "DATE", "TIME", "DATETIME", "TIMESTAMP", "BOOLEAN",
2019:                     "int", "integer", "bigint", "smallint", "tinyint", "float", "double", "decimal",
2020:                     "varchar", "char", "text", "blob", "date", "time", "datetime", "timestamp", "boolean"]
2021:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
2022:         
2023:         highlightComments(attributed, text: text, singleLine: "--", multiLineStart: "/*", multiLineEnd: "*/")
2024:         highlightStrings(attributed, text: text)
2025:         highlightNumbers(attributed, text: text)
2026:     }
2027:     
2028:     // MARK: - GraphQL Highlighting
2029:     
2030:     private func highlightGraphQL(_ attributed: NSMutableAttributedString, text: String) {
2031:         // Keywords
2032:         let keywords = ["query", "mutation", "subscription", "fragment", "on", "type", 
2033:                        "interface", "union", "enum", "scalar", "input", "extend", 
2034:                        "directive", "schema", "implements"]
2035:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2036:         
2037:         // Built-in scalar types
2038:         let types = ["Int", "Float", "String", "Boolean", "ID"]
2039:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
2040:         
2041:         // Variables ($name)
2042:         let variablePattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
2043:         highlightPattern(attributed, pattern: variablePattern, color: UIColor(theme.variable), text: text)
2044:         
2045:         // Directives (@deprecated, @skip, @include, etc.)
2046:         let directivePattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
2047:         highlightPattern(attributed, pattern: directivePattern, color: UIColor(theme.function), text: text)
2048:         
2049:         // Comments (# single line)
2050:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
2051:         
2052:         // Strings
2053:         highlightStrings(attributed, text: text)
2054:         
2055:         // Numbers
2056:         highlightNumbers(attributed, text: text)
2057:     }
2058:     
2059:     // MARK: - Helper Methods
2060:     
2061:     private func highlightKeywords(_ attributed: NSMutableAttributedString, keywords: [String], color: UIColor, text: String) {
2062:         for keyword in keywords {
2063:             let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
2064:             highlightPattern(attributed, pattern: pattern, color: color, text: text)
2065:         }
2066:     }
2067:     
2068:     private func highlightPattern(_ attributed: NSMutableAttributedString, pattern: String, color: UIColor, text: String, options: NSRegularExpression.Options = [], captureGroup: Int = 0) {
2069:         guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
2070:         let range = NSRange(location: 0, length: text.utf16.count)
2071:         
2072:         regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
2073:             guard let match = match else { return }
2074:             let matchRange = captureGroup > 0 && match.numberOfRanges > captureGroup
2075:                 ? match.range(at: captureGroup)
2076:                 : match.range
2077:             if matchRange.location != NSNotFound {
2078:                 attributed.addAttribute(.foregroundColor, value: color, range: matchRange)
2079:             }
2080:         }
2081:     }
2082:     
2083:     private func highlightStrings(_ attributed: NSMutableAttributedString, text: String) {
2084:         // Double-quoted strings
2085:         let doublePattern = "\"(?:[^\"\\\\]|\\\\.)*\""
2086:         highlightPattern(attributed, pattern: doublePattern, color: UIColor(theme.string), text: text)
2087:         
2088:         // Single-quoted strings
2089:         let singlePattern = "'(?:[^'\\\\]|\\\\.)*'"
2090:         highlightPattern(attributed, pattern: singlePattern, color: UIColor(theme.string), text: text)
2091:     }
2092:     
2093:     private func highlightPythonStrings(_ attributed: NSMutableAttributedString, text: String) {
2094:         // Triple-quoted strings first
2095:         let tripleDoublePattern = "\"\"\"[\\s\\S]*?\"\"\""
2096:         highlightPattern(attributed, pattern: tripleDoublePattern, color: UIColor(theme.string), text: text)
2097:         
2098:         let tripleSinglePattern = "'''[\\s\\S]*?'''"
2099:         highlightPattern(attributed, pattern: tripleSinglePattern, color: UIColor(theme.string), text: text)
2100:         
2101:         // Then regular strings
2102:         highlightStrings(attributed, text: text)
2103:         
2104:         // F-strings (with expressions highlighted differently)
2105:         let fstringPattern = "f\"[^\"]*\"|f'[^']*'"
2106:         highlightPattern(attributed, pattern: fstringPattern, color: UIColor(theme.string), text: text)
2107:     }
2108:     
2109:     private func highlightJSTemplateLiterals(_ attributed: NSMutableAttributedString, text: String) {
2110:         // Template literals
2111:         let templatePattern = "`[^`]*`"
2112:         highlightPattern(attributed, pattern: templatePattern, color: UIColor(theme.string), text: text)
2113:     }
2114:     
2115:     private func highlightComments(_ attributed: NSMutableAttributedString, text: String, singleLine: String?, multiLineStart: String?, multiLineEnd: String?) {
2116:         // Single-line comments
2117:         if let single = singleLine {
2118:             let pattern = "\(NSRegularExpression.escapedPattern(for: single)).*$"
2119:             highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text, options: .anchorsMatchLines)
2120:         }
2121:         
2122:         // Multi-line comments
2123:         if let start = multiLineStart, let end = multiLineEnd {
2124:             let pattern = "\(NSRegularExpression.escapedPattern(for: start))[\\s\\S]*?\(NSRegularExpression.escapedPattern(for: end))"
2125:             highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
2126:         }
2127:     }
2128:     
2129:     private func highlightHTMLComments(_ attributed: NSMutableAttributedString, text: String) {
2130:         let pattern = "<!--[\\s\\S]*?-->"
2131:         highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
2132:     }
2133:     
2134:     private func highlightNumbers(_ attributed: NSMutableAttributedString, text: String) {
2135:         // Hex numbers
2136:         let hexPattern = "\\b0[xX][0-9a-fA-F]+\\b"
2137:         highlightPattern(attributed, pattern: hexPattern, color: UIColor(theme.number), text: text)
2138:         
2139:         // Binary numbers
2140:         let binPattern = "\\b0[bB][01]+\\b"
2141:         highlightPattern(attributed, pattern: binPattern, color: UIColor(theme.number), text: text)
2142:         
2143:         // Octal numbers
2144:         let octPattern = "\\b0[oO][0-7]+\\b"
2145:         highlightPattern(attributed, pattern: octPattern, color: UIColor(theme.number), text: text)
2146:         
2147:         // Decimal numbers (including floats and scientific notation)
2148:         let decPattern = "\\b\\d+\\.?\\d*([eE][+-]?\\d+)?\\b"
2149:         highlightPattern(attributed, pattern: decPattern, color: UIColor(theme.number), text: text)
2150:     }
2151: }


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1100, "end_line": 1400}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1101-1400 of 2151)
────────────────────────────────────────
1101:             }
1102: 
1103:             let indentLevel = spaces / tabSize
1104:             guard indentLevel > 0 else { return }
1105: 
1106:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
1107: 
1108:             for i in 1...indentLevel {
1109:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
1110:                 let startPoint = CGPoint(x: x, y: rect.minY)
1111:                 let endPoint = CGPoint(x: x, y: rect.maxY)
1112: 
1113:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
1114:                 context.setStrokeColor(stroke.cgColor)
1115: 
1116:                 context.move(to: startPoint)
1117:                 context.addLine(to: endPoint)
1118:                 context.strokePath()
1119:             }
1120:         }
1121:     }
1122:     
1123:     override var keyCommands: [UIKeyCommand]? {
1124:         // NOTE: Only define text-editing specific shortcuts here.
1125:         // App-level shortcuts (Cmd+B, Cmd+P, Cmd+N, Cmd+S, Cmd+W, Cmd+F, etc.)
1126:         // are defined in the Menus/ folder via SwiftUI's .keyboardShortcut().
1127:         // See: KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
1128:         // Defining them here AND in Menus/ causes duplicate conflicts.
1129:         
1130:         var commands = super.keyCommands ?? []
1131:         
1132:         // Peek Definition: Option+D (editor-specific, not in menus)
1133:         commands.append(UIKeyCommand(
1134:             input: "d",
1135:             modifierFlags: .alternate,
1136:             action: #selector(handlePeekDefinition)
1137:         ))
1138: 
1139:         // NOTE: Cmd+G (Go to Line) is defined in GoMenuCommands.swift - DO NOT ADD HERE
1140: 
1141:         // Tab: accept autocomplete if visible, else insert tab
1142:         commands.append(UIKeyCommand(
1143:             input: "\t",
1144:             modifierFlags: [],
1145:             action: #selector(handleTab)
1146:         ))
1147:         
1148:         // Escape: dismiss autocomplete/peek if visible
1149:         commands.append(UIKeyCommand(
1150:             input: UIKeyCommand.inputEscape,
1151:             modifierFlags: [],
1152:             action: #selector(handleEscape)
1153:         ))
1154:         
1155:         // Fold: Cmd+Opt+[
1156:         commands.append(UIKeyCommand(
1157:             input: "[",
1158:             modifierFlags: [.command, .alternate],
1159:             action: #selector(handleFold)
1160:         ))
1161:         
1162:         // Unfold: Cmd+Opt+]
1163:         commands.append(UIKeyCommand(
1164:             input: "]",
1165:             modifierFlags: [.command, .alternate],
1166:             action: #selector(handleUnfold)
1167:         ))
1168:         
1169:         // Toggle Terminal: Cmd+J (not in standard system menus, safe to define here)
1170:         let toggleTerminalCmd = UIKeyCommand(
1171:             input: "j",
1172:             modifierFlags: .command,
1173:             action: #selector(handleToggleTerminal),
1174:             discoverabilityTitle: "Toggle Panel"
1175:         )
1176:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
1177:         commands.append(toggleTerminalCmd)
1178:         
1179:         // AI Assistant: Cmd+Shift+A (not conflicting with system Select All which is Cmd+A)
1180:         commands.append(UIKeyCommand(
1181:             input: "a",
1182:             modifierFlags: [.command, .shift],
1183:             action: #selector(handleShowAIAssistant),
1184:             discoverabilityTitle: "AI Assistant"
1185:         ))
1186:         
1187:         return commands
1188:     }
1189:     
1190:     @objc func handlePeekDefinition() {
1191:         onPeekDefinition?()
1192:     }
1193: 
1194:     @objc func handleGoToLine() {
1195:         onGoToLine?()
1196:     }
1197: 
1198:     @objc func handleTab() {
1199:         if onAcceptAutocomplete?() == true {
1200:             return
1201:         }
1202:         insertText("\t")
1203:     }
1204:     
1205:     @objc func handleEscape() {
1206:         if onDismissAutocomplete?() == true {
1207:             return
1208:         }
1209:         onEscape?()
1210:     }
1211:     
1212:     @objc func handleFold() {
1213:         onFold?()
1214:     }
1215:     
1216:     @objc func handleUnfold() {
1217:         onUnfold?()
1218:     }
1219: 
1220:     // MARK: - Undo / Redo
1221: 
1222:     @objc func handleUndo() {
1223:         undoManager?.undo()
1224:     }
1225: 
1226:     @objc func handleRedo() {
1227:         undoManager?.redo()
1228:     }
1229:     
1230:     // MARK: - App-Level Shortcut Handlers
1231:     
1232:     @objc func handleShowCommandPalette() {
1233:         NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1234:     }
1235:     
1236:     @objc func handleToggleTerminal() {
1237:         NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1238:     }
1239:     
1240:     @objc func handleShowAIAssistant() {
1241:         NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1242:     }
1243:     
1244:     @objc func handleToggleSidebar() {
1245:         NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
1246:     }
1247:     
1248:     @objc func handleShowQuickOpen() {
1249:         NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
1250:     }
1251:     
1252:     @objc func handleNewFile() {
1253:         NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
1254:     }
1255:     
1256:     @objc func handleSaveFile() {
1257:         NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
1258:     }
1259:     
1260:     @objc func handleCloseTab() {
1261:         NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
1262:     }
1263:     
1264:     @objc func handleFind() {
1265:         NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
1266:     }
1267:     
1268:     @objc func handleZoomIn() {
1269:         NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
1270:     }
1271:     
1272:     @objc func handleZoomOut() {
1273:         NotificationCenter.default.post(name: NSNotification.Name("ZoomOut"), object: nil)
1274:     }
1275:     
1276:     // MARK: - Custom Actions
1277:     
1278:     @objc private func goToDefinition(_ sender: Any?) {
1279:         onGoToDefinition?()
1280:     }
1281:     
1282:     @objc private func peekDefinition(_ sender: Any?) {
1283:         onPeekDefinition?()
1284:     }
1285:     
1286:     @objc private func findReferences(_ sender: Any?) {
1287:         onFindReferences?()
1288:     }
1289:     
1290:     @objc private func formatDocument(_ sender: Any?) {
1291:         onFormatDocument?()
1292:     }
1293:     
1294:     @objc private func toggleComment(_ sender: Any?) {
1295:         onToggleComment?()
1296:     }
1297:     
1298:     // MARK: - Menu Support
1299:     
1300:     override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
1301:         // Enable custom actions
1302:         if action == #selector(goToDefinition(_:)) {
1303:             return onGoToDefinition != nil
1304:         }
1305:         if action == #selector(peekDefinition(_:)) {
1306:             return onPeekDefinition != nil
1307:         }
1308:         if action == #selector(findReferences(_:)) {
1309:             return onFindReferences != nil
1310:         }
1311:         if action == #selector(formatDocument(_:)) {
1312:             return onFormatDocument != nil
1313:         }
1314:         if action == #selector(toggleComment(_:)) {
1315:             return onToggleComment != nil
1316:         }
1317:         
1318:         return super.canPerformAction(action, withSender: sender)
1319:     }
1320:     
1321:     override func buildMenu(with builder: UIMenuBuilder) {
1322:         super.buildMenu(with: builder)
1323:         
1324:         guard builder.menu(for: .text) != nil else { return }
1325:         
1326:         // Create custom menu items
1327:         let goToDefinitionAction = UIAction(
1328:             title: "Go to Definition",
1329:             image: UIImage(systemName: "arrow.forward.circle"),
1330:             identifier: UIAction.Identifier("com.vscode.goToDefinition"),
1331:             handler: { [weak self] _ in
1332:                 self?.goToDefinition(nil)
1333:             }
1334:         )
1335:         
1336:         let peekDefinitionAction = UIAction(
1337:             title: "Peek Definition",
1338:             image: UIImage(systemName: "eye"),
1339:             identifier: UIAction.Identifier("com.vscode.peekDefinition"),
1340:             handler: { [weak self] _ in
1341:                 self?.peekDefinition(nil)
1342:             }
1343:         )
1344:         
1345:         let findReferencesAction = UIAction(
1346:             title: "Find All References",
1347:             image: UIImage(systemName: "magnifyingglass"),
1348:             identifier: UIAction.Identifier("com.vscode.findReferences"),
1349:             handler: { [weak self] _ in
1350:                 self?.findReferences(nil)
1351:             }
1352:         )
1353:         
1354:         let formatDocumentAction = UIAction(
1355:             title: "Format Document",
1356:             image: UIImage(systemName: "text.alignleft"),
1357:             identifier: UIAction.Identifier("com.vscode.formatDocument"),
1358:             handler: { [weak self] _ in
1359:                 self?.formatDocument(nil)
1360:             }
1361:         )
1362:         
1363:         let toggleCommentAction = UIAction(
1364:             title: "Toggle Comment",
1365:             image: UIImage(systemName: "text.quote"),
1366:             identifier: UIAction.Identifier("com.vscode.toggleComment"),
1367:             handler: { [weak self] _ in
1368:                 self?.toggleComment(nil)
1369:             }
1370:         )
1371:         
1372:         // Group custom actions
1373:         let customMenu = UIMenu(
1374:             title: "",
1375:             identifier: UIMenu.Identifier("com.vscode.customActions"),
1376:             options: [.displayInline],
1377:             children: [
1378:                 goToDefinitionAction,
1379:                 peekDefinitionAction,
1380:                 findReferencesAction,
1381:                 formatDocumentAction,
1382:                 toggleCommentAction
1383:             ]
1384:         )
1385:         
1386:         // Insert custom menu after standard edit menu
1387:         builder.insertChild(customMenu, atStartOfMenu: .text)
1388:     }
1389: }
1390: 
1391: // MARK: - VSCode-Style Syntax Highlighter
1392: 
1393: enum Language {
1394:     case swift
1395: 
1396:     case javascript
1397:     case typescript
1398:     case jsx
1399:     case tsx
1400: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 900, "end_line": 1100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 901-1100 of 2151)
────────────────────────────────────────
901: 
902:             // Candidate bracket location: char before caret, else at caret
903:             let candidateIndices: [Int] = [
904:                 caret - 1,
905:                 caret
906:             ].filter { $0 >= 0 && $0 < length }
907: 
908:             func isBracket(_ c: unichar) -> Bool {
909:                 c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
910:             }
911: 
912:             var bracketIndex: Int?
913:             var bracketChar: unichar = 0
914: 
915:             for idx in candidateIndices {
916:                 let c = nsText.character(at: idx)
917:                 if isBracket(c) {
918:                     bracketIndex = idx
919:                     bracketChar = c
920:                     break
921:                 }
922:             }
923: 
924:             guard let idx = bracketIndex else { return }
925: 
926:             // Define bracket pairs
927:             let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
928:             let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
929: 
930:             let theme = ThemeManager.shared.currentTheme
931:             let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
932: 
933:             var matchIndex: Int?
934: 
935:             if let close = openToClose[bracketChar] {
936:                 // Opening bracket: scan forward
937:                 var depth = 0
938:                 var i = idx + 1
939:                 while i < length {
940:                     let c = nsText.character(at: i)
941:                     if c == bracketChar {
942:                         depth += 1
943:                     } else if c == close {
944:                         if depth == 0 {
945:                             matchIndex = i
946:                             break
947:                         } else {
948:                             depth -= 1
949:                         }
950:                     }
951:                     i += 1
952:                 }
953:             } else if let open = closeToOpen[bracketChar] {
954:                 // Closing bracket: scan backward
955:                 var depth = 0
956:                 var i = idx - 1
957:                 while i >= 0 {
958:                     let c = nsText.character(at: i)
959:                     if c == bracketChar {
960:                         depth += 1
961:                     } else if c == open {
962:                         if depth == 0 {
963:                             matchIndex = i
964:                             break
965:                         } else {
966:                             depth -= 1
967:                         }
968:                     }
969:                     i -= 1
970:                 }
971:             }
972: 
973:             guard let match = matchIndex else { return }
974: 
975:             let r1 = NSRange(location: idx, length: 1)
976:             let r2 = NSRange(location: match, length: 1)
977: 
978:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
979:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
980: 
981:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
982:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
983: 
984:             bracketHighlightRanges = [r1, r2]
985:         }
986:     }
987: }
988: 
989: // Custom text view to handle key commands, indent guides, and line highlighting
990: class EditorTextView: MultiCursorTextView {
991:     var onPeekDefinition: (() -> Void)?
992:     var onEscape: (() -> Void)?
993:     var onGoToLine: (() -> Void)?
994:     
995:     // Custom action closures for context menu
996:     var onGoToDefinition: (() -> Void)?
997:     var onFindReferences: (() -> Void)?
998:     var onFormatDocument: (() -> Void)?
999:     var onToggleComment: (() -> Void)?
1000:     var onFold: (() -> Void)?
1001:     var onUnfold: (() -> Void)?
1002: 
1003:     // Autocomplete key handling hooks are inherited from MultiCursorTextView
1004:     
1005:     // FEAT-039 & FEAT-043
1006:     private var indentGuideColor: UIColor = .separator
1007:     private var activeIndentGuideColor: UIColor = .label
1008:     private var currentLineHighlightColor: UIColor = .clear
1009:     
1010:     override init(frame: CGRect, textContainer: NSTextContainer?) {
1011:         super.init(frame: frame, textContainer: textContainer)
1012:         setup()
1013:     }
1014:     
1015:     required init?(coder: NSCoder) {
1016:         super.init(coder: coder)
1017:         setup()
1018:     }
1019:     
1020:     private func setup() {
1021:         // Ensure we redraw when bounds/selection change
1022:         contentMode = .redraw
1023:     }
1024:     
1025:     func updateThemeColors(theme: Theme) {
1026:         self.indentGuideColor = UIColor(theme.indentGuide)
1027:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
1028:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
1029:         setNeedsDisplay()
1030:     }
1031:     
1032:     override func draw(_ rect: CGRect) {
1033:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
1034:             super.draw(rect)
1035:             return
1036:         }
1037:         
1038:         // 1. Draw Current Line Highlight (FEAT-043)
1039:         if let selectedRange = selectedTextRange {
1040:             // Get the line rect for the cursor position
1041:             let caretRect = self.caretRect(for: selectedRange.start)
1042:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
1043:             
1044:             context.setFillColor(currentLineHighlightColor.cgColor)
1045:             context.fill(lineRect)
1046:         }
1047:         
1048:         // 2. Draw Text (super implementation)
1049:         super.draw(rect)
1050:         
1051:         // 3. Draw Indent Guides (FEAT-039)
1052:         // We iterate visible lines and draw vertical lines for indentation
1053:         // Optimization: Only draw for visible range
1054: 
1055:         context.setLineWidth(1.0)
1056: 
1057:         // Respect editor tab size setting (default 4)
1058:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
1059:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
1060: 
1061:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
1062:         let indentWidth = spaceWidth * CGFloat(tabSize)
1063: 
1064:         // Determine active indent level for caret line (for indentGuideActive)
1065:         var activeIndentLevel: Int = 0
1066:         if let selected = selectedTextRange {
1067:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
1068:             let nsText = (self.text ?? "") as NSString
1069:             let safeLoc = min(max(0, caretPos), nsText.length)
1070:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
1071:             let caretLineText = nsText.substring(with: caretLineRange)
1072: 
1073:             var spaces = 0
1074:             for ch in caretLineText {
1075:                 if ch == " " { spaces += 1 }
1076:                 else if ch == "\t" { spaces += tabSize }
1077:                 else { break }
1078:             }
1079:             activeIndentLevel = spaces / tabSize
1080:         }
1081: 
1082:         // Iterate visible glyphs/lines
1083:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
1084:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
1085: 
1086:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
1087: 
1088:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
1089:             // Get text for this line
1090:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
1091:                   let text = self.text as NSString? else { return }
1092: 
1093:             let lineText = text.substring(with: range)
1094: 
1095:             // Calculate indentation level
1096:             var spaces = 0
1097:             for char in lineText {
1098:                 if char == " " { spaces += 1 }
1099:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
1100:                 else { break }


Let me search for the foldingManager property on EditorTextView and how it's set up.

>>>TOOL search
{"query": "var foldingManager", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:424: @ObservedObject private var foldingManager = CodeFoldingManager.shared
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:595: @ObservedObject var foldingManager: CodeFoldingManager
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:489: @ObservedObject private var foldingManager = CodeFoldingManager.shared


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 1-266 of 266)
────────────────────────────────────────
1: //  MultiCursorTextView.swift
2: //  VSCodeiPadOS
3: //
4: //  Custom UITextView subclass that supports multiple cursor display
5: //
6: 
7: import UIKit
8: import SwiftUI
9: 
10: /// Custom UITextView that displays multiple cursors
11: class MultiCursorTextView: UITextView {
12: 
13:     /// Reference to the editor core for multi-cursor state
14:     weak var editorCore: EditorCore?
15: 
16:     /// Autocomplete key handling hooks (return true if handled)
17:     var onAcceptAutocomplete: (() -> Bool)?
18:     var onDismissAutocomplete: (() -> Bool)?
19: 
20:     /// Layer for drawing additional cursors
21:     private var cursorLayers: [CALayer] = []
22: 
23:     /// Layer for drawing selection highlights for additional cursors
24:     private var selectionLayers: [CALayer] = []
25: 
26:     /// Timer for cursor blink animation
27:     private var blinkTimer: Timer?
28:     private var cursorVisible = true
29: 
30:     /// Cursor appearance
31:     private let cursorWidth: CGFloat = 2
32:     private let cursorColor = UIColor.systemBlue
33:     private let secondaryCursorColor = UIColor.systemCyan
34:     private let selectionColor = UIColor.systemBlue.withAlphaComponent(0.3)
35:     private let secondarySelectionColor = UIColor.systemCyan.withAlphaComponent(0.25)
36: 
37:     override init(frame: CGRect, textContainer: NSTextContainer?) {
38:         super.init(frame: frame, textContainer: textContainer)
39:         setupCursorBlinking()
40:     }
41: 
42:     required init?(coder: NSCoder) {
43:         super.init(coder: coder)
44:         setupCursorBlinking()
45:     }
46: 
47:     deinit {
48:         blinkTimer?.invalidate()
49:     }
50: 
51:     private func setupCursorBlinking() {
52:         blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
53:             self?.cursorVisible.toggle()
54:             self?.updateCursorVisibility()
55:         }
56:     }
57: 
58:     private func updateCursorVisibility() {
59:         let alpha: Float = cursorVisible ? 1.0 : 0.0
60:         cursorLayers.forEach { $0.opacity = alpha }
61:     }
62: 
63:     /// Updates the display of all cursors and selections
64:     func updateCursorDisplay() {
65:         // Remove existing cursor and selection layers
66:         cursorLayers.forEach { $0.removeFromSuperlayer() }
67:         cursorLayers.removeAll()
68:         selectionLayers.forEach { $0.removeFromSuperlayer() }
69:         selectionLayers.removeAll()
70: 
71:         guard let editorCore = editorCore else { return }
72:         let cursors = editorCore.multiCursorState.cursors
73: 
74:         // Only show additional cursors if we have multiple
75:         guard cursors.count > 1 else { return }
76: 
77:         // Draw each cursor (skip the primary one as UITextView handles it)
78:         for (index, cursor) in cursors.enumerated() {
79:             // Draw selection if present
80:             if let selectionRange = cursor.selectionRange {
81:                 drawSelection(for: selectionRange, isPrimary: cursor.isPrimary, index: index)
82:             }
83: 
84:             // Draw cursor line (skip primary cursor as system handles it)
85:             if !cursor.isPrimary {
86:                 drawCursor(at: cursor.position, isPrimary: false, index: index)
87:             }
88:         }
89:     }
90: 
91:     private func drawCursor(at position: Int, isPrimary: Bool, index: Int) {
92:         guard let textPosition = self.position(from: beginningOfDocument, offset: position) else { return }
93: 
94:         let caretRect = self.caretRect(for: textPosition)
95: 
96:         let cursorLayer = CALayer()
97:         cursorLayer.backgroundColor = (isPrimary ? cursorColor : secondaryCursorColor).cgColor
98:         cursorLayer.frame = CGRect(
99:             x: caretRect.origin.x,
100:             y: caretRect.origin.y,
101:             width: cursorWidth,
102:             height: caretRect.height
103:         )
104:         cursorLayer.cornerRadius = 1
105: 
106:         layer.addSublayer(cursorLayer)
107:         cursorLayers.append(cursorLayer)
108:     }
109: 
110:     private func drawSelection(for range: NSRange, isPrimary: Bool, index: Int) {
111:         guard let start = position(from: beginningOfDocument, offset: range.location),
112:               let end = position(from: beginningOfDocument, offset: range.location + range.length),
113:               let textRange = self.textRange(from: start, to: end) else { return }
114: 
115:         let selectionRects = selectionRects(for: textRange)
116: 
117:         for rect in selectionRects {
118:             let selectionLayer = CALayer()
119:             selectionLayer.backgroundColor = (isPrimary ? selectionColor : secondarySelectionColor).cgColor
120:             selectionLayer.frame = rect.rect
121: 
122:             // Insert behind text
123:             if let textLayer = layer.sublayers?.first {
124:                 layer.insertSublayer(selectionLayer, below: textLayer)
125:             } else {
126:                 layer.addSublayer(selectionLayer)
127:             }
128:             selectionLayers.append(selectionLayer)
129:         }
130:     }
131: 
132:     // MARK: - Text Input Handling for Multi-Cursor
133: 
134:     override func insertText(_ text: String) {
135:         guard let editorCore = editorCore,
136:               editorCore.multiCursorState.isMultiCursor else {
137:             super.insertText(text)
138:             return
139:         }
140: 
141:         // Handle multi-cursor insert
142:         var content = self.text ?? ""
143:         editorCore.multiCursorState.insertText(text, in: &content)
144: 
145:         // Update text view
146:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
147:         self.text = content
148: 
149:         // Position the main cursor
150:         if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
151:             selectedTextRange = textRange(from: newPosition, to: newPosition)
152:         }
153: 
154:         // Trigger text change notification
155:         delegate?.textViewDidChange?(self)
156: 
157:         updateCursorDisplay()
158:     }
159: 
160:     override func deleteBackward() {
161:         guard let editorCore = editorCore,
162:               editorCore.multiCursorState.isMultiCursor else {
163:             super.deleteBackward()
164:             return
165:         }
166: 
167:         // Handle multi-cursor delete
168:         var content = self.text ?? ""
169:         editorCore.multiCursorState.deleteBackward(in: &content)
170: 
171:         // Update text view
172:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
173:         self.text = content
174: 
175:         // Position the main cursor
176:         if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
177:             selectedTextRange = textRange(from: newPosition, to: newPosition)
178:         }
179: 
180:         // Trigger text change notification
181:         delegate?.textViewDidChange?(self)
182: 
183:         updateCursorDisplay()
184:     }
185: 
186:     // MARK: - Layout Updates
187: 
188:     override func layoutSubviews() {
189:         super.layoutSubviews()
190:         // Refresh cursor positions when layout changes
191:         updateCursorDisplay()
192:     }
193: 
194:     override var contentOffset: CGPoint {
195:         didSet {
196:             // Update cursor positions when scrolling
197:             updateCursorDisplay()
198:         }
199:     }
200: }
201: 
202: // MARK: - Key Commands for Multi-Cursor + Autocomplete
203: // NOTE: App-level shortcuts are defined in Menus/ folder only.
204: // See: KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
205: // DO NOT define Cmd+D, Cmd+Shift+L, Cmd+G here - they are in SelectionMenuCommands/GoMenuCommands
206: 
207: extension MultiCursorTextView {
208: 
209:     override var keyCommands: [UIKeyCommand]? {
210:         var commands = super.keyCommands ?? []
211: 
212:         // Tab: accept autocomplete (if showing), else insert tab
213:         // This is editor-specific and NOT a menu command
214:         commands.append(UIKeyCommand(
215:             title: "Accept Suggestion",
216:             action: #selector(tabAcceptAutocomplete),
217:             input: "\t",
218:             modifierFlags: []
219:         ))
220: 
221:         // NOTE: Cmd+D (Add Next Occurrence) is in SelectionMenuCommands.swift
222:         // NOTE: Cmd+Shift+L (Select All Occurrences) is in SelectionMenuCommands.swift
223:         // NOTE: Cmd+G (Go to Line) is in GoMenuCommands.swift
224: 
225:         // Escape: Dismiss autocomplete if visible, else exit multi-cursor mode
226:         // This is editor-specific and NOT a menu command
227:         commands.append(UIKeyCommand(
228:             title: "Escape",
229:             action: #selector(escapeKeyPressed),
230:             input: UIKeyCommand.inputEscape,
231:             modifierFlags: []
232:         ))
233: 
234:         return commands
235:     }
236: 
237:     @objc private func tabAcceptAutocomplete() {
238:         if onAcceptAutocomplete?() == true {
239:             return
240:         }
241:         insertText("\t")
242:     }
243: 
244:     @objc private func addNextOccurrence() {
245:         editorCore?.addNextOccurrence()
246:         updateCursorDisplay()
247:     }
248: 
249:     @objc private func selectAllOccurrences() {
250:         editorCore?.selectAllOccurrences()
251:         updateCursorDisplay()
252:     }
253: 
254:     @objc private func goToLine() {
255:         editorCore?.showGoToLine = true
256:     }
257: 
258:     @objc private func escapeKeyPressed() {
259:         if onDismissAutocomplete?() == true {
260:             return
261:         }
262:         editorCore?.escapeMultiCursor()
263:         updateCursorDisplay()
264:     }
265: }
266: 


Now I see the key issue. Let me check if `EditorTextView` has a `foldingManager` property and a `fileId` property (which are referenced in `FoldingLayoutManager`).

>>>TOOL search
{"query": "fileId", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 30 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:265: if let fileId = currentFileId {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:266: foldRegionsByFile[fileId] = regions
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:518: if let fileId = currentFileId, let storedRegions = foldRegionsByFile[fileId] {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:728: func isLineFolded(fileId: String, line: Int) -> Bool {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:729: guard let regions = foldRegionsByFile[fileId] else { return false }
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:756: func isFoldable(fileId: String, line: Int) -> Bool {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:757: guard let regions = foldRegionsByFile[fileId] else { return false }
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:762: func isFolded(fileId: String, line: Int) -> Bool {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:763: guard let regions = foldRegionsByFile[fileId] else { return false }
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:768: func toggleFold(fileId: String, line: Int) {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:769: guard var regions = foldRegionsByFile[fileId] else { return }
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:773: foldRegionsByFile[fileId] = regions
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:776: if fileId == currentFileId {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:785: saveFoldState(for: fileId)
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:790: func getFoldRegions(for fileId: String) -> [FoldRegion] {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:791: return foldRegionsByFile[fileId] ?? []
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:795: func clearFoldRegions(for fileId: String) {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:796: foldRegionsByFile.removeValue(forKey: fileId)
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:176: let fileId = canonicalFileId(file)
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:178: return breakpointsByFile[fileId]?.contains(line) == true
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:182: let fileId = canonicalFileId(file)
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:187: var set = dict[fileId] ?? []
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:196: dict.removeValue(forKey: fileId)
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:198: dict[fileId] = set
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:217: let fileId = canonicalFileId(file)
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:221: guard var set = dict[fileId] else { return }
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:225: dict.removeValue(forKey: fileId)
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:227: dict[fileId] = set
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:233: let fileId = canonicalFileId(file)
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:234: let lines = breakpointsByFile[fileId] ?? []


Let me look at the EditorTextView class more closely to check if it has the foldingManager and fileId properties.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 989, "end_line": 1050}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 990-1050 of 2151)
────────────────────────────────────────
990: class EditorTextView: MultiCursorTextView {
991:     var onPeekDefinition: (() -> Void)?
992:     var onEscape: (() -> Void)?
993:     var onGoToLine: (() -> Void)?
994:     
995:     // Custom action closures for context menu
996:     var onGoToDefinition: (() -> Void)?
997:     var onFindReferences: (() -> Void)?
998:     var onFormatDocument: (() -> Void)?
999:     var onToggleComment: (() -> Void)?
1000:     var onFold: (() -> Void)?
1001:     var onUnfold: (() -> Void)?
1002: 
1003:     // Autocomplete key handling hooks are inherited from MultiCursorTextView
1004:     
1005:     // FEAT-039 & FEAT-043
1006:     private var indentGuideColor: UIColor = .separator
1007:     private var activeIndentGuideColor: UIColor = .label
1008:     private var currentLineHighlightColor: UIColor = .clear
1009:     
1010:     override init(frame: CGRect, textContainer: NSTextContainer?) {
1011:         super.init(frame: frame, textContainer: textContainer)
1012:         setup()
1013:     }
1014:     
1015:     required init?(coder: NSCoder) {
1016:         super.init(coder: coder)
1017:         setup()
1018:     }
1019:     
1020:     private func setup() {
1021:         // Ensure we redraw when bounds/selection change
1022:         contentMode = .redraw
1023:     }
1024:     
1025:     func updateThemeColors(theme: Theme) {
1026:         self.indentGuideColor = UIColor(theme.indentGuide)
1027:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
1028:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
1029:         setNeedsDisplay()
1030:     }
1031:     
1032:     override func draw(_ rect: CGRect) {
1033:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
1034:             super.draw(rect)
1035:             return
1036:         }
1037:         
1038:         // 1. Draw Current Line Highlight (FEAT-043)
1039:         if let selectedRange = selectedTextRange {
1040:             // Get the line rect for the cursor position
1041:             let caretRect = self.caretRect(for: selectedRange.start)
1042:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
1043:             
1044:             context.setFillColor(currentLineHighlightColor.cgColor)
1045:             context.fill(lineRect)
1046:         }
1047:         
1048:         // 2. Draw Text (super implementation)
1049:         super.draw(rect)
1050:         


Now I've found the critical issue! The `FoldingLayoutManager` expects `EditorTextView` to have `foldingManager` and `fileId` properties (lines 27-29), but the `EditorTextView` class (lines 990-1050) doesn't have these properties!

Let me verify there are no other definitions of these properties:

>>>TOOL search
{"query": "owner.foldingManager", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "owner.foldingManager"


>>>TOOL search
{"query": "ownerTextView", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:7: weak var ownerTextView: EditorTextView?
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:27: guard let owner = ownerTextView,


Now let me check if FoldingLayoutManager is ever instantiated or connected to any text view:

>>>TOOL search
{"query": "FoldingLayoutManager()", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "FoldingLayoutManager()"


Now I need to check how folding works in ContentView and see how it's integrated with the editor.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 580, "end_line": 700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 581-700 of 1079)
────────────────────────────────────────
581:     }
582:     
583:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
584: }
585: 
586: // MARK: - Line Numbers with Folding
587: 
588: struct LineNumbersWithFolding: View {
589:     let fileId: String
590:     let totalLines: Int
591:     let currentLine: Int
592:     let scrollOffset: CGFloat
593:     let lineHeight: CGFloat
594:     @Binding var requestedLineSelection: Int?
595:     @ObservedObject var foldingManager: CodeFoldingManager
596:     @ObservedObject private var debugManager = DebugManager.shared
597:     let theme: Theme
598: 
599:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
600: 
601:     var body: some View {
602:         ScrollView(showsIndicators: false) {
603:             VStack(alignment: .trailing, spacing: 0) {
604:                 // Match UITextView.textContainerInset.top (see SyntaxHighlightingTextView.swift)
605:                 // so line numbers stay vertically aligned with the first line of text.
606:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
607:                     if !foldingManager.isLineFolded(line: lineIndex) {
608:                         HStack(spacing: 2) {
609:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
610:                                 Circle()
611:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
612:                                     .overlay(
613:                                         Circle()
614:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
615:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
616:                                     )
617:                                     .frame(width: 10, height: 10)
618:                                     .padding(.leading, 2)
619:                             }
620:                             .buttonStyle(.plain)
621:                             .frame(width: 14, height: lineHeight)
622: 
623:                             if foldingManager.isFoldable(line: lineIndex) {
624:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
625:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
626:                                         .font(.system(size: 8))
627:                                         .foregroundColor(theme.lineNumber)
628:                                 }
629:                                 .buttonStyle(.plain)
630:                                 .frame(width: 14, height: lineHeight)
631:                             } else {
632:                                 Spacer().frame(width: 14)
633:                             }
634: 
635:                             Text(displayText(for: lineIndex))
636:                                 .font(.system(size: 12, design: .monospaced))
637:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
638:                                 .frame(height: lineHeight)
639:                                 .contentShape(Rectangle())
640:                                 .onTapGesture {
641:                                     // FEAT-041: click line number selects entire line
642:                                     requestedLineSelection = lineIndex
643:                                 }
644:                         }
645:                         .frame(maxWidth: .infinity, alignment: .trailing)
646:                         .padding(.trailing, 4)
647:                     }
648:                 }
649:             }
650:             .padding(.top, 8)
651:             .offset(y: -scrollOffset)
652:         }
653:         .scrollDisabled(true)
654:     }
655: 
656:     private func displayText(for lineIndex: Int) -> String {
657:         switch lineNumbersStyle {
658:         case "relative":
659:             // VS Code-style: current line shows absolute, others show relative distance
660:             let lineNumber = lineIndex + 1
661:             if lineNumber == currentLine { return "\(lineNumber)" }
662:             return "\(abs(lineNumber - currentLine))"
663: 
664:         case "interval":
665:             let lineNumber = lineIndex + 1
666:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
667: 
668:         default:
669:             return "\(lineIndex + 1)"
670:         }
671:     }
672: }
673: 
674: // MARK: - Autocomplete Popup
675: 
676: struct AutocompletePopup: View {
677:     let suggestions: [AutocompleteSuggestion]
678:     let selectedIndex: Int
679:     let theme: Theme
680:     let onSelectIndex: (Int) -> Void
681:     
682:     var body: some View {
683:         VStack(alignment: .leading, spacing: 0) {
684:             ForEach(suggestions.indices, id: \.self) { index in
685:                 let s = suggestions[index]
686:                 HStack(spacing: 6) {
687:                     Image(systemName: icon(for: s.kind))
688:                         .font(.caption)
689:                         .foregroundColor(color(for: s.kind))
690:                     VStack(alignment: .leading, spacing: 1) {
691:                         Text(s.displayText)
692:                             .font(.system(size: 12, design: .monospaced))
693:                             .foregroundColor(theme.editorForeground)
694:                         if s.insertText != s.displayText && !s.insertText.isEmpty {
695:                             Text(s.insertText)
696:                                 .font(.system(size: 10, design: .monospaced))
697:                                 .foregroundColor(theme.editorForeground.opacity(0.55))
698:                                 .lineLimit(1)
699:                         }
700:                     }


Now I understand the problem. Let me look at how folding state is connected to the actual text rendering:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 420, "end_line": 520}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 421-520 of 1079)
────────────────────────────────────────
421: 
422:     @StateObject private var autocomplete = AutocompleteManager()
423:     @State private var showAutocomplete = false
424:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
425:     @StateObject private var findViewModel = FindViewModel()
426:     
427:     var body: some View {
428:         VStack(spacing: 0) {
429:             // Find/Replace bar
430:             if editorCore.showSearch {
431:                 FindReplaceView(viewModel: findViewModel)
432:                     .background(theme.tabBarBackground)
433:             }
434:             
435:             BreadcrumbsView(editorCore: editorCore, tab: tab)
436:             
437:             GeometryReader { geometry in
438:                 ZStack(alignment: .topLeading) {
439:                 HStack(spacing: 0) {
440:                     if lineNumbersStyle != "off" {
441:                         LineNumbersWithFolding(
442:                             fileId: tab.url?.path ?? tab.fileName,
443:                             totalLines: totalLines,
444:                             currentLine: currentLineNumber,
445:                             scrollOffset: scrollOffset,
446:                             lineHeight: lineHeight,
447:                             requestedLineSelection: $requestedLineSelection,
448:                             foldingManager: foldingManager,
449:                             theme: theme
450:                         )
451:                         .frame(width: 60)
452:                         .background(theme.sidebarBackground.opacity(0.5))
453:                     }
454:                     
455:                     if tab.fileName.hasSuffix(".json") {
456:                         // JSON Tree View for .json files
457:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
458:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
459:                             .background(theme.editorBackground)
460:                     } else {
461:                         SyntaxHighlightingTextView(
462:                             text: $text,
463:                             filename: tab.fileName,
464:                             scrollPosition: $scrollPosition,
465:                             scrollOffset: $scrollOffset,
466:                             totalLines: $totalLines,
467:                             visibleLines: $visibleLines,
468:                             currentLineNumber: $currentLineNumber,
469:                             currentColumn: $currentColumn,
470:                             cursorIndex: $cursorIndex,
471:                             lineHeight: $lineHeight,
472:                             isActive: true,
473:                             fontSize: editorCore.editorFontSize,
474:                             requestedLineSelection: $requestedLineSelection,
475:                             requestedCursorIndex: $requestedCursorIndex,
476:                             onAcceptAutocomplete: {
477:                                 guard showAutocomplete else { return false }
478:                                 var tempText = text
479:                                 var tempCursor = cursorIndex
480:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
481:                                 if tempText != text {
482:                                     text = tempText
483:                                     cursorIndex = tempCursor
484:                                     requestedCursorIndex = tempCursor
485:                                     showAutocomplete = false
486:                                     return true
487:                                 }
488:                                 return false
489:                             },
490:                             onDismissAutocomplete: {
491:                                 guard showAutocomplete else { return false }
492:                                 autocomplete.hideSuggestions()
493:                                 showAutocomplete = false
494:                                 return true
495:                             }
496:                         )
497:                         .onChange(of: text) { newValue in
498:                             editorCore.updateActiveTabContent(newValue)
499:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
500:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
501:                             showAutocomplete = autocomplete.showSuggestions
502:                             foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path ?? tab.fileName)
503:                         }
504:                         .onChange(of: cursorIndex) { newCursor in
505:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
506:                             showAutocomplete = autocomplete.showSuggestions
507:                         }
508:                     }
509:                     
510:                     if !tab.fileName.hasSuffix(".json") {
511:                         MinimapView(
512:                             content: text,
513:                             scrollOffset: scrollOffset,
514:                             scrollViewHeight: geometry.size.height,
515:                             totalContentHeight: CGFloat(totalLines) * lineHeight,
516:                             onScrollRequested: { newOffset in
517:                                 // Minimap requested scroll - update editor position
518:                                 scrollOffset = newOffset
519:                                 // Convert back from pixels to line number
520:                                 let newLine = Int(newOffset / max(lineHeight, 1))


Now I have a clear picture. Let me check how the text view is created to confirm the layout manager setup:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 110, "end_line": 200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 111-200 of 2151)
────────────────────────────────────────
111:         Coordinator(self)
112:     }
113:     
114:     func makeUIView(context: Context) -> UITextView {
115:         let textView = EditorTextView()
116:         textView.delegate = context.coordinator
117:         textView.editorCore = editorCore
118: 
119:         // Autocomplete hooks
120:         textView.onAcceptAutocomplete = onAcceptAutocomplete
121:         textView.onDismissAutocomplete = onDismissAutocomplete
122: 
123:         textView.onPeekDefinition = {
124:             context.coordinator.handlePeekDefinition(in: textView)
125:         }
126: 
127:         textView.onEscape = {
128:             context.coordinator.handleEscape()
129:         }
130: 
131:         textView.onGoToLine = {
132:             self.editorCore.showGoToLine = true
133:         }
134:         
135:         // Wire up custom context menu actions
136:         textView.onGoToDefinition = {
137:             context.coordinator.handleGoToDefinition(in: textView)
138:         }
139:         
140:         textView.onFindReferences = {
141:             context.coordinator.handleFindReferences(in: textView)
142:         }
143:         
144:         textView.onFormatDocument = {
145:             context.coordinator.handleFormatDocument(in: textView)
146:         }
147:         
148:         textView.onToggleComment = {
149:             context.coordinator.handleToggleComment(in: textView)
150:         }
151:         
152:         textView.onFold = {
153:             context.coordinator.handleFold(in: textView)
154:         }
155:         
156:         textView.onUnfold = {
157:             context.coordinator.handleUnfold(in: textView)
158:         }
159:         
160:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
161:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
162:         pinchGesture.delegate = context.coordinator
163:         textView.addGestureRecognizer(pinchGesture)
164:         context.coordinator.pinchGesture = pinchGesture
165:         
166:         // Configure text view
167:         textView.isEditable = true
168:         textView.isSelectable = true
169:         textView.autocapitalizationType = .none
170:         textView.autocorrectionType = .no
171:         textView.smartDashesType = .no
172:         textView.smartQuotesType = .no
173:         textView.smartInsertDeleteType = .no
174:         textView.spellCheckingType = .no
175:         
176:         // Set font and appearance (use editorCore.editorFontSize)
177:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
178:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
179:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
180:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
181:         textView.keyboardType = .default
182:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
183:         
184:         // Enable line wrapping
185:         textView.textContainer.lineBreakMode = .byCharWrapping
186:         textView.textContainer.widthTracksTextView = true
187:         
188:         // Calculate line height
189:         if let font = textView.font {
190:             DispatchQueue.main.async {
191:                 self.lineHeight = font.lineHeight
192:             }
193:         }
194:         
195:         // Set initial text with syntax highlighting
196:         textView.text = text
197:         context.coordinator.applySyntaxHighlighting(to: textView)
198:         context.coordinator.updateLineCount(textView)
199:         
200:         return textView


Now let me look at how the fold/unfold handlers work in the Coordinator:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 780, "end_line": 900}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 781-900 of 2151)
────────────────────────────────────────
781:             guard let selectedRange = textView.selectedTextRange else { return }
782:             let text = textView.text ?? ""
783:             
784:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
785:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
786:                 
787:                 let prefix = String(text.prefix(location))
788:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
789:                 
790:                 // TODO: Implement find references functionality in EditorCore
791:                 // For now, just trigger peek definition as a placeholder
792:                 parent.editorCore.triggerPeekDefinition(
793:                     file: parent.filename,
794:                     line: sourceLine,
795:                     content: text,
796:                     sourceLine: sourceLine
797:                 )
798:             }
799:         }
800:         
801:         func handleFormatDocument(in textView: UITextView) {
802:             // TODO: Implement format document functionality
803:             // This would typically call a formatter in EditorCore
804:             print("Format Document: Not yet implemented")
805:         }
806:         
807:         func handleToggleComment(in textView: UITextView) {
808:             guard let selectedRange = textView.selectedTextRange else { return }
809:             let text = textView.text ?? ""
810:             
811:             // Get the current line range
812:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
813:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
814:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
815:                 let nsRange = NSRange(location: location, length: length)
816:                 
817:                 if nsRange.location + nsRange.length <= (text as NSString).length {
818:                     let lineText = (text as NSString).substring(with: nsRange)
819:                     let trimmed = lineText.trimmingCharacters(in: .whitespaces)
820:                     
821:                     // Check if line starts with a comment
822:                     let isCommented = trimmed.hasPrefix("//") || trimmed.hasPrefix("#") || trimmed.hasPrefix("/*")
823:                     
824:                     // Toggle comment
825:                     var newLineText: String
826:                     if isCommented {
827:                         // Remove comment
828:                         newLineText = lineText.replacingOccurrences(of: "//", with: "").replacingOccurrences(of: "#", with: "", options: .anchored)
829:                     } else {
830:                         // Add comment (use // for most languages)
831:                         newLineText = "//" + lineText
832:                     }
833:                     
834:                     // Replace the line
835:                     let textStorage = textView.textStorage
836:                     textStorage.replaceCharacters(in: nsRange, with: newLineText)
837:                     
838:                     // Update parent binding
839:                     parent.text = textView.text
840:                 }
841:             }
842:         }
843:         
844:         func handleFold(in textView: UITextView) {
845:             CodeFoldingManager.shared.foldCurrentLine()
846:         }
847:         
848:         func handleUnfold(in textView: UITextView) {
849:             CodeFoldingManager.shared.unfoldCurrentLine()
850:         }
851:         
852:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
853:             guard let textView = gesture.view as? UITextView else { return }
854: 
855:             switch gesture.state {
856:             case .began:
857:                 // Store the initial font size when pinch begins
858:                 initialFontSize = parent.editorCore.editorFontSize
859: 
860:             case .changed:
861:                 // Calculate new font size based on pinch scale
862:                 let newSize = initialFontSize * gesture.scale
863: 
864:                 // Clamp font size between 8 and 32
865:                 let clampedSize = min(max(newSize, 8), 32)
866: 
867:                 // Update EditorCore's font size (this will trigger updateUIView)
868:                 parent.editorCore.editorFontSize = clampedSize
869: 
870:             case .ended, .cancelled:
871:                 // Optional: snap to nearest whole number or standard size
872:                 let finalSize = round(parent.editorCore.editorFontSize)
873:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
874: 
875:             default:
876:                 break
877:             }
878:         }
879: 
880:         // MARK: - FEAT-044 Matching Bracket Highlight
881: 
882:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
883:             // Clear any existing highlights
884:             if !bracketHighlightRanges.isEmpty {
885:                 for r in bracketHighlightRanges {
886:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
887:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
888:                 }
889:                 bracketHighlightRanges.removeAll()
890:             }
891: 
892:             // Only highlight when there's a caret (no selection)
893:             let selection = textView.selectedRange
894:             guard selection.length == 0 else { return }
895: 
896:             let nsText = (textView.text ?? "") as NSString
897:             let length = nsText.length
898:             guard length > 0 else { return }
899: 
900:             let caret = selection.location


⛔ ABORTED by user



⛔ ABORTED by user
