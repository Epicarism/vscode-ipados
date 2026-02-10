# Agent: syntax-highlighting-perf
**Status:** done
**Tokens:** 6,301
**Cost:** $0.0000
**Time:** 2026-02-10T14:30:46.889Z

## Task
CRITICAL: Investigate syntax highlighting performance in VSCodeiPadOS causing lag at just 300 lines.

Read these files FULLY:
1. VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift - especially textViewDidChange, applySyntaxHighlighting, applyHighlightingAsync, applyVisibleRangeHighlighting
2. VSCodeiPadOS/Services/VSCodeSyntaxHighlighter.swift (if exists) or search for syntax highlighting logic

Investigate:
- How often is highlighting triggered?
- Is debouncing actually working?
- Are we highlighting the full document or just visible range?
- Are regex patterns being compiled every time?
- Is attributedText being set causing full relayout?

Report: EXACT bottlenecks with line numbers and CONCRETE fixes with code snippets.

## Response
I'll investigate the syntax highlighting performance issue systematically. Let me start by reading the main files.

>>>TOOL read_file
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

Let me get the symbols to find the key methods:

>>>TOOL get_symbols
{"path": "VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[get_symbols]
Error getting symbols: Error: Unable to read file '/Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift' (Error: Unable to resolve nonexistent file '/Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift')


Let me find the correct path:

>>>TOOL search
{"query": "textViewDidChange applySyntaxHighlighting", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "textViewDidChange applySyntaxHighlighting"


>>>TOOL search
{"query": "func textViewDidChange", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "func textViewDidChange"


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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1, "end_line": 200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-200 of 2289)
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


Let me continue reading to find the Coordinator class and syntax highlighting methods:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 200, "end_line": 500}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 201-500 of 2289)
────────────────────────────────────────
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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 500, "end_line": 800}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 501-800 of 2289)
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


Now let me find and read the VSCodeSyntaxHighlighter:

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
{"query": "func highlight", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "func highlight"


>>>TOOL search
{"query": "SyntaxHighlighter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "SyntaxHighlighter"


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


Let me continue reading the highlighter helper functions:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1800, "end_line": 2100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1801-2100 of 2289)
────────────────────────────────────────
1801:         // Function names (yellow) - regular calls + arrow functions
1802:         let funcNamePattern = "\\b([a-zA-Z_$][a-zA-Z0-9_$]*)\\b(?=\\s*(?:\\(|=>))"
1803:         highlightPattern(attributed, pattern: funcNamePattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1804:         
1805:         // Types (teal)
1806:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1807:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1808:         
1809:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1810:         highlightStrings(attributed, text: text)
1811:         highlightJSTemplateLiterals(attributed, text: text)
1812:         highlightNumbers(attributed, text: text)
1813:     }
1814:     
1815:     // MARK: - Python Highlighting
1816:     
1817:     private func highlightPython(_ attributed: NSMutableAttributedString, text: String) {
1818:         let keywords = ["def", "class", "if", "elif", "else", "for", "while", "return",
1819:                        "import", "from", "as", "try", "except", "finally", "raise",
1820:                        "with", "assert", "yield", "lambda", "pass", "break", "continue",
1821:                        "global", "nonlocal", "del", "in", "not", "and", "or", "is",
1822:                        "async", "await", "match", "case"]
1823:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1824:         
1825:         let constants = ["True", "False", "None", "self", "cls"]
1826:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1827:         
1828:         // Decorators (yellow)
1829:         let decoratorPattern = "@[a-zA-Z_][a-zA-Z0-9_\\.]*"
1830:         highlightPattern(attributed, pattern: decoratorPattern, color: UIColor(theme.function), text: text)
1831:         
1832:         // Function definitions (yellow)
1833:         let funcDefPattern = "(?<=def\\s)[a-zA-Z_][a-zA-Z0-9_]*"
1834:         highlightPattern(attributed, pattern: funcDefPattern, color: UIColor(theme.function), text: text)
1835:         
1836:         // Class names (teal)
1837:         let classPattern = "(?<=class\\s)[a-zA-Z_][a-zA-Z0-9_]*"
1838:         highlightPattern(attributed, pattern: classPattern, color: UIColor(theme.type), text: text)
1839:         
1840:         // Built-in functions (yellow)
1841:         let builtins = ["print", "len", "range", "str", "int", "float", "list", "dict", "set",
1842:                        "tuple", "bool", "type", "isinstance", "hasattr", "getattr", "setattr",
1843:                        "open", "input", "map", "filter", "reduce", "zip", "enumerate",
1844:                        "sorted", "reversed", "min", "max", "sum", "abs", "round",
1845:                        "super", "object", "Exception", "ValueError", "TypeError"]
1846:         highlightKeywords(attributed, keywords: builtins, color: UIColor(theme.function), text: text)
1847:         
1848:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1849:         highlightPythonStrings(attributed, text: text)
1850:         highlightNumbers(attributed, text: text)
1851:     }
1852:     
1853:     // MARK: - HTML Highlighting
1854:     
1855:     private func highlightHTML(_ attributed: NSMutableAttributedString, text: String) {
1856:         // Tags (blue)
1857:         let tagPattern = "</?\\s*([a-zA-Z][a-zA-Z0-9-]*)(?=[\\s>])"
1858:         highlightPattern(attributed, pattern: tagPattern, color: UIColor(theme.keyword), text: text)
1859:         
1860:         // Attributes (light blue)
1861:         let attrPattern = "\\s([a-zA-Z][a-zA-Z0-9-]*)\\s*="
1862:         highlightPattern(attributed, pattern: attrPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
1863:         
1864:         // Angle brackets
1865:         let bracketPattern = "[<>/?]"
1866:         highlightPattern(attributed, pattern: bracketPattern, color: UIColor.gray, text: text)
1867:         
1868:         // Comments
1869:         highlightHTMLComments(attributed, text: text)
1870:         
1871:         // Strings
1872:         highlightStrings(attributed, text: text)
1873:     }
1874:     
1875:     // MARK: - CSS Highlighting
1876:     
1877:     private func highlightCSS(_ attributed: NSMutableAttributedString, text: String) {
1878:         // Selectors (yellow)
1879:         let selectorPattern = "([.#]?[a-zA-Z][a-zA-Z0-9_-]*)\\s*\\{"
1880:         highlightPattern(attributed, pattern: selectorPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1881:         
1882:         // Properties (light blue)
1883:         let propertyPattern = "([a-zA-Z-]+)\\s*:"
1884:         highlightPattern(attributed, pattern: propertyPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
1885:         
1886:         // Values with units
1887:         let unitPattern = "\\b(\\d+)(px|em|rem|%|vh|vw|pt|cm|mm|in)\\b"
1888:         highlightPattern(attributed, pattern: unitPattern, color: UIColor(theme.number), text: text)
1889:         
1890:         // Colors
1891:         let hexPattern = "#[0-9a-fA-F]{3,8}\\b"
1892:         highlightPattern(attributed, pattern: hexPattern, color: UIColor(theme.number), text: text)
1893:         
1894:         // Keywords
1895:         let keywords = ["important", "inherit", "initial", "unset", "none", "auto",
1896:                        "block", "inline", "flex", "grid", "absolute", "relative", "fixed"]
1897:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1898:         
1899:         highlightComments(attributed, text: text, singleLine: nil, multiLineStart: "/*", multiLineEnd: "*/")
1900:         highlightStrings(attributed, text: text)
1901:         highlightNumbers(attributed, text: text)
1902:     }
1903:     
1904:     // MARK: - JSON Highlighting
1905:     
1906:     private func highlightJSON(_ attributed: NSMutableAttributedString, text: String) {
1907:         // Keys (light blue)
1908:         let keyPattern = "\"([^\"]+)\"\\s*:"
1909:         highlightPattern(attributed, pattern: keyPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
1910:         
1911:         // String values (orange)
1912:         highlightStrings(attributed, text: text)
1913:         
1914:         // Numbers (light green)
1915:         highlightNumbers(attributed, text: text)
1916:         
1917:         // Booleans and null (use keyword color)
1918:         let constants = ["true", "false", "null"]
1919:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.keyword), text: text)
1920:     }
1921:     
1922:     // MARK: - Markdown Highlighting
1923:     
1924:     private func highlightMarkdown(_ attributed: NSMutableAttributedString, text: String) {
1925:         // Headers (blue + bold)
1926:         let headerPattern = "^#{1,6}\\s+.+$"
1927:         highlightPattern(attributed, pattern: headerPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
1928:         
1929:         // Bold (orange)
1930:         let boldPattern = "\\*\\*[^*]+\\*\\*|__[^_]+__"
1931:         highlightPattern(attributed, pattern: boldPattern, color: UIColor(theme.string), text: text)
1932:         
1933:         // Italic
1934:         let italicPattern = "(?<!\\*)\\*[^*]+\\*(?!\\*)|(?<!_)_[^_]+_(?!_)"
1935:         highlightPattern(attributed, pattern: italicPattern, color: UIColor.secondaryLabel, text: text)
1936:         
1937:         // Code blocks (green)
1938:         let codeBlockPattern = "```[\\s\\S]*?```|`[^`]+`"
1939:         highlightPattern(attributed, pattern: codeBlockPattern, color: UIColor(theme.comment), text: text)
1940:         
1941:         // Links (light blue)
1942:         let linkPattern = "\\[[^\\]]+\\]\\([^)]+\\)"
1943:         highlightPattern(attributed, pattern: linkPattern, color: UIColor(theme.variable), text: text)
1944:         
1945:         // Lists
1946:         let listPattern = "^\\s*[-*+]\\s"
1947:         highlightPattern(attributed, pattern: listPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
1948:     }
1949:     
1950:     // MARK: - Rust Highlighting
1951:     
1952:     private func highlightRust(_ attributed: NSMutableAttributedString, text: String) {
1953:         let keywords = ["fn", "let", "mut", "const", "if", "else", "match", "loop", "while", "for",
1954:                        "return", "struct", "enum", "impl", "trait", "type", "use", "mod", "pub",
1955:                        "self", "Self", "super", "crate", "as", "in", "ref", "move", "async", "await",
1956:                        "where", "unsafe", "extern", "dyn", "static", "break", "continue"]
1957:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1958:         
1959:         let types = ["i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize",
1960:                     "f32", "f64", "bool", "char", "str", "String", "Vec", "Option", "Result", "Box"]
1961:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1962:         
1963:         let constants = ["true", "false", "None", "Some", "Ok", "Err"]
1964:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1965:         
1966:         // Macros (yellow)
1967:         let macroPattern = "[a-zA-Z_][a-zA-Z0-9_]*!"
1968:         highlightPattern(attributed, pattern: macroPattern, color: UIColor(theme.function), text: text)
1969:         
1970:         // Lifetimes (orange)
1971:         let lifetimePattern = "'[a-zA-Z_][a-zA-Z0-9_]*"
1972:         highlightPattern(attributed, pattern: lifetimePattern, color: UIColor(theme.string), text: text)
1973:         
1974:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1975:         highlightStrings(attributed, text: text)
1976:         highlightNumbers(attributed, text: text)
1977:     }
1978:     
1979:     // MARK: - Go Highlighting
1980:     
1981:     private func highlightGo(_ attributed: NSMutableAttributedString, text: String) {
1982:         let keywords = ["func", "var", "const", "type", "struct", "interface", "map", "chan",
1983:                        "if", "else", "for", "range", "switch", "case", "default", "select",
1984:                        "return", "break", "continue", "goto", "fallthrough", "defer", "go",
1985:                        "package", "import"]
1986:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1987:         
1988:         let types = ["int", "int8", "int16", "int32", "int64", "uint", "uint8", "uint16", "uint32", "uint64",
1989:                     "float32", "float64", "complex64", "complex128", "byte", "rune", "string", "bool", "error"]
1990:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1991:         
1992:         let constants = ["true", "false", "nil", "iota"]
1993:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1994:         
1995:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1996:         highlightStrings(attributed, text: text)
1997:         highlightNumbers(attributed, text: text)
1998:     }
1999:     
2000:     // MARK: - Java Highlighting
2001:     
2002:     private func highlightJava(_ attributed: NSMutableAttributedString, text: String) {
2003:         let keywords = ["public", "private", "protected", "class", "interface", "extends", "implements",
2004:                        "static", "final", "abstract", "native", "synchronized", "volatile", "transient",
2005:                        "if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue",
2006:                        "return", "throw", "throws", "try", "catch", "finally", "new", "this", "super",
2007:                        "import", "package", "instanceof", "assert", "enum", "void"]
2008:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2009:         
2010:         let types = ["int", "long", "short", "byte", "float", "double", "char", "boolean",
2011:                     "String", "Integer", "Long", "Double", "Boolean", "Object", "List", "Map", "Set"]
2012:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
2013:         
2014:         let constants = ["true", "false", "null"]
2015:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
2016:         
2017:         // Annotations
2018:         let annotationPattern = "@[a-zA-Z][a-zA-Z0-9]*"
2019:         highlightPattern(attributed, pattern: annotationPattern, color: UIColor(theme.function), text: text)
2020:         
2021:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
2022:         highlightStrings(attributed, text: text)
2023:         highlightNumbers(attributed, text: text)
2024:     }
2025:     
2026:     // MARK: - C/C++ Highlighting
2027:     
2028:     private func highlightCpp(_ attributed: NSMutableAttributedString, text: String) {
2029:         let keywords = ["auto", "break", "case", "catch", "class", "const", "continue", "default",
2030:                        "delete", "do", "else", "enum", "explicit", "extern", "for", "friend", "goto",
2031:                        "if", "inline", "mutable", "namespace", "new", "operator", "private", "protected",
2032:                        "public", "register", "return", "sizeof", "static", "struct", "switch", "template",
2033:                        "this", "throw", "try", "typedef", "typename", "union", "using", "virtual",
2034:                        "volatile", "while", "constexpr", "nullptr", "override", "final", "noexcept"]
2035:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2036:         
2037:         let types = ["void", "int", "long", "short", "char", "float", "double", "bool", "signed", "unsigned",
2038:                     "int8_t", "int16_t", "int32_t", "int64_t", "uint8_t", "uint16_t", "uint32_t", "uint64_t",
2039:                     "size_t", "string", "vector", "map", "set", "unique_ptr", "shared_ptr"]
2040:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
2041:         
2042:         let constants = ["true", "false", "NULL", "nullptr"]
2043:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
2044:         
2045:         // Preprocessor directives
2046:         let preprocPattern = "^\\s*#\\s*(include|define|ifdef|ifndef|endif|if|else|elif|pragma|error|warning).*$"
2047:         highlightPattern(attributed, pattern: preprocPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
2048:         
2049:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
2050:         highlightStrings(attributed, text: text)
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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 2100, "end_line": 2289}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2101-2289 of 2289)
────────────────────────────────────────
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


Now I have a complete picture. Let me analyze the bottlenecks and provide concrete fixes.

>>>REPORT
# Syntax Highlighting Performance Investigation

## Executive Summary
The syntax highlighting is causing lag at 300 lines (~15-20k characters) due to **6 critical bottlenecks** identified in `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift`.

---

## BOTTLENECK #1: Regex Patterns Compiled Every Time (CRITICAL)
**Location:** Lines 2206-2207

```swift
private func highlightPattern(...) {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
    // ...
}
```

**Problem:** `NSRegularExpression` compilation is called on EVERY highlighting pass. For Swift files:
- `highlightKeywords` with ~50 keywords = **50 regex compilations**
- Plus 10+ other patterns (types, functions, comments, strings, numbers)
- **Total: ~65+ regex compilations per keystroke**

**FIX:** Add static regex cache:
```swift
// Add at struct level (around line 1569)
private static var regexCache: [String: NSRegularExpression] = [:]
private static let regexCacheLock = NSLock()

private func highlightPattern(_ attributed: NSMutableAttributedString, pattern: String, color: UIColor, text: String, options: NSRegularExpression.Options = [], captureGroup: Int = 0) {
    let cacheKey = "\(pattern)_\(options.rawValue)"
    
    Self.regexCacheLock.lock()
    let regex: NSRegularExpression?
    if let cached = Self.regexCache[cacheKey] {
        regex = cached
    } else {
        regex = try? NSRegularExpression(pattern: pattern, options: options)
        if let regex = regex {
            Self.regexCache[cacheKey] = regex
        }
    }
    Self.regexCacheLock.unlock()
    
    guard let regex = regex else { return }
    // ... rest unchanged
}
```

---

## BOTTLENECK #2: highlightKeywords Makes N Passes Over Document (CRITICAL)
**Location:** Lines 2199-2204

```swift
private func highlightKeywords(_ attributed: NSMutableAttributedString, keywords: [String], color: UIColor, text: String) {
    for keyword in keywords {
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
        highlightPattern(attributed, pattern: pattern, color: color, text: text)
    }
}
```

**Problem:** Each keyword triggers a SEPARATE full document scan. Swift has 50+ keywords = **50+ O(n) passes**.

**FIX:** Batch into single regex:
```swift
private func highlightKeywords(_ attributed: NSMutableAttributedString, keywords: [String], color: UIColor, text: String) {
    guard !keywords.isEmpty else { return }
    // Create ONE regex: \b(keyword1|keyword2|keyword3)\b
    let escaped = keywords.map { NSRegularExpression.escapedPattern(for: $0) }
    let pattern = "\\b(\(escaped.joined(separator: "|")))\\b"
    highlightPattern(attributed, pattern: pattern, color: color, text: text)
}
```
**Impact:** Reduces 50 passes to 1 pass.

---

## BOTTLENECK #3: attributedText Assignment Causes Full Relayout (CRITICAL)
**Location:** Lines 450, 550, 778

```swift
textView.attributedText = attributedText  // FULL RELAYOUT TRIGGERED
```

**Problem:** Setting `attributedText` triggers UIKit to re-layout the ENTIRE document, even if only a small portion changed. This is O(n) and blocks the main thread.

**FIX:** Use `NSTextStorage` direct manipulation instead:
```swift
func applySyntaxHighlighting(to textView: UITextView) {
    guard !isApplyingHighlighting else { return }
    isApplyingHighlighting = true
    defer { isApplyingHighlighting = false }
    
    let theme = ThemeManager.shared.currentTheme
    lastThemeId = theme.id
    
    guard let textStorage = textView.textStorage else { return }
    let text = textView.text ?? ""
    let fullRange = NSRange(location: 0, length: text.utf16.count)
    
    // Use beginEditing/endEditing to batch changes (reduces layout passes)
    textStorage.beginEditing()
    
    // Reset to base attributes
    let baseFont = UIFont.monospacedSystemFont(ofSize: parent.editorCore.editorFontSize, weight: .regular)
    textStorage.addAttribute(.font, value: baseFont, range: fullRange)
    textStorage.addAttribute(.foregroundColor, value: UIColor(theme.editorForeground), range: fullRange)
    
    // Apply highlighting directly to textStorage
    let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
    highlighter.applyHighlighting(to: textStorage, text: text, filename: parent.filename)
    
    textStorage.endEditing()  // Single layout pass here
    
    // ... rest unchanged
}
```

---

## BOTTLENECK #4: Visible-Range Highlighting Still Creates Full String
**Location:** Lines 533-538

```swift
// Creates FULL attributed string even for "visible range" highlighting
let fullAttributed = NSMutableAttributedString(string: text)  // O(n)
let fullRange = NSRange(location: 0, length: text.utf16.count)
fullAttributed.addAttribute(.font, value: baseFont, range: fullRange)  // O(n)
fullAttributed.addAttribute(.foregroundColor, value: baseColor, range: fullRange)  // O(n)
```

**Problem:** Even "visible-range only" highlighting allocates and processes the FULL document 3 times before applying visible highlights.

**FIX:** Only modify visible range in existing textStorage:
```swift
func applyVisibleRangeHighlighting(to textView: UITextView) {
    // ... calculate visibleCharRange as before ...
    
    guard let textStorage = textView.textStorage else { return }
    
    textStorage.beginEditing()
    
    // Only reset attributes in visible range + buffer
    let baseFont = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
    textStorage.addAttribute(.font, value: baseFont, range: visibleCharRange)
    textStorage.addAttribute(.foregroundColor, value: UIColor(theme.editorForeground), range: visibleCharRange)
    
    // Extract and highlight only visible text
    let visibleText = (text as NSString).substring(with: visibleCharRange)
    let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
    highlighter.applyHighlighting(to: textStorage, text: visibleText, filename: filename, offset: visibleCharRange.location)
    
    textStorage.endEditing()
}
```

---

## BOTTLENECK #5: Bracket Pair Colorization is O(n) Per Highlight
**Location:** Lines 1673-1733

```swift
private func highlightBracketPairs(_ attributed: NSMutableAttributedString, text: String) {
    // ...
    while index < text.utf16.count {  // O(n) character-by-character scan
        let char = nsString.character(at: index)
        // ...
    }
}
```

**Problem:** Called on EVERY highlight, scans entire document character-by-character with a stack-based bracket matcher.

**FIX:** Skip for large files or make configurable:
```swift
private func highlight(_ text: String, language: Language) -> NSAttributedString {
    // ... existing code ...
    
    // FEAT-038: Bracket Pair Colorization - SKIP for large files (perf)
    if text.utf16.count < 10000 {  // Only for small files
        highlightBracketPairs(attributed, text: text)
    }
    
    return attributed
}
```

---

## BOTTLENECK #6: Debounce Thresholds Too Low
**Location:** Lines 395-420

```swift
} else if textLength > 5000 {
    // MEDIUM FILES (5k-10k): 300ms debounce
    highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, ...) // TOO SHORT
```

**Problem:** 300 lines of Swift code is ~15-20k characters, hitting the "medium" threshold with only 300ms debounce. User typing at normal speed triggers multiple expensive highlights.

**FIX:** Increase thresholds and debounce times:
```swift
if textLength > 30000 {  // Was 50000
    // VERY LARGE: 2 second idle
    highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { ... }
} else if textLength > 8000 {  // Was 10000
    // LARGE: 1.2 second idle, visible-only
    highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { ... }
} else if textLength > 3000 {  // Was 5000
    // MEDIUM: 500ms idle
    highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { ... }
} else {
    // SMALL: 100ms
    highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { ... }
}
```

---

## Performance Impact Summary

| Bottleneck | Current Cost | After Fix |
|------------|--------------|-----------|
| Regex compilation | 65+ per highlight | 0 (cached) |
| Keyword matching | 50 × O(n) | 1 × O(n) |
| attributedText layout | Full O(n) relayout | Single batch layout |
| Visible-range setup | 3 × O(n) allocations | O(visible) only |
| Bracket pairs | O(n) always | O(n) for <10k only |
| Debounce trigger | 300ms for 15k+ | 500ms for 3k+ |

**Expected improvement:** 10-50x faster for 300-line files based on reducing O(n) passes from ~150+ to ~10.

---

## Files Examined
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift` (2289 lines) - Full analysis of:
  - `textViewDidChange` (lines 373-424)
  - `applySyntaxHighlighting` (lines 755-791)
  - `applyHighlightingAsync` (lines 427-461)
  - `applyVisibleRangeHighlighting` (lines 465-561)
  - `VSCodeSyntaxHighlighter` struct (lines 1569-2289)
  - `highlightPattern` (lines 2206-2218)
  - `highlightKeywords` (lines 2199-2204)
  - `highlightBracketPairs` (lines 1673-1733)
>>>END
