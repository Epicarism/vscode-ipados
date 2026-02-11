# Agent: opus-feature-matrix
**Status:** done
**Tokens:** 1,530
**Cost:** $0.0000
**Time:** 2026-02-11T01:17:08.100Z

## Task
AUDIT: Create a comprehensive FEATURE MATRIX for VSCodeiPadOS. Categories: 1) Editor features (syntax highlighting, autocomplete, folding, multi-cursor, etc) 2) File management 3) Git integration 4) SSH/Remote 5) UI/UX (themes, split view, tabs) 6) Search/Replace 7) Terminal. For each: status (working/partial/broken/missing), file locations.

## Response
I'll systematically audit the codebase to create a comprehensive feature matrix. Let me start by exploring the project structure.

>>>TOOL list_dir
{"path": "."}
>>>END

I'll systematically explore the codebase to build a comprehensive feature matrix. Let me start by examining the project structure.

>>>TOOL list_dir
{"path": "VSCodeiPadOS"}
>>>END

>>>TOOL list_dir
{"path": "Views"}
>>>END

>>>TOOL list_dir
{"path": "Services"}
>>>END

>>>TOOL list_dir
{"path": "Models"}
>>>END

---

## 🔧 TOOL RESULTS

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

---

[list_dir]
📁 Views/
📁 Editor/
📁 Panels/
(cached)

---

[list_dir]
📁 Services/
📁 OnDevice/
(cached)

---

[list_dir]
📁 Models/
   (empty directory)


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

---

[list_dir]
📁 Views/Panels/
   RunnerWarningView.swift
   TerminalView.swift_patch1
   TerminalView.swift_patch2

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


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Commands"}
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

---

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Commands/
   AppCommands.swift
   AppCommands.swift.bak


>>>TOOL list_dir
{"path": "Views/Editor"}
>>>END

>>>TOOL list_dir
{"path": "Views/Panels"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor"}
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

[read_file]
Error reading file: cannot open file:///Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS/VSCodeiPadOS/Views/Editor. Detail: Unable to read file '/Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS/VSCodeiPadOS/Views/Editor' (Error: Unable to read file '/Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS/VSCodeiPadOS/Views/Editor' that is actually a directory)


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views"}
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


Let me read the key service and view files to understand feature status.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/AutocompleteManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift"}
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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (lines 1-931 of 931)
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
95:         // If we detect a declaration/function/control-flow whose opening brace is on a later line,
96:         // we mark that brace line so it won't be treated as a standalone generic block.
97:         var braceLinesClaimed: Set<Int> = []
98: 
99:         // Used to prevent duplicate regions for grouped constructs (imports, // comments)
100:         var previousNonEmptyWasImport = false
101:         var previousNonEmptyWasSingleLineComment = false
102:         
103:         for (index, line) in lines.enumerated() {
104:             let trimmed = line.trimmingCharacters(in: .whitespaces)
105:             let leadingWhitespace = line.prefix { $0 == " " || $0 == "\t" }.count
106:             
107:             // Skip empty lines for most detections
108:             guard !trimmed.isEmpty else { continue }
109: 
110:             // MARK: - Close blocks BEFORE opening new ones (handles "} else {" correctly)
111:             if trimmed.hasPrefix("}") {
112:                 // Count consecutive leading '}' so we can pop multiple blocks for lines like "}}"
113:                 let closeCount = max(1, trimmed.prefix { $0 == "}" }.count)
114:                 for _ in 0..<closeCount {
115:                     if let lastBlock = blockStack.popLast() {
116:                         if index - lastBlock.startLine > 1 {
117:                             regions.append(FoldRegion(
118:                                 startLine: lastBlock.startLine,
119:                                 endLine: index,
120:                                 type: lastBlock.type,
121:                                 label: lastBlock.label
122:                             ))
123:                         }
124:                     }
125:                 }
126:             }
127:             
128:             // MARK: - Region Detection (#region, #pragma mark, MARK:)
129:             if let label = detectRegionStart(trimmed) {
130:                 regionStack.append((index, label))
131:             } else if detectRegionEnd(trimmed) {
132:                 if let region = regionStack.popLast() {
133:                     if index - region.startLine > 1 {
134:                         regions.append(FoldRegion(
135:                             startLine: region.startLine,
136:                             endLine: index,
137:                             type: .region,
138:                             label: region.label
139:                         ))
140:                     }
141:                 }
142:             }
143:             
144:             // MARK: - Import Statement Detection (group consecutive imports once)
145:             if trimmed.hasPrefix("import ") {
146:                 if !previousNonEmptyWasImport {
147:                     let importEnd = findConsecutiveImports(from: index, in: lines)
148:                     if importEnd > index {
149:                         regions.append(FoldRegion(
150:                             startLine: index,
151:                             endLine: importEnd,
152:                             type: .importStatement,
153:                             label: "Imports"
154:                         ))
155:                     }
156:                 }
157:                 previousNonEmptyWasImport = true
158:             } else {
159:                 previousNonEmptyWasImport = false
160:             }
161:             
162:             // MARK: - Comment Detection
163:             if detectCommentStart(trimmed) {
164:                 commentStack.append((index, true))
165:                 previousNonEmptyWasSingleLineComment = false
166:             } else if trimmed.starts(with: "//") {
167:                 // Only create a fold region at the start of a consecutive // block
168:                 if !previousNonEmptyWasSingleLineComment {
169:                     let commentEnd = findConsecutiveComments(from: index, in: lines)
170:                     if commentEnd > index {
171:                         regions.append(FoldRegion(
172:                             startLine: index,
173:                             endLine: commentEnd,
174:                             type: .comment,
175:                             label: "Comment"
176:                         ))
177:                     }
178:                 }
179:                 previousNonEmptyWasSingleLineComment = true
180:             } else if detectCommentEnd(trimmed) {
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
261:         
262:         self.foldRegions = regions
263:         
264:         // Store regions in the per-file dictionary
265:         if let fileId = currentFileId {
266:             foldRegionsByFile[fileId] = regions
267:         }
268:         
269:         // Restore previous fold state for this file
270:         if let filePath = filePath {
271:             restoreFoldState(for: filePath)
272:         }
273:         
274:         updateCollapsedLines()
275:     }
276:     
277:     // MARK: - Detection Helper Methods
278:     
279:     private func detectRegionStart(_ line: String) -> String? {
280:         // C# / VS style regions
281:         if line.hasPrefix("#region") {
282:             let components = line.components(separatedBy: "#region")
283:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Region"
284:         }
285:         // Objective-C pragma marks
286:         if line.hasPrefix("#pragma mark") {
287:             let components = line.components(separatedBy: "#pragma mark")
288:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
289:         }
290:         // Swift MARK comments
291:         if line.contains("MARK:") {
292:             let components = line.components(separatedBy: "MARK:")
293:             return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
294:         }
295:         // TODO/FIXME regions
296:         if line.contains("TODO:") {
297:             let components = line.components(separatedBy: "TODO:")
298:             return "TODO: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
299:         }
300:         if line.contains("FIXME:") {
301:             let components = line.components(separatedBy: "FIXME:")
302:             return "FIXME: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
303:         }
304:         return nil
305:     }
306:     
307:     private func detectRegionEnd(_ line: String) -> Bool {
308:         return line.hasPrefix("#endregion") || 
309:                line == "// MARK: -" ||
310:                line.hasPrefix("#pragma mark -")
311:     }
312:     
313:     private func detectCommentStart(_ line: String) -> Bool {
314:         return line.hasPrefix("/*") && !line.contains("*/")
315:     }
316:     
317:     private func detectCommentEnd(_ line: String) -> Bool {
318:         return line.contains("*/") && !line.hasPrefix("/*")
319:     }
320:     
321:     private func findConsecutiveImports(from startIndex: Int, in lines: [String]) -> Int {
322:         var endIndex = startIndex
323:         for i in startIndex..<lines.count {
324:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
325:             if trimmed.hasPrefix("import ") {
326:                 endIndex = i
327:             } else if !trimmed.isEmpty {
328:                 break
329:             }
330:         }
331:         return endIndex
332:     }
333:     
334:     private func findConsecutiveComments(from startIndex: Int, in lines: [String]) -> Int {
335:         var endIndex = startIndex
336:         for i in startIndex..<lines.count {
337:             let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
338:             if trimmed.starts(with: "//") {
339:                 endIndex = i
340:             } else if !trimmed.isEmpty {
341:                 break
342:             }
343:         }
344:         return endIndex
345:     }
346:     
347:     private func detectDeclaration(_ line: String) -> (type: FoldRegion.FoldType, label: String)? {
348:         func matchName(pattern: String) -> String? {
349:             guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
350:             guard let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
351:                   match.numberOfRanges >= 2,
352:                   let r = Range(match.range(at: 1), in: line)
353:             else { return nil }
354:             return String(line[r])
355:         }
356: 
357:         // Allow leading attributes like "@MainActor", "@available(...)"
358:         // Allow common modifiers in any order (best-effort).
359:         let prefix = #"^(?:\s*@\w+(?:\([^\)]*\))?\s+)*(?:\s*(?:public|private|internal|fileprivate|open|final|indirect|lazy|static|override|mutating|nonmutating)\s+)*"#
360: 
361:         // IMPORTANT: avoid treating "class func"/"class var" as a type declaration.
362:         if let name = matchName(pattern: prefix + #"class\s+(?!func\b|var\b|let\b)([A-Za-z_]\w*)"#) {
363:             return (.classOrStruct, name)
364:         }
365: 
366:         // Actor (Swift concurrency) – fold like a class/struct
367:         if let name = matchName(pattern: prefix + #"actor\s+([A-Za-z_]\w*)"#) {
368:             return (.classOrStruct, name)
369:         }
370: 
371:         if let name = matchName(pattern: prefix + #"struct\s+([A-Za-z_]\w*)"#) {
372:             return (.classOrStruct, name)
373:         }
374: 
375:         if let name = matchName(pattern: prefix + #"enum\s+([A-Za-z_]\w*)"#) {
376:             return (.enumDeclaration, name)
377:         }
378: 
379:         if let name = matchName(pattern: prefix + #"protocol\s+([A-Za-z_]\w*)"#) {
380:             return (.protocolDeclaration, name)
381:         }
382: 
383:         // Extensions can include dotted names (Foo.Bar)
384:         if let name = matchName(pattern: prefix + #"extension\s+([A-Za-z_][A-Za-z0-9_\.]*)"#) {
385:             return (.extension, name)
386:         }
387: 
388:         return nil
389:     }
390:     
391:     private func detectFunction(_ line: String) -> String? {
392:         // Function detection with visibility modifiers
393:         let visibilityKeywords = ["public", "private", "internal", "fileprivate", "static", "class", "override", "final", "mutating", "convenience"]
394:         
395:         // Check for 'func' keyword
396:         if line.contains("func ") {
397:             // Extract function name
398:             let funcPattern = "func\\s+(\\w+)"
399:             if let regex = try? NSRegularExpression(pattern: funcPattern),
400:                let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
401:                let nameRange = Range(match.range(at: 1), in: line) {
402:                 let functionName = String(line[nameRange])
403:                 // Check for parameters to create label
404:                 if let parenStart = line.firstIndex(of: "("), let parenEnd = line.firstIndex(of: ")") {
405:                     let params = String(line[parenStart...parenEnd])
406:                     return "\(functionName)\(params)"
407:                 }
408:                 return functionName
409:             }
410:         }
411:         
412:         // Init detection
413:         if let initName = extractName(from: line, prefix: "init", visibility: visibilityKeywords) {
414:             return "\(initName)"
415:         }
416:         
417:         // Deinit detection
418:         if line.contains("deinit") {
419:             return "deinit"
420:         }
421:         
422:         // Computed property with get/set
423:         if line.hasPrefix("var ") && (line.contains("{") || line.contains("get")) {
424:             if let varName = extractVariableName(from: line) {
425:                 return varName
426:             }
427:         }
428:         
429:         return nil
430:     }
431:     
432:     private func detectControlFlow(_ line: String) -> String? {
433:         let controlFlowPatterns = [
434:             ("if ", "if"),
435:             ("guard ", "guard"),
436:             ("else if", "else if"),
437:             ("else", "else"),
438:             ("for ", "for"),
439:             ("while ", "while"),
440:             ("repeat", "repeat"),
441:             ("switch ", "switch"),
442:             ("case ", "case"),
443:             ("default:", "default"),
444:             ("do ", "do"),
445:             ("catch", "catch")
446:         ]
447:         
448:         for (pattern, label) in controlFlowPatterns {
449:             if line.contains(pattern) {
450:                 return label
451:             }
452:         }
453:         return nil
454:     }
455:     
456:     private func extractName(from line: String, prefix: String, visibility: [String]) -> String? {
457:         var components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
458:         
459:         // Remove visibility modifiers
460:         components = components.filter { !visibility.contains($0) }
461:         
462:         // Find prefix index
463:         if let prefixIndex = components.firstIndex(where: { $0 == prefix }),
464:            prefixIndex + 1 < components.count {
465:             var name = components[prefixIndex + 1]
466:             // Remove colons and other trailing characters
467:             name = name.components(separatedBy: ":").first ?? name
468:             name = name.components(separatedBy: "<").first ?? name
469:             name = name.components(separatedBy: ":").first ?? name
470:             return name
471:         }
472:         return nil
473:     }
474:     
475:     private func extractVariableName(from line: String) -> String? {
476:         let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
477:         if components.count >= 2, components[0] == "var" {
478:             var varName = components[1]
479:             varName = varName.components(separatedBy: ":").first ?? varName
480:             varName = varName.components(separatedBy: "=").first ?? varName
481:             return varName
482:         }
483:         return nil
484:     }
485:     
486:     private func findOpeningBrace(from startIndex: Int, in lines: [String]) -> Int? {
487:         for i in startIndex..<min(startIndex + 5, lines.count) {
488:             if lines[i].contains("{") {
489:                 return i
490:             }
491:         }
492:         return nil
493:     }
494:     
495:     private func isDeclarationLine(_ line: String) -> Bool {
496:         let keywords = ["class", "struct", "enum", "protocol", "extension", "init", "func"]
497:         return keywords.contains { line.contains("\($0) ") }
498:     }
499:     
500:     private func isFunctionLine(_ line: String) -> Bool {
501:         return line.contains("func ") || line.contains("init ")
502:     }
503:     
504:     private func detectBlockEnd(_ line: String, leadingWhitespace: Int) -> Bool {
505:         return (line.hasPrefix("}") || line.starts(with: "}")) && 
506:                (line.trimmingCharacters(in: .whitespaces) == "}" || 
507:                 line.trimmingCharacters(in: .whitespaces).hasPrefix("}"))
508:     }
509:     
510:     // MARK: - Fold State Persistence
511:     
512:     /// Saves the current fold state to UserDefaults
513:     func saveFoldState(for filePath: String) {
514:         let key = UserDefaultsKeys.foldStatePrefix + filePath
515:         
516:         // Use regions from the dictionary if available
517:         let regionsToSave: [FoldRegion]
518:         if let fileId = currentFileId, let storedRegions = foldRegionsByFile[fileId] {
519:             regionsToSave = storedRegions
520:         } else {
521:             regionsToSave = foldRegions
522:         }
523:         
524:         // Create a simplified representation for storage
525:         let foldState = regionsToSave.map { FoldStateEntry(startLine: $0.startLine, isFolded: $0.isFolded) }
526:         
527:         if let data = try? JSONEncoder().encode(foldState) {
528:             UserDefaults.standard.set(data, forKey: key)
529:         }
530:     }
531:     
532:     /// Restores fold state from UserDefaults
533:     private func restoreFoldState(for filePath: String) {
534:         let key = UserDefaultsKeys.foldStatePrefix + filePath
535:         
536:         guard let data = UserDefaults.standard.data(forKey: key),
537:               let foldState = try? JSONDecoder().decode([FoldStateEntry].self, from: data) else {
538:             return
539:         }
540:         
541:         // Apply saved state to current regions
542:         for savedState in foldState {
543:             if let index = foldRegions.firstIndex(where: { $0.startLine == savedState.startLine }) {
544:                 foldRegions[index].isFolded = savedState.isFolded
545:             }
546:         }
547:     }
548:     
549:     /// Helper struct for persisting fold state
550:     private struct FoldStateEntry: Codable {
551:         let startLine: Int
552:         let isFolded: Bool
553:     }
554:     
555:     /// Clears fold state for a specific file
556:     func clearFoldState(for filePath: String) {
557:         let key = UserDefaultsKeys.foldStatePrefix + filePath
558:         UserDefaults.standard.removeObject(forKey: key)
559:     }
560:     
561:     /// Clears all fold states
562:     func clearAllFoldStates() {
563:         let defaults = UserDefaults.standard
564:         let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(UserDefaultsKeys.foldStatePrefix) }
565:         for key in keys {
566:             defaults.removeObject(forKey: key)
567:         }
568:     }
569:     
570:     // MARK: - Fold Operations
571:     
572:     /// Toggles the fold state at a specific line
573:     func toggleFold(at line: Int) {
574:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
575:             foldRegions[regionIndex].isFolded.toggle()
576:             updateCollapsedLines()
577:             
578:             // Save state after toggling
579:             if let filePath = currentFilePath {
580:                 saveFoldState(for: filePath)
581:             }
582:         }
583:     }
584:     
585:     /// Expands a folded region
586:     func expandRegion(at line: Int) {
587:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
588:             foldRegions[regionIndex].isFolded = false
589:             updateCollapsedLines()
590:             
591:             if let filePath = currentFilePath {
592:                 saveFoldState(for: filePath)
593:             }
594:         }
595:     }
596:     
597:     /// Collapses a region
598:     func collapseRegion(at line: Int) {
599:         if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
600:             foldRegions[regionIndex].isFolded = true
601:             updateCollapsedLines()
602:             
603:             if let filePath = currentFilePath {
604:                 saveFoldState(for: filePath)
605:             }
606:         }
607:     }
608:     
609:     /// Expands all folded regions
610:     func expandAll() {
611:         for index in foldRegions.indices {
612:             foldRegions[index].isFolded = false
613:         }
614:         updateCollapsedLines()
615:         
616:         if let filePath = currentFilePath {
617:             saveFoldState(for: filePath)
618:         }
619:     }
620:     
621:     /// Folds the region containing the given cursor line
622:     func foldAtLine(_ cursorLine: Int) {
623:         // Find the innermost region containing this line
624:         if let region = foldRegions.filter({ 
625:             cursorLine >= $0.startLine && cursorLine <= $0.endLine && !$0.isFolded
626:         }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
627:             collapseRegion(at: region.startLine)
628:         }
629:     }
630:     
631:     /// Unfolds the region containing the given cursor line
632:     func unfoldAtLine(_ cursorLine: Int) {
633:         // Find any folded region that starts at or contains this line
634:         if let region = foldRegions.first(where: { 
635:             $0.isFolded && ($0.startLine == cursorLine || (cursorLine >= $0.startLine && cursorLine <= $0.endLine))
636:         }) {
637:             expandRegion(at: region.startLine)
638:         }
639:     }
640:     
641:     /// Toggle fold at cursor line - convenience method
642:     func toggleFoldAtLine(_ cursorLine: Int) {
643:         // First check if we're on a fold start line
644:         if let region = foldRegions.first(where: { $0.startLine == cursorLine }) {
645:             toggleFold(at: region.startLine)
646:             return
647:         }
648:         
649:         // Otherwise find the innermost region containing this line
650:         if let region = foldRegions.filter({ 
651:             cursorLine >= $0.startLine && cursorLine <= $0.endLine
652:         }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
653:             toggleFold(at: region.startLine)
654:         }
655:     }
656:     
657:     // MARK: - Legacy/Convenience Methods (for keyboard shortcuts)
658:     
659:     /// Folds at the current line (uses line 0 as fallback - caller should use foldAtLine(_:) with actual cursor)
660:     func foldCurrentLine() {
661:         // This is called from keyboard shortcuts - fold at line 0 or first available region
662:         if let firstUnfolded = foldRegions.first(where: { !$0.isFolded }) {
663:             collapseRegion(at: firstUnfolded.startLine)
664:         }
665:     }
666:     
667:     /// Unfolds at the current line (uses line 0 as fallback - caller should use unfoldAtLine(_:) with actual cursor)
668:     func unfoldCurrentLine() {
669:         // This is called from keyboard shortcuts - unfold first folded region
670:         if let firstFolded = foldRegions.first(where: { $0.isFolded }) {
671:             expandRegion(at: firstFolded.startLine)
672:         }
673:     }
674:     
675:     /// Collapses all foldable regions
676:     func collapseAll() {
677:         for index in foldRegions.indices {
678:             foldRegions[index].isFolded = true
679:         }
680:         updateCollapsedLines()
681:         
682:         if let filePath = currentFilePath {
683:             saveFoldState(for: filePath)
684:         }
685:     }
686:     
687:     /// Collapses all regions of a specific type
688:     func collapseAll(ofType type: FoldRegion.FoldType) {
689:         for index in foldRegions.indices {
690:             if foldRegions[index].type == type {
691:                 foldRegions[index].isFolded = true
692:             }
693:         }
694:         updateCollapsedLines()
695:         
696:         if let filePath = currentFilePath {
697:             saveFoldState(for: filePath)
698:         }
699:     }
700:     
701:     /// Expands all regions of a specific type
702:     func expandAll(ofType type: FoldRegion.FoldType) {
703:         for index in foldRegions.indices {
704:             if foldRegions[index].type == type {
705:                 foldRegions[index].isFolded = false
706:             }
707:         }
708:         updateCollapsedLines()
709:         
710:         if let filePath = currentFilePath {
711:             saveFoldState(for: filePath)
712:         }
713:     }
714:     
715:     // MARK: - Query Methods
716:     
717:     /// Checks if a line is foldable
718:     func isFoldable(line: Int) -> Bool {
719:         return foldRegions.contains { $0.startLine == line }
720:     }
721:     
722:     /// Checks if a line is currently folded (for the currently active file in `foldRegions`)
723:     func isLineFolded(line: Int) -> Bool {
724:         return collapsedLines.contains(line)
725:     }
726: 
727:     /// Checks if a line should be hidden for a specific file (does not rely on `collapsedLines`)
728:     func isLineFolded(fileId: String, line: Int) -> Bool {
729:         guard let regions = foldRegionsByFile[fileId] else { return false }
730:         for region in regions where region.isFolded {
731:             if line > region.startLine && line <= region.endLine {
732:                 return true
733:             }
734:         }
735:         return false
736:     }
737:     
738:     /// Checks if a region at a given line is folded
739:     func isRegionFolded(at line: Int) -> Bool {
740:         return foldRegions.first { $0.startLine == line }?.isFolded ?? false
741:     }
742:     
743:     /// Gets the fold region at a specific line
744:     func getRegion(at line: Int) -> FoldRegion? {
745:         return foldRegions.first { $0.startLine == line }
746:     }
747:     
748:     /// Gets all fold regions of a specific type
749:     func getRegions(ofType type: FoldRegion.FoldType) -> [FoldRegion] {
750:         return foldRegions.filter { $0.type == type }
751:     }
752:     
753:     // MARK: - File-Aware Methods
754:     
755:     /// Checks if a line is foldable for a specific file
756:     func isFoldable(fileId: String, line: Int) -> Bool {
757:         guard let regions = foldRegionsByFile[fileId] else { return false }
758:         return regions.contains { $0.startLine == line }
759:     }
760:     
761:     /// Checks if a region at a given line is folded for a specific file
762:     func isFolded(fileId: String, line: Int) -> Bool {
763:         guard let regions = foldRegionsByFile[fileId] else { return false }
764:         return regions.first { $0.startLine == line }?.isFolded ?? false
765:     }
766:     
767:     /// Toggles the fold state at a specific line for a specific file
768:     func toggleFold(fileId: String, line: Int) {
769:         guard var regions = foldRegionsByFile[fileId] else { return }
770:         
771:         if let regionIndex = regions.firstIndex(where: { $0.startLine == line }) {
772:             regions[regionIndex].isFolded.toggle()
773:             foldRegionsByFile[fileId] = regions
774:             
775:             // Update current file regions if this is the active file
776:             if fileId == currentFileId {
777:                 self.foldRegions = regions
778:                 updateCollapsedLines()
779:             } else {
780:                 // Ensure SwiftUI updates for gutters rendering using file-aware queries.
781:                 objectWillChange.send()
782:             }
783:             
784:             // Save state after toggling
785:             saveFoldState(for: fileId)
786:         }
787:     }
788:     
789:     /// Gets fold regions for a specific file
790:     func getFoldRegions(for fileId: String) -> [FoldRegion] {
791:         return foldRegionsByFile[fileId] ?? []
792:     }
793:     
794:     /// Clears fold regions for a specific file from memory
795:     func clearFoldRegions(for fileId: String) {
796:         foldRegionsByFile.removeValue(forKey: fileId)
797:     }
798:     
799:     /// Clears all fold regions from memory
800:     func clearAllFoldRegions() {
801:         foldRegionsByFile.removeAll()
802:     }
803:     
804:     /// Gets folded line ranges for text hiding
805:     /// Returns an array of closed ranges representing the line numbers that should be hidden
806:     func getFoldedLineRanges() -> [ClosedRange<Int>] {
807:         var ranges: [ClosedRange<Int>] = []
808:         
809:         // Sort regions by start line to ensure proper ordering
810:         let sortedRegions = foldRegions.sorted { $0.startLine < $1.startLine }
811:         
812:         for region in sortedRegions where region.isFolded {
813:             ranges.append((region.startLine + 1)...region.endLine)
814:         }
815:         
816:         return ranges
817:     }
818:     
819:     /// Gets the total count of folded lines
820:     func getFoldedLineCount() -> Int {
821:         return collapsedLines.count
822:     }
823:     
824:     /// Gets a summary of fold statistics
825:     func getFoldStatistics() -> FoldStatistics {
826:         let totalCount = foldRegions.count
827:         let foldedCount = foldRegions.filter { $0.isFolded }.count
828:         
829:         var typeBreakdown: [FoldRegion.FoldType: Int] = [:]
830:         for region in foldRegions {
831:             typeBreakdown[region.type, default: 0] += 1
832:         }
833:         
834:         return FoldStatistics(
835:             totalRegions: totalCount,
836:             foldedRegions: foldedCount,
837:             typeBreakdown: typeBreakdown
838:         )
839:     }
840:     
841:     // MARK: - Private Methods
842:     
843:     private func updateCollapsedLines() {
844:         collapsedLines.removeAll()
845:         
846:         for region in foldRegions where region.isFolded {
847:             for line in (region.startLine + 1)...region.endLine {
848:                 collapsedLines.insert(line)
849:             }
850:         }
851:     }
852: }
853: 
854: // MARK: - Fold Statistics
855: struct FoldStatistics {
856:     let totalRegions: Int
857:     let foldedRegions: Int
858:     let typeBreakdown: [FoldRegion.FoldType: Int]
859:     
860:     var expansionPercentage: Double {
861:         guard totalRegions > 0 else { return 0 }
862:         return Double(foldedCount) / Double(totalRegions) * 100
863:     }
864:     
865:     var foldedCount: Int {
866:         return foldedRegions
867:     }
868:     
869:     var expandedCount: Int {
870:         return totalRegions - foldedRegions
871:     }
872: }
873: 
874: // MARK: - Fold Button View
875: struct FoldButton: View {
876:     let line: Int
877:     let isExpanded: Bool
878:     let foldType: FoldRegion.FoldType?
879:     let action: () -> Void
880:     
881:     var body: some View {
882:         Button(action: action) {
883:             ZStack {
884:                 if let type = foldType {
885:                     Text(type.icon)
886:                         .font(.system(size: 8, weight: .bold))
887:                         .foregroundColor(.blue.opacity(0.6))
888:                 }
889:                 
890:                 Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
891:                     .font(.system(size: 10, weight: .semibold))
892:                     .foregroundColor(.primary.opacity(0.7))
893:             }
894:             .frame(width: 18, height: 18)
895:             .background(isExpanded ? Color.secondary.opacity(0.1) : Color.secondary.opacity(0.2))
896:             .cornerRadius(4)
897:         }
898:         .buttonStyle(PlainButtonStyle())
899:     }
900: }
901: 
902: // MARK: - Line Number View with Folding
903: struct LineNumberViewWithFolding: View {
904:     let lineNumber: Int
905:     let isFoldable: Bool
906:     let isExpanded: Bool
907:     let foldType: FoldRegion.FoldType?
908:     let onFoldTap: () -> Void
909:     
910:     var body: some View {
911:         HStack(spacing: 4) {
912:             if isFoldable {
913:                 FoldButton(
914:                     line: lineNumber,
915:                     isExpanded: isExpanded,
916:                     foldType: foldType,
917:                     action: onFoldTap
918:                 )
919:             } else {
920:                 Color.clear
921:                     .frame(width: 18, height: 18)
922:             }
923:             
924:             Text("\(lineNumber + 1)")
925:                 .font(.system(.caption, design: .monospaced))
926:                 .foregroundColor(.gray)
927:                 .frame(minWidth: 30, alignment: .trailing)
928:         }
929:     }
930: }
931: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/MultiCursor.swift (lines 1-283 of 283)
────────────────────────────────────────
1: //
2: //  MultiCursor.swift
3: //  VSCodeiPadOS
4: //
5: //  Multi-cursor editing support
6: //
7: 
8: import Foundation
9: import UIKit
10: 
11: // MARK: - Cursor
12: 
13: /// Represents a single cursor with optional selection
14: struct Cursor: Identifiable, Equatable {
15:     let id: UUID
16:     
17:     /// Character offset in the text
18:     var position: Int
19:     
20:     /// Selection anchor (if different from position, text is selected)
21:     var anchor: Int?
22:     
23:     /// Whether this is the primary cursor
24:     var isPrimary: Bool
25:     
26:     init(position: Int, anchor: Int? = nil, isPrimary: Bool = false) {
27:         self.id = UUID()
28:         self.position = position
29:         self.anchor = anchor
30:         self.isPrimary = isPrimary
31:     }
32:     
33:     /// The selection range if text is selected
34:     var selectionRange: NSRange? {
35:         guard let anchor = anchor, anchor != position else { return nil }
36:         let start = min(position, anchor)
37:         let length = abs(position - anchor)
38:         return NSRange(location: start, length: length)
39:     }
40:     
41:     /// Whether this cursor has a selection
42:     var hasSelection: Bool {
43:         guard let anchor = anchor else { return false }
44:         return anchor != position
45:     }
46:     
47:     /// The selected text given the full text
48:     func selectedText(in text: String) -> String? {
49:         guard let range = selectionRange,
50:               let swiftRange = Range(range, in: text) else { return nil }
51:         return String(text[swiftRange])
52:     }
53: }
54: 
55: // MARK: - MultiCursorState
56: 
57: /// Manages multiple cursors in the editor
58: class MultiCursorState: ObservableObject {
59:     @Published var cursors: [Cursor] = []
60:     
61:     /// The primary cursor (first one or the explicitly marked one)
62:     var primaryCursor: Cursor? {
63:         cursors.first(where: { $0.isPrimary }) ?? cursors.first
64:     }
65:     
66:     /// Whether we're in multi-cursor mode
67:     var isMultiCursor: Bool {
68:         cursors.count > 1
69:     }
70:     
71:     init() {
72:         // Start with a single cursor at position 0
73:         cursors = [Cursor(position: 0, isPrimary: true)]
74:     }
75:     
76:     // MARK: - Cursor Management
77:     
78:     /// Resets to a single cursor at the given position
79:     func reset(to position: Int) {
80:         cursors = [Cursor(position: position, isPrimary: true)]
81:     }
82:     
83:     /// Adds a cursor at the given position (Option+Click)
84:     func addCursor(at position: Int) {
85:         // Don't add duplicate cursors at the same position
86:         guard !cursors.contains(where: { $0.position == position && $0.anchor == nil }) else { return }
87:         
88:         // Remove primary from existing cursors
89:         cursors = cursors.map { cursor in
90:             var updated = cursor
91:             updated.isPrimary = false
92:             return updated
93:         }
94:         
95:         // Add new primary cursor
96:         cursors.append(Cursor(position: position, isPrimary: true))
97:         sortCursors()
98:     }
99:     
100:     /// Adds a cursor with selection
101:     func addCursorWithSelection(position: Int, anchor: Int) {
102:         // Remove primary from existing cursors
103:         cursors = cursors.map { cursor in
104:             var updated = cursor
105:             updated.isPrimary = false
106:             return updated
107:         }
108:         
109:         cursors.append(Cursor(position: position, anchor: anchor, isPrimary: true))
110:         sortCursors()
111:     }
112:     
113:     /// Removes a cursor at the given position
114:     func removeCursor(at position: Int) {
115:         guard cursors.count > 1 else { return } // Keep at least one cursor
116:         cursors.removeAll { $0.position == position }
117:         
118:         // Ensure we have a primary cursor
119:         if !cursors.contains(where: { $0.isPrimary }), !cursors.isEmpty {
120:             cursors[0].isPrimary = true
121:         }
122:     }
123:     
124:     /// Updates the position of all cursors
125:     func updatePositions(_ transform: (Int) -> Int) {
126:         cursors = cursors.map { cursor in
127:             var updated = cursor
128:             updated.position = transform(cursor.position)
129:             if let anchor = cursor.anchor {
130:                 updated.anchor = transform(anchor)
131:             }
132:             return updated
133:         }
134:     }
135:     
136:     /// Clears all selections but keeps cursors
137:     func clearSelections() {
138:         cursors = cursors.map { cursor in
139:             var updated = cursor
140:             updated.anchor = nil
141:             return updated
142:         }
143:     }
144:     
145:     /// Sort cursors by position
146:     private func sortCursors() {
147:         cursors.sort { $0.position < $1.position }
148:     }
149:     
150:     // MARK: - Text Operations
151:     
152:     /// Insert text at all cursor positions
153:     func insertText(_ text: String, in fullText: inout String) {
154:         // Process from start -> end while tracking how prior edits shift later cursor positions.
155:         let sortedCursors = cursors.sorted { $0.position < $1.position }
156:         var delta = 0
157: 
158:         for cursor in sortedCursors {
159:             guard let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id }) else { continue }
160: 
161:             if let selectionRange = cursor.selectionRange {
162:                 let effectiveLocation = selectionRange.location + delta
163:                 let effectiveRange = NSRange(location: effectiveLocation, length: selectionRange.length)
164: 
165:                 guard let swiftRange = Range(effectiveRange, in: fullText) else { continue }
166: 
167:                 fullText.replaceSubrange(swiftRange, with: text)
168: 
169:                 // Cursor ends after inserted text; selection cleared.
170:                 cursors[cursorIndex].position = effectiveLocation + text.count
171:                 cursors[cursorIndex].anchor = nil
172: 
173:                 delta += (text.count - selectionRange.length)
174:             } else {
175:                 let effectivePosition = cursor.position + delta
176:                 let clamped = min(max(0, effectivePosition), fullText.count)
177:                 let stringIndex = fullText.index(fullText.startIndex, offsetBy: clamped)
178: 
179:                 fullText.insert(contentsOf: text, at: stringIndex)
180: 
181:                 cursors[cursorIndex].position = clamped + text.count
182:                 delta += text.count
183:             }
184:         }
185: 
186:         // Keep state sane if multiple edits collapse cursors onto the same location.
187:         removeDuplicateCursors()
188:     }
189:     
190:     /// Delete text at all cursor positions (backspace)
191:     func deleteBackward(in fullText: inout String) {
192:         let sortedCursors = cursors.sorted { $0.position < $1.position }
193:         var delta = 0
194: 
195:         for cursor in sortedCursors {
196:             guard let cursorIndex = cursors.firstIndex(where: { $0.id == cursor.id }) else { continue }
197: 
198:             if let selectionRange = cursor.selectionRange {
199:                 let effectiveLocation = selectionRange.location + delta
200:                 let effectiveRange = NSRange(location: effectiveLocation, length: selectionRange.length)
201:                 guard let swiftRange = Range(effectiveRange, in: fullText) else { continue }
202: 
203:                 fullText.removeSubrange(swiftRange)
204: 
205:                 cursors[cursorIndex].position = effectiveLocation
206:                 cursors[cursorIndex].anchor = nil
207: 
208:                 delta -= selectionRange.length
209:             } else {
210:                 let effectivePosition = cursor.position + delta
211:                 guard effectivePosition > 0 else { continue }
212: 
213:                 let deleteOffset = effectivePosition - 1
214:                 let deleteIndex = fullText.index(fullText.startIndex, offsetBy: deleteOffset)
215:                 fullText.remove(at: deleteIndex)
216: 
217:                 cursors[cursorIndex].position = deleteOffset
218:                 delta -= 1
219:             }
220:         }
221: 
222:         removeDuplicateCursors()
223:     }
224:     
225:     private func adjustCursorPositions(afterInsertion length: Int) {
226:         // Already handled in insertText
227:     }
228:     
229:     private func removeDuplicateCursors() {
230:         var seen = Set<Int>()
231:         cursors = cursors.filter { cursor in
232:             if seen.contains(cursor.position) {
233:                 return false
234:             }
235:             seen.insert(cursor.position)
236:             return true
237:         }
238:         
239:         // Ensure primary cursor exists
240:         if !cursors.contains(where: { $0.isPrimary }), !cursors.isEmpty {
241:             cursors[0].isPrimary = true
242:         }
243:     }
244: }
245: 
246: // MARK: - Occurrence Finding
247: 
248: extension String {
249:     /// Find all occurrences of a substring
250:     func findAllOccurrences(of searchString: String, caseSensitive: Bool = true) -> [NSRange] {
251:         var ranges: [NSRange] = []
252:         var searchRange = startIndex..<endIndex
253:         let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
254:         
255:         while let range = self.range(of: searchString, options: options, range: searchRange) {
256:             let nsRange = NSRange(range, in: self)
257:             ranges.append(nsRange)
258:             searchRange = range.upperBound..<endIndex
259:         }
260:         
261:         return ranges
262:     }
263:     
264:     /// Find the next occurrence after a given position
265:     func findNextOccurrence(of searchString: String, after position: Int, caseSensitive: Bool = true) -> NSRange? {
266:         guard position < count else { return nil }
267:         let startIdx = index(startIndex, offsetBy: position)
268:         let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
269:         
270:         // Search from current position to end
271:         if let range = self.range(of: searchString, options: options, range: startIdx..<endIndex) {
272:             return NSRange(range, in: self)
273:         }
274:         
275:         // Wrap around: search from beginning to current position
276:         if let range = self.range(of: searchString, options: options, range: startIndex..<startIdx) {
277:             return NSRange(range, in: self)
278:         }
279:         
280:         return nil
281:     }
282: }
283: 

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift (lines 1-352 of 352)
────────────────────────────────────────
1: //
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
101:     let author: String
102:     let date: Date
103:     
104:     var shortSHA: String {
105:         String(id.prefix(7))
106:     }
107: }
108: 
109: struct GitFileChange: Identifiable, Hashable {
110:     let id = UUID()
111:     let path: String
112:     let kind: GitChangeKind
113:     let staged: Bool
114:     
115:     init(path: String, kind: GitChangeKind, staged: Bool = false) {
116:         self.path = path
117:         self.kind = kind
118:         self.staged = staged
119:     }
120: }
121: 
122: struct GitStashEntry: Identifiable, Hashable {
123:     let id = UUID()
124:     let index: Int
125:     let message: String
126:     let branch: String
127: }
128: 
129: // Type alias for compatibility with GitView
130: typealias GitStatusEntry = GitFileChange
131: 
132: // MARK: - Git Manager
133: 
134: @MainActor
135: class GitManager: ObservableObject {
136:     static let shared = GitManager()
137:     
138:     // MARK: - Published State
139:     
140:     @Published var isRepository: Bool = false
141:     @Published var currentBranch: String = "main"
142:     @Published var branches: [GitBranch] = []
143:     @Published var remoteBranches: [GitBranch] = []
144:     @Published var stagedChanges: [GitFileChange] = []
145:     @Published var unstagedChanges: [GitFileChange] = []
146:     @Published var untrackedFiles: [GitFileChange] = []
147:     @Published var recentCommits: [GitCommit] = []
148:     @Published var stashes: [GitStashEntry] = []
149:     @Published var isLoading: Bool = false
150:     @Published var lastError: String?
151:     @Published var aheadCount: Int = 0
152:     @Published var behindCount: Int = 0
153:     
154:     private var workingDirectory: URL?
155:     private var nativeReader: NativeGitReader?
156:     
157:     private init() {}
158:     
159:     // MARK: - Repository Setup
160:     
161:     func setWorkingDirectory(_ url: URL?) {
162:         self.workingDirectory = url
163:         
164:         if let url {
165:             self.nativeReader = NativeGitReader(repositoryURL: url)
166:             self.isRepository = (self.nativeReader != nil)
167:         } else {
168:             self.nativeReader = nil
169:             self.isRepository = false
170:         }
171:         
172:         if isRepository {
173:             Task { await refresh() }
174:         } else {
175:             clearRepository()
176:         }
177:     }
178:     
179:     func clearRepository() {
180:         isRepository = false
181:         currentBranch = "main"
182:         branches = []
183:         remoteBranches = []
184:         stagedChanges = []
185:         unstagedChanges = []
186:         untrackedFiles = []
187:         recentCommits = []
188:         stashes = []
189:         lastError = nil
190:     }
191:     
192:     // MARK: - Git Operations
193:     
194:     func refresh() async {
195:         isLoading = true
196:         defer { isLoading = false }
197:         lastError = nil
198:         
199:         guard let reader = nativeReader else {
200:             lastError = "No git repository found"
201:             return
202:         }
203:         
204:         // Current branch
205:         currentBranch = reader.currentBranch() ?? "HEAD"
206:         
207:         // Branches
208:         let localBranchNames = reader.localBranches()
209:         branches = localBranchNames.map { name in
210:             GitBranch(name: name, isRemote: false, isCurrent: name == currentBranch)
211:         }
212:         
213:         let remoteBranchPairs = reader.remoteBranches()
214:         remoteBranches = remoteBranchPairs.map { (remote, branch) in
215:             GitBranch(name: "\(remote)/\(branch)", isRemote: true, isCurrent: false)
216:         }
217:         
218:         // Status
219:         let fileStatuses = reader.status()
220:         
221:         stagedChanges = fileStatuses.compactMap { status -> GitFileChange? in
222:             guard let staged = status.staged else { return nil }
223:             return GitFileChange(path: status.path, kind: mapStatusType(staged), staged: true)
224:         }
225:         
226:         unstagedChanges = fileStatuses.compactMap { status -> GitFileChange? in
227:             guard let working = status.working else { return nil }
228:             return GitFileChange(path: status.path, kind: mapStatusType(working), staged: false)
229:         }
230:         
231:         untrackedFiles = fileStatuses.compactMap { status -> GitFileChange? in
232:             guard status.working == .untracked else { return nil }
233:             return GitFileChange(path: status.path, kind: .untracked, staged: false)
234:         }
235:         
236:         // Recent commits
237:         let commits = reader.recentCommits(count: 20)
238:         recentCommits = commits.map { commit in
239:             GitCommit(id: commit.sha, message: commit.message, author: commit.author, date: commit.authorDate)
240:         }
241:     }
242:     
243:     private func mapStatusType(_ status: GitStatusType) -> GitChangeKind {
244:         switch status {
245:         case .modified: return .modified
246:         case .added: return .added
247:         case .deleted: return .deleted
248:         case .renamed: return .renamed
249:         case .copied: return .copied
250:         case .untracked: return .untracked
251:         case .ignored: return .ignored
252:         }
253:     }
254:     
255:     /// Build a real diff for a working-copy file against HEAD (offline, using NativeGitReader).
256:     func diffWorkingCopyToHEAD(path: String, kind: GitChangeKind) async -> DiffFile? {
257:         guard let repoURL = workingDirectory else { return nil }
258:         
259:         return await Task.detached {
260:             guard let reader = NativeGitReader(repositoryURL: repoURL) else { return nil }
261:             
262:             let headSha = reader.headSHA()
263:             let oldText = reader.fileContentsString(atPath: path, commitSHA: headSha) ?? ""
264:             
265:             let workingURL = repoURL.appendingPathComponent(path)
266:             let newText = (try? String(contentsOf: workingURL, encoding: .utf8)) ?? ""
267:             
268:             return DiffBuilder.build(
269:                 fileName: path,
270:                 status: kind.rawValue,
271:                 old: oldText,
272:                 new: newText
273:             )
274:         }.value
275:     }
276:     
277:     func stage(file: String) async throws {
278:         throw GitManagerError.sshNotConnected
279:     }
280:     
281:     func stageAll() async throws {
282:         throw GitManagerError.sshNotConnected
283:     }
284:     
285:     func unstage(file: String) async throws {
286:         throw GitManagerError.sshNotConnected
287:     }
288:     
289:     func commit(message: String) async throws {
290:         guard workingDirectory != nil else {
291:             throw GitManagerError.noRepository
292:         }
293:         
294:         // Native commit requires NativeGitWriter which isn't in Xcode project yet
295:         // TODO: Add NativeGit folder to Xcode project to enable offline commits
296:         throw GitManagerError.sshNotConnected
297:     }
298:     
299:     func checkout(branch: String) async throws {
300:         throw GitManagerError.sshNotConnected
301:     }
302:     
303:     func createBranch(name: String) async throws {
304:         throw GitManagerError.sshNotConnected
305:     }
306:     
307:     func deleteBranch(name: String) async throws {
308:         throw GitManagerError.sshNotConnected
309:     }
310:     
311:     func pull() async throws {
312:         throw GitManagerError.sshNotConnected
313:     }
314:     
315:     func push() async throws {
316:         throw GitManagerError.sshNotConnected
317:     }
318:     
319:     func stashPush(message: String?) async throws {
320:         throw GitManagerError.sshNotConnected
321:     }
322:     
323:     func stashPop(index: Int) async throws {
324:         throw GitManagerError.sshNotConnected
325:     }
326:     
327:     func stashDrop(index: Int) async throws {
328:         throw GitManagerError.sshNotConnected
329:     }
330:     
331:     func discard(file: String) async throws {
332:         throw GitManagerError.sshNotConnected
333:     }
334:     
335:     func discardAll() async throws {
336:         throw GitManagerError.sshNotConnected
337:     }
338:     
339:     func discardChanges(file: String) async throws {
340:         throw GitManagerError.sshNotConnected
341:     }
342:     
343:     func fetch() async throws {
344:         throw GitManagerError.sshNotConnected
345:     }
346:     
347:     /// Alias for lastError for compatibility
348:     var error: String? {
349:         return lastError
350:     }
351: }
352: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/SSHManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/SearchManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/SSHManager.swift (lines 1-233 of 233)
────────────────────────────────────────
1: //
2: //  SSHManager.swift
3: //  VSCodeiPadOS
4: //
5: //  Stub SSH Manager - TODO: Implement with SwiftNIO SSH
6: //  Add package: https://github.com/apple/swift-nio-ssh
7: //
8: 
9: import Foundation
10: import SwiftUI
11: 
12: // MARK: - SSH Connection Model
13: 
14: struct SSHConnectionConfig: Codable, Identifiable, Equatable {
15:     var id: UUID = UUID()
16:     var name: String
17:     var host: String
18:     var port: Int
19:     var username: String
20:     var authMethod: SSHAuthMethod
21:     var lastUsed: Date?
22:     
23:     enum SSHAuthMethod: Codable, Equatable {
24:         case password(String)
25:         case privateKey(key: String, passphrase: String?)
26:     }
27:     
28:     static func == (lhs: SSHConnectionConfig, rhs: SSHConnectionConfig) -> Bool {
29:         lhs.id == rhs.id
30:     }
31: }
32: 
33: // MARK: - SSH Manager Delegate Protocol
34: 
35: protocol SSHManagerDelegate: AnyObject {
36:     func sshManagerDidConnect(_ manager: SSHManager)
37:     func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?)
38:     func sshManager(_ manager: SSHManager, didReceiveOutput text: String)
39:     func sshManager(_ manager: SSHManager, didReceiveError text: String)
40: }
41: 
42: // MARK: - SSH Client Errors
43: 
44: enum SSHClientError: Error, LocalizedError {
45:     case connectionFailed(String)
46:     case authenticationFailed
47:     case channelCreationFailed
48:     case invalidChannelType
49:     case notConnected
50:     case timeout
51:     case invalidPrivateKey
52:     case commandExecutionFailed(String)
53:     case notImplemented
54:     
55:     var errorDescription: String? {
56:         switch self {
57:         case .connectionFailed(let reason): return "Connection failed: \(reason)"
58:         case .authenticationFailed: return "Authentication failed"
59:         case .channelCreationFailed: return "Failed to create SSH channel"
60:         case .invalidChannelType: return "Invalid channel type"
61:         case .notConnected: return "Not connected to server"
62:         case .timeout: return "Connection timed out"
63:         case .invalidPrivateKey: return "Invalid private key format"
64:         case .commandExecutionFailed(let reason): return "Command execution failed: \(reason)"
65:         case .notImplemented: return "SSH not yet implemented - add SwiftNIO SSH package"
66:         }
67:     }
68: }
69: 
70: // MARK: - Command Output Types
71: 
72: /// Real-time output events from SSH command execution
73: enum SSHCommandOutput {
74:     case stdout(String)
75:     case stderr(String)
76:     case exit(Int)
77:     case error(Error)
78:     case timeout
79: }
80: 
81: /// Result of a completed SSH command
82: struct SSHCommandResult {
83:     let stdout: String
84:     let stderr: String
85:     let exitCode: Int
86:     let isTimedOut: Bool
87:     
88:     var isSuccess: Bool {
89:         return exitCode == 0 && !isTimedOut
90:     }
91: }
92: 
93: // MARK: - SSH Manager (Stub Implementation)
94: 
95: class SSHManager {
96:     weak var delegate: SSHManagerDelegate?
97:     
98:     private(set) var isConnected: Bool = false
99:     private(set) var currentConfig: SSHConnectionConfig?
100:     
101:     init() {}
102:     
103:     // MARK: - Connection Methods
104:     
105:     /// Connect with async/await
106:     func connect(config: SSHConnectionConfig) async throws {
107:         // TODO: Implement with SwiftNIO SSH
108:         throw SSHClientError.notImplemented
109:     }
110:     
111:     /// Connect with completion handler (for compatibility)
112:     func connect(config: SSHConnectionConfig, completion: @escaping (Result<Void, Error>) -> Void) {
113:         // TODO: Implement with SwiftNIO SSH
114:         completion(.failure(SSHClientError.notImplemented))
115:     }
116:     
117:     func disconnect() {
118:         isConnected = false
119:         currentConfig = nil
120:         delegate?.sshManagerDidDisconnect(self, error: nil)
121:     }
122:     
123:     // MARK: - Command Execution
124:     
125:     func executeCommand(_ command: String, timeout: TimeInterval = 30) async throws -> SSHCommandResult {
126:         // TODO: Implement with SwiftNIO SSH
127:         throw SSHClientError.notImplemented
128:     }
129:     
130:     func executeCommand(_ command: String, onOutput: @escaping (SSHCommandOutput) -> Void) async throws {
131:         // TODO: Implement with SwiftNIO SSH
132:         throw SSHClientError.notImplemented
133:     }
134:     
135:     // MARK: - Interactive Shell
136:     
137:     func startInteractiveShell() async throws {
138:         // TODO: Implement with SwiftNIO SSH
139:         throw SSHClientError.notImplemented
140:     }
141:     
142:     func sendInput(_ text: String) async throws {
143:         // TODO: Implement with SwiftNIO SSH
144:         throw SSHClientError.notImplemented
145:     }
146:     
147:     /// Send a command to the shell
148:     func send(command: String) {
149:         // TODO: Implement with SwiftNIO SSH
150:         delegate?.sshManager(self, didReceiveError: "SSH not implemented")
151:     }
152:     
153:     /// Send interrupt signal (Ctrl+C)
154:     func sendInterrupt() {
155:         // TODO: Implement with SwiftNIO SSH
156:     }
157:     
158:     /// Send tab for auto-completion
159:     func sendTab() {
160:         // TODO: Implement with SwiftNIO SSH
161:     }
162:     
163:     /// Send escape key
164:     func sendEscape() {
165:         // TODO: Implement with SwiftNIO SSH
166:     }
167:     
168:     func resizeTerminal(cols: Int, rows: Int) async throws {
169:         // TODO: Implement with SwiftNIO SSH
170:     }
171:     
172:     func closeShell() {
173:         // TODO: Implement with SwiftNIO SSH
174:     }
175:     
176:     deinit {
177:         disconnect()
178:     }
179: }
180: 
181: // MARK: - SSH Connection Store (Persistence)
182: 
183: class SSHConnectionStore: ObservableObject {
184:     static let shared = SSHConnectionStore()
185:     
186:     @Published var savedConnections: [SSHConnectionConfig] = []
187:     
188:     private let userDefaults = UserDefaults.standard
189:     private let storageKey = "ssh_saved_connections"
190:     
191:     init() {
192:         loadConnections()
193:     }
194:     
195:     func save(_ connection: SSHConnectionConfig) {
196:         var config = connection
197:         config.lastUsed = Date()
198:         
199:         if let index = savedConnections.firstIndex(where: { $0.id == config.id }) {
200:             savedConnections[index] = config
201:         } else {
202:             savedConnections.append(config)
203:         }
204:         
205:         persistConnections()
206:     }
207:     
208:     func delete(_ connection: SSHConnectionConfig) {
209:         savedConnections.removeAll { $0.id == connection.id }
210:         persistConnections()
211:     }
212:     
213:     func updateLastUsed(_ connection: SSHConnectionConfig) {
214:         if let index = savedConnections.firstIndex(where: { $0.id == connection.id }) {
215:             savedConnections[index].lastUsed = Date()
216:             persistConnections()
217:         }
218:     }
219:     
220:     private func loadConnections() {
221:         guard let data = userDefaults.data(forKey: storageKey),
222:               let connections = try? JSONDecoder().decode([SSHConnectionConfig].self, from: data) else {
223:             return
224:         }
225:         savedConnections = connections.sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }
226:     }
227:     
228:     private func persistConnections() {
229:         guard let data = try? JSONEncoder().encode(savedConnections) else { return }
230:         userDefaults.set(data, forKey: storageKey)
231:     }
232: }
233: 

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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift (lines 1-981 of 981)
────────────────────────────────────────
1: import SwiftUI
2: import SwiftUI
3: import UIKit
4: import Network
5: import Foundation
6: 
7: // MARK: - Terminal View (Main Container)
8: 
9: struct TerminalView: View {
10:     @StateObject private var workspace = TerminalWorkspace.shared
11:     @ObservedObject private var themeManager = ThemeManager.shared
12:     @State private var showConnectionSheet = false
13: 
14:     var body: some View {
15:         VStack(spacing: 0) {
16:             // MARK: Top Toolbar
17:             HStack(spacing: 10) {
18:                 Text("TERMINAL")
19:                     .font(.caption)
20:                     .fontWeight(.bold)
21:                     .foregroundColor(themeManager.currentTheme.tabActiveForeground)
22:                     .padding(.horizontal, 8)
23: 
24:                 Spacer()
25: 
26:                 HStack(spacing: 12) {
27:                     Button(action: { workspace.addTab() }) {
28:                         Image(systemName: "plus")
29:                     }
30:                     .help("New Terminal")
31: 
32:                     Button(action: { workspace.toggleSplitActiveTab() }) {
33:                         Image(systemName: "square.split.2x1")
34:                     }
35:                     .disabled(workspace.tabs.isEmpty)
36:                     .help("Split Terminal")
37: 
38:                     Button(action: copyActiveTerminalToClipboard) {
39:                         Image(systemName: "doc.on.doc")
40:                     }
41:                     .disabled(workspace.activePane == nil)
42:                     .help("Copy Terminal Output")
43: 
44:                     Button(action: pasteClipboardToActiveTerminal) {
45:                         Image(systemName: "doc.on.clipboard")
46:                     }
47:                     .disabled(workspace.activePane == nil)
48:                     .help("Paste")
49: 
50:                     Button(action: { workspace.activePane?.clear() }) {
51:                         Image(systemName: "trash")
52:                     }
53:                     .disabled(workspace.activePane == nil)
54:                     .help("Clear Terminal")
55: 
56:                     Button(action: { workspace.killActive() }) {
57:                         Image(systemName: "xmark")
58:                     }
59:                     .disabled(workspace.activePane == nil)
60:                     .help("Kill Terminal")
61: 
62:                     Button(action: { showConnectionSheet = true }) {
63:                         Image(systemName: "network")
64:                     }
65:                     .disabled(workspace.activePane == nil)
66:                     .help("SSH Connect")
67:                 }
68:                 .font(.caption)
69:                 .foregroundColor(themeManager.currentTheme.editorForeground)
70:             }
71:             .padding(8)
72:             .background(themeManager.currentTheme.editorBackground)
73:             .overlay(
74:                 Rectangle()
75:                     .frame(height: 1)
76:                     .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.2)),
77:                 alignment: .bottom
78:             )
79: 
80:             // MARK: Tab Strip
81:             ScrollView(.horizontal, showsIndicators: false) {
82:                 HStack(spacing: 6) {
83:                     ForEach(workspace.tabs) { tab in
84:                         if let primary = tab.panes.first {
85:                             TerminalTabButtonView(
86:                                 terminal: primary,
87:                                 isActive: workspace.activeTabId == tab.id,
88:                                 onSelect: { workspace.activeTabId = tab.id },
89:                                 onClose: { workspace.closeTab(id: tab.id) },
90:                                 onRename: { workspace.activeTabId = tab.id },
91:                                 onSplit: { workspace.activeTabId = tab.id; workspace.toggleSplitActiveTab() }
92:                             )
93:                         }
94:                     }
95: 
96:                     Button(action: { workspace.addTab() }) {
97:                         Image(systemName: "plus")
98:                             .font(.caption)
99:                             .padding(.horizontal, 10)
100:                             .padding(.vertical, 6)
101:                             .background(
102:                                 RoundedRectangle(cornerRadius: 6)
103:                                     .fill(themeManager.currentTheme.editorForeground.opacity(0.08))
104:                             )
105:                     }
106:                     .buttonStyle(.plain)
107:                     .help("New Terminal")
108:                 }
109:                 .padding(.horizontal, 8)
110:                 .padding(.vertical, 6)
111:             }
112:             .background(themeManager.currentTheme.editorBackground)
113:             .overlay(
114:                 Rectangle()
115:                     .frame(height: 1)
116:                     .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.12)),
117:                 alignment: .bottom
118:             )
119: 
120:             // MARK: Terminal Content
121:             Group {
122:                 if let tab = workspace.activeTab {
123:                     if tab.panes.count <= 1, let terminal = tab.panes.first {
124:                         SingleTerminalView(
125:                             terminal: terminal,
126:                             isActive: true,
127:                             onActivate: { workspace.setActivePane(terminal.id, in: tab.id) },
128:                             onKill: { workspace.killActive() }
129:                         )
130:                     } else {
131:                         HStack(spacing: 0) {
132:                             ForEach(tab.panes) { pane in
133:                                 SingleTerminalView(
134:                                     terminal: pane,
135:                                     isActive: tab.activePaneId == pane.id,
136:                                     onActivate: { workspace.setActivePane(pane.id, in: tab.id) },
137:                                     onKill: { workspace.killActive() }
138:                                 )
139:                                 .frame(maxWidth: .infinity, maxHeight: .infinity)
140: 
141:                                 if pane.id != tab.panes.last?.id {
142:                                     Divider()
143:                                         .background(themeManager.currentTheme.editorForeground.opacity(0.2))
144:                                 }
145:                             }
146:                         }
147:                     }
148:                 } else {
149:                     VStack(spacing: 12) {
150:                         Text("No Open Terminals")
151:                             .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.5))
152:                         Button("Create New Terminal") {
153:                             workspace.addTab()
154:                         }
155:                     }
156:                     .frame(maxWidth: .infinity, maxHeight: .infinity)
157:                     .background(themeManager.currentTheme.editorBackground)
158:                 }
159:             }
160:         }
161:         .background(themeManager.currentTheme.editorBackground)
162:         .sheet(isPresented: $showConnectionSheet) {
163:             if let active = workspace.activePane {
164:                 SSHConnectionView(terminal: active, isPresented: $showConnectionSheet)
165:             }
166:         }
167:     }
168: 
169:     private func copyActiveTerminalToClipboard() {
170:         guard let terminal = workspace.activePane else { return }
171:         let text = terminal.output.map(\.text).joined(separator: "\n")
172:         UIPasteboard.general.string = text
173:     }
174: 
175:     private func pasteClipboardToActiveTerminal() {
176:         guard let terminal = workspace.activePane else { return }
177:         guard let clip = UIPasteboard.general.string, !clip.isEmpty else { return }
178:         terminal.draftCommand.append(contentsOf: clip)
179:     }
180: }
181: 
182: struct TerminalTabButtonView: View {
183:     @ObservedObject var terminal: TerminalManager
184:     var isActive: Bool
185:     var onSelect: () -> Void
186:     var onClose: () -> Void
187:     var onRename: () -> Void
188:     var onSplit: () -> Void
189: 
190:     @ObservedObject private var themeManager = ThemeManager.shared
191:     @State private var showRenameAlert = false
192: 
193:     var body: some View {
194:         Button(action: onSelect) {
195:             HStack(spacing: 6) {
196:                 Image(systemName: "terminal")
197:                     .font(.caption2)
198: 
199:                 Text(terminal.title.isEmpty ? "Terminal" : terminal.title)
200:                     .font(.caption)
201:                     .lineLimit(1)
202:                     .frame(maxWidth: 200, alignment: .leading)
203: 
204:                 Button(action: onClose) {
205:                     Image(systemName: "xmark")
206:                         .font(.caption2)
207:                 }
208:                 .buttonStyle(.plain)
209:             }
210:             .padding(.horizontal, 10)
211:             .padding(.vertical, 6)
212:             .background(
213:                 RoundedRectangle(cornerRadius: 6)
214:                     .fill(isActive ? themeManager.currentTheme.editorForeground.opacity(0.15) : themeManager.currentTheme.editorForeground.opacity(0.08))
215:             )
216:             .overlay(
217:                 RoundedRectangle(cornerRadius: 6)
218:                     .stroke(isActive ? themeManager.currentTheme.tabActiveForeground.opacity(0.5) : .clear, lineWidth: 1)
219:             )
220:         }
221:         .buttonStyle(.plain)
222:         .contextMenu {
223:             Button(action: {
224:                 showRenameAlert = true
225:             }) {
226:                 Label("Rename Terminal", systemImage: "pencil")
227:             }
228: 
229:             Button(action: {
230:                 onSplit()
231:             }) {
232:                 Label("Split Terminal", systemImage: "square.split.2x1")
233:             }
234: 
235:             Divider()
236: 
237:             Button(action: {
238:                 onClose()
239:             }) {
240:                 Label("Close Terminal", systemImage: "xmark")
241:                     .foregroundColor(.red)
242:             }
243:         }
244:         .alert("Rename Terminal", isPresented: $showRenameAlert) {
245:             TextField("Terminal Name", text: $terminal.title)
246:             Button("OK", role: .cancel) { }
247:         }
248:     }
249: }
250: 
251: // MARK: - Single Terminal View
252: 
253: struct SingleTerminalView: View {
254:     @ObservedObject var terminal: TerminalManager
255:     var isActive: Bool
256:     var onActivate: () -> Void
257:     var onKill: () -> Void
258: 
259:     @ObservedObject private var themeManager = ThemeManager.shared
260:     @FocusState private var isInputFocused: Bool
261: 
262:     var body: some View {
263:         VStack(spacing: 0) {
264:             // Terminal Output
265:             ScrollViewReader { proxy in
266:                 ScrollView {
267:                     VStack(alignment: .leading, spacing: 2) {
268:                         ForEach(terminal.output) { line in
269:                             TerminalLineView(line: line)
270:                                 .id(line.id)
271:                         }
272:                     }
273:                     .frame(maxWidth: .infinity, alignment: .leading)
274:                     .padding(8)
275:                 }
276:                 .onChange(of: terminal.output.count) { _ in
277:                     withAnimation(.easeOut(duration: 0.1)) {
278:                         proxy.scrollTo(terminal.output.last?.id, anchor: .bottom)
279:                     }
280:                 }
281:             }
282:             .contentShape(Rectangle())
283:             .contextMenu {
284:                 Button(action: {
285:                     let text = terminal.output.map(\.text).joined(separator: "\n")
286:                     UIPasteboard.general.string = text
287:                 }) {
288:                     Label("Copy", systemImage: "doc.on.doc")
289:                 }
290: 
291:                 Button(action: {
292:                     if let clip = UIPasteboard.general.string, !clip.isEmpty {
293:                         terminal.draftCommand.append(contentsOf: clip)
294:                     }
295:                 }) {
296:                     Label("Paste", systemImage: "doc.on.clipboard")
297:                 }
298: 
299:                 Divider()
300: 
301:                 Button(action: {
302:                     terminal.clear()
303:                 }) {
304:                     Label("Clear Terminal", systemImage: "trash")
305:                 }
306: 
307:                 Divider()
308: 
309:                 Button(action: {
310:                     onKill()
311:                 }) {
312:                     Label("Kill Terminal", systemImage: "xmark.circle")
313:                         .foregroundColor(.red)
314:                 }
315:             }
316:             .onTapGesture {
317:                 onActivate()
318:                 isInputFocused = true
319:             }
320: 
321:             // Input Area
322:             HStack(spacing: 0) {
323:                 Text(terminal.promptString)
324:                     .font(.system(.body, design: .monospaced))
325:                     .foregroundColor(themeManager.currentTheme.type)
326:                     .padding(.leading, 8)
327: 
328:                 TextField("", text: $terminal.draftCommand)
329:                     .font(.system(.body, design: .monospaced))
330:                     .foregroundColor(themeManager.currentTheme.editorForeground)
331:                     .accentColor(themeManager.currentTheme.cursor)
332:                     .autocapitalization(.none)
333:                     .disableAutocorrection(true)
334:                     .focused($isInputFocused)
335:                     .onSubmit { executeCommand() }
336:                     .padding(8)
337:             }
338:             .background(themeManager.currentTheme.editorBackground)
339: 
340:             // Mobile Helper Bar (optional)
341:             if isInputFocused {
342:                 HStack(spacing: 12) {
343:                     Button("Tab") { terminal.sendTab() }
344:                     Button("Esc") { /* handle esc */ }
345:                     Button("Ctrl+C") { terminal.sendInterrupt() }
346:                         .foregroundColor(.red)
347:                     Spacer()
348:                     Button("ls") { terminal.draftCommand = "ls -la" }
349:                     Button("git status") { terminal.draftCommand = "git status" }
350:                 }
351:                 .font(.caption)
352:                 .padding(.horizontal)
353:                 .padding(.vertical, 6)
354:                 .background(themeManager.currentTheme.editorForeground.opacity(0.1))
355:             }
356:         }
357:         .background(themeManager.currentTheme.editorBackground)
358:         .overlay(
359:             RoundedRectangle(cornerRadius: 0)
360:                 .stroke(isActive ? themeManager.currentTheme.tabActiveForeground.opacity(0.35) : .clear, lineWidth: 1)
361:         )
362:         .onAppear {
363:             if isActive {
364:                 isInputFocused = true
365:             }
366:         }
367:     }
368: 
369:     private func executeCommand() {
370:         let command = terminal.draftCommand.trimmingCharacters(in: .whitespacesAndNewlines)
371:         guard !command.isEmpty else { return }
372:         terminal.executeCommand(command)
373:         terminal.draftCommand = ""
374:     }
375: }
376: 
377: struct TerminalLineView: View {
378:     let line: TerminalLine
379:     @ObservedObject private var themeManager = ThemeManager.shared
380:     
381:     var body: some View {
382:         if line.isANSI {
383:             ANSIText(line.text)
384:         } else {
385:             Text(line.text)
386:                 .font(.system(.body, design: .monospaced))
387:                 .foregroundColor(colorForType(line.type))
388:                 .textSelection(.enabled)
389:         }
390:     }
391:     
392:     func colorForType(_ type: LineType) -> Color {
393:         switch type {
394:         case .command: return themeManager.currentTheme.editorForeground
395:         case .output: return themeManager.currentTheme.editorForeground.opacity(0.9)
396:         case .error: return Color.red // Could use theme error color if available
397:         case .system: return themeManager.currentTheme.comment
398:         case .prompt: return themeManager.currentTheme.type
399:         }
400:     }
401: }
402: 
403: // MARK: - Terminal Workspace Manager
404: 
405: struct TerminalTab: Identifiable, Equatable {
406:     let id: UUID
407:     var panes: [TerminalManager]
408:     var activePaneId: UUID
409: 
410:     init(panes: [TerminalManager]) {
411:         self.id = UUID()
412:         self.panes = panes
413:         self.activePaneId = panes.first?.id ?? UUID()
414:     }
415: 
416:     var title: String {
417:         panes.first?.title ?? "Terminal"
418:     }
419: 
420:     static func == (lhs: TerminalTab, rhs: TerminalTab) -> Bool {
421:         lhs.id == rhs.id
422:     }
423: }
424: 
425: class TerminalWorkspace: ObservableObject {
426:     static let shared = TerminalWorkspace()
427: 
428:     @Published var tabs: [TerminalTab] = []
429:     @Published var activeTabId: UUID?
430: 
431:     var activeTabIndex: Int? {
432:         guard let id = activeTabId else { return nil }
433:         return tabs.firstIndex(where: { $0.id == id })
434:     }
435: 
436:     var activeTab: TerminalTab? {
437:         guard let idx = activeTabIndex else { return nil }
438:         return tabs[idx]
439:     }
440: 
441:     var activePane: TerminalManager? {
442:         guard let tab = activeTab else { return nil }
443:         return tab.panes.first(where: { $0.id == tab.activePaneId }) ?? tab.panes.first
444:     }
445: 
446:     init() {
447:         addTab() // start with one
448:     }
449: 
450:     func addTab() {
451:         let term = TerminalManager()
452:         term.title = "Terminal \(tabs.count + 1)"
453:         let tab = TerminalTab(panes: [term])
454:         tabs.append(tab)
455:         activeTabId = tab.id
456:     }
457: 
458:     func closeTab(id: UUID) {
459:         guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
460:         for pane in tabs[idx].panes {
461:             pane.disconnect()
462:         }
463:         tabs.remove(at: idx)
464:         if activeTabId == id {
465:             activeTabId = tabs.last?.id
466:         }
467:     }
468: 
469:     func setActivePane(_ paneId: UUID, in tabId: UUID) {
470:         guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }
471:         tabs[tabIndex].activePaneId = paneId
472:     }
473: 
474:     func toggleSplitActiveTab() {
475:         guard let tabId = activeTabId else { return }
476:         guard let idx = tabs.firstIndex(where: { $0.id == tabId }) else { return }
477: 
478:         if tabs[idx].panes.count <= 1 {
479:             // Split: add a second pane (max 2 panes for now)
480:             let newPane = TerminalManager()
481:             newPane.title = "Terminal \(tabs.count).2"
482:             tabs[idx].panes.append(newPane)
483:             tabs[idx].activePaneId = newPane.id
484:         } else {
485:             // Unsplit: remove all panes except the first
486:             let extraPanes = tabs[idx].panes.dropFirst()
487:             for pane in extraPanes {
488:                 pane.disconnect()
489:             }
490:             tabs[idx].panes = Array(tabs[idx].panes.prefix(1))
491:             tabs[idx].activePaneId = tabs[idx].panes.first?.id ?? tabs[idx].activePaneId
492:         }
493:     }
494: 
495:     func killActive() {
496:         guard let tabId = activeTabId else { return }
497:         guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }
498: 
499:         let paneId = tabs[tabIndex].activePaneId
500:         if tabs[tabIndex].panes.count > 1 {
501:             // If split, kill the active pane only.
502:             if let paneIndex = tabs[tabIndex].panes.firstIndex(where: { $0.id == paneId }) {
503:                 tabs[tabIndex].panes[paneIndex].disconnect()
504:                 tabs[tabIndex].panes.remove(at: paneIndex)
505:             }
506:             tabs[tabIndex].activePaneId = tabs[tabIndex].panes.first?.id ?? tabs[tabIndex].activePaneId
507: 
508:             if tabs[tabIndex].panes.isEmpty {
509:                 closeTab(id: tabId)
510:             }
511:         } else {
512:             // If not split, kill the tab.
513:             closeTab(id: tabId)
514:         }
515:     }
516: }
517: 
518: // MARK: - Terminal Manager
519: 
520: class TerminalManager: ObservableObject, Identifiable {
521:     let id = UUID()
522:     @Published var title: String = "Terminal"
523:     
524:     @Published var output: [TerminalLine] = [
525:         TerminalLine(text: "VSCode iPadOS Terminal v2.0", type: .system),
526:         TerminalLine(text: "Type 'help' for commands or connect via SSH (SwiftNIO).", type: .system),
527:         TerminalLine(text: "", type: .output)
528:     ]
529:     @Published var isConnected = false
530:     @Published var isConnecting = false
531:     @Published var connectionStatus = "Not connected"
532:     @Published var promptString = "$ "
533:     @Published var draftCommand: String = ""
534:     
535:     private var sshManager: SSHManager?
536:     private var currentConfig: SSHConnectionConfig?
537:     private var commandHistory: [String] = []
538:     private var historyIndex = 0
539:     
540:     func clear() {
541:         output = []
542:     }
543:     
544:     func connect(to config: SSHConnectionConfig) {
545:         currentConfig = config
546:         isConnecting = true
547:         connectionStatus = "Connecting to \(config.host)..."
548:         title = "\(config.username)@\(config.host)"
549:         
550:         appendOutput("Connecting to \(config.username)@\(config.host):\(config.port)...", type: .system)
551:         appendOutput("Using SwiftNIO SSH (real SSH protocol)", type: .system)
552:         
553:         sshManager = SSHManager()
554:         sshManager?.delegate = self
555:         sshManager?.connect(config: config) { [weak self] result in
556:             switch result {
557:             case .success:
558:                 // Connection successful - delegate will handle UI update
559:                 SSHConnectionStore.shared.updateLastUsed(config)
560:             case .failure(let error):
561:                 self?.appendOutput("Connection failed: \(error.localizedDescription)", type: .error)
562:                 self?.isConnecting = false
563:                 self?.connectionStatus = "Connection failed"
564:             }
565:         }
566:     }
567:     
568:     // Legacy connect method for backward compatibility
569:     func connect(to connection: SSHConnection) {
570:         let authMethod: SSHConnectionConfig.SSHAuthMethod
571:         if let privateKey = connection.privateKey, !privateKey.isEmpty {
572:             authMethod = .privateKey(key: privateKey, passphrase: nil)
573:         } else {
574:             authMethod = .password(connection.password ?? "")
575:         }
576:         
577:         let config = SSHConnectionConfig(
578:             name: "\(connection.username)@\(connection.host)",
579:             host: connection.host,
580:             port: connection.port,
581:             username: connection.username,
582:             authMethod: authMethod
583:         )
584:         connect(to: config)
585:     }
586:     
587:     func disconnect() {
588:         sshManager?.disconnect()
589:         sshManager = nil
590:         isConnected = false
591:         isConnecting = false
592:         connectionStatus = "Disconnected"
593:         promptString = "$ "
594:         title = "Terminal (Disconnected)"
595:         appendOutput("Disconnected from server.", type: .system)
596:     }
597:     
598:     func executeCommand(_ command: String) {
599:         commandHistory.append(command)
600:         historyIndex = commandHistory.count
601:         
602:         if isConnected {
603:             // Don't echo command - server will echo it back
604:             sshManager?.send(command: command)
605:         } else {
606:             appendOutput(promptString + command, type: .command)
607:             processLocalCommand(command)
608:         }
609:     }
610:     
611:     func sendInterrupt() {
612:         if isConnected {
613:             sshManager?.sendInterrupt()
614:         }
615:         appendOutput("^C", type: .system)
616:     }
617:     
618:     func sendTab() {
619:         if isConnected {
620:             sshManager?.sendTab()
621:         }
622:     }
623:     
624:     func sendEscape() {
625:         sshManager?.sendEscape()
626:     }
627:     
628:     func previousCommand() -> String? {
629:         guard !commandHistory.isEmpty else { return nil }
630:         historyIndex = max(0, historyIndex - 1)
631:         return commandHistory[historyIndex]
632:     }
633:     
634:     func nextCommand() -> String? {
635:         guard !commandHistory.isEmpty else { return nil }
636:         historyIndex = min(commandHistory.count, historyIndex + 1)
637:         if historyIndex >= commandHistory.count {
638:             return ""
639:         }
640:         return commandHistory[historyIndex]
641:     }
642:     
643:     private func processLocalCommand(_ command: String) {
644:         let parts = command.split(separator: " ", maxSplits: 1)
645:         guard let cmd = parts.first?.lowercased() else { return }
646:         
647:         switch cmd {
648:         case "help":
649:             appendOutput("""
650:             Local Commands:
651:               help              - Show this help
652:               clear             - Clear terminal
653:               echo <text>       - Echo text
654:               date              - Show current date
655:               whoami            - Show current user
656:               history           - Show command history
657:               ssh               - Show SSH connection info
658:             
659:             Connect via SSH using the network button in toolbar.
660:             Real SSH protocol powered by SwiftNIO SSH.
661:             """, type: .output)
662:             
663:         case "clear":
664:             clear()
665:             
666:         case "echo":
667:             let text = parts.count > 1 ? String(parts[1]) : ""
668:             appendOutput(text, type: .output)
669:             
670:         case "date":
671:             appendOutput(Date().description, type: .output)
672:             
673:         case "whoami":
674:             appendOutput("ipad-user", type: .output)
675:             
676:         case "history":
677:             for (index, cmd) in commandHistory.enumerated() {
678:                 appendOutput("  \(index + 1)  \(cmd)", type: .output)
679:             }
680:             
681:         case "ssh":
682:             appendOutput("""
683:             SSH Status: \(isConnected ? "Connected" : "Not connected")
684:             Implementation: SwiftNIO SSH (apple/swift-nio-ssh)
685:             Features: Password auth, Key auth, PTY support, Shell sessions
686:             """, type: .output)
687:             
688:         default:
689:             appendOutput("\(cmd): command not found (local mode)", type: .error)
690:         }
691:     }
692:     
693:     func appendOutput(_ text: String, type: LineType, isANSI: Bool = false) {
694:         DispatchQueue.main.async {
695:             // Split multi-line output into separate lines
696:             let lines = text.components(separatedBy: .newlines)
697:             for line in lines {
698:                 if !line.isEmpty || lines.count == 1 {
699:                     self.output.append(TerminalLine(text: line, type: type, isANSI: isANSI || line.contains("\u{1B}")))
700:                 }
701:             }
702:         }
703:     }
704: }
705: 
706: // MARK: - SSH Manager Delegate
707: extension TerminalManager: SSHManagerDelegate {
708:     func sshManagerDidConnect(_ manager: SSHManager) {
709:         DispatchQueue.main.async {
710:             self.isConnected = true
711:             self.isConnecting = false
712:             self.connectionStatus = "Connected"
713:             self.promptString = "" // Shell will provide prompt
714:             self.appendOutput("Connected successfully via SwiftNIO SSH!", type: .system)
715:         }
716:     }
717:     
718:     func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?) {
719:         DispatchQueue.main.async {
720:             self.isConnected = false
721:             self.isConnecting = false
722:             self.connectionStatus = "Disconnected"
723:             self.promptString = "$ "
724:             if let error = error {
725:                 self.appendOutput("Connection lost: \(error.localizedDescription)", type: .error)
726:             }
727:         }
728:     }
729:     
730:     func sshManager(_ manager: SSHManager, didReceiveOutput text: String) {
731:         appendOutput(text, type: .output)
732:     }
733:     
734:     func sshManager(_ manager: SSHManager, didReceiveError text: String) {
735:         appendOutput(text, type: .error)
736:     }
737: }
738: 
739: // MARK: - SSH Connection View (Enhanced with Saved Connections)
740: 
741: struct SSHConnectionView: View {
742:     @ObservedObject var terminal: TerminalManager
743:     @Binding var isPresented: Bool
744:     @ObservedObject private var connectionStore = SSHConnectionStore.shared
745:     @ObservedObject private var themeManager = ThemeManager.shared
746:     
747:     @State private var connectionName = ""
748:     @State private var host = ""
749:     @State private var port = "22"
750:     @State private var username = ""
751:     @State private var password = ""
752:     @State private var useKey = false
753:     @State private var privateKey = ""
754:     @State private var keyPassphrase = ""
755:     @State private var saveConnection = true
756:     @State private var showSavedConnections = true
757:     @State private var errorMessage: String?
758:     
759:     var body: some View {
760:         NavigationView {
761:             Form {
762:                 // Saved Connections Section
763:                 if !connectionStore.savedConnections.isEmpty {
764:                     Section(header: Text("Saved Connections")) {
765:                         ForEach(connectionStore.savedConnections) { config in
766:                             Button(action: { connectToSaved(config) }) {
767:                                 HStack {
768:                                     VStack(alignment: .leading, spacing: 2) {
769:                                         Text(config.name)
770:                                             .font(.headline)
771:                                             .foregroundColor(themeManager.currentTheme.editorForeground)
772:                                         Text("\(config.username)@\(config.host):\(config.port)")
773:                                             .font(.caption)
774:                                             .foregroundColor(themeManager.currentTheme.comment)
775:                                     }
776:                                     Spacer()
777:                                     if case .privateKey = config.authMethod {
778:                                         Image(systemName: "key.fill")
779:                                             .foregroundColor(.orange)
780:                                     } else {
781:                                         Image(systemName: "lock.fill")
782:                                             .foregroundColor(.blue)
783:                                     }
784:                                 }
785:                             }
786:                             .swipeActions(edge: .trailing, allowsFullSwipe: true) {
787:                                 Button(role: .destructive) {
788:                                     connectionStore.delete(config)
789:                                 } label: {
790:                                     Label("Delete", systemImage: "trash")
791:                                 }
792:                             }
793:                         }
794:                     }
795:                 }
796:                 
797:                 // New Connection Section
798:                 Section(header: Text("New Connection")) {
799:                     TextField("Connection Name (optional)", text: $connectionName)
800:                         .autocapitalization(.none)
801:                     
802:                     TextField("Host", text: $host)
803:                         .autocapitalization(.none)
804:                         .disableAutocorrection(true)
805:                         .keyboardType(.URL)
806:                     
807:                     TextField("Port", text: $port)
808:                         .keyboardType(.numberPad)
809:                     
810:                     TextField("Username", text: $username)
811:                         .autocapitalization(.none)
812:                         .disableAutocorrection(true)
813:                 }
814:                 
815:                 Section(header: Text("Authentication")) {
816:                     Picker("Method", selection: $useKey) {
817:                         Text("Password").tag(false)
818:                         Text("SSH Key").tag(true)
819:                     }
820:                     .pickerStyle(.segmented)
821:                     
822:                     if useKey {
823:                         VStack(alignment: .leading, spacing: 8) {
824:                             Text("Private Key (PEM format)")
825:                                 .font(.caption)
826:                                 .foregroundColor(themeManager.currentTheme.comment)
827:                             
828:                             TextEditor(text: $privateKey)
829:                                 .font(.system(.caption, design: .monospaced))
830:                                 .frame(height: 120)
831:                                 .overlay(
832:                                     RoundedRectangle(cornerRadius: 8)
833:                                         .stroke(themeManager.currentTheme.editorForeground.opacity(0.2), lineWidth: 1)
834:                                 )
835:                             
836:                             SecureField("Key Passphrase (if encrypted)", text: $keyPassphrase)
837:                         }
838:                     } else {
839:                         SecureField("Password", text: $password)
840:                     }
841:                 }
842:                 
843:                 Section {
844:                     Toggle("Save Connection", isOn: $saveConnection)
845:                 }
846:                 
847:                 if let error = errorMessage {
848:                     Section {
849:                         Text(error)
850:                             .foregroundColor(.red)
851:                             .font(.caption)
852:                     }
853:                 }
854:                 
855:                 Section {
856:                     Button(action: connect) {
857:                         HStack {
858:                             Spacer()
859:                             if terminal.isConnecting {
860:                                 ProgressView()
861:                                     .progressViewStyle(CircularProgressViewStyle())
862:                                 Text("Connecting...")
863:                             } else {
864:                                 Image(systemName: "network")
865:                                 Text("Connect")
866:                             }
867:                             Spacer()
868:                         }
869:                     }
870:                     .disabled(host.isEmpty || username.isEmpty || terminal.isConnecting)
871:                 }
872:             }
873:             .navigationTitle("SSH Connection")
874:             .toolbar {
875:                 ToolbarItem(placement: .cancellationAction) {
876:                     Button("Cancel") { isPresented = false }
877:                 }
878:             }
879:         }
880:     }
881:     
882:     private func connectToSaved(_ config: SSHConnectionConfig) {
883:         terminal.connect(to: config)
884:         isPresented = false
885:     }
886:     
887:     private func connect() {
888:         errorMessage = nil
889:         
890:         let authMethod: SSHConnectionConfig.SSHAuthMethod
891:         if useKey {
892:             guard !privateKey.isEmpty else {
893:                 errorMessage = "Please enter your private key"
894:                 return
895:             }
896:             authMethod = .privateKey(key: privateKey, passphrase: keyPassphrase.isEmpty ? nil : keyPassphrase)
897:         } else {
898:             guard !password.isEmpty else {
899:                 errorMessage = "Please enter your password"
900:                 return
901:             }
902:             authMethod = .password(password)
903:         }
904:         
905:         let name = connectionName.isEmpty ? "\(username)@\(host)" : connectionName
906:         
907:         let config = SSHConnectionConfig(
908:             name: name,
909:             host: host,
910:             port: Int(port) ?? 22,
911:             username: username,
912:             authMethod: authMethod
913:         )
914:         
915:         if saveConnection {
916:             connectionStore.save(config)
917:         }
918:         
919:         terminal.connect(to: config)
920:         isPresented = false
921:     }
922: }
923: 
924: // MARK: - Models & Helpers (Legacy support)
925: 
926: struct SSHConnection {
927:     let host: String
928:     let port: Int
929:     let username: String
930:     let password: String?
931:     let privateKey: String?
932: }
933: 
934: struct TerminalLine: Identifiable {
935:     let id = UUID()
936:     let text: String
937:     let type: LineType
938:     var isANSI: Bool = false
939: }
940: 
941: enum LineType {
942:     case command
943:     case output
944:     case error
945:     case system
946:     case prompt
947: }
948: 
949: struct ANSIText: View {
950:     let text: String
951:     @ObservedObject private var themeManager = ThemeManager.shared
952:     
953:     init(_ text: String) {
954:         self.text = text
955:     }
956:     
957:     var body: some View {
958:         Text(stripANSI(text))
959:             .font(.system(.body, design: .monospaced))
960:             .foregroundColor(themeManager.currentTheme.editorForeground)
961:             .textSelection(.enabled)
962:     }
963:     
964:     private func stripANSI(_ text: String) -> String {
965:         let pattern = "\u{1B}\\[[0-9;]*[a-zA-Z]"
966:         guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
967:         let range = NSRange(text.startIndex..., in: text)
968:         return regex.stringByReplacingMatches(in: text, range: range, withTemplate: "")
969:     }
970: }
971: 
972: // MARK: - SSH Client Implementation
973: // Real SSH implementation is now in Services/SSHManager.swift
974: // Uses SwiftNIO SSH (apple/swift-nio-ssh) for proper SSH protocol support
975: // Features:
976: // - Password authentication
977: // - SSH key authentication (Ed25519, ECDSA)
978: // - PTY allocation for interactive shells
979: // - Proper channel management
980: // - Terminal resize support
981: 


❌ API Error (iteration 8): All slots exhausted after session terminated
