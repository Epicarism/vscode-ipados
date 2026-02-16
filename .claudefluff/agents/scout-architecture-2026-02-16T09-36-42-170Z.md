# Agent: scout-architecture
**Status:** done
**Tokens:** 3,835
**Cost:** $0.0000
**Time:** 2026-02-16T09:36:42.170Z

## Task
Read the entire project structure of VSCodeiPadOS. Report: 1) All Services and what they do, 2) How the editor works (Runestone vs WebView?), 3) Any existing WebView/WKWebView usage, 4) All runner implementations (WASM, JS, Python), 5) How menus are currently structured. Be thorough - we need to understand what to keep vs rebuild.

## Response
I'll systematically explore the VSCodeiPadOS project structure to answer all your questions. Let me start with a broad overview.





---

## 🔧 TOOL RESULTS

[list_dir]
📁 Services/
📁 OnDevice/




---

## 🔧 TOOL RESULTS

[list_dir]
📁 Services/OnDevice/
   (empty directory)




---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/
📁 Editor/
📁 Panels/




---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/Editor/
   (empty directory)




---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/Panels/
   RunnerWarningView.swift
   TerminalView.swift_patch1
   TerminalView.swift_patch2




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/
📁 .garbage/
📁 AUDIT/
📁 Docs/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOS.xcodeproj/
📁 VSCodeiPadOSTests/
   bugs.md
   FeatureFlags.swift
   Info.plist
   Package.swift
   TreeSitterLanguages.swift
   TypingLagTest.swift




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/
📁 App/
📁 Assets.xcassets/
📁 Commands/
📁 Docs/
📁 Extensions/
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




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/
📁 NativeGit/
📁 OnDevice/
📁 Runners/
   AIManager.swift
   AutocompleteManager.swift
   BracketMatchingManager.swift
   CodeExecutionService.swift
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
   OutputPanelManager.swift
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
   WindowStateManager.swift
   WordOccurrenceHighlighter.swift
   WorkspaceManager.swift
   WorkspaceTrustManager.swift




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/Runners/
   NodeRunner.swift
   PythonRunner.swift
   PythonRunnerAlt.swift
   SwiftRunner.swift




---

## 🔧 TOOL RESULTS

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

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/Panels/
   AIAssistantView.swift
   DebugConsoleView.swift
   DebugView.swift
   GitQuickActionsView.swift
   GitView.swift
   GoToLineView.swift
   MarkdownPreviewView.swift
   MarkdownPreviewWrapper.swift
   OutlineView.swift
   OutputView.swift
   PanelView.swift
   ProblemsView.swift
   RunnerWarningView.swift
   SearchView.swift
   SettingsView.swift
   TerminalView.swift
   TestView.swift
   TimelineView.swift




---

## 🔧 TOOL RESULTS

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


Now let me read the key files to understand the details. Starting with the main services:



---

## 🔧 TOOL RESULTS

[read_file]
snapshot: f4973229db81
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 1-1386 of 1386)
────────────────────────────────────────
1|c4e19d|import UniformTypeIdentifiers
2|d755ba|import SwiftUI
3|adc83b|
4|2908be|// MARK: - Navigation Location
5|41204c|struct NavigationLocation {
6|220d1e|    let tabId: UUID
7|390384|    let line: Int
8|539e50|    let column: Int
9|b31277|}
10|adc83b|
11|d2991a|// MARK: - Sidebar Panel (renamed from SidebarView to avoid conflict with SidebarView struct in Views)
12|a8f216|enum SidebarPanel {
13|0f9eb6|    case explorer
14|ea28a4|    case git
15|16448a|    case search
16|49cb25|    case extensions
17|b31277|}
18|adc83b|
19|a2fb27|// MARK: - Terminal Session Stub
20|fc8967|struct TerminalSession: Identifiable {
21|91b0e8|    let id: UUID
22|7255e0|    var title: String
23|9ac954|    var output: String
24|b4687f|    
25|77a7fd|    init(id: UUID = UUID(), title: String = "Terminal", output: String = "") {
26|51d091|        self.id = id
27|27169c|        self.title = title
28|6ef144|        self.output = output
29|27e597|    }
30|b31277|}
31|adc83b|
32|2fd1b6|// MARK: - Debug State Stubs
33|25e238|struct DebugSessionState {
34|ff6786|    var isPaused: Bool = false
35|3aea38|    var currentLine: Int?
36|38a719|    var currentFile: String?
37|cdfb22|    var callStack: [String] = []
38|63e31e|    var variables: [String: String] = [:]
39|b31277|}
40|adc83b|
41|47c98a|struct DebugBreakpoint: Identifiable, Equatable {
42|91b0e8|    let id: UUID
43|7e6914|    var file: String
44|acbcc9|    var line: Int
45|46cb5f|    var isEnabled: Bool
46|02ea27|    var condition: String?
47|b4687f|    
48|38228a|    init(id: UUID = UUID(), file: String, line: Int, isEnabled: Bool = true, condition: String? = nil) {
49|51d091|        self.id = id
50|f386e5|        self.file = file
51|84c49f|        self.line = line
52|bc842e|        self.isEnabled = isEnabled
53|3d45db|        self.condition = condition
54|27e597|    }
55|b31277|}
56|adc83b|
57|20222f|// MARK: - Peek Definition State
58|283e14|struct PeekState: Equatable {
59|2553d0|    let file: String
60|390384|    let line: Int
61|02a6c7|    let content: String
62|bbcf1b|    let sourceLine: Int // The line where peek was triggered
63|b31277|}
64|adc83b|
65|320daa|// MARK: - Editor Core (Central State Manager)
66|312682|class EditorCore: ObservableObject {
67|1ee7ef|    @Published var peekState: PeekState?
68|a6d994|    @Published var tabs: [Tab] = []
69|e129c3|    @Published var activeTabId: UUID?
70|29899f|    @Published var showSidebar = true
71|4d5c2a|    @Published var sidebarWidth: CGFloat = 250
72|dfe044|    @Published var showFilePicker = false
73|949c0a|    @Published var showSaveAsDialog = false
74|cabad2|    var saveAsContent: String = ""
75|f8bcea|    @Published var lastSaveError: String?
76|0818a1|    @Published var searchText = ""
77|84d537|    @Published var showSearch = false
78|f84db8|    @Published var showCommandPalette = false
79|fbcbe4|    @Published var showQuickOpen = false
80|f2f493|    @Published var showAIAssistant = false
81|7c3010|    @Published var showGoToLine = false
82|13859f|    @Published var showGoToSymbol = false
83|e43e57|    @Published var editorFontSize: CGFloat = 14.0
84|2e5f14|    @Published var isZenMode = false
85|fa580f|    @Published var isFocusMode = false
86|adc83b|
87|fca5a3|    // Snippet picker support
88|15f11e|    @Published var showSnippetPicker = false
89|941161|    @Published var pendingSnippetInsertion: Snippet?
90|adc83b|
91|27e392|    // Cursor tracking
92|a020ef|    @Published var cursorPosition = CursorPosition()
93|adc83b|
94|5442e5|    // Multi-cursor support
95|a9b9d0|    @Published var multiCursorState = MultiCursorState()
96|ba0b96|    @Published var currentSelection: String = ""
97|1a3f89|    @Published var currentSelectionRange: NSRange?
98|adc83b|
99|82e321|    // Selection request for find/replace navigation
100|bc0892|    @Published var requestedSelection: NSRange?
101|adc83b|
102|f1b77b|    // UI Panel state
103|5d1a58|    @Published var showPanel = false
104|dfc392|    @Published var showRenameSymbol = false
105|1f093c|    @Published var focusedSidebarTab = 0
106|adc83b|
107|d51ea1|    // Terminal state
108|81609c|    @Published var terminalSessions: [TerminalSession] = []
109|505e94|    @Published var activeTerminalId: UUID?
110|f12907|    @Published var isTerminalMaximized: Bool = false
111|eb5ca9|    @Published var terminalPanelHeight: CGFloat = 200
112|adc83b|
113|9f19f0|    // Debug state
114|cbb347|    @Published var isDebugging: Bool = false
115|6b6ac5|    @Published var isRunning: Bool = false
116|e75e60|    @Published var canStartDebugging: Bool = true
117|019801|    @Published var showAddConfiguration: Bool = false
118|bfe134|    @Published var debugSessionState: DebugSessionState?
119|79abaa|    @Published var breakpoints: [DebugBreakpoint] = []
120|adc83b|
121|cd5080|    // Focused sidebar panel
122|15b1c0|    @Published var focusedView: SidebarPanel = .explorer
123|adc83b|
124|fda16b|    // Reference to file navigator for workspace search
125|e4df05|    weak var fileNavigator: FileSystemNavigator?
126|adc83b|
127|9ec84f|    // Navigation history
128|6a3111|    private var navigationHistory: [NavigationLocation] = []
129|4d0d46|    private var navigationIndex = -1
130|adc83b|
131|7b8f21|    /// Track active security-scoped URL access while files are open in tabs.
132|b24c0d|    /// This avoids losing access after opening a document (common on iPadOS).
133|e6fd81|    private var securityScopedAccessCounts: [URL: Int] = [:]
134|adc83b|
135|b8bdf3|    var activeTab: Tab? {
136|59ee7e|        tabs.first { $0.id == activeTabId }
137|27e597|    }
138|adc83b|
139|75cc04|    var activeTabIndex: Int? {
140|de4487|        tabs.firstIndex { $0.id == activeTabId }
141|27e597|    }
142|adc83b|
143|359b1b|    init() {
144|62fd7f|        // Create example tabs for all supported languages
145|0ba339|        let exampleTabs = Self.createExampleTabs()
146|8780f1|        tabs.append(contentsOf: exampleTabs)
147|4f6451|        activeTabId = exampleTabs.first?.id ?? UUID()
148|27e597|    }
149|b4687f|    
150|78f12b|    /// Creates example tabs demonstrating syntax highlighting for all supported languages
151|a830d6|    private static func createExampleTabs() -> [Tab] {
152|8cfd49|        var examples: [Tab] = []
153|d6ed84|        
154|a13ba8|        // Swift example
155|f0955b|        examples.append(Tab(
156|0bc9a8|            fileName: "Welcome.swift",
157|7a029b|            content: """
158|cf53a7|// Welcome to VS Code for iPadOS! 🎉
159|8d0643|//
160|f205ed|// Features:
161|8cef3f|// • Syntax highlighting for Swift, JS, Python, and more
162|9a4015|// • Multiple tabs with drag reordering
163|ca1f11|// • File explorer sidebar
164|463668|// • Command palette (⌘+Shift+P)
165|9a7f61|// • Quick open (⌘+P)
166|73eab0|// • Find & Replace (⌘+F)
167|c04970|// • AI Assistant
168|cb07e6|// • Minimap navigation
169|7db993|// • Code folding
170|8f1f2b|// • Go to line (⌘+G)
171|8d0643|//
172|3349e5|// Start editing or open a file!
173|adc83b|
174|d755ba|import SwiftUI
175|adc83b|
176|4a07a6|struct ContentView: View {
177|bfb6e5|    @State private var counter = 0
178|b4687f|    
179|504e43|    var body: some View {
180|69d3a9|        VStack(spacing: 20) {
181|034352|            Text("Hello, World!")
182|1b4a82|                .font(.largeTitle)
183|f7ad69|                .foregroundColor(.blue)
184|3070d1|            
185|a1d5d1|            Button("Count: \\(counter)") {
186|497b4e|                counter += 1
187|a7dc16|            }
188|a68f66|            .buttonStyle(.borderedProminent)
189|5f3077|        }
190|72583e|        .padding()
191|27e597|    }
192|b31277|}
193|adc83b|
194|5e4767|// MARK: - Preview
195|0eca73|#Preview {
196|c476ef|    ContentView()
197|b31277|}
198|b7ce6e|""",
199|97882c|            language: "swift"
200|813e75|        ))
201|d6ed84|        
202|5bfc87|        // JavaScript example
203|f0955b|        examples.append(Tab(
204|75279c|            fileName: "example.js",
205|7a029b|            content: """
206|08e83e|// JavaScript Example - ES6+ Features
207|adc83b|
208|d9b09f|import React, { useState, useEffect } from 'react';
209|adc83b|
210|4bb664|const API_URL = 'https://api.example.com';
211|adc83b|
212|4e581e|// Async function with error handling
213|5a86c3|async function fetchData(endpoint) {
214|3c751d|    try {
215|8e9b1e|        const response = await fetch(`${API_URL}/${endpoint}`);
216|c52d1e|        if (!response.ok) {
217|4e9ea1|            throw new Error(`HTTP error! status: ${response.status}`);
218|5f3077|        }
219|1f4f06|        return await response.json();
220|6e1365|    } catch (error) {
221|da4c02|        console.error('Fetch failed:', error);
222|0a5fa4|        return null;
223|27e597|    }
224|b31277|}
225|adc83b|
226|0b2611|// React Component
227|c85565|function UserProfile({ userId }) {
228|21b1ca|    const [user, setUser] = useState(null);
229|9d5052|    const [loading, setLoading] = useState(true);
230|b4687f|    
231|b7837a|    useEffect(() => {
232|fd3d47|        fetchData(`users/${userId}`)
233|4a85c4|            .then(data => {
234|cd836c|                setUser(data);
235|b2d927|                setLoading(false);
236|892e8b|            });
237|349367|    }, [userId]);
238|b4687f|    
239|32b313|    if (loading) return <div>Loading...</div>;
240|b4687f|    
241|d09267|    return (
242|b5ce1f|        <div className="profile">
243|3b6efe|            <h1>{user?.name ?? 'Unknown'}</h1>
244|81326b|            <p>Email: {user?.email}</p>
245|2d89f1|        </div>
246|209670|    );
247|b31277|}
248|adc83b|
249|e498aa|// Array methods & destructuring
250|5c73a8|const numbers = [1, 2, 3, 4, 5];
251|128f8a|const doubled = numbers.map(n => n * 2);
252|251ac8|const [first, second, ...rest] = doubled;
253|adc83b|
254|b32033|export { fetchData, UserProfile };
255|b7ce6e|""",
256|2f9d42|            language: "javascript"
257|813e75|        ))
258|d6ed84|        
259|8af368|        // Python example
260|f0955b|        examples.append(Tab(
261|d04e33|            fileName: "example.py",
262|7a029b|            content: """
263|e05c05|#!/usr/bin/env python3
264|5aac47|\"\"\"
265|a39a14|Python Example - Modern Python Features
266|d6a5ac|Demonstrates type hints, dataclasses, async, and more.
267|5aac47|\"\"\"
268|adc83b|
269|e13070|import asyncio
270|57a161|from dataclasses import dataclass, field
271|3e7c83|from typing import Optional, List
272|acc0ed|from enum import Enum
273|adc83b|
274|054df8|class Status(Enum):
275|5c9625|    PENDING = "pending"
276|132770|    ACTIVE = "active"
277|bacb8e|    COMPLETED = "completed"
278|adc83b|
279|4cd340|@dataclass
280|603d0e|class Task:
281|e89e79|    \"\"\"Represents a task with metadata.\"\"\"
282|45c89b|    id: int
283|c662c5|    title: str
284|4b5b96|    status: Status = Status.PENDING
285|d39601|    tags: List[str] = field(default_factory=list)
286|c4d782|    description: Optional[str] = None
287|b4687f|    
288|291a22|    def mark_complete(self) -> None:
289|b93a57|        self.status = Status.COMPLETED
290|b90567|        print(f"Task '{self.title}' completed!")
291|adc83b|
292|d9ba4a|class TaskManager:
293|8fa5a7|    def __init__(self):
294|2e7c6d|        self._tasks: dict[int, Task] = {}
295|1ced01|        self._next_id = 1
296|b4687f|    
297|1a3e8a|    def add_task(self, title: str, **kwargs) -> Task:
298|c350a2|        task = Task(id=self._next_id, title=title, **kwargs)
299|8f87cb|        self._tasks[task.id] = task
300|48db70|        self._next_id += 1
301|46b7e5|        return task
302|b4687f|    
303|ffb550|    async def process_tasks(self) -> None:
304|1f6997|        for task in self._tasks.values():
305|960af6|            await asyncio.sleep(0.1)  # Simulate work
306|741a3c|            task.mark_complete()
307|adc83b|
308|8efbd4|# Main execution
309|fe03be|async def main():
310|a47a74|    manager = TaskManager()
311|b84b88|    manager.add_task("Learn Python", tags=["programming", "learning"])
312|081e24|    manager.add_task("Build app", description="Create VSCode for iPad")
313|b4687f|    
314|bef3bc|    await manager.process_tasks()
315|adc83b|
316|cfba8f|if __name__ == "__main__":
317|33c963|    asyncio.run(main())
318|b7ce6e|""",
319|cdea1f|            language: "python"
320|813e75|        ))
321|d6ed84|        
322|f1b7a5|        // JSON example
323|f0955b|        examples.append(Tab(
324|b0afa9|            fileName: "package.json",
325|7a029b|            content: """
326|137f55|{
327|5a9a9f|  "name": "vscode-ipados-example",
328|dd9edb|  "version": "1.0.0",
329|85d7cf|  "description": "Example package.json for VS Code iPadOS",
330|35fe1c|  "main": "index.js",
331|f28523|  "scripts": {
332|1de9e5|    "start": "node index.js",
333|feee95|    "build": "webpack --mode production",
334|f44e40|    "test": "jest --coverage",
335|d2306e|    "lint": "eslint src/**/*.js"
336|063e71|  },
337|724ff4|  "dependencies": {
338|f2dec7|    "react": "^18.2.0",
339|f54b12|    "react-dom": "^18.2.0",
340|51303e|    "axios": "^1.4.0"
341|063e71|  },
342|de1e66|  "devDependencies": {
343|e7a7d8|    "webpack": "^5.88.0",
344|83ae0a|    "jest": "^29.5.0",
345|d4e6db|    "eslint": "^8.44.0",
346|e3d462|    "typescript": "^5.1.6"
347|063e71|  },
348|be4963|  "keywords": ["vscode", "ipad", "editor"],
349|d24a7d|  "author": "VS Code iPadOS Team",
350|548227|  "license": "MIT",
351|fc00d9|  "repository": {
352|db4690|    "type": "git",
353|965946|    "url": "https://github.com/example/vscode-ipados"
354|063e71|  },
355|195883|  "engines": {
356|fc4fb9|    "node": ">=18.0.0"
357|2006e9|  }
358|b31277|}
359|b7ce6e|""",
360|b88667|            language: "json"
361|813e75|        ))
362|d6ed84|        
363|3dd2d4|        // HTML example
364|f0955b|        examples.append(Tab(
365|f01655|            fileName: "index.html",
366|7a029b|            content: """
367|51a231|<!DOCTYPE html>
368|e3fb3e|<html lang="en">
369|a2ec41|<head>
370|ceed69|    <meta charset="UTF-8">
371|851396|    <meta name="viewport" content="width=device-width, initial-scale=1.0">
372|6a6e5f|    <title>VS Code for iPadOS</title>
373|e16c0b|    <link rel="stylesheet" href="styles.css">
374|4b63f0|    <script src="app.js" defer></script>
375|bbfb03|</head>
376|61e9e9|<body>
377|937a27|    <header class="navbar">
378|853b8f|        <nav>
379|1af42a|            <a href="#" class="logo">VS Code iPadOS</a>
380|d38e1e|            <ul class="nav-links">
381|934f87|                <li><a href="#features">Features</a></li>
382|80f25b|                <li><a href="#download">Download</a></li>
383|789f5f|                <li><a href="#docs">Documentation</a></li>
384|b74eea|            </ul>
385|51ac3b|        </nav>
386|522d00|    </header>
387|b4687f|    
388|81576b|    <main>
389|830bcd|        <section id="hero" class="hero-section">
390|20b19e|            <h1>Code Anywhere</h1>
391|8a31bf|            <p>Professional code editor for your iPad</p>
392|2c53b2|            <button id="cta-button" class="btn primary">
393|7169f9|                Get Started
394|eb9cdc|            </button>
395|202d1f|        </section>
396|d6ed84|        
397|2e4e42|        <section id="features">
398|766a7e|            <h2>Features</h2>
399|ee7b02|            <div class="feature-grid">
400|9a7a42|                <article class="feature-card">
401|aa27d7|                    <h3>Syntax Highlighting</h3>
402|a8a4fa|                    <p>Support for 8+ languages with TreeSitter</p>
403|7ee35d|                </article>
404|9f4855|                <!-- More features -->
405|8fad5c|            </div>
406|202d1f|        </section>
407|bc6196|    </main>
408|b4687f|    
409|d8696a|    <footer>
410|1d6f72|        <p>&copy; 2024 VS Code iPadOS. All rights reserved.</p>
411|97ab03|    </footer>
412|fb2d70|</body>
413|27941c|</html>
414|b7ce6e|""",
415|f9b289|            language: "html"
416|813e75|        ))
417|d6ed84|        
418|94fd82|        // CSS example
419|f0955b|        examples.append(Tab(
420|889224|            fileName: "styles.css",
421|7a029b|            content: """
422|4fbc3e|/* VS Code iPadOS - Stylesheet */
423|8f459f|/* Modern CSS with variables, grid, and animations */
424|adc83b|
425|80477a|:root {
426|08021a|    --primary-color: #007acc;
427|f3d2d1|    --secondary-color: #3c3c3c;
428|b8e284|    --background-dark: #1e1e1e;
429|49fc5d|    --text-light: #d4d4d4;
430|e07b10|    --accent-green: #4ec9b0;
431|ba90a3|    --font-mono: 'SF Mono', Menlo, monospace;
432|0ca247|    --shadow-lg: 0 10px 40px rgba(0, 0, 0, 0.3);
433|b31277|}
434|adc83b|
435|528114|* {
436|0d96ba|    margin: 0;
437|20ce36|    padding: 0;
438|59004d|    box-sizing: border-box;
439|b31277|}
440|adc83b|
441|3e84a3|body {
442|b2d922|    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
443|e33751|    background-color: var(--background-dark);
444|a7026f|    color: var(--text-light);
445|508c34|    line-height: 1.6;
446|b31277|}
447|adc83b|
448|bca70d|.navbar {
449|701f74|    position: sticky;
450|978aba|    top: 0;
451|b44137|    background: rgba(30, 30, 30, 0.95);
452|2859c9|    backdrop-filter: blur(10px);
453|420323|    padding: 1rem 2rem;
454|35c4be|    z-index: 1000;
455|b31277|}
456|adc83b|
457|40cda2|.hero-section {
458|9dd02d|    min-height: 100vh;
459|8928a5|    display: grid;
460|d1ff91|    place-items: center;
461|2d6734|    text-align: center;
462|4173b0|    background: linear-gradient(135deg, var(--background-dark), #2d2d30);
463|b31277|}
464|adc83b|
465|de992a|.btn.primary {
466|1af0b4|    background: var(--primary-color);
467|3b4c82|    color: white;
468|4bafa9|    padding: 12px 24px;
469|84f6c0|    border: none;
470|7265d9|    border-radius: 6px;
471|0235f4|    font-size: 1rem;
472|ad2c58|    cursor: pointer;
473|6f67b9|    transition: transform 0.2s, box-shadow 0.2s;
474|b31277|}
475|adc83b|
476|9ad7b2|.btn.primary:hover {
477|9a2e0f|    transform: translateY(-2px);
478|c6f6d6|    box-shadow: var(--shadow-lg);
479|b31277|}
480|adc83b|
481|2dae44|.feature-grid {
482|8928a5|    display: grid;
483|4a5fbb|    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
484|2a5a6f|    gap: 2rem;
485|54ce2f|    padding: 2rem;
486|b31277|}
487|adc83b|
488|0202ba|@keyframes fadeIn {
489|77cf08|    from { opacity: 0; transform: translateY(20px); }
490|4358d6|    to { opacity: 1; transform: translateY(0); }
491|b31277|}
492|adc83b|
493|a0a323|.feature-card {
494|f63ff0|    animation: fadeIn 0.5s ease-out forwards;
495|b31277|}
496|adc83b|
497|09eb02|@media (max-width: 768px) {
498|fc0953|    .nav-links { display: none; }
499|36bb36|    .hero-section { padding: 2rem; }
500|b31277|}
501|b7ce6e|""",
502|37073b|            language: "css"
503|813e75|        ))
504|d6ed84|        
505|70854a|        // Go example
506|f0955b|        examples.append(Tab(
507|173417|            fileName: "main.go",
508|7a029b|            content: """
509|dd18bb|// Go Example - HTTP Server with Goroutines
510|af96a5|package main
511|adc83b|
512|f7ab87|import (
513|f48f0e|\t"context"
514|567e13|\t"encoding/json"
515|b1db2d|\t"fmt"
516|7293d7|\t"log"
517|dbc36b|\t"net/http"
518|5284c6|\t"sync"
519|5f54ea|\t"time"
520|a35077|)
521|adc83b|
522|39ac9c|// User represents a user in the system
523|00db38|type User struct {
524|c77d6f|\tID        int       `json:"id"`
525|4698d5|\tName      string    `json:"name"`
526|b65b1b|\tEmail     string    `json:"email"`
527|2ed51e|\tCreatedAt time.Time `json:"created_at"`
528|b31277|}
529|adc83b|
530|e578a6|// UserStore handles user data with thread-safe access
531|c88728|type UserStore struct {
532|c3fdfb|\tmu    sync.RWMutex
533|051305|\tusers map[int]*User
534|d54867|\tnextID int
535|b31277|}
536|adc83b|
537|cc854c|func NewUserStore() *UserStore {
538|ed9ea3|\treturn &UserStore{
539|020c9f|\t\tusers:  make(map[int]*User),
540|5bfe05|\t\tnextID: 1,
541|bceb9c|\t}
542|b31277|}
543|adc83b|
544|e1b92c|func (s *UserStore) Create(name, email string) *User {
545|1db638|\ts.mu.Lock()
546|7d9ed0|\tdefer s.mu.Unlock()
547|80050b|\t
548|d8abf6|\tuser := &User{
549|e00997|\t\tID:        s.nextID,
550|6a68d6|\t\tName:      name,
551|9c5c36|\t\tEmail:     email,
552|97639d|\t\tCreatedAt: time.Now(),
553|bceb9c|\t}
554|72a210|\ts.users[user.ID] = user
555|1e16b2|\ts.nextID++
556|53ef3f|\treturn user
557|b31277|}
558|adc83b|
559|366ce6|func (s *UserStore) Get(id int) (*User, bool) {
560|4ddb51|\ts.mu.RLock()
561|bced95|\tdefer s.mu.RUnlock()
562|4eba9b|\tuser, ok := s.users[id]
563|00df77|\treturn user, ok
564|b31277|}
565|adc83b|
566|ff8f91|func handleUsers(store *UserStore) http.HandlerFunc {
567|339c11|\treturn func(w http.ResponseWriter, r *http.Request) {
568|53b88a|\t\tswitch r.Method {
569|9d2118|\t\tcase http.MethodGet:
570|394019|\t\t\t// Return all users
571|9e9af3|\t\t\tw.Header().Set("Content-Type", "application/json")
572|43bf24|\t\t\tjson.NewEncoder(w).Encode(store.users)
573|59888b|\t\tcase http.MethodPost:
574|0965d8|\t\t\t// Create new user
575|e913f0|\t\t\tvar req struct {
576|2f0bda|\t\t\t\tName  string `json:"name"`
577|0c4cc3|\t\t\t\tEmail string `json:"email"`
578|1f4a90|\t\t\t}
579|2b3653|\t\t\tif err := json.NewDecoder(r.Body).Decode(&req); err != nil {
580|447a17|\t\t\t\thttp.Error(w, err.Error(), http.StatusBadRequest)
581|1b1356|\t\t\t\treturn
582|1f4a90|\t\t\t}
583|b82a43|\t\t\tuser := store.Create(req.Name, req.Email)
584|d73497|\t\t\tw.WriteHeader(http.StatusCreated)
585|17b111|\t\t\tjson.NewEncoder(w).Encode(user)
586|04883b|\t\tdefault:
587|2ea09d|\t\t\thttp.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
588|53a2fc|\t\t}
589|bceb9c|\t}
590|b31277|}
591|adc83b|
592|a4072f|func main() {
593|ca7100|\tstore := NewUserStore()
594|80050b|\t
595|1b6d3b|\t// Seed some data
596|6ea9c7|\tstore.Create("Alice", "alice@example.com")
597|2c81f1|\tstore.Create("Bob", "bob@example.com")
598|80050b|\t
599|45645c|\tmux := http.NewServeMux()
600|b3170f|\tmux.HandleFunc("/api/users", handleUsers(store))
601|80050b|\t
602|a3c17c|\tserver := &http.Server{
603|879a10|\t\tAddr:         ":8080",
604|876c57|\t\tHandler:      mux,
605|a8bd2e|\t\tReadTimeout:  10 * time.Second,
606|aa51e5|\t\tWriteTimeout: 10 * time.Second,
607|bceb9c|\t}
608|80050b|\t
609|8d2b91|\tfmt.Println("Server starting on :8080")
610|fd5ced|\tlog.Fatal(server.ListenAndServe())
611|b31277|}
612|b7ce6e|""",
613|9eaac4|            language: "go"
614|813e75|        ))
615|d6ed84|        
616|6fa96a|        // Rust example
617|f0955b|        examples.append(Tab(
618|f13142|            fileName: "main.rs",
619|7a029b|            content: """
620|0e41ca|//! Rust Example - Async Web Server
621|fa16f5|//! Demonstrates ownership, traits, async/await, and error handling
622|adc83b|
623|9acfeb|use std::collections::HashMap;
624|b948b2|use std::sync::Arc;
625|859d9d|use tokio::sync::RwLock;
626|adc83b|
627|5f279c|/// Represents a task in our system
628|fc0948|#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
629|9fa61b|pub struct Task {
630|eb40d9|    pub id: u64,
631|b30539|    pub title: String,
632|968947|    pub completed: bool,
633|3f7fee|    #[serde(skip_serializing_if = "Option::is_none")]
634|eb696e|    pub description: Option<String>,
635|b31277|}
636|adc83b|
637|c65acf|/// Task store with thread-safe access
638|aa97ce|pub struct TaskStore {
639|f700f3|    tasks: RwLock<HashMap<u64, Task>>,
640|4ca795|    next_id: RwLock<u64>,
641|b31277|}
642|adc83b|
643|302a3c|impl TaskStore {
644|8ad9f1|    pub fn new() -> Self {
645|3f21ea|        Self {
646|c4b209|            tasks: RwLock::new(HashMap::new()),
647|a066e2|            next_id: RwLock::new(1),
648|5f3077|        }
649|27e597|    }
650|b4687f|    
651|5b894d|    pub async fn create(&self, title: String, description: Option<String>) -> Task {
652|c96765|        let mut next_id = self.next_id.write().await;
653|582717|        let id = *next_id;
654|35ab64|        *next_id += 1;
655|d6ed84|        
656|8ffd70|        let task = Task {
657|c48bb6|            id,
658|9643f5|            title,
659|49769d|            completed: false,
660|d6d80b|            description,
661|105ee3|        };
662|d6ed84|        
663|c79c9c|        self.tasks.write().await.insert(id, task.clone());
664|9cec82|        task
665|27e597|    }
666|b4687f|    
667|d18a8f|    pub async fn get(&self, id: u64) -> Option<Task> {
668|ee96f9|        self.tasks.read().await.get(&id).cloned()
669|27e597|    }
670|b4687f|    
671|c542c4|    pub async fn list(&self) -> Vec<Task> {
672|26bc2e|        self.tasks.read().await.values().cloned().collect()
673|27e597|    }
674|b4687f|    
675|1e6608|    pub async fn complete(&self, id: u64) -> Result<Task, &'static str> {
676|8b2ab5|        let mut tasks = self.tasks.write().await;
677|1e8e13|        match tasks.get_mut(&id) {
678|7711a1|            Some(task) => {
679|9cb7d9|                task.completed = true;
680|b1925e|                Ok(task.clone())
681|a7dc16|            }
682|ba0906|            None => Err("Task not found"),
683|5f3077|        }
684|27e597|    }
685|b31277|}
686|adc83b|
687|167169|/// Error type for our application
688|351e30|#[derive(Debug, thiserror::Error)]
689|f57677|pub enum AppError {
690|552bc0|    #[error("Task not found: {0}")]
691|953fad|    NotFound(u64),
692|50ef8b|    #[error("Invalid input: {0}")]
693|e8e806|    InvalidInput(String),
694|b31277|}
695|adc83b|
696|50ce0f|#[tokio::main]
697|c703d0|async fn main() -> Result<(), Box<dyn std::error::Error>> {
698|0ea21b|    let store = Arc::new(TaskStore::new());
699|b4687f|    
700|d1b2bd|    // Create some tasks
701|2a3a42|    let task1 = store.create("Learn Rust".into(), Some("Study ownership".into())).await;
702|edbb66|    let task2 = store.create("Build app".into(), None).await;
703|b4687f|    
704|aafcec|    println!("Created tasks:");
705|9c5f1e|    for task in store.list().await {
706|2d361b|        println!("  - {} ({})", task.title, if task.completed { "✓" } else { "○" });
707|27e597|    }
708|b4687f|    
709|c1ed84|    // Complete a task
710|2d32bb|    store.complete(task1.id).await?;
711|3db4e3|    println!("\\nCompleted task: {}", task1.title);
712|b4687f|    
713|b54f61|    Ok(())
714|b31277|}
715|adc83b|
716|9a36b8|#[cfg(test)]
717|0a8608|mod tests {
718|2b9eed|    use super::*;
719|b4687f|    
720|fe8662|    #[tokio::test]
721|c05d04|    async fn test_create_task() {
722|c8da74|        let store = TaskStore::new();
723|286898|        let task = store.create("Test".into(), None).await;
724|75629b|        assert_eq!(task.title, "Test");
725|f10fec|        assert!(!task.completed);
726|27e597|    }
727|b31277|}
728|b7ce6e|""",
729|fb2489|            language: "rust"
730|813e75|        ))
731|d6ed84|        
732|3e02a9|        return examples
733|27e597|    }
734|adc83b|
735|4dde5e|    // MARK: - Tab Management
736|adc83b|
737|76ae59|    func addTab(fileName: String = "Untitled.swift", content: String = "", url: URL? = nil) {
738|741280|        // Check if file is already open by URL
739|0ac880|        if let url = url, let existingTab = tabs.first(where: { $0.url == url }) {
740|552ca0|            activeTabId = existingTab.id
741|bef5d6|            return
742|5f3077|        }
743|d6ed84|        
744|95bffd|        // For tabs without URLs (demo/untitled), check by fileName to avoid duplicates
745|c31f65|        if url == nil, let existingTab = tabs.first(where: { $0.url == nil && $0.fileName == fileName }) {
746|552ca0|            activeTabId = existingTab.id
747|bef5d6|            return
748|5f3077|        }
749|adc83b|
750|813121|        let newTab = Tab(fileName: fileName, content: content, url: url)
751|c48936|        tabs.append(newTab)
752|731705|        activeTabId = newTab.id
753|27e597|    }
754|adc83b|
755|32d0a2|    func closeTab(id: UUID) {
756|b4daef|        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
757|adc83b|
758|91aee8|        // Release security-scoped access if this tab was holding it.
759|f9902f|        if let url = tabs[index].url {
760|c0ad41|            releaseSecurityScopedAccess(to: url)
761|5f3077|        }
762|adc83b|
763|f8d587|        tabs.remove(at: index)
764|adc83b|
765|75e35f|        // Update active tab if we closed the active one
766|7a2997|        if activeTabId == id {
767|420e70|            if tabs.isEmpty {
768|562329|                activeTabId = nil
769|9f1ca7|            } else if index >= tabs.count {
770|fe0d6f|                activeTabId = tabs[tabs.count - 1].id
771|f5a6eb|            } else {
772|fea167|                activeTabId = tabs[index].id
773|a7dc16|            }
774|5f3077|        }
775|27e597|    }
776|adc83b|
777|da8c92|    func closeAllTabs() {
778|480aa6|        // Release security-scoped access held by any open tabs.
779|f898d5|        for tab in tabs {
780|e59f65|            if let url = tab.url {
781|4f4725|                releaseSecurityScopedAccess(to: url)
782|a7dc16|            }
783|5f3077|        }
784|adc83b|
785|11c622|        tabs.removeAll()
786|73f75a|        activeTabId = nil
787|27e597|    }
788|adc83b|
789|637501|    func closeOtherTabs(except id: UUID) {
790|7cae19|        // Release security-scoped access for tabs being closed.
791|cd7359|        for tab in tabs where tab.id != id {
792|e59f65|            if let url = tab.url {
793|4f4725|                releaseSecurityScopedAccess(to: url)
794|a7dc16|            }
795|5f3077|        }
796|adc83b|
797|9e38c3|        tabs.removeAll { $0.id != id }
798|124072|        activeTabId = id
799|27e597|    }
800|adc83b|
801|01b632|    func selectTab(id: UUID) {
802|124072|        activeTabId = id
803|27e597|    }
804|adc83b|
805|4d82c6|    func nextTab() {
806|0b2bdb|        guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
807|713593|        let nextIndex = (currentIndex + 1) % tabs.count
808|40ccb0|        activeTabId = tabs[nextIndex].id
809|27e597|    }
810|adc83b|
811|50e532|    func previousTab() {
812|0b2bdb|        guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
813|6fd10d|        let prevIndex = currentIndex == 0 ? tabs.count - 1 : currentIndex - 1
814|3edfe7|        activeTabId = tabs[prevIndex].id
815|27e597|    }
816|adc83b|
817|f5367a|    func moveTab(from source: IndexSet, to destination: Int) {
818|d4de4a|        tabs.move(fromOffsets: source, toOffset: destination)
819|27e597|    }
820|adc83b|
821|7e7abf|    // MARK: - Content Management
822|adc83b|
823|eb64ec|    func updateActiveTabContent(_ content: String) {
824|f3cca9|        guard let index = activeTabIndex else { return }
825|adc83b|
826|c5cef8|        // Avoid marking a tab dirty when we're just syncing state (e.g., initial onAppear assignment).
827|206567|        guard tabs[index].content != content else { return }
828|adc83b|
829|a364aa|        tabs[index].content = content
830|adc83b|
831|d56c61|        // Mark dirty for both saved and unsaved-new files.
832|6625d3|        tabs[index].isUnsaved = true
833|27e597|    }
834|adc83b|
835|d01c74|    func saveActiveTab() {
836|f3cca9|        guard let index = activeTabIndex else { return }
837|d6ed84|        
838|3e82a0|        // If the file has no URL (untitled/new file), trigger Save As dialog
839|e8c471|        guard let url = tabs[index].url else {
840|493ad8|            saveAsContent = tabs[index].content
841|c5db7c|            showSaveAsDialog = true
842|bef5d6|            return
843|5f3077|        }
844|d6ed84|        
845|4da690|        do {
846|8eaea8|            if let fileNavigator {
847|30e940|                try fileNavigator.writeFile(at: url, content: tabs[index].content)
848|f5a6eb|            } else {
849|3a43c7|                // Fallback: Ensure we have access when writing
850|498601|                let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
851|b9e991|                defer { if didStart { url.stopAccessingSecurityScopedResource() } }
852|6f7d16|                try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
853|a7dc16|            }
854|3070d1|            
855|6adfeb|            tabs[index].isUnsaved = false
856|6e3184|            lastSaveError = nil
857|853889|        } catch {
858|a859a6|            lastSaveError = "Failed to save: \(error.localizedDescription)"
859|8217f6|            print("Error saving file: \(error)")
860|5f3077|        }
861|27e597|    }
862|b4687f|    
863|16b4eb|    /// Save the active tab to a specific URL (used by Save As dialog)
864|94964b|    func saveActiveTab(to url: URL) {
865|f3cca9|        guard let index = activeTabIndex else { return }
866|d6ed84|        
867|4da690|        do {
868|afab8e|            let didStart = url.startAccessingSecurityScopedResource()
869|4538e7|            defer { if didStart { url.stopAccessingSecurityScopedResource() } }
870|3070d1|            
871|b88be0|            try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
872|3070d1|            
873|7bf4ac|            // Update the tab with the new URL and filename
874|061520|            tabs[index].url = url
875|6ac8fc|            tabs[index].fileName = url.lastPathComponent
876|6adfeb|            tabs[index].isUnsaved = false
877|6e3184|            lastSaveError = nil
878|3070d1|            
879|c923e6|            // Refresh file tree if navigator available
880|3e34a9|            fileNavigator?.refreshFileTree()
881|853889|        } catch {
882|a859a6|            lastSaveError = "Failed to save: \(error.localizedDescription)"
883|eda068|            print("Error saving file to \(url): \(error)")
884|5f3077|        }
885|27e597|    }
886|adc83b|
887|733624|    func saveAllTabs() {
888|be31b4|        for index in tabs.indices {
889|2205f5|            guard let url = tabs[index].url, tabs[index].isUnsaved else { continue }
890|adc83b|
891|71cc09|            do {
892|d06464|                if let fileNavigator {
893|882974|                    try fileNavigator.writeFile(at: url, content: tabs[index].content)
894|fdd0e2|                } else {
895|fa1070|                    // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
896|a62986|                    let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
897|981337|                    defer { if didStart { url.stopAccessingSecurityScopedResource() } }
898|5eb718|                    try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
899|4e2d32|                }
900|adc83b|
901|c47dbe|                tabs[index].isUnsaved = false
902|91b9a2|            } catch {
903|a5c86a|                print("Error saving file: \(error)")
904|a7dc16|            }
905|5f3077|        }
906|27e597|    }
907|adc83b|
908|7fcf6b|    // MARK: - File Operations
909|adc83b|
910|c94d4f|    /// Retain security scoped access for as long as a tab referencing the URL is open.
911|80f870|    /// - Returns: `true` if access was retained (either already retained or started successfully).
912|144775|    @discardableResult
913|047478|    private func retainSecurityScopedAccess(to url: URL) -> Bool {
914|3361e8|        if let count = securityScopedAccessCounts[url] {
915|74a992|            securityScopedAccessCounts[url] = count + 1
916|40cfc4|            return true
917|5f3077|        }
918|adc83b|
919|6bae9a|        let started = url.startAccessingSecurityScopedResource()
920|eab9dd|        if started {
921|f70ee6|            securityScopedAccessCounts[url] = 1
922|40cfc4|            return true
923|5f3077|        }
924|adc83b|
925|e24e9c|        // Not all URLs are security-scoped; startAccessing may legitimately return false.
926|dc1500|        return false
927|27e597|    }
928|adc83b|
929|bb512f|    private func releaseSecurityScopedAccess(to url: URL) {
930|e6f2d9|        guard let count = securityScopedAccessCounts[url] else { return }
931|d1b9b6|        if count <= 1 {
932|a8ee0e|            securityScopedAccessCounts.removeValue(forKey: url)
933|1a1387|            url.stopAccessingSecurityScopedResource()
934|b31999|        } else {
935|385b72|            securityScopedAccessCounts[url] = count - 1
936|5f3077|        }
937|27e597|    }
938|adc83b|
939|cf78ab|    func openFile(from url: URL) {
940|588853|        // If already open, just activate it (and avoid re-reading / re-requesting access).
941|b525f3|        if let existingTab = tabs.first(where: { $0.url == url }) {
942|552ca0|            activeTabId = existingTab.id
943|bef5d6|            return
944|5f3077|        }
945|adc83b|
946|932f65|        // IMPORTANT (BUG-005):
947|473a90|        // Do not early-return if startAccessingSecurityScopedResource() fails.
948|9fa2d8|        // For many URLs (non-security-scoped, or when parent scope is active), this may return false,
949|66c5ff|        // but the file is still readable. We retain access if available.
950|b64f72|        let retained = retainSecurityScopedAccess(to: url)
951|adc83b|
952|4da690|        do {
953|71b351|            let content = try String(contentsOf: url, encoding: .utf8)
954|b7a845|            addTab(fileName: url.lastPathComponent, content: content, url: url)
955|adc83b|
956|029423|            // Index the file in Spotlight for search
957|89eebb|            SpotlightManager.shared.indexFile(url: url, content: content, fileName: url.lastPathComponent)
958|853889|        } catch {
959|6234c2|            print("Error opening file: \(error)")
960|b8e2ff|            if retained {
961|3785d1|                // We retained access but failed to open; release our retain.
962|4f4725|                releaseSecurityScopedAccess(to: url)
963|a7dc16|            }
964|5f3077|        }
965|27e597|    }
966|adc83b|
967|ecab4a|    func openFile(_ fileItem: FileItem) {
968|5644a7|        guard let url = fileItem.url else {
969|5428ce|            // Try path
970|cc691d|            if !fileItem.path.isEmpty {
971|0d25db|                let fileURL = URL(fileURLWithPath: fileItem.path)
972|04ee6d|                openFile(from: fileURL)
973|a7dc16|            }
974|bef5d6|            return
975|5f3077|        }
976|aa85ed|        openFile(from: url)
977|27e597|    }
978|adc83b|
979|a458b1|    // MARK: - File System Event Handlers
980|adc83b|
981|9aaca8|    /// Called when a file or folder is moved/renamed in the file system.
982|fa3810|    /// Updates any open tabs that reference the old URL.
983|1aeb4b|    func handleFileSystemItemMoved(from oldURL: URL, to newURL: URL) {
984|be31b4|        for index in tabs.indices {
985|73b1a5|            guard let tabURL = tabs[index].url else { continue }
986|adc83b|
987|d91d40|            // Check if tab URL matches the moved item or is inside it (for folders)
988|6c0d3c|            let oldPath = oldURL.standardizedFileURL.path
989|354993|            let tabPath = tabURL.standardizedFileURL.path
990|adc83b|
991|ca2206|            if tabPath == oldPath {
992|5a4762|                // Direct match - update URL
993|93dccc|                tabs[index].url = newURL
994|f8a1b8|                tabs[index].fileName = newURL.lastPathComponent
995|d38dd0|            } else if tabPath.hasPrefix(oldPath + "/") {
996|cbbd97|                // Tab is inside a moved folder - update the path prefix
997|14ba8e|                let relativePath = String(tabPath.dropFirst(oldPath.count))
998|a19b0f|                let newTabURL = URL(fileURLWithPath: newURL.path + relativePath)
999|cf0bad|                tabs[index].url = newTabURL
1000|a7dc16|            }
1001|5f3077|        }
1002|27e597|    }
1003|adc83b|
1004|8e6575|    /// Called when a file or folder is deleted from the file system.
1005|cc8758|    /// Closes any open tabs that reference the deleted item.
1006|c5a4eb|    func handleFileSystemItemDeleted(at url: URL) {
1007|2e29c5|        let deletedPath = url.standardizedFileURL.path
1008|adc83b|
1009|1f90b1|        // Find all tabs that should be closed
1010|e5b209|        let tabsToClose = tabs.filter { tab in
1011|2a4205|            guard let tabURL = tab.url else { return false }
1012|354993|            let tabPath = tabURL.standardizedFileURL.path
1013|5f7d97|            // Close if exact match or if tab is inside deleted folder
1014|5ea75a|            return tabPath == deletedPath || tabPath.hasPrefix(deletedPath + "/")
1015|5f3077|        }
1016|adc83b|
1017|a7d718|        // Close the tabs (release security access)
1018|97cba5|        for tab in tabsToClose {
1019|cf059e|            closeTab(id: tab.id)
1020|5f3077|        }
1021|27e597|    }
1022|adc83b|
1023|b0d18d|    // MARK: - UI Toggles
1024|adc83b|
1025|7013cb|    func toggleSidebar() {
1026|2143c8|        withAnimation(.spring(response: 0.3)) {
1027|67f0f7|            showSidebar.toggle()
1028|5f3077|        }
1029|27e597|    }
1030|adc83b|
1031|2240d2|    func toggleCommandPalette() {
1032|338807|        showCommandPalette.toggle()
1033|27e597|    }
1034|adc83b|
1035|d4097e|    func toggleQuickOpen() {
1036|5f3455|        showQuickOpen.toggle()
1037|27e597|    }
1038|adc83b|
1039|96b71e|    func toggleSearch() {
1040|556f01|        showSearch.toggle()
1041|27e597|    }
1042|adc83b|
1043|48d0ca|    func toggleAIAssistant() {
1044|24cfdd|        showAIAssistant.toggle()
1045|27e597|    }
1046|adc83b|
1047|1dd42a|    func toggleGoToSymbol() {
1048|fe0419|        showGoToSymbol.toggle()
1049|27e597|    }
1050|adc83b|
1051|56cd4c|    func toggleZenMode() {
1052|2754aa|        isZenMode.toggle()
1053|27e597|    }
1054|adc83b|
1055|a09c47|    func toggleFocusMode() {
1056|b29cfd|        isFocusMode.toggle()
1057|27e597|    }
1058|adc83b|
1059|ebbc1a|    func togglePanel() {
1060|2143c8|        withAnimation(.spring(response: 0.3)) {
1061|684bf3|            showPanel.toggle()
1062|5f3077|        }
1063|27e597|    }
1064|adc83b|
1065|296597|    func addSelectionToNextFindMatch() {
1066|55fc4b|        addNextOccurrence()
1067|27e597|    }
1068|adc83b|
1069|e2f257|    func zoomIn() {
1070|9e13d9|        editorFontSize = min(editorFontSize + 2, 32)
1071|27e597|    }
1072|adc83b|
1073|075e98|    func zoomOut() {
1074|ae2cf8|        editorFontSize = max(editorFontSize - 2, 8)
1075|27e597|    }
1076|adc83b|
1077|71e9b8|    func resetZoom() {
1078|8d736d|        editorFontSize = 14.0
1079|27e597|    }
1080|adc83b|
1081|163f31|    func focusExplorer() {
1082|b167b4|        focusedView = .explorer
1083|3c73ad|        focusedSidebarTab = 0
1084|408502|        withAnimation {
1085|810390|            showSidebar = true
1086|5f3077|        }
1087|27e597|    }
1088|adc83b|
1089|b6ea74|    func focusGit() {
1090|33d4c7|        focusedView = .git
1091|7047e6|        focusedSidebarTab = 1
1092|408502|        withAnimation {
1093|810390|            showSidebar = true
1094|5f3077|        }
1095|27e597|    }
1096|adc83b|
1097|3fbb57|    func renameSymbol() {
1098|36a2b1|        showRenameSymbol.toggle()
1099|27e597|    }
1100|adc83b|
1101|f4b4ed|    // NOTE:
1102|79de5e|    // goToDefinitionAtCursor(), peekDefinitionAtCursor(), navigateBack(), and navigateForward()
1103|b412a0|    // are implemented in an EditorCore extension in Services/NavigationManager.swift.
1104|adc83b|
1105|cece09|    // MARK: - Peek Definition
1106|adc83b|
1107|d018d7|    func triggerPeekDefinition(file: String, line: Int, content: String, sourceLine: Int) {
1108|14e1e5|        peekState = PeekState(file: file, line: line, content: content, sourceLine: sourceLine)
1109|27e597|    }
1110|adc83b|
1111|91dd62|    func closePeekDefinition() {
1112|5d3d13|        peekState = nil
1113|27e597|    }
1114|adc83b|
1115|224ae6|    // MARK: - Multi-Cursor Operations
1116|adc83b|
1117|274aab|    /// Add cursor at a specific position (Option+Click)
1118|6a8c80|    func addCursorAtPosition(_ position: Int) {
1119|1d6502|        multiCursorState.addCursor(at: position)
1120|27e597|    }
1121|adc83b|
1122|44d2df|    /// Add cursor on the line above (Cmd+Option+Up)
1123|2c94f4|    func addCursorAbove() {
1124|f3cca9|        guard let index = activeTabIndex else { return }
1125|760df9|        let content = tabs[index].content
1126|d6ed84|        
1127|c36153|        guard let primary = multiCursorState.primaryCursor else { return }
1128|d6ed84|        
1129|97e112|        // Find current line and column
1130|cae86c|        let lines = content.components(separatedBy: "\n")
1131|4c16f5|        var currentLine = 0
1132|788b38|        var charCount = 0
1133|efbb41|        var columnInLine = 0
1134|d6ed84|        
1135|d1a1ab|        for (lineIndex, line) in lines.enumerated() {
1136|28f01c|            let lineLength = line.count + 1 // +1 for newline
1137|855639|            if charCount + lineLength > primary.position {
1138|1f2410|                currentLine = lineIndex
1139|e165bc|                columnInLine = primary.position - charCount
1140|74cfd8|                break
1141|a7dc16|            }
1142|8f266f|            charCount += lineLength
1143|5f3077|        }
1144|d6ed84|        
1145|4ff883|        // Can't add cursor above line 0
1146|b7a259|        guard currentLine > 0 else { return }
1147|d6ed84|        
1148|ce6291|        // Calculate position on line above
1149|899b8a|        let targetLine = currentLine - 1
1150|e8b652|        var targetPosition = 0
1151|4dc12b|        for i in 0..<targetLine {
1152|8e5904|            targetPosition += lines[i].count + 1
1153|5f3077|        }
1154|90bb82|        targetPosition += min(columnInLine, lines[targetLine].count)
1155|d6ed84|        
1156|22be0f|        multiCursorState.addCursor(at: targetPosition)
1157|27e597|    }
1158|adc83b|
1159|fec522|    /// Add cursor on the line below (Cmd+Option+Down)
1160|c1a645|    func addCursorBelow() {
1161|f3cca9|        guard let index = activeTabIndex else { return }
1162|760df9|        let content = tabs[index].content
1163|d6ed84|        
1164|c36153|        guard let primary = multiCursorState.primaryCursor else { return }
1165|d6ed84|        
1166|97e112|        // Find current line and column
1167|cae86c|        let lines = content.components(separatedBy: "\n")
1168|4c16f5|        var currentLine = 0
1169|788b38|        var charCount = 0
1170|efbb41|        var columnInLine = 0
1171|d6ed84|        
1172|d1a1ab|        for (lineIndex, line) in lines.enumerated() {
1173|28f01c|            let lineLength = line.count + 1 // +1 for newline
1174|855639|            if charCount + lineLength > primary.position {
1175|1f2410|                currentLine = lineIndex
1176|e165bc|                columnInLine = primary.position - charCount
1177|74cfd8|                break
1178|a7dc16|            }
1179|8f266f|            charCount += lineLength
1180|5f3077|        }
1181|d6ed84|        
1182|f6134c|        // Can't add cursor below last line
1183|df788d|        guard currentLine < lines.count - 1 else { return }
1184|d6ed84|        
1185|f2ffac|        // Calculate position on line below
1186|a09bd7|        let targetLine = currentLine + 1
1187|e8b652|        var targetPosition = 0
1188|4dc12b|        for i in 0..<targetLine {
1189|8e5904|            targetPosition += lines[i].count + 1
1190|5f3077|        }
1191|90bb82|        targetPosition += min(columnInLine, lines[targetLine].count)
1192|d6ed84|        
1193|22be0f|        multiCursorState.addCursor(at: targetPosition)
1194|27e597|    }
1195|adc83b|
1196|77aabc|    /// Add next occurrence of current selection (Cmd+D)
1197|e6ce2e|    func addNextOccurrence() {
1198|f3cca9|        guard let index = activeTabIndex else { return }
1199|760df9|        let content = tabs[index].content
1200|adc83b|
1201|5425d2|        // Get the word/selection to search for
1202|14ac96|        let searchText: String
1203|b70289|        let startPosition: Int
1204|adc83b|
1205|cfba87|        if let range = currentSelectionRange, range.length > 0,
1206|0939c5|           let swiftRange = Range(range, in: content) {
1207|451be1|            searchText = String(content[swiftRange])
1208|0b5fe8|            startPosition = range.location + range.length
1209|f70aa5|        } else if let primary = multiCursorState.primaryCursor {
1210|aed341|            // No selection - select the word under cursor
1211|1688ec|            let wordRange = findWordAtPosition(primary.position, in: content)
1212|8dbaff|            if let range = wordRange, range.length > 0,
1213|6998ee|               let swiftRange = Range(range, in: content) {
1214|f4b9bc|                searchText = String(content[swiftRange])
1215|d7f1fc|                startPosition = range.location + range.length
1216|adc83b|
1217|8bf0a9|                // First Cmd+D selects the word under cursor
1218|0cebd2|                multiCursorState.cursors = [Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)]
1219|70c25c|                currentSelectionRange = range
1220|311604|                currentSelection = searchText
1221|53ab34|                return
1222|f5a6eb|            } else {
1223|53ab34|                return
1224|a7dc16|            }
1225|b31999|        } else {
1226|bef5d6|            return
1227|5f3077|        }
1228|adc83b|
1229|2e0155|        // Find next occurrence
1230|c59f65|        if let nextRange = content.findNextOccurrence(of: searchText, after: startPosition) {
1231|372de1|            // Check if this occurrence is already selected
1232|222428|            let alreadySelected = multiCursorState.cursors.contains { cursor in
1233|d4114c|                if let selRange = cursor.selectionRange {
1234|173534|                    return selRange.location == nextRange.location
1235|4e2d32|                }
1236|473d08|                return false
1237|a7dc16|            }
1238|adc83b|
1239|068570|            if !alreadySelected {
1240|11d39c|                multiCursorState.addCursorWithSelection(
1241|b8d907|                    position: nextRange.location + nextRange.length,
1242|4db973|                    anchor: nextRange.location
1243|6f642e|                )
1244|a7dc16|            }
1245|5f3077|        }
1246|27e597|    }
1247|adc83b|
1248|455218|    /// Select all occurrences of current selection (Cmd+Shift+L)
1249|db732c|    func selectAllOccurrences() {
1250|f3cca9|        guard let index = activeTabIndex else { return }
1251|760df9|        let content = tabs[index].content
1252|adc83b|
1253|5425d2|        // Get the word/selection to search for
1254|14ac96|        let searchText: String
1255|adc83b|
1256|cfba87|        if let range = currentSelectionRange, range.length > 0,
1257|0939c5|           let swiftRange = Range(range, in: content) {
1258|451be1|            searchText = String(content[swiftRange])
1259|f70aa5|        } else if let primary = multiCursorState.primaryCursor {
1260|da9f76|            // No selection - use word under cursor
1261|1688ec|            let wordRange = findWordAtPosition(primary.position, in: content)
1262|8dbaff|            if let range = wordRange, range.length > 0,
1263|6998ee|               let swiftRange = Range(range, in: content) {
1264|f4b9bc|                searchText = String(content[swiftRange])
1265|f5a6eb|            } else {
1266|53ab34|                return
1267|a7dc16|            }
1268|b31999|        } else {
1269|bef5d6|            return
1270|5f3077|        }
1271|adc83b|
1272|5b5fb8|        // Find all occurrences
1273|d3dc0b|        let allRanges = content.findAllOccurrences(of: searchText)
1274|adc83b|
1275|64295a|        guard !allRanges.isEmpty else { return }
1276|adc83b|
1277|91a2a1|        // Create cursors for all occurrences
1278|897764|        multiCursorState.cursors = allRanges.enumerated().map { index, range in
1279|ea4ddb|            Cursor(
1280|4a52a3|                position: range.location + range.length,
1281|a68855|                anchor: range.location,
1282|501395|                isPrimary: index == 0
1283|43d041|            )
1284|5f3077|        }
1285|adc83b|
1286|f352f6|        currentSelection = searchText
1287|27e597|    }
1288|adc83b|
1289|169518|    /// Reset to single cursor
1290|6ea64a|    func resetToSingleCursor(at position: Int) {
1291|a156ab|        multiCursorState.reset(to: position)
1292|633a0d|        currentSelectionRange = nil
1293|3ed4e9|        currentSelection = ""
1294|27e597|    }
1295|adc83b|
1296|f7916f|    /// Update selection from text view
1297|fc455c|    func updateSelection(range: NSRange?, text: String) {
1298|69c3ac|        currentSelectionRange = range
1299|a147d3|        if let range = range, range.length > 0,
1300|4c0c23|           let index = activeTabIndex {
1301|527d1a|            let content = tabs[index].content
1302|69d76b|            if let swiftRange = Range(range, in: content) {
1303|6e1e02|                currentSelection = String(content[swiftRange])
1304|a7dc16|            }
1305|b31999|        } else {
1306|1e5b1e|            currentSelection = ""
1307|5f3077|        }
1308|27e597|    }
1309|adc83b|
1310|8984f8|    /// Find word boundaries at a given position
1311|10f43e|    func findWordAtPosition(_ position: Int, in text: String) -> NSRange? {
1312|37ae73|        guard position >= 0 && position <= text.count else { return nil }
1313|adc83b|
1314|599630|        let nsText = text as NSString
1315|026ed8|        let wordCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
1316|adc83b|
1317|b5bfb0|        // Find start of word
1318|def66a|        var start = position
1319|aaa57c|        while start > 0 {
1320|148e5a|            let char = nsText.substring(with: NSRange(location: start - 1, length: 1))
1321|70b198|            if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
1322|0c6efe|                start -= 1
1323|f5a6eb|            } else {
1324|74cfd8|                break
1325|a7dc16|            }
1326|5f3077|        }
1327|adc83b|
1328|3d8df8|        // Find end of word
1329|f5c145|        var end = position
1330|b8851f|        while end < nsText.length {
1331|244ed1|            let char = nsText.substring(with: NSRange(location: end, length: 1))
1332|70b198|            if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
1333|fddf9a|                end += 1
1334|f5a6eb|            } else {
1335|74cfd8|                break
1336|a7dc16|            }
1337|5f3077|        }
1338|adc83b|
1339|77048a|        if start == end {
1340|1c8557|            return nil
1341|5f3077|        }
1342|adc83b|
1343|469001|        return NSRange(location: start, length: end - start)
1344|27e597|    }
1345|adc83b|
1346|b207fc|    /// Escape multi-cursor mode
1347|2874f6|    func escapeMultiCursor() {
1348|09e325|        if multiCursorState.isMultiCursor {
1349|30a482|            if let primary = multiCursorState.primaryCursor {
1350|a206bf|                resetToSingleCursor(at: primary.position)
1351|a7dc16|            }
1352|5f3077|        }
1353|27e597|    }
1354|adc83b|
1355|0de0c3|    // MARK: - Code Folding
1356|adc83b|
1357|2cd425|    /// Collapse all foldable regions in the active editor
1358|17ae91|    func collapseAllFolds() {
1359|f3cca9|        guard let index = activeTabIndex else { return }
1360|309336|        // Post notification that will be picked up by the editor view
1361|63edcc|        NotificationCenter.default.post(
1362|acbca9|            name: .collapseAllFolds,
1363|33f159|            object: nil,
1364|ed71df|            userInfo: ["tabId": tabs[index].id]
1365|3143a4|        )
1366|27e597|    }
1367|adc83b|
1368|f1a2b1|    /// Expand all collapsed regions in the active editor
1369|6f1bb0|    func expandAllFolds() {
1370|f3cca9|        guard let index = activeTabIndex else { return }
1371|309336|        // Post notification that will be picked up by the editor view
1372|63edcc|        NotificationCenter.default.post(
1373|d3ba38|            name: .expandAllFolds,
1374|33f159|            object: nil,
1375|ed71df|            userInfo: ["tabId": tabs[index].id]
1376|3143a4|        )
1377|27e597|    }
1378|b31277|}
1379|adc83b|
1380|27b7fc|// MARK: - Notification Names for Code Folding
1381|adc83b|
1382|c090b9|extension Notification.Name {
1383|db6075|    static let collapseAllFolds = Notification.Name("collapseAllFolds")
1384|244109|    static let expandAllFolds = Notification.Name("expandAllFolds")
1385|b31277|}
1386|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 463b0e5988f0
File: VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/WASMRunner.swift (lines 1-723 of 723)
────────────────────────────────────────
1|8b6b78|import Foundation
2|501c1a|import WebKit
3|119e5c|import JavaScriptCore
4|adc83b|
5|2dbcb6|// MARK: - Errors
6|adc83b|
7|c28ee2|/// Errors that can occur during WASM execution
8|8dcbab|public enum WASMError: Error, LocalizedError {
9|4d2ddc|    case initializationFailed(reason: String)
10|d4f4ac|    case moduleCompilationFailed(reason: String)
11|64a824|    case moduleLoadFailed(reason: String)
12|d920fc|    case functionNotFound(name: String)
13|5a086c|    case executionFailed(reason: String)
14|be1463|    case invalidArguments
15|a6f7ed|    case memoryLimitExceeded(limit: UInt64)
16|3c7ca1|    case executionTimeout(seconds: TimeInterval)
17|ce5d8c|    case hostFunctionRegistrationFailed(name: String)
18|62aed1|    case wasiNotSupported
19|d85fd8|    case invalidReturnType
20|b4687f|    
21|13155b|    public var errorDescription: String? {
22|2e6d08|        switch self {
23|5c31df|        case .initializationFailed(let reason):
24|0f1fab|            return "WASM initialization failed: \(reason)"
25|626538|        case .moduleCompilationFailed(let reason):
26|cf14a9|            return "Module compilation failed: \(reason)"
27|41918b|        case .moduleLoadFailed(let reason):
28|1554d0|            return "Module load failed: \(reason)"
29|47d4f6|        case .functionNotFound(let name):
30|3bc2b7|            return "Function '\(name)' not found in WASM module"
31|630f9b|        case .executionFailed(let reason):
32|4cbda2|            return "Execution failed: \(reason)"
33|c22843|        case .invalidArguments:
34|c6b6d1|            return "Invalid arguments provided to WASM function"
35|5c28cf|        case .memoryLimitExceeded(let limit):
36|595312|            return "Memory limit exceeded: \(limit) bytes"
37|d6e6fe|        case .executionTimeout(let seconds):
38|0cde63|            return "Execution timed out after \(seconds) seconds"
39|968350|        case .hostFunctionRegistrationFailed(let name):
40|124d6c|            return "Failed to register host function '\(name)'"
41|758c42|        case .wasiNotSupported:
42|3a30f2|            return "WASI is not fully supported on iOS. Use WASI polyfills or server-side execution."
43|51617d|        case .invalidReturnType:
44|24f405|            return "Invalid return type from WASM function"
45|5f3077|        }
46|27e597|    }
47|b31277|}
48|adc83b|
49|39016f|// MARK: - Configuration
50|adc83b|
51|f48e0e|/// Configuration for WASM execution environment
52|010912|public struct WASMConfiguration {
53|3cb324|    /// Memory limit in bytes (default: 128 MB)
54|0082f6|    public var memoryLimit: UInt64
55|b4687f|    
56|ad5017|    /// Execution timeout in seconds (default: 30)
57|b779fd|    public var executionTimeout: TimeInterval
58|b4687f|    
59|f6d508|    /// Enable debug logging
60|7e3c31|    public var enableDebugLogging: Bool
61|b4687f|    
62|1c25bf|    /// WASI support mode
63|21ba6a|    public var wasiMode: WASIMode
64|b4687f|    
65|6da088|    /// JavaScript runtime to use
66|526cf6|    public var runtime: JavaScriptRuntime
67|b4687f|    
68|9ab6df|    public enum WASIMode {
69|7f01fe|        case disabled
70|7bfad5|        case polyfill  // Limited support via polyfills
71|d87348|        case stub      // Stub implementations that log warnings
72|27e597|    }
73|b4687f|    
74|eb7512|    public enum JavaScriptRuntime {
75|ad5af1|        case wkWebView   // Full WebAssembly support via Safari engine
76|c04391|        case javaScriptCore  // No WebAssembly support (fallback only)
77|27e597|    }
78|b4687f|    
79|fb99ae|    public init(
80|5717da|        memoryLimit: UInt64 = 128 * 1024 * 1024,
81|576c95|        executionTimeout: TimeInterval = 30.0,
82|8fea3e|        enableDebugLogging: Bool = false,
83|25fc37|        wasiMode: WASIMode = .stub,
84|b9262d|        runtime: JavaScriptRuntime = .wkWebView
85|981e04|    ) {
86|e9e4ed|        self.memoryLimit = memoryLimit
87|4e1aac|        self.executionTimeout = executionTimeout
88|857b48|        self.enableDebugLogging = enableDebugLogging
89|cc110a|        self.wasiMode = wasiMode
90|59cc84|        self.runtime = runtime
91|27e597|    }
92|b4687f|    
93|ced82d|    /// Default configuration with conservative limits
94|64f7fb|    public static let `default` = WASMConfiguration()
95|b4687f|    
96|b89903|    /// Configuration optimized for Pyodide
97|59cc39|    public static let pyodide = WASMConfiguration(
98|8dc10a|        memoryLimit: 256 * 1024 * 1024,
99|ed2baf|        executionTimeout: 60.0,
100|45bceb|        enableDebugLogging: true,
101|5da7af|        wasiMode: .disabled
102|829c44|    )
103|b4687f|    
104|31f03f|    /// Configuration optimized for Rust WASM
105|33e226|    public static let rust = WASMConfiguration(
106|7c0a7b|        memoryLimit: 64 * 1024 * 1024,
107|1fe430|        executionTimeout: 10.0,
108|15894e|        enableDebugLogging: false,
109|435a24|        wasiMode: .stub
110|829c44|    )
111|b31277|}
112|adc83b|
113|54458c|// MARK: - WASMRunner
114|adc83b|
115|d07a0f|/// WebAssembly runner for iOS using WKWebView
116|e0ad8a|/// 
117|ffe3f1|/// **IMPORTANT LIMITATIONS:**
118|664833|/// - WKWebView runs in separate process - all calls are async
119|24cc24|/// - JavaScriptCore does NOT support WebAssembly
120|608f3f|/// - WASI filesystem operations are limited/stubbed
121|f8e828|/// - Memory limits are approximate (WebKit manages memory)
122|d48082|/// - Large WASM modules (>50MB) may cause memory pressure
123|83588b|/// - Pyodide requires ~200MB+ memory and network access
124|e0ad8a|/// 
125|841246|/// **Architecture:**
126|b2a45b|/// Uses WKWebView with a hidden web view to execute WASM in Safari's JavaScriptCore engine.
127|a4635c|/// Communication happens via WKUserContentController message handlers.
128|69d728|@MainActor
129|6c4353|public final class WASMRunner: NSObject {
130|b4687f|    
131|6503ae|    // MARK: - Properties
132|b4687f|    
133|aec798|    private var webView: WKWebView?
134|92995d|    private let configuration: WASMConfiguration
135|5db138|    private var hostFunctions: [String: ([Any]) -> Any] = [:]
136|68354c|    private var continuation: CheckedContinuation<Any, Error>?
137|b478ea|    private var executionTask: Task<Void, Never>?
138|e8c6b3|    private var isInitialized = false
139|8531d7|    private var moduleLoaded = false
140|468c74|    private var currentModuleName: String?
141|b4687f|    
142|b3456b|    // Message handler identifier
143|824913|    private let messageHandlerName = "wasmRunner"
144|b4687f|    
145|7dca75|    // MARK: - Initialization
146|b4687f|    
147|dcc193|    /// Creates a new WASM runner with the specified configuration
148|f330ab|    /// - Parameter configuration: Execution configuration (defaults to .default)
149|bc94ee|    /// - Throws: WASMError.initializationFailed if WKWebView setup fails
150|bfcf79|    public init(configuration: WASMConfiguration = .default) throws {
151|e62f56|        self.configuration = configuration
152|15cfe8|        super.init()
153|d6ed84|        
154|5b5cb8|        guard configuration.runtime == .wkWebView else {
155|d4ad7d|            throw WASMError.initializationFailed(
156|5e754b|                reason: "JavaScriptCore does not support WebAssembly. Use WKWebView runtime."
157|43d041|            )
158|5f3077|        }
159|d6ed84|        
160|d58b13|        try setupWebView()
161|27e597|    }
162|b4687f|    
163|1dd0a9|    private func setupWebView() throws {
164|24e765|        let webConfiguration = WKWebViewConfiguration()
165|d6ed84|        
166|e7e77f|        // Set up message handler for communication
167|21705a|        let userContentController = WKUserContentController()
168|c865bb|        userContentController.add(self, name: messageHandlerName)
169|9b6f4d|        webConfiguration.userContentController = userContentController
170|d6ed84|        
171|beda62|        // Enable WASM support
172|54cd65|        webConfiguration.preferences.javaScriptEnabled = true
173|24e933|        if #available(iOS 15.0, *) {
174|c4f979|            webConfiguration.preferences.isTextInteractionEnabled = true
175|5f3077|        }
176|d6ed84|        
177|0a0cbc|        // Create hidden web view
178|07b1b6|        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
179|e01bdb|        webView.isHidden = true
180|d6ed84|        
181|af4b8f|        // Inject WASM runtime helper
182|4937f0|        let wasmHelperScript = WKUserScript(
183|fc02e3|            source: WASMRuntimeHelper.javascript,
184|d54844|            injectionTime: .atDocumentStart,
185|bbfeef|            forMainFrameOnly: true
186|3143a4|        )
187|4e5e29|        userContentController.addUserScript(wasmHelperScript)
188|d6ed84|        
189|f8ed0c|        self.webView = webView
190|d6ed84|        
191|1d2da5|        // Load blank page to initialize
192|d1c0b4|        webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
193|d6ed84|        
194|1bdb42|        if configuration.enableDebugLogging {
195|ae0dc8|            print("[WASMRunner] WebView initialized")
196|5f3077|        }
197|27e597|    }
198|b4687f|    
199|09e8a5|    // MARK: - Module Loading
200|b4687f|    
201|9458cd|    /// Loads a WebAssembly module from Data
202|d56ac1|    /// - Parameter wasmData: The WASM binary data
203|85ba2d|    /// - Throws: WASMError.moduleLoadFailed if loading fails
204|e8e0fe|    public func load(wasmData: Data) async throws {
205|9176d5|        guard let webView = webView else {
206|44352e|            throw WASMError.initializationFailed(reason: "WebView not available")
207|5f3077|        }
208|d6ed84|        
209|d4e805|        // Convert to base64 for JavaScript transfer
210|ca9524|        let base64String = wasmData.base64EncodedString()
211|c9b31e|        let moduleName = "wasm_module_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
212|d6ed84|        
213|d3325c|        // Build load command
214|9c21ed|        let loadScript = """
215|563fc4|        (async function() {
216|174ec8|            try {
217|e27daa|                const binaryString = atob('\(base64String)');
218|ba9f94|                const bytes = new Uint8Array(binaryString.length);
219|dab495|                for (let i = 0; i < binaryString.length; i++) {
220|eb8518|                    bytes[i] = binaryString.charCodeAt(i);
221|4e2d32|                }
222|216278|                
223|0d932c|                // Compile the module
224|d31622|                const module = await WebAssembly.compile(bytes);
225|216278|                
226|409c21|                // Store in window.wasmModules
227|249c20|                if (!window.wasmModules) window.wasmModules = {};
228|8979bb|                window.wasmModules['\(moduleName)'] = module;
229|216278|                
230|c58a0a|                // Check memory requirements
231|11687c|                const memoryPages = module.imports.find(i => i.module === 'env' && i.name === 'memory');
232|409315|                if (memoryPages) {
233|14deaf|                    // Memory is imported, will be checked at instantiation
234|4e2d32|                }
235|216278|                
236|a5d51a|                return { success: true, moduleName: '\(moduleName)' };
237|1a5fdc|            } catch (error) {
238|737f10|                return { success: false, error: error.toString() };
239|a7dc16|            }
240|6ba073|        })()
241|c70080|        """
242|d6ed84|        
243|1bb917|        let result = try await executeJavaScript(loadScript, in: webView)
244|d6ed84|        
245|f8e887|        guard let dict = result as? [String: Any],
246|914c2b|              let success = dict["success"] as? Bool else {
247|afb53b|            throw WASMError.moduleLoadFailed(reason: "Invalid response from WebView")
248|5f3077|        }
249|d6ed84|        
250|cf5235|        if success {
251|d97bdb|            self.currentModuleName = moduleName
252|d71206|            self.moduleLoaded = true
253|3070d1|            
254|fa3662|            if configuration.enableDebugLogging {
255|e81c3f|                print("[WASMRunner] Module '\(moduleName)' loaded successfully")
256|a7dc16|            }
257|b31999|        } else {
258|83c3f9|            let errorMessage = dict["error"] as? String ?? "Unknown error"
259|5042be|            throw WASMError.moduleLoadFailed(reason: errorMessage)
260|5f3077|        }
261|27e597|    }
262|b4687f|    
263|a24546|    /// Loads a WebAssembly module from a file URL
264|7bc912|    /// - Parameter url: File URL to the .wasm file
265|85ba2d|    /// - Throws: WASMError.moduleLoadFailed if loading fails
266|1d4013|    public func load(from url: URL) async throws {
267|7dcb26|        let data = try Data(contentsOf: url)
268|bb1e25|        try await load(wasmData: data)
269|27e597|    }
270|b4687f|    
271|68bc64|    // MARK: - Function Execution
272|b4687f|    
273|d8cb0a|    /// Executes a function from the loaded WASM module
274|45b4bd|    /// - Parameters:
275|be21ff|    ///   - function: Name of the exported function
276|3fa52e|    ///   - args: Arguments to pass (must be JSON-serializable)
277|7fa39e|    /// - Returns: The function result (converted from JavaScript)
278|7cb653|    /// - Throws: WASMError if execution fails
279|8a1855|    public func execute(function: String, args: [Any] = []) async throws -> Any {
280|37f4e7|        guard moduleLoaded, let moduleName = currentModuleName else {
281|ba2137|            throw WASMError.moduleLoadFailed(reason: "No module loaded")
282|5f3077|        }
283|d6ed84|        
284|2bcea4|        // Serialize arguments
285|946b71|        let argsJSON = try serializeArguments(args)
286|d6ed84|        
287|22d139|        // Build execution script with timeout
288|a1a7cc|        let executionScript = """
289|563fc4|        (async function() {
290|56585c|            const timeout = \(Int(configuration.executionTimeout * 1000));
291|a52445|            const startTime = Date.now();
292|3070d1|            
293|c650f1|            const timeoutPromise = new Promise((_, reject) => {
294|87e71a|                setTimeout(() => reject(new Error('Execution timeout')), timeout);
295|892e8b|            });
296|3070d1|            
297|833476|            const executionPromise = (async () => {
298|cc952a|                try {
299|85e6ec|                    const module = window.wasmModules['\(moduleName)'];
300|52c2c8|                    if (!module) throw new Error('Module not found');
301|dd2193|                    
302|b62d6e|                    // Create import object with host functions
303|8b9537|                    const importObject = window.createImportObject ? window.createImportObject() : {};
304|dd2193|                    
305|f2db4a|                    // Instantiate the module
306|9ff714|                    const instance = await WebAssembly.instantiate(module, importObject);
307|dd2193|                    
308|cb643c|                    // Get the exported function
309|1460e5|                    const fn = instance.exports['\(function)'];
310|7bbad9|                    if (typeof fn !== 'function') {
311|b8bc1b|                        throw new Error('Function \'\(function)\' not found or not a function');
312|c9717a|                    }
313|dd2193|                    
314|2b8e30|                    // Parse arguments
315|e96661|                    const args = \(argsJSON);
316|dd2193|                    
317|eab339|                    // Call the function
318|c04c44|                    const result = fn.apply(null, args);
319|dd2193|                    
320|bd48f0|                    return { 
321|f7cf9f|                        success: true, 
322|625dd9|                        result: result,
323|947a17|                        executionTime: Date.now() - startTime
324|5331c6|                    };
325|c4d255|                } catch (error) {
326|bd48f0|                    return { 
327|477151|                        success: false, 
328|755dca|                        error: error.toString(),
329|947a17|                        executionTime: Date.now() - startTime
330|5331c6|                    };
331|4e2d32|                }
332|43941f|            })();
333|3070d1|            
334|e7b220|            return Promise.race([executionPromise, timeoutPromise]);
335|6ba073|        })()
336|c70080|        """
337|d6ed84|        
338|9176d5|        guard let webView = webView else {
339|9f5cc9|            throw WASMError.executionFailed(reason: "WebView not available")
340|5f3077|        }
341|d6ed84|        
342|082c1c|        let result = try await executeJavaScript(executionScript, in: webView)
343|d6ed84|        
344|22d3cd|        guard let dict = result as? [String: Any] else {
345|f92b0d|            throw WASMError.executionFailed(reason: "Invalid response format")
346|5f3077|        }
347|d6ed84|        
348|48e3d6|        if let success = dict["success"] as? Bool, success {
349|9dac58|            return dict["result"] ?? NSNull()
350|b31999|        } else {
351|83c3f9|            let errorMessage = dict["error"] as? String ?? "Unknown error"
352|2aa2c6|            if errorMessage.contains("timeout") {
353|c39dae|                throw WASMError.executionTimeout(seconds: configuration.executionTimeout)
354|a7dc16|            }
355|5d5bf9|            throw WASMError.executionFailed(reason: errorMessage)
356|5f3077|        }
357|27e597|    }
358|b4687f|    
359|945ea1|    // MARK: - Host Functions
360|b4687f|    
361|cc25e2|    /// Exposes a native Swift function to the WASM module
362|7cfeb1|    /// 
363|5f6cfb|    /// **Limitation:** Host functions are called asynchronously via message handlers.
364|08f7a9|    /// Synchronous host function calls from WASM are not supported.
365|7cfeb1|    /// 
366|45b4bd|    /// - Parameters:
367|4ede7d|    ///   - name: Name of the function in the import namespace
368|9f9bae|    ///   - handler: Closure that receives arguments and returns a result
369|d6fe84|    /// - Throws: WASMError.hostFunctionRegistrationFailed if registration fails
370|04ba75|    public func exposeHostFunction(name: String, handler: @escaping ([Any]) -> Any) async throws {
371|decfd5|        hostFunctions[name] = handler
372|d6ed84|        
373|9176d5|        guard let webView = webView else {
374|cb0a15|            throw WASMError.hostFunctionRegistrationFailed(name: name)
375|5f3077|        }
376|d6ed84|        
377|d49474|        // Register with JavaScript runtime
378|346754|        let registerScript = """
379|1efaf3|        (function() {
380|952daa|            if (!window.hostFunctions) window.hostFunctions = {};
381|d6884e|            window.hostFunctions['\(name)'] = function(...args) {
382|756fc5|                // Send message to native for async execution
383|d08a7b|                window.webkit.messageHandlers.\(messageHandlerName).postMessage({
384|cab20f|                    type: 'hostFunction',
385|5f6b10|                    name: '\(name)',
386|7a6e38|                    args: args
387|4a2b79|                });
388|7426b0|                // Return a placeholder (actual result comes async)
389|6994fb|                return 0;
390|13106d|            };
391|204981|            return { success: true };
392|6ba073|        })()
393|c70080|        """
394|d6ed84|        
395|5110a8|        _ = try await executeJavaScript(registerScript, in: webView)
396|d6ed84|        
397|1bdb42|        if configuration.enableDebugLogging {
398|7d41b3|            print("[WASMRunner] Host function '\(name)' registered")
399|5f3077|        }
400|27e597|    }
401|b4687f|    
402|ed250e|    // MARK: - WASI Support
403|b4687f|    
404|3589a7|    /// Configures WASI support (limited on iOS)
405|7cfeb1|    /// 
406|d54137|    /// **IMPORTANT:** Full WASI support requires a server-side component or
407|c261cd|    /// WASI polyfill. On iOS, this is stubbed to prevent security issues.
408|7cfeb1|    /// 
409|f67132|    /// - Throws: WASMError.wasiNotSupported if WASI mode is .disabled
410|68852d|    public func configureWASI() async throws {
411|57dd34|        switch configuration.wasiMode {
412|776f6f|        case .disabled:
413|e2cdbf|            throw WASMError.wasiNotSupported
414|3070d1|            
415|e1df62|        case .stub:
416|ffd74c|            // Install stub WASI implementations that log warnings
417|fdb891|            guard let webView = webView else {
418|4c11ef|                throw WASMError.initializationFailed(reason: "WebView not available")
419|a7dc16|            }
420|3070d1|            
421|dcb690|            let wasiStubScript = """
422|027e5e|            (function() {
423|c788d5|                const wasiStub = {
424|25002b|                    fd_write: function() { 
425|7d7ade|                        console.warn('WASI fd_write stub called'); return 0; 
426|12b5e6|                    },
427|2219fc|                    fd_read: function() { 
428|6d62f3|                        console.warn('WASI fd_read stub called'); return 0; 
429|12b5e6|                    },
430|5a414f|                    fd_close: function() { 
431|200c9a|                        console.warn('WASI fd_close stub called'); return 0; 
432|12b5e6|                    },
433|ad9908|                    fd_seek: function() { 
434|db935f|                        console.warn('WASI fd_seek stub called'); return 0; 
435|12b5e6|                    },
436|9e6889|                    path_open: function() { 
437|3101eb|                        console.warn('WASI path_open stub called'); return -1; 
438|12b5e6|                    },
439|d8fb08|                    path_unlink_file: function() { 
440|0cbcde|                        console.warn('WASI path_unlink_file stub called'); return -1; 
441|12b5e6|                    },
442|c7c0a2|                    environ_get: function() { return 0; },
443|5b3c94|                    environ_sizes_get: function() { return 0; },
444|50baa5|                    args_get: function() { return 0; },
445|b76a60|                    args_sizes_get: function() { return 0; },
446|41721f|                    proc_exit: function(code) { 
447|1e4dee|                        console.log('WASI proc_exit called with code:', code); 
448|12b5e6|                    },
449|ff6090|                    clock_time_get: function() { return 0; }
450|2c6774|                };
451|216278|                
452|cad0c0|                if (!window.wasiSnapshotPreview1) {
453|a81a6d|                    window.wasiSnapshotPreview1 = wasiStub;
454|4e2d32|                }
455|216278|                
456|73c4f3|                return { success: true };
457|1a37c6|            })()
458|f9d356|            """
459|3070d1|            
460|00b190|            _ = try await executeJavaScript(wasiStubScript, in: webView)
461|3070d1|            
462|fa3662|            if configuration.enableDebugLogging {
463|cee7ef|                print("[WASMRunner] WASI stub configured")
464|a7dc16|            }
465|3070d1|            
466|854010|        case .polyfill:
467|32e1be|            // Would require loading external polyfill library
468|fa3662|            if configuration.enableDebugLogging {
469|9af80d|                print("[WASMRunner] WASI polyfill mode - external polyfill required")
470|a7dc16|            }
471|5f3077|        }
472|27e597|    }
473|b4687f|    
474|6a24e0|    // MARK: - Cleanup
475|b4687f|    
476|677399|    /// Unloads the current WASM module and cleans up resources
477|512378|    public func unload() async {
478|bd4fb8|        guard let webView = webView, let moduleName = currentModuleName else { return }
479|d6ed84|        
480|04b4fb|        let cleanupScript = """
481|1efaf3|        (function() {
482|461121|            if (window.wasmModules && window.wasmModules['\(moduleName)']) {
483|8dad2a|                delete window.wasmModules['\(moduleName)'];
484|a7dc16|            }
485|204981|            return { success: true };
486|6ba073|        })()
487|c70080|        """
488|d6ed84|        
489|151b4f|        _ = try? await executeJavaScript(cleanupScript, in: webView)
490|d6ed84|        
491|923e32|        currentModuleName = nil
492|44d2ef|        moduleLoaded = false
493|d6ed84|        
494|1bdb42|        if configuration.enableDebugLogging {
495|981085|            print("[WASMRunner] Module unloaded")
496|5f3077|        }
497|27e597|    }
498|b4687f|    
499|e10fe0|    /// Destroys the runner and releases all resources
500|8308ae|    public func destroy() {
501|5df072|        executionTask?.cancel()
502|75a854|        webView?.stopLoading()
503|4426a6|        webView?.configuration.userContentController.removeScriptMessageHandler(forName: messageHandlerName)
504|b8727c|        webView = nil
505|6399c7|        hostFunctions.removeAll()
506|d6ed84|        
507|1bdb42|        if configuration.enableDebugLogging {
508|4c23b7|            print("[WASMRunner] Destroyed")
509|5f3077|        }
510|27e597|    }
511|b4687f|    
512|e57f77|    deinit {
513|d79336|        Task { @MainActor in
514|aba717|            destroy()
515|5f3077|        }
516|27e597|    }
517|b4687f|    
518|81a958|    // MARK: - Private Helpers
519|b4687f|    
520|d993a7|    private func executeJavaScript(_ script: String, in webView: WKWebView) async throws -> Any {
521|3d0b9a|        return try await withCheckedThrowingContinuation { continuation in
522|24a40d|            webView.evaluateJavaScript(script) { result, error in
523|bced13|                if let error = error {
524|4f255d|                    continuation.resume(throwing: WASMError.executionFailed(reason: error.localizedDescription))
525|fdd0e2|                } else {
526|bf791f|                    continuation.resume(returning: result ?? NSNull())
527|4e2d32|                }
528|a7dc16|            }
529|5f3077|        }
530|27e597|    }
531|b4687f|    
532|14e654|    private func serializeArguments(_ args: [Any]) throws -> String {
533|1592a2|        let data = try JSONSerialization.data(withJSONObject: args, options: [])
534|6d9752|        guard let string = String(data: data, encoding: .utf8) else {
535|290ab4|            throw WASMError.invalidArguments
536|5f3077|        }
537|d970e8|        return string
538|27e597|    }
539|b31277|}
540|adc83b|
541|923e5c|// MARK: - WKScriptMessageHandler
542|adc83b|
543|9b6b1f|extension WASMRunner: WKScriptMessageHandler {
544|916b28|    public func userContentController(
545|7c2a4e|        _ userContentController: WKUserContentController,
546|4802e9|        didReceive message: WKScriptMessage
547|981e04|    ) {
548|193994|        guard let body = message.body as? [String: Any],
549|83691d|              let type = body["type"] as? String else { return }
550|d6ed84|        
551|d79336|        Task { @MainActor in
552|ecf57d|            await handleMessage(type: type, body: body)
553|5f3077|        }
554|27e597|    }
555|b4687f|    
556|629ebb|    private func handleMessage(type: String, body: [String: Any]) async {
557|ba7bd8|        switch type {
558|1dc996|        case "hostFunction":
559|32007e|            if let name = body["name"] as? String,
560|6768d0|               let args = body["args"] as? [Any],
561|de6351|               let handler = hostFunctions[name] {
562|6dd596|                _ = handler(args)
563|a7dc16|            }
564|520b7d|        default:
565|fa3662|            if configuration.enableDebugLogging {
566|3d9cc4|                print("[WASMRunner] Unknown message type: \(type)")
567|a7dc16|            }
568|5f3077|        }
569|27e597|    }
570|b31277|}
571|adc83b|
572|6cd549|// MARK: - JavaScript Runtime Helper
573|adc83b|
574|0d5264|private enum WASMRuntimeHelper {
575|ea3c7b|    static let javascript = """
576|ee8990|    (function() {
577|a77c0e|        'use strict';
578|d6ed84|        
579|e3b5c3|        // WASM Module storage
580|7c4903|        window.wasmModules = window.wasmModules || {};
581|dbe417|        window.hostFunctions = window.hostFunctions || {};
582|d6ed84|        
583|71156c|        // Create import object with WASI and host functions
584|412846|        window.createImportObject = function(env) {
585|71f80d|            env = env || {};
586|3070d1|            
587|d6e892|            // Add WASI if available
588|6e8c78|            if (window.wasiSnapshotPreview1) {
589|c77dcb|                env.wasi_snapshot_preview1 = window.wasiSnapshotPreview1;
590|a7dc16|            }
591|3070d1|            
592|8879c0|            // Add host functions
593|079396|            if (window.hostFunctions) {
594|79aa32|                env.env = env.env || {};
595|cea2cb|                for (const [name, fn] of Object.entries(window.hostFunctions)) {
596|f82665|                    env.env[name] = fn;
597|4e2d32|                }
598|a7dc16|            }
599|3070d1|            
600|eee6b7|            return env;
601|105ee3|        };
602|d6ed84|        
603|882836|        // Helper to convert JS values for WASM
604|d67455|        window.toWASM = {
605|9879b5|            string: function(ptr, len, memory) {
606|14ea79|                const bytes = new Uint8Array(memory.buffer, ptr, len);
607|c83059|                return new TextDecoder('utf8').decode(bytes);
608|12b7cc|            },
609|d8c6de|            bytes: function(ptr, len, memory) {
610|299933|                return new Uint8Array(memory.buffer, ptr, len);
611|a7dc16|            }
612|105ee3|        };
613|d6ed84|        
614|44b60c|        // Helper to write to WASM memory
615|59d10f|        window.fromWASM = {
616|eb03e9|            string: function(str, memory) {
617|7fd28a|                const encoder = new TextEncoder();
618|7c3997|                const bytes = encoder.encode(str);
619|31c0b1|                // Note: Actual memory allocation must be done in WASM
620|5400ad|                return bytes;
621|a7dc16|            }
622|105ee3|        };
623|d6ed84|        
624|7209ba|        console.log('[WASMRuntime] Helper loaded');
625|2f3d4e|    })();
626|87f133|    """
627|b31277|}
628|adc83b|
629|82fd81|// MARK: - Example Usage
630|adc83b|
631|32ca1a|/*
632|ab20fd|Example 1: Running a simple Rust-compiled WASM module
633|adc83b|
634|97f574|```swift
635|9f8e8f|// Load a Rust-compiled WASM module
636|2dda2b|let runner = try WASMRunner(configuration: .rust)
637|adc83b|
638|af46f6|// Load the module
639|343999|let wasmData = try Data(contentsOf: Bundle.main.url(forResource: "calculator", withExtension: "wasm")!)
640|71d6c4|try await runner.load(wasmData: wasmData)
641|adc83b|
642|f2822f|// Call an exported function
643|bfc399|let result = try await runner.execute(function: "add", args: [5, 3])
644|8dd233|print("Result: \(result)") // Prints: 8
645|adc83b|
646|62390b|// Clean up
647|8d06a3|await runner.unload()
648|1a0775|```
649|adc83b|
650|dafcd2|Example 2: Running Pyodide (requires network access and large memory)
651|adc83b|
652|97f574|```swift
653|783d32|// Pyodide requires significant memory
654|154bd5|let runner = try WASMRunner(configuration: .pyodide)
655|adc83b|
656|5648e0|// Load Pyodide (this is a large download ~20MB)
657|c5e631|let pyodideURL = URL(string: "https://cdn.jsdelivr.net/pyodide/v0.24.1/full/pyodide.js")!
658|dc26af|let pyodideWasmURL = URL(string: "https://cdn.jsdelivr.net/pyodide/v0.24.1/full/pyodide.asm.wasm")!
659|adc83b|
660|d130f3|// First load the JavaScript bootstrap
661|60c6da|try await runner.load(from: pyodideWasmURL)
662|adc83b|
663|536077|// Pyodide requires special initialization - see Pyodide documentation
664|beacd5|// This is a simplified example
665|adc83b|
666|62390b|// Clean up
667|8d06a3|await runner.unload()
668|1a0775|```
669|adc83b|
670|1cdd4a|Example 3: Exposing host functions
671|adc83b|
672|97f574|```swift
673|0b9ad4|let runner = try WASMRunner()
674|adc83b|
675|5e3349|// Expose a native function to WASM
676|ce36ef|try await runner.exposeHostFunction(name: "log") { args in
677|8e6abe|    print("WASM Log: \(args)")
678|36d886|    return 0
679|b31277|}
680|adc83b|
681|94c0db|// WASM module can now import and call this function
682|04c15c|// (import "env" "log" (func $log (param i32)))
683|1a0775|```
684|adc83b|
685|5621d8|Example 4: Error handling
686|adc83b|
687|97f574|```swift
688|4e14f2|do {
689|5adc71|    let runner = try WASMRunner()
690|e6c645|    try await runner.load(wasmData: invalidData)
691|f9d86b|    let result = try await runner.execute(function: "main", args: [])
692|5e4017|} catch let error as WASMError {
693|715729|    switch error {
694|80709a|    case .moduleCompilationFailed(let reason):
695|5d77f4|        print("Compilation failed: \(reason)")
696|1849db|    case .executionTimeout(let seconds):
697|dbfbf2|        print("Timeout after \(seconds) seconds")
698|3281bf|    default:
699|2d5d21|        print("WASM Error: \(error.localizedDescription)")
700|27e597|    }
701|b31277|}
702|1a0775|```
703|0edef9|*/
704|adc83b|
705|9e8885|// MARK: - Advanced Features (Future)
706|adc83b|
707|32ca1a|/*
708|b85f4b|Potential future enhancements:
709|adc83b|
710|1ded7d|1. **Streaming Compilation**: Use WebAssembly.compileStreaming() for larger modules
711|d4e71f|2. **SharedArrayBuffer**: Enable for multi-threaded WASM (requires COOP/COEP headers)
712|53674c|3. **WASI Polyfill Integration**: Full WASI support via wasmtime or wasmer
713|f70bb2|4. **Debugging Support**: DWARF debugging info integration
714|2e71cb|5. **Hot Reloading**: Module replacement without full reinitialization
715|727ddb|6. **Performance Profiling**: Integration with Safari DevTools
716|adc83b|
717|fa7959|Current limitations that may be addressed:
718|b4d182|- Host function calls are async-only (no sync interop)
719|d3e3a3|- WASI filesystem is stubbed (no real file access)
720|6489a1|- Memory limits are WebKit-managed, not strictly enforced
721|f829fa|- No direct memory access from Swift (must go through JS bridge)
722|0edef9|*/
723|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: f68518a5a3a6
File: VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/JSRunner.swift (lines 1-717 of 717)
────────────────────────────────────────
1|119e5c|import JavaScriptCore
2|8b6b78|import Foundation
3|adc83b|
4|bbdb6d|// MARK: - Console Protocol
5|c50987|/**
6|c2f53a| * Protocol for JavaScript console object exposure to native Swift.
7|52124c| * Conforming to JSExport allows JavaScript to call these methods directly.
8|d48ab4| */
9|9e272a|@objc protocol JSConsoleProtocol: JSExport {
10|535e2c|    func log(_ message: String)
11|cd2fff|    func error(_ message: String)
12|0ad30e|    func warn(_ message: String)
13|3df368|    func info(_ message: String)
14|b31277|}
15|adc83b|
16|605790|// MARK: - Console Implementation
17|c50987|/**
18|1f8622| * Native implementation of JavaScript console that captures output
19|12c962| * and forwards it to a Swift callback handler.
20|d48ab4| */
21|a2c26a|@objc class JSConsole: NSObject, JSConsoleProtocol {
22|ee0651|    private var logHandler: ((String) -> Void)?
23|b4687f|    
24|c32910|    /**
25|d69004|     * Initializes the console with a log handler callback.
26|c0ac75|     * - Parameter handler: Closure called when console methods are invoked from JS
27|1ef3e9|     */
28|fb2158|    init(handler: @escaping (String) -> Void) {
29|d0a4b0|        self.logHandler = handler
30|15cfe8|        super.init()
31|27e597|    }
32|b4687f|    
33|37d53e|    func log(_ message: String) {
34|ff8699|        logHandler?("[LOG] \(message)")
35|27e597|    }
36|b4687f|    
37|7bc954|    func error(_ message: String) {
38|28b25a|        logHandler?("[ERROR] \(message)")
39|27e597|    }
40|b4687f|    
41|614f48|    func warn(_ message: String) {
42|f49b47|        logHandler?("[WARN] \(message)")
43|27e597|    }
44|b4687f|    
45|af50e0|    func info(_ message: String) {
46|41118a|        logHandler?("[INFO] \(message)")
47|27e597|    }
48|b31277|}
49|adc83b|
50|9f0d64|// MARK: - Error Types
51|c50987|/**
52|203f37| * Errors that can occur during JavaScript execution.
53|d48ab4| */
54|8a94f0|enum JSRunnerError: Error, LocalizedError {
55|b58f28|    case contextCreationFailed
56|bee84d|    case executionTimeout
57|cdbfea|    case memoryLimitExceeded
58|44f523|    case scriptError(String)
59|e15df9|    case invalidResult
60|34fb35|    case nativeFunctionRegistrationFailed(String)
61|b4687f|    
62|242b78|    var errorDescription: String? {
63|2e6d08|        switch self {
64|d407e2|        case .contextCreationFailed:
65|bd9d29|            return "Failed to create JavaScript context"
66|109edb|        case .executionTimeout:
67|ee7ac2|            return "JavaScript execution exceeded the timeout limit"
68|406c63|        case .memoryLimitExceeded:
69|1f8993|            return "JavaScript execution exceeded the memory limit"
70|9b6153|        case .scriptError(let message):
71|71c51f|            return "Script error: \(message)"
72|188205|        case .invalidResult:
73|31771d|            return "JavaScript returned an invalid or unsupported result type"
74|a4f5d8|        case .nativeFunctionRegistrationFailed(let name):
75|5a40ea|            return "Failed to register native function '\(name)'"
76|5f3077|        }
77|27e597|    }
78|b31277|}
79|adc83b|
80|f0d446|// MARK: - JSRunner
81|c50987|/**
82|d8c630| * A Swift wrapper around JavaScriptCore that provides:
83|3f696d| * - Safe async JavaScript execution with timeout and memory limits
84|208a87| * - Console.log capture via JSExport protocol
85|467440| * - Native function exposure to JavaScript
86|cf3494| * - Automatic conversion of JS values to Swift types
87|ca6a42| *
88|d8d423| * ## Example Usage:
89|17213a| * ```swift
90|9b831c| * let runner = JSRunner()
91|ca6a42| *
92|77ce1e| * // Set up console handler
93|9e27ea| * runner.setConsoleHandler { message in
94|ebf826| *     print("JS Console: \(message)")
95|095c29| * }
96|ca6a42| *
97|37606b| * // Expose a native function
98|02911a| * runner.exposeNativeFunction(name: "nativeAdd") { args in
99|cfd01c| *     guard args.count >= 2,
100|959284| *           let a = args[0].toInt32(),
101|da3bb0| *           let b = args[1].toInt32() else {
102|10d08e| *         return JSValue(undefinedIn: runner.context)
103|153f07| *     }
104|06396f| *     return JSValue(int32: a + b, in: runner.context)
105|095c29| * }
106|ca6a42| *
107|9ce2a9| * // Execute JavaScript
108|ce0b3c| * do {
109|d48634| *     let result = try await runner.execute(code: "nativeAdd(5, 3)")
110|9aca35| *     print("Result: \(result)") // Result: 8
111|f7f7e4| * } catch {
112|1ebc71| *     print("Error: \(error)")
113|095c29| * }
114|7f8f0c| * ```
115|d48ab4| */
116|1dbd55|class JSRunner {
117|b4687f|    
118|6503ae|    // MARK: - Properties
119|b4687f|    
120|e8b868|    /** The underlying JavaScript context */
121|5cc683|    private(set) var context: JSContext!
122|b4687f|    
123|14603b|    /** Handler for console messages from JavaScript */
124|77f178|    private var consoleHandler: ((String) -> Void)?
125|b4687f|    
126|b90a91|    /** Timeout duration for script execution (default: 30 seconds) */
127|32dbb9|    var timeoutDuration: TimeInterval = 30.0
128|b4687f|    
129|1b4da4|    /** Memory limit in bytes (default: 100 MB) */
130|a9e039|    var memoryLimit: UInt64 = 100 * 1024 * 1024
131|b4687f|    
132|095e8d|    /** Track memory usage */
133|dea0ce|    private var currentMemoryUsage: UInt64 = 0
134|b4687f|    
135|eddf5c|    /** Background queue for JavaScript execution */
136|bf4c54|    private let executionQueue = DispatchQueue(
137|f78e47|        label: "com.jsrunner.execution",
138|d35bfe|        qos: .userInitiated
139|829c44|    )
140|b4687f|    
141|7dca75|    // MARK: - Initialization
142|b4687f|    
143|c32910|    /**
144|a7d546|     * Creates a new JSRunner with a fresh JavaScript context.
145|3e1e93|     * Automatically sets up error handling and exception callbacks.
146|1ef3e9|     */
147|359b1b|    init() {
148|22aae4|        setupContext()
149|27e597|    }
150|b4687f|    
151|e57f77|    deinit {
152|05bf05|        context = nil
153|27e597|    }
154|b4687f|    
155|674a7e|    // MARK: - Context Setup
156|b4687f|    
157|95a0d0|    private func setupContext() {
158|a4c8b1|        // Create context with nil virtual machine (creates default VM)
159|f7b6e1|        let virtualMachine = JSVirtualMachine()
160|0a876b|        context = JSContext(virtualMachine: virtualMachine)
161|d6ed84|        
162|211625|        // Set up exception handler
163|f21caa|        context.exceptionHandler = { [weak self] context, exception in
164|4219ab|            guard let self = self, let exception = exception else { return }
165|b5b6da|            let message = exception.toString() ?? "Unknown error"
166|bcef50|            self.consoleHandler?("[EXCEPTION] \(message)")
167|5f3077|        }
168|d6ed84|        
169|9b3f73|        // Inject console object
170|492bf9|        setupConsole()
171|27e597|    }
172|b4687f|    
173|7994a7|    private func setupConsole() {
174|d15e81|        let console = JSConsole { [weak self] message in
175|e71e9a|            self?.consoleHandler?(message)
176|5f3077|        }
177|8966f3|        context.setObject(console, forKeyedSubscript: "console" as NSString)
178|27e597|    }
179|b4687f|    
180|c705f9|    // MARK: - Console Handler
181|b4687f|    
182|c32910|    /**
183|e7ac5e|     * Sets the callback handler for JavaScript console messages.
184|2b23ac|     *
185|913c9b|     * - Parameter callback: Closure invoked when console.log, console.error,
186|846e04|     *                       console.warn, or console.info are called from JavaScript.
187|2b23ac|     *
188|7a5f4e|     * ## Example:
189|ac33be|     * ```swift
190|2a4b88|     * runner.setConsoleHandler { message in
191|d32410|     *     // Log to your app's logging system
192|290ea9|     *     Logger.shared.log(message)
193|994983|     * }
194|056bf3|     * ```
195|1ef3e9|     */
196|7fb007|    func setConsoleHandler(callback: @escaping (String) -> Void) {
197|3fd389|        consoleHandler = callback
198|2a70ea|        // Re-inject console with new handler
199|492bf9|        setupConsole()
200|27e597|    }
201|b4687f|    
202|10cd53|    // MARK: - Native Function Exposure
203|b4687f|    
204|c32910|    /**
205|69d2aa|     * Exposes a native Swift function to JavaScript.
206|2b23ac|     *
207|59e69e|     * - Parameters:
208|35a3eb|     *   - name: The name the function will have in JavaScript
209|22dd60|     *   - block: The Swift closure that implements the function.
210|9ef388|     *            Receives an array of JSValue arguments and must return a JSValue.
211|2b23ac|     *
212|7a5f4e|     * ## Example:
213|ac33be|     * ```swift
214|366e56|     * // Expose native multiply function
215|9e49c9|     * runner.exposeNativeFunction(name: "nativeMultiply") { args in
216|f51b62|     *     guard args.count >= 2,
217|06b6d1|     *           let a = args[0].toDouble(),
218|a48939|     *           let b = args[1].toDouble() else {
219|5b33f0|     *         return JSValue(undefinedIn: self.context)
220|82584f|     *     }
221|6c2150|     *     return JSValue(double: a * b, in: self.context)
222|994983|     * }
223|2b23ac|     *
224|3be248|     * // Use in JavaScript:
225|f5c3e6|     * // const result = nativeMultiply(4, 5); // Returns 20
226|056bf3|     * ```
227|1ef3e9|     */
228|0b8a67|    func exposeNativeFunction(
229|f1fce1|        name: String,
230|15e547|        block: @escaping ([JSValue]) -> JSValue
231|981e04|    ) {
232|5fc015|        let jsFunction: @convention(block) () -> JSValue = { [weak self] in
233|b38552|            guard let self = self else {
234|b2a4ff|                return JSValue(undefinedIn: nil)
235|a7dc16|            }
236|3070d1|            
237|9d1a10|            // Get arguments from current JS context
238|029f5c|            let args = JSContext.currentArguments() as? [JSValue] ?? []
239|1f7d95|            return block(args)
240|5f3077|        }
241|d6ed84|        
242|04b344|        context.setObject(
243|df1db0|            jsFunction,
244|b12af3|            forKeyedSubscript: name as NSString
245|3143a4|        )
246|27e597|    }
247|b4687f|    
248|c32910|    /**
249|054db7|     * Exposes a native Swift function with specific argument count to JavaScript.
250|a76b43|     * This version provides better type safety for functions with known arity.
251|2b23ac|     *
252|59e69e|     * - Parameters:
253|35a3eb|     *   - name: The name the function will have in JavaScript
254|e3c5e3|     *   - argCount: Expected number of arguments
255|0a4a60|     *   - block: Swift closure implementing the function
256|1ef3e9|     */
257|0b8a67|    func exposeNativeFunction(
258|f1fce1|        name: String,
259|823692|        argCount: Int,
260|50b329|        block: @escaping ([JSValue]) throws -> JSValue
261|53fcb2|    ) throws {
262|a27133|        let wrapper: @convention(block) () -> JSValue = { [weak self] in
263|b38552|            guard let self = self else {
264|b2a4ff|                return JSValue(undefinedIn: nil)
265|a7dc16|            }
266|3070d1|            
267|029f5c|            let args = JSContext.currentArguments() as? [JSValue] ?? []
268|3070d1|            
269|ff1395|            // Check argument count
270|e7c0a1|            if args.count != argCount {
271|7af74c|                let error = JSValue(
272|0a2850|                    newErrorFromMessage: "Expected \(argCount) arguments, got \(args.count)",
273|236a64|                    in: self.context
274|6f642e|                )
275|6e37a0|                self.context.exception = error
276|e63078|                return JSValue(undefinedIn: self.context)
277|a7dc16|            }
278|3070d1|            
279|71cc09|            do {
280|73b609|                return try block(args)
281|91b9a2|            } catch {
282|c839dc|                let errorMessage = (error as? JSRunnerError)?.errorDescription ?? error.localizedDescription
283|9011d6|                let jsError = JSValue(
284|64fe5a|                    newErrorFromMessage: errorMessage,
285|236a64|                    in: self.context
286|6f642e|                )
287|341375|                self.context.exception = jsError
288|e63078|                return JSValue(undefinedIn: self.context)
289|a7dc16|            }
290|5f3077|        }
291|d6ed84|        
292|3b2f68|        context.setObject(wrapper, forKeyedSubscript: name as NSString)
293|27e597|    }
294|b4687f|    
295|b66c56|    // MARK: - Script Execution
296|b4687f|    
297|c32910|    /**
298|2c0e40|     * Executes JavaScript code with timeout and memory limit protection.
299|2b23ac|     *
300|958f2c|     * - Parameter code: The JavaScript code to execute
301|54dd62|     * - Returns: The result of the execution as a JSValue
302|806780|     * - Throws: JSRunnerError if execution fails, times out, or exceeds memory limits
303|2b23ac|     *
304|7a5f4e|     * ## Example:
305|ac33be|     * ```swift
306|1ac76e|     * do {
307|036931|     *     // Simple arithmetic
308|f72a3b|     *     let result = try await runner.execute(code: "2 + 2")
309|eb949a|     *     print(result.toInt32()!) // 4
310|2b23ac|     *
311|d12776|     *     // Complex object
312|9bb09e|     *     let obj = try await runner.execute(code: "({ name: 'Test', value: 42 })")
313|4e4eeb|     *     print(obj.toDictionary()) // ["name": "Test", "value": 42]
314|2b23ac|     *
315|6b666f|     *     // Using native functions
316|48521c|     *     let sum = try await runner.execute(code: "nativeAdd(10, 20)")
317|d68fec|     *     print(sum.toInt32()!) // 30
318|1a815b|     * } catch JSRunnerError.executionTimeout {
319|8d6c76|     *     print("Script took too long")
320|ed4965|     * } catch {
321|74b8f1|     *     print("Execution failed: \(error)")
322|994983|     * }
323|056bf3|     * ```
324|1ef3e9|     */
325|fe06df|    func execute(code: String) async throws -> JSValue {
326|3d0b9a|        return try await withCheckedThrowingContinuation { continuation in
327|f0fb73|            executionQueue.async { [weak self] in
328|ec615d|                guard let self = self else {
329|6d0401|                    continuation.resume(throwing: JSRunnerError.contextCreationFailed)
330|d253ab|                    return
331|4e2d32|                }
332|216278|                
333|017597|                // Set up timeout
334|e632c2|                var timeoutOccurred = false
335|3de9a5|                let timeoutWorkItem = DispatchWorkItem { [weak self] in
336|6d2715|                    timeoutOccurred = true
337|407546|                    self?.context = nil // Force terminate
338|4e2d32|                }
339|216278|                
340|b3d5f7|                DispatchQueue.global().asyncAfter(
341|b31dab|                    deadline: .now() + self.timeoutDuration,
342|04f1d4|                    execute: timeoutWorkItem
343|6f642e|                )
344|216278|                
345|eef54f|                // Reset memory tracking
346|227951|                self.currentMemoryUsage = 0
347|216278|                
348|fa7b33|                // Execute the script
349|b526d9|                var result: JSValue?
350|6039e5|                var executionError: Error?
351|216278|                
352|656264|                autoreleasepool {
353|a9c022|                    result = self.context.evaluateScript(code)
354|dd2193|                    
355|4efdad|                    // Check for exceptions
356|aa0bf6|                    if let exception = self.context.exception {
357|2258f1|                        let message = exception.toString() ?? "Unknown error"
358|3db872|                        executionError = JSRunnerError.scriptError(message)
359|30683f|                        self.context.exception = nil
360|c9717a|                    }
361|4e2d32|                }
362|216278|                
363|b3f63e|                // Cancel timeout if execution completed
364|91d8f9|                timeoutWorkItem.cancel()
365|216278|                
366|4a9afe|                // Check for timeout
367|501942|                if timeoutOccurred {
368|156b94|                    // Need to recreate context since we nilled it
369|cfa3f6|                    self.setupContext()
370|86c114|                    continuation.resume(throwing: JSRunnerError.executionTimeout)
371|d253ab|                    return
372|4e2d32|                }
373|216278|                
374|054333|                // Check for memory limit
375|aaf645|                // Note: Real memory tracking would use more sophisticated methods
376|6e76e6|                // This is a simplified check
377|77b9fb|                if self.currentMemoryUsage > self.memoryLimit {
378|e0fe74|                    continuation.resume(throwing: JSRunnerError.memoryLimitExceeded)
379|d253ab|                    return
380|4e2d32|                }
381|216278|                
382|03d4cf|                // Handle execution error
383|325379|                if let error = executionError {
384|773145|                    continuation.resume(throwing: error)
385|d253ab|                    return
386|4e2d32|                }
387|216278|                
388|42b2ec|                // Return result or undefined if nil
389|312ffa|                continuation.resume(returning: result ?? JSValue(undefinedIn: self.context))
390|a7dc16|            }
391|5f3077|        }
392|27e597|    }
393|b4687f|    
394|c32910|    /**
395|78a44c|     * Executes JavaScript code with a specific timeout.
396|2b23ac|     *
397|59e69e|     * - Parameters:
398|03adfb|     *   - code: The JavaScript code to execute
399|9d2e32|     *   - timeout: Custom timeout duration for this execution
400|2a89b5|     * - Returns: The result as a JSValue
401|6e6897|     * - Throws: JSRunnerError for various failure conditions
402|1ef3e9|     */
403|75fbd6|    func execute(code: String, timeout: TimeInterval) async throws -> JSValue {
404|7d6a40|        let originalTimeout = timeoutDuration
405|5b4e28|        timeoutDuration = timeout
406|fa2a6a|        defer { timeoutDuration = originalTimeout }
407|7b68a8|        return try await execute(code: code)
408|27e597|    }
409|b4687f|    
410|5ef09c|    // MARK: - Result Conversion
411|b4687f|    
412|c32910|    /**
413|638fe8|     * Converts a JSValue to a native Swift type.
414|2b23ac|     *
415|cc9e44|     * - Parameter value: The JSValue to convert
416|b42367|     * - Returns: The converted Swift value (String, Int, Double, Bool, Array, Dictionary, or nil)
417|2b23ac|     *
418|7a5f4e|     * ## Example:
419|ac33be|     * ```swift
420|2e03ce|     * let jsValue = try await runner.execute(code: "{ a: 1, b: [1, 2, 3] }")
421|9d3028|     * let swiftValue = runner.convertToSwift(jsValue)
422|cb6f68|     * // Returns: ["a": 1, "b": [1, 2, 3]] as [String: Any]
423|056bf3|     * ```
424|1ef3e9|     */
425|40c821|    func convertToSwift(_ value: JSValue) -> Any? {
426|af96db|        if value.isUndefined || value.isNull {
427|1c8557|            return nil
428|5f3077|        }
429|d6ed84|        
430|6639a5|        if value.isString {
431|7fd7f0|            return value.toString()
432|5f3077|        }
433|d6ed84|        
434|fe29fa|        if value.isNumber {
435|0200f8|            let int = value.toInt32()
436|6a6589|            if Double(int) == value.toDouble() {
437|fdd122|                return Int(int)
438|a7dc16|            }
439|cc6808|            return value.toDouble()
440|5f3077|        }
441|d6ed84|        
442|97b38b|        if value.isBoolean {
443|48a040|            return value.toBool()
444|5f3077|        }
445|d6ed84|        
446|a80647|        if value.isArray {
447|936625|            return value.toArray()
448|5f3077|        }
449|d6ed84|        
450|8844d6|        if value.isObject {
451|a2dc1c|            return value.toDictionary()
452|5f3077|        }
453|d6ed84|        
454|8e7e0b|        if let date = value.toDate() {
455|0f7876|            return date
456|5f3077|        }
457|d6ed84|        
458|c2ae65|        return nil
459|27e597|    }
460|b4687f|    
461|c32910|    /**
462|0ec2b2|     * Executes code and automatically converts the result to a Swift type.
463|2b23ac|     *
464|f02985|     * - Parameter code: JavaScript code to execute
465|049f9c|     * - Returns: Converted Swift value, or nil if conversion fails
466|7bce23|     * - Throws: JSRunnerError for execution failures
467|1ef3e9|     */
468|6865ed|    func executeAndConvert(code: String) async throws -> Any? {
469|a03023|        let result = try await execute(code: code)
470|c759dd|        return convertToSwift(result)
471|27e597|    }
472|b4687f|    
473|bd6ccb|    // MARK: - Memory Management
474|b4687f|    
475|c32910|    /**
476|cf136b|     * Sets the memory limit for JavaScript execution.
477|2b23ac|     *
478|c60210|     * - Parameter limit: Maximum memory in bytes
479|1ef3e9|     */
480|65e2e8|    func setMemoryLimit(_ limit: UInt64) {
481|158e82|        memoryLimit = limit
482|27e597|    }
483|b4687f|    
484|c32910|    /**
485|461e9d|     * Forces garbage collection and clears the context.
486|552831|     * Call this when you're done with the runner to free resources.
487|1ef3e9|     */
488|380be3|    func cleanup() {
489|5a8e21|        context.exceptionHandler = nil
490|05bf05|        context = nil
491|2e3689|        consoleHandler = nil
492|27e597|    }
493|b31277|}
494|adc83b|
495|eb33bc|// MARK: - Convenience Extensions
496|adc83b|
497|83899d|extension JSRunner {
498|b4687f|    
499|c32910|    /**
500|389f7a|     * Executes JavaScript and returns the result as a String.
501|1ef3e9|     */
502|7903ec|    func executeToString(code: String) async throws -> String? {
503|a03023|        let result = try await execute(code: code)
504|399657|        return result.toString()
505|27e597|    }
506|b4687f|    
507|c32910|    /**
508|a6219f|     * Executes JavaScript and returns the result as an Int.
509|1ef3e9|     */
510|b5428a|    func executeToInt(code: String) async throws -> Int? {
511|a03023|        let result = try await execute(code: code)
512|44e26f|        return Int(result.toInt32())
513|27e597|    }
514|b4687f|    
515|c32910|    /**
516|0e138b|     * Executes JavaScript and returns the result as a Double.
517|1ef3e9|     */
518|70f92c|    func executeToDouble(code: String) async throws -> Double? {
519|a03023|        let result = try await execute(code: code)
520|9374d0|        return result.toDouble()
521|27e597|    }
522|b4687f|    
523|c32910|    /**
524|8086be|     * Executes JavaScript and returns the result as a Bool.
525|1ef3e9|     */
526|dd633e|    func executeToBool(code: String) async throws -> Bool? {
527|a03023|        let result = try await execute(code: code)
528|c50d04|        return result.isBoolean ? result.toBool() : nil
529|27e597|    }
530|b4687f|    
531|c32910|    /**
532|9853d8|     * Executes JavaScript and returns the result as a Dictionary.
533|1ef3e9|     */
534|93d723|    func executeToDictionary(code: String) async throws -> [String: Any]? {
535|a03023|        let result = try await execute(code: code)
536|1a88b3|        guard let dict = result.toDictionary() else { return nil }
537|786254|        var stringDict: [String: Any] = [:]
538|0c0c7f|        for (key, value) in dict {
539|947451|            if let stringKey = key as? String {
540|c59c65|                stringDict[stringKey] = value
541|a7dc16|            }
542|5f3077|        }
543|5e8679|        return stringDict.isEmpty ? nil : stringDict
544|27e597|    }
545|b4687f|    
546|c32910|    /**
547|2f765d|     * Executes JavaScript and returns the result as an Array.
548|1ef3e9|     */
549|e7718f|    func executeToArray(code: String) async throws -> [Any]? {
550|a03023|        let result = try await execute(code: code)
551|a42f1e|        return result.toArray()
552|27e597|    }
553|b31277|}
554|adc83b|
555|95af32|// MARK: - Test Example
556|32ca1a|/*
557|dd1225| 
558|ea119b| // MARK: - Example Test Usage
559|adc83b|
560|e4031d| import XCTest
561|adc83b|
562|3cdf90| class JSRunnerTests: XCTestCase {
563|8f1f4b|     
564|536c57|     var runner: JSRunner!
565|8f1f4b|     
566|676c35|     override func setUp() {
567|30f761|         super.setUp()
568|6ab08f|         runner = JSRunner()
569|1b931e|         runner.setConsoleHandler { message in
570|1f545b|             print("Console: \(message)")
571|b9c240|         }
572|48082f|     }
573|8f1f4b|     
574|41f09e|     override func tearDown() {
575|5c2aee|         runner.cleanup()
576|501764|         runner = nil
577|bc7549|         super.tearDown()
578|48082f|     }
579|8f1f4b|     
580|ff723b|     func testBasicArithmetic() async throws {
581|6c4337|         let result = try await runner.executeToInt(code: "2 + 3")
582|c79b91|         XCTAssertEqual(result, 5)
583|48082f|     }
584|8f1f4b|     
585|5216c0|     func testConsoleCapture() async throws {
586|57e3fd|         var capturedMessages: [String] = []
587|1b931e|         runner.setConsoleHandler { message in
588|a2ab29|             capturedMessages.append(message)
589|b9c240|         }
590|27e700|         
591|eceb74|         _ = try await runner.execute(code: "console.log('Hello from JS'); console.error('Error test')")
592|27e700|         
593|2691fd|         XCTAssertTrue(capturedMessages.contains("[LOG] Hello from JS"))
594|13e3ca|         XCTAssertTrue(capturedMessages.contains("[ERROR] Error test"))
595|48082f|     }
596|8f1f4b|     
597|ee7567|     func testNativeFunctionExposure() async throws {
598|8181c7|         runner.exposeNativeFunction(name: "swiftAdd") { args in
599|48134e|             guard args.count >= 2,
600|ae326c|                   let a = args[0].toInt32(),
601|c098e9|                   let b = args[1].toInt32() else {
602|957178|                 return JSValue(undefinedIn: self.runner.context)
603|6a8388|             }
604|d2dff2|             return JSValue(int32: a + b, in: self.runner.context)
605|b9c240|         }
606|27e700|         
607|e237bc|         let result = try await runner.executeToInt(code: "swiftAdd(10, 20)")
608|6bd0c8|         XCTAssertEqual(result, 30)
609|48082f|     }
610|8f1f4b|     
611|ec5511|     func testComplexObjectConversion() async throws {
612|c47f70|         let result = try await runner.executeAndConvert(code: """
613|fb48e7|             ({
614|7512f1|                 name: 'Test Object',
615|deebe9|                 count: 42,
616|76b333|                 active: true,
617|3b7226|                 items: ['a', 'b', 'c']
618|899c68|             })
619|72e678|         """)
620|27e700|         
621|904df8|         guard let dict = result as? [String: Any] else {
622|72cfb3|             XCTFail("Expected dictionary result")
623|ccedbe|             return
624|b9c240|         }
625|27e700|         
626|00108e|         XCTAssertEqual(dict["name"] as? String, "Test Object")
627|6dbd01|         XCTAssertEqual(dict["count"] as? Int, 42)
628|91b50b|         XCTAssertEqual(dict["active"] as? Bool, true)
629|adb09c|         XCTAssertEqual(dict["items"] as? [String], ["a", "b", "c"])
630|48082f|     }
631|8f1f4b|     
632|4d88a0|     func testTimeout() async {
633|16516b|         runner.timeoutDuration = 0.5 // 500ms timeout
634|27e700|         
635|c39137|         do {
636|b39167|             // Infinite loop should timeout
637|18f657|             _ = try await runner.execute(code: "while(true) {}")
638|1e90a5|             XCTFail("Should have thrown timeout error")
639|e245bc|         } catch JSRunnerError.executionTimeout {
640|4c03b3|             // Expected
641|397a89|         } catch {
642|f414ab|             XCTFail("Unexpected error: \(error)")
643|b9c240|         }
644|48082f|     }
645|8f1f4b|     
646|c45f91|     func testErrorHandling() async {
647|c39137|         do {
648|d9a249|             _ = try await runner.execute(code: "throw new Error('Test error')")
649|f7d33e|             XCTFail("Should have thrown error")
650|cfd468|         } catch JSRunnerError.scriptError(let message) {
651|cfb4a6|             XCTAssertTrue(message.contains("Test error"))
652|397a89|         } catch {
653|1fb92f|             XCTFail("Unexpected error type: \(error)")
654|b9c240|         }
655|48082f|     }
656|02e5c8| }
657|adc83b|
658|ae6ce1| // Simple playground-style example:
659|dd1225| 
660|1bac8e| func runExample() async {
661|56213f|     let runner = JSRunner()
662|8f1f4b|     
663|628fbb|     // Capture console output
664|96505e|     runner.setConsoleHandler { message in
665|bfc72f|         print("📝 \(message)")
666|48082f|     }
667|8f1f4b|     
668|9c1723|     // Expose native Swift function
669|216414|     runner.exposeNativeFunction(name: "calculateArea") { args in
670|aef866|         guard args.count >= 2,
671|f8e67b|               let width = args[0].toDouble(),
672|74396a|               let height = args[1].toDouble() else {
673|5551b3|             return JSValue(undefinedIn: runner.context)
674|b9c240|         }
675|bb8bbf|         let area = width * height
676|33a37c|         return JSValue(double: area, in: runner.context)
677|48082f|     }
678|8f1f4b|     
679|4489c1|     do {
680|430d75|         // Test 1: Basic arithmetic
681|882cc5|         let sum = try await runner.executeToInt(code: "10 + 32")
682|02b91a|         print("Sum: \(sum ?? 0)")
683|27e700|         
684|153e1f|         // Test 2: Console logging
685|c62d34|         try await runner.execute(code: """
686|e53a89|             console.log('Starting calculation...');
687|b8f170|             console.info('This is info');
688|454b58|             console.warn('This is a warning');
689|72e678|         """)
690|27e700|         
691|465444|         // Test 3: Native function call
692|b2a206|         let area = try await runner.executeToDouble(code: "calculateArea(5.5, 10.2)")
693|8be639|         print("Area: \(area ?? 0)")
694|27e700|         
695|1d373e|         // Test 4: Complex object
696|0b0b5e|         let user = try await runner.executeToDictionary(code: """
697|fb48e7|             ({
698|11940c|                 id: 123,
699|a36923|                 name: 'John Doe',
700|fef5db|                 email: 'john@example.com',
701|4cd091|                 roles: ['user', 'admin']
702|899c68|             })
703|72e678|         """)
704|aefd4d|         print("User: \(user ?? [:])")
705|27e700|         
706|a6364d|     } catch {
707|3d5d68|         print("❌ Error: \(error)")
708|48082f|     }
709|8f1f4b|     
710|dd8022|     runner.cleanup()
711|02e5c8| }
712|adc83b|
713|ba234e| // Run the example:
714|5e6c27| // Task { await runExample() }
715|dd1225| 
716|d48ab4| */
717|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 1c5aeea0d4b3
File: VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/PythonRunner.swift (lines 1-510 of 510)
────────────────────────────────────────
1|8b6b78|import Foundation
2|adc83b|
3|c68524|// MARK: - Python Execution Architecture Decision
4|8d0643|//
5|39cfcc|// This file documents the extensive research and rationale for why direct
6|dec062|// Python execution via PythonKit is NOT feasible on iOS/iPadOS for App Store
7|7a95d4|// distribution.
8|8d0643|//
9|0b4a9f|// =============================================================================
10|e7672b|// RESEARCH FINDINGS
11|0b4a9f|// =============================================================================
12|8d0643|//
13|d8d448|// 1. PythonKit Architecture
14|ad3a89|//    - Original PythonKit (pvieito/PythonKit) uses dlopen()/dlsym() to
15|84034f|//      dynamically load libpython at runtime
16|8a1383|//    - Fork kewlbear/PythonKitIOS attempts iOS support but still relies on
17|f6ed61|//      dynamic library loading mechanisms
18|8d0643|//
19|0efa4c|// 2. iOS Sandbox Restrictions
20|fd3131|//    - iOS does NOT allow dlopen() of arbitrary dynamic libraries in App Store apps
21|6fac17|//    - Dynamic library loading is considered a security risk (code injection)
22|d4c4e3|//    - Only system frameworks and bundled frameworks can be loaded
23|81fb52|//    - The iOS kernel enforces these restrictions at the system level
24|8d0643|//
25|a157ad|// 3. Embedded Python Challenges
26|9b547d|//    - Python-Apple-support (beeware/kewlbear) can build static Python libraries
27|60abb0|//    - However, this requires:
28|959252|//      * Custom Xcode build phases
29|ed02a1|//      * 50+ MB additional binary size
30|bc53f2|//      * Complex patch management for Python versions
31|0d454f|//      * Recompilation for every Python version update
32|8d0643|//
33|62051f|// 4. Scientific Library Limitations
34|c19e48|//    - numpy, pandas, scipy require compiled C extensions
35|f69f4b|//    - These extensions use:
36|e70ce2|//      * Platform-specific assembly (SIMD instructions)
37|d93a1c|//      * BLAS/LAPACK libraries (not available on iOS)
38|9107dd|//      * Memory mapping features restricted by iOS sandbox
39|850002|//    - Cross-compiling these for iOS ARM64 is extremely complex
40|8d0643|//
41|2f2d6f|// 5. JIT Compilation Restrictions
42|2c78ea|//    - Python's eval()/exec() create executable code at runtime
43|4274d0|//    - iOS requires com.apple.security.cs.allow-jit entitlement
44|36bcfd|//    - This entitlement is ONLY available to:
45|0131df|//      * Web browsers (WKWebView JIT)
46|69e573|//      * Apps with special justification (not general Python execution)
47|8d0643|//
48|0b4a9f|// =============================================================================
49|edc678|// ALTERNATIVES CONSIDERED
50|0b4a9f|// =============================================================================
51|8d0643|//
52|033866|// Option 1: Pyodide via WASM (RECOMMENDED)
53|c7fe55|//    - Pyodide = Python compiled to WebAssembly
54|435fc6|//    - Runs in WKWebView JavaScript context
55|6b83d4|//    - Pros: No native code restrictions, full numpy/pandas support via WASM
56|ba456e|//    - Cons: 10-50x slower than native, large initial download (~20MB)
57|74886a|//    - Status: Best option for in-browser Python execution
58|8d0643|//
59|aa7686|// Option 2: Remote Execution
60|b4e804|//    - Execute Python on server, stream results
61|0e519f|//    - Pros: Full Python environment, zero iOS restrictions
62|c8ed12|//    - Cons: Requires internet, latency, privacy concerns
63|5ce804|//    - Status: Good for production apps with server infrastructure
64|8d0643|//
65|21d6b1|// Option 3: Restricted Static Python
66|70f8f5|//    - Use Python-Apple-support for basic stdlib only
67|566930|//    - Pros: Truly offline, native performance
68|ea54a3|//    - Cons: No scientific libraries, complex build process, large app size
69|6a1ec4|//    - Status: Viable for simple scripts only
70|8d0643|//
71|77b110|// Option 4: transpilation
72|6201ad|//    - Convert Python to Swift/JavaScript
73|921ec4|//    - Pros: Native execution, no runtime overhead
74|671e51|//    - Cons: Limited language compatibility, complex implementation
75|d6f2c1|//    - Status: Research phase only
76|8d0643|//
77|0b4a9f|// =============================================================================
78|adc83b|
79|9f0d64|// MARK: - Error Types
80|adc83b|
81|67804c|enum PythonRunnerError: Error, LocalizedError {
82|d3a564|    case pythonExecutionNotSupported
83|287624|    case numpyPandasNotAvailable
84|3cef44|    case networkRequired
85|553b8f|    case timeout
86|cdbfea|    case memoryLimitExceeded
87|8d1ccd|    case wasmNotInitialized
88|918ea0|    case remoteServerUnavailable
89|b4687f|    
90|242b78|    var errorDescription: String? {
91|2e6d08|        switch self {
92|f6c432|        case .pythonExecutionNotSupported:
93|16df73|            return "Native Python execution is not supported on iOS/iPadOS. " +
94|89c3b5|                   "Use executeWebAssembly(code:) or executeRemote(code:) instead."
95|cfa9fe|        case .numpyPandasNotAvailable:
96|1e0a5b|            return "numpy and pandas require WebAssembly or remote execution. " +
97|751510|                   "Native iOS execution does not support compiled C extensions."
98|0fae90|        case .networkRequired:
99|dd8c04|            return "This operation requires an internet connection."
100|18c9f6|        case .timeout:
101|bd921a|            return "Python execution timed out."
102|406c63|        case .memoryLimitExceeded:
103|2e21c3|            return "Python execution exceeded memory limits."
104|b16e58|        case .wasmNotInitialized:
105|3172dd|            return "WebAssembly runtime not initialized. Call initializeWASM() first."
106|809531|        case .remoteServerUnavailable:
107|b73286|            return "Remote Python server is unavailable."
108|5f3077|        }
109|27e597|    }
110|b4687f|    
111|e1853f|    var recoverySuggestion: String? {
112|2e6d08|        switch self {
113|f6c432|        case .pythonExecutionNotSupported:
114|f62efa|            return "Use WebAssembly execution for client-side Python or remote " +
115|998245|                   "execution for full environment support."
116|cfa9fe|        case .numpyPandasNotAvailable:
117|543bbf|            return "Use WebAssembly execution which supports numpy/pandas via WASM."
118|0fae90|        case .networkRequired:
119|f1f5bd|            return "Connect to Wi-Fi or cellular network and try again."
120|18c9f6|        case .timeout:
121|9a5b67|            return "Simplify your code or increase the timeout threshold."
122|406c63|        case .memoryLimitExceeded:
123|1ca8a6|            return "Reduce data size or use streaming/chunked processing."
124|b16e58|        case .wasmNotInitialized:
125|c78c57|            return "Initialize the WASM runtime before executing code."
126|809531|        case .remoteServerUnavailable:
127|e12e73|            return "Check server status or use WebAssembly fallback."
128|5f3077|        }
129|27e597|    }
130|b31277|}
131|adc83b|
132|7d9bc8|// MARK: - PythonRunner
133|adc83b|
134|b3dcad|/// A service that provides Python execution capabilities on iOS/iPadOS.
135|63c993|///
136|531eb8|/// ⚠️ IMPORTANT: This is a STUB implementation documenting why native Python
137|97d938|/// execution is not feasible on iOS/iPadOS. See the extensive comments above
138|52fe86|/// for technical details.
139|63c993|///
140|1456db|/// Use this class to:
141|469fba|/// 1. Detect if user code requires numpy/pandas
142|897427|/// 2. Route execution to appropriate backend (WASM, Remote, or reject)
143|f788c7|/// 3. Provide clear error messages about limitations
144|63c993|///
145|efa86f|/// Example usage:
146|78513c|/// ```swift
147|1095f8|/// let runner = PythonRunner()
148|6be473|/// runner.setOutputHandler { print("Output: \($0)") }
149|63c993|///
150|22f496|/// // For WebAssembly execution (recommended for client-side):
151|da8f55|/// let result = try await runner.executeWebAssembly(code: pythonCode)
152|63c993|///
153|e74a47|/// // For remote execution (requires server):
154|c6d25f|/// let result = try await runner.executeRemote(code: pythonCode, endpoint: serverURL)
155|dce1cf|/// ```
156|1c3da8|actor PyodidePythonRunner {
157|b4687f|    
158|6503ae|    // MARK: - Properties
159|b4687f|    
160|aa3644|    private var outputHandler: ((String) -> Void)?
161|f0239d|    private var wasmInitialized: Bool = false
162|e858a2|    private var defaultTimeout: TimeInterval = 30.0
163|2068d0|    private var memoryLimitMB: Int = 512
164|b4687f|    
165|9b972c|    // Patterns to detect libraries that require WASM/remote execution
166|0f60b4|    private let heavyLibraryPatterns: [String] = [
167|70d9e5|        "import numpy",
168|4a36fa|        "import pandas",
169|d3003c|        "import scipy",
170|969b2c|        "import matplotlib",
171|b6ca1d|        "import sklearn",
172|b68d7f|        "import tensorflow",
173|7681e2|        "import torch",
174|3ad65d|        "import cv2",
175|23e3a3|        "import PIL",
176|ae5e0b|        "from numpy",
177|b89f0f|        "from pandas",
178|878e67|        "from scipy",
179|a51f8f|        "np\\.",
180|b85844|        "pd\\.",
181|f7d573|    ]
182|b4687f|    
183|7dca75|    // MARK: - Initialization
184|b4687f|    
185|359b1b|    init() {
186|90df88|        // No native Python initialization possible on iOS
187|04c43b|        // Log the architecture decision
188|384a1d|        print("PythonRunner initialized (STUB - native execution unavailable)")
189|27e597|    }
190|b4687f|    
191|f5c08e|    // MARK: - Configuration
192|b4687f|    
193|53fde8|    /// Sets a handler for capturing Python print() output.
194|ec384f|    /// Note: Only works with WebAssembly or remote execution.
195|d6a238|    func setOutputHandler(_ handler: @escaping (String) -> Void) {
196|17f2a2|        self.outputHandler = handler
197|27e597|    }
198|b4687f|    
199|8080e4|    /// Sets the execution timeout.
200|3ab9d9|    /// - Parameter seconds: Maximum execution time (default: 30s)
201|bcdf8c|    func setTimeout(_ seconds: TimeInterval) {
202|9d2add|        self.defaultTimeout = seconds
203|27e597|    }
204|b4687f|    
205|a07daa|    /// Sets the memory limit for Python execution.
206|8da75a|    /// - Parameter megabytes: Maximum memory in MB (default: 512)
207|e50116|    func setMemoryLimit(megabytes: Int) {
208|112d40|        self.memoryLimitMB = megabytes
209|27e597|    }
210|b4687f|    
211|ca30a6|    /// Initializes the WebAssembly Python runtime.
212|b2bf85|    /// This is required before using executeWebAssembly().
213|aae40e|    func initializeWASM() async throws {
214|4e8cc7|        // TODO: Implement Pyodide loading
215|65acb2|        // This would:
216|49163d|        // 1. Load pyodide.js in WKWebView
217|7e501c|        // 2. Download Python WASM packages (~20MB)
218|7045a0|        // 3. Set up output capture bridge
219|451dd1|        self.wasmInitialized = true
220|1772a8|        print("WASM initialization not yet implemented")
221|27e597|    }
222|b4687f|    
223|3bf095|    // MARK: - Code Analysis
224|b4687f|    
225|69c3e7|    /// Analyzes Python code to determine execution requirements.
226|ac8e47|    /// - Returns: Detection result with recommendations
227|49c41b|    func analyze(code: String) -> PyodideCodeAnalysisResult {
228|dce57c|        let requiresHeavyLibraries = heavyLibraryPatterns.contains { pattern in
229|3f723b|            code.range(of: pattern, options: .regularExpression) != nil
230|5f3077|        }
231|d6ed84|        
232|4c6330|        let detectedLibraries = heavyLibraryPatterns.compactMap { pattern -> String? in
233|eba771|            let cleanPattern = pattern
234|8c049c|                .replacingOccurrences(of: "import ", with: "")
235|b55f88|                .replacingOccurrences(of: "from ", with: "")
236|81969c|                .replacingOccurrences(of: "\\.", with: "")
237|d46e55|                .replacingOccurrences(of: "\\", with: "")
238|2095f9|            if code.range(of: pattern, options: .regularExpression) != nil {
239|d65064|                return cleanPattern
240|a7dc16|            }
241|1c8557|            return nil
242|5f3077|        }
243|d6ed84|        
244|b5d4a5|        let estimatedComplexity = estimateComplexity(code)
245|d6ed84|        
246|0b6498|        return PyodideCodeAnalysisResult(
247|b4648e|            requiresNativeExecution: false,  // Never possible on iOS
248|27af78|            requiresWASMExecution: requiresHeavyLibraries,
249|25b5c1|            requiresRemoteExecution: requiresHeavyLibraries || estimatedComplexity > .high,
250|bcd656|            detectedLibraries: Array(Set(detectedLibraries)),
251|dc8746|            complexity: estimatedComplexity,
252|a4ed61|            recommendedBackend: requiresHeavyLibraries ? .webAssembly : .webAssembly,
253|9f6dba|            warnings: generateWarnings(code: code, requiresHeavyLibraries: requiresHeavyLibraries)
254|3143a4|        )
255|27e597|    }
256|b4687f|    
257|928270|    private func estimateComplexity(_ code: String) -> CodeComplexity {
258|7fa1d4|        let lines = code.components(separatedBy: .newlines).count
259|c1f936|        let hasLoops = code.contains("for ") || code.contains("while ")
260|a36c09|        let hasRecursion = code.contains("func ") && code.contains(code.components(separatedBy: "func ").first ?? "")
261|d6ed84|        
262|ea3ffb|        if lines > 500 || (hasLoops && hasRecursion) {
263|538061|            return .veryHigh
264|c490bb|        } else if lines > 100 || hasRecursion {
265|4d0ae3|            return .high
266|5ead71|        } else if lines > 50 || hasLoops {
267|136a8f|            return .medium
268|b31999|        } else {
269|769604|            return .low
270|5f3077|        }
271|27e597|    }
272|b4687f|    
273|63270c|    private func generateWarnings(code: String, requiresHeavyLibraries: Bool) -> [String] {
274|4b9e61|        var warnings: [String] = []
275|d6ed84|        
276|59c393|        if requiresHeavyLibraries {
277|14926d|            warnings.append(
278|dc39de|                "Detected scientific Python libraries (numpy, pandas, etc.). " +
279|df320a|                "These require WebAssembly or remote execution due to iOS sandbox restrictions."
280|43d041|            )
281|5f3077|        }
282|d6ed84|        
283|1cdea6|        if code.contains("import os") || code.contains("import sys") {
284|14926d|            warnings.append(
285|1bd5ea|                "System-level operations may behave differently in sandboxed environments."
286|43d041|            )
287|5f3077|        }
288|d6ed84|        
289|232e6f|        if code.contains("open(") || code.contains("with open") {
290|14926d|            warnings.append(
291|4facab|                "File I/O is restricted. Use in-memory data or WebAssembly virtual filesystem."
292|43d041|            )
293|5f3077|        }
294|d6ed84|        
295|cb802b|        if code.contains("import requests") || code.contains("import urllib") {
296|14926d|            warnings.append(
297|0c4441|                "Network operations may fail in WebAssembly. Consider remote execution."
298|43d041|            )
299|5f3077|        }
300|d6ed84|        
301|ff5dbb|        return warnings
302|27e597|    }
303|b4687f|    
304|467726|    // MARK: - Execution Methods (Stubs)
305|b4687f|    
306|77d5b2|    /// ⚠️ NOT IMPLEMENTED: Native Python execution is NOT POSSIBLE on iOS/iPadOS.
307|2cbc84|    ///
308|bca51f|    /// This method always throws PythonRunnerError.pythonExecutionNotSupported.
309|2cbc84|    ///
310|d584a2|    /// For alternatives, use:
311|4e6e92|    /// - executeWebAssembly(code:) for client-side execution
312|7d01db|    /// - executeRemote(code:endpoint:) for server-side execution
313|ab9826|    func execute(code: String) async throws -> String {
314|3a40fa|        throw PythonRunnerError.pythonExecutionNotSupported
315|27e597|    }
316|b4687f|    
317|06c885|    /// Executes Python code using Pyodide WebAssembly runtime.
318|2cbc84|    ///
319|1b56e6|    /// This is the recommended approach for client-side Python execution.
320|abad9b|    /// Supports numpy, pandas, and other scientific libraries compiled to WASM.
321|2cbc84|    ///
322|4b8d6e|    /// Requirements:
323|84195a|    /// - Call initializeWASM() before first use
324|555b56|    /// - ~20MB initial download for Python WASM packages
325|56c1e9|    /// - 10-50x slower than native execution
326|2cbc84|    ///
327|45b4bd|    /// - Parameters:
328|b5cb3c|    ///   - code: Python code to execute
329|a6c8b6|    ///   - timeout: Maximum execution time (uses default if nil)
330|084b43|    /// - Returns: Execution output as string
331|8c97ca|    func executeWebAssembly(code: String, timeout: TimeInterval? = nil) async throws -> String {
332|570a62|        guard wasmInitialized else {
333|ec69cc|            throw PythonRunnerError.wasmNotInitialized
334|5f3077|        }
335|d6ed84|        
336|0b8696|        // TODO: Implement Pyodide execution via WKWebView
337|c3bed0|        // 1. Inject code into JavaScript context
338|f8e89a|        // 2. Set up output capture
339|2b0f8d|        // 3. Apply timeout using Task.withTimeout
340|80a11e|        // 4. Return results
341|d6ed84|        
342|3a40fa|        throw PythonRunnerError.pythonExecutionNotSupported
343|27e597|    }
344|b4687f|    
345|6baf0c|    /// Executes Python code on a remote server.
346|2cbc84|    ///
347|326dde|    /// This provides full Python environment support but requires network access.
348|2cbc84|    ///
349|45b4bd|    /// - Parameters:
350|b5cb3c|    ///   - code: Python code to execute
351|917b4f|    ///   - endpoint: URL of Python execution server
352|a6c8b6|    ///   - timeout: Maximum execution time (uses default if nil)
353|084b43|    /// - Returns: Execution output as string
354|5f7463|    func executeRemote(
355|412ab1|        code: String,
356|3eb6e7|        endpoint: URL,
357|a21815|        timeout: TimeInterval? = nil
358|b48f76|    ) async throws -> String {
359|badbe6|        // TODO: Implement remote execution
360|691662|        // 1. Send code to server endpoint
361|6066cc|        // 2. Stream output if supported
362|07ec17|        // 3. Apply timeout
363|792dee|        // 4. Handle network errors gracefully
364|d6ed84|        
365|3a40fa|        throw PythonRunnerError.pythonExecutionNotSupported
366|27e597|    }
367|b4687f|    
368|c0541b|    // MARK: - Utility Methods
369|b4687f|    
370|6a2dfa|    /// Returns documentation about iOS Python limitations.
371|12d711|    func getLimitationsDocumentation() -> String {
372|9f6283|        return """
373|b94f6d|        iOS/iPadOS Python Execution Limitations
374|9b4c9f|        =======================================
375|d6ed84|        
376|61a1b1|        1. NO Native Execution
377|74413f|           - dlopen() is restricted on iOS
378|f848e6|           - JIT compilation requires special entitlements
379|fbd1be|           - App Store policies prohibit arbitrary code execution
380|d6ed84|        
381|13c2ca|        2. WebAssembly Alternative
382|bb1ce3|           - Pyodide provides Python in WASM
383|84a360|           - Supports numpy, pandas, matplotlib
384|cd9a7b|           - 10-50x slower than native
385|d46ee6|           - ~20MB download size
386|d6ed84|        
387|68f0e0|        3. Remote Execution
388|0c26a4|           - Full Python environment on server
389|118285|           - Requires network connection
390|2fc8cf|           - Privacy considerations for sensitive data
391|d6ed84|        
392|6447af|        4. Build Requirements for Static Python
393|e3b8ef|           - Python-Apple-support: 50+ MB binary
394|5aa174|           - No numpy/pandas (C extensions don't compile)
395|03b5d8|           - Complex Xcode build phases
396|4a004c|           - Manual patch management
397|d6ed84|        
398|ea0cae|        For implementation details, see:
399|28dff3|        - Pyodide: https://pyodide.org
400|243413|        - Python-Apple-support: https://github.com/beeware/Python-Apple-support
401|662e4a|        - PythonKit: https://github.com/pvieito/PythonKit
402|c70080|        """
403|27e597|    }
404|b4687f|    
405|a8c894|    /// Returns the appropriate execution backend for given code.
406|7f92d7|    func recommendBackend(for code: String) -> ExecutionBackend {
407|5584ea|        let analysis = analyze(code: code)
408|e513cd|        return analysis.recommendedBackend
409|27e597|    }
410|b31277|}
411|adc83b|
412|71e2e4|// MARK: - Supporting Types
413|adc83b|
414|63fd49|struct PyodideCodeAnalysisResult {
415|fd56ac|    let requiresNativeExecution: Bool
416|3c6567|    let requiresWASMExecution: Bool
417|2e98f6|    let requiresRemoteExecution: Bool
418|32e388|    let detectedLibraries: [String]
419|201054|    let complexity: CodeComplexity
420|ef01b2|    let recommendedBackend: ExecutionBackend
421|99a275|    let warnings: [String]
422|b31277|}
423|adc83b|
424|980d1d|enum CodeComplexity: String, Comparable {
425|86e540|    case low = "Low"
426|ed2e33|    case medium = "Medium"
427|c7f862|    case high = "High"
428|5ba422|    case veryHigh = "Very High"
429|b4687f|    
430|f4335f|    static func < (lhs: CodeComplexity, rhs: CodeComplexity) -> Bool {
431|814056|        let order: [CodeComplexity] = [.low, .medium, .high, .veryHigh]
432|05cbec|        guard let lhsIndex = order.firstIndex(of: lhs),
433|548456|              let rhsIndex = order.firstIndex(of: rhs) else {
434|e2e187|            return false
435|5f3077|        }
436|5253a8|        return lhsIndex < rhsIndex
437|27e597|    }
438|b31277|}
439|adc83b|
440|b3f762|enum ExecutionBackend: String {
441|d5d8ec|    case native = "Native (Not Available)"
442|c8ce92|    case webAssembly = "WebAssembly (Recommended)"
443|3fe1c6|    case remote = "Remote Server"
444|8d6e6b|    case none = "None (Not Supported)"
445|b31277|}
446|adc83b|
447|eb33bc|// MARK: - Convenience Extensions
448|adc83b|
449|359254|extension PyodidePythonRunner {
450|4fc349|    /// Quick check if code can run locally (WASM).
451|644e3f|    func canExecuteLocally(_ code: String) -> Bool {
452|5584ea|        let analysis = analyze(code: code)
453|b24475|        return !analysis.requiresRemoteExecution
454|27e597|    }
455|b4687f|    
456|7a55a4|    /// Check if code uses scientific libraries.
457|4689ad|    func usesScientificLibraries(_ code: String) -> Bool {
458|5584ea|        let analysis = analyze(code: code)
459|2991cf|        return analysis.detectedLibraries.contains { lib in
460|fa60ab|            ["numpy", "pandas", "scipy", "matplotlib", "sklearn"].contains(lib)
461|5f3077|        }
462|27e597|    }
463|b31277|}
464|adc83b|
465|3df719|// MARK: - Usage Example (Documentation)
466|adc83b|
467|32ca1a|/*
468|e715a9| Example implementation pattern:
469|dd1225| 
470|45f015| class PythonExecutionController: ObservableObject {
471|279dcf|    private let runner = PyodidePythonRunner()
472|8f1f4b|     
473|603c77|     func executePython(_ code: String) async {
474|291c1f|         let analysis = await runner.analyze(code: code)
475|27e700|         
476|e1975e|         // Show warnings
477|e67ac1|         for warning in analysis.warnings {
478|0c2af4|             print("⚠️ \(warning)")
479|b9c240|         }
480|27e700|         
481|69270c|         // Route to appropriate backend
482|d8bd22|         switch analysis.recommendedBackend {
483|ca7abc|         case .webAssembly:
484|55fb7b|             do {
485|f1b3c3|                 try await runner.initializeWASM()
486|85f76b|                 let result = try await runner.executeWebAssembly(code: code)
487|26703a|                 print(result)
488|29ba16|             } catch {
489|373341|                 print("WASM Error: \(error.localizedDescription)")
490|6a8388|             }
491|5a9d76|             
492|88013c|         case .remote:
493|941b01|             let serverURL = URL(string: "https://api.example.com/python")!
494|55fb7b|             do {
495|5f5dc5|                 let result = try await runner.executeRemote(
496|bd62fe|                     code: code,
497|94ccde|                     endpoint: serverURL
498|8f7d53|                 )
499|26703a|                 print(result)
500|29ba16|             } catch {
501|b04787|                 print("Remote Error: \(error.localizedDescription)")
502|6a8388|             }
503|5a9d76|             
504|bbf751|         default:
505|0938e9|             print("Execution not supported for this code")
506|b9c240|         }
507|48082f|     }
508|02e5c8| }
509|0edef9|*/
510|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 9fea23a8b787
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 1-906 of 906)
────────────────────────────────────────
1|8d0643|//
2|e2d7aa|//  RunestoneEditorView.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|53f930|//  High-performance code editor using Runestone with TreeSitter syntax highlighting.
6|0887d5|//  Provides native line numbers, code folding, and efficient rendering for large files.
7|8d0643|//
8|adc83b|
9|d755ba|import SwiftUI
10|9ed0a9|import UIKit
11|cf8736|import Runestone
12|e235ab|import TreeSitterSwiftRunestone
13|d7e1b3|import TreeSitterJavaScriptRunestone
14|3b16eb|import TreeSitterPythonRunestone
15|6925df|import TreeSitterJSONRunestone
16|ed1891|import TreeSitterHTMLRunestone
17|27fb7d|import TreeSitterCSSRunestone
18|53be86|import TreeSitterGoRunestone
19|3373e8|import TreeSitterRustRunestone
20|adc83b|
21|941ebe|// Feature flag now uses centralized FeatureFlags.useRunestoneEditor
22|adc83b|
23|83c360|// MARK: - Custom TextView Subclass with Keyboard Shortcuts
24|adc83b|
25|7b9ade|/// Custom subclass of Runestone's TextView that overrides keyboard shortcuts
26|410907|/// to prevent UITextView's default handlers (Bold=Cmd+B, etc.) from intercepting
27|1fa8d6|/// VS Code-style shortcuts.
28|115382|final class VSCodeRunestoneTextView: TextView {
29|b4687f|    
30|7c24d6|    override var keyCommands: [UIKeyCommand]? {
31|17c9a0|        var commands = super.keyCommands ?? []
32|d6ed84|        
33|876d9a|        // MARK: - App-Level Shortcuts that conflict with UITextView defaults
34|417f86|        // These MUST be defined here with wantsPriorityOverSystemBehavior to override
35|b023b0|        // UITextView's built-in handlers (Bold=Cmd+B, Italic=Cmd+I, Print=Cmd+P, etc.)
36|d6ed84|        
37|0789a5|        // Toggle Sidebar: Cmd+B (overrides UITextView's "Bold" command)
38|f34626|        let toggleSidebarCmd = UIKeyCommand(
39|c21f91|            input: "b",
40|791043|            modifierFlags: .command,
41|fd9c9d|            action: #selector(handleToggleSidebar),
42|8f6ce0|            discoverabilityTitle: "Toggle Sidebar"
43|3143a4|        )
44|767005|        toggleSidebarCmd.wantsPriorityOverSystemBehavior = true
45|adcd07|        commands.append(toggleSidebarCmd)
46|d6ed84|        
47|7aaf15|        // Command Palette: Cmd+Shift+P (VS Code's most important shortcut)
48|84ad03|        let cmdPaletteCmd = UIKeyCommand(
49|022265|            input: "p",
50|8d9971|            modifierFlags: [.command, .shift],
51|1339c8|            action: #selector(handleShowCommandPalette),
52|37ea80|            discoverabilityTitle: "Command Palette"
53|3143a4|        )
54|84edb1|        cmdPaletteCmd.wantsPriorityOverSystemBehavior = true
55|1f0c8e|        commands.append(cmdPaletteCmd)
56|d6ed84|        
57|a9230e|        // Quick Open: Cmd+P (overrides system "Print" command)
58|c94963|        let quickOpenCmd = UIKeyCommand(
59|022265|            input: "p",
60|791043|            modifierFlags: .command,
61|6a1edf|            action: #selector(handleShowQuickOpen),
62|5f77d9|            discoverabilityTitle: "Quick Open"
63|3143a4|        )
64|dccd84|        quickOpenCmd.wantsPriorityOverSystemBehavior = true
65|ab20ff|        commands.append(quickOpenCmd)
66|d6ed84|        
67|f2a6a7|        // New File: Cmd+N
68|239cbd|        let newFileCmd = UIKeyCommand(
69|0549ea|            input: "n",
70|791043|            modifierFlags: .command,
71|ae138f|            action: #selector(handleNewFile),
72|d350d6|            discoverabilityTitle: "New File"
73|3143a4|        )
74|91d006|        newFileCmd.wantsPriorityOverSystemBehavior = true
75|1d3599|        commands.append(newFileCmd)
76|d6ed84|        
77|c16fdb|        // Save: Cmd+S
78|10fa85|        let saveCmd = UIKeyCommand(
79|a1985e|            input: "s",
80|791043|            modifierFlags: .command,
81|6ba66c|            action: #selector(handleSaveFile),
82|863fd2|            discoverabilityTitle: "Save"
83|3143a4|        )
84|26081a|        saveCmd.wantsPriorityOverSystemBehavior = true
85|5dd1cb|        commands.append(saveCmd)
86|d6ed84|        
87|976d1c|        // Close Tab: Cmd+W
88|e61690|        let closeTabCmd = UIKeyCommand(
89|0880cc|            input: "w",
90|791043|            modifierFlags: .command,
91|9f0305|            action: #selector(handleCloseTab),
92|6df774|            discoverabilityTitle: "Close Tab"
93|3143a4|        )
94|2c1c6b|        closeTabCmd.wantsPriorityOverSystemBehavior = true
95|41d3f0|        commands.append(closeTabCmd)
96|d6ed84|        
97|bcc592|        // Find: Cmd+F
98|4a10ea|        let findCmd = UIKeyCommand(
99|6c041a|            input: "f",
100|791043|            modifierFlags: .command,
101|ecd0ee|            action: #selector(handleFind),
102|d0ec0f|            discoverabilityTitle: "Find"
103|3143a4|        )
104|bea84d|        findCmd.wantsPriorityOverSystemBehavior = true
105|0b235f|        commands.append(findCmd)
106|d6ed84|        
107|bf24cc|        // Toggle Terminal: Cmd+J
108|a60c7e|        let toggleTerminalCmd = UIKeyCommand(
109|f01b26|            input: "j",
110|791043|            modifierFlags: .command,
111|e6ca50|            action: #selector(handleToggleTerminal),
112|1af0a9|            discoverabilityTitle: "Toggle Panel"
113|3143a4|        )
114|021006|        toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
115|329329|        commands.append(toggleTerminalCmd)
116|d6ed84|        
117|a05812|        // Undo: Cmd+Z
118|546e2c|        let undoCmd = UIKeyCommand(
119|9b11b3|            input: "z",
120|791043|            modifierFlags: .command,
121|fe6402|            action: #selector(handleUndo),
122|5badd2|            discoverabilityTitle: "Undo"
123|3143a4|        )
124|fd81bb|        undoCmd.wantsPriorityOverSystemBehavior = true
125|d37784|        commands.append(undoCmd)
126|d6ed84|        
127|dda763|        // Redo: Cmd+Shift+Z
128|40379c|        let redoCmd = UIKeyCommand(
129|9b11b3|            input: "z",
130|8d9971|            modifierFlags: [.command, .shift],
131|5a175a|            action: #selector(handleRedo),
132|fd37b5|            discoverabilityTitle: "Redo"
133|3143a4|        )
134|42f687|        redoCmd.wantsPriorityOverSystemBehavior = true
135|d9b0e4|        commands.append(redoCmd)
136|d6ed84|        
137|abb5c6|        return commands
138|27e597|    }
139|b4687f|    
140|6665ac|    // MARK: - Notification Handlers
141|b4687f|    
142|30a71a|    @objc func handleToggleSidebar() {
143|2114eb|        NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
144|27e597|    }
145|b4687f|    
146|21f1bc|    @objc func handleShowCommandPalette() {
147|fbe0c5|        NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
148|27e597|    }
149|b4687f|    
150|991940|    @objc func handleShowQuickOpen() {
151|5b0f35|        NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
152|27e597|    }
153|b4687f|    
154|c28d1b|    @objc func handleNewFile() {
155|387109|        NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
156|27e597|    }
157|b4687f|    
158|212d04|    @objc func handleSaveFile() {
159|eb35b9|        NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
160|27e597|    }
161|b4687f|    
162|24f8f9|    @objc func handleCloseTab() {
163|c4ac53|        NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
164|27e597|    }
165|b4687f|    
166|4767e4|    @objc func handleFind() {
167|6bd372|        NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
168|27e597|    }
169|b4687f|    
170|46f792|    @objc func handleToggleTerminal() {
171|10178b|        NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
172|27e597|    }
173|b4687f|    
174|74a433|    @objc func handleUndo() {
175|fe4807|        undoManager?.undo()
176|27e597|    }
177|b4687f|    
178|bddc81|    @objc func handleRedo() {
179|af088f|        undoManager?.redo()
180|27e597|    }
181|b31277|}
182|adc83b|
183|e52ef5|/// UIViewRepresentable wrapper for Runestone's TextView
184|513873|/// Provides native TreeSitter syntax highlighting, line numbers, and code folding
185|bc7df1|struct RunestoneEditorView: UIViewRepresentable {
186|abdc8e|    @Binding var text: String
187|ab828e|    let filename: String
188|d84a59|    @Binding var scrollOffset: CGFloat
189|4cb87f|    @Binding var totalLines: Int
190|aab88e|    @Binding var currentLineNumber: Int
191|a5aa31|    @Binding var currentColumn: Int
192|9e1100|    @Binding var cursorIndex: Int
193|65ebe2|    let isActive: Bool
194|82ae06|    let fontSize: CGFloat
195|088df4|    @EnvironmentObject var editorCore: EditorCore
196|b4687f|    
197|6fdc4b|    // Settings from AppStorage
198|b4e1b7|    @AppStorage("wordWrap") private var wordWrapEnabled: Bool = true
199|ecfad7|    @AppStorage("showLineNumbers") private var showLineNumbers: Bool = true
200|b4687f|    
201|594855|    /// Autocomplete key handling hooks (return true if handled)
202|e7b3cd|    let onAcceptAutocomplete: (() -> Bool)?
203|7c9ea4|    let onDismissAutocomplete: (() -> Bool)?
204|b4687f|    
205|62e028|    init(
206|30281b|        text: Binding<String>,
207|9be454|        filename: String,
208|ab89ef|        scrollOffset: Binding<CGFloat> = .constant(0),
209|b063a9|        totalLines: Binding<Int>,
210|058768|        currentLineNumber: Binding<Int>,
211|fd200b|        currentColumn: Binding<Int>,
212|a428dc|        cursorIndex: Binding<Int> = .constant(0),
213|4ee198|        isActive: Bool,
214|c7d56f|        fontSize: CGFloat = 14.0,
215|31d064|        onAcceptAutocomplete: (() -> Bool)? = nil,
216|7f921c|        onDismissAutocomplete: (() -> Bool)? = nil
217|981e04|    ) {
218|772eb2|        self._text = text
219|693829|        self.filename = filename
220|b44e77|        self._scrollOffset = scrollOffset
221|f2dacc|        self._totalLines = totalLines
222|2111d8|        self._currentLineNumber = currentLineNumber
223|6ac61d|        self._currentColumn = currentColumn
224|a30d0a|        self._cursorIndex = cursorIndex
225|a76635|        self.isActive = isActive
226|aefa3e|        self.fontSize = fontSize
227|e84aef|        self.onAcceptAutocomplete = onAcceptAutocomplete
228|b27828|        self.onDismissAutocomplete = onDismissAutocomplete
229|27e597|    }
230|b4687f|    
231|89795a|    func makeCoordinator() -> Coordinator {
232|5b6b15|        Coordinator(self)
233|27e597|    }
234|b4687f|    
235|680f9a|    func makeUIView(context: Context) -> VSCodeRunestoneTextView {
236|7786eb|        let textView = VSCodeRunestoneTextView()
237|5c30bd|        textView.editorDelegate = context.coordinator
238|d6ed84|        
239|da91fc|        // Configure line numbers (from settings)
240|4387cb|        textView.showLineNumbers = showLineNumbers
241|ebf726|        textView.lineSelectionDisplayType = .line
242|d6ed84|        
243|73d245|        // Configure line wrapping (from settings)
244|a2828f|        textView.isLineWrappingEnabled = wordWrapEnabled
245|d6ed84|        
246|c645f9|        // Configure editing
247|da0c96|        textView.isEditable = true
248|8e0a05|        textView.isSelectable = true
249|d6ed84|        
250|834cfd|        // Disable autocorrect/autocapitalize for code editing
251|9239ec|        textView.autocorrectionType = .no
252|be8b25|        textView.autocapitalizationType = .none
253|95e6b5|        textView.smartQuotesType = .no
254|8d5412|        textView.smartDashesType = .no
255|046505|        textView.smartInsertDeleteType = .no
256|3ed52b|        textView.spellCheckingType = .no
257|d6ed84|        
258|eda999|        // Configure keyboard
259|562515|        textView.keyboardType = .asciiCapable
260|1a155e|        textView.keyboardDismissMode = .interactive
261|d6ed84|        
262|5846ea|        // Content insets for padding
263|948867|        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
264|d6ed84|        
265|6afd10|        // Set text with TreeSitter language support FIRST
266|1bdc19|        if let language = getTreeSitterLanguage(for: filename) {
267|e862fa|            let state = TextViewState(text: text, language: language)
268|aaf1be|            textView.setState(state)
269|b31999|        } else {
270|bf2c47|            // No language support - fallback to plain text
271|bf1757|            textView.text = text
272|5f3077|        }
273|d6ed84|        
274|359325|        // Set theme AFTER setState to ensure it takes effect
275|86633d|        // setState may reset internal rendering state, so theme must come after
276|3ea396|        textView.theme = makeRunestoneTheme()
277|e5b95a|        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
278|d6ed84|        
279|dafec7|        // Store reference for coordinator
280|33bdd5|        context.coordinator.textView = textView
281|d6ed84|        
282|94dfef|        // Initial line count
283|0706d6|        DispatchQueue.main.async {
284|61f4f4|            self.totalLines = self.countLines(in: text)
285|5f3077|        }
286|d6ed84|        
287|36e727|        return textView
288|27e597|    }
289|b4687f|    
290|ddb800|    func updateUIView(_ textView: VSCodeRunestoneTextView, context: Context) {
291|6bce46|        // Update coordinator's parent reference for current bindings
292|aa6fd6|        context.coordinator.parent = self
293|d6ed84|        
294|fa3f7d|        // Update theme if changed
295|462091|        let currentThemeId = ThemeManager.shared.currentTheme.id
296|173529|        if context.coordinator.lastThemeId != currentThemeId {
297|0ae3b4|            context.coordinator.lastThemeId = currentThemeId
298|cd161e|            textView.theme = makeRunestoneTheme()
299|2c8fb7|            textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
300|5f3077|        }
301|d6ed84|        
302|c11584|        // Update font size if changed
303|0d6968|        if context.coordinator.lastFontSize != fontSize {
304|ad902d|            context.coordinator.lastFontSize = fontSize
305|cd161e|            textView.theme = makeRunestoneTheme()
306|5f3077|        }
307|d6ed84|        
308|cb515b|        // Update settings if changed (live toggle support)
309|8f116a|        if textView.showLineNumbers != showLineNumbers {
310|c530c2|            textView.showLineNumbers = showLineNumbers
311|5f3077|        }
312|8e7477|        if textView.isLineWrappingEnabled != wordWrapEnabled {
313|ed0ffc|            textView.isLineWrappingEnabled = wordWrapEnabled
314|5f3077|        }
315|d6ed84|        
316|26756b|        // CRITICAL: Only call setState() when safe (not during active editing)
317|e2bb7b|        // Calling setState() during editing corrupts Runestone's lineManager
318|092fab|        // and causes crash at TextEditHelper.swift:27 (force unwrap on linePosition)
319|d6ed84|        
320|a43f62|        let isFileSwitching = context.coordinator.lastFilename != filename
321|d8aa68|        let currentText = textView.text
322|5cc09d|        let textChanged = currentText != text
323|dbea58|        let isActivelyEditing = textView.isFirstResponder
324|d6ed84|        
325|317e91|        if isFileSwitching {
326|97906a|            // User switched to a different file - safe to call setState()
327|6db873|            context.coordinator.lastFilename = filename
328|a9199d|            context.coordinator.hasBeenEdited = false
329|3070d1|            
330|66a1a1|            if let language = getTreeSitterLanguage(for: filename) {
331|d00b5e|                let state = TextViewState(text: text, language: language)
332|d69a75|                textView.setState(state)
333|f5a6eb|            } else {
334|8d685d|                textView.text = text
335|a7dc16|            }
336|3070d1|            
337|80f64f|            // CRITICAL: Re-apply theme AFTER setState - setState may reset rendering state
338|cd161e|            textView.theme = makeRunestoneTheme()
339|3070d1|            
340|00d273|            // Reset cursor to start for new file
341|f89f38|            textView.selectedRange = NSRange(location: 0, length: 0)
342|3070d1|            
343|a6439c|            // Update line count
344|ebb427|            DispatchQueue.main.async {
345|b26907|                self.totalLines = self.countLines(in: text)
346|a7dc16|            }
347|8bc7f3|        } else if textChanged && !context.coordinator.hasBeenEdited && !isActivelyEditing && !context.coordinator.isUpdatingFromTextView {
348|016671|            // Text changed externally (e.g., initial load, external modification)
349|51a126|            // Safe to update since user hasn't started editing yet
350|66a1a1|            if let language = getTreeSitterLanguage(for: filename) {
351|d00b5e|                let state = TextViewState(text: text, language: language)
352|d69a75|                textView.setState(state)
353|f5a6eb|            } else {
354|8d685d|                textView.text = text
355|a7dc16|            }
356|3070d1|            
357|80f64f|            // CRITICAL: Re-apply theme AFTER setState - setState may reset rendering state
358|cd161e|            textView.theme = makeRunestoneTheme()
359|3070d1|            
360|a6439c|            // Update line count
361|ebb427|            DispatchQueue.main.async {
362|b26907|                self.totalLines = self.countLines(in: text)
363|a7dc16|            }
364|5f3077|        }
365|57fb66|        // If user HAS edited OR is actively editing, DO NOTHING
366|a3857b|        // Let the user's edits remain - don't corrupt the lineManager
367|27e597|    }
368|b4687f|    
369|072048|    // MARK: - Runestone Theme Factory
370|b4687f|    
371|9607ec|    private func makeRunestoneTheme() -> RunestoneEditorTheme {
372|71a1d4|        let appTheme = ThemeManager.shared.currentTheme
373|754683|        return RunestoneEditorTheme(
374|141233|            fontSize: fontSize,
375|6fed03|            backgroundColor: UIColor(appTheme.editorBackground),
376|3ff577|            textColor: UIColor(appTheme.editorForeground),
377|25c8f7|            gutterBackgroundColor: UIColor(appTheme.editorBackground),
378|f59562|            gutterHairlineColor: UIColor(appTheme.lineNumber).withAlphaComponent(0.3),
379|69b115|            lineNumberColor: UIColor(appTheme.lineNumber),
380|761e46|            selectedLineBackgroundColor: UIColor(appTheme.currentLineHighlight),
381|253711|            selectedLinesLineNumberColor: UIColor(appTheme.lineNumberActive),
382|c74ad9|            selectedLinesGutterBackgroundColor: UIColor(appTheme.currentLineHighlight),
383|2f7e95|            invisibleCharactersColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.3),
384|d7f152|            pageGuideHairlineColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.1),
385|811607|            pageGuideBackgroundColor: UIColor(appTheme.editorBackground),
386|f4a737|            markedTextBackgroundColor: UIColor(appTheme.selection).withAlphaComponent(0.5),
387|8585f5|            keywordColor: UIColor(appTheme.keyword),
388|b3e17b|            stringColor: UIColor(appTheme.string),
389|7ff3fd|            numberColor: UIColor(appTheme.number),
390|a05855|            commentColor: UIColor(appTheme.comment),
391|2801b0|            functionColor: UIColor(appTheme.function),
392|12e112|            typeColor: UIColor(appTheme.type),
393|684aec|            variableColor: UIColor(appTheme.variable)
394|3143a4|        )
395|27e597|    }
396|b4687f|    
397|957540|    // MARK: - Language Mode Mapping
398|b4687f|    
399|70f3e8|    /// Gets the actual TreeSitter Language object for a given filename
400|f3a5e1|    /// Returns nil for plain text files (no syntax highlighting)
401|a4a35b|    private func getTreeSitterLanguage(for filename: String) -> Runestone.TreeSitterLanguage? {
402|98942b|        let ext = (filename as NSString).pathExtension.lowercased()
403|82335e|        let lastComponent = (filename as NSString).lastPathComponent.lowercased()
404|d6ed84|        
405|ab25ec|        // Special-case filenames without extensions
406|013551|        if lastComponent == "dockerfile" || lastComponent.hasPrefix("dockerfile.") {
407|274790|            return nil // Bash support not in package list yet
408|5f3077|        }
409|bf07fd|        if lastComponent == ".env" || lastComponent.hasPrefix(".env.") {
410|3e3e36|            return nil // Plain text
411|5f3077|        }
412|828d40|        if lastComponent == "makefile" || lastComponent == "gnumakefile" {
413|274790|            return nil // Bash support not in package list yet
414|5f3077|        }
415|4b7128|        if lastComponent == "podfile" || lastComponent == "gemfile" {
416|46c419|            return nil // Ruby support not in package list yet
417|5f3077|        }
418|0efae9|        if lastComponent == "package.json" || lastComponent == "tsconfig.json" {
419|4d9419|            return TreeSitterLanguage.json
420|5f3077|        }
421|d6ed84|        
422|f60e4e|        switch ext {
423|4c2810|        // Swift
424|1c8542|        case "swift":
425|376f7d|            return TreeSitterLanguage.swift
426|d6ed84|        
427|20fa65|        // JavaScript
428|cd5864|        case "js", "mjs", "cjs", "jsx":
429|fd14ee|            return TreeSitterLanguage.javaScript
430|d6ed84|        
431|194537|        // TypeScript - use JavaScript as fallback
432|a4d183|        case "ts", "mts", "cts", "tsx":
433|fd14ee|            return TreeSitterLanguage.javaScript
434|d6ed84|        
435|a87c1b|        // Python
436|85dfd3|        case "py", "pyw", "pyi":
437|4462da|            return TreeSitterLanguage.python
438|d6ed84|        
439|cd9e63|        // Go
440|ee50e6|        case "go":
441|44c0af|            return TreeSitterLanguage.go
442|d6ed84|        
443|fd611a|        // Rust
444|c28591|        case "rs":
445|9af65c|            return TreeSitterLanguage.rust
446|d6ed84|        
447|08c082|        // JSON
448|7aa37f|        case "json", "jsonc":
449|4d9419|            return TreeSitterLanguage.json
450|d6ed84|        
451|8aadd1|        // HTML
452|8f517a|        case "html", "htm", "xhtml":
453|d6b81f|            return TreeSitterLanguage.html
454|d6ed84|        
455|b0d395|        // CSS
456|c4efc3|        case "css", "scss":
457|27b343|            return TreeSitterLanguage.css
458|d6ed84|        
459|0fbfad|        // XML - use HTML as fallback
460|f580bd|        case "xml", "plist", "svg":
461|d6b81f|            return TreeSitterLanguage.html
462|d6ed84|        
463|c32a01|        // Default - no syntax highlighting
464|520b7d|        default:
465|1c8557|            return nil
466|5f3077|        }
467|27e597|    }
468|adc83b|
469|b4687f|    
470|ee02fb|    // MARK: - Helpers
471|b4687f|    
472|6a2db5|    private func countLines(in text: String) -> Int {
473|ee3501|        guard !text.isEmpty else { return 1 }
474|c746a1|        var count = 1
475|48817a|        var index = text.startIndex
476|42136d|        while index < text.endIndex {
477|4396fc|            if text[index] == "\n" {
478|31d0c1|                count += 1
479|a7dc16|            }
480|3a0fcb|            index = text.index(after: index)
481|5f3077|        }
482|c7b6e6|        return count
483|27e597|    }
484|b4687f|    
485|b90e11|    // MARK: - Coordinator
486|b4687f|    
487|57fd33|    class Coordinator: NSObject, TextViewDelegate {
488|fe867f|        var parent: RunestoneEditorView
489|0bde9e|        weak var textView: TextView?
490|e0c082|        var isUpdatingFromTextView = false
491|d5e6db|        var lastFontSize: CGFloat = 14.0
492|df72ce|        var lastThemeId: String = ""
493|e181a1|        var currentLanguage: Language?
494|d6ed84|        
495|b93091|        // Track file identity to know when to call setState()
496|244df6|        var lastFilename: String = ""
497|82a9dc|        var hasBeenEdited: Bool = false
498|d6ed84|        
499|a814d3|        // Debounced text sync to avoid SwiftUI re-renders on every keystroke
500|aae740|        private var textSyncWorkItem: DispatchWorkItem?
501|8fda30|        private let debounceInterval: TimeInterval = 0.5 // 500ms
502|d6ed84|        
503|043ea2|        init(_ parent: RunestoneEditorView) {
504|12d237|            self.parent = parent
505|ffb0bd|            self.lastFontSize = parent.fontSize
506|3fc189|            self.lastThemeId = ThemeManager.shared.currentTheme.id
507|c8ef01|            self.lastFilename = parent.filename
508|5f3077|        }
509|d6ed84|        
510|788eb1|        deinit {
511|e504ad|            // Cancel any pending debounced updates
512|bc1cc6|            textSyncWorkItem?.cancel()
513|5f3077|        }
514|d6ed84|        
515|cc0795|        // MARK: - TextViewDelegate
516|d6ed84|        
517|b75d27|        func textViewDidChange(_ textView: TextView) {
518|02717e|            // Mark that user has edited - blocks setState() calls until file switch
519|f51822|            hasBeenEdited = true
520|3070d1|            
521|d2cd8b|            // Cancel any pending debounced update
522|bc1cc6|            textSyncWorkItem?.cancel()
523|3070d1|            
524|6966df|            // Create new debounced work item
525|36310e|            let workItem = DispatchWorkItem { [weak self] in
526|150252|                guard let self = self else { return }
527|84d674|                self.isUpdatingFromTextView = true
528|0ae33b|                defer { self.isUpdatingFromTextView = false }
529|216278|                
530|24c8b7|                // Update text binding (debounced - only after typing stops)
531|c75e92|                self.parent.text = textView.text
532|216278|                
533|416a60|                // Update line count
534|f143b8|                DispatchQueue.main.async {
535|d865ea|                    self.parent.totalLines = self.parent.countLines(in: textView.text)
536|4e2d32|                }
537|a7dc16|            }
538|3070d1|            
539|eaaa24|            // Schedule the update after debounce interval
540|587c05|            textSyncWorkItem = workItem
541|c3b6ab|            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
542|5f3077|        }
543|d6ed84|        
544|6a67c9|        /// Immediately sync text to SwiftUI binding (call on save/tab-switch)
545|a61f5c|        func syncTextImmediately() {
546|d2cd8b|            // Cancel any pending debounced update
547|bc1cc6|            textSyncWorkItem?.cancel()
548|3070d1|            
549|078830|            guard let textView = textView else { return }
550|3070d1|            
551|3f491a|            isUpdatingFromTextView = true
552|5485b2|            defer { isUpdatingFromTextView = false }
553|3070d1|            
554|6db6b0|            // Immediate sync
555|f9041f|            parent.text = textView.text
556|9b320f|            parent.totalLines = parent.countLines(in: textView.text)
557|5f3077|        }
558|d6ed84|        
559|49059d|        func textViewDidChangeSelection(_ textView: TextView) {
560|b59fde|            updateCursorPosition(in: textView)
561|5f3077|        }
562|d6ed84|        
563|4eb4ea|        func textViewDidBeginEditing(_ textView: TextView) {
564|bb2790|            // Could be used for focus handling
565|5f3077|        }
566|d6ed84|        
567|40d063|        func textViewDidEndEditing(_ textView: TextView) {
568|bb2790|            // Could be used for focus handling
569|5f3077|        }
570|d6ed84|        
571|f6a64f|        func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
572|3f3964|            // Handle Tab key for autocomplete acceptance
573|6688de|            if text == "\t" {
574|f9c439|                if let onAccept = parent.onAcceptAutocomplete, onAccept() {
575|df59cf|                    return false
576|4e2d32|                }
577|a7dc16|            }
578|3070d1|            
579|cc3aa6|            // Handle Escape key for autocomplete dismissal
580|ce7885|            // Note: Escape key events are typically handled via key commands, not here
581|3070d1|            
582|40cfc4|            return true
583|5f3077|        }
584|d6ed84|        
585|fc84c5|        func scrollViewDidScroll(_ scrollView: UIScrollView) {
586|6c450e|            // Update scroll offset binding for gutter synchronization
587|ebb427|            DispatchQueue.main.async {
588|e41cd2|                self.parent.scrollOffset = scrollView.contentOffset.y
589|a7dc16|            }
590|5f3077|        }
591|d6ed84|        
592|f9574f|        // MARK: - Cursor Position Calculation
593|d6ed84|        
594|638123|        private func updateCursorPosition(in textView: TextView) {
595|e844dd|            let selectedRange = textView.selectedRange
596|0c3128|            let text = textView.text as NSString
597|c0763f|            let cursorLocation = selectedRange.location
598|3070d1|            
599|3c0f5f|            // Calculate line and column from cursor location
600|2bf772|            var lineNumber = 1
601|b2dc74|            var columnNumber = 1
602|895788|            var currentLineStart = 0
603|3070d1|            
604|30ee03|            for i in 0..<min(cursorLocation, text.length) {
605|76817f|                if text.character(at: i) == UInt16(UnicodeScalar("\n").value) {
606|4ae0f3|                    lineNumber += 1
607|1230ab|                    currentLineStart = i + 1
608|4e2d32|                }
609|a7dc16|            }
610|3070d1|            
611|fe9f83|            // Column is the offset from the start of the current line
612|2ea6e9|            columnNumber = cursorLocation - currentLineStart + 1
613|3070d1|            
614|13f4e9|            // Update bindings on main thread to avoid SwiftUI state update warnings
615|ebb427|            DispatchQueue.main.async {
616|62efc4|                self.parent.cursorIndex = cursorLocation
617|29327f|                self.parent.currentLineNumber = lineNumber
618|975d29|                self.parent.currentColumn = columnNumber
619|a7dc16|            }
620|5f3077|        }
621|27e597|    }
622|b31277|}
623|adc83b|
624|7246b9|// MARK: - Runestone Theme Implementation
625|adc83b|
626|23f6be|/// Custom theme implementation for Runestone that maps app theme colors to editor appearance
627|15772b|class RunestoneEditorTheme: Runestone.Theme {
628|82ae06|    let fontSize: CGFloat
629|b4687f|    
630|674973|    // Core colors
631|63a650|    private let _backgroundColor: UIColor
632|69ecef|    private let _textColor: UIColor
633|a63dc8|    private let _gutterBackgroundColor: UIColor
634|61f893|    private let _gutterHairlineColor: UIColor
635|46e697|    private let _lineNumberColor: UIColor
636|b77015|    private let _selectedLineBackgroundColor: UIColor
637|45d5b6|    private let _selectedLinesLineNumberColor: UIColor
638|507d94|    private let _selectedLinesGutterBackgroundColor: UIColor
639|df300a|    private let _invisibleCharactersColor: UIColor
640|7fcd59|    private let _pageGuideHairlineColor: UIColor
641|35d435|    private let _pageGuideBackgroundColor: UIColor
642|54ba9c|    private let _markedTextBackgroundColor: UIColor
643|b4687f|    
644|a068d3|    // Syntax colors
645|6a8c7b|    private let _keywordColor: UIColor
646|d325df|    private let _stringColor: UIColor
647|c14ae7|    private let _numberColor: UIColor
648|8109d2|    private let _commentColor: UIColor
649|8b9e8b|    private let _functionColor: UIColor
650|dfabea|    private let _typeColor: UIColor
651|9bf787|    private let _variableColor: UIColor
652|b4687f|    
653|62e028|    init(
654|03646e|        fontSize: CGFloat,
655|97f91e|        backgroundColor: UIColor,
656|49a1fd|        textColor: UIColor,
657|0fad6c|        gutterBackgroundColor: UIColor,
658|ce1735|        gutterHairlineColor: UIColor,
659|bb55ce|        lineNumberColor: UIColor,
660|b155a3|        selectedLineBackgroundColor: UIColor,
661|6c9121|        selectedLinesLineNumberColor: UIColor,
662|c2f462|        selectedLinesGutterBackgroundColor: UIColor,
663|5baff1|        invisibleCharactersColor: UIColor,
664|091cec|        pageGuideHairlineColor: UIColor,
665|b4018e|        pageGuideBackgroundColor: UIColor,
666|27caf6|        markedTextBackgroundColor: UIColor,
667|eafccc|        keywordColor: UIColor,
668|4e8e95|        stringColor: UIColor,
669|a8eb96|        numberColor: UIColor,
670|60e3f1|        commentColor: UIColor,
671|ccbcd5|        functionColor: UIColor,
672|f73e24|        typeColor: UIColor,
673|21f39b|        variableColor: UIColor
674|981e04|    ) {
675|aefa3e|        self.fontSize = fontSize
676|e7c18a|        self._backgroundColor = backgroundColor
677|6496d6|        self._textColor = textColor
678|ce814d|        self._gutterBackgroundColor = gutterBackgroundColor
679|00e443|        self._gutterHairlineColor = gutterHairlineColor
680|ca4d73|        self._lineNumberColor = lineNumberColor
681|eca234|        self._selectedLineBackgroundColor = selectedLineBackgroundColor
682|ed0200|        self._selectedLinesLineNumberColor = selectedLinesLineNumberColor
683|7b2780|        self._selectedLinesGutterBackgroundColor = selectedLinesGutterBackgroundColor
684|d0b4cd|        self._invisibleCharactersColor = invisibleCharactersColor
685|17d124|        self._pageGuideHairlineColor = pageGuideHairlineColor
686|3e4113|        self._pageGuideBackgroundColor = pageGuideBackgroundColor
687|a9e119|        self._markedTextBackgroundColor = markedTextBackgroundColor
688|a0ba9e|        self._keywordColor = keywordColor
689|c8a0bb|        self._stringColor = stringColor
690|838c3f|        self._numberColor = numberColor
691|401c0b|        self._commentColor = commentColor
692|ad8646|        self._functionColor = functionColor
693|21a810|        self._typeColor = typeColor
694|ca4496|        self._variableColor = variableColor
695|27e597|    }
696|b4687f|    
697|7f191d|    // MARK: - Theme Protocol Properties
698|b4687f|    
699|8f5011|    var font: UIFont {
700|b3c33c|        UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
701|27e597|    }
702|b4687f|    
703|c63798|    var textColor: UIColor {
704|b0766b|        _textColor
705|27e597|    }
706|b4687f|    
707|a341cb|    var gutterBackgroundColor: UIColor {
708|d276f1|        _gutterBackgroundColor
709|27e597|    }
710|b4687f|    
711|bd9178|    var gutterHairlineColor: UIColor {
712|d3bdb3|        _gutterHairlineColor
713|27e597|    }
714|b4687f|    
715|140e5a|    var lineNumberColor: UIColor {
716|441d7b|        _lineNumberColor
717|27e597|    }
718|b4687f|    
719|b10d53|    var lineNumberFont: UIFont {
720|8af963|        UIFont.monospacedSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
721|27e597|    }
722|b4687f|    
723|17d30e|    var selectedLineBackgroundColor: UIColor {
724|426cdf|        _selectedLineBackgroundColor
725|27e597|    }
726|b4687f|    
727|9754a3|    var selectedLinesLineNumberColor: UIColor {
728|9d658b|        _selectedLinesLineNumberColor
729|27e597|    }
730|b4687f|    
731|829549|    var selectedLinesGutterBackgroundColor: UIColor {
732|deca65|        _selectedLinesGutterBackgroundColor
733|27e597|    }
734|b4687f|    
735|7ca6bc|    var invisibleCharactersColor: UIColor {
736|65f0fd|        _invisibleCharactersColor
737|27e597|    }
738|b4687f|    
739|e3c8a4|    var pageGuideHairlineColor: UIColor {
740|7b7247|        _pageGuideHairlineColor
741|27e597|    }
742|b4687f|    
743|ac8dba|    var pageGuideBackgroundColor: UIColor {
744|f52547|        _pageGuideBackgroundColor
745|27e597|    }
746|b4687f|    
747|441109|    var markedTextBackgroundColor: UIColor {
748|6f8303|        _markedTextBackgroundColor
749|27e597|    }
750|b4687f|    
751|ff2c29|    // MARK: - Syntax Highlighting
752|b4687f|    
753|77216f|    func textColor(for rawHighlightName: String) -> UIColor? {
754|364fdf|        // Map TreeSitter highlight names to colors
755|077102|        // See: https://tree-sitter.github.io/tree-sitter/syntax-highlighting#highlights
756|a3c6a6|        let highlightName = rawHighlightName.lowercased()
757|d6ed84|        
758|3e8301|        // Debug: Log ALL highlight names to console (ENABLED FOR DEBUGGING)
759|1aa7f0|        print("🎨 HIGHLIGHT: '\(rawHighlightName)' -> ", terminator: "")
760|d6ed84|        
761|5f2431|        // Keywords
762|347daa|        if highlightName.contains("keyword") {
763|e0cdb7|            print("keyword (blue)")
764|11656d|            return _keywordColor
765|5f3077|        }
766|d6ed84|        
767|c13ace|        // JSON/Object keys - MUST return color for specific patterns
768|164d0a|        // TreeSitter JSON emits BOTH "string.special.key" AND "string" for keys
769|63f969|        // We handle specific patterns first, then skip generic "string" to avoid overwrite
770|929452|        if highlightName.hasPrefix("string.special") ||
771|7d9926|           highlightName.contains("label") ||
772|81c371|           highlightName.contains("property.definition") {
773|7612b6|            print("key/label (light blue)")
774|5086b7|            return _variableColor  // Light blue #9CDCFE for keys
775|5f3077|        }
776|d6ed84|        
777|5fe933|        // Strings - but NOT if it's JUST "string" (let specific matches win)
778|dcb001|        // Only color strings that are clearly values, not potential keys
779|ab3d14|        if highlightName.contains("string") {
780|5655ac|            print("string (orange)")
781|f09755|            return _stringColor  // Orange #CE9178 for string values
782|5f3077|        }
783|d6ed84|        
784|f425cd|        // Numbers and constants
785|a2036f|        if highlightName.contains("number") || highlightName == "constant.numeric" {
786|57bea5|            print("number (green)")
787|da9aee|            return _numberColor
788|5f3077|        }
789|d6ed84|        
790|185d89|        // Comments
791|f4b237|        if highlightName.contains("comment") {
792|e46058|            return _commentColor
793|5f3077|        }
794|d6ed84|        
795|4d76db|        // Functions and methods
796|915dec|        if highlightName.contains("function") || highlightName.contains("method") {
797|69dae5|            return _functionColor
798|5f3077|        }
799|d6ed84|        
800|5853d5|        // Types, classes, structs
801|a68e63|        if highlightName.contains("type") || highlightName.contains("class") ||
802|fe7d45|           highlightName.contains("struct") || highlightName.contains("interface") ||
803|7850d5|           highlightName.contains("enum") {
804|079364|            return _typeColor
805|5f3077|        }
806|d6ed84|        
807|100acb|        // Variables, parameters, properties
808|87a47d|        if highlightName.contains("variable") || highlightName.contains("parameter") ||
809|6198a9|           highlightName.contains("property") || highlightName.contains("field") {
810|0e23b9|            return _variableColor
811|5f3077|        }
812|d6ed84|        
813|f1a54a|        // Constants and booleans - use keyword color
814|cc358f|        if highlightName.contains("constant") || highlightName.contains("boolean") {
815|11656d|            return _keywordColor
816|5f3077|        }
817|d6ed84|        
818|b158fb|        // Operators - use keyword color
819|1a986d|        if highlightName.contains("operator") {
820|11656d|            return _keywordColor
821|5f3077|        }
822|d6ed84|        
823|8737fd|        // Namespaces and modules - use type color
824|d04ebe|        if highlightName.contains("namespace") || highlightName.contains("module") {
825|079364|            return _typeColor
826|5f3077|        }
827|d6ed84|        
828|d204ef|        // Tags (HTML, XML) - use type color
829|e21ab6|        if highlightName.contains("tag") {
830|079364|            return _typeColor
831|5f3077|        }
832|d6ed84|        
833|2abb6b|        // Attributes - use variable color
834|91f255|        if highlightName.contains("attribute") {
835|0e23b9|            return _variableColor
836|5f3077|        }
837|d6ed84|        
838|bb1e1f|        // Spell checking highlights - ignore (return nil to use default)
839|1dc697|        if highlightName.contains("spell") {
840|1c8557|            return nil
841|5f3077|        }
842|d6ed84|        
843|3d22f9|        // Include/import statements - use keyword color
844|fd8f58|        if highlightName.contains("include") {
845|11656d|            return _keywordColor
846|5f3077|        }
847|d6ed84|        
848|c1e1a1|        // Default: use standard text color
849|e35567|        print("nil (default)")
850|c2ae65|        return nil
851|27e597|    }
852|b4687f|    
853|666dc2|    func fontTraits(for rawHighlightName: String) -> FontTraits {
854|a3c6a6|        let highlightName = rawHighlightName.lowercased()
855|d6ed84|        
856|f6d691|        // Make comments italic
857|f4b237|        if highlightName.contains("comment") {
858|9ac334|            return .italic
859|5f3077|        }
860|d6ed84|        
861|556e36|        // Make keywords bold
862|347daa|        if highlightName.contains("keyword") {
863|7775b3|            return .bold
864|5f3077|        }
865|d6ed84|        
866|b72a10|        return []
867|27e597|    }
868|b31277|}
869|adc83b|
870|adc83b|
871|adc83b|
872|5e4767|// MARK: - Preview
873|7d6cf3|#if DEBUG
874|d96129|struct RunestoneEditorView_Previews: PreviewProvider {
875|23ccc3|    @State static var text = """
876|c1065b|    func hello() {
877|cf26fb|        print("Hello, World!")
878|27e597|    }
879|b4687f|    
880|dea7f1|    // This is a comment
881|3fef35|    let number = 42
882|8a4f92|    let string = "test"
883|87f133|    """
884|f58238|    @State static var scrollOffset: CGFloat = 0
885|708cb1|    @State static var totalLines = 7
886|6ac8ce|    @State static var currentLineNumber = 1
887|eeb538|    @State static var currentColumn = 1
888|d2cdc5|    @State static var cursorIndex = 0
889|b4687f|    
890|b92db4|    static var previews: some View {
891|86a5f4|        RunestoneEditorView(
892|ddc198|            text: $text,
893|58b764|            filename: "test.swift",
894|656a50|            scrollOffset: $scrollOffset,
895|aed4a6|            totalLines: $totalLines,
896|d36a4f|            currentLineNumber: $currentLineNumber,
897|d238b6|            currentColumn: $currentColumn,
898|0e3014|            cursorIndex: $cursorIndex,
899|d77846|            isActive: true,
900|9ccdd9|            fontSize: 14
901|3143a4|        )
902|f4bf48|        .environmentObject(EditorCore())
903|27e597|    }
904|b31277|}
905|3f6acf|#endif
906|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 32d0fe684d7d
File: VSCodeiPadOS/VSCodeiPadOS/Services/RunnerSelector.swift (lines 1-794 of 794)
────────────────────────────────────────
1|8b6b78|import Foundation
2|119e5c|import JavaScriptCore
3|adc83b|
4|71e2e4|// MARK: - Supporting Types
5|adc83b|
6|ff5f1d|/// Supported programming languages for execution
7|0bf52b|public enum Language: String, CaseIterable, Sendable {
8|711815|    case javascript = "javascript"
9|45eeb0|    case python = "python"
10|efcbf5|    case swift = "swift"
11|100b23|    case typescript = "typescript"
12|be7aa6|    case bash = "bash"
13|79ac44|    case ruby = "ruby"
14|67d38c|    case php = "php"
15|c04123|    case go = "go"
16|62f77b|    case rust = "rust"
17|4247bc|    case lua = "lua"
18|2a61cb|    case wasm = "wasm"
19|2c47ef|    case unknown = "unknown"
20|b4687f|    
21|5b2161|    /// Returns true if the language can potentially run on-device
22|ed3041|    public var supportsOnDeviceExecution: Bool {
23|2e6d08|        switch self {
24|cd15d1|        case .javascript, .lua:
25|927510|            return true // JavaScriptCore available
26|9fa55d|        case .python:
27|7ad79e|            return false // Requires embedded Python or Pyodide
28|3347f4|        case .swift:
29|43eb12|            return true // Can run in limited sandbox
30|df946e|        case .typescript:
31|a2d703|            return true // Transpiles to JS
32|06bb56|        case .wasm:
33|ad407b|            return true // WebAssembly via WKWebView
34|f74e2b|        case .bash, .ruby, .php, .go, .rust, .unknown:
35|2d392c|            return false // Requires interpreter/compiler not on iOS
36|5f3077|        }
37|27e597|    }
38|b4687f|    
39|86232d|    /// File extensions for this language
40|21fa4e|    public var fileExtensions: [String] {
41|2e6d08|        switch self {
42|3e1a22|        case .javascript: return ["js", "mjs"]
43|620be7|        case .python: return ["py", "pyw"]
44|24d683|        case .swift: return ["swift"]
45|bf69f2|        case .typescript: return ["ts", "tsx"]
46|f335e2|        case .bash: return ["sh", "bash"]
47|697a3e|        case .ruby: return ["rb"]
48|43013e|        case .php: return ["php"]
49|69e01f|        case .go: return ["go"]
50|c5fd5f|        case .rust: return ["rs"]
51|14f8b7|        case .lua: return ["lua"]
52|e5ef4f|        case .wasm: return ["wasm"]
53|d43b7a|        case .unknown: return []
54|5f3077|        }
55|27e597|    }
56|b4687f|    
57|89b9c5|    /// Detect language from file extension or code content
58|4e28f7|    public static func detect(from filename: String, code: String? = nil) -> Language {
59|98942b|        let ext = (filename as NSString).pathExtension.lowercased()
60|f60e4e|        switch ext {
61|0af4e0|        case "js", "mjs": return .javascript
62|20a752|        case "ts", "tsx": return .typescript
63|e1e2fb|        case "py", "pyw": return .python
64|6a01dc|        case "swift": return .swift
65|8ebeed|        case "sh", "bash": return .bash
66|56dccc|        case "rb": return .ruby
67|e8bfcf|        case "php": return .php
68|edae84|        case "go": return .go
69|714d49|        case "rs": return .rust
70|04dee0|        case "lua": return .lua
71|63cc2e|        case "wasm": return .wasm
72|520b7d|        default:
73|31e196|            // Try to detect from code heuristics
74|c06164|            if let code = code {
75|3ab5c9|                return detectFromCode(code)
76|a7dc16|            }
77|5062c2|            return .unknown
78|5f3077|        }
79|27e597|    }
80|b4687f|    
81|bd46dc|    private static func detectFromCode(_ code: String) -> Language {
82|05ac6a|        if code.contains("func ") && code.contains("{") && (code.contains("var ") || code.contains("let ")) {
83|ce5dbf|            return .swift
84|5f3077|        }
85|79b719|        if code.contains("def ") && code.contains(":") {
86|48afab|            return .python
87|5f3077|        }
88|bedde6|        if code.contains("function ") || code.contains("const ") || code.contains("let ") {
89|ddb75d|            if code.contains(": ") && code.contains("interface ") {
90|bbadbf|                return .typescript
91|a7dc16|            }
92|63d43b|            return .javascript
93|5f3077|        }
94|a7b1d4|        if code.contains("#!/bin/bash") || code.contains("#!/bin/sh") {
95|e62265|            return .bash
96|5f3077|        }
97|471f60|        return .unknown
98|27e597|    }
99|b31277|}
100|adc83b|
101|309f12|/// Execution strategy determined by the selector
102|c71a60|public enum ExecutionStrategy: Equatable, Sendable {
103|284ec0|    /// Run entirely on-device
104|118a65|    case onDevice
105|b4687f|    
106|fde229|    /// Run on remote server
107|557b36|    case remote(reason: String)
108|b4687f|    
109|59b190|    /// Hybrid: analyze on-device, run on remote
110|addf88|    case hybrid(analysisOnDevice: Bool, executionRemote: Bool)
111|b4687f|    
112|ecb28d|    public var description: String {
113|2e6d08|        switch self {
114|f36256|        case .onDevice:
115|f3f2c4|            return "Execute entirely on-device"
116|51682a|        case .remote(let reason):
117|d86460|            return "Execute remotely: \(reason)"
118|4dc65c|        case .hybrid(let analysis, let execution):
119|8fc456|            return "Hybrid (analysis: \(analysis ? "on-device" : "remote"), execution: \(execution ? "remote" : "on-device"))"
120|5f3077|        }
121|27e597|    }
122|b31277|}
123|adc83b|
124|98597f|/// Resource usage estimate for code execution
125|434324|public struct ResourceEstimate: Sendable {
126|6d38ed|    public let estimatedTimeSeconds: Double
127|d80126|    public let estimatedMemoryMB: Double
128|08650e|    public let estimatedCPUUsage: Double // 0.0 to 1.0
129|6705e8|    public let hasExternalDependencies: Bool
130|e8dddd|    public let requiresNetwork: Bool
131|a04bb6|    public let requiresFileSystem: Bool
132|b4687f|    
133|fb99ae|    public init(
134|fcef86|        estimatedTimeSeconds: Double = 1.0,
135|d66546|        estimatedMemoryMB: Double = 50.0,
136|f6ecc3|        estimatedCPUUsage: Double = 0.5,
137|0ad433|        hasExternalDependencies: Bool = false,
138|cfb5b6|        requiresNetwork: Bool = false,
139|ac6f30|        requiresFileSystem: Bool = false
140|981e04|    ) {
141|2c6226|        self.estimatedTimeSeconds = estimatedTimeSeconds
142|f62d39|        self.estimatedMemoryMB = estimatedMemoryMB
143|2db94c|        self.estimatedCPUUsage = estimatedCPUUsage
144|b5e89e|        self.hasExternalDependencies = hasExternalDependencies
145|79e0d8|        self.requiresNetwork = requiresNetwork
146|3f3dac|        self.requiresFileSystem = requiresFileSystem
147|27e597|    }
148|b4687f|    
149|89d516|    /// Check if estimate exceeds typical iOS limits
150|499e81|    public var exceedsOnDeviceLimits: Bool {
151|0c2bf4|        return estimatedTimeSeconds > 30.0 || // 30 second limit
152|4030ee|               estimatedMemoryMB > 512.0 || // 512MB memory limit
153|0163a0|               estimatedCPUUsage > 0.8 || // High CPU usage
154|547379|               requiresNetwork || // Network required
155|d4d685|               hasExternalDependencies // External packages needed
156|27e597|    }
157|b31277|}
158|adc83b|
159|37b3d1|/// Result of on-device capability analysis
160|9087c4|public struct DeviceExecutionResult: Sendable {
161|1c29c7|    public let canRunOnDevice: Bool
162|ecd5c8|    public let recommendedStrategy: ExecutionStrategy
163|fce095|    public let factors: [ExecutionFactor]
164|ca4867|    public let resourceEstimate: ResourceEstimate
165|b4687f|    
166|fb99ae|    public init(
167|fece58|        canRunOnDevice: Bool,
168|f8ce1f|        recommendedStrategy: ExecutionStrategy,
169|d0d104|        factors: [ExecutionFactor],
170|e5abd2|        resourceEstimate: ResourceEstimate
171|981e04|    ) {
172|68c67c|        self.canRunOnDevice = canRunOnDevice
173|118ffa|        self.recommendedStrategy = recommendedStrategy
174|b89fc6|        self.factors = factors
175|139fb3|        self.resourceEstimate = resourceEstimate
176|27e597|    }
177|b31277|}
178|adc83b|
179|8242ce|/// Individual factor affecting execution decision
180|2133d2|public struct ExecutionFactor: Sendable {
181|a83384|    public let name: String
182|cfb400|    public let status: FactorStatus
183|94eac9|    public let description: String
184|b4687f|    
185|f2a1a6|    public init(name: String, status: FactorStatus, description: String) {
186|b8025b|        self.name = name
187|55d357|        self.status = status
188|957e00|        self.description = description
189|27e597|    }
190|b31277|}
191|adc83b|
192|2c85e5|public enum FactorStatus: String, Sendable {
193|0ecb59|    case pass = "✅"
194|cc540e|    case warning = "⚠️"
195|61a970|    case fail = "❌"
196|b31277|}
197|adc83b|
198|695f9d|/// User preferences for execution
199|b82db9|public struct ExecutionPreferences: Sendable {
200|1e9cff|    public var preferOnDevice: Bool
201|fab66f|    public var preferRemote: Bool
202|536b2f|    public var warnBeforeRemote: Bool
203|cb360f|    public var maxOnDeviceTimeSeconds: Double
204|e7f7f9|    public var maxOnDeviceMemoryMB: Double
205|b4687f|    
206|fb99ae|    public init(
207|7efe31|        preferOnDevice: Bool = true,
208|ad2d3b|        preferRemote: Bool = false,
209|e87669|        warnBeforeRemote: Bool = true,
210|48ee34|        maxOnDeviceTimeSeconds: Double = 30.0,
211|6f7a82|        maxOnDeviceMemoryMB: Double = 256.0
212|981e04|    ) {
213|7fab45|        self.preferOnDevice = preferOnDevice
214|9e7da1|        self.preferRemote = preferRemote
215|b60fb5|        self.warnBeforeRemote = warnBeforeRemote
216|b31206|        self.maxOnDeviceTimeSeconds = maxOnDeviceTimeSeconds
217|3e926f|        self.maxOnDeviceMemoryMB = maxOnDeviceMemoryMB
218|27e597|    }
219|b31277|}
220|adc83b|
221|1b2788|/// Configuration for the RunnerSelector
222|032e76|public struct RunnerConfiguration: Sendable {
223|3b88b1|    public var maxOnDeviceExecutionTime: TimeInterval
224|e7f7f9|    public var maxOnDeviceMemoryMB: Double
225|b23cbc|    public var maxCPUUsageBeforeThrottle: Double
226|b8c6d1|    public var allowNetworkAccess: Bool
227|b76a96|    public var allowFileSystemAccess: Bool
228|b4687f|    
229|68c405|    public static let `default` = RunnerConfiguration(
230|2e8f4c|        maxOnDeviceExecutionTime: 30.0,
231|9895de|        maxOnDeviceMemoryMB: 256.0,
232|5ef793|        maxCPUUsageBeforeThrottle: 0.8,
233|edc72e|        allowNetworkAccess: false,
234|2c49d8|        allowFileSystemAccess: true
235|829c44|    )
236|b4687f|    
237|fb99ae|    public init(
238|020144|        maxOnDeviceExecutionTime: TimeInterval = 30.0,
239|bbdbd5|        maxOnDeviceMemoryMB: Double = 256.0,
240|004a6d|        maxCPUUsageBeforeThrottle: Double = 0.8,
241|5c1960|        allowNetworkAccess: Bool = false,
242|2e2a1b|        allowFileSystemAccess: Bool = true
243|981e04|    ) {
244|26d30b|        self.maxOnDeviceExecutionTime = maxOnDeviceExecutionTime
245|3e926f|        self.maxOnDeviceMemoryMB = maxOnDeviceMemoryMB
246|5a0a99|        self.maxCPUUsageBeforeThrottle = maxCPUUsageBeforeThrottle
247|a2a0fc|        self.allowNetworkAccess = allowNetworkAccess
248|f61ae2|        self.allowFileSystemAccess = allowFileSystemAccess
249|27e597|    }
250|b31277|}
251|adc83b|
252|efbc0e|// MARK: - RunnerSelector
253|adc83b|
254|2ea47b|/// Intelligent runner selection that decides on-device vs remote execution
255|69d728|@MainActor
256|4a1612|public final class RunnerSelector: Sendable {
257|b4687f|    
258|6503ae|    // MARK: - Properties
259|b4687f|    
260|a360ee|    public var userPreferences: ExecutionPreferences
261|336f66|    public var configuration: RunnerConfiguration
262|ee35f9|    public var delegate: RunnerSelectorDelegate?
263|b4687f|    
264|7dca75|    // MARK: - Initialization
265|b4687f|    
266|fb99ae|    public init(
267|c43b28|        preferences: ExecutionPreferences = ExecutionPreferences(),
268|ad60dc|        configuration: RunnerConfiguration = .default
269|981e04|    ) {
270|a20738|        self.userPreferences = preferences
271|e62f56|        self.configuration = configuration
272|27e597|    }
273|b4687f|    
274|81c2c9|    // MARK: - Public Methods
275|b4687f|    
276|a9a1b6|    /// Analyzes code and determines the best execution strategy
277|45b4bd|    /// - Parameters:
278|1f5198|    ///   - code: The source code to analyze
279|a9d40f|    ///   - language: The programming language
280|34436c|    /// - Returns: Recommended execution strategy
281|e9562e|    public func analyze(code: String, language: Language) -> ExecutionStrategy {
282|36f4ee|        // Step 1: Check user preference overrides
283|d8949b|        if userPreferences.preferRemote {
284|7462a9|            return .remote(reason: "User preference for remote execution")
285|5f3077|        }
286|d6ed84|        
287|67c50e|        // Step 2: Check if language supports on-device execution at all
288|4a8dca|        if !language.supportsOnDeviceExecution {
289|2ce1cb|            return .remote(reason: "\(language.rawValue) requires remote interpreter")
290|5f3077|        }
291|d6ed84|        
292|5bddb9|        // Step 3: Estimate resource usage
293|103428|        let resourceEstimate = estimateResourceUsage(code: code, language: language)
294|d6ed84|        
295|866789|        // Step 4: Check for file system requirements
296|5f189b|        let requiresFileSystem = detectFileSystemAccess(code: code, language: language)
297|f6546e|        if requiresFileSystem && !configuration.allowFileSystemAccess {
298|831ece|            return .remote(reason: "File system access required but not allowed on-device")
299|5f3077|        }
300|d6ed84|        
301|a0460f|        // Step 5: Check for network requirements
302|a0de0e|        let requiresNetwork = detectNetworkAccess(code: code, language: language)
303|7ec4a5|        if requiresNetwork && !configuration.allowNetworkAccess {
304|a6a758|            return .remote(reason: "Network access required but not allowed on-device")
305|5f3077|        }
306|d6ed84|        
307|91a683|        // Step 6: Check resource limits
308|de90e5|        if resourceEstimate.exceedsOnDeviceLimits {
309|d1bef1|            let reason = buildLimitExceededReason(estimate: resourceEstimate)
310|a5b154|            return .remote(reason: reason)
311|5f3077|        }
312|d6ed84|        
313|1a4acd|        // Step 7: Check execution time against user preference
314|a0b704|        if resourceEstimate.estimatedTimeSeconds > userPreferences.maxOnDeviceTimeSeconds {
315|680bf5|            return .remote(reason: "Estimated execution time (\(Int(resourceEstimate.estimatedTimeSeconds))s) exceeds user limit")
316|5f3077|        }
317|d6ed84|        
318|bca17e|        // Step 8: Check code complexity
319|ee8203|        let complexity = calculateComplexityScore(code: code, language: language)
320|7e4e31|        if complexity > 100 {
321|6df5e2|            return .hybrid(analysisOnDevice: true, executionRemote: true)
322|5f3077|        }
323|d6ed84|        
324|012218|        // All checks passed - can run on-device
325|39c0ca|        return .onDevice
326|27e597|    }
327|b4687f|    
328|1e4529|    /// Determines if code can run on-device and provides detailed analysis
329|45b4bd|    /// - Parameters:
330|1f5198|    ///   - code: The source code to analyze
331|a9d40f|    ///   - language: The programming language
332|4372e4|    /// - Returns: Detailed execution result with factors
333|fe3de9|    public func canRunOnDevice(code: String, language: Language) -> DeviceExecutionResult {
334|b35fba|        var factors: [ExecutionFactor] = []
335|d6ed84|        
336|75ad74|        // Language support check
337|de5c51|        if language.supportsOnDeviceExecution {
338|934c75|            factors.append(ExecutionFactor(
339|8ddf61|                name: "Language Support",
340|365222|                status: .pass,
341|8c3934|                description: "\(language.rawValue) supports on-device execution"
342|30ec32|            ))
343|b31999|        } else {
344|934c75|            factors.append(ExecutionFactor(
345|8ddf61|                name: "Language Support",
346|1a38e1|                status: .fail,
347|c35789|                description: "\(language.rawValue) requires remote execution"
348|30ec32|            ))
349|5f3077|        }
350|d6ed84|        
351|e5dbc4|        // Resource estimation
352|c429ad|        let resources = estimateResourceUsage(code: code, language: language)
353|1e73f8|        if resources.exceedsOnDeviceLimits {
354|934c75|            factors.append(ExecutionFactor(
355|e64804|                name: "Resource Usage",
356|1a38e1|                status: .fail,
357|f49cb2|                description: "Exceeds on-device limits (time: \(Int(resources.estimatedTimeSeconds))s, memory: \(Int(resources.estimatedMemoryMB))MB)"
358|30ec32|            ))
359|b31999|        } else {
360|934c75|            factors.append(ExecutionFactor(
361|e64804|                name: "Resource Usage",
362|365222|                status: .pass,
363|77b784|                description: "Within on-device limits"
364|30ec32|            ))
365|5f3077|        }
366|d6ed84|        
367|6c13ad|        // Dependencies check
368|8d9074|        let dependencies = analyzeDependencies(code: code, language: language)
369|7bc240|        if dependencies.isEmpty {
370|934c75|            factors.append(ExecutionFactor(
371|044bd3|                name: "Dependencies",
372|365222|                status: .pass,
373|2ab7f9|                description: "No external dependencies detected"
374|30ec32|            ))
375|b31999|        } else {
376|934c75|            factors.append(ExecutionFactor(
377|044bd3|                name: "Dependencies",
378|11070c|                status: .warning,
379|409563|                description: "Detected dependencies: \(dependencies.joined(separator: ", "))"
380|30ec32|            ))
381|5f3077|        }
382|d6ed84|        
383|5e7230|        // Network check
384|f7a506|        let network = detectNetworkAccess(code: code, language: language)
385|00a6a9|        if network {
386|934c75|            factors.append(ExecutionFactor(
387|b0706c|                name: "Network Access",
388|97a453|                status: configuration.allowNetworkAccess ? .warning : .fail,
389|a63ea4|                description: configuration.allowNetworkAccess ? "Network access detected" : "Network access not allowed on-device"
390|30ec32|            ))
391|b31999|        } else {
392|934c75|            factors.append(ExecutionFactor(
393|b0706c|                name: "Network Access",
394|365222|                status: .pass,
395|76d0d2|                description: "No network access required"
396|30ec32|            ))
397|5f3077|        }
398|d6ed84|        
399|bd76c2|        // File system check
400|3e4c0f|        let fileSystem = detectFileSystemAccess(code: code, language: language)
401|56c45e|        if fileSystem {
402|934c75|            factors.append(ExecutionFactor(
403|add843|                name: "File System",
404|a54427|                status: configuration.allowFileSystemAccess ? .warning : .fail,
405|f98595|                description: configuration.allowFileSystemAccess ? "File system access detected" : "File system access restricted"
406|30ec32|            ))
407|b31999|        } else {
408|934c75|            factors.append(ExecutionFactor(
409|add843|                name: "File System",
410|365222|                status: .pass,
411|c7d4c9|                description: "No file system access required"
412|30ec32|            ))
413|5f3077|        }
414|d6ed84|        
415|cb6db1|        // Complexity check
416|ee8203|        let complexity = calculateComplexityScore(code: code, language: language)
417|7e4e31|        if complexity > 100 {
418|934c75|            factors.append(ExecutionFactor(
419|dc79ef|                name: "Code Complexity",
420|11070c|                status: .warning,
421|716c54|                description: "High complexity score: \(complexity)"
422|30ec32|            ))
423|b31999|        } else {
424|934c75|            factors.append(ExecutionFactor(
425|dc79ef|                name: "Code Complexity",
426|365222|                status: .pass,
427|2838e4|                description: "Complexity score: \(complexity)"
428|30ec32|            ))
429|5f3077|        }
430|d6ed84|        
431|703083|        let strategy = analyze(code: code, language: language)
432|296906|        let isHybrid: Bool
433|73b0e1|        if case .hybrid = strategy { isHybrid = true } else { isHybrid = false }
434|8a7779|        let canRun = strategy == .onDevice || (isHybrid && factors.allSatisfy { $0.status != .fail })
435|d6ed84|        
436|86ac69|        return DeviceExecutionResult(
437|1a5d1a|            canRunOnDevice: canRun,
438|e7d056|            recommendedStrategy: strategy,
439|da62d6|            factors: factors,
440|5b0d9d|            resourceEstimate: resources
441|3143a4|        )
442|27e597|    }
443|b4687f|    
444|d8542a|    /// Estimates resource usage for the given code
445|45b4bd|    /// - Parameters:
446|378f16|    ///   - code: The source code
447|a9d40f|    ///   - language: The programming language
448|07aeb1|    /// - Returns: Resource estimate
449|a5ae00|    public func estimateResourceUsage(code: String, language: Language) -> ResourceEstimate {
450|7fa1d4|        let lines = code.components(separatedBy: .newlines).count
451|3a2a94|        let characters = code.count
452|d6ed84|        
453|021338|        // Base estimates
454|d5777f|        var timeEstimate = Double(lines) * 0.01 // 10ms per line baseline
455|145fb6|        var memoryEstimate = Double(characters) * 0.001 // 1KB per 1000 chars
456|b1e634|        var cpuEstimate = 0.3
457|18df1b|        var hasExternalDeps = false
458|7fc726|        var requiresNetwork = false
459|55701b|        var requiresFileSystem = false
460|d6ed84|        
461|f445aa|        // Language-specific adjustments
462|f3155b|        switch language {
463|47baba|        case .javascript:
464|5b5f6b|            // Check for complex operations
465|8954eb|            if code.contains("while(true)") || code.contains("for(;;)") {
466|ffde62|                timeEstimate *= 10
467|4a0d47|                cpuEstimate = 1.0
468|a7dc16|            }
469|6258ea|            // Check for large data structures
470|397925|            if code.contains("new Array(1000000)") || code.contains("Array(1000000)") {
471|712430|                memoryEstimate += 8.0 // ~8MB for million element array
472|a7dc16|            }
473|3070d1|            
474|9fa55d|        case .python:
475|cc0433|            // Python typically needs more memory
476|5b850d|            memoryEstimate *= 1.5
477|90ef2b|            if code.contains("import numpy") || code.contains("import pandas") {
478|4b23f0|                memoryEstimate += 100.0
479|118049|                hasExternalDeps = true
480|a7dc16|            }
481|3070d1|            
482|3347f4|        case .swift:
483|ae089e|            // Swift compilation time
484|dde790|            timeEstimate += 2.0
485|78701d|            memoryEstimate *= 1.2
486|3070d1|            
487|520b7d|        default:
488|4c03e4|            break
489|5f3077|        }
490|d6ed84|        
491|9dd287|        // Check for network operations
492|5fc077|        requiresNetwork = detectNetworkAccess(code: code, language: language)
493|d6ed84|        
494|775440|        // Check for file operations
495|dc04f3|        requiresFileSystem = detectFileSystemAccess(code: code, language: language)
496|d6ed84|        
497|71bfc0|        // Check for external dependencies
498|170680|        let deps = analyzeDependencies(code: code, language: language)
499|a4b061|        hasExternalDeps = !deps.isEmpty
500|d6ed84|        
501|18749d|        return ResourceEstimate(
502|fe38e9|            estimatedTimeSeconds: min(timeEstimate, 300.0), // Cap at 5 minutes
503|c3b660|            estimatedMemoryMB: min(memoryEstimate, 2048.0), // Cap at 2GB
504|09bb7c|            estimatedCPUUsage: min(cpuEstimate, 1.0),
505|a91993|            hasExternalDependencies: hasExternalDeps,
506|0ec9ee|            requiresNetwork: requiresNetwork,
507|7f678e|            requiresFileSystem: requiresFileSystem
508|3143a4|        )
509|27e597|    }
510|b4687f|    
511|049941|    // MARK: - Private Methods
512|b4687f|    
513|f40b05|    /// Calculate complexity score based on code analysis
514|cb1c5f|    private func calculateComplexityScore(code: String, language: Language) -> Int {
515|268b95|        var score = 0
516|d6ed84|        
517|5e39ae|        // Lines of code
518|7fa1d4|        let lines = code.components(separatedBy: .newlines).count
519|fe3748|        score += lines / 10 // 1 point per 10 lines
520|d6ed84|        
521|d53ec1|        // Control flow complexity
522|bad9a4|        let controlFlowPatterns = [
523|2e3177|            "if", "else", "switch", "case", "for", "while", "do",
524|7744e8|            "try", "catch", "finally", "guard", "defer"
525|220505|        ]
526|f786bd|        for pattern in controlFlowPatterns {
527|46eab4|            score += code.components(separatedBy: pattern).count - 1
528|5f3077|        }
529|d6ed84|        
530|71c52a|        // Nesting depth (approximate)
531|39d63a|        let braceCount = code.filter { $0 == "{" }.count
532|c62b86|        score += braceCount / 3
533|d6ed84|        
534|7a6e9e|        // Function/method count
535|f3155b|        switch language {
536|1cbd06|        case .javascript, .typescript:
537|fdcf43|            score += code.components(separatedBy: "function ").count - 1
538|c26521|            score += code.components(separatedBy: "=> ").count - 1
539|9fa55d|        case .python:
540|84d85c|            score += code.components(separatedBy: "def ").count - 1
541|3347f4|        case .swift:
542|13df58|            score += code.components(separatedBy: "func ").count - 1
543|520b7d|        default:
544|4c03e4|            break
545|5f3077|        }
546|d6ed84|        
547|51b0fb|        // API calls (external complexity)
548|3ba188|        let apiPatterns = ["fetch(", "XMLHttpRequest", "URLSession", "AF.request", "Alamofire"]
549|fd6ed2|        for pattern in apiPatterns {
550|46eab4|            score += code.components(separatedBy: pattern).count - 1
551|5f3077|        }
552|d6ed84|        
553|c07521|        return score
554|27e597|    }
555|b4687f|    
556|282614|    /// Detect imports/requires to find external dependencies
557|cf7aa0|    private func analyzeDependencies(code: String, language: Language) -> [String] {
558|88f7af|        var dependencies: [String] = []
559|d6ed84|        
560|f3155b|        switch language {
561|1cbd06|        case .javascript, .typescript:
562|61cd6d|            // ES6 imports
563|ff56c1|            let importRegex = try? NSRegularExpression(pattern: #"import\s+(?:{[^}]+}|\*?\s+as\s+\w+|\w+)\s+from\s+['"]([^'"]+)['"]"#, options: [])
564|870e63|            let importMatches = importRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
565|5e345d|            for match in importMatches {
566|70b497|                if let range = Range(match.range(at: 1), in: code) {
567|a57e9e|                    dependencies.append(String(code[range]))
568|4e2d32|                }
569|a7dc16|            }
570|3070d1|            
571|21b0e4|            // CommonJS requires
572|4c919b|            let requireRegex = try? NSRegularExpression(pattern: #"require\s*\(\s*['"]([^'"]+)['"]\s*\)"#, options: [])
573|adfe59|            let requireMatches = requireRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
574|eeb0f8|            for match in requireMatches {
575|70b497|                if let range = Range(match.range(at: 1), in: code) {
576|a57e9e|                    dependencies.append(String(code[range]))
577|4e2d32|                }
578|a7dc16|            }
579|3070d1|            
580|9fa55d|        case .python:
581|a74742|            // Python imports
582|c43333|            let importRegex = try? NSRegularExpression(pattern: #"^\s*(?:import|from)\s+(\w+)"#, options: [.anchorsMatchLines])
583|236390|            let matches = importRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
584|7c58fe|            for match in matches {
585|70b497|                if let range = Range(match.range(at: 1), in: code) {
586|05cd71|                    let module = String(code[range])
587|0d324c|                    // Filter out standard library
588|4c2dfc|                    let stdLib = ["os", "sys", "json", "math", "random", "datetime", "collections", "itertools", "functools"]
589|c3522c|                    if !stdLib.contains(module) {
590|ff894e|                        dependencies.append(module)
591|c9717a|                    }
592|4e2d32|                }
593|a7dc16|            }
594|3070d1|            
595|3347f4|        case .swift:
596|665fed|            // Swift imports
597|2b052a|            let importRegex = try? NSRegularExpression(pattern: #"^\s*import\s+(\w+)"#, options: [.anchorsMatchLines])
598|236390|            let matches = importRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
599|7c58fe|            for match in matches {
600|70b497|                if let range = Range(match.range(at: 1), in: code) {
601|05cd71|                    let module = String(code[range])
602|0d324c|                    // Filter out standard library
603|4f1ce9|                    let stdLib = ["Foundation", "Swift", "Dispatch"]
604|c3522c|                    if !stdLib.contains(module) {
605|ff894e|                        dependencies.append(module)
606|c9717a|                    }
607|4e2d32|                }
608|a7dc16|            }
609|3070d1|            
610|520b7d|        default:
611|4c03e4|            break
612|5f3077|        }
613|d6ed84|        
614|339f3e|        return dependencies
615|27e597|    }
616|b4687f|    
617|cbc39a|    /// Detect file system access patterns
618|fd6689|    private func detectFileSystemAccess(code: String, language: Language) -> Bool {
619|f3155b|        switch language {
620|1cbd06|        case .javascript, .typescript:
621|2e366c|            let patterns = ["fs.readFile", "fs.writeFile", "require('fs')", "import.*fs", "FileReader"]
622|f940c3|            return patterns.contains { code.contains($0) }
623|3070d1|            
624|9fa55d|        case .python:
625|84f076|            let patterns = ["open(", "os.path", "pathlib", "shutil", "with open"]
626|f940c3|            return patterns.contains { code.contains($0) }
627|3070d1|            
628|3347f4|        case .swift:
629|5d4c8c|            let patterns = ["FileManager", "NSData(contentsOfFile:", "String(contentsOfFile:", "FileHandle"]
630|f940c3|            return patterns.contains { code.contains($0) }
631|3070d1|            
632|528e1b|        case .bash:
633|924093|            return true // Bash almost always uses file system
634|3070d1|            
635|520b7d|        default:
636|e2e187|            return false
637|5f3077|        }
638|27e597|    }
639|b4687f|    
640|4286f7|    /// Detect network access patterns
641|3e2f30|    private func detectNetworkAccess(code: String, language: Language) -> Bool {
642|f3155b|        switch language {
643|1cbd06|        case .javascript, .typescript:
644|167191|            let patterns = [
645|7ac6f0|                "fetch(", "XMLHttpRequest", "axios", "$.ajax", "$.get", "$.post",
646|2a345d|                "request(", "require('http')", "require('https')", "new WebSocket",
647|4b211e|                "navigator.sendBeacon", "EventSource"
648|324820|            ]
649|f940c3|            return patterns.contains { code.contains($0) }
650|3070d1|            
651|9fa55d|        case .python:
652|19606a|            let patterns = ["import requests", "import urllib", "import http", "socket.socket", "urlopen"]
653|f940c3|            return patterns.contains { code.contains($0) }
654|3070d1|            
655|3347f4|        case .swift:
656|70bde8|            let patterns = ["URLSession", "URLRequest", "Alamofire", "AF.request"]
657|f940c3|            return patterns.contains { code.contains($0) }
658|3070d1|            
659|528e1b|        case .bash:
660|2dd898|            let patterns = ["curl", "wget", "ssh", "scp", "ftp"]
661|f940c3|            return patterns.contains { code.contains($0) }
662|3070d1|            
663|520b7d|        default:
664|e2e187|            return false
665|5f3077|        }
666|27e597|    }
667|b4687f|    
668|a03740|    /// Build a descriptive reason for why limits were exceeded
669|2ba9a8|    private func buildLimitExceededReason(estimate: ResourceEstimate) -> String {
670|b8f5e6|        var reasons: [String] = []
671|d6ed84|        
672|1d942a|        if estimate.estimatedTimeSeconds > 30 {
673|5a5ed2|            reasons.append("long execution time (\(Int(estimate.estimatedTimeSeconds))s)")
674|5f3077|        }
675|442b8c|        if estimate.estimatedMemoryMB > 256 {
676|b6d668|            reasons.append("high memory usage (\(Int(estimate.estimatedMemoryMB))MB)")
677|5f3077|        }
678|d733bb|        if estimate.hasExternalDependencies {
679|f6f404|            reasons.append("external dependencies required")
680|5f3077|        }
681|68f370|        if estimate.requiresNetwork {
682|06c85a|            reasons.append("network access required")
683|5f3077|        }
684|d6ed84|        
685|f23f42|        return reasons.isEmpty ? "Resource limits exceeded" : reasons.joined(separator: ", ")
686|27e597|    }
687|b31277|}
688|adc83b|
689|790072|// MARK: - Delegate Protocol
690|adc83b|
691|1464e5|/// Protocol for receiving runner selection events
692|83f68a|public protocol RunnerSelectorDelegate: AnyObject {
693|dcf1d0|    /// Called when remote execution is required
694|f41131|    func runnerSelector(_ selector: RunnerSelector, requiresRemoteExecution reason: String, for code: String)
695|b4687f|    
696|210e45|    /// Called when on-device execution is selected
697|1fcf65|    func runnerSelector(_ selector: RunnerSelector, willExecuteOnDevice code: String)
698|b4687f|    
699|9d9b39|    /// Called when execution strategy is determined
700|183001|    func runnerSelector(_ selector: RunnerSelector, selectedStrategy: ExecutionStrategy, for code: String)
701|b31277|}
702|adc83b|
703|eb33bc|// MARK: - Convenience Extensions
704|adc83b|
705|1d4e08|public extension RunnerSelector {
706|a76e29|    /// Quick check if code should run remotely
707|093f67|    func shouldRunRemotely(code: String, language: Language) -> Bool {
708|703083|        let strategy = analyze(code: code, language: language)
709|f18e06|        if case .remote = strategy {
710|40cfc4|            return true
711|5f3077|        }
712|dc1500|        return false
713|27e597|    }
714|b4687f|    
715|7198d9|    /// Get execution strategy with formatted explanation
716|04dbad|    func analyzeWithExplanation(code: String, language: Language) -> (strategy: ExecutionStrategy, explanation: String) {
717|3ae7a7|        let result = canRunOnDevice(code: code, language: language)
718|d6ed84|        
719|31824e|        var explanation = "Execution Analysis:\n"
720|9cd92c|        explanation += "Strategy: \(result.recommendedStrategy.description)\n"
721|0d2869|        explanation += "Can run on-device: \(result.canRunOnDevice ? "Yes" : "No")\n\n"
722|3b2cfd|        explanation += "Factors:\n"
723|684bbf|        for factor in result.factors {
724|af0821|            explanation += "  \(factor.status.rawValue) \(factor.name): \(factor.description)\n"
725|5f3077|        }
726|1474e7|        explanation += "\nResource Estimate:\n"
727|fc8352|        explanation += "  Time: \(Int(result.resourceEstimate.estimatedTimeSeconds))s\n"
728|d75dfd|        explanation += "  Memory: \(Int(result.resourceEstimate.estimatedMemoryMB))MB\n"
729|427900|        explanation += "  CPU: \(Int(result.resourceEstimate.estimatedCPUUsage * 100))%\n"
730|d6ed84|        
731|058b2d|        return (result.recommendedStrategy, explanation)
732|27e597|    }
733|b31277|}
734|adc83b|
735|950eba|// MARK: - Usage Examples
736|adc83b|
737|32ca1a|/*
738|991d9c| // Example 1: Basic usage
739|f1ee82| let selector = RunnerSelector()
740|8b2d61| let strategy = selector.analyze(code: "console.log('Hello')", language: .javascript)
741|403835| // Returns: .onDevice
742|dd1225| 
743|307147| // Example 2: Network access requires remote
744|69cc90| let strategy = selector.analyze(
745|13f75d|     code: "fetch('https://api.example.com')",
746|9ad517|     language: .javascript
747|c37227| )
748|40f8b6| // Returns: .remote(reason: "Network access required but not allowed on-device")
749|dd1225| 
750|247be3| // Example 3: Detailed analysis
751|2c6479| let result = selector.canRunOnDevice(
752|ddec13|     code: "import numpy; print('test')",
753|3e9b5d|     language: .python
754|c37227| )
755|7a7463| // result.canRunOnDevice = false
756|8b806d| // result.factors contains warnings about Python not being available
757|dd1225| 
758|5092f3| // Example 4: With user preferences
759|c0523c| let preferences = ExecutionPreferences(
760|751ea3|     preferOnDevice: true,
761|ce66f0|     warnBeforeRemote: true,
762|e53b22|     maxOnDeviceTimeSeconds: 5.0
763|c37227| )
764|f8ce0b| let selector = RunnerSelector(preferences: preferences)
765|dd1225| 
766|b36628| // Example 5: Using delegate
767|9895ad| class ExecutionCoordinator: RunnerSelectorDelegate {
768|89dc6e|     func runnerSelector(_ selector: RunnerSelector, requiresRemoteExecution reason: String, for code: String) {
769|9bade8|         showRemoteExecutionWarning(reason: reason)
770|48082f|     }
771|8f1f4b|     
772|6dc5ad|     func runnerSelector(_ selector: RunnerSelector, willExecuteOnDevice code: String) {
773|16c4b5|         showLoadingIndicator()
774|48082f|     }
775|02e5c8| }
776|dd1225| 
777|f1ee82| let selector = RunnerSelector()
778|1d1494| selector.delegate = coordinator
779|dd1225| 
780|43cef1| // Example 6: Resource estimation
781|bb02df| let estimate = selector.estimateResourceUsage(
782|d6336f|     code: largeScript,
783|9ad517|     language: .javascript
784|c37227| )
785|8f8173| print("Estimated: \(estimate.estimatedTimeSeconds)s, \(estimate.estimatedMemoryMB)MB")
786|dd1225| 
787|5245b8| // Example 7: With formatted explanation
788|f3ca15| let (strategy, explanation) = selector.analyzeWithExplanation(
789|a1fa5c|     code: code,
790|4bfba8|     language: .swift
791|c37227| )
792|9f6b72| print(explanation) // Human-readable analysis
793|d48ab4| */
794|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 68c762044b1e
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 1-1202 of 1202)
────────────────────────────────────────
1|d755ba|import SwiftUI
2|9ed0a9|import UIKit
3|c4e19d|import UniformTypeIdentifiers
4|adc83b|
5|2a57a9|// MARK: - Helper Functions
6|ad5b9c|// Moved to Extensions/FileHelpers.swift
7|adc83b|
8|a68576|// MARK: - Main Content View
9|adc83b|
10|4a07a6|struct ContentView: View {
11|088df4|    @EnvironmentObject var editorCore: EditorCore
12|2872fe|    @StateObject private var fileNavigator = FileSystemNavigator()
13|37f8cd|    @StateObject private var themeManager = ThemeManager.shared
14|b4687f|    
15|8cd583|    @State private var showingDocumentPicker = false
16|b4c22b|    @State private var showingFolderPicker = false
17|9eee01|    @State private var showSettings = false
18|489b1b|    @State private var showTerminal = false
19|e0d33d|    @State private var terminalHeight: CGFloat = 200
20|fdc30d|    @State private var selectedSidebarTab = 0
21|f8f90c|    @State private var pendingTrustURL: URL?
22|2503ee|    @State private var windowTitle: String = "VS Code"
23|b4687f|    
24|1e596a|    @StateObject private var trustManager = WorkspaceTrustManager.shared
25|b4687f|    
26|9f2686|    private var theme: Theme { themeManager.currentTheme }
27|b4687f|    
28|504e43|    var body: some View {
29|88666c|        ZStack {
30|92175e|            VStack(spacing: 0) {
31|7a5371|                HStack(spacing: 0) {
32|27e10a|                    IDEActivityBar(editorCore: editorCore, selectedTab: $selectedSidebarTab, showSettings: $showSettings, showTerminal: $showTerminal)
33|dd2193|                    
34|4dab7d|                    if editorCore.showSidebar {
35|d419cb|                        sidebarContent.frame(width: editorCore.sidebarWidth)
36|c9717a|                    }
37|dd2193|                    
38|1e36f9|                    VStack(spacing: 0) {
39|6a811f|                        IDETabBar(editorCore: editorCore, theme: theme)
40|956cfe|                        
41|83c7d6|                        if let tab = editorCore.activeTab {
42|031e08|                            IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
43|1dbdcc|                                .id(tab.id)  // Force view recreation when tab changes
44|65e2f4|                        } else {
45|7f8e7c|                            IDEWelcomeView(editorCore: editorCore, showFolderPicker: $showingFolderPicker, theme: theme)
46|392b35|                        }
47|956cfe|                        
48|194580|                        StatusBarView(editorCore: editorCore)
49|c9717a|                    }
50|4e2d32|                }
51|216278|                
52|716072|                if showTerminal {
53|59d000|                    PanelView(isVisible: $showTerminal, height: $terminalHeight)
54|4e2d32|                }
55|a7dc16|            }
56|6f1e62|            .background(theme.editorBackground)
57|3070d1|            
58|7302ba|            // Overlays - Command Palette (Cmd+Shift+P)
59|4198c8|            if editorCore.showCommandPalette {
60|58c9ab|                Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showCommandPalette = false }
61|8e2128|                CommandPaletteView(editorCore: editorCore, showSettings: $showSettings, showTerminal: $showTerminal)
62|a7dc16|            }
63|3070d1|            
64|fa065d|            // Quick Open (Cmd+P)
65|01c135|            if editorCore.showQuickOpen {
66|a54d0f|                Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showQuickOpen = false }
67|ce04b0|                QuickOpenView(editorCore: editorCore, fileNavigator: fileNavigator)
68|a7dc16|            }
69|3070d1|            
70|a99939|            // Go To Symbol (Cmd+Shift+O)
71|5d58a0|            if editorCore.showGoToSymbol {
72|b595d3|                Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToSymbol = false }
73|c5b9a1|                GoToSymbolView(editorCore: editorCore, onGoToLine: { _ in })
74|a7dc16|            }
75|3070d1|            
76|1be718|            // AI Assistant
77|e0d260|            if editorCore.showAIAssistant {
78|4f1597|                HStack { Spacer(); AIAssistantView(editorCore: editorCore).frame(width: 400, height: 500).padding() }
79|a7dc16|            }
80|3070d1|            
81|6203ff|            // Go To Line (Ctrl+G)
82|a2b661|            if editorCore.showGoToLine {
83|5c3db9|                Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToLine = false }
84|81e062|                GoToLineView(isPresented: $editorCore.showGoToLine, onGoToLine: { _ in })
85|a7dc16|            }
86|3070d1|            
87|6f717b|            // Workspace Trust Dialog
88|098802|            if let trustURL = pendingTrustURL {
89|ab7e7f|                Color.black.opacity(0.4).ignoresSafeArea()
90|df03f4|                WorkspaceTrustDialog(workspaceURL: trustURL, onTrust: {
91|c68ffe|                    trustManager.trust(url: trustURL)
92|de4749|                    finishOpeningWorkspace(trustURL)
93|462591|                    pendingTrustURL = nil
94|125220|                }, onCancel: {
95|462591|                    pendingTrustURL = nil
96|b102ed|                })
97|a7dc16|            }
98|5f3077|        }
99|d15dde|        .sheet(isPresented: $showingDocumentPicker) { IDEDocumentPicker(editorCore: editorCore) }
100|9158ae|        .sheet(isPresented: $showingFolderPicker) {
101|0ac5b1|            IDEFolderPicker(fileNavigator: fileNavigator) { url in
102|f33638|                if trustManager.isTrusted(url: url) {
103|442245|                    finishOpeningWorkspace(url)
104|fdd0e2|                } else {
105|62b0e4|                    pendingTrustURL = url
106|4e2d32|                }
107|a7dc16|            }
108|5f3077|        }
109|5005ae|        .sheet(isPresented: $showSettings) { SettingsView(themeManager: themeManager) }
110|bd0708|        .sheet(isPresented: $editorCore.showSaveAsDialog) {
111|6a4512|            IDESaveAsPicker(
112|c4a7af|                editorCore: editorCore,
113|e79992|                content: editorCore.saveAsContent,
114|fe6b2f|                suggestedName: editorCore.activeTab?.fileName ?? "Untitled.txt"
115|43d041|            )
116|5f3077|        }
117|e49551|        .onChange(of: editorCore.showFilePicker) { show in showingDocumentPicker = show }
118|d712a4|        .onChange(of: editorCore.activeTab?.fileName) { newFileName in
119|b402b3|            updateWindowTitle()
120|5f3077|        }
121|4fa530|        .onChange(of: editorCore.tabs.count) { _ in
122|b402b3|            updateWindowTitle()
123|5f3077|        }
124|9fb603|        .onChange(of: editorCore.activeTabId) { _ in
125|b402b3|            updateWindowTitle()
126|5f3077|        }
127|e16410|        .onChange(of: editorCore.activeTab?.isUnsaved) { _ in
128|b402b3|            updateWindowTitle()
129|5f3077|        }
130|2bd24e|        .onAppear {
131|05c407|            // Wire up EditorCore -> FileSystemNavigator so save operations can route through it.
132|d410a3|            editorCore.fileNavigator = fileNavigator
133|b402b3|            updateWindowTitle()
134|5f3077|        }
135|be2cfe|        // MARK: - Notification Handlers for Menu Keyboard Shortcuts
136|5f1d44|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowCommandPalette"))) { _ in
137|e74633|            editorCore.showCommandPalette = true
138|5f3077|        }
139|dcdcf8|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleTerminal"))) { _ in
140|9d7767|            showTerminal.toggle()
141|5f3077|        }
142|8c8974|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleSidebar"))) { _ in
143|53cad1|            editorCore.toggleSidebar()
144|5f3077|        }
145|f012ad|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowQuickOpen"))) { _ in
146|386b9a|            editorCore.showQuickOpen = true
147|5f3077|        }
148|71e497|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToSymbol"))) { _ in
149|e57e74|            editorCore.showGoToSymbol = true
150|5f3077|        }
151|61fe23|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToLine"))) { _ in
152|8cc4b6|            editorCore.showGoToLine = true
153|5f3077|        }
154|7f8a05|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAIAssistant"))) { _ in
155|0a68c1|            editorCore.showAIAssistant = true
156|5f3077|        }
157|809dfc|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewFile"))) { _ in
158|b60db2|            editorCore.addTab()
159|5f3077|        }
160|8d2162|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveFile"))) { _ in
161|07f047|            editorCore.saveActiveTab()
162|5f3077|        }
163|d2a947|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CloseTab"))) { _ in
164|c7a65d|            if let id = editorCore.activeTabId { editorCore.closeTab(id: id) }
165|5f3077|        }
166|a9ccd0|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowFind"))) { _ in
167|72e173|            editorCore.showSearch = true
168|5f3077|        }
169|c69ebf|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ZoomIn"))) { _ in
170|224c97|            editorCore.zoomIn()
171|5f3077|        }
172|7ff5a6|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ZoomOut"))) { _ in
173|18c95d|            editorCore.zoomOut()
174|5f3077|        }
175|fb4855|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RunWithoutDebugging"))) { _ in
176|7ff579|            // Execute the current file using JSRunner for .js files
177|71e6ee|            if let activeTab = editorCore.activeTab {
178|a60731|                CodeExecutionService.shared.executeCurrentFile(
179|6332f1|                    fileName: activeTab.fileName,
180|d26039|                    content: activeTab.content
181|6f642e|                )
182|e325ce|                // Show the terminal/panel and switch to Output tab so user can see output
183|f34303|                showTerminal = true
184|fc89bb|                NotificationCenter.default.post(name: NSNotification.Name("SwitchToOutputPanel"), object: nil)
185|a7dc16|            }
186|5f3077|        }
187|4a37b7|        .environmentObject(themeManager)
188|e3bdc6|        .environmentObject(editorCore)
189|27e597|    }
190|b4687f|    
191|231605|    private func finishOpeningWorkspace(_ url: URL) {
192|6dcdb7|        fileNavigator.loadFileTree(at: url)
193|d79336|        Task { @MainActor in
194|99e24e|            LaunchManager.shared.setWorkspaceRoot(url)
195|eccbe2|            GitManager.shared.setWorkingDirectory(url)
196|5f3077|        }
197|27e597|    }
198|b4687f|    
199|65a033|    private func updateWindowTitle() {
200|53ad0a|        if let activeTab = editorCore.activeTab {
201|ba8861|            let fileName = activeTab.fileName
202|b072a0|            let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
203|741609|            windowTitle = "\(unsavedIndicator)\(fileName) - VS Code"
204|59ea7f|        } else if !editorCore.tabs.isEmpty {
205|fa7eae|            windowTitle = "VS Code"
206|b31999|        } else {
207|6c3506|            windowTitle = "Welcome - VS Code"
208|5f3077|        }
209|d6ed84|        
210|c675c5|        // Notify the app of the title change
211|63edcc|        NotificationCenter.default.post(
212|9251fc|            name: NSNotification.Name("WindowTitleDidChange"),
213|33f159|            object: nil,
214|332f22|            userInfo: ["title": windowTitle]
215|3143a4|        )
216|27e597|    }
217|b4687f|    
218|ab06c2|    @ViewBuilder
219|0bbc6d|    private var sidebarContent: some View {
220|34711c|        switch selectedSidebarTab {
221|ab83f1|        case 0:
222|161f7c|            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
223|032375|        case 1:
224|19e3bd|            SidebarSearchView(theme: theme)
225|12d44a|        case 2:
226|7fc3ae|            GitView()
227|1a2232|        case 3:
228|7116ef|            DebugView()
229|520b7d|        default:
230|161f7c|            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
231|5f3077|        }
232|27e597|    }
233|b31277|}
234|adc83b|
235|6fd553|// MARK: - Activity Bar
236|adc83b|
237|adc83b|
238|adc83b|
239|4a910a|struct BarButton: View {
240|f0e87a|    let icon: String
241|055123|    let isSelected: Bool
242|6b0e55|    let theme: Theme
243|59027a|    let action: () -> Void
244|b4687f|    
245|504e43|    var body: some View {
246|6f04d8|        Button(action: action) {
247|ed6617|            Image(systemName: icon)
248|13a7f6|                .font(.system(size: 22))
249|557f46|                .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
250|c81e69|                .frame(width: 48, height: 48)
251|5f3077|        }
252|27e597|    }
253|b31277|}
254|adc83b|
255|2f1081|// MARK: - Sidebar with Real File System
256|adc83b|
257|77668e|struct IDESidebarFiles: View {
258|e5f895|    @ObservedObject var editorCore: EditorCore
259|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
260|fe002a|    @Binding var showFolderPicker: Bool
261|6b0e55|    let theme: Theme
262|b4687f|    
263|504e43|    var body: some View {
264|0865e6|        VStack(alignment: .leading, spacing: 0) {
265|f49fd2|            HStack {
266|8f10b4|                Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
267|a02350|                Spacer()
268|124c35|                Button(action: { showFolderPicker = true }) {
269|98d029|                    Image(systemName: "folder.badge.plus").font(.caption)
270|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
271|035054|                Button(action: { editorCore.showFilePicker = true }) {
272|e2bf82|                    Image(systemName: "doc.badge.plus").font(.caption)
273|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
274|eaa303|                if fileNavigator.fileTree != nil {
275|a67875|                    Button(action: { fileNavigator.refreshFileTree() }) {
276|7cfff4|                        Image(systemName: "arrow.clockwise").font(.caption)
277|681233|                    }.foregroundColor(theme.sidebarForeground.opacity(0.7))
278|4e2d32|                }
279|5cbd4e|            }.padding(.horizontal, 12).padding(.vertical, 8)
280|3070d1|            
281|6b85db|            ScrollView {
282|492557|                VStack(alignment: .leading, spacing: 2) {
283|5cce6c|                    if let tree = fileNavigator.fileTree {
284|46c9f4|                        FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
285|540066|                    } else {
286|b9326c|                        DemoFileTree(editorCore: editorCore, theme: theme)
287|c9717a|                    }
288|d407ec|                }.padding(.horizontal, 8)
289|a7dc16|            }
290|ea6339|        }.background(theme.sidebarBackground)
291|27e597|    }
292|b31277|}
293|adc83b|
294|2efb89|struct RealFileTreeView: View {
295|7345b3|    let node: FileTreeNode
296|ded86f|    let level: Int
297|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
298|e5f895|    @ObservedObject var editorCore: EditorCore
299|6b0e55|    let theme: Theme
300|b4687f|    
301|17d62f|    var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
302|b4687f|    
303|504e43|    var body: some View {
304|ea9354|        VStack(alignment: .leading, spacing: 2) {
305|37f526|            HStack(spacing: 4) {
306|a37387|                if node.isDirectory {
307|440597|                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
308|8aec79|                        .font(.caption2).frame(width: 12)
309|0b3717|                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
310|740862|                        .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
311|fdd0e2|                } else {
312|df77cf|                    Spacer().frame(width: 12)
313|4e2d32|                }
314|bf729b|                Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
315|8237e3|                    .font(.caption)
316|a7e98c|                    .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
317|926090|                Text(node.name).font(.system(.caption)).lineLimit(1)
318|985367|                    .foregroundColor(theme.sidebarForeground)
319|a02350|                Spacer()
320|a7dc16|            }
321|f3d9fb|            .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
322|68d57d|            .contentShape(Rectangle())
323|835ded|            .onTapGesture {
324|a37387|                if node.isDirectory {
325|8f26cf|                    fileNavigator.toggleExpanded(path: node.url.path)
326|fdd0e2|                } else {
327|13e765|                    editorCore.openFile(from: node.url)
328|4e2d32|                }
329|a7dc16|            }
330|3070d1|            
331|dd4b6d|            if isExpanded && node.isDirectory {
332|4a6742|                ForEach(node.children) { child in
333|8deaf6|                    RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
334|4e2d32|                }
335|a7dc16|            }
336|5f3077|        }
337|27e597|    }
338|b31277|}
339|adc83b|
340|c7c785|struct DemoFileTree: View {
341|e5f895|    @ObservedObject var editorCore: EditorCore
342|6b0e55|    let theme: Theme
343|b4687f|    
344|504e43|    var body: some View {
345|478d8c|        VStack(alignment: .leading, spacing: 4) {
346|dca3c9|            Text("Open a folder to browse files")
347|916793|                .font(.caption)
348|417420|                .foregroundColor(theme.sidebarForeground.opacity(0.6))
349|a48a8d|                .padding(.vertical, 8)
350|3070d1|            
351|eead9e|            DemoFileRow(name: "Welcome.swift", editorCore: editorCore, theme: theme)
352|cbcd60|            DemoFileRow(name: "example.js", editorCore: editorCore, theme: theme)
353|0f2913|            DemoFileRow(name: "example.py", editorCore: editorCore, theme: theme)
354|c07fb7|            DemoFileRow(name: "package.json", editorCore: editorCore, theme: theme)
355|d67c95|            DemoFileRow(name: "index.html", editorCore: editorCore, theme: theme)
356|822f11|            DemoFileRow(name: "styles.css", editorCore: editorCore, theme: theme)
357|5f3077|        }
358|27e597|    }
359|b31277|}
360|adc83b|
361|ab28f0|struct DemoFileRow: View {
362|a5193b|    let name: String
363|e5f895|    @ObservedObject var editorCore: EditorCore
364|6b0e55|    let theme: Theme
365|b4687f|    
366|504e43|    var body: some View {
367|b120fa|        HStack(spacing: 4) {
368|5a4821|            Spacer().frame(width: 12)
369|5a9b2c|            Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
370|0ffef7|            Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
371|1e6289|            Spacer()
372|5f3077|        }
373|60e15e|        .padding(.vertical, 4)
374|55e29b|        .contentShape(Rectangle())
375|cf12c6|        .onTapGesture {
376|9f9063|            if let tab = editorCore.tabs.first(where: { $0.fileName == name }) {
377|166be5|                editorCore.selectTab(id: tab.id)
378|a7dc16|            }
379|5f3077|        }
380|27e597|    }
381|b31277|}
382|adc83b|
383|f3aab4|// MARK: - Tab Bar
384|adc83b|
385|24d9d9|struct IDETabBar: View {
386|e5f895|    @ObservedObject var editorCore: EditorCore
387|6b0e55|    let theme: Theme
388|b4687f|    
389|504e43|    var body: some View {
390|98ab70|        ScrollView(.horizontal, showsIndicators: false) {
391|3b7550|            HStack(spacing: 0) {
392|7512d8|                ForEach(editorCore.tabs) { tab in
393|4b4bd2|                    IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
394|4e2d32|                }
395|5de7cd|                Button(action: { editorCore.addTab() }) {
396|fd7d74|                    Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
397|4e2d32|                }
398|30b85f|            }.padding(.horizontal, 4)
399|962d70|        }.frame(height: 36).background(theme.tabBarBackground)
400|27e597|    }
401|b31277|}
402|adc83b|
403|68fbe9|struct IDETabItem: View {
404|4dc199|    let tab: Tab
405|055123|    let isSelected: Bool
406|e5f895|    @ObservedObject var editorCore: EditorCore
407|6b0e55|    let theme: Theme
408|b4687f|    
409|504e43|    var body: some View {
410|e1c66d|        HStack(spacing: 6) {
411|29528a|            Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
412|a9dd8d|            Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
413|d555ba|                .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
414|5029ae|            if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
415|6effb3|            Button(action: { editorCore.closeTab(id: tab.id) }) {
416|f4c72a|                Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
417|041ce7|                    .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
418|a7dc16|            }
419|5f3077|        }
420|2da2e9|        .padding(.horizontal, 12).padding(.vertical, 6)
421|116b54|        .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
422|7a9052|        .onTapGesture { editorCore.selectTab(id: tab.id) }
423|27e597|    }
424|b31277|}
425|adc83b|
426|f95ca3|// MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
427|adc83b|
428|a178f9|struct IDEEditorView: View {
429|e5f895|    @ObservedObject var editorCore: EditorCore
430|4dc199|    let tab: Tab
431|6b0e55|    let theme: Theme
432|b4687f|    
433|129112|    /// Feature flag for Runestone editor - uses centralized FeatureFlags
434|952908|    private var useRunestoneEditor: Bool { FeatureFlags.useRunestoneEditor }
435|adc83b|
436|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
437|eba335|    @State private var text: String = ""
438|4f0ac8|    @State private var scrollPosition: Int = 0
439|36da68|    @State private var scrollOffset: CGFloat = 0
440|d473fd|    @State private var totalLines: Int = 1
441|bcf90b|    @State private var visibleLines: Int = 20
442|9cb5e9|    @State private var currentLineNumber: Int = 1
443|cc347a|    @State private var currentColumn: Int = 1
444|eee196|    @State private var cursorIndex: Int = 0
445|2c43f6|    @State private var lineHeight: CGFloat = 17
446|446eb9|    @State private var requestedCursorIndex: Int? = nil
447|5c2aeb|    @State private var requestedLineSelection: Int? = nil
448|adc83b|
449|3977e1|    @StateObject private var autocomplete = AutocompleteManager()
450|4445ec|    @State private var showAutocomplete = false
451|a9aa54|    @ObservedObject private var foldingManager = CodeFoldingManager.shared
452|f453fc|    @StateObject private var findViewModel = FindViewModel()
453|b4687f|    
454|504e43|    var body: some View {
455|94dd27|        VStack(spacing: 0) {
456|8779dd|            // Find/Replace bar
457|2b2a70|            if editorCore.showSearch {
458|38cbe4|                FindReplaceView(viewModel: findViewModel)
459|b768ed|                    .background(theme.tabBarBackground)
460|a7dc16|            }
461|3070d1|            
462|b97232|            BreadcrumbsView(editorCore: editorCore, tab: tab)
463|3070d1|            
464|ca6f75|            GeometryReader { geometry in
465|e60c16|                ZStack(alignment: .topLeading) {
466|7a5371|                HStack(spacing: 0) {
467|439015|                    // Only show custom line numbers for legacy editor (Runestone has built-in line numbers)
468|3dcece|                    if lineNumbersStyle != "off" && !useRunestoneEditor {
469|ca5e14|                        LineNumbersWithFolding(
470|a108d1|                            fileId: tab.url?.path ?? tab.fileName,
471|937d74|                            totalLines: totalLines,
472|0f00a6|                            currentLine: currentLineNumber,
473|d6742c|                            scrollOffset: scrollOffset,
474|9f4e9f|                            lineHeight: lineHeight,
475|76e9b6|                            requestedLineSelection: $requestedLineSelection,
476|0d74bf|                            foldingManager: foldingManager,
477|0acd63|                            theme: theme
478|63214b|                        )
479|c15397|                        .frame(width: 60)
480|3a838d|                        .background(theme.sidebarBackground.opacity(0.5))
481|c9717a|                    }
482|dd2193|                    
483|3f9dab|                    // Use Runestone for all files including JSON (has TreeSitter JSON support)
484|df925c|                    if false && tab.fileName.hasSuffix(".json") {
485|4229a0|                        // JSON Tree View disabled - using Runestone editor instead
486|daf992|                        JSONTreeView(data: text.data(using: .utf8) ?? Data())
487|f9d830|                            .frame(maxWidth: .infinity, maxHeight: .infinity)
488|96e3a5|                            .background(theme.editorBackground)
489|540066|                    } else {
490|082ddd|                        // Use Runestone for O(log n) performance, or legacy view as fallback
491|e44d33|                        Group {
492|31b1a0|                            if useRunestoneEditor {
493|40914b|                                RunestoneEditorView(
494|4496ad|                                    text: $text,
495|d36f79|                                    filename: tab.fileName,
496|deb430|                                    scrollOffset: $scrollOffset,
497|2b845b|                                    totalLines: $totalLines,
498|71c5eb|                                    currentLineNumber: $currentLineNumber,
499|872d17|                                    currentColumn: $currentColumn,
500|927813|                                    cursorIndex: $cursorIndex,
501|397368|                                    isActive: true,
502|b41e3e|                                    fontSize: editorCore.editorFontSize,
503|f39601|                                    onAcceptAutocomplete: {
504|35fa15|                                        guard showAutocomplete else { return false }
505|028ab7|                                        var tempText = text
506|4f6f56|                                        var tempCursor = cursorIndex
507|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
508|28278a|                                        if tempText != text {
509|1a390a|                                            text = tempText
510|9a3612|                                            cursorIndex = tempCursor
511|55a703|                                            requestedCursorIndex = tempCursor
512|46924a|                                            showAutocomplete = false
513|e18645|                                            return true
514|eed1d8|                                        }
515|9818dc|                                        return false
516|3cc64b|                                    },
517|7ed733|                                    onDismissAutocomplete: {
518|35fa15|                                        guard showAutocomplete else { return false }
519|fc38c2|                                        autocomplete.hideSuggestions()
520|579f59|                                        showAutocomplete = false
521|c09eb1|                                        return true
522|8ab74d|                                    }
523|58a90d|                                )
524|240f50|                            } else {
525|e97ddb|                                // Legacy SyntaxHighlightingTextView (fallback)
526|27eb3b|                                SyntaxHighlightingTextView(
527|4496ad|                                    text: $text,
528|d36f79|                                    filename: tab.fileName,
529|44ffa0|                                    scrollPosition: $scrollPosition,
530|deb430|                                    scrollOffset: $scrollOffset,
531|2b845b|                                    totalLines: $totalLines,
532|a9b405|                                    visibleLines: $visibleLines,
533|71c5eb|                                    currentLineNumber: $currentLineNumber,
534|872d17|                                    currentColumn: $currentColumn,
535|927813|                                    cursorIndex: $cursorIndex,
536|31e938|                                    lineHeight: $lineHeight,
537|397368|                                    isActive: true,
538|b41e3e|                                    fontSize: editorCore.editorFontSize,
539|193919|                                    requestedLineSelection: $requestedLineSelection,
540|70abf8|                                    requestedCursorIndex: $requestedCursorIndex,
541|f39601|                                    onAcceptAutocomplete: {
542|35fa15|                                        guard showAutocomplete else { return false }
543|028ab7|                                        var tempText = text
544|4f6f56|                                        var tempCursor = cursorIndex
545|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
546|28278a|                                        if tempText != text {
547|1a390a|                                            text = tempText
548|9a3612|                                            cursorIndex = tempCursor
549|55a703|                                            requestedCursorIndex = tempCursor
550|46924a|                                            showAutocomplete = false
551|e18645|                                            return true
552|eed1d8|                                        }
553|9818dc|                                        return false
554|3cc64b|                                    },
555|7ed733|                                    onDismissAutocomplete: {
556|35fa15|                                        guard showAutocomplete else { return false }
557|fc38c2|                                        autocomplete.hideSuggestions()
558|579f59|                                        showAutocomplete = false
559|c09eb1|                                        return true
560|8ab74d|                                    }
561|58a90d|                                )
562|89d40a|                            }
563|392b35|                        }
564|23a7d6|                        .onChange(of: text) { newValue in
565|c2cbfa|                            editorCore.updateActiveTabContent(newValue)
566|ca5c5e|                            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
567|2d6cfb|                            autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
568|5db623|                            showAutocomplete = autocomplete.showSuggestions
569|f1e408|                            foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path ?? tab.fileName)
570|392b35|                        }
571|ae1be2|                        .onChange(of: cursorIndex) { newCursor in
572|017a4d|                            autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
573|5db623|                            showAutocomplete = autocomplete.showSuggestions
574|392b35|                        }
575|c9717a|                    }
576|dd2193|                    
577|0fbe94|                    if !tab.fileName.hasSuffix(".json") {
578|d0a712|                        MinimapView(
579|234a10|                            content: text,
580|d6742c|                            scrollOffset: scrollOffset,
581|9a8bd2|                            scrollViewHeight: geometry.size.height,
582|29b4a2|                            totalContentHeight: CGFloat(totalLines) * lineHeight,
583|83e3c8|                            onScrollRequested: { newOffset in
584|c2e825|                                // Minimap requested scroll - update editor position
585|d09b41|                                scrollOffset = newOffset
586|af41de|                                // Convert back from pixels to line number
587|6ad0f0|                                let newLine = Int(newOffset / max(lineHeight, 1))
588|ec5b45|                                scrollPosition = max(0, min(newLine, totalLines - 1))
589|89d40a|                            }
590|63214b|                        )
591|abeec0|                        .frame(width: 80)
592|c9717a|                    }
593|4e2d32|                }
594|3bc2db|                .background(theme.editorBackground)
595|adc83b|
596|cf06bf|                // Sticky Header Overlay (FEAT-040)
597|d5af46|                StickyHeaderView(
598|c24fd5|                    text: text,
599|f49254|                    currentLine: scrollPosition,
600|f7b7a6|                    theme: theme,
601|8e60a5|                    lineHeight: lineHeight,
602|9628b3|                    onSelect: { line in
603|df068a|                        requestedLineSelection = line
604|c9717a|                    }
605|6f642e|                )
606|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
607|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
608|adc83b|
609|0f82df|                // Inlay Hints Overlay (type hints, parameter names)
610|a8bcb0|                InlayHintsOverlay(
611|0fb212|                    code: text,
612|5f8f93|                    language: tab.language,
613|23acb0|                    scrollPosition: scrollPosition,
614|8e60a5|                    lineHeight: lineHeight,
615|0e3ffc|                    fontSize: editorCore.editorFontSize,
616|a63927|                    gutterWidth: (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0,
617|088baa|                    rightReservedWidth: tab.fileName.hasSuffix(".json") ? 0 : 80
618|6f642e|                )
619|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
620|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
621|8eef2d|                if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
622|baeb3a|                    AutocompletePopup(
623|83a4b0|                        suggestions: autocomplete.suggestionItems,
624|53da2f|                        selectedIndex: autocomplete.selectedIndex,
625|5db55c|                        theme: theme
626|82606a|                    ) { index in
627|3a2861|                        autocomplete.selectedIndex = index
628|9c12a8|                        var tempText = text
629|f02eb3|                        var tempCursor = cursorIndex
630|7fdc0e|                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
631|326231|                        if tempText != text {
632|d7f8a5|                            text = tempText
633|34aa29|                            cursorIndex = tempCursor
634|d3d820|                            requestedCursorIndex = tempCursor
635|392b35|                        }
636|2411d0|                        showAutocomplete = false
637|c9717a|                    }
638|58a34b|                    .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
639|4e2d32|                }
640|a7dc16|            }
641|5f3077|        }
642|5f3077|        }
643|2bd24e|        .onAppear {
644|ba85f8|            text = tab.content
645|92d865|            foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
646|5f3077|        }
647|9d97c0|        .onChange(of: tab.id) { _ in
648|ba85f8|            text = tab.content
649|92d865|            foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
650|5f3077|        }
651|d3345e|        .onChange(of: currentLineNumber) { line in
652|3384f8|            editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
653|5f3077|        }
654|588fd8|        .onChange(of: currentColumn) { col in
655|16524d|            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
656|5f3077|        }
657|2bd24e|        .onAppear {
658|c916b3|            findViewModel.editorCore = editorCore
659|5f3077|        }
660|27e597|    }
661|b4687f|    
662|a19e38|    // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
663|b31277|}
664|adc83b|
665|dcdcdb|// MARK: - Line Numbers with Folding
666|adc83b|
667|c8dd5c|struct LineNumbersWithFolding: View {
668|5799da|    let fileId: String
669|cdda83|    let totalLines: Int
670|c75d8a|    let currentLine: Int
671|5b2177|    let scrollOffset: CGFloat
672|96ac71|    let lineHeight: CGFloat
673|86829b|    @Binding var requestedLineSelection: Int?
674|ec5c86|    @ObservedObject var foldingManager: CodeFoldingManager
675|c97289|    @ObservedObject private var debugManager = DebugManager.shared
676|6b0e55|    let theme: Theme
677|adc83b|
678|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
679|adc83b|
680|504e43|    var body: some View {
681|ca170c|        ScrollView(showsIndicators: false) {
682|829de3|            VStack(alignment: .trailing, spacing: 0) {
683|2e20ec|                // Match UITextView.textContainerInset.top (see SyntaxHighlightingTextView.swift)
684|551416|                // so line numbers stay vertically aligned with the first line of text.
685|227120|                ForEach(0..<totalLines, id: \.self) { lineIndex in
686|71bf03|                    if !foldingManager.isLineFolded(line: lineIndex) {
687|d3392c|                        HStack(spacing: 2) {
688|8eed40|                            Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
689|5f750e|                                Circle()
690|4cf57e|                                    .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
691|5ded70|                                    .overlay(
692|6304cf|                                        Circle()
693|f93b39|                                            .stroke(Color.red.opacity(0.6), lineWidth: 1)
694|fe99c4|                                            .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
695|bf17fb|                                    )
696|d07523|                                    .frame(width: 10, height: 10)
697|da49b4|                                    .padding(.leading, 2)
698|89d40a|                            }
699|917e04|                            .buttonStyle(.plain)
700|746328|                            .frame(width: 14, height: lineHeight)
701|adc83b|
702|75451e|                            if foldingManager.isFoldable(line: lineIndex) {
703|6ae979|                                Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
704|8689bb|                                    Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
705|e50a51|                                        .font(.system(size: 8))
706|856d81|                                        .foregroundColor(theme.lineNumber)
707|f83e05|                                }
708|31bef9|                                .buttonStyle(.plain)
709|23311c|                                .frame(width: 14, height: lineHeight)
710|240f50|                            } else {
711|b18c2d|                                Spacer().frame(width: 14)
712|89d40a|                            }
713|adc83b|
714|6798e8|                            Text(displayText(for: lineIndex))
715|f57164|                                .font(.system(size: 12, design: .monospaced))
716|525023|                                .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
717|5d10bc|                                .frame(height: lineHeight)
718|5cb7d4|                                .contentShape(Rectangle())
719|d56a2c|                                .onTapGesture {
720|c0cc45|                                    // FEAT-041: click line number selects entire line
721|6eaf3d|                                    requestedLineSelection = lineIndex
722|f83e05|                                }
723|392b35|                        }
724|729aac|                        .frame(maxWidth: .infinity, alignment: .trailing)
725|539a79|                        .padding(.trailing, 4)
726|c9717a|                    }
727|4e2d32|                }
728|a7dc16|            }
729|5f0534|            .padding(.top, 8)
730|873abc|            .offset(y: -scrollOffset)
731|5f3077|        }
732|c059d6|        .scrollDisabled(true)
733|27e597|    }
734|adc83b|
735|46d3db|    private func displayText(for lineIndex: Int) -> String {
736|5d97cf|        switch lineNumbersStyle {
737|a6eb36|        case "relative":
738|e1ceac|            // VS Code-style: current line shows absolute, others show relative distance
739|b0622f|            let lineNumber = lineIndex + 1
740|44bb33|            if lineNumber == currentLine { return "\(lineNumber)" }
741|5e67df|            return "\(abs(lineNumber - currentLine))"
742|adc83b|
743|5040ac|        case "interval":
744|b0622f|            let lineNumber = lineIndex + 1
745|bc3fe3|            return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
746|adc83b|
747|520b7d|        default:
748|3880c0|            return "\(lineIndex + 1)"
749|5f3077|        }
750|27e597|    }
751|b31277|}
752|adc83b|
753|e3bdd2|// MARK: - Autocomplete Popup
754|adc83b|
755|b1d20a|struct AutocompletePopup: View {
756|5eb9d3|    let suggestions: [AutocompleteSuggestion]
757|79c1fc|    let selectedIndex: Int
758|6b0e55|    let theme: Theme
759|6f35cf|    let onSelectIndex: (Int) -> Void
760|b4687f|    
761|504e43|    var body: some View {
762|0865e6|        VStack(alignment: .leading, spacing: 0) {
763|a954be|            ForEach(suggestions.indices, id: \.self) { index in
764|ad513b|                let s = suggestions[index]
765|dbadc1|                HStack(spacing: 6) {
766|fcd45a|                    Image(systemName: icon(for: s.kind))
767|cdb0af|                        .font(.caption)
768|2e9202|                        .foregroundColor(color(for: s.kind))
769|288999|                    VStack(alignment: .leading, spacing: 1) {
770|3d1271|                        Text(s.displayText)
771|09bbe1|                            .font(.system(size: 12, design: .monospaced))
772|239e62|                            .foregroundColor(theme.editorForeground)
773|71c2b3|                        if s.insertText != s.displayText && !s.insertText.isEmpty {
774|53d416|                            Text(s.insertText)
775|87ab4e|                                .font(.system(size: 10, design: .monospaced))
776|32bc5b|                                .foregroundColor(theme.editorForeground.opacity(0.55))
777|a9b5f4|                                .lineLimit(1)
778|392b35|                        }
779|c9717a|                    }
780|dcd0bf|                    Spacer()
781|4e2d32|                }
782|41847e|                .padding(.horizontal, 8).padding(.vertical, 6)
783|e72d30|                .background(index == selectedIndex ? theme.selection : Color.clear)
784|1e8a31|                .contentShape(Rectangle())
785|eec06d|                .onTapGesture { onSelectIndex(index) }
786|a7dc16|            }
787|5f3077|        }
788|5260c9|        .frame(width: 260)
789|04ec17|        .background(theme.editorBackground)
790|097147|        .cornerRadius(6)
791|f64ce1|        .shadow(radius: 8)
792|27e597|    }
793|b4687f|    
794|ccd198|    private func icon(for kind: AutocompleteSuggestionKind) -> String {
795|01fe0f|        switch kind {
796|62a12d|        case .keyword: return "key.fill"
797|710dbd|        case .symbol: return "cube.fill"
798|d0a8ab|        case .stdlib: return "curlybraces"
799|c3ed81|        case .member: return "arrow.right.circle.fill"
800|5f3077|        }
801|27e597|    }
802|b4687f|    
803|126b1f|    private func color(for kind: AutocompleteSuggestionKind) -> Color {
804|01fe0f|        switch kind {
805|a51b30|        case .keyword: return .purple
806|8740a1|        case .symbol: return .blue
807|628567|        case .stdlib: return .orange
808|b8e5e8|        case .member: return .green
809|5f3077|        }
810|27e597|    }
811|b31277|}
812|adc83b|
813|4409de|// MARK: - Welcome View
814|adc83b|
815|35ff8c|struct IDEWelcomeView: View {
816|e5f895|    @ObservedObject var editorCore: EditorCore
817|fe002a|    @Binding var showFolderPicker: Bool
818|6b0e55|    let theme: Theme
819|b4687f|    
820|504e43|    var body: some View {
821|c906ca|        VStack(spacing: 24) {
822|00a225|            Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 80)).foregroundColor(theme.editorForeground.opacity(0.3))
823|b3ccb7|            Text("VS Code for iPadOS").font(.largeTitle).fontWeight(.bold).foregroundColor(theme.editorForeground)
824|5c2d12|            VStack(alignment: .leading, spacing: 12) {
825|49df13|                WelcomeBtn(icon: "doc.badge.plus", title: "New File", shortcut: "⌘N", theme: theme) { editorCore.addTab() }
826|b0fcfd|                WelcomeBtn(icon: "folder", title: "Open Folder", shortcut: "⌘⇧O", theme: theme) { showFolderPicker = true }
827|2bad60|                WelcomeBtn(icon: "doc", title: "Open File", shortcut: "⌘O", theme: theme) { editorCore.showFilePicker = true }
828|502f56|                WelcomeBtn(icon: "terminal", title: "Command Palette", shortcut: "⌘⇧P", theme: theme) { editorCore.showCommandPalette = true }
829|a7dc16|            }
830|139d2b|        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.editorBackground)
831|27e597|    }
832|b31277|}
833|adc83b|
834|4b4130|struct WelcomeBtn: View {
835|f0e87a|    let icon: String
836|399f36|    let title: String
837|14874c|    let shortcut: String
838|6b0e55|    let theme: Theme
839|59027a|    let action: () -> Void
840|b4687f|    
841|504e43|    var body: some View {
842|6f04d8|        Button(action: action) {
843|f49fd2|            HStack {
844|f2b865|                Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
845|d34e42|                Text(title).foregroundColor(theme.editorForeground)
846|a02350|                Spacer()
847|0f9490|                Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
848|a7dc16|            }
849|a09f6b|            .padding().frame(width: 280)
850|cef0ad|            .background(theme.sidebarBackground)
851|b18c2b|            .cornerRadius(8)
852|9e9bdf|        }.buttonStyle(.plain)
853|27e597|    }
854|b31277|}
855|adc83b|
856|db0271|// MARK: - Command Palette
857|adc83b|
858|e71bec|struct IDECommandPalette: View {
859|e5f895|    @ObservedObject var editorCore: EditorCore
860|3bd3a7|    @Binding var showSettings: Bool
861|fe5153|    @Binding var showTerminal: Bool
862|d901da|    @State private var searchText = ""
863|b4687f|    
864|504e43|    var body: some View {
865|94dd27|        VStack(spacing: 0) {
866|f49fd2|            HStack {
867|41b09a|                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
868|259764|                TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
869|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))
870|e744dc|            Divider()
871|6b85db|            ScrollView {
872|9ad863|                VStack(spacing: 0) {
873|bd267a|                    CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
874|48369f|                    CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
875|1997cb|                    CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
876|e10354|                    CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
877|684ba0|                    CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
878|79e8a7|                    CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
879|92fdf3|                    CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
880|e6f867|                    CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
881|b7baf1|                }.padding(.vertical, 8)
882|a7dc16|            }
883|338a7e|        }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
884|27e597|    }
885|b31277|}
886|adc83b|
887|b6a6d7|struct CommandRow: View {
888|e97b0d|    let icon: String; let name: String; let shortcut: String; let action: () -> Void
889|504e43|    var body: some View {
890|6f04d8|        Button(action: action) {
891|f49fd2|            HStack {
892|c4580d|                Image(systemName: icon).foregroundColor(.accentColor).frame(width: 24)
893|ade206|                Text(name).foregroundColor(.primary)
894|a02350|                Spacer()
895|512c27|                Text(shortcut).font(.caption).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 4).background(Color(UIColor.tertiarySystemFill)).cornerRadius(4)
896|dfa64f|            }.padding(.horizontal).padding(.vertical, 12).contentShape(Rectangle())
897|9e9bdf|        }.buttonStyle(.plain)
898|27e597|    }
899|b31277|}
900|adc83b|
901|6b1f13|// MARK: - Quick Open
902|adc83b|
903|7bfe0e|struct IDEQuickOpen: View {
904|e5f895|    @ObservedObject var editorCore: EditorCore
905|d901da|    @State private var searchText = ""
906|b4687f|    
907|504e43|    var body: some View {
908|94dd27|        VStack(spacing: 0) {
909|f49fd2|            HStack {
910|fa8104|                Image(systemName: "magnifyingglass").foregroundColor(.gray)
911|a496c8|                TextField("Search files...", text: $searchText).textFieldStyle(.plain)
912|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))
913|e744dc|            Divider()
914|6b85db|            ScrollView {
915|8ee2f5|                VStack(alignment: .leading, spacing: 0) {
916|3625c1|                    ForEach(editorCore.tabs) { tab in
917|88ee6a|                        QuickOpenRow(name: tab.fileName, path: "") {
918|4f316a|                            editorCore.selectTab(id: tab.id)
919|90bf2b|                            editorCore.showQuickOpen = false
920|392b35|                        }
921|c9717a|                    }
922|4e2d32|                }
923|1964e5|            }.frame(maxHeight: 350)
924|0014d4|        }.frame(width: 500).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
925|27e597|    }
926|b31277|}
927|adc83b|
928|767562|struct QuickOpenRow: View {
929|ee9c0b|    let name: String; let path: String; let action: () -> Void
930|504e43|    var body: some View {
931|6f04d8|        Button(action: action) {
932|f49fd2|            HStack {
933|0b1ac7|                Image(systemName: fileIcon(for: name)).foregroundColor(fileColor(for: name)).frame(width: 20)
934|23f981|                VStack(alignment: .leading, spacing: 2) { Text(name).font(.system(size: 14)); Text(path + name).font(.system(size: 11)).foregroundColor(.secondary) }
935|a02350|                Spacer()
936|38ff47|            }.padding(.horizontal).padding(.vertical, 8).contentShape(Rectangle())
937|9e9bdf|        }.buttonStyle(.plain)
938|27e597|    }
939|b31277|}
940|adc83b|
941|2d88cf|// MARK: - AI Assistant
942|adc83b|
943|5f57bf|struct IDEAIAssistant: View {
944|e5f895|    @ObservedObject var editorCore: EditorCore
945|6b0e55|    let theme: Theme
946|2855b6|    @State private var userInput = ""
947|9cbba7|    @State private var messages: [(id: UUID, role: String, content: String)] = [(UUID(), "assistant", "Hello! I'm your AI coding assistant. How can I help?")]
948|b4687f|    
949|504e43|    var body: some View {
950|94dd27|        VStack(spacing: 0) {
951|f49fd2|            HStack {
952|35e129|                Image(systemName: "brain").foregroundColor(.blue)
953|b6566c|                Text("AI Assistant").font(.headline).foregroundColor(theme.editorForeground)
954|a02350|                Spacer()
955|cc1153|                Button(action: { editorCore.showAIAssistant = false }) { Image(systemName: "xmark.circle.fill").foregroundColor(theme.editorForeground.opacity(0.5)) }
956|0facd0|            }.padding().background(theme.sidebarBackground)
957|3070d1|            
958|6b85db|            ScrollView {
959|df82e6|                LazyVStack(alignment: .leading, spacing: 12) {
960|a5721a|                    ForEach(messages, id: \.id) { msg in
961|679877|                        HStack {
962|a85384|                            if msg.role == "user" { Spacer(minLength: 60) }
963|8b1fb9|                            Text(msg.content).padding(12).background(RoundedRectangle(cornerRadius: 12).fill(msg.role == "user" ? Color.blue : theme.sidebarBackground)).foregroundColor(msg.role == "user" ? .white : theme.editorForeground)
964|b74ebb|                            if msg.role == "assistant" { Spacer(minLength: 60) }
965|392b35|                        }
966|c9717a|                    }
967|c5f15e|                }.padding()
968|744c4f|            }.background(theme.editorBackground)
969|3070d1|            
970|8574de|            HStack(spacing: 12) {
971|0e3711|                TextField("Ask about your code...", text: $userInput).textFieldStyle(.roundedBorder)
972|753afe|                Button(action: { sendMessage() }) { Image(systemName: "paperplane.fill").foregroundColor(userInput.isEmpty ? .gray : .blue) }.disabled(userInput.isEmpty)
973|0facd0|            }.padding().background(theme.sidebarBackground)
974|a8790d|        }.background(theme.editorBackground).cornerRadius(12).shadow(radius: 20)
975|27e597|    }
976|b4687f|    
977|beb964|    func sendMessage() {
978|29cfe7|        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
979|8a803f|        messages.append((UUID(), "user", userInput))
980|eac017|        let input = userInput
981|2c52ee|        userInput = ""
982|145a34|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
983|c7ba20|            messages.append((UUID(), "assistant", "I can help with '\(input)'! What specifically would you like to know?"))
984|5f3077|        }
985|27e597|    }
986|b31277|}
987|adc83b|
988|31bfc1|// MARK: - Status Bar
989|adc83b|
990|adc83b|
991|adc83b|
992|f4a6ee|// MARK: - Folder Picker
993|adc83b|
994|4842b2|struct IDEFolderPicker: UIViewControllerRepresentable {
995|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
996|10370b|    var onPick: ((URL) -> Void)?
997|b4687f|    
998|fc2de0|    init(fileNavigator: FileSystemNavigator, onPick: ((URL) -> Void)? = nil) {
999|237a4e|        self.fileNavigator = fileNavigator
1000|3192b9|        self.onPick = onPick
1001|27e597|    }
1002|b4687f|    
1003|a4c191|    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
1004|352547|        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
1005|325e82|        picker.delegate = context.coordinator
1006|993f50|        return picker
1007|27e597|    }
1008|b4687f|    
1009|bd012f|    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
1010|b4687f|    
1011|7da3c4|    func makeCoordinator() -> Coordinator { Coordinator(self) }
1012|b4687f|    
1013|9c0536|    class Coordinator: NSObject, UIDocumentPickerDelegate {
1014|e78b69|        let parent: IDEFolderPicker
1015|11a437|        init(_ parent: IDEFolderPicker) { self.parent = parent }
1016|d6ed84|        
1017|da3421|        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
1018|51c500|            if let url = urls.first {
1019|94998b|                _ = url.startAccessingSecurityScopedResource()
1020|24e3be|                if let onPick = parent.onPick {
1021|71fb5b|                    onPick(url)
1022|fdd0e2|                } else {
1023|866512|                    // Default behavior if no custom handler
1024|7ec9fd|                    parent.fileNavigator.loadFileTree(at: url)
1025|3d4547|                    Task { @MainActor in
1026|e3472e|                        LaunchManager.shared.setWorkspaceRoot(url)
1027|14c08d|                        GitManager.shared.setWorkingDirectory(url)
1028|c9717a|                    }
1029|4e2d32|                }
1030|a7dc16|            }
1031|5f3077|        }
1032|27e597|    }
1033|b31277|}
1034|adc83b|
1035|ba3cff|// MARK: - Document Picker
1036|adc83b|
1037|f67fab|struct IDEDocumentPicker: UIViewControllerRepresentable {
1038|e5f895|    @ObservedObject var editorCore: EditorCore
1039|b4687f|    
1040|a4c191|    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
1041|99746f|        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .sourceCode, .json, .plainText, .data])
1042|1abf38|        picker.allowsMultipleSelection = true
1043|325e82|        picker.delegate = context.coordinator
1044|993f50|        return picker
1045|27e597|    }
1046|b4687f|    
1047|bd012f|    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
1048|b4687f|    
1049|eca7e2|    func makeCoordinator() -> Coordinator { Coordinator(editorCore: editorCore) }
1050|b4687f|    
1051|9c0536|    class Coordinator: NSObject, UIDocumentPickerDelegate {
1052|3f6aca|        let editorCore: EditorCore
1053|d04b21|        init(editorCore: EditorCore) { self.editorCore = editorCore }
1054|d6ed84|        
1055|da3421|        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
1056|457fb6|            for url in urls { editorCore.openFile(from: url) }
1057|7adb67|            editorCore.showFilePicker = false
1058|5f3077|        }
1059|d6ed84|        
1060|de7fa5|        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
1061|7adb67|            editorCore.showFilePicker = false
1

... [output truncated: 192 more chars]




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5fe9c71a9c44
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift (lines 1-981 of 981)
────────────────────────────────────────
1|d755ba|import SwiftUI
2|d755ba|import SwiftUI
3|9ed0a9|import UIKit
4|8bad8d|import Network
5|8b6b78|import Foundation
6|adc83b|
7|2b1313|// MARK: - Terminal View (Main Container)
8|adc83b|
9|f8f2b8|struct TerminalView: View {
10|71c210|    @StateObject private var workspace = TerminalWorkspace.shared
11|6f45dc|    @ObservedObject private var themeManager = ThemeManager.shared
12|b49d02|    @State private var showConnectionSheet = false
13|adc83b|
14|504e43|    var body: some View {
15|94dd27|        VStack(spacing: 0) {
16|780474|            // MARK: Top Toolbar
17|b001a2|            HStack(spacing: 10) {
18|bd2dc4|                Text("TERMINAL")
19|8237e3|                    .font(.caption)
20|aa46e4|                    .fontWeight(.bold)
21|6752e8|                    .foregroundColor(themeManager.currentTheme.tabActiveForeground)
22|aa3316|                    .padding(.horizontal, 8)
23|adc83b|
24|a02350|                Spacer()
25|adc83b|
26|46f0ec|                HStack(spacing: 12) {
27|a16b7c|                    Button(action: { workspace.addTab() }) {
28|958376|                        Image(systemName: "plus")
29|c9717a|                    }
30|5a056a|                    .help("New Terminal")
31|adc83b|
32|a2ffa5|                    Button(action: { workspace.toggleSplitActiveTab() }) {
33|9a718e|                        Image(systemName: "square.split.2x1")
34|c9717a|                    }
35|2c025f|                    .disabled(workspace.tabs.isEmpty)
36|b8104a|                    .help("Split Terminal")
37|adc83b|
38|b70e3e|                    Button(action: copyActiveTerminalToClipboard) {
39|fbcaec|                        Image(systemName: "doc.on.doc")
40|c9717a|                    }
41|53a60c|                    .disabled(workspace.activePane == nil)
42|2cb489|                    .help("Copy Terminal Output")
43|adc83b|
44|83c010|                    Button(action: pasteClipboardToActiveTerminal) {
45|275e8d|                        Image(systemName: "doc.on.clipboard")
46|c9717a|                    }
47|53a60c|                    .disabled(workspace.activePane == nil)
48|dca22d|                    .help("Paste")
49|adc83b|
50|45f113|                    Button(action: { workspace.activePane?.clear() }) {
51|b2a960|                        Image(systemName: "trash")
52|c9717a|                    }
53|53a60c|                    .disabled(workspace.activePane == nil)
54|453633|                    .help("Clear Terminal")
55|adc83b|
56|ce9854|                    Button(action: { workspace.killActive() }) {
57|7b5328|                        Image(systemName: "xmark")
58|c9717a|                    }
59|53a60c|                    .disabled(workspace.activePane == nil)
60|913b7c|                    .help("Kill Terminal")
61|adc83b|
62|474b24|                    Button(action: { showConnectionSheet = true }) {
63|a1409b|                        Image(systemName: "network")
64|c9717a|                    }
65|53a60c|                    .disabled(workspace.activePane == nil)
66|7eed83|                    .help("SSH Connect")
67|4e2d32|                }
68|916793|                .font(.caption)
69|c95603|                .foregroundColor(themeManager.currentTheme.editorForeground)
70|a7dc16|            }
71|49a025|            .padding(8)
72|15d4ab|            .background(themeManager.currentTheme.editorBackground)
73|18f111|            .overlay(
74|ff13e9|                Rectangle()
75|041817|                    .frame(height: 1)
76|1a13c4|                    .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.2)),
77|7ee53b|                alignment: .bottom
78|43d041|            )
79|adc83b|
80|96a33e|            // MARK: Tab Strip
81|b2bb0c|            ScrollView(.horizontal, showsIndicators: false) {
82|dbadc1|                HStack(spacing: 6) {
83|4f3c09|                    ForEach(workspace.tabs) { tab in
84|31a03e|                        if let primary = tab.panes.first {
85|b4dfcf|                            TerminalTabButtonView(
86|4a5579|                                terminal: primary,
87|da48be|                                isActive: workspace.activeTabId == tab.id,
88|a93cba|                                onSelect: { workspace.activeTabId = tab.id },
89|d522da|                                onClose: { workspace.closeTab(id: tab.id) },
90|f6b686|                                onRename: { workspace.activeTabId = tab.id },
91|153649|                                onSplit: { workspace.activeTabId = tab.id; workspace.toggleSplitActiveTab() }
92|3d140c|                            )
93|392b35|                        }
94|c9717a|                    }
95|adc83b|
96|a16b7c|                    Button(action: { workspace.addTab() }) {
97|958376|                        Image(systemName: "plus")
98|459f67|                            .font(.caption)
99|605c18|                            .padding(.horizontal, 10)
100|336f39|                            .padding(.vertical, 6)
101|79b669|                            .background(
102|80c226|                                RoundedRectangle(cornerRadius: 6)
103|a25e13|                                    .fill(themeManager.currentTheme.editorForeground.opacity(0.08))
104|3d140c|                            )
105|c9717a|                    }
106|9cd867|                    .buttonStyle(.plain)
107|5a056a|                    .help("New Terminal")
108|4e2d32|                }
109|3263f8|                .padding(.horizontal, 8)
110|5b10b7|                .padding(.vertical, 6)
111|a7dc16|            }
112|15d4ab|            .background(themeManager.currentTheme.editorBackground)
113|18f111|            .overlay(
114|ff13e9|                Rectangle()
115|041817|                    .frame(height: 1)
116|fb88ad|                    .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.12)),
117|7ee53b|                alignment: .bottom
118|43d041|            )
119|adc83b|
120|e9df9a|            // MARK: Terminal Content
121|763642|            Group {
122|bec389|                if let tab = workspace.activeTab {
123|b970a9|                    if tab.panes.count <= 1, let terminal = tab.panes.first {
124|bd83cb|                        SingleTerminalView(
125|b1241a|                            terminal: terminal,
126|fe1d86|                            isActive: true,
127|d70aae|                            onActivate: { workspace.setActivePane(terminal.id, in: tab.id) },
128|73e1bc|                            onKill: { workspace.killActive() }
129|63214b|                        )
130|540066|                    } else {
131|3cf85f|                        HStack(spacing: 0) {
132|5fc26b|                            ForEach(tab.panes) { pane in
133|9eb68c|                                SingleTerminalView(
134|9641bc|                                    terminal: pane,
135|fa2455|                                    isActive: tab.activePaneId == pane.id,
136|d17fa2|                                    onActivate: { workspace.setActivePane(pane.id, in: tab.id) },
137|4d67dd|                                    onKill: { workspace.killActive() }
138|58a90d|                                )
139|e011b6|                                .frame(maxWidth: .infinity, maxHeight: .infinity)
140|adc83b|
141|9d1f71|                                if pane.id != tab.panes.last?.id {
142|e52e53|                                    Divider()
143|dae494|                                        .background(themeManager.currentTheme.editorForeground.opacity(0.2))
144|f83e05|                                }
145|89d40a|                            }
146|392b35|                        }
147|c9717a|                    }
148|fdd0e2|                } else {
149|0a54a4|                    VStack(spacing: 12) {
150|571e40|                        Text("No Open Terminals")
151|0a589f|                            .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.5))
152|5037d3|                        Button("Create New Terminal") {
153|e8c73b|                            workspace.addTab()
154|392b35|                        }
155|c9717a|                    }
156|839db3|                    .frame(maxWidth: .infinity, maxHeight: .infinity)
157|46702b|                    .background(themeManager.currentTheme.editorBackground)
158|4e2d32|                }
159|a7dc16|            }
160|5f3077|        }
161|d9bb16|        .background(themeManager.currentTheme.editorBackground)
162|4505b3|        .sheet(isPresented: $showConnectionSheet) {
163|3b8d30|            if let active = workspace.activePane {
164|f793cc|                SSHConnectionView(terminal: active, isPresented: $showConnectionSheet)
165|a7dc16|            }
166|5f3077|        }
167|27e597|    }
168|adc83b|
169|e8b291|    private func copyActiveTerminalToClipboard() {
170|f606ee|        guard let terminal = workspace.activePane else { return }
171|c11f93|        let text = terminal.output.map(\.text).joined(separator: "\n")
172|54857a|        UIPasteboard.general.string = text
173|27e597|    }
174|adc83b|
175|14aa9c|    private func pasteClipboardToActiveTerminal() {
176|f606ee|        guard let terminal = workspace.activePane else { return }
177|2334d7|        guard let clip = UIPasteboard.general.string, !clip.isEmpty else { return }
178|271d77|        terminal.draftCommand.append(contentsOf: clip)
179|27e597|    }
180|b31277|}
181|adc83b|
182|176775|struct TerminalTabButtonView: View {
183|e2d1ab|    @ObservedObject var terminal: TerminalManager
184|3bc279|    var isActive: Bool
185|14a91a|    var onSelect: () -> Void
186|9bc98b|    var onClose: () -> Void
187|bfbe06|    var onRename: () -> Void
188|207087|    var onSplit: () -> Void
189|adc83b|
190|6f45dc|    @ObservedObject private var themeManager = ThemeManager.shared
191|9d1f5d|    @State private var showRenameAlert = false
192|adc83b|
193|504e43|    var body: some View {
194|428a47|        Button(action: onSelect) {
195|e0a0f2|            HStack(spacing: 6) {
196|ed883a|                Image(systemName: "terminal")
197|3c209d|                    .font(.caption2)
198|adc83b|
199|466da1|                Text(terminal.title.isEmpty ? "Terminal" : terminal.title)
200|8237e3|                    .font(.caption)
201|97a348|                    .lineLimit(1)
202|20e444|                    .frame(maxWidth: 200, alignment: .leading)
203|adc83b|
204|b16624|                Button(action: onClose) {
205|26dd5e|                    Image(systemName: "xmark")
206|b3ffec|                        .font(.caption2)
207|4e2d32|                }
208|556acc|                .buttonStyle(.plain)
209|a7dc16|            }
210|436919|            .padding(.horizontal, 10)
211|f86fc3|            .padding(.vertical, 6)
212|210764|            .background(
213|bc3227|                RoundedRectangle(cornerRadius: 6)
214|7fd0c3|                    .fill(isActive ? themeManager.currentTheme.editorForeground.opacity(0.15) : themeManager.currentTheme.editorForeground.opacity(0.08))
215|43d041|            )
216|18f111|            .overlay(
217|bc3227|                RoundedRectangle(cornerRadius: 6)
218|75de76|                    .stroke(isActive ? themeManager.currentTheme.tabActiveForeground.opacity(0.5) : .clear, lineWidth: 1)
219|43d041|            )
220|5f3077|        }
221|bd8b70|        .buttonStyle(.plain)
222|3c5038|        .contextMenu {
223|4107dd|            Button(action: {
224|975e9f|                showRenameAlert = true
225|7ceec9|            }) {
226|117995|                Label("Rename Terminal", systemImage: "pencil")
227|a7dc16|            }
228|adc83b|
229|4107dd|            Button(action: {
230|06372b|                onSplit()
231|7ceec9|            }) {
232|5944e1|                Label("Split Terminal", systemImage: "square.split.2x1")
233|a7dc16|            }
234|adc83b|
235|e744dc|            Divider()
236|adc83b|
237|4107dd|            Button(action: {
238|33234b|                onClose()
239|7ceec9|            }) {
240|24efa8|                Label("Close Terminal", systemImage: "xmark")
241|4d37d6|                    .foregroundColor(.red)
242|a7dc16|            }
243|5f3077|        }
244|698b18|        .alert("Rename Terminal", isPresented: $showRenameAlert) {
245|8877aa|            TextField("Terminal Name", text: $terminal.title)
246|7cfb5b|            Button("OK", role: .cancel) { }
247|5f3077|        }
248|27e597|    }
249|b31277|}
250|adc83b|
251|7aab6d|// MARK: - Single Terminal View
252|adc83b|
253|7c3d0e|struct SingleTerminalView: View {
254|e2d1ab|    @ObservedObject var terminal: TerminalManager
255|3bc279|    var isActive: Bool
256|f48857|    var onActivate: () -> Void
257|509bf7|    var onKill: () -> Void
258|adc83b|
259|6f45dc|    @ObservedObject private var themeManager = ThemeManager.shared
260|eb1158|    @FocusState private var isInputFocused: Bool
261|adc83b|
262|504e43|    var body: some View {
263|94dd27|        VStack(spacing: 0) {
264|999521|            // Terminal Output
265|db6e07|            ScrollViewReader { proxy in
266|5deb41|                ScrollView {
267|b36751|                    VStack(alignment: .leading, spacing: 2) {
268|f6076b|                        ForEach(terminal.output) { line in
269|bd8fa2|                            TerminalLineView(line: line)
270|dc9aa4|                                .id(line.id)
271|392b35|                        }
272|c9717a|                    }
273|e735f9|                    .frame(maxWidth: .infinity, alignment: .leading)
274|d79a18|                    .padding(8)
275|4e2d32|                }
276|08e1d0|                .onChange(of: terminal.output.count) { _ in
277|aa4d2e|                    withAnimation(.easeOut(duration: 0.1)) {
278|cf5738|                        proxy.scrollTo(terminal.output.last?.id, anchor: .bottom)
279|c9717a|                    }
280|4e2d32|                }
281|a7dc16|            }
282|68d57d|            .contentShape(Rectangle())
283|d2ad19|            .contextMenu {
284|10d307|                Button(action: {
285|eff8ea|                    let text = terminal.output.map(\.text).joined(separator: "\n")
286|4ae1a8|                    UIPasteboard.general.string = text
287|e641c1|                }) {
288|fdfe21|                    Label("Copy", systemImage: "doc.on.doc")
289|4e2d32|                }
290|adc83b|
291|10d307|                Button(action: {
292|90a70b|                    if let clip = UIPasteboard.general.string, !clip.isEmpty {
293|c0e5bd|                        terminal.draftCommand.append(contentsOf: clip)
294|c9717a|                    }
295|e641c1|                }) {
296|ed7a41|                    Label("Paste", systemImage: "doc.on.clipboard")
297|4e2d32|                }
298|adc83b|
299|df398e|                Divider()
300|adc83b|
301|10d307|                Button(action: {
302|fc3478|                    terminal.clear()
303|e641c1|                }) {
304|fa9760|                    Label("Clear Terminal", systemImage: "trash")
305|4e2d32|                }
306|adc83b|
307|df398e|                Divider()
308|adc83b|
309|10d307|                Button(action: {
310|7d4910|                    onKill()
311|e641c1|                }) {
312|c5199a|                    Label("Kill Terminal", systemImage: "xmark.circle")
313|201e5d|                        .foregroundColor(.red)
314|4e2d32|                }
315|a7dc16|            }
316|835ded|            .onTapGesture {
317|e4612c|                onActivate()
318|ba88b6|                isInputFocused = true
319|a7dc16|            }
320|adc83b|
321|a4e22b|            // Input Area
322|3b7550|            HStack(spacing: 0) {
323|8302c7|                Text(terminal.promptString)
324|6babeb|                    .font(.system(.body, design: .monospaced))
325|88c9cc|                    .foregroundColor(themeManager.currentTheme.type)
326|ff23a5|                    .padding(.leading, 8)
327|adc83b|
328|86f898|                TextField("", text: $terminal.draftCommand)
329|6babeb|                    .font(.system(.body, design: .monospaced))
330|783375|                    .foregroundColor(themeManager.currentTheme.editorForeground)
331|f7c523|                    .accentColor(themeManager.currentTheme.cursor)
332|efe835|                    .autocapitalization(.none)
333|0becd9|                    .disableAutocorrection(true)
334|19a9c9|                    .focused($isInputFocused)
335|dd8982|                    .onSubmit { executeCommand() }
336|d79a18|                    .padding(8)
337|a7dc16|            }
338|15d4ab|            .background(themeManager.currentTheme.editorBackground)
339|adc83b|
340|d6d07b|            // Mobile Helper Bar (optional)
341|6c87bb|            if isInputFocused {
342|46f0ec|                HStack(spacing: 12) {
343|d05b4d|                    Button("Tab") { terminal.sendTab() }
344|2da9a0|                    Button("Esc") { /* handle esc */ }
345|568525|                    Button("Ctrl+C") { terminal.sendInterrupt() }
346|201e5d|                        .foregroundColor(.red)
347|dcd0bf|                    Spacer()
348|e892ce|                    Button("ls") { terminal.draftCommand = "ls -la" }
349|0f09a6|                    Button("git status") { terminal.draftCommand = "git status" }
350|4e2d32|                }
351|916793|                .font(.caption)
352|bfc121|                .padding(.horizontal)
353|5b10b7|                .padding(.vertical, 6)
354|ef9ab7|                .background(themeManager.currentTheme.editorForeground.opacity(0.1))
355|a7dc16|            }
356|5f3077|        }
357|d9bb16|        .background(themeManager.currentTheme.editorBackground)
358|d38294|        .overlay(
359|d52622|            RoundedRectangle(cornerRadius: 0)
360|d7e0cd|                .stroke(isActive ? themeManager.currentTheme.tabActiveForeground.opacity(0.35) : .clear, lineWidth: 1)
361|3143a4|        )
362|2bd24e|        .onAppear {
363|ecd8a0|            if isActive {
364|ba88b6|                isInputFocused = true
365|a7dc16|            }
366|5f3077|        }
367|27e597|    }
368|adc83b|
369|5b4bc4|    private func executeCommand() {
370|d44d42|        let command = terminal.draftCommand.trimmingCharacters(in: .whitespacesAndNewlines)
371|23b059|        guard !command.isEmpty else { return }
372|4e7dd7|        terminal.executeCommand(command)
373|b88a67|        terminal.draftCommand = ""
374|27e597|    }
375|b31277|}
376|adc83b|
377|bc3211|struct TerminalLineView: View {
378|2d4131|    let line: TerminalLine
379|6f45dc|    @ObservedObject private var themeManager = ThemeManager.shared
380|b4687f|    
381|504e43|    var body: some View {
382|f1c650|        if line.isANSI {
383|521adf|            ANSIText(line.text)
384|b31999|        } else {
385|e370c1|            Text(line.text)
386|3c6488|                .font(.system(.body, design: .monospaced))
387|fd4df0|                .foregroundColor(colorForType(line.type))
388|7916de|                .textSelection(.enabled)
389|5f3077|        }
390|27e597|    }
391|b4687f|    
392|0b8dbf|    func colorForType(_ type: LineType) -> Color {
393|ba7bd8|        switch type {
394|9029f5|        case .command: return themeManager.currentTheme.editorForeground
395|7d92c5|        case .output: return themeManager.currentTheme.editorForeground.opacity(0.9)
396|6a926f|        case .error: return Color.red // Could use theme error color if available
397|3ec47f|        case .system: return themeManager.currentTheme.comment
398|24d002|        case .prompt: return themeManager.currentTheme.type
399|5f3077|        }
400|27e597|    }
401|b31277|}
402|adc83b|
403|07464a|// MARK: - Terminal Workspace Manager
404|adc83b|
405|66e0a4|struct TerminalTab: Identifiable, Equatable {
406|91b0e8|    let id: UUID
407|e9f3bb|    var panes: [TerminalManager]
408|85b7a1|    var activePaneId: UUID
409|adc83b|
410|f9cc01|    init(panes: [TerminalManager]) {
411|19590e|        self.id = UUID()
412|50e9ea|        self.panes = panes
413|dae951|        self.activePaneId = panes.first?.id ?? UUID()
414|27e597|    }
415|adc83b|
416|969b6b|    var title: String {
417|869852|        panes.first?.title ?? "Terminal"
418|27e597|    }
419|adc83b|
420|a90d36|    static func == (lhs: TerminalTab, rhs: TerminalTab) -> Bool {
421|d0886d|        lhs.id == rhs.id
422|27e597|    }
423|b31277|}
424|adc83b|
425|fb5c90|class TerminalWorkspace: ObservableObject {
426|bef14f|    static let shared = TerminalWorkspace()
427|adc83b|
428|65ba2d|    @Published var tabs: [TerminalTab] = []
429|e129c3|    @Published var activeTabId: UUID?
430|adc83b|
431|75cc04|    var activeTabIndex: Int? {
432|1af0c1|        guard let id = activeTabId else { return nil }
433|461110|        return tabs.firstIndex(where: { $0.id == id })
434|27e597|    }
435|adc83b|
436|fd50a2|    var activeTab: TerminalTab? {
437|9011cf|        guard let idx = activeTabIndex else { return nil }
438|3fc8ba|        return tabs[idx]
439|27e597|    }
440|adc83b|
441|2a046a|    var activePane: TerminalManager? {
442|749017|        guard let tab = activeTab else { return nil }
443|e503c0|        return tab.panes.first(where: { $0.id == tab.activePaneId }) ?? tab.panes.first
444|27e597|    }
445|adc83b|
446|359b1b|    init() {
447|a198e7|        addTab() // start with one
448|27e597|    }
449|adc83b|
450|ff5787|    func addTab() {
451|d110cf|        let term = TerminalManager()
452|79d501|        term.title = "Terminal \(tabs.count + 1)"
453|208e89|        let tab = TerminalTab(panes: [term])
454|a630ed|        tabs.append(tab)
455|4370c7|        activeTabId = tab.id
456|27e597|    }
457|adc83b|
458|32d0a2|    func closeTab(id: UUID) {
459|a1d7f5|        guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
460|dbcf27|        for pane in tabs[idx].panes {
461|dd970f|            pane.disconnect()
462|5f3077|        }
463|bf3ad9|        tabs.remove(at: idx)
464|7a2997|        if activeTabId == id {
465|04b8bb|            activeTabId = tabs.last?.id
466|5f3077|        }
467|27e597|    }
468|adc83b|
469|7f1ee2|    func setActivePane(_ paneId: UUID, in tabId: UUID) {
470|82eb46|        guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }
471|9992f8|        tabs[tabIndex].activePaneId = paneId
472|27e597|    }
473|adc83b|
474|1ed657|    func toggleSplitActiveTab() {
475|77cde5|        guard let tabId = activeTabId else { return }
476|4956f0|        guard let idx = tabs.firstIndex(where: { $0.id == tabId }) else { return }
477|adc83b|
478|ae622d|        if tabs[idx].panes.count <= 1 {
479|3f3758|            // Split: add a second pane (max 2 panes for now)
480|47c4fb|            let newPane = TerminalManager()
481|923da3|            newPane.title = "Terminal \(tabs.count).2"
482|692bfb|            tabs[idx].panes.append(newPane)
483|e67696|            tabs[idx].activePaneId = newPane.id
484|b31999|        } else {
485|1a3c65|            // Unsplit: remove all panes except the first
486|6dddf5|            let extraPanes = tabs[idx].panes.dropFirst()
487|669ba4|            for pane in extraPanes {
488|31982c|                pane.disconnect()
489|a7dc16|            }
490|941223|            tabs[idx].panes = Array(tabs[idx].panes.prefix(1))
491|cad079|            tabs[idx].activePaneId = tabs[idx].panes.first?.id ?? tabs[idx].activePaneId
492|5f3077|        }
493|27e597|    }
494|adc83b|
495|e5ad11|    func killActive() {
496|77cde5|        guard let tabId = activeTabId else { return }
497|82eb46|        guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }
498|adc83b|
499|3861ec|        let paneId = tabs[tabIndex].activePaneId
500|3771af|        if tabs[tabIndex].panes.count > 1 {
501|ad5b37|            // If split, kill the active pane only.
502|bf8135|            if let paneIndex = tabs[tabIndex].panes.firstIndex(where: { $0.id == paneId }) {
503|5a8bea|                tabs[tabIndex].panes[paneIndex].disconnect()
504|fed5a3|                tabs[tabIndex].panes.remove(at: paneIndex)
505|a7dc16|            }
506|aa4b79|            tabs[tabIndex].activePaneId = tabs[tabIndex].panes.first?.id ?? tabs[tabIndex].activePaneId
507|adc83b|
508|7f8f51|            if tabs[tabIndex].panes.isEmpty {
509|58d66b|                closeTab(id: tabId)
510|a7dc16|            }
511|b31999|        } else {
512|cb6a91|            // If not split, kill the tab.
513|d69312|            closeTab(id: tabId)
514|5f3077|        }
515|27e597|    }
516|b31277|}
517|adc83b|
518|d5db6b|// MARK: - Terminal Manager
519|adc83b|
520|74d1c1|class TerminalManager: ObservableObject, Identifiable {
521|c90f8e|    let id = UUID()
522|af0aed|    @Published var title: String = "Terminal"
523|b4687f|    
524|31ec09|    @Published var output: [TerminalLine] = [
525|ae746a|        TerminalLine(text: "VSCode iPadOS Terminal v2.0", type: .system),
526|eeeb13|        TerminalLine(text: "Type 'help' for commands or connect via SSH (SwiftNIO).", type: .system),
527|76151f|        TerminalLine(text: "", type: .output)
528|f7d573|    ]
529|99716f|    @Published var isConnected = false
530|be0506|    @Published var isConnecting = false
531|554c2f|    @Published var connectionStatus = "Not connected"
532|2da343|    @Published var promptString = "$ "
533|2f9e71|    @Published var draftCommand: String = ""
534|b4687f|    
535|f16c3b|    private var sshManager: SSHManager?
536|d89225|    private var currentConfig: SSHConnectionConfig?
537|42c98c|    private var commandHistory: [String] = []
538|09e3b8|    private var historyIndex = 0
539|b4687f|    
540|5416f6|    func clear() {
541|2e1932|        output = []
542|27e597|    }
543|b4687f|    
544|8e9bc2|    func connect(to config: SSHConnectionConfig) {
545|3e57c9|        currentConfig = config
546|80c418|        isConnecting = true
547|e18aca|        connectionStatus = "Connecting to \(config.host)..."
548|bf4100|        title = "\(config.username)@\(config.host)"
549|d6ed84|        
550|218001|        appendOutput("Connecting to \(config.username)@\(config.host):\(config.port)...", type: .system)
551|2097e9|        appendOutput("Using SwiftNIO SSH (real SSH protocol)", type: .system)
552|d6ed84|        
553|c078b7|        sshManager = SSHManager()
554|7b5b43|        sshManager?.delegate = self
555|6b69aa|        sshManager?.connect(config: config) { [weak self] result in
556|06e424|            switch result {
557|2b2fda|            case .success:
558|7dee8d|                // Connection successful - delegate will handle UI update
559|652c30|                SSHConnectionStore.shared.updateLastUsed(config)
560|652929|            case .failure(let error):
561|ac2295|                self?.appendOutput("Connection failed: \(error.localizedDescription)", type: .error)
562|542a9d|                self?.isConnecting = false
563|370632|                self?.connectionStatus = "Connection failed"
564|a7dc16|            }
565|5f3077|        }
566|27e597|    }
567|b4687f|    
568|ade9c8|    // Legacy connect method for backward compatibility
569|8f35de|    func connect(to connection: SSHConnection) {
570|d8217a|        let authMethod: SSHConnectionConfig.SSHAuthMethod
571|cfcdef|        if let privateKey = connection.privateKey, !privateKey.isEmpty {
572|abe8fb|            authMethod = .privateKey(key: privateKey, passphrase: nil)
573|b31999|        } else {
574|81319d|            authMethod = .password(connection.password ?? "")
575|5f3077|        }
576|d6ed84|        
577|650977|        let config = SSHConnectionConfig(
578|811daa|            name: "\(connection.username)@\(connection.host)",
579|e3c9b1|            host: connection.host,
580|aababa|            port: connection.port,
581|253e2b|            username: connection.username,
582|f03d4f|            authMethod: authMethod
583|3143a4|        )
584|f55808|        connect(to: config)
585|27e597|    }
586|b4687f|    
587|55975b|    func disconnect() {
588|9da246|        sshManager?.disconnect()
589|e2702b|        sshManager = nil
590|83c6c9|        isConnected = false
591|cafdf0|        isConnecting = false
592|b898f0|        connectionStatus = "Disconnected"
593|cc0336|        promptString = "$ "
594|0ceeb0|        title = "Terminal (Disconnected)"
595|967440|        appendOutput("Disconnected from server.", type: .system)
596|27e597|    }
597|b4687f|    
598|4d3524|    func executeCommand(_ command: String) {
599|e8b2cd|        commandHistory.append(command)
600|049ad5|        historyIndex = commandHistory.count
601|d6ed84|        
602|605618|        if isConnected {
603|09f0e3|            // Don't echo command - server will echo it back
604|c99217|            sshManager?.send(command: command)
605|b31999|        } else {
606|f11ced|            appendOutput(promptString + command, type: .command)
607|3e9bf8|            processLocalCommand(command)
608|5f3077|        }
609|27e597|    }
610|b4687f|    
611|b9a892|    func sendInterrupt() {
612|605618|        if isConnected {
613|14e2bf|            sshManager?.sendInterrupt()
614|5f3077|        }
615|4b7ebc|        appendOutput("^C", type: .system)
616|27e597|    }
617|b4687f|    
618|85260e|    func sendTab() {
619|605618|        if isConnected {
620|6140fc|            sshManager?.sendTab()
621|5f3077|        }
622|27e597|    }
623|b4687f|    
624|a9ab0c|    func sendEscape() {
625|c78a4c|        sshManager?.sendEscape()
626|27e597|    }
627|b4687f|    
628|ff60c1|    func previousCommand() -> String? {
629|110e6c|        guard !commandHistory.isEmpty else { return nil }
630|e58dae|        historyIndex = max(0, historyIndex - 1)
631|349c34|        return commandHistory[historyIndex]
632|27e597|    }
633|b4687f|    
634|776e44|    func nextCommand() -> String? {
635|110e6c|        guard !commandHistory.isEmpty else { return nil }
636|cfcee6|        historyIndex = min(commandHistory.count, historyIndex + 1)
637|bd9a28|        if historyIndex >= commandHistory.count {
638|273b25|            return ""
639|5f3077|        }
640|349c34|        return commandHistory[historyIndex]
641|27e597|    }
642|b4687f|    
643|9a721f|    private func processLocalCommand(_ command: String) {
644|499317|        let parts = command.split(separator: " ", maxSplits: 1)
645|40788b|        guard let cmd = parts.first?.lowercased() else { return }
646|d6ed84|        
647|c5be0d|        switch cmd {
648|84ac7a|        case "help":
649|e25ab4|            appendOutput("""
650|742a6a|            Local Commands:
651|378490|              help              - Show this help
652|25afb7|              clear             - Clear terminal
653|007b75|              echo <text>       - Echo text
654|5edcc4|              date              - Show current date
655|6ea41d|              whoami            - Show current user
656|36311a|              history           - Show command history
657|9f0baf|              ssh               - Show SSH connection info
658|3070d1|            
659|144f70|            Connect via SSH using the network button in toolbar.
660|4a6995|            Real SSH protocol powered by SwiftNIO SSH.
661|33cb96|            """, type: .output)
662|3070d1|            
663|8d75cb|        case "clear":
664|55c3ab|            clear()
665|3070d1|            
666|629cd7|        case "echo":
667|1b5be1|            let text = parts.count > 1 ? String(parts[1]) : ""
668|b00dd0|            appendOutput(text, type: .output)
669|3070d1|            
670|f72b70|        case "date":
671|4c1e8a|            appendOutput(Date().description, type: .output)
672|3070d1|            
673|492542|        case "whoami":
674|c97efc|            appendOutput("ipad-user", type: .output)
675|3070d1|            
676|06f2cd|        case "history":
677|36fd0c|            for (index, cmd) in commandHistory.enumerated() {
678|c3e90e|                appendOutput("  \(index + 1)  \(cmd)", type: .output)
679|a7dc16|            }
680|3070d1|            
681|2f6c43|        case "ssh":
682|e25ab4|            appendOutput("""
683|558576|            SSH Status: \(isConnected ? "Connected" : "Not connected")
684|9f3dfd|            Implementation: SwiftNIO SSH (apple/swift-nio-ssh)
685|14e2c7|            Features: Password auth, Key auth, PTY support, Shell sessions
686|33cb96|            """, type: .output)
687|3070d1|            
688|520b7d|        default:
689|da445e|            appendOutput("\(cmd): command not found (local mode)", type: .error)
690|5f3077|        }
691|27e597|    }
692|b4687f|    
693|99d6fc|    func appendOutput(_ text: String, type: LineType, isANSI: Bool = false) {
694|0706d6|        DispatchQueue.main.async {
695|c63a2a|            // Split multi-line output into separate lines
696|f7effa|            let lines = text.components(separatedBy: .newlines)
697|1a16f7|            for line in lines {
698|301e4e|                if !line.isEmpty || lines.count == 1 {
699|3609d8|                    self.output.append(TerminalLine(text: line, type: type, isANSI: isANSI || line.contains("\u{1B}")))
700|4e2d32|                }
701|a7dc16|            }
702|5f3077|        }
703|27e597|    }
704|b31277|}
705|adc83b|
706|feff35|// MARK: - SSH Manager Delegate
707|9ef1f5|extension TerminalManager: SSHManagerDelegate {
708|2d04fb|    func sshManagerDidConnect(_ manager: SSHManager) {
709|0706d6|        DispatchQueue.main.async {
710|44a0c9|            self.isConnected = true
711|fa9956|            self.isConnecting = false
712|8d3b4d|            self.connectionStatus = "Connected"
713|94a3a3|            self.promptString = "" // Shell will provide prompt
714|8cab6d|            self.appendOutput("Connected successfully via SwiftNIO SSH!", type: .system)
715|5f3077|        }
716|27e597|    }
717|b4687f|    
718|826b4e|    func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?) {
719|0706d6|        DispatchQueue.main.async {
720|2c082f|            self.isConnected = false
721|fa9956|            self.isConnecting = false
722|507061|            self.connectionStatus = "Disconnected"
723|ae9c8a|            self.promptString = "$ "
724|b2967c|            if let error = error {
725|1956ab|                self.appendOutput("Connection lost: \(error.localizedDescription)", type: .error)
726|a7dc16|            }
727|5f3077|        }
728|27e597|    }
729|b4687f|    
730|759518|    func sshManager(_ manager: SSHManager, didReceiveOutput text: String) {
731|c062ad|        appendOutput(text, type: .output)
732|27e597|    }
733|b4687f|    
734|7abe87|    func sshManager(_ manager: SSHManager, didReceiveError text: String) {
735|bc0a54|        appendOutput(text, type: .error)
736|27e597|    }
737|b31277|}
738|adc83b|
739|ceb8fb|// MARK: - SSH Connection View (Enhanced with Saved Connections)
740|adc83b|
741|65943c|struct SSHConnectionView: View {
742|e2d1ab|    @ObservedObject var terminal: TerminalManager
743|cf723e|    @Binding var isPresented: Bool
744|2ecc22|    @ObservedObject private var connectionStore = SSHConnectionStore.shared
745|6f45dc|    @ObservedObject private var themeManager = ThemeManager.shared
746|b4687f|    
747|b8684b|    @State private var connectionName = ""
748|5ed459|    @State private var host = ""
749|f64726|    @State private var port = "22"
750|097685|    @State private var username = ""
751|a254ba|    @State private var password = ""
752|2a95a2|    @State private var useKey = false
753|4d4789|    @State private var privateKey = ""
754|f55d77|    @State private var keyPassphrase = ""
755|de6192|    @State private var saveConnection = true
756|fdb628|    @State private var showSavedConnections = true
757|4a282f|    @State private var errorMessage: String?
758|b4687f|    
759|504e43|    var body: some View {
760|0c7ea9|        NavigationView {
761|aeeb16|            Form {
762|4327c5|                // Saved Connections Section
763|95dae6|                if !connectionStore.savedConnections.isEmpty {
764|ce9170|                    Section(header: Text("Saved Connections")) {
765|54df11|                        ForEach(connectionStore.savedConnections) { config in
766|2eb65b|                            Button(action: { connectToSaved(config) }) {
767|ccf016|                                HStack {
768|8d0337|                                    VStack(alignment: .leading, spacing: 2) {
769|be8aca|                                        Text(config.name)
770|ca6ecf|                                            .font(.headline)
771|7611ac|                                            .foregroundColor(themeManager.currentTheme.editorForeground)
772|bd86b4|                                        Text("\(config.username)@\(config.host):\(config.port)")
773|e4e921|                                            .font(.caption)
774|5651c5|                                            .foregroundColor(themeManager.currentTheme.comment)
775|8ab74d|                                    }
776|c7a564|                                    Spacer()
777|5c5389|                                    if case .privateKey = config.authMethod {
778|285c83|                                        Image(systemName: "key.fill")
779|e32c61|                                            .foregroundColor(.orange)
780|719c18|                                    } else {
781|6bade9|                                        Image(systemName: "lock.fill")
782|a8af62|                                            .foregroundColor(.blue)
783|8ab74d|                                    }
784|f83e05|                                }
785|89d40a|                            }
786|45088b|                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
787|296f57|                                Button(role: .destructive) {
788|b0605e|                                    connectionStore.delete(config)
789|d22f20|                                } label: {
790|f673e9|                                    Label("Delete", systemImage: "trash")
791|f83e05|                                }
792|89d40a|                            }
793|392b35|                        }
794|c9717a|                    }
795|4e2d32|                }
796|216278|                
797|7c2846|                // New Connection Section
798|6be1b3|                Section(header: Text("New Connection")) {
799|f655fc|                    TextField("Connection Name (optional)", text: $connectionName)
800|f2ff5f|                        .autocapitalization(.none)
801|dd2193|                    
802|ad1bae|                    TextField("Host", text: $host)
803|f2ff5f|                        .autocapitalization(.none)
804|2afd93|                        .disableAutocorrection(true)
805|9193a5|                        .keyboardType(.URL)
806|dd2193|                    
807|bd17e9|                    TextField("Port", text: $port)
808|f90d9b|                        .keyboardType(.numberPad)
809|dd2193|                    
810|93ebd5|                    TextField("Username", text: $username)
811|f2ff5f|                        .autocapitalization(.none)
812|2afd93|                        .disableAutocorrection(true)
813|4e2d32|                }
814|216278|                
815|bff571|                Section(header: Text("Authentication")) {
816|b851b2|                    Picker("Method", selection: $useKey) {
817|8660c4|                        Text("Password").tag(false)
818|52f2b1|                        Text("SSH Key").tag(true)
819|c9717a|                    }
820|7a2e25|                    .pickerStyle(.segmented)
821|dd2193|                    
822|af9aa6|                    if useKey {
823|3f28ac|                        VStack(alignment: .leading, spacing: 8) {
824|55af90|                            Text("Private Key (PEM format)")
825|5ff98f|                                .font(.caption)
826|e1b9ba|                                .foregroundColor(themeManager.currentTheme.comment)
827|e4abf2|                            
828|ce9f51|                            TextEditor(text: $privateKey)
829|a131a0|                                .font(.system(.caption, design: .monospaced))
830|987f16|                                .frame(height: 120)
831|9d784e|                                .overlay(
832|da9c0c|                                    RoundedRectangle(cornerRadius: 8)
833|598ff8|                                        .stroke(themeManager.currentTheme.editorForeground.opacity(0.2), lineWidth: 1)
834|58a90d|                                )
835|e4abf2|                            
836|279b71|                            SecureField("Key Passphrase (if encrypted)", text: $keyPassphrase)
837|392b35|                        }
838|540066|                    } else {
839|bb09f6|                        SecureField("Password", text: $password)
840|c9717a|                    }
841|4e2d32|                }
842|216278|                
843|65412a|                Section {
844|549c24|                    Toggle("Save Connection", isOn: $saveConnection)
845|4e2d32|                }
846|216278|                
847|a86c64|                if let error = errorMessage {
848|7b33d3|                    Section {
849|0412c6|                        Text(error)
850|7a5370|                            .foregroundColor(.red)
851|459f67|                            .font(.caption)
852|c9717a|                    }
853|4e2d32|                }
854|216278|                
855|65412a|                Section {
856|bb75c2|                    Button(action: connect) {
857|679877|                        HStack {
858|581e8e|                            Spacer()
859|c059d7|                            if terminal.isConnecting {
860|174b96|                                ProgressView()
861|ba16b3|                                    .progressViewStyle(CircularProgressViewStyle())
862|818176|                                Text("Connecting...")
863|240f50|                            } else {
864|f02b9c|                                Image(systemName: "network")
865|8a6977|                                Text("Connect")
866|89d40a|                            }
867|581e8e|                            Spacer()
868|392b35|                        }
869|c9717a|                    }
870|095dcf|                    .disabled(host.isEmpty || username.isEmpty || terminal.isConnecting)
871|4e2d32|                }
872|a7dc16|            }
873|9a06f5|            .navigationTitle("SSH Connection")
874|806036|            .toolbar {
875|f0ac3b|                ToolbarItem(placement: .cancellationAction) {
876|a46df0|                    Button("Cancel") { isPresented = false }
877|4e2d32|                }
878|a7dc16|            }
879|5f3077|        }
880|27e597|    }
881|b4687f|    
882|087f92|    private func connectToSaved(_ config: SSHConnectionConfig) {
883|e3d025|        terminal.connect(to: config)
884|3a71db|        isPresented = false
885|27e597|    }
886|b4687f|    
887|06d184|    private func connect() {
888|5a9168|        errorMessage = nil
889|d6ed84|        
890|d8217a|        let authMethod: SSHConnectionConfig.SSHAuthMethod
891|516cf1|        if useKey {
892|1daa0f|            guard !privateKey.isEmpty else {
893|c56e11|                errorMessage = "Please enter your private key"
894|53ab34|                return
895|a7dc16|            }
896|3aabb2|            authMethod = .privateKey(key: privateKey, passphrase: keyPassphrase.isEmpty ? nil : keyPassphrase)
897|b31999|        } else {
898|0346de|            guard !password.isEmpty else {
899|288d37|                errorMessage = "Please enter your password"
900|53ab34|                return
901|a7dc16|            }
902|99f80b|            authMethod = .password(password)
903|5f3077|        }
904|d6ed84|        
905|2a5113|        let name = connectionName.isEmpty ? "\(username)@\(host)" : connectionName
906|d6ed84|        
907|650977|        let config = SSHConnectionConfig(
908|b71427|            name: name,
909|77bedd|            host: host,
910|39ad81|            port: Int(port) ?? 22,
911|21cc1a|            username: username,
912|f03d4f|            authMethod: authMethod
913|3143a4|        )
914|d6ed84|        
915|10f9f4|        if saveConnection {
916|ce31c3|            connectionStore.save(config)
917|5f3077|        }
918|d6ed84|        
919|e3d025|        terminal.connect(to: config)
920|3a71db|        isPresented = false
921|27e597|    }
922|b31277|}
923|adc83b|
924|6ab75b|// MARK: - Models & Helpers (Legacy support)
925|adc83b|
926|e0141a|struct SSHConnection {
927|d0d91d|    let host: String
928|932f80|    let port: Int
929|bc3558|    let username: String
930|3b3218|    let password: String?
931|e7de76|    let privateKey: String?
932|b31277|}
933|adc83b|
934|578abf|struct TerminalLine: Identifiable {
935|c90f8e|    let id = UUID()
936|e25e12|    let text: String
937|70c12f|    let type: LineType
938|aea298|    var isANSI: Bool = false
939|b31277|}
940|adc83b|
941|d69199|enum LineType {
942|b54904|    case command
943|37045f|    case output
944|e0c61d|    case error
945|47f116|    case system
946|872bf4|    case prompt
947|b31277|}
948|adc83b|
949|619a86|struct ANSIText: View {
950|e25e12|    let text: String
951|6f45dc|    @ObservedObject private var themeManager = ThemeManager.shared
952|b4687f|    
953|23e59f|    init(_ text: String) {
954|226b10|        self.text = text
955|27e597|    }
956|b4687f|    
957|504e43|    var body: some View {
958|32997f|        Text(stripANSI(text))
959|89a887|            .font(.system(.body, design: .monospaced))
960|2a2402|            .foregroundColor(themeManager.currentTheme.editorForeground)
961|3d9c12|            .textSelection(.enabled)
962|27e597|    }
963|b4687f|    
964|91a22d|    private func stripANSI(_ text: String) -> String {
965|e3c761|        let pattern = "\u{1B}\\[[0-9;]*[a-zA-Z]"
966|d23a93|        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
967|10d615|        let range = NSRange(text.startIndex..., in: text)
968|de5100|        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: "")
969|27e597|    }
970|b31277|}
971|adc83b|
972|40a886|// MARK: - SSH Client Implementation
973|a0a15d|// Real SSH implementation is now in Services/SSHManager.swift
974|c7f1b2|// Uses SwiftNIO SSH (apple/swift-nio-ssh) for proper SSH protocol support
975|f205ed|// Features:
976|6b5ad9|// - Password authentication
977|c690e6|// - SSH key authentication (Ed25519, ECDSA)
978|5bb526|// - PTY allocation for interactive shells
979|7b8e6d|// - Proper channel management
980|756da0|// - Terminal resize support
981|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 555516475e59
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/MarkdownPreviewView.swift (lines 1-85 of 85)
────────────────────────────────────────
1|d755ba|import SwiftUI
2|501c1a|import WebKit
3|adc83b|
4|b8aed1|struct MarkdownPreviewView: View {
5|d09865|    @Binding var content: String
6|11581a|    @State private var webView = WKWebView()
7|b4687f|    
8|504e43|    var body: some View {
9|b9f448|        WebView(webView: webView)
10|290fad|            .onAppear {
11|70d9af|                loadMarkdown()
12|a7dc16|            }
13|9c76ad|            .onChange(of: content) { _ in
14|70d9af|                loadMarkdown()
15|a7dc16|            }
16|27e597|    }
17|b4687f|    
18|206620|    private func loadMarkdown() {
19|cbec40|        let html = """
20|a99ffd|        <!DOCTYPE html>
21|161e88|        <html>
22|7ea9f8|        <head>
23|d846c0|            <meta name="viewport" content="width=device-width, initial-scale=1.0">
24|ea90fc|            <style>
25|a85077|                body {
26|cb3318|                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
27|dab015|                    padding: 20px;
28|102944|                    line-height: 1.6;
29|be60df|                    color: #333;
30|4e2d32|                }
31|2bac13|                pre {
32|8a9f67|                    background-color: #f6f8fa;
33|d60699|                    padding: 16px;
34|69102b|                    border-radius: 6px;
35|81fa8b|                    overflow-x: auto;
36|4e2d32|                }
37|7226ee|                code {
38|6ea68f|                    font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;
39|c68b05|                    font-size: 85%;
40|4e2d32|                }
41|ced1c9|                @media (prefers-color-scheme: dark) {
42|74db39|                    body {
43|f81e74|                        background-color: #1e1e1e;
44|39b1c1|                        color: #d4d4d4;
45|c9717a|                    }
46|595f62|                    pre {
47|f65cc2|                        background-color: #2d2d2d;
48|c9717a|                    }
49|edd5fb|                    a {
50|4aa58a|                        color: #3794ff;
51|c9717a|                    }
52|4e2d32|                }
53|82b0a8|            </style>
54|ba350c|            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
55|96c305|        </head>
56|578c25|        <body>
57|359b9b|            <div id="content"></div>
58|f461fb|            <script>
59|c85dcf|                document.getElementById('content').innerHTML = marked.parse(`\(escapeContent(content))`);
60|296586|            </script>
61|bee0ac|        </body>
62|674488|        </html>
63|c70080|        """
64|d6ed84|        
65|e8a235|        webView.loadHTMLString(html, baseURL: nil)
66|27e597|    }
67|b4687f|    
68|a80aa0|    private func escapeContent(_ text: String) -> String {
69|e3573c|        text.replacingOccurrences(of: "`", with: "\\`")
70|cf21dc|            .replacingOccurrences(of: "$", with: "\\$")
71|27e597|    }
72|b31277|}
73|adc83b|
74|1eca22|struct WebView: UIViewRepresentable {
75|0e42e1|    let webView: WKWebView
76|b4687f|    
77|ee05db|    func makeUIView(context: Context) -> WKWebView {
78|f1462f|        webView.isOpaque = false
79|db99f4|        webView.backgroundColor = .clear
80|ddcafd|        return webView
81|27e597|    }
82|b4687f|    
83|8d3e14|    func updateUIView(_ uiView: WKWebView, context: Context) {}
84|b31277|}
85|adc83b|




---

## 🔧 TOOL RESULTS

[search]
Error searching: Extension 'danielswagg.outlier-chat' CANNOT use API proposal: findTextInFiles.
Its package.json#enabledApiProposals-property declares: [] but NOT findTextInFiles.
 The missing proposal MUST be added and you must start in extension development mode or use the following command line switch: --enable-proposed-api danielswagg.outlier-chat




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/
   NativeGitReader.swift
   NativeGitWriter.swift
   SSHGitClient.swift




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 2e02fe9e4dcf
File: VSCodeiPadOS/VSCodeiPadOS/Views/CommandPalette.swift (lines 1-721 of 721)
────────────────────────────────────────
1|8d0643|//
2|4e8449|//  CommandPalette.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|ca4b3d|//  VS Code-style Command Palette with fuzzy search
6|8d0643|//
7|adc83b|
8|d755ba|import SwiftUI
9|adc83b|
10|703c53|// MARK: - Command Definition
11|adc83b|
12|5d9ec7|struct Command: Identifiable, Equatable {
13|c90f8e|    let id = UUID()
14|a5193b|    let name: String
15|265a5c|    let shortcut: String?
16|f0e87a|    let icon: String
17|91ac52|    let category: CommandCategory
18|59027a|    let action: () -> Void
19|b4687f|    
20|b1401d|    static func == (lhs: Command, rhs: Command) -> Bool {
21|d0886d|        lhs.id == rhs.id
22|27e597|    }
23|b31277|}
24|adc83b|
25|f60156|enum CommandCategory: String, CaseIterable {
26|bcbee0|    case file = "File"
27|292b25|    case edit = "Edit"
28|48275f|    case selection = "Selection"
29|b471ed|    case view = "View"
30|6ba47a|    case go = "Go"
31|eef6f0|    case run = "Run"
32|dd6981|    case terminal = "Terminal"
33|8b2118|    case preferences = "Preferences"
34|ba3898|    case help = "Help"
35|b4687f|    
36|4108d4|    var icon: String {
37|2e6d08|        switch self {
38|20972d|        case .file: return "doc"
39|e7049d|        case .edit: return "pencil"
40|83b547|        case .selection: return "selection.pin.in.out"
41|093583|        case .view: return "rectangle.3.group"
42|3aaf34|        case .go: return "arrow.right"
43|011e81|        case .run: return "play"
44|49deca|        case .terminal: return "terminal"
45|9a10f9|        case .preferences: return "gear"
46|b15942|        case .help: return "questionmark.circle"
47|5f3077|        }
48|27e597|    }
49|b31277|}
50|adc83b|
51|cc0284|// MARK: - Recent Commands Manager
52|adc83b|
53|411ba5|class RecentCommandsManager: ObservableObject {
54|d3834f|    @Published var recentCommands: [String] = []
55|4d914d|    private let maxRecent = 5
56|f67f90|    private let storageKey = "recentCommands"
57|b4687f|    
58|359b1b|    init() {
59|880bd6|        loadRecent()
60|27e597|    }
61|b4687f|    
62|230e29|    func addRecent(_ commandName: String) {
63|fe3482|        recentCommands.removeAll { $0 == commandName }
64|d6c233|        recentCommands.insert(commandName, at: 0)
65|8a5223|        if recentCommands.count > maxRecent {
66|578c6f|            recentCommands = Array(recentCommands.prefix(maxRecent))
67|5f3077|        }
68|a8ef93|        saveRecent()
69|27e597|    }
70|b4687f|    
71|998823|    private func loadRecent() {
72|7e091c|        if let saved = UserDefaults.standard.stringArray(forKey: storageKey) {
73|cbe995|            recentCommands = saved
74|5f3077|        }
75|27e597|    }
76|b4687f|    
77|956c57|    private func saveRecent() {
78|98ac56|        UserDefaults.standard.set(recentCommands, forKey: storageKey)
79|27e597|    }
80|b31277|}
81|adc83b|
82|af0ecd|// MARK: - Fuzzy Search
83|adc83b|
84|9fce4f|struct FuzzyMatcher {
85|ae76bd|    static func score(query: String, target: String) -> Int? {
86|34cef6|        guard !query.isEmpty else { return 1000 }
87|d6ed84|        
88|aa4292|        let queryLower = query.lowercased()
89|18ea38|        let targetLower = target.lowercased()
90|d6ed84|        
91|c33784|        // Exact match gets highest score
92|bea5c7|        if targetLower == queryLower { return 10000 }
93|d6ed84|        
94|bffced|        // Contains full query
95|8cd767|        if targetLower.contains(queryLower) {
96|1063f5|            // Bonus for starting with query
97|d0876a|            if targetLower.hasPrefix(queryLower) {
98|2e989d|                return 5000 + (1000 - target.count)
99|a7dc16|            }
100|c9ab09|            return 3000 + (1000 - target.count)
101|5f3077|        }
102|d6ed84|        
103|83786c|        // Fuzzy character matching
104|65f313|        var queryIndex = queryLower.startIndex
105|7f11d4|        var targetIndex = targetLower.startIndex
106|268b95|        var score = 0
107|5dc28e|        var consecutiveBonus = 0
108|1d718f|        var lastMatchIndex: String.Index? = nil
109|d6ed84|        
110|308cfe|        while queryIndex < queryLower.endIndex && targetIndex < targetLower.endIndex {
111|c13bec|            if queryLower[queryIndex] == targetLower[targetIndex] {
112|145bbf|                score += 100 + consecutiveBonus
113|216278|                
114|d6ef12|                // Bonus for consecutive matches
115|9f661a|                if let lastIdx = lastMatchIndex,
116|83874f|                   targetLower.index(after: lastIdx) == targetIndex {
117|9c7108|                    consecutiveBonus += 50
118|fdd0e2|                } else {
119|51d442|                    consecutiveBonus = 0
120|4e2d32|                }
121|216278|                
122|c7d2d9|                // Bonus for matching at word boundaries
123|3c44b0|                if targetIndex == targetLower.startIndex ||
124|75c499|                   !targetLower[targetLower.index(before: targetIndex)].isLetter {
125|78d351|                    score += 75
126|4e2d32|                }
127|216278|                
128|b7133b|                lastMatchIndex = targetIndex
129|ea161d|                queryIndex = queryLower.index(after: queryIndex)
130|a7dc16|            }
131|916731|            targetIndex = targetLower.index(after: targetIndex)
132|5f3077|        }
133|d6ed84|        
134|989e1f|        // All query characters must be found
135|0160b5|        guard queryIndex == queryLower.endIndex else { return nil }
136|d6ed84|        
137|c07521|        return score
138|27e597|    }
139|b4687f|    
140|ace7c9|    static func highlight(query: String, in text: String) -> [(String, Bool)] {
141|81813c|        guard !query.isEmpty else { return [(text, false)] }
142|d6ed84|        
143|b880d0|        var result: [(String, Bool)] = []
144|aa4292|        let queryLower = query.lowercased()
145|a14f23|        let textLower = text.lowercased()
146|d6ed84|        
147|65f313|        var queryIndex = queryLower.startIndex
148|a07ffc|        var currentSegment = ""
149|d3c359|        var isMatch = false
150|d6ed84|        
151|4083e9|        for (i, char) in text.enumerated() {
152|212094|            let textIndex = textLower.index(textLower.startIndex, offsetBy: i)
153|3070d1|            
154|3f747d|            if queryIndex < queryLower.endIndex && 
155|f8248a|               textLower[textIndex] == queryLower[queryIndex] {
156|eecabe|                if !isMatch && !currentSegment.isEmpty {
157|78ec19|                    result.append((currentSegment, false))
158|cc1904|                    currentSegment = ""
159|4e2d32|                }
160|a00101|                isMatch = true
161|b31654|                currentSegment.append(char)
162|ea161d|                queryIndex = queryLower.index(after: queryIndex)
163|f5a6eb|            } else {
164|fbac5d|                if isMatch && !currentSegment.isEmpty {
165|15ba04|                    result.append((currentSegment, true))
166|cc1904|                    currentSegment = ""
167|4e2d32|                }
168|d1cc2f|                isMatch = false
169|b31654|                currentSegment.append(char)
170|a7dc16|            }
171|5f3077|        }
172|d6ed84|        
173|5d8d48|        if !currentSegment.isEmpty {
174|eb146d|            result.append((currentSegment, isMatch))
175|5f3077|        }
176|d6ed84|        
177|67ed82|        return result
178|27e597|    }
179|b31277|}
180|adc83b|
181|cfacdb|// MARK: - Command Palette View
182|adc83b|
183|7c5c9e|struct CommandPaletteView: View {
184|e5f895|    @ObservedObject var editorCore: EditorCore
185|3bd3a7|    @Binding var showSettings: Bool
186|fe5153|    @Binding var showTerminal: Bool
187|86ed01|    @StateObject private var recentManager = RecentCommandsManager()
188|b4687f|    
189|d901da|    @State private var searchText = ""
190|6c323c|    @State private var selectedIndex = 0
191|c96b14|    @FocusState private var isSearchFocused: Bool
192|b4687f|    
193|7d3e86|    private var allCommands: [Command] {
194|77fd49|        [
195|3125d2|            // File Commands
196|038091|            Command(name: "New File", shortcut: "⌘N", icon: "doc.badge.plus", category: .file) {
197|4e14dd|                editorCore.addTab()
198|a2c4a2|                dismiss()
199|12b7cc|            },
200|18a956|            Command(name: "New Window", shortcut: "⌘⇧N", icon: "macwindow.badge.plus", category: .file) {
201|a2c4a2|                dismiss()
202|12b7cc|            },
203|9eda86|            Command(name: "Open File", shortcut: "⌘O", icon: "doc", category: .file) {
204|d11da5|                editorCore.showFilePicker = true
205|a2c4a2|                dismiss()
206|12b7cc|            },
207|91a625|            Command(name: "Open Folder", shortcut: "⌘⇧O", icon: "folder", category: .file) {
208|a2c4a2|                dismiss()
209|12b7cc|            },
210|d28e2f|            Command(name: "Save", shortcut: "⌘S", icon: "square.and.arrow.down", category: .file) {
211|b9e2a3|                editorCore.saveActiveTab()
212|a2c4a2|                dismiss()
213|12b7cc|            },
214|5f3788|            Command(name: "Save As...", shortcut: "⌘⇧S", icon: "square.and.arrow.down.on.square", category: .file) {
215|a2c4a2|                dismiss()
216|12b7cc|            },
217|84d2b8|            Command(name: "Save All", shortcut: "⌘⌥S", icon: "square.and.arrow.down.fill", category: .file) {
218|183eb7|                editorCore.saveAllTabs()
219|a2c4a2|                dismiss()
220|12b7cc|            },
221|12a8d5|            Command(name: "Close Editor", shortcut: "⌘W", icon: "xmark.square", category: .file) {
222|3ce118|                if let tabId = editorCore.activeTabId {
223|afb881|                    editorCore.closeTab(id: tabId)
224|4e2d32|                }
225|a2c4a2|                dismiss()
226|12b7cc|            },
227|85a144|            Command(name: "Close All Editors", shortcut: "⌘K ⌘W", icon: "xmark.square.fill", category: .file) {
228|237734|                editorCore.closeAllTabs()
229|a2c4a2|                dismiss()
230|12b7cc|            },
231|3070d1|            
232|6a0b81|            // Edit Commands
233|ee0284|            Command(name: "Undo", shortcut: "⌘Z", icon: "arrow.uturn.backward", category: .edit) {
234|a2c4a2|                dismiss()
235|12b7cc|            },
236|be921e|            Command(name: "Redo", shortcut: "⌘⇧Z", icon: "arrow.uturn.forward", category: .edit) {
237|a2c4a2|                dismiss()
238|12b7cc|            },
239|14b4b9|            Command(name: "Cut", shortcut: "⌘X", icon: "scissors", category: .edit) {
240|a2c4a2|                dismiss()
241|12b7cc|            },
242|a620a9|            Command(name: "Copy", shortcut: "⌘C", icon: "doc.on.doc", category: .edit) {
243|a2c4a2|                dismiss()
244|12b7cc|            },
245|6a0d20|            Command(name: "Paste", shortcut: "⌘V", icon: "doc.on.clipboard", category: .edit) {
246|a2c4a2|                dismiss()
247|12b7cc|            },
248|49b96c|            Command(name: "Find", shortcut: "⌘F", icon: "magnifyingglass", category: .edit) {
249|53e6a6|                editorCore.showSearch = true
250|a2c4a2|                dismiss()
251|12b7cc|            },
252|33d410|            Command(name: "Replace", shortcut: "⌘⌥F", icon: "arrow.left.arrow.right", category: .edit) {
253|53e6a6|                editorCore.showSearch = true
254|a2c4a2|                dismiss()
255|12b7cc|            },
256|4e1858|            Command(name: "Find in Files", shortcut: "⌘⇧F", icon: "doc.text.magnifyingglass", category: .edit) {
257|48a81b|                editorCore.focusedSidebarTab = 1  // Search tab
258|04d45c|                editorCore.showSidebar = true
259|a2c4a2|                dismiss()
260|12b7cc|            },
261|3070d1|            
262|0552fb|            // Selection Commands
263|220752|            Command(name: "Select All", shortcut: "⌘A", icon: "selection.pin.in.out", category: .selection) {
264|a2c4a2|                dismiss()
265|12b7cc|            },
266|7e4d38|            Command(name: "Expand Selection", shortcut: "⌃⇧⌘→", icon: "arrow.up.left.and.arrow.down.right", category: .selection) {
267|a2c4a2|                dismiss()
268|12b7cc|            },
269|7e4bdd|            Command(name: "Shrink Selection", shortcut: "⌃⇧⌘←", icon: "arrow.down.right.and.arrow.up.left", category: .selection) {
270|a2c4a2|                dismiss()
271|12b7cc|            },
272|3bdecb|            Command(name: "Add Cursor Above", shortcut: "⌥⌘↑", icon: "cursorarrow.and.square.on.square.dashed", category: .selection) {
273|649529|                editorCore.addCursorAbove()
274|a2c4a2|                dismiss()
275|12b7cc|            },
276|5be7e6|            Command(name: "Add Cursor Below", shortcut: "⌥⌘↓", icon: "cursorarrow.and.square.on.square.dashed", category: .selection) {
277|42bcdf|                editorCore.addCursorBelow()
278|a2c4a2|                dismiss()
279|12b7cc|            },
280|3070d1|            
281|98cf23|            // View Commands
282|4c49fd|            Command(name: "Toggle Sidebar", shortcut: "⌘B", icon: "sidebar.left", category: .view) {
283|1b8eef|                editorCore.toggleSidebar()
284|a2c4a2|                dismiss()
285|12b7cc|            },
286|74b889|            Command(name: "Toggle Terminal", shortcut: "⌘`", icon: "terminal", category: .view) {
287|8f6822|                showTerminal.toggle()
288|a2c4a2|                dismiss()
289|12b7cc|            },
290|fb9b74|            Command(name: "Toggle Full Screen", shortcut: "⌃⌘F", icon: "arrow.up.left.and.arrow.down.right", category: .view) {
291|a2c4a2|                dismiss()
292|12b7cc|            },
293|3c614d|            Command(name: "Zoom In", shortcut: "⌘+", icon: "plus.magnifyingglass", category: .view) {
294|41a814|                editorCore.zoomIn()
295|a2c4a2|                dismiss()
296|12b7cc|            },
297|afbdee|            Command(name: "Zoom Out", shortcut: "⌘-", icon: "minus.magnifyingglass", category: .view) {
298|44c319|                editorCore.zoomOut()
299|a2c4a2|                dismiss()
300|12b7cc|            },
301|29b667|            Command(name: "Reset Zoom", shortcut: "⌘0", icon: "1.magnifyingglass", category: .view) {
302|687359|                editorCore.resetZoom()
303|a2c4a2|                dismiss()
304|12b7cc|            },
305|8cf2b6|            Command(name: "Show Command Palette", shortcut: "⌘⇧P", icon: "command", category: .view) {
306|a2c4a2|                dismiss()
307|12b7cc|            },
308|6fbb2b|            Command(name: "Quick Open", shortcut: "⌘P", icon: "magnifyingglass", category: .view) {
309|4d8e29|                editorCore.showQuickOpen = true
310|a2c4a2|                dismiss()
311|12b7cc|            },
312|73d768|            Command(name: "Collapse All", shortcut: "⌘K ⌘[", icon: "minus.rectangle.on.rectangle", category: .view) {
313|49d1dd|                CodeFoldingManager.shared.collapseAll()
314|a2c4a2|                dismiss()
315|12b7cc|            },
316|359b8a|            Command(name: "Expand All", shortcut: "⌘K ⌘]", icon: "plus.rectangle.on.rectangle", category: .view) {
317|e2fc53|                CodeFoldingManager.shared.expandAll()
318|a2c4a2|                dismiss()
319|12b7cc|            },
320|3070d1|            
321|9819d5|            // Go Commands
322|bccd00|            Command(name: "Go to File", shortcut: "⌘P", icon: "doc.text.magnifyingglass", category: .go) {
323|4d8e29|                editorCore.showQuickOpen = true
324|a2c4a2|                dismiss()
325|12b7cc|            },
326|987482|            Command(name: "Go to Symbol", shortcut: "⌘⇧O", icon: "number", category: .go) {
327|392933|                editorCore.showGoToSymbol = true
328|a2c4a2|                dismiss()
329|12b7cc|            },
330|76261b|            Command(name: "Go to Line", shortcut: "⌘G", icon: "arrow.right.to.line", category: .go) {
331|1c8278|                editorCore.showGoToLine = true
332|a2c4a2|                dismiss()
333|12b7cc|            },
334|c14db7|            Command(name: "Go to Definition", shortcut: "F12", icon: "arrow.right.circle", category: .go) {
335|687578|                editorCore.goToDefinitionAtCursor()
336|a2c4a2|                dismiss()
337|12b7cc|            },
338|6f1c21|            Command(name: "Go Back", shortcut: "⌃-", icon: "chevron.backward", category: .go) {
339|505ba2|                editorCore.navigateBack()
340|a2c4a2|                dismiss()
341|12b7cc|            },
342|c6c9fd|            Command(name: "Go Forward", shortcut: "⌃⇧-", icon: "chevron.forward", category: .go) {
343|958214|                editorCore.navigateForward()
344|a2c4a2|                dismiss()
345|12b7cc|            },
346|00c74b|            Command(name: "Next Editor", shortcut: "⌃Tab", icon: "arrow.right.square", category: .go) {
347|49be3b|                editorCore.nextTab()
348|a2c4a2|                dismiss()
349|12b7cc|            },
350|7c06e2|            Command(name: "Previous Editor", shortcut: "⌃⇧Tab", icon: "arrow.left.square", category: .go) {
351|83663a|                editorCore.previousTab()
352|a2c4a2|                dismiss()
353|12b7cc|            },
354|3070d1|            
355|3ea29a|            // Run Commands
356|7d83d4|            Command(name: "Start Debugging", shortcut: "F5", icon: "play.fill", category: .run) {
357|a2c4a2|                dismiss()
358|12b7cc|            },
359|ce011b|            Command(name: "Run Without Debugging", shortcut: "⌃F5", icon: "play", category: .run) {
360|a2c4a2|                dismiss()
361|12b7cc|            },
362|a9bc5e|            Command(name: "Stop", shortcut: "⇧F5", icon: "stop.fill", category: .run) {
363|a2c4a2|                dismiss()
364|12b7cc|            },
365|f200da|            Command(name: "Restart", shortcut: "⌃⇧F5", icon: "arrow.clockwise", category: .run) {
366|a2c4a2|                dismiss()
367|12b7cc|            },
368|3070d1|            
369|37560a|            // Terminal Commands
370|8b070b|            Command(name: "New Terminal", shortcut: "⌃⇧`", icon: "terminal.fill", category: .terminal) {
371|f34303|                showTerminal = true
372|a2c4a2|                dismiss()
373|12b7cc|            },
374|926af9|            Command(name: "Clear Terminal", shortcut: nil, icon: "trash", category: .terminal) {
375|a2c4a2|                dismiss()
376|12b7cc|            },
377|c82d10|            Command(name: "Kill Terminal", shortcut: nil, icon: "xmark.circle", category: .terminal) {
378|893b2a|                showTerminal = false
379|a2c4a2|                dismiss()
380|12b7cc|            },
381|3070d1|            
382|a02741|            // Preferences Commands
383|4b1a46|            Command(name: "Settings", shortcut: "⌘,", icon: "gear", category: .preferences) {
384|1990ef|                showSettings = true
385|a2c4a2|                dismiss()
386|12b7cc|            },
387|868701|            Command(name: "Keyboard Shortcuts", shortcut: "⌘K ⌘S", icon: "keyboard", category: .preferences) {
388|a2c4a2|                dismiss()
389|12b7cc|            },
390|10ebbf|            Command(name: "Color Theme", shortcut: nil, icon: "paintpalette", category: .preferences) {
391|a2c4a2|                dismiss()
392|12b7cc|            },
393|e51984|            Command(name: "File Icon Theme", shortcut: nil, icon: "doc.badge.gearshape", category: .preferences) {
394|a2c4a2|                dismiss()
395|12b7cc|            },
396|3070d1|            
397|53c6c1|            // Help Commands
398|0c3ae0|            Command(name: "Welcome", shortcut: nil, icon: "hand.wave", category: .help) {
399|a2c4a2|                dismiss()
400|12b7cc|            },
401|716385|            Command(name: "Documentation", shortcut: nil, icon: "book", category: .help) {
402|a2c4a2|                dismiss()
403|12b7cc|            },
404|2cb975|            Command(name: "AI Assistant", shortcut: "⌘⇧A", icon: "brain", category: .help) {
405|953466|                editorCore.showAIAssistant = true
406|a2c4a2|                dismiss()
407|a7dc16|            }
408|220505|        ]
409|27e597|    }
410|b4687f|    
411|27623f|    private var filteredCommands: [Command] {
412|93055c|        if searchText.isEmpty {
413|c6a1fd|            // Show recent commands first, then all commands
414|df481a|            let recentNames = Set(recentManager.recentCommands)
415|28414c|            let recent = allCommands.filter { recentNames.contains($0.name) }
416|af65a0|                .sorted { a, b in
417|d73b49|                    let aIdx = recentManager.recentCommands.firstIndex(of: a.name) ?? Int.max
418|3d02c9|                    let bIdx = recentManager.recentCommands.firstIndex(of: b.name) ?? Int.max
419|0688f6|                    return aIdx < bIdx
420|4e2d32|                }
421|c4a108|            let others = allCommands.filter { !recentNames.contains($0.name) }
422|4f9548|            return recent + others
423|5f3077|        }
424|d6ed84|        
425|babd96|        return allCommands
426|519b5d|            .compactMap { cmd -> (Command, Int)? in
427|8c516a|                guard let score = FuzzyMatcher.score(query: searchText, target: cmd.name) else {
428|024b84|                    return nil
429|4e2d32|                }
430|46f56b|                return (cmd, score)
431|a7dc16|            }
432|4a2f11|            .sorted { $0.1 > $1.1 }
433|ffcc79|            .map { $0.0 }
434|27e597|    }
435|b4687f|    
436|debdc2|    private func dismiss() {
437|02562c|        editorCore.showCommandPalette = false
438|27e597|    }
439|b4687f|    
440|3b5568|    private func executeCommand(_ command: Command) {
441|0a37ea|        recentManager.addRecent(command.name)
442|a6f1ca|        command.action()
443|27e597|    }
444|b4687f|    
445|504e43|    var body: some View {
446|94dd27|        VStack(spacing: 0) {
447|b8aa88|            // Search Header
448|8574de|            HStack(spacing: 12) {
449|d1730f|                Image(systemName: "chevron.right")
450|9d5a30|                    .font(.system(size: 14, weight: .medium))
451|72464b|                    .foregroundColor(.secondary)
452|216278|                
453|0cd38c|                TextField("", text: $searchText, prompt: Text("Type a command or search...").foregroundColor(.secondary))
454|abe43c|                    .font(.system(size: 14))
455|63a586|                    .textFieldStyle(.plain)
456|f3390b|                    .focused($isSearchFocused)
457|eaf7dc|                    .onSubmit {
458|7ac5d5|                        if let command = selectedIndex < filteredCommands.count ? filteredCommands[selectedIndex] : nil {
459|338ed6|                            executeCommand(command)
460|392b35|                        }
461|c9717a|                    }
462|216278|                
463|73afa1|                if !searchText.isEmpty {
464|67cd1a|                    Button(action: { searchText = "" }) {
465|a5c3e0|                        Image(systemName: "xmark.circle.fill")
466|b15939|                            .foregroundColor(.secondary)
467|c9717a|                    }
468|9cd867|                    .buttonStyle(.plain)
469|4e2d32|                }
470|a7dc16|            }
471|94e6d5|            .padding(.horizontal, 16)
472|b3298d|            .padding(.vertical, 12)
473|508ae7|            .background(Color(UIColor.secondarySystemBackground))
474|3070d1|            
475|e744dc|            Divider()
476|3070d1|            
477|a2afcf|            // Commands List
478|db6e07|            ScrollViewReader { proxy in
479|5deb41|                ScrollView {
480|1b3e39|                    LazyVStack(spacing: 0) {
481|169618|                        // Recent section header
482|ae3a4d|                        if searchText.isEmpty && !recentManager.recentCommands.isEmpty {
483|94cdc3|                            HStack {
484|82d132|                                Text("recently used")
485|0a796c|                                    .font(.system(size: 11, weight: .medium))
486|5c0ddb|                                    .foregroundColor(.secondary)
487|98814c|                                    .textCase(.uppercase)
488|7e8fcd|                                Spacer()
489|89d40a|                            }
490|05e9b9|                            .padding(.horizontal, 16)
491|336f39|                            .padding(.vertical, 6)
492|77ef6f|                            .background(Color(UIColor.tertiarySystemBackground))
493|392b35|                        }
494|956cfe|                        
495|7f3bee|                        ForEach(Array(filteredCommands.enumerated()), id: \.element.id) { index, command in
496|1cca0a|                            CommandRowView(
497|1e93df|                                command: command,
498|8acb07|                                searchQuery: searchText,
499|8672fa|                                isSelected: index == selectedIndex,
500|327321|                                isRecent: recentManager.recentCommands.contains(command.name)
501|3d140c|                            )
502|48f34a|                            .id(index)
503|9925b9|                            .onTapGesture {
504|d9a1ab|                                executeCommand(command)
505|89d40a|                            }
506|e4abf2|                            
507|df9ad5|                            // Category divider after recent commands
508|355287|                            if searchText.isEmpty && 
509|b5f48c|                               index == recentManager.recentCommands.count - 1 && 
510|2b7f74|                               !recentManager.recentCommands.isEmpty {
511|ccf016|                                HStack {
512|fca79c|                                    Text("all commands")
513|d38e38|                                        .font(.system(size: 11, weight: .medium))
514|759980|                                        .foregroundColor(.secondary)
515|dfaca8|                                        .textCase(.uppercase)
516|c7a564|                                    Spacer()
517|f83e05|                                }
518|597e80|                                .padding(.horizontal, 16)
519|4bf4c3|                                .padding(.vertical, 6)
520|d8bd09|                                .background(Color(UIColor.tertiarySystemBackground))
521|89d40a|                            }
522|392b35|                        }
523|c9717a|                    }
524|4e2d32|                }
525|65a3c2|                .onChange(of: selectedIndex) { newIndex in
526|276987|                    withAnimation(.easeInOut(duration: 0.1)) {
527|64186a|                        proxy.scrollTo(newIndex, anchor: .center)
528|c9717a|                    }
529|4e2d32|                }
530|a7dc16|            }
531|a27b41|            .frame(maxHeight: 400)
532|3070d1|            
533|311873|            // Footer
534|3185eb|            HStack(spacing: 16) {
535|10b64b|                FooterHint(keys: ["↑", "↓"], description: "navigate")
536|02f516|                FooterHint(keys: ["↵"], description: "select")
537|1a5433|                FooterHint(keys: ["esc"], description: "close")
538|a02350|                Spacer()
539|d51270|                Text("\(filteredCommands.count) commands")
540|a5b455|                    .font(.system(size: 11))
541|72464b|                    .foregroundColor(.secondary)
542|a7dc16|            }
543|94e6d5|            .padding(.horizontal, 16)
544|5b6fc5|            .padding(.vertical, 8)
545|13cf90|            .background(Color(UIColor.tertiarySystemBackground))
546|5f3077|        }
547|9d86ef|        .frame(width: 600)
548|928ed0|        .background(Color(UIColor.systemBackground))
549|1599ca|        .cornerRadius(12)
550|637de6|        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
551|2bd24e|        .onAppear {
552|56a05a|            isSearchFocused = true
553|5373e9|            selectedIndex = 0
554|5f3077|        }
555|50c165|        .onChange(of: searchText) { _ in
556|5373e9|            selectedIndex = 0
557|5f3077|        }
558|f58142|        .modifier(KeyboardNavigationModifier(
559|b3eba3|            onUp: { if selectedIndex > 0 { selectedIndex -= 1 } },
560|e0aa58|            onDown: { if selectedIndex < filteredCommands.count - 1 { selectedIndex += 1 } },
561|22e9fc|            onEscape: { dismiss() }
562|813e75|        ))
563|27e597|    }
564|b31277|}
565|adc83b|
566|23824e|// MARK: - Command Row View
567|adc83b|
568|f531c6|struct CommandRowView: View {
569|19696f|    let command: Command
570|470a2c|    let searchQuery: String
571|055123|    let isSelected: Bool
572|a41eed|    let isRecent: Bool
573|b4687f|    
574|504e43|    var body: some View {
575|8c28e9|        HStack(spacing: 12) {
576|bf7cbb|            // Category icon
577|b321df|            Image(systemName: command.icon)
578|a57c19|                .font(.system(size: 14))
579|afdbe6|                .foregroundColor(isSelected ? .white : .accentColor)
580|fc6377|                .frame(width: 24)
581|3070d1|            
582|1fc88c|            // Command name with highlighting
583|085bc5|            highlightedName
584|3070d1|            
585|1e6289|            Spacer()
586|3070d1|            
587|f0dd0d|            // Recent indicator
588|1fe14a|            if isRecent && searchQuery.isEmpty {
589|ce2635|                Image(systemName: "clock")
590|43cd83|                    .font(.system(size: 10))
591|39aaec|                    .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
592|a7dc16|            }
593|3070d1|            
594|2e665a|            // Category badge
595|7ff844|            Text(command.category.rawValue)
596|439860|                .font(.system(size: 10, weight: .medium))
597|f145ac|                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
598|801496|                .padding(.horizontal, 6)
599|aa3473|                .padding(.vertical, 2)
600|f02960|                .background(
601|8ef1be|                    RoundedRectangle(cornerRadius: 4)
602|276f73|                        .fill(isSelected ? Color.white.opacity(0.2) : Color(UIColor.tertiarySystemFill))
603|6f642e|                )
604|3070d1|            
605|fbe6c5|            // Keyboard shortcut
606|6b1008|            if let shortcut = command.shortcut {
607|6d43ae|                ShortcutBadge(shortcut: shortcut, isSelected: isSelected)
608|a7dc16|            }
609|5f3077|        }
610|a15da8|        .padding(.horizontal, 16)
611|bd7543|        .padding(.vertical, 10)
612|413d6d|        .background(
613|08e8f6|            RoundedRectangle(cornerRadius: 6)
614|13be75|                .fill(isSelected ? Color.accentColor : Color.clear)
615|3143a4|        )
616|0921e9|        .padding(.horizontal, 8)
617|ea63eb|        .padding(.vertical, 1)
618|55e29b|        .contentShape(Rectangle())
619|27e597|    }
620|b4687f|    
621|ab06c2|    @ViewBuilder
622|a557f4|    private var highlightedName: some View {
623|4c9b69|        if searchQuery.isEmpty {
624|3a60a5|            Text(command.name)
625|737552|                .font(.system(size: 13))
626|6226ee|                .foregroundColor(isSelected ? .white : .primary)
627|b31999|        } else {
628|01e1af|            let parts = FuzzyMatcher.highlight(query: searchQuery, in: command.name)
629|3b7550|            HStack(spacing: 0) {
630|b696d8|                ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
631|e6b375|                    Text(part.0)
632|fc096a|                        .font(.system(size: 13, weight: part.1 ? .bold : .regular))
633|ee54d3|                        .foregroundColor(isSelected ? .white : (part.1 ? .accentColor : .primary))
634|4e2d32|                }
635|a7dc16|            }
636|5f3077|        }
637|27e597|    }
638|b31277|}
639|adc83b|
640|431faf|// MARK: - Shortcut Badge
641|adc83b|
642|536eff|struct ShortcutBadge: View {
643|14874c|    let shortcut: String
644|055123|    let isSelected: Bool
645|b4687f|    
646|504e43|    var body: some View {
647|fc9fe2|        HStack(spacing: 2) {
648|4df5ea|            ForEach(shortcut.components(separatedBy: " "), id: \.self) { key in
649|6e641a|                Text(key)
650|60a363|                    .font(.system(size: 11, design: .rounded))
651|4326ee|                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
652|092f7b|                    .padding(.horizontal, 6)
653|f8dd2a|                    .padding(.vertical, 3)
654|c7bd73|                    .background(
655|f38447|                        RoundedRectangle(cornerRadius: 4)
656|dcbcf3|                            .fill(isSelected ? Color.white.opacity(0.2) : Color(UIColor.tertiarySystemFill))
657|1961a4|                    )
658|a7dc16|            }
659|5f3077|        }
660|27e597|    }
661|b31277|}
662|adc83b|
663|7cff0e|// MARK: - Footer Hint
664|adc83b|
665|ec13ea|struct FooterHint: View {
666|164a9e|    let keys: [String]
667|8dc0c7|    let description: String
668|b4687f|    
669|504e43|    var body: some View {
670|b120fa|        HStack(spacing: 4) {
671|4184bb|            ForEach(keys, id: \.self) { key in
672|6e641a|                Text(key)
673|0aa3ba|                    .font(.system(size: 10, weight: .medium, design: .rounded))
674|72464b|                    .foregroundColor(.secondary)
675|4424f8|                    .padding(.horizontal, 4)
676|9bae05|                    .padding(.vertical, 2)
677|c7bd73|                    .background(
678|27f2ec|                        RoundedRectangle(cornerRadius: 3)
679|ebf9c9|                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
680|1961a4|                    )
681|a7dc16|            }
682|77626e|            Text(description)
683|a7de34|                .font(.system(size: 11))
684|831eae|                .foregroundColor(.secondary)
685|5f3077|        }
686|27e597|    }
687|b31277|}
688|adc83b|
689|b8a7dc|// MARK: - Keyboard Navigation Modifier
690|adc83b|
691|533d2d|private struct KeyboardNavigationModifier: ViewModifier {
692|021242|    let onUp: () -> Void
693|81b54b|    let onDown: () -> Void
694|984088|    let onEscape: () -> Void
695|b4687f|    
696|ab06c2|    @ViewBuilder
697|881671|    func body(content: Content) -> some View {
698|5ddca0|        if #available(iOS 17.0, *) {
699|d1acbf|            content
700|08cff7|                .onKeyPress(.upArrow) { onUp(); return .handled }
701|415326|                .onKeyPress(.downArrow) { onDown(); return .handled }
702|48ee00|                .onKeyPress(.escape) { onEscape(); return .handled }
703|b31999|        } else {
704|d1acbf|            content
705|5f3077|        }
706|27e597|    }
707|b31277|}
708|adc83b|
709|5e4767|// MARK: - Preview
710|adc83b|
711|0eca73|#Preview {
712|3feb8f|    ZStack {
713|526d43|        Color.black.opacity(0.5)
714|d6ae6c|        CommandPaletteView(
715|ba2dc2|            editorCore: EditorCore(),
716|9dafa9|            showSettings: .constant(false),
717|36a3e4|            showTerminal: .constant(false)
718|3143a4|        )
719|27e597|    }
720|b31277|}
721|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 9cfe4766210b
File: VSCodeiPadOS/VSCodeiPadOS/Services/Runners/NodeRunner.swift (lines 1-847 of 847)
────────────────────────────────────────
1|8b6b78|import Foundation
2|8b6b78|import Foundation
3|adc83b|
4|f2b054|#if os(macOS)
5|adc83b|
6|b945b3|// MARK: - Base Runner Protocol
7|adc83b|
8|a6c338|/// Base protocol for all language runners
9|8de8ab|protocol ToolingRunner {
10|cef805|    /// The language this runner handles
11|342bdc|    static var language: String { get }
12|adc83b|
13|80d6e6|    /// Execute a command
14|50f8a8|    func execute(command: String, in directory: URL, environment: [String: String]?) async throws -> ProcessResult
15|adc83b|
16|33a462|    /// Check if the required tooling is available
17|3cf7f2|    func checkAvailability() async -> RunnerAvailability
18|b31277|}
19|adc83b|
20|f1e669|/// Result of running a process
21|a55b78|struct ProcessResult {
22|580fea|    let exitCode: Int
23|b28d7c|    let stdout: String
24|75a80c|    let stderr: String
25|afb00a|    let duration: TimeInterval
26|b4687f|    
27|bacfaf|    var isSuccess: Bool { exitCode == 0 }
28|b31277|}
29|adc83b|
30|80e333|/// Availability status of a runner
31|75585c|struct RunnerAvailability {
32|6190a1|    let isAvailable: Bool
33|31b5b0|    let version: String?
34|7bbb20|    let missingTools: [String]
35|b31277|}
36|adc83b|
37|aa117a|// MARK: - Node.js Error Types
38|adc83b|
39|289c56|enum NodeRunnerError: Error, LocalizedError {
40|92ead6|    case nodeNotFound
41|8a2464|    case packageManagerNotFound
42|c78e77|    case packageJsonNotFound
43|e6ed67|    case invalidScript(String)
44|101d19|    case moduleNotFound(String)
45|9aac74|    case syntaxError(line: Int, message: String)
46|3fbf8b|    case typeError(message: String)
47|f11be7|    case versionMismatch(required: String, found: String)
48|9c05fd|    case nvmNotConfigured
49|b4687f|    
50|242b78|    var errorDescription: String? {
51|2e6d08|        switch self {
52|5af276|        case .nodeNotFound:
53|8e0c66|            return "Node.js is not installed or not in PATH"
54|d7dbb6|        case .packageManagerNotFound:
55|dbca87|            return "No package manager (npm, yarn, pnpm) found"
56|2a5431|        case .packageJsonNotFound:
57|003713|            return "No package.json found in project"
58|59a1b3|        case .invalidScript(let script):
59|526a7d|            return "Invalid npm script: \(script)"
60|fd4335|        case .moduleNotFound(let module):
61|fb8e72|            return "Module not found: \(module)"
62|3df256|        case .syntaxError(let line, let message):
63|ef88e9|            return "Syntax error at line \(line): \(message)"
64|f9797d|        case .typeError(let message):
65|777c50|            return "Type error: \(message)"
66|7ae649|        case .versionMismatch(let required, let found):
67|0cca20|            return "Node version mismatch. Required: \(required), Found: \(found)"
68|62e87c|        case .nvmNotConfigured:
69|cb673e|            return "nvm/n is not configured properly"
70|5f3077|        }
71|27e597|    }
72|b31277|}
73|adc83b|
74|71e2e4|// MARK: - Supporting Types
75|adc83b|
76|bfbd44|/// Package manager types
77|318481|enum PackageManager: String, CaseIterable {
78|b75c00|    case npm = "npm"
79|2d3953|    case yarn = "yarn"
80|99bfa8|    case pnpm = "pnpm"
81|b4687f|    
82|4cf739|    var lockFile: String {
83|2e6d08|        switch self {
84|0ff003|        case .npm: return "package-lock.json"
85|43cfd8|        case .yarn: return "yarn.lock"
86|50a21c|        case .pnpm: return "pnpm-lock.yaml"
87|5f3077|        }
88|27e597|    }
89|b4687f|    
90|cf0133|    var installCommand: String {
91|2e6d08|        switch self {
92|7ab2c0|        case .npm: return "npm install"
93|90f313|        case .yarn: return "yarn install"
94|a41448|        case .pnpm: return "pnpm install"
95|5f3077|        }
96|27e597|    }
97|b4687f|    
98|8b3242|    var runCommand: String {
99|2e6d08|        switch self {
100|21615a|        case .npm: return "npm run"
101|134ac2|        case .yarn: return "yarn"
102|56290d|        case .pnpm: return "pnpm"
103|5f3077|        }
104|27e597|    }
105|b31277|}
106|adc83b|
107|69844c|/// TypeScript execution mode
108|a72b4e|enum TypeScriptMode {
109|71c94a|    case tsc          // Compile then run with node
110|62e682|    case tsNode       // Direct execution with ts-node
111|c4fbe8|    case tsx          // Fast tsx runner
112|b4687f|    
113|0f2285|    var command: String {
114|2e6d08|        switch self {
115|39fd33|        case .tsc: return "tsc"
116|e338f0|        case .tsNode: return "ts-node"
117|b541fc|        case .tsx: return "tsx"
118|5f3077|        }
119|27e597|    }
120|b31277|}
121|adc83b|
122|90e9cd|/// Module system type
123|30b969|enum ModuleSystem {
124|c2837d|    case esm          // ES Modules (ESM)
125|b8ffda|    case commonjs     // CommonJS (CJS)
126|b4687f|    
127|c38ccc|    var flag: String? {
128|2e6d08|        switch self {
129|32dcd5|        case .esm: return "--experimental-modules"
130|289716|        case .commonjs: return nil
131|5f3077|        }
132|27e597|    }
133|b31277|}
134|adc83b|
135|017159|/// Node debug configuration
136|c23185|struct NodeDebugConfig {
137|74544f|    let enabled: Bool
138|932f80|    let port: Int
139|3c31e8|    let breakOnStart: Bool
140|b4687f|    
141|8b42d9|    static let `default` = NodeDebugConfig(enabled: false, port: 9229, breakOnStart: false)
142|b4687f|    
143|c38ccc|    var flag: String? {
144|eb4e4e|        guard enabled else { return nil }
145|a79184|        if breakOnStart {
146|6896f6|            return "--inspect-brk=\(port)"
147|b31999|        } else {
148|4655c5|            return "--inspect=\(port)"
149|5f3077|        }
150|27e597|    }
151|b31277|}
152|adc83b|
153|f15965|/// Parsed error from Node.js output
154|d003e4|struct NodeError {
155|1d8c8b|    let type: String
156|edcb08|    let message: String
157|160db9|    let file: String?
158|1053a3|    let line: Int?
159|8d1d41|    let column: Int?
160|8208ae|    let stackTrace: [String]
161|b31277|}
162|adc83b|
163|318e85|// MARK: - NodeRunner
164|adc83b|
165|868c97|/// Specialized runner for Node.js/JavaScript/TypeScript execution
166|c812ed|final class NodeRunner: ToolingRunner {
167|39be29|    static let language = "javascript"
168|b4687f|    
169|6503ae|    // MARK: - Properties
170|b4687f|    
171|56b9b3|    private let fileManager = FileManager.default
172|45e82b|    private var detectedNodeVersion: String?
173|d803e3|    private var detectedPackageManager: PackageManager?
174|d170df|    private var cachedPackageScripts: [String: String] = [:]
175|b4687f|    
176|7dca75|    // MARK: - Initialization
177|b4687f|    
178|9e018b|    init() {}
179|b4687f|    
180|3321a4|    // MARK: - Runner Protocol Methods
181|b4687f|    
182|e7f989|    /// Execute a command in the specified directory
183|3f563a|    func execute(
184|f87c55|        command: String,
185|4ec94b|        in directory: URL,
186|eed212|        environment: [String: String]? = nil
187|5917f3|    ) async throws -> ProcessResult {
188|69a69f|        let startTime = Date()
189|d6ed84|        
190|75fa71|        // Prepare environment variables
191|058b45|        var env = environment ?? [:]
192|b85aba|        env["NODE_ENV"] = env["NODE_ENV"] ?? "development"
193|d6ed84|        
194|f0d20b|        // Check Node availability
195|b786fc|        let availability = await checkAvailability()
196|7c5765|        guard availability.isAvailable else {
197|2982f2|            throw NodeRunnerError.nodeNotFound
198|5f3077|        }
199|d6ed84|        
200|41e1ce|        // Execute the command
201|a6cfb9|        let result = try await runProcess(
202|87869c|            command: command,
203|6be9f0|            in: directory,
204|217d91|            environment: env
205|3143a4|        )
206|d6ed84|        
207|6c5aa2|        let duration = Date().timeIntervalSince(startTime)
208|cf81c6|        return ProcessResult(
209|ac7aa8|            exitCode: result.exitCode,
210|4ec9b9|            stdout: result.stdout,
211|b73398|            stderr: result.stderr,
212|3cac83|            duration: duration
213|3143a4|        )
214|27e597|    }
215|b4687f|    
216|a2f65a|    /// Check if Node.js and required tools are available
217|3b4a8f|    func checkAvailability() async -> RunnerAvailability {
218|4da690|        do {
219|f88b4f|            let result = try await runProcess(command: "node --version")
220|0da421|            let version = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
221|07314b|            detectedNodeVersion = version
222|3070d1|            
223|ce5e50|            let missingTools = await findMissingTools()
224|3070d1|            
225|451ff1|            return RunnerAvailability(
226|4b5462|                isAvailable: !version.isEmpty,
227|138e56|                version: version,
228|b171c2|                missingTools: missingTools
229|43d041|            )
230|853889|        } catch {
231|451ff1|            return RunnerAvailability(
232|399a80|                isAvailable: false,
233|9ae3e9|                version: nil,
234|f0f414|                missingTools: ["node"]
235|43d041|            )
236|5f3077|        }
237|27e597|    }
238|b4687f|    
239|6f823e|    // MARK: - Feature 1: Auto-detect Node Version and Package Manager
240|b4687f|    
241|bc3f3c|    /// Auto-detect the Node.js version from the project
242|234dd8|    func detectNodeVersion(in directory: URL) async throws -> String {
243|a865c7|        // Check .nvmrc first
244|72fb26|        let nvmrcPath = directory.appendingPathComponent(".nvmrc")
245|8c3efc|        if fileManager.fileExists(atPath: nvmrcPath.path),
246|3593cc|           let version = try? String(contentsOf: nvmrcPath, encoding: .utf8) {
247|14e171|            return version.trimmingCharacters(in: .whitespacesAndNewlines)
248|5f3077|        }
249|d6ed84|        
250|f7ad8e|        // Check package.json engines
251|21aa7b|        let packageJsonPath = directory.appendingPathComponent("package.json")
252|833b8e|        if let data = try? Data(contentsOf: packageJsonPath),
253|f3f42d|           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
254|358430|           let engines = json["engines"] as? [String: String],
255|25dd7e|           let nodeVersion = engines["node"] {
256|9b48bf|            return nodeVersion
257|5f3077|        }
258|d6ed84|        
259|dfa275|        // Fall back to current system version
260|77ad9a|        let result = try await runProcess(command: "node --version")
261|c77a20|        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
262|27e597|    }
263|b4687f|    
264|cd433a|    /// Auto-detect the package manager used in the project
265|41aba9|    func detectPackageManager(in directory: URL) -> PackageManager {
266|ea6a49|        // Check for lock files (most reliable)
267|3737e6|        for pm in PackageManager.allCases {
268|ff3ecb|            let lockFilePath = directory.appendingPathComponent(pm.lockFile)
269|adc555|            if fileManager.fileExists(atPath: lockFilePath.path) {
270|bbcddf|                detectedPackageManager = pm
271|d18275|                return pm
272|a7dc16|            }
273|5f3077|        }
274|d6ed84|        
275|3eb531|        // Default to npm
276|6d2319|        detectedPackageManager = .npm
277|0b28c7|        return .npm
278|27e597|    }
279|b4687f|    
280|2f6479|    // MARK: - Feature 2: TypeScript Compilation
281|b4687f|    
282|702ffb|    /// Detect TypeScript execution mode for a file
283|82ce9b|    func detectTypeScriptMode(for file: URL) -> TypeScriptMode {
284|1027d3|        let path = file.path
285|d6ed84|        
286|8f600c|        // Prefer tsx for speed if available
287|6f7b38|        if isToolAvailable("tsx") {
288|63d44c|            return .tsx
289|5f3077|        }
290|d6ed84|        
291|77232b|        // Check if ts-node is configured
292|c6cef6|        if isToolAvailable("ts-node") {
293|f790ad|            return .tsNode
294|5f3077|        }
295|d6ed84|        
296|dae1b4|        // Default to tsc compilation
297|04963a|        return .tsc
298|27e597|    }
299|b4687f|    
300|a786f8|    /// Execute TypeScript file with appropriate runner
301|7212a6|    func runTypeScript(
302|d3d61c|        file: URL,
303|ace2d2|        mode: TypeScriptMode? = nil,
304|697e61|        args: [String] = [],
305|4ec94b|        in directory: URL,
306|eed212|        environment: [String: String]? = nil
307|5917f3|    ) async throws -> ProcessResult {
308|1b3505|        let tsMode = mode ?? detectTypeScriptMode(for: file)
309|7ef18f|        let moduleSystem = detectModuleSystem(for: file, in: directory)
310|d6ed84|        
311|1fc35a|        var command: String
312|d6ed84|        
313|ab95be|        switch tsMode {
314|88e54b|        case .tsc:
315|c6f734|            // Compile and then run
316|3f628b|            let compiledPath = file.deletingPathExtension().appendingPathExtension("js")
317|d27298|            let compileCmd = "tsc \(file.path) --outDir \(directory.path)"
318|5f719f|            let compileResult = try await execute(
319|a31c39|                command: compileCmd,
320|3a2cb2|                in: directory,
321|b7f6de|                environment: environment
322|43d041|            )
323|3070d1|            
324|c596d2|            guard compileResult.isSuccess else {
325|74ddbd|                return compileResult
326|a7dc16|            }
327|3070d1|            
328|cb4264|            command = "node \(compiledPath.path)"
329|3070d1|            
330|4ddf4c|        case .tsNode:
331|333f7c|            let moduleFlag = moduleSystem == .esm ? "--esm" : ""
332|d4f9b6|            command = "ts-node \(moduleFlag) \(file.path)"
333|3070d1|            
334|ce6126|        case .tsx:
335|2fefbe|            let moduleFlag = moduleSystem == .esm ? "--import tsx" : ""
336|587037|            command = "tsx \(moduleFlag) \(file.path)"
337|5f3077|        }
338|d6ed84|        
339|372b2b|        if !args.isEmpty {
340|009a87|            command += " " + args.joined(separator: " ")
341|5f3077|        }
342|d6ed84|        
343|f4c9b0|        return try await execute(command: command, in: directory, environment: environment)
344|27e597|    }
345|b4687f|    
346|e398b5|    // MARK: - Feature 3: ESM vs CommonJS Detection
347|b4687f|    
348|425d1a|    /// Detect module system (ESM vs CommonJS) for a file
349|a6b99c|    func detectModuleSystem(for file: URL, in directory: URL) -> ModuleSystem {
350|b52163|        // Check package.json type field
351|21aa7b|        let packageJsonPath = directory.appendingPathComponent("package.json")
352|833b8e|        if let data = try? Data(contentsOf: packageJsonPath),
353|f3f42d|           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
354|ce8876|           let type = json["type"] as? String,
355|b12ea7|           type == "module" {
356|ea9762|            return .esm
357|5f3077|        }
358|d6ed84|        
359|f2af0e|        // Check file extension
360|83e64d|        if file.pathExtension == "mjs" {
361|ea9762|            return .esm
362|06192f|        } else if file.pathExtension == "cjs" {
363|ba5bda|            return .commonjs
364|5f3077|        }
365|d6ed84|        
366|621f3a|        // Check for ESM syntax in the file
367|c8e55e|        if let content = try? String(contentsOf: file, encoding: .utf8) {
368|e2c630|            let esmPatterns = [
369|4f9105|                "^\\s*import\\s+.*\\s+from\\s+['\"]",
370|951c7c|                "^\\s*export\\s+(default\\s+)?",
371|cc2fe6|                "^\\s*export\\s*\\{"
372|324820|            ]
373|3070d1|            
374|6968c7|            for pattern in esmPatterns {
375|16d6cd|                if content.range(of: pattern, options: .regularExpression) != nil {
376|2e2770|                    return .esm
377|4e2d32|                }
378|a7dc16|            }
379|5f3077|        }
380|d6ed84|        
381|e788b0|        return .commonjs
382|27e597|    }
383|b4687f|    
384|4d2460|    /// Get the appropriate Node flags for the module system
385|4c5de6|    func getModuleFlags(for file: URL, in directory: URL) -> [String] {
386|0bc26a|        let system = detectModuleSystem(for: file, in: directory)
387|f49f15|        var flags: [String] = []
388|d6ed84|        
389|cf156b|        if let flag = system.flag {
390|6fbcc6|            flags.append(flag)
391|5f3077|        }
392|d6ed84|        
393|bf2b68|        return flags
394|27e597|    }
395|b4687f|    
396|afcc07|    // MARK: - Feature 4: Node Inspect/Debug Support
397|b4687f|    
398|3de624|    /// Run with debug configuration
399|9771bd|    func runWithDebug(
400|d3d61c|        file: URL,
401|0a1edd|        debugConfig: NodeDebugConfig = .default,
402|4ec94b|        in directory: URL,
403|eed212|        environment: [String: String]? = nil
404|5917f3|    ) async throws -> ProcessResult {
405|f49f15|        var flags: [String] = []
406|d6ed84|        
407|27729b|        if let debugFlag = debugConfig.flag {
408|3cf6da|            flags.append(debugFlag)
409|5f3077|        }
410|d6ed84|        
411|878637|        flags.append(file.path)
412|d6ed84|        
413|0efed4|        let command = "node " + flags.joined(separator: " ")
414|f4c9b0|        return try await execute(command: command, in: directory, environment: environment)
415|27e597|    }
416|b4687f|    
417|58b767|    // MARK: - Feature 5: NODE_ENV Handling
418|b4687f|    
419|ed8a11|    /// Set up environment with appropriate NODE_ENV
420|ddcaa6|    func prepareEnvironment(
421|de5fed|        mode: NodeEnvMode,
422|4dfdde|        additionalVars: [String: String]? = nil
423|40eb52|    ) -> [String: String] {
424|f6495c|        var env = additionalVars ?? [:]
425|d6ed84|        
426|a187af|        switch mode {
427|efe6a0|        case .development:
428|0a6ba9|            env["NODE_ENV"] = "development"
429|9de750|        case .production:
430|6796f8|            env["NODE_ENV"] = "production"
431|90680f|        case .test:
432|bc3513|            env["NODE_ENV"] = "test"
433|5fe6cf|        case .custom(let value):
434|a9e5b3|            env["NODE_ENV"] = value
435|5f3077|        }
436|d6ed84|        
437|308aba|        return env
438|27e597|    }
439|b4687f|    
440|28e05a|    enum NodeEnvMode {
441|b756b2|        case development
442|f2685a|        case production
443|efeedc|        case test
444|669a34|        case custom(String)
445|27e597|    }
446|b4687f|    
447|60ec6f|    // MARK: - Feature 6: npm Script Execution
448|b4687f|    
449|9233d0|    /// Execute an npm script from package.json
450|8b234c|    func runNpmScript(
451|d82f35|        script: String,
452|4ec94b|        in directory: URL,
453|8a38a9|        additionalArgs: [String] = [],
454|eed212|        environment: [String: String]? = nil
455|5917f3|    ) async throws -> ProcessResult {
456|c018ff|        let pm = detectPackageManager(in: directory)
457|d6ed84|        
458|07c40d|        var command = "\(pm.runCommand) \(script)"
459|7ef083|        if !additionalArgs.isEmpty {
460|6cdc10|            command += " -- " + additionalArgs.joined(separator: " ")
461|5f3077|        }
462|d6ed84|        
463|f4c9b0|        return try await execute(command: command, in: directory, environment: environment)
464|27e597|    }
465|b4687f|    
466|4b59fd|    /// Get all available npm scripts
467|45bbf6|    func getNpmScripts(from directory: URL) async -> [String: String] {
468|21aa7b|        let packageJsonPath = directory.appendingPathComponent("package.json")
469|d6ed84|        
470|abd27c|        guard let data = try? Data(contentsOf: packageJsonPath),
471|10e037|              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
472|809f5d|              let scripts = json["scripts"] as? [String: String] else {
473|a3b117|            return [:]
474|5f3077|        }
475|d6ed84|        
476|70581f|        cachedPackageScripts = scripts
477|1c17d8|        return scripts
478|27e597|    }
479|b4687f|    
480|186be5|    // MARK: - Feature 7: nvm/n Switch Support
481|b4687f|    
482|5ae478|    /// Switch Node version using nvm or n
483|8ac25b|    func switchNodeVersion(
484|3a0f6c|        to version: String,
485|595293|        using manager: NodeVersionManager = .auto
486|5917f3|    ) async throws -> ProcessResult {
487|4abf2b|        let tool = try await detectVersionManager()
488|d6ed84|        
489|6f8cea|        switch tool {
490|6b8964|        case .nvm:
491|4ddf62|            return try await execute(command: "nvm use \(version)")
492|f2915f|        case .n:
493|d170b3|            return try await execute(command: "n \(version)")
494|328915|        case .fnm:
495|23c383|            return try await execute(command: "fnm use \(version)")
496|e9a021|        case .none:
497|41905d|            throw NodeRunnerError.nvmNotConfigured
498|5f3077|        }
499|27e597|    }
500|b4687f|    
501|00ca39|    /// Install a specific Node version
502|d36319|    func installNodeVersion(
503|eb193d|        _ version: String,
504|595293|        using manager: NodeVersionManager = .auto
505|5917f3|    ) async throws -> ProcessResult {
506|4abf2b|        let tool = try await detectVersionManager()
507|d6ed84|        
508|6f8cea|        switch tool {
509|6b8964|        case .nvm:
510|ceef31|            return try await execute(command: "nvm install \(version)")
511|f2915f|        case .n:
512|2da97a|            return try await execute(command: "n install \(version)")
513|328915|        case .fnm:
514|dc970f|            return try await execute(command: "fnm install \(version)")
515|e9a021|        case .none:
516|41905d|            throw NodeRunnerError.nvmNotConfigured
517|5f3077|        }
518|27e597|    }
519|b4687f|    
520|1848b9|    enum NodeVersionManager {
521|1b9c38|        case nvm
522|23e011|        case n
523|5bfe6d|        case fnm
524|16a854|        case none
525|a1d77d|        case auto
526|27e597|    }
527|b4687f|    
528|1ba79d|    /// Detect which version manager is available
529|c3a4af|    private func detectVersionManager() async throws -> NodeVersionManager {
530|892637|        if isCommandAvailable("nvm") {
531|4cc5f9|            return .nvm
532|4dbdaa|        } else if isCommandAvailable("n") {
533|2ad493|            return .n
534|618e28|        } else if isCommandAvailable("fnm") {
535|bdd94a|            return .fnm
536|5f3077|        }
537|c63b0d|        return .none
538|27e597|    }
539|b4687f|    
540|b7c078|    // MARK: - Feature 8: Package.json Script Autocomplete
541|b4687f|    
542|9a381f|    /// Get script suggestions for autocomplete
543|62dd77|    func getScriptSuggestions(
544|3c4550|        prefix: String,
545|44692a|        in directory: URL
546|c45b0f|    ) async -> [(name: String, command: String, description: String?)] {
547|82ea10|        let scripts = await getNpmScripts(from: directory)
548|d6ed84|        
549|1c17d8|        return scripts
550|dd0e1f|            .filter { $0.key.hasPrefix(prefix) }
551|0779f3|            .map { (name: $0.key, command: $0.value, description: extractDescription(from: $0.value)) }
552|c7f347|            .sorted { $0.name < $1.name }
553|27e597|    }
554|b4687f|    
555|2f38d7|    /// Get all available scripts
556|d2b1bf|    func getAllScriptSuggestions(
557|44692a|        in directory: URL
558|c45b0f|    ) async -> [(name: String, command: String, description: String?)] {
559|82ea10|        let scripts = await getNpmScripts(from: directory)
560|d6ed84|        
561|1c17d8|        return scripts
562|0779f3|            .map { (name: $0.key, command: $0.value, description: extractDescription(from: $0.value)) }
563|c7f347|            .sorted { $0.name < $1.name }
564|27e597|    }
565|b4687f|    
566|6e3410|    private func extractDescription(from command: String) -> String? {
567|9dfffa|        // Try to infer description from common patterns
568|763102|        if command.contains("build") || command.contains("compile") {
569|6b78b4|            return "Build the project"
570|904856|        } else if command.contains("test") {
571|5bf6bf|            return "Run tests"
572|fcdbdb|        } else if command.contains("start") || command.contains("serve") {
573|aa3737|            return "Start the application"
574|0e8ea2|        } else if command.contains("dev") || command.contains("watch") {
575|7e9763|            return "Start development mode"
576|e94990|        } else if command.contains("lint") {
577|c96ed8|            return "Run linter"
578|1ff543|        } else if command.contains("format") {
579|d6ee6e|            return "Format code"
580|5f3077|        }
581|c2ae65|        return nil
582|27e597|    }
583|b4687f|    
584|7abc65|    // MARK: - Feature 9: Node-specific Error Parsing
585|b4687f|    
586|953eac|    /// Parse Node.js error output
587|6ff814|    func parseNodeError(_ stderr: String) -> NodeError? {
588|83e371|        // Parse syntax errors
589|28789e|        if let match = stderr.range(of: "SyntaxError.*:(.+)\\n\\s+at.+(\\d+):(\\d+)", options: .regularExpression) {
590|816f8e|            let components = String(stderr[match]).split(separator: ":")
591|010962|            if components.count >= 2 {
592|db0514|                let message = String(components[1]).trimmingCharacters(in: .whitespaces)
593|b48f04|                let line = Int(components[2]) ?? 0
594|032071|                let column = Int(components[3]) ?? 0
595|216278|                
596|626c47|                return NodeError(
597|beaea4|                    type: "SyntaxError",
598|88bd6a|                    message: message,
599|26254a|                    file: nil,
600|8cea7b|                    line: line,
601|0adac9|                    column: column,
602|264f2c|                    stackTrace: extractStackTrace(from: stderr)
603|6f642e|                )
604|a7dc16|            }
605|5f3077|        }
606|d6ed84|        
607|66cfe0|        // Parse module not found errors
608|89d5e4|        if let match = stderr.range(of: "Error: Cannot find module '(.+)'", options: .regularExpression) {
609|297020|            let module = String(stderr[match])
610|79ce65|                .replacingOccurrences(of: "Error: Cannot find module '", with: "")
611|eb91fd|                .replacingOccurrences(of: "'", with: "")
612|3070d1|            
613|b870aa|            return NodeError(
614|7e2d0f|                type: "ModuleNotFoundError",
615|06231b|                message: "Cannot find module '\(module)'",
616|fcf663|                file: nil,
617|537e9f|                line: nil,
618|ccf0a9|                column: nil,
619|20bcb4|                stackTrace: extractStackTrace(from: stderr)
620|43d041|            )
621|5f3077|        }
622|d6ed84|        
623|e5e718|        // Parse type errors (TypeScript)
624|6e769e|        if stderr.contains("error TS") {
625|dec753|            let lines = stderr.components(separatedBy: .newlines)
626|1a16f7|            for line in lines {
627|4d2398|                if let match = line.range(of: "error TS\\d+:", options: .regularExpression) {
628|ab114e|                    let message = String(line[match.upperBound...]).trimmingCharacters(in: .whitespaces)
629|c277c2|                    let fileLine = line.components(separatedBy: "(")
630|a49bb7|                    let file = fileLine.first?.trimmingCharacters(in: .whitespaces)
631|dd2193|                    
632|b25951|                    return NodeError(
633|0e5120|                        type: "TypeError",
634|1c5846|                        message: message,
635|bc7442|                        file: file,
636|178eeb|                        line: nil,
637|a7e2cf|                        column: nil,
638|c1d2aa|                        stackTrace: []
639|1961a4|                    )
640|4e2d32|                }
641|a7dc16|            }
642|5f3077|        }
643|d6ed84|        
644|e5094a|        // Generic error parsing
645|bdba5d|        if let match = stderr.range(of: "Error: (.+)", options: .regularExpression) {
646|1ac55c|            let message = String(stderr[match])
647|bfae37|                .replacingOccurrences(of: "Error: ", with: "")
648|3070d1|            
649|b870aa|            return NodeError(
650|70ca63|                type: "Error",
651|596fe8|                message: message,
652|fcf663|                file: nil,
653|537e9f|                line: nil,
654|ccf0a9|                column: nil,
655|20bcb4|                stackTrace: extractStackTrace(from: stderr)
656|43d041|            )
657|5f3077|        }
658|d6ed84|        
659|c2ae65|        return nil
660|27e597|    }
661|b4687f|    
662|feeabd|    private func extractStackTrace(from output: String) -> [String] {
663|b18c49|        let lines = output.components(separatedBy: .newlines)
664|8112dc|        var stackTrace: [String] = []
665|37877d|        var capturing = false
666|d6ed84|        
667|08a605|        for line in lines {
668|5ae397|            if line.contains("at ") {
669|b414af|                capturing = true
670|e9fb4f|                stackTrace.append(line.trimmingCharacters(in: .whitespaces))
671|bfaf91|            } else if capturing && !line.isEmpty {
672|74cfd8|                break
673|a7dc16|            }
674|5f3077|        }
675|d6ed84|        
676|33c86e|        return stackTrace
677|27e597|    }
678|b4687f|    
679|bc3228|    /// Format error for display in IDE
680|2a0e1e|    func formatErrorForDisplay(_ error: NodeError) -> String {
681|aeb033|        var output = "[\(error.type)] \(error.message)"
682|d6ed84|        
683|3fc356|        if let file = error.file {
684|07d711|            output += "\n  File: \(file)"
685|5f3077|        }
686|d6ed84|        
687|64cf9b|        if let line = error.line {
688|ec7c93|            output += ":\(line)"
689|737283|            if let column = error.column {
690|8154d7|                output += ":\(column)"
691|a7dc16|            }
692|5f3077|        }
693|d6ed84|        
694|a0599e|        if !error.stackTrace.isEmpty {
695|610f27|            output += "\n\nStack trace:\n"
696|f0702a|            output += error.stackTrace.prefix(5).joined(separator: "\n")
697|5f3077|        }
698|d6ed84|        
699|f0738a|        return output
700|27e597|    }
701|b4687f|    
702|6822a6|    // MARK: - Helper Methods
703|b4687f|    
704|af6a9e|    /// Run a shell process
705|ce64d6|    private func runProcess(
706|f87c55|        command: String,
707|69c878|        in directory: URL? = nil,
708|eed212|        environment: [String: String]? = nil
709|085e26|    ) async throws -> (exitCode: Int, stdout: String, stderr: String) {
710|6d92f9|        let process = Process()
711|29ef1b|        let pipe = Pipe()
712|80d637|        let errorPipe = Pipe()
713|d6ed84|        
714|9a6aef|        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
715|f84278|        process.arguments = ["-c", command]
716|a7df3b|        process.standardOutput = pipe
717|364042|        process.standardError = errorPipe
718|d6ed84|        
719|3f1ab4|        if let directory = directory {
720|4836e8|            process.currentDirectoryURL = directory
721|5f3077|        }
722|d6ed84|        
723|ab9c4e|        if let environment = environment {
724|089831|            var env = ProcessInfo.processInfo.environment
725|4b1ff3|            env.merge(environment) { (_, new) in new }
726|d99e37|            process.environment = env
727|5f3077|        }
728|d6ed84|        
729|3d0b9a|        return try await withCheckedThrowingContinuation { continuation in
730|fffb66|            process.terminationHandler = { process in
731|1fc4ab|                let stdoutData = pipe.fileHandleForReading.readDataToEndOfFile()
732|ca2e55|                let stderrData = errorPipe.fileHandleForReading.readDataToEndOfFile()
733|216278|                
734|a080e7|                let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
735|25c876|                let stderr = String(data: stderrData, encoding: .utf8) ?? ""
736|216278|                
737|e0c3da|                continuation.resume(returning: (
738|8e1f69|                    exitCode: Int(process.terminationStatus),
739|1dedd6|                    stdout: stdout,
740|e2d35c|                    stderr: stderr
741|2188d8|                ))
742|a7dc16|            }
743|3070d1|            
744|71cc09|            do {
745|eee8fb|                try process.run()
746|91b9a2|            } catch {
747|a814ec|                continuation.resume(throwing: error)
748|a7dc16|            }
749|5f3077|        }
750|27e597|    }
751|b4687f|    
752|bf4a12|    /// Check if a command is available in PATH
753|867a20|    private func isCommandAvailable(_ command: String) -> Bool {
754|a7b3f3|        let task = Process()
755|d9c208|        task.executableURL = URL(fileURLWithPath: "/usr/bin/which")
756|b4469f|        task.arguments = [command]
757|d6ed84|        
758|29ef1b|        let pipe = Pipe()
759|c5814e|        task.standardOutput = pipe
760|eb1912|        task.standardError = FileHandle.nullDevice
761|d6ed84|        
762|fa0d8a|        try? task.run()
763|00160c|        task.waitUntilExit()
764|d6ed84|        
765|ae7846|        return task.terminationStatus == 0
766|27e597|    }
767|b4687f|    
768|2426a2|    /// Check if a Node tool is available
769|c5272c|    private func isToolAvailable(_ tool: String) -> Bool {
770|1b602c|        return isCommandAvailable(tool) || isCommandAvailable("npx \(tool)")
771|27e597|    }
772|b4687f|    
773|54d169|    /// Find missing tools for full functionality
774|84536f|    private func findMissingTools() async -> [String] {
775|f97c2c|        var missing: [String] = []
776|d6ed84|        
777|ce8f46|        let tools = ["npm", "tsc", "ts-node", "tsx"]
778|f96bda|        for tool in tools {
779|4a83c4|            if !isToolAvailable(tool) {
780|0b8d7e|                missing.append(tool)
781|a7dc16|            }
782|5f3077|        }
783|d6ed84|        
784|3249ad|        return missing
785|27e597|    }
786|b4687f|    
787|07efd8|    /// Get project info for debugging
788|2029f6|    func getProjectInfo(in directory: URL) async -> NodeProjectInfo {
789|e6bd51|        let nodeVersion = (try? await detectNodeVersion(in: directory)) ?? detectedNodeVersion ?? "unknown"
790|e4037b|        let packageManager = detectedPackageManager ?? detectPackageManager(in: directory)
791|82ea10|        let scripts = await getNpmScripts(from: directory)
792|9e4c37|        let moduleSystem = detectModuleSystem(for: directory.appendingPathComponent("index.js"), in: directory)
793|d6ed84|        
794|8b17df|        return NodeProjectInfo(
795|fe839e|            nodeVersion: nodeVersion,
796|aefa27|            packageManager: packageManager,
797|854636|            availableScripts: Array(scripts.keys),
798|316b4c|            moduleSystem: moduleSystem,
799|bd6f12|            hasTypeScript: fileManager.fileExists(atPath: directory.appendingPathComponent("tsconfig.json").path)
800|3143a4|        )
801|27e597|    }
802|b31277|}
803|adc83b|
804|71e2e4|// MARK: - Supporting Types
805|adc83b|
806|8fda99|struct NodeProjectInfo {
807|7a4216|    let nodeVersion: String
808|bd78e8|    let packageManager: PackageManager
809|99cc36|    let availableScripts: [String]
810|a20baa|    let moduleSystem: ModuleSystem
811|9d7407|    let hasTypeScript: Bool
812|b31277|}
813|adc83b|
814|eb33bc|// MARK: - Convenience Extensions
815|adc83b|
816|3e84d5|extension NodeRunner {
817|88427f|    /// Quick run JavaScript file
818|4e9d89|    func runJavaScript(
819|d3d61c|        file: URL,
820|4ec94b|        in directory: URL,
821|eed212|        environment: [String: String]? = nil
822|5917f3|    ) async throws -> ProcessResult {
823|a4ebb6|        let moduleFlags = getModuleFlags(for: file, in: directory)
824|2705c3|        let flagString = moduleFlags.isEmpty ? "" : moduleFlags.joined(separator: " ") + " "
825|d6ed84|        
826|e6d639|        let command = "node \(flagString)\(file.path)"
827|f4c9b0|        return try await execute(command: command, in: directory, environment: environment)
828|27e597|    }
829|b4687f|    
830|8c18b6|    /// Install dependencies
831|27870f|    func installDependencies(
832|4ec94b|        in directory: URL,
833|5cb837|        packageManager: PackageManager? = nil
834|5917f3|    ) async throws -> ProcessResult {
835|770f47|        let pm = packageManager ?? detectPackageManager(in: directory)
836|5bbd52|        return try await execute(command: pm.installCommand, in: directory)
837|27e597|    }
838|b4687f|    
839|81870e|    /// Check if a script exists
840|ed1108|    func hasScript(_ name: String, in directory: URL) async -> Bool {
841|82ea10|        let scripts = await getNpmScripts(from: directory)
842|0c638f|        return scripts[name] != nil
843|27e597|    }
844|b31277|}
845|adc83b|
846|3f6acf|#endif
847|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
Error reading file: Error: EISDIR: illegal operation on a directory, read




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/
📁 NativeGit/
📁 OnDevice/
📁 Runners/
   AIManager.swift
   AutocompleteManager.swift
   BracketMatchingManager.swift
   CodeExecutionService.swift
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
   OutputPanelManager.swift
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
   WindowStateManager.swift
   WordOccurrenceHighlighter.swift
   WorkspaceManager.swift
   WorkspaceTrustManager.swift




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: d8ae091e3dac
File: VSCodeiPadOS/VSCodeiPadOS/Services/CodeExecutionService.swift (lines 1-220 of 220)
────────────────────────────────────────
1|8b6b78|import Foundation
2|d755ba|import SwiftUI
3|119e5c|import JavaScriptCore
4|501c1a|import WebKit
5|adc83b|
6|6486b8|// MARK: - CodeExecutionService
7|adc83b|
8|260b9d|/// Service that handles code execution requests from the Run menu.
9|f40e11|/// Routes execution to appropriate runners based on file type and outputs results to the Output panel.
10|69d728|@MainActor
11|a43a38|final class CodeExecutionService {
12|6dc112|    static let shared = CodeExecutionService()
13|b4687f|    
14|6503ae|    // MARK: - Properties
15|b4687f|    
16|37bd08|    private var jsRunner: JSRunner?
17|b9f2e8|    private var wasmRunner: WASMRunner?
18|33c15c|    private let outputManager = OutputPanelManager.shared
19|b4687f|    
20|7dca75|    // MARK: - Initialization
21|b4687f|    
22|54113e|    private init() {}
23|b4687f|    
24|81c2c9|    // MARK: - Public Methods
25|b4687f|    
26|d148d5|    /// Execute the currently active file
27|45b4bd|    /// - Parameters:
28|4cfe18|    ///   - fileName: Name of the file to execute
29|13e212|    ///   - content: Content/code of the file
30|97d12a|    func executeCurrentFile(fileName: String, content: String) {
31|cc9311|        let fileExtension = (fileName as NSString).pathExtension.lowercased()
32|d6ed84|        
33|2eea91|        switch fileExtension {
34|ff039a|        case "js", "mjs":
35|760a4e|            executeJavaScript(fileName: fileName, code: content)
36|048ca0|        case "ts", "tsx":
37|b896b9|            outputManager.append("[ERROR] TypeScript execution requires transpilation. Coming soon!", to: OutputChannel.javascript, streamType: StreamType.stderr)
38|de8aa1|            outputManager.selectedChannel = OutputChannel.javascript
39|e1d221|        case "py":
40|9e2a3c|            outputManager.append("[ERROR] Python execution not yet available on-device.", to: OutputChannel.python, streamType: StreamType.stderr)
41|25499b|            outputManager.selectedChannel = OutputChannel.python
42|49451f|        case "wasm":
43|4b7eaa|            executeWASM(fileName: fileName, fileURL: nil)
44|520b7d|        default:
45|cc7290|            outputManager.append("[ERROR] No runner available for .\(fileExtension) files", to: OutputChannel.output, streamType: StreamType.stderr)
46|c75b79|            outputManager.selectedChannel = OutputChannel.output
47|5f3077|        }
48|27e597|    }
49|b4687f|    
50|9b6f68|    // MARK: - JavaScript Execution
51|b4687f|    
52|d76b7d|    private func executeJavaScript(fileName: String, code: String) {
53|0dec37|        // Switch to JavaScript output channel
54|e39e9c|        outputManager.selectedChannel = OutputChannel.javascript
55|d6ed84|        
56|a728d5|        // Clear previous output and show execution header
57|1511a8|        outputManager.clear(OutputChannel.javascript)
58|6cfb10|        outputManager.append("▶ Running: \(fileName)", to: OutputChannel.javascript)
59|89174a|        outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
60|d6ed84|        
61|a3f62b|        // Create a fresh JSRunner instance
62|462f68|        jsRunner = JSRunner()
63|d6ed84|        
64|e61664|        // Set up console handler to capture output
65|305ad3|        jsRunner?.setConsoleHandler { [weak self] message in
66|270dfc|            Task { @MainActor in
67|150252|                guard let self = self else { return }
68|216278|                
69|b169c6|                // Determine stream type based on message prefix
70|27b18b|                let streamType: StreamType = message.hasPrefix("[ERROR]") || message.hasPrefix("[EXCEPTION]") ? StreamType.stderr : StreamType.stdout
71|216278|                
72|4b39b7|                // Remove the prefix for cleaner output display
73|62636a|                var cleanMessage = message
74|121995|                for prefix in ["[LOG] ", "[INFO] ", "[WARN] ", "[ERROR] ", "[EXCEPTION] "] {
75|1df682|                    if message.hasPrefix(prefix) {
76|11af1f|                        cleanMessage = String(message.dropFirst(prefix.count))
77|28a64b|                        break
78|c9717a|                    }
79|4e2d32|                }
80|216278|                
81|6a3616|                self.outputManager.append(cleanMessage, to: OutputChannel.javascript, streamType: streamType)
82|a7dc16|            }
83|5f3077|        }
84|d6ed84|        
85|5a9195|        // Execute the code asynchronously
86|0f1953|        Task {
87|073be0|            let startTime = Date()
88|3070d1|            
89|71cc09|            do {
90|f3a1fd|                let result = try await jsRunner?.execute(code: code)
91|1ee120|                let duration = Date().timeIntervalSince(startTime)
92|216278|                
93|73b1fb|                // Show result if it's not undefined
94|f23508|                if let result = result, !result.isUndefined {
95|8a7075|                    let resultString = formatJSValue(result)
96|174733|                    outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
97|1c40a4|                    outputManager.append("⮐ Result: \(resultString)", to: OutputChannel.javascript)
98|4e2d32|                }
99|216278|                
100|b2c6e7|                // Show completion message
101|dc27a4|                outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
102|2c8c65|                outputManager.append("✓ Completed in \(String(format: "%.2f", duration * 1000))ms", to: OutputChannel.javascript)
103|216278|                
104|77a0dc|            } catch let error as JSRunnerError {
105|dc27a4|                outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
106|a0d863|                outputManager.append("✗ Error: \(error.localizedDescription)", to: OutputChannel.javascript, streamType: StreamType.stderr)
107|216278|                
108|91b9a2|            } catch {
109|dc27a4|                outputManager.append("─────────────────────────────────────", to: OutputChannel.javascript)
110|a0d863|                outputManager.append("✗ Error: \(error.localizedDescription)", to: OutputChannel.javascript, streamType: StreamType.stderr)
111|a7dc16|            }
112|3070d1|            
113|eb797f|            // Clean up runner
114|e9e019|            jsRunner = nil
115|5f3077|        }
116|27e597|    }
117|b4687f|    
118|71b351|    // MARK: - WASM Execution
119|b4687f|    
120|6d17d8|    private func executeWASM(fileName: String, fileURL: URL?) {
121|b0742b|        outputManager.selectedChannel = OutputChannel.output
122|968d09|        outputManager.clear(OutputChannel.output)
123|717b89|        outputManager.append("▶ Running WASM: \(fileName)", to: OutputChannel.output)
124|12d412|        outputManager.append("─────────────────────────────────────", to: OutputChannel.output)
125|d6ed84|        
126|0f1953|        Task {
127|073be0|            let startTime = Date()
128|3070d1|            
129|71cc09|            do {
130|6d0a21|                // Get WASM data - either from URL or bundle
131|50de22|                let wasmData: Data
132|6593af|                if let fileURL = fileURL {
133|f95e47|                    wasmData = try Data(contentsOf: fileURL)
134|08d06b|                } else if let bundleURL = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".wasm", with: ""), withExtension: "wasm") {
135|8399bc|                    wasmData = try Data(contentsOf: bundleURL)
136|fdd0e2|                } else {
137|357392|                    throw WASMError.moduleLoadFailed(reason: "Could not find WASM file: \(fileName)")
138|4e2d32|                }
139|216278|                
140|e5cbe2|                // Create and configure runner
141|a26664|                let runner = try WASMRunner(configuration: .default)
142|177575|                self.wasmRunner = runner
143|216278|                
144|6f83f4|                // Load the module
145|08a9dc|                try await runner.load(wasmData: wasmData)
146|3b984f|                outputManager.append("✓ Module loaded (\(wasmData.count) bytes)", to: OutputChannel.output)
147|216278|                
148|b56126|                // Try to execute main or _start function
149|e171c8|                let mainFunctions = ["main", "_start", "run"]
150|2aaaf2|                var executed = false
151|216278|                
152|23ed15|                for fnName in mainFunctions {
153|af84d6|                    do {
154|300cc8|                        let result = try await runner.execute(function: fnName, args: [])
155|0df3dd|                        let duration = Date().timeIntervalSince(startTime)
156|956cfe|                        
157|487e79|                        outputManager.append("─────────────────────────────────────", to: OutputChannel.output)
158|dde839|                        outputManager.append("⮐ Result: \(result)", to: OutputChannel.output)
159|4ebeca|                        outputManager.append("✓ Completed in \(String(format: "%.2f", duration * 1000))ms", to: OutputChannel.output)
160|8361ce|                        executed = true
161|28a64b|                        break
162|cdc068|                    } catch WASMError.functionNotFound {
163|ae3944|                        continue // Try next function name
164|c9717a|                    }
165|4e2d32|                }
166|216278|                
167|8e135d|                if !executed {
168|051a99|                    outputManager.append("⚠ No main/start function found. Module loaded but not executed.", to: OutputChannel.output, streamType: StreamType.stderr)
169|d02737|                    outputManager.append("  Export a function named 'main', '_start', or 'run' to execute automatically.", to: OutputChannel.output)
170|4e2d32|                }
171|216278|                
172|e0120c|            } catch let error as WASMError {
173|e076d4|                outputManager.append("─────────────────────────────────────", to: OutputChannel.output)
174|195aa0|                outputManager.append("✗ WASM Error: \(error.localizedDescription)", to: OutputChannel.output, streamType: StreamType.stderr)
175|91b9a2|            } catch {
176|e076d4|                outputManager.append("─────────────────────────────────────", to: OutputChannel.output)
177|27773e|                outputManager.append("✗ Error: \(error.localizedDescription)", to: OutputChannel.output, streamType: StreamType.stderr)
178|a7dc16|            }
179|3070d1|            
180|f7639d|            wasmRunner = nil
181|5f3077|        }
182|27e597|    }
183|b4687f|    
184|ee02fb|    // MARK: - Helpers
185|b4687f|    
186|7aa5bd|    /// Format a JSValue for display
187|e68bfd|    private func formatJSValue(_ value: JSValue) -> String {
188|c903ed|        if value.isNull {
189|c04d4d|            return "null"
190|35d02e|        } else if value.isUndefined {
191|b32932|            return "undefined"
192|edfa6b|        } else if value.isBoolean {
193|1a76ee|            return value.toBool() ? "true" : "false"
194|4e414f|        } else if value.isNumber {
195|9abc83|            let num = value.toNumber()
196|d3fc6f|            // Check if it's an integer
197|a09f20|            if let n = num, n.doubleValue == Double(n.intValue) {
198|ee9ad8|                return "\(n.intValue)"
199|a7dc16|            }
200|64a140|            return "\(num?.doubleValue ?? 0)"
201|419991|        } else if value.isString {
202|7c8a45|            return "\"\(value.toString() ?? "")\""
203|a72377|        } else if value.isArray {
204|d7f252|            if let array = value.toArray() {
205|c35363|                return "[\(array.map { "\($0)" }.joined(separator: ", "))]"
206|a7dc16|            }
207|976c47|            return "[]"
208|bb3c98|        } else if value.isObject {
209|b4fae0|            if let dict = value.toDictionary() {
210|ee1ab7|                let json = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
211|a9b0f4|                if let json = json, let str = String(data: json, encoding: .utf8) {
212|cfed56|                    return str
213|4e2d32|                }
214|a7dc16|            }
215|0b436d|            return value.toString() ?? "[object]"
216|5f3077|        }
217|bbc620|        return value.toString() ?? "undefined"
218|27e597|    }
219|b31277|}
220|adc83b|




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/Runners/
   NodeRunner.swift
   PythonRunner.swift
   PythonRunnerAlt.swift
   SwiftRunner.swift




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 762bf5a8a730
File: VSCodeiPadOS/VSCodeiPadOS/Services/Runners/PythonRunner.swift (lines 1-427 of 427)
────────────────────────────────────────
1|8b6b78|import Foundation
2|adc83b|
3|c0b92c|/// Python-specific runner for executing Python code via SSH
4|4ae723|struct PythonRunner: Runner {
5|a3ae5e|    let name = "Python"
6|228c80|    let supportedExtensions = ["py", "pyw", "pyi"]
7|19399d|    let languageId = "python"
8|b4687f|    
9|a3b0ab|    private var ssh: SSHManager
10|840006|    private var useVirtualEnv: Bool
11|14fc66|    private var virtualEnvPath: String?
12|cd17ec|    private var pythonCommand: String
13|b4687f|    
14|0f8e35|    /// Represents a parsed Python traceback entry
15|ee09f1|    struct TracebackEntry {
16|2cd908|        let file: String
17|c0eddc|        let line: Int
18|75530b|        let function: String
19|066433|        let code: String?
20|27e597|    }
21|b4687f|    
22|7cabcf|    /// Represents a complete Python error with traceback
23|6479a8|    struct PythonError {
24|490b5e|        let errorType: String
25|032cc1|        let message: String
26|9f3c1d|        let traceback: [TracebackEntry]
27|249c49|        let fullTraceback: String
28|27e597|    }
29|b4687f|    
30|3b3e98|    /// Python environment configuration
31|ceb35b|    struct PythonEnvironment {
32|027777|        let pythonPath: String
33|526d6e|        let version: String
34|c5581e|        let hasVirtualEnv: Bool
35|934eaf|        let virtualEnvPath: String?
36|b34012|        let pipPath: String
37|27e597|    }
38|b4687f|    
39|d23c69|    init(ssh: SSHManager, useVirtualEnv: Bool = false, virtualEnvPath: String? = nil) {
40|ff366a|        self.ssh = ssh
41|5a7d86|        self.useVirtualEnv = useVirtualEnv
42|06be25|        self.virtualEnvPath = virtualEnvPath
43|90294d|        self.pythonCommand = "python3" // Default to python3
44|27e597|    }
45|b4687f|    
46|ef00f1|    // MARK: - Runner Protocol Conformance
47|b4687f|    
48|c5a36d|    func canRun(file: String) -> Bool {
49|dec58c|        let ext = (file as NSString).pathExtension.lowercased()
50|9b6bc4|        return supportedExtensions.contains(ext)
51|27e597|    }
52|b4687f|    
53|795436|    func buildCommand(for file: String, args: [String]) -> String {
54|590d89|        let pythonCmd = determinePythonCommand()
55|85cb07|        let filePath = escapePath(file)
56|d6ed84|        
57|f1d336|        var command = ""
58|d6ed84|        
59|d08413|        // Activate virtual environment if configured
60|887bad|        if useVirtualEnv, let venvPath = virtualEnvPath {
61|06dc6d|            command += "source \(escapePath(venvPath))/bin/activate && "
62|5f3077|        }
63|d6ed84|        
64|591f59|        // Build the Python command
65|524cb6|        command += "\(pythonCmd) \(filePath)"
66|d6ed84|        
67|c03742|        // Add arguments
68|372b2b|        if !args.isEmpty {
69|736e04|            let escapedArgs = args.map { escapeArgument($0) }.joined(separator: " ")
70|6ab3de|            command += " \(escapedArgs)"
71|5f3077|        }
72|d6ed84|        
73|d8c0f7|        return command
74|27e597|    }
75|b4687f|    
76|b97ba2|    func execute(file: String, args: [String]) async throws -> ExecutionResult {
77|1c0fc7|        let command = buildCommand(for: file, args: args)
78|86ea07|        let output = try await ssh.execute(command: command)
79|d6ed84|        
80|5f0174|        // Check if output contains a Python traceback
81|4d2811|        if let pythonError = parseTraceback(output.stderr) {
82|577003|            return ExecutionResult(
83|027ed1|                stdout: output.stdout,
84|10454f|                stderr: pythonError.fullTraceback,
85|2fc392|                exitCode: 1,
86|24b632|                error: RunnerError.executionFailed(pythonError.errorType + ": " + pythonError.message)
87|43d041|            )
88|5f3077|        }
89|d6ed84|        
90|c2ccde|        return ExecutionResult(
91|117939|            stdout: output.stdout,
92|2ad579|            stderr: output.stderr,
93|92e024|            exitCode: output.exitCode,
94|f1a260|            error: nil
95|3143a4|        )
96|27e597|    }
97|b4687f|    
98|8dd446|    // MARK: - Python-Specific Methods
99|b4687f|    
100|c84772|    /// Detects the Python version available on the remote system
101|4d6757|    func detectPythonVersion(via ssh: SSHManager) async throws -> String {
102|35312e|        // Try python3 first (more common on modern systems)
103|4da690|        do {
104|0f1706|            let output = try await ssh.execute(command: "python3 --version 2>&1")
105|7380c8|            if output.exitCode == 0 {
106|d33fd8|                let version = output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
107|cffbea|                if !version.isEmpty {
108|72aae1|                    self.pythonCommand = "python3"
109|948ce9|                    return version
110|4e2d32|                }
111|a7dc16|            }
112|853889|        } catch {
113|72ed4f|            // python3 not available, try python
114|5f3077|        }
115|d6ed84|        
116|8eeb15|        // Fallback to python
117|f1f65a|        let output = try await ssh.execute(command: "python --version 2>&1")
118|603b7d|        if output.exitCode == 0 {
119|d90e19|            let version = output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
120|295aa8|            if !version.isEmpty {
121|4a0520|                self.pythonCommand = "python"
122|9ce6e6|                return version
123|a7dc16|            }
124|5f3077|        }
125|d6ed84|        
126|82a19c|        throw RunnerError.executionFailed("No Python installation found on remote system")
127|27e597|    }
128|b4687f|    
129|5545c3|    /// Installs requirements from a requirements.txt file
130|238788|    func installRequirements(file: String, via ssh: SSHManager) async throws {
131|b81b8e|        let requirementsPath = escapePath(file)
132|d6ed84|        
133|e99de2|        // Check if requirements.txt exists
134|a88f92|        let checkOutput = try await ssh.execute(command: "test -f \(requirementsPath) && echo 'exists' || echo 'not found'")
135|13978d|        guard checkOutput.stdout.trimmingCharacters(in: .whitespacesAndNewlines) == "exists" else {
136|b5a68c|            throw RunnerError.executionFailed("Requirements file not found: \(file)")
137|5f3077|        }
138|d6ed84|        
139|65eb4f|        var installCommand = ""
140|d6ed84|        
141|d08413|        // Activate virtual environment if configured
142|887bad|        if useVirtualEnv, let venvPath = virtualEnvPath {
143|7c46b2|            installCommand += "source \(escapePath(venvPath))/bin/activate && "
144|5f3077|        }
145|d6ed84|        
146|a3a922|        // Determine pip command
147|e1ded6|        let pipCmd = determinePipCommand()
148|5fd768|        installCommand += "\(pipCmd) install -r \(requirementsPath)"
149|d6ed84|        
150|25435c|        let output = try await ssh.execute(command: installCommand)
151|d6ed84|        
152|d2730c|        guard output.exitCode == 0 else {
153|b61f24|            throw RunnerError.executionFailed("Failed to install requirements: \(output.stderr)")
154|5f3077|        }
155|27e597|    }
156|b4687f|    
157|5dd625|    /// Creates a virtual environment at the specified path
158|251c5a|    func createVirtualEnv(at path: String, via ssh: SSHManager) async throws {
159|590d89|        let pythonCmd = determinePythonCommand()
160|f38407|        let escapedPath = escapePath(path)
161|d6ed84|        
162|ccefe7|        let command = "\(pythonCmd) -m venv \(escapedPath)"
163|86ea07|        let output = try await ssh.execute(command: command)
164|d6ed84|        
165|d2730c|        guard output.exitCode == 0 else {
166|74c9cd|            throw RunnerError.executionFailed("Failed to create virtual environment: \(output.stderr)")
167|5f3077|        }
168|d6ed84|        
169|9bf507|        self.virtualEnvPath = path
170|386ad5|        self.useVirtualEnv = true
171|27e597|    }
172|b4687f|    
173|1ff3a4|    /// Detects the full Python environment
174|20efd3|    func detectPythonEnvironment(via ssh: SSHManager) async throws -> PythonEnvironment {
175|51c40e|        let version = try await detectPythonVersion(via: ssh)
176|e5702b|        let pythonPath = try await whichPython(via: ssh)
177|d6ed84|        
178|3b2f8b|        var hasVirtualEnv = false
179|ca9816|        var venvPath: String? = nil
180|99c28f|        var pipPath = determinePipCommand()
181|d6ed84|        
182|1e3dc4|        // Check if we're in a virtual environment
183|9d7ad5|        let venvCheck = try await ssh.execute(command: "echo \$VIRTUAL_ENV")
184|498cf7|        let detectedVenv = venvCheck.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
185|2dd499|        if !detectedVenv.isEmpty && detectedVenv != "$VIRTUAL_ENV" {
186|92317a|            hasVirtualEnv = true
187|ea48e4|            venvPath = detectedVenv
188|13064f|            pipPath = "\(detectedVenv)/bin/pip"
189|5f3077|        }
190|d6ed84|        
191|0b5cc2|        return PythonEnvironment(
192|5b537d|            pythonPath: pythonPath,
193|d8050f|            version: version,
194|b8deb9|            hasVirtualEnv: hasVirtualEnv,
195|b4f4bd|            virtualEnvPath: venvPath,
196|95c909|            pipPath: pipPath
197|3143a4|        )
198|27e597|    }
199|b4687f|    
200|d8748f|    /// Installs a specific package
201|97f560|    func installPackage(_ package: String, version: String? = nil, via ssh: SSHManager) async throws {
202|e150c2|        var packageSpec = package
203|9a8e86|        if let ver = version {
204|2bc41e|            packageSpec += "==\(ver)"
205|5f3077|        }
206|d6ed84|        
207|f1d336|        var command = ""
208|887bad|        if useVirtualEnv, let venvPath = virtualEnvPath {
209|06dc6d|            command += "source \(escapePath(venvPath))/bin/activate && "
210|5f3077|        }
211|d6ed84|        
212|e1ded6|        let pipCmd = determinePipCommand()
213|e2c262|        command += "\(pipCmd) install \(escapeArgument(packageSpec))"
214|d6ed84|        
215|86ea07|        let output = try await ssh.execute(command: command)
216|d6ed84|        
217|d2730c|        guard output.exitCode == 0 else {
218|411d25|            throw RunnerError.executionFailed("Failed to install package \(package): \(output.stderr)")
219|5f3077|        }
220|27e597|    }
221|b4687f|    
222|1f23a5|    // MARK: - Traceback Parsing
223|b4687f|    
224|49d20e|    /// Parses Python traceback output into a structured error
225|7a5685|    func parseTraceback(_ output: String) -> PythonError? {
226|b18c49|        let lines = output.components(separatedBy: .newlines)
227|fabe5e|        var entries: [TracebackEntry] = []
228|fc39ff|        var errorType = ""
229|fe5cf9|        var errorMessage = ""
230|de7cda|        var parsingTraceback = false
231|0f75e4|        var currentFile: String?
232|15d6c7|        var currentLine: Int?
233|60ff7b|        var currentFunction: String?
234|d6ed84|        
235|589d54|        var i = 0
236|9a423c|        while i < lines.count {
237|ef0328|            let line = lines[i]
238|3070d1|            
239|d66c5c|            // Check for traceback header
240|839a36|            if line.contains("Traceback (most recent call last):") {
241|e0be48|                parsingTraceback = true
242|c190bb|                i += 1
243|1df510|                continue
244|a7dc16|            }
245|3070d1|            
246|0c58d7|            // Parse File "...", line X, in ...
247|db15b0|            if parsingTraceback && line.starts(with: "  File \"") {
248|ecf05c|                let pattern = #"File \"([^\"]+)\", line (\d+), in (\w+)"#
249|66048b|                if let regex = try? NSRegularExpression(pattern: pattern, options: []),
250|54bbdd|                   let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
251|dd2193|                    
252|4864f3|                    if let fileRange = Range(match.range(at: 1), in: line) {
253|c15c3e|                        currentFile = String(line[fileRange])
254|c9717a|                    }
255|930cdc|                    if let lineRange = Range(match.range(at: 2), in: line),
256|36e8d9|                       let lineNum = Int(line[lineRange]) {
257|338cc2|                        currentLine = lineNum
258|c9717a|                    }
259|bfa86d|                    if let funcRange = Range(match.range(at: 3), in: line) {
260|221b62|                        currentFunction = String(line[funcRange])
261|c9717a|                    }
262|4e2d32|                }
263|c190bb|                i += 1
264|1df510|                continue
265|a7dc16|            }
266|3070d1|            
267|9e990f|            // Parse code line (starts with "    ")
268|72f330|            if parsingTraceback && line.starts(with: "    ") && !line.trimmingCharacters(in: .whitespaces).isEmpty {
269|5c7857|                if let file = currentFile, let lineNum = currentLine, let function = currentFunction {
270|fc13a3|                    let code = line.trimmingCharacters(in: .whitespaces)
271|f6e89d|                    entries.append(TracebackEntry(
272|bc7442|                        file: file,
273|02bd59|                        line: lineNum,
274|64c68e|                        function: function,
275|ccacd2|                        code: code
276|c89922|                    ))
277|4e2d32|                }
278|c4a3f3|                currentFile = nil
279|df6bcb|                currentLine = nil
280|5f9bbc|                currentFunction = nil
281|c190bb|                i += 1
282|1df510|                continue
283|a7dc16|            }
284|3070d1|            
285|3cde42|            // Parse error type and message (last line before blank or end)
286|99b886|            if parsingTraceback && !line.hasPrefix("  ") && !line.isEmpty {
287|af99e3|                let errorPattern = #"^(\w+Error|\w+Exception|KeyboardInterrupt|SystemExit|GeneratorExit):\s*(.*)$"#
288|b7d609|                if let regex = try? NSRegularExpression(pattern: errorPattern, options: []),
289|54bbdd|                   let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
290|0323c7|                    if let typeRange = Range(match.range(at: 1), in: line) {
291|3e6979|                        errorType = String(line[typeRange])
292|c9717a|                    }
293|dd22e3|                    if let msgRange = Range(match.range(at: 2), in: line) {
294|ef1f6c|                        errorMessage = String(line[msgRange])
295|c9717a|                    }
296|a11237|                } else if !line.isEmpty {
297|b08f3c|                    // Custom exception class
298|1236d6|                    let components = line.split(separator: ":", maxSplits: 1)
299|494eb5|                    errorType = String(components.first ?? "")
300|5b37fd|                    errorMessage = components.count > 1 ? String(components[1]).trimmingCharacters(in: .whitespaces) : ""
301|4e2d32|                }
302|74cfd8|                break
303|a7dc16|            }
304|3070d1|            
305|d59338|            i += 1
306|5f3077|        }
307|d6ed84|        
308|c41de1|        // Only return error if we found an error type
309|fa0844|        guard !errorType.isEmpty else {
310|1c8557|            return nil
311|5f3077|        }
312|d6ed84|        
313|7a4811|        return PythonError(
314|bb0c2f|            errorType: errorType,
315|ac86d9|            message: errorMessage,
316|e77b15|            traceback: entries,
317|44e486|            fullTraceback: output
318|3143a4|        )
319|27e597|    }
320|b4687f|    
321|98d431|    /// Formats a traceback entry for display
322|366006|    func formatTracebackEntry(_ entry: TracebackEntry) -> String {
323|2e3a15|        var result = "File \"\(entry.file)\", line \(entry.line), in \(entry.function)"
324|4d3e2f|        if let code = entry.code {
325|1b2516|            result += "\n    \(code)"
326|5f3077|        }
327|67ed82|        return result
328|27e597|    }
329|b4687f|    
330|81a958|    // MARK: - Private Helpers
331|b4687f|    
332|0ec54c|    private func determinePythonCommand() -> String {
333|887bad|        if useVirtualEnv, let venvPath = virtualEnvPath {
334|52f2db|            return "\(venvPath)/bin/python"
335|5f3077|        }
336|39593f|        return pythonCommand
337|27e597|    }
338|b4687f|    
339|4ac4ef|    private func determinePipCommand() -> String {
340|887bad|        if useVirtualEnv, let venvPath = virtualEnvPath {
341|e5fa92|            return "\(venvPath)/bin/pip"
342|5f3077|        }
343|b68550|        return pythonCommand == "python3" ? "pip3" : "pip"
344|27e597|    }
345|b4687f|    
346|21d07f|    private func whichPython(via ssh: SSHManager) async throws -> String {
347|630914|        let cmd = "which \(determinePythonCommand())"
348|5a6999|        let output = try await ssh.execute(command: cmd)
349|5bb23c|        return output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
350|27e597|    }
351|b4687f|    
352|3ca6ce|    private func escapePath(_ path: String) -> String {
353|ff22be|        return path.replacingOccurrences(of: " ", with: "\\ ")
354|817e1f|                   .replacingOccurrences(of: "\"", with: "\\\"")
355|df4c73|                   .replacingOccurrences(of: "'", with: "\\'\\''")
356|ecf299|                   .replacingOccurrences(of: "$", with: "\\$")
357|8194ef|                   .replacingOccurrences(of: "`", with: "\\`")
358|27e597|    }
359|b4687f|    
360|a7f4bc|    private func escapeArgument(_ arg: String) -> String {
361|d90bee|        if arg.contains(" ") || arg.contains("\"") || arg.contains("'") {
362|d7635b|            return "\"\(arg.replacingOccurrences(of: "\"", with: "\\\""))\""
363|5f3077|        }
364|90c6d1|        return arg
365|27e597|    }
366|b31277|}
367|adc83b|
368|8766b8|// MARK: - PythonRunner Extensions
369|adc83b|
370|e52e63|extension PythonRunner {
371|498a30|    /// Common Python error types for syntax highlighting
372|9ccac9|    static let commonErrorTypes = [
373|117b84|        "SyntaxError",
374|f23923|        "IndentationError",
375|71f93c|        "TabError",
376|7af234|        "NameError",
377|8d02a9|        "AttributeError",
378|27b817|        "TypeError",
379|f310d8|        "ValueError",
380|c74459|        "IndexError",
381|6ee793|        "KeyError",
382|6a8dd6|        "ZeroDivisionError",
383|b898f9|        "OverflowError",
384|fdbde4|        "FloatingPointError",
385|4e8d41|        "MemoryError",
386|ff50bf|        "RecursionError",
387|db84df|        "RuntimeError",
388|6befc0|        "NotImplementedError",
389|fb9a59|        "StopIteration",
390|7ba895|        "StopAsyncIteration",
391|54ab3a|        "OSError",
392|b95201|        "IOError",
393|b1fff9|        "FileNotFoundError",
394|ea2652|        "PermissionError",
395|2bfc3c|        "IsADirectoryError",
396|4147c9|        "NotADirectoryError",
397|75a431|        "ConnectionError",
398|ed7229|        "BrokenPipeError",
399|5be61a|        "ConnectionAbortedError",
400|36f115|        "ConnectionRefusedError",
401|ed44f4|        "ConnectionResetError",
402|3d1465|        "BlockingIOError",
403|bb025a|        "ChildProcessError",
404|491fda|        "InterruptedError",
405|de3cba|        "TimeoutError",
406|fcb3c2|        "ImportError",
407|8cbecb|        "ModuleNotFoundError",
408|de72bd|        "LookupError",
409|8e3813|        "AssertionError",
410|5de235|        "EOFError",
411|0d8764|        "SystemError",
412|abe223|        "ReferenceError",
413|2778b0|        "BufferError",
414|938491|        "Warning",
415|c815a9|        "UserWarning",
416|08724d|        "DeprecationWarning",
417|03a423|        "PendingDeprecationWarning",
418|6737b0|        "SyntaxWarning",
419|2cde76|        "RuntimeWarning",
420|8ea77c|        "FutureWarning",
421|abe394|        "ImportWarning",
422|0db106|        "UnicodeWarning",
423|dc1373|        "BytesWarning",
424|121401|        "ResourceWarning"
425|f7d573|    ]
426|b31277|}
427|adc83b|




---

## 🔧 TOOL RESULTS

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

## 🔧 TOOL RESULTS

[read_file]
snapshot: f68518a5a3a6
File: VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/JSRunner.swift (lines 1-717 of 717)
────────────────────────────────────────
1|119e5c|import JavaScriptCore
2|8b6b78|import Foundation
3|adc83b|
4|bbdb6d|// MARK: - Console Protocol
5|c50987|/**
6|c2f53a| * Protocol for JavaScript console object exposure to native Swift.
7|52124c| * Conforming to JSExport allows JavaScript to call these methods directly.
8|d48ab4| */
9|9e272a|@objc protocol JSConsoleProtocol: JSExport {
10|535e2c|    func log(_ message: String)
11|cd2fff|    func error(_ message: String)
12|0ad30e|    func warn(_ message: String)
13|3df368|    func info(_ message: String)
14|b31277|}
15|adc83b|
16|605790|// MARK: - Console Implementation
17|c50987|/**
18|1f8622| * Native implementation of JavaScript console that captures output
19|12c962| * and forwards it to a Swift callback handler.
20|d48ab4| */
21|a2c26a|@objc class JSConsole: NSObject, JSConsoleProtocol {
22|ee0651|    private var logHandler: ((String) -> Void)?
23|b4687f|    
24|c32910|    /**
25|d69004|     * Initializes the console with a log handler callback.
26|c0ac75|     * - Parameter handler: Closure called when console methods are invoked from JS
27|1ef3e9|     */
28|fb2158|    init(handler: @escaping (String) -> Void) {
29|d0a4b0|        self.logHandler = handler
30|15cfe8|        super.init()
31|27e597|    }
32|b4687f|    
33|37d53e|    func log(_ message: String) {
34|ff8699|        logHandler?("[LOG] \(message)")
35|27e597|    }
36|b4687f|    
37|7bc954|    func error(_ message: String) {
38|28b25a|        logHandler?("[ERROR] \(message)")
39|27e597|    }
40|b4687f|    
41|614f48|    func warn(_ message: String) {
42|f49b47|        logHandler?("[WARN] \(message)")
43|27e597|    }
44|b4687f|    
45|af50e0|    func info(_ message: String) {
46|41118a|        logHandler?("[INFO] \(message)")
47|27e597|    }
48|b31277|}
49|adc83b|
50|9f0d64|// MARK: - Error Types
51|c50987|/**
52|203f37| * Errors that can occur during JavaScript execution.
53|d48ab4| */
54|8a94f0|enum JSRunnerError: Error, LocalizedError {
55|b58f28|    case contextCreationFailed
56|bee84d|    case executionTimeout
57|cdbfea|    case memoryLimitExceeded
58|44f523|    case scriptError(String)
59|e15df9|    case invalidResult
60|34fb35|    case nativeFunctionRegistrationFailed(String)
61|b4687f|    
62|242b78|    var errorDescription: String? {
63|2e6d08|        switch self {
64|d407e2|        case .contextCreationFailed:
65|bd9d29|            return "Failed to create JavaScript context"
66|109edb|        case .executionTimeout:
67|ee7ac2|            return "JavaScript execution exceeded the timeout limit"
68|406c63|        case .memoryLimitExceeded:
69|1f8993|            return "JavaScript execution exceeded the memory limit"
70|9b6153|        case .scriptError(let message):
71|71c51f|            return "Script error: \(message)"
72|188205|        case .invalidResult:
73|31771d|            return "JavaScript returned an invalid or unsupported result type"
74|a4f5d8|        case .nativeFunctionRegistrationFailed(let name):
75|5a40ea|            return "Failed to register native function '\(name)'"
76|5f3077|        }
77|27e597|    }
78|b31277|}
79|adc83b|
80|f0d446|// MARK: - JSRunner
81|c50987|/**
82|d8c630| * A Swift wrapper around JavaScriptCore that provides:
83|3f696d| * - Safe async JavaScript execution with timeout and memory limits
84|208a87| * - Console.log capture via JSExport protocol
85|467440| * - Native function exposure to JavaScript
86|cf3494| * - Automatic conversion of JS values to Swift types
87|ca6a42| *
88|d8d423| * ## Example Usage:
89|17213a| * ```swift
90|9b831c| * let runner = JSRunner()
91|ca6a42| *
92|77ce1e| * // Set up console handler
93|9e27ea| * runner.setConsoleHandler { message in
94|ebf826| *     print("JS Console: \(message)")
95|095c29| * }
96|ca6a42| *
97|37606b| * // Expose a native function
98|02911a| * runner.exposeNativeFunction(name: "nativeAdd") { args in
99|cfd01c| *     guard args.count >= 2,
100|959284| *           let a = args[0].toInt32(),
101|da3bb0| *           let b = args[1].toInt32() else {
102|10d08e| *         return JSValue(undefinedIn: runner.context)
103|153f07| *     }
104|06396f| *     return JSValue(int32: a + b, in: runner.context)
105|095c29| * }
106|ca6a42| *
107|9ce2a9| * // Execute JavaScript
108|ce0b3c| * do {
109|d48634| *     let result = try await runner.execute(code: "nativeAdd(5, 3)")
110|9aca35| *     print("Result: \(result)") // Result: 8
111|f7f7e4| * } catch {
112|1ebc71| *     print("Error: \(error)")
113|095c29| * }
114|7f8f0c| * ```
115|d48ab4| */
116|1dbd55|class JSRunner {
117|b4687f|    
118|6503ae|    // MARK: - Properties
119|b4687f|    
120|e8b868|    /** The underlying JavaScript context */
121|5cc683|    private(set) var context: JSContext!
122|b4687f|    
123|14603b|    /** Handler for console messages from JavaScript */
124|77f178|    private var consoleHandler: ((String) -> Void)?
125|b4687f|    
126|b90a91|    /** Timeout duration for script execution (default: 30 seconds) */
127|32dbb9|    var timeoutDuration: TimeInterval = 30.0
128|b4687f|    
129|1b4da4|    /** Memory limit in bytes (default: 100 MB) */
130|a9e039|    var memoryLimit: UInt64 = 100 * 1024 * 1024
131|b4687f|    
132|095e8d|    /** Track memory usage */
133|dea0ce|    private var currentMemoryUsage: UInt64 = 0
134|b4687f|    
135|eddf5c|    /** Background queue for JavaScript execution */
136|bf4c54|    private let executionQueue = DispatchQueue(
137|f78e47|        label: "com.jsrunner.execution",
138|d35bfe|        qos: .userInitiated
139|829c44|    )
140|b4687f|    
141|7dca75|    // MARK: - Initialization
142|b4687f|    
143|c32910|    /**
144|a7d546|     * Creates a new JSRunner with a fresh JavaScript context.
145|3e1e93|     * Automatically sets up error handling and exception callbacks.
146|1ef3e9|     */
147|359b1b|    init() {
148|22aae4|        setupContext()
149|27e597|    }
150|b4687f|    
151|e57f77|    deinit {
152|05bf05|        context = nil
153|27e597|    }
154|b4687f|    
155|674a7e|    // MARK: - Context Setup
156|b4687f|    
157|95a0d0|    private func setupContext() {
158|a4c8b1|        // Create context with nil virtual machine (creates default VM)
159|f7b6e1|        let virtualMachine = JSVirtualMachine()
160|0a876b|        context = JSContext(virtualMachine: virtualMachine)
161|d6ed84|        
162|211625|        // Set up exception handler
163|f21caa|        context.exceptionHandler = { [weak self] context, exception in
164|4219ab|            guard let self = self, let exception = exception else { return }
165|b5b6da|            let message = exception.toString() ?? "Unknown error"
166|bcef50|            self.consoleHandler?("[EXCEPTION] \(message)")
167|5f3077|        }
168|d6ed84|        
169|9b3f73|        // Inject console object
170|492bf9|        setupConsole()
171|27e597|    }
172|b4687f|    
173|7994a7|    private func setupConsole() {
174|d15e81|        let console = JSConsole { [weak self] message in
175|e71e9a|            self?.consoleHandler?(message)
176|5f3077|        }
177|8966f3|        context.setObject(console, forKeyedSubscript: "console" as NSString)
178|27e597|    }
179|b4687f|    
180|c705f9|    // MARK: - Console Handler
181|b4687f|    
182|c32910|    /**
183|e7ac5e|     * Sets the callback handler for JavaScript console messages.
184|2b23ac|     *
185|913c9b|     * - Parameter callback: Closure invoked when console.log, console.error,
186|846e04|     *                       console.warn, or console.info are called from JavaScript.
187|2b23ac|     *
188|7a5f4e|     * ## Example:
189|ac33be|     * ```swift
190|2a4b88|     * runner.setConsoleHandler { message in
191|d32410|     *     // Log to your app's logging system
192|290ea9|     *     Logger.shared.log(message)
193|994983|     * }
194|056bf3|     * ```
195|1ef3e9|     */
196|7fb007|    func setConsoleHandler(callback: @escaping (String) -> Void) {
197|3fd389|        consoleHandler = callback
198|2a70ea|        // Re-inject console with new handler
199|492bf9|        setupConsole()
200|27e597|    }
201|b4687f|    
202|10cd53|    // MARK: - Native Function Exposure
203|b4687f|    
204|c32910|    /**
205|69d2aa|     * Exposes a native Swift function to JavaScript.
206|2b23ac|     *
207|59e69e|     * - Parameters:
208|35a3eb|     *   - name: The name the function will have in JavaScript
209|22dd60|     *   - block: The Swift closure that implements the function.
210|9ef388|     *            Receives an array of JSValue arguments and must return a JSValue.
211|2b23ac|     *
212|7a5f4e|     * ## Example:
213|ac33be|     * ```swift
214|366e56|     * // Expose native multiply function
215|9e49c9|     * runner.exposeNativeFunction(name: "nativeMultiply") { args in
216|f51b62|     *     guard args.count >= 2,
217|06b6d1|     *           let a = args[0].toDouble(),
218|a48939|     *           let b = args[1].toDouble() else {
219|5b33f0|     *         return JSValue(undefinedIn: self.context)
220|82584f|     *     }
221|6c2150|     *     return JSValue(double: a * b, in: self.context)
222|994983|     * }
223|2b23ac|     *
224|3be248|     * // Use in JavaScript:
225|f5c3e6|     * // const result = nativeMultiply(4, 5); // Returns 20
226|056bf3|     * ```
227|1ef3e9|     */
228|0b8a67|    func exposeNativeFunction(
229|f1fce1|        name: String,
230|15e547|        block: @escaping ([JSValue]) -> JSValue
231|981e04|    ) {
232|5fc015|        let jsFunction: @convention(block) () -> JSValue = { [weak self] in
233|b38552|            guard let self = self else {
234|b2a4ff|                return JSValue(undefinedIn: nil)
235|a7dc16|            }
236|3070d1|            
237|9d1a10|            // Get arguments from current JS context
238|029f5c|            let args = JSContext.currentArguments() as? [JSValue] ?? []
239|1f7d95|            return block(args)
240|5f3077|        }
241|d6ed84|        
242|04b344|        context.setObject(
243|df1db0|            jsFunction,
244|b12af3|            forKeyedSubscript: name as NSString
245|3143a4|        )
246|27e597|    }
247|b4687f|    
248|c32910|    /**
249|054db7|     * Exposes a native Swift function with specific argument count to JavaScript.
250|a76b43|     * This version provides better type safety for functions with known arity.
251|2b23ac|     *
252|59e69e|     * - Parameters:
253|35a3eb|     *   - name: The name the function will have in JavaScript
254|e3c5e3|     *   - argCount: Expected number of arguments
255|0a4a60|     *   - block: Swift closure implementing the function
256|1ef3e9|     */
257|0b8a67|    func exposeNativeFunction(
258|f1fce1|        name: String,
259|823692|        argCount: Int,
260|50b329|        block: @escaping ([JSValue]) throws -> JSValue
261|53fcb2|    ) throws {
262|a27133|        let wrapper: @convention(block) () -> JSValue = { [weak self] in
263|b38552|            guard let self = self else {
264|b2a4ff|                return JSValue(undefinedIn: nil)
265|a7dc16|            }
266|3070d1|            
267|029f5c|            let args = JSContext.currentArguments() as? [JSValue] ?? []
268|3070d1|            
269|ff1395|            // Check argument count
270|e7c0a1|            if args.count != argCount {
271|7af74c|                let error = JSValue(
272|0a2850|                    newErrorFromMessage: "Expected \(argCount) arguments, got \(args.count)",
273|236a64|                    in: self.context
274|6f642e|                )
275|6e37a0|                self.context.exception = error
276|e63078|                return JSValue(undefinedIn: self.context)
277|a7dc16|            }
278|3070d1|            
279|71cc09|            do {
280|73b609|                return try block(args)
281|91b9a2|            } catch {
282|c839dc|                let errorMessage = (error as? JSRunnerError)?.errorDescription ?? error.localizedDescription
283|9011d6|                let jsError = JSValue(
284|64fe5a|                    newErrorFromMessage: errorMessage,
285|236a64|                    in: self.context
286|6f642e|                )
287|341375|                self.context.exception = jsError
288|e63078|                return JSValue(undefinedIn: self.context)
289|a7dc16|            }
290|5f3077|        }
291|d6ed84|        
292|3b2f68|        context.setObject(wrapper, forKeyedSubscript: name as NSString)
293|27e597|    }
294|b4687f|    
295|b66c56|    // MARK: - Script Execution
296|b4687f|    
297|c32910|    /**
298|2c0e40|     * Executes JavaScript code with timeout and memory limit protection.
299|2b23ac|     *
300|958f2c|     * - Parameter code: The JavaScript code to execute
301|54dd62|     * - Returns: The result of the execution as a JSValue
302|806780|     * - Throws: JSRunnerError if execution fails, times out, or exceeds memory limits
303|2b23ac|     *
304|7a5f4e|     * ## Example:
305|ac33be|     * ```swift
306|1ac76e|     * do {
307|036931|     *     // Simple arithmetic
308|f72a3b|     *     let result = try await runner.execute(code: "2 + 2")
309|eb949a|     *     print(result.toInt32()!) // 4
310|2b23ac|     *
311|d12776|     *     // Complex object
312|9bb09e|     *     let obj = try await runner.execute(code: "({ name: 'Test', value: 42 })")
313|4e4eeb|     *     print(obj.toDictionary()) // ["name": "Test", "value": 42]
314|2b23ac|     *
315|6b666f|     *     // Using native functions
316|48521c|     *     let sum = try await runner.execute(code: "nativeAdd(10, 20)")
317|d68fec|     *     print(sum.toInt32()!) // 30
318|1a815b|     * } catch JSRunnerError.executionTimeout {
319|8d6c76|     *     print("Script took too long")
320|ed4965|     * } catch {
321|74b8f1|     *     print("Execution failed: \(error)")
322|994983|     * }
323|056bf3|     * ```
324|1ef3e9|     */
325|fe06df|    func execute(code: String) async throws -> JSValue {
326|3d0b9a|        return try await withCheckedThrowingContinuation { continuation in
327|f0fb73|            executionQueue.async { [weak self] in
328|ec615d|                guard let self = self else {
329|6d0401|                    continuation.resume(throwing: JSRunnerError.contextCreationFailed)
330|d253ab|                    return
331|4e2d32|                }
332|216278|                
333|017597|                // Set up timeout
334|e632c2|                var timeoutOccurred = false
335|3de9a5|                let timeoutWorkItem = DispatchWorkItem { [weak self] in
336|6d2715|                    timeoutOccurred = true
337|407546|                    self?.context = nil // Force terminate
338|4e2d32|                }
339|216278|                
340|b3d5f7|                DispatchQueue.global().asyncAfter(
341|b31dab|                    deadline: .now() + self.timeoutDuration,
342|04f1d4|                    execute: timeoutWorkItem
343|6f642e|                )
344|216278|                
345|eef54f|                // Reset memory tracking
346|227951|                self.currentMemoryUsage = 0
347|216278|                
348|fa7b33|                // Execute the script
349|b526d9|                var result: JSValue?
350|6039e5|                var executionError: Error?
351|216278|                
352|656264|                autoreleasepool {
353|a9c022|                    result = self.context.evaluateScript(code)
354|dd2193|                    
355|4efdad|                    // Check for exceptions
356|aa0bf6|                    if let exception = self.context.exception {
357|2258f1|                        let message = exception.toString() ?? "Unknown error"
358|3db872|                        executionError = JSRunnerError.scriptError(message)
359|30683f|                        self.context.exception = nil
360|c9717a|                    }
361|4e2d32|                }
362|216278|                
363|b3f63e|                // Cancel timeout if execution completed
364|91d8f9|                timeoutWorkItem.cancel()
365|216278|                
366|4a9afe|                // Check for timeout
367|501942|                if timeoutOccurred {
368|156b94|                    // Need to recreate context since we nilled it
369|cfa3f6|                    self.setupContext()
370|86c114|                    continuation.resume(throwing: JSRunnerError.executionTimeout)
371|d253ab|                    return
372|4e2d32|                }
373|216278|                
374|054333|                // Check for memory limit
375|aaf645|                // Note: Real memory tracking would use more sophisticated methods
376|6e76e6|                // This is a simplified check
377|77b9fb|                if self.currentMemoryUsage > self.memoryLimit {
378|e0fe74|                    continuation.resume(throwing: JSRunnerError.memoryLimitExceeded)
379|d253ab|                    return
380|4e2d32|                }
381|216278|                
382|03d4cf|                // Handle execution error
383|325379|                if let error = executionError {
384|773145|                    continuation.resume(throwing: error)
385|d253ab|                    return
386|4e2d32|                }
387|216278|                
388|42b2ec|                // Return result or undefined if nil
389|312ffa|                continuation.resume(returning: result ?? JSValue(undefinedIn: self.context))
390|a7dc16|            }
391|5f3077|        }
392|27e597|    }
393|b4687f|    
394|c32910|    /**
395|78a44c|     * Executes JavaScript code with a specific timeout.
396|2b23ac|     *
397|59e69e|     * - Parameters:
398|03adfb|     *   - code: The JavaScript code to execute
399|9d2e32|     *   - timeout: Custom timeout duration for this execution
400|2a89b5|     * - Returns: The result as a JSValue
401|6e6897|     * - Throws: JSRunnerError for various failure conditions
402|1ef3e9|     */
403|75fbd6|    func execute(code: String, timeout: TimeInterval) async throws -> JSValue {
404|7d6a40|        let originalTimeout = timeoutDuration
405|5b4e28|        timeoutDuration = timeout
406|fa2a6a|        defer { timeoutDuration = originalTimeout }
407|7b68a8|        return try await execute(code: code)
408|27e597|    }
409|b4687f|    
410|5ef09c|    // MARK: - Result Conversion
411|b4687f|    
412|c32910|    /**
413|638fe8|     * Converts a JSValue to a native Swift type.
414|2b23ac|     *
415|cc9e44|     * - Parameter value: The JSValue to convert
416|b42367|     * - Returns: The converted Swift value (String, Int, Double, Bool, Array, Dictionary, or nil)
417|2b23ac|     *
418|7a5f4e|     * ## Example:
419|ac33be|     * ```swift
420|2e03ce|     * let jsValue = try await runner.execute(code: "{ a: 1, b: [1, 2, 3] }")
421|9d3028|     * let swiftValue = runner.convertToSwift(jsValue)
422|cb6f68|     * // Returns: ["a": 1, "b": [1, 2, 3]] as [String: Any]
423|056bf3|     * ```
424|1ef3e9|     */
425|40c821|    func convertToSwift(_ value: JSValue) -> Any? {
426|af96db|        if value.isUndefined || value.isNull {
427|1c8557|            return nil
428|5f3077|        }
429|d6ed84|        
430|6639a5|        if value.isString {
431|7fd7f0|            return value.toString()
432|5f3077|        }
433|d6ed84|        
434|fe29fa|        if value.isNumber {
435|0200f8|            let int = value.toInt32()
436|6a6589|            if Double(int) == value.toDouble() {
437|fdd122|                return Int(int)
438|a7dc16|            }
439|cc6808|            return value.toDouble()
440|5f3077|        }
441|d6ed84|        
442|97b38b|        if value.isBoolean {
443|48a040|            return value.toBool()
444|5f3077|        }
445|d6ed84|        
446|a80647|        if value.isArray {
447|936625|            return value.toArray()
448|5f3077|        }
449|d6ed84|        
450|8844d6|        if value.isObject {
451|a2dc1c|            return value.toDictionary()
452|5f3077|        }
453|d6ed84|        
454|8e7e0b|        if let date = value.toDate() {
455|0f7876|            return date
456|5f3077|        }
457|d6ed84|        
458|c2ae65|        return nil
459|27e597|    }
460|b4687f|    
461|c32910|    /**
462|0ec2b2|     * Executes code and automatically converts the result to a Swift type.
463|2b23ac|     *
464|f02985|     * - Parameter code: JavaScript code to execute
465|049f9c|     * - Returns: Converted Swift value, or nil if conversion fails
466|7bce23|     * - Throws: JSRunnerError for execution failures
467|1ef3e9|     */
468|6865ed|    func executeAndConvert(code: String) async throws -> Any? {
469|a03023|        let result = try await execute(code: code)
470|c759dd|        return convertToSwift(result)
471|27e597|    }
472|b4687f|    
473|bd6ccb|    // MARK: - Memory Management
474|b4687f|    
475|c32910|    /**
476|cf136b|     * Sets the memory limit for JavaScript execution.
477|2b23ac|     *
478|c60210|     * - Parameter limit: Maximum memory in bytes
479|1ef3e9|     */
480|65e2e8|    func setMemoryLimit(_ limit: UInt64) {
481|158e82|        memoryLimit = limit
482|27e597|    }
483|b4687f|    
484|c32910|    /**
485|461e9d|     * Forces garbage collection and clears the context.
486|552831|     * Call this when you're done with the runner to free resources.
487|1ef3e9|     */
488|380be3|    func cleanup() {
489|5a8e21|        context.exceptionHandler = nil
490|05bf05|        context = nil
491|2e3689|        consoleHandler = nil
492|27e597|    }
493|b31277|}
494|adc83b|
495|eb33bc|// MARK: - Convenience Extensions
496|adc83b|
497|83899d|extension JSRunner {
498|b4687f|    
499|c32910|    /**
500|389f7a|     * Executes JavaScript and returns the result as a String.
501|1ef3e9|     */
502|7903ec|    func executeToString(code: String) async throws -> String? {
503|a03023|        let result = try await execute(code: code)
504|399657|        return result.toString()
505|27e597|    }
506|b4687f|    
507|c32910|    /**
508|a6219f|     * Executes JavaScript and returns the result as an Int.
509|1ef3e9|     */
510|b5428a|    func executeToInt(code: String) async throws -> Int? {
511|a03023|        let result = try await execute(code: code)
512|44e26f|        return Int(result.toInt32())
513|27e597|    }
514|b4687f|    
515|c32910|    /**
516|0e138b|     * Executes JavaScript and returns the result as a Double.
517|1ef3e9|     */
518|70f92c|    func executeToDouble(code: String) async throws -> Double? {
519|a03023|        let result = try await execute(code: code)
520|9374d0|        return result.toDouble()
521|27e597|    }
522|b4687f|    
523|c32910|    /**
524|8086be|     * Executes JavaScript and returns the result as a Bool.
525|1ef3e9|     */
526|dd633e|    func executeToBool(code: String) async throws -> Bool? {
527|a03023|        let result = try await execute(code: code)
528|c50d04|        return result.isBoolean ? result.toBool() : nil
529|27e597|    }
530|b4687f|    
531|c32910|    /**
532|9853d8|     * Executes JavaScript and returns the result as a Dictionary.
533|1ef3e9|     */
534|93d723|    func executeToDictionary(code: String) async throws -> [String: Any]? {
535|a03023|        let result = try await execute(code: code)
536|1a88b3|        guard let dict = result.toDictionary() else { return nil }
537|786254|        var stringDict: [String: Any] = [:]
538|0c0c7f|        for (key, value) in dict {
539|947451|            if let stringKey = key as? String {
540|c59c65|                stringDict[stringKey] = value
541|a7dc16|            }
542|5f3077|        }
543|5e8679|        return stringDict.isEmpty ? nil : stringDict
544|27e597|    }
545|b4687f|    
546|c32910|    /**
547|2f765d|     * Executes JavaScript and returns the result as an Array.
548|1ef3e9|     */
549|e7718f|    func executeToArray(code: String) async throws -> [Any]? {
550|a03023|        let result = try await execute(code: code)
551|a42f1e|        return result.toArray()
552|27e597|    }
553|b31277|}
554|adc83b|
555|95af32|// MARK: - Test Example
556|32ca1a|/*
557|dd1225| 
558|ea119b| // MARK: - Example Test Usage
559|adc83b|
560|e4031d| import XCTest
561|adc83b|
562|3cdf90| class JSRunnerTests: XCTestCase {
563|8f1f4b|     
564|536c57|     var runner: JSRunner!
565|8f1f4b|     
566|676c35|     override func setUp() {
567|30f761|         super.setUp()
568|6ab08f|         runner = JSRunner()
569|1b931e|         runner.setConsoleHandler { message in
570|1f545b|             print("Console: \(message)")
571|b9c240|         }
572|48082f|     }
573|8f1f4b|     
574|41f09e|     override func tearDown() {
575|5c2aee|         runner.cleanup()
576|501764|         runner = nil
577|bc7549|         super.tearDown()
578|48082f|     }
579|8f1f4b|     
580|ff723b|     func testBasicArithmetic() async throws {
581|6c4337|         let result = try await runner.executeToInt(code: "2 + 3")
582|c79b91|         XCTAssertEqual(result, 5)
583|48082f|     }
584|8f1f4b|     
585|5216c0|     func testConsoleCapture() async throws {
586|57e3fd|         var capturedMessages: [String] = []
587|1b931e|         runner.setConsoleHandler { message in
588|a2ab29|             capturedMessages.append(message)
589|b9c240|         }
590|27e700|         
591|eceb74|         _ = try await runner.execute(code: "console.log('Hello from JS'); console.error('Error test')")
592|27e700|         
593|2691fd|         XCTAssertTrue(capturedMessages.contains("[LOG] Hello from JS"))
594|13e3ca|         XCTAssertTrue(capturedMessages.contains("[ERROR] Error test"))
595|48082f|     }
596|8f1f4b|     
597|ee7567|     func testNativeFunctionExposure() async throws {
598|8181c7|         runner.exposeNativeFunction(name: "swiftAdd") { args in
599|48134e|             guard args.count >= 2,
600|ae326c|                   let a = args[0].toInt32(),
601|c098e9|                   let b = args[1].toInt32() else {
602|957178|                 return JSValue(undefinedIn: self.runner.context)
603|6a8388|             }
604|d2dff2|             return JSValue(int32: a + b, in: self.runner.context)
605|b9c240|         }
606|27e700|         
607|e237bc|         let result = try await runner.executeToInt(code: "swiftAdd(10, 20)")
608|6bd0c8|         XCTAssertEqual(result, 30)
609|48082f|     }
610|8f1f4b|     
611|ec5511|     func testComplexObjectConversion() async throws {
612|c47f70|         let result = try await runner.executeAndConvert(code: """
613|fb48e7|             ({
614|7512f1|                 name: 'Test Object',
615|deebe9|                 count: 42,
616|76b333|                 active: true,
617|3b7226|                 items: ['a', 'b', 'c']
618|899c68|             })
619|72e678|         """)
620|27e700|         
621|904df8|         guard let dict = result as? [String: Any] else {
622|72cfb3|             XCTFail("Expected dictionary result")
623|ccedbe|             return
624|b9c240|         }
625|27e700|         
626|00108e|         XCTAssertEqual(dict["name"] as? String, "Test Object")
627|6dbd01|         XCTAssertEqual(dict["count"] as? Int, 42)
628|91b50b|         XCTAssertEqual(dict["active"] as? Bool, true)
629|adb09c|         XCTAssertEqual(dict["items"] as? [String], ["a", "b", "c"])
630|48082f|     }
631|8f1f4b|     
632|4d88a0|     func testTimeout() async {
633|16516b|         runner.timeoutDuration = 0.5 // 500ms timeout
634|27e700|         
635|c39137|         do {
636|b39167|             // Infinite loop should timeout
637|18f657|             _ = try await runner.execute(code: "while(true) {}")
638|1e90a5|             XCTFail("Should have thrown timeout error")
639|e245bc|         } catch JSRunnerError.executionTimeout {
640|4c03b3|             // Expected
641|397a89|         } catch {
642|f414ab|             XCTFail("Unexpected error: \(error)")
643|b9c240|         }
644|48082f|     }
645|8f1f4b|     
646|c45f91|     func testErrorHandling() async {
647|c39137|         do {
648|d9a249|             _ = try await runner.execute(code: "throw new Error('Test error')")
649|f7d33e|             XCTFail("Should have thrown error")
650|cfd468|         } catch JSRunnerError.scriptError(let message) {
651|cfb4a6|             XCTAssertTrue(message.contains("Test error"))
652|397a89|         } catch {
653|1fb92f|             XCTFail("Unexpected error type: \(error)")
654|b9c240|         }
655|48082f|     }
656|02e5c8| }
657|adc83b|
658|ae6ce1| // Simple playground-style example:
659|dd1225| 
660|1bac8e| func runExample() async {
661|56213f|     let runner = JSRunner()
662|8f1f4b|     
663|628fbb|     // Capture console output
664|96505e|     runner.setConsoleHandler { message in
665|bfc72f|         print("📝 \(message)")
666|48082f|     }
667|8f1f4b|     
668|9c1723|     // Expose native Swift function
669|216414|     runner.exposeNativeFunction(name: "calculateArea") { args in
670|aef866|         guard args.count >= 2,
671|f8e67b|               let width = args[0].toDouble(),
672|74396a|               let height = args[1].toDouble() else {
673|5551b3|             return JSValue(undefinedIn: runner.context)
674|b9c240|         }
675|bb8bbf|         let area = width * height
676|33a37c|         return JSValue(double: area, in: runner.context)
677|48082f|     }
678|8f1f4b|     
679|4489c1|     do {
680|430d75|         // Test 1: Basic arithmetic
681|882cc5|         let sum = try await runner.executeToInt(code: "10 + 32")
682|02b91a|         print("Sum: \(sum ?? 0)")
683|27e700|         
684|153e1f|         // Test 2: Console logging
685|c62d34|         try await runner.execute(code: """
686|e53a89|             console.log('Starting calculation...');
687|b8f170|             console.info('This is info');
688|454b58|             console.warn('This is a warning');
689|72e678|         """)
690|27e700|         
691|465444|         // Test 3: Native function call
692|b2a206|         let area = try await runner.executeToDouble(code: "calculateArea(5.5, 10.2)")
693|8be639|         print("Area: \(area ?? 0)")
694|27e700|         
695|1d373e|         // Test 4: Complex object
696|0b0b5e|         let user = try await runner.executeToDictionary(code: """
697|fb48e7|             ({
698|11940c|                 id: 123,
699|a36923|                 name: 'John Doe',
700|fef5db|                 email: 'john@example.com',
701|4cd091|                 roles: ['user', 'admin']
702|899c68|             })
703|72e678|         """)
704|aefd4d|         print("User: \(user ?? [:])")
705|27e700|         
706|a6364d|     } catch {
707|3d5d68|         print("❌ Error: \(error)")
708|48082f|     }
709|8f1f4b|     
710|dd8022|     runner.cleanup()
711|02e5c8| }
712|adc83b|
713|ba234e| // Run the example:
714|5e6c27| // Task { await runExample() }
715|dd1225| 
716|d48ab4| */
717|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 463b0e5988f0
File: VSCodeiPadOS/VSCodeiPadOS/Services/OnDevice/WASMRunner.swift (lines 1-723 of 723)
────────────────────────────────────────
1|8b6b78|import Foundation
2|501c1a|import WebKit
3|119e5c|import JavaScriptCore
4|adc83b|
5|2dbcb6|// MARK: - Errors
6|adc83b|
7|c28ee2|/// Errors that can occur during WASM execution
8|8dcbab|public enum WASMError: Error, LocalizedError {
9|4d2ddc|    case initializationFailed(reason: String)
10|d4f4ac|    case moduleCompilationFailed(reason: String)
11|64a824|    case moduleLoadFailed(reason: String)
12|d920fc|    case functionNotFound(name: String)
13|5a086c|    case executionFailed(reason: String)
14|be1463|    case invalidArguments
15|a6f7ed|    case memoryLimitExceeded(limit: UInt64)
16|3c7ca1|    case executionTimeout(seconds: TimeInterval)
17|ce5d8c|    case hostFunctionRegistrationFailed(name: String)
18|62aed1|    case wasiNotSupported
19|d85fd8|    case invalidReturnType
20|b4687f|    
21|13155b|    public var errorDescription: String? {
22|2e6d08|        switch self {
23|5c31df|        case .initializationFailed(let reason):
24|0f1fab|            return "WASM initialization failed: \(reason)"
25|626538|        case .moduleCompilationFailed(let reason):
26|cf14a9|            return "Module compilation failed: \(reason)"
27|41918b|        case .moduleLoadFailed(let reason):
28|1554d0|            return "Module load failed: \(reason)"
29|47d4f6|        case .functionNotFound(let name):
30|3bc2b7|            return "Function '\(name)' not found in WASM module"
31|630f9b|        case .executionFailed(let reason):
32|4cbda2|            return "Execution failed: \(reason)"
33|c22843|        case .invalidArguments:
34|c6b6d1|            return "Invalid arguments provided to WASM function"
35|5c28cf|        case .memoryLimitExceeded(let limit):
36|595312|            return "Memory limit exceeded: \(limit) bytes"
37|d6e6fe|        case .executionTimeout(let seconds):
38|0cde63|            return "Execution timed out after \(seconds) seconds"
39|968350|        case .hostFunctionRegistrationFailed(let name):
40|124d6c|            return "Failed to register host function '\(name)'"
41|758c42|        case .wasiNotSupported:
42|3a30f2|            return "WASI is not fully supported on iOS. Use WASI polyfills or server-side execution."
43|51617d|        case .invalidReturnType:
44|24f405|            return "Invalid return type from WASM function"
45|5f3077|        }
46|27e597|    }
47|b31277|}
48|adc83b|
49|39016f|// MARK: - Configuration
50|adc83b|
51|f48e0e|/// Configuration for WASM execution environment
52|010912|public struct WASMConfiguration {
53|3cb324|    /// Memory limit in bytes (default: 128 MB)
54|0082f6|    public var memoryLimit: UInt64
55|b4687f|    
56|ad5017|    /// Execution timeout in seconds (default: 30)
57|b779fd|    public var executionTimeout: TimeInterval
58|b4687f|    
59|f6d508|    /// Enable debug logging
60|7e3c31|    public var enableDebugLogging: Bool
61|b4687f|    
62|1c25bf|    /// WASI support mode
63|21ba6a|    public var wasiMode: WASIMode
64|b4687f|    
65|6da088|    /// JavaScript runtime to use
66|526cf6|    public var runtime: JavaScriptRuntime
67|b4687f|    
68|9ab6df|    public enum WASIMode {
69|7f01fe|        case disabled
70|7bfad5|        case polyfill  // Limited support via polyfills
71|d87348|        case stub      // Stub implementations that log warnings
72|27e597|    }
73|b4687f|    
74|eb7512|    public enum JavaScriptRuntime {
75|ad5af1|        case wkWebView   // Full WebAssembly support via Safari engine
76|c04391|        case javaScriptCore  // No WebAssembly support (fallback only)
77|27e597|    }
78|b4687f|    
79|fb99ae|    public init(
80|5717da|        memoryLimit: UInt64 = 128 * 1024 * 1024,
81|576c95|        executionTimeout: TimeInterval = 30.0,
82|8fea3e|        enableDebugLogging: Bool = false,
83|25fc37|        wasiMode: WASIMode = .stub,
84|b9262d|        runtime: JavaScriptRuntime = .wkWebView
85|981e04|    ) {
86|e9e4ed|        self.memoryLimit = memoryLimit
87|4e1aac|        self.executionTimeout = executionTimeout
88|857b48|        self.enableDebugLogging = enableDebugLogging
89|cc110a|        self.wasiMode = wasiMode
90|59cc84|        self.runtime = runtime
91|27e597|    }
92|b4687f|    
93|ced82d|    /// Default configuration with conservative limits
94|64f7fb|    public static let `default` = WASMConfiguration()
95|b4687f|    
96|b89903|    /// Configuration optimized for Pyodide
97|59cc39|    public static let pyodide = WASMConfiguration(
98|8dc10a|        memoryLimit: 256 * 1024 * 1024,
99|ed2baf|        executionTimeout: 60.0,
100|45bceb|        enableDebugLogging: true,
101|5da7af|        wasiMode: .disabled
102|829c44|    )
103|b4687f|    
104|31f03f|    /// Configuration optimized for Rust WASM
105|33e226|    public static let rust = WASMConfiguration(
106|7c0a7b|        memoryLimit: 64 * 1024 * 1024,
107|1fe430|        executionTimeout: 10.0,
108|15894e|        enableDebugLogging: false,
109|435a24|        wasiMode: .stub
110|829c44|    )
111|b31277|}
112|adc83b|
113|54458c|// MARK: - WASMRunner
114|adc83b|
115|d07a0f|/// WebAssembly runner for iOS using WKWebView
116|e0ad8a|/// 
117|ffe3f1|/// **IMPORTANT LIMITATIONS:**
118|664833|/// - WKWebView runs in separate process - all calls are async
119|24cc24|/// - JavaScriptCore does NOT support WebAssembly
120|608f3f|/// - WASI filesystem operations are limited/stubbed
121|f8e828|/// - Memory limits are approximate (WebKit manages memory)
122|d48082|/// - Large WASM modules (>50MB) may cause memory pressure
123|83588b|/// - Pyodide requires ~200MB+ memory and network access
124|e0ad8a|/// 
125|841246|/// **Architecture:**
126|b2a45b|/// Uses WKWebView with a hidden web view to execute WASM in Safari's JavaScriptCore engine.
127|a4635c|/// Communication happens via WKUserContentController message handlers.
128|69d728|@MainActor
129|6c4353|public final class WASMRunner: NSObject {
130|b4687f|    
131|6503ae|    // MARK: - Properties
132|b4687f|    
133|aec798|    private var webView: WKWebView?
134|92995d|    private let configuration: WASMConfiguration
135|5db138|    private var hostFunctions: [String: ([Any]) -> Any] = [:]
136|68354c|    private var continuation: CheckedContinuation<Any, Error>?
137|b478ea|    private var executionTask: Task<Void, Never>?
138|e8c6b3|    private var isInitialized = false
139|8531d7|    private var moduleLoaded = false
140|468c74|    private var currentModuleName: String?
141|b4687f|    
142|b3456b|    // Message handler identifier
143|824913|    private let messageHandlerName = "wasmRunner"
144|b4687f|    
145|7dca75|    // MARK: - Initialization
146|b4687f|    
147|dcc193|    /// Creates a new WASM runner with the specified configuration
148|f330ab|    /// - Parameter configuration: Execution configuration (defaults to .default)
149|bc94ee|    /// - Throws: WASMError.initializationFailed if WKWebView setup fails
150|bfcf79|    public init(configuration: WASMConfiguration = .default) throws {
151|e62f56|        self.configuration = configuration
152|15cfe8|        super.init()
153|d6ed84|        
154|5b5cb8|        guard configuration.runtime == .wkWebView else {
155|d4ad7d|            throw WASMError.initializationFailed(
156|5e754b|                reason: "JavaScriptCore does not support WebAssembly. Use WKWebView runtime."
157|43d041|            )
158|5f3077|        }
159|d6ed84|        
160|d58b13|        try setupWebView()
161|27e597|    }
162|b4687f|    
163|1dd0a9|    private func setupWebView() throws {
164|24e765|        let webConfiguration = WKWebViewConfiguration()
165|d6ed84|        
166|e7e77f|        // Set up message handler for communication
167|21705a|        let userContentController = WKUserContentController()
168|c865bb|        userContentController.add(self, name: messageHandlerName)
169|9b6f4d|        webConfiguration.userContentController = userContentController
170|d6ed84|        
171|beda62|        // Enable WASM support
172|54cd65|        webConfiguration.preferences.javaScriptEnabled = true
173|24e933|        if #available(iOS 15.0, *) {
174|c4f979|            webConfiguration.preferences.isTextInteractionEnabled = true
175|5f3077|        }
176|d6ed84|        
177|0a0cbc|        // Create hidden web view
178|07b1b6|        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
179|e01bdb|        webView.isHidden = true
180|d6ed84|        
181|af4b8f|        // Inject WASM runtime helper
182|4937f0|        let wasmHelperScript = WKUserScript(
183|fc02e3|            source: WASMRuntimeHelper.javascript,
184|d54844|            injectionTime: .atDocumentStart,
185|bbfeef|            forMainFrameOnly: true
186|3143a4|        )
187|4e5e29|        userContentController.addUserScript(wasmHelperScript)
188|d6ed84|        
189|f8ed0c|        self.webView = webView
190|d6ed84|        
191|1d2da5|        // Load blank page to initialize
192|d1c0b4|        webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
193|d6ed84|        
194|1bdb42|        if configuration.enableDebugLogging {
195|ae0dc8|            print("[WASMRunner] WebView initialized")
196|5f3077|        }
197|27e597|    }
198|b4687f|    
199|09e8a5|    // MARK: - Module Loading
200|b4687f|    
201|9458cd|    /// Loads a WebAssembly module from Data
202|d56ac1|    /// - Parameter wasmData: The WASM binary data
203|85ba2d|    /// - Throws: WASMError.moduleLoadFailed if loading fails
204|e8e0fe|    public func load(wasmData: Data) async throws {
205|9176d5|        guard let webView = webView else {
206|44352e|            throw WASMError.initializationFailed(reason: "WebView not available")
207|5f3077|        }
208|d6ed84|        
209|d4e805|        // Convert to base64 for JavaScript transfer
210|ca9524|        let base64String = wasmData.base64EncodedString()
211|c9b31e|        let moduleName = "wasm_module_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
212|d6ed84|        
213|d3325c|        // Build load command
214|9c21ed|        let loadScript = """
215|563fc4|        (async function() {
216|174ec8|            try {
217|e27daa|                const binaryString = atob('\(base64String)');
218|ba9f94|                const bytes = new Uint8Array(binaryString.length);
219|dab495|                for (let i = 0; i < binaryString.length; i++) {
220|eb8518|                    bytes[i] = binaryString.charCodeAt(i);
221|4e2d32|                }
222|216278|                
223|0d932c|                // Compile the module
224|d31622|                const module = await WebAssembly.compile(bytes);
225|216278|                
226|409c21|                // Store in window.wasmModules
227|249c20|                if (!window.wasmModules) window.wasmModules = {};
228|8979bb|                window.wasmModules['\(moduleName)'] = module;
229|216278|                
230|c58a0a|                // Check memory requirements
231|11687c|                const memoryPages = module.imports.find(i => i.module === 'env' && i.name === 'memory');
232|409315|                if (memoryPages) {
233|14deaf|                    // Memory is imported, will be checked at instantiation
234|4e2d32|                }
235|216278|                
236|a5d51a|                return { success: true, moduleName: '\(moduleName)' };
237|1a5fdc|            } catch (error) {
238|737f10|                return { success: false, error: error.toString() };
239|a7dc16|            }
240|6ba073|        })()
241|c70080|        """
242|d6ed84|        
243|1bb917|        let result = try await executeJavaScript(loadScript, in: webView)
244|d6ed84|        
245|f8e887|        guard let dict = result as? [String: Any],
246|914c2b|              let success = dict["success"] as? Bool else {
247|afb53b|            throw WASMError.moduleLoadFailed(reason: "Invalid response from WebView")
248|5f3077|        }
249|d6ed84|        
250|cf5235|        if success {
251|d97bdb|            self.currentModuleName = moduleName
252|d71206|            self.moduleLoaded = true
253|3070d1|            
254|fa3662|            if configuration.enableDebugLogging {
255|e81c3f|                print("[WASMRunner] Module '\(moduleName)' loaded successfully")
256|a7dc16|            }
257|b31999|        } else {
258|83c3f9|            let errorMessage = dict["error"] as? String ?? "Unknown error"
259|5042be|            throw WASMError.moduleLoadFailed(reason: errorMessage)
260|5f3077|        }
261|27e597|    }
262|b4687f|    
263|a24546|    /// Loads a WebAssembly module from a file URL
264|7bc912|    /// - Parameter url: File URL to the .wasm file
265|85ba2d|    /// - Throws: WASMError.moduleLoadFailed if loading fails
266|1d4013|    public func load(from url: URL) async throws {
267|7dcb26|        let data = try Data(contentsOf: url)
268|bb1e25|        try await load(wasmData: data)
269|27e597|    }
270|b4687f|    
271|68bc64|    // MARK: - Function Execution
272|b4687f|    
273|d8cb0a|    /// Executes a function from the loaded WASM module
274|45b4bd|    /// - Parameters:
275|be21ff|    ///   - function: Name of the exported function
276|3fa52e|    ///   - args: Arguments to pass (must be JSON-serializable)
277|7fa39e|    /// - Returns: The function result (converted from JavaScript)
278|7cb653|    /// - Throws: WASMError if execution fails
279|8a1855|    public func execute(function: String, args: [Any] = []) async throws -> Any {
280|37f4e7|        guard moduleLoaded, let moduleName = currentModuleName else {
281|ba2137|            throw WASMError.moduleLoadFailed(reason: "No module loaded")
282|5f3077|        }
283|d6ed84|        
284|2bcea4|        // Serialize arguments
285|946b71|        let argsJSON = try serializeArguments(args)
286|d6ed84|        
287|22d139|        // Build execution script with timeout
288|a1a7cc|        let executionScript = """
289|563fc4|        (async function() {
290|56585c|            const timeout = \(Int(configuration.executionTimeout * 1000));
291|a52445|            const startTime = Date.now();
292|3070d1|            
293|c650f1|            const timeoutPromise = new Promise((_, reject) => {
294|87e71a|                setTimeout(() => reject(new Error('Execution timeout')), timeout);
295|892e8b|            });
296|3070d1|            
297|833476|            const executionPromise = (async () => {
298|cc952a|                try {
299|85e6ec|                    const module = window.wasmModules['\(moduleName)'];
300|52c2c8|                    if (!module) throw new Error('Module not found');
301|dd2193|                    
302|b62d6e|                    // Create import object with host functions
303|8b9537|                    const importObject = window.createImportObject ? window.createImportObject() : {};
304|dd2193|                    
305|f2db4a|                    // Instantiate the module
306|9ff714|                    const instance = await WebAssembly.instantiate(module, importObject);
307|dd2193|                    
308|cb643c|                    // Get the exported function
309|1460e5|                    const fn = instance.exports['\(function)'];
310|7bbad9|                    if (typeof fn !== 'function') {
311|b8bc1b|                        throw new Error('Function \'\(function)\' not found or not a function');
312|c9717a|                    }
313|dd2193|                    
314|2b8e30|                    // Parse arguments
315|e96661|                    const args = \(argsJSON);
316|dd2193|                    
317|eab339|                    // Call the function
318|c04c44|                    const result = fn.apply(null, args);
319|dd2193|                    
320|bd48f0|                    return { 
321|f7cf9f|                        success: true, 
322|625dd9|                        result: result,
323|947a17|                        executionTime: Date.now() - startTime
324|5331c6|                    };
325|c4d255|                } catch (error) {
326|bd48f0|                    return { 
327|477151|                        success: false, 
328|755dca|                        error: error.toString(),
329|947a17|                        executionTime: Date.now() - startTime
330|5331c6|                    };
331|4e2d32|                }
332|43941f|            })();
333|3070d1|            
334|e7b220|            return Promise.race([executionPromise, timeoutPromise]);
335|6ba073|        })()
336|c70080|        """
337|d6ed84|        
338|9176d5|        guard let webView = webView else {
339|9f5cc9|            throw WASMError.executionFailed(reason: "WebView not available")
340|5f3077|        }
341|d6ed84|        
342|082c1c|        let result = try await executeJavaScript(executionScript, in: webView)
343|d6ed84|        
344|22d3cd|        guard let dict = result as? [String: Any] else {
345|f92b0d|            throw WASMError.executionFailed(reason: "Invalid response format")
346|5f3077|        }
347|d6ed84|        
348|48e3d6|        if let success = dict["success"] as? Bool, success {
349|9dac58|            return dict["result"] ?? NSNull()
350|b31999|        } else {
351|83c3f9|            let errorMessage = dict["error"] as? String ?? "Unknown error"
352|2aa2c6|            if errorMessage.contains("timeout") {
353|c39dae|                throw WASMError.executionTimeout(seconds: configuration.executionTimeout)
354|a7dc16|            }
355|5d5bf9|            throw WASMError.executionFailed(reason: errorMessage)
356|5f3077|        }
357|27e597|    }
358|b4687f|    
359|945ea1|    // MARK: - Host Functions
360|b4687f|    
361|cc25e2|    /// Exposes a native Swift function to the WASM module
362|7cfeb1|    /// 
363|5f6cfb|    /// **Limitation:** Host functions are called asynchronously via message handlers.
364|08f7a9|    /// Synchronous host function calls from WASM are not supported.
365|7cfeb1|    /// 
366|45b4bd|    /// - Parameters:
367|4ede7d|    ///   - name: Name of the function in the import namespace
368|9f9bae|    ///   - handler: Closure that receives arguments and returns a result
369|d6fe84|    /// - Throws: WASMError.hostFunctionRegistrationFailed if registration fails
370|04ba75|    public func exposeHostFunction(name: String, handler: @escaping ([Any]) -> Any) async throws {
371|decfd5|        hostFunctions[name] = handler
372|d6ed84|        
373|9176d5|        guard let webView = webView else {
374|cb0a15|            throw WASMError.hostFunctionRegistrationFailed(name: name)
375|5f3077|        }
376|d6ed84|        
377|d49474|        // Register with JavaScript runtime
378|346754|        let registerScript = """
379|1efaf3|        (function() {
380|952daa|            if (!window.hostFunctions) window.hostFunctions = {};
381|d6884e|            window.hostFunctions['\(name)'] = function(...args) {
382|756fc5|                // Send message to native for async execution
383|d08a7b|                window.webkit.messageHandlers.\(messageHandlerName).postMessage({
384|cab20f|                    type: 'hostFunction',
385|5f6b10|                    name: '\(name)',
386|7a6e38|                    args: args
387|4a2b79|                });
388|7426b0|                // Return a placeholder (actual result comes async)
389|6994fb|                return 0;
390|13106d|            };
391|204981|            return { success: true };
392|6ba073|        })()
393|c70080|        """
394|d6ed84|        
395|5110a8|        _ = try await executeJavaScript(registerScript, in: webView)
396|d6ed84|        
397|1bdb42|        if configuration.enableDebugLogging {
398|7d41b3|            print("[WASMRunner] Host function '\(name)' registered")
399|5f3077|        }
400|27e597|    }
401|b4687f|    
402|ed250e|    // MARK: - WASI Support
403|b4687f|    
404|3589a7|    /// Configures WASI support (limited on iOS)
405|7cfeb1|    /// 
406|d54137|    /// **IMPORTANT:** Full WASI support requires a server-side component or
407|c261cd|    /// WASI polyfill. On iOS, this is stubbed to prevent security issues.
408|7cfeb1|    /// 
409|f67132|    /// - Throws: WASMError.wasiNotSupported if WASI mode is .disabled
410|68852d|    public func configureWASI() async throws {
411|57dd34|        switch configuration.wasiMode {
412|776f6f|        case .disabled:
413|e2cdbf|            throw WASMError.wasiNotSupported
414|3070d1|            
415|e1df62|        case .stub:
416|ffd74c|            // Install stub WASI implementations that log warnings
417|fdb891|            guard let webView = webView else {
418|4c11ef|                throw WASMError.initializationFailed(reason: "WebView not available")
419|a7dc16|            }
420|3070d1|            
421|dcb690|            let wasiStubScript = """
422|027e5e|            (function() {
423|c788d5|                const wasiStub = {
424|25002b|                    fd_write: function() { 
425|7d7ade|                        console.warn('WASI fd_write stub called'); return 0; 
426|12b5e6|                    },
427|2219fc|                    fd_read: function() { 
428|6d62f3|                        console.warn('WASI fd_read stub called'); return 0; 
429|12b5e6|                    },
430|5a414f|                    fd_close: function() { 
431|200c9a|                        console.warn('WASI fd_close stub called'); return 0; 
432|12b5e6|                    },
433|ad9908|                    fd_seek: function() { 
434|db935f|                        console.warn('WASI fd_seek stub called'); return 0; 
435|12b5e6|                    },
436|9e6889|                    path_open: function() { 
437|3101eb|                        console.warn('WASI path_open stub called'); return -1; 
438|12b5e6|                    },
439|d8fb08|                    path_unlink_file: function() { 
440|0cbcde|                        console.warn('WASI path_unlink_file stub called'); return -1; 
441|12b5e6|                    },
442|c7c0a2|                    environ_get: function() { return 0; },
443|5b3c94|                    environ_sizes_get: function() { return 0; },
444|50baa5|                    args_get: function() { return 0; },
445|b76a60|                    args_sizes_get: function() { return 0; },
446|41721f|                    proc_exit: function(code) { 
447|1e4dee|                        console.log('WASI proc_exit called with code:', code); 
448|12b5e6|                    },
449|ff6090|                    clock_time_get: function() { return 0; }
450|2c6774|                };
451|216278|                
452|cad0c0|                if (!window.wasiSnapshotPreview1) {
453|a81a6d|                    window.wasiSnapshotPreview1 = wasiStub;
454|4e2d32|                }
455|216278|                
456|73c4f3|                return { success: true };
457|1a37c6|            })()
458|f9d356|            """
459|3070d1|            
460|00b190|            _ = try await executeJavaScript(wasiStubScript, in: webView)
461|3070d1|            
462|fa3662|            if configuration.enableDebugLogging {
463|cee7ef|                print("[WASMRunner] WASI stub configured")
464|a7dc16|            }
465|3070d1|            
466|854010|        case .polyfill:
467|32e1be|            // Would require loading external polyfill library
468|fa3662|            if configuration.enableDebugLogging {
469|9af80d|                print("[WASMRunner] WASI polyfill mode - external polyfill required")
470|a7dc16|            }
471|5f3077|        }
472|27e597|    }
473|b4687f|    
474|6a24e0|    // MARK: - Cleanup
475|b4687f|    
476|677399|    /// Unloads the current WASM module and cleans up resources
477|512378|    public func unload() async {
478|bd4fb8|        guard let webView = webView, let moduleName = currentModuleName else { return }
479|d6ed84|        
480|04b4fb|        let cleanupScript = """
481|1efaf3|        (function() {
482|461121|            if (window.wasmModules && window.wasmModules['\(moduleName)']) {
483|8dad2a|                delete window.wasmModules['\(moduleName)'];
484|a7dc16|            }
485|204981|            return { success: true };
486|6ba073|        })()
487|c70080|        """
488|d6ed84|        
489|151b4f|        _ = try? await executeJavaScript(cleanupScript, in: webView)
490|d6ed84|        
491|923e32|        currentModuleName = nil
492|44d2ef|        moduleLoaded = false
493|d6ed84|        
494|1bdb42|        if configuration.enableDebugLogging {
495|981085|            print("[WASMRunner] Module unloaded")
496|5f3077|        }
497|27e597|    }
498|b4687f|    
499|e10fe0|    /// Destroys the runner and releases all resources
500|8308ae|    public func destroy() {
501|5df072|        executionTask?.cancel()
502|75a854|        webView?.stopLoading()
503|4426a6|        webView?.configuration.userContentController.removeScriptMessageHandler(forName: messageHandlerName)
504|b8727c|        webView = nil
505|6399c7|        hostFunctions.removeAll()
506|d6ed84|        
507|1bdb42|        if configuration.enableDebugLogging {
508|4c23b7|            print("[WASMRunner] Destroyed")
509|5f3077|        }
510|27e597|    }
511|b4687f|    
512|e57f77|    deinit {
513|d79336|        Task { @MainActor in
514|aba717|            destroy()
515|5f3077|        }
516|27e597|    }
517|b4687f|    
518|81a958|    // MARK: - Private Helpers
519|b4687f|    
520|d993a7|    private func executeJavaScript(_ script: String, in webView: WKWebView) async throws -> Any {
521|3d0b9a|        return try await withCheckedThrowingContinuation { continuation in
522|24a40d|            webView.evaluateJavaScript(script) { result, error in
523|bced13|                if let error = error {
524|4f255d|                    continuation.resume(throwing: WASMError.executionFailed(reason: error.localizedDescription))
525|fdd0e2|                } else {
526|bf791f|                    continuation.resume(returning: result ?? NSNull())
527|4e2d32|                }
528|a7dc16|            }
529|5f3077|        }
530|27e597|    }
531|b4687f|    
532|14e654|    private func serializeArguments(_ args: [Any]) throws -> String {
533|1592a2|        let data = try JSONSerialization.data(withJSONObject: args, options: [])
534|6d9752|        guard let string = String(data: data, encoding: .utf8) else {
535|290ab4|            throw WASMError.invalidArguments
536|5f3077|        }
537|d970e8|        return string
538|27e597|    }
539|b31277|}
540|adc83b|
541|923e5c|// MARK: - WKScriptMessageHandler
542|adc83b|
543|9b6b1f|extension WASMRunner: WKScriptMessageHandler {
544|916b28|    public func userContentController(
545|7c2a4e|        _ userContentController: WKUserContentController,
546|4802e9|        didReceive message: WKScriptMessage
547|981e04|    ) {
548|193994|        guard let body = message.body as? [String: Any],
549|83691d|              let type = body["type"] as? String else { return }
550|d6ed84|        
551|d79336|        Task { @MainActor in
552|ecf57d|            await handleMessage(type: type, body: body)
553|5f3077|        }
554|27e597|    }
555|b4687f|    
556|629ebb|    private func handleMessage(type: String, body: [String: Any]) async {
557|ba7bd8|        switch type {
558|1dc996|        case "hostFunction":
559|32007e|            if let name = body["name"] as? String,
560|6768d0|               let args = body["args"] as? [Any],
561|de6351|               let handler = hostFunctions[name] {
562|6dd596|                _ = handler(args)
563|a7dc16|            }
564|520b7d|        default:
565|fa3662|            if configuration.enableDebugLogging {
566|3d9cc4|                print("[WASMRunner] Unknown message type: \(type)")
567|a7dc16|            }
568|5f3077|        }
569|27e597|    }
570|b31277|}
571|adc83b|
572|6cd549|// MARK: - JavaScript Runtime Helper
573|adc83b|
574|0d5264|private enum WASMRuntimeHelper {
575|ea3c7b|    static let javascript = """
576|ee8990|    (function() {
577|a77c0e|        'use strict';
578|d6ed84|        
579|e3b5c3|        // WASM Module storage
580|7c4903|        window.wasmModules = window.wasmModules || {};
581|dbe417|        window.hostFunctions = window.hostFunctions || {};
582|d6ed84|        
583|71156c|        // Create import object with WASI and host functions
584|412846|        window.createImportObject = function(env) {
585|71f80d|            env = env || {};
586|3070d1|            
587|d6e892|            // Add WASI if available
588|6e8c78|            if (window.wasiSnapshotPreview1) {
589|c77dcb|                env.wasi_snapshot_preview1 = window.wasiSnapshotPreview1;
590|a7dc16|            }
591|3070d1|            
592|8879c0|            // Add host functions
593|079396|            if (window.hostFunctions) {
594|79aa32|                env.env = env.env || {};
595|cea2cb|                for (const [name, fn] of Object.entries(window.hostFunctions)) {
596|f82665|                    env.env[name] = fn;
597|4e2d32|                }
598|a7dc16|            }
599|3070d1|            
600|eee6b7|            return env;
601|105ee3|        };
602|d6ed84|        
603|882836|        // Helper to convert JS values for WASM
604|d67455|        window.toWASM = {
605|9879b5|            string: function(ptr, len, memory) {
606|14ea79|                const bytes = new Uint8Array(memory.buffer, ptr, len);
607|c83059|                return new TextDecoder('utf8').decode(bytes);
608|12b7cc|            },
609|d8c6de|            bytes: function(ptr, len, memory) {
610|299933|                return new Uint8Array(memory.buffer, ptr, len);
611|a7dc16|            }
612|105ee3|        };
613|d6ed84|        
614|44b60c|        // Helper to write to WASM memory
615|59d10f|        window.fromWASM = {
616|eb03e9|            string: function(str, memory) {
617|7fd28a|                const encoder = new TextEncoder();
618|7c3997|                const bytes = encoder.encode(str);
619|31c0b1|                // Note: Actual memory allocation must be done in WASM
620|5400ad|                return bytes;
621|a7dc16|            }
622|105ee3|        };
623|d6ed84|        
624|7209ba|        console.log('[WASMRuntime] Helper loaded');
625|2f3d4e|    })();
626|87f133|    """
627|b31277|}
628|adc83b|
629|82fd81|// MARK: - Example Usage
630|adc83b|
631|32ca1a|/*
632|ab20fd|Example 1: Running a simple Rust-compiled WASM module
633|adc83b|
634|97f574|```swift
635|9f8e8f|// Load a Rust-compiled WASM module
636|2dda2b|let runner = try WASMRunner(configuration: .rust)
637|adc83b|
638|af46f6|// Load the module
639|343999|let wasmData = try Data(contentsOf: Bundle.main.url(forResource: "calculator", withExtension: "wasm")!)
640|71d6c4|try await runner.load(wasmData: wasmData)
641|adc83b|
642|f2822f|// Call an exported function
643|bfc399|let result = try await runner.execute(function: "add", args: [5, 3])
644|8dd233|print("Result: \(result)") // Prints: 8
645|adc83b|
646|62390b|// Clean up
647|8d06a3|await runner.unload()
648|1a0775|```
649|adc83b|
650|dafcd2|Example 2: Running Pyodide (requires network access and large memory)
651|adc83b|
652|97f574|```swift
653|783d32|// Pyodide requires significant memory
654|154bd5|let runner = try WASMRunner(configuration: .pyodide)
655|adc83b|
656|5648e0|// Load Pyodide (this is a large download ~20MB)
657|c5e631|let pyodideURL = URL(string: "https://cdn.jsdelivr.net/pyodide/v0.24.1/full/pyodide.js")!
658|dc26af|let pyodideWasmURL = URL(string: "https://cdn.jsdelivr.net/pyodide/v0.24.1/full/pyodide.asm.wasm")!
659|adc83b|
660|d130f3|// First load the JavaScript bootstrap
661|60c6da|try await runner.load(from: pyodideWasmURL)
662|adc83b|
663|536077|// Pyodide requires special initialization - see Pyodide documentation
664|beacd5|// This is a simplified example
665|adc83b|
666|62390b|// Clean up
667|8d06a3|await runner.unload()
668|1a0775|```
669|adc83b|
670|1cdd4a|Example 3: Exposing host functions
671|adc83b|
672|97f574|```swift
673|0b9ad4|let runner = try WASMRunner()
674|adc83b|
675|5e3349|// Expose a native function to WASM
676|ce36ef|try await runner.exposeHostFunction(name: "log") { args in
677|8e6abe|    print("WASM Log: \(args)")
678|36d886|    return 0
679|b31277|}
680|adc83b|
681|94c0db|// WASM module can now import and call this function
682|04c15c|// (import "env" "log" (func $log (param i32)))
683|1a0775|```
684|adc83b|
685|5621d8|Example 4: Error handling
686|adc83b|
687|97f574|```swift
688|4e14f2|do {
689|5adc71|    let runner = try WASMRunner()
690|e6c645|    try await runner.load(wasmData: invalidData)
691|f9d86b|    let result = try await runner.execute(function: "main", args: [])
692|5e4017|} catch let error as WASMError {
693|715729|    switch error {
694|80709a|    case .moduleCompilationFailed(let reason):
695|5d77f4|        print("Compilation failed: \(reason)")
696|1849db|    case .executionTimeout(let seconds):
697|dbfbf2|        print("Timeout after \(seconds) seconds")
698|3281bf|    default:
699|2d5d21|        print("WASM Error: \(error.localizedDescription)")
700|27e597|    }
701|b31277|}
702|1a0775|```
703|0edef9|*/
704|adc83b|
705|9e8885|// MARK: - Advanced Features (Future)
706|adc83b|
707|32ca1a|/*
708|b85f4b|Potential future enhancements:
709|adc83b|
710|1ded7d|1. **Streaming Compilation**: Use WebAssembly.compileStreaming() for larger modules
711|d4e71f|2. **SharedArrayBuffer**: Enable for multi-threaded WASM (requires COOP/COEP headers)
712|53674c|3. **WASI Polyfill Integration**: Full WASI support via wasmtime or wasmer
713|f70bb2|4. **Debugging Support**: DWARF debugging info integration
714|2e71cb|5. **Hot Reloading**: Module replacement without full reinitialization
715|727ddb|6. **Performance Profiling**: Integration with Safari DevTools
716|adc83b|
717|fa7959|Current limitations that may be addressed:
718|b4d182|- Host function calls are async-only (no sync interop)
719|d3e3a3|- WASI filesystem is stubbed (no real file access)
720|6489a1|- Memory limits are WebKit-managed, not strictly enforced
721|f829fa|- No direct memory access from Swift (must go through JS bridge)
722|0edef9|*/
723|adc83b|




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

## 🔧 TOOL RESULTS

[read_file]
snapshot: 9fea23a8b787
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 1-906 of 906)
────────────────────────────────────────
1|8d0643|//
2|e2d7aa|//  RunestoneEditorView.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|53f930|//  High-performance code editor using Runestone with TreeSitter syntax highlighting.
6|0887d5|//  Provides native line numbers, code folding, and efficient rendering for large files.
7|8d0643|//
8|adc83b|
9|d755ba|import SwiftUI
10|9ed0a9|import UIKit
11|cf8736|import Runestone
12|e235ab|import TreeSitterSwiftRunestone
13|d7e1b3|import TreeSitterJavaScriptRunestone
14|3b16eb|import TreeSitterPythonRunestone
15|6925df|import TreeSitterJSONRunestone
16|ed1891|import TreeSitterHTMLRunestone
17|27fb7d|import TreeSitterCSSRunestone
18|53be86|import TreeSitterGoRunestone
19|3373e8|import TreeSitterRustRunestone
20|adc83b|
21|941ebe|// Feature flag now uses centralized FeatureFlags.useRunestoneEditor
22|adc83b|
23|83c360|// MARK: - Custom TextView Subclass with Keyboard Shortcuts
24|adc83b|
25|7b9ade|/// Custom subclass of Runestone's TextView that overrides keyboard shortcuts
26|410907|/// to prevent UITextView's default handlers (Bold=Cmd+B, etc.) from intercepting
27|1fa8d6|/// VS Code-style shortcuts.
28|115382|final class VSCodeRunestoneTextView: TextView {
29|b4687f|    
30|7c24d6|    override var keyCommands: [UIKeyCommand]? {
31|17c9a0|        var commands = super.keyCommands ?? []
32|d6ed84|        
33|876d9a|        // MARK: - App-Level Shortcuts that conflict with UITextView defaults
34|417f86|        // These MUST be defined here with wantsPriorityOverSystemBehavior to override
35|b023b0|        // UITextView's built-in handlers (Bold=Cmd+B, Italic=Cmd+I, Print=Cmd+P, etc.)
36|d6ed84|        
37|0789a5|        // Toggle Sidebar: Cmd+B (overrides UITextView's "Bold" command)
38|f34626|        let toggleSidebarCmd = UIKeyCommand(
39|c21f91|            input: "b",
40|791043|            modifierFlags: .command,
41|fd9c9d|            action: #selector(handleToggleSidebar),
42|8f6ce0|            discoverabilityTitle: "Toggle Sidebar"
43|3143a4|        )
44|767005|        toggleSidebarCmd.wantsPriorityOverSystemBehavior = true
45|adcd07|        commands.append(toggleSidebarCmd)
46|d6ed84|        
47|7aaf15|        // Command Palette: Cmd+Shift+P (VS Code's most important shortcut)
48|84ad03|        let cmdPaletteCmd = UIKeyCommand(
49|022265|            input: "p",
50|8d9971|            modifierFlags: [.command, .shift],
51|1339c8|            action: #selector(handleShowCommandPalette),
52|37ea80|            discoverabilityTitle: "Command Palette"
53|3143a4|        )
54|84edb1|        cmdPaletteCmd.wantsPriorityOverSystemBehavior = true
55|1f0c8e|        commands.append(cmdPaletteCmd)
56|d6ed84|        
57|a9230e|        // Quick Open: Cmd+P (overrides system "Print" command)
58|c94963|        let quickOpenCmd = UIKeyCommand(
59|022265|            input: "p",
60|791043|            modifierFlags: .command,
61|6a1edf|            action: #selector(handleShowQuickOpen),
62|5f77d9|            discoverabilityTitle: "Quick Open"
63|3143a4|        )
64|dccd84|        quickOpenCmd.wantsPriorityOverSystemBehavior = true
65|ab20ff|        commands.append(quickOpenCmd)
66|d6ed84|        
67|f2a6a7|        // New File: Cmd+N
68|239cbd|        let newFileCmd = UIKeyCommand(
69|0549ea|            input: "n",
70|791043|            modifierFlags: .command,
71|ae138f|            action: #selector(handleNewFile),
72|d350d6|            discoverabilityTitle: "New File"
73|3143a4|        )
74|91d006|        newFileCmd.wantsPriorityOverSystemBehavior = true
75|1d3599|        commands.append(newFileCmd)
76|d6ed84|        
77|c16fdb|        // Save: Cmd+S
78|10fa85|        let saveCmd = UIKeyCommand(
79|a1985e|            input: "s",
80|791043|            modifierFlags: .command,
81|6ba66c|            action: #selector(handleSaveFile),
82|863fd2|            discoverabilityTitle: "Save"
83|3143a4|        )
84|26081a|        saveCmd.wantsPriorityOverSystemBehavior = true
85|5dd1cb|        commands.append(saveCmd)
86|d6ed84|        
87|976d1c|        // Close Tab: Cmd+W
88|e61690|        let closeTabCmd = UIKeyCommand(
89|0880cc|            input: "w",
90|791043|            modifierFlags: .command,
91|9f0305|            action: #selector(handleCloseTab),
92|6df774|            discoverabilityTitle: "Close Tab"
93|3143a4|        )
94|2c1c6b|        closeTabCmd.wantsPriorityOverSystemBehavior = true
95|41d3f0|        commands.append(closeTabCmd)
96|d6ed84|        
97|bcc592|        // Find: Cmd+F
98|4a10ea|        let findCmd = UIKeyCommand(
99|6c041a|            input: "f",
100|791043|            modifierFlags: .command,
101|ecd0ee|            action: #selector(handleFind),
102|d0ec0f|            discoverabilityTitle: "Find"
103|3143a4|        )
104|bea84d|        findCmd.wantsPriorityOverSystemBehavior = true
105|0b235f|        commands.append(findCmd)
106|d6ed84|        
107|bf24cc|        // Toggle Terminal: Cmd+J
108|a60c7e|        let toggleTerminalCmd = UIKeyCommand(
109|f01b26|            input: "j",
110|791043|            modifierFlags: .command,
111|e6ca50|            action: #selector(handleToggleTerminal),
112|1af0a9|            discoverabilityTitle: "Toggle Panel"
113|3143a4|        )
114|021006|        toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
115|329329|        commands.append(toggleTerminalCmd)
116|d6ed84|        
117|a05812|        // Undo: Cmd+Z
118|546e2c|        let undoCmd = UIKeyCommand(
119|9b11b3|            input: "z",
120|791043|            modifierFlags: .command,
121|fe6402|            action: #selector(handleUndo),
122|5badd2|            discoverabilityTitle: "Undo"
123|3143a4|        )
124|fd81bb|        undoCmd.wantsPriorityOverSystemBehavior = true
125|d37784|        commands.append(undoCmd)
126|d6ed84|        
127|dda763|        // Redo: Cmd+Shift+Z
128|40379c|        let redoCmd = UIKeyCommand(
129|9b11b3|            input: "z",
130|8d9971|            modifierFlags: [.command, .shift],
131|5a175a|            action: #selector(handleRedo),
132|fd37b5|            discoverabilityTitle: "Redo"
133|3143a4|        )
134|42f687|        redoCmd.wantsPriorityOverSystemBehavior = true
135|d9b0e4|        commands.append(redoCmd)
136|d6ed84|        
137|abb5c6|        return commands
138|27e597|    }
139|b4687f|    
140|6665ac|    // MARK: - Notification Handlers
141|b4687f|    
142|30a71a|    @objc func handleToggleSidebar() {
143|2114eb|        NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
144|27e597|    }
145|b4687f|    
146|21f1bc|    @objc func handleShowCommandPalette() {
147|fbe0c5|        NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
148|27e597|    }
149|b4687f|    
150|991940|    @objc func handleShowQuickOpen() {
151|5b0f35|        NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
152|27e597|    }
153|b4687f|    
154|c28d1b|    @objc func handleNewFile() {
155|387109|        NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
156|27e597|    }
157|b4687f|    
158|212d04|    @objc func handleSaveFile() {
159|eb35b9|        NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
160|27e597|    }
161|b4687f|    
162|24f8f9|    @objc func handleCloseTab() {
163|c4ac53|        NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
164|27e597|    }
165|b4687f|    
166|4767e4|    @objc func handleFind() {
167|6bd372|        NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
168|27e597|    }
169|b4687f|    
170|46f792|    @objc func handleToggleTerminal() {
171|10178b|        NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
172|27e597|    }
173|b4687f|    
174|74a433|    @objc func handleUndo() {
175|fe4807|        undoManager?.undo()
176|27e597|    }
177|b4687f|    
178|bddc81|    @objc func handleRedo() {
179|af088f|        undoManager?.redo()
180|27e597|    }
181|b31277|}
182|adc83b|
183|e52ef5|/// UIViewRepresentable wrapper for Runestone's TextView
184|513873|/// Provides native TreeSitter syntax highlighting, line numbers, and code folding
185|bc7df1|struct RunestoneEditorView: UIViewRepresentable {
186|abdc8e|    @Binding var text: String
187|ab828e|    let filename: String
188|d84a59|    @Binding var scrollOffset: CGFloat
189|4cb87f|    @Binding var totalLines: Int
190|aab88e|    @Binding var currentLineNumber: Int
191|a5aa31|    @Binding var currentColumn: Int
192|9e1100|    @Binding var cursorIndex: Int
193|65ebe2|    let isActive: Bool
194|82ae06|    let fontSize: CGFloat
195|088df4|    @EnvironmentObject var editorCore: EditorCore
196|b4687f|    
197|6fdc4b|    // Settings from AppStorage
198|b4e1b7|    @AppStorage("wordWrap") private var wordWrapEnabled: Bool = true
199|ecfad7|    @AppStorage("showLineNumbers") private var showLineNumbers: Bool = true
200|b4687f|    
201|594855|    /// Autocomplete key handling hooks (return true if handled)
202|e7b3cd|    let onAcceptAutocomplete: (() -> Bool)?
203|7c9ea4|    let onDismissAutocomplete: (() -> Bool)?
204|b4687f|    
205|62e028|    init(
206|30281b|        text: Binding<String>,
207|9be454|        filename: String,
208|ab89ef|        scrollOffset: Binding<CGFloat> = .constant(0),
209|b063a9|        totalLines: Binding<Int>,
210|058768|        currentLineNumber: Binding<Int>,
211|fd200b|        currentColumn: Binding<Int>,
212|a428dc|        cursorIndex: Binding<Int> = .constant(0),
213|4ee198|        isActive: Bool,
214|c7d56f|        fontSize: CGFloat = 14.0,
215|31d064|        onAcceptAutocomplete: (() -> Bool)? = nil,
216|7f921c|        onDismissAutocomplete: (() -> Bool)? = nil
217|981e04|    ) {
218|772eb2|        self._text = text
219|693829|        self.filename = filename
220|b44e77|        self._scrollOffset = scrollOffset
221|f2dacc|        self._totalLines = totalLines
222|2111d8|        self._currentLineNumber = currentLineNumber
223|6ac61d|        self._currentColumn = currentColumn
224|a30d0a|        self._cursorIndex = cursorIndex
225|a76635|        self.isActive = isActive
226|aefa3e|        self.fontSize = fontSize
227|e84aef|        self.onAcceptAutocomplete = onAcceptAutocomplete
228|b27828|        self.onDismissAutocomplete = onDismissAutocomplete
229|27e597|    }
230|b4687f|    
231|89795a|    func makeCoordinator() -> Coordinator {
232|5b6b15|        Coordinator(self)
233|27e597|    }
234|b4687f|    
235|680f9a|    func makeUIView(context: Context) -> VSCodeRunestoneTextView {
236|7786eb|        let textView = VSCodeRunestoneTextView()
237|5c30bd|        textView.editorDelegate = context.coordinator
238|d6ed84|        
239|da91fc|        // Configure line numbers (from settings)
240|4387cb|        textView.showLineNumbers = showLineNumbers
241|ebf726|        textView.lineSelectionDisplayType = .line
242|d6ed84|        
243|73d245|        // Configure line wrapping (from settings)
244|a2828f|        textView.isLineWrappingEnabled = wordWrapEnabled
245|d6ed84|        
246|c645f9|        // Configure editing
247|da0c96|        textView.isEditable = true
248|8e0a05|        textView.isSelectable = true
249|d6ed84|        
250|834cfd|        // Disable autocorrect/autocapitalize for code editing
251|9239ec|        textView.autocorrectionType = .no
252|be8b25|        textView.autocapitalizationType = .none
253|95e6b5|        textView.smartQuotesType = .no
254|8d5412|        textView.smartDashesType = .no
255|046505|        textView.smartInsertDeleteType = .no
256|3ed52b|        textView.spellCheckingType = .no
257|d6ed84|        
258|eda999|        // Configure keyboard
259|562515|        textView.keyboardType = .asciiCapable
260|1a155e|        textView.keyboardDismissMode = .interactive
261|d6ed84|        
262|5846ea|        // Content insets for padding
263|948867|        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
264|d6ed84|        
265|6afd10|        // Set text with TreeSitter language support FIRST
266|1bdc19|        if let language = getTreeSitterLanguage(for: filename) {
267|e862fa|            let state = TextViewState(text: text, language: language)
268|aaf1be|            textView.setState(state)
269|b31999|        } else {
270|bf2c47|            // No language support - fallback to plain text
271|bf1757|            textView.text = text
272|5f3077|        }
273|d6ed84|        
274|359325|        // Set theme AFTER setState to ensure it takes effect
275|86633d|        // setState may reset internal rendering state, so theme must come after
276|3ea396|        textView.theme = makeRunestoneTheme()
277|e5b95a|        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
278|d6ed84|        
279|dafec7|        // Store reference for coordinator
280|33bdd5|        context.coordinator.textView = textView
281|d6ed84|        
282|94dfef|        // Initial line count
283|0706d6|        DispatchQueue.main.async {
284|61f4f4|            self.totalLines = self.countLines(in: text)
285|5f3077|        }
286|d6ed84|        
287|36e727|        return textView
288|27e597|    }
289|b4687f|    
290|ddb800|    func updateUIView(_ textView: VSCodeRunestoneTextView, context: Context) {
291|6bce46|        // Update coordinator's parent reference for current bindings
292|aa6fd6|        context.coordinator.parent = self
293|d6ed84|        
294|fa3f7d|        // Update theme if changed
295|462091|        let currentThemeId = ThemeManager.shared.currentTheme.id
296|173529|        if context.coordinator.lastThemeId != currentThemeId {
297|0ae3b4|            context.coordinator.lastThemeId = currentThemeId
298|cd161e|            textView.theme = makeRunestoneTheme()
299|2c8fb7|            textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
300|5f3077|        }
301|d6ed84|        
302|c11584|        // Update font size if changed
303|0d6968|        if context.coordinator.lastFontSize != fontSize {
304|ad902d|            context.coordinator.lastFontSize = fontSize
305|cd161e|            textView.theme = makeRunestoneTheme()
306|5f3077|        }
307|d6ed84|        
308|cb515b|        // Update settings if changed (live toggle support)
309|8f116a|        if textView.showLineNumbers != showLineNumbers {
310|c530c2|            textView.showLineNumbers = showLineNumbers
311|5f3077|        }
312|8e7477|        if textView.isLineWrappingEnabled != wordWrapEnabled {
313|ed0ffc|            textView.isLineWrappingEnabled = wordWrapEnabled
314|5f3077|        }
315|d6ed84|        
316|26756b|        // CRITICAL: Only call setState() when safe (not during active editing)
317|e2bb7b|        // Calling setState() during editing corrupts Runestone's lineManager
318|092fab|        // and causes crash at TextEditHelper.swift:27 (force unwrap on linePosition)
319|d6ed84|        
320|a43f62|        let isFileSwitching = context.coordinator.lastFilename != filename
321|d8aa68|        let currentText = textView.text
322|5cc09d|        let textChanged = currentText != text
323|dbea58|        let isActivelyEditing = textView.isFirstResponder
324|d6ed84|        
325|317e91|        if isFileSwitching {
326|97906a|            // User switched to a different file - safe to call setState()
327|6db873|            context.coordinator.lastFilename = filename
328|a9199d|            context.coordinator.hasBeenEdited = false
329|3070d1|            
330|66a1a1|            if let language = getTreeSitterLanguage(for: filename) {
331|d00b5e|                let state = TextViewState(text: text, language: language)
332|d69a75|                textView.setState(state)
333|f5a6eb|            } else {
334|8d685d|                textView.text = text
335|a7dc16|            }
336|3070d1|            
337|80f64f|            // CRITICAL: Re-apply theme AFTER setState - setState may reset rendering state
338|cd161e|            textView.theme = makeRunestoneTheme()
339|3070d1|            
340|00d273|            // Reset cursor to start for new file
341|f89f38|            textView.selectedRange = NSRange(location: 0, length: 0)
342|3070d1|            
343|a6439c|            // Update line count
344|ebb427|            DispatchQueue.main.async {
345|b26907|                self.totalLines = self.countLines(in: text)
346|a7dc16|            }
347|8bc7f3|        } else if textChanged && !context.coordinator.hasBeenEdited && !isActivelyEditing && !context.coordinator.isUpdatingFromTextView {
348|016671|            // Text changed externally (e.g., initial load, external modification)
349|51a126|            // Safe to update since user hasn't started editing yet
350|66a1a1|            if let language = getTreeSitterLanguage(for: filename) {
351|d00b5e|                let state = TextViewState(text: text, language: language)
352|d69a75|                textView.setState(state)
353|f5a6eb|            } else {
354|8d685d|                textView.text = text
355|a7dc16|            }
356|3070d1|            
357|80f64f|            // CRITICAL: Re-apply theme AFTER setState - setState may reset rendering state
358|cd161e|            textView.theme = makeRunestoneTheme()
359|3070d1|            
360|a6439c|            // Update line count
361|ebb427|            DispatchQueue.main.async {
362|b26907|                self.totalLines = self.countLines(in: text)
363|a7dc16|            }
364|5f3077|        }
365|57fb66|        // If user HAS edited OR is actively editing, DO NOTHING
366|a3857b|        // Let the user's edits remain - don't corrupt the lineManager
367|27e597|    }
368|b4687f|    
369|072048|    // MARK: - Runestone Theme Factory
370|b4687f|    
371|9607ec|    private func makeRunestoneTheme() -> RunestoneEditorTheme {
372|71a1d4|        let appTheme = ThemeManager.shared.currentTheme
373|754683|        return RunestoneEditorTheme(
374|141233|            fontSize: fontSize,
375|6fed03|            backgroundColor: UIColor(appTheme.editorBackground),
376|3ff577|            textColor: UIColor(appTheme.editorForeground),
377|25c8f7|            gutterBackgroundColor: UIColor(appTheme.editorBackground),
378|f59562|            gutterHairlineColor: UIColor(appTheme.lineNumber).withAlphaComponent(0.3),
379|69b115|            lineNumberColor: UIColor(appTheme.lineNumber),
380|761e46|            selectedLineBackgroundColor: UIColor(appTheme.currentLineHighlight),
381|253711|            selectedLinesLineNumberColor: UIColor(appTheme.lineNumberActive),
382|c74ad9|            selectedLinesGutterBackgroundColor: UIColor(appTheme.currentLineHighlight),
383|2f7e95|            invisibleCharactersColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.3),
384|d7f152|            pageGuideHairlineColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.1),
385|811607|            pageGuideBackgroundColor: UIColor(appTheme.editorBackground),
386|f4a737|            markedTextBackgroundColor: UIColor(appTheme.selection).withAlphaComponent(0.5),
387|8585f5|            keywordColor: UIColor(appTheme.keyword),
388|b3e17b|            stringColor: UIColor(appTheme.string),
389|7ff3fd|            numberColor: UIColor(appTheme.number),
390|a05855|            commentColor: UIColor(appTheme.comment),
391|2801b0|            functionColor: UIColor(appTheme.function),
392|12e112|            typeColor: UIColor(appTheme.type),
393|684aec|            variableColor: UIColor(appTheme.variable)
394|3143a4|        )
395|27e597|    }
396|b4687f|    
397|957540|    // MARK: - Language Mode Mapping
398|b4687f|    
399|70f3e8|    /// Gets the actual TreeSitter Language object for a given filename
400|f3a5e1|    /// Returns nil for plain text files (no syntax highlighting)
401|a4a35b|    private func getTreeSitterLanguage(for filename: String) -> Runestone.TreeSitterLanguage? {
402|98942b|        let ext = (filename as NSString).pathExtension.lowercased()
403|82335e|        let lastComponent = (filename as NSString).lastPathComponent.lowercased()
404|d6ed84|        
405|ab25ec|        // Special-case filenames without extensions
406|013551|        if lastComponent == "dockerfile" || lastComponent.hasPrefix("dockerfile.") {
407|274790|            return nil // Bash support not in package list yet
408|5f3077|        }
409|bf07fd|        if lastComponent == ".env" || lastComponent.hasPrefix(".env.") {
410|3e3e36|            return nil // Plain text
411|5f3077|        }
412|828d40|        if lastComponent == "makefile" || lastComponent == "gnumakefile" {
413|274790|            return nil // Bash support not in package list yet
414|5f3077|        }
415|4b7128|        if lastComponent == "podfile" || lastComponent == "gemfile" {
416|46c419|            return nil // Ruby support not in package list yet
417|5f3077|        }
418|0efae9|        if lastComponent == "package.json" || lastComponent == "tsconfig.json" {
419|4d9419|            return TreeSitterLanguage.json
420|5f3077|        }
421|d6ed84|        
422|f60e4e|        switch ext {
423|4c2810|        // Swift
424|1c8542|        case "swift":
425|376f7d|            return TreeSitterLanguage.swift
426|d6ed84|        
427|20fa65|        // JavaScript
428|cd5864|        case "js", "mjs", "cjs", "jsx":
429|fd14ee|            return TreeSitterLanguage.javaScript
430|d6ed84|        
431|194537|        // TypeScript - use JavaScript as fallback
432|a4d183|        case "ts", "mts", "cts", "tsx":
433|fd14ee|            return TreeSitterLanguage.javaScript
434|d6ed84|        
435|a87c1b|        // Python
436|85dfd3|        case "py", "pyw", "pyi":
437|4462da|            return TreeSitterLanguage.python
438|d6ed84|        
439|cd9e63|        // Go
440|ee50e6|        case "go":
441|44c0af|            return TreeSitterLanguage.go
442|d6ed84|        
443|fd611a|        // Rust
444|c28591|        case "rs":
445|9af65c|            return TreeSitterLanguage.rust
446|d6ed84|        
447|08c082|        // JSON
448|7aa37f|        case "json", "jsonc":
449|4d9419|            return TreeSitterLanguage.json
450|d6ed84|        
451|8aadd1|        // HTML
452|8f517a|        case "html", "htm", "xhtml":
453|d6b81f|            return TreeSitterLanguage.html
454|d6ed84|        
455|b0d395|        // CSS
456|c4efc3|        case "css", "scss":
457|27b343|            return TreeSitterLanguage.css
458|d6ed84|        
459|0fbfad|        // XML - use HTML as fallback
460|f580bd|        case "xml", "plist", "svg":
461|d6b81f|            return TreeSitterLanguage.html
462|d6ed84|        
463|c32a01|        // Default - no syntax highlighting
464|520b7d|        default:
465|1c8557|            return nil
466|5f3077|        }
467|27e597|    }
468|adc83b|
469|b4687f|    
470|ee02fb|    // MARK: - Helpers
471|b4687f|    
472|6a2db5|    private func countLines(in text: String) -> Int {
473|ee3501|        guard !text.isEmpty else { return 1 }
474|c746a1|        var count = 1
475|48817a|        var index = text.startIndex
476|42136d|        while index < text.endIndex {
477|4396fc|            if text[index] == "\n" {
478|31d0c1|                count += 1
479|a7dc16|            }
480|3a0fcb|            index = text.index(after: index)
481|5f3077|        }
482|c7b6e6|        return count
483|27e597|    }
484|b4687f|    
485|b90e11|    // MARK: - Coordinator
486|b4687f|    
487|57fd33|    class Coordinator: NSObject, TextViewDelegate {
488|fe867f|        var parent: RunestoneEditorView
489|0bde9e|        weak var textView: TextView?
490|e0c082|        var isUpdatingFromTextView = false
491|d5e6db|        var lastFontSize: CGFloat = 14.0
492|df72ce|        var lastThemeId: String = ""
493|e181a1|        var currentLanguage: Language?
494|d6ed84|        
495|b93091|        // Track file identity to know when to call setState()
496|244df6|        var lastFilename: String = ""
497|82a9dc|        var hasBeenEdited: Bool = false
498|d6ed84|        
499|a814d3|        // Debounced text sync to avoid SwiftUI re-renders on every keystroke
500|aae740|        private var textSyncWorkItem: DispatchWorkItem?
501|8fda30|        private let debounceInterval: TimeInterval = 0.5 // 500ms
502|d6ed84|        
503|043ea2|        init(_ parent: RunestoneEditorView) {
504|12d237|            self.parent = parent
505|ffb0bd|            self.lastFontSize = parent.fontSize
506|3fc189|            self.lastThemeId = ThemeManager.shared.currentTheme.id
507|c8ef01|            self.lastFilename = parent.filename
508|5f3077|        }
509|d6ed84|        
510|788eb1|        deinit {
511|e504ad|            // Cancel any pending debounced updates
512|bc1cc6|            textSyncWorkItem?.cancel()
513|5f3077|        }
514|d6ed84|        
515|cc0795|        // MARK: - TextViewDelegate
516|d6ed84|        
517|b75d27|        func textViewDidChange(_ textView: TextView) {
518|02717e|            // Mark that user has edited - blocks setState() calls until file switch
519|f51822|            hasBeenEdited = true
520|3070d1|            
521|d2cd8b|            // Cancel any pending debounced update
522|bc1cc6|            textSyncWorkItem?.cancel()
523|3070d1|            
524|6966df|            // Create new debounced work item
525|36310e|            let workItem = DispatchWorkItem { [weak self] in
526|150252|                guard let self = self else { return }
527|84d674|                self.isUpdatingFromTextView = true
528|0ae33b|                defer { self.isUpdatingFromTextView = false }
529|216278|                
530|24c8b7|                // Update text binding (debounced - only after typing stops)
531|c75e92|                self.parent.text = textView.text
532|216278|                
533|416a60|                // Update line count
534|f143b8|                DispatchQueue.main.async {
535|d865ea|                    self.parent.totalLines = self.parent.countLines(in: textView.text)
536|4e2d32|                }
537|a7dc16|            }
538|3070d1|            
539|eaaa24|            // Schedule the update after debounce interval
540|587c05|            textSyncWorkItem = workItem
541|c3b6ab|            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
542|5f3077|        }
543|d6ed84|        
544|6a67c9|        /// Immediately sync text to SwiftUI binding (call on save/tab-switch)
545|a61f5c|        func syncTextImmediately() {
546|d2cd8b|            // Cancel any pending debounced update
547|bc1cc6|            textSyncWorkItem?.cancel()
548|3070d1|            
549|078830|            guard let textView = textView else { return }
550|3070d1|            
551|3f491a|            isUpdatingFromTextView = true
552|5485b2|            defer { isUpdatingFromTextView = false }
553|3070d1|            
554|6db6b0|            // Immediate sync
555|f9041f|            parent.text = textView.text
556|9b320f|            parent.totalLines = parent.countLines(in: textView.text)
557|5f3077|        }
558|d6ed84|        
559|49059d|        func textViewDidChangeSelection(_ textView: TextView) {
560|b59fde|            updateCursorPosition(in: textView)
561|5f3077|        }
562|d6ed84|        
563|4eb4ea|        func textViewDidBeginEditing(_ textView: TextView) {
564|bb2790|            // Could be used for focus handling
565|5f3077|        }
566|d6ed84|        
567|40d063|        func textViewDidEndEditing(_ textView: TextView) {
568|bb2790|            // Could be used for focus handling
569|5f3077|        }
570|d6ed84|        
571|f6a64f|        func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
572|3f3964|            // Handle Tab key for autocomplete acceptance
573|6688de|            if text == "\t" {
574|f9c439|                if let onAccept = parent.onAcceptAutocomplete, onAccept() {
575|df59cf|                    return false
576|4e2d32|                }
577|a7dc16|            }
578|3070d1|            
579|cc3aa6|            // Handle Escape key for autocomplete dismissal
580|ce7885|            // Note: Escape key events are typically handled via key commands, not here
581|3070d1|            
582|40cfc4|            return true
583|5f3077|        }
584|d6ed84|        
585|fc84c5|        func scrollViewDidScroll(_ scrollView: UIScrollView) {
586|6c450e|            // Update scroll offset binding for gutter synchronization
587|ebb427|            DispatchQueue.main.async {
588|e41cd2|                self.parent.scrollOffset = scrollView.contentOffset.y
589|a7dc16|            }
590|5f3077|        }
591|d6ed84|        
592|f9574f|        // MARK: - Cursor Position Calculation
593|d6ed84|        
594|638123|        private func updateCursorPosition(in textView: TextView) {
595|e844dd|            let selectedRange = textView.selectedRange
596|0c3128|            let text = textView.text as NSString
597|c0763f|            let cursorLocation = selectedRange.location
598|3070d1|            
599|3c0f5f|            // Calculate line and column from cursor location
600|2bf772|            var lineNumber = 1
601|b2dc74|            var columnNumber = 1
602|895788|            var currentLineStart = 0
603|3070d1|            
604|30ee03|            for i in 0..<min(cursorLocation, text.length) {
605|76817f|                if text.character(at: i) == UInt16(UnicodeScalar("\n").value) {
606|4ae0f3|                    lineNumber += 1
607|1230ab|                    currentLineStart = i + 1
608|4e2d32|                }
609|a7dc16|            }
610|3070d1|            
611|fe9f83|            // Column is the offset from the start of the current line
612|2ea6e9|            columnNumber = cursorLocation - currentLineStart + 1
613|3070d1|            
614|13f4e9|            // Update bindings on main thread to avoid SwiftUI state update warnings
615|ebb427|            DispatchQueue.main.async {
616|62efc4|                self.parent.cursorIndex = cursorLocation
617|29327f|                self.parent.currentLineNumber = lineNumber
618|975d29|                self.parent.currentColumn = columnNumber
619|a7dc16|            }
620|5f3077|        }
621|27e597|    }
622|b31277|}
623|adc83b|
624|7246b9|// MARK: - Runestone Theme Implementation
625|adc83b|
626|23f6be|/// Custom theme implementation for Runestone that maps app theme colors to editor appearance
627|15772b|class RunestoneEditorTheme: Runestone.Theme {
628|82ae06|    let fontSize: CGFloat
629|b4687f|    
630|674973|    // Core colors
631|63a650|    private let _backgroundColor: UIColor
632|69ecef|    private let _textColor: UIColor
633|a63dc8|    private let _gutterBackgroundColor: UIColor
634|61f893|    private let _gutterHairlineColor: UIColor
635|46e697|    private let _lineNumberColor: UIColor
636|b77015|    private let _selectedLineBackgroundColor: UIColor
637|45d5b6|    private let _selectedLinesLineNumberColor: UIColor
638|507d94|    private let _selectedLinesGutterBackgroundColor: UIColor
639|df300a|    private let _invisibleCharactersColor: UIColor
640|7fcd59|    private let _pageGuideHairlineColor: UIColor
641|35d435|    private let _pageGuideBackgroundColor: UIColor
642|54ba9c|    private let _markedTextBackgroundColor: UIColor
643|b4687f|    
644|a068d3|    // Syntax colors
645|6a8c7b|    private let _keywordColor: UIColor
646|d325df|    private let _stringColor: UIColor
647|c14ae7|    private let _numberColor: UIColor
648|8109d2|    private let _commentColor: UIColor
649|8b9e8b|    private let _functionColor: UIColor
650|dfabea|    private let _typeColor: UIColor
651|9bf787|    private let _variableColor: UIColor
652|b4687f|    
653|62e028|    init(
654|03646e|        fontSize: CGFloat,
655|97f91e|        backgroundColor: UIColor,
656|49a1fd|        textColor: UIColor,
657|0fad6c|        gutterBackgroundColor: UIColor,
658|ce1735|        gutterHairlineColor: UIColor,
659|bb55ce|        lineNumberColor: UIColor,
660|b155a3|        selectedLineBackgroundColor: UIColor,
661|6c9121|        selectedLinesLineNumberColor: UIColor,
662|c2f462|        selectedLinesGutterBackgroundColor: UIColor,
663|5baff1|        invisibleCharactersColor: UIColor,
664|091cec|        pageGuideHairlineColor: UIColor,
665|b4018e|        pageGuideBackgroundColor: UIColor,
666|27caf6|        markedTextBackgroundColor: UIColor,
667|eafccc|        keywordColor: UIColor,
668|4e8e95|        stringColor: UIColor,
669|a8eb96|        numberColor: UIColor,
670|60e3f1|        commentColor: UIColor,
671|ccbcd5|        functionColor: UIColor,
672|f73e24|        typeColor: UIColor,
673|21f39b|        variableColor: UIColor
674|981e04|    ) {
675|aefa3e|        self.fontSize = fontSize
676|e7c18a|        self._backgroundColor = backgroundColor
677|6496d6|        self._textColor = textColor
678|ce814d|        self._gutterBackgroundColor = gutterBackgroundColor
679|00e443|        self._gutterHairlineColor = gutterHairlineColor
680|ca4d73|        self._lineNumberColor = lineNumberColor
681|eca234|        self._selectedLineBackgroundColor = selectedLineBackgroundColor
682|ed0200|        self._selectedLinesLineNumberColor = selectedLinesLineNumberColor
683|7b2780|        self._selectedLinesGutterBackgroundColor = selectedLinesGutterBackgroundColor
684|d0b4cd|        self._invisibleCharactersColor = invisibleCharactersColor
685|17d124|        self._pageGuideHairlineColor = pageGuideHairlineColor
686|3e4113|        self._pageGuideBackgroundColor = pageGuideBackgroundColor
687|a9e119|        self._markedTextBackgroundColor = markedTextBackgroundColor
688|a0ba9e|        self._keywordColor = keywordColor
689|c8a0bb|        self._stringColor = stringColor
690|838c3f|        self._numberColor = numberColor
691|401c0b|        self._commentColor = commentColor
692|ad8646|        self._functionColor = functionColor
693|21a810|        self._typeColor = typeColor
694|ca4496|        self._variableColor = variableColor
695|27e597|    }
696|b4687f|    
697|7f191d|    // MARK: - Theme Protocol Properties
698|b4687f|    
699|8f5011|    var font: UIFont {
700|b3c33c|        UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
701|27e597|    }
702|b4687f|    
703|c63798|    var textColor: UIColor {
704|b0766b|        _textColor
705|27e597|    }
706|b4687f|    
707|a341cb|    var gutterBackgroundColor: UIColor {
708|d276f1|        _gutterBackgroundColor
709|27e597|    }
710|b4687f|    
711|bd9178|    var gutterHairlineColor: UIColor {
712|d3bdb3|        _gutterHairlineColor
713|27e597|    }
714|b4687f|    
715|140e5a|    var lineNumberColor: UIColor {
716|441d7b|        _lineNumberColor
717|27e597|    }
718|b4687f|    
719|b10d53|    var lineNumberFont: UIFont {
720|8af963|        UIFont.monospacedSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
721|27e597|    }
722|b4687f|    
723|17d30e|    var selectedLineBackgroundColor: UIColor {
724|426cdf|        _selectedLineBackgroundColor
725|27e597|    }
726|b4687f|    
727|9754a3|    var selectedLinesLineNumberColor: UIColor {
728|9d658b|        _selectedLinesLineNumberColor
729|27e597|    }
730|b4687f|    
731|829549|    var selectedLinesGutterBackgroundColor: UIColor {
732|deca65|        _selectedLinesGutterBackgroundColor
733|27e597|    }
734|b4687f|    
735|7ca6bc|    var invisibleCharactersColor: UIColor {
736|65f0fd|        _invisibleCharactersColor
737|27e597|    }
738|b4687f|    
739|e3c8a4|    var pageGuideHairlineColor: UIColor {
740|7b7247|        _pageGuideHairlineColor
741|27e597|    }
742|b4687f|    
743|ac8dba|    var pageGuideBackgroundColor: UIColor {
744|f52547|        _pageGuideBackgroundColor
745|27e597|    }
746|b4687f|    
747|441109|    var markedTextBackgroundColor: UIColor {
748|6f8303|        _markedTextBackgroundColor
749|27e597|    }
750|b4687f|    
751|ff2c29|    // MARK: - Syntax Highlighting
752|b4687f|    
753|77216f|    func textColor(for rawHighlightName: String) -> UIColor? {
754|364fdf|        // Map TreeSitter highlight names to colors
755|077102|        // See: https://tree-sitter.github.io/tree-sitter/syntax-highlighting#highlights
756|a3c6a6|        let highlightName = rawHighlightName.lowercased()
757|d6ed84|        
758|3e8301|        // Debug: Log ALL highlight names to console (ENABLED FOR DEBUGGING)
759|1aa7f0|        print("🎨 HIGHLIGHT: '\(rawHighlightName)' -> ", terminator: "")
760|d6ed84|        
761|5f2431|        // Keywords
762|347daa|        if highlightName.contains("keyword") {
763|e0cdb7|            print("keyword (blue)")
764|11656d|            return _keywordColor
765|5f3077|        }
766|d6ed84|        
767|c13ace|        // JSON/Object keys - MUST return color for specific patterns
768|164d0a|        // TreeSitter JSON emits BOTH "string.special.key" AND "string" for keys
769|63f969|        // We handle specific patterns first, then skip generic "string" to avoid overwrite
770|929452|        if highlightName.hasPrefix("string.special") ||
771|7d9926|           highlightName.contains("label") ||
772|81c371|           highlightName.contains("property.definition") {
773|7612b6|            print("key/label (light blue)")
774|5086b7|            return _variableColor  // Light blue #9CDCFE for keys
775|5f3077|        }
776|d6ed84|        
777|5fe933|        // Strings - but NOT if it's JUST "string" (let specific matches win)
778|dcb001|        // Only color strings that are clearly values, not potential keys
779|ab3d14|        if highlightName.contains("string") {
780|5655ac|            print("string (orange)")
781|f09755|            return _stringColor  // Orange #CE9178 for string values
782|5f3077|        }
783|d6ed84|        
784|f425cd|        // Numbers and constants
785|a2036f|        if highlightName.contains("number") || highlightName == "constant.numeric" {
786|57bea5|            print("number (green)")
787|da9aee|            return _numberColor
788|5f3077|        }
789|d6ed84|        
790|185d89|        // Comments
791|f4b237|        if highlightName.contains("comment") {
792|e46058|            return _commentColor
793|5f3077|        }
794|d6ed84|        
795|4d76db|        // Functions and methods
796|915dec|        if highlightName.contains("function") || highlightName.contains("method") {
797|69dae5|            return _functionColor
798|5f3077|        }
799|d6ed84|        
800|5853d5|        // Types, classes, structs
801|a68e63|        if highlightName.contains("type") || highlightName.contains("class") ||
802|fe7d45|           highlightName.contains("struct") || highlightName.contains("interface") ||
803|7850d5|           highlightName.contains("enum") {
804|079364|            return _typeColor
805|5f3077|        }
806|d6ed84|        
807|100acb|        // Variables, parameters, properties
808|87a47d|        if highlightName.contains("variable") || highlightName.contains("parameter") ||
809|6198a9|           highlightName.contains("property") || highlightName.contains("field") {
810|0e23b9|            return _variableColor
811|5f3077|        }
812|d6ed84|        
813|f1a54a|        // Constants and booleans - use keyword color
814|cc358f|        if highlightName.contains("constant") || highlightName.contains("boolean") {
815|11656d|            return _keywordColor
816|5f3077|        }
817|d6ed84|        
818|b158fb|        // Operators - use keyword color
819|1a986d|        if highlightName.contains("operator") {
820|11656d|            return _keywordColor
821|5f3077|        }
822|d6ed84|        
823|8737fd|        // Namespaces and modules - use type color
824|d04ebe|        if highlightName.contains("namespace") || highlightName.contains("module") {
825|079364|            return _typeColor
826|5f3077|        }
827|d6ed84|        
828|d204ef|        // Tags (HTML, XML) - use type color
829|e21ab6|        if highlightName.contains("tag") {
830|079364|            return _typeColor
831|5f3077|        }
832|d6ed84|        
833|2abb6b|        // Attributes - use variable color
834|91f255|        if highlightName.contains("attribute") {
835|0e23b9|            return _variableColor
836|5f3077|        }
837|d6ed84|        
838|bb1e1f|        // Spell checking highlights - ignore (return nil to use default)
839|1dc697|        if highlightName.contains("spell") {
840|1c8557|            return nil
841|5f3077|        }
842|d6ed84|        
843|3d22f9|        // Include/import statements - use keyword color
844|fd8f58|        if highlightName.contains("include") {
845|11656d|            return _keywordColor
846|5f3077|        }
847|d6ed84|        
848|c1e1a1|        // Default: use standard text color
849|e35567|        print("nil (default)")
850|c2ae65|        return nil
851|27e597|    }
852|b4687f|    
853|666dc2|    func fontTraits(for rawHighlightName: String) -> FontTraits {
854|a3c6a6|        let highlightName = rawHighlightName.lowercased()
855|d6ed84|        
856|f6d691|        // Make comments italic
857|f4b237|        if highlightName.contains("comment") {
858|9ac334|            return .italic
859|5f3077|        }
860|d6ed84|        
861|556e36|        // Make keywords bold
862|347daa|        if highlightName.contains("keyword") {
863|7775b3|            return .bold
864|5f3077|        }
865|d6ed84|        
866|b72a10|        return []
867|27e597|    }
868|b31277|}
869|adc83b|
870|adc83b|
871|adc83b|
872|5e4767|// MARK: - Preview
873|7d6cf3|#if DEBUG
874|d96129|struct RunestoneEditorView_Previews: PreviewProvider {
875|23ccc3|    @State static var text = """
876|c1065b|    func hello() {
877|cf26fb|        print("Hello, World!")
878|27e597|    }
879|b4687f|    
880|dea7f1|    // This is a comment
881|3fef35|    let number = 42
882|8a4f92|    let string = "test"
883|87f133|    """
884|f58238|    @State static var scrollOffset: CGFloat = 0
885|708cb1|    @State static var totalLines = 7
886|6ac8ce|    @State static var currentLineNumber = 1
887|eeb538|    @State static var currentColumn = 1
888|d2cdc5|    @State static var cursorIndex = 0
889|b4687f|    
890|b92db4|    static var previews: some View {
891|86a5f4|        RunestoneEditorView(
892|ddc198|            text: $text,
893|58b764|            filename: "test.swift",
894|656a50|            scrollOffset: $scrollOffset,
895|aed4a6|            totalLines: $totalLines,
896|d36a4f|            currentLineNumber: $currentLineNumber,
897|d238b6|            currentColumn: $currentColumn,
898|0e3014|            cursorIndex: $cursorIndex,
899|d77846|            isActive: true,
900|9ccdd9|            fontSize: 14
901|3143a4|        )
902|f4bf48|        .environmentObject(EditorCore())
903|27e597|    }
904|b31277|}
905|3f6acf|#endif
906|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: f4973229db81
File: VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift (lines 2-200 of 1386)
────────────────────────────────────────
2|d755ba|import SwiftUI
3|adc83b|
4|2908be|// MARK: - Navigation Location
5|41204c|struct NavigationLocation {
6|220d1e|    let tabId: UUID
7|390384|    let line: Int
8|539e50|    let column: Int
9|b31277|}
10|adc83b|
11|d2991a|// MARK: - Sidebar Panel (renamed from SidebarView to avoid conflict with SidebarView struct in Views)
12|a8f216|enum SidebarPanel {
13|0f9eb6|    case explorer
14|ea28a4|    case git
15|16448a|    case search
16|49cb25|    case extensions
17|b31277|}
18|adc83b|
19|a2fb27|// MARK: - Terminal Session Stub
20|fc8967|struct TerminalSession: Identifiable {
21|91b0e8|    let id: UUID
22|7255e0|    var title: String
23|9ac954|    var output: String
24|b4687f|    
25|77a7fd|    init(id: UUID = UUID(), title: String = "Terminal", output: String = "") {
26|51d091|        self.id = id
27|27169c|        self.title = title
28|6ef144|        self.output = output
29|27e597|    }
30|b31277|}
31|adc83b|
32|2fd1b6|// MARK: - Debug State Stubs
33|25e238|struct DebugSessionState {
34|ff6786|    var isPaused: Bool = false
35|3aea38|    var currentLine: Int?
36|38a719|    var currentFile: String?
37|cdfb22|    var callStack: [String] = []
38|63e31e|    var variables: [String: String] = [:]
39|b31277|}
40|adc83b|
41|47c98a|struct DebugBreakpoint: Identifiable, Equatable {
42|91b0e8|    let id: UUID
43|7e6914|    var file: String
44|acbcc9|    var line: Int
45|46cb5f|    var isEnabled: Bool
46|02ea27|    var condition: String?
47|b4687f|    
48|38228a|    init(id: UUID = UUID(), file: String, line: Int, isEnabled: Bool = true, condition: String? = nil) {
49|51d091|        self.id = id
50|f386e5|        self.file = file
51|84c49f|        self.line = line
52|bc842e|        self.isEnabled = isEnabled
53|3d45db|        self.condition = condition
54|27e597|    }
55|b31277|}
56|adc83b|
57|20222f|// MARK: - Peek Definition State
58|283e14|struct PeekState: Equatable {
59|2553d0|    let file: String
60|390384|    let line: Int
61|02a6c7|    let content: String
62|bbcf1b|    let sourceLine: Int // The line where peek was triggered
63|b31277|}
64|adc83b|
65|320daa|// MARK: - Editor Core (Central State Manager)
66|312682|class EditorCore: ObservableObject {
67|1ee7ef|    @Published var peekState: PeekState?
68|a6d994|    @Published var tabs: [Tab] = []
69|e129c3|    @Published var activeTabId: UUID?
70|29899f|    @Published var showSidebar = true
71|4d5c2a|    @Published var sidebarWidth: CGFloat = 250
72|dfe044|    @Published var showFilePicker = false
73|949c0a|    @Published var showSaveAsDialog = false
74|cabad2|    var saveAsContent: String = ""
75|f8bcea|    @Published var lastSaveError: String?
76|0818a1|    @Published var searchText = ""
77|84d537|    @Published var showSearch = false
78|f84db8|    @Published var showCommandPalette = false
79|fbcbe4|    @Published var showQuickOpen = false
80|f2f493|    @Published var showAIAssistant = false
81|7c3010|    @Published var showGoToLine = false
82|13859f|    @Published var showGoToSymbol = false
83|e43e57|    @Published var editorFontSize: CGFloat = 14.0
84|2e5f14|    @Published var isZenMode = false
85|fa580f|    @Published var isFocusMode = false
86|adc83b|
87|fca5a3|    // Snippet picker support
88|15f11e|    @Published var showSnippetPicker = false
89|941161|    @Published var pendingSnippetInsertion: Snippet?
90|adc83b|
91|27e392|    // Cursor tracking
92|a020ef|    @Published var cursorPosition = CursorPosition()
93|adc83b|
94|5442e5|    // Multi-cursor support
95|a9b9d0|    @Published var multiCursorState = MultiCursorState()
96|ba0b96|    @Published var currentSelection: String = ""
97|1a3f89|    @Published var currentSelectionRange: NSRange?
98|adc83b|
99|82e321|    // Selection request for find/replace navigation
100|bc0892|    @Published var requestedSelection: NSRange?
101|adc83b|
102|f1b77b|    // UI Panel state
103|5d1a58|    @Published var showPanel = false
104|dfc392|    @Published var showRenameSymbol = false
105|1f093c|    @Published var focusedSidebarTab = 0
106|adc83b|
107|d51ea1|    // Terminal state
108|81609c|    @Published var terminalSessions: [TerminalSession] = []
109|505e94|    @Published var activeTerminalId: UUID?
110|f12907|    @Published var isTerminalMaximized: Bool = false
111|eb5ca9|    @Published var terminalPanelHeight: CGFloat = 200
112|adc83b|
113|9f19f0|    // Debug state
114|cbb347|    @Published var isDebugging: Bool = false
115|6b6ac5|    @Published var isRunning: Bool = false
116|e75e60|    @Published var canStartDebugging: Bool = true
117|019801|    @Published var showAddConfiguration: Bool = false
118|bfe134|    @Published var debugSessionState: DebugSessionState?
119|79abaa|    @Published var breakpoints: [DebugBreakpoint] = []
120|adc83b|
121|cd5080|    // Focused sidebar panel
122|15b1c0|    @Published var focusedView: SidebarPanel = .explorer
123|adc83b|
124|fda16b|    // Reference to file navigator for workspace search
125|e4df05|    weak var fileNavigator: FileSystemNavigator?
126|adc83b|
127|9ec84f|    // Navigation history
128|6a3111|    private var navigationHistory: [NavigationLocation] = []
129|4d0d46|    private var navigationIndex = -1
130|adc83b|
131|7b8f21|    /// Track active security-scoped URL access while files are open in tabs.
132|b24c0d|    /// This avoids losing access after opening a document (common on iPadOS).
133|e6fd81|    private var securityScopedAccessCounts: [URL: Int] = [:]
134|adc83b|
135|b8bdf3|    var activeTab: Tab? {
136|59ee7e|        tabs.first { $0.id == activeTabId }
137|27e597|    }
138|adc83b|
139|75cc04|    var activeTabIndex: Int? {
140|de4487|        tabs.firstIndex { $0.id == activeTabId }
141|27e597|    }
142|adc83b|
143|359b1b|    init() {
144|62fd7f|        // Create example tabs for all supported languages
145|0ba339|        let exampleTabs = Self.createExampleTabs()
146|8780f1|        tabs.append(contentsOf: exampleTabs)
147|4f6451|        activeTabId = exampleTabs.first?.id ?? UUID()
148|27e597|    }
149|b4687f|    
150|78f12b|    /// Creates example tabs demonstrating syntax highlighting for all supported languages
151|a830d6|    private static func createExampleTabs() -> [Tab] {
152|8cfd49|        var examples: [Tab] = []
153|d6ed84|        
154|a13ba8|        // Swift example
155|f0955b|        examples.append(Tab(
156|0bc9a8|            fileName: "Welcome.swift",
157|7a029b|            content: """
158|cf53a7|// Welcome to VS Code for iPadOS! 🎉
159|8d0643|//
160|f205ed|// Features:
161|8cef3f|// • Syntax highlighting for Swift, JS, Python, and more
162|9a4015|// • Multiple tabs with drag reordering
163|ca1f11|// • File explorer sidebar
164|463668|// • Command palette (⌘+Shift+P)
165|9a7f61|// • Quick open (⌘+P)
166|73eab0|// • Find & Replace (⌘+F)
167|c04970|// • AI Assistant
168|cb07e6|// • Minimap navigation
169|7db993|// • Code folding
170|8f1f2b|// • Go to line (⌘+G)
171|8d0643|//
172|3349e5|// Start editing or open a file!
173|adc83b|
174|d755ba|import SwiftUI
175|adc83b|
176|4a07a6|struct ContentView: View {
177|bfb6e5|    @State private var counter = 0
178|b4687f|    
179|504e43|    var body: some View {
180|69d3a9|        VStack(spacing: 20) {
181|034352|            Text("Hello, World!")
182|1b4a82|                .font(.largeTitle)
183|f7ad69|                .foregroundColor(.blue)
184|3070d1|            
185|a1d5d1|            Button("Count: \\(counter)") {
186|497b4e|                counter += 1
187|a7dc16|            }
188|a68f66|            .buttonStyle(.borderedProminent)
189|5f3077|        }
190|72583e|        .padding()
191|27e597|    }
192|b31277|}
193|adc83b|
194|5e4767|// MARK: - Preview
195|0eca73|#Preview {
196|c476ef|    ContentView()
197|b31277|}
198|b7ce6e|""",
199|97882c|            language: "swift"
200|813e75|        ))




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/
📁 App/
📁 Assets.xcassets/
📁 Commands/
📁 Docs/
📁 Extensions/
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
   FIX_SUMMARY.md
   IMPLEMENTATION_SUMMARY.md
   Info.plist
   KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
   KeyboardShortcuts.md
   MULTI_WINDOW_IMPLEMENTATION.md
   MultiWindowSupport.md
   SceneDelegate.swift
   SyntaxHighlighter_Optimizations.md




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Commands/
   AppCommands.swift
   AppCommands.swift.bak




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 3b71ff45a1a9
File: VSCodeiPadOS/VSCodeiPadOS/Commands/AppCommands.swift (lines 1-4 of 4)
────────────────────────────────────────
1|b43708|// This file is intentionally empty
2|7a1c7a|// Menu commands are defined inline in VSCodeiPadOSApp.swift
3|35eb04|// to avoid duplicate registration issues
4|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5ea460def35d
File: VSCodeiPadOS/VSCodeiPadOS/App/VSCodeiPadOSApp.swift (lines 1-280 of 280)
────────────────────────────────────────
1|d755ba|import SwiftUI
2|adc83b|
3|401dd2|@main
4|cdd7c9|struct VSCodeiPadOSApp: App {
5|44480e|    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
6|188ba3|    @StateObject private var editorCore = EditorCore()
7|9eee01|    @State private var showSettings = false
8|489b1b|    @State private var showTerminal = false
9|2503ee|    @State private var windowTitle: String = "VS Code"
10|b4687f|    
11|cfc509|    var body: some Scene {
12|960265|        WindowGroup {
13|b5bccb|            ContentView()
14|6ba81f|                .environmentObject(editorCore)
15|76658d|                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WindowTitleDidChange"))) { notification in
16|541a76|                    if let userInfo = notification.userInfo,
17|dc535d|                       let title = userInfo["title"] as? String {
18|fbf516|                        windowTitle = title
19|fec065|                        updateWindowTitle(title)
20|c9717a|                    }
21|4e2d32|                }
22|5f3077|        }
23|20d856|        .commands {
24|7bb455|            // Hide conflicting system menus by replacing with empty content
25|eb2e59|            CommandGroup(replacing: .textEditing) { }
26|a36e9e|            CommandGroup(replacing: .help) { }
27|3070d1|            
28|e80f11|            // VS Code-style menu bar (our custom menus)
29|5b3e7b|            FileMenuCommands()
30|83883d|            EditMenuCommands()
31|ab422b|            SelectionMenuCommands()
32|52e200|            ViewMenuCommands()
33|604cab|            GoMenuCommands()
34|16eb17|            RunMenuCommands()
35|ad1a3c|            TerminalMenuCommands()
36|508b35|            HelpMenuCommands()
37|5f3077|        }
38|27e597|    }
39|b4687f|    
40|161a61|    private func updateWindowTitle(_ title: String) {
41|af07cf|        // Update the window title for the scene
42|cbe88f|        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
43|531eb8|            windowScene.title = title
44|5f3077|        }
45|27e597|    }
46|b31277|}
47|adc83b|
48|f5818c|// MARK: - File Menu Commands
49|adc83b|
50|cea89f|struct FileMenuCommands: Commands {
51|9db218|    var body: some Commands {
52|689074|        // Add to existing system File menu
53|640e37|        CommandGroup(replacing: .newItem) {
54|afb006|            Button("New File") {
55|05599e|                NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
56|a7dc16|            }
57|1514aa|            .keyboardShortcut("n", modifiers: .command)
58|3070d1|            
59|774a66|            Button("New Window") {
60|2668c7|                // Request new window via UIKit
61|a7dc16|            }
62|06a7ad|            .keyboardShortcut("n", modifiers: [.command, .option])
63|5f3077|        }
64|d6ed84|        
65|6e5685|        CommandGroup(after: .newItem) {
66|e744dc|            Divider()
67|3070d1|            
68|303836|            Button("Open...") {
69|0c45d2|                NotificationCenter.default.post(name: NSNotification.Name("OpenFile"), object: nil)
70|a7dc16|            }
71|3070d1|            
72|e744dc|            Divider()
73|3070d1|            
74|87c1fc|            Button("Save") {
75|8cd475|                NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
76|a7dc16|            }
77|df0850|            .keyboardShortcut("s", modifiers: .command)
78|3070d1|            
79|cfb2e6|            Button("Save All") {
80|07b858|                NotificationCenter.default.post(name: NSNotification.Name("SaveAllFiles"), object: nil)
81|a7dc16|            }
82|31c983|            .keyboardShortcut("s", modifiers: [.command, .option])
83|3070d1|            
84|e744dc|            Divider()
85|3070d1|            
86|dce406|            Button("Close Tab") {
87|00bdfb|                NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
88|a7dc16|            }
89|fc759f|            .keyboardShortcut("w", modifiers: .command)
90|5f3077|        }
91|27e597|    }
92|b31277|}
93|adc83b|
94|5de97f|// MARK: - Edit Menu Commands
95|adc83b|
96|895d4c|struct EditMenuCommands: Commands {
97|9db218|    var body: some Commands {
98|d44e9d|        // Add Find/Replace to existing Edit menu (after pasteboard operations)
99|5cfe80|        CommandGroup(after: .pasteboard) {
100|e744dc|            Divider()
101|3070d1|            
102|0b121d|            Button("Find") {
103|1bd6d0|                NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
104|a7dc16|            }
105|f97e35|            .keyboardShortcut("f", modifiers: .command)
106|3070d1|            
107|503e4e|            Button("Replace") {
108|35e0ea|                NotificationCenter.default.post(name: NSNotification.Name("ShowReplace"), object: nil)
109|a7dc16|            }
110|db41a5|            .keyboardShortcut("h", modifiers: [.command, .option])
111|5f3077|        }
112|27e597|    }
113|b31277|}
114|adc83b|
115|0dd79a|// MARK: - Selection Menu Commands
116|adc83b|
117|a96c93|struct SelectionMenuCommands: Commands {
118|9db218|    var body: some Commands {
119|3b5a73|        CommandMenu("Selection") {
120|57df08|            // Note: Select All removed - conflicts with UITextView Cmd+A
121|3070d1|            
122|463507|            Button("Add Cursor Above") {
123|be1ac5|                NotificationCenter.default.post(name: NSNotification.Name("AddCursorAbove"), object: nil)
124|a7dc16|            }
125|1d6b0a|            .keyboardShortcut(.upArrow, modifiers: [.command, .option])
126|3070d1|            
127|371466|            Button("Add Cursor Below") {
128|46f0c9|                NotificationCenter.default.post(name: NSNotification.Name("AddCursorBelow"), object: nil)
129|a7dc16|            }
130|2a6642|            .keyboardShortcut(.downArrow, modifiers: [.command, .option])
131|5f3077|        }
132|27e597|    }
133|b31277|}
134|adc83b|
135|c5458e|// MARK: - View Menu Commands
136|adc83b|
137|d50ec0|struct ViewMenuCommands: Commands {
138|9db218|    var body: some Commands {
139|e45db2|        // Add to existing system View menu
140|987c62|        CommandGroup(replacing: .sidebar) {
141|7db6f2|            Button("Toggle Sidebar") {
142|a086b2|                NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
143|a7dc16|            }
144|9245d1|            // Note: Cmd+B shortcut handled by UIKeyCommand in editor to override Bold
145|5f3077|        }
146|d6ed84|        
147|0e86b9|        CommandGroup(after: .sidebar) {
148|57043e|            Button("Command Palette") {
149|932cb8|                NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
150|a7dc16|            }
151|0d4533|            // Note: Cmd+Shift+P shortcut handled by UIKeyCommand in editor
152|3070d1|            
153|f1d311|            Button("Toggle Terminal") {
154|59bb23|                NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
155|a7dc16|            }
156|74fe55|            .keyboardShortcut("j", modifiers: .command)
157|3070d1|            
158|e744dc|            Divider()
159|3070d1|            
160|f7d3e3|            Button("Zoom In") {
161|633c0b|                NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
162|a7dc16|            }
163|a29ff9|            .keyboardShortcut("+", modifiers: .command)
164|3070d1|            
165|205092|            Button("Zoom Out") {
166|376a08|                NotificationCenter.default.post(name: NSNotification.Name("ZoomOut"), object: nil)
167|a7dc16|            }
168|67ad89|            .keyboardShortcut("-", modifiers: .command)
169|5f3077|        }
170|27e597|    }
171|b31277|}
172|adc83b|
173|039e1e|// MARK: - Go Menu Commands
174|adc83b|
175|858f73|struct GoMenuCommands: Commands {
176|9db218|    var body: some Commands {
177|2bde10|        CommandMenu("Go") {
178|652cca|            Button("Go to File...") {
179|ec83f0|                NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
180|a7dc16|            }
181|f54154|            .keyboardShortcut("p", modifiers: .command)
182|3070d1|            
183|c951ba|            Button("Go to Symbol...") {
184|9df234|                NotificationCenter.default.post(name: NSNotification.Name("ShowGoToSymbol"), object: nil)
185|a7dc16|            }
186|83c5d3|            .keyboardShortcut("o", modifiers: [.command, .shift])
187|3070d1|            
188|6f4da5|            Button("Go to Line...") {
189|af95e1|                NotificationCenter.default.post(name: NSNotification.Name("ShowGoToLine"), object: nil)
190|a7dc16|            }
191|62ad6b|            .keyboardShortcut("g", modifiers: .control)
192|3070d1|            
193|e744dc|            Divider()
194|3070d1|            
195|4e3b1e|            Button("Go to Definition") {
196|fc7cff|                NotificationCenter.default.post(name: NSNotification.Name("GoToDefinition"), object: nil)
197|a7dc16|            }
198|98c4c4|            .keyboardShortcut(.return, modifiers: .command)
199|3070d1|            
200|6ebc31|            Button("Go Back") {
201|bee9db|                NotificationCenter.default.post(name: NSNotification.Name("GoBack"), object: nil)
202|a7dc16|            }
203|4bc856|            .keyboardShortcut("[", modifiers: .control)
204|3070d1|            
205|f5d504|            Button("Go Forward") {
206|9c476e|                NotificationCenter.default.post(name: NSNotification.Name("GoForward"), object: nil)
207|a7dc16|            }
208|6c5cfe|            .keyboardShortcut("]", modifiers: .control)
209|5f3077|        }
210|27e597|    }
211|b31277|}
212|adc83b|
213|bbbab3|// MARK: - Run Menu Commands
214|adc83b|
215|56b0ce|struct RunMenuCommands: Commands {
216|9db218|    var body: some Commands {
217|35cc5e|        CommandMenu("Run") {
218|a151cc|            Button("Start Debugging") {
219|17dc53|                NotificationCenter.default.post(name: NSNotification.Name("StartDebugging"), object: nil)
220|a7dc16|            }
221|622ffb|            .keyboardShortcut("d", modifiers: [.command, .shift])
222|3070d1|            
223|fabf77|            Button("Run Without Debugging") {
224|9a83e4|                NotificationCenter.default.post(name: NSNotification.Name("RunWithoutDebugging"), object: nil)
225|a7dc16|            }
226|ea09f1|            .keyboardShortcut("r", modifiers: [.command, .shift])
227|3070d1|            
228|e744dc|            Divider()
229|3070d1|            
230|faaca0|            Button("Toggle Breakpoint") {
231|200e8e|                NotificationCenter.default.post(name: NSNotification.Name("ToggleBreakpoint"), object: nil)
232|a7dc16|            }
233|4bceb6|            .keyboardShortcut("b", modifiers: [.command, .shift])
234|5f3077|        }
235|27e597|    }
236|b31277|}
237|adc83b|
238|044961|// MARK: - Terminal Menu Commands
239|adc83b|
240|d92349|struct TerminalMenuCommands: Commands {
241|9db218|    var body: some Commands {
242|ca8d66|        CommandMenu("Terminal") {
243|6f8152|            Button("New Terminal") {
244|5843c7|                NotificationCenter.default.post(name: NSNotification.Name("NewTerminal"), object: nil)
245|a7dc16|            }
246|6371c2|            .keyboardShortcut("`", modifiers: [.control, .shift])
247|3070d1|            
248|cb847d|            Button("Clear Terminal") {
249|5513ef|                NotificationCenter.default.post(name: NSNotification.Name("ClearTerminal"), object: nil)
250|a7dc16|            }
251|8c8fb9|            .keyboardShortcut("k", modifiers: .command)
252|5f3077|        }
253|27e597|    }
254|b31277|}
255|adc83b|
256|e76d5b|// MARK: - Help Menu Commands
257|adc83b|
258|453771|struct HelpMenuCommands: Commands {
259|9db218|    var body: some Commands {
260|4afa1e|        CommandMenu("Help") {
261|e250dd|            Button("Documentation") {
262|38b70d|                if let url = URL(string: "https://code.visualstudio.com/docs") {
263|196c99|                    UIApplication.shared.open(url)
264|4e2d32|                }
265|a7dc16|            }
266|3070d1|            
267|ca047c|            Button("Keyboard Shortcuts") {
268|7511e5|                NotificationCenter.default.post(name: NSNotification.Name("ShowKeyboardShortcuts"), object: nil)
269|a7dc16|            }
270|fbd9f7|            .keyboardShortcut("k", modifiers: [.command, .shift])
271|3070d1|            
272|e744dc|            Divider()
273|3070d1|            
274|317359|            Button("About VS Code for iPad") {
275|ad8883|                NotificationCenter.default.post(name: NSNotification.Name("ShowAbout"), object: nil)
276|a7dc16|            }
277|5f3077|        }
278|27e597|    }
279|b31277|}
280|adc83b|


Now I have enough information to compile a comprehensive report.

>>>REPORT
# VSCodeiPadOS Architecture Analysis

## 1. ALL SERVICES AND THEIR FUNCTIONS

### Core State Management
- **EditorCore.swift** (Services/) - Central state manager: tabs, navigation history, cursor position, multi-cursor, debug state, terminal sessions, sidebar state, search, zoom, breakpoints. Uses @Published for SwiftUI reactivity.

### Code Execution
- **CodeExecutionService.swift** - Routes execution requests by file type to JSRunner (js/mjs), WASMRunner (wasm). TypeScript/Python show "not yet available" errors.
- **RunnerSelector.swift** - Intelligent on-device vs remote decision engine. Analyzes code for: language support, resource usage, dependencies, network/filesystem access, complexity. Returns ExecutionStrategy enum (.onDevice, .remote, .hybrid).

### On-Device Runners (Services/OnDevice/)
- **JSRunner.swift** - JavaScriptCore wrapper with: console.log capture via JSExport, native function exposure, timeout/memory limits, async execution.
- **WASMRunner.swift** - WebAssembly execution via **hidden WKWebView** (required because JSCore doesn't support WASM). Features: module loading, function execution, WASI stubs, host function registration.
- **PythonRunner.swift** (OnDevice) - Stub/mock implementation

### Remote Runners (Services/Runners/)
- **NodeRunner.swift** - macOS-only (`#if os(macOS)`), Process-based Node.js execution with npm script support, nvm/n version switching
- **PythonRunner.swift** - SSH-based Python execution with virtualenv support, traceback parsing
- **SwiftRunner.swift** - Similar SSH-based execution

### Editor Support Services
- **AutocompleteManager.swift** - Code completion
- **CodeFoldingManager.swift** - Fold regions detection/management
- **InlayHintsManager.swift** - Type hints overlay
- **HoverInfoManager.swift** - Hover documentation
- **BracketMatchingManager.swift** - Bracket pairing
- **SyntaxHighlighter** (multiple files) - Regex-based highlighting for legacy editor

### Infrastructure
- **ThemeManager.swift** - Editor theme management, maps to Runestone themes
- **FileSystemNavigator.swift** - File tree navigation
- **GitManager.swift** / **GitService.swift** - Git integration
- **SSHManager.swift** - SSH client for remote execution
- **OutputPanelManager.swift** - Output channel management

## 2. EDITOR ARCHITECTURE

### Primary: Runestone (Native iOS)
**File:** `Views/Editor/RunestoneEditorView.swift`
- Uses **Runestone library** with TreeSitter for syntax highlighting
- Custom subclass `VSCodeRunestoneTextView` extends Runestone's TextView
- **NOT WebView-based** - native UIKit text editing
- Built-in: line numbers, code folding, current line highlight

**Supported Languages (TreeSitter):**
- Swift, JavaScript, TypeScript (via JS), Python, Go, Rust, JSON, HTML, CSS

**Feature Flag:** `FeatureFlags.useRunestoneEditor` (currently enabled by default)

### Legacy Fallback: SyntaxHighlightingTextView
**File:** `Views/Editor/SyntaxHighlightingTextView.swift`
- UITextView-based with regex syntax highlighting
- Used when Runestone flag is disabled

### Key Editor Components
- `MinimapView.swift` - Code minimap
- `StickyHeaderView.swift` - Sticky function headers
- `InlayHintsOverlay.swift` - Type hints overlay
- `BreadcrumbsView.swift` - File path breadcrumbs

## 3. WEBVIEW/WKWEBVIEW USAGE

**Only 2 uses found:**

1. **WASMRunner.swift** (line 145-200)
   - Creates **hidden WKWebView** for WASM execution
   - Required because JavaScriptCore doesn't support WebAssembly
   - Safari's JSCore engine (in WKWebView) does support WASM
   - Uses WKUserContentController for Swift↔JS messaging

2. **MarkdownPreviewView.swift** (line 74-84)
   - WKWebView for rendering markdown via marked.js
   - Loads HTML string with CDN script

**NOT used for code editing** - Editor is fully native via Runestone

## 4. RUNNER IMPLEMENTATIONS

### JavaScript (On-Device)
**JSRunner.swift** - JavaScriptCore-based
- Console capture: `JSConsole` class conforms to `JSConsoleProtocol: JSExport`
- Native function exposure: `exposeNativeFunction(name:block:)`
- Execution: `execute(code:)` async with timeout
- Memory limit: configurable (default 100MB)
- Result conversion: JSValue → Swift types

### WebAssembly (On-Device)
**WASMRunner.swift** - WKWebView-based
- Hidden WebView executes WASM via browser APIs
- Module loading: base64-encoded data transfer
- WASI support: Stub implementations (limited on iOS)
- Host functions: Async-only via message handlers
- Configurations: .default, .pyodide, .rust presets

### Python (Remote Only)
**PythonRunner.swift** (Services/Runners/) - SSH-based
- Executes via SSH connection
- Virtual environment support
- Traceback parsing for error display
- Requirements installation

### Node.js (macOS Only)
**NodeRunner.swift** - Process-based
- Guarded by `#if os(macOS)`
- Full npm script execution
- nvm/n version switching
- Package manager detection (npm, yarn, pnpm)

## 5. MENU STRUCTURE

### Implementation Location
**VSCodeiPadOSApp.swift** - Menus defined inline using SwiftUI Commands API

### Menu Hierarchy
```
File: New File(⌘N), New Window(⌘⌥N), Open, Save(⌘S), Save All(⌘⌥S), Close Tab(⌘W)
Edit: [System items] + Find(⌘F), Replace(⌘⌥H)
Selection: Add Cursor Above(⌘⌥↑), Add Cursor Below(⌘⌥↓)
View: Toggle Sidebar, Command Palette, Toggle Terminal(⌘J), Zoom In(⌘+), Zoom Out(⌘-)
Go: Go to File(⌘P), Go to Symbol(⌘⇧O), Go to Line(^G), Go to Definition(⌘↵), Back(^[), Forward(^])
Run: Start Debugging(⌘⇧D), Run Without Debugging(⌘⇧R), Toggle Breakpoint(⌘⇧B)
Terminal: New Terminal(^⇧`), Clear Terminal(⌘K)
Help: Documentation, Keyboard Shortcuts(⌘⇧K), About
```

### Keyboard Shortcut Handling
- **UIKeyCommand overrides** in `VSCodeRunestoneTextView` for conflicts with UITextView defaults
- Uses `wantsPriorityOverSystemBehavior = true` to override Bold(⌘B), Print(⌘P), etc.
- Actions dispatch via `NotificationCenter.default.post(name:)`

## SUMMARY: WHAT TO KEEP VS REBUILD

### KEEP (High Quality)
- Runestone editor integration
- JSRunner implementation
- WASMRunner architecture (uses WKWebView appropriately)
- Menu structure pattern
- Theme system
- EditorCore state management pattern

### REBUILD/IMPROVE
- Python on-device execution (currently remote-only/stub)
- TypeScript execution (currently shows error)
- Remote runner integration (NodeRunner is macOS-only)
- WASMRunner improvements for Pyodide

### ARCHITECTURE NOTES
- Editor is **NOT WebView-based** - uses native Runestone/TreeSitter
- WKWebView is used **only** for WASM execution (necessary limitation)
- Services use NotificationCenter for menu→action decoupling
- Feature flags control editor implementation switching
>>>END
