# Agent: tab-autocomplete-investigator
**Status:** done
**Tokens:** 5,933
**Cost:** $0.0000
**Time:** 2026-02-10T12:55:14.779Z

## Task
Investigate Tab autocomplete crash in VSCodeiPadOS. Trace the FULL flow: 1) handleTab() in SyntaxHighlightingTextView 2) onAcceptAutocomplete callback 3) AutocompleteManager.commitCurrentSuggestion 4) Text insertion logic. Look for: race conditions, nil force unwraps, index out of bounds, state inconsistencies. A bounds check was added - verify it's sufficient. Report ALL remaining crash risks with line numbers.

## Response
I'll investigate the Tab autocomplete crash by tracing the full flow. Let me start by finding the relevant files.

>>>TOOL search
{"query": "handleTab", "glob": "*.swift"}
>>>END

Let me search for the SyntaxHighlightingTextView and autocomplete-related code.

>>>TOOL search
{"query": "SyntaxHighlightingTextView", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "SyntaxHighlightingTextView"


Let me list the directory structure to understand the codebase layout.

>>>TOOL list_dir
{"path": "."}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 ./
📁 .claude/
📁 .claudefluff/
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


>>>TOOL list_dir
{"path": "Views"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/
📁 Editor/
📁 Panels/


>>>TOOL list_dir
{"path": "Views/Editor"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/Editor/
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
(cached)


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/
📁 Editor/
📁 Panels/
   _tmp.txt
   BranchMenu.swift
   CommandPalette.swift
   CommandPaletteView.swift
   DiffComponents.swift
   FileIconView.swift
   FileTreeView.swift
   GoToSymbol.swift
   LaunchConfigView.swift
   QuickOpen.swift
   RunConfigView.swift
   SidebarView.swift
   SnippetPickerView.swift
   StatusBarView.swift
   TabBarView.swift
   TasksView.swift
   WorkspaceSettingsView.swift
   WorkspaceTrustDialog.swift


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
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
⚠️ File too large (97160 chars, 2151 lines). Showing first 100 lines.
Use start_line/end_line to read specific sections.

File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
────────────────────────────────────────
1: //
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

... [truncated - 2051 more lines]


>>>TOOL get_symbols
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[get_symbols]
No symbols found in VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (file may need to be opened first)


>>>TOOL search
{"query": "Tab autocomplete", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "Tab autocomplete"


>>>TOOL search
{"query": "onAcceptAutocomplete", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "onAcceptAutocomplete"


>>>TOOL search
{"query": "autocomplete", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "autocomplete"


>>>TOOL search
{"query": "Autocomplete", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "Autocomplete"


>>>TOOL search
{"query": "AutocompleteManager", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "AutocompleteManager"


>>>TOOL search
{"query": "commitCurrentSuggestion", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "commitCurrentSuggestion"


>>>TOOL search
{"query": "onAcceptAutocomplete", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "onAcceptAutocomplete"


Let me read the SyntaxHighlightingTextView file to find the Tab key handling and autocomplete callback logic.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 25, "end_line": 75}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 26-75 of 2151)
────────────────────────────────────────
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


>>>TOOL search
{"query": "func pressesBegan", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "func pressesBegan"


>>>TOOL search
{"query": "UIKeyCommand", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "UIKeyCommand"


>>>TOOL search
{"query": "Tab", "glob": "*SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "Tab"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-300 of 2151)
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
115:         let textView = EditorTextView()
116:         textView.delegate = context.coordinator
117:         textView.editorCore = editorCore
118: 
119:         // Autocomplete hooks
120:         textView.onAcceptAutocomplete = onAcceptAutocomplete
121:         textView.onDismissAutocomplete = onDismissAutocomplete
122: 
123:         textView.onPeekDefinition = {
124:             context.coordinator.handlePeekDefinition(in: textView)
125:         }
126: 
127:         textView.onEscape = {
128:             context.coordinator.handleEscape()
129:         }
130: 
131:         textView.onGoToLine = {
132:             self.editorCore.showGoToLine = true
133:         }
134:         
135:         // Wire up custom context menu actions
136:         textView.onGoToDefinition = {
137:             context.coordinator.handleGoToDefinition(in: textView)
138:         }
139:         
140:         textView.onFindReferences = {
141:             context.coordinator.handleFindReferences(in: textView)
142:         }
143:         
144:         textView.onFormatDocument = {
145:             context.coordinator.handleFormatDocument(in: textView)
146:         }
147:         
148:         textView.onToggleComment = {
149:             context.coordinator.handleToggleComment(in: textView)
150:         }
151:         
152:         textView.onFold = {
153:             context.coordinator.handleFold(in: textView)
154:         }
155:         
156:         textView.onUnfold = {
157:             context.coordinator.handleUnfold(in: textView)
158:         }
159:         
160:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
161:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
162:         pinchGesture.delegate = context.coordinator
163:         textView.addGestureRecognizer(pinchGesture)
164:         context.coordinator.pinchGesture = pinchGesture
165:         
166:         // Configure text view
167:         textView.isEditable = true
168:         textView.isSelectable = true
169:         textView.autocapitalizationType = .none
170:         textView.autocorrectionType = .no
171:         textView.smartDashesType = .no
172:         textView.smartQuotesType = .no
173:         textView.smartInsertDeleteType = .no
174:         textView.spellCheckingType = .no
175:         
176:         // Set font and appearance (use editorCore.editorFontSize)
177:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
178:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
179:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
180:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
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
271:             DispatchQueue.main.async {
272:                 self.requestedLineSelection = nil
273:             }
274:         }
275: 
276:         // Handle cursor index requests (e.g. accepting autocomplete)
277:         if let requested = requestedCursorIndex,
278:            requested != context.coordinator.lastRequestedCursorIndex {
279:             context.coordinator.lastRequestedCursorIndex = requested
280:             // Use UTF-16 count for NSRange compatibility
281:             let textLength = (textView.text as NSString?)?.length ?? 0
282:             let safeIndex = max(0, min(requested, textLength))
283:             textView.selectedRange = NSRange(location: safeIndex, length: 0)
284:             
285:             // Ensure cursor is visible by scrolling to it
286:             textView.scrollRangeToVisible(textView.selectedRange)
287:             
288:             // Defer @Binding update to avoid "Publishing changes from within view updates"
289:             DispatchQueue.main.async {
290:                 self.requestedCursorIndex = nil
291:             }
292: 
293:             // Update SwiftUI state
294:             context.coordinator.updateCursorPosition(textView)
295:             context.coordinator.updateScrollPosition(textView)
296:         }
297:         
298:         // Note: updateLineCount is called in textViewDidChange, no need to call here
299:         // as it causes unnecessary state churn on every updateUIView
300:     }


>>>TOOL search
{"query": "class EditorTextView", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class EditorTextView"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-300 of 2151)
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
115:         let textView = EditorTextView()
116:         textView.delegate = context.coordinator
117:         textView.editorCore = editorCore
118: 
119:         // Autocomplete hooks
120:         textView.onAcceptAutocomplete = onAcceptAutocomplete
121:         textView.onDismissAutocomplete = onDismissAutocomplete
122: 
123:         textView.onPeekDefinition = {
124:             context.coordinator.handlePeekDefinition(in: textView)
125:         }
126: 
127:         textView.onEscape = {
128:             context.coordinator.handleEscape()
129:         }
130: 
131:         textView.onGoToLine = {
132:             self.editorCore.showGoToLine = true
133:         }
134:         
135:         // Wire up custom context menu actions
136:         textView.onGoToDefinition = {
137:             context.coordinator.handleGoToDefinition(in: textView)
138:         }
139:         
140:         textView.onFindReferences = {
141:             context.coordinator.handleFindReferences(in: textView)
142:         }
143:         
144:         textView.onFormatDocument = {
145:             context.coordinator.handleFormatDocument(in: textView)
146:         }
147:         
148:         textView.onToggleComment = {
149:             context.coordinator.handleToggleComment(in: textView)
150:         }
151:         
152:         textView.onFold = {
153:             context.coordinator.handleFold(in: textView)
154:         }
155:         
156:         textView.onUnfold = {
157:             context.coordinator.handleUnfold(in: textView)
158:         }
159:         
160:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
161:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
162:         pinchGesture.delegate = context.coordinator
163:         textView.addGestureRecognizer(pinchGesture)
164:         context.coordinator.pinchGesture = pinchGesture
165:         
166:         // Configure text view
167:         textView.isEditable = true
168:         textView.isSelectable = true
169:         textView.autocapitalizationType = .none
170:         textView.autocorrectionType = .no
171:         textView.smartDashesType = .no
172:         textView.smartQuotesType = .no
173:         textView.smartInsertDeleteType = .no
174:         textView.spellCheckingType = .no
175:         
176:         // Set font and appearance (use editorCore.editorFontSize)
177:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
178:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
179:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
180:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
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
271:             DispatchQueue.main.async {
272:                 self.requestedLineSelection = nil
273:             }
274:         }
275: 
276:         // Handle cursor index requests (e.g. accepting autocomplete)
277:         if let requested = requestedCursorIndex,
278:            requested != context.coordinator.lastRequestedCursorIndex {
279:             context.coordinator.lastRequestedCursorIndex = requested
280:             // Use UTF-16 count for NSRange compatibility
281:             let textLength = (textView.text as NSString?)?.length ?? 0
282:             let safeIndex = max(0, min(requested, textLength))
283:             textView.selectedRange = NSRange(location: safeIndex, length: 0)
284:             
285:             // Ensure cursor is visible by scrolling to it
286:             textView.scrollRangeToVisible(textView.selectedRange)
287:             
288:             // Defer @Binding update to avoid "Publishing changes from within view updates"
289:             DispatchQueue.main.async {
290:                 self.requestedCursorIndex = nil
291:             }
292: 
293:             // Update SwiftUI state
294:             context.coordinator.updateCursorPosition(textView)
295:             context.coordinator.updateScrollPosition(textView)
296:         }
297:         
298:         // Note: updateLineCount is called in textViewDidChange, no need to call here
299:         // as it causes unnecessary state churn on every updateUIView
300:     }




>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-300 of 2151)
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
115:         let textView = EditorTextView()
116:         textView.delegate = context.coordinator
117:         textView.editorCore = editorCore
118: 
119:         // Autocomplete hooks
120:         textView.onAcceptAutocomplete = onAcceptAutocomplete
121:         textView.onDismissAutocomplete = onDismissAutocomplete
122: 
123:         textView.onPeekDefinition = {
124:             context.coordinator.handlePeekDefinition(in: textView)
125:         }
126: 
127:         textView.onEscape = {
128:             context.coordinator.handleEscape()
129:         }
130: 
131:         textView.onGoToLine = {
132:             self.editorCore.showGoToLine = true
133:         }
134:         
135:         // Wire up custom context menu actions
136:         textView.onGoToDefinition = {
137:             context.coordinator.handleGoToDefinition(in: textView)
138:         }
139:         
140:         textView.onFindReferences = {
141:             context.coordinator.handleFindReferences(in: textView)
142:         }
143:         
144:         textView.onFormatDocument = {
145:             context.coordinator.handleFormatDocument(in: textView)
146:         }
147:         
148:         textView.onToggleComment = {
149:             context.coordinator.handleToggleComment(in: textView)
150:         }
151:         
152:         textView.onFold = {
153:             context.coordinator.handleFold(in: textView)
154:         }
155:         
156:         textView.onUnfold = {
157:             context.coordinator.handleUnfold(in: textView)
158:         }
159:         
160:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
161:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
162:         pinchGesture.delegate = context.coordinator
163:         textView.addGestureRecognizer(pinchGesture)
164:         context.coordinator.pinchGesture = pinchGesture
165:         
166:         // Configure text view
167:         textView.isEditable = true
168:         textView.isSelectable = true
169:         textView.autocapitalizationType = .none
170:         textView.autocorrectionType = .no
171:         textView.smartDashesType = .no
172:         textView.smartQuotesType = .no
173:         textView.smartInsertDeleteType = .no
174:         textView.spellCheckingType = .no
175:         
176:         // Set font and appearance (use editorCore.editorFontSize)
177:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
178:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
179:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
180:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
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
271:             DispatchQueue.main.async {
272:                 self.requestedLineSelection = nil
273:             }
274:         }
275: 
276:         // Handle cursor index requests (e.g. accepting autocomplete)
277:         if let requested = requestedCursorIndex,
278:            requested != context.coordinator.lastRequestedCursorIndex {
279:             context.coordinator.lastRequestedCursorIndex = requested
280:             // Use UTF-16 count for NSRange compatibility
281:             let textLength = (textView.text as NSString?)?.length ?? 0
282:             let safeIndex = max(0, min(requested, textLength))
283:             textView.selectedRange = NSRange(location: safeIndex, length: 0)
284:             
285:             // Ensure cursor is visible by scrolling to it
286:             textView.scrollRangeToVisible(textView.selectedRange)
287:             
288:             // Defer @Binding update to avoid "Publishing changes from within view updates"
289:             DispatchQueue.main.async {
290:                 self.requestedCursorIndex = nil
291:             }
292: 
293:             // Update SwiftUI state
294:             context.coordinator.updateCursorPosition(textView)
295:             context.coordinator.updateScrollPosition(textView)
296:         }
297:         
298:         // Note: updateLineCount is called in textViewDidChange, no need to call here
299:         // as it causes unnecessary state churn on every updateUIView
300:     }


>>>TOOL search
{"query": "class EditorTextView", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class EditorTextView"


>>>TOOL search
{"query": "EditorTextView", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "EditorTextView"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1500, "end_line": 1700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1501-1700 of 2151)
────────────────────────────────────────
1501:         attributed.addAttribute(.font, value: baseFont, range: fullRange)
1502:         attributed.addAttribute(.foregroundColor, value: UIColor(theme.editorForeground), range: fullRange)
1503:         
1504:         // Apply language-specific highlighting
1505:         switch language {
1506:         case .swift: highlightSwift(attributed, text: text)
1507:         case .javascript, .jsx: highlightJavaScript(attributed, text: text, isTS: false)
1508:         case .typescript, .tsx: highlightJavaScript(attributed, text: text, isTS: true)
1509:         case .python: highlightPython(attributed, text: text)
1510:         case .html, .xml: highlightHTML(attributed, text: text)
1511:         case .css, .scss, .less: highlightCSS(attributed, text: text)
1512:         case .json: highlightJSON(attributed, text: text)
1513:         case .markdown: highlightMarkdown(attributed, text: text)
1514:         case .rust: highlightRust(attributed, text: text)
1515:         case .go: highlightGo(attributed, text: text)
1516:         case .java, .kotlin: highlightJava(attributed, text: text)
1517:         case .c, .cpp, .objectiveC: highlightCpp(attributed, text: text)
1518:         case .ruby: highlightRuby(attributed, text: text)
1519:         case .php: highlightPHP(attributed, text: text)
1520:         case .shell, .dockerfile: highlightShell(attributed, text: text)
1521:         case .yaml, .env: highlightYAML(attributed, text: text)
1522:         case .sql: highlightSQL(attributed, text: text)
1523:         case .graphql: highlightGraphQL(attributed, text: text)
1524:         case .plainText: break
1525:         }
1526:         
1527:         // FEAT-038: Bracket Pair Colorization (applied last)
1528:         highlightBracketPairs(attributed, text: text)
1529:         
1530:         return attributed
1531:     }
1532:     
1533:     // MARK: - Bracket Pair Colorization
1534:     
1535:     private func highlightBracketPairs(_ attributed: NSMutableAttributedString, text: String) {
1536:         let brackets: [Character] = ["{", "}", "[", "]", "(", ")"]
1537:         let pairs: [Character: Character] = ["}": "{", "]": "[", ")": "("]
1538:         
1539:         var stack: [(char: Character, index: Int, depth: Int)] = []
1540:         let colors = [
1541:             UIColor(theme.bracketPair1),
1542:             UIColor(theme.bracketPair2),
1543:             UIColor(theme.bracketPair3),
1544:             UIColor(theme.bracketPair4),
1545:             UIColor(theme.bracketPair5),
1546:             UIColor(theme.bracketPair6)
1547:         ]
1548:         
1549:         // Scan text for brackets
1550:         // Note: In a real implementation, we should skip brackets inside strings/comments
1551:         // But since we apply this LAST, we can try to respect existing string/comment colors
1552:         // OR implement a more robust parser. For now, simple scan.
1553:         
1554:         // Optimization: Use scanner or direct iteration
1555:         let nsString = text as NSString
1556:         var index = 0
1557:         
1558:         while index < text.utf16.count {
1559:             let char = nsString.character(at: index)
1560:             if let scalar = UnicodeScalar(char) {
1561:                 let c = Character(scalar)
1562:                 
1563:                 if brackets.contains(c) {
1564:                     // Check if it's already colored as string/comment (heuristic)
1565:                     // If color is string/comment, skip
1566:                     // (Requires iterating attributes, which is slow. We'll just apply on top for now)
1567:                     
1568:                     if let open = pairs[c] { // Closing bracket
1569:                         if let last = stack.last, last.char == open {
1570:                             // Match found
1571:                             let depth = last.depth
1572:                             let color = colors[depth % colors.count]
1573:                             
1574:                             attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1575:                             attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: last.index, length: 1))
1576:                             
1577:                             stack.removeLast()
1578:                         } else {
1579:                             // Mismatched or extra closing bracket - unexpected
1580:                             // Keep default color or mark red? Default for now.
1581:                         }
1582:                     } else { // Opening bracket
1583:                         let depth = stack.count
1584:                         stack.append((c, index, depth))
1585:                         
1586:                         // We'll color it when (and if) we find the match, or here?
1587:                         // Better to color here tentatively, but matching is better.
1588:                         // Let's color tentatively based on depth.
1589:                         let color = colors[depth % colors.count]
1590:                         attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1591:                     }
1592:                 }
1593:             }
1594:             index += 1
1595:         }
1596:     }
1597:     
1598:     // MARK: - Swift Highlighting
1599:     
1600:     private func highlightSwift(_ attributed: NSMutableAttributedString, text: String) {
1601:         // Keywords (purple/pink)
1602:         let keywords = ["func", "var", "let", "if", "else", "for", "while", "return",
1603:                        "class", "struct", "enum", "protocol", "extension", "import",
1604:                        "private", "public", "internal", "fileprivate", "open",
1605:                        "static", "final", "override", "mutating", "nonmutating",
1606:                        "init", "deinit", "subscript", "typealias", "associatedtype",
1607:                        "where", "throws", "rethrows", "async", "await", "actor",
1608:                        "guard", "defer", "do", "try", "catch", "throw",
1609:                        "switch", "case", "default", "break", "continue", "fallthrough",
1610:                        "in", "is", "as", "inout", "some", "any", "Self",
1611:                        "get", "set", "willSet", "didSet", "lazy", "weak", "unowned",
1612:                        "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject",
1613:                        "@Environment", "@EnvironmentObject", "@ViewBuilder", "@MainActor",
1614:                        "@escaping", "@autoclosure", "@available", "@objc", "@discardableResult"]
1615:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1616:         
1617:         // Types (teal) - CamelCase words that aren't keywords
1618:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1619:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1620:         
1621:         // Function calls (yellow)
1622:         let funcCallPattern = "\\b([a-z][a-zA-Z0-9]*)\\s*\\("
1623:         highlightPattern(attributed, pattern: funcCallPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1624:         
1625:         // Constants (blue)
1626:         let constants = ["true", "false", "nil", "self", "super"]
1627:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1628:         
1629:         // Comments MUST come late (green) - they override everything
1630:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1631:         
1632:         // Strings AFTER comments (orange)
1633:         highlightStrings(attributed, text: text)
1634:         
1635:         // Numbers (light green)
1636:         highlightNumbers(attributed, text: text)
1637:     }
1638:     
1639:     // MARK: - JavaScript/TypeScript Highlighting
1640:     
1641:     private func highlightJavaScript(_ attributed: NSMutableAttributedString, text: String, isTS: Bool) {
1642:         var keywords = ["function", "var", "let", "const", "if", "else", "for", "while",
1643:                        "return", "class", "extends", "new", "this", "super", "import",
1644:                        "export", "default", "from", "as", "async", "await", "yield",
1645:                        "try", "catch", "finally", "throw", "typeof", "instanceof",
1646:                        "switch", "case", "break", "continue", "do", "in", "of",
1647:                        "get", "set", "static", "constructor", "delete", "void",
1648:                        "with", "debugger"]
1649:         
1650:         if isTS {
1651:             keywords += ["interface", "type", "enum", "namespace", "module", "declare",
1652:                         "implements", "public", "private", "protected", "readonly",
1653:                         "abstract", "override", "keyof", "infer", "never", "unknown",
1654:                         "any", "asserts", "is"]
1655:         }
1656:         
1657:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1658:         
1659:         // Constants
1660:         let constants = ["true", "false", "null", "undefined", "NaN", "Infinity"]
1661:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1662:         
1663:         // Function names (yellow) - regular calls + arrow functions
1664:         let funcNamePattern = "\\b([a-zA-Z_$][a-zA-Z0-9_$]*)\\b(?=\\s*(?:\\(|=>))"
1665:         highlightPattern(attributed, pattern: funcNamePattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1666:         
1667:         // Types (teal)
1668:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1669:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1670:         
1671:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1672:         highlightStrings(attributed, text: text)
1673:         highlightJSTemplateLiterals(attributed, text: text)
1674:         highlightNumbers(attributed, text: text)
1675:     }
1676:     
1677:     // MARK: - Python Highlighting
1678:     
1679:     private func highlightPython(_ attributed: NSMutableAttributedString, text: String) {
1680:         let keywords = ["def", "class", "if", "elif", "else", "for", "while", "return",
1681:                        "import", "from", "as", "try", "except", "finally", "raise",
1682:                        "with", "assert", "yield", "lambda", "pass", "break", "continue",
1683:                        "global", "nonlocal", "del", "in", "not", "and", "or", "is",
1684:                        "async", "await", "match", "case"]
1685:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1686:         
1687:         let constants = ["True", "False", "None", "self", "cls"]
1688:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1689:         
1690:         // Decorators (yellow)
1691:         let decoratorPattern = "@[a-zA-Z_][a-zA-Z0-9_\\.]*"
1692:         highlightPattern(attributed, pattern: decoratorPattern, color: UIColor(theme.function), text: text)
1693:         
1694:         // Function definitions (yellow)
1695:         let funcDefPattern = "(?<=def\\s)[a-zA-Z_][a-zA-Z0-9_]*"
1696:         highlightPattern(attributed, pattern: funcDefPattern, color: UIColor(theme.function), text: text)
1697:         
1698:         // Class names (teal)
1699:         let classPattern = "(?<=class\\s)[a-zA-Z_][a-zA-Z0-9_]*"
1700:         highlightPattern(attributed, pattern: classPattern, color: UIColor(theme.type), text: text)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1800, "end_line": 2000}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1801-2000 of 2151)
────────────────────────────────────────
1801:         highlightPattern(attributed, pattern: codeBlockPattern, color: UIColor(theme.comment), text: text)
1802:         
1803:         // Links (light blue)
1804:         let linkPattern = "\\[[^\\]]+\\]\\([^)]+\\)"
1805:         highlightPattern(attributed, pattern: linkPattern, color: UIColor(theme.variable), text: text)
1806:         
1807:         // Lists
1808:         let listPattern = "^\\s*[-*+]\\s"
1809:         highlightPattern(attributed, pattern: listPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
1810:     }
1811:     
1812:     // MARK: - Rust Highlighting
1813:     
1814:     private func highlightRust(_ attributed: NSMutableAttributedString, text: String) {
1815:         let keywords = ["fn", "let", "mut", "const", "if", "else", "match", "loop", "while", "for",
1816:                        "return", "struct", "enum", "impl", "trait", "type", "use", "mod", "pub",
1817:                        "self", "Self", "super", "crate", "as", "in", "ref", "move", "async", "await",
1818:                        "where", "unsafe", "extern", "dyn", "static", "break", "continue"]
1819:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1820:         
1821:         let types = ["i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize",
1822:                     "f32", "f64", "bool", "char", "str", "String", "Vec", "Option", "Result", "Box"]
1823:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1824:         
1825:         let constants = ["true", "false", "None", "Some", "Ok", "Err"]
1826:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1827:         
1828:         // Macros (yellow)
1829:         let macroPattern = "[a-zA-Z_][a-zA-Z0-9_]*!"
1830:         highlightPattern(attributed, pattern: macroPattern, color: UIColor(theme.function), text: text)
1831:         
1832:         // Lifetimes (orange)
1833:         let lifetimePattern = "'[a-zA-Z_][a-zA-Z0-9_]*"
1834:         highlightPattern(attributed, pattern: lifetimePattern, color: UIColor(theme.string), text: text)
1835:         
1836:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1837:         highlightStrings(attributed, text: text)
1838:         highlightNumbers(attributed, text: text)
1839:     }
1840:     
1841:     // MARK: - Go Highlighting
1842:     
1843:     private func highlightGo(_ attributed: NSMutableAttributedString, text: String) {
1844:         let keywords = ["func", "var", "const", "type", "struct", "interface", "map", "chan",
1845:                        "if", "else", "for", "range", "switch", "case", "default", "select",
1846:                        "return", "break", "continue", "goto", "fallthrough", "defer", "go",
1847:                        "package", "import"]
1848:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1849:         
1850:         let types = ["int", "int8", "int16", "int32", "int64", "uint", "uint8", "uint16", "uint32", "uint64",
1851:                     "float32", "float64", "complex64", "complex128", "byte", "rune", "string", "bool", "error"]
1852:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1853:         
1854:         let constants = ["true", "false", "nil", "iota"]
1855:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1856:         
1857:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1858:         highlightStrings(attributed, text: text)
1859:         highlightNumbers(attributed, text: text)
1860:     }
1861:     
1862:     // MARK: - Java Highlighting
1863:     
1864:     private func highlightJava(_ attributed: NSMutableAttributedString, text: String) {
1865:         let keywords = ["public", "private", "protected", "class", "interface", "extends", "implements",
1866:                        "static", "final", "abstract", "native", "synchronized", "volatile", "transient",
1867:                        "if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue",
1868:                        "return", "throw", "throws", "try", "catch", "finally", "new", "this", "super",
1869:                        "import", "package", "instanceof", "assert", "enum", "void"]
1870:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1871:         
1872:         let types = ["int", "long", "short", "byte", "float", "double", "char", "boolean",
1873:                     "String", "Integer", "Long", "Double", "Boolean", "Object", "List", "Map", "Set"]
1874:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1875:         
1876:         let constants = ["true", "false", "null"]
1877:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1878:         
1879:         // Annotations
1880:         let annotationPattern = "@[a-zA-Z][a-zA-Z0-9]*"
1881:         highlightPattern(attributed, pattern: annotationPattern, color: UIColor(theme.function), text: text)
1882:         
1883:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1884:         highlightStrings(attributed, text: text)
1885:         highlightNumbers(attributed, text: text)
1886:     }
1887:     
1888:     // MARK: - C/C++ Highlighting
1889:     
1890:     private func highlightCpp(_ attributed: NSMutableAttributedString, text: String) {
1891:         let keywords = ["auto", "break", "case", "catch", "class", "const", "continue", "default",
1892:                        "delete", "do", "else", "enum", "explicit", "extern", "for", "friend", "goto",
1893:                        "if", "inline", "mutable", "namespace", "new", "operator", "private", "protected",
1894:                        "public", "register", "return", "sizeof", "static", "struct", "switch", "template",
1895:                        "this", "throw", "try", "typedef", "typename", "union", "using", "virtual",
1896:                        "volatile", "while", "constexpr", "nullptr", "override", "final", "noexcept"]
1897:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1898:         
1899:         let types = ["void", "int", "long", "short", "char", "float", "double", "bool", "signed", "unsigned",
1900:                     "int8_t", "int16_t", "int32_t", "int64_t", "uint8_t", "uint16_t", "uint32_t", "uint64_t",
1901:                     "size_t", "string", "vector", "map", "set", "unique_ptr", "shared_ptr"]
1902:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1903:         
1904:         let constants = ["true", "false", "NULL", "nullptr"]
1905:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1906:         
1907:         // Preprocessor directives
1908:         let preprocPattern = "^\\s*#\\s*(include|define|ifdef|ifndef|endif|if|else|elif|pragma|error|warning).*$"
1909:         highlightPattern(attributed, pattern: preprocPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
1910:         
1911:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1912:         highlightStrings(attributed, text: text)
1913:         highlightNumbers(attributed, text: text)
1914:     }
1915:     
1916:     // MARK: - Ruby Highlighting
1917:     
1918:     private func highlightRuby(_ attributed: NSMutableAttributedString, text: String) {
1919:         let keywords = ["def", "class", "module", "if", "elsif", "else", "unless", "case", "when",
1920:                        "while", "until", "for", "do", "end", "begin", "rescue", "ensure", "raise",
1921:                        "return", "yield", "break", "next", "redo", "retry", "self", "super",
1922:                        "require", "require_relative", "include", "extend", "attr_reader", "attr_writer", "attr_accessor",
1923:                        "public", "private", "protected", "alias", "and", "or", "not", "in"]
1924:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1925:         
1926:         let constants = ["true", "false", "nil"]
1927:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1928:         
1929:         // Symbols (orange)
1930:         let symbolPattern = ":[a-zA-Z_][a-zA-Z0-9_]*"
1931:         highlightPattern(attributed, pattern: symbolPattern, color: UIColor(theme.string), text: text)
1932:         
1933:         // Instance variables (light blue)
1934:         let ivarPattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
1935:         highlightPattern(attributed, pattern: ivarPattern, color: UIColor(theme.variable), text: text)
1936:         
1937:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: "=begin", multiLineEnd: "=end")
1938:         highlightStrings(attributed, text: text)
1939:         highlightNumbers(attributed, text: text)
1940:     }
1941:     
1942:     // MARK: - PHP Highlighting
1943:     
1944:     private func highlightPHP(_ attributed: NSMutableAttributedString, text: String) {
1945:         let keywords = ["function", "class", "interface", "trait", "extends", "implements", "use",
1946:                        "public", "private", "protected", "static", "final", "abstract", "const",
1947:                        "if", "else", "elseif", "switch", "case", "default", "for", "foreach", "while", "do",
1948:                        "return", "break", "continue", "throw", "try", "catch", "finally",
1949:                        "new", "clone", "instanceof", "echo", "print", "die", "exit",
1950:                        "require", "require_once", "include", "include_once", "namespace"]
1951:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1952:         
1953:         let constants = ["true", "false", "null", "TRUE", "FALSE", "NULL"]
1954:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1955:         
1956:         // Variables (light blue)
1957:         let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
1958:         highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
1959:         
1960:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1961:         highlightStrings(attributed, text: text)
1962:         highlightNumbers(attributed, text: text)
1963:     }
1964:     
1965:     // MARK: - Shell Highlighting
1966:     
1967:     private func highlightShell(_ attributed: NSMutableAttributedString, text: String) {
1968:         let keywords = ["if", "then", "else", "elif", "fi", "for", "while", "do", "done", "case", "esac",
1969:                        "function", "return", "exit", "break", "continue", "local", "export", "readonly",
1970:                        "source", "alias", "unalias", "set", "unset", "shift", "eval", "exec",
1971:                        "echo", "printf", "read", "cd", "pwd", "ls", "mkdir", "rm", "cp", "mv"]
1972:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1973:         
1974:         // Variables (light blue)
1975:         let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*|\\$\\{[^}]+\\}"
1976:         highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
1977:         
1978:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1979:         highlightStrings(attributed, text: text)
1980:         highlightNumbers(attributed, text: text)
1981:     }
1982:     
1983:     // MARK: - YAML Highlighting
1984:     
1985:     private func highlightYAML(_ attributed: NSMutableAttributedString, text: String) {
1986:         // Keys (light blue)
1987:         let keyPattern = "^\\s*([a-zA-Z_][a-zA-Z0-9_-]*)\\s*:"
1988:         highlightPattern(attributed, pattern: keyPattern, color: UIColor(theme.variable), text: text, options: .anchorsMatchLines, captureGroup: 1)
1989:         
1990:         // Booleans and null
1991:         let constants = ["true", "false", "yes", "no", "on", "off", "null", "~"]
1992:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1993:         
1994:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1995:         highlightStrings(attributed, text: text)
1996:         highlightNumbers(attributed, text: text)
1997:     }
1998:     
1999:     // MARK: - SQL Highlighting
2000:     


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 300, "end_line": 500}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 301-500 of 2151)
────────────────────────────────────────
301:     
302:     // MARK: - Coordinator
303:     
304:     class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
305:         var parent: SyntaxHighlightingTextView
306:         var lastKnownScrollPosition: Int = 0
307:         var lastThemeId: String = ""
308:         var lastRequestedLineSelection: Int? = nil
309:         var lastRequestedCursorIndex: Int? = nil
310:         private var isUpdatingFromMinimap = false
311:         private var highlightDebouncer: Timer?
312:         weak var pinchGesture: UIPinchGestureRecognizer?
313:         private var initialFontSize: CGFloat = 0
314:         
315:         // Track user scroll to prevent programmatic scroll fighting back
316:         private var userScrollDebouncer: Timer?
317:         var isUserScrolling = false
318: 
319:         // FEAT-044: Matching bracket highlight state
320:         private var bracketHighlightRanges: [NSRange] = []
321:         
322:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
323:         var hasAppliedInitialHighlighting = false
324:         
325:         // PERFORMANCE: Large file highlighting optimization
326:         // Files larger than this threshold get deferred full highlighting
327:         private let largeFileThreshold = 10000  // 10k characters
328:         private var largeFileHighlightDebouncer: Timer?
329:         // Track if we have pending full highlight (for large files)
330:         private var hasPendingFullHighlight = false
331:         
332:         init(_ parent: SyntaxHighlightingTextView) {
333:             self.parent = parent
334:         }
335:         
336:         // MARK: - UIGestureRecognizerDelegate
337:         
338:         // Allow pinch gesture to work simultaneously with text selection gestures
339:         func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
340:             // Allow pinch to work alongside native text selection gestures
341:             return true
342:         }
343:         
344:         func textViewDidBeginEditing(_ textView: UITextView) {
345:             // Ensure syntax highlighting is current when user begins editing
346:             // This handles cases where text was set but highlighting hasn't run yet
347:             applySyntaxHighlighting(to: textView)
348:         }
349:         
350:         func textViewDidChange(_ textView: UITextView) {
351:             // Update parent text
352:             parent.text = textView.text
353:             
354:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
355:             // This prevents flicker during the debounce period
356:             let theme = ThemeManager.shared.currentTheme
357:             let fontSize = parent.editorCore.editorFontSize
358:             textView.typingAttributes = [
359:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
360:                 .foregroundColor: UIColor(theme.editorForeground)
361:             ]
362:             
363:             // PERFORMANCE FIX: Aggressive debounce strategy based on document size
364:             // For large files, syntax highlighting is EXTREMELY expensive and causes lag
365:             let textLength = textView.text.count
366:             
367:             // Large file threshold - above this, skip highlighting during active typing entirely
368:             let largeFileThreshold = 10000
369:             // Very large file threshold - above this, use extended delay
370:             let veryLargeFileThreshold = 50000
371:             
372:             highlightDebouncer?.invalidate()
373:             
374:             if textLength > veryLargeFileThreshold {
375:                 // VERY LARGE FILES (50k+): Wait 1.5 seconds of idle before highlighting
376:                 // This prevents UI blocking entirely during active typing
377:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
378:                     self?.applyVisibleRangeHighlighting(to: textView)
379:                 }
380:             } else if textLength > largeFileThreshold {
381:                 // LARGE FILES (10k-50k): Wait 1 second of idle, then highlight visible range only
382:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
383:                     self?.applyVisibleRangeHighlighting(to: textView)
384:                 }
385:             } else if textLength > 5000 {
386:                 // MEDIUM FILES (5k-10k): 300ms debounce, full highlighting on background thread
387:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
388:                     self?.applyHighlightingAsync(to: textView)
389:                 }
390:             } else {
391:                 // SMALL FILES (<5k): 80ms debounce, direct highlighting (fast enough)
392:                 highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
393:                     DispatchQueue.main.async {
394:                         self?.applySyntaxHighlighting(to: textView)
395:                     }
396:                 }
397:             }
398:             
399:             updateLineCount(textView)
400:             updateCursorPosition(textView)
401:         }
402:         
403:         /// Async highlighting for large files - processes on background thread
404:         func applyHighlightingAsync(to textView: UITextView) {
405:             guard !isApplyingHighlighting else { return }
406:             isApplyingHighlighting = true
407:             
408:             let text = textView.text ?? ""
409:             let filename = parent.filename
410:             let theme = ThemeManager.shared.currentTheme
411:             let fontSize = parent.editorCore.editorFontSize
412:             let selectedRange = textView.selectedRange
413:             
414:             // Process highlighting on background thread
415:             DispatchQueue.global(qos: .userInitiated).async { [weak self] in
416:                 let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
417:                 let attributedText = highlighter.highlight(text, filename: filename)
418:                 
419:                 // Apply on main thread
420:                 DispatchQueue.main.async {
421:                     guard let self = self else { return }
422:                     self.isApplyingHighlighting = false
423:                     
424:                     // Only apply if text hasn't changed while we were processing
425:                     guard textView.text == text else { return }
426:                     
427:                     textView.attributedText = attributedText
428:                     textView.selectedRange = selectedRange
429:                     
430:                     textView.typingAttributes = [
431:                         .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
432:                         .foregroundColor: UIColor(theme.editorForeground)
433:                     ]
434:                     
435:                     self.lastThemeId = theme.id
436:                 }
437:             }
438:         }
439:         
440:         /// PERFORMANCE: Visible-range-only highlighting for very large files
441:         /// Only highlights the text that's currently visible on screen, dramatically reducing lag
442:         func applyVisibleRangeHighlighting(to textView: UITextView) {
443:             guard !isApplyingHighlighting else { return }
444:             isApplyingHighlighting = true
445:             
446:             let text = textView.text ?? ""
447:             let filename = parent.filename
448:             let theme = ThemeManager.shared.currentTheme
449:             let fontSize = parent.editorCore.editorFontSize
450:             let selectedRange = textView.selectedRange
451:             
452:             // Calculate visible range with buffer
453:             let visibleRect = textView.bounds
454:             let textContainer = textView.textContainer
455:             let layoutManager = textView.layoutManager
456:             
457:             // Get the glyph range for the visible rect
458:             var visibleGlyphRange = NSRange()
459:             layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs)) { (rect, usedRect, container, glyphRange, stop) in
460:                 if rect.intersects(visibleRect) {
461:                     if visibleGlyphRange.length == 0 {
462:                         visibleGlyphRange = glyphRange
463:                     } else {
464:                         visibleGlyphRange.length = glyphRange.location + glyphRange.length - visibleGlyphRange.location
465:                     }
466:                 } else if visibleGlyphRange.length > 0 && rect.minY > visibleRect.maxY {
467:                     stop.pointee = true
468:                 }
469:             }
470:             
471:             // Convert glyph range to character range
472:             var visibleCharRange = layoutManager.characterRange(forGlyphRange: visibleGlyphRange, actualGlyphRange: nil)
473:             
474:             // Add buffer of ~50 lines before and after for smooth scrolling
475:             let bufferChars = 5000
476:             let rangeStart = max(0, visibleCharRange.location - bufferChars)
477:             let rangeEnd = min(text.utf16.count, visibleCharRange.location + visibleCharRange.length + bufferChars)
478:             visibleCharRange = NSRange(location: rangeStart, length: rangeEnd - rangeStart)
479:             
480:             // Process highlighting on background thread
481:             DispatchQueue.global(qos: .userInitiated).async { [weak self] in
482:                 // Extract the visible portion of text
483:                 let nsText = text as NSString
484:                 let safeRange = NSRange(
485:                     location: visibleCharRange.location,
486:                     length: min(visibleCharRange.length, nsText.length - visibleCharRange.location)
487:                 )
488:                 guard safeRange.length > 0 else {
489:                     DispatchQueue.main.async {
490:                         self?.isApplyingHighlighting = false
491:                     }
492:                     return
493:                 }
494:                 
495:                 let visibleText = nsText.substring(with: safeRange)
496:                 
497:                 // Highlight only the visible portion
498:                 let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
499:                 let highlightedVisible = highlighter.highlight(visibleText, filename: filename)
500:                 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 500, "end_line": 700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 501-700 of 2151)
────────────────────────────────────────
501:                 // Apply on main thread
502:                 DispatchQueue.main.async {
503:                     guard let self = self else { return }
504:                     self.isApplyingHighlighting = false
505:                     
506:                     // Only apply if text hasn't changed while we were processing
507:                     guard textView.text == text else { return }
508:                     
509:                     // Create full attributed string with base styling
510:                     let fullAttributed = NSMutableAttributedString(string: text)
511:                     let baseFont = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
512:                     let baseColor = UIColor(theme.editorForeground)
513:                     let fullRange = NSRange(location: 0, length: text.utf16.count)
514:                     fullAttributed.addAttribute(.font, value: baseFont, range: fullRange)
515:                     fullAttributed.addAttribute(.foregroundColor, value: baseColor, range: fullRange)
516:                     
517:                     // Apply highlighted attributes only to visible range
518:                     highlightedVisible.enumerateAttributes(in: NSRange(location: 0, length: highlightedVisible.length), options: []) { attrs, range, _ in
519:                         let targetRange = NSRange(location: safeRange.location + range.location, length: range.length)
520:                         if targetRange.location + targetRange.length <= fullAttributed.length {
521:                             for (key, value) in attrs {
522:                                 fullAttributed.addAttribute(key, value: value, range: targetRange)
523:                             }
524:                         }
525:                     }
526:                     
527:                     textView.attributedText = fullAttributed
528:                     textView.selectedRange = selectedRange
529:                     
530:                     textView.typingAttributes = [
531:                         .font: baseFont,
532:                         .foregroundColor: baseColor
533:                     ]
534:                     
535:                     self.lastThemeId = theme.id
536:                 }
537:             }
538:         }
539:         
540:         func textViewDidChangeSelection(_ textView: UITextView) {
541:             if !isUpdatingFromMinimap {
542:                 updateCursorPosition(textView)
543:                 updateScrollPosition(textView)
544: 
545:                 // FEAT-044: Matching bracket highlight
546:                 updateMatchingBracketHighlight(textView)
547: 
548:                 // Trigger redraw so current-line highlight/indent guides track the caret
549:                 (textView as? EditorTextView)?.setNeedsDisplay()
550: 
551:                 // Update selection in EditorCore for multi-cursor support
552:                 // Defer @Published property updates to avoid "Publishing changes from within view updates"
553:                 let range = textView.selectedRange
554:                 let currentText = textView.text ?? ""
555:                 let isMultiCursor = parent.editorCore.multiCursorState.isMultiCursor
556:                 
557:                 DispatchQueue.main.async { [weak self] in
558:                     guard let self = self else { return }
559:                     self.parent.editorCore.updateSelection(range: range, text: currentText)
560: 
561:                     // Keep EditorCore.multiCursorState in sync with UIKit selection.
562:                     // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
563:                     // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
564:                     if !isMultiCursor {
565:                         if range.length > 0 {
566:                             self.parent.editorCore.multiCursorState.cursors = [
567:                                 Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)
568:                             ]
569:                         } else {
570:                             self.parent.editorCore.multiCursorState.reset(to: range.location)
571:                         }
572:                     }
573:                 }
574:             }
575:         }
576:         
577:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
578:         
579:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
580:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
581:             isUserScrolling = true
582:             userScrollDebouncer?.invalidate()
583:         }
584:         
585:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
586:             // If not decelerating, user stopped scrolling
587:             if !decelerate {
588:                 // Small delay to let any final scroll events settle
589:                 userScrollDebouncer?.invalidate()
590:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
591:                     self?.isUserScrolling = false
592:                 }
593:             }
594:         }
595:         
596:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
597:             // Deceleration finished - user scroll is complete
598:             userScrollDebouncer?.invalidate()
599:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
600:                 self?.isUserScrolling = false
601:             }
602:         }
603:         
604:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
605:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
606:             
607:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
608:             // We still use debouncer as a fallback for edge cases
609:             if isUserScrolling {
610:                 userScrollDebouncer?.invalidate()
611:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
612:                     self?.isUserScrolling = false
613:                 }
614:             }
615:             
616:             updateScrollPosition(textView)
617:         }
618:         
619:         func updateLineCount(_ textView: UITextView) {
620:             let lines = textView.text.components(separatedBy: .newlines)
621:             DispatchQueue.main.async {
622:                 self.parent.totalLines = max(1, lines.count)
623:             }
624:         }
625:         
626:         func updateCursorPosition(_ textView: UITextView) {
627:             guard let selectedRange = textView.selectedTextRange else { return }
628:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
629:              
630:              let text = textView.text ?? ""
631:              let prefix = String(text.prefix(cursorPosition))
632:              let lines = prefix.components(separatedBy: .newlines)
633:              
634:              let lineNumber = lines.count
635:              let column = (lines.last?.count ?? 0) + 1
636:              
637:              DispatchQueue.main.async {
638:                  self.parent.currentLineNumber = lineNumber
639:                  self.parent.currentColumn = column
640:                  self.parent.cursorIndex = cursorPosition
641:              }
642:         }
643:         
644:         func updateScrollPosition(_ textView: UITextView) {
645:             guard let font = textView.font else { return }
646:             let lineHeight = font.lineHeight
647:             let yOffset = textView.contentOffset.y
648:             let line = Int(yOffset / lineHeight)
649: 
650:             // Update lastKnownScrollPosition synchronously to prevent feedback loops
651:             lastKnownScrollPosition = line
652:             
653:             // Defer @Binding updates to avoid "Publishing changes from within view updates"
654:             DispatchQueue.main.async {
655:                 self.parent.scrollPosition = line
656:                 self.parent.scrollOffset = yOffset
657:             }
658:         }
659:         
660:         func scrollToLine(_ line: Int, in textView: UITextView) {
661:             guard !isUpdatingFromMinimap else { return }
662:             isUpdatingFromMinimap = true
663:             
664:             let lines = textView.text.components(separatedBy: .newlines)
665:             guard line >= 0 && line < lines.count else {
666:                 isUpdatingFromMinimap = false
667:                 return
668:             }
669:             
670:             var characterPosition = 0
671:             for i in 0..<line {
672:                 characterPosition += lines[i].count + 1
673:             }
674:             
675:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
676:                 let rect = textView.caretRect(for: position)
677:                 let targetY = max(0, rect.origin.y)
678:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
679:             }
680:             
681:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
682:                 self.isUpdatingFromMinimap = false
683:             }
684:         }
685: 
686:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
687:             let lines = textView.text.components(separatedBy: .newlines)
688:             guard line >= 0 && line < lines.count else { return }
689: 
690:             var characterPosition = 0
691:             for i in 0..<line {
692:                 characterPosition += lines[i].count + 1
693:             }
694: 
695:             // FEAT-041: select entire line (excluding trailing newline)
696:             let lineLength = (lines[line] as NSString).length
697:             let range = NSRange(location: characterPosition, length: lineLength)
698:             textView.selectedRange = range
699: 
700:             // Ensure it's visible


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 700, "end_line": 900}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 701-900 of 2151)
────────────────────────────────────────
701:             scrollToLine(line, in: textView)
702: 
703:             // Update SwiftUI state
704:             updateCursorPosition(textView)
705:             updateScrollPosition(textView)
706:         }
707: 
708:         private var isApplyingHighlighting = false
709:         
710:         func applySyntaxHighlighting(to textView: UITextView) {
711:             // Guard against reentrancy - this can happen if attributedText assignment
712:             // triggers delegate callbacks that call this method again
713:             guard !isApplyingHighlighting else { return }
714:             isApplyingHighlighting = true
715:             defer { isApplyingHighlighting = false }
716:             
717:             let theme = ThemeManager.shared.currentTheme
718:             lastThemeId = theme.id
719: 
720:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
721:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
722: 
723:             let selectedRange = textView.selectedRange
724: 
725:             // NOTE: We intentionally do NOT manipulate undoManager.disableUndoRegistration/enableUndoRegistration
726:             // here. UITextView's internal undo manager state machine is fragile and can crash with
727:             // "enableUndoRegistration may only be invoked with matching call to disableUndoRegistration"
728:             // when attributedText assignment triggers internal undo callbacks.
729:             // 
730:             // Instead, we let the system handle undo naturally. The trade-off is that syntax highlighting
731:             // changes might add noise to the undo stack, but this is preferable to crashing.
732:             
733:             textView.attributedText = attributedText
734:             textView.selectedRange = selectedRange
735: 
736:             // Set typing attributes so newly typed characters have correct base styling
737:             // This prevents flicker during the debounce period before full highlighting runs
738:             let fontSize = parent.editorCore.editorFontSize
739:             textView.typingAttributes = [
740:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
741:                 .foregroundColor: UIColor(theme.editorForeground)
742:             ]
743: 
744:             // FEAT-044: restore matching bracket highlight after re-attributing text
745:             updateMatchingBracketHighlight(textView)
746:         }
747:         
748:         func handlePeekDefinition(in textView: UITextView) {
749:             guard let selectedRange = textView.selectedTextRange else { return }
750:             let text = textView.text ?? ""
751:             
752:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
753:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
754:                  
755:                  let prefix = String(text.prefix(location))
756:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
757:                  
758:                  parent.editorCore.triggerPeekDefinition(
759:                      file: parent.filename,
760:                      line: sourceLine,
761:                      content: text,
762:                      sourceLine: sourceLine
763:                  )
764:             }
765:         }
766:         
767:         func handleEscape() {
768:             if parent.editorCore.peekState != nil {
769:                 parent.editorCore.closePeekDefinition()
770:             } else {
771:                 parent.editorCore.escapeMultiCursor()
772:             }
773:         }
774:         
775:         func handleGoToDefinition(in textView: UITextView) {
776:             // Reuse the peek definition logic for now
777:             handlePeekDefinition(in: textView)
778:         }
779:         
780:         func handleFindReferences(in textView: UITextView) {
781:             guard let selectedRange = textView.selectedTextRange else { return }
782:             let text = textView.text ?? ""
783:             
784:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
785:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
786:                 
787:                 let prefix = String(text.prefix(location))
788:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
789:                 
790:                 // TODO: Implement find references functionality in EditorCore
791:                 // For now, just trigger peek definition as a placeholder
792:                 parent.editorCore.triggerPeekDefinition(
793:                     file: parent.filename,
794:                     line: sourceLine,
795:                     content: text,
796:                     sourceLine: sourceLine
797:                 )
798:             }
799:         }
800:         
801:         func handleFormatDocument(in textView: UITextView) {
802:             // TODO: Implement format document functionality
803:             // This would typically call a formatter in EditorCore
804:             print("Format Document: Not yet implemented")
805:         }
806:         
807:         func handleToggleComment(in textView: UITextView) {
808:             guard let selectedRange = textView.selectedTextRange else { return }
809:             let text = textView.text ?? ""
810:             
811:             // Get the current line range
812:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
813:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
814:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
815:                 let nsRange = NSRange(location: location, length: length)
816:                 
817:                 if nsRange.location + nsRange.length <= (text as NSString).length {
818:                     let lineText = (text as NSString).substring(with: nsRange)
819:                     let trimmed = lineText.trimmingCharacters(in: .whitespaces)
820:                     
821:                     // Check if line starts with a comment
822:                     let isCommented = trimmed.hasPrefix("//") || trimmed.hasPrefix("#") || trimmed.hasPrefix("/*")
823:                     
824:                     // Toggle comment
825:                     var newLineText: String
826:                     if isCommented {
827:                         // Remove comment
828:                         newLineText = lineText.replacingOccurrences(of: "//", with: "").replacingOccurrences(of: "#", with: "", options: .anchored)
829:                     } else {
830:                         // Add comment (use // for most languages)
831:                         newLineText = "//" + lineText
832:                     }
833:                     
834:                     // Replace the line
835:                     let textStorage = textView.textStorage
836:                     textStorage.replaceCharacters(in: nsRange, with: newLineText)
837:                     
838:                     // Update parent binding
839:                     parent.text = textView.text
840:                 }
841:             }
842:         }
843:         
844:         func handleFold(in textView: UITextView) {
845:             CodeFoldingManager.shared.foldCurrentLine()
846:         }
847:         
848:         func handleUnfold(in textView: UITextView) {
849:             CodeFoldingManager.shared.unfoldCurrentLine()
850:         }
851:         
852:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
853:             guard let textView = gesture.view as? UITextView else { return }
854: 
855:             switch gesture.state {
856:             case .began:
857:                 // Store the initial font size when pinch begins
858:                 initialFontSize = parent.editorCore.editorFontSize
859: 
860:             case .changed:
861:                 // Calculate new font size based on pinch scale
862:                 let newSize = initialFontSize * gesture.scale
863: 
864:                 // Clamp font size between 8 and 32
865:                 let clampedSize = min(max(newSize, 8), 32)
866: 
867:                 // Update EditorCore's font size (this will trigger updateUIView)
868:                 parent.editorCore.editorFontSize = clampedSize
869: 
870:             case .ended, .cancelled:
871:                 // Optional: snap to nearest whole number or standard size
872:                 let finalSize = round(parent.editorCore.editorFontSize)
873:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
874: 
875:             default:
876:                 break
877:             }
878:         }
879: 
880:         // MARK: - FEAT-044 Matching Bracket Highlight
881: 
882:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
883:             // Clear any existing highlights
884:             if !bracketHighlightRanges.isEmpty {
885:                 for r in bracketHighlightRanges {
886:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
887:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
888:                 }
889:                 bracketHighlightRanges.removeAll()
890:             }
891: 
892:             // Only highlight when there's a caret (no selection)
893:             let selection = textView.selectedRange
894:             guard selection.length == 0 else { return }
895: 
896:             let nsText = (textView.text ?? "") as NSString
897:             let length = nsText.length
898:             guard length > 0 else { return }
899: 
900:             let caret = selection.location


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1000, "end_line": 1200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1001-1200 of 2151)
────────────────────────────────────────
1001:     var onUnfold: (() -> Void)?
1002: 
1003:     // Autocomplete key handling hooks are inherited from MultiCursorTextView
1004:     
1005:     // FEAT-039 & FEAT-043
1006:     private var indentGuideColor: UIColor = .separator
1007:     private var activeIndentGuideColor: UIColor = .label
1008:     private var currentLineHighlightColor: UIColor = .clear
1009:     
1010:     override init(frame: CGRect, textContainer: NSTextContainer?) {
1011:         super.init(frame: frame, textContainer: textContainer)
1012:         setup()
1013:     }
1014:     
1015:     required init?(coder: NSCoder) {
1016:         super.init(coder: coder)
1017:         setup()
1018:     }
1019:     
1020:     private func setup() {
1021:         // Ensure we redraw when bounds/selection change
1022:         contentMode = .redraw
1023:     }
1024:     
1025:     func updateThemeColors(theme: Theme) {
1026:         self.indentGuideColor = UIColor(theme.indentGuide)
1027:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
1028:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
1029:         setNeedsDisplay()
1030:     }
1031:     
1032:     override func draw(_ rect: CGRect) {
1033:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
1034:             super.draw(rect)
1035:             return
1036:         }
1037:         
1038:         // 1. Draw Current Line Highlight (FEAT-043)
1039:         if let selectedRange = selectedTextRange {
1040:             // Get the line rect for the cursor position
1041:             let caretRect = self.caretRect(for: selectedRange.start)
1042:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
1043:             
1044:             context.setFillColor(currentLineHighlightColor.cgColor)
1045:             context.fill(lineRect)
1046:         }
1047:         
1048:         // 2. Draw Text (super implementation)
1049:         super.draw(rect)
1050:         
1051:         // 3. Draw Indent Guides (FEAT-039)
1052:         // We iterate visible lines and draw vertical lines for indentation
1053:         // Optimization: Only draw for visible range
1054: 
1055:         context.setLineWidth(1.0)
1056: 
1057:         // Respect editor tab size setting (default 4)
1058:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
1059:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
1060: 
1061:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
1062:         let indentWidth = spaceWidth * CGFloat(tabSize)
1063: 
1064:         // Determine active indent level for caret line (for indentGuideActive)
1065:         var activeIndentLevel: Int = 0
1066:         if let selected = selectedTextRange {
1067:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
1068:             let nsText = (self.text ?? "") as NSString
1069:             let safeLoc = min(max(0, caretPos), nsText.length)
1070:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
1071:             let caretLineText = nsText.substring(with: caretLineRange)
1072: 
1073:             var spaces = 0
1074:             for ch in caretLineText {
1075:                 if ch == " " { spaces += 1 }
1076:                 else if ch == "\t" { spaces += tabSize }
1077:                 else { break }
1078:             }
1079:             activeIndentLevel = spaces / tabSize
1080:         }
1081: 
1082:         // Iterate visible glyphs/lines
1083:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
1084:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
1085: 
1086:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
1087: 
1088:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
1089:             // Get text for this line
1090:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
1091:                   let text = self.text as NSString? else { return }
1092: 
1093:             let lineText = text.substring(with: range)
1094: 
1095:             // Calculate indentation level
1096:             var spaces = 0
1097:             for char in lineText {
1098:                 if char == " " { spaces += 1 }
1099:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
1100:                 else { break }
1101:             }
1102: 
1103:             let indentLevel = spaces / tabSize
1104:             guard indentLevel > 0 else { return }
1105: 
1106:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
1107: 
1108:             for i in 1...indentLevel {
1109:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
1110:                 let startPoint = CGPoint(x: x, y: rect.minY)
1111:                 let endPoint = CGPoint(x: x, y: rect.maxY)
1112: 
1113:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
1114:                 context.setStrokeColor(stroke.cgColor)
1115: 
1116:                 context.move(to: startPoint)
1117:                 context.addLine(to: endPoint)
1118:                 context.strokePath()
1119:             }
1120:         }
1121:     }
1122:     
1123:     override var keyCommands: [UIKeyCommand]? {
1124:         // NOTE: Only define text-editing specific shortcuts here.
1125:         // App-level shortcuts (Cmd+B, Cmd+P, Cmd+N, Cmd+S, Cmd+W, Cmd+F, etc.)
1126:         // are defined in the Menus/ folder via SwiftUI's .keyboardShortcut().
1127:         // See: KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
1128:         // Defining them here AND in Menus/ causes duplicate conflicts.
1129:         
1130:         var commands = super.keyCommands ?? []
1131:         
1132:         // Peek Definition: Option+D (editor-specific, not in menus)
1133:         commands.append(UIKeyCommand(
1134:             input: "d",
1135:             modifierFlags: .alternate,
1136:             action: #selector(handlePeekDefinition)
1137:         ))
1138: 
1139:         // NOTE: Cmd+G (Go to Line) is defined in GoMenuCommands.swift - DO NOT ADD HERE
1140: 
1141:         // Tab: accept autocomplete if visible, else insert tab
1142:         commands.append(UIKeyCommand(
1143:             input: "\t",
1144:             modifierFlags: [],
1145:             action: #selector(handleTab)
1146:         ))
1147:         
1148:         // Escape: dismiss autocomplete/peek if visible
1149:         commands.append(UIKeyCommand(
1150:             input: UIKeyCommand.inputEscape,
1151:             modifierFlags: [],
1152:             action: #selector(handleEscape)
1153:         ))
1154:         
1155:         // Fold: Cmd+Opt+[
1156:         commands.append(UIKeyCommand(
1157:             input: "[",
1158:             modifierFlags: [.command, .alternate],
1159:             action: #selector(handleFold)
1160:         ))
1161:         
1162:         // Unfold: Cmd+Opt+]
1163:         commands.append(UIKeyCommand(
1164:             input: "]",
1165:             modifierFlags: [.command, .alternate],
1166:             action: #selector(handleUnfold)
1167:         ))
1168:         
1169:         // Toggle Terminal: Cmd+J (not in standard system menus, safe to define here)
1170:         let toggleTerminalCmd = UIKeyCommand(
1171:             input: "j",
1172:             modifierFlags: .command,
1173:             action: #selector(handleToggleTerminal),
1174:             discoverabilityTitle: "Toggle Panel"
1175:         )
1176:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
1177:         commands.append(toggleTerminalCmd)
1178:         
1179:         // AI Assistant: Cmd+Shift+A (not conflicting with system Select All which is Cmd+A)
1180:         commands.append(UIKeyCommand(
1181:             input: "a",
1182:             modifierFlags: [.command, .shift],
1183:             action: #selector(handleShowAIAssistant),
1184:             discoverabilityTitle: "AI Assistant"
1185:         ))
1186:         
1187:         return commands
1188:     }
1189:     
1190:     @objc func handlePeekDefinition() {
1191:         onPeekDefinition?()
1192:     }
1193: 
1194:     @objc func handleGoToLine() {
1195:         onGoToLine?()
1196:     }
1197: 
1198:     @objc func handleTab() {
1199:         if onAcceptAutocomplete?() == true {
1200:             return


Found `handleTab` at line 1198. Let me read more to see the full implementation.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1198, "end_line": 1350}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1199-1350 of 2151)
────────────────────────────────────────
1199:         if onAcceptAutocomplete?() == true {
1200:             return
1201:         }
1202:         insertText("\t")
1203:     }
1204:     
1205:     @objc func handleEscape() {
1206:         if onDismissAutocomplete?() == true {
1207:             return
1208:         }
1209:         onEscape?()
1210:     }
1211:     
1212:     @objc func handleFold() {
1213:         onFold?()
1214:     }
1215:     
1216:     @objc func handleUnfold() {
1217:         onUnfold?()
1218:     }
1219: 
1220:     // MARK: - Undo / Redo
1221: 
1222:     @objc func handleUndo() {
1223:         undoManager?.undo()
1224:     }
1225: 
1226:     @objc func handleRedo() {
1227:         undoManager?.redo()
1228:     }
1229:     
1230:     // MARK: - App-Level Shortcut Handlers
1231:     
1232:     @objc func handleShowCommandPalette() {
1233:         NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1234:     }
1235:     
1236:     @objc func handleToggleTerminal() {
1237:         NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1238:     }
1239:     
1240:     @objc func handleShowAIAssistant() {
1241:         NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1242:     }
1243:     
1244:     @objc func handleToggleSidebar() {
1245:         NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
1246:     }
1247:     
1248:     @objc func handleShowQuickOpen() {
1249:         NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
1250:     }
1251:     
1252:     @objc func handleNewFile() {
1253:         NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
1254:     }
1255:     
1256:     @objc func handleSaveFile() {
1257:         NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
1258:     }
1259:     
1260:     @objc func handleCloseTab() {
1261:         NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
1262:     }
1263:     
1264:     @objc func handleFind() {
1265:         NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
1266:     }
1267:     
1268:     @objc func handleZoomIn() {
1269:         NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
1270:     }
1271:     
1272:     @objc func handleZoomOut() {
1273:         NotificationCenter.default.post(name: NSNotification.Name("ZoomOut"), object: nil)
1274:     }
1275:     
1276:     // MARK: - Custom Actions
1277:     
1278:     @objc private func goToDefinition(_ sender: Any?) {
1279:         onGoToDefinition?()
1280:     }
1281:     
1282:     @objc private func peekDefinition(_ sender: Any?) {
1283:         onPeekDefinition?()
1284:     }
1285:     
1286:     @objc private func findReferences(_ sender: Any?) {
1287:         onFindReferences?()
1288:     }
1289:     
1290:     @objc private func formatDocument(_ sender: Any?) {
1291:         onFormatDocument?()
1292:     }
1293:     
1294:     @objc private func toggleComment(_ sender: Any?) {
1295:         onToggleComment?()
1296:     }
1297:     
1298:     // MARK: - Menu Support
1299:     
1300:     override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
1301:         // Enable custom actions
1302:         if action == #selector(goToDefinition(_:)) {
1303:             return onGoToDefinition != nil
1304:         }
1305:         if action == #selector(peekDefinition(_:)) {
1306:             return onPeekDefinition != nil
1307:         }
1308:         if action == #selector(findReferences(_:)) {
1309:             return onFindReferences != nil
1310:         }
1311:         if action == #selector(formatDocument(_:)) {
1312:             return onFormatDocument != nil
1313:         }
1314:         if action == #selector(toggleComment(_:)) {
1315:             return onToggleComment != nil
1316:         }
1317:         
1318:         return super.canPerformAction(action, withSender: sender)
1319:     }
1320:     
1321:     override func buildMenu(with builder: UIMenuBuilder) {
1322:         super.buildMenu(with: builder)
1323:         
1324:         guard builder.menu(for: .text) != nil else { return }
1325:         
1326:         // Create custom menu items
1327:         let goToDefinitionAction = UIAction(
1328:             title: "Go to Definition",
1329:             image: UIImage(systemName: "arrow.forward.circle"),
1330:             identifier: UIAction.Identifier("com.vscode.goToDefinition"),
1331:             handler: { [weak self] _ in
1332:                 self?.goToDefinition(nil)
1333:             }
1334:         )
1335:         
1336:         let peekDefinitionAction = UIAction(
1337:             title: "Peek Definition",
1338:             image: UIImage(systemName: "eye"),
1339:             identifier: UIAction.Identifier("com.vscode.peekDefinition"),
1340:             handler: { [weak self] _ in
1341:                 self?.peekDefinition(nil)
1342:             }
1343:         )
1344:         
1345:         let findReferencesAction = UIAction(
1346:             title: "Find All References",
1347:             image: UIImage(systemName: "magnifyingglass"),
1348:             identifier: UIAction.Identifier("com.vscode.findReferences"),
1349:             handler: { [weak self] _ in
1350:                 self?.findReferences(nil)


I found the `handleTab` function. Let me read more to understand the EditorTextView class and find where it's defined.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1050, "end_line": 1200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1051-1200 of 2151)
────────────────────────────────────────
1051:         // 3. Draw Indent Guides (FEAT-039)
1052:         // We iterate visible lines and draw vertical lines for indentation
1053:         // Optimization: Only draw for visible range
1054: 
1055:         context.setLineWidth(1.0)
1056: 
1057:         // Respect editor tab size setting (default 4)
1058:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
1059:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
1060: 
1061:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
1062:         let indentWidth = spaceWidth * CGFloat(tabSize)
1063: 
1064:         // Determine active indent level for caret line (for indentGuideActive)
1065:         var activeIndentLevel: Int = 0
1066:         if let selected = selectedTextRange {
1067:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
1068:             let nsText = (self.text ?? "") as NSString
1069:             let safeLoc = min(max(0, caretPos), nsText.length)
1070:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
1071:             let caretLineText = nsText.substring(with: caretLineRange)
1072: 
1073:             var spaces = 0
1074:             for ch in caretLineText {
1075:                 if ch == " " { spaces += 1 }
1076:                 else if ch == "\t" { spaces += tabSize }
1077:                 else { break }
1078:             }
1079:             activeIndentLevel = spaces / tabSize
1080:         }
1081: 
1082:         // Iterate visible glyphs/lines
1083:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
1084:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
1085: 
1086:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
1087: 
1088:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
1089:             // Get text for this line
1090:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
1091:                   let text = self.text as NSString? else { return }
1092: 
1093:             let lineText = text.substring(with: range)
1094: 
1095:             // Calculate indentation level
1096:             var spaces = 0
1097:             for char in lineText {
1098:                 if char == " " { spaces += 1 }
1099:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
1100:                 else { break }
1101:             }
1102: 
1103:             let indentLevel = spaces / tabSize
1104:             guard indentLevel > 0 else { return }
1105: 
1106:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
1107: 
1108:             for i in 1...indentLevel {
1109:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
1110:                 let startPoint = CGPoint(x: x, y: rect.minY)
1111:                 let endPoint = CGPoint(x: x, y: rect.maxY)
1112: 
1113:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
1114:                 context.setStrokeColor(stroke.cgColor)
1115: 
1116:                 context.move(to: startPoint)
1117:                 context.addLine(to: endPoint)
1118:                 context.strokePath()
1119:             }
1120:         }
1121:     }
1122:     
1123:     override var keyCommands: [UIKeyCommand]? {
1124:         // NOTE: Only define text-editing specific shortcuts here.
1125:         // App-level shortcuts (Cmd+B, Cmd+P, Cmd+N, Cmd+S, Cmd+W, Cmd+F, etc.)
1126:         // are defined in the Menus/ folder via SwiftUI's .keyboardShortcut().
1127:         // See: KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
1128:         // Defining them here AND in Menus/ causes duplicate conflicts.
1129:         
1130:         var commands = super.keyCommands ?? []
1131:         
1132:         // Peek Definition: Option+D (editor-specific, not in menus)
1133:         commands.append(UIKeyCommand(
1134:             input: "d",
1135:             modifierFlags: .alternate,
1136:             action: #selector(handlePeekDefinition)
1137:         ))
1138: 
1139:         // NOTE: Cmd+G (Go to Line) is defined in GoMenuCommands.swift - DO NOT ADD HERE
1140: 
1141:         // Tab: accept autocomplete if visible, else insert tab
1142:         commands.append(UIKeyCommand(
1143:             input: "\t",
1144:             modifierFlags: [],
1145:             action: #selector(handleTab)
1146:         ))
1147:         
1148:         // Escape: dismiss autocomplete/peek if visible
1149:         commands.append(UIKeyCommand(
1150:             input: UIKeyCommand.inputEscape,
1151:             modifierFlags: [],
1152:             action: #selector(handleEscape)
1153:         ))
1154:         
1155:         // Fold: Cmd+Opt+[
1156:         commands.append(UIKeyCommand(
1157:             input: "[",
1158:             modifierFlags: [.command, .alternate],
1159:             action: #selector(handleFold)
1160:         ))
1161:         
1162:         // Unfold: Cmd+Opt+]
1163:         commands.append(UIKeyCommand(
1164:             input: "]",
1165:             modifierFlags: [.command, .alternate],
1166:             action: #selector(handleUnfold)
1167:         ))
1168:         
1169:         // Toggle Terminal: Cmd+J (not in standard system menus, safe to define here)
1170:         let toggleTerminalCmd = UIKeyCommand(
1171:             input: "j",
1172:             modifierFlags: .command,
1173:             action: #selector(handleToggleTerminal),
1174:             discoverabilityTitle: "Toggle Panel"
1175:         )
1176:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
1177:         commands.append(toggleTerminalCmd)
1178:         
1179:         // AI Assistant: Cmd+Shift+A (not conflicting with system Select All which is Cmd+A)
1180:         commands.append(UIKeyCommand(
1181:             input: "a",
1182:             modifierFlags: [.command, .shift],
1183:             action: #selector(handleShowAIAssistant),
1184:             discoverabilityTitle: "AI Assistant"
1185:         ))
1186:         
1187:         return commands
1188:     }
1189:     
1190:     @objc func handlePeekDefinition() {
1191:         onPeekDefinition?()
1192:     }
1193: 
1194:     @objc func handleGoToLine() {
1195:         onGoToLine?()
1196:     }
1197: 
1198:     @objc func handleTab() {
1199:         if onAcceptAutocomplete?() == true {
1200:             return


Now let me search for where the autocomplete callback is implemented and trace through to the AutocompleteManager.

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
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift (lines 1-357 of 357)
────────────────────────────────────────
1: import SwiftUI
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
201:     func hideSuggestions() {
202:         apply(items: [])
203:     }
204: 
205:     /// Optional helper for inserting the currently-selected suggestion into the text.
206:     /// (Not wired by default; added as plumbing for FEAT-045 dropdown selection.)
207:     func commitCurrentSuggestion(into text: inout String, cursorPosition: inout Int) {
208:         guard let suggestion = suggestionItems[safe: selectedIndex], showSuggestions else { return }
209:         let safeCursor = max(0, min(cursorPosition, text.count))
210:         guard let context = completionContext(in: text, cursorPosition: safeCursor) else { return }
211: 
212:         let replacementRange = context.replacementRange
213:         text.replaceSubrange(replacementRange, with: suggestion.insertText)
214: 
215:         // Move cursor to end of inserted text.
216:         let newCursorOffset = text.distance(from: text.startIndex, to: replacementRange.lowerBound) + suggestion.insertText.count
217:         cursorPosition = min(newCursorOffset, text.count)
218: 
219:         hideSuggestions()
220:     }
221: 
222:     // MARK: - Internals
223: 
224:     private struct CompletionContext {
225:         let prefix: String
226:         let replacementRange: Range<String.Index>
227:         let isMemberCompletion: Bool
228:         let memberBase: String?
229:     }
230: 
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


Now let me search for where the onAcceptAutocomplete callback is set up and where commitCurrentSuggestion is called.

>>>TOOL search
{"query": "commitCurrentSuggestion", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "commitCurrentSuggestion"


>>>TOOL search
{"query": "onAcceptAutocomplete", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "onAcceptAutocomplete"


>>>TOOL search
{"query": "Accept.*autocomplete", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "Accept.*autocomplete"


>>>TOOL search
{"query": "acceptAutocomplete", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "acceptAutocomplete"


>>>TOOL search
{"query": "AcceptAutocomplete", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "AcceptAutocomplete"


Let me look at the ContentView.swift to see how the autocomplete callback is wired up.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 1, "end_line": 200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 2-200 of 1079)
────────────────────────────────────────
2: import UIKit
3: import UniformTypeIdentifiers
4: 
5: // MARK: - Helper Functions
6: // Moved to Extensions/FileHelpers.swift
7: 
8: // MARK: - Main Content View
9: 
10: struct ContentView: View {
11:     @EnvironmentObject var editorCore: EditorCore
12:     @StateObject private var fileNavigator = FileSystemNavigator()
13:     @StateObject private var themeManager = ThemeManager.shared
14:     
15:     @State private var showingDocumentPicker = false
16:     @State private var showingFolderPicker = false
17:     @State private var showSettings = false
18:     @State private var showTerminal = false
19:     @State private var terminalHeight: CGFloat = 200
20:     @State private var selectedSidebarTab = 0
21:     @State private var pendingTrustURL: URL?
22:     @State private var windowTitle: String = "VS Code"
23:     
24:     @StateObject private var trustManager = WorkspaceTrustManager.shared
25:     
26:     private var theme: Theme { themeManager.currentTheme }
27:     
28:     var body: some View {
29:         ZStack {
30:             VStack(spacing: 0) {
31:                 HStack(spacing: 0) {
32:                     IDEActivityBar(editorCore: editorCore, selectedTab: $selectedSidebarTab, showSettings: $showSettings, showTerminal: $showTerminal)
33:                     
34:                     if editorCore.showSidebar {
35:                         sidebarContent.frame(width: editorCore.sidebarWidth)
36:                     }
37:                     
38:                     VStack(spacing: 0) {
39:                         IDETabBar(editorCore: editorCore, theme: theme)
40:                         
41:                         if let tab = editorCore.activeTab {
42:                             IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
43:                                 .id(tab.id)  // Force view recreation when tab changes
44:                         } else {
45:                             IDEWelcomeView(editorCore: editorCore, showFolderPicker: $showingFolderPicker, theme: theme)
46:                         }
47:                         
48:                         StatusBarView(editorCore: editorCore)
49:                     }
50:                 }
51:                 
52:                 if showTerminal {
53:                     PanelView(isVisible: $showTerminal, height: $terminalHeight)
54:                 }
55:             }
56:             .background(theme.editorBackground)
57:             
58:             // Overlays - Command Palette (Cmd+Shift+P)
59:             if editorCore.showCommandPalette {
60:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showCommandPalette = false }
61:                 CommandPaletteView(editorCore: editorCore, showSettings: $showSettings, showTerminal: $showTerminal)
62:             }
63:             
64:             // Quick Open (Cmd+P)
65:             if editorCore.showQuickOpen {
66:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showQuickOpen = false }
67:                 QuickOpenView(editorCore: editorCore, fileNavigator: fileNavigator)
68:             }
69:             
70:             // Go To Symbol (Cmd+Shift+O)
71:             if editorCore.showGoToSymbol {
72:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToSymbol = false }
73:                 GoToSymbolView(editorCore: editorCore, onGoToLine: { _ in })
74:             }
75:             
76:             // AI Assistant
77:             if editorCore.showAIAssistant {
78:                 HStack { Spacer(); IDEAIAssistant(editorCore: editorCore, theme: theme).frame(width: 400, height: 500).padding() }
79:             }
80:             
81:             // Go To Line (Ctrl+G)
82:             if editorCore.showGoToLine {
83:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToLine = false }
84:                 GoToLineView(isPresented: $editorCore.showGoToLine, onGoToLine: { _ in })
85:             }
86:             
87:             // Workspace Trust Dialog
88:             if let trustURL = pendingTrustURL {
89:                 Color.black.opacity(0.4).ignoresSafeArea()
90:                 WorkspaceTrustDialog(workspaceURL: trustURL, onTrust: {
91:                     trustManager.trust(url: trustURL)
92:                     finishOpeningWorkspace(trustURL)
93:                     pendingTrustURL = nil
94:                 }, onCancel: {
95:                     pendingTrustURL = nil
96:                 })
97:             }
98:         }
99:         .sheet(isPresented: $showingDocumentPicker) { IDEDocumentPicker(editorCore: editorCore) }
100:         .sheet(isPresented: $showingFolderPicker) {
101:             IDEFolderPicker(fileNavigator: fileNavigator) { url in
102:                 if trustManager.isTrusted(url: url) {
103:                     finishOpeningWorkspace(url)
104:                 } else {
105:                     pendingTrustURL = url
106:                 }
107:             }
108:         }
109:         .sheet(isPresented: $showSettings) { SettingsView(themeManager: themeManager) }
110:         .onChange(of: editorCore.showFilePicker) { show in showingDocumentPicker = show }
111:         .onChange(of: editorCore.activeTab?.fileName) { newFileName in
112:             updateWindowTitle()
113:         }
114:         .onChange(of: editorCore.tabs.count) { _ in
115:             updateWindowTitle()
116:         }
117:         .onChange(of: editorCore.activeTabId) { _ in
118:             updateWindowTitle()
119:         }
120:         .onChange(of: editorCore.activeTab?.isUnsaved) { _ in
121:             updateWindowTitle()
122:         }
123:         .onAppear {
124:             // Wire up EditorCore -> FileSystemNavigator so save operations can route through it.
125:             editorCore.fileNavigator = fileNavigator
126:             updateWindowTitle()
127:         }
128:         // MARK: - Notification Handlers for Menu Keyboard Shortcuts
129:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowCommandPalette"))) { _ in
130:             editorCore.showCommandPalette = true
131:         }
132:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleTerminal"))) { _ in
133:             showTerminal.toggle()
134:         }
135:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleSidebar"))) { _ in
136:             editorCore.toggleSidebar()
137:         }
138:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowQuickOpen"))) { _ in
139:             editorCore.showQuickOpen = true
140:         }
141:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToSymbol"))) { _ in
142:             editorCore.showGoToSymbol = true
143:         }
144:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToLine"))) { _ in
145:             editorCore.showGoToLine = true
146:         }
147:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAIAssistant"))) { _ in
148:             editorCore.showAIAssistant = true
149:         }
150:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewFile"))) { _ in
151:             editorCore.addTab()
152:         }
153:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveFile"))) { _ in
154:             editorCore.saveActiveTab()
155:         }
156:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CloseTab"))) { _ in
157:             if let id = editorCore.activeTabId { editorCore.closeTab(id: id) }
158:         }
159:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowFind"))) { _ in
160:             editorCore.showSearch = true
161:         }
162:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ZoomIn"))) { _ in
163:             editorCore.zoomIn()
164:         }
165:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ZoomOut"))) { _ in
166:             editorCore.zoomOut()
167:         }
168:         .environmentObject(themeManager)
169:         .environmentObject(editorCore)
170:     }
171:     
172:     private func finishOpeningWorkspace(_ url: URL) {
173:         fileNavigator.loadFileTree(at: url)
174:         Task { @MainActor in
175:             LaunchManager.shared.setWorkspaceRoot(url)
176:             GitManager.shared.setWorkingDirectory(url)
177:         }
178:     }
179:     
180:     private func updateWindowTitle() {
181:         if let activeTab = editorCore.activeTab {
182:             let fileName = activeTab.fileName
183:             let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
184:             windowTitle = "\(unsavedIndicator)\(fileName) - VS Code"
185:         } else if !editorCore.tabs.isEmpty {
186:             windowTitle = "VS Code"
187:         } else {
188:             windowTitle = "Welcome - VS Code"
189:         }
190:         
191:         // Notify the app of the title change
192:         NotificationCenter.default.post(
193:             name: NSNotification.Name("WindowTitleDidChange"),
194:             object: nil,
195:             userInfo: ["title": windowTitle]
196:         )
197:     }
198:     
199:     @ViewBuilder
200:     private var sidebarContent: some View {


>>>TOOL search
{"query": "IDEEditorView", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "IDEEditorView"


>>>TOOL search
{"query": "SyntaxHighlightingTextView", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "SyntaxHighlightingTextView"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 970, "end_line": 1100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 971-1100 of 2151)
────────────────────────────────────────
971:             }
972: 
973:             guard let match = matchIndex else { return }
974: 
975:             let r1 = NSRange(location: idx, length: 1)
976:             let r2 = NSRange(location: match, length: 1)
977: 
978:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
979:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
980: 
981:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
982:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
983: 
984:             bracketHighlightRanges = [r1, r2]
985:         }
986:     }
987: }
988: 
989: // Custom text view to handle key commands, indent guides, and line highlighting
990: class EditorTextView: MultiCursorTextView {
991:     var onPeekDefinition: (() -> Void)?
992:     var onEscape: (() -> Void)?
993:     var onGoToLine: (() -> Void)?
994:     
995:     // Custom action closures for context menu
996:     var onGoToDefinition: (() -> Void)?
997:     var onFindReferences: (() -> Void)?
998:     var onFormatDocument: (() -> Void)?
999:     var onToggleComment: (() -> Void)?
1000:     var onFold: (() -> Void)?
1001:     var onUnfold: (() -> Void)?
1002: 
1003:     // Autocomplete key handling hooks are inherited from MultiCursorTextView
1004:     
1005:     // FEAT-039 & FEAT-043
1006:     private var indentGuideColor: UIColor = .separator
1007:     private var activeIndentGuideColor: UIColor = .label
1008:     private var currentLineHighlightColor: UIColor = .clear
1009:     
1010:     override init(frame: CGRect, textContainer: NSTextContainer?) {
1011:         super.init(frame: frame, textContainer: textContainer)
1012:         setup()
1013:     }
1014:     
1015:     required init?(coder: NSCoder) {
1016:         super.init(coder: coder)
1017:         setup()
1018:     }
1019:     
1020:     private func setup() {
1021:         // Ensure we redraw when bounds/selection change
1022:         contentMode = .redraw
1023:     }
1024:     
1025:     func updateThemeColors(theme: Theme) {
1026:         self.indentGuideColor = UIColor(theme.indentGuide)
1027:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
1028:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
1029:         setNeedsDisplay()
1030:     }
1031:     
1032:     override func draw(_ rect: CGRect) {
1033:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
1034:             super.draw(rect)
1035:             return
1036:         }
1037:         
1038:         // 1. Draw Current Line Highlight (FEAT-043)
1039:         if let selectedRange = selectedTextRange {
1040:             // Get the line rect for the cursor position
1041:             let caretRect = self.caretRect(for: selectedRange.start)
1042:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
1043:             
1044:             context.setFillColor(currentLineHighlightColor.cgColor)
1045:             context.fill(lineRect)
1046:         }
1047:         
1048:         // 2. Draw Text (super implementation)
1049:         super.draw(rect)
1050:         
1051:         // 3. Draw Indent Guides (FEAT-039)
1052:         // We iterate visible lines and draw vertical lines for indentation
1053:         // Optimization: Only draw for visible range
1054: 
1055:         context.setLineWidth(1.0)
1056: 
1057:         // Respect editor tab size setting (default 4)
1058:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
1059:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
1060: 
1061:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
1062:         let indentWidth = spaceWidth * CGFloat(tabSize)
1063: 
1064:         // Determine active indent level for caret line (for indentGuideActive)
1065:         var activeIndentLevel: Int = 0
1066:         if let selected = selectedTextRange {
1067:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
1068:             let nsText = (self.text ?? "") as NSString
1069:             let safeLoc = min(max(0, caretPos), nsText.length)
1070:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
1071:             let caretLineText = nsText.substring(with: caretLineRange)
1072: 
1073:             var spaces = 0
1074:             for ch in caretLineText {
1075:                 if ch == " " { spaces += 1 }
1076:                 else if ch == "\t" { spaces += tabSize }
1077:                 else { break }
1078:             }
1079:             activeIndentLevel = spaces / tabSize
1080:         }
1081: 
1082:         // Iterate visible glyphs/lines
1083:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
1084:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
1085: 
1086:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
1087: 
1088:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
1089:             // Get text for this line
1090:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
1091:                   let text = self.text as NSString? else { return }
1092: 
1093:             let lineText = text.substring(with: range)
1094: 
1095:             // Calculate indentation level
1096:             var spaces = 0
1097:             for char in lineText {
1098:                 if char == " " { spaces += 1 }
1099:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
1100:                 else { break }


>>>TOOL search
{"query": "class MultiCursorTextView", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class MultiCursorTextView"


>>>TOOL search
{"query": "MultiCursorTextView", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "MultiCursorTextView"


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
(cached)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 1-266 of 266)
────────────────────────────────────────
1: //  MultiCursorTextView.swift
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
30:     /// Cursor appearance
31:     private let cursorWidth: CGFloat = 2
32:     private let cursorColor = UIColor.systemBlue
33:     private let secondaryCursorColor = UIColor.systemCyan
34:     private let selectionColor = UIColor.systemBlue.withAlphaComponent(0.3)
35:     private let secondarySelectionColor = UIColor.systemCyan.withAlphaComponent(0.25)
36: 
37:     override init(frame: CGRect, textContainer: NSTextContainer?) {
38:         super.init(frame: frame, textContainer: textContainer)
39:         setupCursorBlinking()
40:     }
41: 
42:     required init?(coder: NSCoder) {
43:         super.init(coder: coder)
44:         setupCursorBlinking()
45:     }
46: 
47:     deinit {
48:         blinkTimer?.invalidate()
49:     }
50: 
51:     private func setupCursorBlinking() {
52:         blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
53:             self?.cursorVisible.toggle()
54:             self?.updateCursorVisibility()
55:         }
56:     }
57: 
58:     private func updateCursorVisibility() {
59:         let alpha: Float = cursorVisible ? 1.0 : 0.0
60:         cursorLayers.forEach { $0.opacity = alpha }
61:     }
62: 
63:     /// Updates the display of all cursors and selections
64:     func updateCursorDisplay() {
65:         // Remove existing cursor and selection layers
66:         cursorLayers.forEach { $0.removeFromSuperlayer() }
67:         cursorLayers.removeAll()
68:         selectionLayers.forEach { $0.removeFromSuperlayer() }
69:         selectionLayers.removeAll()
70: 
71:         guard let editorCore = editorCore else { return }
72:         let cursors = editorCore.multiCursorState.cursors
73: 
74:         // Only show additional cursors if we have multiple
75:         guard cursors.count > 1 else { return }
76: 
77:         // Draw each cursor (skip the primary one as UITextView handles it)
78:         for (index, cursor) in cursors.enumerated() {
79:             // Draw selection if present
80:             if let selectionRange = cursor.selectionRange {
81:                 drawSelection(for: selectionRange, isPrimary: cursor.isPrimary, index: index)
82:             }
83: 
84:             // Draw cursor line (skip primary cursor as system handles it)
85:             if !cursor.isPrimary {
86:                 drawCursor(at: cursor.position, isPrimary: false, index: index)
87:             }
88:         }
89:     }
90: 
91:     private func drawCursor(at position: Int, isPrimary: Bool, index: Int) {
92:         guard let textPosition = self.position(from: beginningOfDocument, offset: position) else { return }
93: 
94:         let caretRect = self.caretRect(for: textPosition)
95: 
96:         let cursorLayer = CALayer()
97:         cursorLayer.backgroundColor = (isPrimary ? cursorColor : secondaryCursorColor).cgColor
98:         cursorLayer.frame = CGRect(
99:             x: caretRect.origin.x,
100:             y: caretRect.origin.y,
101:             width: cursorWidth,
102:             height: caretRect.height
103:         )
104:         cursorLayer.cornerRadius = 1
105: 
106:         layer.addSublayer(cursorLayer)
107:         cursorLayers.append(cursorLayer)
108:     }
109: 
110:     private func drawSelection(for range: NSRange, isPrimary: Bool, index: Int) {
111:         guard let start = position(from: beginningOfDocument, offset: range.location),
112:               let end = position(from: beginningOfDocument, offset: range.location + range.length),
113:               let textRange = self.textRange(from: start, to: end) else { return }
114: 
115:         let selectionRects = selectionRects(for: textRange)
116: 
117:         for rect in selectionRects {
118:             let selectionLayer = CALayer()
119:             selectionLayer.backgroundColor = (isPrimary ? selectionColor : secondarySelectionColor).cgColor
120:             selectionLayer.frame = rect.rect
121: 
122:             // Insert behind text
123:             if let textLayer = layer.sublayers?.first {
124:                 layer.insertSublayer(selectionLayer, below: textLayer)
125:             } else {
126:                 layer.addSublayer(selectionLayer)
127:             }
128:             selectionLayers.append(selectionLayer)
129:         }
130:     }
131: 
132:     // MARK: - Text Input Handling for Multi-Cursor
133: 
134:     override func insertText(_ text: String) {
135:         guard let editorCore = editorCore,
136:               editorCore.multiCursorState.isMultiCursor else {
137:             super.insertText(text)
138:             return
139:         }
140: 
141:         // Handle multi-cursor insert
142:         var content = self.text ?? ""
143:         editorCore.multiCursorState.insertText(text, in: &content)
144: 
145:         // Update text view
146:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
147:         self.text = content
148: 
149:         // Position the main cursor
150:         if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
151:             selectedTextRange = textRange(from: newPosition, to: newPosition)
152:         }
153: 
154:         // Trigger text change notification
155:         delegate?.textViewDidChange?(self)
156: 
157:         updateCursorDisplay()
158:     }
159: 
160:     override func deleteBackward() {
161:         guard let editorCore = editorCore,
162:               editorCore.multiCursorState.isMultiCursor else {
163:             super.deleteBackward()
164:             return
165:         }
166: 
167:         // Handle multi-cursor delete
168:         var content = self.text ?? ""
169:         editorCore.multiCursorState.deleteBackward(in: &content)
170: 
171:         // Update text view
172:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
173:         self.text = content
174: 
175:         // Position the main cursor
176:         if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
177:             selectedTextRange = textRange(from: newPosition, to: newPosition)
178:         }
179: 
180:         // Trigger text change notification
181:         delegate?.textViewDidChange?(self)
182: 
183:         updateCursorDisplay()
184:     }
185: 
186:     // MARK: - Layout Updates
187: 
188:     override func layoutSubviews() {
189:         super.layoutSubviews()
190:         // Refresh cursor positions when layout changes
191:         updateCursorDisplay()
192:     }
193: 
194:     override var contentOffset: CGPoint {
195:         didSet {
196:             // Update cursor positions when scrolling
197:             updateCursorDisplay()
198:         }
199:     }
200: }
201: 
202: // MARK: - Key Commands for Multi-Cursor + Autocomplete
203: // NOTE: App-level shortcuts are defined in Menus/ folder only.
204: // See: KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
205: // DO NOT define Cmd+D, Cmd+Shift+L, Cmd+G here - they are in SelectionMenuCommands/GoMenuCommands
206: 
207: extension MultiCursorTextView {
208: 
209:     override var keyCommands: [UIKeyCommand]? {
210:         var commands = super.keyCommands ?? []
211: 
212:         // Tab: accept autocomplete (if showing), else insert tab
213:         // This is editor-specific and NOT a menu command
214:         commands.append(UIKeyCommand(
215:             title: "Accept Suggestion",
216:             action: #selector(tabAcceptAutocomplete),
217:             input: "\t",
218:             modifierFlags: []
219:         ))
220: 
221:         // NOTE: Cmd+D (Add Next Occurrence) is in SelectionMenuCommands.swift
222:         // NOTE: Cmd+Shift+L (Select All Occurrences) is in SelectionMenuCommands.swift
223:         // NOTE: Cmd+G (Go to Line) is in GoMenuCommands.swift
224: 
225:         // Escape: Dismiss autocomplete if visible, else exit multi-cursor mode
226:         // This is editor-specific and NOT a menu command
227:         commands.append(UIKeyCommand(
228:             title: "Escape",
229:             action: #selector(escapeKeyPressed),
230:             input: UIKeyCommand.inputEscape,
231:             modifierFlags: []
232:         ))
233: 
234:         return commands
235:     }
236: 
237:     @objc private func tabAcceptAutocomplete() {
238:         if onAcceptAutocomplete?() == true {
239:             return
240:         }
241:         insertText("\t")
242:     }
243: 
244:     @objc private func addNextOccurrence() {
245:         editorCore?.addNextOccurrence()
246:         updateCursorDisplay()
247:     }
248: 
249:     @objc private func selectAllOccurrences() {
250:         editorCore?.selectAllOccurrences()
251:         updateCursorDisplay()
252:     }
253: 
254:     @objc private func goToLine() {
255:         editorCore?.showGoToLine = true
256:     }
257: 
258:     @objc private func escapeKeyPressed() {
259:         if onDismissAutocomplete?() == true {
260:             return
261:         }
262:         editorCore?.escapeMultiCursor()
263:         updateCursorDisplay()
264:     }
265: }
266: 


Now let me search for where the onAcceptAutocomplete callback is set and what logic it performs:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 200, "end_line": 400}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 201-400 of 1079)
────────────────────────────────────────
201:         switch selectedSidebarTab {
202:         case 0:
203:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
204:         case 1:
205:             SidebarSearchView(theme: theme)
206:         case 2:
207:             GitView()
208:         case 3:
209:             DebugView()
210:         default:
211:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
212:         }
213:     }
214: }
215: 
216: // MARK: - Activity Bar
217: 
218: 
219: 
220: struct BarButton: View {
221:     let icon: String
222:     let isSelected: Bool
223:     let theme: Theme
224:     let action: () -> Void
225:     
226:     var body: some View {
227:         Button(action: action) {
228:             Image(systemName: icon)
229:                 .font(.system(size: 22))
230:                 .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
231:                 .frame(width: 48, height: 48)
232:         }
233:     }
234: }
235: 
236: // MARK: - Sidebar with Real File System
237: 
238: struct IDESidebarFiles: View {
239:     @ObservedObject var editorCore: EditorCore
240:     @ObservedObject var fileNavigator: FileSystemNavigator
241:     @Binding var showFolderPicker: Bool
242:     let theme: Theme
243:     
244:     var body: some View {
245:         VStack(alignment: .leading, spacing: 0) {
246:             HStack {
247:                 Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
248:                 Spacer()
249:                 Button(action: { showFolderPicker = true }) {
250:                     Image(systemName: "folder.badge.plus").font(.caption)
251:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
252:                 Button(action: { editorCore.showFilePicker = true }) {
253:                     Image(systemName: "doc.badge.plus").font(.caption)
254:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
255:                 if fileNavigator.fileTree != nil {
256:                     Button(action: { fileNavigator.refreshFileTree() }) {
257:                         Image(systemName: "arrow.clockwise").font(.caption)
258:                     }.foregroundColor(theme.sidebarForeground.opacity(0.7))
259:                 }
260:             }.padding(.horizontal, 12).padding(.vertical, 8)
261:             
262:             ScrollView {
263:                 VStack(alignment: .leading, spacing: 2) {
264:                     if let tree = fileNavigator.fileTree {
265:                         FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
266:                     } else {
267:                         DemoFileTree(editorCore: editorCore, theme: theme)
268:                     }
269:                 }.padding(.horizontal, 8)
270:             }
271:         }.background(theme.sidebarBackground)
272:     }
273: }
274: 
275: struct RealFileTreeView: View {
276:     let node: FileTreeNode
277:     let level: Int
278:     @ObservedObject var fileNavigator: FileSystemNavigator
279:     @ObservedObject var editorCore: EditorCore
280:     let theme: Theme
281:     
282:     var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
283:     
284:     var body: some View {
285:         VStack(alignment: .leading, spacing: 2) {
286:             HStack(spacing: 4) {
287:                 if node.isDirectory {
288:                     Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
289:                         .font(.caption2).frame(width: 12)
290:                         .foregroundColor(theme.sidebarForeground.opacity(0.6))
291:                         .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
292:                 } else {
293:                     Spacer().frame(width: 12)
294:                 }
295:                 Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
296:                     .font(.caption)
297:                     .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
298:                 Text(node.name).font(.system(.caption)).lineLimit(1)
299:                     .foregroundColor(theme.sidebarForeground)
300:                 Spacer()
301:             }
302:             .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
303:             .contentShape(Rectangle())
304:             .onTapGesture {
305:                 if node.isDirectory {
306:                     fileNavigator.toggleExpanded(path: node.url.path)
307:                 } else {
308:                     editorCore.openFile(from: node.url)
309:                 }
310:             }
311:             
312:             if isExpanded && node.isDirectory {
313:                 ForEach(node.children) { child in
314:                     RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
315:                 }
316:             }
317:         }
318:     }
319: }
320: 
321: struct DemoFileTree: View {
322:     @ObservedObject var editorCore: EditorCore
323:     let theme: Theme
324:     
325:     var body: some View {
326:         VStack(alignment: .leading, spacing: 4) {
327:             Text("Open a folder to browse files")
328:                 .font(.caption)
329:                 .foregroundColor(theme.sidebarForeground.opacity(0.6))
330:                 .padding(.vertical, 8)
331:             
332:             DemoFileRow(name: "main.swift", editorCore: editorCore, theme: theme)
333:             DemoFileRow(name: "ContentView.swift", editorCore: editorCore, theme: theme)
334:             DemoFileRow(name: "README.md", editorCore: editorCore, theme: theme)
335:         }
336:     }
337: }
338: 
339: struct DemoFileRow: View {
340:     let name: String
341:     @ObservedObject var editorCore: EditorCore
342:     let theme: Theme
343:     
344:     var body: some View {
345:         HStack(spacing: 4) {
346:             Spacer().frame(width: 12)
347:             Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
348:             Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
349:             Spacer()
350:         }
351:         .padding(.vertical, 4)
352:         .contentShape(Rectangle())
353:         .onTapGesture {
354:             editorCore.addTab(fileName: name, content: "// \(name)\n\n")
355:         }
356:     }
357: }
358: 
359: // MARK: - Tab Bar
360: 
361: struct IDETabBar: View {
362:     @ObservedObject var editorCore: EditorCore
363:     let theme: Theme
364:     
365:     var body: some View {
366:         ScrollView(.horizontal, showsIndicators: false) {
367:             HStack(spacing: 0) {
368:                 ForEach(editorCore.tabs) { tab in
369:                     IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
370:                 }
371:                 Button(action: { editorCore.addTab() }) {
372:                     Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
373:                 }
374:             }.padding(.horizontal, 4)
375:         }.frame(height: 36).background(theme.tabBarBackground)
376:     }
377: }
378: 
379: struct IDETabItem: View {
380:     let tab: Tab
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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift", "start_line": 400, "end_line": 600}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 401-600 of 1079)
────────────────────────────────────────
401: 
402: // MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
403: 
404: struct IDEEditorView: View {
405:     @ObservedObject var editorCore: EditorCore
406:     let tab: Tab
407:     let theme: Theme
408: 
409:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
410:     @State private var text: String = ""
411:     @State private var scrollPosition: Int = 0
412:     @State private var scrollOffset: CGFloat = 0
413:     @State private var totalLines: Int = 1
414:     @State private var visibleLines: Int = 20
415:     @State private var currentLineNumber: Int = 1
416:     @State private var currentColumn: Int = 1
417:     @State private var cursorIndex: Int = 0
418:     @State private var lineHeight: CGFloat = 17
419:     @State private var requestedCursorIndex: Int? = nil
420:     @State private var requestedLineSelection: Int? = nil
421: 
422:     @StateObject private var autocomplete = AutocompleteManager()
423:     @State private var showAutocomplete = false
424:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
425:     @StateObject private var findViewModel = FindViewModel()
426:     
427:     var body: some View {
428:         VStack(spacing: 0) {
429:             // Find/Replace bar
430:             if editorCore.showSearch {
431:                 FindReplaceView(viewModel: findViewModel)
432:                     .background(theme.tabBarBackground)
433:             }
434:             
435:             BreadcrumbsView(editorCore: editorCore, tab: tab)
436:             
437:             GeometryReader { geometry in
438:                 ZStack(alignment: .topLeading) {
439:                 HStack(spacing: 0) {
440:                     if lineNumbersStyle != "off" {
441:                         LineNumbersWithFolding(
442:                             fileId: tab.url?.path ?? tab.fileName,
443:                             totalLines: totalLines,
444:                             currentLine: currentLineNumber,
445:                             scrollOffset: scrollOffset,
446:                             lineHeight: lineHeight,
447:                             requestedLineSelection: $requestedLineSelection,
448:                             foldingManager: foldingManager,
449:                             theme: theme
450:                         )
451:                         .frame(width: 60)
452:                         .background(theme.sidebarBackground.opacity(0.5))
453:                     }
454:                     
455:                     if tab.fileName.hasSuffix(".json") {
456:                         // JSON Tree View for .json files
457:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
458:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
459:                             .background(theme.editorBackground)
460:                     } else {
461:                         SyntaxHighlightingTextView(
462:                             text: $text,
463:                             filename: tab.fileName,
464:                             scrollPosition: $scrollPosition,
465:                             scrollOffset: $scrollOffset,
466:                             totalLines: $totalLines,
467:                             visibleLines: $visibleLines,
468:                             currentLineNumber: $currentLineNumber,
469:                             currentColumn: $currentColumn,
470:                             cursorIndex: $cursorIndex,
471:                             lineHeight: $lineHeight,
472:                             isActive: true,
473:                             fontSize: editorCore.editorFontSize,
474:                             requestedLineSelection: $requestedLineSelection,
475:                             requestedCursorIndex: $requestedCursorIndex,
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
561:             }
562:         }
563:         }
564:         .onAppear {
565:             text = tab.content
566:             foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
567:         }
568:         .onChange(of: tab.id) { _ in
569:             text = tab.content
570:             foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
571:         }
572:         .onChange(of: currentLineNumber) { line in
573:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
574:         }
575:         .onChange(of: currentColumn) { col in
576:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
577:         }
578:         .onAppear {
579:             findViewModel.editorCore = editorCore
580:         }
581:     }
582:     
583:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
584: }
585: 
586: // MARK: - Line Numbers with Folding
587: 
588: struct LineNumbersWithFolding: View {
589:     let fileId: String
590:     let totalLines: Int
591:     let currentLine: Int
592:     let scrollOffset: CGFloat
593:     let lineHeight: CGFloat
594:     @Binding var requestedLineSelection: Int?
595:     @ObservedObject var foldingManager: CodeFoldingManager
596:     @ObservedObject private var debugManager = DebugManager.shared
597:     let theme: Theme
598: 
599:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
600: 


⛔ ABORTED by user



⛔ ABORTED by user
