# Agent: diagnose-file-opening
**Status:** done
**Tokens:** 10,389
**Cost:** $0.0000
**Time:** 2026-02-09T22:46:48.049Z

## Task
CRITICAL: Files don't open when clicked in file tree. Read VSCodeiPadOS/VSCodeiPadOS/Views/FileTreeView.swift and VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift openFile methods. Find why clicking a file only shows title but doesn't load content. Check if there's a state update issue or async problem.

## Response
I'll investigate this issue by reading the relevant files. Let me start with the FileTreeView.swift to understand how file clicks are handled.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/FileTreeView.swift"}
>>>END

Now let me read the EditorCore.swift to see the `openFile` method:

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


Let me check the Tab model and how the editor view displays content:

>>>TOOL search
{"query": "struct Tab", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "struct Tab"


Let me search for the Tab model definition differently:

>>>TOOL search
{"query": "class Tab", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class Tab"


>>>TOOL search
{"query": "Tab:", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftParserDiagnostics/ParserDiagnosticMessages.swift:397: case .unexpectedTab: return "unexpected tab in indentation"


>>>TOOL search
{"query": "fileName: String", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 9 matches:
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftCompilerPluginMessageHandling/PluginMacroExpansionContext.swift:33: var fileName: String
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftCompilerPluginMessageHandling/PluginMacroExpansionContext.swift:52: var fileName: String
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftCompilerPluginMessageHandling/PluginMacroExpansionContext.swift:57: var fileName: String
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftCompilerPluginMessageHandling/PluginMessages.swift:136: public var fileName: String
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftCompilerPluginMessageHandling/PluginMessages.swift:144: public init(fileID: String, fileName: String, offset: Int, line: Int, column: Int) {
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftCompilerPluginMessageHandling/PluginMessages.swift:161: public var fileName: String
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftCompilerPluginMessageHandling/PluginMessages.swift:165: public init(fileName: String, offset: Int) {
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftCompilerPluginMessageHandling/PluginMessages.swift:175: public var fileName: String
.garbage/workspace-cleanup-20260209/.build/checkouts/swift-syntax/Sources/SwiftCompilerPluginMessageHandling/PluginMessages.swift:181: public init(fileName: String, startOffset: Int, endOffset: Int) {


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models"}
>>>END

---

## 🔧 TOOL RESULTS

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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models/Tab.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/Tab.swift (lines 1-244 of 244)
────────────────────────────────────────
1: //
2: //  Tab.swift
3: //  VSCodeiPadOS
4: //
5: //  Created by AI Assistant
6: //  A model representing an editor tab with file content and metadata
7: //
8: 
9: import Foundation
10: import SwiftUI
11: 
12: /// Represents an open editor tab containing file content
13: struct Tab: Identifiable, Equatable, Hashable, Codable {
14:     // MARK: - Properties
15:     
16:     /// Unique identifier for the tab
17:     let id: UUID
18:     
19:     /// Display name of the file
20:     var fileName: String
21:     
22:     /// Current content of the file
23:     var content: String
24:     
25:     /// Programming language/file type
26:     var language: CodeLanguage
27:     
28:     /// File system URL (nil for unsaved new files)
29:     var url: URL?
30:     
31:     /// Whether the file has unsaved changes
32:     var isUnsaved: Bool
33:     
34:     /// Whether this tab is currently active/selected
35:     var isActive: Bool
36:     
37:     /// Whether this tab is pinned
38:     var isPinned: Bool
39:     
40:     /// Whether this tab is in preview mode
41:     var isPreview: Bool
42:     
43:     // MARK: - Initialization
44:     
45:     /// Creates a new tab
46:     /// - Parameters:
47:     ///   - id: Unique identifier (auto-generated if not provided)
48:     ///   - fileName: Display name for the file
49:     ///   - content: File content (empty by default)
50:     ///   - language: Programming language (auto-detected from fileName if not provided)
51:     ///   - url: File system URL (nil for new unsaved files)
52:     ///   - isUnsaved: Whether file has unsaved changes (false by default)
53:     ///   - isActive: Whether this is the active tab (false by default)
54:     ///   - isPinned: Whether the tab is pinned (false by default)
55:     ///   - isPreview: Whether the tab is in preview mode (false by default)
56:     init(
57:         id: UUID = UUID(),
58:         fileName: String,
59:         content: String = "",
60:         language: CodeLanguage? = nil,
61:         url: URL? = nil,
62:         isUnsaved: Bool = false,
63:         isActive: Bool = false,
64:         isPinned: Bool = false,
65:         isPreview: Bool = false
66:     ) {
67:         self.id = id
68:         self.fileName = fileName
69:         self.content = content
70:         self.url = url
71:         self.isUnsaved = isUnsaved
72:         self.isActive = isActive
73:         self.isPinned = isPinned
74:         self.isPreview = isPreview
75:         
76:         // Auto-detect language from file extension if not provided
77:         if let language = language {
78:             self.language = language
79:         } else {
80:             let fileExtension = (fileName as NSString).pathExtension
81:             self.language = CodeLanguage(from: fileExtension)
82:         }
83:     }
84:     
85:     /// Convenience initializer that accepts language as String
86:     init(
87:         id: UUID = UUID(),
88:         fileName: String,
89:         content: String = "",
90:         language: String,
91:         url: URL? = nil,
92:         isUnsaved: Bool = false,
93:         isActive: Bool = false,
94:         isPinned: Bool = false,
95:         isPreview: Bool = false
96:     ) {
97:         self.init(
98:             id: id,
99:             fileName: fileName,
100:             content: content,
101:             language: CodeLanguage(from: language),
102:             url: url,
103:             isUnsaved: isUnsaved,
104:             isActive: isActive,
105:             isPinned: isPinned,
106:             isPreview: isPreview
107:         )
108:     }
109:     
110:     // MARK: - Computed Properties
111:     
112:     /// File extension (e.g., "swift", "js")
113:     var fileExtension: String {
114:         (fileName as NSString).pathExtension.lowercased()
115:     }
116:     
117:     /// Display title for the tab (includes unsaved indicator)
118:     var displayTitle: String {
119:         isUnsaved ? "● \(fileName)" : fileName
120:     }
121:     
122:     /// Number of lines in the content
123:     var lineCount: Int {
124:         content.isEmpty ? 0 : content.components(separatedBy: .newlines).count
125:     }
126:     
127:     /// File size in bytes
128:     var contentSize: Int {
129:         content.utf8.count
130:     }
131:     
132:     // MARK: - Equatable & Hashable
133:     
134:     /// Tabs are equal if they have the same ID
135:     static func == (lhs: Tab, rhs: Tab) -> Bool {
136:         lhs.id == rhs.id
137:     }
138:     
139:     /// Hash based on ID only
140:     func hash(into hasher: inout Hasher) {
141:         hasher.combine(id)
142:     }
143: }
144: 
145: // MARK: - CodeLanguage
146: 
147: /// Supported programming languages and file types
148: enum CodeLanguage: String, CaseIterable, Codable {
149:     case swift = "swift"
150:     case javascript = "javascript"
151:     case typescript = "typescript"
152:     case python = "python"
153:     case html = "html"
154:     case css = "css"
155:     case json = "json"
156:     case markdown = "markdown"
157:     case yaml = "yaml"
158:     case xml = "xml"
159:     case plainText = "plaintext"
160:     
161:     // MARK: - Initialization
162:     
163:     /// Detects language from file extension
164:     /// - Parameter fileExtension: File extension (e.g., "swift", "js")
165:     init(from fileExtension: String) {
166:         let ext = fileExtension.lowercased()
167:         switch ext {
168:         case "swift":
169:             self = .swift
170:         case "js", "jsx", "mjs":
171:             self = .javascript
172:         case "ts", "tsx":
173:             self = .typescript
174:         case "py", "pyw":
175:             self = .python
176:         case "html", "htm":
177:             self = .html
178:         case "css", "scss", "sass", "less":
179:             self = .css
180:         case "json":
181:             self = .json
182:         case "md", "markdown":
183:             self = .markdown
184:         case "yml", "yaml":
185:             self = .yaml
186:         case "xml":
187:             self = .xml
188:         default:
189:             self = .plainText
190:         }
191:     }
192:     
193:     // MARK: - Display Properties
194:     
195:     /// Human-readable display name
196:     var displayName: String {
197:         switch self {
198:         case .swift: return "Swift"
199:         case .javascript: return "JavaScript"
200:         case .typescript: return "TypeScript"
201:         case .python: return "Python"
202:         case .html: return "HTML"
203:         case .css: return "CSS"
204:         case .json: return "JSON"
205:         case .markdown: return "Markdown"
206:         case .yaml: return "YAML"
207:         case .xml: return "XML"
208:         case .plainText: return "Plain Text"
209:         }
210:     }
211:     
212:     /// Icon name for SF Symbols
213:     var iconName: String {
214:         switch self {
215:         case .swift: return "swift"
216:         case .javascript, .typescript: return "curlybraces"
217:         case .python: return "chevron.left.forwardslash.chevron.right"
218:         case .html: return "globe"
219:         case .css: return "paintbrush"
220:         case .json: return "curlybraces.square"
221:         case .markdown: return "doc.richtext"
222:         case .yaml, .xml: return "doc.text"
223:         case .plainText: return "doc"
224:         }
225:     }
226:     
227:     /// Color associated with the language
228:     var color: Color {
229:         switch self {
230:         case .swift: return .orange
231:         case .javascript: return .yellow
232:         case .typescript: return .blue
233:         case .python: return .green
234:         case .html: return .red
235:         case .css: return .purple
236:         case .json: return .green
237:         case .markdown: return .blue
238:         case .yaml: return .cyan
239:         case .xml: return .orange
240:         case .plainText: return .gray
241:         }
242:     }
243: }
244: 


Now let me look at how the editor view displays content - this might be where the issue is:

>>>TOOL search
{"query": "activeTab.content", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "activeTab.content"


>>>TOOL search
{"query": "editorCore.tabs", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "editorCore.tabs"


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
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/TabBarView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/TabBarView.swift (lines 1-249 of 249)
────────────────────────────────────────
1: //  TabBarView.swift
2: //  VSCodeiPadOS
3: //
4: //  Created by AI Assistant
5: //  Improved Tab Bar View
6: //
7: 
8: import SwiftUI
9: 
10: struct TabBarView: View {
11:     @Binding var tabs: [Tab]
12:     @Binding var activeTabId: UUID?
13:     @ObservedObject var themeManager: ThemeManager
14: 
15:     // Drag and drop support
16:     @State private var draggedTab: Tab? = nil
17: 
18:     var body: some View {
19:         ScrollView(.horizontal, showsIndicators: false) {
20:             ScrollViewReader { scrollProxy in
21:                 HStack(spacing: 1) {
22:                     ForEach(tabs) { tab in
23:                         TabItemView(
24:                             tab: tab,
25:                             isActive: activeTabId == tab.id,
26:                             themeManager: themeManager,
27:                             onClose: { closeTab(tab) },
28:                             onActivate: { activateTab(tab) },
29:                             onPin: { togglePin(tab) },
30:                             onCloseOthers: { closeOthers(except: tab) },
31:                             onCloseRight: { closeTabsToRight(of: tab) }
32:                         )
33:                         .id(tab.id)
34:                         .draggableToNewWindow(tab: tab, onDrag: {
35:                             self.draggedTab = tab
36:                             return NSItemProvider(object: tab.id.uuidString as NSString)
37:                         })
38:                         .onDrop(of: [.text], delegate: TabDropDelegate(item: tab, tabs: $tabs, draggedItem: $draggedTab))
39:                     }
40:                 }
41:                 .padding(.leading, 1)
42:                 .onChange(of: activeTabId) { newId in
43:                     if let id = newId {
44:                         withAnimation {
45:                             scrollProxy.scrollTo(id, anchor: .center)
46:                         }
47:                     }
48:                 }
49:             }
50:         }
51:         .background(themeManager.currentTheme.tabBarBackground)
52:         .frame(height: 35)
53:     }
54: 
55:     private func closeTab(_ tab: Tab) {
56:         if let index = tabs.firstIndex(where: { $0.id == tab.id }) {
57:             tabs.remove(at: index)
58: 
59:             // If we closed the active tab, activate another one
60:             if activeTabId == tab.id {
61:                 if tabs.isEmpty {
62:                     activeTabId = nil
63:                 } else {
64:                     // Try to activate the tab to the right, or the last one if we closed the last one
65:                     let newIndex = min(index, tabs.count - 1)
66:                     activeTabId = tabs[newIndex].id
67:                 }
68:             }
69:         }
70:     }
71: 
72:     private func activateTab(_ tab: Tab) {
73:         activeTabId = tab.id
74:     }
75: 
76:     private func togglePin(_ tab: Tab) {
77:         if let index = tabs.firstIndex(where: { $0.id == tab.id }) {
78:             tabs[index].isPinned.toggle()
79:             tabs[index].isPreview = false
80:         }
81:     }
82: 
83:     private func closeOthers(except tab: Tab) {
84:         tabs = tabs.filter { $0.id == tab.id || $0.isPinned }
85:         if activeTabId != tab.id {
86:             activeTabId = tab.id
87:         }
88:     }
89: 
90:     private func closeTabsToRight(of tab: Tab) {
91:         if let index = tabs.firstIndex(where: { $0.id == tab.id }) {
92:             // Keep tabs up to index, plus pinned tabs that might be to the right (though pinned tabs should be on left)
93:             let tabsToKeep = tabs.prefix(through: index)
94:             let remainingTabs = tabs.suffix(from: index + 1).filter { $0.isPinned }
95:             tabs = Array(tabsToKeep) + Array(remainingTabs)
96:         }
97:     }
98: }
99: 
100: struct TabItemView: View {
101:     let tab: Tab
102:     let isActive: Bool
103:     @ObservedObject var themeManager: ThemeManager
104:     let onClose: () -> Void
105:     let onActivate: () -> Void
106:     let onPin: () -> Void
107:     let onCloseOthers: () -> Void
108:     let onCloseRight: () -> Void
109: 
110:     @State private var isHovering = false
111: 
112:     var body: some View {
113:         HStack(spacing: 6) {
114:             // File icon
115:             if !tab.isPinned {
116:                 Image(systemName: tab.language.iconName)
117:                     .foregroundColor(themeManager.color(for: tab.fileName))
118:                     .font(.system(size: 14))
119:             }
120: 
121:             // Tab title (hidden if pinned)
122:             if tab.isPinned {
123:                 Image(systemName: "pin.fill")
124:                     .font(.system(size: 12))
125:                     .foregroundColor(isActive ? themeManager.currentTheme.tabActiveForeground : themeManager.currentTheme.tabInactiveForeground)
126:             } else {
127:                 Text(tab.fileName)
128:                     .font(.system(size: 13))
129:                     .modifier(ConditionalItalicModifier(isItalic: tab.isPreview))
130:                     .foregroundColor(isActive ? themeManager.currentTheme.tabActiveForeground : themeManager.currentTheme.tabInactiveForeground)
131:                     .lineLimit(1)
132:             }
133: 
134:             if !tab.isPinned {
135:                 Spacer()
136: 
137:                 ZStack {
138:                     if tab.isUnsaved {
139:                         Circle()
140:                             .fill(isActive ? themeManager.currentTheme.tabActiveForeground : themeManager.currentTheme.tabInactiveForeground)
141:                             .frame(width: 8, height: 8)
142:                             .opacity(isHovering ? 0 : 1)
143:                     }
144: 
145:                     if isHovering || !tab.isUnsaved {
146:                         Button(action: onClose) {
147:                             Image(systemName: "xmark")
148:                                 .font(.system(size: 10, weight: .bold))
149:                                 .foregroundColor(isActive ? themeManager.currentTheme.tabActiveForeground : themeManager.currentTheme.tabInactiveForeground)
150:                                 .frame(width: 16, height: 16)
151:                                 .background(Color.black.opacity(0.1))
152:                                 .cornerRadius(4)
153:                         }
154:                         .buttonStyle(.plain)
155:                         .opacity(isHovering ? 1 : 0)
156:                     }
157:                 }
158:                 .frame(width: 16, height: 16)
159:             }
160:         }
161:         .padding(.horizontal, tab.isPinned ? 12 : 10)
162:         .padding(.vertical, 8)
163:         .frame(width: tab.isPinned ? 40 : 160)
164:         .background(isActive ? themeManager.currentTheme.tabActiveBackground : themeManager.currentTheme.tabInactiveBackground)
165:         .overlay(
166:             Rectangle()
167:                 .fill(isActive ? themeManager.currentTheme.statusBarBackground : Color.clear)
168:                 .frame(height: 2),
169:             alignment: .top
170:         )
171:         .onTapGesture { onActivate() }
172:         .onHover { hovering in
173:             isHovering = hovering
174:         }
175:         .contextMenu {
176:             Button(action: onClose) { Label("Close", systemImage: "xmark") }
177:             Button(action: onPin) { Label(tab.isPinned ? "Unpin" : "Pin", systemImage: "pin") }
178:             Divider()
179:             Button(action: onCloseOthers) { Label("Close Others", systemImage: "xmark.circle") }
180:             Button(action: onCloseRight) { Label("Close to the Right", systemImage: "xmark.square") }
181:         }
182:     }
183: }
184: 
185: 
186: // MARK: - Tab Drop Delegate
187: 
188: struct TabDropDelegate: DropDelegate {
189:     let item: Tab
190:     @Binding var tabs: [Tab]
191:     @Binding var draggedItem: Tab?
192:     
193:     func performDrop(info: DropInfo) -> Bool {
194:         draggedItem = nil
195:         return true
196:     }
197:     
198:     func dropEntered(info: DropInfo) {
199:         guard let draggedItem = draggedItem,
200:               draggedItem.id != item.id,
201:               let fromIndex = tabs.firstIndex(where: { $0.id == draggedItem.id }),
202:               let toIndex = tabs.firstIndex(where: { $0.id == item.id }) else { return }
203:         
204:         withAnimation {
205:             tabs.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
206:         }
207:     }
208: }
209: 
210: // MARK: - Conditional Italic Modifier
211: 
212: struct ConditionalItalicModifier: ViewModifier {
213:     let isItalic: Bool
214:     
215:     func body(content: Content) -> some View {
216:         if #available(iOS 16.0, *) {
217:             content.italic(isItalic)
218:         } else {
219:             content
220:         }
221:     }
222: }
223: 
224: 
225: // MARK: - Draggable To New Window Modifier
226: 
227: extension View {
228:     func draggableToNewWindow(tab: Tab, onDrag: @escaping () -> NSItemProvider) -> some View {
229:         #if os(iOS) || os(visionOS)
230:         return self.onDrag {
231:             // Create a provider that supports both tab reordering and window creation
232:             let provider = onDrag()
233:             
234:             // Register additional data for window creation on iPadOS
235:             if let data = try? JSONEncoder().encode(tab) {
236:                 provider.registerDataRepresentation(forTypeIdentifier: "com.vscodeipados.tab", visibility: .all) { completion in
237:                     completion(data, nil)
238:                     return nil
239:                 }
240:             }
241:             
242:             return provider
243:         }
244:         #else
245:         return self.onDrag(onDrag)
246:         #endif
247:     }
248: }
249: 


>>>TOOL search
{"query": "activeTab", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 30 matches:
VSCodeiPadOS/.garbage/1770636460065/NavigationManager.swift:731: guard let tab = activeTab else { return }
VSCodeiPadOS/.garbage/1770636460065/NavigationManager.swift:763: if let currentTab = activeTab {
VSCodeiPadOS/.garbage/1770636460065/NavigationManager.swift:774: activeTabId = tab.id
VSCodeiPadOS/.garbage/1770636460065/NavigationManager.swift:792: activeTabId = tab.id
VSCodeiPadOS/.garbage/1770636460065/NavigationManager.swift:804: activeTabId = tab.id
VSCodeiPadOS/.garbage/1770636460065/NavigationManager.swift:811: guard let tab = activeTab else { return }
VSCodeiPadOS/.garbage/1770636460065/NavigationManager.swift:823: guard let tab = activeTab else { return }
VSCodeiPadOS/.garbage/1770636460065/NavigationManager.swift:833: guard let tab = activeTab else { return }
VSCodeiPadOS/VSCodeiPadOS/SceneDelegate.swift:126: let activeTab = editorCore.activeTab {
VSCodeiPadOS/VSCodeiPadOS/SceneDelegate.swift:127: title = activeTab.fileName
VSCodeiPadOS/VSCodeiPadOS/SceneDelegate.swift:130: if activeTab.isUnsaved {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:41: if let tab = editorCore.activeTab {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:110: .onChange(of: editorCore.activeTab?.fileName) { newFileName in
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:132: if let activeTab = editorCore.activeTab {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:133: let fileName = activeTab.fileName
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:134: let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:320: IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
VSCodeiPadOS/VSCodeiPadOS/Commands/AppCommands.swift:66: if let id = editorCore.activeTabId {
VSCodeiPadOS/VSCodeiPadOS/Views/StatusBarView.swift:83: if let tab = editorCore.activeTab {
VSCodeiPadOS/VSCodeiPadOS/Views/CommandPalette.swift:222: if let tabId = editorCore.activeTabId {
VSCodeiPadOS/VSCodeiPadOS/Views/CommandPaletteView.swift:168: if let id = editorCore.activeTabId {
VSCodeiPadOS/VSCodeiPadOS/Views/GoToSymbol.swift:499: .onChange(of: editorCore.activeTabId) { _ in
VSCodeiPadOS/VSCodeiPadOS/Views/GoToSymbol.swift:513: guard let tab = editorCore.activeTab else {
VSCodeiPadOS/VSCodeiPadOS/Views/TabBarView.swift:12: @Binding var activeTabId: UUID?
VSCodeiPadOS/VSCodeiPadOS/Views/TabBarView.swift:25: isActive: activeTabId == tab.id,
VSCodeiPadOS/VSCodeiPadOS/Views/TabBarView.swift:42: .onChange(of: activeTabId) { newId in
VSCodeiPadOS/VSCodeiPadOS/Views/TabBarView.swift:60: if activeTabId == tab.id {
VSCodeiPadOS/VSCodeiPadOS/Views/TabBarView.swift:62: activeTabId = nil
VSCodeiPadOS/VSCodeiPadOS/Views/TabBarView.swift:66: activeTabId = tabs[newIndex].id
VSCodeiPadOS/VSCodeiPadOS/Views/TabBarView.swift:73: activeTabId = tab.id


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


Now I understand the issue. Looking at `IDEEditorView` (lines 355-525), I can see the problem. Let me trace through the flow:

**The Bug:**

In `IDEEditorView`:
- Line 361: `@State private var text: String = ""` - local state initialized empty
- Line 505-508: `.onAppear { text = tab.content }` - only fires when view FIRST appears
- Line 509-512: `.onChange(of: tab.id) { _ in text = tab.content }` - should fire when switching tabs

The issue is that when a **new file is opened**, SwiftUI keeps the same `IDEEditorView` instance (same position in view hierarchy). The `@State text` preserves its old value. The `.onChange(of: tab.id)` should update it, but there's a timing/capture issue.

The closure at line 509-511 captures `tab` from the view body, but in SwiftUI's onChange, when comparing old vs new `tab.id`, the closure might not always fire reliably in all iOS versions, especially when the tab is a struct passed as a parameter.

**The Fix:**

The most reliable fix is to add `.id(tab.id)` to force the view to be recreated when the tab changes, ensuring `.onAppear` fires with fresh state:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
                        if let tab = editorCore.activeTab {
                            IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
                        } else {
>>>REPLACE
                        if let tab = editorCore.activeTab {
                            IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
                                .id(tab.id)  // Force view recreation when tab changes to ensure content loads
                        } else {
>>>END

Also, let's add a safety backup by also watching `tab.content` changes directly:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
        .onChange(of: tab.id) { _ in
            text = tab.content
            foldingManager.detectFoldableRegions(in: text)
        }
>>>REPLACE
        .onChange(of: tab.id) { _ in
            text = tab.content
            foldingManager.detectFoldableRegions(in: text)
        }
        .onChange(of: tab.content) { newContent in
            // Sync text when tab content changes externally (e.g., file reload)
            if text != newContent {
                text = newContent
                foldingManager.detectFoldableRegions(in: text)
            }
        }
>>>END

>>>REPORT
## Root Cause Analysis

**Issue:** Files don't load content when clicked in file tree - only title shows.

**Location:** `VSCodeiPadOS/VSCodeiPadOS/ContentView.swift`, `IDEEditorView` struct (lines 355-525)

**Root Cause:**
1. `IDEEditorView` uses `@State private var text: String = ""` (line 361) to hold editor content
2. When a new file is opened, SwiftUI keeps the SAME view instance (same position in hierarchy)
3. `@State` preserves its value across re-renders
4. `.onAppear` (line 506) only fires when the view FIRST appears, not when tab changes
5. `.onChange(of: tab.id)` (line 509) should update the text, but due to SwiftUI's structural identity and potential timing issues with captured closures, it may not reliably fire when switching tabs

**Evidence:**
- `openFile(from: URL)` correctly reads content and creates tab (EditorCore.swift lines 331-357)
- `addTab()` correctly passes content to new Tab (EditorCore.swift lines 179-189)
- The tab title shows because `tab.fileName` is accessed directly in the view
- Content doesn't show because `@State text` isn't updated from `tab.content`

**Fix Applied:**
1. Added `.id(tab.id)` to `IDEEditorView` at line 42 - forces view recreation when tab changes, ensuring `.onAppear` fires with correct content
2. Added `.onChange(of: tab.content)` as a backup sync mechanism for when external content changes occur

The `.id()` modifier is the key fix - it tells SwiftUI to treat the view as a NEW instance when the tab ID changes, which resets `@State` and triggers `.onAppear`.
>>>END
