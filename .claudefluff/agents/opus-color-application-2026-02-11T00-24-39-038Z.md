# Agent: opus-color-application
**Status:** done
**Tokens:** 13,169
**Cost:** $0.0000
**Time:** 2026-02-11T00:24:39.038Z

## Task
CRITICAL: Find where colors are ACTUALLY APPLIED to text in Runestone. Search for NSAttributedString, foregroundColor, addAttribute in Runestone source. Trace from delegate response to actual text rendering. Find why all text ends up same color.

## Response
I'll search for where colors are actually applied to text in Runestone. Let me trace the color application flow.

>>>TOOL search
{"query": "foregroundColor", "glob": "AuroraEditor/AuroraEditorSourceEditor/.build/checkouts/Runestone/**/*.swift"}
>>>END

>>>TOOL search
{"query": "addAttribute", "glob": "AuroraEditor/AuroraEditorSourceEditor/.build/checkouts/Runestone/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "addAttribute"


>>>TOOL search
{"query": "NSAttributedString", "glob": "AuroraEditor/AuroraEditorSourceEditor/.build/checkouts/Runestone/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "NSAttributedString"


>>>TOOL list_dir
{"path": "AuroraEditor/AuroraEditorSourceEditor/.build/checkouts/Runestone"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "AuroraEditor/AuroraEditorSourceEditor/.build/checkouts/Runestone" not found


>>>TOOL search
{"query": "Runestone", "glob": "**/Package.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "Runestone"


>>>TOOL search
{"query": "runestone", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "runestone"


>>>TOOL list_dir
{"path": "AuroraEditor/AuroraEditorSourceEditor"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "AuroraEditor/AuroraEditorSourceEditor" not found


>>>TOOL list_dir
{"path": "."}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 ./
📁 .claude/
📁 .claudefluff/
📁 .garbage/
📁 .patch-backups/
📁 .vscode/
📁 Docs/
📁 Extensions/
📁 logs/
📁 Models/
📁 Services/
📁 test-results/
📁 Tests/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOSUITests/
   .gitignore
   build.log
   FULL_FEATURE_TEST_PLAN.md
   idb_testing_report.md
   LICENSE
   README.md
   StressTest.swift
   test_editor_typing.sh
   update.md
   VSCodeiPadOS_idb_test_plan.sh
   VSCodeiPadOS_Ui_Element_Coordinates.md
(cached)


>>>TOOL search
{"query": "Runestone", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 30 matches:
VSCodeiPadOS/FeatureFlags.swift:5: /// Use Runestone editor instead of legacy regex-based highlighting
VSCodeiPadOS/FeatureFlags.swift:7: static let useRunestoneEditor = true
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:2: //  RunestoneThemeAdapter.swift
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:5: //  Maps our Theme struct to Runestone's Theme protocol for syntax highlighting
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:10: import Runestone
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:12: // MARK: - VSCodeRunestoneTheme
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:14: /// A Runestone Theme implementation that adapts our app's Theme struct
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:15: /// to Runestone's expected theme protocol for syntax highlighting.
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:16: public final class VSCodeRunestoneTheme: Runestone.Theme {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:91: /// Creates a Runestone theme from our app's Theme struct
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:282: // MARK: - RunestoneThemeAdapter
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:284: /// Static helper for creating Runestone themes from our app's Theme struct
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:285: public enum RunestoneThemeAdapter {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:287: /// Creates a Runestone Theme from our app's Theme struct
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:291: /// - Returns: A Runestone-compatible Theme
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:292: public static func theme(from theme: Models.Theme, fontSize: CGFloat = 14) -> Runestone.Theme {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:293: VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:296: /// Creates a Runestone Theme from our app's Theme with customized settings
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:300: /// - Returns: A VSCodeRunestoneTheme instance
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:304: ) -> VSCodeRunestoneTheme {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:305: VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:311: /// Namespace alias to avoid conflicts between our Theme model and Runestone's Theme protocol
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:2: //  RunestoneEditorView.swift
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:5: //  High-performance code editor using Runestone with TreeSitter syntax highlighting.
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:11: import Runestone
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:13: // Feature flag now uses centralized FeatureFlags.useRunestoneEditor
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:15: /// UIViewRepresentable wrapper for Runestone's TextView
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:17: struct RunestoneEditorView: UIViewRepresentable {
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:91: let theme = makeRunestoneTheme()
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:126: let theme = makeRunestoneTheme()


>>>TOOL search
{"query": "import Runestone", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 6 matches:
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:10: import Runestone
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:11: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:10: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift:10: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:11: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:11: import Runestone


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 1-741 of 741)
────────────────────────────────────────
1: //
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
12: import TreeSitterSwiftRunestone
13: import TreeSitterJavaScriptRunestone
14: import TreeSitterPythonRunestone
15: import TreeSitterJSONRunestone
16: import TreeSitterHTMLRunestone
17: import TreeSitterCSSRunestone
18: import TreeSitterGoRunestone
19: import TreeSitterRustRunestone
20: 
21: // Feature flag now uses centralized FeatureFlags.useRunestoneEditor
22: 
23: /// UIViewRepresentable wrapper for Runestone's TextView
24: /// Provides native TreeSitter syntax highlighting, line numbers, and code folding
25: struct RunestoneEditorView: UIViewRepresentable {
26:     @Binding var text: String
27:     let filename: String
28:     @Binding var scrollOffset: CGFloat
29:     @Binding var totalLines: Int
30:     @Binding var currentLineNumber: Int
31:     @Binding var currentColumn: Int
32:     @Binding var cursorIndex: Int
33:     let isActive: Bool
34:     let fontSize: CGFloat
35:     @EnvironmentObject var editorCore: EditorCore
36:     
37:     // Settings from AppStorage
38:     @AppStorage("wordWrap") private var wordWrapEnabled: Bool = true
39:     @AppStorage("showLineNumbers") private var showLineNumbers: Bool = true
40:     
41:     /// Autocomplete key handling hooks (return true if handled)
42:     let onAcceptAutocomplete: (() -> Bool)?
43:     let onDismissAutocomplete: (() -> Bool)?
44:     
45:     init(
46:         text: Binding<String>,
47:         filename: String,
48:         scrollOffset: Binding<CGFloat> = .constant(0),
49:         totalLines: Binding<Int>,
50:         currentLineNumber: Binding<Int>,
51:         currentColumn: Binding<Int>,
52:         cursorIndex: Binding<Int> = .constant(0),
53:         isActive: Bool,
54:         fontSize: CGFloat = 14.0,
55:         onAcceptAutocomplete: (() -> Bool)? = nil,
56:         onDismissAutocomplete: (() -> Bool)? = nil
57:     ) {
58:         self._text = text
59:         self.filename = filename
60:         self._scrollOffset = scrollOffset
61:         self._totalLines = totalLines
62:         self._currentLineNumber = currentLineNumber
63:         self._currentColumn = currentColumn
64:         self._cursorIndex = cursorIndex
65:         self.isActive = isActive
66:         self.fontSize = fontSize
67:         self.onAcceptAutocomplete = onAcceptAutocomplete
68:         self.onDismissAutocomplete = onDismissAutocomplete
69:     }
70:     
71:     func makeCoordinator() -> Coordinator {
72:         Coordinator(self)
73:     }
74:     
75:     func makeUIView(context: Context) -> TextView {
76:         let textView = TextView()
77:         textView.editorDelegate = context.coordinator
78:         
79:         // Configure line numbers (from settings)
80:         textView.showLineNumbers = showLineNumbers
81:         textView.lineSelectionDisplayType = .line
82:         
83:         // Configure line wrapping (from settings)
84:         textView.isLineWrappingEnabled = wordWrapEnabled
85:         
86:         // Configure editing
87:         textView.isEditable = true
88:         textView.isSelectable = true
89:         
90:         // Disable autocorrect/autocapitalize for code editing
91:         textView.autocorrectionType = .no
92:         textView.autocapitalizationType = .none
93:         textView.smartQuotesType = .no
94:         textView.smartDashesType = .no
95:         textView.smartInsertDeleteType = .no
96:         textView.spellCheckingType = .no
97:         
98:         // Configure keyboard
99:         textView.keyboardType = .asciiCapable
100:         textView.keyboardDismissMode = .interactive
101:         
102:         // Set theme and appearance
103:         textView.theme = makeRunestoneTheme()
104:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
105:         
106:         // Content insets for padding
107:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
108:         
109:         // Set text with TreeSitter language support
110:         if let language = getTreeSitterLanguage(for: filename) {
111:             let state = TextViewState(text: text, language: language)
112:             textView.setState(state)
113:         } else {
114:             // No language support - fallback to plain text
115:             textView.text = text
116:         }
117:         
118:         // Store reference for coordinator
119:         context.coordinator.textView = textView
120:         
121:         // Initial line count
122:         DispatchQueue.main.async {
123:             self.totalLines = self.countLines(in: text)
124:         }
125:         
126:         return textView
127:     }
128:     
129:     func updateUIView(_ textView: TextView, context: Context) {
130:         // Update coordinator's parent reference for current bindings
131:         context.coordinator.parent = self
132:         
133:         // Update theme if changed
134:         let currentThemeId = ThemeManager.shared.currentTheme.id
135:         if context.coordinator.lastThemeId != currentThemeId {
136:             context.coordinator.lastThemeId = currentThemeId
137:             textView.theme = makeRunestoneTheme()
138:             textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
139:         }
140:         
141:         // Update font size if changed
142:         if context.coordinator.lastFontSize != fontSize {
143:             context.coordinator.lastFontSize = fontSize
144:             textView.theme = makeRunestoneTheme()
145:         }
146:         
147:         // Update settings if changed (live toggle support)
148:         if textView.showLineNumbers != showLineNumbers {
149:             textView.showLineNumbers = showLineNumbers
150:         }
151:         if textView.isLineWrappingEnabled != wordWrapEnabled {
152:             textView.isLineWrappingEnabled = wordWrapEnabled
153:         }
154:         
155:         // CRITICAL: Only call setState() when safe (not during active editing)
156:         // Calling setState() during editing corrupts Runestone's lineManager
157:         // and causes crash at TextEditHelper.swift:27 (force unwrap on linePosition)
158:         
159:         let isFileSwitching = context.coordinator.lastFilename != filename
160:         let currentText = textView.text
161:         let textChanged = currentText != text
162:         let isActivelyEditing = textView.isFirstResponder
163:         
164:         if isFileSwitching {
165:             // User switched to a different file - safe to call setState()
166:             context.coordinator.lastFilename = filename
167:             context.coordinator.hasBeenEdited = false
168:             
169:             if let language = getTreeSitterLanguage(for: filename) {
170:                 let state = TextViewState(text: text, language: language)
171:                 textView.setState(state)
172:             } else {
173:                 textView.text = text
174:             }
175:             
176:             // Reset cursor to start for new file
177:             textView.selectedRange = NSRange(location: 0, length: 0)
178:             
179:             // Update line count
180:             DispatchQueue.main.async {
181:                 self.totalLines = self.countLines(in: text)
182:             }
183:         } else if textChanged && !context.coordinator.hasBeenEdited && !isActivelyEditing && !context.coordinator.isUpdatingFromTextView {
184:             // Text changed externally (e.g., initial load, external modification)
185:             // Safe to update since user hasn't started editing yet
186:             if let language = getTreeSitterLanguage(for: filename) {
187:                 let state = TextViewState(text: text, language: language)
188:                 textView.setState(state)
189:             } else {
190:                 textView.text = text
191:             }
192:             
193:             // Update line count
194:             DispatchQueue.main.async {
195:                 self.totalLines = self.countLines(in: text)
196:             }
197:         }
198:         // If user HAS edited OR is actively editing, DO NOTHING
199:         // Let the user's edits remain - don't corrupt the lineManager
200:     }
201:     
202:     // MARK: - Runestone Theme Factory
203:     
204:     private func makeRunestoneTheme() -> RunestoneEditorTheme {
205:         let appTheme = ThemeManager.shared.currentTheme
206:         return RunestoneEditorTheme(
207:             fontSize: fontSize,
208:             backgroundColor: UIColor(appTheme.editorBackground),
209:             textColor: UIColor(appTheme.editorForeground),
210:             gutterBackgroundColor: UIColor(appTheme.editorBackground),
211:             gutterHairlineColor: UIColor(appTheme.lineNumber).withAlphaComponent(0.3),
212:             lineNumberColor: UIColor(appTheme.lineNumber),
213:             selectedLineBackgroundColor: UIColor(appTheme.currentLineHighlight),
214:             selectedLinesLineNumberColor: UIColor(appTheme.lineNumberActive),
215:             selectedLinesGutterBackgroundColor: UIColor(appTheme.currentLineHighlight),
216:             invisibleCharactersColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.3),
217:             pageGuideHairlineColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.1),
218:             pageGuideBackgroundColor: UIColor(appTheme.editorBackground),
219:             markedTextBackgroundColor: UIColor(appTheme.selection).withAlphaComponent(0.5),
220:             keywordColor: UIColor(appTheme.keyword),
221:             stringColor: UIColor(appTheme.string),
222:             numberColor: UIColor(appTheme.number),
223:             commentColor: UIColor(appTheme.comment),
224:             functionColor: UIColor(appTheme.function),
225:             typeColor: UIColor(appTheme.type),
226:             variableColor: UIColor(appTheme.variable)
227:         )
228:     }
229:     
230:     // MARK: - Language Mode Mapping
231:     
232:     /// Gets the actual TreeSitter Language object for a given filename
233:     /// Returns nil for plain text files (no syntax highlighting)
234:     private func getTreeSitterLanguage(for filename: String) -> Runestone.TreeSitterLanguage? {
235:         let ext = (filename as NSString).pathExtension.lowercased()
236:         let lastComponent = (filename as NSString).lastPathComponent.lowercased()
237:         
238:         // Special-case filenames without extensions
239:         if lastComponent == "dockerfile" || lastComponent.hasPrefix("dockerfile.") {
240:             return nil // Bash support not in package list yet
241:         }
242:         if lastComponent == ".env" || lastComponent.hasPrefix(".env.") {
243:             return nil // Plain text
244:         }
245:         if lastComponent == "makefile" || lastComponent == "gnumakefile" {
246:             return nil // Bash support not in package list yet
247:         }
248:         if lastComponent == "podfile" || lastComponent == "gemfile" {
249:             return nil // Ruby support not in package list yet
250:         }
251:         if lastComponent == "package.json" || lastComponent == "tsconfig.json" {
252:             return TreeSitterLanguage.json
253:         }
254:         
255:         switch ext {
256:         // Swift
257:         case "swift":
258:             return TreeSitterLanguage.swift
259:         
260:         // JavaScript
261:         case "js", "mjs", "cjs", "jsx":
262:             return TreeSitterLanguage.javaScript
263:         
264:         // TypeScript - use JavaScript as fallback
265:         case "ts", "mts", "cts", "tsx":
266:             return TreeSitterLanguage.javaScript
267:         
268:         // Python
269:         case "py", "pyw", "pyi":
270:             return TreeSitterLanguage.python
271:         
272:         // Go
273:         case "go":
274:             return TreeSitterLanguage.go
275:         
276:         // Rust
277:         case "rs":
278:             return TreeSitterLanguage.rust
279:         
280:         // JSON
281:         case "json", "jsonc":
282:             return TreeSitterLanguage.json
283:         
284:         // HTML
285:         case "html", "htm", "xhtml":
286:             return TreeSitterLanguage.html
287:         
288:         // CSS
289:         case "css", "scss":
290:             return TreeSitterLanguage.css
291:         
292:         // XML - use HTML as fallback
293:         case "xml", "plist", "svg":
294:             return TreeSitterLanguage.html
295:         
296:         // Default - no syntax highlighting
297:         default:
298:             return nil
299:         }
300:     }
301: 
302:     
303:     // MARK: - Helpers
304:     
305:     private func countLines(in text: String) -> Int {
306:         guard !text.isEmpty else { return 1 }
307:         var count = 1
308:         var index = text.startIndex
309:         while index < text.endIndex {
310:             if text[index] == "\n" {
311:                 count += 1
312:             }
313:             index = text.index(after: index)
314:         }
315:         return count
316:     }
317:     
318:     // MARK: - Coordinator
319:     
320:     class Coordinator: NSObject, TextViewDelegate {
321:         var parent: RunestoneEditorView
322:         weak var textView: TextView?
323:         var isUpdatingFromTextView = false
324:         var lastFontSize: CGFloat = 14.0
325:         var lastThemeId: String = ""
326:         var currentLanguage: Language?
327:         
328:         // Track file identity to know when to call setState()
329:         var lastFilename: String = ""
330:         var hasBeenEdited: Bool = false
331:         
332:         // Debounced text sync to avoid SwiftUI re-renders on every keystroke
333:         private var textSyncWorkItem: DispatchWorkItem?
334:         private let debounceInterval: TimeInterval = 0.5 // 500ms
335:         
336:         init(_ parent: RunestoneEditorView) {
337:             self.parent = parent
338:             self.lastFontSize = parent.fontSize
339:             self.lastThemeId = ThemeManager.shared.currentTheme.id
340:             self.lastFilename = parent.filename
341:         }
342:         
343:         deinit {
344:             // Cancel any pending debounced updates
345:             textSyncWorkItem?.cancel()
346:         }
347:         
348:         // MARK: - TextViewDelegate
349:         
350:         func textViewDidChange(_ textView: TextView) {
351:             // Mark that user has edited - blocks setState() calls until file switch
352:             hasBeenEdited = true
353:             
354:             // Cancel any pending debounced update
355:             textSyncWorkItem?.cancel()
356:             
357:             // Create new debounced work item
358:             let workItem = DispatchWorkItem { [weak self] in
359:                 guard let self = self else { return }
360:                 self.isUpdatingFromTextView = true
361:                 defer { self.isUpdatingFromTextView = false }
362:                 
363:                 // Update text binding (debounced - only after typing stops)
364:                 self.parent.text = textView.text
365:                 
366:                 // Update line count
367:                 DispatchQueue.main.async {
368:                     self.parent.totalLines = self.parent.countLines(in: textView.text)
369:                 }
370:             }
371:             
372:             // Schedule the update after debounce interval
373:             textSyncWorkItem = workItem
374:             DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
375:         }
376:         
377:         /// Immediately sync text to SwiftUI binding (call on save/tab-switch)
378:         func syncTextImmediately() {
379:             // Cancel any pending debounced update
380:             textSyncWorkItem?.cancel()
381:             
382:             guard let textView = textView else { return }
383:             
384:             isUpdatingFromTextView = true
385:             defer { isUpdatingFromTextView = false }
386:             
387:             // Immediate sync
388:             parent.text = textView.text
389:             parent.totalLines = parent.countLines(in: textView.text)
390:         }
391:         
392:         func textViewDidChangeSelection(_ textView: TextView) {
393:             updateCursorPosition(in: textView)
394:         }
395:         
396:         func textViewDidBeginEditing(_ textView: TextView) {
397:             // Could be used for focus handling
398:         }
399:         
400:         func textViewDidEndEditing(_ textView: TextView) {
401:             // Could be used for focus handling
402:         }
403:         
404:         func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
405:             // Handle Tab key for autocomplete acceptance
406:             if text == "\t" {
407:                 if let onAccept = parent.onAcceptAutocomplete, onAccept() {
408:                     return false
409:                 }
410:             }
411:             
412:             // Handle Escape key for autocomplete dismissal
413:             // Note: Escape key events are typically handled via key commands, not here
414:             
415:             return true
416:         }
417:         
418:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
419:             // Update scroll offset binding for gutter synchronization
420:             DispatchQueue.main.async {
421:                 self.parent.scrollOffset = scrollView.contentOffset.y
422:             }
423:         }
424:         
425:         // MARK: - Cursor Position Calculation
426:         
427:         private func updateCursorPosition(in textView: TextView) {
428:             let selectedRange = textView.selectedRange
429:             let text = textView.text as NSString
430:             let cursorLocation = selectedRange.location
431:             
432:             // Calculate line and column from cursor location
433:             var lineNumber = 1
434:             var columnNumber = 1
435:             var currentLineStart = 0
436:             
437:             for i in 0..<min(cursorLocation, text.length) {
438:                 if text.character(at: i) == UInt16(UnicodeScalar("\n").value) {
439:                     lineNumber += 1
440:                     currentLineStart = i + 1
441:                 }
442:             }
443:             
444:             // Column is the offset from the start of the current line
445:             columnNumber = cursorLocation - currentLineStart + 1
446:             
447:             // Update bindings on main thread to avoid SwiftUI state update warnings
448:             DispatchQueue.main.async {
449:                 self.parent.cursorIndex = cursorLocation
450:                 self.parent.currentLineNumber = lineNumber
451:                 self.parent.currentColumn = columnNumber
452:             }
453:         }
454:     }
455: }
456: 
457: // MARK: - Runestone Theme Implementation
458: 
459: /// Custom theme implementation for Runestone that maps app theme colors to editor appearance
460: class RunestoneEditorTheme: Runestone.Theme {
461:     let fontSize: CGFloat
462:     
463:     // Core colors
464:     private let _backgroundColor: UIColor
465:     private let _textColor: UIColor
466:     private let _gutterBackgroundColor: UIColor
467:     private let _gutterHairlineColor: UIColor
468:     private let _lineNumberColor: UIColor
469:     private let _selectedLineBackgroundColor: UIColor
470:     private let _selectedLinesLineNumberColor: UIColor
471:     private let _selectedLinesGutterBackgroundColor: UIColor
472:     private let _invisibleCharactersColor: UIColor
473:     private let _pageGuideHairlineColor: UIColor
474:     private let _pageGuideBackgroundColor: UIColor
475:     private let _markedTextBackgroundColor: UIColor
476:     
477:     // Syntax colors
478:     private let _keywordColor: UIColor
479:     private let _stringColor: UIColor
480:     private let _numberColor: UIColor
481:     private let _commentColor: UIColor
482:     private let _functionColor: UIColor
483:     private let _typeColor: UIColor
484:     private let _variableColor: UIColor
485:     
486:     init(
487:         fontSize: CGFloat,
488:         backgroundColor: UIColor,
489:         textColor: UIColor,
490:         gutterBackgroundColor: UIColor,
491:         gutterHairlineColor: UIColor,
492:         lineNumberColor: UIColor,
493:         selectedLineBackgroundColor: UIColor,
494:         selectedLinesLineNumberColor: UIColor,
495:         selectedLinesGutterBackgroundColor: UIColor,
496:         invisibleCharactersColor: UIColor,
497:         pageGuideHairlineColor: UIColor,
498:         pageGuideBackgroundColor: UIColor,
499:         markedTextBackgroundColor: UIColor,
500:         keywordColor: UIColor,
501:         stringColor: UIColor,
502:         numberColor: UIColor,
503:         commentColor: UIColor,
504:         functionColor: UIColor,
505:         typeColor: UIColor,
506:         variableColor: UIColor
507:     ) {
508:         self.fontSize = fontSize
509:         self._backgroundColor = backgroundColor
510:         self._textColor = textColor
511:         self._gutterBackgroundColor = gutterBackgroundColor
512:         self._gutterHairlineColor = gutterHairlineColor
513:         self._lineNumberColor = lineNumberColor
514:         self._selectedLineBackgroundColor = selectedLineBackgroundColor
515:         self._selectedLinesLineNumberColor = selectedLinesLineNumberColor
516:         self._selectedLinesGutterBackgroundColor = selectedLinesGutterBackgroundColor
517:         self._invisibleCharactersColor = invisibleCharactersColor
518:         self._pageGuideHairlineColor = pageGuideHairlineColor
519:         self._pageGuideBackgroundColor = pageGuideBackgroundColor
520:         self._markedTextBackgroundColor = markedTextBackgroundColor
521:         self._keywordColor = keywordColor
522:         self._stringColor = stringColor
523:         self._numberColor = numberColor
524:         self._commentColor = commentColor
525:         self._functionColor = functionColor
526:         self._typeColor = typeColor
527:         self._variableColor = variableColor
528:     }
529:     
530:     // MARK: - Theme Protocol Properties
531:     
532:     var font: UIFont {
533:         UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
534:     }
535:     
536:     var textColor: UIColor {
537:         _textColor
538:     }
539:     
540:     var gutterBackgroundColor: UIColor {
541:         _gutterBackgroundColor
542:     }
543:     
544:     var gutterHairlineColor: UIColor {
545:         _gutterHairlineColor
546:     }
547:     
548:     var lineNumberColor: UIColor {
549:         _lineNumberColor
550:     }
551:     
552:     var lineNumberFont: UIFont {
553:         UIFont.monospacedSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
554:     }
555:     
556:     var selectedLineBackgroundColor: UIColor {
557:         _selectedLineBackgroundColor
558:     }
559:     
560:     var selectedLinesLineNumberColor: UIColor {
561:         _selectedLinesLineNumberColor
562:     }
563:     
564:     var selectedLinesGutterBackgroundColor: UIColor {
565:         _selectedLinesGutterBackgroundColor
566:     }
567:     
568:     var invisibleCharactersColor: UIColor {
569:         _invisibleCharactersColor
570:     }
571:     
572:     var pageGuideHairlineColor: UIColor {
573:         _pageGuideHairlineColor
574:     }
575:     
576:     var pageGuideBackgroundColor: UIColor {
577:         _pageGuideBackgroundColor
578:     }
579:     
580:     var markedTextBackgroundColor: UIColor {
581:         _markedTextBackgroundColor
582:     }
583:     
584:     // MARK: - Syntax Highlighting
585:     
586:     func textColor(for rawHighlightName: String) -> UIColor? {
587:         // Map TreeSitter highlight names to colors
588:         // See: https://tree-sitter.github.io/tree-sitter/syntax-highlighting#highlights
589:         let highlightName = rawHighlightName.lowercased()
590:         
591:         // Debug: Log ALL highlight names to console (remove in production)
592:         // print("🎨 HIGHLIGHT: '\(rawHighlightName)'")
593:         
594:         // Keywords
595:         if highlightName.contains("keyword") {
596:             return _keywordColor
597:         }
598:         
599:         // JSON/Object keys - MUST return color for specific patterns
600:         // TreeSitter JSON emits BOTH "string.special.key" AND "string" for keys
601:         // We handle specific patterns first, then skip generic "string" to avoid overwrite
602:         if highlightName.hasPrefix("string.special") ||
603:            highlightName.contains("label") ||
604:            highlightName.contains("property.definition") {
605:             return _variableColor  // Light blue #9CDCFE for keys
606:         }
607:         
608:         // Strings - but NOT if it's JUST "string" (let specific matches win)
609:         // Only color strings that are clearly values, not potential keys
610:         if highlightName.contains("string") {
611:             // If it's exactly "string" with no qualifiers, it might be a key
612:             // that was already colored by string.special.key - return nil to not overwrite
613:             if rawHighlightName == "string" {
614:                 // For pure "string" captures, still color them (they're values)
615:                 // The issue is ordering - specific patterns should come AFTER in Runestone
616:                 return _stringColor
617:             }
618:             return _stringColor  // Orange #CE9178 for string values
619:         }
620:         
621:         // Numbers and constants
622:         if highlightName.contains("number") || highlightName == "constant.numeric" {
623:             return _numberColor
624:         }
625:         
626:         // Comments
627:         if highlightName.contains("comment") {
628:             return _commentColor
629:         }
630:         
631:         // Functions and methods
632:         if highlightName.contains("function") || highlightName.contains("method") {
633:             return _functionColor
634:         }
635:         
636:         // Types, classes, structs
637:         if highlightName.contains("type") || highlightName.contains("class") ||
638:            highlightName.contains("struct") || highlightName.contains("interface") ||
639:            highlightName.contains("enum") {
640:             return _typeColor
641:         }
642:         
643:         // Variables, parameters, properties
644:         if highlightName.contains("variable") || highlightName.contains("parameter") ||
645:            highlightName.contains("property") || highlightName.contains("field") {
646:             return _variableColor
647:         }
648:         
649:         // Constants and booleans - use keyword color
650:         if highlightName.contains("constant") || highlightName.contains("boolean") {
651:             return _keywordColor
652:         }
653:         
654:         // Operators - use keyword color
655:         if highlightName.contains("operator") {
656:             return _keywordColor
657:         }
658:         
659:         // Namespaces and modules - use type color
660:         if highlightName.contains("namespace") || highlightName.contains("module") {
661:             return _typeColor
662:         }
663:         
664:         // Tags (HTML, XML) - use type color
665:         if highlightName.contains("tag") {
666:             return _typeColor
667:         }
668:         
669:         // Attributes - use variable color
670:         if highlightName.contains("attribute") {
671:             return _variableColor
672:         }
673:         
674:         // Spell checking highlights - ignore (return nil to use default)
675:         if highlightName.contains("spell") {
676:             return nil
677:         }
678:         
679:         // Include/import statements - use keyword color
680:         if highlightName.contains("include") {
681:             return _keywordColor
682:         }
683:         
684:         // Default: use standard text color
685:         return nil
686:     }
687:     
688:     func fontTraits(for rawHighlightName: String) -> FontTraits {
689:         let highlightName = rawHighlightName.lowercased()
690:         
691:         // Make comments italic
692:         if highlightName.contains("comment") {
693:             return .italic
694:         }
695:         
696:         // Make keywords bold
697:         if highlightName.contains("keyword") {
698:             return .bold
699:         }
700:         
701:         return []
702:     }
703: }
704: 
705: 
706: 
707: // MARK: - Preview
708: #if DEBUG
709: struct RunestoneEditorView_Previews: PreviewProvider {
710:     @State static var text = """
711:     func hello() {
712:         print("Hello, World!")
713:     }
714:     
715:     // This is a comment
716:     let number = 42
717:     let string = "test"
718:     """
719:     @State static var scrollOffset: CGFloat = 0
720:     @State static var totalLines = 7
721:     @State static var currentLineNumber = 1
722:     @State static var currentColumn = 1
723:     @State static var cursorIndex = 0
724:     
725:     static var previews: some View {
726:         RunestoneEditorView(
727:             text: $text,
728:             filename: "test.swift",
729:             scrollOffset: $scrollOffset,
730:             totalLines: $totalLines,
731:             currentLineNumber: $currentLineNumber,
732:             currentColumn: $currentColumn,
733:             cursorIndex: $cursorIndex,
734:             isActive: true,
735:             fontSize: 14
736:         )
737:         .environmentObject(EditorCore())
738:     }
739: }
740: #endif
741: 


I found the theme implementation. Now let me check the actual theme colors being passed and search for how Runestone internally applies colors.

>>>TOOL read_file
{"path": "Models/Theme.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/Theme.swift (lines 1-887 of 887)
────────────────────────────────────────
1: import SwiftUI
2: 
3: struct Theme: Identifiable, Equatable, Hashable {
4:     let id: String
5:     let name: String
6:     let isDark: Bool
7:     
8:     // Editor Colors
9:     let editorBackground: Color
10:     let editorForeground: Color
11:     let selection: Color
12:     let cursor: Color
13:     let lineNumber: Color
14:     let lineNumberActive: Color
15:     let currentLineHighlight: Color
16:     let bracketPair1: Color
17:     let bracketPair2: Color
18:     let bracketPair3: Color
19:     let bracketPair4: Color
20:     let bracketPair5: Color
21:     let bracketPair6: Color
22:     let indentGuide: Color
23:     let indentGuideActive: Color
24:     
25:     // UI Colors
26:     let sidebarBackground: Color
27:     let sidebarForeground: Color
28:     let sidebarSectionHeader: Color
29:     let sidebarSelection: Color
30:     let activityBarBackground: Color
31:     let activityBarForeground: Color
32:     let activityBarSelection: Color
33:     let tabBarBackground: Color
34:     let tabActiveBackground: Color
35:     let tabInactiveBackground: Color
36:     let tabActiveForeground: Color
37:     let tabInactiveForeground: Color
38:     let statusBarBackground: Color
39:     let statusBarForeground: Color
40:     
41:     // Syntax Colors
42:     let keyword: Color
43:     let string: Color
44:     let number: Color
45:     let comment: Color
46:     let function: Color
47:     let type: Color
48:     let variable: Color
49:     
50:     // Helper for Hex Colors
51:     static func hex(_ hex: String) -> Color {
52:         var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
53:         hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
54:         
55:         var rgb: UInt64 = 0
56:         Scanner(string: hexSanitized).scanHexInt64(&rgb)
57:         
58:         let r = Double((rgb & 0xFF0000) >> 16) / 255.0
59:         let g = Double((rgb & 0x00FF00) >> 8) / 255.0
60:         let b = Double(rgb & 0x0000FF) / 255.0
61:         
62:         return Color(red: r, green: g, blue: b)
63:     }
64:     
65:     // MARK: - VS Code Default Themes
66:     
67:     static let darkPlus = Theme(
68:         id: "dark_plus",
69:         name: "Dark+ (Default Dark)",
70:         isDark: true,
71:         editorBackground: hex("#1E1E1E"),
72:         editorForeground: hex("#D4D4D4"),
73:         selection: hex("#264F78"),
74:         cursor: hex("#AEAFAD"),
75:         lineNumber: hex("#858585"),
76:         lineNumberActive: hex("#C6C6C6"),
77:         currentLineHighlight: hex("#FFFFFF").opacity(0.1),
78:         bracketPair1: hex("#FFD700"),
79:         bracketPair2: hex("#DA70D6"),
80:         bracketPair3: hex("#179FFF"),
81:         bracketPair4: hex("#FFD700"),
82:         bracketPair5: hex("#DA70D6"),
83:         bracketPair6: hex("#179FFF"),
84:         indentGuide: hex("#404040"),
85:         indentGuideActive: hex("#707070"),
86:         sidebarBackground: hex("#252526"),
87:         sidebarForeground: hex("#CCCCCC"),
88:         sidebarSectionHeader: hex("#383838"),
89:         sidebarSelection: hex("#37373D"),
90:         activityBarBackground: hex("#333333"),
91:         activityBarForeground: hex("#FFFFFF"),
92:         activityBarSelection: hex("#FFFFFF"),
93:         tabBarBackground: hex("#252526"),
94:         tabActiveBackground: hex("#1E1E1E"),
95:         tabInactiveBackground: hex("#2D2D2D"),
96:         tabActiveForeground: hex("#FFFFFF"),
97:         tabInactiveForeground: hex("#969696"),
98:         statusBarBackground: hex("#007ACC"),
99:         statusBarForeground: hex("#FFFFFF"),
100:         keyword: hex("#569CD6"),
101:         string: hex("#CE9178"),
102:         number: hex("#B5CEA8"),
103:         comment: hex("#6A9955"),
104:         function: hex("#DCDCAA"),
105:         type: hex("#4EC9B0"),
106:         variable: hex("#9CDCFE")
107:     )
108:     
109:     static let lightPlus = Theme(
110:         id: "light_plus",
111:         name: "Light+ (Default Light)",
112:         isDark: false,
113:         editorBackground: hex("#FFFFFF"),
114:         editorForeground: hex("#000000"),
115:         selection: hex("#ADD6FF"),
116:         cursor: hex("#000000"),
117:         lineNumber: hex("#237893"),
118:         lineNumberActive: hex("#0B216F"),
119:         currentLineHighlight: hex("#000000").opacity(0.07),
120:         bracketPair1: hex("#0431FA"),
121:         bracketPair2: hex("#319331"),
122:         bracketPair3: hex("#7B3814"),
123:         bracketPair4: hex("#0431FA"),
124:         bracketPair5: hex("#319331"),
125:         bracketPair6: hex("#7B3814"),
126:         indentGuide: hex("#D3D3D3"),
127:         indentGuideActive: hex("#939393"),
128:         sidebarBackground: hex("#F3F3F3"),
129:         sidebarForeground: hex("#616161"),
130:         sidebarSectionHeader: hex("#E7E7E7"),
131:         sidebarSelection: hex("#E4E6F1"),
132:         activityBarBackground: hex("#2C2C2C"),
133:         activityBarForeground: hex("#FFFFFF"),
134:         activityBarSelection: hex("#FFFFFF"),
135:         tabBarBackground: hex("#F3F3F3"),
136:         tabActiveBackground: hex("#FFFFFF"),
137:         tabInactiveBackground: hex("#ECECEC"),
138:         tabActiveForeground: hex("#333333"),
139:         tabInactiveForeground: hex("#8E8E8E"),
140:         statusBarBackground: hex("#007ACC"),
141:         statusBarForeground: hex("#FFFFFF"),
142:         keyword: hex("#AF00DB"),
143:         string: hex("#A31515"),
144:         number: hex("#098658"),
145:         comment: hex("#008000"),
146:         function: hex("#795E26"),
147:         type: hex("#267F99"),
148:         variable: hex("#001080")
149:     )
150:     
151:     static let monokai = Theme(
152:         id: "monokai",
153:         name: "Monokai",
154:         isDark: true,
155:         editorBackground: hex("#272822"),
156:         editorForeground: hex("#F8F8F2"),
157:         selection: hex("#49483E"),
158:         cursor: hex("#F8F8F0"),
159:         lineNumber: hex("#90908A"),
160:         lineNumberActive: hex("#F8F8F2"),
161:         currentLineHighlight: hex("#3E3D32"),
162:         bracketPair1: hex("#F8F8F2"),
163:         bracketPair2: hex("#F92672"),
164:         bracketPair3: hex("#A6E22E"),
165:         bracketPair4: hex("#F8F8F2"),
166:         bracketPair5: hex("#F92672"),
167:         bracketPair6: hex("#A6E22E"),
168:         indentGuide: hex("#464741"),
169:         indentGuideActive: hex("#75715E"),
170:         sidebarBackground: hex("#272822"),
171:         sidebarForeground: hex("#F8F8F2"),
172:         sidebarSectionHeader: hex("#1E1F1C"),
173:         sidebarSelection: hex("#49483E"),
174:         activityBarBackground: hex("#1E1F1C"),
175:         activityBarForeground: hex("#F8F8F2"),
176:         activityBarSelection: hex("#F8F8F2"),
177:         tabBarBackground: hex("#1E1F1C"),
178:         tabActiveBackground: hex("#272822"),
179:         tabInactiveBackground: hex("#34352F"),
180:         tabActiveForeground: hex("#F8F8F2"),
181:         tabInactiveForeground: hex("#88846F"),
182:         statusBarBackground: hex("#75715E"),
183:         statusBarForeground: hex("#F8F8F2"),
184:         keyword: hex("#F92672"),
185:         string: hex("#E6DB74"),
186:         number: hex("#AE81FF"),
187:         comment: hex("#75715E"),
188:         function: hex("#A6E22E"),
189:         type: hex("#66D9EF"),
190:         variable: hex("#FD971F")
191:     )
192:     
193:     static let solarizedDark = Theme(
194:         id: "solarized_dark",
195:         name: "Solarized Dark",
196:         isDark: true,
197:         editorBackground: hex("#002B36"),
198:         editorForeground: hex("#839496"),
199:         selection: hex("#274642"),
200:         cursor: hex("#D30102"),
201:         lineNumber: hex("#586E75"),
202:         lineNumberActive: hex("#93A1A1"),
203:         currentLineHighlight: hex("#0A2933"),
204:         bracketPair1: hex("#859900"),
205:         bracketPair2: hex("#2AA198"),
206:         bracketPair3: hex("#268BD2"),
207:         bracketPair4: hex("#859900"),
208:         bracketPair5: hex("#2AA198"),
209:         bracketPair6: hex("#268BD2"),
210:         indentGuide: hex("#073642"),
211:         indentGuideActive: hex("#586E75"),
212:         sidebarBackground: hex("#00252E"),
213:         sidebarForeground: hex("#93A1A1"),
214:         sidebarSectionHeader: hex("#001F27"),
215:         sidebarSelection: hex("#073642"),
216:         activityBarBackground: hex("#002B36"),
217:         activityBarForeground: hex("#93A1A1"),
218:         activityBarSelection: hex("#FDF6E3"),
219:         tabBarBackground: hex("#002B36"),
220:         tabActiveBackground: hex("#002B36"),
221:         tabInactiveBackground: hex("#00212B"),
222:         tabActiveForeground: hex("#93A1A1"),
223:         tabInactiveForeground: hex("#586E75"),
224:         statusBarBackground: hex("#00212B"),
225:         statusBarForeground: hex("#93A1A1"),
226:         keyword: hex("#859900"),
227:         string: hex("#2AA198"),
228:         number: hex("#D33682"),
229:         comment: hex("#586E75"),
230:         function: hex("#268BD2"),
231:         type: hex("#CB4B16"),
232:         variable: hex("#B58900")
233:     )
234:     
235:     static let solarizedLight = Theme(
236:         id: "solarized_light",
237:         name: "Solarized Light",
238:         isDark: false,
239:         editorBackground: hex("#FDF6E3"),
240:         editorForeground: hex("#657B83"),
241:         selection: hex("#EEE8D5"),
242:         cursor: hex("#D30102"),
243:         lineNumber: hex("#93A1A1"),
244:         lineNumberActive: hex("#586E75"),
245:         currentLineHighlight: hex("#EEE8D5"),
246:         bracketPair1: hex("#859900"),
247:         bracketPair2: hex("#2AA198"),
248:         bracketPair3: hex("#268BD2"),
249:         bracketPair4: hex("#859900"),
250:         bracketPair5: hex("#2AA198"),
251:         bracketPair6: hex("#268BD2"),
252:         indentGuide: hex("#EEE8D5"),
253:         indentGuideActive: hex("#93A1A1"),
254:         sidebarBackground: hex("#EEE8D5"),
255:         sidebarForeground: hex("#586E75"),
256:         sidebarSectionHeader: hex("#DDD6C1"),
257:         sidebarSelection: hex("#D3CBB8"),
258:         activityBarBackground: hex("#DDD6C1"),
259:         activityBarForeground: hex("#586E75"),
260:         activityBarSelection: hex("#073642"),
261:         tabBarBackground: hex("#EEE8D5"),
262:         tabActiveBackground: hex("#FDF6E3"),
263:         tabInactiveBackground: hex("#EEE8D5"),
264:         tabActiveForeground: hex("#073642"),
265:         tabInactiveForeground: hex("#93A1A1"),
266:         statusBarBackground: hex("#EEE8D5"),
267:         statusBarForeground: hex("#586E75"),
268:         keyword: hex("#859900"),
269:         string: hex("#2AA198"),
270:         number: hex("#D33682"),
271:         comment: hex("#93A1A1"),
272:         function: hex("#268BD2"),
273:         type: hex("#CB4B16"),
274:         variable: hex("#B58900")
275:     )
276:     
277:     static let dracula = Theme(
278:         id: "dracula",
279:         name: "Dracula",
280:         isDark: true,
281:         editorBackground: hex("#282A36"),
282:         editorForeground: hex("#F8F8F2"),
283:         selection: hex("#44475A"),
284:         cursor: hex("#F8F8F2"),
285:         lineNumber: hex("#6272A4"),
286:         lineNumberActive: hex("#F8F8F2"),
287:         currentLineHighlight: hex("#44475A"),
288:         bracketPair1: hex("#F8F8F2"),
289:         bracketPair2: hex("#FF79C6"),
290:         bracketPair3: hex("#8BE9FD"),
291:         bracketPair4: hex("#F8F8F2"),
292:         bracketPair5: hex("#FF79C6"),
293:         bracketPair6: hex("#8BE9FD"),
294:         indentGuide: hex("#424450"),
295:         indentGuideActive: hex("#6272A4"),
296:         sidebarBackground: hex("#21222C"),
297:         sidebarForeground: hex("#F8F8F2"),
298:         sidebarSectionHeader: hex("#191A21"),
299:         sidebarSelection: hex("#44475A"),
300:         activityBarBackground: hex("#343746"),
301:         activityBarForeground: hex("#F8F8F2"),
302:         activityBarSelection: hex("#F8F8F2"),
303:         tabBarBackground: hex("#191A21"),
304:         tabActiveBackground: hex("#282A36"),
305:         tabInactiveBackground: hex("#21222C"),
306:         tabActiveForeground: hex("#F8F8F2"),
307:         tabInactiveForeground: hex("#6272A4"),
308:         statusBarBackground: hex("#BD93F9"),
309:         statusBarForeground: hex("#282A36"),
310:         keyword: hex("#FF79C6"),
311:         string: hex("#F1FA8C"),
312:         number: hex("#BD93F9"),
313:         comment: hex("#6272A4"),
314:         function: hex("#50FA7B"),
315:         type: hex("#8BE9FD"),
316:         variable: hex("#FFB86C")
317:     )
318:     
319:     static let oneDarkPro = Theme(
320:         id: "one_dark_pro",
321:         name: "One Dark Pro",
322:         isDark: true,
323:         editorBackground: hex("#282C34"),
324:         editorForeground: hex("#ABB2BF"),
325:         selection: hex("#3E4451"),
326:         cursor: hex("#528BFF"),
327:         lineNumber: hex("#4B5263"),
328:         lineNumberActive: hex("#ABB2BF"),
329:         currentLineHighlight: hex("#2C313C"),
330:         bracketPair1: hex("#C678DD"),
331:         bracketPair2: hex("#61AFEF"),
332:         bracketPair3: hex("#E5C07B"),
333:         bracketPair4: hex("#C678DD"),
334:         bracketPair5: hex("#61AFEF"),
335:         bracketPair6: hex("#E5C07B"),
336:         indentGuide: hex("#3B4048"),
337:         indentGuideActive: hex("#5C6370"),
338:         sidebarBackground: hex("#21252B"),
339:         sidebarForeground: hex("#ABB2BF"),
340:         sidebarSectionHeader: hex("#282C34"),
341:         sidebarSelection: hex("#2C313A"),
342:         activityBarBackground: hex("#282C34"),
343:         activityBarForeground: hex("#ABB2BF"),
344:         activityBarSelection: hex("#D7DAE0"),
345:         tabBarBackground: hex("#21252B"),
346:         tabActiveBackground: hex("#282C34"),
347:         tabInactiveBackground: hex("#21252B"),
348:         tabActiveForeground: hex("#D7DAE0"),
349:         tabInactiveForeground: hex("#5C6370"),
350:         statusBarBackground: hex("#21252B"),
351:         statusBarForeground: hex("#9DA5B4"),
352:         keyword: hex("#C678DD"),
353:         string: hex("#98C379"),
354:         number: hex("#D19A66"),
355:         comment: hex("#5C6370"),
356:         function: hex("#61AFEF"),
357:         type: hex("#E5C07B"),
358:         variable: hex("#E06C75")
359:     )
360:     
361:     static let nord = Theme(
362:         id: "nord",
363:         name: "Nord",
364:         isDark: true,
365:         editorBackground: hex("#2E3440"),
366:         editorForeground: hex("#D8DEE9"),
367:         selection: hex("#434C5E"),
368:         cursor: hex("#D8DEE9"),
369:         lineNumber: hex("#4C566A"),
370:         lineNumberActive: hex("#D8DEE9"),
371:         currentLineHighlight: hex("#3B4252"),
372:         bracketPair1: hex("#EBCB8B"),
373:         bracketPair2: hex("#A3BE8C"),
374:         bracketPair3: hex("#81A1C1"),
375:         bracketPair4: hex("#EBCB8B"),
376:         bracketPair5: hex("#A3BE8C"),
377:         bracketPair6: hex("#81A1C1"),
378:         indentGuide: hex("#434C5E"),
379:         indentGuideActive: hex("#4C566A"),
380:         sidebarBackground: hex("#2E3440"),
381:         sidebarForeground: hex("#D8DEE9"),
382:         sidebarSectionHeader: hex("#3B4252"),
383:         sidebarSelection: hex("#3B4252"),
384:         activityBarBackground: hex("#2E3440"),
385:         activityBarForeground: hex("#D8DEE9"),
386:         activityBarSelection: hex("#88C0D0"),
387:         tabBarBackground: hex("#2E3440"),
388:         tabActiveBackground: hex("#3B4252"),
389:         tabInactiveBackground: hex("#2E3440"),
390:         tabActiveForeground: hex("#D8DEE9"),
391:         tabInactiveForeground: hex("#4C566A"),
392:         statusBarBackground: hex("#3B4252"),
393:         statusBarForeground: hex("#D8DEE9"),
394:         keyword: hex("#81A1C1"),
395:         string: hex("#A3BE8C"),
396:         number: hex("#B48EAD"),
397:         comment: hex("#616E88"),
398:         function: hex("#88C0D0"),
399:         type: hex("#8FBCBB"),
400:         variable: hex("#D8DEE9")
401:     )
402:     
403:     static let githubDark = Theme(
404:         id: "github_dark",
405:         name: "GitHub Dark",
406:         isDark: true,
407:         editorBackground: hex("#0D1117"),
408:         editorForeground: hex("#C9D1D9"),
409:         selection: hex("#163356"),
410:         cursor: hex("#58A6FF"),
411:         lineNumber: hex("#484F58"),
412:         lineNumberActive: hex("#C9D1D9"),
413:         currentLineHighlight: hex("#161B22"),
414:         bracketPair1: hex("#79C0FF"),
415:         bracketPair2: hex("#D2A8FF"),
416:         bracketPair3: hex("#FFA657"),
417:         bracketPair4: hex("#79C0FF"),
418:         bracketPair5: hex("#D2A8FF"),
419:         bracketPair6: hex("#FFA657"),
420:         indentGuide: hex("#21262D"),
421:         indentGuideActive: hex("#30363D"),
422:         sidebarBackground: hex("#010409"),
423:         sidebarForeground: hex("#C9D1D9"),
424:         sidebarSectionHeader: hex("#161B22"),
425:         sidebarSelection: hex("#1F2428"),
426:         activityBarBackground: hex("#0D1117"),
427:         activityBarForeground: hex("#C9D1D9"),
428:         activityBarSelection: hex("#C9D1D9"),
429:         tabBarBackground: hex("#010409"),
430:         tabActiveBackground: hex("#0D1117"),
431:         tabInactiveBackground: hex("#010409"),
432:         tabActiveForeground: hex("#C9D1D9"),
433:         tabInactiveForeground: hex("#8B949E"),
434:         statusBarBackground: hex("#0D1117"),
435:         statusBarForeground: hex("#58A6FF"),
436:         keyword: hex("#FF7B72"),
437:         string: hex("#A5D6FF"),
438:         number: hex("#79C0FF"),
439:         comment: hex("#8B949E"),
440:         function: hex("#D2A8FF"),
441:         type: hex("#79C0FF"),
442:         variable: hex("#FFA657")
443:     )
444:     
445:     static let githubLight = Theme(
446:         id: "github_light",
447:         name: "GitHub Light",
448:         isDark: false,
449:         editorBackground: hex("#FFFFFF"),
450:         editorForeground: hex("#24292F"),
451:         selection: hex("#B6E3FF"),
452:         cursor: hex("#0969DA"),
453:         lineNumber: hex("#8C959F"),
454:         lineNumberActive: hex("#24292F"),
455:         currentLineHighlight: hex("#F6F8FA"),
456:         bracketPair1: hex("#0550AE"),
457:         bracketPair2: hex("#8250DF"),
458:         bracketPair3: hex("#953800"),
459:         bracketPair4: hex("#0550AE"),
460:         bracketPair5: hex("#8250DF"),
461:         bracketPair6: hex("#953800"),
462:         indentGuide: hex("#D0D7DE"),
463:         indentGuideActive: hex("#8C959F"),
464:         sidebarBackground: hex("#F6F8FA"),
465:         sidebarForeground: hex("#24292F"),
466:         sidebarSectionHeader: hex("#EAEEF2"),
467:         sidebarSelection: hex("#DDFBE6"),
468:         activityBarBackground: hex("#F6F8FA"),
469:         activityBarForeground: hex("#24292F"),
470:         activityBarSelection: hex("#24292F"),
471:         tabBarBackground: hex("#F6F8FA"),
472:         tabActiveBackground: hex("#FFFFFF"),
473:         tabInactiveBackground: hex("#F6F8FA"),
474:         tabActiveForeground: hex("#24292F"),
475:         tabInactiveForeground: hex("#57606A"),
476:         statusBarBackground: hex("#F6F8FA"),
477:         statusBarForeground: hex("#0969DA"),
478:         keyword: hex("#CF222E"),
479:         string: hex("#0A3069"),
480:         number: hex("#0550AE"),
481:         comment: hex("#6E7781"),
482:         function: hex("#8250DF"),
483:         type: hex("#0550AE"),
484:         variable: hex("#953800")
485:     )
486:     
487:     static let cobalt2 = Theme(
488:         id: "cobalt2",
489:         name: "Cobalt2",
490:         isDark: true,
491:         editorBackground: hex("#193549"),
492:         editorForeground: hex("#FFFFFF"),
493:         selection: hex("#0D3A58"),
494:         cursor: hex("#FEFB00"),
495:         lineNumber: hex("#3D5F7D"),
496:         lineNumberActive: hex("#FFFFFF"),
497:         currentLineHighlight: hex("#1F4662"),
498:         bracketPair1: hex("#FFC600"),
499:         bracketPair2: hex("#FF628C"),
500:         bracketPair3: hex("#80FFBB"),
501:         bracketPair4: hex("#FFC600"),
502:         bracketPair5: hex("#FF628C"),
503:         bracketPair6: hex("#80FFBB"),
504:         indentGuide: hex("#294B5C"),
505:         indentGuideActive: hex("#3D5F7D"),
506:         sidebarBackground: hex("#15232D"),
507:         sidebarForeground: hex("#FFFFFF"),
508:         sidebarSectionHeader: hex("#0D1A23"),
509:         sidebarSelection: hex("#0D3A58"),
510:         activityBarBackground: hex("#193549"),
511:         activityBarForeground: hex("#FFFFFF"),
512:         activityBarSelection: hex("#FFC600"),
513:         tabBarBackground: hex("#15232D"),
514:         tabActiveBackground: hex("#193549"),
515:         tabInactiveBackground: hex("#15232D"),
516:         tabActiveForeground: hex("#FFFFFF"),
517:         tabInactiveForeground: hex("#3D5F7D"),
518:         statusBarBackground: hex("#15232D"),
519:         statusBarForeground: hex("#FFFFFF"),
520:         keyword: hex("#FF9D00"),
521:         string: hex("#A5FF90"),
522:         number: hex("#FF628C"),
523:         comment: hex("#0088FF"),
524:         function: hex("#FFC600"),
525:         type: hex("#80FFBB"),
526:         variable: hex("#9EFFFF")
527:     )
528:     
529:     static let ayuDark = Theme(
530:         id: "ayu_dark",
531:         name: "Ayu Dark",
532:         isDark: true,
533:         editorBackground: hex("#0A0E14"),
534:         editorForeground: hex("#B3B1AD"),
535:         selection: hex("#273747"),
536:         cursor: hex("#E6B450"),
537:         lineNumber: hex("#3D424D"),
538:         lineNumberActive: hex("#E6B450"),
539:         currentLineHighlight: hex("#0D1016"),
540:         bracketPair1: hex("#FFB454"),
541:         bracketPair2: hex("#59C2FF"),
542:         bracketPair3: hex("#AAD94C"),
543:         bracketPair4: hex("#FFB454"),
544:         bracketPair5: hex("#59C2FF"),
545:         bracketPair6: hex("#AAD94C"),
546:         indentGuide: hex("#1C212B"),
547:         indentGuideActive: hex("#3D424D"),
548:         sidebarBackground: hex("#0D1016"),
549:         sidebarForeground: hex("#B3B1AD"),
550:         sidebarSectionHeader: hex("#0A0E14"),
551:         sidebarSelection: hex("#273747"),
552:         activityBarBackground: hex("#0A0E14"),
553:         activityBarForeground: hex("#B3B1AD"),
554:         activityBarSelection: hex("#E6B450"),
555:         tabBarBackground: hex("#0D1016"),
556:         tabActiveBackground: hex("#0A0E14"),
557:         tabInactiveBackground: hex("#0D1016"),
558:         tabActiveForeground: hex("#B3B1AD"),
559:         tabInactiveForeground: hex("#3D424D"),
560:         statusBarBackground: hex("#0D1016"),
561:         statusBarForeground: hex("#B3B1AD"),
562:         keyword: hex("#FF8F40"),
563:         string: hex("#AAD94C"),
564:         number: hex("#DFBFFF"),
565:         comment: hex("#626A73"),
566:         function: hex("#FFB454"),
567:         type: hex("#59C2FF"),
568:         variable: hex("#B3B1AD")
569:     )
570:     
571:     static let ayuLight = Theme(
572:         id: "ayu_light",
573:         name: "Ayu Light",
574:         isDark: false,
575:         editorBackground: hex("#FAFAFA"),
576:         editorForeground: hex("#5C6166"),
577:         selection: hex("#D1E4F4"),
578:         cursor: hex("#FF9940"),
579:         lineNumber: hex("#9DA2A6"),
580:         lineNumberActive: hex("#FF9940"),
581:         currentLineHighlight: hex("#EFF0F1"),
582:         bracketPair1: hex("#F2AE49"),
583:         bracketPair2: hex("#399EE6"),
584:         bracketPair3: hex("#86B300"),
585:         bracketPair4: hex("#F2AE49"),
586:         bracketPair5: hex("#399EE6"),
587:         bracketPair6: hex("#86B300"),
588:         indentGuide: hex("#E7E8E9"),
589:         indentGuideActive: hex("#9DA2A6"),
590:         sidebarBackground: hex("#F0F0F0"),
591:         sidebarForeground: hex("#5C6166"),
592:         sidebarSectionHeader: hex("#E7E7E7"),
593:         sidebarSelection: hex("#D1E4F4"),
594:         activityBarBackground: hex("#F0F0F0"),
595:         activityBarForeground: hex("#5C6166"),
596:         activityBarSelection: hex("#FF9940"),
597:         tabBarBackground: hex("#F0F0F0"),
598:         tabActiveBackground: hex("#FAFAFA"),
599:         tabInactiveBackground: hex("#F0F0F0"),
600:         tabActiveForeground: hex("#5C6166"),
601:         tabInactiveForeground: hex("#9DA2A6"),
602:         statusBarBackground: hex("#F0F0F0"),
603:         statusBarForeground: hex("#5C6166"),
604:         keyword: hex("#FA8D3E"),
605:         string: hex("#86B300"),
606:         number: hex("#A37ACC"),
607:         comment: hex("#ABB0B6"),
608:         function: hex("#F2AE49"),
609:         type: hex("#399EE6"),
610:         variable: hex("#5C6166")
611:     )
612:     
613:     static let ayuMirage = Theme(
614:         id: "ayu_mirage",
615:         name: "Ayu Mirage",
616:         isDark: true,
617:         editorBackground: hex("#1F2430"),
618:         editorForeground: hex("#CBCCC6"),
619:         selection: hex("#33415E"),
620:         cursor: hex("#FFCC66"),
621:         lineNumber: hex("#707A8C"),
622:         lineNumberActive: hex("#FFCC66"),
623:         currentLineHighlight: hex("#232834"),
624:         bracketPair1: hex("#FFD580"),
625:         bracketPair2: hex("#73D0FF"),
626:         bracketPair3: hex("#BAE67E"),
627:         bracketPair4: hex("#FFD580"),
628:         bracketPair5: hex("#73D0FF"),
629:         bracketPair6: hex("#BAE67E"),
630:         indentGuide: hex("#2D3640"),
631:         indentGuideActive: hex("#707A8C"),
632:         sidebarBackground: hex("#232834"),
633:         sidebarForeground: hex("#CBCCC6"),
634:         sidebarSectionHeader: hex("#1F2430"),
635:         sidebarSelection: hex("#33415E"),
636:         activityBarBackground: hex("#1F2430"),
637:         activityBarForeground: hex("#CBCCC6"),
638:         activityBarSelection: hex("#FFCC66"),
639:         tabBarBackground: hex("#232834"),
640:         tabActiveBackground: hex("#1F2430"),
641:         tabInactiveBackground: hex("#232834"),
642:         tabActiveForeground: hex("#CBCCC6"),
643:         tabInactiveForeground: hex("#707A8C"),
644:         statusBarBackground: hex("#232834"),
645:         statusBarForeground: hex("#CBCCC6"),
646:         keyword: hex("#FFA759"),
647:         string: hex("#BAE67E"),
648:         number: hex("#D4BFFF"),
649:         comment: hex("#5C6773"),
650:         function: hex("#FFD580"),
651:         type: hex("#73D0FF"),
652:         variable: hex("#CBCCC6")
653:     )
654:     
655:     static let quietLight = Theme(
656:         id: "quiet_light",
657:         name: "Quiet Light",
658:         isDark: false,
659:         editorBackground: hex("#F5F5F5"),
660:         editorForeground: hex("#333333"),
661:         selection: hex("#C9D0D9"),
662:         cursor: hex("#54494B"),
663:         lineNumber: hex("#AAAAAA"),
664:         lineNumberActive: hex("#333333"),
665:         currentLineHighlight: hex("#E4F6D4"),
666:         bracketPair1: hex("#7A3E9D"),
667:         bracketPair2: hex("#448C27"),
668:         bracketPair3: hex("#4B83CD"),
669:         bracketPair4: hex("#7A3E9D"),
670:         bracketPair5: hex("#448C27"),
671:         bracketPair6: hex("#4B83CD"),
672:         indentGuide: hex("#E0E0E0"),
673:         indentGuideActive: hex("#AAAAAA"),
674:         sidebarBackground: hex("#E7E7E7"),
675:         sidebarForeground: hex("#333333"),
676:         sidebarSectionHeader: hex("#DDDDDD"),
677:         sidebarSelection: hex("#C9D0D9"),
678:         activityBarBackground: hex("#E7E7E7"),
679:         activityBarForeground: hex("#333333"),
680:         activityBarSelection: hex("#333333"),
681:         tabBarBackground: hex("#E7E7E7"),
682:         tabActiveBackground: hex("#F5F5F5"),
683:         tabInactiveBackground: hex("#E7E7E7"),
684:         tabActiveForeground: hex("#333333"),
685:         tabInactiveForeground: hex("#AAAAAA"),
686:         statusBarBackground: hex("#E7E7E7"),
687:         statusBarForeground: hex("#333333"),
688:         keyword: hex("#4B83CD"),
689:         string: hex("#448C27"),
690:         number: hex("#AB6526"),
691:         comment: hex("#AAAAAA"),
692:         function: hex("#7A3E9D"),
693:         type: hex("#7A3E9D"),
694:         variable: hex("#333333")
695:     )
696:     
697:     static let red = Theme(
698:         id: "red",
699:         name: "Red",
700:         isDark: true,
701:         editorBackground: hex("#390000"),
702:         editorForeground: hex("#F8F8F8"),
703:         selection: hex("#750000"),
704:         cursor: hex("#FF0000"),
705:         lineNumber: hex("#FF6666"),
706:         lineNumberActive: hex("#FFFFFF"),
707:         currentLineHighlight: hex("#500000"),
708:         bracketPair1: hex("#FFFF66"),
709:         bracketPair2: hex("#AAFFAA"),
710:         bracketPair3: hex("#AADDFF"),
711:         bracketPair4: hex("#FFFF66"),
712:         bracketPair5: hex("#AAFFAA"),
713:         bracketPair6: hex("#AADDFF"),
714:         indentGuide: hex("#550000"),
715:         indentGuideActive: hex("#CC6666"),
716:         sidebarBackground: hex("#300000"),
717:         sidebarForeground: hex("#F8F8F8"),
718:         sidebarSectionHeader: hex("#500000"),
719:         sidebarSelection: hex("#750000"),
720:         activityBarBackground: hex("#390000"),
721:         activityBarForeground: hex("#F8F8F8"),
722:         activityBarSelection: hex("#FF0000"),
723:         tabBarBackground: hex("#300000"),
724:         tabActiveBackground: hex("#390000"),
725:         tabInactiveBackground: hex("#300000"),
726:         tabActiveForeground: hex("#FFFFFF"),
727:         tabInactiveForeground: hex("#CC6666"),
728:         statusBarBackground: hex("#FF0000"),
729:         statusBarForeground: hex("#FFFFFF"),
730:         keyword: hex("#FF6666"),
731:         string: hex("#FFA0A0"),
732:         number: hex("#FFD0D0"),
733:         comment: hex("#CC6666"),
734:         function: hex("#FFFF66"),
735:         type: hex("#AAFFAA"),
736:         variable: hex("#AADDFF")
737:     )
738:     
739:     static let tomorrowNight = Theme(
740:         id: "tomorrow_night",
741:         name: "Tomorrow Night",
742:         isDark: true,
743:         editorBackground: hex("#1D1F21"),
744:         editorForeground: hex("#C5C8C6"),
745:         selection: hex("#373B41"),
746:         cursor: hex("#AEAFAD"),
747:         lineNumber: hex("#969896"),
748:         lineNumberActive: hex("#C5C8C6"),
749:         currentLineHighlight: hex("#282A2E"),
750:         bracketPair1: hex("#F0C674"),
751:         bracketPair2: hex("#B5BD68"),
752:         bracketPair3: hex("#81A2BE"),
753:         bracketPair4: hex("#F0C674"),
754:         bracketPair5: hex("#B5BD68"),
755:         bracketPair6: hex("#81A2BE"),
756:         indentGuide: hex("#373B41"),
757:         indentGuideActive: hex("#969896"),
758:         sidebarBackground: hex("#1D1F21"),
759:         sidebarForeground: hex("#C5C8C6"),
760:         sidebarSectionHeader: hex("#282A2E"),
761:         sidebarSelection: hex("#373B41"),
762:         activityBarBackground: hex("#1D1F21"),
763:         activityBarForeground: hex("#C5C8C6"),
764:         activityBarSelection: hex("#81A2BE"),
765:         tabBarBackground: hex("#1D1F21"),
766:         tabActiveBackground: hex("#282A2E"),
767:         tabInactiveBackground: hex("#1D1F21"),
768:         tabActiveForeground: hex("#C5C8C6"),
769:         tabInactiveForeground: hex("#969896"),
770:         statusBarBackground: hex("#282A2E"),
771:         statusBarForeground: hex("#C5C8C6"),
772:         keyword: hex("#B294BB"),
773:         string: hex("#B5BD68"),
774:         number: hex("#DE935F"),
775:         comment: hex("#969896"),
776:         function: hex("#81A2BE"),
777:         type: hex("#F0C674"),
778:         variable: hex("#CC6666")
779:     )
780:     
781:     static let tomorrowNightBlue = Theme(
782:         id: "tomorrow_night_blue",
783:         name: "Tomorrow Night Blue",
784:         isDark: true,
785:         editorBackground: hex("#002451"),
786:         editorForeground: hex("#FFFFFF"),
787:         selection: hex("#003F8E"),
788:         cursor: hex("#FFFFFF"),
789:         lineNumber: hex("#7285B7"),
790:         lineNumberActive: hex("#FFFFFF"),
791:         currentLineHighlight: hex("#00346E"),
792:         bracketPair1: hex("#FFEEAD"),
793:         bracketPair2: hex("#D1F1A9"),
794:         bracketPair3: hex("#BBDAFF"),
795:         bracketPair4: hex("#FFEEAD"),
796:         bracketPair5: hex("#D1F1A9"),
797:         bracketPair6: hex("#BBDAFF"),
798:         indentGuide: hex("#003875"),
799:         indentGuideActive: hex("#7285B7"),
800:         sidebarBackground: hex("#001E40"),
801:         sidebarForeground: hex("#FFFFFF"),
802:         sidebarSectionHeader: hex("#003875"),
803:         sidebarSelection: hex("#003F8E"),
804:         activityBarBackground: hex("#002451"),
805:         activityBarForeground: hex("#FFFFFF"),
806:         activityBarSelection: hex("#BBDAFF"),
807:         tabBarBackground: hex("#001E40"),
808:         tabActiveBackground: hex("#002451"),
809:         tabInactiveBackground: hex("#001E40"),
810:         tabActiveForeground: hex("#FFFFFF"),
811:         tabInactiveForeground: hex("#7285B7"),
812:         statusBarBackground: hex("#003875"),
813:         statusBarForeground: hex("#FFFFFF"),
814:         keyword: hex("#EBBBFF"),
815:         string: hex("#D1F1A9"),
816:         number: hex("#FFC58F"),
817:         comment: hex("#7285B7"),
818:         function: hex("#BBDAFF"),
819:         type: hex("#FFEEAD"),
820:         variable: hex("#FF9DA4")
821:     )
822:     
823:     static let highContrast = Theme(
824:         id: "high_contrast",
825:         name: "High Contrast",
826:         isDark: true,
827:         editorBackground: hex("#000000"),
828:         editorForeground: hex("#FFFFFF"),
829:         selection: hex("#FFFFFF").opacity(0.3),
830:         cursor: hex("#FFFFFF"),
831:         lineNumber: hex("#FFFFFF"),
832:         lineNumberActive: hex("#FFFFFF"),
833:         currentLineHighlight: hex("#FFFFFF").opacity(0.1),
834:         bracketPair1: hex("#FFD700"),
835:         bracketPair2: hex("#00FF00"),
836:         bracketPair3: hex("#00BFFF"),
837:         bracketPair4: hex("#FFD700"),
838:         bracketPair5: hex("#00FF00"),
839:         bracketPair6: hex("#00BFFF"),
840:         indentGuide: hex("#FFFFFF").opacity(0.2),
841:         indentGuideActive: hex("#FFFFFF").opacity(0.5),
842:         sidebarBackground: hex("#000000"),
843:         sidebarForeground: hex("#FFFFFF"),
844:         sidebarSectionHeader: hex("#000000"),
845:         sidebarSelection: hex("#FFFFFF").opacity(0.15),
846:         activityBarBackground: hex("#000000"),
847:         activityBarForeground: hex("#FFFFFF"),
848:         activityBarSelection: hex("#FFFFFF"),
849:         tabBarBackground: hex("#000000"),
850:         tabActiveBackground: hex("#000000"),
851:         tabInactiveBackground: hex("#000000"),
852:         tabActiveForeground: hex("#FFFFFF"),
853:         tabInactiveForeground: hex("#FFFFFF").opacity(0.6),
854:         statusBarBackground: hex("#0000AA"),
855:         statusBarForeground: hex("#FFFFFF"),
856:         keyword: hex("#569CD6"),
857:         string: hex("#CE9178"),
858:         number: hex("#B5CEA8"),
859:         comment: hex("#7CA668"),
860:         function: hex("#DCDCAA"),
861:         type: hex("#4EC9B0"),
862:         variable: hex("#9CDCFE")
863:     )
864:     
865:     // MARK: - All Themes
866:     static let allThemes: [Theme] = [
867:         .darkPlus,
868:         .lightPlus,
869:         .monokai,
870:         .solarizedDark,
871:         .solarizedLight,
872:         .dracula,
873:         .oneDarkPro,
874:         .nord,
875:         .githubDark,
876:         .githubLight,
877:         .cobalt2,
878:         .ayuDark,
879:         .ayuLight,
880:         .ayuMirage,
881:         .quietLight,
882:         .red,
883:         .tomorrowNight,
884:         .tomorrowNightBlue,
885:         .highContrast
886:     ]
887: }


Now I need to understand how Runestone actually applies colors internally. Let me search for documentation on how Runestone uses the Theme protocol.

>>>TOOL web_search
{"query": "Runestone Swift Theme textColor highlightName syntax highlighting apply color", "max_results": 10}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Runestone Swift Theme textColor highlightName syntax highlighting apply color" (10 results):

1. **Creating a Theme | Documentation - docs.runestone.app**
   https://docs.runestone.app/documentation/runestone/creatingatheme/
   The theme determines the text styling and colors to use when syntax highlighting text. Implement the following methods on Theme to specify the text styling and color of syntax highlighted text.

2. **GitHub - appstefan/HighlightSwift: Code syntax highlighting in Swift ...**
   https://github.com/appstefan/HighlightSwift
   SwiftUI view to display a String of code with syntax highlighting 🌗 Color theme syncs automatically with Dark Mode 📜 Theme background color included with .card style 🔠 Works with Text modifiers like .bold() or .font() ⚙️ Includes modifiers to set the color theme, style &amp; language 📫 Callback modifiers to get the highlight results, language &amp; score 🍃 Memory efficient using an ...

3. **swift - How do style Text view with different font and colour on string ...**
   https://stackoverflow.com/questions/59071375/how-do-style-text-view-with-different-font-and-colour-on-string-subranges
   I want to style my Text view such that string it displays has different colours for each of 2 words. I know I can just use 2 x Text with different style. But then I should keep this string words in separate state variables. But I consider whether it is possible to define different .font ().foregroundColor () for different parts of string. There are also cases when there is longer lead and we ...

4. **Building a SwiftUI Code Block View with Syntax Highlighting**
   https://medium.com/@orhanerday/building-a-swiftui-code-block-view-with-syntax-highlighting-d3d737a90a65
   Now that we have the basic structure of the code block, let&#x27;s focus on syntax highlighting. Swift provides AttributedString, which allows us to apply different styles (such as color and font ...

5. **A package for syntax highlighting in Swift and SwiftUI**
   https://iosexample.com/a-package-for-syntax-highlighting-in-swift-and-swiftui/
   A package for syntax highlighting in Swift and SwiftUI HighlightSwift ? Syntax Highlighting in Swift and SwiftUI Contents Highlight Convert any String of code into a syntax highlighted AttributedString ? Automatic language detection ? Works for 50 common languages ? Choose from 30 classic color styles ? Built with highlight.js and JavaScriptCore ?️ Supported on iOS, iPadOS, macOS, and tvOS ...

6. **Syntax Highlighting the Text — Runestone Tutorials | Documentation**
   https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text/
   Runestone Essentials Syntax Highlighting the Text This tutorial guides you through syntax highlighting text in a text view. In this guide we&#x27;ll add support for syntax highlighting JavaScript code to the text view we configured in Setting up a TextView. We&#x27;ll use the JavaScript syntax included in the TreeSitterLanguages Swift package.

7. **Highlighting code blocks in Markdown with SwiftSyntax**
   https://artemnovichkov.com/blog/highlighting-code-blocks-in-markdown-with-swiftsyntax
   A practical guide to highlighting Swift code

8. **Syntax Highlighting SwiftUI Code with Swift Syntax**
   https://sahandnayebaziz.org/blog/syntax-highlighting-swiftui-with-swift-syntax
   The End Results DetailsPro now shows live-updating, syntax-highlighted SwiftUI code when users select any part of their design. Today, syntax highlighting is running great in DetailsPro and I&#x27;m happy to have added a what is surely a reliable dependency that will enjoy continued support by the Swift community.

9. **Runestone - Swift Package Registry**
   https://swiftpackageregistry.com/simonbs/Runestone
   👋 Welcome to Runestone - a performant plain text editor for iOS with code editing features Runestone uses GitHub&#x27;s Tree-sitter to parse code to a syntax tree which is used for features that require an understanding of the code in the editor, for example syntax highlighting.

10. **Runestone - Swift Package Index**
   https://swiftpackageindex.com/simonbs/Runestone
   Runestone by Simon B. Støvring on the Swift Package Index - 📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more.


>>>TOOL web_fetch
{"url": "https://docs.runestone.app/documentation/runestone/creatingatheme/", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://docs.runestone.app/documentation/runestone/creatingatheme/

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.92s 
[SCRAPE].. ◆ https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.00s 
[COMPLETE] ● https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.92s 
[Skip Navigation](https://docs.runestone.app/documentation/runestone/creatingatheme/#main)
Light
Dark
Auto


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Theme/Theme.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Theme/Theme.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Theme/
Theme.swift          | ✓ | ⏱: 1.18s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Theme/
Theme.swift          | ✓ | ⏱: 0.03s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Theme/
Theme.swift          | ✓ | ⏱: 1.22s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Theme/Theme.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTextView%2FTheme%2FTheme.swift)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTextView%2FTheme%2FTheme.swift)
####  Sign in to GitHub 
Username or email address 
Password  [Forgot password?](https://github.com/password_reset)
[ or continue with other methods ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTextView%2FTheme%2FTheme.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Theme/Theme.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Theme/Theme.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Theme/Theme.swift) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


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


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)
  5. /[Theme](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Theme)


/
# Theme.swift
/
Copy path
404 - page not found
The 
main
branch of 
Runestone
does not contain the path 
Sources/Runestone/TextView/Theme/Theme.swift.
[Return to the repository overview](https://github.com/simonbs/Runestone)
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone/tree/main/Sources/Runestone   
| ✓ | ⏱: 1.28s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone/tree/main/Sources/Runestone   
| ✓ | ⏱: 0.04s 
[COMPLETE] ● https://github.com/simonbs/Runestone/tree/main/Sources/Runestone   
| ✓ | ⏱: 1.33s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


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


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)


/
# Runestone
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)


/
# Runestone
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources)  
[Documentation.docc](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Documentation.docc "Documentation.docc") | [Documentation.docc](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Documentation.docc "Documentation.docc") |  [Adds StringSyntaxHighlighter (](https://github.com/simonbs/Runestone/commit/9a486543e8ea44a705359cd06069c8f86e18df1b "Adds StringSyntaxHighlighter \(#363\)

* Adds default tab stops

* Fixes SwiftLint warning

* Adds StringSyntaxHighlighter

* Adds documentation

* Fixes SwiftLint warnings

* Improves formatting")[#363](https://github.com/simonbs/Runestone/pull/363)[)](https://github.com/simonbs/Runestone/commit/9a486543e8ea44a705359cd06069c8f86e18df1b "Adds StringSyntaxHighlighter \(#363\)

* Adds default tab stops

* Fixes SwiftLint warning

* Adds StringSyntaxHighlighter

* Adds documentation

* Fixes SwiftLint warnings

* Improves formatting") | Mar 23, 2024  
[Library](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Library "Library") | [Library](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Library "Library") |  [Fix build with Xcode 16 (](https://github.com/simonbs/Runestone/commit/1fad339aab99cf2136ce6bf8c32da3265b2e85e5 "Fix build with Xcode 16 \(#375\)

Prior to this, Xcode 16 was unable to infer the type of the variable \(while Xcode 15 was\), so the lookup to `reversed\(\)` was ambiguous.

This adds `String` as the inferred type, so that the call to `reversed\(\)` is no longer ambiguous.")[#375](https://github.com/simonbs/Runestone/pull/375)[)](https://github.com/simonbs/Runestone/commit/1fad339aab99cf2136ce6bf8c32da3265b2e85e5 "Fix build with Xcode 16 \(#375\)

Prior to this, Xcode 16 was unable to infer the type of the variable \(while Xcode 15 was\), so the lookup to `reversed\(\)` was ambiguous.

This adds `String` as the inferred type, so that the call to `reversed\(\)` is no longer ambiguous.") | Jun 11, 2024  
[LineManager](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/LineManager "LineManager") | [LineManager](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/LineManager "LineManager") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[RedBlackTree](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/RedBlackTree "RedBlackTree") | [RedBlackTree](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/RedBlackTree "RedBlackTree") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[Resources](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Resources "Resources") | [Resources](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Resources "Resources") |  [Create Localizable.strings (](https://github.com/simonbs/Runestone/commit/d862d75901b679556e8486255842825e987733e2 "Create Localizable.strings \(#194\)")[#194](https://github.com/simonbs/Runestone/pull/194)[)](https://github.com/simonbs/Runestone/commit/d862d75901b679556e8486255842825e987733e2 "Create Localizable.strings \(#194\)") | Sep 21, 2022  
[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView "TextView") | [TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView "TextView") |  [Scroll edge effect blurs line numbers on iOS 26 (](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7 "Scroll edge effect blurs line numbers on iOS 26 \(#404\)")[#404](https://github.com/simonbs/Runestone/pull/404)[)](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7 "Scroll edge effect blurs line numbers on iOS 26 \(#404\)") | Aug 31, 2025  
[TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter "TreeSitter") | [TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter "TreeSitter") |  [Modernizes GitHub Actions workflows (](https://github.com/simonbs/Runestone/commit/5bb9f9b59965c18fa0aa1cb183747ea9f85d5cc5 "Modernizes GitHub Actions workflows \(#301\)

* Removes extraneous whitespace

* Uses latest macOS versions

* Uses latest stable Xcode

* Selects Xcode version using environment variable

* Removes third-party action for SwiftLint

* Removes CODEQL_ENABLE_EXPERIMENTAL_FEATURES_SWIFT

* Adds concurrency rules

* Explicitly uses macOS 13 runners

* Fixes SwiftLint error

* Ensure SwiftLint is newest version

* Use SwiftLint via Homebrew

* Overwrite linked SwiftLint

* Set Homebrew related environment variables

* Removes existing SwiftLint

* Runs installed SwiftLint

* Disables prefer_self_in_static_references

* Uses version 3 of actions/checkout")[#301](https://github.com/simonbs/Runestone/pull/301)[)](https://github.com/simonbs/Runestone/commit/5bb9f9b59965c18fa0aa1cb183747ea9f85d5cc5 "Modernizes GitHub Actions workflows \(#301\)

* Removes extraneous whitespace

* Uses latest macOS versions

* Uses latest stable Xcode

* Selects Xcode version using environment variable

* Removes third-party action for SwiftLint

* Removes CODEQL_ENABLE_EXPERIMENTAL_FEATURES_SWIFT

* Adds concurrency rules

* Explicitly uses macOS 13 runners

* Fixes SwiftLint error

* Ensure SwiftLint is newest version

* Use SwiftLint via Homebrew

* Overwrite linked SwiftLint

* Set Homebrew related environment variables

* Removes existing SwiftLint

* Runs installed SwiftLint

* Disables prefer_self_in_static_references

* Uses version 3 of actions/checkout") | Jul 15, 2023  
[PrivacyInfo.xcprivacy](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/PrivacyInfo.xcprivacy "PrivacyInfo.xcprivacy") | [PrivacyInfo.xcprivacy](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/PrivacyInfo.xcprivacy "PrivacyInfo.xcprivacy") |  [Adds privacy report (](https://github.com/simonbs/Runestone/commit/9ba5a1fb624701c230524b9751b23ea05840947f "Adds privacy report \(#358\)")[#358](https://github.com/simonbs/Runestone/pull/358)[)](https://github.com/simonbs/Runestone/commit/9ba5a1fb624701c230524b9751b23ea05840947f "Adds privacy report \(#358\)") | Mar 16, 2024  
[StringSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/StringSyntaxHighlighter.swift "StringSyntaxHighlighter.swift") | [StringSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/StringSyntaxHighlighter.swift "StringSyntaxHighlighter.swift") |  [Adds StringSyntaxHighlighter (](https://github.com/simonbs/Runestone/commit/9a486543e8ea44a705359cd06069c8f86e18df1b "Adds StringSyntaxHighlighter \(#363\)

* Adds default tab stops

* Fixes SwiftLint warning

* Adds StringSyntaxHighlighter

* Adds documentation

* Fixes SwiftLint warnings

* Improves formatting")[#363](https://github.com/simonbs/Runestone/pull/363)[)](https://github.com/simonbs/Runestone/commit/9a486543e8ea44a705359cd06069c8f86e18df1b "Adds StringSyntaxHighlighter \(#363\)

* Adds default tab stops

* Fixes SwiftLint warning

* Adds StringSyntaxHighlighter

* Adds documentation

* Fixes SwiftLint warnings

* Improves formatting") | Mar 23, 2024  
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/SyntaxHighlighter.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/SyntaxHighlighter.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest...tView/SyntaxHighlighting/Synt
axHighlighter.swift  | ✓ | ⏱: 0.60s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest...tView/SyntaxHighlighting/Synt
axHighlighter.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest...tView/SyntaxHighlighting/Synt
axHighlighter.swift  | ✓ | ⏱: 0.60s 
```
404: Not Found
```


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 1.31s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 1.35s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


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


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)


/
# TextView
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)


/
# TextView
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)  
[Appearance](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance "Appearance") | [Appearance](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance "Appearance") |  |   
[CharacterPairs](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/CharacterPairs "CharacterPairs") | [CharacterPairs](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/CharacterPairs "CharacterPairs") |  |   
[Core](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Core "Core") | [Core](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Core "Core") |  |   
[Gutter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Gutter "Gutter") | [Gutter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Gutter "Gutter") |  |   
[Highlight](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Highlight "Highlight") | [Highlight](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Highlight "Highlight") |  |   
[Indent](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Indent "Indent") | [Indent](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Indent "Indent") |  |   
[InvisibleCharacters](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/InvisibleCharacters "InvisibleCharacters") | [InvisibleCharacters](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/InvisibleCharacters "InvisibleCharacters") |  |   
[LineController](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController "LineController") | [LineController](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController "LineController") |  |   
[Navigation](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Navigation "Navigation") | [Navigation](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Navigation "Navigation") |  |   
[PageGuide](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/PageGuide "PageGuide") | [PageGuide](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/PageGuide "PageGuide") |  |   
[SearchAndReplace](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SearchAndReplace "SearchAndReplace") | [SearchAndReplace](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SearchAndReplace "SearchAndReplace") |  |   
[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting "SyntaxHighlighting") | [SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting "SyntaxHighlighting") |  |   
[TextSelection](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/TextSelection "TextSelection") | [TextSelection](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/TextSelection "TextSelection") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Syntax
Highlighting         | ✓ | ⏱: 1.23s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Syntax
Highlighting         | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Syntax
Highlighting         | ✓ | ⏱: 1.27s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


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


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
          * Internal
          * PlainText
          * TreeSitter
          * LanguageMode.swift
          * SyntaxNode.swift
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# SyntaxHighlighting
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# SyntaxHighlighting
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)  
[Internal](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal "Internal") | [Internal](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal "Internal") |  |   
[PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/PlainText "PlainText") | [PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/PlainText "PlainText") |  |   
[TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter "TreeSitter") | [TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter "TreeSitter") |  |   
[LanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/LanguageMode.swift "LanguageMode.swift") | [LanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/LanguageMode.swift "LanguageMode.swift") |  |   
[SyntaxNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/SyntaxNode.swift "SyntaxNode.swift") | [SyntaxNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/SyntaxNode.swift "SyntaxNode.swift") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/S...s/Runestone/TextView/SyntaxHi
ghlighting/Internal  | ✓ | ⏱: 1.16s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/S...s/Runestone/TextView/SyntaxHi
ghlighting/Internal  | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/S...s/Runestone/TextView/SyntaxHi
ghlighting/Internal  | ✓ | ⏱: 1.21s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting%2FInternal)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting%2FInternal)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


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


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
          * Internal
            * PlainText
            * TreeSitter
            * InternalLanguageMode.swift
            * InternalLanguageModeFactory.swift
          * PlainText
          * TreeSitter
          * LanguageMode.swift
          * SyntaxNode.swift
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)
  5. /[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)


/
# Internal
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)
  5. /[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)


/
# Internal
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)  
[PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/PlainText "PlainText") | [PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/PlainText "PlainText") |  |   
[TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter "TreeSitter") | [TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter "TreeSitter") |  |   
[InternalLanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageMode.swift "InternalLanguageMode.swift") | [InternalLanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageMode.swift "InternalLanguageMode.swift") |  |   
[InternalLanguageModeFactory.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageModeFactory.swift "InternalLanguageModeFactory.swift") | [InternalLanguageModeFactory.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageModeFactory.swift "InternalLanguageModeFactory.swift") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineCo
ntroller             | ✓ | ⏱: 1.33s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineCo
ntroller             | ✓ | ⏱: 0.05s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineCo
ntroller             | ✓ | ⏱: 1.38s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FLineController)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FLineController)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


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


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
          * LineBreak
          * LineController.swift
          * LineControllerFactory.swift
          * LineControllerStorage.swift
          * LineFragment.swift
          * LineFragmentCharacterLocationQuery.swift
          * LineFragmentController.swift
          * LineFragmentFrameQuery.swift
          * LineFragmentNode.swift
          * LineFragmentRenderer.swift
          * LineFragmentSelectionRect.swift
          * LineSyntaxHighlighter.swift
          * LineTypesetter.swift
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# LineController
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/LineController)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/LineController)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# LineController
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)  
[LineBreak](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController/LineBreak "LineBreak") | [LineBreak](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController/LineBreak "LineBreak") |  |   
[LineController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineController.swift "LineController.swift") | [LineController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineController.swift "LineController.swift") |  |   
[LineControllerFactory.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineControllerFactory.swift "LineControllerFactory.swift") | [LineControllerFactory.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineControllerFactory.swift "LineControllerFactory.swift") |  |   
[LineControllerStorage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineControllerStorage.swift "LineControllerStorage.swift") | [LineControllerStorage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineControllerStorage.swift "LineControllerStorage.swift") |  |   
[LineFragment.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragment.swift "LineFragment.swift") | [LineFragment.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragment.swift "LineFragment.swift") |  |   
[LineFragmentCharacterLocationQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentCharacterLocationQuery.swift "LineFragmentCharacterLocationQuery.swift") | [LineFragmentCharacterLocationQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentCharacterLocationQuery.swift "LineFragmentCharacterLocationQuery.swift") |  |   
[LineFragmentController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentController.swift "LineFragmentController.swift") | [LineFragmentController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentController.swift "LineFragmentController.swift") |  |   
[LineFragmentFrameQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentFrameQuery.swift "LineFragmentFrameQuery.swift") | [LineFragmentFrameQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentFrameQuery.swift "LineFragmentFrameQuery.swift") |  |   
[LineFragmentNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentNode.swift "LineFragmentNode.swift") | [LineFragmentNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentNode.swift "LineFragmentNode.swift") |  |   
[LineFragmentRenderer.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentRenderer.swift "LineFragmentRenderer.swift") | [LineFragmentRenderer.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentRenderer.swift "LineFragmentRenderer.swift") |  |   
[LineFragmentSelectionRect.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentSelectionRect.swift "LineFragmentSelectionRect.swift") | [LineFragmentSelectionRect.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentSelectionRect.swift "LineFragmentSelectionRect.swift") |  |   
[LineSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift "LineSyntaxHighlighter.swift") | [LineSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift "LineSyntaxHighlighter.swift") |  |   
[LineTypesetter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineTypesetter.swift "LineTypesetter.swift") | [LineTypesetter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineTypesetter.swift "LineTypesetter.swift") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest...tView/LineController/LineSynt
axHighlighter.swift  | ✓ | ⏱: 0.71s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest...tView/LineController/LineSynt
axHighlighter.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest...tView/LineController/LineSynt
axHighlighter.swift  | ✓ | ⏱: 0.71s 
```
import CoreGraphics
import Foundation

extension NSAttributedString.Key {
    static let isBold = NSAttributedString.Key("runestone_isBold")
    static let isItalic = NSAttributedString.Key("runestone_isItalic")
}

struct LineSyntaxHiglighterSetAttributesResult {
    let isSizingInvalid: Bool
}

final class LineSyntaxHighlighterInput {
    let attributedString: NSMutableAttributedString
    let byteRange: ByteRange

    init(attributedString: NSMutableAttributedString, byteRange: ByteRange) {
        self.attributedString = attributedString
        self.byteRange = byteRange
    }
}

protocol LineSyntaxHighlighter: AnyObject {
    typealias AsyncCallback = (Result<Void, Error>) -> Void
    var theme: Theme { get set }
    var canHighlight: Bool { get }
    func syntaxHighlight(_ input: LineSyntaxHighlighterInput)
    func syntaxHighlight(_ input: LineSyntaxHighlighterInput, completion: @escaping AsyncCallback)
    func cancel()
}

```


Excellent! Found the key file! Let me get the TreeSitter implementation that actually applies colors:

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlighter.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlighter.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest...nal/TreeSitter/TreeSitterSynt
axHighlighter.swift  | ✓ | ⏱: 0.51s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest...nal/TreeSitter/TreeSitterSynt
axHighlighter.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest...nal/TreeSitter/TreeSitterSynt
axHighlighter.swift  | ✓ | ⏱: 0.52s 
```
import UIKit

enum TreeSitterSyntaxHighlighterError: LocalizedError {
    case cancelled
    case operationDeallocated

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Operation was cancelled"
        case .operationDeallocated:
            return "The operation was deallocated"
        }
    }
}

final class TreeSitterSyntaxHighlighter: LineSyntaxHighlighter {
    var theme: Theme = DefaultTheme()
    var kern: CGFloat = 0
    var canHighlight: Bool {
        languageMode.canHighlight
    }

    private let stringView: StringView
    private let languageMode: TreeSitterInternalLanguageMode
    private let operationQueue: OperationQueue
    private var currentOperation: Operation?

    init(stringView: StringView, languageMode: TreeSitterInternalLanguageMode, operationQueue: OperationQueue) {
        self.stringView = stringView
        self.languageMode = languageMode
        self.operationQueue = operationQueue
    }

    func syntaxHighlight(_ input: LineSyntaxHighlighterInput) {
        let captures = languageMode.captures(in: input.byteRange)
        let tokens = self.tokens(for: captures, localTo: input.byteRange)
        setAttributes(for: tokens, on: input.attributedString)
    }

    func syntaxHighlight(_ input: LineSyntaxHighlighterInput, completion: @escaping AsyncCallback) {
        let operation = BlockOperation()
        operation.addExecutionBlock { [weak operation, weak self] in
            guard let operation = operation, let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(TreeSitterSyntaxHighlighterError.operationDeallocated))
                }
                return
            }
            guard !operation.isCancelled else {
                DispatchQueue.main.async {
                    completion(.failure(TreeSitterSyntaxHighlighterError.cancelled))
                }
                return
            }
            let captures = self.languageMode.captures(in: input.byteRange)
            if !operation.isCancelled {
                DispatchQueue.main.async {
                    if !operation.isCancelled {
                        let tokens = self.tokens(for: captures, localTo: input.byteRange)
                        self.setAttributes(for: tokens, on: input.attributedString)
                        completion(.success(()))
                    } else {
                        completion(.failure(TreeSitterSyntaxHighlighterError.cancelled))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(TreeSitterSyntaxHighlighterError.cancelled))
                }
            }
        }
        currentOperation = operation
        operationQueue.addOperation(operation)
    }

    func cancel() {
        currentOperation?.cancel()
        currentOperation = nil
    }
}

private extension TreeSitterSyntaxHighlighter {
    private func setAttributes(for tokens: [TreeSitterSyntaxHighlightToken], on attributedString: NSMutableAttributedString) {
        attributedString.beginEditing()
        for token in tokens {
            var attributes: [NSAttributedString.Key: Any] = [:]
            if let foregroundColor = token.textColor {
                attributes[.foregroundColor] = foregroundColor
            }
            if let shadow = token.shadow {
                attributes[.shadow] = shadow
            }
            if token.fontTraits.contains(.bold) {
                attributedString.addAttribute(.isBold, value: true, range: token.range)
            }
            if token.fontTraits.contains(.italic) {
                attributedString.addAttribute(.isItalic, value: true, range: token.range)
            }
            var symbolicTraits: UIFontDescriptor.SymbolicTraits = []
            if let isBold = attributedString.attribute(.isBold, at: token.range.location, effectiveRange: nil) as? Bool, isBold {
                symbolicTraits.insert(.traitBold)
            }
            if let isItalic = attributedString.attribute(.isItalic, at: token.range.location, effectiveRange: nil) as? Bool, isItalic {
                symbolicTraits.insert(.traitItalic)
            }
            let currentFont = attributedString.attribute(.font, at: token.range.location, effectiveRange: nil) as? UIFont
            let baseFont = token.font ?? theme.font
            let newFont: UIFont
            if !symbolicTraits.isEmpty {
                newFont = baseFont.withSymbolicTraits(symbolicTraits) ?? baseFont
            } else {
                newFont = baseFont
            }
            if newFont != currentFont {
                attributes[.font] = newFont
            }
            if !attributes.isEmpty {
                attributedString.addAttributes(attributes, range: token.range)
            }
        }
        attributedString.endEditing()
    }

    private func tokens(for captures: [TreeSitterCapture], localTo localRange: ByteRange) -> [TreeSitterSyntaxHighlightToken] {
        var tokens: [TreeSitterSyntaxHighlightToken] = []
        for capture in captures where capture.byteRange.overlaps(localRange) {
            // We highlight each line separately but a capture may extend beyond a line,
            // e.g. an unterminated string, so we need to cap the start and end location
            // to ensure it's within the line.
            let cappedStartByte = max(capture.byteRange.lowerBound, localRange.lowerBound)
            let cappedEndByte = min(capture.byteRange.upperBound, localRange.upperBound)
            let length = cappedEndByte - cappedStartByte
            let cappedRange = ByteRange(location: cappedStartByte - localRange.lowerBound, length: length)
            if !cappedRange.isEmpty {
                let token = token(from: capture, in: cappedRange)
                if !token.isEmpty {
                    tokens.append(token)
                }
            }
        }
        return tokens
    }
}

private extension TreeSitterSyntaxHighlighter {
    private func token(from capture: TreeSitterCapture, in byteRange: ByteRange) -> TreeSitterSyntaxHighlightToken {
        let range = NSRange(byteRange)
        let textColor = theme.textColor(for: capture.name)
        let shadow = theme.shadow(for: capture.name)
        let font = theme.font(for: capture.name)
        let fontTraits = theme.fontTraits(for: capture.name)
        return TreeSitterSyntaxHighlightToken(range: range, textColor: textColor, shadow: shadow, font: font, fontTraits: fontTraits)
    }
}

private extension UIFont {
    func withSymbolicTraits(_ symbolicTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        if let newFontDescriptor = fontDescriptor.withSymbolicTraits(symbolicTraits) {
            return UIFont(descriptor: newFontDescriptor, size: pointSize)
        } else {
            return nil
        }
    }
}

```


This is the critical code! Now let me check the Theme protocol to see all required methods:

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appear
ance                 | ✓ | ⏱: 1.27s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appear
ance                 | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appear
ance                 | ✓ | ⏱: 1.32s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FAppearance)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FAppearance)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


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


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
          * Theme.xcassets
          * DefaultTheme.swift
          * FontTraits.swift
          * HighlightName.swift
          * LineBreakMode.swift
          * LineSelectionDisplayType.swift
          * Theme.swift
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# Appearance
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
[![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)](https://github.com/simonbs)[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[No longer uses system colors (](https://github.com/simonbs/Runestone/commit/bea27981428993589e739985bf5e4f502c927de9)[#352](https://github.com/simonbs/Runestone/pull/352)[)](https://github.com/simonbs/Runestone/commit/bea27981428993589e739985bf5e4f502c927de9)
Feb 28, 2024
[bea2798](https://github.com/simonbs/Runestone/commit/bea27981428993589e739985bf5e4f502c927de9) · Feb 28, 2024
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/Appearance)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/Appearance)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# Appearance
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)  
[Theme.xcassets](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance/Theme.xcassets "Theme.xcassets") | [Theme.xcassets](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance/Theme.xcassets "Theme.xcassets") |  |   
[DefaultTheme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/DefaultTheme.swift "DefaultTheme.swift") | [DefaultTheme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/DefaultTheme.swift "DefaultTheme.swift") |  |   
[FontTraits.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/FontTraits.swift "FontTraits.swift") | [FontTraits.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/FontTraits.swift "FontTraits.swift") |  |   
[HighlightName.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/HighlightName.swift "HighlightName.swift") | [HighlightName.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/HighlightName.swift "HighlightName.swift") |  |   
[LineBreakMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineBreakMode.swift "LineBreakMode.swift") | [LineBreakMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineBreakMode.swift "LineBreakMode.swift") |  |   
[LineSelectionDisplayType.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineSelectionDisplayType.swift "LineSelectionDisplayType.swift") | [LineSelectionDisplayType.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineSelectionDisplayType.swift "LineSelectionDisplayType.swift") |  |   
[Theme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/Theme.swift "Theme.swift") | [Theme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/Theme.swift "Theme.swift") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/Theme.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/Theme.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest...ources/Runestone/TextView/App
earance/Theme.swift  | ✓ | ⏱: 0.53s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest...ources/Runestone/TextView/App
earance/Theme.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest...ources/Runestone/TextView/App
earance/Theme.swift  | ✓ | ⏱: 0.53s 
```
import UIKit

/// Fonts and colors to be used by a `TextView`.
public protocol Theme: AnyObject {
    /// Default font of text in the text view.
    var font: UIFont { get }
    /// Default color of text in the text view.
    var textColor: UIColor { get }
    /// Background color of the gutter containing line numbers.
    var gutterBackgroundColor: UIColor { get }
    /// Color of the hairline next to the gutter containing line numbers.
    var gutterHairlineColor: UIColor { get }
    /// Width of the hairline next to the gutter containing line numbers.
    var gutterHairlineWidth: CGFloat { get }
    /// Color of the line numbers in the gutter.
    var lineNumberColor: UIColor { get }
    /// Font of the line nubmers in the gutter.
    var lineNumberFont: UIFont { get }
    /// Background color of the selected line.
    var selectedLineBackgroundColor: UIColor { get }
    /// Color of the line number of the selected line.
    var selectedLinesLineNumberColor: UIColor { get }
    /// Background color of the gutter for selected lines.
    var selectedLinesGutterBackgroundColor: UIColor { get }
    /// Color of invisible characters, i.e. dots, spaces and line breaks.
    var invisibleCharactersColor: UIColor { get }
    /// Color of the hairline next to the page guide.
    var pageGuideHairlineColor: UIColor { get }
    /// Width of the hairline next to the page guide.
    var pageGuideHairlineWidth: CGFloat { get }
    /// Background color of the page guide.
    var pageGuideBackgroundColor: UIColor { get }
    /// Background color of marked text. Text will be marked when writing certain languages, for example Chinese and Japanese.
    var markedTextBackgroundColor: UIColor { get }
    /// Corner radius of the background of marked text. Text will be marked when writing certain languages, for example Chinese and Japanese.
    /// A value of zero or less means that the background will not have rounded corners. Defaults to 0.
    var markedTextBackgroundCornerRadius: CGFloat { get }
    /// Color of text matching the capture sequence.
    ///
    /// See <doc:CreatingATheme> for more information on higlight names.
    func textColor(for highlightName: String) -> UIColor?
    /// Font of text matching the capture sequence.
    ///
    /// See <doc:CreatingATheme> for more information on higlight names.
    func font(for highlightName: String) -> UIFont?
    /// Traits of text matching the capture sequence.
    ///
    /// See <doc:CreatingATheme> for more information on higlight names.
    func fontTraits(for highlightName: String) -> FontTraits
    /// Shadow of text matching the capture sequence.
    ///
    /// See <doc:CreatingATheme> for more information on higlight names.
    func shadow(for highlightName: String) -> NSShadow?
    /// Highlighted range for a text range matching a search query.
    ///
    /// This function is called when highlighting a search result that was found using the standard find/replace interaction enabled using <doc:TextView/isFindInteractionEnabled>.
    ///
    /// Return `nil` to prevent highlighting the range.
    /// - Parameters:
    ///   - foundTextRange: The text range matching a search query.
    ///   - style: Style used to decorate the text.
    /// - Returns: The object used for highlighting the provided text range, or `nil` if the range should not be highlighted.
    @available(iOS 16, *)
    func highlightedRange(forFoundTextRange foundTextRange: NSRange, ofStyle style: UITextSearchFoundTextStyle) -> HighlightedRange?
}

public extension Theme {
    var gutterHairlineWidth: CGFloat {
        hairlineLength
    }

    var pageGuideHairlineWidth: CGFloat {
        hairlineLength
    }

    var markedTextBackgroundCornerRadius: CGFloat {
        0
    }

    func font(for highlightName: String) -> UIFont? {
        nil
    }

    func fontTraits(for highlightName: String) -> FontTraits {
        []
    }

    func shadow(for highlightName: String) -> NSShadow? {
        nil
    }

    @available(iOS 16, *)
    func highlightedRange(forFoundTextRange foundTextRange: NSRange, ofStyle style: UITextSearchFoundTextStyle) -> HighlightedRange? {
        switch style {
        case .found:
            return HighlightedRange(range: foundTextRange, color: .systemYellow.withAlphaComponent(0.2))
        case .highlighted:
            return HighlightedRange(range: foundTextRange, color: .systemYellow)
        case .normal:
            return nil
        @unknown default:
            return nil
        }
    }
}

```


Now I have the full picture. Let me also check the TreeSitter internal language mode to see how captures are produced:

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInternalLanguageMode.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInternalLanguageMode.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest.../TreeSitter/TreeSitterInterna
lLanguageMode.swift  | ✓ | ⏱: 0.55s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest.../TreeSitter/TreeSitterInterna
lLanguageMode.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest.../TreeSitter/TreeSitterInterna
lLanguageMode.swift  | ✓ | ⏱: 0.55s 
```
import Foundation
import TreeSitter

protocol TreeSitterLanguageModeDelegate: AnyObject {
    func treeSitterLanguageMode(_ languageMode: TreeSitterInternalLanguageMode, bytesAt byteIndex: ByteCount) -> TreeSitterTextProviderResult?
}

final class TreeSitterInternalLanguageMode: InternalLanguageMode {
    weak var delegate: TreeSitterLanguageModeDelegate?
    var canHighlight: Bool {
        rootLanguageLayer.canHighlight
    }

    private let stringView: StringView
    private let parser: TreeSitterParser
    private let lineManager: LineManager
    private let rootLanguageLayer: TreeSitterLanguageLayer
    private let operationQueue = OperationQueue()
    private let parseLock = NSLock()

    init(language: TreeSitterInternalLanguage, languageProvider: TreeSitterLanguageProvider?, stringView: StringView, lineManager: LineManager) {
        self.stringView = stringView
        self.lineManager = lineManager
        operationQueue.name = "TreeSitterLanguageMode"
        operationQueue.qualityOfService = .default
        parser = TreeSitterParser(encoding: TSInputEncodingUTF16)
        rootLanguageLayer = TreeSitterLanguageLayer(
            language: language,
            languageProvider: languageProvider,
            parser: parser,
            stringView: stringView,
            lineManager: lineManager)
        parser.delegate = self
    }

    deinit {
        operationQueue.cancelAllOperations()
    }

    func parse(_ text: NSString) {
        parseLock.withLock {
            rootLanguageLayer.parse(text)
        }
    }

    func parse(_ text: NSString, completion: @escaping ((Bool) -> Void)) {
        operationQueue.cancelAllOperations()
        let operation = BlockOperation()
        operation.addExecutionBlock { [weak operation, weak self] in
            if let self = self, let operation = operation, !operation.isCancelled {
                self.parse(text)
                DispatchQueue.main.async {
                    completion(!operation.isCancelled)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        operationQueue.addOperation(operation)
    }

    func textDidChange(_ change: TextChange) -> LineChangeSet {
        let bytesRemoved = change.byteRange.length
        let bytesAdded = change.bytesAdded
        let edit = TreeSitterInputEdit(
            startByte: change.byteRange.location,
            oldEndByte: change.byteRange.location + bytesRemoved,
            newEndByte: change.byteRange.location + bytesAdded,
            startPoint: TreeSitterTextPoint(change.startLinePosition),
            oldEndPoint: TreeSitterTextPoint(change.oldEndLinePosition),
            newEndPoint: TreeSitterTextPoint(change.newEndLinePosition))
        return rootLanguageLayer.apply(edit)
    }

    func captures(in range: ByteRange) -> [TreeSitterCapture] {
        rootLanguageLayer.captures(in: range)
    }

    func createLineSyntaxHighlighter() -> LineSyntaxHighlighter {
        TreeSitterSyntaxHighlighter(stringView: stringView, languageMode: self, operationQueue: operationQueue)
    }

    func currentIndentLevel(of line: DocumentLineNode, using indentStrategy: IndentStrategy) -> Int {
        let measurer = IndentLevelMeasurer(stringView: stringView)
        return measurer.indentLevel(lineStartLocation: line.location, lineTotalLength: line.data.totalLength, tabLength: indentStrategy.tabLength)
    }

    func strategyForInsertingLineBreak(from startLinePosition: LinePosition,
                                       to endLinePosition: LinePosition,
                                       using indentStrategy: IndentStrategy) -> InsertLineBreakIndentStrategy {
        let startLayerAndNode = rootLanguageLayer.layerAndNode(at: startLinePosition)
        let endLayerAndNode = rootLanguageLayer.layerAndNode(at: endLinePosition)
        if let indentationScopes = startLayerAndNode?.layer.language.indentationScopes ?? endLayerAndNode?.layer.language.indentationScopes {
            let indentController = TreeSitterIndentController(
                indentationScopes: indentationScopes,
                stringView: stringView,
                lineManager: lineManager,
                tabLength: indentStrategy.tabLength)
            let startNode = startLayerAndNode?.node
            let endNode = endLayerAndNode?.node
            return indentController.strategyForInsertingLineBreak(
                between: startNode,
                and: endNode,
                caretStartPosition: startLinePosition,
                caretEndPosition: endLinePosition)
        } else {
            return InsertLineBreakIndentStrategy(indentLevel: 0, insertExtraLineBreak: false)
        }
    }

    func syntaxNode(at linePosition: LinePosition) -> SyntaxNode? {
        if let node = rootLanguageLayer.layerAndNode(at: linePosition)?.node, let type = node.type {
            let startLocation = TextLocation(LinePosition(node.startPoint))
            let endLocation = TextLocation(LinePosition(node.endPoint))
            return SyntaxNode(type: type, startLocation: startLocation, endLocation: endLocation)
        } else {
            return nil
        }
    }

    func detectIndentStrategy() -> DetectedIndentStrategy {
        if let tree = rootLanguageLayer.tree {
            let detector = TreeSitterIndentStrategyDetector(lineManager: lineManager, tree: tree, stringView: stringView)
            return detector.detect()
        } else {
            return .unknown
        }
    }
}

extension TreeSitterInternalLanguageMode: TreeSitterParserDelegate {
    func parser(_ parser: TreeSitterParser, bytesAt byteIndex: ByteCount) -> TreeSitterTextProviderResult? {
        delegate?.treeSitterLanguageMode(self, bytesAt: byteIndex)
    }
}

```


Now I have the full picture. Let me look at how the base text color is initially set on the attributed string:

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/LineController/LineController.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/LineController/LineController.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest...one/TextView/LineController/L
ineController.swift  | ✓ | ⏱: 0.50s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest...one/TextView/LineController/L
ineController.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest...one/TextView/LineController/L
ineController.swift  | ✓ | ⏱: 0.51s 
```
// swiftlint:disable file_length
import CoreGraphics
import CoreText
import UIKit

typealias LineFragmentTree = RedBlackTree<LineFragmentNodeID, Int, LineFragmentNodeData>

protocol LineControllerDelegate: AnyObject {
    func lineSyntaxHighlighter(for lineController: LineController) -> LineSyntaxHighlighter?
    func lineControllerDidInvalidateLineWidthDuringAsyncSyntaxHighlight(_ lineController: LineController)
}

final class LineController {
    private enum TypesetAmount {
        case inRect(CGRect)
        case toLocation(Int)
    }

    weak var delegate: LineControllerDelegate?
    let line: DocumentLineNode
    var lineFragmentHeightMultiplier: CGFloat = 1 {
        didSet {
            if lineFragmentHeightMultiplier != oldValue {
                typesetter.lineFragmentHeightMultiplier = lineFragmentHeightMultiplier
            }
        }
    }
    var theme: Theme = DefaultTheme() {
        didSet {
            syntaxHighlighter?.theme = theme
            applyThemeToAllLineFragmentControllers()
        }
    }
    var estimatedLineFragmentHeight: CGFloat = 15
    var tabWidth: CGFloat = 10
    var constrainingWidth: CGFloat {
        get {
            typesetter.constrainingWidth
        }
        set {
            typesetter.constrainingWidth = newValue
        }
    }
    var lineWidth: CGFloat {
        ceil(typesetter.maximumLineWidth)
    }
    var lineHeight: CGFloat {
        if let lineHeight = _lineHeight {
            return lineHeight
        } else if typesetter.lineFragments.isEmpty {
            let lineHeight = estimatedLineFragmentHeight * lineFragmentHeightMultiplier
            _lineHeight = lineHeight
            return lineHeight
        } else {
            let knownLineFragmentHeight = typesetter.lineFragments.reduce(0) { $0 + $1.scaledSize.height }
            let remainingNumberOfLineFragments = typesetter.bestGuessNumberOfLineFragments - typesetter.lineFragments.count
            let lineFragmentHeight = estimatedLineFragmentHeight * lineFragmentHeightMultiplier
            let remainingLineFragmentHeight = CGFloat(remainingNumberOfLineFragments) * lineFragmentHeight
            let lineHeight = knownLineFragmentHeight + remainingLineFragmentHeight
            _lineHeight = lineHeight
            return lineHeight
        }
    }
    var kern: CGFloat = 0 {
        didSet {
            if kern != oldValue {
                isDefaultAttributesInvalid = true
            }
        }
    }
    var lineBreakMode: LineBreakMode {
        get {
            typesetter.lineBreakMode
        }
        set {
            typesetter.lineBreakMode = newValue
        }
    }
    var numberOfLineFragments: Int {
        typesetter.lineFragments.count
    }
    var isFinishedTypesetting: Bool {
        typesetter.isFinishedTypesetting
    }
    private(set) var attributedString: NSMutableAttributedString?

    private let stringView: StringView
    private let invisibleCharacterConfiguration: InvisibleCharacterConfiguration
    private let highlightService: HighlightService
    private let typesetter: LineTypesetter
    private var cachedSyntaxHighlighter: LineSyntaxHighlighter?
    private var lineFragmentControllers: [LineFragmentID: LineFragmentController] = [:]
    private var isLineFragmentCacheInvalid = true
    private var isStringInvalid = true
    private var isDefaultAttributesInvalid = true
    private var isSyntaxHighlightingInvalid = true
    private var isTypesetterInvalid = true
    private var _lineHeight: CGFloat?
    private var lineFragmentTree: LineFragmentTree
    private var syntaxHighlighter: LineSyntaxHighlighter? {
        if let cachedSyntaxHighlighter = cachedSyntaxHighlighter {
            return cachedSyntaxHighlighter
        } else if let syntaxHighlighter = delegate?.lineSyntaxHighlighter(for: self) {
            syntaxHighlighter.theme = theme
            cachedSyntaxHighlighter = syntaxHighlighter
            return syntaxHighlighter
        } else {
            return nil
        }
    }

    init(line: DocumentLineNode,
         stringView: StringView,
         invisibleCharacterConfiguration: InvisibleCharacterConfiguration,
         highlightService: HighlightService) {
        self.line = line
        self.stringView = stringView
        self.invisibleCharacterConfiguration = invisibleCharacterConfiguration
        self.highlightService = highlightService
        self.typesetter = LineTypesetter(lineID: line.id.rawValue)
        let rootLineFragmentNodeData = LineFragmentNodeData(lineFragment: nil)
        self.lineFragmentTree = LineFragmentTree(minimumValue: 0, rootValue: 0, rootData: rootLineFragmentNodeData)
    }

    func prepareToDisplayString(in rect: CGRect, syntaxHighlightAsynchronously: Bool) {
        prepareToDisplayString(.inRect(rect), syntaxHighlightAsynchronously: syntaxHighlightAsynchronously)
    }

    func prepareToDisplayString(toLocation location: Int, syntaxHighlightAsynchronously: Bool) {
        prepareToDisplayString(.toLocation(location), syntaxHighlightAsynchronously: syntaxHighlightAsynchronously)
    }

    func cancelSyntaxHighlighting() {
        syntaxHighlighter?.cancel()
    }

    func invalidateEverything() {
        isLineFragmentCacheInvalid = true
        isStringInvalid = true
        isTypesetterInvalid = true
        isDefaultAttributesInvalid = true
        isSyntaxHighlightingInvalid = true
        _lineHeight = nil
    }

    func invalidateSyntaxHighlighter() {
        cachedSyntaxHighlighter = nil
    }

    func invalidateSyntaxHighlighting() {
        isTypesetterInvalid = true
        isDefaultAttributesInvalid = true
        isSyntaxHighlightingInvalid = true
        _lineHeight = nil
    }

    func lineFragmentControllers(in rect: CGRect) -> [LineFragmentController] {
        let lineYPosition = line.yPosition
        let localMinY = rect.minY - lineYPosition
        let localMaxY = rect.maxY - lineYPosition
        let query = LineFragmentFrameQuery(range: localMinY ... localMaxY)
        return lineFragmentControllers(matching: query)
    }

    func lineFragmentNode(containingCharacterAt location: Int) -> LineFragmentNode? {
        lineFragmentTree.node(containingLocation: location)
    }

    func lineFragmentNode(atIndex index: Int) -> LineFragmentNode {
        lineFragmentTree.node(atIndex: index)
    }

    func setNeedsDisplayOnLineFragmentViews() {
        for (_, lineFragmentController) in lineFragmentControllers {
            lineFragmentController.lineFragmentView?.setNeedsDisplay()
        }
    }

    func setMarkedTextOnLineFragments(_ range: NSRange?) {
        for (_, lineFragmentController) in lineFragmentControllers {
            let lineFragment = lineFragmentController.lineFragment
            if let range = range, range.overlaps(lineFragment.visibleRange) {
                lineFragmentController.markedRange = range
            } else {
                lineFragmentController.markedRange = nil
            }
        }
    }
}

private extension LineController {
    private func prepareToDisplayString(_ typesetAmount: TypesetAmount, syntaxHighlightAsynchronously: Bool) {
        prepareString(syntaxHighlightAsynchronously: syntaxHighlightAsynchronously)
        typesetLineFragments(typesetAmount)
    }

    private func prepareString(syntaxHighlightAsynchronously: Bool) {
        syntaxHighlighter?.cancel()
        clearLineFragmentControllersIfNecessary()
        updateStringIfNecessary()
        updateDefaultAttributesIfNecessary()
        updateSyntaxHighlightingIfNecessary(async: syntaxHighlightAsynchronously)
        updateTypesetterIfNecessary()
    }

    private func typesetLineFragments(_ typesetAmount: TypesetAmount) {
        let newLineFragments: [LineFragment]
        switch typesetAmount {
        case .inRect(let rect):
            newLineFragments = typesetter.typesetLineFragments(in: rect)
        case .toLocation(let location):
            // When typesetting to a location we'll typeset an additional line fragment to ensure that we can display the text surrounding that location.
            newLineFragments = typesetter.typesetLineFragments(toLocation: location, additionalLineFragmentCount: 1)
        }
        updateLineHeight(for: newLineFragments)
    }

    private func clearLineFragmentControllersIfNecessary() {
        if isLineFragmentCacheInvalid {
            lineFragmentControllers.removeAll(keepingCapacity: true)
            isLineFragmentCacheInvalid = false
        }
    }

    private func updateStringIfNecessary() {
        if isStringInvalid {
            let range = NSRange(location: line.location, length: line.data.totalLength)
            if let string = stringView.substring(in: range) {
                attributedString = NSMutableAttributedString(string: string)
            } else {
                attributedString = nil
            }
            isStringInvalid = false
            isDefaultAttributesInvalid = true
            isSyntaxHighlightingInvalid = true
            isTypesetterInvalid = true
        }
    }

    private func updateDefaultAttributesIfNecessary() {
        if isDefaultAttributesInvalid {
            if let input = createLineSyntaxHighlightInput() {
                let defaultStringAttributes = DefaultStringAttributes(
                    textColor: theme.textColor,
                    font: theme.font,
                    kern: kern,
                    tabWidth: tabWidth
                )
                defaultStringAttributes.apply(to: input.attributedString)
            }
            isDefaultAttributesInvalid = false
            isSyntaxHighlightingInvalid = true
            isTypesetterInvalid = true
        }
    }

    private func updateTypesetterIfNecessary() {
        if isTypesetterInvalid {
            lineFragmentTree.reset(rootValue: 0, rootData: LineFragmentNodeData(lineFragment: nil))
            typesetter.reset()
            if let attributedString = attributedString {
                typesetter.prepareToTypeset(attributedString)
            }
            isTypesetterInvalid = false
        }
    }

    private func updateSyntaxHighlightingIfNecessary(async: Bool) {
        guard isSyntaxHighlightingInvalid else {
            return
        }
        guard let syntaxHighlighter = syntaxHighlighter else {
            return
        }
        guard syntaxHighlighter.canHighlight else {
            isSyntaxHighlightingInvalid = false
            return
        }
        guard let input = createLineSyntaxHighlightInput() else {
            isSyntaxHighlightingInvalid = false
            return
        }
        if async {
            syntaxHighlighter.syntaxHighlight(input) { [weak self] result in
                if case .success = result, let self = self {
                    let oldWidth = self.lineWidth
                    self.isSyntaxHighlightingInvalid = false
                    self.isTypesetterInvalid = true
                    self.redisplayLineFragments()
                    if abs(self.lineWidth - oldWidth) > CGFloat.ulpOfOne {
                        self.delegate?.lineControllerDidInvalidateLineWidthDuringAsyncSyntaxHighlight(self)
                    }
                }
            }
        } else {
            syntaxHighlighter.cancel()
            syntaxHighlighter.syntaxHighlight(input)
            isSyntaxHighlightingInvalid = false
            isTypesetterInvalid = true
        }
    }

    private func updateLineHeight(for lineFragments: [LineFragment]) {
        var previousNode: LineFragmentNode?
        for lineFragment in lineFragments {
            let length = lineFragment.range.length
            let data = LineFragmentNodeData(lineFragment: lineFragment)
            if lineFragment.index < lineFragmentTree.nodeTotalCount {
                let node = lineFragmentTree.node(atIndex: lineFragment.index)
                let heightDifference = abs(lineFragment.baseSize.height - node.data.lineFragmentHeight)
                if heightDifference > CGFloat.ulpOfOne {
                    _lineHeight = nil
                }
                node.value = length
                node.data.lineFragment = lineFragment
                node.updateTotalLineFragmentHeight()
                lineFragmentTree.updateAfterChangingChildren(of: node)
                previousNode = node
            } else if let thisPreviousNode = previousNode {
                let newNode = lineFragmentTree.insertNode(value: length, data: data, after: thisPreviousNode)
                newNode.updateTotalLineFragmentHeight()
                previousNode = newNode
                _lineHeight = nil
            } else {
                let thisPreviousNode = lineFragmentTree.node(atIndex: lineFragment.index - 1)
                let newNode = lineFragmentTree.insertNode(value: length, data: data, after: thisPreviousNode)
                newNode.updateTotalLineFragmentHeight()
                previousNode = newNode
                _lineHeight = nil
            }
        }
    }

    private func createLineSyntaxHighlightInput() -> LineSyntaxHighlighterInput? {
        if let attributedString = attributedString {
            let byteRange = line.data.totalByteRange
            return LineSyntaxHighlighterInput(attributedString: attributedString, byteRange: byteRange)
        } else {
            return nil
        }
    }

    private func lineFragmentController(for lineFragment: LineFragment) -> LineFragmentController {
        if let lineFragmentController = lineFragmentControllers[lineFragment.id] {
            lineFragmentController.lineFragment = lineFragment
            return lineFragmentController
        } else {
            let lineFragmentController = LineFragmentController(
                lineFragment: lineFragment,
                invisibleCharacterConfiguration: invisibleCharacterConfiguration
            )
            lineFragmentController.delegate = self
            lineFragmentControllers[lineFragment.id] = lineFragmentController
            applyTheme(to: lineFragmentController)
            return lineFragmentController
        }
    }

    private func redisplayLineFragments() {
        let typesetLength = typesetter.typesetLength
        _lineHeight = nil
        updateTypesetterIfNecessary()
        let newLineFragments = typesetter.typesetLineFragments(toLocation: typesetLength)
        updateLineHeight(for: newLineFragments)
        reapplyLineFragmentToLineFragmentControllers()
        setNeedsDisplayOnLineFragmentViews()
    }

    private func reapplyLineFragmentToLineFragmentControllers() {
        for (_, lineFragmentController) in lineFragmentControllers {
            let lineFragmentID = lineFragmentController.lineFragment.id
            if let lineFragment = typesetter.lineFragment(withID: lineFragmentID) {
                lineFragmentController.lineFragment = lineFragment
            }
        }
    }

    private func lineFragmentControllers<T: RedBlackTreeSearchQuery>(matching query: T)
    -> [LineFragmentController] where T.NodeID == LineFragmentNodeID, T.NodeValue == Int, T.NodeData == LineFragmentNodeData {
        let queryResult = lineFragmentTree.search(using: query)
        return queryResult.compactMap { match in
            if let lineFragment = match.node.data.lineFragment {
                return lineFragmentController(for: lineFragment)
            } else {
                return nil
            }
        }
    }

    private func applyThemeToAllLineFragmentControllers() {
        for (_, lineFragmentController) in lineFragmentControllers {
            applyTheme(to: lineFragmentController)
        }
    }

    private func applyTheme(to lineFragmentController: LineFragmentController) {
        lineFragmentController.markedTextBackgroundColor = theme.markedTextBackgroundColor
        lineFragmentController.markedTextBackgroundCornerRadius = theme.markedTextBackgroundCornerRadius
    }

    private func lineFragment(closestTo point: CGPoint) -> LineFragment? {
        var closestLineFragment = typesetter.lineFragments.last
        for lineFragment in typesetter.lineFragments {
            let lineMaxY = lineFragment.yPosition + lineFragment.scaledSize.height
            if point.y <= lineMaxY {
                closestLineFragment = lineFragment
                break
            }
        }
        return closestLineFragment
    }
}

// MARK: - UITextInput
extension LineController {
    func caretRect(atIndex lineLocalLocation: Int) -> CGRect {
        for lineFragment in typesetter.lineFragments {
            if let caretLocation = lineFragment.caretLocation(forLineLocalLocation: lineLocalLocation) {
                let xPosition = CTLineGetOffsetForStringIndex(lineFragment.line, caretLocation, nil)
                let yPosition = lineFragment.yPosition + (lineFragment.scaledSize.height - lineFragment.baseSize.height) / 2
                return CGRect(x: xPosition, y: yPosition, width: Caret.width, height: lineFragment.baseSize.height)
            }
        }
        let yPosition = (estimatedLineFragmentHeight * lineFragmentHeightMultiplier - estimatedLineFragmentHeight) / 2
        return CGRect(x: 0, y: yPosition, width: Caret.width, height: estimatedLineFragmentHeight)
    }

    func firstRect(for lineLocalRange: NSRange) -> CGRect {
        for lineFragment in typesetter.lineFragments {
            if let caretRange = lineFragment.caretRange(forLineLocalRange: lineLocalRange) {
                let finalIndex = min(lineFragment.visibleRange.upperBound, caretRange.upperBound)
                let xStart = CTLineGetOffsetForStringIndex(lineFragment.line, caretRange.location, nil)
                let xEnd = CTLineGetOffsetForStringIndex(lineFragment.line, finalIndex, nil)
                let yPosition = lineFragment.yPosition + (lineFragment.scaledSize.height - lineFragment.baseSize.height) / 2
                return CGRect(x: xStart, y: yPosition, width: xEnd - xStart, height: lineFragment.baseSize.height)
            }
        }
        return CGRect(x: 0, y: 0, width: 0, height: estimatedLineFragmentHeight * lineFragmentHeightMultiplier)
    }

    func closestIndex(to point: CGPoint) -> Int {
        guard let closestLineFragment = lineFragment(closestTo: point) else {
            return line.location
        }
        let localLocation = min(CTLineGetStringIndexForPosition(closestLineFragment.line, point), line.data.length)
        return line.location + localLocation
    }
}

// MARK: - LineFragmentControllerDelegate
extension LineController: LineFragmentControllerDelegate {
    func string(in controller: LineFragmentController) -> String? {
        let lineFragment = controller.lineFragment
        let range = NSRange(location: line.location + lineFragment.visibleRange.location, length: lineFragment.visibleRange.length)
        return stringView.substring(in: range)
    }
}

```


Now I have the complete picture of how colors are applied in Runestone. Let me compile my findings.

>>>REPORT
## Runestone Color Application - Complete Trace

### How Colors Are ACTUALLY Applied

**File: Runestone source (from GitHub)**

#### 1. Base Text Color Application
In `LineController.swift`, the `updateDefaultAttributesIfNecessary()` method applies the default text color to the ENTIRE attributed string FIRST:
```swift
let defaultStringAttributes = DefaultStringAttributes(
    textColor: theme.textColor,
    font: theme.font,
    kern: kern,
    tabWidth: tabWidth
)
defaultStringAttributes.apply(to: input.attributedString)
```

#### 2. Syntax Highlighting Color Application
In `TreeSitterSyntaxHighlighter.swift`, the `setAttributes(for:on:)` method THEN applies syntax colors on top:
```swift
private func setAttributes(for tokens: [TreeSitterSyntaxHighlightToken], on attributedString: NSMutableAttributedString) {
    attributedString.beginEditing()
    for token in tokens {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let foregroundColor = token.textColor {
            attributes[.foregroundColor] = foregroundColor  // ← CRITICAL LINE
        }
        // ... font traits handling
        if !attributes.isEmpty {
            attributedString.addAttributes(attributes, range: token.range)
        }
    }
    attributedString.endEditing()
}
```

#### 3. Color Resolution Flow
```
TreeSitter parses code → Produces captures (e.g., "keyword", "string.quoted")
    ↓
languageMode.captures(in: byteRange) returns [TreeSitterCapture]
    ↓
theme.textColor(for: capture.name) called for each capture
    ↓
If color returned: applied via addAttributes(.foregroundColor)
If nil returned: DEFAULT text color stays (from step 1)
```

### The Theme Protocol (from Runestone source)
```swift
public protocol Theme: AnyObject {
    var font: UIFont { get }
    var textColor: UIColor { get }  // Default color for all text
    // ... gutter, line numbers, etc.
    
    func textColor(for highlightName: String) -> UIColor?  // CRITICAL: Syntax colors
    func font(for highlightName: String) -> UIFont?
    func fontTraits(for highlightName: String) -> FontTraits
}
```

### Why All Text Might End Up Same Color

**Root Cause Options:**

1. **TreeSitter Not Producing Captures**
   - Language grammar not loaded correctly
   - Highlights.scm query file missing or not bundled
   - Parsing failing silently

2. **textColor(for:) Returning nil For All Names**
   - Highlight names from TreeSitter don't match patterns in theme
   - Example: TreeSitter emits `"string.quoted.double"` but theme checks for `"string"` with exact match

3. **Theme Colors Same as Default**
   - All syntax colors accidentally set to same value as `textColor`

### Your Implementation Analysis

In `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift` (lines 586-686):
```swift
func textColor(for rawHighlightName: String) -> UIColor? {
    let highlightName = rawHighlightName.lowercased()
    
    // Debug line is COMMENTED OUT:
    // print("🎨 HIGHLIGHT: '\(rawHighlightName)'")
    
    if highlightName.contains("keyword") {
        return _keywordColor
    }
    // ... more patterns
    return nil  // Falls back to default textColor
}
```

### Debugging Recommendation

**Uncomment the debug print on line 591** to see what highlight names TreeSitter actually produces:
```swift
print("🎨 HIGHLIGHT: '\(rawHighlightName)'")
```

If NO output appears → TreeSitter isn't producing captures (language/query issue)
If output appears with names → Compare names to pattern matching logic

### Key Files Examined
- Runestone source: `TreeSitterSyntaxHighlighter.swift` - applies colors via `addAttributes`
- Runestone source: `LineController.swift` - applies default color first
- Runestone source: `Theme.swift` - defines the protocol
- Local: `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift` - theme implementation (lines 460-703)
>>>END
