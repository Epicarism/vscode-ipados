# Agent: opus-architecture-review
**Status:** done
**Tokens:** 2,142
**Cost:** $0.0000
**Time:** 2026-02-11T01:17:17.043Z

## Task
AUDIT: Review the overall ARCHITECTURE of VSCodeiPadOS. Document: 1) App structure (Views, Models, Services, etc) 2) Data flow patterns 3) State management approach 4) Key singletons/managers 5) Dependencies between components. Create architecture diagram in text/markdown form.

## Response
I'll audit the architecture of VSCodeiPadOS by systematically exploring the codebase. Let me start by understanding the project structure.

>>>TOOL list_dir
{"path": "."}
>>>END

Now let me explore each major directory to understand the architecture.

>>>TOOL list_dir
{"path": "Views"}
>>>END

>>>TOOL list_dir
{"path": "Models"}
>>>END

>>>TOOL list_dir
{"path": "Services"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/
📁 Editor/
📁 Panels/
(cached)

---

[list_dir]
📁 Models/
   (empty directory)
(cached)

---

[list_dir]
📁 Services/
📁 OnDevice/
(cached)

---

[list_dir]
📁 VSCodeiPadOS/
📁 .garbage/
📁 Docs/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOS.xcodeproj/
📁 VSCodeiPadOSTests/
   bugs.md
   build_output.log
   build_output2.log
   build.log
   FeatureFlags.swift
   Info.plist
   Package.swift
   TreeSitterLanguages.swift
   TypingLagTest.swift
(cached)


>>>TOOL list_dir
{"path": "Views/Editor"}
>>>END

>>>TOOL list_dir
{"path": "Views/Panels"}
>>>END

>>>TOOL list_dir
{"path": "Services/OnDevice"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/Editor/
   (empty directory)
(cached)

---

[list_dir]
📁 Views/Panels/
   RunnerWarningView.swift
   TerminalView.swift_patch1
   TerminalView.swift_patch2
(cached)

---

[list_dir]
📁 Services/OnDevice/
   (empty directory)
(cached)

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/
📁 App/
📁 Assets.xcassets/
📁 Commands/
📁 Docs/
📁 Extensions/
📁 Menus.bak/
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


Let me explore the main source directories in depth.

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/App"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Utils"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Commands"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/App/
   AppDelegate.swift
   SceneDelegate.swift
   VSCodeiPadOSApp.swift

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Models/
   EditorState.swift
   FileItem.swift
   FileItemUTType.swift
   FindViewModel.swift
   MultiCursor.swift
   Tab.swift
   Theme.swift
   ThemeManager.swift
(cached)

---

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
   RunestoneThemeAdapter 2.swift
   RunestoneThemeAdapter.swift
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
   TreeSitterLanguages.swift
   WindowStateManager.swift
   WorkspaceManager.swift
   WorkspaceTrustManager.swift
(cached)

---

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
(cached)

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Utils/
   Codicon.swift
   FeatureFlags.swift
   FileDragModifier.swift

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Commands/
   AppCommands.swift
   AppCommands.swift.bak
(cached)


Let me explore the Views subdirectories and read key files to understand the architecture:

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/Runners"}
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
   RunestoneEditorView.swift
   SplitEditorView.swift
   StickyHeaderView.swift
   SyntaxHighlightingTextView_Update.swift
   SyntaxHighlightingTextView.swift
(cached)

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/Panels/
   AIAssistantView.swift
   AIAssistantView.swift.backup
   AIAssistantView.swift.bak
   DebugConsoleView.swift
   DebugView.swift
   GitQuickActionsView.swift
   GitView.swift
   GitView.swift.broken
   GoToLineView.swift
   MarkdownPreviewView.swift
   MarkdownPreviewWrapper.swift
   OutlineView.swift
   OutputView.swift
   PanelView.swift
   ProblemsView.swift
   RunnerWarningView.swift
   SearchView.swift
   SearchView.swift.broken
   SettingsView.swift
   TerminalView.swift
   TerminalView.swift.bak
   TestView.swift
   TimelineView.swift
(cached)

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/
   CodeAnalyzer.swift
   IntegrationTests.swift
   JSRunner.swift
   JSRunnerTests.swift
   MockRunners.swift
   PythonRunner.swift
   WASMRunner.swift
   WASMRunnerTests.swift

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/
   NativeGitReader.swift
   NativeGitWriter.swift
   SSHGitClient.swift

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/Runners/
   NodeRunner.swift
   PythonRunner.swift
   SwiftRunner.swift


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/App"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Utils"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Commands"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Extensions"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/App/
   AppDelegate.swift
   SceneDelegate.swift
   VSCodeiPadOSApp.swift
(cached)

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Models/
   EditorState.swift
   FileItem.swift
   FileItemUTType.swift
   FindViewModel.swift
   MultiCursor.swift
   Tab.swift
   Theme.swift
   ThemeManager.swift
(cached)

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Utils/
   Codicon.swift
   FeatureFlags.swift
   FileDragModifier.swift
(cached)

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Commands/
   AppCommands.swift
   AppCommands.swift.bak
(cached)

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Extensions/
   Array+Safe.swift
   Color+Hex.swift
   FileHelpers.swift
   FileIcons.swift
   FileManager+Extension.swift
   FileManager+Extensions.swift
   Notification+Search.swift
   NSAttributedStringSyntaxHighlighter.swift
(cached)


Now let me read the key files to understand the architecture deeply:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/App/VSCodeiPadOSApp.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models/EditorState.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/WorkspaceManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/App/VSCodeiPadOSApp.swift (lines 1-277 of 277)
────────────────────────────────────────
1: import SwiftUI
2: 
3: @main
4: struct VSCodeiPadOSApp: App {
5:     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
6:     @StateObject private var editorCore = EditorCore()
7:     @State private var showSettings = false
8:     @State private var showTerminal = false
9:     @State private var windowTitle: String = "VS Code"
10:     
11:     var body: some Scene {
12:         WindowGroup {
13:             ContentView()
14:                 .environmentObject(editorCore)
15:                 .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WindowTitleDidChange"))) { notification in
16:                     if let userInfo = notification.userInfo,
17:                        let title = userInfo["title"] as? String {
18:                         windowTitle = title
19:                         updateWindowTitle(title)
20:                     }
21:                 }
22:         }
23:         .commands {
24:             // Hide conflicting system menus by replacing with empty content
25:             CommandGroup(replacing: .textEditing) { }
26:             CommandGroup(replacing: .help) { }
27:             
28:             // VS Code-style menu bar (our custom menus)
29:             FileMenuCommands()
30:             EditMenuCommands()
31:             SelectionMenuCommands()
32:             ViewMenuCommands()
33:             GoMenuCommands()
34:             RunMenuCommands()
35:             TerminalMenuCommands()
36:             HelpMenuCommands()
37:         }
38:     }
39:     
40:     private func updateWindowTitle(_ title: String) {
41:         // Update the window title for the scene
42:         if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
43:             windowScene.title = title
44:         }
45:     }
46: }
47: 
48: // MARK: - File Menu Commands
49: 
50: struct FileMenuCommands: Commands {
51:     var body: some Commands {
52:         CommandMenu("File") {
53:             Button("New File") {
54:                 NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
55:             }
56:             .keyboardShortcut("n", modifiers: .command)
57:             
58:             Button("New Window") {
59:                 // Request new window via UIKit
60:             }
61:             .keyboardShortcut("n", modifiers: [.command, .option])
62:             
63:             Divider()
64:             
65:             Button("Open...") {
66:                 NotificationCenter.default.post(name: NSNotification.Name("OpenFile"), object: nil)
67:             }
68:             // Note: Cmd+O removed - conflicts with UITextView
69:             
70:             Divider()
71:             
72:             Button("Save") {
73:                 NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
74:             }
75:             .keyboardShortcut("s", modifiers: .command)
76:             
77:             Button("Save All") {
78:                 NotificationCenter.default.post(name: NSNotification.Name("SaveAllFiles"), object: nil)
79:             }
80:             .keyboardShortcut("s", modifiers: [.command, .option])
81:             
82:             Divider()
83:             
84:             Button("Close Tab") {
85:                 NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
86:             }
87:             .keyboardShortcut("w", modifiers: .command)
88:         }
89:     }
90: }
91: 
92: // MARK: - Edit Menu Commands
93: 
94: struct EditMenuCommands: Commands {
95:     var body: some Commands {
96:         CommandMenu("Edit") {
97:             // Note: Undo/Redo/Cut/Copy/Paste/SelectAll removed
98:             // They conflict with UITextView's built-in handlers
99:             
100:             Button("Find") {
101:                 NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
102:             }
103:             .keyboardShortcut("f", modifiers: .command)
104:             
105:             Button("Replace") {
106:                 NotificationCenter.default.post(name: NSNotification.Name("ShowReplace"), object: nil)
107:             }
108:             .keyboardShortcut("h", modifiers: [.command, .option])
109:         }
110:     }
111: }
112: 
113: // MARK: - Selection Menu Commands
114: 
115: struct SelectionMenuCommands: Commands {
116:     var body: some Commands {
117:         CommandMenu("Selection") {
118:             // Note: Select All removed - conflicts with UITextView Cmd+A
119:             
120:             Button("Add Cursor Above") {
121:                 NotificationCenter.default.post(name: NSNotification.Name("AddCursorAbove"), object: nil)
122:             }
123:             .keyboardShortcut(.upArrow, modifiers: [.command, .option])
124:             
125:             Button("Add Cursor Below") {
126:                 NotificationCenter.default.post(name: NSNotification.Name("AddCursorBelow"), object: nil)
127:             }
128:             .keyboardShortcut(.downArrow, modifiers: [.command, .option])
129:         }
130:     }
131: }
132: 
133: // MARK: - View Menu Commands
134: 
135: struct ViewMenuCommands: Commands {
136:     var body: some Commands {
137:         CommandMenu("View") {
138:             Button("Command Palette") {
139:                 NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
140:             }
141:             .keyboardShortcut("p", modifiers: [.command, .shift])
142:             
143:             Divider()
144:             
145:             Button("Toggle Sidebar") {
146:                 NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
147:             }
148:             .keyboardShortcut("b", modifiers: .command)
149:             
150:             Button("Toggle Terminal") {
151:                 NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
152:             }
153:             .keyboardShortcut("`", modifiers: .command)
154:             
155:             Divider()
156:             
157:             Button("Zoom In") {
158:                 NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
159:             }
160:             .keyboardShortcut("=", modifiers: .command)  // Use = instead of + (standard)
161:             
162:             Button("Zoom Out") {
163:                 NotificationCenter.default.post(name: NSNotification.Name("ZoomOut"), object: nil)
164:             }
165:             .keyboardShortcut("-", modifiers: .command)
166:         }
167:     }
168: }
169: 
170: // MARK: - Go Menu Commands
171: 
172: struct GoMenuCommands: Commands {
173:     var body: some Commands {
174:         CommandMenu("Go") {
175:             Button("Go to File...") {
176:                 NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
177:             }
178:             .keyboardShortcut("p", modifiers: .command)
179:             
180:             Button("Go to Symbol...") {
181:                 NotificationCenter.default.post(name: NSNotification.Name("ShowGoToSymbol"), object: nil)
182:             }
183:             .keyboardShortcut("o", modifiers: [.command, .shift])
184:             
185:             Button("Go to Line...") {
186:                 NotificationCenter.default.post(name: NSNotification.Name("ShowGoToLine"), object: nil)
187:             }
188:             .keyboardShortcut("g", modifiers: .control)
189:             
190:             Divider()
191:             
192:             Button("Go to Definition") {
193:                 NotificationCenter.default.post(name: NSNotification.Name("GoToDefinition"), object: nil)
194:             }
195:             .keyboardShortcut(.return, modifiers: .command)
196:             
197:             Button("Go Back") {
198:                 NotificationCenter.default.post(name: NSNotification.Name("GoBack"), object: nil)
199:             }
200:             .keyboardShortcut("[", modifiers: .control)
201:             
202:             Button("Go Forward") {
203:                 NotificationCenter.default.post(name: NSNotification.Name("GoForward"), object: nil)
204:             }
205:             .keyboardShortcut("]", modifiers: .control)
206:         }
207:     }
208: }
209: 
210: // MARK: - Run Menu Commands
211: 
212: struct RunMenuCommands: Commands {
213:     var body: some Commands {
214:         CommandMenu("Run") {
215:             Button("Start Debugging") {
216:                 NotificationCenter.default.post(name: NSNotification.Name("StartDebugging"), object: nil)
217:             }
218:             .keyboardShortcut("d", modifiers: [.command, .shift])
219:             
220:             Button("Run Without Debugging") {
221:                 NotificationCenter.default.post(name: NSNotification.Name("RunWithoutDebugging"), object: nil)
222:             }
223:             .keyboardShortcut("r", modifiers: [.command, .shift])
224:             
225:             Divider()
226:             
227:             Button("Toggle Breakpoint") {
228:                 NotificationCenter.default.post(name: NSNotification.Name("ToggleBreakpoint"), object: nil)
229:             }
230:             .keyboardShortcut("b", modifiers: [.command, .shift])
231:         }
232:     }
233: }
234: 
235: // MARK: - Terminal Menu Commands
236: 
237: struct TerminalMenuCommands: Commands {
238:     var body: some Commands {
239:         CommandMenu("Terminal") {
240:             Button("New Terminal") {
241:                 NotificationCenter.default.post(name: NSNotification.Name("NewTerminal"), object: nil)
242:             }
243:             .keyboardShortcut("`", modifiers: [.control, .shift])
244:             
245:             Button("Clear Terminal") {
246:                 NotificationCenter.default.post(name: NSNotification.Name("ClearTerminal"), object: nil)
247:             }
248:             .keyboardShortcut("k", modifiers: .command)
249:         }
250:     }
251: }
252: 
253: // MARK: - Help Menu Commands
254: 
255: struct HelpMenuCommands: Commands {
256:     var body: some Commands {
257:         CommandMenu("Help") {
258:             Button("Documentation") {
259:                 if let url = URL(string: "https://code.visualstudio.com/docs") {
260:                     UIApplication.shared.open(url)
261:                 }
262:             }
263:             
264:             Button("Keyboard Shortcuts") {
265:                 NotificationCenter.default.post(name: NSNotification.Name("ShowKeyboardShortcuts"), object: nil)
266:             }
267:             .keyboardShortcut("k", modifiers: [.command, .shift])
268:             
269:             Divider()
270:             
271:             Button("About VS Code for iPad") {
272:                 NotificationCenter.default.post(name: NSNotification.Name("ShowAbout"), object: nil)
273:             }
274:         }
275:     }
276: }
277: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/EditorState.swift (lines 1-298 of 298)
────────────────────────────────────────
1: //
2: //  EditorState.swift
3: //  VSCodeiPadOS
4: //
5: //  Created by AI Assistant
6: //  State management for editor view configuration and cursor position
7: //
8: 
9: import Foundation
10: import SwiftUI
11: 
12: /// Manages the state of an individual editor instance
13: struct EditorState: Equatable {
14:     // MARK: - Cursor & Selection
15:     
16:     /// Current cursor position in the editor
17:     var cursorPosition: CursorPosition
18:     
19:     /// Current text selection (nil if no selection)
20:     var selection: TextSelection?
21:     
22:     /// Line numbers that are currently folded/collapsed
23:     var foldedRegions: Set<Int>
24:     
25:     // MARK: - Display Settings
26:     
27:     /// Font size for editor text
28:     var fontSize: CGFloat
29:     
30:     /// Whether to show line numbers in the gutter
31:     var showLineNumbers: Bool
32:     
33:     /// Whether to show the minimap overview
34:     var showMinimap: Bool
35:     
36:     /// Whether to wrap long lines
37:     var wordWrap: Bool
38:     
39:     /// Whether to show whitespace characters
40:     var showWhitespace: Bool
41:     
42:     /// Number of spaces per tab
43:     var tabSize: Int
44:     
45:     /// Whether to use spaces instead of tabs
46:     var insertSpaces: Bool
47:     
48:     // MARK: - Scroll State
49:     
50:     /// Vertical scroll position (line number)
51:     var scrollLine: Int
52:     
53:     /// Horizontal scroll position (column)
54:     var scrollColumn: Int
55:     
56:     // MARK: - Initialization
57:     
58:     /// Creates a new editor state with default values
59:     init(
60:         cursorPosition: CursorPosition = CursorPosition(),
61:         selection: TextSelection? = nil,
62:         foldedRegions: Set<Int> = [],
63:         fontSize: CGFloat = 14,
64:         showLineNumbers: Bool = true,
65:         showMinimap: Bool = false,
66:         wordWrap: Bool = false,
67:         showWhitespace: Bool = false,
68:         tabSize: Int = 4,
69:         insertSpaces: Bool = true,
70:         scrollLine: Int = 0,
71:         scrollColumn: Int = 0
72:     ) {
73:         self.cursorPosition = cursorPosition
74:         self.selection = selection
75:         self.foldedRegions = foldedRegions
76:         self.fontSize = fontSize
77:         self.showLineNumbers = showLineNumbers
78:         self.showMinimap = showMinimap
79:         self.wordWrap = wordWrap
80:         self.showWhitespace = showWhitespace
81:         self.tabSize = tabSize
82:         self.insertSpaces = insertSpaces
83:         self.scrollLine = scrollLine
84:         self.scrollColumn = scrollColumn
85:     }
86:     
87:     // MARK: - Helper Methods
88:     
89:     /// Checks if a line is currently folded
90:     /// - Parameter line: Line number (0-indexed)
91:     /// - Returns: True if the line is folded
92:     func isLineFolded(_ line: Int) -> Bool {
93:         foldedRegions.contains(line)
94:     }
95:     
96:     /// Toggles folding for a line
97:     /// - Parameter line: Line number (0-indexed)
98:     mutating func toggleFolding(at line: Int) {
99:         if foldedRegions.contains(line) {
100:             foldedRegions.remove(line)
101:         } else {
102:             foldedRegions.insert(line)
103:         }
104:     }
105:     
106:     /// Clears all text selection
107:     mutating func clearSelection() {
108:         selection = nil
109:     }
110:     
111:     /// Sets a text selection
112:     /// - Parameters:
113:     ///   - start: Starting cursor position
114:     ///   - end: Ending cursor position
115:     mutating func setSelection(from start: CursorPosition, to end: CursorPosition) {
116:         selection = TextSelection(start: start, end: end)
117:     }
118: }
119: 
120: // MARK: - CursorPosition
121: 
122: /// Represents a position in the text editor
123: struct CursorPosition: Equatable, Codable {
124:     /// Line number (0-indexed)
125:     var line: Int
126:     
127:     /// Column number (0-indexed)
128:     var column: Int
129:     
130:     /// Creates a cursor position at the beginning of the document
131:     init(line: Int = 0, column: Int = 0) {
132:         self.line = line
133:         self.column = column
134:     }
135:     
136:     /// Human-readable description (1-indexed for display)
137:     var displayDescription: String {
138:         "Ln \(line + 1), Col \(column + 1)"
139:     }
140:     
141:     /// Alias for displayDescription for convenience
142:     var description: String {
143:         displayDescription
144:     }
145:     
146:     /// Short display format
147:     var shortDisplay: String {
148:         "\(line + 1):\(column + 1)"
149:     }
150:     
151:     /// Moves cursor to the next line
152:     mutating func moveToNextLine() {
153:         line += 1
154:         column = 0
155:     }
156:     
157:     /// Moves cursor to the previous line
158:     mutating func moveToPreviousLine() {
159:         if line > 0 {
160:             line -= 1
161:             column = 0
162:         }
163:     }
164:     
165:     /// Compares two positions
166:     /// - Parameter other: Position to compare with
167:     /// - Returns: True if this position comes before the other
168:     func isBefore(_ other: CursorPosition) -> Bool {
169:         if line < other.line { return true }
170:         if line > other.line { return false }
171:         return column < other.column
172:     }
173:     
174:     /// Compares two positions
175:     /// - Parameter other: Position to compare with
176:     /// - Returns: True if this position comes after the other
177:     func isAfter(_ other: CursorPosition) -> Bool {
178:         if line > other.line { return true }
179:         if line < other.line { return false }
180:         return column > other.column
181:     }
182: }
183: 
184: // MARK: - TextSelection
185: 
186: /// Represents a range of selected text in the editor
187: struct TextSelection: Equatable, Codable {
188:     /// Starting position of the selection
189:     let start: CursorPosition
190:     
191:     /// Ending position of the selection
192:     let end: CursorPosition
193:     
194:     /// Creates a text selection
195:     /// - Parameters:
196:     ///   - start: Starting cursor position
197:     ///   - end: Ending cursor position
198:     init(start: CursorPosition, end: CursorPosition) {
199:         // Ensure start is always before end
200:         if start.isBefore(end) {
201:             self.start = start
202:             self.end = end
203:         } else {
204:             self.start = end
205:             self.end = start
206:         }
207:     }
208:     
209:     /// Whether the selection is empty (start == end)
210:     var isEmpty: Bool {
211:         start.line == end.line && start.column == end.column
212:     }
213:     
214:     /// Whether the selection spans multiple lines
215:     var isMultiLine: Bool {
216:         start.line != end.line
217:     }
218:     
219:     /// Number of lines in the selection
220:     var lineCount: Int {
221:         end.line - start.line + 1
222:     }
223:     
224:     /// Human-readable description of the selection
225:     var displayDescription: String {
226:         if isEmpty {
227:             return "No selection"
228:         }
229:         let chars = isMultiLine ? "\(lineCount) lines" : "\(end.column - start.column) chars"
230:         return "\(chars) selected"
231:     }
232:     
233:     /// Checks if a position is within this selection
234:     /// - Parameter position: Position to check
235:     /// - Returns: True if the position is within the selection
236:     func contains(_ position: CursorPosition) -> Bool {
237:         if position.line < start.line || position.line > end.line {
238:             return false
239:         }
240:         if position.line == start.line && position.column < start.column {
241:             return false
242:         }
243:         if position.line == end.line && position.column > end.column {
244:             return false
245:         }
246:         return true
247:     }
248: }
249: 
250: // MARK: - Split View Configuration
251: 
252: /// Defines how the editor is split (for multi-pane editing)
253: enum SplitViewConfiguration: Equatable, Codable {
254:     /// Single editor pane
255:     case single
256:     
257:     /// Two panes side by side with specified ratio
258:     case vertical(ratio: CGFloat)
259:     
260:     /// Two panes stacked with specified ratio
261:     case horizontal(ratio: CGFloat)
262:     
263:     /// Four panes in a grid
264:     case grid
265:     
266:     /// Default vertical split (50/50)
267:     static var verticalDefault: SplitViewConfiguration {
268:         .vertical(ratio: 0.5)
269:     }
270:     
271:     /// Default horizontal split (50/50)
272:     static var horizontalDefault: SplitViewConfiguration {
273:         .horizontal(ratio: 0.5)
274:     }
275:     
276:     /// Whether this configuration shows multiple panes
277:     var isMultiPane: Bool {
278:         switch self {
279:         case .single:
280:             return false
281:         case .vertical, .horizontal, .grid:
282:             return true
283:         }
284:     }
285:     
286:     /// Number of visible panes
287:     var paneCount: Int {
288:         switch self {
289:         case .single:
290:             return 1
291:         case .vertical, .horizontal:
292:             return 2
293:         case .grid:
294:             return 4
295:         }
296:     }
297: }
298: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/WorkspaceManager.swift (lines 1-238 of 238)
────────────────────────────────────────
1: import Foundation
2: 
3: // MARK: - Workspace Settings
4: 
5: /// Workspace (per-project) settings that override global settings.
6: ///
7: /// These correspond loosely to VS Code's `.vscode/settings.json` keys:
8: /// - editor.tabSize
9: /// - editor.insertSpaces
10: /// - editor.formatOnSave
11: /// - workbench.colorTheme
12: /// - editor.fontFamily
13: /// - editor.fontSize
14: struct WorkspaceSettings: Codable, Equatable {
15:     /// Number of spaces that a tab represents.
16:     var tabSize: Int?
17: 
18:     /// Insert spaces when pressing tab.
19:     var insertSpaces: Bool?
20: 
21:     /// Format the document on save.
22:     var formatOnSave: Bool?
23: 
24:     /// Theme identifier (app-specific). Stored under `workbench.colorTheme`.
25:     var theme: String?
26: 
27:     /// Editor font family name.
28:     var fontFamily: String?
29: 
30:     /// Editor font size.
31:     var fontSize: Double?
32: 
33:     static let empty = WorkspaceSettings()
34: }
35: 
36: /// Concrete, fully-resolved settings after merging global + workspace overrides.
37: struct ResolvedWorkspaceSettings: Equatable {
38:     var tabSize: Int
39:     var insertSpaces: Bool
40:     var formatOnSave: Bool
41:     var theme: String
42:     var fontFamily: String
43:     var fontSize: Double
44: }
45: 
46: // MARK: - Workspace Manager
47: 
48: @MainActor
49: final class WorkspaceManager: ObservableObject {
50:     static let shared = WorkspaceManager()
51: 
52:     @Published private(set) var workspaceRootURL: URL?
53:     @Published private(set) var workspaceSettings: WorkspaceSettings = .empty
54: 
55:     @Published var lastErrorMessage: String?
56: 
57:     private init() {}
58: 
59:     // MARK: - Workspace
60: 
61:     func setWorkspaceRoot(_ url: URL?) {
62:         workspaceRootURL = url
63:         reload()
64:     }
65: 
66:     // MARK: - Global settings
67: 
68:     /// Reads global (app) settings from `UserDefaults`.
69:     func globalSettings() -> ResolvedWorkspaceSettings {
70:         let defaults = UserDefaults.standard
71: 
72:         let tabSize = defaults.object(forKey: "tabSize") as? Int ?? 4
73: 
74:         // Defaults to true when unset.
75:         let insertSpaces: Bool
76:         if defaults.object(forKey: "insertSpaces") == nil {
77:             insertSpaces = true
78:         } else {
79:             insertSpaces = defaults.bool(forKey: "insertSpaces")
80:         }
81: 
82:         let formatOnSave: Bool
83:         if defaults.object(forKey: "formatOnSave") == nil {
84:             formatOnSave = false
85:         } else {
86:             formatOnSave = defaults.bool(forKey: "formatOnSave")
87:         }
88: 
89:         let theme = defaults.string(forKey: "selectedThemeId") ?? "dark_plus"
90:         let fontFamily = defaults.string(forKey: "fontFamily") ?? "Menlo"
91:         let fontSize = defaults.object(forKey: "fontSize") as? Double ?? 14
92: 
93:         return ResolvedWorkspaceSettings(
94:             tabSize: tabSize,
95:             insertSpaces: insertSpaces,
96:             formatOnSave: formatOnSave,
97:             theme: theme,
98:             fontFamily: fontFamily,
99:             fontSize: fontSize
100:         )
101:     }
102: 
103:     /// Workspace overrides global.
104:     func effectiveSettings() -> ResolvedWorkspaceSettings {
105:         let global = globalSettings()
106:         let ws = workspaceSettings
107: 
108:         return ResolvedWorkspaceSettings(
109:             tabSize: ws.tabSize ?? global.tabSize,
110:             insertSpaces: ws.insertSpaces ?? global.insertSpaces,
111:             formatOnSave: ws.formatOnSave ?? global.formatOnSave,
112:             theme: ws.theme ?? global.theme,
113:             fontFamily: ws.fontFamily ?? global.fontFamily,
114:             fontSize: ws.fontSize ?? global.fontSize
115:         )
116:     }
117: 
118:     // MARK: - Load
119: 
120:     func reload() {
121:         lastErrorMessage = nil
122:         workspaceSettings = .empty
123: 
124:         guard let root = workspaceRootURL else { return }
125: 
126:         let settingsURL = root
127:             .appendingPathComponent(".vscode", isDirectory: true)
128:             .appendingPathComponent("settings.json", isDirectory: false)
129: 
130:         do {
131:             let data = try Data(contentsOf: settingsURL)
132:             let raw = String(decoding: data, as: UTF8.self)
133:             let stripped = Self.stripJSONComments(raw)
134:             let obj = try JSONSerialization.jsonObject(with: Data(stripped.utf8), options: [])
135: 
136:             guard let dict = obj as? [String: Any] else {
137:                 lastErrorMessage = "Couldn’t parse .vscode/settings.json"
138:                 return
139:             }
140: 
141:             workspaceSettings = Self.parseWorkspaceSettings(from: dict)
142:         } catch {
143:             // Not an error if settings.json doesn't exist.
144:             // Only show an error if the file exists but couldn't be read.
145:             if FileManager.default.fileExists(atPath: settingsURL.path) {
146:                 lastErrorMessage = "Couldn’t load .vscode/settings.json"
147:             }
148:         }
149:     }
150: 
151:     // MARK: - Save
152: 
153:     func saveWorkspaceSettings(_ newSettings: WorkspaceSettings) {
154:         workspaceSettings = newSettings
155:         save()
156:     }
157: 
158:     func save() {
159:         lastErrorMessage = nil
160:         guard let root = workspaceRootURL else {
161:             lastErrorMessage = "No workspace folder is open"
162:             return
163:         }
164: 
165:         let vscodeDir = root.appendingPathComponent(".vscode", isDirectory: true)
166:         let settingsURL = vscodeDir.appendingPathComponent("settings.json", isDirectory: false)
167: 
168:         do {
169:             try FileManager.default.createDirectory(at: vscodeDir, withIntermediateDirectories: true)
170: 
171:             let dict = Self.serializeWorkspaceSettings(workspaceSettings)
172:             let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
173: 
174:             // Add trailing newline for nicer diffs.
175:             var out = String(decoding: data, as: UTF8.self)
176:             if !out.hasSuffix("\n") { out += "\n" }
177: 
178:             try out.data(using: .utf8)?.write(to: settingsURL, options: [.atomic])
179:         } catch {
180:             lastErrorMessage = "Couldn’t save .vscode/settings.json"
181:         }
182:     }
183: 
184:     // MARK: - JSON mapping
185: 
186:     private static func parseWorkspaceSettings(from dict: [String: Any]) -> WorkspaceSettings {
187:         func int(_ key: String) -> Int? {
188:             dict[key] as? Int
189:         }
190:         func bool(_ key: String) -> Bool? {
191:             dict[key] as? Bool
192:         }
193:         func string(_ key: String) -> String? {
194:             dict[key] as? String
195:         }
196:         func double(_ key: String) -> Double? {
197:             if let d = dict[key] as? Double { return d }
198:             if let i = dict[key] as? Int { return Double(i) }
199:             return nil
200:         }
201: 
202:         return WorkspaceSettings(
203:             tabSize: int("editor.tabSize"),
204:             insertSpaces: bool("editor.insertSpaces"),
205:             formatOnSave: bool("editor.formatOnSave"),
206:             theme: string("workbench.colorTheme"),
207:             fontFamily: string("editor.fontFamily"),
208:             fontSize: double("editor.fontSize")
209:         )
210:     }
211: 
212:     private static func serializeWorkspaceSettings(_ settings: WorkspaceSettings) -> [String: Any] {
213:         var dict: [String: Any] = [:]
214: 
215:         if let tabSize = settings.tabSize { dict["editor.tabSize"] = tabSize }
216:         if let insertSpaces = settings.insertSpaces { dict["editor.insertSpaces"] = insertSpaces }
217:         if let formatOnSave = settings.formatOnSave { dict["editor.formatOnSave"] = formatOnSave }
218:         if let theme = settings.theme, !theme.isEmpty { dict["workbench.colorTheme"] = theme }
219:         if let fontFamily = settings.fontFamily, !fontFamily.isEmpty { dict["editor.fontFamily"] = fontFamily }
220:         if let fontSize = settings.fontSize { dict["editor.fontSize"] = fontSize }
221: 
222:         return dict
223:     }
224: 
225:     // MARK: - JSONC helpers
226: 
227:     /// VS Code `settings.json` can contain JSON with comments (JSONC). This strips
228:     /// both `//` line comments and `/* ... */` block comments.
229:     private static func stripJSONComments(_ input: String) -> String {
230:         let blockPattern = "/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/"
231:         let linePattern = "(?m)//.*$"
232: 
233:         let withoutBlocks = input.replacingOccurrences(of: blockPattern, with: "", options: .regularExpression)
234:         let withoutLines = withoutBlocks.replacingOccurrences(of: linePattern, with: "", options: .regularExpression)
235:         return withoutLines
236:     }
237: }
238: 


Let me read more core files to understand the architecture:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/SettingsManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models/FileItem.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 1-1345 of 1345)
────────────────────────────────────────
1: import UniformTypeIdentifiers
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
141:         // Create example tabs for all supported languages
142:         let exampleTabs = Self.createExampleTabs()
143:         tabs.append(contentsOf: exampleTabs)
144:         activeTabId = exampleTabs.first?.id ?? UUID()
145:     }
146:     
147:     /// Creates example tabs demonstrating syntax highlighting for all supported languages
148:     private static func createExampleTabs() -> [Tab] {
149:         var examples: [Tab] = []
150:         
151:         // Swift example
152:         examples.append(Tab(
153:             fileName: "Welcome.swift",
154:             content: """
155: // Welcome to VS Code for iPadOS! 🎉
156: //
157: // Features:
158: // • Syntax highlighting for Swift, JS, Python, and more
159: // • Multiple tabs with drag reordering
160: // • File explorer sidebar
161: // • Command palette (⌘+Shift+P)
162: // • Quick open (⌘+P)
163: // • Find & Replace (⌘+F)
164: // • AI Assistant
165: // • Minimap navigation
166: // • Code folding
167: // • Go to line (⌘+G)
168: //
169: // Start editing or open a file!
170: 
171: import SwiftUI
172: 
173: struct ContentView: View {
174:     @State private var counter = 0
175:     
176:     var body: some View {
177:         VStack(spacing: 20) {
178:             Text("Hello, World!")
179:                 .font(.largeTitle)
180:                 .foregroundColor(.blue)
181:             
182:             Button("Count: \\(counter)") {
183:                 counter += 1
184:             }
185:             .buttonStyle(.borderedProminent)
186:         }
187:         .padding()
188:     }
189: }
190: 
191: // MARK: - Preview
192: #Preview {
193:     ContentView()
194: }
195: """,
196:             language: "swift"
197:         ))
198:         
199:         // JavaScript example
200:         examples.append(Tab(
201:             fileName: "example.js",
202:             content: """
203: // JavaScript Example - ES6+ Features
204: 
205: import React, { useState, useEffect } from 'react';
206: 
207: const API_URL = 'https://api.example.com';
208: 
209: // Async function with error handling
210: async function fetchData(endpoint) {
211:     try {
212:         const response = await fetch(`${API_URL}/${endpoint}`);
213:         if (!response.ok) {
214:             throw new Error(`HTTP error! status: ${response.status}`);
215:         }
216:         return await response.json();
217:     } catch (error) {
218:         console.error('Fetch failed:', error);
219:         return null;
220:     }
221: }
222: 
223: // React Component
224: function UserProfile({ userId }) {
225:     const [user, setUser] = useState(null);
226:     const [loading, setLoading] = useState(true);
227:     
228:     useEffect(() => {
229:         fetchData(`users/${userId}`)
230:             .then(data => {
231:                 setUser(data);
232:                 setLoading(false);
233:             });
234:     }, [userId]);
235:     
236:     if (loading) return <div>Loading...</div>;
237:     
238:     return (
239:         <div className="profile">
240:             <h1>{user?.name ?? 'Unknown'}</h1>
241:             <p>Email: {user?.email}</p>
242:         </div>
243:     );
244: }
245: 
246: // Array methods & destructuring
247: const numbers = [1, 2, 3, 4, 5];
248: const doubled = numbers.map(n => n * 2);
249: const [first, second, ...rest] = doubled;
250: 
251: export { fetchData, UserProfile };
252: """,
253:             language: "javascript"
254:         ))
255:         
256:         // Python example
257:         examples.append(Tab(
258:             fileName: "example.py",
259:             content: """
260: #!/usr/bin/env python3
261: \"\"\"
262: Python Example - Modern Python Features
263: Demonstrates type hints, dataclasses, async, and more.
264: \"\"\"
265: 
266: import asyncio
267: from dataclasses import dataclass, field
268: from typing import Optional, List
269: from enum import Enum
270: 
271: class Status(Enum):
272:     PENDING = "pending"
273:     ACTIVE = "active"
274:     COMPLETED = "completed"
275: 
276: @dataclass
277: class Task:
278:     \"\"\"Represents a task with metadata.\"\"\"
279:     id: int
280:     title: str
281:     status: Status = Status.PENDING
282:     tags: List[str] = field(default_factory=list)
283:     description: Optional[str] = None
284:     
285:     def mark_complete(self) -> None:
286:         self.status = Status.COMPLETED
287:         print(f"Task '{self.title}' completed!")
288: 
289: class TaskManager:
290:     def __init__(self):
291:         self._tasks: dict[int, Task] = {}
292:         self._next_id = 1
293:     
294:     def add_task(self, title: str, **kwargs) -> Task:
295:         task = Task(id=self._next_id, title=title, **kwargs)
296:         self._tasks[task.id] = task
297:         self._next_id += 1
298:         return task
299:     
300:     async def process_tasks(self) -> None:
301:         for task in self._tasks.values():
302:             await asyncio.sleep(0.1)  # Simulate work
303:             task.mark_complete()
304: 
305: # Main execution
306: async def main():
307:     manager = TaskManager()
308:     manager.add_task("Learn Python", tags=["programming", "learning"])
309:     manager.add_task("Build app", description="Create VSCode for iPad")
310:     
311:     await manager.process_tasks()
312: 
313: if __name__ == "__main__":
314:     asyncio.run(main())
315: """,
316:             language: "python"
317:         ))
318:         
319:         // JSON example
320:         examples.append(Tab(
321:             fileName: "package.json",
322:             content: """
323: {
324:   "name": "vscode-ipados-example",
325:   "version": "1.0.0",
326:   "description": "Example package.json for VS Code iPadOS",
327:   "main": "index.js",
328:   "scripts": {
329:     "start": "node index.js",
330:     "build": "webpack --mode production",
331:     "test": "jest --coverage",
332:     "lint": "eslint src/**/*.js"
333:   },
334:   "dependencies": {
335:     "react": "^18.2.0",
336:     "react-dom": "^18.2.0",
337:     "axios": "^1.4.0"
338:   },
339:   "devDependencies": {
340:     "webpack": "^5.88.0",
341:     "jest": "^29.5.0",
342:     "eslint": "^8.44.0",
343:     "typescript": "^5.1.6"
344:   },
345:   "keywords": ["vscode", "ipad", "editor"],
346:   "author": "VS Code iPadOS Team",
347:   "license": "MIT",
348:   "repository": {
349:     "type": "git",
350:     "url": "https://github.com/example/vscode-ipados"
351:   },
352:   "engines": {
353:     "node": ">=18.0.0"
354:   }
355: }
356: """,
357:             language: "json"
358:         ))
359:         
360:         // HTML example
361:         examples.append(Tab(
362:             fileName: "index.html",
363:             content: """
364: <!DOCTYPE html>
365: <html lang="en">
366: <head>
367:     <meta charset="UTF-8">
368:     <meta name="viewport" content="width=device-width, initial-scale=1.0">
369:     <title>VS Code for iPadOS</title>
370:     <link rel="stylesheet" href="styles.css">
371:     <script src="app.js" defer></script>
372: </head>
373: <body>
374:     <header class="navbar">
375:         <nav>
376:             <a href="#" class="logo">VS Code iPadOS</a>
377:             <ul class="nav-links">
378:                 <li><a href="#features">Features</a></li>
379:                 <li><a href="#download">Download</a></li>
380:                 <li><a href="#docs">Documentation</a></li>
381:             </ul>
382:         </nav>
383:     </header>
384:     
385:     <main>
386:         <section id="hero" class="hero-section">
387:             <h1>Code Anywhere</h1>
388:             <p>Professional code editor for your iPad</p>
389:             <button id="cta-button" class="btn primary">
390:                 Get Started
391:             </button>
392:         </section>
393:         
394:         <section id="features">
395:             <h2>Features</h2>
396:             <div class="feature-grid">
397:                 <article class="feature-card">
398:                     <h3>Syntax Highlighting</h3>
399:                     <p>Support for 8+ languages with TreeSitter</p>
400:                 </article>
401:                 <!-- More features -->
402:             </div>
403:         </section>
404:     </main>
405:     
406:     <footer>
407:         <p>&copy; 2024 VS Code iPadOS. All rights reserved.</p>
408:     </footer>
409: </body>
410: </html>
411: """,
412:             language: "html"
413:         ))
414:         
415:         // CSS example
416:         examples.append(Tab(
417:             fileName: "styles.css",
418:             content: """
419: /* VS Code iPadOS - Stylesheet */
420: /* Modern CSS with variables, grid, and animations */
421: 
422: :root {
423:     --primary-color: #007acc;
424:     --secondary-color: #3c3c3c;
425:     --background-dark: #1e1e1e;
426:     --text-light: #d4d4d4;
427:     --accent-green: #4ec9b0;
428:     --font-mono: 'SF Mono', Menlo, monospace;
429:     --shadow-lg: 0 10px 40px rgba(0, 0, 0, 0.3);
430: }
431: 
432: * {
433:     margin: 0;
434:     padding: 0;
435:     box-sizing: border-box;
436: }
437: 
438: body {
439:     font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
440:     background-color: var(--background-dark);
441:     color: var(--text-light);
442:     line-height: 1.6;
443: }
444: 
445: .navbar {
446:     position: sticky;
447:     top: 0;
448:     background: rgba(30, 30, 30, 0.95);
449:     backdrop-filter: blur(10px);
450:     padding: 1rem 2rem;
451:     z-index: 1000;
452: }
453: 
454: .hero-section {
455:     min-height: 100vh;
456:     display: grid;
457:     place-items: center;
458:     text-align: center;
459:     background: linear-gradient(135deg, var(--background-dark), #2d2d30);
460: }
461: 
462: .btn.primary {
463:     background: var(--primary-color);
464:     color: white;
465:     padding: 12px 24px;
466:     border: none;
467:     border-radius: 6px;
468:     font-size: 1rem;
469:     cursor: pointer;
470:     transition: transform 0.2s, box-shadow 0.2s;
471: }
472: 
473: .btn.primary:hover {
474:     transform: translateY(-2px);
475:     box-shadow: var(--shadow-lg);
476: }
477: 
478: .feature-grid {
479:     display: grid;
480:     grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
481:     gap: 2rem;
482:     padding: 2rem;
483: }
484: 
485: @keyframes fadeIn {
486:     from { opacity: 0; transform: translateY(20px); }
487:     to { opacity: 1; transform: translateY(0); }
488: }
489: 
490: .feature-card {
491:     animation: fadeIn 0.5s ease-out forwards;
492: }
493: 
494: @media (max-width: 768px) {
495:     .nav-links { display: none; }
496:     .hero-section { padding: 2rem; }
497: }
498: """,
499:             language: "css"
500:         ))
501:         
502:         // Go example
503:         examples.append(Tab(
504:             fileName: "main.go",
505:             content: """
506: // Go Example - HTTP Server with Goroutines
507: package main
508: 
509: import (
510: \t"context"
511: \t"encoding/json"
512: \t"fmt"
513: \t"log"
514: \t"net/http"
515: \t"sync"
516: \t"time"
517: )
518: 
519: // User represents a user in the system
520: type User struct {
521: \tID        int       `json:"id"`
522: \tName      string    `json:"name"`
523: \tEmail     string    `json:"email"`
524: \tCreatedAt time.Time `json:"created_at"`
525: }
526: 
527: // UserStore handles user data with thread-safe access
528: type UserStore struct {
529: \tmu    sync.RWMutex
530: \tusers map[int]*User
531: \tnextID int
532: }
533: 
534: func NewUserStore() *UserStore {
535: \treturn &UserStore{
536: \t\tusers:  make(map[int]*User),
537: \t\tnextID: 1,
538: \t}
539: }
540: 
541: func (s *UserStore) Create(name, email string) *User {
542: \ts.mu.Lock()
543: \tdefer s.mu.Unlock()
544: \t
545: \tuser := &User{
546: \t\tID:        s.nextID,
547: \t\tName:      name,
548: \t\tEmail:     email,
549: \t\tCreatedAt: time.Now(),
550: \t}
551: \ts.users[user.ID] = user
552: \ts.nextID++
553: \treturn user
554: }
555: 
556: func (s *UserStore) Get(id int) (*User, bool) {
557: \ts.mu.RLock()
558: \tdefer s.mu.RUnlock()
559: \tuser, ok := s.users[id]
560: \treturn user, ok
561: }
562: 
563: func handleUsers(store *UserStore) http.HandlerFunc {
564: \treturn func(w http.ResponseWriter, r *http.Request) {
565: \t\tswitch r.Method {
566: \t\tcase http.MethodGet:
567: \t\t\t// Return all users
568: \t\t\tw.Header().Set("Content-Type", "application/json")
569: \t\t\tjson.NewEncoder(w).Encode(store.users)
570: \t\tcase http.MethodPost:
571: \t\t\t// Create new user
572: \t\t\tvar req struct {
573: \t\t\t\tName  string `json:"name"`
574: \t\t\t\tEmail string `json:"email"`
575: \t\t\t}
576: \t\t\tif err := json.NewDecoder(r.Body).Decode(&req); err != nil {
577: \t\t\t\thttp.Error(w, err.Error(), http.StatusBadRequest)
578: \t\t\t\treturn
579: \t\t\t}
580: \t\t\tuser := store.Create(req.Name, req.Email)
581: \t\t\tw.WriteHeader(http.StatusCreated)
582: \t\t\tjson.NewEncoder(w).Encode(user)
583: \t\tdefault:
584: \t\t\thttp.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
585: \t\t}
586: \t}
587: }
588: 
589: func main() {
590: \tstore := NewUserStore()
591: \t
592: \t// Seed some data
593: \tstore.Create("Alice", "alice@example.com")
594: \tstore.Create("Bob", "bob@example.com")
595: \t
596: \tmux := http.NewServeMux()
597: \tmux.HandleFunc("/api/users", handleUsers(store))
598: \t
599: \tserver := &http.Server{
600: \t\tAddr:         ":8080",
601: \t\tHandler:      mux,
602: \t\tReadTimeout:  10 * time.Second,
603: \t\tWriteTimeout: 10 * time.Second,
604: \t}
605: \t
606: \tfmt.Println("Server starting on :8080")
607: \tlog.Fatal(server.ListenAndServe())
608: }
609: """,
610:             language: "go"
611:         ))
612:         
613:         // Rust example
614:         examples.append(Tab(
615:             fileName: "main.rs",
616:             content: """
617: //! Rust Example - Async Web Server
618: //! Demonstrates ownership, traits, async/await, and error handling
619: 
620: use std::collections::HashMap;
621: use std::sync::Arc;
622: use tokio::sync::RwLock;
623: 
624: /// Represents a task in our system
625: #[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
626: pub struct Task {
627:     pub id: u64,
628:     pub title: String,
629:     pub completed: bool,
630:     #[serde(skip_serializing_if = "Option::is_none")]
631:     pub description: Option<String>,
632: }
633: 
634: /// Task store with thread-safe access
635: pub struct TaskStore {
636:     tasks: RwLock<HashMap<u64, Task>>,
637:     next_id: RwLock<u64>,
638: }
639: 
640: impl TaskStore {
641:     pub fn new() -> Self {
642:         Self {
643:             tasks: RwLock::new(HashMap::new()),
644:             next_id: RwLock::new(1),
645:         }
646:     }
647:     
648:     pub async fn create(&self, title: String, description: Option<String>) -> Task {
649:         let mut next_id = self.next_id.write().await;
650:         let id = *next_id;
651:         *next_id += 1;
652:         
653:         let task = Task {
654:             id,
655:             title,
656:             completed: false,
657:             description,
658:         };
659:         
660:         self.tasks.write().await.insert(id, task.clone());
661:         task
662:     }
663:     
664:     pub async fn get(&self, id: u64) -> Option<Task> {
665:         self.tasks.read().await.get(&id).cloned()
666:     }
667:     
668:     pub async fn list(&self) -> Vec<Task> {
669:         self.tasks.read().await.values().cloned().collect()
670:     }
671:     
672:     pub async fn complete(&self, id: u64) -> Result<Task, &'static str> {
673:         let mut tasks = self.tasks.write().await;
674:         match tasks.get_mut(&id) {
675:             Some(task) => {
676:                 task.completed = true;
677:                 Ok(task.clone())
678:             }
679:             None => Err("Task not found"),
680:         }
681:     }
682: }
683: 
684: /// Error type for our application
685: #[derive(Debug, thiserror::Error)]
686: pub enum AppError {
687:     #[error("Task not found: {0}")]
688:     NotFound(u64),
689:     #[error("Invalid input: {0}")]
690:     InvalidInput(String),
691: }
692: 
693: #[tokio::main]
694: async fn main() -> Result<(), Box<dyn std::error::Error>> {
695:     let store = Arc::new(TaskStore::new());
696:     
697:     // Create some tasks
698:     let task1 = store.create("Learn Rust".into(), Some("Study ownership".into())).await;
699:     let task2 = store.create("Build app".into(), None).await;
700:     
701:     println!("Created tasks:");
702:     for task in store.list().await {
703:         println!("  - {} ({})", task.title, if task.completed { "✓" } else { "○" });
704:     }
705:     
706:     // Complete a task
707:     store.complete(task1.id).await?;
708:     println!("\\nCompleted task: {}", task1.title);
709:     
710:     Ok(())
711: }
712: 
713: #[cfg(test)]
714: mod tests {
715:     use super::*;
716:     
717:     #[tokio::test]
718:     async fn test_create_task() {
719:         let store = TaskStore::new();
720:         let task = store.create("Test".into(), None).await;
721:         assert_eq!(task.title, "Test");
722:         assert!(!task.completed);
723:     }
724: }
725: """,
726:             language: "rust"
727:         ))
728:         
729:         return examples
730:     }
731: 
732:     // MARK: - Tab Management
733: 
734:     func addTab(fileName: String = "Untitled.swift", content: String = "", url: URL? = nil) {
735:         // Check if file is already open
736:         if let url = url, let existingTab = tabs.first(where: { $0.url == url }) {
737:             activeTabId = existingTab.id
738:             return
739:         }
740: 
741:         let newTab = Tab(fileName: fileName, content: content, url: url)
742:         tabs.append(newTab)
743:         activeTabId = newTab.id
744:     }
745: 
746:     func closeTab(id: UUID) {
747:         guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
748: 
749:         // Release security-scoped access if this tab was holding it.
750:         if let url = tabs[index].url {
751:             releaseSecurityScopedAccess(to: url)
752:         }
753: 
754:         tabs.remove(at: index)
755: 
756:         // Update active tab if we closed the active one
757:         if activeTabId == id {
758:             if tabs.isEmpty {
759:                 activeTabId = nil
760:             } else if index >= tabs.count {
761:                 activeTabId = tabs[tabs.count - 1].id
762:             } else {
763:                 activeTabId = tabs[index].id
764:             }
765:         }
766:     }
767: 
768:     func closeAllTabs() {
769:         // Release security-scoped access held by any open tabs.
770:         for tab in tabs {
771:             if let url = tab.url {
772:                 releaseSecurityScopedAccess(to: url)
773:             }
774:         }
775: 
776:         tabs.removeAll()
777:         activeTabId = nil
778:     }
779: 
780:     func closeOtherTabs(except id: UUID) {
781:         // Release security-scoped access for tabs being closed.
782:         for tab in tabs where tab.id != id {
783:             if let url = tab.url {
784:                 releaseSecurityScopedAccess(to: url)
785:             }
786:         }
787: 
788:         tabs.removeAll { $0.id != id }
789:         activeTabId = id
790:     }
791: 
792:     func selectTab(id: UUID) {
793:         activeTabId = id
794:     }
795: 
796:     func nextTab() {
797:         guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
798:         let nextIndex = (currentIndex + 1) % tabs.count
799:         activeTabId = tabs[nextIndex].id
800:     }
801: 
802:     func previousTab() {
803:         guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
804:         let prevIndex = currentIndex == 0 ? tabs.count - 1 : currentIndex - 1
805:         activeTabId = tabs[prevIndex].id
806:     }
807: 
808:     func moveTab(from source: IndexSet, to destination: Int) {
809:         tabs.move(fromOffsets: source, toOffset: destination)
810:     }
811: 
812:     // MARK: - Content Management
813: 
814:     func updateActiveTabContent(_ content: String) {
815:         guard let index = activeTabIndex else { return }
816: 
817:         // Avoid marking a tab dirty when we're just syncing state (e.g., initial onAppear assignment).
818:         guard tabs[index].content != content else { return }
819: 
820:         tabs[index].content = content
821: 
822:         // Mark dirty for both saved and unsaved-new files.
823:         tabs[index].isUnsaved = true
824:     }
825: 
826:     func saveActiveTab() {
827:         guard let index = activeTabIndex,
828:               let url = tabs[index].url else { return }
829: 
830:         do {
831:             if let fileNavigator {
832:                 try fileNavigator.writeFile(at: url, content: tabs[index].content)
833:             } else {
834:                 // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
835:                 let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
836:                 defer { if didStart { url.stopAccessingSecurityScopedResource() } }
837:                 try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
838:             }
839: 
840:             tabs[index].isUnsaved = false
841:         } catch {
842:             print("Error saving file: \(error)")
843:         }
844:     }
845: 
846:     func saveAllTabs() {
847:         for index in tabs.indices {
848:             guard let url = tabs[index].url, tabs[index].isUnsaved else { continue }
849: 
850:             do {
851:                 if let fileNavigator {
852:                     try fileNavigator.writeFile(at: url, content: tabs[index].content)
853:                 } else {
854:                     // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
855:                     let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
856:                     defer { if didStart { url.stopAccessingSecurityScopedResource() } }
857:                     try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
858:                 }
859: 
860:                 tabs[index].isUnsaved = false
861:             } catch {
862:                 print("Error saving file: \(error)")
863:             }
864:         }
865:     }
866: 
867:     // MARK: - File Operations
868: 
869:     /// Retain security scoped access for as long as a tab referencing the URL is open.
870:     /// - Returns: `true` if access was retained (either already retained or started successfully).
871:     @discardableResult
872:     private func retainSecurityScopedAccess(to url: URL) -> Bool {
873:         if let count = securityScopedAccessCounts[url] {
874:             securityScopedAccessCounts[url] = count + 1
875:             return true
876:         }
877: 
878:         let started = url.startAccessingSecurityScopedResource()
879:         if started {
880:             securityScopedAccessCounts[url] = 1
881:             return true
882:         }
883: 
884:         // Not all URLs are security-scoped; startAccessing may legitimately return false.
885:         return false
886:     }
887: 
888:     private func releaseSecurityScopedAccess(to url: URL) {
889:         guard let count = securityScopedAccessCounts[url] else { return }
890:         if count <= 1 {
891:             securityScopedAccessCounts.removeValue(forKey: url)
892:             url.stopAccessingSecurityScopedResource()
893:         } else {
894:             securityScopedAccessCounts[url] = count - 1
895:         }
896:     }
897: 
898:     func openFile(from url: URL) {
899:         // If already open, just activate it (and avoid re-reading / re-requesting access).
900:         if let existingTab = tabs.first(where: { $0.url == url }) {
901:             activeTabId = existingTab.id
902:             return
903:         }
904: 
905:         // IMPORTANT (BUG-005):
906:         // Do not early-return if startAccessingSecurityScopedResource() fails.
907:         // For many URLs (non-security-scoped, or when parent scope is active), this may return false,
908:         // but the file is still readable. We retain access if available.
909:         let retained = retainSecurityScopedAccess(to: url)
910: 
911:         do {
912:             let content = try String(contentsOf: url, encoding: .utf8)
913:             addTab(fileName: url.lastPathComponent, content: content, url: url)
914: 
915:             // Index the file in Spotlight for search
916:             SpotlightManager.shared.indexFile(url: url, content: content, fileName: url.lastPathComponent)
917:         } catch {
918:             print("Error opening file: \(error)")
919:             if retained {
920:                 // We retained access but failed to open; release our retain.
921:                 releaseSecurityScopedAccess(to: url)
922:             }
923:         }
924:     }
925: 
926:     func openFile(_ fileItem: FileItem) {
927:         guard let url = fileItem.url else {
928:             // Try path
929:             if !fileItem.path.isEmpty {
930:                 let fileURL = URL(fileURLWithPath: fileItem.path)
931:                 openFile(from: fileURL)
932:             }
933:             return
934:         }
935:         openFile(from: url)
936:     }
937: 
938:     // MARK: - File System Event Handlers
939: 
940:     /// Called when a file or folder is moved/renamed in the file system.
941:     /// Updates any open tabs that reference the old URL.
942:     func handleFileSystemItemMoved(from oldURL: URL, to newURL: URL) {
943:         for index in tabs.indices {
944:             guard let tabURL = tabs[index].url else { continue }
945: 
946:             // Check if tab URL matches the moved item or is inside it (for folders)
947:             let oldPath = oldURL.standardizedFileURL.path
948:             let tabPath = tabURL.standardizedFileURL.path
949: 
950:             if tabPath == oldPath {
951:                 // Direct match - update URL
952:                 tabs[index].url = newURL
953:                 tabs[index].fileName = newURL.lastPathComponent
954:             } else if tabPath.hasPrefix(oldPath + "/") {
955:                 // Tab is inside a moved folder - update the path prefix
956:                 let relativePath = String(tabPath.dropFirst(oldPath.count))
957:                 let newTabURL = URL(fileURLWithPath: newURL.path + relativePath)
958:                 tabs[index].url = newTabURL
959:             }
960:         }
961:     }
962: 
963:     /// Called when a file or folder is deleted from the file system.
964:     /// Closes any open tabs that reference the deleted item.
965:     func handleFileSystemItemDeleted(at url: URL) {
966:         let deletedPath = url.standardizedFileURL.path
967: 
968:         // Find all tabs that should be closed
969:         let tabsToClose = tabs.filter { tab in
970:             guard let tabURL = tab.url else { return false }
971:             let tabPath = tabURL.standardizedFileURL.path
972:             // Close if exact match or if tab is inside deleted folder
973:             return tabPath == deletedPath || tabPath.hasPrefix(deletedPath + "/")
974:         }
975: 
976:         // Close the tabs (release security access)
977:         for tab in tabsToClose {
978:             closeTab(id: tab.id)
979:         }
980:     }
981: 
982:     // MARK: - UI Toggles
983: 
984:     func toggleSidebar() {
985:         withAnimation(.spring(response: 0.3)) {
986:             showSidebar.toggle()
987:         }
988:     }
989: 
990:     func toggleCommandPalette() {
991:         showCommandPalette.toggle()
992:     }
993: 
994:     func toggleQuickOpen() {
995:         showQuickOpen.toggle()
996:     }
997: 
998:     func toggleSearch() {
999:         showSearch.toggle()
1000:     }
1001: 
1002:     func toggleAIAssistant() {
1003:         showAIAssistant.toggle()
1004:     }
1005: 
1006:     func toggleGoToSymbol() {
1007:         showGoToSymbol.toggle()
1008:     }
1009: 
1010:     func toggleZenMode() {
1011:         isZenMode.toggle()
1012:     }
1013: 
1014:     func toggleFocusMode() {
1015:         isFocusMode.toggle()
1016:     }
1017: 
1018:     func togglePanel() {
1019:         withAnimation(.spring(response: 0.3)) {
1020:             showPanel.toggle()
1021:         }
1022:     }
1023: 
1024:     func addSelectionToNextFindMatch() {
1025:         addNextOccurrence()
1026:     }
1027: 
1028:     func zoomIn() {
1029:         editorFontSize = min(editorFontSize + 2, 32)
1030:     }
1031: 
1032:     func zoomOut() {
1033:         editorFontSize = max(editorFontSize - 2, 8)
1034:     }
1035: 
1036:     func resetZoom() {
1037:         editorFontSize = 14.0
1038:     }
1039: 
1040:     func focusExplorer() {
1041:         focusedView = .explorer
1042:         focusedSidebarTab = 0
1043:         withAnimation {
1044:             showSidebar = true
1045:         }
1046:     }
1047: 
1048:     func focusGit() {
1049:         focusedView = .git
1050:         focusedSidebarTab = 1
1051:         withAnimation {
1052:             showSidebar = true
1053:         }
1054:     }
1055: 
1056:     func renameSymbol() {
1057:         showRenameSymbol.toggle()
1058:     }
1059: 
1060:     // NOTE:
1061:     // goToDefinitionAtCursor(), peekDefinitionAtCursor(), navigateBack(), and navigateForward()
1062:     // are implemented in an EditorCore extension in Services/NavigationManager.swift.
1063: 
1064:     // MARK: - Peek Definition
1065: 
1066:     func triggerPeekDefinition(file: String, line: Int, content: String, sourceLine: Int) {
1067:         peekState = PeekState(file: file, line: line, content: content, sourceLine: sourceLine)
1068:     }
1069: 
1070:     func closePeekDefinition() {
1071:         peekState = nil
1072:     }
1073: 
1074:     // MARK: - Multi-Cursor Operations
1075: 
1076:     /// Add cursor at a specific position (Option+Click)
1077:     func addCursorAtPosition(_ position: Int) {
1078:         multiCursorState.addCursor(at: position)
1079:     }
1080: 
1081:     /// Add cursor on the line above (Cmd+Option+Up)
1082:     func addCursorAbove() {
1083:         guard let index = activeTabIndex else { return }
1084:         let content = tabs[index].content
1085:         
1086:         guard let primary = multiCursorState.primaryCursor else { return }
1087:         
1088:         // Find current line and column
1089:         let lines = content.components(separatedBy: "\n")
1090:         var currentLine = 0
1091:         var charCount = 0
1092:         var columnInLine = 0
1093:         
1094:         for (lineIndex, line) in lines.enumerated() {
1095:             let lineLength = line.count + 1 // +1 for newline
1096:             if charCount + lineLength > primary.position {
1097:                 currentLine = lineIndex
1098:                 columnInLine = primary.position - charCount
1099:                 break
1100:             }
1101:             charCount += lineLength
1102:         }
1103:         
1104:         // Can't add cursor above line 0
1105:         guard currentLine > 0 else { return }
1106:         
1107:         // Calculate position on line above
1108:         let targetLine = currentLine - 1
1109:         var targetPosition = 0
1110:         for i in 0..<targetLine {
1111:             targetPosition += lines[i].count + 1
1112:         }
1113:         targetPosition += min(columnInLine, lines[targetLine].count)
1114:         
1115:         multiCursorState.addCursor(at: targetPosition)
1116:     }
1117: 
1118:     /// Add cursor on the line below (Cmd+Option+Down)
1119:     func addCursorBelow() {
1120:         guard let index = activeTabIndex else { return }
1121:         let content = tabs[index].content
1122:         
1123:         guard let primary = multiCursorState.primaryCursor else { return }
1124:         
1125:         // Find current line and column
1126:         let lines = content.components(separatedBy: "\n")
1127:         var currentLine = 0
1128:         var charCount = 0
1129:         var columnInLine = 0
1130:         
1131:         for (lineIndex, line) in lines.enumerated() {
1132:             let lineLength = line.count + 1 // +1 for newline
1133:             if charCount + lineLength > primary.position {
1134:                 currentLine = lineIndex
1135:                 columnInLine = primary.position - charCount
1136:                 break
1137:             }
1138:             charCount += lineLength
1139:         }
1140:         
1141:         // Can't add cursor below last line
1142:         guard currentLine < lines.count - 1 else { return }
1143:         
1144:         // Calculate position on line below
1145:         let targetLine = currentLine + 1
1146:         var targetPosition = 0
1147:         for i in 0..<targetLine {
1148:             targetPosition += lines[i].count + 1
1149:         }
1150:         targetPosition += min(columnInLine, lines[targetLine].count)
1151:         
1152:         multiCursorState.addCursor(at: targetPosition)
1153:     }
1154: 
1155:     /// Add next occurrence of current selection (Cmd+D)
1156:     func addNextOccurrence() {
1157:         guard let index = activeTabIndex else { return }
1158:         let content = tabs[index].content
1159: 
1160:         // Get the word/selection to search for
1161:         let searchText: String
1162:         let startPosition: Int
1163: 
1164:         if let range = currentSelectionRange, range.length > 0,
1165:            let swiftRange = Range(range, in: content) {
1166:             searchText = String(content[swiftRange])
1167:             startPosition = range.location + range.length
1168:         } else if let primary = multiCursorState.primaryCursor {
1169:             // No selection - select the word under cursor
1170:             let wordRange = findWordAtPosition(primary.position, in: content)
1171:             if let range = wordRange, range.length > 0,
1172:                let swiftRange = Range(range, in: content) {
1173:                 searchText = String(content[swiftRange])
1174:                 startPosition = range.location + range.length
1175: 
1176:                 // First Cmd+D selects the word under cursor
1177:                 multiCursorState.cursors = [Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)]
1178:                 currentSelectionRange = range
1179:                 currentSelection = searchText
1180:                 return
1181:             } else {
1182:                 return
1183:             }
1184:         } else {
1185:             return
1186:         }
1187: 
1188:         // Find next occurrence
1189:         if let nextRange = content.findNextOccurrence(of: searchText, after: startPosition) {
1190:             // Check if this occurrence is already selected
1191:             let alreadySelected = multiCursorState.cursors.contains { cursor in
1192:                 if let selRange = cursor.selectionRange {
1193:                     return selRange.location == nextRange.location
1194:                 }
1195:                 return false
1196:             }
1197: 
1198:             if !alreadySelected {
1199:                 multiCursorState.addCursorWithSelection(
1200:                     position: nextRange.location + nextRange.length,
1201:                     anchor: nextRange.location
1202:                 )
1203:             }
1204:         }
1205:     }
1206: 
1207:     /// Select all occurrences of current selection (Cmd+Shift+L)
1208:     func selectAllOccurrences() {
1209:         guard let index = activeTabIndex else { return }
1210:         let content = tabs[index].content
1211: 
1212:         // Get the word/selection to search for
1213:         let searchText: String
1214: 
1215:         if let range = currentSelectionRange, range.length > 0,
1216:            let swiftRange = Range(range, in: content) {
1217:             searchText = String(content[swiftRange])
1218:         } else if let primary = multiCursorState.primaryCursor {
1219:             // No selection - use word under cursor
1220:             let wordRange = findWordAtPosition(primary.position, in: content)
1221:             if let range = wordRange, range.length > 0,
1222:                let swiftRange = Range(range, in: content) {
1223:                 searchText = String(content[swiftRange])
1224:             } else {
1225:                 return
1226:             }
1227:         } else {
1228:             return
1229:         }
1230: 
1231:         // Find all occurrences
1232:         let allRanges = content.findAllOccurrences(of: searchText)
1233: 
1234:         guard !allRanges.isEmpty else { return }
1235: 
1236:         // Create cursors for all occurrences
1237:         multiCursorState.cursors = allRanges.enumerated().map { index, range in
1238:             Cursor(
1239:                 position: range.location + range.length,
1240:                 anchor: range.location,
1241:                 isPrimary: index == 0
1242:             )
1243:         }
1244: 
1245:         currentSelection = searchText
1246:     }
1247: 
1248:     /// Reset to single cursor
1249:     func resetToSingleCursor(at position: Int) {
1250:         multiCursorState.reset(to: position)
1251:         currentSelectionRange = nil
1252:         currentSelection = ""
1253:     }
1254: 
1255:     /// Update selection from text view
1256:     func updateSelection(range: NSRange?, text: String) {
1257:         currentSelectionRange = range
1258:         if let range = range, range.length > 0,
1259:            let index = activeTabIndex {
1260:             let content = tabs[index].content
1261:             if let swiftRange = Range(range, in: content) {
1262:                 currentSelection = String(content[swiftRange])
1263:             }
1264:         } else {
1265:             currentSelection = ""
1266:         }
1267:     }
1268: 
1269:     /// Find word boundaries at a given position
1270:     func findWordAtPosition(_ position: Int, in text: String) -> NSRange? {
1271:         guard position >= 0 && position <= text.count else { return nil }
1272: 
1273:         let nsText = text as NSString
1274:         let wordCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
1275: 
1276:         // Find start of word
1277:         var start = position
1278:         while start > 0 {
1279:             let char = nsText.substring(with: NSRange(location: start - 1, length: 1))
1280:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
1281:                 start -= 1
1282:             } else {
1283:                 break
1284:             }
1285:         }
1286: 
1287:         // Find end of word
1288:         var end = position
1289:         while end < nsText.length {
1290:             let char = nsText.substring(with: NSRange(location: end, length: 1))
1291:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
1292:                 end += 1
1293:             } else {
1294:                 break
1295:             }
1296:         }
1297: 
1298:         if start == end {
1299:             return nil
1300:         }
1301: 
1302:         return NSRange(location: start, length: end - start)
1303:     }
1304: 
1305:     /// Escape multi-cursor mode
1306:     func escapeMultiCursor() {
1307:         if multiCursorState.isMultiCursor {
1308:             if let primary = multiCursorState.primaryCursor {
1309:                 resetToSingleCursor(at: primary.position)
1310:             }
1311:         }
1312:     }
1313: 
1314:     // MARK: - Code Folding
1315: 
1316:     /// Collapse all foldable regions in the active editor
1317:     func collapseAllFolds() {
1318:         guard let index = activeTabIndex else { return }
1319:         // Post notification that will be picked up by the editor view
1320:         NotificationCenter.default.post(
1321:             name: .collapseAllFolds,
1322:             object: nil,
1323:             userInfo: ["tabId": tabs[index].id]
1324:         )
1325:     }
1326: 
1327:     /// Expand all collapsed regions in the active editor
1328:     func expandAllFolds() {
1329:         guard let index = activeTabIndex else { return }
1330:         // Post notification that will be picked up by the editor view
1331:         NotificationCenter.default.post(
1332:             name: .expandAllFolds,
1333:             object: nil,
1334:             userInfo: ["tabId": tabs[index].id]
1335:         )
1336:     }
1337: }
1338: 
1339: // MARK: - Notification Names for Code Folding
1340: 
1341: extension Notification.Name {
1342:     static let collapseAllFolds = Notification.Name("collapseAllFolds")
1343:     static let expandAllFolds = Notification.Name("expandAllFolds")
1344: }
1345: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/SettingsManager.swift (lines 1-99 of 99)
────────────────────────────────────────
1: import Foundation
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
81:         }
82: 
83:         for name in candidates {
84:             if let font = UIFont(name: name, size: size) {
85:                 // Ensure monospaced feel if available; otherwise return as-is.
86:                 return font
87:             }
88:         }
89: 
90:         // Fallback
91:         return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
92:     }
93: 
94:     /// A stable key used to detect when re-highlighting is necessary.
95:     var editorStyleKey: String {
96:         "\(fontFamily)|\(Int(fontSize))|\(clampedTabSize)"
97:     }
98: }
99: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/FileItem.swift (lines 1-83 of 83)
────────────────────────────────────────
1: import Foundation
2: import SwiftUI
3: 
4: /// Represents a file or directory in the file system
5: struct FileItem: Identifiable, Hashable {
6:     let id: UUID
7:     var name: String
8:     var url: URL?
9:     var path: String
10:     var isDirectory: Bool
11:     var children: [FileItem]?
12:     var isExpanded: Bool
13:     
14:     init(
15:         id: UUID = UUID(),
16:         name: String,
17:         url: URL? = nil,
18:         path: String = "",
19:         isDirectory: Bool = false,
20:         children: [FileItem]? = nil,
21:         isExpanded: Bool = false
22:     ) {
23:         self.id = id
24:         self.name = name
25:         self.url = url
26:         self.path = path.isEmpty ? (url?.path ?? "") : path
27:         self.isDirectory = isDirectory
28:         self.children = children
29:         self.isExpanded = isExpanded
30:     }
31:     
32:     var fileExtension: String {
33:         (name as NSString).pathExtension.lowercased()
34:     }
35:     
36:     var icon: String {
37:         FileItem.getFileIcon(for: name, isDirectory: isDirectory, isExpanded: isExpanded)
38:     }
39:     
40:     var iconColor: Color {
41:         FileItem.getFileColor(for: name, isDirectory: isDirectory)
42:     }
43:     
44:     // MARK: - File Icon Helpers (inline to avoid dependency issues)
45:     
46:     static func getFileIcon(for filename: String, isDirectory: Bool = false, isExpanded: Bool = false) -> String {
47:         if isDirectory {
48:             return isExpanded ? "folder.fill.badge.minus" : "folder.fill"
49:         }
50:         
51:         let ext = (filename as NSString).pathExtension.lowercased()
52:         switch ext {
53:         case "swift": return "swift"
54:         case "js", "jsx", "ts", "tsx": return "curlybraces"
55:         case "py": return "chevron.left.forwardslash.chevron.right"
56:         case "html", "htm": return "globe"
57:         case "css", "scss": return "paintbrush.fill"
58:         case "json": return "curlybraces.square"
59:         case "md", "markdown": return "doc.richtext"
60:         default: return "doc.text"
61:         }
62:     }
63:     
64:     static func getFileColor(for filename: String, isDirectory: Bool = false) -> Color {
65:         if isDirectory {
66:             return .yellow
67:         }
68:         
69:         let ext = (filename as NSString).pathExtension.lowercased()
70:         switch ext {
71:         case "swift": return .orange
72:         case "js", "jsx": return .yellow
73:         case "ts", "tsx": return .blue
74:         case "py": return .green
75:         case "html", "htm": return .red
76:         case "css", "scss": return .purple
77:         case "json": return .green
78:         case "md", "markdown": return .blue
79:         default: return .gray
80:         }
81:     }
82: }
83: 


Let me read more key files to complete the architecture understanding:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models/Tab.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models/ThemeManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/FileSystemNavigator.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/Tab.swift (lines 1-244 of 244)
────────────────────────────────────────
1: //
2: //  Tab.swift
3: //  VSCodeiPadOS
4: //
5: //  Created by AI Assistant
6: //  A model representing an editor tab with file content and metadata
7: //
8: 
9: import Foundation
10: import SwiftUI
11: 
12: /// Represents an open editor tab containing file content
13: struct Tab: Identifiable, Equatable, Hashable, Codable {
14:     // MARK: - Properties
15:     
16:     /// Unique identifier for the tab
17:     let id: UUID
18:     
19:     /// Display name of the file
20:     var fileName: String
21:     
22:     /// Current content of the file
23:     var content: String
24:     
25:     /// Programming language/file type
26:     var language: CodeLanguage
27:     
28:     /// File system URL (nil for unsaved new files)
29:     var url: URL?
30:     
31:     /// Whether the file has unsaved changes
32:     var isUnsaved: Bool
33:     
34:     /// Whether this tab is currently active/selected
35:     var isActive: Bool
36:     
37:     /// Whether this tab is pinned
38:     var isPinned: Bool
39:     
40:     /// Whether this tab is in preview mode
41:     var isPreview: Bool
42:     
43:     // MARK: - Initialization
44:     
45:     /// Creates a new tab
46:     /// - Parameters:
47:     ///   - id: Unique identifier (auto-generated if not provided)
48:     ///   - fileName: Display name for the file
49:     ///   - content: File content (empty by default)
50:     ///   - language: Programming language (auto-detected from fileName if not provided)
51:     ///   - url: File system URL (nil for new unsaved files)
52:     ///   - isUnsaved: Whether file has unsaved changes (false by default)
53:     ///   - isActive: Whether this is the active tab (false by default)
54:     ///   - isPinned: Whether the tab is pinned (false by default)
55:     ///   - isPreview: Whether the tab is in preview mode (false by default)
56:     init(
57:         id: UUID = UUID(),
58:         fileName: String,
59:         content: String = "",
60:         language: CodeLanguage? = nil,
61:         url: URL? = nil,
62:         isUnsaved: Bool = false,
63:         isActive: Bool = false,
64:         isPinned: Bool = false,
65:         isPreview: Bool = false
66:     ) {
67:         self.id = id
68:         self.fileName = fileName
69:         self.content = content
70:         self.url = url
71:         self.isUnsaved = isUnsaved
72:         self.isActive = isActive
73:         self.isPinned = isPinned
74:         self.isPreview = isPreview
75:         
76:         // Auto-detect language from file extension if not provided
77:         if let language = language {
78:             self.language = language
79:         } else {
80:             let fileExtension = (fileName as NSString).pathExtension
81:             self.language = CodeLanguage(from: fileExtension)
82:         }
83:     }
84:     
85:     /// Convenience initializer that accepts language as String
86:     init(
87:         id: UUID = UUID(),
88:         fileName: String,
89:         content: String = "",
90:         language: String,
91:         url: URL? = nil,
92:         isUnsaved: Bool = false,
93:         isActive: Bool = false,
94:         isPinned: Bool = false,
95:         isPreview: Bool = false
96:     ) {
97:         self.init(
98:             id: id,
99:             fileName: fileName,
100:             content: content,
101:             language: CodeLanguage(from: language),
102:             url: url,
103:             isUnsaved: isUnsaved,
104:             isActive: isActive,
105:             isPinned: isPinned,
106:             isPreview: isPreview
107:         )
108:     }
109:     
110:     // MARK: - Computed Properties
111:     
112:     /// File extension (e.g., "swift", "js")
113:     var fileExtension: String {
114:         (fileName as NSString).pathExtension.lowercased()
115:     }
116:     
117:     /// Display title for the tab (includes unsaved indicator)
118:     var displayTitle: String {
119:         isUnsaved ? "● \(fileName)" : fileName
120:     }
121:     
122:     /// Number of lines in the content
123:     var lineCount: Int {
124:         content.isEmpty ? 0 : content.components(separatedBy: .newlines).count
125:     }
126:     
127:     /// File size in bytes
128:     var contentSize: Int {
129:         content.utf8.count
130:     }
131:     
132:     // MARK: - Equatable & Hashable
133:     
134:     /// Tabs are equal if they have the same ID
135:     static func == (lhs: Tab, rhs: Tab) -> Bool {
136:         lhs.id == rhs.id
137:     }
138:     
139:     /// Hash based on ID only
140:     func hash(into hasher: inout Hasher) {
141:         hasher.combine(id)
142:     }
143: }
144: 
145: // MARK: - CodeLanguage
146: 
147: /// Supported programming languages and file types
148: enum CodeLanguage: String, CaseIterable, Codable {
149:     case swift = "swift"
150:     case javascript = "javascript"
151:     case typescript = "typescript"
152:     case python = "python"
153:     case html = "html"
154:     case css = "css"
155:     case json = "json"
156:     case markdown = "markdown"
157:     case yaml = "yaml"
158:     case xml = "xml"
159:     case plainText = "plaintext"
160:     
161:     // MARK: - Initialization
162:     
163:     /// Detects language from file extension
164:     /// - Parameter fileExtension: File extension (e.g., "swift", "js")
165:     init(from fileExtension: String) {
166:         let ext = fileExtension.lowercased()
167:         switch ext {
168:         case "swift":
169:             self = .swift
170:         case "js", "jsx", "mjs":
171:             self = .javascript
172:         case "ts", "tsx":
173:             self = .typescript
174:         case "py", "pyw":
175:             self = .python
176:         case "html", "htm":
177:             self = .html
178:         case "css", "scss", "sass", "less":
179:             self = .css
180:         case "json":
181:             self = .json
182:         case "md", "markdown":
183:             self = .markdown
184:         case "yml", "yaml":
185:             self = .yaml
186:         case "xml":
187:             self = .xml
188:         default:
189:             self = .plainText
190:         }
191:     }
192:     
193:     // MARK: - Display Properties
194:     
195:     /// Human-readable display name
196:     var displayName: String {
197:         switch self {
198:         case .swift: return "Swift"
199:         case .javascript: return "JavaScript"
200:         case .typescript: return "TypeScript"
201:         case .python: return "Python"
202:         case .html: return "HTML"
203:         case .css: return "CSS"
204:         case .json: return "JSON"
205:         case .markdown: return "Markdown"
206:         case .yaml: return "YAML"
207:         case .xml: return "XML"
208:         case .plainText: return "Plain Text"
209:         }
210:     }
211:     
212:     /// Icon name for SF Symbols
213:     var iconName: String {
214:         switch self {
215:         case .swift: return "swift"
216:         case .javascript, .typescript: return "curlybraces"
217:         case .python: return "chevron.left.forwardslash.chevron.right"
218:         case .html: return "globe"
219:         case .css: return "paintbrush"
220:         case .json: return "curlybraces.square"
221:         case .markdown: return "doc.richtext"
222:         case .yaml, .xml: return "doc.text"
223:         case .plainText: return "doc"
224:         }
225:     }
226:     
227:     /// Color associated with the language
228:     var color: Color {
229:         switch self {
230:         case .swift: return .orange
231:         case .javascript: return .yellow
232:         case .typescript: return .blue
233:         case .python: return .green
234:         case .html: return .red
235:         case .css: return .purple
236:         case .json: return .green
237:         case .markdown: return .blue
238:         case .yaml: return .cyan
239:         case .xml: return .orange
240:         case .plainText: return .gray
241:         }
242:     }
243: }
244: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/ThemeManager.swift (lines 1-77 of 77)
────────────────────────────────────────
1: import SwiftUI
2: import Combine
3: 
4: class ThemeManager: ObservableObject {
5:     @AppStorage("selectedThemeId") var selectedThemeId: String = "dark_plus"
6:     @Published var currentTheme: Theme
7:     
8:     static let shared = ThemeManager()
9:     
10:     // Quick access to current theme
11:     static var current: Theme { shared.currentTheme }
12:     
13:     init() {
14:         let themeId = UserDefaults.standard.string(forKey: "selectedThemeId") ?? "dark_plus"
15:         self.currentTheme = Theme.allThemes.first(where: { $0.id == themeId }) ?? .darkPlus
16:     }
17:     
18:     func switchTheme(to themeId: String) {
19:         if let theme = Theme.allThemes.first(where: { $0.id == themeId }) {
20:             withAnimation(.easeInOut(duration: 0.2)) {
21:                 self.currentTheme = theme
22:             }
23:             self.selectedThemeId = themeId
24:         }
25:     }
26:     
27:     func switchTheme(to theme: Theme) {
28:         switchTheme(to: theme.id)
29:     }
30:     
31:     // Cycle to next theme
32:     func nextTheme() {
33:         let themes = Theme.allThemes
34:         guard let currentIndex = themes.firstIndex(where: { $0.id == currentTheme.id }) else {
35:             switchTheme(to: themes.first!)
36:             return
37:         }
38:         let nextIndex = (currentIndex + 1) % themes.count
39:         switchTheme(to: themes[nextIndex])
40:     }
41:     
42:     // Cycle to previous theme
43:     func previousTheme() {
44:         let themes = Theme.allThemes
45:         guard let currentIndex = themes.firstIndex(where: { $0.id == currentTheme.id }) else {
46:             switchTheme(to: themes.first!)
47:             return
48:         }
49:         let prevIndex = currentIndex == 0 ? themes.count - 1 : currentIndex - 1
50:         switchTheme(to: themes[prevIndex])
51:     }
52:     
53:     // Get themes by category
54:     var darkThemes: [Theme] {
55:         Theme.allThemes.filter { $0.isDark }
56:     }
57:     
58:     var lightThemes: [Theme] {
59:         Theme.allThemes.filter { !$0.isDark }
60:     }
61:     
62:     // Helper for file colors that adapts to theme
63:     func color(for filename: String) -> Color {
64:         let ext = (filename as NSString).pathExtension.lowercased()
65:         switch ext {
66:         case "swift": return .orange
67:         case "js", "jsx": return .yellow
68:         case "ts", "tsx": return .blue
69:         case "py": return .green
70:         case "html", "htm": return .red
71:         case "css", "scss": return .purple
72:         case "json": return .green
73:         case "md": return .blue
74:         default: return currentTheme.isDark ? .white : .black
75:         }
76:     }
77: }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/FileSystemNavigator.swift (lines 1-336 of 336)
────────────────────────────────────────
1: import SwiftUI
2: import Foundation
3: import Combine
4: 
5: final class FileSystemNavigator: ObservableObject {
6:     @Published var fileTree: FileTreeNode?
7:     @Published var expandedPaths: Set<String> = []
8: 
9:     /// The currently opened workspace root URL (if any).
10:     @Published private(set) var rootURL: URL?
11: 
12:     /// Convenience for callers that store paths.
13:     var rootPath: String? { rootURL?.path }
14: 
15:     func loadFileTree(at url: URL) {
16:         // Treat this as the workspace root.
17:         rootURL = url
18: 
19:         DispatchQueue.global(qos: .userInitiated).async {
20:             let tree = self.buildFileTree(at: url)
21:             DispatchQueue.main.async {
22:                 self.fileTree = tree
23:                 if let tree = tree {
24:                     self.expandedPaths.insert(tree.url.path)
25:                 }
26:             }
27:         }
28:     }
29: 
30:     // MARK: - File Read/Write
31: 
32:     /// Write UTF-8 text to a URL, handling security-scoped access when applicable.
33:     func writeFile(at url: URL, content: String) throws {
34:         // Try to access the file; if that fails, try its parent folder (common on iPadOS).
35:         let didStartItem = url.startAccessingSecurityScopedResource()
36:         let parentURL = url.deletingLastPathComponent()
37:         let didStartParent = (!didStartItem) ? parentURL.startAccessingSecurityScopedResource() : false
38: 
39:         defer {
40:             if didStartItem { url.stopAccessingSecurityScopedResource() }
41:             if didStartParent { parentURL.stopAccessingSecurityScopedResource() }
42:         }
43: 
44:         try content.write(to: url, atomically: true, encoding: .utf8)
45:     }
46: 
47:     /// Create a new empty file, choosing a unique name if needed, and return its URL.
48:     func createFileUnique(named name: String, in folder: URL) throws -> URL {
49:         let didStart = folder.startAccessingSecurityScopedResource()
50:         defer { if didStart { folder.stopAccessingSecurityScopedResource() } }
51: 
52:         let initialURL = folder.appendingPathComponent(name, isDirectory: false)
53:         let finalURL = uniqueDestinationURL(for: initialURL, fileManager: FileManager.default)
54: 
55:         let created = FileManager.default.createFile(atPath: finalURL.path, contents: Data(), attributes: nil)
56:         if !created {
57:             throw NSError(domain: "FileSystemNavigator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create file"])
58:         }
59: 
60:         DispatchQueue.main.async { self.refreshFileTree() }
61:         return finalURL
62:     }
63: 
64:     // MARK: - Refresh
65: 
66:     /// Reload the tree for the currently opened root folder.
67:     ///
68:     /// Note: This intentionally preserves `expandedPaths` so folders don't collapse after operations.
69:     func refreshFileTree() {
70:         guard let currentTree = fileTree else { return }
71:         let rootURL = currentTree.url
72:         expandedPaths.insert(rootURL.path)
73:         loadFileTree(at: rootURL)
74:     }
75: 
76:     // MARK: - File Operations (Create / Rename / Move / Delete)
77: 
78:     /// Create a new empty file and return its URL.
79:     func createFile(named name: String, in folder: URL) throws -> URL {
80:         let didStart = folder.startAccessingSecurityScopedResource()
81:         defer { if didStart { folder.stopAccessingSecurityScopedResource() } }
82: 
83:         let fileURL = folder.appendingPathComponent(name, isDirectory: false)
84:         let fileManager = FileManager.default
85: 
86:         if fileManager.fileExists(atPath: fileURL.path) {
87:             throw NSError(domain: "FileSystemNavigator", code: 1, userInfo: [NSLocalizedDescriptionKey: "File already exists"])
88:         }
89: 
90:         let created = fileManager.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)
91:         if !created {
92:             throw NSError(domain: "FileSystemNavigator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create file"])
93:         }
94: 
95:         DispatchQueue.main.async { self.refreshFileTree() }
96:         return fileURL
97:     }
98: 
99:     /// Backwards-compatible async API.
100:     func createFile(name: String, in folder: URL) {
101:         DispatchQueue.global(qos: .userInitiated).async {
102:             let didStart = folder.startAccessingSecurityScopedResource()
103:             defer { if didStart { folder.stopAccessingSecurityScopedResource() } }
104: 
105:             let fileURL = folder.appendingPathComponent(name, isDirectory: false)
106:             let fileManager = FileManager.default
107:             if !fileManager.fileExists(atPath: fileURL.path) {
108:                 _ = fileManager.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)
109:             }
110: 
111:             DispatchQueue.main.async { self.refreshFileTree() }
112:         }
113:     }
114: 
115:     /// Create a new folder and return its URL.
116:     func createFolder(named name: String, in folder: URL) throws -> URL {
117:         let didStart = folder.startAccessingSecurityScopedResource()
118:         defer { if didStart { folder.stopAccessingSecurityScopedResource() } }
119: 
120:         let folderURL = folder.appendingPathComponent(name, isDirectory: true)
121:         let fileManager = FileManager.default
122: 
123:         if fileManager.fileExists(atPath: folderURL.path) {
124:             throw NSError(domain: "FileSystemNavigator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Folder already exists"])
125:         }
126: 
127:         try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
128:         DispatchQueue.main.async { self.refreshFileTree() }
129:         return folderURL
130:     }
131: 
132:     /// Backwards-compatible async API.
133:     func createFolder(name: String, in folder: URL) {
134:         DispatchQueue.global(qos: .userInitiated).async {
135:             let didStart = folder.startAccessingSecurityScopedResource()
136:             defer { if didStart { folder.stopAccessingSecurityScopedResource() } }
137: 
138:             let folderURL = folder.appendingPathComponent(name, isDirectory: true)
139:             let fileManager = FileManager.default
140: 
141:             do {
142:                 try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
143:             } catch {
144:                 print("Error creating folder at \(folderURL): \(error)")
145:             }
146: 
147:             DispatchQueue.main.async { self.refreshFileTree() }
148:         }
149:     }
150: 
151:     /// Rename a file or folder and return the new URL.
152:     func renameItem(at url: URL, to newName: String) throws -> URL {
153:         let parent = url.deletingLastPathComponent()
154: 
155:         let didStartItem = url.startAccessingSecurityScopedResource()
156:         let didStartParent = (!didStartItem) ? parent.startAccessingSecurityScopedResource() : false
157:         defer {
158:             if didStartItem { url.stopAccessingSecurityScopedResource() }
159:             if didStartParent { parent.stopAccessingSecurityScopedResource() }
160:         }
161: 
162:         let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
163:         let destination = parent.appendingPathComponent(newName, isDirectory: isDirectory)
164: 
165:         try FileManager.default.moveItem(at: url, to: destination)
166:         DispatchQueue.main.async { self.refreshFileTree() }
167:         return destination
168:     }
169: 
170:     /// Move a file/folder into a destination folder and return the new URL.
171:     func moveItem(at source: URL, to destinationFolder: URL) throws -> URL {
172:         let destinationIsDirectory = (try? destinationFolder.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? destinationFolder.hasDirectoryPath
173:         guard destinationIsDirectory else {
174:             throw NSError(domain: "FileSystemNavigator", code: 4, userInfo: [NSLocalizedDescriptionKey: "Destination must be a folder"])
175:         }
176: 
177:         let isDirectory = (try? source.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? source.hasDirectoryPath
178:         let fileManager = FileManager.default
179: 
180:         // Access security scoped resources for both ends.
181:         let didStartSource = source.startAccessingSecurityScopedResource()
182:         let didStartSourceParent = (!didStartSource) ? source.deletingLastPathComponent().startAccessingSecurityScopedResource() : false
183:         let didStartDest = destinationFolder.startAccessingSecurityScopedResource()
184:         defer {
185:             if didStartSource { source.stopAccessingSecurityScopedResource() }
186:             if didStartSourceParent { source.deletingLastPathComponent().stopAccessingSecurityScopedResource() }
187:             if didStartDest { destinationFolder.stopAccessingSecurityScopedResource() }
188:         }
189: 
190:         let initialDest = destinationFolder.appendingPathComponent(source.lastPathComponent, isDirectory: isDirectory)
191:         let finalDest = uniqueDestinationURL(for: initialDest, fileManager: fileManager)
192: 
193:         do {
194:             try fileManager.moveItem(at: source, to: finalDest)
195:         } catch {
196:             // Fallback for cross-volume moves.
197:             try fileManager.copyItem(at: source, to: finalDest)
198:             try fileManager.removeItem(at: source)
199:         }
200: 
201:         DispatchQueue.main.async { self.refreshFileTree() }
202:         return finalDest
203:     }
204: 
205:     /// Task-required API: move `source` to `destination`.
206:     /// - If `destination` is a folder, the item is moved *into* that folder.
207:     /// - If `destination` is a file URL, the item is moved/renamed to that exact URL.
208:     @discardableResult
209:     func moveItem(from source: URL, to destination: URL) -> Bool {
210:         do {
211:             let destinationIsDirectory = (try? destination.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? destination.hasDirectoryPath
212:             if destinationIsDirectory {
213:                 _ = try moveItem(at: source, to: destination)
214:             } else {
215:                 let didStartSource = source.startAccessingSecurityScopedResource()
216:                 let didStartSourceParent = (!didStartSource) ? source.deletingLastPathComponent().startAccessingSecurityScopedResource() : false
217:                 let didStartDestParent = destination.deletingLastPathComponent().startAccessingSecurityScopedResource()
218:                 defer {
219:                     if didStartSource { source.stopAccessingSecurityScopedResource() }
220:                     if didStartSourceParent { source.deletingLastPathComponent().stopAccessingSecurityScopedResource() }
221:                     if didStartDestParent { destination.deletingLastPathComponent().stopAccessingSecurityScopedResource() }
222:                 }
223: 
224:                 try FileManager.default.moveItem(at: source, to: destination)
225:                 DispatchQueue.main.async { self.refreshFileTree() }
226:             }
227:             return true
228:         } catch {
229:             print("Error moving item from \(source) to \(destination): \(error)")
230:             return false
231:         }
232:     }
233: 
234:     /// Delete a file or folder and refresh the tree.
235:     @discardableResult
236:     func deleteItem(at url: URL) -> Bool {
237:         var success = false
238: 
239:         // Try to access the item directly; if that fails, try its parent folder (common for child URLs).
240:         let didStartItem = url.startAccessingSecurityScopedResource()
241:         let parentURL = url.deletingLastPathComponent()
242:         let didStartParent = (!didStartItem) ? parentURL.startAccessingSecurityScopedResource() : false
243: 
244:         defer {
245:             if didStartItem { url.stopAccessingSecurityScopedResource() }
246:             if didStartParent { parentURL.stopAccessingSecurityScopedResource() }
247:         }
248: 
249:         do {
250:             try FileManager.default.removeItem(at: url) // works for files and directories
251:             success = true
252:         } catch {
253:             print("Error deleting item at \(url): \(error)")
254:             success = false
255:         }
256: 
257:         DispatchQueue.main.async { self.refreshFileTree() }
258:         return success
259:     }
260: 
261:     // MARK: - Tree
262: 
263:     private func buildFileTree(at url: URL) -> FileTreeNode? {
264:         let fileManager = FileManager.default
265: 
266:         do {
267:             let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .nameKey])
268:             let isDirectory = resourceValues.isDirectory ?? false
269:             let name = resourceValues.name ?? url.lastPathComponent
270: 
271:             if isDirectory {
272:                 let contents = try fileManager.contentsOfDirectory(
273:                     at: url,
274:                     includingPropertiesForKeys: [.isDirectoryKey],
275:                     options: [.skipsHiddenFiles]
276:                 )
277:                 let children = contents.compactMap { buildFileTree(at: $0) }.sorted { $0.name < $1.name }
278:                 return FileTreeNode(url: url, name: name, isDirectory: true, children: children)
279:             } else {
280:                 return FileTreeNode(url: url, name: name, isDirectory: false, children: [])
281:             }
282:         } catch {
283:             print("Error building file tree at \(url): \(error)")
284:             return nil
285:         }
286:     }
287: 
288:     func toggleExpanded(path: String) {
289:         if expandedPaths.contains(path) {
290:             expandedPaths.remove(path)
291:         } else {
292:             expandedPaths.insert(path)
293:         }
294:     }
295: 
296:     // MARK: - Helpers
297: 
298:     private func uniqueDestinationURL(for initial: URL, fileManager: FileManager) -> URL {
299:         if !fileManager.fileExists(atPath: initial.path) { return initial }
300: 
301:         let folder = initial.deletingLastPathComponent()
302:         let isDirectory = (try? initial.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? initial.hasDirectoryPath
303: 
304:         let baseName = initial.deletingPathExtension().lastPathComponent
305:         let ext = initial.pathExtension
306: 
307:         var counter = 1
308:         while true {
309:             let candidateName: String
310:             if ext.isEmpty {
311:                 candidateName = "\(baseName) \(counter)"
312:             } else {
313:                 candidateName = "\(baseName) \(counter).\(ext)"
314:             }
315: 
316:             let candidate = folder.appendingPathComponent(candidateName, isDirectory: isDirectory)
317:             if !fileManager.fileExists(atPath: candidate.path) {
318:                 return candidate
319:             }
320:             counter += 1
321:         }
322:     }
323: }
324: 
325: struct FileTreeNode: Identifiable {
326:     let id = UUID()
327:     let url: URL
328:     let name: String
329:     let isDirectory: Bool
330:     let children: [FileTreeNode]
331: 
332:     var fileExtension: String {
333:         (name as NSString).pathExtension.lowercased()
334:     }
335: }
336: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/SettingsManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models/FileItem.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 1-1345 of 1345)
────────────────────────────────────────
1: import UniformTypeIdentifiers
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
141:         // Create example tabs for all supported languages
142:         let exampleTabs = Self.createExampleTabs()
143:         tabs.append(contentsOf: exampleTabs)
144:         activeTabId = exampleTabs.first?.id ?? UUID()
145:     }
146:     
147:     /// Creates example tabs demonstrating syntax highlighting for all supported languages
148:     private static func createExampleTabs() -> [Tab] {
149:         var examples: [Tab] = []
150:         
151:         // Swift example
152:         examples.append(Tab(
153:             fileName: "Welcome.swift",
154:             content: """
155: // Welcome to VS Code for iPadOS! 🎉
156: //
157: // Features:
158: // • Syntax highlighting for Swift, JS, Python, and more
159: // • Multiple tabs with drag reordering
160: // • File explorer sidebar
161: // • Command palette (⌘+Shift+P)
162: // • Quick open (⌘+P)
163: // • Find & Replace (⌘+F)
164: // • AI Assistant
165: // • Minimap navigation
166: // • Code folding
167: // • Go to line (⌘+G)
168: //
169: // Start editing or open a file!
170: 
171: import SwiftUI
172: 
173: struct ContentView: View {
174:     @State private var counter = 0
175:     
176:     var body: some View {
177:         VStack(spacing: 20) {
178:             Text("Hello, World!")
179:                 .font(.largeTitle)
180:                 .foregroundColor(.blue)
181:             
182:             Button("Count: \\(counter)") {
183:                 counter += 1
184:             }
185:             .buttonStyle(.borderedProminent)
186:         }
187:         .padding()
188:     }
189: }
190: 
191: // MARK: - Preview
192: #Preview {
193:     ContentView()
194: }
195: """,
196:             language: "swift"
197:         ))
198:         
199:         // JavaScript example
200:         examples.append(Tab(
201:             fileName: "example.js",
202:             content: """
203: // JavaScript Example - ES6+ Features
204: 
205: import React, { useState, useEffect } from 'react';
206: 
207: const API_URL = 'https://api.example.com';
208: 
209: // Async function with error handling
210: async function fetchData(endpoint) {
211:     try {
212:         const response = await fetch(`${API_URL}/${endpoint}`);
213:         if (!response.ok) {
214:             throw new Error(`HTTP error! status: ${response.status}`);
215:         }
216:         return await response.json();
217:     } catch (error) {
218:         console.error('Fetch failed:', error);
219:         return null;
220:     }
221: }
222: 
223: // React Component
224: function UserProfile({ userId }) {
225:     const [user, setUser] = useState(null);
226:     const [loading, setLoading] = useState(true);
227:     
228:     useEffect(() => {
229:         fetchData(`users/${userId}`)
230:             .then(data => {
231:                 setUser(data);
232:                 setLoading(false);
233:             });
234:     }, [userId]);
235:     
236:     if (loading) return <div>Loading...</div>;
237:     
238:     return (
239:         <div className="profile">
240:             <h1>{user?.name ?? 'Unknown'}</h1>
241:             <p>Email: {user?.email}</p>
242:         </div>
243:     );
244: }
245: 
246: // Array methods & destructuring
247: const numbers = [1, 2, 3, 4, 5];
248: const doubled = numbers.map(n => n * 2);
249: const [first, second, ...rest] = doubled;
250: 
251: export { fetchData, UserProfile };
252: """,
253:             language: "javascript"
254:         ))
255:         
256:         // Python example
257:         examples.append(Tab(
258:             fileName: "example.py",
259:             content: """
260: #!/usr/bin/env python3
261: \"\"\"
262: Python Example - Modern Python Features
263: Demonstrates type hints, dataclasses, async, and more.
264: \"\"\"
265: 
266: import asyncio
267: from dataclasses import dataclass, field
268: from typing import Optional, List
269: from enum import Enum
270: 
271: class Status(Enum):
272:     PENDING = "pending"
273:     ACTIVE = "active"
274:     COMPLETED = "completed"
275: 
276: @dataclass
277: class Task:
278:     \"\"\"Represents a task with metadata.\"\"\"
279:     id: int
280:     title: str
281:     status: Status = Status.PENDING
282:     tags: List[str] = field(default_factory=list)
283:     description: Optional[str] = None
284:     
285:     def mark_complete(self) -> None:
286:         self.status = Status.COMPLETED
287:         print(f"Task '{self.title}' completed!")
288: 
289: class TaskManager:
290:     def __init__(self):
291:         self._tasks: dict[int, Task] = {}
292:         self._next_id = 1
293:     
294:     def add_task(self, title: str, **kwargs) -> Task:
295:         task = Task(id=self._next_id, title=title, **kwargs)
296:         self._tasks[task.id] = task
297:         self._next_id += 1
298:         return task
299:     
300:     async def process_tasks(self) -> None:
301:         for task in self._tasks.values():
302:             await asyncio.sleep(0.1)  # Simulate work
303:             task.mark_complete()
304: 
305: # Main execution
306: async def main():
307:     manager = TaskManager()
308:     manager.add_task("Learn Python", tags=["programming", "learning"])
309:     manager.add_task("Build app", description="Create VSCode for iPad")
310:     
311:     await manager.process_tasks()
312: 
313: if __name__ == "__main__":
314:     asyncio.run(main())
315: """,
316:             language: "python"
317:         ))
318:         
319:         // JSON example
320:         examples.append(Tab(
321:             fileName: "package.json",
322:             content: """
323: {
324:   "name": "vscode-ipados-example",
325:   "version": "1.0.0",
326:   "description": "Example package.json for VS Code iPadOS",
327:   "main": "index.js",
328:   "scripts": {
329:     "start": "node index.js",
330:     "build": "webpack --mode production",
331:     "test": "jest --coverage",
332:     "lint": "eslint src/**/*.js"
333:   },
334:   "dependencies": {
335:     "react": "^18.2.0",
336:     "react-dom": "^18.2.0",
337:     "axios": "^1.4.0"
338:   },
339:   "devDependencies": {
340:     "webpack": "^5.88.0",
341:     "jest": "^29.5.0",
342:     "eslint": "^8.44.0",
343:     "typescript": "^5.1.6"
344:   },
345:   "keywords": ["vscode", "ipad", "editor"],
346:   "author": "VS Code iPadOS Team",
347:   "license": "MIT",
348:   "repository": {
349:     "type": "git",
350:     "url": "https://github.com/example/vscode-ipados"
351:   },
352:   "engines": {
353:     "node": ">=18.0.0"
354:   }
355: }
356: """,
357:             language: "json"
358:         ))
359:         
360:         // HTML example
361:         examples.append(Tab(
362:             fileName: "index.html",
363:             content: """
364: <!DOCTYPE html>
365: <html lang="en">
366: <head>
367:     <meta charset="UTF-8">
368:     <meta name="viewport" content="width=device-width, initial-scale=1.0">
369:     <title>VS Code for iPadOS</title>
370:     <link rel="stylesheet" href="styles.css">
371:     <script src="app.js" defer></script>
372: </head>
373: <body>
374:     <header class="navbar">
375:         <nav>
376:             <a href="#" class="logo">VS Code iPadOS</a>
377:             <ul class="nav-links">
378:                 <li><a href="#features">Features</a></li>
379:                 <li><a href="#download">Download</a></li>
380:                 <li><a href="#docs">Documentation</a></li>
381:             </ul>
382:         </nav>
383:     </header>
384:     
385:     <main>
386:         <section id="hero" class="hero-section">
387:             <h1>Code Anywhere</h1>
388:             <p>Professional code editor for your iPad</p>
389:             <button id="cta-button" class="btn primary">
390:                 Get Started
391:             </button>
392:         </section>
393:         
394:         <section id="features">
395:             <h2>Features</h2>
396:             <div class="feature-grid">
397:                 <article class="feature-card">
398:                     <h3>Syntax Highlighting</h3>
399:                     <p>Support for 8+ languages with TreeSitter</p>
400:                 </article>
401:                 <!-- More features -->
402:             </div>
403:         </section>
404:     </main>
405:     
406:     <footer>
407:         <p>&copy; 2024 VS Code iPadOS. All rights reserved.</p>
408:     </footer>
409: </body>
410: </html>
411: """,
412:             language: "html"
413:         ))
414:         
415:         // CSS example
416:         examples.append(Tab(
417:             fileName: "styles.css",
418:             content: """
419: /* VS Code iPadOS - Stylesheet */
420: /* Modern CSS with variables, grid, and animations */
421: 
422: :root {
423:     --primary-color: #007acc;
424:     --secondary-color: #3c3c3c;
425:     --background-dark: #1e1e1e;
426:     --text-light: #d4d4d4;
427:     --accent-green: #4ec9b0;
428:     --font-mono: 'SF Mono', Menlo, monospace;
429:     --shadow-lg: 0 10px 40px rgba(0, 0, 0, 0.3);
430: }
431: 
432: * {
433:     margin: 0;
434:     padding: 0;
435:     box-sizing: border-box;
436: }
437: 
438: body {
439:     font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
440:     background-color: var(--background-dark);
441:     color: var(--text-light);
442:     line-height: 1.6;
443: }
444: 
445: .navbar {
446:     position: sticky;
447:     top: 0;
448:     background: rgba(30, 30, 30, 0.95);
449:     backdrop-filter: blur(10px);
450:     padding: 1rem 2rem;
451:     z-index: 1000;
452: }
453: 
454: .hero-section {
455:     min-height: 100vh;
456:     display: grid;
457:     place-items: center;
458:     text-align: center;
459:     background: linear-gradient(135deg, var(--background-dark), #2d2d30);
460: }
461: 
462: .btn.primary {
463:     background: var(--primary-color);
464:     color: white;
465:     padding: 12px 24px;
466:     border: none;
467:     border-radius: 6px;
468:     font-size: 1rem;
469:     cursor: pointer;
470:     transition: transform 0.2s, box-shadow 0.2s;
471: }
472: 
473: .btn.primary:hover {
474:     transform: translateY(-2px);
475:     box-shadow: var(--shadow-lg);
476: }
477: 
478: .feature-grid {
479:     display: grid;
480:     grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
481:     gap: 2rem;
482:     padding: 2rem;
483: }
484: 
485: @keyframes fadeIn {
486:     from { opacity: 0; transform: translateY(20px); }
487:     to { opacity: 1; transform: translateY(0); }
488: }
489: 
490: .feature-card {
491:     animation: fadeIn 0.5s ease-out forwards;
492: }
493: 
494: @media (max-width: 768px) {
495:     .nav-links { display: none; }
496:     .hero-section { padding: 2rem; }
497: }
498: """,
499:             language: "css"
500:         ))
501:         
502:         // Go example
503:         examples.append(Tab(
504:             fileName: "main.go",
505:             content: """
506: // Go Example - HTTP Server with Goroutines
507: package main
508: 
509: import (
510: \t"context"
511: \t"encoding/json"
512: \t"fmt"
513: \t"log"
514: \t"net/http"
515: \t"sync"
516: \t"time"
517: )
518: 
519: // User represents a user in the system
520: type User struct {
521: \tID        int       `json:"id"`
522: \tName      string    `json:"name"`
523: \tEmail     string    `json:"email"`
524: \tCreatedAt time.Time `json:"created_at"`
525: }
526: 
527: // UserStore handles user data with thread-safe access
528: type UserStore struct {
529: \tmu    sync.RWMutex
530: \tusers map[int]*User
531: \tnextID int
532: }
533: 
534: func NewUserStore() *UserStore {
535: \treturn &UserStore{
536: \t\tusers:  make(map[int]*User),
537: \t\tnextID: 1,
538: \t}
539: }
540: 
541: func (s *UserStore) Create(name, email string) *User {
542: \ts.mu.Lock()
543: \tdefer s.mu.Unlock()
544: \t
545: \tuser := &User{
546: \t\tID:        s.nextID,
547: \t\tName:      name,
548: \t\tEmail:     email,
549: \t\tCreatedAt: time.Now(),
550: \t}
551: \ts.users[user.ID] = user
552: \ts.nextID++
553: \treturn user
554: }
555: 
556: func (s *UserStore) Get(id int) (*User, bool) {
557: \ts.mu.RLock()
558: \tdefer s.mu.RUnlock()
559: \tuser, ok := s.users[id]
560: \treturn user, ok
561: }
562: 
563: func handleUsers(store *UserStore) http.HandlerFunc {
564: \treturn func(w http.ResponseWriter, r *http.Request) {
565: \t\tswitch r.Method {
566: \t\tcase http.MethodGet:
567: \t\t\t// Return all users
568: \t\t\tw.Header().Set("Content-Type", "application/json")
569: \t\t\tjson.NewEncoder(w).Encode(store.users)
570: \t\tcase http.MethodPost:
571: \t\t\t// Create new user
572: \t\t\tvar req struct {
573: \t\t\t\tName  string `json:"name"`
574: \t\t\t\tEmail string `json:"email"`
575: \t\t\t}
576: \t\t\tif err := json.NewDecoder(r.Body).Decode(&req); err != nil {
577: \t\t\t\thttp.Error(w, err.Error(), http.StatusBadRequest)
578: \t\t\t\treturn
579: \t\t\t}
580: \t\t\tuser := store.Create(req.Name, req.Email)
581: \t\t\tw.WriteHeader(http.StatusCreated)
582: \t\t\tjson.NewEncoder(w).Encode(user)
583: \t\tdefault:
584: \t\t\thttp.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
585: \t\t}
586: \t}
587: }
588: 
589: func main() {
590: \tstore := NewUserStore()
591: \t
592: \t// Seed some data
593: \tstore.Create("Alice", "alice@example.com")
594: \tstore.Create("Bob", "bob@example.com")
595: \t
596: \tmux := http.NewServeMux()
597: \tmux.HandleFunc("/api/users", handleUsers(store))
598: \t
599: \tserver := &http.Server{
600: \t\tAddr:         ":8080",
601: \t\tHandler:      mux,
602: \t\tReadTimeout:  10 * time.Second,
603: \t\tWriteTimeout: 10 * time.Second,
604: \t}
605: \t
606: \tfmt.Println("Server starting on :8080")
607: \tlog.Fatal(server.ListenAndServe())
608: }
609: """,
610:             language: "go"
611:         ))
612:         
613:         // Rust example
614:         examples.append(Tab(
615:             fileName: "main.rs",
616:             content: """
617: //! Rust Example - Async Web Server
618: //! Demonstrates ownership, traits, async/await, and error handling
619: 
620: use std::collections::HashMap;
621: use std::sync::Arc;
622: use tokio::sync::RwLock;
623: 
624: /// Represents a task in our system
625: #[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
626: pub struct Task {
627:     pub id: u64,
628:     pub title: String,
629:     pub completed: bool,
630:     #[serde(skip_serializing_if = "Option::is_none")]
631:     pub description: Option<String>,
632: }
633: 
634: /// Task store with thread-safe access
635: pub struct TaskStore {
636:     tasks: RwLock<HashMap<u64, Task>>,
637:     next_id: RwLock<u64>,
638: }
639: 
640: impl TaskStore {
641:     pub fn new() -> Self {
642:         Self {
643:             tasks: RwLock::new(HashMap::new()),
644:             next_id: RwLock::new(1),
645:         }
646:     }
647:     
648:     pub async fn create(&self, title: String, description: Option<String>) -> Task {
649:         let mut next_id = self.next_id.write().await;
650:         let id = *next_id;
651:         *next_id += 1;
652:         
653:         let task = Task {
654:             id,
655:             title,
656:             completed: false,
657:             description,
658:         };
659:         
660:         self.tasks.write().await.insert(id, task.clone());
661:         task
662:     }
663:     
664:     pub async fn get(&self, id: u64) -> Option<Task> {
665:         self.tasks.read().await.get(&id).cloned()
666:     }
667:     
668:     pub async fn list(&self) -> Vec<Task> {
669:         self.tasks.read().await.values().cloned().collect()
670:     }
671:     
672:     pub async fn complete(&self, id: u64) -> Result<Task, &'static str> {
673:         let mut tasks = self.tasks.write().await;
674:         match tasks.get_mut(&id) {
675:             Some(task) => {
676:                 task.completed = true;
677:                 Ok(task.clone())
678:             }
679:             None => Err("Task not found"),
680:         }
681:     }
682: }
683: 
684: /// Error type for our application
685: #[derive(Debug, thiserror::Error)]
686: pub enum AppError {
687:     #[error("Task not found: {0}")]
688:     NotFound(u64),
689:     #[error("Invalid input: {0}")]
690:     InvalidInput(String),
691: }
692: 
693: #[tokio::main]
694: async fn main() -> Result<(), Box<dyn std::error::Error>> {
695:     let store = Arc::new(TaskStore::new());
696:     
697:     // Create some tasks
698:     let task1 = store.create("Learn Rust".into(), Some("Study ownership".into())).await;
699:     let task2 = store.create("Build app".into(), None).await;
700:     
701:     println!("Created tasks:");
702:     for task in store.list().await {
703:         println!("  - {} ({})", task.title, if task.completed { "✓" } else { "○" });
704:     }
705:     
706:     // Complete a task
707:     store.complete(task1.id).await?;
708:     println!("\\nCompleted task: {}", task1.title);
709:     
710:     Ok(())
711: }
712: 
713: #[cfg(test)]
714: mod tests {
715:     use super::*;
716:     
717:     #[tokio::test]
718:     async fn test_create_task() {
719:         let store = TaskStore::new();
720:         let task = store.create("Test".into(), None).await;
721:         assert_eq!(task.title, "Test");
722:         assert!(!task.completed);
723:     }
724: }
725: """,
726:             language: "rust"
727:         ))
728:         
729:         return examples
730:     }
731: 
732:     // MARK: - Tab Management
733: 
734:     func addTab(fileName: String = "Untitled.swift", content: String = "", url: URL? = nil) {
735:         // Check if file is already open
736:         if let url = url, let existingTab = tabs.first(where: { $0.url == url }) {
737:             activeTabId = existingTab.id
738:             return
739:         }
740: 
741:         let newTab = Tab(fileName: fileName, content: content, url: url)
742:         tabs.append(newTab)
743:         activeTabId = newTab.id
744:     }
745: 
746:     func closeTab(id: UUID) {
747:         guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
748: 
749:         // Release security-scoped access if this tab was holding it.
750:         if let url = tabs[index].url {
751:             releaseSecurityScopedAccess(to: url)
752:         }
753: 
754:         tabs.remove(at: index)
755: 
756:         // Update active tab if we closed the active one
757:         if activeTabId == id {
758:             if tabs.isEmpty {
759:                 activeTabId = nil
760:             } else if index >= tabs.count {
761:                 activeTabId = tabs[tabs.count - 1].id
762:             } else {
763:                 activeTabId = tabs[index].id
764:             }
765:         }
766:     }
767: 
768:     func closeAllTabs() {
769:         // Release security-scoped access held by any open tabs.
770:         for tab in tabs {
771:             if let url = tab.url {
772:                 releaseSecurityScopedAccess(to: url)
773:             }
774:         }
775: 
776:         tabs.removeAll()
777:         activeTabId = nil
778:     }
779: 
780:     func closeOtherTabs(except id: UUID) {
781:         // Release security-scoped access for tabs being closed.
782:         for tab in tabs where tab.id != id {
783:             if let url = tab.url {
784:                 releaseSecurityScopedAccess(to: url)
785:             }
786:         }
787: 
788:         tabs.removeAll { $0.id != id }
789:         activeTabId = id
790:     }
791: 
792:     func selectTab(id: UUID) {
793:         activeTabId = id
794:     }
795: 
796:     func nextTab() {
797:         guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
798:         let nextIndex = (currentIndex + 1) % tabs.count
799:         activeTabId = tabs[nextIndex].id
800:     }
801: 
802:     func previousTab() {
803:         guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
804:         let prevIndex = currentIndex == 0 ? tabs.count - 1 : currentIndex - 1
805:         activeTabId = tabs[prevIndex].id
806:     }
807: 
808:     func moveTab(from source: IndexSet, to destination: Int) {
809:         tabs.move(fromOffsets: source, toOffset: destination)
810:     }
811: 
812:     // MARK: - Content Management
813: 
814:     func updateActiveTabContent(_ content: String) {
815:         guard let index = activeTabIndex else { return }
816: 
817:         // Avoid marking a tab dirty when we're just syncing state (e.g., initial onAppear assignment).
818:         guard tabs[index].content != content else { return }
819: 
820:         tabs[index].content = content
821: 
822:         // Mark dirty for both saved and unsaved-new files.
823:         tabs[index].isUnsaved = true
824:     }
825: 
826:     func saveActiveTab() {
827:         guard let index = activeTabIndex,
828:               let url = tabs[index].url else { return }
829: 
830:         do {
831:             if let fileNavigator {
832:                 try fileNavigator.writeFile(at: url, content: tabs[index].content)
833:             } else {
834:                 // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
835:                 let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
836:                 defer { if didStart { url.stopAccessingSecurityScopedResource() } }
837:                 try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
838:             }
839: 
840:             tabs[index].isUnsaved = false
841:         } catch {
842:             print("Error saving file: \(error)")
843:         }
844:     }
845: 
846:     func saveAllTabs() {
847:         for index in tabs.indices {
848:             guard let url = tabs[index].url, tabs[index].isUnsaved else { continue }
849: 
850:             do {
851:                 if let fileNavigator {
852:                     try fileNavigator.writeFile(at: url, content: tabs[index].content)
853:                 } else {
854:                     // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
855:                     let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
856:                     defer { if didStart { url.stopAccessingSecurityScopedResource() } }
857:                     try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
858:                 }
859: 
860:                 tabs[index].isUnsaved = false
861:             } catch {
862:                 print("Error saving file: \(error)")
863:             }
864:         }
865:     }
866: 
867:     // MARK: - File Operations
868: 
869:     /// Retain security scoped access for as long as a tab referencing the URL is open.
870:     /// - Returns: `true` if access was retained (either already retained or started successfully).
871:     @discardableResult
872:     private func retainSecurityScopedAccess(to url: URL) -> Bool {
873:         if let count = securityScopedAccessCounts[url] {
874:             securityScopedAccessCounts[url] = count + 1
875:             return true
876:         }
877: 
878:         let started = url.startAccessingSecurityScopedResource()
879:         if started {
880:             securityScopedAccessCounts[url] = 1
881:             return true
882:         }
883: 
884:         // Not all URLs are security-scoped; startAccessing may legitimately return false.
885:         return false
886:     }
887: 
888:     private func releaseSecurityScopedAccess(to url: URL) {
889:         guard let count = securityScopedAccessCounts[url] else { return }
890:         if count <= 1 {
891:             securityScopedAccessCounts.removeValue(forKey: url)
892:             url.stopAccessingSecurityScopedResource()
893:         } else {
894:             securityScopedAccessCounts[url] = count - 1
895:         }
896:     }
897: 
898:     func openFile(from url: URL) {
899:         // If already open, just activate it (and avoid re-reading / re-requesting access).
900:         if let existingTab = tabs.first(where: { $0.url == url }) {
901:             activeTabId = existingTab.id
902:             return
903:         }
904: 
905:         // IMPORTANT (BUG-005):
906:         // Do not early-return if startAccessingSecurityScopedResource() fails.
907:         // For many URLs (non-security-scoped, or when parent scope is active), this may return false,
908:         // but the file is still readable. We retain access if available.
909:         let retained = retainSecurityScopedAccess(to: url)
910: 
911:         do {
912:             let content = try String(contentsOf: url, encoding: .utf8)
913:             addTab(fileName: url.lastPathComponent, content: content, url: url)
914: 
915:             // Index the file in Spotlight for search
916:             SpotlightManager.shared.indexFile(url: url, content: content, fileName: url.lastPathComponent)
917:         } catch {
918:             print("Error opening file: \(error)")
919:             if retained {
920:                 // We retained access but failed to open; release our retain.
921:                 releaseSecurityScopedAccess(to: url)
922:             }
923:         }
924:     }
925: 
926:     func openFile(_ fileItem: FileItem) {
927:         guard let url = fileItem.url else {
928:             // Try path
929:             if !fileItem.path.isEmpty {
930:                 let fileURL = URL(fileURLWithPath: fileItem.path)
931:                 openFile(from: fileURL)
932:             }
933:             return
934:         }
935:         openFile(from: url)
936:     }
937: 
938:     // MARK: - File System Event Handlers
939: 
940:     /// Called when a file or folder is moved/renamed in the file system.
941:     /// Updates any open tabs that reference the old URL.
942:     func handleFileSystemItemMoved(from oldURL: URL, to newURL: URL) {
943:         for index in tabs.indices {
944:             guard let tabURL = tabs[index].url else { continue }
945: 
946:             // Check if tab URL matches the moved item or is inside it (for folders)
947:             let oldPath = oldURL.standardizedFileURL.path
948:             let tabPath = tabURL.standardizedFileURL.path
949: 
950:             if tabPath == oldPath {
951:                 // Direct match - update URL
952:                 tabs[index].url = newURL
953:                 tabs[index].fileName = newURL.lastPathComponent
954:             } else if tabPath.hasPrefix(oldPath + "/") {
955:                 // Tab is inside a moved folder - update the path prefix
956:                 let relativePath = String(tabPath.dropFirst(oldPath.count))
957:                 let newTabURL = URL(fileURLWithPath: newURL.path + relativePath)
958:                 tabs[index].url = newTabURL
959:             }
960:         }
961:     }
962: 
963:     /// Called when a file or folder is deleted from the file system.
964:     /// Closes any open tabs that reference the deleted item.
965:     func handleFileSystemItemDeleted(at url: URL) {
966:         let deletedPath = url.standardizedFileURL.path
967: 
968:         // Find all tabs that should be closed
969:         let tabsToClose = tabs.filter { tab in
970:             guard let tabURL = tab.url else { return false }
971:             let tabPath = tabURL.standardizedFileURL.path
972:             // Close if exact match or if tab is inside deleted folder
973:             return tabPath == deletedPath || tabPath.hasPrefix(deletedPath + "/")
974:         }
975: 
976:         // Close the tabs (release security access)
977:         for tab in tabsToClose {
978:             closeTab(id: tab.id)
979:         }
980:     }
981: 
982:     // MARK: - UI Toggles
983: 
984:     func toggleSidebar() {
985:         withAnimation(.spring(response: 0.3)) {
986:             showSidebar.toggle()
987:         }
988:     }
989: 
990:     func toggleCommandPalette() {
991:         showCommandPalette.toggle()
992:     }
993: 
994:     func toggleQuickOpen() {
995:         showQuickOpen.toggle()
996:     }
997: 
998:     func toggleSearch() {
999:         showSearch.toggle()
1000:     }
1001: 
1002:     func toggleAIAssistant() {
1003:         showAIAssistant.toggle()
1004:     }
1005: 
1006:     func toggleGoToSymbol() {
1007:         showGoToSymbol.toggle()
1008:     }
1009: 
1010:     func toggleZenMode() {
1011:         isZenMode.toggle()
1012:     }
1013: 
1014:     func toggleFocusMode() {
1015:         isFocusMode.toggle()
1016:     }
1017: 
1018:     func togglePanel() {
1019:         withAnimation(.spring(response: 0.3)) {
1020:             showPanel.toggle()
1021:         }
1022:     }
1023: 
1024:     func addSelectionToNextFindMatch() {
1025:         addNextOccurrence()
1026:     }
1027: 
1028:     func zoomIn() {
1029:         editorFontSize = min(editorFontSize + 2, 32)
1030:     }
1031: 
1032:     func zoomOut() {
1033:         editorFontSize = max(editorFontSize - 2, 8)
1034:     }
1035: 
1036:     func resetZoom() {
1037:         editorFontSize = 14.0
1038:     }
1039: 
1040:     func focusExplorer() {
1041:         focusedView = .explorer
1042:         focusedSidebarTab = 0
1043:         withAnimation {
1044:             showSidebar = true
1045:         }
1046:     }
1047: 
1048:     func focusGit() {
1049:         focusedView = .git
1050:         focusedSidebarTab = 1
1051:         withAnimation {
1052:             showSidebar = true
1053:         }
1054:     }
1055: 
1056:     func renameSymbol() {
1057:         showRenameSymbol.toggle()
1058:     }
1059: 
1060:     // NOTE:
1061:     // goToDefinitionAtCursor(), peekDefinitionAtCursor(), navigateBack(), and navigateForward()
1062:     // are implemented in an EditorCore extension in Services/NavigationManager.swift.
1063: 
1064:     // MARK: - Peek Definition
1065: 
1066:     func triggerPeekDefinition(file: String, line: Int, content: String, sourceLine: Int) {
1067:         peekState = PeekState(file: file, line: line, content: content, sourceLine: sourceLine)
1068:     }
1069: 
1070:     func closePeekDefinition() {
1071:         peekState = nil
1072:     }
1073: 
1074:     // MARK: - Multi-Cursor Operations
1075: 
1076:     /// Add cursor at a specific position (Option+Click)
1077:     func addCursorAtPosition(_ position: Int) {
1078:         multiCursorState.addCursor(at: position)
1079:     }
1080: 
1081:     /// Add cursor on the line above (Cmd+Option+Up)
1082:     func addCursorAbove() {
1083:         guard let index = activeTabIndex else { return }
1084:         let content = tabs[index].content
1085:         
1086:         guard let primary = multiCursorState.primaryCursor else { return }
1087:         
1088:         // Find current line and column
1089:         let lines = content.components(separatedBy: "\n")
1090:         var currentLine = 0
1091:         var charCount = 0
1092:         var columnInLine = 0
1093:         
1094:         for (lineIndex, line) in lines.enumerated() {
1095:             let lineLength = line.count + 1 // +1 for newline
1096:             if charCount + lineLength > primary.position {
1097:                 currentLine = lineIndex
1098:                 columnInLine = primary.position - charCount
1099:                 break
1100:             }
1101:             charCount += lineLength
1102:         }
1103:         
1104:         // Can't add cursor above line 0
1105:         guard currentLine > 0 else { return }
1106:         
1107:         // Calculate position on line above
1108:         let targetLine = currentLine - 1
1109:         var targetPosition = 0
1110:         for i in 0..<targetLine {
1111:             targetPosition += lines[i].count + 1
1112:         }
1113:         targetPosition += min(columnInLine, lines[targetLine].count)
1114:         
1115:         multiCursorState.addCursor(at: targetPosition)
1116:     }
1117: 
1118:     /// Add cursor on the line below (Cmd+Option+Down)
1119:     func addCursorBelow() {
1120:         guard let index = activeTabIndex else { return }
1121:         let content = tabs[index].content
1122:         
1123:         guard let primary = multiCursorState.primaryCursor else { return }
1124:         
1125:         // Find current line and column
1126:         let lines = content.components(separatedBy: "\n")
1127:         var currentLine = 0
1128:         var charCount = 0
1129:         var columnInLine = 0
1130:         
1131:         for (lineIndex, line) in lines.enumerated() {
1132:             let lineLength = line.count + 1 // +1 for newline
1133:             if charCount + lineLength > primary.position {
1134:                 currentLine = lineIndex
1135:                 columnInLine = primary.position - charCount
1136:                 break
1137:             }
1138:             charCount += lineLength
1139:         }
1140:         
1141:         // Can't add cursor below last line
1142:         guard currentLine < lines.count - 1 else { return }
1143:         
1144:         // Calculate position on line below
1145:         let targetLine = currentLine + 1
1146:         var targetPosition = 0
1147:         for i in 0..<targetLine {
1148:             targetPosition += lines[i].count + 1
1149:         }
1150:         targetPosition += min(columnInLine, lines[targetLine].count)
1151:         
1152:         multiCursorState.addCursor(at: targetPosition)
1153:     }
1154: 
1155:     /// Add next occurrence of current selection (Cmd+D)
1156:     func addNextOccurrence() {
1157:         guard let index = activeTabIndex else { return }
1158:         let content = tabs[index].content
1159: 
1160:         // Get the word/selection to search for
1161:         let searchText: String
1162:         let startPosition: Int
1163: 
1164:         if let range = currentSelectionRange, range.length > 0,
1165:            let swiftRange = Range(range, in: content) {
1166:             searchText = String(content[swiftRange])
1167:             startPosition = range.location + range.length
1168:         } else if let primary = multiCursorState.primaryCursor {
1169:             // No selection - select the word under cursor
1170:             let wordRange = findWordAtPosition(primary.position, in: content)
1171:             if let range = wordRange, range.length > 0,
1172:                let swiftRange = Range(range, in: content) {
1173:                 searchText = String(content[swiftRange])
1174:                 startPosition = range.location + range.length
1175: 
1176:                 // First Cmd+D selects the word under cursor
1177:                 multiCursorState.cursors = [Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)]
1178:                 currentSelectionRange = range
1179:                 currentSelection = searchText
1180:                 return
1181:             } else {
1182:                 return
1183:             }
1184:         } else {
1185:             return
1186:         }
1187: 
1188:         // Find next occurrence
1189:         if let nextRange = content.findNextOccurrence(of: searchText, after: startPosition) {
1190:             // Check if this occurrence is already selected
1191:             let alreadySelected = multiCursorState.cursors.contains { cursor in
1192:                 if let selRange = cursor.selectionRange {
1193:                     return selRange.location == nextRange.location
1194:                 }
1195:                 return false
1196:             }
1197: 
1198:             if !alreadySelected {
1199:                 multiCursorState.addCursorWithSelection(
1200:                     position: nextRange.location + nextRange.length,
1201:                     anchor: nextRange.location
1202:                 )
1203:             }
1204:         }
1205:     }
1206: 
1207:     /// Select all occurrences of current selection (Cmd+Shift+L)
1208:     func selectAllOccurrences() {
1209:         guard let index = activeTabIndex else { return }
1210:         let content = tabs[index].content
1211: 
1212:         // Get the word/selection to search for
1213:         let searchText: String
1214: 
1215:         if let range = currentSelectionRange, range.length > 0,
1216:            let swiftRange = Range(range, in: content) {
1217:             searchText = String(content[swiftRange])
1218:         } else if let primary = multiCursorState.primaryCursor {
1219:             // No selection - use word under cursor
1220:             let wordRange = findWordAtPosition(primary.position, in: content)
1221:             if let range = wordRange, range.length > 0,
1222:                let swiftRange = Range(range, in: content) {
1223:                 searchText = String(content[swiftRange])
1224:             } else {
1225:                 return
1226:             }
1227:         } else {
1228:             return
1229:         }
1230: 
1231:         // Find all occurrences
1232:         let allRanges = content.findAllOccurrences(of: searchText)
1233: 
1234:         guard !allRanges.isEmpty else { return }
1235: 
1236:         // Create cursors for all occurrences
1237:         multiCursorState.cursors = allRanges.enumerated().map { index, range in
1238:             Cursor(
1239:                 position: range.location + range.length,
1240:                 anchor: range.location,
1241:                 isPrimary: index == 0
1242:             )
1243:         }
1244: 
1245:         currentSelection = searchText
1246:     }
1247: 
1248:     /// Reset to single cursor
1249:     func resetToSingleCursor(at position: Int) {
1250:         multiCursorState.reset(to: position)
1251:         currentSelectionRange = nil
1252:         currentSelection = ""
1253:     }
1254: 
1255:     /// Update selection from text view
1256:     func updateSelection(range: NSRange?, text: String) {
1257:         currentSelectionRange = range
1258:         if let range = range, range.length > 0,
1259:            let index = activeTabIndex {
1260:             let content = tabs[index].content
1261:             if let swiftRange = Range(range, in: content) {
1262:                 currentSelection = String(content[swiftRange])
1263:             }
1264:         } else {
1265:             currentSelection = ""
1266:         }
1267:     }
1268: 
1269:     /// Find word boundaries at a given position
1270:     func findWordAtPosition(_ position: Int, in text: String) -> NSRange? {
1271:         guard position >= 0 && position <= text.count else { return nil }
1272: 
1273:         let nsText = text as NSString
1274:         let wordCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
1275: 
1276:         // Find start of word
1277:         var start = position
1278:         while start > 0 {
1279:             let char = nsText.substring(with: NSRange(location: start - 1, length: 1))
1280:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
1281:                 start -= 1
1282:             } else {
1283:                 break
1284:             }
1285:         }
1286: 
1287:         // Find end of word
1288:         var end = position
1289:         while end < nsText.length {
1290:             let char = nsText.substring(with: NSRange(location: end, length: 1))
1291:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
1292:                 end += 1
1293:             } else {
1294:                 break
1295:             }
1296:         }
1297: 
1298:         if start == end {
1299:             return nil
1300:         }
1301: 
1302:         return NSRange(location: start, length: end - start)
1303:     }
1304: 
1305:     /// Escape multi-cursor mode
1306:     func escapeMultiCursor() {
1307:         if multiCursorState.isMultiCursor {
1308:             if let primary = multiCursorState.primaryCursor {
1309:                 resetToSingleCursor(at: primary.position)
1310:             }
1311:         }
1312:     }
1313: 
1314:     // MARK: - Code Folding
1315: 
1316:     /// Collapse all foldable regions in the active editor
1317:     func collapseAllFolds() {
1318:         guard let index = activeTabIndex else { return }
1319:         // Post notification that will be picked up by the editor view
1320:         NotificationCenter.default.post(
1321:             name: .collapseAllFolds,
1322:             object: nil,
1323:             userInfo: ["tabId": tabs[index].id]
1324:         )
1325:     }
1326: 
1327:     /// Expand all collapsed regions in the active editor
1328:     func expandAllFolds() {
1329:         guard let index = activeTabIndex else { return }
1330:         // Post notification that will be picked up by the editor view
1331:         NotificationCenter.default.post(
1332:             name: .expandAllFolds,
1333:             object: nil,
1334:             userInfo: ["tabId": tabs[index].id]
1335:         )
1336:     }
1337: }
1338: 
1339: // MARK: - Notification Names for Code Folding
1340: 
1341: extension Notification.Name {
1342:     static let collapseAllFolds = Notification.Name("collapseAllFolds")
1343:     static let expandAllFolds = Notification.Name("expandAllFolds")
1344: }
1345: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/SettingsManager.swift (lines 1-99 of 99)
────────────────────────────────────────
1: import Foundation
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
81:         }
82: 
83:         for name in candidates {
84:             if let font = UIFont(name: name, size: size) {
85:                 // Ensure monospaced feel if available; otherwise return as-is.
86:                 return font
87:             }
88:         }
89: 
90:         // Fallback
91:         return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
92:     }
93: 
94:     /// A stable key used to detect when re-highlighting is necessary.
95:     var editorStyleKey: String {
96:         "\(fontFamily)|\(Int(fontSize))|\(clampedTabSize)"
97:     }
98: }
99: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/FileItem.swift (lines 1-83 of 83)
────────────────────────────────────────
1: import Foundation
2: import SwiftUI
3: 
4: /// Represents a file or directory in the file system
5: struct FileItem: Identifiable, Hashable {
6:     let id: UUID
7:     var name: String
8:     var url: URL?
9:     var path: String
10:     var isDirectory: Bool
11:     var children: [FileItem]?
12:     var isExpanded: Bool
13:     
14:     init(
15:         id: UUID = UUID(),
16:         name: String,
17:         url: URL? = nil,
18:         path: String = "",
19:         isDirectory: Bool = false,
20:         children: [FileItem]? = nil,
21:         isExpanded: Bool = false
22:     ) {
23:         self.id = id
24:         self.name = name
25:         self.url = url
26:         self.path = path.isEmpty ? (url?.path ?? "") : path
27:         self.isDirectory = isDirectory
28:         self.children = children
29:         self.isExpanded = isExpanded
30:     }
31:     
32:     var fileExtension: String {
33:         (name as NSString).pathExtension.lowercased()
34:     }
35:     
36:     var icon: String {
37:         FileItem.getFileIcon(for: name, isDirectory: isDirectory, isExpanded: isExpanded)
38:     }
39:     
40:     var iconColor: Color {
41:         FileItem.getFileColor(for: name, isDirectory: isDirectory)
42:     }
43:     
44:     // MARK: - File Icon Helpers (inline to avoid dependency issues)
45:     
46:     static func getFileIcon(for filename: String, isDirectory: Bool = false, isExpanded: Bool = false) -> String {
47:         if isDirectory {
48:             return isExpanded ? "folder.fill.badge.minus" : "folder.fill"
49:         }
50:         
51:         let ext = (filename as NSString).pathExtension.lowercased()
52:         switch ext {
53:         case "swift": return "swift"
54:         case "js", "jsx", "ts", "tsx": return "curlybraces"
55:         case "py": return "chevron.left.forwardslash.chevron.right"
56:         case "html", "htm": return "globe"
57:         case "css", "scss": return "paintbrush.fill"
58:         case "json": return "curlybraces.square"
59:         case "md", "markdown": return "doc.richtext"
60:         default: return "doc.text"
61:         }
62:     }
63:     
64:     static func getFileColor(for filename: String, isDirectory: Bool = false) -> Color {
65:         if isDirectory {
66:             return .yellow
67:         }
68:         
69:         let ext = (filename as NSString).pathExtension.lowercased()
70:         switch ext {
71:         case "swift": return .orange
72:         case "js", "jsx": return .yellow
73:         case "ts", "tsx": return .blue
74:         case "py": return .green
75:         case "html", "htm": return .red
76:         case "css", "scss": return .purple
77:         case "json": return .green
78:         case "md", "markdown": return .blue
79:         default: return .gray
80:         }
81:     }
82: }
83: 


Let me examine a few more key service files and views to complete my understanding:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/NavigationManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift", "start_line": 1, "end_line": 100}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/SearchManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/NavigationManager.swift (lines 1-906 of 906)
────────────────────────────────────────
1: //  NavigationManager.swift
2: //  VSCodeiPadOS
3: //
4: //  Go to Definition support with Cmd+Click and F12
5: //  FEAT-134: Symbol table tracking and navigation
6: //
7: 
8: import Foundation
9: import SwiftUI
10: #if canImport(UIKit)
11: import UIKit
12: #endif
13: 
14: // MARK: - Symbol Location Model
15: 
16: /// Represents a location in a source file
17: struct SymbolLocation: Identifiable, Equatable, Hashable {
18:     let id = UUID()
19:     let file: String           // File path or identifier
20:     let fileName: String       // Display name
21:     let line: Int              // 1-based line number
22:     let column: Int            // 1-based column number
23:     let endLine: Int?          // Optional end line for range
24:     let endColumn: Int?        // Optional end column for range
25: 
26:     init(file: String, line: Int, column: Int = 1, endLine: Int? = nil, endColumn: Int? = nil) {
27:         self.file = file
28:         self.fileName = (file as NSString).lastPathComponent
29:         self.line = line
30:         self.column = column
31:         self.endLine = endLine
32:         self.endColumn = endColumn
33:     }
34: 
35:     var displayString: String {
36:         "\(fileName):\(line):\(column)"
37:     }
38: }
39: 
40: // MARK: - Symbol Definition Model
41: 
42: /// Represents a symbol definition with its location and metadata
43: struct SymbolDefinition: Identifiable, Equatable {
44:     let id = UUID()
45:     let name: String                  // Symbol name
46:     let kind: SymbolKind              // Type of symbol
47:     let location: SymbolLocation      // Where it's defined
48:     let signature: String?            // Optional function signature or type info
49:     let documentation: String?        // Optional doc comment
50:     let containerName: String?        // Parent class/struct/module
51: 
52:     static func == (lhs: SymbolDefinition, rhs: SymbolDefinition) -> Bool {
53:         lhs.name == rhs.name && lhs.location == rhs.location
54:     }
55: }
56: 
57: // MARK: - Symbol Kind
58: 
59: enum SymbolKind: String, CaseIterable {
60:     case function = "function"
61:     case method = "method"
62:     case property = "property"
63:     case variable = "variable"
64:     case constant = "constant"
65:     case `class` = "class"
66:     case `struct` = "struct"
67:     case `enum` = "enum"
68:     case enumCase = "enumCase"
69:     case `protocol` = "protocol"
70:     case interface = "interface"
71:     case type = "type"
72:     case namespace = "namespace"
73:     case module = "module"
74:     case field = "field"
75:     case constructor = "constructor"
76:     case parameter = "parameter"
77:     case typeParameter = "typeParameter"
78:     case unknown = "unknown"
79: 
80:     var icon: String {
81:         switch self {
82:         case .function, .method: return "f.square"
83:         case .property, .field: return "p.square"
84:         case .variable: return "v.square"
85:         case .constant: return "c.square"
86:         case .class: return "c.square.fill"
87:         case .struct: return "s.square.fill"
88:         case .enum, .enumCase: return "e.square.fill"
89:         case .protocol, .interface: return "i.square"
90:         case .type, .typeParameter: return "t.square"
91:         case .namespace, .module: return "n.square"
92:         case .constructor: return "hammer"
93:         case .parameter: return "p.circle"
94:         case .unknown: return "questionmark.square"
95:         }
96:     }
97: 
98:     var color: Color {
99:         switch self {
100:         case .function, .method: return .purple
101:         case .property, .field: return .blue
102:         case .variable: return .cyan
103:         case .constant: return .orange
104:         case .class: return .yellow
105:         case .struct: return .green
106:         case .enum, .enumCase: return .mint
107:         case .protocol, .interface: return .pink
108:         case .type, .typeParameter: return .indigo
109:         case .namespace, .module: return .brown
110:         case .constructor: return .red
111:         case .parameter: return .teal
112:         case .unknown: return .gray
113:         }
114:     }
115: }
116: 
117: // MARK: - Navigation Result
118: 
119: enum NavigationResult {
120:     case found(SymbolLocation)
121:     case multipleFound([SymbolDefinition])
122:     case notFound(reason: String)
123: }
124: 
125: // MARK: - Navigation Manager
126: 
127: /// Manages symbol tracking and Go to Definition functionality
128: @MainActor
129: final class NavigationManager: ObservableObject {
130:     static let shared = NavigationManager()
131: 
132:     // MARK: - Published State
133: 
134:     @Published var isNavigating = false
135:     @Published var lastNavigationError: String?
136:     @Published var definitionPreview: SymbolDefinition?
137:     @Published var showDefinitionPicker = false
138:     @Published var multipleDefinitions: [SymbolDefinition] = []
139: 
140:     // MARK: - Symbol Table
141: 
142:     /// Symbol table: maps symbol names to their definitions
143:     /// Key: symbol name, Value: array of definitions (can have multiple for overloads)
144:     private var symbolTable: [String: [SymbolDefinition]] = [:]
145: 
146:     /// File index: maps file paths to their symbols for quick lookup
147:     private var fileSymbols: [String: [SymbolDefinition]] = [:]
148: 
149:     /// Cache of parsed file contents (hash -> symbols)
150:     private var parseCache: [Int: [SymbolDefinition]] = [:]
151: 
152:     // MARK: - Navigation History
153: 
154:     private var navigationHistory: [SymbolLocation] = []
155:     private var historyIndex: Int = -1
156:     private let maxHistorySize = 50
157: 
158:     // MARK: - Initialization
159: 
160:     private init() {}
161: 
162:     // MARK: - Symbol Table Management
163: 
164:     /// Register a symbol definition in the symbol table
165:     func registerSymbol(_ definition: SymbolDefinition) {
166:         // Add to symbol table
167:         if symbolTable[definition.name] == nil {
168:             symbolTable[definition.name] = []
169:         }
170: 
171:         // Avoid duplicates
172:         if !symbolTable[definition.name]!.contains(where: { $0.location == definition.location }) {
173:             symbolTable[definition.name]!.append(definition)
174:         }
175: 
176:         // Add to file index
177:         let filePath = definition.location.file
178:         if fileSymbols[filePath] == nil {
179:             fileSymbols[filePath] = []
180:         }
181:         if !fileSymbols[filePath]!.contains(where: { $0.location == definition.location }) {
182:             fileSymbols[filePath]!.append(definition)
183:         }
184:     }
185: 
186:     /// Remove all symbols for a specific file (for refresh)
187:     func clearSymbols(for file: String) {
188:         // Remove from file index
189:         let removed = fileSymbols.removeValue(forKey: file) ?? []
190: 
191:         // Remove from symbol table
192:         for definition in removed {
193:             symbolTable[definition.name]?.removeAll { $0.location.file == file }
194:             if symbolTable[definition.name]?.isEmpty == true {
195:                 symbolTable.removeValue(forKey: definition.name)
196:             }
197:         }
198:     }
199: 
200:     /// Clear all symbols
201:     func clearAllSymbols() {
202:         symbolTable.removeAll()
203:         fileSymbols.removeAll()
204:         parseCache.removeAll()
205:     }
206: 
207:     // MARK: - Find Definition
208: 
209:     /// Find the definition of a symbol
210:     /// - Parameters:
211:     ///   - symbol: The symbol name to find
212:     ///   - context: Optional context (current file) for prioritizing results
213:     /// - Returns: NavigationResult with the definition location(s) or error
214:     func findDefinition(symbol: String, in context: String? = nil) -> NavigationResult {
215:         let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
216:         guard !trimmedSymbol.isEmpty else {
217:             return .notFound(reason: "Empty symbol name")
218:         }
219: 
220:         guard let definitions = symbolTable[trimmedSymbol], !definitions.isEmpty else {
221:             return .notFound(reason: "No definition found for '\(trimmedSymbol)'")
222:         }
223: 
224:         // If only one definition, return it
225:         if definitions.count == 1, let first = definitions.first {
226:             return .found(first.location)
227:         }
228: 
229:         // If we have context, try to prioritize definitions in the same file
230:         if let context {
231:             let inCurrentFile = definitions.filter { $0.location.file == context }
232:             if inCurrentFile.count == 1, let first = inCurrentFile.first {
233:                 return .found(first.location)
234:             }
235:         }
236: 
237:         // Return multiple definitions for user to choose
238:         return .multipleFound(definitions)
239:     }
240: 
241:     /// Find definitions matching a partial name (for autocomplete/suggestions)
242:     func findDefinitions(matching prefix: String, limit: Int = 20) -> [SymbolDefinition] {
243:         let lowercasePrefix = prefix.lowercased()
244: 
245:         return symbolTable.flatMap { (name, definitions) -> [SymbolDefinition] in
246:             if name.lowercased().hasPrefix(lowercasePrefix) {
247:                 return definitions
248:             }
249:             return []
250:         }
251:         .prefix(limit)
252:         .map { $0 }
253:     }
254: 
255:     /// Get all symbols in a file
256:     func getSymbols(in file: String) -> [SymbolDefinition] {
257:         fileSymbols[file] ?? []
258:     }
259: 
260:     // MARK: - Parse File for Symbols
261: 
262:     /// Parse a file's content and extract symbol definitions
263:     /// - Parameters:
264:     ///   - content: The source code content
265:     ///   - file: The file path/identifier
266:     ///   - language: The programming language
267:     func parseAndIndexFile(content: String, file: String, language: CodeLanguage) {
268:         // Check cache
269:         let contentHash = content.hashValue
270:         if let cached = parseCache[contentHash] {
271:             // Re-register cached symbols with new file path
272:             for definition in cached {
273:                 registerSymbol(definition)
274:             }
275:             return
276:         }
277: 
278:         // Clear existing symbols for this file
279:         clearSymbols(for: file)
280: 
281:         // Parse based on language
282:         let definitions: [SymbolDefinition]
283:         switch language {
284:         case .swift:
285:             definitions = parseSwiftDefinitions(content: content, file: file)
286:         case .javascript, .typescript:
287:             definitions = parseJavaScriptDefinitions(content: content, file: file)
288:         case .python:
289:             definitions = parsePythonDefinitions(content: content, file: file)
290:         default:
291:             definitions = parseGenericDefinitions(content: content, file: file)
292:         }
293: 
294:         // Register all definitions
295:         for definition in definitions {
296:             registerSymbol(definition)
297:         }
298: 
299:         // Cache the results
300:         parseCache[contentHash] = definitions
301:     }
302: 
303:     // MARK: - Language Parsers (Regex based)
304: 
305:     private func parseSwiftDefinitions(content: String, file: String) -> [SymbolDefinition] {
306:         var definitions: [SymbolDefinition] = []
307:         let lines = content.components(separatedBy: .newlines)
308: 
309:         // Regex patterns for Swift
310:         let patterns: [(pattern: String, kind: SymbolKind, nameGroup: Int)] = [
311:             // Functions
312:             (#"^\s*(public |private |internal |fileprivate |open )?(static |class )?(override )?func\s+(\w+)"#, .function, 4),
313:             // Classes
314:             (#"^\s*(public |private |internal |fileprivate |open )?(final )?class\s+(\w+)"#, .class, 3),
315:             // Structs
316:             (#"^\s*(public |private |internal |fileprivate |open )?struct\s+(\w+)"#, .struct, 2),
317:             // Enums
318:             (#"^\s*(public |private |internal |fileprivate |open )?enum\s+(\w+)"#, .enum, 2),
319:             // Protocols
320:             (#"^\s*(public |private |internal |fileprivate |open )?protocol\s+(\w+)"#, .protocol, 2)
321:         ]
322: 
323:         for (index, line) in lines.enumerated() {
324:             let lineNum = index + 1
325:             for p in patterns {
326:                 guard let regex = try? NSRegularExpression(pattern: p.pattern) else { continue }
327:                 let range = NSRange(location: 0, length: (line as NSString).length)
328:                 guard let match = regex.firstMatch(in: line, range: range) else { continue }
329: 
330:                 let nameRange = match.range(at: p.nameGroup)
331:                 guard nameRange.location != NSNotFound else { continue }
332:                 let name = (line as NSString).substring(with: nameRange)
333: 
334:                 let location = SymbolLocation(file: file, line: lineNum, column: 1)
335:                 let def = SymbolDefinition(
336:                     name: name,
337:                     kind: p.kind,
338:                     location: location,
339:                     signature: line.trimmingCharacters(in: .whitespaces),
340:                     documentation: nil,
341:                     containerName: nil
342:                 )
343:                 definitions.append(def)
344:             }
345: 
346:             // Enum cases (simple)
347:             if let regex = try? NSRegularExpression(pattern: #"^\s*case\s+(\w+)"#),
348:                let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: (line as NSString).length)) {
349:                 let nameRange = match.range(at: 1)
350:                 if nameRange.location != NSNotFound {
351:                     let name = (line as NSString).substring(with: nameRange)
352:                     let location = SymbolLocation(file: file, line: lineNum, column: 1)
353:                     definitions.append(.init(name: name, kind: .enumCase, location: location, signature: line.trimmingCharacters(in: .whitespaces), documentation: nil, containerName: nil))
354:                 }
355:             }
356:         }
357: 
358:         return definitions
359:     }
360: 
361:     private func parseJavaScriptDefinitions(content: String, file: String) -> [SymbolDefinition] {
362:         var definitions: [SymbolDefinition] = []
363:         let lines = content.components(separatedBy: .newlines)
364: 
365:         // Basic JS/TS patterns
366:         let patterns: [(pattern: String, kind: SymbolKind, nameGroup: Int)] = [
367:             (#"^\s*(export\s+)?(async\s+)?function\s+(\w+)"#, .function, 3),
368:             (#"^\s*(export\s+)?class\s+(\w+)"#, .class, 2),
369:             (#"^\s*(export\s+)?(const|let|var)\s+(\w+)"#, .variable, 3),
370:             (#"^\s*interface\s+(\w+)"#, .interface, 1),
371:             (#"^\s*type\s+(\w+)"#, .type, 1)
372:         ]
373: 
374:         for (index, line) in lines.enumerated() {
375:             let lineNum = index + 1
376:             for p in patterns {
377:                 guard let regex = try? NSRegularExpression(pattern: p.pattern) else { continue }
378:                 let range = NSRange(location: 0, length: (line as NSString).length)
379:                 guard let match = regex.firstMatch(in: line, range: range) else { continue }
380: 
381:                 let nameRange = match.range(at: p.nameGroup)
382:                 guard nameRange.location != NSNotFound else { continue }
383:                 let name = (line as NSString).substring(with: nameRange)
384: 
385:                 let location = SymbolLocation(file: file, line: lineNum, column: 1)
386:                 definitions.append(.init(name: name, kind: p.kind, location: location, signature: line.trimmingCharacters(in: .whitespaces), documentation: nil, containerName: nil))
387:             }
388:         }
389: 
390:         return definitions
391:     }
392: 
393:     private func parsePythonDefinitions(content: String, file: String) -> [SymbolDefinition] {
394:         var definitions: [SymbolDefinition] = []
395:         let lines = content.components(separatedBy: .newlines)
396: 
397:         let patterns: [(pattern: String, kind: SymbolKind, nameGroup: Int)] = [
398:             (#"^\s*def\s+(\w+)\s*\("#, .function, 1),
399:             (#"^\s*class\s+(\w+)\s*\(?"#, .class, 1)
400:         ]
401: 
402:         for (index, line) in lines.enumerated() {
403:             let lineNum = index + 1
404:             for p in patterns {
405:                 guard let regex = try? NSRegularExpression(pattern: p.pattern) else { continue }
406:                 let range = NSRange(location: 0, length: (line as NSString).length)
407:                 guard let match = regex.firstMatch(in: line, range: range) else { continue }
408: 
409:                 let nameRange = match.range(at: p.nameGroup)
410:                 guard nameRange.location != NSNotFound else { continue }
411:                 let name = (line as NSString).substring(with: nameRange)
412: 
413:                 let location = SymbolLocation(file: file, line: lineNum, column: 1)
414:                 definitions.append(.init(name: name, kind: p.kind, location: location, signature: line.trimmingCharacters(in: .whitespaces), documentation: nil, containerName: nil))
415:             }
416:         }
417: 
418:         return definitions
419:     }
420: 
421:     private func parseGenericDefinitions(content: String, file: String) -> [SymbolDefinition] {
422:         // Fallback: try to detect simple function-like declarations
423:         var definitions: [SymbolDefinition] = []
424:         let lines = content.components(separatedBy: .newlines)
425: 
426:         for (index, line) in lines.enumerated() {
427:             let lineNum = index + 1
428: 
429:             // Very rough: identifier followed by "(" at start
430:             if let regex = try? NSRegularExpression(pattern: #"^\s*(\w+)\s*\("#),
431:                let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: (line as NSString).length)) {
432:                 let nameRange = match.range(at: 1)
433:                 if nameRange.location != NSNotFound {
434:                     let name = (line as NSString).substring(with: nameRange)
435:                     let location = SymbolLocation(file: file, line: lineNum, column: 1)
436:                     definitions.append(.init(name: name, kind: .function, location: location, signature: line.trimmingCharacters(in: .whitespaces), documentation: nil, containerName: nil))
437:                 }
438:             }
439:         }
440: 
441:         return definitions
442:     }
443: 
444:     // MARK: - Navigation History
445: 
446:     /// Record a navigation location in history
447:     func recordNavigation(to location: SymbolLocation) {
448:         // Remove any forward history if we're not at the end
449:         if historyIndex < navigationHistory.count - 1 {
450:             navigationHistory = Array(navigationHistory.prefix(historyIndex + 1))
451:         }
452: 
453:         navigationHistory.append(location)
454:         historyIndex = navigationHistory.count - 1
455: 
456:         // Limit history size
457:         if navigationHistory.count > maxHistorySize {
458:             navigationHistory.removeFirst()
459:             historyIndex -= 1
460:         }
461:     }
462: 
463:     /// Navigate back in history
464:     func navigateBack() -> SymbolLocation? {
465:         guard historyIndex > 0 else { return nil }
466:         historyIndex -= 1
467:         return navigationHistory[historyIndex]
468:     }
469: 
470:     /// Navigate forward in history
471:     func navigateForward() -> SymbolLocation? {
472:         guard historyIndex < navigationHistory.count - 1 else { return nil }
473:         historyIndex += 1
474:         return navigationHistory[historyIndex]
475:     }
476: 
477:     /// Check if back navigation is possible
478:     var canNavigateBack: Bool {
479:         historyIndex > 0
480:     }
481: 
482:     /// Check if forward navigation is possible
483:     var canNavigateForward: Bool {
484:         historyIndex < navigationHistory.count - 1
485:     }
486: 
487:     // MARK: - Word at Position
488: 
489:     /// Extract the word/symbol at a given position in text
490:     func getWordAtPosition(_ position: Int, in text: String) -> String? {
491:         guard position >= 0 && position <= text.count else { return nil }
492: 
493:         let nsText = text as NSString
494:         let wordCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
495: 
496:         // Find start of word
497:         var start = position
498:         while start > 0 {
499:             let char = nsText.substring(with: NSRange(location: start - 1, length: 1))
500:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
501:                 start -= 1
502:             } else {
503:                 break
504:             }
505:         }
506: 
507:         // Find end of word
508:         var end = position
509:         while end < nsText.length {
510:             let char = nsText.substring(with: NSRange(location: end, length: 1))
511:             if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
512:                 end += 1
513:             } else {
514:                 break
515:             }
516:         }
517: 
518:         if start == end {
519:             return nil
520:         }
521: 
522:         return nsText.substring(with: NSRange(location: start, length: end - start))
523:     }
524: }
525: 
526: // MARK: - EditorCore Integration Extension
527: 
528: extension EditorCore {
529:     /// Navigate to a symbol definition (F12 / Cmd+Click)
530:     @MainActor
531:     func goToDefinition(at position: Int) {
532:         guard let tab = activeTab else { return }
533: 
534:         let navigationManager = NavigationManager.shared
535: 
536:         // Get the word at cursor position
537:         guard let symbol = navigationManager.getWordAtPosition(position, in: tab.content) else {
538:             return
539:         }
540: 
541:         // Find the definition
542:         let result = navigationManager.findDefinition(symbol: symbol, in: tab.url?.path ?? tab.fileName)
543: 
544:         switch result {
545:         case .found(let location):
546:             navigateToLocation(location)
547: 
548:         case .multipleFound(let definitions):
549:             // Show picker for multiple definitions
550:             navigationManager.multipleDefinitions = definitions
551:             navigationManager.showDefinitionPicker = true
552: 
553:         case .notFound(let reason):
554:             navigationManager.lastNavigationError = reason
555:         }
556:     }
557: 
558:     /// Convenience used by keyboard/menu actions.
559:     @MainActor
560:     func goToDefinitionAtCursor() {
561:         let position = multiCursorState.primaryCursor?.position ?? 0
562:         goToDefinition(at: position)
563:     }
564: 
565:     /// Peek a symbol definition inline (without navigating away).
566:     @MainActor
567:     func peekDefinition(at position: Int) {
568:         guard let tab = activeTab else { return }
569: 
570:         let navigationManager = NavigationManager.shared
571: 
572:         guard let symbol = navigationManager.getWordAtPosition(position, in: tab.content) else {
573:             return
574:         }
575: 
576:         let result = navigationManager.findDefinition(symbol: symbol, in: tab.url?.path ?? tab.fileName)
577: 
578:         switch result {
579:         case .found(let location):
580:             showPeekPreview(for: location)
581: 
582:         case .multipleFound(let definitions):
583:             navigationManager.multipleDefinitions = definitions
584:             navigationManager.showDefinitionPicker = true
585: 
586:         case .notFound(let reason):
587:             navigationManager.lastNavigationError = reason
588:         }
589:     }
590: 
591:     /// Convenience used by keyboard/menu actions.
592:     @MainActor
593:     func peekDefinitionAtCursor() {
594:         let position = multiCursorState.primaryCursor?.position ?? 0
595:         peekDefinition(at: position)
596:     }
597: 
598:     /// Navigate back in recorded navigation history.
599:     @MainActor
600:     func navigateBack() {
601:         if let location = NavigationManager.shared.navigateBack() {
602:             navigateToLocation(location)
603:         }
604:     }
605: 
606:     /// Navigate forward in recorded navigation history.
607:     @MainActor
608:     func navigateForward() {
609:         if let location = NavigationManager.shared.navigateForward() {
610:             navigateToLocation(location)
611:         }
612:     }
613: 
614:     /// Navigate to a specific location
615:     @MainActor
616:     func navigateToLocation(_ location: SymbolLocation) {
617:         let navigationManager = NavigationManager.shared
618: 
619:         // Record current position in history
620:         if let currentTab = activeTab {
621:             let currentLocation = SymbolLocation(
622:                 file: currentTab.url?.path ?? currentTab.fileName,
623:                 line: cursorPosition.line,
624:                 column: cursorPosition.column
625:             )
626:             navigationManager.recordNavigation(to: currentLocation)
627:         }
628: 
629:         // If it's a different file, open it first
630:         if let tab = tabs.first(where: { $0.url?.path == location.file || $0.fileName == location.fileName }) {
631:             activeTabId = tab.id
632:         }
633: 
634:         // Update cursor position
635:         cursorPosition = CursorPosition(line: location.line, column: location.column)
636: 
637:         // Record the navigation destination
638:         navigationManager.recordNavigation(to: location)
639:     }
640: 
641:     /// Parse and index the current active tab
642:     func indexActiveTab() {
643:         guard let tab = activeTab else { return }
644:         let navigationManager = NavigationManager.shared
645: 
646:         // NavigationManager is @MainActor; indexActiveTab can be called from non-isolated contexts.
647:         Task { @MainActor in
648:             navigationManager.parseAndIndexFile(
649:                 content: tab.content,
650:                 file: tab.url?.path ?? tab.fileName,
651:                 language: tab.language
652:             )
653:         }
654:     }
655: 
656:     /// Show peek preview inline (without navigating away)
657:     @MainActor
658:     private func showPeekPreview(for location: SymbolLocation) {
659:         // Find the content at the definition location
660:         if let tab = tabs.first(where: { $0.url?.path == location.file || $0.fileName == location.fileName }) {
661:             let lines = tab.content.components(separatedBy: .newlines)
662:             let startLine = max(0, location.line - 3)
663:             let endLine = min(lines.count, location.line + 7)
664:             let previewLines = lines[startLine..<endLine].joined(separator: "\n")
665: 
666:             // Store peek state for display
667:             peekState = PeekState(
668:                 file: location.fileName,
669:                 line: location.line,
670:                 content: previewLines,
671:                 sourceLine: cursorPosition.line
672:             )
673:         }
674:     }
675: 
676:     /// Convert line/column to character position
677:     private func getCharacterPosition(line: Int, column: Int, in text: String) -> Int {
678:         let lines = text.components(separatedBy: .newlines)
679:         var position = 0
680: 
681:         for i in 0..<min(line - 1, lines.count) {
682:             position += lines[i].count + 1 // +1 for newline
683:         }
684: 
685:         position += min(column - 1, lines.count > line - 1 ? lines[line - 1].count : 0)
686:         return position
687:     }
688: }
689: 
690: // MARK: - Go To Definition Picker View
691: 
692: /// View for selecting from multiple definition locations
693: struct GoToDefinitionPicker: View {
694:     @ObservedObject var navigationManager = NavigationManager.shared
695:     @ObservedObject var editorCore: EditorCore
696: 
697:     @State private var selectedIndex = 0
698:     @FocusState private var isFocused: Bool
699: 
700:     private var definitions: [SymbolDefinition] {
701:         navigationManager.multipleDefinitions
702:     }
703: 
704:     var body: some View {
705:         let base = VStack(spacing: 0) {
706:             // Header
707:             HStack {
708:                 Image(systemName: "arrow.right.circle.fill")
709:                     .foregroundColor(.accentColor)
710:                 Text("Go to Definition")
711:                     .font(.system(size: 14, weight: .semibold))
712:                 Spacer()
713:                 if let first = definitions.first {
714:                     Text("'\(first.name)'")
715:                         .font(.system(size: 12, design: .monospaced))
716:                         .foregroundColor(.secondary)
717:                 }
718:                 Text("×")
719:                     .font(.system(size: 16, weight: .light))
720:                     .foregroundColor(.secondary)
721:                     .onTapGesture { dismiss() }
722:             }
723:             .padding(.horizontal, 16)
724:             .padding(.vertical, 12)
725:             #if canImport(UIKit)
726:             .background(Color(UIColor.secondarySystemBackground))
727:             #endif
728: 
729:             Divider()
730: 
731:             // Definitions list
732:             ScrollViewReader { proxy in
733:                 ScrollView {
734:                     LazyVStack(spacing: 0) {
735:                         ForEach(Array(definitions.enumerated()), id: \.element.id) { index, definition in
736:                             DefinitionRow(
737:                                 definition: definition,
738:                                 isSelected: index == selectedIndex
739:                             )
740:                             .id(index)
741:                             .onTapGesture {
742:                                 selectDefinition(definition)
743:                             }
744:                         }
745:                     }
746:                     .padding(.vertical, 4)
747:                 }
748:                 .onChange(of: selectedIndex) { newIndex in
749:                     withAnimation(.easeInOut(duration: 0.1)) {
750:                         proxy.scrollTo(newIndex, anchor: .center)
751:                     }
752:                 }
753:             }
754:             .frame(maxHeight: 300)
755: 
756:             Divider()
757: 
758:             // Footer with hints
759:             HStack(spacing: 16) {
760:                 KeyboardHint(keys: ["↑", "↓"], description: "navigate")
761:                 KeyboardHint(keys: ["↵"], description: "go to")
762:                 KeyboardHint(keys: ["esc"], description: "close")
763:                 Spacer()
764:                 Text("\(definitions.count) definitions")
765:                     .font(.system(size: 11))
766:                     .foregroundColor(.secondary)
767:             }
768:             .padding(.horizontal, 16)
769:             .padding(.vertical, 8)
770:             #if canImport(UIKit)
771:             .background(Color(UIColor.tertiarySystemBackground))
772:             #endif
773:         }
774:         .frame(width: 500)
775:         #if canImport(UIKit)
776:         .background(Color(UIColor.systemBackground))
777:         #endif
778:         .cornerRadius(12)
779:         .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
780:         .focused($isFocused)
781:         .onAppear {
782:             isFocused = true
783:             selectedIndex = 0
784:         }
785: 
786:         // iOS 17+: keyboard navigation via onKeyPress
787:         if #available(iOS 17.0, *) {
788:             base
789:                 .onKeyPress(.upArrow) {
790:                     if selectedIndex > 0 { selectedIndex -= 1 }
791:                     return .handled
792:                 }
793:                 .onKeyPress(.downArrow) {
794:                     if selectedIndex < definitions.count - 1 { selectedIndex += 1 }
795:                     return .handled
796:                 }
797:                 .onKeyPress(.return) {
798:                     if let def = selectedIndex < definitions.count ? definitions[selectedIndex] : nil {
799:                         selectDefinition(def)
800:                     }
801:                     return .handled
802:                 }
803:                 .onKeyPress(.escape) {
804:                     dismiss()
805:                     return .handled
806:                 }
807:         } else {
808:             base
809:         }
810:     }
811: 
812:     private func selectDefinition(_ definition: SymbolDefinition) {
813:         editorCore.navigateToLocation(definition.location)
814:         dismiss()
815:     }
816: 
817:     private func dismiss() {
818:         navigationManager.showDefinitionPicker = false
819:         navigationManager.multipleDefinitions = []
820:     }
821: }
822: 
823: // MARK: - Definition Row View
824: 
825: struct DefinitionRow: View {
826:     let definition: SymbolDefinition
827:     let isSelected: Bool
828: 
829:     var body: some View {
830:         HStack(spacing: 12) {
831:             // Kind icon
832:             Image(systemName: definition.kind.icon)
833:                 .font(.system(size: 14))
834:                 .foregroundColor(isSelected ? .white : definition.kind.color)
835:                 .frame(width: 24)
836: 
837:             VStack(alignment: .leading, spacing: 2) {
838:                 // Name with container
839:                 HStack(spacing: 4) {
840:                     Text(definition.name)
841:                         .font(.system(size: 13, weight: .medium, design: .monospaced))
842:                         .foregroundColor(isSelected ? .white : .primary)
843: 
844:                     if let container = definition.containerName {
845:                         Text("in \(container)")
846:                             .font(.system(size: 11))
847:                             .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
848:                     }
849:                 }
850: 
851:                 // Location
852:                 HStack(spacing: 8) {
853:                     Text(definition.location.fileName)
854:                         .font(.system(size: 11))
855:                         .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
856: 
857:                     Text("line \(definition.location.line)")
858:                         .font(.system(size: 11))
859:                         .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
860:                 }
861:             }
862: 
863:             Spacer()
864: 
865:             // Signature preview
866:             if let signature = definition.signature {
867:                 Text(signature)
868:                     .font(.system(size: 11, design: .monospaced))
869:                     .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
870:                     .lineLimit(1)
871:                     .frame(maxWidth: 160, alignment: .trailing)
872:             }
873:         }
874:         .padding(.horizontal, 16)
875:         .padding(.vertical, 10)
876:         .background(isSelected ? Color.accentColor : Color.clear)
877:     }
878: }
879: 
880: // MARK: - Keyboard Hint
881: 
882: struct KeyboardHint: View {
883:     let keys: [String]
884:     let description: String
885: 
886:     var body: some View {
887:         HStack(spacing: 6) {
888:             HStack(spacing: 2) {
889:                 ForEach(keys, id: \.self) { key in
890:                     Text(key)
891:                         .font(.system(size: 11, weight: .semibold, design: .monospaced))
892:                         .padding(.horizontal, 6)
893:                         .padding(.vertical, 2)
894:                         .background(Color.secondary.opacity(0.15))
895:                         .cornerRadius(4)
896:                 }
897:             }
898:             Text(description)
899:                 .font(.system(size: 11))
900:                 .foregroundColor(.secondary)
901:         }
902:     }
903: }
904: 
905: 
906: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift (lines 2-100 of 352)
────────────────────────────────────────
2: //  GitManager.swift
3: //  VSCodeiPadOS
4: //
5: //  Minimal Git Manager - stub implementation
6: //  TODO: Implement real git operations via SSH
7: //
8: 
9: import SwiftUI
10: import Combine
11: 
12: // MARK: - Git Errors
13: 
14: enum GitManagerError: Error, LocalizedError {
15:     case noRepository
16:     case gitExecutableNotFound
17:     case commandFailed(args: [String], exitCode: Int32, message: String)
18:     case notAvailableOnIOS
19:     case sshNotConnected
20:     case invalidRepository
21:     
22:     var errorDescription: String? {
23:         switch self {
24:         case .noRepository:
25:             return "No git repository configured"
26:         case .gitExecutableNotFound:
27:             return "Git executable not found"
28:         case let .commandFailed(args, exitCode, message):
29:             return "git \(args.joined(separator: " ")) failed (\(exitCode)): \(message)"
30:         case .notAvailableOnIOS:
31:             return "Git is not available on iOS"
32:         case .sshNotConnected:
33:             return "SSH connection required for git operations"
34:         case .invalidRepository:
35:             return "Invalid git repository"
36:         }
37:     }
38: }
39: 
40: // MARK: - Git Types
41: 
42: enum GitChangeKind: String, Codable, Hashable {
43:     case modified = "M"
44:     case added = "A"
45:     case deleted = "D"
46:     case renamed = "R"
47:     case copied = "C"
48:     case untracked = "?"
49:     case ignored = "!"
50:     case unmerged = "U"
51:     case typeChanged = "T"
52:     case unknown = "X"
53:     
54:     var icon: String {
55:         switch self {
56:         case .modified: return "pencil"
57:         case .added: return "plus"
58:         case .deleted: return "minus"
59:         case .renamed: return "arrow.right"
60:         case .copied: return "doc.on.doc"
61:         case .untracked: return "questionmark"
62:         case .ignored: return "eye.slash"
63:         case .unmerged: return "exclamationmark.triangle"
64:         case .typeChanged: return "arrow.triangle.2.circlepath"
65:         case .unknown: return "questionmark.circle"
66:         }
67:     }
68:     
69:     var color: Color {
70:         switch self {
71:         case .modified: return .orange
72:         case .added: return .green
73:         case .deleted: return .red
74:         case .renamed: return .blue
75:         case .copied: return .blue
76:         case .untracked: return .gray
77:         case .ignored: return .gray
78:         case .unmerged: return .yellow
79:         case .typeChanged: return .purple
80:         case .unknown: return .gray
81:         }
82:     }
83: }
84: 
85: struct GitBranch: Identifiable, Hashable {
86:     let id = UUID()
87:     let name: String
88:     let isRemote: Bool
89:     let isCurrent: Bool
90:     
91:     init(name: String, isRemote: Bool = false, isCurrent: Bool = false) {
92:         self.name = name
93:         self.isRemote = isRemote
94:         self.isCurrent = isCurrent
95:     }
96: }
97: 
98: struct GitCommit: Identifiable, Hashable {
99:     let id: String // SHA
100:     let message: String

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/SearchManager.swift (lines 1-902 of 902)
────────────────────────────────────────
1: import Foundation
2: import Combine
3: 
4: // SearchManager
5: // Implements find-in-files style searching with options (case sensitivity, whole word, regex),
6: // include/exclude glob patterns, query history, and replace-in-files.
7: //
8: // NOTE: This file is intentionally self-contained so it can integrate with varying app models.
9: 
10: public final class SearchManager: ObservableObject {
11: 
12:     // MARK: - Types
13: 
14:     public struct SearchOptions: Codable, Hashable, Sendable {
15:         public var isCaseSensitive: Bool
16:         public var isWholeWord: Bool
17:         public var isRegex: Bool
18: 
19:         public init(isCaseSensitive: Bool = false,
20:                     isWholeWord: Bool = false,
21:                     isRegex: Bool = false) {
22:             self.isCaseSensitive = isCaseSensitive
23:             self.isWholeWord = isWholeWord
24:             self.isRegex = isRegex
25:         }
26:     }
27: 
28:     public struct SearchQuery: Codable, Hashable, Sendable {
29:         public var text: String
30:         public var options: SearchOptions
31:         /// Include file globs (e.g. ["**/*.swift", "**/*.md"]) - empty means include all.
32:         public var includeGlobs: [String]
33:         /// Exclude file globs (e.g. ["**/.git/**", "**/DerivedData/**"]).
34:         public var excludeGlobs: [String]
35: 
36:         public init(text: String,
37:                     options: SearchOptions = .init(),
38:                     includeGlobs: [String] = [],
39:                     excludeGlobs: [String] = []) {
40:             self.text = text
41:             self.options = options
42:             self.includeGlobs = includeGlobs
43:             self.excludeGlobs = excludeGlobs
44:         }
45:     }
46: 
47:     public struct MatchLocation: Codable, Hashable, Sendable {
48:         public var line: Int
49:         public var column: Int
50:         public var length: Int
51: 
52:         public init(line: Int, column: Int, length: Int) {
53:             self.line = line
54:             self.column = column
55:             self.length = length
56:         }
57:     }
58: 
59:     public struct FileMatch: Codable, Hashable, Sendable, Identifiable {
60:         public var id: String { filePath }
61:         public var filePath: String
62:         public var matches: [Match]
63: 
64:         public init(filePath: String, matches: [Match]) {
65:             self.filePath = filePath
66:             self.matches = matches
67:         }
68: 
69:         public struct Match: Codable, Hashable, Sendable, Identifiable {
70:             public var id: String { "\(location.line):\(location.column):\(location.length):\(preview)" }
71:             public var location: MatchLocation
72:             public var preview: String
73: 
74:             public init(location: MatchLocation, preview: String) {
75:                 self.location = location
76:                 self.preview = preview
77:             }
78:         }
79:     }
80: 
81:     public struct ReplaceResult: Codable, Hashable, Sendable {
82:         public var filesTouched: Int
83:         public var replacements: Int
84:         public var fileResults: [PerFile]
85: 
86:         public init(filesTouched: Int, replacements: Int, fileResults: [PerFile]) {
87:             self.filesTouched = filesTouched
88:             self.replacements = replacements
89:             self.fileResults = fileResults
90:         }
91: 
92:         public struct PerFile: Codable, Hashable, Sendable {
93:             public var filePath: String
94:             public var replacements: Int
95:             public init(filePath: String, replacements: Int) {
96:                 self.filePath = filePath
97:                 self.replacements = replacements
98:             }
99:         }
100:     }
101: 
102:     public enum SearchError: Error, LocalizedError {
103:         case emptyQuery
104:         case invalidRegex(String)
105:         case ioError(String)
106: 
107:         public var errorDescription: String? {
108:             switch self {
109:             case .emptyQuery:
110:                 return "Search query is empty."
111:             case .invalidRegex(let pattern):
112:                 return "Invalid regular expression: \(pattern)"
113:             case .ioError(let msg):
114:                 return msg
115:             }
116:         }
117:     }
118: 
119:     // MARK: - Published State (UI integration)
120: 
121:     @Published public private(set) var isSearching: Bool = false
122:     @Published public private(set) var progress: Double = 0
123:     @Published public private(set) var results: [FileMatch] = []
124:     @Published public private(set) var lastError: String? = nil
125: 
126:     /// Most-recent-first history.
127:     @Published public private(set) var history: [SearchQuery] = []
128: 
129:     // MARK: - Config
130: 
131:     public var maxHistoryCount: Int = 30
132: 
133:     // MARK: - Private
134: 
135:     private var searchTask: Task<Void, Never>? = nil
136:     private let historyKey = "SearchManager.history.v1"
137: 
138:     // MARK: - Init
139: 
140:     public init() {
141:         loadHistory()
142:     }
143: 
144:     deinit {
145:         searchTask?.cancel()
146:     }
147: 
148:     // MARK: - History
149: 
150:     public func addToHistory(_ query: SearchQuery) {
151:         let trimmed = query.text.trimmingCharacters(in: .whitespacesAndNewlines)
152:         guard !trimmed.isEmpty else { return }
153: 
154:         var q = query
155:         q.text = trimmed
156: 
157:         history.removeAll(where: { $0 == q })
158:         history.insert(q, at: 0)
159:         if history.count > maxHistoryCount {
160:             history.removeLast(history.count - maxHistoryCount)
161:         }
162:         persistHistory()
163:     }
164: 
165:     public func clearHistory() {
166:         history = []
167:         persistHistory()
168:     }
169: 
170:     private func loadHistory() {
171:         guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
172:         if let decoded = try? JSONDecoder().decode([SearchQuery].self, from: data) {
173:             history = decoded
174:         }
175:     }
176: 
177:     private func persistHistory() {
178:         guard let data = try? JSONEncoder().encode(history) else { return }
179:         UserDefaults.standard.set(data, forKey: historyKey)
180:     }
181: 
182:     // MARK: - Search API
183: 
184:     /// Cancels any in-flight search.
185:     public func cancelSearch() {
186:         searchTask?.cancel()
187:         searchTask = nil
188:         isSearching = false
189:     }
190:     
191:     /// Clears the current search results.
192:     public func clearResults() {
193:         results = []
194:         lastError = nil
195:     }
196:     
197:     /// Clears the last error
198:     public func clearError() {
199:         lastError = nil
200:     }
201: 
202:     /// Search files under `rootURL`.
203:     /// - Parameters:
204:     ///   - rootURL: Directory to search.
205:     ///   - query: Query and options.
206:     ///   - fileURLs: Optional pre-resolved file list. If provided, include/exclude filtering is still applied.
207:     @MainActor
208:     public func search(in rootURL: URL,
209:                        query: SearchQuery,
210:                        fileURLs: [URL]? = nil) {
211:         lastError = nil
212:         results = []
213:         progress = 0
214: 
215:         let trimmed = query.text.trimmingCharacters(in: .whitespacesAndNewlines)
216:         guard !trimmed.isEmpty else {
217:             lastError = SearchError.emptyQuery.localizedDescription
218:             return
219:         }
220: 
221:         // update history immediately
222:         addToHistory(query)
223: 
224:         cancelSearch()
225:         isSearching = true
226: 
227:         let q = SearchQuery(text: trimmed,
228:                             options: query.options,
229:                             includeGlobs: query.includeGlobs,
230:                             excludeGlobs: query.excludeGlobs)
231: 
232:         searchTask = Task.detached(priority: .userInitiated) { [weak self] in
233:             guard let self else { return }
234:             do {
235:                 let resolvedFiles = try self.resolveFiles(rootURL: rootURL, provided: fileURLs, query: q)
236:                 let total = max(resolvedFiles.count, 1)
237: 
238:                 var aggregated: [FileMatch] = []
239:                 for (idx, url) in resolvedFiles.enumerated() {
240:                     try Task.checkCancellation()
241:                     if let match = try self.searchFile(url: url, rootURL: rootURL, query: q), !match.matches.isEmpty {
242:                         aggregated.append(match)
243:                     }
244:                     let p = Double(idx + 1) / Double(total)
245:                     await MainActor.run {
246:                         self.progress = p
247:                     }
248:                 }
249: 
250:                 await MainActor.run {
251:                     self.results = aggregated
252:                     self.isSearching = false
253:                     self.progress = 1
254:                 }
255:             } catch is CancellationError {
256:                 await MainActor.run {
257:                     self.isSearching = false
258:                 }
259:             } catch {
260:                 await MainActor.run {
261:                     self.lastError = error.localizedDescription
262:                     self.isSearching = false
263:                 }
264:             }
265:         }
266:     }
267: 
268:     // MARK: - Replace in files
269: 
270:     /// Replace occurrences for `query` with `replacement` under `rootURL`.
271:     /// Returns counts per file.
272:     public func replace(in rootURL: URL,
273:                         query: SearchQuery,
274:                         replacement: String,
275:                         fileURLs: [URL]? = nil) async throws -> ReplaceResult {
276:         let trimmed = query.text.trimmingCharacters(in: .whitespacesAndNewlines)
277:         guard !trimmed.isEmpty else { throw SearchError.emptyQuery }
278: 
279:         let q = SearchQuery(text: trimmed,
280:                             options: query.options,
281:                             includeGlobs: query.includeGlobs,
282:                             excludeGlobs: query.excludeGlobs)
283: 
284:         // Pre-compile pattern.
285:         let compiled = try compilePattern(for: q)
286: 
287:         let resolvedFiles = try resolveFiles(rootURL: rootURL, provided: fileURLs, query: q)
288:         var perFile: [ReplaceResult.PerFile] = []
289:         perFile.reserveCapacity(resolvedFiles.count)
290: 
291:         var totalReplacements = 0
292:         var filesTouched = 0
293: 
294:         for url in resolvedFiles {
295:             try Task.checkCancellation()
296:             let (changed, reps) = try replaceInFile(url: url, compiled: compiled, replacement: replacement)
297:             if changed {
298:                 filesTouched += 1
299:                 totalReplacements += reps
300:                 perFile.append(.init(filePath: url.path, replacements: reps))
301:             }
302:         }
303: 
304:         return ReplaceResult(filesTouched: filesTouched,
305:                              replacements: totalReplacements,
306:                              fileResults: perFile)
307:     }
308: 
309:     // MARK: - File enumeration + filtering
310: 
311:     private func resolveFiles(rootURL: URL, provided: [URL]?, query: SearchQuery) throws -> [URL] {
312:         let all: [URL]
313:         if let provided {
314:             all = provided
315:         } else {
316:             all = try enumerateFiles(rootURL: rootURL)
317:         }
318:         return all.filter { url in
319:             guard url.isFileURL else { return false }
320:             let path = url.path
321:             if matchesAnyGlob(path: path, globs: query.excludeGlobs) { return false }
322:             if query.includeGlobs.isEmpty { return true }
323:             return matchesAnyGlob(path: path, globs: query.includeGlobs)
324:         }
325:     }
326: 
327:     private func enumerateFiles(rootURL: URL) throws -> [URL] {
328:         let fm = FileManager.default
329:         guard let enumerator = fm.enumerator(at: rootURL,
330:                                             includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
331:                                             options: [.skipsHiddenFiles],
332:                                             errorHandler: { _, _ in true }) else {
333:             return []
334:         }
335: 
336:         var urls: [URL] = []
337:         for case let url as URL in enumerator {
338:             let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey])
339:             if values?.isDirectory == true { continue }
340:             if values?.isRegularFile == true {
341:                 urls.append(url)
342:             }
343:         }
344:         return urls
345:     }
346: 
347:     // MARK: - Actual searching
348: 
349:     private struct CompiledPattern {
350:         enum Kind {
351:             case regex(NSRegularExpression)
352:             case literal(needle: String, compareLowercased: Bool, wholeWord: Bool)
353:         }
354:         let kind: Kind
355:     }
356: 
357:     private func compilePattern(for query: SearchQuery) throws -> CompiledPattern {
358:         if query.options.isRegex {
359:             let opts: NSRegularExpression.Options = query.options.isCaseSensitive ? [] : [.caseInsensitive]
360:             do {
361:                 let re = try NSRegularExpression(pattern: query.text, options: opts)
362:                 return CompiledPattern(kind: .regex(re))
363:             } catch {
364:                 throw SearchError.invalidRegex(query.text)
365:             }
366:         } else {
367:             // Literal search.
368:             let compareLowercased = !query.options.isCaseSensitive
369:             return CompiledPattern(kind: .literal(needle: query.text,
370:                                                  compareLowercased: compareLowercased,
371:                                                  wholeWord: query.options.isWholeWord))
372:         }
373:     }
374: 
375:     private func searchFile(url: URL, rootURL: URL, query: SearchQuery) throws -> FileMatch? {
376:         let compiled = try compilePattern(for: query)
377:         let data: Data
378:         do {
379:             data = try Data(contentsOf: url)
380:         } catch {
381:             // ignore unreadable files
382:             return nil
383:         }
384:         // Try UTF-8 first. If it fails, ignore file (keeps implementation safe).
385:         guard let text = String(data: data, encoding: .utf8) else { return nil }
386: 
387:         let relPath: String
388:         if url.path.hasPrefix(rootURL.path) {
389:             relPath = String(url.path.dropFirst(rootURL.path.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
390:         } else {
391:             relPath = url.path
392:         }
393: 
394:         let matches = findMatches(in: text, compiled: compiled)
395:         if matches.isEmpty { return nil }
396: 
397:         return FileMatch(filePath: relPath, matches: matches)
398:     }
399: 
400:     private func findMatches(in text: String, compiled: CompiledPattern) -> [FileMatch.Match] {
401:         switch compiled.kind {
402:         case .regex(let re):
403:             return regexMatches(in: text, re: re)
404:         case .literal(let needle, let compareLowercased, let wholeWord):
405:             return literalMatches(in: text, needle: needle, compareLowercased: compareLowercased, wholeWord: wholeWord)
406:         }
407:     }
408: 
409:     private func regexMatches(in text: String, re: NSRegularExpression) -> [FileMatch.Match] {
410:         let ns = text as NSString
411:         let range = NSRange(location: 0, length: ns.length)
412:         let matches = re.matches(in: text, options: [], range: range)
413:         if matches.isEmpty { return [] }
414: 
415:         // Precompute line starts for fast conversion.
416:         let lineIndex = LineIndex(text)
417: 
418:         return matches.compactMap { m in
419:             guard m.range.location != NSNotFound, m.range.length > 0 else { return nil }
420:             let (line, col) = lineIndex.lineAndColumn(utf16Offset: m.range.location)
421:             let preview = lineIndex.lineText(line: line)
422:             return .init(location: .init(line: line, column: col, length: m.range.length), preview: preview)
423:         }
424:     }
425: 
426:     private func literalMatches(in text: String,
427:                                needle: String,
428:                                compareLowercased: Bool,
429:                                wholeWord: Bool) -> [FileMatch.Match] {
430:         guard !needle.isEmpty else { return [] }
431: 
432:         let haystack = compareLowercased ? text.lowercased() : text
433:         let n = compareLowercased ? needle.lowercased() : needle
434: 
435:         // Use NSString for UTF16 indexing.
436:         let nsHay = haystack as NSString
437:         let nsOrig = text as NSString
438: 
439:         let lineIndex = LineIndex(text)
440: 
441:         var results: [FileMatch.Match] = []
442:         var searchRange = NSRange(location: 0, length: nsHay.length)
443: 
444:         while true {
445:             let found = nsHay.range(of: n, options: [], range: searchRange)
446:             if found.location == NSNotFound { break }
447: 
448:             if wholeWord {
449:                 if !isWholeWordMatch(in: nsHay, range: found) {
450:                     let nextLoc = found.location + max(found.length, 1)
451:                     if nextLoc >= nsHay.length { break }
452:                     searchRange = NSRange(location: nextLoc, length: nsHay.length - nextLoc)
453:                     continue
454:                 }
455:             }
456: 
457:             let (line, col) = lineIndex.lineAndColumn(utf16Offset: found.location)
458:             let preview = lineIndex.lineText(line: line)
459: 
460:             // Use original needle length in UTF16 for accurate highlighting.
461:             let origLen = (needle as NSString).length
462:             results.append(.init(location: .init(line: line, column: col, length: origLen), preview: preview))
463: 
464:             let nextLoc = found.location + max(found.length, 1)
465:             if nextLoc >= nsHay.length { break }
466:             searchRange = NSRange(location: nextLoc, length: nsHay.length - nextLoc)
467:         }
468: 
469:         return results
470:     }
471: 
472:     private func isWholeWordMatch(in nsText: NSString, range: NSRange) -> Bool {
473:         // Word boundary definition: letters, numbers, underscore.
474:         func isWordChar(_ u: unichar) -> Bool {
475:             if u == 95 { return true } // '_'
476:             // ASCII letters/digits
477:             if (u >= 48 && u <= 57) || (u >= 65 && u <= 90) || (u >= 97 && u <= 122) { return true }
478:             return false
479:         }
480: 
481:         if range.location > 0 {
482:             let prev = nsText.character(at: range.location - 1)
483:             if isWordChar(prev) { return false }
484:         }
485:         let end = range.location + range.length
486:         if end < nsText.length {
487:             let next = nsText.character(at: end)
488:             if isWordChar(next) { return false }
489:         }
490:         return true
491:     }
492: 
493:     // MARK: - Replace implementation
494: 
495:     private func replaceInFile(url: URL,
496:                                compiled: CompiledPattern,
497:                                replacement: String) throws -> (changed: Bool, replacements: Int) {
498:         let data: Data
499:         do {
500:             data = try Data(contentsOf: url)
501:         } catch {
502:             return (false, 0)
503:         }
504:         guard let text = String(data: data, encoding: .utf8) else { return (false, 0) }
505: 
506:         let (newText, reps) = replaceAll(in: text, compiled: compiled, replacement: replacement)
507:         guard reps > 0 else { return (false, 0) }
508: 
509:         do {
510:             // Atomic write.
511:             try newText.data(using: .utf8)?.write(to: url, options: [.atomic])
512:         } catch {
513:             throw SearchError.ioError("Failed to write file: \(url.path)")
514:         }
515:         return (true, reps)
516:     }
517: 
518:     private func replaceAll(in text: String,
519:                             compiled: CompiledPattern,
520:                             replacement: String) -> (String, Int) {
521:         switch compiled.kind {
522:         case .regex(let re):
523:             let ns = text as NSString
524:             let range = NSRange(location: 0, length: ns.length)
525:             let matches = re.matches(in: text, options: [], range: range)
526:             if matches.isEmpty { return (text, 0) }
527:             let out = re.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: replacement)
528:             return (out, matches.count)
529: 
530:         case .literal(let needle, let compareLowercased, let wholeWord):
531:             if needle.isEmpty { return (text, 0) }
532:             // For literal, we re-scan and build output to support whole-word.
533:             let haystack = compareLowercased ? text.lowercased() : text
534:             let n = compareLowercased ? needle.lowercased() : needle
535: 
536:             let nsHay = haystack as NSString
537:             let nsOrig = text as NSString
538:             let nsNeedle = n as NSString
539: 
540:             var out = ""
541:             out.reserveCapacity(text.count)
542: 
543:             var cursor = 0
544:             var reps = 0
545: 
546:             while cursor < nsHay.length {
547:                 let searchRange = NSRange(location: cursor, length: nsHay.length - cursor)
548:                 let found = nsHay.range(of: n, options: [], range: searchRange)
549:                 if found.location == NSNotFound {
550:                     out += nsOrig.substring(with: NSRange(location: cursor, length: nsOrig.length - cursor))
551:                     break
552:                 }
553: 
554:                 // append leading segment
555:                 out += nsOrig.substring(with: NSRange(location: cursor, length: found.location - cursor))
556: 
557:                 if wholeWord && !isWholeWordMatch(in: nsHay, range: found) {
558:                     // not a whole-word match; append original matched text and continue
559:                     out += nsOrig.substring(with: found)
560:                     cursor = found.location + max(found.length, 1)
561:                     continue
562:                 }
563: 
564:                 out += replacement
565:                 reps += 1
566: 
567:                 cursor = found.location + max(nsNeedle.length, 1)
568:             }
569: 
570:             return (out, reps)
571:         }
572:     }
573: 
574:     // MARK: - Glob matching
575: 
576:     /// Very small glob matcher supporting '*', '**', and '?'.
577:     /// Matching is path-based (uses '/' as separator). Globs are compared against the full path.
578:     private func matchesAnyGlob(path: String, globs: [String]) -> Bool {
579:         guard !globs.isEmpty else { return false }
580:         for g in globs {
581:             if globMatch(path: path, pattern: g) { return true }
582:         }
583:         return false
584:     }
585: 
586:     private func globMatch(path: String, pattern: String) -> Bool {
587:         // Convert glob to regex.
588:         // - '**' => '.*'
589:         // - '*' => '[^/]*'
590:         // - '?' => '[^/]'
591:         var regex = "^"
592:         var i = pattern.startIndex
593:         while i < pattern.endIndex {
594:             let ch = pattern[i]
595:             if ch == "*" {
596:                 let next = pattern.index(after: i)
597:                 if next < pattern.endIndex && pattern[next] == "*" {
598:                     regex += ".*"
599:                     i = pattern.index(after: next)
600:                 } else {
601:                     regex += "[^/]*"
602:                     i = next
603:                 }
604:             } else if ch == "?" {
605:                 regex += "[^/]"
606:                 i = pattern.index(after: i)
607:             } else {
608:                 // escape regex metacharacters
609:                 if "\\.^$|()[]{}+".contains(ch) {
610:                     // Single backslash to escape the character in regex
611:                     // e.g., "." becomes "\." which matches literal dot
612:                     regex += "\\\(ch)"
613:                 } else {
614:                     regex.append(ch)
615:                 }
616:                 i = pattern.index(after: i)
617:             }
618:         }
619:         regex += "$"
620: 
621:         let opts: NSRegularExpression.Options = []
622:         guard let re = try? NSRegularExpression(pattern: regex, options: opts) else { return false }
623:         let ns = path as NSString
624:         let r = NSRange(location: 0, length: ns.length)
625:         return re.firstMatch(in: path, options: [], range: r) != nil
626:     }
627: 
628:     // MARK: - Glob Pattern Testing
629: 
630:     /// Runs all glob pattern tests and returns results for verification
631:     /// - Returns: Tuple containing (passedCount, failedCount, [failureDetails])
632:     public func runGlobTests() -> (passed: Int, failed: Int, failures: [String]) {
633:         var passed = 0
634:         var failed = 0
635:         var failures: [String] = []
636: 
637:         func assert(_ condition: Bool, _ message: String) {
638:             if condition {
639:                 passed += 1
640:             } else {
641:                 failed += 1
642:                 failures.append(message)
643:             }
644:         }
645: 
646:         // MARK: 1. testGlobStar - single * matches any chars except /
647:         
648:         // Single * should match any characters except path separator /
649:         assert(globMatch(path: "file.swift", pattern: "*.swift"), "testGlobStar: *.swift should match file.swift")
650:         assert(globMatch(path: "main.swift", pattern: "*.swift"), "testGlobStar: *.swift should match main.swift")
651:         assert(globMatch(path: "ViewController.swift", pattern: "*.swift"), "testGlobStar: *.swift should match ViewController.swift")
652:         assert(!globMatch(path: "src/file.swift", pattern: "*.swift"), "testGlobStar: *.swift should NOT match src/file.swift (contains /)")
653:         assert(!globMatch(path: "path/to/file.swift", pattern: "*.swift"), "testGlobStar: *.swift should NOT match path/to/file.swift (contains /)")
654:         
655:         // * in the middle
656:         assert(globMatch(path: "test-file.txt", pattern: "test-*.txt"), "testGlobStar: test-*.txt should match test-file.txt")
657:         assert(globMatch(path: "test-123.txt", pattern: "test-*.txt"), "testGlobStar: test-*.txt should match test-123.txt")
658:         assert(globMatch(path: "test-123-456.txt", pattern: "test-*.txt"), "testGlobStar: test-*.txt should match test-123-456.txt")
659:         
660:         // Multiple *
661:         assert(globMatch(path: "a.b.swift", pattern: "*.*.swift"), "testGlobStar: *.*.swift should match a.b.swift")
662:         assert(globMatch(path: "View.Controller.swift", pattern: "*.*.swift"), "testGlobStar: *.*.swift should match View.Controller.swift")
663:         assert(!globMatch(path: "file.swift", pattern: "*.*.swift"), "testGlobStar: *.*.swift should NOT match file.swift (no dot before .swift)")
664: 
665:         // MARK: 2. testGlobDoubleStar - ** matches any path including /
666:         
667:         // ** should match any characters including path separator /
668:         assert(globMatch(path: "file.swift", pattern: "**/*.swift"), "testGlobDoubleStar: **/*.swift should match file.swift")
669:         assert(globMatch(path: "src/file.swift", pattern: "**/*.swift"), "testGlobDoubleStar: **/*.swift should match src/file.swift")
670:         assert(globMatch(path: "path/to/file.swift", pattern: "**/*.swift"), "testGlobDoubleStar: **/*.swift should match path/to/file.swift")
671:         assert(globMatch(path: "very/deep/nested/path/file.swift", pattern: "**/*.swift"), "testGlobDoubleStar: **/*.swift should match very/deep/nested/path/file.swift")
672:         assert(!globMatch(path: "file.txt", pattern: "**/*.swift"), "testGlobDoubleStar: **/*.swift should NOT match file.txt (wrong extension)")
673:         assert(!globMatch(path: "src/file.txt", pattern: "**/*.swift"), "testGlobDoubleStar: **/*.swift should NOT match src/file.txt (wrong extension)")
674:         
675:         // ** at the start only
676:         assert(globMatch(path: "foo/bar/baz", pattern: "**/baz"), "testGlobDoubleStar: **/baz should match foo/bar/baz")
677:         assert(globMatch(path: "baz", pattern: "**/baz"), "testGlobDoubleStar: **/baz should match baz")
678:         assert(globMatch(path: "a/b/c/baz", pattern: "**/baz"), "testGlobDoubleStar: **/baz should match a/b/c/baz")
679:         
680:         // ** at the end
681:         assert(globMatch(path: "src/", pattern: "src/**"), "testGlobDoubleStar: src/** should match src/")
682:         assert(globMatch(path: "src/file.swift", pattern: "src/**"), "testGlobDoubleStar: src/** should match src/file.swift")
683:         assert(globMatch(path: "src/components/Button.swift", pattern: "src/**"), "testGlobDoubleStar: src/** should match src/components/Button.swift")
684: 
685:         // MARK: 3. testGlobQuestion - ? matches single char
686:         
687:         // ? should match exactly one character (any char except /)
688:         assert(globMatch(path: "file1.swift", pattern: "file?.swift"), "testGlobQuestion: file?.swift should match file1.swift")
689:         assert(globMatch(path: "fileA.swift", pattern: "file?.swift"), "testGlobQuestion: file?.swift should match fileA.swift")
690:         assert(globMatch(path: "file_.swift", pattern: "file?.swift"), "testGlobQuestion: file?.swift should match file_.swift")
691:         assert(!globMatch(path: "file12.swift", pattern: "file?.swift"), "testGlobQuestion: file?.swift should NOT match file12.swift (two chars)")
692:         assert(!globMatch(path: "file.swift", pattern: "file?.swift"), "testGlobQuestion: file?.swift should NOT match file.swift (no char before .swift)")
693:         assert(!globMatch(path: "file/1.swift", pattern: "file?.swift"), "testGlobQuestion: file?.swift should NOT match file/1.swift (? doesn't match /)")
694:         
695:         // Multiple ?
696:         assert(globMatch(path: "file01.txt", pattern: "file??.txt"), "testGlobQuestion: file??.txt should match file01.txt")
697:         assert(globMatch(path: "fileAB.txt", pattern: "file??.txt"), "testGlobQuestion: file??.txt should match fileAB.txt")
698:         assert(!globMatch(path: "file1.txt", pattern: "file??.txt"), "testGlobQuestion: file??.txt should NOT match file1.txt (only one char)")
699: 
700:         // MARK: 4. testGlobExactMatch - exact path matching
701:         
702:         // Exact path should match exactly
703:         assert(globMatch(path: "file.swift", pattern: "file.swift"), "testGlobExactMatch: exact match file.swift")
704:         assert(globMatch(path: "src/file.swift", pattern: "src/file.swift"), "testGlobExactMatch: exact match src/file.swift")
705:         assert(!globMatch(path: "File.swift", pattern: "file.swift"), "testGlobExactMatch: file.swift should NOT match File.swift (case sensitive)")
706:         assert(!globMatch(path: "file.swift", pattern: "file.txt"), "testGlobExactMatch: file.txt should NOT match file.swift")
707:         assert(!globMatch(path: "src/file.swift", pattern: "file.swift"), "testGlobExactMatch: file.swift should NOT match src/file.swift (different path)")
708:         
709:         // Empty pattern edge case
710:         assert(!globMatch(path: "file.swift", pattern: ""), "testGlobExactMatch: empty pattern should NOT match file.swift")
711:         assert(globMatch(path: "", pattern: ""), "testGlobExactMatch: empty pattern should match empty path")
712: 
713:         // MARK: 5. testGlobMultiplePatterns - test matchesAnyGlob with array
714:         
715:         // Test matchesAnyGlob with multiple patterns
716:         assert(matchesAnyGlob(path: "file.swift", globs: ["*.swift", "*.md"]), "testGlobMultiplePatterns: should match *.swift in array")
717:         assert(matchesAnyGlob(path: "README.md", globs: ["*.swift", "*.md"]), "testGlobMultiplePatterns: should match *.md in array")
718:         assert(!matchesAnyGlob(path: "file.txt", globs: ["*.swift", "*.md"]), "testGlobMultiplePatterns: should NOT match *.txt")
719:         
720:         assert(matchesAnyGlob(path: "src/main.swift", globs: ["**/*.swift", "**/*.h", "**/*.m"]), "testGlobMultiplePatterns: should match **/*.swift")
721:         assert(matchesAnyGlob(path: "headers/main.h", globs: ["**/*.swift", "**/*.h", "**/*.m"]), "testGlobMultiplePatterns: should match **/*.h")
722:         assert(matchesAnyGlob(path: "impl/main.m", globs: ["**/*.swift", "**/*.h", "**/*.m"]), "testGlobMultiplePatterns: should match **/*.m")
723:         assert(!matchesAnyGlob(path: "src/main.js", globs: ["**/*.swift", "**/*.h", "**/*.m"]), "testGlobMultiplePatterns: should NOT match **/*.js")
724:         
725:         // Empty globs array
726:         assert(!matchesAnyGlob(path: "file.swift", globs: []), "testGlobMultiplePatterns: empty globs should return false")
727:         
728:         // Single pattern in array
729:         assert(matchesAnyGlob(path: "file.swift", globs: ["*.swift"]), "testGlobMultiplePatterns: single pattern array should match")
730:         assert(!matchesAnyGlob(path: "file.txt", globs: ["*.swift"]), "testGlobMultiplePatterns: single pattern array should NOT match wrong extension")
731: 
732:         // MARK: 6. testGlobEdgeCases - empty patterns, special chars
733:         
734:         // Only wildcards
735:         assert(globMatch(path: "anything", pattern: "*"), "testGlobEdgeCases: * should match anything")
736:         assert(globMatch(path: "", pattern: "*"), "testGlobEdgeCases: * should match empty string")
737:         assert(globMatch(path: "a/b/c", pattern: "**"), "testGlobEdgeCases: ** should match a/b/c")
738:         
739:         // Special regex characters that should be escaped (treated as literals)
740:         assert(globMatch(path: "file.swift", pattern: "file.swift"), "testGlobEdgeCases: . should be literal, not regex wildcard")
741:         assert(!globMatch(path: "fileXswift", pattern: "file.swift"), "testGlobEdgeCases: . should NOT match X")
742:         assert(globMatch(path: "test+file.swift", pattern: "test+file.swift"), "testGlobEdgeCases: + should be literal")
743:         assert(globMatch(path: "(test).swift", pattern: "(test).swift"), "testGlobEdgeCases: () should be literal")
744:         assert(globMatch(path: "[test].swift", pattern: "[test].swift"), "testGlobEdgeCases: [] should be literal")
745:         
746:         // Escaped characters in pattern
747:         assert(globMatch(path: "file.swift", pattern: #"file\.swift"#), "testGlobEdgeCases: escaped dot should match literal dot")
748:         
749:         // Whitespace handling
750:         assert(globMatch(path: "file name.swift", pattern: "file*.swift"), "testGlobEdgeCases: should match with space in filename")
751:         assert(globMatch(path: "file name.swift", pattern: "file *.swift"), "testGlobEdgeCases: should match with space in pattern")
752: 
753:         // MARK: 7. testGlobSwiftFiles - **/*.swift pattern
754:         
755:         let swiftPattern = "**/*.swift"
756:         
757:         // Root level Swift files
758:         assert(globMatch(path: "main.swift", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should match main.swift")
759:         assert(globMatch(path: "App.swift", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should match App.swift")
760:         
761:         // Nested Swift files
762:         assert(globMatch(path: "Sources/main.swift", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should match Sources/main.swift")
763:         assert(globMatch(path: "Sources/Models/User.swift", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should match Sources/Models/User.swift")
764:         assert(globMatch(path: "Sources/Views/Buttons/PrimaryButton.swift", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should match deep nested path")
765:         
766:         // Deep nesting
767:         assert(globMatch(path: "a/b/c/d/e/f/g/file.swift", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should match very deep path")
768:         
769:         // Non-matching cases
770:         assert(!globMatch(path: "main.m", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should NOT match main.m")
771:         assert(!globMatch(path: "Sources/main.m", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should NOT match Sources/main.m")
772:         assert(!globMatch(path: "file.txt", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should NOT match file.txt")
773:         assert(!globMatch(path: "Sources/file.h", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should NOT match Sources/file.h")
774:         
775:         // Edge cases that look similar
776:         assert(!globMatch(path: "file.swift.txt", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should NOT match file.swift.txt (ends with .txt)")
777:         assert(!globMatch(path: "file.swiftbackup", pattern: swiftPattern), "testGlobSwiftFiles: **/*.swift should NOT match file.swiftbackup (ends with backup)")
778: 
779:         // MARK: 8. testGlobExcludeNodeModules - **/node_modules/** pattern
780:         
781:         let nodeModulesPattern = "**/node_modules/**"
782:         
783:         // Should match node_modules at any level
784:         assert(globMatch(path: "node_modules/", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should match node_modules/")
785:         assert(globMatch(path: "node_modules/lodash", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should match node_modules/lodash")
786:         assert(globMatch(path: "node_modules/lodash/index.js", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should match node_modules/lodash/index.js")
787:         assert(globMatch(path: "client/node_modules/", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should match client/node_modules/")
788:         assert(globMatch(path: "client/node_modules/react", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should match client/node_modules/react")
789:         assert(globMatch(path: "client/node_modules/react/index.js", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should match client/node_modules/react/index.js")
790:         assert(globMatch(path: "src/client/node_modules/package/lib/file.js", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should match deeply nested node_modules")
791:         
792:         // Deep nesting
793:         assert(globMatch(path: "a/b/c/node_modules/package/file.js", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should match a/b/c/node_modules")
794:         
795:         // Should NOT match (not node_modules)
796:         assert(!globMatch(path: "src/main.js", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should NOT match src/main.js")
797:         assert(!globMatch(path: "node_modules_backup/file.js", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should NOT match node_modules_backup (not exact match)")
798:         assert(!globMatch(path: "src/node_modules_test/file.js", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should NOT match node_modules_test")
799:         assert(!globMatch(path: "mynode_modules/file.js", pattern: nodeModulesPattern), "testGlobExcludeNodeModules: should NOT match mynode_modules")
800: 
801:         // MARK: Additional Comprehensive Tests
802:         
803:         // Pattern with **, *, and ?
804:         assert(globMatch(path: "src/components/Button.swift", pattern: "**/*?utton.swift"), "testComplex: **/*?utton.swift should match src/components/Button.swift")
805:         assert(globMatch(path: "Button.swift", pattern: "**/*?utton.swift"), "testComplex: **/*?utton.swift should match Button.swift")
806:         assert(!globMatch(path: "src/components/Switch.swift", pattern: "**/*?utton.swift"), "testComplex: **/*?utton.swift should NOT match Switch.swift")
807:         
808:         // Multiple ** in pattern
809:         assert(globMatch(path: "a/b/c/d/e", pattern: "**/b/**/d/**"), "testComplex: **/b/**/d/** should match a/b/c/d/e")
810:         assert(globMatch(path: "src/test/unit/utils", pattern: "**/test/**/utils"), "testComplex: **/test/**/utils should match src/test/unit/utils")
811:         
812:         // Real-world patterns
813:         assert(globMatch(path: "Tests/Unit/Test.swift", pattern: "Tests/**/*.swift"), "testComplex: Tests/**/*.swift should match Tests/Unit/Test.swift")
814:         assert(globMatch(path: "Tests/Integration/UI/Test.swift", pattern: "Tests/**/*.swift"), "testComplex: Tests/**/*.swift should match deeply nested test")
815:         
816:         // Xcode project patterns
817:         assert(globMatch(path: "MyApp.xcodeproj/project.pbxproj", pattern: "*.xcodeproj/*.pbxproj"), "testComplex: *.xcodeproj/*.pbxproj should match")
818:         assert(!globMatch(path: "MyApp.xcodeproj/project.xcworkspace", pattern: "*.xcodeproj/*.pbxproj"), "testComplex: *.xcodeproj/*.pbxproj should NOT match .xcworkspace")
819: 
820:         // MARK: Dotfiles
821:         assert(globMatch(path: ".gitignore", pattern: ".gitignore"), "testDotFiles: .gitignore should match")
822:         assert(globMatch(path: ".env", pattern: ".*"), "testDotFiles: .* should match .env")
823:         assert(globMatch(path: ".swiftlint.yml", pattern: ".*"), "testDotFiles: .* should match .swiftlint.yml")
824:         assert(globMatch(path: ".github/workflows/ci.yml", pattern: ".github/**"), "testDotFiles: .github/** should match")
825:         assert(!globMatch(path: "gitignore", pattern: ".gitignore"), "testDotFiles: .gitignore should NOT match gitignore (no dot)")
826: 
827:         return (passed, failed, failures)
828:     }
829: }
830: 
831: // MARK: - Line indexing helper
832: 
833: /// LineIndex is internal to allow testing while being encapsulated within SearchManager
834: internal struct LineIndex {
835:     private let text: String
836:     private let nsText: NSString
837:     // line start offsets in UTF16
838:     private var lineStarts: [Int] = [0]
839:     private var lines: [String] = []
840: 
841:     init(_ text: String) {
842:         self.text = text
843:         self.nsText = text as NSString
844: 
845:         // Build lineStarts and cache line strings.
846:         // Use NSString lineRange(for:) to be safe with various newline types.
847:         var idx = 0
848:         var currentLine = 1
849:         while idx < nsText.length {
850:             let r = nsText.lineRange(for: NSRange(location: idx, length: 0))
851:             let lineStr = nsText.substring(with: r).trimmingCharacters(in: CharacterSet.newlines)
852:             if lines.count < currentLine { lines.append(lineStr) } else { lines[currentLine - 1] = lineStr }
853: 
854:             idx = NSMaxRange(r)
855:             if idx < nsText.length {
856:                 lineStarts.append(idx)
857:                 currentLine += 1
858:             }
859:         }
860:         if nsText.length == 0 {
861:             lines = [""]
862:             lineStarts = [0]
863:         } else if lines.isEmpty {
864:             // single line without newline
865:             lines = [text]
866:             lineStarts = [0]
867:         }
868:     }
869: 
870:     func lineAndColumn(utf16Offset: Int) -> (line: Int, column: Int) {
871:         // Binary search lineStarts to find last start <= offset.
872:         var lo = 0
873:         var hi = lineStarts.count - 1
874:         while lo <= hi {
875:             let mid = (lo + hi) / 2
876:             let v = lineStarts[mid]
877:             if v == utf16Offset {
878:                 return (mid + 1, 1)
879:             } else if v < utf16Offset {
880:                 lo = mid + 1
881:             } else {
882:                 hi = mid - 1
883:             }
884:         }
885:         let lineIndex = max(hi, 0)
886:         let lineStart = lineStarts[lineIndex]
887:         let col = max(utf16Offset - lineStart, 0) + 1
888:         return (lineIndex + 1, col)
889:     }
890: 
891:     func lineText(line: Int) -> String {
892:         let i = max(1, line) - 1
893:         if i >= 0 && i < lines.count { return lines[i] }
894:         return ""
895:     }
896:     
897:     /// Internal accessor for testing binary search behavior
898:     internal var lineStartOffsets: [Int] { lineStarts }
899:     internal var lineCount: Int { lines.count }
900:     internal var allLines: [String] { lines }
901: }
902: 


❌ API Error (iteration 10): All slots exhausted after session terminated
