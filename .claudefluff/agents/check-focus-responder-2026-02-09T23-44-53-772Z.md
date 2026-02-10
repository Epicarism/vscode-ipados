# Agent: check-focus-responder
**Status:** done
**Tokens:** 4,163
**Cost:** $0.0000
**Time:** 2026-02-09T23:44:53.772Z

## Task
On iPadOS, when UITextView has focus, it captures keyboard input. Read SyntaxHighlightingTextView.swift and check if there's a way keyboard shortcuts are being intercepted. Look for keyCommands, pressesBegan, or any keyboard handling. Also check if ContentView has any .focusedSceneValue or .focusedValue setup.

## Response
I'll investigate the keyboard handling in these files. Let me start by reading the SyntaxHighlightingTextView.swift file.

>>>TOOL read_file
{"path": "vscode-ipados/SyntaxHighlightingTextView.swift"}
>>>END

Let me search for keyboard-related code in this file:

>>>TOOL search
{"query": "keyCommands", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 4 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:821: override var keyCommands: [UIKeyCommand]? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:822: var commands = super.keyCommands ?? []
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:206: override var keyCommands: [UIKeyCommand]? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:207: var commands = super.keyCommands ?? []


Let me read the keyCommands section in SyntaxHighlightingTextView.swift:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 810, "end_line": 950}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 811-950 of 1776)
────────────────────────────────────────
811:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
812:                 context.setStrokeColor(stroke.cgColor)
813: 
814:                 context.move(to: startPoint)
815:                 context.addLine(to: endPoint)
816:                 context.strokePath()
817:             }
818:         }
819:     }
820:     
821:     override var keyCommands: [UIKeyCommand]? {
822:         var commands = super.keyCommands ?? []
823:         
824:         // Peek Definition: Alt+F12 (using special key input)
825:         // Note: F12 is not directly available on iPadOS keyboards
826:         // Using Option+D as alternative
827:         commands.append(UIKeyCommand(
828:             input: "d",
829:             modifierFlags: .alternate,
830:             action: #selector(handlePeekDefinition)
831:         ))
832: 
833:         // Go to Line: Cmd+G
834:         commands.append(UIKeyCommand(
835:             input: "g",
836:             modifierFlags: .command,
837:             action: #selector(handleGoToLine)
838:         ))
839: 
840:         // Tab: accept autocomplete if visible, else insert tab
841:         commands.append(UIKeyCommand(
842:             input: "\t",
843:             modifierFlags: [],
844:             action: #selector(handleTab)
845:         ))
846:         
847:         // Escape: dismiss autocomplete if visible, else normal escape behavior
848:         commands.append(UIKeyCommand(
849:             input: UIKeyCommand.inputEscape,
850:             modifierFlags: [],
851:             action: #selector(handleEscape)
852:         ))
853:         
854:         // Fold: Cmd+Opt+[
855:         commands.append(UIKeyCommand(
856:             input: "[",
857:             modifierFlags: [.command, .alternate],
858:             action: #selector(handleFold)
859:         ))
860:         
861:         // Unfold: Cmd+Opt+]
862:         commands.append(UIKeyCommand(
863:             input: "]",
864:             modifierFlags: [.command, .alternate],
865:             action: #selector(handleUnfold)
866:         ))
867:         
868:         return commands
869:     }
870:     
871:     @objc func handlePeekDefinition() {
872:         onPeekDefinition?()
873:     }
874: 
875:     @objc func handleGoToLine() {
876:         onGoToLine?()
877:     }
878: 
879:     @objc func handleTab() {
880:         if onAcceptAutocomplete?() == true {
881:             return
882:         }
883:         insertText("\t")
884:     }
885:     
886:     @objc func handleEscape() {
887:         if onDismissAutocomplete?() == true {
888:             return
889:         }
890:         onEscape?()
891:     }
892:     
893:     @objc func handleFold() {
894:         onFold?()
895:     }
896:     
897:     @objc func handleUnfold() {
898:         onUnfold?()
899:     }
900:     
901:     // MARK: - Custom Actions
902:     
903:     @objc private func goToDefinition(_ sender: Any?) {
904:         onGoToDefinition?()
905:     }
906:     
907:     @objc private func peekDefinition(_ sender: Any?) {
908:         onPeekDefinition?()
909:     }
910:     
911:     @objc private func findReferences(_ sender: Any?) {
912:         onFindReferences?()
913:     }
914:     
915:     @objc private func formatDocument(_ sender: Any?) {
916:         onFormatDocument?()
917:     }
918:     
919:     @objc private func toggleComment(_ sender: Any?) {
920:         onToggleComment?()
921:     }
922:     
923:     // MARK: - Menu Support
924:     
925:     override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
926:         // Enable custom actions
927:         if action == #selector(goToDefinition(_:)) {
928:             return onGoToDefinition != nil
929:         }
930:         if action == #selector(peekDefinition(_:)) {
931:             return onPeekDefinition != nil
932:         }
933:         if action == #selector(findReferences(_:)) {
934:             return onFindReferences != nil
935:         }
936:         if action == #selector(formatDocument(_:)) {
937:             return onFormatDocument != nil
938:         }
939:         if action == #selector(toggleComment(_:)) {
940:             return onToggleComment != nil
941:         }
942:         
943:         return super.canPerformAction(action, withSender: sender)
944:     }
945:     
946:     override func buildMenu(with builder: UIMenuBuilder) {
947:         super.buildMenu(with: builder)
948:         
949:         guard builder.menu(for: .text) != nil else { return }
950:         


I found keyCommands. Let me search for pressesBegan and other keyboard handling:

>>>TOOL search
{"query": "pressesBegan", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "pressesBegan"


Let me search for more keyboard handling and check ContentView:

>>>TOOL search
{"query": "focusedSceneValue", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 1 matches:
VSCodeiPadOS/VSCodeiPadOS/SceneDelegate.swift:38: .focusedSceneValue(\.menuEditorCore, core)


Let me check the SceneDelegate and also search for focusedValue:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/SceneDelegate.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/SceneDelegate.swift (lines 1-232 of 232)
────────────────────────────────────────
1: //
2: //  SceneDelegate.swift
3: //  VSCodeiPadOS
4: //
5: //  Manages multiple window scenes for iPadOS 26+
6: //  Handles state restoration, drag & drop, and window lifecycle
7: //
8: 
9: import UIKit
10: import SwiftUI
11: 
12: @available(iOS 13.0, *)
13: class SceneDelegate: UIResponder, UIWindowSceneDelegate {
14:     
15:     var window: UIWindow?
16:     private var editorCore: EditorCore?
17:     private var windowId: UUID?
18:     
19:     // MARK: - Scene Lifecycle
20:     
21:     func scene(
22:         _ scene: UIScene,
23:         willConnectTo session: UISceneSession,
24:         options connectionOptions: UIScene.ConnectionOptions
25:     ) {
26:         guard let windowScene = scene as? UIWindowScene else { return }
27:         
28:         // Generate or retrieve window ID
29:         windowId = session.windowId
30:         
31:         // Create a new EditorCore instance for this window
32:         let core = EditorCore()
33:         editorCore = core
34:         
35:         // Create the root view
36:         let contentView = ContentView()
37:             .environmentObject(core)
38:             .focusedSceneValue(\.menuEditorCore, core)
39:             .onAppear {
40:                 self.restoreWindowState(session: session, connectionOptions: connectionOptions)
41:             }
42:         
43:         // Set up the window
44:         let window = UIWindow(windowScene: windowScene)
45:         window.rootViewController = UIHostingController(rootView: contentView)
46:         window.makeKeyAndVisible()
47:         self.window = window
48:         
49:         // Handle URL contexts if opening a file directly
50:         if let urlContext = connectionOptions.urlContexts.first {
51:             handleFileURL(urlContext.url)
52:         }
53:         
54:         // Handle user activities (e.g., from handoff or spotlight)
55:         if let userActivity = connectionOptions.userActivities.first {
56:             handleUserActivity(userActivity)
57:         }
58:         
59:         // Set window title
60:         updateWindowTitle()
61:         
62:         // Register this window with the state manager
63:         WindowStateManager.shared.registerWindow(id: windowId!)
64:     }
65:     
66:     func sceneDidDisconnect(_ scene: UIScene) {
67:         // Save state before disconnecting
68:         saveWindowState()
69:         
70:         // Remove window from state manager
71:         if let windowId = windowId {
72:             WindowStateManager.shared.removeWindow(id: windowId)
73:         }
74:     }
75:     
76:     func sceneDidBecomeActive(_ scene: UIScene) {
77:         // Set as active window
78:         if let windowId = windowId {
79:             WindowStateManager.shared.setActiveWindow(windowId)
80:         }
81:     }
82:     
83:     func sceneWillResignActive(_ scene: UIScene) {
84:         // Save state when resigning active
85:         saveWindowState()
86:     }
87:     
88:     func sceneWillEnterForeground(_ scene: UIScene) {
89:         // Restore state when entering foreground
90:         restoreWindowState(session: (scene as? UIWindowScene)?.session)
91:     }
92:     
93:     func sceneDidEnterBackground(_ scene: UIScene) {
94:         // Save state when entering background
95:         saveWindowState()
96:     }
97:     
98:     // MARK: - State Restoration
99:     
100:     func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
101:         // Return user activity for state restoration
102:         guard let windowId = windowId else { return nil }
103:         
104:         let activity = WindowStateManager.shared.createUserActivity(for: windowId)
105:         
106:         // Update activity with current state
107:         if let editorCore = editorCore {
108:             WindowStateManager.shared.captureState(
109:                 from: editorCore,
110:                 windowId: windowId,
111:                 workspacePath: editorCore.fileNavigator?.rootPath
112:             )
113:         }
114:         
115:         return activity
116:     }
117:     
118:     // MARK: - Window Title
119:     
120:     private func updateWindowTitle() {
121:         guard let scene = window?.windowScene else { return }
122:         
123:         var title = "VS Code"
124:         
125:         if let editorCore = editorCore,
126:            let activeTab = editorCore.activeTab {
127:             title = activeTab.fileName
128:             
129:             // Add unsaved indicator
130:             if activeTab.isUnsaved {
131:                 title += " •"
132:             }
133:         } else if let editorCore = editorCore,
134:                   let workspacePath = editorCore.fileNavigator?.rootPath {
135:             title = URL(fileURLWithPath: workspacePath).lastPathComponent
136:         }
137:         
138:         scene.title = title
139:     }
140:     
141:     // MARK: - File Handling
142:     
143:     private func handleFileURL(_ url: URL) {
144:         guard let editorCore = editorCore else { return }
145:         
146:         // Start accessing security-scoped resource if needed
147:         let _ = url.startAccessingSecurityScopedResource()
148:         defer { url.stopAccessingSecurityScopedResource() }
149:         
150:         // Open the file
151:         editorCore.openFile(from: url)
152:         updateWindowTitle()
153:     }
154:     
155:     private func handleUserActivity(_ userActivity: NSUserActivity) {
156:         guard let editorCore = editorCore else { return }
157:         
158:         // Check if this is a window activity
159:         if userActivity.activityType == WindowActivity.activityType {
160:             if let fileURLString = userActivity.userInfo?[WindowActivity.fileURLKey] as? String,
161:                let fileURL = URL(string: fileURLString) {
162:                 editorCore.openFile(from: fileURL)
163:             }
164:             
165:             if let workspacePath = userActivity.userInfo?[WindowActivity.workspacePathKey] as? String {
166:                 // TODO: Open workspace at path
167:                 print("Opening workspace: \(workspacePath)")
168:             }
169:         }
170:         
171:         updateWindowTitle()
172:     }
173:     
174:     func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
175:         guard let urlContext = URLContexts.first else { return }
176:         handleFileURL(urlContext.url)
177:     }
178:     
179:     // MARK: - Window State Persistence
180:     
181:     private func saveWindowState() {
182:         guard let windowId = windowId,
183:               let editorCore = editorCore else { return }
184:         
185:         WindowStateManager.shared.captureState(
186:             from: editorCore,
187:             windowId: windowId,
188:             workspacePath: editorCore.fileNavigator?.rootPath
189:         )
190:     }
191:     
192:     private func restoreWindowState(
193:         session: UISceneSession?,
194:         connectionOptions: UIScene.ConnectionOptions? = nil
195:     ) {
196:         guard let windowId = windowId,
197:               let editorCore = editorCore else { return }
198:         
199:         // Try to restore from session state restoration activity
200:         var shouldRestore = false
201:         
202:         if let session = session,
203:            let activity = session.stateRestorationActivity {
204:             shouldRestore = true
205:         }
206:         
207:         // Or check connection options for user activity
208:         if !shouldRestore,
209:            let options = connectionOptions,
210:            let activity = options.userActivities.first {
211:             shouldRestore = true
212:         }
213:         
214:         if shouldRestore {
215:             WindowStateManager.shared.restoreState(to: editorCore, windowId: windowId)
216:         }
217:     }
218: }
219: 
220: // MARK: - FocusedSceneKey
221: 
222: struct MenuEditorCoreKey: FocusedSceneValueKey {
223:     typealias Value = EditorCore
224: }
225: 
226: extension FocusedSceneValues {
227:     var menuEditorCore: EditorCore? {
228:         get { self[MenuEditorCoreKey.self] }
229:         set { self[MenuEditorCoreKey.self] = newValue }
230:     }
231: }
232: 


Now let me check ContentView.swift for keyboard handling:

>>>TOOL search
{"query": "focusedValue", "glob": "**/ContentView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "focusedValue"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/SceneDelegate.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/SceneDelegate.swift (lines 1-232 of 232)
────────────────────────────────────────
1: //
2: //  SceneDelegate.swift
3: //  VSCodeiPadOS
4: //
5: //  Manages multiple window scenes for iPadOS 26+
6: //  Handles state restoration, drag & drop, and window lifecycle
7: //
8: 
9: import UIKit
10: import SwiftUI
11: 
12: @available(iOS 13.0, *)
13: class SceneDelegate: UIResponder, UIWindowSceneDelegate {
14:     
15:     var window: UIWindow?
16:     private var editorCore: EditorCore?
17:     private var windowId: UUID?
18:     
19:     // MARK: - Scene Lifecycle
20:     
21:     func scene(
22:         _ scene: UIScene,
23:         willConnectTo session: UISceneSession,
24:         options connectionOptions: UIScene.ConnectionOptions
25:     ) {
26:         guard let windowScene = scene as? UIWindowScene else { return }
27:         
28:         // Generate or retrieve window ID
29:         windowId = session.windowId
30:         
31:         // Create a new EditorCore instance for this window
32:         let core = EditorCore()
33:         editorCore = core
34:         
35:         // Create the root view
36:         let contentView = ContentView()
37:             .environmentObject(core)
38:             .focusedSceneValue(\.menuEditorCore, core)
39:             .onAppear {
40:                 self.restoreWindowState(session: session, connectionOptions: connectionOptions)
41:             }
42:         
43:         // Set up the window
44:         let window = UIWindow(windowScene: windowScene)
45:         window.rootViewController = UIHostingController(rootView: contentView)
46:         window.makeKeyAndVisible()
47:         self.window = window
48:         
49:         // Handle URL contexts if opening a file directly
50:         if let urlContext = connectionOptions.urlContexts.first {
51:             handleFileURL(urlContext.url)
52:         }
53:         
54:         // Handle user activities (e.g., from handoff or spotlight)
55:         if let userActivity = connectionOptions.userActivities.first {
56:             handleUserActivity(userActivity)
57:         }
58:         
59:         // Set window title
60:         updateWindowTitle()
61:         
62:         // Register this window with the state manager
63:         WindowStateManager.shared.registerWindow(id: windowId!)
64:     }
65:     
66:     func sceneDidDisconnect(_ scene: UIScene) {
67:         // Save state before disconnecting
68:         saveWindowState()
69:         
70:         // Remove window from state manager
71:         if let windowId = windowId {
72:             WindowStateManager.shared.removeWindow(id: windowId)
73:         }
74:     }
75:     
76:     func sceneDidBecomeActive(_ scene: UIScene) {
77:         // Set as active window
78:         if let windowId = windowId {
79:             WindowStateManager.shared.setActiveWindow(windowId)
80:         }
81:     }
82:     
83:     func sceneWillResignActive(_ scene: UIScene) {
84:         // Save state when resigning active
85:         saveWindowState()
86:     }
87:     
88:     func sceneWillEnterForeground(_ scene: UIScene) {
89:         // Restore state when entering foreground
90:         restoreWindowState(session: (scene as? UIWindowScene)?.session)
91:     }
92:     
93:     func sceneDidEnterBackground(_ scene: UIScene) {
94:         // Save state when entering background
95:         saveWindowState()
96:     }
97:     
98:     // MARK: - State Restoration
99:     
100:     func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
101:         // Return user activity for state restoration
102:         guard let windowId = windowId else { return nil }
103:         
104:         let activity = WindowStateManager.shared.createUserActivity(for: windowId)
105:         
106:         // Update activity with current state
107:         if let editorCore = editorCore {
108:             WindowStateManager.shared.captureState(
109:                 from: editorCore,
110:                 windowId: windowId,
111:                 workspacePath: editorCore.fileNavigator?.rootPath
112:             )
113:         }
114:         
115:         return activity
116:     }
117:     
118:     // MARK: - Window Title
119:     
120:     private func updateWindowTitle() {
121:         guard let scene = window?.windowScene else { return }
122:         
123:         var title = "VS Code"
124:         
125:         if let editorCore = editorCore,
126:            let activeTab = editorCore.activeTab {
127:             title = activeTab.fileName
128:             
129:             // Add unsaved indicator
130:             if activeTab.isUnsaved {
131:                 title += " •"
132:             }
133:         } else if let editorCore = editorCore,
134:                   let workspacePath = editorCore.fileNavigator?.rootPath {
135:             title = URL(fileURLWithPath: workspacePath).lastPathComponent
136:         }
137:         
138:         scene.title = title
139:     }
140:     
141:     // MARK: - File Handling
142:     
143:     private func handleFileURL(_ url: URL) {
144:         guard let editorCore = editorCore else { return }
145:         
146:         // Start accessing security-scoped resource if needed
147:         let _ = url.startAccessingSecurityScopedResource()
148:         defer { url.stopAccessingSecurityScopedResource() }
149:         
150:         // Open the file
151:         editorCore.openFile(from: url)
152:         updateWindowTitle()
153:     }
154:     
155:     private func handleUserActivity(_ userActivity: NSUserActivity) {
156:         guard let editorCore = editorCore else { return }
157:         
158:         // Check if this is a window activity
159:         if userActivity.activityType == WindowActivity.activityType {
160:             if let fileURLString = userActivity.userInfo?[WindowActivity.fileURLKey] as? String,
161:                let fileURL = URL(string: fileURLString) {
162:                 editorCore.openFile(from: fileURL)
163:             }
164:             
165:             if let workspacePath = userActivity.userInfo?[WindowActivity.workspacePathKey] as? String {
166:                 // TODO: Open workspace at path
167:                 print("Opening workspace: \(workspacePath)")
168:             }
169:         }
170:         
171:         updateWindowTitle()
172:     }
173:     
174:     func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
175:         guard let urlContext = URLContexts.first else { return }
176:         handleFileURL(urlContext.url)
177:     }
178:     
179:     // MARK: - Window State Persistence
180:     
181:     private func saveWindowState() {
182:         guard let windowId = windowId,
183:               let editorCore = editorCore else { return }
184:         
185:         WindowStateManager.shared.captureState(
186:             from: editorCore,
187:             windowId: windowId,
188:             workspacePath: editorCore.fileNavigator?.rootPath
189:         )
190:     }
191:     
192:     private func restoreWindowState(
193:         session: UISceneSession?,
194:         connectionOptions: UIScene.ConnectionOptions? = nil
195:     ) {
196:         guard let windowId = windowId,
197:               let editorCore = editorCore else { return }
198:         
199:         // Try to restore from session state restoration activity
200:         var shouldRestore = false
201:         
202:         if let session = session,
203:            let activity = session.stateRestorationActivity {
204:             shouldRestore = true
205:         }
206:         
207:         // Or check connection options for user activity
208:         if !shouldRestore,
209:            let options = connectionOptions,
210:            let activity = options.userActivities.first {
211:             shouldRestore = true
212:         }
213:         
214:         if shouldRestore {
215:             WindowStateManager.shared.restoreState(to: editorCore, windowId: windowId)
216:         }
217:     }
218: }
219: 
220: // MARK: - FocusedSceneKey
221: 
222: struct MenuEditorCoreKey: FocusedSceneValueKey {
223:     typealias Value = EditorCore
224: }
225: 
226: extension FocusedSceneValues {
227:     var menuEditorCore: EditorCore? {
228:         get { self[MenuEditorCoreKey.self] }
229:         set { self[MenuEditorCoreKey.self] = newValue }
230:     }
231: }
232: 


Let me read ContentView.swift directly:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/ContentView.swift (lines 1-1048 of 1048)
────────────────────────────────────────
1: import SwiftUI
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
148:         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CloseFile"))) { _ in
149:             if let id = editorCore.activeTabId { editorCore.closeTab(id: id) }
150:         }
151:         .environmentObject(themeManager)
152:         .environmentObject(editorCore)
153:     }
154:     
155:     private func finishOpeningWorkspace(_ url: URL) {
156:         fileNavigator.loadFileTree(at: url)
157:         Task { @MainActor in
158:             LaunchManager.shared.setWorkspaceRoot(url)
159:             GitManager.shared.setWorkingDirectory(url)
160:         }
161:     }
162:     
163:     private func updateWindowTitle() {
164:         if let activeTab = editorCore.activeTab {
165:             let fileName = activeTab.fileName
166:             let unsavedIndicator = activeTab.isUnsaved ? "● " : ""
167:             windowTitle = "\(unsavedIndicator)\(fileName) - VS Code"
168:         } else if !editorCore.tabs.isEmpty {
169:             windowTitle = "VS Code"
170:         } else {
171:             windowTitle = "Welcome - VS Code"
172:         }
173:         
174:         // Notify the app of the title change
175:         NotificationCenter.default.post(
176:             name: NSNotification.Name("WindowTitleDidChange"),
177:             object: nil,
178:             userInfo: ["title": windowTitle]
179:         )
180:     }
181:     
182:     @ViewBuilder
183:     private var sidebarContent: some View {
184:         switch selectedSidebarTab {
185:         case 0:
186:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
187:         case 1:
188:             SidebarSearchView(theme: theme)
189:         case 2:
190:             GitView()
191:         case 3:
192:             DebugView()
193:         default:
194:             IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showingFolderPicker, theme: theme)
195:         }
196:     }
197: }
198: 
199: // MARK: - Activity Bar
200: 
201: 
202: 
203: struct BarButton: View {
204:     let icon: String
205:     let isSelected: Bool
206:     let theme: Theme
207:     let action: () -> Void
208:     
209:     var body: some View {
210:         Button(action: action) {
211:             Image(systemName: icon)
212:                 .font(.system(size: 22))
213:                 .foregroundColor(isSelected ? theme.activityBarSelection : theme.activityBarForeground.opacity(0.6))
214:                 .frame(width: 48, height: 48)
215:         }
216:     }
217: }
218: 
219: // MARK: - Sidebar with Real File System
220: 
221: struct IDESidebarFiles: View {
222:     @ObservedObject var editorCore: EditorCore
223:     @ObservedObject var fileNavigator: FileSystemNavigator
224:     @Binding var showFolderPicker: Bool
225:     let theme: Theme
226:     
227:     var body: some View {
228:         VStack(alignment: .leading, spacing: 0) {
229:             HStack {
230:                 Text("EXPLORER").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
231:                 Spacer()
232:                 Button(action: { showFolderPicker = true }) {
233:                     Image(systemName: "folder.badge.plus").font(.caption)
234:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
235:                 Button(action: { editorCore.showFilePicker = true }) {
236:                     Image(systemName: "doc.badge.plus").font(.caption)
237:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
238:                 if fileNavigator.fileTree != nil {
239:                     Button(action: { fileNavigator.refreshFileTree() }) {
240:                         Image(systemName: "arrow.clockwise").font(.caption)
241:                     }.foregroundColor(theme.sidebarForeground.opacity(0.7))
242:                 }
243:             }.padding(.horizontal, 12).padding(.vertical, 8)
244:             
245:             ScrollView {
246:                 VStack(alignment: .leading, spacing: 2) {
247:                     if let tree = fileNavigator.fileTree {
248:                         FileTreeView(root: tree, fileNavigator: fileNavigator, editorCore: editorCore)
249:                     } else {
250:                         DemoFileTree(editorCore: editorCore, theme: theme)
251:                     }
252:                 }.padding(.horizontal, 8)
253:             }
254:         }.background(theme.sidebarBackground)
255:     }
256: }
257: 
258: struct RealFileTreeView: View {
259:     let node: FileTreeNode
260:     let level: Int
261:     @ObservedObject var fileNavigator: FileSystemNavigator
262:     @ObservedObject var editorCore: EditorCore
263:     let theme: Theme
264:     
265:     var isExpanded: Bool { fileNavigator.expandedPaths.contains(node.url.path) }
266:     
267:     var body: some View {
268:         VStack(alignment: .leading, spacing: 2) {
269:             HStack(spacing: 4) {
270:                 if node.isDirectory {
271:                     Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
272:                         .font(.caption2).frame(width: 12)
273:                         .foregroundColor(theme.sidebarForeground.opacity(0.6))
274:                         .onTapGesture { fileNavigator.toggleExpanded(path: node.url.path) }
275:                 } else {
276:                     Spacer().frame(width: 12)
277:                 }
278:                 Image(systemName: node.isDirectory ? "folder.fill" : fileIcon(for: node.name))
279:                     .font(.caption)
280:                     .foregroundColor(node.isDirectory ? .yellow : fileColor(for: node.name))
281:                 Text(node.name).font(.system(.caption)).lineLimit(1)
282:                     .foregroundColor(theme.sidebarForeground)
283:                 Spacer()
284:             }
285:             .padding(.leading, CGFloat(level * 16)).padding(.vertical, 4)
286:             .contentShape(Rectangle())
287:             .onTapGesture {
288:                 if node.isDirectory {
289:                     fileNavigator.toggleExpanded(path: node.url.path)
290:                 } else {
291:                     editorCore.openFile(from: node.url)
292:                 }
293:             }
294:             
295:             if isExpanded && node.isDirectory {
296:                 ForEach(node.children) { child in
297:                     RealFileTreeView(node: child, level: level + 1, fileNavigator: fileNavigator, editorCore: editorCore, theme: theme)
298:                 }
299:             }
300:         }
301:     }
302: }
303: 
304: struct DemoFileTree: View {
305:     @ObservedObject var editorCore: EditorCore
306:     let theme: Theme
307:     
308:     var body: some View {
309:         VStack(alignment: .leading, spacing: 4) {
310:             Text("Open a folder to browse files")
311:                 .font(.caption)
312:                 .foregroundColor(theme.sidebarForeground.opacity(0.6))
313:                 .padding(.vertical, 8)
314:             
315:             DemoFileRow(name: "main.swift", editorCore: editorCore, theme: theme)
316:             DemoFileRow(name: "ContentView.swift", editorCore: editorCore, theme: theme)
317:             DemoFileRow(name: "README.md", editorCore: editorCore, theme: theme)
318:         }
319:     }
320: }
321: 
322: struct DemoFileRow: View {
323:     let name: String
324:     @ObservedObject var editorCore: EditorCore
325:     let theme: Theme
326:     
327:     var body: some View {
328:         HStack(spacing: 4) {
329:             Spacer().frame(width: 12)
330:             Image(systemName: fileIcon(for: name)).font(.caption).foregroundColor(fileColor(for: name))
331:             Text(name).font(.system(.caption)).lineLimit(1).foregroundColor(theme.sidebarForeground)
332:             Spacer()
333:         }
334:         .padding(.vertical, 4)
335:         .contentShape(Rectangle())
336:         .onTapGesture {
337:             editorCore.addTab(fileName: name, content: "// \(name)\n\n")
338:         }
339:     }
340: }
341: 
342: // MARK: - Tab Bar
343: 
344: struct IDETabBar: View {
345:     @ObservedObject var editorCore: EditorCore
346:     let theme: Theme
347:     
348:     var body: some View {
349:         ScrollView(.horizontal, showsIndicators: false) {
350:             HStack(spacing: 0) {
351:                 ForEach(editorCore.tabs) { tab in
352:                     IDETabItem(tab: tab, isSelected: editorCore.activeTabId == tab.id, editorCore: editorCore, theme: theme)
353:                 }
354:                 Button(action: { editorCore.addTab() }) {
355:                     Image(systemName: "plus").font(.caption).foregroundColor(theme.tabInactiveForeground).padding(8)
356:                 }
357:             }.padding(.horizontal, 4)
358:         }.frame(height: 36).background(theme.tabBarBackground)
359:     }
360: }
361: 
362: struct IDETabItem: View {
363:     let tab: Tab
364:     let isSelected: Bool
365:     @ObservedObject var editorCore: EditorCore
366:     let theme: Theme
367:     
368:     var body: some View {
369:         HStack(spacing: 6) {
370:             Image(systemName: fileIcon(for: tab.fileName)).font(.caption).foregroundColor(fileColor(for: tab.fileName))
371:             Text(tab.fileName).font(.system(size: 12)).lineLimit(1)
372:                 .foregroundColor(isSelected ? theme.tabActiveForeground : theme.tabInactiveForeground)
373:             if tab.isUnsaved { Circle().fill(Color.orange).frame(width: 6, height: 6) }
374:             Button(action: { editorCore.closeTab(id: tab.id) }) {
375:                 Image(systemName: "xmark").font(.system(size: 9, weight: .medium))
376:                     .foregroundColor(isSelected ? theme.tabActiveForeground.opacity(0.6) : theme.tabInactiveForeground)
377:             }
378:         }
379:         .padding(.horizontal, 12).padding(.vertical, 6)
380:         .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? theme.tabActiveBackground : theme.tabInactiveBackground))
381:         .onTapGesture { editorCore.selectTab(id: tab.id) }
382:     }
383: }
384: 
385: // MARK: - Editor with Syntax Highlighting + Autocomplete + Folding
386: 
387: struct IDEEditorView: View {
388:     @ObservedObject var editorCore: EditorCore
389:     let tab: Tab
390:     let theme: Theme
391: 
392:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
393:     @State private var text: String = ""
394:     @State private var scrollPosition: Int = 0
395:     @State private var totalLines: Int = 1
396:     @State private var visibleLines: Int = 20
397:     @State private var currentLineNumber: Int = 1
398:     @State private var currentColumn: Int = 1
399:     @State private var cursorIndex: Int = 0
400:     @State private var lineHeight: CGFloat = 17
401:     @State private var requestedCursorIndex: Int? = nil
402:     @State private var requestedLineSelection: Int? = nil
403: 
404:     @StateObject private var autocomplete = AutocompleteManager()
405:     @State private var showAutocomplete = false
406:     @StateObject private var foldingManager = CodeFoldingManager()
407:     @StateObject private var findViewModel = FindViewModel()
408:     
409:     var body: some View {
410:         VStack(spacing: 0) {
411:             // Find/Replace bar
412:             if editorCore.showSearch {
413:                 FindReplaceView(viewModel: findViewModel)
414:                     .background(theme.tabBarBackground)
415:             }
416:             
417:             BreadcrumbsView(editorCore: editorCore, tab: tab)
418:             
419:             GeometryReader { geometry in
420:                 ZStack(alignment: .topLeading) {
421:                 HStack(spacing: 0) {
422:                     if lineNumbersStyle != "off" {
423:                         LineNumbersWithFolding(
424:                             fileId: tab.url?.path ?? tab.fileName,
425:                             totalLines: totalLines,
426:                             currentLine: currentLineNumber,
427:                             scrollOffset: CGFloat(scrollPosition) * lineHeight,
428:                             lineHeight: lineHeight,
429:                             requestedLineSelection: $requestedLineSelection,
430:                             foldingManager: foldingManager,
431:                             theme: theme
432:                         )
433:                         .frame(width: 60)
434:                         .background(theme.sidebarBackground.opacity(0.5))
435:                     }
436:                     
437:                     if tab.fileName.hasSuffix(".json") {
438:                         // JSON Tree View for .json files
439:                         JSONTreeView(data: text.data(using: .utf8) ?? Data())
440:                             .frame(maxWidth: .infinity, maxHeight: .infinity)
441:                             .background(theme.editorBackground)
442:                     } else {
443:                         SyntaxHighlightingTextView(
444:                             text: $text,
445:                             filename: tab.fileName,
446:                             scrollPosition: $scrollPosition,
447:                             totalLines: $totalLines,
448:                             visibleLines: $visibleLines,
449:                             currentLineNumber: $currentLineNumber,
450:                             currentColumn: $currentColumn,
451:                             cursorIndex: $cursorIndex,
452:                             lineHeight: $lineHeight,
453:                             isActive: true,
454:                             requestedLineSelection: $requestedLineSelection,
455:                             requestedCursorIndex: $requestedCursorIndex,
456:                             onAcceptAutocomplete: {
457:                                 guard showAutocomplete else { return false }
458:                                 var tempText = text
459:                                 var tempCursor = cursorIndex
460:                                 autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
461:                                 if tempText != text {
462:                                     text = tempText
463:                                     cursorIndex = tempCursor
464:                                     requestedCursorIndex = tempCursor
465:                                     showAutocomplete = false
466:                                     return true
467:                                 }
468:                                 return false
469:                             },
470:                             onDismissAutocomplete: {
471:                                 guard showAutocomplete else { return false }
472:                                 autocomplete.hideSuggestions()
473:                                 showAutocomplete = false
474:                                 return true
475:                             }
476:                         )
477:                         .onChange(of: text) { newValue in
478:                             editorCore.updateActiveTabContent(newValue)
479:                             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: currentColumn)
480:                             autocomplete.updateSuggestions(for: newValue, cursorPosition: cursorIndex)
481:                             showAutocomplete = autocomplete.showSuggestions
482:                             foldingManager.detectFoldableRegions(in: newValue)
483:                         }
484:                         .onChange(of: cursorIndex) { newCursor in
485:                             autocomplete.updateSuggestions(for: text, cursorPosition: newCursor)
486:                             showAutocomplete = autocomplete.showSuggestions
487:                         }
488:                     }
489:                     
490:                     if !tab.fileName.hasSuffix(".json") {
491:                         MinimapView(
492:                             content: text,
493:                             scrollOffset: .constant(CGFloat(scrollPosition) * lineHeight),
494:                             scrollViewHeight: .constant(geometry.size.height),
495:                             totalContentHeight: CGFloat(totalLines) * lineHeight
496:                         )
497:                         .frame(width: 80)
498:                     }
499:                 }
500:                 .background(theme.editorBackground)
501: 
502:                 // Sticky Header Overlay (FEAT-040)
503:                 StickyHeaderView(
504:                     text: text,
505:                     currentLine: scrollPosition,
506:                     theme: theme,
507:                     lineHeight: lineHeight,
508:                     onSelect: { line in
509:                         requestedLineSelection = line
510:                     }
511:                 )
512:                 .padding(.leading, lineNumbersStyle != "off" ? 60 : 0)
513:                 .padding(.trailing, tab.fileName.hasSuffix(".json") ? 0 : 80)
514: 
515:                 if showAutocomplete && !autocomplete.suggestionItems.isEmpty {
516:                     AutocompletePopup(
517:                         suggestions: autocomplete.suggestionItems,
518:                         selectedIndex: autocomplete.selectedIndex,
519:                         theme: theme
520:                     ) { index in
521:                         autocomplete.selectedIndex = index
522:                         var tempText = text
523:                         var tempCursor = cursorIndex
524:                         autocomplete.commitCurrentSuggestion(into: &tempText, cursorPosition: &tempCursor)
525:                         if tempText != text {
526:                             text = tempText
527:                             cursorIndex = tempCursor
528:                             requestedCursorIndex = tempCursor
529:                         }
530:                         showAutocomplete = false
531:                     }
532:                     .offset(x: 70, y: CGFloat(currentLineNumber) * lineHeight)
533:                 }
534:             }
535:         }
536:         }
537:         .onAppear {
538:             text = tab.content
539:             foldingManager.detectFoldableRegions(in: text)
540:         }
541:         .onChange(of: tab.id) { _ in
542:             text = tab.content
543:             foldingManager.detectFoldableRegions(in: text)
544:         }
545:         .onChange(of: currentLineNumber) { line in
546:             editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
547:         }
548:         .onChange(of: currentColumn) { col in
549:             editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
550:         }
551:         .onAppear {
552:             findViewModel.editorCore = editorCore
553:         }
554:     }
555:     
556:     // Autocomplete insertion is handled by AutocompleteManager.acceptSuggestion(...)
557: }
558: 
559: // MARK: - Line Numbers with Folding
560: 
561: struct LineNumbersWithFolding: View {
562:     let fileId: String
563:     let totalLines: Int
564:     let currentLine: Int
565:     let scrollOffset: CGFloat
566:     let lineHeight: CGFloat
567:     @Binding var requestedLineSelection: Int?
568:     @ObservedObject var foldingManager: CodeFoldingManager
569:     @ObservedObject private var debugManager = DebugManager.shared
570:     let theme: Theme
571: 
572:     @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
573: 
574:     var body: some View {
575:         ScrollView(showsIndicators: false) {
576:             VStack(alignment: .trailing, spacing: 0) {
577:                 ForEach(0..<totalLines, id: \.self) { lineIndex in
578:                     if !foldingManager.isLineFolded(line: lineIndex) {
579:                         HStack(spacing: 2) {
580:                             Button(action: { debugManager.toggleBreakpoint(file: fileId, line: lineIndex) }) {
581:                                 Circle()
582:                                     .fill(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? Color.red : Color.clear)
583:                                     .overlay(
584:                                         Circle()
585:                                             .stroke(Color.red.opacity(0.6), lineWidth: 1)
586:                                             .opacity(debugManager.hasBreakpoint(file: fileId, line: lineIndex) ? 0 : 0.25)
587:                                     )
588:                                     .frame(width: 10, height: 10)
589:                                     .padding(.leading, 2)
590:                             }
591:                             .buttonStyle(.plain)
592:                             .frame(width: 14, height: lineHeight)
593: 
594:                             if foldingManager.isFoldable(line: lineIndex) {
595:                                 Button(action: { foldingManager.toggleFold(at: lineIndex) }) {
596:                                     Image(systemName: foldingManager.foldRegions.first(where: { $0.startLine == lineIndex })?.isFolded == true ? "chevron.right" : "chevron.down")
597:                                         .font(.system(size: 8))
598:                                         .foregroundColor(theme.lineNumber)
599:                                 }
600:                                 .buttonStyle(.plain)
601:                                 .frame(width: 14, height: lineHeight)
602:                             } else {
603:                                 Spacer().frame(width: 14)
604:                             }
605: 
606:                             Text(displayText(for: lineIndex))
607:                                 .font(.system(size: 12, design: .monospaced))
608:                                 .foregroundColor(lineIndex + 1 == currentLine ? theme.lineNumberActive : theme.lineNumber)
609:                                 .frame(height: lineHeight)
610:                                 .contentShape(Rectangle())
611:                                 .onTapGesture {
612:                                     // FEAT-041: click line number selects entire line
613:                                     requestedLineSelection = lineIndex
614:                                 }
615:                         }
616:                         .frame(maxWidth: .infinity, alignment: .trailing)
617:                         .padding(.trailing, 4)
618:                     }
619:                 }
620:             }
621:             .offset(y: -scrollOffset)
622:         }
623:     }
624: 
625:     private func displayText(for lineIndex: Int) -> String {
626:         switch lineNumbersStyle {
627:         case "relative":
628:             // VS Code-style: current line shows absolute, others show relative distance
629:             let lineNumber = lineIndex + 1
630:             if lineNumber == currentLine { return "\(lineNumber)" }
631:             return "\(abs(lineNumber - currentLine))"
632: 
633:         case "interval":
634:             let lineNumber = lineIndex + 1
635:             return (lineNumber == 1 || lineNumber % 5 == 0) ? "\(lineNumber)" : ""
636: 
637:         default:
638:             return "\(lineIndex + 1)"
639:         }
640:     }
641: }
642: 
643: // MARK: - Autocomplete Popup
644: 
645: struct AutocompletePopup: View {
646:     let suggestions: [AutocompleteSuggestion]
647:     let selectedIndex: Int
648:     let theme: Theme
649:     let onSelectIndex: (Int) -> Void
650:     
651:     var body: some View {
652:         VStack(alignment: .leading, spacing: 0) {
653:             ForEach(suggestions.indices, id: \.self) { index in
654:                 let s = suggestions[index]
655:                 HStack(spacing: 6) {
656:                     Image(systemName: icon(for: s.kind))
657:                         .font(.caption)
658:                         .foregroundColor(color(for: s.kind))
659:                     VStack(alignment: .leading, spacing: 1) {
660:                         Text(s.displayText)
661:                             .font(.system(size: 12, design: .monospaced))
662:                             .foregroundColor(theme.editorForeground)
663:                         if s.insertText != s.displayText && !s.insertText.isEmpty {
664:                             Text(s.insertText)
665:                                 .font(.system(size: 10, design: .monospaced))
666:                                 .foregroundColor(theme.editorForeground.opacity(0.55))
667:                                 .lineLimit(1)
668:                         }
669:                     }
670:                     Spacer()
671:                 }
672:                 .padding(.horizontal, 8).padding(.vertical, 6)
673:                 .background(index == selectedIndex ? theme.selection : Color.clear)
674:                 .contentShape(Rectangle())
675:                 .onTapGesture { onSelectIndex(index) }
676:             }
677:         }
678:         .frame(width: 260)
679:         .background(theme.editorBackground)
680:         .cornerRadius(6)
681:         .shadow(radius: 8)
682:     }
683:     
684:     private func icon(for kind: AutocompleteSuggestionKind) -> String {
685:         switch kind {
686:         case .keyword: return "key.fill"
687:         case .symbol: return "cube.fill"
688:         case .stdlib: return "curlybraces"
689:         case .member: return "arrow.right.circle.fill"
690:         }
691:     }
692:     
693:     private func color(for kind: AutocompleteSuggestionKind) -> Color {
694:         switch kind {
695:         case .keyword: return .purple
696:         case .symbol: return .blue
697:         case .stdlib: return .orange
698:         case .member: return .green
699:         }
700:     }
701: }
702: 
703: // MARK: - Welcome View
704: 
705: struct IDEWelcomeView: View {
706:     @ObservedObject var editorCore: EditorCore
707:     @Binding var showFolderPicker: Bool
708:     let theme: Theme
709:     
710:     var body: some View {
711:         VStack(spacing: 24) {
712:             Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 80)).foregroundColor(theme.editorForeground.opacity(0.3))
713:             Text("VS Code for iPadOS").font(.largeTitle).fontWeight(.bold).foregroundColor(theme.editorForeground)
714:             VStack(alignment: .leading, spacing: 12) {
715:                 WelcomeBtn(icon: "doc.badge.plus", title: "New File", shortcut: "⌘N", theme: theme) { editorCore.addTab() }
716:                 WelcomeBtn(icon: "folder", title: "Open Folder", shortcut: "⌘⇧O", theme: theme) { showFolderPicker = true }
717:                 WelcomeBtn(icon: "doc", title: "Open File", shortcut: "⌘O", theme: theme) { editorCore.showFilePicker = true }
718:                 WelcomeBtn(icon: "terminal", title: "Command Palette", shortcut: "⌘⇧P", theme: theme) { editorCore.showCommandPalette = true }
719:             }
720:         }.frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.editorBackground)
721:     }
722: }
723: 
724: struct WelcomeBtn: View {
725:     let icon: String
726:     let title: String
727:     let shortcut: String
728:     let theme: Theme
729:     let action: () -> Void
730:     
731:     var body: some View {
732:         Button(action: action) {
733:             HStack {
734:                 Image(systemName: icon).frame(width: 24).foregroundColor(theme.editorForeground)
735:                 Text(title).foregroundColor(theme.editorForeground)
736:                 Spacer()
737:                 Text(shortcut).font(.caption).foregroundColor(theme.editorForeground.opacity(0.5))
738:             }
739:             .padding().frame(width: 280)
740:             .background(theme.sidebarBackground)
741:             .cornerRadius(8)
742:         }.buttonStyle(.plain)
743:     }
744: }
745: 
746: // MARK: - Command Palette
747: 
748: struct IDECommandPalette: View {
749:     @ObservedObject var editorCore: EditorCore
750:     @Binding var showSettings: Bool
751:     @Binding var showTerminal: Bool
752:     @State private var searchText = ""
753:     
754:     var body: some View {
755:         VStack(spacing: 0) {
756:             HStack {
757:                 Image(systemName: "magnifyingglass").foregroundColor(.secondary)
758:                 TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
759:             }.padding().background(Color(UIColor.secondarySystemBackground))
760:             Divider()
761:             ScrollView {
762:                 VStack(spacing: 0) {
763:                     CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
764:                     CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
765:                     CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
766:                     CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
767:                     CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
768:                     CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
769:                     CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
770:                     CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
771:                 }.padding(.vertical, 8)
772:             }
773:         }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
774:     }
775: }
776: 
777: struct CommandRow: View {
778:     let icon: String; let name: String; let shortcut: String; let action: () -> Void
779:     var body: some View {
780:         Button(action: action) {
781:             HStack {
782:                 Image(systemName: icon).foregroundColor(.accentColor).frame(width: 24)
783:                 Text(name).foregroundColor(.primary)
784:                 Spacer()
785:                 Text(shortcut).font(.caption).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 4).background(Color(UIColor.tertiarySystemFill)).cornerRadius(4)
786:             }.padding(.horizontal).padding(.vertical, 12).contentShape(Rectangle())
787:         }.buttonStyle(.plain)
788:     }
789: }
790: 
791: // MARK: - Quick Open
792: 
793: struct IDEQuickOpen: View {
794:     @ObservedObject var editorCore: EditorCore
795:     @State private var searchText = ""
796:     
797:     var body: some View {
798:         VStack(spacing: 0) {
799:             HStack {
800:                 Image(systemName: "magnifyingglass").foregroundColor(.gray)
801:                 TextField("Search files...", text: $searchText).textFieldStyle(.plain)
802:             }.padding().background(Color(UIColor.secondarySystemBackground))
803:             Divider()
804:             ScrollView {
805:                 VStack(alignment: .leading, spacing: 0) {
806:                     ForEach(editorCore.tabs) { tab in
807:                         QuickOpenRow(name: tab.fileName, path: "") {
808:                             editorCore.selectTab(id: tab.id)
809:                             editorCore.showQuickOpen = false
810:                         }
811:                     }
812:                 }
813:             }.frame(maxHeight: 350)
814:         }.frame(width: 500).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
815:     }
816: }
817: 
818: struct QuickOpenRow: View {
819:     let name: String; let path: String; let action: () -> Void
820:     var body: some View {
821:         Button(action: action) {
822:             HStack {
823:                 Image(systemName: fileIcon(for: name)).foregroundColor(fileColor(for: name)).frame(width: 20)
824:                 VStack(alignment: .leading, spacing: 2) { Text(name).font(.system(size: 14)); Text(path + name).font(.system(size: 11)).foregroundColor(.secondary) }
825:                 Spacer()
826:             }.padding(.horizontal).padding(.vertical, 8).contentShape(Rectangle())
827:         }.buttonStyle(.plain)
828:     }
829: }
830: 
831: // MARK: - AI Assistant
832: 
833: struct IDEAIAssistant: View {
834:     @ObservedObject var editorCore: EditorCore
835:     let theme: Theme
836:     @State private var userInput = ""
837:     @State private var messages: [(id: UUID, role: String, content: String)] = [(UUID(), "assistant", "Hello! I'm your AI coding assistant. How can I help?")]
838:     
839:     var body: some View {
840:         VStack(spacing: 0) {
841:             HStack {
842:                 Image(systemName: "brain").foregroundColor(.blue)
843:                 Text("AI Assistant").font(.headline).foregroundColor(theme.editorForeground)
844:                 Spacer()
845:                 Button(action: { editorCore.showAIAssistant = false }) { Image(systemName: "xmark.circle.fill").foregroundColor(theme.editorForeground.opacity(0.5)) }
846:             }.padding().background(theme.sidebarBackground)
847:             
848:             ScrollView {
849:                 LazyVStack(alignment: .leading, spacing: 12) {
850:                     ForEach(messages, id: \.id) { msg in
851:                         HStack {
852:                             if msg.role == "user" { Spacer(minLength: 60) }
853:                             Text(msg.content).padding(12).background(RoundedRectangle(cornerRadius: 12).fill(msg.role == "user" ? Color.blue : theme.sidebarBackground)).foregroundColor(msg.role == "user" ? .white : theme.editorForeground)
854:                             if msg.role == "assistant" { Spacer(minLength: 60) }
855:                         }
856:                     }
857:                 }.padding()
858:             }.background(theme.editorBackground)
859:             
860:             HStack(spacing: 12) {
861:                 TextField("Ask about your code...", text: $userInput).textFieldStyle(.roundedBorder)
862:                 Button(action: { sendMessage() }) { Image(systemName: "paperplane.fill").foregroundColor(userInput.isEmpty ? .gray : .blue) }.disabled(userInput.isEmpty)
863:             }.padding().background(theme.sidebarBackground)
864:         }.background(theme.editorBackground).cornerRadius(12).shadow(radius: 20)
865:     }
866:     
867:     func sendMessage() {
868:         guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
869:         messages.append((UUID(), "user", userInput))
870:         let input = userInput
871:         userInput = ""
872:         DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
873:             messages.append((UUID(), "assistant", "I can help with '\(input)'! What specifically would you like to know?"))
874:         }
875:     }
876: }
877: 
878: // MARK: - Status Bar
879: 
880: 
881: 
882: // MARK: - Folder Picker
883: 
884: struct IDEFolderPicker: UIViewControllerRepresentable {
885:     @ObservedObject var fileNavigator: FileSystemNavigator
886:     var onPick: ((URL) -> Void)?
887:     
888:     init(fileNavigator: FileSystemNavigator, onPick: ((URL) -> Void)? = nil) {
889:         self.fileNavigator = fileNavigator
890:         self.onPick = onPick
891:     }
892:     
893:     func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
894:         let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
895:         picker.delegate = context.coordinator
896:         return picker
897:     }
898:     
899:     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
900:     
901:     func makeCoordinator() -> Coordinator { Coordinator(self) }
902:     
903:     class Coordinator: NSObject, UIDocumentPickerDelegate {
904:         let parent: IDEFolderPicker
905:         init(_ parent: IDEFolderPicker) { self.parent = parent }
906:         
907:         func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
908:             if let url = urls.first {
909:                 _ = url.startAccessingSecurityScopedResource()
910:                 if let onPick = parent.onPick {
911:                     onPick(url)
912:                 } else {
913:                     // Default behavior if no custom handler
914:                     parent.fileNavigator.loadFileTree(at: url)
915:                     Task { @MainActor in
916:                         LaunchManager.shared.setWorkspaceRoot(url)
917:                         GitManager.shared.setWorkingDirectory(url)
918:                     }
919:                 }
920:             }
921:         }
922:     }
923: }
924: 
925: // MARK: - Document Picker
926: 
927: struct IDEDocumentPicker: UIViewControllerRepresentable {
928:     @ObservedObject var editorCore: EditorCore
929:     
930:     func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
931:         let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .sourceCode, .json, .plainText, .data])
932:         picker.allowsMultipleSelection = true
933:         picker.delegate = context.coordinator
934:         return picker
935:     }
936:     
937:     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
938:     
939:     func makeCoordinator() -> Coordinator { Coordinator(editorCore: editorCore) }
940:     
941:     class Coordinator: NSObject, UIDocumentPickerDelegate {
942:         let editorCore: EditorCore
943:         init(editorCore: EditorCore) { self.editorCore = editorCore }
944:         
945:         func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
946:             for url in urls { editorCore.openFile(from: url) }
947:             editorCore.showFilePicker = false
948:         }
949:         
950:         func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
951:             editorCore.showFilePicker = false
952:         }
953:     }
954: }
955: 
956: // MARK: - Sidebar Search View
957: 
958: struct SidebarSearchView: View {
959:     let theme: Theme
960:     @State private var searchText = ""
961:     @State private var replaceText = ""
962:     @State private var showReplace = false
963:     @State private var searchResults: [(fileName: String, line: Int, preview: String)] = []
964:     
965:     var body: some View {
966:         VStack(alignment: .leading, spacing: 0) {
967:             HStack {
968:                 Text("SEARCH").font(.caption).fontWeight(.semibold).foregroundColor(theme.sidebarForeground.opacity(0.7))
969:                 Spacer()
970:             }.padding(.horizontal, 12).padding(.vertical, 8)
971:             
972:             HStack(spacing: 4) {
973:                 Image(systemName: "magnifyingglass").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
974:                 TextField("Search", text: $searchText).textFieldStyle(.plain).font(.system(size: 13))
975:                     .foregroundColor(theme.sidebarForeground)
976:                 if !searchText.isEmpty {
977:                     Button(action: { searchText = "" }) {
978:                         Image(systemName: "xmark.circle.fill").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
979:                     }
980:                 }
981:             }
982:             .padding(8)
983:             .background(theme.editorBackground)
984:             .cornerRadius(6)
985:             .padding(.horizontal, 12)
986:             
987:             HStack {
988:                 Button(action: { showReplace.toggle() }) {
989:                     Image(systemName: showReplace ? "chevron.down" : "chevron.right").font(.caption2)
990:                     Text("Replace").font(.caption)
991:                 }.foregroundColor(theme.sidebarForeground.opacity(0.7))
992:                 Spacer()
993:             }.padding(.horizontal, 12).padding(.vertical, 6)
994:             
995:             if showReplace {
996:                 HStack(spacing: 4) {
997:                     Image(systemName: "arrow.right").foregroundColor(theme.sidebarForeground.opacity(0.6)).font(.caption)
998:                     TextField("Replace", text: $replaceText).textFieldStyle(.plain).font(.system(size: 13))
999:                         .foregroundColor(theme.sidebarForeground)
1000:                 }
1001:                 .padding(8)
1002:                 .background(theme.editorBackground)
1003:                 .cornerRadius(6)
1004:                 .padding(.horizontal, 12)
1005:             }
1006:             
1007:             Divider().padding(.top, 8)
1008:             
1009:             if searchText.isEmpty {
1010:                 VStack(spacing: 8) {
1011:                     Spacer()
1012:                     Image(systemName: "magnifyingglass").font(.largeTitle).foregroundColor(theme.sidebarForeground.opacity(0.3))
1013:                     Text("Search in files").font(.caption).foregroundColor(theme.sidebarForeground.opacity(0.6))
1014:                     Spacer()
1015:                 }.frame(maxWidth: .infinity)
1016:             } else {
1017:                 ScrollView {
1018:                     LazyVStack(alignment: .leading, spacing: 0) {
1019:                         ForEach(0..<searchResults.count, id: \.self) { i in
1020:                             let result = searchResults[i]
1021:                             VStack(alignment: .leading, spacing: 2) {
1022:                                 HStack {
1023:                                     Image(systemName: "doc.text").font(.caption2).foregroundColor(theme.sidebarForeground.opacity(0.6))
1024:                                     Text(result.fileName).font(.system(size: 11, weight: .medium)).foregroundColor(theme.sidebarForeground)
1025:                                     Spacer()
1026:                                     Text(":\(result.line)").font(.system(size: 10, design: .monospaced)).foregroundColor(theme.sidebarForeground.opacity(0.6))
1027:                                 }
1028:                                 Text(result.preview).font(.system(size: 11, design: .monospaced)).foregroundColor(theme.sidebarForeground.opacity(0.7)).lineLimit(1)
1029:                             }.padding(.horizontal, 12).padding(.vertical, 6)
1030:                         }
1031:                     }
1032:                 }
1033:             }
1034:         }
1035:         .background(theme.sidebarBackground)
1036:         .onChange(of: searchText) { query in
1037:             if query.isEmpty { searchResults = [] }
1038:             else { searchResults = [("ContentView.swift", 15, "Text(\"\(query)\")"), ("main.swift", 8, "// \(query)")] }
1039:         }
1040:     }
1041: }
1042: 
1043: // MARK: - Preview
1044: 
1045: #Preview {
1046:     ContentView()
1047: }
1048: 


Now let me check more of the SyntaxHighlightingTextView for any additional keyboard handling:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift", "start_line": 700, "end_line": 830}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 701-830 of 1776)
────────────────────────────────────────
701:     var onDismissAutocomplete: (() -> Bool)?
702:     
703:     // FEAT-039 & FEAT-043
704:     private var indentGuideColor: UIColor = .separator
705:     private var activeIndentGuideColor: UIColor = .label
706:     private var currentLineHighlightColor: UIColor = .clear
707:     
708:     override init(frame: CGRect, textContainer: NSTextContainer?) {
709:         super.init(frame: frame, textContainer: textContainer)
710:         setup()
711:     }
712:     
713:     required init?(coder: NSCoder) {
714:         super.init(coder: coder)
715:         setup()
716:     }
717:     
718:     private func setup() {
719:         // Ensure we redraw when bounds/selection change
720:         contentMode = .redraw
721:     }
722:     
723:     func updateThemeColors(theme: Theme) {
724:         self.indentGuideColor = UIColor(theme.indentGuide)
725:         self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
726:         self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
727:         setNeedsDisplay()
728:     }
729:     
730:     override func draw(_ rect: CGRect) {
731:         guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
732:             super.draw(rect)
733:             return
734:         }
735:         
736:         // 1. Draw Current Line Highlight (FEAT-043)
737:         if let selectedRange = selectedTextRange {
738:             // Get the line rect for the cursor position
739:             let caretRect = self.caretRect(for: selectedRange.start)
740:             let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
741:             
742:             context.setFillColor(currentLineHighlightColor.cgColor)
743:             context.fill(lineRect)
744:         }
745:         
746:         // 2. Draw Text (super implementation)
747:         super.draw(rect)
748:         
749:         // 3. Draw Indent Guides (FEAT-039)
750:         // We iterate visible lines and draw vertical lines for indentation
751:         // Optimization: Only draw for visible range
752: 
753:         context.setLineWidth(1.0)
754: 
755:         // Respect editor tab size setting (default 4)
756:         let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
757:         let tabSize = storedTabSize > 0 ? storedTabSize : 4
758: 
759:         let spaceWidth = " ".size(withAttributes: [.font: font]).width
760:         let indentWidth = spaceWidth * CGFloat(tabSize)
761: 
762:         // Determine active indent level for caret line (for indentGuideActive)
763:         var activeIndentLevel: Int = 0
764:         if let selected = selectedTextRange {
765:             let caretPos = offset(from: beginningOfDocument, to: selected.start)
766:             let nsText = (self.text ?? "") as NSString
767:             let safeLoc = min(max(0, caretPos), nsText.length)
768:             let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
769:             let caretLineText = nsText.substring(with: caretLineRange)
770: 
771:             var spaces = 0
772:             for ch in caretLineText {
773:                 if ch == " " { spaces += 1 }
774:                 else if ch == "\t" { spaces += tabSize }
775:                 else { break }
776:             }
777:             activeIndentLevel = spaces / tabSize
778:         }
779: 
780:         // Iterate visible glyphs/lines
781:         let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
782:         let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
783: 
784:         let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
785: 
786:         layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
787:             // Get text for this line
788:             guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
789:                   let text = self.text as NSString? else { return }
790: 
791:             let lineText = text.substring(with: range)
792: 
793:             // Calculate indentation level
794:             var spaces = 0
795:             for char in lineText {
796:                 if char == " " { spaces += 1 }
797:                 else if char == "\t" { spaces += tabSize } // Handle tabs if present
798:                 else { break }
799:             }
800: 
801:             let indentLevel = spaces / tabSize
802:             guard indentLevel > 0 else { return }
803: 
804:             let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
805: 
806:             for i in 1...indentLevel {
807:                 let x = CGFloat(i) * indentWidth + self.textContainerInset.left
808:                 let startPoint = CGPoint(x: x, y: rect.minY)
809:                 let endPoint = CGPoint(x: x, y: rect.maxY)
810: 
811:                 let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
812:                 context.setStrokeColor(stroke.cgColor)
813: 
814:                 context.move(to: startPoint)
815:                 context.addLine(to: endPoint)
816:                 context.strokePath()
817:             }
818:         }
819:     }
820:     
821:     override var keyCommands: [UIKeyCommand]? {
822:         var commands = super.keyCommands ?? []
823:         
824:         // Peek Definition: Alt+F12 (using special key input)
825:         // Note: F12 is not directly available on iPadOS keyboards
826:         // Using Option+D as alternative
827:         commands.append(UIKeyCommand(
828:             input: "d",
829:             modifierFlags: .alternate,
830:             action: #selector(handlePeekDefinition)


Let me search for the menu commands that might be intercepting keyboard shortcuts:

>>>TOOL search
{"query": "UIKeyCommand", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 7 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:496: // MARK: - UIKeyCommand Extensions for Partial Accept
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:504: static func registerInlineSuggestionKeyCommands() -> [UIKeyCommand] {
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:506: let ctrlRightCommand = UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:507: input: UIKeyCommand.inputRightArrow,
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:514: let optRightCommand = UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:515: input: UIKeyCommand.inputRightArrow,
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:524: @objc private func performPartialAccept(_ sender: UIKeyCommand) {


Let me search for more keyboard handling patterns in the codebase:

>>>TOOL search
{"query": "UIKeyCommand", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 22 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:496: // MARK: - UIKeyCommand Extensions for Partial Accept
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:504: static func registerInlineSuggestionKeyCommands() -> [UIKeyCommand] {
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:506: let ctrlRightCommand = UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:507: input: UIKeyCommand.inputRightArrow,
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:514: let optRightCommand = UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:515: input: UIKeyCommand.inputRightArrow,
VSCodeiPadOS/VSCodeiPadOS/Services/InlineSuggestionManager.swift:524: @objc private func performPartialAccept(_ sender: UIKeyCommand) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:821: override var keyCommands: [UIKeyCommand]? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:827: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:834: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:841: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:848: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:849: input: UIKeyCommand.inputEscape,
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:855: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:862: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:206: override var keyCommands: [UIKeyCommand]? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:210: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:218: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:226: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:234: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:242: commands.append(UIKeyCommand(
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:245: input: UIKeyCommand.inputEscape,


Let me check the AppDelegate for menu keyboard shortcut handling:

>>>TOOL search
{"query": "buildMenu", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:946: override func buildMenu(with builder: UIMenuBuilder) {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:947: super.buildMenu(with: builder)


>>>TOOL search
{"query": "override var keyCommands", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 2 matches:
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift:821: override var keyCommands: [UIKeyCommand]? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift:206: override var keyCommands: [UIKeyCommand]? {


Let me check MultiCursorTextView's keyCommands as well:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift", "start_line": 200, "end_line": 280}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 201-280 of 281)
────────────────────────────────────────
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


Let me search for where menu keyboard shortcuts are handled at the app level:

>>>TOOL search
{"query": "performKeyEquivalent", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "performKeyEquivalent"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift", "start_line": 200, "end_line": 280}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 201-280 of 281)
────────────────────────────────────────
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


Let me check for menu building at the app level:

>>>TOOL search
{"query": "CommandMenu", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "CommandMenu"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift", "start_line": 200, "end_line": 280}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/MultiCursorTextView.swift (lines 201-280 of 281)
────────────────────────────────────────
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


>>>TOOL search
{"query": "CommandMenu", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "CommandMenu"


Now I have enough information to provide a complete report.

>>>REPORT
## Keyboard Handling in SyntaxHighlightingTextView and Related Views

### Key Commands in SyntaxHighlightingTextView.swift (lines 821-869)
The `SyntaxHighlightedCodeTextView` class (UITextView subclass) overrides `keyCommands` to intercept:
- **Alt+D**: Peek Definition (`handlePeekDefinition`)
- **Cmd+G**: Go to Line (`handleGoToLine`)
- **Tab**: Accept autocomplete or insert tab (`handleTab`)
- **Escape**: Dismiss autocomplete (`handleEscape`)
- **Cmd+Opt+[**: Fold code (`handleFold`)
- **Cmd+Opt+]**: Unfold code (`handleUnfold`)

### Key Commands in MultiCursorTextView.swift (lines 206-250)
Also overrides `keyCommands`:
- **Tab**: Accept suggestion or insert tab
- **Cmd+D**: Add next occurrence
- **Cmd+Shift+L**: Select all occurrences
- **Cmd+G**: Go to Line
- **Escape**: Dismiss autocomplete or exit multi-cursor mode

### focusedSceneValue Setup
**SceneDelegate.swift (line 38):** The `focusedSceneValue` IS being used:
```swift
let contentView = ContentView()
    .environmentObject(core)
    .focusedSceneValue(\.menuEditorCore, core)
```

There's also a custom `FocusedSceneValueKey` defined (lines 222-231):
```swift
struct MenuEditorCoreKey: FocusedSceneValueKey {
    typealias Value = EditorCore
}
```

### ContentView.swift Keyboard Handling
ContentView does NOT use `.focusedValue` directly but relies on **NotificationCenter** (lines 121-151) to receive keyboard shortcut commands:
- ShowCommandPalette, ToggleTerminal, ToggleSidebar
- ShowQuickOpen, ShowGoToSymbol, ShowGoToLine
- ShowAIAssistant, NewFile, SaveFile, CloseFile

### pressesBegan
**Not found** anywhere in the codebase.

### Summary
When UITextView has focus, it captures keyboard via `override var keyCommands`. The shortcuts defined there (Tab, Escape, Cmd+G, etc.) are intercepted by the text view and won't propagate to SwiftUI's keyboard shortcut handlers or the app menu system. This is the standard iPadOS behavior - first responder UIKeyCommands take priority.

The `focusedSceneValue` is set up in SceneDelegate but is primarily used for the menu bar to access EditorCore, not for keyboard shortcut routing to/from the text view.
>>>END
