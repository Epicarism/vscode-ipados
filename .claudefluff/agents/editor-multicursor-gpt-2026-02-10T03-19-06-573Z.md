# Agent: editor-multicursor-gpt
**Status:** done
**Tokens:** 123,849
**Cost:** $0.0000
**Time:** 2026-02-10T03:19:06.573Z

## Task
VSCodeiPadOS: Verify multi-cursor editing. Check MultiCursorTextView.swift. Cmd+D should add next occurrence, Option+Click should add cursor. Verify typing works at all cursors. Fix bugs. BUILD AFTER.

## Response
>>>TOOL search
{"query":"MultiCursorTextView.swift","glob":"**/*"}
>>>END>>>TOOL read_file
{"path":"MultiCursorTextView.swift","start_line":1,"end_line":400}
>>>END>>>END>>>TOOL list_dir
{"path":"."}
>>>END
>>>END>>>TOOL search
{"query":"MultiCursorTextView.swift","glob":"**/*"} 
>>>END

>>>TOOL search
{"query":"func addNextOccurrence", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"addCursor", "glob":"**/*.swift"}
>>>END
>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:589: func addNextOccurrence() {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:259: @objc private func addNextOccurrence() {

---

[search]
Found 9 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:510: func addCursorAtPosition(_ position: Int) {
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:511: multiCursorState.addCursor(at: position)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:515: func addCursorAbove() {
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:548: multiCursorState.addCursor(at: targetPosition)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:552: func addCursorBelow() {
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:585: multiCursorState.addCursor(at: targetPosition)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:632: multiCursorState.addCursorWithSelection(
VSCodeiPadOS/VSCodeiPadOS/Views/CommandPalette.swift:273: editorCore.addCursorAbove()
VSCodeiPadOS/VSCodeiPadOS/Views/CommandPalette.swift:277: editorCore.addCursorBelow()


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift","start_line":470,"end_line":720}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 471-720 of 778)
────────────────────────────────────────
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


>>>TOOL search
{"query":"class MultiCursorState", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"multiCursorState.insertText", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"Option+Click", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"UIHoverGestureRecognizer", "glob":"**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class MultiCursorState"

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:143: editorCore.multiCursorState.insertText(text, in: &content)

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:509: /// Add cursor at a specific position (Option+Click)

---

[search]
No matches found for "UIHoverGestureRecognizer"


>>>TOOL search
{"query":"multiCursorState", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"struct Cursor", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"addCursorAtPosition(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift","start_line":1,"end_line":140}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 28 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/NavigationManager.swift:561: let position = multiCursorState.primaryCursor?.position ?? 0
VSCodeiPadOS/VSCodeiPadOS/Services/NavigationManager.swift:594: let position = multiCursorState.primaryCursor?.position ?? 0
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:92: @Published var multiCursorState = MultiCursorState()
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:511: multiCursorState.addCursor(at: position)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:519: guard let primary = multiCursorState.primaryCursor else { return }
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:548: multiCursorState.addCursor(at: targetPosition)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:556: guard let primary = multiCursorState.primaryCursor else { return }
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:585: multiCursorState.addCursor(at: targetPosition)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:601: } else if let primary = multiCursorState.primaryCursor {
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:610: multiCursorState.cursors = [Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)]
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:624: let alreadySelected = multiCursorState.cursors.contains { cursor in
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:632: multiCursorState.addCursorWithSelection(
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:651: } else if let primary = multiCursorState.primaryCursor {
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:670: multiCursorState.cursors = allRanges.enumerated().map { index, range in
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:683: multiCursorState.reset(to: position)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:740: if multiCursorState.isMultiCursor {
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:741: if let primary = multiCursorState.primaryCursor {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:360: if !parent.editorCore.multiCursorState.isMultiCursor {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:361: parent.editorCore.multiCursorState.reset(to: range.location + range.length)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:72: let cursors = editorCore.multiCursorState.cursors
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:136: editorCore.multiCursorState.isMultiCursor else {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:143: editorCore.multiCursorState.insertText(text, in: &content)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:146: let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:162: editorCore.multiCursorState.isMultiCursor else {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:169: editorCore.multiCursorState.deleteBackward(in: &content)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:172: let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
VSCodeiPadOS/VSCodeiPadOS/Views/StatusBarView.swift:52: if editorCore.multiCursorState.isMultiCursor {
VSCodeiPadOS/VSCodeiPadOS/Views/StatusBarView.swift:54: text: "\(editorCore.multiCursorState.cursors.count) cursors",

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:88: struct CursorPosition: Equatable, Hashable {

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:510: func addCursorAtPosition(_ position: Int) {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 2-140 of 778)
────────────────────────────────────────
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


>>>TOOL search
{"query":"MultiCursorState", "glob":"**/*.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":300,"end_line":460}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:92: @Published var multiCursorState = MultiCursorState()

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 301-460 of 1995)
────────────────────────────────────────
301:         var isUserScrolling = false
302: 
303:         // FEAT-044: Matching bracket highlight state
304:         private var bracketHighlightRanges: [NSRange] = []
305:         
306:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
307:         var hasAppliedInitialHighlighting = false
308:         
309:         init(_ parent: SyntaxHighlightingTextView) {
310:             self.parent = parent
311:         }
312:         
313:         func textViewDidBeginEditing(_ textView: UITextView) {
314:             // Ensure syntax highlighting is current when user begins editing
315:             // This handles cases where text was set but highlighting hasn't run yet
316:             applySyntaxHighlighting(to: textView)
317:         }
318:         
319:         func textViewDidChange(_ textView: UITextView) {
320:             // Update parent text
321:             parent.text = textView.text
322:             
323:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
324:             // This prevents flicker during the debounce period
325:             let theme = ThemeManager.shared.currentTheme
326:             let fontSize = parent.editorCore.editorFontSize
327:             textView.typingAttributes = [
328:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
329:                 .foregroundColor: UIColor(theme.editorForeground)
330:             ]
331:             
332:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
333:             highlightDebouncer?.invalidate()
334:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
335:                 DispatchQueue.main.async {
336:                     self?.applySyntaxHighlighting(to: textView)
337:                 }
338:             }
339:             
340:             updateLineCount(textView)
341:             updateCursorPosition(textView)
342:         }
343:         
344:         func textViewDidChangeSelection(_ textView: UITextView) {
345:             if !isUpdatingFromMinimap {
346:                 updateCursorPosition(textView)
347:                 updateScrollPosition(textView)
348: 
349:                 // FEAT-044: Matching bracket highlight
350:                 updateMatchingBracketHighlight(textView)
351: 
352:                 // Trigger redraw so current-line highlight/indent guides track the caret
353:                 (textView as? EditorTextView)?.setNeedsDisplay()
354: 
355:                 // Update selection in EditorCore for multi-cursor support
356:                 let range = textView.selectedRange
357:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
358: 
359:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
360:                 if !parent.editorCore.multiCursorState.isMultiCursor {
361:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
362:                 }
363:             }
364:         }
365:         
366:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
367:         
368:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
369:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
370:             isUserScrolling = true
371:             userScrollDebouncer?.invalidate()
372:         }
373:         
374:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
375:             // If not decelerating, user stopped scrolling
376:             if !decelerate {
377:                 // Small delay to let any final scroll events settle
378:                 userScrollDebouncer?.invalidate()
379:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
380:                     self?.isUserScrolling = false
381:                 }
382:             }
383:         }
384:         
385:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
386:             // Deceleration finished - user scroll is complete
387:             userScrollDebouncer?.invalidate()
388:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
389:                 self?.isUserScrolling = false
390:             }
391:         }
392:         
393:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
394:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
395:             
396:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
397:             // We still use debouncer as a fallback for edge cases
398:             if isUserScrolling {
399:                 userScrollDebouncer?.invalidate()
400:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
401:                     self?.isUserScrolling = false
402:                 }
403:             }
404:             
405:             updateScrollPosition(textView)
406:         }
407:         
408:         func updateLineCount(_ textView: UITextView) {
409:             let lines = textView.text.components(separatedBy: .newlines)
410:             DispatchQueue.main.async {
411:                 self.parent.totalLines = max(1, lines.count)
412:             }
413:         }
414:         
415:         func updateCursorPosition(_ textView: UITextView) {
416:             guard let selectedRange = textView.selectedTextRange else { return }
417:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
418:              
419:              let text = textView.text ?? ""
420:              let prefix = String(text.prefix(cursorPosition))
421:              let lines = prefix.components(separatedBy: .newlines)
422:              
423:              let lineNumber = lines.count
424:              let column = (lines.last?.count ?? 0) + 1
425:              
426:              DispatchQueue.main.async {
427:                  self.parent.currentLineNumber = lineNumber
428:                  self.parent.currentColumn = column
429:                  self.parent.cursorIndex = cursorPosition
430:              }
431:         }
432:         
433:         func updateScrollPosition(_ textView: UITextView) {
434:             guard let font = textView.font else { return }
435:             let lineHeight = font.lineHeight
436:             let scrollOffset = textView.contentOffset.y
437:             let line = Int(scrollOffset / lineHeight)
438:             
439:             // Update both synchronously to prevent feedback loop:
440:             // If we update parent.scrollPosition async, there's a race where
441:             // updateUIView sees old binding value != lastKnownScrollPosition
442:             // and scrolls back to the old position, causing jaggy scrolling.
443:             lastKnownScrollPosition = line
444:             parent.scrollPosition = line
445:         }
446:         
447:         func scrollToLine(_ line: Int, in textView: UITextView) {
448:             guard !isUpdatingFromMinimap else { return }
449:             isUpdatingFromMinimap = true
450:             
451:             let lines = textView.text.components(separatedBy: .newlines)
452:             guard line >= 0 && line < lines.count else {
453:                 isUpdatingFromMinimap = false
454:                 return
455:             }
456:             
457:             var characterPosition = 0
458:             for i in 0..<line {
459:                 characterPosition += lines[i].count + 1
460:             }


>>>TOOL search
{"query":"addCursorWithSelection", "glob":"**/*"}
>>>END
>>>TOOL search
{"query":"insertText(_ text: String, in:", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"deleteBackward(in:", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"struct Cursor", "glob":"**/*"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
.claudefluff/agents/scout-statusbar-2026-02-09T22-10-32-974Z.md:595: 554:                 multiCursorState.addCursorWithSelection(

---

[search]
No matches found for "insertText(_ text: String, in:"

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:169: editorCore.multiCursorState.deleteBackward(in: &content)

---

[search]
Found 2 matches:
.claudefluff/agents/coord-20-final-2026-02-09T11-39-30-168Z.md:646: {"command": "grep -rn 'struct CursorPosition' /Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS/VSCodeiPadOS/"}
.claudefluff/agents/crash-investigator-2026-02-10T01-40-26-755Z.md:486: 88:     struct CursorPosition: Equatable, Hashable {


>>>TOOL search
{"query":"addCursorWithSelection", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"isMultiCursor", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"struct Cursor", "glob":"**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:632: multiCursorState.addCursorWithSelection(

---

[search]
Found 5 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:740: if multiCursorState.isMultiCursor {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:360: if !parent.editorCore.multiCursorState.isMultiCursor {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:136: editorCore.multiCursorState.isMultiCursor else {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:162: editorCore.multiCursorState.isMultiCursor else {
VSCodeiPadOS/VSCodeiPadOS/Views/StatusBarView.swift:52: if editorCore.multiCursorState.isMultiCursor {

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:88: struct CursorPosition: Equatable, Hashable {


>>>TOOL search
{"query":"addCursor(at:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"addCursorWithSelection(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"cursors: [Cursor]", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"Cursor(position:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:511: multiCursorState.addCursor(at: position)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:548: multiCursorState.addCursor(at: targetPosition)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:585: multiCursorState.addCursor(at: targetPosition)

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:632: multiCursorState.addCursorWithSelection(

---

[search]
No matches found for "cursors: [Cursor]"

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:610: multiCursorState.cursors = [Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)]


>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS"}
>>>END
>>>TOOL search
{"query":"MultiCursorState", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"addCursorWithSelection(", "glob":"**/*.swift"}
>>>END
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

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:92: @Published var multiCursorState = MultiCursorState()

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:632: multiCursorState.addCursorWithSelection(


>>>TOOL search
{"query":"addCursorWithSelection", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"reset(to:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"addCursor(at:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"Cursor(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:632: multiCursorState.addCursorWithSelection(

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:361: parent.editorCore.multiCursorState.reset(to: range.location + range.length)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:683: multiCursorState.reset(to: position)

---

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:511: multiCursorState.addCursor(at: position)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:548: multiCursorState.addCursor(at: targetPosition)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:585: multiCursorState.addCursor(at: targetPosition)

---

[search]
Found 19 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/NavigationManager.swift:560: func goToDefinitionAtCursor() {
VSCodeiPadOS/VSCodeiPadOS/Services/NavigationManager.swift:593: func peekDefinitionAtCursor() {
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:494: // goToDefinitionAtCursor(), peekDefinitionAtCursor(), navigateBack(), and navigateForward()
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:511: multiCursorState.addCursor(at: position)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:548: multiCursorState.addCursor(at: targetPosition)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:585: multiCursorState.addCursor(at: targetPosition)
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:610: multiCursorState.cursors = [Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)]
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:671: Cursor(
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:682: func resetToSingleCursor(at position: Int) {
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:739: func escapeMultiCursor() {
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:742: resetToSingleCursor(at: primary.position)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:541: parent.editorCore.escapeMultiCursor()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:86: drawCursor(at: cursor.position, isPrimary: false, index: index)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:91: private func drawCursor(at position: Int, isPrimary: Bool, index: Int) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:277: editorCore?.escapeMultiCursor()
VSCodeiPadOS/VSCodeiPadOS/Views/StatusBarView.swift:58: editorCore.escapeMultiCursor()
VSCodeiPadOS/VSCodeiPadOS/Views/CommandPalette.swift:335: editorCore.goToDefinitionAtCursor()
VSCodeiPadOS/VSCodeiPadOS/Commands/AppCommands.swift:188: editorCore.goToDefinitionAtCursor()
VSCodeiPadOS/VSCodeiPadOS/Commands/AppCommands.swift:193: editorCore.peekDefinitionAtCursor()


>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services"}
>>>END
>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Models"}
>>>END
>>>TOOL search
{"query":"func insertText(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"func deleteBackward", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
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

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:134: override func insertText(_ text: String) {

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:160: override func deleteBackward() {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift","start_line":1,"end_line":260}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift (lines 2-260 of 272)
────────────────────────────────────────
2: //  MultiCursor.swift
3: //  VSCodeiPadOS
4: //
5: //  Multi-cursor editing support
6: //
7: 
8: import Foundation
9: import UIKit
10: 
11: // MARK: - Cursor
12: 
13: /// Represents a single cursor with optional selection
14: struct Cursor: Identifiable, Equatable {
15:     let id: UUID
16:     
17:     /// Character offset in the text
18:     var position: Int
19:     
20:     /// Selection anchor (if different from position, text is selected)
21:     var anchor: Int?
22:     
23:     /// Whether this is the primary cursor
24:     var isPrimary: Bool
25:     
26:     init(position: Int, anchor: Int? = nil, isPrimary: Bool = false) {
27:         self.id = UUID()
28:         self.position = position
29:         self.anchor = anchor
30:         self.isPrimary = isPrimary
31:     }
32:     
33:     /// The selection range if text is selected
34:     var selectionRange: NSRange? {
35:         guard let anchor = anchor, anchor != position else { return nil }
36:         let start = min(position, anchor)
37:         let length = abs(position - anchor)
38:         return NSRange(location: start, length: length)
39:     }
40:     
41:     /// Whether this cursor has a selection
42:     var hasSelection: Bool {
43:         guard let anchor = anchor else { return false }
44:         return anchor != position
45:     }
46:     
47:     /// The selected text given the full text
48:     func selectedText(in text: String) -> String? {
49:         guard let range = selectionRange,
50:               let swiftRange = Range(range, in: text) else { return nil }
51:         return String(text[swiftRange])
52:     }
53: }
54: 
55: // MARK: - MultiCursorState
56: 
57: /// Manages multiple cursors in the editor
58: class MultiCursorState: ObservableObject {
59:     @Published var cursors: [Cursor] = []
60:     
61:     /// The primary cursor (first one or the explicitly marked one)
62:     var primaryCursor: Cursor? {
63:         cursors.first(where: { $0.isPrimary }) ?? cursors.first
64:     }
65:     
66:     /// Whether we're in multi-cursor mode
67:     var isMultiCursor: Bool {
68:         cursors.count > 1
69:     }
70:     
71:     init() {
72:         // Start with a single cursor at position 0
73:         cursors = [Cursor(position: 0, isPrimary: true)]
74:     }
75:     
76:     // MARK: - Cursor Management
77:     
78:     /// Resets to a single cursor at the given position
79:     func reset(to position: Int) {
80:         cursors = [Cursor(position: position, isPrimary: true)]
81:     }
82:     
83:     /// Adds a cursor at the given position (Option+Click)
84:     func addCursor(at position: Int) {
85:         // Don't add duplicate cursors at the same position
86:         guard !cursors.contains(where: { $0.position == position && $0.anchor == nil }) else { return }
87:         
88:         // Remove primary from existing cursors
89:         cursors = cursors.map { cursor in
90:             var updated = cursor
91:             updated.isPrimary = false
92:             return updated
93:         }
94:         
95:         // Add new primary cursor
96:         cursors.append(Cursor(position: position, isPrimary: true))
97:         sortCursors()
98:     }
99:     
100:     /// Adds a cursor with selection
101:     func addCursorWithSelection(position: Int, anchor: Int) {
102:         // Remove primary from existing cursors
103:         cursors = cursors.map { cursor in
104:             var updated = cursor
105:             updated.isPrimary = false
106:             return updated
107:         }
108:         
109:         cursors.append(Cursor(position: position, anchor: anchor, isPrimary: true))
110:         sortCursors()
111:     }
112:     
113:     /// Removes a cursor at the given position
114:     func removeCursor(at position: Int) {
115:         guard cursors.count > 1 else { return } // Keep at least one cursor
116:         cursors.removeAll { $0.position == position }
117:         
118:         // Ensure we have a primary cursor
119:         if !cursors.contains(where: { $0.isPrimary }), !cursors.isEmpty {
120:             cursors[0].isPrimary = true
121:         }
122:     }
123:     
124:     /// Updates the position of all cursors
125:     func updatePositions(_ transform: (Int) -> Int) {
126:         cursors = cursors.map { cursor in
127:             var updated = cursor
128:             updated.position = transform(cursor.position)
129:             if let anchor = cursor.anchor {
130:                 updated.anchor = transform(anchor)
131:             }
132:             return updated
133:         }
134:     }
135:     
136:     /// Clears all selections but keeps cursors
137:     func clearSelections() {
138:         cursors = cursors.map { cursor in
139:             var updated = cursor
140:             updated.anchor = nil
141:             return updated
142:         }
143:     }
144:     
145:     /// Sort cursors by position
146:     private func sortCursors() {
147:         cursors.sort { $0.position < $1.position }
148:     }
149:     
150:     // MARK: - Text Operations
151:     
152:     /// Insert text at all cursor positions
153:     func insertText(_ text: String, in fullText: inout String) {
154:         // Process cursors from end to start to maintain positions
155:         let sortedCursors = cursors.sorted { $0.position > $1.position }
156:         var offsetAdjustment = 0
157:         
158:         for (index, cursor) in sortedCursors.enumerated() {
159:             let adjustedPosition = cursor.position
160:             
161:             if let selectionRange = cursor.selectionRange,
162:                let swiftRange = Range(selectionRange, in: fullText) {
163:                 // Replace selection
164:                 fullText.replaceSubrange(swiftRange, with: text)
165:                 let delta = text.count - selectionRange.length
166:                 offsetAdjustment += delta
167:                 
168:                 // Update cursor position
169:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
170:                 cursors[cursorIndex].position = selectionRange.location + text.count
171:                 cursors[cursorIndex].anchor = nil
172:             } else {
173:                 // Insert at cursor
174:                 let stringIndex = fullText.index(fullText.startIndex, offsetBy: min(adjustedPosition, fullText.count))
175:                 fullText.insert(contentsOf: text, at: stringIndex)
176:                 
177:                 // Update cursor position
178:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
179:                 cursors[cursorIndex].position = adjustedPosition + text.count
180:             }
181:         }
182:         
183:         // Adjust positions of cursors that come before
184:         adjustCursorPositions(afterInsertion: text.count)
185:     }
186:     
187:     /// Delete text at all cursor positions (backspace)
188:     func deleteBackward(in fullText: inout String) {
189:         let sortedCursors = cursors.sorted { $0.position > $1.position }
190:         
191:         for cursor in sortedCursors {
192:             if let selectionRange = cursor.selectionRange,
193:                let swiftRange = Range(selectionRange, in: fullText) {
194:                 // Delete selection
195:                 fullText.removeSubrange(swiftRange)
196:                 
197:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
198:                 cursors[cursorIndex].position = selectionRange.location
199:                 cursors[cursorIndex].anchor = nil
200:             } else if cursor.position > 0 {
201:                 // Delete character before cursor
202:                 let deleteIndex = fullText.index(fullText.startIndex, offsetBy: cursor.position - 1)
203:                 fullText.remove(at: deleteIndex)
204:                 
205:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
206:                 cursors[cursorIndex].position = cursor.position - 1
207:             }
208:         }
209:         
210:         // Remove duplicate cursors at same position
211:         removeDuplicateCursors()
212:     }
213:     
214:     private func adjustCursorPositions(afterInsertion length: Int) {
215:         // Already handled in insertText
216:     }
217:     
218:     private func removeDuplicateCursors() {
219:         var seen = Set<Int>()
220:         cursors = cursors.filter { cursor in
221:             if seen.contains(cursor.position) {
222:                 return false
223:             }
224:             seen.insert(cursor.position)
225:             return true
226:         }
227:         
228:         // Ensure primary cursor exists
229:         if !cursors.contains(where: { $0.isPrimary }), !cursors.isEmpty {
230:             cursors[0].isPrimary = true
231:         }
232:     }
233: }
234: 
235: // MARK: - Occurrence Finding
236: 
237: extension String {
238:     /// Find all occurrences of a substring
239:     func findAllOccurrences(of searchString: String, caseSensitive: Bool = true) -> [NSRange] {
240:         var ranges: [NSRange] = []
241:         var searchRange = startIndex..<endIndex
242:         let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
243:         
244:         while let range = self.range(of: searchString, options: options, range: searchRange) {
245:             let nsRange = NSRange(range, in: self)
246:             ranges.append(nsRange)
247:             searchRange = range.upperBound..<endIndex
248:         }
249:         
250:         return ranges
251:     }
252:     
253:     /// Find the next occurrence after a given position
254:     func findNextOccurrence(of searchString: String, after position: Int, caseSensitive: Bool = true) -> NSRange? {
255:         guard position < count else { return nil }
256:         let startIdx = index(startIndex, offsetBy: position)
257:         let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
258:         
259:         // Search from current position to end
260:         if let range = self.range(of: searchString, options: options, range: startIdx..<endIndex) {


>>>TOOL search
{"query":"addCursorAtPosition", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"modifierFlags", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/**/*.swift"}
>>>END
>>>TOOL search
{"query":"UITapGestureRecognizer", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/**/*.swift"}
>>>END
>>>TOOL search
{"query":"Option", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:510: func addCursorAtPosition(_ position: Int) {

---

[search]
Found 22 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:903: modifierFlags: .alternate,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:910: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:917: modifierFlags: [],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:924: modifierFlags: [],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:931: modifierFlags: [.command, .alternate],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:938: modifierFlags: [.command, .alternate],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:948: modifierFlags: [.command, .shift],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:956: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:966: modifierFlags: [.command, .shift],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:974: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:982: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:990: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1000: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1008: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1018: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1028: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1036: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:214: modifierFlags: []
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:222: modifierFlags: .command
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:230: modifierFlags: [.command, .shift]
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:238: modifierFlags: .command
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:246: modifierFlags: []

---

[search]
No matches found for "UITapGestureRecognizer"

---

[search]
Found 5 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:641: // Optional: snap to nearest whole number or standard size
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:900: // Using Option+D as alternative
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1666: "f32", "f64", "bool", "char", "str", "String", "Vec", "Option", "Result", "Box"]
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1912: private func highlightPattern(_ attributed: NSMutableAttributedString, pattern: String, color: UIColor, text: String, options: NSRegularExpression.Options = [], captureGroup: Int = 0) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift:22: /// Optional indicators to render as thin bars on the left side of the minimap.


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":840,"end_line":1045}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 841-1045 of 1995)
────────────────────────────────────────
841:             let safeLoc = min(max(0, caretPos), nsText.length)
842:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
843:             let caretLineText = nsText.substring(with: caretLineRange)
844: 
845:             var spaces = 0
846:             for ch in caretLineText {
847:                 if ch == " " { spaces += 1 }
848:                 else if ch == "\t" { spaces += tabSize }
849:                 else { break }
850:             }
851:             activeIndentLevel = spaces / tabSize
852:         }
853: 
854:         // Iterate visible glyphs/lines
855:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
856:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
857: 
858:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
859: 
860:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
861:             // Get text for this line
862:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
863:                   let text = self.text as NSString? else { return }
864: 
865:             let lineText = text.substring(with: range)
866: 
867:             // Calculate indentation level
868:             var spaces = 0
869:             for char in lineText {
870:                 if char == " " { spaces += 1 }
871:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
872:                 else { break }
873:             }
874: 
875:             let indentLevel = spaces / tabSize
876:             guard indentLevel > 0 else { return }
877: 
878:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
879: 
880:             for i in 1...indentLevel {
881:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
882:                 let startPoint = CGPoint(x: x, y: rect.minY)
883:                 let endPoint = CGPoint(x: x, y: rect.maxY)
884: 
885:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
886:                 context.setStrokeColor(stroke.cgColor)
887: 
888:                 context.move(to: startPoint)
889:                 context.addLine(to: endPoint)
890:                 context.strokePath()
891:             }
892:         }
893:     }
894:     
895:     override var keyCommands: [UIKeyCommand]? {
896:         var commands = super.keyCommands ?? []
897:         
898:         // Peek Definition: Alt+F12 (using special key input)
899:         // Note: F12 is not directly available on iPadOS keyboards
900:         // Using Option+D as alternative
901:         commands.append(UIKeyCommand(
902:             input: "d",
903:             modifierFlags: .alternate,
904:             action: #selector(handlePeekDefinition)
905:         ))
906: 
907:         // Go to Line: Cmd+G
908:         commands.append(UIKeyCommand(
909:             input: "g",
910:             modifierFlags: .command,
911:             action: #selector(handleGoToLine)
912:         ))
913: 
914:         // Tab: accept autocomplete if visible, else insert tab
915:         commands.append(UIKeyCommand(
916:             input: "\t",
917:             modifierFlags: [],
918:             action: #selector(handleTab)
919:         ))
920:         
921:         // Escape: dismiss autocomplete if visible, else normal escape behavior
922:         commands.append(UIKeyCommand(
923:             input: UIKeyCommand.inputEscape,
924:             modifierFlags: [],
925:             action: #selector(handleEscape)
926:         ))
927:         
928:         // Fold: Cmd+Opt+[
929:         commands.append(UIKeyCommand(
930:             input: "[",
931:             modifierFlags: [.command, .alternate],
932:             action: #selector(handleFold)
933:         ))
934:         
935:         // Unfold: Cmd+Opt+]
936:         commands.append(UIKeyCommand(
937:             input: "]",
938:             modifierFlags: [.command, .alternate],
939:             action: #selector(handleUnfold)
940:         ))
941:         
942:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
943:         // These post to NotificationCenter so ContentView can handle them
944:         
945:         // Command Palette: Cmd+Shift+P
946:         commands.append(UIKeyCommand(
947:             input: "p",
948:             modifierFlags: [.command, .shift],
949:             action: #selector(handleShowCommandPalette),
950:             discoverabilityTitle: "Command Palette"
951:         ))
952:         
953:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
954:         let toggleTerminalCmd = UIKeyCommand(
955:             input: "j",
956:             modifierFlags: .command,
957:             action: #selector(handleToggleTerminal),
958:             discoverabilityTitle: "Toggle Terminal"
959:         )
960:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
961:         commands.append(toggleTerminalCmd)
962:         
963:         // AI Assistant: Cmd+Shift+A
964:         commands.append(UIKeyCommand(
965:             input: "a",
966:             modifierFlags: [.command, .shift],
967:             action: #selector(handleShowAIAssistant),
968:             discoverabilityTitle: "AI Assistant"
969:         ))
970:         
971:         // Toggle Sidebar: Cmd+B
972:         commands.append(UIKeyCommand(
973:             input: "b",
974:             modifierFlags: .command,
975:             action: #selector(handleToggleSidebar),
976:             discoverabilityTitle: "Toggle Sidebar"
977:         ))
978:         
979:         // Quick Open: Cmd+P
980:         commands.append(UIKeyCommand(
981:             input: "p",
982:             modifierFlags: .command,
983:             action: #selector(handleShowQuickOpen),
984:             discoverabilityTitle: "Quick Open"
985:         ))
986:         
987:         // New File: Cmd+N
988:         let newFileCmd = UIKeyCommand(
989:             input: "n",
990:             modifierFlags: .command,
991:             action: #selector(handleNewFile),
992:             discoverabilityTitle: "New File"
993:         )
994:         newFileCmd.wantsPriorityOverSystemBehavior = true
995:         commands.append(newFileCmd)
996:         
997:         // Save: Cmd+S
998:         commands.append(UIKeyCommand(
999:             input: "s",
1000:             modifierFlags: .command,
1001:             action: #selector(handleSaveFile),
1002:             discoverabilityTitle: "Save"
1003:         ))
1004:         
1005:         // Close Tab: Cmd+W
1006:         let closeTabCmd = UIKeyCommand(
1007:             input: "w",
1008:             modifierFlags: .command,
1009:             action: #selector(handleCloseTab),
1010:             discoverabilityTitle: "Close Tab"
1011:         )
1012:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1013:         commands.append(closeTabCmd)
1014:         
1015:         // Find: Cmd+F
1016:         let findCmd = UIKeyCommand(
1017:             input: "f",
1018:             modifierFlags: .command,
1019:             action: #selector(handleFind),
1020:             discoverabilityTitle: "Find"
1021:         )
1022:         findCmd.wantsPriorityOverSystemBehavior = true
1023:         commands.append(findCmd)
1024:         
1025:         // Zoom In: Cmd+=
1026:         commands.append(UIKeyCommand(
1027:             input: "=",
1028:             modifierFlags: .command,
1029:             action: #selector(handleZoomIn),
1030:             discoverabilityTitle: "Zoom In"
1031:         ))
1032:         
1033:         // Zoom Out: Cmd+-
1034:         commands.append(UIKeyCommand(
1035:             input: "-",
1036:             modifierFlags: .command,
1037:             action: #selector(handleZoomOut),
1038:             discoverabilityTitle: "Zoom Out"
1039:         ))
1040:         
1041:         return commands
1042:     }
1043:     
1044:     @objc func handlePeekDefinition() {
1045:         onPeekDefinition?()


>>>TOOL search
{"query":"MultiCursorTextView(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":": MultiCursorTextView", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"EditorTextView", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/**/*.swift"}
>>>END
>>>TOOL search
{"query":"addCursorAtPosition", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "MultiCursorTextView("

---

[search]
No matches found for ": MultiCursorTextView"

---

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:109: let textView = EditorTextView()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:216: if let editorView = textView as? EditorTextView {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:353: (textView as? EditorTextView)?.setNeedsDisplay()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:760: class EditorTextView: UITextView {

---

[search]
No matches found for "addCursorAtPosition"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":740,"end_line":940}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 741-940 of 1995)
────────────────────────────────────────
741:             }
742: 
743:             guard let match = matchIndex else { return }
744: 
745:             let r1 = NSRange(location: idx, length: 1)
746:             let r2 = NSRange(location: match, length: 1)
747: 
748:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
749:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
750: 
751:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
752:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
753: 
754:             bracketHighlightRanges = [r1, r2]
755:         }
756:     }
757: }
758: 
759: // Custom text view to handle key commands, indent guides, and line highlighting
760: class EditorTextView: UITextView {
761:     var onPeekDefinition: (() -> Void)?
762:     var onEscape: (() -> Void)?
763:     var onGoToLine: (() -> Void)?
764:     
765:     // Custom action closures for context menu
766:     var onGoToDefinition: (() -> Void)?
767:     var onFindReferences: (() -> Void)?
768:     var onFormatDocument: (() -> Void)?
769:     var onToggleComment: (() -> Void)?
770:     var onFold: (() -> Void)?
771:     var onUnfold: (() -> Void)?
772: 
773:     // Autocomplete key handling hooks (return true if handled)
774:     var onAcceptAutocomplete: (() -> Bool)?
775:     var onDismissAutocomplete: (() -> Bool)?
776:     
777:     // FEAT-039 & FEAT-043
778:     private var indentGuideColor: UIColor = .separator
779:     private var activeIndentGuideColor: UIColor = .label
780:     private var currentLineHighlightColor: UIColor = .clear
781:     
782:     override init(frame: CGRect, textContainer: NSTextContainer?) {
783:         super.init(frame: frame, textContainer: textContainer)
784:         setup()
785:     }
786:     
787:     required init?(coder: NSCoder) {
788:         super.init(coder: coder)
789:         setup()
790:     }
791:     
792:     private func setup() {
793:         // Ensure we redraw when bounds/selection change
794:         contentMode = .redraw
795:     }
796:     
797:     func updateThemeColors(theme: Theme) {
798:         self.indentGuideColor = UIColor(theme.indentGuide)
799:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
800:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
801:         setNeedsDisplay()
802:     }
803:     
804:     override func draw(_ rect: CGRect) {
805:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
806:             super.draw(rect)
807:             return
808:         }
809:         
810:         // 1. Draw Current Line Highlight (FEAT-043)
811:         if let selectedRange = selectedTextRange {
812:             // Get the line rect for the cursor position
813:             let caretRect = self.caretRect(for: selectedRange.start)
814:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
815:             
816:             context.setFillColor(currentLineHighlightColor.cgColor)
817:             context.fill(lineRect)
818:         }
819:         
820:         // 2. Draw Text (super implementation)
821:         super.draw(rect)
822:         
823:         // 3. Draw Indent Guides (FEAT-039)
824:         // We iterate visible lines and draw vertical lines for indentation
825:         // Optimization: Only draw for visible range
826: 
827:         context.setLineWidth(1.0)
828: 
829:         // Respect editor tab size setting (default 4)
830:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
831:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
832: 
833:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
834:         let indentWidth = spaceWidth * CGFloat(tabSize)
835: 
836:         // Determine active indent level for caret line (for indentGuideActive)
837:         var activeIndentLevel: Int = 0
838:         if let selected = selectedTextRange {
839:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
840:             let nsText = (self.text ?? "") as NSString
841:             let safeLoc = min(max(0, caretPos), nsText.length)
842:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
843:             let caretLineText = nsText.substring(with: caretLineRange)
844: 
845:             var spaces = 0
846:             for ch in caretLineText {
847:                 if ch == " " { spaces += 1 }
848:                 else if ch == "\t" { spaces += tabSize }
849:                 else { break }
850:             }
851:             activeIndentLevel = spaces / tabSize
852:         }
853: 
854:         // Iterate visible glyphs/lines
855:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
856:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
857: 
858:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
859: 
860:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
861:             // Get text for this line
862:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
863:                   let text = self.text as NSString? else { return }
864: 
865:             let lineText = text.substring(with: range)
866: 
867:             // Calculate indentation level
868:             var spaces = 0
869:             for char in lineText {
870:                 if char == " " { spaces += 1 }
871:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
872:                 else { break }
873:             }
874: 
875:             let indentLevel = spaces / tabSize
876:             guard indentLevel > 0 else { return }
877: 
878:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
879: 
880:             for i in 1...indentLevel {
881:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
882:                 let startPoint = CGPoint(x: x, y: rect.minY)
883:                 let endPoint = CGPoint(x: x, y: rect.maxY)
884: 
885:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
886:                 context.setStrokeColor(stroke.cgColor)
887: 
888:                 context.move(to: startPoint)
889:                 context.addLine(to: endPoint)
890:                 context.strokePath()
891:             }
892:         }
893:     }
894:     
895:     override var keyCommands: [UIKeyCommand]? {
896:         var commands = super.keyCommands ?? []
897:         
898:         // Peek Definition: Alt+F12 (using special key input)
899:         // Note: F12 is not directly available on iPadOS keyboards
900:         // Using Option+D as alternative
901:         commands.append(UIKeyCommand(
902:             input: "d",
903:             modifierFlags: .alternate,
904:             action: #selector(handlePeekDefinition)
905:         ))
906: 
907:         // Go to Line: Cmd+G
908:         commands.append(UIKeyCommand(
909:             input: "g",
910:             modifierFlags: .command,
911:             action: #selector(handleGoToLine)
912:         ))
913: 
914:         // Tab: accept autocomplete if visible, else insert tab
915:         commands.append(UIKeyCommand(
916:             input: "\t",
917:             modifierFlags: [],
918:             action: #selector(handleTab)
919:         ))
920:         
921:         // Escape: dismiss autocomplete if visible, else normal escape behavior
922:         commands.append(UIKeyCommand(
923:             input: UIKeyCommand.inputEscape,
924:             modifierFlags: [],
925:             action: #selector(handleEscape)
926:         ))
927:         
928:         // Fold: Cmd+Opt+[
929:         commands.append(UIKeyCommand(
930:             input: "[",
931:             modifierFlags: [.command, .alternate],
932:             action: #selector(handleFold)
933:         ))
934:         
935:         // Unfold: Cmd+Opt+]
936:         commands.append(UIKeyCommand(
937:             input: "]",
938:             modifierFlags: [.command, .alternate],
939:             action: #selector(handleUnfold)
940:         ))


>>>TOOL search
{"query":"override func touches", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/**/*.swift"}
>>>END
>>>TOOL search
{"query":"modifierFlags", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/**/*.swift"}
>>>END
>>>TOOL search
{"query":"UIEvent", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "override func touches"

---

[search]
Found 22 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:903: modifierFlags: .alternate,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:910: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:917: modifierFlags: [],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:924: modifierFlags: [],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:931: modifierFlags: [.command, .alternate],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:938: modifierFlags: [.command, .alternate],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:948: modifierFlags: [.command, .shift],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:956: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:966: modifierFlags: [.command, .shift],
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:974: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:982: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:990: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1000: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1008: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1018: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1028: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1036: modifierFlags: .command,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:214: modifierFlags: []
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:222: modifierFlags: .command
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:230: modifierFlags: [.command, .shift]
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:238: modifierFlags: .command
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:246: modifierFlags: []

---

[search]
No matches found for "UIEvent"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":260}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-260 of 1995)
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
30:     let fontSize: CGFloat  // Explicit parameter to trigger SwiftUI updates
31:     @EnvironmentObject var editorCore: EditorCore
32: 
33:     init(
34:         text: Binding<String>,
35:         filename: String,
36:         scrollPosition: Binding<Int>,
37:         totalLines: Binding<Int>,
38:         visibleLines: Binding<Int>,
39:         currentLineNumber: Binding<Int>,
40:         currentColumn: Binding<Int>,
41:         cursorIndex: Binding<Int> = .constant(0),
42:         lineHeight: Binding<CGFloat>,
43:         isActive: Bool,
44:         fontSize: CGFloat = 14.0,
45:         requestedLineSelection: Binding<Int?> = .constant(nil),
46:         requestedCursorIndex: Binding<Int?> = .constant(nil),
47:         onAcceptAutocomplete: (() -> Bool)? = nil,
48:         onDismissAutocomplete: (() -> Bool)? = nil
49:     ) {
50:         self._text = text
51:         self.filename = filename
52:         self._scrollPosition = scrollPosition
53:         self._totalLines = totalLines
54:         self._visibleLines = visibleLines
55:         self._currentLineNumber = currentLineNumber
56:         self._currentColumn = currentColumn
57:         self._cursorIndex = cursorIndex
58:         self._lineHeight = lineHeight
59:         self.isActive = isActive
60:         self.fontSize = fontSize
61:         self._requestedLineSelection = requestedLineSelection
62:         self._requestedCursorIndex = requestedCursorIndex
63:         self.onAcceptAutocomplete = onAcceptAutocomplete
64:         self.onDismissAutocomplete = onDismissAutocomplete
65:     }
66:     
67:     // Compatibility init for older call sites (e.g. SplitEditorView) that pass editorCore explicitly.
68:     init(
69:         text: Binding<String>,
70:         filename: String,
71:         scrollPosition: Binding<Int>,
72:         totalLines: Binding<Int>,
73:         visibleLines: Binding<Int>,
74:         currentLineNumber: Binding<Int>,
75:         currentColumn: Binding<Int>,
76:         cursorIndex: Binding<Int> = .constant(0),
77:         lineHeight: Binding<CGFloat>,
78:         isActive: Bool,
79:         editorCore: EditorCore,
80:         requestedLineSelection: Binding<Int?> = .constant(nil),
81:         requestedCursorIndex: Binding<Int?> = .constant(nil),
82:         onAcceptAutocomplete: (() -> Bool)? = nil,
83:         onDismissAutocomplete: (() -> Bool)? = nil
84:     ) {
85:         self.init(
86:             text: text,
87:             filename: filename,
88:             scrollPosition: scrollPosition,
89:             totalLines: totalLines,
90:             visibleLines: visibleLines,
91:             currentLineNumber: currentLineNumber,
92:             currentColumn: currentColumn,
93:             cursorIndex: cursorIndex,
94:             lineHeight: lineHeight,
95:             isActive: isActive,
96:             fontSize: editorCore.editorFontSize,
97:             requestedLineSelection: requestedLineSelection,
98:             requestedCursorIndex: requestedCursorIndex,
99:             onAcceptAutocomplete: onAcceptAutocomplete,
100:             onDismissAutocomplete: onDismissAutocomplete
101:         )
102:     }
103: 
104:     func makeCoordinator() -> Coordinator {
105:         Coordinator(self)
106:     }
107:     
108:     func makeUIView(context: Context) -> UITextView {
109:         let textView = EditorTextView()
110:         textView.delegate = context.coordinator
111: 
112:         // Autocomplete hooks
113:         textView.onAcceptAutocomplete = onAcceptAutocomplete
114:         textView.onDismissAutocomplete = onDismissAutocomplete
115: 
116:         textView.onPeekDefinition = {
117:             context.coordinator.handlePeekDefinition(in: textView)
118:         }
119: 
120:         textView.onEscape = {
121:             context.coordinator.handleEscape()
122:         }
123: 
124:         textView.onGoToLine = {
125:             self.editorCore.showGoToLine = true
126:         }
127:         
128:         // Wire up custom context menu actions
129:         textView.onGoToDefinition = {
130:             context.coordinator.handleGoToDefinition(in: textView)
131:         }
132:         
133:         textView.onFindReferences = {
134:             context.coordinator.handleFindReferences(in: textView)
135:         }
136:         
137:         textView.onFormatDocument = {
138:             context.coordinator.handleFormatDocument(in: textView)
139:         }
140:         
141:         textView.onToggleComment = {
142:             context.coordinator.handleToggleComment(in: textView)
143:         }
144:         
145:         textView.onFold = {
146:             context.coordinator.handleFold(in: textView)
147:         }
148:         
149:         textView.onUnfold = {
150:             context.coordinator.handleUnfold(in: textView)
151:         }
152:         
153:         // Add pinch gesture for zoom
154:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
155:         textView.addGestureRecognizer(pinchGesture)
156:         context.coordinator.pinchGesture = pinchGesture
157:         
158:         // Configure text view
159:         textView.isEditable = true
160:         textView.isSelectable = true
161:         textView.autocapitalizationType = .none
162:         textView.autocorrectionType = .no
163:         textView.smartDashesType = .no
164:         textView.smartQuotesType = .no
165:         textView.smartInsertDeleteType = .no
166:         textView.spellCheckingType = .no
167:         
168:         // Set font and appearance (use editorCore.editorFontSize)
169:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
170:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
171:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
172:         textView.keyboardType = .default
173:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
174:         
175:         // Enable line wrapping
176:         textView.textContainer.lineBreakMode = .byCharWrapping
177:         textView.textContainer.widthTracksTextView = true
178:         
179:         // Calculate line height
180:         if let font = textView.font {
181:             DispatchQueue.main.async {
182:                 self.lineHeight = font.lineHeight
183:             }
184:         }
185:         
186:         // Set initial text with syntax highlighting
187:         textView.text = text
188:         context.coordinator.applySyntaxHighlighting(to: textView)
189:         context.coordinator.updateLineCount(textView)
190:         
191:         return textView
192:     }
193:     
194:     func updateUIView(_ textView: UITextView, context: Context) {
195:         // CRITICAL: Update coordinator's parent reference to current struct
196:         // SwiftUI creates new struct instances on each update, so this keeps
197:         // coordinator in sync with current bindings and properties
198:         context.coordinator.parent = self
199:         
200:         // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
201:         // This fixes the bug where syntax highlighting only appears after typing.
202:         // makeUIView applies it, but the view may not be fully in hierarchy yet,
203:         // causing the attributed text to be lost. This ensures it's applied reliably.
204:         if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
205:             context.coordinator.applySyntaxHighlighting(to: textView)
206:             context.coordinator.hasAppliedInitialHighlighting = true
207:         }
208:         
209:         // Update colors when theme changes
210:         // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor
211:         // as it interferes with attributedText syntax highlighting colors.
212:         // The foreground color is handled entirely by the attributedText.
213:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
214:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
215:         
216:         if let editorView = textView as? EditorTextView {
217:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
218:         }
219:         
220:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
221:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
222:             let selectedRange = textView.selectedRange
223:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
224:             context.coordinator.applySyntaxHighlighting(to: textView)
225:             textView.selectedRange = selectedRange
226:             
227:             // Update line height
228:             if let font = textView.font {
229:                 DispatchQueue.main.async {
230:                     self.lineHeight = font.lineHeight
231:                 }
232:             }
233:         }
234:         
235:         // Update text if changed externally
236:         if textView.text != text {
237:             let selectedRange = textView.selectedRange
238:             textView.text = text
239:             context.coordinator.applySyntaxHighlighting(to: textView)
240:             context.coordinator.hasAppliedInitialHighlighting = true
241:             textView.selectedRange = selectedRange
242:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
243:             // Re-apply highlighting if theme changed
244:             context.coordinator.applySyntaxHighlighting(to: textView)
245:         }
246:         
247:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
248:         // This prevents the editor from fighting against user scroll due to async binding lag
249:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
250:             // Update lastKnownScrollPosition FIRST to prevent race condition
251:             // where user scroll gets overridden by stale binding value
252:             context.coordinator.lastKnownScrollPosition = scrollPosition
253:             context.coordinator.scrollToLine(scrollPosition, in: textView)
254:         }
255: 
256:         // Handle line selection requests (e.g. tapping line numbers)
257:         if let requested = requestedLineSelection,
258:            requested != context.coordinator.lastRequestedLineSelection {
259:             context.coordinator.lastRequestedLineSelection = requested
260:             context.coordinator.scrollToAndSelectLine(requested, in: textView)


>>>TOOL search
{"query":"escapeMultiCursor", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:739: func escapeMultiCursor() {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:541: parent.editorCore.escapeMultiCursor()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:277: editorCore?.escapeMultiCursor()
VSCodeiPadOS/VSCodeiPadOS/Views/StatusBarView.swift:58: editorCore.escapeMultiCursor()




>>>TOOL search
{"query":"@objc func handleTab", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"handleEscape", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"handleGoToLine", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":940,"end_line":1125}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1052: @objc func handleTab() {

---

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:121: context.coordinator.handleEscape()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:537: func handleEscape() {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:925: action: #selector(handleEscape)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1059: @objc func handleEscape() {

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:911: action: #selector(handleGoToLine)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1048: @objc func handleGoToLine() {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 941-1125 of 1995)
────────────────────────────────────────
941:         
942:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
943:         // These post to NotificationCenter so ContentView can handle them
944:         
945:         // Command Palette: Cmd+Shift+P
946:         commands.append(UIKeyCommand(
947:             input: "p",
948:             modifierFlags: [.command, .shift],
949:             action: #selector(handleShowCommandPalette),
950:             discoverabilityTitle: "Command Palette"
951:         ))
952:         
953:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
954:         let toggleTerminalCmd = UIKeyCommand(
955:             input: "j",
956:             modifierFlags: .command,
957:             action: #selector(handleToggleTerminal),
958:             discoverabilityTitle: "Toggle Terminal"
959:         )
960:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
961:         commands.append(toggleTerminalCmd)
962:         
963:         // AI Assistant: Cmd+Shift+A
964:         commands.append(UIKeyCommand(
965:             input: "a",
966:             modifierFlags: [.command, .shift],
967:             action: #selector(handleShowAIAssistant),
968:             discoverabilityTitle: "AI Assistant"
969:         ))
970:         
971:         // Toggle Sidebar: Cmd+B
972:         commands.append(UIKeyCommand(
973:             input: "b",
974:             modifierFlags: .command,
975:             action: #selector(handleToggleSidebar),
976:             discoverabilityTitle: "Toggle Sidebar"
977:         ))
978:         
979:         // Quick Open: Cmd+P
980:         commands.append(UIKeyCommand(
981:             input: "p",
982:             modifierFlags: .command,
983:             action: #selector(handleShowQuickOpen),
984:             discoverabilityTitle: "Quick Open"
985:         ))
986:         
987:         // New File: Cmd+N
988:         let newFileCmd = UIKeyCommand(
989:             input: "n",
990:             modifierFlags: .command,
991:             action: #selector(handleNewFile),
992:             discoverabilityTitle: "New File"
993:         )
994:         newFileCmd.wantsPriorityOverSystemBehavior = true
995:         commands.append(newFileCmd)
996:         
997:         // Save: Cmd+S
998:         commands.append(UIKeyCommand(
999:             input: "s",
1000:             modifierFlags: .command,
1001:             action: #selector(handleSaveFile),
1002:             discoverabilityTitle: "Save"
1003:         ))
1004:         
1005:         // Close Tab: Cmd+W
1006:         let closeTabCmd = UIKeyCommand(
1007:             input: "w",
1008:             modifierFlags: .command,
1009:             action: #selector(handleCloseTab),
1010:             discoverabilityTitle: "Close Tab"
1011:         )
1012:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1013:         commands.append(closeTabCmd)
1014:         
1015:         // Find: Cmd+F
1016:         let findCmd = UIKeyCommand(
1017:             input: "f",
1018:             modifierFlags: .command,
1019:             action: #selector(handleFind),
1020:             discoverabilityTitle: "Find"
1021:         )
1022:         findCmd.wantsPriorityOverSystemBehavior = true
1023:         commands.append(findCmd)
1024:         
1025:         // Zoom In: Cmd+=
1026:         commands.append(UIKeyCommand(
1027:             input: "=",
1028:             modifierFlags: .command,
1029:             action: #selector(handleZoomIn),
1030:             discoverabilityTitle: "Zoom In"
1031:         ))
1032:         
1033:         // Zoom Out: Cmd+-
1034:         commands.append(UIKeyCommand(
1035:             input: "-",
1036:             modifierFlags: .command,
1037:             action: #selector(handleZoomOut),
1038:             discoverabilityTitle: "Zoom Out"
1039:         ))
1040:         
1041:         return commands
1042:     }
1043:     
1044:     @objc func handlePeekDefinition() {
1045:         onPeekDefinition?()
1046:     }
1047: 
1048:     @objc func handleGoToLine() {
1049:         onGoToLine?()
1050:     }
1051: 
1052:     @objc func handleTab() {
1053:         if onAcceptAutocomplete?() == true {
1054:             return
1055:         }
1056:         insertText("\t")
1057:     }
1058:     
1059:     @objc func handleEscape() {
1060:         if onDismissAutocomplete?() == true {
1061:             return
1062:         }
1063:         onEscape?()
1064:     }
1065:     
1066:     @objc func handleFold() {
1067:         onFold?()
1068:     }
1069:     
1070:     @objc func handleUnfold() {
1071:         onUnfold?()
1072:     }
1073:     
1074:     // MARK: - App-Level Shortcut Handlers
1075:     
1076:     @objc func handleShowCommandPalette() {
1077:         NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1078:     }
1079:     
1080:     @objc func handleToggleTerminal() {
1081:         NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1082:     }
1083:     
1084:     @objc func handleShowAIAssistant() {
1085:         NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1086:     }
1087:     
1088:     @objc func handleToggleSidebar() {
1089:         NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
1090:     }
1091:     
1092:     @objc func handleShowQuickOpen() {
1093:         NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
1094:     }
1095:     
1096:     @objc func handleNewFile() {
1097:         NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
1098:     }
1099:     
1100:     @objc func handleSaveFile() {
1101:         NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
1102:     }
1103:     
1104:     @objc func handleCloseTab() {
1105:         NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
1106:     }
1107:     
1108:     @objc func handleFind() {
1109:         NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
1110:     }
1111:     
1112:     @objc func handleZoomIn() {
1113:         NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
1114:     }
1115:     
1116:     @objc func handleZoomOut() {
1117:         NotificationCenter.default.post(name: NSNotification.Name("ZoomOut"), object: nil)
1118:     }
1119:     
1120:     // MARK: - Custom Actions
1121:     
1122:     @objc private func goToDefinition(_ sender: Any?) {
1123:         onGoToDefinition?()
1124:     }
1125:     


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":500,"end_line":575}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 501-575 of 1995)
────────────────────────────────────────
501: 
502:             let selectedRange = textView.selectedRange
503:             textView.attributedText = attributedText
504:             textView.selectedRange = selectedRange
505: 
506:             // Set typing attributes so newly typed characters have correct base styling
507:             // This prevents flicker during the debounce period before full highlighting runs
508:             let fontSize = parent.editorCore.editorFontSize
509:             textView.typingAttributes = [
510:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
511:                 .foregroundColor: UIColor(theme.editorForeground)
512:             ]
513: 
514:             // FEAT-044: restore matching bracket highlight after re-attributing text
515:             updateMatchingBracketHighlight(textView)
516:         }
517:         
518:         func handlePeekDefinition(in textView: UITextView) {
519:             guard let selectedRange = textView.selectedTextRange else { return }
520:             let text = textView.text ?? ""
521:             
522:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
523:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
524:                  
525:                  let prefix = String(text.prefix(location))
526:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
527:                  
528:                  parent.editorCore.triggerPeekDefinition(
529:                      file: parent.filename,
530:                      line: sourceLine,
531:                      content: text,
532:                      sourceLine: sourceLine
533:                  )
534:             }
535:         }
536:         
537:         func handleEscape() {
538:             if parent.editorCore.peekState != nil {
539:                 parent.editorCore.closePeekDefinition()
540:             } else {
541:                 parent.editorCore.escapeMultiCursor()
542:             }
543:         }
544:         
545:         func handleGoToDefinition(in textView: UITextView) {
546:             // Reuse the peek definition logic for now
547:             handlePeekDefinition(in: textView)
548:         }
549:         
550:         func handleFindReferences(in textView: UITextView) {
551:             guard let selectedRange = textView.selectedTextRange else { return }
552:             let text = textView.text ?? ""
553:             
554:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
555:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
556:                 
557:                 let prefix = String(text.prefix(location))
558:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
559:                 
560:                 // TODO: Implement find references functionality in EditorCore
561:                 // For now, just trigger peek definition as a placeholder
562:                 parent.editorCore.triggerPeekDefinition(
563:                     file: parent.filename,
564:                     line: sourceLine,
565:                     content: text,
566:                     sourceLine: sourceLine
567:                 )
568:             }
569:         }
570:         
571:         func handleFormatDocument(in textView: UITextView) {
572:             // TODO: Implement format document functionality
573:             // This would typically call a formatter in EditorCore
574:             print("Format Document: Not yet implemented")
575:         }


>>>TOOL web_search
{"query":"iOS UIGestureRecognizer modifierFlags option click", "max_results": 5}
>>>END
>>>TOOL web_search
{"query":"UIEvent modifierFlags touchesBegan iPadOS", "max_results": 5}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "iOS UIGestureRecognizer modifierFlags option click" (5 results):

1. **UIGestureRecognizer | Apple Developer Documentation**
   https://developer.apple.com/documentation/uikit/uigesturerecognizer
   The UIGestureRecognizer class defines a set of common behaviors that can be configured for all concrete gesture recognizers. It can also communicate with its delegate (an object that adopts the UIGestureRecognizerDelegate protocol), thereby enabling finer-grained customization of some behaviors.

2. **ios - UIGestureRecognizer.State is &#x27;possible&#x27; and not &#x27;recognized ...**
   https://stackoverflow.com/questions/64208905/uigesturerecognizer-state-is-possible-and-not-recognized-every-other-click-o
   UIGestureRecognizer.State is &#x27;possible&#x27; and not &#x27;recognized&#x27; every other click on an MKMapView Asked 5 years ago Modified 4 years, 11 months ago Viewed 2k times

3. **UIGestureRecognizer.ModifierFlags Property (UIKit)**
   https://learn.microsoft.com/en-us/dotnet/api/uikit.uigesturerecognizer.modifierflags?view=net-ios-26.2-10.0
   Learn more about the UIKit.UIGestureRecognizer.ModifierFlags in the UIKit namespace.

4. **UIGestureRecognizer Tutorial: Getting Started - Kodeco**
   https://www.kodeco.com/6747815-uigesturerecognizer-tutorial-getting-started
   In this tutorial, you&#x27;ll learn how to configure UIGestureRecognizer objects and how to create custom recognizers in code.

5. **Advanced Gesture Recognition with UIGestureRecognizer: Custom Gestures ...**
   https://www.momentslog.com/development/ios/advanced-gesture-recognition-with-uigesturerecognizer-custom-gestures-and-handling
   In conclusion, creating custom gestures with UIGestureRecognizer opens up a world of possibilities for enhancing user interaction in your iOS applications. By subclassing UIGestureRecognizer and implementing your own recognition logic, you can tailor gestures to fit your app&#x27;s specific needs.

---

[web_search]
🔍 DuckDuckGo results for "UIEvent modifierFlags touchesBegan iPadOS" (5 results):

1. **modifierFlags | Apple Developer Documentation**
   https://developer.apple.com/documentation/uikit/uievent/modifierflags
   The set of modifier keys that are pressed for the current event.

2. **ios - How to add a touch event to a UIView? - Stack Overflow**
   https://stackoverflow.com/questions/4660371/how-to-add-a-touch-event-to-a-uiview
   0 Create a gesture recognizer (subclass), that will implement touch events, like touchesBegan. You can add it to the view after that. This way you&#x27;ll use composition instead subclassing (which was the request).

3. **Understanding UIEvent in iOS: A Comprehensive Guide - Medium**
   https://swiftlynomad.medium.com/understanding-uievent-in-ios-a-comprehensive-guide-b324e3516b49
   This is where UIEvent comes into play. In this comprehensive guide, we will explore the concept of UIEvent in iOS, including its properties, types, and how to effectively utilize it in your apps. What is UIEvent? UIEvent is a fundamental class in iOS that represents a user&#x27;s interaction with the app&#x27;s user interface.

4. **An Example iOS 17 Touch, Multitouch, and Tap App - Answertopia**
   https://www.answertopia.com/ios/an-example-ios-touch-multitouch-and-tap-app/
   Summary This chapter has created a simple example project designed to demonstrate the use of the touchesBegan, touchesMoved, and touchesEnded methods to obtain information about the touches occurring on the display of an iOS device.

5. **UIEvent | Apple Developer Documentation**
   https://developer.apple.com/documentation/uikit/uievent
   When a touch event occurs, the system routes it to the appropriate responder and calls the appropriate method, such as touchesBegan(_:with:). The responder then uses the touches to determine an appropriate course of action. During a multitouch sequence, UIKit reuses the same UIEvent object when delivering updated touch data to your app.


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":740,"end_line":820}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 741-820 of 1995)
────────────────────────────────────────
741:             }
742: 
743:             guard let match = matchIndex else { return }
744: 
745:             let r1 = NSRange(location: idx, length: 1)
746:             let r2 = NSRange(location: match, length: 1)
747: 
748:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
749:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
750: 
751:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
752:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
753: 
754:             bracketHighlightRanges = [r1, r2]
755:         }
756:     }
757: }
758: 
759: // Custom text view to handle key commands, indent guides, and line highlighting
760: class EditorTextView: UITextView {
761:     var onPeekDefinition: (() -> Void)?
762:     var onEscape: (() -> Void)?
763:     var onGoToLine: (() -> Void)?
764:     
765:     // Custom action closures for context menu
766:     var onGoToDefinition: (() -> Void)?
767:     var onFindReferences: (() -> Void)?
768:     var onFormatDocument: (() -> Void)?
769:     var onToggleComment: (() -> Void)?
770:     var onFold: (() -> Void)?
771:     var onUnfold: (() -> Void)?
772: 
773:     // Autocomplete key handling hooks (return true if handled)
774:     var onAcceptAutocomplete: (() -> Bool)?
775:     var onDismissAutocomplete: (() -> Bool)?
776:     
777:     // FEAT-039 & FEAT-043
778:     private var indentGuideColor: UIColor = .separator
779:     private var activeIndentGuideColor: UIColor = .label
780:     private var currentLineHighlightColor: UIColor = .clear
781:     
782:     override init(frame: CGRect, textContainer: NSTextContainer?) {
783:         super.init(frame: frame, textContainer: textContainer)
784:         setup()
785:     }
786:     
787:     required init?(coder: NSCoder) {
788:         super.init(coder: coder)
789:         setup()
790:     }
791:     
792:     private func setup() {
793:         // Ensure we redraw when bounds/selection change
794:         contentMode = .redraw
795:     }
796:     
797:     func updateThemeColors(theme: Theme) {
798:         self.indentGuideColor = UIColor(theme.indentGuide)
799:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
800:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
801:         setNeedsDisplay()
802:     }
803:     
804:     override func draw(_ rect: CGRect) {
805:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
806:             super.draw(rect)
807:             return
808:         }
809:         
810:         // 1. Draw Current Line Highlight (FEAT-043)
811:         if let selectedRange = selectedTextRange {
812:             // Get the line rect for the cursor position
813:             let caretRect = self.caretRect(for: selectedRange.start)
814:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
815:             
816:             context.setFillColor(currentLineHighlightColor.cgColor)
817:             context.fill(lineRect)
818:         }
819:         
820:         // 2. Draw Text (super implementation)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":1,"end_line":320}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":740,"end_line":1120}
>>>END
>>>END>>>TOOL create_file
{"path":".patch-backups/multicursor_fix_notes.txt","content":"placeholder"}
>>>END
>>>END>>>TOOL copy_file
{"from":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","to":".patch-backups/MultiCursorTextView.swift.bak"}
>>>END
>>>END>>>TOOL copy_file
{"from":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","to":".patch-backups/SyntaxHighlightingTextView.swift.bak"}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":60,"end_line":170}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":170,"end_line":320}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":750,"end_line":820}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":820,"end_line":910}
>>>END
>>>END>>>TOOL create_file
{"path":".patch-backups/.keep","content":""}
>>>END
>>>END>>>TOOL get_symbols
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift"}
>>>END
>>>END>>>TOOL create_file
{"path":".patch-backups/README_multicursor_patch.txt","content":"Backups created for MultiCursorTextView.swift and SyntaxHighlightingTextView.swift before multi-cursor fixes."}
>>>END
>>>END>>>TOOL create_file
{"path":".patch-backups/patch_id_2026-02-10_multicursor.txt","content":"patching now"}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":70,"end_line":110}
>>>END
>>>END>>>TOOL create_file
{"path":".patch-backups/placeholder2.txt","content":"."}
>>>END
>>>END>>>TOOL create_file
{"path":".patch-backups/placeholder3.txt","content":"."}
>>>END
>>>END>>>TOOL create_file
{"path":".patch-backups/placeholder4.txt","content":"."}
>>>END
>>>END>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift
>>>FIND
        // Draw each cursor (skip the primary one as UITextView handles it)
        for (index, cursor) in cursors.enumerated() {
            // Draw selection if present
            if let selectionRange = cursor.selectionRange {
                drawSelection(for: selectionRange, isPrimary: cursor.isPrimary, index: index)
            }

            // Draw cursor line (skip primary cursor as system handles it)
            if !cursor.isPrimary {
                drawCursor(at: cursor.position, isPrimary: false, index: index)
            }
        }
>>>REPLACE
        // Draw each cursor (skip the primary one as UITextView handles it)
        for (index, cursor) in cursors.enumerated() {
            // Primary selection is handled by UITextView.selectedRange; only draw additional selections.
            if !cursor.isPrimary, let selectionRange = cursor.selectionRange {
                drawSelection(for: selectionRange, isPrimary: false, index: index)
            }

            // Draw cursor line (skip primary cursor as system handles it)
            if !cursor.isPrimary {
                drawCursor(at: cursor.position, isPrimary: false, index: index)
            }
        }
>>>END
>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift
>>>FIND
    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        // Tab: accept autocomplete (if showing), else insert tab
        commands.append(UIKeyCommand(
            title: "Accept Suggestion",
            action: #selector(tabAcceptAutocomplete),
            input: "\t",
            modifierFlags: []
        ))

        // Cmd+D: Add next occurrence
        commands.append(UIKeyCommand(
            title: "Add Next Occurrence",
            action: #selector(addNextOccurrence),
            input: "d",
            modifierFlags: .command
        ))

        // Cmd+Shift+L: Select all occurrences
        commands.append(UIKeyCommand(
            title: "Select All Occurrences",
            action: #selector(selectAllOccurrences),
            input: "l",
            modifierFlags: [.command, .shift]
        ))

        // Cmd+G: Go to Line
        commands.append(UIKeyCommand(
            title: "Go to Line",
            action: #selector(goToLine),
            input: "g",
            modifierFlags: .command
        ))

        // Escape: Dismiss autocomplete if visible, else exit multi-cursor mode
        commands.append(UIKeyCommand(
            title: "Escape",
            action: #selector(escapeKeyPressed),
            input: UIKeyCommand.inputEscape,
            modifierFlags: []
        ))

        return commands
    }
>>>REPLACE
    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        // Cmd+D: Add next occurrence
        commands.append(UIKeyCommand(
            title: "Add Next Occurrence",
            action: #selector(addNextOccurrence),
            input: "d",
            modifierFlags: .command
        ))

        // Cmd+Shift+L: Select all occurrences
        commands.append(UIKeyCommand(
            title: "Select All Occurrences",
            action: #selector(selectAllOccurrences),
            input: "l",
            modifierFlags: [.command, .shift]
        ))

        return commands
    }
>>>END
>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift
>>>FIND
    @objc private func addNextOccurrence() {
        editorCore?.addNextOccurrence()
        updateCursorDisplay()
    }

    @objc private func selectAllOccurrences() {
        editorCore?.selectAllOccurrences()
        updateCursorDisplay()
    }
>>>REPLACE
    @objc private func addNextOccurrence() {
        guard let editorCore = editorCore else { return }
        editorCore.addNextOccurrence()

        // Sync UIKit selection with the primary multi-cursor selection so typing replaces the selection.
        if let primary = editorCore.multiCursorState.primaryCursor {
            if let selection = primary.selectionRange {
                selectedRange = selection
            } else {
                selectedRange = NSRange(location: primary.position, length: 0)
            }
            delegate?.textViewDidChangeSelection?(self)
        }

        updateCursorDisplay()
    }

    @objc private func selectAllOccurrences() {
        guard let editorCore = editorCore else { return }
        editorCore.selectAllOccurrences()

        if let primary = editorCore.multiCursorState.primaryCursor {
            if let selection = primary.selectionRange {
                selectedRange = selection
            } else {
                selectedRange = NSRange(location: primary.position, length: 0)
            }
            delegate?.textViewDidChangeSelection?(self)
        }

        updateCursorDisplay()
    }
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 2-281 of 281)
────────────────────────────────────────
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
203: 
204: extension MultiCursorTextView {
205: 
206:     override var keyCommands: [UIKeyCommand]? {
207:         var commands = super.keyCommands ?? []
208: 
209:         // Tab: accept autocomplete (if showing), else insert tab
210:         commands.append(UIKeyCommand(
211:             title: "Accept Suggestion",
212:             action: #selector(tabAcceptAutocomplete),
213:             input: "\t",
214:             modifierFlags: []
215:         ))
216: 
217:         // Cmd+D: Add next occurrence
218:         commands.append(UIKeyCommand(
219:             title: "Add Next Occurrence",
220:             action: #selector(addNextOccurrence),
221:             input: "d",
222:             modifierFlags: .command
223:         ))
224: 
225:         // Cmd+Shift+L: Select all occurrences
226:         commands.append(UIKeyCommand(
227:             title: "Select All Occurrences",
228:             action: #selector(selectAllOccurrences),
229:             input: "l",
230:             modifierFlags: [.command, .shift]
231:         ))
232: 
233:         // Cmd+G: Go to Line
234:         commands.append(UIKeyCommand(
235:             title: "Go to Line",
236:             action: #selector(goToLine),
237:             input: "g",
238:             modifierFlags: .command
239:         ))
240: 
241:         // Escape: Dismiss autocomplete if visible, else exit multi-cursor mode
242:         commands.append(UIKeyCommand(
243:             title: "Escape",
244:             action: #selector(escapeKeyPressed),
245:             input: UIKeyCommand.inputEscape,
246:             modifierFlags: []
247:         ))
248: 
249:         return commands
250:     }
251: 
252:     @objc private func tabAcceptAutocomplete() {
253:         if onAcceptAutocomplete?() == true {
254:             return
255:         }
256:         insertText("\t")
257:     }
258: 
259:     @objc private func addNextOccurrence() {
260:         editorCore?.addNextOccurrence()
261:         updateCursorDisplay()
262:     }
263: 
264:     @objc private func selectAllOccurrences() {
265:         editorCore?.selectAllOccurrences()
266:         updateCursorDisplay()
267:     }
268: 
269:     @objc private func goToLine() {
270:         editorCore?.showGoToLine = true
271:     }
272: 
273:     @objc private func escapeKeyPressed() {
274:         if onDismissAutocomplete?() == true {
275:             return
276:         }
277:         editorCore?.escapeMultiCursor()
278:         updateCursorDisplay()
279:     }
280: }
281: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 741-1120 of 2000)
────────────────────────────────────────
741:                             depth -= 1
742:                         }
743:                     }
744:                     i -= 1
745:                 }
746:             }
747: 
748:             guard let match = matchIndex else { return }
749: 
750:             let r1 = NSRange(location: idx, length: 1)
751:             let r2 = NSRange(location: match, length: 1)
752: 
753:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
754:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
755: 
756:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
757:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
758: 
759:             bracketHighlightRanges = [r1, r2]
760:         }
761:     }
762: }
763: 
764: // Custom text view to handle key commands, indent guides, and line highlighting
765: class EditorTextView: UITextView {
766:     var onPeekDefinition: (() -> Void)?
767:     var onEscape: (() -> Void)?
768:     var onGoToLine: (() -> Void)?
769:     
770:     // Custom action closures for context menu
771:     var onGoToDefinition: (() -> Void)?
772:     var onFindReferences: (() -> Void)?
773:     var onFormatDocument: (() -> Void)?
774:     var onToggleComment: (() -> Void)?
775:     var onFold: (() -> Void)?
776:     var onUnfold: (() -> Void)?
777: 
778:     // Autocomplete key handling hooks (return true if handled)
779:     var onAcceptAutocomplete: (() -> Bool)?
780:     var onDismissAutocomplete: (() -> Bool)?
781:     
782:     // FEAT-039 & FEAT-043
783:     private var indentGuideColor: UIColor = .separator
784:     private var activeIndentGuideColor: UIColor = .label
785:     private var currentLineHighlightColor: UIColor = .clear
786:     
787:     override init(frame: CGRect, textContainer: NSTextContainer?) {
788:         super.init(frame: frame, textContainer: textContainer)
789:         setup()
790:     }
791:     
792:     required init?(coder: NSCoder) {
793:         super.init(coder: coder)
794:         setup()
795:     }
796:     
797:     private func setup() {
798:         // Ensure we redraw when bounds/selection change
799:         contentMode = .redraw
800:     }
801:     
802:     func updateThemeColors(theme: Theme) {
803:         self.indentGuideColor = UIColor(theme.indentGuide)
804:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
805:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
806:         setNeedsDisplay()
807:     }
808:     
809:     override func draw(_ rect: CGRect) {
810:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
811:             super.draw(rect)
812:             return
813:         }
814:         
815:         // 1. Draw Current Line Highlight (FEAT-043)
816:         if let selectedRange = selectedTextRange {
817:             // Get the line rect for the cursor position
818:             let caretRect = self.caretRect(for: selectedRange.start)
819:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
820:             
821:             context.setFillColor(currentLineHighlightColor.cgColor)
822:             context.fill(lineRect)
823:         }
824:         
825:         // 2. Draw Text (super implementation)
826:         super.draw(rect)
827:         
828:         // 3. Draw Indent Guides (FEAT-039)
829:         // We iterate visible lines and draw vertical lines for indentation
830:         // Optimization: Only draw for visible range
831: 
832:         context.setLineWidth(1.0)
833: 
834:         // Respect editor tab size setting (default 4)
835:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
836:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
837: 
838:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
839:         let indentWidth = spaceWidth * CGFloat(tabSize)
840: 
841:         // Determine active indent level for caret line (for indentGuideActive)
842:         var activeIndentLevel: Int = 0
843:         if let selected = selectedTextRange {
844:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
845:             let nsText = (self.text ?? "") as NSString
846:             let safeLoc = min(max(0, caretPos), nsText.length)
847:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
848:             let caretLineText = nsText.substring(with: caretLineRange)
849: 
850:             var spaces = 0
851:             for ch in caretLineText {
852:                 if ch == " " { spaces += 1 }
853:                 else if ch == "\t" { spaces += tabSize }
854:                 else { break }
855:             }
856:             activeIndentLevel = spaces / tabSize
857:         }
858: 
859:         // Iterate visible glyphs/lines
860:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
861:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
862: 
863:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
864: 
865:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
866:             // Get text for this line
867:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
868:                   let text = self.text as NSString? else { return }
869: 
870:             let lineText = text.substring(with: range)
871: 
872:             // Calculate indentation level
873:             var spaces = 0
874:             for char in lineText {
875:                 if char == " " { spaces += 1 }
876:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
877:                 else { break }
878:             }
879: 
880:             let indentLevel = spaces / tabSize
881:             guard indentLevel > 0 else { return }
882: 
883:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
884: 
885:             for i in 1...indentLevel {
886:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
887:                 let startPoint = CGPoint(x: x, y: rect.minY)
888:                 let endPoint = CGPoint(x: x, y: rect.maxY)
889: 
890:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
891:                 context.setStrokeColor(stroke.cgColor)
892: 
893:                 context.move(to: startPoint)
894:                 context.addLine(to: endPoint)
895:                 context.strokePath()
896:             }
897:         }
898:     }
899:     
900:     override var keyCommands: [UIKeyCommand]? {
901:         var commands = super.keyCommands ?? []
902:         
903:         // Peek Definition: Alt+F12 (using special key input)
904:         // Note: F12 is not directly available on iPadOS keyboards
905:         // Using Option+D as alternative
906:         commands.append(UIKeyCommand(
907:             input: "d",
908:             modifierFlags: .alternate,
909:             action: #selector(handlePeekDefinition)
910:         ))
911: 
912:         // Go to Line: Cmd+G
913:         commands.append(UIKeyCommand(
914:             input: "g",
915:             modifierFlags: .command,
916:             action: #selector(handleGoToLine)
917:         ))
918: 
919:         // Tab: accept autocomplete if visible, else insert tab
920:         commands.append(UIKeyCommand(
921:             input: "\t",
922:             modifierFlags: [],
923:             action: #selector(handleTab)
924:         ))
925:         
926:         // Escape: dismiss autocomplete if visible, else normal escape behavior
927:         commands.append(UIKeyCommand(
928:             input: UIKeyCommand.inputEscape,
929:             modifierFlags: [],
930:             action: #selector(handleEscape)
931:         ))
932:         
933:         // Fold: Cmd+Opt+[
934:         commands.append(UIKeyCommand(
935:             input: "[",
936:             modifierFlags: [.command, .alternate],
937:             action: #selector(handleFold)
938:         ))
939:         
940:         // Unfold: Cmd+Opt+]
941:         commands.append(UIKeyCommand(
942:             input: "]",
943:             modifierFlags: [.command, .alternate],
944:             action: #selector(handleUnfold)
945:         ))
946:         
947:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
948:         // These post to NotificationCenter so ContentView can handle them
949:         
950:         // Command Palette: Cmd+Shift+P
951:         commands.append(UIKeyCommand(
952:             input: "p",
953:             modifierFlags: [.command, .shift],
954:             action: #selector(handleShowCommandPalette),
955:             discoverabilityTitle: "Command Palette"
956:         ))
957:         
958:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
959:         let toggleTerminalCmd = UIKeyCommand(
960:             input: "j",
961:             modifierFlags: .command,
962:             action: #selector(handleToggleTerminal),
963:             discoverabilityTitle: "Toggle Terminal"
964:         )
965:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
966:         commands.append(toggleTerminalCmd)
967:         
968:         // AI Assistant: Cmd+Shift+A
969:         commands.append(UIKeyCommand(
970:             input: "a",
971:             modifierFlags: [.command, .shift],
972:             action: #selector(handleShowAIAssistant),
973:             discoverabilityTitle: "AI Assistant"
974:         ))
975:         
976:         // Toggle Sidebar: Cmd+B
977:         commands.append(UIKeyCommand(
978:             input: "b",
979:             modifierFlags: .command,
980:             action: #selector(handleToggleSidebar),
981:             discoverabilityTitle: "Toggle Sidebar"
982:         ))
983:         
984:         // Quick Open: Cmd+P
985:         commands.append(UIKeyCommand(
986:             input: "p",
987:             modifierFlags: .command,
988:             action: #selector(handleShowQuickOpen),
989:             discoverabilityTitle: "Quick Open"
990:         ))
991:         
992:         // New File: Cmd+N
993:         let newFileCmd = UIKeyCommand(
994:             input: "n",
995:             modifierFlags: .command,
996:             action: #selector(handleNewFile),
997:             discoverabilityTitle: "New File"
998:         )
999:         newFileCmd.wantsPriorityOverSystemBehavior = true
1000:         commands.append(newFileCmd)
1001:         
1002:         // Save: Cmd+S
1003:         commands.append(UIKeyCommand(
1004:             input: "s",
1005:             modifierFlags: .command,
1006:             action: #selector(handleSaveFile),
1007:             discoverabilityTitle: "Save"
1008:         ))
1009:         
1010:         // Close Tab: Cmd+W
1011:         let closeTabCmd = UIKeyCommand(
1012:             input: "w",
1013:             modifierFlags: .command,
1014:             action: #selector(handleCloseTab),
1015:             discoverabilityTitle: "Close Tab"
1016:         )
1017:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1018:         commands.append(closeTabCmd)
1019:         
1020:         // Find: Cmd+F
1021:         let findCmd = UIKeyCommand(
1022:             input: "f",
1023:             modifierFlags: .command,
1024:             action: #selector(handleFind),
1025:             discoverabilityTitle: "Find"
1026:         )
1027:         findCmd.wantsPriorityOverSystemBehavior = true
1028:         commands.append(findCmd)
1029:         
1030:         // Zoom In: Cmd+=
1031:         commands.append(UIKeyCommand(
1032:             input: "=",
1033:             modifierFlags: .command,
1034:             action: #selector(handleZoomIn),
1035:             discoverabilityTitle: "Zoom In"
1036:         ))
1037:         
1038:         // Zoom Out: Cmd+-
1039:         commands.append(UIKeyCommand(
1040:             input: "-",
1041:             modifierFlags: .command,
1042:             action: #selector(handleZoomOut),
1043:             discoverabilityTitle: "Zoom Out"
1044:         ))
1045:         
1046:         return commands
1047:     }
1048:     
1049:     @objc func handlePeekDefinition() {
1050:         onPeekDefinition?()
1051:     }
1052: 
1053:     @objc func handleGoToLine() {
1054:         onGoToLine?()
1055:     }
1056: 
1057:     @objc func handleTab() {
1058:         if onAcceptAutocomplete?() == true {
1059:             return
1060:         }
1061:         insertText("\t")
1062:     }
1063:     
1064:     @objc func handleEscape() {
1065:         if onDismissAutocomplete?() == true {
1066:             return
1067:         }
1068:         onEscape?()
1069:     }
1070:     
1071:     @objc func handleFold() {
1072:         onFold?()
1073:     }
1074:     
1075:     @objc func handleUnfold() {
1076:         onUnfold?()
1077:     }
1078:     
1079:     // MARK: - App-Level Shortcut Handlers
1080:     
1081:     @objc func handleShowCommandPalette() {
1082:         NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1083:     }
1084:     
1085:     @objc func handleToggleTerminal() {
1086:         NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1087:     }
1088:     
1089:     @objc func handleShowAIAssistant() {
1090:         NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1091:     }
1092:     
1093:     @objc func handleToggleSidebar() {
1094:         NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
1095:     }
1096:     
1097:     @objc func handleShowQuickOpen() {
1098:         NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
1099:     }
1100:     
1101:     @objc func handleNewFile() {
1102:         NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
1103:     }
1104:     
1105:     @objc func handleSaveFile() {
1106:         NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
1107:     }
1108:     
1109:     @objc func handleCloseTab() {
1110:         NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
1111:     }
1112:     
1113:     @objc func handleFind() {
1114:         NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
1115:     }
1116:     
1117:     @objc func handleZoomIn() {
1118:         NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
1119:     }
1120:     

---

[create_file]
✅ Created: .patch-backups/multicursor_fix_notes.txt

---

[copy_file]
✅ Copied: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift → .patch-backups/MultiCursorTextView.swift.bak

---

[copy_file]
✅ Copied: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift → .patch-backups/SyntaxHighlightingTextView.swift.bak

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 61-170 of 281)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 171-281 of 281)
────────────────────────────────────────
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
203: 
204: extension MultiCursorTextView {
205: 
206:     override var keyCommands: [UIKeyCommand]? {
207:         var commands = super.keyCommands ?? []
208: 
209:         // Tab: accept autocomplete (if showing), else insert tab
210:         commands.append(UIKeyCommand(
211:             title: "Accept Suggestion",
212:             action: #selector(tabAcceptAutocomplete),
213:             input: "\t",
214:             modifierFlags: []
215:         ))
216: 
217:         // Cmd+D: Add next occurrence
218:         commands.append(UIKeyCommand(
219:             title: "Add Next Occurrence",
220:             action: #selector(addNextOccurrence),
221:             input: "d",
222:             modifierFlags: .command
223:         ))
224: 
225:         // Cmd+Shift+L: Select all occurrences
226:         commands.append(UIKeyCommand(
227:             title: "Select All Occurrences",
228:             action: #selector(selectAllOccurrences),
229:             input: "l",
230:             modifierFlags: [.command, .shift]
231:         ))
232: 
233:         // Cmd+G: Go to Line
234:         commands.append(UIKeyCommand(
235:             title: "Go to Line",
236:             action: #selector(goToLine),
237:             input: "g",
238:             modifierFlags: .command
239:         ))
240: 
241:         // Escape: Dismiss autocomplete if visible, else exit multi-cursor mode
242:         commands.append(UIKeyCommand(
243:             title: "Escape",
244:             action: #selector(escapeKeyPressed),
245:             input: UIKeyCommand.inputEscape,
246:             modifierFlags: []
247:         ))
248: 
249:         return commands
250:     }
251: 
252:     @objc private func tabAcceptAutocomplete() {
253:         if onAcceptAutocomplete?() == true {
254:             return
255:         }
256:         insertText("\t")
257:     }
258: 
259:     @objc private func addNextOccurrence() {
260:         editorCore?.addNextOccurrence()
261:         updateCursorDisplay()
262:     }
263: 
264:     @objc private func selectAllOccurrences() {
265:         editorCore?.selectAllOccurrences()
266:         updateCursorDisplay()
267:     }
268: 
269:     @objc private func goToLine() {
270:         editorCore?.showGoToLine = true
271:     }
272: 
273:     @objc private func escapeKeyPressed() {
274:         if onDismissAutocomplete?() == true {
275:             return
276:         }
277:         editorCore?.escapeMultiCursor()
278:         updateCursorDisplay()
279:     }
280: }
281: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 751-820 of 2000)
────────────────────────────────────────
751:             let r2 = NSRange(location: match, length: 1)
752: 
753:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
754:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
755: 
756:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
757:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
758: 
759:             bracketHighlightRanges = [r1, r2]
760:         }
761:     }
762: }
763: 
764: // Custom text view to handle key commands, indent guides, and line highlighting
765: class EditorTextView: UITextView {
766:     var onPeekDefinition: (() -> Void)?
767:     var onEscape: (() -> Void)?
768:     var onGoToLine: (() -> Void)?
769:     
770:     // Custom action closures for context menu
771:     var onGoToDefinition: (() -> Void)?
772:     var onFindReferences: (() -> Void)?
773:     var onFormatDocument: (() -> Void)?
774:     var onToggleComment: (() -> Void)?
775:     var onFold: (() -> Void)?
776:     var onUnfold: (() -> Void)?
777: 
778:     // Autocomplete key handling hooks (return true if handled)
779:     var onAcceptAutocomplete: (() -> Bool)?
780:     var onDismissAutocomplete: (() -> Bool)?
781:     
782:     // FEAT-039 & FEAT-043
783:     private var indentGuideColor: UIColor = .separator
784:     private var activeIndentGuideColor: UIColor = .label
785:     private var currentLineHighlightColor: UIColor = .clear
786:     
787:     override init(frame: CGRect, textContainer: NSTextContainer?) {
788:         super.init(frame: frame, textContainer: textContainer)
789:         setup()
790:     }
791:     
792:     required init?(coder: NSCoder) {
793:         super.init(coder: coder)
794:         setup()
795:     }
796:     
797:     private func setup() {
798:         // Ensure we redraw when bounds/selection change
799:         contentMode = .redraw
800:     }
801:     
802:     func updateThemeColors(theme: Theme) {
803:         self.indentGuideColor = UIColor(theme.indentGuide)
804:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
805:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
806:         setNeedsDisplay()
807:     }
808:     
809:     override func draw(_ rect: CGRect) {
810:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
811:             super.draw(rect)
812:             return
813:         }
814:         
815:         // 1. Draw Current Line Highlight (FEAT-043)
816:         if let selectedRange = selectedTextRange {
817:             // Get the line rect for the cursor position
818:             let caretRect = self.caretRect(for: selectedRange.start)
819:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
820:             

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 821-910 of 2000)
────────────────────────────────────────
821:             context.setFillColor(currentLineHighlightColor.cgColor)
822:             context.fill(lineRect)
823:         }
824:         
825:         // 2. Draw Text (super implementation)
826:         super.draw(rect)
827:         
828:         // 3. Draw Indent Guides (FEAT-039)
829:         // We iterate visible lines and draw vertical lines for indentation
830:         // Optimization: Only draw for visible range
831: 
832:         context.setLineWidth(1.0)
833: 
834:         // Respect editor tab size setting (default 4)
835:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
836:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
837: 
838:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
839:         let indentWidth = spaceWidth * CGFloat(tabSize)
840: 
841:         // Determine active indent level for caret line (for indentGuideActive)
842:         var activeIndentLevel: Int = 0
843:         if let selected = selectedTextRange {
844:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
845:             let nsText = (self.text ?? "") as NSString
846:             let safeLoc = min(max(0, caretPos), nsText.length)
847:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
848:             let caretLineText = nsText.substring(with: caretLineRange)
849: 
850:             var spaces = 0
851:             for ch in caretLineText {
852:                 if ch == " " { spaces += 1 }
853:                 else if ch == "\t" { spaces += tabSize }
854:                 else { break }
855:             }
856:             activeIndentLevel = spaces / tabSize
857:         }
858: 
859:         // Iterate visible glyphs/lines
860:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
861:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
862: 
863:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
864: 
865:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
866:             // Get text for this line
867:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
868:                   let text = self.text as NSString? else { return }
869: 
870:             let lineText = text.substring(with: range)
871: 
872:             // Calculate indentation level
873:             var spaces = 0
874:             for char in lineText {
875:                 if char == " " { spaces += 1 }
876:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
877:                 else { break }
878:             }
879: 
880:             let indentLevel = spaces / tabSize
881:             guard indentLevel > 0 else { return }
882: 
883:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
884: 
885:             for i in 1...indentLevel {
886:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
887:                 let startPoint = CGPoint(x: x, y: rect.minY)
888:                 let endPoint = CGPoint(x: x, y: rect.maxY)
889: 
890:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
891:                 context.setStrokeColor(stroke.cgColor)
892: 
893:                 context.move(to: startPoint)
894:                 context.addLine(to: endPoint)
895:                 context.strokePath()
896:             }
897:         }
898:     }
899:     
900:     override var keyCommands: [UIKeyCommand]? {
901:         var commands = super.keyCommands ?? []
902:         
903:         // Peek Definition: Alt+F12 (using special key input)
904:         // Note: F12 is not directly available on iPadOS keyboards
905:         // Using Option+D as alternative
906:         commands.append(UIKeyCommand(
907:             input: "d",
908:             modifierFlags: .alternate,
909:             action: #selector(handlePeekDefinition)
910:         ))

---

[create_file]
✅ Created: .patch-backups/.keep

---

[get_symbols]
No symbols found in VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (file may need to be opened first)

---

[create_file]
✅ Created: .patch-backups/README_multicursor_patch.txt

---

[create_file]
✅ Created: .patch-backups/patch_id_2026-02-10_multicursor.txt

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 71-110 of 281)
────────────────────────────────────────
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

---

[create_file]
✅ Created: .patch-backups/placeholder2.txt

---

[create_file]
✅ Created: .patch-backups/placeholder3.txt

---

[create_file]
✅ Created: .patch-backups/placeholder4.txt

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift]
Applied 1 patch(es)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":60,"end_line":120}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 61-120 of 280)
────────────────────────────────────────
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
79:             // Primary selection is handled by UITextView.selectedRange; only draw additional selections.
80:             if !cursor.isPrimary, let selectionRange = cursor.selectionRange {
81:                 drawSelection(for: selectionRange, isPrimary: false, index: index)
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":190,"end_line":285}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 191-280 of 280)
────────────────────────────────────────
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
203: 
204: extension MultiCursorTextView {
205: 
206:     override var keyCommands: [UIKeyCommand]? {
207:         var commands = super.keyCommands ?? []
208: 
209:         // Cmd+D: Add next occurrence
210:         commands.append(UIKeyCommand(
211:             title: "Add Next Occurrence",
212:             action: #selector(addNextOccurrence),
213:             input: "d",
214:             modifierFlags: .command
215:         ))
216: 
217:         // Cmd+Shift+L: Select all occurrences
218:         commands.append(UIKeyCommand(
219:             title: "Select All Occurrences",
220:             action: #selector(selectAllOccurrences),
221:             input: "l",
222:             modifierFlags: [.command, .shift]
223:         ))
224: 
225:         return commands
226:     }
227: 
228:     @objc private func tabAcceptAutocomplete() {
229:         if onAcceptAutocomplete?() == true {
230:             return
231:         }
232:         insertText("\t")
233:     }
234: 
235:     @objc private func addNextOccurrence() {
236:         guard let editorCore = editorCore else { return }
237:         editorCore.addNextOccurrence()
238: 
239:         // Sync UIKit selection with the primary multi-cursor selection so typing replaces the selection.
240:         if let primary = editorCore.multiCursorState.primaryCursor {
241:             if let selection = primary.selectionRange {
242:                 selectedRange = selection
243:             } else {
244:                 selectedRange = NSRange(location: primary.position, length: 0)
245:             }
246:             delegate?.textViewDidChangeSelection?(self)
247:         }
248: 
249:         updateCursorDisplay()
250:     }
251: 
252:     @objc private func selectAllOccurrences() {
253:         guard let editorCore = editorCore else { return }
254:         editorCore.selectAllOccurrences()
255: 
256:         if let primary = editorCore.multiCursorState.primaryCursor {
257:             if let selection = primary.selectionRange {
258:                 selectedRange = selection
259:             } else {
260:                 selectedRange = NSRange(location: primary.position, length: 0)
261:             }
262:             delegate?.textViewDidChangeSelection?(self)
263:         }
264: 
265:         updateCursorDisplay()
266:     }
267: 
268:     @objc private func goToLine() {
269:         editorCore?.showGoToLine = true
270:     }
271: 
272:     @objc private func escapeKeyPressed() {
273:         if onDismissAutocomplete?() == true {
274:             return
275:         }
276:         editorCore?.escapeMultiCursor()
277:         updateCursorDisplay()
278:     }
279: }
280: 


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":120,"end_line":210}
>>>END
>>>TOOL search
{"query":"class EditorTextView: UITextView", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"let textView = EditorTextView()", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 121-210 of 280)
────────────────────────────────────────
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
203: 
204: extension MultiCursorTextView {
205: 
206:     override var keyCommands: [UIKeyCommand]? {
207:         var commands = super.keyCommands ?? []
208: 
209:         // Cmd+D: Add next occurrence
210:         commands.append(UIKeyCommand(

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:776: class EditorTextView: UITextView {

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:109: let textView = EditorTextView()


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":1,"end_line":285}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":90,"end_line":140}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 2-280 of 280)
────────────────────────────────────────
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
79:             // Primary selection is handled by UITextView.selectedRange; only draw additional selections.
80:             if !cursor.isPrimary, let selectionRange = cursor.selectionRange {
81:                 drawSelection(for: selectionRange, isPrimary: false, index: index)
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
203: 
204: extension MultiCursorTextView {
205: 
206:     override var keyCommands: [UIKeyCommand]? {
207:         var commands = super.keyCommands ?? []
208: 
209:         // Cmd+D: Add next occurrence
210:         commands.append(UIKeyCommand(
211:             title: "Add Next Occurrence",
212:             action: #selector(addNextOccurrence),
213:             input: "d",
214:             modifierFlags: .command
215:         ))
216: 
217:         // Cmd+Shift+L: Select all occurrences
218:         commands.append(UIKeyCommand(
219:             title: "Select All Occurrences",
220:             action: #selector(selectAllOccurrences),
221:             input: "l",
222:             modifierFlags: [.command, .shift]
223:         ))
224: 
225:         return commands
226:     }
227: 
228:     @objc private func tabAcceptAutocomplete() {
229:         if onAcceptAutocomplete?() == true {
230:             return
231:         }
232:         insertText("\t")
233:     }
234: 
235:     @objc private func addNextOccurrence() {
236:         guard let editorCore = editorCore else { return }
237:         editorCore.addNextOccurrence()
238: 
239:         // Sync UIKit selection with the primary multi-cursor selection so typing replaces the selection.
240:         if let primary = editorCore.multiCursorState.primaryCursor {
241:             if let selection = primary.selectionRange {
242:                 selectedRange = selection
243:             } else {
244:                 selectedRange = NSRange(location: primary.position, length: 0)
245:             }
246:             delegate?.textViewDidChangeSelection?(self)
247:         }
248: 
249:         updateCursorDisplay()
250:     }
251: 
252:     @objc private func selectAllOccurrences() {
253:         guard let editorCore = editorCore else { return }
254:         editorCore.selectAllOccurrences()
255: 
256:         if let primary = editorCore.multiCursorState.primaryCursor {
257:             if let selection = primary.selectionRange {
258:                 selectedRange = selection
259:             } else {
260:                 selectedRange = NSRange(location: primary.position, length: 0)
261:             }
262:             delegate?.textViewDidChangeSelection?(self)
263:         }
264: 
265:         updateCursorDisplay()
266:     }
267: 
268:     @objc private func goToLine() {
269:         editorCore?.showGoToLine = true
270:     }
271: 
272:     @objc private func escapeKeyPressed() {
273:         if onDismissAutocomplete?() == true {
274:             return
275:         }
276:         editorCore?.escapeMultiCursor()
277:         updateCursorDisplay()
278:     }
279: }
280: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 91-140 of 2011)
────────────────────────────────────────
91:             currentLineNumber: currentLineNumber,
92:             currentColumn: currentColumn,
93:             cursorIndex: cursorIndex,
94:             lineHeight: lineHeight,
95:             isActive: isActive,
96:             fontSize: editorCore.editorFontSize,
97:             requestedLineSelection: requestedLineSelection,
98:             requestedCursorIndex: requestedCursorIndex,
99:             onAcceptAutocomplete: onAcceptAutocomplete,
100:             onDismissAutocomplete: onDismissAutocomplete
101:         )
102:     }
103: 
104:     func makeCoordinator() -> Coordinator {
105:         Coordinator(self)
106:     }
107:     
108:     func makeUIView(context: Context) -> UITextView {
109:         let textView = EditorTextView()
110:         textView.delegate = context.coordinator
111: 
112:         // Autocomplete hooks
113:         textView.onAcceptAutocomplete = onAcceptAutocomplete
114:         textView.onDismissAutocomplete = onDismissAutocomplete
115: 
116:         textView.onPeekDefinition = {
117:             context.coordinator.handlePeekDefinition(in: textView)
118:         }
119: 
120:         textView.onEscape = {
121:             context.coordinator.handleEscape()
122:         }
123: 
124:         textView.onGoToLine = {
125:             self.editorCore.showGoToLine = true
126:         }
127:         
128:         // Wire up custom context menu actions
129:         textView.onGoToDefinition = {
130:             context.coordinator.handleGoToDefinition(in: textView)
131:         }
132:         
133:         textView.onFindReferences = {
134:             context.coordinator.handleFindReferences(in: textView)
135:         }
136:         
137:         textView.onFormatDocument = {
138:             context.coordinator.handleFormatDocument(in: textView)
139:         }
140:         


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":1,"end_line":120}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":760,"end_line":820}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 2-120 of 280)
────────────────────────────────────────
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
79:             // Primary selection is handled by UITextView.selectedRange; only draw additional selections.
80:             if !cursor.isPrimary, let selectionRange = cursor.selectionRange {
81:                 drawSelection(for: selectionRange, isPrimary: false, index: index)
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 761-820 of 2011)
────────────────────────────────────────
761:             let r1 = NSRange(location: idx, length: 1)
762:             let r2 = NSRange(location: match, length: 1)
763: 
764:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
765:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
766: 
767:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
768:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
769: 
770:             bracketHighlightRanges = [r1, r2]
771:         }
772:     }
773: }
774: 
775: // Custom text view to handle key commands, indent guides, and line highlighting
776: class EditorTextView: UITextView {
777:     var onPeekDefinition: (() -> Void)?
778:     var onEscape: (() -> Void)?
779:     var onGoToLine: (() -> Void)?
780:     
781:     // Custom action closures for context menu
782:     var onGoToDefinition: (() -> Void)?
783:     var onFindReferences: (() -> Void)?
784:     var onFormatDocument: (() -> Void)?
785:     var onToggleComment: (() -> Void)?
786:     var onFold: (() -> Void)?
787:     var onUnfold: (() -> Void)?
788: 
789:     // Autocomplete key handling hooks (return true if handled)
790:     var onAcceptAutocomplete: (() -> Bool)?
791:     var onDismissAutocomplete: (() -> Bool)?
792:     
793:     // FEAT-039 & FEAT-043
794:     private var indentGuideColor: UIColor = .separator
795:     private var activeIndentGuideColor: UIColor = .label
796:     private var currentLineHighlightColor: UIColor = .clear
797:     
798:     override init(frame: CGRect, textContainer: NSTextContainer?) {
799:         super.init(frame: frame, textContainer: textContainer)
800:         setup()
801:     }
802:     
803:     required init?(coder: NSCoder) {
804:         super.init(coder: coder)
805:         setup()
806:     }
807:     
808:     private func setup() {
809:         // Ensure we redraw when bounds/selection change
810:         contentMode = .redraw
811:     }
812:     
813:     func updateThemeColors(theme: Theme) {
814:         self.indentGuideColor = UIColor(theme.indentGuide)
815:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
816:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
817:         setNeedsDisplay()
818:     }
819:     
820:     override func draw(_ rect: CGRect) {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift","start_line":720,"end_line":780}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":330,"end_line":370}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 721-778 of 778)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 331-370 of 2011)
────────────────────────────────────────
331:             // This handles cases where text was set but highlighting hasn't run yet
332:             applySyntaxHighlighting(to: textView)
333:         }
334:         
335:         func textViewDidChange(_ textView: UITextView) {
336:             // Update parent text
337:             parent.text = textView.text
338:             
339:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
340:             // This prevents flicker during the debounce period
341:             let theme = ThemeManager.shared.currentTheme
342:             let fontSize = parent.editorCore.editorFontSize
343:             textView.typingAttributes = [
344:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
345:                 .foregroundColor: UIColor(theme.editorForeground)
346:             ]
347:             
348:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
349:             highlightDebouncer?.invalidate()
350:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
351:                 DispatchQueue.main.async {
352:                     self?.applySyntaxHighlighting(to: textView)
353:                 }
354:             }
355:             
356:             updateLineCount(textView)
357:             updateCursorPosition(textView)
358:         }
359:         
360:         func textViewDidChangeSelection(_ textView: UITextView) {
361:             if !isUpdatingFromMinimap {
362:                 updateCursorPosition(textView)
363:                 updateScrollPosition(textView)
364: 
365:                 // FEAT-044: Matching bracket highlight
366:                 updateMatchingBracketHighlight(textView)
367: 
368:                 // Trigger redraw so current-line highlight/indent guides track the caret
369:                 (textView as? EditorTextView)?.setNeedsDisplay()
370: 


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":100,"end_line":135}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":770,"end_line":790}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":1,"end_line":70}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-135 of 2012)
────────────────────────────────────────
101:         )
102:     }
103: 
104:     func makeCoordinator() -> Coordinator {
105:         Coordinator(self)
106:     }
107:     
108:     func makeUIView(context: Context) -> UITextView {
109:         let textView = EditorTextView()
110:         textView.delegate = context.coordinator
111: 
112:         // Autocomplete hooks
113:         textView.onAcceptAutocomplete = onAcceptAutocomplete
114:         textView.onDismissAutocomplete = onDismissAutocomplete
115: 
116:         textView.onPeekDefinition = {
117:             context.coordinator.handlePeekDefinition(in: textView)
118:         }
119: 
120:         textView.onEscape = {
121:             context.coordinator.handleEscape()
122:         }
123: 
124:         textView.onGoToLine = {
125:             self.editorCore.showGoToLine = true
126:         }
127:         
128:         // Wire up custom context menu actions
129:         textView.onGoToDefinition = {
130:             context.coordinator.handleGoToDefinition(in: textView)
131:         }
132:         
133:         textView.onFindReferences = {
134:             context.coordinator.handleFindReferences(in: textView)
135:         }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 771-790 of 2012)
────────────────────────────────────────
771:             bracketHighlightRanges = [r1, r2]
772:         }
773:     }
774: }
775: 
776: // Custom text view to handle key commands, indent guides, and line highlighting
777: class EditorTextView: UITextView {
778:     var onPeekDefinition: (() -> Void)?
779:     var onEscape: (() -> Void)?
780:     var onGoToLine: (() -> Void)?
781:     
782:     // Custom action closures for context menu
783:     var onGoToDefinition: (() -> Void)?
784:     var onFindReferences: (() -> Void)?
785:     var onFormatDocument: (() -> Void)?
786:     var onToggleComment: (() -> Void)?
787:     var onFold: (() -> Void)?
788:     var onUnfold: (() -> Void)?
789: 
790:     // Autocomplete key handling hooks (return true if handled)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 2-70 of 280)
────────────────────────────────────────
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


>>>TOOL search
{"query":"class Coordinator", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":260,"end_line":340}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:297: class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 261-340 of 2051)
────────────────────────────────────────
261:             context.coordinator.lastRequestedLineSelection = requested
262:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
263:             // Defer @Binding update to avoid "Publishing changes from within view updates"
264:             DispatchQueue.main.async {
265:                 self.requestedLineSelection = nil
266:             }
267:         }
268: 
269:         // Handle cursor index requests (e.g. accepting autocomplete)
270:         if let requested = requestedCursorIndex,
271:            requested != context.coordinator.lastRequestedCursorIndex {
272:             context.coordinator.lastRequestedCursorIndex = requested
273:             // Use UTF-16 count for NSRange compatibility
274:             let textLength = (textView.text as NSString?)?.length ?? 0
275:             let safeIndex = max(0, min(requested, textLength))
276:             textView.selectedRange = NSRange(location: safeIndex, length: 0)
277:             
278:             // Ensure cursor is visible by scrolling to it
279:             textView.scrollRangeToVisible(textView.selectedRange)
280:             
281:             // Defer @Binding update to avoid "Publishing changes from within view updates"
282:             DispatchQueue.main.async {
283:                 self.requestedCursorIndex = nil
284:             }
285: 
286:             // Update SwiftUI state
287:             context.coordinator.updateCursorPosition(textView)
288:             context.coordinator.updateScrollPosition(textView)
289:         }
290:         
291:         // Note: updateLineCount is called in textViewDidChange, no need to call here
292:         // as it causes unnecessary state churn on every updateUIView
293:     }
294:     
295:     // MARK: - Coordinator
296:     
297:     class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
298:         var parent: SyntaxHighlightingTextView
299:         var lastKnownScrollPosition: Int = 0
300:         var lastThemeId: String = ""
301:         var lastRequestedLineSelection: Int? = nil
302:         var lastRequestedCursorIndex: Int? = nil
303:         private var isUpdatingFromMinimap = false
304:         private var highlightDebouncer: Timer?
305:         weak var pinchGesture: UIPinchGestureRecognizer?
306:         private var initialFontSize: CGFloat = 0
307:         
308:         // Track user scroll to prevent programmatic scroll fighting back
309:         private var userScrollDebouncer: Timer?
310:         var isUserScrolling = false
311: 
312:         // FEAT-044: Matching bracket highlight state
313:         private var bracketHighlightRanges: [NSRange] = []
314:         
315:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
316:         var hasAppliedInitialHighlighting = false
317:         
318:         init(_ parent: SyntaxHighlightingTextView) {
319:             self.parent = parent
320:         }
321:         
322:         // MARK: - UIGestureRecognizerDelegate
323:         
324:         // Allow pinch gesture to work simultaneously with text selection gestures
325:         func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
326:             // Allow pinch to work alongside native text selection gestures
327:             return true
328:         }
329:         
330:         func textViewDidBeginEditing(_ textView: UITextView) {
331:             // Ensure syntax highlighting is current when user begins editing
332:             // This handles cases where text was set but highlighting hasn't run yet
333:             applySyntaxHighlighting(to: textView)
334:         }
335:         
336:         func textViewDidChange(_ textView: UITextView) {
337:             // Update parent text
338:             parent.text = textView.text
339:             
340:             // Set typing attributes IMMEDIATELY so new characters have proper base styling


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift","start_line":140,"end_line":235}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift (lines 141-235 of 272)
────────────────────────────────────────
141:             return updated
142:         }
143:     }
144:     
145:     /// Sort cursors by position
146:     private func sortCursors() {
147:         cursors.sort { $0.position < $1.position }
148:     }
149:     
150:     // MARK: - Text Operations
151:     
152:     /// Insert text at all cursor positions
153:     func insertText(_ text: String, in fullText: inout String) {
154:         // Process cursors from end to start to maintain positions
155:         let sortedCursors = cursors.sorted { $0.position > $1.position }
156:         var offsetAdjustment = 0
157:         
158:         for (index, cursor) in sortedCursors.enumerated() {
159:             let adjustedPosition = cursor.position
160:             
161:             if let selectionRange = cursor.selectionRange,
162:                let swiftRange = Range(selectionRange, in: fullText) {
163:                 // Replace selection
164:                 fullText.replaceSubrange(swiftRange, with: text)
165:                 let delta = text.count - selectionRange.length
166:                 offsetAdjustment += delta
167:                 
168:                 // Update cursor position
169:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
170:                 cursors[cursorIndex].position = selectionRange.location + text.count
171:                 cursors[cursorIndex].anchor = nil
172:             } else {
173:                 // Insert at cursor
174:                 let stringIndex = fullText.index(fullText.startIndex, offsetBy: min(adjustedPosition, fullText.count))
175:                 fullText.insert(contentsOf: text, at: stringIndex)
176:                 
177:                 // Update cursor position
178:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
179:                 cursors[cursorIndex].position = adjustedPosition + text.count
180:             }
181:         }
182:         
183:         // Adjust positions of cursors that come before
184:         adjustCursorPositions(afterInsertion: text.count)
185:     }
186:     
187:     /// Delete text at all cursor positions (backspace)
188:     func deleteBackward(in fullText: inout String) {
189:         let sortedCursors = cursors.sorted { $0.position > $1.position }
190:         
191:         for cursor in sortedCursors {
192:             if let selectionRange = cursor.selectionRange,
193:                let swiftRange = Range(selectionRange, in: fullText) {
194:                 // Delete selection
195:                 fullText.removeSubrange(swiftRange)
196:                 
197:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
198:                 cursors[cursorIndex].position = selectionRange.location
199:                 cursors[cursorIndex].anchor = nil
200:             } else if cursor.position > 0 {
201:                 // Delete character before cursor
202:                 let deleteIndex = fullText.index(fullText.startIndex, offsetBy: cursor.position - 1)
203:                 fullText.remove(at: deleteIndex)
204:                 
205:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
206:                 cursors[cursorIndex].position = cursor.position - 1
207:             }
208:         }
209:         
210:         // Remove duplicate cursors at same position
211:         removeDuplicateCursors()
212:     }
213:     
214:     private func adjustCursorPositions(afterInsertion length: Int) {
215:         // Already handled in insertText
216:     }
217:     
218:     private func removeDuplicateCursors() {
219:         var seen = Set<Int>()
220:         cursors = cursors.filter { cursor in
221:             if seen.contains(cursor.position) {
222:                 return false
223:             }
224:             seen.insert(cursor.position)
225:             return true
226:         }
227:         
228:         // Ensure primary cursor exists
229:         if !cursors.contains(where: { $0.isPrimary }), !cursors.isEmpty {
230:             cursors[0].isPrimary = true
231:         }
232:     }
233: }
234: 
235: // MARK: - Occurrence Finding


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":340,"end_line":410}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":460,"end_line":520}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":760,"end_line":820}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 341-410 of 2051)
────────────────────────────────────────
341:             // This prevents flicker during the debounce period
342:             let theme = ThemeManager.shared.currentTheme
343:             let fontSize = parent.editorCore.editorFontSize
344:             textView.typingAttributes = [
345:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
346:                 .foregroundColor: UIColor(theme.editorForeground)
347:             ]
348:             
349:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
350:             highlightDebouncer?.invalidate()
351:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
352:                 DispatchQueue.main.async {
353:                     self?.applySyntaxHighlighting(to: textView)
354:                 }
355:             }
356:             
357:             updateLineCount(textView)
358:             updateCursorPosition(textView)
359:         }
360:         
361:         func textViewDidChangeSelection(_ textView: UITextView) {
362:             if !isUpdatingFromMinimap {
363:                 updateCursorPosition(textView)
364:                 updateScrollPosition(textView)
365: 
366:                 // FEAT-044: Matching bracket highlight
367:                 updateMatchingBracketHighlight(textView)
368: 
369:                 // Trigger redraw so current-line highlight/indent guides track the caret
370:                 (textView as? EditorTextView)?.setNeedsDisplay()
371: 
372:                 // Update selection in EditorCore for multi-cursor support
373:                 let range = textView.selectedRange
374:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
375: 
376:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
377:                 if !parent.editorCore.multiCursorState.isMultiCursor {
378:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
379:                 }
380:             }
381:         }
382:         
383:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
384:         
385:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
386:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
387:             isUserScrolling = true
388:             userScrollDebouncer?.invalidate()
389:         }
390:         
391:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
392:             // If not decelerating, user stopped scrolling
393:             if !decelerate {
394:                 // Small delay to let any final scroll events settle
395:                 userScrollDebouncer?.invalidate()
396:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
397:                     self?.isUserScrolling = false
398:                 }
399:             }
400:         }
401:         
402:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
403:             // Deceleration finished - user scroll is complete
404:             userScrollDebouncer?.invalidate()
405:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
406:                 self?.isUserScrolling = false
407:             }
408:         }
409:         
410:         func scrollViewDidScroll(_ scrollView: UIScrollView) {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 461-520 of 2051)
────────────────────────────────────────
461:             parent.scrollPosition = line
462:         }
463:         
464:         func scrollToLine(_ line: Int, in textView: UITextView) {
465:             guard !isUpdatingFromMinimap else { return }
466:             isUpdatingFromMinimap = true
467:             
468:             let lines = textView.text.components(separatedBy: .newlines)
469:             guard line >= 0 && line < lines.count else {
470:                 isUpdatingFromMinimap = false
471:                 return
472:             }
473:             
474:             var characterPosition = 0
475:             for i in 0..<line {
476:                 characterPosition += lines[i].count + 1
477:             }
478:             
479:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
480:                 let rect = textView.caretRect(for: position)
481:                 let targetY = max(0, rect.origin.y)
482:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
483:             }
484:             
485:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
486:                 self.isUpdatingFromMinimap = false
487:             }
488:         }
489: 
490:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
491:             let lines = textView.text.components(separatedBy: .newlines)
492:             guard line >= 0 && line < lines.count else { return }
493: 
494:             var characterPosition = 0
495:             for i in 0..<line {
496:                 characterPosition += lines[i].count + 1
497:             }
498: 
499:             // FEAT-041: select entire line (excluding trailing newline)
500:             let lineLength = (lines[line] as NSString).length
501:             let range = NSRange(location: characterPosition, length: lineLength)
502:             textView.selectedRange = range
503: 
504:             // Ensure it's visible
505:             scrollToLine(line, in: textView)
506: 
507:             // Update SwiftUI state
508:             updateCursorPosition(textView)
509:             updateScrollPosition(textView)
510:         }
511: 
512:         func applySyntaxHighlighting(to textView: UITextView) {
513:             let theme = ThemeManager.shared.currentTheme
514:             lastThemeId = theme.id
515: 
516:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
517:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
518: 
519:             let selectedRange = textView.selectedRange
520: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 761-820 of 2051)
────────────────────────────────────────
761:                             break
762:                         } else {
763:                             depth -= 1
764:                         }
765:                     }
766:                     i -= 1
767:                 }
768:             }
769: 
770:             guard let match = matchIndex else { return }
771: 
772:             let r1 = NSRange(location: idx, length: 1)
773:             let r2 = NSRange(location: match, length: 1)
774: 
775:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
776:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
777: 
778:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
779:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
780: 
781:             bracketHighlightRanges = [r1, r2]
782:         }
783:     }
784: }
785: 
786: // Custom text view to handle key commands, indent guides, and line highlighting
787: class EditorTextView: UITextView {
788:     var onPeekDefinition: (() -> Void)?
789:     var onEscape: (() -> Void)?
790:     var onGoToLine: (() -> Void)?
791:     
792:     // Custom action closures for context menu
793:     var onGoToDefinition: (() -> Void)?
794:     var onFindReferences: (() -> Void)?
795:     var onFormatDocument: (() -> Void)?
796:     var onToggleComment: (() -> Void)?
797:     var onFold: (() -> Void)?
798:     var onUnfold: (() -> Void)?
799: 
800:     // Autocomplete key handling hooks (return true if handled)
801:     var onAcceptAutocomplete: (() -> Bool)?
802:     var onDismissAutocomplete: (() -> Bool)?
803:     
804:     // FEAT-039 & FEAT-043
805:     private var indentGuideColor: UIColor = .separator
806:     private var activeIndentGuideColor: UIColor = .label
807:     private var currentLineHighlightColor: UIColor = .clear
808:     
809:     override init(frame: CGRect, textContainer: NSTextContainer?) {
810:         super.init(frame: frame, textContainer: textContainer)
811:         setup()
812:     }
813:     
814:     required init?(coder: NSCoder) {
815:         super.init(coder: coder)
816:         setup()
817:     }
818:     
819:     private func setup() {
820:         // Ensure we redraw when bounds/selection change




>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift","start_line":120,"end_line":240}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":90,"end_line":180}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":760,"end_line":860}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift (lines 121-240 of 272)
────────────────────────────────────────
121:         }
122:     }
123:     
124:     /// Updates the position of all cursors
125:     func updatePositions(_ transform: (Int) -> Int) {
126:         cursors = cursors.map { cursor in
127:             var updated = cursor
128:             updated.position = transform(cursor.position)
129:             if let anchor = cursor.anchor {
130:                 updated.anchor = transform(anchor)
131:             }
132:             return updated
133:         }
134:     }
135:     
136:     /// Clears all selections but keeps cursors
137:     func clearSelections() {
138:         cursors = cursors.map { cursor in
139:             var updated = cursor
140:             updated.anchor = nil
141:             return updated
142:         }
143:     }
144:     
145:     /// Sort cursors by position
146:     private func sortCursors() {
147:         cursors.sort { $0.position < $1.position }
148:     }
149:     
150:     // MARK: - Text Operations
151:     
152:     /// Insert text at all cursor positions
153:     func insertText(_ text: String, in fullText: inout String) {
154:         // Process cursors from end to start to maintain positions
155:         let sortedCursors = cursors.sorted { $0.position > $1.position }
156:         var offsetAdjustment = 0
157:         
158:         for (index, cursor) in sortedCursors.enumerated() {
159:             let adjustedPosition = cursor.position
160:             
161:             if let selectionRange = cursor.selectionRange,
162:                let swiftRange = Range(selectionRange, in: fullText) {
163:                 // Replace selection
164:                 fullText.replaceSubrange(swiftRange, with: text)
165:                 let delta = text.count - selectionRange.length
166:                 offsetAdjustment += delta
167:                 
168:                 // Update cursor position
169:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
170:                 cursors[cursorIndex].position = selectionRange.location + text.count
171:                 cursors[cursorIndex].anchor = nil
172:             } else {
173:                 // Insert at cursor
174:                 let stringIndex = fullText.index(fullText.startIndex, offsetBy: min(adjustedPosition, fullText.count))
175:                 fullText.insert(contentsOf: text, at: stringIndex)
176:                 
177:                 // Update cursor position
178:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
179:                 cursors[cursorIndex].position = adjustedPosition + text.count
180:             }
181:         }
182:         
183:         // Adjust positions of cursors that come before
184:         adjustCursorPositions(afterInsertion: text.count)
185:     }
186:     
187:     /// Delete text at all cursor positions (backspace)
188:     func deleteBackward(in fullText: inout String) {
189:         let sortedCursors = cursors.sorted { $0.position > $1.position }
190:         
191:         for cursor in sortedCursors {
192:             if let selectionRange = cursor.selectionRange,
193:                let swiftRange = Range(selectionRange, in: fullText) {
194:                 // Delete selection
195:                 fullText.removeSubrange(swiftRange)
196:                 
197:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
198:                 cursors[cursorIndex].position = selectionRange.location
199:                 cursors[cursorIndex].anchor = nil
200:             } else if cursor.position > 0 {
201:                 // Delete character before cursor
202:                 let deleteIndex = fullText.index(fullText.startIndex, offsetBy: cursor.position - 1)
203:                 fullText.remove(at: deleteIndex)
204:                 
205:                 let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
206:                 cursors[cursorIndex].position = cursor.position - 1
207:             }
208:         }
209:         
210:         // Remove duplicate cursors at same position
211:         removeDuplicateCursors()
212:     }
213:     
214:     private func adjustCursorPositions(afterInsertion length: Int) {
215:         // Already handled in insertText
216:     }
217:     
218:     private func removeDuplicateCursors() {
219:         var seen = Set<Int>()
220:         cursors = cursors.filter { cursor in
221:             if seen.contains(cursor.position) {
222:                 return false
223:             }
224:             seen.insert(cursor.position)
225:             return true
226:         }
227:         
228:         // Ensure primary cursor exists
229:         if !cursors.contains(where: { $0.isPrimary }), !cursors.isEmpty {
230:             cursors[0].isPrimary = true
231:         }
232:     }
233: }
234: 
235: // MARK: - Occurrence Finding
236: 
237: extension String {
238:     /// Find all occurrences of a substring
239:     func findAllOccurrences(of searchString: String, caseSensitive: Bool = true) -> [NSRange] {
240:         var ranges: [NSRange] = []

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 91-180 of 2051)
────────────────────────────────────────
91:             currentLineNumber: currentLineNumber,
92:             currentColumn: currentColumn,
93:             cursorIndex: cursorIndex,
94:             lineHeight: lineHeight,
95:             isActive: isActive,
96:             fontSize: editorCore.editorFontSize,
97:             requestedLineSelection: requestedLineSelection,
98:             requestedCursorIndex: requestedCursorIndex,
99:             onAcceptAutocomplete: onAcceptAutocomplete,
100:             onDismissAutocomplete: onDismissAutocomplete
101:         )
102:     }
103: 
104:     func makeCoordinator() -> Coordinator {
105:         Coordinator(self)
106:     }
107:     
108:     func makeUIView(context: Context) -> UITextView {
109:         let textView = EditorTextView()
110:         textView.delegate = context.coordinator
111: 
112:         // Autocomplete hooks
113:         textView.onAcceptAutocomplete = onAcceptAutocomplete
114:         textView.onDismissAutocomplete = onDismissAutocomplete
115: 
116:         textView.onPeekDefinition = {
117:             context.coordinator.handlePeekDefinition(in: textView)
118:         }
119: 
120:         textView.onEscape = {
121:             context.coordinator.handleEscape()
122:         }
123: 
124:         textView.onGoToLine = {
125:             self.editorCore.showGoToLine = true
126:         }
127:         
128:         // Wire up custom context menu actions
129:         textView.onGoToDefinition = {
130:             context.coordinator.handleGoToDefinition(in: textView)
131:         }
132:         
133:         textView.onFindReferences = {
134:             context.coordinator.handleFindReferences(in: textView)
135:         }
136:         
137:         textView.onFormatDocument = {
138:             context.coordinator.handleFormatDocument(in: textView)
139:         }
140:         
141:         textView.onToggleComment = {
142:             context.coordinator.handleToggleComment(in: textView)
143:         }
144:         
145:         textView.onFold = {
146:             context.coordinator.handleFold(in: textView)
147:         }
148:         
149:         textView.onUnfold = {
150:             context.coordinator.handleUnfold(in: textView)
151:         }
152:         
153:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
154:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
155:         pinchGesture.delegate = context.coordinator
156:         textView.addGestureRecognizer(pinchGesture)
157:         context.coordinator.pinchGesture = pinchGesture
158:         
159:         // Configure text view
160:         textView.isEditable = true
161:         textView.isSelectable = true
162:         textView.autocapitalizationType = .none
163:         textView.autocorrectionType = .no
164:         textView.smartDashesType = .no
165:         textView.smartQuotesType = .no
166:         textView.smartInsertDeleteType = .no
167:         textView.spellCheckingType = .no
168:         
169:         // Set font and appearance (use editorCore.editorFontSize)
170:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
171:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
172:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
173:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
174:         textView.keyboardType = .default
175:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
176:         
177:         // Enable line wrapping
178:         textView.textContainer.lineBreakMode = .byCharWrapping
179:         textView.textContainer.widthTracksTextView = true
180:         

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 761-860 of 2051)
────────────────────────────────────────
761:                             break
762:                         } else {
763:                             depth -= 1
764:                         }
765:                     }
766:                     i -= 1
767:                 }
768:             }
769: 
770:             guard let match = matchIndex else { return }
771: 
772:             let r1 = NSRange(location: idx, length: 1)
773:             let r2 = NSRange(location: match, length: 1)
774: 
775:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
776:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
777: 
778:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
779:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
780: 
781:             bracketHighlightRanges = [r1, r2]
782:         }
783:     }
784: }
785: 
786: // Custom text view to handle key commands, indent guides, and line highlighting
787: class EditorTextView: UITextView {
788:     var onPeekDefinition: (() -> Void)?
789:     var onEscape: (() -> Void)?
790:     var onGoToLine: (() -> Void)?
791:     
792:     // Custom action closures for context menu
793:     var onGoToDefinition: (() -> Void)?
794:     var onFindReferences: (() -> Void)?
795:     var onFormatDocument: (() -> Void)?
796:     var onToggleComment: (() -> Void)?
797:     var onFold: (() -> Void)?
798:     var onUnfold: (() -> Void)?
799: 
800:     // Autocomplete key handling hooks (return true if handled)
801:     var onAcceptAutocomplete: (() -> Bool)?
802:     var onDismissAutocomplete: (() -> Bool)?
803:     
804:     // FEAT-039 & FEAT-043
805:     private var indentGuideColor: UIColor = .separator
806:     private var activeIndentGuideColor: UIColor = .label
807:     private var currentLineHighlightColor: UIColor = .clear
808:     
809:     override init(frame: CGRect, textContainer: NSTextContainer?) {
810:         super.init(frame: frame, textContainer: textContainer)
811:         setup()
812:     }
813:     
814:     required init?(coder: NSCoder) {
815:         super.init(coder: coder)
816:         setup()
817:     }
818:     
819:     private func setup() {
820:         // Ensure we redraw when bounds/selection change
821:         contentMode = .redraw
822:     }
823:     
824:     func updateThemeColors(theme: Theme) {
825:         self.indentGuideColor = UIColor(theme.indentGuide)
826:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
827:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
828:         setNeedsDisplay()
829:     }
830:     
831:     override func draw(_ rect: CGRect) {
832:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
833:             super.draw(rect)
834:             return
835:         }
836:         
837:         // 1. Draw Current Line Highlight (FEAT-043)
838:         if let selectedRange = selectedTextRange {
839:             // Get the line rect for the cursor position
840:             let caretRect = self.caretRect(for: selectedRange.start)
841:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
842:             
843:             context.setFillColor(currentLineHighlightColor.cgColor)
844:             context.fill(lineRect)
845:         }
846:         
847:         // 2. Draw Text (super implementation)
848:         super.draw(rect)
849:         
850:         // 3. Draw Indent Guides (FEAT-039)
851:         // We iterate visible lines and draw vertical lines for indentation
852:         // Optimization: Only draw for visible range
853: 
854:         context.setLineWidth(1.0)
855: 
856:         // Respect editor tab size setting (default 4)
857:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
858:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
859: 
860:         let spaceWidth = " ".size(withAttributes: [.font: font]).width


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":140,"end_line":190}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":318,"end_line":360}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":768,"end_line":812}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 141-190 of 2051)
────────────────────────────────────────
141:         textView.onToggleComment = {
142:             context.coordinator.handleToggleComment(in: textView)
143:         }
144:         
145:         textView.onFold = {
146:             context.coordinator.handleFold(in: textView)
147:         }
148:         
149:         textView.onUnfold = {
150:             context.coordinator.handleUnfold(in: textView)
151:         }
152:         
153:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
154:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
155:         pinchGesture.delegate = context.coordinator
156:         textView.addGestureRecognizer(pinchGesture)
157:         context.coordinator.pinchGesture = pinchGesture
158:         
159:         // Configure text view
160:         textView.isEditable = true
161:         textView.isSelectable = true
162:         textView.autocapitalizationType = .none
163:         textView.autocorrectionType = .no
164:         textView.smartDashesType = .no
165:         textView.smartQuotesType = .no
166:         textView.smartInsertDeleteType = .no
167:         textView.spellCheckingType = .no
168:         
169:         // Set font and appearance (use editorCore.editorFontSize)
170:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
171:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
172:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
173:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
174:         textView.keyboardType = .default
175:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
176:         
177:         // Enable line wrapping
178:         textView.textContainer.lineBreakMode = .byCharWrapping
179:         textView.textContainer.widthTracksTextView = true
180:         
181:         // Calculate line height
182:         if let font = textView.font {
183:             DispatchQueue.main.async {
184:                 self.lineHeight = font.lineHeight
185:             }
186:         }
187:         
188:         // Set initial text with syntax highlighting
189:         textView.text = text
190:         context.coordinator.applySyntaxHighlighting(to: textView)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 319-360 of 2051)
────────────────────────────────────────
319:             self.parent = parent
320:         }
321:         
322:         // MARK: - UIGestureRecognizerDelegate
323:         
324:         // Allow pinch gesture to work simultaneously with text selection gestures
325:         func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
326:             // Allow pinch to work alongside native text selection gestures
327:             return true
328:         }
329:         
330:         func textViewDidBeginEditing(_ textView: UITextView) {
331:             // Ensure syntax highlighting is current when user begins editing
332:             // This handles cases where text was set but highlighting hasn't run yet
333:             applySyntaxHighlighting(to: textView)
334:         }
335:         
336:         func textViewDidChange(_ textView: UITextView) {
337:             // Update parent text
338:             parent.text = textView.text
339:             
340:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
341:             // This prevents flicker during the debounce period
342:             let theme = ThemeManager.shared.currentTheme
343:             let fontSize = parent.editorCore.editorFontSize
344:             textView.typingAttributes = [
345:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
346:                 .foregroundColor: UIColor(theme.editorForeground)
347:             ]
348:             
349:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
350:             highlightDebouncer?.invalidate()
351:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
352:                 DispatchQueue.main.async {
353:                     self?.applySyntaxHighlighting(to: textView)
354:                 }
355:             }
356:             
357:             updateLineCount(textView)
358:             updateCursorPosition(textView)
359:         }
360:         

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 769-812 of 2051)
────────────────────────────────────────
769: 
770:             guard let match = matchIndex else { return }
771: 
772:             let r1 = NSRange(location: idx, length: 1)
773:             let r2 = NSRange(location: match, length: 1)
774: 
775:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
776:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
777: 
778:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
779:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
780: 
781:             bracketHighlightRanges = [r1, r2]
782:         }
783:     }
784: }
785: 
786: // Custom text view to handle key commands, indent guides, and line highlighting
787: class EditorTextView: UITextView {
788:     var onPeekDefinition: (() -> Void)?
789:     var onEscape: (() -> Void)?
790:     var onGoToLine: (() -> Void)?
791:     
792:     // Custom action closures for context menu
793:     var onGoToDefinition: (() -> Void)?
794:     var onFindReferences: (() -> Void)?
795:     var onFormatDocument: (() -> Void)?
796:     var onToggleComment: (() -> Void)?
797:     var onFold: (() -> Void)?
798:     var onUnfold: (() -> Void)?
799: 
800:     // Autocomplete key handling hooks (return true if handled)
801:     var onAcceptAutocomplete: (() -> Bool)?
802:     var onDismissAutocomplete: (() -> Bool)?
803:     
804:     // FEAT-039 & FEAT-043
805:     private var indentGuideColor: UIColor = .separator
806:     private var activeIndentGuideColor: UIColor = .label
807:     private var currentLineHighlightColor: UIColor = .clear
808:     
809:     override init(frame: CGRect, textContainer: NSTextContainer?) {
810:         super.init(frame: frame, textContainer: textContainer)
811:         setup()
812:     }


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":780,"end_line":860}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":860,"end_line":940}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 781-860 of 2051)
────────────────────────────────────────
781:             bracketHighlightRanges = [r1, r2]
782:         }
783:     }
784: }
785: 
786: // Custom text view to handle key commands, indent guides, and line highlighting
787: class EditorTextView: UITextView {
788:     var onPeekDefinition: (() -> Void)?
789:     var onEscape: (() -> Void)?
790:     var onGoToLine: (() -> Void)?
791:     
792:     // Custom action closures for context menu
793:     var onGoToDefinition: (() -> Void)?
794:     var onFindReferences: (() -> Void)?
795:     var onFormatDocument: (() -> Void)?
796:     var onToggleComment: (() -> Void)?
797:     var onFold: (() -> Void)?
798:     var onUnfold: (() -> Void)?
799: 
800:     // Autocomplete key handling hooks (return true if handled)
801:     var onAcceptAutocomplete: (() -> Bool)?
802:     var onDismissAutocomplete: (() -> Bool)?
803:     
804:     // FEAT-039 & FEAT-043
805:     private var indentGuideColor: UIColor = .separator
806:     private var activeIndentGuideColor: UIColor = .label
807:     private var currentLineHighlightColor: UIColor = .clear
808:     
809:     override init(frame: CGRect, textContainer: NSTextContainer?) {
810:         super.init(frame: frame, textContainer: textContainer)
811:         setup()
812:     }
813:     
814:     required init?(coder: NSCoder) {
815:         super.init(coder: coder)
816:         setup()
817:     }
818:     
819:     private func setup() {
820:         // Ensure we redraw when bounds/selection change
821:         contentMode = .redraw
822:     }
823:     
824:     func updateThemeColors(theme: Theme) {
825:         self.indentGuideColor = UIColor(theme.indentGuide)
826:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
827:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
828:         setNeedsDisplay()
829:     }
830:     
831:     override func draw(_ rect: CGRect) {
832:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
833:             super.draw(rect)
834:             return
835:         }
836:         
837:         // 1. Draw Current Line Highlight (FEAT-043)
838:         if let selectedRange = selectedTextRange {
839:             // Get the line rect for the cursor position
840:             let caretRect = self.caretRect(for: selectedRange.start)
841:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
842:             
843:             context.setFillColor(currentLineHighlightColor.cgColor)
844:             context.fill(lineRect)
845:         }
846:         
847:         // 2. Draw Text (super implementation)
848:         super.draw(rect)
849:         
850:         // 3. Draw Indent Guides (FEAT-039)
851:         // We iterate visible lines and draw vertical lines for indentation
852:         // Optimization: Only draw for visible range
853: 
854:         context.setLineWidth(1.0)
855: 
856:         // Respect editor tab size setting (default 4)
857:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
858:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
859: 
860:         let spaceWidth = " ".size(withAttributes: [.font: font]).width

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 861-940 of 2051)
────────────────────────────────────────
861:         let indentWidth = spaceWidth * CGFloat(tabSize)
862: 
863:         // Determine active indent level for caret line (for indentGuideActive)
864:         var activeIndentLevel: Int = 0
865:         if let selected = selectedTextRange {
866:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
867:             let nsText = (self.text ?? "") as NSString
868:             let safeLoc = min(max(0, caretPos), nsText.length)
869:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
870:             let caretLineText = nsText.substring(with: caretLineRange)
871: 
872:             var spaces = 0
873:             for ch in caretLineText {
874:                 if ch == " " { spaces += 1 }
875:                 else if ch == "\t" { spaces += tabSize }
876:                 else { break }
877:             }
878:             activeIndentLevel = spaces / tabSize
879:         }
880: 
881:         // Iterate visible glyphs/lines
882:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
883:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
884: 
885:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
886: 
887:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
888:             // Get text for this line
889:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
890:                   let text = self.text as NSString? else { return }
891: 
892:             let lineText = text.substring(with: range)
893: 
894:             // Calculate indentation level
895:             var spaces = 0
896:             for char in lineText {
897:                 if char == " " { spaces += 1 }
898:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
899:                 else { break }
900:             }
901: 
902:             let indentLevel = spaces / tabSize
903:             guard indentLevel > 0 else { return }
904: 
905:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
906: 
907:             for i in 1...indentLevel {
908:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
909:                 let startPoint = CGPoint(x: x, y: rect.minY)
910:                 let endPoint = CGPoint(x: x, y: rect.maxY)
911: 
912:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
913:                 context.setStrokeColor(stroke.cgColor)
914: 
915:                 context.move(to: startPoint)
916:                 context.addLine(to: endPoint)
917:                 context.strokePath()
918:             }
919:         }
920:     }
921:     
922:     override var keyCommands: [UIKeyCommand]? {
923:         var commands = super.keyCommands ?? []
924: 
925:         // Undo / Redo (ensure system shortcuts work even with custom keyCommands)
926:         let undoCmd = UIKeyCommand(
927:             input: "z",
928:             modifierFlags: .command,
929:             action: #selector(handleUndo),
930:             discoverabilityTitle: "Undo"
931:         )
932:         undoCmd.wantsPriorityOverSystemBehavior = true
933:         commands.append(undoCmd)
934: 
935:         let redoCmd = UIKeyCommand(
936:             input: "z",
937:             modifierFlags: [.command, .shift],
938:             action: #selector(handleRedo),
939:             discoverabilityTitle: "Redo"
940:         )


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":350,"end_line":390}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 351-390 of 2051)
────────────────────────────────────────
351:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
352:                 DispatchQueue.main.async {
353:                     self?.applySyntaxHighlighting(to: textView)
354:                 }
355:             }
356:             
357:             updateLineCount(textView)
358:             updateCursorPosition(textView)
359:         }
360:         
361:         func textViewDidChangeSelection(_ textView: UITextView) {
362:             if !isUpdatingFromMinimap {
363:                 updateCursorPosition(textView)
364:                 updateScrollPosition(textView)
365: 
366:                 // FEAT-044: Matching bracket highlight
367:                 updateMatchingBracketHighlight(textView)
368: 
369:                 // Trigger redraw so current-line highlight/indent guides track the caret
370:                 (textView as? EditorTextView)?.setNeedsDisplay()
371: 
372:                 // Update selection in EditorCore for multi-cursor support
373:                 let range = textView.selectedRange
374:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
375: 
376:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
377:                 if !parent.editorCore.multiCursorState.isMultiCursor {
378:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
379:                 }
380:             }
381:         }
382:         
383:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
384:         
385:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
386:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
387:             isUserScrolling = true
388:             userScrollDebouncer?.invalidate()
389:         }
390:         


>>>FILE VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift
>>>FIND
    /// Insert text at all cursor positions
    func insertText(_ text: String, in fullText: inout String) {
        // Process cursors from end to start to maintain positions
        let sortedCursors = cursors.sorted { $0.position > $1.position }
        var offsetAdjustment = 0
        
        for (index, cursor) in sortedCursors.enumerated() {
            let adjustedPosition = cursor.position
            
            if let selectionRange = cursor.selectionRange,
               let swiftRange = Range(selectionRange, in: fullText) {
                // Replace selection
                fullText.replaceSubrange(swiftRange, with: text)
                let delta = text.count - selectionRange.length
                offsetAdjustment += delta
                
                // Update cursor position
                let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
                cursors[cursorIndex].position = selectionRange.location + text.count
                cursors[cursorIndex].anchor = nil
            } else {
                // Insert at cursor
                let stringIndex = fullText.index(fullText.startIndex, offsetBy: min(adjustedPosition, fullText.count))
                fullText.insert(contentsOf: text, at: stringIndex)
                
                // Update cursor position
                let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
                cursors[cursorIndex].position = adjustedPosition + text.count
            }
        }
        
        // Adjust positions of cursors that come before
        adjustCursorPositions(afterInsertion: text.count)
    }
>>>REPLACE
    /// Insert text at all cursor positions
    func insertText(_ text: String, in fullText: inout String) {
        // Process from start -> end while tracking how prior edits shift later cursor positions.
        let sortedCursors = cursors.sorted { $0.position < $1.position }
        var delta = 0

        for cursor in sortedCursors {
            guard let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id }) else { continue }

            if let selectionRange = cursor.selectionRange {
                let effectiveLocation = selectionRange.location + delta
                let effectiveRange = NSRange(location: effectiveLocation, length: selectionRange.length)

                guard let swiftRange = Range(effectiveRange, in: fullText) else { continue }

                fullText.replaceSubrange(swiftRange, with: text)

                // Cursor ends after inserted text; selection cleared.
                cursors[cursorIndex].position = effectiveLocation + text.count
                cursors[cursorIndex].anchor = nil

                delta += (text.count - selectionRange.length)
            } else {
                let effectivePosition = cursor.position + delta
                let clamped = min(max(0, effectivePosition), fullText.count)
                let stringIndex = fullText.index(fullText.startIndex, offsetBy: clamped)

                fullText.insert(contentsOf: text, at: stringIndex)

                cursors[cursorIndex].position = clamped + text.count
                delta += text.count
            }
        }

        // Keep state sane if multiple edits collapse cursors onto the same location.
        removeDuplicateCursors()
    }
>>>END
>>>FILE VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift
>>>FIND
    /// Delete text at all cursor positions (backspace)
    func deleteBackward(in fullText: inout String) {
        let sortedCursors = cursors.sorted { $0.position > $1.position }
        
        for cursor in sortedCursors {
            if let selectionRange = cursor.selectionRange,
               let swiftRange = Range(selectionRange, in: fullText) {
                // Delete selection
                fullText.removeSubrange(swiftRange)
                
                let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
                cursors[cursorIndex].position = selectionRange.location
                cursors[cursorIndex].anchor = nil
            } else if cursor.position > 0 {
                // Delete character before cursor
                let deleteIndex = fullText.index(fullText.startIndex, offsetBy: cursor.position - 1)
                fullText.remove(at: deleteIndex)
                
                let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id })!
                cursors[cursorIndex].position = cursor.position - 1
            }
        }
        
        // Remove duplicate cursors at same position
        removeDuplicateCursors()
    }
>>>REPLACE
    /// Delete text at all cursor positions (backspace)
    func deleteBackward(in fullText: inout String) {
        let sortedCursors = cursors.sorted { $0.position < $1.position }
        var delta = 0

        for cursor in sortedCursors {
            guard let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id }) else { continue }

            if let selectionRange = cursor.selectionRange {
                let effectiveLocation = selectionRange.location + delta
                let effectiveRange = NSRange(location: effectiveLocation, length: selectionRange.length)
                guard let swiftRange = Range(effectiveRange, in: fullText) else { continue }

                fullText.removeSubrange(swiftRange)

                cursors[cursorIndex].position = effectiveLocation
                cursors[cursorIndex].anchor = nil

                delta -= selectionRange.length
            } else {
                let effectivePosition = cursor.position + delta
                guard effectivePosition > 0 else { continue }

                let deleteOffset = effectivePosition - 1
                let deleteIndex = fullText.index(fullText.startIndex, offsetBy: deleteOffset)
                fullText.remove(at: deleteIndex)

                cursors[cursorIndex].position = deleteOffset
                delta -= 1
            }
        }

        removeDuplicateCursors()
    }
>>>END
>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift
>>>FIND
/// Custom UITextView that displays multiple cursors
class MultiCursorTextView: UITextView {
>>>REPLACE
/// Custom UITextView that displays multiple cursors
class MultiCursorTextView: UITextView, UIGestureRecognizerDelegate {
>>>END
>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift
>>>FIND
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupCursorBlinking()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCursorBlinking()
    }
>>>REPLACE
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupCursorBlinking()
        setupOptionClickAddCursor()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCursorBlinking()
        setupOptionClickAddCursor()
    }
>>>END
>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift
>>>FIND
    private func updateCursorVisibility() {
        let alpha: Float = cursorVisible ? 1.0 : 0.0
        cursorLayers.forEach { $0.opacity = alpha }
    }
>>>REPLACE
    private func updateCursorVisibility() {
        let alpha: Float = cursorVisible ? 1.0 : 0.0
        cursorLayers.forEach { $0.opacity = alpha }
    }

    // MARK: - Option+Click (Alt+Click) Add Cursor

    private weak var optionClickTapRecognizer: UITapGestureRecognizer?

    private func setupOptionClickAddCursor() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOptionClickTap(_:)))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
        optionClickTapRecognizer = tap
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === optionClickTapRecognizer {
            // Only handle when Option/Alt is pressed.
            return gestureRecognizer.modifierFlags.contains(.alternate)
        }
        return true
    }

    @objc private func handleOptionClickTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.modifierFlags.contains(.alternate) else { return }
        guard let editorCore = editorCore else { return }

        let point = gestureRecognizer.location(in: self)
        guard let pos = closestPosition(to: point) else { return }

        let offset = self.offset(from: beginningOfDocument, to: pos)

        editorCore.addCursorAtPosition(offset)

        // Make the newly added cursor the UIKit caret too.
        selectedRange = NSRange(location: offset, length: 0)
        delegate?.textViewDidChangeSelection?(self)

        updateCursorDisplay()
    }
>>>END
>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
        let textView = EditorTextView()
        textView.delegate = context.coordinator
>>>REPLACE
        let textView = EditorTextView()
        textView.delegate = context.coordinator
        textView.editorCore = editorCore
>>>END
>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
class EditorTextView: UITextView {
>>>REPLACE
class EditorTextView: MultiCursorTextView {
>>>END
>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
    // Autocomplete key handling hooks (return true if handled)
    var onAcceptAutocomplete: (() -> Bool)?
    var onDismissAutocomplete: (() -> Bool)?
>>>REPLACE
    // Autocomplete key handling hooks are inherited from MultiCursorTextView
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[FILE VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift","start_line":120,"end_line":230}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":1,"end_line":120}
>>>END
>>>TOOL search
{"query":"setupOptionClickAddCursor", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift"}
>>>END
>>>TOOL search
{"query":"editorCore = editorCore", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift (lines 121-230 of 283)
────────────────────────────────────────
121:         }
122:     }
123:     
124:     /// Updates the position of all cursors
125:     func updatePositions(_ transform: (Int) -> Int) {
126:         cursors = cursors.map { cursor in
127:             var updated = cursor
128:             updated.position = transform(cursor.position)
129:             if let anchor = cursor.anchor {
130:                 updated.anchor = transform(anchor)
131:             }
132:             return updated
133:         }
134:     }
135:     
136:     /// Clears all selections but keeps cursors
137:     func clearSelections() {
138:         cursors = cursors.map { cursor in
139:             var updated = cursor
140:             updated.anchor = nil
141:             return updated
142:         }
143:     }
144:     
145:     /// Sort cursors by position
146:     private func sortCursors() {
147:         cursors.sort { $0.position < $1.position }
148:     }
149:     
150:     // MARK: - Text Operations
151:     
152:     /// Insert text at all cursor positions
153:     func insertText(_ text: String, in fullText: inout String) {
154:         // Process from start -> end while tracking how prior edits shift later cursor positions.
155:         let sortedCursors = cursors.sorted { $0.position < $1.position }
156:         var delta = 0
157: 
158:         for cursor in sortedCursors {
159:             guard let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id }) else { continue }
160: 
161:             if let selectionRange = cursor.selectionRange {
162:                 let effectiveLocation = selectionRange.location + delta
163:                 let effectiveRange = NSRange(location: effectiveLocation, length: selectionRange.length)
164: 
165:                 guard let swiftRange = Range(effectiveRange, in: fullText) else { continue }
166: 
167:                 fullText.replaceSubrange(swiftRange, with: text)
168: 
169:                 // Cursor ends after inserted text; selection cleared.
170:                 cursors[cursorIndex].position = effectiveLocation + text.count
171:                 cursors[cursorIndex].anchor = nil
172: 
173:                 delta += (text.count - selectionRange.length)
174:             } else {
175:                 let effectivePosition = cursor.position + delta
176:                 let clamped = min(max(0, effectivePosition), fullText.count)
177:                 let stringIndex = fullText.index(fullText.startIndex, offsetBy: clamped)
178: 
179:                 fullText.insert(contentsOf: text, at: stringIndex)
180: 
181:                 cursors[cursorIndex].position = clamped + text.count
182:                 delta += text.count
183:             }
184:         }
185: 
186:         // Keep state sane if multiple edits collapse cursors onto the same location.
187:         removeDuplicateCursors()
188:     }
189:     
190:     /// Delete text at all cursor positions (backspace)
191:     func deleteBackward(in fullText: inout String) {
192:         let sortedCursors = cursors.sorted { $0.position < $1.position }
193:         var delta = 0
194: 
195:         for cursor in sortedCursors {
196:             guard let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id }) else { continue }
197: 
198:             if let selectionRange = cursor.selectionRange {
199:                 let effectiveLocation = selectionRange.location + delta
200:                 let effectiveRange = NSRange(location: effectiveLocation, length: selectionRange.length)
201:                 guard let swiftRange = Range(effectiveRange, in: fullText) else { continue }
202: 
203:                 fullText.removeSubrange(swiftRange)
204: 
205:                 cursors[cursorIndex].position = effectiveLocation
206:                 cursors[cursorIndex].anchor = nil
207: 
208:                 delta -= selectionRange.length
209:             } else {
210:                 let effectivePosition = cursor.position + delta
211:                 guard effectivePosition > 0 else { continue }
212: 
213:                 let deleteOffset = effectivePosition - 1
214:                 let deleteIndex = fullText.index(fullText.startIndex, offsetBy: deleteOffset)
215:                 fullText.remove(at: deleteIndex)
216: 
217:                 cursors[cursorIndex].position = deleteOffset
218:                 delta -= 1
219:             }
220:         }
221: 
222:         removeDuplicateCursors()
223:     }
224:     
225:     private func adjustCursorPositions(afterInsertion length: Int) {
226:         // Already handled in insertText
227:     }
228:     
229:     private func removeDuplicateCursors() {
230:         var seen = Set<Int>()

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 2-120 of 320)
────────────────────────────────────────
2: //  VSCodeiPadOS
3: //
4: //  Custom UITextView subclass that supports multiple cursor display
5: //
6: 
7: import UIKit
8: import SwiftUI
9: 
10: /// Custom UITextView that displays multiple cursors
11: class MultiCursorTextView: UITextView, UIGestureRecognizerDelegate {
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
40:         setupOptionClickAddCursor()
41:     }
42: 
43:     required init?(coder: NSCoder) {
44:         super.init(coder: coder)
45:         setupCursorBlinking()
46:         setupOptionClickAddCursor()
47:     }
48: 
49:     deinit {
50:         blinkTimer?.invalidate()
51:     }
52: 
53:     private func setupCursorBlinking() {
54:         blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
55:             self?.cursorVisible.toggle()
56:             self?.updateCursorVisibility()
57:         }
58:     }
59: 
60:     private func updateCursorVisibility() {
61:         let alpha: Float = cursorVisible ? 1.0 : 0.0
62:         cursorLayers.forEach { $0.opacity = alpha }
63:     }
64: 
65:     // MARK: - Option+Click (Alt+Click) Add Cursor
66: 
67:     private weak var optionClickTapRecognizer: UITapGestureRecognizer?
68: 
69:     private func setupOptionClickAddCursor() {
70:         let tap = UITapGestureRecognizer(target: self, action: #selector(handleOptionClickTap(_:)))
71:         tap.delegate = self
72:         tap.cancelsTouchesInView = false
73:         addGestureRecognizer(tap)
74:         optionClickTapRecognizer = tap
75:     }
76: 
77:     func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
78:         if gestureRecognizer === optionClickTapRecognizer {
79:             // Only handle when Option/Alt is pressed.
80:             return gestureRecognizer.modifierFlags.contains(.alternate)
81:         }
82:         return true
83:     }
84: 
85:     @objc private func handleOptionClickTap(_ gestureRecognizer: UITapGestureRecognizer) {
86:         guard gestureRecognizer.modifierFlags.contains(.alternate) else { return }
87:         guard let editorCore = editorCore else { return }
88: 
89:         let point = gestureRecognizer.location(in: self)
90:         guard let pos = closestPosition(to: point) else { return }
91: 
92:         let offset = self.offset(from: beginningOfDocument, to: pos)
93: 
94:         editorCore.addCursorAtPosition(offset)
95: 
96:         // Make the newly added cursor the UIKit caret too.
97:         selectedRange = NSRange(location: offset, length: 0)
98:         delegate?.textViewDidChangeSelection?(self)
99: 
100:         updateCursorDisplay()
101:     }
102: 
103:     /// Updates the display of all cursors and selections
104:     func updateCursorDisplay() {
105:         // Remove existing cursor and selection layers
106:         cursorLayers.forEach { $0.removeFromSuperlayer() }
107:         cursorLayers.removeAll()
108:         selectionLayers.forEach { $0.removeFromSuperlayer() }
109:         selectionLayers.removeAll()
110: 
111:         guard let editorCore = editorCore else { return }
112:         let cursors = editorCore.multiCursorState.cursors
113: 
114:         // Only show additional cursors if we have multiple
115:         guard cursors.count > 1 else { return }
116: 
117:         // Draw each cursor (skip the primary one as UITextView handles it)
118:         for (index, cursor) in cursors.enumerated() {
119:             // Primary selection is handled by UITextView.selectedRange; only draw additional selections.
120:             if !cursor.isPrimary, let selectionRange = cursor.selectionRange {

---

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:40: setupOptionClickAddCursor()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:46: setupOptionClickAddCursor()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:69: private func setupOptionClickAddCursor() {

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:111: textView.editorCore = editorCore


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":770,"end_line":1120}
>>>END
>>>TOOL search
{"query":"onAcceptAutocomplete", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"onDismissAutocomplete", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 771-1120 of 2050)
────────────────────────────────────────
771:             guard let match = matchIndex else { return }
772: 
773:             let r1 = NSRange(location: idx, length: 1)
774:             let r2 = NSRange(location: match, length: 1)
775: 
776:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
777:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
778: 
779:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
780:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
781: 
782:             bracketHighlightRanges = [r1, r2]
783:         }
784:     }
785: }
786: 
787: // Custom text view to handle key commands, indent guides, and line highlighting
788: class EditorTextView: MultiCursorTextView {
789:     var onPeekDefinition: (() -> Void)?
790:     var onEscape: (() -> Void)?
791:     var onGoToLine: (() -> Void)?
792:     
793:     // Custom action closures for context menu
794:     var onGoToDefinition: (() -> Void)?
795:     var onFindReferences: (() -> Void)?
796:     var onFormatDocument: (() -> Void)?
797:     var onToggleComment: (() -> Void)?
798:     var onFold: (() -> Void)?
799:     var onUnfold: (() -> Void)?
800: 
801:     // Autocomplete key handling hooks are inherited from MultiCursorTextView
802:     
803:     // FEAT-039 & FEAT-043
804:     private var indentGuideColor: UIColor = .separator
805:     private var activeIndentGuideColor: UIColor = .label
806:     private var currentLineHighlightColor: UIColor = .clear
807:     
808:     override init(frame: CGRect, textContainer: NSTextContainer?) {
809:         super.init(frame: frame, textContainer: textContainer)
810:         setup()
811:     }
812:     
813:     required init?(coder: NSCoder) {
814:         super.init(coder: coder)
815:         setup()
816:     }
817:     
818:     private func setup() {
819:         // Ensure we redraw when bounds/selection change
820:         contentMode = .redraw
821:     }
822:     
823:     func updateThemeColors(theme: Theme) {
824:         self.indentGuideColor = UIColor(theme.indentGuide)
825:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
826:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
827:         setNeedsDisplay()
828:     }
829:     
830:     override func draw(_ rect: CGRect) {
831:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
832:             super.draw(rect)
833:             return
834:         }
835:         
836:         // 1. Draw Current Line Highlight (FEAT-043)
837:         if let selectedRange = selectedTextRange {
838:             // Get the line rect for the cursor position
839:             let caretRect = self.caretRect(for: selectedRange.start)
840:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
841:             
842:             context.setFillColor(currentLineHighlightColor.cgColor)
843:             context.fill(lineRect)
844:         }
845:         
846:         // 2. Draw Text (super implementation)
847:         super.draw(rect)
848:         
849:         // 3. Draw Indent Guides (FEAT-039)
850:         // We iterate visible lines and draw vertical lines for indentation
851:         // Optimization: Only draw for visible range
852: 
853:         context.setLineWidth(1.0)
854: 
855:         // Respect editor tab size setting (default 4)
856:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
857:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
858: 
859:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
860:         let indentWidth = spaceWidth * CGFloat(tabSize)
861: 
862:         // Determine active indent level for caret line (for indentGuideActive)
863:         var activeIndentLevel: Int = 0
864:         if let selected = selectedTextRange {
865:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
866:             let nsText = (self.text ?? "") as NSString
867:             let safeLoc = min(max(0, caretPos), nsText.length)
868:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
869:             let caretLineText = nsText.substring(with: caretLineRange)
870: 
871:             var spaces = 0
872:             for ch in caretLineText {
873:                 if ch == " " { spaces += 1 }
874:                 else if ch == "\t" { spaces += tabSize }
875:                 else { break }
876:             }
877:             activeIndentLevel = spaces / tabSize
878:         }
879: 
880:         // Iterate visible glyphs/lines
881:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
882:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
883: 
884:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
885: 
886:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
887:             // Get text for this line
888:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
889:                   let text = self.text as NSString? else { return }
890: 
891:             let lineText = text.substring(with: range)
892: 
893:             // Calculate indentation level
894:             var spaces = 0
895:             for char in lineText {
896:                 if char == " " { spaces += 1 }
897:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
898:                 else { break }
899:             }
900: 
901:             let indentLevel = spaces / tabSize
902:             guard indentLevel > 0 else { return }
903: 
904:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
905: 
906:             for i in 1...indentLevel {
907:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
908:                 let startPoint = CGPoint(x: x, y: rect.minY)
909:                 let endPoint = CGPoint(x: x, y: rect.maxY)
910: 
911:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
912:                 context.setStrokeColor(stroke.cgColor)
913: 
914:                 context.move(to: startPoint)
915:                 context.addLine(to: endPoint)
916:                 context.strokePath()
917:             }
918:         }
919:     }
920:     
921:     override var keyCommands: [UIKeyCommand]? {
922:         var commands = super.keyCommands ?? []
923: 
924:         // Undo / Redo (ensure system shortcuts work even with custom keyCommands)
925:         let undoCmd = UIKeyCommand(
926:             input: "z",
927:             modifierFlags: .command,
928:             action: #selector(handleUndo),
929:             discoverabilityTitle: "Undo"
930:         )
931:         undoCmd.wantsPriorityOverSystemBehavior = true
932:         commands.append(undoCmd)
933: 
934:         let redoCmd = UIKeyCommand(
935:             input: "z",
936:             modifierFlags: [.command, .shift],
937:             action: #selector(handleRedo),
938:             discoverabilityTitle: "Redo"
939:         )
940:         redoCmd.wantsPriorityOverSystemBehavior = true
941:         commands.append(redoCmd)
942:         
943:         // Peek Definition: Alt+F12 (using special key input)
944:         // Note: F12 is not directly available on iPadOS keyboards
945:         // Using Option+D as alternative
946:         commands.append(UIKeyCommand(
947:             input: "d",
948:             modifierFlags: .alternate,
949:             action: #selector(handlePeekDefinition)
950:         ))
951: 
952:         // Go to Line: Cmd+G
953:         commands.append(UIKeyCommand(
954:             input: "g",
955:             modifierFlags: .command,
956:             action: #selector(handleGoToLine)
957:         ))
958: 
959:         // Tab: accept autocomplete if visible, else insert tab
960:         commands.append(UIKeyCommand(
961:             input: "\t",
962:             modifierFlags: [],
963:             action: #selector(handleTab)
964:         ))
965:         
966:         // Escape: dismiss autocomplete if visible, else normal escape behavior
967:         commands.append(UIKeyCommand(
968:             input: UIKeyCommand.inputEscape,
969:             modifierFlags: [],
970:             action: #selector(handleEscape)
971:         ))
972:         
973:         // Fold: Cmd+Opt+[
974:         commands.append(UIKeyCommand(
975:             input: "[",
976:             modifierFlags: [.command, .alternate],
977:             action: #selector(handleFold)
978:         ))
979:         
980:         // Unfold: Cmd+Opt+]
981:         commands.append(UIKeyCommand(
982:             input: "]",
983:             modifierFlags: [.command, .alternate],
984:             action: #selector(handleUnfold)
985:         ))
986:         
987:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
988:         // These post to NotificationCenter so ContentView can handle them
989:         
990:         // Command Palette: Cmd+Shift+P
991:         commands.append(UIKeyCommand(
992:             input: "p",
993:             modifierFlags: [.command, .shift],
994:             action: #selector(handleShowCommandPalette),
995:             discoverabilityTitle: "Command Palette"
996:         ))
997:         
998:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
999:         let toggleTerminalCmd = UIKeyCommand(
1000:             input: "j",
1001:             modifierFlags: .command,
1002:             action: #selector(handleToggleTerminal),
1003:             discoverabilityTitle: "Toggle Terminal"
1004:         )
1005:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
1006:         commands.append(toggleTerminalCmd)
1007:         
1008:         // AI Assistant: Cmd+Shift+A
1009:         commands.append(UIKeyCommand(
1010:             input: "a",
1011:             modifierFlags: [.command, .shift],
1012:             action: #selector(handleShowAIAssistant),
1013:             discoverabilityTitle: "AI Assistant"
1014:         ))
1015:         
1016:         // Toggle Sidebar: Cmd+B
1017:         commands.append(UIKeyCommand(
1018:             input: "b",
1019:             modifierFlags: .command,
1020:             action: #selector(handleToggleSidebar),
1021:             discoverabilityTitle: "Toggle Sidebar"
1022:         ))
1023:         
1024:         // Quick Open: Cmd+P
1025:         commands.append(UIKeyCommand(
1026:             input: "p",
1027:             modifierFlags: .command,
1028:             action: #selector(handleShowQuickOpen),
1029:             discoverabilityTitle: "Quick Open"
1030:         ))
1031:         
1032:         // New File: Cmd+N
1033:         let newFileCmd = UIKeyCommand(
1034:             input: "n",
1035:             modifierFlags: .command,
1036:             action: #selector(handleNewFile),
1037:             discoverabilityTitle: "New File"
1038:         )
1039:         newFileCmd.wantsPriorityOverSystemBehavior = true
1040:         commands.append(newFileCmd)
1041:         
1042:         // Save: Cmd+S
1043:         commands.append(UIKeyCommand(
1044:             input: "s",
1045:             modifierFlags: .command,
1046:             action: #selector(handleSaveFile),
1047:             discoverabilityTitle: "Save"
1048:         ))
1049:         
1050:         // Close Tab: Cmd+W
1051:         let closeTabCmd = UIKeyCommand(
1052:             input: "w",
1053:             modifierFlags: .command,
1054:             action: #selector(handleCloseTab),
1055:             discoverabilityTitle: "Close Tab"
1056:         )
1057:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1058:         commands.append(closeTabCmd)
1059:         
1060:         // Find: Cmd+F
1061:         let findCmd = UIKeyCommand(
1062:             input: "f",
1063:             modifierFlags: .command,
1064:             action: #selector(handleFind),
1065:             discoverabilityTitle: "Find"
1066:         )
1067:         findCmd.wantsPriorityOverSystemBehavior = true
1068:         commands.append(findCmd)
1069:         
1070:         // Zoom In: Cmd+=
1071:         commands.append(UIKeyCommand(
1072:             input: "=",
1073:             modifierFlags: .command,
1074:             action: #selector(handleZoomIn),
1075:             discoverabilityTitle: "Zoom In"
1076:         ))
1077:         
1078:         // Zoom Out: Cmd+-
1079:         commands.append(UIKeyCommand(
1080:             input: "-",
1081:             modifierFlags: .command,
1082:             action: #selector(handleZoomOut),
1083:             discoverabilityTitle: "Zoom Out"
1084:         ))
1085:         
1086:         return commands
1087:     }
1088:     
1089:     @objc func handlePeekDefinition() {
1090:         onPeekDefinition?()
1091:     }
1092: 
1093:     @objc func handleGoToLine() {
1094:         onGoToLine?()
1095:     }
1096: 
1097:     @objc func handleTab() {
1098:         if onAcceptAutocomplete?() == true {
1099:             return
1100:         }
1101:         insertText("\t")
1102:     }
1103:     
1104:     @objc func handleEscape() {
1105:         if onDismissAutocomplete?() == true {
1106:             return
1107:         }
1108:         onEscape?()
1109:     }
1110:     
1111:     @objc func handleFold() {
1112:         onFold?()
1113:     }
1114:     
1115:     @objc func handleUnfold() {
1116:         onUnfold?()
1117:     }
1118: 
1119:     // MARK: - Undo / Redo
1120: 

---

[search]
Found 7 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:26: let onAcceptAutocomplete: (() -> Bool)?
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:47: onAcceptAutocomplete: (() -> Bool)? = nil,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:63: self.onAcceptAutocomplete = onAcceptAutocomplete
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:82: onAcceptAutocomplete: (() -> Bool)? = nil,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:99: onAcceptAutocomplete: onAcceptAutocomplete,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:114: textView.onAcceptAutocomplete = onAcceptAutocomplete
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1098: if onAcceptAutocomplete?() == true {

---

[search]
Found 7 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:27: let onDismissAutocomplete: (() -> Bool)?
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:48: onDismissAutocomplete: (() -> Bool)? = nil
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:64: self.onDismissAutocomplete = onDismissAutocomplete
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:83: onDismissAutocomplete: (() -> Bool)? = nil
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:100: onDismissAutocomplete: onDismissAutocomplete
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:115: textView.onDismissAutocomplete = onDismissAutocomplete
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1105: if onDismissAutocomplete?() == true {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":108,"end_line":130}
>>>END
>>>TOOL search
{"query":"func handleEscape()", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":520,"end_line":555}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 109-130 of 2050)
────────────────────────────────────────
109:         let textView = EditorTextView()
110:         textView.delegate = context.coordinator
111:         textView.editorCore = editorCore
112: 
113:         // Autocomplete hooks
114:         textView.onAcceptAutocomplete = onAcceptAutocomplete
115:         textView.onDismissAutocomplete = onDismissAutocomplete
116: 
117:         textView.onPeekDefinition = {
118:             context.coordinator.handlePeekDefinition(in: textView)
119:         }
120: 
121:         textView.onEscape = {
122:             context.coordinator.handleEscape()
123:         }
124: 
125:         textView.onGoToLine = {
126:             self.editorCore.showGoToLine = true
127:         }
128:         
129:         // Wire up custom context menu actions
130:         textView.onGoToDefinition = {

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:565: func handleEscape() {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1104: @objc func handleEscape() {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 521-555 of 2050)
────────────────────────────────────────
521: 
522:             // NOTE: Setting `attributedText` repeatedly for syntax highlighting can interfere with
523:             // UITextView's built-in Undo/Redo stack (Cmd+Z / Cmd+Shift+Z).
524:             // We explicitly disable undo registration around the styling pass so only user edits
525:             // participate in undo/redo.
526:             let um = textView.undoManager
527:             let wasUndoEnabled = um?.isUndoRegistrationEnabled ?? true
528:             if wasUndoEnabled { um?.disableUndoRegistration() }
529:             textView.attributedText = attributedText
530:             if wasUndoEnabled { um?.enableUndoRegistration() }
531: 
532:             textView.selectedRange = selectedRange
533: 
534:             // Set typing attributes so newly typed characters have correct base styling
535:             // This prevents flicker during the debounce period before full highlighting runs
536:             let fontSize = parent.editorCore.editorFontSize
537:             textView.typingAttributes = [
538:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
539:                 .foregroundColor: UIColor(theme.editorForeground)
540:             ]
541: 
542:             // FEAT-044: restore matching bracket highlight after re-attributing text
543:             updateMatchingBracketHighlight(textView)
544:         }
545:         
546:         func handlePeekDefinition(in textView: UITextView) {
547:             guard let selectedRange = textView.selectedTextRange else { return }
548:             let text = textView.text ?? ""
549:             
550:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
551:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
552:                  
553:                  let prefix = String(text.prefix(location))
554:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
555:                  


>>>TOOL search
{"query":"tabAcceptAutocomplete", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"escapeKeyPressed", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"@objc private func goToLine", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":200,"end_line":340}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:268: @objc private func tabAcceptAutocomplete() {

---

[search]
No matches found for "escapeKeyPressed"

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:308: @objc private func goToLine() {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 201-320 of 320)
────────────────────────────────────────
201:         guard let editorCore = editorCore,
202:               editorCore.multiCursorState.isMultiCursor else {
203:             super.deleteBackward()
204:             return
205:         }
206: 
207:         // Handle multi-cursor delete
208:         var content = self.text ?? ""
209:         editorCore.multiCursorState.deleteBackward(in: &content)
210: 
211:         // Update text view
212:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
213:         self.text = content
214: 
215:         // Position the main cursor
216:         if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
217:             selectedTextRange = textRange(from: newPosition, to: newPosition)
218:         }
219: 
220:         // Trigger text change notification
221:         delegate?.textViewDidChange?(self)
222: 
223:         updateCursorDisplay()
224:     }
225: 
226:     // MARK: - Layout Updates
227: 
228:     override func layoutSubviews() {
229:         super.layoutSubviews()
230:         // Refresh cursor positions when layout changes
231:         updateCursorDisplay()
232:     }
233: 
234:     override var contentOffset: CGPoint {
235:         didSet {
236:             // Update cursor positions when scrolling
237:             updateCursorDisplay()
238:         }
239:     }
240: }
241: 
242: // MARK: - Key Commands for Multi-Cursor + Autocomplete
243: 
244: extension MultiCursorTextView {
245: 
246:     override var keyCommands: [UIKeyCommand]? {
247:         var commands = super.keyCommands ?? []
248: 
249:         // Cmd+D: Add next occurrence
250:         commands.append(UIKeyCommand(
251:             title: "Add Next Occurrence",
252:             action: #selector(addNextOccurrence),
253:             input: "d",
254:             modifierFlags: .command
255:         ))
256: 
257:         // Cmd+Shift+L: Select all occurrences
258:         commands.append(UIKeyCommand(
259:             title: "Select All Occurrences",
260:             action: #selector(selectAllOccurrences),
261:             input: "l",
262:             modifierFlags: [.command, .shift]
263:         ))
264: 
265:         return commands
266:     }
267: 
268:     @objc private func tabAcceptAutocomplete() {
269:         if onAcceptAutocomplete?() == true {
270:             return
271:         }
272:         insertText("\t")
273:     }
274: 
275:     @objc private func addNextOccurrence() {
276:         guard let editorCore = editorCore else { return }
277:         editorCore.addNextOccurrence()
278: 
279:         // Sync UIKit selection with the primary multi-cursor selection so typing replaces the selection.
280:         if let primary = editorCore.multiCursorState.primaryCursor {
281:             if let selection = primary.selectionRange {
282:                 selectedRange = selection
283:             } else {
284:                 selectedRange = NSRange(location: primary.position, length: 0)
285:             }
286:             delegate?.textViewDidChangeSelection?(self)
287:         }
288: 
289:         updateCursorDisplay()
290:     }
291: 
292:     @objc private func selectAllOccurrences() {
293:         guard let editorCore = editorCore else { return }
294:         editorCore.selectAllOccurrences()
295: 
296:         if let primary = editorCore.multiCursorState.primaryCursor {
297:             if let selection = primary.selectionRange {
298:                 selectedRange = selection
299:             } else {
300:                 selectedRange = NSRange(location: primary.position, length: 0)
301:             }
302:             delegate?.textViewDidChangeSelection?(self)
303:         }
304: 
305:         updateCursorDisplay()
306:     }
307: 
308:     @objc private func goToLine() {
309:         editorCore?.showGoToLine = true
310:     }
311: 
312:     @objc private func escapeKeyPressed() {
313:         if onDismissAutocomplete?() == true {
314:             return
315:         }
316:         editorCore?.escapeMultiCursor()
317:         updateCursorDisplay()
318:     }
319: }
320: 


>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
                // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
                if !parent.editorCore.multiCursorState.isMultiCursor {
                    parent.editorCore.multiCursorState.reset(to: range.location + range.length)
                }
>>>REPLACE
                // Keep EditorCore.multiCursorState in sync with UIKit selection.
                // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
                // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
                if !parent.editorCore.multiCursorState.isMultiCursor {
                    if range.length > 0 {
                        parent.editorCore.multiCursorState.cursors = [
                            Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)
                        ]
                    } else {
                        parent.editorCore.multiCursorState.reset(to: range.location)
                    }
                }
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":350,"end_line":390}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 351-390 of 2050)
────────────────────────────────────────
351:             highlightDebouncer?.invalidate()
352:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
353:                 DispatchQueue.main.async {
354:                     self?.applySyntaxHighlighting(to: textView)
355:                 }
356:             }
357:             
358:             updateLineCount(textView)
359:             updateCursorPosition(textView)
360:         }
361:         
362:         func textViewDidChangeSelection(_ textView: UITextView) {
363:             if !isUpdatingFromMinimap {
364:                 updateCursorPosition(textView)
365:                 updateScrollPosition(textView)
366: 
367:                 // FEAT-044: Matching bracket highlight
368:                 updateMatchingBracketHighlight(textView)
369: 
370:                 // Trigger redraw so current-line highlight/indent guides track the caret
371:                 (textView as? EditorTextView)?.setNeedsDisplay()
372: 
373:                 // Update selection in EditorCore for multi-cursor support
374:                 let range = textView.selectedRange
375:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
376: 
377:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
378:                 if !parent.editorCore.multiCursorState.isMultiCursor {
379:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
380:                 }
381:             }
382:         }
383:         
384:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
385:         
386:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
387:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
388:             isUserScrolling = true
389:             userScrollDebouncer?.invalidate()
390:         }

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":110,"end_line":360}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":780,"end_line":840}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 111-320 of 320)
────────────────────────────────────────
111:         guard let editorCore = editorCore else { return }
112:         let cursors = editorCore.multiCursorState.cursors
113: 
114:         // Only show additional cursors if we have multiple
115:         guard cursors.count > 1 else { return }
116: 
117:         // Draw each cursor (skip the primary one as UITextView handles it)
118:         for (index, cursor) in cursors.enumerated() {
119:             // Primary selection is handled by UITextView.selectedRange; only draw additional selections.
120:             if !cursor.isPrimary, let selectionRange = cursor.selectionRange {
121:                 drawSelection(for: selectionRange, isPrimary: false, index: index)
122:             }
123: 
124:             // Draw cursor line (skip primary cursor as system handles it)
125:             if !cursor.isPrimary {
126:                 drawCursor(at: cursor.position, isPrimary: false, index: index)
127:             }
128:         }
129:     }
130: 
131:     private func drawCursor(at position: Int, isPrimary: Bool, index: Int) {
132:         guard let textPosition = self.position(from: beginningOfDocument, offset: position) else { return }
133: 
134:         let caretRect = self.caretRect(for: textPosition)
135: 
136:         let cursorLayer = CALayer()
137:         cursorLayer.backgroundColor = (isPrimary ? cursorColor : secondaryCursorColor).cgColor
138:         cursorLayer.frame = CGRect(
139:             x: caretRect.origin.x,
140:             y: caretRect.origin.y,
141:             width: cursorWidth,
142:             height: caretRect.height
143:         )
144:         cursorLayer.cornerRadius = 1
145: 
146:         layer.addSublayer(cursorLayer)
147:         cursorLayers.append(cursorLayer)
148:     }
149: 
150:     private func drawSelection(for range: NSRange, isPrimary: Bool, index: Int) {
151:         guard let start = position(from: beginningOfDocument, offset: range.location),
152:               let end = position(from: beginningOfDocument, offset: range.location + range.length),
153:               let textRange = self.textRange(from: start, to: end) else { return }
154: 
155:         let selectionRects = selectionRects(for: textRange)
156: 
157:         for rect in selectionRects {
158:             let selectionLayer = CALayer()
159:             selectionLayer.backgroundColor = (isPrimary ? selectionColor : secondarySelectionColor).cgColor
160:             selectionLayer.frame = rect.rect
161: 
162:             // Insert behind text
163:             if let textLayer = layer.sublayers?.first {
164:                 layer.insertSublayer(selectionLayer, below: textLayer)
165:             } else {
166:                 layer.addSublayer(selectionLayer)
167:             }
168:             selectionLayers.append(selectionLayer)
169:         }
170:     }
171: 
172:     // MARK: - Text Input Handling for Multi-Cursor
173: 
174:     override func insertText(_ text: String) {
175:         guard let editorCore = editorCore,
176:               editorCore.multiCursorState.isMultiCursor else {
177:             super.insertText(text)
178:             return
179:         }
180: 
181:         // Handle multi-cursor insert
182:         var content = self.text ?? ""
183:         editorCore.multiCursorState.insertText(text, in: &content)
184: 
185:         // Update text view
186:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
187:         self.text = content
188: 
189:         // Position the main cursor
190:         if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
191:             selectedTextRange = textRange(from: newPosition, to: newPosition)
192:         }
193: 
194:         // Trigger text change notification
195:         delegate?.textViewDidChange?(self)
196: 
197:         updateCursorDisplay()
198:     }
199: 
200:     override func deleteBackward() {
201:         guard let editorCore = editorCore,
202:               editorCore.multiCursorState.isMultiCursor else {
203:             super.deleteBackward()
204:             return
205:         }
206: 
207:         // Handle multi-cursor delete
208:         var content = self.text ?? ""
209:         editorCore.multiCursorState.deleteBackward(in: &content)
210: 
211:         // Update text view
212:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
213:         self.text = content
214: 
215:         // Position the main cursor
216:         if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
217:             selectedTextRange = textRange(from: newPosition, to: newPosition)
218:         }
219: 
220:         // Trigger text change notification
221:         delegate?.textViewDidChange?(self)
222: 
223:         updateCursorDisplay()
224:     }
225: 
226:     // MARK: - Layout Updates
227: 
228:     override func layoutSubviews() {
229:         super.layoutSubviews()
230:         // Refresh cursor positions when layout changes
231:         updateCursorDisplay()
232:     }
233: 
234:     override var contentOffset: CGPoint {
235:         didSet {
236:             // Update cursor positions when scrolling
237:             updateCursorDisplay()
238:         }
239:     }
240: }
241: 
242: // MARK: - Key Commands for Multi-Cursor + Autocomplete
243: 
244: extension MultiCursorTextView {
245: 
246:     override var keyCommands: [UIKeyCommand]? {
247:         var commands = super.keyCommands ?? []
248: 
249:         // Cmd+D: Add next occurrence
250:         commands.append(UIKeyCommand(
251:             title: "Add Next Occurrence",
252:             action: #selector(addNextOccurrence),
253:             input: "d",
254:             modifierFlags: .command
255:         ))
256: 
257:         // Cmd+Shift+L: Select all occurrences
258:         commands.append(UIKeyCommand(
259:             title: "Select All Occurrences",
260:             action: #selector(selectAllOccurrences),
261:             input: "l",
262:             modifierFlags: [.command, .shift]
263:         ))
264: 
265:         return commands
266:     }
267: 
268:     @objc private func tabAcceptAutocomplete() {
269:         if onAcceptAutocomplete?() == true {
270:             return
271:         }
272:         insertText("\t")
273:     }
274: 
275:     @objc private func addNextOccurrence() {
276:         guard let editorCore = editorCore else { return }
277:         editorCore.addNextOccurrence()
278: 
279:         // Sync UIKit selection with the primary multi-cursor selection so typing replaces the selection.
280:         if let primary = editorCore.multiCursorState.primaryCursor {
281:             if let selection = primary.selectionRange {
282:                 selectedRange = selection
283:             } else {
284:                 selectedRange = NSRange(location: primary.position, length: 0)
285:             }
286:             delegate?.textViewDidChangeSelection?(self)
287:         }
288: 
289:         updateCursorDisplay()
290:     }
291: 
292:     @objc private func selectAllOccurrences() {
293:         guard let editorCore = editorCore else { return }
294:         editorCore.selectAllOccurrences()
295: 
296:         if let primary = editorCore.multiCursorState.primaryCursor {
297:             if let selection = primary.selectionRange {
298:                 selectedRange = selection
299:             } else {
300:                 selectedRange = NSRange(location: primary.position, length: 0)
301:             }
302:             delegate?.textViewDidChangeSelection?(self)
303:         }
304: 
305:         updateCursorDisplay()
306:     }
307: 
308:     @objc private func goToLine() {
309:         editorCore?.showGoToLine = true
310:     }
311: 
312:     @objc private func escapeKeyPressed() {
313:         if onDismissAutocomplete?() == true {
314:             return
315:         }
316:         editorCore?.escapeMultiCursor()
317:         updateCursorDisplay()
318:     }
319: }
320: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 781-840 of 2058)
────────────────────────────────────────
781:             let r1 = NSRange(location: idx, length: 1)
782:             let r2 = NSRange(location: match, length: 1)
783: 
784:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
785:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
786: 
787:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
788:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
789: 
790:             bracketHighlightRanges = [r1, r2]
791:         }
792:     }
793: }
794: 
795: // Custom text view to handle key commands, indent guides, and line highlighting
796: class EditorTextView: MultiCursorTextView {
797:     var onPeekDefinition: (() -> Void)?
798:     var onEscape: (() -> Void)?
799:     var onGoToLine: (() -> Void)?
800:     
801:     // Custom action closures for context menu
802:     var onGoToDefinition: (() -> Void)?
803:     var onFindReferences: (() -> Void)?
804:     var onFormatDocument: (() -> Void)?
805:     var onToggleComment: (() -> Void)?
806:     var onFold: (() -> Void)?
807:     var onUnfold: (() -> Void)?
808: 
809:     // Autocomplete key handling hooks are inherited from MultiCursorTextView
810:     
811:     // FEAT-039 & FEAT-043
812:     private var indentGuideColor: UIColor = .separator
813:     private var activeIndentGuideColor: UIColor = .label
814:     private var currentLineHighlightColor: UIColor = .clear
815:     
816:     override init(frame: CGRect, textContainer: NSTextContainer?) {
817:         super.init(frame: frame, textContainer: textContainer)
818:         setup()
819:     }
820:     
821:     required init?(coder: NSCoder) {
822:         super.init(coder: coder)
823:         setup()
824:     }
825:     
826:     private func setup() {
827:         // Ensure we redraw when bounds/selection change
828:         contentMode = .redraw
829:     }
830:     
831:     func updateThemeColors(theme: Theme) {
832:         self.indentGuideColor = UIColor(theme.indentGuide)
833:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
834:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
835:         setNeedsDisplay()
836:     }
837:     
838:     override func draw(_ rect: CGRect) {
839:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
840:             super.draw(rect)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":360,"end_line":395}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 361-395 of 2058)
────────────────────────────────────────
361:         
362:         func textViewDidChangeSelection(_ textView: UITextView) {
363:             if !isUpdatingFromMinimap {
364:                 updateCursorPosition(textView)
365:                 updateScrollPosition(textView)
366: 
367:                 // FEAT-044: Matching bracket highlight
368:                 updateMatchingBracketHighlight(textView)
369: 
370:                 // Trigger redraw so current-line highlight/indent guides track the caret
371:                 (textView as? EditorTextView)?.setNeedsDisplay()
372: 
373:                 // Update selection in EditorCore for multi-cursor support
374:                 let range = textView.selectedRange
375:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
376: 
377:                 // Keep EditorCore.multiCursorState in sync with UIKit selection.
378:                 // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
379:                 // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
380:                 if !parent.editorCore.multiCursorState.isMultiCursor {
381:                     if range.length > 0 {
382:                         parent.editorCore.multiCursorState.cursors = [
383:                             Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)
384:                         ]
385:                     } else {
386:                         parent.editorCore.multiCursorState.reset(to: range.location)
387:                     }
388:                 }
389:             }
390:         }
391:         
392:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
393:         
394:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
395:             // User started dragging - set flag immediately to prevent programmatic scroll fighting


>>>REPORT
Multi-cursor editing fixes implemented and wired into the actual editor text view.

Key fixes / verification points (with evidence):

1) MultiCursorTextView was not being used by the editor; EditorTextView now subclasses it
- `SyntaxHighlightingTextView.makeUIView` now constructs `EditorTextView` (which is a `MultiCursorTextView`) and injects `editorCore`:
  - `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:109-116` shows `let textView = EditorTextView()` and `textView.editorCore = editorCore`.
- `EditorTextView` changed to inherit multi-cursor behavior:
  - `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:788-803` shows `class EditorTextView: MultiCursorTextView`.

2) Cmd+D “add next occurrence” now keeps UIKit selection synced so typing replaces at all cursors
- MultiCursorTextView’s Cmd+D handler now sets `selectedRange` to the primary cursor’s selection (or caret) and triggers `textViewDidChangeSelection`:
  - `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:275-290`.
- Coordinator selection handling updated so single-cursor selections preserve anchor (don’t reset to a caret-only cursor), which is required for Cmd+D to work correctly on the “first selection”:
  - `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:377-388`.

3) Option+Click (Alt+Click) add-cursor implemented in MultiCursorTextView
- Added a tap recognizer that only begins when `.alternate` is pressed; on recognition it adds a cursor at the tapped text offset and updates the UIKit caret:
  - Setup + delegate gating: `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:65-83`
  - Handler: `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:85-101`

4) Typing/editing at all cursors: fixed MultiCursorState insert/delete logic
- Previous implementation edited text using cursor positions without accounting for shifts from earlier edits; updated algorithms now apply edits left-to-right while tracking a `delta` so all cursors/selection replacements apply correctly:
  - Insert: `VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift:152-188`
  - Delete backward: `VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift:190-223`

5) Cursor/selection drawing bug fix
- MultiCursorTextView no longer draws a selection layer for the primary cursor (UIKit already draws it), preventing double-highlighting:
  - `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:117-128` (only draws selection for `!cursor.isPrimary`).

Notes:
- Cmd+D key command is provided by MultiCursorTextView (`VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:246-265`) and is inherited by EditorTextView (since it subclasses MultiCursorTextView).
- I cannot run an Xcode build with the provided tools; changes were made conservatively to avoid compile-time breakage, but please build in Xcode to confirm.
>>>END
