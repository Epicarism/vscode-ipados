# Agent: opus-fix-all-errors
**Status:** done
**Tokens:** 2,159
**Cost:** $0.0000
**Time:** 2026-02-09T20:40:59.349Z

## Task
Fix ALL remaining build errors in VSCodeiPadOS. The errors are:

1. VSCodeiPadOSApp.swift:5 - AppDelegate not found
   - Check if App/AppDelegate.swift exists, if not create it or remove the @UIApplicationDelegateAdaptor

2. SplitEditorView.swift:489 - CodeFoldingManager has no member 'shared'
   - Add 'static let shared = CodeFoldingManager()' to CodeFoldingManager class

3. GitView.swift:9,256 - GitStatusEntry not found
   - Add 'typealias GitStatusEntry = GitFileChange' to GitManager.swift or GitView.swift

4. SearchView.swift:1407 - ReplacePreview not found
   - Find and fix or add stub struct ReplacePreview

5. TerminalView.swift - SSHManager, SSHConnectionConfig, SSHManagerDelegate, SSHConnectionStore not found
   - Check SSHManager.swift for these types
   - Add missing types or fix imports

Read each file, understand the issue, and fix it. Make the project compile.

## Response
I'll systematically fix each build error. Let me start by reading the relevant files.

>>>TOOL read_file
{"path": "VSCodeiPadOS/App/VSCodeiPadOSApp.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/App/AppDelegate.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/Features/Editor/Views/SplitEditorView.swift", "start_line": 485, "end_line": 495}
>>>END

>>>TOOL search
{"query": "class CodeFoldingManager", "glob": "*.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/Features/Git/Views/GitView.swift", "start_line": 1, "end_line": 30}
>>>END

>>>TOOL search
{"query": "GitStatusEntry", "glob": "*.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/Features/Search/Views/SearchView.swift", "start_line": 1400, "end_line": 1420}
>>>END

>>>TOOL search
{"query": "struct ReplacePreview", "glob": "*.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/Features/Terminal/Views/TerminalView.swift", "start_line": 1, "end_line": 50}
>>>END

>>>TOOL search
{"query": "class SSHManager", "glob": "*.swift"}
>>>END

Let me search more broadly for these types:

>>>TOOL search
{"query": "CodeFoldingManager", "glob": "*.swift"}
>>>END

>>>TOOL search
{"query": "GitFileChange", "glob": "*.swift"}
>>>END

>>>TOOL search
{"query": "ReplacePreview", "glob": "*.swift"}
>>>END

>>>TOOL search
{"query": "SSHManager", "glob": "*.swift"}
>>>END

>>>TOOL search
{"query": "SSHConnectionConfig", "glob": "*.swift"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Features"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "CodeFoldingManager"

---

[search]
No matches found for "GitFileChange"

---

[search]
No matches found for "ReplacePreview"

---

[search]
No matches found for "SSHManager"

---

[search]
No matches found for "SSHConnectionConfig"

---

[list_dir]
Error: Directory "VSCodeiPadOS/VSCodeiPadOS/Features" not found

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Models/
   EditorState.swift
   FileItem.swift
   FileItemUTType.swift
   FindViewModel.swift
   MultiCursor.swift
   Tab.swift
   Theme.swift
   ThemeManager.swift


Let me explore the project structure more to understand where to create the missing types:

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift", "start_line": 250, "end_line": 270}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift", "start_line": 1, "end_line": 50}
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

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/Panels/
   AIAssistantView.swift
   AIAssistantView.swift.backup
   AIAssistantView.swift.bak
   DebugConsoleView.swift
   DebugView.swift
   GitQuickActionsView.swift
   GitView.swift
   GitView.swift.broken
   GoToLineView.swift
   MarkdownPreviewView.swift
   MarkdownPreviewWrapper.swift
   OutlineView.swift
   OutputView.swift
   PanelView.swift
   ProblemsView.swift
   RunnerWarningView.swift
   SearchView.swift
   SearchView.swift.broken
   SettingsView.swift
   TerminalView.swift
   TerminalView.swift.bak
   TestView.swift
   TimelineView.swift

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift (lines 251-270 of 504)
────────────────────────────────────────
251:             Spacer()
252:         }
253:         .padding(.vertical, 4)
254:     }
255:     
256:     private func changeRow(_ entry: GitStatusEntry, isStaged: Bool) -> some View {
257:         HStack(spacing: 8) {
258:             // Status indicator
259:             Text(entry.kind.rawValue.prefix(1).uppercased())
260:                 .font(.system(size: 10, weight: .bold, design: .monospaced))
261:                 .foregroundColor(entry.kind.color)
262:                 .frame(width: 16)
263:             
264:             // File name
265:             Text(entry.path.components(separatedBy: "/").last ?? entry.path)
266:                 .font(.system(size: 12))
267:                 .lineLimit(1)
268:             
269:             Spacer()
270:             

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift (lines 2-50 of 1630)
────────────────────────────────────────
2: import Combine
3: 
4: enum SearchField: Hashable {
5:     case search
6:     case replace
7:     case filesToInclude
8:     case filesToExclude
9: }
10: 
11: // MARK: - Data Models
12: 
13: struct SearchResultLine: Identifiable, Hashable {
14:     let id = UUID()
15:     let lineNumber: Int
16:     let text: String
17:     let matches: [Range<String.Index>]
18: }
19: 
20: struct SearchNavigationItem: Identifiable, Hashable {
21:     let id = UUID()
22:     let fileIndex: Int
23:     let matchIndex: Int
24:     let fileID: UUID
25:     let matchID: UUID
26: }
27: 
28: struct FileSearchResult: Identifiable, Comparable {
29:     let id = UUID()
30:     let fileName: String
31:     let path: String
32:     let matches: [SearchResultLine]
33:     var isExpanded: Bool = true
34:     
35:     // Computed property for directory grouping
36:     var directory: String {
37:         let components = path.components(separatedBy: "/")
38:         return components.dropLast().joined(separator: "/")
39:     }
40:     
41:     // Comparable implementation for sorting
42:     static func < (lhs: FileSearchResult, rhs: FileSearchResult) -> Bool {
43:         lhs.fileName < rhs.fileName
44:     }
45: }
46: 
47: // MARK: - Sort Options
48: 
49: enum SortOption: String, CaseIterable, Identifiable {
50:     case fileName = "Filename"


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift", "start_line": 480, "end_line": 504}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift", "start_line": 1410, "end_line": 1450}
>>>END

>>>TOOL search
{"query": "TerminalWorkspace", "glob": "*.swift"}
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift (lines 481-504 of 504)
────────────────────────────────────────
481:             }
482:         }
483:     }
484:     
485:     private func checkout(_ branch: String) {
486:         Task {
487:             try? await gitManager.checkout(branch: branch)
488:             await MainActor.run { dismiss() }
489:         }
490:     }
491:     
492:     private func createBranch() {
493:         guard !newBranchName.isEmpty else { return }
494:         Task {
495:             try? await gitManager.createBranch(name: newBranchName, checkout: true)
496:             await MainActor.run {
497:                 newBranchName = ""
498:                 showCreateBranch = false
499:                 dismiss()
500:             }
501:         }
502:     }
503: }
504: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift (lines 1411-1450 of 1630)
────────────────────────────────────────
1411:     
1412:     var body: some View {
1413:         NavigationView {
1414:             List {
1415:                 Section(header: Text("\(previews.count) changes to be made")) {
1416:                     ForEach(previews) { preview in
1417:                         VStack(alignment: .leading, spacing: 8) {
1418:                             HStack {
1419:                                 Image(systemName: "doc.text")
1420:                                     .foregroundColor(.secondary)
1421:                                 Text(preview.fileName)
1422:                                     .font(.system(size: 13, weight: .semibold))
1423:                                 Text(preview.path)
1424:                                     .font(.caption)
1425:                                     .foregroundColor(.secondary)
1426:                                 Spacer()
1427:                             }
1428:                             
1429:                             VStack(alignment: .leading, spacing: 4) {
1430:                                 HStack(alignment: .top) {
1431:                                     Text("\(preview.lineNumber)")
1432:                                         .font(.system(size: 11, design: .monospaced))
1433:                                         .foregroundColor(.secondary)
1434:                                         .frame(width: 30, alignment: .trailing)
1435:                                     Text(preview.originalLine)
1436:                                         .font(.system(size: 12, design: .monospaced))
1437:                                         .foregroundColor(.red)
1438:                                         .strikethrough()
1439:                                 }
1440:                                 
1441:                                 HStack(alignment: .top) {
1442:                                     Text("\(preview.lineNumber)")
1443:                                         .font(.system(size: 11, design: .monospaced))
1444:                                         .foregroundColor(.secondary)
1445:                                         .frame(width: 30, alignment: .trailing)
1446:                                     Text(preview.replacedLine)
1447:                                         .font(.system(size: 12, design: .monospaced))
1448:                                         .foregroundColor(.green)
1449:                                 }
1450:                             }

---

[search]
No matches found for "TerminalWorkspace"


Now I have a clearer picture. Let me read the key files:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift", "start_line": 1, "end_line": 100}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/SSHManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 1-810 of 810)
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
221:                     label: lastBlock.label
222:                 ))
223:             }
224:         }
225:         
226:         // Sort regions by start line
227:         regions.sort { $0.startLine < $1.startLine }
228:         
229:         self.foldRegions = regions
230:         
231:         // Store regions in the per-file dictionary
232:         if let fileId = currentFileId {
233:             foldRegionsByFile[fileId] = regions
234:         }
235:         
236:         // Restore previous fold state for this file
237:         if let filePath = filePath {
238:             restoreFoldState(for: filePath)
239:         }
240:         
241:         updateCollapsedLines()
242:     }
243:     
244:     // MARK: - Detection Helper Methods
245:     
246:     private func detectRegionStart(_ line: String) -> String? {
247:         // C# / VS style regions
248:         if line.hasPrefix("#region") {
249:             let components = line.components(separatedBy: "#region")
250:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Region"
251:         }
252:         // Objective-C pragma marks
253:         if line.hasPrefix("#pragma mark") {
254:             let components = line.components(separatedBy: "#pragma mark")
255:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
256:         }
257:         // Swift MARK comments
258:         if line.contains("MARK:") {
259:             let components = line.components(separatedBy: "MARK:")
260:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
261:         }
262:         // TODO/FIXME regions
263:         if line.contains("TODO:") {
264:             let components = line.components(separatedBy: "TODO:")
265:             return "TODO: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
266:         }
267:         if line.contains("FIXME:") {
268:             let components = line.components(separatedBy: "FIXME:")
269:             return "FIXME: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
270:         }
271:         return nil
272:     }
273:     
274:     private func detectRegionEnd(_ line: String) -> Bool {
275:         return line.hasPrefix("#endregion") || 
276:                line == "// MARK: -" ||
277:                line.hasPrefix("#pragma mark -")
278:     }
279:     
280:     private func detectCommentStart(_ line: String) -> Bool {
281:         return line.hasPrefix("/*") && !line.contains("*/")
282:     }
283:     
284:     private func detectCommentEnd(_ line: String) -> Bool {
285:         return line.contains("*/") && !line.hasPrefix("/*")
286:     }
287:     
288:     private func findConsecutiveImports(from startIndex: Int, in lines: [String]) -> Int {
289:         var endIndex = startIndex
290:         for i in startIndex..<lines.count {
291:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
292:             if trimmed.hasPrefix("import ") {
293:                 endIndex = i
294:             } else if !trimmed.isEmpty {
295:                 break
296:             }
297:         }
298:         return endIndex
299:     }
300:     
301:     private func findConsecutiveComments(from startIndex: Int, in lines: [String]) -> Int {
302:         var endIndex = startIndex
303:         for i in startIndex..<lines.count {
304:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
305:             if trimmed.starts(with: "//") {
306:                 endIndex = i
307:             } else if !trimmed.isEmpty {
308:                 break
309:             }
310:         }
311:         return endIndex
312:     }
313:     
314:     private func detectDeclaration(_ line: String) -> (type: FoldRegion.FoldType, label: String)? {
315:         // Class detection
316:         if let className = extractName(from: line, prefix: "class", visibility: ["public", "private", "internal", "fileprivate", "open", "final"]) {
317:             return (.classOrStruct, className)
318:         }
319:         // Struct detection
320:         if let structName = extractName(from: line, prefix: "struct", visibility: ["public", "private", "internal", "fileprivate"]) {
321:             return (.classOrStruct, structName)
322:         }
323:         // Enum detection
324:         if let enumName = extractName(from: line, prefix: "enum", visibility: ["public", "private", "internal", "fileprivate", "indirect"]) {
325:             return (.enumDeclaration, enumName)
326:         }
327:         // Protocol detection
328:         if let protocolName = extractName(from: line, prefix: "protocol", visibility: ["public", "private", "internal", "fileprivate"]) {
329:             return (.protocolDeclaration, protocolName)
330:         }
331:         // Extension detection
332:         if let extensionName = extractName(from: line, prefix: "extension", visibility: []) {
333:             return (.extension, extensionName)
334:         }
335:         return nil
336:     }
337:     
338:     private func detectFunction(_ line: String) -> String? {
339:         // Function detection with visibility modifiers
340:         let visibilityKeywords = ["public", "private", "internal", "fileprivate", "static", "class", "override", "final", "mutating", "convenience"]
341:         
342:         // Check for 'func' keyword
343:         if line.contains("func ") {
344:             // Extract function name
345:             let funcPattern = "func\\s+(\\w+)"
346:             if let regex = try? NSRegularExpression(pattern: funcPattern),
347:                let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
348:                let nameRange = Range(match.range(at: 1), in: line) {
349:                 let functionName = String(line[nameRange])
350:                 // Check for parameters to create label
351:                 if let parenStart = line.firstIndex(of: "("), let parenEnd = line.firstIndex(of: ")") {
352:                     let params = String(line[parenStart...parenEnd])
353:                     return "\(functionName)\(params)"
354:                 }
355:                 return functionName
356:             }
357:         }
358:         
359:         // Init detection
360:         if let initName = extractName(from: line, prefix: "init", visibility: visibilityKeywords) {
361:             return "\(initName)"
362:         }
363:         
364:         // Deinit detection
365:         if line.contains("deinit") {
366:             return "deinit"
367:         }
368:         
369:         // Computed property with get/set
370:         if line.hasPrefix("var ") && (line.contains("{") || line.contains("get")) {
371:             if let varName = extractVariableName(from: line) {
372:                 return varName
373:             }
374:         }
375:         
376:         return nil
377:     }
378:     
379:     private func detectControlFlow(_ line: String) -> String? {
380:         let controlFlowPatterns = [
381:             ("if ", "if"),
382:             ("guard ", "guard"),
383:             ("else if", "else if"),
384:             ("else", "else"),
385:             ("for ", "for"),
386:             ("while ", "while"),
387:             ("repeat", "repeat"),
388:             ("switch ", "switch"),
389:             ("case ", "case"),
390:             ("default:", "default"),
391:             ("do ", "do"),
392:             ("catch", "catch")
393:         ]
394:         
395:         for (pattern, label) in controlFlowPatterns {
396:             if line.contains(pattern) {
397:                 return label
398:             }
399:         }
400:         return nil
401:     }
402:     
403:     private func extractName(from line: String, prefix: String, visibility: [String]) -> String? {
404:         var components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
405:         
406:         // Remove visibility modifiers
407:         components = components.filter { !visibility.contains($0) }
408:         
409:         // Find prefix index
410:         if let prefixIndex = components.firstIndex(where: { $0 == prefix }),
411:            prefixIndex + 1 < components.count {
412:             var name = components[prefixIndex + 1]
413:             // Remove colons and other trailing characters
414:             name = name.components(separatedBy: ":").first ?? name
415:             name = name.components(separatedBy: "<").first ?? name
416:             name = name.components(separatedBy: ":").first ?? name
417:             return name
418:         }
419:         return nil
420:     }
421:     
422:     private func extractVariableName(from line: String) -> String? {
423:         let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
424:         if components.count >= 2, components[0] == "var" {
425:             var varName = components[1]
426:             varName = varName.components(separatedBy: ":").first ?? varName
427:             varName = varName.components(separatedBy: "=").first ?? varName
428:             return varName
429:         }
430:         return nil
431:     }
432:     
433:     private func findOpeningBrace(from startIndex: Int, in lines: [String]) -> Int? {
434:         for i in startIndex..<min(startIndex + 5, lines.count) {
435:             if lines[i].contains("{") {
436:                 return i
437:             }
438:         }
439:         return nil
440:     }
441:     
442:     private func isDeclarationLine(_ line: String) -> Bool {
443:         let keywords = ["class", "struct", "enum", "protocol", "extension", "init", "func"]
444:         return keywords.contains { line.contains("\($0) ") }
445:     }
446:     
447:     private func isFunctionLine(_ line: String) -> Bool {
448:         return line.contains("func ") || line.contains("init ")
449:     }
450:     
451:     private func detectBlockEnd(_ line: String, leadingWhitespace: Int) -> Bool {
452:         return (line.hasPrefix("}") || line.starts(with: "}")) && 
453:                (line.trimmingCharacters(in: .whitespaces) == "}" || 
454:                 line.trimmingCharacters(in: .whitespaces).hasPrefix("}"))
455:     }
456:     
457:     // MARK: - Fold State Persistence
458:     
459:     /// Saves the current fold state to UserDefaults
460:     func saveFoldState(for filePath: String) {
461:         let key = UserDefaultsKeys.foldStatePrefix + filePath
462:         
463:         // Use regions from the dictionary if available
464:         let regionsToSave: [FoldRegion]
465:         if let fileId = currentFileId, let storedRegions = foldRegionsByFile[fileId] {
466:             regionsToSave = storedRegions
467:         } else {
468:             regionsToSave = foldRegions
469:         }
470:         
471:         // Create a simplified representation for storage
472:         let foldState = regionsToSave.map { FoldStateEntry(startLine: $0.startLine, isFolded: $0.isFolded) }
473:         
474:         if let data = try? JSONEncoder().encode(foldState) {
475:             UserDefaults.standard.set(data, forKey: key)
476:         }
477:     }
478:     
479:     /// Restores fold state from UserDefaults
480:     private func restoreFoldState(for filePath: String) {
481:         let key = UserDefaultsKeys.foldStatePrefix + filePath
482:         
483:         guard let data = UserDefaults.standard.data(forKey: key),
484:               let foldState = try? JSONDecoder().decode([FoldStateEntry].self, from: data) else {
485:             return
486:         }
487:         
488:         // Apply saved state to current regions
489:         for savedState in foldState {
490:             if let index = foldRegions.firstIndex(where: { $0.startLine == savedState.startLine }) {
491:                 foldRegions[index].isFolded = savedState.isFolded
492:             }
493:         }
494:     }
495:     
496:     /// Helper struct for persisting fold state
497:     private struct FoldStateEntry: Codable {
498:         let startLine: Int
499:         let isFolded: Bool
500:     }
501:     
502:     /// Clears fold state for a specific file
503:     func clearFoldState(for filePath: String) {
504:         let key = UserDefaultsKeys.foldStatePrefix + filePath
505:         UserDefaults.standard.removeObject(forKey: key)
506:     }
507:     
508:     /// Clears all fold states
509:     func clearAllFoldStates() {
510:         let defaults = UserDefaults.standard
511:         let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(UserDefaultsKeys.foldStatePrefix) }
512:         for key in keys {
513:             defaults.removeObject(forKey: key)
514:         }
515:     }
516:     
517:     // MARK: - Fold Operations
518:     
519:     /// Toggles the fold state at a specific line
520:     func toggleFold(at line: Int) {
521:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
522:             foldRegions[regionIndex].isFolded.toggle()
523:             updateCollapsedLines()
524:             
525:             // Save state after toggling
526:             if let filePath = currentFilePath {
527:                 saveFoldState(for: filePath)
528:             }
529:         }
530:     }
531:     
532:     /// Expands a folded region
533:     func expandRegion(at line: Int) {
534:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
535:             foldRegions[regionIndex].isFolded = false
536:             updateCollapsedLines()
537:             
538:             if let filePath = currentFilePath {
539:                 saveFoldState(for: filePath)
540:             }
541:         }
542:     }
543:     
544:     /// Collapses a region
545:     func collapseRegion(at line: Int) {
546:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
547:             foldRegions[regionIndex].isFolded = true
548:             updateCollapsedLines()
549:             
550:             if let filePath = currentFilePath {
551:                 saveFoldState(for: filePath)
552:             }
553:         }
554:     }
555:     
556:     /// Expands all folded regions
557:     func expandAll() {
558:         for index in foldRegions.indices {
559:             foldRegions[index].isFolded = false
560:         }
561:         updateCollapsedLines()
562:         
563:         if let filePath = currentFilePath {
564:             saveFoldState(for: filePath)
565:         }
566:     }
567:     
568:     /// Collapses all foldable regions
569:     func collapseAll() {
570:         for index in foldRegions.indices {
571:             foldRegions[index].isFolded = true
572:         }
573:         updateCollapsedLines()
574:         
575:         if let filePath = currentFilePath {
576:             saveFoldState(for: filePath)
577:         }
578:     }
579:     
580:     /// Collapses all regions of a specific type
581:     func collapseAll(ofType type: FoldRegion.FoldType) {
582:         for index in foldRegions.indices {
583:             if foldRegions[index].type == type {
584:                 foldRegions[index].isFolded = true
585:             }
586:         }
587:         updateCollapsedLines()
588:         
589:         if let filePath = currentFilePath {
590:             saveFoldState(for: filePath)
591:         }
592:     }
593:     
594:     /// Expands all regions of a specific type
595:     func expandAll(ofType type: FoldRegion.FoldType) {
596:         for index in foldRegions.indices {
597:             if foldRegions[index].type == type {
598:                 foldRegions[index].isFolded = false
599:             }
600:         }
601:         updateCollapsedLines()
602:         
603:         if let filePath = currentFilePath {
604:             saveFoldState(for: filePath)
605:         }
606:     }
607:     
608:     // MARK: - Query Methods
609:     
610:     /// Checks if a line is foldable
611:     func isFoldable(line: Int) -> Bool {
612:         return foldRegions.contains { $0.startLine == line }
613:     }
614:     
615:     /// Checks if a line is currently folded
616:     func isLineFolded(line: Int) -> Bool {
617:         return collapsedLines.contains(line)
618:     }
619:     
620:     /// Checks if a region at a given line is folded
621:     func isRegionFolded(at line: Int) -> Bool {
622:         return foldRegions.first { $0.startLine == line }?.isFolded ?? false
623:     }
624:     
625:     /// Gets the fold region at a specific line
626:     func getRegion(at line: Int) -> FoldRegion? {
627:         return foldRegions.first { $0.startLine == line }
628:     }
629:     
630:     /// Gets all fold regions of a specific type
631:     func getRegions(ofType type: FoldRegion.FoldType) -> [FoldRegion] {
632:         return foldRegions.filter { $0.type == type }
633:     }
634:     
635:     // MARK: - File-Aware Methods
636:     
637:     /// Checks if a line is foldable for a specific file
638:     func isFoldable(fileId: String, line: Int) -> Bool {
639:         guard let regions = foldRegionsByFile[fileId] else { return false }
640:         return regions.contains { $0.startLine == line }
641:     }
642:     
643:     /// Checks if a region at a given line is folded for a specific file
644:     func isFolded(fileId: String, line: Int) -> Bool {
645:         guard let regions = foldRegionsByFile[fileId] else { return false }
646:         return regions.first { $0.startLine == line }?.isFolded ?? false
647:     }
648:     
649:     /// Toggles the fold state at a specific line for a specific file
650:     func toggleFold(fileId: String, line: Int) {
651:         guard var regions = foldRegionsByFile[fileId] else { return }
652:         
653:         if let regionIndex = regions.firstIndex(where: { $0.startLine == line }) {
654:             regions[regionIndex].isFolded.toggle()
655:             foldRegionsByFile[fileId] = regions
656:             
657:             // Update current file regions if this is the active file
658:             if fileId == currentFileId {
659:                 self.foldRegions = regions
660:                 updateCollapsedLines()
661:             }
662:             
663:             // Save state after toggling
664:             saveFoldState(for: fileId)
665:         }
666:     }
667:     
668:     /// Gets fold regions for a specific file
669:     func getFoldRegions(for fileId: String) -> [FoldRegion] {
670:         return foldRegionsByFile[fileId] ?? []
671:     }
672:     
673:     /// Clears fold regions for a specific file from memory
674:     func clearFoldRegions(for fileId: String) {
675:         foldRegionsByFile.removeValue(forKey: fileId)
676:     }
677:     
678:     /// Clears all fold regions from memory
679:     func clearAllFoldRegions() {
680:         foldRegionsByFile.removeAll()
681:     }
682:     
683:     /// Gets folded line ranges for text hiding
684:     /// Returns an array of closed ranges representing the line numbers that should be hidden
685:     func getFoldedLineRanges() -> [ClosedRange<Int>] {
686:         var ranges: [ClosedRange<Int>] = []
687:         
688:         // Sort regions by start line to ensure proper ordering
689:         let sortedRegions = foldRegions.sorted { $0.startLine < $1.startLine }
690:         
691:         for region in sortedRegions where region.isFolded {
692:             ranges.append((region.startLine + 1)...region.endLine)
693:         }
694:         
695:         return ranges
696:     }
697:     
698:     /// Gets the total count of folded lines
699:     func getFoldedLineCount() -> Int {
700:         return collapsedLines.count
701:     }
702:     
703:     /// Gets a summary of fold statistics
704:     func getFoldStatistics() -> FoldStatistics {
705:         let totalCount = foldRegions.count
706:         let foldedCount = foldRegions.filter { $0.isFolded }.count
707:         
708:         var typeBreakdown: [FoldRegion.FoldType: Int] = [:]
709:         for region in foldRegions {
710:             typeBreakdown[region.type, default: 0] += 1
711:         }
712:         
713:         return FoldStatistics(
714:             totalRegions: totalCount,
715:             foldedRegions: foldedCount,
716:             typeBreakdown: typeBreakdown
717:         )
718:     }
719:     
720:     // MARK: - Private Methods
721:     
722:     private func updateCollapsedLines() {
723:         collapsedLines.removeAll()
724:         
725:         for region in foldRegions where region.isFolded {
726:             for line in (region.startLine + 1)...region.endLine {
727:                 collapsedLines.insert(line)
728:             }
729:         }
730:     }
731: }
732: 
733: // MARK: - Fold Statistics
734: struct FoldStatistics {
735:     let totalRegions: Int
736:     let foldedRegions: Int
737:     let typeBreakdown: [FoldRegion.FoldType: Int]
738:     
739:     var expansionPercentage: Double {
740:         guard totalRegions > 0 else { return 0 }
741:         return Double(foldedCount) / Double(totalRegions) * 100
742:     }
743:     
744:     var foldedCount: Int {
745:         return foldedRegions
746:     }
747:     
748:     var expandedCount: Int {
749:         return totalRegions - foldedRegions
750:     }
751: }
752: 
753: // MARK: - Fold Button View
754: struct FoldButton: View {
755:     let line: Int
756:     let isExpanded: Bool
757:     let foldType: FoldRegion.FoldType?
758:     let action: () -> Void
759:     
760:     var body: some View {
761:         Button(action: action) {
762:             ZStack {
763:                 if let type = foldType {
764:                     Text(type.icon)
765:                         .font(.system(size: 8, weight: .bold))
766:                         .foregroundColor(.blue.opacity(0.6))
767:                 }
768:                 
769:                 Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
770:                     .font(.system(size: 10, weight: .semibold))
771:                     .foregroundColor(.primary.opacity(0.7))
772:             }
773:             .frame(width: 18, height: 18)
774:             .background(isExpanded ? Color.secondary.opacity(0.1) : Color.secondary.opacity(0.2))
775:             .cornerRadius(4)
776:         }
777:         .buttonStyle(PlainButtonStyle())
778:     }
779: }
780: 
781: // MARK: - Line Number View with Folding
782: struct LineNumberViewWithFolding: View {
783:     let lineNumber: Int
784:     let isFoldable: Bool
785:     let isExpanded: Bool
786:     let foldType: FoldRegion.FoldType?
787:     let onFoldTap: () -> Void
788:     
789:     var body: some View {
790:         HStack(spacing: 4) {
791:             if isFoldable {
792:                 FoldButton(
793:                     line: lineNumber,
794:                     isExpanded: isExpanded,
795:                     foldType: foldType,
796:                     action: onFoldTap
797:                 )
798:             } else {
799:                 Color.clear
800:                     .frame(width: 18, height: 18)
801:             }
802:             
803:             Text("\(lineNumber + 1)")
804:                 .font(.system(.caption, design: .monospaced))
805:                 .foregroundColor(.gray)
806:                 .frame(minWidth: 30, alignment: .trailing)
807:         }
808:     }
809: }
810: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift (lines 2-100 of 244)
────────────────────────────────────────
2: //  GitManager.swift
3: //  VSCodeiPadOS
4: //
5: //  Minimal Git Manager - stub implementation
6: //  TODO: Implement real git operations via SSH
7: //
8: 
9: import SwiftUI
10: import Combine
11: 
12: // MARK: - Git Errors
13: 
14: enum GitManagerError: Error, LocalizedError {
15:     case noRepository
16:     case gitExecutableNotFound
17:     case commandFailed(args: [String], exitCode: Int32, message: String)
18:     case notAvailableOnIOS
19:     case sshNotConnected
20:     case invalidRepository
21:     
22:     var errorDescription: String? {
23:         switch self {
24:         case .noRepository:
25:             return "No git repository configured"
26:         case .gitExecutableNotFound:
27:             return "Git executable not found"
28:         case let .commandFailed(args, exitCode, message):
29:             return "git \(args.joined(separator: " ")) failed (\(exitCode)): \(message)"
30:         case .notAvailableOnIOS:
31:             return "Git is not available on iOS"
32:         case .sshNotConnected:
33:             return "SSH connection required for git operations"
34:         case .invalidRepository:
35:             return "Invalid git repository"
36:         }
37:     }
38: }
39: 
40: // MARK: - Git Types
41: 
42: enum GitChangeKind: String, Codable, Hashable {
43:     case modified = "M"
44:     case added = "A"
45:     case deleted = "D"
46:     case renamed = "R"
47:     case copied = "C"
48:     case untracked = "?"
49:     case ignored = "!"
50:     case unmerged = "U"
51:     case typeChanged = "T"
52:     case unknown = "X"
53:     
54:     var icon: String {
55:         switch self {
56:         case .modified: return "pencil"
57:         case .added: return "plus"
58:         case .deleted: return "minus"
59:         case .renamed: return "arrow.right"
60:         case .copied: return "doc.on.doc"
61:         case .untracked: return "questionmark"
62:         case .ignored: return "eye.slash"
63:         case .unmerged: return "exclamationmark.triangle"
64:         case .typeChanged: return "arrow.triangle.2.circlepath"
65:         case .unknown: return "questionmark.circle"
66:         }
67:     }
68:     
69:     var color: Color {
70:         switch self {
71:         case .modified: return .orange
72:         case .added: return .green
73:         case .deleted: return .red
74:         case .renamed: return .blue
75:         case .copied: return .blue
76:         case .untracked: return .gray
77:         case .ignored: return .gray
78:         case .unmerged: return .yellow
79:         case .typeChanged: return .purple
80:         case .unknown: return .gray
81:         }
82:     }
83: }
84: 
85: struct GitBranch: Identifiable, Hashable {
86:     let id = UUID()
87:     let name: String
88:     let isRemote: Bool
89:     let isCurrent: Bool
90:     
91:     init(name: String, isRemote: Bool = false, isCurrent: Bool = false) {
92:         self.name = name
93:         self.isRemote = isRemote
94:         self.isCurrent = isCurrent
95:     }
96: }
97: 
98: struct GitCommit: Identifiable, Hashable {
99:     let id: String // SHA
100:     let message: String

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/SSHManager.swift (lines 1-887 of 887)
────────────────────────────────────────
1: //
2: //  SSHManager.swift
3: //  VSCodeiPadOS
4: //
5: //  Real SSH implementation using SwiftNIO SSH
6: //  Add package: https://github.com/apple/swift-nio-ssh
7: //
8: 
9: import Foundation
10: import NIO
11: import NIOSSH
12: import NIOCore
13: import NIOPosix
14: 
15: // MARK: - SSH Connection Model
16: 
17: struct SSHConnectionConfig: Codable, Identifiable, Equatable {
18:     var id: UUID = UUID()
19:     var name: String
20:     var host: String
21:     var port: Int
22:     var username: String
23:     var authMethod: SSHAuthMethod
24:     var lastUsed: Date?
25:     
26:     enum SSHAuthMethod: Codable, Equatable {
27:         case password(String)
28:         case privateKey(key: String, passphrase: String?)
29:     }
30:     
31:     static func == (lhs: SSHConnectionConfig, rhs: SSHConnectionConfig) -> Bool {
32:         lhs.id == rhs.id
33:     }
34: }
35: 
36: // MARK: - SSH Manager Delegate Protocol
37: 
38: protocol SSHManagerDelegate: AnyObject {
39:     func sshManagerDidConnect(_ manager: SSHManager)
40:     func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?)
41:     func sshManager(_ manager: SSHManager, didReceiveOutput text: String)
42:     func sshManager(_ manager: SSHManager, didReceiveError text: String)
43: }
44: 
45: // MARK: - SSH Client Errors
46: 
47: enum SSHClientError: Error, LocalizedError {
48:     case connectionFailed(String)
49:     case authenticationFailed
50:     case channelCreationFailed
51:     case invalidChannelType
52:     case notConnected
53:     case timeout
54:     case invalidPrivateKey
55:     case commandExecutionFailed(String)
56:     
57:     var errorDescription: String? {
58:         switch self {
59:         case .connectionFailed(let reason): return "Connection failed: \(reason)"
60:         case .authenticationFailed: return "Authentication failed"
61:         case .channelCreationFailed: return "Failed to create SSH channel"
62:         case .invalidChannelType: return "Invalid channel type"
63:         case .notConnected: return "Not connected to server"
64:         case .timeout: return "Connection timed out"
65:         case .invalidPrivateKey: return "Invalid private key format"
66:         case .commandExecutionFailed(let reason): return "Command execution failed: \(reason)"
67:         }
68:     }
69: }
70: 
71: // MARK: - Command Output Types
72: 
73: /// Real-time output events from SSH command execution
74: enum SSHCommandOutput {
75:     case stdout(String)
76:     case stderr(String)
77:     case exit(Int)
78:     case error(Error)
79:     case timeout
80: }
81: 
82: /// Result of a completed SSH command
83: struct SSHCommandResult {
84:     let stdout: String
85:     let stderr: String
86:     let exitCode: Int
87:     let isTimedOut: Bool
88:     
89:     var isSuccess: Bool {
90:         return exitCode == 0 && !isTimedOut
91:     }
92: }
93: 
94: // MARK: - SSH Manager
95: 
96: class SSHManager {
97:     weak var delegate: SSHManagerDelegate?
98:     
99:     private var eventLoopGroup: MultiThreadedEventLoopGroup?
100:     private var channel: Channel?
101:     private var sshHandler: NIOSSHHandler?
102:     private var shellChannel: Channel?
103:     
104:     private(set) var isConnected = false
105:     private(set) var config: SSHConnectionConfig?
106:     
107:     // MARK: - Authentication Delegates
108:     
109:     private class PasswordAuthDelegate: NIOSSHClientUserAuthenticationDelegate {
110:         let username: String
111:         let password: String
112:         private var attemptedPassword = false
113:         
114:         init(username: String, password: String) {
115:             self.username = username
116:             self.password = password
117:         }
118:         
119:         func nextAuthenticationType(
120:             availableMethods: NIOSSHAvailableUserAuthenticationMethods,
121:             nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
122:         ) {
123:             guard !attemptedPassword else {
124:                 // Already tried password, fail
125:                 nextChallengePromise.succeed(nil)
126:                 return
127:             }
128:             
129:             if availableMethods.contains(.password) {
130:                 attemptedPassword = true
131:                 nextChallengePromise.succeed(
132:                     NIOSSHUserAuthenticationOffer(
133:                         username: username,
134:                         serviceName: "",
135:                         offer: .password(.init(password: password))
136:                     )
137:                 )
138:             } else {
139:                 nextChallengePromise.succeed(nil)
140:             }
141:         }
142:     }
143:     
144:     private class PrivateKeyAuthDelegate: NIOSSHClientUserAuthenticationDelegate {
145:         let username: String
146:         let privateKey: NIOSSHPrivateKey
147:         private var attemptedKey = false
148:         
149:         init(username: String, privateKey: NIOSSHPrivateKey) {
150:             self.username = username
151:             self.privateKey = privateKey
152:         }
153:         
154:         func nextAuthenticationType(
155:             availableMethods: NIOSSHAvailableUserAuthenticationMethods,
156:             nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
157:         ) {
158:             guard !attemptedKey else {
159:                 nextChallengePromise.succeed(nil)
160:                 return
161:             }
162:             
163:             if availableMethods.contains(.publicKey) {
164:                 attemptedKey = true
165:                 nextChallengePromise.succeed(
166:                     NIOSSHUserAuthenticationOffer(
167:                         username: username,
168:                         serviceName: "",
169:                         offer: .privateKey(.init(privateKey: privateKey))
170:                     )
171:                 )
172:             } else {
173:                 nextChallengePromise.succeed(nil)
174:             }
175:         }
176:     }
177:     
178:     private class AcceptAllHostKeysDelegate: NIOSSHClientServerAuthenticationDelegate {
179:         func validateHostKey(
180:             hostKey: NIOSSHPublicKey,
181:             validationCompletePromise: EventLoopPromise<Void>
182:         ) {
183:             // WARNING: In production, implement proper host key verification!
184:             // This accepts all host keys for demo purposes.
185:             validationCompletePromise.succeed(())
186:         }
187:     }
188:     
189:     // MARK: - Channel Handlers
190:     
191:     private class SSHChannelHandler: ChannelDuplexHandler {
192:         typealias InboundIn = SSHChannelData
193:         typealias InboundOut = ByteBuffer
194:         typealias OutboundIn = ByteBuffer
195:         typealias OutboundOut = SSHChannelData
196:         
197:         weak var manager: SSHManager?
198:         
199:         init(manager: SSHManager) {
200:             self.manager = manager
201:         }
202:         
203:         func channelRead(context: ChannelHandlerContext, data: NIOAny) {
204:             let channelData = unwrapInboundIn(data)
205:             
206:             switch channelData.type {
207:             case .channel:
208:                 guard case .byteBuffer(let buffer) = channelData.data else { return }
209:                 if let text = buffer.getString(at: 0, length: buffer.readableBytes) {
210:                     DispatchQueue.main.async {
211:                         self.manager?.delegate?.sshManager(self.manager!, didReceiveOutput: text)
212:                     }
213:                 }
214:             case .stdErr:
215:                 guard case .byteBuffer(let buffer) = channelData.data else { return }
216:                 if let text = buffer.getString(at: 0, length: buffer.readableBytes) {
217:                     DispatchQueue.main.async {
218:                         self.manager?.delegate?.sshManager(self.manager!, didReceiveError: text)
219:                     }
220:                 }
221:             default:
222:                 break
223:             }
224:         }
225:         
226:         func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
227:             let buffer = unwrapOutboundIn(data)
228:             let channelData = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
229:             context.write(wrapOutboundOut(channelData), promise: promise)
230:         }
231:         
232:         func errorCaught(context: ChannelHandlerContext, error: Error) {
233:             print("SSH Channel Error: \(error)")
234:             context.close(promise: nil)
235:         }
236:     }
237:     
238:     private class ShellRequestHandler: ChannelInboundHandler {
239:         typealias InboundIn = SSHChannelData
240:         
241:         let completePromise: EventLoopPromise<Void>
242:         
243:         init(completePromise: EventLoopPromise<Void>) {
244:             self.completePromise = completePromise
245:         }
246:         
247:         func channelActive(context: ChannelHandlerContext) {
248:             // Request a PTY
249:             let ptyRequest = SSHChannelRequestEvent.PseudoTerminalRequest(
250:                 wantReply: true,
251:                 term: "xterm-256color",
252:                 terminalCharacterWidth: 80,
253:                 terminalRowHeight: 24,
254:                 terminalPixelWidth: 0,
255:                 terminalPixelHeight: 0,
256:                 terminalModes: .init([])
257:             )
258:             context.triggerUserOutboundEvent(ptyRequest, promise: nil)
259:             
260:             // Request a shell
261:             let shellRequest = SSHChannelRequestEvent.ShellRequest(wantReply: true)
262:             context.triggerUserOutboundEvent(shellRequest, promise: nil)
263:         }
264:         
265:         func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
266:             switch event {
267:             case let event as ChannelSuccessEvent:
268:                 completePromise.succeed(())
269:             case let event as ChannelFailureEvent:
270:                 completePromise.fail(SSHClientError.channelCreationFailed)
271:             default:
272:                 break
273:             }
274:         }
275:     }
276:     
277:     // MARK: - Exec Channel Handler
278:     
279:     private class ExecChannelHandler: ChannelDuplexHandler {
280:         typealias InboundIn = SSHChannelData
281:         typealias InboundOut = ByteBuffer
282:         typealias OutboundIn = ByteBuffer
283:         typealias OutboundOut = SSHChannelData
284:         
285:         private var stdoutBuffer = ByteBufferAllocator().buffer(capacity: 4096)
286:         private var stderrBuffer = ByteBufferAllocator().buffer(capacity: 4096)
287:         private var exitCode: Int?
288:         private var outputHandler: ((SSHCommandOutput) -> Void)?
289:         private var completionHandler: ((SSHCommandResult) -> Void)?
290:         
291:         init(
292:             outputHandler: ((SSHCommandOutput) -> Void)? = nil,
293:             completionHandler: ((SSHCommandResult) -> Void)? = nil
294:         ) {
295:             self.outputHandler = outputHandler
296:             self.completionHandler = completionHandler
297:         }
298:         
299:         func channelRead(context: ChannelHandlerContext, data: NIOAny) {
300:             let channelData = unwrapInboundIn(data)
301:             
302:             switch channelData.type {
303:             case .channel:
304:                 guard case .byteBuffer(let buffer) = channelData.data else { return }
305:                 
306:                 // Accumulate stdout
307:                 var mutableBuffer = buffer
308:                 stdoutBuffer.writeBuffer(&mutableBuffer)
309:                 
310:                 // Notify real-time handler
311:                 if let text = buffer.getString(at: 0, length: buffer.readableBytes) {
312:                     outputHandler?(.stdout(text))
313:                 }
314:                 
315:             case .stdErr:
316:                 guard case .byteBuffer(let buffer) = channelData.data else { return }
317:                 
318:                 // Accumulate stderr
319:                 var mutableBuffer = buffer
320:                 stderrBuffer.writeBuffer(&mutableBuffer)
321:                 
322:                 // Notify real-time handler
323:                 if let text = buffer.getString(at: 0, length: buffer.readableBytes) {
324:                     outputHandler?(.stderr(text))
325:                 }
326:                 
327:             default:
328:                 break
329:             }
330:         }
331:         
332:         func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
333:             if let exitStatus = event as? SSHChannelRequestEvent.ExitStatus {
334:                 exitCode = Int(exitStatus.exitStatus)
335:                 outputHandler?(.exit(exitStatus.exitStatus))
336:             }
337:         }
338:         
339:         func channelInactive(context: ChannelHandlerContext) {
340:             let stdout = stdoutBuffer.getString(at: 0, length: stdoutBuffer.readableBytes) ?? ""
341:             let stderr = stderrBuffer.getString(at: 0, length: stderrBuffer.readableBytes) ?? ""
342:             let result = SSHCommandResult(
343:                 stdout: stdout,
344:                 stderr: stderr,
345:                 exitCode: exitCode ?? -1,
346:                 isTimedOut: false
347:             )
348:             completionHandler?(result)
349:         }
350:         
351:         func errorCaught(context: ChannelHandlerContext, error: Error) {
352:             outputHandler?(.error(error))
353:             context.close(promise: nil)
354:         }
355:     }
356:     
357:     // MARK: - Exec Request Handler
358:     
359:     private class ExecRequestHandler: ChannelInboundHandler {
360:         typealias InboundIn = SSHChannelData
361:         
362:         let completePromise: EventLoopPromise<Void>
363:         let command: String
364:         let workingDirectory: String?
365:         let environment: [String: String]?
366:         
367:         init(
368:             command: String,
369:             workingDirectory: String? = nil,
370:             environment: [String: String]? = nil,
371:             completePromise: EventLoopPromise<Void>
372:         ) {
373:             self.command = command
374:             self.workingDirectory = workingDirectory
375:             self.environment = environment
376:             self.completePromise = completePromise
377:         }
378:         
379:         func channelActive(context: ChannelHandlerContext) {
380:             // Set environment variables if provided
381:             if let env = environment {
382:                 for (key, value) in env {
383:                     let envRequest = SSHChannelRequestEvent.EnvironmentRequest(
384:                         wantReply: false,
385:                         variableName: key,
386:                         variableValue: value
387:                     )
388:                     context.triggerUserOutboundEvent(envRequest, promise: nil)
389:                 }
390:             }
391:             
392:             // Build the command with working directory if provided
393:             let finalCommand: String
394:             if let cwd = workingDirectory {
395:                 finalCommand = "cd '\(cwd)' && \(command)"
396:             } else {
397:                 finalCommand = command
398:             }
399:             
400:             // Request exec
401:             let execRequest = SSHChannelRequestEvent.ExecRequest(
402:                 command: finalCommand,
403:                 wantReply: true
404:             )
405:             context.triggerUserOutboundEvent(execRequest, promise: nil)
406:         }
407:         
408:         func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
409:             switch event {
410:             case let event as ChannelSuccessEvent:
411:                 completePromise.succeed(())
412:             case let event as ChannelFailureEvent:
413:                 completePromise.fail(SSHClientError.commandExecutionFailed("Failed to execute command"))
414:             default:
415:                 break
416:             }
417:         }
418:     }
419:     
420:     private class ConnectionErrorHandler: ChannelInboundHandler {
421:         typealias InboundIn = Any
422:         
423:         weak var manager: SSHManager?
424:         
425:         init(manager: SSHManager) {
426:             self.manager = manager
427:         }
428:         
429:         func errorCaught(context: ChannelHandlerContext, error: Error) {
430:             print("Connection Error: \(error)")
431:             DispatchQueue.main.async {
432:                 self.manager?.handleDisconnection(error: error)
433:             }
434:             context.close(promise: nil)
435:         }
436:         
437:         func channelInactive(context: ChannelHandlerContext) {
438:             DispatchQueue.main.async {
439:                 self.manager?.handleDisconnection(error: nil)
440:             }
441:         }
442:     }
443:     
444:     // MARK: - Public Methods
445:     
446:     func connect(config: SSHConnectionConfig, completion: @escaping (Result<Void, Error>) -> Void) {
447:         self.config = config
448:         
449:         eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
450:         
451:         guard let group = eventLoopGroup else {
452:             completion(.failure(SSHClientError.connectionFailed("Failed to create event loop")))
453:             return
454:         }
455:         
456:         // Create auth delegate based on auth method
457:         let userAuthDelegate: NIOSSHClientUserAuthenticationDelegate
458:         
459:         switch config.authMethod {
460:         case .password(let password):
461:             userAuthDelegate = PasswordAuthDelegate(username: config.username, password: password)
462:             
463:         case .privateKey(let keyString, let passphrase):
464:             do {
465:                 let privateKey = try parsePrivateKey(keyString, passphrase: passphrase)
466:                 userAuthDelegate = PrivateKeyAuthDelegate(username: config.username, privateKey: privateKey)
467:             } catch {
468:                 completion(.failure(SSHClientError.invalidPrivateKey))
469:                 return
470:             }
471:         }
472:         
473:         let clientConfig = SSHClientConfiguration(
474:             userAuthDelegate: userAuthDelegate,
475:             serverAuthDelegate: AcceptAllHostKeysDelegate()
476:         )
477:         
478:         let bootstrap = ClientBootstrap(group: group)
479:             .channelInitializer { [weak self] channel in
480:                 guard let self = self else {
481:                     return channel.eventLoop.makeFailedFuture(SSHClientError.connectionFailed("Manager deallocated"))
482:                 }
483:                 
484:                 let sshHandler = NIOSSHHandler(
485:                     role: .client(clientConfig),
486:                     allocator: channel.allocator,
487:                     inboundChildChannelInitializer: nil
488:                 )
489:                 self.sshHandler = sshHandler
490:                 
491:                 return channel.pipeline.addHandlers([
492:                     sshHandler,
493:                     ConnectionErrorHandler(manager: self)
494:                 ])
495:             }
496:             .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
497:             .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
498:             .connectTimeout(.seconds(30))
499:         
500:         bootstrap.connect(host: config.host, port: config.port)
501:             .flatMap { [weak self] channel -> EventLoopFuture<Void> in
502:                 guard let self = self else {
503:                     return channel.eventLoop.makeFailedFuture(SSHClientError.connectionFailed("Manager deallocated"))
504:                 }
505:                 self.channel = channel
506:                 return self.createShellChannel(on: channel)
507:             }
508:             .whenComplete { [weak self] result in
509:                 DispatchQueue.main.async {
510:                     switch result {
511:                     case .success:
512:                         self?.isConnected = true
513:                         self?.delegate?.sshManagerDidConnect(self!)
514:                         completion(.success(()))
515:                     case .failure(let error):
516:                         self?.cleanup()
517:                         completion(.failure(error))
518:                     }
519:                 }
520:             }
521:     }
522:     
523:     private func createShellChannel(on channel: Channel) -> EventLoopFuture<Void> {
524:         guard let sshHandler = self.sshHandler else {
525:             return channel.eventLoop.makeFailedFuture(SSHClientError.channelCreationFailed)
526:         }
527:         
528:         let shellPromise = channel.eventLoop.makePromise(of: Void.self)
529:         let channelPromise = channel.eventLoop.makePromise(of: Channel.self)
530:         
531:         sshHandler.createChannel(channelPromise) { [weak self] childChannel, channelType in
532:             guard channelType == .session else {
533:                 return childChannel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
534:             }
535:             
536:             guard let self = self else {
537:                 return childChannel.eventLoop.makeFailedFuture(SSHClientError.connectionFailed("Manager deallocated"))
538:             }
539:             
540:             return childChannel.pipeline.addHandlers([
541:                 SSHChannelHandler(manager: self),
542:                 ShellRequestHandler(completePromise: shellPromise)
543:             ]).flatMap {
544:                 // Enable half-closure for proper SSH behavior
545:                 childChannel.setOption(ChannelOptions.allowRemoteHalfClosure, value: true)
546:             }
547:         }
548:         
549:         return channelPromise.futureResult.flatMap { [weak self] shellChannel in
550:             self?.shellChannel = shellChannel
551:             return shellPromise.futureResult
552:         }
553:     }
554:     
555:     func send(command: String) {
556:         guard isConnected, let shellChannel = shellChannel else {
557:             delegate?.sshManager(self, didReceiveError: "Not connected")
558:             return
559:         }
560:         
561:         let commandWithNewline = command + "\n"
562:         var buffer = shellChannel.allocator.buffer(capacity: commandWithNewline.utf8.count)
563:         buffer.writeString(commandWithNewline)
564:         
565:         let data = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
566:         shellChannel.writeAndFlush(data, promise: nil)
567:     }
568:     
569:     // MARK: - Command Execution
570:     
571:     /// Execute a single command via SSH exec channel (non-interactive)
572:     /// Captures stdout/stderr separately and returns exit code
573:     func executeCommand(
574:         command: String,
575:         workingDirectory: String? = nil,
576:         environment: [String: String]? = nil,
577:         timeout: TimeInterval = 60,
578:         completion: @escaping (Result<SSHCommandResult, Error>) -> Void
579:     ) {
580:         guard isConnected, let channel = channel, let sshHandler = sshHandler else {
581:             completion(.failure(SSHClientError.notConnected))
582:             return
583:         }
584:         
585:         let channelPromise = channel.eventLoop.makePromise(of: Channel.self)
586:         let execPromise = channel.eventLoop.makePromise(of: Void.self)
587:         
588:         var resultHandler: ((SSHCommandResult) -> Void)?
589:         var timeoutTask: DispatchWorkItem?
590:         
591:         // Create the exec channel
592:         sshHandler.createChannel(channelPromise) { childChannel, channelType in
593:             guard channelType == .session else {
594:                 return childChannel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
595:             }
596:             
597:             // Handler for accumulating output and completion
598:             let handler = ExecChannelHandler(
599:                 completionHandler: { result in
600:                     timeoutTask?.cancel()
601:                     DispatchQueue.main.async {
602:                         completion(.success(result))
603:                     }
604:                 }
605:             )
606:             
607:             resultHandler = handler.completionHandler
608:             
609:             return childChannel.pipeline.addHandlers([
610:                 handler,
611:                 ExecRequestHandler(
612:                     command: command,
613:                     workingDirectory: workingDirectory,
614:                     environment: environment,
615:                     completePromise: execPromise
616:                 )
617:             ]).flatMap {
618:                 childChannel.setOption(ChannelOptions.allowRemoteHalfClosure, value: true)
619:             }
620:         }
621:         
622:         // Handle channel creation success/failure
623:         channelPromise.futureResult.whenComplete { [weak self] result in
624:             guard let self = self else { return }
625:             
626:             switch result {
627:             case .failure(let error):
628:                 completion(.failure(error))
629:                 
630:             case .success(let execChannel):
631:                 // Set up timeout
632:                 timeoutTask = DispatchWorkItem { [weak self] in
633:                     execChannel.close(promise: nil)
634:                     let timeoutResult = SSHCommandResult(
635:                         stdout: "",
636:                         stderr: "Command timed out after \(timeout) seconds",
637:                         exitCode: -1,
638:                         isTimedOut: true
639:                     )
640:                     DispatchQueue.main.async {
641:                         completion(.success(timeoutResult))
642:                     }
643:                 }
644:                 DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutTask!)
645:             }
646:         }
647:     }
648:     
649:     /// Execute a command with real-time output streaming via AsyncStream
650:     func executeCommandAsync(
651:         command: String,
652:         workingDirectory: String? = nil,
653:         environment: [String: String]? = nil,
654:         timeout: TimeInterval = 60
655:     ) -> AsyncStream<SSHCommandOutput> {
656:         return AsyncStream { [weak self] continuation in
657:             guard let self = self, self.isConnected, let channel = self.channel, let sshHandler = self.sshHandler else {
658:                 continuation.yield(.error(SSHClientError.notConnected))
659:                 continuation.finish()
660:                 return
661:             }
662:             
663:             let channelPromise = channel.eventLoop.makePromise(of: Channel.self)
664:             let execPromise = channel.eventLoop.makePromise(of: Void.self)
665:             
666:             var timeoutTask: DispatchWorkItem?
667:             var isFinished = false
668:             
669:             func finishStream() {
670:                 guard !isFinished else { return }
671:                 isFinished = true
672:                 timeoutTask?.cancel()
673:                 continuation.finish()
674:             }
675:             
676:             // Create the exec channel with real-time output handler
677:             sshHandler.createChannel(channelPromise) { childChannel, channelType in
678:                 guard channelType == .session else {
679:                     return childChannel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
680:                 }
681:                 
682:                 let handler = ExecChannelHandler(
683:                     outputHandler: { output in
684:                         DispatchQueue.main.async {
685:                             guard !isFinished else { return }
686:                             continuation.yield(output)
687:                             
688:                             if case .exit = output {
689:                                 finishStream()
690:                             }
691:                         }
692:                     },
693:                     completionHandler: { result in
694:                         DispatchQueue.main.async {
695:                             guard !isFinished else { return }
696:                             
697:                             if result.isTimedOut {
698:                                 continuation.yield(.timeout)
699:                             } else {
700:                                 continuation.yield(.exit(result.exitCode))
701:                             }
702:                             finishStream()
703:                         }
704:                     }
705:                 )
706:                 
707:                 return childChannel.pipeline.addHandlers([
708:                     handler,
709:                     ExecRequestHandler(
710:                         command: command,
711:                         workingDirectory: workingDirectory,
712:                         environment: environment,
713:                         completePromise: execPromise
714:                     )
715:                 ]).flatMap {
716:                     childChannel.setOption(ChannelOptions.allowRemoteHalfClosure, value: true)
717:                 }
718:             }
719:             
720:             // Handle errors
721:             channelPromise.futureResult.whenFailure { error in
722:                 DispatchQueue.main.async {
723:                     guard !isFinished else { return }
724:                     continuation.yield(.error(error))
725:                     finishStream()
726:                 }
727:             }
728:             
729:             // Set up timeout
730:             timeoutTask = DispatchWorkItem { [weak self] in
731:                 DispatchQueue.main.async {
732:                     guard !isFinished else { return }
733:                     continuation.yield(.timeout)
734:                     finishStream()
735:                 }
736:             }
737:             DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutTask!)
738:             
739:             // Handle cancellation
740:             continuation.onTermination = { _ in
741:                 timeoutTask?.cancel()
742:                 channelPromise.futureResult.whenSuccess { channel in
743:                     channel.close(promise: nil)
744:                 }
745:             }
746:         }
747:     }
748:     
749:     func sendRaw(_ data: Data) {
750:         guard isConnected, let shellChannel = shellChannel else { return }
751:         
752:         var buffer = shellChannel.allocator.buffer(capacity: data.count)
753:         buffer.writeBytes(data)
754:         
755:         let channelData = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
756:         shellChannel.writeAndFlush(channelData, promise: nil)
757:     }
758:     
759:     func sendInterrupt() {
760:         // Send Ctrl+C (ASCII 3)
761:         sendRaw(Data([0x03]))
762:     }
763:     
764:     func sendTab() {
765:         // Send Tab (ASCII 9)
766:         sendRaw(Data([0x09]))
767:     }
768:     
769:     func sendEscape() {
770:         // Send Escape (ASCII 27)
771:         sendRaw(Data([0x1B]))
772:     }
773:     
774:     func resizeTerminal(width: Int, height: Int) {
775:         guard let shellChannel = shellChannel else { return }
776:         
777:         let windowChange = SSHChannelRequestEvent.WindowChangeRequest(
778:             terminalCharacterWidth: width,
779:             terminalRowHeight: height,
780:             terminalPixelWidth: 0,
781:             terminalPixelHeight: 0
782:         )
783:         
784:         shellChannel.triggerUserOutboundEvent(windowChange, promise: nil)
785:     }
786:     
787:     func disconnect() {
788:         cleanup()
789:         delegate?.sshManagerDidDisconnect(self, error: nil)
790:     }
791:     
792:     private func handleDisconnection(error: Error?) {
793:         guard isConnected else { return }
794:         cleanup()
795:         delegate?.sshManagerDidDisconnect(self, error: error)
796:     }
797:     
798:     private func cleanup() {
799:         isConnected = false
800:         
801:         shellChannel?.close(promise: nil)
802:         shellChannel = nil
803:         
804:         channel?.close(promise: nil)
805:         channel = nil
806:         
807:         sshHandler = nil
808:         
809:         try? eventLoopGroup?.syncShutdownGracefully()
810:         eventLoopGroup = nil
811:     }
812:     
813:     private func parsePrivateKey(_ keyString: String, passphrase: String?) throws -> NIOSSHPrivateKey {
814:         // Try to parse as Ed25519 first
815:         if let key = try? NIOSSHPrivateKey(ed25519Key: .init()) {
816:             // For now, generate a new key - proper PEM parsing would need implementation
817:             // This is a placeholder - real implementation would parse PEM format
818:             return key
819:         }
820:         
821:         // For production, implement proper PEM parsing:
822:         // 1. Strip headers/footers
823:         // 2. Base64 decode
824:         // 3. Parse ASN.1/DER structure
825:         // 4. Handle encryption if passphrase provided
826:         
827:         throw SSHClientError.invalidPrivateKey
828:     }
829:     
830:     deinit {
831:         cleanup()
832:     }
833: }
834: 
835: // MARK: - SSH Connection Store (Persistence)
836: 
837: class SSHConnectionStore: ObservableObject {
838:     static let shared = SSHConnectionStore()
839:     
840:     @Published var savedConnections: [SSHConnectionConfig] = []
841:     
842:     private let userDefaults = UserDefaults.standard
843:     private let storageKey = "ssh_saved_connections"
844:     
845:     init() {
846:         loadConnections()
847:     }
848:     
849:     func save(_ connection: SSHConnectionConfig) {
850:         var config = connection
851:         config.lastUsed = Date()
852:         
853:         if let index = savedConnections.firstIndex(where: { $0.id == config.id }) {
854:             savedConnections[index] = config
855:         } else {
856:             savedConnections.append(config)
857:         }
858:         
859:         persistConnections()
860:     }
861:     
862:     func delete(_ connection: SSHConnectionConfig) {
863:         savedConnections.removeAll { $0.id == connection.id }
864:         persistConnections()
865:     }
866:     
867:     func updateLastUsed(_ connection: SSHConnectionConfig) {
868:         if let index = savedConnections.firstIndex(where: { $0.id == connection.id }) {
869:             savedConnections[index].lastUsed = Date()
870:             persistConnections()
871:         }
872:     }
873:     
874:     private func loadConnections() {
875:         guard let data = userDefaults.data(forKey: storageKey),
876:               let connections = try? JSONDecoder().decode([SSHConnectionConfig].self, from: data) else {
877:             return
878:         }
879:         savedConnections = connections.sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }
880:     }
881:     
882:     private func persistConnections() {
883:         guard let data = try? JSONEncoder().encode(savedConnections) else { return }
884:         userDefaults.set(data, forKey: storageKey)
885:     }
886: }
887: 


❌ API Error (iteration 4): terminated
