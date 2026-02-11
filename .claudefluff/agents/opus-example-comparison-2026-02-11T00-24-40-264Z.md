# Agent: opus-example-comparison
**Status:** done
**Tokens:** 9,306
**Cost:** $0.0000
**Time:** 2026-02-11T00:24:40.264Z

## Task
CRITICAL: Find and analyze the Runestone Example app. Search ~/Library/Developer/Xcode/DerivedData for Runestone example code. See how THEY set up syntax highlighting and theming. Compare to our implementation. Find differences.

## Response
I'll search for the Runestone Example app in the DerivedData directory and analyze their syntax highlighting and theming setup.

>>>TOOL list_dir
{"path": "/Users/danielswagg/Library/Developer/Xcode/DerivedData"}
>>>END

Let me search for Runestone example code in other locations.

>>>TOOL list_dir
{"path": "/Users/danielswagg/Library/Developer/Xcode"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg/Library/Developer/Xcode" not found


Let me search for Runestone-related files in the current project and check for any downloaded Runestone source code.

>>>TOOL list_dir
{"path": "/Users/danielswagg/Library/Developer"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg/Library/Developer" not found


>>>TOOL list_dir
{"path": "/Users/danielswagg"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg" not found


Let me search within the current project directory for Runestone-related files and any example code.

>>>TOOL search
{"query": "Runestone example", "glob": "**/*"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
.claudefluff/agents/runestone-spm-setup-2026-02-10T15-14-54-587Z.md:1183: Let me search for Runestone examples and the specific language packages:


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


>>>TOOL search
{"query": "TreeSitterLanguage", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 25 matches:
VSCodeiPadOS/TreeSitterLanguages.swift:2: //  TreeSitterLanguages.swift
VSCodeiPadOS/TreeSitterLanguages.swift:41: public struct TreeSitterLanguages {
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:194: /// Maps file extensions to Runestone TreeSitterLanguage
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:196: static func treeSitterLanguage(for filename: String) -> TreeSitterLanguage? {
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:676: // MARK: - TreeSitterLanguage Enum
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:680: enum TreeSitterLanguage {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:194: /// Maps file extensions to Runestone TreeSitterLanguage
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:196: static func treeSitterLanguage(for filename: String) -> TreeSitterLanguage? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:676: // MARK: - TreeSitterLanguage Enum
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:680: enum TreeSitterLanguage {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:110: if let language = getTreeSitterLanguage(for: filename) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:169: if let language = getTreeSitterLanguage(for: filename) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:186: if let language = getTreeSitterLanguage(for: filename) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:234: private func getTreeSitterLanguage(for filename: String) -> Runestone.TreeSitterLanguage? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:252: return TreeSitterLanguage.json
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:258: return TreeSitterLanguage.swift
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:262: return TreeSitterLanguage.javaScript
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:266: return TreeSitterLanguage.javaScript
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:270: return TreeSitterLanguage.python
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:274: return TreeSitterLanguage.go
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:278: return TreeSitterLanguage.rust
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:282: return TreeSitterLanguage.json
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:286: return TreeSitterLanguage.html
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:290: return TreeSitterLanguage.css
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:294: return TreeSitterLanguage.html


Let me read our current implementation and then search for Runestone's official example code.

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


Now let me search for Runestone's official example code to compare with our implementation.

>>>TOOL web_search
{"query": "Runestone GitHub example app syntax highlighting theme setup site:github.com/simonbs/Runestone"}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Runestone GitHub example app syntax highlighting theme setup site:github.com/simonbs/Runestone" (10 results):

1. **Runestone/README.md at main · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/blob/main/README.md
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - Runestone/README.md at main · simonbs/Runestone

2. **Runestone/Tests/RunestoneTests at main - GitHub**
   https://github.com/simonbs/Runestone/tree/main/Tests/RunestoneTests
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - simonbs/Runestone

3. **Runestone/Package.resolved at main · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/blob/main/Package.resolved
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - Runestone/Package.resolved at main · simonbs/Runestone

4. **Releases · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/releases
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - simonbs/Runestone

5. **Activity · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/activity?ref=main
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - Activity · simonbs/Runestone

6. **Build Example Project · Workflow runs · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/actions/workflows/build_example_project.yml
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - Build Example Project · Workflow runs · simonbs/Runestone

7. **Forks · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/forks
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - Forks · simonbs/Runestone

8. **Network Graph · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/network
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - Network Graph · simonbs/Runestone

9. **Community Standards · GitHub**
   https://github.com/simonbs/Runestone/community
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - Community Standards · simonbs/Runestone

10. **Add Clojure as supported language · Issue #246 · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/issues/246
   What solution would you like? Add syntax highlighting for clj/cljs files as Clojure code.


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Example", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Example

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone/tree/main/Example             
| ✓ | ⏱: 1.38s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone/tree/main/Example             
| ✓ | ⏱: 0.03s 
[COMPLETE] ● https://github.com/simonbs/Runestone/tree/main/Example             
| ✓ | ⏱: 1.42s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Example#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
    * Languages
    * Themes
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


/
# Example
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
[History](https://github.com/simonbs/Runestone/commits/main/Example)
[](https://github.com/simonbs/Runestone/commits/main/Example)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)


/
# Example
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main)  
[Example.xcodeproj](https://github.com/simonbs/Runestone/tree/main/Example/Example.xcodeproj "Example.xcodeproj") | [Example.xcodeproj](https://github.com/simonbs/Runestone/tree/main/Example/Example.xcodeproj "Example.xcodeproj") |  |   
[Example](https://github.com/simonbs/Runestone/tree/main/Example/Example "Example") | [Example](https://github.com/simonbs/Runestone/tree/main/Example/Example "Example") |  |   
[Languages](https://github.com/simonbs/Runestone/tree/main/Example/Languages "Languages") | [Languages](https://github.com/simonbs/Runestone/tree/main/Example/Languages "Languages") |  |   
[Themes](https://github.com/simonbs/Runestone/tree/main/Example/Themes "Themes") | [Themes](https://github.com/simonbs/Runestone/tree/main/Example/Themes "Themes") |  |   
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


Let me fetch the Example app's theme and main code files.

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Example/Themes", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Example/Themes

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone/tree/main/Example/Themes      
| ✓ | ⏱: 1.36s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone/tree/main/Example/Themes      
| ✓ | ⏱: 0.05s 
[COMPLETE] ● https://github.com/simonbs/Runestone/tree/main/Example/Themes      
| ✓ | ⏱: 1.42s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Example/Themes#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FThemes)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FThemes)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Themes) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Themes) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Themes) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
    * Languages
    * Themes
      * Sources
      * .gitignore
      * Package.swift
      * README.md
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)


/
# Themes
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
[History](https://github.com/simonbs/Runestone/commits/main/Example/Themes)
[](https://github.com/simonbs/Runestone/commits/main/Example/Themes)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)


/
# Themes
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Example)  
[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources "Sources") | [Sources](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources "Sources") |  |   
[.gitignore](https://github.com/simonbs/Runestone/blob/main/Example/Themes/.gitignore ".gitignore") | [.gitignore](https://github.com/simonbs/Runestone/blob/main/Example/Themes/.gitignore ".gitignore") |  |   
[Package.swift](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Package.swift "Package.swift") | [Package.swift](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Package.swift "Package.swift") |  |   
[README.md](https://github.com/simonbs/Runestone/blob/main/Example/Themes/README.md "README.md") | [README.md](https://github.com/simonbs/Runestone/blob/main/Example/Themes/README.md "README.md") |  |   
View all files  
## [README.md](https://github.com/simonbs/Runestone/tree/main/Example/Themes#readme)
# Themes
[](https://github.com/simonbs/Runestone/tree/main/Example/Themes#themes)
Contains the themes used by the example project. The following themes are included:
  * One Dark
  * Plain Text
  * Tomorrow
  * Tomorrow Night


The RunestoneThemeCommon package includes the types used across all of the themes and the example project.
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
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Example/Themes/Sources/RunestoneThemeOneDark/OneDarkTheme.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
Error: https://raw.githubusercontent.com/simonbs/Runestone/main/Example/Themes/Sources/RunestoneThemeOneDark/OneDarkTheme.swift returned 404


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources           
| ✓ | ⏱: 1.12s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources           
| ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources           
| ✓ | ⏱: 1.16s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FThemes%2FSources)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FThemes%2FSources)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
    * Languages
    * Themes
      * Sources
        * RunestoneOneDarkTheme
        * RunestonePlainTextTheme
        * RunestoneThemeCommon
        * RunestoneTomorrowNightTheme
        * RunestoneTomorrowTheme
      * .gitignore
      * Package.swift
      * README.md
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Themes](https://github.com/simonbs/Runestone/tree/main/Example/Themes)


/
# Sources
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
[Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028)[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028)
Open commit details
Feb 6, 2023
[1db0e1b](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028) · Feb 6, 2023
## History
[History](https://github.com/simonbs/Runestone/commits/main/Example/Themes/Sources)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Example/Themes/Sources)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Themes](https://github.com/simonbs/Runestone/tree/main/Example/Themes)


/
# Sources
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Example/Themes)  
[RunestoneOneDarkTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneOneDarkTheme "RunestoneOneDarkTheme") | [RunestoneOneDarkTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneOneDarkTheme "RunestoneOneDarkTheme") |  |   
[RunestonePlainTextTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestonePlainTextTheme "RunestonePlainTextTheme") | [RunestonePlainTextTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestonePlainTextTheme "RunestonePlainTextTheme") |  |   
[RunestoneThemeCommon](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneThemeCommon "RunestoneThemeCommon") | [RunestoneThemeCommon](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneThemeCommon "RunestoneThemeCommon") |  |   
[RunestoneTomorrowNightTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneTomorrowNightTheme "RunestoneTomorrowNightTheme") | [RunestoneTomorrowNightTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneTomorrowNightTheme "RunestoneTomorrowNightTheme") |  |   
[RunestoneTomorrowTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneTomorrowTheme "RunestoneTomorrowTheme") | [RunestoneTomorrowTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneTomorrowTheme "RunestoneTomorrowTheme") |  |   
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
{"url": "https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/E...Sources/RunestoneOneDarkTheme
/OneDarkTheme.swift  | ✓ | ⏱: 1.39s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/E...Sources/RunestoneOneDarkTheme
/OneDarkTheme.swift  | ✓ | ⏱: 0.05s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/E...Sources/RunestoneOneDarkTheme
/OneDarkTheme.swift  | ✓ | ⏱: 1.44s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FThemes%2FSources%2FRunestoneOneDarkTheme%2FOneDarkTheme.swift)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FThemes%2FSources%2FRunestoneOneDarkTheme%2FOneDarkTheme.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
    * Languages
    * Themes
      * Sources
        * RunestoneOneDarkTheme
          * Colors.xcassets
          * OneDarkTheme.swift
        * RunestonePlainTextTheme
        * RunestoneThemeCommon
        * RunestoneTomorrowNightTheme
        * RunestoneTomorrowTheme
      * .gitignore
      * Package.swift
      * README.md
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Themes](https://github.com/simonbs/Runestone/tree/main/Example/Themes)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources)
  5. /[RunestoneOneDarkTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneOneDarkTheme)


/
# OneDarkTheme.swift
Copy path
BlameMore file actions
BlameMore file actions
## Latest commit
[![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)](https://github.com/simonbs)[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[Splits example project into Swift packages (](https://github.com/simonbs/Runestone/commit/0352d728ef74fcefd0de9c3c2e307a08d019734b)[#37](https://github.com/simonbs/Runestone/pull/37)[)](https://github.com/simonbs/Runestone/commit/0352d728ef74fcefd0de9c3c2e307a08d019734b)
Open commit details
May 9, 2022
[0352d72](https://github.com/simonbs/Runestone/commit/0352d728ef74fcefd0de9c3c2e307a08d019734b) · May 9, 2022
## History
[History](https://github.com/simonbs/Runestone/commits/main/Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift)History
69 lines (57 loc) · 2.73 KB
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Themes](https://github.com/simonbs/Runestone/tree/main/Example/Themes)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources)
  5. /[RunestoneOneDarkTheme](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneOneDarkTheme)


/
# OneDarkTheme.swift
Top
## File metadata and controls
  * Code
  * Blame


69 lines (57 loc) · 2.73 KB
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
[Raw](https://github.com/simonbs/Runestone/raw/refs/heads/main/Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift)
Copy raw file
Download raw file
Open symbols panel
Edit and raw actions
import Runestone import RunestoneThemeCommon import UIKit public final class OneDarkTheme: EditorTheme { public let backgroundColor = UIColor(namedInModule: "OneDarkBackground") public let userInterfaceStyle: UIUserInterfaceStyle = .dark public let font: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular) public let textColor = UIColor(namedInModule: "OneDarkForeground") public let gutterBackgroundColor = UIColor(namedInModule: "OneDarkCurrentLine") public let gutterHairlineColor: UIColor = .opaqueSeparator public let lineNumberColor = UIColor(namedInModule: "OneDarkForeground").withAlphaComponent(0.5) public let lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular) public let selectedLineBackgroundColor = UIColor(namedInModule: "OneDarkCurrentLine") public let selectedLinesLineNumberColor = UIColor(namedInModule: "OneDarkForeground") public let selectedLinesGutterBackgroundColor: UIColor = .clear public let invisibleCharactersColor = UIColor(namedInModule: "OneDarkForeground").withAlphaComponent(0.7) public let pageGuideHairlineColor = UIColor(namedInModule: "OneDarkForeground") public let pageGuideBackgroundColor = UIColor(namedInModule: "OneDarkCurrentLine") public let markedTextBackgroundColor = UIColor(namedInModule: "OneDarkForeground").withAlphaComponent(0.1) public let markedTextBackgroundCornerRadius: CGFloat = 4 public init() {} public func textColor(for rawHighlightName: String) -> UIColor? { guard let highlightName = HighlightName(rawHighlightName) else { return nil } switch highlightName { case .comment: return UIColor(namedInModule: "OneDarkComment") case .operator, .punctuation: return UIColor(namedInModule: "OneDarkForeground").withAlphaComponent(0.75) case .property: return UIColor(namedInModule: "OneDarkAqua") case .function: return UIColor(namedInModule: "OneDarkBlue") case .string: return UIColor(namedInModule: "OneDarkGreen") case .number: return UIColor(namedInModule: "OneDarkYellow") case .keyword: return UIColor(namedInModule: "OneDarkPurple") case .variableBuiltin: return UIColor(namedInModule: "OneDarkRed") } } public func fontTraits(for rawHighlightName: String) -> FontTraits { if let highlightName = HighlightName(rawHighlightName), highlightName == .keyword { return .bold } else { return [] } } } private extension UIColor { convenience init(namedInModule name: String) { self.init(named: name, in: .module, compatibleWith: nil)! } }
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
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


This is excellent! Let me now look at the `HighlightName` enum they use for mapping.

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/E...Sources/RunestoneThemeCommon/
HighlightName.swift  | ✓ | ⏱: 1.37s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/E...Sources/RunestoneThemeCommon/
HighlightName.swift  | ✓ | ⏱: 0.05s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/E...Sources/RunestoneThemeCommon/
HighlightName.swift  | ✓ | ⏱: 1.42s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FThemes%2FSources%2FRunestoneThemeCommon%2FHighlightName.swift)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FThemes%2FSources%2FRunestoneThemeCommon%2FHighlightName.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
    * Languages
    * Themes
      * Sources
        * RunestoneOneDarkTheme
        * RunestonePlainTextTheme
        * RunestoneThemeCommon
          * EditorTheme.swift
          * HighlightName.swift
        * RunestoneTomorrowNightTheme
        * RunestoneTomorrowTheme
      * .gitignore
      * Package.swift
      * README.md
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Themes](https://github.com/simonbs/Runestone/tree/main/Example/Themes)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources)
  5. /[RunestoneThemeCommon](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneThemeCommon)


/
# HighlightName.swift
Copy path
BlameMore file actions
BlameMore file actions
## Latest commit
[![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)](https://github.com/simonbs)[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[Splits example project into Swift packages (](https://github.com/simonbs/Runestone/commit/0352d728ef74fcefd0de9c3c2e307a08d019734b)[#37](https://github.com/simonbs/Runestone/pull/37)[)](https://github.com/simonbs/Runestone/commit/0352d728ef74fcefd0de9c3c2e307a08d019734b)
Open commit details
May 9, 2022
[0352d72](https://github.com/simonbs/Runestone/commit/0352d728ef74fcefd0de9c3c2e307a08d019734b) · May 9, 2022
## History
[History](https://github.com/simonbs/Runestone/commits/main/Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift)History
38 lines (35 loc) · 1.18 KB
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Themes](https://github.com/simonbs/Runestone/tree/main/Example/Themes)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources)
  5. /[RunestoneThemeCommon](https://github.com/simonbs/Runestone/tree/main/Example/Themes/Sources/RunestoneThemeCommon)


/
# HighlightName.swift
Top
## File metadata and controls
  * Code
  * Blame


38 lines (35 loc) · 1.18 KB
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
[Raw](https://github.com/simonbs/Runestone/raw/refs/heads/main/Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift)
Copy raw file
Download raw file
Open symbols panel
Edit and raw actions
import Foundation #if DEBUG private var previousUnrecognizedHighlightNames: [String] = [] #endif public enum HighlightName: String { case comment case function case keyword case number case `operator` case property case punctuation case string case variableBuiltin = "variable.builtin" public init?(_ rawHighlightName: String) { var comps = rawHighlightName.split(separator: ".") while !comps.isEmpty { let candidateRawHighlightName = comps.joined(separator: ".") if let highlightName = Self(rawValue: candidateRawHighlightName) { self = highlightName return } comps.removeLast() } #if DEBUG if !previousUnrecognizedHighlightNames.contains(rawHighlightName) { previousUnrecognizedHighlightNames.append(rawHighlightName) print("Unrecognized highlight name: '\\(rawHighlightName)'." + " Add the highlight name to HighlightName.swift if you want to add support for syntax highlighting it." + " This message will only be shown once per highlight name.") } #endif return nil } }
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
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


Now let me find how they set up the editor with language support:

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Example/Example", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Example/Example

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone/tree/main/Example/Example     
| ✓ | ⏱: 1.25s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone/tree/main/Example/Example     
| ✓ | ⏱: 0.04s 
[COMPLETE] ● https://github.com/simonbs/Runestone/tree/main/Example/Example     
| ✓ | ⏱: 1.30s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Example/Example#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FExample)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FExample)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Example) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Example) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Example) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
      * Application
      * Assets.xcassets
      * Library
      * Main
      * ThemePicker
      * Example.entitlements
      * Info.plist
    * Languages
    * Themes
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)


/
# Example
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
[History](https://github.com/simonbs/Runestone/commits/main/Example/Example)
[](https://github.com/simonbs/Runestone/commits/main/Example/Example)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)


/
# Example
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Example)  
[Application](https://github.com/simonbs/Runestone/tree/main/Example/Example/Application "Application") | [Application](https://github.com/simonbs/Runestone/tree/main/Example/Example/Application "Application") |  |   
[Assets.xcassets](https://github.com/simonbs/Runestone/tree/main/Example/Example/Assets.xcassets "Assets.xcassets") | [Assets.xcassets](https://github.com/simonbs/Runestone/tree/main/Example/Example/Assets.xcassets "Assets.xcassets") |  |   
[Library](https://github.com/simonbs/Runestone/tree/main/Example/Example/Library "Library") | [Library](https://github.com/simonbs/Runestone/tree/main/Example/Example/Library "Library") |  |   
[Main](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main "Main") | [Main](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main "Main") |  |   
[ThemePicker](https://github.com/simonbs/Runestone/tree/main/Example/Example/ThemePicker "ThemePicker") | [ThemePicker](https://github.com/simonbs/Runestone/tree/main/Example/Example/ThemePicker "ThemePicker") |  |   
[Example.entitlements](https://github.com/simonbs/Runestone/blob/main/Example/Example/Example.entitlements "Example.entitlements") | [Example.entitlements](https://github.com/simonbs/Runestone/blob/main/Example/Example/Example.entitlements "Example.entitlements") |  |   
[Info.plist](https://github.com/simonbs/Runestone/blob/main/Example/Example/Info.plist "Info.plist") | [Info.plist](https://github.com/simonbs/Runestone/blob/main/Example/Example/Info.plist "Info.plist") |  |   
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
{"url": "https://github.com/simonbs/Runestone/tree/main/Example/Example/Main", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Example/Example/Main

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone/tree/main/Example/Example/Main
| ✓ | ⏱: 1.17s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone/tree/main/Example/Example/Main
| ✓ | ⏱: 0.04s 
[COMPLETE] ● https://github.com/simonbs/Runestone/tree/main/Example/Example/Main
| ✓ | ⏱: 1.22s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FExample%2FMain)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FExample%2FMain)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
      * Application
      * Assets.xcassets
      * Library
      * Main
        * Menu
        * KeyboardToolsView.swift
        * MainView.swift
        * MainViewController.swift
      * ThemePicker
      * Example.entitlements
      * Info.plist
    * Languages
    * Themes
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Example](https://github.com/simonbs/Runestone/tree/main/Example/Example)


/
# Main
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
[History](https://github.com/simonbs/Runestone/commits/main/Example/Example/Main)
[](https://github.com/simonbs/Runestone/commits/main/Example/Example/Main)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Example](https://github.com/simonbs/Runestone/tree/main/Example/Example)


/
# Main
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Example/Example)  
[Menu](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main/Menu "Menu") | [Menu](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main/Menu "Menu") |  |   
[KeyboardToolsView.swift](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/KeyboardToolsView.swift "KeyboardToolsView.swift") | [KeyboardToolsView.swift](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/KeyboardToolsView.swift "KeyboardToolsView.swift") |  |   
[MainView.swift](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainView.swift "MainView.swift") | [MainView.swift](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainView.swift "MainView.swift") |  |   
[MainViewController.swift](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewController.swift "MainViewController.swift") | [MainViewController.swift](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewController.swift "MainViewController.swift") |  |   
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
{"url": "https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewController.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewController.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewCont
roller.swift         | ✓ | ⏱: 1.63s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewCont
roller.swift         | ✓ | ⏱: 0.07s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewCont
roller.swift         | ✓ | ⏱: 1.70s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewController.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FExample%2FMain%2FMainViewController.swift)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FExample%2FMain%2FMainViewController.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewController.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewController.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Example/Main/MainViewController.swift) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
      * Application
      * Assets.xcassets
      * Library
      * Main
        * Menu
        * KeyboardToolsView.swift
        * MainView.swift
        * MainViewController.swift
      * ThemePicker
      * Example.entitlements
      * Info.plist
    * Languages
    * Themes
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Example](https://github.com/simonbs/Runestone/tree/main/Example/Example)
  4. /[Main](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main)


/
# MainViewController.swift
Copy path
BlameMore file actions
BlameMore file actions
## Latest commit
[![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)](https://github.com/simonbs)[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[Checks compiler version](https://github.com/simonbs/Runestone/commit/bfe2032325deb22a03b528a78b6e42b7dae96584)
Feb 14, 2024
[bfe2032](https://github.com/simonbs/Runestone/commit/bfe2032325deb22a03b528a78b6e42b7dae96584) · Feb 14, 2024
## History
[History](https://github.com/simonbs/Runestone/commits/main/Example/Example/Main/MainViewController.swift)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Example/Example/Main/MainViewController.swift)History
210 lines (190 loc) · 7.49 KB
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Example](https://github.com/simonbs/Runestone/tree/main/Example/Example)
  4. /[Main](https://github.com/simonbs/Runestone/tree/main/Example/Example/Main)


/
# MainViewController.swift
Top
## File metadata and controls
  * Code
  * Blame


210 lines (190 loc) · 7.49 KB
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
[Raw](https://github.com/simonbs/Runestone/raw/refs/heads/main/Example/Example/Main/MainViewController.swift)
Copy raw file
Download raw file
Open symbols panel
Edit and raw actions
import Runestone import RunestoneJavaScriptLanguage import SwiftUI import UIKit final class MainViewController: UIViewController { override var textInputContextIdentifier: String? { // Returning a unique identifier makes iOS remember the user's selection of keyboard. "RunestoneExample.Main" } private let contentView = MainView() #if os(iOS) private let toolsView: KeyboardToolsView #endif init() { #if os(iOS) toolsView = KeyboardToolsView(textView: contentView.textView) #endif super.init(nibName: nil, bundle: nil) title = "Example" NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil ) NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil ) } required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") } override func loadView() { view = contentView } override func viewDidLoad() { super.viewDidLoad() if #available(iOS 16, *) { contentView.textView.isFindInteractionEnabled = true } #if os(iOS) contentView.textView.inputAccessoryView = toolsView #endif #if compiler(>=5.9) && os(visionOS) ornaments = [ UIHostingOrnament(sceneAnchor: .topTrailing, contentAlignment: .bottomTrailing) { HStack { SwiftUIMenuButton(selectionHandler: self) .glassBackgroundEffect() } .padding(.trailing) } ] #endif setupMenuButton() setupTextView() updateTextViewSettings() } } private extension MainViewController { @available(iOS 16, *) @objc private func presentFind() { contentView.textView.findInteraction?.presentFindNavigator(showingReplace: false) } @available(iOS 16, *) @objc private func presentFindAndReplace() { contentView.textView.findInteraction?.presentFindNavigator(showingReplace: true) } private func setupTextView() { var text = "" if !ProcessInfo.processInfo.disableTextPersistance, let persistedText = UserDefaults.standard.text { text = persistedText } let themeSetting = UserDefaults.standard.theme let theme = themeSetting.makeTheme() let state = TextViewState(text: text, theme: theme, language: .javaScript) if ProcessInfo.processInfo.useCRLFLineEndings { contentView.textView.lineEndings = .crlf } contentView.textView.editorDelegate = self contentView.textView.setState(state) } private func updateTextViewSettings() { let settings = UserDefaults.standard let theme = settings.theme.makeTheme() contentView.textView.applyTheme(theme) contentView.textView.applySettings(from: settings) } private func setupMenuButton() { let menuButton = MenuButton.makeConfigured(with: self) navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton) } private func presentGoToLineAlert() { let alertController = UIAlertController(title: "Go To Line", message: nil, preferredStyle: .alert) alertController.addTextField { textField in textField.placeholder = "42" textField.keyboardType = .numberPad } let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) let doneAction = UIAlertAction(title: "Go", style: .default) { [weak self, weak alertController] _ in if let textField = alertController?.textFields?.first, let text = textField.text, !text.isEmpty, let lineNumber = Int(text) { let lineIndex = lineNumber - 1 self?.contentView.textView.goToLine(lineIndex, select: .line) } } alertController.addAction(cancelAction) alertController.addAction(doneAction) present(alertController, animated: true) } private func presentThemePicker() { let theme = UserDefaults.standard.theme let themePickerViewController = ThemePickerViewController(selectedTheme: theme) themePickerViewController.delegate = self let navigationController = UINavigationController(rootViewController: themePickerViewController) present(navigationController, animated: true) } @objc private func keyboardWillHide(_ notification: Notification) { updateInsets(keyboardHeight: 0) } @objc private func keyboardWillChangeFrame(_ notification: Notification) { if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect { let keyboardHeight = max(frame.height - view.safeAreaInsets.bottom, 0) updateInsets(keyboardHeight: keyboardHeight) } } private func updateInsets(keyboardHeight: CGFloat) { contentView.textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0) contentView.textView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0) } } extension MainViewController: TextViewDelegate { func textViewDidChange(_ textView: TextView) { if !ProcessInfo.processInfo.disableTextPersistance { UserDefaults.standard.text = textView.text } } func textView(_ textView: TextView, canReplaceTextIn highlightedRange: HighlightedRange) -> Bool { true } } extension MainViewController: MenuSelectionHandler { // swiftlint:disable:next cyclomatic_complexity func handleSelection(of menuItem: MenuItem) { switch menuItem { case .presentFind: if #available(iOS 16, *) { presentFind() } case .presentFindAndReplace: if #available(iOS 16, *) { presentFindAndReplace() } case .presentGoToLine: presentGoToLineAlert() case .presentThemePicker: presentThemePicker() case .toggleEditable: UserDefaults.standard.isEditable.toggle() updateTextViewSettings() case .toggleInvisibleCharacters: UserDefaults.standard.showInvisibleCharacters.toggle() updateTextViewSettings() case .toggleHighlightSelectedLine: UserDefaults.standard.highlightSelectedLine.toggle() updateTextViewSettings() case .toggleLineNumbers: UserDefaults.standard.showLineNumbers.toggle() updateTextViewSettings() case .togglePageGuide: UserDefaults.standard.showPageGuide.toggle() updateTextViewSettings() case .toggleSelectable: UserDefaults.standard.isSelectable.toggle() updateTextViewSettings() case .toggleWrapLines: UserDefaults.standard.wrapLines.toggle() updateTextViewSettings() } } } extension MainViewController: ThemePickerViewControllerDelegate { func themePickerViewController(_ viewController: ThemePickerViewController, didPick theme: ThemeSetting) { UserDefaults.standard.theme = theme view.window?.overrideUserInterfaceStyle = theme.makeTheme().userInterfaceStyle updateTextViewSettings() } }
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
137
138
139
140
141
142
143
144
145
146
147
148
149
150
151
152
153
154
155
156
157
158
159
160
161
162
163
164
165
166
167
168
169
170
171
172
173
174
175
176
177
178
179
180
181
182
183
184
185
186
187
188
189
190
191
192
193
194
195
196
197
198
199
200
201
202
203
204
205
206
207
208
209
210
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


This is critical! I see a major difference. Let me look at how they set up the language package:

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Example/Languages", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Example/Languages

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone/tree/main/Example/Languages   
| ✓ | ⏱: 1.32s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone/tree/main/Example/Languages   
| ✓ | ⏱: 0.04s 
[COMPLETE] ● https://github.com/simonbs/Runestone/tree/main/Example/Languages   
| ✓ | ⏱: 1.35s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Example/Languages#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FLanguages)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FLanguages)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Languages) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Languages) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Languages) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
    * Languages
      * Sources
      * .gitignore
      * Package.swift
      * README.md
    * Themes
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)


/
# Languages
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
[Fixes superfluous compile error (](https://github.com/simonbs/Runestone/commit/d6d1a238c509e957a1f04d0b88a95f10530da38b)[#266](https://github.com/simonbs/Runestone/pull/266)[)](https://github.com/simonbs/Runestone/commit/d6d1a238c509e957a1f04d0b88a95f10530da38b)
Open commit details
Feb 6, 2023
[d6d1a23](https://github.com/simonbs/Runestone/commit/d6d1a238c509e957a1f04d0b88a95f10530da38b) · Feb 6, 2023
## History
[History](https://github.com/simonbs/Runestone/commits/main/Example/Languages)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Example/Languages)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)


/
# Languages
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Example)  
[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources "Sources") | [Sources](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources "Sources") |  |   
[.gitignore](https://github.com/simonbs/Runestone/blob/main/Example/Languages/.gitignore ".gitignore") | [.gitignore](https://github.com/simonbs/Runestone/blob/main/Example/Languages/.gitignore ".gitignore") |  |   
[Package.swift](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Package.swift "Package.swift") | [Package.swift](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Package.swift "Package.swift") |  |   
[README.md](https://github.com/simonbs/Runestone/blob/main/Example/Languages/README.md "README.md") | [README.md](https://github.com/simonbs/Runestone/blob/main/Example/Languages/README.md "README.md") |  |   
View all files  
## [README.md](https://github.com/simonbs/Runestone/tree/main/Example/Languages#readme)
# Languages
[](https://github.com/simonbs/Runestone/tree/main/Example/Languages#languages)
Contains the languages used by the example project. The package includes the JavaScript language.
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
{"url": "https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage+JavaScript.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage+JavaScript.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/E...riptLanguage/TreeSitterLangua
ge+JavaScript.swift  | ✓ | ⏱: 1.13s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/E...riptLanguage/TreeSitterLangua
ge+JavaScript.swift  | ✓ | ⏱: 0.03s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/E...riptLanguage/TreeSitterLangua
ge+JavaScript.swift  | ✓ | ⏱: 1.16s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage+JavaScript.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FLanguages%2FSources%2FRunestoneJavaScriptLanguage%2FTreeSitterLanguage%2BJavaScript.swift)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FLanguages%2FSources%2FRunestoneJavaScriptLanguage%2FTreeSitterLanguage%2BJavaScript.swift)
####  Sign in to GitHub 
Username or email address 
Password  [Forgot password?](https://github.com/password_reset)
[ or continue with other methods ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FLanguages%2FSources%2FRunestoneJavaScriptLanguage%2FTreeSitterLanguage%2BJavaScript.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage+JavaScript.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage+JavaScript.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage+JavaScript.swift) to refresh your session. Dismiss alert
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Languages](https://github.com/simonbs/Runestone/tree/main/Example/Languages)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources)
  5. /[RunestoneJavaScriptLanguage](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage)


/
# TreeSitterLanguage+JavaScript.swift
/
Copy path
404 - page not found
The 
main
branch of 
Runestone
does not contain the path 
Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage+JavaScript.swift.
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
{"url": "https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/Runesto
neJavaScriptLanguage | ✓ | ⏱: 1.20s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/Runesto
neJavaScriptLanguage | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/Runesto
neJavaScriptLanguage | ✓ | ⏱: 1.24s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FLanguages%2FSources%2FRunestoneJavaScriptLanguage)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FExample%2FLanguages%2FSources%2FRunestoneJavaScriptLanguage)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
    * Languages
      * Sources
        * RunestoneJavaScriptLanguage
          * IndentationScopes.swift
          * TreeSitterLanguage.swift
          * highlights.scm
          * injections.scm
        * TreeSitterJavaScript
      * .gitignore
      * Package.swift
      * README.md
    * Themes
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Languages](https://github.com/simonbs/Runestone/tree/main/Example/Languages)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources)


/
# RunestoneJavaScriptLanguage
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
[History](https://github.com/simonbs/Runestone/commits/main/Example/Languages/Sources/RunestoneJavaScriptLanguage)
[](https://github.com/simonbs/Runestone/commits/main/Example/Languages/Sources/RunestoneJavaScriptLanguage)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Languages](https://github.com/simonbs/Runestone/tree/main/Example/Languages)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources)


/
# RunestoneJavaScriptLanguage
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources)  
[IndentationScopes.swift](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/IndentationScopes.swift "IndentationScopes.swift") | [IndentationScopes.swift](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/IndentationScopes.swift "IndentationScopes.swift") |  |   
[TreeSitterLanguage.swift](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift "TreeSitterLanguage.swift") | [TreeSitterLanguage.swift](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift "TreeSitterLanguage.swift") |  |   
[highlights.scm](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm "highlights.scm") | [highlights.scm](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm "highlights.scm") |  |   
[injections.scm](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/injections.scm "injections.scm") | [injections.scm](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/injections.scm "injections.scm") |  |   
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
{"url": "https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/E...stoneJavaScriptLanguage/TreeS
itterLanguage.swift  | ✓ | ⏱: 1.32s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/E...stoneJavaScriptLanguage/TreeS
itterLanguage.swift  | ✓ | ⏱: 0.05s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/E...stoneJavaScriptLanguage/TreeS
itterLanguage.swift  | ✓ | ⏱: 1.38s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FLanguages%2FSources%2FRunestoneJavaScriptLanguage%2FTreeSitterLanguage.swift)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FLanguages%2FSources%2FRunestoneJavaScriptLanguage%2FTreeSitterLanguage.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
    * Languages
      * Sources
        * RunestoneJavaScriptLanguage
          * IndentationScopes.swift
          * TreeSitterLanguage.swift
          * highlights.scm
          * injections.scm
        * TreeSitterJavaScript
      * .gitignore
      * Package.swift
      * README.md
    * Themes
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Languages](https://github.com/simonbs/Runestone/tree/main/Example/Languages)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources)
  5. /[RunestoneJavaScriptLanguage](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage)


/
# TreeSitterLanguage.swift
Copy path
BlameMore file actions
BlameMore file actions
## Latest commit
[![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)](https://github.com/simonbs)[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[Fixes superfluous compile error (](https://github.com/simonbs/Runestone/commit/d6d1a238c509e957a1f04d0b88a95f10530da38b)[#266](https://github.com/simonbs/Runestone/pull/266)[)](https://github.com/simonbs/Runestone/commit/d6d1a238c509e957a1f04d0b88a95f10530da38b)
Open commit details
Feb 6, 2023
[d6d1a23](https://github.com/simonbs/Runestone/commit/d6d1a238c509e957a1f04d0b88a95f10530da38b) · Feb 6, 2023
## History
[History](https://github.com/simonbs/Runestone/commits/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift)History
22 lines (20 loc) · 936 Bytes
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Languages](https://github.com/simonbs/Runestone/tree/main/Example/Languages)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources)
  5. /[RunestoneJavaScriptLanguage](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage)


/
# TreeSitterLanguage.swift
Top
## File metadata and controls
  * Code
  * Blame


22 lines (20 loc) · 936 Bytes
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
[Raw](https://github.com/simonbs/Runestone/raw/refs/heads/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift)
Copy raw file
Download raw file
Open symbols panel
Edit and raw actions
import Foundation import Runestone import TreeSitterJavaScript public extension TreeSitterLanguage { static var javaScript: TreeSitterLanguage { let highlightsQueryURL = queryFileURL(forQueryNamed: "highlights") let injectionsQueryURL = queryFileURL(forQueryNamed: "injections") let highlightsQuery = TreeSitterLanguage.Query(contentsOf: highlightsQueryURL) let injectionsQuery = TreeSitterLanguage.Query(contentsOf: injectionsQueryURL) return TreeSitterLanguage(tree_sitter_javascript(), highlightsQuery: highlightsQuery, injectionsQuery: injectionsQuery, indentationScopes: .javaScript) } } private extension TreeSitterLanguage { static func queryFileURL(forQueryNamed queryName: String) -> URL { Bundle.module.url(forResource: queryName, withExtension: "scm")! } }
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
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


This is a CRITICAL finding! Let me look at their highlights.scm file:

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/E...urces/RunestoneJavaScriptLang
uage/highlights.scm  | ✓ | ⏱: 1.48s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/E...urces/RunestoneJavaScriptLang
uage/highlights.scm  | ✓ | ⏱: 0.06s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/E...urces/RunestoneJavaScriptLang
uage/highlights.scm  | ✓ | ⏱: 1.55s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FLanguages%2FSources%2FRunestoneJavaScriptLanguage%2Fhighlights.scm)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FExample%2FLanguages%2FSources%2FRunestoneJavaScriptLanguage%2Fhighlights.scm)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm) to refresh your session. Dismiss alert
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
    * Example.xcodeproj
    * Example
    * Languages
      * Sources
        * RunestoneJavaScriptLanguage
          * IndentationScopes.swift
          * TreeSitterLanguage.swift
          * highlights.scm
          * injections.scm
        * TreeSitterJavaScript
      * .gitignore
      * Package.swift
      * README.md
    * Themes
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
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Languages](https://github.com/simonbs/Runestone/tree/main/Example/Languages)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources)
  5. /[RunestoneJavaScriptLanguage](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage)


/
# highlights.scm
Copy path
BlameMore file actions
BlameMore file actions
## Latest commit
[![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)](https://github.com/simonbs)[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[Fixes superfluous compile error (](https://github.com/simonbs/Runestone/commit/d6d1a238c509e957a1f04d0b88a95f10530da38b)[#266](https://github.com/simonbs/Runestone/pull/266)[)](https://github.com/simonbs/Runestone/commit/d6d1a238c509e957a1f04d0b88a95f10530da38b)
Open commit details
Feb 6, 2023
[d6d1a23](https://github.com/simonbs/Runestone/commit/d6d1a238c509e957a1f04d0b88a95f10530da38b) · Feb 6, 2023
## History
[History](https://github.com/simonbs/Runestone/commits/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm)History
205 lines (175 loc) · 2.61 KB
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Example](https://github.com/simonbs/Runestone/tree/main/Example)
  3. /[Languages](https://github.com/simonbs/Runestone/tree/main/Example/Languages)
  4. /[Sources](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources)
  5. /[RunestoneJavaScriptLanguage](https://github.com/simonbs/Runestone/tree/main/Example/Languages/Sources/RunestoneJavaScriptLanguage)


/
# highlights.scm
Top
## File metadata and controls
  * Code
  * Blame


205 lines (175 loc) · 2.61 KB
· [](https://github.com/simonbs/Runestone/blob/main/CODEOWNERS#L1)
[Raw](https://github.com/simonbs/Runestone/raw/refs/heads/main/Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm)
Copy raw file
Download raw file
Open symbols panel
Edit and raw actions
; Special identifiers ;-------------------- ([ (identifier) (shorthand_property_identifier) (shorthand_property_identifier_pattern) ] @constant (#match? @constant "^[A-Z_][A-Z\\\d_]+$")) ((identifier) @constructor (#match? @constructor "^[A-Z]")) ((identifier) @variable.builtin (#match? @variable.builtin "^(arguments|module|console|window|document)$") (#is-not? local)) ((identifier) @function.builtin (#eq? @function.builtin "require") (#is-not? local)) ; Function and method definitions ;-------------------------------- (function name: (identifier) @function) (function_declaration name: (identifier) @function) (method_definition name: (property_identifier) @function.method) (pair key: (property_identifier) @function.method value: [(function) (arrow_function)]) (assignment_expression left: (member_expression property: (property_identifier) @function.method) right: [(function) (arrow_function)]) (variable_declarator name: (identifier) @function value: [(function) (arrow_function)]) (assignment_expression left: (identifier) @function right: [(function) (arrow_function)]) ; Function and method calls ;-------------------------- (call_expression function: (identifier) @function) (call_expression function: (member_expression property: (property_identifier) @function.method)) ; Variables ;---------- (identifier) @variable ; Properties ;----------- (property_identifier) @property ; Literals ;--------- (this) @variable.builtin (super) @variable.builtin [ (true) (false) (null) (undefined) ] @constant.builtin (comment) @comment [ (string) (template_string) ] @string (regex) @string.special (number) @number ; Tokens ;------- (template_substitution "${" @punctuation.special "}" @punctuation.special) @embedded [ ";" "?." "." "," ] @punctuation.delimiter [ "-" "--" "-=" "+" "++" "+=" "*" "*=" "**" "**=" "/" "/=" "%" "%=" "<" "<=" "<<" "<<=" "=" "==" "===" "!" "!=" "!==" "=>" ">" ">=" ">>" ">>=" ">>>" ">>>=" "~" "^" "&" "|" "^=" "&=" "|=" "&&" "||" "??" "&&=" "||=" "??=" ] @operator [ "(" ")" "[" "]" "{" "}" ] @punctuation.bracket [ "as" "async" "await" "break" "case" "catch" "class" "const" "continue" "debugger" "default" "delete" "do" "else" "export" "extends" "finally" "for" "from" "function" "get" "if" "import" "in" "instanceof" "let" "new" "of" "return" "set" "static" "switch" "target" "throw" "try" "typeof" "var" "void" "while" "with" "yield" ] @keyword
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
132
133
134
135
136
137
138
139
140
141
142
143
144
145
146
147
148
149
150
151
152
153
154
155
156
157
158
159
160
161
162
163
164
165
166
167
168
169
170
171
172
173
174
175
176
177
178
179
180
181
182
183
184
185
186
187
188
189
190
191
192
193
194
195
196
197
198
199
200
201
202
203
204
205
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


Now let me check the TreeSitter*Runestone packages we're using and see how they provide the TreeSitterLanguage:

>>>TOOL read_file
{"path": "VSCodeiPadOS/TreeSitterLanguages.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/TreeSitterLanguages.swift (lines 1-342 of 342)
────────────────────────────────────────
1: //
2: //  TreeSitterLanguages.swift
3: //  VSCodeiPadOS
4: //
5: //  Created on 2025-01-31.
6: //
7: 
8: import Foundation
9: 
10: // TODO: Uncomment these imports as TreeSitter Swift packages become available
11: // import TreeSitterSwift
12: // import TreeSitterJavaScript
13: // import TreeSitterTypeScript
14: // import TreeSitterPython
15: // import TreeSitterJSON
16: // import TreeSitterHTML
17: // import TreeSitterCSS
18: // import TreeSitterMarkdown
19: // import TreeSitterGo
20: // import TreeSitterRust
21: // import TreeSitterRuby
22: // import TreeSitterJava
23: // import TreeSitterC
24: // import TreeSitterCPP
25: // import TreeSitterBash
26: // import TreeSitterYAML
27: // import TreeSitterSQL
28: //
29: // TODO: Additional languages from the current implementation:
30: // import TreeSitterKotlin        // For kt, kts files
31: // import TreeSitterObjectiveC     // For m, mm files
32: // import TreeSitterSCSS           // For scss, sass files
33: // import TreeSitterLess           // For less files
34: // import TreeSitterXML            // For xml, plist, svg files
35: // import TreeSitterGraphQL        // For graphql, gql files
36: // import TreeSitterPHP            // For php files
37: 
38: /// Provides language modes for syntax highlighting based on file extensions.
39: /// This struct maps file extensions and special filenames to their appropriate
40: /// TreeSitter language modes for syntax highlighting.
41: public struct TreeSitterLanguages {
42:     
43:     /// Returns the appropriate language mode for a given filename.
44:     /// - Parameter filename: The filename (with or without path) to analyze
45:     /// - Returns: A LanguageMode instance for the detected language, or PlainTextLanguageMode() if unknown
46:     public static func languageMode(for filename: String) -> LanguageMode {
47:         let lower = filename.lowercased()
48:         let ext = (filename as NSString).pathExtension.lowercased()
49:         
50:         // Special-case filenames without extensions
51:         let lastComponent = (filename as NSString).lastPathComponent.lowercased()
52:         if lastComponent == "dockerfile" || lastComponent == "dockerfile.*" {
53:             // Dockerfile is typically bash-like, could use TreeSitterBash when available
54:             return bashLanguageMode() // or PlainTextLanguageMode()
55:         }
56:         if lastComponent == ".env" || lower.hasSuffix("/.env") {
57:             return PlainTextLanguageMode()
58:         }
59:         
60:         switch ext {
61:         // Swift
62:         case "swift":
63:             return swiftLanguageMode()
64:         
65:         // JavaScript
66:         case "js", "mjs", "cjs":
67:             return javaScriptLanguageMode()
68:         case "jsx":
69:             // JSX typically uses JavaScript grammar with JSX extensions
70:             return javaScriptLanguageMode()
71:         
72:         // TypeScript
73:         case "ts", "mts", "cts":
74:             return typeScriptLanguageMode()
75:         case "tsx":
76:             // TSX typically uses TypeScript grammar with JSX extensions
77:             return typeScriptLanguageMode()
78:         
79:         // Python
80:         case "py", "pyw":
81:             return pythonLanguageMode()
82:         
83:         // Ruby
84:         case "rb", "ruby":
85:             return rubyLanguageMode()
86:         
87:         // Go
88:         case "go":
89:             return goLanguageMode()
90:         
91:         // Rust
92:         case "rs":
93:             return rustLanguageMode()
94:         
95:         // Java
96:         case "java":
97:             return javaLanguageMode()
98:         
99:         // Kotlin (TODO: may not have Swift package yet)
100:         case "kt", "kts":
101:             return kotlinLanguageMode()
102:         
103:         // C
104:         case "c", "h":
105:             return cLanguageMode()
106:         
107:         // C++
108:         case "cpp", "cc", "cxx", "hpp", "hh", "hxx":
109:             return cppLanguageMode()
110:         
111:         // Objective-C (TODO: may not have Swift package yet)
112:         case "m", "mm":
113:             return objectiveCLanguageMode()
114:         
115:         // HTML
116:         case "html", "htm":
117:             return htmlLanguageMode()
118:         
119:         // CSS
120:         case "css":
121:             return cssLanguageMode()
122:         
123:         // SCSS/SASS (TODO: may not have Swift package yet)
124:         case "scss", "sass":
125:             return scssLanguageMode()
126:         
127:         // Less (TODO: may not have Swift package yet)
128:         case "less":
129:             return lessLanguageMode()
130:         
131:         // JSON
132:         case "json", "jsonc":
133:             return jsonLanguageMode()
134:         
135:         // XML (TODO: may not have Swift package yet)
136:         case "xml", "plist", "svg":
137:             return xmlLanguageMode()
138:         
139:         // YAML
140:         case "yml", "yaml":
141:             return yamlLanguageMode()
142:         
143:         // SQL
144:         case "sql":
145:             return sqlLanguageMode()
146:         
147:         // Shell scripts
148:         case "sh", "bash", "zsh", "fish":
149:             return bashLanguageMode()
150:         
151:         // Dockerfile (when it has an extension)
152:         case "dockerfile":
153:             return bashLanguageMode() // or PlainTextLanguageMode()
154:         
155:         // GraphQL (TODO: may not have Swift package yet)
156:         case "graphql", "gql":
157:             return graphqlLanguageMode()
158:         
159:         // Markdown
160:         case "md", "markdown":
161:             return markdownLanguageMode()
162:         
163:         // PHP (TODO: may not have Swift package yet)
164:         case "php":
165:             return phpLanguageMode()
166:         
167:         // Environment files
168:         case "env":
169:             return PlainTextLanguageMode()
170:         
171:         default:
172:             return PlainTextLanguageMode()
173:         }
174:     }
175:     
176:     // MARK: - Language Mode Factory Methods
177:     
178:     private static func swiftLanguageMode() -> LanguageMode {
179:         // TODO: Return TreeSitterSwift() when package is available
180:         // return TreeSitterSwift()
181:         return PlainTextLanguageMode()
182:     }
183:     
184:     private static func javaScriptLanguageMode() -> LanguageMode {
185:         // TODO: Return TreeSitterJavaScript() when package is available
186:         // return TreeSitterJavaScript()
187:         return PlainTextLanguageMode()
188:     }
189:     
190:     private static func typeScriptLanguageMode() -> LanguageMode {
191:         // TODO: Return TreeSitterTypeScript() when package is available
192:         // return TreeSitterTypeScript()
193:         return PlainTextLanguageMode()
194:     }
195:     
196:     private static func pythonLanguageMode() -> LanguageMode {
197:         // TODO: Return TreeSitterPython() when package is available
198:         // return TreeSitterPython()
199:         return PlainTextLanguageMode()
200:     }
201:     
202:     private static func jsonLanguageMode() -> LanguageMode {
203:         // TODO: Return TreeSitterJSON() when package is available
204:         // return TreeSitterJSON()
205:         return PlainTextLanguageMode()
206:     }
207:     
208:     private static func htmlLanguageMode() -> LanguageMode {
209:         // TODO: Return TreeSitterHTML() when package is available
210:         // return TreeSitterHTML()
211:         return PlainTextLanguageMode()
212:     }
213:     
214:     private static func cssLanguageMode() -> LanguageMode {
215:         // TODO: Return TreeSitterCSS() when package is available
216:         // return TreeSitterCSS()
217:         return PlainTextLanguageMode()
218:     }
219:     
220:     private static func markdownLanguageMode() -> LanguageMode {
221:         // TODO: Return TreeSitterMarkdown() when package is available
222:         // return TreeSitterMarkdown()
223:         return PlainTextLanguageMode()
224:     }
225:     
226:     private static func goLanguageMode() -> LanguageMode {
227:         // TODO: Return TreeSitterGo() when package is available
228:         // return TreeSitterGo()
229:         return PlainTextLanguageMode()
230:     }
231:     
232:     private static func rustLanguageMode() -> LanguageMode {
233:         // TODO: Return TreeSitterRust() when package is available
234:         // return TreeSitterRust()
235:         return PlainTextLanguageMode()
236:     }
237:     
238:     private static func rubyLanguageMode() -> LanguageMode {
239:         // TODO: Return TreeSitterRuby() when package is available
240:         // return TreeSitterRuby()
241:         return PlainTextLanguageMode()
242:     }
243:     
244:     private static func javaLanguageMode() -> LanguageMode {
245:         // TODO: Return TreeSitterJava() when package is available
246:         // return TreeSitterJava()
247:         return PlainTextLanguageMode()
248:     }
249:     
250:     private static func cLanguageMode() -> LanguageMode {
251:         // TODO: Return TreeSitterC() when package is available
252:         // return TreeSitterC()
253:         return PlainTextLanguageMode()
254:     }
255:     
256:     private static func cppLanguageMode() -> LanguageMode {
257:         // TODO: Return TreeSitterCPP() when package is available
258:         // return TreeSitterCPP()
259:         return PlainTextLanguageMode()
260:     }
261:     
262:     private static func bashLanguageMode() -> LanguageMode {
263:         // TODO: Return TreeSitterBash() when package is available
264:         // return TreeSitterBash()
265:         return PlainTextLanguageMode()
266:     }
267:     
268:     private static func yamlLanguageMode() -> LanguageMode {
269:         // TODO: Return TreeSitterYAML() when package is available
270:         // return TreeSitterYAML()
271:         return PlainTextLanguageMode()
272:     }
273:     
274:     private static func sqlLanguageMode() -> LanguageMode {
275:         // TODO: Return TreeSitterSQL() when package is available
276:         // return TreeSitterSQL()
277:         return PlainTextLanguageMode()
278:     }
279:     
280:     // MARK: - Additional Language Factory Methods
281:     
282:     private static func kotlinLanguageMode() -> LanguageMode {
283:         // TODO: Return TreeSitterKotlin() when package is available
284:         return PlainTextLanguageMode()
285:     }
286:     
287:     private static func objectiveCLanguageMode() -> LanguageMode {
288:         // TODO: Return TreeSitterObjectiveC() when package is available
289:         return PlainTextLanguageMode()
290:     }
291:     
292:     private static func scssLanguageMode() -> LanguageMode {
293:         // TODO: Return TreeSitterSCSS() when package is available
294:         return PlainTextLanguageMode()
295:     }
296:     
297:     private static func lessLanguageMode() -> LanguageMode {
298:         // TODO: Return TreeSitterLess() when package is available
299:         return PlainTextLanguageMode()
300:     }
301:     
302:     private static func xmlLanguageMode() -> LanguageMode {
303:         // TODO: Return TreeSitterXML() when package is available
304:         return PlainTextLanguageMode()
305:     }
306:     
307:     private static func graphqlLanguageMode() -> LanguageMode {
308:         // TODO: Return TreeSitterGraphQL() when package is available
309:         return PlainTextLanguageMode()
310:     }
311:     
312:     private static func phpLanguageMode() -> LanguageMode {
313:         // TODO: Return TreeSitterPHP() when package is available
314:         return PlainTextLanguageMode()
315:     }
316: }
317: 
318: // MARK: - LanguageMode Protocol
319: 
320: /// Protocol that all TreeSitter language modes must conform to.
321: /// This will be implemented by each TreeSitter language wrapper.
322: public protocol LanguageMode {
323:     /// The name of the language
324:     var name: String { get }
325:     
326:     /// The file extensions associated with this language
327:     var extensions: [String] { get }
328:     
329:     /// Create a new language mode instance
330:     init()
331: }
332: 
333: // MARK: - Plain Text Language Mode
334: 
335: /// Fallback language mode for files without specific syntax highlighting.
336: public struct PlainTextLanguageMode: LanguageMode {
337:     public let name = "Plain Text"
338:     public let extensions: [String] = []
339:     
340:     public init() {}
341: }
342: 


Now let me check what the TreeSitter*Runestone packages actually provide:

>>>TOOL web_search
{"query": "TreeSitterSwiftRunestone GitHub highlights.scm TreeSitterLanguage"}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "TreeSitterSwiftRunestone GitHub highlights.scm TreeSitterLanguage" (10 results):

1. **tree-sitter-python/queries/highlights.scm at master - GitHub**
   https://github.com/tree-sitter/tree-sitter-python/blob/master/queries/highlights.scm
   Python grammar for tree-sitter. Contribute to tree-sitter/tree-sitter-python development by creating an account on GitHub.

2. **Adding a Tree-sitter Language - Documentation**
   https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/
   The key files are covered previously in this article but they include src/parser.c, src/tree_sitter/parser.h and queries/highlights.scm. A Tree-sitter parser is exposed as a C function with the name tree_sitter_{language}, like tree_sitter_json or tree_sitter_javascript. You will need to add the C definition for this function to your project.

3. **Highlight - Tree-sitter**
   https://tree-sitter.github.io/tree-sitter/cli/highlight.html
   These should end in highlights.scm. --scope &lt;SCOPE&gt; The language scope to use for syntax highlighting. This is useful when the language is ambiguous. -t/--time Print the time taken to highlight the file. -q/--quiet Suppress main output. --paths &lt;PATHS_FILE&gt; The path to a file that contains paths to source files to highlight -p/--grammar-path &lt;PATH&gt;

4. **Highlighting source code with tree-sitter - Jeff Kreeftmeijer**
   https://jeffkreeftmeijer.com/tree-sitter-highlight/
   Warning: You have not configured any parser directories! Please run `tree-sitter init-config` and edit the resulting configuration file to indicate where we should look for language grammars. No language found for path `example.rb` If a language should be associated with this file extension, please ensure the path to `example.rb` is inside one of the following directories as specified by your ...

5. **Tree-sitter Syntax Highlighting. Syntax highlighting plays a crucial ...**
   https://medium.com/@linz07m/understanding-tree-sitter-syntax-highlighting-c44d40b9e1e0
   Tree-sitter offers a structured and extensible approach to syntax highlighting through its tree-sitter-highlight system, which is widely used, including on platforms like GitHub.

6. **syntax highlighting with tree-sitter - Tony Finch**
   https://dotat.at/@/2025-03-30-hilite.html
   Eventually I worked out that tree_sitter_javascript::HIGHLIGHT_QUERY in the tree-sitter-highlight example corresponds to the contents of a highlights.scm file. Each @name in highlights.scm is a highlight name that I might be interested in.

7. **tree-sitter/docs/section-4-syntax-highlighting.md at master**
   https://gitea.com/tree-sitter/tree-sitter/src/branch/master/docs/section-4-syntax-highlighting.md
   Tree-sitter has built-in support for syntax highlighting, via the tree-sitter-highlight library, which is currently used on GitHub.com for highlighting code written in several languages. You can also perform syntax highlighting at the command line using the tree-sitter highlight command.

8. **syntax highlighting with tree-sitter | Lobsters**
   https://lobste.rs/s/mk6n0l/syntax_highlighting_with_tree_sitter
   A highlights.scm file is coupled to a specific tree-sitter grammar, and defines highlight names for specific nodes in the syntax tree. The &quot;list of recognized highlight names&quot; passed to tree-sitter-highlight is a subset of the highlight names in the highlights.scm file, tailored to only the syntax you are interested in actually highlighting.

9. **tree-sitter-c-sharp/queries/highlights.scm at master - GitHub**
   https://github.com/tree-sitter/tree-sitter-c-sharp/blob/master/queries/highlights.scm
   C# Grammar for tree-sitter. Contribute to tree-sitter/tree-sitter-c-sharp development by creating an account on GitHub.

10. **Syntax Highlighting - Tree-sitter**
   https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html
   Syntax Highlighting Syntax highlighting is a very common feature in applications that deal with code. Tree-sitter has built-in support for syntax highlighting via the tree-sitter-highlight library, which is now used on GitHub.com for highlighting code written in several languages. You can also perform syntax highlighting at the command line using the tree-sitter highlight command. This ...


>>>TOOL web_fetch
{"url": "https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/   
| ✓ | ⏱: 0.57s 
[SCRAPE].. ◆ 
https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/   
| ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/   
| ✓ | ⏱: 0.57s 
[Skip Navigation](https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/#main)
Light
Dark
Auto


>>>TOOL web_search
{"query": "simonbs TreeSitterLanguageMode swift package language provider highlights"}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "simonbs TreeSitterLanguageMode swift package language provider highlights" (10 results):

1. **GitHub - simonbs/TreeSitterLanguages: Languages for Tree-sitter wrapped ...**
   https://github.com/simonbs/TreeSitterLanguages
   Usage The Swift package contains multiple libraries. Each language is wrapped in its own Swift package so you don&#x27;t need to import a whole suite of languages in case you only need a few. The package contains the following three libraries for each language.

2. **Examples and Tutorials | tree-sitter/swift-tree-sitter | DeepWiki**
   https://deepwiki.com/tree-sitter/swift-tree-sitter/5-examples-and-tutorials
   This page provides practical examples and step-by-step tutorials demonstrating how to use both SwiftTreeSitter and SwiftTreeSitterLayer APIs. The examples progress from basic parsing operations to advanced multi-language document processing scenarios.

3. **SwiftTreeSitter - Swift Package Registry**
   https://swiftpackageregistry.com/tree-sitter/swift-tree-sitter
   SwiftTreeSitter Swift API for the tree-sitter incremental parsing system. Close to full coverage of the C API Swift/Foundation types where possible Standard query result mapping for highlights and injections Query predicate/directive support via ResolvingQueryMatchSequence Nested language support Swift concurrency support where possible

4. **Adding a Tree-sitter Language - Documentation**
   https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/
   Using the TreeSitterLanguages Swift Package The easiest way to add a Tree-sitter parser to your project is by adding the TreeSitterLanguages Swift package. The package is used by the Runestone Text Editor app and as such contains all languages supported by Runestone Text Editor. TreeSitterLanguages contain three Swift packages for each language.

5. **Packages by Simon B. Støvring - Swift Package Index**
   https://swiftpackageindex.com/simonbs
   The Swift Package Index is indexing 7 packages authored by Simon B. Støvring.

6. **TreeSitterLanguages/README.md at main · simonbs ... - GitHub**
   https://github.com/simonbs/TreeSitterLanguages/blob/main/README.md
   Languages for Tree-sitter wrapped in Swift packages - TreeSitterLanguages/README.md at main · simonbs/TreeSitterLanguages

7. **Syntax Highlighting - Tree-sitter**
   https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html
   Syntax Highlighting Syntax highlighting is a very common feature in applications that deal with code. Tree-sitter has built-in support for syntax highlighting via the tree-sitter-highlight library, which is now used on GitHub.com for highlighting code written in several languages. You can also perform syntax highlighting at the command line using the tree-sitter highlight command. This ...

8. **Package | Apple Developer Documentation**
   https://developer.apple.com/documentation/packagedescription/package
   In Swift tools versions earlier than 5.4, the package manifest must begin with the string // swift-tools-version: followed by a version number specifier. Version 5.4 and later has relaxed the whitespace requirements.

9. **TreeSitter - Swift Package Index**
   https://swiftpackageindex.com/simonbs/tree-sitter
   TreeSitter by Simon B. Støvring on the Swift Package Index - An incremental parsing system for programming tools

10. **GitHub - alex-pinkus/tree-sitter-swift: A tree-sitter grammar for the ...**
   https://github.com/alex-pinkus/tree-sitter-swift
   To use this parser to parse Swift code, you&#x27;ll want to depend on either the Rust crate or the NPM package. To use tree-sitter-swift as a language for the web bindings version tree-sitter, which will likely be a more modern version than the published node module. see. Follow the instructions below ...


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/TreeSitterLanguages", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/TreeSitterLanguages

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/TreeSitterLanguages                     
| ✓ | ⏱: 1.23s 
[SCRAPE].. ◆ https://github.com/simonbs/TreeSitterLanguages                     
| ✓ | ⏱: 0.04s 
[COMPLETE] ● https://github.com/simonbs/TreeSitterLanguages                     
| ✓ | ⏱: 1.27s 
[Skip to content](https://github.com/simonbs/TreeSitterLanguages#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&source=header-repo&source_repo=simonbs%2FTreeSitterLanguages)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages) ** Public
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages) You must be signed in to change notification settings
  * [ 27 ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages)
  * [ Star  67 ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages)


Languages for Tree-sitter wrapped in Swift packages 
### License
[ ](https://github.com/simonbs/TreeSitterLanguages/blob/main/LICENSE)
[ 67 stars ](https://github.com/simonbs/TreeSitterLanguages/stargazers) [ 27 forks ](https://github.com/simonbs/TreeSitterLanguages/forks) [ Branches ](https://github.com/simonbs/TreeSitterLanguages/branches) [ Tags ](https://github.com/simonbs/TreeSitterLanguages/tags) [ Activity ](https://github.com/simonbs/TreeSitterLanguages/activity)
[ Star  ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages)
[ ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages) You must be signed in to change notification settings
  * [ Code ](https://github.com/simonbs/TreeSitterLanguages)
  * [ Pull requests 3 ](https://github.com/simonbs/TreeSitterLanguages/pulls)
  * [ Actions ](https://github.com/simonbs/TreeSitterLanguages/actions)
  * [ Security 0 ](https://github.com/simonbs/TreeSitterLanguages/security)
  * [ Insights ](https://github.com/simonbs/TreeSitterLanguages/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/TreeSitterLanguages)
  * [ Pull requests  ](https://github.com/simonbs/TreeSitterLanguages/pulls)
  * [ Actions  ](https://github.com/simonbs/TreeSitterLanguages/actions)
  * [ Security  ](https://github.com/simonbs/TreeSitterLanguages/security)
  * [ Insights  ](https://github.com/simonbs/TreeSitterLanguages/pulse)


# simonbs/TreeSitterLanguages
main
[Branches](https://github.com/simonbs/TreeSitterLanguages/branches)[Tags](https://github.com/simonbs/TreeSitterLanguages/tags)
[](https://github.com/simonbs/TreeSitterLanguages/branches)[](https://github.com/simonbs/TreeSitterLanguages/tags)
Go to file
Code
Open more actions menu
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
## Latest commit
## History
[83 Commits](https://github.com/simonbs/TreeSitterLanguages/commits/main/) [](https://github.com/simonbs/TreeSitterLanguages/commits/main/)83 Commits  
[.github/workflows](https://github.com/simonbs/TreeSitterLanguages/tree/main/.github/workflows "This path skips through empty directories") | [.github/workflows](https://github.com/simonbs/TreeSitterLanguages/tree/main/.github/workflows "This path skips through empty directories") |  |   
[Sources](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources "Sources") | [Sources](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources "Sources") |  |   
[.gitignore](https://github.com/simonbs/TreeSitterLanguages/blob/main/.gitignore ".gitignore") | [.gitignore](https://github.com/simonbs/TreeSitterLanguages/blob/main/.gitignore ".gitignore") |  |   
[LICENSE](https://github.com/simonbs/TreeSitterLanguages/blob/main/LICENSE "LICENSE") | [LICENSE](https://github.com/simonbs/TreeSitterLanguages/blob/main/LICENSE "LICENSE") |  |   
[Package.resolved](https://github.com/simonbs/TreeSitterLanguages/blob/main/Package.resolved "Package.resolved") | [Package.resolved](https://github.com/simonbs/TreeSitterLanguages/blob/main/Package.resolved "Package.resolved") |  |   
[Package.swift](https://github.com/simonbs/TreeSitterLanguages/blob/main/Package.swift "Package.swift") | [Package.swift](https://github.com/simonbs/TreeSitterLanguages/blob/main/Package.swift "Package.swift") |  |   
[README.md](https://github.com/simonbs/TreeSitterLanguages/blob/main/README.md "README.md") | [README.md](https://github.com/simonbs/TreeSitterLanguages/blob/main/README.md "README.md") |  |   
View all files  
## Repository files navigation
  * [README](https://github.com/simonbs/TreeSitterLanguages#)
  * [MIT license](https://github.com/simonbs/TreeSitterLanguages#)


# TreeSitterLanguages
[](https://github.com/simonbs/TreeSitterLanguages#treesitterlanguages)
Languages for the [Tree-sitter](https://tree-sitter.github.io/tree-sitter/) parser generator wrapped in Swift packages.
## Motivation
[](https://github.com/simonbs/TreeSitterLanguages#motivation)
There are two reasons this package exists:
  1. As an easy way to add several Tree-sitter languages to an app and particularly to an app that uses the [Runestone](https://github.com/simonbs/runestone) framework.
  2. To show how a Tree-sitter language can be wrapped in a Swift package.


It is not recommended to use this package if you only need to add a few Tree-sitter languages to your app. Instead you should add the languages manually.
## Installation
[](https://github.com/simonbs/TreeSitterLanguages#installation)
The languages are distributed using the [Swift Package Manager](https://www.swift.org/package-manager/) as separated libraries in a single Swift package. Install the package in your project by adding it as a dependency in your Package.swift manifest or through "Package Dependencies" in your project settings.
```
let package = Package(
    dependencies: [
        .package(url: "git@github.com:simonbs/TreeSitterLanguages.git", from: "0.1.0")
    ]
)
```

## Usage
[](https://github.com/simonbs/TreeSitterLanguages#usage)
The Swift package contains multiple libraries. Each language is wrapped in its own Swift package so you don't need to import a whole suite of languages in case you only need a few.
The package contains the following three libraries for each language.
Name | Purpose  
---|---  
TreeSitter{Language} | The C code for the generated Tree-sitter parser. Each package exposes a function named like `tree_sitter_{language}`.  
TreeSitter{Language}Queries | The queries to be used with the language. For more information on queries, please refer to [Tree-sitter's documentation](https://tree-sitter.github.io/tree-sitter/syntax-highlighting#queries). The only reason this is a separate library and not part of the TreeSitter{Language} library is that C code and Swift code cannot be mixed in a library using Swift Package Manager.  
TreeSitter{Language}Runestone | Exposes the language to be used with [Runestone](https://github.com/simonbs/runestone). This library depends on the TreeSitter{Language} and TreeSitter{Language}Queries libraries and it is the only library you need to import when using Runestone. The library exposes the language as an extension on [TreeSitterLanguage](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Language/TreeSitter/TreeSitterLanguage.swift) (e.g. `TreeSitterLanguage.javaScript`) that's ready to be used in Runestone. It also includes the indentation specification for select languages.  
Furthermore the package contains the TreeSitterLanguagesCommon library which exposes base types from Tree-sitter like `TSLanguage`. This is useful when you need to refer to these types in your source code, for example if you return a `TSLanguage` from a function.
## Compatibility
[](https://github.com/simonbs/TreeSitterLanguages#compatibility)
The parser.c file of a language is generated using [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/cli/README.md) and a language generated with one version of the CLI may not be compatible with future versions of Tree-sitter. All languages in this repository are kept compatible with the version of Tree-sitter used by my [Runestone](https://github.com/simonbs/runestone) framework.
## Acknowledgements
[](https://github.com/simonbs/TreeSitterLanguages#acknowledgements)
The TreeSitterLanguages repository contains files copied from the following repositories. I had originally added these repositories as submodules but it turned out to be very impractical when the package is used with Swift Package Manager because checking out the repository and all the submodules would take a long time and doing so on a slow connection (for example when commuting) would be unbearable.
Thanks to all the contributors to these repositories for their great effort in ensuring Tree-sitter supports a wide array of languages.
  * [tree-sitter-astro](https://github.com/virchau13/tree-sitter-astro)
  * [tree-sitter-bash](https://github.com/tree-sitter/tree-sitter-bash)
  * [tree-sitter-c](https://github.com/tree-sitter/tree-sitter-c)
  * [tree-sitter-comment](https://github.com/stsewd/tree-sitter-comment)
  * [tree-sitter-c-sharp](https://github.com/tree-sitter/tree-sitter-c-sharp)
  * [tree-sitter-cpp](https://github.com/tree-sitter/tree-sitter-cpp)
  * [tree-sitter-css](https://github.com/tree-sitter/tree-sitter-css)
  * [tree-sitter-elixir](https://github.com/elixir-lang/tree-sitter-elixir)
  * [tree-sitter-elm](https://github.com/elm-tooling/tree-sitter-elm)
  * [tree-sitter-go](https://github.com/tree-sitter/tree-sitter-go)
  * [tree-sitter-haskell](https://github.com/tree-sitter/tree-sitter-haskell)
  * [tree-sitter-html](https://github.com/tree-sitter/tree-sitter-html)
  * [tree-sitter-java](https://github.com/tree-sitter/tree-sitter-java)
  * [tree-sitter-javascript](https://github.com/tree-sitter/tree-sitter-javascript)
  * [tree-sitter-jsdoc](https://github.com/tree-sitter/tree-sitter-jsdoc)
  * [tree-sitter-json](https://github.com/tree-sitter/tree-sitter-json)
  * [tree-sitter-json5](https://github.com/Joakker/tree-sitter-json5)
  * [tree-sitter-julia](https://github.com/tree-sitter/tree-sitter-julia)
  * [tree-sitter-latex](https://github.com/latex-lsp/tree-sitter-latex)
  * [tree-sitter-lua](https://github.com/tjdevries/tree-sitter-lua)
  * [tree-sitter-markdown](https://github.com/MDeiml/tree-sitter-markdown)
  * [tree-sitter-ocaml](https://github.com/tree-sitter/tree-sitter-ocaml)
  * [tree-sitter-perl](https://github.com/ganezdragon/tree-sitter-perl)
  * [tree-sitter-php](https://github.com/tree-sitter/tree-sitter-php)
  * [tree-sitter-python](https://github.com/tree-sitter/tree-sitter-python)
  * [tree-sitter-r](https://github.com/r-lib/tree-sitter-r)
  * [tree-sitter-regex](https://github.com/tree-sitter/tree-sitter-regex)
  * [tree-sitter-ruby](https://github.com/tree-sitter/tree-sitter-ruby)
  * [tree-sitter-rust](https://github.com/tree-sitter/tree-sitter-rust)
  * [tree-sitter-scss](https://github.com/serenadeai/tree-sitter-scss)
  * [tree-sitter-sql](https://github.com/DerekStride/tree-sitter-sql)
  * [tree-sitter-svelte](https://github.com/Himujjal/tree-sitter-svelte)
  * [tree-sitter-swift](https://github.com/alex-pinkus/tree-sitter-swift)
  * [tree-sitter-toml](https://github.com/ikatyang/tree-sitter-toml)
  * [tree-sitter-typescript](https://github.com/tree-sitter/tree-sitter-typescript)
  * [tree-sitter-yaml](https://github.com/ikatyang/tree-sitter-yaml)
  * [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)


## About
Languages for Tree-sitter wrapped in Swift packages 
### Resources
[ ](https://github.com/simonbs/TreeSitterLanguages#readme-ov-file)
### License
[ ](https://github.com/simonbs/TreeSitterLanguages#MIT-1-ov-file)
###  Uh oh! 
There was an error while loading. [Please reload this page](https://github.com/simonbs/TreeSitterLanguages).
[Activity](https://github.com/simonbs/TreeSitterLanguages/activity)
### Stars
[**67** stars](https://github.com/simonbs/TreeSitterLanguages/stargazers)
### Watchers
[**3** watching](https://github.com/simonbs/TreeSitterLanguages/watchers)
### Forks
[**27** forks](https://github.com/simonbs/TreeSitterLanguages/forks)
[ Report repository ](https://github.com/contact/report-content?content_url=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages&report=simonbs+%28user%29)
##  [Releases 11](https://github.com/simonbs/TreeSitterLanguages/releases)
[ 0.1.10 Latest  Feb 14, 2024 ](https://github.com/simonbs/TreeSitterLanguages/releases/tag/0.1.10)
[+ 10 releases](https://github.com/simonbs/TreeSitterLanguages/releases)
##  [Packages 0](https://github.com/users/simonbs/packages?repo_name=TreeSitterLanguages)
No packages published   

###  Uh oh! 
There was an error while loading. [Please reload this page](https://github.com/simonbs/TreeSitterLanguages).
##  [Contributors 4](https://github.com/simonbs/TreeSitterLanguages/graphs/contributors)
###  Uh oh! 
There was an error while loading. [Please reload this page](https://github.com/simonbs/TreeSitterLanguages).
## Languages
  * [ C 99.9% ](https://github.com/simonbs/TreeSitterLanguages/search?l=c)
  * Other 0.1%


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


Now I have enough information to write a comprehensive comparison report.

>>>REPORT
## Runestone Example App Analysis - Comparison with Our Implementation

### Files Examined:
1. **Our implementation:** `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift` (lines 1-741)
2. **Official Example:** 
   - `Example/Example/Main/MainViewController.swift` (setup)
   - `Example/Themes/Sources/RunestoneOneDarkTheme/OneDarkTheme.swift` (theme)
   - `Example/Themes/Sources/RunestoneThemeCommon/HighlightName.swift` (highlight mapping)
   - `Example/Languages/Sources/RunestoneJavaScriptLanguage/TreeSitterLanguage.swift` (custom language)
   - `Example/Languages/Sources/RunestoneJavaScriptLanguage/highlights.scm` (205 lines of custom queries)

### CRITICAL DIFFERENCES FOUND:

#### 1. **Language Setup - MAJOR DIFFERENCE**

**Official Example creates CUSTOM language definitions:**
```swift
// Example/Languages/.../TreeSitterLanguage.swift
public extension TreeSitterLanguage {
    static var javaScript: TreeSitterLanguage {
        let highlightsQueryURL = queryFileURL(forQueryNamed: "highlights")
        let injectionsQueryURL = queryFileURL(forQueryNamed: "injections")
        let highlightsQuery = TreeSitterLanguage.Query(contentsOf: highlightsQueryURL)
        let injectionsQuery = TreeSitterLanguage.Query(contentsOf: injectionsQueryURL)
        return TreeSitterLanguage(tree_sitter_javascript(), 
            highlightsQuery: highlightsQuery, 
            injectionsQuery: injectionsQuery, 
            indentationScopes: .javaScript)
    }
}
```

**Our implementation uses pre-packaged languages:**
```swift
// RunestoneEditorView.swift line 258
return TreeSitterLanguage.swift
return TreeSitterLanguage.javaScript
```

We rely on `TreeSitter*Runestone` packages (from `simonbs/TreeSitterLanguages`) which bundle the highlights.scm queries. This SHOULD work correctly.

#### 2. **Highlight Name Mapping - SIGNIFICANT DIFFERENCE**

**Official Example uses clean enum-based parsing:**
```swift
// HighlightName.swift
public enum HighlightName: String {
    case comment
    case function
    case keyword
    case number
    case `operator`
    case property
    case punctuation
    case string
    case variableBuiltin = "variable.builtin"
    
    public init?(_ rawHighlightName: String) {
        // Progressively removes suffixes until match found
        var comps = rawHighlightName.split(separator: ".")
        while !comps.isEmpty {
            let candidate = comps.joined(separator: ".")
            if let highlightName = Self(rawValue: candidate) {
                self = highlightName
                return
            }
            comps.removeLast()
        }
        return nil  // Unrecognized
    }
}
```

**Our implementation uses substring matching (lines 586-686):**
```swift
func textColor(for rawHighlightName: String) -> UIColor? {
    let highlightName = rawHighlightName.lowercased()
    
    if highlightName.contains("keyword") { return _keywordColor }
    if highlightName.hasPrefix("string.special") { return _variableColor }
    if highlightName.contains("string") { return _stringColor }
    // ... more .contains() checks
}
```

**Issues with our approach:**
- More highlight names supported but more error-prone
- Order-dependent matching could cause wrong colors
- No debug logging for unrecognized names (official logs them in DEBUG)

#### 3. **Theme Protocol Implementation - MINOR DIFFERENCE**

**Official Example** handles only 8 highlight types:
- comment, operator, punctuation, property, function, string, number, keyword, variableBuiltin

**Our Implementation** handles 15+ highlight types (more comprehensive but potentially over-complicated)

#### 4. **TextViewState Initialization**

**Official Example:**
```swift
let state = TextViewState(text: text, theme: theme, language: .javaScript)
textView.setState(state)
```

**Our Implementation (line 110-112):**
```swift
textView.theme = makeRunestoneTheme()  // Set theme first
let state = TextViewState(text: text, language: language)  // No theme in state
textView.setState(state)
```

Both approaches should work, but the official one passes theme with the state.

### RECOMMENDATIONS:

1. **Add Debug Logging** - Uncomment line 590 to see what highlight names are actually being received:
   ```swift
   print("🎨 HIGHLIGHT: '\(rawHighlightName)'")
   ```

2. **Simplify Highlight Mapping** - Consider adopting the official enum-based approach for cleaner, more maintainable code

3. **Verify TreeSitter*Runestone Packages** - The pre-packaged languages from `simonbs/TreeSitterLanguages` should include proper highlights.scm queries. If syntax highlighting isn't working, check:
   - Are the packages imported correctly? (lines 12-19 show imports)
   - Are queries being loaded? (no way to verify without runtime debug)

4. **The official Example uses CUSTOM highlights.scm files** (205 lines for JavaScript) which may have better query coverage than the packaged defaults.

### KEY INSIGHT:
The TreeSitter*Runestone packages we use SHOULD work out-of-the-box. If syntax highlighting isn't appearing, the issue is likely in:
1. The theme's `textColor(for:)` method not matching the highlight names produced
2. The TextViewState/setState flow
3. Enable the debug print to see what highlight names are actually being sent to the theme

The DerivedData search was not possible as the path doesn't exist on this machine.
>>>END
