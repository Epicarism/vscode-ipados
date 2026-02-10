# Agent: scroll-content-fix
**Status:** done
**Tokens:** 117,768
**Cost:** $0.0000
**Time:** 2026-02-10T02:59:07.422Z

## Task
Fix scroll jitter in VSCodeiPadOS. Check ContentView.swift for any @State or @Binding for scrollPosition that might cause feedback loops. The minimap scroll sync might also cause issues - check MinimapView.swift. Goal: smooth scrolling without editor fighting user. Build after fix.

## Response
>>>TOOL list_dir
{"path":"/Users/danielswagg/PLAYGROUND/vscode-ipados"}
>>>END>>>TOOL search
{"query":"ContentView.swift", "glob":"**/*"}
>>>END>>>TOOL search
{"query":"MinimapView.swift", "glob":"**/*"}
>>>END>>>END>>>TOOL list_dir
{"path":"/Users/danielswagg/PLAYGROUND/vscode-ipados"}
>>>END

>>>TOOL list_dir
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":1,"end_line":260}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift","start_line":1,"end_line":260}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 2-260 of 1064)
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
41:                         if let tab = editorCore.activeTab {
42:                             IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
43:                                 .id(tab.id)  // Force view recreation when tab changes
44:                         } else {
45:                             IDEWelcomeView(editorCore: editorCore, showFolderPicker: $showingFolderPicker, theme: theme)
46:                         }
47:                         
48:                         StatusBarView(editorCore: editorCore)
49:                     }
50:                 }
51:                 
52:                 if showTerminal {
53:                     PanelView(isVisible: $showTerminal, height: $terminalHeight)
54:                 }
55:             }
56:             .background(theme.editorBackground)
57:             
58:             // Overlays - Command Palette (Cmd+Shift+P)
59:             if editorCore.showCommandPalette {
60:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showCommandPalette = false }
61:                 CommandPaletteView(editorCore: editorCore, showSettings: $showSettings, showTerminal: $showTerminal)
62:             }
63:             
64:             // Quick Open (Cmd+P)
65:             if editorCore.showQuickOpen {
66:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showQuickOpen = false }
67:                 QuickOpenView(editorCore: editorCore, fileNavigator: fileNavigator)
68:             }
69:             
70:             // Go To Symbol (Cmd+Shift+O)
71:             if editorCore.showGoToSymbol {
72:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToSymbol = false }
73:                 GoToSymbolView(editorCore: editorCore, onGoToLine: { _ in })
74:             }
75:             
76:             // AI Assistant
77:             if editorCore.showAIAssistant {
78:                 HStack { Spacer(); IDEAIAssistant(editorCore: editorCore, theme: theme).frame(width: 400, height: 500).padding() }
79:             }
80:             
81:             // Go To Line (Ctrl+G)
82:             if editorCore.showGoToLine {
83:                 Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { editorCore.showGoToLine = false }
84:                 GoToLineView(isPresented: $editorCore.showGoToLine, onGoToLine: { _ in })
85:             }
86:             
87:             // Workspace Trust Dialog
88:             if let trustURL = pendingTrustURL {
89:                 Color.black.opacity(0.4).ignoresSafeArea()
90:                 WorkspaceTrustDialog(workspaceURL: trustURL, onTrust: {
91:                     trustManager.trust(url: trustURL)
92:                     finishOpeningWorkspace(trustURL)
93:                     pendingTrustURL = nil
94:                 }, onCancel: {
95:                     pendingTrustURL = nil
96:                 })
97:             }
98:         }
99:         .sheet(isPresented: $showingDocumentPicker) { IDEDocumentPicker(editorCore: editorCore) }
100:         .sheet(isPresented: $showingFolderPicker) {
101:             IDEFolderPicker(fileNavigator: fileNavigator) { url in
102:                 if trustManager.isTrusted(url: url) {
103:                     finishOpeningWorkspace(url)
104:                 } else {
105:                     pendingTrustURL = url
106:                 }
107:             }
108:         }
109:         .sheet(isPresented: $showSettings) { SettingsView(themeManager: themeManager) }
110:         .onChange(of: editorCore.showFilePicker) { show in showingDocumentPicker = show }
111:         .onChange(of: editorCore.activeTab?.fileName) { newFileName in
112:             updateWindowTitle()
113:         }
114:         .onChange(of: editorCore.tabs.count) { _ in
115:             updateWindowTitle()
116:         }
117:         .onAppear {
118:             updateWindowTitle()
119:         }
120:         // MARK: - Notification Handlers for Menu Keyboard Shortcuts
121:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowCommandPalette"))) { _ in
122:             editorCore.showCommandPalette = true
123:         }
124:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleTerminal"))) { _ in
125:             showTerminal.toggle()
126:         }
127:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleSidebar"))) { _ in
128:             editorCore.toggleSidebar()
129:         }
130:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowQuickOpen"))) { _ in
131:             editorCore.showQuickOpen = true
132:         }
133:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToSymbol"))) { _ in
134:             editorCore.showGoToSymbol = true
135:         }
136:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowGoToLine"))) { _ in
137:             editorCore.showGoToLine = true
138:         }
139:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAIAssistant"))) { _ in
140:             editorCore.showAIAssistant = true
141:         }
142:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewFile"))) { _ in
143:             editorCore.addTab()
144:         }
145:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveFile"))) { _ in
146:             editorCore.saveActiveTab()
147:         }
148:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CloseTab"))) { _ in
149:             if let id = editorCore.activeTabId { editorCore.closeTab(id: id) }
150:         }
151:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowFind"))) { _ in
152:             editorCore.showSearch = true
153:         }
154:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ZoomIn"))) { _ in
155:             editorCore.zoomIn()
156:         }
157:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ZoomOut"))) { _ in
158:             editorCore.zoomOut()
159:         }
160:         .environmentObject(themeManager)
161:         .environmentObject(editorCore)
162:     }
163:     
164:     private func finishOpeningWorkspace(_ url: URL) {
165:         fileNavigator.loadFileTree(at: url)
166:         Task { @MainActor in
167:             LaunchManager.shared.setWorkspaceRoot(url)
168:             GitManager.shared.setWorkingDirectory(url)
169:         }
170:     }
171:     
172:     private func updateWindowTitle() {
173:         if let activeTab = editorCore.activeTab {
174:             let fileName = activeTab.fileName
175:             let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
176:             windowTitle = "\(unsavedIndicator)\(fileName) - VS Code"
177:         } else if !editorCore.tabs.isEmpty {
178:             windowTitle = "VS Code"
179:         } else {
180:             windowTitle = "Welcome - VS Code"
181:         }
182:         
183:         // Notify the app of the title change
184:         NotificationCenter.default.post(
185:             name: NSNotification.Name("WindowTitleDidChange"),
186:             object: nil,
187:             userInfo: ["title": windowTitle]
188:         )
189:     }
190:     
191:     @ViewBuilder
192:     private var sidebarContent: some View {
193:         switch selectedSidebarTab {
194:         case 0:
195:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
196:         case 1:
197:             SidebarSearchView(theme: theme)
198:         case 2:
199:             GitView()
200:         case 3:
201:             DebugView()
202:         default:
203:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
204:         }
205:     }
206: }
207: 
208: // MARK: - Activity Bar
209: 
210: 
211: 
212: struct BarButton: View {
213:     let icon: String
214:     let isSelected: Bool
215:     let theme: Theme
216:     let action: () -> Void
217:     
218:     var body: some View {
219:         Button(action: action) {
220:             Image(systemName: icon)
221:                 .font(.system(size: 22))
222:                 .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
223:                 .frame(width: 48, height: 48)
224:         }
225:     }
226: }
227: 
228: // MARK: - Sidebar with Real File System
229: 
230: struct IDESidebarFiles: View {
231:     @ObservedObject var editorCore: EditorCore
232:     @ObservedObject var fileNavigator: FileSystemNavigator
233:     @Binding var showFolderPicker: Bool
234:     let theme: Theme
235:     
236:     var body: some View {
237:         VStack(alignment: .leading, spacing: 0) {
238:             HStack {
239:                 Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
240:                 Spacer()
241:                 Button(action: { showFolderPicker = true }) {
242:                     Image(systemName: "folder.badge.plus").font(.caption)
243:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
244:                 Button(action: { editorCore.showFilePicker = true }) {
245:                     Image(systemName: "doc.badge.plus").font(.caption)
246:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
247:                 if fileNavigator.fileTree != nil {
248:                     Button(action: { fileNavigator.refreshFileTree() }) {
249:                         Image(systemName: "arrow.clockwise").font(.caption)
250:                     }.foregroundColor(theme.sidebarForeground.opacity(0.7))
251:                 }
252:             }.padding(.horizontal, 12).padding(.vertical, 8)
253:             
254:             ScrollView {
255:                 VStack(alignment: .leading, spacing: 2) {
256:                     if let tree = fileNavigator.fileTree {
257:                         FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
258:                     } else {
259:                         DemoFileTree(editorCore: editorCore, theme: theme)
260:                     }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift (lines 2-260 of 472)
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
221: 
222:         // Render lines starting from startLine (scrolls with document)
223:         let endLine = min(startLine + visibleLines + 1, lineCount)
224:         
225:         // Guard against invalid range (endLine must be >= startLine)
226:         guard endLine >= startLine else { return }
227:         
228:         for i in startLine..<endLine {
229:             let displayIndex = i - startLine
230:             let y = paddingY + (CGFloat(displayIndex) * pixelsPerLine)
231:             if y > size.height { break }
232: 
233:             let line = lines.indices.contains(i) ? lines[i] : Substring("")
234:             let tokens = tokenize(line)
235: 
236:             var x = paddingX
237:             let yAligned = y.rounded(FloatingPointRoundingRule.down)
238: 
239:             if tokens.isEmpty {
240:                 // Render faint whitespace line.
241:                 let rect = CGRect(x: x, y: yAligned, width: max(4, contentWidth * 0.15), height: barHeight)
242:                 context.fill(Path(rect), with: .color(Color(white: 0.45).opacity(0.10)))
243:                 continue
244:             }
245: 
246:             for token in tokens {
247:                 guard x < (paddingX + contentWidth) else { break }
248:                 let w = max(1, CGFloat(token.text.count) * charWidth)
249:                 let rect = CGRect(x: x, y: yAligned, width: min(w, paddingX + contentWidth - x), height: barHeight)
250:                 context.fill(Path(rect), with: .color(token.color.opacity(0.80)))
251:                 x += w
252:             }
253:         }
254:     }
255: 
256:     // MARK: - Syntax highlighting (lightweight)
257: 
258:     private struct Token {
259:         enum Kind {
260:             case plain


>>>TOOL search
{"query":"scrollPosition", "glob":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift"}
>>>END
>>>TOOL search
{"query":"scrollPosition", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 6 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:403: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:436: scrollOffset: CGFloat(scrollPosition) * lineHeight,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:455: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:503: scrollOffset: CGFloat(scrollPosition) * lineHeight,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:510: scrollPosition = max(0, min(newLine, totalLines - 1))
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:521: currentLine: scrollPosition,

---

[search]
Found 30 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:403: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:436: scrollOffset: CGFloat(scrollPosition) * lineHeight,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:455: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:503: scrollOffset: CGFloat(scrollPosition) * lineHeight,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:510: scrollPosition = max(0, min(newLine, totalLines - 1))
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:521: currentLine: scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:491: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:559: .offset(y: -CGFloat(scrollPosition) * lineHeight)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:569: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:584: splitManager.syncScrollOffset(CGFloat(scrollPosition) * lineHeight, fromPaneId: pane.id)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:591: scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:600: currentLine: scrollPosition, // Using scrollPosition as approximate top line
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:616: .frame(height: max(0, CGFloat(peekState.sourceLine - scrollPosition) * lineHeight + lineHeight + 20))
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:648: scrollPosition = Int(newOffset / lineHeight)
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":360,"end_line":560}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":1,"end_line":240}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":450,"end_line":720}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 361-560 of 1064)
────────────────────────────────────────
361:                     IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
362:                 }
363:                 Button(action: { editorCore.addTab() }) {
364:                     Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
365:                 }
366:             }.padding(.horizontal, 4)
367:         }.frame(height: 36).background(theme.tabBarBackground)
368:     }
369: }
370: 
371: struct IDETabItem: View {
372:     let tab: Tab
373:     let isSelected: Bool
374:     @ObservedObject var editorCore: EditorCore
375:     let theme: Theme
376:     
377:     var body: some View {
378:         HStack(spacing: 6) {
379:             Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
380:             Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-240 of 1931)
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 451-720 of 774)
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
591:                     scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
592:                     scrollViewHeight: .constant(geometry.size.height),
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


>>>TOOL search
{"query":"lastKnownScrollPosition", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"scrollViewDidScroll", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":240,"end_line":420}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 6 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:232: if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:233: // Update lastKnownScrollPosition FIRST to prevent race condition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:235: context.coordinator.lastKnownScrollPosition = scrollPosition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:273: var lastKnownScrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:392: // updateUIView sees old binding value != lastKnownScrollPosition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:394: lastKnownScrollPosition = line

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:346: func scrollViewDidScroll(_ scrollView: UIScrollView) {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 241-420 of 1946)
────────────────────────────────────────
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
321:             updateCursorPosition(textView)
322:         }
323:         
324:         func textViewDidChangeSelection(_ textView: UITextView) {
325:             if !isUpdatingFromMinimap {
326:                 updateCursorPosition(textView)
327:                 updateScrollPosition(textView)
328: 
329:                 // FEAT-044: Matching bracket highlight
330:                 updateMatchingBracketHighlight(textView)
331: 
332:                 // Trigger redraw so current-line highlight/indent guides track the caret
333:                 (textView as? EditorTextView)?.setNeedsDisplay()
334: 
335:                 // Update selection in EditorCore for multi-cursor support
336:                 let range = textView.selectedRange
337:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
338: 
339:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
340:                 if !parent.editorCore.multiCursorState.isMultiCursor {
341:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
342:                 }
343:             }
344:         }
345:         
346:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
347:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
348:             
349:             // Mark that user is actively scrolling - prevents updateUIView from fighting back
350:             isUserScrolling = true
351:             userScrollDebouncer?.invalidate()
352:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
353:                 self?.isUserScrolling = false
354:             }
355:             
356:             updateScrollPosition(textView)
357:         }
358:         
359:         func updateLineCount(_ textView: UITextView) {
360:             let lines = textView.text.components(separatedBy: .newlines)
361:             DispatchQueue.main.async {
362:                 self.parent.totalLines = max(1, lines.count)
363:             }
364:         }
365:         
366:         func updateCursorPosition(_ textView: UITextView) {
367:             guard let selectedRange = textView.selectedTextRange else { return }
368:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
369:              
370:              let text = textView.text ?? ""
371:              let prefix = String(text.prefix(cursorPosition))
372:              let lines = prefix.components(separatedBy: .newlines)
373:              
374:              let lineNumber = lines.count
375:              let column = (lines.last?.count ?? 0) + 1
376:              
377:              DispatchQueue.main.async {
378:                  self.parent.currentLineNumber = lineNumber
379:                  self.parent.currentColumn = column
380:                  self.parent.cursorIndex = cursorPosition
381:              }
382:         }
383:         
384:         func updateScrollPosition(_ textView: UITextView) {
385:             guard let font = textView.font else { return }
386:             let lineHeight = font.lineHeight
387:             let scrollOffset = textView.contentOffset.y
388:             let line = Int(scrollOffset / lineHeight)
389:             
390:             // Update both synchronously to prevent feedback loop:
391:             // If we update parent.scrollPosition async, there's a race where
392:             // updateUIView sees old binding value != lastKnownScrollPosition
393:             // and scrolls back to the old position, causing jaggy scrolling.
394:             lastKnownScrollPosition = line
395:             parent.scrollPosition = line
396:         }
397:         
398:         func scrollToLine(_ line: Int, in textView: UITextView) {
399:             guard !isUpdatingFromMinimap else { return }
400:             isUpdatingFromMinimap = true
401:             
402:             let lines = textView.text.components(separatedBy: .newlines)
403:             guard line >= 0 && line < lines.count else {
404:                 isUpdatingFromMinimap = false
405:                 return
406:             }
407:             
408:             var characterPosition = 0
409:             for i in 0..<line {
410:                 characterPosition += lines[i].count + 1
411:             }
412:             
413:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
414:                 let rect = textView.caretRect(for: position)
415:                 let targetY = max(0, rect.origin.y)
416:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
417:             }
418:             
419:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
420:                 self.isUpdatingFromMinimap = false


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift","start_line":260,"end_line":472}
>>>END
>>>TOOL search
{"query":"init(", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift (lines 261-472 of 472)
────────────────────────────────────────
261:             case keyword
262:             case string
263:             case comment
264:             case number
265:             case typeName
266:         }
267: 
268:         var text: Substring
269:         var kind: Kind
270: 
271:         var color: Color {
272:             switch kind {
273:             case .plain:
274:                 return Color(white: 0.70)
275:             case .keyword:
276:                 return Color(red: 0.78, green: 0.53, blue: 0.95) // purple-ish
277:             case .string:
278:                 return Color(red: 0.80, green: 0.72, blue: 0.43) // yellow-ish
279:             case .comment:
280:                 return Color(red: 0.46, green: 0.60, blue: 0.50) // green-ish
281:             case .number:
282:                 return Color(red: 0.40, green: 0.73, blue: 0.92) // blue-ish
283:             case .typeName:
284:                 return Color(red: 0.45, green: 0.83, blue: 0.70) // teal-ish
285:             }
286:         }
287:     }
288: 
289:     private func makeAttributedLine(from line: Substring, fontSize: CGFloat) -> AttributedString {
290:         let tokens = tokenize(line)
291: 
292:         var out = AttributedString()
293:         for token in tokens {
294:             var chunk = AttributedString(String(token.text))
295:             chunk.font = .system(size: fontSize, weight: .regular, design: .monospaced)
296:             chunk.foregroundColor = token.color
297:             out.append(chunk)
298:         }
299: 
300:         if out.characters.isEmpty {
301:             // Preserve a tiny amount of "whitespace presence" so empty lines still show.
302:             var chunk = AttributedString(" ")
303:             chunk.font = .system(size: fontSize, weight: .regular, design: .monospaced)
304:             chunk.foregroundColor = Color(white: 0.7).opacity(0.25)
305:             out.append(chunk)
306:         }
307: 
308:         return out
309:     }
310: 
311:     private func tokenize(_ line: Substring) -> [Token] {
312:         // Extremely lightweight tokenizer:
313:         // - full-line comment if first non-space is # (python-like)
314:         // - inline comment starting at //
315:         // - strings in "..." or '...'
316:         // - numbers
317:         // - keywords
318:         // - PascalCase tokens treated as type names
319:         var tokens: [Token] = []
320:         var i = line.startIndex
321: 
322:         func peek(_ offset: Int = 0) -> Character? {
323:             var idx = i
324:             for _ in 0..<offset {
325:                 guard idx < line.endIndex else { return nil }
326:                 idx = line.index(after: idx)
327:             }
328:             return idx < line.endIndex ? line[idx] : nil
329:         }
330: 
331:         func advance(_ n: Int = 1) {
332:             for _ in 0..<n {
333:                 guard i < line.endIndex else { return }
334:                 i = line.index(after: i)
335:             }
336:         }
337: 
338:         // Detect python/shebang-like comment lines: first non-whitespace is '#'
339:         if let firstNonSpace = line.firstIndex(where: { !$0.isWhitespace }),
340:            line[firstNonSpace] == "#" {
341:             tokens.append(Token(text: line[line.startIndex..<line.endIndex], kind: .comment))
342:             return tokens
343:         }
344: 
345:         while i < line.endIndex {
346:             let ch = line[i]
347: 
348:             // Inline comment: //
349:             if ch == "/", peek(1) == "/" {
350:                 let range = i..<line.endIndex
351:                 tokens.append(Token(text: line[range], kind: .comment))
352:                 return tokens
353:             }
354: 
355:             // Whitespace
356:             if ch.isWhitespace {
357:                 let start = i
358:                 while i < line.endIndex, line[i].isWhitespace { advance() }
359:                 tokens.append(Token(text: line[start..<i], kind: .plain))
360:                 continue
361:             }
362: 
363:             // String literals
364:             if ch == "\"" || ch == "'" {
365:                 let quote = ch
366:                 let start = i
367:                 advance()
368:                 var escaped = false
369:                 while i < line.endIndex {
370:                     let c = line[i]
371:                     if escaped {
372:                         escaped = false
373:                         advance()
374:                         continue
375:                     }
376:                     if c == "\\" {
377:                         escaped = true
378:                         advance()
379:                         continue
380:                     }
381:                     if c == quote {
382:                         advance()
383:                         break
384:                     }
385:                     advance()
386:                 }
387:                 tokens.append(Token(text: line[start..<i], kind: .string))
388:                 continue
389:             }
390: 
391:             // Numbers
392:             if ch.isNumber {
393:                 let start = i
394:                 while i < line.endIndex, line[i].isNumber || line[i] == "." { advance() }
395:                 tokens.append(Token(text: line[start..<i], kind: .number))
396:                 continue
397:             }
398: 
399:             // Identifiers / keywords
400:             if ch.isLetter || ch == "_" {
401:                 let start = i
402:                 advance()
403:                 while i < line.endIndex {
404:                     let c = line[i]
405:                     if c.isLetter || c.isNumber || c == "_" { advance() } else { break }
406:                 }
407:                 let word = line[start..<i]
408:                 let kind: Token.Kind
409: 
410:                 if isKeyword(word) {
411:                     kind = .keyword
412:                 } else if looksLikeTypeName(word) {
413:                     kind = .typeName
414:                 } else {
415:                     kind = .plain
416:                 }
417: 
418:                 tokens.append(Token(text: word, kind: kind))
419:                 continue
420:             }
421: 
422:             // Operators / punctuation
423:             let start = i
424:             advance()
425:             tokens.append(Token(text: line[start..<i], kind: .plain))
426:         }
427: 
428:         return tokens
429:     }
430: 
431:     private func isKeyword(_ word: Substring) -> Bool {
432:         // Small superset of common Swift/JS/Python keywords.
433:         // (We can't depend on a full parser here.)
434:         let keywords: Set<String> = [
435:             "import", "export", "from", "as",
436:             "struct", "class", "enum", "protocol", "extension", "func", "var", "let",
437:             "if", "else", "for", "while", "repeat", "switch", "case", "default",
438:             "break", "continue", "return", "throw", "throws", "try", "catch",
439:             "do", "in", "where", "guard", "defer",
440:             "public", "private", "fileprivate", "internal", "open",
441:             "static", "final", "override", "mutating", "nonmutating",
442:             "async", "await",
443:             "true", "false", "nil",
444:             "self", "super",
445:             // JS/Python-ish
446:             "const", "function", "async", "await", "new", "this",
447:             "def", "pass", "lambda", "None"
448:         ]
449:         return keywords.contains(String(word))
450:     }
451: 
452:     private func looksLikeTypeName(_ word: Substring) -> Bool {
453:         // Simple heuristic: PascalCase (leading uppercase).
454:         guard let first = word.first else { return false }
455:         return first.isUppercase
456:     }
457: 
458:     // MARK: - Diff colors
459: 
460:     private func diffColor(for kind: MinimapDiffIndicator.Kind) -> Color {
461:         switch kind {
462:         case .added:
463:             return Color.green
464:         case .modified:
465:             return Color.red
466:         case .deleted:
467:             // VS Code uses red-ish for deletions too; keep distinct via slightly different tone.
468:             return Color(red: 1.0, green: 0.35, blue: 0.35)
469:         }
470:     }
471: }
472: 

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift:47: init(lineRange: Range<Int>, kind: Kind) {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":210,"end_line":250}
>>>END
>>>TOOL search
{"query":"setContentOffset(CGPoint", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"animated: true", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 211-250 of 1946)
────────────────────────────────────────
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

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:416: textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:416: textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)


>>>TOOL search
{"query":"struct MinimapView", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/Minimap.swift","start_line":1,"end_line":220}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MinimapView.swift:8: struct MinimapView: View {

---

[read_file]
Error: File not found: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/Minimap.swift


>>>TOOL search
{"query":"scrollToAndSelectLine", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"scrollToLine(", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":420,"end_line":560}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:248: context.coordinator.scrollToAndSelectLine(requested, in: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:461: func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {

---

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:241: context.coordinator.scrollToLine(scrollPosition, in: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:435: func scrollToLine(_ line: Int, in textView: UITextView) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:476: scrollToLine(line, in: textView)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 421-560 of 1983)
────────────────────────────────────────
421:         func updateScrollPosition(_ textView: UITextView) {
422:             guard let font = textView.font else { return }
423:             let lineHeight = font.lineHeight
424:             let scrollOffset = textView.contentOffset.y
425:             let line = Int(scrollOffset / lineHeight)
426:             
427:             // Update both synchronously to prevent feedback loop:
428:             // If we update parent.scrollPosition async, there's a race where
429:             // updateUIView sees old binding value != lastKnownScrollPosition
430:             // and scrolls back to the old position, causing jaggy scrolling.
431:             lastKnownScrollPosition = line
432:             parent.scrollPosition = line
433:         }
434:         
435:         func scrollToLine(_ line: Int, in textView: UITextView) {
436:             guard !isUpdatingFromMinimap else { return }
437:             isUpdatingFromMinimap = true
438:             
439:             let lines = textView.text.components(separatedBy: .newlines)
440:             guard line >= 0 && line < lines.count else {
441:                 isUpdatingFromMinimap = false
442:                 return
443:             }
444:             
445:             var characterPosition = 0
446:             for i in 0..<line {
447:                 characterPosition += lines[i].count + 1
448:             }
449:             
450:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
451:                 let rect = textView.caretRect(for: position)
452:                 let targetY = max(0, rect.origin.y)
453:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
454:             }
455:             
456:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
457:                 self.isUpdatingFromMinimap = false
458:             }
459:         }
460: 
461:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
462:             let lines = textView.text.components(separatedBy: .newlines)
463:             guard line >= 0 && line < lines.count else { return }
464: 
465:             var characterPosition = 0
466:             for i in 0..<line {
467:                 characterPosition += lines[i].count + 1
468:             }
469: 
470:             // FEAT-041: select entire line (excluding trailing newline)
471:             let lineLength = (lines[line] as NSString).length
472:             let range = NSRange(location: characterPosition, length: lineLength)
473:             textView.selectedRange = range
474: 
475:             // Ensure it's visible
476:             scrollToLine(line, in: textView)
477: 
478:             // Update SwiftUI state
479:             updateCursorPosition(textView)
480:             updateScrollPosition(textView)
481:         }
482: 
483:         func applySyntaxHighlighting(to textView: UITextView) {
484:             let theme = ThemeManager.shared.currentTheme
485:             lastThemeId = theme.id
486: 
487:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
488:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
489: 
490:             let selectedRange = textView.selectedRange
491:             textView.attributedText = attributedText
492:             textView.selectedRange = selectedRange
493: 
494:             // Set typing attributes so newly typed characters have correct base styling
495:             // This prevents flicker during the debounce period before full highlighting runs
496:             let fontSize = parent.editorCore.editorFontSize
497:             textView.typingAttributes = [
498:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
499:                 .foregroundColor: UIColor(theme.editorForeground)
500:             ]
501: 
502:             // FEAT-044: restore matching bracket highlight after re-attributing text
503:             updateMatchingBracketHighlight(textView)
504:         }
505:         
506:         func handlePeekDefinition(in textView: UITextView) {
507:             guard let selectedRange = textView.selectedTextRange else { return }
508:             let text = textView.text ?? ""
509:             
510:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
511:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
512:                  
513:                  let prefix = String(text.prefix(location))
514:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
515:                  
516:                  parent.editorCore.triggerPeekDefinition(
517:                      file: parent.filename,
518:                      line: sourceLine,
519:                      content: text,
520:                      sourceLine: sourceLine
521:                  )
522:             }
523:         }
524:         
525:         func handleEscape() {
526:             if parent.editorCore.peekState != nil {
527:                 parent.editorCore.closePeekDefinition()
528:             } else {
529:                 parent.editorCore.escapeMultiCursor()
530:             }
531:         }
532:         
533:         func handleGoToDefinition(in textView: UITextView) {
534:             // Reuse the peek definition logic for now
535:             handlePeekDefinition(in: textView)
536:         }
537:         
538:         func handleFindReferences(in textView: UITextView) {
539:             guard let selectedRange = textView.selectedTextRange else { return }
540:             let text = textView.text ?? ""
541:             
542:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
543:                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
544:                 
545:                 let prefix = String(text.prefix(location))
546:                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
547:                 
548:                 // TODO: Implement find references functionality in EditorCore
549:                 // For now, just trigger peek definition as a placeholder
550:                 parent.editorCore.triggerPeekDefinition(
551:                     file: parent.filename,
552:                     line: sourceLine,
553:                     content: text,
554:                     sourceLine: sourceLine
555:                 )
556:             }
557:         }
558:         
559:         func handleFormatDocument(in textView: UITextView) {
560:             // TODO: Implement format document functionality


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":330,"end_line":520}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":520,"end_line":520}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 331-520 of 1990)
────────────────────────────────────────
331:                     self?.applySyntaxHighlighting(to: textView)
332:                 }
333:             }
334:             
335:             updateLineCount(textView)
336:             updateCursorPosition(textView)
337:         }
338:         
339:         func textViewDidChangeSelection(_ textView: UITextView) {
340:             if !isUpdatingFromMinimap {
341:                 updateCursorPosition(textView)
342:                 updateScrollPosition(textView)
343: 
344:                 // FEAT-044: Matching bracket highlight
345:                 updateMatchingBracketHighlight(textView)
346: 
347:                 // Trigger redraw so current-line highlight/indent guides track the caret
348:                 (textView as? EditorTextView)?.setNeedsDisplay()
349: 
350:                 // Update selection in EditorCore for multi-cursor support
351:                 let range = textView.selectedRange
352:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
353: 
354:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
355:                 if !parent.editorCore.multiCursorState.isMultiCursor {
356:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
357:                 }
358:             }
359:         }
360:         
361:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
362:         
363:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
364:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
365:             isUserScrolling = true
366:             userScrollDebouncer?.invalidate()
367:         }
368:         
369:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
370:             // If not decelerating, user stopped scrolling
371:             if !decelerate {
372:                 // Small delay to let any final scroll events settle
373:                 userScrollDebouncer?.invalidate()
374:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
375:                     self?.isUserScrolling = false
376:                 }
377:             }
378:         }
379:         
380:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
381:             // Deceleration finished - user scroll is complete
382:             userScrollDebouncer?.invalidate()
383:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
384:                 self?.isUserScrolling = false
385:             }
386:         }
387:         
388:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
389:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
390:             
391:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
392:             // We still use debouncer as a fallback for edge cases
393:             if isUserScrolling {
394:                 userScrollDebouncer?.invalidate()
395:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
396:                     self?.isUserScrolling = false
397:                 }
398:             }
399:             
400:             updateScrollPosition(textView)
401:         }
402:         
403:         func updateLineCount(_ textView: UITextView) {
404:             let lines = textView.text.components(separatedBy: .newlines)
405:             DispatchQueue.main.async {
406:                 self.parent.totalLines = max(1, lines.count)
407:             }
408:         }
409:         
410:         func updateCursorPosition(_ textView: UITextView) {
411:             guard let selectedRange = textView.selectedTextRange else { return }
412:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
413:              
414:              let text = textView.text ?? ""
415:              let prefix = String(text.prefix(cursorPosition))
416:              let lines = prefix.components(separatedBy: .newlines)
417:              
418:              let lineNumber = lines.count
419:              let column = (lines.last?.count ?? 0) + 1
420:              
421:              DispatchQueue.main.async {
422:                  self.parent.currentLineNumber = lineNumber
423:                  self.parent.currentColumn = column
424:                  self.parent.cursorIndex = cursorPosition
425:              }
426:         }
427:         
428:         func updateScrollPosition(_ textView: UITextView) {
429:             guard let font = textView.font else { return }
430:             let lineHeight = font.lineHeight
431:             let scrollOffset = textView.contentOffset.y
432:             let line = Int(scrollOffset / lineHeight)
433:             
434:             // Update both synchronously to prevent feedback loop:
435:             // If we update parent.scrollPosition async, there's a race where
436:             // updateUIView sees old binding value != lastKnownScrollPosition
437:             // and scrolls back to the old position, causing jaggy scrolling.
438:             lastKnownScrollPosition = line
439:             parent.scrollPosition = line
440:         }
441:         
442:         func scrollToLine(_ line: Int, in textView: UITextView) {
443:             guard !isUpdatingFromMinimap else { return }
444:             isUpdatingFromMinimap = true
445:             
446:             let lines = textView.text.components(separatedBy: .newlines)
447:             guard line >= 0 && line < lines.count else {
448:                 isUpdatingFromMinimap = false
449:                 return
450:             }
451:             
452:             var characterPosition = 0
453:             for i in 0..<line {
454:                 characterPosition += lines[i].count + 1
455:             }
456:             
457:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
458:                 let rect = textView.caretRect(for: position)
459:                 let targetY = max(0, rect.origin.y)
460:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
461:             }
462:             
463:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
464:                 self.isUpdatingFromMinimap = false
465:             }
466:         }
467: 
468:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
469:             let lines = textView.text.components(separatedBy: .newlines)
470:             guard line >= 0 && line < lines.count else { return }
471: 
472:             var characterPosition = 0
473:             for i in 0..<line {
474:                 characterPosition += lines[i].count + 1
475:             }
476: 
477:             // FEAT-041: select entire line (excluding trailing newline)
478:             let lineLength = (lines[line] as NSString).length
479:             let range = NSRange(location: characterPosition, length: lineLength)
480:             textView.selectedRange = range
481: 
482:             // Ensure it's visible
483:             scrollToLine(line, in: textView)
484: 
485:             // Update SwiftUI state
486:             updateCursorPosition(textView)
487:             updateScrollPosition(textView)
488:         }
489: 
490:         func applySyntaxHighlighting(to textView: UITextView) {
491:             let theme = ThemeManager.shared.currentTheme
492:             lastThemeId = theme.id
493: 
494:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
495:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
496: 
497:             let selectedRange = textView.selectedRange
498:             textView.attributedText = attributedText
499:             textView.selectedRange = selectedRange
500: 
501:             // Set typing attributes so newly typed characters have correct base styling
502:             // This prevents flicker during the debounce period before full highlighting runs
503:             let fontSize = parent.editorCore.editorFontSize
504:             textView.typingAttributes = [
505:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
506:                 .foregroundColor: UIColor(theme.editorForeground)
507:             ]
508: 
509:             // FEAT-044: restore matching bracket highlight after re-attributing text
510:             updateMatchingBracketHighlight(textView)
511:         }
512:         
513:         func handlePeekDefinition(in textView: UITextView) {
514:             guard let selectedRange = textView.selectedTextRange else { return }
515:             let text = textView.text ?? ""
516:             
517:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
518:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
519:                  
520:                  let prefix = String(text.prefix(location))

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 521-520 of 1990)
────────────────────────────────────────



>>>TOOL search
{"query":"MinimapView(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"scrollOffset: .constant", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"scrollViewHeight: .constant", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:501: MinimapView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:566: MinimapView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:589: MinimapView(

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:568: scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:591: scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:569: scrollViewHeight: .constant(geometry.size.height),
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:592: scrollViewHeight: .constant(geometry.size.height),


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift","start_line":520,"end_line":640}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":560,"end_line":610}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift (lines 521-640 of 708)
────────────────────────────────────────
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
621:                         Circle()
622:                             .fill(isDragging ? Color.accentColor : Color.secondary)
623:                             .frame(width: 3, height: 3)
624:                     }
625:                 }
626:             } else {
627:                 HStack(spacing: 2) {
628:                     ForEach(0..<3, id: \.self) { _ in
629:                         Circle()
630:                             .fill(isDragging ? Color.accentColor : Color.secondary)
631:                             .frame(width: 3, height: 3)
632:                     }
633:                 }
634:             }
635:         }
636:         .frame(
637:             width: direction == .horizontal ? 6 : nil,
638:             height: direction == .vertical ? 6 : nil
639:         )
640:         .contentShape(Rectangle())

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 561-610 of 774)
────────────────────────────────────────
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
591:                     scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
592:                     scrollViewHeight: .constant(geometry.size.height),
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


>>>TOOL create_file
{"path":"_tmp_ignore","content":"placeholder"} 
>>>END>>>TOOL move_file
{"from":"_tmp_ignore","to":".claude/_tmp_ignore"}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":420,"end_line":475}
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":224,"end_line":242}
>>>END>>>END


---

## 🔧 TOOL RESULTS

[create_file]
✅ Created: _tmp_ignore

---

[move_file]
✅ Moved: _tmp_ignore → .claude/_tmp_ignore

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 421-475 of 1990)
────────────────────────────────────────
421:              DispatchQueue.main.async {
422:                  self.parent.currentLineNumber = lineNumber
423:                  self.parent.currentColumn = column
424:                  self.parent.cursorIndex = cursorPosition
425:              }
426:         }
427:         
428:         func updateScrollPosition(_ textView: UITextView) {
429:             guard let font = textView.font else { return }
430:             let lineHeight = font.lineHeight
431:             let scrollOffset = textView.contentOffset.y
432:             let line = Int(scrollOffset / lineHeight)
433:             
434:             // Update both synchronously to prevent feedback loop:
435:             // If we update parent.scrollPosition async, there's a race where
436:             // updateUIView sees old binding value != lastKnownScrollPosition
437:             // and scrolls back to the old position, causing jaggy scrolling.
438:             lastKnownScrollPosition = line
439:             parent.scrollPosition = line
440:         }
441:         
442:         func scrollToLine(_ line: Int, in textView: UITextView) {
443:             guard !isUpdatingFromMinimap else { return }
444:             isUpdatingFromMinimap = true
445:             
446:             let lines = textView.text.components(separatedBy: .newlines)
447:             guard line >= 0 && line < lines.count else {
448:                 isUpdatingFromMinimap = false
449:                 return
450:             }
451:             
452:             var characterPosition = 0
453:             for i in 0..<line {
454:                 characterPosition += lines[i].count + 1
455:             }
456:             
457:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
458:                 let rect = textView.caretRect(for: position)
459:                 let targetY = max(0, rect.origin.y)
460:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
461:             }
462:             
463:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
464:                 self.isUpdatingFromMinimap = false
465:             }
466:         }
467: 
468:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
469:             let lines = textView.text.components(separatedBy: .newlines)
470:             guard line >= 0 && line < lines.count else { return }
471: 
472:             var characterPosition = 0
473:             for i in 0..<line {
474:                 characterPosition += lines[i].count + 1
475:             }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 225-242 of 1990)
────────────────────────────────────────
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
241:         
242:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift","start_line":540,"end_line":620}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":575,"end_line":605}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift (lines 541-620 of 708)
────────────────────────────────────────
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
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 576-605 of 774)
────────────────────────────────────────
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
591:                     scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
592:                     scrollViewHeight: .constant(geometry.size.height),
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":420,"end_line":470}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift","start_line":560,"end_line":585}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":585,"end_line":600}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 421-470 of 1999)
────────────────────────────────────────
421:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
422:              
423:              let text = textView.text ?? ""
424:              let prefix = String(text.prefix(cursorPosition))
425:              let lines = prefix.components(separatedBy: .newlines)
426:              
427:              let lineNumber = lines.count
428:              let column = (lines.last?.count ?? 0) + 1
429:              
430:              DispatchQueue.main.async {
431:                  self.parent.currentLineNumber = lineNumber
432:                  self.parent.currentColumn = column
433:                  self.parent.cursorIndex = cursorPosition
434:              }
435:         }
436:         
437:         func updateScrollPosition(_ textView: UITextView) {
438:             guard let font = textView.font else { return }
439:             let lineHeight = font.lineHeight
440:             let scrollOffset = textView.contentOffset.y
441:             let line = Int(scrollOffset / lineHeight)
442:             
443:             // Update both synchronously to prevent feedback loop:
444:             // If we update parent.scrollPosition async, there's a race where
445:             // updateUIView sees old binding value != lastKnownScrollPosition
446:             // and scrolls back to the old position, causing jaggy scrolling.
447:             lastKnownScrollPosition = line
448:             parent.scrollPosition = line
449:         }
450:         
451:         func scrollToLine(_ line: Int, in textView: UITextView) {
452:             guard !isUpdatingFromMinimap else { return }
453:             isUpdatingFromMinimap = true
454:             
455:             let lines = textView.text.components(separatedBy: .newlines)
456:             guard line >= 0 && line < lines.count else {
457:                 isUpdatingFromMinimap = false
458:                 return
459:             }
460:             
461:             var characterPosition = 0
462:             for i in 0..<line {
463:                 characterPosition += lines[i].count + 1
464:             }
465:             
466:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
467:                 let rect = textView.caretRect(for: position)
468:                 let targetY = max(0, rect.origin.y)
469:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
470:             }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift (lines 561-585 of 708)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 586-600 of 774)
────────────────────────────────────────
586:                 }
587:                 
588:                 // Mini minimap
589:                 MinimapView(
590:                     content: text,
591:                     scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
592:                     scrollViewHeight: .constant(geometry.size.height),
593:                     totalContentHeight: CGFloat(totalLines) * lineHeight
594:                 )
595:                 .frame(width: 60)
596:             }
597:             // Sticky Header Overlay (FEAT-040)
598:             StickyHeaderView(
599:                 text: text,
600:                 currentLine: scrollPosition, // Using scrollPosition as approximate top line


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":220,"end_line":520}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift","start_line":550,"end_line":580}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":585,"end_line":600}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 221-520 of 1993)
────────────────────────────────────────
221:             textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
222:             context.coordinator.applySyntaxHighlighting(to: textView)
223:             textView.selectedRange = selectedRange
224:             
225:             // Update line height
226:             if let font = textView.font {
227:                 DispatchQueue.main.async {
228:                     self.lineHeight = font.lineHeight
229:                 }
230:             }
231:         }
232:         
233:         // Update text if changed externally
234:         if textView.text != text {
235:             let selectedRange = textView.selectedRange
236:             textView.text = text
237:             context.coordinator.applySyntaxHighlighting(to: textView)
238:             context.coordinator.hasAppliedInitialHighlighting = true
239:             textView.selectedRange = selectedRange
240:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
241:             // Re-apply highlighting if theme changed
242:             context.coordinator.applySyntaxHighlighting(to: textView)
243:         }
244:         
245:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
246:         // This prevents the editor from fighting against user scroll due to async binding lag
247:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
248:             // Update lastKnownScrollPosition FIRST to prevent race condition
249:             // where user scroll gets overridden by stale binding value
250:             context.coordinator.lastKnownScrollPosition = scrollPosition
251:             context.coordinator.scrollToLine(scrollPosition, in: textView)
252:         }
253: 
254:         // Handle line selection requests (e.g. tapping line numbers)
255:         if let requested = requestedLineSelection,
256:            requested != context.coordinator.lastRequestedLineSelection {
257:             context.coordinator.lastRequestedLineSelection = requested
258:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
259:             // Defer @Binding update to avoid "Publishing changes from within view updates"
260:             DispatchQueue.main.async {
261:                 self.requestedLineSelection = nil
262:             }
263:         }
264: 
265:         // Handle cursor index requests (e.g. accepting autocomplete)
266:         if let requested = requestedCursorIndex,
267:            requested != context.coordinator.lastRequestedCursorIndex {
268:             context.coordinator.lastRequestedCursorIndex = requested
269:             textView.selectedRange = NSRange(location: max(0, requested), length: 0)
270:             // Defer @Binding update to avoid "Publishing changes from within view updates"
271:             DispatchQueue.main.async {
272:                 self.requestedCursorIndex = nil
273:             }
274: 
275:             // Update SwiftUI state
276:             context.coordinator.updateCursorPosition(textView)
277:             context.coordinator.updateScrollPosition(textView)
278:         }
279:         
280:         // Note: updateLineCount is called in textViewDidChange, no need to call here
281:         // as it causes unnecessary state churn on every updateUIView
282:     }
283:     
284:     // MARK: - Coordinator
285:     
286:     class Coordinator: NSObject, UITextViewDelegate {
287:         var parent: SyntaxHighlightingTextView
288:         var lastKnownScrollPosition: Int = 0
289:         var lastThemeId: String = ""
290:         var lastRequestedLineSelection: Int? = nil
291:         var lastRequestedCursorIndex: Int? = nil
292:         private var isUpdatingFromMinimap = false
293:         private var highlightDebouncer: Timer?
294:         weak var pinchGesture: UIPinchGestureRecognizer?
295:         private var initialFontSize: CGFloat = 0
296:         
297:         // Track user scroll to prevent programmatic scroll fighting back
298:         private var userScrollDebouncer: Timer?
299:         var isUserScrolling = false
300: 
301:         // FEAT-044: Matching bracket highlight state
302:         private var bracketHighlightRanges: [NSRange] = []
303:         
304:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
305:         var hasAppliedInitialHighlighting = false
306:         
307:         init(_ parent: SyntaxHighlightingTextView) {
308:             self.parent = parent
309:         }
310:         
311:         func textViewDidBeginEditing(_ textView: UITextView) {
312:             // Ensure syntax highlighting is current when user begins editing
313:             // This handles cases where text was set but highlighting hasn't run yet
314:             applySyntaxHighlighting(to: textView)
315:         }
316:         
317:         func textViewDidChange(_ textView: UITextView) {
318:             // Update parent text
319:             parent.text = textView.text
320:             
321:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
322:             // This prevents flicker during the debounce period
323:             let theme = ThemeManager.shared.currentTheme
324:             let fontSize = parent.editorCore.editorFontSize
325:             textView.typingAttributes = [
326:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
327:                 .foregroundColor: UIColor(theme.editorForeground)
328:             ]
329:             
330:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
331:             highlightDebouncer?.invalidate()
332:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
333:                 DispatchQueue.main.async {
334:                     self?.applySyntaxHighlighting(to: textView)
335:                 }
336:             }
337:             
338:             updateLineCount(textView)
339:             updateCursorPosition(textView)
340:         }
341:         
342:         func textViewDidChangeSelection(_ textView: UITextView) {
343:             if !isUpdatingFromMinimap {
344:                 updateCursorPosition(textView)
345:                 updateScrollPosition(textView)
346: 
347:                 // FEAT-044: Matching bracket highlight
348:                 updateMatchingBracketHighlight(textView)
349: 
350:                 // Trigger redraw so current-line highlight/indent guides track the caret
351:                 (textView as? EditorTextView)?.setNeedsDisplay()
352: 
353:                 // Update selection in EditorCore for multi-cursor support
354:                 let range = textView.selectedRange
355:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
356: 
357:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
358:                 if !parent.editorCore.multiCursorState.isMultiCursor {
359:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
360:                 }
361:             }
362:         }
363:         
364:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
365:         
366:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
367:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
368:             isUserScrolling = true
369:             userScrollDebouncer?.invalidate()
370:         }
371:         
372:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
373:             // If not decelerating, user stopped scrolling
374:             if !decelerate {
375:                 // Small delay to let any final scroll events settle
376:                 userScrollDebouncer?.invalidate()
377:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
378:                     self?.isUserScrolling = false
379:                 }
380:             }
381:         }
382:         
383:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
384:             // Deceleration finished - user scroll is complete
385:             userScrollDebouncer?.invalidate()
386:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
387:                 self?.isUserScrolling = false
388:             }
389:         }
390:         
391:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
392:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
393:             
394:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
395:             // We still use debouncer as a fallback for edge cases
396:             if isUserScrolling {
397:                 userScrollDebouncer?.invalidate()
398:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
399:                     self?.isUserScrolling = false
400:                 }
401:             }
402:             
403:             updateScrollPosition(textView)
404:         }
405:         
406:         func updateLineCount(_ textView: UITextView) {
407:             let lines = textView.text.components(separatedBy: .newlines)
408:             DispatchQueue.main.async {
409:                 self.parent.totalLines = max(1, lines.count)
410:             }
411:         }
412:         
413:         func updateCursorPosition(_ textView: UITextView) {
414:             guard let selectedRange = textView.selectedTextRange else { return }
415:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
416:              
417:              let text = textView.text ?? ""
418:              let prefix = String(text.prefix(cursorPosition))
419:              let lines = prefix.components(separatedBy: .newlines)
420:              
421:              let lineNumber = lines.count
422:              let column = (lines.last?.count ?? 0) + 1
423:              
424:              DispatchQueue.main.async {
425:                  self.parent.currentLineNumber = lineNumber
426:                  self.parent.currentColumn = column
427:                  self.parent.cursorIndex = cursorPosition
428:              }
429:         }
430:         
431:         func updateScrollPosition(_ textView: UITextView) {
432:             guard let font = textView.font else { return }
433:             let lineHeight = font.lineHeight
434:             let scrollOffset = textView.contentOffset.y
435:             let line = Int(scrollOffset / lineHeight)
436:             
437:             // Update both synchronously to prevent feedback loop:
438:             // If we update parent.scrollPosition async, there's a race where
439:             // updateUIView sees old binding value != lastKnownScrollPosition
440:             // and scrolls back to the old position, causing jaggy scrolling.
441:             lastKnownScrollPosition = line
442:             parent.scrollPosition = line
443:         }
444:         
445:         func scrollToLine(_ line: Int, in textView: UITextView) {
446:             guard !isUpdatingFromMinimap else { return }
447:             isUpdatingFromMinimap = true
448:             
449:             let lines = textView.text.components(separatedBy: .newlines)
450:             guard line >= 0 && line < lines.count else {
451:                 isUpdatingFromMinimap = false
452:                 return
453:             }
454:             
455:             var characterPosition = 0
456:             for i in 0..<line {
457:                 characterPosition += lines[i].count + 1
458:             }
459:             
460:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
461:                 let rect = textView.caretRect(for: position)
462:                 let targetY = max(0, rect.origin.y)
463:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
464:             }
465:             
466:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
467:                 self.isUpdatingFromMinimap = false
468:             }
469:         }
470: 
471:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
472:             let lines = textView.text.components(separatedBy: .newlines)
473:             guard line >= 0 && line < lines.count else { return }
474: 
475:             var characterPosition = 0
476:             for i in 0..<line {
477:                 characterPosition += lines[i].count + 1
478:             }
479: 
480:             // FEAT-041: select entire line (excluding trailing newline)
481:             let lineLength = (lines[line] as NSString).length
482:             let range = NSRange(location: characterPosition, length: lineLength)
483:             textView.selectedRange = range
484: 
485:             // Ensure it's visible
486:             scrollToLine(line, in: textView)
487: 
488:             // Update SwiftUI state
489:             updateCursorPosition(textView)
490:             updateScrollPosition(textView)
491:         }
492: 
493:         func applySyntaxHighlighting(to textView: UITextView) {
494:             let theme = ThemeManager.shared.currentTheme
495:             lastThemeId = theme.id
496: 
497:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
498:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
499: 
500:             let selectedRange = textView.selectedRange
501:             textView.attributedText = attributedText
502:             textView.selectedRange = selectedRange
503: 
504:             // Set typing attributes so newly typed characters have correct base styling
505:             // This prevents flicker during the debounce period before full highlighting runs
506:             let fontSize = parent.editorCore.editorFontSize
507:             textView.typingAttributes = [
508:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
509:                 .foregroundColor: UIColor(theme.editorForeground)
510:             ]
511: 
512:             // FEAT-044: restore matching bracket highlight after re-attributing text
513:             updateMatchingBracketHighlight(textView)
514:         }
515:         
516:         func handlePeekDefinition(in textView: UITextView) {
517:             guard let selectedRange = textView.selectedTextRange else { return }
518:             let text = textView.text ?? ""
519:             
520:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift (lines 551-580 of 708)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 586-600 of 774)
────────────────────────────────────────
586:                 }
587:                 
588:                 // Mini minimap
589:                 MinimapView(
590:                     content: text,
591:                     scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
592:                     scrollViewHeight: .constant(geometry.size.height),
593:                     totalContentHeight: CGFloat(totalLines) * lineHeight
594:                 )
595:                 .frame(width: 60)
596:             }
597:             // Sticky Header Overlay (FEAT-040)
598:             StickyHeaderView(
599:                 text: text,
600:                 currentLine: scrollPosition, // Using scrollPosition as approximate top line


>>>TOOL search
{"query":"scrollPosition =", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"scrollPosition:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 7 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:70: self.scrollPosition = scrollPosition
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:510: scrollPosition = max(0, min(newLine, totalLines - 1))
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:582: scrollPosition = line
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:596: scrollPosition = Int(newOffset / lineHeight)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:52: self._scrollPosition = scrollPosition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:442: parent.scrollPosition = line
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:648: scrollPosition = Int(newOffset / lineHeight)

---

[search]
Found 16 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:51: var scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:61: scrollPosition: Int = 0,
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:167: scrollPosition: 0,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:403: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:455: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:495: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:547: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:24: let scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:271: scrollPosition: 0,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:12: let scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:15: @Binding var scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:36: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:71: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:88: scrollPosition: scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:491: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:569: scrollPosition: $scrollPosition,


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":430,"end_line":475}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":584,"end_line":598}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift","start_line":560,"end_line":575}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 431-475 of 1993)
────────────────────────────────────────
431:         func updateScrollPosition(_ textView: UITextView) {
432:             guard let font = textView.font else { return }
433:             let lineHeight = font.lineHeight
434:             let scrollOffset = textView.contentOffset.y
435:             let line = Int(scrollOffset / lineHeight)
436:             
437:             // Update both synchronously to prevent feedback loop:
438:             // If we update parent.scrollPosition async, there's a race where
439:             // updateUIView sees old binding value != lastKnownScrollPosition
440:             // and scrolls back to the old position, causing jaggy scrolling.
441:             lastKnownScrollPosition = line
442:             parent.scrollPosition = line
443:         }
444:         
445:         func scrollToLine(_ line: Int, in textView: UITextView) {
446:             guard !isUpdatingFromMinimap else { return }
447:             isUpdatingFromMinimap = true
448:             
449:             let lines = textView.text.components(separatedBy: .newlines)
450:             guard line >= 0 && line < lines.count else {
451:                 isUpdatingFromMinimap = false
452:                 return
453:             }
454:             
455:             var characterPosition = 0
456:             for i in 0..<line {
457:                 characterPosition += lines[i].count + 1
458:             }
459:             
460:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
461:                 let rect = textView.caretRect(for: position)
462:                 let targetY = max(0, rect.origin.y)
463:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
464:             }
465:             
466:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
467:                 self.isUpdatingFromMinimap = false
468:             }
469:         }
470: 
471:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
472:             let lines = textView.text.components(separatedBy: .newlines)
473:             guard line >= 0 && line < lines.count else { return }
474: 
475:             var characterPosition = 0

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 585-598 of 774)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift (lines 561-575 of 708)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":350,"end_line":480}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":480,"end_line":520}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 351-480 of 1995)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 481-520 of 1995)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":435,"end_line":475}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift","start_line":580,"end_line":600}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 436-475 of 1995)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift (lines 581-600 of 774)
────────────────────────────────────────
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


>>>TOOL search
{"query":"scrollPosition =", "glob":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift"}
>>>END
>>>TOOL search
{"query":"scrollPosition = ", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"scrollPosition = ", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:510: scrollPosition = max(0, min(newLine, totalLines - 1))

---

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:52: self._scrollPosition = scrollPosition
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:444: parent.scrollPosition = line

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:648: scrollPosition = Int(newOffset / lineHeight)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":200,"end_line":520}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 201-520 of 1995)
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":430,"end_line":475}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 431-475 of 1995)
────────────────────────────────────────
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


>>>TOOL search
{"query":"SyntaxHighlightingTextView_Update.swift", "glob":"VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj"}
>>>END
>>>TOOL search
{"query":"SyntaxHighlightingTextView_Update.swift", "glob":"**/*.pbxproj"}
>>>END
>>>TOOL search
{"query":"SyntaxHighlightingTextView_Update", "glob":"**/*.pbxproj"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "SyntaxHighlightingTextView_Update.swift"

---

[search]
No matches found for "SyntaxHighlightingTextView_Update.swift"

---

[search]
No matches found for "SyntaxHighlightingTextView_Update"


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":430,"end_line":510}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":235,"end_line":260}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 431-510 of 1995)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 236-260 of 1995)
────────────────────────────────────────
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


>>>TOOL create_file
{"path":".claude/_tmp_ignore","content":"temp"}
>>>END
>>>TOOL move_file
{"from":".claude/_tmp_ignore","to":".claude/_tmp_ignore"}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":430,"end_line":475}
>>>END

---

## 🔧 TOOL RESULTS

[create_file]
Error: File already exists: .claude/_tmp_ignore. Use overwrite:true to replace.

---

[move_file]
✅ Moved: .claude/_tmp_ignore → .claude/_tmp_ignore

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 431-475 of 1995)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":260,"end_line":510}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 261-510 of 1995)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":350,"end_line":470}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":180,"end_line":270}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 351-470 of 1995)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 181-270 of 1995)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":420,"end_line":490}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":490,"end_line":475}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 421-490 of 1995)
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 491-490 of 1995)
────────────────────────────────────────



>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":235,"end_line":275}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":430,"end_line":472}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 236-275 of 1995)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 431-472 of 1995)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":350,"end_line":520}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":520,"end_line":500}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 351-520 of 1995)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 521-520 of 1995)
────────────────────────────────────────



>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":440,"end_line":475}
>>>END
>>>TOOL search
{"query":"setContentOffset(CGPoint(x: 0, y: targetY), animated: true)", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 441-475 of 1995)
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

---

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:465: textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":350,"end_line":410}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":430,"end_line":475}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 351-410 of 2002)
────────────────────────────────────────
351:         func textViewDidChangeSelection(_ textView: UITextView) {
352:             if !isUpdatingFromMinimap {
353:                 updateCursorPosition(textView)
354:                 updateScrollPosition(textView)
355: 
356:                 // FEAT-044: Matching bracket highlight
357:                 updateMatchingBracketHighlight(textView)
358: 
359:                 // Trigger redraw so current-line highlight/indent guides track the caret
360:                 (textView as? EditorTextView)?.setNeedsDisplay()
361: 
362:                 // Update selection in EditorCore for multi-cursor support
363:                 let range = textView.selectedRange
364:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
365: 
366:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
367:                 if !parent.editorCore.multiCursorState.isMultiCursor {
368:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
369:                 }
370:             }
371:         }
372:         
373:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
374:         
375:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
376:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
377:             isUserScrolling = true
378:             userScrollDebouncer?.invalidate()
379:         }
380:         
381:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
382:             // If not decelerating, user stopped scrolling
383:             if !decelerate {
384:                 // Small delay to let any final scroll events settle
385:                 userScrollDebouncer?.invalidate()
386:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
387:                     self?.isUserScrolling = false
388:                 }
389:             }
390:         }
391:         
392:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
393:             // Deceleration finished - user scroll is complete
394:             userScrollDebouncer?.invalidate()
395:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
396:                 self?.isUserScrolling = false
397:             }
398:         }
399:         
400:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
401:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
402:             
403:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
404:             // We still use debouncer as a fallback for edge cases
405:             if isUserScrolling {
406:                 userScrollDebouncer?.invalidate()
407:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
408:                     self?.isUserScrolling = false
409:                 }
410:             }

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 431-475 of 2002)
────────────────────────────────────────
431:              let column = (lines.last?.count ?? 0) + 1
432:              
433:              DispatchQueue.main.async {
434:                  self.parent.currentLineNumber = lineNumber
435:                  self.parent.currentColumn = column
436:                  self.parent.cursorIndex = cursorPosition
437:              }
438:         }
439:         
440:         func updateScrollPosition(_ textView: UITextView) {
441:             guard let font = textView.font else { return }
442:             let lineHeight = font.lineHeight
443:             let scrollOffset = textView.contentOffset.y
444:             let line = Int(scrollOffset / lineHeight)
445:             
446:             // Update both synchronously to prevent feedback loop:
447:             // If we update parent.scrollPosition async, there's a race where
448:             // updateUIView sees old binding value != lastKnownScrollPosition
449:             // and scrolls back to the old position, causing jaggy scrolling.
450:             lastKnownScrollPosition = line
451:             parent.scrollPosition = line
452:         }
453:         
454:         func scrollToLine(_ line: Int, in textView: UITextView) {
455:             guard !isUpdatingFromMinimap else { return }
456:             isUpdatingFromMinimap = true
457:             
458:             let lines = textView.text.components(separatedBy: .newlines)
459:             guard line >= 0 && line < lines.count else {
460:                 isUpdatingFromMinimap = false
461:                 return
462:             }
463:             
464:             var characterPosition = 0
465:             for i in 0..<line {
466:                 characterPosition += lines[i].count + 1
467:             }
468:             
469:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
470:                 let rect = textView.caretRect(for: position)
471:                 let targetY = max(0, rect.origin.y)
472:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
473:             }
474:             
475:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":240,"end_line":520}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":520,"end_line":560}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 241-520 of 2011)
────────────────────────────────────────
241:             context.coordinator.hasAppliedInitialHighlighting = true
242:             textView.selectedRange = selectedRange
243:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
244:             // Re-apply highlighting if theme changed
245:             context.coordinator.applySyntaxHighlighting(to: textView)
246:         }
247:         
248:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
249:         // This prevents the editor from fighting against user scroll due to async binding lag
250:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
251:             // Update lastKnownScrollPosition FIRST to prevent race condition
252:             // where user scroll gets overridden by stale binding value
253:             context.coordinator.lastKnownScrollPosition = scrollPosition
254:             context.coordinator.scrollToLine(scrollPosition, in: textView)
255:         }
256: 
257:         // Handle line selection requests (e.g. tapping line numbers)
258:         if let requested = requestedLineSelection,
259:            requested != context.coordinator.lastRequestedLineSelection {
260:             context.coordinator.lastRequestedLineSelection = requested
261:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
262:             // Defer @Binding update to avoid "Publishing changes from within view updates"
263:             DispatchQueue.main.async {
264:                 self.requestedLineSelection = nil
265:             }
266:         }
267: 
268:         // Handle cursor index requests (e.g. accepting autocomplete)
269:         if let requested = requestedCursorIndex,
270:            requested != context.coordinator.lastRequestedCursorIndex {
271:             context.coordinator.lastRequestedCursorIndex = requested
272:             // Use UTF-16 count for NSRange compatibility
273:             let textLength = (textView.text as NSString?)?.length ?? 0
274:             let safeIndex = max(0, min(requested, textLength))
275:             textView.selectedRange = NSRange(location: safeIndex, length: 0)
276:             
277:             // Ensure cursor is visible by scrolling to it
278:             textView.scrollRangeToVisible(textView.selectedRange)
279:             
280:             // Defer @Binding update to avoid "Publishing changes from within view updates"
281:             DispatchQueue.main.async {
282:                 self.requestedCursorIndex = nil
283:             }
284: 
285:             // Update SwiftUI state
286:             context.coordinator.updateCursorPosition(textView)
287:             context.coordinator.updateScrollPosition(textView)
288:         }
289:         
290:         // Note: updateLineCount is called in textViewDidChange, no need to call here
291:         // as it causes unnecessary state churn on every updateUIView
292:     }
293:     
294:     // MARK: - Coordinator
295:     
296:     class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
297:         var parent: SyntaxHighlightingTextView
298:         var lastKnownScrollPosition: Int = 0
299:         var lastThemeId: String = ""
300:         var lastRequestedLineSelection: Int? = nil
301:         var lastRequestedCursorIndex: Int? = nil
302:         private var isUpdatingFromMinimap = false
303:         private var highlightDebouncer: Timer?
304:         weak var pinchGesture: UIPinchGestureRecognizer?
305:         private var initialFontSize: CGFloat = 0
306:         
307:         // Track user scroll to prevent programmatic scroll fighting back
308:         private var userScrollDebouncer: Timer?
309:         var isUserScrolling = false
310: 
311:         // FEAT-044: Matching bracket highlight state
312:         private var bracketHighlightRanges: [NSRange] = []
313:         
314:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
315:         var hasAppliedInitialHighlighting = false
316:         
317:         init(_ parent: SyntaxHighlightingTextView) {
318:             self.parent = parent
319:         }
320:         
321:         // MARK: - UIGestureRecognizerDelegate
322:         
323:         // Allow pinch gesture to work simultaneously with text selection gestures
324:         func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
325:             // Allow pinch to work alongside native text selection gestures
326:             return true
327:         }
328:         
329:         func textViewDidBeginEditing(_ textView: UITextView) {
330:             // Ensure syntax highlighting is current when user begins editing
331:             // This handles cases where text was set but highlighting hasn't run yet
332:             applySyntaxHighlighting(to: textView)
333:         }
334:         
335:         func textViewDidChange(_ textView: UITextView) {
336:             // Update parent text
337:             parent.text = textView.text
338:             
339:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
340:             // This prevents flicker during the debounce period
341:             let theme = ThemeManager.shared.currentTheme
342:             let fontSize = parent.editorCore.editorFontSize
343:             textView.typingAttributes = [
344:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
345:                 .foregroundColor: UIColor(theme.editorForeground)
346:             ]
347:             
348:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
349:             highlightDebouncer?.invalidate()
350:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
351:                 DispatchQueue.main.async {
352:                     self?.applySyntaxHighlighting(to: textView)
353:                 }
354:             }
355:             
356:             updateLineCount(textView)
357:             updateCursorPosition(textView)
358:         }
359:         
360:         func textViewDidChangeSelection(_ textView: UITextView) {
361:             if !isUpdatingFromMinimap {
362:                 updateCursorPosition(textView)
363:                 updateScrollPosition(textView)
364: 
365:                 // FEAT-044: Matching bracket highlight
366:                 updateMatchingBracketHighlight(textView)
367: 
368:                 // Trigger redraw so current-line highlight/indent guides track the caret
369:                 (textView as? EditorTextView)?.setNeedsDisplay()
370: 
371:                 // Update selection in EditorCore for multi-cursor support
372:                 let range = textView.selectedRange
373:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
374: 
375:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
376:                 if !parent.editorCore.multiCursorState.isMultiCursor {
377:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
378:                 }
379:             }
380:         }
381:         
382:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
383:         
384:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
385:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
386:             isUserScrolling = true
387:             userScrollDebouncer?.invalidate()
388:         }
389:         
390:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
391:             // If not decelerating, user stopped scrolling
392:             if !decelerate {
393:                 // Small delay to let any final scroll events settle
394:                 userScrollDebouncer?.invalidate()
395:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
396:                     self?.isUserScrolling = false
397:                 }
398:             }
399:         }
400:         
401:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
402:             // Deceleration finished - user scroll is complete
403:             userScrollDebouncer?.invalidate()
404:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
405:                 self?.isUserScrolling = false
406:             }
407:         }
408:         
409:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
410:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
411:             
412:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
413:             // We still use debouncer as a fallback for edge cases
414:             if isUserScrolling {
415:                 userScrollDebouncer?.invalidate()
416:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
417:                     self?.isUserScrolling = false
418:                 }
419:             }
420:             
421:             updateScrollPosition(textView)
422:         }
423:         
424:         func updateLineCount(_ textView: UITextView) {
425:             let lines = textView.text.components(separatedBy: .newlines)
426:             DispatchQueue.main.async {
427:                 self.parent.totalLines = max(1, lines.count)
428:             }
429:         }
430:         
431:         func updateCursorPosition(_ textView: UITextView) {
432:             guard let selectedRange = textView.selectedTextRange else { return }
433:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
434:              
435:              let text = textView.text ?? ""
436:              let prefix = String(text.prefix(cursorPosition))
437:              let lines = prefix.components(separatedBy: .newlines)
438:              
439:              let lineNumber = lines.count
440:              let column = (lines.last?.count ?? 0) + 1
441:              
442:              DispatchQueue.main.async {
443:                  self.parent.currentLineNumber = lineNumber
444:                  self.parent.currentColumn = column
445:                  self.parent.cursorIndex = cursorPosition
446:              }
447:         }
448:         
449:         func updateScrollPosition(_ textView: UITextView) {
450:             guard let font = textView.font else { return }
451:             let lineHeight = font.lineHeight
452:             let scrollOffset = textView.contentOffset.y
453:             let line = Int(scrollOffset / lineHeight)
454:             
455:             // Update both synchronously to prevent feedback loop:
456:             // If we update parent.scrollPosition async, there's a race where
457:             // updateUIView sees old binding value != lastKnownScrollPosition
458:             // and scrolls back to the old position, causing jaggy scrolling.
459:             lastKnownScrollPosition = line
460:             parent.scrollPosition = line
461:         }
462:         
463:         func scrollToLine(_ line: Int, in textView: UITextView) {
464:             guard !isUpdatingFromMinimap else { return }
465:             isUpdatingFromMinimap = true
466:             
467:             let lines = textView.text.components(separatedBy: .newlines)
468:             guard line >= 0 && line < lines.count else {
469:                 isUpdatingFromMinimap = false
470:                 return
471:             }
472:             
473:             var characterPosition = 0
474:             for i in 0..<line {
475:                 characterPosition += lines[i].count + 1
476:             }
477:             
478:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
479:                 let rect = textView.caretRect(for: position)
480:                 let targetY = max(0, rect.origin.y)
481:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
482:             }
483:             
484:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
485:                 self.isUpdatingFromMinimap = false
486:             }
487:         }
488: 
489:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
490:             let lines = textView.text.components(separatedBy: .newlines)
491:             guard line >= 0 && line < lines.count else { return }
492: 
493:             var characterPosition = 0
494:             for i in 0..<line {
495:                 characterPosition += lines[i].count + 1
496:             }
497: 
498:             // FEAT-041: select entire line (excluding trailing newline)
499:             let lineLength = (lines[line] as NSString).length
500:             let range = NSRange(location: characterPosition, length: lineLength)
501:             textView.selectedRange = range
502: 
503:             // Ensure it's visible
504:             scrollToLine(line, in: textView)
505: 
506:             // Update SwiftUI state
507:             updateCursorPosition(textView)
508:             updateScrollPosition(textView)
509:         }
510: 
511:         func applySyntaxHighlighting(to textView: UITextView) {
512:             let theme = ThemeManager.shared.currentTheme
513:             lastThemeId = theme.id
514: 
515:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
516:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
517: 
518:             let selectedRange = textView.selectedRange
519:             textView.attributedText = attributedText
520:             textView.selectedRange = selectedRange

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 521-560 of 2011)
────────────────────────────────────────
521: 
522:             // Set typing attributes so newly typed characters have correct base styling
523:             // This prevents flicker during the debounce period before full highlighting runs
524:             let fontSize = parent.editorCore.editorFontSize
525:             textView.typingAttributes = [
526:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
527:                 .foregroundColor: UIColor(theme.editorForeground)
528:             ]
529: 
530:             // FEAT-044: restore matching bracket highlight after re-attributing text
531:             updateMatchingBracketHighlight(textView)
532:         }
533:         
534:         func handlePeekDefinition(in textView: UITextView) {
535:             guard let selectedRange = textView.selectedTextRange else { return }
536:             let text = textView.text ?? ""
537:             
538:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
539:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
540:                  
541:                  let prefix = String(text.prefix(location))
542:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
543:                  
544:                  parent.editorCore.triggerPeekDefinition(
545:                      file: parent.filename,
546:                      line: sourceLine,
547:                      content: text,
548:                      sourceLine: sourceLine
549:                  )
550:             }
551:         }
552:         
553:         func handleEscape() {
554:             if parent.editorCore.peekState != nil {
555:                 parent.editorCore.closePeekDefinition()
556:             } else {
557:                 parent.editorCore.escapeMultiCursor()
558:             }
559:         }
560:         


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":230,"end_line":520}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":520,"end_line":560}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 231-520 of 2011)
────────────────────────────────────────
231:                     self.lineHeight = font.lineHeight
232:                 }
233:             }
234:         }
235:         
236:         // Update text if changed externally
237:         if textView.text != text {
238:             let selectedRange = textView.selectedRange
239:             textView.text = text
240:             context.coordinator.applySyntaxHighlighting(to: textView)
241:             context.coordinator.hasAppliedInitialHighlighting = true
242:             textView.selectedRange = selectedRange
243:         } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
244:             // Re-apply highlighting if theme changed
245:             context.coordinator.applySyntaxHighlighting(to: textView)
246:         }
247:         
248:         // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
249:         // This prevents the editor from fighting against user scroll due to async binding lag
250:         if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
251:             // Update lastKnownScrollPosition FIRST to prevent race condition
252:             // where user scroll gets overridden by stale binding value
253:             context.coordinator.lastKnownScrollPosition = scrollPosition
254:             context.coordinator.scrollToLine(scrollPosition, in: textView)
255:         }
256: 
257:         // Handle line selection requests (e.g. tapping line numbers)
258:         if let requested = requestedLineSelection,
259:            requested != context.coordinator.lastRequestedLineSelection {
260:             context.coordinator.lastRequestedLineSelection = requested
261:             context.coordinator.scrollToAndSelectLine(requested, in: textView)
262:             // Defer @Binding update to avoid "Publishing changes from within view updates"
263:             DispatchQueue.main.async {
264:                 self.requestedLineSelection = nil
265:             }
266:         }
267: 
268:         // Handle cursor index requests (e.g. accepting autocomplete)
269:         if let requested = requestedCursorIndex,
270:            requested != context.coordinator.lastRequestedCursorIndex {
271:             context.coordinator.lastRequestedCursorIndex = requested
272:             // Use UTF-16 count for NSRange compatibility
273:             let textLength = (textView.text as NSString?)?.length ?? 0
274:             let safeIndex = max(0, min(requested, textLength))
275:             textView.selectedRange = NSRange(location: safeIndex, length: 0)
276:             
277:             // Ensure cursor is visible by scrolling to it
278:             textView.scrollRangeToVisible(textView.selectedRange)
279:             
280:             // Defer @Binding update to avoid "Publishing changes from within view updates"
281:             DispatchQueue.main.async {
282:                 self.requestedCursorIndex = nil
283:             }
284: 
285:             // Update SwiftUI state
286:             context.coordinator.updateCursorPosition(textView)
287:             context.coordinator.updateScrollPosition(textView)
288:         }
289:         
290:         // Note: updateLineCount is called in textViewDidChange, no need to call here
291:         // as it causes unnecessary state churn on every updateUIView
292:     }
293:     
294:     // MARK: - Coordinator
295:     
296:     class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
297:         var parent: SyntaxHighlightingTextView
298:         var lastKnownScrollPosition: Int = 0
299:         var lastThemeId: String = ""
300:         var lastRequestedLineSelection: Int? = nil
301:         var lastRequestedCursorIndex: Int? = nil
302:         private var isUpdatingFromMinimap = false
303:         private var highlightDebouncer: Timer?
304:         weak var pinchGesture: UIPinchGestureRecognizer?
305:         private var initialFontSize: CGFloat = 0
306:         
307:         // Track user scroll to prevent programmatic scroll fighting back
308:         private var userScrollDebouncer: Timer?
309:         var isUserScrolling = false
310: 
311:         // FEAT-044: Matching bracket highlight state
312:         private var bracketHighlightRanges: [NSRange] = []
313:         
314:         // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
315:         var hasAppliedInitialHighlighting = false
316:         
317:         init(_ parent: SyntaxHighlightingTextView) {
318:             self.parent = parent
319:         }
320:         
321:         // MARK: - UIGestureRecognizerDelegate
322:         
323:         // Allow pinch gesture to work simultaneously with text selection gestures
324:         func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
325:             // Allow pinch to work alongside native text selection gestures
326:             return true
327:         }
328:         
329:         func textViewDidBeginEditing(_ textView: UITextView) {
330:             // Ensure syntax highlighting is current when user begins editing
331:             // This handles cases where text was set but highlighting hasn't run yet
332:             applySyntaxHighlighting(to: textView)
333:         }
334:         
335:         func textViewDidChange(_ textView: UITextView) {
336:             // Update parent text
337:             parent.text = textView.text
338:             
339:             // Set typing attributes IMMEDIATELY so new characters have proper base styling
340:             // This prevents flicker during the debounce period
341:             let theme = ThemeManager.shared.currentTheme
342:             let fontSize = parent.editorCore.editorFontSize
343:             textView.typingAttributes = [
344:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
345:                 .foregroundColor: UIColor(theme.editorForeground)
346:             ]
347:             
348:             // Debounced syntax highlighting for performance (reduced from 0.15s to 0.08s)
349:             highlightDebouncer?.invalidate()
350:             highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
351:                 DispatchQueue.main.async {
352:                     self?.applySyntaxHighlighting(to: textView)
353:                 }
354:             }
355:             
356:             updateLineCount(textView)
357:             updateCursorPosition(textView)
358:         }
359:         
360:         func textViewDidChangeSelection(_ textView: UITextView) {
361:             if !isUpdatingFromMinimap {
362:                 updateCursorPosition(textView)
363:                 updateScrollPosition(textView)
364: 
365:                 // FEAT-044: Matching bracket highlight
366:                 updateMatchingBracketHighlight(textView)
367: 
368:                 // Trigger redraw so current-line highlight/indent guides track the caret
369:                 (textView as? EditorTextView)?.setNeedsDisplay()
370: 
371:                 // Update selection in EditorCore for multi-cursor support
372:                 let range = textView.selectedRange
373:                 parent.editorCore.updateSelection(range: range, text: textView.text ?? "")
374: 
375:                 // If user clicks elsewhere (not multi-cursor operation), reset to single cursor
376:                 if !parent.editorCore.multiCursorState.isMultiCursor {
377:                     parent.editorCore.multiCursorState.reset(to: range.location + range.length)
378:                 }
379:             }
380:         }
381:         
382:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
383:         
384:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
385:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
386:             isUserScrolling = true
387:             userScrollDebouncer?.invalidate()
388:         }
389:         
390:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
391:             // If not decelerating, user stopped scrolling
392:             if !decelerate {
393:                 // Small delay to let any final scroll events settle
394:                 userScrollDebouncer?.invalidate()
395:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
396:                     self?.isUserScrolling = false
397:                 }
398:             }
399:         }
400:         
401:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
402:             // Deceleration finished - user scroll is complete
403:             userScrollDebouncer?.invalidate()
404:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
405:                 self?.isUserScrolling = false
406:             }
407:         }
408:         
409:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
410:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
411:             
412:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
413:             // We still use debouncer as a fallback for edge cases
414:             if isUserScrolling {
415:                 userScrollDebouncer?.invalidate()
416:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
417:                     self?.isUserScrolling = false
418:                 }
419:             }
420:             
421:             updateScrollPosition(textView)
422:         }
423:         
424:         func updateLineCount(_ textView: UITextView) {
425:             let lines = textView.text.components(separatedBy: .newlines)
426:             DispatchQueue.main.async {
427:                 self.parent.totalLines = max(1, lines.count)
428:             }
429:         }
430:         
431:         func updateCursorPosition(_ textView: UITextView) {
432:             guard let selectedRange = textView.selectedTextRange else { return }
433:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
434:              
435:              let text = textView.text ?? ""
436:              let prefix = String(text.prefix(cursorPosition))
437:              let lines = prefix.components(separatedBy: .newlines)
438:              
439:              let lineNumber = lines.count
440:              let column = (lines.last?.count ?? 0) + 1
441:              
442:              DispatchQueue.main.async {
443:                  self.parent.currentLineNumber = lineNumber
444:                  self.parent.currentColumn = column
445:                  self.parent.cursorIndex = cursorPosition
446:              }
447:         }
448:         
449:         func updateScrollPosition(_ textView: UITextView) {
450:             guard let font = textView.font else { return }
451:             let lineHeight = font.lineHeight
452:             let scrollOffset = textView.contentOffset.y
453:             let line = Int(scrollOffset / lineHeight)
454:             
455:             // Update both synchronously to prevent feedback loop:
456:             // If we update parent.scrollPosition async, there's a race where
457:             // updateUIView sees old binding value != lastKnownScrollPosition
458:             // and scrolls back to the old position, causing jaggy scrolling.
459:             lastKnownScrollPosition = line
460:             parent.scrollPosition = line
461:         }
462:         
463:         func scrollToLine(_ line: Int, in textView: UITextView) {
464:             guard !isUpdatingFromMinimap else { return }
465:             isUpdatingFromMinimap = true
466:             
467:             let lines = textView.text.components(separatedBy: .newlines)
468:             guard line >= 0 && line < lines.count else {
469:                 isUpdatingFromMinimap = false
470:                 return
471:             }
472:             
473:             var characterPosition = 0
474:             for i in 0..<line {
475:                 characterPosition += lines[i].count + 1
476:             }
477:             
478:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
479:                 let rect = textView.caretRect(for: position)
480:                 let targetY = max(0, rect.origin.y)
481:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
482:             }
483:             
484:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
485:                 self.isUpdatingFromMinimap = false
486:             }
487:         }
488: 
489:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
490:             let lines = textView.text.components(separatedBy: .newlines)
491:             guard line >= 0 && line < lines.count else { return }
492: 
493:             var characterPosition = 0
494:             for i in 0..<line {
495:                 characterPosition += lines[i].count + 1
496:             }
497: 
498:             // FEAT-041: select entire line (excluding trailing newline)
499:             let lineLength = (lines[line] as NSString).length
500:             let range = NSRange(location: characterPosition, length: lineLength)
501:             textView.selectedRange = range
502: 
503:             // Ensure it's visible
504:             scrollToLine(line, in: textView)
505: 
506:             // Update SwiftUI state
507:             updateCursorPosition(textView)
508:             updateScrollPosition(textView)
509:         }
510: 
511:         func applySyntaxHighlighting(to textView: UITextView) {
512:             let theme = ThemeManager.shared.currentTheme
513:             lastThemeId = theme.id
514: 
515:             let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
516:             let attributedText = highlighter.highlight(textView.text, filename: parent.filename)
517: 
518:             let selectedRange = textView.selectedRange
519:             textView.attributedText = attributedText
520:             textView.selectedRange = selectedRange

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 521-560 of 2011)
────────────────────────────────────────
521: 
522:             // Set typing attributes so newly typed characters have correct base styling
523:             // This prevents flicker during the debounce period before full highlighting runs
524:             let fontSize = parent.editorCore.editorFontSize
525:             textView.typingAttributes = [
526:                 .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
527:                 .foregroundColor: UIColor(theme.editorForeground)
528:             ]
529: 
530:             // FEAT-044: restore matching bracket highlight after re-attributing text
531:             updateMatchingBracketHighlight(textView)
532:         }
533:         
534:         func handlePeekDefinition(in textView: UITextView) {
535:             guard let selectedRange = textView.selectedTextRange else { return }
536:             let text = textView.text ?? ""
537:             
538:             if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
539:                  let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
540:                  
541:                  let prefix = String(text.prefix(location))
542:                  let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
543:                  
544:                  parent.editorCore.triggerPeekDefinition(
545:                      file: parent.filename,
546:                      line: sourceLine,
547:                      content: text,
548:                      sourceLine: sourceLine
549:                  )
550:             }
551:         }
552:         
553:         func handleEscape() {
554:             if parent.editorCore.peekState != nil {
555:                 parent.editorCore.closePeekDefinition()
556:             } else {
557:                 parent.editorCore.escapeMultiCursor()
558:             }
559:         }
560:         


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":480,"end_line":535}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":440,"end_line":495}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 481-535 of 1064)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 441-495 of 2011)
────────────────────────────────────────
441:              
442:              DispatchQueue.main.async {
443:                  self.parent.currentLineNumber = lineNumber
444:                  self.parent.currentColumn = column
445:                  self.parent.cursorIndex = cursorPosition
446:              }
447:         }
448:         
449:         func updateScrollPosition(_ textView: UITextView) {
450:             guard let font = textView.font else { return }
451:             let lineHeight = font.lineHeight
452:             let scrollOffset = textView.contentOffset.y
453:             let line = Int(scrollOffset / lineHeight)
454:             
455:             // Update both synchronously to prevent feedback loop:
456:             // If we update parent.scrollPosition async, there's a race where
457:             // updateUIView sees old binding value != lastKnownScrollPosition
458:             // and scrolls back to the old position, causing jaggy scrolling.
459:             lastKnownScrollPosition = line
460:             parent.scrollPosition = line
461:         }
462:         
463:         func scrollToLine(_ line: Int, in textView: UITextView) {
464:             guard !isUpdatingFromMinimap else { return }
465:             isUpdatingFromMinimap = true
466:             
467:             let lines = textView.text.components(separatedBy: .newlines)
468:             guard line >= 0 && line < lines.count else {
469:                 isUpdatingFromMinimap = false
470:                 return
471:             }
472:             
473:             var characterPosition = 0
474:             for i in 0..<line {
475:                 characterPosition += lines[i].count + 1
476:             }
477:             
478:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
479:                 let rect = textView.caretRect(for: position)
480:                 let targetY = max(0, rect.origin.y)
481:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
482:             }
483:             
484:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
485:                 self.isUpdatingFromMinimap = false
486:             }
487:         }
488: 
489:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
490:             let lines = textView.text.components(separatedBy: .newlines)
491:             guard line >= 0 && line < lines.count else { return }
492: 
493:             var characterPosition = 0
494:             for i in 0..<line {
495:                 characterPosition += lines[i].count + 1


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":430,"end_line":490}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":380,"end_line":430}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 431-490 of 2011)
────────────────────────────────────────
431:         func updateCursorPosition(_ textView: UITextView) {
432:             guard let selectedRange = textView.selectedTextRange else { return }
433:              let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
434:              
435:              let text = textView.text ?? ""
436:              let prefix = String(text.prefix(cursorPosition))
437:              let lines = prefix.components(separatedBy: .newlines)
438:              
439:              let lineNumber = lines.count
440:              let column = (lines.last?.count ?? 0) + 1
441:              
442:              DispatchQueue.main.async {
443:                  self.parent.currentLineNumber = lineNumber
444:                  self.parent.currentColumn = column
445:                  self.parent.cursorIndex = cursorPosition
446:              }
447:         }
448:         
449:         func updateScrollPosition(_ textView: UITextView) {
450:             guard let font = textView.font else { return }
451:             let lineHeight = font.lineHeight
452:             let scrollOffset = textView.contentOffset.y
453:             let line = Int(scrollOffset / lineHeight)
454:             
455:             // Update both synchronously to prevent feedback loop:
456:             // If we update parent.scrollPosition async, there's a race where
457:             // updateUIView sees old binding value != lastKnownScrollPosition
458:             // and scrolls back to the old position, causing jaggy scrolling.
459:             lastKnownScrollPosition = line
460:             parent.scrollPosition = line
461:         }
462:         
463:         func scrollToLine(_ line: Int, in textView: UITextView) {
464:             guard !isUpdatingFromMinimap else { return }
465:             isUpdatingFromMinimap = true
466:             
467:             let lines = textView.text.components(separatedBy: .newlines)
468:             guard line >= 0 && line < lines.count else {
469:                 isUpdatingFromMinimap = false
470:                 return
471:             }
472:             
473:             var characterPosition = 0
474:             for i in 0..<line {
475:                 characterPosition += lines[i].count + 1
476:             }
477:             
478:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
479:                 let rect = textView.caretRect(for: position)
480:                 let targetY = max(0, rect.origin.y)
481:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
482:             }
483:             
484:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
485:                 self.isUpdatingFromMinimap = false
486:             }
487:         }
488: 
489:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
490:             let lines = textView.text.components(separatedBy: .newlines)

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 381-430 of 2011)
────────────────────────────────────────
381:         
382:         // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
383:         
384:         func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
385:             // User started dragging - set flag immediately to prevent programmatic scroll fighting
386:             isUserScrolling = true
387:             userScrollDebouncer?.invalidate()
388:         }
389:         
390:         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
391:             // If not decelerating, user stopped scrolling
392:             if !decelerate {
393:                 // Small delay to let any final scroll events settle
394:                 userScrollDebouncer?.invalidate()
395:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
396:                     self?.isUserScrolling = false
397:                 }
398:             }
399:         }
400:         
401:         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
402:             // Deceleration finished - user scroll is complete
403:             userScrollDebouncer?.invalidate()
404:             userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
405:                 self?.isUserScrolling = false
406:             }
407:         }
408:         
409:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
410:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
411:             
412:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
413:             // We still use debouncer as a fallback for edge cases
414:             if isUserScrolling {
415:                 userScrollDebouncer?.invalidate()
416:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
417:                     self?.isUserScrolling = false
418:                 }
419:             }
420:             
421:             updateScrollPosition(textView)
422:         }
423:         
424:         func updateLineCount(_ textView: UITextView) {
425:             let lines = textView.text.components(separatedBy: .newlines)
426:             DispatchQueue.main.async {
427:                 self.parent.totalLines = max(1, lines.count)
428:             }
429:         }
430:         


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":440,"end_line":490}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 441-490 of 2011)
────────────────────────────────────────
441:              
442:              DispatchQueue.main.async {
443:                  self.parent.currentLineNumber = lineNumber
444:                  self.parent.currentColumn = column
445:                  self.parent.cursorIndex = cursorPosition
446:              }
447:         }
448:         
449:         func updateScrollPosition(_ textView: UITextView) {
450:             guard let font = textView.font else { return }
451:             let lineHeight = font.lineHeight
452:             let scrollOffset = textView.contentOffset.y
453:             let line = Int(scrollOffset / lineHeight)
454:             
455:             // Update both synchronously to prevent feedback loop:
456:             // If we update parent.scrollPosition async, there's a race where
457:             // updateUIView sees old binding value != lastKnownScrollPosition
458:             // and scrolls back to the old position, causing jaggy scrolling.
459:             lastKnownScrollPosition = line
460:             parent.scrollPosition = line
461:         }
462:         
463:         func scrollToLine(_ line: Int, in textView: UITextView) {
464:             guard !isUpdatingFromMinimap else { return }
465:             isUpdatingFromMinimap = true
466:             
467:             let lines = textView.text.components(separatedBy: .newlines)
468:             guard line >= 0 && line < lines.count else {
469:                 isUpdatingFromMinimap = false
470:                 return
471:             }
472:             
473:             var characterPosition = 0
474:             for i in 0..<line {
475:                 characterPosition += lines[i].count + 1
476:             }
477:             
478:             if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
479:                 let rect = textView.caretRect(for: position)
480:                 let targetY = max(0, rect.origin.y)
481:                 textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
482:             }
483:             
484:             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
485:                 self.isUpdatingFromMinimap = false
486:             }
487:         }
488: 
489:         func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
490:             let lines = textView.text.components(separatedBy: .newlines)


>>>TOOL search
{"query":"SyntaxHighlightingTextView(", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>TOOL search
{"query":"scrollPosition:", "glob":"VSCodeiPadOS/VSCodeiPadOS/**/*.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:452: SyntaxHighlightingTextView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:544: SyntaxHighlightingTextView(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:566: SyntaxHighlightingTextView(

---

[search]
Found 16 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:51: var scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:61: scrollPosition: Int = 0,
VSCodeiPadOS/VSCodeiPadOS/Services/WindowStateManager.swift:167: scrollPosition: 0,
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:403: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/ContentView.swift:455: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:495: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView_Update.swift:547: scrollPosition: $scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:24: let scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlineSuggestionView.swift:271: scrollPosition: 0,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/InlayHintsOverlay.swift:12: let scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:15: @Binding var scrollPosition: Int
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:36: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:71: scrollPosition: Binding<Int>,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:88: scrollPosition: scrollPosition,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:491: @State private var scrollPosition: Int = 0
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SplitEditorView.swift:569: scrollPosition: $scrollPosition,


>>>TOOL search
{"query":".scrollToLine(", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>TOOL search
{"query":"scrollToLine(", "glob":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift"}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:254: context.coordinator.scrollToLine(scrollPosition, in: textView)

---

[search]
Found 3 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:254: context.coordinator.scrollToLine(scrollPosition, in: textView)
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:463: func scrollToLine(_ line: Int, in textView: UITextView) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:504: scrollToLine(line, in: textView)


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":420,"end_line":515}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":495,"end_line":520}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":430,"end_line":495}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":410,"end_line":505}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":490,"end_line":520}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":420,"end_line":505}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":500,"end_line":516}
>>>END
>>>END>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":430,"end_line":505}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":495,"end_line":520}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 421-515 of 2012)
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 496-520 of 1064)
────────────────────────────────────────
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
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 431-495 of 2012)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 411-505 of 2012)
────────────────────────────────────────
411:             guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
412:             
413:             // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
414:             // We still use debouncer as a fallback for edge cases
415:             if isUserScrolling {
416:                 userScrollDebouncer?.invalidate()
417:                 userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
418:                     self?.isUserScrolling = false
419:                 }
420:             }
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 491-520 of 1064)
────────────────────────────────────────
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
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 421-505 of 2012)
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 501-516 of 1064)
────────────────────────────────────────
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 431-505 of 2012)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":455,"end_line":490}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 456-490 of 2012)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":440,"end_line":490}
>>>END
>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/ContentView.swift","start_line":498,"end_line":514}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 441-490 of 2051)
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

---

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 499-514 of 1064)
────────────────────────────────────────
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


>>>TOOL read_file
{"path":"VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift","start_line":450,"end_line":490}
>>>END
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 451-490 of 2051)
────────────────────────────────────────
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


❌ API Error (iteration 44): terminated
