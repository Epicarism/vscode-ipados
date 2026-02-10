# Agent: runestone-contentview-integration
**Status:** done
**Tokens:** 3,337
**Cost:** $0.0000
**Time:** 2026-02-10T15:19:21.635Z

## Task
PHASE 3: Update ContentView.swift to use RunestoneEditorView.

1. READ FIRST:
   - VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (full file, especially lines 455-510)
   - Understand how SyntaxHighlightingTextView is currently used

2. Add import for the new view (it's in same module, so just need to use it)

3. FIND the SyntaxHighlightingTextView instantiation around line 461 and REPLACE with RunestoneEditorView:

OLD:
```swift
SyntaxHighlightingTextView(
    text: $text,
    filename: tab.fileName,
    scrollPosition: $scrollPosition,
    scrollOffset: $scrollOffset,
    totalLines: $totalLines,
    visibleLines: $visibleLines,
    currentLineNumber: $currentLineNumber,
    currentColumn: $currentColumn,
    cursorIndex: $cursorIndex,
    lineHeight: $lineHeight,
    isActive: true,
    fontSize: editorCore.editorFontSize,
    requestedLineSelection: $requestedLineSelection,
    requestedCursorIndex: $requestedCursorIndex,
    onAcceptAutocomplete: { ... },
    onDismissAutocomplete: { ... }
)
```

NEW:
```swift
RunestoneEditorView(
    text: $text,
    filename: tab.fileName,
    scrollOffset: $scrollOffset,
    totalLines: $totalLines,
    currentLineNumber: $currentLineNumber,
    currentColumn: $currentColumn,
    cursorIndex: $cursorIndex,
    isActive: true,
    fontSize: editorCore.editorFontSize,
    onAcceptAutocomplete: { ... },  // keep the closure contents
    onDismissAutocomplete: { ... }  // keep the closure contents
)
```

4. In the .onChange(of: text) modifier around line 497-503:
   - REMOVE the foldingManager.detectFoldableRegions call (Runestone handles this)
   - KEEP the other calls (editorCore.updateActiveTabContent, autocomplete.updateSuggestions)

5. Add a feature flag at top of file for easy rollback:
```swift
private let useRunestoneEditor = true
```

Then wrap in: `if useRunestoneEditor { RunestoneEditorView(...) } else { SyntaxHighlightingTextView(...) }`

DO NOT delete the old SyntaxHighlightingTextView code - keep it behind the feature flag.

## Response
I'll start by reading ContentView.swift to understand how SyntaxHighlightingTextView is currently used.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 1, "end_line": 100}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 430, "end_line": 530}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 431-530 of 1126)
────────────────────────────────────────
431:         VStack(spacing: 0) {
432:             // Find/Replace bar
433:             if editorCore.showSearch {
434:                 FindReplaceView(viewModel: findViewModel)
435:                     .background(theme.tabBarBackground)
436:             }
437:             
438:             BreadcrumbsView(editorCore: editorCore, tab: tab)
439:             
440:             GeometryReader { geometry in
441:                 ZStack(alignment: .topLeading) {
442:                 HStack(spacing: 0) {
443:                     if lineNumbersStyle != "off" {
444:                         LineNumbersWithFolding(
445:                             fileId: tab.url?.path ?? tab.fileName,
446:                             totalLines: totalLines,
447:                             currentLine: currentLineNumber,
448:                             scrollOffset: scrollOffset,
449:                             lineHeight: lineHeight,
450:                             requestedLineSelection: $requestedLineSelection,
451:                             foldingManager: foldingManager,
452:                             theme: theme
453:                         )
454:                         .frame(width: 60)
455:                         .background(theme.sidebarBackground.opacity(0.5))
456:                     }
457:                     
458:                     if tab.fileName.hasSuffix(".json") {
459:                         // JSON Tree View for .json files
460:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
461:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
462:                             .background(theme.editorBackground)
463:                     } else if useRunestoneEditor {
464:                         // Runestone-based editor with native syntax highlighting
465:                         RunestoneEditorView(
466:                             text: $text,
467:                             filename: tab.fileName,
468:                             scrollOffset: $scrollOffset,
469:                             totalLines: $totalLines,
470:                             currentLineNumber: $currentLineNumber,
471:                             currentColumn: $currentColumn,
472:                             cursorIndex: $cursorIndex,
473:                             isActive: true,
474:                             fontSize: editorCore.editorFontSize,
475:                             onAcceptAutocomplete: {
476:                                 guard showAutocomplete else { return false }
477:                                 var tempText = text
478:                                 var tempCursor = cursorIndex
479:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
480:                                 if tempText != text {
481:                                     text = tempText
482:                                     cursorIndex = tempCursor
483:                                     showAutocomplete = false
484:                                     return true
485:                                 }
486:                                 return false
487:                             },
488:                             onDismissAutocomplete: {
489:                                 guard showAutocomplete else { return false }
490:                                 autocomplete.hideSuggestions()
491:                                 showAutocomplete = false
492:                                 return true
493:                             }
494:                         )
495:                         .onChange(of: text) { newValue in
496:                             editorCore.updateActiveTabContent(newValue)
497:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
498:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
499:                             showAutocomplete = autocomplete.showSuggestions
500:                             // Note: Runestone handles code folding internally, no need to call foldingManager
501:                         }
502:                         .onChange(of: cursorIndex) { newCursor in
503:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
504:                             showAutocomplete = autocomplete.showSuggestions
505:                         }
506:                     } else {
507:                         // Legacy SyntaxHighlightingTextView (kept for fallback)
508:                         SyntaxHighlightingTextView(
509:                             text: $text,
510:                             filename: tab.fileName,
511:                             scrollPosition: $scrollPosition,
512:                             scrollOffset: $scrollOffset,
513:                             totalLines: $totalLines,
514:                             visibleLines: $visibleLines,
515:                             currentLineNumber: $currentLineNumber,
516:                             currentColumn: $currentColumn,
517:                             cursorIndex: $cursorIndex,
518:                             lineHeight: $lineHeight,
519:                             isActive: true,
520:                             fontSize: editorCore.editorFontSize,
521:                             requestedLineSelection: $requestedLineSelection,
522:                             requestedCursorIndex: $requestedCursorIndex,
523:                             onAcceptAutocomplete: {
524:                                 guard showAutocomplete else { return false }
525:                                 var tempText = text
526:                                 var tempCursor = cursorIndex
527:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
528:                                 if tempText != text {
529:                                     text = tempText
530:                                     cursorIndex = tempCursor


Let me read more to see the rest of the SyntaxHighlightingTextView code and check if the feature flag already exists.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 530, "end_line": 620}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 531-620 of 1126)
────────────────────────────────────────
531:                                     requestedCursorIndex = tempCursor
532:                                     showAutocomplete = false
533:                                     return true
534:                                 }
535:                                 return false
536:                             },
537:                             onDismissAutocomplete: {
538:                                 guard showAutocomplete else { return false }
539:                                 autocomplete.hideSuggestions()
540:                                 showAutocomplete = false
541:                                 return true
542:                             }
543:                         )
544:                         .onChange(of: text) { newValue in
545:                             editorCore.updateActiveTabContent(newValue)
546:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
547:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
548:                             showAutocomplete = autocomplete.showSuggestions
549:                             foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path ?? tab.fileName)
550:                         }
551:                         .onChange(of: cursorIndex) { newCursor in
552:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
553:                             showAutocomplete = autocomplete.showSuggestions
554:                         }
555:                     }
556:                     
557:                     if !tab.fileName.hasSuffix(".json") {
558:                         MinimapView(
559:                             content: text,
560:                             scrollOffset: scrollOffset,
561:                             scrollViewHeight: geometry.size.height,
562:                             totalContentHeight: CGFloat(totalLines) * lineHeight,
563:                             onScrollRequested: { newOffset in
564:                                 // Minimap requested scroll - update editor position
565:                                 scrollOffset = newOffset
566:                                 // Convert back from pixels to line number
567:                                 let newLine = Int(newOffset / max(lineHeight, 1))
568:                                 scrollPosition = max(0, min(newLine, totalLines - 1))
569:                             }
570:                         )
571:                         .frame(width: 80)
572:                     }
573:                 }
574:                 .background(theme.editorBackground)
575: 
576:                 // Sticky Header Overlay (FEAT-040)
577:                 StickyHeaderView(
578:                     text: text,
579:                     currentLine: scrollPosition,
580:                     theme: theme,
581:                     lineHeight: lineHeight,
582:                     onSelect: { line in
583:                         requestedLineSelection = line
584:                     }
585:                 )
586:                 .padding(.leading, lineNumbersStyle != "off" ? 60 : 0)
587:                 .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
588: 
589:                 if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
590:                     AutocompletePopup(
591:                         suggestions: autocomplete.suggestionItems,
592:                         selectedIndex: autocomplete.selectedIndex,
593:                         theme: theme
594:                     ) { index in
595:                         autocomplete.selectedIndex = index
596:                         var tempText = text
597:                         var tempCursor = cursorIndex
598:                         autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
599:                         if tempText != text {
600:                             text = tempText
601:                             cursorIndex = tempCursor
602:                             requestedCursorIndex = tempCursor
603:                         }
604:                         showAutocomplete = false
605:                     }
606:                     .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
607:                 }
608:             }
609:         }
610:         }
611:         .onAppear {
612:             text = tab.content
613:             foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
614:         }
615:         .onChange(of: tab.id) { _ in
616:             text = tab.content
617:             foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
618:         }
619:         .onChange(of: currentLineNumber) { line in
620:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)


Let me check if the feature flag is already defined at the top of the IDEEditorView struct.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 380, "end_line": 430}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 381-430 of 1126)
────────────────────────────────────────
381:     let isSelected: Bool
382:     @ObservedObject var editorCore: EditorCore
383:     let theme: Theme
384:     
385:     var body: some View {
386:         HStack(spacing: 6) {
387:             Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
388:             Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
389:                 .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
390:             if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
391:             Button(action: { editorCore.closeTab(id: tab.id) }) {
392:                 Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
393:                     .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
394:             }
395:         }
396:         .padding(.horizontal, 12).padding(.vertical, 6)
397:         .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
398:         .onTapGesture { editorCore.selectTab(id: tab.id) }
399:     }
400: }
401: 
402: // MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
403: 
404: struct IDEEditorView: View {
405:     @ObservedObject var editorCore: EditorCore
406:     let tab: Tab
407:     let theme: Theme
408:     
409:     /// Feature flag for Runestone editor - set to false to revert to SyntaxHighlightingTextView
410:     private let useRunestoneEditor = true
411: 
412:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
413:     @State private var text: String = ""
414:     @State private var scrollPosition: Int = 0
415:     @State private var scrollOffset: CGFloat = 0
416:     @State private var totalLines: Int = 1
417:     @State private var visibleLines: Int = 20
418:     @State private var currentLineNumber: Int = 1
419:     @State private var currentColumn: Int = 1
420:     @State private var cursorIndex: Int = 0
421:     @State private var lineHeight: CGFloat = 17
422:     @State private var requestedCursorIndex: Int? = nil
423:     @State private var requestedLineSelection: Int? = nil
424: 
425:     @StateObject private var autocomplete = AutocompleteManager()
426:     @State private var showAutocomplete = false
427:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
428:     @StateObject private var findViewModel = FindViewModel()
429:     
430:     var body: some View {


Excellent! I can see that the integration is already complete. The code shows:

1. **Feature flag** at line 410: `private let useRunestoneEditor = true`
2. **RunestoneEditorView** at lines 463-494 with proper bindings
3. **Legacy SyntaxHighlightingTextView** at lines 506-554 kept behind the `else` block
4. **Line 500** has a comment noting Runestone handles code folding internally
5. **foldingManager.detectFoldableRegions** is only called in the legacy path (line 549)

Let me verify the RunestoneEditorView file exists and is properly implemented:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/RunestoneEditorView.swift", "start_line": 1, "end_line": 100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 2-100 of 749)
────────────────────────────────────────
2: //  RunestoneEditorView.swift
3: //  VSCodeiPadOS
4: //
5: //  High-performance code editor using Runestone with TreeSitter syntax highlighting.
6: //  Provides native line numbers, code folding, and efficient rendering for large files.
7: //
8: 
9: import SwiftUI
10: import UIKit
11: import Runestone
12: 
13: /// Feature flag for Runestone editor - set to true when Runestone package is added
14: let useRunestoneEditorGlobal = true
15: 
16: /// UIViewRepresentable wrapper for Runestone's TextView
17: /// Provides native TreeSitter syntax highlighting, line numbers, and code folding
18: struct RunestoneEditorView: UIViewRepresentable {
19:     @Binding var text: String
20:     let filename: String
21:     @Binding var scrollOffset: CGFloat
22:     @Binding var totalLines: Int
23:     @Binding var currentLineNumber: Int
24:     @Binding var currentColumn: Int
25:     @Binding var cursorIndex: Int
26:     let isActive: Bool
27:     let fontSize: CGFloat
28:     @EnvironmentObject var editorCore: EditorCore
29:     
30:     /// Autocomplete key handling hooks (return true if handled)
31:     let onAcceptAutocomplete: (() -> Bool)?
32:     let onDismissAutocomplete: (() -> Bool)?
33:     
34:     init(
35:         text: Binding<String>,
36:         filename: String,
37:         scrollOffset: Binding<CGFloat> = .constant(0),
38:         totalLines: Binding<Int>,
39:         currentLineNumber: Binding<Int>,
40:         currentColumn: Binding<Int>,
41:         cursorIndex: Binding<Int> = .constant(0),
42:         isActive: Bool,
43:         fontSize: CGFloat = 14.0,
44:         onAcceptAutocomplete: (() -> Bool)? = nil,
45:         onDismissAutocomplete: (() -> Bool)? = nil
46:     ) {
47:         self._text = text
48:         self.filename = filename
49:         self._scrollOffset = scrollOffset
50:         self._totalLines = totalLines
51:         self._currentLineNumber = currentLineNumber
52:         self._currentColumn = currentColumn
53:         self._cursorIndex = cursorIndex
54:         self.isActive = isActive
55:         self.fontSize = fontSize
56:         self.onAcceptAutocomplete = onAcceptAutocomplete
57:         self.onDismissAutocomplete = onDismissAutocomplete
58:     }
59:     
60:     func makeCoordinator() -> Coordinator {
61:         Coordinator(self)
62:     }
63:     
64:     func makeUIView(context: Context) -> TextView {
65:         let textView = TextView()
66:         textView.editorDelegate = context.coordinator
67:         
68:         // Configure line numbers
69:         textView.showLineNumbers = true
70:         textView.lineSelectionDisplayType = .line
71:         
72:         // Configure line wrapping
73:         textView.isLineWrappingEnabled = true
74:         
75:         // Configure editing
76:         textView.isEditable = true
77:         textView.isSelectable = true
78:         
79:         // Disable autocorrect/autocapitalize for code editing
80:         textView.autocorrectionType = .no
81:         textView.autocapitalizationType = .none
82:         textView.smartQuotesType = .no
83:         textView.smartDashesType = .no
84:         textView.smartInsertDeleteType = .no
85:         textView.spellCheckingType = .no
86:         
87:         // Configure keyboard
88:         textView.keyboardType = .asciiCapable
89:         textView.keyboardDismissMode = .interactive
90:         
91:         // Set theme and appearance
92:         let theme = makeRunestoneTheme()
93:         textView.applyTheme(theme)
94:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
95:         
96:         // Content insets for padding
97:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
98:         
99:         // Configure language mode based on file extension
100:         if let language = Self.treeSitterLanguage(for: filename) {


The integration is already complete! Let me verify by checking if the file compiles properly by looking for any errors:

>>>TOOL get_errors
{}
>>>END

---

## 🔧 TOOL RESULTS

[get_errors]
✅ No errors or warnings


The integration is already complete. Let me do a final verification to ensure everything is in place:

>>>TOOL search
{"query": "useRunestoneEditor", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "useRunestoneEditor"


Let me search with the correct path:

>>>TOOL search
{"query": "RunestoneEditorView", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 8 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:465: RunestoneEditorView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:2: //  RunestoneEditorView.swift
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:18: struct RunestoneEditorView: UIViewRepresentable {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:367: var parent: RunestoneEditorView
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:373: init(_ parent: RunestoneEditorView) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:717: struct RunestoneEditorView_Previews: PreviewProvider {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:734: RunestoneEditorView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:575: RunestoneEditorView(


>>>TOOL search
{"query": "useRunestoneEditor", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:410: private let useRunestoneEditor = true
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:463: } else if useRunestoneEditor {


The integration is already complete. Let me verify the structure one more time:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 458, "end_line": 556}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 459-556 of 1126)
────────────────────────────────────────
459:                         // JSON Tree View for .json files
460:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
461:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
462:                             .background(theme.editorBackground)
463:                     } else if useRunestoneEditor {
464:                         // Runestone-based editor with native syntax highlighting
465:                         RunestoneEditorView(
466:                             text: $text,
467:                             filename: tab.fileName,
468:                             scrollOffset: $scrollOffset,
469:                             totalLines: $totalLines,
470:                             currentLineNumber: $currentLineNumber,
471:                             currentColumn: $currentColumn,
472:                             cursorIndex: $cursorIndex,
473:                             isActive: true,
474:                             fontSize: editorCore.editorFontSize,
475:                             onAcceptAutocomplete: {
476:                                 guard showAutocomplete else { return false }
477:                                 var tempText = text
478:                                 var tempCursor = cursorIndex
479:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
480:                                 if tempText != text {
481:                                     text = tempText
482:                                     cursorIndex = tempCursor
483:                                     showAutocomplete = false
484:                                     return true
485:                                 }
486:                                 return false
487:                             },
488:                             onDismissAutocomplete: {
489:                                 guard showAutocomplete else { return false }
490:                                 autocomplete.hideSuggestions()
491:                                 showAutocomplete = false
492:                                 return true
493:                             }
494:                         )
495:                         .onChange(of: text) { newValue in
496:                             editorCore.updateActiveTabContent(newValue)
497:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
498:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
499:                             showAutocomplete = autocomplete.showSuggestions
500:                             // Note: Runestone handles code folding internally, no need to call foldingManager
501:                         }
502:                         .onChange(of: cursorIndex) { newCursor in
503:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
504:                             showAutocomplete = autocomplete.showSuggestions
505:                         }
506:                     } else {
507:                         // Legacy SyntaxHighlightingTextView (kept for fallback)
508:                         SyntaxHighlightingTextView(
509:                             text: $text,
510:                             filename: tab.fileName,
511:                             scrollPosition: $scrollPosition,
512:                             scrollOffset: $scrollOffset,
513:                             totalLines: $totalLines,
514:                             visibleLines: $visibleLines,
515:                             currentLineNumber: $currentLineNumber,
516:                             currentColumn: $currentColumn,
517:                             cursorIndex: $cursorIndex,
518:                             lineHeight: $lineHeight,
519:                             isActive: true,
520:                             fontSize: editorCore.editorFontSize,
521:                             requestedLineSelection: $requestedLineSelection,
522:                             requestedCursorIndex: $requestedCursorIndex,
523:                             onAcceptAutocomplete: {
524:                                 guard showAutocomplete else { return false }
525:                                 var tempText = text
526:                                 var tempCursor = cursorIndex
527:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
528:                                 if tempText != text {
529:                                     text = tempText
530:                                     cursorIndex = tempCursor
531:                                     requestedCursorIndex = tempCursor
532:                                     showAutocomplete = false
533:                                     return true
534:                                 }
535:                                 return false
536:                             },
537:                             onDismissAutocomplete: {
538:                                 guard showAutocomplete else { return false }
539:                                 autocomplete.hideSuggestions()
540:                                 showAutocomplete = false
541:                                 return true
542:                             }
543:                         )
544:                         .onChange(of: text) { newValue in
545:                             editorCore.updateActiveTabContent(newValue)
546:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
547:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
548:                             showAutocomplete = autocomplete.showSuggestions
549:                             foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path ?? tab.fileName)
550:                         }
551:                         .onChange(of: cursorIndex) { newCursor in
552:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
553:                             showAutocomplete = autocomplete.showSuggestions
554:                         }
555:                     }
556:                     


>>>REPORT
## PHASE 3: ContentView.swift Update - ALREADY COMPLETE

The integration of RunestoneEditorView into ContentView.swift has already been completed. Here's what I verified:

### ✅ Feature Flag (Line 410)
```swift
private let useRunestoneEditor = true
```

### ✅ RunestoneEditorView Integration (Lines 463-505)
The new Runestone-based editor is properly integrated with:
- All required bindings: `text`, `scrollOffset`, `totalLines`, `currentLineNumber`, `currentColumn`, `cursorIndex`
- `filename`, `isActive`, `fontSize` parameters
- `onAcceptAutocomplete` and `onDismissAutocomplete` closures with full implementation
- `.onChange(of: text)` modifier that:
  - Calls `editorCore.updateActiveTabContent(newValue)`
  - Updates `editorCore.cursorPosition`
  - Calls `autocomplete.updateSuggestions`
  - Does NOT call `foldingManager.detectFoldableRegions` (line 500 comment explains Runestone handles this)

### ✅ Legacy SyntaxHighlightingTextView Preserved (Lines 506-555)
Kept behind the `else` block for easy rollback:
- Full original implementation preserved
- Still calls `foldingManager.detectFoldableRegions` in its `.onChange` handler

### ✅ No Compilation Errors
`get_errors` returned no issues.

### Files Verified:
- `VSCodeiPadOS/VSCodeiPadOS/ContentView.swift` (lines 380-560)
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift` (exists and properly implemented)

### Usage Locations:
RunestoneEditorView is also used in:
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:575`

**Status: COMPLETE - No changes needed**
>>>END
