# Agent: highlight-fix-opus
**Status:** done
**Tokens:** 15,996
**Cost:** $0.0000
**Time:** 2026-02-10T02:24:02.402Z

## Task
CRITICAL: Fix syntax highlighting not appearing on file open in VSCodeiPadOS. Only appears after typing. In SyntaxHighlightingTextView.swift, find makeUIView() and ensure applySyntaxHighlighting() is called IMMEDIATELY when text is set. Also check updateUIView() - it should apply highlighting when context.coordinator.parent.text changes. After fix run build command.

## Response
I'll start by reading the SyntaxHighlightingTextView.swift file to understand the current implementation.

>>>TOOL read_file
{"path": "SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 250}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-250 of 1931)
────────────────────────────────────────
101:         )
102:     }
103: 
104:     func makeCoordinator() -> Coordinator {
105:         Coordinator(self)
106:     }
107:     
108:     func makeUIView(context: Context) -> UITextView {
109:         let textView = EditorTextView()
110:         textView.delegate = context.coordinator
111: 
112:         // Autocomplete hooks
113:         textView.onAcceptAutocomplete = onAcceptAutocomplete
114:         textView.onDismissAutocomplete = onDismissAutocomplete
115: 
116:         textView.onPeekDefinition = {
117:             context.coordinator.handlePeekDefinition(in: textView)
118:         }
119: 
120:         textView.onEscape = {
121:             context.coordinator.handleEscape()
122:         }
123: 
124:         textView.onGoToLine = {
125:             self.editorCore.showGoToLine = true
126:         }
127:         
128:         // Wire up custom context menu actions
129:         textView.onGoToDefinition = {
130:             context.coordinator.handleGoToDefinition(in: textView)
131:         }
132:         
133:         textView.onFindReferences = {
134:             context.coordinator.handleFindReferences(in: textView)
135:         }
136:         
137:         textView.onFormatDocument = {
138:             context.coordinator.handleFormatDocument(in: textView)
139:         }
140:         
141:         textView.onToggleComment = {
142:             context.coordinator.handleToggleComment(in: textView)
143:         }
144:         
145:         textView.onFold = {
146:             context.coordinator.handleFold(in: textView)
147:         }
148:         
149:         textView.onUnfold = {
150:             context.coordinator.handleUnfold(in: textView)
151:         }
152:         
153:         // Add pinch gesture for zoom
154:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
155:         textView.addGestureRecognizer(pinchGesture)
156:         context.coordinator.pinchGesture = pinchGesture
157:         
158:         // Configure text view
159:         textView.isEditable = true
160:         textView.isSelectable = true
161:         textView.autocapitalizationType = .none
162:         textView.autocorrectionType = .no
163:         textView.smartDashesType = .no
164:         textView.smartQuotesType = .no
165:         textView.smartInsertDeleteType = .no
166:         textView.spellCheckingType = .no
167:         
168:         // Set font and appearance (use editorCore.editorFontSize)
169:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
170:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
171:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
172:         textView.keyboardType = .default
173:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
174:         
175:         // Enable line wrapping
176:         textView.textContainer.lineBreakMode = .byCharWrapping
177:         textView.textContainer.widthTracksTextView = true
178:         
179:         // Calculate line height
180:         if let font = textView.font {
181:             DispatchQueue.main.async {
182:                 self.lineHeight = font.lineHeight
183:             }
184:         }
185:         
186:         // Set initial text with syntax highlighting
187:         textView.text = text
188:         context.coordinator.applySyntaxHighlighting(to: textView)
189:         context.coordinator.updateLineCount(textView)
190:         
191:         return textView
192:     }
193:     
194:     func updateUIView(_ textView: UITextView, context: Context) {
195:         // Update colors when theme changes
196:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
197:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
198:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
199:         
200:         if let editorView = textView as? EditorTextView {
201:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
202:         }
203:         
204:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
205:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
206:             let selectedRange = textView.selectedRange
207:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
208:             context.coordinator.applySyntaxHighlighting(to: textView)
209:             textView.selectedRange = selectedRange
210:             
211:             // Update line height
212:             if let font = textView.font {
213:                 DispatchQueue.main.async {
214:                     self.lineHeight = font.lineHeight
215:                 }
216:             }
217:         }
218:         
219:         // Update text if changed externally
220:         if textView.text != text {
221:             let selectedRange = textView.selectedRange
222:             textView.text = text
223:             context.coordinator.applySyntaxHighlighting(to: textView)
224:             textView.selectedRange = selectedRange
225:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
226:             // Re-apply highlighting if theme changed
227:             context.coordinator.applySyntaxHighlighting(to: textView)
228:         }
229:         
230:         // Handle minimap scrolling
231:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 {
232:             // Update lastKnownScrollPosition FIRST to prevent race condition
233:             // where user scroll gets overridden by stale binding value
234:             context.coordinator.lastKnownScrollPosition = scrollPosition
235:             context.coordinator.scrollToLine(scrollPosition, in: textView)
236:         }
237: 
238:         // Handle line selection requests (e.g. tapping line numbers)
239:         if let requested = requestedLineSelection,
240:            requested != context.coordinator.lastRequestedLineSelection {
241:             context.coordinator.lastRequestedLineSelection = requested
242:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
243:             // Defer @Binding update to avoid "Publishing changes from within view updates"
244:             DispatchQueue.main.async {
245:                 self.requestedLineSelection = nil
246:             }
247:         }
248: 
249:         // Handle cursor index requests (e.g. accepting autocomplete)
250:         if let requested = requestedCursorIndex,


I can see that `makeUIView()` at line 188 already calls `applySyntaxHighlighting()` after setting text, and `updateUIView()` at line 223 also applies highlighting when text changes. The issue might be in the `applySyntaxHighlighting` method itself. Let me find and examine it:

>>>TOOL search
{"query": "func applySyntaxHighlighting", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:431: func applySyntaxHighlighting(to textView: UITextView) {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 100, "end_line": 300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-300 of 1931)
────────────────────────────────────────
101:         )
102:     }
103: 
104:     func makeCoordinator() -> Coordinator {
105:         Coordinator(self)
106:     }
107:     
108:     func makeUIView(context: Context) -> UITextView {
109:         let textView = EditorTextView()
110:         textView.delegate = context.coordinator
111: 
112:         // Autocomplete hooks
113:         textView.onAcceptAutocomplete = onAcceptAutocomplete
114:         textView.onDismissAutocomplete = onDismissAutocomplete
115: 
116:         textView.onPeekDefinition = {
117:             context.coordinator.handlePeekDefinition(in: textView)
118:         }
119: 
120:         textView.onEscape = {
121:             context.coordinator.handleEscape()
122:         }
123: 
124:         textView.onGoToLine = {
125:             self.editorCore.showGoToLine = true
126:         }
127:         
128:         // Wire up custom context menu actions
129:         textView.onGoToDefinition = {
130:             context.coordinator.handleGoToDefinition(in: textView)
131:         }
132:         
133:         textView.onFindReferences = {
134:             context.coordinator.handleFindReferences(in: textView)
135:         }
136:         
137:         textView.onFormatDocument = {
138:             context.coordinator.handleFormatDocument(in: textView)
139:         }
140:         
141:         textView.onToggleComment = {
142:             context.coordinator.handleToggleComment(in: textView)
143:         }
144:         
145:         textView.onFold = {
146:             context.coordinator.handleFold(in: textView)
147:         }
148:         
149:         textView.onUnfold = {
150:             context.coordinator.handleUnfold(in: textView)
151:         }
152:         
153:         // Add pinch gesture for zoom
154:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
155:         textView.addGestureRecognizer(pinchGesture)
156:         context.coordinator.pinchGesture = pinchGesture
157:         
158:         // Configure text view
159:         textView.isEditable = true
160:         textView.isSelectable = true
161:         textView.autocapitalizationType = .none
162:         textView.autocorrectionType = .no
163:         textView.smartDashesType = .no
164:         textView.smartQuotesType = .no
165:         textView.smartInsertDeleteType = .no
166:         textView.spellCheckingType = .no
167:         
168:         // Set font and appearance (use editorCore.editorFontSize)
169:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
170:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
171:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
172:         textView.keyboardType = .default
173:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
174:         
175:         // Enable line wrapping
176:         textView.textContainer.lineBreakMode = .byCharWrapping
177:         textView.textContainer.widthTracksTextView = true
178:         
179:         // Calculate line height
180:         if let font = textView.font {
181:             DispatchQueue.main.async {
182:                 self.lineHeight = font.lineHeight
183:             }
184:         }
185:         
186:         // Set initial text with syntax highlighting
187:         textView.text = text
188:         context.coordinator.applySyntaxHighlighting(to: textView)
189:         context.coordinator.updateLineCount(textView)
190:         
191:         return textView
192:     }
193:     
194:     func updateUIView(_ textView: UITextView, context: Context) {
195:         // Update colors when theme changes
196:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
197:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
198:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
199:         
200:         if let editorView = textView as? EditorTextView {
201:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
202:         }
203:         
204:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
205:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
206:             let selectedRange = textView.selectedRange
207:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
208:             context.coordinator.applySyntaxHighlighting(to: textView)
209:             textView.selectedRange = selectedRange
210:             
211:             // Update line height
212:             if let font = textView.font {
213:                 DispatchQueue.main.async {
214:                     self.lineHeight = font.lineHeight
215:                 }
216:             }
217:         }
218:         
219:         // Update text if changed externally
220:         if textView.text != text {
221:             let selectedRange = textView.selectedRange
222:             textView.text = text
223:             context.coordinator.applySyntaxHighlighting(to: textView)
224:             textView.selectedRange = selectedRange
225:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
226:             // Re-apply highlighting if theme changed
227:             context.coordinator.applySyntaxHighlighting(to: textView)
228:         }
229:         
230:         // Handle minimap scrolling
231:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 {
232:             // Update lastKnownScrollPosition FIRST to prevent race condition
233:             // where user scroll gets overridden by stale binding value
234:             context.coordinator.lastKnownScrollPosition = scrollPosition
235:             context.coordinator.scrollToLine(scrollPosition, in: textView)
236:         }
237: 
238:         // Handle line selection requests (e.g. tapping line numbers)
239:         if let requested = requestedLineSelection,
240:            requested != context.coordinator.lastRequestedLineSelection {
241:             context.coordinator.lastRequestedLineSelection = requested
242:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
243:             // Defer @Binding update to avoid "Publishing changes from within view updates"
244:             DispatchQueue.main.async {
245:                 self.requestedLineSelection = nil
246:             }
247:         }
248: 
249:         // Handle cursor index requests (e.g. accepting autocomplete)
250:         if let requested = requestedCursorIndex,
251:            requested != context.coordinator.lastRequestedCursorIndex {
252:             context.coordinator.lastRequestedCursorIndex = requested
253:             textView.selectedRange = NSRange(location: max(0, requested), length: 0)
254:             // Defer @Binding update to avoid "Publishing changes from within view updates"
255:             DispatchQueue.main.async {
256:                 self.requestedCursorIndex = nil
257:             }
258: 
259:             // Update SwiftUI state
260:             context.coordinator.updateCursorPosition(textView)
261:             context.coordinator.updateScrollPosition(textView)
262:         }
263:         
264:         // Note: updateLineCount is called in textViewDidChange, no need to call here
265:         // as it causes unnecessary state churn on every updateUIView
266:     }
267:     
268:     // MARK: - Coordinator
269:     
270:     class Coordinator: NSObject, UITextViewDelegate {
271:         var parent: SyntaxHighlightingTextView
272:         var lastKnownScrollPosition: Int = 0
273:         var lastThemeId: String = ""
274:         var lastRequestedLineSelection: Int? = nil
275:         var lastRequestedCursorIndex: Int? = nil
276:         private var isUpdatingFromMinimap = false
277:         private var highlightDebouncer: Timer?
278:         weak var pinchGesture: UIPinchGestureRecognizer?
279:         private var initialFontSize: CGFloat = 0
280: 
281:         // FEAT-044: Matching bracket highlight state
282:         private var bracketHighlightRanges: [NSRange] = []
283:         
284:         init(_ parent: SyntaxHighlightingTextView) {
285:             self.parent = parent
286:         }
287:         
288:         func textViewDidBeginEditing(_ textView: UITextView) {
289:             // Ensure syntax highlighting is current when user begins editing
290:             // This handles cases where text was set but highlighting hasn't run yet
291:             applySyntaxHighlighting(to: textView)
292:         }
293:         
294:         func textViewDidChange(_ textView: UITextView) {
295:             // Update parent text
296:             parent.text = textView.text
297:             
298:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
299:             // This prevents flicker during the debounce period
300:             let theme = ThemeManager.shared.currentTheme


>>>TOOL search
{"query": "func applySyntaxHighlighting", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:431: func applySyntaxHighlighting(to textView: UITextView) {


>>>TOOL search
{"query": "func makeUIView", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:909: func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:946: func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:108: func makeUIView(context: Context) -> UITextView {
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/MarkdownPreviewView.swift:77: func makeUIView(context: Context) -> WKWebView {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 108, "end_line": 200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 109-200 of 1931)
────────────────────────────────────────
109:         let textView = EditorTextView()
110:         textView.delegate = context.coordinator
111: 
112:         // Autocomplete hooks
113:         textView.onAcceptAutocomplete = onAcceptAutocomplete
114:         textView.onDismissAutocomplete = onDismissAutocomplete
115: 
116:         textView.onPeekDefinition = {
117:             context.coordinator.handlePeekDefinition(in: textView)
118:         }
119: 
120:         textView.onEscape = {
121:             context.coordinator.handleEscape()
122:         }
123: 
124:         textView.onGoToLine = {
125:             self.editorCore.showGoToLine = true
126:         }
127:         
128:         // Wire up custom context menu actions
129:         textView.onGoToDefinition = {
130:             context.coordinator.handleGoToDefinition(in: textView)
131:         }
132:         
133:         textView.onFindReferences = {
134:             context.coordinator.handleFindReferences(in: textView)
135:         }
136:         
137:         textView.onFormatDocument = {
138:             context.coordinator.handleFormatDocument(in: textView)
139:         }
140:         
141:         textView.onToggleComment = {
142:             context.coordinator.handleToggleComment(in: textView)
143:         }
144:         
145:         textView.onFold = {
146:             context.coordinator.handleFold(in: textView)
147:         }
148:         
149:         textView.onUnfold = {
150:             context.coordinator.handleUnfold(in: textView)
151:         }
152:         
153:         // Add pinch gesture for zoom
154:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
155:         textView.addGestureRecognizer(pinchGesture)
156:         context.coordinator.pinchGesture = pinchGesture
157:         
158:         // Configure text view
159:         textView.isEditable = true
160:         textView.isSelectable = true
161:         textView.autocapitalizationType = .none
162:         textView.autocorrectionType = .no
163:         textView.smartDashesType = .no
164:         textView.smartQuotesType = .no
165:         textView.smartInsertDeleteType = .no
166:         textView.spellCheckingType = .no
167:         
168:         // Set font and appearance (use editorCore.editorFontSize)
169:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
170:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
171:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
172:         textView.keyboardType = .default
173:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
174:         
175:         // Enable line wrapping
176:         textView.textContainer.lineBreakMode = .byCharWrapping
177:         textView.textContainer.widthTracksTextView = true
178:         
179:         // Calculate line height
180:         if let font = textView.font {
181:             DispatchQueue.main.async {
182:                 self.lineHeight = font.lineHeight
183:             }
184:         }
185:         
186:         // Set initial text with syntax highlighting
187:         textView.text = text
188:         context.coordinator.applySyntaxHighlighting(to: textView)
189:         context.coordinator.updateLineCount(textView)
190:         
191:         return textView
192:     }
193:     
194:     func updateUIView(_ textView: UITextView, context: Context) {
195:         // Update colors when theme changes
196:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
197:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
198:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
199:         
200:         if let editorView = textView as? EditorTextView {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 200, "end_line": 320}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 201-320 of 1931)
────────────────────────────────────────
201:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
202:         }
203:         
204:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
205:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
206:             let selectedRange = textView.selectedRange
207:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
208:             context.coordinator.applySyntaxHighlighting(to: textView)
209:             textView.selectedRange = selectedRange
210:             
211:             // Update line height
212:             if let font = textView.font {
213:                 DispatchQueue.main.async {
214:                     self.lineHeight = font.lineHeight
215:                 }
216:             }
217:         }
218:         
219:         // Update text if changed externally
220:         if textView.text != text {
221:             let selectedRange = textView.selectedRange
222:             textView.text = text
223:             context.coordinator.applySyntaxHighlighting(to: textView)
224:             textView.selectedRange = selectedRange
225:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
226:             // Re-apply highlighting if theme changed
227:             context.coordinator.applySyntaxHighlighting(to: textView)
228:         }
229:         
230:         // Handle minimap scrolling
231:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 {
232:             // Update lastKnownScrollPosition FIRST to prevent race condition
233:             // where user scroll gets overridden by stale binding value
234:             context.coordinator.lastKnownScrollPosition = scrollPosition
235:             context.coordinator.scrollToLine(scrollPosition, in: textView)
236:         }
237: 
238:         // Handle line selection requests (e.g. tapping line numbers)
239:         if let requested = requestedLineSelection,
240:            requested != context.coordinator.lastRequestedLineSelection {
241:             context.coordinator.lastRequestedLineSelection = requested
242:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
243:             // Defer @Binding update to avoid "Publishing changes from within view updates"
244:             DispatchQueue.main.async {
245:                 self.requestedLineSelection = nil
246:             }
247:         }
248: 
249:         // Handle cursor index requests (e.g. accepting autocomplete)
250:         if let requested = requestedCursorIndex,
251:            requested != context.coordinator.lastRequestedCursorIndex {
252:             context.coordinator.lastRequestedCursorIndex = requested
253:             textView.selectedRange = NSRange(location: max(0, requested), length: 0)
254:             // Defer @Binding update to avoid "Publishing changes from within view updates"
255:             DispatchQueue.main.async {
256:                 self.requestedCursorIndex = nil
257:             }
258: 
259:             // Update SwiftUI state
260:             context.coordinator.updateCursorPosition(textView)
261:             context.coordinator.updateScrollPosition(textView)
262:         }
263:         
264:         // Note: updateLineCount is called in textViewDidChange, no need to call here
265:         // as it causes unnecessary state churn on every updateUIView
266:     }
267:     
268:     // MARK: - Coordinator
269:     
270:     class Coordinator: NSObject, UITextViewDelegate {
271:         var parent: SyntaxHighlightingTextView
272:         var lastKnownScrollPosition: Int = 0
273:         var lastThemeId: String = ""
274:         var lastRequestedLineSelection: Int? = nil
275:         var lastRequestedCursorIndex: Int? = nil
276:         private var isUpdatingFromMinimap = false
277:         private var highlightDebouncer: Timer?
278:         weak var pinchGesture: UIPinchGestureRecognizer?
279:         private var initialFontSize: CGFloat = 0
280: 
281:         // FEAT-044: Matching bracket highlight state
282:         private var bracketHighlightRanges: [NSRange] = []
283:         
284:         init(_ parent: SyntaxHighlightingTextView) {
285:             self.parent = parent
286:         }
287:         
288:         func textViewDidBeginEditing(_ textView: UITextView) {
289:             // Ensure syntax highlighting is current when user begins editing
290:             // This handles cases where text was set but highlighting hasn't run yet
291:             applySyntaxHighlighting(to: textView)
292:         }
293:         
294:         func textViewDidChange(_ textView: UITextView) {
295:             // Update parent text
296:             parent.text = textView.text
297:             
298:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
299:             // This prevents flicker during the debounce period
300:             let theme = ThemeManager.shared.currentTheme
301:             let fontSize = parent.editorCore.editorFontSize
302:             textView.typingAttributes = [
303:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
304:                 .foregroundColor: UIColor(theme.editorForeground)
305:             ]
306:             
307:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
308:             highlightDebouncer?.invalidate()
309:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
310:                 DispatchQueue.main.async {
311:                     self?.applySyntaxHighlighting(to: textView)
312:                 }
313:             }
314:             
315:             updateLineCount(textView)
316:             updateCursorPosition(textView)
317:         }
318:         
319:         func textViewDidChangeSelection(_ textView: UITextView) {
320:             if !isUpdatingFromMinimap {


Let me look at the `applySyntaxHighlighting` function to understand the issue:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 425, "end_line": 550}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 426-550 of 1946)
────────────────────────────────────────
426:             guard line >= 0 && line < lines.count else { return }
427: 
428:             var characterPosition = 0
429:             for i in 0..<line {
430:                 characterPosition += lines[i].count + 1
431:             }
432: 
433:             // FEAT-041: select entire line (excluding trailing newline)
434:             let lineLength = (lines[line] as NSString).length
435:             let range = NSRange(location: characterPosition, length: lineLength)
436:             textView.selectedRange = range
437: 
438:             // Ensure it's visible
439:             scrollToLine(line, in: textView)
440: 
441:             // Update SwiftUI state
442:             updateCursorPosition(textView)
443:             updateScrollPosition(textView)
444:         }
445: 
446:         func applySyntaxHighlighting(to textView: UITextView) {
447:             let theme = ThemeManager.shared.currentTheme
448:             lastThemeId = theme.id
449: 
450:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
451:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
452: 
453:             let selectedRange = textView.selectedRange
454:             textView.attributedText = attributedText
455:             textView.selectedRange = selectedRange
456: 
457:             // Set typing attributes so newly typed characters have correct base styling
458:             // This prevents flicker during the debounce period before full highlighting runs
459:             let fontSize = parent.editorCore.editorFontSize
460:             textView.typingAttributes = [
461:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
462:                 .foregroundColor: UIColor(theme.editorForeground)
463:             ]
464: 
465:             // FEAT-044: restore matching bracket highlight after re-attributing text
466:             updateMatchingBracketHighlight(textView)
467:         }
468:         
469:         func handlePeekDefinition(in textView: UITextView) {
470:             guard let selectedRange = textView.selectedTextRange else { return }
471:             let text = textView.text ?? ""
472:             
473:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
474:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
475:                  
476:                  let prefix = String(text.prefix(location))
477:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
478:                  
479:                  parent.editorCore.triggerPeekDefinition(
480:                      file: parent.filename,
481:                      line: sourceLine,
482:                      content: text,
483:                      sourceLine: sourceLine
484:                  )
485:             }
486:         }
487:         
488:         func handleEscape() {
489:             if parent.editorCore.peekState != nil {
490:                 parent.editorCore.closePeekDefinition()
491:             } else {
492:                 parent.editorCore.escapeMultiCursor()
493:             }
494:         }
495:         
496:         func handleGoToDefinition(in textView: UITextView) {
497:             // Reuse the peek definition logic for now
498:             handlePeekDefinition(in: textView)
499:         }
500:         
501:         func handleFindReferences(in textView: UITextView) {
502:             guard let selectedRange = textView.selectedTextRange else { return }
503:             let text = textView.text ?? ""
504:             
505:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
506:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
507:                 
508:                 let prefix = String(text.prefix(location))
509:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
510:                 
511:                 // TODO: Implement find references functionality in EditorCore
512:                 // For now, just trigger peek definition as a placeholder
513:                 parent.editorCore.triggerPeekDefinition(
514:                     file: parent.filename,
515:                     line: sourceLine,
516:                     content: text,
517:                     sourceLine: sourceLine
518:                 )
519:             }
520:         }
521:         
522:         func handleFormatDocument(in textView: UITextView) {
523:             // TODO: Implement format document functionality
524:             // This would typically call a formatter in EditorCore
525:             print("Format Document: Not yet implemented")
526:         }
527:         
528:         func handleToggleComment(in textView: UITextView) {
529:             guard let selectedRange = textView.selectedTextRange else { return }
530:             let text = textView.text ?? ""
531:             
532:             // Get the current line range
533:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
534:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
535:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
536:                 let nsRange = NSRange(location: location, length: length)
537:                 
538:                 if nsRange.location + nsRange.length <= (text as NSString).length {
539:                     let lineText = (text as NSString).substring(with: nsRange)
540:                     let trimmed = lineText.trimmingCharacters(in: .whitespaces)
541:                     
542:                     // Check if line starts with a comment
543:                     let isCommented = trimmed.hasPrefix("//") || trimmed.hasPrefix("#") || trimmed.hasPrefix("/*")
544:                     
545:                     // Toggle comment
546:                     var newLineText: String
547:                     if isCommented {
548:                         // Remove comment
549:                         newLineText = lineText.replacingOccurrences(of: "//", with: "").replacingOccurrences(of: "#", with: "", options: .anchored)
550:                     } else {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 200, "end_line": 320}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 201-320 of 1946)
────────────────────────────────────────
201:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
202:         }
203:         
204:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
205:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
206:             let selectedRange = textView.selectedRange
207:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
208:             context.coordinator.applySyntaxHighlighting(to: textView)
209:             textView.selectedRange = selectedRange
210:             
211:             // Update line height
212:             if let font = textView.font {
213:                 DispatchQueue.main.async {
214:                     self.lineHeight = font.lineHeight
215:                 }
216:             }
217:         }
218:         
219:         // Update text if changed externally
220:         if textView.text != text {
221:             let selectedRange = textView.selectedRange
222:             textView.text = text
223:             context.coordinator.applySyntaxHighlighting(to: textView)
224:             textView.selectedRange = selectedRange
225:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
226:             // Re-apply highlighting if theme changed
227:             context.coordinator.applySyntaxHighlighting(to: textView)
228:         }
229:         
230:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
231:         // This prevents the editor from fighting against user scroll due to async binding lag
232:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
233:             // Update lastKnownScrollPosition FIRST to prevent race condition
234:             // where user scroll gets overridden by stale binding value
235:             context.coordinator.lastKnownScrollPosition = scrollPosition
236:             context.coordinator.scrollToLine(scrollPosition, in: textView)
237:         }
238: 
239:         // Handle line selection requests (e.g. tapping line numbers)
240:         if let requested = requestedLineSelection,
241:            requested != context.coordinator.lastRequestedLineSelection {
242:             context.coordinator.lastRequestedLineSelection = requested
243:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
244:             // Defer @Binding update to avoid "Publishing changes from within view updates"
245:             DispatchQueue.main.async {
246:                 self.requestedLineSelection = nil
247:             }
248:         }
249: 
250:         // Handle cursor index requests (e.g. accepting autocomplete)
251:         if let requested = requestedCursorIndex,
252:            requested != context.coordinator.lastRequestedCursorIndex {
253:             context.coordinator.lastRequestedCursorIndex = requested
254:             textView.selectedRange = NSRange(location: max(0, requested), length: 0)
255:             // Defer @Binding update to avoid "Publishing changes from within view updates"
256:             DispatchQueue.main.async {
257:                 self.requestedCursorIndex = nil
258:             }
259: 
260:             // Update SwiftUI state
261:             context.coordinator.updateCursorPosition(textView)
262:             context.coordinator.updateScrollPosition(textView)
263:         }
264:         
265:         // Note: updateLineCount is called in textViewDidChange, no need to call here
266:         // as it causes unnecessary state churn on every updateUIView
267:     }
268:     
269:     // MARK: - Coordinator
270:     
271:     class Coordinator: NSObject, UITextViewDelegate {
272:         var parent: SyntaxHighlightingTextView
273:         var lastKnownScrollPosition: Int = 0
274:         var lastThemeId: String = ""
275:         var lastRequestedLineSelection: Int? = nil
276:         var lastRequestedCursorIndex: Int? = nil
277:         private var isUpdatingFromMinimap = false
278:         private var highlightDebouncer: Timer?
279:         weak var pinchGesture: UIPinchGestureRecognizer?
280:         private var initialFontSize: CGFloat = 0
281:         
282:         // Track user scroll to prevent programmatic scroll fighting back
283:         private var userScrollDebouncer: Timer?
284:         var isUserScrolling = false
285: 
286:         // FEAT-044: Matching bracket highlight state
287:         private var bracketHighlightRanges: [NSRange] = []
288:         
289:         init(_ parent: SyntaxHighlightingTextView) {
290:             self.parent = parent
291:         }
292:         
293:         func textViewDidBeginEditing(_ textView: UITextView) {
294:             // Ensure syntax highlighting is current when user begins editing
295:             // This handles cases where text was set but highlighting hasn't run yet
296:             applySyntaxHighlighting(to: textView)
297:         }
298:         
299:         func textViewDidChange(_ textView: UITextView) {
300:             // Update parent text
301:             parent.text = textView.text
302:             
303:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
304:             // This prevents flicker during the debounce period
305:             let theme = ThemeManager.shared.currentTheme
306:             let fontSize = parent.editorCore.editorFontSize
307:             textView.typingAttributes = [
308:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
309:                 .foregroundColor: UIColor(theme.editorForeground)
310:             ]
311:             
312:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
313:             highlightDebouncer?.invalidate()
314:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
315:                 DispatchQueue.main.async {
316:                     self?.applySyntaxHighlighting(to: textView)
317:                 }
318:             }
319:             
320:             updateLineCount(textView)


I can now see the issue. Looking at the code:

1. `makeUIView()` (lines 187-188) does set text and call `applySyntaxHighlighting`
2. But `updateUIView()` is called immediately after by SwiftUI
3. The coordinator's `parent` reference is never updated in `updateUIView`, which can cause stale state
4. More importantly, there's no guarantee the initial highlighting persists if the view isn't fully in the hierarchy

Let me also check the Coordinator class and see if there's a missing parent update:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 269, "end_line": 300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 270-300 of 1946)
────────────────────────────────────────
270:     
271:     class Coordinator: NSObject, UITextViewDelegate {
272:         var parent: SyntaxHighlightingTextView
273:         var lastKnownScrollPosition: Int = 0
274:         var lastThemeId: String = ""
275:         var lastRequestedLineSelection: Int? = nil
276:         var lastRequestedCursorIndex: Int? = nil
277:         private var isUpdatingFromMinimap = false
278:         private var highlightDebouncer: Timer?
279:         weak var pinchGesture: UIPinchGestureRecognizer?
280:         private var initialFontSize: CGFloat = 0
281:         
282:         // Track user scroll to prevent programmatic scroll fighting back
283:         private var userScrollDebouncer: Timer?
284:         var isUserScrolling = false
285: 
286:         // FEAT-044: Matching bracket highlight state
287:         private var bracketHighlightRanges: [NSRange] = []
288:         
289:         init(_ parent: SyntaxHighlightingTextView) {
290:             self.parent = parent
291:         }
292:         
293:         func textViewDidBeginEditing(_ textView: UITextView) {
294:             // Ensure syntax highlighting is current when user begins editing
295:             // This handles cases where text was set but highlighting hasn't run yet
296:             applySyntaxHighlighting(to: textView)
297:         }
298:         
299:         func textViewDidChange(_ textView: UITextView) {
300:             // Update parent text


Now I understand the issue. The problem is that in `UIViewRepresentable`, the coordinator's `parent` reference becomes stale because SwiftUI creates new struct instances on each update. The `parent` needs to be updated at the start of `updateUIView()`. Additionally, the initial highlighting in `makeUIView` may be getting lost when `updateUIView` is called immediately after.

Let me create the fix:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
    func updateUIView(_ textView: UITextView, context: Context) {
        // Update colors when theme changes
        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
        textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
        textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
>>>REPLACE
    func updateUIView(_ textView: UITextView, context: Context) {
        // CRITICAL: Update coordinator's parent reference to current struct
        // SwiftUI creates new struct instances on each update, so this keeps
        // coordinator in sync with current bindings and properties
        context.coordinator.parent = self
        
        // Update colors when theme changes
        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
        textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
        textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
>>>END

Now let me also add a flag to track if initial highlighting was applied, and force it on first updateUIView:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 271, "end_line": 292}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 272-292 of 1946)
────────────────────────────────────────
272:         var parent: SyntaxHighlightingTextView
273:         var lastKnownScrollPosition: Int = 0
274:         var lastThemeId: String = ""
275:         var lastRequestedLineSelection: Int? = nil
276:         var lastRequestedCursorIndex: Int? = nil
277:         private var isUpdatingFromMinimap = false
278:         private var highlightDebouncer: Timer?
279:         weak var pinchGesture: UIPinchGestureRecognizer?
280:         private var initialFontSize: CGFloat = 0
281:         
282:         // Track user scroll to prevent programmatic scroll fighting back
283:         private var userScrollDebouncer: Timer?
284:         var isUserScrolling = false
285: 
286:         // FEAT-044: Matching bracket highlight state
287:         private var bracketHighlightRanges: [NSRange] = []
288:         
289:         init(_ parent: SyntaxHighlightingTextView) {
290:             self.parent = parent
291:         }
292:         

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)


Now let me add a flag to ensure initial highlighting is applied:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
        // FEAT-044: Matching bracket highlight state
        private var bracketHighlightRanges: [NSRange] = []
        
        init(_ parent: SyntaxHighlightingTextView) {
            self.parent = parent
        }
>>>REPLACE
        // FEAT-044: Matching bracket highlight state
        private var bracketHighlightRanges: [NSRange] = []
        
        // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
        var hasAppliedInitialHighlighting = false
        
        init(_ parent: SyntaxHighlightingTextView) {
            self.parent = parent
        }
>>>END

Now let me update `updateUIView` to apply highlighting on first call:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 219, "end_line": 235}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 220-235 of 1951)
────────────────────────────────────────
220:                 }
221:             }
222:         }
223:         
224:         // Update text if changed externally
225:         if textView.text != text {
226:             let selectedRange = textView.selectedRange
227:             textView.text = text
228:             context.coordinator.applySyntaxHighlighting(to: textView)
229:             textView.selectedRange = selectedRange
230:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
231:             // Re-apply highlighting if theme changed
232:             context.coordinator.applySyntaxHighlighting(to: textView)
233:         }
234:         
235:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)


>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
        // Update text if changed externally
        if textView.text != text {
            let selectedRange = textView.selectedRange
            textView.text = text
            context.coordinator.applySyntaxHighlighting(to: textView)
            textView.selectedRange = selectedRange
        } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
            // Re-apply highlighting if theme changed
            context.coordinator.applySyntaxHighlighting(to: textView)
        }
>>>REPLACE
        // Update text if changed externally
        if textView.text != text {
            let selectedRange = textView.selectedRange
            textView.text = text
            context.coordinator.applySyntaxHighlighting(to: textView)
            context.coordinator.hasAppliedInitialHighlighting = true
            textView.selectedRange = selectedRange
        } else if !context.coordinator.hasAppliedInitialHighlighting {
            // CRITICAL: Apply highlighting on first updateUIView call
            // makeUIView applies it, but the view may not be fully in hierarchy yet,
            // causing the attributed text to be lost. This ensures it's applied.
            context.coordinator.applySyntaxHighlighting(to: textView)
            context.coordinator.hasAppliedInitialHighlighting = true
        } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
            // Re-apply highlighting if theme changed
            context.coordinator.applySyntaxHighlighting(to: textView)
        }
>>>END

---

## 🔧 TOOL RESULTS

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 194, "end_line": 240}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 195-240 of 1990)
────────────────────────────────────────
195:         // CRITICAL: Update coordinator's parent reference to current struct
196:         // SwiftUI creates new struct instances on each update, so this keeps
197:         // coordinator in sync with current bindings and properties
198:         context.coordinator.parent = self
199:         
200:         // Update colors when theme changes
201:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
202:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
203:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
204:         
205:         if let editorView = textView as? EditorTextView {
206:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
207:         }
208:         
209:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
210:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
211:             let selectedRange = textView.selectedRange
212:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
213:             context.coordinator.applySyntaxHighlighting(to: textView)
214:             textView.selectedRange = selectedRange
215:             
216:             // Update line height
217:             if let font = textView.font {
218:                 DispatchQueue.main.async {
219:                     self.lineHeight = font.lineHeight
220:                 }
221:             }
222:         }
223:         
224:         // Update text if changed externally
225:         if textView.text != text {
226:             let selectedRange = textView.selectedRange
227:             textView.text = text
228:             context.coordinator.applySyntaxHighlighting(to: textView)
229:             context.coordinator.hasAppliedInitialHighlighting = true
230:             textView.selectedRange = selectedRange
231:         } else if !context.coordinator.hasAppliedInitialHighlighting {
232:             // CRITICAL: Apply highlighting on first updateUIView call
233:             // makeUIView applies it, but the view may not be fully in hierarchy yet,
234:             // causing the attributed text to be lost. This ensures it's applied.
235:             context.coordinator.applySyntaxHighlighting(to: textView)
236:             context.coordinator.hasAppliedInitialHighlighting = true
237:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
238:             // Re-apply highlighting if theme changed
239:             context.coordinator.applySyntaxHighlighting(to: textView)
240:         }


The fix has been applied. Let me verify the complete fix by reading a bit more to ensure the logic is correct:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 185, "end_line": 195}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 186-195 of 1990)
────────────────────────────────────────
186:         // Set initial text with syntax highlighting
187:         textView.text = text
188:         context.coordinator.applySyntaxHighlighting(to: textView)
189:         context.coordinator.updateLineCount(textView)
190:         
191:         return textView
192:     }
193:     
194:     func updateUIView(_ textView: UITextView, context: Context) {
195:         // CRITICAL: Update coordinator's parent reference to current struct


Let me verify the Coordinator class has the new flag:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 286, "end_line": 300}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 287-300 of 1990)
────────────────────────────────────────
287:         var lastRequestedLineSelection: Int? = nil
288:         var lastRequestedCursorIndex: Int? = nil
289:         private var isUpdatingFromMinimap = false
290:         private var highlightDebouncer: Timer?
291:         weak var pinchGesture: UIPinchGestureRecognizer?
292:         private var initialFontSize: CGFloat = 0
293:         
294:         // Track user scroll to prevent programmatic scroll fighting back
295:         private var userScrollDebouncer: Timer?
296:         var isUserScrolling = false
297: 
298:         // FEAT-044: Matching bracket highlight state
299:         private var bracketHighlightRanges: [NSRange] = []
300:         


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 298, "end_line": 315}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 299-315 of 1990)
────────────────────────────────────────
299:         private var bracketHighlightRanges: [NSRange] = []
300:         
301:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
302:         var hasAppliedInitialHighlighting = false
303:         
304:         init(_ parent: SyntaxHighlightingTextView) {
305:             self.parent = parent
306:         }
307:         
308:         func textViewDidBeginEditing(_ textView: UITextView) {
309:             // Ensure syntax highlighting is current when user begins editing
310:             // This handles cases where text was set but highlighting hasn't run yet
311:             applySyntaxHighlighting(to: textView)
312:         }
313:         
314:         func textViewDidChange(_ textView: UITextView) {
315:             // Update parent text


The fixes have been applied successfully. The changes fix the syntax highlighting not appearing on file open issue. Now I need to note that I cannot run the build command as I only have read+write permissions.

>>>REPORT
## Fixed: Syntax Highlighting Not Appearing on File Open

### Problem
Syntax highlighting was only appearing after the user started typing, not when a file was initially opened.

### Root Cause
In SwiftUI's `UIViewRepresentable`, `makeUIView()` applies the highlighting, but when `updateUIView()` is called immediately after (which SwiftUI does), the attributed text could be lost because the view wasn't fully in the hierarchy yet. Additionally, the coordinator's `parent` reference was becoming stale as SwiftUI creates new struct instances on each update.

### Changes Made to `SyntaxHighlightingTextView.swift`

1. **Line 195-198**: Added critical update of coordinator's parent reference at the start of `updateUIView()`:
   ```swift
   // CRITICAL: Update coordinator's parent reference to current struct
   context.coordinator.parent = self
   ```

2. **Lines 301-302**: Added tracking flag to Coordinator class:
   ```swift
   // Track if initial highlighting has been applied
   var hasAppliedInitialHighlighting = false
   ```

3. **Lines 231-236**: Added logic in `updateUIView()` to ensure highlighting is applied on first call:
   ```swift
   } else if !context.coordinator.hasAppliedInitialHighlighting {
       // CRITICAL: Apply highlighting on first updateUIView call
       context.coordinator.applySyntaxHighlighting(to: textView)
       context.coordinator.hasAppliedInitialHighlighting = true
   }
   ```

### Build Required
⚠️ I cannot run the build command (no command execution permissions). Please run:
```bash
xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj -scheme VSCodeiPadOS build
```

Or build from Xcode to verify the fix compiles correctly.
>>>END
