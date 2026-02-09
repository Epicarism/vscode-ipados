# Agent: editor-features-audit
**Status:** done
**Tokens:** 3,053
**Cost:** $0.0000
**Time:** 2026-02-09T21:53:53.521Z

## Task
Audit editor features: 1) SyntaxHighlightingTextView.swift - verify all 15+ languages have highlighting patterns, 2) MultiCursorTextView.swift - verify Option+Click, Cmd+D, Cmd+Shift+L, 3) CodeFoldingManager.swift - verify fold detection and UI, 4) MinimapView.swift - verify rendering and click-to-scroll. Report FULLY WIRED vs STUB/MISSING for each.

## Response
I'll audit these 4 editor features by examining each file. Let me start by reading all the files to understand their implementation status.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

I need to search for the language patterns in this large file. Let me search for the language definitions.

>>>TOOL search
{"query": "case \"swift\" case \"javascript\" case \"python\" language patterns", "glob": "**/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "case "swift" case "javascript" case "python" language patterns"


>>>TOOL search
{"query": "language", "path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 7 matches:
phase1-agents.json:12: "task": "You are the SYNTAX HIGHLIGHTING COORDINATOR. Your job is to audit and fix ALL syntax highlighting.\n\nCURRENT STATE: Syntax highlighting exists but may not be working properly at runtime.\n\nYOUR MISSION:\n1. Read SyntaxHighlightingTextView.swift completely\n2. Identify what's broken\n3. Test each language: Swift, JS, TS, Python, HTML, CSS, JSON, Markdown\n4. Fix any highlighting bugs\n5. Ensure theme colors apply correctly\n6. Test with real code files\n\nFILES:\n- Views/Editor/SyntaxHighlightingTextView.swift\n- Services/ThemeManager.swift\n\nDELIVER:\n- All 10 languages highlight correctly\n- Keywords, strings, comments, numbers all colored\n- Theme integration works",
MASTER_AGENT_PLAN.md:41: | syntax-8 | Test all languages, create test files | Tests/SyntaxTests/ |
MASTER_AGENT_PLAN.md:222: | remote-2 | Run current file (detect language) | Services/RemoteRunner.swift (NEW) |
MASTER_AGENT_PLAN.md:294: | verify-1-5 | All syntax highlighting (10 languages) |
MASTER_AGENT_PLAN.md:366: 5. ✅ Syntax highlighting works for all languages
.vscode/settings.json:5: "swift.languageServerPath": "/usr/bin/sourcekit-lsp",
.vscode/sourcekit-lsp.json:7: "languages": ["swift"],


>>>TOOL get_symbols
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[get_symbols]
No symbols found in VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (file may need to be opened first)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 500, "end_line": 800}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 501-800 of 1749)
────────────────────────────────────────
501:                     }
502:                     
503:                     // Replace the line
504:                     let textStorage = textView.textStorage
505:                     textStorage.replaceCharacters(in: nsRange, with: newLineText)
506:                     
507:                     // Update parent binding
508:                     parent.text = textView.text
509:                 }
510:             }
511:         }
512:         
513:         func handleFold(in textView: UITextView) {
514:             CodeFoldingManager.shared.foldCurrentLine()
515:         }
516:         
517:         func handleUnfold(in textView: UITextView) {
518:             CodeFoldingManager.shared.unfoldCurrentLine()
519:         }
520:         
521:         @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
522:             guard let textView = gesture.view as? UITextView else { return }
523: 
524:             switch gesture.state {
525:             case .began:
526:                 // Store the initial font size when pinch begins
527:                 initialFontSize = parent.editorCore.editorFontSize
528: 
529:             case .changed:
530:                 // Calculate new font size based on pinch scale
531:                 let newSize = initialFontSize * gesture.scale
532: 
533:                 // Clamp font size between 8 and 32
534:                 let clampedSize = min(max(newSize, 8), 32)
535: 
536:                 // Update EditorCore's font size (this will trigger updateUIView)
537:                 parent.editorCore.editorFontSize = clampedSize
538: 
539:             case .ended, .cancelled:
540:                 // Optional: snap to nearest whole number or standard size
541:                 let finalSize = round(parent.editorCore.editorFontSize)
542:                 parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)
543: 
544:             default:
545:                 break
546:             }
547:         }
548: 
549:         // MARK: - FEAT-044 Matching Bracket Highlight
550: 
551:         private func updateMatchingBracketHighlight(_ textView: UITextView) {
552:             // Clear any existing highlights
553:             if !bracketHighlightRanges.isEmpty {
554:                 for r in bracketHighlightRanges {
555:                     textView.textStorage.removeAttribute(.backgroundColor, range: r)
556:                     textView.textStorage.removeAttribute(.underlineStyle, range: r)
557:                 }
558:                 bracketHighlightRanges.removeAll()
559:             }
560: 
561:             // Only highlight when there's a caret (no selection)
562:             let selection = textView.selectedRange
563:             guard selection.length == 0 else { return }
564: 
565:             let nsText = (textView.text ?? "") as NSString
566:             let length = nsText.length
567:             guard length > 0 else { return }
568: 
569:             let caret = selection.location
570: 
571:             // Candidate bracket location: char before caret, else at caret
572:             let candidateIndices: [Int] = [
573:                 caret - 1,
574:                 caret
575:             ].filter { $0 >= 0 && $0 < length }
576: 
577:             func isBracket(_ c: unichar) -> Bool {
578:                 c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
579:             }
580: 
581:             var bracketIndex: Int?
582:             var bracketChar: unichar = 0
583: 
584:             for idx in candidateIndices {
585:                 let c = nsText.character(at: idx)
586:                 if isBracket(c) {
587:                     bracketIndex = idx
588:                     bracketChar = c
589:                     break
590:                 }
591:             }
592: 
593:             guard let idx = bracketIndex else { return }
594: 
595:             // Define bracket pairs
596:             let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
597:             let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
598: 
599:             let theme = ThemeManager.shared.currentTheme
600:             let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
601: 
602:             var matchIndex: Int?
603: 
604:             if let close = openToClose[bracketChar] {
605:                 // Opening bracket: scan forward
606:                 var depth = 0
607:                 var i = idx + 1
608:                 while i < length {
609:                     let c = nsText.character(at: i)
610:                     if c == bracketChar {
611:                         depth += 1
612:                     } else if c == close {
613:                         if depth == 0 {
614:                             matchIndex = i
615:                             break
616:                         } else {
617:                             depth -= 1
618:                         }
619:                     }
620:                     i += 1
621:                 }
622:             } else if let open = closeToOpen[bracketChar] {
623:                 // Closing bracket: scan backward
624:                 var depth = 0
625:                 var i = idx - 1
626:                 while i >= 0 {
627:                     let c = nsText.character(at: i)
628:                     if c == bracketChar {
629:                         depth += 1
630:                     } else if c == open {
631:                         if depth == 0 {
632:                             matchIndex = i
633:                             break
634:                         } else {
635:                             depth -= 1
636:                         }
637:                     }
638:                     i -= 1
639:                 }
640:             }
641: 
642:             guard let match = matchIndex else { return }
643: 
644:             let r1 = NSRange(location: idx, length: 1)
645:             let r2 = NSRange(location: match, length: 1)
646: 
647:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
648:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
649: 
650:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
651:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
652: 
653:             bracketHighlightRanges = [r1, r2]
654:         }
655:     }
656: }
657: 
658: // Custom text view to handle key commands, indent guides, and line highlighting
659: class EditorTextView: UITextView {
660:     var onPeekDefinition: (() -> Void)?
661:     var onEscape: (() -> Void)?
662:     var onGoToLine: (() -> Void)?
663:     
664:     // Custom action closures for context menu
665:     var onGoToDefinition: (() -> Void)?
666:     var onFindReferences: (() -> Void)?
667:     var onFormatDocument: (() -> Void)?
668:     var onToggleComment: (() -> Void)?
669:     var onFold: (() -> Void)?
670:     var onUnfold: (() -> Void)?
671: 
672:     // Autocomplete key handling hooks (return true if handled)
673:     var onAcceptAutocomplete: (() -> Bool)?
674:     var onDismissAutocomplete: (() -> Bool)?
675:     
676:     // FEAT-039 & FEAT-043
677:     private var indentGuideColor: UIColor = .separator
678:     private var activeIndentGuideColor: UIColor = .label
679:     private var currentLineHighlightColor: UIColor = .clear
680:     
681:     override init(frame: CGRect, textContainer: NSTextContainer?) {
682:         super.init(frame: frame, textContainer: textContainer)
683:         setup()
684:     }
685:     
686:     required init?(coder: NSCoder) {
687:         super.init(coder: coder)
688:         setup()
689:     }
690:     
691:     private func setup() {
692:         // Ensure we redraw when bounds/selection change
693:         contentMode = .redraw
694:     }
695:     
696:     func updateThemeColors(theme: Theme) {
697:         self.indentGuideColor = UIColor(theme.indentGuide)
698:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
699:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
700:         setNeedsDisplay()
701:     }
702:     
703:     override func draw(_ rect: CGRect) {
704:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
705:             super.draw(rect)
706:             return
707:         }
708:         
709:         // 1. Draw Current Line Highlight (FEAT-043)
710:         if let selectedRange = selectedTextRange {
711:             // Get the line rect for the cursor position
712:             let caretRect = self.caretRect(for: selectedRange.start)
713:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
714:             
715:             context.setFillColor(currentLineHighlightColor.cgColor)
716:             context.fill(lineRect)
717:         }
718:         
719:         // 2. Draw Text (super implementation)
720:         super.draw(rect)
721:         
722:         // 3. Draw Indent Guides (FEAT-039)
723:         // We iterate visible lines and draw vertical lines for indentation
724:         // Optimization: Only draw for visible range
725: 
726:         context.setLineWidth(1.0)
727: 
728:         // Respect editor tab size setting (default 4)
729:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
730:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
731: 
732:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
733:         let indentWidth = spaceWidth * CGFloat(tabSize)
734: 
735:         // Determine active indent level for caret line (for indentGuideActive)
736:         var activeIndentLevel: Int = 0
737:         if let selected = selectedTextRange {
738:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
739:             let nsText = (self.text ?? "") as NSString
740:             let safeLoc = min(max(0, caretPos), nsText.length)
741:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
742:             let caretLineText = nsText.substring(with: caretLineRange)
743: 
744:             var spaces = 0
745:             for ch in caretLineText {
746:                 if ch == " " { spaces += 1 }
747:                 else if ch == "\t" { spaces += tabSize }
748:                 else { break }
749:             }
750:             activeIndentLevel = spaces / tabSize
751:         }
752: 
753:         // Iterate visible glyphs/lines
754:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
755:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
756: 
757:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
758: 
759:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
760:             // Get text for this line
761:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
762:                   let text = self.text as NSString? else { return }
763: 
764:             let lineText = text.substring(with: range)
765: 
766:             // Calculate indentation level
767:             var spaces = 0
768:             for char in lineText {
769:                 if char == " " { spaces += 1 }
770:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
771:                 else { break }
772:             }
773: 
774:             let indentLevel = spaces / tabSize
775:             guard indentLevel > 0 else { return }
776: 
777:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
778: 
779:             for i in 1...indentLevel {
780:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
781:                 let startPoint = CGPoint(x: x, y: rect.minY)
782:                 let endPoint = CGPoint(x: x, y: rect.maxY)
783: 
784:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
785:                 context.setStrokeColor(stroke.cgColor)
786: 
787:                 context.move(to: startPoint)
788:                 context.addLine(to: endPoint)
789:                 context.strokePath()
790:             }
791:         }
792:     }
793:     
794:     override var keyCommands: [UIKeyCommand]? {
795:         var commands = super.keyCommands ?? []
796:         
797:         // Peek Definition: Alt+F12 (using special key input)
798:         // Note: F12 is not directly available on iPadOS keyboards
799:         // Using Option+D as alternative
800:         commands.append(UIKeyCommand(


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 800, "end_line": 1100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 801-1100 of 1749)
────────────────────────────────────────
801:             input: "d",
802:             modifierFlags: .alternate,
803:             action: #selector(handlePeekDefinition)
804:         ))
805: 
806:         // Go to Line: Cmd+G
807:         commands.append(UIKeyCommand(
808:             input: "g",
809:             modifierFlags: .command,
810:             action: #selector(handleGoToLine)
811:         ))
812: 
813:         // Tab: accept autocomplete if visible, else insert tab
814:         commands.append(UIKeyCommand(
815:             input: "\t",
816:             modifierFlags: [],
817:             action: #selector(handleTab)
818:         ))
819:         
820:         // Escape: dismiss autocomplete if visible, else normal escape behavior
821:         commands.append(UIKeyCommand(
822:             input: UIKeyCommand.inputEscape,
823:             modifierFlags: [],
824:             action: #selector(handleEscape)
825:         ))
826:         
827:         // Fold: Cmd+Opt+[
828:         commands.append(UIKeyCommand(
829:             input: "[",
830:             modifierFlags: [.command, .alternate],
831:             action: #selector(handleFold)
832:         ))
833:         
834:         // Unfold: Cmd+Opt+]
835:         commands.append(UIKeyCommand(
836:             input: "]",
837:             modifierFlags: [.command, .alternate],
838:             action: #selector(handleUnfold)
839:         ))
840:         
841:         return commands
842:     }
843:     
844:     @objc func handlePeekDefinition() {
845:         onPeekDefinition?()
846:     }
847: 
848:     @objc func handleGoToLine() {
849:         onGoToLine?()
850:     }
851: 
852:     @objc func handleTab() {
853:         if onAcceptAutocomplete?() == true {
854:             return
855:         }
856:         insertText("\t")
857:     }
858:     
859:     @objc func handleEscape() {
860:         if onDismissAutocomplete?() == true {
861:             return
862:         }
863:         onEscape?()
864:     }
865:     
866:     @objc func handleFold() {
867:         onFold?()
868:     }
869:     
870:     @objc func handleUnfold() {
871:         onUnfold?()
872:     }
873:     
874:     // MARK: - Custom Actions
875:     
876:     @objc private func goToDefinition(_ sender: Any?) {
877:         onGoToDefinition?()
878:     }
879:     
880:     @objc private func peekDefinition(_ sender: Any?) {
881:         onPeekDefinition?()
882:     }
883:     
884:     @objc private func findReferences(_ sender: Any?) {
885:         onFindReferences?()
886:     }
887:     
888:     @objc private func formatDocument(_ sender: Any?) {
889:         onFormatDocument?()
890:     }
891:     
892:     @objc private func toggleComment(_ sender: Any?) {
893:         onToggleComment?()
894:     }
895:     
896:     // MARK: - Menu Support
897:     
898:     override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
899:         // Enable custom actions
900:         if action == #selector(goToDefinition(_:)) {
901:             return onGoToDefinition != nil
902:         }
903:         if action == #selector(peekDefinition(_:)) {
904:             return onPeekDefinition != nil
905:         }
906:         if action == #selector(findReferences(_:)) {
907:             return onFindReferences != nil
908:         }
909:         if action == #selector(formatDocument(_:)) {
910:             return onFormatDocument != nil
911:         }
912:         if action == #selector(toggleComment(_:)) {
913:             return onToggleComment != nil
914:         }
915:         
916:         return super.canPerformAction(action, withSender: sender)
917:     }
918:     
919:     override func buildMenu(with builder: UIMenuBuilder) {
920:         super.buildMenu(with: builder)
921:         
922:         guard builder.menu(for: .text) != nil else { return }
923:         
924:         // Create custom menu items
925:         let goToDefinitionAction = UIAction(
926:             title: "Go to Definition",
927:             image: UIImage(systemName: "arrow.forward.circle"),
928:             identifier: UIAction.Identifier("com.vscode.goToDefinition"),
929:             handler: { [weak self] _ in
930:                 self?.goToDefinition(nil)
931:             }
932:         )
933:         
934:         let peekDefinitionAction = UIAction(
935:             title: "Peek Definition",
936:             image: UIImage(systemName: "eye"),
937:             identifier: UIAction.Identifier("com.vscode.peekDefinition"),
938:             handler: { [weak self] _ in
939:                 self?.peekDefinition(nil)
940:             }
941:         )
942:         
943:         let findReferencesAction = UIAction(
944:             title: "Find All References",
945:             image: UIImage(systemName: "magnifyingglass"),
946:             identifier: UIAction.Identifier("com.vscode.findReferences"),
947:             handler: { [weak self] _ in
948:                 self?.findReferences(nil)
949:             }
950:         )
951:         
952:         let formatDocumentAction = UIAction(
953:             title: "Format Document",
954:             image: UIImage(systemName: "text.alignleft"),
955:             identifier: UIAction.Identifier("com.vscode.formatDocument"),
956:             handler: { [weak self] _ in
957:                 self?.formatDocument(nil)
958:             }
959:         )
960:         
961:         let toggleCommentAction = UIAction(
962:             title: "Toggle Comment",
963:             image: UIImage(systemName: "text.quote"),
964:             identifier: UIAction.Identifier("com.vscode.toggleComment"),
965:             handler: { [weak self] _ in
966:                 self?.toggleComment(nil)
967:             }
968:         )
969:         
970:         // Group custom actions
971:         let customMenu = UIMenu(
972:             title: "",
973:             identifier: UIMenu.Identifier("com.vscode.customActions"),
974:             options: [.displayInline],
975:             children: [
976:                 goToDefinitionAction,
977:                 peekDefinitionAction,
978:                 findReferencesAction,
979:                 formatDocumentAction,
980:                 toggleCommentAction
981:             ]
982:         )
983:         
984:         // Insert custom menu after standard edit menu
985:         builder.insertChild(customMenu, atStartOfMenu: .text)
986:     }
987: }
988: 
989: // MARK: - VSCode-Style Syntax Highlighter
990: 
991: enum Language {
992:     case swift
993: 
994:     case javascript
995:     case typescript
996:     case jsx
997:     case tsx
998: 
999:     case python
1000:     case ruby
1001:     case go
1002:     case rust
1003:     case java
1004:     case kotlin
1005: 
1006:     case c
1007:     case cpp
1008:     case objectiveC
1009: 
1010:     case html
1011:     case css
1012:     case scss
1013:     case less
1014:     case json
1015:     case xml
1016:     case yaml
1017:     case sql
1018: 
1019:     case shell
1020:     case dockerfile
1021:     case graphql
1022:     case markdown
1023:     case php
1024:     case env
1025: 
1026:     case plainText
1027: }
1028: 
1029: struct VSCodeSyntaxHighlighter {
1030:     private let baseFontSize: CGFloat
1031:     let theme: Theme
1032:     
1033:     init(theme: Theme = ThemeManager.shared.currentTheme, fontSize: CGFloat = 14) {
1034:         self.theme = theme
1035:         self.baseFontSize = fontSize
1036:     }
1037:     
1038:     func highlight(_ text: String, filename: String) -> NSAttributedString {
1039:         let language = detectLanguage(from: filename)
1040:         return highlight(text, language: language)
1041:     }
1042:     
1043:     private func detectLanguage(from filename: String) -> Language {
1044:         let lower = filename.lowercased()
1045:         let ext = (filename as NSString).pathExtension.lowercased()
1046: 
1047:         // Special-case filenames without extensions
1048:         if (filename as NSString).lastPathComponent.lowercased() == "dockerfile" { return .dockerfile }
1049:         if (filename as NSString).lastPathComponent.lowercased() == ".env" { return .env }
1050:         if lower.hasSuffix("/.env") { return .env }
1051: 
1052:         switch ext {
1053:         case "swift": return .swift
1054: 
1055:         case "js", "mjs", "cjs": return .javascript
1056:         case "jsx": return .jsx
1057:         case "ts", "mts", "cts": return .typescript
1058:         case "tsx": return .tsx
1059: 
1060:         case "py", "pyw": return .python
1061:         case "rb", "ruby": return .ruby
1062:         case "go": return .go
1063:         case "rs": return .rust
1064:         case "java": return .java
1065:         case "kt", "kts": return .kotlin
1066: 
1067:         case "c", "h": return .c
1068:         case "cpp", "cc", "cxx", "hpp", "hh", "hxx": return .cpp
1069:         case "m", "mm": return .objectiveC
1070: 
1071:         case "html", "htm": return .html
1072:         case "css": return .css
1073:         case "scss", "sass": return .scss
1074:         case "less": return .less
1075:         case "json", "jsonc": return .json
1076:         case "xml", "plist", "svg": return .xml
1077:         case "yml", "yaml": return .yaml
1078:         case "sql": return .sql
1079: 
1080:         case "sh", "bash", "zsh", "fish": return .shell
1081:         case "dockerfile": return .dockerfile
1082: 
1083:         case "graphql", "gql": return .graphql
1084: 
1085:         case "md", "markdown": return .markdown
1086:         case "php": return .php
1087:         case "env": return .env
1088: 
1089:         default: return .plainText
1090:         }
1091:     }
1092:     
1093:     private func highlight(_ text: String, language: Language) -> NSAttributedString {
1094:         let attributed = NSMutableAttributedString(string: text)
1095:         let fullRange = NSRange(location: 0, length: text.utf16.count)
1096:         
1097:         // Base attributes
1098:         let baseFont = UIFont.monospacedSystemFont(ofSize: baseFontSize, weight: .regular)
1099:         attributed.addAttribute(.font, value: baseFont, range: fullRange)
1100:         attributed.addAttribute(.foregroundColor, value: UIColor(theme.editorForeground), range: fullRange)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1100, "end_line": 1400}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1101-1400 of 1749)
────────────────────────────────────────
1101:         
1102:         // Apply language-specific highlighting
1103:         switch language {
1104:         case .swift: highlightSwift(attributed, text: text)
1105:         case .javascript, .jsx: highlightJavaScript(attributed, text: text, isTS: false)
1106:         case .typescript, .tsx: highlightJavaScript(attributed, text: text, isTS: true)
1107:         case .python: highlightPython(attributed, text: text)
1108:         case .html, .xml: highlightHTML(attributed, text: text)
1109:         case .css, .scss, .less: highlightCSS(attributed, text: text)
1110:         case .json: highlightJSON(attributed, text: text)
1111:         case .markdown: highlightMarkdown(attributed, text: text)
1112:         case .rust: highlightRust(attributed, text: text)
1113:         case .go: highlightGo(attributed, text: text)
1114:         case .java, .kotlin: highlightJava(attributed, text: text)
1115:         case .c, .cpp, .objectiveC: highlightCpp(attributed, text: text)
1116:         case .ruby: highlightRuby(attributed, text: text)
1117:         case .php: highlightPHP(attributed, text: text)
1118:         case .shell, .dockerfile: highlightShell(attributed, text: text)
1119:         case .yaml, .env: highlightYAML(attributed, text: text)
1120:         case .sql: highlightSQL(attributed, text: text)
1121:         case .graphql: highlightGraphQL(attributed, text: text)
1122:         case .plainText: break
1123:         }
1124:         
1125:         // FEAT-038: Bracket Pair Colorization (applied last)
1126:         highlightBracketPairs(attributed, text: text)
1127:         
1128:         return attributed
1129:     }
1130:     
1131:     // MARK: - Bracket Pair Colorization
1132:     
1133:     private func highlightBracketPairs(_ attributed: NSMutableAttributedString, text: String) {
1134:         let brackets: [Character] = ["{", "}", "[", "]", "(", ")"]
1135:         let pairs: [Character: Character] = ["}": "{", "]": "[", ")": "("]
1136:         
1137:         var stack: [(char: Character, index: Int, depth: Int)] = []
1138:         let colors = [
1139:             UIColor(theme.bracketPair1),
1140:             UIColor(theme.bracketPair2),
1141:             UIColor(theme.bracketPair3),
1142:             UIColor(theme.bracketPair4),
1143:             UIColor(theme.bracketPair5),
1144:             UIColor(theme.bracketPair6)
1145:         ]
1146:         
1147:         // Scan text for brackets
1148:         // Note: In a real implementation, we should skip brackets inside strings/comments
1149:         // But since we apply this LAST, we can try to respect existing string/comment colors
1150:         // OR implement a more robust parser. For now, simple scan.
1151:         
1152:         // Optimization: Use scanner or direct iteration
1153:         let nsString = text as NSString
1154:         var index = 0
1155:         
1156:         while index < text.utf16.count {
1157:             let char = nsString.character(at: index)
1158:             if let scalar = UnicodeScalar(char) {
1159:                 let c = Character(scalar)
1160:                 
1161:                 if brackets.contains(c) {
1162:                     // Check if it's already colored as string/comment (heuristic)
1163:                     // If color is string/comment, skip
1164:                     // (Requires iterating attributes, which is slow. We'll just apply on top for now)
1165:                     
1166:                     if let open = pairs[c] { // Closing bracket
1167:                         if let last = stack.last, last.char == open {
1168:                             // Match found
1169:                             let depth = last.depth
1170:                             let color = colors[depth % colors.count]
1171:                             
1172:                             attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1173:                             attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: last.index, length: 1))
1174:                             
1175:                             stack.removeLast()
1176:                         } else {
1177:                             // Mismatched or extra closing bracket - unexpected
1178:                             // Keep default color or mark red? Default for now.
1179:                         }
1180:                     } else { // Opening bracket
1181:                         let depth = stack.count
1182:                         stack.append((c, index, depth))
1183:                         
1184:                         // We'll color it when (and if) we find the match, or here?
1185:                         // Better to color here tentatively, but matching is better.
1186:                         // Let's color tentatively based on depth.
1187:                         let color = colors[depth % colors.count]
1188:                         attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1189:                     }
1190:                 }
1191:             }
1192:             index += 1
1193:         }
1194:     }
1195:     
1196:     // MARK: - Swift Highlighting
1197:     
1198:     private func highlightSwift(_ attributed: NSMutableAttributedString, text: String) {
1199:         // Keywords (purple/pink)
1200:         let keywords = ["func", "var", "let", "if", "else", "for", "while", "return",
1201:                        "class", "struct", "enum", "protocol", "extension", "import",
1202:                        "private", "public", "internal", "fileprivate", "open",
1203:                        "static", "final", "override", "mutating", "nonmutating",
1204:                        "init", "deinit", "subscript", "typealias", "associatedtype",
1205:                        "where", "throws", "rethrows", "async", "await", "actor",
1206:                        "guard", "defer", "do", "try", "catch", "throw",
1207:                        "switch", "case", "default", "break", "continue", "fallthrough",
1208:                        "in", "is", "as", "inout", "some", "any", "Self",
1209:                        "get", "set", "willSet", "didSet", "lazy", "weak", "unowned",
1210:                        "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject",
1211:                        "@Environment", "@EnvironmentObject", "@ViewBuilder", "@MainActor",
1212:                        "@escaping", "@autoclosure", "@available", "@objc", "@discardableResult"]
1213:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1214:         
1215:         // Types (teal) - CamelCase words that aren't keywords
1216:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1217:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1218:         
1219:         // Function calls (yellow)
1220:         let funcCallPattern = "\\b([a-z][a-zA-Z0-9]*)\\s*\\("
1221:         highlightPattern(attributed, pattern: funcCallPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1222:         
1223:         // Constants (blue)
1224:         let constants = ["true", "false", "nil", "self", "super"]
1225:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1226:         
1227:         // Comments MUST come late (green) - they override everything
1228:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1229:         
1230:         // Strings AFTER comments (orange)
1231:         highlightStrings(attributed, text: text)
1232:         
1233:         // Numbers (light green)
1234:         highlightNumbers(attributed, text: text)
1235:     }
1236:     
1237:     // MARK: - JavaScript/TypeScript Highlighting
1238:     
1239:     private func highlightJavaScript(_ attributed: NSMutableAttributedString, text: String, isTS: Bool) {
1240:         var keywords = ["function", "var", "let", "const", "if", "else", "for", "while",
1241:                        "return", "class", "extends", "new", "this", "super", "import",
1242:                        "export", "default", "from", "as", "async", "await", "yield",
1243:                        "try", "catch", "finally", "throw", "typeof", "instanceof",
1244:                        "switch", "case", "break", "continue", "do", "in", "of",
1245:                        "get", "set", "static", "constructor", "delete", "void",
1246:                        "with", "debugger"]
1247:         
1248:         if isTS {
1249:             keywords += ["interface", "type", "enum", "namespace", "module", "declare",
1250:                         "implements", "public", "private", "protected", "readonly",
1251:                         "abstract", "override", "keyof", "infer", "never", "unknown",
1252:                         "any", "asserts", "is"]
1253:         }
1254:         
1255:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1256:         
1257:         // Constants
1258:         let constants = ["true", "false", "null", "undefined", "NaN", "Infinity"]
1259:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1260:         
1261:         // Function names (yellow) - regular calls + arrow functions
1262:         let funcNamePattern = "\\b([a-zA-Z_$][a-zA-Z0-9_$]*)\\b(?=\\s*(?:\\(|=>))"
1263:         highlightPattern(attributed, pattern: funcNamePattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1264:         
1265:         // Types (teal)
1266:         let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1267:         highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1268:         
1269:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1270:         highlightStrings(attributed, text: text)
1271:         highlightJSTemplateLiterals(attributed, text: text)
1272:         highlightNumbers(attributed, text: text)
1273:     }
1274:     
1275:     // MARK: - Python Highlighting
1276:     
1277:     private func highlightPython(_ attributed: NSMutableAttributedString, text: String) {
1278:         let keywords = ["def", "class", "if", "elif", "else", "for", "while", "return",
1279:                        "import", "from", "as", "try", "except", "finally", "raise",
1280:                        "with", "assert", "yield", "lambda", "pass", "break", "continue",
1281:                        "global", "nonlocal", "del", "in", "not", "and", "or", "is",
1282:                        "async", "await", "match", "case"]
1283:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1284:         
1285:         let constants = ["True", "False", "None", "self", "cls"]
1286:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1287:         
1288:         // Decorators (yellow)
1289:         let decoratorPattern = "@[a-zA-Z_][a-zA-Z0-9_\\.]*"
1290:         highlightPattern(attributed, pattern: decoratorPattern, color: UIColor(theme.function), text: text)
1291:         
1292:         // Function definitions (yellow)
1293:         let funcDefPattern = "(?<=def\\s)[a-zA-Z_][a-zA-Z0-9_]*"
1294:         highlightPattern(attributed, pattern: funcDefPattern, color: UIColor(theme.function), text: text)
1295:         
1296:         // Class names (teal)
1297:         let classPattern = "(?<=class\\s)[a-zA-Z_][a-zA-Z0-9_]*"
1298:         highlightPattern(attributed, pattern: classPattern, color: UIColor(theme.type), text: text)
1299:         
1300:         // Built-in functions (yellow)
1301:         let builtins = ["print", "len", "range", "str", "int", "float", "list", "dict", "set",
1302:                        "tuple", "bool", "type", "isinstance", "hasattr", "getattr", "setattr",
1303:                        "open", "input", "map", "filter", "reduce", "zip", "enumerate",
1304:                        "sorted", "reversed", "min", "max", "sum", "abs", "round",
1305:                        "super", "object", "Exception", "ValueError", "TypeError"]
1306:         highlightKeywords(attributed, keywords: builtins, color: UIColor(theme.function), text: text)
1307:         
1308:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1309:         highlightPythonStrings(attributed, text: text)
1310:         highlightNumbers(attributed, text: text)
1311:     }
1312:     
1313:     // MARK: - HTML Highlighting
1314:     
1315:     private func highlightHTML(_ attributed: NSMutableAttributedString, text: String) {
1316:         // Tags (blue)
1317:         let tagPattern = "</?\\s*([a-zA-Z][a-zA-Z0-9-]*)(?=[\\s>])"
1318:         highlightPattern(attributed, pattern: tagPattern, color: UIColor(theme.keyword), text: text)
1319:         
1320:         // Attributes (light blue)
1321:         let attrPattern = "\\s([a-zA-Z][a-zA-Z0-9-]*)\\s*="
1322:         highlightPattern(attributed, pattern: attrPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
1323:         
1324:         // Angle brackets
1325:         let bracketPattern = "[<>/?]"
1326:         highlightPattern(attributed, pattern: bracketPattern, color: UIColor.gray, text: text)
1327:         
1328:         // Comments
1329:         highlightHTMLComments(attributed, text: text)
1330:         
1331:         // Strings
1332:         highlightStrings(attributed, text: text)
1333:     }
1334:     
1335:     // MARK: - CSS Highlighting
1336:     
1337:     private func highlightCSS(_ attributed: NSMutableAttributedString, text: String) {
1338:         // Selectors (yellow)
1339:         let selectorPattern = "([.#]?[a-zA-Z][a-zA-Z0-9_-]*)\\s*\\{"
1340:         highlightPattern(attributed, pattern: selectorPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1341:         
1342:         // Properties (light blue)
1343:         let propertyPattern = "([a-zA-Z-]+)\\s*:"
1344:         highlightPattern(attributed, pattern: propertyPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
1345:         
1346:         // Values with units
1347:         let unitPattern = "\\b(\\d+)(px|em|rem|%|vh|vw|pt|cm|mm|in)\\b"
1348:         highlightPattern(attributed, pattern: unitPattern, color: UIColor(theme.number), text: text)
1349:         
1350:         // Colors
1351:         let hexPattern = "#[0-9a-fA-F]{3,8}\\b"
1352:         highlightPattern(attributed, pattern: hexPattern, color: UIColor(theme.number), text: text)
1353:         
1354:         // Keywords
1355:         let keywords = ["important", "inherit", "initial", "unset", "none", "auto",
1356:                        "block", "inline", "flex", "grid", "absolute", "relative", "fixed"]
1357:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1358:         
1359:         highlightComments(attributed, text: text, singleLine: nil, multiLineStart: "/*", multiLineEnd: "*/")
1360:         highlightStrings(attributed, text: text)
1361:         highlightNumbers(attributed, text: text)
1362:     }
1363:     
1364:     // MARK: - JSON Highlighting
1365:     
1366:     private func highlightJSON(_ attributed: NSMutableAttributedString, text: String) {
1367:         // Keys (light blue)
1368:         let keyPattern = "\"([^\"]+)\"\\s*:"
1369:         highlightPattern(attributed, pattern: keyPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
1370:         
1371:         // String values (orange)
1372:         highlightStrings(attributed, text: text)
1373:         
1374:         // Numbers (light green)
1375:         highlightNumbers(attributed, text: text)
1376:         
1377:         // Booleans and null (use keyword color)
1378:         let constants = ["true", "false", "null"]
1379:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.keyword), text: text)
1380:     }
1381:     
1382:     // MARK: - Markdown Highlighting
1383:     
1384:     private func highlightMarkdown(_ attributed: NSMutableAttributedString, text: String) {
1385:         // Headers (blue + bold)
1386:         let headerPattern = "^#{1,6}\\s+.+$"
1387:         highlightPattern(attributed, pattern: headerPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
1388:         
1389:         // Bold (orange)
1390:         let boldPattern = "\\*\\*[^*]+\\*\\*|__[^_]+__"
1391:         highlightPattern(attributed, pattern: boldPattern, color: UIColor(theme.string), text: text)
1392:         
1393:         // Italic
1394:         let italicPattern = "(?<!\\*)\\*[^*]+\\*(?!\\*)|(?<!_)_[^_]+_(?!_)"
1395:         highlightPattern(attributed, pattern: italicPattern, color: UIColor.secondaryLabel, text: text)
1396:         
1397:         // Code blocks (green)
1398:         let codeBlockPattern = "```[\\s\\S]*?```|`[^`]+`"
1399:         highlightPattern(attributed, pattern: codeBlockPattern, color: UIColor(theme.comment), text: text)
1400:         


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 1400, "end_line": 1749}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1401-1749 of 1749)
────────────────────────────────────────
1401:         // Links (light blue)
1402:         let linkPattern = "\\[[^\\]]+\\]\\([^)]+\\)"
1403:         highlightPattern(attributed, pattern: linkPattern, color: UIColor(theme.variable), text: text)
1404:         
1405:         // Lists
1406:         let listPattern = "^\\s*[-*+]\\s"
1407:         highlightPattern(attributed, pattern: listPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
1408:     }
1409:     
1410:     // MARK: - Rust Highlighting
1411:     
1412:     private func highlightRust(_ attributed: NSMutableAttributedString, text: String) {
1413:         let keywords = ["fn", "let", "mut", "const", "if", "else", "match", "loop", "while", "for",
1414:                        "return", "struct", "enum", "impl", "trait", "type", "use", "mod", "pub",
1415:                        "self", "Self", "super", "crate", "as", "in", "ref", "move", "async", "await",
1416:                        "where", "unsafe", "extern", "dyn", "static", "break", "continue"]
1417:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1418:         
1419:         let types = ["i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize",
1420:                     "f32", "f64", "bool", "char", "str", "String", "Vec", "Option", "Result", "Box"]
1421:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1422:         
1423:         let constants = ["true", "false", "None", "Some", "Ok", "Err"]
1424:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1425:         
1426:         // Macros (yellow)
1427:         let macroPattern = "[a-zA-Z_][a-zA-Z0-9_]*!"
1428:         highlightPattern(attributed, pattern: macroPattern, color: UIColor(theme.function), text: text)
1429:         
1430:         // Lifetimes (orange)
1431:         let lifetimePattern = "'[a-zA-Z_][a-zA-Z0-9_]*"
1432:         highlightPattern(attributed, pattern: lifetimePattern, color: UIColor(theme.string), text: text)
1433:         
1434:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1435:         highlightStrings(attributed, text: text)
1436:         highlightNumbers(attributed, text: text)
1437:     }
1438:     
1439:     // MARK: - Go Highlighting
1440:     
1441:     private func highlightGo(_ attributed: NSMutableAttributedString, text: String) {
1442:         let keywords = ["func", "var", "const", "type", "struct", "interface", "map", "chan",
1443:                        "if", "else", "for", "range", "switch", "case", "default", "select",
1444:                        "return", "break", "continue", "goto", "fallthrough", "defer", "go",
1445:                        "package", "import"]
1446:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1447:         
1448:         let types = ["int", "int8", "int16", "int32", "int64", "uint", "uint8", "uint16", "uint32", "uint64",
1449:                     "float32", "float64", "complex64", "complex128", "byte", "rune", "string", "bool", "error"]
1450:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1451:         
1452:         let constants = ["true", "false", "nil", "iota"]
1453:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1454:         
1455:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1456:         highlightStrings(attributed, text: text)
1457:         highlightNumbers(attributed, text: text)
1458:     }
1459:     
1460:     // MARK: - Java Highlighting
1461:     
1462:     private func highlightJava(_ attributed: NSMutableAttributedString, text: String) {
1463:         let keywords = ["public", "private", "protected", "class", "interface", "extends", "implements",
1464:                        "static", "final", "abstract", "native", "synchronized", "volatile", "transient",
1465:                        "if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue",
1466:                        "return", "throw", "throws", "try", "catch", "finally", "new", "this", "super",
1467:                        "import", "package", "instanceof", "assert", "enum", "void"]
1468:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1469:         
1470:         let types = ["int", "long", "short", "byte", "float", "double", "char", "boolean",
1471:                     "String", "Integer", "Long", "Double", "Boolean", "Object", "List", "Map", "Set"]
1472:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1473:         
1474:         let constants = ["true", "false", "null"]
1475:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1476:         
1477:         // Annotations
1478:         let annotationPattern = "@[a-zA-Z][a-zA-Z0-9]*"
1479:         highlightPattern(attributed, pattern: annotationPattern, color: UIColor(theme.function), text: text)
1480:         
1481:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1482:         highlightStrings(attributed, text: text)
1483:         highlightNumbers(attributed, text: text)
1484:     }
1485:     
1486:     // MARK: - C/C++ Highlighting
1487:     
1488:     private func highlightCpp(_ attributed: NSMutableAttributedString, text: String) {
1489:         let keywords = ["auto", "break", "case", "catch", "class", "const", "continue", "default",
1490:                        "delete", "do", "else", "enum", "explicit", "extern", "for", "friend", "goto",
1491:                        "if", "inline", "mutable", "namespace", "new", "operator", "private", "protected",
1492:                        "public", "register", "return", "sizeof", "static", "struct", "switch", "template",
1493:                        "this", "throw", "try", "typedef", "typename", "union", "using", "virtual",
1494:                        "volatile", "while", "constexpr", "nullptr", "override", "final", "noexcept"]
1495:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1496:         
1497:         let types = ["void", "int", "long", "short", "char", "float", "double", "bool", "signed", "unsigned",
1498:                     "int8_t", "int16_t", "int32_t", "int64_t", "uint8_t", "uint16_t", "uint32_t", "uint64_t",
1499:                     "size_t", "string", "vector", "map", "set", "unique_ptr", "shared_ptr"]
1500:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1501:         
1502:         let constants = ["true", "false", "NULL", "nullptr"]
1503:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1504:         
1505:         // Preprocessor directives
1506:         let preprocPattern = "^\\s*#\\s*(include|define|ifdef|ifndef|endif|if|else|elif|pragma|error|warning).*$"
1507:         highlightPattern(attributed, pattern: preprocPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
1508:         
1509:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1510:         highlightStrings(attributed, text: text)
1511:         highlightNumbers(attributed, text: text)
1512:     }
1513:     
1514:     // MARK: - Ruby Highlighting
1515:     
1516:     private func highlightRuby(_ attributed: NSMutableAttributedString, text: String) {
1517:         let keywords = ["def", "class", "module", "if", "elsif", "else", "unless", "case", "when",
1518:                        "while", "until", "for", "do", "end", "begin", "rescue", "ensure", "raise",
1519:                        "return", "yield", "break", "next", "redo", "retry", "self", "super",
1520:                        "require", "require_relative", "include", "extend", "attr_reader", "attr_writer", "attr_accessor",
1521:                        "public", "private", "protected", "alias", "and", "or", "not", "in"]
1522:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1523:         
1524:         let constants = ["true", "false", "nil"]
1525:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1526:         
1527:         // Symbols (orange)
1528:         let symbolPattern = ":[a-zA-Z_][a-zA-Z0-9_]*"
1529:         highlightPattern(attributed, pattern: symbolPattern, color: UIColor(theme.string), text: text)
1530:         
1531:         // Instance variables (light blue)
1532:         let ivarPattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
1533:         highlightPattern(attributed, pattern: ivarPattern, color: UIColor(theme.variable), text: text)
1534:         
1535:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: "=begin", multiLineEnd: "=end")
1536:         highlightStrings(attributed, text: text)
1537:         highlightNumbers(attributed, text: text)
1538:     }
1539:     
1540:     // MARK: - PHP Highlighting
1541:     
1542:     private func highlightPHP(_ attributed: NSMutableAttributedString, text: String) {
1543:         let keywords = ["function", "class", "interface", "trait", "extends", "implements", "use",
1544:                        "public", "private", "protected", "static", "final", "abstract", "const",
1545:                        "if", "else", "elseif", "switch", "case", "default", "for", "foreach", "while", "do",
1546:                        "return", "break", "continue", "throw", "try", "catch", "finally",
1547:                        "new", "clone", "instanceof", "echo", "print", "die", "exit",
1548:                        "require", "require_once", "include", "include_once", "namespace"]
1549:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1550:         
1551:         let constants = ["true", "false", "null", "TRUE", "FALSE", "NULL"]
1552:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1553:         
1554:         // Variables (light blue)
1555:         let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
1556:         highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
1557:         
1558:         highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1559:         highlightStrings(attributed, text: text)
1560:         highlightNumbers(attributed, text: text)
1561:     }
1562:     
1563:     // MARK: - Shell Highlighting
1564:     
1565:     private func highlightShell(_ attributed: NSMutableAttributedString, text: String) {
1566:         let keywords = ["if", "then", "else", "elif", "fi", "for", "while", "do", "done", "case", "esac",
1567:                        "function", "return", "exit", "break", "continue", "local", "export", "readonly",
1568:                        "source", "alias", "unalias", "set", "unset", "shift", "eval", "exec",
1569:                        "echo", "printf", "read", "cd", "pwd", "ls", "mkdir", "rm", "cp", "mv"]
1570:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1571:         
1572:         // Variables (light blue)
1573:         let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*|\\$\\{[^}]+\\}"
1574:         highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
1575:         
1576:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1577:         highlightStrings(attributed, text: text)
1578:         highlightNumbers(attributed, text: text)
1579:     }
1580:     
1581:     // MARK: - YAML Highlighting
1582:     
1583:     private func highlightYAML(_ attributed: NSMutableAttributedString, text: String) {
1584:         // Keys (light blue)
1585:         let keyPattern = "^\\s*([a-zA-Z_][a-zA-Z0-9_-]*)\\s*:"
1586:         highlightPattern(attributed, pattern: keyPattern, color: UIColor(theme.variable), text: text, options: .anchorsMatchLines, captureGroup: 1)
1587:         
1588:         // Booleans and null
1589:         let constants = ["true", "false", "yes", "no", "on", "off", "null", "~"]
1590:         highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1591:         
1592:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1593:         highlightStrings(attributed, text: text)
1594:         highlightNumbers(attributed, text: text)
1595:     }
1596:     
1597:     // MARK: - SQL Highlighting
1598:     
1599:     private func highlightSQL(_ attributed: NSMutableAttributedString, text: String) {
1600:         let keywords = ["SELECT", "FROM", "WHERE", "AND", "OR", "NOT", "IN", "LIKE", "BETWEEN",
1601:                        "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE", "CREATE", "ALTER", "DROP",
1602:                        "TABLE", "INDEX", "VIEW", "DATABASE", "SCHEMA", "PRIMARY", "KEY", "FOREIGN", "REFERENCES",
1603:                        "JOIN", "INNER", "LEFT", "RIGHT", "OUTER", "FULL", "ON", "AS", "DISTINCT",
1604:                        "ORDER", "BY", "ASC", "DESC", "GROUP", "HAVING", "LIMIT", "OFFSET", "UNION",
1605:                        "NULL", "IS", "TRUE", "FALSE", "CASE", "WHEN", "THEN", "ELSE", "END",
1606:                        "COUNT", "SUM", "AVG", "MIN", "MAX", "COALESCE", "CAST",
1607:                        "select", "from", "where", "and", "or", "not", "in", "like", "between",
1608:                        "insert", "into", "values", "update", "set", "delete", "create", "alter", "drop",
1609:                        "table", "index", "view", "database", "schema", "primary", "key", "foreign", "references",
1610:                        "join", "inner", "left", "right", "outer", "full", "on", "as", "distinct",
1611:                        "order", "by", "asc", "desc", "group", "having", "limit", "offset", "union",
1612:                        "null", "is", "true", "false", "case", "when", "then", "else", "end"]
1613:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1614:         
1615:         let types = ["INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT", "FLOAT", "DOUBLE", "DECIMAL",
1616:                     "VARCHAR", "CHAR", "TEXT", "BLOB", "DATE", "TIME", "DATETIME", "TIMESTAMP", "BOOLEAN",
1617:                     "int", "integer", "bigint", "smallint", "tinyint", "float", "double", "decimal",
1618:                     "varchar", "char", "text", "blob", "date", "time", "datetime", "timestamp", "boolean"]
1619:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1620:         
1621:         highlightComments(attributed, text: text, singleLine: "--", multiLineStart: "/*", multiLineEnd: "*/")
1622:         highlightStrings(attributed, text: text)
1623:         highlightNumbers(attributed, text: text)
1624:     }
1625:     
1626:     // MARK: - GraphQL Highlighting
1627:     
1628:     private func highlightGraphQL(_ attributed: NSMutableAttributedString, text: String) {
1629:         // Keywords
1630:         let keywords = ["query", "mutation", "subscription", "fragment", "on", "type", 
1631:                        "interface", "union", "enum", "scalar", "input", "extend", 
1632:                        "directive", "schema", "implements"]
1633:         highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1634:         
1635:         // Built-in scalar types
1636:         let types = ["Int", "Float", "String", "Boolean", "ID"]
1637:         highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
1638:         
1639:         // Variables ($name)
1640:         let variablePattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
1641:         highlightPattern(attributed, pattern: variablePattern, color: UIColor(theme.variable), text: text)
1642:         
1643:         // Directives (@deprecated, @skip, @include, etc.)
1644:         let directivePattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
1645:         highlightPattern(attributed, pattern: directivePattern, color: UIColor(theme.function), text: text)
1646:         
1647:         // Comments (# single line)
1648:         highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
1649:         
1650:         // Strings
1651:         highlightStrings(attributed, text: text)
1652:         
1653:         // Numbers
1654:         highlightNumbers(attributed, text: text)
1655:     }
1656:     
1657:     // MARK: - Helper Methods
1658:     
1659:     private func highlightKeywords(_ attributed: NSMutableAttributedString, keywords: [String], color: UIColor, text: String) {
1660:         for keyword in keywords {
1661:             let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
1662:             highlightPattern(attributed, pattern: pattern, color: color, text: text)
1663:         }
1664:     }
1665:     
1666:     private func highlightPattern(_ attributed: NSMutableAttributedString, pattern: String, color: UIColor, text: String, options: NSRegularExpression.Options = [], captureGroup: Int = 0) {
1667:         guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
1668:         let range = NSRange(location: 0, length: text.utf16.count)
1669:         
1670:         regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
1671:             guard let match = match else { return }
1672:             let matchRange = captureGroup > 0 && match.numberOfRanges > captureGroup
1673:                 ? match.range(at: captureGroup)
1674:                 : match.range
1675:             if matchRange.location != NSNotFound {
1676:                 attributed.addAttribute(.foregroundColor, value: color, range: matchRange)
1677:             }
1678:         }
1679:     }
1680:     
1681:     private func highlightStrings(_ attributed: NSMutableAttributedString, text: String) {
1682:         // Double-quoted strings
1683:         let doublePattern = "\"(?:[^\"\\\\]|\\\\.)*\""
1684:         highlightPattern(attributed, pattern: doublePattern, color: UIColor(theme.string), text: text)
1685:         
1686:         // Single-quoted strings
1687:         let singlePattern = "'(?:[^'\\\\]|\\\\.)*'"
1688:         highlightPattern(attributed, pattern: singlePattern, color: UIColor(theme.string), text: text)
1689:     }
1690:     
1691:     private func highlightPythonStrings(_ attributed: NSMutableAttributedString, text: String) {
1692:         // Triple-quoted strings first
1693:         let tripleDoublePattern = "\"\"\"[\\s\\S]*?\"\"\""
1694:         highlightPattern(attributed, pattern: tripleDoublePattern, color: UIColor(theme.string), text: text)
1695:         
1696:         let tripleSinglePattern = "'''[\\s\\S]*?'''"
1697:         highlightPattern(attributed, pattern: tripleSinglePattern, color: UIColor(theme.string), text: text)
1698:         
1699:         // Then regular strings
1700:         highlightStrings(attributed, text: text)
1701:         
1702:         // F-strings (with expressions highlighted differently)
1703:         let fstringPattern = "f\"[^\"]*\"|f'[^']*'"
1704:         highlightPattern(attributed, pattern: fstringPattern, color: UIColor(theme.string), text: text)
1705:     }
1706:     
1707:     private func highlightJSTemplateLiterals(_ attributed: NSMutableAttributedString, text: String) {
1708:         // Template literals
1709:         let templatePattern = "`[^`]*`"
1710:         highlightPattern(attributed, pattern: templatePattern, color: UIColor(theme.string), text: text)
1711:     }
1712:     
1713:     private func highlightComments(_ attributed: NSMutableAttributedString, text: String, singleLine: String?, multiLineStart: String?, multiLineEnd: String?) {
1714:         // Single-line comments
1715:         if let single = singleLine {
1716:             let pattern = "\(NSRegularExpression.escapedPattern(for: single)).*$"
1717:             highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text, options: .anchorsMatchLines)
1718:         }
1719:         
1720:         // Multi-line comments
1721:         if let start = multiLineStart, let end = multiLineEnd {
1722:             let pattern = "\(NSRegularExpression.escapedPattern(for: start))[\\s\\S]*?\(NSRegularExpression.escapedPattern(for: end))"
1723:             highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
1724:         }
1725:     }
1726:     
1727:     private func highlightHTMLComments(_ attributed: NSMutableAttributedString, text: String) {
1728:         let pattern = "<!--[\\s\\S]*?-->"
1729:         highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
1730:     }
1731:     
1732:     private func highlightNumbers(_ attributed: NSMutableAttributedString, text: String) {
1733:         // Hex numbers
1734:         let hexPattern = "\\b0[xX][0-9a-fA-F]+\\b"
1735:         highlightPattern(attributed, pattern: hexPattern, color: UIColor(theme.number), text: text)
1736:         
1737:         // Binary numbers
1738:         let binPattern = "\\b0[bB][01]+\\b"
1739:         highlightPattern(attributed, pattern: binPattern, color: UIColor(theme.number), text: text)
1740:         
1741:         // Octal numbers
1742:         let octPattern = "\\b0[oO][0-7]+\\b"
1743:         highlightPattern(attributed, pattern: octPattern, color: UIColor(theme.number), text: text)
1744:         
1745:         // Decimal numbers (including floats and scientific notation)
1746:         let decPattern = "\\b\\d+\\.?\\d*([eE][+-]?\\d+)?\\b"
1747:         highlightPattern(attributed, pattern: decPattern, color: UIColor(theme.number), text: text)
1748:     }
1749: }


Now let me check the MultiCursorTextView.swift file:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 1-281 of 281)
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
281: 


Now let me check the CodeFoldingManager.swift file:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 1-824 of 824)
────────────────────────────────────────
1: import SwiftUI
2: import Foundation
3: 
4: // MARK: - Fold Region Model
5: struct FoldRegion: Identifiable, Codable {
6:     let id = UUID()
7:     let startLine: Int
8:     let endLine: Int
9:     var isFolded: Bool = false
10:     let type: FoldType
11:     let label: String?
12:     
13:     enum FoldType: String, Codable {
14:         case function
15:         case classOrStruct
16:         case `extension`
17:         case enumDeclaration
18:         case protocolDeclaration
19:         case importStatement
20:         case comment
21:         case region
22:         case controlFlow
23:         case genericBlock
24:         
25:         var displayName: String {
26:             switch self {
27:             case .function: return "Function"
28:             case .classOrStruct: return "Class/Struct"
29:             case .extension: return "Extension"
30:             case .enumDeclaration: return "Enum"
31:             case .protocolDeclaration: return "Protocol"
32:             case .importStatement: return "Import"
33:             case .comment: return "Comment"
34:             case .region: return "Region"
35:             case .controlFlow: return "Control Flow"
36:             case .genericBlock: return "Block"
37:             }
38:         }
39:         
40:         var icon: String {
41:             switch self {
42:             case .function: return "f"
43:             case .classOrStruct: return "C"
44:             case .extension: return "E"
45:             case .enumDeclaration: return "E"
46:             case .protocolDeclaration: return "P"
47:             case .importStatement: return "i"
48:             case .comment: return "//"
49:             case .region: return "#"
50:             case .controlFlow: return "if"
51:             case .genericBlock: return "{}"
52:             }
53:         }
54:     }
55:     
56:     // Exclude id from Codable
57:     enum CodingKeys: String, CodingKey {
58:         case startLine, endLine, isFolded, type, label
59:     }
60: }
61: 
62: // MARK: - UserDefaults Keys
63: struct UserDefaultsKeys {
64:     static let foldStatePrefix = "codeFoldingState_"
65: }
66: 
67: // MARK: - Code Folding Manager
68: class CodeFoldingManager: ObservableObject {
69:     static let shared = CodeFoldingManager()
70:     
71:     @Published var foldRegions: [FoldRegion] = []
72:     @Published var collapsedLines: Set<Int> = []
73:     
74:     // Dictionary to manage fold regions per file
75:     private var foldRegionsByFile: [String: [FoldRegion]] = [:]
76:     
77:     private var currentFilePath: String?
78:     private var currentFileId: String?
79:     
80:     // MARK: - Enhanced Fold Detection
81:     
82:     /// Detects all foldable regions in the given code
83:     func detectFoldableRegions(in code: String, filePath: String? = nil) {
84:         self.currentFilePath = filePath
85:         self.currentFileId = filePath
86:         
87:         let lines = code.components(separatedBy: .newlines)
88:         var regions: [FoldRegion] = []
89:         
90:         // Track different types of blocks
91:         var blockStack: [(type: FoldRegion.FoldType, startLine: Int, label: String?)] = []
92:         var commentStack: [(startLine: Int, isMultiline: Bool)] = []
93:         var regionStack: [(startLine: Int, label: String)] = []
94:         
95:         for (index, line) in lines.enumerated() {
96:             let trimmed = line.trimmingCharacters(in: .whitespaces)
97:             let leadingWhitespace = line.prefix { $0 == " " || $0 == "\t" }.count
98:             
99:             // Skip empty lines for most detections
100:             guard !trimmed.isEmpty else { continue }
101:             
102:             // MARK: - Region Detection (#region, #pragma mark, MARK:)
103:             if detectRegionStart(trimmed) != nil {
104:                 if let label = detectRegionStart(trimmed) {
105:                     regionStack.append((index, label))
106:                 }
107:             } else if detectRegionEnd(trimmed) {
108:                 if let region = regionStack.popLast() {
109:                     if index - region.startLine > 1 {
110:                         regions.append(FoldRegion(
111:                             startLine: region.startLine,
112:                             endLine: index,
113:                             type: .region,
114:                             label: region.label
115:                         ))
116:                     }
117:                 }
118:             }
119:             
120:             // MARK: - Import Statement Detection
121:             if trimmed.hasPrefix("import ") {
122:                 // Group consecutive imports
123:                 let importEnd = findConsecutiveImports(from: index, in: lines)
124:                 if importEnd > index {
125:                     regions.append(FoldRegion(
126:                         startLine: index,
127:                         endLine: importEnd,
128:                         type: .importStatement,
129:                         label: "Imports"
130:                     ))
131:                 }
132:             }
133:             
134:             // MARK: - Comment Detection
135:             if detectCommentStart(trimmed) {
136:                 commentStack.append((index, true))
137:             } else if trimmed.starts(with: "//") {
138:                 // Single-line comment - check for consecutive comment blocks
139:                 let commentEnd = findConsecutiveComments(from: index, in: lines)
140:                 if commentEnd > index {
141:                     regions.append(FoldRegion(
142:                         startLine: index,
143:                         endLine: commentEnd,
144:                         type: .comment,
145:                         label: "Comment"
146:                     ))
147:                 }
148:             } else if detectCommentEnd(trimmed) {
149:                 if let comment = commentStack.popLast() {
150:                     if index - comment.startLine > 1 {
151:                         regions.append(FoldRegion(
152:                             startLine: comment.startLine,
153:                             endLine: index,
154:                             type: .comment,
155:                             label: "Comment"
156:                         ))
157:                     }
158:                 }
159:             }
160:             
161:             // MARK: - Class/Struct/Enum/Protocol/Extension Detection
162:             if let declaration = detectDeclaration(trimmed) {
163:                 if trimmed.contains("{") {
164:                     blockStack.append((declaration.type, index, declaration.label))
165:                 } else {
166:                     // Declaration without opening brace - look ahead for it
167:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
168:                         blockStack.append((declaration.type, index, declaration.label))
169:                     }
170:                 }
171:             }
172:             
173:             // MARK: - Function/Method Detection
174:             if let functionInfo = detectFunction(trimmed) {
175:                 if trimmed.contains("{") {
176:                     blockStack.append((.function, index, functionInfo))
177:                 } else {
178:                     // Function without opening brace - look ahead
179:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
180:                         blockStack.append((.function, index, functionInfo))
181:                     }
182:                 }
183:             }
184:             
185:             // MARK: - Control Flow Detection (if, guard, for, while, switch, etc.)
186:             if let controlFlowLabel = detectControlFlow(trimmed) {
187:                 if trimmed.contains("{") {
188:                     blockStack.append((.controlFlow, index, controlFlowLabel))
189:                 } else {
190:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
191:                         blockStack.append((.controlFlow, index, controlFlowLabel))
192:                     }
193:                 }
194:             }
195:             
196:             // MARK: - Generic Block Detection
197:             if trimmed.hasSuffix("{") && !isDeclarationLine(trimmed) && !isFunctionLine(trimmed) {
198:                 blockStack.append((.genericBlock, index, nil))
199:             }
200:             
201:             // MARK: - Block End Detection
202:             if detectBlockEnd(trimmed, leadingWhitespace: leadingWhitespace) {
203:                 if let lastBlock = blockStack.popLast() {
204:                     if index - lastBlock.startLine > 1 {
205:                         regions.append(FoldRegion(
206:                             startLine: lastBlock.startLine,
207:                             endLine: index,
208:                             type: lastBlock.type,
209:                             label: lastBlock.label
210:                         ))
211:                     }
212:                 }
213:             }
214:         }
215:         
216:         // Handle any remaining unclosed blocks
217:         while let lastBlock = blockStack.popLast() {
218:             if lines.count - 1 - lastBlock.startLine > 1 {
219:                 regions.append(FoldRegion(
220:                     startLine: lastBlock.startLine,
221:                     endLine: lines.count - 1,
222:                     type: lastBlock.type,
223:                     label: lastBlock.label
224:                 ))
225:             }
226:         }
227:         
228:         // Sort regions by start line
229:         regions.sort { $0.startLine < $1.startLine }
230:         
231:         self.foldRegions = regions
232:         
233:         // Store regions in the per-file dictionary
234:         if let fileId = currentFileId {
235:             foldRegionsByFile[fileId] = regions
236:         }
237:         
238:         // Restore previous fold state for this file
239:         if let filePath = filePath {
240:             restoreFoldState(for: filePath)
241:         }
242:         
243:         updateCollapsedLines()
244:     }
245:     
246:     // MARK: - Detection Helper Methods
247:     
248:     private func detectRegionStart(_ line: String) -> String? {
249:         // C# / VS style regions
250:         if line.hasPrefix("#region") {
251:             let components = line.components(separatedBy: "#region")
252:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Region"
253:         }
254:         // Objective-C pragma marks
255:         if line.hasPrefix("#pragma mark") {
256:             let components = line.components(separatedBy: "#pragma mark")
257:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
258:         }
259:         // Swift MARK comments
260:         if line.contains("MARK:") {
261:             let components = line.components(separatedBy: "MARK:")
262:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
263:         }
264:         // TODO/FIXME regions
265:         if line.contains("TODO:") {
266:             let components = line.components(separatedBy: "TODO:")
267:             return "TODO: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
268:         }
269:         if line.contains("FIXME:") {
270:             let components = line.components(separatedBy: "FIXME:")
271:             return "FIXME: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
272:         }
273:         return nil
274:     }
275:     
276:     private func detectRegionEnd(_ line: String) -> Bool {
277:         return line.hasPrefix("#endregion") || 
278:                line == "// MARK: -" ||
279:                line.hasPrefix("#pragma mark -")
280:     }
281:     
282:     private func detectCommentStart(_ line: String) -> Bool {
283:         return line.hasPrefix("/*") && !line.contains("*/")
284:     }
285:     
286:     private func detectCommentEnd(_ line: String) -> Bool {
287:         return line.contains("*/") && !line.hasPrefix("/*")
288:     }
289:     
290:     private func findConsecutiveImports(from startIndex: Int, in lines: [String]) -> Int {
291:         var endIndex = startIndex
292:         for i in startIndex..<lines.count {
293:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
294:             if trimmed.hasPrefix("import ") {
295:                 endIndex = i
296:             } else if !trimmed.isEmpty {
297:                 break
298:             }
299:         }
300:         return endIndex
301:     }
302:     
303:     private func findConsecutiveComments(from startIndex: Int, in lines: [String]) -> Int {
304:         var endIndex = startIndex
305:         for i in startIndex..<lines.count {
306:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
307:             if trimmed.starts(with: "//") {
308:                 endIndex = i
309:             } else if !trimmed.isEmpty {
310:                 break
311:             }
312:         }
313:         return endIndex
314:     }
315:     
316:     private func detectDeclaration(_ line: String) -> (type: FoldRegion.FoldType, label: String)? {
317:         // Class detection
318:         if let className = extractName(from: line, prefix: "class", visibility: ["public", "private", "internal", "fileprivate", "open", "final"]) {
319:             return (.classOrStruct, className)
320:         }
321:         // Struct detection
322:         if let structName = extractName(from: line, prefix: "struct", visibility: ["public", "private", "internal", "fileprivate"]) {
323:             return (.classOrStruct, structName)
324:         }
325:         // Enum detection
326:         if let enumName = extractName(from: line, prefix: "enum", visibility: ["public", "private", "internal", "fileprivate", "indirect"]) {
327:             return (.enumDeclaration, enumName)
328:         }
329:         // Protocol detection
330:         if let protocolName = extractName(from: line, prefix: "protocol", visibility: ["public", "private", "internal", "fileprivate"]) {
331:             return (.protocolDeclaration, protocolName)
332:         }
333:         // Extension detection
334:         if let extensionName = extractName(from: line, prefix: "extension", visibility: []) {
335:             return (.extension, extensionName)
336:         }
337:         return nil
338:     }
339:     
340:     private func detectFunction(_ line: String) -> String? {
341:         // Function detection with visibility modifiers
342:         let visibilityKeywords = ["public", "private", "internal", "fileprivate", "static", "class", "override", "final", "mutating", "convenience"]
343:         
344:         // Check for 'func' keyword
345:         if line.contains("func ") {
346:             // Extract function name
347:             let funcPattern = "func\\s+(\\w+)"
348:             if let regex = try? NSRegularExpression(pattern: funcPattern),
349:                let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
350:                let nameRange = Range(match.range(at: 1), in: line) {
351:                 let functionName = String(line[nameRange])
352:                 // Check for parameters to create label
353:                 if let parenStart = line.firstIndex(of: "("), let parenEnd = line.firstIndex(of: ")") {
354:                     let params = String(line[parenStart...parenEnd])
355:                     return "\(functionName)\(params)"
356:                 }
357:                 return functionName
358:             }
359:         }
360:         
361:         // Init detection
362:         if let initName = extractName(from: line, prefix: "init", visibility: visibilityKeywords) {
363:             return "\(initName)"
364:         }
365:         
366:         // Deinit detection
367:         if line.contains("deinit") {
368:             return "deinit"
369:         }
370:         
371:         // Computed property with get/set
372:         if line.hasPrefix("var ") && (line.contains("{") || line.contains("get")) {
373:             if let varName = extractVariableName(from: line) {
374:                 return varName
375:             }
376:         }
377:         
378:         return nil
379:     }
380:     
381:     private func detectControlFlow(_ line: String) -> String? {
382:         let controlFlowPatterns = [
383:             ("if ", "if"),
384:             ("guard ", "guard"),
385:             ("else if", "else if"),
386:             ("else", "else"),
387:             ("for ", "for"),
388:             ("while ", "while"),
389:             ("repeat", "repeat"),
390:             ("switch ", "switch"),
391:             ("case ", "case"),
392:             ("default:", "default"),
393:             ("do ", "do"),
394:             ("catch", "catch")
395:         ]
396:         
397:         for (pattern, label) in controlFlowPatterns {
398:             if line.contains(pattern) {
399:                 return label
400:             }
401:         }
402:         return nil
403:     }
404:     
405:     private func extractName(from line: String, prefix: String, visibility: [String]) -> String? {
406:         var components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
407:         
408:         // Remove visibility modifiers
409:         components = components.filter { !visibility.contains($0) }
410:         
411:         // Find prefix index
412:         if let prefixIndex = components.firstIndex(where: { $0 == prefix }),
413:            prefixIndex + 1 < components.count {
414:             var name = components[prefixIndex + 1]
415:             // Remove colons and other trailing characters
416:             name = name.components(separatedBy: ":").first ?? name
417:             name = name.components(separatedBy: "<").first ?? name
418:             name = name.components(separatedBy: ":").first ?? name
419:             return name
420:         }
421:         return nil
422:     }
423:     
424:     private func extractVariableName(from line: String) -> String? {
425:         let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
426:         if components.count >= 2, components[0] == "var" {
427:             var varName = components[1]
428:             varName = varName.components(separatedBy: ":").first ?? varName
429:             varName = varName.components(separatedBy: "=").first ?? varName
430:             return varName
431:         }
432:         return nil
433:     }
434:     
435:     private func findOpeningBrace(from startIndex: Int, in lines: [String]) -> Int? {
436:         for i in startIndex..<min(startIndex + 5, lines.count) {
437:             if lines[i].contains("{") {
438:                 return i
439:             }
440:         }
441:         return nil
442:     }
443:     
444:     private func isDeclarationLine(_ line: String) -> Bool {
445:         let keywords = ["class", "struct", "enum", "protocol", "extension", "init", "func"]
446:         return keywords.contains { line.contains("\($0) ") }
447:     }
448:     
449:     private func isFunctionLine(_ line: String) -> Bool {
450:         return line.contains("func ") || line.contains("init ")
451:     }
452:     
453:     private func detectBlockEnd(_ line: String, leadingWhitespace: Int) -> Bool {
454:         return (line.hasPrefix("}") || line.starts(with: "}")) && 
455:                (line.trimmingCharacters(in: .whitespaces) == "}" || 
456:                 line.trimmingCharacters(in: .whitespaces).hasPrefix("}"))
457:     }
458:     
459:     // MARK: - Fold State Persistence
460:     
461:     /// Saves the current fold state to UserDefaults
462:     func saveFoldState(for filePath: String) {
463:         let key = UserDefaultsKeys.foldStatePrefix + filePath
464:         
465:         // Use regions from the dictionary if available
466:         let regionsToSave: [FoldRegion]
467:         if let fileId = currentFileId, let storedRegions = foldRegionsByFile[fileId] {
468:             regionsToSave = storedRegions
469:         } else {
470:             regionsToSave = foldRegions
471:         }
472:         
473:         // Create a simplified representation for storage
474:         let foldState = regionsToSave.map { FoldStateEntry(startLine: $0.startLine, isFolded: $0.isFolded) }
475:         
476:         if let data = try? JSONEncoder().encode(foldState) {
477:             UserDefaults.standard.set(data, forKey: key)
478:         }
479:     }
480:     
481:     /// Restores fold state from UserDefaults
482:     private func restoreFoldState(for filePath: String) {
483:         let key = UserDefaultsKeys.foldStatePrefix + filePath
484:         
485:         guard let data = UserDefaults.standard.data(forKey: key),
486:               let foldState = try? JSONDecoder().decode([FoldStateEntry].self, from: data) else {
487:             return
488:         }
489:         
490:         // Apply saved state to current regions
491:         for savedState in foldState {
492:             if let index = foldRegions.firstIndex(where: { $0.startLine == savedState.startLine }) {
493:                 foldRegions[index].isFolded = savedState.isFolded
494:             }
495:         }
496:     }
497:     
498:     /// Helper struct for persisting fold state
499:     private struct FoldStateEntry: Codable {
500:         let startLine: Int
501:         let isFolded: Bool
502:     }
503:     
504:     /// Clears fold state for a specific file
505:     func clearFoldState(for filePath: String) {
506:         let key = UserDefaultsKeys.foldStatePrefix + filePath
507:         UserDefaults.standard.removeObject(forKey: key)
508:     }
509:     
510:     /// Clears all fold states
511:     func clearAllFoldStates() {
512:         let defaults = UserDefaults.standard
513:         let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(UserDefaultsKeys.foldStatePrefix) }
514:         for key in keys {
515:             defaults.removeObject(forKey: key)
516:         }
517:     }
518:     
519:     // MARK: - Fold Operations
520:     
521:     /// Toggles the fold state at a specific line
522:     func toggleFold(at line: Int) {
523:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
524:             foldRegions[regionIndex].isFolded.toggle()
525:             updateCollapsedLines()
526:             
527:             // Save state after toggling
528:             if let filePath = currentFilePath {
529:                 saveFoldState(for: filePath)
530:             }
531:         }
532:     }
533:     
534:     /// Expands a folded region
535:     func expandRegion(at line: Int) {
536:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
537:             foldRegions[regionIndex].isFolded = false
538:             updateCollapsedLines()
539:             
540:             if let filePath = currentFilePath {
541:                 saveFoldState(for: filePath)
542:             }
543:         }
544:     }
545:     
546:     /// Collapses a region
547:     func collapseRegion(at line: Int) {
548:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
549:             foldRegions[regionIndex].isFolded = true
550:             updateCollapsedLines()
551:             
552:             if let filePath = currentFilePath {
553:                 saveFoldState(for: filePath)
554:             }
555:         }
556:     }
557:     
558:     /// Expands all folded regions
559:     func expandAll() {
560:         for index in foldRegions.indices {
561:             foldRegions[index].isFolded = false
562:         }
563:         updateCollapsedLines()
564:         
565:         if let filePath = currentFilePath {
566:             saveFoldState(for: filePath)
567:         }
568:     }
569:     
570:     /// Folds the region at current cursor line (stub - requires cursor position from editor)
571:     func foldCurrentLine() {
572:         // This would need cursor position from the editor
573:         // For now, it's a no-op since we don't have cursor context
574:     }
575:     
576:     /// Unfolds the region at current cursor line (stub - requires cursor position from editor)
577:     func unfoldCurrentLine() {
578:         // This would need cursor position from the editor
579:         // For now, it's a no-op since we don't have cursor context
580:     }
581:     
582:     /// Collapses all foldable regions
583:     func collapseAll() {
584:         for index in foldRegions.indices {
585:             foldRegions[index].isFolded = true
586:         }
587:         updateCollapsedLines()
588:         
589:         if let filePath = currentFilePath {
590:             saveFoldState(for: filePath)
591:         }
592:     }
593:     
594:     /// Collapses all regions of a specific type
595:     func collapseAll(ofType type: FoldRegion.FoldType) {
596:         for index in foldRegions.indices {
597:             if foldRegions[index].type == type {
598:                 foldRegions[index].isFolded = true
599:             }
600:         }
601:         updateCollapsedLines()
602:         
603:         if let filePath = currentFilePath {
604:             saveFoldState(for: filePath)
605:         }
606:     }
607:     
608:     /// Expands all regions of a specific type
609:     func expandAll(ofType type: FoldRegion.FoldType) {
610:         for index in foldRegions.indices {
611:             if foldRegions[index].type == type {
612:                 foldRegions[index].isFolded = false
613:             }
614:         }
615:         updateCollapsedLines()
616:         
617:         if let filePath = currentFilePath {
618:             saveFoldState(for: filePath)
619:         }
620:     }
621:     
622:     // MARK: - Query Methods
623:     
624:     /// Checks if a line is foldable
625:     func isFoldable(line: Int) -> Bool {
626:         return foldRegions.contains { $0.startLine == line }
627:     }
628:     
629:     /// Checks if a line is currently folded
630:     func isLineFolded(line: Int) -> Bool {
631:         return collapsedLines.contains(line)
632:     }
633:     
634:     /// Checks if a region at a given line is folded
635:     func isRegionFolded(at line: Int) -> Bool {
636:         return foldRegions.first { $0.startLine == line }?.isFolded ?? false
637:     }
638:     
639:     /// Gets the fold region at a specific line
640:     func getRegion(at line: Int) -> FoldRegion? {
641:         return foldRegions.first { $0.startLine == line }
642:     }
643:     
644:     /// Gets all fold regions of a specific type
645:     func getRegions(ofType type: FoldRegion.FoldType) -> [FoldRegion] {
646:         return foldRegions.filter { $0.type == type }
647:     }
648:     
649:     // MARK: - File-Aware Methods
650:     
651:     /// Checks if a line is foldable for a specific file
652:     func isFoldable(fileId: String, line: Int) -> Bool {
653:         guard let regions = foldRegionsByFile[fileId] else { return false }
654:         return regions.contains { $0.startLine == line }
655:     }
656:     
657:     /// Checks if a region at a given line is folded for a specific file
658:     func isFolded(fileId: String, line: Int) -> Bool {
659:         guard let regions = foldRegionsByFile[fileId] else { return false }
660:         return regions.first { $0.startLine == line }?.isFolded ?? false
661:     }
662:     
663:     /// Toggles the fold state at a specific line for a specific file
664:     func toggleFold(fileId: String, line: Int) {
665:         guard var regions = foldRegionsByFile[fileId] else { return }
666:         
667:         if let regionIndex = regions.firstIndex(where: { $0.startLine == line }) {
668:             regions[regionIndex].isFolded.toggle()
669:             foldRegionsByFile[fileId] = regions
670:             
671:             // Update current file regions if this is the active file
672:             if fileId == currentFileId {
673:                 self.foldRegions = regions
674:                 updateCollapsedLines()
675:             }
676:             
677:             // Save state after toggling
678:             saveFoldState(for: fileId)
679:         }
680:     }
681:     
682:     /// Gets fold regions for a specific file
683:     func getFoldRegions(for fileId: String) -> [FoldRegion] {
684:         return foldRegionsByFile[fileId] ?? []
685:     }
686:     
687:     /// Clears fold regions for a specific file from memory
688:     func clearFoldRegions(for fileId: String) {
689:         foldRegionsByFile.removeValue(forKey: fileId)
690:     }
691:     
692:     /// Clears all fold regions from memory
693:     func clearAllFoldRegions() {
694:         foldRegionsByFile.removeAll()
695:     }
696:     
697:     /// Gets folded line ranges for text hiding
698:     /// Returns an array of closed ranges representing the line numbers that should be hidden
699:     func getFoldedLineRanges() -> [ClosedRange<Int>] {
700:         var ranges: [ClosedRange<Int>] = []
701:         
702:         // Sort regions by start line to ensure proper ordering
703:         let sortedRegions = foldRegions.sorted { $0.startLine < $1.startLine }
704:         
705:         for region in sortedRegions where region.isFolded {
706:             ranges.append((region.startLine + 1)...region.endLine)
707:         }
708:         
709:         return ranges
710:     }
711:     
712:     /// Gets the total count of folded lines
713:     func getFoldedLineCount() -> Int {
714:         return collapsedLines.count
715:     }
716:     
717:     /// Gets a summary of fold statistics
718:     func getFoldStatistics() -> FoldStatistics {
719:         let totalCount = foldRegions.count
720:         let foldedCount = foldRegions.filter { $0.isFolded }.count
721:         
722:         var typeBreakdown: [FoldRegion.FoldType: Int] = [:]
723:         for region in foldRegions {
724:             typeBreakdown[region.type, default: 0] += 1
725:         }
726:         
727:         return FoldStatistics(
728:             totalRegions: totalCount,
729:             foldedRegions: foldedCount,
730:             typeBreakdown: typeBreakdown
731:         )
732:     }
733:     
734:     // MARK: - Private Methods
735:     
736:     private func updateCollapsedLines() {
737:         collapsedLines.removeAll()
738:         
739:         for region in foldRegions where region.isFolded {
740:             for line in (region.startLine + 1)...region.endLine {
741:                 collapsedLines.insert(line)
742:             }
743:         }
744:     }
745: }
746: 
747: // MARK: - Fold Statistics
748: struct FoldStatistics {
749:     let totalRegions: Int
750:     let foldedRegions: Int
751:     let typeBreakdown: [FoldRegion.FoldType: Int]
752:     
753:     var expansionPercentage: Double {
754:         guard totalRegions > 0 else { return 0 }
755:         return Double(foldedCount) / Double(totalRegions) * 100
756:     }
757:     
758:     var foldedCount: Int {
759:         return foldedRegions
760:     }
761:     
762:     var expandedCount: Int {
763:         return totalRegions - foldedRegions
764:     }
765: }
766: 
767: // MARK: - Fold Button View
768: struct FoldButton: View {
769:     let line: Int
770:     let isExpanded: Bool
771:     let foldType: FoldRegion.FoldType?
772:     let action: () -> Void
773:     
774:     var body: some View {
775:         Button(action: action) {
776:             ZStack {
777:                 if let type = foldType {
778:                     Text(type.icon)
779:                         .font(.system(size: 8, weight: .bold))
780:                         .foregroundColor(.blue.opacity(0.6))
781:                 }
782:                 
783:                 Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
784:                     .font(.system(size: 10, weight: .semibold))
785:                     .foregroundColor(.primary.opacity(0.7))
786:             }
787:             .frame(width: 18, height: 18)
788:             .background(isExpanded ? Color.secondary.opacity(0.1) : Color.secondary.opacity(0.2))
789:             .cornerRadius(4)
790:         }
791:         .buttonStyle(PlainButtonStyle())
792:     }
793: }
794: 
795: // MARK: - Line Number View with Folding
796: struct LineNumberViewWithFolding: View {
797:     let lineNumber: Int
798:     let isFoldable: Bool
799:     let isExpanded: Bool
800:     let foldType: FoldRegion.FoldType?
801:     let onFoldTap: () -> Void
802:     
803:     var body: some View {
804:         HStack(spacing: 4) {
805:             if isFoldable {
806:                 FoldButton(
807:                     line: lineNumber,
808:                     isExpanded: isExpanded,
809:                     foldType: foldType,
810:                     action: onFoldTap
811:                 )
812:             } else {
813:                 Color.clear
814:                     .frame(width: 18, height: 18)
815:             }
816:             
817:             Text("\(lineNumber + 1)")
818:                 .font(.system(.caption, design: .monospaced))
819:                 .foregroundColor(.gray)
820:                 .frame(minWidth: 30, alignment: .trailing)
821:         }
822:     }
823: }
824: 


Now let me check the MinimapView.swift file:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift (lines 1-465 of 465)
────────────────────────────────────────
1: import SwiftUI
2: 
3: /// VS Code–style minimap with:
4: /// - syntax-colored tiny preview
5: /// - visible region overlay
6: /// - tap/drag to scroll
7: /// - optional git diff indicators (added/modified/deleted)
8: struct MinimapView: View {
9:     // MARK: - External inputs
10: 
11:     let content: String
12:     @Binding var scrollOffset: CGFloat
13:     @Binding var scrollViewHeight: CGFloat
14:     let totalContentHeight: CGFloat
15: 
16:     /// Optional indicators to render as thin bars on the left side of the minimap.
17:     /// Note: call sites can ignore this (default empty) without breaking compilation.
18:     var diffIndicators: [MinimapDiffIndicator] = []
19: 
20:     /// Fixed width; height expands to the container.
21:     var minimapWidth: CGFloat = 60
22: 
23:     // MARK: - Internal state
24: 
25:     @State private var isInteracting: Bool = false
26: 
27:     // MARK: - Types
28: 
29:     struct MinimapDiffIndicator: Identifiable, Hashable {
30:         enum Kind: Hashable {
31:             case added
32:             case modified
33:             case deleted
34:         }
35: 
36:         var id = UUID()
37:         /// 0-based line range in the current `content`.
38:         var lineRange: Range<Int>
39:         var kind: Kind
40: 
41:         init(lineRange: Range<Int>, kind: Kind) {
42:             self.lineRange = lineRange
43:             self.kind = kind
44:         }
45:     }
46: 
47:     // MARK: - View
48: 
49:     var body: some View {
50:         GeometryReader { geometry in
51:             let size = geometry.size
52:             let minimapHeight = max(1, size.height)
53:             let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
54:             let lineCount = max(lines.count, 1)
55: 
56:             ZStack(alignment: .topLeading) {
57:                 // Background
58:                 Rectangle()
59:                     .fill(Color(white: 0.13))
60: 
61:                 // Syntax-colored code preview
62:                 Canvas { context, canvasSize in
63:                     drawMinimapPreview(
64:                         in: &context,
65:                         size: canvasSize,
66:                         lines: lines
67:                     )
68:                 }
69:                 .allowsHitTesting(false)
70: 
71:                 // Git diff indicators (thin left bars)
72:                 diffIndicatorsLayer(
73:                     minimapHeight: minimapHeight,
74:                     lineCount: lineCount
75:                 )
76:                 .allowsHitTesting(false)
77: 
78:                 // Visible region highlight
79:                 visibleRegionLayer(minimapHeight: minimapHeight)
80:                     .allowsHitTesting(false)
81:             }
82:             .frame(width: minimapWidth, height: minimapHeight)
83:             .clipShape(Rectangle())
84:             .contentShape(Rectangle())
85:             // Click-to-scroll + drag scrolling (DragGesture(minDistance: 0) captures taps too)
86:             .gesture(
87:                 DragGesture(minimumDistance: 0, coordinateSpace: .local)
88:                     .onChanged { value in
89:                         isInteracting = true
90:                         updateScroll(forMinimapY: value.location.y, minimapHeight: minimapHeight)
91:                     }
92:                     .onEnded { _ in
93:                         isInteracting = false
94:                     }
95:             )
96:         }
97:         .frame(width: minimapWidth)
98:     }
99: 
100:     // MARK: - Layers
101: 
102:     @ViewBuilder
103:     private func visibleRegionLayer(minimapHeight: CGFloat) -> some View {
104:         let height = visibleRegionHeight(minimapHeight: minimapHeight)
105:         let offset = visibleRegionOffset(minimapHeight: minimapHeight, visibleHeight: height)
106: 
107:         Rectangle()
108:             .fill(Color.accentColor.opacity(isInteracting ? 0.22 : 0.16))
109:             .overlay(
110:                 Rectangle()
111:                     .stroke(Color.accentColor.opacity(0.65), lineWidth: 1)
112:             )
113:             .frame(width: minimapWidth, height: height)
114:             .offset(y: offset)
115:     }
116: 
117:     @ViewBuilder
118:     private func diffIndicatorsLayer(minimapHeight: CGFloat, lineCount: Int) -> some View {
119:         // VS Code minimap diff markers are thin and pinned to the left.
120:         let barWidth: CGFloat = 2
121: 
122:         ForEach(diffIndicators) { indicator in
123:             let startLine = max(0, min(indicator.lineRange.lowerBound, lineCount - 1))
124:             let endLineExclusive = max(startLine + 1, min(indicator.lineRange.upperBound, lineCount))
125: 
126:             let startY = (CGFloat(startLine) / CGFloat(lineCount)) * minimapHeight
127:             let endY = (CGFloat(endLineExclusive) / CGFloat(lineCount)) * minimapHeight
128:             let height = max(2, endY - startY)
129: 
130:             Rectangle()
131:                 .fill(diffColor(for: indicator.kind).opacity(0.95))
132:                 .frame(width: barWidth, height: height)
133:                 .offset(x: 0, y: startY)
134:         }
135:     }
136: 
137:     // MARK: - Visible region math
138: 
139:     private func visibleRegionHeight(minimapHeight: CGFloat) -> CGFloat {
140:         guard totalContentHeight > 0 else { return 0 }
141:         let ratio = scrollViewHeight / totalContentHeight
142:         return minimapHeight * min(max(ratio, 0), 1.0)
143:     }
144: 
145:     private func visibleRegionOffset(minimapHeight: CGFloat, visibleHeight: CGFloat) -> CGFloat {
146:         let scrollable = max(0, totalContentHeight - scrollViewHeight)
147:         guard scrollable > 0 else { return 0 }
148: 
149:         let scrollRatio = min(max(scrollOffset / scrollable, 0), 1.0)
150:         return scrollRatio * max(0, minimapHeight - visibleHeight)
151:     }
152: 
153:     // MARK: - Interaction
154: 
155:     /// Sets `scrollOffset` so that the main editor's visible region is centered around the minimap Y position.
156:     private func updateScroll(forMinimapY yPosition: CGFloat, minimapHeight: CGFloat) {
157:         guard totalContentHeight > 0 else { return }
158: 
159:         let clampedY = max(0, min(yPosition, minimapHeight))
160:         let ratio = (minimapHeight > 0) ? (clampedY / minimapHeight) : 0
161: 
162:         // Target a center position (VS Code behavior).
163:         let targetCenter = ratio * totalContentHeight
164:         let desiredOffset = targetCenter - (scrollViewHeight / 2)
165: 
166:         let maxOffset = max(0, totalContentHeight - scrollViewHeight)
167:         scrollOffset = min(max(desiredOffset, 0), maxOffset)
168:     }
169: 
170:     // MARK: - Rendering (Canvas)
171: 
172:     private func drawMinimapPreview(
173:         in context: inout GraphicsContext,
174:         size: CGSize,
175:         lines: [Substring]
176:     ) {
177:         let paddingX: CGFloat = 4
178:         let paddingY: CGFloat = 2
179: 
180:         let contentWidth = max(0, size.width - (paddingX * 2))
181:         let contentHeight = max(0, size.height - (paddingY * 2))
182: 
183:         guard contentWidth > 0, contentHeight > 0 else { return }
184: 
185:         let lineCount = max(lines.count, 1)
186:         let pixelsPerLine = contentHeight / CGFloat(lineCount)
187: 
188:         // If we're dense (lots of lines), switch to token-block rendering.
189:         // Otherwise, render actual tiny syntax-colored text.
190:         let useTextMode = pixelsPerLine >= 3.0
191: 
192:         if useTextMode {
193:             // Font is tiny; keep it stable rather than tied too tightly to pixelsPerLine.
194:             let fontSize: CGFloat = min(6, max(3.5, pixelsPerLine * 0.9))
195: 
196:             for i in 0..<lineCount {
197:                 let y = paddingY + (CGFloat(i) * pixelsPerLine)
198:                 if y > size.height { break }
199: 
200:                 let line = lines.indices.contains(i) ? lines[i] : Substring("")
201:                 let attributed = makeAttributedLine(from: line, fontSize: fontSize)
202: 
203:                 // Slightly dim to match minimap look.
204:                 let text = Text(attributed)
205: 
206:                 context.draw(
207:                     text,
208:                     at: CGPoint(x: paddingX, y: y),
209:                     anchor: .topLeading
210:                 )
211:             }
212:         } else {
213:             // Token-block mode (colored rectangles), closer to VS Code minimap blocks for long files.
214:             let minBarHeight: CGFloat = 1
215:             let barHeight = max(minBarHeight, pixelsPerLine)
216: 
217:             // Approximate "characters" across minimap width.
218:             let maxChars: CGFloat = 120
219:             let charWidth = contentWidth / maxChars
220: 
221:             for i in 0..<lineCount {
222:                 let y = paddingY + (CGFloat(i) * pixelsPerLine)
223:                 if y > size.height { break }
224: 
225:                 let line = lines.indices.contains(i) ? lines[i] : Substring("")
226:                 let tokens = tokenize(line)
227: 
228:                 var x = paddingX
229:                 let yAligned = y.rounded(.down)
230: 
231:                 if tokens.isEmpty {
232:                     // Render faint whitespace line.
233:                     let rect = CGRect(x: x, y: yAligned, width: max(4, contentWidth * 0.15), height: barHeight)
234:                     context.fill(Path(rect), with: .color(Color(white: 0.45).opacity(0.10)))
235:                     continue
236:                 }
237: 
238:                 for token in tokens {
239:                     guard x < (paddingX + contentWidth) else { break }
240:                     let w = max(1, CGFloat(token.text.count) * charWidth)
241:                     let rect = CGRect(x: x, y: yAligned, width: min(w, paddingX + contentWidth - x), height: barHeight)
242:                     context.fill(Path(rect), with: .color(token.color.opacity(0.80)))
243:                     x += w
244:                 }
245:             }
246:         }
247:     }
248: 
249:     // MARK: - Syntax highlighting (lightweight)
250: 
251:     private struct Token {
252:         enum Kind {
253:             case plain
254:             case keyword
255:             case string
256:             case comment
257:             case number
258:             case typeName
259:         }
260: 
261:         var text: Substring
262:         var kind: Kind
263: 
264:         var color: Color {
265:             switch kind {
266:             case .plain:
267:                 return Color(white: 0.70)
268:             case .keyword:
269:                 return Color(red: 0.78, green: 0.53, blue: 0.95) // purple-ish
270:             case .string:
271:                 return Color(red: 0.80, green: 0.72, blue: 0.43) // yellow-ish
272:             case .comment:
273:                 return Color(red: 0.46, green: 0.60, blue: 0.50) // green-ish
274:             case .number:
275:                 return Color(red: 0.40, green: 0.73, blue: 0.92) // blue-ish
276:             case .typeName:
277:                 return Color(red: 0.45, green: 0.83, blue: 0.70) // teal-ish
278:             }
279:         }
280:     }
281: 
282:     private func makeAttributedLine(from line: Substring, fontSize: CGFloat) -> AttributedString {
283:         let tokens = tokenize(line)
284: 
285:         var out = AttributedString()
286:         for token in tokens {
287:             var chunk = AttributedString(String(token.text))
288:             chunk.font = .system(size: fontSize, weight: .regular, design: .monospaced)
289:             chunk.foregroundColor = token.color
290:             out.append(chunk)
291:         }
292: 
293:         if out.characters.isEmpty {
294:             // Preserve a tiny amount of "whitespace presence" so empty lines still show.
295:             var chunk = AttributedString(" ")
296:             chunk.font = .system(size: fontSize, weight: .regular, design: .monospaced)
297:             chunk.foregroundColor = Color(white: 0.7).opacity(0.25)
298:             out.append(chunk)
299:         }
300: 
301:         return out
302:     }
303: 
304:     private func tokenize(_ line: Substring) -> [Token] {
305:         // Extremely lightweight tokenizer:
306:         // - full-line comment if first non-space is # (python-like)
307:         // - inline comment starting at //
308:         // - strings in "..." or '...'
309:         // - numbers
310:         // - keywords
311:         // - PascalCase tokens treated as type names
312:         var tokens: [Token] = []
313:         var i = line.startIndex
314: 
315:         func peek(_ offset: Int = 0) -> Character? {
316:             var idx = i
317:             for _ in 0..<offset {
318:                 guard idx < line.endIndex else { return nil }
319:                 idx = line.index(after: idx)
320:             }
321:             return idx < line.endIndex ? line[idx] : nil
322:         }
323: 
324:         func advance(_ n: Int = 1) {
325:             for _ in 0..<n {
326:                 guard i < line.endIndex else { return }
327:                 i = line.index(after: i)
328:             }
329:         }
330: 
331:         // Detect python/shebang-like comment lines: first non-whitespace is '#'
332:         if let firstNonSpace = line.firstIndex(where: { !$0.isWhitespace }),
333:            line[firstNonSpace] == "#" {
334:             tokens.append(Token(text: line[line.startIndex..<line.endIndex], kind: .comment))
335:             return tokens
336:         }
337: 
338:         while i < line.endIndex {
339:             let ch = line[i]
340: 
341:             // Inline comment: //
342:             if ch == "/", peek(1) == "/" {
343:                 let range = i..<line.endIndex
344:                 tokens.append(Token(text: line[range], kind: .comment))
345:                 return tokens
346:             }
347: 
348:             // Whitespace
349:             if ch.isWhitespace {
350:                 let start = i
351:                 while i < line.endIndex, line[i].isWhitespace { advance() }
352:                 tokens.append(Token(text: line[start..<i], kind: .plain))
353:                 continue
354:             }
355: 
356:             // String literals
357:             if ch == "\"" || ch == "'" {
358:                 let quote = ch
359:                 let start = i
360:                 advance()
361:                 var escaped = false
362:                 while i < line.endIndex {
363:                     let c = line[i]
364:                     if escaped {
365:                         escaped = false
366:                         advance()
367:                         continue
368:                     }
369:                     if c == "\\" {
370:                         escaped = true
371:                         advance()
372:                         continue
373:                     }
374:                     if c == quote {
375:                         advance()
376:                         break
377:                     }
378:                     advance()
379:                 }
380:                 tokens.append(Token(text: line[start..<i], kind: .string))
381:                 continue
382:             }
383: 
384:             // Numbers
385:             if ch.isNumber {
386:                 let start = i
387:                 while i < line.endIndex, line[i].isNumber || line[i] == "." { advance() }
388:                 tokens.append(Token(text: line[start..<i], kind: .number))
389:                 continue
390:             }
391: 
392:             // Identifiers / keywords
393:             if ch.isLetter || ch == "_" {
394:                 let start = i
395:                 advance()
396:                 while i < line.endIndex {
397:                     let c = line[i]
398:                     if c.isLetter || c.isNumber || c == "_" { advance() } else { break }
399:                 }
400:                 let word = line[start..<i]
401:                 let kind: Token.Kind
402: 
403:                 if isKeyword(word) {
404:                     kind = .keyword
405:                 } else if looksLikeTypeName(word) {
406:                     kind = .typeName
407:                 } else {
408:                     kind = .plain
409:                 }
410: 
411:                 tokens.append(Token(text: word, kind: kind))
412:                 continue
413:             }
414: 
415:             // Operators / punctuation
416:             let start = i
417:             advance()
418:             tokens.append(Token(text: line[start..<i], kind: .plain))
419:         }
420: 
421:         return tokens
422:     }
423: 
424:     private func isKeyword(_ word: Substring) -> Bool {
425:         // Small superset of common Swift/JS/Python keywords.
426:         // (We can't depend on a full parser here.)
427:         let keywords: Set<String> = [
428:             "import", "export", "from", "as",
429:             "struct", "class", "enum", "protocol", "extension", "func", "var", "let",
430:             "if", "else", "for", "while", "repeat", "switch", "case", "default",
431:             "break", "continue", "return", "throw", "throws", "try", "catch",
432:             "do", "in", "where", "guard", "defer",
433:             "public", "private", "fileprivate", "internal", "open",
434:             "static", "final", "override", "mutating", "nonmutating",
435:             "async", "await",
436:             "true", "false", "nil",
437:             "self", "super",
438:             // JS/Python-ish
439:             "const", "function", "async", "await", "new", "this",
440:             "def", "pass", "lambda", "None"
441:         ]
442:         return keywords.contains(String(word))
443:     }
444: 
445:     private func looksLikeTypeName(_ word: Substring) -> Bool {
446:         // Simple heuristic: PascalCase (leading uppercase).
447:         guard let first = word.first else { return false }
448:         return first.isUppercase
449:     }
450: 
451:     // MARK: - Diff colors
452: 
453:     private func diffColor(for kind: MinimapDiffIndicator.Kind) -> Color {
454:         switch kind {
455:         case .added:
456:             return Color.green
457:         case .modified:
458:             return Color.red
459:         case .deleted:
460:             // VS Code uses red-ish for deletions too; keep distinct via slightly different tone.
461:             return Color(red: 1.0, green: 0.35, blue: 0.35)
462:         }
463:     }
464: }
465: 


>>>REPORT
# EDITOR FEATURES AUDIT REPORT

## 1. SyntaxHighlightingTextView.swift - **FULLY WIRED** ✓

**Evidence:** Lines 991-1749
- **26+ languages fully implemented** with dedicated highlighting functions:
  - Swift (1196-1235), JavaScript/TypeScript/JSX/TSX (1237-1273)
  - Python (1275-1311), HTML/XML (1313-1333), CSS/SCSS/Less (1335-1362)
  - JSON (1364-1380), Markdown (1382-1408), Rust (1410-1437)
  - Go (1439-1458), Java/Kotlin (1460-1484), C/C++/ObjC (1486-1512)
  - Ruby (1514-1538), PHP (1540-1561), Shell/Dockerfile (1563-1579)
  - YAML/ENV (1581-1595), SQL (1597-1624), GraphQL (1626-1655)
- Each language has: keywords, types, strings, comments, numbers, and language-specific patterns
- Includes bracket pair colorization (1133-1194)

## 2. MultiCursorTextView.swift - **PARTIALLY WIRED** ⚠️

**Evidence:** Lines 217-231
- ✓ **Cmd+D** (Add next occurrence): Lines 217-223, implemented, calls `addNextOccurrence()`
- ✓ **Cmd+Shift+L** (Select all occurrences): Lines 225-231, implemented, calls `selectAllOccurrences()`
- ✗ **Option+Click**: NOT IMPLEMENTED - No gesture recognizer or click handler found for mouse/touch-based multi-cursor creation
- ✓ Multi-cursor text editing works: Lines 134-184 (insertText, deleteBackward)
- ✓ Cursor rendering: Lines 64-130

## 3. CodeFoldingManager.swift - **MOSTLY WIRED** ⚠️

**Evidence:** Lines 1-824
- ✓ **Fold detection**: FULLY IMPLEMENTED (lines 80-244)
  - Functions, classes, structs, enums, protocols, extensions
  - Control flow (if, for, while, switch)
  - Comments (single-line, multi-line), Import blocks
  - Region markers (#region, MARK:, TODO:, FIXME:)
- ✓ **UI components**: Lines 768-823
  - FoldButton with expand/collapse icons
  - LineNumberViewWithFolding with interactive buttons
- ✓ **Persistence**: Lines 459-517 (UserDefaults save/restore)
- ⚠️ **STUB METHODS**: Lines 571-580
  - `foldCurrentLine()`: "stub - requires cursor position from editor"
  - `unfoldCurrentLine()`: "stub - requires cursor position from editor"
  - These are currently no-ops

## 4. MinimapView.swift - **FULLY WIRED** ✓

**Evidence:** Lines 1-465
- ✓ **Rendering**: Lines 172-247
  - Syntax-colored code preview with Canvas
  - Two modes: text mode (≥3px/line) and token-block mode (dense files)
  - Lightweight tokenizer for keywords, strings, comments, numbers
- ✓ **Visible region overlay**: Lines 102-115 (shows current viewport)
- ✓ **Click-to-scroll**: Lines 86-95
  - DragGesture with minDistance 0 captures taps
  - `updateScroll()` calculates offset based on minimap position
- ✓ **Git diff indicators**: Lines 117-135 (optional thin colored bars)

---
**SUMMARY:**
- Fully Wired: 2/4 (SyntaxHighlighting, Minimap)
- Partially/Mostly Wired: 2/4 (MultiCursor missing Option+Click, CodeFolding has stub cursor methods)
>>>END
