# Agent: swiftui-binding-perf
**Status:** done
**Tokens:** 8,265
**Cost:** $0.0000
**Time:** 2026-02-10T14:30:48.295Z

## Task
CRITICAL: Investigate SwiftUI binding overhead causing typing lag in VSCodeiPadOS.

Read VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift FULLY.

Investigate:
1. How many @Binding properties does SyntaxHighlightingTextView have?
2. How often are bindings updated during typing? (every keystroke?)
3. Is updateUIView being called too frequently?
4. Are DispatchQueue.main.async calls causing SwiftUI re-renders?
5. Is EditorCore ObservableObject causing cascading updates?

Report: ALL SwiftUI/binding-related performance issues with line numbers and CONCRETE fixes.

## Response
I'll investigate the SwiftUI binding overhead in SyntaxHighlightingTextView.swift. Let me read the full file first.

>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

Let me read the file in sections to find the critical parts - updateUIView and the Coordinator.

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


Let me read the beginning of the file to see all the @Binding properties:

>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1, "end_line": 100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-100 of 2289)
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
16:     /// Pixel scroll offset (contentOffset.y) for smooth gutter alignment.
17:     @Binding var scrollOffset: CGFloat
18:     @Binding var totalLines: Int
19:     @Binding var visibleLines: Int
20:     @Binding var currentLineNumber: Int
21:     @Binding var currentColumn: Int
22:     @Binding var cursorIndex: Int
23:     @Binding var lineHeight: CGFloat
24:     @Binding var requestedLineSelection: Int?
25:     @Binding var requestedCursorIndex: Int?
26: 
27:     /// Autocomplete key handling hooks (return true if handled)
28:     let onAcceptAutocomplete: (() -> Bool)?
29:     let onDismissAutocomplete: (() -> Bool)?
30: 
31:     let isActive: Bool
32:     let fontSize: CGFloat  // Explicit parameter to trigger SwiftUI updates
33:     @EnvironmentObject var editorCore: EditorCore
34: 
35:     init(
36:         text: Binding<String>,
37:         filename: String,
38:         scrollPosition: Binding<Int>,
39:         scrollOffset: Binding<CGFloat> = .constant(0),
40:         totalLines: Binding<Int>,
41:         visibleLines: Binding<Int>,
42:         currentLineNumber: Binding<Int>,
43:         currentColumn: Binding<Int>,
44:         cursorIndex: Binding<Int> = .constant(0),
45:         lineHeight: Binding<CGFloat>,
46:         isActive: Bool,
47:         fontSize: CGFloat = 14.0,
48:         requestedLineSelection: Binding<Int?> = .constant(nil),
49:         requestedCursorIndex: Binding<Int?> = .constant(nil),
50:         onAcceptAutocomplete: (() -> Bool)? = nil,
51:         onDismissAutocomplete: (() -> Bool)? = nil
52:     ) {
53:         self._text = text
54:         self.filename = filename
55:         self._scrollPosition = scrollPosition
56:         self._scrollOffset = scrollOffset
57:         self._totalLines = totalLines
58:         self._visibleLines = visibleLines
59:         self._currentLineNumber = currentLineNumber
60:         self._currentColumn = currentColumn
61:         self._cursorIndex = cursorIndex
62:         self._lineHeight = lineHeight
63:         self.isActive = isActive
64:         self.fontSize = fontSize
65:         self._requestedLineSelection = requestedLineSelection
66:         self._requestedCursorIndex = requestedCursorIndex
67:         self.onAcceptAutocomplete = onAcceptAutocomplete
68:         self.onDismissAutocomplete = onDismissAutocomplete
69:     }
70:     
71:     // Compatibility init for older call sites (e.g. SplitEditorView) that pass editorCore explicitly.
72:     init(
73:         text: Binding<String>,
74:         filename: String,
75:         scrollPosition: Binding<Int>,
76:         scrollOffset: Binding<CGFloat> = .constant(0),
77:         totalLines: Binding<Int>,
78:         visibleLines: Binding<Int>,
79:         currentLineNumber: Binding<Int>,
80:         currentColumn: Binding<Int>,
81:         cursorIndex: Binding<Int> = .constant(0),
82:         lineHeight: Binding<CGFloat>,
83:         isActive: Bool,
84:         editorCore: EditorCore,
85:         requestedLineSelection: Binding<Int?> = .constant(nil),
86:         requestedCursorIndex: Binding<Int?> = .constant(nil),
87:         onAcceptAutocomplete: (() -> Bool)? = nil,
88:         onDismissAutocomplete: (() -> Bool)? = nil
89:     ) {
90:         self.init(
91:             text: text,
92:             filename: filename,
93:             scrollPosition: scrollPosition,
94:             scrollOffset: scrollOffset,
95:             totalLines: totalLines,
96:             visibleLines: visibleLines,
97:             currentLineNumber: currentLineNumber,
98:             currentColumn: currentColumn,
99:             cursorIndex: cursorIndex,
100:             lineHeight: lineHeight,


Let me continue reading the Coordinator class and the textViewDidChange method:

>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 300, "end_line": 500}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 301-500 of 2289)
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


Let me continue reading to see more of the Coordinator and binding update patterns:

>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 500, "end_line": 700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 501-700 of 2289)
────────────────────────────────────────
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


Let me continue reading and also check the applySyntaxHighlighting method:

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


Now let me check the EditorCore class to see how it handles published properties:

>>>TOOL read_file
{"path": "VSCodeiPadOS/Models/EditorCore.swift", "start_line": 1, "end_line": 150}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 2-150 of 790)
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


Let me search for where these bindings are used and how EditorCore updateSelection works:

>>>TOOL search
{"query": "updateSelection", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "updateSelection"


>>>TOOL read_file
{"path": "VSCodeiPadOS/Services/EditorCore.swift", "start_line": 150, "end_line": 300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 151-300 of 790)
────────────────────────────────────────
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


>>>TOOL search
{"query": "func update.*selection", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "func update.*selection"


>>>TOOL search
{"query": "parent.editorCore.updateSelection", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "parent.editorCore.updateSelection"




>>>TOOL search
{"query": "func updateSelection", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "func updateSelection"


Let me search for the method definition in EditorCore:

>>>TOOL read_file
{"path": "VSCodeiPadOS/Services/EditorCore.swift", "start_line": 300, "end_line": 500}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 301-500 of 790)
────────────────────────────────────────
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
321:         }
322: 
323:         let started = url.startAccessingSecurityScopedResource()
324:         if started {
325:             securityScopedAccessCounts[url] = 1
326:             return true
327:         }
328: 
329:         // Not all URLs are security-scoped; startAccessing may legitimately return false.
330:         return false
331:     }
332: 
333:     private func releaseSecurityScopedAccess(to url: URL) {
334:         guard let count = securityScopedAccessCounts[url] else { return }
335:         if count <= 1 {
336:             securityScopedAccessCounts.removeValue(forKey: url)
337:             url.stopAccessingSecurityScopedResource()
338:         } else {
339:             securityScopedAccessCounts[url] = count - 1
340:         }
341:     }
342: 
343:     func openFile(from url: URL) {
344:         // If already open, just activate it (and avoid re-reading / re-requesting access).
345:         if let existingTab = tabs.first(where: { $0.url == url }) {
346:             activeTabId = existingTab.id
347:             return
348:         }
349: 
350:         // IMPORTANT (BUG-005):
351:         // Do not early-return if startAccessingSecurityScopedResource() fails.
352:         // For many URLs (non-security-scoped, or when parent scope is active), this may return false,
353:         // but the file is still readable. We retain access if available.
354:         let retained = retainSecurityScopedAccess(to: url)
355: 
356:         do {
357:             let content = try String(contentsOf: url, encoding: .utf8)
358:             addTab(fileName: url.lastPathComponent, content: content, url: url)
359: 
360:             // Index the file in Spotlight for search
361:             SpotlightManager.shared.indexFile(url: url, content: content, fileName: url.lastPathComponent)
362:         } catch {
363:             print("Error opening file: \(error)")
364:             if retained {
365:                 // We retained access but failed to open; release our retain.
366:                 releaseSecurityScopedAccess(to: url)
367:             }
368:         }
369:     }
370: 
371:     func openFile(_ fileItem: FileItem) {
372:         guard let url = fileItem.url else {
373:             // Try path
374:             if !fileItem.path.isEmpty {
375:                 let fileURL = URL(fileURLWithPath: fileItem.path)
376:                 openFile(from: fileURL)
377:             }
378:             return
379:         }
380:         openFile(from: url)
381:     }
382: 
383:     // MARK: - File System Event Handlers
384: 
385:     /// Called when a file or folder is moved/renamed in the file system.
386:     /// Updates any open tabs that reference the old URL.
387:     func handleFileSystemItemMoved(from oldURL: URL, to newURL: URL) {
388:         for index in tabs.indices {
389:             guard let tabURL = tabs[index].url else { continue }
390: 
391:             // Check if tab URL matches the moved item or is inside it (for folders)
392:             let oldPath = oldURL.standardizedFileURL.path
393:             let tabPath = tabURL.standardizedFileURL.path
394: 
395:             if tabPath == oldPath {
396:                 // Direct match - update URL
397:                 tabs[index].url = newURL
398:                 tabs[index].fileName = newURL.lastPathComponent
399:             } else if tabPath.hasPrefix(oldPath + "/") {
400:                 // Tab is inside a moved folder - update the path prefix
401:                 let relativePath = String(tabPath.dropFirst(oldPath.count))
402:                 let newTabURL = URL(fileURLWithPath: newURL.path + relativePath)
403:                 tabs[index].url = newTabURL
404:             }
405:         }
406:     }
407: 
408:     /// Called when a file or folder is deleted from the file system.
409:     /// Closes any open tabs that reference the deleted item.
410:     func handleFileSystemItemDeleted(at url: URL) {
411:         let deletedPath = url.standardizedFileURL.path
412: 
413:         // Find all tabs that should be closed
414:         let tabsToClose = tabs.filter { tab in
415:             guard let tabURL = tab.url else { return false }
416:             let tabPath = tabURL.standardizedFileURL.path
417:             // Close if exact match or if tab is inside deleted folder
418:             return tabPath == deletedPath || tabPath.hasPrefix(deletedPath + "/")
419:         }
420: 
421:         // Close the tabs (release security access)
422:         for tab in tabsToClose {
423:             closeTab(id: tab.id)
424:         }
425:     }
426: 
427:     // MARK: - UI Toggles
428: 
429:     func toggleSidebar() {
430:         withAnimation(.spring(response: 0.3)) {
431:             showSidebar.toggle()
432:         }
433:     }
434: 
435:     func toggleCommandPalette() {
436:         showCommandPalette.toggle()
437:     }
438: 
439:     func toggleQuickOpen() {
440:         showQuickOpen.toggle()
441:     }
442: 
443:     func toggleSearch() {
444:         showSearch.toggle()
445:     }
446: 
447:     func toggleAIAssistant() {
448:         showAIAssistant.toggle()
449:     }
450: 
451:     func toggleGoToSymbol() {
452:         showGoToSymbol.toggle()
453:     }
454: 
455:     func toggleZenMode() {
456:         isZenMode.toggle()
457:     }
458: 
459:     func toggleFocusMode() {
460:         isFocusMode.toggle()
461:     }
462: 
463:     func togglePanel() {
464:         withAnimation(.spring(response: 0.3)) {
465:             showPanel.toggle()
466:         }
467:     }
468: 
469:     func addSelectionToNextFindMatch() {
470:         addNextOccurrence()
471:     }
472: 
473:     func zoomIn() {
474:         editorFontSize = min(editorFontSize + 2, 32)
475:     }
476: 
477:     func zoomOut() {
478:         editorFontSize = max(editorFontSize - 2, 8)
479:     }
480: 
481:     func resetZoom() {
482:         editorFontSize = 14.0
483:     }
484: 
485:     func focusExplorer() {
486:         focusedView = .explorer
487:         focusedSidebarTab = 0
488:         withAnimation {
489:             showSidebar = true
490:         }
491:     }
492: 
493:     func focusGit() {
494:         focusedView = .git
495:         focusedSidebarTab = 1
496:         withAnimation {
497:             showSidebar = true
498:         }
499:     }
500: 


>>>TOOL search
{"query": "updateSelection(range:", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "updateSelection(range:"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift", "start_line": 300, "end_line": 500}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 301-500 of 790)
────────────────────────────────────────
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
321:         }
322: 
323:         let started = url.startAccessingSecurityScopedResource()
324:         if started {
325:             securityScopedAccessCounts[url] = 1
326:             return true
327:         }
328: 
329:         // Not all URLs are security-scoped; startAccessing may legitimately return false.
330:         return false
331:     }
332: 
333:     private func releaseSecurityScopedAccess(to url: URL) {
334:         guard let count = securityScopedAccessCounts[url] else { return }
335:         if count <= 1 {
336:             securityScopedAccessCounts.removeValue(forKey: url)
337:             url.stopAccessingSecurityScopedResource()
338:         } else {
339:             securityScopedAccessCounts[url] = count - 1
340:         }
341:     }
342: 
343:     func openFile(from url: URL) {
344:         // If already open, just activate it (and avoid re-reading / re-requesting access).
345:         if let existingTab = tabs.first(where: { $0.url == url }) {
346:             activeTabId = existingTab.id
347:             return
348:         }
349: 
350:         // IMPORTANT (BUG-005):
351:         // Do not early-return if startAccessingSecurityScopedResource() fails.
352:         // For many URLs (non-security-scoped, or when parent scope is active), this may return false,
353:         // but the file is still readable. We retain access if available.
354:         let retained = retainSecurityScopedAccess(to: url)
355: 
356:         do {
357:             let content = try String(contentsOf: url, encoding: .utf8)
358:             addTab(fileName: url.lastPathComponent, content: content, url: url)
359: 
360:             // Index the file in Spotlight for search
361:             SpotlightManager.shared.indexFile(url: url, content: content, fileName: url.lastPathComponent)
362:         } catch {
363:             print("Error opening file: \(error)")
364:             if retained {
365:                 // We retained access but failed to open; release our retain.
366:                 releaseSecurityScopedAccess(to: url)
367:             }
368:         }
369:     }
370: 
371:     func openFile(_ fileItem: FileItem) {
372:         guard let url = fileItem.url else {
373:             // Try path
374:             if !fileItem.path.isEmpty {
375:                 let fileURL = URL(fileURLWithPath: fileItem.path)
376:                 openFile(from: fileURL)
377:             }
378:             return
379:         }
380:         openFile(from: url)
381:     }
382: 
383:     // MARK: - File System Event Handlers
384: 
385:     /// Called when a file or folder is moved/renamed in the file system.
386:     /// Updates any open tabs that reference the old URL.
387:     func handleFileSystemItemMoved(from oldURL: URL, to newURL: URL) {
388:         for index in tabs.indices {
389:             guard let tabURL = tabs[index].url else { continue }
390: 
391:             // Check if tab URL matches the moved item or is inside it (for folders)
392:             let oldPath = oldURL.standardizedFileURL.path
393:             let tabPath = tabURL.standardizedFileURL.path
394: 
395:             if tabPath == oldPath {
396:                 // Direct match - update URL
397:                 tabs[index].url = newURL
398:                 tabs[index].fileName = newURL.lastPathComponent
399:             } else if tabPath.hasPrefix(oldPath + "/") {
400:                 // Tab is inside a moved folder - update the path prefix
401:                 let relativePath = String(tabPath.dropFirst(oldPath.count))
402:                 let newTabURL = URL(fileURLWithPath: newURL.path + relativePath)
403:                 tabs[index].url = newTabURL
404:             }
405:         }
406:     }
407: 
408:     /// Called when a file or folder is deleted from the file system.
409:     /// Closes any open tabs that reference the deleted item.
410:     func handleFileSystemItemDeleted(at url: URL) {
411:         let deletedPath = url.standardizedFileURL.path
412: 
413:         // Find all tabs that should be closed
414:         let tabsToClose = tabs.filter { tab in
415:             guard let tabURL = tab.url else { return false }
416:             let tabPath = tabURL.standardizedFileURL.path
417:             // Close if exact match or if tab is inside deleted folder
418:             return tabPath == deletedPath || tabPath.hasPrefix(deletedPath + "/")
419:         }
420: 
421:         // Close the tabs (release security access)
422:         for tab in tabsToClose {
423:             closeTab(id: tab.id)
424:         }
425:     }
426: 
427:     // MARK: - UI Toggles
428: 
429:     func toggleSidebar() {
430:         withAnimation(.spring(response: 0.3)) {
431:             showSidebar.toggle()
432:         }
433:     }
434: 
435:     func toggleCommandPalette() {
436:         showCommandPalette.toggle()
437:     }
438: 
439:     func toggleQuickOpen() {
440:         showQuickOpen.toggle()
441:     }
442: 
443:     func toggleSearch() {
444:         showSearch.toggle()
445:     }
446: 
447:     func toggleAIAssistant() {
448:         showAIAssistant.toggle()
449:     }
450: 
451:     func toggleGoToSymbol() {
452:         showGoToSymbol.toggle()
453:     }
454: 
455:     func toggleZenMode() {
456:         isZenMode.toggle()
457:     }
458: 
459:     func toggleFocusMode() {
460:         isFocusMode.toggle()
461:     }
462: 
463:     func togglePanel() {
464:         withAnimation(.spring(response: 0.3)) {
465:             showPanel.toggle()
466:         }
467:     }
468: 
469:     func addSelectionToNextFindMatch() {
470:         addNextOccurrence()
471:     }
472: 
473:     func zoomIn() {
474:         editorFontSize = min(editorFontSize + 2, 32)
475:     }
476: 
477:     func zoomOut() {
478:         editorFontSize = max(editorFontSize - 2, 8)
479:     }
480: 
481:     func resetZoom() {
482:         editorFontSize = 14.0
483:     }
484: 
485:     func focusExplorer() {
486:         focusedView = .explorer
487:         focusedSidebarTab = 0
488:         withAnimation {
489:             showSidebar = true
490:         }
491:     }
492: 
493:     func focusGit() {
494:         focusedView = .git
495:         focusedSidebarTab = 1
496:         withAnimation {
497:             showSidebar = true
498:         }
499:     }
500: 


>>>TOOL search
{"query": "currentSelection", "glob": "*EditorCore.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "currentSelection"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift", "start_line": 500, "end_line": 700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 501-700 of 790)
────────────────────────────────────────
501:     func renameSymbol() {
502:         showRenameSymbol.toggle()
503:     }
504: 
505:     // NOTE:
506:     // goToDefinitionAtCursor(), peekDefinitionAtCursor(), navigateBack(), and navigateForward()
507:     // are implemented in an EditorCore extension in Services/NavigationManager.swift.
508: 
509:     // MARK: - Peek Definition
510: 
511:     func triggerPeekDefinition(file: String, line: Int, content: String, sourceLine: Int) {
512:         peekState = PeekState(file: file, line: line, content: content, sourceLine: sourceLine)
513:     }
514: 
515:     func closePeekDefinition() {
516:         peekState = nil
517:     }
518: 
519:     // MARK: - Multi-Cursor Operations
520: 
521:     /// Add cursor at a specific position (Option+Click)
522:     func addCursorAtPosition(_ position: Int) {
523:         multiCursorState.addCursor(at: position)
524:     }
525: 
526:     /// Add cursor on the line above (Cmd+Option+Up)
527:     func addCursorAbove() {
528:         guard let index = activeTabIndex else { return }
529:         let content = tabs[index].content
530:         
531:         guard let primary = multiCursorState.primaryCursor else { return }
532:         
533:         // Find current line and column
534:         let lines = content.components(separatedBy: "\n")
535:         var currentLine = 0
536:         var charCount = 0
537:         var columnInLine = 0
538:         
539:         for (lineIndex, line) in lines.enumerated() {
540:             let lineLength = line.count + 1 // +1 for newline
541:             if charCount + lineLength > primary.position {
542:                 currentLine = lineIndex
543:                 columnInLine = primary.position - charCount
544:                 break
545:             }
546:             charCount += lineLength
547:         }
548:         
549:         // Can't add cursor above line 0
550:         guard currentLine > 0 else { return }
551:         
552:         // Calculate position on line above
553:         let targetLine = currentLine - 1
554:         var targetPosition = 0
555:         for i in 0..<targetLine {
556:             targetPosition += lines[i].count + 1
557:         }
558:         targetPosition += min(columnInLine, lines[targetLine].count)
559:         
560:         multiCursorState.addCursor(at: targetPosition)
561:     }
562: 
563:     /// Add cursor on the line below (Cmd+Option+Down)
564:     func addCursorBelow() {
565:         guard let index = activeTabIndex else { return }
566:         let content = tabs[index].content
567:         
568:         guard let primary = multiCursorState.primaryCursor else { return }
569:         
570:         // Find current line and column
571:         let lines = content.components(separatedBy: "\n")
572:         var currentLine = 0
573:         var charCount = 0
574:         var columnInLine = 0
575:         
576:         for (lineIndex, line) in lines.enumerated() {
577:             let lineLength = line.count + 1 // +1 for newline
578:             if charCount + lineLength > primary.position {
579:                 currentLine = lineIndex
580:                 columnInLine = primary.position - charCount
581:                 break
582:             }
583:             charCount += lineLength
584:         }
585:         
586:         // Can't add cursor below last line
587:         guard currentLine < lines.count - 1 else { return }
588:         
589:         // Calculate position on line below
590:         let targetLine = currentLine + 1
591:         var targetPosition = 0
592:         for i in 0..<targetLine {
593:             targetPosition += lines[i].count + 1
594:         }
595:         targetPosition += min(columnInLine, lines[targetLine].count)
596:         
597:         multiCursorState.addCursor(at: targetPosition)
598:     }
599: 
600:     /// Add next occurrence of current selection (Cmd+D)
601:     func addNextOccurrence() {
602:         guard let index = activeTabIndex else { return }
603:         let content = tabs[index].content
604: 
605:         // Get the word/selection to search for
606:         let searchText: String
607:         let startPosition: Int
608: 
609:         if let range = currentSelectionRange, range.length > 0,
610:            let swiftRange = Range(range, in: content) {
611:             searchText = String(content[swiftRange])
612:             startPosition = range.location + range.length
613:         } else if let primary = multiCursorState.primaryCursor {
614:             // No selection - select the word under cursor
615:             let wordRange = findWordAtPosition(primary.position, in: content)
616:             if let range = wordRange, range.length > 0,
617:                let swiftRange = Range(range, in: content) {
618:                 searchText = String(content[swiftRange])
619:                 startPosition = range.location + range.length
620: 
621:                 // First Cmd+D selects the word under cursor
622:                 multiCursorState.cursors = [Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)]
623:                 currentSelectionRange = range
624:                 currentSelection = searchText
625:                 return
626:             } else {
627:                 return
628:             }
629:         } else {
630:             return
631:         }
632: 
633:         // Find next occurrence
634:         if let nextRange = content.findNextOccurrence(of: searchText, after: startPosition) {
635:             // Check if this occurrence is already selected
636:             let alreadySelected = multiCursorState.cursors.contains { cursor in
637:                 if let selRange = cursor.selectionRange {
638:                     return selRange.location == nextRange.location
639:                 }
640:                 return false
641:             }
642: 
643:             if !alreadySelected {
644:                 multiCursorState.addCursorWithSelection(
645:                     position: nextRange.location + nextRange.length,
646:                     anchor: nextRange.location
647:                 )
648:             }
649:         }
650:     }
651: 
652:     /// Select all occurrences of current selection (Cmd+Shift+L)
653:     func selectAllOccurrences() {
654:         guard let index = activeTabIndex else { return }
655:         let content = tabs[index].content
656: 
657:         // Get the word/selection to search for
658:         let searchText: String
659: 
660:         if let range = currentSelectionRange, range.length > 0,
661:            let swiftRange = Range(range, in: content) {
662:             searchText = String(content[swiftRange])
663:         } else if let primary = multiCursorState.primaryCursor {
664:             // No selection - use word under cursor
665:             let wordRange = findWordAtPosition(primary.position, in: content)
666:             if let range = wordRange, range.length > 0,
667:                let swiftRange = Range(range, in: content) {
668:                 searchText = String(content[swiftRange])
669:             } else {
670:                 return
671:             }
672:         } else {
673:             return
674:         }
675: 
676:         // Find all occurrences
677:         let allRanges = content.findAllOccurrences(of: searchText)
678: 
679:         guard !allRanges.isEmpty else { return }
680: 
681:         // Create cursors for all occurrences
682:         multiCursorState.cursors = allRanges.enumerated().map { index, range in
683:             Cursor(
684:                 position: range.location + range.length,
685:                 anchor: range.location,
686:                 isPrimary: index == 0
687:             )
688:         }
689: 
690:         currentSelection = searchText
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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift", "start_line": 700, "end_line": 790}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 701-790 of 790)
────────────────────────────────────────
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
781:     }
782: }
783: 
784: // MARK: - Notification Names for Code Folding
785: 
786: extension Notification.Name {
787:     static let collapseAllFolds = Notification.Name("collapseAllFolds")
788:     static let expandAllFolds = Notification.Name("expandAllFolds")
789: }
790: 


Now I have a complete picture. Let me compile my findings into a comprehensive report.

>>>REPORT
# SwiftUI Binding Overhead Analysis: SyntaxHighlightingTextView

## Summary
**CRITICAL FINDING:** SyntaxHighlightingTextView has **11 @Binding properties** that create a cascading update storm on every keystroke, causing typing lag.

---

## 1. @Binding Property Count (Lines 13-25)

**11 @Binding properties identified:**
```swift
@Binding var text: String                    // Line 13
@Binding var scrollPosition: Int             // Line 15  
@Binding var scrollOffset: CGFloat           // Line 17
@Binding var totalLines: Int                 // Line 18
@Binding var visibleLines: Int               // Line 19
@Binding var currentLineNumber: Int          // Line 20
@Binding var currentColumn: Int              // Line 21
@Binding var cursorIndex: Int                // Line 22
@Binding var lineHeight: CGFloat             // Line 23
@Binding var requestedLineSelection: Int?    // Line 24
@Binding var requestedCursorIndex: Int?      // Line 25
```

Plus `@EnvironmentObject var editorCore: EditorCore` (line 33) with **40+ @Published properties**.

---

## 2. Binding Updates Per Keystroke

**Every single keystroke triggers:**

### In `textViewDidChange` (line 373-424):
- `parent.text = textView.text` (line 375) - **SYNCHRONOUS** binding update
- `updateLineCount(textView)` (line 422) - triggers async binding update
- `updateCursorPosition(textView)` (line 423) - triggers **3** async binding updates

### In `updateLineCount` (lines 649-661):
```swift
DispatchQueue.main.async {
    self.parent.totalLines = lineCount  // Line 659
}
```

### In `updateCursorPosition` (lines 682-686):
```swift
DispatchQueue.main.async {
    self.parent.currentLineNumber = lineNumber  // Line 683
    self.parent.currentColumn = column          // Line 684  
    self.parent.cursorIndex = cursorPosition    // Line 685
}
```

**RESULT: 4-5 binding updates per keystroke, each potentially triggering `updateUIView`**

---

## 3. updateUIView Called Too Frequently

`updateUIView` (lines 220-317) runs whenever ANY of the 11 bindings change. Each call:

1. Updates coordinator parent reference (line 224)
2. Checks/applies initial highlighting (lines 230-233)
3. Updates theme colors (lines 239-244)
4. Checks font size change & potentially re-highlights (lines 247-259)
5. Checks text change & potentially re-highlights (lines 262-271)
6. Checks scroll position (lines 275-280)
7. Handles line selection requests (lines 283-291)
8. Handles cursor index requests (lines 294-313)

**ISSUE:** No early-exit optimization. Even if only `currentColumn` changed, ALL these checks run.

---

## 4. DispatchQueue.main.async Causing SwiftUI Re-renders

**8 locations found where async binding updates trigger re-renders:**

| Line | Binding Updated | Trigger |
|------|-----------------|---------|
| 207-209 | lineHeight | makeUIView |
| 255-258 | lineHeight | updateUIView (font change) |
| 288-290 | requestedLineSelection | updateUIView |
| 306-308 | requestedCursorIndex | updateUIView |
| 416-418 | (highlighting) | textViewDidChange |
| 658-660 | totalLines | Every keystroke |
| 682-686 | currentLineNumber, currentColumn, cursorIndex | Every keystroke |
| 698-702 | scrollPosition, scrollOffset | Every scroll |

**CRITICAL:** Lines 658-686 create an **async update loop** on every keystroke:
1. User types → textViewDidChange
2. DispatchQueue.main.async updates bindings
3. SwiftUI detects binding change
4. updateUIView called
5. May trigger more async updates

---

## 5. EditorCore ObservableObject Cascading Updates

### EditorCore has 40+ @Published properties (lines 67-122):
```swift
@Published var cursorPosition = CursorPosition()     // Line 89
@Published var multiCursorState = MultiCursorState() // Line 92
@Published var currentSelection: String = ""         // Line 93
@Published var currentSelectionRange: NSRange?       // Line 94
```

### textViewDidChangeSelection (lines 587-603) updates EditorCore:
```swift
DispatchQueue.main.async { [weak self] in
    self.parent.editorCore.updateSelection(range: range, text: currentText)  // Line 589
    // ... more editorCore updates (lines 596-601)
}
```

### EditorCore.updateSelection (lines 701-712):
```swift
func updateSelection(range: NSRange?, text: String) {
    currentSelectionRange = range        // @Published - triggers re-render
    currentSelection = String(...)       // @Published - triggers re-render
}
```

**RESULT:** Every cursor movement triggers EditorCore @Published updates, which re-renders ALL views observing EditorCore!

---

## CONCRETE FIXES

### Fix 1: Batch Binding Updates (HIGH IMPACT)
**Problem:** Multiple separate DispatchQueue.main.async calls (lines 658-686, 698-702)

**Solution:** Create a single struct for cursor state:
```swift
struct CursorState {
    var lineNumber: Int
    var column: Int
    var cursorIndex: Int
    var totalLines: Int
}
@Binding var cursorState: CursorState  // Replace 4 bindings with 1
```

Update once per keystroke instead of 4 separate async calls.

### Fix 2: Add Dirty Checking to updateUIView (HIGH IMPACT)
**Problem:** Lines 220-317 do expensive work even when irrelevant bindings change

**Solution:** Track what changed and early-exit:
```swift
func updateUIView(_ textView: UITextView, context: Context) {
    context.coordinator.parent = self
    
    // Only check font if fontSize changed (line 247)
    guard context.coordinator.lastFontSize != fontSize else { return } // for font section
    
    // Only check text if text changed (line 262)
    guard textView.text != text else { return }  // for text section
}
```

### Fix 3: Throttle Cursor Position Updates (MEDIUM IMPACT)
**Problem:** updateCursorPosition runs on every keystroke (line 423)

**Solution:** Debounce like bracket matching (line 569-572):
```swift
private var cursorUpdateDebouncer: Timer?

func textViewDidChange(_ textView: UITextView) {
    parent.text = textView.text
    
    // Debounce cursor position updates - 50ms is imperceptible
    cursorUpdateDebouncer?.invalidate()
    cursorUpdateDebouncer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { [weak self] _ in
        self?.updateCursorPosition(textView)
    }
    
    updateLineCount(textView)  // Keep this for line numbers display
}
```

### Fix 4: Skip EditorCore Updates During Typing (HIGH IMPACT)
**Problem:** Lines 587-603 update EditorCore on every selection change

**Solution:** Add typing flag to skip selection sync:
```swift
private var isTyping = false

func textViewDidChange(_ textView: UITextView) {
    isTyping = true
    // ... existing code ...
    
    // Reset after debounce
    highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
        self?.isTyping = false
        // ...
    }
}

func textViewDidChangeSelection(_ textView: UITextView) {
    guard !isTyping else { return }  // Skip during active typing
    // ... rest of method
}
```

### Fix 5: Use @State for Internal Display Values (LOW IMPACT)
**Problem:** `lineHeight`, `visibleLines` are read-only display values but trigger parent re-renders

**Solution:** Move to internal @State or compute on-demand instead of binding.

---

## Files Examined
- VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (2289 lines)
- VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (790 lines)

## Priority Order for Fixes
1. **Fix 4** - Skip EditorCore updates during typing (biggest cascade source)
2. **Fix 1** - Batch binding updates (reduce update count from 5 to 1)
3. **Fix 3** - Throttle cursor updates (skip unnecessary work)
4. **Fix 2** - Dirty checking in updateUIView (reduce per-update cost)
5. **Fix 5** - Convert read-only bindings to @State (minor improvement)
>>>END
