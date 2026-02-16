# Agent: scout-save-functionality
**Status:** done
**Tokens:** 1,330
**Cost:** $0.0000
**Time:** 2026-02-16T08:55:07.054Z

## Task
Read VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift and find the saveActiveTab() function. Report: 1) What does it do? 2) Does it actually write to disk? 3) What are the failure points? Also search for 'SaveFile' notification handler in ContentView.swift.

## Response
I'll investigate the `saveActiveTab()` function and the SaveFile notification handler.



Now let me search for the SaveFile notification handler in ContentView.swift:



---

## 🔧 TOOL RESULTS

[search]
Error searching: Extension 'danielswagg.outlier-chat' CANNOT use API proposal: findTextInFiles.
Its package.json#enabledApiProposals-property declares: [] but NOT findTextInFiles.
 The missing proposal MUST be added and you must start in extension development mode or use the following command line switch: --enable-proposed-api danielswagg.outlier-chat


Let me read ContentView.swift directly:



---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 6d210bc6de11
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 1-1151 of 1151)
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
110|e49551|        .onChange(of: editorCore.showFilePicker) { show in showingDocumentPicker = show }
111|d712a4|        .onChange(of: editorCore.activeTab?.fileName) { newFileName in
112|b402b3|            updateWindowTitle()
113|5f3077|        }
114|4fa530|        .onChange(of: editorCore.tabs.count) { _ in
115|b402b3|            updateWindowTitle()
116|5f3077|        }
117|9fb603|        .onChange(of: editorCore.activeTabId) { _ in
118|b402b3|            updateWindowTitle()
119|5f3077|        }
120|e16410|        .onChange(of: editorCore.activeTab?.isUnsaved) { _ in
121|b402b3|            updateWindowTitle()
122|5f3077|        }
123|2bd24e|        .onAppear {
124|05c407|            // Wire up EditorCore -> FileSystemNavigator so save operations can route through it.
125|d410a3|            editorCore.fileNavigator = fileNavigator
126|b402b3|            updateWindowTitle()
127|5f3077|        }
128|be2cfe|        // MARK: - Notification Handlers for Menu Keyboard Shortcuts
129|5f1d44|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowCommandPalette"))) { _ in
130|e74633|            editorCore.showCommandPalette = true
131|5f3077|        }
132|dcdcf8|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleTerminal"))) { _ in
133|9d7767|            showTerminal.toggle()
134|5f3077|        }
135|8c8974|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleSidebar"))) { _ in
136|53cad1|            editorCore.toggleSidebar()
137|5f3077|        }
138|f012ad|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowQuickOpen"))) { _ in
139|386b9a|            editorCore.showQuickOpen = true
140|5f3077|        }
141|71e497|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToSymbol"))) { _ in
142|e57e74|            editorCore.showGoToSymbol = true
143|5f3077|        }
144|61fe23|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToLine"))) { _ in
145|8cc4b6|            editorCore.showGoToLine = true
146|5f3077|        }
147|7f8a05|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAIAssistant"))) { _ in
148|0a68c1|            editorCore.showAIAssistant = true
149|5f3077|        }
150|809dfc|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewFile"))) { _ in
151|b60db2|            editorCore.addTab()
152|5f3077|        }
153|8d2162|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveFile"))) { _ in
154|07f047|            editorCore.saveActiveTab()
155|5f3077|        }
156|d2a947|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CloseTab"))) { _ in
157|c7a65d|            if let id = editorCore.activeTabId { editorCore.closeTab(id: id) }
158|5f3077|        }
159|a9ccd0|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowFind"))) { _ in
160|72e173|            editorCore.showSearch = true
161|5f3077|        }
162|c69ebf|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ZoomIn"))) { _ in
163|224c97|            editorCore.zoomIn()
164|5f3077|        }
165|7ff5a6|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ZoomOut"))) { _ in
166|18c95d|            editorCore.zoomOut()
167|5f3077|        }
168|fb4855|        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RunWithoutDebugging"))) { _ in
169|7ff579|            // Execute the current file using JSRunner for .js files
170|71e6ee|            if let activeTab = editorCore.activeTab {
171|a60731|                CodeExecutionService.shared.executeCurrentFile(
172|6332f1|                    fileName: activeTab.fileName,
173|d26039|                    content: activeTab.content
174|6f642e|                )
175|e325ce|                // Show the terminal/panel and switch to Output tab so user can see output
176|f34303|                showTerminal = true
177|fc89bb|                NotificationCenter.default.post(name: NSNotification.Name("SwitchToOutputPanel"), object: nil)
178|a7dc16|            }
179|5f3077|        }
180|4a37b7|        .environmentObject(themeManager)
181|e3bdc6|        .environmentObject(editorCore)
182|27e597|    }
183|b4687f|    
184|231605|    private func finishOpeningWorkspace(_ url: URL) {
185|6dcdb7|        fileNavigator.loadFileTree(at: url)
186|d79336|        Task { @MainActor in
187|99e24e|            LaunchManager.shared.setWorkspaceRoot(url)
188|eccbe2|            GitManager.shared.setWorkingDirectory(url)
189|5f3077|        }
190|27e597|    }
191|b4687f|    
192|65a033|    private func updateWindowTitle() {
193|53ad0a|        if let activeTab = editorCore.activeTab {
194|ba8861|            let fileName = activeTab.fileName
195|b072a0|            let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
196|741609|            windowTitle = "\(unsavedIndicator)\(fileName) - VS Code"
197|59ea7f|        } else if !editorCore.tabs.isEmpty {
198|fa7eae|            windowTitle = "VS Code"
199|b31999|        } else {
200|6c3506|            windowTitle = "Welcome - VS Code"
201|5f3077|        }
202|d6ed84|        
203|c675c5|        // Notify the app of the title change
204|63edcc|        NotificationCenter.default.post(
205|9251fc|            name: NSNotification.Name("WindowTitleDidChange"),
206|33f159|            object: nil,
207|332f22|            userInfo: ["title": windowTitle]
208|3143a4|        )
209|27e597|    }
210|b4687f|    
211|ab06c2|    @ViewBuilder
212|0bbc6d|    private var sidebarContent: some View {
213|34711c|        switch selectedSidebarTab {
214|ab83f1|        case 0:
215|161f7c|            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
216|032375|        case 1:
217|19e3bd|            SidebarSearchView(theme: theme)
218|12d44a|        case 2:
219|7fc3ae|            GitView()
220|1a2232|        case 3:
221|7116ef|            DebugView()
222|520b7d|        default:
223|161f7c|            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
224|5f3077|        }
225|27e597|    }
226|b31277|}
227|adc83b|
228|6fd553|// MARK: - Activity Bar
229|adc83b|
230|adc83b|
231|adc83b|
232|4a910a|struct BarButton: View {
233|f0e87a|    let icon: String
234|055123|    let isSelected: Bool
235|6b0e55|    let theme: Theme
236|59027a|    let action: () -> Void
237|b4687f|    
238|504e43|    var body: some View {
239|6f04d8|        Button(action: action) {
240|ed6617|            Image(systemName: icon)
241|13a7f6|                .font(.system(size: 22))
242|557f46|                .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
243|c81e69|                .frame(width: 48, height: 48)
244|5f3077|        }
245|27e597|    }
246|b31277|}
247|adc83b|
248|2f1081|// MARK: - Sidebar with Real File System
249|adc83b|
250|77668e|struct IDESidebarFiles: View {
251|e5f895|    @ObservedObject var editorCore: EditorCore
252|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
253|fe002a|    @Binding var showFolderPicker: Bool
254|6b0e55|    let theme: Theme
255|b4687f|    
256|504e43|    var body: some View {
257|0865e6|        VStack(alignment: .leading, spacing: 0) {
258|f49fd2|            HStack {
259|8f10b4|                Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
260|a02350|                Spacer()
261|124c35|                Button(action: { showFolderPicker = true }) {
262|98d029|                    Image(systemName: "folder.badge.plus").font(.caption)
263|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
264|035054|                Button(action: { editorCore.showFilePicker = true }) {
265|e2bf82|                    Image(systemName: "doc.badge.plus").font(.caption)
266|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
267|eaa303|                if fileNavigator.fileTree != nil {
268|a67875|                    Button(action: { fileNavigator.refreshFileTree() }) {
269|7cfff4|                        Image(systemName: "arrow.clockwise").font(.caption)
270|681233|                    }.foregroundColor(theme.sidebarForeground.opacity(0.7))
271|4e2d32|                }
272|5cbd4e|            }.padding(.horizontal, 12).padding(.vertical, 8)
273|3070d1|            
274|6b85db|            ScrollView {
275|492557|                VStack(alignment: .leading, spacing: 2) {
276|5cce6c|                    if let tree = fileNavigator.fileTree {
277|46c9f4|                        FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
278|540066|                    } else {
279|b9326c|                        DemoFileTree(editorCore: editorCore, theme: theme)
280|c9717a|                    }
281|d407ec|                }.padding(.horizontal, 8)
282|a7dc16|            }
283|ea6339|        }.background(theme.sidebarBackground)
284|27e597|    }
285|b31277|}
286|adc83b|
287|2efb89|struct RealFileTreeView: View {
288|7345b3|    let node: FileTreeNode
289|ded86f|    let level: Int
290|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
291|e5f895|    @ObservedObject var editorCore: EditorCore
292|6b0e55|    let theme: Theme
293|b4687f|    
294|17d62f|    var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
295|b4687f|    
296|504e43|    var body: some View {
297|ea9354|        VStack(alignment: .leading, spacing: 2) {
298|37f526|            HStack(spacing: 4) {
299|a37387|                if node.isDirectory {
300|440597|                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
301|8aec79|                        .font(.caption2).frame(width: 12)
302|0b3717|                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
303|740862|                        .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
304|fdd0e2|                } else {
305|df77cf|                    Spacer().frame(width: 12)
306|4e2d32|                }
307|bf729b|                Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
308|8237e3|                    .font(.caption)
309|a7e98c|                    .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
310|926090|                Text(node.name).font(.system(.caption)).lineLimit(1)
311|985367|                    .foregroundColor(theme.sidebarForeground)
312|a02350|                Spacer()
313|a7dc16|            }
314|f3d9fb|            .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
315|68d57d|            .contentShape(Rectangle())
316|835ded|            .onTapGesture {
317|a37387|                if node.isDirectory {
318|8f26cf|                    fileNavigator.toggleExpanded(path: node.url.path)
319|fdd0e2|                } else {
320|13e765|                    editorCore.openFile(from: node.url)
321|4e2d32|                }
322|a7dc16|            }
323|3070d1|            
324|dd4b6d|            if isExpanded && node.isDirectory {
325|4a6742|                ForEach(node.children) { child in
326|8deaf6|                    RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
327|4e2d32|                }
328|a7dc16|            }
329|5f3077|        }
330|27e597|    }
331|b31277|}
332|adc83b|
333|c7c785|struct DemoFileTree: View {
334|e5f895|    @ObservedObject var editorCore: EditorCore
335|6b0e55|    let theme: Theme
336|b4687f|    
337|504e43|    var body: some View {
338|478d8c|        VStack(alignment: .leading, spacing: 4) {
339|dca3c9|            Text("Open a folder to browse files")
340|916793|                .font(.caption)
341|417420|                .foregroundColor(theme.sidebarForeground.opacity(0.6))
342|a48a8d|                .padding(.vertical, 8)
343|3070d1|            
344|eead9e|            DemoFileRow(name: "Welcome.swift", editorCore: editorCore, theme: theme)
345|cbcd60|            DemoFileRow(name: "example.js", editorCore: editorCore, theme: theme)
346|0f2913|            DemoFileRow(name: "example.py", editorCore: editorCore, theme: theme)
347|c07fb7|            DemoFileRow(name: "package.json", editorCore: editorCore, theme: theme)
348|d67c95|            DemoFileRow(name: "index.html", editorCore: editorCore, theme: theme)
349|822f11|            DemoFileRow(name: "styles.css", editorCore: editorCore, theme: theme)
350|5f3077|        }
351|27e597|    }
352|b31277|}
353|adc83b|
354|ab28f0|struct DemoFileRow: View {
355|a5193b|    let name: String
356|e5f895|    @ObservedObject var editorCore: EditorCore
357|6b0e55|    let theme: Theme
358|b4687f|    
359|504e43|    var body: some View {
360|b120fa|        HStack(spacing: 4) {
361|5a4821|            Spacer().frame(width: 12)
362|5a9b2c|            Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
363|0ffef7|            Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
364|1e6289|            Spacer()
365|5f3077|        }
366|60e15e|        .padding(.vertical, 4)
367|55e29b|        .contentShape(Rectangle())
368|cf12c6|        .onTapGesture {
369|9f9063|            if let tab = editorCore.tabs.first(where: { $0.fileName == name }) {
370|166be5|                editorCore.selectTab(id: tab.id)
371|a7dc16|            }
372|5f3077|        }
373|27e597|    }
374|b31277|}
375|adc83b|
376|f3aab4|// MARK: - Tab Bar
377|adc83b|
378|24d9d9|struct IDETabBar: View {
379|e5f895|    @ObservedObject var editorCore: EditorCore
380|6b0e55|    let theme: Theme
381|b4687f|    
382|504e43|    var body: some View {
383|98ab70|        ScrollView(.horizontal, showsIndicators: false) {
384|3b7550|            HStack(spacing: 0) {
385|7512d8|                ForEach(editorCore.tabs) { tab in
386|4b4bd2|                    IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
387|4e2d32|                }
388|5de7cd|                Button(action: { editorCore.addTab() }) {
389|fd7d74|                    Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
390|4e2d32|                }
391|30b85f|            }.padding(.horizontal, 4)
392|962d70|        }.frame(height: 36).background(theme.tabBarBackground)
393|27e597|    }
394|b31277|}
395|adc83b|
396|68fbe9|struct IDETabItem: View {
397|4dc199|    let tab: Tab
398|055123|    let isSelected: Bool
399|e5f895|    @ObservedObject var editorCore: EditorCore
400|6b0e55|    let theme: Theme
401|b4687f|    
402|504e43|    var body: some View {
403|e1c66d|        HStack(spacing: 6) {
404|29528a|            Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
405|a9dd8d|            Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
406|d555ba|                .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
407|5029ae|            if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
408|6effb3|            Button(action: { editorCore.closeTab(id: tab.id) }) {
409|f4c72a|                Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
410|041ce7|                    .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
411|a7dc16|            }
412|5f3077|        }
413|2da2e9|        .padding(.horizontal, 12).padding(.vertical, 6)
414|116b54|        .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
415|7a9052|        .onTapGesture { editorCore.selectTab(id: tab.id) }
416|27e597|    }
417|b31277|}
418|adc83b|
419|f95ca3|// MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
420|adc83b|
421|a178f9|struct IDEEditorView: View {
422|e5f895|    @ObservedObject var editorCore: EditorCore
423|4dc199|    let tab: Tab
424|6b0e55|    let theme: Theme
425|b4687f|    
426|129112|    /// Feature flag for Runestone editor - uses centralized FeatureFlags
427|952908|    private var useRunestoneEditor: Bool { FeatureFlags.useRunestoneEditor }
428|adc83b|
429|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
430|eba335|    @State private var text: String = ""
431|4f0ac8|    @State private var scrollPosition: Int = 0
432|36da68|    @State private var scrollOffset: CGFloat = 0
433|d473fd|    @State private var totalLines: Int = 1
434|bcf90b|    @State private var visibleLines: Int = 20
435|9cb5e9|    @State private var currentLineNumber: Int = 1
436|cc347a|    @State private var currentColumn: Int = 1
437|eee196|    @State private var cursorIndex: Int = 0
438|2c43f6|    @State private var lineHeight: CGFloat = 17
439|446eb9|    @State private var requestedCursorIndex: Int? = nil
440|5c2aeb|    @State private var requestedLineSelection: Int? = nil
441|adc83b|
442|3977e1|    @StateObject private var autocomplete = AutocompleteManager()
443|4445ec|    @State private var showAutocomplete = false
444|a9aa54|    @ObservedObject private var foldingManager = CodeFoldingManager.shared
445|f453fc|    @StateObject private var findViewModel = FindViewModel()
446|b4687f|    
447|504e43|    var body: some View {
448|94dd27|        VStack(spacing: 0) {
449|8779dd|            // Find/Replace bar
450|2b2a70|            if editorCore.showSearch {
451|38cbe4|                FindReplaceView(viewModel: findViewModel)
452|b768ed|                    .background(theme.tabBarBackground)
453|a7dc16|            }
454|3070d1|            
455|b97232|            BreadcrumbsView(editorCore: editorCore, tab: tab)
456|3070d1|            
457|ca6f75|            GeometryReader { geometry in
458|e60c16|                ZStack(alignment: .topLeading) {
459|7a5371|                HStack(spacing: 0) {
460|439015|                    // Only show custom line numbers for legacy editor (Runestone has built-in line numbers)
461|3dcece|                    if lineNumbersStyle != "off" && !useRunestoneEditor {
462|ca5e14|                        LineNumbersWithFolding(
463|a108d1|                            fileId: tab.url?.path ?? tab.fileName,
464|937d74|                            totalLines: totalLines,
465|0f00a6|                            currentLine: currentLineNumber,
466|d6742c|                            scrollOffset: scrollOffset,
467|9f4e9f|                            lineHeight: lineHeight,
468|76e9b6|                            requestedLineSelection: $requestedLineSelection,
469|0d74bf|                            foldingManager: foldingManager,
470|0acd63|                            theme: theme
471|63214b|                        )
472|c15397|                        .frame(width: 60)
473|3a838d|                        .background(theme.sidebarBackground.opacity(0.5))
474|c9717a|                    }
475|dd2193|                    
476|3f9dab|                    // Use Runestone for all files including JSON (has TreeSitter JSON support)
477|df925c|                    if false && tab.fileName.hasSuffix(".json") {
478|4229a0|                        // JSON Tree View disabled - using Runestone editor instead
479|daf992|                        JSONTreeView(data: text.data(using: .utf8) ?? Data())
480|f9d830|                            .frame(maxWidth: .infinity, maxHeight: .infinity)
481|96e3a5|                            .background(theme.editorBackground)
482|540066|                    } else {
483|082ddd|                        // Use Runestone for O(log n) performance, or legacy view as fallback
484|e44d33|                        Group {
485|31b1a0|                            if useRunestoneEditor {
486|40914b|                                RunestoneEditorView(
487|4496ad|                                    text: $text,
488|d36f79|                                    filename: tab.fileName,
489|deb430|                                    scrollOffset: $scrollOffset,
490|2b845b|                                    totalLines: $totalLines,
491|71c5eb|                                    currentLineNumber: $currentLineNumber,
492|872d17|                                    currentColumn: $currentColumn,
493|927813|                                    cursorIndex: $cursorIndex,
494|397368|                                    isActive: true,
495|b41e3e|                                    fontSize: editorCore.editorFontSize,
496|f39601|                                    onAcceptAutocomplete: {
497|35fa15|                                        guard showAutocomplete else { return false }
498|028ab7|                                        var tempText = text
499|4f6f56|                                        var tempCursor = cursorIndex
500|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
501|28278a|                                        if tempText != text {
502|1a390a|                                            text = tempText
503|9a3612|                                            cursorIndex = tempCursor
504|55a703|                                            requestedCursorIndex = tempCursor
505|46924a|                                            showAutocomplete = false
506|e18645|                                            return true
507|eed1d8|                                        }
508|9818dc|                                        return false
509|3cc64b|                                    },
510|7ed733|                                    onDismissAutocomplete: {
511|35fa15|                                        guard showAutocomplete else { return false }
512|fc38c2|                                        autocomplete.hideSuggestions()
513|579f59|                                        showAutocomplete = false
514|c09eb1|                                        return true
515|8ab74d|                                    }
516|58a90d|                                )
517|240f50|                            } else {
518|e97ddb|                                // Legacy SyntaxHighlightingTextView (fallback)
519|27eb3b|                                SyntaxHighlightingTextView(
520|4496ad|                                    text: $text,
521|d36f79|                                    filename: tab.fileName,
522|44ffa0|                                    scrollPosition: $scrollPosition,
523|deb430|                                    scrollOffset: $scrollOffset,
524|2b845b|                                    totalLines: $totalLines,
525|a9b405|                                    visibleLines: $visibleLines,
526|71c5eb|                                    currentLineNumber: $currentLineNumber,
527|872d17|                                    currentColumn: $currentColumn,
528|927813|                                    cursorIndex: $cursorIndex,
529|31e938|                                    lineHeight: $lineHeight,
530|397368|                                    isActive: true,
531|b41e3e|                                    fontSize: editorCore.editorFontSize,
532|193919|                                    requestedLineSelection: $requestedLineSelection,
533|70abf8|                                    requestedCursorIndex: $requestedCursorIndex,
534|f39601|                                    onAcceptAutocomplete: {
535|35fa15|                                        guard showAutocomplete else { return false }
536|028ab7|                                        var tempText = text
537|4f6f56|                                        var tempCursor = cursorIndex
538|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
539|28278a|                                        if tempText != text {
540|1a390a|                                            text = tempText
541|9a3612|                                            cursorIndex = tempCursor
542|55a703|                                            requestedCursorIndex = tempCursor
543|46924a|                                            showAutocomplete = false
544|e18645|                                            return true
545|eed1d8|                                        }
546|9818dc|                                        return false
547|3cc64b|                                    },
548|7ed733|                                    onDismissAutocomplete: {
549|35fa15|                                        guard showAutocomplete else { return false }
550|fc38c2|                                        autocomplete.hideSuggestions()
551|579f59|                                        showAutocomplete = false
552|c09eb1|                                        return true
553|8ab74d|                                    }
554|58a90d|                                )
555|89d40a|                            }
556|392b35|                        }
557|23a7d6|                        .onChange(of: text) { newValue in
558|c2cbfa|                            editorCore.updateActiveTabContent(newValue)
559|ca5c5e|                            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
560|2d6cfb|                            autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
561|5db623|                            showAutocomplete = autocomplete.showSuggestions
562|f1e408|                            foldingManager.detectFoldableRegions(in: newValue, filePath: tab.url?.path ?? tab.fileName)
563|392b35|                        }
564|ae1be2|                        .onChange(of: cursorIndex) { newCursor in
565|017a4d|                            autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
566|5db623|                            showAutocomplete = autocomplete.showSuggestions
567|392b35|                        }
568|c9717a|                    }
569|dd2193|                    
570|0fbe94|                    if !tab.fileName.hasSuffix(".json") {
571|d0a712|                        MinimapView(
572|234a10|                            content: text,
573|d6742c|                            scrollOffset: scrollOffset,
574|9a8bd2|                            scrollViewHeight: geometry.size.height,
575|29b4a2|                            totalContentHeight: CGFloat(totalLines) * lineHeight,
576|83e3c8|                            onScrollRequested: { newOffset in
577|c2e825|                                // Minimap requested scroll - update editor position
578|d09b41|                                scrollOffset = newOffset
579|af41de|                                // Convert back from pixels to line number
580|6ad0f0|                                let newLine = Int(newOffset / max(lineHeight, 1))
581|ec5b45|                                scrollPosition = max(0, min(newLine, totalLines - 1))
582|89d40a|                            }
583|63214b|                        )
584|abeec0|                        .frame(width: 80)
585|c9717a|                    }
586|4e2d32|                }
587|3bc2db|                .background(theme.editorBackground)
588|adc83b|
589|cf06bf|                // Sticky Header Overlay (FEAT-040)
590|d5af46|                StickyHeaderView(
591|c24fd5|                    text: text,
592|f49254|                    currentLine: scrollPosition,
593|f7b7a6|                    theme: theme,
594|8e60a5|                    lineHeight: lineHeight,
595|9628b3|                    onSelect: { line in
596|df068a|                        requestedLineSelection = line
597|c9717a|                    }
598|6f642e|                )
599|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
600|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
601|adc83b|
602|0f82df|                // Inlay Hints Overlay (type hints, parameter names)
603|a8bcb0|                InlayHintsOverlay(
604|0fb212|                    code: text,
605|5f8f93|                    language: tab.language,
606|23acb0|                    scrollPosition: scrollPosition,
607|8e60a5|                    lineHeight: lineHeight,
608|0e3ffc|                    fontSize: editorCore.editorFontSize,
609|a63927|                    gutterWidth: (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0,
610|088baa|                    rightReservedWidth: tab.fileName.hasSuffix(".json") ? 0 : 80
611|6f642e|                )
612|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
613|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
614|8eef2d|                if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
615|baeb3a|                    AutocompletePopup(
616|83a4b0|                        suggestions: autocomplete.suggestionItems,
617|53da2f|                        selectedIndex: autocomplete.selectedIndex,
618|5db55c|                        theme: theme
619|82606a|                    ) { index in
620|3a2861|                        autocomplete.selectedIndex = index
621|9c12a8|                        var tempText = text
622|f02eb3|                        var tempCursor = cursorIndex
623|7fdc0e|                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
624|326231|                        if tempText != text {
625|d7f8a5|                            text = tempText
626|34aa29|                            cursorIndex = tempCursor
627|d3d820|                            requestedCursorIndex = tempCursor
628|392b35|                        }
629|2411d0|                        showAutocomplete = false
630|c9717a|                    }
631|58a34b|                    .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
632|4e2d32|                }
633|a7dc16|            }
634|5f3077|        }
635|5f3077|        }
636|2bd24e|        .onAppear {
637|ba85f8|            text = tab.content
638|92d865|            foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
639|5f3077|        }
640|9d97c0|        .onChange(of: tab.id) { _ in
641|ba85f8|            text = tab.content
642|92d865|            foldingManager.detectFoldableRegions(in: text, filePath: tab.url?.path ?? tab.fileName)
643|5f3077|        }
644|d3345e|        .onChange(of: currentLineNumber) { line in
645|3384f8|            editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
646|5f3077|        }
647|588fd8|        .onChange(of: currentColumn) { col in
648|16524d|            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
649|5f3077|        }
650|2bd24e|        .onAppear {
651|c916b3|            findViewModel.editorCore = editorCore
652|5f3077|        }
653|27e597|    }
654|b4687f|    
655|a19e38|    // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
656|b31277|}
657|adc83b|
658|dcdcdb|// MARK: - Line Numbers with Folding
659|adc83b|
660|c8dd5c|struct LineNumbersWithFolding: View {
661|5799da|    let fileId: String
662|cdda83|    let totalLines: Int
663|c75d8a|    let currentLine: Int
664|5b2177|    let scrollOffset: CGFloat
665|96ac71|    let lineHeight: CGFloat
666|86829b|    @Binding var requestedLineSelection: Int?
667|ec5c86|    @ObservedObject var foldingManager: CodeFoldingManager
668|c97289|    @ObservedObject private var debugManager = DebugManager.shared
669|6b0e55|    let theme: Theme
670|adc83b|
671|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
672|adc83b|
673|504e43|    var body: some View {
674|ca170c|        ScrollView(showsIndicators: false) {
675|829de3|            VStack(alignment: .trailing, spacing: 0) {
676|2e20ec|                // Match UITextView.textContainerInset.top (see SyntaxHighlightingTextView.swift)
677|551416|                // so line numbers stay vertically aligned with the first line of text.
678|227120|                ForEach(0..<totalLines, id: \.self) { lineIndex in
679|71bf03|                    if !foldingManager.isLineFolded(line: lineIndex) {
680|d3392c|                        HStack(spacing: 2) {
681|8eed40|                            Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
682|5f750e|                                Circle()
683|4cf57e|                                    .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
684|5ded70|                                    .overlay(
685|6304cf|                                        Circle()
686|f93b39|                                            .stroke(Color.red.opacity(0.6), lineWidth: 1)
687|fe99c4|                                            .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
688|bf17fb|                                    )
689|d07523|                                    .frame(width: 10, height: 10)
690|da49b4|                                    .padding(.leading, 2)
691|89d40a|                            }
692|917e04|                            .buttonStyle(.plain)
693|746328|                            .frame(width: 14, height: lineHeight)
694|adc83b|
695|75451e|                            if foldingManager.isFoldable(line: lineIndex) {
696|6ae979|                                Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
697|8689bb|                                    Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
698|e50a51|                                        .font(.system(size: 8))
699|856d81|                                        .foregroundColor(theme.lineNumber)
700|f83e05|                                }
701|31bef9|                                .buttonStyle(.plain)
702|23311c|                                .frame(width: 14, height: lineHeight)
703|240f50|                            } else {
704|b18c2d|                                Spacer().frame(width: 14)
705|89d40a|                            }
706|adc83b|
707|6798e8|                            Text(displayText(for: lineIndex))
708|f57164|                                .font(.system(size: 12, design: .monospaced))
709|525023|                                .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
710|5d10bc|                                .frame(height: lineHeight)
711|5cb7d4|                                .contentShape(Rectangle())
712|d56a2c|                                .onTapGesture {
713|c0cc45|                                    // FEAT-041: click line number selects entire line
714|6eaf3d|                                    requestedLineSelection = lineIndex
715|f83e05|                                }
716|392b35|                        }
717|729aac|                        .frame(maxWidth: .infinity, alignment: .trailing)
718|539a79|                        .padding(.trailing, 4)
719|c9717a|                    }
720|4e2d32|                }
721|a7dc16|            }
722|5f0534|            .padding(.top, 8)
723|873abc|            .offset(y: -scrollOffset)
724|5f3077|        }
725|c059d6|        .scrollDisabled(true)
726|27e597|    }
727|adc83b|
728|46d3db|    private func displayText(for lineIndex: Int) -> String {
729|5d97cf|        switch lineNumbersStyle {
730|a6eb36|        case "relative":
731|e1ceac|            // VS Code-style: current line shows absolute, others show relative distance
732|b0622f|            let lineNumber = lineIndex + 1
733|44bb33|            if lineNumber == currentLine { return "\(lineNumber)" }
734|5e67df|            return "\(abs(lineNumber - currentLine))"
735|adc83b|
736|5040ac|        case "interval":
737|b0622f|            let lineNumber = lineIndex + 1
738|bc3fe3|            return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
739|adc83b|
740|520b7d|        default:
741|3880c0|            return "\(lineIndex + 1)"
742|5f3077|        }
743|27e597|    }
744|b31277|}
745|adc83b|
746|e3bdd2|// MARK: - Autocomplete Popup
747|adc83b|
748|b1d20a|struct AutocompletePopup: View {
749|5eb9d3|    let suggestions: [AutocompleteSuggestion]
750|79c1fc|    let selectedIndex: Int
751|6b0e55|    let theme: Theme
752|6f35cf|    let onSelectIndex: (Int) -> Void
753|b4687f|    
754|504e43|    var body: some View {
755|0865e6|        VStack(alignment: .leading, spacing: 0) {
756|a954be|            ForEach(suggestions.indices, id: \.self) { index in
757|ad513b|                let s = suggestions[index]
758|dbadc1|                HStack(spacing: 6) {
759|fcd45a|                    Image(systemName: icon(for: s.kind))
760|cdb0af|                        .font(.caption)
761|2e9202|                        .foregroundColor(color(for: s.kind))
762|288999|                    VStack(alignment: .leading, spacing: 1) {
763|3d1271|                        Text(s.displayText)
764|09bbe1|                            .font(.system(size: 12, design: .monospaced))
765|239e62|                            .foregroundColor(theme.editorForeground)
766|71c2b3|                        if s.insertText != s.displayText && !s.insertText.isEmpty {
767|53d416|                            Text(s.insertText)
768|87ab4e|                                .font(.system(size: 10, design: .monospaced))
769|32bc5b|                                .foregroundColor(theme.editorForeground.opacity(0.55))
770|a9b5f4|                                .lineLimit(1)
771|392b35|                        }
772|c9717a|                    }
773|dcd0bf|                    Spacer()
774|4e2d32|                }
775|41847e|                .padding(.horizontal, 8).padding(.vertical, 6)
776|e72d30|                .background(index == selectedIndex ? theme.selection : Color.clear)
777|1e8a31|                .contentShape(Rectangle())
778|eec06d|                .onTapGesture { onSelectIndex(index) }
779|a7dc16|            }
780|5f3077|        }
781|5260c9|        .frame(width: 260)
782|04ec17|        .background(theme.editorBackground)
783|097147|        .cornerRadius(6)
784|f64ce1|        .shadow(radius: 8)
785|27e597|    }
786|b4687f|    
787|ccd198|    private func icon(for kind: AutocompleteSuggestionKind) -> String {
788|01fe0f|        switch kind {
789|62a12d|        case .keyword: return "key.fill"
790|710dbd|        case .symbol: return "cube.fill"
791|d0a8ab|        case .stdlib: return "curlybraces"
792|c3ed81|        case .member: return "arrow.right.circle.fill"
793|5f3077|        }
794|27e597|    }
795|b4687f|    
796|126b1f|    private func color(for kind: AutocompleteSuggestionKind) -> Color {
797|01fe0f|        switch kind {
798|a51b30|        case .keyword: return .purple
799|8740a1|        case .symbol: return .blue
800|628567|        case .stdlib: return .orange
801|b8e5e8|        case .member: return .green
802|5f3077|        }
803|27e597|    }
804|b31277|}
805|adc83b|
806|4409de|// MARK: - Welcome View
807|adc83b|
808|35ff8c|struct IDEWelcomeView: View {
809|e5f895|    @ObservedObject var editorCore: EditorCore
810|fe002a|    @Binding var showFolderPicker: Bool
811|6b0e55|    let theme: Theme
812|b4687f|    
813|504e43|    var body: some View {
814|c906ca|        VStack(spacing: 24) {
815|00a225|            Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 80)).foregroundColor(theme.editorForeground.opacity(0.3))
816|b3ccb7|            Text("VS Code for iPadOS").font(.largeTitle).fontWeight(.bold).foregroundColor(theme.editorForeground)
817|5c2d12|            VStack(alignment: .leading, spacing: 12) {
818|49df13|                WelcomeBtn(icon: "doc.badge.plus", title: "New File", shortcut: "⌘N", theme: theme) { editorCore.addTab() }
819|b0fcfd|                WelcomeBtn(icon: "folder", title: "Open Folder", shortcut: "⌘⇧O", theme: theme) { showFolderPicker = true }
820|2bad60|                WelcomeBtn(icon: "doc", title: "Open File", shortcut: "⌘O", theme: theme) { editorCore.showFilePicker = true }
821|502f56|                WelcomeBtn(icon: "terminal", title: "Command Palette", shortcut: "⌘⇧P", theme: theme) { editorCore.showCommandPalette = true }
822|a7dc16|            }
823|139d2b|        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.editorBackground)
824|27e597|    }
825|b31277|}
826|adc83b|
827|4b4130|struct WelcomeBtn: View {
828|f0e87a|    let icon: String
829|399f36|    let title: String
830|14874c|    let shortcut: String
831|6b0e55|    let theme: Theme
832|59027a|    let action: () -> Void
833|b4687f|    
834|504e43|    var body: some View {
835|6f04d8|        Button(action: action) {
836|f49fd2|            HStack {
837|f2b865|                Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
838|d34e42|                Text(title).foregroundColor(theme.editorForeground)
839|a02350|                Spacer()
840|0f9490|                Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
841|a7dc16|            }
842|a09f6b|            .padding().frame(width: 280)
843|cef0ad|            .background(theme.sidebarBackground)
844|b18c2b|            .cornerRadius(8)
845|9e9bdf|        }.buttonStyle(.plain)
846|27e597|    }
847|b31277|}
848|adc83b|
849|db0271|// MARK: - Command Palette
850|adc83b|
851|e71bec|struct IDECommandPalette: View {
852|e5f895|    @ObservedObject var editorCore: EditorCore
853|3bd3a7|    @Binding var showSettings: Bool
854|fe5153|    @Binding var showTerminal: Bool
855|d901da|    @State private var searchText = ""
856|b4687f|    
857|504e43|    var body: some View {
858|94dd27|        VStack(spacing: 0) {
859|f49fd2|            HStack {
860|41b09a|                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
861|259764|                TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
862|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))
863|e744dc|            Divider()
864|6b85db|            ScrollView {
865|9ad863|                VStack(spacing: 0) {
866|bd267a|                    CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
867|48369f|                    CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
868|1997cb|                    CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
869|e10354|                    CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
870|684ba0|                    CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
871|79e8a7|                    CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
872|92fdf3|                    CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
873|e6f867|                    CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
874|b7baf1|                }.padding(.vertical, 8)
875|a7dc16|            }
876|338a7e|        }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
877|27e597|    }
878|b31277|}
879|adc83b|
880|b6a6d7|struct CommandRow: View {
881|e97b0d|    let icon: String; let name: String; let shortcut: String; let action: () -> Void
882|504e43|    var body: some View {
883|6f04d8|        Button(action: action) {
884|f49fd2|            HStack {
885|c4580d|                Image(systemName: icon).foregroundColor(.accentColor).frame(width: 24)
886|ade206|                Text(name).foregroundColor(.primary)
887|a02350|                Spacer()
888|512c27|                Text(shortcut).font(.caption).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 4).background(Color(UIColor.tertiarySystemFill)).cornerRadius(4)
889|dfa64f|            }.padding(.horizontal).padding(.vertical, 12).contentShape(Rectangle())
890|9e9bdf|        }.buttonStyle(.plain)
891|27e597|    }
892|b31277|}
893|adc83b|
894|6b1f13|// MARK: - Quick Open
895|adc83b|
896|7bfe0e|struct IDEQuickOpen: View {
897|e5f895|    @ObservedObject var editorCore: EditorCore
898|d901da|    @State private var searchText = ""
899|b4687f|    
900|504e43|    var body: some View {
901|94dd27|        VStack(spacing: 0) {
902|f49fd2|            HStack {
903|fa8104|                Image(systemName: "magnifyingglass").foregroundColor(.gray)
904|a496c8|                TextField("Search files...", text: $searchText).textFieldStyle(.plain)
905|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))
906|e744dc|            Divider()
907|6b85db|            ScrollView {
908|8ee2f5|                VStack(alignment: .leading, spacing: 0) {
909|3625c1|                    ForEach(editorCore.tabs) { tab in
910|88ee6a|                        QuickOpenRow(name: tab.fileName, path: "") {
911|4f316a|                            editorCore.selectTab(id: tab.id)
912|90bf2b|                            editorCore.showQuickOpen = false
913|392b35|                        }
914|c9717a|                    }
915|4e2d32|                }
916|1964e5|            }.frame(maxHeight: 350)
917|0014d4|        }.frame(width: 500).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
918|27e597|    }
919|b31277|}
920|adc83b|
921|767562|struct QuickOpenRow: View {
922|ee9c0b|    let name: String; let path: String; let action: () -> Void
923|504e43|    var body: some View {
924|6f04d8|        Button(action: action) {
925|f49fd2|            HStack {
926|0b1ac7|                Image(systemName: fileIcon(for: name)).foregroundColor(fileColor(for: name)).frame(width: 20)
927|23f981|                VStack(alignment: .leading, spacing: 2) { Text(name).font(.system(size: 14)); Text(path + name).font(.system(size: 11)).foregroundColor(.secondary) }
928|a02350|                Spacer()
929|38ff47|            }.padding(.horizontal).padding(.vertical, 8).contentShape(Rectangle())
930|9e9bdf|        }.buttonStyle(.plain)
931|27e597|    }
932|b31277|}
933|adc83b|
934|2d88cf|// MARK: - AI Assistant
935|adc83b|
936|5f57bf|struct IDEAIAssistant: View {
937|e5f895|    @ObservedObject var editorCore: EditorCore
938|6b0e55|    let theme: Theme
939|2855b6|    @State private var userInput = ""
940|9cbba7|    @State private var messages: [(id: UUID, role: String, content: String)] = [(UUID(), "assistant", "Hello! I'm your AI coding assistant. How can I help?")]
941|b4687f|    
942|504e43|    var body: some View {
943|94dd27|        VStack(spacing: 0) {
944|f49fd2|            HStack {
945|35e129|                Image(systemName: "brain").foregroundColor(.blue)
946|b6566c|                Text("AI Assistant").font(.headline).foregroundColor(theme.editorForeground)
947|a02350|                Spacer()
948|cc1153|                Button(action: { editorCore.showAIAssistant = false }) { Image(systemName: "xmark.circle.fill").foregroundColor(theme.editorForeground.opacity(0.5)) }
949|0facd0|            }.padding().background(theme.sidebarBackground)
950|3070d1|            
951|6b85db|            ScrollView {
952|df82e6|                LazyVStack(alignment: .leading, spacing: 12) {
953|a5721a|                    ForEach(messages, id: \.id) { msg in
954|679877|                        HStack {
955|a85384|                            if msg.role == "user" { Spacer(minLength: 60) }
956|8b1fb9|                            Text(msg.content).padding(12).background(RoundedRectangle(cornerRadius: 12).fill(msg.role == "user" ? Color.blue : theme.sidebarBackground)).foregroundColor(msg.role == "user" ? .white : theme.editorForeground)
957|b74ebb|                            if msg.role == "assistant" { Spacer(minLength: 60) }
958|392b35|                        }
959|c9717a|                    }
960|c5f15e|                }.padding()
961|744c4f|            }.background(theme.editorBackground)
962|3070d1|            
963|8574de|            HStack(spacing: 12) {
964|0e3711|                TextField("Ask about your code...", text: $userInput).textFieldStyle(.roundedBorder)
965|753afe|                Button(action: { sendMessage() }) { Image(systemName: "paperplane.fill").foregroundColor(userInput.isEmpty ? .gray : .blue) }.disabled(userInput.isEmpty)
966|0facd0|            }.padding().background(theme.sidebarBackground)
967|a8790d|        }.background(theme.editorBackground).cornerRadius(12).shadow(radius: 20)
968|27e597|    }
969|b4687f|    
970|beb964|    func sendMessage() {
971|29cfe7|        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
972|8a803f|        messages.append((UUID(), "user", userInput))
973|eac017|        let input = userInput
974|2c52ee|        userInput = ""
975|145a34|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
976|c7ba20|            messages.append((UUID(), "assistant", "I can help with '\(input)'! What specifically would you like to know?"))
977|5f3077|        }
978|27e597|    }
979|b31277|}
980|adc83b|
981|31bfc1|// MARK: - Status Bar
982|adc83b|
983|adc83b|
984|adc83b|
985|f4a6ee|// MARK: - Folder Picker
986|adc83b|
987|4842b2|struct IDEFolderPicker: UIViewControllerRepresentable {
988|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
989|10370b|    var onPick: ((URL) -> Void)?
990|b4687f|    
991|fc2de0|    init(fileNavigator: FileSystemNavigator, onPick: ((URL) -> Void)? = nil) {
992|237a4e|        self.fileNavigator = fileNavigator
993|3192b9|        self.onPick = onPick
994|27e597|    }
995|b4687f|    
996|a4c191|    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
997|352547|        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
998|325e82|        picker.delegate = context.coordinator
999|993f50|        return picker
1000|27e597|    }
1001|b4687f|    
1002|bd012f|    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
1003|b4687f|    
1004|7da3c4|    func makeCoordinator() -> Coordinator { Coordinator(self) }
1005|b4687f|    
1006|9c0536|    class Coordinator: NSObject, UIDocumentPickerDelegate {
1007|e78b69|        let parent: IDEFolderPicker
1008|11a437|        init(_ parent: IDEFolderPicker) { self.parent = parent }
1009|d6ed84|        
1010|da3421|        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
1011|51c500|            if let url = urls.first {
1012|94998b|                _ = url.startAccessingSecurityScopedResource()
1013|24e3be|                if let onPick = parent.onPick {
1014|71fb5b|                    onPick(url)
1015|fdd0e2|                } else {
1016|866512|                    // Default behavior if no custom handler
1017|7ec9fd|                    parent.fileNavigator.loadFileTree(at: url)
1018|3d4547|                    Task { @MainActor in
1019|e3472e|                        LaunchManager.shared.setWorkspaceRoot(url)
1020|14c08d|                        GitManager.shared.setWorkingDirectory(url)
1021|c9717a|                    }
1022|4e2d32|                }
1023|a7dc16|            }
1024|5f3077|        }
1025|27e597|    }
1026|b31277|}
1027|adc83b|
1028|ba3cff|// MARK: - Document Picker
1029|adc83b|
1030|f67fab|struct IDEDocumentPicker: UIViewControllerRepresentable {
1031|e5f895|    @ObservedObject var editorCore: EditorCore
1032|b4687f|    
1033|a4c191|    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
1034|99746f|        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .sourceCode, .json, .plainText, .data])
1035|1abf38|        picker.allowsMultipleSelection = true
1036|325e82|        picker.delegate = context.coordinator
1037|993f50|        return picker
1038|27e597|    }
1039|b4687f|    
1040|bd012f|    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
1041|b4687f|    
1042|eca7e2|    func makeCoordinator() -> Coordinator { Coordinator(editorCore: editorCore) }
1043|b4687f|    
1044|9c0536|    class Coordinator: NSObject, UIDocumentPickerDelegate {
1045|3f6aca|        let editorCore: EditorCore
1046|d04b21|        init(editorCore: EditorCore) { self.editorCore = editorCore }
1047|d6ed84|        
1048|da3421|        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
1049|457fb6|            for url in urls { editorCore.openFile(from: url) }
1050|7adb67|            editorCore.showFilePicker = false
1051|5f3077|        }
1052|d6ed84|        
1053|de7fa5|        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
1054|7adb67|            editorCore.showFilePicker = false
1055|5f3077|        }
1056|27e597|    }
1057|b31277|}
1058|adc83b|
1059|c30d93|// MARK: - Sidebar Search View
1060|adc83b|
1061|ff7a02|struct SidebarSearchView: View {
1062|6b0e55|    let theme: Theme
1063|d901da|    @State private var searchText = ""
1064|fc86dc|    @State private var replaceText = ""
1065|14c295|    @State private var showReplace = false
1066|e71a4

... [output truncated: 192 more chars]


Now I have all the information needed to provide the report.

>>>REPORT
## Analysis of `saveActiveTab()` in EditorCore.swift

### Location
- **File:** VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift
- **Lines:** 832-850

### 1) What does it do?
The function saves the content of the currently active tab to disk:
1. Guards that there's an active tab index AND that the tab has a URL (early returns if either is missing)
2. Attempts to write the content to disk via two paths:
   - **Primary:** Uses `fileNavigator.writeFile(at:content:)` if fileNavigator is set
   - **Fallback:** Direct write using `String.write(to:atomically:encoding:)` with security-scoped resource handling
3. On success, marks the tab as saved (`isUnsaved = false`)
4. On failure, only prints an error message to console

### 2) Does it actually write to disk?
**YES**, it writes to disk through one of two mechanisms:
- Via `fileNavigator.writeFile()` (preferred path when fileNavigator is wired up)
- Via direct `String.write(to: url, atomically: true, encoding: .utf8)` as fallback

The fallback also handles iPadOS security-scoped resource access for sandboxed files.

### 3) Failure Points
| Failure Point | Impact |
|---------------|--------|
| **No active tab** (`activeTabIndex` is nil) | Silent early return - no save attempted |
| **Tab has no URL** (unsaved new file) | Silent early return - **BUG: new files can't be saved this way!** |
| **fileNavigator.writeFile() throws** | Error printed to console, tab stays marked unsaved |
| **String.write() throws** | Error printed to console, tab stays marked unsaved |
| **Security-scoped access fails** | May still work if parent scope active, otherwise write fails |
| **No user feedback** | Errors are only `print()`ed - user never sees failure notification |

**Critical Issue:** New/untitled files (where `url == nil`) cannot be saved via this function - it silently returns. There's no "Save As" flow triggered.

---

## SaveFile Notification Handler in ContentView.swift

### Location
- **File:** VSCodeiPadOS/VSCodeiPadOS/ContentView.swift  
- **Lines:** 153-155

### Code
```swift
.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveFile"))) { _ in
    editorCore.saveActiveTab()
}
```

### What it does
Simply forwards the `SaveFile` notification (typically triggered by ⌘S keyboard shortcut from menu commands) to `editorCore.saveActiveTab()`. No additional logic or error handling at this layer.

---

## Files Examined
1. `VSCodeiPadOS/VSCodeiPadOS/Services/EditorCore.swift` (full file, 1351 lines)
2. `VSCodeiPadOS/VSCodeiPadOS/ContentView.swift` (full file, 1151 lines)
>>>END
