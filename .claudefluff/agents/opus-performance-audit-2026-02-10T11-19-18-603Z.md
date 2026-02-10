# Agent: opus-performance-audit
**Status:** done
**Tokens:** 9,704
**Cost:** $0.0000
**Time:** 2026-02-10T11:19:18.603Z

## Task
PERFORMANCE AUDIT for VSCodeiPadOS. The app has extreme lag. Investigate:

1. SyntaxHighlightingTextView.swift - find ALL places that call applySyntaxHighlighting
2. Check if highlighting runs on file OPEN (makeUIView, updateUIView)
3. Check updateLineCount, updateCursorPosition - do they have O(n) operations?
4. Look for .components(separatedBy:) calls - these are O(n) and run on every keystroke
5. Check if TextKit 1 compatibility mode (seen in logs) is causing issues

Report ALL performance bottlenecks found with line numbers.

## Response
I'll investigate the performance issues in VSCodeiPadOS. Let me start by finding and reading the SyntaxHighlightingTextView.swift file.

>>>TOOL read_file
{"path": "SyntaxHighlightingTextView.swift"}
>>>END

I need to analyze this large file systematically. Let me start by getting the symbols and then searching for the specific performance patterns.

>>>TOOL get_symbols
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query": "applySyntaxHighlighting", "glob": "**/*.swift"}
>>>END

>>>TOOL search
{"query": "components(separatedBy:", "glob": "**/*.swift"}
>>>END

>>>TOOL search
{"query": "updateLineCount", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[get_symbols]
No symbols found in VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (file may need to be opened first)

---

[search]
Found 8 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:197: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:214: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:233: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:248: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:253: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:340: applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:377: self?.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:593: func applySyntaxHighlighting(to textView: UITextView) {

---

[search]
Found 30 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift:696: let lines = text.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift:280: Text(entry.path.components(separatedBy: "/").last ?? entry.path)
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutlineView.swift:394: let lines = content.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutlineView.swift:576: let lines = content.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutlineView.swift:742: let lines = content.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift:44: let components = path.components(separatedBy: "/")
VSCodeiPadOS/VSCodeiPadOS/Views/CommandPalette.swift:648: ForEach(shortcut.components(separatedBy: " "), id: \.self) { key in
VSCodeiPadOS/VSCodeiPadOS/Views/GoToSymbol.swift:104: let lines = content.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/GoToSymbol.swift:174: let lines = content.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/GoToSymbol.swift:229: let lines = content.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/GoToSymbol.swift:271: let lines = content.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:83: var lines = text.components(separatedBy: "\n")
VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift:403: let lines = code.components(separatedBy: .newlines).count
VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift:471: let lines = code.components(separatedBy: .newlines).count
VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift:480: score += code.components(separatedBy: pattern).count - 1
VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift:490: score += code.components(separatedBy: "function ").count - 1
VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift:491: score += code.components(separatedBy: "=> ").count - 1
VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift:493: score += code.components(separatedBy: "def ").count - 1
VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift:495: score += code.components(separatedBy: "func ").count - 1
VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift:503: score += code.components(separatedBy: pattern).count - 1
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/PeekDefinitionView.swift:65: let lines = content.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:101: let lines = code.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:122: let ghostLines = ghostText.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:39: let lines = code.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:503: let lines = textView.text.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:515: let lines = prefix.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:547: let lines = textView.text.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:570: let lines = textView.text.components(separatedBy: .newlines)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:639: let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:671: let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1

---

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:198: context.coordinator.updateLineCount(textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:298: // Note: updateLineCount is called in textViewDidChange, no need to call here
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:382: updateLineCount(textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:502: func updateLineCount(_ textView: UITextView) {


Let me read the specific sections with the performance-critical code:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 180, "end_line": 270}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 181-270 of 2038)
────────────────────────────────────────
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


Now let me read the updateLineCount and updateCursorPosition functions:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 500, "end_line": 600}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 501-600 of 2038)
────────────────────────────────────────
501:         
502:         func updateLineCount(_ textView: UITextView) {
503:             let lines = textView.text.components(separatedBy: .newlines)
504:             DispatchQueue.main.async {
505:                 self.parent.totalLines = max(1, lines.count)
506:             }
507:         }
508:         
509:         func updateCursorPosition(_ textView: UITextView) {
510:             guard let selectedRange = textView.selectedTextRange else { return }
511:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
512:              
513:              let text = textView.text ?? ""
514:              let prefix = String(text.prefix(cursorPosition))
515:              let lines = prefix.components(separatedBy: .newlines)
516:              
517:              let lineNumber = lines.count
518:              let column = (lines.last?.count ?? 0) + 1
519:              
520:              DispatchQueue.main.async {
521:                  self.parent.currentLineNumber = lineNumber
522:                  self.parent.currentColumn = column
523:                  self.parent.cursorIndex = cursorPosition
524:              }
525:         }
526:         
527:         func updateScrollPosition(_ textView: UITextView) {
528:             guard let font = textView.font else { return }
529:             let lineHeight = font.lineHeight
530:             let yOffset = textView.contentOffset.y
531:             let line = Int(yOffset / lineHeight)
532: 
533:             // Update lastKnownScrollPosition synchronously to prevent feedback loops
534:             lastKnownScrollPosition = line
535:             
536:             // Defer @Binding updates to avoid "Publishing changes from within view updates"
537:             DispatchQueue.main.async {
538:                 self.parent.scrollPosition = line
539:                 self.parent.scrollOffset = yOffset
540:             }
541:         }
542:         
543:         func scrollToLine(_ line: Int, in textView: UITextView) {
544:             guard !isUpdatingFromMinimap else { return }
545:             isUpdatingFromMinimap = true
546:             
547:             let lines = textView.text.components(separatedBy: .newlines)
548:             guard line >= 0 && line < lines.count else {
549:                 isUpdatingFromMinimap = false
550:                 return
551:             }
552:             
553:             var characterPosition = 0
554:             for i in 0..<line {
555:                 characterPosition += lines[i].count + 1
556:             }
557:             
558:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
559:                 let rect = textView.caretRect(for: position)
560:                 let targetY = max(0, rect.origin.y)
561:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
562:             }
563:             
564:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
565:                 self.isUpdatingFromMinimap = false
566:             }
567:         }
568: 
569:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
570:             let lines = textView.text.components(separatedBy: .newlines)
571:             guard line >= 0 && line < lines.count else { return }
572: 
573:             var characterPosition = 0
574:             for i in 0..<line {
575:                 characterPosition += lines[i].count + 1
576:             }
577: 
578:             // FEAT-041: select entire line (excluding trailing newline)
579:             let lineLength = (lines[line] as NSString).length
580:             let range = NSRange(location: characterPosition, length: lineLength)
581:             textView.selectedRange = range
582: 
583:             // Ensure it's visible
584:             scrollToLine(line, in: textView)
585: 
586:             // Update SwiftUI state
587:             updateCursorPosition(textView)
588:             updateScrollPosition(textView)
589:         }
590: 
591:         private var isApplyingHighlighting = false
592:         
593:         func applySyntaxHighlighting(to textView: UITextView) {
594:             // Guard against reentrancy - this can happen if attributedText assignment
595:             // triggers delegate callbacks that call this method again
596:             guard !isApplyingHighlighting else { return }
597:             isApplyingHighlighting = true
598:             defer { isApplyingHighlighting = false }
599:             
600:             let theme = ThemeManager.shared.currentTheme


Let me continue reading the applySyntaxHighlighting function:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 600, "end_line": 750}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 601-750 of 2038)
────────────────────────────────────────
601:             lastThemeId = theme.id
602: 
603:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
604:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
605: 
606:             let selectedRange = textView.selectedRange
607: 
608:             // NOTE: We intentionally do NOT manipulate undoManager.disableUndoRegistration/enableUndoRegistration
609:             // here. UITextView's internal undo manager state machine is fragile and can crash with
610:             // "enableUndoRegistration may only be invoked with matching call to disableUndoRegistration"
611:             // when attributedText assignment triggers internal undo callbacks.
612:             // 
613:             // Instead, we let the system handle undo naturally. The trade-off is that syntax highlighting
614:             // changes might add noise to the undo stack, but this is preferable to crashing.
615:             
616:             textView.attributedText = attributedText
617:             textView.selectedRange = selectedRange
618: 
619:             // Set typing attributes so newly typed characters have correct base styling
620:             // This prevents flicker during the debounce period before full highlighting runs
621:             let fontSize = parent.editorCore.editorFontSize
622:             textView.typingAttributes = [
623:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
624:                 .foregroundColor: UIColor(theme.editorForeground)
625:             ]
626: 
627:             // FEAT-044: restore matching bracket highlight after re-attributing text
628:             updateMatchingBracketHighlight(textView)
629:         }
630:         
631:         func handlePeekDefinition(in textView: UITextView) {
632:             guard let selectedRange = textView.selectedTextRange else { return }
633:             let text = textView.text ?? ""
634:             
635:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
636:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
637:                  
638:                  let prefix = String(text.prefix(location))
639:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
640:                  
641:                  parent.editorCore.triggerPeekDefinition(
642:                      file: parent.filename,
643:                      line: sourceLine,
644:                      content: text,
645:                      sourceLine: sourceLine
646:                  )
647:             }
648:         }
649:         
650:         func handleEscape() {
651:             if parent.editorCore.peekState != nil {
652:                 parent.editorCore.closePeekDefinition()
653:             } else {
654:                 parent.editorCore.escapeMultiCursor()
655:             }
656:         }
657:         
658:         func handleGoToDefinition(in textView: UITextView) {
659:             // Reuse the peek definition logic for now
660:             handlePeekDefinition(in: textView)
661:         }
662:         
663:         func handleFindReferences(in textView: UITextView) {
664:             guard let selectedRange = textView.selectedTextRange else { return }
665:             let text = textView.text ?? ""
666:             
667:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
668:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
669:                 
670:                 let prefix = String(text.prefix(location))
671:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
672:                 
673:                 // TODO: Implement find references functionality in EditorCore
674:                 // For now, just trigger peek definition as a placeholder
675:                 parent.editorCore.triggerPeekDefinition(
676:                     file: parent.filename,
677:                     line: sourceLine,
678:                     content: text,
679:                     sourceLine: sourceLine
680:                 )
681:             }
682:         }
683:         
684:         func handleFormatDocument(in textView: UITextView) {
685:             // TODO: Implement format document functionality
686:             // This would typically call a formatter in EditorCore
687:             print("Format Document: Not yet implemented")
688:         }
689:         
690:         func handleToggleComment(in textView: UITextView) {
691:             guard let selectedRange = textView.selectedTextRange else { return }
692:             let text = textView.text ?? ""
693:             
694:             // Get the current line range
695:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
696:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
697:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
698:                 let nsRange = NSRange(location: location, length: length)
699:                 
700:                 if nsRange.location + nsRange.length <= (text as NSString).length {
701:                     let lineText = (text as NSString).substring(with: nsRange)
702:                     let trimmed = lineText.trimmingCharacters(in: .whitespaces)
703:                     
704:                     // Check if line starts with a comment
705:                     let isCommented = trimmed.hasPrefix("//") || trimmed.hasPrefix("#") || trimmed.hasPrefix("/*")
706:                     
707:                     // Toggle comment
708:                     var newLineText: String
709:                     if isCommented {
710:                         // Remove comment
711:                         newLineText = lineText.replacingOccurrences(of: "//", with: "").replacingOccurrences(of: "#", with: "", options: .anchored)
712:                     } else {
713:                         // Add comment (use // for most languages)
714:                         newLineText = "//" + lineText
715:                     }
716:                     
717:                     // Replace the line
718:                     let textStorage = textView.textStorage
719:                     textStorage.replaceCharacters(in: nsRange, with: newLineText)
720:                     
721:                     // Update parent binding
722:                     parent.text = textView.text
723:                 }
724:             }
725:         }
726:         
727:         func handleFold(in textView: UITextView) {
728:             CodeFoldingManager.shared.foldCurrentLine()
729:         }
730:         
731:         func handleUnfold(in textView: UITextView) {
732:             CodeFoldingManager.shared.unfoldCurrentLine()
733:         }
734:         
735:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
736:             guard let textView = gesture.view as? UITextView else { return }
737: 
738:             switch gesture.state {
739:             case .began:
740:                 // Store the initial font size when pinch begins
741:                 initialFontSize = parent.editorCore.editorFontSize
742: 
743:             case .changed:
744:                 // Calculate new font size based on pinch scale
745:                 let newSize = initialFontSize * gesture.scale
746: 
747:                 // Clamp font size between 8 and 32
748:                 let clampedSize = min(max(newSize, 8), 32)
749: 
750:                 // Update EditorCore's font size (this will trigger updateUIView)


Let me check the textViewDidChange delegate method and where highlighting is triggered on text changes:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 330, "end_line": 420}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 331-420 of 2038)
────────────────────────────────────────
331:         // Allow pinch gesture to work simultaneously with text selection gestures
332:         func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
333:             // Allow pinch to work alongside native text selection gestures
334:             return true
335:         }
336:         
337:         func textViewDidBeginEditing(_ textView: UITextView) {
338:             // Ensure syntax highlighting is current when user begins editing
339:             // This handles cases where text was set but highlighting hasn't run yet
340:             applySyntaxHighlighting(to: textView)
341:         }
342:         
343:         func textViewDidChange(_ textView: UITextView) {
344:             // Update parent text
345:             parent.text = textView.text
346:             
347:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
348:             // This prevents flicker during the debounce period
349:             let theme = ThemeManager.shared.currentTheme
350:             let fontSize = parent.editorCore.editorFontSize
351:             textView.typingAttributes = [
352:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
353:                 .foregroundColor: UIColor(theme.editorForeground)
354:             ]
355:             
356:             // PERFORMANCE: Adaptive debounce based on document size
357:             // Longer debounce for large files to prevent UI blocking
358:             let textLength = textView.text.count
359:             let debounceInterval: TimeInterval
360:             if textLength > 50000 {
361:                 debounceInterval = 0.5  // Very large files (50k+ chars): 500ms
362:             } else if textLength > 20000 {
363:                 debounceInterval = 0.3  // Large files (20k+ chars): 300ms
364:             } else if textLength > 5000 {
365:                 debounceInterval = 0.15 // Medium files (5k+ chars): 150ms
366:             } else {
367:                 debounceInterval = 0.08 // Small files: 80ms (responsive)
368:             }
369:             
370:             highlightDebouncer?.invalidate()
371:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
372:                 // For large files, do highlighting on background thread
373:                 if textLength > 20000 {
374:                     self?.applyHighlightingAsync(to: textView)
375:                 } else {
376:                     DispatchQueue.main.async {
377:                         self?.applySyntaxHighlighting(to: textView)
378:                     }
379:                 }
380:             }
381:             
382:             updateLineCount(textView)
383:             updateCursorPosition(textView)
384:         }
385:         
386:         /// Async highlighting for large files - processes on background thread
387:         func applyHighlightingAsync(to textView: UITextView) {
388:             guard !isApplyingHighlighting else { return }
389:             isApplyingHighlighting = true
390:             
391:             let text = textView.text ?? ""
392:             let filename = parent.filename
393:             let theme = ThemeManager.shared.currentTheme
394:             let fontSize = parent.editorCore.editorFontSize
395:             let selectedRange = textView.selectedRange
396:             
397:             // Process highlighting on background thread
398:             DispatchQueue.global(qos: .userInitiated).async { [weak self] in
399:                 let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
400:                 let attributedText = highlighter.highlight(text, filename: filename)
401:                 
402:                 // Apply on main thread
403:                 DispatchQueue.main.async {
404:                     guard let self = self else { return }
405:                     self.isApplyingHighlighting = false
406:                     
407:                     // Only apply if text hasn't changed while we were processing
408:                     guard textView.text == text else { return }
409:                     
410:                     textView.attributedText = attributedText
411:                     textView.selectedRange = selectedRange
412:                     
413:                     textView.typingAttributes = [
414:                         .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
415:                         .foregroundColor: UIColor(theme.editorForeground)
416:                     ]
417:                     
418:                     self.lastThemeId = theme.id
419:                 }
420:             }


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 593, "end_line": 700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 594-700 of 2038)
────────────────────────────────────────
594:             // Guard against reentrancy - this can happen if attributedText assignment
595:             // triggers delegate callbacks that call this method again
596:             guard !isApplyingHighlighting else { return }
597:             isApplyingHighlighting = true
598:             defer { isApplyingHighlighting = false }
599:             
600:             let theme = ThemeManager.shared.currentTheme
601:             lastThemeId = theme.id
602: 
603:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
604:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
605: 
606:             let selectedRange = textView.selectedRange
607: 
608:             // NOTE: We intentionally do NOT manipulate undoManager.disableUndoRegistration/enableUndoRegistration
609:             // here. UITextView's internal undo manager state machine is fragile and can crash with
610:             // "enableUndoRegistration may only be invoked with matching call to disableUndoRegistration"
611:             // when attributedText assignment triggers internal undo callbacks.
612:             // 
613:             // Instead, we let the system handle undo naturally. The trade-off is that syntax highlighting
614:             // changes might add noise to the undo stack, but this is preferable to crashing.
615:             
616:             textView.attributedText = attributedText
617:             textView.selectedRange = selectedRange
618: 
619:             // Set typing attributes so newly typed characters have correct base styling
620:             // This prevents flicker during the debounce period before full highlighting runs
621:             let fontSize = parent.editorCore.editorFontSize
622:             textView.typingAttributes = [
623:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
624:                 .foregroundColor: UIColor(theme.editorForeground)
625:             ]
626: 
627:             // FEAT-044: restore matching bracket highlight after re-attributing text
628:             updateMatchingBracketHighlight(textView)
629:         }
630:         
631:         func handlePeekDefinition(in textView: UITextView) {
632:             guard let selectedRange = textView.selectedTextRange else { return }
633:             let text = textView.text ?? ""
634:             
635:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
636:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
637:                  
638:                  let prefix = String(text.prefix(location))
639:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
640:                  
641:                  parent.editorCore.triggerPeekDefinition(
642:                      file: parent.filename,
643:                      line: sourceLine,
644:                      content: text,
645:                      sourceLine: sourceLine
646:                  )
647:             }
648:         }
649:         
650:         func handleEscape() {
651:             if parent.editorCore.peekState != nil {
652:                 parent.editorCore.closePeekDefinition()
653:             } else {
654:                 parent.editorCore.escapeMultiCursor()
655:             }
656:         }
657:         
658:         func handleGoToDefinition(in textView: UITextView) {
659:             // Reuse the peek definition logic for now
660:             handlePeekDefinition(in: textView)
661:         }
662:         
663:         func handleFindReferences(in textView: UITextView) {
664:             guard let selectedRange = textView.selectedTextRange else { return }
665:             let text = textView.text ?? ""
666:             
667:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
668:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
669:                 
670:                 let prefix = String(text.prefix(location))
671:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
672:                 
673:                 // TODO: Implement find references functionality in EditorCore
674:                 // For now, just trigger peek definition as a placeholder
675:                 parent.editorCore.triggerPeekDefinition(
676:                     file: parent.filename,
677:                     line: sourceLine,
678:                     content: text,
679:                     sourceLine: sourceLine
680:                 )
681:             }
682:         }
683:         
684:         func handleFormatDocument(in textView: UITextView) {
685:             // TODO: Implement format document functionality
686:             // This would typically call a formatter in EditorCore
687:             print("Format Document: Not yet implemented")
688:         }
689:         
690:         func handleToggleComment(in textView: UITextView) {
691:             guard let selectedRange = textView.selectedTextRange else { return }
692:             let text = textView.text ?? ""
693:             
694:             // Get the current line range
695:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
696:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
697:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
698:                 let nsRange = NSRange(location: location, length: length)
699:                 
700:                 if nsRange.location + nsRange.length <= (text as NSString).length {


Let me also check the textViewDidEndEditing and any other delegate methods that might trigger highlighting:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 420, "end_line": 510}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 421-510 of 2038)
────────────────────────────────────────
421:         }
422:         
423:         func textViewDidChangeSelection(_ textView: UITextView) {
424:             if !isUpdatingFromMinimap {
425:                 updateCursorPosition(textView)
426:                 updateScrollPosition(textView)
427: 
428:                 // FEAT-044: Matching bracket highlight
429:                 updateMatchingBracketHighlight(textView)
430: 
431:                 // Trigger redraw so current-line highlight/indent guides track the caret
432:                 (textView as? EditorTextView)?.setNeedsDisplay()
433: 
434:                 // Update selection in EditorCore for multi-cursor support
435:                 // Defer @Published property updates to avoid "Publishing changes from within view updates"
436:                 let range = textView.selectedRange
437:                 let currentText = textView.text ?? ""
438:                 let isMultiCursor = parent.editorCore.multiCursorState.isMultiCursor
439:                 
440:                 DispatchQueue.main.async { [weak self] in
441:                     guard let self = self else { return }
442:                     self.parent.editorCore.updateSelection(range: range, text: currentText)
443: 
444:                     // Keep EditorCore.multiCursorState in sync with UIKit selection.
445:                     // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
446:                     // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
447:                     if !isMultiCursor {
448:                         if range.length > 0 {
449:                             self.parent.editorCore.multiCursorState.cursors = [
450:                                 Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)
451:                             ]
452:                         } else {
453:                             self.parent.editorCore.multiCursorState.reset(to: range.location)
454:                         }
455:                     }
456:                 }
457:             }
458:         }
459:         
460:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
461:         
462:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
463:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
464:             isUserScrolling = true
465:             userScrollDebouncer?.invalidate()
466:         }
467:         
468:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
469:             // If not decelerating, user stopped scrolling
470:             if !decelerate {
471:                 // Small delay to let any final scroll events settle
472:                 userScrollDebouncer?.invalidate()
473:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
474:                     self?.isUserScrolling = false
475:                 }
476:             }
477:         }
478:         
479:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
480:             // Deceleration finished - user scroll is complete
481:             userScrollDebouncer?.invalidate()
482:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
483:                 self?.isUserScrolling = false
484:             }
485:         }
486:         
487:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
488:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
489:             
490:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
491:             // We still use debouncer as a fallback for edge cases
492:             if isUserScrolling {
493:                 userScrollDebouncer?.invalidate()
494:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
495:                     self?.isUserScrolling = false
496:                 }
497:             }
498:             
499:             updateScrollPosition(textView)
500:         }
501:         
502:         func updateLineCount(_ textView: UITextView) {
503:             let lines = textView.text.components(separatedBy: .newlines)
504:             DispatchQueue.main.async {
505:                 self.parent.totalLines = max(1, lines.count)
506:             }
507:         }
508:         
509:         func updateCursorPosition(_ textView: UITextView) {
510:             guard let selectedRange = textView.selectedTextRange else { return }


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 593, "end_line": 680}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 594-680 of 2038)
────────────────────────────────────────
594:             // Guard against reentrancy - this can happen if attributedText assignment
595:             // triggers delegate callbacks that call this method again
596:             guard !isApplyingHighlighting else { return }
597:             isApplyingHighlighting = true
598:             defer { isApplyingHighlighting = false }
599:             
600:             let theme = ThemeManager.shared.currentTheme
601:             lastThemeId = theme.id
602: 
603:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
604:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
605: 
606:             let selectedRange = textView.selectedRange
607: 
608:             // NOTE: We intentionally do NOT manipulate undoManager.disableUndoRegistration/enableUndoRegistration
609:             // here. UITextView's internal undo manager state machine is fragile and can crash with
610:             // "enableUndoRegistration may only be invoked with matching call to disableUndoRegistration"
611:             // when attributedText assignment triggers internal undo callbacks.
612:             // 
613:             // Instead, we let the system handle undo naturally. The trade-off is that syntax highlighting
614:             // changes might add noise to the undo stack, but this is preferable to crashing.
615:             
616:             textView.attributedText = attributedText
617:             textView.selectedRange = selectedRange
618: 
619:             // Set typing attributes so newly typed characters have correct base styling
620:             // This prevents flicker during the debounce period before full highlighting runs
621:             let fontSize = parent.editorCore.editorFontSize
622:             textView.typingAttributes = [
623:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
624:                 .foregroundColor: UIColor(theme.editorForeground)
625:             ]
626: 
627:             // FEAT-044: restore matching bracket highlight after re-attributing text
628:             updateMatchingBracketHighlight(textView)
629:         }
630:         
631:         func handlePeekDefinition(in textView: UITextView) {
632:             guard let selectedRange = textView.selectedTextRange else { return }
633:             let text = textView.text ?? ""
634:             
635:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
636:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
637:                  
638:                  let prefix = String(text.prefix(location))
639:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
640:                  
641:                  parent.editorCore.triggerPeekDefinition(
642:                      file: parent.filename,
643:                      line: sourceLine,
644:                      content: text,
645:                      sourceLine: sourceLine
646:                  )
647:             }
648:         }
649:         
650:         func handleEscape() {
651:             if parent.editorCore.peekState != nil {
652:                 parent.editorCore.closePeekDefinition()
653:             } else {
654:                 parent.editorCore.escapeMultiCursor()
655:             }
656:         }
657:         
658:         func handleGoToDefinition(in textView: UITextView) {
659:             // Reuse the peek definition logic for now
660:             handlePeekDefinition(in: textView)
661:         }
662:         
663:         func handleFindReferences(in textView: UITextView) {
664:             guard let selectedRange = textView.selectedTextRange else { return }
665:             let text = textView.text ?? ""
666:             
667:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
668:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
669:                 
670:                 let prefix = String(text.prefix(location))
671:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
672:                 
673:                 // TODO: Implement find references functionality in EditorCore
674:                 // For now, just trigger peek definition as a placeholder
675:                 parent.editorCore.triggerPeekDefinition(
676:                     file: parent.filename,
677:                     line: sourceLine,
678:                     content: text,
679:                     sourceLine: sourceLine
680:                 )


Let me search for more performance-related patterns and check the VSCodeSyntaxHighlighter:

>>>TOOL search
{"query": "TextKit", "glob": "**/*.swift"}
>>>END

>>>TOOL search
{"query": "VSCodeSyntaxHighlighter", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:3: /// TextKit layout manager that collapses line fragments for lines marked folded in CodeFoldingManager.

---

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/PeekDefinitionView.swift:86: let highlighter = VSCodeSyntaxHighlighter(theme: ThemeManager.shared.currentTheme)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:399: let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:603: let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1318: struct VSCodeSyntaxHighlighter {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1318, "end_line": 1500}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1319-1500 of 2038)
────────────────────────────────────────
1319:     private let baseFontSize: CGFloat
1320:     let theme: Theme
1321:     
1322:     init(theme: Theme = ThemeManager.shared.currentTheme, fontSize: CGFloat = 14) {
1323:         self.theme = theme
1324:         self.baseFontSize = fontSize
1325:     }
1326:     
1327:     func highlight(_ text: String, filename: String) -> NSAttributedString {
1328:         let language = detectLanguage(from: filename)
1329:         return highlight(text, language: language)
1330:     }
1331:     
1332:     private func detectLanguage(from filename: String) -> Language {
1333:         let lower = filename.lowercased()
1334:         let ext = (filename as NSString).pathExtension.lowercased()
1335: 
1336:         // Special-case filenames without extensions
1337:         if (filename as NSString).lastPathComponent.lowercased() == "dockerfile" { return .dockerfile }
1338:         if (filename as NSString).lastPathComponent.lowercased() == ".env" { return .env }
1339:         if lower.hasSuffix("/.env") { return .env }
1340: 
1341:         switch ext {
1342:         case "swift": return .swift
1343: 
1344:         case "js", "mjs", "cjs": return .javascript
1345:         case "jsx": return .jsx
1346:         case "ts", "mts", "cts": return .typescript
1347:         case "tsx": return .tsx
1348: 
1349:         case "py", "pyw": return .python
1350:         case "rb", "ruby": return .ruby
1351:         case "go": return .go
1352:         case "rs": return .rust
1353:         case "java": return .java
1354:         case "kt", "kts": return .kotlin
1355: 
1356:         case "c", "h": return .c
1357:         case "cpp", "cc", "cxx", "hpp", "hh", "hxx": return .cpp
1358:         case "m", "mm": return .objectiveC
1359: 
1360:         case "html", "htm": return .html
1361:         case "css": return .css
1362:         case "scss", "sass": return .scss
1363:         case "less": return .less
1364:         case "json", "jsonc": return .json
1365:         case "xml", "plist", "svg": return .xml
1366:         case "yml", "yaml": return .yaml
1367:         case "sql": return .sql
1368: 
1369:         case "sh", "bash", "zsh", "fish": return .shell
1370:         case "dockerfile": return .dockerfile
1371: 
1372:         case "graphql", "gql": return .graphql
1373: 
1374:         case "md", "markdown": return .markdown
1375:         case "php": return .php
1376:         case "env": return .env
1377: 
1378:         default: return .plainText
1379:         }
1380:     }
1381:     
1382:     private func highlight(_ text: String, language: Language) -> NSAttributedString {
1383:         let attributed = NSMutableAttributedString(string: text)
1384:         let fullRange = NSRange(location: 0, length: text.utf16.count)
1385:         
1386:         // Base attributes
1387:         let baseFont = UIFont.monospacedSystemFont(ofSize: baseFontSize, weight: .regular)
1388:         attributed.addAttribute(.font, value: baseFont, range: fullRange)
1389:         attributed.addAttribute(.foregroundColor, value: UIColor(theme.editorForeground), range: fullRange)
1390:         
1391:         // Apply language-specific highlighting
1392:         switch language {
1393:         case .swift: highlightSwift(attributed, text: text)
1394:         case .javascript, .jsx: highlightJavaScript(attributed, text: text, isTS: false)
1395:         case .typescript, .tsx: highlightJavaScript(attributed, text: text, isTS: true)
1396:         case .python: highlightPython(attributed, text: text)
1397:         case .html, .xml: highlightHTML(attributed, text: text)
1398:         case .css, .scss, .less: highlightCSS(attributed, text: text)
1399:         case .json: highlightJSON(attributed, text: text)
1400:         case .markdown: highlightMarkdown(attributed, text: text)
1401:         case .rust: highlightRust(attributed, text: text)
1402:         case .go: highlightGo(attributed, text: text)
1403:         case .java, .kotlin: highlightJava(attributed, text: text)
1404:         case .c, .cpp, .objectiveC: highlightCpp(attributed, text: text)
1405:         case .ruby: highlightRuby(attributed, text: text)
1406:         case .php: highlightPHP(attributed, text: text)
1407:         case .shell, .dockerfile: highlightShell(attributed, text: text)
1408:         case .yaml, .env: highlightYAML(attributed, text: text)
1409:         case .sql: highlightSQL(attributed, text: text)
1410:         case .graphql: highlightGraphQL(attributed, text: text)
1411:         case .plainText: break
1412:         }
1413:         
1414:         // FEAT-038: Bracket Pair Colorization (applied last)
1415:         highlightBracketPairs(attributed, text: text)
1416:         
1417:         return attributed
1418:     }
1419:     
1420:     // MARK: - Bracket Pair Colorization
1421:     
1422:     private func highlightBracketPairs(_ attributed: NSMutableAttributedString, text: String) {
1423:         let brackets: [Character] = ["{", "}", "[", "]", "(", ")"]
1424:         let pairs: [Character: Character] = ["}": "{", "]": "[", ")": "("]
1425:         
1426:         var stack: [(char: Character, index: Int, depth: Int)] = []
1427:         let colors = [
1428:             UIColor(theme.bracketPair1),
1429:             UIColor(theme.bracketPair2),
1430:             UIColor(theme.bracketPair3),
1431:             UIColor(theme.bracketPair4),
1432:             UIColor(theme.bracketPair5),
1433:             UIColor(theme.bracketPair6)
1434:         ]
1435:         
1436:         // Scan text for brackets
1437:         // Note: In a real implementation, we should skip brackets inside strings/comments
1438:         // But since we apply this LAST, we can try to respect existing string/comment colors
1439:         // OR implement a more robust parser. For now, simple scan.
1440:         
1441:         // Optimization: Use scanner or direct iteration
1442:         let nsString = text as NSString
1443:         var index = 0
1444:         
1445:         while index < text.utf16.count {
1446:             let char = nsString.character(at: index)
1447:             if let scalar = UnicodeScalar(char) {
1448:                 let c = Character(scalar)
1449:                 
1450:                 if brackets.contains(c) {
1451:                     // Check if it's already colored as string/comment (heuristic)
1452:                     // If color is string/comment, skip
1453:                     // (Requires iterating attributes, which is slow. We'll just apply on top for now)
1454:                     
1455:                     if let open = pairs[c] { // Closing bracket
1456:                         if let last = stack.last, last.char == open {
1457:                             // Match found
1458:                             let depth = last.depth
1459:                             let color = colors[depth % colors.count]
1460:                             
1461:                             attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1462:                             attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: last.index, length: 1))
1463:                             
1464:                             stack.removeLast()
1465:                         } else {
1466:                             // Mismatched or extra closing bracket - unexpected
1467:                             // Keep default color or mark red? Default for now.
1468:                         }
1469:                     } else { // Opening bracket
1470:                         let depth = stack.count
1471:                         stack.append((c, index, depth))
1472:                         
1473:                         // We'll color it when (and if) we find the match, or here?
1474:                         // Better to color here tentatively, but matching is better.
1475:                         // Let's color tentatively based on depth.
1476:                         let color = colors[depth % colors.count]
1477:                         attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1478:                     }
1479:                 }
1480:             }
1481:             index += 1
1482:         }
1483:     }
1484:     
1485:     // MARK: - Swift Highlighting
1486:     
1487:     private func highlightSwift(_ attributed: NSMutableAttributedString, text: String) {
1488:         // Keywords (purple/pink)
1489:         let keywords = ["func", "var", "let", "if", "else", "for", "while", "return",
1490:                        "class", "struct", "enum", "protocol", "extension", "import",
1491:                        "private", "public", "internal", "fileprivate", "open",
1492:                        "static", "final", "override", "mutating", "nonmutating",
1493:                        "init", "deinit", "subscript", "typealias", "associatedtype",
1494:                        "where", "throws", "rethrows", "async", "await", "actor",
1495:                        "guard", "defer", "do", "try", "catch", "throw",
1496:                        "switch", "case", "default", "break", "continue", "fallthrough",
1497:                        "in", "is", "as", "inout", "some", "any", "Self",
1498:                        "get", "set", "willSet", "didSet", "lazy", "weak", "unowned",
1499:                        "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject",
1500:                        "@Environment", "@EnvironmentObject", "@ViewBuilder", "@MainActor",


>>>TOOL search
{"query": "TextKit 1", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "TextKit 1"


>>>TOOL search
{"query": "compatibility", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 11 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/Runners/SwiftRunner.swift:635: /// Convenience method for SwiftRunner compatibility
VSCodeiPadOS/VSCodeiPadOS/Services/SSHManager.swift:111: /// Connect with completion handler (for compatibility)
VSCodeiPadOS/VSCodeiPadOS/Services/ErrorParser.swift:57: /// Converts to legacy ErrorLocation for backward compatibility
VSCodeiPadOS/VSCodeiPadOS/Services/ErrorParser.swift:392: // MARK: - Legacy ErrorLocation (backward compatibility)
VSCodeiPadOS/VSCodeiPadOS/Services/ErrorParser.swift:685: // MARK: - Legacy Parsing Methods (maintained for compatibility)
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/PythonRunner.swift:74: //    - Cons: Limited language compatibility, complex implementation
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:62: /// Returns children as optional for OutlineGroup compatibility
VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift:129: // Type alias for compatibility with GitView
VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift:347: /// Alias for lastError for compatibility
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:280: // Use UTF-16 count for NSRange compatibility
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift:568: // Legacy connect method for backward compatibility


>>>TOOL search
{"query": "updateMatchingBracketHighlight", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:429: updateMatchingBracketHighlight(textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:628: updateMatchingBracketHighlight(textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:765: private func updateMatchingBracketHighlight(_ textView: UITextView) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 765, "end_line": 870}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 766-870 of 2038)
────────────────────────────────────────
766:             // Clear any existing highlights
767:             if !bracketHighlightRanges.isEmpty {
768:                 for r in bracketHighlightRanges {
769:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
770:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
771:                 }
772:                 bracketHighlightRanges.removeAll()
773:             }
774: 
775:             // Only highlight when there's a caret (no selection)
776:             let selection = textView.selectedRange
777:             guard selection.length == 0 else { return }
778: 
779:             let nsText = (textView.text ?? "") as NSString
780:             let length = nsText.length
781:             guard length > 0 else { return }
782: 
783:             let caret = selection.location
784: 
785:             // Candidate bracket location: char before caret, else at caret
786:             let candidateIndices: [Int] = [
787:                 caret - 1,
788:                 caret
789:             ].filter { $0 >= 0 && $0 < length }
790: 
791:             func isBracket(_ c: unichar) -> Bool {
792:                 c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
793:             }
794: 
795:             var bracketIndex: Int?
796:             var bracketChar: unichar = 0
797: 
798:             for idx in candidateIndices {
799:                 let c = nsText.character(at: idx)
800:                 if isBracket(c) {
801:                     bracketIndex = idx
802:                     bracketChar = c
803:                     break
804:                 }
805:             }
806: 
807:             guard let idx = bracketIndex else { return }
808: 
809:             // Define bracket pairs
810:             let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
811:             let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
812: 
813:             let theme = ThemeManager.shared.currentTheme
814:             let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
815: 
816:             var matchIndex: Int?
817: 
818:             if let close = openToClose[bracketChar] {
819:                 // Opening bracket: scan forward
820:                 var depth = 0
821:                 var i = idx + 1
822:                 while i < length {
823:                     let c = nsText.character(at: i)
824:                     if c == bracketChar {
825:                         depth += 1
826:                     } else if c == close {
827:                         if depth == 0 {
828:                             matchIndex = i
829:                             break
830:                         } else {
831:                             depth -= 1
832:                         }
833:                     }
834:                     i += 1
835:                 }
836:             } else if let open = closeToOpen[bracketChar] {
837:                 // Closing bracket: scan backward
838:                 var depth = 0
839:                 var i = idx - 1
840:                 while i >= 0 {
841:                     let c = nsText.character(at: i)
842:                     if c == bracketChar {
843:                         depth += 1
844:                     } else if c == open {
845:                         if depth == 0 {
846:                             matchIndex = i
847:                             break
848:                         } else {
849:                             depth -= 1
850:                         }
851:                     }
852:                     i -= 1
853:                 }
854:             }
855: 
856:             guard let match = matchIndex else { return }
857: 
858:             let r1 = NSRange(location: idx, length: 1)
859:             let r2 = NSRange(location: match, length: 1)
860: 
861:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
862:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
863: 
864:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
865:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
866: 
867:             bracketHighlightRanges = [r1, r2]
868:         }
869:     }
870: }


Let me check the textViewDidChangeSelection to see what runs on every selection change:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 423, "end_line": 460}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 424-460 of 2048)
────────────────────────────────────────
424:                         .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
425:                         .foregroundColor: UIColor(theme.editorForeground)
426:                     ]
427:                     
428:                     self.lastThemeId = theme.id
429:                 }
430:             }
431:         }
432:         
433:         func textViewDidChangeSelection(_ textView: UITextView) {
434:             if !isUpdatingFromMinimap {
435:                 updateCursorPosition(textView)
436:                 updateScrollPosition(textView)
437: 
438:                 // FEAT-044: Matching bracket highlight
439:                 updateMatchingBracketHighlight(textView)
440: 
441:                 // Trigger redraw so current-line highlight/indent guides track the caret
442:                 (textView as? EditorTextView)?.setNeedsDisplay()
443: 
444:                 // Update selection in EditorCore for multi-cursor support
445:                 // Defer @Published property updates to avoid "Publishing changes from within view updates"
446:                 let range = textView.selectedRange
447:                 let currentText = textView.text ?? ""
448:                 let isMultiCursor = parent.editorCore.multiCursorState.isMultiCursor
449:                 
450:                 DispatchQueue.main.async { [weak self] in
451:                     guard let self = self else { return }
452:                     self.parent.editorCore.updateSelection(range: range, text: currentText)
453: 
454:                     // Keep EditorCore.multiCursorState in sync with UIKit selection.
455:                     // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
456:                     // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
457:                     if !isMultiCursor {
458:                         if range.length > 0 {
459:                             self.parent.editorCore.multiCursorState.cursors = [
460:                                 Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)




>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 423, "end_line": 460}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 424-460 of 2048)
────────────────────────────────────────
424:                         .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
425:                         .foregroundColor: UIColor(theme.editorForeground)
426:                     ]
427:                     
428:                     self.lastThemeId = theme.id
429:                 }
430:             }
431:         }
432:         
433:         func textViewDidChangeSelection(_ textView: UITextView) {
434:             if !isUpdatingFromMinimap {
435:                 updateCursorPosition(textView)
436:                 updateScrollPosition(textView)
437: 
438:                 // FEAT-044: Matching bracket highlight
439:                 updateMatchingBracketHighlight(textView)
440: 
441:                 // Trigger redraw so current-line highlight/indent guides track the caret
442:                 (textView as? EditorTextView)?.setNeedsDisplay()
443: 
444:                 // Update selection in EditorCore for multi-cursor support
445:                 // Defer @Published property updates to avoid "Publishing changes from within view updates"
446:                 let range = textView.selectedRange
447:                 let currentText = textView.text ?? ""
448:                 let isMultiCursor = parent.editorCore.multiCursorState.isMultiCursor
449:                 
450:                 DispatchQueue.main.async { [weak self] in
451:                     guard let self = self else { return }
452:                     self.parent.editorCore.updateSelection(range: range, text: currentText)
453: 
454:                     // Keep EditorCore.multiCursorState in sync with UIKit selection.
455:                     // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
456:                     // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
457:                     if !isMultiCursor {
458:                         if range.length > 0 {
459:                             self.parent.editorCore.multiCursorState.cursors = [
460:                                 Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)


Let me check the InlayHintsOverlay which also showed components(separatedBy:) usage:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift", "start_line": 30, "end_line": 80}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift (lines 31-80 of 93)
────────────────────────────────────────
31:     var body: some View {
32:         GeometryReader { geo in
33:             let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
34:             let charWidth = (" " as NSString).size(withAttributes: [.font: font]).width
35:             let fontLineHeight = font.lineHeight
36:             let baselineAdjustment = max(0, (lineHeight - fontLineHeight) / 2)
37:             let maxVisibleLines = Int(ceil(geo.size.height / max(lineHeight, 1))) + 2
38: 
39:             let lines = code.components(separatedBy: .newlines)
40: 
41:             ZStack(alignment: .topLeading) {
42:                 ForEach(hints) { hint in
43:                     if hint.line >= scrollPosition && hint.line <= (scrollPosition + maxVisibleLines) {
44:                         let lineText = (hint.line >= 0 && hint.line < lines.count) ? lines[hint.line] : ""
45:                         let visualColumn = visualColumn(in: lineText, utf16Column: hint.column, tabSize: tabSize)
46: 
47:                         let x = gutterWidth + textInsets.left + (CGFloat(visualColumn) * charWidth)
48:                         let y = textInsets.top + baselineAdjustment + (CGFloat(hint.line - scrollPosition) * lineHeight)
49: 
50:                         Text(hint.text)
51:                             .font(.system(size: fontSize, design: .monospaced))
52:                             .foregroundColor(Color.secondary.opacity(0.42))
53:                             .offset(x: x, y: y)
54:                             .lineLimit(1)
55:                             .fixedSize(horizontal: true, vertical: false)
56:                     }
57:                 }
58:             }
59:             // Avoid drawing under minimap (or other right-side UI)
60:             .frame(
61:                 width: max(0, geo.size.width - rightReservedWidth),
62:                 height: geo.size.height,
63:                 alignment: .topLeading
64:             )
65:             .clipped()
66:         }
67:         .allowsHitTesting(false)
68:         .onAppear { recompute() }
69:         .onChange(of: code) { _ in recompute() }
70:         .onChange(of: language) { _ in recompute() }
71:     }
72: 
73:     private func recompute() {
74:         hints = InlayHintsManager.shared.hints(for: code, language: language)
75:     }
76: 
77:     private func visualColumn(in line: String, utf16Column: Int, tabSize: Int) -> Int {
78:         let ns = line as NSString
79:         let clamped = max(0, min(utf16Column, ns.length))
80:         let prefix = ns.substring(with: NSRange(location: 0, length: clamped))


Let me check how often the highlighter patterns are being compiled:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1485, "end_line": 1600}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1486-1600 of 2055)
────────────────────────────────────────
1486:                     } else { // Opening bracket
1487:                         let depth = stack.count
1488:                         stack.append((c, index, depth))
1489:                         
1490:                         // We'll color it when (and if) we find the match, or here?
1491:                         // Better to color here tentatively, but matching is better.
1492:                         // Let's color tentatively based on depth.
1493:                         let color = colors[depth % colors.count]
1494:                         attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1495:                     }
1496:                 }
1497:             }
1498:             index += 1
1499:         }
1500:     }
1501:     
1502:     // MARK: - Swift Highlighting
1503:     
1504:     private func highlightSwift(_ attributed: NSMutableAttributedString, text: String) {
1505:         // Keywords (purple/pink)
1506:         let keywords = ["func", "var", "let", "if", "else", "for", "while", "return",
1507:                        "class", "struct", "enum", "protocol", "extension", "import",
1508:                        "private", "public", "internal", "fileprivate", "open",
1509:                        "static", "final", "override", "mutating", "nonmutating",
1510:                        "init", "deinit", "subscript", "typealias", "associatedtype",
1511:                        "where", "throws", "rethrows", "async", "await", "actor",
1512:                        "guard", "defer", "do", "try", "catch", "throw",
1513:                        "switch", "case", "default", "break", "continue", "fallthrough",
1514:                        "in", "is", "as", "inout", "some", "any", "Self",
1515:                        "get", "set", "willSet", "didSet", "lazy", "weak", "unowned",
1516:                        "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject",
1517:                        "@Environment", "@EnvironmentObject", "@ViewBuilder", "@MainActor",
1518:                        "@escaping", "@autoclosure", "@available", "@objc", "@discardableResult"]
1519:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1520:         
1521:         // Types (teal) - CamelCase words that aren't keywords
1522:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1523:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1524:         
1525:         // Function calls (yellow)
1526:         let funcCallPattern = "\\b([a-z][a-zA-Z0-9]*)\\s*\\("
1527:         highlightPattern(attributed, pattern: funcCallPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1528:         
1529:         // Constants (blue)
1530:         let constants = ["true", "false", "nil", "self", "super"]
1531:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1532:         
1533:         // Comments MUST come late (green) - they override everything
1534:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1535:         
1536:         // Strings AFTER comments (orange)
1537:         highlightStrings(attributed, text: text)
1538:         
1539:         // Numbers (light green)
1540:         highlightNumbers(attributed, text: text)
1541:     }
1542:     
1543:     // MARK: - JavaScript/TypeScript Highlighting
1544:     
1545:     private func highlightJavaScript(_ attributed: NSMutableAttributedString, text: String, isTS: Bool) {
1546:         var keywords = ["function", "var", "let", "const", "if", "else", "for", "while",
1547:                        "return", "class", "extends", "new", "this", "super", "import",
1548:                        "export", "default", "from", "as", "async", "await", "yield",
1549:                        "try", "catch", "finally", "throw", "typeof", "instanceof",
1550:                        "switch", "case", "break", "continue", "do", "in", "of",
1551:                        "get", "set", "static", "constructor", "delete", "void",
1552:                        "with", "debugger"]
1553:         
1554:         if isTS {
1555:             keywords += ["interface", "type", "enum", "namespace", "module", "declare",
1556:                         "implements", "public", "private", "protected", "readonly",
1557:                         "abstract", "override", "keyof", "infer", "never", "unknown",
1558:                         "any", "asserts", "is"]
1559:         }
1560:         
1561:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1562:         
1563:         // Constants
1564:         let constants = ["true", "false", "null", "undefined", "NaN", "Infinity"]
1565:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1566:         
1567:         // Function names (yellow) - regular calls + arrow functions
1568:         let funcNamePattern = "\\b([a-zA-Z_$][a-zA-Z0-9_$]*)\\b(?=\\s*(?:\\(|=>))"
1569:         highlightPattern(attributed, pattern: funcNamePattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1570:         
1571:         // Types (teal)
1572:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1573:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1574:         
1575:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1576:         highlightStrings(attributed, text: text)
1577:         highlightJSTemplateLiterals(attributed, text: text)
1578:         highlightNumbers(attributed, text: text)
1579:     }
1580:     
1581:     // MARK: - Python Highlighting
1582:     
1583:     private func highlightPython(_ attributed: NSMutableAttributedString, text: String) {
1584:         let keywords = ["def", "class", "if", "elif", "else", "for", "while", "return",
1585:                        "import", "from", "as", "try", "except", "finally", "raise",
1586:                        "with", "assert", "yield", "lambda", "pass", "break", "continue",
1587:                        "global", "nonlocal", "del", "in", "not", "and", "or", "is",
1588:                        "async", "await", "match", "case"]
1589:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1590:         
1591:         let constants = ["True", "False", "None", "self", "cls"]
1592:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1593:         
1594:         // Decorators (yellow)
1595:         let decoratorPattern = "@[a-zA-Z_][a-zA-Z0-9_\\.]*"
1596:         highlightPattern(attributed, pattern: decoratorPattern, color: UIColor(theme.function), text: text)
1597:         
1598:         // Function definitions (yellow)
1599:         let funcDefPattern = "(?<=def\\s)[a-zA-Z_][a-zA-Z0-9_]*"
1600:         highlightPattern(attributed, pattern: funcDefPattern, color: UIColor(theme.function), text: text)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift", "start_line": 1, "end_line": 100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift (lines 2-93 of 93)
────────────────────────────────────────
2: import UIKit
3: 
4: /// Renders inlay hints as subtle inline text inside the editor area.
5: ///
6: /// This is a lightweight overlay that approximates text positions using monospaced font metrics.
7: struct InlayHintsOverlay: View {
8:     let code: String
9:     let language: CodeLanguage
10: 
11:     /// 0-based top visible line index.
12:     let scrollPosition: Int
13: 
14:     let lineHeight: CGFloat
15:     let fontSize: CGFloat
16: 
17:     /// Width reserved for the gutter (line numbers).
18:     var gutterWidth: CGFloat = 60
19: 
20:     /// Insets used by the underlying UITextView.
21:     var textInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
22: 
23:     /// Width reserved at the right edge (e.g. minimap).
24:     var rightReservedWidth: CGFloat = 0
25: 
26:     /// How many spaces a tab visually represents.
27:     var tabSize: Int = 4
28: 
29:     @State private var hints: [InlayHintsManager.InlayHint] = []
30: 
31:     var body: some View {
32:         GeometryReader { geo in
33:             let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
34:             let charWidth = (" " as NSString).size(withAttributes: [.font: font]).width
35:             let fontLineHeight = font.lineHeight
36:             let baselineAdjustment = max(0, (lineHeight - fontLineHeight) / 2)
37:             let maxVisibleLines = Int(ceil(geo.size.height / max(lineHeight, 1))) + 2
38: 
39:             let lines = code.components(separatedBy: .newlines)
40: 
41:             ZStack(alignment: .topLeading) {
42:                 ForEach(hints) { hint in
43:                     if hint.line >= scrollPosition && hint.line <= (scrollPosition + maxVisibleLines) {
44:                         let lineText = (hint.line >= 0 && hint.line < lines.count) ? lines[hint.line] : ""
45:                         let visualColumn = visualColumn(in: lineText, utf16Column: hint.column, tabSize: tabSize)
46: 
47:                         let x = gutterWidth + textInsets.left + (CGFloat(visualColumn) * charWidth)
48:                         let y = textInsets.top + baselineAdjustment + (CGFloat(hint.line - scrollPosition) * lineHeight)
49: 
50:                         Text(hint.text)
51:                             .font(.system(size: fontSize, design: .monospaced))
52:                             .foregroundColor(Color.secondary.opacity(0.42))
53:                             .offset(x: x, y: y)
54:                             .lineLimit(1)
55:                             .fixedSize(horizontal: true, vertical: false)
56:                     }
57:                 }
58:             }
59:             // Avoid drawing under minimap (or other right-side UI)
60:             .frame(
61:                 width: max(0, geo.size.width - rightReservedWidth),
62:                 height: geo.size.height,
63:                 alignment: .topLeading
64:             )
65:             .clipped()
66:         }
67:         .allowsHitTesting(false)
68:         .onAppear { recompute() }
69:         .onChange(of: code) { _ in recompute() }
70:         .onChange(of: language) { _ in recompute() }
71:     }
72: 
73:     private func recompute() {
74:         hints = InlayHintsManager.shared.hints(for: code, language: language)
75:     }
76: 
77:     private func visualColumn(in line: String, utf16Column: Int, tabSize: Int) -> Int {
78:         let ns = line as NSString
79:         let clamped = max(0, min(utf16Column, ns.length))
80:         let prefix = ns.substring(with: NSRange(location: 0, length: clamped))
81: 
82:         var col = 0
83:         for ch in prefix {
84:             if ch == "\t" {
85:                 col += tabSize
86:             } else {
87:                 col += 1
88:             }
89:         }
90:         return col
91:     }
92: }
93: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1485, "end_line": 1620}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1486-1620 of 2055)
────────────────────────────────────────
1486:                     } else { // Opening bracket
1487:                         let depth = stack.count
1488:                         stack.append((c, index, depth))
1489:                         
1490:                         // We'll color it when (and if) we find the match, or here?
1491:                         // Better to color here tentatively, but matching is better.
1492:                         // Let's color tentatively based on depth.
1493:                         let color = colors[depth % colors.count]
1494:                         attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1495:                     }
1496:                 }
1497:             }
1498:             index += 1
1499:         }
1500:     }
1501:     
1502:     // MARK: - Swift Highlighting
1503:     
1504:     private func highlightSwift(_ attributed: NSMutableAttributedString, text: String) {
1505:         // Keywords (purple/pink)
1506:         let keywords = ["func", "var", "let", "if", "else", "for", "while", "return",
1507:                        "class", "struct", "enum", "protocol", "extension", "import",
1508:                        "private", "public", "internal", "fileprivate", "open",
1509:                        "static", "final", "override", "mutating", "nonmutating",
1510:                        "init", "deinit", "subscript", "typealias", "associatedtype",
1511:                        "where", "throws", "rethrows", "async", "await", "actor",
1512:                        "guard", "defer", "do", "try", "catch", "throw",
1513:                        "switch", "case", "default", "break", "continue", "fallthrough",
1514:                        "in", "is", "as", "inout", "some", "any", "Self",
1515:                        "get", "set", "willSet", "didSet", "lazy", "weak", "unowned",
1516:                        "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject",
1517:                        "@Environment", "@EnvironmentObject", "@ViewBuilder", "@MainActor",
1518:                        "@escaping", "@autoclosure", "@available", "@objc", "@discardableResult"]
1519:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1520:         
1521:         // Types (teal) - CamelCase words that aren't keywords
1522:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1523:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1524:         
1525:         // Function calls (yellow)
1526:         let funcCallPattern = "\\b([a-z][a-zA-Z0-9]*)\\s*\\("
1527:         highlightPattern(attributed, pattern: funcCallPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1528:         
1529:         // Constants (blue)
1530:         let constants = ["true", "false", "nil", "self", "super"]
1531:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1532:         
1533:         // Comments MUST come late (green) - they override everything
1534:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1535:         
1536:         // Strings AFTER comments (orange)
1537:         highlightStrings(attributed, text: text)
1538:         
1539:         // Numbers (light green)
1540:         highlightNumbers(attributed, text: text)
1541:     }
1542:     
1543:     // MARK: - JavaScript/TypeScript Highlighting
1544:     
1545:     private func highlightJavaScript(_ attributed: NSMutableAttributedString, text: String, isTS: Bool) {
1546:         var keywords = ["function", "var", "let", "const", "if", "else", "for", "while",
1547:                        "return", "class", "extends", "new", "this", "super", "import",
1548:                        "export", "default", "from", "as", "async", "await", "yield",
1549:                        "try", "catch", "finally", "throw", "typeof", "instanceof",
1550:                        "switch", "case", "break", "continue", "do", "in", "of",
1551:                        "get", "set", "static", "constructor", "delete", "void",
1552:                        "with", "debugger"]
1553:         
1554:         if isTS {
1555:             keywords += ["interface", "type", "enum", "namespace", "module", "declare",
1556:                         "implements", "public", "private", "protected", "readonly",
1557:                         "abstract", "override", "keyof", "infer", "never", "unknown",
1558:                         "any", "asserts", "is"]
1559:         }
1560:         
1561:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1562:         
1563:         // Constants
1564:         let constants = ["true", "false", "null", "undefined", "NaN", "Infinity"]
1565:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1566:         
1567:         // Function names (yellow) - regular calls + arrow functions
1568:         let funcNamePattern = "\\b([a-zA-Z_$][a-zA-Z0-9_$]*)\\b(?=\\s*(?:\\(|=>))"
1569:         highlightPattern(attributed, pattern: funcNamePattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1570:         
1571:         // Types (teal)
1572:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1573:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1574:         
1575:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1576:         highlightStrings(attributed, text: text)
1577:         highlightJSTemplateLiterals(attributed, text: text)
1578:         highlightNumbers(attributed, text: text)
1579:     }
1580:     
1581:     // MARK: - Python Highlighting
1582:     
1583:     private func highlightPython(_ attributed: NSMutableAttributedString, text: String) {
1584:         let keywords = ["def", "class", "if", "elif", "else", "for", "while", "return",
1585:                        "import", "from", "as", "try", "except", "finally", "raise",
1586:                        "with", "assert", "yield", "lambda", "pass", "break", "continue",
1587:                        "global", "nonlocal", "del", "in", "not", "and", "or", "is",
1588:                        "async", "await", "match", "case"]
1589:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1590:         
1591:         let constants = ["True", "False", "None", "self", "cls"]
1592:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1593:         
1594:         // Decorators (yellow)
1595:         let decoratorPattern = "@[a-zA-Z_][a-zA-Z0-9_\\.]*"
1596:         highlightPattern(attributed, pattern: decoratorPattern, color: UIColor(theme.function), text: text)
1597:         
1598:         // Function definitions (yellow)
1599:         let funcDefPattern = "(?<=def\\s)[a-zA-Z_][a-zA-Z0-9_]*"
1600:         highlightPattern(attributed, pattern: funcDefPattern, color: UIColor(theme.function), text: text)
1601:         
1602:         // Class names (teal)
1603:         let classPattern = "(?<=class\\s)[a-zA-Z_][a-zA-Z0-9_]*"
1604:         highlightPattern(attributed, pattern: classPattern, color: UIColor(theme.type), text: text)
1605:         
1606:         // Built-in functions (yellow)
1607:         let builtins = ["print", "len", "range", "str", "int", "float", "list", "dict", "set",
1608:                        "tuple", "bool", "type", "isinstance", "hasattr", "getattr", "setattr",
1609:                        "open", "input", "map", "filter", "reduce", "zip", "enumerate",
1610:                        "sorted", "reversed", "min", "max", "sum", "abs", "round",
1611:                        "super", "object", "Exception", "ValueError", "TypeError"]
1612:         highlightKeywords(attributed, keywords: builtins, color: UIColor(theme.function), text: text)
1613:         
1614:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1615:         highlightPythonStrings(attributed, text: text)
1616:         highlightNumbers(attributed, text: text)
1617:     }
1618:     
1619:     // MARK: - HTML Highlighting
1620:     


>>>TOOL search
{"query": "highlightKeywords", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 30 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1519: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1531: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1561: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1565: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1589: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1592: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1612: highlightKeywords(attributed, keywords: builtins, color: UIColor(theme.function), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1663: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1685: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1723: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1727: highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1730: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1752: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1756: highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1759: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1774: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1778: highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1781: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1801: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1806: highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1809: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1828: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1831: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1855: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1858: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1876: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1896: highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1919: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1925: highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1939: highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1940, "end_line": 2055}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1941-2055 of 2055)
────────────────────────────────────────
1941:         // Built-in scalar types
1942:         let types = ["Int", "Float", "String", "Boolean", "ID"]
1943:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1944:         
1945:         // Variables ($name)
1946:         let variablePattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
1947:         highlightPattern(attributed, pattern: variablePattern, color: UIColor(theme.variable), text: text)
1948:         
1949:         // Directives (@deprecated, @skip, @include, etc.)
1950:         let directivePattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
1951:         highlightPattern(attributed, pattern: directivePattern, color: UIColor(theme.function), text: text)
1952:         
1953:         // Comments (# single line)
1954:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1955:         
1956:         // Strings
1957:         highlightStrings(attributed, text: text)
1958:         
1959:         // Numbers
1960:         highlightNumbers(attributed, text: text)
1961:     }
1962:     
1963:     // MARK: - Helper Methods
1964:     
1965:     private func highlightKeywords(_ attributed: NSMutableAttributedString, keywords: [String], color: UIColor, text: String) {
1966:         for keyword in keywords {
1967:             let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
1968:             highlightPattern(attributed, pattern: pattern, color: color, text: text)
1969:         }
1970:     }
1971:     
1972:     private func highlightPattern(_ attributed: NSMutableAttributedString, pattern: String, color: UIColor, text: String, options: NSRegularExpression.Options = [], captureGroup: Int = 0) {
1973:         guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
1974:         let range = NSRange(location: 0, length: text.utf16.count)
1975:         
1976:         regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
1977:             guard let match = match else { return }
1978:             let matchRange = captureGroup > 0 && match.numberOfRanges > captureGroup
1979:                 ? match.range(at: captureGroup)
1980:                 : match.range
1981:             if matchRange.location != NSNotFound {
1982:                 attributed.addAttribute(.foregroundColor, value: color, range: matchRange)
1983:             }
1984:         }
1985:     }
1986:     
1987:     private func highlightStrings(_ attributed: NSMutableAttributedString, text: String) {
1988:         // Double-quoted strings
1989:         let doublePattern = "\"(?:[^\"\\\\]|\\\\.)*\""
1990:         highlightPattern(attributed, pattern: doublePattern, color: UIColor(theme.string), text: text)
1991:         
1992:         // Single-quoted strings
1993:         let singlePattern = "'(?:[^'\\\\]|\\\\.)*'"
1994:         highlightPattern(attributed, pattern: singlePattern, color: UIColor(theme.string), text: text)
1995:     }
1996:     
1997:     private func highlightPythonStrings(_ attributed: NSMutableAttributedString, text: String) {
1998:         // Triple-quoted strings first
1999:         let tripleDoublePattern = "\"\"\"[\\s\\S]*?\"\"\""
2000:         highlightPattern(attributed, pattern: tripleDoublePattern, color: UIColor(theme.string), text: text)
2001:         
2002:         let tripleSinglePattern = "'''[\\s\\S]*?'''"
2003:         highlightPattern(attributed, pattern: tripleSinglePattern, color: UIColor(theme.string), text: text)
2004:         
2005:         // Then regular strings
2006:         highlightStrings(attributed, text: text)
2007:         
2008:         // F-strings (with expressions highlighted differently)
2009:         let fstringPattern = "f\"[^\"]*\"|f'[^']*'"
2010:         highlightPattern(attributed, pattern: fstringPattern, color: UIColor(theme.string), text: text)
2011:     }
2012:     
2013:     private func highlightJSTemplateLiterals(_ attributed: NSMutableAttributedString, text: String) {
2014:         // Template literals
2015:         let templatePattern = "`[^`]*`"
2016:         highlightPattern(attributed, pattern: templatePattern, color: UIColor(theme.string), text: text)
2017:     }
2018:     
2019:     private func highlightComments(_ attributed: NSMutableAttributedString, text: String, singleLine: String?, multiLineStart: String?, multiLineEnd: String?) {
2020:         // Single-line comments
2021:         if let single = singleLine {
2022:             let pattern = "\(NSRegularExpression.escapedPattern(for: single)).*$"
2023:             highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text, options: .anchorsMatchLines)
2024:         }
2025:         
2026:         // Multi-line comments
2027:         if let start = multiLineStart, let end = multiLineEnd {
2028:             let pattern = "\(NSRegularExpression.escapedPattern(for: start))[\\s\\S]*?\(NSRegularExpression.escapedPattern(for: end))"
2029:             highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
2030:         }
2031:     }
2032:     
2033:     private func highlightHTMLComments(_ attributed: NSMutableAttributedString, text: String) {
2034:         let pattern = "<!--[\\s\\S]*?-->"
2035:         highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
2036:     }
2037:     
2038:     private func highlightNumbers(_ attributed: NSMutableAttributedString, text: String) {
2039:         // Hex numbers
2040:         let hexPattern = "\\b0[xX][0-9a-fA-F]+\\b"
2041:         highlightPattern(attributed, pattern: hexPattern, color: UIColor(theme.number), text: text)
2042:         
2043:         // Binary numbers
2044:         let binPattern = "\\b0[bB][01]+\\b"
2045:         highlightPattern(attributed, pattern: binPattern, color: UIColor(theme.number), text: text)
2046:         
2047:         // Octal numbers
2048:         let octPattern = "\\b0[oO][0-7]+\\b"
2049:         highlightPattern(attributed, pattern: octPattern, color: UIColor(theme.number), text: text)
2050:         
2051:         // Decimal numbers (including floats and scientific notation)
2052:         let decPattern = "\\b\\d+\\.?\\d*([eE][+-]?\\d+)?\\b"
2053:         highlightPattern(attributed, pattern: decPattern, color: UIColor(theme.number), text: text)
2054:     }
2055: }


Now I have enough information to provide a comprehensive performance audit report.

>>>REPORT
# PERFORMANCE AUDIT: SyntaxHighlightingTextView.swift

## CRITICAL BOTTLENECKS FOUND

### 1. **applySyntaxHighlighting Called Excessively** (8 call sites)
- **Line 197**: `makeUIView` - runs on file OPEN
- **Line 214**: `updateUIView` - runs on first update (initial highlighting)
- **Line 233**: `updateUIView` - runs when font size changes
- **Line 248**: `updateUIView` - runs when text changes externally
- **Line 253**: `updateUIView` - runs when theme changes
- **Line 340**: `textViewDidBeginEditing` - runs when user starts editing
- **Line 377**: Timer callback in `textViewDidChange` (debounced)
- **Line 593**: Function definition

**Impact**: Full syntax highlighting runs MULTIPLE times on file open (makeUIView + updateUIView initial + textViewDidBeginEditing).

---

### 2. **O(n) `components(separatedBy:)` Calls on EVERY KEYSTROKE**

**Line 503** - `updateLineCount`:
```swift
let lines = textView.text.components(separatedBy: .newlines)
```
Called from `textViewDidChange` (line 382) - **RUNS ON EVERY CHARACTER TYPED**

**Line 515** - `updateCursorPosition`:
```swift
let lines = prefix.components(separatedBy: .newlines)
```
Called from `textViewDidChange` (line 383) - **RUNS ON EVERY CHARACTER TYPED**

**Line 547** - `scrollToLine`:
```swift
let lines = textView.text.components(separatedBy: .newlines)
```

**Line 570** - `scrollToAndSelectLine`:
```swift
let lines = textView.text.components(separatedBy: .newlines)
```

**Lines 639, 671** - `handlePeekDefinition` and `handleFindReferences`:
```swift
let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
```

---

### 3. **textViewDidChangeSelection Does O(n) Work on EVERY CURSOR MOVE** (Lines 433-460)
On every selection change:
- `updateCursorPosition(textView)` - O(n) string split
- `updateScrollPosition(textView)` 
- `updateMatchingBracketHighlight(textView)` - O(n) bracket scan
- `(textView as? EditorTextView)?.setNeedsDisplay()` - triggers redraw
- `parent.editorCore.updateSelection(...)` - async update

---

### 4. **highlightBracketPairs is O(n)** (Lines 1438-1499)
Iterates through ENTIRE text character-by-character on every full highlight:
```swift
while index < text.utf16.count {
    let char = nsString.character(at: index)
    // ... bracket matching logic
    index += 1
}
```

---

### 5. **highlightKeywords Creates Regex for EACH Keyword** (Line 1965-1969)
```swift
for keyword in keywords {
    let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
    highlightPattern(attributed, pattern: pattern, color: color, text: text)
}
```
For Swift alone: ~75+ keywords × regex compilation × full text scan = **thousands of regex operations per highlight**

---

### 6. **InlayHintsOverlay.swift Line 39** - O(n) split in SwiftUI body:
```swift
let lines = code.components(separatedBy: .newlines)
```
Runs on EVERY render of the overlay.

---

## SUMMARY OF FIXES NEEDED

| Location | Issue | Fix |
|----------|-------|-----|
| Line 503 | `updateLineCount` O(n) split | Cache line count, update incrementally |
| Line 515 | `updateCursorPosition` O(n) split | Use TextKit position APIs instead |
| Lines 433-460 | `textViewDidChangeSelection` too heavy | Debounce/throttle updates |
| Line 340 | `textViewDidBeginEditing` redundant highlight | Remove - already highlighted in makeUIView |
| Lines 1965-1969 | Per-keyword regex | Combine into single regex pattern |
| Line 1438-1499 | O(n) bracket scan | Only scan visible range or use incremental updates |
| Lines 197, 214 | Double highlight on open | Consolidate to single highlight call |

**Estimated impact**: For a 10,000 line file, every keystroke triggers 2+ O(n) string splits (~20,000+ string operations per character typed).
>>>END
