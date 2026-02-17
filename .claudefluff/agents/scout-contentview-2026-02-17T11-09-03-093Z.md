# Agent: scout-contentview
**Status:** done
**Tokens:** 2,493
**Cost:** $0.0000
**Time:** 2026-02-17T11:09:03.093Z

## Task
Read VSCodeiPadOS/VSCodeiPadOS/ContentView.swift. Report: main app structure, what features are wired up, what's missing

## Response




---

## 🔧 TOOL RESULTS

[get_symbols]
No symbols found in VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (file may need to be opened first)




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 101-250 of 1407)
────────────────────────────────────────
101|b4687f|    
102|f6ca88|    @ObservedObject private var tunnelManager = TunnelManager.shared
103|b4687f|    
104|ab06c2|    @ViewBuilder
105|99e241|    private var mainContentView: some View {
106|da7046|        // Connected Mode takes over the entire screen when active
107|0b30f6|        if tunnelManager.isConnected {
108|e42686|            VSCodeTunnelView()
109|e3d6fe|                .environmentObject(themeManager)
110|b31999|        } else {
111|d6f3f4|            ZStack {
112|114abf|                mainLayout
113|e1cd88|                overlayViews
114|216278|                
115|511507|                // Toast notifications (bottom-right)
116|c031d1|                NotificationToastOverlay(manager: NotificationManager.shared)
117|a7dc16|            }
118|6f1e62|            .background(theme.editorBackground)
119|5f3077|        }
120|27e597|    }
121|b4687f|    
122|ab06c2|    @ViewBuilder
123|e7dc9d|    private var mainLayout: some View {
124|94dd27|        VStack(spacing: 0) {
125|3b7550|            HStack(spacing: 0) {
126|10bfb5|                IDEActivityBar(editorCore: editorCore, selectedTab: $selectedSidebarTab, showSettings: $showSettings, showTerminal: $showTerminal)
127|216278|                
128|aad50d|                if editorCore.showSidebar {
129|f664cf|                    sidebarContent.frame(width: editorCore.sidebarWidth)
130|4e2d32|                }
131|216278|                
132|9ad863|                VStack(spacing: 0) {
133|c452a2|                    IDETabBar(editorCore: editorCore, theme: theme)
134|dd2193|                    
135|957acf|                    if let tab = editorCore.activeTab {
136|44cc4d|                        IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
137|79ebe2|                            .id(tab.id)
138|540066|                    } else {
139|0134d1|                        IDEWelcomeView(editorCore: editorCore, showFolderPicker: $showingFolderPicker, theme: theme)
140|c9717a|                    }
141|dd2193|                    
142|ec041c|                    StatusBarView(editorCore: editorCore)
143|4e2d32|                }
144|a7dc16|            }
145|3070d1|            
146|bb0c3a|            if showTerminal {
147|b4c4b0|                PanelView(isVisible: $showTerminal, height: $terminalHeight)
148|a7dc16|            }
149|5f3077|        }
150|27e597|    }
151|b4687f|    
152|ab06c2|    @ViewBuilder
153|54134c|    private var overlayViews: some View {
154|1a1bc5|        // Command Palette (Cmd+Shift+P)
155|a59479|        if editorCore.showCommandPalette {
156|44e7ae|            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showCommandPalette = false }
157|b35c5f|            CommandPaletteView(editorCore: editorCore, showSettings: $showSettings, showTerminal: $showTerminal)
158|5f3077|        }
159|d6ed84|        
160|67d30a|        // Quick Open (Cmd+P)
161|9a8f1d|        if editorCore.showQuickOpen {
162|d9eb8b|            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showQuickOpen = false }
163|62e30c|            QuickOpenView(editorCore: editorCore, fileNavigator: fileNavigator)
164|5f3077|        }
165|d6ed84|        
166|2856ba|        // Go To Symbol (Cmd+Shift+O)
167|c17163|        if editorCore.showGoToSymbol {
168|214cc3|            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToSymbol = false }
169|57385e|            GoToSymbolView(editorCore: editorCore, onGoToLine: { _ in })
170|5f3077|        }
171|d6ed84|        
172|b06d36|        // AI Assistant
173|abaf03|        if editorCore.showAIAssistant {
174|061224|            HStack { Spacer(); AIAssistantView(editorCore: editorCore).frame(width: 400, height: 500).padding() }
175|5f3077|        }
176|d6ed84|        
177|2f999e|        // Go To Line (Ctrl+G)
178|2e5673|        if editorCore.showGoToLine {
179|d8005e|            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToLine = false }
180|17e481|            GoToLineView(isPresented: $editorCore.showGoToLine, onGoToLine: { _ in })
181|5f3077|        }
182|d6ed84|        
183|48bb71|        // Workspace Trust Dialog
184|74336b|        if let trustURL = pendingTrustURL {
185|cbd54a|            Color.black.opacity(0.4).ignoresSafeArea()
186|ab1b6f|            WorkspaceTrustDialog(workspaceURL: trustURL, onTrust: {
187|5c6143|                trustManager.trust(url: trustURL)
188|b27193|                finishOpeningWorkspace(trustURL)
189|12fdc5|                pendingTrustURL = nil
190|b37f06|            }, onCancel: {
191|12fdc5|                pendingTrustURL = nil
192|2df177|            })
193|5f3077|        }
194|d6ed84|        
195|5db4d3|        // Keyboard Shortcuts sheet
196|dc1126|        EmptyView()
197|7fd1ec|            .sheet(isPresented: $editorCore.showKeyboardShortcuts) {
198|e1555f|                KeyboardShortcutsView()
199|a7dc16|            }
200|27e597|    }
201|b4687f|    
202|231605|    private func finishOpeningWorkspace(_ url: URL) {
203|6dcdb7|        fileNavigator.loadFileTree(at: url)
204|d79336|        Task { @MainActor in
205|99e24e|            LaunchManager.shared.setWorkspaceRoot(url)
206|eccbe2|            GitManager.shared.setWorkingDirectory(url)
207|5f3077|        }
208|27e597|    }
209|b4687f|    
210|65a033|    private func updateWindowTitle() {
211|53ad0a|        if let activeTab = editorCore.activeTab {
212|ba8861|            let fileName = activeTab.fileName
213|b072a0|            let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
214|741609|            windowTitle = "\(unsavedIndicator)\(fileName) - VS Code"
215|59ea7f|        } else if !editorCore.tabs.isEmpty {
216|fa7eae|            windowTitle = "VS Code"
217|b31999|        } else {
218|6c3506|            windowTitle = "Welcome - VS Code"
219|5f3077|        }
220|d6ed84|        
221|c675c5|        // Notify the app of the title change
222|63edcc|        NotificationCenter.default.post(
223|9251fc|            name: NSNotification.Name("WindowTitleDidChange"),
224|33f159|            object: nil,
225|332f22|            userInfo: ["title": windowTitle]
226|3143a4|        )
227|27e597|    }
228|b4687f|    
229|ab06c2|    @ViewBuilder
230|0bbc6d|    private var sidebarContent: some View {
231|34711c|        switch selectedSidebarTab {
232|ab83f1|        case 0:
233|161f7c|            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
234|032375|        case 1:
235|19e3bd|            SidebarSearchView(theme: theme)
236|12d44a|        case 2:
237|7fc3ae|            GitView()
238|1a2232|        case 3:
239|7116ef|            DebugView()
240|520b7d|        default:
241|161f7c|            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
242|5f3077|        }
243|27e597|    }
244|b31277|}
245|adc83b|
246|6fd553|// MARK: - Activity Bar
247|adc83b|
248|adc83b|
249|adc83b|
250|4a910a|struct BarButton: View {




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 251-500 of 1407)
────────────────────────────────────────
251|f0e87a|    let icon: String
252|055123|    let isSelected: Bool
253|6b0e55|    let theme: Theme
254|59027a|    let action: () -> Void
255|b4687f|    
256|504e43|    var body: some View {
257|6f04d8|        Button(action: action) {
258|ed6617|            Image(systemName: icon)
259|13a7f6|                .font(.system(size: 22))
260|557f46|                .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
261|c81e69|                .frame(width: 48, height: 48)
262|5f3077|        }
263|27e597|    }
264|b31277|}
265|adc83b|
266|2f1081|// MARK: - Sidebar with Real File System
267|adc83b|
268|77668e|struct IDESidebarFiles: View {
269|e5f895|    @ObservedObject var editorCore: EditorCore
270|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
271|fe002a|    @Binding var showFolderPicker: Bool
272|6b0e55|    let theme: Theme
273|b4687f|    
274|504e43|    var body: some View {
275|0865e6|        VStack(alignment: .leading, spacing: 0) {
276|f49fd2|            HStack {
277|8f10b4|                Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
278|a02350|                Spacer()
279|124c35|                Button(action: { showFolderPicker = true }) {
280|98d029|                    Image(systemName: "folder.badge.plus").font(.caption)
281|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
282|035054|                Button(action: { editorCore.showFilePicker = true }) {
283|e2bf82|                    Image(systemName: "doc.badge.plus").font(.caption)
284|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
285|eaa303|                if fileNavigator.fileTree != nil {
286|a67875|                    Button(action: { fileNavigator.refreshFileTree() }) {
287|7cfff4|                        Image(systemName: "arrow.clockwise").font(.caption)
288|681233|                    }.foregroundColor(theme.sidebarForeground.opacity(0.7))
289|4e2d32|                }
290|5cbd4e|            }.padding(.horizontal, 12).padding(.vertical, 8)
291|3070d1|            
292|6b85db|            ScrollView {
293|492557|                VStack(alignment: .leading, spacing: 2) {
294|5cce6c|                    if let tree = fileNavigator.fileTree {
295|46c9f4|                        FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
296|540066|                    } else {
297|b9326c|                        DemoFileTree(editorCore: editorCore, theme: theme)
298|c9717a|                    }
299|d407ec|                }.padding(.horizontal, 8)
300|a7dc16|            }
301|ea6339|        }.background(theme.sidebarBackground)
302|27e597|    }
303|b31277|}
304|adc83b|
305|2efb89|struct RealFileTreeView: View {
306|7345b3|    let node: FileTreeNode
307|ded86f|    let level: Int
308|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
309|e5f895|    @ObservedObject var editorCore: EditorCore
310|6b0e55|    let theme: Theme
311|b4687f|    
312|17d62f|    var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
313|b4687f|    
314|504e43|    var body: some View {
315|ea9354|        VStack(alignment: .leading, spacing: 2) {
316|37f526|            HStack(spacing: 4) {
317|a37387|                if node.isDirectory {
318|440597|                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
319|8aec79|                        .font(.caption2).frame(width: 12)
320|0b3717|                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
321|740862|                        .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
322|fdd0e2|                } else {
323|df77cf|                    Spacer().frame(width: 12)
324|4e2d32|                }
325|bf729b|                Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
326|8237e3|                    .font(.caption)
327|a7e98c|                    .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
328|926090|                Text(node.name).font(.system(.caption)).lineLimit(1)
329|985367|                    .foregroundColor(theme.sidebarForeground)
330|a02350|                Spacer()
331|a7dc16|            }
332|f3d9fb|            .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
333|68d57d|            .contentShape(Rectangle())
334|835ded|            .onTapGesture {
335|a37387|                if node.isDirectory {
336|8f26cf|                    fileNavigator.toggleExpanded(path: node.url.path)
337|fdd0e2|                } else {
338|13e765|                    editorCore.openFile(from: node.url)
339|4e2d32|                }
340|a7dc16|            }
341|3070d1|            
342|dd4b6d|            if isExpanded && node.isDirectory {
343|4a6742|                ForEach(node.children) { child in
344|8deaf6|                    RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
345|4e2d32|                }
346|a7dc16|            }
347|5f3077|        }
348|27e597|    }
349|b31277|}
350|adc83b|
351|c7c785|struct DemoFileTree: View {
352|e5f895|    @ObservedObject var editorCore: EditorCore
353|6b0e55|    let theme: Theme
354|b4687f|    
355|504e43|    var body: some View {
356|478d8c|        VStack(alignment: .leading, spacing: 4) {
357|dca3c9|            Text("Open a folder to browse files")
358|916793|                .font(.caption)
359|417420|                .foregroundColor(theme.sidebarForeground.opacity(0.6))
360|a48a8d|                .padding(.vertical, 8)
361|3070d1|            
362|eead9e|            DemoFileRow(name: "Welcome.swift", editorCore: editorCore, theme: theme)
363|cbcd60|            DemoFileRow(name: "example.js", editorCore: editorCore, theme: theme)
364|0f2913|            DemoFileRow(name: "example.py", editorCore: editorCore, theme: theme)
365|c07fb7|            DemoFileRow(name: "package.json", editorCore: editorCore, theme: theme)
366|d67c95|            DemoFileRow(name: "index.html", editorCore: editorCore, theme: theme)
367|822f11|            DemoFileRow(name: "styles.css", editorCore: editorCore, theme: theme)
368|5f3077|        }
369|27e597|    }
370|b31277|}
371|adc83b|
372|ab28f0|struct DemoFileRow: View {
373|a5193b|    let name: String
374|e5f895|    @ObservedObject var editorCore: EditorCore
375|6b0e55|    let theme: Theme
376|b4687f|    
377|504e43|    var body: some View {
378|b120fa|        HStack(spacing: 4) {
379|5a4821|            Spacer().frame(width: 12)
380|5a9b2c|            Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
381|0ffef7|            Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
382|1e6289|            Spacer()
383|5f3077|        }
384|60e15e|        .padding(.vertical, 4)
385|55e29b|        .contentShape(Rectangle())
386|cf12c6|        .onTapGesture {
387|9f9063|            if let tab = editorCore.tabs.first(where: { $0.fileName == name }) {
388|166be5|                editorCore.selectTab(id: tab.id)
389|a7dc16|            }
390|5f3077|        }
391|27e597|    }
392|b31277|}
393|adc83b|
394|f3aab4|// MARK: - Tab Bar
395|adc83b|
396|24d9d9|struct IDETabBar: View {
397|e5f895|    @ObservedObject var editorCore: EditorCore
398|6b0e55|    let theme: Theme
399|b4687f|    
400|504e43|    var body: some View {
401|98ab70|        ScrollView(.horizontal, showsIndicators: false) {
402|3b7550|            HStack(spacing: 0) {
403|7512d8|                ForEach(editorCore.tabs) { tab in
404|4b4bd2|                    IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
405|4e2d32|                }
406|5de7cd|                Button(action: { editorCore.addTab() }) {
407|fd7d74|                    Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
408|4e2d32|                }
409|30b85f|            }.padding(.horizontal, 4)
410|962d70|        }.frame(height: 36).background(theme.tabBarBackground)
411|27e597|    }
412|b31277|}
413|adc83b|
414|68fbe9|struct IDETabItem: View {
415|4dc199|    let tab: Tab
416|055123|    let isSelected: Bool
417|e5f895|    @ObservedObject var editorCore: EditorCore
418|6b0e55|    let theme: Theme
419|b4687f|    
420|504e43|    var body: some View {
421|e1c66d|        HStack(spacing: 6) {
422|29528a|            Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
423|a9dd8d|            Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
424|d555ba|                .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
425|5029ae|            if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
426|6effb3|            Button(action: { editorCore.closeTab(id: tab.id) }) {
427|f4c72a|                Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
428|041ce7|                    .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
429|a7dc16|            }
430|5f3077|        }
431|2da2e9|        .padding(.horizontal, 12).padding(.vertical, 6)
432|116b54|        .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
433|7a9052|        .onTapGesture { editorCore.selectTab(id: tab.id) }
434|27e597|    }
435|b31277|}
436|adc83b|
437|f95ca3|// MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
438|adc83b|
439|a178f9|struct IDEEditorView: View {
440|e5f895|    @ObservedObject var editorCore: EditorCore
441|4dc199|    let tab: Tab
442|6b0e55|    let theme: Theme
443|b4687f|    
444|129112|    /// Feature flag for Runestone editor - uses centralized FeatureFlags
445|952908|    private var useRunestoneEditor: Bool { FeatureFlags.useRunestoneEditor }
446|adc83b|
447|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
448|eba335|    @State private var text: String = ""
449|4f0ac8|    @State private var scrollPosition: Int = 0
450|36da68|    @State private var scrollOffset: CGFloat = 0
451|d473fd|    @State private var totalLines: Int = 1
452|bcf90b|    @State private var visibleLines: Int = 20
453|9cb5e9|    @State private var currentLineNumber: Int = 1
454|cc347a|    @State private var currentColumn: Int = 1
455|eee196|    @State private var cursorIndex: Int = 0
456|f97bd7|    @State private var lineHeight: CGFloat = 20  // Updated dynamically based on font size
457|446eb9|    @State private var requestedCursorIndex: Int? = nil
458|5c2aeb|    @State private var requestedLineSelection: Int? = nil
459|adc83b|
460|3977e1|    @StateObject private var autocomplete = AutocompleteManager()
461|4445ec|    @State private var showAutocomplete = false
462|f77a99|    // Code folding removed - will use VS Code tunnel for real folding
463|f453fc|    @StateObject private var findViewModel = FindViewModel()
464|b4687f|    
465|504e43|    var body: some View {
466|94dd27|        VStack(spacing: 0) {
467|8779dd|            // Find/Replace bar
468|2b2a70|            if editorCore.showSearch {
469|38cbe4|                FindReplaceView(viewModel: findViewModel)
470|b768ed|                    .background(theme.tabBarBackground)
471|a7dc16|            }
472|3070d1|            
473|b97232|            BreadcrumbsView(editorCore: editorCore, tab: tab)
474|3070d1|            
475|ca6f75|            GeometryReader { geometry in
476|e60c16|                ZStack(alignment: .topLeading) {
477|7a5371|                HStack(spacing: 0) {
478|91f67b|                    // Simple line numbers gutter (folding/breakpoints removed)
479|8d4059|                    if lineNumbersStyle != "off" {
480|682232|                        LineNumbers(
481|937d74|                            totalLines: totalLines,
482|0f00a6|                            currentLine: currentLineNumber,
483|d6742c|                            scrollOffset: scrollOffset,
484|9f4e9f|                            lineHeight: lineHeight,
485|76e9b6|                            requestedLineSelection: $requestedLineSelection,
486|0acd63|                            theme: theme
487|63214b|                        )
488|4619d2|                        .frame(width: 44)
489|3a838d|                        .background(theme.sidebarBackground.opacity(0.5))
490|c9717a|                    }
491|dd2193|                    
492|3f9dab|                    // Use Runestone for all files including JSON (has TreeSitter JSON support)
493|df925c|                    if false && tab.fileName.hasSuffix(".json") {
494|4229a0|                        // JSON Tree View disabled - using Runestone editor instead
495|daf992|                        JSONTreeView(data: text.data(using: .utf8) ?? Data())
496|f9d830|                            .frame(maxWidth: .infinity, maxHeight: .infinity)
497|96e3a5|                            .background(theme.editorBackground)
498|540066|                    } else {
499|082ddd|                        // Use Runestone for O(log n) performance, or legacy view as fallback
500|e44d33|                        Group {




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 501-750 of 1407)
────────────────────────────────────────
501|31b1a0|                            if useRunestoneEditor {
502|40914b|                                RunestoneEditorView(
503|4496ad|                                    text: $text,
504|d36f79|                                    filename: tab.fileName,
505|deb430|                                    scrollOffset: $scrollOffset,
506|2b845b|                                    totalLines: $totalLines,
507|71c5eb|                                    currentLineNumber: $currentLineNumber,
508|872d17|                                    currentColumn: $currentColumn,
509|927813|                                    cursorIndex: $cursorIndex,
510|397368|                                    isActive: true,
511|b41e3e|                                    fontSize: editorCore.editorFontSize,
512|f39601|                                    onAcceptAutocomplete: {
513|35fa15|                                        guard showAutocomplete else { return false }
514|028ab7|                                        var tempText = text
515|4f6f56|                                        var tempCursor = cursorIndex
516|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
517|28278a|                                        if tempText != text {
518|1a390a|                                            text = tempText
519|9a3612|                                            cursorIndex = tempCursor
520|55a703|                                            requestedCursorIndex = tempCursor
521|46924a|                                            showAutocomplete = false
522|e18645|                                            return true
523|eed1d8|                                        }
524|9818dc|                                        return false
525|3cc64b|                                    },
526|7ed733|                                    onDismissAutocomplete: {
527|35fa15|                                        guard showAutocomplete else { return false }
528|fc38c2|                                        autocomplete.hideSuggestions()
529|579f59|                                        showAutocomplete = false
530|c09eb1|                                        return true
531|8ab74d|                                    }
532|58a90d|                                )
533|240f50|                            } else {
534|e97ddb|                                // Legacy SyntaxHighlightingTextView (fallback)
535|27eb3b|                                SyntaxHighlightingTextView(
536|4496ad|                                    text: $text,
537|d36f79|                                    filename: tab.fileName,
538|44ffa0|                                    scrollPosition: $scrollPosition,
539|deb430|                                    scrollOffset: $scrollOffset,
540|2b845b|                                    totalLines: $totalLines,
541|a9b405|                                    visibleLines: $visibleLines,
542|71c5eb|                                    currentLineNumber: $currentLineNumber,
543|872d17|                                    currentColumn: $currentColumn,
544|927813|                                    cursorIndex: $cursorIndex,
545|31e938|                                    lineHeight: $lineHeight,
546|397368|                                    isActive: true,
547|b41e3e|                                    fontSize: editorCore.editorFontSize,
548|193919|                                    requestedLineSelection: $requestedLineSelection,
549|70abf8|                                    requestedCursorIndex: $requestedCursorIndex,
550|f39601|                                    onAcceptAutocomplete: {
551|35fa15|                                        guard showAutocomplete else { return false }
552|028ab7|                                        var tempText = text
553|4f6f56|                                        var tempCursor = cursorIndex
554|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
555|28278a|                                        if tempText != text {
556|1a390a|                                            text = tempText
557|9a3612|                                            cursorIndex = tempCursor
558|55a703|                                            requestedCursorIndex = tempCursor
559|46924a|                                            showAutocomplete = false
560|e18645|                                            return true
561|eed1d8|                                        }
562|9818dc|                                        return false
563|3cc64b|                                    },
564|7ed733|                                    onDismissAutocomplete: {
565|35fa15|                                        guard showAutocomplete else { return false }
566|fc38c2|                                        autocomplete.hideSuggestions()
567|579f59|                                        showAutocomplete = false
568|c09eb1|                                        return true
569|8ab74d|                                    }
570|58a90d|                                )
571|89d40a|                            }
572|392b35|                        }
573|23a7d6|                        .onChange(of: text) { newValue in
574|c2cbfa|                            editorCore.updateActiveTabContent(newValue)
575|ca5c5e|                            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
576|2d6cfb|                            autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
577|5db623|                            showAutocomplete = autocomplete.showSuggestions
578|1bd01f|                            // Folding removed - using VS Code tunnel for real folding
579|392b35|                        }
580|ae1be2|                        .onChange(of: cursorIndex) { newCursor in
581|017a4d|                            autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
582|5db623|                            showAutocomplete = autocomplete.showSuggestions
583|392b35|                        }
584|c9717a|                    }
585|dd2193|                    
586|0fbe94|                    if !tab.fileName.hasSuffix(".json") {
587|d0a712|                        MinimapView(
588|234a10|                            content: text,
589|d6742c|                            scrollOffset: scrollOffset,
590|9a8bd2|                            scrollViewHeight: geometry.size.height,
591|29b4a2|                            totalContentHeight: CGFloat(totalLines) * lineHeight,
592|83e3c8|                            onScrollRequested: { newOffset in
593|c2e825|                                // Minimap requested scroll - update editor position
594|d09b41|                                scrollOffset = newOffset
595|af41de|                                // Convert back from pixels to line number
596|6ad0f0|                                let newLine = Int(newOffset / max(lineHeight, 1))
597|ec5b45|                                scrollPosition = max(0, min(newLine, totalLines - 1))
598|89d40a|                            }
599|63214b|                        )
600|abeec0|                        .frame(width: 80)
601|c9717a|                    }
602|4e2d32|                }
603|3bc2db|                .background(theme.editorBackground)
604|adc83b|
605|cf06bf|                // Sticky Header Overlay (FEAT-040)
606|d5af46|                StickyHeaderView(
607|c24fd5|                    text: text,
608|f49254|                    currentLine: scrollPosition,
609|f7b7a6|                    theme: theme,
610|8e60a5|                    lineHeight: lineHeight,
611|9628b3|                    onSelect: { line in
612|df068a|                        requestedLineSelection = line
613|c9717a|                    }
614|6f642e|                )
615|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
616|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
617|adc83b|
618|0f82df|                // Inlay Hints Overlay (type hints, parameter names)
619|a8bcb0|                InlayHintsOverlay(
620|0fb212|                    code: text,
621|5f8f93|                    language: tab.language,
622|23acb0|                    scrollPosition: scrollPosition,
623|8e60a5|                    lineHeight: lineHeight,
624|0e3ffc|                    fontSize: editorCore.editorFontSize,
625|a63927|                    gutterWidth: (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0,
626|088baa|                    rightReservedWidth: tab.fileName.hasSuffix(".json") ? 0 : 80
627|6f642e|                )
628|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
629|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
630|8eef2d|                if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
631|baeb3a|                    AutocompletePopup(
632|83a4b0|                        suggestions: autocomplete.suggestionItems,
633|53da2f|                        selectedIndex: autocomplete.selectedIndex,
634|5db55c|                        theme: theme
635|82606a|                    ) { index in
636|3a2861|                        autocomplete.selectedIndex = index
637|9c12a8|                        var tempText = text
638|f02eb3|                        var tempCursor = cursorIndex
639|7fdc0e|                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
640|326231|                        if tempText != text {
641|d7f8a5|                            text = tempText
642|34aa29|                            cursorIndex = tempCursor
643|d3d820|                            requestedCursorIndex = tempCursor
644|392b35|                        }
645|2411d0|                        showAutocomplete = false
646|c9717a|                    }
647|58a34b|                    .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
648|4e2d32|                }
649|a7dc16|            }
650|5f3077|        }
651|5f3077|        }
652|2bd24e|        .onAppear {
653|ba85f8|            text = tab.content
654|8e600f|            // Folding detection removed
655|5f3077|        }
656|9d97c0|        .onChange(of: tab.id) { _ in
657|ba85f8|            text = tab.content
658|8e600f|            // Folding detection removed
659|5f3077|        }
660|d3345e|        .onChange(of: currentLineNumber) { line in
661|3384f8|            editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
662|5f3077|        }
663|588fd8|        .onChange(of: currentColumn) { col in
664|16524d|            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
665|5f3077|        }
666|75807d|        .onChange(of: editorCore.editorFontSize) { newSize in
667|494152|            // Update lineHeight to match Runestone's line height (~1.4x font size)
668|4f8334|            lineHeight = ceil(newSize * 1.4)
669|5f3077|        }
670|2bd24e|        .onAppear {
671|c916b3|            findViewModel.editorCore = editorCore
672|3e3b84|            // Set initial lineHeight based on font size
673|a33db3|            lineHeight = ceil(editorCore.editorFontSize * 1.4)
674|5f3077|        }
675|27e597|    }
676|b4687f|    
677|a19e38|    // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
678|b31277|}
679|adc83b|
680|e7208c|// MARK: - Line Numbers (Simple)
681|adc83b|
682|91f1f4|struct LineNumbers: View {
683|cdda83|    let totalLines: Int
684|c75d8a|    let currentLine: Int
685|5b2177|    let scrollOffset: CGFloat
686|96ac71|    let lineHeight: CGFloat
687|86829b|    @Binding var requestedLineSelection: Int?
688|6b0e55|    let theme: Theme
689|adc83b|
690|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
691|adc83b|
692|504e43|    var body: some View {
693|ca170c|        ScrollView(showsIndicators: false) {
694|829de3|            VStack(alignment: .trailing, spacing: 0) {
695|227120|                ForEach(0..<totalLines, id: \.self) { lineIndex in
696|d47566|                    Text(displayText(for: lineIndex))
697|67dec4|                        .font(.system(size: 12, design: .monospaced))
698|383a9d|                        .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
699|228b93|                        .frame(height: lineHeight)
700|729aac|                        .frame(maxWidth: .infinity, alignment: .trailing)
701|539a79|                        .padding(.trailing, 4)
702|aec4a4|                        .contentShape(Rectangle())
703|23c196|                        .onTapGesture {
704|f3678b|                            requestedLineSelection = lineIndex
705|392b35|                        }
706|4e2d32|                }
707|a7dc16|            }
708|5f0534|            .padding(.top, 8)
709|873abc|            .offset(y: -scrollOffset)
710|5f3077|        }
711|c059d6|        .scrollDisabled(true)
712|27e597|    }
713|adc83b|
714|46d3db|    private func displayText(for lineIndex: Int) -> String {
715|5d97cf|        switch lineNumbersStyle {
716|a6eb36|        case "relative":
717|b0622f|            let lineNumber = lineIndex + 1
718|44bb33|            if lineNumber == currentLine { return "\(lineNumber)" }
719|5e67df|            return "\(abs(lineNumber - currentLine))"
720|adc83b|
721|5040ac|        case "interval":
722|b0622f|            let lineNumber = lineIndex + 1
723|bc3fe3|            return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
724|adc83b|
725|520b7d|        default:
726|3880c0|            return "\(lineIndex + 1)"
727|5f3077|        }
728|27e597|    }
729|b31277|}
730|adc83b|
731|e3bdd2|// MARK: - Autocomplete Popup
732|adc83b|
733|b1d20a|struct AutocompletePopup: View {
734|5eb9d3|    let suggestions: [AutocompleteSuggestion]
735|79c1fc|    let selectedIndex: Int
736|6b0e55|    let theme: Theme
737|6f35cf|    let onSelectIndex: (Int) -> Void
738|b4687f|    
739|504e43|    var body: some View {
740|0865e6|        VStack(alignment: .leading, spacing: 0) {
741|a954be|            ForEach(suggestions.indices, id: \.self) { index in
742|ad513b|                let s = suggestions[index]
743|dbadc1|                HStack(spacing: 6) {
744|fcd45a|                    Image(systemName: icon(for: s.kind))
745|cdb0af|                        .font(.caption)
746|2e9202|                        .foregroundColor(color(for: s.kind))
747|288999|                    VStack(alignment: .leading, spacing: 1) {
748|3d1271|                        Text(s.displayText)
749|09bbe1|                            .font(.system(size: 12, design: .monospaced))
750|239e62|                            .foregroundColor(theme.editorForeground)




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 751-1000 of 1407)
────────────────────────────────────────
751|71c2b3|                        if s.insertText != s.displayText && !s.insertText.isEmpty {
752|53d416|                            Text(s.insertText)
753|87ab4e|                                .font(.system(size: 10, design: .monospaced))
754|32bc5b|                                .foregroundColor(theme.editorForeground.opacity(0.55))
755|a9b5f4|                                .lineLimit(1)
756|392b35|                        }
757|c9717a|                    }
758|dcd0bf|                    Spacer()
759|4e2d32|                }
760|41847e|                .padding(.horizontal, 8).padding(.vertical, 6)
761|e72d30|                .background(index == selectedIndex ? theme.selection : Color.clear)
762|1e8a31|                .contentShape(Rectangle())
763|eec06d|                .onTapGesture { onSelectIndex(index) }
764|a7dc16|            }
765|5f3077|        }
766|5260c9|        .frame(width: 260)
767|04ec17|        .background(theme.editorBackground)
768|097147|        .cornerRadius(6)
769|f64ce1|        .shadow(radius: 8)
770|27e597|    }
771|b4687f|    
772|ccd198|    private func icon(for kind: AutocompleteSuggestionKind) -> String {
773|01fe0f|        switch kind {
774|62a12d|        case .keyword: return "key.fill"
775|710dbd|        case .symbol: return "cube.fill"
776|d0a8ab|        case .stdlib: return "curlybraces"
777|c3ed81|        case .member: return "arrow.right.circle.fill"
778|5f3077|        }
779|27e597|    }
780|b4687f|    
781|126b1f|    private func color(for kind: AutocompleteSuggestionKind) -> Color {
782|01fe0f|        switch kind {
783|a51b30|        case .keyword: return .purple
784|8740a1|        case .symbol: return .blue
785|628567|        case .stdlib: return .orange
786|b8e5e8|        case .member: return .green
787|5f3077|        }
788|27e597|    }
789|b31277|}
790|adc83b|
791|4409de|// MARK: - Welcome View
792|adc83b|
793|35ff8c|struct IDEWelcomeView: View {
794|e5f895|    @ObservedObject var editorCore: EditorCore
795|7d30ad|    @ObservedObject var recentFiles: RecentFileManager = .shared
796|fe002a|    @Binding var showFolderPicker: Bool
797|6b0e55|    let theme: Theme
798|b4687f|    
799|504e43|    var body: some View {
800|4d4b46|        ScrollView {
801|92175e|            VStack(spacing: 0) {
802|8ceded|                Spacer().frame(height: 60)
803|216278|                
804|0a052f|                // Logo & Title
805|6194f8|                VStack(spacing: 12) {
806|28467a|                    Image(systemName: "chevron.left.forwardslash.chevron.right")
807|20375b|                        .font(.system(size: 64, weight: .thin))
808|da2fcc|                        .foregroundColor(.accentColor.opacity(0.7))
809|af291e|                    Text("VS Code for iPadOS")
810|331176|                        .font(.system(size: 28, weight: .bold))
811|49a616|                        .foregroundColor(theme.editorForeground)
812|d68666|                    Text("Code anywhere. Build anything.")
813|e4008e|                        .font(.system(size: 14))
814|c9c92a|                        .foregroundColor(theme.editorForeground.opacity(0.5))
815|4e2d32|                }
816|9e1451|                .padding(.bottom, 40)
817|216278|                
818|38781d|                // Main content in columns
819|1ff7c7|                HStack(alignment: .top, spacing: 48) {
820|7da568|                    // Left: Start actions
821|f38358|                    VStack(alignment: .leading, spacing: 16) {
822|97a3c6|                        Text("Start")
823|1a45a2|                            .font(.system(size: 13, weight: .semibold))
824|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
825|d4034e|                            .textCase(.uppercase)
826|956cfe|                        
827|3e5f33|                        WelcomeLink(icon: "doc.badge.plus", title: "New File", shortcut: "\u{2318}N", theme: theme) { editorCore.addTab() }
828|ff3de3|                        WelcomeLink(icon: "folder", title: "Open Folder...", shortcut: "\u{2318}\u{21E7}O", theme: theme) { showFolderPicker = true }
829|af22ad|                        WelcomeLink(icon: "doc", title: "Open File...", shortcut: "\u{2318}O", theme: theme) { editorCore.showFilePicker = true }
830|7f563b|                        WelcomeLink(icon: "arrow.triangle.branch", title: "Clone Repository...", shortcut: nil, theme: theme) { }
831|c6b72d|                        WelcomeLink(icon: "network", title: "Connect to SSH Host...", shortcut: nil, theme: theme) { }
832|c9717a|                    }
833|a50e8e|                    .frame(width: 260)
834|dd2193|                    
835|fb6ef7|                    // Center: Recent
836|f38358|                    VStack(alignment: .leading, spacing: 16) {
837|09b581|                        Text("Recent")
838|1a45a2|                            .font(.system(size: 13, weight: .semibold))
839|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
840|d4034e|                            .textCase(.uppercase)
841|956cfe|                        
842|2dfdd3|                        if recentFiles.recentFiles.isEmpty {
843|2c0bc4|                            Text("No recent files")
844|f4b380|                                .font(.system(size: 13))
845|1df1cd|                                .foregroundColor(theme.editorForeground.opacity(0.3))
846|ebe48f|                                .padding(.vertical, 8)
847|65e2f4|                        } else {
848|3121b3|                            ForEach(recentFiles.recentFiles.prefix(8), id: \.absoluteString) { url in
849|859ef8|                                Button(action: {
850|2e44f8|                                    editorCore.addTab(fileName: url.lastPathComponent, content: "", url: url)
851|a37f0c|                                }) {
852|0334d4|                                    HStack(spacing: 8) {
853|a7ba40|                                        Image(systemName: url.hasDirectoryPath ? "folder.fill" : "doc.fill")
854|d6fd17|                                            .font(.system(size: 12))
855|16ab52|                                            .foregroundColor(.accentColor)
856|62f5b3|                                            .frame(width: 16)
857|e9d9bf|                                        VStack(alignment: .leading, spacing: 1) {
858|2f3f86|                                            Text(url.lastPathComponent)
859|351a6d|                                                .font(.system(size: 13))
860|fd3cf9|                                                .foregroundColor(.accentColor)
861|ebf583|                                                .lineLimit(1)
862|71fb92|                                            Text(url.deletingLastPathComponent().path)
863|c2a1f5|                                                .font(.system(size: 10))
864|4dacfc|                                                .foregroundColor(theme.editorForeground.opacity(0.4))
865|ebf583|                                                .lineLimit(1)
866|eed1d8|                                        }
867|8ab74d|                                    }
868|f83e05|                                }
869|31bef9|                                .buttonStyle(.plain)
870|89d40a|                            }
871|392b35|                        }
872|c9717a|                    }
873|ac3576|                    .frame(width: 280)
874|dd2193|                    
875|74716b|                    // Right: Help & Tips
876|f38358|                    VStack(alignment: .leading, spacing: 16) {
877|f992df|                        Text("Help")
878|1a45a2|                            .font(.system(size: 13, weight: .semibold))
879|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
880|d4034e|                            .textCase(.uppercase)
881|956cfe|                        
882|c46faa|                        WelcomeLink(icon: "terminal", title: "Command Palette", shortcut: "\u{2318}\u{21E7}P", theme: theme) { editorCore.showCommandPalette = true }
883|f1821e|                        WelcomeLink(icon: "keyboard", title: "Keyboard Shortcuts", shortcut: nil, theme: theme) { editorCore.showKeyboardShortcuts = true }
884|149497|                        WelcomeLink(icon: "gear", title: "Settings", shortcut: "\u{2318},", theme: theme) {
885|6da7e1|                            NotificationCenter.default.post(name: .init("ShowSettings"), object: nil)
886|392b35|                        }
887|956cfe|                        
888|c0a3dd|                        Divider().padding(.vertical, 4)
889|956cfe|                        
890|f3e0be|                        Text("Tips")
891|1a45a2|                            .font(.system(size: 13, weight: .semibold))
892|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
893|d4034e|                            .textCase(.uppercase)
894|956cfe|                        
895|db141c|                        WelcomeTip(icon: "sparkles", text: "Use \u{2318}\u{21E7}A to open the AI assistant", theme: theme)
896|0714f5|                        WelcomeTip(icon: "sidebar.left", text: "\u{2318}B toggles the sidebar", theme: theme)
897|91e7bb|                        WelcomeTip(icon: "magnifyingglass", text: "\u{2318}\u{21E7}F searches across all files", theme: theme)
898|6bf5fa|                        WelcomeTip(icon: "arrow.triangle.branch", text: "Built-in Git with native Swift implementation", theme: theme)
899|c9717a|                    }
900|ac3576|                    .frame(width: 280)
901|4e2d32|                }
902|3570a8|                .padding(.horizontal, 40)
903|216278|                
904|8ceded|                Spacer().frame(height: 60)
905|a7dc16|            }
906|9a9c46|            .frame(maxWidth: .infinity)
907|5f3077|        }
908|04ec17|        .background(theme.editorBackground)
909|27e597|    }
910|b31277|}
911|adc83b|
912|24ea2a|struct WelcomeLink: View {
913|f0e87a|    let icon: String
914|399f36|    let title: String
915|265a5c|    let shortcut: String?
916|6b0e55|    let theme: Theme
917|59027a|    let action: () -> Void
918|b4687f|    
919|6d2ac2|    @State private var isHovering = false
920|b4687f|    
921|504e43|    var body: some View {
922|6f04d8|        Button(action: action) {
923|c0775d|            HStack(spacing: 8) {
924|7b64f6|                Image(systemName: icon)
925|9c904b|                    .font(.system(size: 13))
926|153725|                    .foregroundColor(.accentColor)
927|688547|                    .frame(width: 20)
928|3f8b13|                Text(title)
929|9c904b|                    .font(.system(size: 13))
930|153725|                    .foregroundColor(.accentColor)
931|e1df7b|                if let shortcut = shortcut {
932|dcd0bf|                    Spacer()
933|5e6df6|                    Text(shortcut)
934|1057c9|                        .font(.system(size: 11, design: .rounded))
935|40df1e|                        .foregroundColor(theme.editorForeground.opacity(0.35))
936|4e2d32|                }
937|a7dc16|            }
938|ec0aa4|            .padding(.vertical, 3)
939|68d57d|            .contentShape(Rectangle())
940|5f3077|        }
941|bd8b70|        .buttonStyle(.plain)
942|c115d3|        .onHover { isHovering = $0 }
943|17fe31|        .opacity(isHovering ? 0.8 : 1.0)
944|27e597|    }
945|b31277|}
946|adc83b|
947|bb22f9|struct WelcomeTip: View {
948|f0e87a|    let icon: String
949|e25e12|    let text: String
950|6b0e55|    let theme: Theme
951|b4687f|    
952|504e43|    var body: some View {
953|d6296b|        HStack(spacing: 8) {
954|ed6617|            Image(systemName: icon)
955|a7de34|                .font(.system(size: 11))
956|195e4d|                .foregroundColor(theme.editorForeground.opacity(0.4))
957|c404e7|                .frame(width: 16)
958|6a8caf|            Text(text)
959|ee466d|                .font(.system(size: 12))
960|904c91|                .foregroundColor(theme.editorForeground.opacity(0.5))
961|5f3077|        }
962|27e597|    }
963|b31277|}
964|adc83b|
965|4b4130|struct WelcomeBtn: View {
966|f0e87a|    let icon: String
967|399f36|    let title: String
968|14874c|    let shortcut: String
969|6b0e55|    let theme: Theme
970|59027a|    let action: () -> Void
971|b4687f|    
972|504e43|    var body: some View {
973|6f04d8|        Button(action: action) {
974|f49fd2|            HStack {
975|f2b865|                Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
976|d34e42|                Text(title).foregroundColor(theme.editorForeground)
977|a02350|                Spacer()
978|0f9490|                Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
979|a7dc16|            }
980|a09f6b|            .padding().frame(width: 280)
981|cef0ad|            .background(theme.sidebarBackground)
982|b18c2b|            .cornerRadius(8)
983|9e9bdf|        }.buttonStyle(.plain)
984|27e597|    }
985|b31277|}
986|adc83b|
987|db0271|// MARK: - Command Palette
988|adc83b|
989|e71bec|struct IDECommandPalette: View {
990|e5f895|    @ObservedObject var editorCore: EditorCore
991|3bd3a7|    @Binding var showSettings: Bool
992|fe5153|    @Binding var showTerminal: Bool
993|d901da|    @State private var searchText = ""
994|b4687f|    
995|504e43|    var body: some View {
996|94dd27|        VStack(spacing: 0) {
997|f49fd2|            HStack {
998|41b09a|                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
999|259764|                TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
1000|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 501-750 of 1407)
────────────────────────────────────────
501|31b1a0|                            if useRunestoneEditor {
502|40914b|                                RunestoneEditorView(
503|4496ad|                                    text: $text,
504|d36f79|                                    filename: tab.fileName,
505|deb430|                                    scrollOffset: $scrollOffset,
506|2b845b|                                    totalLines: $totalLines,
507|71c5eb|                                    currentLineNumber: $currentLineNumber,
508|872d17|                                    currentColumn: $currentColumn,
509|927813|                                    cursorIndex: $cursorIndex,
510|397368|                                    isActive: true,
511|b41e3e|                                    fontSize: editorCore.editorFontSize,
512|f39601|                                    onAcceptAutocomplete: {
513|35fa15|                                        guard showAutocomplete else { return false }
514|028ab7|                                        var tempText = text
515|4f6f56|                                        var tempCursor = cursorIndex
516|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
517|28278a|                                        if tempText != text {
518|1a390a|                                            text = tempText
519|9a3612|                                            cursorIndex = tempCursor
520|55a703|                                            requestedCursorIndex = tempCursor
521|46924a|                                            showAutocomplete = false
522|e18645|                                            return true
523|eed1d8|                                        }
524|9818dc|                                        return false
525|3cc64b|                                    },
526|7ed733|                                    onDismissAutocomplete: {
527|35fa15|                                        guard showAutocomplete else { return false }
528|fc38c2|                                        autocomplete.hideSuggestions()
529|579f59|                                        showAutocomplete = false
530|c09eb1|                                        return true
531|8ab74d|                                    }
532|58a90d|                                )
533|240f50|                            } else {
534|e97ddb|                                // Legacy SyntaxHighlightingTextView (fallback)
535|27eb3b|                                SyntaxHighlightingTextView(
536|4496ad|                                    text: $text,
537|d36f79|                                    filename: tab.fileName,
538|44ffa0|                                    scrollPosition: $scrollPosition,
539|deb430|                                    scrollOffset: $scrollOffset,
540|2b845b|                                    totalLines: $totalLines,
541|a9b405|                                    visibleLines: $visibleLines,
542|71c5eb|                                    currentLineNumber: $currentLineNumber,
543|872d17|                                    currentColumn: $currentColumn,
544|927813|                                    cursorIndex: $cursorIndex,
545|31e938|                                    lineHeight: $lineHeight,
546|397368|                                    isActive: true,
547|b41e3e|                                    fontSize: editorCore.editorFontSize,
548|193919|                                    requestedLineSelection: $requestedLineSelection,
549|70abf8|                                    requestedCursorIndex: $requestedCursorIndex,
550|f39601|                                    onAcceptAutocomplete: {
551|35fa15|                                        guard showAutocomplete else { return false }
552|028ab7|                                        var tempText = text
553|4f6f56|                                        var tempCursor = cursorIndex
554|93d70e|                                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
555|28278a|                                        if tempText != text {
556|1a390a|                                            text = tempText
557|9a3612|                                            cursorIndex = tempCursor
558|55a703|                                            requestedCursorIndex = tempCursor
559|46924a|                                            showAutocomplete = false
560|e18645|                                            return true
561|eed1d8|                                        }
562|9818dc|                                        return false
563|3cc64b|                                    },
564|7ed733|                                    onDismissAutocomplete: {
565|35fa15|                                        guard showAutocomplete else { return false }
566|fc38c2|                                        autocomplete.hideSuggestions()
567|579f59|                                        showAutocomplete = false
568|c09eb1|                                        return true
569|8ab74d|                                    }
570|58a90d|                                )
571|89d40a|                            }
572|392b35|                        }
573|23a7d6|                        .onChange(of: text) { newValue in
574|c2cbfa|                            editorCore.updateActiveTabContent(newValue)
575|ca5c5e|                            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
576|2d6cfb|                            autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
577|5db623|                            showAutocomplete = autocomplete.showSuggestions
578|1bd01f|                            // Folding removed - using VS Code tunnel for real folding
579|392b35|                        }
580|ae1be2|                        .onChange(of: cursorIndex) { newCursor in
581|017a4d|                            autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
582|5db623|                            showAutocomplete = autocomplete.showSuggestions
583|392b35|                        }
584|c9717a|                    }
585|dd2193|                    
586|0fbe94|                    if !tab.fileName.hasSuffix(".json") {
587|d0a712|                        MinimapView(
588|234a10|                            content: text,
589|d6742c|                            scrollOffset: scrollOffset,
590|9a8bd2|                            scrollViewHeight: geometry.size.height,
591|29b4a2|                            totalContentHeight: CGFloat(totalLines) * lineHeight,
592|83e3c8|                            onScrollRequested: { newOffset in
593|c2e825|                                // Minimap requested scroll - update editor position
594|d09b41|                                scrollOffset = newOffset
595|af41de|                                // Convert back from pixels to line number
596|6ad0f0|                                let newLine = Int(newOffset / max(lineHeight, 1))
597|ec5b45|                                scrollPosition = max(0, min(newLine, totalLines - 1))
598|89d40a|                            }
599|63214b|                        )
600|abeec0|                        .frame(width: 80)
601|c9717a|                    }
602|4e2d32|                }
603|3bc2db|                .background(theme.editorBackground)
604|adc83b|
605|cf06bf|                // Sticky Header Overlay (FEAT-040)
606|d5af46|                StickyHeaderView(
607|c24fd5|                    text: text,
608|f49254|                    currentLine: scrollPosition,
609|f7b7a6|                    theme: theme,
610|8e60a5|                    lineHeight: lineHeight,
611|9628b3|                    onSelect: { line in
612|df068a|                        requestedLineSelection = line
613|c9717a|                    }
614|6f642e|                )
615|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
616|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
617|adc83b|
618|0f82df|                // Inlay Hints Overlay (type hints, parameter names)
619|a8bcb0|                InlayHintsOverlay(
620|0fb212|                    code: text,
621|5f8f93|                    language: tab.language,
622|23acb0|                    scrollPosition: scrollPosition,
623|8e60a5|                    lineHeight: lineHeight,
624|0e3ffc|                    fontSize: editorCore.editorFontSize,
625|a63927|                    gutterWidth: (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0,
626|088baa|                    rightReservedWidth: tab.fileName.hasSuffix(".json") ? 0 : 80
627|6f642e|                )
628|a9b95c|                .padding(.leading, (lineNumbersStyle != "off" && !useRunestoneEditor) ? 60 : 0)
629|a079a8|                .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
630|8eef2d|                if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
631|baeb3a|                    AutocompletePopup(
632|83a4b0|                        suggestions: autocomplete.suggestionItems,
633|53da2f|                        selectedIndex: autocomplete.selectedIndex,
634|5db55c|                        theme: theme
635|82606a|                    ) { index in
636|3a2861|                        autocomplete.selectedIndex = index
637|9c12a8|                        var tempText = text
638|f02eb3|                        var tempCursor = cursorIndex
639|7fdc0e|                        autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
640|326231|                        if tempText != text {
641|d7f8a5|                            text = tempText
642|34aa29|                            cursorIndex = tempCursor
643|d3d820|                            requestedCursorIndex = tempCursor
644|392b35|                        }
645|2411d0|                        showAutocomplete = false
646|c9717a|                    }
647|58a34b|                    .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
648|4e2d32|                }
649|a7dc16|            }
650|5f3077|        }
651|5f3077|        }
652|2bd24e|        .onAppear {
653|ba85f8|            text = tab.content
654|8e600f|            // Folding detection removed
655|5f3077|        }
656|9d97c0|        .onChange(of: tab.id) { _ in
657|ba85f8|            text = tab.content
658|8e600f|            // Folding detection removed
659|5f3077|        }
660|d3345e|        .onChange(of: currentLineNumber) { line in
661|3384f8|            editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
662|5f3077|        }
663|588fd8|        .onChange(of: currentColumn) { col in
664|16524d|            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
665|5f3077|        }
666|75807d|        .onChange(of: editorCore.editorFontSize) { newSize in
667|494152|            // Update lineHeight to match Runestone's line height (~1.4x font size)
668|4f8334|            lineHeight = ceil(newSize * 1.4)
669|5f3077|        }
670|2bd24e|        .onAppear {
671|c916b3|            findViewModel.editorCore = editorCore
672|3e3b84|            // Set initial lineHeight based on font size
673|a33db3|            lineHeight = ceil(editorCore.editorFontSize * 1.4)
674|5f3077|        }
675|27e597|    }
676|b4687f|    
677|a19e38|    // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
678|b31277|}
679|adc83b|
680|e7208c|// MARK: - Line Numbers (Simple)
681|adc83b|
682|91f1f4|struct LineNumbers: View {
683|cdda83|    let totalLines: Int
684|c75d8a|    let currentLine: Int
685|5b2177|    let scrollOffset: CGFloat
686|96ac71|    let lineHeight: CGFloat
687|86829b|    @Binding var requestedLineSelection: Int?
688|6b0e55|    let theme: Theme
689|adc83b|
690|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
691|adc83b|
692|504e43|    var body: some View {
693|ca170c|        ScrollView(showsIndicators: false) {
694|829de3|            VStack(alignment: .trailing, spacing: 0) {
695|227120|                ForEach(0..<totalLines, id: \.self) { lineIndex in
696|d47566|                    Text(displayText(for: lineIndex))
697|67dec4|                        .font(.system(size: 12, design: .monospaced))
698|383a9d|                        .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
699|228b93|                        .frame(height: lineHeight)
700|729aac|                        .frame(maxWidth: .infinity, alignment: .trailing)
701|539a79|                        .padding(.trailing, 4)
702|aec4a4|                        .contentShape(Rectangle())
703|23c196|                        .onTapGesture {
704|f3678b|                            requestedLineSelection = lineIndex
705|392b35|                        }
706|4e2d32|                }
707|a7dc16|            }
708|5f0534|            .padding(.top, 8)
709|873abc|            .offset(y: -scrollOffset)
710|5f3077|        }
711|c059d6|        .scrollDisabled(true)
712|27e597|    }
713|adc83b|
714|46d3db|    private func displayText(for lineIndex: Int) -> String {
715|5d97cf|        switch lineNumbersStyle {
716|a6eb36|        case "relative":
717|b0622f|            let lineNumber = lineIndex + 1
718|44bb33|            if lineNumber == currentLine { return "\(lineNumber)" }
719|5e67df|            return "\(abs(lineNumber - currentLine))"
720|adc83b|
721|5040ac|        case "interval":
722|b0622f|            let lineNumber = lineIndex + 1
723|bc3fe3|            return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
724|adc83b|
725|520b7d|        default:
726|3880c0|            return "\(lineIndex + 1)"
727|5f3077|        }
728|27e597|    }
729|b31277|}
730|adc83b|
731|e3bdd2|// MARK: - Autocomplete Popup
732|adc83b|
733|b1d20a|struct AutocompletePopup: View {
734|5eb9d3|    let suggestions: [AutocompleteSuggestion]
735|79c1fc|    let selectedIndex: Int
736|6b0e55|    let theme: Theme
737|6f35cf|    let onSelectIndex: (Int) -> Void
738|b4687f|    
739|504e43|    var body: some View {
740|0865e6|        VStack(alignment: .leading, spacing: 0) {
741|a954be|            ForEach(suggestions.indices, id: \.self) { index in
742|ad513b|                let s = suggestions[index]
743|dbadc1|                HStack(spacing: 6) {
744|fcd45a|                    Image(systemName: icon(for: s.kind))
745|cdb0af|                        .font(.caption)
746|2e9202|                        .foregroundColor(color(for: s.kind))
747|288999|                    VStack(alignment: .leading, spacing: 1) {
748|3d1271|                        Text(s.displayText)
749|09bbe1|                            .font(.system(size: 12, design: .monospaced))
750|239e62|                            .foregroundColor(theme.editorForeground)




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 751-1000 of 1407)
────────────────────────────────────────
751|71c2b3|                        if s.insertText != s.displayText && !s.insertText.isEmpty {
752|53d416|                            Text(s.insertText)
753|87ab4e|                                .font(.system(size: 10, design: .monospaced))
754|32bc5b|                                .foregroundColor(theme.editorForeground.opacity(0.55))
755|a9b5f4|                                .lineLimit(1)
756|392b35|                        }
757|c9717a|                    }
758|dcd0bf|                    Spacer()
759|4e2d32|                }
760|41847e|                .padding(.horizontal, 8).padding(.vertical, 6)
761|e72d30|                .background(index == selectedIndex ? theme.selection : Color.clear)
762|1e8a31|                .contentShape(Rectangle())
763|eec06d|                .onTapGesture { onSelectIndex(index) }
764|a7dc16|            }
765|5f3077|        }
766|5260c9|        .frame(width: 260)
767|04ec17|        .background(theme.editorBackground)
768|097147|        .cornerRadius(6)
769|f64ce1|        .shadow(radius: 8)
770|27e597|    }
771|b4687f|    
772|ccd198|    private func icon(for kind: AutocompleteSuggestionKind) -> String {
773|01fe0f|        switch kind {
774|62a12d|        case .keyword: return "key.fill"
775|710dbd|        case .symbol: return "cube.fill"
776|d0a8ab|        case .stdlib: return "curlybraces"
777|c3ed81|        case .member: return "arrow.right.circle.fill"
778|5f3077|        }
779|27e597|    }
780|b4687f|    
781|126b1f|    private func color(for kind: AutocompleteSuggestionKind) -> Color {
782|01fe0f|        switch kind {
783|a51b30|        case .keyword: return .purple
784|8740a1|        case .symbol: return .blue
785|628567|        case .stdlib: return .orange
786|b8e5e8|        case .member: return .green
787|5f3077|        }
788|27e597|    }
789|b31277|}
790|adc83b|
791|4409de|// MARK: - Welcome View
792|adc83b|
793|35ff8c|struct IDEWelcomeView: View {
794|e5f895|    @ObservedObject var editorCore: EditorCore
795|7d30ad|    @ObservedObject var recentFiles: RecentFileManager = .shared
796|fe002a|    @Binding var showFolderPicker: Bool
797|6b0e55|    let theme: Theme
798|b4687f|    
799|504e43|    var body: some View {
800|4d4b46|        ScrollView {
801|92175e|            VStack(spacing: 0) {
802|8ceded|                Spacer().frame(height: 60)
803|216278|                
804|0a052f|                // Logo & Title
805|6194f8|                VStack(spacing: 12) {
806|28467a|                    Image(systemName: "chevron.left.forwardslash.chevron.right")
807|20375b|                        .font(.system(size: 64, weight: .thin))
808|da2fcc|                        .foregroundColor(.accentColor.opacity(0.7))
809|af291e|                    Text("VS Code for iPadOS")
810|331176|                        .font(.system(size: 28, weight: .bold))
811|49a616|                        .foregroundColor(theme.editorForeground)
812|d68666|                    Text("Code anywhere. Build anything.")
813|e4008e|                        .font(.system(size: 14))
814|c9c92a|                        .foregroundColor(theme.editorForeground.opacity(0.5))
815|4e2d32|                }
816|9e1451|                .padding(.bottom, 40)
817|216278|                
818|38781d|                // Main content in columns
819|1ff7c7|                HStack(alignment: .top, spacing: 48) {
820|7da568|                    // Left: Start actions
821|f38358|                    VStack(alignment: .leading, spacing: 16) {
822|97a3c6|                        Text("Start")
823|1a45a2|                            .font(.system(size: 13, weight: .semibold))
824|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
825|d4034e|                            .textCase(.uppercase)
826|956cfe|                        
827|3e5f33|                        WelcomeLink(icon: "doc.badge.plus", title: "New File", shortcut: "\u{2318}N", theme: theme) { editorCore.addTab() }
828|ff3de3|                        WelcomeLink(icon: "folder", title: "Open Folder...", shortcut: "\u{2318}\u{21E7}O", theme: theme) { showFolderPicker = true }
829|af22ad|                        WelcomeLink(icon: "doc", title: "Open File...", shortcut: "\u{2318}O", theme: theme) { editorCore.showFilePicker = true }
830|7f563b|                        WelcomeLink(icon: "arrow.triangle.branch", title: "Clone Repository...", shortcut: nil, theme: theme) { }
831|c6b72d|                        WelcomeLink(icon: "network", title: "Connect to SSH Host...", shortcut: nil, theme: theme) { }
832|c9717a|                    }
833|a50e8e|                    .frame(width: 260)
834|dd2193|                    
835|fb6ef7|                    // Center: Recent
836|f38358|                    VStack(alignment: .leading, spacing: 16) {
837|09b581|                        Text("Recent")
838|1a45a2|                            .font(.system(size: 13, weight: .semibold))
839|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
840|d4034e|                            .textCase(.uppercase)
841|956cfe|                        
842|2dfdd3|                        if recentFiles.recentFiles.isEmpty {
843|2c0bc4|                            Text("No recent files")
844|f4b380|                                .font(.system(size: 13))
845|1df1cd|                                .foregroundColor(theme.editorForeground.opacity(0.3))
846|ebe48f|                                .padding(.vertical, 8)
847|65e2f4|                        } else {
848|3121b3|                            ForEach(recentFiles.recentFiles.prefix(8), id: \.absoluteString) { url in
849|859ef8|                                Button(action: {
850|2e44f8|                                    editorCore.addTab(fileName: url.lastPathComponent, content: "", url: url)
851|a37f0c|                                }) {
852|0334d4|                                    HStack(spacing: 8) {
853|a7ba40|                                        Image(systemName: url.hasDirectoryPath ? "folder.fill" : "doc.fill")
854|d6fd17|                                            .font(.system(size: 12))
855|16ab52|                                            .foregroundColor(.accentColor)
856|62f5b3|                                            .frame(width: 16)
857|e9d9bf|                                        VStack(alignment: .leading, spacing: 1) {
858|2f3f86|                                            Text(url.lastPathComponent)
859|351a6d|                                                .font(.system(size: 13))
860|fd3cf9|                                                .foregroundColor(.accentColor)
861|ebf583|                                                .lineLimit(1)
862|71fb92|                                            Text(url.deletingLastPathComponent().path)
863|c2a1f5|                                                .font(.system(size: 10))
864|4dacfc|                                                .foregroundColor(theme.editorForeground.opacity(0.4))
865|ebf583|                                                .lineLimit(1)
866|eed1d8|                                        }
867|8ab74d|                                    }
868|f83e05|                                }
869|31bef9|                                .buttonStyle(.plain)
870|89d40a|                            }
871|392b35|                        }
872|c9717a|                    }
873|ac3576|                    .frame(width: 280)
874|dd2193|                    
875|74716b|                    // Right: Help & Tips
876|f38358|                    VStack(alignment: .leading, spacing: 16) {
877|f992df|                        Text("Help")
878|1a45a2|                            .font(.system(size: 13, weight: .semibold))
879|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
880|d4034e|                            .textCase(.uppercase)
881|956cfe|                        
882|c46faa|                        WelcomeLink(icon: "terminal", title: "Command Palette", shortcut: "\u{2318}\u{21E7}P", theme: theme) { editorCore.showCommandPalette = true }
883|f1821e|                        WelcomeLink(icon: "keyboard", title: "Keyboard Shortcuts", shortcut: nil, theme: theme) { editorCore.showKeyboardShortcuts = true }
884|149497|                        WelcomeLink(icon: "gear", title: "Settings", shortcut: "\u{2318},", theme: theme) {
885|6da7e1|                            NotificationCenter.default.post(name: .init("ShowSettings"), object: nil)
886|392b35|                        }
887|956cfe|                        
888|c0a3dd|                        Divider().padding(.vertical, 4)
889|956cfe|                        
890|f3e0be|                        Text("Tips")
891|1a45a2|                            .font(.system(size: 13, weight: .semibold))
892|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
893|d4034e|                            .textCase(.uppercase)
894|956cfe|                        
895|db141c|                        WelcomeTip(icon: "sparkles", text: "Use \u{2318}\u{21E7}A to open the AI assistant", theme: theme)
896|0714f5|                        WelcomeTip(icon: "sidebar.left", text: "\u{2318}B toggles the sidebar", theme: theme)
897|91e7bb|                        WelcomeTip(icon: "magnifyingglass", text: "\u{2318}\u{21E7}F searches across all files", theme: theme)
898|6bf5fa|                        WelcomeTip(icon: "arrow.triangle.branch", text: "Built-in Git with native Swift implementation", theme: theme)
899|c9717a|                    }
900|ac3576|                    .frame(width: 280)
901|4e2d32|                }
902|3570a8|                .padding(.horizontal, 40)
903|216278|                
904|8ceded|                Spacer().frame(height: 60)
905|a7dc16|            }
906|9a9c46|            .frame(maxWidth: .infinity)
907|5f3077|        }
908|04ec17|        .background(theme.editorBackground)
909|27e597|    }
910|b31277|}
911|adc83b|
912|24ea2a|struct WelcomeLink: View {
913|f0e87a|    let icon: String
914|399f36|    let title: String
915|265a5c|    let shortcut: String?
916|6b0e55|    let theme: Theme
917|59027a|    let action: () -> Void
918|b4687f|    
919|6d2ac2|    @State private var isHovering = false
920|b4687f|    
921|504e43|    var body: some View {
922|6f04d8|        Button(action: action) {
923|c0775d|            HStack(spacing: 8) {
924|7b64f6|                Image(systemName: icon)
925|9c904b|                    .font(.system(size: 13))
926|153725|                    .foregroundColor(.accentColor)
927|688547|                    .frame(width: 20)
928|3f8b13|                Text(title)
929|9c904b|                    .font(.system(size: 13))
930|153725|                    .foregroundColor(.accentColor)
931|e1df7b|                if let shortcut = shortcut {
932|dcd0bf|                    Spacer()
933|5e6df6|                    Text(shortcut)
934|1057c9|                        .font(.system(size: 11, design: .rounded))
935|40df1e|                        .foregroundColor(theme.editorForeground.opacity(0.35))
936|4e2d32|                }
937|a7dc16|            }
938|ec0aa4|            .padding(.vertical, 3)
939|68d57d|            .contentShape(Rectangle())
940|5f3077|        }
941|bd8b70|        .buttonStyle(.plain)
942|c115d3|        .onHover { isHovering = $0 }
943|17fe31|        .opacity(isHovering ? 0.8 : 1.0)
944|27e597|    }
945|b31277|}
946|adc83b|
947|bb22f9|struct WelcomeTip: View {
948|f0e87a|    let icon: String
949|e25e12|    let text: String
950|6b0e55|    let theme: Theme
951|b4687f|    
952|504e43|    var body: some View {
953|d6296b|        HStack(spacing: 8) {
954|ed6617|            Image(systemName: icon)
955|a7de34|                .font(.system(size: 11))
956|195e4d|                .foregroundColor(theme.editorForeground.opacity(0.4))
957|c404e7|                .frame(width: 16)
958|6a8caf|            Text(text)
959|ee466d|                .font(.system(size: 12))
960|904c91|                .foregroundColor(theme.editorForeground.opacity(0.5))
961|5f3077|        }
962|27e597|    }
963|b31277|}
964|adc83b|
965|4b4130|struct WelcomeBtn: View {
966|f0e87a|    let icon: String
967|399f36|    let title: String
968|14874c|    let shortcut: String
969|6b0e55|    let theme: Theme
970|59027a|    let action: () -> Void
971|b4687f|    
972|504e43|    var body: some View {
973|6f04d8|        Button(action: action) {
974|f49fd2|            HStack {
975|f2b865|                Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
976|d34e42|                Text(title).foregroundColor(theme.editorForeground)
977|a02350|                Spacer()
978|0f9490|                Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
979|a7dc16|            }
980|a09f6b|            .padding().frame(width: 280)
981|cef0ad|            .background(theme.sidebarBackground)
982|b18c2b|            .cornerRadius(8)
983|9e9bdf|        }.buttonStyle(.plain)
984|27e597|    }
985|b31277|}
986|adc83b|
987|db0271|// MARK: - Command Palette
988|adc83b|
989|e71bec|struct IDECommandPalette: View {
990|e5f895|    @ObservedObject var editorCore: EditorCore
991|3bd3a7|    @Binding var showSettings: Bool
992|fe5153|    @Binding var showTerminal: Bool
993|d901da|    @State private var searchText = ""
994|b4687f|    
995|504e43|    var body: some View {
996|94dd27|        VStack(spacing: 0) {
997|f49fd2|            HStack {
998|41b09a|                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
999|259764|                TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
1000|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 1001-1200 of 1407)
────────────────────────────────────────
1001|e744dc|            Divider()
1002|6b85db|            ScrollView {
1003|9ad863|                VStack(spacing: 0) {
1004|bd267a|                    CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
1005|48369f|                    CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
1006|1997cb|                    CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
1007|e10354|                    CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
1008|684ba0|                    CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
1009|79e8a7|                    CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
1010|92fdf3|                    CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
1011|e6f867|                    CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
1012|b7baf1|                }.padding(.vertical, 8)
1013|a7dc16|            }
1014|338a7e|        }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
1015|27e597|    }
1016|b31277|}
1017|adc83b|
1018|b6a6d7|struct CommandRow: View {
1019|e97b0d|    let icon: String; let name: String; let shortcut: String; let action: () -> Void
1020|504e43|    var body: some View {
1021|6f04d8|        Button(action: action) {
1022|f49fd2|            HStack {
1023|c4580d|                Image(systemName: icon).foregroundColor(.accentColor).frame(width: 24)
1024|ade206|                Text(name).foregroundColor(.primary)
1025|a02350|                Spacer()
1026|512c27|                Text(shortcut).font(.caption).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 4).background(Color(UIColor.tertiarySystemFill)).cornerRadius(4)
1027|dfa64f|            }.padding(.horizontal).padding(.vertical, 12).contentShape(Rectangle())
1028|9e9bdf|        }.buttonStyle(.plain)
1029|27e597|    }
1030|b31277|}
1031|adc83b|
1032|6b1f13|// MARK: - Quick Open
1033|adc83b|
1034|7bfe0e|struct IDEQuickOpen: View {
1035|e5f895|    @ObservedObject var editorCore: EditorCore
1036|d901da|    @State private var searchText = ""
1037|b4687f|    
1038|504e43|    var body: some View {
1039|94dd27|        VStack(spacing: 0) {
1040|f49fd2|            HStack {
1041|fa8104|                Image(systemName: "magnifyingglass").foregroundColor(.gray)
1042|a496c8|                TextField("Search files...", text: $searchText).textFieldStyle(.plain)
1043|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))
1044|e744dc|            Divider()
1045|6b85db|            ScrollView {
1046|8ee2f5|                VStack(alignment: .leading, spacing: 0) {
1047|3625c1|                    ForEach(editorCore.tabs) { tab in
1048|88ee6a|                        QuickOpenRow(name: tab.fileName, path: "") {
1049|4f316a|                            editorCore.selectTab(id: tab.id)
1050|90bf2b|                            editorCore.showQuickOpen = false
1051|392b35|                        }
1052|c9717a|                    }
1053|4e2d32|                }
1054|1964e5|            }.frame(maxHeight: 350)
1055|0014d4|        }.frame(width: 500).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
1056|27e597|    }
1057|b31277|}
1058|adc83b|
1059|767562|struct QuickOpenRow: View {
1060|ee9c0b|    let name: String; let path: String; let action: () -> Void
1061|504e43|    var body: some View {
1062|6f04d8|        Button(action: action) {
1063|f49fd2|            HStack {
1064|0b1ac7|                Image(systemName: fileIcon(for: name)).foregroundColor(fileColor(for: name)).frame(width: 20)
1065|23f981|                VStack(alignment: .leading, spacing: 2) { Text(name).font(.system(size: 14)); Text(path + name).font(.system(size: 11)).foregroundColor(.secondary) }
1066|a02350|                Spacer()
1067|38ff47|            }.padding(.horizontal).padding(.vertical, 8).contentShape(Rectangle())
1068|9e9bdf|        }.buttonStyle(.plain)
1069|27e597|    }
1070|b31277|}
1071|adc83b|
1072|2d88cf|// MARK: - AI Assistant
1073|adc83b|
1074|5f57bf|struct IDEAIAssistant: View {
1075|e5f895|    @ObservedObject var editorCore: EditorCore
1076|6b0e55|    let theme: Theme
1077|2855b6|    @State private var userInput = ""
1078|9cbba7|    @State private var messages: [(id: UUID, role: String, content: String)] = [(UUID(), "assistant", "Hello! I'm your AI coding assistant. How can I help?")]
1079|b4687f|    
1080|504e43|    var body: some View {
1081|94dd27|        VStack(spacing: 0) {
1082|f49fd2|            HStack {
1083|35e129|                Image(systemName: "brain").foregroundColor(.blue)
1084|b6566c|                Text("AI Assistant").font(.headline).foregroundColor(theme.editorForeground)
1085|a02350|                Spacer()
1086|cc1153|                Button(action: { editorCore.showAIAssistant = false }) { Image(systemName: "xmark.circle.fill").foregroundColor(theme.editorForeground.opacity(0.5)) }
1087|0facd0|            }.padding().background(theme.sidebarBackground)
1088|3070d1|            
1089|6b85db|            ScrollView {
1090|df82e6|                LazyVStack(alignment: .leading, spacing: 12) {
1091|a5721a|                    ForEach(messages, id: \.id) { msg in
1092|679877|                        HStack {
1093|a85384|                            if msg.role == "user" { Spacer(minLength: 60) }
1094|8b1fb9|                            Text(msg.content).padding(12).background(RoundedRectangle(cornerRadius: 12).fill(msg.role == "user" ? Color.blue : theme.sidebarBackground)).foregroundColor(msg.role == "user" ? .white : theme.editorForeground)
1095|b74ebb|                            if msg.role == "assistant" { Spacer(minLength: 60) }
1096|392b35|                        }
1097|c9717a|                    }
1098|c5f15e|                }.padding()
1099|744c4f|            }.background(theme.editorBackground)
1100|3070d1|            
1101|8574de|            HStack(spacing: 12) {
1102|0e3711|                TextField("Ask about your code...", text: $userInput).textFieldStyle(.roundedBorder)
1103|753afe|                Button(action: { sendMessage() }) { Image(systemName: "paperplane.fill").foregroundColor(userInput.isEmpty ? .gray : .blue) }.disabled(userInput.isEmpty)
1104|0facd0|            }.padding().background(theme.sidebarBackground)
1105|a8790d|        }.background(theme.editorBackground).cornerRadius(12).shadow(radius: 20)
1106|27e597|    }
1107|b4687f|    
1108|beb964|    func sendMessage() {
1109|29cfe7|        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
1110|8a803f|        messages.append((UUID(), "user", userInput))
1111|eac017|        let input = userInput
1112|2c52ee|        userInput = ""
1113|145a34|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
1114|c7ba20|            messages.append((UUID(), "assistant", "I can help with '\(input)'! What specifically would you like to know?"))
1115|5f3077|        }
1116|27e597|    }
1117|b31277|}
1118|adc83b|
1119|31bfc1|// MARK: - Status Bar
1120|adc83b|
1121|adc83b|
1122|adc83b|
1123|f4a6ee|// MARK: - Folder Picker
1124|adc83b|
1125|4842b2|struct IDEFolderPicker: UIViewControllerRepresentable {
1126|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
1127|10370b|    var onPick: ((URL) -> Void)?
1128|b4687f|    
1129|fc2de0|    init(fileNavigator: FileSystemNavigator, onPick: ((URL) -> Void)? = nil) {
1130|237a4e|        self.fileNavigator = fileNavigator
1131|3192b9|        self.onPick = onPick
1132|27e597|    }
1133|b4687f|    
1134|a4c191|    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
1135|352547|        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
1136|325e82|        picker.delegate = context.coordinator
1137|993f50|        return picker
1138|27e597|    }
1139|b4687f|    
1140|bd012f|    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
1141|b4687f|    
1142|7da3c4|    func makeCoordinator() -> Coordinator { Coordinator(self) }
1143|b4687f|    
1144|9c0536|    class Coordinator: NSObject, UIDocumentPickerDelegate {
1145|e78b69|        let parent: IDEFolderPicker
1146|11a437|        init(_ parent: IDEFolderPicker) { self.parent = parent }
1147|d6ed84|        
1148|da3421|        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
1149|51c500|            if let url = urls.first {
1150|94998b|                _ = url.startAccessingSecurityScopedResource()
1151|24e3be|                if let onPick = parent.onPick {
1152|71fb5b|                    onPick(url)
1153|fdd0e2|                } else {
1154|866512|                    // Default behavior if no custom handler
1155|7ec9fd|                    parent.fileNavigator.loadFileTree(at: url)
1156|3d4547|                    Task { @MainActor in
1157|e3472e|                        LaunchManager.shared.setWorkspaceRoot(url)
1158|14c08d|                        GitManager.shared.setWorkingDirectory(url)
1159|c9717a|                    }
1160|4e2d32|                }
1161|a7dc16|            }
1162|5f3077|        }
1163|27e597|    }
1164|b31277|}
1165|adc83b|
1166|ba3cff|// MARK: - Document Picker
1167|adc83b|
1168|f67fab|struct IDEDocumentPicker: UIViewControllerRepresentable {
1169|e5f895|    @ObservedObject var editorCore: EditorCore
1170|b4687f|    
1171|a4c191|    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
1172|99746f|        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .sourceCode, .json, .plainText, .data])
1173|1abf38|        picker.allowsMultipleSelection = true
1174|325e82|        picker.delegate = context.coordinator
1175|993f50|        return picker
1176|27e597|    }
1177|b4687f|    
1178|bd012f|    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
1179|b4687f|    
1180|eca7e2|    func makeCoordinator() -> Coordinator { Coordinator(editorCore: editorCore) }
1181|b4687f|    
1182|9c0536|    class Coordinator: NSObject, UIDocumentPickerDelegate {
1183|3f6aca|        let editorCore: EditorCore
1184|d04b21|        init(editorCore: EditorCore) { self.editorCore = editorCore }
1185|d6ed84|        
1186|da3421|        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
1187|457fb6|            for url in urls { editorCore.openFile(from: url) }
1188|7adb67|            editorCore.showFilePicker = false
1189|5f3077|        }
1190|d6ed84|        
1191|de7fa5|        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
1192|7adb67|            editorCore.showFilePicker = false
1193|5f3077|        }
1194|27e597|    }
1195|b31277|}
1196|adc83b|
1197|74cc94|// MARK: - Save As Document Picker
1198|ccc9e4|struct IDESaveAsPicker: UIViewControllerRepresentable {
1199|e5f895|    @ObservedObject var editorCore: EditorCore
1200|02a6c7|    let content: String




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 1201-1407 of 1407)
────────────────────────────────────────
1201|a9f0b2|    let suggestedName: String
1202|b4687f|    
1203|a4c191|    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
1204|b841b0|        // Create a temporary file to export
1205|1a88a0|        let tempDir = FileManager.default.temporaryDirectory
1206|a5eb77|        let tempURL = tempDir.appendingPathComponent(suggestedName)
1207|e535ac|        try? content.write(to: tempURL, atomically: true, encoding: .utf8)
1208|d6ed84|        
1209|b82568|        let picker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: false)
1210|325e82|        picker.delegate = context.coordinator
1211|993f50|        return picker
1212|27e597|    }
1213|b4687f|    
1214|bd012f|    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
1215|b4687f|    
1216|eca7e2|    func makeCoordinator() -> Coordinator { Coordinator(editorCore: editorCore) }
1217|b4687f|    
1218|9c0536|    class Coordinator: NSObject, UIDocumentPickerDelegate {
1219|3f6aca|        let editorCore: EditorCore
1220|d04b21|        init(editorCore: EditorCore) { self.editorCore = editorCore }
1221|d6ed84|        
1222|da3421|        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
1223|c1fffc|            if let savedURL = urls.first {
1224|cc6bec|                // Update the active tab with the new URL
1225|0fe499|                if let tabId = editorCore.activeTabId,
1226|19d222|                   let index = editorCore.tabs.firstIndex(where: { $0.id == tabId }) {
1227|5b032d|                    editorCore.tabs[index].url = savedURL
1228|ade234|                    editorCore.tabs[index].fileName = savedURL.lastPathComponent
1229|e37e24|                    editorCore.tabs[index].isUnsaved = false
1230|4e2d32|                }
1231|a7dc16|            }
1232|77d979|            editorCore.showSaveAsDialog = false
1233|5f3077|        }
1234|d6ed84|        
1235|de7fa5|        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
1236|77d979|            editorCore.showSaveAsDialog = false
1237|5f3077|        }
1238|27e597|    }
1239|b31277|}
1240|adc83b|
1241|c30d93|// MARK: - Sidebar Search View
1242|adc83b|
1243|ff7a02|struct SidebarSearchView: View {
1244|6b0e55|    let theme: Theme
1245|d901da|    @State private var searchText = ""
1246|fc86dc|    @State private var replaceText = ""
1247|14c295|    @State private var showReplace = false
1248|e71a49|    @State private var searchResults: [(fileName: String, line: Int, preview: String)] = []
1249|b4687f|    
1250|504e43|    var body: some View {
1251|0865e6|        VStack(alignment: .leading, spacing: 0) {
1252|f49fd2|            HStack {
1253|a72153|                Text("SEARCH").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
1254|a02350|                Spacer()
1255|5cbd4e|            }.padding(.horizontal, 12).padding(.vertical, 8)
1256|3070d1|            
1257|37f526|            HStack(spacing: 4) {
1258|7c8adb|                Image(systemName: "magnifyingglass").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
1259|954f5a|                TextField("Search", text: $searchText).textFieldStyle(.plain).font(.system(size: 13))
1260|985367|                    .foregroundColor(theme.sidebarForeground)
1261|73afa1|                if !searchText.isEmpty {
1262|67cd1a|                    Button(action: { searchText = "" }) {
1263|5104ae|                        Image(systemName: "xmark.circle.fill").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
1264|c9717a|                    }
1265|4e2d32|                }
1266|a7dc16|            }
1267|49a025|            .padding(8)
1268|6f1e62|            .background(theme.editorBackground)
1269|d4ec9d|            .cornerRadius(6)
1270|87be8f|            .padding(.horizontal, 12)
1271|3070d1|            
1272|f49fd2|            HStack {
1273|475b21|                Button(action: { showReplace.toggle() }) {
1274|fa96e4|                    Image(systemName: showReplace ? "chevron.down" : "chevron.right").font(.caption2)
1275|4d5fa8|                    Text("Replace").font(.caption)
1276|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
1277|a02350|                Spacer()
1278|d99206|            }.padding(.horizontal, 12).padding(.vertical, 6)
1279|3070d1|            
1280|cd0b7c|            if showReplace {
1281|0cad4d|                HStack(spacing: 4) {
1282|306ea2|                    Image(systemName: "arrow.right").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
1283|bbb551|                    TextField("Replace", text: $replaceText).textFieldStyle(.plain).font(.system(size: 13))
1284|187f02|                        .foregroundColor(theme.sidebarForeground)
1285|4e2d32|                }
1286|040bcc|                .padding(8)
1287|3bc2db|                .background(theme.editorBackground)
1288|e16349|                .cornerRadius(6)
1289|010717|                .padding(.horizontal, 12)
1290|a7dc16|            }
1291|3070d1|            
1292|11295a|            Divider().padding(.top, 8)
1293|3070d1|            
1294|671ab1|            if searchText.isEmpty {
1295|a55c92|                VStack(spacing: 8) {
1296|dcd0bf|                    Spacer()
1297|3752b9|                    Image(systemName: "magnifyingglass").font(.largeTitle).foregroundColor(theme.sidebarForeground.opacity(0.3))
1298|878b47|                    Text("Search in files").font(.caption).foregroundColor(theme.sidebarForeground.opacity(0.6))
1299|dcd0bf|                    Spacer()
1300|6ace0d|                }.frame(maxWidth: .infinity)
1301|f5a6eb|            } else {
1302|5deb41|                ScrollView {
1303|697be1|                    LazyVStack(alignment: .leading, spacing: 0) {
1304|8e3e6e|                        ForEach(0..<searchResults.count, id: \.self) { i in
1305|a30ef9|                            let result = searchResults[i]
1306|8b2f33|                            VStack(alignment: .leading, spacing: 2) {
1307|ccf016|                                HStack {
1308|04d28f|                                    Image(systemName: "doc.text").font(.caption2).foregroundColor(theme.sidebarForeground.opacity(0.6))
1309|24753d|                                    Text(result.fileName).font(.system(size: 11, weight: .medium)).foregroundColor(theme.sidebarForeground)
1310|c7a564|                                    Spacer()
1311|234ffb|                                    Text(":\(result.line)").font(.system(size: 10, design: .monospaced)).foregroundColor(theme.sidebarForeground.opacity(0.6))
1312|f83e05|                                }
1313|ef7387|                                Text(result.preview).font(.system(size: 11, design: .monospaced)).foregroundColor(theme.sidebarForeground.opacity(0.7)).lineLimit(1)
1314|0fc88f|                            }.padding(.horizontal, 12).padding(.vertical, 6)
1315|392b35|                        }
1316|c9717a|                    }
1317|4e2d32|                }
1318|a7dc16|            }
1319|5f3077|        }
1320|a9d0fc|        .background(theme.sidebarBackground)
1321|649689|        .onChange(of: searchText) { query in
1322|387dc1|            if query.isEmpty { searchResults = [] }
1323|c8764c|            else { searchResults = [("ContentView.swift", 15, "Text(\"\(query)\")"), ("main.swift", 8, "// \(query)")] }
1324|5f3077|        }
1325|27e597|    }
1326|b31277|}
1327|adc83b|
1328|0ab084|// MARK: - Local Code Execution
1329|adc83b|
1330|ace768|extension ContentView {
1331|0b0ee0|    /// Run the bundled test.wasm sample
1332|7196e8|    func runSampleWASM() async {
1333|057b3b|        // Find the bundled test.wasm
1334|81c26b|        guard let wasmURL = Bundle.main.url(forResource: "test", withExtension: "wasm") else {
1335|a6a73d|            await MainActor.run {
1336|f34303|                showTerminal = true
1337|665384|                NotificationCenter.default.post(name: NSNotification.Name("AppendOutput"), object: nil, userInfo: ["text": "❌ Error: test.wasm not found in bundle\n"])
1338|a7dc16|            }
1339|bef5d6|            return
1340|5f3077|        }
1341|d6ed84|        
1342|84c5ec|        await MainActor.run {
1343|4bf62b|            showTerminal = true
1344|e348e9|            NotificationCenter.default.post(name: NSNotification.Name("SwitchToOutputPanel"), object: nil)
1345|544777|            NotificationCenter.default.post(name: NSNotification.Name("AppendOutput"), object: nil, userInfo: ["text": "▶ Running bundled WASM: test.wasm\n─────────────────────────────────────\n"])
1346|5f3077|        }
1347|d6ed84|        
1348|4da690|        do {
1349|c6cc85|            let config = WASMConfiguration.default
1350|7c8265|            let runner = try WASMRunner(configuration: config)
1351|3070d1|            
1352|e8b4ce|            try await runner.load(from: wasmURL)
1353|a6a73d|            await MainActor.run {
1354|4910ef|                NotificationCenter.default.post(name: NSNotification.Name("AppendOutput"), object: nil, userInfo: ["text": "✓ Module loaded\n"])
1355|a7dc16|            }
1356|3070d1|            
1357|aea9ab|            // Call main() which returns 42
1358|e36d76|            let result = try await runner.execute(function: "main", args: [])
1359|3070d1|            
1360|a6a73d|            await MainActor.run {
1361|9f4667|                NotificationCenter.default.post(name: NSNotification.Name("AppendOutput"), object: nil, userInfo: ["text": "─────────────────────────────────────\n⮐ Result: \(result)\n✓ Completed\n"])
1362|a7dc16|            }
1363|3070d1|            
1364|061a0b|            await runner.unload()
1365|853889|        } catch {
1366|a6a73d|            await MainActor.run {
1367|3615e4|                NotificationCenter.default.post(name: NSNotification.Name("AppendOutput"), object: nil, userInfo: ["text": "❌ Error: \(error.localizedDescription)\n"])
1368|a7dc16|            }
1369|5f3077|        }
1370|27e597|    }
1371|b4687f|    
1372|4f470e|    /// Run JavaScript code using JSRunner
1373|35a86d|    func runJavaScript(code: String, fileName: String) async {
1374|84c5ec|        await MainActor.run {
1375|4bf62b|            showTerminal = true
1376|e348e9|            NotificationCenter.default.post(name: NSNotification.Name("SwitchToOutputPanel"), object: nil)
1377|f35dc6|            NotificationCenter.default.post(name: NSNotification.Name("AppendOutput"), object: nil, userInfo: ["text": "▶ Running JavaScript: \(fileName)\n─────────────────────────────────────\n"])
1378|5f3077|        }
1379|d6ed84|        
1380|d199c4|        let runner = JSRunner()
1381|d6ed84|        
1382|58d20f|        // Capture console output
1383|6252fc|        runner.setConsoleHandler { message in
1384|270dfc|            Task { @MainActor in
1385|4f982f|                NotificationCenter.default.post(name: NSNotification.Name("AppendOutput"), object: nil, userInfo: ["text": "\(message)\n"])
1386|a7dc16|            }
1387|5f3077|        }
1388|d6ed84|        
1389|4da690|        do {
1390|b7ae42|            let result = try await runner.execute(code: code)
1391|a6a73d|            await MainActor.run {
1392|9f4667|                NotificationCenter.default.post(name: NSNotification.Name("AppendOutput"), object: nil, userInfo: ["text": "─────────────────────────────────────\n⮐ Result: \(result)\n✓ Completed\n"])
1393|a7dc16|            }
1394|853889|        } catch {
1395|a6a73d|            await MainActor.run {
1396|3615e4|                NotificationCenter.default.post(name: NSNotification.Name("AppendOutput"), object: nil, userInfo: ["text": "❌ Error: \(error.localizedDescription)\n"])
1397|a7dc16|            }
1398|5f3077|        }
1399|27e597|    }
1400|b31277|}
1401|adc83b|
1402|5e4767|// MARK: - Preview
1403|adc83b|
1404|0eca73|#Preview {
1405|c476ef|    ContentView()
1406|b31277|}
1407|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 251-500 of 1407)
────────────────────────────────────────
251|f0e87a|    let icon: String
252|055123|    let isSelected: Bool
253|6b0e55|    let theme: Theme
254|59027a|    let action: () -> Void
255|b4687f|    
256|504e43|    var body: some View {
257|6f04d8|        Button(action: action) {
258|ed6617|            Image(systemName: icon)
259|13a7f6|                .font(.system(size: 22))
260|557f46|                .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
261|c81e69|                .frame(width: 48, height: 48)
262|5f3077|        }
263|27e597|    }
264|b31277|}
265|adc83b|
266|2f1081|// MARK: - Sidebar with Real File System
267|adc83b|
268|77668e|struct IDESidebarFiles: View {
269|e5f895|    @ObservedObject var editorCore: EditorCore
270|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
271|fe002a|    @Binding var showFolderPicker: Bool
272|6b0e55|    let theme: Theme
273|b4687f|    
274|504e43|    var body: some View {
275|0865e6|        VStack(alignment: .leading, spacing: 0) {
276|f49fd2|            HStack {
277|8f10b4|                Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
278|a02350|                Spacer()
279|124c35|                Button(action: { showFolderPicker = true }) {
280|98d029|                    Image(systemName: "folder.badge.plus").font(.caption)
281|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
282|035054|                Button(action: { editorCore.showFilePicker = true }) {
283|e2bf82|                    Image(systemName: "doc.badge.plus").font(.caption)
284|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
285|eaa303|                if fileNavigator.fileTree != nil {
286|a67875|                    Button(action: { fileNavigator.refreshFileTree() }) {
287|7cfff4|                        Image(systemName: "arrow.clockwise").font(.caption)
288|681233|                    }.foregroundColor(theme.sidebarForeground.opacity(0.7))
289|4e2d32|                }
290|5cbd4e|            }.padding(.horizontal, 12).padding(.vertical, 8)
291|3070d1|            
292|6b85db|            ScrollView {
293|492557|                VStack(alignment: .leading, spacing: 2) {
294|5cce6c|                    if let tree = fileNavigator.fileTree {
295|46c9f4|                        FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
296|540066|                    } else {
297|b9326c|                        DemoFileTree(editorCore: editorCore, theme: theme)
298|c9717a|                    }
299|d407ec|                }.padding(.horizontal, 8)
300|a7dc16|            }
301|ea6339|        }.background(theme.sidebarBackground)
302|27e597|    }
303|b31277|}
304|adc83b|
305|2efb89|struct RealFileTreeView: View {
306|7345b3|    let node: FileTreeNode
307|ded86f|    let level: Int
308|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
309|e5f895|    @ObservedObject var editorCore: EditorCore
310|6b0e55|    let theme: Theme
311|b4687f|    
312|17d62f|    var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
313|b4687f|    
314|504e43|    var body: some View {
315|ea9354|        VStack(alignment: .leading, spacing: 2) {
316|37f526|            HStack(spacing: 4) {
317|a37387|                if node.isDirectory {
318|440597|                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
319|8aec79|                        .font(.caption2).frame(width: 12)
320|0b3717|                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
321|740862|                        .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
322|fdd0e2|                } else {
323|df77cf|                    Spacer().frame(width: 12)
324|4e2d32|                }
325|bf729b|                Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
326|8237e3|                    .font(.caption)
327|a7e98c|                    .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
328|926090|                Text(node.name).font(.system(.caption)).lineLimit(1)
329|985367|                    .foregroundColor(theme.sidebarForeground)
330|a02350|                Spacer()
331|a7dc16|            }
332|f3d9fb|            .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
333|68d57d|            .contentShape(Rectangle())
334|835ded|            .onTapGesture {
335|a37387|                if node.isDirectory {
336|8f26cf|                    fileNavigator.toggleExpanded(path: node.url.path)
337|fdd0e2|                } else {
338|13e765|                    editorCore.openFile(from: node.url)
339|4e2d32|                }
340|a7dc16|            }
341|3070d1|            
342|dd4b6d|            if isExpanded && node.isDirectory {
343|4a6742|                ForEach(node.children) { child in
344|8deaf6|                    RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
345|4e2d32|                }
346|a7dc16|            }
347|5f3077|        }
348|27e597|    }
349|b31277|}
350|adc83b|
351|c7c785|struct DemoFileTree: View {
352|e5f895|    @ObservedObject var editorCore: EditorCore
353|6b0e55|    let theme: Theme
354|b4687f|    
355|504e43|    var body: some View {
356|478d8c|        VStack(alignment: .leading, spacing: 4) {
357|dca3c9|            Text("Open a folder to browse files")
358|916793|                .font(.caption)
359|417420|                .foregroundColor(theme.sidebarForeground.opacity(0.6))
360|a48a8d|                .padding(.vertical, 8)
361|3070d1|            
362|eead9e|            DemoFileRow(name: "Welcome.swift", editorCore: editorCore, theme: theme)
363|cbcd60|            DemoFileRow(name: "example.js", editorCore: editorCore, theme: theme)
364|0f2913|            DemoFileRow(name: "example.py", editorCore: editorCore, theme: theme)
365|c07fb7|            DemoFileRow(name: "package.json", editorCore: editorCore, theme: theme)
366|d67c95|            DemoFileRow(name: "index.html", editorCore: editorCore, theme: theme)
367|822f11|            DemoFileRow(name: "styles.css", editorCore: editorCore, theme: theme)
368|5f3077|        }
369|27e597|    }
370|b31277|}
371|adc83b|
372|ab28f0|struct DemoFileRow: View {
373|a5193b|    let name: String
374|e5f895|    @ObservedObject var editorCore: EditorCore
375|6b0e55|    let theme: Theme
376|b4687f|    
377|504e43|    var body: some View {
378|b120fa|        HStack(spacing: 4) {
379|5a4821|            Spacer().frame(width: 12)
380|5a9b2c|            Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
381|0ffef7|            Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
382|1e6289|            Spacer()
383|5f3077|        }
384|60e15e|        .padding(.vertical, 4)
385|55e29b|        .contentShape(Rectangle())
386|cf12c6|        .onTapGesture {
387|9f9063|            if let tab = editorCore.tabs.first(where: { $0.fileName == name }) {
388|166be5|                editorCore.selectTab(id: tab.id)
389|a7dc16|            }
390|5f3077|        }
391|27e597|    }
392|b31277|}
393|adc83b|
394|f3aab4|// MARK: - Tab Bar
395|adc83b|
396|24d9d9|struct IDETabBar: View {
397|e5f895|    @ObservedObject var editorCore: EditorCore
398|6b0e55|    let theme: Theme
399|b4687f|    
400|504e43|    var body: some View {
401|98ab70|        ScrollView(.horizontal, showsIndicators: false) {
402|3b7550|            HStack(spacing: 0) {
403|7512d8|                ForEach(editorCore.tabs) { tab in
404|4b4bd2|                    IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
405|4e2d32|                }
406|5de7cd|                Button(action: { editorCore.addTab() }) {
407|fd7d74|                    Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
408|4e2d32|                }
409|30b85f|            }.padding(.horizontal, 4)
410|962d70|        }.frame(height: 36).background(theme.tabBarBackground)
411|27e597|    }
412|b31277|}
413|adc83b|
414|68fbe9|struct IDETabItem: View {
415|4dc199|    let tab: Tab
416|055123|    let isSelected: Bool
417|e5f895|    @ObservedObject var editorCore: EditorCore
418|6b0e55|    let theme: Theme
419|b4687f|    
420|504e43|    var body: some View {
421|e1c66d|        HStack(spacing: 6) {
422|29528a|            Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
423|a9dd8d|            Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
424|d555ba|                .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
425|5029ae|            if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
426|6effb3|            Button(action: { editorCore.closeTab(id: tab.id) }) {
427|f4c72a|                Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
428|041ce7|                    .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
429|a7dc16|            }
430|5f3077|        }
431|2da2e9|        .padding(.horizontal, 12).padding(.vertical, 6)
432|116b54|        .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
433|7a9052|        .onTapGesture { editorCore.selectTab(id: tab.id) }
434|27e597|    }
435|b31277|}
436|adc83b|
437|f95ca3|// MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
438|adc83b|
439|a178f9|struct IDEEditorView: View {
440|e5f895|    @ObservedObject var editorCore: EditorCore
441|4dc199|    let tab: Tab
442|6b0e55|    let theme: Theme
443|b4687f|    
444|129112|    /// Feature flag for Runestone editor - uses centralized FeatureFlags
445|952908|    private var useRunestoneEditor: Bool { FeatureFlags.useRunestoneEditor }
446|adc83b|
447|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
448|eba335|    @State private var text: String = ""
449|4f0ac8|    @State private var scrollPosition: Int = 0
450|36da68|    @State private var scrollOffset: CGFloat = 0
451|d473fd|    @State private var totalLines: Int = 1
452|bcf90b|    @State private var visibleLines: Int = 20
453|9cb5e9|    @State private var currentLineNumber: Int = 1
454|cc347a|    @State private var currentColumn: Int = 1
455|eee196|    @State private var cursorIndex: Int = 0
456|f97bd7|    @State private var lineHeight: CGFloat = 20  // Updated dynamically based on font size
457|446eb9|    @State private var requestedCursorIndex: Int? = nil
458|5c2aeb|    @State private var requestedLineSelection: Int? = nil
459|adc83b|
460|3977e1|    @StateObject private var autocomplete = AutocompleteManager()
461|4445ec|    @State private var showAutocomplete = false
462|f77a99|    // Code folding removed - will use VS Code tunnel for real folding
463|f453fc|    @StateObject private var findViewModel = FindViewModel()
464|b4687f|    
465|504e43|    var body: some View {
466|94dd27|        VStack(spacing: 0) {
467|8779dd|            // Find/Replace bar
468|2b2a70|            if editorCore.showSearch {
469|38cbe4|                FindReplaceView(viewModel: findViewModel)
470|b768ed|                    .background(theme.tabBarBackground)
471|a7dc16|            }
472|3070d1|            
473|b97232|            BreadcrumbsView(editorCore: editorCore, tab: tab)
474|3070d1|            
475|ca6f75|            GeometryReader { geometry in
476|e60c16|                ZStack(alignment: .topLeading) {
477|7a5371|                HStack(spacing: 0) {
478|91f67b|                    // Simple line numbers gutter (folding/breakpoints removed)
479|8d4059|                    if lineNumbersStyle != "off" {
480|682232|                        LineNumbers(
481|937d74|                            totalLines: totalLines,
482|0f00a6|                            currentLine: currentLineNumber,
483|d6742c|                            scrollOffset: scrollOffset,
484|9f4e9f|                            lineHeight: lineHeight,
485|76e9b6|                            requestedLineSelection: $requestedLineSelection,
486|0acd63|                            theme: theme
487|63214b|                        )
488|4619d2|                        .frame(width: 44)
489|3a838d|                        .background(theme.sidebarBackground.opacity(0.5))
490|c9717a|                    }
491|dd2193|                    
492|3f9dab|                    // Use Runestone for all files including JSON (has TreeSitter JSON support)
493|df925c|                    if false && tab.fileName.hasSuffix(".json") {
494|4229a0|                        // JSON Tree View disabled - using Runestone editor instead
495|daf992|                        JSONTreeView(data: text.data(using: .utf8) ?? Data())
496|f9d830|                            .frame(maxWidth: .infinity, maxHeight: .infinity)
497|96e3a5|                            .background(theme.editorBackground)
498|540066|                    } else {
499|082ddd|                        // Use Runestone for O(log n) performance, or legacy view as fallback
500|e44d33|                        Group {




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 751-1000 of 1407)
────────────────────────────────────────
751|71c2b3|                        if s.insertText != s.displayText && !s.insertText.isEmpty {
752|53d416|                            Text(s.insertText)
753|87ab4e|                                .font(.system(size: 10, design: .monospaced))
754|32bc5b|                                .foregroundColor(theme.editorForeground.opacity(0.55))
755|a9b5f4|                                .lineLimit(1)
756|392b35|                        }
757|c9717a|                    }
758|dcd0bf|                    Spacer()
759|4e2d32|                }
760|41847e|                .padding(.horizontal, 8).padding(.vertical, 6)
761|e72d30|                .background(index == selectedIndex ? theme.selection : Color.clear)
762|1e8a31|                .contentShape(Rectangle())
763|eec06d|                .onTapGesture { onSelectIndex(index) }
764|a7dc16|            }
765|5f3077|        }
766|5260c9|        .frame(width: 260)
767|04ec17|        .background(theme.editorBackground)
768|097147|        .cornerRadius(6)
769|f64ce1|        .shadow(radius: 8)
770|27e597|    }
771|b4687f|    
772|ccd198|    private func icon(for kind: AutocompleteSuggestionKind) -> String {
773|01fe0f|        switch kind {
774|62a12d|        case .keyword: return "key.fill"
775|710dbd|        case .symbol: return "cube.fill"
776|d0a8ab|        case .stdlib: return "curlybraces"
777|c3ed81|        case .member: return "arrow.right.circle.fill"
778|5f3077|        }
779|27e597|    }
780|b4687f|    
781|126b1f|    private func color(for kind: AutocompleteSuggestionKind) -> Color {
782|01fe0f|        switch kind {
783|a51b30|        case .keyword: return .purple
784|8740a1|        case .symbol: return .blue
785|628567|        case .stdlib: return .orange
786|b8e5e8|        case .member: return .green
787|5f3077|        }
788|27e597|    }
789|b31277|}
790|adc83b|
791|4409de|// MARK: - Welcome View
792|adc83b|
793|35ff8c|struct IDEWelcomeView: View {
794|e5f895|    @ObservedObject var editorCore: EditorCore
795|7d30ad|    @ObservedObject var recentFiles: RecentFileManager = .shared
796|fe002a|    @Binding var showFolderPicker: Bool
797|6b0e55|    let theme: Theme
798|b4687f|    
799|504e43|    var body: some View {
800|4d4b46|        ScrollView {
801|92175e|            VStack(spacing: 0) {
802|8ceded|                Spacer().frame(height: 60)
803|216278|                
804|0a052f|                // Logo & Title
805|6194f8|                VStack(spacing: 12) {
806|28467a|                    Image(systemName: "chevron.left.forwardslash.chevron.right")
807|20375b|                        .font(.system(size: 64, weight: .thin))
808|da2fcc|                        .foregroundColor(.accentColor.opacity(0.7))
809|af291e|                    Text("VS Code for iPadOS")
810|331176|                        .font(.system(size: 28, weight: .bold))
811|49a616|                        .foregroundColor(theme.editorForeground)
812|d68666|                    Text("Code anywhere. Build anything.")
813|e4008e|                        .font(.system(size: 14))
814|c9c92a|                        .foregroundColor(theme.editorForeground.opacity(0.5))
815|4e2d32|                }
816|9e1451|                .padding(.bottom, 40)
817|216278|                
818|38781d|                // Main content in columns
819|1ff7c7|                HStack(alignment: .top, spacing: 48) {
820|7da568|                    // Left: Start actions
821|f38358|                    VStack(alignment: .leading, spacing: 16) {
822|97a3c6|                        Text("Start")
823|1a45a2|                            .font(.system(size: 13, weight: .semibold))
824|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
825|d4034e|                            .textCase(.uppercase)
826|956cfe|                        
827|3e5f33|                        WelcomeLink(icon: "doc.badge.plus", title: "New File", shortcut: "\u{2318}N", theme: theme) { editorCore.addTab() }
828|ff3de3|                        WelcomeLink(icon: "folder", title: "Open Folder...", shortcut: "\u{2318}\u{21E7}O", theme: theme) { showFolderPicker = true }
829|af22ad|                        WelcomeLink(icon: "doc", title: "Open File...", shortcut: "\u{2318}O", theme: theme) { editorCore.showFilePicker = true }
830|7f563b|                        WelcomeLink(icon: "arrow.triangle.branch", title: "Clone Repository...", shortcut: nil, theme: theme) { }
831|c6b72d|                        WelcomeLink(icon: "network", title: "Connect to SSH Host...", shortcut: nil, theme: theme) { }
832|c9717a|                    }
833|a50e8e|                    .frame(width: 260)
834|dd2193|                    
835|fb6ef7|                    // Center: Recent
836|f38358|                    VStack(alignment: .leading, spacing: 16) {
837|09b581|                        Text("Recent")
838|1a45a2|                            .font(.system(size: 13, weight: .semibold))
839|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
840|d4034e|                            .textCase(.uppercase)
841|956cfe|                        
842|2dfdd3|                        if recentFiles.recentFiles.isEmpty {
843|2c0bc4|                            Text("No recent files")
844|f4b380|                                .font(.system(size: 13))
845|1df1cd|                                .foregroundColor(theme.editorForeground.opacity(0.3))
846|ebe48f|                                .padding(.vertical, 8)
847|65e2f4|                        } else {
848|3121b3|                            ForEach(recentFiles.recentFiles.prefix(8), id: \.absoluteString) { url in
849|859ef8|                                Button(action: {
850|2e44f8|                                    editorCore.addTab(fileName: url.lastPathComponent, content: "", url: url)
851|a37f0c|                                }) {
852|0334d4|                                    HStack(spacing: 8) {
853|a7ba40|                                        Image(systemName: url.hasDirectoryPath ? "folder.fill" : "doc.fill")
854|d6fd17|                                            .font(.system(size: 12))
855|16ab52|                                            .foregroundColor(.accentColor)
856|62f5b3|                                            .frame(width: 16)
857|e9d9bf|                                        VStack(alignment: .leading, spacing: 1) {
858|2f3f86|                                            Text(url.lastPathComponent)
859|351a6d|                                                .font(.system(size: 13))
860|fd3cf9|                                                .foregroundColor(.accentColor)
861|ebf583|                                                .lineLimit(1)
862|71fb92|                                            Text(url.deletingLastPathComponent().path)
863|c2a1f5|                                                .font(.system(size: 10))
864|4dacfc|                                                .foregroundColor(theme.editorForeground.opacity(0.4))
865|ebf583|                                                .lineLimit(1)
866|eed1d8|                                        }
867|8ab74d|                                    }
868|f83e05|                                }
869|31bef9|                                .buttonStyle(.plain)
870|89d40a|                            }
871|392b35|                        }
872|c9717a|                    }
873|ac3576|                    .frame(width: 280)
874|dd2193|                    
875|74716b|                    // Right: Help & Tips
876|f38358|                    VStack(alignment: .leading, spacing: 16) {
877|f992df|                        Text("Help")
878|1a45a2|                            .font(.system(size: 13, weight: .semibold))
879|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
880|d4034e|                            .textCase(.uppercase)
881|956cfe|                        
882|c46faa|                        WelcomeLink(icon: "terminal", title: "Command Palette", shortcut: "\u{2318}\u{21E7}P", theme: theme) { editorCore.showCommandPalette = true }
883|f1821e|                        WelcomeLink(icon: "keyboard", title: "Keyboard Shortcuts", shortcut: nil, theme: theme) { editorCore.showKeyboardShortcuts = true }
884|149497|                        WelcomeLink(icon: "gear", title: "Settings", shortcut: "\u{2318},", theme: theme) {
885|6da7e1|                            NotificationCenter.default.post(name: .init("ShowSettings"), object: nil)
886|392b35|                        }
887|956cfe|                        
888|c0a3dd|                        Divider().padding(.vertical, 4)
889|956cfe|                        
890|f3e0be|                        Text("Tips")
891|1a45a2|                            .font(.system(size: 13, weight: .semibold))
892|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
893|d4034e|                            .textCase(.uppercase)
894|956cfe|                        
895|db141c|                        WelcomeTip(icon: "sparkles", text: "Use \u{2318}\u{21E7}A to open the AI assistant", theme: theme)
896|0714f5|                        WelcomeTip(icon: "sidebar.left", text: "\u{2318}B toggles the sidebar", theme: theme)
897|91e7bb|                        WelcomeTip(icon: "magnifyingglass", text: "\u{2318}\u{21E7}F searches across all files", theme: theme)
898|6bf5fa|                        WelcomeTip(icon: "arrow.triangle.branch", text: "Built-in Git with native Swift implementation", theme: theme)
899|c9717a|                    }
900|ac3576|                    .frame(width: 280)
901|4e2d32|                }
902|3570a8|                .padding(.horizontal, 40)
903|216278|                
904|8ceded|                Spacer().frame(height: 60)
905|a7dc16|            }
906|9a9c46|            .frame(maxWidth: .infinity)
907|5f3077|        }
908|04ec17|        .background(theme.editorBackground)
909|27e597|    }
910|b31277|}
911|adc83b|
912|24ea2a|struct WelcomeLink: View {
913|f0e87a|    let icon: String
914|399f36|    let title: String
915|265a5c|    let shortcut: String?
916|6b0e55|    let theme: Theme
917|59027a|    let action: () -> Void
918|b4687f|    
919|6d2ac2|    @State private var isHovering = false
920|b4687f|    
921|504e43|    var body: some View {
922|6f04d8|        Button(action: action) {
923|c0775d|            HStack(spacing: 8) {
924|7b64f6|                Image(systemName: icon)
925|9c904b|                    .font(.system(size: 13))
926|153725|                    .foregroundColor(.accentColor)
927|688547|                    .frame(width: 20)
928|3f8b13|                Text(title)
929|9c904b|                    .font(.system(size: 13))
930|153725|                    .foregroundColor(.accentColor)
931|e1df7b|                if let shortcut = shortcut {
932|dcd0bf|                    Spacer()
933|5e6df6|                    Text(shortcut)
934|1057c9|                        .font(.system(size: 11, design: .rounded))
935|40df1e|                        .foregroundColor(theme.editorForeground.opacity(0.35))
936|4e2d32|                }
937|a7dc16|            }
938|ec0aa4|            .padding(.vertical, 3)
939|68d57d|            .contentShape(Rectangle())
940|5f3077|        }
941|bd8b70|        .buttonStyle(.plain)
942|c115d3|        .onHover { isHovering = $0 }
943|17fe31|        .opacity(isHovering ? 0.8 : 1.0)
944|27e597|    }
945|b31277|}
946|adc83b|
947|bb22f9|struct WelcomeTip: View {
948|f0e87a|    let icon: String
949|e25e12|    let text: String
950|6b0e55|    let theme: Theme
951|b4687f|    
952|504e43|    var body: some View {
953|d6296b|        HStack(spacing: 8) {
954|ed6617|            Image(systemName: icon)
955|a7de34|                .font(.system(size: 11))
956|195e4d|                .foregroundColor(theme.editorForeground.opacity(0.4))
957|c404e7|                .frame(width: 16)
958|6a8caf|            Text(text)
959|ee466d|                .font(.system(size: 12))
960|904c91|                .foregroundColor(theme.editorForeground.opacity(0.5))
961|5f3077|        }
962|27e597|    }
963|b31277|}
964|adc83b|
965|4b4130|struct WelcomeBtn: View {
966|f0e87a|    let icon: String
967|399f36|    let title: String
968|14874c|    let shortcut: String
969|6b0e55|    let theme: Theme
970|59027a|    let action: () -> Void
971|b4687f|    
972|504e43|    var body: some View {
973|6f04d8|        Button(action: action) {
974|f49fd2|            HStack {
975|f2b865|                Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
976|d34e42|                Text(title).foregroundColor(theme.editorForeground)
977|a02350|                Spacer()
978|0f9490|                Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
979|a7dc16|            }
980|a09f6b|            .padding().frame(width: 280)
981|cef0ad|            .background(theme.sidebarBackground)
982|b18c2b|            .cornerRadius(8)
983|9e9bdf|        }.buttonStyle(.plain)
984|27e597|    }
985|b31277|}
986|adc83b|
987|db0271|// MARK: - Command Palette
988|adc83b|
989|e71bec|struct IDECommandPalette: View {
990|e5f895|    @ObservedObject var editorCore: EditorCore
991|3bd3a7|    @Binding var showSettings: Bool
992|fe5153|    @Binding var showTerminal: Bool
993|d901da|    @State private var searchText = ""
994|b4687f|    
995|504e43|    var body: some View {
996|94dd27|        VStack(spacing: 0) {
997|f49fd2|            HStack {
998|41b09a|                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
999|259764|                TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
1000|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 251-500 of 1407)
────────────────────────────────────────
251|f0e87a|    let icon: String
252|055123|    let isSelected: Bool
253|6b0e55|    let theme: Theme
254|59027a|    let action: () -> Void
255|b4687f|    
256|504e43|    var body: some View {
257|6f04d8|        Button(action: action) {
258|ed6617|            Image(systemName: icon)
259|13a7f6|                .font(.system(size: 22))
260|557f46|                .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
261|c81e69|                .frame(width: 48, height: 48)
262|5f3077|        }
263|27e597|    }
264|b31277|}
265|adc83b|
266|2f1081|// MARK: - Sidebar with Real File System
267|adc83b|
268|77668e|struct IDESidebarFiles: View {
269|e5f895|    @ObservedObject var editorCore: EditorCore
270|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
271|fe002a|    @Binding var showFolderPicker: Bool
272|6b0e55|    let theme: Theme
273|b4687f|    
274|504e43|    var body: some View {
275|0865e6|        VStack(alignment: .leading, spacing: 0) {
276|f49fd2|            HStack {
277|8f10b4|                Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
278|a02350|                Spacer()
279|124c35|                Button(action: { showFolderPicker = true }) {
280|98d029|                    Image(systemName: "folder.badge.plus").font(.caption)
281|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
282|035054|                Button(action: { editorCore.showFilePicker = true }) {
283|e2bf82|                    Image(systemName: "doc.badge.plus").font(.caption)
284|af1e18|                }.foregroundColor(theme.sidebarForeground.opacity(0.7))
285|eaa303|                if fileNavigator.fileTree != nil {
286|a67875|                    Button(action: { fileNavigator.refreshFileTree() }) {
287|7cfff4|                        Image(systemName: "arrow.clockwise").font(.caption)
288|681233|                    }.foregroundColor(theme.sidebarForeground.opacity(0.7))
289|4e2d32|                }
290|5cbd4e|            }.padding(.horizontal, 12).padding(.vertical, 8)
291|3070d1|            
292|6b85db|            ScrollView {
293|492557|                VStack(alignment: .leading, spacing: 2) {
294|5cce6c|                    if let tree = fileNavigator.fileTree {
295|46c9f4|                        FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
296|540066|                    } else {
297|b9326c|                        DemoFileTree(editorCore: editorCore, theme: theme)
298|c9717a|                    }
299|d407ec|                }.padding(.horizontal, 8)
300|a7dc16|            }
301|ea6339|        }.background(theme.sidebarBackground)
302|27e597|    }
303|b31277|}
304|adc83b|
305|2efb89|struct RealFileTreeView: View {
306|7345b3|    let node: FileTreeNode
307|ded86f|    let level: Int
308|a33870|    @ObservedObject var fileNavigator: FileSystemNavigator
309|e5f895|    @ObservedObject var editorCore: EditorCore
310|6b0e55|    let theme: Theme
311|b4687f|    
312|17d62f|    var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
313|b4687f|    
314|504e43|    var body: some View {
315|ea9354|        VStack(alignment: .leading, spacing: 2) {
316|37f526|            HStack(spacing: 4) {
317|a37387|                if node.isDirectory {
318|440597|                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
319|8aec79|                        .font(.caption2).frame(width: 12)
320|0b3717|                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
321|740862|                        .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
322|fdd0e2|                } else {
323|df77cf|                    Spacer().frame(width: 12)
324|4e2d32|                }
325|bf729b|                Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
326|8237e3|                    .font(.caption)
327|a7e98c|                    .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
328|926090|                Text(node.name).font(.system(.caption)).lineLimit(1)
329|985367|                    .foregroundColor(theme.sidebarForeground)
330|a02350|                Spacer()
331|a7dc16|            }
332|f3d9fb|            .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
333|68d57d|            .contentShape(Rectangle())
334|835ded|            .onTapGesture {
335|a37387|                if node.isDirectory {
336|8f26cf|                    fileNavigator.toggleExpanded(path: node.url.path)
337|fdd0e2|                } else {
338|13e765|                    editorCore.openFile(from: node.url)
339|4e2d32|                }
340|a7dc16|            }
341|3070d1|            
342|dd4b6d|            if isExpanded && node.isDirectory {
343|4a6742|                ForEach(node.children) { child in
344|8deaf6|                    RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
345|4e2d32|                }
346|a7dc16|            }
347|5f3077|        }
348|27e597|    }
349|b31277|}
350|adc83b|
351|c7c785|struct DemoFileTree: View {
352|e5f895|    @ObservedObject var editorCore: EditorCore
353|6b0e55|    let theme: Theme
354|b4687f|    
355|504e43|    var body: some View {
356|478d8c|        VStack(alignment: .leading, spacing: 4) {
357|dca3c9|            Text("Open a folder to browse files")
358|916793|                .font(.caption)
359|417420|                .foregroundColor(theme.sidebarForeground.opacity(0.6))
360|a48a8d|                .padding(.vertical, 8)
361|3070d1|            
362|eead9e|            DemoFileRow(name: "Welcome.swift", editorCore: editorCore, theme: theme)
363|cbcd60|            DemoFileRow(name: "example.js", editorCore: editorCore, theme: theme)
364|0f2913|            DemoFileRow(name: "example.py", editorCore: editorCore, theme: theme)
365|c07fb7|            DemoFileRow(name: "package.json", editorCore: editorCore, theme: theme)
366|d67c95|            DemoFileRow(name: "index.html", editorCore: editorCore, theme: theme)
367|822f11|            DemoFileRow(name: "styles.css", editorCore: editorCore, theme: theme)
368|5f3077|        }
369|27e597|    }
370|b31277|}
371|adc83b|
372|ab28f0|struct DemoFileRow: View {
373|a5193b|    let name: String
374|e5f895|    @ObservedObject var editorCore: EditorCore
375|6b0e55|    let theme: Theme
376|b4687f|    
377|504e43|    var body: some View {
378|b120fa|        HStack(spacing: 4) {
379|5a4821|            Spacer().frame(width: 12)
380|5a9b2c|            Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
381|0ffef7|            Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
382|1e6289|            Spacer()
383|5f3077|        }
384|60e15e|        .padding(.vertical, 4)
385|55e29b|        .contentShape(Rectangle())
386|cf12c6|        .onTapGesture {
387|9f9063|            if let tab = editorCore.tabs.first(where: { $0.fileName == name }) {
388|166be5|                editorCore.selectTab(id: tab.id)
389|a7dc16|            }
390|5f3077|        }
391|27e597|    }
392|b31277|}
393|adc83b|
394|f3aab4|// MARK: - Tab Bar
395|adc83b|
396|24d9d9|struct IDETabBar: View {
397|e5f895|    @ObservedObject var editorCore: EditorCore
398|6b0e55|    let theme: Theme
399|b4687f|    
400|504e43|    var body: some View {
401|98ab70|        ScrollView(.horizontal, showsIndicators: false) {
402|3b7550|            HStack(spacing: 0) {
403|7512d8|                ForEach(editorCore.tabs) { tab in
404|4b4bd2|                    IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
405|4e2d32|                }
406|5de7cd|                Button(action: { editorCore.addTab() }) {
407|fd7d74|                    Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
408|4e2d32|                }
409|30b85f|            }.padding(.horizontal, 4)
410|962d70|        }.frame(height: 36).background(theme.tabBarBackground)
411|27e597|    }
412|b31277|}
413|adc83b|
414|68fbe9|struct IDETabItem: View {
415|4dc199|    let tab: Tab
416|055123|    let isSelected: Bool
417|e5f895|    @ObservedObject var editorCore: EditorCore
418|6b0e55|    let theme: Theme
419|b4687f|    
420|504e43|    var body: some View {
421|e1c66d|        HStack(spacing: 6) {
422|29528a|            Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
423|a9dd8d|            Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
424|d555ba|                .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
425|5029ae|            if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
426|6effb3|            Button(action: { editorCore.closeTab(id: tab.id) }) {
427|f4c72a|                Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
428|041ce7|                    .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
429|a7dc16|            }
430|5f3077|        }
431|2da2e9|        .padding(.horizontal, 12).padding(.vertical, 6)
432|116b54|        .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
433|7a9052|        .onTapGesture { editorCore.selectTab(id: tab.id) }
434|27e597|    }
435|b31277|}
436|adc83b|
437|f95ca3|// MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
438|adc83b|
439|a178f9|struct IDEEditorView: View {
440|e5f895|    @ObservedObject var editorCore: EditorCore
441|4dc199|    let tab: Tab
442|6b0e55|    let theme: Theme
443|b4687f|    
444|129112|    /// Feature flag for Runestone editor - uses centralized FeatureFlags
445|952908|    private var useRunestoneEditor: Bool { FeatureFlags.useRunestoneEditor }
446|adc83b|
447|834dc8|    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
448|eba335|    @State private var text: String = ""
449|4f0ac8|    @State private var scrollPosition: Int = 0
450|36da68|    @State private var scrollOffset: CGFloat = 0
451|d473fd|    @State private var totalLines: Int = 1
452|bcf90b|    @State private var visibleLines: Int = 20
453|9cb5e9|    @State private var currentLineNumber: Int = 1
454|cc347a|    @State private var currentColumn: Int = 1
455|eee196|    @State private var cursorIndex: Int = 0
456|f97bd7|    @State private var lineHeight: CGFloat = 20  // Updated dynamically based on font size
457|446eb9|    @State private var requestedCursorIndex: Int? = nil
458|5c2aeb|    @State private var requestedLineSelection: Int? = nil
459|adc83b|
460|3977e1|    @StateObject private var autocomplete = AutocompleteManager()
461|4445ec|    @State private var showAutocomplete = false
462|f77a99|    // Code folding removed - will use VS Code tunnel for real folding
463|f453fc|    @StateObject private var findViewModel = FindViewModel()
464|b4687f|    
465|504e43|    var body: some View {
466|94dd27|        VStack(spacing: 0) {
467|8779dd|            // Find/Replace bar
468|2b2a70|            if editorCore.showSearch {
469|38cbe4|                FindReplaceView(viewModel: findViewModel)
470|b768ed|                    .background(theme.tabBarBackground)
471|a7dc16|            }
472|3070d1|            
473|b97232|            BreadcrumbsView(editorCore: editorCore, tab: tab)
474|3070d1|            
475|ca6f75|            GeometryReader { geometry in
476|e60c16|                ZStack(alignment: .topLeading) {
477|7a5371|                HStack(spacing: 0) {
478|91f67b|                    // Simple line numbers gutter (folding/breakpoints removed)
479|8d4059|                    if lineNumbersStyle != "off" {
480|682232|                        LineNumbers(
481|937d74|                            totalLines: totalLines,
482|0f00a6|                            currentLine: currentLineNumber,
483|d6742c|                            scrollOffset: scrollOffset,
484|9f4e9f|                            lineHeight: lineHeight,
485|76e9b6|                            requestedLineSelection: $requestedLineSelection,
486|0acd63|                            theme: theme
487|63214b|                        )
488|4619d2|                        .frame(width: 44)
489|3a838d|                        .background(theme.sidebarBackground.opacity(0.5))
490|c9717a|                    }
491|dd2193|                    
492|3f9dab|                    // Use Runestone for all files including JSON (has TreeSitter JSON support)
493|df925c|                    if false && tab.fileName.hasSuffix(".json") {
494|4229a0|                        // JSON Tree View disabled - using Runestone editor instead
495|daf992|                        JSONTreeView(data: text.data(using: .utf8) ?? Data())
496|f9d830|                            .frame(maxWidth: .infinity, maxHeight: .infinity)
497|96e3a5|                            .background(theme.editorBackground)
498|540066|                    } else {
499|082ddd|                        // Use Runestone for O(log n) performance, or legacy view as fallback
500|e44d33|                        Group {




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 5f719e9a96e2
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 751-1000 of 1407)
────────────────────────────────────────
751|71c2b3|                        if s.insertText != s.displayText && !s.insertText.isEmpty {
752|53d416|                            Text(s.insertText)
753|87ab4e|                                .font(.system(size: 10, design: .monospaced))
754|32bc5b|                                .foregroundColor(theme.editorForeground.opacity(0.55))
755|a9b5f4|                                .lineLimit(1)
756|392b35|                        }
757|c9717a|                    }
758|dcd0bf|                    Spacer()
759|4e2d32|                }
760|41847e|                .padding(.horizontal, 8).padding(.vertical, 6)
761|e72d30|                .background(index == selectedIndex ? theme.selection : Color.clear)
762|1e8a31|                .contentShape(Rectangle())
763|eec06d|                .onTapGesture { onSelectIndex(index) }
764|a7dc16|            }
765|5f3077|        }
766|5260c9|        .frame(width: 260)
767|04ec17|        .background(theme.editorBackground)
768|097147|        .cornerRadius(6)
769|f64ce1|        .shadow(radius: 8)
770|27e597|    }
771|b4687f|    
772|ccd198|    private func icon(for kind: AutocompleteSuggestionKind) -> String {
773|01fe0f|        switch kind {
774|62a12d|        case .keyword: return "key.fill"
775|710dbd|        case .symbol: return "cube.fill"
776|d0a8ab|        case .stdlib: return "curlybraces"
777|c3ed81|        case .member: return "arrow.right.circle.fill"
778|5f3077|        }
779|27e597|    }
780|b4687f|    
781|126b1f|    private func color(for kind: AutocompleteSuggestionKind) -> Color {
782|01fe0f|        switch kind {
783|a51b30|        case .keyword: return .purple
784|8740a1|        case .symbol: return .blue
785|628567|        case .stdlib: return .orange
786|b8e5e8|        case .member: return .green
787|5f3077|        }
788|27e597|    }
789|b31277|}
790|adc83b|
791|4409de|// MARK: - Welcome View
792|adc83b|
793|35ff8c|struct IDEWelcomeView: View {
794|e5f895|    @ObservedObject var editorCore: EditorCore
795|7d30ad|    @ObservedObject var recentFiles: RecentFileManager = .shared
796|fe002a|    @Binding var showFolderPicker: Bool
797|6b0e55|    let theme: Theme
798|b4687f|    
799|504e43|    var body: some View {
800|4d4b46|        ScrollView {
801|92175e|            VStack(spacing: 0) {
802|8ceded|                Spacer().frame(height: 60)
803|216278|                
804|0a052f|                // Logo & Title
805|6194f8|                VStack(spacing: 12) {
806|28467a|                    Image(systemName: "chevron.left.forwardslash.chevron.right")
807|20375b|                        .font(.system(size: 64, weight: .thin))
808|da2fcc|                        .foregroundColor(.accentColor.opacity(0.7))
809|af291e|                    Text("VS Code for iPadOS")
810|331176|                        .font(.system(size: 28, weight: .bold))
811|49a616|                        .foregroundColor(theme.editorForeground)
812|d68666|                    Text("Code anywhere. Build anything.")
813|e4008e|                        .font(.system(size: 14))
814|c9c92a|                        .foregroundColor(theme.editorForeground.opacity(0.5))
815|4e2d32|                }
816|9e1451|                .padding(.bottom, 40)
817|216278|                
818|38781d|                // Main content in columns
819|1ff7c7|                HStack(alignment: .top, spacing: 48) {
820|7da568|                    // Left: Start actions
821|f38358|                    VStack(alignment: .leading, spacing: 16) {
822|97a3c6|                        Text("Start")
823|1a45a2|                            .font(.system(size: 13, weight: .semibold))
824|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
825|d4034e|                            .textCase(.uppercase)
826|956cfe|                        
827|3e5f33|                        WelcomeLink(icon: "doc.badge.plus", title: "New File", shortcut: "\u{2318}N", theme: theme) { editorCore.addTab() }
828|ff3de3|                        WelcomeLink(icon: "folder", title: "Open Folder...", shortcut: "\u{2318}\u{21E7}O", theme: theme) { showFolderPicker = true }
829|af22ad|                        WelcomeLink(icon: "doc", title: "Open File...", shortcut: "\u{2318}O", theme: theme) { editorCore.showFilePicker = true }
830|7f563b|                        WelcomeLink(icon: "arrow.triangle.branch", title: "Clone Repository...", shortcut: nil, theme: theme) { }
831|c6b72d|                        WelcomeLink(icon: "network", title: "Connect to SSH Host...", shortcut: nil, theme: theme) { }
832|c9717a|                    }
833|a50e8e|                    .frame(width: 260)
834|dd2193|                    
835|fb6ef7|                    // Center: Recent
836|f38358|                    VStack(alignment: .leading, spacing: 16) {
837|09b581|                        Text("Recent")
838|1a45a2|                            .font(.system(size: 13, weight: .semibold))
839|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
840|d4034e|                            .textCase(.uppercase)
841|956cfe|                        
842|2dfdd3|                        if recentFiles.recentFiles.isEmpty {
843|2c0bc4|                            Text("No recent files")
844|f4b380|                                .font(.system(size: 13))
845|1df1cd|                                .foregroundColor(theme.editorForeground.opacity(0.3))
846|ebe48f|                                .padding(.vertical, 8)
847|65e2f4|                        } else {
848|3121b3|                            ForEach(recentFiles.recentFiles.prefix(8), id: \.absoluteString) { url in
849|859ef8|                                Button(action: {
850|2e44f8|                                    editorCore.addTab(fileName: url.lastPathComponent, content: "", url: url)
851|a37f0c|                                }) {
852|0334d4|                                    HStack(spacing: 8) {
853|a7ba40|                                        Image(systemName: url.hasDirectoryPath ? "folder.fill" : "doc.fill")
854|d6fd17|                                            .font(.system(size: 12))
855|16ab52|                                            .foregroundColor(.accentColor)
856|62f5b3|                                            .frame(width: 16)
857|e9d9bf|                                        VStack(alignment: .leading, spacing: 1) {
858|2f3f86|                                            Text(url.lastPathComponent)
859|351a6d|                                                .font(.system(size: 13))
860|fd3cf9|                                                .foregroundColor(.accentColor)
861|ebf583|                                                .lineLimit(1)
862|71fb92|                                            Text(url.deletingLastPathComponent().path)
863|c2a1f5|                                                .font(.system(size: 10))
864|4dacfc|                                                .foregroundColor(theme.editorForeground.opacity(0.4))
865|ebf583|                                                .lineLimit(1)
866|eed1d8|                                        }
867|8ab74d|                                    }
868|f83e05|                                }
869|31bef9|                                .buttonStyle(.plain)
870|89d40a|                            }
871|392b35|                        }
872|c9717a|                    }
873|ac3576|                    .frame(width: 280)
874|dd2193|                    
875|74716b|                    // Right: Help & Tips
876|f38358|                    VStack(alignment: .leading, spacing: 16) {
877|f992df|                        Text("Help")
878|1a45a2|                            .font(.system(size: 13, weight: .semibold))
879|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
880|d4034e|                            .textCase(.uppercase)
881|956cfe|                        
882|c46faa|                        WelcomeLink(icon: "terminal", title: "Command Palette", shortcut: "\u{2318}\u{21E7}P", theme: theme) { editorCore.showCommandPalette = true }
883|f1821e|                        WelcomeLink(icon: "keyboard", title: "Keyboard Shortcuts", shortcut: nil, theme: theme) { editorCore.showKeyboardShortcuts = true }
884|149497|                        WelcomeLink(icon: "gear", title: "Settings", shortcut: "\u{2318},", theme: theme) {
885|6da7e1|                            NotificationCenter.default.post(name: .init("ShowSettings"), object: nil)
886|392b35|                        }
887|956cfe|                        
888|c0a3dd|                        Divider().padding(.vertical, 4)
889|956cfe|                        
890|f3e0be|                        Text("Tips")
891|1a45a2|                            .font(.system(size: 13, weight: .semibold))
892|0f4292|                            .foregroundColor(theme.editorForeground.opacity(0.5))
893|d4034e|                            .textCase(.uppercase)
894|956cfe|                        
895|db141c|                        WelcomeTip(icon: "sparkles", text: "Use \u{2318}\u{21E7}A to open the AI assistant", theme: theme)
896|0714f5|                        WelcomeTip(icon: "sidebar.left", text: "\u{2318}B toggles the sidebar", theme: theme)
897|91e7bb|                        WelcomeTip(icon: "magnifyingglass", text: "\u{2318}\u{21E7}F searches across all files", theme: theme)
898|6bf5fa|                        WelcomeTip(icon: "arrow.triangle.branch", text: "Built-in Git with native Swift implementation", theme: theme)
899|c9717a|                    }
900|ac3576|                    .frame(width: 280)
901|4e2d32|                }
902|3570a8|                .padding(.horizontal, 40)
903|216278|                
904|8ceded|                Spacer().frame(height: 60)
905|a7dc16|            }
906|9a9c46|            .frame(maxWidth: .infinity)
907|5f3077|        }
908|04ec17|        .background(theme.editorBackground)
909|27e597|    }
910|b31277|}
911|adc83b|
912|24ea2a|struct WelcomeLink: View {
913|f0e87a|    let icon: String
914|399f36|    let title: String
915|265a5c|    let shortcut: String?
916|6b0e55|    let theme: Theme
917|59027a|    let action: () -> Void
918|b4687f|    
919|6d2ac2|    @State private var isHovering = false
920|b4687f|    
921|504e43|    var body: some View {
922|6f04d8|        Button(action: action) {
923|c0775d|            HStack(spacing: 8) {
924|7b64f6|                Image(systemName: icon)
925|9c904b|                    .font(.system(size: 13))
926|153725|                    .foregroundColor(.accentColor)
927|688547|                    .frame(width: 20)
928|3f8b13|                Text(title)
929|9c904b|                    .font(.system(size: 13))
930|153725|                    .foregroundColor(.accentColor)
931|e1df7b|                if let shortcut = shortcut {
932|dcd0bf|                    Spacer()
933|5e6df6|                    Text(shortcut)
934|1057c9|                        .font(.system(size: 11, design: .rounded))
935|40df1e|                        .foregroundColor(theme.editorForeground.opacity(0.35))
936|4e2d32|                }
937|a7dc16|            }
938|ec0aa4|            .padding(.vertical, 3)
939|68d57d|            .contentShape(Rectangle())
940|5f3077|        }
941|bd8b70|        .buttonStyle(.plain)
942|c115d3|        .onHover { isHovering = $0 }
943|17fe31|        .opacity(isHovering ? 0.8 : 1.0)
944|27e597|    }
945|b31277|}
946|adc83b|
947|bb22f9|struct WelcomeTip: View {
948|f0e87a|    let icon: String
949|e25e12|    let text: String
950|6b0e55|    let theme: Theme
951|b4687f|    
952|504e43|    var body: some View {
953|d6296b|        HStack(spacing: 8) {
954|ed6617|            Image(systemName: icon)
955|a7de34|                .font(.system(size: 11))
956|195e4d|                .foregroundColor(theme.editorForeground.opacity(0.4))
957|c404e7|                .frame(width: 16)
958|6a8caf|            Text(text)
959|ee466d|                .font(.system(size: 12))
960|904c91|                .foregroundColor(theme.editorForeground.opacity(0.5))
961|5f3077|        }
962|27e597|    }
963|b31277|}
964|adc83b|
965|4b4130|struct WelcomeBtn: View {
966|f0e87a|    let icon: String
967|399f36|    let title: String
968|14874c|    let shortcut: String
969|6b0e55|    let theme: Theme
970|59027a|    let action: () -> Void
971|b4687f|    
972|504e43|    var body: some View {
973|6f04d8|        Button(action: action) {
974|f49fd2|            HStack {
975|f2b865|                Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
976|d34e42|                Text(title).foregroundColor(theme.editorForeground)
977|a02350|                Spacer()
978|0f9490|                Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
979|a7dc16|            }
980|a09f6b|            .padding().frame(width: 280)
981|cef0ad|            .background(theme.sidebarBackground)
982|b18c2b|            .cornerRadius(8)
983|9e9bdf|        }.buttonStyle(.plain)
984|27e597|    }
985|b31277|}
986|adc83b|
987|db0271|// MARK: - Command Palette
988|adc83b|
989|e71bec|struct IDECommandPalette: View {
990|e5f895|    @ObservedObject var editorCore: EditorCore
991|3bd3a7|    @Binding var showSettings: Bool
992|fe5153|    @Binding var showTerminal: Bool
993|d901da|    @State private var searchText = ""
994|b4687f|    
995|504e43|    var body: some View {
996|94dd27|        VStack(spacing: 0) {
997|f49fd2|            HStack {
998|41b09a|                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
999|259764|                TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
1000|854fbd|            }.padding().background(Color(UIColor.secondarySystemBackground))


>>>REPORT

# ContentView.swift Analysis (1407 lines)

## Main App Structure

**File:** `VSCodeiPadOS/VSCodeiPadOS/ContentView.swift`

The file is a monolithic SwiftUI view file containing the main `ContentView` and ~15 supporting structs, organized with MARK sections.

### ContentView (lines 10-244) — Top-Level Orchestrator
- **State objects:** `EditorCore` (env object), `FileSystemNavigator`, `ThemeManager`, `WorkspaceTrustManager`, `TunnelManager`
- **State vars:** `showingDocumentPicker`, `showingFolderPicker`, `showSettings`, `showTerminal`, `terminalHeight`, `selectedSidebarTab`, `pendingTrustURL`, `windowTitle`

### Layout Hierarchy (lines 105-200)
```
mainContentView
├── if tunnelManager.isConnected → VSCodeTunnelView (full takeover)
└── else → ZStack
    ├── mainLayout
    │   ├── HStack
    │   │   ├── IDEActivityBar (left icon rail)
    │   │   ├── sidebarContent (conditional, width: editorCore.sidebarWidth)
    │   │   │   ├── case 0: IDESidebarFiles
    │   │   │   ├── case 1: SidebarSearchView
    │   │   │   ├── case 2: GitView
    │   │   │   └── case 3: DebugView
    │   │   └── VStack
    │   │       ├── IDETabBar
    │   │       ├── IDEEditorView / IDEWelcomeView
    │   │       └── StatusBarView
    │   └── PanelView (terminal, conditional)
    ├── overlayViews (command palette, quick open, go-to-symbol, AI assistant, go-to-line, workspace trust dialog, keyboard shortcuts sheet)
    └── NotificationToastOverlay
```

## Features WIRED UP (functional)

1. **File operations** (lines 30-47): Document picker, folder picker, Save As dialog — all use `UIDocumentPickerViewController` wrappers (lines 1125-1239)
2. **Tab management** (lines 396-435): `IDETabBar` + `IDETabItem` with select/close/add/unsaved indicator
3. **Editor** (lines 439-678): `IDEEditorView` with dual-engine support:
   - `RunestoneEditorView` (primary, behind `FeatureFlags.useRunestoneEditor`, line 445)
   - `SyntaxHighlightingTextView` (legacy fallback)
4. **Autocomplete** (lines 460-461, 573-583, 630-648, 733-789): `AutocompleteManager` + `AutocompletePopup` with keyword/symbol/stdlib/member kinds
5. **Line numbers** (lines 682-729): `LineNumbers` with 3 styles: "on", "relative", "interval" via `@AppStorage`
6. **Minimap** (lines 586-601): `MinimapView` for non-JSON files, 80px wide, with scroll sync
7. **Sticky headers** (lines 605-616): `StickyHeaderView` (FEAT-040)
8. **Inlay hints** (lines 618-629): `InlayHintsOverlay` for type hints/parameter names
9. **Find/Replace** (lines 468-471): `FindReplaceView` with `FindViewModel`
10. **Breadcrumbs** (line 473): `BreadcrumbsView`
11. **Notification handlers** (lines 57-95): 18 `onReceive` handlers for keyboard shortcuts — command palette, terminal, sidebar, quick open, go-to-symbol, go-to-line, AI assistant, new file, save, close tab, find, zoom in/out, run without debugging, run WASM, run JavaScript, start debugging
12. **Workspace trust** (lines 183-193, line 24): `WorkspaceTrustDialog` + `WorkspaceTrustManager` — gates folder opening
13. **VS Code tunnel mode** (lines 102-119): `TunnelManager.isConnected` → `VSCodeTunnelView` takes over entire screen
14. **WASM execution** (lines 1332-1370): `runSampleWASM()` loads bundled `test.wasm` via `WASMRunner`
15. **JavaScript execution** (lines 1373-1400): `runJavaScript()` via `JSRunner` with console capture
16. **Debugging** (lines 83-95): `DebugManager.shared.startDebugging()` for `.js` files only
17. **Code execution** (lines 70-76): `CodeExecutionService.shared.executeCurrentFile()`
18. **Git integration** (line 206, line 237): `GitManager.shared.setWorkingDirectory()` on workspace open; `GitView()` in sidebar tab 2
19. **Welcome view** (lines 793-910): 3-column layout — Start actions, Recent files (via `RecentFileManager`), Help & Tips
20. **Window title** (lines 210-227): Updates with filename, unsaved indicator, posts `WindowTitleDidChange`
21. **Theme** (line 13, 26): `ThemeManager.shared`, `theme.editorBackground` etc. used throughout
22. **Settings** (line 40): `.sheet` presenting `SettingsView`

## Features PRESENT BUT INCOMPLETE / STUBBED

1. **AI Assistant** (lines 1074-1117): `IDEAIAssistant` has a fake echo response — `sendMessage()` at line 1113-1115 just replies with `"I can help with '\(input)'! What specifically would you like to know?"` after 0.8s delay. **No real AI backend.**
2. **Sidebar Search** (lines 1243-1326): `SidebarSearchView` has search/replace UI but returns **hardcoded fake results** (line 1323): `[("ContentView.swift", 15, "Text(...)"), ("main.swift", 8, "// ...")]`. No actual file search.
3. **Clone Repository** (line 830): Welcome link has **empty action** `{ }`.
4. **Connect to SSH Host** (line 831): Welcome link has **empty action** `{ }`.
5. **Go To Symbol** (line 169): `GoToSymbolView` is wired up but `onGoToLine` callback is `{ _ in }` — **no-op**.
6. **Go To Line** (line 180): `GoToLineView` is wired up but `onGoToLine` callback is `{ _ in }` — **no-op**.
7. **IDEQuickOpen** (lines 1034-1057): Only searches open tabs (line 1047: `editorCore.tabs`), **not filesystem files**. Note: the overlay at line 163 uses a different `QuickOpenView` — this `IDEQuickOpen` struct appears unused/legacy.
8. **IDECommandPalette** (lines 989-1016): Has 8 hardcoded commands, no filtering by `searchText`. The overlay at line 157 uses a different `CommandPaletteView` — this struct appears unused/legacy.
9. **JSON Tree View** (line 493): Disabled with `if false &&` — commented out in favor of Runestone editor.
10. **Code folding** (lines 462, 578, 654, 658): Explicitly removed — comments say "using VS Code tunnel for real folding".

## Structural Issues

1. **Duplicate/legacy structs**: `IDECommandPalette` (line 989) and `IDEQuickOpen` (line 1034) and `IDEAIAssistant` (line 1074) appear to be legacy versions — the overlays reference different views (`CommandPaletteView`, `QuickOpenView`, `AIAssistantView`). These are dead code.
2. **Monolithic file**: 1407 lines with ~15 structs that could be separate files.
3. **Two `.onAppear` blocks** on `IDEEditorView` body (lines 652 and 670) — both will fire but it's messy.

## Summary

| Category | Status |
|----------|--------|
| Editor (Runestone + legacy) | ✅ Fully wired |
| Tab management | ✅ Fully wired |
| File open/save/save-as | ✅ Fully wired |
| File tree (real filesystem) | ✅ Fully wired |
| Keyboard shortcuts (18) | ✅ Fully wired |
| Terminal/Panel | ✅ Fully wired |
| Minimap, sticky headers, inlay hints | ✅ Fully wired |
| Find/Replace | ✅ Fully wired |
| Autocomplete | ✅ Fully wired |
| Theme system | ✅ Fully wired |
| Workspace trust | ✅ Fully wired |
| VS Code tunnel mode | ✅ Fully wired |
| JS execution + WASM | ✅ Fully wired |
| Git sidebar | ✅ View wired |
| Debug sidebar | ✅ View wired |
| AI Assistant | ⚠️ Stub (fake echo) |
| Sidebar file search | ⚠️ Stub (hardcoded results) |
| Go To Symbol / Go To Line | ⚠️ No-op callbacks |
| Clone Repository | ❌ Empty action |
| SSH Host connection | ❌ Empty action |
| Code folding | ❌ Removed (deferred to tunnel) |
| Legacy structs (IDECommandPalette, IDEQuickOpen, IDEAIAssistant) | 🗑️ Dead code |

>>>END
