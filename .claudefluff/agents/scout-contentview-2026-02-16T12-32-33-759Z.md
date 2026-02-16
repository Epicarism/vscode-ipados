# Agent: scout-contentview
**Status:** done
**Tokens:** 0
**Cost:** $0.0000
**Time:** 2026-02-16T12:32:33.759Z

## Task
Read ContentView.swift and search for how panels (terminal, problems, output) are integrated into the main layout. Report: how panels are switched, what tab system exists for bottom panels.

## Response


Now I need to find the `PanelView` component to understand how panels (terminal, problems, output) are implemented with tabs. Let me search for it.

---

## 🔧 TOOL RESULTS

[search]
Error searching: Extension 'danielswagg.outlier-chat' CANNOT use API proposal: findTextInFiles.
Its package.json#enabledApiProposals-property declares: [] but NOT findTextInFiles.
 The missing proposal MUST be added and you must start in extension development mode or use the following command line switch: --enable-proposed-api danielswagg.outlier-chat




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
   LICENSE
   README.md
   StressTest.swift
   test_editor_typing.sh
   update.md
   VSCodeiPadOS_idb_test_plan.sh
   VSCodeiPadOS_Ui_Element_Coordinates.md
   wasm-test-ipad.html




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
(cached)




---

## 🔧 TOOL RESULTS

[search]
Error searching: Extension 'danielswagg.outlier-chat' CANNOT use API proposal: findTextInFiles.
Its package.json#enabledApiProposals-property declares: [] but NOT findTextInFiles.
 The missing proposal MUST be added and you must start in extension development mode or use the following command line switch: --enable-proposed-api danielswagg.outlier-chat




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
   LICENSE
   README.md
   StressTest.swift
   test_editor_typing.sh
   update.md
   VSCodeiPadOS_idb_test_plan.sh
   VSCodeiPadOS_Ui_Element_Coordinates.md
   wasm-test-ipad.html
(cached)




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5029ab80acc8
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 1-1291 of 1291)
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
187|32cae6|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RunSampleWASM"))) { _ in
188|304fc6|            // Run the bundled test.wasm sample
189|47ed67|            Task {
190|76a227|                await runSampleWASM()
191|a7dc16|            }
192|5f3077|        }
193|15292a|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RunJavaScript"))) { _ in
194|88d4b9|            // Run current file as JavaScript
195|71e6ee|            if let activeTab = editorCore.activeTab {
196|0f0930|                Task {
197|236d24|                    await runJavaScript(code: activeTab.content, fileName: activeTab.fileName)
198|4e2d32|                }
199|a7dc16|            }
200|5f3077|        }
201|4a37b7|        .environmentObject(themeManager)
202|e3bdc6|        .environmentObject(editorCore)
203|27e597|    }
204|b4687f|    
205|231605|    private func finishOpeningWorkspace(_ url: URL) {
206|6dcdb7|        fileNavigator.loadFileTree(at: url)
207|d79336|        Task { @MainActor in
208|99e24e|            LaunchManager.shared.setWorkspaceRoot(url)
209|eccbe2|            GitManager.shared.setWorkingDirectory(url)
210|5f3077|        }
211|27e597|    }
212|b4687f|    
213|65a033|    private func updateWindowTitle() {
214|53ad0a|        if let activeTab = editorCore.activeTab {
215|ba8861|            let fileName = activeTab.fileName
216|b072a0|            let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
217|741609|            windowTitle = "\(unsavedIndicator)\(fileName) - VS Code"
218|59ea7f|        } else if !editorCore.tabs.isEmpty {
219|fa7eae|            windowTitle = "VS Code"
220|b31999|        } else {
221|6c3506|            windowTitle = "Welcome - VS Code"
222|5f3077|        }
223|d6ed84|        
224|c675c5|        // Notify the app of the title change
225|63edcc|        NotificationCenter.default.post(
226|9251fc|            name: NSNotification.Name("WindowTitleDidChange"),
227|33f159|            object: nil,
228|332f22|            userInfo: ["title": windowTitle]
229|3143a4|        )
230|27e597|    }
231|b4687f|    
232|ab06c2|    @ViewBuilder
233|0bbc6d|    private var sidebarContent: some View {
234|34711c|        switch selectedSidebarTab {
235|ab83f1|        case 0:
236|161f7c|            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
237|032375|        case 1:
238|19e3bd|            SidebarSearchView(theme: theme)
239|12d44a|        case 2:
240|7fc3ae|            GitView()
241|1a2232|        case 3:
242|7116ef|            DebugView()
243|520b7d|        default:
244|161f7c|            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
245|5f3077|        }
246|27e597|    }
247|b31277|}
248|adc83b|
249|6fd553|// MARK: - Activity Bar
250|adc83b|
251|adc83b|
252|adc83b|
253|4a910a|struct BarButton: View {
254|f0e87a|    let icon: String
255|055123|    let isSelected: Bool
256|6b0e55|    let theme: Theme
257|59027a|    let action: () -> Void
258|b4687f|    
259|504e43|    var body: some View {
260|6f04d8|        Button(action: action) {
261|ed6617|            Image(systemName: icon)
262|13a7f6|                .font(.system(size: 22))
263|557f46|                .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
264|c81e69|                .frame(width: 48, height: 48)
265|5f3077|        }
266|27e597|    }
267|b31277|}
268|adc83b|
269|2f1081|// MARK: - Sidebar with Real File System
270|adc83b|
271|77668e|struct IDESidebarFiles: View {
272|e5f895|    @ObservedObject var editorCore: EditorCore
273|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
274|fe002a|    @Binding var showFolderPicker: Bool
275|6b0e55|    let theme: Theme
276|b4687f|    
277|504e43|    var body: some View {
278|0865e6|        VStack(alignment: .leading, spacing: 0) {
279|f49fd2|            HStack {
280|8f10b4|                Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
281|a02350|                Spacer()
282|124c35|                Button(action: { showFolderPicker = true }) {
283|98d029|                    Image(systemName: "folder.badge.plus").font(.caption)
284|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
285|035054|                Button(action: { editorCore.showFilePicker = true }) {
286|e2bf82|                    Image(systemName: "doc.badge.plus").font(.caption)
287|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
288|eaa303|                if fileNavigator.fileTree != nil {
289|a67875|                    Button(action: { fileNavigator.refreshFileTree() }) {
290|7cfff4|                        Image(systemName: "arrow.clockwise").font(.caption)
291|681233|                    }.foregroundColor(theme.sidebarForeground.opacity(0.7))
292|4e2d32|                }
293|5cbd4e|            }.padding(.horizontal, 12).padding(.vertical, 8)
294|3070d1|            
295|6b85db|            ScrollView {
296|492557|                VStack(alignment: .leading, spacing: 2) {
297|5cce6c|                    if let tree = fileNavigator.fileTree {
298|46c9f4|                        FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
299|540066|                    } else {
300|b9326c|                        DemoFileTree(editorCore: editorCore, theme: theme)
301|c9717a|                    }
302|d407ec|                }.padding(.horizontal, 8)
303|a7dc16|            }
304|ea6339|        }.background(theme.sidebarBackground)
305|27e597|    }
306|b31277|}
307|adc83b|
308|2efb89|struct RealFileTreeView: View {
309|7345b3|    let node: FileTreeNode
310|ded86f|    let level: Int
311|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
312|e5f895|    @ObservedObject var editorCore: EditorCore
313|6b0e55|    let theme: Theme
314|b4687f|    
315|17d62f|    var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
316|b4687f|    
317|504e43|    var body: some View {
318|ea9354|        VStack(alignment: .leading, spacing: 2) {
319|37f526|            HStack(spacing: 4) {
320|a37387|                if node.isDirectory {
321|440597|                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
322|8aec79|                        .font(.caption2).frame(width: 12)
323|0b3717|                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
324|740862|                        .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
325|fdd0e2|                } else {
326|df77cf|                    Spacer().frame(width: 12)
327|4e2d32|                }
328|bf729b|                Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
329|8237e3|                    .font(.caption)
330|a7e98c|                    .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
331|926090|                Text(node.name).font(.system(.caption)).lineLimit(1)
332|985367|                    .foregroundColor(theme.sidebarForeground)
333|a02350|                Spacer()
334|a7dc16|            }
335|f3d9fb|            .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
336|68d57d|            .contentShape(Rectangle())
337|835ded|            .onTapGesture {
338|a37387|                if node.isDirectory {
339|8f26cf|                    fileNavigator.toggleExpanded(path: node.url.path)
340|fdd0e2|                } else {
341|13e765|                    editorCore.openFile(from: node.url)
342|4e2d32|                }
343|a7dc16|            }
344|3070d1|            
345|dd4b6d|            if isExpanded && node.isDirectory {
346|4a6742|                ForEach(node.children) { child in
347|8deaf6|                    RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
348|4e2d32|                }
349|a7dc16|            }
350|5f3077|        }
351|27e597|    }
352|b31277|}
353|adc83b|
354|c7c785|struct DemoFileTree: View {
355|e5f895|    @ObservedObject var editorCore: EditorCore
356|6b0e55|    let theme: Theme
357|b4687f|    
358|504e43|    var body: some View {
359|478d8c|        VStack(alignment: .leading, spacing: 4) {
360|dca3c9|            Text("Open a folder to browse files")
361|916793|                .font(.caption)
362|417420|                .foregroundColor(theme.sidebarForeground.opacity(0.6))
363|a48a8d|                .padding(.vertical, 8)
364|3070d1|            
365|eead9e|            DemoFileRow(name: "Welcome.swift", editorCore: editorCore, theme: theme)
366|cbcd60|            DemoFileRow(name: "example.js", editorCore: editorCore, theme: theme)
367|0f2913|            DemoFileRow(name: "example.py", editorCore: editorCore, theme: theme)
368|c07fb7|            DemoFileRow(name: "package.json", editorCore: editorCore, theme: theme)
369|d67c95|            DemoFileRow(name: "index.html", editorCore: editorCore, theme: theme)
370|822f11|            DemoFileRow(name: "styles.css", editorCore: editorCore, theme: theme)
371|5f3077|        }
372|27e597|    }
373|b31277|}
374|adc83b|
375|ab28f0|struct DemoFileRow: View {
376|a5193b|    let name: String
377|e5f895|    @ObservedObject var editorCore: EditorCore
378|6b0e55|    let theme: Theme
379|b4687f|    
380|504e43|    var body: some View {
381|b120fa|        HStack(spacing: 4) {
382|5a4821|            Spacer().frame(width: 12)
383|5a9b2c|            Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
384|0ffef7|            Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
385|1e6289|            Spacer()
386|5f3077|        }
387|60e15e|        .padding(.vertical, 4)
388|55e29b|        .contentShape(Rectangle())
389|cf12c6|        .onTapGesture {
390|9f9063|            if let tab = editorCore.tabs.first(where: { $0.fileName == name }) {
391|166be5|                editorCore.selectTab(id: tab.id)
392|a7dc16|            }
393|5f3077|        }
394|27e597|    }
395|b31277|}
396|adc83b|
397|f3aab4|// MARK: - Tab Bar
398|adc83b|
399|24d9d9|struct IDETabBar: View {
400|e5f895|    @ObservedObject var editorCore: EditorCore
401|6b0e55|    let theme: Theme
402|b4687f|    
403|504e43|    var body: some View {
404|98ab70|        ScrollView(.horizontal, showsIndicators: false) {
405|3b7550|            HStack(spacing: 0) {
406|7512d8|                ForEach(editorCore.tabs) { tab in
407|4b4bd2|                    IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
408|4e2d32|                }
409|5de7cd|                Button(action: { editorCore.addTab() }) {
410|fd7d74|                    Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
411|4e2d32|                }
412|30b85f|            }.padding(.horizontal, 4)
413|962d70|        }.frame(height: 36).background(theme.tabBarBackground)
414|27e597|    }
415|b31277|}
416|adc83b|
417|68fbe9|struct IDETabItem: View {
418|4dc199|    let tab: Tab
419|055123|    let isSelected: Bool
420|e5f895|    @ObservedObject var editorCore: EditorCore
421|6b0e55|    let theme: Theme
422|b4687f|    
423|504e43|    var body: some View {
424|e1c66d|        HStack(spacing: 6) {
425|29528a|            Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
426|a9dd8d|            Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
427|d555ba|                .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
428|5029ae|            if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
429|6effb3|            Button(action: { editorCore.closeTab(id: tab.id) }) {
430|f4c72a|                Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
431|041ce7|                    .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
432|a7dc16|            }
433|5f3077|        }
434|2da2e9|        .padding(.horizontal, 12).padding(.vertical, 6)
435|116b54|        .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
436|7a9052|        .onTapGesture { editorCore.selectTab(id: tab.id) }
437|27e597|    }
438|b31277|}
439|adc83b|
440|f95ca3|// MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
441|adc83b|
442|a178f9|struct IDEEditorView: View {
443|e5f895|    @ObservedObject var editorCore: EditorCore
444|4dc199|    let tab: Tab
445|6b0e55|    let theme: Theme
446|b4687f|    
447|129112|    /// Feature flag for Runestone editor - uses centralized FeatureFlags
448|952908|    private var useRunestoneEditor: Bool { FeatureFlags.useRunestoneEditor }
449|adc83b|
450|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
451|eba335|    @State private var text: String = ""
452|4f0ac8|    @State private var scrollPosition: Int = 0
453|36da68|    @State private var scrollOffset: CGFloat = 0
454|d473fd|    @State private var totalLines: Int = 1
455|bcf90b|    @State private var visibleLines: Int = 20
456|9cb5e9|    @State private var currentLineNumber: Int = 1
457|cc347a|    @State private var currentColumn: Int = 1
458|eee196|    @State private var cursorIndex: Int = 0
459|f97bd7|    @State private var lineHeight: CGFloat = 20  // Updated dynamically based on font size
460|446eb9|    @State private var requestedCursorIndex: Int? = nil
461|5c2aeb|    @State private var requestedLineSelection: Int? = nil
462|adc83b|
463|3977e1|    @StateObject private var autocomplete = AutocompleteManager()
464|4445ec|    @State private var showAutocomplete = false
465|a9aa54|    @ObservedObject private var foldingManager = CodeFoldingManager.shared
466|f453fc|    @StateObject private var findViewModel = FindViewModel()
467|b4687f|    
468|504e43|    var body: some View {
469|94dd27|        VStack(spacing: 0) {
470|8779dd|            // Find/Replace bar
471|2b2a70|            if editorCore.showSearch {
472|38cbe4|                FindReplaceView(viewModel: findViewModel)
473|b768ed|                    .background(theme.tabBarBackground)
474|a7dc16|            }
475|3070d1|            
476|b97232|            BreadcrumbsView(editorCore: editorCore, tab: tab)
477|3070d1|            
478|ca6f75|            GeometryReader { geometry in
479|e60c16|                ZStack(alignment: .topLeading) {
480|7a5371|                HStack(spacing: 0) {
481|188ac4|                    // Show custom gutter with fold arrows + breakpoints (always, even with Runestone)
482|c938b9|                    // Runestone's built-in line numbers are disabled to avoid duplication
483|8d4059|                    if lineNumbersStyle != "off" {
484|ca5e14|                        LineNumbersWithFolding(
485|a108d1|                            fileId: tab.url?.path ?? tab.fileName,
486|937d74|                            totalLines: totalLines,
487|0f00a6|                            currentLine: currentLineNumber,
488|d6742c|                            scrollOffset: scrollOffset,
489|9f4e9f|                            lineHeight: lineHeight,
490|76e9b6|                            requestedLineSelection: $requestedLineSelection,
491|0d74bf|                            foldingManager: foldingManager,
492|0acd63|                            theme: theme
493|63214b|                        )
494|c15397|                        .frame(width: 60)
495|3a838d|                        .background(theme.sidebarBackground.opacity(0.5))
496|c9717a|                    }
497|dd2193|                    
498|3f9dab|                    // Use Runestone for all files including JSON (has TreeSitter JSON support)
499|df925c|                    if false && tab.fileName.hasSuffix(".json") {
500|4229a0|                        // JSON Tree View disabled - using Runestone editor instead
501|daf992|                        JSONTreeView(data: text.data(using: .utf8) ?? Data())
502|f9d830|                            .frame(maxWidth: .infinity, maxHeight: .infinity)
503|96e3a5|                            .background(theme.editorBackground)
504|540066|                    } else {
505|082ddd|                        // Use Runestone for O(log n) performance, or legacy view as fallback
506|e44d33|                        Group {
507|31b1a0|                            if useRunestoneEditor {
508|40914b|                                RunestoneEditorView(
509|4496ad|                                    text: $text,
510|d36f79|                                    filename: tab.fileName,
511|deb430|                                    scrollOffset: $scrollOffset,
512|2b845b|                                    totalLines: $totalLines,
513|71c5eb|                                    currentLineNumber: $currentLineNumber,
514|872d17|                                    currentColumn: $currentColumn,
515|927813|                                    cursorIndex: $cursorIndex,
516|397368|                                    isActive: true,
517|b41e3e|                                    fontSize: editorCore.editorFontSize,
518|f39601|                                    onAcceptAutocomplete: {
519|35fa15|                                        guard showAutocomplete else { return false }
520|028ab7|                                        var tempText = text
521|4f6f56|                                        var tempCursor = cursorIndex
522|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
523|28278a|                                        if tempText != text {
524|1a390a|                                            text = tempText
525|9a3612|                                            cursorIndex = tempCursor
526|55a703|                                            requestedCursorIndex = tempCursor
527|46924a|                                            showAutocomplete = false
528|e18645|                                            return true
529|eed1d8|                                        }
530|9818dc|                                        return false
531|3cc64b|                                    },
532|7ed733|                                    onDismissAutocomplete: {
533|35fa15|                                        guard showAutocomplete else { return false }
534|fc38c2|                                        autocomplete.hideSuggestions()
535|579f59|                                        showAutocomplete = false
536|c09eb1|                                        return true
537|8ab74d|                                    }
538|58a90d|                                )
539|240f50|                            } else {
540|e97ddb|                                // Legacy SyntaxHighlightingTextView (fallback)
541|27eb3b|                                SyntaxHighlightingTextView(
542|4496ad|                                    text: $text,
543|d36f79|                                    filename: tab.fileName,
544|44ffa0|                                    scrollPosition: $scrollPosition,
545|deb430|                                    scrollOffset: $scrollOffset,
546|2b845b|                                    totalLines: $totalLines,
547|a9b405|                                    visibleLines: $visibleLines,
548|71c5eb|                                    currentLineNumber: $currentLineNumber,
549|872d17|                                    currentColumn: $currentColumn,
550|927813|                                    cursorIndex: $cursorIndex,
551|31e938|                                    lineHeight: $lineHeight,
552|397368|                                    isActive: true,
553|b41e3e|                                    fontSize: editorCore.editorFontSize,
554|193919|                                    requestedLineSelection: $requestedLineSelection,
555|70abf8|                                    requestedCursorIndex: $requestedCursorIndex,
556|f39601|                                    onAcceptAutocomplete: {
557|35fa15|                                        guard showAutocomplete else { return false }
558|028ab7|                                        var tempText = text
559|4f6f56|                                        var tempCursor = cursorIndex
560|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
561|28278a|                                        if tempText != text {
562|1a390a|                                            text = tempText
563|9a3612|                                            cursorIndex = tempCursor
564|55a703|                                            requestedCursorIndex = tempCursor
565|46924a|                                            showAutocomplete = false
566|e18645|                                            return true
567|eed1d8|                                        }
568|9818dc|                                        return false
569|3cc64b|                                    },
570|7ed733|                                    onDismissAutocomplete: {
571|35fa15|                                        guard showAutocomplete else { return false }
572|fc38c2|                                        autocomplete.hideSuggestions()
573|579f59|                                        showAutocomplete = false
574|c09eb1|                                        return true
575|8ab74d|                                    }
576|58a90d|                                )
577|89d40a|                            }
578|392b35|                        }
579|23a7d6|                        .onChange(of: text) { newValue in
580|c2cbfa|                            editorCore.updateActiveTabContent(newValue)
581|ca5c5e|                            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
582|2d6cfb|                            autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
583|5db623|                            showAutocomplete = autocomplete.showSuggestions
584|f1e408|                            foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path ?? tab.fileName)
585|392b35|                        }
586|ae1be2|                        .onChange(of: cursorIndex) { newCursor in
587|017a4d|                            autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
588|5db623|                            showAutocomplete = autocomplete.showSuggestions
589|392b35|                        }
590|c9717a|                    }
591|dd2193|                    
592|0fbe94|                    if !tab.fileName.hasSuffix(".json") {
593|d0a712|                        MinimapView(
594|234a10|                            content: text,
595|d6742c|                            scrollOffset: scrollOffset,
596|9a8bd2|                            scrollViewHeight: geometry.size.height,
597|29b4a2|                            totalContentHeight: CGFloat(totalLines) * lineHeight,
598|83e3c8|                            onScrollRequested: { newOffset in
599|c2e825|                                // Minimap requested scroll - update editor position
600|d09b41|                                scrollOffset = newOffset
601|af41de|                                // Convert back from pixels to line number
602|6ad0f0|                                let newLine = Int(newOffset / max(lineHeight, 1))
603|ec5b45|                                scrollPosition = max(0, min(newLine, totalLines - 1))
604|89d40a|                            }
605|63214b|                        )
606|abeec0|                        .frame(width: 80)
607|c9717a|                    }
608|4e2d32|                }
609|3bc2db|                .background(theme.editorBackground)
610|adc83b|
611|cf06bf|                // Sticky Header Overlay (FEAT-040)
612|d5af46|                StickyHeaderView(
613|c24fd5|                    text: text,
614|f49254|                    currentLine: scrollPosition,
615|f7b7a6|                    theme: theme,
616|8e60a5|                    lineHeight: lineHeight,
617|9628b3|                    onSelect: { line in
618|df068a|                        requestedLineSelection = line
619|c9717a|                    }
620|6f642e|                )
621|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
622|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
623|adc83b|
624|0f82df|                // Inlay Hints Overlay (type hints, parameter names)
625|a8bcb0|                InlayHintsOverlay(
626|0fb212|                    code: text,
627|5f8f93|                    language: tab.language,
628|23acb0|                    scrollPosition: scrollPosition,
629|8e60a5|                    lineHeight: lineHeight,
630|0e3ffc|                    fontSize: editorCore.editorFontSize,
631|a63927|                    gutterWidth: (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0,
632|088baa|                    rightReservedWidth: tab.fileName.hasSuffix(".json") ? 0 : 80
633|6f642e|                )
634|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
635|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
636|8eef2d|                if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
637|baeb3a|                    AutocompletePopup(
638|83a4b0|                        suggestions: autocomplete.suggestionItems,
639|53da2f|                        selectedIndex: autocomplete.selectedIndex,
640|5db55c|                        theme: theme
641|82606a|                    ) { index in
642|3a2861|                        autocomplete.selectedIndex = index
643|9c12a8|                        var tempText = text
644|f02eb3|                        var tempCursor = cursorIndex
645|7fdc0e|                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
646|326231|                        if tempText != text {
647|d7f8a5|                            text = tempText
648|34aa29|                            cursorIndex = tempCursor
649|d3d820|                            requestedCursorIndex = tempCursor
650|392b35|                        }
651|2411d0|                        showAutocomplete = false
652|c9717a|                    }
653|58a34b|                    .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
654|4e2d32|                }
655|a7dc16|            }
656|5f3077|        }
657|5f3077|        }
658|2bd24e|        .onAppear {
659|ba85f8|            text = tab.content
660|92d865|            foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
661|5f3077|        }
662|9d97c0|        .onChange(of: tab.id) { _ in
663|ba85f8|            text = tab.content
664|92d865|            foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
665|5f3077|        }
666|d3345e|        .onChange(of: currentLineNumber) { line in
667|3384f8|            editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
668|5f3077|        }
669|588fd8|        .onChange(of: currentColumn) { col in
670|16524d|            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
671|5f3077|        }
672|2bd24e|        .onAppear {
673|c916b3|            findViewModel.editorCore = editorCore
674|5f3077|        }
675|27e597|    }
676|b4687f|    
677|a19e38|    // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
678|b31277|}
679|adc83b|
680|dcdcdb|// MARK: - Line Numbers with Folding
681|adc83b|
682|c8dd5c|struct LineNumbersWithFolding: View {
683|5799da|    let fileId: String
684|cdda83|    let totalLines: Int
685|c75d8a|    let currentLine: Int
686|5b2177|    let scrollOffset: CGFloat
687|96ac71|    let lineHeight: CGFloat
688|86829b|    @Binding var requestedLineSelection: Int?
689|ec5c86|    @ObservedObject var foldingManager: CodeFoldingManager
690|c97289|    @ObservedObject private var debugManager = DebugManager.shared
691|6b0e55|    let theme: Theme
692|adc83b|
693|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
694|adc83b|
695|504e43|    var body: some View {
696|ca170c|        ScrollView(showsIndicators: false) {
697|829de3|            VStack(alignment: .trailing, spacing: 0) {
698|2e20ec|                // Match UITextView.textContainerInset.top (see SyntaxHighlightingTextView.swift)
699|551416|                // so line numbers stay vertically aligned with the first line of text.
700|227120|                ForEach(0..<totalLines, id: \.self) { lineIndex in
701|71bf03|                    if !foldingManager.isLineFolded(line: lineIndex) {
702|d3392c|                        HStack(spacing: 2) {
703|8eed40|                            Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
704|5f750e|                                Circle()
705|4cf57e|                                    .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
706|5ded70|                                    .overlay(
707|6304cf|                                        Circle()
708|f93b39|                                            .stroke(Color.red.opacity(0.6), lineWidth: 1)
709|fe99c4|                                            .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
710|bf17fb|                                    )
711|d07523|                                    .frame(width: 10, height: 10)
712|da49b4|                                    .padding(.leading, 2)
713|89d40a|                            }
714|917e04|                            .buttonStyle(.plain)
715|746328|                            .frame(width: 14, height: lineHeight)
716|adc83b|
717|75451e|                            if foldingManager.isFoldable(line: lineIndex) {
718|6ae979|                                Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
719|8689bb|                                    Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
720|e50a51|                                        .font(.system(size: 8))
721|856d81|                                        .foregroundColor(theme.lineNumber)
722|f83e05|                                }
723|31bef9|                                .buttonStyle(.plain)
724|23311c|                                .frame(width: 14, height: lineHeight)
725|240f50|                            } else {
726|b18c2d|                                Spacer().frame(width: 14)
727|89d40a|                            }
728|adc83b|
729|6798e8|                            Text(displayText(for: lineIndex))
730|f57164|                                .font(.system(size: 12, design: .monospaced))
731|525023|                                .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
732|5d10bc|                                .frame(height: lineHeight)
733|5cb7d4|                                .contentShape(Rectangle())
734|d56a2c|                                .onTapGesture {
735|c0cc45|                                    // FEAT-041: click line number selects entire line
736|6eaf3d|                                    requestedLineSelection = lineIndex
737|f83e05|                                }
738|392b35|                        }
739|729aac|                        .frame(maxWidth: .infinity, alignment: .trailing)
740|539a79|                        .padding(.trailing, 4)
741|c9717a|                    }
742|4e2d32|                }
743|a7dc16|            }
744|5f0534|            .padding(.top, 8)
745|873abc|            .offset(y: -scrollOffset)
746|5f3077|        }
747|c059d6|        .scrollDisabled(true)
748|27e597|    }
749|adc83b|
750|46d3db|    private func displayText(for lineIndex: Int) -> String {
751|5d97cf|        switch lineNumbersStyle {
752|a6eb36|        case "relative":
753|e1ceac|            // VS Code-style: current line shows absolute, others show relative distance
754|b0622f|            let lineNumber = lineIndex + 1
755|44bb33|            if lineNumber == currentLine { return "\(lineNumber)" }
756|5e67df|            return "\(abs(lineNumber - currentLine))"
757|adc83b|
758|5040ac|        case "interval":
759|b0622f|            let lineNumber = lineIndex + 1
760|bc3fe3|            return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
761|adc83b|
762|520b7d|        default:
763|3880c0|            return "\(lineIndex + 1)"
764|5f3077|        }
765|27e597|    }
766|b31277|}
767|adc83b|
768|e3bdd2|// MARK: - Autocomplete Popup
769|adc83b|
770|b1d20a|struct AutocompletePopup: View {
771|5eb9d3|    let suggestions: [AutocompleteSuggestion]
772|79c1fc|    let selectedIndex: Int
773|6b0e55|    let theme: Theme
774|6f35cf|    let onSelectIndex: (Int) -> Void
775|b4687f|    
776|504e43|    var body: some View {
777|0865e6|        VStack(alignment: .leading, spacing: 0) {
778|a954be|            ForEach(suggestions.indices, id: \.self) { index in
779|ad513b|                let s = suggestions[index]
780|dbadc1|                HStack(spacing: 6) {
781|fcd45a|                    Image(systemName: icon(for: s.kind))
782|cdb0af|                        .font(.caption)
783|2e9202|                        .foregroundColor(color(for: s.kind))
784|288999|                    VStack(alignment: .leading, spacing: 1) {
785|3d1271|                        Text(s.displayText)
786|09bbe1|                            .font(.system(size: 12, design: .monospaced))
787|239e62|                            .foregroundColor(theme.editorForeground)
788|71c2b3|                        if s.insertText != s.displayText && !s.insertText.isEmpty {
789|53d416|                            Text(s.insertText)
790|87ab4e|                                .font(.system(size: 10, design: .monospaced))
791|32bc5b|                                .foregroundColor(theme.editorForeground.opacity(0.55))
792|a9b5f4|                                .lineLimit(1)
793|392b35|                        }
794|c9717a|                    }
795|dcd0bf|                    Spacer()
796|4e2d32|                }
797|41847e|                .padding(.horizontal, 8).padding(.vertical, 6)
798|e72d30|                .background(index == selectedIndex ? theme.selection : Color.clear)
799|1e8a31|                .contentShape(Rectangle())
800|eec06d|                .onTapGesture { onSelectIndex(index) }
801|a7dc16|            }
802|5f3077|        }
803|5260c9|        .frame(width: 260)
804|04ec17|        .background(theme.editorBackground)
805|097147|        .cornerRadius(6)
806|f64ce1|        .shadow(radius: 8)
807|27e597|    }
808|b4687f|    
809|ccd198|    private func icon(for kind: AutocompleteSuggestionKind) -> String {
810|01fe0f|        switch kind {
811|62a12d|        case .keyword: return "key.fill"
812|710dbd|        case .symbol: return "cube.fill"
813|d0a8ab|        case .stdlib: return "curlybraces"
814|c3ed81|        case .member: return "arrow.right.circle.fill"
815|5f3077|        }
816|27e597|    }
817|b4687f|    
818|126b1f|    private func color(for kind: AutocompleteSuggestionKind) -> Color {
819|01fe0f|        switch kind {
820|a51b30|        case .keyword: return .purple
821|8740a1|        case .symbol: return .blue
822|628567|        case .stdlib: return .orange
823|b8e5e8|        case .member: return .green
824|5f3077|        }
825|27e597|    }
826|b31277|}
827|adc83b|
828|4409de|// MARK: - Welcome View
829|adc83b|
830|35ff8c|struct IDEWelcomeView: View {
831|e5f895|    @ObservedObject var editorCore: EditorCore
832|fe002a|    @Binding var showFolderPicker: Bool
833|6b0e55|    let theme: Theme
834|b4687f|    
835|504e43|    var body: some View {
836|c906ca|        VStack(spacing: 24) {
837|00a225|            Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 80)).foregroundColor(theme.editorForeground.opacity(0.3))
838|b3ccb7|            Text("VS Code for iPadOS").font(.largeTitle).fontWeight(.bold).foregroundColor(theme.editorForeground)
839|5c2d12|            VStack(alignment: .leading, spacing: 12) {
840|49df13|                WelcomeBtn(icon: "doc.badge.plus", title: "New File", shortcut: "⌘N", theme: theme) { editorCore.addTab() }
841|b0fcfd|                WelcomeBtn(icon: "folder", title: "Open Folder", shortcut: "⌘⇧O", theme: theme) { showFolderPicker = true }
842|2bad60|                WelcomeBtn(icon: "doc", title: "Open File", shortcut: "⌘O", theme: theme) { editorCore.showFilePicker = true }
843|502f56|                WelcomeBtn(icon: "terminal", title: "Command Palette", shortcut: "⌘⇧P", theme: theme) { editorCore.showCommandPalette = true }
844|a7dc16|            }
845|139d2b|        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.editorBackground)
846|27e597|    }
847|b31277|}
848|adc83b|
849|4b4130|struct WelcomeBtn: View {
850|f0e87a|    let icon: String
851|399f36|    let title: String
852|14874c|    let shortcut: String
853|6b0e55|    let theme: Theme
854|59027a|    let action: () -> Void
855|b4687f|    
856|504e43|    var body: some View {
857|6f04d8|        Button(action: action) {
858|f49fd2|            HStack {
859|f2b865|                Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
860|d34e42|                Text(title).foregroundColor(theme.editorForeground)
861|a02350|                Spacer()
862|0f9490|                Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
863|a7dc16|            }
864|a09f6b|            .padding().frame(width: 280)
865|cef0ad|            .background(theme.sidebarBackground)
866|b18c2b|            .cornerRadius(8)
867|9e9bdf|        }.buttonStyle(.plain)
868|27e597|    }
869|b31277|}
870|adc83b|
871|db0271|// MARK: - Command Palette
872|adc83b|
873|e71bec|struct IDECommandPalette: View {
874|e5f895|    @ObservedObject var editorCore: EditorCore
875|3bd3a7|    @Binding var showSettings: Bool
876|fe5153|    @Binding var showTerminal: Bool
877|d901da|    @State private var searchText = ""
878|b4687f|    
879|504e43|    var body: some View {
880|94dd27|        VStack(spacing: 0) {
881|f49fd2|            HStack {
882|41b09a|                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
883|259764|                TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
884|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))
885|e744dc|            Divider()
886|6b85db|            ScrollView {
887|9ad863|                VStack(spacing: 0) {
888|bd267a|                    CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
889|48369f|                    CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
890|1997cb|                    CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
891|e10354|                    CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
892|684ba0|                    CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
893|79e8a7|                    CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
894|92fdf3|                    CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
895|e6f867|                    CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
896|b7baf1|                }.padding(.vertical, 8)
897|a7dc16|            }
898|338a7e|        }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
899|27e597|    }
900|b31277|}
901|adc83b|
902|b6a6d7|struct CommandRow: View {
903|e97b0d|    let icon: String; let name: String; let shortcut: String; let action: () -> Void
904|504e43|    var body: some View {
905|6f04d8|        Button(action: action) {
906|f49fd2|            HStack {
907|c4580d|                Image(systemName: icon).foregroundColor(.accentColor).frame(width: 24)
908|ade206|                Text(name).foregroundColor(.primary)
909|a02350|                Spacer()
910|512c27|                Text(shortcut).font(.caption).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 4).background(Color(UIColor.tertiarySystemFill)).cornerRadius(4)
911|dfa64f|            }.padding(.horizontal).padding(.vertical, 12).contentShape(Rectangle())
912|9e9bdf|        }.buttonStyle(.plain)
913|27e597|    }
914|b31277|}
915|adc83b|
916|6b1f13|// MARK: - Quick Open
917|adc83b|
918|7bfe0e|struct IDEQuickOpen: View {
919|e5f895|    @ObservedObject var editorCore: EditorCore
920|d901da|    @State private var searchText = ""
921|b4687f|    
922|504e43|    var body: some View {
923|94dd27|        VStack(spacing: 0) {
924|f49fd2|            HStack {
925|fa8104|                Image(systemName: "magnifyingglass").foregroundColor(.gray)
926|a496c8|                TextField("Search files...", text: $searchText).textFieldStyle(.plain)
927|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))
928|e744dc|            Divider()
929|6b85db|            ScrollView {
930|8ee2f5|                VStack(alignment: .leading, spacing: 0) {
931|3625c1|                    ForEach(editorCore.tabs) { tab in
932|88ee6a|                        QuickOpenRow(name: tab.fileName, path: "") {
933|4f316a|                            editorCore.selectTab(id: tab.id)
934|90bf2b|                            editorCore.showQuickOpen = false
935|392b35|                        }
936|c9717a|                    }
937|4e2d32|                }
938|1964e5|            }.frame(maxHeight: 350)
939|0014d4|        }.frame(width: 500).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
940|27e597|    }
941|b31277|}
942|adc83b|
943|767562|struct QuickOpenRow: View {
944|ee9c0b|    let name: String; let path: String; let action: () -> Void
945|504e43|    var body: some View {
946|6f04d8|        Button(action: action) {
947|f49fd2|            HStack {
948|0b1ac7|                Image(systemName: fileIcon(for: name)).foregroundColor(fileColor(for: name)).frame(width: 20)
949|23f981|                VStack(alignment: .leading, spacing: 2) { Text(name).font(.system(size: 14)); Text(path + name).font(.system(size: 11)).foregroundColor(.secondary) }
950|a02350|                Spacer()
951|38ff47|            }.padding(.horizontal).padding(.vertical, 8).contentShape(Rectangle())
952|9e9bdf|        }.buttonStyle(.plain)
953|27e597|    }
954|b31277|}
955|adc83b|
956|2d88cf|// MARK: - AI Assistant
957|adc83b|
958|5f57bf|struct IDEAIAssistant: View {
959|e5f895|    @ObservedObject var editorCore: EditorCore
960|6b0e55|    let theme: Theme
961|2855b6|    @State private var userInput = ""
962|9cbba7|    @State private var messages: [(id: UUID, role: String, content: String)] = [(UUID(), "assistant", "Hello! I'm your AI coding assistant. How can I help?")]
963|b4687f|    
964|504e43|    var body: some View {
965|94dd27|        VStack(spacing: 0) {
966|f49fd2|            HStack {
967|35e129|                Image(systemName: "brain").foregroundColor(.blue)
968|b6566c|                Text("AI Assistant").font(.headline).foregroundColor(theme.editorForeground)
969|a02350|                Spacer()
970|cc1153|                Button(action: { editorCore.showAIAssistant = false }) { Image(systemName: "xmark.circle.fill").foregroundColor(theme.editorForeground.opacity(0.5)) }
971|0facd0|            }.padding().background(theme.sidebarBackground)
972|3070d1|            
973|6b85db|            ScrollView {
974|df82e6|                LazyVStack(alignment: .leading, spacing: 12) {
975|a5721a|                    ForEach(messages, id: \.id) { msg in
976|679877|                        HStack {
977|a85384|                            if msg.role == "user" { Spacer(minLength: 60) }
978|8b1fb9|                            Text(msg.content).padding(12).background(RoundedRectangle(cornerRadius: 12).fill(msg.role == "user" ? Color.blue : theme.sidebarBackground)).foregroundColor(msg.role == "user" ? .white : theme.editorForeground)
979|b74ebb|                            if msg.role == "assistant" { Spacer(minLength: 60) }
980|392b35|                        }
981|c9717a|                    }
982|c5f15e|                }.padding()
983|744c4f|            }.background(theme.editorBackground)
984|3070d1|            
985|8574de|            HStack(spacing: 12) {
986|0e3711|                TextField("Ask about your code...", text: $userInput).textFieldStyle(.roundedBorder)
987|753afe|                Button(action: { sendMessage() }) { Image(systemName: "paperplane.fill").foregroundColor(userInput.isEmpty ? .gray : .blue) }.disabled(userInput.isEmpty)
988|0facd0|            }.padding().background(theme.sidebarBackground)
989|a8790d|        }.background(theme.editorBackground).cornerRadius(12).shadow(radius: 20)
990|27e597|    }
991|b4687f|    
992|beb964|    func sendMessage() {
993|29cfe7|        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
994|8a803f|        messages.append((UUID(), "user", userInput))
995|eac017|        let input = userInput
996|2c52ee|        userInput = ""
997|145a34|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
998|c7ba20|            messages.append((UUID(), "assistant", "I can help with '\(input)'! What specifically would you like to know?"))
999|5f3077|        }
1000|27e597|    }
1001|b31277|}
1002|adc83b|
1003|31bfc1|// MARK: - Status Bar
1004|adc83b|
1005|adc83b|
1006|adc83b|
1007|f4a6ee|// MARK: - Folder Picker
1008|adc83b|
1009|4842b2|struct IDEFolderPicker: UIViewControllerRepresentable {
1010|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
1011|10370b|    var onPick: ((URL) -> Void)?
1012|b4687f|    
1013|fc2de0|    init(fileNavigator: FileSystemNavigator, onPick: ((URL) -> Void)? = nil) {
1014|237a4e|        self.fileNavigator = fileNavigator
1015|3192b9|        self.onPick = onPick
1016|27e597|    }
1017|b4687f|    
1018|a4c191|    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
1019|352547|        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
1020|325e82|        picker.delegate = context.coordinator
1021|993f50|        return picker
1022|27e597|    }
1023|b4687f|    
1024|bd012f|    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
1025|b4687f|    
1026|7da3c4|    func makeCoordinator() -> Coordinator { Coordinator(self) }
1027|b4687f|    
1028|9c0536|    class Coordinator: NSObject, UIDocumentPickerDelegate {
1029|e78b69|        let parent: IDEFolderPicker
1030|11a437|        init(_ parent: IDEFolderPicker) { self.parent = parent }
1031|d6ed84|        
1032|da3421|        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
1033|51c500|            if let url = urls.first {
1034|94998b|                _ = url.startAccessingSecurityScopedResource()
1035|24e3be|                if let onPick = parent.onPick {
1036|71fb5b|                    onPick(url)
1037|fdd0e2|                } else {
1038|866512|                    // Default behavior if no custom handler
1039|7ec9fd|                    parent.fileNavigator.loadFileTree(at: url)
1040|3d4547|                    Task { @MainActor in
1041|e3472e|                        LaunchManager.shared.setWorkspaceRoot(url)
1042|14c08d|                        GitManager.shared.setWorkingDirectory(url)
1043|c9717a|                    }
1044|4e2d32|                }
1045|a7dc16|            }
1046|5f3077|        }
1047|27e597|    }
1048|b31277|}
1049|adc83b|
1050|ba3cff|// MARK: - Document Picker
1051|adc83b|
1052|f67fab|struct IDEDocumentPicker: UIViewControllerRepresentable {
1053|e5f895|    @ObservedObject var editorCore: EditorCore
1054|b4687f|    
1055|a4c191|    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
1056|99746f|        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .sourceCode, .json, .plainText, .data])
1057|1abf38|        picker.allowsMultipleSelection = true
1058|325e82|        picker.delegate = context.coordinator
1059|993f50|        return picker
1060|27e597|    }
1061|b4687f|    
1062|bd012f|    func updateUIViewC

... [output truncated: 192 more chars]




⛔ ABORTED by user
