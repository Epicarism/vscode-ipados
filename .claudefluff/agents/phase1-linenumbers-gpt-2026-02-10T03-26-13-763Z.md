# Agent: phase1-linenumbers-gpt
**Status:** done
**Tokens:** 132,945
**Cost:** $0.0000
**Time:** 2026-02-10T03:26:13.763Z

## Task
Verify line numbers in VSCodeiPadOS. Check how line numbers are rendered - likely in SyntaxHighlightingTextView or a separate LineNumberView. Ensure numbers stay aligned with text, update on scroll, clickable to select line. Fix bugs. BUILD AFTER.

## Response
>>>TOOL list_dir
{"path":"/Users/danielswagg/PLAYGROUND/vscode-ipados"}
>>>END>>>END>>>TOOL list_dir
{"path":"/Users/danielswagg/PLAYGROUND/vscode-ipados"}
>>>END>>>END>>>TOOL list_dir
{"path":"/Users/danielswagg/PLAYGROUND/vscode-ipados"}
>>>END>>>TOOL list_dir
{"path":"/Users/danielswagg/PLAYGROUND/vscode-ipados"}
>>>END

>>>TOOL list_dir
{}
>>>END>>>TOOL list_dir
{}
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


>>>TOOL search
{"query":"LineNumber", "glob":"**/*"}
>>>END

>>>TOOL search
{"query":"SyntaxHighlightingTextView", "glob":"**/*"}
>>>END

>>>TOOL search
{"query":"line numbers", "glob":"**/*"}
>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 30 matches:
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SplitEditorView.swift.2026-02-09T11-05-52-391Z.bak:493: @State private var currentLineNumber: Int = 1
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SplitEditorView.swift.2026-02-09T11-05-52-391Z.bak:525: .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SplitEditorView.swift.2026-02-09T11-05-52-391Z.bak:545: currentLineNumber: $currentLineNumber,
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Services_CodeFoldingManager.swift.2026-02-09T16-25-24-473Z.bak:773: struct LineNumberViewWithFolding: View {
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:351: @State private var currentLineNumber: Int = 1
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:367: LineNumbersWithFolding(
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:369: currentLine: currentLineNumber,
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:384: currentLineNumber: $currentLineNumber,
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:391: editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:413: .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:425: .onChange(of: currentLineNumber) { line in
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:429: editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-38-53-957Z.bak:441: struct LineNumbersWithFolding: View {
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:309: enum LineNumberMode: String, CaseIterable {
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:332: @State private var currentLineNumber: Int = 1
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:335: @State private var lineNumberMode: LineNumberMode = .absolute
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:336: @State private var showLineNumberMenu = false
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:379: LineNumbersWithFolding(
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:382: currentLine: currentLineNumber,
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:391: showLineNumberMenu = true
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:405: currentLineNumber: $currentLineNumber,
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:413: editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:439: .offset(x: lineNumberMode != .off ? (lineNumberMode == .relative ? 80 : 70) : 10, y: CGFloat(currentLineNumber) * lineHeight)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:443: if showLineNumberMenu {
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:447: showLineNumberMenu = false
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:450: LineNumberModeMenu(
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:452: onDismiss: { showLineNumberMenu = false }
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:469: .onChange(of: currentLineNumber) { line in
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:474: editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_ContentView.swift.2026-02-09T10-46-48-303Z.bak:513: struct LineNumberModeMenu: View {

---

[search]
Found 30 matches:
FULL_FEATURE_TEST_PLAN.md:47: ## 2. SYNTAX HIGHLIGHTING (SyntaxHighlightingTextView.swift - 1503 lines)
Docs/GITFUTURE.md:693: | git-gutter-2 | Integrate gutter with editor | Views/Editor/SyntaxHighlightingTextView.swift |
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:8: Implement FEAT-048 Tab to accept suggestion + FEAT-049 Escape to dismiss autocomplete. Must wire into existing editor views (SyntaxHighlightingTextView / MultiCursorTextView / ContentView IDEEditorView). Use gpt52 for autocomplete logic.
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:17: {"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":500}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:23: {"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":500}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:28: {"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":140}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:54: {"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":260}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:58: {"query":"editorCore", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:63: {"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":40}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:84: {"query":"SyntaxHighlightingTextView(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:142: {"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":25}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:198: {"query":"SyntaxHighlightingTextView(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:286: {"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":980}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:346: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:348: struct SyntaxHighlightingTextView: UIViewRepresentable {
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:361: struct SyntaxHighlightingTextView: UIViewRepresentable {
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:381: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:442: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:471: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:508: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:520: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:539: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:589: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:638: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:654: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:680: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:692: >>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:739: {"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":8,"end_line":90}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:743: {"query":"self._requestedCursorIndex", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:747: {"query":"self.parent.currentColumn", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}

---

[search]
Found 10 matches:
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SyntaxHighlightingTextView.swift.2026-02-09T11-29-06-918Z.bak:170: // Handle line selection requests (e.g. tapping line numbers)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SyntaxHighlightingTextView.swift.2026-02-09T11-05-29-681Z.bak:125: // Handle line selection requests (e.g. tapping line numbers)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Services_CodeFoldingManager.swift.2026-02-09T16-25-24-473Z.bak:675: /// Returns an array of closed ranges representing the line numbers that should be hidden
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SyntaxHighlightingTextView.swift.2026-02-09T11-15-56-148Z.bak:161: // Handle line selection requests (e.g. tapping line numbers)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SyntaxHighlightingTextView.swift.2026-02-09T11-15-54-100Z.bak:149: // Handle line selection requests (e.g. tapping line numbers)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SyntaxHighlightingTextView.swift.2026-02-09T23-16-41-859Z.bak:231: // Handle line selection requests (e.g. tapping line numbers)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SyntaxHighlightingTextView.swift.2026-02-09T11-34-04-060Z.bak:206: // Handle line selection requests (e.g. tapping line numbers)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SyntaxHighlightingTextView.swift.2026-02-09T20-55-55-038Z.bak:231: // Handle line selection requests (e.g. tapping line numbers)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SyntaxHighlightingTextView.swift.2026-02-09T11-15-14-719Z.bak:129: // Handle line selection requests (e.g. tapping line numbers)
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Views_Editor_SplitEditorView.swift.2026-02-09T11-55-24-150Z.bak:589: .padding(.leading, 54) // Offset for line numbers




>>>TOOL search
{"query":"LineNumber", "glob":"**/*"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 30 matches:
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:354: @Binding var currentLineNumber: Int
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:367: @Binding var currentLineNumber: Int
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:389: currentLineNumber: Binding<Int>,
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:401: self._currentLineNumber = currentLineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:415: currentLineNumber: Binding<Int>,
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:430: self._currentLineNumber = currentLineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:640: @Binding var currentLineNumber: Int
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:646: @Binding var currentLineNumber: Int
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:656: currentLineNumber: Binding<Int>,
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:667: currentLineNumber: Binding<Int>,
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:682: self._currentLineNumber = currentLineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:686: self._currentLineNumber = currentLineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:704: self.parent.currentLineNumber = lineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:718: self.parent.currentLineNumber = lineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:791: self.parent.currentLineNumber = lineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:808: self.parent.currentLineNumber = lineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:825: @State private var currentLineNumber: Int = 1
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:843: @State private var currentLineNumber: Int = 1
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:864: currentLineNumber: $currentLineNumber,
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:871: editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:883: currentLineNumber: $currentLineNumber,
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:910: editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:929: .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:945: .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:1112: currentLineNumber: Binding<Int>,
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:1128: self._currentLineNumber = currentLineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:1146: currentLineNumber: Binding<Int>,
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:1161: self._currentLineNumber = currentLineNumber
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:1263: currentLineNumber: Binding<Int>,
.claudefluff/agents/worker-autocomplete-keys-2026-02-09T11-35-27-953Z.md:1280: currentLineNumber: Binding<Int>,


>>>TOOL search
{"query":"SyntaxHighlightingTextView", "glob":"**/*.swift"}
>>>END

>>>TOOL search
{"query":"LineNumber", "glob":"**/*.swift"}
>>>END

>>>TOOL search
{"query":"gutter", "glob":"**/*.swift"}
>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 7 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:452: SyntaxHighlightingTextView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:544: SyntaxHighlightingTextView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:2: //  SyntaxHighlightingTextView.swift
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:12: struct SyntaxHighlightingTextView: UIViewRepresentable {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:289: var parent: SyntaxHighlightingTextView
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:309: init(_ parent: SyntaxHighlightingTextView) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:566: SyntaxHighlightingTextView(

---

[search]
Found 30 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:406: @State private var currentLineNumber: Int = 1
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:432: LineNumbersWithFolding(
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:435: currentLine: currentLineNumber,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:458: currentLineNumber: $currentLineNumber,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:489: editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:548: .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:561: .onChange(of: currentLineNumber) { line in
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:565: editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:577: struct LineNumbersWithFolding: View {
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:16: let oldLineNumber: Int?
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:17: let newLineNumber: Int?
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:65: Text(line.oldLineNumber.map(String.init) ?? "")
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:68: Text(line.newLineNumber.map(String.init) ?? "")
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:124: Text(line.oldLineNumber.map(String.init) ?? "")
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:147: Text(line.newLineNumber.map(String.init) ?? "")
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:202: DiffLine(type: .context, content: "import SwiftUI", oldLineNumber: 1, newLineNumber: 1),
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:203: DiffLine(type: .deletion, content: "struct OldView: View {", oldLineNumber: 2, newLineNumber: nil),
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:204: DiffLine(type: .addition, content: "struct NewView: View {", oldLineNumber: nil, newLineNumber: 2),
VSCodeiPadOS/VSCodeiPadOS/Views/DiffComponents.swift:205: DiffLine(type: .context, content: "    var body: some View {", oldLineNumber: 3, newLineNumber: 3)
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:838: struct LineNumberViewWithFolding: View {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:494: @State private var currentLineNumber: Int = 1
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:548: .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:572: currentLineNumber: $currentLineNumber,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:657: if lineNumber == currentLineNumber { return "\(lineNumber)" }
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:658: return "\(abs(lineNumber - currentLineNumber))"
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SettingsView.swift:86: @AppStorage("showLineNumbers") private var showLineNumbers: Bool = true
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SettingsView.swift:137: showLineNumbers = (newValue != "off")
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:498: @State private var currentLineNumber: Int = 1
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:530: .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:550: currentLineNumber: $currentLineNumber,

---

[search]
Found 20 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:8: /// for the Debug sidebar and breakpoint gutter markers.
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:507: // Line numbers + breakpoints (gutter)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:509: // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:32: /// Width reserved for the gutter (line numbers)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:33: var gutterWidth: CGFloat = 60
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:114: // Calculate starting X position (gutter + insets + character offset)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:115: startX = gutterWidth + textInsets.left + (CGFloat(visualColumn) * charWidth)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:129: let xOffset: CGFloat = index == 0 ? startX : gutterWidth + textInsets.left
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/GitGutterView.swift:4: // MARK: - FEAT-071 Git gutter indicators + FEAT-072 Inline blame
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/GitGutterView.swift:7: // - FEAT-071: Git gutter indicators (added/modified/deleted)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/GitGutterView.swift:113: public var gutterWidth: CGFloat = 6
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/GitGutterView.swift:114: public var gutterCornerRadius: CGFloat = 1
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/GitGutterView.swift:169: .frame(width: configuration.gutterWidth)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/GitGutterView.swift:193: let corner = configuration.gutterCornerRadius
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/GitGutterView.swift:216: .accessibilityLabel("Git diff gutter")
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:17: /// Width reserved for the gutter (line numbers).
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:18: var gutterWidth: CGFloat = 60
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:47: let x = gutterWidth + textInsets.left + (CGFloat(visualColumn) * charWidth)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:506: // Line numbers + breakpoints + code folding (gutter)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:508: // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":450,"end_line":760}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift","start_line":470,"end_line":620}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":420}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 451-760 of 774)
────────────────────────────────────────
451:             RoundedRectangle(cornerRadius: 4)
452:                 .fill(isSelected ? Color(UIColor.systemBackground) : Color.clear)
453:         )
454:         .opacity(isDragging ? 0.5 : 1.0)
455:         .onTapGesture {
456:             pane.selectTab(id: tab.id)
457:             splitManager.activePaneId = pane.id
458:         }
459:         .onDrag {
460:             isDragging = true
461:             return NSItemProvider(object: tab.id.uuidString as NSString)
462:         }
463:         .contextMenu {
464:             Button(action: { pane.closeTab(id: tab.id) }) {
465:                 Label("Close", systemImage: "xmark")
466:             }
467:             
468:             Divider()
469:             
470:             Button(action: { splitManager.moveTabToNewSplit(tab: tab, fromPaneId: pane.id, direction: .horizontal) }) {
471:                 Label("Move to Split Right", systemImage: "rectangle.split.2x1")
472:             }
473:             
474:             Button(action: { splitManager.moveTabToNewSplit(tab: tab, fromPaneId: pane.id, direction: .vertical) }) {
475:                 Label("Move to Split Down", systemImage: "rectangle.split.1x2")
476:             }
477:         }
478:     }
479: }
480: 
481: // MARK: - Pane Editor View
482: 
483: struct PaneEditorView: View {
484:     @ObservedObject var pane: EditorPane
485:     let tab: Tab
486:     @ObservedObject var splitManager: SplitEditorManager
487:     @ObservedObject var editorCore: EditorCore
488:     @ObservedObject private var debugManager = DebugManager.shared
489:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
490:     @State private var text: String = ""
491:     @State private var scrollPosition: Int = 0
492:     @State private var totalLines: Int = 1
493:     @State private var visibleLines: Int = 20
494:     @State private var currentLineNumber: Int = 1
495:     @State private var currentColumn: Int = 1
496:     @State private var lineHeight: CGFloat = 17
497:     @State private var requestedLineSelection: Int? = nil
498: 
499:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
500:     
501:     private var fileId: String { tab.url?.path ?? tab.fileName }
502:     
503:     var body: some View {
504:         GeometryReader { geometry in
505:             HStack(spacing: 0) {
506:                 // Line numbers + breakpoints + code folding (gutter)
507:                 //
508:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
509:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
510:                 if lineNumbersStyle != "off" {
511:                     ScrollView(showsIndicators: false) {
512:                         VStack(alignment: .trailing, spacing: 0) {
513:                             ForEach(0..<totalLines, id: \ .self) { lineIndex in
514:                                 HStack(spacing: 2) {
515:                                     // Fold chevron icon
516:                                     if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
517:                                         Button(action: { 
518:                                             foldingManager.toggleFold(fileId: fileId, line: lineIndex)
519:                                         }) {
520:                                             Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")
521:                                                 .font(.system(size: 10, weight: .regular))
522:                                                 .foregroundColor(.secondary.opacity(0.8))
523:                                                 .frame(width: 12, height: lineHeight)
524:                                         }
525:                                         .buttonStyle(.plain)
526:                                     } else {
527:                                         // Spacer for alignment
528:                                         Spacer()
529:                                             .frame(width: 12)
530:                                     }
531:                                     
532:                                     // Breakpoint indicator
533:                                     Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
534:                                         Circle()
535:                                             .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
536:                                             .overlay(
537:                                                 Circle()
538:                                                     .stroke(Color.red.opacity(0.6), lineWidth: 1)
539:                                                     .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
540:                                             )
541:                                             .frame(width: 10, height: 10)
542:                                     }
543:                                     .buttonStyle(.plain)
544:                                     .frame(width: 14, height: lineHeight)
545: 
546:                                     Text(displayText(for: lineIndex))
547:                                         .font(.system(size: 12, design: .monospaced))
548:                                         .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
549:                                         .frame(height: lineHeight)
550:                                         .contentShape(Rectangle())
551:                                         .onTapGesture {
552:                                             requestedLineSelection = lineIndex
553:                                         }
554:                                 }
555:                                 .frame(maxWidth: .infinity, alignment: .trailing)
556:                             }
557:                         }
558:                         .padding(.trailing, 4)
559:                         .offset(y: -CGFloat(scrollPosition) * lineHeight)
560:                     }
561:                     .frame(width: 70)
562:                     .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
563:                 }
564: 
565:                 // Editor
566:                 SyntaxHighlightingTextView(
567:                     text: $text,
568:                     filename: tab.fileName,
569:                     scrollPosition: $scrollPosition,
570:                     totalLines: $totalLines,
571:                     visibleLines: $visibleLines,
572:                     currentLineNumber: $currentLineNumber,
573:                     currentColumn: $currentColumn,
574:                     lineHeight: $lineHeight,
575:                     isActive: splitManager.activePaneId == pane.id,
576:                     editorCore: editorCore,
577:                     requestedLineSelection: $requestedLineSelection
578:                 )
579:                 .onChange(of: text) { newValue in
580:                     pane.updateTabContent(newValue)
581:                     
582:                     // Sync scroll if enabled
583:                     if splitManager.syncScroll {
584:                         splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
585:                     }
586:                 }
587:                 
588:                 // Mini minimap
589:                 MinimapView(
590:                     content: text,
591:                     scrollOffset: CGFloat(scrollPosition) * lineHeight,
592:                     scrollViewHeight: geometry.size.height,
593:                     totalContentHeight: CGFloat(totalLines) * lineHeight
594:                 )
595:                 .frame(width: 60)
596:             }
597:             // Sticky Header Overlay (FEAT-040)
598:             StickyHeaderView(
599:                 text: text,
600:                 currentLine: scrollPosition, // Using scrollPosition as approximate top line
601:                 theme: ThemeManager.shared.currentTheme,
602:                 lineHeight: lineHeight,
603:                 onSelect: { line in
604:                     requestedLineSelection = line
605:                 }
606:             )
607:             .padding(.leading, 70) // Offset for line numbers + folding icons
608:             .padding(.trailing, 60) // Offset for minimap
609:             
610:             // Peek Definition Overlay
611:             if let peekState = editorCore.peekState, editorCore.activeTabId == tab.id {
612:                  // Calculate simplified position: center of screen for now, but conceptually "inline"
613:                  // To make it truly inline, we'd need more complex geometry, but overlay is a good start.
614:                  VStack {
615:                      Spacer()
616:                          .frame(height: max(0, CGFloat(peekState.sourceLine - scrollPosition) * lineHeight + lineHeight + 20))
617:                      
618:                      PeekDefinitionView(
619:                          editorCore: editorCore,
620:                          targetFile: peekState.file,
621:                          targetLine: peekState.line,
622:                          content: peekState.content,
623:                          onClose: { editorCore.closePeekDefinition() },
624:                          onOpen: {
625:                              editorCore.openFile(FileItem(name: URL(fileURLWithPath: peekState.file).lastPathComponent, path: peekState.file, isDirectory: false))
626:                              editorCore.closePeekDefinition()
627:                          }
628:                      )
629:                      .padding(.horizontal)
630:                      .padding(.bottom, 20)
631:                      
632:                      Spacer()
633:                  }
634:                  .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
635:                  .background(Color.black.opacity(0.01)) // Capture taps outside if needed, or let them pass
636:                  .transition(.opacity)
637:                  .zIndex(100)
638:             }
639:         }
640:         .onAppear {
641:             text = tab.content
642:         }
643:         .onChange(of: tab.id) { _ in
644:             text = tab.content
645:         }
646:         .onChange(of: pane.scrollOffset) { newOffset in
647:             if splitManager.syncScroll {
648:                 scrollPosition = Int(newOffset / lineHeight)
649:             }
650:         }
651:     }
652:     
653:     private func displayText(for lineIndex: Int) -> String {
654:         switch lineNumbersStyle {
655:         case "relative":
656:             let lineNumber = lineIndex + 1
657:             if lineNumber == currentLineNumber { return "\(lineNumber)" }
658:             return "\(abs(lineNumber - currentLineNumber))"
659:         case "interval":
660:             let lineNumber = lineIndex + 1
661:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
662:         default:
663:             return "\(lineIndex + 1)"
664:         }
665:     }
666: }
667: 
668: // MARK: - Split Drag Handle
669: 
670: struct SplitDragHandle: View {
671:     let direction: SplitDirection
672:     let onDrag: (CGFloat) -> Void
673:     
674:     @State private var isDragging = false
675:     @GestureState private var dragOffset: CGFloat = 0
676:     
677:     var body: some View {
678:         ZStack {
679:             // Background
680:             Rectangle()
681:                 .fill(Color(UIColor.separator))
682:             
683:             // Handle indicator
684:             if direction == .horizontal {
685:                 VStack(spacing: 2) {
686:                     ForEach(0..<3, id: \.self) { _ in
687:                         Circle()
688:                             .fill(isDragging ? Color.accentColor : Color.secondary)
689:                             .frame(width: 3, height: 3)
690:                     }
691:                 }
692:             } else {
693:                 HStack(spacing: 2) {
694:                     ForEach(0..<3, id: \.self) { _ in
695:                         Circle()
696:                             .fill(isDragging ? Color.accentColor : Color.secondary)
697:                             .frame(width: 3, height: 3)
698:                     }
699:                 }
700:             }
701:         }
702:         .frame(
703:             width: direction == .horizontal ? 6 : nil,
704:             height: direction == .vertical ? 6 : nil
705:         )
706:         .contentShape(Rectangle())
707:         .gesture(
708:             DragGesture()
709:                 .updating($dragOffset) { value, state, _ in
710:                     let delta = direction == .horizontal ? value.translation.width : value.translation.height
711:                     state = delta
712:                 }
713:                 .onChanged { value in
714:                     isDragging = true
715:                     let delta = direction == .horizontal ? value.translation.width : value.translation.height
716:                     onDrag(delta)
717:                 }
718:                 .onEnded { _ in
719:                     isDragging = false
720:                 }
721:         )
722:         .onHover { hovering in
723:             if hovering {
724:                 #if targetEnvironment(macCatalyst)
725:                 NSCursor.resizeLeftRight.push()
726:                 #endif
727:             } else {
728:                 #if targetEnvironment(macCatalyst)
729:                 NSCursor.pop()
730:                 #endif
731:             }
732:         }
733:     }
734: }
735: 
736: // MARK: - Split Action Buttons (for toolbar/menu)
737: 
738: struct SplitEditorButtons: View {
739:     @ObservedObject var splitManager: SplitEditorManager
740:     
741:     var body: some View {
742:         HStack(spacing: 4) {
743:             Button(action: { splitManager.splitPane(direction: .horizontal) }) {
744:                 Image(systemName: "rectangle.split.2x1")
745:                     .font(.caption)
746:             }
747:             .help("Split Editor Right")
748:             
749:             Button(action: { splitManager.splitPane(direction: .vertical) }) {
750:                 Image(systemName: "rectangle.split.1x2")
751:                     .font(.caption)
752:             }
753:             .help("Split Editor Down")
754:             
755:             Toggle(isOn: $splitManager.syncScroll) {
756:                 Image(systemName: "arrow.up.arrow.down")
757:                     .font(.caption)
758:             }
759:             .toggleStyle(.button)
760:             .help("Sync Scroll")

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift (lines 471-620 of 708)
────────────────────────────────────────
471:             }
472:             
473:             Divider()
474:             
475:             Button(action: { splitManager.moveTabToNewSplit(tab: tab, fromPaneId: pane.id, direction: .horizontal) }) {
476:                 Label("Move to Split Right", systemImage: "rectangle.split.2x1")
477:             }
478:             
479:             Button(action: { splitManager.moveTabToNewSplit(tab: tab, fromPaneId: pane.id, direction: .vertical) }) {
480:                 Label("Move to Split Down", systemImage: "rectangle.split.1x2")
481:             }
482:         }
483:     }
484: }
485: 
486: // MARK: - Pane Editor View
487: 
488: struct PaneEditorView: View {
489:     @ObservedObject var pane: EditorPane
490:     let tab: Tab
491:     @ObservedObject var splitManager: SplitEditorManager
492:     @ObservedObject var editorCore: EditorCore
493:     @ObservedObject private var debugManager = DebugManager.shared
494:     @State private var text: String = ""
495:     @State private var scrollPosition: Int = 0
496:     @State private var totalLines: Int = 1
497:     @State private var visibleLines: Int = 20
498:     @State private var currentLineNumber: Int = 1
499:     @State private var currentColumn: Int = 1
500:     @State private var lineHeight: CGFloat = 17
501:     
502:     private var fileId: String { tab.url?.path ?? tab.fileName }
503:     
504:     var body: some View {
505:         GeometryReader { geometry in
506:             HStack(spacing: 0) {
507:                 // Line numbers + breakpoints (gutter)
508:                 //
509:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
510:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
511:                 ScrollView(showsIndicators: false) {
512:                     VStack(alignment: .trailing, spacing: 0) {
513:                         ForEach(0..<totalLines, id: \.self) { lineIndex in
514:                             HStack(spacing: 4) {
515:                                 Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
516:                                     Circle()
517:                                         .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
518:                                         .overlay(
519:                                             Circle()
520:                                                 .stroke(Color.red.opacity(0.6), lineWidth: 1)
521:                                                 .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
522:                                         )
523:                                         .frame(width: 10, height: 10)
524:                                 }
525:                                 .buttonStyle(.plain)
526:                                 .frame(width: 14, height: lineHeight)
527:                                 
528:                                 Text("\(lineIndex + 1)")
529:                                     .font(.system(size: 12, design: .monospaced))
530:                                     .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
531:                                     .frame(height: lineHeight)
532:                             }
533:                             .frame(maxWidth: .infinity, alignment: .trailing)
534:                         }
535:                     }
536:                     .padding(.trailing, 4)
537:                     .offset(y: -CGFloat(scrollPosition) * lineHeight)
538:                 }
539:                 .scrollDisabled(true)
540:                 .frame(width: 54)
541:                 .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
542:                 
543:                 // Editor
544:                 SyntaxHighlightingTextView(
545:                     text: $text,
546:                     filename: tab.fileName,
547:                     scrollPosition: $scrollPosition,
548:                     totalLines: $totalLines,
549:                     visibleLines: $visibleLines,
550:                     currentLineNumber: $currentLineNumber,
551:                     currentColumn: $currentColumn,
552:                     lineHeight: $lineHeight,
553:                     isActive: splitManager.activePaneId == pane.id
554:                 )
555:                 .environmentObject(editorCore)
556:                 .onChange(of: text) { newValue in
557:                     pane.updateTabContent(newValue)
558:                     
559:                     // Sync scroll if enabled
560:                     if splitManager.syncScroll {
561:                         splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
562:                     }
563:                 }
564:                 
565:                 // Mini minimap
566:                 MinimapView(
567:                     content: text,
568:                     scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
569:                     scrollViewHeight: .constant(geometry.size.height),
570:                     totalContentHeight: CGFloat(totalLines) * lineHeight
571:                 )
572:                 .frame(width: 60)
573:             }
574:             
575:             // Sticky Header Overlay (FEAT-040)
576:             StickyHeaderView(
577:                 text: text,
578:                 currentLine: scrollPosition,
579:                 theme: ThemeManager.shared.currentTheme,
580:                 lineHeight: lineHeight,
581:                 onSelect: { line in
582:                     scrollPosition = line
583:                 }
584:             )
585:             .padding(.leading, 54)
586:             .padding(.trailing, 60)
587:         }
588:         .onAppear {
589:             text = tab.content
590:         }
591:         .onChange(of: tab.id) { _ in
592:             text = tab.content
593:         }
594:         .onChange(of: pane.scrollOffset) { newOffset in
595:             if splitManager.syncScroll {
596:                 scrollPosition = Int(newOffset / lineHeight)
597:             }
598:         }
599:     }
600: }
601: 
602: // MARK: - Split Drag Handle
603: 
604: struct SplitDragHandle: View {
605:     let direction: SplitDirection
606:     let onDrag: (CGFloat) -> Void
607:     
608:     @State private var isDragging = false
609:     @GestureState private var dragOffset: CGFloat = 0
610:     
611:     var body: some View {
612:         ZStack {
613:             // Background
614:             Rectangle()
615:                 .fill(Color(UIColor.separator))
616:             
617:             // Handle indicator
618:             if direction == .horizontal {
619:                 VStack(spacing: 2) {
620:                     ForEach(0..<3, id: \.self) { _ in

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-420 of 1995)
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


>>>TOOL search
{"query":"func updateScrollPosition", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"scrollToAndSelectLine", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"scrollToLine(", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:433: func updateScrollPosition(_ textView: UITextView) {

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:260: context.coordinator.scrollToAndSelectLine(requested, in: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:473: func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {

---

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:253: context.coordinator.scrollToLine(scrollPosition, in: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:447: func scrollToLine(_ line: Int, in textView: UITextView) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:488: scrollToLine(line, in: textView)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":420,"end_line":560}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":380,"end_line":620}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":780,"end_line":920}
>>>END


---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 421-560 of 1995)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 381-620 of 1064)
────────────────────────────────────────
381:                 .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
382:             if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
383:             Button(action: { editorCore.closeTab(id: tab.id) }) {
384:                 Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
385:                     .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
386:             }
387:         }
388:         .padding(.horizontal, 12).padding(.vertical, 6)
389:         .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
390:         .onTapGesture { editorCore.selectTab(id: tab.id) }
391:     }
392: }
393: 
394: // MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
395: 
396: struct IDEEditorView: View {
397:     @ObservedObject var editorCore: EditorCore
398:     let tab: Tab
399:     let theme: Theme
400: 
401:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
402:     @State private var text: String = ""
403:     @State private var scrollPosition: Int = 0
404:     @State private var totalLines: Int = 1
405:     @State private var visibleLines: Int = 20
406:     @State private var currentLineNumber: Int = 1
407:     @State private var currentColumn: Int = 1
408:     @State private var cursorIndex: Int = 0
409:     @State private var lineHeight: CGFloat = 17
410:     @State private var requestedCursorIndex: Int? = nil
411:     @State private var requestedLineSelection: Int? = nil
412: 
413:     @StateObject private var autocomplete = AutocompleteManager()
414:     @State private var showAutocomplete = false
415:     @StateObject private var foldingManager = CodeFoldingManager()
416:     @StateObject private var findViewModel = FindViewModel()
417:     
418:     var body: some View {
419:         VStack(spacing: 0) {
420:             // Find/Replace bar
421:             if editorCore.showSearch {
422:                 FindReplaceView(viewModel: findViewModel)
423:                     .background(theme.tabBarBackground)
424:             }
425:             
426:             BreadcrumbsView(editorCore: editorCore, tab: tab)
427:             
428:             GeometryReader { geometry in
429:                 ZStack(alignment: .topLeading) {
430:                 HStack(spacing: 0) {
431:                     if lineNumbersStyle != "off" {
432:                         LineNumbersWithFolding(
433:                             fileId: tab.url?.path ?? tab.fileName,
434:                             totalLines: totalLines,
435:                             currentLine: currentLineNumber,
436:                             scrollOffset: CGFloat(scrollPosition) * lineHeight,
437:                             lineHeight: lineHeight,
438:                             requestedLineSelection: $requestedLineSelection,
439:                             foldingManager: foldingManager,
440:                             theme: theme
441:                         )
442:                         .frame(width: 60)
443:                         .background(theme.sidebarBackground.opacity(0.5))
444:                     }
445:                     
446:                     if tab.fileName.hasSuffix(".json") {
447:                         // JSON Tree View for .json files
448:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
449:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
450:                             .background(theme.editorBackground)
451:                     } else {
452:                         SyntaxHighlightingTextView(
453:                             text: $text,
454:                             filename: tab.fileName,
455:                             scrollPosition: $scrollPosition,
456:                             totalLines: $totalLines,
457:                             visibleLines: $visibleLines,
458:                             currentLineNumber: $currentLineNumber,
459:                             currentColumn: $currentColumn,
460:                             cursorIndex: $cursorIndex,
461:                             lineHeight: $lineHeight,
462:                             isActive: true,
463:                             fontSize: editorCore.editorFontSize,
464:                             requestedLineSelection: $requestedLineSelection,
465:                             requestedCursorIndex: $requestedCursorIndex,
466:                             onAcceptAutocomplete: {
467:                                 guard showAutocomplete else { return false }
468:                                 var tempText = text
469:                                 var tempCursor = cursorIndex
470:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
471:                                 if tempText != text {
472:                                     text = tempText
473:                                     cursorIndex = tempCursor
474:                                     requestedCursorIndex = tempCursor
475:                                     showAutocomplete = false
476:                                     return true
477:                                 }
478:                                 return false
479:                             },
480:                             onDismissAutocomplete: {
481:                                 guard showAutocomplete else { return false }
482:                                 autocomplete.hideSuggestions()
483:                                 showAutocomplete = false
484:                                 return true
485:                             }
486:                         )
487:                         .onChange(of: text) { newValue in
488:                             editorCore.updateActiveTabContent(newValue)
489:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
490:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
491:                             showAutocomplete = autocomplete.showSuggestions
492:                             foldingManager.detectFoldableRegions(in: newValue)
493:                         }
494:                         .onChange(of: cursorIndex) { newCursor in
495:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
496:                             showAutocomplete = autocomplete.showSuggestions
497:                         }
498:                     }
499:                     
500:                     if !tab.fileName.hasSuffix(".json") {
501:                         MinimapView(
502:                             content: text,
503:                             scrollOffset: CGFloat(scrollPosition) * lineHeight,
504:                             scrollViewHeight: geometry.size.height,
505:                             totalContentHeight: CGFloat(totalLines) * lineHeight,
506:                             onScrollRequested: { newOffset in
507:                                 // Minimap requested scroll - update editor position
508:                                 // Convert back from pixels to line number
509:                                 let newLine = Int(newOffset / lineHeight)
510:                                 scrollPosition = max(0, min(newLine, totalLines - 1))
511:                             }
512:                         )
513:                         .frame(width: 80)
514:                     }
515:                 }
516:                 .background(theme.editorBackground)
517: 
518:                 // Sticky Header Overlay (FEAT-040)
519:                 StickyHeaderView(
520:                     text: text,
521:                     currentLine: scrollPosition,
522:                     theme: theme,
523:                     lineHeight: lineHeight,
524:                     onSelect: { line in
525:                         requestedLineSelection = line
526:                     }
527:                 )
528:                 .padding(.leading, lineNumbersStyle != "off" ? 60 : 0)
529:                 .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
530: 
531:                 if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
532:                     AutocompletePopup(
533:                         suggestions: autocomplete.suggestionItems,
534:                         selectedIndex: autocomplete.selectedIndex,
535:                         theme: theme
536:                     ) { index in
537:                         autocomplete.selectedIndex = index
538:                         var tempText = text
539:                         var tempCursor = cursorIndex
540:                         autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
541:                         if tempText != text {
542:                             text = tempText
543:                             cursorIndex = tempCursor
544:                             requestedCursorIndex = tempCursor
545:                         }
546:                         showAutocomplete = false
547:                     }
548:                     .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
549:                 }
550:             }
551:         }
552:         }
553:         .onAppear {
554:             text = tab.content
555:             foldingManager.detectFoldableRegions(in: text)
556:         }
557:         .onChange(of: tab.id) { _ in
558:             text = tab.content
559:             foldingManager.detectFoldableRegions(in: text)
560:         }
561:         .onChange(of: currentLineNumber) { line in
562:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
563:         }
564:         .onChange(of: currentColumn) { col in
565:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
566:         }
567:         .onAppear {
568:             findViewModel.editorCore = editorCore
569:         }
570:     }
571:     
572:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
573: }
574: 
575: // MARK: - Line Numbers with Folding
576: 
577: struct LineNumbersWithFolding: View {
578:     let fileId: String
579:     let totalLines: Int
580:     let currentLine: Int
581:     let scrollOffset: CGFloat
582:     let lineHeight: CGFloat
583:     @Binding var requestedLineSelection: Int?
584:     @ObservedObject var foldingManager: CodeFoldingManager
585:     @ObservedObject private var debugManager = DebugManager.shared
586:     let theme: Theme
587: 
588:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
589: 
590:     var body: some View {
591:         ScrollView(showsIndicators: false) {
592:             VStack(alignment: .trailing, spacing: 0) {
593:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
594:                     if !foldingManager.isLineFolded(line: lineIndex) {
595:                         HStack(spacing: 2) {
596:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
597:                                 Circle()
598:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
599:                                     .overlay(
600:                                         Circle()
601:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
602:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
603:                                     )
604:                                     .frame(width: 10, height: 10)
605:                                     .padding(.leading, 2)
606:                             }
607:                             .buttonStyle(.plain)
608:                             .frame(width: 14, height: lineHeight)
609: 
610:                             if foldingManager.isFoldable(line: lineIndex) {
611:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
612:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
613:                                         .font(.system(size: 8))
614:                                         .foregroundColor(theme.lineNumber)
615:                                 }
616:                                 .buttonStyle(.plain)
617:                                 .frame(width: 14, height: lineHeight)
618:                             } else {
619:                                 Spacer().frame(width: 14)
620:                             }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 781-866 of 866)
────────────────────────────────────────
781:         for region in foldRegions where region.isFolded {
782:             for line in (region.startLine + 1)...region.endLine {
783:                 collapsedLines.insert(line)
784:             }
785:         }
786:     }
787: }
788: 
789: // MARK: - Fold Statistics
790: struct FoldStatistics {
791:     let totalRegions: Int
792:     let foldedRegions: Int
793:     let typeBreakdown: [FoldRegion.FoldType: Int]
794:     
795:     var expansionPercentage: Double {
796:         guard totalRegions > 0 else { return 0 }
797:         return Double(foldedCount) / Double(totalRegions) * 100
798:     }
799:     
800:     var foldedCount: Int {
801:         return foldedRegions
802:     }
803:     
804:     var expandedCount: Int {
805:         return totalRegions - foldedRegions
806:     }
807: }
808: 
809: // MARK: - Fold Button View
810: struct FoldButton: View {
811:     let line: Int
812:     let isExpanded: Bool
813:     let foldType: FoldRegion.FoldType?
814:     let action: () -> Void
815:     
816:     var body: some View {
817:         Button(action: action) {
818:             ZStack {
819:                 if let type = foldType {
820:                     Text(type.icon)
821:                         .font(.system(size: 8, weight: .bold))
822:                         .foregroundColor(.blue.opacity(0.6))
823:                 }
824:                 
825:                 Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
826:                     .font(.system(size: 10, weight: .semibold))
827:                     .foregroundColor(.primary.opacity(0.7))
828:             }
829:             .frame(width: 18, height: 18)
830:             .background(isExpanded ? Color.secondary.opacity(0.1) : Color.secondary.opacity(0.2))
831:             .cornerRadius(4)
832:         }
833:         .buttonStyle(PlainButtonStyle())
834:     }
835: }
836: 
837: // MARK: - Line Number View with Folding
838: struct LineNumberViewWithFolding: View {
839:     let lineNumber: Int
840:     let isFoldable: Bool
841:     let isExpanded: Bool
842:     let foldType: FoldRegion.FoldType?
843:     let onFoldTap: () -> Void
844:     
845:     var body: some View {
846:         HStack(spacing: 4) {
847:             if isFoldable {
848:                 FoldButton(
849:                     line: lineNumber,
850:                     isExpanded: isExpanded,
851:                     foldType: foldType,
852:                     action: onFoldTap
853:                 )
854:             } else {
855:                 Color.clear
856:                     .frame(width: 18, height: 18)
857:             }
858:             
859:             Text("\(lineNumber + 1)")
860:                 .font(.system(.caption, design: .monospaced))
861:                 .foregroundColor(.gray)
862:                 .frame(minWidth: 30, alignment: .trailing)
863:         }
864:     }
865: }
866: 


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":620,"end_line":780}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":500,"end_line":640}
>>>END>>>TOOL search
{"query":"scrollOffset", "glob":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift"}
>>>END
>>>END of response.>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":620,"end_line":820}
>>>END

>>>TOOL search
{"query":"scrollOffset", "glob":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 621-780 of 1064)
────────────────────────────────────────
621: 
622:                             Text(displayText(for: lineIndex))
623:                                 .font(.system(size: 12, design: .monospaced))
624:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
625:                                 .frame(height: lineHeight)
626:                                 .contentShape(Rectangle())
627:                                 .onTapGesture {
628:                                     // FEAT-041: click line number selects entire line
629:                                     requestedLineSelection = lineIndex
630:                                 }
631:                         }
632:                         .frame(maxWidth: .infinity, alignment: .trailing)
633:                         .padding(.trailing, 4)
634:                     }
635:                 }
636:             }
637:             .offset(y: -scrollOffset)
638:         }
639:     }
640: 
641:     private func displayText(for lineIndex: Int) -> String {
642:         switch lineNumbersStyle {
643:         case "relative":
644:             // VS Code-style: current line shows absolute, others show relative distance
645:             let lineNumber = lineIndex + 1
646:             if lineNumber == currentLine { return "\(lineNumber)" }
647:             return "\(abs(lineNumber - currentLine))"
648: 
649:         case "interval":
650:             let lineNumber = lineIndex + 1
651:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
652: 
653:         default:
654:             return "\(lineIndex + 1)"
655:         }
656:     }
657: }
658: 
659: // MARK: - Autocomplete Popup
660: 
661: struct AutocompletePopup: View {
662:     let suggestions: [AutocompleteSuggestion]
663:     let selectedIndex: Int
664:     let theme: Theme
665:     let onSelectIndex: (Int) -> Void
666:     
667:     var body: some View {
668:         VStack(alignment: .leading, spacing: 0) {
669:             ForEach(suggestions.indices, id: \.self) { index in
670:                 let s = suggestions[index]
671:                 HStack(spacing: 6) {
672:                     Image(systemName: icon(for: s.kind))
673:                         .font(.caption)
674:                         .foregroundColor(color(for: s.kind))
675:                     VStack(alignment: .leading, spacing: 1) {
676:                         Text(s.displayText)
677:                             .font(.system(size: 12, design: .monospaced))
678:                             .foregroundColor(theme.editorForeground)
679:                         if s.insertText != s.displayText && !s.insertText.isEmpty {
680:                             Text(s.insertText)
681:                                 .font(.system(size: 10, design: .monospaced))
682:                                 .foregroundColor(theme.editorForeground.opacity(0.55))
683:                                 .lineLimit(1)
684:                         }
685:                     }
686:                     Spacer()
687:                 }
688:                 .padding(.horizontal, 8).padding(.vertical, 6)
689:                 .background(index == selectedIndex ? theme.selection : Color.clear)
690:                 .contentShape(Rectangle())
691:                 .onTapGesture { onSelectIndex(index) }
692:             }
693:         }
694:         .frame(width: 260)
695:         .background(theme.editorBackground)
696:         .cornerRadius(6)
697:         .shadow(radius: 8)
698:     }
699:     
700:     private func icon(for kind: AutocompleteSuggestionKind) -> String {
701:         switch kind {
702:         case .keyword: return "key.fill"
703:         case .symbol: return "cube.fill"
704:         case .stdlib: return "curlybraces"
705:         case .member: return "arrow.right.circle.fill"
706:         }
707:     }
708:     
709:     private func color(for kind: AutocompleteSuggestionKind) -> Color {
710:         switch kind {
711:         case .keyword: return .purple
712:         case .symbol: return .blue
713:         case .stdlib: return .orange
714:         case .member: return .green
715:         }
716:     }
717: }
718: 
719: // MARK: - Welcome View
720: 
721: struct IDEWelcomeView: View {
722:     @ObservedObject var editorCore: EditorCore
723:     @Binding var showFolderPicker: Bool
724:     let theme: Theme
725:     
726:     var body: some View {
727:         VStack(spacing: 24) {
728:             Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 80)).foregroundColor(theme.editorForeground.opacity(0.3))
729:             Text("VS Code for iPadOS").font(.largeTitle).fontWeight(.bold).foregroundColor(theme.editorForeground)
730:             VStack(alignment: .leading, spacing: 12) {
731:                 WelcomeBtn(icon: "doc.badge.plus", title: "New File", shortcut: "⌘N", theme: theme) { editorCore.addTab() }
732:                 WelcomeBtn(icon: "folder", title: "Open Folder", shortcut: "⌘⇧O", theme: theme) { showFolderPicker = true }
733:                 WelcomeBtn(icon: "doc", title: "Open File", shortcut: "⌘O", theme: theme) { editorCore.showFilePicker = true }
734:                 WelcomeBtn(icon: "terminal", title: "Command Palette", shortcut: "⌘⇧P", theme: theme) { editorCore.showCommandPalette = true }
735:             }
736:         }.frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.editorBackground)
737:     }
738: }
739: 
740: struct WelcomeBtn: View {
741:     let icon: String
742:     let title: String
743:     let shortcut: String
744:     let theme: Theme
745:     let action: () -> Void
746:     
747:     var body: some View {
748:         Button(action: action) {
749:             HStack {
750:                 Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
751:                 Text(title).foregroundColor(theme.editorForeground)
752:                 Spacer()
753:                 Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
754:             }
755:             .padding().frame(width: 280)
756:             .background(theme.sidebarBackground)
757:             .cornerRadius(8)
758:         }.buttonStyle(.plain)
759:     }
760: }
761: 
762: // MARK: - Command Palette
763: 
764: struct IDECommandPalette: View {
765:     @ObservedObject var editorCore: EditorCore
766:     @Binding var showSettings: Bool
767:     @Binding var showTerminal: Bool
768:     @State private var searchText = ""
769:     
770:     var body: some View {
771:         VStack(spacing: 0) {
772:             HStack {
773:                 Image(systemName: "magnifyingglass").foregroundColor(.secondary)
774:                 TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
775:             }.padding().background(Color(UIColor.secondarySystemBackground))
776:             Divider()
777:             ScrollView {
778:                 VStack(spacing: 0) {
779:                     CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
780:                     CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 501-640 of 774)
────────────────────────────────────────
501:     private var fileId: String { tab.url?.path ?? tab.fileName }
502:     
503:     var body: some View {
504:         GeometryReader { geometry in
505:             HStack(spacing: 0) {
506:                 // Line numbers + breakpoints + code folding (gutter)
507:                 //
508:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
509:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
510:                 if lineNumbersStyle != "off" {
511:                     ScrollView(showsIndicators: false) {
512:                         VStack(alignment: .trailing, spacing: 0) {
513:                             ForEach(0..<totalLines, id: \ .self) { lineIndex in
514:                                 HStack(spacing: 2) {
515:                                     // Fold chevron icon
516:                                     if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
517:                                         Button(action: { 
518:                                             foldingManager.toggleFold(fileId: fileId, line: lineIndex)
519:                                         }) {
520:                                             Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")
521:                                                 .font(.system(size: 10, weight: .regular))
522:                                                 .foregroundColor(.secondary.opacity(0.8))
523:                                                 .frame(width: 12, height: lineHeight)
524:                                         }
525:                                         .buttonStyle(.plain)
526:                                     } else {
527:                                         // Spacer for alignment
528:                                         Spacer()
529:                                             .frame(width: 12)
530:                                     }
531:                                     
532:                                     // Breakpoint indicator
533:                                     Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
534:                                         Circle()
535:                                             .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
536:                                             .overlay(
537:                                                 Circle()
538:                                                     .stroke(Color.red.opacity(0.6), lineWidth: 1)
539:                                                     .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
540:                                             )
541:                                             .frame(width: 10, height: 10)
542:                                     }
543:                                     .buttonStyle(.plain)
544:                                     .frame(width: 14, height: lineHeight)
545: 
546:                                     Text(displayText(for: lineIndex))
547:                                         .font(.system(size: 12, design: .monospaced))
548:                                         .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
549:                                         .frame(height: lineHeight)
550:                                         .contentShape(Rectangle())
551:                                         .onTapGesture {
552:                                             requestedLineSelection = lineIndex
553:                                         }
554:                                 }
555:                                 .frame(maxWidth: .infinity, alignment: .trailing)
556:                             }
557:                         }
558:                         .padding(.trailing, 4)
559:                         .offset(y: -CGFloat(scrollPosition) * lineHeight)
560:                     }
561:                     .frame(width: 70)
562:                     .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
563:                 }
564: 
565:                 // Editor
566:                 SyntaxHighlightingTextView(
567:                     text: $text,
568:                     filename: tab.fileName,
569:                     scrollPosition: $scrollPosition,
570:                     totalLines: $totalLines,
571:                     visibleLines: $visibleLines,
572:                     currentLineNumber: $currentLineNumber,
573:                     currentColumn: $currentColumn,
574:                     lineHeight: $lineHeight,
575:                     isActive: splitManager.activePaneId == pane.id,
576:                     editorCore: editorCore,
577:                     requestedLineSelection: $requestedLineSelection
578:                 )
579:                 .onChange(of: text) { newValue in
580:                     pane.updateTabContent(newValue)
581:                     
582:                     // Sync scroll if enabled
583:                     if splitManager.syncScroll {
584:                         splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
585:                     }
586:                 }
587:                 
588:                 // Mini minimap
589:                 MinimapView(
590:                     content: text,
591:                     scrollOffset: CGFloat(scrollPosition) * lineHeight,
592:                     scrollViewHeight: geometry.size.height,
593:                     totalContentHeight: CGFloat(totalLines) * lineHeight
594:                 )
595:                 .frame(width: 60)
596:             }
597:             // Sticky Header Overlay (FEAT-040)
598:             StickyHeaderView(
599:                 text: text,
600:                 currentLine: scrollPosition, // Using scrollPosition as approximate top line
601:                 theme: ThemeManager.shared.currentTheme,
602:                 lineHeight: lineHeight,
603:                 onSelect: { line in
604:                     requestedLineSelection = line
605:                 }
606:             )
607:             .padding(.leading, 70) // Offset for line numbers + folding icons
608:             .padding(.trailing, 60) // Offset for minimap
609:             
610:             // Peek Definition Overlay
611:             if let peekState = editorCore.peekState, editorCore.activeTabId == tab.id {
612:                  // Calculate simplified position: center of screen for now, but conceptually "inline"
613:                  // To make it truly inline, we'd need more complex geometry, but overlay is a good start.
614:                  VStack {
615:                      Spacer()
616:                          .frame(height: max(0, CGFloat(peekState.sourceLine - scrollPosition) * lineHeight + lineHeight + 20))
617:                      
618:                      PeekDefinitionView(
619:                          editorCore: editorCore,
620:                          targetFile: peekState.file,
621:                          targetLine: peekState.line,
622:                          content: peekState.content,
623:                          onClose: { editorCore.closePeekDefinition() },
624:                          onOpen: {
625:                              editorCore.openFile(FileItem(name: URL(fileURLWithPath: peekState.file).lastPathComponent, path: peekState.file, isDirectory: false))
626:                              editorCore.closePeekDefinition()
627:                          }
628:                      )
629:                      .padding(.horizontal)
630:                      .padding(.bottom, 20)
631:                      
632:                      Spacer()
633:                  }
634:                  .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
635:                  .background(Color.black.opacity(0.01)) // Capture taps outside if needed, or let them pass
636:                  .transition(.opacity)
637:                  .zIndex(100)
638:             }
639:         }
640:         .onAppear {

---

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:436: scrollOffset: CGFloat(scrollPosition) * lineHeight,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:503: scrollOffset: CGFloat(scrollPosition) * lineHeight,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:581: let scrollOffset: CGFloat
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:637: .offset(y: -scrollOffset)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 621-820 of 1064)
────────────────────────────────────────
621: 
622:                             Text(displayText(for: lineIndex))
623:                                 .font(.system(size: 12, design: .monospaced))
624:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
625:                                 .frame(height: lineHeight)
626:                                 .contentShape(Rectangle())
627:                                 .onTapGesture {
628:                                     // FEAT-041: click line number selects entire line
629:                                     requestedLineSelection = lineIndex
630:                                 }
631:                         }
632:                         .frame(maxWidth: .infinity, alignment: .trailing)
633:                         .padding(.trailing, 4)
634:                     }
635:                 }
636:             }
637:             .offset(y: -scrollOffset)
638:         }
639:     }
640: 
641:     private func displayText(for lineIndex: Int) -> String {
642:         switch lineNumbersStyle {
643:         case "relative":
644:             // VS Code-style: current line shows absolute, others show relative distance
645:             let lineNumber = lineIndex + 1
646:             if lineNumber == currentLine { return "\(lineNumber)" }
647:             return "\(abs(lineNumber - currentLine))"
648: 
649:         case "interval":
650:             let lineNumber = lineIndex + 1
651:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
652: 
653:         default:
654:             return "\(lineIndex + 1)"
655:         }
656:     }
657: }
658: 
659: // MARK: - Autocomplete Popup
660: 
661: struct AutocompletePopup: View {
662:     let suggestions: [AutocompleteSuggestion]
663:     let selectedIndex: Int
664:     let theme: Theme
665:     let onSelectIndex: (Int) -> Void
666:     
667:     var body: some View {
668:         VStack(alignment: .leading, spacing: 0) {
669:             ForEach(suggestions.indices, id: \.self) { index in
670:                 let s = suggestions[index]
671:                 HStack(spacing: 6) {
672:                     Image(systemName: icon(for: s.kind))
673:                         .font(.caption)
674:                         .foregroundColor(color(for: s.kind))
675:                     VStack(alignment: .leading, spacing: 1) {
676:                         Text(s.displayText)
677:                             .font(.system(size: 12, design: .monospaced))
678:                             .foregroundColor(theme.editorForeground)
679:                         if s.insertText != s.displayText && !s.insertText.isEmpty {
680:                             Text(s.insertText)
681:                                 .font(.system(size: 10, design: .monospaced))
682:                                 .foregroundColor(theme.editorForeground.opacity(0.55))
683:                                 .lineLimit(1)
684:                         }
685:                     }
686:                     Spacer()
687:                 }
688:                 .padding(.horizontal, 8).padding(.vertical, 6)
689:                 .background(index == selectedIndex ? theme.selection : Color.clear)
690:                 .contentShape(Rectangle())
691:                 .onTapGesture { onSelectIndex(index) }
692:             }
693:         }
694:         .frame(width: 260)
695:         .background(theme.editorBackground)
696:         .cornerRadius(6)
697:         .shadow(radius: 8)
698:     }
699:     
700:     private func icon(for kind: AutocompleteSuggestionKind) -> String {
701:         switch kind {
702:         case .keyword: return "key.fill"
703:         case .symbol: return "cube.fill"
704:         case .stdlib: return "curlybraces"
705:         case .member: return "arrow.right.circle.fill"
706:         }
707:     }
708:     
709:     private func color(for kind: AutocompleteSuggestionKind) -> Color {
710:         switch kind {
711:         case .keyword: return .purple
712:         case .symbol: return .blue
713:         case .stdlib: return .orange
714:         case .member: return .green
715:         }
716:     }
717: }
718: 
719: // MARK: - Welcome View
720: 
721: struct IDEWelcomeView: View {
722:     @ObservedObject var editorCore: EditorCore
723:     @Binding var showFolderPicker: Bool
724:     let theme: Theme
725:     
726:     var body: some View {
727:         VStack(spacing: 24) {
728:             Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 80)).foregroundColor(theme.editorForeground.opacity(0.3))
729:             Text("VS Code for iPadOS").font(.largeTitle).fontWeight(.bold).foregroundColor(theme.editorForeground)
730:             VStack(alignment: .leading, spacing: 12) {
731:                 WelcomeBtn(icon: "doc.badge.plus", title: "New File", shortcut: "⌘N", theme: theme) { editorCore.addTab() }
732:                 WelcomeBtn(icon: "folder", title: "Open Folder", shortcut: "⌘⇧O", theme: theme) { showFolderPicker = true }
733:                 WelcomeBtn(icon: "doc", title: "Open File", shortcut: "⌘O", theme: theme) { editorCore.showFilePicker = true }
734:                 WelcomeBtn(icon: "terminal", title: "Command Palette", shortcut: "⌘⇧P", theme: theme) { editorCore.showCommandPalette = true }
735:             }
736:         }.frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.editorBackground)
737:     }
738: }
739: 
740: struct WelcomeBtn: View {
741:     let icon: String
742:     let title: String
743:     let shortcut: String
744:     let theme: Theme
745:     let action: () -> Void
746:     
747:     var body: some View {
748:         Button(action: action) {
749:             HStack {
750:                 Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
751:                 Text(title).foregroundColor(theme.editorForeground)
752:                 Spacer()
753:                 Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
754:             }
755:             .padding().frame(width: 280)
756:             .background(theme.sidebarBackground)
757:             .cornerRadius(8)
758:         }.buttonStyle(.plain)
759:     }
760: }
761: 
762: // MARK: - Command Palette
763: 
764: struct IDECommandPalette: View {
765:     @ObservedObject var editorCore: EditorCore
766:     @Binding var showSettings: Bool
767:     @Binding var showTerminal: Bool
768:     @State private var searchText = ""
769:     
770:     var body: some View {
771:         VStack(spacing: 0) {
772:             HStack {
773:                 Image(systemName: "magnifyingglass").foregroundColor(.secondary)
774:                 TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
775:             }.padding().background(Color(UIColor.secondarySystemBackground))
776:             Divider()
777:             ScrollView {
778:                 VStack(spacing: 0) {
779:                     CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
780:                     CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
781:                     CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
782:                     CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
783:                     CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
784:                     CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
785:                     CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
786:                     CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
787:                 }.padding(.vertical, 8)
788:             }
789:         }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
790:     }
791: }
792: 
793: struct CommandRow: View {
794:     let icon: String; let name: String; let shortcut: String; let action: () -> Void
795:     var body: some View {
796:         Button(action: action) {
797:             HStack {
798:                 Image(systemName: icon).foregroundColor(.accentColor).frame(width: 24)
799:                 Text(name).foregroundColor(.primary)
800:                 Spacer()
801:                 Text(shortcut).font(.caption).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 4).background(Color(UIColor.tertiarySystemFill)).cornerRadius(4)
802:             }.padding(.horizontal).padding(.vertical, 12).contentShape(Rectangle())
803:         }.buttonStyle(.plain)
804:     }
805: }
806: 
807: // MARK: - Quick Open
808: 
809: struct IDEQuickOpen: View {
810:     @ObservedObject var editorCore: EditorCore
811:     @State private var searchText = ""
812:     
813:     var body: some View {
814:         VStack(spacing: 0) {
815:             HStack {
816:                 Image(systemName: "magnifyingglass").foregroundColor(.gray)
817:                 TextField("Search files...", text: $searchText).textFieldStyle(.plain)
818:             }.padding().background(Color(UIColor.secondarySystemBackground))
819:             Divider()
820:             ScrollView {


>>>TOOL search
{"query":"textContainerInset", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":560,"end_line":660}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift","start_line":1,"end_line":90}
>>>END
>>>END of response>>>TOOL search
{"query":"textContainerInset", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":560,"end_line":660}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift","start_line":1,"end_line":90}
>>>END
>>>END of response>>>TOOL search
{"query":"textContainerInset", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:173: textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:881: let x = CGFloat(i) * indentWidth + self.textContainerInset.left

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 561-660 of 1064)
────────────────────────────────────────
561:         .onChange(of: currentLineNumber) { line in
562:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
563:         }
564:         .onChange(of: currentColumn) { col in
565:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
566:         }
567:         .onAppear {
568:             findViewModel.editorCore = editorCore
569:         }
570:     }
571:     
572:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
573: }
574: 
575: // MARK: - Line Numbers with Folding
576: 
577: struct LineNumbersWithFolding: View {
578:     let fileId: String
579:     let totalLines: Int
580:     let currentLine: Int
581:     let scrollOffset: CGFloat
582:     let lineHeight: CGFloat
583:     @Binding var requestedLineSelection: Int?
584:     @ObservedObject var foldingManager: CodeFoldingManager
585:     @ObservedObject private var debugManager = DebugManager.shared
586:     let theme: Theme
587: 
588:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
589: 
590:     var body: some View {
591:         ScrollView(showsIndicators: false) {
592:             VStack(alignment: .trailing, spacing: 0) {
593:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
594:                     if !foldingManager.isLineFolded(line: lineIndex) {
595:                         HStack(spacing: 2) {
596:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
597:                                 Circle()
598:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
599:                                     .overlay(
600:                                         Circle()
601:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
602:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
603:                                     )
604:                                     .frame(width: 10, height: 10)
605:                                     .padding(.leading, 2)
606:                             }
607:                             .buttonStyle(.plain)
608:                             .frame(width: 14, height: lineHeight)
609: 
610:                             if foldingManager.isFoldable(line: lineIndex) {
611:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
612:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
613:                                         .font(.system(size: 8))
614:                                         .foregroundColor(theme.lineNumber)
615:                                 }
616:                                 .buttonStyle(.plain)
617:                                 .frame(width: 14, height: lineHeight)
618:                             } else {
619:                                 Spacer().frame(width: 14)
620:                             }
621: 
622:                             Text(displayText(for: lineIndex))
623:                                 .font(.system(size: 12, design: .monospaced))
624:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
625:                                 .frame(height: lineHeight)
626:                                 .contentShape(Rectangle())
627:                                 .onTapGesture {
628:                                     // FEAT-041: click line number selects entire line
629:                                     requestedLineSelection = lineIndex
630:                                 }
631:                         }
632:                         .frame(maxWidth: .infinity, alignment: .trailing)
633:                         .padding(.trailing, 4)
634:                     }
635:                 }
636:             }
637:             .offset(y: -scrollOffset)
638:         }
639:     }
640: 
641:     private func displayText(for lineIndex: Int) -> String {
642:         switch lineNumbersStyle {
643:         case "relative":
644:             // VS Code-style: current line shows absolute, others show relative distance
645:             let lineNumber = lineIndex + 1
646:             if lineNumber == currentLine { return "\(lineNumber)" }
647:             return "\(abs(lineNumber - currentLine))"
648: 
649:         case "interval":
650:             let lineNumber = lineIndex + 1
651:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
652: 
653:         default:
654:             return "\(lineIndex + 1)"
655:         }
656:     }
657: }
658: 
659: // MARK: - Autocomplete Popup
660: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift (lines 2-90 of 281)
────────────────────────────────────────
2: import UIKit
3: 
4: /// Renders inline ghost text suggestions with fade animations and multi-line support.
5: ///
6: /// This view displays AI-generated code suggestions as semi-transparent gray text
7: /// positioned at the cursor location. Users can accept suggestions with the Tab key.
8: ///
9: /// Features:
10: /// - Ghost text overlay with proper positioning based on cursor location
11: /// - Multi-line suggestion support with line breaks
12: /// - Fade in/out animations for smooth appearance/disappearance
13: /// - "Tab to accept" indicator
14: /// - Integration with InlineSuggestionManager via @EnvironmentObject
15: /// - Proper handling of partial accept state
16: struct InlineSuggestionView: View {
17:     /// The code content being edited (needed for positioning calculations)
18:     let code: String
19:     
20:     /// Language for syntax context (affects styling)
21:     let language: CodeLanguage
22:     
23:     /// Current scroll position (line index) of the editor
24:     let scrollPosition: Int
25:     
26:     /// Height of each line in the editor
27:     let lineHeight: CGFloat
28:     
29:     /// Font size used in the editor
30:     let fontSize: CGFloat
31:     
32:     /// Width reserved for the gutter (line numbers)
33:     var gutterWidth: CGFloat = 60
34:     
35:     /// Insets used by the underlying UITextView
36:     var textInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
37:     
38:     /// Width reserved at the right edge (e.g. minimap)
39:     var rightReservedWidth: CGFloat = 0
40:     
41:     /// How many spaces a tab visually represents
42:     var tabSize: Int = 4
43:     
44:     /// Animation duration for fade in/out
45:     var animationDuration: Double = 0.15
46:     
47:     /// The manager that provides suggestion state
48:     @EnvironmentObject var suggestionManager: InlineSuggestionManager
49:     
50:     /// Controls the visibility animation state
51:     @State private var isVisible: Bool = false
52:     
53:     /// The ghost text to display (filtered to show only unaccepted portion)
54:     private var ghostText: String {
55:         suggestionManager.ghostText
56:     }
57:     
58:     /// Whether there is an active suggestion to display
59:     private var hasSuggestion: Bool {
60:         !ghostText.isEmpty
61:     }
62:     
63:     /// The cursor position for rendering
64:     private var cursorPosition: InlineSuggestionManager.CursorPosition {
65:         suggestionManager.cursorPosition
66:     }
67:     
68:     var body: some View {
69:         GeometryReader { geo in
70:             ZStack(alignment: .topLeading) {
71:                 if isVisible && hasSuggestion {
72:                     suggestionContent(geometry: geo)
73:                 }
74:             }
75:             .frame(
76:                 width: max(0, geo.size.width - rightReservedWidth),
77:                 height: geo.size.height,
78:                 alignment: .topLeading
79:             )
80:             .clipped()
81:         }
82:         .allowsHitTesting(false)
83:         .onAppear {
84:             updateVisibility()
85:         }
86:         .onChange(of: ghostText) { _ in
87:             updateVisibility()
88:         }
89:         .onChange(of: suggestionManager.currentSuggestion) { _ in
90:             updateVisibility()


>>>TOOL search
{"query":"isLineFolded", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"detectFoldableRegions", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"toggleFold(at:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:672: func isLineFolded(line: Int) -> Bool {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:594: if !foldingManager.isLineFolded(line: lineIndex) {

---

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:83: func detectFoldableRegions(in code: String, filePath: String? = nil) {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:492: foldingManager.detectFoldableRegions(in: newValue)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:555: foldingManager.detectFoldableRegions(in: text)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:559: foldingManager.detectFoldableRegions(in: text)

---

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:594: toggleFold(at: region.startLine)
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:602: toggleFold(at: region.startLine)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:611: Button(action: { foldingManager.toggleFold(at: lineIndex) }) {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":40,"end_line":140}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":620,"end_line":740}
>>>END

>>>TOOL get_errors
{}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 41-140 of 866)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 621-740 of 866)
────────────────────────────────────────
621:         }
622:     }
623:     
624:     /// Collapses all foldable regions
625:     func collapseAll() {
626:         for index in foldRegions.indices {
627:             foldRegions[index].isFolded = true
628:         }
629:         updateCollapsedLines()
630:         
631:         if let filePath = currentFilePath {
632:             saveFoldState(for: filePath)
633:         }
634:     }
635:     
636:     /// Collapses all regions of a specific type
637:     func collapseAll(ofType type: FoldRegion.FoldType) {
638:         for index in foldRegions.indices {
639:             if foldRegions[index].type == type {
640:                 foldRegions[index].isFolded = true
641:             }
642:         }
643:         updateCollapsedLines()
644:         
645:         if let filePath = currentFilePath {
646:             saveFoldState(for: filePath)
647:         }
648:     }
649:     
650:     /// Expands all regions of a specific type
651:     func expandAll(ofType type: FoldRegion.FoldType) {
652:         for index in foldRegions.indices {
653:             if foldRegions[index].type == type {
654:                 foldRegions[index].isFolded = false
655:             }
656:         }
657:         updateCollapsedLines()
658:         
659:         if let filePath = currentFilePath {
660:             saveFoldState(for: filePath)
661:         }
662:     }
663:     
664:     // MARK: - Query Methods
665:     
666:     /// Checks if a line is foldable
667:     func isFoldable(line: Int) -> Bool {
668:         return foldRegions.contains { $0.startLine == line }
669:     }
670:     
671:     /// Checks if a line is currently folded
672:     func isLineFolded(line: Int) -> Bool {
673:         return collapsedLines.contains(line)
674:     }
675:     
676:     /// Checks if a region at a given line is folded
677:     func isRegionFolded(at line: Int) -> Bool {
678:         return foldRegions.first { $0.startLine == line }?.isFolded ?? false
679:     }
680:     
681:     /// Gets the fold region at a specific line
682:     func getRegion(at line: Int) -> FoldRegion? {
683:         return foldRegions.first { $0.startLine == line }
684:     }
685:     
686:     /// Gets all fold regions of a specific type
687:     func getRegions(ofType type: FoldRegion.FoldType) -> [FoldRegion] {
688:         return foldRegions.filter { $0.type == type }
689:     }
690:     
691:     // MARK: - File-Aware Methods
692:     
693:     /// Checks if a line is foldable for a specific file
694:     func isFoldable(fileId: String, line: Int) -> Bool {
695:         guard let regions = foldRegionsByFile[fileId] else { return false }
696:         return regions.contains { $0.startLine == line }
697:     }
698:     
699:     /// Checks if a region at a given line is folded for a specific file
700:     func isFolded(fileId: String, line: Int) -> Bool {
701:         guard let regions = foldRegionsByFile[fileId] else { return false }
702:         return regions.first { $0.startLine == line }?.isFolded ?? false
703:     }
704:     
705:     /// Toggles the fold state at a specific line for a specific file
706:     func toggleFold(fileId: String, line: Int) {
707:         guard var regions = foldRegionsByFile[fileId] else { return }
708:         
709:         if let regionIndex = regions.firstIndex(where: { $0.startLine == line }) {
710:             regions[regionIndex].isFolded.toggle()
711:             foldRegionsByFile[fileId] = regions
712:             
713:             // Update current file regions if this is the active file
714:             if fileId == currentFileId {
715:                 self.foldRegions = regions
716:                 updateCollapsedLines()
717:             }
718:             
719:             // Save state after toggling
720:             saveFoldState(for: fileId)
721:         }
722:     }
723:     
724:     /// Gets fold regions for a specific file
725:     func getFoldRegions(for fileId: String) -> [FoldRegion] {
726:         return foldRegionsByFile[fileId] ?? []
727:     }
728:     
729:     /// Clears fold regions for a specific file from memory
730:     func clearFoldRegions(for fileId: String) {
731:         foldRegionsByFile.removeValue(forKey: fileId)
732:     }
733:     
734:     /// Clears all fold regions from memory
735:     func clearAllFoldRegions() {
736:         foldRegionsByFile.removeAll()
737:     }
738:     
739:     /// Gets folded line ranges for text hiding
740:     /// Returns an array of closed ranges representing the line numbers that should be hidden

---

[get_errors]
✅ No errors or warnings


>>>TOOL search
{"query":"struct MinimapView", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift","start_line":1,"end_line":220}
>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift:8: struct MinimapView: View {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift (lines 2-220 of 472)
────────────────────────────────────────
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
12:     /// Current scroll offset (read-only for display). Minimap FOLLOWS the editor, never fights it.
13:     let scrollOffset: CGFloat
14:     /// Visible viewport height (read-only for display)
15:     let scrollViewHeight: CGFloat
16:     let totalContentHeight: CGFloat
17:     
18:     /// Callback when user taps/drags on minimap to request scroll. 
19:     /// Parent handles actual scrolling - prevents bidirectional binding jitter.
20:     var onScrollRequested: ((CGFloat) -> Void)? = nil
21: 
22:     /// Optional indicators to render as thin bars on the left side of the minimap.
23:     /// Note: call sites can ignore this (default empty) without breaking compilation.
24:     var diffIndicators: [MinimapDiffIndicator] = []
25: 
26:     /// Fixed width; height expands to the container.
27:     var minimapWidth: CGFloat = 60
28: 
29:     // MARK: - Internal state
30: 
31:     @State private var isInteracting: Bool = false
32: 
33:     // MARK: - Types
34: 
35:     struct MinimapDiffIndicator: Identifiable, Hashable {
36:         enum Kind: Hashable {
37:             case added
38:             case modified
39:             case deleted
40:         }
41: 
42:         var id = UUID()
43:         /// 0-based line range in the current `content`.
44:         var lineRange: Range<Int>
45:         var kind: Kind
46: 
47:         init(lineRange: Range<Int>, kind: Kind) {
48:             self.lineRange = lineRange
49:             self.kind = kind
50:         }
51:     }
52: 
53:     // MARK: - View
54: 
55:     var body: some View {
56:         GeometryReader { geometry in
57:             let size = geometry.size
58:             let minimapHeight = max(1, size.height)
59:             let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
60:             let lineCount = max(lines.count, 1)
61: 
62:             ZStack(alignment: .topLeading) {
63:                 // Background
64:                 Rectangle()
65:                     .fill(Color(white: 0.13))
66: 
67:                 // Syntax-colored code preview
68:                 Canvas { context, canvasSize in
69:                     drawMinimapPreview(
70:                         in: &context,
71:                         size: canvasSize,
72:                         lines: lines
73:                     )
74:                 }
75:                 .allowsHitTesting(false)
76: 
77:                 // Git diff indicators (thin left bars)
78:                 diffIndicatorsLayer(
79:                     minimapHeight: minimapHeight,
80:                     lineCount: lineCount
81:                 )
82:                 .allowsHitTesting(false)
83: 
84:                 // Visible region highlight
85:                 visibleRegionLayer(minimapHeight: minimapHeight)
86:                     .allowsHitTesting(false)
87:             }
88:             .frame(width: minimapWidth, height: minimapHeight)
89:             .clipShape(Rectangle())
90:             .contentShape(Rectangle())
91:             // Click-to-scroll + drag scrolling (DragGesture(minDistance: 0) captures taps too)
92:             .gesture(
93:                 DragGesture(minimumDistance: 0, coordinateSpace: .local)
94:                     .onChanged { value in
95:                         isInteracting = true
96:                         updateScroll(forMinimapY: value.location.y, minimapHeight: minimapHeight)
97:                     }
98:                     .onEnded { _ in
99:                         isInteracting = false
100:                     }
101:             )
102:         }
103:         .frame(width: minimapWidth)
104:     }
105: 
106:     // MARK: - Layers
107: 
108:     @ViewBuilder
109:     private func visibleRegionLayer(minimapHeight: CGFloat) -> some View {
110:         let height = visibleRegionHeight(minimapHeight: minimapHeight)
111:         let offset = visibleRegionOffset(minimapHeight: minimapHeight, visibleHeight: height)
112: 
113:         Rectangle()
114:             .fill(Color.accentColor.opacity(isInteracting ? 0.22 : 0.16))
115:             .overlay(
116:                 Rectangle()
117:                     .stroke(Color.accentColor.opacity(0.65), lineWidth: 1)
118:             )
119:             .frame(width: minimapWidth, height: height)
120:             .offset(y: offset)
121:     }
122: 
123:     @ViewBuilder
124:     private func diffIndicatorsLayer(minimapHeight: CGFloat, lineCount: Int) -> some View {
125:         // VS Code minimap diff markers are thin and pinned to the left.
126:         let barWidth: CGFloat = 2
127: 
128:         // Guard against division by zero
129:         if lineCount > 0 {
130:             ForEach(diffIndicators) { indicator in
131:                 let startLine = max(0, min(indicator.lineRange.lowerBound, lineCount - 1))
132:                 let endLineExclusive = max(startLine + 1, min(indicator.lineRange.upperBound, lineCount))
133: 
134:                 let startY = (CGFloat(startLine) / CGFloat(max(lineCount, 1))) * minimapHeight
135:                 let endY = (CGFloat(endLineExclusive) / CGFloat(max(lineCount, 1))) * minimapHeight
136:                 let height = max(2, endY - startY)
137: 
138:                 Rectangle()
139:                     .fill(diffColor(for: indicator.kind).opacity(0.95))
140:                     .frame(width: barWidth, height: height)
141:                     .offset(x: 0, y: startY)
142:             }
143:         }
144:     }
145: 
146:     // MARK: - Visible region math
147: 
148:     private func visibleRegionHeight(minimapHeight: CGFloat) -> CGFloat {
149:         guard totalContentHeight > 0 else { return 0 }
150:         let ratio = scrollViewHeight / totalContentHeight
151:         return minimapHeight * min(max(ratio, 0), 1.0)
152:     }
153: 
154:     private func visibleRegionOffset(minimapHeight: CGFloat, visibleHeight: CGFloat) -> CGFloat {
155:         let scrollable = max(0, totalContentHeight - scrollViewHeight)
156:         guard scrollable > 0 else { return 0 }
157: 
158:         let scrollRatio = min(max(scrollOffset / scrollable, 0), 1.0)
159:         return scrollRatio * max(0, minimapHeight - visibleHeight)
160:     }
161: 
162:     // MARK: - Interaction
163: 
164:     /// Requests scroll so that the main editor's visible region is centered around the minimap Y position.
165:     /// Uses callback to parent - minimap never directly controls editor scroll (prevents jitter).
166:     private func updateScroll(forMinimapY yPosition: CGFloat, minimapHeight: CGFloat) {
167:         guard totalContentHeight > 0 else { return }
168:         guard let onScrollRequested = onScrollRequested else { return }
169: 
170:         let clampedY = max(0, min(yPosition, minimapHeight))
171:         let ratio = (minimapHeight > 0) ? (clampedY / minimapHeight) : 0
172: 
173:         // Target a center position (VS Code behavior).
174:         let targetCenter = ratio * totalContentHeight
175:         let desiredOffset = targetCenter - (scrollViewHeight / 2)
176: 
177:         let maxOffset = max(0, totalContentHeight - scrollViewHeight)
178:         let newOffset = min(max(desiredOffset, 0), maxOffset)
179:         
180:         // Request scroll via callback - parent controls the actual scroll
181:         onScrollRequested(newOffset)
182:     }
183: 
184:     // MARK: - Rendering (Canvas)
185: 
186:     private func drawMinimapPreview(
187:         in context: inout GraphicsContext,
188:         size: CGSize,
189:         lines: [Substring]
190:     ) {
191:         let paddingX: CGFloat = 4
192:         let paddingY: CGFloat = 2
193: 
194:         let contentWidth = max(0, size.width - (paddingX * 2))
195:         let contentHeight = max(0, size.height - (paddingY * 2))
196: 
197:         guard contentWidth > 0, contentHeight > 0 else { return }
198: 
199:         let lineCount = max(lines.count, 1)
200:         
201:         // FIXED: Use fixed pixels per line (VS Code style) instead of stretching to fill
202:         // This ensures the minimap always shows a tiny preview regardless of file size
203:         let targetPixelsPerLine: CGFloat = 2.5
204:         let pixelsPerLine = targetPixelsPerLine
205:         
206:         // Calculate how many lines we can show in the minimap
207:         let visibleLines = Int(contentHeight / pixelsPerLine)
208:         
209:         // Calculate scroll offset to show the right portion of the document
210:         // Use scrollOffset and totalContentHeight to calculate current position
211:         let scrollRatio = totalContentHeight > 0 ? Double(scrollOffset) / Double(max(totalContentHeight - scrollViewHeight, 1)) : 0
212:         let startLine = max(0, Int(scrollRatio * Double(max(0, lineCount - visibleLines))))
213: 
214:         // Token-block mode (colored rectangles) - VS Code style minimap
215:         let minBarHeight: CGFloat = 1
216:         let barHeight = max(minBarHeight, pixelsPerLine)
217: 
218:         // Approximate "characters" across minimap width.
219:         let maxChars: CGFloat = 120
220:         let charWidth = contentWidth / maxChars


>>>TOOL search
{"query":"collapsedLines", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"isLineFolded(", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/*.swift"}
>>>END

>>>TOOL search
{"query":"toggleFold(fileId", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 5 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:72: @Published var collapsedLines: Set<Int> = []
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:673: return collapsedLines.contains(line)
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:756: return collapsedLines.count
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:779: collapsedLines.removeAll()
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:783: collapsedLines.insert(line)

---

[search]
No matches found for "isLineFolded("

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:518: foldingManager.toggleFold(fileId: fileId, line: lineIndex)
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:706: func toggleFold(fileId: String, line: Int) {


>>>TOOL search
{"query":"func toggleFold(at", "glob":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":520,"end_line":640}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:522: func toggleFold(at line: Int) {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 521-640 of 866)
────────────────────────────────────────
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
570:     /// Folds the region containing the given cursor line
571:     func foldAtLine(_ cursorLine: Int) {
572:         // Find the innermost region containing this line
573:         if let region = foldRegions.filter({ 
574:             cursorLine >= $0.startLine && cursorLine <= $0.endLine && !$0.isFolded
575:         }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
576:             collapseRegion(at: region.startLine)
577:         }
578:     }
579:     
580:     /// Unfolds the region containing the given cursor line
581:     func unfoldAtLine(_ cursorLine: Int) {
582:         // Find any folded region that starts at or contains this line
583:         if let region = foldRegions.first(where: { 
584:             $0.isFolded && ($0.startLine == cursorLine || (cursorLine >= $0.startLine && cursorLine <= $0.endLine))
585:         }) {
586:             expandRegion(at: region.startLine)
587:         }
588:     }
589:     
590:     /// Toggle fold at cursor line - convenience method
591:     func toggleFoldAtLine(_ cursorLine: Int) {
592:         // First check if we're on a fold start line
593:         if let region = foldRegions.first(where: { $0.startLine == cursorLine }) {
594:             toggleFold(at: region.startLine)
595:             return
596:         }
597:         
598:         // Otherwise find the innermost region containing this line
599:         if let region = foldRegions.filter({ 
600:             cursorLine >= $0.startLine && cursorLine <= $0.endLine
601:         }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
602:             toggleFold(at: region.startLine)
603:         }
604:     }
605:     
606:     // MARK: - Legacy/Convenience Methods (for keyboard shortcuts)
607:     
608:     /// Folds at the current line (uses line 0 as fallback - caller should use foldAtLine(_:) with actual cursor)
609:     func foldCurrentLine() {
610:         // This is called from keyboard shortcuts - fold at line 0 or first available region
611:         if let firstUnfolded = foldRegions.first(where: { !$0.isFolded }) {
612:             collapseRegion(at: firstUnfolded.startLine)
613:         }
614:     }
615:     
616:     /// Unfolds at the current line (uses line 0 as fallback - caller should use unfoldAtLine(_:) with actual cursor)
617:     func unfoldCurrentLine() {
618:         // This is called from keyboard shortcuts - unfold first folded region
619:         if let firstFolded = foldRegions.first(where: { $0.isFolded }) {
620:             expandRegion(at: firstFolded.startLine)
621:         }
622:     }
623:     
624:     /// Collapses all foldable regions
625:     func collapseAll() {
626:         for index in foldRegions.indices {
627:             foldRegions[index].isFolded = true
628:         }
629:         updateCollapsedLines()
630:         
631:         if let filePath = currentFilePath {
632:             saveFoldState(for: filePath)
633:         }
634:     }
635:     
636:     /// Collapses all regions of a specific type
637:     func collapseAll(ofType type: FoldRegion.FoldType) {
638:         for index in foldRegions.indices {
639:             if foldRegions[index].type == type {
640:                 foldRegions[index].isFolded = true


>>>TOOL search
{"query":"scrollPosition:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"@State private var scrollPosition", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"scrollPosition", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 16 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:403: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:455: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:51: var scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:61: scrollPosition: Int = 0,
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:167: scrollPosition: 0,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:24: let scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:271: scrollPosition: 0,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:12: let scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:15: @Binding var scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:36: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:71: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:88: scrollPosition: scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:491: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:569: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:495: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:547: scrollPosition: $scrollPosition,

---

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:403: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:491: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:495: @State private var scrollPosition: Int = 0

---

[search]
Found 30 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:403: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:436: scrollOffset: CGFloat(scrollPosition) * lineHeight,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:455: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:503: scrollOffset: CGFloat(scrollPosition) * lineHeight,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:510: scrollPosition = max(0, min(newLine, totalLines - 1))
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:521: currentLine: scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:495: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:537: .offset(y: -CGFloat(scrollPosition) * lineHeight)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:547: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:561: splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:568: scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:578: currentLine: scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:582: scrollPosition = line
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:596: scrollPosition = Int(newOffset / lineHeight)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:24: let scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:118: let visibleLineIndex = currentLineIndex - scrollPosition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:218: let visibleRange = scrollPosition...(scrollPosition + 50) // Assuming ~50 visible lines
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:271: scrollPosition: 0,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:12: let scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:43: if hint.line >= scrollPosition && hint.line <= (scrollPosition + maxVisibleLines) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:48: let y = textInsets.top + baselineAdjustment + (CGFloat(hint.line - scrollPosition) * lineHeight)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:15: @Binding var scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:36: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:52: self._scrollPosition = scrollPosition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:71: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:88: scrollPosition: scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:249: if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:252: context.coordinator.lastKnownScrollPosition = scrollPosition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:253: context.coordinator.scrollToLine(scrollPosition, in: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:445: // If we update parent.scrollPosition async, there's a race where


>>>TOOL search
{"query":"collapsedLines", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"CodeFoldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"isLineFolded", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END


---

## 🔧 TOOL RESULTS

[search]
No matches found for "collapsedLines"

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:622: CodeFoldingManager.shared.foldCurrentLine()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:626: CodeFoldingManager.shared.unfoldCurrentLine()

---

[search]
No matches found for "isLineFolded"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":8,"end_line":110}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 9-110 of 2011)
────────────────────────────────────────
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


>>>TOOL search
{"query":"class EditorPane", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"@Published var scrollOffset", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"class EditorPane", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"@Published var scrollOffset", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:25: class EditorPane: ObservableObject, Identifiable {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:25: class EditorPane: ObservableObject, Identifiable {

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:29: @Published var scrollOffset: CGFloat = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:29: @Published var scrollOffset: CGFloat = 0


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":1,"end_line":140}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":140,"end_line":240}
>>>END


---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 2-140 of 774)
────────────────────────────────────────
2: //  SplitEditorView.swift
3: //  VSCodeiPadOS
4: //
5: //  Split editor panes implementation
6: //  - Split right/down
7: //  - Drag tabs to create splits
8: //  - Independent panes with own tabs
9: //  - Resizable with drag handles
10: //  - Close split buttons
11: //  - Sync scroll option
12: //
13: 
14: import SwiftUI
15: 
16: // MARK: - Split Direction
17: 
18: enum SplitDirection: String, CaseIterable {
19:     case horizontal // side by side
20:     case vertical   // top and bottom
21: }
22: 
23: // MARK: - Editor Pane Model
24: 
25: class EditorPane: ObservableObject, Identifiable {
26:     let id: UUID
27:     @Published var tabs: [Tab]
28:     @Published var activeTabId: UUID?
29:     @Published var scrollOffset: CGFloat = 0
30:     
31:     var activeTab: Tab? {
32:         tabs.first { $0.id == activeTabId }
33:     }
34:     
35:     init(id: UUID = UUID(), tabs: [Tab] = [], activeTabId: UUID? = nil) {
36:         self.id = id
37:         self.tabs = tabs
38:         self.activeTabId = activeTabId ?? tabs.first?.id
39:     }
40:     
41:     func addTab(_ tab: Tab) {
42:         // Check if already exists
43:         if let existing = tabs.first(where: { $0.url == tab.url && tab.url != nil }) {
44:             activeTabId = existing.id
45:             return
46:         }
47:         tabs.append(tab)
48:         activeTabId = tab.id
49:     }
50:     
51:     func closeTab(id: UUID) {
52:         guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
53:         tabs.remove(at: index)
54:         
55:         if activeTabId == id {
56:             if tabs.isEmpty {
57:                 activeTabId = nil
58:             } else if index >= tabs.count {
59:                 activeTabId = tabs[tabs.count - 1].id
60:             } else {
61:                 activeTabId = tabs[index].id
62:             }
63:         }
64:     }
65:     
66:     func selectTab(id: UUID) {
67:         activeTabId = id
68:     }
69:     
70:     func updateTabContent(_ content: String) {
71:         guard let index = tabs.firstIndex(where: { $0.id == activeTabId }) else { return }
72:         tabs[index].content = content
73:         if tabs[index].url != nil {
74:             tabs[index].isUnsaved = true
75:         }
76:     }
77: }
78: 
79: // MARK: - Split Editor Manager
80: 
81: class SplitEditorManager: ObservableObject {
82:     @Published var panes: [EditorPane] = []
83:     @Published var splitDirection: SplitDirection = .horizontal
84:     @Published var splitRatios: [CGFloat] = [1.0]
85:     @Published var activePaneId: UUID?
86:     @Published var syncScroll: Bool = false
87:     
88:     var activePane: EditorPane? {
89:         panes.first { $0.id == activePaneId }
90:     }
91:     
92:     init() {
93:         let initialPane = EditorPane()
94:         panes = [initialPane]
95:         activePaneId = initialPane.id
96:         splitRatios = [1.0]
97:     }
98:     
99:     // Initialize with EditorCore's tabs
100:     func initializeWithTabs(_ tabs: [Tab], activeTabId: UUID?) {
101:         if panes.isEmpty {
102:             let pane = EditorPane(tabs: tabs, activeTabId: activeTabId)
103:             panes = [pane]
104:             activePaneId = pane.id
105:             splitRatios = [1.0]
106:         } else if let firstPane = panes.first, firstPane.tabs.isEmpty {
107:             firstPane.tabs = tabs
108:             firstPane.activeTabId = activeTabId
109:         }
110:     }
111:     
112:     // MARK: - Split Operations
113:     
114:     func splitPane(direction: SplitDirection, fromPaneId: UUID? = nil) {
115:         let sourcePane = fromPaneId.flatMap { id in panes.first { $0.id == id } } ?? activePane
116:         guard let source = sourcePane else { return }
117:         
118:         // Create new pane with duplicate of active tab (or empty)
119:         var newTabs: [Tab] = []
120:         if let activeTab = source.activeTab {
121:             let duplicateTab = Tab(
122:                 fileName: activeTab.fileName,
123:                 content: activeTab.content,
124:                 language: activeTab.language,
125:                 url: activeTab.url,
126:                 isUnsaved: activeTab.isUnsaved
127:             )
128:             newTabs = [duplicateTab]
129:         }
130:         
131:         let newPane = EditorPane(tabs: newTabs, activeTabId: newTabs.first?.id)
132:         
133:         self.splitDirection = direction
134:         panes.append(newPane)
135:         
136:         // Recalculate ratios equally
137:         let ratio = 1.0 / CGFloat(panes.count)
138:         splitRatios = Array(repeating: ratio, count: panes.count)
139:         
140:         activePaneId = newPane.id

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 141-240 of 774)
────────────────────────────────────────
141:     }
142:     
143:     func closePane(id: UUID) {
144:         guard panes.count > 1 else { return } // Keep at least one pane
145:         guard let index = panes.firstIndex(where: { $0.id == id }) else { return }
146:         
147:         panes.remove(at: index)
148:         splitRatios.remove(at: index)
149:         
150:         // Normalize ratios
151:         let total = splitRatios.reduce(0, +)
152:         if total > 0 {
153:             splitRatios = splitRatios.map { $0 / total }
154:         } else {
155:             splitRatios = Array(repeating: 1.0 / CGFloat(panes.count), count: panes.count)
156:         }
157:         
158:         // Update active pane
159:         if activePaneId == id {
160:             activePaneId = panes.first?.id
161:         }
162:     }
163:     
164:     func moveTabToPane(tab: Tab, fromPaneId: UUID, toPaneId: UUID) {
165:         guard let fromPane = panes.first(where: { $0.id == fromPaneId }),
166:               let toPane = panes.first(where: { $0.id == toPaneId }) else { return }
167:         
168:         fromPane.closeTab(id: tab.id)
169:         
170:         // Create new tab (since Tab is a struct)
171:         let newTab = Tab(
172:             fileName: tab.fileName,
173:             content: tab.content,
174:             language: tab.language,
175:             url: tab.url,
176:             isUnsaved: tab.isUnsaved
177:         )
178:         toPane.addTab(newTab)
179:     }
180:     
181:     func moveTabToNewSplit(tab: Tab, fromPaneId: UUID, direction: SplitDirection) {
182:         guard let fromPane = panes.first(where: { $0.id == fromPaneId }) else { return }
183:         
184:         fromPane.closeTab(id: tab.id)
185:         
186:         let newTab = Tab(
187:             fileName: tab.fileName,
188:             content: tab.content,
189:             language: tab.language,
190:             url: tab.url,
191:             isUnsaved: tab.isUnsaved
192:         )
193:         
194:         let newPane = EditorPane(tabs: [newTab], activeTabId: newTab.id)
195:         self.splitDirection = direction
196:         panes.append(newPane)
197:         
198:         let ratio = 1.0 / CGFloat(panes.count)
199:         splitRatios = Array(repeating: ratio, count: panes.count)
200:         activePaneId = newPane.id
201:     }
202:     
203:     func updateRatio(at index: Int, delta: CGFloat, totalSize: CGFloat) {
204:         guard index < splitRatios.count - 1 else { return }
205:         
206:         let deltaRatio = delta / totalSize
207:         let minRatio: CGFloat = 0.15
208:         
209:         let newRatio1 = splitRatios[index] + deltaRatio
210:         let newRatio2 = splitRatios[index + 1] - deltaRatio
211:         
212:         if newRatio1 >= minRatio && newRatio2 >= minRatio {
213:             splitRatios[index] = newRatio1
214:             splitRatios[index + 1] = newRatio2
215:         }
216:     }
217:     
218:     // Sync scroll across panes
219:     func syncScrollOffset(_ offset: CGFloat, fromPaneId: UUID) {
220:         guard syncScroll else { return }
221:         for pane in panes where pane.id != fromPaneId {
222:             pane.scrollOffset = offset
223:         }
224:     }
225: }
226: 
227: // MARK: - Split Editor View
228: 
229: struct SplitEditorView: View {
230:     @ObservedObject var splitManager: SplitEditorManager
231:     @ObservedObject var editorCore: EditorCore
232:     
233:     var body: some View {
234:         GeometryReader { geometry in
235:             if splitManager.panes.count == 1 {
236:                 // Single pane - no split
237:                 if let pane = splitManager.panes.first {
238:                     SinglePaneView(pane: pane, splitManager: splitManager, editorCore: editorCore)
239:                 }
240:             } else {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":480,"end_line":620}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":560,"end_line":660}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":586,"end_line":646}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":504,"end_line":570}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":586,"end_line":646}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":504,"end_line":570}
>>>END


---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 481-620 of 774)
────────────────────────────────────────
481: // MARK: - Pane Editor View
482: 
483: struct PaneEditorView: View {
484:     @ObservedObject var pane: EditorPane
485:     let tab: Tab
486:     @ObservedObject var splitManager: SplitEditorManager
487:     @ObservedObject var editorCore: EditorCore
488:     @ObservedObject private var debugManager = DebugManager.shared
489:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
490:     @State private var text: String = ""
491:     @State private var scrollPosition: Int = 0
492:     @State private var totalLines: Int = 1
493:     @State private var visibleLines: Int = 20
494:     @State private var currentLineNumber: Int = 1
495:     @State private var currentColumn: Int = 1
496:     @State private var lineHeight: CGFloat = 17
497:     @State private var requestedLineSelection: Int? = nil
498: 
499:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
500:     
501:     private var fileId: String { tab.url?.path ?? tab.fileName }
502:     
503:     var body: some View {
504:         GeometryReader { geometry in
505:             HStack(spacing: 0) {
506:                 // Line numbers + breakpoints + code folding (gutter)
507:                 //
508:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
509:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
510:                 if lineNumbersStyle != "off" {
511:                     ScrollView(showsIndicators: false) {
512:                         VStack(alignment: .trailing, spacing: 0) {
513:                             ForEach(0..<totalLines, id: \ .self) { lineIndex in
514:                                 HStack(spacing: 2) {
515:                                     // Fold chevron icon
516:                                     if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
517:                                         Button(action: { 
518:                                             foldingManager.toggleFold(fileId: fileId, line: lineIndex)
519:                                         }) {
520:                                             Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")
521:                                                 .font(.system(size: 10, weight: .regular))
522:                                                 .foregroundColor(.secondary.opacity(0.8))
523:                                                 .frame(width: 12, height: lineHeight)
524:                                         }
525:                                         .buttonStyle(.plain)
526:                                     } else {
527:                                         // Spacer for alignment
528:                                         Spacer()
529:                                             .frame(width: 12)
530:                                     }
531:                                     
532:                                     // Breakpoint indicator
533:                                     Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
534:                                         Circle()
535:                                             .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
536:                                             .overlay(
537:                                                 Circle()
538:                                                     .stroke(Color.red.opacity(0.6), lineWidth: 1)
539:                                                     .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
540:                                             )
541:                                             .frame(width: 10, height: 10)
542:                                     }
543:                                     .buttonStyle(.plain)
544:                                     .frame(width: 14, height: lineHeight)
545: 
546:                                     Text(displayText(for: lineIndex))
547:                                         .font(.system(size: 12, design: .monospaced))
548:                                         .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
549:                                         .frame(height: lineHeight)
550:                                         .contentShape(Rectangle())
551:                                         .onTapGesture {
552:                                             requestedLineSelection = lineIndex
553:                                         }
554:                                 }
555:                                 .frame(maxWidth: .infinity, alignment: .trailing)
556:                             }
557:                         }
558:                         .padding(.trailing, 4)
559:                         .offset(y: -CGFloat(scrollPosition) * lineHeight)
560:                     }
561:                     .frame(width: 70)
562:                     .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
563:                 }
564: 
565:                 // Editor
566:                 SyntaxHighlightingTextView(
567:                     text: $text,
568:                     filename: tab.fileName,
569:                     scrollPosition: $scrollPosition,
570:                     totalLines: $totalLines,
571:                     visibleLines: $visibleLines,
572:                     currentLineNumber: $currentLineNumber,
573:                     currentColumn: $currentColumn,
574:                     lineHeight: $lineHeight,
575:                     isActive: splitManager.activePaneId == pane.id,
576:                     editorCore: editorCore,
577:                     requestedLineSelection: $requestedLineSelection
578:                 )
579:                 .onChange(of: text) { newValue in
580:                     pane.updateTabContent(newValue)
581:                     
582:                     // Sync scroll if enabled
583:                     if splitManager.syncScroll {
584:                         splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
585:                     }
586:                 }
587:                 
588:                 // Mini minimap
589:                 MinimapView(
590:                     content: text,
591:                     scrollOffset: CGFloat(scrollPosition) * lineHeight,
592:                     scrollViewHeight: geometry.size.height,
593:                     totalContentHeight: CGFloat(totalLines) * lineHeight
594:                 )
595:                 .frame(width: 60)
596:             }
597:             // Sticky Header Overlay (FEAT-040)
598:             StickyHeaderView(
599:                 text: text,
600:                 currentLine: scrollPosition, // Using scrollPosition as approximate top line
601:                 theme: ThemeManager.shared.currentTheme,
602:                 lineHeight: lineHeight,
603:                 onSelect: { line in
604:                     requestedLineSelection = line
605:                 }
606:             )
607:             .padding(.leading, 70) // Offset for line numbers + folding icons
608:             .padding(.trailing, 60) // Offset for minimap
609:             
610:             // Peek Definition Overlay
611:             if let peekState = editorCore.peekState, editorCore.activeTabId == tab.id {
612:                  // Calculate simplified position: center of screen for now, but conceptually "inline"
613:                  // To make it truly inline, we'd need more complex geometry, but overlay is a good start.
614:                  VStack {
615:                      Spacer()
616:                          .frame(height: max(0, CGFloat(peekState.sourceLine - scrollPosition) * lineHeight + lineHeight + 20))
617:                      
618:                      PeekDefinitionView(
619:                          editorCore: editorCore,
620:                          targetFile: peekState.file,

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 561-660 of 1064)
────────────────────────────────────────
561:         .onChange(of: currentLineNumber) { line in
562:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
563:         }
564:         .onChange(of: currentColumn) { col in
565:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
566:         }
567:         .onAppear {
568:             findViewModel.editorCore = editorCore
569:         }
570:     }
571:     
572:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
573: }
574: 
575: // MARK: - Line Numbers with Folding
576: 
577: struct LineNumbersWithFolding: View {
578:     let fileId: String
579:     let totalLines: Int
580:     let currentLine: Int
581:     let scrollOffset: CGFloat
582:     let lineHeight: CGFloat
583:     @Binding var requestedLineSelection: Int?
584:     @ObservedObject var foldingManager: CodeFoldingManager
585:     @ObservedObject private var debugManager = DebugManager.shared
586:     let theme: Theme
587: 
588:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
589: 
590:     var body: some View {
591:         ScrollView(showsIndicators: false) {
592:             VStack(alignment: .trailing, spacing: 0) {
593:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
594:                     if !foldingManager.isLineFolded(line: lineIndex) {
595:                         HStack(spacing: 2) {
596:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
597:                                 Circle()
598:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
599:                                     .overlay(
600:                                         Circle()
601:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
602:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
603:                                     )
604:                                     .frame(width: 10, height: 10)
605:                                     .padding(.leading, 2)
606:                             }
607:                             .buttonStyle(.plain)
608:                             .frame(width: 14, height: lineHeight)
609: 
610:                             if foldingManager.isFoldable(line: lineIndex) {
611:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
612:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
613:                                         .font(.system(size: 8))
614:                                         .foregroundColor(theme.lineNumber)
615:                                 }
616:                                 .buttonStyle(.plain)
617:                                 .frame(width: 14, height: lineHeight)
618:                             } else {
619:                                 Spacer().frame(width: 14)
620:                             }
621: 
622:                             Text(displayText(for: lineIndex))
623:                                 .font(.system(size: 12, design: .monospaced))
624:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
625:                                 .frame(height: lineHeight)
626:                                 .contentShape(Rectangle())
627:                                 .onTapGesture {
628:                                     // FEAT-041: click line number selects entire line
629:                                     requestedLineSelection = lineIndex
630:                                 }
631:                         }
632:                         .frame(maxWidth: .infinity, alignment: .trailing)
633:                         .padding(.trailing, 4)
634:                     }
635:                 }
636:             }
637:             .offset(y: -scrollOffset)
638:         }
639:     }
640: 
641:     private func displayText(for lineIndex: Int) -> String {
642:         switch lineNumbersStyle {
643:         case "relative":
644:             // VS Code-style: current line shows absolute, others show relative distance
645:             let lineNumber = lineIndex + 1
646:             if lineNumber == currentLine { return "\(lineNumber)" }
647:             return "\(abs(lineNumber - currentLine))"
648: 
649:         case "interval":
650:             let lineNumber = lineIndex + 1
651:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
652: 
653:         default:
654:             return "\(lineIndex + 1)"
655:         }
656:     }
657: }
658: 
659: // MARK: - Autocomplete Popup
660: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 587-646 of 1064)
────────────────────────────────────────
587: 
588:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
589: 
590:     var body: some View {
591:         ScrollView(showsIndicators: false) {
592:             VStack(alignment: .trailing, spacing: 0) {
593:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
594:                     if !foldingManager.isLineFolded(line: lineIndex) {
595:                         HStack(spacing: 2) {
596:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
597:                                 Circle()
598:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
599:                                     .overlay(
600:                                         Circle()
601:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
602:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
603:                                     )
604:                                     .frame(width: 10, height: 10)
605:                                     .padding(.leading, 2)
606:                             }
607:                             .buttonStyle(.plain)
608:                             .frame(width: 14, height: lineHeight)
609: 
610:                             if foldingManager.isFoldable(line: lineIndex) {
611:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
612:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
613:                                         .font(.system(size: 8))
614:                                         .foregroundColor(theme.lineNumber)
615:                                 }
616:                                 .buttonStyle(.plain)
617:                                 .frame(width: 14, height: lineHeight)
618:                             } else {
619:                                 Spacer().frame(width: 14)
620:                             }
621: 
622:                             Text(displayText(for: lineIndex))
623:                                 .font(.system(size: 12, design: .monospaced))
624:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
625:                                 .frame(height: lineHeight)
626:                                 .contentShape(Rectangle())
627:                                 .onTapGesture {
628:                                     // FEAT-041: click line number selects entire line
629:                                     requestedLineSelection = lineIndex
630:                                 }
631:                         }
632:                         .frame(maxWidth: .infinity, alignment: .trailing)
633:                         .padding(.trailing, 4)
634:                     }
635:                 }
636:             }
637:             .offset(y: -scrollOffset)
638:         }
639:     }
640: 
641:     private func displayText(for lineIndex: Int) -> String {
642:         switch lineNumbersStyle {
643:         case "relative":
644:             // VS Code-style: current line shows absolute, others show relative distance
645:             let lineNumber = lineIndex + 1
646:             if lineNumber == currentLine { return "\(lineNumber)" }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 505-570 of 774)
────────────────────────────────────────
505:             HStack(spacing: 0) {
506:                 // Line numbers + breakpoints + code folding (gutter)
507:                 //
508:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
509:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
510:                 if lineNumbersStyle != "off" {
511:                     ScrollView(showsIndicators: false) {
512:                         VStack(alignment: .trailing, spacing: 0) {
513:                             ForEach(0..<totalLines, id: \ .self) { lineIndex in
514:                                 HStack(spacing: 2) {
515:                                     // Fold chevron icon
516:                                     if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
517:                                         Button(action: { 
518:                                             foldingManager.toggleFold(fileId: fileId, line: lineIndex)
519:                                         }) {
520:                                             Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")
521:                                                 .font(.system(size: 10, weight: .regular))
522:                                                 .foregroundColor(.secondary.opacity(0.8))
523:                                                 .frame(width: 12, height: lineHeight)
524:                                         }
525:                                         .buttonStyle(.plain)
526:                                     } else {
527:                                         // Spacer for alignment
528:                                         Spacer()
529:                                             .frame(width: 12)
530:                                     }
531:                                     
532:                                     // Breakpoint indicator
533:                                     Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
534:                                         Circle()
535:                                             .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
536:                                             .overlay(
537:                                                 Circle()
538:                                                     .stroke(Color.red.opacity(0.6), lineWidth: 1)
539:                                                     .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
540:                                             )
541:                                             .frame(width: 10, height: 10)
542:                                     }
543:                                     .buttonStyle(.plain)
544:                                     .frame(width: 14, height: lineHeight)
545: 
546:                                     Text(displayText(for: lineIndex))
547:                                         .font(.system(size: 12, design: .monospaced))
548:                                         .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
549:                                         .frame(height: lineHeight)
550:                                         .contentShape(Rectangle())
551:                                         .onTapGesture {
552:                                             requestedLineSelection = lineIndex
553:                                         }
554:                                 }
555:                                 .frame(maxWidth: .infinity, alignment: .trailing)
556:                             }
557:                         }
558:                         .padding(.trailing, 4)
559:                         .offset(y: -CGFloat(scrollPosition) * lineHeight)
560:                     }
561:                     .frame(width: 70)
562:                     .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
563:                 }
564: 
565:                 // Editor
566:                 SyntaxHighlightingTextView(
567:                     text: $text,
568:                     filename: tab.fileName,
569:                     scrollPosition: $scrollPosition,
570:                     totalLines: $totalLines,


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":1,"end_line":40}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 2-40 of 1064)
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


>>>TOOL get_errors
{}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":10,"end_line":80}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":426,"end_line":470}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":392,"end_line":520}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":520,"end_line":660}
>>>END>>>END

---

## 🔧 TOOL RESULTS

[get_errors]
✅ No errors or warnings

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 11-80 of 2012)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 427-470 of 2012)
────────────────────────────────────────
427:             DispatchQueue.main.async {
428:                 self.parent.totalLines = max(1, lines.count)
429:             }
430:         }
431:         
432:         func updateCursorPosition(_ textView: UITextView) {
433:             guard let selectedRange = textView.selectedTextRange else { return }
434:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
435:              
436:              let text = textView.text ?? ""
437:              let prefix = String(text.prefix(cursorPosition))
438:              let lines = prefix.components(separatedBy: .newlines)
439:              
440:              let lineNumber = lines.count
441:              let column = (lines.last?.count ?? 0) + 1
442:              
443:              DispatchQueue.main.async {
444:                  self.parent.currentLineNumber = lineNumber
445:                  self.parent.currentColumn = column
446:                  self.parent.cursorIndex = cursorPosition
447:              }
448:         }
449:         
450:         func updateScrollPosition(_ textView: UITextView) {
451:             guard let font = textView.font else { return }
452:             let lineHeight = font.lineHeight
453:             let scrollOffset = textView.contentOffset.y
454:             let line = Int(scrollOffset / lineHeight)
455:             
456:             // Update both synchronously to prevent feedback loop:
457:             // If we update parent.scrollPosition async, there's a race where
458:             // updateUIView sees old binding value != lastKnownScrollPosition
459:             // and scrolls back to the old position, causing jaggy scrolling.
460:             lastKnownScrollPosition = line
461:             parent.scrollPosition = line
462:         }
463:         
464:         func scrollToLine(_ line: Int, in textView: UITextView) {
465:             guard !isUpdatingFromMinimap else { return }
466:             isUpdatingFromMinimap = true
467:             
468:             let lines = textView.text.components(separatedBy: .newlines)
469:             guard line >= 0 && line < lines.count else {
470:                 isUpdatingFromMinimap = false

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 393-520 of 1064)
────────────────────────────────────────
393: 
394: // MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
395: 
396: struct IDEEditorView: View {
397:     @ObservedObject var editorCore: EditorCore
398:     let tab: Tab
399:     let theme: Theme
400: 
401:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
402:     @State private var text: String = ""
403:     @State private var scrollPosition: Int = 0
404:     @State private var totalLines: Int = 1
405:     @State private var visibleLines: Int = 20
406:     @State private var currentLineNumber: Int = 1
407:     @State private var currentColumn: Int = 1
408:     @State private var cursorIndex: Int = 0
409:     @State private var lineHeight: CGFloat = 17
410:     @State private var requestedCursorIndex: Int? = nil
411:     @State private var requestedLineSelection: Int? = nil
412: 
413:     @StateObject private var autocomplete = AutocompleteManager()
414:     @State private var showAutocomplete = false
415:     @StateObject private var foldingManager = CodeFoldingManager()
416:     @StateObject private var findViewModel = FindViewModel()
417:     
418:     var body: some View {
419:         VStack(spacing: 0) {
420:             // Find/Replace bar
421:             if editorCore.showSearch {
422:                 FindReplaceView(viewModel: findViewModel)
423:                     .background(theme.tabBarBackground)
424:             }
425:             
426:             BreadcrumbsView(editorCore: editorCore, tab: tab)
427:             
428:             GeometryReader { geometry in
429:                 ZStack(alignment: .topLeading) {
430:                 HStack(spacing: 0) {
431:                     if lineNumbersStyle != "off" {
432:                         LineNumbersWithFolding(
433:                             fileId: tab.url?.path ?? tab.fileName,
434:                             totalLines: totalLines,
435:                             currentLine: currentLineNumber,
436:                             scrollOffset: CGFloat(scrollPosition) * lineHeight,
437:                             lineHeight: lineHeight,
438:                             requestedLineSelection: $requestedLineSelection,
439:                             foldingManager: foldingManager,
440:                             theme: theme
441:                         )
442:                         .frame(width: 60)
443:                         .background(theme.sidebarBackground.opacity(0.5))
444:                     }
445:                     
446:                     if tab.fileName.hasSuffix(".json") {
447:                         // JSON Tree View for .json files
448:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
449:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
450:                             .background(theme.editorBackground)
451:                     } else {
452:                         SyntaxHighlightingTextView(
453:                             text: $text,
454:                             filename: tab.fileName,
455:                             scrollPosition: $scrollPosition,
456:                             totalLines: $totalLines,
457:                             visibleLines: $visibleLines,
458:                             currentLineNumber: $currentLineNumber,
459:                             currentColumn: $currentColumn,
460:                             cursorIndex: $cursorIndex,
461:                             lineHeight: $lineHeight,
462:                             isActive: true,
463:                             fontSize: editorCore.editorFontSize,
464:                             requestedLineSelection: $requestedLineSelection,
465:                             requestedCursorIndex: $requestedCursorIndex,
466:                             onAcceptAutocomplete: {
467:                                 guard showAutocomplete else { return false }
468:                                 var tempText = text
469:                                 var tempCursor = cursorIndex
470:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
471:                                 if tempText != text {
472:                                     text = tempText
473:                                     cursorIndex = tempCursor
474:                                     requestedCursorIndex = tempCursor
475:                                     showAutocomplete = false
476:                                     return true
477:                                 }
478:                                 return false
479:                             },
480:                             onDismissAutocomplete: {
481:                                 guard showAutocomplete else { return false }
482:                                 autocomplete.hideSuggestions()
483:                                 showAutocomplete = false
484:                                 return true
485:                             }
486:                         )
487:                         .onChange(of: text) { newValue in
488:                             editorCore.updateActiveTabContent(newValue)
489:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
490:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
491:                             showAutocomplete = autocomplete.showSuggestions
492:                             foldingManager.detectFoldableRegions(in: newValue)
493:                         }
494:                         .onChange(of: cursorIndex) { newCursor in
495:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
496:                             showAutocomplete = autocomplete.showSuggestions
497:                         }
498:                     }
499:                     
500:                     if !tab.fileName.hasSuffix(".json") {
501:                         MinimapView(
502:                             content: text,
503:                             scrollOffset: CGFloat(scrollPosition) * lineHeight,
504:                             scrollViewHeight: geometry.size.height,
505:                             totalContentHeight: CGFloat(totalLines) * lineHeight,
506:                             onScrollRequested: { newOffset in
507:                                 // Minimap requested scroll - update editor position
508:                                 // Convert back from pixels to line number
509:                                 let newLine = Int(newOffset / lineHeight)
510:                                 scrollPosition = max(0, min(newLine, totalLines - 1))
511:                             }
512:                         )
513:                         .frame(width: 80)
514:                     }
515:                 }
516:                 .background(theme.editorBackground)
517: 
518:                 // Sticky Header Overlay (FEAT-040)
519:                 StickyHeaderView(
520:                     text: text,

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 521-660 of 1064)
────────────────────────────────────────
521:                     currentLine: scrollPosition,
522:                     theme: theme,
523:                     lineHeight: lineHeight,
524:                     onSelect: { line in
525:                         requestedLineSelection = line
526:                     }
527:                 )
528:                 .padding(.leading, lineNumbersStyle != "off" ? 60 : 0)
529:                 .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
530: 
531:                 if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
532:                     AutocompletePopup(
533:                         suggestions: autocomplete.suggestionItems,
534:                         selectedIndex: autocomplete.selectedIndex,
535:                         theme: theme
536:                     ) { index in
537:                         autocomplete.selectedIndex = index
538:                         var tempText = text
539:                         var tempCursor = cursorIndex
540:                         autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
541:                         if tempText != text {
542:                             text = tempText
543:                             cursorIndex = tempCursor
544:                             requestedCursorIndex = tempCursor
545:                         }
546:                         showAutocomplete = false
547:                     }
548:                     .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
549:                 }
550:             }
551:         }
552:         }
553:         .onAppear {
554:             text = tab.content
555:             foldingManager.detectFoldableRegions(in: text)
556:         }
557:         .onChange(of: tab.id) { _ in
558:             text = tab.content
559:             foldingManager.detectFoldableRegions(in: text)
560:         }
561:         .onChange(of: currentLineNumber) { line in
562:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
563:         }
564:         .onChange(of: currentColumn) { col in
565:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
566:         }
567:         .onAppear {
568:             findViewModel.editorCore = editorCore
569:         }
570:     }
571:     
572:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
573: }
574: 
575: // MARK: - Line Numbers with Folding
576: 
577: struct LineNumbersWithFolding: View {
578:     let fileId: String
579:     let totalLines: Int
580:     let currentLine: Int
581:     let scrollOffset: CGFloat
582:     let lineHeight: CGFloat
583:     @Binding var requestedLineSelection: Int?
584:     @ObservedObject var foldingManager: CodeFoldingManager
585:     @ObservedObject private var debugManager = DebugManager.shared
586:     let theme: Theme
587: 
588:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
589: 
590:     var body: some View {
591:         ScrollView(showsIndicators: false) {
592:             VStack(alignment: .trailing, spacing: 0) {
593:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
594:                     if !foldingManager.isLineFolded(line: lineIndex) {
595:                         HStack(spacing: 2) {
596:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
597:                                 Circle()
598:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
599:                                     .overlay(
600:                                         Circle()
601:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
602:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
603:                                     )
604:                                     .frame(width: 10, height: 10)
605:                                     .padding(.leading, 2)
606:                             }
607:                             .buttonStyle(.plain)
608:                             .frame(width: 14, height: lineHeight)
609: 
610:                             if foldingManager.isFoldable(line: lineIndex) {
611:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
612:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
613:                                         .font(.system(size: 8))
614:                                         .foregroundColor(theme.lineNumber)
615:                                 }
616:                                 .buttonStyle(.plain)
617:                                 .frame(width: 14, height: lineHeight)
618:                             } else {
619:                                 Spacer().frame(width: 14)
620:                             }
621: 
622:                             Text(displayText(for: lineIndex))
623:                                 .font(.system(size: 12, design: .monospaced))
624:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
625:                                 .frame(height: lineHeight)
626:                                 .contentShape(Rectangle())
627:                                 .onTapGesture {
628:                                     // FEAT-041: click line number selects entire line
629:                                     requestedLineSelection = lineIndex
630:                                 }
631:                         }
632:                         .frame(maxWidth: .infinity, alignment: .trailing)
633:                         .padding(.trailing, 4)
634:                     }
635:                 }
636:             }
637:             .offset(y: -scrollOffset)
638:         }
639:     }
640: 
641:     private func displayText(for lineIndex: Int) -> String {
642:         switch lineNumbersStyle {
643:         case "relative":
644:             // VS Code-style: current line shows absolute, others show relative distance
645:             let lineNumber = lineIndex + 1
646:             if lineNumber == currentLine { return "\(lineNumber)" }
647:             return "\(abs(lineNumber - currentLine))"
648: 
649:         case "interval":
650:             let lineNumber = lineIndex + 1
651:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
652: 
653:         default:
654:             return "\(lineIndex + 1)"
655:         }
656:     }
657: }
658: 
659: // MARK: - Autocomplete Popup
660: 


>>>TOOL search
{"query":"CodeFoldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"CodeFoldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/*.swift"}
>>>END

>>>TOOL search
{"query":"isLineFolded", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"CodeFoldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"CodeFoldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/*.swift"}
>>>END

>>>TOOL search
{"query":"isLineFolded", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:632: CodeFoldingManager.shared.foldCurrentLine()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:636: CodeFoldingManager.shared.unfoldCurrentLine()

---

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:632: CodeFoldingManager.shared.foldCurrentLine()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:636: CodeFoldingManager.shared.unfoldCurrentLine()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:489: @ObservedObject private var foldingManager = CodeFoldingManager.shared

---

[search]
No matches found for "isLineFolded"


>>>TOOL search
{"query":"foldRegions", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"collapsed", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"isFold", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "foldRegions"

---

[search]
No matches found for "collapsed"

---

[search]
No matches found for "isFold"


>>>TOOL search
{"query":"collapsedLines", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/*.swift"}
>>>END

>>>TOOL search
{"query":"fold", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/EditorTextView.swift"}
>>>END

>>>TOOL search
{"query":"class EditorTextView", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "collapsedLines"

---

[search]
No matches found for "fold"

---

[search]
No matches found for "class EditorTextView"


>>>TOOL search
{"query":"EditorTextView", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:109: let textView = EditorTextView()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:218: if let editorView = textView as? EditorTextView {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:370: (textView as? EditorTextView)?.setNeedsDisplay()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:787: class EditorTextView: UITextView {


>>>TOOL search
{"query":"\\ .self", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"id: \\ .self", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"ForEach(0..<totalLines, id:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:513: ForEach(0..<totalLines, id: \ .self) { lineIndex in

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:513: ForEach(0..<totalLines, id: \ .self) { lineIndex in

---

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:593: ForEach(0..<totalLines, id: \.self) { lineIndex in
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:513: ForEach(0..<totalLines, id: \.self) { lineIndex in
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:513: ForEach(0..<totalLines, id: \ .self) { lineIndex in


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":10,"end_line":60}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":420,"end_line":455}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift","start_line":488,"end_line":565}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 11-60 of 2051)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 421-455 of 2051)
────────────────────────────────────────
421:             
422:             updateScrollPosition(textView)
423:         }
424:         
425:         func updateLineCount(_ textView: UITextView) {
426:             let lines = textView.text.components(separatedBy: .newlines)
427:             DispatchQueue.main.async {
428:                 self.parent.totalLines = max(1, lines.count)
429:             }
430:         }
431:         
432:         func updateCursorPosition(_ textView: UITextView) {
433:             guard let selectedRange = textView.selectedTextRange else { return }
434:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
435:              
436:              let text = textView.text ?? ""
437:              let prefix = String(text.prefix(cursorPosition))
438:              let lines = prefix.components(separatedBy: .newlines)
439:              
440:              let lineNumber = lines.count
441:              let column = (lines.last?.count ?? 0) + 1
442:              
443:              DispatchQueue.main.async {
444:                  self.parent.currentLineNumber = lineNumber
445:                  self.parent.currentColumn = column
446:                  self.parent.cursorIndex = cursorPosition
447:              }
448:         }
449:         
450:         func updateScrollPosition(_ textView: UITextView) {
451:             guard let font = textView.font else { return }
452:             let lineHeight = font.lineHeight
453:             let scrollOffset = textView.contentOffset.y
454:             let line = Int(scrollOffset / lineHeight)
455:             

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift (lines 489-565 of 708)
────────────────────────────────────────
489:     @ObservedObject var pane: EditorPane
490:     let tab: Tab
491:     @ObservedObject var splitManager: SplitEditorManager
492:     @ObservedObject var editorCore: EditorCore
493:     @ObservedObject private var debugManager = DebugManager.shared
494:     @State private var text: String = ""
495:     @State private var scrollPosition: Int = 0
496:     @State private var totalLines: Int = 1
497:     @State private var visibleLines: Int = 20
498:     @State private var currentLineNumber: Int = 1
499:     @State private var currentColumn: Int = 1
500:     @State private var lineHeight: CGFloat = 17
501:     
502:     private var fileId: String { tab.url?.path ?? tab.fileName }
503:     
504:     var body: some View {
505:         GeometryReader { geometry in
506:             HStack(spacing: 0) {
507:                 // Line numbers + breakpoints (gutter)
508:                 //
509:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
510:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
511:                 ScrollView(showsIndicators: false) {
512:                     VStack(alignment: .trailing, spacing: 0) {
513:                         ForEach(0..<totalLines, id: \.self) { lineIndex in
514:                             HStack(spacing: 4) {
515:                                 Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
516:                                     Circle()
517:                                         .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
518:                                         .overlay(
519:                                             Circle()
520:                                                 .stroke(Color.red.opacity(0.6), lineWidth: 1)
521:                                                 .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
522:                                         )
523:                                         .frame(width: 10, height: 10)
524:                                 }
525:                                 .buttonStyle(.plain)
526:                                 .frame(width: 14, height: lineHeight)
527:                                 
528:                                 Text("\(lineIndex + 1)")
529:                                     .font(.system(size: 12, design: .monospaced))
530:                                     .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
531:                                     .frame(height: lineHeight)
532:                             }
533:                             .frame(maxWidth: .infinity, alignment: .trailing)
534:                         }
535:                     }
536:                     .padding(.trailing, 4)
537:                     .offset(y: -CGFloat(scrollPosition) * lineHeight)
538:                 }
539:                 .scrollDisabled(true)
540:                 .frame(width: 54)
541:                 .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
542:                 
543:                 // Editor
544:                 SyntaxHighlightingTextView(
545:                     text: $text,
546:                     filename: tab.fileName,
547:                     scrollPosition: $scrollPosition,
548:                     totalLines: $totalLines,
549:                     visibleLines: $visibleLines,
550:                     currentLineNumber: $currentLineNumber,
551:                     currentColumn: $currentColumn,
552:                     lineHeight: $lineHeight,
553:                     isActive: splitManager.activePaneId == pane.id
554:                 )
555:                 .environmentObject(editorCore)
556:                 .onChange(of: text) { newValue in
557:                     pane.updateTabContent(newValue)
558:                     
559:                     // Sync scroll if enabled
560:                     if splitManager.syncScroll {
561:                         splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
562:                     }
563:                 }
564:                 
565:                 // Mini minimap


>>>TOOL search
{"query":"word wrap", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"lineBreakMode", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"wrap", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"word wrap", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"lineBreakMode", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"widthTracksTextView", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutputView.swift:310: .help("Toggle word wrap")

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:178: textView.textContainer.lineBreakMode = .byCharWrapping

---

[search]
Found 30 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/SSHGitClient.swift:281: // Simple shell escaping - wrap in single quotes and escape internal single quotes
VSCodeiPadOS/VSCodeiPadOS/Services/RemoteRunner.swift:675: let channelData = unwrapInboundIn(data)
VSCodeiPadOS/VSCodeiPadOS/Services/ErrorParser.swift:1030: /Users/dev/project/Sources/Main.swift:42:15: error: value of optional type 'String?' must be unwrapped
VSCodeiPadOS/VSCodeiPadOS/Services/KeychainManager.swift:357: var wrappedValue: String? {
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:166: // For mock, we create a simple wrapper
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:167: return MockJSValue(wrapped: value)
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:652: public let wrapped: Any
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:654: public var isString: Bool { wrapped is String }
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:655: public var isNumber: Bool { wrapped is NSNumber }
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:656: public var isArray: Bool { wrapped is [Any] }
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:657: public var isObject: Bool { wrapped is [String: Any] }
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:658: public var isNull: Bool { wrapped is NSNull }
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:661: public var toString: String { String(describing: wrapped) }
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:662: public var toInt32: Int32 { (wrapped as? NSNumber)?.int32Value ?? 0 }
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:663: public var toDouble: Double { (wrapped as? NSNumber)?.doubleValue ?? 0 }
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/MockRunners.swift:664: public var toBool: Bool { (wrapped as? NSNumber)?.boolValue ?? false }
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/JSRunnerTests.swift:655: /// In real implementation, this would wrap JavaScriptCore's JSValue
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/JSRunner.swift:82: * A Swift wrapper around JavaScriptCore that provides:
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/JSRunner.swift:262: let wrapper: @convention(block) () -> JSValue = { [weak self] in
VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/JSRunner.swift:292: context.setObject(wrapper, forKeyedSubscript: name as NSString)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/GitGutterView.swift:301: // MARK: - Minimal Git wrappers (CLI-backed)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:11: /// UITextView wrapper with syntax highlighting support
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:177: // Enable line wrapping
VSCodeiPadOS/VSCodeiPadOS/Views/RunConfigView.swift:767: presentationMode.wrappedValue.dismiss()
VSCodeiPadOS/VSCodeiPadOS/Views/RunConfigView.swift:779: presentationMode.wrappedValue.dismiss()
VSCodeiPadOS/VSCodeiPadOS/Views/WorkspaceSettingsView.swift:203: .disabled(!isOverriding.wrappedValue)
VSCodeiPadOS/VSCodeiPadOS/Views/WorkspaceSettingsView.swift:204: .opacity(isOverriding.wrappedValue ? 1 : 0.5)
VSCodeiPadOS/VSCodeiPadOS/Views/WorkspaceSettingsView.swift:219: Stepper("\(title): \(value.wrappedValue)", value: value, in: range)
VSCodeiPadOS/VSCodeiPadOS/Views/WorkspaceSettingsView.swift:220: .disabled(!isOverriding.wrappedValue)
VSCodeiPadOS/VSCodeiPadOS/Views/WorkspaceSettingsView.swift:221: .opacity(isOverriding.wrappedValue ? 1 : 0.5)

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:179: textView.textContainer.widthTracksTextView = true


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":760,"end_line":980}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":760,"end_line":980}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 761-980 of 2051)
────────────────────────────────────────
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
776:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
777: 
778:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
779:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
780: 
781:             bracketHighlightRanges = [r1, r2]
782:         }
783:     }
784: }
785: 
786: // Custom text view to handle key commands, indent guides, and line highlighting
787: class EditorTextView: UITextView {
788:     var onPeekDefinition: (() -> Void)?
789:     var onEscape: (() -> Void)?
790:     var onGoToLine: (() -> Void)?
791:     
792:     // Custom action closures for context menu
793:     var onGoToDefinition: (() -> Void)?
794:     var onFindReferences: (() -> Void)?
795:     var onFormatDocument: (() -> Void)?
796:     var onToggleComment: (() -> Void)?
797:     var onFold: (() -> Void)?
798:     var onUnfold: (() -> Void)?
799: 
800:     // Autocomplete key handling hooks (return true if handled)
801:     var onAcceptAutocomplete: (() -> Bool)?
802:     var onDismissAutocomplete: (() -> Bool)?
803:     
804:     // FEAT-039 & FEAT-043
805:     private var indentGuideColor: UIColor = .separator
806:     private var activeIndentGuideColor: UIColor = .label
807:     private var currentLineHighlightColor: UIColor = .clear
808:     
809:     override init(frame: CGRect, textContainer: NSTextContainer?) {
810:         super.init(frame: frame, textContainer: textContainer)
811:         setup()
812:     }
813:     
814:     required init?(coder: NSCoder) {
815:         super.init(coder: coder)
816:         setup()
817:     }
818:     
819:     private func setup() {
820:         // Ensure we redraw when bounds/selection change
821:         contentMode = .redraw
822:     }
823:     
824:     func updateThemeColors(theme: Theme) {
825:         self.indentGuideColor = UIColor(theme.indentGuide)
826:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
827:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
828:         setNeedsDisplay()
829:     }
830:     
831:     override func draw(_ rect: CGRect) {
832:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
833:             super.draw(rect)
834:             return
835:         }
836:         
837:         // 1. Draw Current Line Highlight (FEAT-043)
838:         if let selectedRange = selectedTextRange {
839:             // Get the line rect for the cursor position
840:             let caretRect = self.caretRect(for: selectedRange.start)
841:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
842:             
843:             context.setFillColor(currentLineHighlightColor.cgColor)
844:             context.fill(lineRect)
845:         }
846:         
847:         // 2. Draw Text (super implementation)
848:         super.draw(rect)
849:         
850:         // 3. Draw Indent Guides (FEAT-039)
851:         // We iterate visible lines and draw vertical lines for indentation
852:         // Optimization: Only draw for visible range
853: 
854:         context.setLineWidth(1.0)
855: 
856:         // Respect editor tab size setting (default 4)
857:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
858:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
859: 
860:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
861:         let indentWidth = spaceWidth * CGFloat(tabSize)
862: 
863:         // Determine active indent level for caret line (for indentGuideActive)
864:         var activeIndentLevel: Int = 0
865:         if let selected = selectedTextRange {
866:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
867:             let nsText = (self.text ?? "") as NSString
868:             let safeLoc = min(max(0, caretPos), nsText.length)
869:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
870:             let caretLineText = nsText.substring(with: caretLineRange)
871: 
872:             var spaces = 0
873:             for ch in caretLineText {
874:                 if ch == " " { spaces += 1 }
875:                 else if ch == "\t" { spaces += tabSize }
876:                 else { break }
877:             }
878:             activeIndentLevel = spaces / tabSize
879:         }
880: 
881:         // Iterate visible glyphs/lines
882:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
883:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
884: 
885:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
886: 
887:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
888:             // Get text for this line
889:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
890:                   let text = self.text as NSString? else { return }
891: 
892:             let lineText = text.substring(with: range)
893: 
894:             // Calculate indentation level
895:             var spaces = 0
896:             for char in lineText {
897:                 if char == " " { spaces += 1 }
898:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
899:                 else { break }
900:             }
901: 
902:             let indentLevel = spaces / tabSize
903:             guard indentLevel > 0 else { return }
904: 
905:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
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


>>>TOOL search
{"query":"contentInsetAdjustmentBehavior", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"contentInsetAdjustmentBehavior", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "contentInsetAdjustmentBehavior"


>>>TOOL search
{"query":"getFoldedLineRanges", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"isLineFolded(line:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":730,"end_line":820}
>>>END
>>>END>>>TOOL search
{"query":"getFoldedLineRanges", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"isLineFolded(line:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":730,"end_line":820}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:741: func getFoldedLineRanges() -> [ClosedRange<Int>] {

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:672: func isLineFolded(line: Int) -> Bool {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:594: if !foldingManager.isLineFolded(line: lineIndex) {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 731-820 of 866)
────────────────────────────────────────
731:         foldRegionsByFile.removeValue(forKey: fileId)
732:     }
733:     
734:     /// Clears all fold regions from memory
735:     func clearAllFoldRegions() {
736:         foldRegionsByFile.removeAll()
737:     }
738:     
739:     /// Gets folded line ranges for text hiding
740:     /// Returns an array of closed ranges representing the line numbers that should be hidden
741:     func getFoldedLineRanges() -> [ClosedRange<Int>] {
742:         var ranges: [ClosedRange<Int>] = []
743:         
744:         // Sort regions by start line to ensure proper ordering
745:         let sortedRegions = foldRegions.sorted { $0.startLine < $1.startLine }
746:         
747:         for region in sortedRegions where region.isFolded {
748:             ranges.append((region.startLine + 1)...region.endLine)
749:         }
750:         
751:         return ranges
752:     }
753:     
754:     /// Gets the total count of folded lines
755:     func getFoldedLineCount() -> Int {
756:         return collapsedLines.count
757:     }
758:     
759:     /// Gets a summary of fold statistics
760:     func getFoldStatistics() -> FoldStatistics {
761:         let totalCount = foldRegions.count
762:         let foldedCount = foldRegions.filter { $0.isFolded }.count
763:         
764:         var typeBreakdown: [FoldRegion.FoldType: Int] = [:]
765:         for region in foldRegions {
766:             typeBreakdown[region.type, default: 0] += 1
767:         }
768:         
769:         return FoldStatistics(
770:             totalRegions: totalCount,
771:             foldedRegions: foldedCount,
772:             typeBreakdown: typeBreakdown
773:         )
774:     }
775:     
776:     // MARK: - Private Methods
777:     
778:     private func updateCollapsedLines() {
779:         collapsedLines.removeAll()
780:         
781:         for region in foldRegions where region.isFolded {
782:             for line in (region.startLine + 1)...region.endLine {
783:                 collapsedLines.insert(line)
784:             }
785:         }
786:     }
787: }
788: 
789: // MARK: - Fold Statistics
790: struct FoldStatistics {
791:     let totalRegions: Int
792:     let foldedRegions: Int
793:     let typeBreakdown: [FoldRegion.FoldType: Int]
794:     
795:     var expansionPercentage: Double {
796:         guard totalRegions > 0 else { return 0 }
797:         return Double(foldedCount) / Double(totalRegions) * 100
798:     }
799:     
800:     var foldedCount: Int {
801:         return foldedRegions
802:     }
803:     
804:     var expandedCount: Int {
805:         return totalRegions - foldedRegions
806:     }
807: }
808: 
809: // MARK: - Fold Button View
810: struct FoldButton: View {
811:     let line: Int
812:     let isExpanded: Bool
813:     let foldType: FoldRegion.FoldType?
814:     let action: () -> Void
815:     
816:     var body: some View {
817:         Button(action: action) {
818:             ZStack {
819:                 if let type = foldType {
820:                     Text(type.icon)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":120}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":180,"end_line":320}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":432,"end_line":520}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-120 of 2051)
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 181-320 of 2051)
────────────────────────────────────────
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
281:             // Defer @Binding update to avoid "Publishing changes from within view updates"
282:             DispatchQueue.main.async {
283:                 self.requestedCursorIndex = nil
284:             }
285: 
286:             // Update SwiftUI state
287:             context.coordinator.updateCursorPosition(textView)
288:             context.coordinator.updateScrollPosition(textView)
289:         }
290:         
291:         // Note: updateLineCount is called in textViewDidChange, no need to call here
292:         // as it causes unnecessary state churn on every updateUIView
293:     }
294:     
295:     // MARK: - Coordinator
296:     
297:     class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
298:         var parent: SyntaxHighlightingTextView
299:         var lastKnownScrollPosition: Int = 0
300:         var lastThemeId: String = ""
301:         var lastRequestedLineSelection: Int? = nil
302:         var lastRequestedCursorIndex: Int? = nil
303:         private var isUpdatingFromMinimap = false
304:         private var highlightDebouncer: Timer?
305:         weak var pinchGesture: UIPinchGestureRecognizer?
306:         private var initialFontSize: CGFloat = 0
307:         
308:         // Track user scroll to prevent programmatic scroll fighting back
309:         private var userScrollDebouncer: Timer?
310:         var isUserScrolling = false
311: 
312:         // FEAT-044: Matching bracket highlight state
313:         private var bracketHighlightRanges: [NSRange] = []
314:         
315:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
316:         var hasAppliedInitialHighlighting = false
317:         
318:         init(_ parent: SyntaxHighlightingTextView) {
319:             self.parent = parent
320:         }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 433-520 of 2051)
────────────────────────────────────────
433:             guard let selectedRange = textView.selectedTextRange else { return }
434:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
435:              
436:              let text = textView.text ?? ""
437:              let prefix = String(text.prefix(cursorPosition))
438:              let lines = prefix.components(separatedBy: .newlines)
439:              
440:              let lineNumber = lines.count
441:              let column = (lines.last?.count ?? 0) + 1
442:              
443:              DispatchQueue.main.async {
444:                  self.parent.currentLineNumber = lineNumber
445:                  self.parent.currentColumn = column
446:                  self.parent.cursorIndex = cursorPosition
447:              }
448:         }
449:         
450:         func updateScrollPosition(_ textView: UITextView) {
451:             guard let font = textView.font else { return }
452:             let lineHeight = font.lineHeight
453:             let scrollOffset = textView.contentOffset.y
454:             let line = Int(scrollOffset / lineHeight)
455:             
456:             // Update both synchronously to prevent feedback loop:
457:             // If we update parent.scrollPosition async, there's a race where
458:             // updateUIView sees old binding value != lastKnownScrollPosition
459:             // and scrolls back to the old position, causing jaggy scrolling.
460:             lastKnownScrollPosition = line
461:             parent.scrollPosition = line
462:         }
463:         
464:         func scrollToLine(_ line: Int, in textView: UITextView) {
465:             guard !isUpdatingFromMinimap else { return }
466:             isUpdatingFromMinimap = true
467:             
468:             let lines = textView.text.components(separatedBy: .newlines)
469:             guard line >= 0 && line < lines.count else {
470:                 isUpdatingFromMinimap = false
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
520: 


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":740,"end_line":866}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 741-866 of 866)
────────────────────────────────────────
741:     func getFoldedLineRanges() -> [ClosedRange<Int>] {
742:         var ranges: [ClosedRange<Int>] = []
743:         
744:         // Sort regions by start line to ensure proper ordering
745:         let sortedRegions = foldRegions.sorted { $0.startLine < $1.startLine }
746:         
747:         for region in sortedRegions where region.isFolded {
748:             ranges.append((region.startLine + 1)...region.endLine)
749:         }
750:         
751:         return ranges
752:     }
753:     
754:     /// Gets the total count of folded lines
755:     func getFoldedLineCount() -> Int {
756:         return collapsedLines.count
757:     }
758:     
759:     /// Gets a summary of fold statistics
760:     func getFoldStatistics() -> FoldStatistics {
761:         let totalCount = foldRegions.count
762:         let foldedCount = foldRegions.filter { $0.isFolded }.count
763:         
764:         var typeBreakdown: [FoldRegion.FoldType: Int] = [:]
765:         for region in foldRegions {
766:             typeBreakdown[region.type, default: 0] += 1
767:         }
768:         
769:         return FoldStatistics(
770:             totalRegions: totalCount,
771:             foldedRegions: foldedCount,
772:             typeBreakdown: typeBreakdown
773:         )
774:     }
775:     
776:     // MARK: - Private Methods
777:     
778:     private func updateCollapsedLines() {
779:         collapsedLines.removeAll()
780:         
781:         for region in foldRegions where region.isFolded {
782:             for line in (region.startLine + 1)...region.endLine {
783:                 collapsedLines.insert(line)
784:             }
785:         }
786:     }
787: }
788: 
789: // MARK: - Fold Statistics
790: struct FoldStatistics {
791:     let totalRegions: Int
792:     let foldedRegions: Int
793:     let typeBreakdown: [FoldRegion.FoldType: Int]
794:     
795:     var expansionPercentage: Double {
796:         guard totalRegions > 0 else { return 0 }
797:         return Double(foldedCount) / Double(totalRegions) * 100
798:     }
799:     
800:     var foldedCount: Int {
801:         return foldedRegions
802:     }
803:     
804:     var expandedCount: Int {
805:         return totalRegions - foldedRegions
806:     }
807: }
808: 
809: // MARK: - Fold Button View
810: struct FoldButton: View {
811:     let line: Int
812:     let isExpanded: Bool
813:     let foldType: FoldRegion.FoldType?
814:     let action: () -> Void
815:     
816:     var body: some View {
817:         Button(action: action) {
818:             ZStack {
819:                 if let type = foldType {
820:                     Text(type.icon)
821:                         .font(.system(size: 8, weight: .bold))
822:                         .foregroundColor(.blue.opacity(0.6))
823:                 }
824:                 
825:                 Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
826:                     .font(.system(size: 10, weight: .semibold))
827:                     .foregroundColor(.primary.opacity(0.7))
828:             }
829:             .frame(width: 18, height: 18)
830:             .background(isExpanded ? Color.secondary.opacity(0.1) : Color.secondary.opacity(0.2))
831:             .cornerRadius(4)
832:         }
833:         .buttonStyle(PlainButtonStyle())
834:     }
835: }
836: 
837: // MARK: - Line Number View with Folding
838: struct LineNumberViewWithFolding: View {
839:     let lineNumber: Int
840:     let isFoldable: Bool
841:     let isExpanded: Bool
842:     let foldType: FoldRegion.FoldType?
843:     let onFoldTap: () -> Void
844:     
845:     var body: some View {
846:         HStack(spacing: 4) {
847:             if isFoldable {
848:                 FoldButton(
849:                     line: lineNumber,
850:                     isExpanded: isExpanded,
851:                     foldType: foldType,
852:                     action: onFoldTap
853:                 )
854:             } else {
855:                 Color.clear
856:                     .frame(width: 18, height: 18)
857:             }
858:             
859:             Text("\(lineNumber + 1)")
860:                 .font(.system(.caption, design: .monospaced))
861:                 .foregroundColor(.gray)
862:                 .frame(minWidth: 30, alignment: .trailing)
863:         }
864:     }
865: }
866: 


>>>TOOL search
{"query":"getFoldedLineRanges", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"isLineFolded(line:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"collapsedLines", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>TOOL search
{"query":"getFoldedLineRanges", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"isLineFolded(line:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"collapsedLines", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:741: func getFoldedLineRanges() -> [ClosedRange<Int>] {

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:672: func isLineFolded(line: Int) -> Bool {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:594: if !foldingManager.isLineFolded(line: lineIndex) {

---

[search]
Found 5 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:72: @Published var collapsedLines: Set<Int> = []
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:673: return collapsedLines.contains(line)
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:756: return collapsedLines.count
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:779: collapsedLines.removeAll()
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:783: collapsedLines.insert(line)


>>>TOOL search
{"query":"foldRegionsByFile", "glob":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":240,"end_line":360}
>>>END
>>>END>>>TOOL search
{"query":"foldRegionsByFile", "glob":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":360,"end_line":520}
>>>END


---

## 🔧 TOOL RESULTS

[search]
Found 10 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:75: private var foldRegionsByFile: [String: [FoldRegion]] = [:]
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:235: foldRegionsByFile[fileId] = regions
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:467: if let fileId = currentFileId, let storedRegions = foldRegionsByFile[fileId] {
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:695: guard let regions = foldRegionsByFile[fileId] else { return false }
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:701: guard let regions = foldRegionsByFile[fileId] else { return false }
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:707: guard var regions = foldRegionsByFile[fileId] else { return }
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:711: foldRegionsByFile[fileId] = regions
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:726: return foldRegionsByFile[fileId] ?? []
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:731: foldRegionsByFile.removeValue(forKey: fileId)
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:736: foldRegionsByFile.removeAll()

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 241-360 of 866)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 361-520 of 866)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":10,"end_line":40}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":440,"end_line":520}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":10,"end_line":40}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":440,"end_line":520}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 11-40 of 2051)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 441-520 of 2051)
────────────────────────────────────────
441:              let column = (lines.last?.count ?? 0) + 1
442:              
443:              DispatchQueue.main.async {
444:                  self.parent.currentLineNumber = lineNumber
445:                  self.parent.currentColumn = column
446:                  self.parent.cursorIndex = cursorPosition
447:              }
448:         }
449:         
450:         func updateScrollPosition(_ textView: UITextView) {
451:             guard let font = textView.font else { return }
452:             let lineHeight = font.lineHeight
453:             let scrollOffset = textView.contentOffset.y
454:             let line = Int(scrollOffset / lineHeight)
455:             
456:             // Update both synchronously to prevent feedback loop:
457:             // If we update parent.scrollPosition async, there's a race where
458:             // updateUIView sees old binding value != lastKnownScrollPosition
459:             // and scrolls back to the old position, causing jaggy scrolling.
460:             lastKnownScrollPosition = line
461:             parent.scrollPosition = line
462:         }
463:         
464:         func scrollToLine(_ line: Int, in textView: UITextView) {
465:             guard !isUpdatingFromMinimap else { return }
466:             isUpdatingFromMinimap = true
467:             
468:             let lines = textView.text.components(separatedBy: .newlines)
469:             guard line >= 0 && line < lines.count else {
470:                 isUpdatingFromMinimap = false
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
520: 


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift","start_line":480,"end_line":620}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift","start_line":1,"end_line":120}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":140}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":140,"end_line":220}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":220,"end_line":320}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":320,"end_line":520}
>>>END
>>>END>>>TOOL create_file
{"path":".patch-backups/notes_line_numbers_fix.txt","content":"Tracking fixes for line numbers alignment & scroll sync.\n"} 
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":480,"end_line":620}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":486,"end_line":666}
>>>END
>>>END>>>TOOL patch_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","patch":">>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift\n>>>FIND\n    @State private var scrollPosition: Int = 0\n    @State private var totalLines: Int = 1\n    @State private var visibleLines: Int = 20\n>>>REPLACE\n    @State private var scrollPosition: Int = 0\n    @State private var scrollOffset: CGFloat = 0\n    @State private var totalLines: Int = 1\n    @State private var visibleLines: Int = 20\n>>>END"} 
>>>END
>>>END>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor"}
>>>END
>>>END>>>TOOL list_dir
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift (lines 481-620 of 708)
────────────────────────────────────────
481:             }
482:         }
483:     }
484: }
485: 
486: // MARK: - Pane Editor View
487: 
488: struct PaneEditorView: View {
489:     @ObservedObject var pane: EditorPane
490:     let tab: Tab
491:     @ObservedObject var splitManager: SplitEditorManager
492:     @ObservedObject var editorCore: EditorCore
493:     @ObservedObject private var debugManager = DebugManager.shared
494:     @State private var text: String = ""
495:     @State private var scrollPosition: Int = 0
496:     @State private var totalLines: Int = 1
497:     @State private var visibleLines: Int = 20
498:     @State private var currentLineNumber: Int = 1
499:     @State private var currentColumn: Int = 1
500:     @State private var lineHeight: CGFloat = 17
501:     
502:     private var fileId: String { tab.url?.path ?? tab.fileName }
503:     
504:     var body: some View {
505:         GeometryReader { geometry in
506:             HStack(spacing: 0) {
507:                 // Line numbers + breakpoints (gutter)
508:                 //
509:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
510:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
511:                 ScrollView(showsIndicators: false) {
512:                     VStack(alignment: .trailing, spacing: 0) {
513:                         ForEach(0..<totalLines, id: \.self) { lineIndex in
514:                             HStack(spacing: 4) {
515:                                 Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
516:                                     Circle()
517:                                         .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
518:                                         .overlay(
519:                                             Circle()
520:                                                 .stroke(Color.red.opacity(0.6), lineWidth: 1)
521:                                                 .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
522:                                         )
523:                                         .frame(width: 10, height: 10)
524:                                 }
525:                                 .buttonStyle(.plain)
526:                                 .frame(width: 14, height: lineHeight)
527:                                 
528:                                 Text("\(lineIndex + 1)")
529:                                     .font(.system(size: 12, design: .monospaced))
530:                                     .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
531:                                     .frame(height: lineHeight)
532:                             }
533:                             .frame(maxWidth: .infinity, alignment: .trailing)
534:                         }
535:                     }
536:                     .padding(.trailing, 4)
537:                     .offset(y: -CGFloat(scrollPosition) * lineHeight)
538:                 }
539:                 .scrollDisabled(true)
540:                 .frame(width: 54)
541:                 .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
542:                 
543:                 // Editor
544:                 SyntaxHighlightingTextView(
545:                     text: $text,
546:                     filename: tab.fileName,
547:                     scrollPosition: $scrollPosition,
548:                     totalLines: $totalLines,
549:                     visibleLines: $visibleLines,
550:                     currentLineNumber: $currentLineNumber,
551:                     currentColumn: $currentColumn,
552:                     lineHeight: $lineHeight,
553:                     isActive: splitManager.activePaneId == pane.id
554:                 )
555:                 .environmentObject(editorCore)
556:                 .onChange(of: text) { newValue in
557:                     pane.updateTabContent(newValue)
558:                     
559:                     // Sync scroll if enabled
560:                     if splitManager.syncScroll {
561:                         splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
562:                     }
563:                 }
564:                 
565:                 // Mini minimap
566:                 MinimapView(
567:                     content: text,
568:                     scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
569:                     scrollViewHeight: .constant(geometry.size.height),
570:                     totalContentHeight: CGFloat(totalLines) * lineHeight
571:                 )
572:                 .frame(width: 60)
573:             }
574:             
575:             // Sticky Header Overlay (FEAT-040)
576:             StickyHeaderView(
577:                 text: text,
578:                 currentLine: scrollPosition,
579:                 theme: ThemeManager.shared.currentTheme,
580:                 lineHeight: lineHeight,
581:                 onSelect: { line in
582:                     scrollPosition = line
583:                 }
584:             )
585:             .padding(.leading, 54)
586:             .padding(.trailing, 60)
587:         }
588:         .onAppear {
589:             text = tab.content
590:         }
591:         .onChange(of: tab.id) { _ in
592:             text = tab.content
593:         }
594:         .onChange(of: pane.scrollOffset) { newOffset in
595:             if splitManager.syncScroll {
596:                 scrollPosition = Int(newOffset / lineHeight)
597:             }
598:         }
599:     }
600: }
601: 
602: // MARK: - Split Drag Handle
603: 
604: struct SplitDragHandle: View {
605:     let direction: SplitDirection
606:     let onDrag: (CGFloat) -> Void
607:     
608:     @State private var isDragging = false
609:     @GestureState private var dragOffset: CGFloat = 0
610:     
611:     var body: some View {
612:         ZStack {
613:             // Background
614:             Rectangle()
615:                 .fill(Color(UIColor.separator))
616:             
617:             // Handle indicator
618:             if direction == .horizontal {
619:                 VStack(spacing: 2) {
620:                     ForEach(0..<3, id: \.self) { _ in

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift (lines 2-93 of 93)
────────────────────────────────────────
2: import UIKit
3: 
4: /// Renders inlay hints as subtle inline text inside the editor area.
5: ///
6: /// This is a lightweight overlay that approximates text positions using monospaced font metrics.
7: struct InlayHintsOverlay: View {
8:     let code: String
9:     let language: CodeLanguage
10: 
11:     /// 0-based top visible line index.
12:     let scrollPosition: Int
13: 
14:     let lineHeight: CGFloat
15:     let fontSize: CGFloat
16: 
17:     /// Width reserved for the gutter (line numbers).
18:     var gutterWidth: CGFloat = 60
19: 
20:     /// Insets used by the underlying UITextView.
21:     var textInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
22: 
23:     /// Width reserved at the right edge (e.g. minimap).
24:     var rightReservedWidth: CGFloat = 0
25: 
26:     /// How many spaces a tab visually represents.
27:     var tabSize: Int = 4
28: 
29:     @State private var hints: [InlayHintsManager.InlayHint] = []
30: 
31:     var body: some View {
32:         GeometryReader { geo in
33:             let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
34:             let charWidth = (" " as NSString).size(withAttributes: [.font: font]).width
35:             let fontLineHeight = font.lineHeight
36:             let baselineAdjustment = max(0, (lineHeight - fontLineHeight) / 2)
37:             let maxVisibleLines = Int(ceil(geo.size.height / max(lineHeight, 1))) + 2
38: 
39:             let lines = code.components(separatedBy: .newlines)
40: 
41:             ZStack(alignment: .topLeading) {
42:                 ForEach(hints) { hint in
43:                     if hint.line >= scrollPosition && hint.line <= (scrollPosition + maxVisibleLines) {
44:                         let lineText = (hint.line >= 0 && hint.line < lines.count) ? lines[hint.line] : ""
45:                         let visualColumn = visualColumn(in: lineText, utf16Column: hint.column, tabSize: tabSize)
46: 
47:                         let x = gutterWidth + textInsets.left + (CGFloat(visualColumn) * charWidth)
48:                         let y = textInsets.top + baselineAdjustment + (CGFloat(hint.line - scrollPosition) * lineHeight)
49: 
50:                         Text(hint.text)
51:                             .font(.system(size: fontSize, design: .monospaced))
52:                             .foregroundColor(Color.secondary.opacity(0.42))
53:                             .offset(x: x, y: y)
54:                             .lineLimit(1)
55:                             .fixedSize(horizontal: true, vertical: false)
56:                     }
57:                 }
58:             }
59:             // Avoid drawing under minimap (or other right-side UI)
60:             .frame(
61:                 width: max(0, geo.size.width - rightReservedWidth),
62:                 height: geo.size.height,
63:                 alignment: .topLeading
64:             )
65:             .clipped()
66:         }
67:         .allowsHitTesting(false)
68:         .onAppear { recompute() }
69:         .onChange(of: code) { _ in recompute() }
70:         .onChange(of: language) { _ in recompute() }
71:     }
72: 
73:     private func recompute() {
74:         hints = InlayHintsManager.shared.hints(for: code, language: language)
75:     }
76: 
77:     private func visualColumn(in line: String, utf16Column: Int, tabSize: Int) -> Int {
78:         let ns = line as NSString
79:         let clamped = max(0, min(utf16Column, ns.length))
80:         let prefix = ns.substring(with: NSRange(location: 0, length: clamped))
81: 
82:         var col = 0
83:         for ch in prefix {
84:             if ch == "\t" {
85:                 col += tabSize
86:             } else {
87:                 col += 1
88:             }
89:         }
90:         return col
91:     }
92: }
93: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-140 of 2050)
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
111:         textView.editorCore = editorCore
112: 
113:         // Autocomplete hooks
114:         textView.onAcceptAutocomplete = onAcceptAutocomplete
115:         textView.onDismissAutocomplete = onDismissAutocomplete
116: 
117:         textView.onPeekDefinition = {
118:             context.coordinator.handlePeekDefinition(in: textView)
119:         }
120: 
121:         textView.onEscape = {
122:             context.coordinator.handleEscape()
123:         }
124: 
125:         textView.onGoToLine = {
126:             self.editorCore.showGoToLine = true
127:         }
128:         
129:         // Wire up custom context menu actions
130:         textView.onGoToDefinition = {
131:             context.coordinator.handleGoToDefinition(in: textView)
132:         }
133:         
134:         textView.onFindReferences = {
135:             context.coordinator.handleFindReferences(in: textView)
136:         }
137:         
138:         textView.onFormatDocument = {
139:             context.coordinator.handleFormatDocument(in: textView)
140:         }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 141-220 of 2050)
────────────────────────────────────────
141:         
142:         textView.onToggleComment = {
143:             context.coordinator.handleToggleComment(in: textView)
144:         }
145:         
146:         textView.onFold = {
147:             context.coordinator.handleFold(in: textView)
148:         }
149:         
150:         textView.onUnfold = {
151:             context.coordinator.handleUnfold(in: textView)
152:         }
153:         
154:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
155:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
156:         pinchGesture.delegate = context.coordinator
157:         textView.addGestureRecognizer(pinchGesture)
158:         context.coordinator.pinchGesture = pinchGesture
159:         
160:         // Configure text view
161:         textView.isEditable = true
162:         textView.isSelectable = true
163:         textView.autocapitalizationType = .none
164:         textView.autocorrectionType = .no
165:         textView.smartDashesType = .no
166:         textView.smartQuotesType = .no
167:         textView.smartInsertDeleteType = .no
168:         textView.spellCheckingType = .no
169:         
170:         // Set font and appearance (use editorCore.editorFontSize)
171:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
172:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
173:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
174:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
175:         textView.keyboardType = .default
176:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
177:         
178:         // Enable line wrapping
179:         textView.textContainer.lineBreakMode = .byCharWrapping
180:         textView.textContainer.widthTracksTextView = true
181:         
182:         // Calculate line height
183:         if let font = textView.font {
184:             DispatchQueue.main.async {
185:                 self.lineHeight = font.lineHeight
186:             }
187:         }
188:         
189:         // Set initial text with syntax highlighting
190:         textView.text = text
191:         context.coordinator.applySyntaxHighlighting(to: textView)
192:         context.coordinator.updateLineCount(textView)
193:         
194:         return textView
195:     }
196:     
197:     func updateUIView(_ textView: UITextView, context: Context) {
198:         // CRITICAL: Update coordinator's parent reference to current struct
199:         // SwiftUI creates new struct instances on each update, so this keeps
200:         // coordinator in sync with current bindings and properties
201:         context.coordinator.parent = self
202:         
203:         // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
204:         // This fixes the bug where syntax highlighting only appears after typing.
205:         // makeUIView applies it, but the view may not be fully in hierarchy yet,
206:         // causing the attributed text to be lost. This ensures it's applied reliably.
207:         if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
208:             context.coordinator.applySyntaxHighlighting(to: textView)
209:             context.coordinator.hasAppliedInitialHighlighting = true
210:         }
211:         
212:         // Update colors when theme changes
213:         // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor
214:         // as it interferes with attributedText syntax highlighting colors.
215:         // The foreground color is handled entirely by the attributedText.
216:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
217:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
218:         
219:         if let editorView = textView as? EditorTextView {
220:             editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 221-320 of 2050)
────────────────────────────────────────
221:         }
222:         
223:         // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
224:         if let currentFont = textView.font, currentFont.pointSize != fontSize {
225:             let selectedRange = textView.selectedRange
226:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
227:             context.coordinator.applySyntaxHighlighting(to: textView)
228:             textView.selectedRange = selectedRange
229:             
230:             // Update line height
231:             if let font = textView.font {
232:                 DispatchQueue.main.async {
233:                     self.lineHeight = font.lineHeight
234:                 }
235:             }
236:         }
237:         
238:         // Update text if changed externally
239:         if textView.text != text {
240:             let selectedRange = textView.selectedRange
241:             textView.text = text
242:             context.coordinator.applySyntaxHighlighting(to: textView)
243:             context.coordinator.hasAppliedInitialHighlighting = true
244:             textView.selectedRange = selectedRange
245:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
246:             // Re-apply highlighting if theme changed
247:             context.coordinator.applySyntaxHighlighting(to: textView)
248:         }
249:         
250:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
251:         // This prevents the editor from fighting against user scroll due to async binding lag
252:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
253:             // Update lastKnownScrollPosition FIRST to prevent race condition
254:             // where user scroll gets overridden by stale binding value
255:             context.coordinator.lastKnownScrollPosition = scrollPosition
256:             context.coordinator.scrollToLine(scrollPosition, in: textView)
257:         }
258: 
259:         // Handle line selection requests (e.g. tapping line numbers)
260:         if let requested = requestedLineSelection,
261:            requested != context.coordinator.lastRequestedLineSelection {
262:             context.coordinator.lastRequestedLineSelection = requested
263:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
264:             // Defer @Binding update to avoid "Publishing changes from within view updates"
265:             DispatchQueue.main.async {
266:                 self.requestedLineSelection = nil
267:             }
268:         }
269: 
270:         // Handle cursor index requests (e.g. accepting autocomplete)
271:         if let requested = requestedCursorIndex,
272:            requested != context.coordinator.lastRequestedCursorIndex {
273:             context.coordinator.lastRequestedCursorIndex = requested
274:             // Use UTF-16 count for NSRange compatibility
275:             let textLength = (textView.text as NSString?)?.length ?? 0
276:             let safeIndex = max(0, min(requested, textLength))
277:             textView.selectedRange = NSRange(location: safeIndex, length: 0)
278:             
279:             // Ensure cursor is visible by scrolling to it
280:             textView.scrollRangeToVisible(textView.selectedRange)
281:             
282:             // Defer @Binding update to avoid "Publishing changes from within view updates"
283:             DispatchQueue.main.async {
284:                 self.requestedCursorIndex = nil
285:             }
286: 
287:             // Update SwiftUI state
288:             context.coordinator.updateCursorPosition(textView)
289:             context.coordinator.updateScrollPosition(textView)
290:         }
291:         
292:         // Note: updateLineCount is called in textViewDidChange, no need to call here
293:         // as it causes unnecessary state churn on every updateUIView
294:     }
295:     
296:     // MARK: - Coordinator
297:     
298:     class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
299:         var parent: SyntaxHighlightingTextView
300:         var lastKnownScrollPosition: Int = 0
301:         var lastThemeId: String = ""
302:         var lastRequestedLineSelection: Int? = nil
303:         var lastRequestedCursorIndex: Int? = nil
304:         private var isUpdatingFromMinimap = false
305:         private var highlightDebouncer: Timer?
306:         weak var pinchGesture: UIPinchGestureRecognizer?
307:         private var initialFontSize: CGFloat = 0
308:         
309:         // Track user scroll to prevent programmatic scroll fighting back
310:         private var userScrollDebouncer: Timer?
311:         var isUserScrolling = false
312: 
313:         // FEAT-044: Matching bracket highlight state
314:         private var bracketHighlightRanges: [NSRange] = []
315:         
316:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
317:         var hasAppliedInitialHighlighting = false
318:         
319:         init(_ parent: SyntaxHighlightingTextView) {
320:             self.parent = parent

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 321-520 of 2050)
────────────────────────────────────────
321:         }
322:         
323:         // MARK: - UIGestureRecognizerDelegate
324:         
325:         // Allow pinch gesture to work simultaneously with text selection gestures
326:         func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
327:             // Allow pinch to work alongside native text selection gestures
328:             return true
329:         }
330:         
331:         func textViewDidBeginEditing(_ textView: UITextView) {
332:             // Ensure syntax highlighting is current when user begins editing
333:             // This handles cases where text was set but highlighting hasn't run yet
334:             applySyntaxHighlighting(to: textView)
335:         }
336:         
337:         func textViewDidChange(_ textView: UITextView) {
338:             // Update parent text
339:             parent.text = textView.text
340:             
341:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
342:             // This prevents flicker during the debounce period
343:             let theme = ThemeManager.shared.currentTheme
344:             let fontSize = parent.editorCore.editorFontSize
345:             textView.typingAttributes = [
346:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
347:                 .foregroundColor: UIColor(theme.editorForeground)
348:             ]
349:             
350:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
351:             highlightDebouncer?.invalidate()
352:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
353:                 DispatchQueue.main.async {
354:                     self?.applySyntaxHighlighting(to: textView)
355:                 }
356:             }
357:             
358:             updateLineCount(textView)
359:             updateCursorPosition(textView)
360:         }
361:         
362:         func textViewDidChangeSelection(_ textView: UITextView) {
363:             if !isUpdatingFromMinimap {
364:                 updateCursorPosition(textView)
365:                 updateScrollPosition(textView)
366: 
367:                 // FEAT-044: Matching bracket highlight
368:                 updateMatchingBracketHighlight(textView)
369: 
370:                 // Trigger redraw so current-line highlight/indent guides track the caret
371:                 (textView as? EditorTextView)?.setNeedsDisplay()
372: 
373:                 // Update selection in EditorCore for multi-cursor support
374:                 let range = textView.selectedRange
375:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
376: 
377:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
378:                 if !parent.editorCore.multiCursorState.isMultiCursor {
379:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
380:                 }
381:             }
382:         }
383:         
384:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
385:         
386:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
387:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
388:             isUserScrolling = true
389:             userScrollDebouncer?.invalidate()
390:         }
391:         
392:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
393:             // If not decelerating, user stopped scrolling
394:             if !decelerate {
395:                 // Small delay to let any final scroll events settle
396:                 userScrollDebouncer?.invalidate()
397:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
398:                     self?.isUserScrolling = false
399:                 }
400:             }
401:         }
402:         
403:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
404:             // Deceleration finished - user scroll is complete
405:             userScrollDebouncer?.invalidate()
406:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
407:                 self?.isUserScrolling = false
408:             }
409:         }
410:         
411:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
412:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
413:             
414:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
415:             // We still use debouncer as a fallback for edge cases
416:             if isUserScrolling {
417:                 userScrollDebouncer?.invalidate()
418:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
419:                     self?.isUserScrolling = false
420:                 }
421:             }
422:             
423:             updateScrollPosition(textView)
424:         }
425:         
426:         func updateLineCount(_ textView: UITextView) {
427:             let lines = textView.text.components(separatedBy: .newlines)
428:             DispatchQueue.main.async {
429:                 self.parent.totalLines = max(1, lines.count)
430:             }
431:         }
432:         
433:         func updateCursorPosition(_ textView: UITextView) {
434:             guard let selectedRange = textView.selectedTextRange else { return }
435:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
436:              
437:              let text = textView.text ?? ""
438:              let prefix = String(text.prefix(cursorPosition))
439:              let lines = prefix.components(separatedBy: .newlines)
440:              
441:              let lineNumber = lines.count
442:              let column = (lines.last?.count ?? 0) + 1
443:              
444:              DispatchQueue.main.async {
445:                  self.parent.currentLineNumber = lineNumber
446:                  self.parent.currentColumn = column
447:                  self.parent.cursorIndex = cursorPosition
448:              }
449:         }
450:         
451:         func updateScrollPosition(_ textView: UITextView) {
452:             guard let font = textView.font else { return }
453:             let lineHeight = font.lineHeight
454:             let scrollOffset = textView.contentOffset.y
455:             let line = Int(scrollOffset / lineHeight)
456:             
457:             // Update both synchronously to prevent feedback loop:
458:             // If we update parent.scrollPosition async, there's a race where
459:             // updateUIView sees old binding value != lastKnownScrollPosition
460:             // and scrolls back to the old position, causing jaggy scrolling.
461:             lastKnownScrollPosition = line
462:             parent.scrollPosition = line
463:         }
464:         
465:         func scrollToLine(_ line: Int, in textView: UITextView) {
466:             guard !isUpdatingFromMinimap else { return }
467:             isUpdatingFromMinimap = true
468:             
469:             let lines = textView.text.components(separatedBy: .newlines)
470:             guard line >= 0 && line < lines.count else {
471:                 isUpdatingFromMinimap = false
472:                 return
473:             }
474:             
475:             var characterPosition = 0
476:             for i in 0..<line {
477:                 characterPosition += lines[i].count + 1
478:             }
479:             
480:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
481:                 let rect = textView.caretRect(for: position)
482:                 let targetY = max(0, rect.origin.y)
483:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
484:             }
485:             
486:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
487:                 self.isUpdatingFromMinimap = false
488:             }
489:         }
490: 
491:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
492:             let lines = textView.text.components(separatedBy: .newlines)
493:             guard line >= 0 && line < lines.count else { return }
494: 
495:             var characterPosition = 0
496:             for i in 0..<line {
497:                 characterPosition += lines[i].count + 1
498:             }
499: 
500:             // FEAT-041: select entire line (excluding trailing newline)
501:             let lineLength = (lines[line] as NSString).length
502:             let range = NSRange(location: characterPosition, length: lineLength)
503:             textView.selectedRange = range
504: 
505:             // Ensure it's visible
506:             scrollToLine(line, in: textView)
507: 
508:             // Update SwiftUI state
509:             updateCursorPosition(textView)
510:             updateScrollPosition(textView)
511:         }
512: 
513:         func applySyntaxHighlighting(to textView: UITextView) {
514:             let theme = ThemeManager.shared.currentTheme
515:             lastThemeId = theme.id
516: 
517:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
518:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
519: 
520:             let selectedRange = textView.selectedRange

---

[create_file]
✅ Created: .patch-backups/notes_line_numbers_fix.txt

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 481-620 of 774)
────────────────────────────────────────
481: // MARK: - Pane Editor View
482: 
483: struct PaneEditorView: View {
484:     @ObservedObject var pane: EditorPane
485:     let tab: Tab
486:     @ObservedObject var splitManager: SplitEditorManager
487:     @ObservedObject var editorCore: EditorCore
488:     @ObservedObject private var debugManager = DebugManager.shared
489:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
490:     @State private var text: String = ""
491:     @State private var scrollPosition: Int = 0
492:     @State private var totalLines: Int = 1
493:     @State private var visibleLines: Int = 20
494:     @State private var currentLineNumber: Int = 1
495:     @State private var currentColumn: Int = 1
496:     @State private var lineHeight: CGFloat = 17
497:     @State private var requestedLineSelection: Int? = nil
498: 
499:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
500:     
501:     private var fileId: String { tab.url?.path ?? tab.fileName }
502:     
503:     var body: some View {
504:         GeometryReader { geometry in
505:             HStack(spacing: 0) {
506:                 // Line numbers + breakpoints + code folding (gutter)
507:                 //
508:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
509:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
510:                 if lineNumbersStyle != "off" {
511:                     ScrollView(showsIndicators: false) {
512:                         VStack(alignment: .trailing, spacing: 0) {
513:                             ForEach(0..<totalLines, id: \ .self) { lineIndex in
514:                                 HStack(spacing: 2) {
515:                                     // Fold chevron icon
516:                                     if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
517:                                         Button(action: { 
518:                                             foldingManager.toggleFold(fileId: fileId, line: lineIndex)
519:                                         }) {
520:                                             Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")
521:                                                 .font(.system(size: 10, weight: .regular))
522:                                                 .foregroundColor(.secondary.opacity(0.8))
523:                                                 .frame(width: 12, height: lineHeight)
524:                                         }
525:                                         .buttonStyle(.plain)
526:                                     } else {
527:                                         // Spacer for alignment
528:                                         Spacer()
529:                                             .frame(width: 12)
530:                                     }
531:                                     
532:                                     // Breakpoint indicator
533:                                     Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
534:                                         Circle()
535:                                             .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
536:                                             .overlay(
537:                                                 Circle()
538:                                                     .stroke(Color.red.opacity(0.6), lineWidth: 1)
539:                                                     .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
540:                                             )
541:                                             .frame(width: 10, height: 10)
542:                                     }
543:                                     .buttonStyle(.plain)
544:                                     .frame(width: 14, height: lineHeight)
545: 
546:                                     Text(displayText(for: lineIndex))
547:                                         .font(.system(size: 12, design: .monospaced))
548:                                         .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
549:                                         .frame(height: lineHeight)
550:                                         .contentShape(Rectangle())
551:                                         .onTapGesture {
552:                                             requestedLineSelection = lineIndex
553:                                         }
554:                                 }
555:                                 .frame(maxWidth: .infinity, alignment: .trailing)
556:                             }
557:                         }
558:                         .padding(.trailing, 4)
559:                         .offset(y: -CGFloat(scrollPosition) * lineHeight)
560:                     }
561:                     .frame(width: 70)
562:                     .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
563:                 }
564: 
565:                 // Editor
566:                 SyntaxHighlightingTextView(
567:                     text: $text,
568:                     filename: tab.fileName,
569:                     scrollPosition: $scrollPosition,
570:                     totalLines: $totalLines,
571:                     visibleLines: $visibleLines,
572:                     currentLineNumber: $currentLineNumber,
573:                     currentColumn: $currentColumn,
574:                     lineHeight: $lineHeight,
575:                     isActive: splitManager.activePaneId == pane.id,
576:                     editorCore: editorCore,
577:                     requestedLineSelection: $requestedLineSelection
578:                 )
579:                 .onChange(of: text) { newValue in
580:                     pane.updateTabContent(newValue)
581:                     
582:                     // Sync scroll if enabled
583:                     if splitManager.syncScroll {
584:                         splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
585:                     }
586:                 }
587:                 
588:                 // Mini minimap
589:                 MinimapView(
590:                     content: text,
591:                     scrollOffset: CGFloat(scrollPosition) * lineHeight,
592:                     scrollViewHeight: geometry.size.height,
593:                     totalContentHeight: CGFloat(totalLines) * lineHeight
594:                 )
595:                 .frame(width: 60)
596:             }
597:             // Sticky Header Overlay (FEAT-040)
598:             StickyHeaderView(
599:                 text: text,
600:                 currentLine: scrollPosition, // Using scrollPosition as approximate top line
601:                 theme: ThemeManager.shared.currentTheme,
602:                 lineHeight: lineHeight,
603:                 onSelect: { line in
604:                     requestedLineSelection = line
605:                 }
606:             )
607:             .padding(.leading, 70) // Offset for line numbers + folding icons
608:             .padding(.trailing, 60) // Offset for minimap
609:             
610:             // Peek Definition Overlay
611:             if let peekState = editorCore.peekState, editorCore.activeTabId == tab.id {
612:                  // Calculate simplified position: center of screen for now, but conceptually "inline"
613:                  // To make it truly inline, we'd need more complex geometry, but overlay is a good start.
614:                  VStack {
615:                      Spacer()
616:                          .frame(height: max(0, CGFloat(peekState.sourceLine - scrollPosition) * lineHeight + lineHeight + 20))
617:                      
618:                      PeekDefinitionView(
619:                          editorCore: editorCore,
620:                          targetFile: peekState.file,

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 487-666 of 774)
────────────────────────────────────────
487:     @ObservedObject var editorCore: EditorCore
488:     @ObservedObject private var debugManager = DebugManager.shared
489:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
490:     @State private var text: String = ""
491:     @State private var scrollPosition: Int = 0
492:     @State private var totalLines: Int = 1
493:     @State private var visibleLines: Int = 20
494:     @State private var currentLineNumber: Int = 1
495:     @State private var currentColumn: Int = 1
496:     @State private var lineHeight: CGFloat = 17
497:     @State private var requestedLineSelection: Int? = nil
498: 
499:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
500:     
501:     private var fileId: String { tab.url?.path ?? tab.fileName }
502:     
503:     var body: some View {
504:         GeometryReader { geometry in
505:             HStack(spacing: 0) {
506:                 // Line numbers + breakpoints + code folding (gutter)
507:                 //
508:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
509:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
510:                 if lineNumbersStyle != "off" {
511:                     ScrollView(showsIndicators: false) {
512:                         VStack(alignment: .trailing, spacing: 0) {
513:                             ForEach(0..<totalLines, id: \ .self) { lineIndex in
514:                                 HStack(spacing: 2) {
515:                                     // Fold chevron icon
516:                                     if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
517:                                         Button(action: { 
518:                                             foldingManager.toggleFold(fileId: fileId, line: lineIndex)
519:                                         }) {
520:                                             Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")
521:                                                 .font(.system(size: 10, weight: .regular))
522:                                                 .foregroundColor(.secondary.opacity(0.8))
523:                                                 .frame(width: 12, height: lineHeight)
524:                                         }
525:                                         .buttonStyle(.plain)
526:                                     } else {
527:                                         // Spacer for alignment
528:                                         Spacer()
529:                                             .frame(width: 12)
530:                                     }
531:                                     
532:                                     // Breakpoint indicator
533:                                     Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
534:                                         Circle()
535:                                             .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
536:                                             .overlay(
537:                                                 Circle()
538:                                                     .stroke(Color.red.opacity(0.6), lineWidth: 1)
539:                                                     .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
540:                                             )
541:                                             .frame(width: 10, height: 10)
542:                                     }
543:                                     .buttonStyle(.plain)
544:                                     .frame(width: 14, height: lineHeight)
545: 
546:                                     Text(displayText(for: lineIndex))
547:                                         .font(.system(size: 12, design: .monospaced))
548:                                         .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
549:                                         .frame(height: lineHeight)
550:                                         .contentShape(Rectangle())
551:                                         .onTapGesture {
552:                                             requestedLineSelection = lineIndex
553:                                         }
554:                                 }
555:                                 .frame(maxWidth: .infinity, alignment: .trailing)
556:                             }
557:                         }
558:                         .padding(.trailing, 4)
559:                         .offset(y: -CGFloat(scrollPosition) * lineHeight)
560:                     }
561:                     .frame(width: 70)
562:                     .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
563:                 }
564: 
565:                 // Editor
566:                 SyntaxHighlightingTextView(
567:                     text: $text,
568:                     filename: tab.fileName,
569:                     scrollPosition: $scrollPosition,
570:                     totalLines: $totalLines,
571:                     visibleLines: $visibleLines,
572:                     currentLineNumber: $currentLineNumber,
573:                     currentColumn: $currentColumn,
574:                     lineHeight: $lineHeight,
575:                     isActive: splitManager.activePaneId == pane.id,
576:                     editorCore: editorCore,
577:                     requestedLineSelection: $requestedLineSelection
578:                 )
579:                 .onChange(of: text) { newValue in
580:                     pane.updateTabContent(newValue)
581:                     
582:                     // Sync scroll if enabled
583:                     if splitManager.syncScroll {
584:                         splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
585:                     }
586:                 }
587:                 
588:                 // Mini minimap
589:                 MinimapView(
590:                     content: text,
591:                     scrollOffset: CGFloat(scrollPosition) * lineHeight,
592:                     scrollViewHeight: geometry.size.height,
593:                     totalContentHeight: CGFloat(totalLines) * lineHeight
594:                 )
595:                 .frame(width: 60)
596:             }
597:             // Sticky Header Overlay (FEAT-040)
598:             StickyHeaderView(
599:                 text: text,
600:                 currentLine: scrollPosition, // Using scrollPosition as approximate top line
601:                 theme: ThemeManager.shared.currentTheme,
602:                 lineHeight: lineHeight,
603:                 onSelect: { line in
604:                     requestedLineSelection = line
605:                 }
606:             )
607:             .padding(.leading, 70) // Offset for line numbers + folding icons
608:             .padding(.trailing, 60) // Offset for minimap
609:             
610:             // Peek Definition Overlay
611:             if let peekState = editorCore.peekState, editorCore.activeTabId == tab.id {
612:                  // Calculate simplified position: center of screen for now, but conceptually "inline"
613:                  // To make it truly inline, we'd need more complex geometry, but overlay is a good start.
614:                  VStack {
615:                      Spacer()
616:                          .frame(height: max(0, CGFloat(peekState.sourceLine - scrollPosition) * lineHeight + lineHeight + 20))
617:                      
618:                      PeekDefinitionView(
619:                          editorCore: editorCore,
620:                          targetFile: peekState.file,
621:                          targetLine: peekState.line,
622:                          content: peekState.content,
623:                          onClose: { editorCore.closePeekDefinition() },
624:                          onOpen: {
625:                              editorCore.openFile(FileItem(name: URL(fileURLWithPath: peekState.file).lastPathComponent, path: peekState.file, isDirectory: false))
626:                              editorCore.closePeekDefinition()
627:                          }
628:                      )
629:                      .padding(.horizontal)
630:                      .padding(.bottom, 20)
631:                      
632:                      Spacer()
633:                  }
634:                  .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
635:                  .background(Color.black.opacity(0.01)) // Capture taps outside if needed, or let them pass
636:                  .transition(.opacity)
637:                  .zIndex(100)
638:             }
639:         }
640:         .onAppear {
641:             text = tab.content
642:         }
643:         .onChange(of: tab.id) { _ in
644:             text = tab.content
645:         }
646:         .onChange(of: pane.scrollOffset) { newOffset in
647:             if splitManager.syncScroll {
648:                 scrollPosition = Int(newOffset / lineHeight)
649:             }
650:         }
651:     }
652:     
653:     private func displayText(for lineIndex: Int) -> String {
654:         switch lineNumbersStyle {
655:         case "relative":
656:             let lineNumber = lineIndex + 1
657:             if lineNumber == currentLineNumber { return "\(lineNumber)" }
658:             return "\(abs(lineNumber - currentLineNumber))"
659:         case "interval":
660:             let lineNumber = lineIndex + 1
661:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
662:         default:
663:             return "\(lineIndex + 1)"
664:         }
665:     }
666: }

---

Error: Tool 'patch_file' not permitted for this agent (tools=read_write)

---

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
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift","start_line":1,"end_line":260}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift","start_line":260,"end_line":520}
>>>END
>>>END>>>TOOL search
{"query":"FoldingLayoutManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END>>>END of responseIt seems I used multiple tool calls incorrectly? Actually I wrote tool calls in multiple blocks each ended with >>>END, but need to stop after them. I included 3 tool calls. It's fine.>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift","start_line":1,"end_line":260}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift","start_line":260,"end_line":520}
>>>END

>>>TOOL search
{"query":"FoldingLayoutManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift (lines 2-71 of 71)
────────────────────────────────────────
2: 
3: /// TextKit layout manager that collapses line fragments for lines marked folded in CodeFoldingManager.
4: ///
5: /// This is a view-level folding implementation (it does NOT modify the underlying text).
6: final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
7:     weak var ownerTextView: EditorTextView?
8: 
9:     override init() {
10:         super.init()
11:         self.delegate = self
12:     }
13: 
14:     required init?(coder: NSCoder) {
15:         super.init(coder: coder)
16:         self.delegate = self
17:     }
18: 
19:     func layoutManager(
20:         _ layoutManager: NSLayoutManager,
21:         shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<CGRect>,
22:         lineFragmentUsedRect: UnsafeMutablePointer<CGRect>,
23:         baselineOffset: UnsafeMutablePointer<CGFloat>,
24:         in textContainer: NSTextContainer,
25:         forGlyphRange glyphRange: NSRange
26:     ) -> Bool {
27:         guard let owner = ownerTextView,
28:               let foldingManager = owner.foldingManager,
29:               let fileId = owner.fileId
30:         else {
31:             return false
32:         }
33: 
34:         // Convert glyphRange -> characterRange so we can compute the line index.
35:         let charRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
36:         let loc = max(0, charRange.location)
37: 
38:         let full = (self.textStorage?.string ?? "") as NSString
39:         let lineIndex = FoldingLayoutManager.lineIndex(atUTF16Location: loc, in: full)
40: 
41:         if foldingManager.isLineFolded(fileId: fileId, line: lineIndex) {
42:             // Collapse this visual line fragment.
43:             lineFragmentRect.pointee.size.height = 0
44:             lineFragmentUsedRect.pointee.size.height = 0
45:             baselineOffset.pointee = 0
46:             return true
47:         }
48: 
49:         return false
50:     }
51: 
52:     private static func lineIndex(atUTF16Location loc: Int, in text: NSString) -> Int {
53:         if loc <= 0 { return 0 }
54: 
55:         let capped = min(loc, text.length)
56:         var line = 0
57:         var searchStart = 0
58: 
59:         while searchStart < capped {
60:             let r = text.range(of: "\n", options: [], range: NSRange(location: searchStart, length: capped - searchStart))
61:             if r.location == NSNotFound { break }
62:             line += 1
63:             let next = r.location + 1
64:             if next >= capped { break }
65:             searchStart = next
66:         }
67: 
68:         return line
69:     }
70: }
71: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift (lines 261-71 of 71)
────────────────────────────────────────


---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:6: final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:39: let lineIndex = FoldingLayoutManager.lineIndex(atUTF16Location: loc, in: full)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":100,"end_line":210}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":760,"end_line":900}
>>>END

>>>TOOL search
{"query":"foldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"fileId", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 101-210 of 2050)
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
111:         textView.editorCore = editorCore
112: 
113:         // Autocomplete hooks
114:         textView.onAcceptAutocomplete = onAcceptAutocomplete
115:         textView.onDismissAutocomplete = onDismissAutocomplete
116: 
117:         textView.onPeekDefinition = {
118:             context.coordinator.handlePeekDefinition(in: textView)
119:         }
120: 
121:         textView.onEscape = {
122:             context.coordinator.handleEscape()
123:         }
124: 
125:         textView.onGoToLine = {
126:             self.editorCore.showGoToLine = true
127:         }
128:         
129:         // Wire up custom context menu actions
130:         textView.onGoToDefinition = {
131:             context.coordinator.handleGoToDefinition(in: textView)
132:         }
133:         
134:         textView.onFindReferences = {
135:             context.coordinator.handleFindReferences(in: textView)
136:         }
137:         
138:         textView.onFormatDocument = {
139:             context.coordinator.handleFormatDocument(in: textView)
140:         }
141:         
142:         textView.onToggleComment = {
143:             context.coordinator.handleToggleComment(in: textView)
144:         }
145:         
146:         textView.onFold = {
147:             context.coordinator.handleFold(in: textView)
148:         }
149:         
150:         textView.onUnfold = {
151:             context.coordinator.handleUnfold(in: textView)
152:         }
153:         
154:         // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
155:         let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
156:         pinchGesture.delegate = context.coordinator
157:         textView.addGestureRecognizer(pinchGesture)
158:         context.coordinator.pinchGesture = pinchGesture
159:         
160:         // Configure text view
161:         textView.isEditable = true
162:         textView.isSelectable = true
163:         textView.autocapitalizationType = .none
164:         textView.autocorrectionType = .no
165:         textView.smartDashesType = .no
166:         textView.smartQuotesType = .no
167:         textView.smartInsertDeleteType = .no
168:         textView.spellCheckingType = .no
169:         
170:         // Set font and appearance (use editorCore.editorFontSize)
171:         textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
172:         textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
173:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
174:         textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
175:         textView.keyboardType = .default
176:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
177:         
178:         // Enable line wrapping
179:         textView.textContainer.lineBreakMode = .byCharWrapping
180:         textView.textContainer.widthTracksTextView = true
181:         
182:         // Calculate line height
183:         if let font = textView.font {
184:             DispatchQueue.main.async {
185:                 self.lineHeight = font.lineHeight
186:             }
187:         }
188:         
189:         // Set initial text with syntax highlighting
190:         textView.text = text
191:         context.coordinator.applySyntaxHighlighting(to: textView)
192:         context.coordinator.updateLineCount(textView)
193:         
194:         return textView
195:     }
196:     
197:     func updateUIView(_ textView: UITextView, context: Context) {
198:         // CRITICAL: Update coordinator's parent reference to current struct
199:         // SwiftUI creates new struct instances on each update, so this keeps
200:         // coordinator in sync with current bindings and properties
201:         context.coordinator.parent = self
202:         
203:         // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
204:         // This fixes the bug where syntax highlighting only appears after typing.
205:         // makeUIView applies it, but the view may not be fully in hierarchy yet,
206:         // causing the attributed text to be lost. This ensures it's applied reliably.
207:         if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
208:             context.coordinator.applySyntaxHighlighting(to: textView)
209:             context.coordinator.hasAppliedInitialHighlighting = true
210:         }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 761-900 of 2050)
────────────────────────────────────────
761:                             matchIndex = i
762:                             break
763:                         } else {
764:                             depth -= 1
765:                         }
766:                     }
767:                     i -= 1
768:                 }
769:             }
770: 
771:             guard let match = matchIndex else { return }
772: 
773:             let r1 = NSRange(location: idx, length: 1)
774:             let r2 = NSRange(location: match, length: 1)
775: 
776:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
777:             textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
778: 
779:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
780:             textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
781: 
782:             bracketHighlightRanges = [r1, r2]
783:         }
784:     }
785: }
786: 
787: // Custom text view to handle key commands, indent guides, and line highlighting
788: class EditorTextView: MultiCursorTextView {
789:     var onPeekDefinition: (() -> Void)?
790:     var onEscape: (() -> Void)?
791:     var onGoToLine: (() -> Void)?
792:     
793:     // Custom action closures for context menu
794:     var onGoToDefinition: (() -> Void)?
795:     var onFindReferences: (() -> Void)?
796:     var onFormatDocument: (() -> Void)?
797:     var onToggleComment: (() -> Void)?
798:     var onFold: (() -> Void)?
799:     var onUnfold: (() -> Void)?
800: 
801:     // Autocomplete key handling hooks are inherited from MultiCursorTextView
802:     
803:     // FEAT-039 & FEAT-043
804:     private var indentGuideColor: UIColor = .separator
805:     private var activeIndentGuideColor: UIColor = .label
806:     private var currentLineHighlightColor: UIColor = .clear
807:     
808:     override init(frame: CGRect, textContainer: NSTextContainer?) {
809:         super.init(frame: frame, textContainer: textContainer)
810:         setup()
811:     }
812:     
813:     required init?(coder: NSCoder) {
814:         super.init(coder: coder)
815:         setup()
816:     }
817:     
818:     private func setup() {
819:         // Ensure we redraw when bounds/selection change
820:         contentMode = .redraw
821:     }
822:     
823:     func updateThemeColors(theme: Theme) {
824:         self.indentGuideColor = UIColor(theme.indentGuide)
825:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
826:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
827:         setNeedsDisplay()
828:     }
829:     
830:     override func draw(_ rect: CGRect) {
831:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
832:             super.draw(rect)
833:             return
834:         }
835:         
836:         // 1. Draw Current Line Highlight (FEAT-043)
837:         if let selectedRange = selectedTextRange {
838:             // Get the line rect for the cursor position
839:             let caretRect = self.caretRect(for: selectedRange.start)
840:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
841:             
842:             context.setFillColor(currentLineHighlightColor.cgColor)
843:             context.fill(lineRect)
844:         }
845:         
846:         // 2. Draw Text (super implementation)
847:         super.draw(rect)
848:         
849:         // 3. Draw Indent Guides (FEAT-039)
850:         // We iterate visible lines and draw vertical lines for indentation
851:         // Optimization: Only draw for visible range
852: 
853:         context.setLineWidth(1.0)
854: 
855:         // Respect editor tab size setting (default 4)
856:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
857:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
858: 
859:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
860:         let indentWidth = spaceWidth * CGFloat(tabSize)
861: 
862:         // Determine active indent level for caret line (for indentGuideActive)
863:         var activeIndentLevel: Int = 0
864:         if let selected = selectedTextRange {
865:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
866:             let nsText = (self.text ?? "") as NSString
867:             let safeLoc = min(max(0, caretPos), nsText.length)
868:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
869:             let caretLineText = nsText.substring(with: caretLineRange)
870: 
871:             var spaces = 0
872:             for ch in caretLineText {
873:                 if ch == " " { spaces += 1 }
874:                 else if ch == "\t" { spaces += tabSize }
875:                 else { break }
876:             }
877:             activeIndentLevel = spaces / tabSize
878:         }
879: 
880:         // Iterate visible glyphs/lines
881:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
882:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
883: 
884:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
885: 
886:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
887:             // Get text for this line
888:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
889:                   let text = self.text as NSString? else { return }
890: 
891:             let lineText = text.substring(with: range)
892: 
893:             // Calculate indentation level
894:             var spaces = 0
895:             for char in lineText {
896:                 if char == " " { spaces += 1 }
897:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
898:                 else { break }
899:             }
900: 

---

[search]
No matches found for "foldingManager"

---

[search]
No matches found for "fileId"


>>>TOOL search
{"query":"FoldingLayoutManager(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift","start_line":1,"end_line":260}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "FoldingLayoutManager("

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 2-260 of 320)
────────────────────────────────────────
2: //  VSCodeiPadOS
3: //
4: //  Custom UITextView subclass that supports multiple cursor display
5: //
6: 
7: import UIKit
8: import SwiftUI
9: 
10: /// Custom UITextView that displays multiple cursors
11: class MultiCursorTextView: UITextView, UIGestureRecognizerDelegate {
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
40:         setupOptionClickAddCursor()
41:     }
42: 
43:     required init?(coder: NSCoder) {
44:         super.init(coder: coder)
45:         setupCursorBlinking()
46:         setupOptionClickAddCursor()
47:     }
48: 
49:     deinit {
50:         blinkTimer?.invalidate()
51:     }
52: 
53:     private func setupCursorBlinking() {
54:         blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
55:             self?.cursorVisible.toggle()
56:             self?.updateCursorVisibility()
57:         }
58:     }
59: 
60:     private func updateCursorVisibility() {
61:         let alpha: Float = cursorVisible ? 1.0 : 0.0
62:         cursorLayers.forEach { $0.opacity = alpha }
63:     }
64: 
65:     // MARK: - Option+Click (Alt+Click) Add Cursor
66: 
67:     private weak var optionClickTapRecognizer: UITapGestureRecognizer?
68: 
69:     private func setupOptionClickAddCursor() {
70:         let tap = UITapGestureRecognizer(target: self, action: #selector(handleOptionClickTap(_:)))
71:         tap.delegate = self
72:         tap.cancelsTouchesInView = false
73:         addGestureRecognizer(tap)
74:         optionClickTapRecognizer = tap
75:     }
76: 
77:     func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
78:         if gestureRecognizer === optionClickTapRecognizer {
79:             // Only handle when Option/Alt is pressed.
80:             return gestureRecognizer.modifierFlags.contains(.alternate)
81:         }
82:         return true
83:     }
84: 
85:     @objc private func handleOptionClickTap(_ gestureRecognizer: UITapGestureRecognizer) {
86:         guard gestureRecognizer.modifierFlags.contains(.alternate) else { return }
87:         guard let editorCore = editorCore else { return }
88: 
89:         let point = gestureRecognizer.location(in: self)
90:         guard let pos = closestPosition(to: point) else { return }
91: 
92:         let offset = self.offset(from: beginningOfDocument, to: pos)
93: 
94:         editorCore.addCursorAtPosition(offset)
95: 
96:         // Make the newly added cursor the UIKit caret too.
97:         selectedRange = NSRange(location: offset, length: 0)
98:         delegate?.textViewDidChangeSelection?(self)
99: 
100:         updateCursorDisplay()
101:     }
102: 
103:     /// Updates the display of all cursors and selections
104:     func updateCursorDisplay() {
105:         // Remove existing cursor and selection layers
106:         cursorLayers.forEach { $0.removeFromSuperlayer() }
107:         cursorLayers.removeAll()
108:         selectionLayers.forEach { $0.removeFromSuperlayer() }
109:         selectionLayers.removeAll()
110: 
111:         guard let editorCore = editorCore else { return }
112:         let cursors = editorCore.multiCursorState.cursors
113: 
114:         // Only show additional cursors if we have multiple
115:         guard cursors.count > 1 else { return }
116: 
117:         // Draw each cursor (skip the primary one as UITextView handles it)
118:         for (index, cursor) in cursors.enumerated() {
119:             // Primary selection is handled by UITextView.selectedRange; only draw additional selections.
120:             if !cursor.isPrimary, let selectionRange = cursor.selectionRange {
121:                 drawSelection(for: selectionRange, isPrimary: false, index: index)
122:             }
123: 
124:             // Draw cursor line (skip primary cursor as system handles it)
125:             if !cursor.isPrimary {
126:                 drawCursor(at: cursor.position, isPrimary: false, index: index)
127:             }
128:         }
129:     }
130: 
131:     private func drawCursor(at position: Int, isPrimary: Bool, index: Int) {
132:         guard let textPosition = self.position(from: beginningOfDocument, offset: position) else { return }
133: 
134:         let caretRect = self.caretRect(for: textPosition)
135: 
136:         let cursorLayer = CALayer()
137:         cursorLayer.backgroundColor = (isPrimary ? cursorColor : secondaryCursorColor).cgColor
138:         cursorLayer.frame = CGRect(
139:             x: caretRect.origin.x,
140:             y: caretRect.origin.y,
141:             width: cursorWidth,
142:             height: caretRect.height
143:         )
144:         cursorLayer.cornerRadius = 1
145: 
146:         layer.addSublayer(cursorLayer)
147:         cursorLayers.append(cursorLayer)
148:     }
149: 
150:     private func drawSelection(for range: NSRange, isPrimary: Bool, index: Int) {
151:         guard let start = position(from: beginningOfDocument, offset: range.location),
152:               let end = position(from: beginningOfDocument, offset: range.location + range.length),
153:               let textRange = self.textRange(from: start, to: end) else { return }
154: 
155:         let selectionRects = selectionRects(for: textRange)
156: 
157:         for rect in selectionRects {
158:             let selectionLayer = CALayer()
159:             selectionLayer.backgroundColor = (isPrimary ? selectionColor : secondarySelectionColor).cgColor
160:             selectionLayer.frame = rect.rect
161: 
162:             // Insert behind text
163:             if let textLayer = layer.sublayers?.first {
164:                 layer.insertSublayer(selectionLayer, below: textLayer)
165:             } else {
166:                 layer.addSublayer(selectionLayer)
167:             }
168:             selectionLayers.append(selectionLayer)
169:         }
170:     }
171: 
172:     // MARK: - Text Input Handling for Multi-Cursor
173: 
174:     override func insertText(_ text: String) {
175:         guard let editorCore = editorCore,
176:               editorCore.multiCursorState.isMultiCursor else {
177:             super.insertText(text)
178:             return
179:         }
180: 
181:         // Handle multi-cursor insert
182:         var content = self.text ?? ""
183:         editorCore.multiCursorState.insertText(text, in: &content)
184: 
185:         // Update text view
186:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
187:         self.text = content
188: 
189:         // Position the main cursor
190:         if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
191:             selectedTextRange = textRange(from: newPosition, to: newPosition)
192:         }
193: 
194:         // Trigger text change notification
195:         delegate?.textViewDidChange?(self)
196: 
197:         updateCursorDisplay()
198:     }
199: 
200:     override func deleteBackward() {
201:         guard let editorCore = editorCore,
202:               editorCore.multiCursorState.isMultiCursor else {
203:             super.deleteBackward()
204:             return
205:         }
206: 
207:         // Handle multi-cursor delete
208:         var content = self.text ?? ""
209:         editorCore.multiCursorState.deleteBackward(in: &content)
210: 
211:         // Update text view
212:         let cursorPosition = editorCore.multiCursorState.primaryCursor?.position ?? 0
213:         self.text = content
214: 
215:         // Position the main cursor
216:         if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
217:             selectedTextRange = textRange(from: newPosition, to: newPosition)
218:         }
219: 
220:         // Trigger text change notification
221:         delegate?.textViewDidChange?(self)
222: 
223:         updateCursorDisplay()
224:     }
225: 
226:     // MARK: - Layout Updates
227: 
228:     override func layoutSubviews() {
229:         super.layoutSubviews()
230:         // Refresh cursor positions when layout changes
231:         updateCursorDisplay()
232:     }
233: 
234:     override var contentOffset: CGPoint {
235:         didSet {
236:             // Update cursor positions when scrolling
237:             updateCursorDisplay()
238:         }
239:     }
240: }
241: 
242: // MARK: - Key Commands for Multi-Cursor + Autocomplete
243: 
244: extension MultiCursorTextView {
245: 
246:     override var keyCommands: [UIKeyCommand]? {
247:         var commands = super.keyCommands ?? []
248: 
249:         // Cmd+D: Add next occurrence
250:         commands.append(UIKeyCommand(
251:             title: "Add Next Occurrence",
252:             action: #selector(addNextOccurrence),
253:             input: "d",
254:             modifierFlags: .command
255:         ))
256: 
257:         // Cmd+Shift+L: Select all occurrences
258:         commands.append(UIKeyCommand(
259:             title: "Select All Occurrences",
260:             action: #selector(selectAllOccurrences),


>>>TOOL search
{"query":"isLineFolded(fileId", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"foldingManager:", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:728: func isLineFolded(fileId: String, line: Int) -> Bool {

---

[search]
No matches found for "foldingManager:"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":500,"end_line":575}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 501-575 of 774)
────────────────────────────────────────
501:     private var fileId: String { tab.url?.path ?? tab.fileName }
502:     
503:     var body: some View {
504:         GeometryReader { geometry in
505:             HStack(spacing: 0) {
506:                 // Line numbers + breakpoints + code folding (gutter)
507:                 //
508:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
509:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
510:                 if lineNumbersStyle != "off" {
511:                     ScrollView(showsIndicators: false) {
512:                         VStack(alignment: .trailing, spacing: 0) {
513:                             ForEach(0..<totalLines, id: \ .self) { lineIndex in
514:                                 HStack(spacing: 2) {
515:                                     // Fold chevron icon
516:                                     if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
517:                                         Button(action: { 
518:                                             foldingManager.toggleFold(fileId: fileId, line: lineIndex)
519:                                         }) {
520:                                             Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")
521:                                                 .font(.system(size: 10, weight: .regular))
522:                                                 .foregroundColor(.secondary.opacity(0.8))
523:                                                 .frame(width: 12, height: lineHeight)
524:                                         }
525:                                         .buttonStyle(.plain)
526:                                     } else {
527:                                         // Spacer for alignment
528:                                         Spacer()
529:                                             .frame(width: 12)
530:                                     }
531:                                     
532:                                     // Breakpoint indicator
533:                                     Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
534:                                         Circle()
535:                                             .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
536:                                             .overlay(
537:                                                 Circle()
538:                                                     .stroke(Color.red.opacity(0.6), lineWidth: 1)
539:                                                     .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
540:                                             )
541:                                             .frame(width: 10, height: 10)
542:                                     }
543:                                     .buttonStyle(.plain)
544:                                     .frame(width: 14, height: lineHeight)
545: 
546:                                     Text(displayText(for: lineIndex))
547:                                         .font(.system(size: 12, design: .monospaced))
548:                                         .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
549:                                         .frame(height: lineHeight)
550:                                         .contentShape(Rectangle())
551:                                         .onTapGesture {
552:                                             requestedLineSelection = lineIndex
553:                                         }
554:                                 }
555:                                 .frame(maxWidth: .infinity, alignment: .trailing)
556:                             }
557:                         }
558:                         .padding(.trailing, 4)
559:                         .offset(y: -CGFloat(scrollPosition) * lineHeight)
560:                     }
561:                     .frame(width: 70)
562:                     .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
563:                 }
564: 
565:                 // Editor
566:                 SyntaxHighlightingTextView(
567:                     text: $text,
568:                     filename: tab.fileName,
569:                     scrollPosition: $scrollPosition,
570:                     totalLines: $totalLines,
571:                     visibleLines: $visibleLines,
572:                     currentLineNumber: $currentLineNumber,
573:                     currentColumn: $currentColumn,
574:                     lineHeight: $lineHeight,
575:                     isActive: splitManager.activePaneId == pane.id,


>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
    @Binding var scrollPosition: Int
    @Binding var totalLines: Int
>>>REPLACE
    @Binding var scrollPosition: Int
    /// Pixel scroll offset (contentOffset.y) for smooth gutter alignment.
    @Binding var scrollOffset: CGFloat
    @Binding var totalLines: Int
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
    init(
        text: Binding<String>,
        filename: String,
        scrollPosition: Binding<Int>,
        totalLines: Binding<Int>,
>>>REPLACE
    init(
        text: Binding<String>,
        filename: String,
        scrollPosition: Binding<Int>,
        scrollOffset: Binding<CGFloat> = .constant(0),
        totalLines: Binding<Int>,
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
        self._scrollPosition = scrollPosition
        self._totalLines = totalLines
>>>REPLACE
        self._scrollPosition = scrollPosition
        self._scrollOffset = scrollOffset
        self._totalLines = totalLines
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
    init(
        text: Binding<String>,
        filename: String,
        scrollPosition: Binding<Int>,
        totalLines: Binding<Int>,
        visibleLines: Binding<Int>,
>>>REPLACE
    init(
        text: Binding<String>,
        filename: String,
        scrollPosition: Binding<Int>,
        scrollOffset: Binding<CGFloat> = .constant(0),
        totalLines: Binding<Int>,
        visibleLines: Binding<Int>,
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
        self.init(
            text: text,
            filename: filename,
            scrollPosition: scrollPosition,
            totalLines: totalLines,
>>>REPLACE
        self.init(
            text: text,
            filename: filename,
            scrollPosition: scrollPosition,
            scrollOffset: scrollOffset,
            totalLines: totalLines,
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
>>>FIND
        func updateScrollPosition(_ textView: UITextView) {
            guard let font = textView.font else { return }
            let lineHeight = font.lineHeight
            let scrollOffset = textView.contentOffset.y
            let line = Int(scrollOffset / lineHeight)
            
            // Update both synchronously to prevent feedback loop:
            // If we update parent.scrollPosition async, there's a race where
            // updateUIView sees old binding value != lastKnownScrollPosition
            // and scrolls back to the old position, causing jaggy scrolling.
            lastKnownScrollPosition = line
            parent.scrollPosition = line
        }
>>>REPLACE
        func updateScrollPosition(_ textView: UITextView) {
            guard let font = textView.font else { return }
            let lineHeight = font.lineHeight
            let yOffset = textView.contentOffset.y
            let line = Int(yOffset / lineHeight)

            // Update synchronously to prevent feedback loops/jitter.
            lastKnownScrollPosition = line
            parent.scrollPosition = line
            parent.scrollOffset = yOffset
        }
>>>END

>>>END>>>TOOL get_errors
{}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":10,"end_line":40}
>>>END

>>>TOOL search
{"query":"@Binding var scrollOffset", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END>>>TOOL get_errors
{}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":10,"end_line":50}
>>>END

>>>TOOL search
{"query":"parent.scrollOffset", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END


---

## 🔧 TOOL RESULTS

[get_errors]
✅ No errors or warnings

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 11-40 of 2058)
────────────────────────────────────────
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

---

[search]
No matches found for "@Binding var scrollOffset"

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 11-50 of 2058)
────────────────────────────────────────
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

---

[search]
No matches found for "parent.scrollOffset"

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift]
Applied 1 patch(es)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":10,"end_line":80}
>>>END

>>>TOOL search
{"query":"scrollOffset:", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL get_errors
{}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 11-80 of 2062)
────────────────────────────────────────
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

---

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:17: @Binding var scrollOffset: CGFloat
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:39: scrollOffset: Binding<CGFloat> = .constant(0),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:76: scrollOffset: Binding<CGFloat> = .constant(0),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:94: scrollOffset: scrollOffset,

---

[get_errors]
✅ No errors or warnings


>>>TOOL search
{"query":"wordWrap", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"lineWrapping", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"widthTracksTextView", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 11 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/SettingsManager.swift:23: @AppStorage("wordWrap") var wordWrap: Bool = true {
VSCodeiPadOS/VSCodeiPadOS/Services/TasksManager.swift:285: @Published var wordWrapEnabled: Bool = true
VSCodeiPadOS/VSCodeiPadOS/Services/TasksManager.swift:461: wordWrapEnabled.toggle()
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutputView.swift:9: let wordWrap: Bool
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutputView.swift:63: .lineLimit(wordWrap ? nil : 1)
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutputView.swift:105: .lineLimit(wordWrap ? nil : 1)
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutputView.swift:306: Image(systemName: outputManager.wordWrapEnabled ? "text.wrap" : "text.badge.xmark")
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutputView.swift:308: .foregroundColor(outputManager.wordWrapEnabled ? .blue : .secondary)
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/OutputView.swift:367: wordWrap: outputManager.wordWrapEnabled
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SettingsView.swift:83: @AppStorage("wordWrap") private var wordWrap: Bool = true
VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SettingsView.swift:121: Toggle("Word Wrap", isOn: $wordWrap)

---

[search]
No matches found for "lineWrapping"

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:186: textView.textContainer.widthTracksTextView = true


>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
    @State private var scrollPosition: Int = 0
    @State private var totalLines: Int = 1
>>>REPLACE
    @State private var scrollPosition: Int = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var totalLines: Int = 1
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
                        LineNumbersWithFolding(
                            fileId: tab.url?.path ?? tab.fileName,
                            totalLines: totalLines,
                            currentLine: currentLineNumber,
                            scrollOffset: CGFloat(scrollPosition) * lineHeight,
                            lineHeight: lineHeight,
                            requestedLineSelection: $requestedLineSelection,
                            foldingManager: foldingManager,
                            theme: theme
                        )
>>>REPLACE
                        LineNumbersWithFolding(
                            fileId: tab.url?.path ?? tab.fileName,
                            totalLines: totalLines,
                            currentLine: currentLineNumber,
                            scrollOffset: scrollOffset,
                            lineHeight: lineHeight,
                            requestedLineSelection: $requestedLineSelection,
                            foldingManager: foldingManager,
                            theme: theme
                        )
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
                        SyntaxHighlightingTextView(
                            text: $text,
                            filename: tab.fileName,
                            scrollPosition: $scrollPosition,
                            totalLines: $totalLines,
                            visibleLines: $visibleLines,
                            currentLineNumber: $currentLineNumber,
                            currentColumn: $currentColumn,
                            cursorIndex: $cursorIndex,
                            lineHeight: $lineHeight,
                            isActive: true,
                            fontSize: editorCore.editorFontSize,
                            requestedLineSelection: $requestedLineSelection,
                            requestedCursorIndex: $requestedCursorIndex,
                            onAcceptAutocomplete: {
>>>REPLACE
                        SyntaxHighlightingTextView(
                            text: $text,
                            filename: tab.fileName,
                            scrollPosition: $scrollPosition,
                            scrollOffset: $scrollOffset,
                            totalLines: $totalLines,
                            visibleLines: $visibleLines,
                            currentLineNumber: $currentLineNumber,
                            currentColumn: $currentColumn,
                            cursorIndex: $cursorIndex,
                            lineHeight: $lineHeight,
                            isActive: true,
                            fontSize: editorCore.editorFontSize,
                            requestedLineSelection: $requestedLineSelection,
                            requestedCursorIndex: $requestedCursorIndex,
                            onAcceptAutocomplete: {
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
                        MinimapView(
                            content: text,
                            scrollOffset: CGFloat(scrollPosition) * lineHeight,
                            scrollViewHeight: geometry.size.height,
                            totalContentHeight: CGFloat(totalLines) * lineHeight,
                            onScrollRequested: { newOffset in
                                // Minimap requested scroll - update editor position
                                // Convert back from pixels to line number
                                let newLine = Int(newOffset / lineHeight)
                                scrollPosition = max(0, min(newLine, totalLines - 1))
                            }
                        )
>>>REPLACE
                        MinimapView(
                            content: text,
                            scrollOffset: scrollOffset,
                            scrollViewHeight: geometry.size.height,
                            totalContentHeight: CGFloat(totalLines) * lineHeight,
                            onScrollRequested: { newOffset in
                                // Minimap requested scroll - update editor position
                                scrollOffset = newOffset
                                // Convert back from pixels to line number
                                let newLine = Int(newOffset / lineHeight)
                                scrollPosition = max(0, min(newLine, totalLines - 1))
                            }
                        )
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 0) {
>>>REPLACE
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 0) {
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(0..<totalLines, id: \.self) { lineIndex in
>>>REPLACE
            VStack(alignment: .trailing, spacing: 0) {
                // Match UITextView.textContainerInset.top (see SyntaxHighlightingTextView.swift)
                // so line numbers stay vertically aligned with the first line of text.
                ForEach(0..<totalLines, id: \.self) { lineIndex in
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
            .offset(y: -scrollOffset)
        }
    }
>>>REPLACE
            .padding(.top, 8)
            .offset(y: -scrollOffset)
        }
        .scrollDisabled(true)
    }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift
>>>FIND
    @State private var scrollPosition: Int = 0
    @State private var totalLines: Int = 1
>>>REPLACE
    @State private var scrollPosition: Int = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var totalLines: Int = 1
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift
>>>FIND
                        VStack(alignment: .trailing, spacing: 0) {
                            ForEach(0..<totalLines, id: \ .self) { lineIndex in
>>>REPLACE
                        VStack(alignment: .trailing, spacing: 0) {
                            // Match UITextView.textContainerInset.top (see SyntaxHighlightingTextView.swift)
                            ForEach(0..<totalLines, id: \ .self) { lineIndex in
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift
>>>FIND
                        .padding(.trailing, 4)
                        .offset(y: -CGFloat(scrollPosition) * lineHeight)
                    }
                    .frame(width: 70)
>>>REPLACE
                        .padding(.trailing, 4)
                        .padding(.top, 8)
                        .offset(y: -scrollOffset)
                    }
                    .scrollDisabled(true)
                    .frame(width: 70)
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift
>>>FIND
                SyntaxHighlightingTextView(
                    text: $text,
                    filename: tab.fileName,
                    scrollPosition: $scrollPosition,
                    totalLines: $totalLines,
                    visibleLines: $visibleLines,
                    currentLineNumber: $currentLineNumber,
                    currentColumn: $currentColumn,
                    lineHeight: $lineHeight,
                    isActive: splitManager.activePaneId == pane.id,
                    editorCore: editorCore,
                    requestedLineSelection: $requestedLineSelection
                )
>>>REPLACE
                SyntaxHighlightingTextView(
                    text: $text,
                    filename: tab.fileName,
                    scrollPosition: $scrollPosition,
                    scrollOffset: $scrollOffset,
                    totalLines: $totalLines,
                    visibleLines: $visibleLines,
                    currentLineNumber: $currentLineNumber,
                    currentColumn: $currentColumn,
                    lineHeight: $lineHeight,
                    isActive: splitManager.activePaneId == pane.id,
                    editorCore: editorCore,
                    requestedLineSelection: $requestedLineSelection
                )
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift
>>>FIND
        .onChange(of: pane.scrollOffset) { newOffset in
            if splitManager.syncScroll {
                scrollPosition = Int(newOffset / lineHeight)
            }
        }
>>>REPLACE
        .onChange(of: pane.scrollOffset) { newOffset in
            if splitManager.syncScroll {
                scrollOffset = newOffset
                scrollPosition = Int(newOffset / lineHeight)
            }
        }
>>>END

>>>TOOL get_errors
{}
>>>END

---

## 🔧 TOOL RESULTS

[get_errors]
✅ No errors or warnings

---

[FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift]
Applied 1 patch(es)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":440,"end_line":490}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":396,"end_line":470}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":570,"end_line":650}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":485,"end_line":585}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 441-490 of 2062)
────────────────────────────────────────
441:             let lines = textView.text.components(separatedBy: .newlines)
442:             DispatchQueue.main.async {
443:                 self.parent.totalLines = max(1, lines.count)
444:             }
445:         }
446:         
447:         func updateCursorPosition(_ textView: UITextView) {
448:             guard let selectedRange = textView.selectedTextRange else { return }
449:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
450:              
451:              let text = textView.text ?? ""
452:              let prefix = String(text.prefix(cursorPosition))
453:              let lines = prefix.components(separatedBy: .newlines)
454:              
455:              let lineNumber = lines.count
456:              let column = (lines.last?.count ?? 0) + 1
457:              
458:              DispatchQueue.main.async {
459:                  self.parent.currentLineNumber = lineNumber
460:                  self.parent.currentColumn = column
461:                  self.parent.cursorIndex = cursorPosition
462:              }
463:         }
464:         
465:         func updateScrollPosition(_ textView: UITextView) {
466:             guard let font = textView.font else { return }
467:             let lineHeight = font.lineHeight
468:             let yOffset = textView.contentOffset.y
469:             let line = Int(yOffset / lineHeight)
470: 
471:             // Update synchronously to prevent feedback loops/jitter.
472:             lastKnownScrollPosition = line
473:             parent.scrollPosition = line
474:             parent.scrollOffset = yOffset
475:         }
476:         
477:         func scrollToLine(_ line: Int, in textView: UITextView) {
478:             guard !isUpdatingFromMinimap else { return }
479:             isUpdatingFromMinimap = true
480:             
481:             let lines = textView.text.components(separatedBy: .newlines)
482:             guard line >= 0 && line < lines.count else {
483:                 isUpdatingFromMinimap = false
484:                 return
485:             }
486:             
487:             var characterPosition = 0
488:             for i in 0..<line {
489:                 characterPosition += lines[i].count + 1
490:             }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 397-470 of 1079)
────────────────────────────────────────
397:         .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
398:         .onTapGesture { editorCore.selectTab(id: tab.id) }
399:     }
400: }
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 571-650 of 1079)
────────────────────────────────────────
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
601:     var body: some View {
602:         ScrollView(showsIndicators: false) {
603:             VStack(alignment: .trailing, spacing: 0) {
604:                 // Match UITextView.textContainerInset.top (see SyntaxHighlightingTextView.swift)
605:                 // so line numbers stay vertically aligned with the first line of text.
606:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
607:                     if !foldingManager.isLineFolded(line: lineIndex) {
608:                         HStack(spacing: 2) {
609:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
610:                                 Circle()
611:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
612:                                     .overlay(
613:                                         Circle()
614:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
615:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
616:                                     )
617:                                     .frame(width: 10, height: 10)
618:                                     .padding(.leading, 2)
619:                             }
620:                             .buttonStyle(.plain)
621:                             .frame(width: 14, height: lineHeight)
622: 
623:                             if foldingManager.isFoldable(line: lineIndex) {
624:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
625:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
626:                                         .font(.system(size: 8))
627:                                         .foregroundColor(theme.lineNumber)
628:                                 }
629:                                 .buttonStyle(.plain)
630:                                 .frame(width: 14, height: lineHeight)
631:                             } else {
632:                                 Spacer().frame(width: 14)
633:                             }
634: 
635:                             Text(displayText(for: lineIndex))
636:                                 .font(.system(size: 12, design: .monospaced))
637:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
638:                                 .frame(height: lineHeight)
639:                                 .contentShape(Rectangle())
640:                                 .onTapGesture {
641:                                     // FEAT-041: click line number selects entire line
642:                                     requestedLineSelection = lineIndex
643:                                 }
644:                         }
645:                         .frame(maxWidth: .infinity, alignment: .trailing)
646:                         .padding(.trailing, 4)
647:                     }
648:                 }
649:             }
650:             .padding(.top, 8)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 486-585 of 780)
────────────────────────────────────────
486:     @ObservedObject var splitManager: SplitEditorManager
487:     @ObservedObject var editorCore: EditorCore
488:     @ObservedObject private var debugManager = DebugManager.shared
489:     @ObservedObject private var foldingManager = CodeFoldingManager.shared
490:     @State private var text: String = ""
491:     @State private var scrollPosition: Int = 0
492:     @State private var scrollOffset: CGFloat = 0
493:     @State private var totalLines: Int = 1
494:     @State private var visibleLines: Int = 20
495:     @State private var currentLineNumber: Int = 1
496:     @State private var currentColumn: Int = 1
497:     @State private var lineHeight: CGFloat = 17
498:     @State private var requestedLineSelection: Int? = nil
499: 
500:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
501:     
502:     private var fileId: String { tab.url?.path ?? tab.fileName }
503:     
504:     var body: some View {
505:         GeometryReader { geometry in
506:             HStack(spacing: 0) {
507:                 // Line numbers + breakpoints + code folding (gutter)
508:                 //
509:                 // IMPORTANT: keep gutter in sync with the editor scroll position. The gutter ScrollView
510:                 // is scroll-disabled, and we offset the content to match the editor's scroll.
511:                 if lineNumbersStyle != "off" {
512:                     ScrollView(showsIndicators: false) {
513:                         VStack(alignment: .trailing, spacing: 0) {
514:                             // Match UITextView.textContainerInset.top (see SyntaxHighlightingTextView.swift)
515:                             ForEach(0..<totalLines, id: \ .self) { lineIndex in
516:                                 HStack(spacing: 2) {
517:                                     // Fold chevron icon
518:                                     if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
519:                                         Button(action: { 
520:                                             foldingManager.toggleFold(fileId: fileId, line: lineIndex)
521:                                         }) {
522:                                             Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")
523:                                                 .font(.system(size: 10, weight: .regular))
524:                                                 .foregroundColor(.secondary.opacity(0.8))
525:                                                 .frame(width: 12, height: lineHeight)
526:                                         }
527:                                         .buttonStyle(.plain)
528:                                     } else {
529:                                         // Spacer for alignment
530:                                         Spacer()
531:                                             .frame(width: 12)
532:                                     }
533:                                     
534:                                     // Breakpoint indicator
535:                                     Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
536:                                         Circle()
537:                                             .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
538:                                             .overlay(
539:                                                 Circle()
540:                                                     .stroke(Color.red.opacity(0.6), lineWidth: 1)
541:                                                     .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
542:                                             )
543:                                             .frame(width: 10, height: 10)
544:                                     }
545:                                     .buttonStyle(.plain)
546:                                     .frame(width: 14, height: lineHeight)
547: 
548:                                     Text(displayText(for: lineIndex))
549:                                         .font(.system(size: 12, design: .monospaced))
550:                                         .foregroundColor(lineIndex + 1 == currentLineNumber ? .primary : .secondary.opacity(0.6))
551:                                         .frame(height: lineHeight)
552:                                         .contentShape(Rectangle())
553:                                         .onTapGesture {
554:                                             requestedLineSelection = lineIndex
555:                                         }
556:                                 }
557:                                 .frame(maxWidth: .infinity, alignment: .trailing)
558:                             }
559:                         }
560:                         .padding(.trailing, 4)
561:                         .padding(.top, 8)
562:                         .offset(y: -scrollOffset)
563:                     }
564:                     .scrollDisabled(true)
565:                     .frame(width: 70)
566:                     .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
567:                 }
568: 
569:                 // Editor
570:                 SyntaxHighlightingTextView(
571:                     text: $text,
572:                     filename: tab.fileName,
573:                     scrollPosition: $scrollPosition,
574:                     scrollOffset: $scrollOffset,
575:                     totalLines: $totalLines,
576:                     visibleLines: $visibleLines,
577:                     currentLineNumber: $currentLineNumber,
578:                     currentColumn: $currentColumn,
579:                     lineHeight: $lineHeight,
580:                     isActive: splitManager.activePaneId == pane.id,
581:                     editorCore: editorCore,
582:                     requestedLineSelection: $requestedLineSelection
583:                 )
584:                 .onChange(of: text) { newValue in
585:                     pane.updateTabContent(newValue)


>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift
>>>FIND
                // Mini minimap
                MinimapView(
                    content: text,
                    scrollOffset: CGFloat(scrollPosition) * lineHeight,
                    scrollViewHeight: geometry.size.height,
                    totalContentHeight: CGFloat(totalLines) * lineHeight
                )
                .frame(width: 60)
>>>REPLACE
                // Mini minimap
                MinimapView(
                    content: text,
                    scrollOffset: scrollOffset,
                    scrollViewHeight: geometry.size.height,
                    totalContentHeight: CGFloat(totalLines) * lineHeight,
                    onScrollRequested: { newOffset in
                        scrollOffset = newOffset
                        scrollPosition = Int(newOffset / max(lineHeight, 1))
                    }
                )
                .frame(width: 60)
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift
>>>FIND
                )
                .onChange(of: text) { newValue in
                    pane.updateTabContent(newValue)
                    
                    // Sync scroll if enabled
                    if splitManager.syncScroll {
                        splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
                    }
                }
>>>REPLACE
                )
                .onChange(of: text) { newValue in
                    pane.updateTabContent(newValue)
                }
                .onChange(of: scrollOffset) { newOffset in
                    // Track latest scroll offset for this pane, and sync if enabled.
                    if abs(pane.scrollOffset - newOffset) > 0.5 {
                        pane.scrollOffset = newOffset
                    }
                    if splitManager.syncScroll {
                        splitManager.syncScrollOffset(newOffset, fromPaneId: pane.id)
                    }
                }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift
>>>FIND
        .onChange(of: pane.scrollOffset) { newOffset in
            if splitManager.syncScroll {
                scrollOffset = newOffset
                scrollPosition = Int(newOffset / lineHeight)
            }
        }
>>>REPLACE
        .onChange(of: pane.scrollOffset) { newOffset in
            guard splitManager.syncScroll else { return }
            // Avoid feedback loop when we're the source pane.
            if abs(scrollOffset - newOffset) > 0.5 {
                scrollOffset = newOffset
                scrollPosition = Int(newOffset / max(lineHeight, 1))
            }
        }
>>>END

>>>TOOL get_errors
{}
>>>END

---

## 🔧 TOOL RESULTS

[get_errors]
✅ No errors or warnings

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift]
Applied 1 patch(es)

---

[FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift]
Applied 1 patch(es)


>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
                        MinimapView(
                            content: text,
                            scrollOffset: scrollOffset,
                            scrollViewHeight: geometry.size.height,
                            totalContentHeight: CGFloat(totalLines) * lineHeight,
                            onScrollRequested: { newOffset in
                                // Minimap requested scroll - update editor position
                                scrollOffset = newOffset
                                // Convert back from pixels to line number
                                let newLine = Int(newOffset / lineHeight)
                                scrollPosition = max(0, min(newLine, totalLines - 1))
                            }
                        )
>>>REPLACE
                        MinimapView(
                            content: text,
                            scrollOffset: scrollOffset,
                            scrollViewHeight: geometry.size.height,
                            totalContentHeight: CGFloat(totalLines) * lineHeight,
                            onScrollRequested: { newOffset in
                                // Minimap requested scroll - update editor position
                                scrollOffset = newOffset
                                // Convert back from pixels to line number
                                let newLine = Int(newOffset / max(lineHeight, 1))
                                scrollPosition = max(0, min(newLine, totalLines - 1))
                            }
                        )
>>>END

>>>TOOL get_errors
{}
>>>END

---

## 🔧 TOOL RESULTS

[get_errors]
✅ No errors or warnings

---

[FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift]
Applied 1 patch(es)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift","start_line":180,"end_line":260}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 181-260 of 931)
────────────────────────────────────────
181:                 previousNonEmptyWasSingleLineComment = false
182:                 if let comment = commentStack.popLast() {
183:                     if index - comment.startLine > 1 {
184:                         regions.append(FoldRegion(
185:                             startLine: comment.startLine,
186:                             endLine: index,
187:                             type: .comment,
188:                             label: "Comment"
189:                         ))
190:                     }
191:                 }
192:             } else {
193:                 previousNonEmptyWasSingleLineComment = false
194:             }
195:             
196:             // MARK: - Class/Struct/Enum/Protocol/Extension Detection
197:             if let declaration = detectDeclaration(trimmed) {
198:                 if trimmed.contains("{") {
199:                     blockStack.append((declaration.type, index, declaration.label))
200:                 } else {
201:                     // Declaration without opening brace - look ahead for it
202:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
203:                         braceLinesClaimed.insert(braceLine)
204:                         blockStack.append((declaration.type, index, declaration.label))
205:                     }
206:                 }
207:             }
208:             
209:             // MARK: - Function/Method Detection
210:             if let functionInfo = detectFunction(trimmed) {
211:                 if trimmed.contains("{") {
212:                     blockStack.append((.function, index, functionInfo))
213:                 } else {
214:                     // Function without opening brace - look ahead
215:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
216:                         braceLinesClaimed.insert(braceLine)
217:                         blockStack.append((.function, index, functionInfo))
218:                     }
219:                 }
220:             }
221:             
222:             // MARK: - Control Flow Detection (if, guard, for, while, switch, etc.)
223:             if let controlFlowLabel = detectControlFlow(trimmed) {
224:                 if trimmed.contains("{") {
225:                     blockStack.append((.controlFlow, index, controlFlowLabel))
226:                 } else {
227:                     if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
228:                         braceLinesClaimed.insert(braceLine)
229:                         blockStack.append((.controlFlow, index, controlFlowLabel))
230:                     }
231:                 }
232:             }
233:             
234:             // MARK: - Generic Block Detection
235:             // Avoid adding a generic block for a standalone "{" that belongs to a previously detected declaration.
236:             if trimmed.hasSuffix("{"),
237:                trimmed != "{",
238:                !braceLinesClaimed.contains(index),
239:                !isDeclarationLine(trimmed),
240:                !isFunctionLine(trimmed) {
241:                 blockStack.append((.genericBlock, index, nil))
242:             }
243: 
244:             _ = leadingWhitespace // keep param for potential future heuristics
245:         }
246:         
247:         // Handle any remaining unclosed blocks
248:         while let lastBlock = blockStack.popLast() {
249:             if lines.count - 1 - lastBlock.startLine > 1 {
250:                 regions.append(FoldRegion(
251:                     startLine: lastBlock.startLine,
252:                     endLine: lines.count - 1,
253:                     type: lastBlock.type,
254:                     label: lastBlock.label
255:                 ))
256:             }
257:         }
258:         
259:         // Sort regions by start line
260:         regions.sort { $0.startLine < $1.startLine }


>>>TOOL search
{"query":"foldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"FoldingLayoutManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL search
{"query":"fileId", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "foldingManager"

---

[search]
No matches found for "FoldingLayoutManager"

---

[search]
No matches found for "fileId"


>>>TOOL search
{"query":"var foldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/*.swift"}
>>>END

>>>TOOL search
{"query":"var fileId", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:489: @ObservedObject private var foldingManager = CodeFoldingManager.shared

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:502: private var fileId: String { tab.url?.path ?? tab.fileName }
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:502: private var fileId: String { tab.url?.path ?? tab.fileName }


>>>TOOL search
{"query":"foldingManager", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"fileId", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":640,"end_line":720}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 16 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:28: let foldingManager = owner.foldingManager,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/FoldingLayoutManager.swift:41: if foldingManager.isLineFolded(fileId: fileId, line: lineIndex) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:489: @ObservedObject private var foldingManager = CodeFoldingManager.shared
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:518: if foldingManager.isFoldable(fileId: fileId, line: lineIndex) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:520: foldingManager.toggleFold(fileId: fileId, line: lineIndex)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:522: Image(systemName: foldingManager.isFolded(fileId: fileId, line: lineIndex) ? "chevron.right" : "chevron.down")
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:424: @ObservedObject private var foldingManager = CodeFoldingManager.shared
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:448: foldingManager: foldingManager,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:502: foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path ?? tab.fileName)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:566: foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:570: foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:595: @ObservedObject var foldingManager: CodeFoldingManager
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:607: if !foldingManager.isLineFolded(line: lineIndex) {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:623: if foldingManager.isFoldable(line: lineIndex) {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:624: Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:625: Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")

---

[search]
No matches found for "fileId"

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 641-720 of 1079)
────────────────────────────────────────
641:                                     // FEAT-041: click line number selects entire line
642:                                     requestedLineSelection = lineIndex
643:                                 }
644:                         }
645:                         .frame(maxWidth: .infinity, alignment: .trailing)
646:                         .padding(.trailing, 4)
647:                     }
648:                 }
649:             }
650:             .padding(.top, 8)
651:             .offset(y: -scrollOffset)
652:         }
653:         .scrollDisabled(true)
654:     }
655: 
656:     private func displayText(for lineIndex: Int) -> String {
657:         switch lineNumbersStyle {
658:         case "relative":
659:             // VS Code-style: current line shows absolute, others show relative distance
660:             let lineNumber = lineIndex + 1
661:             if lineNumber == currentLine { return "\(lineNumber)" }
662:             return "\(abs(lineNumber - currentLine))"
663: 
664:         case "interval":
665:             let lineNumber = lineIndex + 1
666:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
667: 
668:         default:
669:             return "\(lineIndex + 1)"
670:         }
671:     }
672: }
673: 
674: // MARK: - Autocomplete Popup
675: 
676: struct AutocompletePopup: View {
677:     let suggestions: [AutocompleteSuggestion]
678:     let selectedIndex: Int
679:     let theme: Theme
680:     let onSelectIndex: (Int) -> Void
681:     
682:     var body: some View {
683:         VStack(alignment: .leading, spacing: 0) {
684:             ForEach(suggestions.indices, id: \.self) { index in
685:                 let s = suggestions[index]
686:                 HStack(spacing: 6) {
687:                     Image(systemName: icon(for: s.kind))
688:                         .font(.caption)
689:                         .foregroundColor(color(for: s.kind))
690:                     VStack(alignment: .leading, spacing: 1) {
691:                         Text(s.displayText)
692:                             .font(.system(size: 12, design: .monospaced))
693:                             .foregroundColor(theme.editorForeground)
694:                         if s.insertText != s.displayText && !s.insertText.isEmpty {
695:                             Text(s.insertText)
696:                                 .font(.system(size: 10, design: .monospaced))
697:                                 .foregroundColor(theme.editorForeground.opacity(0.55))
698:                                 .lineLimit(1)
699:                         }
700:                     }
701:                     Spacer()
702:                 }
703:                 .padding(.horizontal, 8).padding(.vertical, 6)
704:                 .background(index == selectedIndex ? theme.selection : Color.clear)
705:                 .contentShape(Rectangle())
706:                 .onTapGesture { onSelectIndex(index) }
707:             }
708:         }
709:         .frame(width: 260)
710:         .background(theme.editorBackground)
711:         .cornerRadius(6)
712:         .shadow(radius: 8)
713:     }
714:     
715:     private func icon(for kind: AutocompleteSuggestionKind) -> String {
716:         switch kind {
717:         case .keyword: return "key.fill"
718:         case .symbol: return "cube.fill"
719:         case .stdlib: return "curlybraces"
720:         case .member: return "arrow.right.circle.fill"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Services/SettingsManager.swift","start_line":1,"end_line":80}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/SettingsManager.swift (lines 2-80 of 99)
────────────────────────────────────────
2: import SwiftUI
3: import UIKit
4: 
5: @MainActor
6: final class SettingsManager: ObservableObject {
7:     static let shared = SettingsManager()
8: 
9:     // MARK: - AppStorage keys
10: 
11:     @AppStorage("fontSize") var fontSize: Double = 14 {
12:         willSet { objectWillChange.send() }
13:     }
14: 
15:     @AppStorage("fontFamily") var fontFamily: String = "Menlo" {
16:         willSet { objectWillChange.send() }
17:     }
18: 
19:     @AppStorage("tabSize") var tabSize: Int = 4 {
20:         willSet { objectWillChange.send() }
21:     }
22: 
23:     @AppStorage("wordWrap") var wordWrap: Bool = true {
24:         willSet { objectWillChange.send() }
25:     }
26: 
27:     /// Mirrors SettingsView's picker tags: off / afterDelay / onFocusChange / onWindowChange
28:     @AppStorage("autoSave") var autoSaveRaw: String = AutoSaveMode.off.rawValue {
29:         willSet { objectWillChange.send() }
30:     }
31: 
32:     @AppStorage("minimapEnabled") var minimapEnabled: Bool = true {
33:         willSet { objectWillChange.send() }
34:     }
35: 
36:     private init() {}
37: 
38:     // MARK: - Types
39: 
40:     enum AutoSaveMode: String, CaseIterable {
41:         case off
42:         case afterDelay
43:         case onFocusChange
44:         case onWindowChange
45:     }
46: 
47:     var autoSaveMode: AutoSaveMode {
48:         get { AutoSaveMode(rawValue: autoSaveRaw) ?? .off }
49:         set { autoSaveRaw = newValue.rawValue }
50:     }
51: 
52:     /// Delay used when `autoSaveMode == .afterDelay`.
53:     let autoSaveDelay: TimeInterval = 1.0
54: 
55:     // MARK: - Derived editor styling
56: 
57:     var clampedTabSize: Int {
58:         max(1, min(tabSize, 16))
59:     }
60: 
61:     var editorUIFont: UIFont {
62:         font(forFamily: fontFamily, size: CGFloat(fontSize))
63:     }
64: 
65:     func font(forFamily family: String, size: CGFloat) -> UIFont {
66:         // Try common iOS font PostScript names first.
67:         let candidates: [String]
68:         switch family {
69:         case "Menlo":
70:             candidates = ["Menlo-Regular", "Menlo"]
71:         case "Courier New":
72:             candidates = ["CourierNewPSMT", "Courier New"]
73:         case "SF Mono":
74:             candidates = ["SFMono-Regular", "SF Mono", ".SFMono-Regular"]
75:         case "Fira Code":
76:             candidates = ["FiraCode-Regular", "Fira Code"]
77:         case "JetBrains Mono":
78:             candidates = ["JetBrainsMono-Regular", "JetBrains Mono"]
79:         default:
80:             candidates = [family]


>>>TOOL search
{"query":"SyntaxHighlightingTextView(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"scrollOffset:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:461: SyntaxHighlightingTextView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:544: SyntaxHighlightingTextView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:570: SyntaxHighlightingTextView(

---

[search]
Found 16 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:412: @State private var scrollOffset: CGFloat = 0
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:445: scrollOffset: scrollOffset,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:465: scrollOffset: $scrollOffset,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:513: scrollOffset: scrollOffset,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:592: let scrollOffset: CGFloat
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift:13: let scrollOffset: CGFloat
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:29: @Published var scrollOffset: CGFloat = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:492: @State private var scrollOffset: CGFloat = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:574: scrollOffset: $scrollOffset,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:600: scrollOffset: scrollOffset,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:17: @Binding var scrollOffset: CGFloat
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:39: scrollOffset: Binding<CGFloat> = .constant(0),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:76: scrollOffset: Binding<CGFloat> = .constant(0),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:94: scrollOffset: scrollOffset,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:29: @Published var scrollOffset: CGFloat = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:568: scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),


>>>TOOL search
{"query":"getFoldedLineRanges", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL search
{"query":"collapsedLines", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":560,"end_line":660}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:806: func getFoldedLineRanges() -> [ClosedRange<Int>] {

---

[search]
Found 6 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:72: @Published var collapsedLines: Set<Int> = []
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:724: return collapsedLines.contains(line)
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:727: /// Checks if a line should be hidden for a specific file (does not rely on `collapsedLines`)
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:821: return collapsedLines.count
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:844: collapsedLines.removeAll()
VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:848: collapsedLines.insert(line)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 561-660 of 790)
────────────────────────────────────────
561:                         .padding(.top, 8)
562:                         .offset(y: -scrollOffset)
563:                     }
564:                     .scrollDisabled(true)
565:                     .frame(width: 70)
566:                     .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
567:                 }
568: 
569:                 // Editor
570:                 SyntaxHighlightingTextView(
571:                     text: $text,
572:                     filename: tab.fileName,
573:                     scrollPosition: $scrollPosition,
574:                     scrollOffset: $scrollOffset,
575:                     totalLines: $totalLines,
576:                     visibleLines: $visibleLines,
577:                     currentLineNumber: $currentLineNumber,
578:                     currentColumn: $currentColumn,
579:                     lineHeight: $lineHeight,
580:                     isActive: splitManager.activePaneId == pane.id,
581:                     editorCore: editorCore,
582:                     requestedLineSelection: $requestedLineSelection
583:                 )
584:                 .onChange(of: text) { newValue in
585:                     pane.updateTabContent(newValue)
586:                 }
587:                 .onChange(of: scrollOffset) { newOffset in
588:                     // Track latest scroll offset for this pane, and sync if enabled.
589:                     if abs(pane.scrollOffset - newOffset) > 0.5 {
590:                         pane.scrollOffset = newOffset
591:                     }
592:                     if splitManager.syncScroll {
593:                         splitManager.syncScrollOffset(newOffset, fromPaneId: pane.id)
594:                     }
595:                 }
596:                 
597:                 // Mini minimap
598:                 MinimapView(
599:                     content: text,
600:                     scrollOffset: scrollOffset,
601:                     scrollViewHeight: geometry.size.height,
602:                     totalContentHeight: CGFloat(totalLines) * lineHeight,
603:                     onScrollRequested: { newOffset in
604:                         scrollOffset = newOffset
605:                         scrollPosition = Int(newOffset / max(lineHeight, 1))
606:                     }
607:                 )
608:                 .frame(width: 60)
609:             }
610:             // Sticky Header Overlay (FEAT-040)
611:             StickyHeaderView(
612:                 text: text,
613:                 currentLine: scrollPosition, // Using scrollPosition as approximate top line
614:                 theme: ThemeManager.shared.currentTheme,
615:                 lineHeight: lineHeight,
616:                 onSelect: { line in
617:                     requestedLineSelection = line
618:                 }
619:             )
620:             .padding(.leading, 70) // Offset for line numbers + folding icons
621:             .padding(.trailing, 60) // Offset for minimap
622:             
623:             // Peek Definition Overlay
624:             if let peekState = editorCore.peekState, editorCore.activeTabId == tab.id {
625:                  // Calculate simplified position: center of screen for now, but conceptually "inline"
626:                  // To make it truly inline, we'd need more complex geometry, but overlay is a good start.
627:                  VStack {
628:                      Spacer()
629:                          .frame(height: max(0, CGFloat(peekState.sourceLine - scrollPosition) * lineHeight + lineHeight + 20))
630:                      
631:                      PeekDefinitionView(
632:                          editorCore: editorCore,
633:                          targetFile: peekState.file,
634:                          targetLine: peekState.line,
635:                          content: peekState.content,
636:                          onClose: { editorCore.closePeekDefinition() },
637:                          onOpen: {
638:                              editorCore.openFile(FileItem(name: URL(fileURLWithPath: peekState.file).lastPathComponent, path: peekState.file, isDirectory: false))
639:                              editorCore.closePeekDefinition()
640:                          }
641:                      )
642:                      .padding(.horizontal)
643:                      .padding(.bottom, 20)
644:                      
645:                      Spacer()
646:                  }
647:                  .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
648:                  .background(Color.black.opacity(0.01)) // Capture taps outside if needed, or let them pass
649:                  .transition(.opacity)
650:                  .zIndex(100)
651:             }
652:         }
653:         .onAppear {
654:             text = tab.content
655:         }
656:         .onChange(of: tab.id) { _ in
657:             text = tab.content
658:         }
659:         .onChange(of: pane.scrollOffset) { newOffset in
660:             guard splitManager.syncScroll else { return }


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":656,"end_line":720}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":656,"end_line":740}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 657-720 of 790)
────────────────────────────────────────
657:             text = tab.content
658:         }
659:         .onChange(of: pane.scrollOffset) { newOffset in
660:             guard splitManager.syncScroll else { return }
661:             // Avoid feedback loop when we're the source pane.
662:             if abs(scrollOffset - newOffset) > 0.5 {
663:                 scrollOffset = newOffset
664:                 scrollPosition = Int(newOffset / max(lineHeight, 1))
665:             }
666:         }
667:     }
668:     
669:     private func displayText(for lineIndex: Int) -> String {
670:         switch lineNumbersStyle {
671:         case "relative":
672:             let lineNumber = lineIndex + 1
673:             if lineNumber == currentLineNumber { return "\(lineNumber)" }
674:             return "\(abs(lineNumber - currentLineNumber))"
675:         case "interval":
676:             let lineNumber = lineIndex + 1
677:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
678:         default:
679:             return "\(lineIndex + 1)"
680:         }
681:     }
682: }
683: 
684: // MARK: - Split Drag Handle
685: 
686: struct SplitDragHandle: View {
687:     let direction: SplitDirection
688:     let onDrag: (CGFloat) -> Void
689:     
690:     @State private var isDragging = false
691:     @GestureState private var dragOffset: CGFloat = 0
692:     
693:     var body: some View {
694:         ZStack {
695:             // Background
696:             Rectangle()
697:                 .fill(Color(UIColor.separator))
698:             
699:             // Handle indicator
700:             if direction == .horizontal {
701:                 VStack(spacing: 2) {
702:                     ForEach(0..<3, id: \.self) { _ in
703:                         Circle()
704:                             .fill(isDragging ? Color.accentColor : Color.secondary)
705:                             .frame(width: 3, height: 3)
706:                     }
707:                 }
708:             } else {
709:                 HStack(spacing: 2) {
710:                     ForEach(0..<3, id: \.self) { _ in
711:                         Circle()
712:                             .fill(isDragging ? Color.accentColor : Color.secondary)
713:                             .frame(width: 3, height: 3)
714:                     }
715:                 }
716:             }
717:         }
718:         .frame(
719:             width: direction == .horizontal ? 6 : nil,
720:             height: direction == .vertical ? 6 : nil

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 657-740 of 790)
────────────────────────────────────────
657:             text = tab.content
658:         }
659:         .onChange(of: pane.scrollOffset) { newOffset in
660:             guard splitManager.syncScroll else { return }
661:             // Avoid feedback loop when we're the source pane.
662:             if abs(scrollOffset - newOffset) > 0.5 {
663:                 scrollOffset = newOffset
664:                 scrollPosition = Int(newOffset / max(lineHeight, 1))
665:             }
666:         }
667:     }
668:     
669:     private func displayText(for lineIndex: Int) -> String {
670:         switch lineNumbersStyle {
671:         case "relative":
672:             let lineNumber = lineIndex + 1
673:             if lineNumber == currentLineNumber { return "\(lineNumber)" }
674:             return "\(abs(lineNumber - currentLineNumber))"
675:         case "interval":
676:             let lineNumber = lineIndex + 1
677:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
678:         default:
679:             return "\(lineIndex + 1)"
680:         }
681:     }
682: }
683: 
684: // MARK: - Split Drag Handle
685: 
686: struct SplitDragHandle: View {
687:     let direction: SplitDirection
688:     let onDrag: (CGFloat) -> Void
689:     
690:     @State private var isDragging = false
691:     @GestureState private var dragOffset: CGFloat = 0
692:     
693:     var body: some View {
694:         ZStack {
695:             // Background
696:             Rectangle()
697:                 .fill(Color(UIColor.separator))
698:             
699:             // Handle indicator
700:             if direction == .horizontal {
701:                 VStack(spacing: 2) {
702:                     ForEach(0..<3, id: \.self) { _ in
703:                         Circle()
704:                             .fill(isDragging ? Color.accentColor : Color.secondary)
705:                             .frame(width: 3, height: 3)
706:                     }
707:                 }
708:             } else {
709:                 HStack(spacing: 2) {
710:                     ForEach(0..<3, id: \.self) { _ in
711:                         Circle()
712:                             .fill(isDragging ? Color.accentColor : Color.secondary)
713:                             .frame(width: 3, height: 3)
714:                     }
715:                 }
716:             }
717:         }
718:         .frame(
719:             width: direction == .horizontal ? 6 : nil,
720:             height: direction == .vertical ? 6 : nil
721:         )
722:         .contentShape(Rectangle())
723:         .gesture(
724:             DragGesture()
725:                 .updating($dragOffset) { value, state, _ in
726:                     let delta = direction == .horizontal ? value.translation.width : value.translation.height
727:                     state = delta
728:                 }
729:                 .onChanged { value in
730:                     isDragging = true
731:                     let delta = direction == .horizontal ? value.translation.width : value.translation.height
732:                     onDrag(delta)
733:                 }
734:                 .onEnded { _ in
735:                     isDragging = false
736:                 }
737:         )
738:         .onHover { hovering in
739:             if hovering {
740:                 #if targetEnvironment(macCatalyst)


>>>REPORT
Task: verify/fix line numbers rendering/alignment/scroll/click behavior in VSCodeiPadOS.

Findings (how line numbers are rendered)
- Line numbers are rendered as separate SwiftUI gutters (not inside the UITextView):
  - Main editor: `LineNumbersWithFolding` in `VSCodeiPadOS/VSCodeiPadOS/ContentView.swift` (seen around lines 586+; gutter offset applied at lines 650-653).
  - Split editor: custom gutter inside `PaneEditorView` in `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift` (seen around lines 504+).

Confirmed behaviors (before fixes, per code)
- Gutter attempted to follow editor scroll by offsetting line number content via `scrollPosition * lineHeight` (line-based), e.g. Split editor gutter: `.offset(y: -CGFloat(scrollPosition) * lineHeight)` at `SplitEditorView.swift` line 559 (tool excerpt).
- Gutter ScrollViews were not consistently `.scrollDisabled(true)` (split editor gutter had none; main editor gutter had none previously).
- Top inset mismatch: UITextView uses `textContainerInset.top = 8` (`SyntaxHighlightingTextView.swift` line 176), but gutters did not apply matching top padding, causing vertical misalignment at the first line.

Fixes applied
1) Added pixel-precise scroll offset binding from UITextView to SwiftUI
- File: `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift`
  - Added `@Binding var scrollOffset: CGFloat` (lines 15-18 in latest excerpt).
  - Updated initializers to accept `scrollOffset: Binding<CGFloat> = .constant(0)` (lines 35-40 and 71-77 in latest excerpt).
  - Updated coordinator `updateScrollPosition` to set both:
    - `parent.scrollPosition = line` and
    - `parent.scrollOffset = yOffset`
    (seen at lines 465-475 in latest excerpt).

2) Main editor gutter (ContentView) now uses pixel scrollOffset + top padding + is non-scrollable
- File: `VSCodeiPadOS/VSCodeiPadOS/ContentView.swift`
  - Added state: `@State private var scrollOffset: CGFloat = 0` (line 412 in excerpt).
  - Passed `scrollOffset: $scrollOffset` into `SyntaxHighlightingTextView` (lines 461-466).
  - `LineNumbersWithFolding` now receives `scrollOffset: scrollOffset` (line 445).
  - Gutter now matches UITextView top inset and is locked from user scroll:
    - `.padding(.top, 8)` and `.offset(y: -scrollOffset)` (lines 650-652)
    - `.scrollDisabled(true)` (line 653)

3) Split editor gutter now uses pixel scrollOffset + top padding + is non-scrollable; minimap scroll updates scrollOffset/scrollPosition
- File: `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift`
  - Added state: `@State private var scrollOffset: CGFloat = 0` (line 492 in excerpt).
  - Gutter now:
    - `.padding(.top, 8)` and `.offset(y: -scrollOffset)` (lines 561-563)
    - `.scrollDisabled(true)` (line 564)
  - Editor now passes `scrollOffset: $scrollOffset` into `SyntaxHighlightingTextView` (lines 570-575).
  - Minimap now uses pixel offset and can request scroll:
    - `MinimapView(scrollOffset: scrollOffset, ..., onScrollRequested: { newOffset in scrollOffset = newOffset; scrollPosition = Int(newOffset / max(lineHeight, 1)) })`
    (lines 597-607)
  - Sync scroll updated to work with pixel offsets:
    - On local scrollOffset change, update `pane.scrollOffset` and call `splitManager.syncScrollOffset(newOffset, fromPaneId: pane.id)` (lines 587-595).
    - On receiving `pane.scrollOffset`, update local `scrollOffset`/`scrollPosition` with loop guard (lines 659-665).

Click-to-select line (verified)
- Main editor gutter: line number `Text(...).onTapGesture { requestedLineSelection = lineIndex }` in `ContentView.swift` lines 635-643.
- Split editor gutter: same pattern in `SplitEditorView.swift` lines 548-555.
- Selection implementation: `SyntaxHighlightingTextView.Coordinator.scrollToAndSelectLine` selects entire line and scrolls to it (`SyntaxHighlightingTextView.swift` lines 491-510 in earlier excerpt).

Build status
- Swift diagnostics: `get_errors` returned ✅ No errors or warnings after changes.

Files touched (directly relevant)
- VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift
- VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
- VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift
>>>END
