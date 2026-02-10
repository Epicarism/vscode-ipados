# Agent: editor-undoredo-gpt
**Status:** done
**Tokens:** 54,805
**Cost:** $0.0000
**Time:** 2026-02-10T03:02:59.383Z

## Task
VSCodeiPadOS editor: Ensure undo/redo works. Check if UITextView's built-in undoManager is enabled in SyntaxHighlightingTextView.swift. Verify Cmd+Z and Cmd+Shift+Z keyboard shortcuts work. Look for UIKeyCommand handlers. Fix any issues. BUILD AFTER.

## Response
>>>TOOL list_dir
{"path":"/Users/danielswagg/PLAYGROUND/vscode-ipados"}
>>>END>>>TOOL search
{"query":"SyntaxHighlightingTextView", "glob":"**/*"}
>>>END>>>TOOL search
{"query":"UIKeyCommand", "glob":"**/*.swift"}
>>>END>>>TOOL search
{"query":"undoManager", "glob":"**/*.swift"}
>>>END>>>END


>>>TOOL list_dir
{"path":"."}
>>>END
>>>TOOL search
{"query":"override var keyCommands", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"canPerformAction", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":220}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift","start_line":460,"end_line":560}
>>>END
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
   LICENSE
   README.md
(cached)

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:895: override var keyCommands: [UIKeyCommand]? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:206: override var keyCommands: [UIKeyCommand]? {

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1144: override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1162: return super.canPerformAction(action, withSender: sender)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-220 of 1995)
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
16:     @Binding var totalLines: Int
17:     @Binding var visibleLines: Int
18:     @Binding var currentLineNumber: Int
19:     @Binding var currentColumn: Int
20:     @Binding var cursorIndex: Int
21:     @Binding var lineHeight: CGFloat
22:     @Binding var requestedLineSelection: Int?
23:     @Binding var requestedCursorIndex: Int?
24: 
25:     /// Autocomplete key handling hooks (return true if handled)
26:     let onAcceptAutocomplete: (() -> Bool)?
27:     let onDismissAutocomplete: (() -> Bool)?
28: 
29:     let isActive: Bool
30:     let fontSize: CGFloat  // Explicit parameter to trigger SwiftUI updates
31:     @EnvironmentObject var editorCore: EditorCore
32: 
33:     init(
34:         text: Binding<String>,
35:         filename: String,
36:         scrollPosition: Binding<Int>,
37:         totalLines: Binding<Int>,
38:         visibleLines: Binding<Int>,
39:         currentLineNumber: Binding<Int>,
40:         currentColumn: Binding<Int>,
41:         cursorIndex: Binding<Int> = .constant(0),
42:         lineHeight: Binding<CGFloat>,
43:         isActive: Bool,
44:         fontSize: CGFloat = 14.0,
45:         requestedLineSelection: Binding<Int?> = .constant(nil),
46:         requestedCursorIndex: Binding<Int?> = .constant(nil),
47:         onAcceptAutocomplete: (() -> Bool)? = nil,
48:         onDismissAutocomplete: (() -> Bool)? = nil
49:     ) {
50:         self._text = text
51:         self.filename = filename
52:         self._scrollPosition = scrollPosition
53:         self._totalLines = totalLines
54:         self._visibleLines = visibleLines
55:         self._currentLineNumber = currentLineNumber
56:         self._currentColumn = currentColumn
57:         self._cursorIndex = cursorIndex
58:         self._lineHeight = lineHeight
59:         self.isActive = isActive
60:         self.fontSize = fontSize
61:         self._requestedLineSelection = requestedLineSelection
62:         self._requestedCursorIndex = requestedCursorIndex
63:         self.onAcceptAutocomplete = onAcceptAutocomplete
64:         self.onDismissAutocomplete = onDismissAutocomplete
65:     }
66:     
67:     // Compatibility init for older call sites (e.g. SplitEditorView) that pass editorCore explicitly.
68:     init(
69:         text: Binding<String>,
70:         filename: String,
71:         scrollPosition: Binding<Int>,
72:         totalLines: Binding<Int>,
73:         visibleLines: Binding<Int>,
74:         currentLineNumber: Binding<Int>,
75:         currentColumn: Binding<Int>,
76:         cursorIndex: Binding<Int> = .constant(0),
77:         lineHeight: Binding<CGFloat>,
78:         isActive: Bool,
79:         editorCore: EditorCore,
80:         requestedLineSelection: Binding<Int?> = .constant(nil),
81:         requestedCursorIndex: Binding<Int?> = .constant(nil),
82:         onAcceptAutocomplete: (() -> Bool)? = nil,
83:         onDismissAutocomplete: (() -> Bool)? = nil
84:     ) {
85:         self.init(
86:             text: text,
87:             filename: filename,
88:             scrollPosition: scrollPosition,
89:             totalLines: totalLines,
90:             visibleLines: visibleLines,
91:             currentLineNumber: currentLineNumber,
92:             currentColumn: currentColumn,
93:             cursorIndex: cursorIndex,
94:             lineHeight: lineHeight,
95:             isActive: isActive,
96:             fontSize: editorCore.editorFontSize,
97:             requestedLineSelection: requestedLineSelection,
98:             requestedCursorIndex: requestedCursorIndex,
99:             onAcceptAutocomplete: onAcceptAutocomplete,
100:             onDismissAutocomplete: onDismissAutocomplete
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
195:         // CRITICAL: Update coordinator's parent reference to current struct
196:         // SwiftUI creates new struct instances on each update, so this keeps
197:         // coordinator in sync with current bindings and properties
198:         context.coordinator.parent = self
199:         
200:         // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
201:         // This fixes the bug where syntax highlighting only appears after typing.
202:         // makeUIView applies it, but the view may not be fully in hierarchy yet,
203:         // causing the attributed text to be lost. This ensures it's applied reliably.
204:         if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
205:             context.coordinator.applySyntaxHighlighting(to: textView)
206:             context.coordinator.hasAppliedInitialHighlighting = true
207:         }
208:         
209:         // Update colors when theme changes
210:         // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor
211:         // as it interferes with attributedText syntax highlighting colors.
212:         // The foreground color is handled entirely by the attributedText.
213:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
214:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
215:         
216:         if let editorView = textView as? EditorTextView {
217:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
218:         }
219:         
220:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift (lines 461-541 of 541)
────────────────────────────────────────
461:             while position < characters.count && characters[position].isWhitespace {
462:                 position += 1
463:             }
464:         } else {
465:             // Other characters: just consume one character
466:             position += 1
467:         }
468:         
469:         // Ensure we always accept at least one non-whitespace character
470:         // or all leading whitespace if that's all there is
471:         return max(position, leadingWhitespaceCount > 0 ? leadingWhitespaceCount : 1)
472:     }
473:     
474:     /// Checks if a character is punctuation that can be part of a word (like period, comma, etc.)
475:     private func isWordPunctuation(_ char: Character) -> Bool {
476:         let wordPunctuation = CharacterSet(charactersIn: ".,;:!?-_'")
477:         guard let scalar = char.unicodeScalars.first else { return false }
478:         return wordPunctuation.contains(scalar)
479:     }
480:     
481:     /// Checks if a character is general punctuation or symbol
482:     private func isPunctuation(_ char: Character) -> Bool {
483:         return char.isPunctuation || char.isSymbol
484:     }
485: }
486: 
487: // MARK: - Error Types
488: 
489: enum InlineSuggestionError: Error {
490:     case requestThrottled
491:     case noContextAvailable
492:     case serviceUnavailable
493:     case cancelled
494: }
495: 
496: // MARK: - UIKeyCommand Extensions for Partial Accept
497: 
498: /// Extension to provide keyboard shortcut bindings for partial accept functionality.
499: /// Bind to Ctrl+Right Arrow or Option+Right Arrow.
500: extension UIResponder {
501:     
502:     /// Registers keyboard commands for inline suggestions partial accept.
503:     /// Call this from your editor view controller to enable Ctrl+Right and Option+Right shortcuts.
504:     static func registerInlineSuggestionKeyCommands() -> [UIKeyCommand] {
505:         // Ctrl+Right Arrow for partial accept
506:         let ctrlRightCommand = UIKeyCommand(
507:             input: UIKeyCommand.inputRightArrow,
508:             modifierFlags: .control,
509:             action: #selector(performPartialAccept(_:))
510:         )
511:         ctrlRightCommand.wantsPriorityOverSystemBehavior = true
512:         
513:         // Option+Right Arrow for partial accept (alternative binding)
514:         let optRightCommand = UIKeyCommand(
515:             input: UIKeyCommand.inputRightArrow,
516:             modifierFlags: .alternate,
517:             action: #selector(performPartialAccept(_:))
518:         )
519:         optRightCommand.wantsPriorityOverSystemBehavior = true
520:         
521:         return [ctrlRightCommand, optRightCommand]
522:     }
523:     
524:     @objc private func performPartialAccept(_ sender: UIKeyCommand) {
525:         // Access the shared manager and perform partial accept
526:         // This requires the editor to insert the accepted text at cursor position
527:         NotificationCenter.default.post(
528:             name: .inlineSuggestionPartialAccept,
529:             object: nil
530:         )
531:     }
532: }
533: 
534: // MARK: - Notification Names
535: 
536: extension Notification.Name {
537:     /// Posted when partial accept should be performed.
538:     /// Bind your editor's insert method to this notification.
539:     static let inlineSuggestionPartialAccept = Notification.Name("inlineSuggestionPartialAccept")
540: }
541: 


>>>TOOL get_symbols
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[get_symbols]
No symbols found in VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (file may need to be opened first)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":840,"end_line":980}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 841-980 of 1995)
────────────────────────────────────────
841:             let safeLoc = min(max(0, caretPos), nsText.length)
842:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
843:             let caretLineText = nsText.substring(with: caretLineRange)
844: 
845:             var spaces = 0
846:             for ch in caretLineText {
847:                 if ch == " " { spaces += 1 }
848:                 else if ch == "\t" { spaces += tabSize }
849:                 else { break }
850:             }
851:             activeIndentLevel = spaces / tabSize
852:         }
853: 
854:         // Iterate visible glyphs/lines
855:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
856:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
857: 
858:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
859: 
860:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
861:             // Get text for this line
862:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
863:                   let text = self.text as NSString? else { return }
864: 
865:             let lineText = text.substring(with: range)
866: 
867:             // Calculate indentation level
868:             var spaces = 0
869:             for char in lineText {
870:                 if char == " " { spaces += 1 }
871:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
872:                 else { break }
873:             }
874: 
875:             let indentLevel = spaces / tabSize
876:             guard indentLevel > 0 else { return }
877: 
878:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
879: 
880:             for i in 1...indentLevel {
881:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
882:                 let startPoint = CGPoint(x: x, y: rect.minY)
883:                 let endPoint = CGPoint(x: x, y: rect.maxY)
884: 
885:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
886:                 context.setStrokeColor(stroke.cgColor)
887: 
888:                 context.move(to: startPoint)
889:                 context.addLine(to: endPoint)
890:                 context.strokePath()
891:             }
892:         }
893:     }
894:     
895:     override var keyCommands: [UIKeyCommand]? {
896:         var commands = super.keyCommands ?? []
897:         
898:         // Peek Definition: Alt+F12 (using special key input)
899:         // Note: F12 is not directly available on iPadOS keyboards
900:         // Using Option+D as alternative
901:         commands.append(UIKeyCommand(
902:             input: "d",
903:             modifierFlags: .alternate,
904:             action: #selector(handlePeekDefinition)
905:         ))
906: 
907:         // Go to Line: Cmd+G
908:         commands.append(UIKeyCommand(
909:             input: "g",
910:             modifierFlags: .command,
911:             action: #selector(handleGoToLine)
912:         ))
913: 
914:         // Tab: accept autocomplete if visible, else insert tab
915:         commands.append(UIKeyCommand(
916:             input: "\t",
917:             modifierFlags: [],
918:             action: #selector(handleTab)
919:         ))
920:         
921:         // Escape: dismiss autocomplete if visible, else normal escape behavior
922:         commands.append(UIKeyCommand(
923:             input: UIKeyCommand.inputEscape,
924:             modifierFlags: [],
925:             action: #selector(handleEscape)
926:         ))
927:         
928:         // Fold: Cmd+Opt+[
929:         commands.append(UIKeyCommand(
930:             input: "[",
931:             modifierFlags: [.command, .alternate],
932:             action: #selector(handleFold)
933:         ))
934:         
935:         // Unfold: Cmd+Opt+]
936:         commands.append(UIKeyCommand(
937:             input: "]",
938:             modifierFlags: [.command, .alternate],
939:             action: #selector(handleUnfold)
940:         ))
941:         
942:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
943:         // These post to NotificationCenter so ContentView can handle them
944:         
945:         // Command Palette: Cmd+Shift+P
946:         commands.append(UIKeyCommand(
947:             input: "p",
948:             modifierFlags: [.command, .shift],
949:             action: #selector(handleShowCommandPalette),
950:             discoverabilityTitle: "Command Palette"
951:         ))
952:         
953:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
954:         let toggleTerminalCmd = UIKeyCommand(
955:             input: "j",
956:             modifierFlags: .command,
957:             action: #selector(handleToggleTerminal),
958:             discoverabilityTitle: "Toggle Terminal"
959:         )
960:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
961:         commands.append(toggleTerminalCmd)
962:         
963:         // AI Assistant: Cmd+Shift+A
964:         commands.append(UIKeyCommand(
965:             input: "a",
966:             modifierFlags: [.command, .shift],
967:             action: #selector(handleShowAIAssistant),
968:             discoverabilityTitle: "AI Assistant"
969:         ))
970:         
971:         // Toggle Sidebar: Cmd+B
972:         commands.append(UIKeyCommand(
973:             input: "b",
974:             modifierFlags: .command,
975:             action: #selector(handleToggleSidebar),
976:             discoverabilityTitle: "Toggle Sidebar"
977:         ))
978:         
979:         // Quick Open: Cmd+P
980:         commands.append(UIKeyCommand(


>>>TOOL search
{"query":"class EditorTextView", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:760: class EditorTextView: UITextView {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":740,"end_line":980}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 741-980 of 1995)
────────────────────────────────────────
741:             }
742: 
743:             guard let match = matchIndex else { return }
744: 
745:             let r1 = NSRange(location: idx, length: 1)
746:             let r2 = NSRange(location: match, length: 1)
747: 
748:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
749:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
750: 
751:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
752:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
753: 
754:             bracketHighlightRanges = [r1, r2]
755:         }
756:     }
757: }
758: 
759: // Custom text view to handle key commands, indent guides, and line highlighting
760: class EditorTextView: UITextView {
761:     var onPeekDefinition: (() -> Void)?
762:     var onEscape: (() -> Void)?
763:     var onGoToLine: (() -> Void)?
764:     
765:     // Custom action closures for context menu
766:     var onGoToDefinition: (() -> Void)?
767:     var onFindReferences: (() -> Void)?
768:     var onFormatDocument: (() -> Void)?
769:     var onToggleComment: (() -> Void)?
770:     var onFold: (() -> Void)?
771:     var onUnfold: (() -> Void)?
772: 
773:     // Autocomplete key handling hooks (return true if handled)
774:     var onAcceptAutocomplete: (() -> Bool)?
775:     var onDismissAutocomplete: (() -> Bool)?
776:     
777:     // FEAT-039 & FEAT-043
778:     private var indentGuideColor: UIColor = .separator
779:     private var activeIndentGuideColor: UIColor = .label
780:     private var currentLineHighlightColor: UIColor = .clear
781:     
782:     override init(frame: CGRect, textContainer: NSTextContainer?) {
783:         super.init(frame: frame, textContainer: textContainer)
784:         setup()
785:     }
786:     
787:     required init?(coder: NSCoder) {
788:         super.init(coder: coder)
789:         setup()
790:     }
791:     
792:     private func setup() {
793:         // Ensure we redraw when bounds/selection change
794:         contentMode = .redraw
795:     }
796:     
797:     func updateThemeColors(theme: Theme) {
798:         self.indentGuideColor = UIColor(theme.indentGuide)
799:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
800:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
801:         setNeedsDisplay()
802:     }
803:     
804:     override func draw(_ rect: CGRect) {
805:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
806:             super.draw(rect)
807:             return
808:         }
809:         
810:         // 1. Draw Current Line Highlight (FEAT-043)
811:         if let selectedRange = selectedTextRange {
812:             // Get the line rect for the cursor position
813:             let caretRect = self.caretRect(for: selectedRange.start)
814:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
815:             
816:             context.setFillColor(currentLineHighlightColor.cgColor)
817:             context.fill(lineRect)
818:         }
819:         
820:         // 2. Draw Text (super implementation)
821:         super.draw(rect)
822:         
823:         // 3. Draw Indent Guides (FEAT-039)
824:         // We iterate visible lines and draw vertical lines for indentation
825:         // Optimization: Only draw for visible range
826: 
827:         context.setLineWidth(1.0)
828: 
829:         // Respect editor tab size setting (default 4)
830:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
831:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
832: 
833:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
834:         let indentWidth = spaceWidth * CGFloat(tabSize)
835: 
836:         // Determine active indent level for caret line (for indentGuideActive)
837:         var activeIndentLevel: Int = 0
838:         if let selected = selectedTextRange {
839:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
840:             let nsText = (self.text ?? "") as NSString
841:             let safeLoc = min(max(0, caretPos), nsText.length)
842:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
843:             let caretLineText = nsText.substring(with: caretLineRange)
844: 
845:             var spaces = 0
846:             for ch in caretLineText {
847:                 if ch == " " { spaces += 1 }
848:                 else if ch == "\t" { spaces += tabSize }
849:                 else { break }
850:             }
851:             activeIndentLevel = spaces / tabSize
852:         }
853: 
854:         // Iterate visible glyphs/lines
855:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
856:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
857: 
858:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
859: 
860:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
861:             // Get text for this line
862:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
863:                   let text = self.text as NSString? else { return }
864: 
865:             let lineText = text.substring(with: range)
866: 
867:             // Calculate indentation level
868:             var spaces = 0
869:             for char in lineText {
870:                 if char == " " { spaces += 1 }
871:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
872:                 else { break }
873:             }
874: 
875:             let indentLevel = spaces / tabSize
876:             guard indentLevel > 0 else { return }
877: 
878:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
879: 
880:             for i in 1...indentLevel {
881:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
882:                 let startPoint = CGPoint(x: x, y: rect.minY)
883:                 let endPoint = CGPoint(x: x, y: rect.maxY)
884: 
885:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
886:                 context.setStrokeColor(stroke.cgColor)
887: 
888:                 context.move(to: startPoint)
889:                 context.addLine(to: endPoint)
890:                 context.strokePath()
891:             }
892:         }
893:     }
894:     
895:     override var keyCommands: [UIKeyCommand]? {
896:         var commands = super.keyCommands ?? []
897:         
898:         // Peek Definition: Alt+F12 (using special key input)
899:         // Note: F12 is not directly available on iPadOS keyboards
900:         // Using Option+D as alternative
901:         commands.append(UIKeyCommand(
902:             input: "d",
903:             modifierFlags: .alternate,
904:             action: #selector(handlePeekDefinition)
905:         ))
906: 
907:         // Go to Line: Cmd+G
908:         commands.append(UIKeyCommand(
909:             input: "g",
910:             modifierFlags: .command,
911:             action: #selector(handleGoToLine)
912:         ))
913: 
914:         // Tab: accept autocomplete if visible, else insert tab
915:         commands.append(UIKeyCommand(
916:             input: "\t",
917:             modifierFlags: [],
918:             action: #selector(handleTab)
919:         ))
920:         
921:         // Escape: dismiss autocomplete if visible, else normal escape behavior
922:         commands.append(UIKeyCommand(
923:             input: UIKeyCommand.inputEscape,
924:             modifierFlags: [],
925:             action: #selector(handleEscape)
926:         ))
927:         
928:         // Fold: Cmd+Opt+[
929:         commands.append(UIKeyCommand(
930:             input: "[",
931:             modifierFlags: [.command, .alternate],
932:             action: #selector(handleFold)
933:         ))
934:         
935:         // Unfold: Cmd+Opt+]
936:         commands.append(UIKeyCommand(
937:             input: "]",
938:             modifierFlags: [.command, .alternate],
939:             action: #selector(handleUnfold)
940:         ))
941:         
942:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
943:         // These post to NotificationCenter so ContentView can handle them
944:         
945:         // Command Palette: Cmd+Shift+P
946:         commands.append(UIKeyCommand(
947:             input: "p",
948:             modifierFlags: [.command, .shift],
949:             action: #selector(handleShowCommandPalette),
950:             discoverabilityTitle: "Command Palette"
951:         ))
952:         
953:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
954:         let toggleTerminalCmd = UIKeyCommand(
955:             input: "j",
956:             modifierFlags: .command,
957:             action: #selector(handleToggleTerminal),
958:             discoverabilityTitle: "Toggle Terminal"
959:         )
960:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
961:         commands.append(toggleTerminalCmd)
962:         
963:         // AI Assistant: Cmd+Shift+A
964:         commands.append(UIKeyCommand(
965:             input: "a",
966:             modifierFlags: [.command, .shift],
967:             action: #selector(handleShowAIAssistant),
968:             discoverabilityTitle: "AI Assistant"
969:         ))
970:         
971:         // Toggle Sidebar: Cmd+B
972:         commands.append(UIKeyCommand(
973:             input: "b",
974:             modifierFlags: .command,
975:             action: #selector(handleToggleSidebar),
976:             discoverabilityTitle: "Toggle Sidebar"
977:         ))
978:         
979:         // Quick Open: Cmd+P
980:         commands.append(UIKeyCommand(


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":980,"end_line":1140}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 981-1140 of 1995)
────────────────────────────────────────
981:             input: "p",
982:             modifierFlags: .command,
983:             action: #selector(handleShowQuickOpen),
984:             discoverabilityTitle: "Quick Open"
985:         ))
986:         
987:         // New File: Cmd+N
988:         let newFileCmd = UIKeyCommand(
989:             input: "n",
990:             modifierFlags: .command,
991:             action: #selector(handleNewFile),
992:             discoverabilityTitle: "New File"
993:         )
994:         newFileCmd.wantsPriorityOverSystemBehavior = true
995:         commands.append(newFileCmd)
996:         
997:         // Save: Cmd+S
998:         commands.append(UIKeyCommand(
999:             input: "s",
1000:             modifierFlags: .command,
1001:             action: #selector(handleSaveFile),
1002:             discoverabilityTitle: "Save"
1003:         ))
1004:         
1005:         // Close Tab: Cmd+W
1006:         let closeTabCmd = UIKeyCommand(
1007:             input: "w",
1008:             modifierFlags: .command,
1009:             action: #selector(handleCloseTab),
1010:             discoverabilityTitle: "Close Tab"
1011:         )
1012:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1013:         commands.append(closeTabCmd)
1014:         
1015:         // Find: Cmd+F
1016:         let findCmd = UIKeyCommand(
1017:             input: "f",
1018:             modifierFlags: .command,
1019:             action: #selector(handleFind),
1020:             discoverabilityTitle: "Find"
1021:         )
1022:         findCmd.wantsPriorityOverSystemBehavior = true
1023:         commands.append(findCmd)
1024:         
1025:         // Zoom In: Cmd+=
1026:         commands.append(UIKeyCommand(
1027:             input: "=",
1028:             modifierFlags: .command,
1029:             action: #selector(handleZoomIn),
1030:             discoverabilityTitle: "Zoom In"
1031:         ))
1032:         
1033:         // Zoom Out: Cmd+-
1034:         commands.append(UIKeyCommand(
1035:             input: "-",
1036:             modifierFlags: .command,
1037:             action: #selector(handleZoomOut),
1038:             discoverabilityTitle: "Zoom Out"
1039:         ))
1040:         
1041:         return commands
1042:     }
1043:     
1044:     @objc func handlePeekDefinition() {
1045:         onPeekDefinition?()
1046:     }
1047: 
1048:     @objc func handleGoToLine() {
1049:         onGoToLine?()
1050:     }
1051: 
1052:     @objc func handleTab() {
1053:         if onAcceptAutocomplete?() == true {
1054:             return
1055:         }
1056:         insertText("\t")
1057:     }
1058:     
1059:     @objc func handleEscape() {
1060:         if onDismissAutocomplete?() == true {
1061:             return
1062:         }
1063:         onEscape?()
1064:     }
1065:     
1066:     @objc func handleFold() {
1067:         onFold?()
1068:     }
1069:     
1070:     @objc func handleUnfold() {
1071:         onUnfold?()
1072:     }
1073:     
1074:     // MARK: - App-Level Shortcut Handlers
1075:     
1076:     @objc func handleShowCommandPalette() {
1077:         NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1078:     }
1079:     
1080:     @objc func handleToggleTerminal() {
1081:         NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1082:     }
1083:     
1084:     @objc func handleShowAIAssistant() {
1085:         NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1086:     }
1087:     
1088:     @objc func handleToggleSidebar() {
1089:         NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
1090:     }
1091:     
1092:     @objc func handleShowQuickOpen() {
1093:         NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
1094:     }
1095:     
1096:     @objc func handleNewFile() {
1097:         NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
1098:     }
1099:     
1100:     @objc func handleSaveFile() {
1101:         NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
1102:     }
1103:     
1104:     @objc func handleCloseTab() {
1105:         NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
1106:     }
1107:     
1108:     @objc func handleFind() {
1109:         NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
1110:     }
1111:     
1112:     @objc func handleZoomIn() {
1113:         NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
1114:     }
1115:     
1116:     @objc func handleZoomOut() {
1117:         NotificationCenter.default.post(name: NSNotification.Name("ZoomOut"), object: nil)
1118:     }
1119:     
1120:     // MARK: - Custom Actions
1121:     
1122:     @objc private func goToDefinition(_ sender: Any?) {
1123:         onGoToDefinition?()
1124:     }
1125:     
1126:     @objc private func peekDefinition(_ sender: Any?) {
1127:         onPeekDefinition?()
1128:     }
1129:     
1130:     @objc private func findReferences(_ sender: Any?) {
1131:         onFindReferences?()
1132:     }
1133:     
1134:     @objc private func formatDocument(_ sender: Any?) {
1135:         onFormatDocument?()
1136:     }
1137:     
1138:     @objc private func toggleComment(_ sender: Any?) {
1139:         onToggleComment?()
1140:     }


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":740,"end_line":920}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 741-920 of 1995)
────────────────────────────────────────
741:             }
742: 
743:             guard let match = matchIndex else { return }
744: 
745:             let r1 = NSRange(location: idx, length: 1)
746:             let r2 = NSRange(location: match, length: 1)
747: 
748:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
749:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
750: 
751:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
752:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
753: 
754:             bracketHighlightRanges = [r1, r2]
755:         }
756:     }
757: }
758: 
759: // Custom text view to handle key commands, indent guides, and line highlighting
760: class EditorTextView: UITextView {
761:     var onPeekDefinition: (() -> Void)?
762:     var onEscape: (() -> Void)?
763:     var onGoToLine: (() -> Void)?
764:     
765:     // Custom action closures for context menu
766:     var onGoToDefinition: (() -> Void)?
767:     var onFindReferences: (() -> Void)?
768:     var onFormatDocument: (() -> Void)?
769:     var onToggleComment: (() -> Void)?
770:     var onFold: (() -> Void)?
771:     var onUnfold: (() -> Void)?
772: 
773:     // Autocomplete key handling hooks (return true if handled)
774:     var onAcceptAutocomplete: (() -> Bool)?
775:     var onDismissAutocomplete: (() -> Bool)?
776:     
777:     // FEAT-039 & FEAT-043
778:     private var indentGuideColor: UIColor = .separator
779:     private var activeIndentGuideColor: UIColor = .label
780:     private var currentLineHighlightColor: UIColor = .clear
781:     
782:     override init(frame: CGRect, textContainer: NSTextContainer?) {
783:         super.init(frame: frame, textContainer: textContainer)
784:         setup()
785:     }
786:     
787:     required init?(coder: NSCoder) {
788:         super.init(coder: coder)
789:         setup()
790:     }
791:     
792:     private func setup() {
793:         // Ensure we redraw when bounds/selection change
794:         contentMode = .redraw
795:     }
796:     
797:     func updateThemeColors(theme: Theme) {
798:         self.indentGuideColor = UIColor(theme.indentGuide)
799:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
800:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
801:         setNeedsDisplay()
802:     }
803:     
804:     override func draw(_ rect: CGRect) {
805:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
806:             super.draw(rect)
807:             return
808:         }
809:         
810:         // 1. Draw Current Line Highlight (FEAT-043)
811:         if let selectedRange = selectedTextRange {
812:             // Get the line rect for the cursor position
813:             let caretRect = self.caretRect(for: selectedRange.start)
814:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
815:             
816:             context.setFillColor(currentLineHighlightColor.cgColor)
817:             context.fill(lineRect)
818:         }
819:         
820:         // 2. Draw Text (super implementation)
821:         super.draw(rect)
822:         
823:         // 3. Draw Indent Guides (FEAT-039)
824:         // We iterate visible lines and draw vertical lines for indentation
825:         // Optimization: Only draw for visible range
826: 
827:         context.setLineWidth(1.0)
828: 
829:         // Respect editor tab size setting (default 4)
830:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
831:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
832: 
833:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
834:         let indentWidth = spaceWidth * CGFloat(tabSize)
835: 
836:         // Determine active indent level for caret line (for indentGuideActive)
837:         var activeIndentLevel: Int = 0
838:         if let selected = selectedTextRange {
839:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
840:             let nsText = (self.text ?? "") as NSString
841:             let safeLoc = min(max(0, caretPos), nsText.length)
842:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
843:             let caretLineText = nsText.substring(with: caretLineRange)
844: 
845:             var spaces = 0
846:             for ch in caretLineText {
847:                 if ch == " " { spaces += 1 }
848:                 else if ch == "\t" { spaces += tabSize }
849:                 else { break }
850:             }
851:             activeIndentLevel = spaces / tabSize
852:         }
853: 
854:         // Iterate visible glyphs/lines
855:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
856:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
857: 
858:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
859: 
860:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
861:             // Get text for this line
862:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
863:                   let text = self.text as NSString? else { return }
864: 
865:             let lineText = text.substring(with: range)
866: 
867:             // Calculate indentation level
868:             var spaces = 0
869:             for char in lineText {
870:                 if char == " " { spaces += 1 }
871:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
872:                 else { break }
873:             }
874: 
875:             let indentLevel = spaces / tabSize
876:             guard indentLevel > 0 else { return }
877: 
878:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
879: 
880:             for i in 1...indentLevel {
881:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
882:                 let startPoint = CGPoint(x: x, y: rect.minY)
883:                 let endPoint = CGPoint(x: x, y: rect.maxY)
884: 
885:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
886:                 context.setStrokeColor(stroke.cgColor)
887: 
888:                 context.move(to: startPoint)
889:                 context.addLine(to: endPoint)
890:                 context.strokePath()
891:             }
892:         }
893:     }
894:     
895:     override var keyCommands: [UIKeyCommand]? {
896:         var commands = super.keyCommands ?? []
897:         
898:         // Peek Definition: Alt+F12 (using special key input)
899:         // Note: F12 is not directly available on iPadOS keyboards
900:         // Using Option+D as alternative
901:         commands.append(UIKeyCommand(
902:             input: "d",
903:             modifierFlags: .alternate,
904:             action: #selector(handlePeekDefinition)
905:         ))
906: 
907:         // Go to Line: Cmd+G
908:         commands.append(UIKeyCommand(
909:             input: "g",
910:             modifierFlags: .command,
911:             action: #selector(handleGoToLine)
912:         ))
913: 
914:         // Tab: accept autocomplete if visible, else insert tab
915:         commands.append(UIKeyCommand(
916:             input: "\t",
917:             modifierFlags: [],
918:             action: #selector(handleTab)
919:         ))
920:         


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":920,"end_line":1100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 921-1100 of 1995)
────────────────────────────────────────
921:         // Escape: dismiss autocomplete if visible, else normal escape behavior
922:         commands.append(UIKeyCommand(
923:             input: UIKeyCommand.inputEscape,
924:             modifierFlags: [],
925:             action: #selector(handleEscape)
926:         ))
927:         
928:         // Fold: Cmd+Opt+[
929:         commands.append(UIKeyCommand(
930:             input: "[",
931:             modifierFlags: [.command, .alternate],
932:             action: #selector(handleFold)
933:         ))
934:         
935:         // Unfold: Cmd+Opt+]
936:         commands.append(UIKeyCommand(
937:             input: "]",
938:             modifierFlags: [.command, .alternate],
939:             action: #selector(handleUnfold)
940:         ))
941:         
942:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
943:         // These post to NotificationCenter so ContentView can handle them
944:         
945:         // Command Palette: Cmd+Shift+P
946:         commands.append(UIKeyCommand(
947:             input: "p",
948:             modifierFlags: [.command, .shift],
949:             action: #selector(handleShowCommandPalette),
950:             discoverabilityTitle: "Command Palette"
951:         ))
952:         
953:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
954:         let toggleTerminalCmd = UIKeyCommand(
955:             input: "j",
956:             modifierFlags: .command,
957:             action: #selector(handleToggleTerminal),
958:             discoverabilityTitle: "Toggle Terminal"
959:         )
960:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
961:         commands.append(toggleTerminalCmd)
962:         
963:         // AI Assistant: Cmd+Shift+A
964:         commands.append(UIKeyCommand(
965:             input: "a",
966:             modifierFlags: [.command, .shift],
967:             action: #selector(handleShowAIAssistant),
968:             discoverabilityTitle: "AI Assistant"
969:         ))
970:         
971:         // Toggle Sidebar: Cmd+B
972:         commands.append(UIKeyCommand(
973:             input: "b",
974:             modifierFlags: .command,
975:             action: #selector(handleToggleSidebar),
976:             discoverabilityTitle: "Toggle Sidebar"
977:         ))
978:         
979:         // Quick Open: Cmd+P
980:         commands.append(UIKeyCommand(
981:             input: "p",
982:             modifierFlags: .command,
983:             action: #selector(handleShowQuickOpen),
984:             discoverabilityTitle: "Quick Open"
985:         ))
986:         
987:         // New File: Cmd+N
988:         let newFileCmd = UIKeyCommand(
989:             input: "n",
990:             modifierFlags: .command,
991:             action: #selector(handleNewFile),
992:             discoverabilityTitle: "New File"
993:         )
994:         newFileCmd.wantsPriorityOverSystemBehavior = true
995:         commands.append(newFileCmd)
996:         
997:         // Save: Cmd+S
998:         commands.append(UIKeyCommand(
999:             input: "s",
1000:             modifierFlags: .command,
1001:             action: #selector(handleSaveFile),
1002:             discoverabilityTitle: "Save"
1003:         ))
1004:         
1005:         // Close Tab: Cmd+W
1006:         let closeTabCmd = UIKeyCommand(
1007:             input: "w",
1008:             modifierFlags: .command,
1009:             action: #selector(handleCloseTab),
1010:             discoverabilityTitle: "Close Tab"
1011:         )
1012:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1013:         commands.append(closeTabCmd)
1014:         
1015:         // Find: Cmd+F
1016:         let findCmd = UIKeyCommand(
1017:             input: "f",
1018:             modifierFlags: .command,
1019:             action: #selector(handleFind),
1020:             discoverabilityTitle: "Find"
1021:         )
1022:         findCmd.wantsPriorityOverSystemBehavior = true
1023:         commands.append(findCmd)
1024:         
1025:         // Zoom In: Cmd+=
1026:         commands.append(UIKeyCommand(
1027:             input: "=",
1028:             modifierFlags: .command,
1029:             action: #selector(handleZoomIn),
1030:             discoverabilityTitle: "Zoom In"
1031:         ))
1032:         
1033:         // Zoom Out: Cmd+-
1034:         commands.append(UIKeyCommand(
1035:             input: "-",
1036:             modifierFlags: .command,
1037:             action: #selector(handleZoomOut),
1038:             discoverabilityTitle: "Zoom Out"
1039:         ))
1040:         
1041:         return commands
1042:     }
1043:     
1044:     @objc func handlePeekDefinition() {
1045:         onPeekDefinition?()
1046:     }
1047: 
1048:     @objc func handleGoToLine() {
1049:         onGoToLine?()
1050:     }
1051: 
1052:     @objc func handleTab() {
1053:         if onAcceptAutocomplete?() == true {
1054:             return
1055:         }
1056:         insertText("\t")
1057:     }
1058:     
1059:     @objc func handleEscape() {
1060:         if onDismissAutocomplete?() == true {
1061:             return
1062:         }
1063:         onEscape?()
1064:     }
1065:     
1066:     @objc func handleFold() {
1067:         onFold?()
1068:     }
1069:     
1070:     @objc func handleUnfold() {
1071:         onUnfold?()
1072:     }
1073:     
1074:     // MARK: - App-Level Shortcut Handlers
1075:     
1076:     @objc func handleShowCommandPalette() {
1077:         NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1078:     }
1079:     
1080:     @objc func handleToggleTerminal() {
1081:         NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1082:     }
1083:     
1084:     @objc func handleShowAIAssistant() {
1085:         NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1086:     }
1087:     
1088:     @objc func handleToggleSidebar() {
1089:         NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
1090:     }
1091:     
1092:     @objc func handleShowQuickOpen() {
1093:         NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
1094:     }
1095:     
1096:     @objc func handleNewFile() {
1097:         NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
1098:     }
1099:     
1100:     @objc func handleSaveFile() {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":740,"end_line":940}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 741-940 of 1995)
────────────────────────────────────────
741:             }
742: 
743:             guard let match = matchIndex else { return }
744: 
745:             let r1 = NSRange(location: idx, length: 1)
746:             let r2 = NSRange(location: match, length: 1)
747: 
748:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
749:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
750: 
751:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
752:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
753: 
754:             bracketHighlightRanges = [r1, r2]
755:         }
756:     }
757: }
758: 
759: // Custom text view to handle key commands, indent guides, and line highlighting
760: class EditorTextView: UITextView {
761:     var onPeekDefinition: (() -> Void)?
762:     var onEscape: (() -> Void)?
763:     var onGoToLine: (() -> Void)?
764:     
765:     // Custom action closures for context menu
766:     var onGoToDefinition: (() -> Void)?
767:     var onFindReferences: (() -> Void)?
768:     var onFormatDocument: (() -> Void)?
769:     var onToggleComment: (() -> Void)?
770:     var onFold: (() -> Void)?
771:     var onUnfold: (() -> Void)?
772: 
773:     // Autocomplete key handling hooks (return true if handled)
774:     var onAcceptAutocomplete: (() -> Bool)?
775:     var onDismissAutocomplete: (() -> Bool)?
776:     
777:     // FEAT-039 & FEAT-043
778:     private var indentGuideColor: UIColor = .separator
779:     private var activeIndentGuideColor: UIColor = .label
780:     private var currentLineHighlightColor: UIColor = .clear
781:     
782:     override init(frame: CGRect, textContainer: NSTextContainer?) {
783:         super.init(frame: frame, textContainer: textContainer)
784:         setup()
785:     }
786:     
787:     required init?(coder: NSCoder) {
788:         super.init(coder: coder)
789:         setup()
790:     }
791:     
792:     private func setup() {
793:         // Ensure we redraw when bounds/selection change
794:         contentMode = .redraw
795:     }
796:     
797:     func updateThemeColors(theme: Theme) {
798:         self.indentGuideColor = UIColor(theme.indentGuide)
799:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
800:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
801:         setNeedsDisplay()
802:     }
803:     
804:     override func draw(_ rect: CGRect) {
805:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
806:             super.draw(rect)
807:             return
808:         }
809:         
810:         // 1. Draw Current Line Highlight (FEAT-043)
811:         if let selectedRange = selectedTextRange {
812:             // Get the line rect for the cursor position
813:             let caretRect = self.caretRect(for: selectedRange.start)
814:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
815:             
816:             context.setFillColor(currentLineHighlightColor.cgColor)
817:             context.fill(lineRect)
818:         }
819:         
820:         // 2. Draw Text (super implementation)
821:         super.draw(rect)
822:         
823:         // 3. Draw Indent Guides (FEAT-039)
824:         // We iterate visible lines and draw vertical lines for indentation
825:         // Optimization: Only draw for visible range
826: 
827:         context.setLineWidth(1.0)
828: 
829:         // Respect editor tab size setting (default 4)
830:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
831:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
832: 
833:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
834:         let indentWidth = spaceWidth * CGFloat(tabSize)
835: 
836:         // Determine active indent level for caret line (for indentGuideActive)
837:         var activeIndentLevel: Int = 0
838:         if let selected = selectedTextRange {
839:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
840:             let nsText = (self.text ?? "") as NSString
841:             let safeLoc = min(max(0, caretPos), nsText.length)
842:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
843:             let caretLineText = nsText.substring(with: caretLineRange)
844: 
845:             var spaces = 0
846:             for ch in caretLineText {
847:                 if ch == " " { spaces += 1 }
848:                 else if ch == "\t" { spaces += tabSize }
849:                 else { break }
850:             }
851:             activeIndentLevel = spaces / tabSize
852:         }
853: 
854:         // Iterate visible glyphs/lines
855:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
856:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
857: 
858:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
859: 
860:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
861:             // Get text for this line
862:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
863:                   let text = self.text as NSString? else { return }
864: 
865:             let lineText = text.substring(with: range)
866: 
867:             // Calculate indentation level
868:             var spaces = 0
869:             for char in lineText {
870:                 if char == " " { spaces += 1 }
871:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
872:                 else { break }
873:             }
874: 
875:             let indentLevel = spaces / tabSize
876:             guard indentLevel > 0 else { return }
877: 
878:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
879: 
880:             for i in 1...indentLevel {
881:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
882:                 let startPoint = CGPoint(x: x, y: rect.minY)
883:                 let endPoint = CGPoint(x: x, y: rect.maxY)
884: 
885:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
886:                 context.setStrokeColor(stroke.cgColor)
887: 
888:                 context.move(to: startPoint)
889:                 context.addLine(to: endPoint)
890:                 context.strokePath()
891:             }
892:         }
893:     }
894:     
895:     override var keyCommands: [UIKeyCommand]? {
896:         var commands = super.keyCommands ?? []
897:         
898:         // Peek Definition: Alt+F12 (using special key input)
899:         // Note: F12 is not directly available on iPadOS keyboards
900:         // Using Option+D as alternative
901:         commands.append(UIKeyCommand(
902:             input: "d",
903:             modifierFlags: .alternate,
904:             action: #selector(handlePeekDefinition)
905:         ))
906: 
907:         // Go to Line: Cmd+G
908:         commands.append(UIKeyCommand(
909:             input: "g",
910:             modifierFlags: .command,
911:             action: #selector(handleGoToLine)
912:         ))
913: 
914:         // Tab: accept autocomplete if visible, else insert tab
915:         commands.append(UIKeyCommand(
916:             input: "\t",
917:             modifierFlags: [],
918:             action: #selector(handleTab)
919:         ))
920:         
921:         // Escape: dismiss autocomplete if visible, else normal escape behavior
922:         commands.append(UIKeyCommand(
923:             input: UIKeyCommand.inputEscape,
924:             modifierFlags: [],
925:             action: #selector(handleEscape)
926:         ))
927:         
928:         // Fold: Cmd+Opt+[
929:         commands.append(UIKeyCommand(
930:             input: "[",
931:             modifierFlags: [.command, .alternate],
932:             action: #selector(handleFold)
933:         ))
934:         
935:         // Unfold: Cmd+Opt+]
936:         commands.append(UIKeyCommand(
937:             input: "]",
938:             modifierFlags: [.command, .alternate],
939:             action: #selector(handleUnfold)
940:         ))


>>>TOOL search
{"query":"applySyntaxHighlighting", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 8 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:188: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:205: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:224: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:239: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:244: context.coordinator.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:316: applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:336: self?.applySyntaxHighlighting(to: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:495: func applySyntaxHighlighting(to textView: UITextView) {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":440,"end_line":640}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 441-640 of 1995)
────────────────────────────────────────
441:             // updateUIView sees old binding value != lastKnownScrollPosition
442:             // and scrolls back to the old position, causing jaggy scrolling.
443:             lastKnownScrollPosition = line
444:             parent.scrollPosition = line
445:         }
446:         
447:         func scrollToLine(_ line: Int, in textView: UITextView) {
448:             guard !isUpdatingFromMinimap else { return }
449:             isUpdatingFromMinimap = true
450:             
451:             let lines = textView.text.components(separatedBy: .newlines)
452:             guard line >= 0 && line < lines.count else {
453:                 isUpdatingFromMinimap = false
454:                 return
455:             }
456:             
457:             var characterPosition = 0
458:             for i in 0..<line {
459:                 characterPosition += lines[i].count + 1
460:             }
461:             
462:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
463:                 let rect = textView.caretRect(for: position)
464:                 let targetY = max(0, rect.origin.y)
465:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
466:             }
467:             
468:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
469:                 self.isUpdatingFromMinimap = false
470:             }
471:         }
472: 
473:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
474:             let lines = textView.text.components(separatedBy: .newlines)
475:             guard line >= 0 && line < lines.count else { return }
476: 
477:             var characterPosition = 0
478:             for i in 0..<line {
479:                 characterPosition += lines[i].count + 1
480:             }
481: 
482:             // FEAT-041: select entire line (excluding trailing newline)
483:             let lineLength = (lines[line] as NSString).length
484:             let range = NSRange(location: characterPosition, length: lineLength)
485:             textView.selectedRange = range
486: 
487:             // Ensure it's visible
488:             scrollToLine(line, in: textView)
489: 
490:             // Update SwiftUI state
491:             updateCursorPosition(textView)
492:             updateScrollPosition(textView)
493:         }
494: 
495:         func applySyntaxHighlighting(to textView: UITextView) {
496:             let theme = ThemeManager.shared.currentTheme
497:             lastThemeId = theme.id
498: 
499:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
500:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
501: 
502:             let selectedRange = textView.selectedRange
503:             textView.attributedText = attributedText
504:             textView.selectedRange = selectedRange
505: 
506:             // Set typing attributes so newly typed characters have correct base styling
507:             // This prevents flicker during the debounce period before full highlighting runs
508:             let fontSize = parent.editorCore.editorFontSize
509:             textView.typingAttributes = [
510:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
511:                 .foregroundColor: UIColor(theme.editorForeground)
512:             ]
513: 
514:             // FEAT-044: restore matching bracket highlight after re-attributing text
515:             updateMatchingBracketHighlight(textView)
516:         }
517:         
518:         func handlePeekDefinition(in textView: UITextView) {
519:             guard let selectedRange = textView.selectedTextRange else { return }
520:             let text = textView.text ?? ""
521:             
522:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
523:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
524:                  
525:                  let prefix = String(text.prefix(location))
526:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
527:                  
528:                  parent.editorCore.triggerPeekDefinition(
529:                      file: parent.filename,
530:                      line: sourceLine,
531:                      content: text,
532:                      sourceLine: sourceLine
533:                  )
534:             }
535:         }
536:         
537:         func handleEscape() {
538:             if parent.editorCore.peekState != nil {
539:                 parent.editorCore.closePeekDefinition()
540:             } else {
541:                 parent.editorCore.escapeMultiCursor()
542:             }
543:         }
544:         
545:         func handleGoToDefinition(in textView: UITextView) {
546:             // Reuse the peek definition logic for now
547:             handlePeekDefinition(in: textView)
548:         }
549:         
550:         func handleFindReferences(in textView: UITextView) {
551:             guard let selectedRange = textView.selectedTextRange else { return }
552:             let text = textView.text ?? ""
553:             
554:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
555:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
556:                 
557:                 let prefix = String(text.prefix(location))
558:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
559:                 
560:                 // TODO: Implement find references functionality in EditorCore
561:                 // For now, just trigger peek definition as a placeholder
562:                 parent.editorCore.triggerPeekDefinition(
563:                     file: parent.filename,
564:                     line: sourceLine,
565:                     content: text,
566:                     sourceLine: sourceLine
567:                 )
568:             }
569:         }
570:         
571:         func handleFormatDocument(in textView: UITextView) {
572:             // TODO: Implement format document functionality
573:             // This would typically call a formatter in EditorCore
574:             print("Format Document: Not yet implemented")
575:         }
576:         
577:         func handleToggleComment(in textView: UITextView) {
578:             guard let selectedRange = textView.selectedTextRange else { return }
579:             let text = textView.text ?? ""
580:             
581:             // Get the current line range
582:             if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
583:                 let location = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
584:                 let length = textView.offset(from: lineRange.start, to: lineRange.end)
585:                 let nsRange = NSRange(location: location, length: length)
586:                 
587:                 if nsRange.location + nsRange.length <= (text as NSString).length {
588:                     let lineText = (text as NSString).substring(with: nsRange)
589:                     let trimmed = lineText.trimmingCharacters(in: .whitespaces)
590:                     
591:                     // Check if line starts with a comment
592:                     let isCommented = trimmed.hasPrefix("//") || trimmed.hasPrefix("#") || trimmed.hasPrefix("/*")
593:                     
594:                     // Toggle comment
595:                     var newLineText: String
596:                     if isCommented {
597:                         // Remove comment
598:                         newLineText = lineText.replacingOccurrences(of: "//", with: "").replacingOccurrences(of: "#", with: "", options: .anchored)
599:                     } else {
600:                         // Add comment (use // for most languages)
601:                         newLineText = "//" + lineText
602:                     }
603:                     
604:                     // Replace the line
605:                     let textStorage = textView.textStorage
606:                     textStorage.replaceCharacters(in: nsRange, with: newLineText)
607:                     
608:                     // Update parent binding
609:                     parent.text = textView.text
610:                 }
611:             }
612:         }
613:         
614:         func handleFold(in textView: UITextView) {
615:             CodeFoldingManager.shared.foldCurrentLine()
616:         }
617:         
618:         func handleUnfold(in textView: UITextView) {
619:             CodeFoldingManager.shared.unfoldCurrentLine()
620:         }
621:         
622:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
623:             guard let textView = gesture.view as? UITextView else { return }
624: 
625:             switch gesture.state {
626:             case .began:
627:                 // Store the initial font size when pinch begins
628:                 initialFontSize = parent.editorCore.editorFontSize
629: 
630:             case .changed:
631:                 // Calculate new font size based on pinch scale
632:                 let newSize = initialFontSize * gesture.scale
633: 
634:                 // Clamp font size between 8 and 32
635:                 let clampedSize = min(max(newSize, 8), 32)
636: 
637:                 // Update EditorCore's font size (this will trigger updateUIView)
638:                 parent.editorCore.editorFontSize = clampedSize
639: 
640:             case .ended, .cancelled:


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1120,"end_line":1185}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1121-1185 of 1995)
────────────────────────────────────────
1121:     
1122:     @objc private func goToDefinition(_ sender: Any?) {
1123:         onGoToDefinition?()
1124:     }
1125:     
1126:     @objc private func peekDefinition(_ sender: Any?) {
1127:         onPeekDefinition?()
1128:     }
1129:     
1130:     @objc private func findReferences(_ sender: Any?) {
1131:         onFindReferences?()
1132:     }
1133:     
1134:     @objc private func formatDocument(_ sender: Any?) {
1135:         onFormatDocument?()
1136:     }
1137:     
1138:     @objc private func toggleComment(_ sender: Any?) {
1139:         onToggleComment?()
1140:     }
1141:     
1142:     // MARK: - Menu Support
1143:     
1144:     override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
1145:         // Enable custom actions
1146:         if action == #selector(goToDefinition(_:)) {
1147:             return onGoToDefinition != nil
1148:         }
1149:         if action == #selector(peekDefinition(_:)) {
1150:             return onPeekDefinition != nil
1151:         }
1152:         if action == #selector(findReferences(_:)) {
1153:             return onFindReferences != nil
1154:         }
1155:         if action == #selector(formatDocument(_:)) {
1156:             return onFormatDocument != nil
1157:         }
1158:         if action == #selector(toggleComment(_:)) {
1159:             return onToggleComment != nil
1160:         }
1161:         
1162:         return super.canPerformAction(action, withSender: sender)
1163:     }
1164:     
1165:     override func buildMenu(with builder: UIMenuBuilder) {
1166:         super.buildMenu(with: builder)
1167:         
1168:         guard builder.menu(for: .text) != nil else { return }
1169:         
1170:         // Create custom menu items
1171:         let goToDefinitionAction = UIAction(
1172:             title: "Go to Definition",
1173:             image: UIImage(systemName: "arrow.forward.circle"),
1174:             identifier: UIAction.Identifier("com.vscode.goToDefinition"),
1175:             handler: { [weak self] _ in
1176:                 self?.goToDefinition(nil)
1177:             }
1178:         )
1179:         
1180:         let peekDefinitionAction = UIAction(
1181:             title: "Peek Definition",
1182:             image: UIImage(systemName: "eye"),
1183:             identifier: UIAction.Identifier("com.vscode.peekDefinition"),
1184:             handler: { [weak self] _ in
1185:                 self?.peekDefinition(nil)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":460,"end_line":580}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 461-580 of 1995)
────────────────────────────────────────
461:             
462:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
463:                 let rect = textView.caretRect(for: position)
464:                 let targetY = max(0, rect.origin.y)
465:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
466:             }
467:             
468:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
469:                 self.isUpdatingFromMinimap = false
470:             }
471:         }
472: 
473:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
474:             let lines = textView.text.components(separatedBy: .newlines)
475:             guard line >= 0 && line < lines.count else { return }
476: 
477:             var characterPosition = 0
478:             for i in 0..<line {
479:                 characterPosition += lines[i].count + 1
480:             }
481: 
482:             // FEAT-041: select entire line (excluding trailing newline)
483:             let lineLength = (lines[line] as NSString).length
484:             let range = NSRange(location: characterPosition, length: lineLength)
485:             textView.selectedRange = range
486: 
487:             // Ensure it's visible
488:             scrollToLine(line, in: textView)
489: 
490:             // Update SwiftUI state
491:             updateCursorPosition(textView)
492:             updateScrollPosition(textView)
493:         }
494: 
495:         func applySyntaxHighlighting(to textView: UITextView) {
496:             let theme = ThemeManager.shared.currentTheme
497:             lastThemeId = theme.id
498: 
499:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
500:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
501: 
502:             let selectedRange = textView.selectedRange
503:             textView.attributedText = attributedText
504:             textView.selectedRange = selectedRange
505: 
506:             // Set typing attributes so newly typed characters have correct base styling
507:             // This prevents flicker during the debounce period before full highlighting runs
508:             let fontSize = parent.editorCore.editorFontSize
509:             textView.typingAttributes = [
510:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
511:                 .foregroundColor: UIColor(theme.editorForeground)
512:             ]
513: 
514:             // FEAT-044: restore matching bracket highlight after re-attributing text
515:             updateMatchingBracketHighlight(textView)
516:         }
517:         
518:         func handlePeekDefinition(in textView: UITextView) {
519:             guard let selectedRange = textView.selectedTextRange else { return }
520:             let text = textView.text ?? ""
521:             
522:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
523:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
524:                  
525:                  let prefix = String(text.prefix(location))
526:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
527:                  
528:                  parent.editorCore.triggerPeekDefinition(
529:                      file: parent.filename,
530:                      line: sourceLine,
531:                      content: text,
532:                      sourceLine: sourceLine
533:                  )
534:             }
535:         }
536:         
537:         func handleEscape() {
538:             if parent.editorCore.peekState != nil {
539:                 parent.editorCore.closePeekDefinition()
540:             } else {
541:                 parent.editorCore.escapeMultiCursor()
542:             }
543:         }
544:         
545:         func handleGoToDefinition(in textView: UITextView) {
546:             // Reuse the peek definition logic for now
547:             handlePeekDefinition(in: textView)
548:         }
549:         
550:         func handleFindReferences(in textView: UITextView) {
551:             guard let selectedRange = textView.selectedTextRange else { return }
552:             let text = textView.text ?? ""
553:             
554:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
555:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
556:                 
557:                 let prefix = String(text.prefix(location))
558:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
559:                 
560:                 // TODO: Implement find references functionality in EditorCore
561:                 // For now, just trigger peek definition as a placeholder
562:                 parent.editorCore.triggerPeekDefinition(
563:                     file: parent.filename,
564:                     line: sourceLine,
565:                     content: text,
566:                     sourceLine: sourceLine
567:                 )
568:             }
569:         }
570:         
571:         func handleFormatDocument(in textView: UITextView) {
572:             // TODO: Implement format document functionality
573:             // This would typically call a formatter in EditorCore
574:             print("Format Document: Not yet implemented")
575:         }
576:         
577:         func handleToggleComment(in textView: UITextView) {
578:             guard let selectedRange = textView.selectedTextRange else { return }
579:             let text = textView.text ?? ""
580:             


>>>TOOL search
{"query":"override var undoManager", "glob":"**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "override var undoManager"


>>>TOOL search
{"query":"textView.text =", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:187: textView.text = text
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:238: textView.text = text


>>>TOOL search
{"query":"removeAllActions", "glob":"**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "removeAllActions"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":200,"end_line":320}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 201-320 of 1995)
────────────────────────────────────────
201:         // This fixes the bug where syntax highlighting only appears after typing.
202:         // makeUIView applies it, but the view may not be fully in hierarchy yet,
203:         // causing the attributed text to be lost. This ensures it's applied reliably.
204:         if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
205:             context.coordinator.applySyntaxHighlighting(to: textView)
206:             context.coordinator.hasAppliedInitialHighlighting = true
207:         }
208:         
209:         // Update colors when theme changes
210:         // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor
211:         // as it interferes with attributedText syntax highlighting colors.
212:         // The foreground color is handled entirely by the attributedText.
213:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
214:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
215:         
216:         if let editorView = textView as? EditorTextView {
217:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
218:         }
219:         
220:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
221:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
222:             let selectedRange = textView.selectedRange
223:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
224:             context.coordinator.applySyntaxHighlighting(to: textView)
225:             textView.selectedRange = selectedRange
226:             
227:             // Update line height
228:             if let font = textView.font {
229:                 DispatchQueue.main.async {
230:                     self.lineHeight = font.lineHeight
231:                 }
232:             }
233:         }
234:         
235:         // Update text if changed externally
236:         if textView.text != text {
237:             let selectedRange = textView.selectedRange
238:             textView.text = text
239:             context.coordinator.applySyntaxHighlighting(to: textView)
240:             context.coordinator.hasAppliedInitialHighlighting = true
241:             textView.selectedRange = selectedRange
242:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
243:             // Re-apply highlighting if theme changed
244:             context.coordinator.applySyntaxHighlighting(to: textView)
245:         }
246:         
247:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
248:         // This prevents the editor from fighting against user scroll due to async binding lag
249:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
250:             // Update lastKnownScrollPosition FIRST to prevent race condition
251:             // where user scroll gets overridden by stale binding value
252:             context.coordinator.lastKnownScrollPosition = scrollPosition
253:             context.coordinator.scrollToLine(scrollPosition, in: textView)
254:         }
255: 
256:         // Handle line selection requests (e.g. tapping line numbers)
257:         if let requested = requestedLineSelection,
258:            requested != context.coordinator.lastRequestedLineSelection {
259:             context.coordinator.lastRequestedLineSelection = requested
260:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
261:             // Defer @Binding update to avoid "Publishing changes from within view updates"
262:             DispatchQueue.main.async {
263:                 self.requestedLineSelection = nil
264:             }
265:         }
266: 
267:         // Handle cursor index requests (e.g. accepting autocomplete)
268:         if let requested = requestedCursorIndex,
269:            requested != context.coordinator.lastRequestedCursorIndex {
270:             context.coordinator.lastRequestedCursorIndex = requested
271:             textView.selectedRange = NSRange(location: max(0, requested), length: 0)
272:             // Defer @Binding update to avoid "Publishing changes from within view updates"
273:             DispatchQueue.main.async {
274:                 self.requestedCursorIndex = nil
275:             }
276: 
277:             // Update SwiftUI state
278:             context.coordinator.updateCursorPosition(textView)
279:             context.coordinator.updateScrollPosition(textView)
280:         }
281:         
282:         // Note: updateLineCount is called in textViewDidChange, no need to call here
283:         // as it causes unnecessary state churn on every updateUIView
284:     }
285:     
286:     // MARK: - Coordinator
287:     
288:     class Coordinator: NSObject, UITextViewDelegate {
289:         var parent: SyntaxHighlightingTextView
290:         var lastKnownScrollPosition: Int = 0
291:         var lastThemeId: String = ""
292:         var lastRequestedLineSelection: Int? = nil
293:         var lastRequestedCursorIndex: Int? = nil
294:         private var isUpdatingFromMinimap = false
295:         private var highlightDebouncer: Timer?
296:         weak var pinchGesture: UIPinchGestureRecognizer?
297:         private var initialFontSize: CGFloat = 0
298:         
299:         // Track user scroll to prevent programmatic scroll fighting back
300:         private var userScrollDebouncer: Timer?
301:         var isUserScrolling = false
302: 
303:         // FEAT-044: Matching bracket highlight state
304:         private var bracketHighlightRanges: [NSRange] = []
305:         
306:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
307:         var hasAppliedInitialHighlighting = false
308:         
309:         init(_ parent: SyntaxHighlightingTextView) {
310:             self.parent = parent
311:         }
312:         
313:         func textViewDidBeginEditing(_ textView: UITextView) {
314:             // Ensure syntax highlighting is current when user begins editing
315:             // This handles cases where text was set but highlighting hasn't run yet
316:             applySyntaxHighlighting(to: textView)
317:         }
318:         
319:         func textViewDidChange(_ textView: UITextView) {
320:             // Update parent text


>>>TOOL search
{"query":"disableUndoRegistration", "glob":"**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "disableUndoRegistration"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":160,"end_line":280}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 161-280 of 281)
────────────────────────────────────────
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
203: 
204: extension MultiCursorTextView {
205: 
206:     override var keyCommands: [UIKeyCommand]? {
207:         var commands = super.keyCommands ?? []
208: 
209:         // Tab: accept autocomplete (if showing), else insert tab
210:         commands.append(UIKeyCommand(
211:             title: "Accept Suggestion",
212:             action: #selector(tabAcceptAutocomplete),
213:             input: "\t",
214:             modifierFlags: []
215:         ))
216: 
217:         // Cmd+D: Add next occurrence
218:         commands.append(UIKeyCommand(
219:             title: "Add Next Occurrence",
220:             action: #selector(addNextOccurrence),
221:             input: "d",
222:             modifierFlags: .command
223:         ))
224: 
225:         // Cmd+Shift+L: Select all occurrences
226:         commands.append(UIKeyCommand(
227:             title: "Select All Occurrences",
228:             action: #selector(selectAllOccurrences),
229:             input: "l",
230:             modifierFlags: [.command, .shift]
231:         ))
232: 
233:         // Cmd+G: Go to Line
234:         commands.append(UIKeyCommand(
235:             title: "Go to Line",
236:             action: #selector(goToLine),
237:             input: "g",
238:             modifierFlags: .command
239:         ))
240: 
241:         // Escape: Dismiss autocomplete if visible, else exit multi-cursor mode
242:         commands.append(UIKeyCommand(
243:             title: "Escape",
244:             action: #selector(escapeKeyPressed),
245:             input: UIKeyCommand.inputEscape,
246:             modifierFlags: []
247:         ))
248: 
249:         return commands
250:     }
251: 
252:     @objc private func tabAcceptAutocomplete() {
253:         if onAcceptAutocomplete?() == true {
254:             return
255:         }
256:         insertText("\t")
257:     }
258: 
259:     @objc private func addNextOccurrence() {
260:         editorCore?.addNextOccurrence()
261:         updateCursorDisplay()
262:     }
263: 
264:     @objc private func selectAllOccurrences() {
265:         editorCore?.selectAllOccurrences()
266:         updateCursorDisplay()
267:     }
268: 
269:     @objc private func goToLine() {
270:         editorCore?.showGoToLine = true
271:     }
272: 
273:     @objc private func escapeKeyPressed() {
274:         if onDismissAutocomplete?() == true {
275:             return
276:         }
277:         editorCore?.escapeMultiCursor()
278:         updateCursorDisplay()
279:     }
280: }


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":320,"end_line":460}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 321-460 of 1995)
────────────────────────────────────────
321:             parent.text = textView.text
322:             
323:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
324:             // This prevents flicker during the debounce period
325:             let theme = ThemeManager.shared.currentTheme
326:             let fontSize = parent.editorCore.editorFontSize
327:             textView.typingAttributes = [
328:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
329:                 .foregroundColor: UIColor(theme.editorForeground)
330:             ]
331:             
332:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
333:             highlightDebouncer?.invalidate()
334:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
335:                 DispatchQueue.main.async {
336:                     self?.applySyntaxHighlighting(to: textView)
337:                 }
338:             }
339:             
340:             updateLineCount(textView)
341:             updateCursorPosition(textView)
342:         }
343:         
344:         func textViewDidChangeSelection(_ textView: UITextView) {
345:             if !isUpdatingFromMinimap {
346:                 updateCursorPosition(textView)
347:                 updateScrollPosition(textView)
348: 
349:                 // FEAT-044: Matching bracket highlight
350:                 updateMatchingBracketHighlight(textView)
351: 
352:                 // Trigger redraw so current-line highlight/indent guides track the caret
353:                 (textView as? EditorTextView)?.setNeedsDisplay()
354: 
355:                 // Update selection in EditorCore for multi-cursor support
356:                 let range = textView.selectedRange
357:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
358: 
359:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
360:                 if !parent.editorCore.multiCursorState.isMultiCursor {
361:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
362:                 }
363:             }
364:         }
365:         
366:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
367:         
368:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
369:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
370:             isUserScrolling = true
371:             userScrollDebouncer?.invalidate()
372:         }
373:         
374:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
375:             // If not decelerating, user stopped scrolling
376:             if !decelerate {
377:                 // Small delay to let any final scroll events settle
378:                 userScrollDebouncer?.invalidate()
379:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
380:                     self?.isUserScrolling = false
381:                 }
382:             }
383:         }
384:         
385:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
386:             // Deceleration finished - user scroll is complete
387:             userScrollDebouncer?.invalidate()
388:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
389:                 self?.isUserScrolling = false
390:             }
391:         }
392:         
393:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
394:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
395:             
396:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
397:             // We still use debouncer as a fallback for edge cases
398:             if isUserScrolling {
399:                 userScrollDebouncer?.invalidate()
400:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
401:                     self?.isUserScrolling = false
402:                 }
403:             }
404:             
405:             updateScrollPosition(textView)
406:         }
407:         
408:         func updateLineCount(_ textView: UITextView) {
409:             let lines = textView.text.components(separatedBy: .newlines)
410:             DispatchQueue.main.async {
411:                 self.parent.totalLines = max(1, lines.count)
412:             }
413:         }
414:         
415:         func updateCursorPosition(_ textView: UITextView) {
416:             guard let selectedRange = textView.selectedTextRange else { return }
417:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
418:              
419:              let text = textView.text ?? ""
420:              let prefix = String(text.prefix(cursorPosition))
421:              let lines = prefix.components(separatedBy: .newlines)
422:              
423:              let lineNumber = lines.count
424:              let column = (lines.last?.count ?? 0) + 1
425:              
426:              DispatchQueue.main.async {
427:                  self.parent.currentLineNumber = lineNumber
428:                  self.parent.currentColumn = column
429:                  self.parent.cursorIndex = cursorPosition
430:              }
431:         }
432:         
433:         func updateScrollPosition(_ textView: UITextView) {
434:             guard let font = textView.font else { return }
435:             let lineHeight = font.lineHeight
436:             let scrollOffset = textView.contentOffset.y
437:             let line = Int(scrollOffset / lineHeight)
438:             
439:             // Update both synchronously to prevent feedback loop:
440:             // If we update parent.scrollPosition async, there's a race where
441:             // updateUIView sees old binding value != lastKnownScrollPosition
442:             // and scrolls back to the old position, causing jaggy scrolling.
443:             lastKnownScrollPosition = line
444:             parent.scrollPosition = line
445:         }
446:         
447:         func scrollToLine(_ line: Int, in textView: UITextView) {
448:             guard !isUpdatingFromMinimap else { return }
449:             isUpdatingFromMinimap = true
450:             
451:             let lines = textView.text.components(separatedBy: .newlines)
452:             guard line >= 0 && line < lines.count else {
453:                 isUpdatingFromMinimap = false
454:                 return
455:             }
456:             
457:             var characterPosition = 0
458:             for i in 0..<line {
459:                 characterPosition += lines[i].count + 1
460:             }


>>>TOOL search
{"query":"handleUndo", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "handleUndo"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":160,"end_line":210}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 161-210 of 1995)
────────────────────────────────────────
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
195:         // CRITICAL: Update coordinator's parent reference to current struct
196:         // SwiftUI creates new struct instances on each update, so this keeps
197:         // coordinator in sync with current bindings and properties
198:         context.coordinator.parent = self
199:         
200:         // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
201:         // This fixes the bug where syntax highlighting only appears after typing.
202:         // makeUIView applies it, but the view may not be fully in hierarchy yet,
203:         // causing the attributed text to be lost. This ensures it's applied reliably.
204:         if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
205:             context.coordinator.applySyntaxHighlighting(to: textView)
206:             context.coordinator.hasAppliedInitialHighlighting = true
207:         }
208:         
209:         // Update colors when theme changes
210:         // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":485,"end_line":525}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 486-525 of 1995)
────────────────────────────────────────
486: 
487:             // Ensure it's visible
488:             scrollToLine(line, in: textView)
489: 
490:             // Update SwiftUI state
491:             updateCursorPosition(textView)
492:             updateScrollPosition(textView)
493:         }
494: 
495:         func applySyntaxHighlighting(to textView: UITextView) {
496:             let theme = ThemeManager.shared.currentTheme
497:             lastThemeId = theme.id
498: 
499:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
500:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
501: 
502:             let selectedRange = textView.selectedRange
503:             textView.attributedText = attributedText
504:             textView.selectedRange = selectedRange
505: 
506:             // Set typing attributes so newly typed characters have correct base styling
507:             // This prevents flicker during the debounce period before full highlighting runs
508:             let fontSize = parent.editorCore.editorFontSize
509:             textView.typingAttributes = [
510:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
511:                 .foregroundColor: UIColor(theme.editorForeground)
512:             ]
513: 
514:             // FEAT-044: restore matching bracket highlight after re-attributing text
515:             updateMatchingBracketHighlight(textView)
516:         }
517:         
518:         func handlePeekDefinition(in textView: UITextView) {
519:             guard let selectedRange = textView.selectedTextRange else { return }
520:             let text = textView.text ?? ""
521:             
522:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
523:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
524:                  
525:                  let prefix = String(text.prefix(location))


>>>TOOL web_search
{"query":"iOS UIKeyCommand undo redo selector #selector", "max_results":5}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "iOS UIKeyCommand undo redo selector #selector" (5 results):

1. **UIKeyCommand | Apple Developer Documentation**
   https://developer.apple.com/documentation/uikit/uikeycommand
   Class UIKeyCommand An object that specifies a key press perform on a hardware keyboard and the resulting action. iOS 7.0+ iPadOS 7.0+ Mac Catalyst 13.1+ tvOS visionOS 1.0+

2. **ios - Implementing Undo/Redo Feature in UITextView with IME Support ...**
   https://stackoverflow.com/questions/78666113/implementing-undo-redo-feature-in-uitextview-with-ime-support
   Currently, we are implementing an undo/redo feature in UITextView. However, we cannot use the built-in UndoManager in UITextView because we have multiple UITextView instances inside a UICollectionV...

3. **How to use UIKeyCommand to add keyboard shortcuts**
   https://www.hackingwithswift.com/example-code/uikit/how-to-use-uikeycommand-to-add-keyboard-shortcuts
   You attach an array of these to each view controller that should respond to keyboard shortcuts, and iOS will take care of advertising and responding to them. The basic use of UIKeyCommand is this: let search = UIKeyCommand(input: &quot;f&quot;, modifierFlags: .command, action: #selector(findFriends), discoverabilityTitle: &quot;Find Friends&quot;)

4. **GitHub - brunophilipe/KeyCommandKit: UIKeyCommand registration ...**
   https://github.com/brunophilipe/KeyCommandKit
   This is a self-contained library that allows users of your App to customize the key commands you use in your App. It does this by defining key binding providers, key command factories, and a built-in interface to list and customize the key bindings used by your App. This library provides everything you need to allow user customization of key commands, so integrating it to your app is not a one ...

5. **UIKeyCommand how-to add keyboard shortcuts &amp; speed up your workflow**
   https://www.avanderlee.com/swift/uikeycommand-keyboard-shortcuts/
   Learn how to implement the UIKeyCommand to add keyboard shortcuts to classes like the UITabBarController and UICollectionView and use them in the simulator.


>>>TOOL search
{"query":"input: \"z\"", "glob":"**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "input: "z""


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":888,"end_line":1065}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 889-1065 of 1995)
────────────────────────────────────────
889:                 context.addLine(to: endPoint)
890:                 context.strokePath()
891:             }
892:         }
893:     }
894:     
895:     override var keyCommands: [UIKeyCommand]? {
896:         var commands = super.keyCommands ?? []
897:         
898:         // Peek Definition: Alt+F12 (using special key input)
899:         // Note: F12 is not directly available on iPadOS keyboards
900:         // Using Option+D as alternative
901:         commands.append(UIKeyCommand(
902:             input: "d",
903:             modifierFlags: .alternate,
904:             action: #selector(handlePeekDefinition)
905:         ))
906: 
907:         // Go to Line: Cmd+G
908:         commands.append(UIKeyCommand(
909:             input: "g",
910:             modifierFlags: .command,
911:             action: #selector(handleGoToLine)
912:         ))
913: 
914:         // Tab: accept autocomplete if visible, else insert tab
915:         commands.append(UIKeyCommand(
916:             input: "\t",
917:             modifierFlags: [],
918:             action: #selector(handleTab)
919:         ))
920:         
921:         // Escape: dismiss autocomplete if visible, else normal escape behavior
922:         commands.append(UIKeyCommand(
923:             input: UIKeyCommand.inputEscape,
924:             modifierFlags: [],
925:             action: #selector(handleEscape)
926:         ))
927:         
928:         // Fold: Cmd+Opt+[
929:         commands.append(UIKeyCommand(
930:             input: "[",
931:             modifierFlags: [.command, .alternate],
932:             action: #selector(handleFold)
933:         ))
934:         
935:         // Unfold: Cmd+Opt+]
936:         commands.append(UIKeyCommand(
937:             input: "]",
938:             modifierFlags: [.command, .alternate],
939:             action: #selector(handleUnfold)
940:         ))
941:         
942:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
943:         // These post to NotificationCenter so ContentView can handle them
944:         
945:         // Command Palette: Cmd+Shift+P
946:         commands.append(UIKeyCommand(
947:             input: "p",
948:             modifierFlags: [.command, .shift],
949:             action: #selector(handleShowCommandPalette),
950:             discoverabilityTitle: "Command Palette"
951:         ))
952:         
953:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
954:         let toggleTerminalCmd = UIKeyCommand(
955:             input: "j",
956:             modifierFlags: .command,
957:             action: #selector(handleToggleTerminal),
958:             discoverabilityTitle: "Toggle Terminal"
959:         )
960:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
961:         commands.append(toggleTerminalCmd)
962:         
963:         // AI Assistant: Cmd+Shift+A
964:         commands.append(UIKeyCommand(
965:             input: "a",
966:             modifierFlags: [.command, .shift],
967:             action: #selector(handleShowAIAssistant),
968:             discoverabilityTitle: "AI Assistant"
969:         ))
970:         
971:         // Toggle Sidebar: Cmd+B
972:         commands.append(UIKeyCommand(
973:             input: "b",
974:             modifierFlags: .command,
975:             action: #selector(handleToggleSidebar),
976:             discoverabilityTitle: "Toggle Sidebar"
977:         ))
978:         
979:         // Quick Open: Cmd+P
980:         commands.append(UIKeyCommand(
981:             input: "p",
982:             modifierFlags: .command,
983:             action: #selector(handleShowQuickOpen),
984:             discoverabilityTitle: "Quick Open"
985:         ))
986:         
987:         // New File: Cmd+N
988:         let newFileCmd = UIKeyCommand(
989:             input: "n",
990:             modifierFlags: .command,
991:             action: #selector(handleNewFile),
992:             discoverabilityTitle: "New File"
993:         )
994:         newFileCmd.wantsPriorityOverSystemBehavior = true
995:         commands.append(newFileCmd)
996:         
997:         // Save: Cmd+S
998:         commands.append(UIKeyCommand(
999:             input: "s",
1000:             modifierFlags: .command,
1001:             action: #selector(handleSaveFile),
1002:             discoverabilityTitle: "Save"
1003:         ))
1004:         
1005:         // Close Tab: Cmd+W
1006:         let closeTabCmd = UIKeyCommand(
1007:             input: "w",
1008:             modifierFlags: .command,
1009:             action: #selector(handleCloseTab),
1010:             discoverabilityTitle: "Close Tab"
1011:         )
1012:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1013:         commands.append(closeTabCmd)
1014:         
1015:         // Find: Cmd+F
1016:         let findCmd = UIKeyCommand(
1017:             input: "f",
1018:             modifierFlags: .command,
1019:             action: #selector(handleFind),
1020:             discoverabilityTitle: "Find"
1021:         )
1022:         findCmd.wantsPriorityOverSystemBehavior = true
1023:         commands.append(findCmd)
1024:         
1025:         // Zoom In: Cmd+=
1026:         commands.append(UIKeyCommand(
1027:             input: "=",
1028:             modifierFlags: .command,
1029:             action: #selector(handleZoomIn),
1030:             discoverabilityTitle: "Zoom In"
1031:         ))
1032:         
1033:         // Zoom Out: Cmd+-
1034:         commands.append(UIKeyCommand(
1035:             input: "-",
1036:             modifierFlags: .command,
1037:             action: #selector(handleZoomOut),
1038:             discoverabilityTitle: "Zoom Out"
1039:         ))
1040:         
1041:         return commands
1042:     }
1043:     
1044:     @objc func handlePeekDefinition() {
1045:         onPeekDefinition?()
1046:     }
1047: 
1048:     @objc func handleGoToLine() {
1049:         onGoToLine?()
1050:     }
1051: 
1052:     @objc func handleTab() {
1053:         if onAcceptAutocomplete?() == true {
1054:             return
1055:         }
1056:         insertText("\t")
1057:     }
1058:     
1059:     @objc func handleEscape() {
1060:         if onDismissAutocomplete?() == true {
1061:             return
1062:         }
1063:         onEscape?()
1064:     }
1065:     


>>>TOOL search
{"query":"input: \"z\"", "glob":"**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "input: "z""


>>>TOOL search
{"query":".undoManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/*.swift"}
>>>END>>>TOOL search
{"query":"undo", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for ".undoManager"

---

[search]
No matches found for "undo"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":880,"end_line":940}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 881-940 of 2011)
────────────────────────────────────────
881:             let lineText = text.substring(with: range)
882: 
883:             // Calculate indentation level
884:             var spaces = 0
885:             for char in lineText {
886:                 if char == " " { spaces += 1 }
887:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
888:                 else { break }
889:             }
890: 
891:             let indentLevel = spaces / tabSize
892:             guard indentLevel > 0 else { return }
893: 
894:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
895: 
896:             for i in 1...indentLevel {
897:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
898:                 let startPoint = CGPoint(x: x, y: rect.minY)
899:                 let endPoint = CGPoint(x: x, y: rect.maxY)
900: 
901:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
902:                 context.setStrokeColor(stroke.cgColor)
903: 
904:                 context.move(to: startPoint)
905:                 context.addLine(to: endPoint)
906:                 context.strokePath()
907:             }
908:         }
909:     }
910:     
911:     override var keyCommands: [UIKeyCommand]? {
912:         var commands = super.keyCommands ?? []
913:         
914:         // Peek Definition: Alt+F12 (using special key input)
915:         // Note: F12 is not directly available on iPadOS keyboards
916:         // Using Option+D as alternative
917:         commands.append(UIKeyCommand(
918:             input: "d",
919:             modifierFlags: .alternate,
920:             action: #selector(handlePeekDefinition)
921:         ))
922: 
923:         // Go to Line: Cmd+G
924:         commands.append(UIKeyCommand(
925:             input: "g",
926:             modifierFlags: .command,
927:             action: #selector(handleGoToLine)
928:         ))
929: 
930:         // Tab: accept autocomplete if visible, else insert tab
931:         commands.append(UIKeyCommand(
932:             input: "\t",
933:             modifierFlags: [],
934:             action: #selector(handleTab)
935:         ))
936:         
937:         // Escape: dismiss autocomplete if visible, else normal escape behavior
938:         commands.append(UIKeyCommand(
939:             input: UIKeyCommand.inputEscape,
940:             modifierFlags: [],


>>>TOOL search
{"query":"updateMatchingBracketHighlight", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:366: updateMatchingBracketHighlight(textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:531: updateMatchingBracketHighlight(textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:668: private func updateMatchingBracketHighlight(_ textView: UITextView) {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":640,"end_line":740}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 641-740 of 2011)
────────────────────────────────────────
641:             switch gesture.state {
642:             case .began:
643:                 // Store the initial font size when pinch begins
644:                 initialFontSize = parent.editorCore.editorFontSize
645: 
646:             case .changed:
647:                 // Calculate new font size based on pinch scale
648:                 let newSize = initialFontSize * gesture.scale
649: 
650:                 // Clamp font size between 8 and 32
651:                 let clampedSize = min(max(newSize, 8), 32)
652: 
653:                 // Update EditorCore's font size (this will trigger updateUIView)
654:                 parent.editorCore.editorFontSize = clampedSize
655: 
656:             case .ended, .cancelled:
657:                 // Optional: snap to nearest whole number or standard size
658:                 let finalSize = round(parent.editorCore.editorFontSize)
659:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
660: 
661:             default:
662:                 break
663:             }
664:         }
665: 
666:         // MARK: - FEAT-044 Matching Bracket Highlight
667: 
668:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
669:             // Clear any existing highlights
670:             if !bracketHighlightRanges.isEmpty {
671:                 for r in bracketHighlightRanges {
672:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
673:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
674:                 }
675:                 bracketHighlightRanges.removeAll()
676:             }
677: 
678:             // Only highlight when there's a caret (no selection)
679:             let selection = textView.selectedRange
680:             guard selection.length == 0 else { return }
681: 
682:             let nsText = (textView.text ?? "") as NSString
683:             let length = nsText.length
684:             guard length > 0 else { return }
685: 
686:             let caret = selection.location
687: 
688:             // Candidate bracket location: char before caret, else at caret
689:             let candidateIndices: [Int] = [
690:                 caret - 1,
691:                 caret
692:             ].filter { $0 >= 0 && $0 < length }
693: 
694:             func isBracket(_ c: unichar) -> Bool {
695:                 c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
696:             }
697: 
698:             var bracketIndex: Int?
699:             var bracketChar: unichar = 0
700: 
701:             for idx in candidateIndices {
702:                 let c = nsText.character(at: idx)
703:                 if isBracket(c) {
704:                     bracketIndex = idx
705:                     bracketChar = c
706:                     break
707:                 }
708:             }
709: 
710:             guard let idx = bracketIndex else { return }
711: 
712:             // Define bracket pairs
713:             let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
714:             let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
715: 
716:             let theme = ThemeManager.shared.currentTheme
717:             let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
718: 
719:             var matchIndex: Int?
720: 
721:             if let close = openToClose[bracketChar] {
722:                 // Opening bracket: scan forward
723:                 var depth = 0
724:                 var i = idx + 1
725:                 while i < length {
726:                     let c = nsText.character(at: i)
727:                     if c == bracketChar {
728:                         depth += 1
729:                     } else if c == close {
730:                         if depth == 0 {
731:                             matchIndex = i
732:                             break
733:                         } else {
734:                             depth -= 1
735:                         }
736:                     }
737:                     i += 1
738:                 }
739:             } else if let open = closeToOpen[bracketChar] {
740:                 // Closing bracket: scan backward


>>>TOOL search
{"query":"textStorage.", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 7 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:622: textStorage.replaceCharacters(in: nsRange, with: newLineText)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:672: textView.textStorage.removeAttribute(.backgroundColor, range: r)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:673: textView.textStorage.removeAttribute(.underlineStyle, range: r)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:764: textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:765: textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:767: textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:768: textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":650,"end_line":740}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 651-740 of 2011)
────────────────────────────────────────
651:                 let clampedSize = min(max(newSize, 8), 32)
652: 
653:                 // Update EditorCore's font size (this will trigger updateUIView)
654:                 parent.editorCore.editorFontSize = clampedSize
655: 
656:             case .ended, .cancelled:
657:                 // Optional: snap to nearest whole number or standard size
658:                 let finalSize = round(parent.editorCore.editorFontSize)
659:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
660: 
661:             default:
662:                 break
663:             }
664:         }
665: 
666:         // MARK: - FEAT-044 Matching Bracket Highlight
667: 
668:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
669:             // Clear any existing highlights
670:             if !bracketHighlightRanges.isEmpty {
671:                 for r in bracketHighlightRanges {
672:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
673:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
674:                 }
675:                 bracketHighlightRanges.removeAll()
676:             }
677: 
678:             // Only highlight when there's a caret (no selection)
679:             let selection = textView.selectedRange
680:             guard selection.length == 0 else { return }
681: 
682:             let nsText = (textView.text ?? "") as NSString
683:             let length = nsText.length
684:             guard length > 0 else { return }
685: 
686:             let caret = selection.location
687: 
688:             // Candidate bracket location: char before caret, else at caret
689:             let candidateIndices: [Int] = [
690:                 caret - 1,
691:                 caret
692:             ].filter { $0 >= 0 && $0 < length }
693: 
694:             func isBracket(_ c: unichar) -> Bool {
695:                 c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
696:             }
697: 
698:             var bracketIndex: Int?
699:             var bracketChar: unichar = 0
700: 
701:             for idx in candidateIndices {
702:                 let c = nsText.character(at: idx)
703:                 if isBracket(c) {
704:                     bracketIndex = idx
705:                     bracketChar = c
706:                     break
707:                 }
708:             }
709: 
710:             guard let idx = bracketIndex else { return }
711: 
712:             // Define bracket pairs
713:             let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
714:             let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
715: 
716:             let theme = ThemeManager.shared.currentTheme
717:             let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
718: 
719:             var matchIndex: Int?
720: 
721:             if let close = openToClose[bracketChar] {
722:                 // Opening bracket: scan forward
723:                 var depth = 0
724:                 var i = idx + 1
725:                 while i < length {
726:                     let c = nsText.character(at: i)
727:                     if c == bracketChar {
728:                         depth += 1
729:                     } else if c == close {
730:                         if depth == 0 {
731:                             matchIndex = i
732:                             break
733:                         } else {
734:                             depth -= 1
735:                         }
736:                     }
737:                     i += 1
738:                 }
739:             } else if let open = closeToOpen[bracketChar] {
740:                 // Closing bracket: scan backward


>>>TOOL search
{"query":"MultiCursorTextView", "glob":"**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:1: //  MultiCursorTextView.swift
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:11: class MultiCursorTextView: UITextView {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:204: extension MultiCursorTextView {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":890,"end_line":1045}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 891-1045 of 2011)
────────────────────────────────────────
891:             let indentLevel = spaces / tabSize
892:             guard indentLevel > 0 else { return }
893: 
894:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
895: 
896:             for i in 1...indentLevel {
897:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
898:                 let startPoint = CGPoint(x: x, y: rect.minY)
899:                 let endPoint = CGPoint(x: x, y: rect.maxY)
900: 
901:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
902:                 context.setStrokeColor(stroke.cgColor)
903: 
904:                 context.move(to: startPoint)
905:                 context.addLine(to: endPoint)
906:                 context.strokePath()
907:             }
908:         }
909:     }
910:     
911:     override var keyCommands: [UIKeyCommand]? {
912:         var commands = super.keyCommands ?? []
913:         
914:         // Peek Definition: Alt+F12 (using special key input)
915:         // Note: F12 is not directly available on iPadOS keyboards
916:         // Using Option+D as alternative
917:         commands.append(UIKeyCommand(
918:             input: "d",
919:             modifierFlags: .alternate,
920:             action: #selector(handlePeekDefinition)
921:         ))
922: 
923:         // Go to Line: Cmd+G
924:         commands.append(UIKeyCommand(
925:             input: "g",
926:             modifierFlags: .command,
927:             action: #selector(handleGoToLine)
928:         ))
929: 
930:         // Tab: accept autocomplete if visible, else insert tab
931:         commands.append(UIKeyCommand(
932:             input: "\t",
933:             modifierFlags: [],
934:             action: #selector(handleTab)
935:         ))
936:         
937:         // Escape: dismiss autocomplete if visible, else normal escape behavior
938:         commands.append(UIKeyCommand(
939:             input: UIKeyCommand.inputEscape,
940:             modifierFlags: [],
941:             action: #selector(handleEscape)
942:         ))
943:         
944:         // Fold: Cmd+Opt+[
945:         commands.append(UIKeyCommand(
946:             input: "[",
947:             modifierFlags: [.command, .alternate],
948:             action: #selector(handleFold)
949:         ))
950:         
951:         // Unfold: Cmd+Opt+]
952:         commands.append(UIKeyCommand(
953:             input: "]",
954:             modifierFlags: [.command, .alternate],
955:             action: #selector(handleUnfold)
956:         ))
957:         
958:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
959:         // These post to NotificationCenter so ContentView can handle them
960:         
961:         // Command Palette: Cmd+Shift+P
962:         commands.append(UIKeyCommand(
963:             input: "p",
964:             modifierFlags: [.command, .shift],
965:             action: #selector(handleShowCommandPalette),
966:             discoverabilityTitle: "Command Palette"
967:         ))
968:         
969:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
970:         let toggleTerminalCmd = UIKeyCommand(
971:             input: "j",
972:             modifierFlags: .command,
973:             action: #selector(handleToggleTerminal),
974:             discoverabilityTitle: "Toggle Terminal"
975:         )
976:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
977:         commands.append(toggleTerminalCmd)
978:         
979:         // AI Assistant: Cmd+Shift+A
980:         commands.append(UIKeyCommand(
981:             input: "a",
982:             modifierFlags: [.command, .shift],
983:             action: #selector(handleShowAIAssistant),
984:             discoverabilityTitle: "AI Assistant"
985:         ))
986:         
987:         // Toggle Sidebar: Cmd+B
988:         commands.append(UIKeyCommand(
989:             input: "b",
990:             modifierFlags: .command,
991:             action: #selector(handleToggleSidebar),
992:             discoverabilityTitle: "Toggle Sidebar"
993:         ))
994:         
995:         // Quick Open: Cmd+P
996:         commands.append(UIKeyCommand(
997:             input: "p",
998:             modifierFlags: .command,
999:             action: #selector(handleShowQuickOpen),
1000:             discoverabilityTitle: "Quick Open"
1001:         ))
1002:         
1003:         // New File: Cmd+N
1004:         let newFileCmd = UIKeyCommand(
1005:             input: "n",
1006:             modifierFlags: .command,
1007:             action: #selector(handleNewFile),
1008:             discoverabilityTitle: "New File"
1009:         )
1010:         newFileCmd.wantsPriorityOverSystemBehavior = true
1011:         commands.append(newFileCmd)
1012:         
1013:         // Save: Cmd+S
1014:         commands.append(UIKeyCommand(
1015:             input: "s",
1016:             modifierFlags: .command,
1017:             action: #selector(handleSaveFile),
1018:             discoverabilityTitle: "Save"
1019:         ))
1020:         
1021:         // Close Tab: Cmd+W
1022:         let closeTabCmd = UIKeyCommand(
1023:             input: "w",
1024:             modifierFlags: .command,
1025:             action: #selector(handleCloseTab),
1026:             discoverabilityTitle: "Close Tab"
1027:         )
1028:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1029:         commands.append(closeTabCmd)
1030:         
1031:         // Find: Cmd+F
1032:         let findCmd = UIKeyCommand(
1033:             input: "f",
1034:             modifierFlags: .command,
1035:             action: #selector(handleFind),
1036:             discoverabilityTitle: "Find"
1037:         )
1038:         findCmd.wantsPriorityOverSystemBehavior = true
1039:         commands.append(findCmd)
1040:         
1041:         // Zoom In: Cmd+=
1042:         commands.append(UIKeyCommand(
1043:             input: "=",
1044:             modifierFlags: .command,
1045:             action: #selector(handleZoomIn),


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":754,"end_line":820}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 755-820 of 2011)
────────────────────────────────────────
755:                     i -= 1
756:                 }
757:             }
758: 
759:             guard let match = matchIndex else { return }
760: 
761:             let r1 = NSRange(location: idx, length: 1)
762:             let r2 = NSRange(location: match, length: 1)
763: 
764:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
765:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
766: 
767:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
768:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
769: 
770:             bracketHighlightRanges = [r1, r2]
771:         }
772:     }
773: }
774: 
775: // Custom text view to handle key commands, indent guides, and line highlighting
776: class EditorTextView: UITextView {
777:     var onPeekDefinition: (() -> Void)?
778:     var onEscape: (() -> Void)?
779:     var onGoToLine: (() -> Void)?
780:     
781:     // Custom action closures for context menu
782:     var onGoToDefinition: (() -> Void)?
783:     var onFindReferences: (() -> Void)?
784:     var onFormatDocument: (() -> Void)?
785:     var onToggleComment: (() -> Void)?
786:     var onFold: (() -> Void)?
787:     var onUnfold: (() -> Void)?
788: 
789:     // Autocomplete key handling hooks (return true if handled)
790:     var onAcceptAutocomplete: (() -> Bool)?
791:     var onDismissAutocomplete: (() -> Bool)?
792:     
793:     // FEAT-039 & FEAT-043
794:     private var indentGuideColor: UIColor = .separator
795:     private var activeIndentGuideColor: UIColor = .label
796:     private var currentLineHighlightColor: UIColor = .clear
797:     
798:     override init(frame: CGRect, textContainer: NSTextContainer?) {
799:         super.init(frame: frame, textContainer: textContainer)
800:         setup()
801:     }
802:     
803:     required init?(coder: NSCoder) {
804:         super.init(coder: coder)
805:         setup()
806:     }
807:     
808:     private func setup() {
809:         // Ensure we redraw when bounds/selection change
810:         contentMode = .redraw
811:     }
812:     
813:     func updateThemeColors(theme: Theme) {
814:         self.indentGuideColor = UIColor(theme.indentGuide)
815:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
816:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
817:         setNeedsDisplay()
818:     }
819:     
820:     override func draw(_ rect: CGRect) {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":640,"end_line":780}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 641-780 of 2011)
────────────────────────────────────────
641:             switch gesture.state {
642:             case .began:
643:                 // Store the initial font size when pinch begins
644:                 initialFontSize = parent.editorCore.editorFontSize
645: 
646:             case .changed:
647:                 // Calculate new font size based on pinch scale
648:                 let newSize = initialFontSize * gesture.scale
649: 
650:                 // Clamp font size between 8 and 32
651:                 let clampedSize = min(max(newSize, 8), 32)
652: 
653:                 // Update EditorCore's font size (this will trigger updateUIView)
654:                 parent.editorCore.editorFontSize = clampedSize
655: 
656:             case .ended, .cancelled:
657:                 // Optional: snap to nearest whole number or standard size
658:                 let finalSize = round(parent.editorCore.editorFontSize)
659:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
660: 
661:             default:
662:                 break
663:             }
664:         }
665: 
666:         // MARK: - FEAT-044 Matching Bracket Highlight
667: 
668:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
669:             // Clear any existing highlights
670:             if !bracketHighlightRanges.isEmpty {
671:                 for r in bracketHighlightRanges {
672:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
673:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
674:                 }
675:                 bracketHighlightRanges.removeAll()
676:             }
677: 
678:             // Only highlight when there's a caret (no selection)
679:             let selection = textView.selectedRange
680:             guard selection.length == 0 else { return }
681: 
682:             let nsText = (textView.text ?? "") as NSString
683:             let length = nsText.length
684:             guard length > 0 else { return }
685: 
686:             let caret = selection.location
687: 
688:             // Candidate bracket location: char before caret, else at caret
689:             let candidateIndices: [Int] = [
690:                 caret - 1,
691:                 caret
692:             ].filter { $0 >= 0 && $0 < length }
693: 
694:             func isBracket(_ c: unichar) -> Bool {
695:                 c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
696:             }
697: 
698:             var bracketIndex: Int?
699:             var bracketChar: unichar = 0
700: 
701:             for idx in candidateIndices {
702:                 let c = nsText.character(at: idx)
703:                 if isBracket(c) {
704:                     bracketIndex = idx
705:                     bracketChar = c
706:                     break
707:                 }
708:             }
709: 
710:             guard let idx = bracketIndex else { return }
711: 
712:             // Define bracket pairs
713:             let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
714:             let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
715: 
716:             let theme = ThemeManager.shared.currentTheme
717:             let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
718: 
719:             var matchIndex: Int?
720: 
721:             if let close = openToClose[bracketChar] {
722:                 // Opening bracket: scan forward
723:                 var depth = 0
724:                 var i = idx + 1
725:                 while i < length {
726:                     let c = nsText.character(at: i)
727:                     if c == bracketChar {
728:                         depth += 1
729:                     } else if c == close {
730:                         if depth == 0 {
731:                             matchIndex = i
732:                             break
733:                         } else {
734:                             depth -= 1
735:                         }
736:                     }
737:                     i += 1
738:                 }
739:             } else if let open = closeToOpen[bracketChar] {
740:                 // Closing bracket: scan backward
741:                 var depth = 0
742:                 var i = idx - 1
743:                 while i >= 0 {
744:                     let c = nsText.character(at: i)
745:                     if c == bracketChar {
746:                         depth += 1
747:                     } else if c == open {
748:                         if depth == 0 {
749:                             matchIndex = i
750:                             break
751:                         } else {
752:                             depth -= 1
753:                         }
754:                     }
755:                     i -= 1
756:                 }
757:             }
758: 
759:             guard let match = matchIndex else { return }
760: 
761:             let r1 = NSRange(location: idx, length: 1)
762:             let r2 = NSRange(location: match, length: 1)
763: 
764:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
765:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
766: 
767:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
768:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
769: 
770:             bracketHighlightRanges = [r1, r2]
771:         }
772:     }
773: }
774: 
775: // Custom text view to handle key commands, indent guides, and line highlighting
776: class EditorTextView: UITextView {
777:     var onPeekDefinition: (() -> Void)?
778:     var onEscape: (() -> Void)?
779:     var onGoToLine: (() -> Void)?
780:     


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":880,"end_line":1125}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 881-1125 of 2012)
────────────────────────────────────────
881: 
882:             let lineText = text.substring(with: range)
883: 
884:             // Calculate indentation level
885:             var spaces = 0
886:             for char in lineText {
887:                 if char == " " { spaces += 1 }
888:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
889:                 else { break }
890:             }
891: 
892:             let indentLevel = spaces / tabSize
893:             guard indentLevel > 0 else { return }
894: 
895:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
896: 
897:             for i in 1...indentLevel {
898:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
899:                 let startPoint = CGPoint(x: x, y: rect.minY)
900:                 let endPoint = CGPoint(x: x, y: rect.maxY)
901: 
902:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
903:                 context.setStrokeColor(stroke.cgColor)
904: 
905:                 context.move(to: startPoint)
906:                 context.addLine(to: endPoint)
907:                 context.strokePath()
908:             }
909:         }
910:     }
911:     
912:     override var keyCommands: [UIKeyCommand]? {
913:         var commands = super.keyCommands ?? []
914:         
915:         // Peek Definition: Alt+F12 (using special key input)
916:         // Note: F12 is not directly available on iPadOS keyboards
917:         // Using Option+D as alternative
918:         commands.append(UIKeyCommand(
919:             input: "d",
920:             modifierFlags: .alternate,
921:             action: #selector(handlePeekDefinition)
922:         ))
923: 
924:         // Go to Line: Cmd+G
925:         commands.append(UIKeyCommand(
926:             input: "g",
927:             modifierFlags: .command,
928:             action: #selector(handleGoToLine)
929:         ))
930: 
931:         // Tab: accept autocomplete if visible, else insert tab
932:         commands.append(UIKeyCommand(
933:             input: "\t",
934:             modifierFlags: [],
935:             action: #selector(handleTab)
936:         ))
937:         
938:         // Escape: dismiss autocomplete if visible, else normal escape behavior
939:         commands.append(UIKeyCommand(
940:             input: UIKeyCommand.inputEscape,
941:             modifierFlags: [],
942:             action: #selector(handleEscape)
943:         ))
944:         
945:         // Fold: Cmd+Opt+[
946:         commands.append(UIKeyCommand(
947:             input: "[",
948:             modifierFlags: [.command, .alternate],
949:             action: #selector(handleFold)
950:         ))
951:         
952:         // Unfold: Cmd+Opt+]
953:         commands.append(UIKeyCommand(
954:             input: "]",
955:             modifierFlags: [.command, .alternate],
956:             action: #selector(handleUnfold)
957:         ))
958:         
959:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
960:         // These post to NotificationCenter so ContentView can handle them
961:         
962:         // Command Palette: Cmd+Shift+P
963:         commands.append(UIKeyCommand(
964:             input: "p",
965:             modifierFlags: [.command, .shift],
966:             action: #selector(handleShowCommandPalette),
967:             discoverabilityTitle: "Command Palette"
968:         ))
969:         
970:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
971:         let toggleTerminalCmd = UIKeyCommand(
972:             input: "j",
973:             modifierFlags: .command,
974:             action: #selector(handleToggleTerminal),
975:             discoverabilityTitle: "Toggle Terminal"
976:         )
977:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
978:         commands.append(toggleTerminalCmd)
979:         
980:         // AI Assistant: Cmd+Shift+A
981:         commands.append(UIKeyCommand(
982:             input: "a",
983:             modifierFlags: [.command, .shift],
984:             action: #selector(handleShowAIAssistant),
985:             discoverabilityTitle: "AI Assistant"
986:         ))
987:         
988:         // Toggle Sidebar: Cmd+B
989:         commands.append(UIKeyCommand(
990:             input: "b",
991:             modifierFlags: .command,
992:             action: #selector(handleToggleSidebar),
993:             discoverabilityTitle: "Toggle Sidebar"
994:         ))
995:         
996:         // Quick Open: Cmd+P
997:         commands.append(UIKeyCommand(
998:             input: "p",
999:             modifierFlags: .command,
1000:             action: #selector(handleShowQuickOpen),
1001:             discoverabilityTitle: "Quick Open"
1002:         ))
1003:         
1004:         // New File: Cmd+N
1005:         let newFileCmd = UIKeyCommand(
1006:             input: "n",
1007:             modifierFlags: .command,
1008:             action: #selector(handleNewFile),
1009:             discoverabilityTitle: "New File"
1010:         )
1011:         newFileCmd.wantsPriorityOverSystemBehavior = true
1012:         commands.append(newFileCmd)
1013:         
1014:         // Save: Cmd+S
1015:         commands.append(UIKeyCommand(
1016:             input: "s",
1017:             modifierFlags: .command,
1018:             action: #selector(handleSaveFile),
1019:             discoverabilityTitle: "Save"
1020:         ))
1021:         
1022:         // Close Tab: Cmd+W
1023:         let closeTabCmd = UIKeyCommand(
1024:             input: "w",
1025:             modifierFlags: .command,
1026:             action: #selector(handleCloseTab),
1027:             discoverabilityTitle: "Close Tab"
1028:         )
1029:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1030:         commands.append(closeTabCmd)
1031:         
1032:         // Find: Cmd+F
1033:         let findCmd = UIKeyCommand(
1034:             input: "f",
1035:             modifierFlags: .command,
1036:             action: #selector(handleFind),
1037:             discoverabilityTitle: "Find"
1038:         )
1039:         findCmd.wantsPriorityOverSystemBehavior = true
1040:         commands.append(findCmd)
1041:         
1042:         // Zoom In: Cmd+=
1043:         commands.append(UIKeyCommand(
1044:             input: "=",
1045:             modifierFlags: .command,
1046:             action: #selector(handleZoomIn),
1047:             discoverabilityTitle: "Zoom In"
1048:         ))
1049:         
1050:         // Zoom Out: Cmd+-
1051:         commands.append(UIKeyCommand(
1052:             input: "-",
1053:             modifierFlags: .command,
1054:             action: #selector(handleZoomOut),
1055:             discoverabilityTitle: "Zoom Out"
1056:         ))
1057:         
1058:         return commands
1059:     }
1060:     
1061:     @objc func handlePeekDefinition() {
1062:         onPeekDefinition?()
1063:     }
1064: 
1065:     @objc func handleGoToLine() {
1066:         onGoToLine?()
1067:     }
1068: 
1069:     @objc func handleTab() {
1070:         if onAcceptAutocomplete?() == true {
1071:             return
1072:         }
1073:         insertText("\t")
1074:     }
1075:     
1076:     @objc func handleEscape() {
1077:         if onDismissAutocomplete?() == true {
1078:             return
1079:         }
1080:         onEscape?()
1081:     }
1082:     
1083:     @objc func handleFold() {
1084:         onFold?()
1085:     }
1086:     
1087:     @objc func handleUnfold() {
1088:         onUnfold?()
1089:     }
1090:     
1091:     // MARK: - App-Level Shortcut Handlers
1092:     
1093:     @objc func handleShowCommandPalette() {
1094:         NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1095:     }
1096:     
1097:     @objc func handleToggleTerminal() {
1098:         NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1099:     }
1100:     
1101:     @objc func handleShowAIAssistant() {
1102:         NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1103:     }
1104:     
1105:     @objc func handleToggleSidebar() {
1106:         NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
1107:     }
1108:     
1109:     @objc func handleShowQuickOpen() {
1110:         NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
1111:     }
1112:     
1113:     @objc func handleNewFile() {
1114:         NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
1115:     }
1116:     
1117:     @objc func handleSaveFile() {
1118:         NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
1119:     }
1120:     
1121:     @objc func handleCloseTab() {
1122:         NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
1123:     }
1124:     
1125:     @objc func handleFind() {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":470,"end_line":560}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 471-560 of 2012)
────────────────────────────────────────
471:                 return
472:             }
473:             
474:             var characterPosition = 0
475:             for i in 0..<line {
476:                 characterPosition += lines[i].count + 1
477:             }
478:             
479:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
480:                 let rect = textView.caretRect(for: position)
481:                 let targetY = max(0, rect.origin.y)
482:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
483:             }
484:             
485:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
486:                 self.isUpdatingFromMinimap = false
487:             }
488:         }
489: 
490:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
491:             let lines = textView.text.components(separatedBy: .newlines)
492:             guard line >= 0 && line < lines.count else { return }
493: 
494:             var characterPosition = 0
495:             for i in 0..<line {
496:                 characterPosition += lines[i].count + 1
497:             }
498: 
499:             // FEAT-041: select entire line (excluding trailing newline)
500:             let lineLength = (lines[line] as NSString).length
501:             let range = NSRange(location: characterPosition, length: lineLength)
502:             textView.selectedRange = range
503: 
504:             // Ensure it's visible
505:             scrollToLine(line, in: textView)
506: 
507:             // Update SwiftUI state
508:             updateCursorPosition(textView)
509:             updateScrollPosition(textView)
510:         }
511: 
512:         func applySyntaxHighlighting(to textView: UITextView) {
513:             let theme = ThemeManager.shared.currentTheme
514:             lastThemeId = theme.id
515: 
516:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
517:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
518: 
519:             let selectedRange = textView.selectedRange
520:             textView.attributedText = attributedText
521:             textView.selectedRange = selectedRange
522: 
523:             // Set typing attributes so newly typed characters have correct base styling
524:             // This prevents flicker during the debounce period before full highlighting runs
525:             let fontSize = parent.editorCore.editorFontSize
526:             textView.typingAttributes = [
527:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
528:                 .foregroundColor: UIColor(theme.editorForeground)
529:             ]
530: 
531:             // FEAT-044: restore matching bracket highlight after re-attributing text
532:             updateMatchingBracketHighlight(textView)
533:         }
534:         
535:         func handlePeekDefinition(in textView: UITextView) {
536:             guard let selectedRange = textView.selectedTextRange else { return }
537:             let text = textView.text ?? ""
538:             
539:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
540:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
541:                  
542:                  let prefix = String(text.prefix(location))
543:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
544:                  
545:                  parent.editorCore.triggerPeekDefinition(
546:                      file: parent.filename,
547:                      line: sourceLine,
548:                      content: text,
549:                      sourceLine: sourceLine
550:                  )
551:             }
552:         }
553:         
554:         func handleEscape() {
555:             if parent.editorCore.peekState != nil {
556:                 parent.editorCore.closePeekDefinition()
557:             } else {
558:                 parent.editorCore.escapeMultiCursor()
559:             }
560:         }


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":500,"end_line":545}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":905,"end_line":1015}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":190,"end_line":275}
>>>END>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 501-545 of 2051)
────────────────────────────────────────
501:             let range = NSRange(location: characterPosition, length: lineLength)
502:             textView.selectedRange = range
503: 
504:             // Ensure it's visible
505:             scrollToLine(line, in: textView)
506: 
507:             // Update SwiftUI state
508:             updateCursorPosition(textView)
509:             updateScrollPosition(textView)
510:         }
511: 
512:         func applySyntaxHighlighting(to textView: UITextView) {
513:             let theme = ThemeManager.shared.currentTheme
514:             lastThemeId = theme.id
515: 
516:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
517:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
518: 
519:             let selectedRange = textView.selectedRange
520: 
521:             // NOTE: Setting `attributedText` repeatedly for syntax highlighting can interfere with
522:             // UITextView's built-in Undo/Redo stack (Cmd+Z / Cmd+Shift+Z).
523:             // We explicitly disable undo registration around the styling pass so only user edits
524:             // participate in undo/redo.
525:             let um = textView.undoManager
526:             let wasUndoEnabled = um?.isUndoRegistrationEnabled ?? true
527:             if wasUndoEnabled { um?.disableUndoRegistration() }
528:             textView.attributedText = attributedText
529:             if wasUndoEnabled { um?.enableUndoRegistration() }
530: 
531:             textView.selectedRange = selectedRange
532: 
533:             // Set typing attributes so newly typed characters have correct base styling
534:             // This prevents flicker during the debounce period before full highlighting runs
535:             let fontSize = parent.editorCore.editorFontSize
536:             textView.typingAttributes = [
537:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
538:                 .foregroundColor: UIColor(theme.editorForeground)
539:             ]
540: 
541:             // FEAT-044: restore matching bracket highlight after re-attributing text
542:             updateMatchingBracketHighlight(textView)
543:         }
544:         
545:         func handlePeekDefinition(in textView: UITextView) {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 906-1015 of 2051)
────────────────────────────────────────
906: 
907:             for i in 1...indentLevel {
908:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
909:                 let startPoint = CGPoint(x: x, y: rect.minY)
910:                 let endPoint = CGPoint(x: x, y: rect.maxY)
911: 
912:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
913:                 context.setStrokeColor(stroke.cgColor)
914: 
915:                 context.move(to: startPoint)
916:                 context.addLine(to: endPoint)
917:                 context.strokePath()
918:             }
919:         }
920:     }
921:     
922:     override var keyCommands: [UIKeyCommand]? {
923:         var commands = super.keyCommands ?? []
924: 
925:         // Undo / Redo (ensure system shortcuts work even with custom keyCommands)
926:         let undoCmd = UIKeyCommand(
927:             input: "z",
928:             modifierFlags: .command,
929:             action: #selector(handleUndo),
930:             discoverabilityTitle: "Undo"
931:         )
932:         undoCmd.wantsPriorityOverSystemBehavior = true
933:         commands.append(undoCmd)
934: 
935:         let redoCmd = UIKeyCommand(
936:             input: "z",
937:             modifierFlags: [.command, .shift],
938:             action: #selector(handleRedo),
939:             discoverabilityTitle: "Redo"
940:         )
941:         redoCmd.wantsPriorityOverSystemBehavior = true
942:         commands.append(redoCmd)
943:         
944:         // Peek Definition: Alt+F12 (using special key input)
945:         // Note: F12 is not directly available on iPadOS keyboards
946:         // Using Option+D as alternative
947:         commands.append(UIKeyCommand(
948:             input: "d",
949:             modifierFlags: .alternate,
950:             action: #selector(handlePeekDefinition)
951:         ))
952: 
953:         // Go to Line: Cmd+G
954:         commands.append(UIKeyCommand(
955:             input: "g",
956:             modifierFlags: .command,
957:             action: #selector(handleGoToLine)
958:         ))
959: 
960:         // Tab: accept autocomplete if visible, else insert tab
961:         commands.append(UIKeyCommand(
962:             input: "\t",
963:             modifierFlags: [],
964:             action: #selector(handleTab)
965:         ))
966:         
967:         // Escape: dismiss autocomplete if visible, else normal escape behavior
968:         commands.append(UIKeyCommand(
969:             input: UIKeyCommand.inputEscape,
970:             modifierFlags: [],
971:             action: #selector(handleEscape)
972:         ))
973:         
974:         // Fold: Cmd+Opt+[
975:         commands.append(UIKeyCommand(
976:             input: "[",
977:             modifierFlags: [.command, .alternate],
978:             action: #selector(handleFold)
979:         ))
980:         
981:         // Unfold: Cmd+Opt+]
982:         commands.append(UIKeyCommand(
983:             input: "]",
984:             modifierFlags: [.command, .alternate],
985:             action: #selector(handleUnfold)
986:         ))
987:         
988:         // MARK: - App-Level Shortcuts (UITextView captures keyboard, so we MUST register here)
989:         // These post to NotificationCenter so ContentView can handle them
990:         
991:         // Command Palette: Cmd+Shift+P
992:         commands.append(UIKeyCommand(
993:             input: "p",
994:             modifierFlags: [.command, .shift],
995:             action: #selector(handleShowCommandPalette),
996:             discoverabilityTitle: "Command Palette"
997:         ))
998:         
999:         // Toggle Terminal: Cmd+J (VS Code's shortcut)
1000:         let toggleTerminalCmd = UIKeyCommand(
1001:             input: "j",
1002:             modifierFlags: .command,
1003:             action: #selector(handleToggleTerminal),
1004:             discoverabilityTitle: "Toggle Terminal"
1005:         )
1006:         toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
1007:         commands.append(toggleTerminalCmd)
1008:         
1009:         // AI Assistant: Cmd+Shift+A
1010:         commands.append(UIKeyCommand(
1011:             input: "a",
1012:             modifierFlags: [.command, .shift],
1013:             action: #selector(handleShowAIAssistant),
1014:             discoverabilityTitle: "AI Assistant"
1015:         ))

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 191-275 of 280)
────────────────────────────────────────
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
203: 
204: extension MultiCursorTextView {
205: 
206:     override var keyCommands: [UIKeyCommand]? {
207:         var commands = super.keyCommands ?? []
208: 
209:         // Cmd+D: Add next occurrence
210:         commands.append(UIKeyCommand(
211:             title: "Add Next Occurrence",
212:             action: #selector(addNextOccurrence),
213:             input: "d",
214:             modifierFlags: .command
215:         ))
216: 
217:         // Cmd+Shift+L: Select all occurrences
218:         commands.append(UIKeyCommand(
219:             title: "Select All Occurrences",
220:             action: #selector(selectAllOccurrences),
221:             input: "l",
222:             modifierFlags: [.command, .shift]
223:         ))
224: 
225:         return commands
226:     }
227: 
228:     @objc private func tabAcceptAutocomplete() {
229:         if onAcceptAutocomplete?() == true {
230:             return
231:         }
232:         insertText("\t")
233:     }
234: 
235:     @objc private func addNextOccurrence() {
236:         guard let editorCore = editorCore else { return }
237:         editorCore.addNextOccurrence()
238: 
239:         // Sync UIKit selection with the primary multi-cursor selection so typing replaces the selection.
240:         if let primary = editorCore.multiCursorState.primaryCursor {
241:             if let selection = primary.selectionRange {
242:                 selectedRange = selection
243:             } else {
244:                 selectedRange = NSRange(location: primary.position, length: 0)
245:             }
246:             delegate?.textViewDidChangeSelection?(self)
247:         }
248: 
249:         updateCursorDisplay()
250:     }
251: 
252:     @objc private func selectAllOccurrences() {
253:         guard let editorCore = editorCore else { return }
254:         editorCore.selectAllOccurrences()
255: 
256:         if let primary = editorCore.multiCursorState.primaryCursor {
257:             if let selection = primary.selectionRange {
258:                 selectedRange = selection
259:             } else {
260:                 selectedRange = NSRange(location: primary.position, length: 0)
261:             }
262:             delegate?.textViewDidChangeSelection?(self)
263:         }
264: 
265:         updateCursorDisplay()
266:     }
267: 
268:     @objc private func goToLine() {
269:         editorCore?.showGoToLine = true
270:     }
271: 
272:     @objc private func escapeKeyPressed() {
273:         if onDismissAutocomplete?() == true {
274:             return
275:         }


>>>TOOL search
{"query":"handleUndo", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"handleRedo", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1015,"end_line":1095}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:929: action: #selector(handleUndo),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1122: @objc func handleUndo() {

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:938: action: #selector(handleRedo),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:1126: @objc func handleRedo() {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1016-1095 of 2051)
────────────────────────────────────────
1016:         
1017:         // Toggle Sidebar: Cmd+B
1018:         commands.append(UIKeyCommand(
1019:             input: "b",
1020:             modifierFlags: .command,
1021:             action: #selector(handleToggleSidebar),
1022:             discoverabilityTitle: "Toggle Sidebar"
1023:         ))
1024:         
1025:         // Quick Open: Cmd+P
1026:         commands.append(UIKeyCommand(
1027:             input: "p",
1028:             modifierFlags: .command,
1029:             action: #selector(handleShowQuickOpen),
1030:             discoverabilityTitle: "Quick Open"
1031:         ))
1032:         
1033:         // New File: Cmd+N
1034:         let newFileCmd = UIKeyCommand(
1035:             input: "n",
1036:             modifierFlags: .command,
1037:             action: #selector(handleNewFile),
1038:             discoverabilityTitle: "New File"
1039:         )
1040:         newFileCmd.wantsPriorityOverSystemBehavior = true
1041:         commands.append(newFileCmd)
1042:         
1043:         // Save: Cmd+S
1044:         commands.append(UIKeyCommand(
1045:             input: "s",
1046:             modifierFlags: .command,
1047:             action: #selector(handleSaveFile),
1048:             discoverabilityTitle: "Save"
1049:         ))
1050:         
1051:         // Close Tab: Cmd+W
1052:         let closeTabCmd = UIKeyCommand(
1053:             input: "w",
1054:             modifierFlags: .command,
1055:             action: #selector(handleCloseTab),
1056:             discoverabilityTitle: "Close Tab"
1057:         )
1058:         closeTabCmd.wantsPriorityOverSystemBehavior = true
1059:         commands.append(closeTabCmd)
1060:         
1061:         // Find: Cmd+F
1062:         let findCmd = UIKeyCommand(
1063:             input: "f",
1064:             modifierFlags: .command,
1065:             action: #selector(handleFind),
1066:             discoverabilityTitle: "Find"
1067:         )
1068:         findCmd.wantsPriorityOverSystemBehavior = true
1069:         commands.append(findCmd)
1070:         
1071:         // Zoom In: Cmd+=
1072:         commands.append(UIKeyCommand(
1073:             input: "=",
1074:             modifierFlags: .command,
1075:             action: #selector(handleZoomIn),
1076:             discoverabilityTitle: "Zoom In"
1077:         ))
1078:         
1079:         // Zoom Out: Cmd+-
1080:         commands.append(UIKeyCommand(
1081:             input: "-",
1082:             modifierFlags: .command,
1083:             action: #selector(handleZoomOut),
1084:             discoverabilityTitle: "Zoom Out"
1085:         ))
1086:         
1087:         return commands
1088:     }
1089:     
1090:     @objc func handlePeekDefinition() {
1091:         onPeekDefinition?()
1092:     }
1093: 
1094:     @objc func handleGoToLine() {
1095:         onGoToLine?()


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1090,"end_line":1155}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1091-1155 of 2051)
────────────────────────────────────────
1091:         onPeekDefinition?()
1092:     }
1093: 
1094:     @objc func handleGoToLine() {
1095:         onGoToLine?()
1096:     }
1097: 
1098:     @objc func handleTab() {
1099:         if onAcceptAutocomplete?() == true {
1100:             return
1101:         }
1102:         insertText("\t")
1103:     }
1104:     
1105:     @objc func handleEscape() {
1106:         if onDismissAutocomplete?() == true {
1107:             return
1108:         }
1109:         onEscape?()
1110:     }
1111:     
1112:     @objc func handleFold() {
1113:         onFold?()
1114:     }
1115:     
1116:     @objc func handleUnfold() {
1117:         onUnfold?()
1118:     }
1119: 
1120:     // MARK: - Undo / Redo
1121: 
1122:     @objc func handleUndo() {
1123:         undoManager?.undo()
1124:     }
1125: 
1126:     @objc func handleRedo() {
1127:         undoManager?.redo()
1128:     }
1129:     
1130:     // MARK: - App-Level Shortcut Handlers
1131:     
1132:     @objc func handleShowCommandPalette() {
1133:         NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1134:     }
1135:     
1136:     @objc func handleToggleTerminal() {
1137:         NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1138:     }
1139:     
1140:     @objc func handleShowAIAssistant() {
1141:         NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1142:     }
1143:     
1144:     @objc func handleToggleSidebar() {
1145:         NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
1146:     }
1147:     
1148:     @objc func handleShowQuickOpen() {
1149:         NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
1150:     }
1151:     
1152:     @objc func handleNewFile() {
1153:         NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
1154:     }
1155:     


>>>TOOL search
{"query":"becomeFirstResponder", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"MultiCursorTextView(", "glob":"**/*.swift"}
>>>END
>>>TOOL search
{"query":"class MultiCursorTextView", "glob":"**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "becomeFirstResponder"

---

[search]
No matches found for "MultiCursorTextView("

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:11: class MultiCursorTextView: UITextView {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1100,"end_line":1145}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1101-1145 of 2051)
────────────────────────────────────────
1101:         }
1102:         insertText("\t")
1103:     }
1104:     
1105:     @objc func handleEscape() {
1106:         if onDismissAutocomplete?() == true {
1107:             return
1108:         }
1109:         onEscape?()
1110:     }
1111:     
1112:     @objc func handleFold() {
1113:         onFold?()
1114:     }
1115:     
1116:     @objc func handleUnfold() {
1117:         onUnfold?()
1118:     }
1119: 
1120:     // MARK: - Undo / Redo
1121: 
1122:     @objc func handleUndo() {
1123:         undoManager?.undo()
1124:     }
1125: 
1126:     @objc func handleRedo() {
1127:         undoManager?.redo()
1128:     }
1129:     
1130:     // MARK: - App-Level Shortcut Handlers
1131:     
1132:     @objc func handleShowCommandPalette() {
1133:         NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1134:     }
1135:     
1136:     @objc func handleToggleTerminal() {
1137:         NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1138:     }
1139:     
1140:     @objc func handleShowAIAssistant() {
1141:         NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1142:     }
1143:     
1144:     @objc func handleToggleSidebar() {
1145:         NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":140,"end_line":280}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 141-280 of 2051)
────────────────────────────────────────
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
153:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
154:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
155:         pinchGesture.delegate = context.coordinator
156:         textView.addGestureRecognizer(pinchGesture)
157:         context.coordinator.pinchGesture = pinchGesture
158:         
159:         // Configure text view
160:         textView.isEditable = true
161:         textView.isSelectable = true
162:         textView.autocapitalizationType = .none
163:         textView.autocorrectionType = .no
164:         textView.smartDashesType = .no
165:         textView.smartQuotesType = .no
166:         textView.smartInsertDeleteType = .no
167:         textView.spellCheckingType = .no
168:         
169:         // Set font and appearance (use editorCore.editorFontSize)
170:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
171:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
172:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
173:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
174:         textView.keyboardType = .default
175:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
176:         
177:         // Enable line wrapping
178:         textView.textContainer.lineBreakMode = .byCharWrapping
179:         textView.textContainer.widthTracksTextView = true
180:         
181:         // Calculate line height
182:         if let font = textView.font {
183:             DispatchQueue.main.async {
184:                 self.lineHeight = font.lineHeight
185:             }
186:         }
187:         
188:         // Set initial text with syntax highlighting
189:         textView.text = text
190:         context.coordinator.applySyntaxHighlighting(to: textView)
191:         context.coordinator.updateLineCount(textView)
192:         
193:         return textView
194:     }
195:     
196:     func updateUIView(_ textView: UITextView, context: Context) {
197:         // CRITICAL: Update coordinator's parent reference to current struct
198:         // SwiftUI creates new struct instances on each update, so this keeps
199:         // coordinator in sync with current bindings and properties
200:         context.coordinator.parent = self
201:         
202:         // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
203:         // This fixes the bug where syntax highlighting only appears after typing.
204:         // makeUIView applies it, but the view may not be fully in hierarchy yet,
205:         // causing the attributed text to be lost. This ensures it's applied reliably.
206:         if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
207:             context.coordinator.applySyntaxHighlighting(to: textView)
208:             context.coordinator.hasAppliedInitialHighlighting = true
209:         }
210:         
211:         // Update colors when theme changes
212:         // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor
213:         // as it interferes with attributedText syntax highlighting colors.
214:         // The foreground color is handled entirely by the attributedText.
215:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
216:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
217:         
218:         if let editorView = textView as? EditorTextView {
219:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
220:         }
221:         
222:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
223:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
224:             let selectedRange = textView.selectedRange
225:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
226:             context.coordinator.applySyntaxHighlighting(to: textView)
227:             textView.selectedRange = selectedRange
228:             
229:             // Update line height
230:             if let font = textView.font {
231:                 DispatchQueue.main.async {
232:                     self.lineHeight = font.lineHeight
233:                 }
234:             }
235:         }
236:         
237:         // Update text if changed externally
238:         if textView.text != text {
239:             let selectedRange = textView.selectedRange
240:             textView.text = text
241:             context.coordinator.applySyntaxHighlighting(to: textView)
242:             context.coordinator.hasAppliedInitialHighlighting = true
243:             textView.selectedRange = selectedRange
244:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
245:             // Re-apply highlighting if theme changed
246:             context.coordinator.applySyntaxHighlighting(to: textView)
247:         }
248:         
249:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
250:         // This prevents the editor from fighting against user scroll due to async binding lag
251:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
252:             // Update lastKnownScrollPosition FIRST to prevent race condition
253:             // where user scroll gets overridden by stale binding value
254:             context.coordinator.lastKnownScrollPosition = scrollPosition
255:             context.coordinator.scrollToLine(scrollPosition, in: textView)
256:         }
257: 
258:         // Handle line selection requests (e.g. tapping line numbers)
259:         if let requested = requestedLineSelection,
260:            requested != context.coordinator.lastRequestedLineSelection {
261:             context.coordinator.lastRequestedLineSelection = requested
262:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
263:             // Defer @Binding update to avoid "Publishing changes from within view updates"
264:             DispatchQueue.main.async {
265:                 self.requestedLineSelection = nil
266:             }
267:         }
268: 
269:         // Handle cursor index requests (e.g. accepting autocomplete)
270:         if let requested = requestedCursorIndex,
271:            requested != context.coordinator.lastRequestedCursorIndex {
272:             context.coordinator.lastRequestedCursorIndex = requested
273:             // Use UTF-16 count for NSRange compatibility
274:             let textLength = (textView.text as NSString?)?.length ?? 0
275:             let safeIndex = max(0, min(requested, textLength))
276:             textView.selectedRange = NSRange(location: safeIndex, length: 0)
277:             
278:             // Ensure cursor is visible by scrolling to it
279:             textView.scrollRangeToVisible(textView.selectedRange)
280:             


>>>TOOL search
{"query":"attributedText =", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"disableUndoRegistration", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"enableUndoRegistration", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:517: let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:528: textView.attributedText = attributedText

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:527: if wasUndoEnabled { um?.disableUndoRegistration() }

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:529: if wasUndoEnabled { um?.enableUndoRegistration() }


>>>TOOL read_file
{"path":"build.log","start_line":1,"end_line":120}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: build.log (lines 2-5 of 5)
────────────────────────────────────────
2:     /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -project VSCodeiPadOS/VSCodeiPadOS.xcodeproj -scheme VSCodeiPadOS -destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)" clean build
3: 
4: ** BUILD INTERRUPTED **
5: 


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":660,"end_line":775}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 661-775 of 2051)
────────────────────────────────────────
661:                 // Clamp font size between 8 and 32
662:                 let clampedSize = min(max(newSize, 8), 32)
663: 
664:                 // Update EditorCore's font size (this will trigger updateUIView)
665:                 parent.editorCore.editorFontSize = clampedSize
666: 
667:             case .ended, .cancelled:
668:                 // Optional: snap to nearest whole number or standard size
669:                 let finalSize = round(parent.editorCore.editorFontSize)
670:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
671: 
672:             default:
673:                 break
674:             }
675:         }
676: 
677:         // MARK: - FEAT-044 Matching Bracket Highlight
678: 
679:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
680:             // Clear any existing highlights
681:             if !bracketHighlightRanges.isEmpty {
682:                 for r in bracketHighlightRanges {
683:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
684:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
685:                 }
686:                 bracketHighlightRanges.removeAll()
687:             }
688: 
689:             // Only highlight when there's a caret (no selection)
690:             let selection = textView.selectedRange
691:             guard selection.length == 0 else { return }
692: 
693:             let nsText = (textView.text ?? "") as NSString
694:             let length = nsText.length
695:             guard length > 0 else { return }
696: 
697:             let caret = selection.location
698: 
699:             // Candidate bracket location: char before caret, else at caret
700:             let candidateIndices: [Int] = [
701:                 caret - 1,
702:                 caret
703:             ].filter { $0 >= 0 && $0 < length }
704: 
705:             func isBracket(_ c: unichar) -> Bool {
706:                 c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
707:             }
708: 
709:             var bracketIndex: Int?
710:             var bracketChar: unichar = 0
711: 
712:             for idx in candidateIndices {
713:                 let c = nsText.character(at: idx)
714:                 if isBracket(c) {
715:                     bracketIndex = idx
716:                     bracketChar = c
717:                     break
718:                 }
719:             }
720: 
721:             guard let idx = bracketIndex else { return }
722: 
723:             // Define bracket pairs
724:             let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
725:             let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
726: 
727:             let theme = ThemeManager.shared.currentTheme
728:             let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
729: 
730:             var matchIndex: Int?
731: 
732:             if let close = openToClose[bracketChar] {
733:                 // Opening bracket: scan forward
734:                 var depth = 0
735:                 var i = idx + 1
736:                 while i < length {
737:                     let c = nsText.character(at: i)
738:                     if c == bracketChar {
739:                         depth += 1
740:                     } else if c == close {
741:                         if depth == 0 {
742:                             matchIndex = i
743:                             break
744:                         } else {
745:                             depth -= 1
746:                         }
747:                     }
748:                     i += 1
749:                 }
750:             } else if let open = closeToOpen[bracketChar] {
751:                 // Closing bracket: scan backward
752:                 var depth = 0
753:                 var i = idx - 1
754:                 while i >= 0 {
755:                     let c = nsText.character(at: i)
756:                     if c == bracketChar {
757:                         depth += 1
758:                     } else if c == open {
759:                         if depth == 0 {
760:                             matchIndex = i
761:                             break
762:                         } else {
763:                             depth -= 1
764:                         }
765:                     }
766:                     i -= 1
767:                 }
768:             }
769: 
770:             guard let match = matchIndex else { return }
771: 
772:             let r1 = NSRange(location: idx, length: 1)
773:             let r2 = NSRange(location: match, length: 1)
774: 
775:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)


>>>REPORT
Goal: ensure undo/redo works in VSCodeiPadOS editor (SyntaxHighlightingTextView).

Findings / Evidence (SyntaxHighlightingTextView.swift):
- Undo stack interference from repeated syntax-highlighting attributedText updates is addressed by explicitly disabling undo registration during the styling pass:
  - `applySyntaxHighlighting(to:)` wraps `textView.attributedText = attributedText` with `undoManager?.disableUndoRegistration()` / `enableUndoRegistration()` (VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift lines 521-530 in the current file view).
- Cmd+Z / Cmd+Shift+Z keyboard shortcuts are explicitly registered in `EditorTextView.keyCommands`:
  - Adds UIKeyCommand for Undo: input "z" + .command -> `#selector(handleUndo)` and Redo: input "z" + [.command, .shift] -> `#selector(handleRedo)`; both set `wantsPriorityOverSystemBehavior = true` (same file lines 925-942).
- UIKeyCommand handlers exist and call the UITextView-provided undoManager:
  - `@objc func handleUndo() { undoManager?.undo() }`
  - `@objc func handleRedo() { undoManager?.redo() }`
  (same file lines 1122-1128).
- No custom `override var undoManager` exists in this file (searched for `override var undoManager` / `.undoManager`; none found), so it relies on UITextView’s built-in undoManager, which is the desired behavior.

Other checked file:
- MultiCursorTextView.swift defines its own keyCommands but (per search) is not referenced/constructed anywhere in the repo currently (searched “MultiCursorTextView(” globally; no matches). It also does not register Cmd+Z/Cmd+Shift+Z, but this is likely irrelevant if it’s unused.

Build status:
- Cannot run xcodebuild with available tools. Repository build.log shows the last recorded build was interrupted (build.log lines 2-5).

Files examined:
- VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (multiple ranges; key evidence at ~521-530, ~925-942, ~1122-1128)
- VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (keyCommands section ~206-225)
- build.log
>>>END
