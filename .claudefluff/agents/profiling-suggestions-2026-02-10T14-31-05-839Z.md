# Agent: profiling-suggestions
**Status:** done
**Tokens:** 6,981
**Cost:** $0.0000
**Time:** 2026-02-10T14:31:05.839Z

## Task
CRITICAL: Provide profiling strategy and quick wins for VSCodeiPadOS typing lag.

Read VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift to understand the architecture.

Provide:
1. How to use Instruments Time Profiler to identify the exact bottleneck
2. Quick diagnostic code snippets to add timing measurements
3. List of iOS text editor best practices being violated
4. Compare to how professional iOS code editors handle this (like Runestone, CodeEdit)
5. Radical solutions if incremental fixes aren't enough (e.g., switching to TextKit 2, using custom text rendering)

Report: Actionable profiling plan + list of potential radical fixes if needed.

## Response
I'll analyze the SyntaxHighlightingTextView architecture and provide a comprehensive profiling strategy. Let me start by reading the file.

>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

Let me read more of the file to understand the architecture, especially the text change handling and syntax highlighting logic.

>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-300 of 2289)
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
115:         // Create custom TextKit stack with FoldingLayoutManager for code folding support
116:         let textStorage = NSTextStorage()
117:         let foldingLayoutManager = FoldingLayoutManager()
118:         textStorage.addLayoutManager(foldingLayoutManager)
119:         
120:         let textContainer = NSTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
121:         textContainer.widthTracksTextView = true
122:         foldingLayoutManager.addTextContainer(textContainer)
123:         
124:         let textView = EditorTextView(frame: .zero, textContainer: textContainer)
125:         
126:         // Connect FoldingLayoutManager to EditorTextView
127:         foldingLayoutManager.ownerTextView = textView
128:         
129:         textView.delegate = context.coordinator
130:         textView.editorCore = editorCore
131:         
132:         // Code folding support
133:         textView.foldingManager = CodeFoldingManager.shared
134:         textView.fileId = filename
135: 
136:         // Autocomplete hooks
137:         textView.onAcceptAutocomplete = onAcceptAutocomplete
138:         textView.onDismissAutocomplete = onDismissAutocomplete
139: 
140:         textView.onPeekDefinition = {
141:             context.coordinator.handlePeekDefinition(in: textView)
142:         }
143: 
144:         textView.onEscape = {
145:             context.coordinator.handleEscape()
146:         }
147: 
148:         textView.onGoToLine = {
149:             self.editorCore.showGoToLine = true
150:         }
151:         
152:         // Wire up custom context menu actions
153:         textView.onGoToDefinition = {
154:             context.coordinator.handleGoToDefinition(in: textView)
155:         }
156:         
157:         textView.onFindReferences = {
158:             context.coordinator.handleFindReferences(in: textView)
159:         }
160:         
161:         textView.onFormatDocument = {
162:             context.coordinator.handleFormatDocument(in: textView)
163:         }
164:         
165:         textView.onToggleComment = {
166:             context.coordinator.handleToggleComment(in: textView)
167:         }
168:         
169:         textView.onFold = {
170:             context.coordinator.handleFold(in: textView)
171:         }
172:         
173:         textView.onUnfold = {
174:             context.coordinator.handleUnfold(in: textView)
175:         }
176:         
177:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
178:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
179:         pinchGesture.delegate = context.coordinator
180:         textView.addGestureRecognizer(pinchGesture)
181:         context.coordinator.pinchGesture = pinchGesture
182:         
183:         // Configure text view
184:         textView.isEditable = true
185:         textView.isSelectable = true
186:         textView.autocapitalizationType = .none
187:         textView.autocorrectionType = .no
188:         textView.smartDashesType = .no
189:         textView.smartQuotesType = .no
190:         textView.smartInsertDeleteType = .no
191:         textView.spellCheckingType = .no
192:         
193:         // Set font and appearance (use editorCore.editorFontSize)
194:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
195:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
196:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
197:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
198:         textView.keyboardType = .default
199:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
200:         
201:         // Enable line wrapping
202:         textView.textContainer.lineBreakMode = .byCharWrapping
203:         textView.textContainer.widthTracksTextView = true
204:         
205:         // Calculate line height
206:         if let font = textView.font {
207:             DispatchQueue.main.async {
208:                 self.lineHeight = font.lineHeight
209:             }
210:         }
211:         
212:         // Set initial text with syntax highlighting
213:         textView.text = text
214:         context.coordinator.applySyntaxHighlighting(to: textView)
215:         context.coordinator.updateLineCount(textView)
216:         
217:         return textView
218:     }
219:     
220:     func updateUIView(_ textView: UITextView, context: Context) {
221:         // CRITICAL: Update coordinator's parent reference to current struct
222:         // SwiftUI creates new struct instances on each update, so this keeps
223:         // coordinator in sync with current bindings and properties
224:         context.coordinator.parent = self
225:         
226:         // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
227:         // This fixes the bug where syntax highlighting only appears after typing.
228:         // makeUIView applies it, but the view may not be fully in hierarchy yet,
229:         // causing the attributed text to be lost. This ensures it's applied reliably.
230:         if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
231:             context.coordinator.applySyntaxHighlighting(to: textView)
232:             context.coordinator.hasAppliedInitialHighlighting = true
233:         }
234:         
235:         // Update colors when theme changes
236:         // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor
237:         // as it interferes with attributedText syntax highlighting colors.
238:         // The foreground color is handled entirely by the attributedText.
239:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
240:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
241:         
242:         if let editorView = textView as? EditorTextView {
243:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
244:         }
245:         
246:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
247:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
248:             let selectedRange = textView.selectedRange
249:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
250:             context.coordinator.applySyntaxHighlighting(to: textView)
251:             textView.selectedRange = selectedRange
252:             
253:             // Update line height
254:             if let font = textView.font {
255:                 DispatchQueue.main.async {
256:                     self.lineHeight = font.lineHeight
257:                 }
258:             }
259:         }
260:         
261:         // Update text if changed externally
262:         if textView.text != text {
263:             let selectedRange = textView.selectedRange
264:             textView.text = text
265:             context.coordinator.applySyntaxHighlighting(to: textView)
266:             context.coordinator.hasAppliedInitialHighlighting = true
267:             textView.selectedRange = selectedRange
268:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
269:             // Re-apply highlighting if theme changed
270:             context.coordinator.applySyntaxHighlighting(to: textView)
271:         }
272:         
273:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
274:         // This prevents the editor from fighting against user scroll due to async binding lag
275:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
276:             // Update lastKnownScrollPosition FIRST to prevent race condition
277:             // where user scroll gets overridden by stale binding value
278:             context.coordinator.lastKnownScrollPosition = scrollPosition
279:             context.coordinator.scrollToLine(scrollPosition, in: textView)
280:         }
281: 
282:         // Handle line selection requests (e.g. tapping line numbers)
283:         if let requested = requestedLineSelection,
284:            requested != context.coordinator.lastRequestedLineSelection {
285:             context.coordinator.lastRequestedLineSelection = requested
286:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
287:             // Defer @Binding update to avoid "Publishing changes from within view updates"
288:             DispatchQueue.main.async {
289:                 self.requestedLineSelection = nil
290:             }
291:         }
292: 
293:         // Handle cursor index requests (e.g. accepting autocomplete)
294:         if let requested = requestedCursorIndex,
295:            requested != context.coordinator.lastRequestedCursorIndex {
296:             context.coordinator.lastRequestedCursorIndex = requested
297:             // Use UTF-16 count for NSRange compatibility
298:             let textLength = (textView.text as NSString?)?.length ?? 0
299:             let safeIndex = max(0, min(requested, textLength))
300:             textView.selectedRange = NSRange(location: safeIndex, length: 0)


>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 300, "end_line": 600}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 301-600 of 2289)
────────────────────────────────────────
301:             
302:             // Ensure cursor is visible by scrolling to it
303:             textView.scrollRangeToVisible(textView.selectedRange)
304:             
305:             // Defer @Binding update to avoid "Publishing changes from within view updates"
306:             DispatchQueue.main.async {
307:                 self.requestedCursorIndex = nil
308:             }
309: 
310:             // Update SwiftUI state
311:             context.coordinator.updateCursorPosition(textView)
312:             context.coordinator.updateScrollPosition(textView)
313:         }
314:         
315:         // Note: updateLineCount is called in textViewDidChange, no need to call here
316:         // as it causes unnecessary state churn on every updateUIView
317:     }
318:     
319:     // MARK: - Coordinator
320:     
321:     class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
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


>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 600, "end_line": 900}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 601-900 of 2289)
────────────────────────────────────────
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


>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 900, "end_line": 1200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 901-1200 of 2289)
────────────────────────────────────────
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
1051:         _ layoutManager: NSLayoutManager,
1052:         shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<CGRect>,
1053:         lineFragmentUsedRect: UnsafeMutablePointer<CGRect>,
1054:         baselineOffset: UnsafeMutablePointer<CGFloat>,
1055:         in textContainer: NSTextContainer,
1056:         forGlyphRange glyphRange: NSRange
1057:     ) -> Bool {
1058:         guard let owner = ownerTextView,
1059:               let foldingManager = owner.foldingManager,
1060:               let fileId = owner.fileId
1061:         else {
1062:             return false
1063:         }
1064: 
1065:         // Convert glyphRange -> characterRange so we can compute the line index.
1066:         let charRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
1067:         let loc = max(0, charRange.location)
1068: 
1069:         let full = (self.textStorage?.string ?? "") as NSString
1070:         let lineIndex = FoldingLayoutManager.lineIndex(atUTF16Location: loc, in: full)
1071: 
1072:         if foldingManager.isLineFolded(fileId: fileId, line: lineIndex) {
1073:             // Collapse this visual line fragment.
1074:             lineFragmentRect.pointee.size.height = 0
1075:             lineFragmentUsedRect.pointee.size.height = 0
1076:             baselineOffset.pointee = 0
1077:             return true
1078:         }
1079: 
1080:         return false
1081:     }
1082: 
1083:     private static func lineIndex(atUTF16Location loc: Int, in text: NSString) -> Int {
1084:         if loc <= 0 { return 0 }
1085: 
1086:         let capped = min(loc, text.length)
1087:         var line = 0
1088:         var searchStart = 0
1089: 
1090:         while searchStart < capped {
1091:             let r = text.range(of: "\n", options: [], range: NSRange(location: searchStart, length: capped - searchStart))
1092:             if r.location == NSNotFound { break }
1093:             line += 1
1094:             let next = r.location + 1
1095:             if next >= capped { break }
1096:             searchStart = next
1097:         }
1098: 
1099:         return line
1100:     }
1101: }
1102: 
1103: // Custom text view to handle key commands, indent guides, and line highlighting
1104: class EditorTextView: MultiCursorTextView {
1105:     var onPeekDefinition: (() -> Void)?
1106:     var onEscape: (() -> Void)?
1107:     var onGoToLine: (() -> Void)?
1108:     
1109:     // Custom action closures for context menu
1110:     var onGoToDefinition: (() -> Void)?
1111:     var onFindReferences: (() -> Void)?
1112:     var onFormatDocument: (() -> Void)?
1113:     var onToggleComment: (() -> Void)?
1114:     var onFold: (() -> Void)?
1115:     var onUnfold: (() -> Void)?
1116: 
1117:     // Autocomplete key handling hooks are inherited from MultiCursorTextView
1118:     
1119:     // Code folding support - required by FoldingLayoutManager
1120:     weak var foldingManager: CodeFoldingManager?
1121:     var fileId: String?
1122:     
1123:     // FEAT-039 & FEAT-043
1124:     private var indentGuideColor: UIColor = .separator
1125:     private var activeIndentGuideColor: UIColor = .label
1126:     private var currentLineHighlightColor: UIColor = .clear
1127:     
1128:     // PERF: Cached values to avoid recalculating on every draw()
1129:     private var cachedTabSize: Int = 4
1130:     private var cachedSpaceWidth: CGFloat = 0
1131:     private var cachedIndentWidth: CGFloat = 0
1132:     private var lastCachedFont: UIFont?
1133:     
1134:     override init(frame: CGRect, textContainer: NSTextContainer?) {
1135:         super.init(frame: frame, textContainer: textContainer)
1136:         setup()
1137:     }
1138:     
1139:     required init?(coder: NSCoder) {
1140:         super.init(coder: coder)
1141:         setup()
1142:     }
1143:     
1144:     private func setup() {
1145:         // Ensure we redraw when bounds/selection change
1146:         contentMode = .redraw
1147:         updateCachedMeasurements()
1148:     }
1149:     
1150:     /// PERF: Update cached measurements - call when font changes
1151:     func updateCachedMeasurements() {
1152:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
1153:         cachedTabSize = storedTabSize > 0 ? storedTabSize : 4
1154:         
1155:         if let font = self.font, font != lastCachedFont {
1156:             cachedSpaceWidth = " ".size(withAttributes: [.font: font]).width
1157:             cachedIndentWidth = cachedSpaceWidth * CGFloat(cachedTabSize)
1158:             lastCachedFont = font
1159:         }
1160:     }
1161:     
1162:     func updateThemeColors(theme: Theme) {
1163:         self.indentGuideColor = UIColor(theme.indentGuide)
1164:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
1165:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
1166:         setNeedsDisplay()
1167:     }
1168:     
1169:     override func draw(_ rect: CGRect) {
1170:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
1171:             super.draw(rect)
1172:             return
1173:         }
1174:         
1175:         // 1. Draw Current Line Highlight (FEAT-043)
1176:         if let selectedRange = selectedTextRange {
1177:             // Get the line rect for the cursor position
1178:             let caretRect = self.caretRect(for: selectedRange.start)
1179:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
1180:             
1181:             context.setFillColor(currentLineHighlightColor.cgColor)
1182:             context.fill(lineRect)
1183:         }
1184:         
1185:         // 2. Draw Text (super implementation)
1186:         super.draw(rect)
1187:         
1188:         // 3. Draw Indent Guides (FEAT-039)
1189:         // We iterate visible lines and draw vertical lines for indentation
1190:         // Optimization: Only draw for visible range
1191: 
1192:         context.setLineWidth(1.0)
1193: 
1194:         // PERF: Use cached values instead of recalculating on every draw
1195:         // Update cache if font changed
1196:         if font != lastCachedFont {
1197:             updateCachedMeasurements()
1198:         }
1199:         let tabSize = cachedTabSize
1200:         let indentWidth = cachedIndentWidth


>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 700, "end_line": 900}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 701-900 of 2289)
────────────────────────────────────────
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


Now let me look at the syntax highlighter implementation:

>>>TOOL search
{"query": "VSCodeSyntaxHighlighter highlight", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "VSCodeSyntaxHighlighter highlight"


>>>TOOL search
{"query": "class VSCodeSyntaxHighlighter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class VSCodeSyntaxHighlighter"


>>>TOOL search
{"query": "class VSCodeSyntaxHighlighter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class VSCodeSyntaxHighlighter"


>>>TOOL search
{"query": "VSCodeSyntaxHighlighter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "VSCodeSyntaxHighlighter"


>>>TOOL search
{"query": "SyntaxHighlighter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "SyntaxHighlighter"


>>>TOOL list_dir
{"path": "VSCodeiPadOS/Views/Editor"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/Views/Editor/
   (empty directory)


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


>>>TOOL search
{"query": "func highlight", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "func highlight"


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
(cached)


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
(cached)


>>>TOOL search
{"query": "highlighter.highlight", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "highlighter.highlight"


>>>TOOL search
{"query": "highlighter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "highlighter"


>>>TOOL search
{"query": "class.*Highlighter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class.*Highlighter"


>>>TOOL search
{"query": "attributedText.*highlight", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "attributedText.*highlight"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1500, "end_line": 1800}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1501-1800 of 2289)
────────────────────────────────────────
1501:         let toggleCommentAction = UIAction(
1502:             title: "Toggle Comment",
1503:             image: UIImage(systemName: "text.quote"),
1504:             identifier: UIAction.Identifier("com.vscode.toggleComment"),
1505:             handler: { [weak self] _ in
1506:                 self?.toggleComment(nil)
1507:             }
1508:         )
1509:         
1510:         // Group custom actions
1511:         let customMenu = UIMenu(
1512:             title: "",
1513:             identifier: UIMenu.Identifier("com.vscode.customActions"),
1514:             options: [.displayInline],
1515:             children: [
1516:                 goToDefinitionAction,
1517:                 peekDefinitionAction,
1518:                 findReferencesAction,
1519:                 formatDocumentAction,
1520:                 toggleCommentAction
1521:             ]
1522:         )
1523:         
1524:         // Insert custom menu after standard edit menu
1525:         builder.insertChild(customMenu, atStartOfMenu: .text)
1526:     }
1527: }
1528: 
1529: // MARK: - VSCode-Style Syntax Highlighter
1530: 
1531: enum Language {
1532:     case swift
1533: 
1534:     case javascript
1535:     case typescript
1536:     case jsx
1537:     case tsx
1538: 
1539:     case python
1540:     case ruby
1541:     case go
1542:     case rust
1543:     case java
1544:     case kotlin
1545: 
1546:     case c
1547:     case cpp
1548:     case objectiveC
1549: 
1550:     case html
1551:     case css
1552:     case scss
1553:     case less
1554:     case json
1555:     case xml
1556:     case yaml
1557:     case sql
1558: 
1559:     case shell
1560:     case dockerfile
1561:     case graphql
1562:     case markdown
1563:     case php
1564:     case env
1565: 
1566:     case plainText
1567: }
1568: 
1569: struct VSCodeSyntaxHighlighter {
1570:     private let baseFontSize: CGFloat
1571:     let theme: Theme
1572:     
1573:     init(theme: Theme = ThemeManager.shared.currentTheme, fontSize: CGFloat = 14) {
1574:         self.theme = theme
1575:         self.baseFontSize = fontSize
1576:     }
1577:     
1578:     func highlight(_ text: String, filename: String) -> NSAttributedString {
1579:         let language = detectLanguage(from: filename)
1580:         return highlight(text, language: language)
1581:     }
1582:     
1583:     private func detectLanguage(from filename: String) -> Language {
1584:         let lower = filename.lowercased()
1585:         let ext = (filename as NSString).pathExtension.lowercased()
1586: 
1587:         // Special-case filenames without extensions
1588:         if (filename as NSString).lastPathComponent.lowercased() == "dockerfile" { return .dockerfile }
1589:         if (filename as NSString).lastPathComponent.lowercased() == ".env" { return .env }
1590:         if lower.hasSuffix("/.env") { return .env }
1591: 
1592:         switch ext {
1593:         case "swift": return .swift
1594: 
1595:         case "js", "mjs", "cjs": return .javascript
1596:         case "jsx": return .jsx
1597:         case "ts", "mts", "cts": return .typescript
1598:         case "tsx": return .tsx
1599: 
1600:         case "py", "pyw": return .python
1601:         case "rb", "ruby": return .ruby
1602:         case "go": return .go
1603:         case "rs": return .rust
1604:         case "java": return .java
1605:         case "kt", "kts": return .kotlin
1606: 
1607:         case "c", "h": return .c
1608:         case "cpp", "cc", "cxx", "hpp", "hh", "hxx": return .cpp
1609:         case "m", "mm": return .objectiveC
1610: 
1611:         case "html", "htm": return .html
1612:         case "css": return .css
1613:         case "scss", "sass": return .scss
1614:         case "less": return .less
1615:         case "json", "jsonc": return .json
1616:         case "xml", "plist", "svg": return .xml
1617:         case "yml", "yaml": return .yaml
1618:         case "sql": return .sql
1619: 
1620:         case "sh", "bash", "zsh", "fish": return .shell
1621:         case "dockerfile": return .dockerfile
1622: 
1623:         case "graphql", "gql": return .graphql
1624: 
1625:         case "md", "markdown": return .markdown
1626:         case "php": return .php
1627:         case "env": return .env
1628: 
1629:         default: return .plainText
1630:         }
1631:     }
1632:     
1633:     private func highlight(_ text: String, language: Language) -> NSAttributedString {
1634:         let attributed = NSMutableAttributedString(string: text)
1635:         let fullRange = NSRange(location: 0, length: text.utf16.count)
1636:         
1637:         // Base attributes
1638:         let baseFont = UIFont.monospacedSystemFont(ofSize: baseFontSize, weight: .regular)
1639:         attributed.addAttribute(.font, value: baseFont, range: fullRange)
1640:         attributed.addAttribute(.foregroundColor, value: UIColor(theme.editorForeground), range: fullRange)
1641:         
1642:         // Apply language-specific highlighting
1643:         switch language {
1644:         case .swift: highlightSwift(attributed, text: text)
1645:         case .javascript, .jsx: highlightJavaScript(attributed, text: text, isTS: false)
1646:         case .typescript, .tsx: highlightJavaScript(attributed, text: text, isTS: true)
1647:         case .python: highlightPython(attributed, text: text)
1648:         case .html, .xml: highlightHTML(attributed, text: text)
1649:         case .css, .scss, .less: highlightCSS(attributed, text: text)
1650:         case .json: highlightJSON(attributed, text: text)
1651:         case .markdown: highlightMarkdown(attributed, text: text)
1652:         case .rust: highlightRust(attributed, text: text)
1653:         case .go: highlightGo(attributed, text: text)
1654:         case .java, .kotlin: highlightJava(attributed, text: text)
1655:         case .c, .cpp, .objectiveC: highlightCpp(attributed, text: text)
1656:         case .ruby: highlightRuby(attributed, text: text)
1657:         case .php: highlightPHP(attributed, text: text)
1658:         case .shell, .dockerfile: highlightShell(attributed, text: text)
1659:         case .yaml, .env: highlightYAML(attributed, text: text)
1660:         case .sql: highlightSQL(attributed, text: text)
1661:         case .graphql: highlightGraphQL(attributed, text: text)
1662:         case .plainText: break
1663:         }
1664:         
1665:         // FEAT-038: Bracket Pair Colorization (applied last)
1666:         highlightBracketPairs(attributed, text: text)
1667:         
1668:         return attributed
1669:     }
1670:     
1671:     // MARK: - Bracket Pair Colorization
1672:     
1673:     private func highlightBracketPairs(_ attributed: NSMutableAttributedString, text: String) {
1674:         let brackets: [Character] = ["{", "}", "[", "]", "(", ")"]
1675:         let pairs: [Character: Character] = ["}": "{", "]": "[", ")": "("]
1676:         
1677:         var stack: [(char: Character, index: Int, depth: Int)] = []
1678:         let colors = [
1679:             UIColor(theme.bracketPair1),
1680:             UIColor(theme.bracketPair2),
1681:             UIColor(theme.bracketPair3),
1682:             UIColor(theme.bracketPair4),
1683:             UIColor(theme.bracketPair5),
1684:             UIColor(theme.bracketPair6)
1685:         ]
1686:         
1687:         // Scan text for brackets
1688:         // Note: In a real implementation, we should skip brackets inside strings/comments
1689:         // But since we apply this LAST, we can try to respect existing string/comment colors
1690:         // OR implement a more robust parser. For now, simple scan.
1691:         
1692:         // Optimization: Use scanner or direct iteration
1693:         let nsString = text as NSString
1694:         var index = 0
1695:         
1696:         while index < text.utf16.count {
1697:             let char = nsString.character(at: index)
1698:             if let scalar = UnicodeScalar(char) {
1699:                 let c = Character(scalar)
1700:                 
1701:                 if brackets.contains(c) {
1702:                     // Check if it's already colored as string/comment (heuristic)
1703:                     // If color is string/comment, skip
1704:                     // (Requires iterating attributes, which is slow. We'll just apply on top for now)
1705:                     
1706:                     if let open = pairs[c] { // Closing bracket
1707:                         if let last = stack.last, last.char == open {
1708:                             // Match found
1709:                             let depth = last.depth
1710:                             let color = colors[depth % colors.count]
1711:                             
1712:                             attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1713:                             attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: last.index, length: 1))
1714:                             
1715:                             stack.removeLast()
1716:                         } else {
1717:                             // Mismatched or extra closing bracket - unexpected
1718:                             // Keep default color or mark red? Default for now.
1719:                         }
1720:                     } else { // Opening bracket
1721:                         let depth = stack.count
1722:                         stack.append((c, index, depth))
1723:                         
1724:                         // We'll color it when (and if) we find the match, or here?
1725:                         // Better to color here tentatively, but matching is better.
1726:                         // Let's color tentatively based on depth.
1727:                         let color = colors[depth % colors.count]
1728:                         attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1729:                     }
1730:                 }
1731:             }
1732:             index += 1
1733:         }
1734:     }
1735:     
1736:     // MARK: - Swift Highlighting
1737:     
1738:     private func highlightSwift(_ attributed: NSMutableAttributedString, text: String) {
1739:         // Keywords (purple/pink)
1740:         let keywords = ["func", "var", "let", "if", "else", "for", "while", "return",
1741:                        "class", "struct", "enum", "protocol", "extension", "import",
1742:                        "private", "public", "internal", "fileprivate", "open",
1743:                        "static", "final", "override", "mutating", "nonmutating",
1744:                        "init", "deinit", "subscript", "typealias", "associatedtype",
1745:                        "where", "throws", "rethrows", "async", "await", "actor",
1746:                        "guard", "defer", "do", "try", "catch", "throw",
1747:                        "switch", "case", "default", "break", "continue", "fallthrough",
1748:                        "in", "is", "as", "inout", "some", "any", "Self",
1749:                        "get", "set", "willSet", "didSet", "lazy", "weak", "unowned",
1750:                        "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject",
1751:                        "@Environment", "@EnvironmentObject", "@ViewBuilder", "@MainActor",
1752:                        "@escaping", "@autoclosure", "@available", "@objc", "@discardableResult"]
1753:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1754:         
1755:         // Types (teal) - CamelCase words that aren't keywords
1756:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1757:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1758:         
1759:         // Function calls (yellow)
1760:         let funcCallPattern = "\\b([a-z][a-zA-Z0-9]*)\\s*\\("
1761:         highlightPattern(attributed, pattern: funcCallPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1762:         
1763:         // Constants (blue)
1764:         let constants = ["true", "false", "nil", "self", "super"]
1765:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1766:         
1767:         // Comments MUST come late (green) - they override everything
1768:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1769:         
1770:         // Strings AFTER comments (orange)
1771:         highlightStrings(attributed, text: text)
1772:         
1773:         // Numbers (light green)
1774:         highlightNumbers(attributed, text: text)
1775:     }
1776:     
1777:     // MARK: - JavaScript/TypeScript Highlighting
1778:     
1779:     private func highlightJavaScript(_ attributed: NSMutableAttributedString, text: String, isTS: Bool) {
1780:         var keywords = ["function", "var", "let", "const", "if", "else", "for", "while",
1781:                        "return", "class", "extends", "new", "this", "super", "import",
1782:                        "export", "default", "from", "as", "async", "await", "yield",
1783:                        "try", "catch", "finally", "throw", "typeof", "instanceof",
1784:                        "switch", "case", "break", "continue", "do", "in", "of",
1785:                        "get", "set", "static", "constructor", "delete", "void",
1786:                        "with", "debugger"]
1787:         
1788:         if isTS {
1789:             keywords += ["interface", "type", "enum", "namespace", "module", "declare",
1790:                         "implements", "public", "private", "protected", "readonly",
1791:                         "abstract", "override", "keyof", "infer", "never", "unknown",
1792:                         "any", "asserts", "is"]
1793:         }
1794:         
1795:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1796:         
1797:         // Constants
1798:         let constants = ["true", "false", "null", "undefined", "NaN", "Infinity"]
1799:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1800:         


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 2050, "end_line": 2289}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2051-2289 of 2289)
────────────────────────────────────────
2051:         highlightNumbers(attributed, text: text)
2052:     }
2053:     
2054:     // MARK: - Ruby Highlighting
2055:     
2056:     private func highlightRuby(_ attributed: NSMutableAttributedString, text: String) {
2057:         let keywords = ["def", "class", "module", "if", "elsif", "else", "unless", "case", "when",
2058:                        "while", "until", "for", "do", "end", "begin", "rescue", "ensure", "raise",
2059:                        "return", "yield", "break", "next", "redo", "retry", "self", "super",
2060:                        "require", "require_relative", "include", "extend", "attr_reader", "attr_writer", "attr_accessor",
2061:                        "public", "private", "protected", "alias", "and", "or", "not", "in"]
2062:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2063:         
2064:         let constants = ["true", "false", "nil"]
2065:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
2066:         
2067:         // Symbols (orange)
2068:         let symbolPattern = ":[a-zA-Z_][a-zA-Z0-9_]*"
2069:         highlightPattern(attributed, pattern: symbolPattern, color: UIColor(theme.string), text: text)
2070:         
2071:         // Instance variables (light blue)
2072:         let ivarPattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
2073:         highlightPattern(attributed, pattern: ivarPattern, color: UIColor(theme.variable), text: text)
2074:         
2075:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: "=begin", multiLineEnd: "=end")
2076:         highlightStrings(attributed, text: text)
2077:         highlightNumbers(attributed, text: text)
2078:     }
2079:     
2080:     // MARK: - PHP Highlighting
2081:     
2082:     private func highlightPHP(_ attributed: NSMutableAttributedString, text: String) {
2083:         let keywords = ["function", "class", "interface", "trait", "extends", "implements", "use",
2084:                        "public", "private", "protected", "static", "final", "abstract", "const",
2085:                        "if", "else", "elseif", "switch", "case", "default", "for", "foreach", "while", "do",
2086:                        "return", "break", "continue", "throw", "try", "catch", "finally",
2087:                        "new", "clone", "instanceof", "echo", "print", "die", "exit",
2088:                        "require", "require_once", "include", "include_once", "namespace"]
2089:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2090:         
2091:         let constants = ["true", "false", "null", "TRUE", "FALSE", "NULL"]
2092:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
2093:         
2094:         // Variables (light blue)
2095:         let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
2096:         highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
2097:         
2098:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
2099:         highlightStrings(attributed, text: text)
2100:         highlightNumbers(attributed, text: text)
2101:     }
2102:     
2103:     // MARK: - Shell Highlighting
2104:     
2105:     private func highlightShell(_ attributed: NSMutableAttributedString, text: String) {
2106:         let keywords = ["if", "then", "else", "elif", "fi", "for", "while", "do", "done", "case", "esac",
2107:                        "function", "return", "exit", "break", "continue", "local", "export", "readonly",
2108:                        "source", "alias", "unalias", "set", "unset", "shift", "eval", "exec",
2109:                        "echo", "printf", "read", "cd", "pwd", "ls", "mkdir", "rm", "cp", "mv"]
2110:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2111:         
2112:         // Variables (light blue)
2113:         let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*|\\$\\{[^}]+\\}"
2114:         highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
2115:         
2116:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
2117:         highlightStrings(attributed, text: text)
2118:         highlightNumbers(attributed, text: text)
2119:     }
2120:     
2121:     // MARK: - YAML Highlighting
2122:     
2123:     private func highlightYAML(_ attributed: NSMutableAttributedString, text: String) {
2124:         // Keys (light blue)
2125:         let keyPattern = "^\\s*([a-zA-Z_][a-zA-Z0-9_-]*)\\s*:"
2126:         highlightPattern(attributed, pattern: keyPattern, color: UIColor(theme.variable), text: text, options: .anchorsMatchLines, captureGroup: 1)
2127:         
2128:         // Booleans and null
2129:         let constants = ["true", "false", "yes", "no", "on", "off", "null", "~"]
2130:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
2131:         
2132:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
2133:         highlightStrings(attributed, text: text)
2134:         highlightNumbers(attributed, text: text)
2135:     }
2136:     
2137:     // MARK: - SQL Highlighting
2138:     
2139:     private func highlightSQL(_ attributed: NSMutableAttributedString, text: String) {
2140:         let keywords = ["SELECT", "FROM", "WHERE", "AND", "OR", "NOT", "IN", "LIKE", "BETWEEN",
2141:                        "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE", "CREATE", "ALTER", "DROP",
2142:                        "TABLE", "INDEX", "VIEW", "DATABASE", "SCHEMA", "PRIMARY", "KEY", "FOREIGN", "REFERENCES",
2143:                        "JOIN", "INNER", "LEFT", "RIGHT", "OUTER", "FULL", "ON", "AS", "DISTINCT",
2144:                        "ORDER", "BY", "ASC", "DESC", "GROUP", "HAVING", "LIMIT", "OFFSET", "UNION",
2145:                        "NULL", "IS", "TRUE", "FALSE", "CASE", "WHEN", "THEN", "ELSE", "END",
2146:                        "COUNT", "SUM", "AVG", "MIN", "MAX", "COALESCE", "CAST",
2147:                        "select", "from", "where", "and", "or", "not", "in", "like", "between",
2148:                        "insert", "into", "values", "update", "set", "delete", "create", "alter", "drop",
2149:                        "table", "index", "view", "database", "schema", "primary", "key", "foreign", "references",
2150:                        "join", "inner", "left", "right", "outer", "full", "on", "as", "distinct",
2151:                        "order", "by", "asc", "desc", "group", "having", "limit", "offset", "union",
2152:                        "null", "is", "true", "false", "case", "when", "then", "else", "end"]
2153:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2154:         
2155:         let types = ["INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT", "FLOAT", "DOUBLE", "DECIMAL",
2156:                     "VARCHAR", "CHAR", "TEXT", "BLOB", "DATE", "TIME", "DATETIME", "TIMESTAMP", "BOOLEAN",
2157:                     "int", "integer", "bigint", "smallint", "tinyint", "float", "double", "decimal",
2158:                     "varchar", "char", "text", "blob", "date", "time", "datetime", "timestamp", "boolean"]
2159:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
2160:         
2161:         highlightComments(attributed, text: text, singleLine: "--", multiLineStart: "/*", multiLineEnd: "*/")
2162:         highlightStrings(attributed, text: text)
2163:         highlightNumbers(attributed, text: text)
2164:     }
2165:     
2166:     // MARK: - GraphQL Highlighting
2167:     
2168:     private func highlightGraphQL(_ attributed: NSMutableAttributedString, text: String) {
2169:         // Keywords
2170:         let keywords = ["query", "mutation", "subscription", "fragment", "on", "type", 
2171:                        "interface", "union", "enum", "scalar", "input", "extend", 
2172:                        "directive", "schema", "implements"]
2173:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2174:         
2175:         // Built-in scalar types
2176:         let types = ["Int", "Float", "String", "Boolean", "ID"]
2177:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
2178:         
2179:         // Variables ($name)
2180:         let variablePattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
2181:         highlightPattern(attributed, pattern: variablePattern, color: UIColor(theme.variable), text: text)
2182:         
2183:         // Directives (@deprecated, @skip, @include, etc.)
2184:         let directivePattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
2185:         highlightPattern(attributed, pattern: directivePattern, color: UIColor(theme.function), text: text)
2186:         
2187:         // Comments (# single line)
2188:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
2189:         
2190:         // Strings
2191:         highlightStrings(attributed, text: text)
2192:         
2193:         // Numbers
2194:         highlightNumbers(attributed, text: text)
2195:     }
2196:     
2197:     // MARK: - Helper Methods
2198:     
2199:     private func highlightKeywords(_ attributed: NSMutableAttributedString, keywords: [String], color: UIColor, text: String) {
2200:         for keyword in keywords {
2201:             let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
2202:             highlightPattern(attributed, pattern: pattern, color: color, text: text)
2203:         }
2204:     }
2205:     
2206:     private func highlightPattern(_ attributed: NSMutableAttributedString, pattern: String, color: UIColor, text: String, options: NSRegularExpression.Options = [], captureGroup: Int = 0) {
2207:         guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
2208:         let range = NSRange(location: 0, length: text.utf16.count)
2209:         
2210:         regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
2211:             guard let match = match else { return }
2212:             let matchRange = captureGroup > 0 && match.numberOfRanges > captureGroup
2213:                 ? match.range(at: captureGroup)
2214:                 : match.range
2215:             if matchRange.location != NSNotFound {
2216:                 attributed.addAttribute(.foregroundColor, value: color, range: matchRange)
2217:             }
2218:         }
2219:     }
2220:     
2221:     private func highlightStrings(_ attributed: NSMutableAttributedString, text: String) {
2222:         // Double-quoted strings
2223:         let doublePattern = "\"(?:[^\"\\\\]|\\\\.)*\""
2224:         highlightPattern(attributed, pattern: doublePattern, color: UIColor(theme.string), text: text)
2225:         
2226:         // Single-quoted strings
2227:         let singlePattern = "'(?:[^'\\\\]|\\\\.)*'"
2228:         highlightPattern(attributed, pattern: singlePattern, color: UIColor(theme.string), text: text)
2229:     }
2230:     
2231:     private func highlightPythonStrings(_ attributed: NSMutableAttributedString, text: String) {
2232:         // Triple-quoted strings first
2233:         let tripleDoublePattern = "\"\"\"[\\s\\S]*?\"\"\""
2234:         highlightPattern(attributed, pattern: tripleDoublePattern, color: UIColor(theme.string), text: text)
2235:         
2236:         let tripleSinglePattern = "'''[\\s\\S]*?'''"
2237:         highlightPattern(attributed, pattern: tripleSinglePattern, color: UIColor(theme.string), text: text)
2238:         
2239:         // Then regular strings
2240:         highlightStrings(attributed, text: text)
2241:         
2242:         // F-strings (with expressions highlighted differently)
2243:         let fstringPattern = "f\"[^\"]*\"|f'[^']*'"
2244:         highlightPattern(attributed, pattern: fstringPattern, color: UIColor(theme.string), text: text)
2245:     }
2246:     
2247:     private func highlightJSTemplateLiterals(_ attributed: NSMutableAttributedString, text: String) {
2248:         // Template literals
2249:         let templatePattern = "`[^`]*`"
2250:         highlightPattern(attributed, pattern: templatePattern, color: UIColor(theme.string), text: text)
2251:     }
2252:     
2253:     private func highlightComments(_ attributed: NSMutableAttributedString, text: String, singleLine: String?, multiLineStart: String?, multiLineEnd: String?) {
2254:         // Single-line comments
2255:         if let single = singleLine {
2256:             let pattern = "\(NSRegularExpression.escapedPattern(for: single)).*$"
2257:             highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text, options: .anchorsMatchLines)
2258:         }
2259:         
2260:         // Multi-line comments
2261:         if let start = multiLineStart, let end = multiLineEnd {
2262:             let pattern = "\(NSRegularExpression.escapedPattern(for: start))[\\s\\S]*?\(NSRegularExpression.escapedPattern(for: end))"
2263:             highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
2264:         }
2265:     }
2266:     
2267:     private func highlightHTMLComments(_ attributed: NSMutableAttributedString, text: String) {
2268:         let pattern = "<!--[\\s\\S]*?-->"
2269:         highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
2270:     }
2271:     
2272:     private func highlightNumbers(_ attributed: NSMutableAttributedString, text: String) {
2273:         // Hex numbers
2274:         let hexPattern = "\\b0[xX][0-9a-fA-F]+\\b"
2275:         highlightPattern(attributed, pattern: hexPattern, color: UIColor(theme.number), text: text)
2276:         
2277:         // Binary numbers
2278:         let binPattern = "\\b0[bB][01]+\\b"
2279:         highlightPattern(attributed, pattern: binPattern, color: UIColor(theme.number), text: text)
2280:         
2281:         // Octal numbers
2282:         let octPattern = "\\b0[oO][0-7]+\\b"
2283:         highlightPattern(attributed, pattern: octPattern, color: UIColor(theme.number), text: text)
2284:         
2285:         // Decimal numbers (including floats and scientific notation)
2286:         let decPattern = "\\b\\d+\\.?\\d*([eE][+-]?\\d+)?\\b"
2287:         highlightPattern(attributed, pattern: decPattern, color: UIColor(theme.number), text: text)
2288:     }
2289: }


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/SyntaxHighlighter_Optimizations.md"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/SyntaxHighlighter_Optimizations.md (lines 1-69 of 69)
────────────────────────────────────────
1: # SyntaxHighlighter Performance Optimizations
2: 
3: ## Overview
4: This document describes the performance optimizations made to the SyntaxHighlighter class.
5: 
6: ## Key Optimizations
7: 
8: ### 1. Pre-compiled Regex Patterns
9: - **Before**: Regex patterns were compiled on every `highlight()` call
10: - **After**: All regex patterns are compiled once as static properties
11: - **Impact**: ~40-50% performance improvement
12: 
13: ### 2. NSRegularExpression Instead of Swift Regex
14: - **Before**: Using Swift's Regex type
15: - **After**: Using NSRegularExpression for better performance on iOS
16: - **Impact**: More efficient pattern matching
17: 
18: ### 3. Static Color and Font Properties
19: - **Before**: Colors and fonts created on each use
20: - **After**: Pre-created static properties
21: - **Impact**: Reduced object allocation overhead
22: 
23: ### 4. Efficient Range Operations
24: - **Before**: Multiple string searches for the same content
25: - **After**: Using NSString and NSRange for efficient range operations
26: - **Impact**: Faster range conversions and lookups
27: 
28: ### 5. Range Conflict Resolution
29: - **Before**: Overlapping highlights could cause issues
30: - **After**: Track highlighted ranges to prevent conflicts
31: - **Impact**: More accurate highlighting, prevents double-processing
32: 
33: ### 6. Combined Type Sets
34: - **Before**: Checking types and swiftUITypes separately
35: - **After**: Pre-combined set for single lookup
36: - **Impact**: Faster type checking
37: 
38: ## Performance Improvements
39: 
40: ### Estimated Performance Gains:
41: - **Small files (<1000 chars)**: 40-50% faster
42: - **Medium files (1000-5000 chars)**: 50-60% faster
43: - **Large files (>5000 chars)**: 60-70% faster
44: 
45: ### Memory Usage:
46: - Slightly higher static memory usage (pre-compiled patterns)
47: - Lower dynamic memory allocation during highlighting
48: - Overall memory efficiency improved for repeated highlighting
49: 
50: ## Usage
51: The API remains unchanged. Simply use the SyntaxHighlighter as before:
52: 
53: ```swift
54: let highlighter = SyntaxHighlighter()
55: highlighter.highlight(codeString)
56: let highlighted = highlighter.highlightedText
57: ```
58: 
59: ## Testing
60: Run the performance test to verify improvements:
61: ```swift
62: SyntaxHighlighterPerformanceTest.runPerformanceTest()
63: ```
64: 
65: ## Future Optimizations
66: 1. Implement incremental highlighting for real-time editing
67: 2. Add caching for recently highlighted code
68: 3. Consider background queue processing for very large files
69: 4. Implement language-specific highlighters for better accuracy


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift", "start_line": 1, "end_line": 150}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 2-150 of 274)
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
30:     /// PERF: Throttle cursor display updates during scroll
31:     private var lastCursorUpdateTime: CFTimeInterval = 0
32:     private let cursorUpdateThrottleInterval: CFTimeInterval = 0.016  // ~60fps max
33: 
34:     /// Cursor appearance
35:     private let cursorWidth: CGFloat = 2
36:     private let cursorColor = UIColor.systemBlue
37:     private let secondaryCursorColor = UIColor.systemCyan
38:     private let selectionColor = UIColor.systemBlue.withAlphaComponent(0.3)
39:     private let secondarySelectionColor = UIColor.systemCyan.withAlphaComponent(0.25)
40: 
41:     override init(frame: CGRect, textContainer: NSTextContainer?) {
42:         super.init(frame: frame, textContainer: textContainer)
43:         setupCursorBlinking()
44:     }
45: 
46:     required init?(coder: NSCoder) {
47:         super.init(coder: coder)
48:         setupCursorBlinking()
49:     }
50: 
51:     deinit {
52:         blinkTimer?.invalidate()
53:     }
54: 
55:     private func setupCursorBlinking() {
56:         blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
57:             self?.cursorVisible.toggle()
58:             self?.updateCursorVisibility()
59:         }
60:     }
61: 
62:     private func updateCursorVisibility() {
63:         let alpha: Float = cursorVisible ? 1.0 : 0.0
64:         cursorLayers.forEach { $0.opacity = alpha }
65:     }
66: 
67:     /// Updates the display of all cursors and selections
68:     func updateCursorDisplay() {
69:         // Remove existing cursor and selection layers
70:         cursorLayers.forEach { $0.removeFromSuperlayer() }
71:         cursorLayers.removeAll()
72:         selectionLayers.forEach { $0.removeFromSuperlayer() }
73:         selectionLayers.removeAll()
74: 
75:         guard let editorCore = editorCore else { return }
76:         let cursors = editorCore.multiCursorState.cursors
77: 
78:         // Only show additional cursors if we have multiple
79:         guard cursors.count > 1 else { return }
80: 
81:         // Draw each cursor (skip the primary one as UITextView handles it)
82:         for (index, cursor) in cursors.enumerated() {
83:             // Draw selection if present
84:             if let selectionRange = cursor.selectionRange {
85:                 drawSelection(for: selectionRange, isPrimary: cursor.isPrimary, index: index)
86:             }
87: 
88:             // Draw cursor line (skip primary cursor as system handles it)
89:             if !cursor.isPrimary {
90:                 drawCursor(at: cursor.position, isPrimary: false, index: index)
91:             }
92:         }
93:     }
94: 
95:     private func drawCursor(at position: Int, isPrimary: Bool, index: Int) {
96:         guard let textPosition = self.position(from: beginningOfDocument, offset: position) else { return }
97: 
98:         let caretRect = self.caretRect(for: textPosition)
99: 
100:         let cursorLayer = CALayer()
101:         cursorLayer.backgroundColor = (isPrimary ? cursorColor : secondaryCursorColor).cgColor
102:         cursorLayer.frame = CGRect(
103:             x: caretRect.origin.x,
104:             y: caretRect.origin.y,
105:             width: cursorWidth,
106:             height: caretRect.height
107:         )
108:         cursorLayer.cornerRadius = 1
109: 
110:         layer.addSublayer(cursorLayer)
111:         cursorLayers.append(cursorLayer)
112:     }
113: 
114:     private func drawSelection(for range: NSRange, isPrimary: Bool, index: Int) {
115:         guard let start = position(from: beginningOfDocument, offset: range.location),
116:               let end = position(from: beginningOfDocument, offset: range.location + range.length),
117:               let textRange = self.textRange(from: start, to: end) else { return }
118: 
119:         let selectionRects = selectionRects(for: textRange)
120: 
121:         for rect in selectionRects {
122:             let selectionLayer = CALayer()
123:             selectionLayer.backgroundColor = (isPrimary ? selectionColor : secondarySelectionColor).cgColor
124:             selectionLayer.frame = rect.rect
125: 
126:             // Insert behind text
127:             if let textLayer = layer.sublayers?.first {
128:                 layer.insertSublayer(selectionLayer, below: textLayer)
129:             } else {
130:                 layer.addSublayer(selectionLayer)
131:             }
132:             selectionLayers.append(selectionLayer)
133:         }
134:     }
135: 
136:     // MARK: - Text Input Handling for Multi-Cursor
137: 
138:     override func insertText(_ text: String) {
139:         guard let editorCore = editorCore,
140:               editorCore.multiCursorState.isMultiCursor else {
141:             super.insertText(text)
142:             return
143:         }
144: 
145:         // Handle multi-cursor insert
146:         var content = self.text ?? ""
147:         editorCore.multiCursorState.insertText(text, in: &content)
148: 
149:         // Update text view
150:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0


Now let me search the web for professional iOS text editor approaches:

>>>TOOL web_search
{"query": "Runestone code editor iOS TextKit 2 performance syntax highlighting", "max_results": 5}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Runestone code editor iOS TextKit 2 performance syntax highlighting" (5 results):

1. **Runestone - Performant plain text editor for iOS - GitHub**
   https://github.com/simonbs/runestone
   👋 Welcome to Runestone - a performant plain text editor for iOS with code editing features Runestone uses GitHub&#x27;s Tree-sitter to parse code to a syntax tree which is used for features that require an understanding of the code in the editor, for example syntax highlighting.

2. **Runestone - Documentation**
   https://docs.runestone.app/documentation/runestone/
   Explore Runestone, the performant code editor with syntax highlighting, line numbers, invisible characters, and much more through a series of interactive tutorials.

3. **Syntax Highlighting with TextKit 2 | Apple Developer Forums**
   https://developer.apple.com/forums/thread/763670
   Based on this TextKit 2 demo project I thought that I could implement syntax highlighting by parsing syntax block tokens (e.g. comments like &lt;!-- --&gt; or /* */) in processEditing and storing their locations, and then actually applying the rendering with NSTextContentStorageDelegate in textContentStorage (_:textParagraphWith:) by checking the location of each paragraph against the store of ...

4. **Runestone: A Streamlined Text and Code Editor for iPhone and iPad**
   https://www.macstories.net/reviews/runestone-a-streamlined-text-and-code-editor-for-iphone-and-ipad/
   In my testing, Runestone&#x27;s syntax highlighting has been unbelievably fast and reliable. I&#x27;ve tried many code editors for iOS and iPadOS over the years, and performance and reliability have been the main areas where they&#x27;ve fallen down for me.

5. **Performant plain text editor for iOS with syntax highlighting, line ...**
   https://iosexample.com/performant-plain-text-editor-for-ios-with-syntax-highlighting-line-numbers-invisible-characters-and-much-more/
   Welcome to Runestone - a performant plain text editor for iOS with code editing features Runestone uses GitHub&#x27;s Tree-sitter to parse code to a syntax tree which is used for features that require an understanding of the code in the editor, for example syntax highlighting.


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/runestone", "use_crawl4ai": true, "max_length": 15000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/runestone

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/runestone                               
| ✓ | ⏱: 2.04s 
[SCRAPE].. ◆ https://github.com/simonbs/runestone                               
| ✓ | ⏱: 0.05s 
[COMPLETE] ● https://github.com/simonbs/runestone                               
| ✓ | ⏱: 2.10s 
[Skip to content](https://github.com/simonbs/runestone#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2Frunestone)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2Frunestone)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/runestone) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/runestone) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/runestone) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. 
### License
[ ](https://github.com/simonbs/Runestone/blob/main/LICENSE)
[ 3k stars ](https://github.com/simonbs/Runestone/stargazers) [ 193 forks ](https://github.com/simonbs/Runestone/forks) [ Branches ](https://github.com/simonbs/Runestone/branches) [ Tags ](https://github.com/simonbs/Runestone/tags) [ Activity ](https://github.com/simonbs/Runestone/activity)
[ Star  ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
[ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


# simonbs/Runestone
main
[**3** Branches](https://github.com/simonbs/Runestone/branches)[**31** Tags](https://github.com/simonbs/Runestone/tags)
[](https://github.com/simonbs/Runestone/branches)[](https://github.com/simonbs/Runestone/tags)
Go to file
Code
Open more actions menu
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
## Latest commit
[![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)](https://github.com/simonbs)[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs) [Scroll edge effect blurs line numbers on iOS 26 (](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7)[#404](https://github.com/simonbs/Runestone/pull/404)[)](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7) success Aug 31, 2025 [d490289](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7) · Aug 31, 2025
## History
[1,161 Commits](https://github.com/simonbs/Runestone/commits/main/)Open commit details [](https://github.com/simonbs/Runestone/commits/main/)1,161 Commits  
[.github](https://github.com/simonbs/Runestone/tree/main/.github ".github") | [.github](https://github.com/simonbs/Runestone/tree/main/.github ".github") |  |   
[Assets](https://github.com/simonbs/Runestone/tree/main/Assets "Assets") | [Assets](https://github.com/simonbs/Runestone/tree/main/Assets "Assets") |  |   
[Design](https://github.com/simonbs/Runestone/tree/main/Design "Design") | [Design](https://github.com/simonbs/Runestone/tree/main/Design "Design") |  |   
[Example](https://github.com/simonbs/Runestone/tree/main/Example "Example") | [Example](https://github.com/simonbs/Runestone/tree/main/Example "Example") |  |   
[Scripts](https://github.com/simonbs/Runestone/tree/main/Scripts "Scripts") | [Scripts](https://github.com/simonbs/Runestone/tree/main/Scripts "Scripts") |  |   
[Sources](https://github.com/simonbs/Runestone/tree/main/Sources "Sources") | [Sources](https://github.com/simonbs/Runestone/tree/main/Sources "Sources") |  |   
[Tests/RunestoneTests](https://github.com/simonbs/Runestone/tree/main/Tests/RunestoneTests "This path skips through empty directories") | [Tests/RunestoneTests](https://github.com/simonbs/Runestone/tree/main/Tests/RunestoneTests "This path skips through empty directories") |  |   
[UITests](https://github.com/simonbs/Runestone/tree/main/UITests "UITests") | [UITests](https://github.com/simonbs/Runestone/tree/main/UITests "UITests") |  |   
[.gitattributes](https://github.com/simonbs/Runestone/blob/main/.gitattributes ".gitattributes") | [.gitattributes](https://github.com/simonbs/Runestone/blob/main/.gitattributes ".gitattributes") |  |   
[.gitignore](https://github.com/simonbs/Runestone/blob/main/.gitignore ".gitignore") | [.gitignore](https://github.com/simonbs/Runestone/blob/main/.gitignore ".gitignore") |  |   
[.gitmodules](https://github.com/simonbs/Runestone/blob/main/.gitmodules ".gitmodules") | [.gitmodules](https://github.com/simonbs/Runestone/blob/main/.gitmodules ".gitmodules") |  |   
[.spi.yml](https://github.com/simonbs/Runestone/blob/main/.spi.yml ".spi.yml") | [.spi.yml](https://github.com/simonbs/Runestone/blob/main/.spi.yml ".spi.yml") |  |   
[.swiftlint.yml](https://github.com/simonbs/Runestone/blob/main/.swiftlint.yml ".swiftlint.yml") | [.swiftlint.yml](https://github.com/simonbs/Runestone/blob/main/.swiftlint.yml ".swiftlint.yml") |  |   
[CODEOWNERS](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS "CODEOWNERS") | [CODEOWNERS](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS "CODEOWNERS") |  |   
[LICENSE](https://github.com/simonbs/Runestone/blob/main/LICENSE "LICENSE") | [LICENSE](https://github.com/simonbs/Runestone/blob/main/LICENSE "LICENSE") |  |   
[Package.resolved](https://github.com/simonbs/Runestone/blob/main/Package.resolved "Package.resolved") | [Package.resolved](https://github.com/simonbs/Runestone/blob/main/Package.resolved "Package.resolved") |  |   
[Package.swift](https://github.com/simonbs/Runestone/blob/main/Package.swift "Package.swift") | [Package.swift](https://github.com/simonbs/Runestone/blob/main/Package.swift "Package.swift") |  |   
[README.md](https://github.com/simonbs/Runestone/blob/main/README.md "README.md") | [README.md](https://github.com/simonbs/Runestone/blob/main/README.md "README.md") |  |   
[swiftgen.yml](https://github.com/simonbs/Runestone/blob/main/swiftgen.yml "swiftgen.yml") | [swiftgen.yml](https://github.com/simonbs/Runestone/blob/main/swiftgen.yml "swiftgen.yml") |  |   
View all files  
## Repository files navigation
  * [README](https://github.com/simonbs/runestone#)
  * [License](https://github.com/simonbs/runestone#)


[![](https://github.com/simonbs/Runestone/raw/main/Sources/Runestone/Documentation.docc/Resources/hero.png)](https://github.com/simonbs/Runestone/raw/main/Sources/Runestone/Documentation.docc/Resources/hero.png)
### 👋 Welcome to Runestone - a performant plain text editor for iOS with code editing features
[](https://github.com/simonbs/runestone#-welcome-to-runestone---a-performant-plain-text-editor-for-ios-with-code-editing-features)
Runestone uses GitHub's [Tree-sitter](https://tree-sitter.github.io/tree-sitter/) to parse code to a syntax tree which is used for features that require an understanding of the code in the editor, for example syntax highlighting.
[![](https://camo.githubusercontent.com/1820a0344f6712cbc1a90e9550be26971b36ba47543bd587138b7e435fbb9c63/68747470733a2f2f696d672e736869656c64732e696f2f656e64706f696e743f75726c3d687474707325334125324625324673776966747061636b616765696e6465782e636f6d2532466170692532467061636b6167657325324673696d6f6e627325324652756e6573746f6e6525324662616467652533467479706525334473776966742d76657273696f6e73)](https://swiftpackageindex.com/simonbs/Runestone) [![](https://camo.githubusercontent.com/6eb267fe06818e8193323da5c6c725c063699221905e4e29ebb2f4ba13122a68/68747470733a2f2f696d672e736869656c64732e696f2f656e64706f696e743f75726c3d687474707325334125324625324673776966747061636b616765696e6465782e636f6d2532466170692532467061636b6167657325324673696d6f6e627325324652756e6573746f6e65253246626164676525334674797065253344706c6174666f726d73)](https://swiftpackageindex.com/simonbs/Runestone) [![Build and Test](https://github.com/simonbs/Runestone/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/simonbs/Runestone/actions/workflows/build_and_test.yml) [![Build Documentation](https://github.com/simonbs/Runestone/actions/workflows/build_documentation.yml/badge.svg)](https://github.com/simonbs/Runestone/actions/workflows/build_documentation.yml) [![Build Example Project](https://github.com/simonbs/Runestone/actions/workflows/build_example_project.yml/badge.svg)](https://github.com/simonbs/Runestone/actions/workflows/build_example_project.yml) [![CodeQL](https://github.com/simonbs/Runestone/action


Now I have a complete picture. Let me compile a comprehensive profiling strategy and analysis.

>>>REPORT
# VSCodeiPadOS Typing Lag: Profiling Strategy & Solutions

## 🔍 ARCHITECTURE ANALYSIS (from SyntaxHighlightingTextView.swift)

The editor uses:
- **TextKit 1** with custom `FoldingLayoutManager` (lines 114-128)
- **Regex-based `VSCodeSyntaxHighlighter`** (lines 1569-2289)
- **Full document re-highlighting** on every text change (debounced 80ms-1500ms)
- **EditorTextView** with `draw()` override for line highlighting + indent guides

---

## 1️⃣ INSTRUMENTS TIME PROFILER STRATEGY

### Step 1: Record While Typing
```
1. Product → Profile (⌘I) → Time Profiler
2. Set recording options:
   - High Frequency (10ms sampling)
   - Record Waiting Threads: ON
3. Start typing rapidly in a ~5000+ char file
4. Look for:
   - Main thread blocked > 16ms (missed frames)
   - Call stacks with >5ms per invocation
```

### Step 2: Focus on Hot Paths
Filter by these symbols (based on code analysis):
```
VSCodeSyntaxHighlighter.highlight
applySyntaxHighlighting
textViewDidChange
highlightKeywords (runs dozens of regex patterns!)
highlightBracketPairs (O(n) character scan)
NSRegularExpression.enumerateMatches
NSMutableAttributedString.addAttribute
```

### Step 3: Check for Layout Thrashing
Look for repeated calls to:
```
NSLayoutManager.invalidateLayout
NSTextStorage.edited
UITextView.attributedText setter (triggers full relayout!)
```

---

## 2️⃣ QUICK DIAGNOSTIC CODE SNIPPETS

### Add Timing to textViewDidChange (Line 373)
```swift
func textViewDidChange(_ textView: UITextView) {
    #if DEBUG
    let start = CFAbsoluteTimeGetCurrent()
    defer {
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        if elapsed > 8 { // Log if > 8ms (half a frame)
            print("⚠️ textViewDidChange: \(String(format: "%.1f", elapsed))ms, chars: \(textView.text.count)")
        }
    }
    #endif
    // ... existing code
}
```

### Add Timing to applySyntaxHighlighting (Line 755)
```swift
func applySyntaxHighlighting(to textView: UITextView) {
    #if DEBUG
    let start = CFAbsoluteTimeGetCurrent()
    #endif
    
    // ... existing code ...
    
    #if DEBUG
    let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
    print("🎨 Highlighting: \(String(format: "%.1f", elapsed))ms, chars: \(textView.text.count)")
    #endif
}
```

### Track Frame Drops with CADisplayLink
```swift
// Add to EditorTextView
private var displayLink: CADisplayLink?
private var lastFrameTime: CFTimeInterval = 0

func startFrameMonitoring() {
    displayLink = CADisplayLink(target: self, selector: #selector(frameCallback))
    displayLink?.add(to: .main, forMode: .common)
}

@objc private func frameCallback() {
    let now = CACurrentMediaTime()
    if lastFrameTime > 0 {
        let delta = (now - lastFrameTime) * 1000
        if delta > 20 { // Dropped frame threshold
            print("🔴 Frame drop: \(String(format: "%.1f", delta))ms")
        }
    }
    lastFrameTime = now
}
```

---

## 3️⃣ iOS TEXT EDITOR BEST PRACTICES BEING VIOLATED

| Best Practice | Current State | Severity |
|--------------|---------------|----------|
| **Incremental highlighting** | ❌ Full document re-highlight on every change (line 766) | 🔴 Critical |
| **Tree-sitter/AST parsing** | ❌ Uses regex patterns (line 2206-2218) | 🔴 Critical |
| **TextKit 2** | ❌ Uses TextKit 1 NSLayoutManager | 🟡 Medium |
| **Edit-only relayout** | ❌ `textView.attributedText = ...` replaces entire text (line 778) | 🔴 Critical |
| **Visible-range only processing** | ⚠️ Partial (only for >10k files, lines 465-561) | 🟡 Medium |
| **Background thread highlighting** | ⚠️ Partial (only for 5k-10k files, lines 427-461) | 🟡 Medium |
| **Regex pre-compilation** | ⚠️ Not fully cached (compiled per-call in highlightPattern) | 🟠 High |
| **Avoid draw() override** | ❌ Custom draw() for line highlight + indent guides (line 1169) | 🟡 Medium |

---

## 4️⃣ HOW PROFESSIONAL EDITORS DO IT

### Runestone (iOS, 3k+ GitHub stars)
- **Tree-sitter** for incremental parsing (only re-parses changed text)
- Syntax tree provides O(log n) lookups for highlighting
- **Custom text layout** instead of stock UITextView
- Visible-range-only rendering

### CodeEdit (macOS)
- **Tree-sitter** with `tree_sitter_edit()` for incremental updates
- TextKit 2 `NSTextContentManager` for efficient storage
- Custom `NSTextLayoutManager` for line-by-line rendering

### Key Insight: **The regex approach fundamentally doesn't scale**
- 50+ regex patterns × O(n) per pattern = O(50n) per keystroke
- Tree-sitter: O(log n) incremental update + O(visible lines) highlight

---

## 5️⃣ RADICAL SOLUTIONS

### OPTION A: Tree-sitter Integration (Recommended)
```swift
// Replace VSCodeSyntaxHighlighter with Tree-sitter
// Swift package: https://github.com/nicklockwood/SwiftTreeSitter

import SwiftTreeSitter

class TreeSitterHighlighter {
    private var parser: Parser
    private var tree: Tree?
    
    func applyEdit(_ edit: InputEdit) {
        // O(log n) - only re-parses affected region
        tree?.edit(edit)
        tree = parser.parse(tree: tree, string: text)
    }
    
    func highlightVisibleRange(_ range: NSRange) {
        // Query only visible nodes from syntax tree
        let query = try! Query(language: language, source: highlightQuery)
        let cursor = QueryCursor()
        cursor.execute(query: query, node: tree!.rootNode)
        // ... apply highlights only to visible nodes
    }
}
```

**Effort:** 1-2 weeks  
**Impact:** 10-100x faster for large files

### OPTION B: TextKit 2 Migration
```swift
// Use NSTextContentStorage for efficient editing
let contentStorage = NSTextContentStorage()
let layoutManager = NSTextLayoutManager()

// Implement NSTextContentStorageDelegate
func textContentStorage(
    _ storage: NSTextContentStorage,
    textParagraphWith range: NSRange
) -> NSTextParagraph? {
    // Only process changed paragraph, not entire document
}
```

**Effort:** 2-3 weeks  
**Impact:** Native iOS 15+ text editing performance

### OPTION C: Incremental Highlighting (Quick Win)
```swift
// Instead of replacing entire attributedText, edit in place
func applyIncrementalHighlight(editRange: NSRange, newText: String) {
    textView.textStorage.beginEditing()
    
    // 1. Update only the changed range
    textView.textStorage.replaceCharacters(in: editRange, with: newText)
    
    // 2. Re-highlight only affected lines (not entire document)
    let affectedRange = expandToLinesBoundaries(editRange)
    let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
    let affectedText = (textView.text as NSString).substring(with: affectedRange)
    
    // Apply attributes directly to textStorage (no full replacement!)
    applyHighlightAttributes(to: textView.textStorage, range: affectedRange, text: affectedText)
    
    textView.textStorage.endEditing()
}
```

**Effort:** 2-3 days  
**Impact:** 3-5x faster for typical editing

### OPTION D: Switch to Runestone
```swift
// Literally use Runestone as dependency
import Runestone

let textView = TextView()
textView.setLanguageMode(TreeSitterLanguageMode(language: .swift))
```

**Effort:** 3-5 days (integration work)  
**Impact:** Production-proven performance

---

## 📋 ACTIONABLE NEXT STEPS

### Immediate (This Week)
1. Add timing instrumentation (see code above)
2. Profile with Instruments to confirm bottleneck location
3. Implement **Option C (Incremental Highlighting)** as quick win

### Short-term (2-4 Weeks)
4. Integrate Tree-sitter via SwiftTreeSitter package
5. Replace regex patterns with tree-sitter queries
6. Add visible-range-only highlighting for ALL file sizes

### Long-term (1-2 Months)
7. Consider TextKit 2 migration (iOS 15+ only)
8. Or adopt Runestone as drop-in replacement

---

## FILES EXAMINED
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift` (2289 lines)
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift` (274 lines)
- `VSCodeiPadOS/VSCodeiPadOS/SyntaxHighlighter_Optimizations.md`
- Runestone GitHub repository documentation
>>>END
