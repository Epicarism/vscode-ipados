# Agent: fix-scroll-fighting
**Status:** done
**Tokens:** 5,228
**Cost:** $0.0000
**Time:** 2026-02-10T01:04:48.983Z

## Task
CRITICAL: User can't scroll if they're on a specific line - the view keeps fighting to put that line in view. Read VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift. Find where scroll position is being forced and add a flag to prevent scroll fighting during user scroll gestures.

## Response
I'll read the file to understand the scroll behavior and find where the scroll position is being forced.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

Let me get the symbols to understand the structure and find scroll-related methods:

>>>TOOL get_symbols
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[get_symbols]
No symbols found in VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (file may need to be opened first)


Let me search for scroll-related code in the file:

>>>TOOL search
{"query": "scrollRangeToVisible", "glob": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "scrollRangeToVisible"


>>>TOOL search
{"query": "scroll", "glob": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 19 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:15: @Binding var scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:35: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:50: self._scrollPosition = scrollPosition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:68: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:85: scrollPosition: scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:226: // Handle minimap scrolling
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:227: if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:229: // where user scroll gets overridden by stale binding value
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:230: context.coordinator.lastKnownScrollPosition = scrollPosition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:231: context.coordinator.scrollToLine(scrollPosition, in: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:238: context.coordinator.scrollToAndSelectLine(requested, in: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:331: func scrollViewDidScroll(_ scrollView: UIScrollView) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:332: guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:364: let scrollOffset = textView.contentOffset.y
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:365: let line = Int(scrollOffset / lineHeight)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:369: self.parent.scrollPosition = line
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:373: func scrollToLine(_ line: Int, in textView: UITextView) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:399: func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:414: scrollToLine(line, in: textView)


Let me read the scroll-related sections starting with the updateUIView and the scroll methods:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 220, "end_line": 250}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 221-250 of 1931)
────────────────────────────────────────
221:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
222:             // Re-apply highlighting if theme changed
223:             context.coordinator.applySyntaxHighlighting(to: textView)
224:         }
225:         
226:         // Handle minimap scrolling
227:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 {
228:             // Update lastKnownScrollPosition FIRST to prevent race condition
229:             // where user scroll gets overridden by stale binding value
230:             context.coordinator.lastKnownScrollPosition = scrollPosition
231:             context.coordinator.scrollToLine(scrollPosition, in: textView)
232:         }
233: 
234:         // Handle line selection requests (e.g. tapping line numbers)
235:         if let requested = requestedLineSelection,
236:            requested != context.coordinator.lastRequestedLineSelection {
237:             context.coordinator.lastRequestedLineSelection = requested
238:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
239:             // Defer @Binding update to avoid "Publishing changes from within view updates"
240:             DispatchQueue.main.async {
241:                 self.requestedLineSelection = nil
242:             }
243:         }
244: 
245:         // Handle cursor index requests (e.g. accepting autocomplete)
246:         if let requested = requestedCursorIndex,
247:            requested != context.coordinator.lastRequestedCursorIndex {
248:             context.coordinator.lastRequestedCursorIndex = requested
249:             textView.selectedRange = NSRange(location: max(0, requested), length: 0)
250:             // Defer @Binding update to avoid "Publishing changes from within view updates"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 325, "end_line": 420}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 326-420 of 1931)
────────────────────────────────────────
326:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
327:                 }
328:             }
329:         }
330:         
331:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
332:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
333:             updateScrollPosition(textView)
334:         }
335:         
336:         func updateLineCount(_ textView: UITextView) {
337:             let lines = textView.text.components(separatedBy: .newlines)
338:             DispatchQueue.main.async {
339:                 self.parent.totalLines = max(1, lines.count)
340:             }
341:         }
342:         
343:         func updateCursorPosition(_ textView: UITextView) {
344:             guard let selectedRange = textView.selectedTextRange else { return }
345:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
346:              
347:              let text = textView.text ?? ""
348:              let prefix = String(text.prefix(cursorPosition))
349:              let lines = prefix.components(separatedBy: .newlines)
350:              
351:              let lineNumber = lines.count
352:              let column = (lines.last?.count ?? 0) + 1
353:              
354:              DispatchQueue.main.async {
355:                  self.parent.currentLineNumber = lineNumber
356:                  self.parent.currentColumn = column
357:                  self.parent.cursorIndex = cursorPosition
358:              }
359:         }
360:         
361:         func updateScrollPosition(_ textView: UITextView) {
362:             guard let font = textView.font else { return }
363:             let lineHeight = font.lineHeight
364:             let scrollOffset = textView.contentOffset.y
365:             let line = Int(scrollOffset / lineHeight)
366:             
367:             lastKnownScrollPosition = line
368:             DispatchQueue.main.async {
369:                 self.parent.scrollPosition = line
370:             }
371:         }
372:         
373:         func scrollToLine(_ line: Int, in textView: UITextView) {
374:             guard !isUpdatingFromMinimap else { return }
375:             isUpdatingFromMinimap = true
376:             
377:             let lines = textView.text.components(separatedBy: .newlines)
378:             guard line >= 0 && line < lines.count else {
379:                 isUpdatingFromMinimap = false
380:                 return
381:             }
382:             
383:             var characterPosition = 0
384:             for i in 0..<line {
385:                 characterPosition += lines[i].count + 1
386:             }
387:             
388:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
389:                 let rect = textView.caretRect(for: position)
390:                 let targetY = max(0, rect.origin.y)
391:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
392:             }
393:             
394:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
395:                 self.isUpdatingFromMinimap = false
396:             }
397:         }
398: 
399:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
400:             let lines = textView.text.components(separatedBy: .newlines)
401:             guard line >= 0 && line < lines.count else { return }
402: 
403:             var characterPosition = 0
404:             for i in 0..<line {
405:                 characterPosition += lines[i].count + 1
406:             }
407: 
408:             // FEAT-041: select entire line (excluding trailing newline)
409:             let lineLength = (lines[line] as NSString).length
410:             let range = NSRange(location: characterPosition, length: lineLength)
411:             textView.selectedRange = range
412: 
413:             // Ensure it's visible
414:             scrollToLine(line, in: textView)
415: 
416:             // Update SwiftUI state
417:             updateCursorPosition(textView)
418:             updateScrollPosition(textView)
419:         }
420: 


Now I understand the issue. Let me look at the Coordinator class definition to see the existing flags:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 180}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-180 of 1931)
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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 260, "end_line": 340}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 261-340 of 1931)
────────────────────────────────────────
261:         // as it causes unnecessary state churn on every updateUIView
262:     }
263:     
264:     // MARK: - Coordinator
265:     
266:     class Coordinator: NSObject, UITextViewDelegate {
267:         var parent: SyntaxHighlightingTextView
268:         var lastKnownScrollPosition: Int = 0
269:         var lastThemeId: String = ""
270:         var lastRequestedLineSelection: Int? = nil
271:         var lastRequestedCursorIndex: Int? = nil
272:         private var isUpdatingFromMinimap = false
273:         private var highlightDebouncer: Timer?
274:         weak var pinchGesture: UIPinchGestureRecognizer?
275:         private var initialFontSize: CGFloat = 0
276: 
277:         // FEAT-044: Matching bracket highlight state
278:         private var bracketHighlightRanges: [NSRange] = []
279:         
280:         init(_ parent: SyntaxHighlightingTextView) {
281:             self.parent = parent
282:         }
283:         
284:         func textViewDidChange(_ textView: UITextView) {
285:             // Update parent text
286:             parent.text = textView.text
287:             
288:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
289:             // This prevents flicker during the debounce period
290:             let theme = ThemeManager.shared.currentTheme
291:             let fontSize = parent.editorCore.editorFontSize
292:             textView.typingAttributes = [
293:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
294:                 .foregroundColor: UIColor(theme.editorForeground)
295:             ]
296:             
297:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
298:             highlightDebouncer?.invalidate()
299:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
300:                 DispatchQueue.main.async {
301:                     self?.applySyntaxHighlighting(to: textView)
302:                 }
303:             }
304:             
305:             updateLineCount(textView)
306:             updateCursorPosition(textView)
307:         }
308:         
309:         func textViewDidChangeSelection(_ textView: UITextView) {
310:             if !isUpdatingFromMinimap {
311:                 updateCursorPosition(textView)
312:                 updateScrollPosition(textView)
313: 
314:                 // FEAT-044: Matching bracket highlight
315:                 updateMatchingBracketHighlight(textView)
316: 
317:                 // Trigger redraw so current-line highlight/indent guides track the caret
318:                 (textView as? EditorTextView)?.setNeedsDisplay()
319: 
320:                 // Update selection in EditorCore for multi-cursor support
321:                 let range = textView.selectedRange
322:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
323: 
324:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
325:                 if !parent.editorCore.multiCursorState.isMultiCursor {
326:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
327:                 }
328:             }
329:         }
330:         
331:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
332:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
333:             updateScrollPosition(textView)
334:         }
335:         
336:         func updateLineCount(_ textView: UITextView) {
337:             let lines = textView.text.components(separatedBy: .newlines)
338:             DispatchQueue.main.async {
339:                 self.parent.totalLines = max(1, lines.count)
340:             }


Now I see the issue. The `isUpdatingFromMinimap` flag prevents scroll fighting when the minimap triggers a scroll, but there's no flag to prevent scroll fighting when the user is actively scrolling. When `updateUIView` is called during a user scroll, the `scrollPosition` binding may lag behind `lastKnownScrollPosition`, causing `scrollToLine` to be called and fighting the user's scroll.

Let me check if there are any scroll delegate methods for detecting user dragging:

>>>TOOL search
{"query": "scrollViewWillBeginDragging", "glob": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "scrollViewWillBeginDragging"


The issue is clear. When the user scrolls, SwiftUI's `updateUIView` gets called with possibly stale `scrollPosition` values, causing `scrollToLine` to fight the user's scroll. I need to:

1. Add an `isUserScrolling` flag to the Coordinator
2. Add UIScrollViewDelegate methods to detect when user starts/stops scrolling
3. Check this flag before allowing programmatic scroll in `updateUIView`

Let me apply the fix:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SyntaxHighlightingTextView
        var lastKnownScrollPosition: Int = 0
        var lastThemeId: String = ""
        var lastRequestedLineSelection: Int? = nil
        var lastRequestedCursorIndex: Int? = nil
        private var isUpdatingFromMinimap = false
        private var highlightDebouncer: Timer?
        weak var pinchGesture: UIPinchGestureRecognizer?
        private var initialFontSize: CGFloat = 0

        // FEAT-044: Matching bracket highlight state
        private var bracketHighlightRanges: [NSRange] = []
>>>REPLACE
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SyntaxHighlightingTextView
        var lastKnownScrollPosition: Int = 0
        var lastThemeId: String = ""
        var lastRequestedLineSelection: Int? = nil
        var lastRequestedCursorIndex: Int? = nil
        private var isUpdatingFromMinimap = false
        private var isUserScrolling = false  // Prevents scroll fighting during user scroll gestures
        private var highlightDebouncer: Timer?
        weak var pinchGesture: UIPinchGestureRecognizer?
        private var initialFontSize: CGFloat = 0

        // FEAT-044: Matching bracket highlight state
        private var bracketHighlightRanges: [NSRange] = []
>>>END

Now add the scroll delegate methods to detect user scrolling:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
            updateScrollPosition(textView)
        }
>>>REPLACE
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
            updateScrollPosition(textView)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            // User started scrolling - prevent programmatic scroll from fighting
            isUserScrolling = true
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            // If not decelerating, user finished scrolling
            if !decelerate {
                isUserScrolling = false
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            // Deceleration finished - user scroll complete
            isUserScrolling = false
        }
>>>END

Now update the `updateUIView` to check the `isUserScrolling` flag:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
        // Handle minimap scrolling
        if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 {
            // Update lastKnownScrollPosition FIRST to prevent race condition
            // where user scroll gets overridden by stale binding value
            context.coordinator.lastKnownScrollPosition = scrollPosition
            context.coordinator.scrollToLine(scrollPosition, in: textView)
        }
>>>REPLACE
        // Handle minimap scrolling - but don't fight user scroll gestures
        if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 {
            // Skip programmatic scroll if user is actively scrolling to prevent fighting
            if !context.coordinator.isUserCurrentlyScrolling {
                // Update lastKnownScrollPosition FIRST to prevent race condition
                // where user scroll gets overridden by stale binding value
                context.coordinator.lastKnownScrollPosition = scrollPosition
                context.coordinator.scrollToLine(scrollPosition, in: textView)
            }
        }
>>>END

I need to add a public accessor for the `isUserScrolling` flag since `updateUIView` is outside the Coordinator:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SyntaxHighlightingTextView
        var lastKnownScrollPosition: Int = 0
        var lastThemeId: String = ""
        var lastRequestedLineSelection: Int? = nil
        var lastRequestedCursorIndex: Int? = nil
        private var isUpdatingFromMinimap = false
        private var isUserScrolling = false  // Prevents scroll fighting during user scroll gestures
        private var highlightDebouncer: Timer?
        weak var pinchGesture: UIPinchGestureRecognizer?
        private var initialFontSize: CGFloat = 0

        // FEAT-044: Matching bracket highlight state
        private var bracketHighlightRanges: [NSRange] = []
>>>REPLACE
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SyntaxHighlightingTextView
        var lastKnownScrollPosition: Int = 0
        var lastThemeId: String = ""
        var lastRequestedLineSelection: Int? = nil
        var lastRequestedCursorIndex: Int? = nil
        private var isUpdatingFromMinimap = false
        private var isUserScrolling = false  // Prevents scroll fighting during user scroll gestures
        var isUserCurrentlyScrolling: Bool { isUserScrolling }  // Public accessor for updateUIView
        private var highlightDebouncer: Timer?
        weak var pinchGesture: UIPinchGestureRecognizer?
        private var initialFontSize: CGFloat = 0

        // FEAT-044: Matching bracket highlight state
        private var bracketHighlightRanges: [NSRange] = []
>>>END

>>>REPORT
## Fix Applied: Scroll Fighting Prevention

**Problem:** When the user scrolls to a specific line, the view keeps fighting to put that line back in view because `updateUIView` was being called with stale `scrollPosition` binding values during active user scrolling.

**Root Cause (lines 227-232):** The `updateUIView` function checks if `scrollPosition != lastKnownScrollPosition` and calls `scrollToLine()`. During user scroll gestures, the binding updates asynchronously, so the condition could be true with a stale value, causing programmatic scroll to fight the user's gesture.

**Fix Applied to `SyntaxHighlightingTextView.swift`:**

1. **Added `isUserScrolling` flag** (line ~272) - A private boolean that tracks when user is actively scrolling

2. **Added public accessor** `isUserCurrentlyScrolling` - So `updateUIView` can check the flag

3. **Added three UIScrollViewDelegate methods** (after line ~334):
   - `scrollViewWillBeginDragging` - Sets `isUserScrolling = true` when user starts scrolling
   - `scrollViewDidEndDragging(_:willDecelerate:)` - Sets `isUserScrolling = false` if not decelerating
   - `scrollViewDidEndDecelerating` - Sets `isUserScrolling = false` when deceleration finishes

4. **Modified scroll logic in `updateUIView`** (lines ~227-232) - Now checks `!context.coordinator.isUserCurrentlyScrolling` before calling `scrollToLine()`, preventing programmatic scroll from fighting user gestures

**Files Modified:**
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift`
>>>END
