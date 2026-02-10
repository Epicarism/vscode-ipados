# Agent: delegate-callback-perf
**Status:** done
**Tokens:** 14,475
**Cost:** $0.0000
**Time:** 2026-02-10T14:37:54.563Z

## Task
CRITICAL: Investigate UITextViewDelegate callbacks causing lag in VSCodeiPadOS.

Read VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift - focus on Coordinator class and ALL delegate methods.

Investigate:
1. What happens in textViewDidChange? List EVERY operation.
2. What happens in textViewDidChangeSelection? List EVERY operation.
3. Are there redundant operations between these callbacks?
4. Is autocomplete being triggered too often?
5. Are there any synchronous operations that should be async?

Report: Complete flow diagram of what happens on each keystroke, identify ALL bottlenecks, propose CONCRETE optimizations.

## Response
I'll investigate the UITextViewDelegate callbacks causing lag. Let me start by reading the SyntaxHighlightingTextView.swift file.

>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL get_symbols
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[get_symbols]
No symbols found in VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (file may need to be opened first)


>>>TOOL search
{"query": "class Coordinator", "glob": "VSCodeiPadOS/**/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:321: class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 321, "end_line": 550}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 322-550 of 2289)
────────────────────────────────────────
322:         var parent: SyntaxHighlightingTextView
323:         var lastKnownScrollPosition: Int = 0
324:         var lastThemeId: String = ""
325:         var lastRequestedLineSelection: Int? = nil
326:         var lastRequestedCursorIndex: Int? = nil
327:         private var isUpdatingFromMinimap = false
328:         private var highlightDebouncer: Timer?
329:         weak var pinchGesture: UIPinchGestureRecognizer?
330:         private var initialFontSize: CGFloat = 0
331:         
332:         // Track user scroll to prevent programmatic scroll fighting back
333:         private var userScrollDebouncer: Timer?
334:         var isUserScrolling = false
335: 
336:         // FEAT-044: Matching bracket highlight state
337:         private var bracketHighlightRanges: [NSRange] = []
338:         
339:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
340:         var hasAppliedInitialHighlighting = false
341:         
342:         // PERF: Track last line to avoid unnecessary redraws
343:         private var lastKnownLineNumber: Int = -1
344:         
345:         // PERF: Debounce bracket matching to avoid O(n) scans on every cursor move
346:         private var bracketMatchDebouncer: Timer?
347:         
348:         // PERFORMANCE: Large file highlighting optimization
349:         // Files larger than this threshold get deferred full highlighting
350:         private let largeFileThreshold = 10000  // 10k characters
351:         private var largeFileHighlightDebouncer: Timer?
352:         // Track if we have pending full highlight (for large files)
353:         private var hasPendingFullHighlight = false
354:         
355:         init(_ parent: SyntaxHighlightingTextView) {
356:             self.parent = parent
357:         }
358:         
359:         // MARK: - UIGestureRecognizerDelegate
360:         
361:         // Allow pinch gesture to work simultaneously with text selection gestures
362:         func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
363:             // Allow pinch to work alongside native text selection gestures
364:             return true
365:         }
366:         
367:         func textViewDidBeginEditing(_ textView: UITextView) {
368:             // Ensure syntax highlighting is current when user begins editing
369:             // This handles cases where text was set but highlighting hasn't run yet
370:             applySyntaxHighlighting(to: textView)
371:         }
372:         
373:         func textViewDidChange(_ textView: UITextView) {
374:             // Update parent text
375:             parent.text = textView.text
376:             
377:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
378:             // This prevents flicker during the debounce period
379:             let theme = ThemeManager.shared.currentTheme
380:             let fontSize = parent.editorCore.editorFontSize
381:             textView.typingAttributes = [
382:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
383:                 .foregroundColor: UIColor(theme.editorForeground)
384:             ]
385:             
386:             // PERFORMANCE FIX: Aggressive debounce strategy based on document size
387:             // For large files, syntax highlighting is EXTREMELY expensive and causes lag
388:             let textLength = textView.text.count
389:             
390:             // Large file threshold - above this, skip highlighting during active typing entirely
391:             let largeFileThreshold = 10000
392:             // Very large file threshold - above this, use extended delay
393:             let veryLargeFileThreshold = 50000
394:             
395:             highlightDebouncer?.invalidate()
396:             
397:             if textLength > veryLargeFileThreshold {
398:                 // VERY LARGE FILES (50k+): Wait 1.5 seconds of idle before highlighting
399:                 // This prevents UI blocking entirely during active typing
400:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
401:                     self?.applyVisibleRangeHighlighting(to: textView)
402:                 }
403:             } else if textLength > largeFileThreshold {
404:                 // LARGE FILES (10k-50k): Wait 1 second of idle, then highlight visible range only
405:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
406:                     self?.applyVisibleRangeHighlighting(to: textView)
407:                 }
408:             } else if textLength > 5000 {
409:                 // MEDIUM FILES (5k-10k): 300ms debounce, full highlighting on background thread
410:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
411:                     self?.applyHighlightingAsync(to: textView)
412:                 }
413:             } else {
414:                 // SMALL FILES (<5k): 80ms debounce, direct highlighting (fast enough)
415:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
416:                     DispatchQueue.main.async {
417:                         self?.applySyntaxHighlighting(to: textView)
418:                     }
419:                 }
420:             }
421:             
422:             updateLineCount(textView)
423:             updateCursorPosition(textView)
424:         }
425:         
426:         /// Async highlighting for large files - processes on background thread
427:         func applyHighlightingAsync(to textView: UITextView) {
428:             guard !isApplyingHighlighting else { return }
429:             isApplyingHighlighting = true
430:             
431:             let text = textView.text ?? ""
432:             let filename = parent.filename
433:             let theme = ThemeManager.shared.currentTheme
434:             let fontSize = parent.editorCore.editorFontSize
435:             let selectedRange = textView.selectedRange
436:             
437:             // Process highlighting on background thread
438:             DispatchQueue.global(qos: .userInitiated).async { [weak self] in
439:                 let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
440:                 let attributedText = highlighter.highlight(text, filename: filename)
441:                 
442:                 // Apply on main thread
443:                 DispatchQueue.main.async {
444:                     guard let self = self else { return }
445:                     self.isApplyingHighlighting = false
446:                     
447:                     // Only apply if text hasn't changed while we were processing
448:                     guard textView.text == text else { return }
449:                     
450:                     textView.attributedText = attributedText
451:                     textView.selectedRange = selectedRange
452:                     
453:                     textView.typingAttributes = [
454:                         .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
455:                         .foregroundColor: UIColor(theme.editorForeground)
456:                     ]
457:                     
458:                     self.lastThemeId = theme.id
459:                 }
460:             }
461:         }
462:         
463:         /// PERFORMANCE: Visible-range-only highlighting for very large files
464:         /// Only highlights the text that's currently visible on screen, dramatically reducing lag
465:         func applyVisibleRangeHighlighting(to textView: UITextView) {
466:             guard !isApplyingHighlighting else { return }
467:             isApplyingHighlighting = true
468:             
469:             let text = textView.text ?? ""
470:             let filename = parent.filename
471:             let theme = ThemeManager.shared.currentTheme
472:             let fontSize = parent.editorCore.editorFontSize
473:             let selectedRange = textView.selectedRange
474:             
475:             // Calculate visible range with buffer
476:             let visibleRect = textView.bounds
477:             let textContainer = textView.textContainer
478:             let layoutManager = textView.layoutManager
479:             
480:             // Get the glyph range for the visible rect
481:             var visibleGlyphRange = NSRange()
482:             layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs)) { (rect, usedRect, container, glyphRange, stop) in
483:                 if rect.intersects(visibleRect) {
484:                     if visibleGlyphRange.length == 0 {
485:                         visibleGlyphRange = glyphRange
486:                     } else {
487:                         visibleGlyphRange.length = glyphRange.location + glyphRange.length - visibleGlyphRange.location
488:                     }
489:                 } else if visibleGlyphRange.length > 0 && rect.minY > visibleRect.maxY {
490:                     stop.pointee = true
491:                 }
492:             }
493:             
494:             // Convert glyph range to character range
495:             var visibleCharRange = layoutManager.characterRange(forGlyphRange: visibleGlyphRange, actualGlyphRange: nil)
496:             
497:             // Add buffer of ~50 lines before and after for smooth scrolling
498:             let bufferChars = 5000
499:             let rangeStart = max(0, visibleCharRange.location - bufferChars)
500:             let rangeEnd = min(text.utf16.count, visibleCharRange.location + visibleCharRange.length + bufferChars)
501:             visibleCharRange = NSRange(location: rangeStart, length: rangeEnd - rangeStart)
502:             
503:             // Process highlighting on background thread
504:             DispatchQueue.global(qos: .userInitiated).async { [weak self] in
505:                 // Extract the visible portion of text
506:                 let nsText = text as NSString
507:                 let safeRange = NSRange(
508:                     location: visibleCharRange.location,
509:                     length: min(visibleCharRange.length, nsText.length - visibleCharRange.location)
510:                 )
511:                 guard safeRange.length > 0 else {
512:                     DispatchQueue.main.async {
513:                         self?.isApplyingHighlighting = false
514:                     }
515:                     return
516:                 }
517:                 
518:                 let visibleText = nsText.substring(with: safeRange)
519:                 
520:                 // Highlight only the visible portion
521:                 let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
522:                 let highlightedVisible = highlighter.highlight(visibleText, filename: filename)
523:                 
524:                 // Apply on main thread
525:                 DispatchQueue.main.async {
526:                     guard let self = self else { return }
527:                     self.isApplyingHighlighting = false
528:                     
529:                     // Only apply if text hasn't changed while we were processing
530:                     guard textView.text == text else { return }
531:                     
532:                     // Create full attributed string with base styling
533:                     let fullAttributed = NSMutableAttributedString(string: text)
534:                     let baseFont = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
535:                     let baseColor = UIColor(theme.editorForeground)
536:                     let fullRange = NSRange(location: 0, length: text.utf16.count)
537:                     fullAttributed.addAttribute(.font, value: baseFont, range: fullRange)
538:                     fullAttributed.addAttribute(.foregroundColor, value: baseColor, range: fullRange)
539:                     
540:                     // Apply highlighted attributes only to visible range
541:                     highlightedVisible.enumerateAttributes(in: NSRange(location: 0, length: highlightedVisible.length), options: []) { attrs, range, _ in
542:                         let targetRange = NSRange(location: safeRange.location + range.location, length: range.length)
543:                         if targetRange.location + targetRange.length <= fullAttributed.length {
544:                             for (key, value) in attrs {
545:                                 fullAttributed.addAttribute(key, value: value, range: targetRange)
546:                             }
547:                         }
548:                     }
549:                     
550:                     textView.attributedText = fullAttributed


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 550, "end_line": 800}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 551-800 of 2289)
────────────────────────────────────────
551:                     textView.selectedRange = selectedRange
552:                     
553:                     textView.typingAttributes = [
554:                         .font: baseFont,
555:                         .foregroundColor: baseColor
556:                     ]
557:                     
558:                     self.lastThemeId = theme.id
559:                 }
560:             }
561:         }
562:         
563:         func textViewDidChangeSelection(_ textView: UITextView) {
564:             if !isUpdatingFromMinimap {
565:                 updateCursorPosition(textView)
566:                 updateScrollPosition(textView)
567: 
568:                 // FEAT-044: Matching bracket highlight - PERF: debounced to avoid O(n) scan spam
569:                 bracketMatchDebouncer?.invalidate()
570:                 bracketMatchDebouncer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
571:                     self?.updateMatchingBracketHighlight(textView)
572:                 }
573: 
574:                 // PERF: Only trigger redraw when line actually changes (not on every cursor move)
575:                 let currentLine = parent.currentLineNumber
576:                 if currentLine != lastKnownLineNumber {
577:                     lastKnownLineNumber = currentLine
578:                     (textView as? EditorTextView)?.setNeedsDisplay()
579:                 }
580: 
581:                 // Update selection in EditorCore for multi-cursor support
582:                 // Defer @Published property updates to avoid "Publishing changes from within view updates"
583:                 let range = textView.selectedRange
584:                 let currentText = textView.text ?? ""
585:                 let isMultiCursor = parent.editorCore.multiCursorState.isMultiCursor
586:                 
587:                 DispatchQueue.main.async { [weak self] in
588:                     guard let self = self else { return }
589:                     self.parent.editorCore.updateSelection(range: range, text: currentText)
590: 
591:                     // Keep EditorCore.multiCursorState in sync with UIKit selection.
592:                     // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
593:                     // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
594:                     if !isMultiCursor {
595:                         if range.length > 0 {
596:                             self.parent.editorCore.multiCursorState.cursors = [
597:                                 Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)
598:                             ]
599:                         } else {
600:                             self.parent.editorCore.multiCursorState.reset(to: range.location)
601:                         }
602:                     }
603:                 }
604:             }
605:         }
606:         
607:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
608:         
609:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
610:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
611:             isUserScrolling = true
612:             userScrollDebouncer?.invalidate()
613:         }
614:         
615:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
616:             // If not decelerating, user stopped scrolling
617:             if !decelerate {
618:                 // Small delay to let any final scroll events settle
619:                 userScrollDebouncer?.invalidate()
620:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
621:                     self?.isUserScrolling = false
622:                 }
623:             }
624:         }
625:         
626:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
627:             // Deceleration finished - user scroll is complete
628:             userScrollDebouncer?.invalidate()
629:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
630:                 self?.isUserScrolling = false
631:             }
632:         }
633:         
634:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
635:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
636:             
637:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
638:             // We still use debouncer as a fallback for edge cases
639:             if isUserScrolling {
640:                 userScrollDebouncer?.invalidate()
641:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
642:                     self?.isUserScrolling = false
643:                 }
644:             }
645:             
646:             updateScrollPosition(textView)
647:         }
648:         
649:         func updateLineCount(_ textView: UITextView) {
650:             // PERF: Count newlines directly instead of creating array copy
651:             let text = textView.text ?? ""
652:             var lineCount = 1
653:             for char in text {
654:                 if char == "\n" {
655:                     lineCount += 1
656:                 }
657:             }
658:             DispatchQueue.main.async {
659:                 self.parent.totalLines = lineCount
660:             }
661:         }
662:         
663:         func updateCursorPosition(_ textView: UITextView) {
664:             guard let selectedRange = textView.selectedTextRange else { return }
665:             let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
666:             
667:             // PERF: Count newlines directly instead of creating substring + array
668:             let text = textView.text ?? ""
669:             var lineNumber = 1
670:             var columnStart = 0
671:             
672:             let endIndex = text.index(text.startIndex, offsetBy: min(cursorPosition, text.count), limitedBy: text.endIndex) ?? text.endIndex
673:             for (i, char) in text[..<endIndex].enumerated() {
674:                 if char == "\n" {
675:                     lineNumber += 1
676:                     columnStart = i + 1
677:                 }
678:             }
679:             
680:             let column = cursorPosition - columnStart + 1
681:             
682:             DispatchQueue.main.async {
683:                 self.parent.currentLineNumber = lineNumber
684:                 self.parent.currentColumn = column
685:                 self.parent.cursorIndex = cursorPosition
686:             }
687:         }
688:         
689:         func updateScrollPosition(_ textView: UITextView) {
690:             guard let font = textView.font else { return }
691:             let lineHeight = font.lineHeight
692:             let yOffset = textView.contentOffset.y
693:             let line = Int(yOffset / lineHeight)
694: 
695:             // Update lastKnownScrollPosition synchronously to prevent feedback loops
696:             lastKnownScrollPosition = line
697:             
698:             // Defer @Binding updates to avoid "Publishing changes from within view updates"
699:             DispatchQueue.main.async {
700:                 self.parent.scrollPosition = line
701:                 self.parent.scrollOffset = yOffset
702:             }
703:         }
704:         
705:         func scrollToLine(_ line: Int, in textView: UITextView) {
706:             guard !isUpdatingFromMinimap else { return }
707:             isUpdatingFromMinimap = true
708:             
709:             let lines = textView.text.components(separatedBy: .newlines)
710:             guard line >= 0 && line < lines.count else {
711:                 isUpdatingFromMinimap = false
712:                 return
713:             }
714:             
715:             var characterPosition = 0
716:             for i in 0..<line {
717:                 characterPosition += lines[i].count + 1
718:             }
719:             
720:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
721:                 let rect = textView.caretRect(for: position)
722:                 let targetY = max(0, rect.origin.y)
723:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
724:             }
725:             
726:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
727:                 self.isUpdatingFromMinimap = false
728:             }
729:         }
730: 
731:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
732:             let lines = textView.text.components(separatedBy: .newlines)
733:             guard line >= 0 && line < lines.count else { return }
734: 
735:             var characterPosition = 0
736:             for i in 0..<line {
737:                 characterPosition += lines[i].count + 1
738:             }
739: 
740:             // FEAT-041: select entire line (excluding trailing newline)
741:             let lineLength = (lines[line] as NSString).length
742:             let range = NSRange(location: characterPosition, length: lineLength)
743:             textView.selectedRange = range
744: 
745:             // Ensure it's visible
746:             scrollToLine(line, in: textView)
747: 
748:             // Update SwiftUI state
749:             updateCursorPosition(textView)
750:             updateScrollPosition(textView)
751:         }
752: 
753:         private var isApplyingHighlighting = false
754:         
755:         func applySyntaxHighlighting(to textView: UITextView) {
756:             // Guard against reentrancy - this can happen if attributedText assignment
757:             // triggers delegate callbacks that call this method again
758:             guard !isApplyingHighlighting else { return }
759:             isApplyingHighlighting = true
760:             defer { isApplyingHighlighting = false }
761:             
762:             let theme = ThemeManager.shared.currentTheme
763:             lastThemeId = theme.id
764: 
765:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
766:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
767: 
768:             let selectedRange = textView.selectedRange
769: 
770:             // NOTE: We intentionally do NOT manipulate undoManager.disableUndoRegistration/enableUndoRegistration
771:             // here. UITextView's internal undo manager state machine is fragile and can crash with
772:             // "enableUndoRegistration may only be invoked with matching call to disableUndoRegistration"
773:             // when attributedText assignment triggers internal undo callbacks.
774:             // 
775:             // Instead, we let the system handle undo naturally. The trade-off is that syntax highlighting
776:             // changes might add noise to the undo stack, but this is preferable to crashing.
777:             
778:             textView.attributedText = attributedText
779:             textView.selectedRange = selectedRange
780: 
781:             // Set typing attributes so newly typed characters have correct base styling
782:             // This prevents flicker during the debounce period before full highlighting runs
783:             let fontSize = parent.editorCore.editorFontSize
784:             textView.typingAttributes = [
785:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
786:                 .foregroundColor: UIColor(theme.editorForeground)
787:             ]
788: 
789:             // FEAT-044: restore matching bracket highlight after re-attributing text
790:             updateMatchingBracketHighlight(textView)
791:         }
792:         
793:         func handlePeekDefinition(in textView: UITextView) {
794:             guard let selectedRange = textView.selectedTextRange else { return }
795:             let text = textView.text ?? ""
796:             
797:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
798:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
799:                  
800:                  let prefix = String(text.prefix(location))


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 800, "end_line": 1050}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 801-1050 of 2289)
────────────────────────────────────────
801:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
802:                  
803:                  parent.editorCore.triggerPeekDefinition(
804:                      file: parent.filename,
805:                      line: sourceLine,
806:                      content: text,
807:                      sourceLine: sourceLine
808:                  )
809:             }
810:         }
811:         
812:         func handleEscape() {
813:             if parent.editorCore.peekState != nil {
814:                 parent.editorCore.closePeekDefinition()
815:             } else {
816:                 parent.editorCore.escapeMultiCursor()
817:             }
818:         }
819:         
820:         func handleGoToDefinition(in textView: UITextView) {
821:             // Reuse the peek definition logic for now
822:             handlePeekDefinition(in: textView)
823:         }
824:         
825:         func handleFindReferences(in textView: UITextView) {
826:             guard let selectedRange = textView.selectedTextRange else { return }
827:             let text = textView.text ?? ""
828:             
829:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
830:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
831:                 
832:                 let prefix = String(text.prefix(location))
833:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
834:                 
835:                 // TODO: Implement find references functionality in EditorCore
836:                 // For now, just trigger peek definition as a placeholder
837:                 parent.editorCore.triggerPeekDefinition(
838:                     file: parent.filename,
839:                     line: sourceLine,
840:                     content: text,
841:                     sourceLine: sourceLine
842:                 )
843:             }
844:         }
845:         
846:         func handleFormatDocument(in textView: UITextView) {
847:             // TODO: Implement format document functionality
848:             // This would typically call a formatter in EditorCore
849:             print("Format Document: Not yet implemented")
850:         }
851:         
852:         func handleToggleComment(in textView: UITextView) {
853:             guard let selectedRange = textView.selectedTextRange else { return }
854:             let text = textView.text ?? ""
855:             
856:             // Get the current line range
857:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
858:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
859:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
860:                 let nsRange = NSRange(location: location, length: length)
861:                 
862:                 if nsRange.location + nsRange.length <= (text as NSString).length {
863:                     let lineText = (text as NSString).substring(with: nsRange)
864:                     let trimmed = lineText.trimmingCharacters(in: .whitespaces)
865:                     
866:                     // Check if line starts with a comment
867:                     let isCommented = trimmed.hasPrefix("//") || trimmed.hasPrefix("#") || trimmed.hasPrefix("/*")
868:                     
869:                     // Toggle comment
870:                     var newLineText: String
871:                     if isCommented {
872:                         // Remove comment
873:                         newLineText = lineText.replacingOccurrences(of: "//", with: "").replacingOccurrences(of: "#", with: "", options: .anchored)
874:                     } else {
875:                         // Add comment (use // for most languages)
876:                         newLineText = "//" + lineText
877:                     }
878:                     
879:                     // Replace the line
880:                     let textStorage = textView.textStorage
881:                     textStorage.replaceCharacters(in: nsRange, with: newLineText)
882:                     
883:                     // Update parent binding
884:                     parent.text = textView.text
885:                 }
886:             }
887:         }
888:         
889:         func handleFold(in textView: UITextView) {
890:             CodeFoldingManager.shared.foldCurrentLine()
891:         }
892:         
893:         func handleUnfold(in textView: UITextView) {
894:             CodeFoldingManager.shared.unfoldCurrentLine()
895:         }
896:         
897:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
898:             guard let textView = gesture.view as? UITextView else { return }
899: 
900:             switch gesture.state {
901:             case .began:
902:                 // Store the initial font size when pinch begins
903:                 initialFontSize = parent.editorCore.editorFontSize
904: 
905:             case .changed:
906:                 // Calculate new font size based on pinch scale
907:                 let newSize = initialFontSize * gesture.scale
908: 
909:                 // Clamp font size between 8 and 32
910:                 let clampedSize = min(max(newSize, 8), 32)
911: 
912:                 // Update EditorCore's font size (this will trigger updateUIView)
913:                 parent.editorCore.editorFontSize = clampedSize
914: 
915:             case .ended, .cancelled:
916:                 // Optional: snap to nearest whole number or standard size
917:                 let finalSize = round(parent.editorCore.editorFontSize)
918:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
919: 
920:             default:
921:                 break
922:             }
923:         }
924: 
925:         // MARK: - FEAT-044 Matching Bracket Highlight
926: 
927:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
928:             // Clear any existing highlights
929:             if !bracketHighlightRanges.isEmpty {
930:                 for r in bracketHighlightRanges {
931:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
932:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
933:                 }
934:                 bracketHighlightRanges.removeAll()
935:             }
936: 
937:             // Only highlight when there's a caret (no selection)
938:             let selection = textView.selectedRange
939:             guard selection.length == 0 else { return }
940: 
941:             let nsText = (textView.text ?? "") as NSString
942:             let length = nsText.length
943:             guard length > 0 else { return }
944: 
945:             let caret = selection.location
946: 
947:             // Candidate bracket location: char before caret, else at caret
948:             let candidateIndices: [Int] = [
949:                 caret - 1,
950:                 caret
951:             ].filter { $0 >= 0 && $0 < length }
952: 
953:             func isBracket(_ c: unichar) -> Bool {
954:                 c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
955:             }
956: 
957:             var bracketIndex: Int?
958:             var bracketChar: unichar = 0
959: 
960:             for idx in candidateIndices {
961:                 let c = nsText.character(at: idx)
962:                 if isBracket(c) {
963:                     bracketIndex = idx
964:                     bracketChar = c
965:                     break
966:                 }
967:             }
968: 
969:             guard let idx = bracketIndex else { return }
970: 
971:             // Define bracket pairs
972:             let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
973:             let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
974: 
975:             let theme = ThemeManager.shared.currentTheme
976:             let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
977: 
978:             var matchIndex: Int?
979: 
980:             if let close = openToClose[bracketChar] {
981:                 // Opening bracket: scan forward
982:                 var depth = 0
983:                 var i = idx + 1
984:                 while i < length {
985:                     let c = nsText.character(at: i)
986:                     if c == bracketChar {
987:                         depth += 1
988:                     } else if c == close {
989:                         if depth == 0 {
990:                             matchIndex = i
991:                             break
992:                         } else {
993:                             depth -= 1
994:                         }
995:                     }
996:                     i += 1
997:                 }
998:             } else if let open = closeToOpen[bracketChar] {
999:                 // Closing bracket: scan backward
1000:                 var depth = 0
1001:                 var i = idx - 1
1002:                 while i >= 0 {
1003:                     let c = nsText.character(at: i)
1004:                     if c == bracketChar {
1005:                         depth += 1
1006:                     } else if c == open {
1007:                         if depth == 0 {
1008:                             matchIndex = i
1009:                             break
1010:                         } else {
1011:                             depth -= 1
1012:                         }
1013:                     }
1014:                     i -= 1
1015:                 }
1016:             }
1017: 
1018:             guard let match = matchIndex else { return }
1019: 
1020:             let r1 = NSRange(location: idx, length: 1)
1021:             let r2 = NSRange(location: match, length: 1)
1022: 
1023:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
1024:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
1025: 
1026:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
1027:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
1028: 
1029:             bracketHighlightRanges = [r1, r2]
1030:         }
1031:     }
1032: }
1033: 
1034: // MARK: - FoldingLayoutManager
1035: /// TextKit layout manager that collapses line fragments for lines marked folded in CodeFoldingManager.
1036: /// This is a view-level folding implementation (it does NOT modify the underlying text).
1037: final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
1038:     weak var ownerTextView: EditorTextView?
1039: 
1040:     override init() {
1041:         super.init()
1042:         self.delegate = self
1043:     }
1044: 
1045:     required init?(coder: NSCoder) {
1046:         super.init(coder: coder)
1047:         self.delegate = self
1048:     }
1049: 
1050:     func layoutManager(


>>>TOOL search
{"query": "textViewDidChangeSelection", "glob": "VSCodeiPadOS/**/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:563: func textViewDidChangeSelection(_ textView: UITextView) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 800, "end_line": 1050}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 801-1050 of 2289)
────────────────────────────────────────
801:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
802:                  
803:                  parent.editorCore.triggerPeekDefinition(
804:                      file: parent.filename,
805:                      line: sourceLine,
806:                      content: text,
807:                      sourceLine: sourceLine
808:                  )
809:             }
810:         }
811:         
812:         func handleEscape() {
813:             if parent.editorCore.peekState != nil {
814:                 parent.editorCore.closePeekDefinition()
815:             } else {
816:                 parent.editorCore.escapeMultiCursor()
817:             }
818:         }
819:         
820:         func handleGoToDefinition(in textView: UITextView) {
821:             // Reuse the peek definition logic for now
822:             handlePeekDefinition(in: textView)
823:         }
824:         
825:         func handleFindReferences(in textView: UITextView) {
826:             guard let selectedRange = textView.selectedTextRange else { return }
827:             let text = textView.text ?? ""
828:             
829:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
830:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
831:                 
832:                 let prefix = String(text.prefix(location))
833:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
834:                 
835:                 // TODO: Implement find references functionality in EditorCore
836:                 // For now, just trigger peek definition as a placeholder
837:                 parent.editorCore.triggerPeekDefinition(
838:                     file: parent.filename,
839:                     line: sourceLine,
840:                     content: text,
841:                     sourceLine: sourceLine
842:                 )
843:             }
844:         }
845:         
846:         func handleFormatDocument(in textView: UITextView) {
847:             // TODO: Implement format document functionality
848:             // This would typically call a formatter in EditorCore
849:             print("Format Document: Not yet implemented")
850:         }
851:         
852:         func handleToggleComment(in textView: UITextView) {
853:             guard let selectedRange = textView.selectedTextRange else { return }
854:             let text = textView.text ?? ""
855:             
856:             // Get the current line range
857:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
858:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
859:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
860:                 let nsRange = NSRange(location: location, length: length)
861:                 
862:                 if nsRange.location + nsRange.length <= (text as NSString).length {
863:                     let lineText = (text as NSString).substring(with: nsRange)
864:                     let trimmed = lineText.trimmingCharacters(in: .whitespaces)
865:                     
866:                     // Check if line starts with a comment
867:                     let isCommented = trimmed.hasPrefix("//") || trimmed.hasPrefix("#") || trimmed.hasPrefix("/*")
868:                     
869:                     // Toggle comment
870:                     var newLineText: String
871:                     if isCommented {
872:                         // Remove comment
873:                         newLineText = lineText.replacingOccurrences(of: "//", with: "").replacingOccurrences(of: "#", with: "", options: .anchored)
874:                     } else {
875:                         // Add comment (use // for most languages)
876:                         newLineText = "//" + lineText
877:                     }
878:                     
879:                     // Replace the line
880:                     let textStorage = textView.textStorage
881:                     textStorage.replaceCharacters(in: nsRange, with: newLineText)
882:                     
883:                     // Update parent binding
884:                     parent.text = textView.text
885:                 }
886:             }
887:         }
888:         
889:         func handleFold(in textView: UITextView) {
890:             CodeFoldingManager.shared.foldCurrentLine()
891:         }
892:         
893:         func handleUnfold(in textView: UITextView) {
894:             CodeFoldingManager.shared.unfoldCurrentLine()
895:         }
896:         
897:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
898:             guard let textView = gesture.view as? UITextView else { return }
899: 
900:             switch gesture.state {
901:             case .began:
902:                 // Store the initial font size when pinch begins
903:                 initialFontSize = parent.editorCore.editorFontSize
904: 
905:             case .changed:
906:                 // Calculate new font size based on pinch scale
907:                 let newSize = initialFontSize * gesture.scale
908: 
909:                 // Clamp font size between 8 and 32
910:                 let clampedSize = min(max(newSize, 8), 32)
911: 
912:                 // Update EditorCore's font size (this will trigger updateUIView)
913:                 parent.editorCore.editorFontSize = clampedSize
914: 
915:             case .ended, .cancelled:
916:                 // Optional: snap to nearest whole number or standard size
917:                 let finalSize = round(parent.editorCore.editorFontSize)
918:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
919: 
920:             default:
921:                 break
922:             }
923:         }
924: 
925:         // MARK: - FEAT-044 Matching Bracket Highlight
926: 
927:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
928:             // Clear any existing highlights
929:             if !bracketHighlightRanges.isEmpty {
930:                 for r in bracketHighlightRanges {
931:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
932:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
933:                 }
934:                 bracketHighlightRanges.removeAll()
935:             }
936: 
937:             // Only highlight when there's a caret (no selection)
938:             let selection = textView.selectedRange
939:             guard selection.length == 0 else { return }
940: 
941:             let nsText = (textView.text ?? "") as NSString
942:             let length = nsText.length
943:             guard length > 0 else { return }
944: 
945:             let caret = selection.location
946: 
947:             // Candidate bracket location: char before caret, else at caret
948:             let candidateIndices: [Int] = [
949:                 caret - 1,
950:                 caret
951:             ].filter { $0 >= 0 && $0 < length }
952: 
953:             func isBracket(_ c: unichar) -> Bool {
954:                 c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
955:             }
956: 
957:             var bracketIndex: Int?
958:             var bracketChar: unichar = 0
959: 
960:             for idx in candidateIndices {
961:                 let c = nsText.character(at: idx)
962:                 if isBracket(c) {
963:                     bracketIndex = idx
964:                     bracketChar = c
965:                     break
966:                 }
967:             }
968: 
969:             guard let idx = bracketIndex else { return }
970: 
971:             // Define bracket pairs
972:             let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
973:             let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
974: 
975:             let theme = ThemeManager.shared.currentTheme
976:             let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
977: 
978:             var matchIndex: Int?
979: 
980:             if let close = openToClose[bracketChar] {
981:                 // Opening bracket: scan forward
982:                 var depth = 0
983:                 var i = idx + 1
984:                 while i < length {
985:                     let c = nsText.character(at: i)
986:                     if c == bracketChar {
987:                         depth += 1
988:                     } else if c == close {
989:                         if depth == 0 {
990:                             matchIndex = i
991:                             break
992:                         } else {
993:                             depth -= 1
994:                         }
995:                     }
996:                     i += 1
997:                 }
998:             } else if let open = closeToOpen[bracketChar] {
999:                 // Closing bracket: scan backward
1000:                 var depth = 0
1001:                 var i = idx - 1
1002:                 while i >= 0 {
1003:                     let c = nsText.character(at: i)
1004:                     if c == bracketChar {
1005:                         depth += 1
1006:                     } else if c == open {
1007:                         if depth == 0 {
1008:                             matchIndex = i
1009:                             break
1010:                         } else {
1011:                             depth -= 1
1012:                         }
1013:                     }
1014:                     i -= 1
1015:                 }
1016:             }
1017: 
1018:             guard let match = matchIndex else { return }
1019: 
1020:             let r1 = NSRange(location: idx, length: 1)
1021:             let r2 = NSRange(location: match, length: 1)
1022: 
1023:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
1024:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
1025: 
1026:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
1027:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
1028: 
1029:             bracketHighlightRanges = [r1, r2]
1030:         }
1031:     }
1032: }
1033: 
1034: // MARK: - FoldingLayoutManager
1035: /// TextKit layout manager that collapses line fragments for lines marked folded in CodeFoldingManager.
1036: /// This is a view-level folding implementation (it does NOT modify the underlying text).
1037: final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
1038:     weak var ownerTextView: EditorTextView?
1039: 
1040:     override init() {
1041:         super.init()
1042:         self.delegate = self
1043:     }
1044: 
1045:     required init?(coder: NSCoder) {
1046:         super.init(coder: coder)
1047:         self.delegate = self
1048:     }
1049: 
1050:     func layoutManager(


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 550, "end_line": 700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 551-700 of 2289)
────────────────────────────────────────
551:                     textView.selectedRange = selectedRange
552:                     
553:                     textView.typingAttributes = [
554:                         .font: baseFont,
555:                         .foregroundColor: baseColor
556:                     ]
557:                     
558:                     self.lastThemeId = theme.id
559:                 }
560:             }
561:         }
562:         
563:         func textViewDidChangeSelection(_ textView: UITextView) {
564:             if !isUpdatingFromMinimap {
565:                 updateCursorPosition(textView)
566:                 updateScrollPosition(textView)
567: 
568:                 // FEAT-044: Matching bracket highlight - PERF: debounced to avoid O(n) scan spam
569:                 bracketMatchDebouncer?.invalidate()
570:                 bracketMatchDebouncer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
571:                     self?.updateMatchingBracketHighlight(textView)
572:                 }
573: 
574:                 // PERF: Only trigger redraw when line actually changes (not on every cursor move)
575:                 let currentLine = parent.currentLineNumber
576:                 if currentLine != lastKnownLineNumber {
577:                     lastKnownLineNumber = currentLine
578:                     (textView as? EditorTextView)?.setNeedsDisplay()
579:                 }
580: 
581:                 // Update selection in EditorCore for multi-cursor support
582:                 // Defer @Published property updates to avoid "Publishing changes from within view updates"
583:                 let range = textView.selectedRange
584:                 let currentText = textView.text ?? ""
585:                 let isMultiCursor = parent.editorCore.multiCursorState.isMultiCursor
586:                 
587:                 DispatchQueue.main.async { [weak self] in
588:                     guard let self = self else { return }
589:                     self.parent.editorCore.updateSelection(range: range, text: currentText)
590: 
591:                     // Keep EditorCore.multiCursorState in sync with UIKit selection.
592:                     // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
593:                     // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
594:                     if !isMultiCursor {
595:                         if range.length > 0 {
596:                             self.parent.editorCore.multiCursorState.cursors = [
597:                                 Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)
598:                             ]
599:                         } else {
600:                             self.parent.editorCore.multiCursorState.reset(to: range.location)
601:                         }
602:                     }
603:                 }
604:             }
605:         }
606:         
607:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
608:         
609:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
610:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
611:             isUserScrolling = true
612:             userScrollDebouncer?.invalidate()
613:         }
614:         
615:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
616:             // If not decelerating, user stopped scrolling
617:             if !decelerate {
618:                 // Small delay to let any final scroll events settle
619:                 userScrollDebouncer?.invalidate()
620:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
621:                     self?.isUserScrolling = false
622:                 }
623:             }
624:         }
625:         
626:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
627:             // Deceleration finished - user scroll is complete
628:             userScrollDebouncer?.invalidate()
629:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
630:                 self?.isUserScrolling = false
631:             }
632:         }
633:         
634:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
635:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
636:             
637:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
638:             // We still use debouncer as a fallback for edge cases
639:             if isUserScrolling {
640:                 userScrollDebouncer?.invalidate()
641:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
642:                     self?.isUserScrolling = false
643:                 }
644:             }
645:             
646:             updateScrollPosition(textView)
647:         }
648:         
649:         func updateLineCount(_ textView: UITextView) {
650:             // PERF: Count newlines directly instead of creating array copy
651:             let text = textView.text ?? ""
652:             var lineCount = 1
653:             for char in text {
654:                 if char == "\n" {
655:                     lineCount += 1
656:                 }
657:             }
658:             DispatchQueue.main.async {
659:                 self.parent.totalLines = lineCount
660:             }
661:         }
662:         
663:         func updateCursorPosition(_ textView: UITextView) {
664:             guard let selectedRange = textView.selectedTextRange else { return }
665:             let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
666:             
667:             // PERF: Count newlines directly instead of creating substring + array
668:             let text = textView.text ?? ""
669:             var lineNumber = 1
670:             var columnStart = 0
671:             
672:             let endIndex = text.index(text.startIndex, offsetBy: min(cursorPosition, text.count), limitedBy: text.endIndex) ?? text.endIndex
673:             for (i, char) in text[..<endIndex].enumerated() {
674:                 if char == "\n" {
675:                     lineNumber += 1
676:                     columnStart = i + 1
677:                 }
678:             }
679:             
680:             let column = cursorPosition - columnStart + 1
681:             
682:             DispatchQueue.main.async {
683:                 self.parent.currentLineNumber = lineNumber
684:                 self.parent.currentColumn = column
685:                 self.parent.cursorIndex = cursorPosition
686:             }
687:         }
688:         
689:         func updateScrollPosition(_ textView: UITextView) {
690:             guard let font = textView.font else { return }
691:             let lineHeight = font.lineHeight
692:             let yOffset = textView.contentOffset.y
693:             let line = Int(yOffset / lineHeight)
694: 
695:             // Update lastKnownScrollPosition synchronously to prevent feedback loops
696:             lastKnownScrollPosition = line
697:             
698:             // Defer @Binding updates to avoid "Publishing changes from within view updates"
699:             DispatchQueue.main.async {
700:                 self.parent.scrollPosition = line


>>>TOOL search
{"query": "triggerAutocomplete", "glob": "VSCodeiPadOS/**/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "triggerAutocomplete"


>>>TOOL search
{"query": "autocomplete", "glob": "VSCodeiPadOS/**/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:293: // Handle cursor index requests (e.g. accepting autocomplete)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1279: // Tab: accept autocomplete if visible, else insert tab
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1286: // Escape: dismiss autocomplete/peek if visible


>>>TOOL search
{"query": "autocomplete", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 21 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/NavigationManager.swift:241: /// Find definitions matching a partial name (for autocomplete/suggestions)
VSCodeiPadOS/VSCodeiPadOS/Services/Runners/NodeRunner.swift:539: /// Get script suggestions for autocomplete
VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift:9: /// - Basic autocomplete dropdown state (showSuggestions/selectedIndex)
VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift:285: // Swift identifiers are more complex, but this is enough for basic autocomplete.
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:422: @StateObject private var autocomplete = AutocompleteManager()
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:480: autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:492: autocomplete.hideSuggestions()
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:500: autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:501: showAutocomplete = autocomplete.showSuggestions
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:505: autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:506: showAutocomplete = autocomplete.showSuggestions
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:542: if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:544: suggestions: autocomplete.suggestionItems,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:545: selectedIndex: autocomplete.selectedIndex,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:548: autocomplete.selectedIndex = index
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:551: autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:293: // Handle cursor index requests (e.g. accepting autocomplete)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1279: // Tab: accept autocomplete if visible, else insert tab
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1286: // Escape: dismiss autocomplete/peek if visible
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:220: // Tab: accept autocomplete (if showing), else insert tab
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:233: // Escape: Dismiss autocomplete if visible, else exit multi-cursor mode


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 495, "end_line": 560}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 496-560 of 1079)
────────────────────────────────────────
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
521:                                 scrollPosition = max(0, min(newLine, totalLines - 1))
522:                             }
523:                         )
524:                         .frame(width: 80)
525:                     }
526:                 }
527:                 .background(theme.editorBackground)
528: 
529:                 // Sticky Header Overlay (FEAT-040)
530:                 StickyHeaderView(
531:                     text: text,
532:                     currentLine: scrollPosition,
533:                     theme: theme,
534:                     lineHeight: lineHeight,
535:                     onSelect: { line in
536:                         requestedLineSelection = line
537:                     }
538:                 )
539:                 .padding(.leading, lineNumbersStyle != "off" ? 60 : 0)
540:                 .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
541: 
542:                 if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
543:                     AutocompletePopup(
544:                         suggestions: autocomplete.suggestionItems,
545:                         selectedIndex: autocomplete.selectedIndex,
546:                         theme: theme
547:                     ) { index in
548:                         autocomplete.selectedIndex = index
549:                         var tempText = text
550:                         var tempCursor = cursorIndex
551:                         autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
552:                         if tempText != text {
553:                             text = tempText
554:                             cursorIndex = tempCursor
555:                             requestedCursorIndex = tempCursor
556:                         }
557:                         showAutocomplete = false
558:                     }
559:                     .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
560:                 }


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift", "start_line": 1, "end_line": 150}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift (lines 2-150 of 357)
────────────────────────────────────────
2: import Foundation
3: 
4: // Type aliases for external use
5: typealias AutocompleteSuggestion = AutocompleteManager.Suggestion
6: typealias AutocompleteSuggestionKind = AutocompleteManager.SuggestionKind
7: 
8: /// FEAT-045/046/047
9: /// - Basic autocomplete dropdown state (showSuggestions/selectedIndex)
10: /// - Current file symbol extraction
11: /// - Swift stdlib completions (top-level + a small set of member completions)
12: final class AutocompleteManager: ObservableObject {
13: 
14:     // MARK: - UI-facing legacy API (kept for existing views)
15: 
16:     /// A simple list used by existing UI.
17:     @Published var suggestions: [String] = []
18:     @Published var showSuggestions = false
19:     @Published var selectedIndex = 0
20: 
21:     // MARK: - Rich suggestion model (for future UI)
22: 
23:     enum SuggestionKind: String, Hashable {
24:         case keyword
25:         case stdlib
26:         case symbol
27:         case member
28:     }
29: 
30:     struct Suggestion: Identifiable, Hashable {
31:         var id: String { "\(kind.rawValue):\(insertText)" }
32:         let kind: SuggestionKind
33:         let displayText: String
34:         let insertText: String
35:         let score: Int
36: 
37:         init(kind: SuggestionKind, displayText: String, insertText: String? = nil, score: Int) {
38:             self.kind = kind
39:             self.displayText = displayText
40:             self.insertText = insertText ?? displayText
41:             self.score = score
42:         }
43:     }
44: 
45:     /// Structured suggestions (not currently required by UI, but provides plumbing).
46:     @Published private(set) var suggestionItems: [Suggestion] = []
47: 
48:     // MARK: - Completion sources
49: 
50:     private let keywords: [String] = [
51:         "import", "func", "var", "let", "class", "struct", "enum",
52:         "if", "else", "for", "while", "switch", "case", "return",
53:         "true", "false", "nil", "self", "super", "init", "deinit",
54:         "extension", "protocol", "typealias", "static", "private",
55:         "public", "internal", "fileprivate", "open", "final",
56:         "guard", "defer", "break", "continue", "fallthrough",
57:         "throws", "throw", "try", "catch", "do", "as", "is",
58:         "in", "where", "associatedtype", "mutating", "nonmutating",
59:         "convenience", "required", "override"
60:     ]
61: 
62:     private let stdlibTopLevel: [String] = [
63:         // Common types
64:         "Any", "AnyObject", "Never", "Void",
65:         "Bool",
66:         "Int", "Int8", "Int16", "Int32", "Int64",
67:         "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
68:         "Float", "Double",
69:         "String", "Character", "Substring",
70:         "Array", "Dictionary", "Set", "Optional", "Result",
71: 
72:         // Common protocols
73:         "Equatable", "Hashable", "Comparable",
74:         "Sequence", "Collection", "BidirectionalCollection", "RandomAccessCollection",
75:         "IteratorProtocol",
76:         "Encodable", "Decodable", "Codable",
77:         "Identifiable", "CaseIterable",
78:         "Error",
79: 
80:         // Concurrency (Swift stdlib)
81:         "Task", "MainActor", "Actor", "Sendable",
82: 
83:         // Common functions
84:         "print", "debugPrint", "dump",
85:         "assert", "assertionFailure", "precondition", "preconditionFailure", "fatalError",
86:         "min", "max", "abs", "zip", "stride"
87:     ]
88: 
89:     private let memberCompletions: [String: [String]] = [
90:         "String": [
91:             "count", "isEmpty", "startIndex", "endIndex",
92:             "uppercased()", "lowercased()",
93:             "hasPrefix(\"\")", "hasSuffix(\"\")",
94:             "contains(\"\")",
95:             "split(separator:)",
96:             "trimmingCharacters(in:)",
97:             "replacingOccurrences(of:with:)",
98:             "prefix(_:)", "suffix(_:)", "dropFirst()", "dropLast()"
99:         ],
100:         "Array": [
101:             "count", "isEmpty", "first", "last",
102:             "append(_:)", "insert(_:at:)",
103:             "removeLast()", "removeAll()",
104:             "map(_:)", "compactMap(_:)", "flatMap(_:)", "filter(_:)", "reduce(_:_:)",
105:             "forEach(_:)", "sorted()", "sorted(by:)"
106:         ],
107:         "Dictionary": [
108:             "count", "isEmpty", "keys", "values",
109:             "updateValue(_:forKey:)", "removeValue(forKey:)",
110:             "mapValues(_:)"
111:         ],
112:         "Set": [
113:             "count", "isEmpty",
114:             "insert(_:)", "remove(_:)", "contains(_:)",
115:             "union(_:)", "intersection(_:)", "subtracting(_:)"
116:         ],
117:         "Optional": [
118:             "map(_:)", "flatMap(_:)"
119:         ],
120:         "Result": [
121:             "get()", "map(_:)", "mapError(_:)"
122:         ]
123:     ]
124: 
125:     // MARK: - Public API
126: 
127:     /// Updates suggestions based on the current text and cursor.
128:     ///
129:     /// FEAT-046: extracts symbols from `text` and mixes them into the suggestion list.
130:     /// FEAT-047: adds a curated set of Swift stdlib completions.
131:     func updateSuggestions(for text: String, cursorPosition: Int) {
132:         let safeCursor = max(0, min(cursorPosition, text.count))
133:         guard let context = completionContext(in: text, cursorPosition: safeCursor) else {
134:             apply(items: [])
135:             return
136:         }
137: 
138:         let prefixLower = context.prefix.lowercased()
139:         guard !prefixLower.isEmpty else {
140:             // If user just typed a dot, show members even with empty prefix.
141:             if context.isMemberCompletion, let base = context.memberBase {
142:                 let members = memberCandidates(forBase: base)
143:                 let items = members.map { Suggestion(kind: .member, displayText: $0, score: 1000) }
144:                 apply(items: items)
145:             } else {
146:                 apply(items: [])
147:             }
148:             return
149:         }
150: 


>>>TOOL search
{"query": "func applySyntaxHighlighting", "glob": "VSCodeiPadOS/**/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:755: func applySyntaxHighlighting(to textView: UITextView) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift", "start_line": 1, "end_line": 150}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift (lines 2-150 of 357)
────────────────────────────────────────
2: import Foundation
3: 
4: // Type aliases for external use
5: typealias AutocompleteSuggestion = AutocompleteManager.Suggestion
6: typealias AutocompleteSuggestionKind = AutocompleteManager.SuggestionKind
7: 
8: /// FEAT-045/046/047
9: /// - Basic autocomplete dropdown state (showSuggestions/selectedIndex)
10: /// - Current file symbol extraction
11: /// - Swift stdlib completions (top-level + a small set of member completions)
12: final class AutocompleteManager: ObservableObject {
13: 
14:     // MARK: - UI-facing legacy API (kept for existing views)
15: 
16:     /// A simple list used by existing UI.
17:     @Published var suggestions: [String] = []
18:     @Published var showSuggestions = false
19:     @Published var selectedIndex = 0
20: 
21:     // MARK: - Rich suggestion model (for future UI)
22: 
23:     enum SuggestionKind: String, Hashable {
24:         case keyword
25:         case stdlib
26:         case symbol
27:         case member
28:     }
29: 
30:     struct Suggestion: Identifiable, Hashable {
31:         var id: String { "\(kind.rawValue):\(insertText)" }
32:         let kind: SuggestionKind
33:         let displayText: String
34:         let insertText: String
35:         let score: Int
36: 
37:         init(kind: SuggestionKind, displayText: String, insertText: String? = nil, score: Int) {
38:             self.kind = kind
39:             self.displayText = displayText
40:             self.insertText = insertText ?? displayText
41:             self.score = score
42:         }
43:     }
44: 
45:     /// Structured suggestions (not currently required by UI, but provides plumbing).
46:     @Published private(set) var suggestionItems: [Suggestion] = []
47: 
48:     // MARK: - Completion sources
49: 
50:     private let keywords: [String] = [
51:         "import", "func", "var", "let", "class", "struct", "enum",
52:         "if", "else", "for", "while", "switch", "case", "return",
53:         "true", "false", "nil", "self", "super", "init", "deinit",
54:         "extension", "protocol", "typealias", "static", "private",
55:         "public", "internal", "fileprivate", "open", "final",
56:         "guard", "defer", "break", "continue", "fallthrough",
57:         "throws", "throw", "try", "catch", "do", "as", "is",
58:         "in", "where", "associatedtype", "mutating", "nonmutating",
59:         "convenience", "required", "override"
60:     ]
61: 
62:     private let stdlibTopLevel: [String] = [
63:         // Common types
64:         "Any", "AnyObject", "Never", "Void",
65:         "Bool",
66:         "Int", "Int8", "Int16", "Int32", "Int64",
67:         "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
68:         "Float", "Double",
69:         "String", "Character", "Substring",
70:         "Array", "Dictionary", "Set", "Optional", "Result",
71: 
72:         // Common protocols
73:         "Equatable", "Hashable", "Comparable",
74:         "Sequence", "Collection", "BidirectionalCollection", "RandomAccessCollection",
75:         "IteratorProtocol",
76:         "Encodable", "Decodable", "Codable",
77:         "Identifiable", "CaseIterable",
78:         "Error",
79: 
80:         // Concurrency (Swift stdlib)
81:         "Task", "MainActor", "Actor", "Sendable",
82: 
83:         // Common functions
84:         "print", "debugPrint", "dump",
85:         "assert", "assertionFailure", "precondition", "preconditionFailure", "fatalError",
86:         "min", "max", "abs", "zip", "stride"
87:     ]
88: 
89:     private let memberCompletions: [String: [String]] = [
90:         "String": [
91:             "count", "isEmpty", "startIndex", "endIndex",
92:             "uppercased()", "lowercased()",
93:             "hasPrefix(\"\")", "hasSuffix(\"\")",
94:             "contains(\"\")",
95:             "split(separator:)",
96:             "trimmingCharacters(in:)",
97:             "replacingOccurrences(of:with:)",
98:             "prefix(_:)", "suffix(_:)", "dropFirst()", "dropLast()"
99:         ],
100:         "Array": [
101:             "count", "isEmpty", "first", "last",
102:             "append(_:)", "insert(_:at:)",
103:             "removeLast()", "removeAll()",
104:             "map(_:)", "compactMap(_:)", "flatMap(_:)", "filter(_:)", "reduce(_:_:)",
105:             "forEach(_:)", "sorted()", "sorted(by:)"
106:         ],
107:         "Dictionary": [
108:             "count", "isEmpty", "keys", "values",
109:             "updateValue(_:forKey:)", "removeValue(forKey:)",
110:             "mapValues(_:)"
111:         ],
112:         "Set": [
113:             "count", "isEmpty",
114:             "insert(_:)", "remove(_:)", "contains(_:)",
115:             "union(_:)", "intersection(_:)", "subtracting(_:)"
116:         ],
117:         "Optional": [
118:             "map(_:)", "flatMap(_:)"
119:         ],
120:         "Result": [
121:             "get()", "map(_:)", "mapError(_:)"
122:         ]
123:     ]
124: 
125:     // MARK: - Public API
126: 
127:     /// Updates suggestions based on the current text and cursor.
128:     ///
129:     /// FEAT-046: extracts symbols from `text` and mixes them into the suggestion list.
130:     /// FEAT-047: adds a curated set of Swift stdlib completions.
131:     func updateSuggestions(for text: String, cursorPosition: Int) {
132:         let safeCursor = max(0, min(cursorPosition, text.count))
133:         guard let context = completionContext(in: text, cursorPosition: safeCursor) else {
134:             apply(items: [])
135:             return
136:         }
137: 
138:         let prefixLower = context.prefix.lowercased()
139:         guard !prefixLower.isEmpty else {
140:             // If user just typed a dot, show members even with empty prefix.
141:             if context.isMemberCompletion, let base = context.memberBase {
142:                 let members = memberCandidates(forBase: base)
143:                 let items = members.map { Suggestion(kind: .member, displayText: $0, score: 1000) }
144:                 apply(items: items)
145:             } else {
146:                 apply(items: [])
147:             }
148:             return
149:         }
150: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 755, "end_line": 850}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 756-850 of 2289)
────────────────────────────────────────
756:             // Guard against reentrancy - this can happen if attributedText assignment
757:             // triggers delegate callbacks that call this method again
758:             guard !isApplyingHighlighting else { return }
759:             isApplyingHighlighting = true
760:             defer { isApplyingHighlighting = false }
761:             
762:             let theme = ThemeManager.shared.currentTheme
763:             lastThemeId = theme.id
764: 
765:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
766:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
767: 
768:             let selectedRange = textView.selectedRange
769: 
770:             // NOTE: We intentionally do NOT manipulate undoManager.disableUndoRegistration/enableUndoRegistration
771:             // here. UITextView's internal undo manager state machine is fragile and can crash with
772:             // "enableUndoRegistration may only be invoked with matching call to disableUndoRegistration"
773:             // when attributedText assignment triggers internal undo callbacks.
774:             // 
775:             // Instead, we let the system handle undo naturally. The trade-off is that syntax highlighting
776:             // changes might add noise to the undo stack, but this is preferable to crashing.
777:             
778:             textView.attributedText = attributedText
779:             textView.selectedRange = selectedRange
780: 
781:             // Set typing attributes so newly typed characters have correct base styling
782:             // This prevents flicker during the debounce period before full highlighting runs
783:             let fontSize = parent.editorCore.editorFontSize
784:             textView.typingAttributes = [
785:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
786:                 .foregroundColor: UIColor(theme.editorForeground)
787:             ]
788: 
789:             // FEAT-044: restore matching bracket highlight after re-attributing text
790:             updateMatchingBracketHighlight(textView)
791:         }
792:         
793:         func handlePeekDefinition(in textView: UITextView) {
794:             guard let selectedRange = textView.selectedTextRange else { return }
795:             let text = textView.text ?? ""
796:             
797:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
798:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
799:                  
800:                  let prefix = String(text.prefix(location))
801:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
802:                  
803:                  parent.editorCore.triggerPeekDefinition(
804:                      file: parent.filename,
805:                      line: sourceLine,
806:                      content: text,
807:                      sourceLine: sourceLine
808:                  )
809:             }
810:         }
811:         
812:         func handleEscape() {
813:             if parent.editorCore.peekState != nil {
814:                 parent.editorCore.closePeekDefinition()
815:             } else {
816:                 parent.editorCore.escapeMultiCursor()
817:             }
818:         }
819:         
820:         func handleGoToDefinition(in textView: UITextView) {
821:             // Reuse the peek definition logic for now
822:             handlePeekDefinition(in: textView)
823:         }
824:         
825:         func handleFindReferences(in textView: UITextView) {
826:             guard let selectedRange = textView.selectedTextRange else { return }
827:             let text = textView.text ?? ""
828:             
829:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
830:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
831:                 
832:                 let prefix = String(text.prefix(location))
833:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
834:                 
835:                 // TODO: Implement find references functionality in EditorCore
836:                 // For now, just trigger peek definition as a placeholder
837:                 parent.editorCore.triggerPeekDefinition(
838:                     file: parent.filename,
839:                     line: sourceLine,
840:                     content: text,
841:                     sourceLine: sourceLine
842:                 )
843:             }
844:         }
845:         
846:         func handleFormatDocument(in textView: UITextView) {
847:             // TODO: Implement format document functionality
848:             // This would typically call a formatter in EditorCore
849:             print("Format Document: Not yet implemented")
850:         }


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift", "start_line": 1, "end_line": 200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift (lines 2-200 of 357)
────────────────────────────────────────
2: import Foundation
3: 
4: // Type aliases for external use
5: typealias AutocompleteSuggestion = AutocompleteManager.Suggestion
6: typealias AutocompleteSuggestionKind = AutocompleteManager.SuggestionKind
7: 
8: /// FEAT-045/046/047
9: /// - Basic autocomplete dropdown state (showSuggestions/selectedIndex)
10: /// - Current file symbol extraction
11: /// - Swift stdlib completions (top-level + a small set of member completions)
12: final class AutocompleteManager: ObservableObject {
13: 
14:     // MARK: - UI-facing legacy API (kept for existing views)
15: 
16:     /// A simple list used by existing UI.
17:     @Published var suggestions: [String] = []
18:     @Published var showSuggestions = false
19:     @Published var selectedIndex = 0
20: 
21:     // MARK: - Rich suggestion model (for future UI)
22: 
23:     enum SuggestionKind: String, Hashable {
24:         case keyword
25:         case stdlib
26:         case symbol
27:         case member
28:     }
29: 
30:     struct Suggestion: Identifiable, Hashable {
31:         var id: String { "\(kind.rawValue):\(insertText)" }
32:         let kind: SuggestionKind
33:         let displayText: String
34:         let insertText: String
35:         let score: Int
36: 
37:         init(kind: SuggestionKind, displayText: String, insertText: String? = nil, score: Int) {
38:             self.kind = kind
39:             self.displayText = displayText
40:             self.insertText = insertText ?? displayText
41:             self.score = score
42:         }
43:     }
44: 
45:     /// Structured suggestions (not currently required by UI, but provides plumbing).
46:     @Published private(set) var suggestionItems: [Suggestion] = []
47: 
48:     // MARK: - Completion sources
49: 
50:     private let keywords: [String] = [
51:         "import", "func", "var", "let", "class", "struct", "enum",
52:         "if", "else", "for", "while", "switch", "case", "return",
53:         "true", "false", "nil", "self", "super", "init", "deinit",
54:         "extension", "protocol", "typealias", "static", "private",
55:         "public", "internal", "fileprivate", "open", "final",
56:         "guard", "defer", "break", "continue", "fallthrough",
57:         "throws", "throw", "try", "catch", "do", "as", "is",
58:         "in", "where", "associatedtype", "mutating", "nonmutating",
59:         "convenience", "required", "override"
60:     ]
61: 
62:     private let stdlibTopLevel: [String] = [
63:         // Common types
64:         "Any", "AnyObject", "Never", "Void",
65:         "Bool",
66:         "Int", "Int8", "Int16", "Int32", "Int64",
67:         "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
68:         "Float", "Double",
69:         "String", "Character", "Substring",
70:         "Array", "Dictionary", "Set", "Optional", "Result",
71: 
72:         // Common protocols
73:         "Equatable", "Hashable", "Comparable",
74:         "Sequence", "Collection", "BidirectionalCollection", "RandomAccessCollection",
75:         "IteratorProtocol",
76:         "Encodable", "Decodable", "Codable",
77:         "Identifiable", "CaseIterable",
78:         "Error",
79: 
80:         // Concurrency (Swift stdlib)
81:         "Task", "MainActor", "Actor", "Sendable",
82: 
83:         // Common functions
84:         "print", "debugPrint", "dump",
85:         "assert", "assertionFailure", "precondition", "preconditionFailure", "fatalError",
86:         "min", "max", "abs", "zip", "stride"
87:     ]
88: 
89:     private let memberCompletions: [String: [String]] = [
90:         "String": [
91:             "count", "isEmpty", "startIndex", "endIndex",
92:             "uppercased()", "lowercased()",
93:             "hasPrefix(\"\")", "hasSuffix(\"\")",
94:             "contains(\"\")",
95:             "split(separator:)",
96:             "trimmingCharacters(in:)",
97:             "replacingOccurrences(of:with:)",
98:             "prefix(_:)", "suffix(_:)", "dropFirst()", "dropLast()"
99:         ],
100:         "Array": [
101:             "count", "isEmpty", "first", "last",
102:             "append(_:)", "insert(_:at:)",
103:             "removeLast()", "removeAll()",
104:             "map(_:)", "compactMap(_:)", "flatMap(_:)", "filter(_:)", "reduce(_:_:)",
105:             "forEach(_:)", "sorted()", "sorted(by:)"
106:         ],
107:         "Dictionary": [
108:             "count", "isEmpty", "keys", "values",
109:             "updateValue(_:forKey:)", "removeValue(forKey:)",
110:             "mapValues(_:)"
111:         ],
112:         "Set": [
113:             "count", "isEmpty",
114:             "insert(_:)", "remove(_:)", "contains(_:)",
115:             "union(_:)", "intersection(_:)", "subtracting(_:)"
116:         ],
117:         "Optional": [
118:             "map(_:)", "flatMap(_:)"
119:         ],
120:         "Result": [
121:             "get()", "map(_:)", "mapError(_:)"
122:         ]
123:     ]
124: 
125:     // MARK: - Public API
126: 
127:     /// Updates suggestions based on the current text and cursor.
128:     ///
129:     /// FEAT-046: extracts symbols from `text` and mixes them into the suggestion list.
130:     /// FEAT-047: adds a curated set of Swift stdlib completions.
131:     func updateSuggestions(for text: String, cursorPosition: Int) {
132:         let safeCursor = max(0, min(cursorPosition, text.count))
133:         guard let context = completionContext(in: text, cursorPosition: safeCursor) else {
134:             apply(items: [])
135:             return
136:         }
137: 
138:         let prefixLower = context.prefix.lowercased()
139:         guard !prefixLower.isEmpty else {
140:             // If user just typed a dot, show members even with empty prefix.
141:             if context.isMemberCompletion, let base = context.memberBase {
142:                 let members = memberCandidates(forBase: base)
143:                 let items = members.map { Suggestion(kind: .member, displayText: $0, score: 1000) }
144:                 apply(items: items)
145:             } else {
146:                 apply(items: [])
147:             }
148:             return
149:         }
150: 
151:         var candidates: [Suggestion] = []
152: 
153:         // FEAT-046: current file symbols
154:         let symbols = extractSymbols(from: text)
155:         candidates.append(contentsOf: symbols
156:             .filter { $0.lowercased().hasPrefix(prefixLower) }
157:             .map { Suggestion(kind: .symbol, displayText: $0, score: 900) })
158: 
159:         // Keywords
160:         candidates.append(contentsOf: keywords
161:             .filter { $0.lowercased().hasPrefix(prefixLower) }
162:             .map { Suggestion(kind: .keyword, displayText: $0, score: 800) })
163: 
164:         // FEAT-047: Swift stdlib (top level)
165:         candidates.append(contentsOf: stdlibTopLevel
166:             .filter { $0.lowercased().hasPrefix(prefixLower) }
167:             .map { Suggestion(kind: .stdlib, displayText: $0, score: 700) })
168: 
169:         // Member completions (very small heuristic-based set)
170:         if context.isMemberCompletion, let base = context.memberBase {
171:             let members = memberCandidates(forBase: base)
172:             candidates.append(contentsOf: members
173:                 .filter { $0.lowercased().hasPrefix(prefixLower) }
174:                 .map { Suggestion(kind: .member, displayText: $0, score: 1000) })
175:         }
176: 
177:         // De-dupe + rank
178:         let merged = mergeAndSort(candidates)
179:         apply(items: merged)
180:     }
181: 
182:     func selectNext() {
183:         guard showSuggestions else { return }
184:         if selectedIndex < suggestions.count - 1 {
185:             selectedIndex += 1
186:         }
187:     }
188: 
189:     func selectPrevious() {
190:         guard showSuggestions else { return }
191:         if selectedIndex > 0 {
192:             selectedIndex -= 1
193:         }
194:     }
195: 
196:     func getCurrentSuggestion() -> String? {
197:         guard showSuggestions, selectedIndex < suggestions.count else { return nil }
198:         return suggestions[selectedIndex]
199:     }
200: 


Let me look at the updateLineCount and updateCursorPosition methods more closely, and trace how they might be causing redundant work:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 649, "end_line": 750}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 650-750 of 2289)
────────────────────────────────────────
650:             // PERF: Count newlines directly instead of creating array copy
651:             let text = textView.text ?? ""
652:             var lineCount = 1
653:             for char in text {
654:                 if char == "\n" {
655:                     lineCount += 1
656:                 }
657:             }
658:             DispatchQueue.main.async {
659:                 self.parent.totalLines = lineCount
660:             }
661:         }
662:         
663:         func updateCursorPosition(_ textView: UITextView) {
664:             guard let selectedRange = textView.selectedTextRange else { return }
665:             let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
666:             
667:             // PERF: Count newlines directly instead of creating substring + array
668:             let text = textView.text ?? ""
669:             var lineNumber = 1
670:             var columnStart = 0
671:             
672:             let endIndex = text.index(text.startIndex, offsetBy: min(cursorPosition, text.count), limitedBy: text.endIndex) ?? text.endIndex
673:             for (i, char) in text[..<endIndex].enumerated() {
674:                 if char == "\n" {
675:                     lineNumber += 1
676:                     columnStart = i + 1
677:                 }
678:             }
679:             
680:             let column = cursorPosition - columnStart + 1
681:             
682:             DispatchQueue.main.async {
683:                 self.parent.currentLineNumber = lineNumber
684:                 self.parent.currentColumn = column
685:                 self.parent.cursorIndex = cursorPosition
686:             }
687:         }
688:         
689:         func updateScrollPosition(_ textView: UITextView) {
690:             guard let font = textView.font else { return }
691:             let lineHeight = font.lineHeight
692:             let yOffset = textView.contentOffset.y
693:             let line = Int(yOffset / lineHeight)
694: 
695:             // Update lastKnownScrollPosition synchronously to prevent feedback loops
696:             lastKnownScrollPosition = line
697:             
698:             // Defer @Binding updates to avoid "Publishing changes from within view updates"
699:             DispatchQueue.main.async {
700:                 self.parent.scrollPosition = line
701:                 self.parent.scrollOffset = yOffset
702:             }
703:         }
704:         
705:         func scrollToLine(_ line: Int, in textView: UITextView) {
706:             guard !isUpdatingFromMinimap else { return }
707:             isUpdatingFromMinimap = true
708:             
709:             let lines = textView.text.components(separatedBy: .newlines)
710:             guard line >= 0 && line < lines.count else {
711:                 isUpdatingFromMinimap = false
712:                 return
713:             }
714:             
715:             var characterPosition = 0
716:             for i in 0..<line {
717:                 characterPosition += lines[i].count + 1
718:             }
719:             
720:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
721:                 let rect = textView.caretRect(for: position)
722:                 let targetY = max(0, rect.origin.y)
723:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
724:             }
725:             
726:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
727:                 self.isUpdatingFromMinimap = false
728:             }
729:         }
730: 
731:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
732:             let lines = textView.text.components(separatedBy: .newlines)
733:             guard line >= 0 && line < lines.count else { return }
734: 
735:             var characterPosition = 0
736:             for i in 0..<line {
737:                 characterPosition += lines[i].count + 1
738:             }
739: 
740:             // FEAT-041: select entire line (excluding trailing newline)
741:             let lineLength = (lines[line] as NSString).length
742:             let range = NSRange(location: characterPosition, length: lineLength)
743:             textView.selectedRange = range
744: 
745:             // Ensure it's visible
746:             scrollToLine(line, in: textView)
747: 
748:             // Update SwiftUI state
749:             updateCursorPosition(textView)
750:             updateScrollPosition(textView)


Now let me check the EditorCore.updateSelection and understand what work happens there:

>>>TOOL search
{"query": "func updateSelection", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:701: func updateSelection(range: NSRange?, text: String) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift", "start_line": 695, "end_line": 770}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 696-770 of 790)
────────────────────────────────────────
696:         currentSelectionRange = nil
697:         currentSelection = ""
698:     }
699: 
700:     /// Update selection from text view
701:     func updateSelection(range: NSRange?, text: String) {
702:         currentSelectionRange = range
703:         if let range = range, range.length > 0,
704:            let index = activeTabIndex {
705:             let content = tabs[index].content
706:             if let swiftRange = Range(range, in: content) {
707:                 currentSelection = String(content[swiftRange])
708:             }
709:         } else {
710:             currentSelection = ""
711:         }
712:     }
713: 
714:     /// Find word boundaries at a given position
715:     func findWordAtPosition(_ position: Int, in text: String) -> NSRange? {
716:         guard position >= 0 && position <= text.count else { return nil }
717: 
718:         let nsText = text as NSString
719:         let wordCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
720: 
721:         // Find start of word
722:         var start = position
723:         while start > 0 {
724:             let char = nsText.substring(with: NSRange(location: start - 1, length: 1))
725:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
726:                 start -= 1
727:             } else {
728:                 break
729:             }
730:         }
731: 
732:         // Find end of word
733:         var end = position
734:         while end < nsText.length {
735:             let char = nsText.substring(with: NSRange(location: end, length: 1))
736:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
737:                 end += 1
738:             } else {
739:                 break
740:             }
741:         }
742: 
743:         if start == end {
744:             return nil
745:         }
746: 
747:         return NSRange(location: start, length: end - start)
748:     }
749: 
750:     /// Escape multi-cursor mode
751:     func escapeMultiCursor() {
752:         if multiCursorState.isMultiCursor {
753:             if let primary = multiCursorState.primaryCursor {
754:                 resetToSingleCursor(at: primary.position)
755:             }
756:         }
757:     }
758: 
759:     // MARK: - Code Folding
760: 
761:     /// Collapse all foldable regions in the active editor
762:     func collapseAllFolds() {
763:         guard let index = activeTabIndex else { return }
764:         // Post notification that will be picked up by the editor view
765:         NotificationCenter.default.post(
766:             name: .collapseAllFolds,
767:             object: nil,
768:             userInfo: ["tabId": tabs[index].id]
769:         )
770:     }


Let me check the AutocompleteManager.updateSuggestions and extractSymbols to see how expensive they are:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift", "start_line": 230, "end_line": 357}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift (lines 231-357 of 357)
────────────────────────────────────────
231:     private func completionContext(in text: String, cursorPosition: Int) -> CompletionContext? {
232:         guard !text.isEmpty else { return nil }
233:         
234:         // Safety check: ensure cursorPosition is within bounds
235:         let safeCursor = max(0, min(cursorPosition, text.count))
236:         let cursorIndex = text.index(text.startIndex, offsetBy: safeCursor)
237: 
238:         // Find start of current identifier (letters/digits/_).
239:         var start = cursorIndex
240:         while start > text.startIndex {
241:             let prev = text.index(before: start)
242:             if isIdentifierChar(text[prev]) {
243:                 start = prev
244:             } else {
245:                 break
246:             }
247:         }
248: 
249:         let prefix = String(text[start..<cursorIndex])
250: 
251:         // Member completion if immediately preceded by '.'
252:         var isMember = false
253:         var memberBase: String? = nil
254: 
255:         if start > text.startIndex {
256:             let dotIndex = text.index(before: start)
257:             if text[dotIndex] == "." {
258:                 isMember = true
259: 
260:                 // Parse identifier before '.'
261:                 var baseEnd = dotIndex
262:                 var baseStart = baseEnd
263:                 while baseStart > text.startIndex {
264:                     let prev = text.index(before: baseStart)
265:                     if isIdentifierChar(text[prev]) {
266:                         baseStart = prev
267:                     } else {
268:                         break
269:                     }
270:                 }
271:                 let base = String(text[baseStart..<baseEnd])
272:                 if !base.isEmpty {
273:                     memberBase = base
274:                 }
275:             }
276:         }
277: 
278:         return CompletionContext(prefix: prefix,
279:                                  replacementRange: start..<cursorIndex,
280:                                  isMemberCompletion: isMember,
281:                                  memberBase: memberBase)
282:     }
283: 
284:     private func isIdentifierChar(_ c: Character) -> Bool {
285:         // Swift identifiers are more complex, but this is enough for basic autocomplete.
286:         return c.isLetter || c.isNumber || c == "_"
287:     }
288: 
289:     private func memberCandidates(forBase base: String) -> [String] {
290:         // Basic heuristic: only match known stdlib types by exact name.
291:         if let members = memberCompletions[base] { return members }
292:         return []
293:     }
294: 
295:     private func extractSymbols(from text: String) -> [String] {
296:         // Very lightweight symbol extraction: looks for common declarations.
297:         // Intentionally best-effort; keeps FEAT-046 self-contained.
298:         var results = Set<String>()
299: 
300:         func addMatches(pattern: String) {
301:             guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
302:             let ns = text as NSString
303:             let range = NSRange(location: 0, length: ns.length)
304:             regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
305:                 guard let match, match.numberOfRanges >= 2 else { return }
306:                 let nameRange = match.range(at: 1)
307:                 guard nameRange.location != NSNotFound else { return }
308:                 let name = ns.substring(with: nameRange)
309:                 if !name.isEmpty { results.insert(name) }
310:             }
311:         }
312: 
313:         // func Foo
314:         addMatches(pattern: "\\bfunc\\s+([A-Za-z_][A-Za-z0-9_]*)")
315:         // class/struct/enum/protocol/typealias Foo
316:         addMatches(pattern: "\\b(?:class|struct|enum|protocol|typealias)\\s+([A-Za-z_][A-Za-z0-9_]*)")
317:         // let/var foo (captures first name before : = , )
318:         addMatches(pattern: "\\b(?:let|var)\\s+([A-Za-z_][A-Za-z0-9_]*)(?=\\s*[:=,])")
319: 
320:         return results.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
321:     }
322: 
323:     private func mergeAndSort(_ items: [Suggestion]) -> [Suggestion] {
324:         // Keep highest-scored entry per id.
325:         var bestById: [String: Suggestion] = [:]
326:         for item in items {
327:             if let existing = bestById[item.id] {
328:                 if item.score > existing.score {
329:                     bestById[item.id] = item
330:                 }
331:             } else {
332:                 bestById[item.id] = item
333:             }
334:         }
335: 
336:         return bestById.values.sorted {
337:             if $0.score != $1.score { return $0.score > $1.score }
338:             return $0.displayText.localizedCaseInsensitiveCompare($1.displayText) == .orderedAscending
339:         }
340:     }
341: 
342:     private func apply(items: [Suggestion]) {
343:         suggestionItems = items
344:         suggestions = items.map { $0.displayText }
345:         showSuggestions = !items.isEmpty
346:         selectedIndex = 0
347:     }
348: }
349: 
350: // MARK: - Safe Array Access
351: 
352: private extension Array {
353:     subscript(safe index: Int) -> Element? {
354:         indices.contains(index) ? self[index] : nil
355:     }
356: }
357: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift", "start_line": 695, "end_line": 770}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 696-770 of 790)
────────────────────────────────────────
696:         currentSelectionRange = nil
697:         currentSelection = ""
698:     }
699: 
700:     /// Update selection from text view
701:     func updateSelection(range: NSRange?, text: String) {
702:         currentSelectionRange = range
703:         if let range = range, range.length > 0,
704:            let index = activeTabIndex {
705:             let content = tabs[index].content
706:             if let swiftRange = Range(range, in: content) {
707:                 currentSelection = String(content[swiftRange])
708:             }
709:         } else {
710:             currentSelection = ""
711:         }
712:     }
713: 
714:     /// Find word boundaries at a given position
715:     func findWordAtPosition(_ position: Int, in text: String) -> NSRange? {
716:         guard position >= 0 && position <= text.count else { return nil }
717: 
718:         let nsText = text as NSString
719:         let wordCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
720: 
721:         // Find start of word
722:         var start = position
723:         while start > 0 {
724:             let char = nsText.substring(with: NSRange(location: start - 1, length: 1))
725:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
726:                 start -= 1
727:             } else {
728:                 break
729:             }
730:         }
731: 
732:         // Find end of word
733:         var end = position
734:         while end < nsText.length {
735:             let char = nsText.substring(with: NSRange(location: end, length: 1))
736:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
737:                 end += 1
738:             } else {
739:                 break
740:             }
741:         }
742: 
743:         if start == end {
744:             return nil
745:         }
746: 
747:         return NSRange(location: start, length: end - start)
748:     }
749: 
750:     /// Escape multi-cursor mode
751:     func escapeMultiCursor() {
752:         if multiCursorState.isMultiCursor {
753:             if let primary = multiCursorState.primaryCursor {
754:                 resetToSingleCursor(at: primary.position)
755:             }
756:         }
757:     }
758: 
759:     // MARK: - Code Folding
760: 
761:     /// Collapse all foldable regions in the active editor
762:     func collapseAllFolds() {
763:         guard let index = activeTabIndex else { return }
764:         // Post notification that will be picked up by the editor view
765:         NotificationCenter.default.post(
766:             name: .collapseAllFolds,
767:             object: nil,
768:             userInfo: ["tabId": tabs[index].id]
769:         )
770:     }


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services"}
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
   ThemeManager.swift.bak
   WindowStateManager.swift
   WorkspaceManager.swift
   WorkspaceTrustManager.swift


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift", "start_line": 690, "end_line": 780}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 691-780 of 790)
────────────────────────────────────────
691:     }
692: 
693:     /// Reset to single cursor
694:     func resetToSingleCursor(at position: Int) {
695:         multiCursorState.reset(to: position)
696:         currentSelectionRange = nil
697:         currentSelection = ""
698:     }
699: 
700:     /// Update selection from text view
701:     func updateSelection(range: NSRange?, text: String) {
702:         currentSelectionRange = range
703:         if let range = range, range.length > 0,
704:            let index = activeTabIndex {
705:             let content = tabs[index].content
706:             if let swiftRange = Range(range, in: content) {
707:                 currentSelection = String(content[swiftRange])
708:             }
709:         } else {
710:             currentSelection = ""
711:         }
712:     }
713: 
714:     /// Find word boundaries at a given position
715:     func findWordAtPosition(_ position: Int, in text: String) -> NSRange? {
716:         guard position >= 0 && position <= text.count else { return nil }
717: 
718:         let nsText = text as NSString
719:         let wordCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
720: 
721:         // Find start of word
722:         var start = position
723:         while start > 0 {
724:             let char = nsText.substring(with: NSRange(location: start - 1, length: 1))
725:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
726:                 start -= 1
727:             } else {
728:                 break
729:             }
730:         }
731: 
732:         // Find end of word
733:         var end = position
734:         while end < nsText.length {
735:             let char = nsText.substring(with: NSRange(location: end, length: 1))
736:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
737:                 end += 1
738:             } else {
739:                 break
740:             }
741:         }
742: 
743:         if start == end {
744:             return nil
745:         }
746: 
747:         return NSRange(location: start, length: end - start)
748:     }
749: 
750:     /// Escape multi-cursor mode
751:     func escapeMultiCursor() {
752:         if multiCursorState.isMultiCursor {
753:             if let primary = multiCursorState.primaryCursor {
754:                 resetToSingleCursor(at: primary.position)
755:             }
756:         }
757:     }
758: 
759:     // MARK: - Code Folding
760: 
761:     /// Collapse all foldable regions in the active editor
762:     func collapseAllFolds() {
763:         guard let index = activeTabIndex else { return }
764:         // Post notification that will be picked up by the editor view
765:         NotificationCenter.default.post(
766:             name: .collapseAllFolds,
767:             object: nil,
768:             userInfo: ["tabId": tabs[index].id]
769:         )
770:     }
771: 
772:     /// Expand all collapsed regions in the active editor
773:     func expandAllFolds() {
774:         guard let index = activeTabIndex else { return }
775:         // Post notification that will be picked up by the editor view
776:         NotificationCenter.default.post(
777:             name: .expandAllFolds,
778:             object: nil,
779:             userInfo: ["tabId": tabs[index].id]
780:         )


Now let me search for any synchronous operations that might happen during typing:

>>>TOOL search
{"query": "attributedText =", "glob": "VSCodeiPadOS/**/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 5 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:440: let attributedText = highlighter.highlight(text, filename: filename)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:450: textView.attributedText = attributedText
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:550: textView.attributedText = fullAttributed
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:766: let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:778: textView.attributedText = attributedText


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 755, "end_line": 800}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 756-800 of 2289)
────────────────────────────────────────
756:             // Guard against reentrancy - this can happen if attributedText assignment
757:             // triggers delegate callbacks that call this method again
758:             guard !isApplyingHighlighting else { return }
759:             isApplyingHighlighting = true
760:             defer { isApplyingHighlighting = false }
761:             
762:             let theme = ThemeManager.shared.currentTheme
763:             lastThemeId = theme.id
764: 
765:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
766:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
767: 
768:             let selectedRange = textView.selectedRange
769: 
770:             // NOTE: We intentionally do NOT manipulate undoManager.disableUndoRegistration/enableUndoRegistration
771:             // here. UITextView's internal undo manager state machine is fragile and can crash with
772:             // "enableUndoRegistration may only be invoked with matching call to disableUndoRegistration"
773:             // when attributedText assignment triggers internal undo callbacks.
774:             // 
775:             // Instead, we let the system handle undo naturally. The trade-off is that syntax highlighting
776:             // changes might add noise to the undo stack, but this is preferable to crashing.
777:             
778:             textView.attributedText = attributedText
779:             textView.selectedRange = selectedRange
780: 
781:             // Set typing attributes so newly typed characters have correct base styling
782:             // This prevents flicker during the debounce period before full highlighting runs
783:             let fontSize = parent.editorCore.editorFontSize
784:             textView.typingAttributes = [
785:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
786:                 .foregroundColor: UIColor(theme.editorForeground)
787:             ]
788: 
789:             // FEAT-044: restore matching bracket highlight after re-attributing text
790:             updateMatchingBracketHighlight(textView)
791:         }
792:         
793:         func handlePeekDefinition(in textView: UITextView) {
794:             guard let selectedRange = textView.selectedTextRange else { return }
795:             let text = textView.text ?? ""
796:             
797:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
798:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
799:                  
800:                  let prefix = String(text.prefix(location))


Let me look at the autocomplete triggering more closely - specifically how often extractSymbols runs:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift", "start_line": 125, "end_line": 180}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift (lines 126-180 of 357)
────────────────────────────────────────
126: 
127:     /// Updates suggestions based on the current text and cursor.
128:     ///
129:     /// FEAT-046: extracts symbols from `text` and mixes them into the suggestion list.
130:     /// FEAT-047: adds a curated set of Swift stdlib completions.
131:     func updateSuggestions(for text: String, cursorPosition: Int) {
132:         let safeCursor = max(0, min(cursorPosition, text.count))
133:         guard let context = completionContext(in: text, cursorPosition: safeCursor) else {
134:             apply(items: [])
135:             return
136:         }
137: 
138:         let prefixLower = context.prefix.lowercased()
139:         guard !prefixLower.isEmpty else {
140:             // If user just typed a dot, show members even with empty prefix.
141:             if context.isMemberCompletion, let base = context.memberBase {
142:                 let members = memberCandidates(forBase: base)
143:                 let items = members.map { Suggestion(kind: .member, displayText: $0, score: 1000) }
144:                 apply(items: items)
145:             } else {
146:                 apply(items: [])
147:             }
148:             return
149:         }
150: 
151:         var candidates: [Suggestion] = []
152: 
153:         // FEAT-046: current file symbols
154:         let symbols = extractSymbols(from: text)
155:         candidates.append(contentsOf: symbols
156:             .filter { $0.lowercased().hasPrefix(prefixLower) }
157:             .map { Suggestion(kind: .symbol, displayText: $0, score: 900) })
158: 
159:         // Keywords
160:         candidates.append(contentsOf: keywords
161:             .filter { $0.lowercased().hasPrefix(prefixLower) }
162:             .map { Suggestion(kind: .keyword, displayText: $0, score: 800) })
163: 
164:         // FEAT-047: Swift stdlib (top level)
165:         candidates.append(contentsOf: stdlibTopLevel
166:             .filter { $0.lowercased().hasPrefix(prefixLower) }
167:             .map { Suggestion(kind: .stdlib, displayText: $0, score: 700) })
168: 
169:         // Member completions (very small heuristic-based set)
170:         if context.isMemberCompletion, let base = context.memberBase {
171:             let members = memberCandidates(forBase: base)
172:             candidates.append(contentsOf: members
173:                 .filter { $0.lowercased().hasPrefix(prefixLower) }
174:                 .map { Suggestion(kind: .member, displayText: $0, score: 1000) })
175:         }
176: 
177:         // De-dupe + rank
178:         let merged = mergeAndSort(candidates)
179:         apply(items: merged)
180:     }


Now let me check the foldingManager.detectFoldableRegions to see what that does on every text change:

>>>TOOL search
{"query": "func detectFoldableRegions", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:83: func detectFoldableRegions(in code: String, filePath: String? = nil) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 75, "end_line": 200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 76-200 of 931)
────────────────────────────────────────
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


Let me also check what happens in `updateActiveTabContent`:

>>>TOOL search
{"query": "func updateActiveTabContent", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift:259: func updateActiveTabContent(_ content: String) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift", "start_line": 255, "end_line": 320}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 256-320 of 790)
────────────────────────────────────────
256: 
257:     // MARK: - Content Management
258: 
259:     func updateActiveTabContent(_ content: String) {
260:         guard let index = activeTabIndex else { return }
261: 
262:         // Avoid marking a tab dirty when we're just syncing state (e.g., initial onAppear assignment).
263:         guard tabs[index].content != content else { return }
264: 
265:         tabs[index].content = content
266: 
267:         // Mark dirty for both saved and unsaved-new files.
268:         tabs[index].isUnsaved = true
269:     }
270: 
271:     func saveActiveTab() {
272:         guard let index = activeTabIndex,
273:               let url = tabs[index].url else { return }
274: 
275:         do {
276:             if let fileNavigator {
277:                 try fileNavigator.writeFile(at: url, content: tabs[index].content)
278:             } else {
279:                 // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
280:                 let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
281:                 defer { if didStart { url.stopAccessingSecurityScopedResource() } }
282:                 try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
283:             }
284: 
285:             tabs[index].isUnsaved = false
286:         } catch {
287:             print("Error saving file: \(error)")
288:         }
289:     }
290: 
291:     func saveAllTabs() {
292:         for index in tabs.indices {
293:             guard let url = tabs[index].url, tabs[index].isUnsaved else { continue }
294: 
295:             do {
296:                 if let fileNavigator {
297:                     try fileNavigator.writeFile(at: url, content: tabs[index].content)
298:                 } else {
299:                     // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
300:                     let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
301:                     defer { if didStart { url.stopAccessingSecurityScopedResource() } }
302:                     try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
303:                 }
304: 
305:                 tabs[index].isUnsaved = false
306:             } catch {
307:                 print("Error saving file: \(error)")
308:             }
309:         }
310:     }
311: 
312:     // MARK: - File Operations
313: 
314:     /// Retain security scoped access for as long as a tab referencing the URL is open.
315:     /// - Returns: `true` if access was retained (either already retained or started successfully).
316:     @discardableResult
317:     private func retainSecurityScopedAccess(to url: URL) -> Bool {
318:         if let count = securityScopedAccessCounts[url] {
319:             securityScopedAccessCounts[url] = count + 1
320:             return true


Now let me verify there's no debouncing on the autocomplete/folding in ContentView:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 475, "end_line": 510}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 476-510 of 1079)
────────────────────────────────────────
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


Now I have enough information to provide a comprehensive analysis. Let me summarize my findings:

>>>REPORT
# UITextViewDelegate Lag Analysis - SyntaxHighlightingTextView

## COMPLETE KEYSTROKE FLOW DIAGRAM

When user types ONE character, this cascade occurs:

```
1. UITextView receives keystroke
   ↓
2. textViewDidChange(_ textView:) [Line 373]
   ├── parent.text = textView.text              → TRIGGERS SwiftUI binding
   ├── Sets typingAttributes                     → Minor
   ├── Schedules debounced highlighting          → OK (80-1500ms depending on size)
   ├── updateLineCount(textView)                 → O(n) - iterates ENTIRE text
   └── updateCursorPosition(textView)            → O(n) - iterates text to cursor
       ↓
3. SwiftUI's onChange(of: text) fires [ContentView:497]
   ├── editorCore.updateActiveTabContent()       → Minor (string comparison)
   ├── editorCore.cursorPosition = ...           → Minor
   ├── autocomplete.updateSuggestions()          → 🔴 EXPENSIVE: runs 3 regex patterns on ENTIRE file
   └── foldingManager.detectFoldableRegions()    → 🔴 VERY EXPENSIVE: full AST-like parse, O(n) line-by-line
       ↓
4. textViewDidChangeSelection(_ textView:) [Line 563] - ALSO fires
   ├── updateCursorPosition(textView)            → 🔴 DUPLICATE O(n) iteration
   ├── updateScrollPosition(textView)            → Minor
   ├── Schedules bracketMatchDebouncer (100ms)   → OK (debounced)
   ├── DispatchQueue.main.async:
   │   └── parent.editorCore.updateSelection()   → Minor
   └── Potentially: (textView as? EditorTextView)?.setNeedsDisplay()
       ↓
5. SwiftUI's onChange(of: cursorIndex) fires [ContentView:504]
   └── autocomplete.updateSuggestions()          → 🔴 DUPLICATE: regex on ENTIRE file AGAIN
```

## IDENTIFIED BOTTLENECKS

### 1. **CRITICAL: foldingManager.detectFoldableRegions() - NO DEBOUNCING** [ContentView:502]
- Runs on EVERY keystroke synchronously on main thread
- Parses entire file line-by-line looking for functions, classes, comments, imports
- Code: `code.components(separatedBy: .newlines)` creates array copy
- Complexity: O(n) where n = lines, with multiple regex/string operations per line

### 2. **CRITICAL: autocomplete.updateSuggestions() runs TWICE per keystroke**
- First: onChange(of: text) [Line 500]
- Second: onChange(of: cursorIndex) [Line 505]
- Each call runs `extractSymbols(from: text)` [AutocompleteManager:154] which executes 3 NSRegularExpression patterns on entire file

### 3. **REDUNDANT: updateCursorPosition() called twice**
- First in `textViewDidChange` [Line 423]
- Second in `textViewDidChangeSelection` [Line 565]
- Each call iterates through text up to cursor position: O(cursorPos)

### 4. **REDUNDANT: updateLineCount() iterates entire text** [Line 649-660]
- Called on every keystroke in textViewDidChange
- Iterates character-by-character through entire document

## CONCRETE OPTIMIZATIONS

### Fix 1: Debounce foldingManager.detectFoldableRegions
```swift
// In ContentView - add debouncer
private var foldingDebouncer: Timer?

.onChange(of: text) { newValue in
    editorCore.updateActiveTabContent(newValue)
    // ... existing autocomplete code ...
    
    // DEBOUNCE folding detection - it's expensive and not needed instantly
    foldingDebouncer?.invalidate()
    foldingDebouncer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
        foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path ?? tab.fileName)
    }
}
```

### Fix 2: Remove duplicate autocomplete.updateSuggestions call
```swift
// In ContentView - only update on text change, not cursor change during typing
.onChange(of: cursorIndex) { newCursor in
    // ONLY update if text hasn't just changed (avoid double-update)
    // Could use a flag or timestamp check
}
```

### Fix 3: Remove duplicate updateCursorPosition in textViewDidChange
```swift
// Line 423 in textViewDidChange - REMOVE this call
// updateCursorPosition(textView)  // ← Already called by textViewDidChangeSelection
```

### Fix 4: Cache line count instead of recounting
```swift
// Instead of counting newlines on every change, track incrementally:
// - If character inserted is '\n': totalLines += 1
// - If character deleted is '\n': totalLines -= 1
```

### Fix 5: Add debouncing to AutocompleteManager.updateSuggestions
```swift
// In AutocompleteManager - debounce the expensive extractSymbols
private var suggestionDebouncer: Timer?

func updateSuggestions(for text: String, cursorPosition: Int) {
    suggestionDebouncer?.invalidate()
    suggestionDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
        self?.performUpdateSuggestions(for: text, cursorPosition: cursorPosition)
    }
}
```

## FILES EXAMINED
- VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (Lines 321-800)
- VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (Lines 475-510)
- VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift (Lines 125-320)
- VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (Lines 75-200)
- VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (Lines 256-320, 690-750)

## SUMMARY
The primary lag sources are:
1. **foldingManager.detectFoldableRegions()** - expensive, runs synchronously, NO debouncing
2. **autocomplete.updateSuggestions()** - runs TWICE per keystroke (text + cursor change)
3. **updateCursorPosition()** - called redundantly in both delegate methods

The syntax highlighting itself is well-debounced (80ms-1.5s based on file size), but the folding and autocomplete systems are not.
>>>END
