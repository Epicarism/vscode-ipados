# Agent: diagnose-missing-icons
**Status:** done
**Tokens:** 4,723
**Cost:** $0.0000
**Time:** 2026-02-09T22:45:07.604Z

## Task
Find the missing icon 'f.curlybraces'. Search all swift files for 'f.curlybraces' and 'curlybraces'. Report which file uses it and what the correct SF Symbol name should be.

## Response
I'll search for the missing icon references in Swift files.

>>>TOOL search
{"query": "f.curlybraces", "glob": "*.swift"}
>>>END

Let me search for just "curlybraces" without the "f." prefix:

>>>TOOL search
{"query": "curlybraces", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "curlybraces"


Let me try a broader search without the Swift file filter:

>>>TOOL search
{"query": "curlybraces"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 5 matches:
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Models_FileItem.swift.2026-02-09T11-10-34-090Z.bak:13: case "js", "jsx": return "curlybraces"
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Models_FileItem.swift.2026-02-09T11-10-34-090Z.bak:15: case "json": return "curlybraces.square"
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:10: case "js", "jsx", "ts", "tsx": return "curlybraces"
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:14: case "json": return "curlybraces.square"
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T12-33-19-331Z.bak:628: case .stdlib: return "curlybraces"


Let me look at the current Swift files to find where the icon is being used incorrectly:

>>>TOOL search
{"query": "f.curlybraces", "glob": "**/*"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "f.curlybraces"


Let me list the directory to find the Swift files:

>>>TOOL list_dir
{"path": "."}
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
   compiler fix.md
   FULL_FEATURE_TEST_PLAN.md
   LICENSE
   MASTER_AGENT_PLAN.md
   phase1-agents.json
   README.md


>>>TOOL list_dir
{"path": "VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/
📁 .garbage/
📁 Docs/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOS.xcodeproj/
📁 VSCodeiPadOSTests/
   build_output.log
   build_output2.log
   build.log
   Info.plist
   Package.swift


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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 1-1016 of 1016)
────────────────────────────────────────
1: import SwiftUI
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
43:                         } else {
44:                             IDEWelcomeView(editorCore: editorCore, showFolderPicker: $showingFolderPicker, theme: theme)
45:                         }
46:                         
47:                         StatusBarView(editorCore: editorCore)
48:                     }
49:                 }
50:                 
51:                 if showTerminal {
52:                     PanelView(isVisible: $showTerminal, height: $terminalHeight)
53:                 }
54:             }
55:             .background(theme.editorBackground)
56:             
57:             // Overlays - Command Palette (Cmd+Shift+P)
58:             if editorCore.showCommandPalette {
59:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showCommandPalette = false }
60:                 CommandPaletteView(editorCore: editorCore, showSettings: $showSettings, showTerminal: $showTerminal)
61:             }
62:             
63:             // Quick Open (Cmd+P)
64:             if editorCore.showQuickOpen {
65:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showQuickOpen = false }
66:                 QuickOpenView(editorCore: editorCore, fileNavigator: fileNavigator)
67:             }
68:             
69:             // Go To Symbol (Cmd+Shift+O)
70:             if editorCore.showGoToSymbol {
71:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToSymbol = false }
72:                 GoToSymbolView(editorCore: editorCore, onGoToLine: { _ in })
73:             }
74:             
75:             // AI Assistant
76:             if editorCore.showAIAssistant {
77:                 HStack { Spacer(); IDEAIAssistant(editorCore: editorCore, theme: theme).frame(width: 400, height: 500).padding() }
78:             }
79:             
80:             // Go To Line (Ctrl+G)
81:             if editorCore.showGoToLine {
82:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToLine = false }
83:                 GoToLineView(isPresented: $editorCore.showGoToLine, onGoToLine: { _ in })
84:             }
85:             
86:             // Workspace Trust Dialog
87:             if let trustURL = pendingTrustURL {
88:                 Color.black.opacity(0.4).ignoresSafeArea()
89:                 WorkspaceTrustDialog(workspaceURL: trustURL, onTrust: {
90:                     trustManager.trust(url: trustURL)
91:                     finishOpeningWorkspace(trustURL)
92:                     pendingTrustURL = nil
93:                 }, onCancel: {
94:                     pendingTrustURL = nil
95:                 })
96:             }
97:         }
98:         .sheet(isPresented: $showingDocumentPicker) { IDEDocumentPicker(editorCore: editorCore) }
99:         .sheet(isPresented: $showingFolderPicker) {
100:             IDEFolderPicker(fileNavigator: fileNavigator) { url in
101:                 if trustManager.isTrusted(url: url) {
102:                     finishOpeningWorkspace(url)
103:                 } else {
104:                     pendingTrustURL = url
105:                 }
106:             }
107:         }
108:         .sheet(isPresented: $showSettings) { SettingsView(themeManager: themeManager) }
109:         .onChange(of: editorCore.showFilePicker) { show in showingDocumentPicker = show }
110:         .onChange(of: editorCore.activeTab?.fileName) { newFileName in
111:             updateWindowTitle()
112:         }
113:         .onChange(of: editorCore.tabs.count) { _ in
114:             updateWindowTitle()
115:         }
116:         .onAppear {
117:             updateWindowTitle()
118:         }
119:         .environmentObject(themeManager)
120:         .environmentObject(editorCore)
121:     }
122:     
123:     private func finishOpeningWorkspace(_ url: URL) {
124:         fileNavigator.loadFileTree(at: url)
125:         Task { @MainActor in
126:             LaunchManager.shared.setWorkspaceRoot(url)
127:             GitManager.shared.setWorkingDirectory(url)
128:         }
129:     }
130:     
131:     private func updateWindowTitle() {
132:         if let activeTab = editorCore.activeTab {
133:             let fileName = activeTab.fileName
134:             let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
135:             windowTitle = "\(unsavedIndicator)\(fileName) - VS Code"
136:         } else if !editorCore.tabs.isEmpty {
137:             windowTitle = "VS Code"
138:         } else {
139:             windowTitle = "Welcome - VS Code"
140:         }
141:         
142:         // Notify the app of the title change
143:         NotificationCenter.default.post(
144:             name: NSNotification.Name("WindowTitleDidChange"),
145:             object: nil,
146:             userInfo: ["title": windowTitle]
147:         )
148:     }
149:     
150:     @ViewBuilder
151:     private var sidebarContent: some View {
152:         switch selectedSidebarTab {
153:         case 0:
154:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
155:         case 1:
156:             SidebarSearchView(theme: theme)
157:         case 2:
158:             GitView()
159:         case 3:
160:             DebugView()
161:         default:
162:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
163:         }
164:     }
165: }
166: 
167: // MARK: - Activity Bar
168: 
169: 
170: 
171: struct BarButton: View {
172:     let icon: String
173:     let isSelected: Bool
174:     let theme: Theme
175:     let action: () -> Void
176:     
177:     var body: some View {
178:         Button(action: action) {
179:             Image(systemName: icon)
180:                 .font(.system(size: 22))
181:                 .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
182:                 .frame(width: 48, height: 48)
183:         }
184:     }
185: }
186: 
187: // MARK: - Sidebar with Real File System
188: 
189: struct IDESidebarFiles: View {
190:     @ObservedObject var editorCore: EditorCore
191:     @ObservedObject var fileNavigator: FileSystemNavigator
192:     @Binding var showFolderPicker: Bool
193:     let theme: Theme
194:     
195:     var body: some View {
196:         VStack(alignment: .leading, spacing: 0) {
197:             HStack {
198:                 Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
199:                 Spacer()
200:                 Button(action: { showFolderPicker = true }) {
201:                     Image(systemName: "folder.badge.plus").font(.caption)
202:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
203:                 Button(action: { editorCore.showFilePicker = true }) {
204:                     Image(systemName: "doc.badge.plus").font(.caption)
205:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
206:                 if fileNavigator.fileTree != nil {
207:                     Button(action: { fileNavigator.refreshFileTree() }) {
208:                         Image(systemName: "arrow.clockwise").font(.caption)
209:                     }.foregroundColor(theme.sidebarForeground.opacity(0.7))
210:                 }
211:             }.padding(.horizontal, 12).padding(.vertical, 8)
212:             
213:             ScrollView {
214:                 VStack(alignment: .leading, spacing: 2) {
215:                     if let tree = fileNavigator.fileTree {
216:                         FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
217:                     } else {
218:                         DemoFileTree(editorCore: editorCore, theme: theme)
219:                     }
220:                 }.padding(.horizontal, 8)
221:             }
222:         }.background(theme.sidebarBackground)
223:     }
224: }
225: 
226: struct RealFileTreeView: View {
227:     let node: FileTreeNode
228:     let level: Int
229:     @ObservedObject var fileNavigator: FileSystemNavigator
230:     @ObservedObject var editorCore: EditorCore
231:     let theme: Theme
232:     
233:     var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
234:     
235:     var body: some View {
236:         VStack(alignment: .leading, spacing: 2) {
237:             HStack(spacing: 4) {
238:                 if node.isDirectory {
239:                     Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
240:                         .font(.caption2).frame(width: 12)
241:                         .foregroundColor(theme.sidebarForeground.opacity(0.6))
242:                         .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
243:                 } else {
244:                     Spacer().frame(width: 12)
245:                 }
246:                 Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
247:                     .font(.caption)
248:                     .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
249:                 Text(node.name).font(.system(.caption)).lineLimit(1)
250:                     .foregroundColor(theme.sidebarForeground)
251:                 Spacer()
252:             }
253:             .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
254:             .contentShape(Rectangle())
255:             .onTapGesture {
256:                 if node.isDirectory {
257:                     fileNavigator.toggleExpanded(path: node.url.path)
258:                 } else {
259:                     editorCore.openFile(from: node.url)
260:                 }
261:             }
262:             
263:             if isExpanded && node.isDirectory {
264:                 ForEach(node.children) { child in
265:                     RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
266:                 }
267:             }
268:         }
269:     }
270: }
271: 
272: struct DemoFileTree: View {
273:     @ObservedObject var editorCore: EditorCore
274:     let theme: Theme
275:     
276:     var body: some View {
277:         VStack(alignment: .leading, spacing: 4) {
278:             Text("Open a folder to browse files")
279:                 .font(.caption)
280:                 .foregroundColor(theme.sidebarForeground.opacity(0.6))
281:                 .padding(.vertical, 8)
282:             
283:             DemoFileRow(name: "main.swift", editorCore: editorCore, theme: theme)
284:             DemoFileRow(name: "ContentView.swift", editorCore: editorCore, theme: theme)
285:             DemoFileRow(name: "README.md", editorCore: editorCore, theme: theme)
286:         }
287:     }
288: }
289: 
290: struct DemoFileRow: View {
291:     let name: String
292:     @ObservedObject var editorCore: EditorCore
293:     let theme: Theme
294:     
295:     var body: some View {
296:         HStack(spacing: 4) {
297:             Spacer().frame(width: 12)
298:             Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
299:             Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
300:             Spacer()
301:         }
302:         .padding(.vertical, 4)
303:         .contentShape(Rectangle())
304:         .onTapGesture {
305:             editorCore.addTab(fileName: name, content: "// \(name)\n\n")
306:         }
307:     }
308: }
309: 
310: // MARK: - Tab Bar
311: 
312: struct IDETabBar: View {
313:     @ObservedObject var editorCore: EditorCore
314:     let theme: Theme
315:     
316:     var body: some View {
317:         ScrollView(.horizontal, showsIndicators: false) {
318:             HStack(spacing: 0) {
319:                 ForEach(editorCore.tabs) { tab in
320:                     IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
321:                 }
322:                 Button(action: { editorCore.addTab() }) {
323:                     Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
324:                 }
325:             }.padding(.horizontal, 4)
326:         }.frame(height: 36).background(theme.tabBarBackground)
327:     }
328: }
329: 
330: struct IDETabItem: View {
331:     let tab: Tab
332:     let isSelected: Bool
333:     @ObservedObject var editorCore: EditorCore
334:     let theme: Theme
335:     
336:     var body: some View {
337:         HStack(spacing: 6) {
338:             Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
339:             Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
340:                 .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
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
431:                                     cursorIndex = tempCursor
432:                                     requestedCursorIndex = tempCursor
433:                                     showAutocomplete = false
434:                                     return true
435:                                 }
436:                                 return false
437:                             },
438:                             onDismissAutocomplete: {
439:                                 guard showAutocomplete else { return false }
440:                                 autocomplete.hideSuggestions()
441:                                 showAutocomplete = false
442:                                 return true
443:                             }
444:                         )
445:                         .onChange(of: text) { newValue in
446:                             editorCore.updateActiveTabContent(newValue)
447:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
448:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
449:                             showAutocomplete = autocomplete.showSuggestions
450:                             foldingManager.detectFoldableRegions(in: newValue)
451:                         }
452:                         .onChange(of: cursorIndex) { newCursor in
453:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
454:                             showAutocomplete = autocomplete.showSuggestions
455:                         }
456:                     }
457:                     
458:                     if !tab.fileName.hasSuffix(".json") {
459:                         MinimapView(
460:                             content: text,
461:                             scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
462:                             scrollViewHeight: .constant(geometry.size.height),
463:                             totalContentHeight: CGFloat(totalLines) * lineHeight
464:                         )
465:                         .frame(width: 80)
466:                     }
467:                 }
468:                 .background(theme.editorBackground)
469: 
470:                 // Sticky Header Overlay (FEAT-040)
471:                 StickyHeaderView(
472:                     text: text,
473:                     currentLine: scrollPosition,
474:                     theme: theme,
475:                     lineHeight: lineHeight,
476:                     onSelect: { line in
477:                         requestedLineSelection = line
478:                     }
479:                 )
480:                 .padding(.leading, lineNumbersStyle != "off" ? 60 : 0)
481:                 .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
482: 
483:                 if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
484:                     AutocompletePopup(
485:                         suggestions: autocomplete.suggestionItems,
486:                         selectedIndex: autocomplete.selectedIndex,
487:                         theme: theme
488:                     ) { index in
489:                         autocomplete.selectedIndex = index
490:                         var tempText = text
491:                         var tempCursor = cursorIndex
492:                         autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
493:                         if tempText != text {
494:                             text = tempText
495:                             cursorIndex = tempCursor
496:                             requestedCursorIndex = tempCursor
497:                         }
498:                         showAutocomplete = false
499:                     }
500:                     .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
501:                 }
502:             }
503:         }
504:         }
505:         .onAppear {
506:             text = tab.content
507:             foldingManager.detectFoldableRegions(in: text)
508:         }
509:         .onChange(of: tab.id) { _ in
510:             text = tab.content
511:             foldingManager.detectFoldableRegions(in: text)
512:         }
513:         .onChange(of: currentLineNumber) { line in
514:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
515:         }
516:         .onChange(of: currentColumn) { col in
517:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
518:         }
519:         .onAppear {
520:             findViewModel.editorCore = editorCore
521:         }
522:     }
523:     
524:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
525: }
526: 
527: // MARK: - Line Numbers with Folding
528: 
529: struct LineNumbersWithFolding: View {
530:     let fileId: String
531:     let totalLines: Int
532:     let currentLine: Int
533:     let scrollOffset: CGFloat
534:     let lineHeight: CGFloat
535:     @Binding var requestedLineSelection: Int?
536:     @ObservedObject var foldingManager: CodeFoldingManager
537:     @ObservedObject private var debugManager = DebugManager.shared
538:     let theme: Theme
539: 
540:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
541: 
542:     var body: some View {
543:         ScrollView(showsIndicators: false) {
544:             VStack(alignment: .trailing, spacing: 0) {
545:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
546:                     if !foldingManager.isLineFolded(line: lineIndex) {
547:                         HStack(spacing: 2) {
548:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
549:                                 Circle()
550:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
551:                                     .overlay(
552:                                         Circle()
553:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
554:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
555:                                     )
556:                                     .frame(width: 10, height: 10)
557:                                     .padding(.leading, 2)
558:                             }
559:                             .buttonStyle(.plain)
560:                             .frame(width: 14, height: lineHeight)
561: 
562:                             if foldingManager.isFoldable(line: lineIndex) {
563:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
564:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
565:                                         .font(.system(size: 8))
566:                                         .foregroundColor(theme.lineNumber)
567:                                 }
568:                                 .buttonStyle(.plain)
569:                                 .frame(width: 14, height: lineHeight)
570:                             } else {
571:                                 Spacer().frame(width: 14)
572:                             }
573: 
574:                             Text(displayText(for: lineIndex))
575:                                 .font(.system(size: 12, design: .monospaced))
576:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
577:                                 .frame(height: lineHeight)
578:                                 .contentShape(Rectangle())
579:                                 .onTapGesture {
580:                                     // FEAT-041: click line number selects entire line
581:                                     requestedLineSelection = lineIndex
582:                                 }
583:                         }
584:                         .frame(maxWidth: .infinity, alignment: .trailing)
585:                         .padding(.trailing, 4)
586:                     }
587:                 }
588:             }
589:             .offset(y: -scrollOffset)
590:         }
591:     }
592: 
593:     private func displayText(for lineIndex: Int) -> String {
594:         switch lineNumbersStyle {
595:         case "relative":
596:             // VS Code-style: current line shows absolute, others show relative distance
597:             let lineNumber = lineIndex + 1
598:             if lineNumber == currentLine { return "\(lineNumber)" }
599:             return "\(abs(lineNumber - currentLine))"
600: 
601:         case "interval":
602:             let lineNumber = lineIndex + 1
603:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
604: 
605:         default:
606:             return "\(lineIndex + 1)"
607:         }
608:     }
609: }
610: 
611: // MARK: - Autocomplete Popup
612: 
613: struct AutocompletePopup: View {
614:     let suggestions: [AutocompleteSuggestion]
615:     let selectedIndex: Int
616:     let theme: Theme
617:     let onSelectIndex: (Int) -> Void
618:     
619:     var body: some View {
620:         VStack(alignment: .leading, spacing: 0) {
621:             ForEach(suggestions.indices, id: \.self) { index in
622:                 let s = suggestions[index]
623:                 HStack(spacing: 6) {
624:                     Image(systemName: icon(for: s.kind))
625:                         .font(.caption)
626:                         .foregroundColor(color(for: s.kind))
627:                     VStack(alignment: .leading, spacing: 1) {
628:                         Text(s.displayText)
629:                             .font(.system(size: 12, design: .monospaced))
630:                             .foregroundColor(theme.editorForeground)
631:                         if s.insertText != s.displayText && !s.insertText.isEmpty {
632:                             Text(s.insertText)
633:                                 .font(.system(size: 10, design: .monospaced))
634:                                 .foregroundColor(theme.editorForeground.opacity(0.55))
635:                                 .lineLimit(1)
636:                         }
637:                     }
638:                     Spacer()
639:                 }
640:                 .padding(.horizontal, 8).padding(.vertical, 6)
641:                 .background(index == selectedIndex ? theme.selection : Color.clear)
642:                 .contentShape(Rectangle())
643:                 .onTapGesture { onSelectIndex(index) }
644:             }
645:         }
646:         .frame(width: 260)
647:         .background(theme.editorBackground)
648:         .cornerRadius(6)
649:         .shadow(radius: 8)
650:     }
651:     
652:     private func icon(for kind: AutocompleteSuggestionKind) -> String {
653:         switch kind {
654:         case .keyword: return "key.fill"
655:         case .symbol: return "cube.fill"
656:         case .stdlib: return "curlybraces"
657:         case .member: return "arrow.right.circle.fill"
658:         }
659:     }
660:     
661:     private func color(for kind: AutocompleteSuggestionKind) -> Color {
662:         switch kind {
663:         case .keyword: return .purple
664:         case .symbol: return .blue
665:         case .stdlib: return .orange
666:         case .member: return .green
667:         }
668:     }
669: }
670: 
671: // MARK: - Welcome View
672: 
673: struct IDEWelcomeView: View {
674:     @ObservedObject var editorCore: EditorCore
675:     @Binding var showFolderPicker: Bool
676:     let theme: Theme
677:     
678:     var body: some View {
679:         VStack(spacing: 24) {
680:             Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 80)).foregroundColor(theme.editorForeground.opacity(0.3))
681:             Text("VS Code for iPadOS").font(.largeTitle).fontWeight(.bold).foregroundColor(theme.editorForeground)
682:             VStack(alignment: .leading, spacing: 12) {
683:                 WelcomeBtn(icon: "doc.badge.plus", title: "New File", shortcut: "⌘N", theme: theme) { editorCore.addTab() }
684:                 WelcomeBtn(icon: "folder", title: "Open Folder", shortcut: "⌘⇧O", theme: theme) { showFolderPicker = true }
685:                 WelcomeBtn(icon: "doc", title: "Open File", shortcut: "⌘O", theme: theme) { editorCore.showFilePicker = true }
686:                 WelcomeBtn(icon: "terminal", title: "Command Palette", shortcut: "⌘⇧P", theme: theme) { editorCore.showCommandPalette = true }
687:             }
688:         }.frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.editorBackground)
689:     }
690: }
691: 
692: struct WelcomeBtn: View {
693:     let icon: String
694:     let title: String
695:     let shortcut: String
696:     let theme: Theme
697:     let action: () -> Void
698:     
699:     var body: some View {
700:         Button(action: action) {
701:             HStack {
702:                 Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
703:                 Text(title).foregroundColor(theme.editorForeground)
704:                 Spacer()
705:                 Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
706:             }
707:             .padding().frame(width: 280)
708:             .background(theme.sidebarBackground)
709:             .cornerRadius(8)
710:         }.buttonStyle(.plain)
711:     }
712: }
713: 
714: // MARK: - Command Palette
715: 
716: struct IDECommandPalette: View {
717:     @ObservedObject var editorCore: EditorCore
718:     @Binding var showSettings: Bool
719:     @Binding var showTerminal: Bool
720:     @State private var searchText = ""
721:     
722:     var body: some View {
723:         VStack(spacing: 0) {
724:             HStack {
725:                 Image(systemName: "magnifyingglass").foregroundColor(.secondary)
726:                 TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
727:             }.padding().background(Color(UIColor.secondarySystemBackground))
728:             Divider()
729:             ScrollView {
730:                 VStack(spacing: 0) {
731:                     CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
732:                     CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
733:                     CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
734:                     CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
735:                     CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
736:                     CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
737:                     CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
738:                     CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
739:                 }.padding(.vertical, 8)
740:             }
741:         }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
742:     }
743: }
744: 
745: struct CommandRow: View {
746:     let icon: String; let name: String; let shortcut: String; let action: () -> Void
747:     var body: some View {
748:         Button(action: action) {
749:             HStack {
750:                 Image(systemName: icon).foregroundColor(.accentColor).frame(width: 24)
751:                 Text(name).foregroundColor(.primary)
752:                 Spacer()
753:                 Text(shortcut).font(.caption).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 4).background(Color(UIColor.tertiarySystemFill)).cornerRadius(4)
754:             }.padding(.horizontal).padding(.vertical, 12).contentShape(Rectangle())
755:         }.buttonStyle(.plain)
756:     }
757: }
758: 
759: // MARK: - Quick Open
760: 
761: struct IDEQuickOpen: View {
762:     @ObservedObject var editorCore: EditorCore
763:     @State private var searchText = ""
764:     
765:     var body: some View {
766:         VStack(spacing: 0) {
767:             HStack {
768:                 Image(systemName: "magnifyingglass").foregroundColor(.gray)
769:                 TextField("Search files...", text: $searchText).textFieldStyle(.plain)
770:             }.padding().background(Color(UIColor.secondarySystemBackground))
771:             Divider()
772:             ScrollView {
773:                 VStack(alignment: .leading, spacing: 0) {
774:                     ForEach(editorCore.tabs) { tab in
775:                         QuickOpenRow(name: tab.fileName, path: "") {
776:                             editorCore.selectTab(id: tab.id)
777:                             editorCore.showQuickOpen = false
778:                         }
779:                     }
780:                 }
781:             }.frame(maxHeight: 350)
782:         }.frame(width: 500).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
783:     }
784: }
785: 
786: struct QuickOpenRow: View {
787:     let name: String; let path: String; let action: () -> Void
788:     var body: some View {
789:         Button(action: action) {
790:             HStack {
791:                 Image(systemName: fileIcon(for: name)).foregroundColor(fileColor(for: name)).frame(width: 20)
792:                 VStack(alignment: .leading, spacing: 2) { Text(name).font(.system(size: 14)); Text(path + name).font(.system(size: 11)).foregroundColor(.secondary) }
793:                 Spacer()
794:             }.padding(.horizontal).padding(.vertical, 8).contentShape(Rectangle())
795:         }.buttonStyle(.plain)
796:     }
797: }
798: 
799: // MARK: - AI Assistant
800: 
801: struct IDEAIAssistant: View {
802:     @ObservedObject var editorCore: EditorCore
803:     let theme: Theme
804:     @State private var userInput = ""
805:     @State private var messages: [(id: UUID, role: String, content: String)] = [(UUID(), "assistant", "Hello! I'm your AI coding assistant. How can I help?")]
806:     
807:     var body: some View {
808:         VStack(spacing: 0) {
809:             HStack {
810:                 Image(systemName: "brain").foregroundColor(.blue)
811:                 Text("AI Assistant").font(.headline).foregroundColor(theme.editorForeground)
812:                 Spacer()
813:                 Button(action: { editorCore.showAIAssistant = false }) { Image(systemName: "xmark.circle.fill").foregroundColor(theme.editorForeground.opacity(0.5)) }
814:             }.padding().background(theme.sidebarBackground)
815:             
816:             ScrollView {
817:                 LazyVStack(alignment: .leading, spacing: 12) {
818:                     ForEach(messages, id: \.id) { msg in
819:                         HStack {
820:                             if msg.role == "user" { Spacer(minLength: 60) }
821:                             Text(msg.content).padding(12).background(RoundedRectangle(cornerRadius: 12).fill(msg.role == "user" ? Color.blue : theme.sidebarBackground)).foregroundColor(msg.role == "user" ? .white : theme.editorForeground)
822:                             if msg.role == "assistant" { Spacer(minLength: 60) }
823:                         }
824:                     }
825:                 }.padding()
826:             }.background(theme.editorBackground)
827:             
828:             HStack(spacing: 12) {
829:                 TextField("Ask about your code...", text: $userInput).textFieldStyle(.roundedBorder)
830:                 Button(action: { sendMessage() }) { Image(systemName: "paperplane.fill").foregroundColor(userInput.isEmpty ? .gray : .blue) }.disabled(userInput.isEmpty)
831:             }.padding().background(theme.sidebarBackground)
832:         }.background(theme.editorBackground).cornerRadius(12).shadow(radius: 20)
833:     }
834:     
835:     func sendMessage() {
836:         guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
837:         messages.append((UUID(), "user", userInput))
838:         let input = userInput
839:         userInput = ""
840:         DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
841:             messages.append((UUID(), "assistant", "I can help with '\(input)'! What specifically would you like to know?"))
842:         }
843:     }
844: }
845: 
846: // MARK: - Status Bar
847: 
848: 
849: 
850: // MARK: - Folder Picker
851: 
852: struct IDEFolderPicker: UIViewControllerRepresentable {
853:     @ObservedObject var fileNavigator: FileSystemNavigator
854:     var onPick: ((URL) -> Void)?
855:     
856:     init(fileNavigator: FileSystemNavigator, onPick: ((URL) -> Void)? = nil) {
857:         self.fileNavigator = fileNavigator
858:         self.onPick = onPick
859:     }
860:     
861:     func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
862:         let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
863:         picker.delegate = context.coordinator
864:         return picker
865:     }
866:     
867:     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
868:     
869:     func makeCoordinator() -> Coordinator { Coordinator(self) }
870:     
871:     class Coordinator: NSObject, UIDocumentPickerDelegate {
872:         let parent: IDEFolderPicker
873:         init(_ parent: IDEFolderPicker) { self.parent = parent }
874:         
875:         func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
876:             if let url = urls.first {
877:                 _ = url.startAccessingSecurityScopedResource()
878:                 if let onPick = parent.onPick {
879:                     onPick(url)
880:                 } else {
881:                     // Default behavior if no custom handler
882:                     parent.fileNavigator.loadFileTree(at: url)
883:                     Task { @MainActor in
884:                         LaunchManager.shared.setWorkspaceRoot(url)
885:                         GitManager.shared.setWorkingDirectory(url)
886:                     }
887:                 }
888:             }
889:         }
890:     }
891: }
892: 
893: // MARK: - Document Picker
894: 
895: struct IDEDocumentPicker: UIViewControllerRepresentable {
896:     @ObservedObject var editorCore: EditorCore
897:     
898:     func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
899:         let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .sourceCode, .json, .plainText, .data])
900:         picker.allowsMultipleSelection = true
901:         picker.delegate = context.coordinator
902:         return picker
903:     }
904:     
905:     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
906:     
907:     func makeCoordinator() -> Coordinator { Coordinator(editorCore: editorCore) }
908:     
909:     class Coordinator: NSObject, UIDocumentPickerDelegate {
910:         let editorCore: EditorCore
911:         init(editorCore: EditorCore) { self.editorCore = editorCore }
912:         
913:         func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
914:             for url in urls { editorCore.openFile(from: url) }
915:             editorCore.showFilePicker = false
916:         }
917:         
918:         func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
919:             editorCore.showFilePicker = false
920:         }
921:     }
922: }
923: 
924: // MARK: - Sidebar Search View
925: 
926: struct SidebarSearchView: View {
927:     let theme: Theme
928:     @State private var searchText = ""
929:     @State private var replaceText = ""
930:     @State private var showReplace = false
931:     @State private var searchResults: [(fileName: String, line: Int, preview: String)] = []
932:     
933:     var body: some View {
934:         VStack(alignment: .leading, spacing: 0) {
935:             HStack {
936:                 Text("SEARCH").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
937:                 Spacer()
938:             }.padding(.horizontal, 12).padding(.vertical, 8)
939:             
940:             HStack(spacing: 4) {
941:                 Image(systemName: "magnifyingglass").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
942:                 TextField("Search", text: $searchText).textFieldStyle(.plain).font(.system(size: 13))
943:                     .foregroundColor(theme.sidebarForeground)
944:                 if !searchText.isEmpty {
945:                     Button(action: { searchText = "" }) {
946:                         Image(systemName: "xmark.circle.fill").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
947:                     }
948:                 }
949:             }
950:             .padding(8)
951:             .background(theme.editorBackground)
952:             .cornerRadius(6)
953:             .padding(.horizontal, 12)
954:             
955:             HStack {
956:                 Button(action: { showReplace.toggle() }) {
957:                     Image(systemName: showReplace ? "chevron.down" : "chevron.right").font(.caption2)
958:                     Text("Replace").font(.caption)
959:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
960:                 Spacer()
961:             }.padding(.horizontal, 12).padding(.vertical, 6)
962:             
963:             if showReplace {
964:                 HStack(spacing: 4) {
965:                     Image(systemName: "arrow.right").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
966:                     TextField("Replace", text: $replaceText).textFieldStyle(.plain).font(.system(size: 13))
967:                         .foregroundColor(theme.sidebarForeground)
968:                 }
969:                 .padding(8)
970:                 .background(theme.editorBackground)
971:                 .cornerRadius(6)
972:                 .padding(.horizontal, 12)
973:             }
974:             
975:             Divider().padding(.top, 8)
976:             
977:             if searchText.isEmpty {
978:                 VStack(spacing: 8) {
979:                     Spacer()
980:                     Image(systemName: "magnifyingglass").font(.largeTitle).foregroundColor(theme.sidebarForeground.opacity(0.3))
981:                     Text("Search in files").font(.caption).foregroundColor(theme.sidebarForeground.opacity(0.6))
982:                     Spacer()
983:                 }.frame(maxWidth: .infinity)
984:             } else {
985:                 ScrollView {
986:                     LazyVStack(alignment: .leading, spacing: 0) {
987:                         ForEach(0..<searchResults.count, id: \.self) { i in
988:                             let result = searchResults[i]
989:                             VStack(alignment: .leading, spacing: 2) {
990:                                 HStack {
991:                                     Image(systemName: "doc.text").font(.caption2).foregroundColor(theme.sidebarForeground.opacity(0.6))
992:                                     Text(result.fileName).font(.system(size: 11, weight: .medium)).foregroundColor(theme.sidebarForeground)
993:                                     Spacer()
994:                                     Text(":\(result.line)").font(.system(size: 10, design: .monospaced)).foregroundColor(theme.sidebarForeground.opacity(0.6))
995:                                 }
996:                                 Text(result.preview).font(.system(size: 11, design: .monospaced)).foregroundColor(theme.sidebarForeground.opacity(0.7)).lineLimit(1)
997:                             }.padding(.horizontal, 12).padding(.vertical, 6)
998:                         }
999:                     }
1000:                 }
1001:             }
1002:         }
1003:         .background(theme.sidebarBackground)
1004:         .onChange(of: searchText) { query in
1005:             if query.isEmpty { searchResults = [] }
1006:             else { searchResults = [("ContentView.swift", 15, "Text(\"\(query)\")"), ("main.swift", 8, "// \(query)")] }
1007:         }
1008:     }
1009: }
1010: 
1011: // MARK: - Preview
1012: 
1013: #Preview {
1014:     ContentView()
1015: }
1016: 


I found the usage. The icon `curlybraces` is used at line 656 in `ContentView.swift` for the `.stdlib` autocomplete suggestion kind. Let me also check the FileHelpers extension where other file icons are defined:

>>>TOOL search
{"query": "fileIcon", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "fileIcon"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 1-1016 of 1016)
────────────────────────────────────────
1: import SwiftUI
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
43:                         } else {
44:                             IDEWelcomeView(editorCore: editorCore, showFolderPicker: $showingFolderPicker, theme: theme)
45:                         }
46:                         
47:                         StatusBarView(editorCore: editorCore)
48:                     }
49:                 }
50:                 
51:                 if showTerminal {
52:                     PanelView(isVisible: $showTerminal, height: $terminalHeight)
53:                 }
54:             }
55:             .background(theme.editorBackground)
56:             
57:             // Overlays - Command Palette (Cmd+Shift+P)
58:             if editorCore.showCommandPalette {
59:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showCommandPalette = false }
60:                 CommandPaletteView(editorCore: editorCore, showSettings: $showSettings, showTerminal: $showTerminal)
61:             }
62:             
63:             // Quick Open (Cmd+P)
64:             if editorCore.showQuickOpen {
65:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showQuickOpen = false }
66:                 QuickOpenView(editorCore: editorCore, fileNavigator: fileNavigator)
67:             }
68:             
69:             // Go To Symbol (Cmd+Shift+O)
70:             if editorCore.showGoToSymbol {
71:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToSymbol = false }
72:                 GoToSymbolView(editorCore: editorCore, onGoToLine: { _ in })
73:             }
74:             
75:             // AI Assistant
76:             if editorCore.showAIAssistant {
77:                 HStack { Spacer(); IDEAIAssistant(editorCore: editorCore, theme: theme).frame(width: 400, height: 500).padding() }
78:             }
79:             
80:             // Go To Line (Ctrl+G)
81:             if editorCore.showGoToLine {
82:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToLine = false }
83:                 GoToLineView(isPresented: $editorCore.showGoToLine, onGoToLine: { _ in })
84:             }
85:             
86:             // Workspace Trust Dialog
87:             if let trustURL = pendingTrustURL {
88:                 Color.black.opacity(0.4).ignoresSafeArea()
89:                 WorkspaceTrustDialog(workspaceURL: trustURL, onTrust: {
90:                     trustManager.trust(url: trustURL)
91:                     finishOpeningWorkspace(trustURL)
92:                     pendingTrustURL = nil
93:                 }, onCancel: {
94:                     pendingTrustURL = nil
95:                 })
96:             }
97:         }
98:         .sheet(isPresented: $showingDocumentPicker) { IDEDocumentPicker(editorCore: editorCore) }
99:         .sheet(isPresented: $showingFolderPicker) {
100:             IDEFolderPicker(fileNavigator: fileNavigator) { url in
101:                 if trustManager.isTrusted(url: url) {
102:                     finishOpeningWorkspace(url)
103:                 } else {
104:                     pendingTrustURL = url
105:                 }
106:             }
107:         }
108:         .sheet(isPresented: $showSettings) { SettingsView(themeManager: themeManager) }
109:         .onChange(of: editorCore.showFilePicker) { show in showingDocumentPicker = show }
110:         .onChange(of: editorCore.activeTab?.fileName) { newFileName in
111:             updateWindowTitle()
112:         }
113:         .onChange(of: editorCore.tabs.count) { _ in
114:             updateWindowTitle()
115:         }
116:         .onAppear {
117:             updateWindowTitle()
118:         }
119:         .environmentObject(themeManager)
120:         .environmentObject(editorCore)
121:     }
122:     
123:     private func finishOpeningWorkspace(_ url: URL) {
124:         fileNavigator.loadFileTree(at: url)
125:         Task { @MainActor in
126:             LaunchManager.shared.setWorkspaceRoot(url)
127:             GitManager.shared.setWorkingDirectory(url)
128:         }
129:     }
130:     
131:     private func updateWindowTitle() {
132:         if let activeTab = editorCore.activeTab {
133:             let fileName = activeTab.fileName
134:             let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
135:             windowTitle = "\(unsavedIndicator)\(fileName) - VS Code"
136:         } else if !editorCore.tabs.isEmpty {
137:             windowTitle = "VS Code"
138:         } else {
139:             windowTitle = "Welcome - VS Code"
140:         }
141:         
142:         // Notify the app of the title change
143:         NotificationCenter.default.post(
144:             name: NSNotification.Name("WindowTitleDidChange"),
145:             object: nil,
146:             userInfo: ["title": windowTitle]
147:         )
148:     }
149:     
150:     @ViewBuilder
151:     private var sidebarContent: some View {
152:         switch selectedSidebarTab {
153:         case 0:
154:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
155:         case 1:
156:             SidebarSearchView(theme: theme)
157:         case 2:
158:             GitView()
159:         case 3:
160:             DebugView()
161:         default:
162:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
163:         }
164:     }
165: }
166: 
167: // MARK: - Activity Bar
168: 
169: 
170: 
171: struct BarButton: View {
172:     let icon: String
173:     let isSelected: Bool
174:     let theme: Theme
175:     let action: () -> Void
176:     
177:     var body: some View {
178:         Button(action: action) {
179:             Image(systemName: icon)
180:                 .font(.system(size: 22))
181:                 .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
182:                 .frame(width: 48, height: 48)
183:         }
184:     }
185: }
186: 
187: // MARK: - Sidebar with Real File System
188: 
189: struct IDESidebarFiles: View {
190:     @ObservedObject var editorCore: EditorCore
191:     @ObservedObject var fileNavigator: FileSystemNavigator
192:     @Binding var showFolderPicker: Bool
193:     let theme: Theme
194:     
195:     var body: some View {
196:         VStack(alignment: .leading, spacing: 0) {
197:             HStack {
198:                 Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
199:                 Spacer()
200:                 Button(action: { showFolderPicker = true }) {
201:                     Image(systemName: "folder.badge.plus").font(.caption)
202:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
203:                 Button(action: { editorCore.showFilePicker = true }) {
204:                     Image(systemName: "doc.badge.plus").font(.caption)
205:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
206:                 if fileNavigator.fileTree != nil {
207:                     Button(action: { fileNavigator.refreshFileTree() }) {
208:                         Image(systemName: "arrow.clockwise").font(.caption)
209:                     }.foregroundColor(theme.sidebarForeground.opacity(0.7))
210:                 }
211:             }.padding(.horizontal, 12).padding(.vertical, 8)
212:             
213:             ScrollView {
214:                 VStack(alignment: .leading, spacing: 2) {
215:                     if let tree = fileNavigator.fileTree {
216:                         FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
217:                     } else {
218:                         DemoFileTree(editorCore: editorCore, theme: theme)
219:                     }
220:                 }.padding(.horizontal, 8)
221:             }
222:         }.background(theme.sidebarBackground)
223:     }
224: }
225: 
226: struct RealFileTreeView: View {
227:     let node: FileTreeNode
228:     let level: Int
229:     @ObservedObject var fileNavigator: FileSystemNavigator
230:     @ObservedObject var editorCore: EditorCore
231:     let theme: Theme
232:     
233:     var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
234:     
235:     var body: some View {
236:         VStack(alignment: .leading, spacing: 2) {
237:             HStack(spacing: 4) {
238:                 if node.isDirectory {
239:                     Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
240:                         .font(.caption2).frame(width: 12)
241:                         .foregroundColor(theme.sidebarForeground.opacity(0.6))
242:                         .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
243:                 } else {
244:                     Spacer().frame(width: 12)
245:                 }
246:                 Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
247:                     .font(.caption)
248:                     .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
249:                 Text(node.name).font(.system(.caption)).lineLimit(1)
250:                     .foregroundColor(theme.sidebarForeground)
251:                 Spacer()
252:             }
253:             .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
254:             .contentShape(Rectangle())
255:             .onTapGesture {
256:                 if node.isDirectory {
257:                     fileNavigator.toggleExpanded(path: node.url.path)
258:                 } else {
259:                     editorCore.openFile(from: node.url)
260:                 }
261:             }
262:             
263:             if isExpanded && node.isDirectory {
264:                 ForEach(node.children) { child in
265:                     RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
266:                 }
267:             }
268:         }
269:     }
270: }
271: 
272: struct DemoFileTree: View {
273:     @ObservedObject var editorCore: EditorCore
274:     let theme: Theme
275:     
276:     var body: some View {
277:         VStack(alignment: .leading, spacing: 4) {
278:             Text("Open a folder to browse files")
279:                 .font(.caption)
280:                 .foregroundColor(theme.sidebarForeground.opacity(0.6))
281:                 .padding(.vertical, 8)
282:             
283:             DemoFileRow(name: "main.swift", editorCore: editorCore, theme: theme)
284:             DemoFileRow(name: "ContentView.swift", editorCore: editorCore, theme: theme)
285:             DemoFileRow(name: "README.md", editorCore: editorCore, theme: theme)
286:         }
287:     }
288: }
289: 
290: struct DemoFileRow: View {
291:     let name: String
292:     @ObservedObject var editorCore: EditorCore
293:     let theme: Theme
294:     
295:     var body: some View {
296:         HStack(spacing: 4) {
297:             Spacer().frame(width: 12)
298:             Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
299:             Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
300:             Spacer()
301:         }
302:         .padding(.vertical, 4)
303:         .contentShape(Rectangle())
304:         .onTapGesture {
305:             editorCore.addTab(fileName: name, content: "// \(name)\n\n")
306:         }
307:     }
308: }
309: 
310: // MARK: - Tab Bar
311: 
312: struct IDETabBar: View {
313:     @ObservedObject var editorCore: EditorCore
314:     let theme: Theme
315:     
316:     var body: some View {
317:         ScrollView(.horizontal, showsIndicators: false) {
318:             HStack(spacing: 0) {
319:                 ForEach(editorCore.tabs) { tab in
320:                     IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
321:                 }
322:                 Button(action: { editorCore.addTab() }) {
323:                     Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
324:                 }
325:             }.padding(.horizontal, 4)
326:         }.frame(height: 36).background(theme.tabBarBackground)
327:     }
328: }
329: 
330: struct IDETabItem: View {
331:     let tab: Tab
332:     let isSelected: Bool
333:     @ObservedObject var editorCore: EditorCore
334:     let theme: Theme
335:     
336:     var body: some View {
337:         HStack(spacing: 6) {
338:             Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
339:             Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
340:                 .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
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
431:                                     cursorIndex = tempCursor
432:                                     requestedCursorIndex = tempCursor
433:                                     showAutocomplete = false
434:                                     return true
435:                                 }
436:                                 return false
437:                             },
438:                             onDismissAutocomplete: {
439:                                 guard showAutocomplete else { return false }
440:                                 autocomplete.hideSuggestions()
441:                                 showAutocomplete = false
442:                                 return true
443:                             }
444:                         )
445:                         .onChange(of: text) { newValue in
446:                             editorCore.updateActiveTabContent(newValue)
447:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
448:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
449:                             showAutocomplete = autocomplete.showSuggestions
450:                             foldingManager.detectFoldableRegions(in: newValue)
451:                         }
452:                         .onChange(of: cursorIndex) { newCursor in
453:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
454:                             showAutocomplete = autocomplete.showSuggestions
455:                         }
456:                     }
457:                     
458:                     if !tab.fileName.hasSuffix(".json") {
459:                         MinimapView(
460:                             content: text,
461:                             scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
462:                             scrollViewHeight: .constant(geometry.size.height),
463:                             totalContentHeight: CGFloat(totalLines) * lineHeight
464:                         )
465:                         .frame(width: 80)
466:                     }
467:                 }
468:                 .background(theme.editorBackground)
469: 
470:                 // Sticky Header Overlay (FEAT-040)
471:                 StickyHeaderView(
472:                     text: text,
473:                     currentLine: scrollPosition,
474:                     theme: theme,
475:                     lineHeight: lineHeight,
476:                     onSelect: { line in
477:                         requestedLineSelection = line
478:                     }
479:                 )
480:                 .padding(.leading, lineNumbersStyle != "off" ? 60 : 0)
481:                 .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
482: 
483:                 if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
484:                     AutocompletePopup(
485:                         suggestions: autocomplete.suggestionItems,
486:                         selectedIndex: autocomplete.selectedIndex,
487:                         theme: theme
488:                     ) { index in
489:                         autocomplete.selectedIndex = index
490:                         var tempText = text
491:                         var tempCursor = cursorIndex
492:                         autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
493:                         if tempText != text {
494:                             text = tempText
495:                             cursorIndex = tempCursor
496:                             requestedCursorIndex = tempCursor
497:                         }
498:                         showAutocomplete = false
499:                     }
500:                     .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
501:                 }
502:             }
503:         }
504:         }
505:         .onAppear {
506:             text = tab.content
507:             foldingManager.detectFoldableRegions(in: text)
508:         }
509:         .onChange(of: tab.id) { _ in
510:             text = tab.content
511:             foldingManager.detectFoldableRegions(in: text)
512:         }
513:         .onChange(of: currentLineNumber) { line in
514:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
515:         }
516:         .onChange(of: currentColumn) { col in
517:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
518:         }
519:         .onAppear {
520:             findViewModel.editorCore = editorCore
521:         }
522:     }
523:     
524:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
525: }
526: 
527: // MARK: - Line Numbers with Folding
528: 
529: struct LineNumbersWithFolding: View {
530:     let fileId: String
531:     let totalLines: Int
532:     let currentLine: Int
533:     let scrollOffset: CGFloat
534:     let lineHeight: CGFloat
535:     @Binding var requestedLineSelection: Int?
536:     @ObservedObject var foldingManager: CodeFoldingManager
537:     @ObservedObject private var debugManager = DebugManager.shared
538:     let theme: Theme
539: 
540:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
541: 
542:     var body: some View {
543:         ScrollView(showsIndicators: false) {
544:             VStack(alignment: .trailing, spacing: 0) {
545:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
546:                     if !foldingManager.isLineFolded(line: lineIndex) {
547:                         HStack(spacing: 2) {
548:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
549:                                 Circle()
550:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
551:                                     .overlay(
552:                                         Circle()
553:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
554:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
555:                                     )
556:                                     .frame(width: 10, height: 10)
557:                                     .padding(.leading, 2)
558:                             }
559:                             .buttonStyle(.plain)
560:                             .frame(width: 14, height: lineHeight)
561: 
562:                             if foldingManager.isFoldable(line: lineIndex) {
563:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
564:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
565:                                         .font(.system(size: 8))
566:                                         .foregroundColor(theme.lineNumber)
567:                                 }
568:                                 .buttonStyle(.plain)
569:                                 .frame(width: 14, height: lineHeight)
570:                             } else {
571:                                 Spacer().frame(width: 14)
572:                             }
573: 
574:                             Text(displayText(for: lineIndex))
575:                                 .font(.system(size: 12, design: .monospaced))
576:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
577:                                 .frame(height: lineHeight)
578:                                 .contentShape(Rectangle())
579:                                 .onTapGesture {
580:                                     // FEAT-041: click line number selects entire line
581:                                     requestedLineSelection = lineIndex
582:                                 }
583:                         }
584:                         .frame(maxWidth: .infinity, alignment: .trailing)
585:                         .padding(.trailing, 4)
586:                     }
587:                 }
588:             }
589:             .offset(y: -scrollOffset)
590:         }
591:     }
592: 
593:     private func displayText(for lineIndex: Int) -> String {
594:         switch lineNumbersStyle {
595:         case "relative":
596:             // VS Code-style: current line shows absolute, others show relative distance
597:             let lineNumber = lineIndex + 1
598:             if lineNumber == currentLine { return "\(lineNumber)" }
599:             return "\(abs(lineNumber - currentLine))"
600: 
601:         case "interval":
602:             let lineNumber = lineIndex + 1
603:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
604: 
605:         default:
606:             return "\(lineIndex + 1)"
607:         }
608:     }
609: }
610: 
611: // MARK: - Autocomplete Popup
612: 
613: struct AutocompletePopup: View {
614:     let suggestions: [AutocompleteSuggestion]
615:     let selectedIndex: Int
616:     let theme: Theme
617:     let onSelectIndex: (Int) -> Void
618:     
619:     var body: some View {
620:         VStack(alignment: .leading, spacing: 0) {
621:             ForEach(suggestions.indices, id: \.self) { index in
622:                 let s = suggestions[index]
623:                 HStack(spacing: 6) {
624:                     Image(systemName: icon(for: s.kind))
625:                         .font(.caption)
626:                         .foregroundColor(color(for: s.kind))
627:                     VStack(alignment: .leading, spacing: 1) {
628:                         Text(s.displayText)
629:                             .font(.system(size: 12, design: .monospaced))
630:                             .foregroundColor(theme.editorForeground)
631:                         if s.insertText != s.displayText && !s.insertText.isEmpty {
632:                             Text(s.insertText)
633:                                 .font(.system(size: 10, design: .monospaced))
634:                                 .foregroundColor(theme.editorForeground.opacity(0.55))
635:                                 .lineLimit(1)
636:                         }
637:                     }
638:                     Spacer()
639:                 }
640:                 .padding(.horizontal, 8).padding(.vertical, 6)
641:                 .background(index == selectedIndex ? theme.selection : Color.clear)
642:                 .contentShape(Rectangle())
643:                 .onTapGesture { onSelectIndex(index) }
644:             }
645:         }
646:         .frame(width: 260)
647:         .background(theme.editorBackground)
648:         .cornerRadius(6)
649:         .shadow(radius: 8)
650:     }
651:     
652:     private func icon(for kind: AutocompleteSuggestionKind) -> String {
653:         switch kind {
654:         case .keyword: return "key.fill"
655:         case .symbol: return "cube.fill"
656:         case .stdlib: return "curlybraces"
657:         case .member: return "arrow.right.circle.fill"
658:         }
659:     }
660:     
661:     private func color(for kind: AutocompleteSuggestionKind) -> Color {
662:         switch kind {
663:         case .keyword: return .purple
664:         case .symbol: return .blue
665:         case .stdlib: return .orange
666:         case .member: return .green
667:         }
668:     }
669: }
670: 
671: // MARK: - Welcome View
672: 
673: struct IDEWelcomeView: View {
674:     @ObservedObject var editorCore: EditorCore
675:     @Binding var showFolderPicker: Bool
676:     let theme: Theme
677:     
678:     var body: some View {
679:         VStack(spacing: 24) {
680:             Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 80)).foregroundColor(theme.editorForeground.opacity(0.3))
681:             Text("VS Code for iPadOS").font(.largeTitle).fontWeight(.bold).foregroundColor(theme.editorForeground)
682:             VStack(alignment: .leading, spacing: 12) {
683:                 WelcomeBtn(icon: "doc.badge.plus", title: "New File", shortcut: "⌘N", theme: theme) { editorCore.addTab() }
684:                 WelcomeBtn(icon: "folder", title: "Open Folder", shortcut: "⌘⇧O", theme: theme) { showFolderPicker = true }
685:                 WelcomeBtn(icon: "doc", title: "Open File", shortcut: "⌘O", theme: theme) { editorCore.showFilePicker = true }
686:                 WelcomeBtn(icon: "terminal", title: "Command Palette", shortcut: "⌘⇧P", theme: theme) { editorCore.showCommandPalette = true }
687:             }
688:         }.frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.editorBackground)
689:     }
690: }
691: 
692: struct WelcomeBtn: View {
693:     let icon: String
694:     let title: String
695:     let shortcut: String
696:     let theme: Theme
697:     let action: () -> Void
698:     
699:     var body: some View {
700:         Button(action: action) {
701:             HStack {
702:                 Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
703:                 Text(title).foregroundColor(theme.editorForeground)
704:                 Spacer()
705:                 Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
706:             }
707:             .padding().frame(width: 280)
708:             .background(theme.sidebarBackground)
709:             .cornerRadius(8)
710:         }.buttonStyle(.plain)
711:     }
712: }
713: 
714: // MARK: - Command Palette
715: 
716: struct IDECommandPalette: View {
717:     @ObservedObject var editorCore: EditorCore
718:     @Binding var showSettings: Bool
719:     @Binding var showTerminal: Bool
720:     @State private var searchText = ""
721:     
722:     var body: some View {
723:         VStack(spacing: 0) {
724:             HStack {
725:                 Image(systemName: "magnifyingglass").foregroundColor(.secondary)
726:                 TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
727:             }.padding().background(Color(UIColor.secondarySystemBackground))
728:             Divider()
729:             ScrollView {
730:                 VStack(spacing: 0) {
731:                     CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
732:                     CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
733:                     CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
734:                     CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
735:                     CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
736:                     CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
737:                     CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
738:                     CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
739:                 }.padding(.vertical, 8)
740:             }
741:         }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
742:     }
743: }
744: 
745: struct CommandRow: View {
746:     let icon: String; let name: String; let shortcut: String; let action: () -> Void
747:     var body: some View {
748:         Button(action: action) {
749:             HStack {
750:                 Image(systemName: icon).foregroundColor(.accentColor).frame(width: 24)
751:                 Text(name).foregroundColor(.primary)
752:                 Spacer()
753:                 Text(shortcut).font(.caption).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 4).background(Color(UIColor.tertiarySystemFill)).cornerRadius(4)
754:             }.padding(.horizontal).padding(.vertical, 12).contentShape(Rectangle())
755:         }.buttonStyle(.plain)
756:     }
757: }
758: 
759: // MARK: - Quick Open
760: 
761: struct IDEQuickOpen: View {
762:     @ObservedObject var editorCore: EditorCore
763:     @State private var searchText = ""
764:     
765:     var body: some View {
766:         VStack(spacing: 0) {
767:             HStack {
768:                 Image(systemName: "magnifyingglass").foregroundColor(.gray)
769:                 TextField("Search files...", text: $searchText).textFieldStyle(.plain)
770:             }.padding().background(Color(UIColor.secondarySystemBackground))
771:             Divider()
772:             ScrollView {
773:                 VStack(alignment: .leading, spacing: 0) {
774:                     ForEach(editorCore.tabs) { tab in
775:                         QuickOpenRow(name: tab.fileName, path: "") {
776:                             editorCore.selectTab(id: tab.id)
777:                             editorCore.showQuickOpen = false
778:                         }
779:                     }
780:                 }
781:             }.frame(maxHeight: 350)
782:         }.frame(width: 500).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
783:     }
784: }
785: 
786: struct QuickOpenRow: View {
787:     let name: String; let path: String; let action: () -> Void
788:     var body: some View {
789:         Button(action: action) {
790:             HStack {
791:                 Image(systemName: fileIcon(for: name)).foregroundColor(fileColor(for: name)).frame(width: 20)
792:                 VStack(alignment: .leading, spacing: 2) { Text(name).font(.system(size: 14)); Text(path + name).font(.system(size: 11)).foregroundColor(.secondary) }
793:                 Spacer()
794:             }.padding(.horizontal).padding(.vertical, 8).contentShape(Rectangle())
795:         }.buttonStyle(.plain)
796:     }
797: }
798: 
799: // MARK: - AI Assistant
800: 
801: struct IDEAIAssistant: View {
802:     @ObservedObject var editorCore: EditorCore
803:     let theme: Theme
804:     @State private var userInput = ""
805:     @State private var messages: [(id: UUID, role: String, content: String)] = [(UUID(), "assistant", "Hello! I'm your AI coding assistant. How can I help?")]
806:     
807:     var body: some View {
808:         VStack(spacing: 0) {
809:             HStack {
810:                 Image(systemName: "brain").foregroundColor(.blue)
811:                 Text("AI Assistant").font(.headline).foregroundColor(theme.editorForeground)
812:                 Spacer()
813:                 Button(action: { editorCore.showAIAssistant = false }) { Image(systemName: "xmark.circle.fill").foregroundColor(theme.editorForeground.opacity(0.5)) }
814:             }.padding().background(theme.sidebarBackground)
815:             
816:             ScrollView {
817:                 LazyVStack(alignment: .leading, spacing: 12) {
818:                     ForEach(messages, id: \.id) { msg in
819:                         HStack {
820:                             if msg.role == "user" { Spacer(minLength: 60) }
821:                             Text(msg.content).padding(12).background(RoundedRectangle(cornerRadius: 12).fill(msg.role == "user" ? Color.blue : theme.sidebarBackground)).foregroundColor(msg.role == "user" ? .white : theme.editorForeground)
822:                             if msg.role == "assistant" { Spacer(minLength: 60) }
823:                         }
824:                     }
825:                 }.padding()
826:             }.background(theme.editorBackground)
827:             
828:             HStack(spacing: 12) {
829:                 TextField("Ask about your code...", text: $userInput).textFieldStyle(.roundedBorder)
830:                 Button(action: { sendMessage() }) { Image(systemName: "paperplane.fill").foregroundColor(userInput.isEmpty ? .gray : .blue) }.disabled(userInput.isEmpty)
831:             }.padding().background(theme.sidebarBackground)
832:         }.background(theme.editorBackground).cornerRadius(12).shadow(radius: 20)
833:     }
834:     
835:     func sendMessage() {
836:         guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
837:         messages.append((UUID(), "user", userInput))
838:         let input = userInput
839:         userInput = ""
840:         DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
841:             messages.append((UUID(), "assistant", "I can help with '\(input)'! What specifically would you like to know?"))
842:         }
843:     }
844: }
845: 
846: // MARK: - Status Bar
847: 
848: 
849: 
850: // MARK: - Folder Picker
851: 
852: struct IDEFolderPicker: UIViewControllerRepresentable {
853:     @ObservedObject var fileNavigator: FileSystemNavigator
854:     var onPick: ((URL) -> Void)?
855:     
856:     init(fileNavigator: FileSystemNavigator, onPick: ((URL) -> Void)? = nil) {
857:         self.fileNavigator = fileNavigator
858:         self.onPick = onPick
859:     }
860:     
861:     func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
862:         let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
863:         picker.delegate = context.coordinator
864:         return picker
865:     }
866:     
867:     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
868:     
869:     func makeCoordinator() -> Coordinator { Coordinator(self) }
870:     
871:     class Coordinator: NSObject, UIDocumentPickerDelegate {
872:         let parent: IDEFolderPicker
873:         init(_ parent: IDEFolderPicker) { self.parent = parent }
874:         
875:         func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
876:             if let url = urls.first {
877:                 _ = url.startAccessingSecurityScopedResource()
878:                 if let onPick = parent.onPick {
879:                     onPick(url)
880:                 } else {
881:                     // Default behavior if no custom handler
882:                     parent.fileNavigator.loadFileTree(at: url)
883:                     Task { @MainActor in
884:                         LaunchManager.shared.setWorkspaceRoot(url)
885:                         GitManager.shared.setWorkingDirectory(url)
886:                     }
887:                 }
888:             }
889:         }
890:     }
891: }
892: 
893: // MARK: - Document Picker
894: 
895: struct IDEDocumentPicker: UIViewControllerRepresentable {
896:     @ObservedObject var editorCore: EditorCore
897:     
898:     func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
899:         let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .sourceCode, .json, .plainText, .data])
900:         picker.allowsMultipleSelection = true
901:         picker.delegate = context.coordinator
902:         return picker
903:     }
904:     
905:     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
906:     
907:     func makeCoordinator() -> Coordinator { Coordinator(editorCore: editorCore) }
908:     
909:     class Coordinator: NSObject, UIDocumentPickerDelegate {
910:         let editorCore: EditorCore
911:         init(editorCore: EditorCore) { self.editorCore = editorCore }
912:         
913:         func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
914:             for url in urls { editorCore.openFile(from: url) }
915:             editorCore.showFilePicker = false
916:         }
917:         
918:         func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
919:             editorCore.showFilePicker = false
920:         }
921:     }
922: }
923: 
924: // MARK: - Sidebar Search View
925: 
926: struct SidebarSearchView: View {
927:     let theme: Theme
928:     @State private var searchText = ""
929:     @State private var replaceText = ""
930:     @State private var showReplace = false
931:     @State private var searchResults: [(fileName: String, line: Int, preview: String)] = []
932:     
933:     var body: some View {
934:         VStack(alignment: .leading, spacing: 0) {
935:             HStack {
936:                 Text("SEARCH").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
937:                 Spacer()
938:             }.padding(.horizontal, 12).padding(.vertical, 8)
939:             
940:             HStack(spacing: 4) {
941:                 Image(systemName: "magnifyingglass").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
942:                 TextField("Search", text: $searchText).textFieldStyle(.plain).font(.system(size: 13))
943:                     .foregroundColor(theme.sidebarForeground)
944:                 if !searchText.isEmpty {
945:                     Button(action: { searchText = "" }) {
946:                         Image(systemName: "xmark.circle.fill").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
947:                     }
948:                 }
949:             }
950:             .padding(8)
951:             .background(theme.editorBackground)
952:             .cornerRadius(6)
953:             .padding(.horizontal, 12)
954:             
955:             HStack {
956:                 Button(action: { showReplace.toggle() }) {
957:                     Image(systemName: showReplace ? "chevron.down" : "chevron.right").font(.caption2)
958:                     Text("Replace").font(.caption)
959:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
960:                 Spacer()
961:             }.padding(.horizontal, 12).padding(.vertical, 6)
962:             
963:             if showReplace {
964:                 HStack(spacing: 4) {
965:                     Image(systemName: "arrow.right").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
966:                     TextField("Replace", text: $replaceText).textFieldStyle(.plain).font(.system(size: 13))
967:                         .foregroundColor(theme.sidebarForeground)
968:                 }
969:                 .padding(8)
970:                 .background(theme.editorBackground)
971:                 .cornerRadius(6)
972:                 .padding(.horizontal, 12)
973:             }
974:             
975:             Divider().padding(.top, 8)
976:             
977:             if searchText.isEmpty {
978:                 VStack(spacing: 8) {
979:                     Spacer()
980:                     Image(systemName: "magnifyingglass").font(.largeTitle).foregroundColor(theme.sidebarForeground.opacity(0.3))
981:                     Text("Search in files").font(.caption).foregroundColor(theme.sidebarForeground.opacity(0.6))
982:                     Spacer()
983:                 }.frame(maxWidth: .infinity)
984:             } else {
985:                 ScrollView {
986:                     LazyVStack(alignment: .leading, spacing: 0) {
987:                         ForEach(0..<searchResults.count, id: \.self) { i in
988:                             let result = searchResults[i]
989:                             VStack(alignment: .leading, spacing: 2) {
990:                                 HStack {
991:                                     Image(systemName: "doc.text").font(.caption2).foregroundColor(theme.sidebarForeground.opacity(0.6))
992:                                     Text(result.fileName).font(.system(size: 11, weight: .medium)).foregroundColor(theme.sidebarForeground)
993:                                     Spacer()
994:                                     Text(":\(result.line)").font(.system(size: 10, design: .monospaced)).foregroundColor(theme.sidebarForeground.opacity(0.6))
995:                                 }
996:                                 Text(result.preview).font(.system(size: 11, design: .monospaced)).foregroundColor(theme.sidebarForeground.opacity(0.7)).lineLimit(1)
997:                             }.padding(.horizontal, 12).padding(.vertical, 6)
998:                         }
999:                     }
1000:                 }
1001:             }
1002:         }
1003:         .background(theme.sidebarBackground)
1004:         .onChange(of: searchText) { query in
1005:             if query.isEmpty { searchResults = [] }
1006:             else { searchResults = [("ContentView.swift", 15, "Text(\"\(query)\")"), ("main.swift", 8, "// \(query)")] }
1007:         }
1008:     }
1009: }
1010: 
1011: // MARK: - Preview
1012: 
1013: #Preview {
1014:     ContentView()
1015: }
1016: 


I found "curlybraces" is used in `ContentView.swift` at line 656. Let me check the file helpers extension since the backup files suggest there's also icon handling there:

>>>TOOL search
{"query": "fileIcon", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "fileIcon"


>>>TOOL search
{"query": "func fileIcon", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "func fileIcon"


>>>TOOL search
{"query": "fileIcon(for:", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "fileIcon(for:"


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Extensions"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Extensions/
   Array+Safe.swift
   Color+Hex.swift
   FileHelpers.swift
   FileIcons.swift
   FileManager+Extension.swift
   FileManager+Extensions.swift
   Notification+Search.swift
   NSAttributedStringSyntaxHighlighter.swift


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Extensions/FileHelpers.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Extensions/FileHelpers.swift (lines 1-29 of 29)
────────────────────────────────────────
1: import SwiftUI
2: 
3: func fileIcon(for filename: String) -> String {
4:     let ext = (filename as NSString).pathExtension.lowercased()
5:     switch ext {
6:     case "swift": return "swift"
7:     case "js", "jsx", "ts", "tsx": return "curlybraces"
8:     case "py": return "chevron.left.forwardslash.chevron.right"
9:     case "html", "htm": return "globe"
10:     case "css", "scss": return "paintbrush"
11:     case "json": return "curlybraces.square"
12:     case "md": return "doc.richtext"
13:     default: return "doc.text"
14:     }
15: }
16: 
17: func fileColor(for filename: String) -> Color {
18:     let ext = (filename as NSString).pathExtension.lowercased()
19:     switch ext {
20:     case "swift": return .orange
21:     case "js", "jsx": return .yellow
22:     case "ts", "tsx": return .blue
23:     case "py": return .green
24:     case "html", "htm": return .red
25:     case "css", "scss": return .purple
26:     case "json": return .green
27:     default: return .gray
28:     }
29: }


Let me do one more search to see if "f.curlybraces" exists anywhere or if it might have been already fixed:

>>>TOOL search
{"query": "f.curlybraces"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "f.curlybraces"


>>>REPORT
## Search Results for 'f.curlybraces'

**Finding: The string "f.curlybraces" does NOT exist in any Swift files in the codebase.**

I searched extensively with multiple queries:
- `f.curlybraces` - No matches found
- `curlybraces` - Found valid uses

### Files Using "curlybraces" (Correct SF Symbol)

1. **`VSCodeiPadOS/VSCodeiPadOS/Extensions/FileHelpers.swift`** (lines 7, 11):
   - Line 7: `case "js", "jsx", "ts", "tsx": return "curlybraces"`
   - Line 11: `case "json": return "curlybraces.square"`

2. **`VSCodeiPadOS/VSCodeiPadOS/ContentView.swift`** (line 656):
   - `case .stdlib: return "curlybraces"` (in AutocompletePopup icon function)

### Conclusion

The icon **"curlybraces"** (without the "f." prefix) is the **correct SF Symbol name** and is already being used correctly throughout the codebase. 

- ✅ `curlybraces` - Valid SF Symbol (iOS 14+)
- ✅ `curlybraces.square` - Valid SF Symbol (iOS 14+)
- ❌ `f.curlybraces` - Does NOT exist as an SF Symbol

If you're seeing an error about a missing "f.curlybraces" icon, the issue may have already been fixed, or the error is coming from a different location not tracked in this repository.
>>>END
