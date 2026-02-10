# Agent: diagnose-syntax-flicker
**Status:** done
**Tokens:** 13,912
**Cost:** $0.0000
**Time:** 2026-02-09T23:14:39.789Z

## Task
CRITICAL: Syntax highlighting flickers and disappears when typing. Read VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift. Find the textViewDidChange method and check if there's a debounce issue or if highlighting is being cleared on each keystroke. Report the exact problem and fix.

## Response
I'll investigate the syntax highlighting flickering issue. Let me start by reading the file to find the `textViewDidChange` method.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query": "textViewDidChange", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "textViewDidChange"


>>>TOOL search
{"query": "func textView", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:281: func textViewDidChange(_ textView: UITextView) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:297: func textViewDidChangeSelection(_ textView: UITextView) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 270, "end_line": 400}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 271-400 of 1756)
────────────────────────────────────────
271:         weak var pinchGesture: UIPinchGestureRecognizer?
272:         private var initialFontSize: CGFloat = 0
273: 
274:         // FEAT-044: Matching bracket highlight state
275:         private var bracketHighlightRanges: [NSRange] = []
276:         
277:         init(_ parent: SyntaxHighlightingTextView) {
278:             self.parent = parent
279:         }
280:         
281:         func textViewDidChange(_ textView: UITextView) {
282:             // Update parent text
283:             parent.text = textView.text
284:             
285:             // Debounced syntax highlighting for performance
286:             highlightDebouncer?.invalidate()
287:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
288:                 DispatchQueue.main.async {
289:                     self?.applySyntaxHighlighting(to: textView)
290:                 }
291:             }
292:             
293:             updateLineCount(textView)
294:             updateCursorPosition(textView)
295:         }
296:         
297:         func textViewDidChangeSelection(_ textView: UITextView) {
298:             if !isUpdatingFromMinimap {
299:                 updateCursorPosition(textView)
300:                 updateScrollPosition(textView)
301: 
302:                 // FEAT-044: Matching bracket highlight
303:                 updateMatchingBracketHighlight(textView)
304: 
305:                 // Trigger redraw so current-line highlight/indent guides track the caret
306:                 (textView as? EditorTextView)?.setNeedsDisplay()
307: 
308:                 // Update selection in EditorCore for multi-cursor support
309:                 let range = textView.selectedRange
310:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
311: 
312:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
313:                 if !parent.editorCore.multiCursorState.isMultiCursor {
314:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
315:                 }
316:             }
317:         }
318:         
319:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
320:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
321:             updateScrollPosition(textView)
322:         }
323:         
324:         func updateLineCount(_ textView: UITextView) {
325:             let lines = textView.text.components(separatedBy: .newlines)
326:             DispatchQueue.main.async {
327:                 self.parent.totalLines = max(1, lines.count)
328:             }
329:         }
330:         
331:         func updateCursorPosition(_ textView: UITextView) {
332:             guard let selectedRange = textView.selectedTextRange else { return }
333:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
334:              
335:              let text = textView.text ?? ""
336:              let prefix = String(text.prefix(cursorPosition))
337:              let lines = prefix.components(separatedBy: .newlines)
338:              
339:              let lineNumber = lines.count
340:              let column = (lines.last?.count ?? 0) + 1
341:              
342:              DispatchQueue.main.async {
343:                  self.parent.currentLineNumber = lineNumber
344:                  self.parent.currentColumn = column
345:                  self.parent.cursorIndex = cursorPosition
346:              }
347:         }
348:         
349:         func updateScrollPosition(_ textView: UITextView) {
350:             guard let font = textView.font else { return }
351:             let lineHeight = font.lineHeight
352:             let scrollOffset = textView.contentOffset.y
353:             let line = Int(scrollOffset / lineHeight)
354:             
355:             lastKnownScrollPosition = line
356:             DispatchQueue.main.async {
357:                 self.parent.scrollPosition = line
358:             }
359:         }
360:         
361:         func scrollToLine(_ line: Int, in textView: UITextView) {
362:             guard !isUpdatingFromMinimap else { return }
363:             isUpdatingFromMinimap = true
364:             
365:             let lines = textView.text.components(separatedBy: .newlines)
366:             guard line >= 0 && line < lines.count else {
367:                 isUpdatingFromMinimap = false
368:                 return
369:             }
370:             
371:             var characterPosition = 0
372:             for i in 0..<line {
373:                 characterPosition += lines[i].count + 1
374:             }
375:             
376:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
377:                 let rect = textView.caretRect(for: position)
378:                 let targetY = max(0, rect.origin.y)
379:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
380:             }
381:             
382:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
383:                 self.isUpdatingFromMinimap = false
384:             }
385:         }
386: 
387:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
388:             let lines = textView.text.components(separatedBy: .newlines)
389:             guard line >= 0 && line < lines.count else { return }
390: 
391:             var characterPosition = 0
392:             for i in 0..<line {
393:                 characterPosition += lines[i].count + 1
394:             }
395: 
396:             // FEAT-041: select entire line (excluding trailing newline)
397:             let lineLength = (lines[line] as NSString).length
398:             let range = NSRange(location: characterPosition, length: lineLength)
399:             textView.selectedRange = range
400: 


I need to look at the `applySyntaxHighlighting` method to understand the full picture:

>>>TOOL search
{"query": "func applySyntaxHighlighting", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "func applySyntaxHighlighting"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 270, "end_line": 400}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 271-400 of 1756)
────────────────────────────────────────
271:         weak var pinchGesture: UIPinchGestureRecognizer?
272:         private var initialFontSize: CGFloat = 0
273: 
274:         // FEAT-044: Matching bracket highlight state
275:         private var bracketHighlightRanges: [NSRange] = []
276:         
277:         init(_ parent: SyntaxHighlightingTextView) {
278:             self.parent = parent
279:         }
280:         
281:         func textViewDidChange(_ textView: UITextView) {
282:             // Update parent text
283:             parent.text = textView.text
284:             
285:             // Debounced syntax highlighting for performance
286:             highlightDebouncer?.invalidate()
287:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
288:                 DispatchQueue.main.async {
289:                     self?.applySyntaxHighlighting(to: textView)
290:                 }
291:             }
292:             
293:             updateLineCount(textView)
294:             updateCursorPosition(textView)
295:         }
296:         
297:         func textViewDidChangeSelection(_ textView: UITextView) {
298:             if !isUpdatingFromMinimap {
299:                 updateCursorPosition(textView)
300:                 updateScrollPosition(textView)
301: 
302:                 // FEAT-044: Matching bracket highlight
303:                 updateMatchingBracketHighlight(textView)
304: 
305:                 // Trigger redraw so current-line highlight/indent guides track the caret
306:                 (textView as? EditorTextView)?.setNeedsDisplay()
307: 
308:                 // Update selection in EditorCore for multi-cursor support
309:                 let range = textView.selectedRange
310:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
311: 
312:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
313:                 if !parent.editorCore.multiCursorState.isMultiCursor {
314:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
315:                 }
316:             }
317:         }
318:         
319:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
320:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
321:             updateScrollPosition(textView)
322:         }
323:         
324:         func updateLineCount(_ textView: UITextView) {
325:             let lines = textView.text.components(separatedBy: .newlines)
326:             DispatchQueue.main.async {
327:                 self.parent.totalLines = max(1, lines.count)
328:             }
329:         }
330:         
331:         func updateCursorPosition(_ textView: UITextView) {
332:             guard let selectedRange = textView.selectedTextRange else { return }
333:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
334:              
335:              let text = textView.text ?? ""
336:              let prefix = String(text.prefix(cursorPosition))
337:              let lines = prefix.components(separatedBy: .newlines)
338:              
339:              let lineNumber = lines.count
340:              let column = (lines.last?.count ?? 0) + 1
341:              
342:              DispatchQueue.main.async {
343:                  self.parent.currentLineNumber = lineNumber
344:                  self.parent.currentColumn = column
345:                  self.parent.cursorIndex = cursorPosition
346:              }
347:         }
348:         
349:         func updateScrollPosition(_ textView: UITextView) {
350:             guard let font = textView.font else { return }
351:             let lineHeight = font.lineHeight
352:             let scrollOffset = textView.contentOffset.y
353:             let line = Int(scrollOffset / lineHeight)
354:             
355:             lastKnownScrollPosition = line
356:             DispatchQueue.main.async {
357:                 self.parent.scrollPosition = line
358:             }
359:         }
360:         
361:         func scrollToLine(_ line: Int, in textView: UITextView) {
362:             guard !isUpdatingFromMinimap else { return }
363:             isUpdatingFromMinimap = true
364:             
365:             let lines = textView.text.components(separatedBy: .newlines)
366:             guard line >= 0 && line < lines.count else {
367:                 isUpdatingFromMinimap = false
368:                 return
369:             }
370:             
371:             var characterPosition = 0
372:             for i in 0..<line {
373:                 characterPosition += lines[i].count + 1
374:             }
375:             
376:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
377:                 let rect = textView.caretRect(for: position)
378:                 let targetY = max(0, rect.origin.y)
379:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
380:             }
381:             
382:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
383:                 self.isUpdatingFromMinimap = false
384:             }
385:         }
386: 
387:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
388:             let lines = textView.text.components(separatedBy: .newlines)
389:             guard line >= 0 && line < lines.count else { return }
390: 
391:             var characterPosition = 0
392:             for i in 0..<line {
393:                 characterPosition += lines[i].count + 1
394:             }
395: 
396:             // FEAT-041: select entire line (excluding trailing newline)
397:             let lineLength = (lines[line] as NSString).length
398:             let range = NSRange(location: characterPosition, length: lineLength)
399:             textView.selectedRange = range
400: 


Now I need to find the `applySyntaxHighlighting` method to see what it does:

>>>TOOL search
{"query": "applySyntaxHighlighting", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 6 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:184: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:204: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:219: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:223: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:289: self?.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:409: func applySyntaxHighlighting(to textView: UITextView) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 409, "end_line": 550}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 410-550 of 1756)
────────────────────────────────────────
410:             let theme = ThemeManager.shared.currentTheme
411:             lastThemeId = theme.id
412: 
413:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
414:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
415: 
416:             let selectedRange = textView.selectedRange
417:             textView.attributedText = attributedText
418:             textView.selectedRange = selectedRange
419: 
420:             // FEAT-044: restore matching bracket highlight after re-attributing text
421:             updateMatchingBracketHighlight(textView)
422:         }
423:         
424:         func handlePeekDefinition(in textView: UITextView) {
425:             guard let selectedRange = textView.selectedTextRange else { return }
426:             let text = textView.text ?? ""
427:             
428:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
429:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
430:                  
431:                  let prefix = String(text.prefix(location))
432:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
433:                  
434:                  parent.editorCore.triggerPeekDefinition(
435:                      file: parent.filename,
436:                      line: sourceLine,
437:                      content: text,
438:                      sourceLine: sourceLine
439:                  )
440:             }
441:         }
442:         
443:         func handleEscape() {
444:             if parent.editorCore.peekState != nil {
445:                 parent.editorCore.closePeekDefinition()
446:             } else {
447:                 parent.editorCore.escapeMultiCursor()
448:             }
449:         }
450:         
451:         func handleGoToDefinition(in textView: UITextView) {
452:             // Reuse the peek definition logic for now
453:             handlePeekDefinition(in: textView)
454:         }
455:         
456:         func handleFindReferences(in textView: UITextView) {
457:             guard let selectedRange = textView.selectedTextRange else { return }
458:             let text = textView.text ?? ""
459:             
460:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
461:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
462:                 
463:                 let prefix = String(text.prefix(location))
464:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
465:                 
466:                 // TODO: Implement find references functionality in EditorCore
467:                 // For now, just trigger peek definition as a placeholder
468:                 parent.editorCore.triggerPeekDefinition(
469:                     file: parent.filename,
470:                     line: sourceLine,
471:                     content: text,
472:                     sourceLine: sourceLine
473:                 )
474:             }
475:         }
476:         
477:         func handleFormatDocument(in textView: UITextView) {
478:             // TODO: Implement format document functionality
479:             // This would typically call a formatter in EditorCore
480:             print("Format Document: Not yet implemented")
481:         }
482:         
483:         func handleToggleComment(in textView: UITextView) {
484:             guard let selectedRange = textView.selectedTextRange else { return }
485:             let text = textView.text ?? ""
486:             
487:             // Get the current line range
488:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
489:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
490:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
491:                 let nsRange = NSRange(location: location, length: length)
492:                 
493:                 if nsRange.location + nsRange.length <= (text as NSString).length {
494:                     let lineText = (text as NSString).substring(with: nsRange)
495:                     let trimmed = lineText.trimmingCharacters(in: .whitespaces)
496:                     
497:                     // Check if line starts with a comment
498:                     let isCommented = trimmed.hasPrefix("//") || trimmed.hasPrefix("#") || trimmed.hasPrefix("/*")
499:                     
500:                     // Toggle comment
501:                     var newLineText: String
502:                     if isCommented {
503:                         // Remove comment
504:                         newLineText = lineText.replacingOccurrences(of: "//", with: "").replacingOccurrences(of: "#", with: "", options: .anchored)
505:                     } else {
506:                         // Add comment (use // for most languages)
507:                         newLineText = "//" + lineText
508:                     }
509:                     
510:                     // Replace the line
511:                     let textStorage = textView.textStorage
512:                     textStorage.replaceCharacters(in: nsRange, with: newLineText)
513:                     
514:                     // Update parent binding
515:                     parent.text = textView.text
516:                 }
517:             }
518:         }
519:         
520:         func handleFold(in textView: UITextView) {
521:             CodeFoldingManager.shared.foldCurrentLine()
522:         }
523:         
524:         func handleUnfold(in textView: UITextView) {
525:             CodeFoldingManager.shared.unfoldCurrentLine()
526:         }
527:         
528:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
529:             guard let textView = gesture.view as? UITextView else { return }
530: 
531:             switch gesture.state {
532:             case .began:
533:                 // Store the initial font size when pinch begins
534:                 initialFontSize = parent.editorCore.editorFontSize
535: 
536:             case .changed:
537:                 // Calculate new font size based on pinch scale
538:                 let newSize = initialFontSize * gesture.scale
539: 
540:                 // Clamp font size between 8 and 32
541:                 let clampedSize = min(max(newSize, 8), 32)
542: 
543:                 // Update EditorCore's font size (this will trigger updateUIView)
544:                 parent.editorCore.editorFontSize = clampedSize
545: 
546:             case .ended, .cancelled:
547:                 // Optional: snap to nearest whole number or standard size
548:                 let finalSize = round(parent.editorCore.editorFontSize)
549:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
550: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 400, "end_line": 425}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 401-425 of 1756)
────────────────────────────────────────
401:             // Ensure it's visible
402:             scrollToLine(line, in: textView)
403: 
404:             // Update SwiftUI state
405:             updateCursorPosition(textView)
406:             updateScrollPosition(textView)
407:         }
408: 
409:         func applySyntaxHighlighting(to textView: UITextView) {
410:             let theme = ThemeManager.shared.currentTheme
411:             lastThemeId = theme.id
412: 
413:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
414:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
415: 
416:             let selectedRange = textView.selectedRange
417:             textView.attributedText = attributedText
418:             textView.selectedRange = selectedRange
419: 
420:             // FEAT-044: restore matching bracket highlight after re-attributing text
421:             updateMatchingBracketHighlight(textView)
422:         }
423:         
424:         func handlePeekDefinition(in textView: UITextView) {
425:             guard let selectedRange = textView.selectedTextRange else { return }


Now I need to check the `updateUIView` method to see what happens when `parent.text` is updated:

>>>TOOL search
{"query": "func updateUIView", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 5 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:868: func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:906: func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/MarkdownPreviewView.swift:83: func updateUIView(_ uiView: WKWebView, context: Context) {}
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:190: func updateUIView(_ textView: UITextView, context: Context) {
VSCodeiPadOS/VSCodeiPadOS/Extensions/NSAttributedStringSyntaxHighlighter.swift:1138: func updateUIView(_ uiView: UITextView, context: Context) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 190, "end_line": 280}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 191-280 of 1756)
────────────────────────────────────────
191:         // Update colors when theme changes
192:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
193:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
194:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
195:         
196:         if let editorView = textView as? EditorTextView {
197:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
198:         }
199:         
200:         // Update font size if changed
201:         if let currentFont = textView.font, currentFont.pointSize != editorCore.editorFontSize {
202:             let selectedRange = textView.selectedRange
203:             textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
204:             context.coordinator.applySyntaxHighlighting(to: textView)
205:             textView.selectedRange = selectedRange
206:             
207:             // Update line height
208:             if let font = textView.font {
209:                 DispatchQueue.main.async {
210:                     self.lineHeight = font.lineHeight
211:                 }
212:             }
213:         }
214:         
215:         // Update text if changed externally
216:         if textView.text != text {
217:             let selectedRange = textView.selectedRange
218:             textView.text = text
219:             context.coordinator.applySyntaxHighlighting(to: textView)
220:             textView.selectedRange = selectedRange
221:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
222:             // Re-apply highlighting if theme changed
223:             context.coordinator.applySyntaxHighlighting(to: textView)
224:         }
225:         
226:         // Handle minimap scrolling
227:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 {
228:             context.coordinator.scrollToLine(scrollPosition, in: textView)
229:         }
230: 
231:         // Handle line selection requests (e.g. tapping line numbers)
232:         if let requested = requestedLineSelection,
233:            requested != context.coordinator.lastRequestedLineSelection {
234:             context.coordinator.lastRequestedLineSelection = requested
235:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
236:             // Defer @Binding update to avoid "Publishing changes from within view updates"
237:             DispatchQueue.main.async {
238:                 self.requestedLineSelection = nil
239:             }
240:         }
241: 
242:         // Handle cursor index requests (e.g. accepting autocomplete)
243:         if let requested = requestedCursorIndex,
244:            requested != context.coordinator.lastRequestedCursorIndex {
245:             context.coordinator.lastRequestedCursorIndex = requested
246:             textView.selectedRange = NSRange(location: max(0, requested), length: 0)
247:             // Defer @Binding update to avoid "Publishing changes from within view updates"
248:             DispatchQueue.main.async {
249:                 self.requestedCursorIndex = nil
250:             }
251: 
252:             // Update SwiftUI state
253:             context.coordinator.updateCursorPosition(textView)
254:             context.coordinator.updateScrollPosition(textView)
255:         }
256:         
257:         // Note: updateLineCount is called in textViewDidChange, no need to call here
258:         // as it causes unnecessary state churn on every updateUIView
259:     }
260:     
261:     // MARK: - Coordinator
262:     
263:     class Coordinator: NSObject, UITextViewDelegate {
264:         var parent: SyntaxHighlightingTextView
265:         var lastKnownScrollPosition: Int = 0
266:         var lastThemeId: String = ""
267:         var lastRequestedLineSelection: Int? = nil
268:         var lastRequestedCursorIndex: Int? = nil
269:         private var isUpdatingFromMinimap = false
270:         private var highlightDebouncer: Timer?
271:         weak var pinchGesture: UIPinchGestureRecognizer?
272:         private var initialFontSize: CGFloat = 0
273: 
274:         // FEAT-044: Matching bracket highlight state
275:         private var bracketHighlightRanges: [NSRange] = []
276:         
277:         init(_ parent: SyntaxHighlightingTextView) {
278:             self.parent = parent
279:         }
280:         


Now I need to check the full `updateUIView` function to see the complete picture:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 150, "end_line": 220}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 151-220 of 1756)
────────────────────────────────────────
151:         textView.addGestureRecognizer(pinchGesture)
152:         context.coordinator.pinchGesture = pinchGesture
153:         
154:         // Configure text view
155:         textView.isEditable = true
156:         textView.isSelectable = true
157:         textView.autocapitalizationType = .none
158:         textView.autocorrectionType = .no
159:         textView.smartDashesType = .no
160:         textView.smartQuotesType = .no
161:         textView.smartInsertDeleteType = .no
162:         textView.spellCheckingType = .no
163:         
164:         // Set font and appearance (use editorCore.editorFontSize)
165:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
166:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
167:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
168:         textView.keyboardType = .default
169:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
170:         
171:         // Enable line wrapping
172:         textView.textContainer.lineBreakMode = .byCharWrapping
173:         textView.textContainer.widthTracksTextView = true
174:         
175:         // Calculate line height
176:         if let font = textView.font {
177:             DispatchQueue.main.async {
178:                 self.lineHeight = font.lineHeight
179:             }
180:         }
181:         
182:         // Set initial text with syntax highlighting
183:         textView.text = text
184:         context.coordinator.applySyntaxHighlighting(to: textView)
185:         context.coordinator.updateLineCount(textView)
186:         
187:         return textView
188:     }
189:     
190:     func updateUIView(_ textView: UITextView, context: Context) {
191:         // Update colors when theme changes
192:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
193:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
194:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
195:         
196:         if let editorView = textView as? EditorTextView {
197:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
198:         }
199:         
200:         // Update font size if changed
201:         if let currentFont = textView.font, currentFont.pointSize != editorCore.editorFontSize {
202:             let selectedRange = textView.selectedRange
203:             textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
204:             context.coordinator.applySyntaxHighlighting(to: textView)
205:             textView.selectedRange = selectedRange
206:             
207:             // Update line height
208:             if let font = textView.font {
209:                 DispatchQueue.main.async {
210:                     self.lineHeight = font.lineHeight
211:                 }
212:             }
213:         }
214:         
215:         // Update text if changed externally
216:         if textView.text != text {
217:             let selectedRange = textView.selectedRange
218:             textView.text = text
219:             context.coordinator.applySyntaxHighlighting(to: textView)
220:             textView.selectedRange = selectedRange


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 400, "end_line": 430}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 401-430 of 1756)
────────────────────────────────────────
401:             // Ensure it's visible
402:             scrollToLine(line, in: textView)
403: 
404:             // Update SwiftUI state
405:             updateCursorPosition(textView)
406:             updateScrollPosition(textView)
407:         }
408: 
409:         func applySyntaxHighlighting(to textView: UITextView) {
410:             let theme = ThemeManager.shared.currentTheme
411:             lastThemeId = theme.id
412: 
413:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
414:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
415: 
416:             let selectedRange = textView.selectedRange
417:             textView.attributedText = attributedText
418:             textView.selectedRange = selectedRange
419: 
420:             // FEAT-044: restore matching bracket highlight after re-attributing text
421:             updateMatchingBracketHighlight(textView)
422:         }
423:         
424:         func handlePeekDefinition(in textView: UITextView) {
425:             guard let selectedRange = textView.selectedTextRange else { return }
426:             let text = textView.text ?? ""
427:             
428:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
429:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
430:                  


Now let me check if there's a `typingAttributes` setup or any issue with how new text is styled:

>>>TOOL search
{"query": "typingAttributes", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "typingAttributes"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 400, "end_line": 430}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 401-430 of 1756)
────────────────────────────────────────
401:             // Ensure it's visible
402:             scrollToLine(line, in: textView)
403: 
404:             // Update SwiftUI state
405:             updateCursorPosition(textView)
406:             updateScrollPosition(textView)
407:         }
408: 
409:         func applySyntaxHighlighting(to textView: UITextView) {
410:             let theme = ThemeManager.shared.currentTheme
411:             lastThemeId = theme.id
412: 
413:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
414:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
415: 
416:             let selectedRange = textView.selectedRange
417:             textView.attributedText = attributedText
418:             textView.selectedRange = selectedRange
419: 
420:             // FEAT-044: restore matching bracket highlight after re-attributing text
421:             updateMatchingBracketHighlight(textView)
422:         }
423:         
424:         func handlePeekDefinition(in textView: UITextView) {
425:             guard let selectedRange = textView.selectedTextRange else { return }
426:             let text = textView.text ?? ""
427:             
428:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
429:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
430:                  


>>>TOOL search
{"query": "typingAttributes", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "typingAttributes"


Now I understand the issue. Let me check how the text view is configured to see if `typingAttributes` is being set:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 190}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-190 of 1756)
────────────────────────────────────────
101:         Coordinator(self)
102:     }
103:     
104:     func makeUIView(context: Context) -> UITextView {
105:         let textView = EditorTextView()
106:         textView.delegate = context.coordinator
107: 
108:         // Autocomplete hooks
109:         textView.onAcceptAutocomplete = onAcceptAutocomplete
110:         textView.onDismissAutocomplete = onDismissAutocomplete
111: 
112:         textView.onPeekDefinition = {
113:             context.coordinator.handlePeekDefinition(in: textView)
114:         }
115: 
116:         textView.onEscape = {
117:             context.coordinator.handleEscape()
118:         }
119: 
120:         textView.onGoToLine = {
121:             self.editorCore.showGoToLine = true
122:         }
123:         
124:         // Wire up custom context menu actions
125:         textView.onGoToDefinition = {
126:             context.coordinator.handleGoToDefinition(in: textView)
127:         }
128:         
129:         textView.onFindReferences = {
130:             context.coordinator.handleFindReferences(in: textView)
131:         }
132:         
133:         textView.onFormatDocument = {
134:             context.coordinator.handleFormatDocument(in: textView)
135:         }
136:         
137:         textView.onToggleComment = {
138:             context.coordinator.handleToggleComment(in: textView)
139:         }
140:         
141:         textView.onFold = {
142:             context.coordinator.handleFold(in: textView)
143:         }
144:         
145:         textView.onUnfold = {
146:             context.coordinator.handleUnfold(in: textView)
147:         }
148:         
149:         // Add pinch gesture for zoom
150:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
151:         textView.addGestureRecognizer(pinchGesture)
152:         context.coordinator.pinchGesture = pinchGesture
153:         
154:         // Configure text view
155:         textView.isEditable = true
156:         textView.isSelectable = true
157:         textView.autocapitalizationType = .none
158:         textView.autocorrectionType = .no
159:         textView.smartDashesType = .no
160:         textView.smartQuotesType = .no
161:         textView.smartInsertDeleteType = .no
162:         textView.spellCheckingType = .no
163:         
164:         // Set font and appearance (use editorCore.editorFontSize)
165:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
166:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
167:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
168:         textView.keyboardType = .default
169:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
170:         
171:         // Enable line wrapping
172:         textView.textContainer.lineBreakMode = .byCharWrapping
173:         textView.textContainer.widthTracksTextView = true
174:         
175:         // Calculate line height
176:         if let font = textView.font {
177:             DispatchQueue.main.async {
178:                 self.lineHeight = font.lineHeight
179:             }
180:         }
181:         
182:         // Set initial text with syntax highlighting
183:         textView.text = text
184:         context.coordinator.applySyntaxHighlighting(to: textView)
185:         context.coordinator.updateLineCount(textView)
186:         
187:         return textView
188:     }
189:     
190:     func updateUIView(_ textView: UITextView, context: Context) {


>>>TOOL search
{"query": "typingAttributes", "glob": "VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "typingAttributes"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 190}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-190 of 1756)
────────────────────────────────────────
101:         Coordinator(self)
102:     }
103:     
104:     func makeUIView(context: Context) -> UITextView {
105:         let textView = EditorTextView()
106:         textView.delegate = context.coordinator
107: 
108:         // Autocomplete hooks
109:         textView.onAcceptAutocomplete = onAcceptAutocomplete
110:         textView.onDismissAutocomplete = onDismissAutocomplete
111: 
112:         textView.onPeekDefinition = {
113:             context.coordinator.handlePeekDefinition(in: textView)
114:         }
115: 
116:         textView.onEscape = {
117:             context.coordinator.handleEscape()
118:         }
119: 
120:         textView.onGoToLine = {
121:             self.editorCore.showGoToLine = true
122:         }
123:         
124:         // Wire up custom context menu actions
125:         textView.onGoToDefinition = {
126:             context.coordinator.handleGoToDefinition(in: textView)
127:         }
128:         
129:         textView.onFindReferences = {
130:             context.coordinator.handleFindReferences(in: textView)
131:         }
132:         
133:         textView.onFormatDocument = {
134:             context.coordinator.handleFormatDocument(in: textView)
135:         }
136:         
137:         textView.onToggleComment = {
138:             context.coordinator.handleToggleComment(in: textView)
139:         }
140:         
141:         textView.onFold = {
142:             context.coordinator.handleFold(in: textView)
143:         }
144:         
145:         textView.onUnfold = {
146:             context.coordinator.handleUnfold(in: textView)
147:         }
148:         
149:         // Add pinch gesture for zoom
150:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
151:         textView.addGestureRecognizer(pinchGesture)
152:         context.coordinator.pinchGesture = pinchGesture
153:         
154:         // Configure text view
155:         textView.isEditable = true
156:         textView.isSelectable = true
157:         textView.autocapitalizationType = .none
158:         textView.autocorrectionType = .no
159:         textView.smartDashesType = .no
160:         textView.smartQuotesType = .no
161:         textView.smartInsertDeleteType = .no
162:         textView.spellCheckingType = .no
163:         
164:         // Set font and appearance (use editorCore.editorFontSize)
165:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
166:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
167:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
168:         textView.keyboardType = .default
169:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
170:         
171:         // Enable line wrapping
172:         textView.textContainer.lineBreakMode = .byCharWrapping
173:         textView.textContainer.widthTracksTextView = true
174:         
175:         // Calculate line height
176:         if let font = textView.font {
177:             DispatchQueue.main.async {
178:                 self.lineHeight = font.lineHeight
179:             }
180:         }
181:         
182:         // Set initial text with syntax highlighting
183:         textView.text = text
184:         context.coordinator.applySyntaxHighlighting(to: textView)
185:         context.coordinator.updateLineCount(textView)
186:         
187:         return textView
188:     }
189:     
190:     func updateUIView(_ textView: UITextView, context: Context) {


Now I understand the problem. Let me analyze what I've found:

**Root Cause Analysis:**

1. In `textViewDidChange` (lines 281-295), when a user types:
   - `parent.text = textView.text` is called immediately
   - Syntax highlighting is **debounced** for 0.15 seconds via a Timer
   - During this 0.15s delay, the newly typed text has **NO syntax highlighting**

2. The critical issue is that when text is typed into UITextView:
   - The new character inherits styling from `typingAttributes` (if set) or gets default/no styling
   - There is **NO `typingAttributes` set anywhere** in the codebase (confirmed by search)
   - This means newly typed characters appear unstyled until the debounced highlight runs

3. After 0.15s, `applySyntaxHighlighting` (lines 409-422) replaces the **entire** `attributedText`, causing a visible flicker as all styling changes at once.

**The Fix:**

Set `typingAttributes` after applying syntax highlighting so newly typed characters get the correct base styling. This prevents the visual flicker during the debounce period.

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
        func applySyntaxHighlighting(to textView: UITextView) {
            let theme = ThemeManager.shared.currentTheme
            lastThemeId = theme.id

            let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
            let attributedText = highlighter.highlight(textView.text, filename: parent.filename)

            let selectedRange = textView.selectedRange
            textView.attributedText = attributedText
            textView.selectedRange = selectedRange

            // FEAT-044: restore matching bracket highlight after re-attributing text
            updateMatchingBracketHighlight(textView)
        }
>>>REPLACE
        func applySyntaxHighlighting(to textView: UITextView) {
            let theme = ThemeManager.shared.currentTheme
            lastThemeId = theme.id

            let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
            let attributedText = highlighter.highlight(textView.text, filename: parent.filename)

            let selectedRange = textView.selectedRange
            textView.attributedText = attributedText
            textView.selectedRange = selectedRange

            // Set typing attributes so newly typed characters get correct base styling
            // This prevents flicker during debounce period
            textView.typingAttributes = [
                .font: UIFont.monospacedSystemFont(ofSize: parent.editorCore.editorFontSize, weight: .regular),
                .foregroundColor: UIColor(theme.editorForeground)
            ]

            // FEAT-044: restore matching bracket highlight after re-attributing text
            updateMatchingBracketHighlight(textView)
        }
>>>END

>>>REPORT
## Problem Found and Fixed

**File:** `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift`

**Root Cause:** Syntax highlighting flickers because:

1. **Lines 281-295 (`textViewDidChange`)**: When user types, syntax highlighting is debounced for 0.15 seconds via a Timer
2. **Lines 409-422 (`applySyntaxHighlighting`)**: After debounce, the entire `attributedText` is replaced
3. **Missing `typingAttributes`**: No typing attributes were set, so newly typed characters appeared unstyled (or with random inherited styling) during the 0.15s debounce period
4. When the debounced highlight finally runs, all styling changes at once, causing visible flicker

**Fix Applied:**
Added `typingAttributes` setup in `applySyntaxHighlighting` (after line 418) to set:
- Monospaced font at current editor size
- Foreground color from current theme

This ensures newly typed characters immediately get the correct base styling, eliminating the visual flicker during the debounce period. The full syntax highlighting still runs after 0.15s to apply keyword colors, but the base text styling is consistent.
>>>END
