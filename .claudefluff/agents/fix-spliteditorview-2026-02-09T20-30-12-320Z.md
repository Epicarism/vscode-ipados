# Agent: fix-spliteditorview
**Status:** done
**Tokens:** 1,558
**Cost:** $0.0000
**Time:** 2026-02-09T20:30:12.320Z

## Task
Fix VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift line 489:
- type 'CodeFoldingManager' has no member 'shared'

Check CodeFoldingManager.swift to see if it has a shared singleton. If not, either:
1. Add 'static let shared = CodeFoldingManager()' to CodeFoldingManager
2. Or change the call to create a new instance

## Response
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":450,"end_line":520}
>>>END

>>>TOOL search
{"query":"class CodeFoldingManager", "glob":"VSCodeiPadOS/**"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:68: class CodeFoldingManager: ObservableObject {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":460,"end_line":510}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":1,"end_line":140}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 461-510 of 774)
────────────────────────────────────────
461:             return NSItemProvider(object: tab.id.uuidString as NSString)
462:         }
463:         .contextMenu {
464:             Button(action: { pane.closeTab(id: tab.id) }) {
465:                 Label("Close", systemImage: "xmark")
466:             }
467:             
468:             Divider()
469:             
470:             Button(action: { splitManager.moveTabToNewSplit(tab: tab, fromPaneId: pane.id, direction: .horizontal) }) {
471:                 Label("Move to Split Right", systemImage: "rectangle.split.2x1")
472:             }
473:             
474:             Button(action: { splitManager.moveTabToNewSplit(tab: tab, fromPaneId: pane.id, direction: .vertical) }) {
475:                 Label("Move to Split Down", systemImage: "rectangle.split.1x2")
476:             }
477:         }
478:     }
479: }
480: 
481: // MARK: - Pane Editor View
482: 
483: struct PaneEditorView: View {
484:     @ObservedObject var pane: EditorPane
485:     let tab: Tab
486:     @ObservedObject var splitManager: SplitEditorManager
487:     @ObservedObject var editorCore: EditorCore
488:     @ObservedObject private var debugManager = DebugManager.shared
489:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
490:     @State private var text: String = ""
491:     @State private var scrollPosition: Int = 0
492:     @State private var totalLines: Int = 1
493:     @State private var visibleLines: Int = 20
494:     @State private var currentLineNumber: Int = 1
495:     @State private var currentColumn: Int = 1
496:     @State private var lineHeight: CGFloat = 17
497:     @State private var requestedLineSelection: Int? = nil
498: 
499:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
500:     
501:     private var fileId: String { tab.url?.path ?? tab.fileName }
502:     
503:     var body: some View {
504:         GeometryReader { geometry in
505:             HStack(spacing: 0) {
506:                 // Line numbers + breakpoints + code folding (gutter)
507:                 //
508:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
509:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
510:                 if lineNumbersStyle != "off" {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 2-140 of 809)
────────────────────────────────────────
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
69:     @Published var foldRegions: [FoldRegion] = []
70:     @Published var collapsedLines: Set<Int> = []
71:     
72:     // Dictionary to manage fold regions per file
73:     private var foldRegionsByFile: [String: [FoldRegion]] = [:]
74:     
75:     private var currentFilePath: String?
76:     private var currentFileId: String?
77:     
78:     // MARK: - Enhanced Fold Detection
79:     
80:     /// Detects all foldable regions in the given code
81:     func detectFoldableRegions(in code: String, filePath: String? = nil) {
82:         self.currentFilePath = filePath
83:         self.currentFileId = filePath
84:         
85:         let lines = code.components(separatedBy: .newlines)
86:         var regions: [FoldRegion] = []
87:         
88:         // Track different types of blocks
89:         var blockStack: [(type: FoldRegion.FoldType, startLine: Int, label: String?)] = []
90:         var commentStack: [(startLine: Int, isMultiline: Bool)] = []
91:         var regionStack: [(startLine: Int, label: String)] = []
92:         
93:         for (index, line) in lines.enumerated() {
94:             let trimmed = line.trimmingCharacters(in: .whitespaces)
95:             let leadingWhitespace = line.prefix { $0 == " " || $0 == "\t" }.count
96:             
97:             // Skip empty lines for most detections
98:             guard !trimmed.isEmpty else { continue }
99:             
100:             // MARK: - Region Detection (#region, #pragma mark, MARK:)
101:             if detectRegionStart(trimmed) != nil {
102:                 if let label = detectRegionStart(trimmed) {
103:                     regionStack.append((index, label))
104:                 }
105:             } else if detectRegionEnd(trimmed) {
106:                 if let region = regionStack.popLast() {
107:                     if index - region.startLine > 1 {
108:                         regions.append(FoldRegion(
109:                             startLine: region.startLine,
110:                             endLine: index,
111:                             type: .region,
112:                             label: region.label
113:                         ))
114:                     }
115:                 }
116:             }
117:             
118:             // MARK: - Import Statement Detection
119:             if trimmed.hasPrefix("import ") {
120:                 // Group consecutive imports
121:                 let importEnd = findConsecutiveImports(from: index, in: lines)
122:                 if importEnd > index {
123:                     regions.append(FoldRegion(
124:                         startLine: index,
125:                         endLine: importEnd,
126:                         type: .importStatement,
127:                         label: "Imports"
128:                     ))
129:                 }
130:             }
131:             
132:             // MARK: - Comment Detection
133:             if detectCommentStart(trimmed) {
134:                 commentStack.append((index, true))
135:             } else if trimmed.starts(with: "//") {
136:                 // Single-line comment - check for consecutive comment blocks
137:                 let commentEnd = findConsecutiveComments(from: index, in: lines)
138:                 if commentEnd > index {
139:                     regions.append(FoldRegion(
140:                         startLine: index,


>>>TOOL search
{"query":"shared", "glob":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "shared"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":1,"end_line":220}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 2-220 of 809)
────────────────────────────────────────
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
69:     @Published var foldRegions: [FoldRegion] = []
70:     @Published var collapsedLines: Set<Int> = []
71:     
72:     // Dictionary to manage fold regions per file
73:     private var foldRegionsByFile: [String: [FoldRegion]] = [:]
74:     
75:     private var currentFilePath: String?
76:     private var currentFileId: String?
77:     
78:     // MARK: - Enhanced Fold Detection
79:     
80:     /// Detects all foldable regions in the given code
81:     func detectFoldableRegions(in code: String, filePath: String? = nil) {
82:         self.currentFilePath = filePath
83:         self.currentFileId = filePath
84:         
85:         let lines = code.components(separatedBy: .newlines)
86:         var regions: [FoldRegion] = []
87:         
88:         // Track different types of blocks
89:         var blockStack: [(type: FoldRegion.FoldType, startLine: Int, label: String?)] = []
90:         var commentStack: [(startLine: Int, isMultiline: Bool)] = []
91:         var regionStack: [(startLine: Int, label: String)] = []
92:         
93:         for (index, line) in lines.enumerated() {
94:             let trimmed = line.trimmingCharacters(in: .whitespaces)
95:             let leadingWhitespace = line.prefix { $0 == " " || $0 == "\t" }.count
96:             
97:             // Skip empty lines for most detections
98:             guard !trimmed.isEmpty else { continue }
99:             
100:             // MARK: - Region Detection (#region, #pragma mark, MARK:)
101:             if detectRegionStart(trimmed) != nil {
102:                 if let label = detectRegionStart(trimmed) {
103:                     regionStack.append((index, label))
104:                 }
105:             } else if detectRegionEnd(trimmed) {
106:                 if let region = regionStack.popLast() {
107:                     if index - region.startLine > 1 {
108:                         regions.append(FoldRegion(
109:                             startLine: region.startLine,
110:                             endLine: index,
111:                             type: .region,
112:                             label: region.label
113:                         ))
114:                     }
115:                 }
116:             }
117:             
118:             // MARK: - Import Statement Detection
119:             if trimmed.hasPrefix("import ") {
120:                 // Group consecutive imports
121:                 let importEnd = findConsecutiveImports(from: index, in: lines)
122:                 if importEnd > index {
123:                     regions.append(FoldRegion(
124:                         startLine: index,
125:                         endLine: importEnd,
126:                         type: .importStatement,
127:                         label: "Imports"
128:                     ))
129:                 }
130:             }
131:             
132:             // MARK: - Comment Detection
133:             if detectCommentStart(trimmed) {
134:                 commentStack.append((index, true))
135:             } else if trimmed.starts(with: "//") {
136:                 // Single-line comment - check for consecutive comment blocks
137:                 let commentEnd = findConsecutiveComments(from: index, in: lines)
138:                 if commentEnd > index {
139:                     regions.append(FoldRegion(
140:                         startLine: index,
141:                         endLine: commentEnd,
142:                         type: .comment,
143:                         label: "Comment"
144:                     ))
145:                 }
146:             } else if detectCommentEnd(trimmed) {
147:                 if let comment = commentStack.popLast() {
148:                     if index - comment.startLine > 1 {
149:                         regions.append(FoldRegion(
150:                             startLine: comment.startLine,
151:                             endLine: index,
152:                             type: .comment,
153:                             label: "Comment"
154:                         ))
155:                     }
156:                 }
157:             }
158:             
159:             // MARK: - Class/Struct/Enum/Protocol/Extension Detection
160:             if let declaration = detectDeclaration(trimmed) {
161:                 if trimmed.contains("{") {
162:                     blockStack.append((declaration.type, index, declaration.label))
163:                 } else {
164:                     // Declaration without opening brace - look ahead for it
165:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
166:                         blockStack.append((declaration.type, index, declaration.label))
167:                     }
168:                 }
169:             }
170:             
171:             // MARK: - Function/Method Detection
172:             if let functionInfo = detectFunction(trimmed) {
173:                 if trimmed.contains("{") {
174:                     blockStack.append((.function, index, functionInfo))
175:                 } else {
176:                     // Function without opening brace - look ahead
177:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
178:                         blockStack.append((.function, index, functionInfo))
179:                     }
180:                 }
181:             }
182:             
183:             // MARK: - Control Flow Detection (if, guard, for, while, switch, etc.)
184:             if let controlFlowLabel = detectControlFlow(trimmed) {
185:                 if trimmed.contains("{") {
186:                     blockStack.append((.controlFlow, index, controlFlowLabel))
187:                 } else {
188:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
189:                         blockStack.append((.controlFlow, index, controlFlowLabel))
190:                     }
191:                 }
192:             }
193:             
194:             // MARK: - Generic Block Detection
195:             if trimmed.hasSuffix("{") && !isDeclarationLine(trimmed) && !isFunctionLine(trimmed) {
196:                 blockStack.append((.genericBlock, index, nil))
197:             }
198:             
199:             // MARK: - Block End Detection
200:             if detectBlockEnd(trimmed, leadingWhitespace: leadingWhitespace) {
201:                 if let lastBlock = blockStack.popLast() {
202:                     if index - lastBlock.startLine > 1 {
203:                         regions.append(FoldRegion(
204:                             startLine: lastBlock.startLine,
205:                             endLine: index,
206:                             type: lastBlock.type,
207:                             label: lastBlock.label
208:                         ))
209:                     }
210:                 }
211:             }
212:         }
213:         
214:         // Handle any remaining unclosed blocks
215:         while let lastBlock = blockStack.popLast() {
216:             if lines.count - 1 - lastBlock.startLine > 1 {
217:                 regions.append(FoldRegion(
218:                     startLine: lastBlock.startLine,
219:                     endLine: lines.count - 1,
220:                     type: lastBlock.type,


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":470,"end_line":505}
>>>END

>>>TOOL search
{"query":"CodeFoldingManager.shared","glob":"VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 471-505 of 774)
────────────────────────────────────────
471:                 Label("Move to Split Right", systemImage: "rectangle.split.2x1")
472:             }
473:             
474:             Button(action: { splitManager.moveTabToNewSplit(tab: tab, fromPaneId: pane.id, direction: .vertical) }) {
475:                 Label("Move to Split Down", systemImage: "rectangle.split.1x2")
476:             }
477:         }
478:     }
479: }
480: 
481: // MARK: - Pane Editor View
482: 
483: struct PaneEditorView: View {
484:     @ObservedObject var pane: EditorPane
485:     let tab: Tab
486:     @ObservedObject var splitManager: SplitEditorManager
487:     @ObservedObject var editorCore: EditorCore
488:     @ObservedObject private var debugManager = DebugManager.shared
489:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
490:     @State private var text: String = ""
491:     @State private var scrollPosition: Int = 0
492:     @State private var totalLines: Int = 1
493:     @State private var visibleLines: Int = 20
494:     @State private var currentLineNumber: Int = 1
495:     @State private var currentColumn: Int = 1
496:     @State private var lineHeight: CGFloat = 17
497:     @State private var requestedLineSelection: Int? = nil
498: 
499:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
500:     
501:     private var fileId: String { tab.url?.path ?? tab.fileName }
502:     
503:     var body: some View {
504:         GeometryReader { geometry in
505:             HStack(spacing: 0) {

---

[search]
No matches found for "CodeFoldingManager.shared"


>>>TOOL search
{"query":"class CodeFoldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

>>>TOOL search
{"query":"init(", "glob":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:68: class CodeFoldingManager: ObservableObject {

---

[search]
No matches found for "init("


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":480,"end_line":500}
>>>END

>>>TOOL search
{"query":"CodeFoldingManager()", "glob":"VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"static let shared", "glob":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 481-500 of 774)
────────────────────────────────────────
481: // MARK: - Pane Editor View
482: 
483: struct PaneEditorView: View {
484:     @ObservedObject var pane: EditorPane
485:     let tab: Tab
486:     @ObservedObject var splitManager: SplitEditorManager
487:     @ObservedObject var editorCore: EditorCore
488:     @ObservedObject private var debugManager = DebugManager.shared
489:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
490:     @State private var text: String = ""
491:     @State private var scrollPosition: Int = 0
492:     @State private var totalLines: Int = 1
493:     @State private var visibleLines: Int = 20
494:     @State private var currentLineNumber: Int = 1
495:     @State private var currentColumn: Int = 1
496:     @State private var lineHeight: CGFloat = 17
497:     @State private var requestedLineSelection: Int? = nil
498: 
499:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
500:     

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:374: @StateObject private var foldingManager = CodeFoldingManager()

---

[search]
No matches found for "static let shared"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":340,"end_line":430}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 341-430 of 1016)
────────────────────────────────────────
341:             if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
342:             Button(action: { editorCore.closeTab(id: tab.id) }) {
343:                 Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
344:                     .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
345:             }
346:         }
347:         .padding(.horizontal, 12).padding(.vertical, 6)
348:         .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
349:         .onTapGesture { editorCore.selectTab(id: tab.id) }
350:     }
351: }
352: 
353: // MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
354: 
355: struct IDEEditorView: View {
356:     @ObservedObject var editorCore: EditorCore
357:     let tab: Tab
358:     let theme: Theme
359: 
360:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
361:     @State private var text: String = ""
362:     @State private var scrollPosition: Int = 0
363:     @State private var totalLines: Int = 1
364:     @State private var visibleLines: Int = 20
365:     @State private var currentLineNumber: Int = 1
366:     @State private var currentColumn: Int = 1
367:     @State private var cursorIndex: Int = 0
368:     @State private var lineHeight: CGFloat = 17
369:     @State private var requestedCursorIndex: Int? = nil
370:     @State private var requestedLineSelection: Int? = nil
371: 
372:     @StateObject private var autocomplete = AutocompleteManager()
373:     @State private var showAutocomplete = false
374:     @StateObject private var foldingManager = CodeFoldingManager()
375:     @StateObject private var findViewModel = FindViewModel()
376:     
377:     var body: some View {
378:         VStack(spacing: 0) {
379:             // Find/Replace bar
380:             if editorCore.showSearch {
381:                 FindReplaceView(viewModel: findViewModel)
382:                     .background(theme.tabBarBackground)
383:             }
384:             
385:             BreadcrumbsView(editorCore: editorCore, tab: tab)
386:             
387:             GeometryReader { geometry in
388:                 ZStack(alignment: .topLeading) {
389:                 HStack(spacing: 0) {
390:                     if lineNumbersStyle != "off" {
391:                         LineNumbersWithFolding(
392:                             fileId: tab.url?.path ?? tab.fileName,
393:                             totalLines: totalLines,
394:                             currentLine: currentLineNumber,
395:                             scrollOffset: CGFloat(scrollPosition) * lineHeight,
396:                             lineHeight: lineHeight,
397:                             requestedLineSelection: $requestedLineSelection,
398:                             foldingManager: foldingManager,
399:                             theme: theme
400:                         )
401:                         .frame(width: 60)
402:                         .background(theme.sidebarBackground.opacity(0.5))
403:                     }
404:                     
405:                     if tab.fileName.hasSuffix(".json") {
406:                         // JSON Tree View for .json files
407:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
408:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
409:                             .background(theme.editorBackground)
410:                     } else {
411:                         SyntaxHighlightingTextView(
412:                             text: $text,
413:                             filename: tab.fileName,
414:                             scrollPosition: $scrollPosition,
415:                             totalLines: $totalLines,
416:                             visibleLines: $visibleLines,
417:                             currentLineNumber: $currentLineNumber,
418:                             currentColumn: $currentColumn,
419:                             cursorIndex: $cursorIndex,
420:                             lineHeight: $lineHeight,
421:                             isActive: true,
422:                             requestedLineSelection: $requestedLineSelection,
423:                             requestedCursorIndex: $requestedCursorIndex,
424:                             onAcceptAutocomplete: {
425:                                 guard showAutocomplete else { return false }
426:                                 var tempText = text
427:                                 var tempCursor = cursorIndex
428:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
429:                                 if tempText != text {
430:                                     text = tempText


⛔ ABORTED by user



⛔ ABORTED by user
