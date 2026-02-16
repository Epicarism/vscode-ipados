# Agent: keyboard-shortcut-investigator
**Status:** done
**Tokens:** 4,843
**Cost:** $0.0000
**Time:** 2026-02-16T09:17:28.226Z

## Task
Investigate the duplicate keyboard shortcut issue in VSCodeiPadOS. Read these files and find where commands are being duplicated:

1. VSCodeiPadOS/VSCodeiPadOS/Commands/AppCommands.swift
2. VSCodeiPadOS/VSCodeiPadOS/App/VSCodeiPadOSApp.swift
3. VSCodeiPadOS/VSCodeiPadOS/App/AppDelegate.swift
4. Any other files that register keyboard commands

The error shows duplicates for: Zoom In (Cmd+=), Zoom Out (Cmd+-), Toggle Sidebar (Cmd+B), Command Palette (Cmd+Shift+P), Toggle Terminal (Cmd+`)

Report:
1. Where are these commands defined?
2. Why are they duplicated?
3. How to fix the duplicates

## Response
I'll investigate the duplicate keyboard shortcut issue by reading the relevant files.





---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 2115f662fad5
File: VSCodeiPadOS/VSCodeiPadOS/App/VSCodeiPadOSApp.swift (lines 1-277 of 277)
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
52|3fc41b|        CommandMenu("File") {
53|afb006|            Button("New File") {
54|05599e|                NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
55|a7dc16|            }
56|1514aa|            .keyboardShortcut("n", modifiers: .command)
57|3070d1|            
58|774a66|            Button("New Window") {
59|2668c7|                // Request new window via UIKit
60|a7dc16|            }
61|06a7ad|            .keyboardShortcut("n", modifiers: [.command, .option])
62|3070d1|            
63|e744dc|            Divider()
64|3070d1|            
65|303836|            Button("Open...") {
66|0c45d2|                NotificationCenter.default.post(name: NSNotification.Name("OpenFile"), object: nil)
67|a7dc16|            }
68|d106ac|            // Note: Cmd+O removed - conflicts with UITextView
69|3070d1|            
70|e744dc|            Divider()
71|3070d1|            
72|87c1fc|            Button("Save") {
73|8cd475|                NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
74|a7dc16|            }
75|df0850|            .keyboardShortcut("s", modifiers: .command)
76|3070d1|            
77|cfb2e6|            Button("Save All") {
78|07b858|                NotificationCenter.default.post(name: NSNotification.Name("SaveAllFiles"), object: nil)
79|a7dc16|            }
80|31c983|            .keyboardShortcut("s", modifiers: [.command, .option])
81|3070d1|            
82|e744dc|            Divider()
83|3070d1|            
84|dce406|            Button("Close Tab") {
85|00bdfb|                NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
86|a7dc16|            }
87|fc759f|            .keyboardShortcut("w", modifiers: .command)
88|5f3077|        }
89|27e597|    }
90|b31277|}
91|adc83b|
92|5de97f|// MARK: - Edit Menu Commands
93|adc83b|
94|895d4c|struct EditMenuCommands: Commands {
95|9db218|    var body: some Commands {
96|37041c|        CommandMenu("Edit") {
97|07ea22|            // Note: Undo/Redo/Cut/Copy/Paste/SelectAll removed
98|89a76d|            // They conflict with UITextView's built-in handlers
99|3070d1|            
100|0b121d|            Button("Find") {
101|1bd6d0|                NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
102|a7dc16|            }
103|f97e35|            .keyboardShortcut("f", modifiers: .command)
104|3070d1|            
105|503e4e|            Button("Replace") {
106|35e0ea|                NotificationCenter.default.post(name: NSNotification.Name("ShowReplace"), object: nil)
107|a7dc16|            }
108|db41a5|            .keyboardShortcut("h", modifiers: [.command, .option])
109|5f3077|        }
110|27e597|    }
111|b31277|}
112|adc83b|
113|0dd79a|// MARK: - Selection Menu Commands
114|adc83b|
115|a96c93|struct SelectionMenuCommands: Commands {
116|9db218|    var body: some Commands {
117|3b5a73|        CommandMenu("Selection") {
118|57df08|            // Note: Select All removed - conflicts with UITextView Cmd+A
119|3070d1|            
120|463507|            Button("Add Cursor Above") {
121|be1ac5|                NotificationCenter.default.post(name: NSNotification.Name("AddCursorAbove"), object: nil)
122|a7dc16|            }
123|1d6b0a|            .keyboardShortcut(.upArrow, modifiers: [.command, .option])
124|3070d1|            
125|371466|            Button("Add Cursor Below") {
126|46f0c9|                NotificationCenter.default.post(name: NSNotification.Name("AddCursorBelow"), object: nil)
127|a7dc16|            }
128|2a6642|            .keyboardShortcut(.downArrow, modifiers: [.command, .option])
129|5f3077|        }
130|27e597|    }
131|b31277|}
132|adc83b|
133|c5458e|// MARK: - View Menu Commands
134|adc83b|
135|d50ec0|struct ViewMenuCommands: Commands {
136|9db218|    var body: some Commands {
137|9aad08|        CommandMenu("View") {
138|57043e|            Button("Command Palette") {
139|932cb8|                NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
140|a7dc16|            }
141|49e14c|            .keyboardShortcut("p", modifiers: [.command, .shift])
142|3070d1|            
143|e744dc|            Divider()
144|3070d1|            
145|7db6f2|            Button("Toggle Sidebar") {
146|a086b2|                NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
147|a7dc16|            }
148|dbb692|            .keyboardShortcut("b", modifiers: .command)
149|3070d1|            
150|f1d311|            Button("Toggle Terminal") {
151|59bb23|                NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
152|a7dc16|            }
153|9a2cbc|            .keyboardShortcut("`", modifiers: .command)
154|3070d1|            
155|e744dc|            Divider()
156|3070d1|            
157|f7d3e3|            Button("Zoom In") {
158|633c0b|                NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
159|a7dc16|            }
160|6d2677|            .keyboardShortcut("=", modifiers: .command)  // Use = instead of + (standard)
161|3070d1|            
162|205092|            Button("Zoom Out") {
163|376a08|                NotificationCenter.default.post(name: NSNotification.Name("ZoomOut"), object: nil)
164|a7dc16|            }
165|67ad89|            .keyboardShortcut("-", modifiers: .command)
166|5f3077|        }
167|27e597|    }
168|b31277|}
169|adc83b|
170|039e1e|// MARK: - Go Menu Commands
171|adc83b|
172|858f73|struct GoMenuCommands: Commands {
173|9db218|    var body: some Commands {
174|2bde10|        CommandMenu("Go") {
175|652cca|            Button("Go to File...") {
176|ec83f0|                NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
177|a7dc16|            }
178|f54154|            .keyboardShortcut("p", modifiers: .command)
179|3070d1|            
180|c951ba|            Button("Go to Symbol...") {
181|9df234|                NotificationCenter.default.post(name: NSNotification.Name("ShowGoToSymbol"), object: nil)
182|a7dc16|            }
183|83c5d3|            .keyboardShortcut("o", modifiers: [.command, .shift])
184|3070d1|            
185|6f4da5|            Button("Go to Line...") {
186|af95e1|                NotificationCenter.default.post(name: NSNotification.Name("ShowGoToLine"), object: nil)
187|a7dc16|            }
188|62ad6b|            .keyboardShortcut("g", modifiers: .control)
189|3070d1|            
190|e744dc|            Divider()
191|3070d1|            
192|4e3b1e|            Button("Go to Definition") {
193|fc7cff|                NotificationCenter.default.post(name: NSNotification.Name("GoToDefinition"), object: nil)
194|a7dc16|            }
195|98c4c4|            .keyboardShortcut(.return, modifiers: .command)
196|3070d1|            
197|6ebc31|            Button("Go Back") {
198|bee9db|                NotificationCenter.default.post(name: NSNotification.Name("GoBack"), object: nil)
199|a7dc16|            }
200|4bc856|            .keyboardShortcut("[", modifiers: .control)
201|3070d1|            
202|f5d504|            Button("Go Forward") {
203|9c476e|                NotificationCenter.default.post(name: NSNotification.Name("GoForward"), object: nil)
204|a7dc16|            }
205|6c5cfe|            .keyboardShortcut("]", modifiers: .control)
206|5f3077|        }
207|27e597|    }
208|b31277|}
209|adc83b|
210|bbbab3|// MARK: - Run Menu Commands
211|adc83b|
212|56b0ce|struct RunMenuCommands: Commands {
213|9db218|    var body: some Commands {
214|35cc5e|        CommandMenu("Run") {
215|a151cc|            Button("Start Debugging") {
216|17dc53|                NotificationCenter.default.post(name: NSNotification.Name("StartDebugging"), object: nil)
217|a7dc16|            }
218|622ffb|            .keyboardShortcut("d", modifiers: [.command, .shift])
219|3070d1|            
220|fabf77|            Button("Run Without Debugging") {
221|9a83e4|                NotificationCenter.default.post(name: NSNotification.Name("RunWithoutDebugging"), object: nil)
222|a7dc16|            }
223|ea09f1|            .keyboardShortcut("r", modifiers: [.command, .shift])
224|3070d1|            
225|e744dc|            Divider()
226|3070d1|            
227|faaca0|            Button("Toggle Breakpoint") {
228|200e8e|                NotificationCenter.default.post(name: NSNotification.Name("ToggleBreakpoint"), object: nil)
229|a7dc16|            }
230|4bceb6|            .keyboardShortcut("b", modifiers: [.command, .shift])
231|5f3077|        }
232|27e597|    }
233|b31277|}
234|adc83b|
235|044961|// MARK: - Terminal Menu Commands
236|adc83b|
237|d92349|struct TerminalMenuCommands: Commands {
238|9db218|    var body: some Commands {
239|ca8d66|        CommandMenu("Terminal") {
240|6f8152|            Button("New Terminal") {
241|5843c7|                NotificationCenter.default.post(name: NSNotification.Name("NewTerminal"), object: nil)
242|a7dc16|            }
243|6371c2|            .keyboardShortcut("`", modifiers: [.control, .shift])
244|3070d1|            
245|cb847d|            Button("Clear Terminal") {
246|5513ef|                NotificationCenter.default.post(name: NSNotification.Name("ClearTerminal"), object: nil)
247|a7dc16|            }
248|8c8fb9|            .keyboardShortcut("k", modifiers: .command)
249|5f3077|        }
250|27e597|    }
251|b31277|}
252|adc83b|
253|e76d5b|// MARK: - Help Menu Commands
254|adc83b|
255|453771|struct HelpMenuCommands: Commands {
256|9db218|    var body: some Commands {
257|4afa1e|        CommandMenu("Help") {
258|e250dd|            Button("Documentation") {
259|38b70d|                if let url = URL(string: "https://code.visualstudio.com/docs") {
260|196c99|                    UIApplication.shared.open(url)
261|4e2d32|                }
262|a7dc16|            }
263|3070d1|            
264|ca047c|            Button("Keyboard Shortcuts") {
265|7511e5|                NotificationCenter.default.post(name: NSNotification.Name("ShowKeyboardShortcuts"), object: nil)
266|a7dc16|            }
267|fbd9f7|            .keyboardShortcut("k", modifiers: [.command, .shift])
268|3070d1|            
269|e744dc|            Divider()
270|3070d1|            
271|317359|            Button("About VS Code for iPad") {
272|ad8883|                NotificationCenter.default.post(name: NSNotification.Name("ShowAbout"), object: nil)
273|a7dc16|            }
274|5f3077|        }
275|27e597|    }
276|b31277|}
277|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 24cc7acaed04
File: VSCodeiPadOS/VSCodeiPadOS/App/AppDelegate.swift (lines 1-115 of 115)
────────────────────────────────────────
1|8d0643|//
2|902a53|//  AppDelegate.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|4691e5|//  Application delegate handling scene configuration for multiple windows
6|90ee3e|//  and Stage Manager optimization for iPadOS 26+
7|8d0643|//
8|adc83b|
9|9ed0a9|import UIKit
10|adc83b|
11|3cca7a|class AppDelegate: NSObject, UIApplicationDelegate {
12|b4687f|    
13|e5a893|    // MARK: - Lifecycle
14|b4687f|    
15|33d2aa|    func application(
16|a041bf|        _ application: UIApplication,
17|af3a22|        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
18|54d8bb|    ) -> Bool {
19|d6ed84|        
20|c2c930|        // Configure for Stage Manager optimization
21|9fde61|        configureStageManager()
22|d6ed84|        
23|db1d00|        // Register for window title change notifications
24|98a1f3|        NotificationCenter.default.addObserver(
25|178334|            self,
26|1026a3|            selector: #selector(handleWindowTitleChange(_:)),
27|9251fc|            name: NSNotification.Name("WindowTitleDidChange"),
28|b4da80|            object: nil
29|3143a4|        )
30|d6ed84|        
31|4add8d|        return true
32|27e597|    }
33|b4687f|    
34|90645f|    // MARK: - Scene Configuration
35|b4687f|    
36|642801|    // NOTE: Removed configurationForConnecting - let SwiftUI handle scenes entirely
37|cf653c|    // Returning a custom UISceneConfiguration was causing "Info.plist contained no 
38|e0dcce|    // UIScene configuration dictionary" errors and duplicate menu registration
39|b4687f|    
40|33d2aa|    func application(
41|a041bf|        _ application: UIApplication,
42|cc07f8|        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
43|981e04|    ) {
44|346d01|        // Clean up state for discarded scenes
45|f91dbf|        for session in sceneSessions {
46|13854d|            let windowId = session.windowId
47|8a3206|            WindowStateManager.shared.removeWindow(id: windowId)
48|5f3077|        }
49|27e597|    }
50|b4687f|    
51|b8ce96|    // MARK: - Window Title Management
52|b4687f|    
53|4f435c|    @objc private func handleWindowTitleChange(_ notification: Notification) {
54|4972a3|        guard let userInfo = notification.userInfo,
55|54b0dd|              let title = userInfo["title"] as? String else {
56|bef5d6|            return
57|5f3077|        }
58|d6ed84|        
59|d28fe8|        updateWindowSceneTitle(title)
60|27e597|    }
61|b4687f|    
62|f1bb5d|    private func updateWindowSceneTitle(_ title: String) {
63|efc85f|        // Update all connected window scenes with the new title
64|8cf4d7|        UIApplication.shared.connectedScenes.forEach { scene in
65|ffa8b4|            if let windowScene = scene as? UIWindowScene {
66|5e2ae7|                windowScene.title = title
67|a7dc16|            }
68|5f3077|        }
69|27e597|    }
70|b4687f|    
71|60888a|    // MARK: - Stage Manager Optimization
72|b4687f|    
73|56f8ae|    private func configureStageManager() {
74|33b0f6|        // Enable Stage Manager optimizations for iPadOS 26+
75|896df0|        if #available(iOS 16.0, *) {
76|62c7b1|            // Configure scene resizing behavior
77|47a20d|            // This allows windows to properly resize in Stage Manager
78|3070d1|            
79|0c140f|            // Note: These are hints to the system that help optimize
80|f5f890|            // the app's behavior in Stage Manager
81|5f3077|        }
82|27e597|    }
83|b31277|}
84|adc83b|
85|9f3ee8|// MARK: - Scene Session Extensions
86|adc83b|
87|84f2bb|extension UISceneSession {
88|437984|    /// Get a stable identifier for this scene session
89|8c7288|    var windowId: UUID {
90|efbf1b|        // Use persistentIdentifier to create a stable UUID
91|8141ad|        if let uuid = UUID(uuidString: persistentIdentifier) {
92|956e7f|            return uuid
93|5f3077|        }
94|e1e8ff|        // Fallback: create deterministic UUID from identifier
95|7e91a8|        let data = Data(persistentIdentifier.utf8)
96|0719fd|        return UUID(uuid: (data as NSData).hash.uuid)
97|27e597|    }
98|b31277|}
99|adc83b|
100|968aa1|private extension Int {
101|04f38a|    var uuid: uuid_t {
102|db4b1b|        var value = self
103|7baffe|        var bytes = [UInt8](repeating: 0, count: 16)
104|8da4f9|        withUnsafeBytes(of: &value) { buffer in
105|615038|            for (index, byte) in buffer.enumerated() where index < 16 {
106|dadee0|                bytes[index] = byte
107|a7dc16|            }
108|5f3077|        }
109|80ab50|        return (bytes[0], bytes[1], bytes[2], bytes[3],
110|f2e7c9|                bytes[4], bytes[5], bytes[6], bytes[7],
111|d9dc14|                bytes[8], bytes[9], bytes[10], bytes[11],
112|a8934c|                bytes[12], bytes[13], bytes[14], bytes[15])
113|27e597|    }
114|b31277|}
115|adc83b|




---

## 🔧 TOOL RESULTS

[search]
Error searching: Extension 'danielswagg.outlier-chat' CANNOT use API proposal: findTextInFiles.
Its package.json#enabledApiProposals-property declares: [] but NOT findTextInFiles.
 The missing proposal MUST be added and you must start in extension development mode or use the following command line switch: --enable-proposed-api danielswagg.outlier-chat




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

[read_file]
snapshot: 5f6a28ffd89f
File: VSCodeiPadOS/VSCodeiPadOS/SceneDelegate.swift (lines 1-232 of 232)
────────────────────────────────────────
1|8d0643|//
2|8b0433|//  SceneDelegate.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|4ab835|//  Manages multiple window scenes for iPadOS 26+
6|19322b|//  Handles state restoration, drag & drop, and window lifecycle
7|8d0643|//
8|adc83b|
9|9ed0a9|import UIKit
10|d755ba|import SwiftUI
11|adc83b|
12|63b3f8|@available(iOS 13.0, *)
13|ab5aa9|class SceneDelegate: UIResponder, UIWindowSceneDelegate {
14|b4687f|    
15|c02655|    var window: UIWindow?
16|1c05ba|    private var editorCore: EditorCore?
17|c30156|    private var windowId: UUID?
18|b4687f|    
19|2b5817|    // MARK: - Scene Lifecycle
20|b4687f|    
21|30c416|    func scene(
22|c72bcd|        _ scene: UIScene,
23|52e3e3|        willConnectTo session: UISceneSession,
24|28ccd9|        options connectionOptions: UIScene.ConnectionOptions
25|981e04|    ) {
26|132ce0|        guard let windowScene = scene as? UIWindowScene else { return }
27|d6ed84|        
28|b08e33|        // Generate or retrieve window ID
29|a4a944|        windowId = session.windowId
30|d6ed84|        
31|c7887b|        // Create a new EditorCore instance for this window
32|d3ed24|        let core = EditorCore()
33|34bd65|        editorCore = core
34|d6ed84|        
35|2904fa|        // Create the root view
36|602d04|        let contentView = ContentView()
37|00c45c|            .environmentObject(core)
38|ecc241|            .focusedSceneValue(\.menuEditorCore, core)
39|290fad|            .onAppear {
40|c9c081|                self.restoreWindowState(session: session, connectionOptions: connectionOptions)
41|a7dc16|            }
42|d6ed84|        
43|f3da07|        // Set up the window
44|99bbff|        let window = UIWindow(windowScene: windowScene)
45|be5283|        window.rootViewController = UIHostingController(rootView: contentView)
46|ff7512|        window.makeKeyAndVisible()
47|ad7d12|        self.window = window
48|d6ed84|        
49|3fb169|        // Handle URL contexts if opening a file directly
50|ff4b38|        if let urlContext = connectionOptions.urlContexts.first {
51|52b95e|            handleFileURL(urlContext.url)
52|5f3077|        }
53|d6ed84|        
54|9dd565|        // Handle user activities (e.g., from handoff or spotlight)
55|1a548d|        if let userActivity = connectionOptions.userActivities.first {
56|c6ebf9|            handleUserActivity(userActivity)
57|5f3077|        }
58|d6ed84|        
59|e1f4e0|        // Set window title
60|a7290c|        updateWindowTitle()
61|d6ed84|        
62|29c39e|        // Register this window with the state manager
63|026c0a|        WindowStateManager.shared.registerWindow(id: windowId!)
64|27e597|    }
65|b4687f|    
66|dc320b|    func sceneDidDisconnect(_ scene: UIScene) {
67|1cd11f|        // Save state before disconnecting
68|560f80|        saveWindowState()
69|d6ed84|        
70|4fa5be|        // Remove window from state manager
71|343828|        if let windowId = windowId {
72|8a3206|            WindowStateManager.shared.removeWindow(id: windowId)
73|5f3077|        }
74|27e597|    }
75|b4687f|    
76|f58103|    func sceneDidBecomeActive(_ scene: UIScene) {
77|5268ab|        // Set as active window
78|343828|        if let windowId = windowId {
79|42d5e5|            WindowStateManager.shared.setActiveWindow(windowId)
80|5f3077|        }
81|27e597|    }
82|b4687f|    
83|bb790b|    func sceneWillResignActive(_ scene: UIScene) {
84|9ad73e|        // Save state when resigning active
85|560f80|        saveWindowState()
86|27e597|    }
87|b4687f|    
88|777a4c|    func sceneWillEnterForeground(_ scene: UIScene) {
89|adae51|        // Restore state when entering foreground
90|4747fa|        restoreWindowState(session: (scene as? UIWindowScene)?.session)
91|27e597|    }
92|b4687f|    
93|0eb6ae|    func sceneDidEnterBackground(_ scene: UIScene) {
94|a85728|        // Save state when entering background
95|560f80|        saveWindowState()
96|27e597|    }
97|b4687f|    
98|b5bff0|    // MARK: - State Restoration
99|b4687f|    
100|d04021|    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
101|218758|        // Return user activity for state restoration
102|541fda|        guard let windowId = windowId else { return nil }
103|d6ed84|        
104|47da9f|        let activity = WindowStateManager.shared.createUserActivity(for: windowId)
105|d6ed84|        
106|58fa2e|        // Update activity with current state
107|ab723c|        if let editorCore = editorCore {
108|9ddc54|            WindowStateManager.shared.captureState(
109|e91fb8|                from: editorCore,
110|c087fa|                windowId: windowId,
111|d78d47|                workspacePath: editorCore.fileNavigator?.rootPath
112|43d041|            )
113|5f3077|        }
114|d6ed84|        
115|f917ae|        return activity
116|27e597|    }
117|b4687f|    
118|cd8e50|    // MARK: - Window Title
119|b4687f|    
120|65a033|    private func updateWindowTitle() {
121|7498df|        guard let scene = window?.windowScene else { return }
122|d6ed84|        
123|0e0d17|        var title = "VS Code"
124|d6ed84|        
125|50dfa8|        if let editorCore = editorCore,
126|8487f8|           let activeTab = editorCore.activeTab {
127|3bb043|            title = activeTab.fileName
128|3070d1|            
129|d5fc76|            // Add unsaved indicator
130|88e50f|            if activeTab.isUnsaved {
131|3996ec|                title += " •"
132|a7dc16|            }
133|23d2f2|        } else if let editorCore = editorCore,
134|24e9a2|                  let workspacePath = editorCore.fileNavigator?.rootPath {
135|c42efc|            title = URL(fileURLWithPath: workspacePath).lastPathComponent
136|5f3077|        }
137|d6ed84|        
138|af386a|        scene.title = title
139|27e597|    }
140|b4687f|    
141|a5d60f|    // MARK: - File Handling
142|b4687f|    
143|097679|    private func handleFileURL(_ url: URL) {
144|2ffb0a|        guard let editorCore = editorCore else { return }
145|d6ed84|        
146|c2792e|        // Start accessing security-scoped resource if needed
147|00e5df|        let _ = url.startAccessingSecurityScopedResource()
148|f0b03c|        defer { url.stopAccessingSecurityScopedResource() }
149|d6ed84|        
150|7e8ea4|        // Open the file
151|0fcd75|        editorCore.openFile(from: url)
152|a7290c|        updateWindowTitle()
153|27e597|    }
154|b4687f|    
155|b6ebe2|    private func handleUserActivity(_ userActivity: NSUserActivity) {
156|2ffb0a|        guard let editorCore = editorCore else { return }
157|d6ed84|        
158|150df8|        // Check if this is a window activity
159|90cfc4|        if userActivity.activityType == WindowActivity.activityType {
160|7e5415|            if let fileURLString = userActivity.userInfo?[WindowActivity.fileURLKey] as? String,
161|c22bcb|               let fileURL = URL(string: fileURLString) {
162|63571d|                editorCore.openFile(from: fileURL)
163|a7dc16|            }
164|3070d1|            
165|b4b629|            if let workspacePath = userActivity.userInfo?[WindowActivity.workspacePathKey] as? String {
166|621677|                // TODO: Open workspace at path
167|32d2f4|                print("Opening workspace: \(workspacePath)")
168|a7dc16|            }
169|5f3077|        }
170|d6ed84|        
171|a7290c|        updateWindowTitle()
172|27e597|    }
173|b4687f|    
174|79b94a|    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
175|df4012|        guard let urlContext = URLContexts.first else { return }
176|da3456|        handleFileURL(urlContext.url)
177|27e597|    }
178|b4687f|    
179|ca06fa|    // MARK: - Window State Persistence
180|b4687f|    
181|f85f59|    private func saveWindowState() {
182|29e817|        guard let windowId = windowId,
183|db7e62|              let editorCore = editorCore else { return }
184|d6ed84|        
185|91ba82|        WindowStateManager.shared.captureState(
186|682f8c|            from: editorCore,
187|ee4ab2|            windowId: windowId,
188|3c099e|            workspacePath: editorCore.fileNavigator?.rootPath
189|3143a4|        )
190|27e597|    }
191|b4687f|    
192|51aff4|    private func restoreWindowState(
193|26ff28|        session: UISceneSession?,
194|6f0081|        connectionOptions: UIScene.ConnectionOptions? = nil
195|981e04|    ) {
196|29e817|        guard let windowId = windowId,
197|db7e62|              let editorCore = editorCore else { return }
198|d6ed84|        
199|57c77b|        // Try to restore from session state restoration activity
200|357cfd|        var shouldRestore = false
201|d6ed84|        
202|72d10b|        if let session = session,
203|81b869|           let activity = session.stateRestorationActivity {
204|59c85a|            shouldRestore = true
205|5f3077|        }
206|d6ed84|        
207|244feb|        // Or check connection options for user activity
208|f17840|        if !shouldRestore,
209|36767c|           let options = connectionOptions,
210|d8ebea|           let activity = options.userActivities.first {
211|59c85a|            shouldRestore = true
212|5f3077|        }
213|d6ed84|        
214|bc8631|        if shouldRestore {
215|9679c9|            WindowStateManager.shared.restoreState(to: editorCore, windowId: windowId)
216|5f3077|        }
217|27e597|    }
218|b31277|}
219|adc83b|
220|cfa4e8|// MARK: - FocusedSceneKey
221|adc83b|
222|1db858|struct MenuEditorCoreKey: FocusedSceneValueKey {
223|834def|    typealias Value = EditorCore
224|b31277|}
225|adc83b|
226|5d9029|extension FocusedSceneValues {
227|c7c87c|    var menuEditorCore: EditorCore? {
228|692154|        get { self[MenuEditorCoreKey.self] }
229|e2d7a3|        set { self[MenuEditorCoreKey.self] = newValue }
230|27e597|    }
231|b31277|}
232|adc83b|




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

[read_file]
snapshot: da7c0207c317
File: VSCodeiPadOS/VSCodeiPadOS/Views/CommandPaletteView.swift (lines 1-197 of 197)
────────────────────────────────────────
1|d755ba|import SwiftUI
2|adc83b|
3|7c5c9e|struct CommandPaletteView: View {
4|08e45e|    @Environment(\.dismiss) private var dismiss
5|e5f895|    @ObservedObject var editorCore: EditorCore
6|d901da|    @State private var searchText = ""
7|ed03ac|    @State private var commandCategories: [CommandCategory] = []
8|b4687f|    
9|2db5f3|    var filteredCommands: [CommandCategory] {
10|93055c|        if searchText.isEmpty {
11|08c645|            return commandCategories
12|5f3077|        }
13|5f075b|        return commandCategories.map { category in
14|697344|            CommandCategory(
15|872cc1|                name: category.name,
16|982470|                commands: category.commands.filter { command in
17|495c69|                    command.title.localizedCaseInsensitiveContains(searchText) ||
18|bb2e93|                    command.keywords.contains { $0.localizedCaseInsensitiveContains(searchText) }
19|4e2d32|                }
20|43d041|            )
21|458497|        }.filter { !$0.commands.isEmpty }
22|27e597|    }
23|b4687f|    
24|504e43|    var body: some View {
25|0c7ea9|        NavigationView {
26|319386|            List {
27|c54557|                ForEach(filteredCommands, id: \.name) { category in
28|c35ac3|                    Section(header: Text(category.name)) {
29|3559c3|                        ForEach(category.commands, id: \.title) { command in
30|f221ba|                            Button(action: {
31|0f806c|                                command.action()
32|a8dfb0|                                dismiss()
33|f71d4b|                            }) {
34|ccf016|                                HStack {
35|d9d809|                                    Image(systemName: command.icon)
36|b97656|                                        .foregroundColor(.accentColor)
37|5685ed|                                        .frame(width: 24)
38|4b4c70|                                    VStack(alignment: .leading, spacing: 4) {
39|baf973|                                        Text(command.title)
40|2087fb|                                            .font(.body)
41|d9e8cf|                                        if !command.shortcut.isEmpty {
42|52a1c9|                                            Text(command.shortcut)
43|4cd61f|                                                .font(.caption)
44|0a83e9|                                                .foregroundColor(.secondary)
45|eed1d8|                                        }
46|8ab74d|                                    }
47|c7a564|                                    Spacer()
48|f83e05|                                }
49|5cb7d4|                                .contentShape(Rectangle())
50|89d40a|                            }
51|c86208|                            .buttonStyle(PlainButtonStyle())
52|392b35|                        }
53|c9717a|                    }
54|4e2d32|                }
55|a7dc16|            }
56|5a4e59|            .listStyle(InsetGroupedListStyle())
57|64ac56|            .navigationTitle("Command Palette")
58|83a489|            .navigationBarTitleDisplayMode(.inline)
59|806036|            .toolbar {
60|f0ac3b|                ToolbarItem(placement: .cancellationAction) {
61|608a6e|                    Button("Close") {
62|af2c45|                        dismiss()
63|c9717a|                    }
64|4e2d32|                }
65|a7dc16|            }
66|692868|            .searchable(text: $searchText, prompt: "Search commands...")
67|5f3077|        }
68|2bd24e|        .onAppear {
69|226085|            loadCommands()
70|5f3077|        }
71|27e597|    }
72|b4687f|    
73|2b1eb6|    private func loadCommands() {
74|ae1481|        commandCategories = [
75|dd7d50|            CommandCategory(name: "Editor", commands: [
76|2e02a7|                CommandItem(
77|e59281|                    title: "Collapse All",
78|572b43|                    icon: "arrow.turn.down.right",
79|d9b618|                    shortcut: "Cmd+K Cmd+0",
80|ebd4f2|                    keywords: ["fold", "collapse", "hide"],
81|987936|                    action: { editorCore.collapseAllFolds() }
82|fd6d83|                ),
83|2e02a7|                CommandItem(
84|6082d1|                    title: "Expand All",
85|a2fce9|                    icon: "arrow.turn.up.right",
86|219984|                    shortcut: "Cmd+K Cmd+J",
87|1453a2|                    keywords: ["unfold", "expand", "show"],
88|02c4ff|                    action: { editorCore.expandAllFolds() }
89|fd6d83|                ),
90|2e02a7|                CommandItem(
91|aef641|                    title: "Toggle Sidebar",
92|1130c4|                    icon: "sidebar.left",
93|526519|                    shortcut: "Cmd+B",
94|69ef0c|                    keywords: ["sidebar", "panel"],
95|6859b6|                    action: { editorCore.toggleSidebar() }
96|fd6d83|                ),
97|2e02a7|                CommandItem(
98|f50832|                    title: "Toggle Zen Mode",
99|65a729|                    icon: "rectangle.compress.vertical",
100|951447|                    shortcut: "Cmd+K Z",
101|0d1615|                    keywords: ["zen", "focus", "distraction"],
102|0ecaff|                    action: { editorCore.toggleZenMode() }
103|fd6d83|                ),
104|2e02a7|                CommandItem(
105|d5df5d|                    title: "Go to Line...",
106|9555cd|                    icon: "arrow.right.to.line",
107|d473e3|                    shortcut: "Ctrl+G",
108|6e5567|                    keywords: ["goto", "line", "navigate"],
109|0f14ef|                    action: { editorCore.showGoToLine.toggle() }
110|fd6d83|                ),
111|8a1e7e|            ]),
112|3070d1|            
113|acd11d|            CommandCategory(name: "View", commands: [
114|2e02a7|                CommandItem(
115|87f72b|                    title: "Zoom In",
116|4fbd20|                    icon: "plus.magnifyingglass",
117|d3c9fd|                    shortcut: "Cmd++",
118|328643|                    keywords: ["zoom", "font", "size", "increase"],
119|98118c|                    action: { editorCore.zoomIn() }
120|fd6d83|                ),
121|2e02a7|                CommandItem(
122|28bbd9|                    title: "Zoom Out",
123|972545|                    icon: "minus.magnifyingglass",
124|9d4a8f|                    shortcut: "Cmd+-",
125|7b4502|                    keywords: ["zoom", "font", "size", "decrease"],
126|033bbe|                    action: { editorCore.zoomOut() }
127|fd6d83|                ),
128|8a1e7e|            ]),
129|3070d1|            
130|f3d5d8|            CommandCategory(name: "Navigation", commands: [
131|2e02a7|                CommandItem(
132|2ea8e3|                    title: "Focus Explorer",
133|966bd9|                    icon: "folder",
134|1270d5|                    shortcut: "Cmd+Shift+E",
135|f5d33b|                    keywords: ["explorer", "files", "sidebar"],
136|75f9e2|                    action: { editorCore.focusExplorer() }
137|fd6d83|                ),
138|2e02a7|                CommandItem(
139|fa3478|                    title: "Focus Git",
140|cc27f1|                    icon: "branch",
141|34089d|                    shortcut: "Cmd+Shift+G",
142|092330|                    keywords: ["git", "source", "control"],
143|3b1a5b|                    action: { editorCore.focusGit() }
144|fd6d83|                ),
145|8a1e7e|            ]),
146|3070d1|            
147|936b0e|            CommandCategory(name: "Tabs", commands: [
148|2e02a7|                CommandItem(
149|78c9b6|                    title: "Next Tab",
150|d0e2e9|                    icon: "chevron.right",
151|8d0619|                    shortcut: "Cmd+Option+Right",
152|ef9c67|                    keywords: ["tab", "next", "forward"],
153|045f22|                    action: { editorCore.nextTab() }
154|fd6d83|                ),
155|2e02a7|                CommandItem(
156|1f7ebf|                    title: "Previous Tab",
157|548a36|                    icon: "chevron.left",
158|0e4f2e|                    shortcut: "Cmd+Option+Left",
159|8aac1b|                    keywords: ["tab", "previous", "back"],
160|ea0beb|                    action: { editorCore.previousTab() }
161|fd6d83|                ),
162|2e02a7|                CommandItem(
163|df660b|                    title: "Close Tab",
164|3ed47a|                    icon: "xmark",
165|4b4b2c|                    shortcut: "Cmd+W",
166|f3bd01|                    keywords: ["tab", "close"],
167|9c0645|                    action: { 
168|bbc10a|                        if let id = editorCore.activeTabId {
169|fcc990|                            editorCore.closeTab(id: id)
170|392b35|                        }
171|c9717a|                    }
172|fd6d83|                ),
173|8a1e7e|            ]),
174|220505|        ]
175|27e597|    }
176|b31277|}
177|adc83b|
178|d330b1|struct CommandCategory {
179|a5193b|    let name: String
180|869084|    let commands: [CommandItem]
181|b31277|}
182|adc83b|
183|fc1dcc|struct CommandItem {
184|399f36|    let title: String
185|f0e87a|    let icon: String
186|14874c|    let shortcut: String
187|ff3750|    let keywords: [String]
188|59027a|    let action: () -> Void
189|b31277|}
190|adc83b|
191|f17f7a|// Preview
192|0cc92e|struct CommandPaletteView_Previews: PreviewProvider {
193|b92db4|    static var previews: some View {
194|fc9fc0|        CommandPaletteView(editorCore: EditorCore())
195|27e597|    }
196|b31277|}
197|adc83b|




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
snapshot: ea6e3a2199bd
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 2-150 of 2463)
────────────────────────────────────────
2|801b36|//  SyntaxHighlightingTextView.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|2b1080|//  Upgraded syntax highlighting with VSCode-like colors
6|8d0643|//
7|adc83b|
8|d755ba|import SwiftUI
9|9ed0a9|import UIKit
10|adc83b|
11|cc3622|/// UITextView wrapper with syntax highlighting support
12|827fc2|struct SyntaxHighlightingTextView: UIViewRepresentable {
13|abdc8e|    @Binding var text: String
14|ab828e|    let filename: String
15|737b69|    @Binding var scrollPosition: Int
16|9e95fe|    /// Pixel scroll offset (contentOffset.y) for smooth gutter alignment.
17|d84a59|    @Binding var scrollOffset: CGFloat
18|4cb87f|    @Binding var totalLines: Int
19|4a4dc7|    @Binding var visibleLines: Int
20|aab88e|    @Binding var currentLineNumber: Int
21|a5aa31|    @Binding var currentColumn: Int
22|9e1100|    @Binding var cursorIndex: Int
23|e9f1b4|    @Binding var lineHeight: CGFloat
24|86829b|    @Binding var requestedLineSelection: Int?
25|d2a57a|    @Binding var requestedCursorIndex: Int?
26|adc83b|
27|594855|    /// Autocomplete key handling hooks (return true if handled)
28|e7b3cd|    let onAcceptAutocomplete: (() -> Bool)?
29|7c9ea4|    let onDismissAutocomplete: (() -> Bool)?
30|adc83b|
31|65ebe2|    let isActive: Bool
32|1d448d|    let fontSize: CGFloat  // Explicit parameter to trigger SwiftUI updates
33|088df4|    @EnvironmentObject var editorCore: EditorCore
34|adc83b|
35|62e028|    init(
36|30281b|        text: Binding<String>,
37|9be454|        filename: String,
38|7be08a|        scrollPosition: Binding<Int>,
39|ab89ef|        scrollOffset: Binding<CGFloat> = .constant(0),
40|b063a9|        totalLines: Binding<Int>,
41|18661e|        visibleLines: Binding<Int>,
42|058768|        currentLineNumber: Binding<Int>,
43|fd200b|        currentColumn: Binding<Int>,
44|a428dc|        cursorIndex: Binding<Int> = .constant(0),
45|3a1495|        lineHeight: Binding<CGFloat>,
46|4ee198|        isActive: Bool,
47|c7d56f|        fontSize: CGFloat = 14.0,
48|b14930|        requestedLineSelection: Binding<Int?> = .constant(nil),
49|ccd5bf|        requestedCursorIndex: Binding<Int?> = .constant(nil),
50|31d064|        onAcceptAutocomplete: (() -> Bool)? = nil,
51|7f921c|        onDismissAutocomplete: (() -> Bool)? = nil
52|981e04|    ) {
53|772eb2|        self._text = text
54|693829|        self.filename = filename
55|49d0bf|        self._scrollPosition = scrollPosition
56|b44e77|        self._scrollOffset = scrollOffset
57|f2dacc|        self._totalLines = totalLines
58|6eae9c|        self._visibleLines = visibleLines
59|2111d8|        self._currentLineNumber = currentLineNumber
60|6ac61d|        self._currentColumn = currentColumn
61|a30d0a|        self._cursorIndex = cursorIndex
62|374be9|        self._lineHeight = lineHeight
63|a76635|        self.isActive = isActive
64|aefa3e|        self.fontSize = fontSize
65|868f30|        self._requestedLineSelection = requestedLineSelection
66|095cb5|        self._requestedCursorIndex = requestedCursorIndex
67|e84aef|        self.onAcceptAutocomplete = onAcceptAutocomplete
68|b27828|        self.onDismissAutocomplete = onDismissAutocomplete
69|27e597|    }
70|b4687f|    
71|8e1517|    // Compatibility init for older call sites (e.g. SplitEditorView) that pass editorCore explicitly.
72|62e028|    init(
73|30281b|        text: Binding<String>,
74|9be454|        filename: String,
75|7be08a|        scrollPosition: Binding<Int>,
76|ab89ef|        scrollOffset: Binding<CGFloat> = .constant(0),
77|b063a9|        totalLines: Binding<Int>,
78|18661e|        visibleLines: Binding<Int>,
79|058768|        currentLineNumber: Binding<Int>,
80|fd200b|        currentColumn: Binding<Int>,
81|a428dc|        cursorIndex: Binding<Int> = .constant(0),
82|3a1495|        lineHeight: Binding<CGFloat>,
83|4ee198|        isActive: Bool,
84|6cab1e|        editorCore: EditorCore,
85|b14930|        requestedLineSelection: Binding<Int?> = .constant(nil),
86|ccd5bf|        requestedCursorIndex: Binding<Int?> = .constant(nil),
87|31d064|        onAcceptAutocomplete: (() -> Bool)? = nil,
88|7f921c|        onDismissAutocomplete: (() -> Bool)? = nil
89|981e04|    ) {
90|12bb4e|        self.init(
91|8c084c|            text: text,
92|8079e2|            filename: filename,
93|589245|            scrollPosition: scrollPosition,
94|c50afd|            scrollOffset: scrollOffset,
95|85790a|            totalLines: totalLines,
96|606078|            visibleLines: visibleLines,
97|c96f84|            currentLineNumber: currentLineNumber,
98|f0da98|            currentColumn: currentColumn,
99|51893e|            cursorIndex: cursorIndex,
100|5fb46d|            lineHeight: lineHeight,
101|f80b98|            isActive: isActive,
102|af80eb|            fontSize: editorCore.editorFontSize,
103|952bce|            requestedLineSelection: requestedLineSelection,
104|be28fe|            requestedCursorIndex: requestedCursorIndex,
105|b905e4|            onAcceptAutocomplete: onAcceptAutocomplete,
106|c5cc6f|            onDismissAutocomplete: onDismissAutocomplete
107|3143a4|        )
108|27e597|    }
109|adc83b|
110|89795a|    func makeCoordinator() -> Coordinator {
111|5b6b15|        Coordinator(self)
112|27e597|    }
113|b4687f|    
114|40c383|    func makeUIView(context: Context) -> UITextView {
115|b5c2d7|        // Create custom TextKit stack with FoldingLayoutManager for code folding support
116|4eb525|        let textStorage = NSTextStorage()
117|14dcca|        let foldingLayoutManager = FoldingLayoutManager()
118|3486e3|        textStorage.addLayoutManager(foldingLayoutManager)
119|d6ed84|        
120|b03988|        let textContainer = NSTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
121|8235fe|        textContainer.widthTracksTextView = true
122|2a578c|        foldingLayoutManager.addTextContainer(textContainer)
123|d6ed84|        
124|70d899|        let textView = EditorTextView(frame: .zero, textContainer: textContainer)
125|d6ed84|        
126|0a4844|        // Connect FoldingLayoutManager to EditorTextView
127|1b2fae|        foldingLayoutManager.ownerTextView = textView
128|d6ed84|        
129|658791|        textView.delegate = context.coordinator
130|eedd9e|        textView.editorCore = editorCore
131|d6ed84|        
132|460aec|        // Code folding support
133|8db9c1|        textView.foldingManager = CodeFoldingManager.shared
134|ac74b1|        textView.fileId = filename
135|adc83b|
136|230596|        // Autocomplete hooks
137|590cdf|        textView.onAcceptAutocomplete = onAcceptAutocomplete
138|f86509|        textView.onDismissAutocomplete = onDismissAutocomplete
139|adc83b|
140|bc9426|        textView.onPeekDefinition = {
141|28cdac|            context.coordinator.handlePeekDefinition(in: textView)
142|5f3077|        }
143|adc83b|
144|22544f|        textView.onEscape = {
145|2bbf54|            context.coordinator.handleEscape()
146|5f3077|        }
147|adc83b|
148|893a72|        textView.onGoToLine = {
149|00564f|            self.editorCore.showGoToLine = true
150|5f3077|        }




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: ea6e3a2199bd
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 151-400 of 2463)
────────────────────────────────────────
151|d6ed84|        
152|c5e254|        // Wire up custom context menu actions
153|308464|        textView.onGoToDefinition = {
154|6152d6|            context.coordinator.handleGoToDefinition(in: textView)
155|5f3077|        }
156|d6ed84|        
157|caf5f8|        textView.onFindReferences = {
158|3b41a6|            context.coordinator.handleFindReferences(in: textView)
159|5f3077|        }
160|d6ed84|        
161|193b69|        textView.onFormatDocument = {
162|60fc1e|            context.coordinator.handleFormatDocument(in: textView)
163|5f3077|        }
164|d6ed84|        
165|a5993d|        textView.onToggleComment = {
166|4750cb|            context.coordinator.handleToggleComment(in: textView)
167|5f3077|        }
168|d6ed84|        
169|6ae7f6|        textView.onFold = {
170|2acef9|            context.coordinator.handleFold(in: textView)
171|5f3077|        }
172|d6ed84|        
173|492f97|        textView.onUnfold = {
174|734b97|            context.coordinator.handleUnfold(in: textView)
175|5f3077|        }
176|d6ed84|        
177|090111|        // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
178|d11b6a|        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
179|8b1338|        pinchGesture.delegate = context.coordinator
180|92a15c|        textView.addGestureRecognizer(pinchGesture)
181|d6c725|        context.coordinator.pinchGesture = pinchGesture
182|d6ed84|        
183|f578ff|        // Configure text view
184|da0c96|        textView.isEditable = true
185|8e0a05|        textView.isSelectable = true
186|be8b25|        textView.autocapitalizationType = .none
187|9239ec|        textView.autocorrectionType = .no
188|8d5412|        textView.smartDashesType = .no
189|95e6b5|        textView.smartQuotesType = .no
190|046505|        textView.smartInsertDeleteType = .no
191|3ed52b|        textView.spellCheckingType = .no
192|d6ed84|        
193|74b0ec|        // Set font and appearance (use editorCore.editorFontSize)
194|65f2b4|        textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
195|f8148e|        textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
196|e5b95a|        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
197|0c4521|        textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
198|c43605|        textView.keyboardType = .default
199|948867|        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
200|d6ed84|        
201|ad2c45|        // Enable line wrapping
202|c631bd|        textView.textContainer.lineBreakMode = .byCharWrapping
203|0f2c1b|        textView.textContainer.widthTracksTextView = true
204|d6ed84|        
205|3c85db|        // Calculate line height
206|cfcf55|        if let font = textView.font {
207|ebb427|            DispatchQueue.main.async {
208|b0f625|                self.lineHeight = font.lineHeight
209|a7dc16|            }
210|5f3077|        }
211|d6ed84|        
212|7bfd13|        // Set initial text with syntax highlighting
213|34c68b|        textView.text = text
214|5f8c32|        context.coordinator.applySyntaxHighlighting(to: textView)
215|15fae3|        context.coordinator.updateLineCount(textView)
216|d6ed84|        
217|36e727|        return textView
218|27e597|    }
219|b4687f|    
220|7dcb1c|    func updateUIView(_ textView: UITextView, context: Context) {
221|855109|        // CRITICAL: Update coordinator's parent reference to current struct
222|333ede|        // SwiftUI creates new struct instances on each update, so this keeps
223|620e32|        // coordinator in sync with current bindings and properties
224|aa6fd6|        context.coordinator.parent = self
225|d6ed84|        
226|0a58ec|        // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
227|211a1a|        // This fixes the bug where syntax highlighting only appears after typing.
228|815fc1|        // makeUIView applies it, but the view may not be fully in hierarchy yet,
229|ab2ed7|        // causing the attributed text to be lost. This ensures it's applied reliably.
230|d721d6|        if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
231|140558|            context.coordinator.applySyntaxHighlighting(to: textView)
232|4dd2eb|            context.coordinator.hasAppliedInitialHighlighting = true
233|5f3077|        }
234|d6ed84|        
235|31e4e9|        // Update colors when theme changes
236|5ee36b|        // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor
237|d2a31c|        // as it interferes with attributedText syntax highlighting colors.
238|2ba8b3|        // The foreground color is handled entirely by the attributedText.
239|e5b95a|        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
240|0c4521|        textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
241|d6ed84|        
242|330f1a|        if let editorView = textView as? EditorTextView {
243|397219|            editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
244|5f3077|        }
245|d6ed84|        
246|c506e2|        // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
247|1e3b94|        if let currentFont = textView.font, currentFont.pointSize != fontSize {
248|e844dd|            let selectedRange = textView.selectedRange
249|441e85|            textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
250|140558|            context.coordinator.applySyntaxHighlighting(to: textView)
251|335b1a|            textView.selectedRange = selectedRange
252|3070d1|            
253|53ed35|            // Update line height
254|f4daab|            if let font = textView.font {
255|f143b8|                DispatchQueue.main.async {
256|6dfb70|                    self.lineHeight = font.lineHeight
257|4e2d32|                }
258|a7dc16|            }
259|5f3077|        }
260|d6ed84|        
261|d764b8|        // Update text if changed externally
262|c4b3de|        if textView.text != text {
263|e844dd|            let selectedRange = textView.selectedRange
264|bf1757|            textView.text = text
265|140558|            context.coordinator.applySyntaxHighlighting(to: textView)
266|4dd2eb|            context.coordinator.hasAppliedInitialHighlighting = true
267|335b1a|            textView.selectedRange = selectedRange
268|cbbdc8|        } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
269|921fd1|            // Re-apply highlighting if theme changed
270|140558|            context.coordinator.applySyntaxHighlighting(to: textView)
271|5f3077|        }
272|d6ed84|        
273|98290a|        // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
274|5fbd94|        // This prevents the editor from fighting against user scroll due to async binding lag
275|935237|        if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
276|7582fa|            // Update lastKnownScrollPosition FIRST to prevent race condition
277|2bbfef|            // where user scroll gets overridden by stale binding value
278|76f423|            context.coordinator.lastKnownScrollPosition = scrollPosition
279|8543a8|            context.coordinator.scrollToLine(scrollPosition, in: textView)
280|5f3077|        }
281|adc83b|
282|649b47|        // Handle line selection requests (e.g. tapping line numbers)
283|89e0a7|        if let requested = requestedLineSelection,
284|16d365|           requested != context.coordinator.lastRequestedLineSelection {
285|b908db|            context.coordinator.lastRequestedLineSelection = requested
286|161f74|            context.coordinator.scrollToAndSelectLine(requested, in: textView)
287|8b95ef|            // Defer @Binding update to avoid "Publishing changes from within view updates"
288|ebb427|            DispatchQueue.main.async {
289|2fa7d1|                self.requestedLineSelection = nil
290|a7dc16|            }
291|5f3077|        }
292|adc83b|
293|e31050|        // Handle cursor index requests (e.g. accepting autocomplete)
294|503648|        if let requested = requestedCursorIndex,
295|9a2334|           requested != context.coordinator.lastRequestedCursorIndex {
296|89b5a6|            context.coordinator.lastRequestedCursorIndex = requested
297|40dc8c|            // Use UTF-16 count for NSRange compatibility
298|6d09ca|            let textLength = (textView.text as NSString?)?.length ?? 0
299|97ec0c|            let safeIndex = max(0, min(requested, textLength))
300|f9ad9a|            textView.selectedRange = NSRange(location: safeIndex, length: 0)
301|3070d1|            
302|8bb335|            // Ensure cursor is visible by scrolling to it
303|021d90|            textView.scrollRangeToVisible(textView.selectedRange)
304|3070d1|            
305|8b95ef|            // Defer @Binding update to avoid "Publishing changes from within view updates"
306|ebb427|            DispatchQueue.main.async {
307|f083e4|                self.requestedCursorIndex = nil
308|a7dc16|            }
309|adc83b|
310|2d769a|            // Update SwiftUI state
311|5bf36b|            context.coordinator.updateCursorPosition(textView)
312|6e9f1e|            context.coordinator.updateScrollPosition(textView)
313|5f3077|        }
314|d6ed84|        
315|faca71|        // Note: updateLineCount is called in textViewDidChange, no need to call here
316|ea5565|        // as it causes unnecessary state churn on every updateUIView
317|27e597|    }
318|b4687f|    
319|b90e11|    // MARK: - Coordinator
320|b4687f|    
321|649280|    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
322|22c5f0|        var parent: SyntaxHighlightingTextView
323|e36ab9|        var lastKnownScrollPosition: Int = 0
324|df72ce|        var lastThemeId: String = ""
325|c3cdc9|        var lastRequestedLineSelection: Int? = nil
326|b2f8b4|        var lastRequestedCursorIndex: Int? = nil
327|3c00a1|        private var isUpdatingFromMinimap = false
328|1168d5|        private var highlightDebouncer: Timer?
329|a82d98|        weak var pinchGesture: UIPinchGestureRecognizer?
330|45a3a4|        private var initialFontSize: CGFloat = 0
331|d6ed84|        
332|caef19|        // Track user scroll to prevent programmatic scroll fighting back
333|46c4d2|        private var userScrollDebouncer: Timer?
334|f5a256|        var isUserScrolling = false
335|adc83b|
336|a7fc22|        // FEAT-044: Matching bracket highlight state
337|a1dd55|        private var bracketHighlightRanges: [NSRange] = []
338|d6ed84|        
339|4544cc|        // FEAT-NEW: Word occurrence highlight state
340|a15623|        private var wordOccurrenceRanges: [NSRange] = []
341|6b2a54|        private var wordOccurrenceDebouncer: Timer?
342|adc83b|
343|9e6885|        // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
344|315e1e|        var hasAppliedInitialHighlighting = false
345|d6ed84|        
346|f528ff|        // PERF: Track last line to avoid unnecessary redraws
347|2264dd|        private var lastKnownLineNumber: Int = -1
348|d6ed84|        
349|b00bf3|        // PERF: Debounce bracket matching to avoid O(n) scans on every cursor move
350|a975db|        private var bracketMatchDebouncer: Timer?
351|d6ed84|        
352|fbe659|        // PERFORMANCE: Large file highlighting optimization
353|d7ec6f|        // Files larger than this threshold get deferred full highlighting
354|ea195c|        private let largeFileThreshold = 10000  // 10k characters
355|95ed80|        private var largeFileHighlightDebouncer: Timer?
356|da2fb2|        // Track if we have pending full highlight (for large files)
357|33838e|        private var hasPendingFullHighlight = false
358|d6ed84|        
359|970a19|        init(_ parent: SyntaxHighlightingTextView) {
360|12d237|            self.parent = parent
361|5f3077|        }
362|d6ed84|        
363|78abb5|        // MARK: - UIGestureRecognizerDelegate
364|d6ed84|        
365|8efdab|        // Allow pinch gesture to work simultaneously with text selection gestures
366|852235|        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
367|9f0a50|            // Allow pinch to work alongside native text selection gestures
368|40cfc4|            return true
369|5f3077|        }
370|d6ed84|        
371|de2675|        func textViewDidBeginEditing(_ textView: UITextView) {
372|51937a|            // Ensure syntax highlighting is current when user begins editing
373|4a2c77|            // This handles cases where text was set but highlighting hasn't run yet
374|a5a065|            applySyntaxHighlighting(to: textView)
375|5f3077|        }
376|d6ed84|        
377|af38bb|        func textViewDidChange(_ textView: UITextView) {
378|dea5d1|            // Update parent text
379|f9041f|            parent.text = textView.text
380|3070d1|            
381|0cad3b|            // Set typing attributes IMMEDIATELY so new characters have proper base styling
382|b1b789|            // This prevents flicker during the debounce period
383|6035ba|            let theme = ThemeManager.shared.currentTheme
384|810685|            let fontSize = parent.editorCore.editorFontSize
385|426131|            textView.typingAttributes = [
386|69640c|                .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
387|247992|                .foregroundColor: UIColor(theme.editorForeground)
388|324820|            ]
389|3070d1|            
390|d2871c|            // PERFORMANCE FIX: Aggressive debounce strategy based on document size
391|57483c|            // For large files, syntax highlighting is EXTREMELY expensive and causes lag
392|066049|            let textLength = textView.text.count
393|3070d1|            
394|f58561|            // Large file threshold - above this, skip highlighting during active typing entirely
395|dc34b3|            let largeFileThreshold = 10000
396|ce686a|            // Very large file threshold - above this, use extended delay
397|99a6b3|            let veryLargeFileThreshold = 50000
398|3070d1|            
399|2c90fc|            highlightDebouncer?.invalidate()
400|3070d1|            




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: ea6e3a2199bd
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1801-2100 of 2463)
────────────────────────────────────────
1801|ba56a1|        case "env": return .env
1802|adc83b|
1803|02ed06|        default: return .plainText
1804|5f3077|        }
1805|27e597|    }
1806|b4687f|    
1807|114d31|    private func highlight(_ text: String, language: SyntaxLanguage) -> NSAttributedString {
1808|04be19|        let attributed = NSMutableAttributedString(string: text)
1809|576a7a|        let fullRange = NSRange(location: 0, length: text.utf16.count)
1810|d6ed84|        
1811|9e8c8d|        // Base attributes
1812|b792d5|        let baseFont = UIFont.monospacedSystemFont(ofSize: baseFontSize, weight: .regular)
1813|28d4d0|        attributed.addAttribute(.font, value: baseFont, range: fullRange)
1814|8f20b4|        attributed.addAttribute(.foregroundColor, value: UIColor(theme.editorForeground), range: fullRange)
1815|d6ed84|        
1816|d0998b|        // Apply language-specific highlighting
1817|f3155b|        switch language {
1818|a8ecf9|        case .swift: highlightSwift(attributed, text: text)
1819|66c2b6|        case .javascript, .jsx: highlightJavaScript(attributed, text: text, isTS: false)
1820|f878d3|        case .typescript, .tsx: highlightJavaScript(attributed, text: text, isTS: true)
1821|bf5ad7|        case .python: highlightPython(attributed, text: text)
1822|694371|        case .html, .xml: highlightHTML(attributed, text: text)
1823|d59b9e|        case .css, .scss, .less: highlightCSS(attributed, text: text)
1824|fef33c|        case .json: highlightJSON(attributed, text: text)
1825|d045a0|        case .markdown: highlightMarkdown(attributed, text: text)
1826|3d7ac9|        case .rust: highlightRust(attributed, text: text)
1827|22c786|        case .go: highlightGo(attributed, text: text)
1828|aa1226|        case .java, .kotlin: highlightJava(attributed, text: text)
1829|7161a2|        case .c, .cpp, .objectiveC: highlightCpp(attributed, text: text)
1830|15fa67|        case .ruby: highlightRuby(attributed, text: text)
1831|b2c03c|        case .php: highlightPHP(attributed, text: text)
1832|2e2d06|        case .shell, .dockerfile: highlightShell(attributed, text: text)
1833|6fb34b|        case .yaml, .env: highlightYAML(attributed, text: text)
1834|545180|        case .sql: highlightSQL(attributed, text: text)
1835|a51785|        case .graphql: highlightGraphQL(attributed, text: text)
1836|4fdf68|        case .plainText: break
1837|5f3077|        }
1838|d6ed84|        
1839|ad27ec|        // FEAT-038: Bracket Pair Colorization (applied last)
1840|f1e24b|        highlightBracketPairs(attributed, text: text)
1841|d6ed84|        
1842|c4a88d|        return attributed
1843|27e597|    }
1844|b4687f|    
1845|43cc7c|    // MARK: - Bracket Pair Colorization
1846|b4687f|    
1847|6375f9|    private func highlightBracketPairs(_ attributed: NSMutableAttributedString, text: String) {
1848|15e10d|        let brackets: [Character] = ["{", "}", "[", "]", "(", ")"]
1849|d14333|        let pairs: [Character: Character] = ["}": "{", "]": "[", ")": "("]
1850|d6ed84|        
1851|99a4a9|        var stack: [(char: Character, index: Int, depth: Int)] = []
1852|6e4cea|        let colors = [
1853|20317f|            UIColor(theme.bracketPair1),
1854|5f8621|            UIColor(theme.bracketPair2),
1855|4c6756|            UIColor(theme.bracketPair3),
1856|5eabae|            UIColor(theme.bracketPair4),
1857|f54b47|            UIColor(theme.bracketPair5),
1858|930dd3|            UIColor(theme.bracketPair6)
1859|220505|        ]
1860|d6ed84|        
1861|44166e|        // Scan text for brackets
1862|439013|        // Note: In a real implementation, we should skip brackets inside strings/comments
1863|2bdb67|        // But since we apply this LAST, we can try to respect existing string/comment colors
1864|f89202|        // OR implement a more robust parser. For now, simple scan.
1865|d6ed84|        
1866|8945b5|        // Optimization: Use scanner or direct iteration
1867|4fc7f4|        let nsString = text as NSString
1868|9203e3|        var index = 0
1869|d6ed84|        
1870|810ca8|        while index < text.utf16.count {
1871|4f9ad4|            let char = nsString.character(at: index)
1872|7e8ad3|            if let scalar = UnicodeScalar(char) {
1873|e4a370|                let c = Character(scalar)
1874|216278|                
1875|cbd2a8|                if brackets.contains(c) {
1876|1b3670|                    // Check if it's already colored as string/comment (heuristic)
1877|149e03|                    // If color is string/comment, skip
1878|850f04|                    // (Requires iterating attributes, which is slow. We'll just apply on top for now)
1879|dd2193|                    
1880|996925|                    if let open = pairs[c] { // Closing bracket
1881|6114f3|                        if let last = stack.last, last.char == open {
1882|1469ee|                            // Match found
1883|28d302|                            let depth = last.depth
1884|4ca6c1|                            let color = colors[depth % colors.count]
1885|e4abf2|                            
1886|c40423|                            attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1887|9f0f64|                            attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: last.index, length: 1))
1888|e4abf2|                            
1889|fd0ca5|                            stack.removeLast()
1890|65e2f4|                        } else {
1891|79dbca|                            // Mismatched or extra closing bracket - unexpected
1892|b93d0a|                            // Keep default color or mark red? Default for now.
1893|392b35|                        }
1894|3a0c6a|                    } else { // Opening bracket
1895|0232e2|                        let depth = stack.count
1896|802404|                        stack.append((c, index, depth))
1897|956cfe|                        
1898|6eedf4|                        // We'll color it when (and if) we find the match, or here?
1899|74f3b7|                        // Better to color here tentatively, but matching is better.
1900|66092b|                        // Let's color tentatively based on depth.
1901|f150d9|                        let color = colors[depth % colors.count]
1902|65df06|                        attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
1903|c9717a|                    }
1904|4e2d32|                }
1905|a7dc16|            }
1906|fe2650|            index += 1
1907|5f3077|        }
1908|27e597|    }
1909|b4687f|    
1910|f72eeb|    // MARK: - Swift Highlighting
1911|b4687f|    
1912|b466ff|    private func highlightSwift(_ attributed: NSMutableAttributedString, text: String) {
1913|23ae10|        // Keywords (purple/pink)
1914|e7ca91|        let keywords = ["func", "var", "let", "if", "else", "for", "while", "return",
1915|25406e|                       "class", "struct", "enum", "protocol", "extension", "import",
1916|241b78|                       "private", "public", "internal", "fileprivate", "open",
1917|156502|                       "static", "final", "override", "mutating", "nonmutating",
1918|4afb42|                       "init", "deinit", "subscript", "typealias", "associatedtype",
1919|79a787|                       "where", "throws", "rethrows", "async", "await", "actor",
1920|113cf5|                       "guard", "defer", "do", "try", "catch", "throw",
1921|3202d2|                       "switch", "case", "default", "break", "continue", "fallthrough",
1922|8597f3|                       "in", "is", "as", "inout", "some", "any", "Self",
1923|9662c4|                       "get", "set", "willSet", "didSet", "lazy", "weak", "unowned",
1924|e004f8|                       "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject",
1925|f47110|                       "@Environment", "@EnvironmentObject", "@ViewBuilder", "@MainActor",
1926|5afcac|                       "@escaping", "@autoclosure", "@available", "@objc", "@discardableResult"]
1927|8e884c|        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1928|d6ed84|        
1929|73faee|        // Types (teal) - CamelCase words that aren't keywords
1930|415d1e|        let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1931|340684|        highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1932|d6ed84|        
1933|7cde80|        // Function calls (yellow)
1934|796fb0|        let funcCallPattern = "\\b([a-z][a-zA-Z0-9]*)\\s*\\("
1935|88051b|        highlightPattern(attributed, pattern: funcCallPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1936|d6ed84|        
1937|f5ac60|        // Constants (blue)
1938|1b0337|        let constants = ["true", "false", "nil", "self", "super"]
1939|a27578|        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1940|d6ed84|        
1941|942e13|        // Comments MUST come late (green) - they override everything
1942|1bf0ae|        highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1943|d6ed84|        
1944|f7e9a9|        // Strings AFTER comments (orange)
1945|f626a6|        highlightStrings(attributed, text: text)
1946|d6ed84|        
1947|e70b07|        // Numbers (light green)
1948|c10ee6|        highlightNumbers(attributed, text: text)
1949|27e597|    }
1950|b4687f|    
1951|bda46f|    // MARK: - JavaScript/TypeScript Highlighting
1952|b4687f|    
1953|f40f77|    private func highlightJavaScript(_ attributed: NSMutableAttributedString, text: String, isTS: Bool) {
1954|51d1a7|        var keywords = ["function", "var", "let", "const", "if", "else", "for", "while",
1955|397114|                       "return", "class", "extends", "new", "this", "super", "import",
1956|c59c23|                       "export", "default", "from", "as", "async", "await", "yield",
1957|07a5cf|                       "try", "catch", "finally", "throw", "typeof", "instanceof",
1958|1a9b41|                       "switch", "case", "break", "continue", "do", "in", "of",
1959|70802f|                       "get", "set", "static", "constructor", "delete", "void",
1960|a550d2|                       "with", "debugger"]
1961|d6ed84|        
1962|10a085|        if isTS {
1963|1c14db|            keywords += ["interface", "type", "enum", "namespace", "module", "declare",
1964|643270|                        "implements", "public", "private", "protected", "readonly",
1965|292fa8|                        "abstract", "override", "keyof", "infer", "never", "unknown",
1966|19dba5|                        "any", "asserts", "is"]
1967|5f3077|        }
1968|d6ed84|        
1969|8e884c|        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1970|d6ed84|        
1971|e330b9|        // Constants
1972|2e52aa|        let constants = ["true", "false", "null", "undefined", "NaN", "Infinity"]
1973|a27578|        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
1974|d6ed84|        
1975|7f377a|        // Function names (yellow) - regular calls + arrow functions
1976|a4e532|        let funcNamePattern = "\\b([a-zA-Z_$][a-zA-Z0-9_$]*)\\b(?=\\s*(?:\\(|=>))"
1977|6e412a|        highlightPattern(attributed, pattern: funcNamePattern, color: UIColor(theme.function), text: text, captureGroup: 1)
1978|d6ed84|        
1979|5bdd97|        // Types (teal)
1980|415d1e|        let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
1981|340684|        highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
1982|d6ed84|        
1983|1bf0ae|        highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
1984|f626a6|        highlightStrings(attributed, text: text)
1985|e3ea99|        highlightJSTemplateLiterals(attributed, text: text)
1986|c10ee6|        highlightNumbers(attributed, text: text)
1987|27e597|    }
1988|b4687f|    
1989|f54c79|    // MARK: - Python Highlighting
1990|b4687f|    
1991|ba6ff9|    private func highlightPython(_ attributed: NSMutableAttributedString, text: String) {
1992|a8a2bf|        let keywords = ["def", "class", "if", "elif", "else", "for", "while", "return",
1993|22d22d|                       "import", "from", "as", "try", "except", "finally", "raise",
1994|23f5bf|                       "with", "assert", "yield", "lambda", "pass", "break", "continue",
1995|a87046|                       "global", "nonlocal", "del", "in", "not", "and", "or", "is",
1996|70b13f|                       "async", "await", "match", "case"]
1997|8e884c|        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
1998|d6ed84|        
1999|37079c|        let constants = ["True", "False", "None", "self", "cls"]
2000|a27578|        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
2001|d6ed84|        
2002|731c6d|        // Decorators (yellow)
2003|a74274|        let decoratorPattern = "@[a-zA-Z_][a-zA-Z0-9_\\.]*"
2004|44e26a|        highlightPattern(attributed, pattern: decoratorPattern, color: UIColor(theme.function), text: text)
2005|d6ed84|        
2006|975dbf|        // Function definitions (yellow)
2007|9f7624|        let funcDefPattern = "(?<=def\\s)[a-zA-Z_][a-zA-Z0-9_]*"
2008|a18a2a|        highlightPattern(attributed, pattern: funcDefPattern, color: UIColor(theme.function), text: text)
2009|d6ed84|        
2010|321368|        // Class names (teal)
2011|cfc89a|        let classPattern = "(?<=class\\s)[a-zA-Z_][a-zA-Z0-9_]*"
2012|b90aaa|        highlightPattern(attributed, pattern: classPattern, color: UIColor(theme.type), text: text)
2013|d6ed84|        
2014|6addb2|        // Built-in functions (yellow)
2015|61b003|        let builtins = ["print", "len", "range", "str", "int", "float", "list", "dict", "set",
2016|dcec99|                       "tuple", "bool", "type", "isinstance", "hasattr", "getattr", "setattr",
2017|4ec57e|                       "open", "input", "map", "filter", "reduce", "zip", "enumerate",
2018|0de69c|                       "sorted", "reversed", "min", "max", "sum", "abs", "round",
2019|9a35b7|                       "super", "object", "Exception", "ValueError", "TypeError"]
2020|4fe882|        highlightKeywords(attributed, keywords: builtins, color: UIColor(theme.function), text: text)
2021|d6ed84|        
2022|8febe2|        highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
2023|100fab|        highlightPythonStrings(attributed, text: text)
2024|c10ee6|        highlightNumbers(attributed, text: text)
2025|27e597|    }
2026|b4687f|    
2027|03a312|    // MARK: - HTML Highlighting
2028|b4687f|    
2029|8cf7bd|    private func highlightHTML(_ attributed: NSMutableAttributedString, text: String) {
2030|e71bb7|        // Tags (blue)
2031|073905|        let tagPattern = "</?\\s*([a-zA-Z][a-zA-Z0-9-]*)(?=[\\s>])"
2032|885267|        highlightPattern(attributed, pattern: tagPattern, color: UIColor(theme.keyword), text: text)
2033|d6ed84|        
2034|4b02ec|        // Attributes (light blue)
2035|fe4f95|        let attrPattern = "\\s([a-zA-Z][a-zA-Z0-9-]*)\\s*="
2036|f359c0|        highlightPattern(attributed, pattern: attrPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
2037|d6ed84|        
2038|a35cf8|        // Angle brackets
2039|edb272|        let bracketPattern = "[<>/?]"
2040|1250f4|        highlightPattern(attributed, pattern: bracketPattern, color: UIColor.gray, text: text)
2041|d6ed84|        
2042|185d89|        // Comments
2043|1552bf|        highlightHTMLComments(attributed, text: text)
2044|d6ed84|        
2045|fb886c|        // Strings
2046|f626a6|        highlightStrings(attributed, text: text)
2047|27e597|    }
2048|b4687f|    
2049|7450dd|    // MARK: - CSS Highlighting
2050|b4687f|    
2051|6b922a|    private func highlightCSS(_ attributed: NSMutableAttributedString, text: String) {
2052|f68113|        // Selectors (yellow)
2053|1a4eae|        let selectorPattern = "([.#]?[a-zA-Z][a-zA-Z0-9_-]*)\\s*\\{"
2054|1c98d3|        highlightPattern(attributed, pattern: selectorPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
2055|d6ed84|        
2056|707db2|        // Properties (light blue)
2057|8b5b3a|        let propertyPattern = "([a-zA-Z-]+)\\s*:"
2058|11d30d|        highlightPattern(attributed, pattern: propertyPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
2059|d6ed84|        
2060|54322e|        // Values with units
2061|2fa2d8|        let unitPattern = "\\b(\\d+)(px|em|rem|%|vh|vw|pt|cm|mm|in)\\b"
2062|f49c65|        highlightPattern(attributed, pattern: unitPattern, color: UIColor(theme.number), text: text)
2063|d6ed84|        
2064|9b0384|        // Colors
2065|d017d8|        let hexPattern = "#[0-9a-fA-F]{3,8}\\b"
2066|40dee7|        highlightPattern(attributed, pattern: hexPattern, color: UIColor(theme.number), text: text)
2067|d6ed84|        
2068|5f2431|        // Keywords
2069|058bc2|        let keywords = ["important", "inherit", "initial", "unset", "none", "auto",
2070|36fc17|                       "block", "inline", "flex", "grid", "absolute", "relative", "fixed"]
2071|8e884c|        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
2072|d6ed84|        
2073|74d198|        highlightComments(attributed, text: text, singleLine: nil, multiLineStart: "/*", multiLineEnd: "*/")
2074|f626a6|        highlightStrings(attributed, text: text)
2075|c10ee6|        highlightNumbers(attributed, text: text)
2076|27e597|    }
2077|b4687f|    
2078|39212e|    // MARK: - JSON Highlighting
2079|b4687f|    
2080|f8c440|    private func highlightJSON(_ attributed: NSMutableAttributedString, text: String) {
2081|ff222f|        // Keys (light blue)
2082|ed3db3|        let keyPattern = "\"([^\"]+)\"\\s*:"
2083|49d969|        highlightPattern(attributed, pattern: keyPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
2084|d6ed84|        
2085|696a8d|        // String values (orange)
2086|f626a6|        highlightStrings(attributed, text: text)
2087|d6ed84|        
2088|e70b07|        // Numbers (light green)
2089|c10ee6|        highlightNumbers(attributed, text: text)
2090|d6ed84|        
2091|4b27cf|        // Booleans and null (use keyword color)
2092|617367|        let constants = ["true", "false", "null"]
2093|a19117|        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.keyword), text: text)
2094|27e597|    }
2095|b4687f|    
2096|03c143|    // MARK: - Markdown Highlighting
2097|b4687f|    
2098|11216d|    private func highlightMarkdown(_ attributed: NSMutableAttributedString, text: String) {
2099|633273|        // Headers (blue + bold)
2100|248e20|        let headerPattern = "^#{1,6}\\s+.+$"




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 9fea23a8b787
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 2-200 of 906)
────────────────────────────────────────
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




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 9fea23a8b787
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 201-400 of 906)
────────────────────────────────────────
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


Now I need to check for other places that might register keyboard shortcuts. Let me search for more.



---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 9fea23a8b787
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 131-200 of 906)
────────────────────────────────────────
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


Now let me check if there's an EditorTextView class that also registers keyboard commands:



---

## 🔧 TOOL RESULTS

[read_file]
snapshot: ea6e3a2199bd
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1001-1300 of 2463)
────────────────────────────────────────
1001|8dcb2c|                    break
1002|4e2d32|                }
1003|a7dc16|            }
1004|adc83b|
1005|bad712|            guard let idx = bracketIndex else { return }
1006|adc83b|
1007|6ef39d|            // Define bracket pairs
1008|ffef8e|            let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
1009|844dfd|            let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [
1010|adc83b|
1011|6035ba|            let theme = ThemeManager.shared.currentTheme
1012|dd2745|            let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)
1013|adc83b|
1014|815cc6|            var matchIndex: Int?
1015|adc83b|
1016|da9072|            if let close = openToClose[bracketChar] {
1017|ddb7dc|                // Opening bracket: scan forward
1018|f4b22a|                var depth = 0
1019|726798|                var i = idx + 1
1020|56d843|                while i < length {
1021|a5da50|                    let c = nsText.character(at: i)
1022|e59961|                    if c == bracketChar {
1023|4e6205|                        depth += 1
1024|97f2eb|                    } else if c == close {
1025|eb85cd|                        if depth == 0 {
1026|9fafa2|                            matchIndex = i
1027|331d25|                            break
1028|65e2f4|                        } else {
1029|58feb2|                            depth -= 1
1030|392b35|                        }
1031|c9717a|                    }
1032|358711|                    i += 1
1033|4e2d32|                }
1034|810627|            } else if let open = closeToOpen[bracketChar] {
1035|329192|                // Closing bracket: scan backward
1036|f4b22a|                var depth = 0
1037|41bc7e|                var i = idx - 1
1038|b2cae7|                while i >= 0 {
1039|a5da50|                    let c = nsText.character(at: i)
1040|e59961|                    if c == bracketChar {
1041|4e6205|                        depth += 1
1042|692236|                    } else if c == open {
1043|eb85cd|                        if depth == 0 {
1044|9fafa2|                            matchIndex = i
1045|331d25|                            break
1046|65e2f4|                        } else {
1047|58feb2|                            depth -= 1
1048|392b35|                        }
1049|c9717a|                    }
1050|74be9d|                    i -= 1
1051|4e2d32|                }
1052|a7dc16|            }
1053|adc83b|
1054|f3e771|            guard let match = matchIndex else { return }
1055|adc83b|
1056|97cd09|            let r1 = NSRange(location: idx, length: 1)
1057|c663d6|            let r2 = NSRange(location: match, length: 1)
1058|adc83b|
1059|781302|            textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
1060|6a63d9|            textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)
1061|adc83b|
1062|5188de|            textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
1063|fb51a0|            textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)
1064|adc83b|
1065|28b1a1|            bracketHighlightRanges = [r1, r2]
1066|5f3077|        }
1067|d6ed84|        
1068|df2a90|        // MARK: - FEAT-NEW Word Occurrence Highlighting
1069|d6ed84|        
1070|5cf65b|        private func updateWordOccurrenceHighlights(_ textView: UITextView) {
1071|cbd2ad|            // Clear existing highlights
1072|249f56|            if !wordOccurrenceRanges.isEmpty {
1073|c4ef14|                for r in wordOccurrenceRanges {
1074|fc4278|                    textView.textStorage.removeAttribute(.backgroundColor, range: r)
1075|4e2d32|                }
1076|8a66d0|                wordOccurrenceRanges.removeAll()
1077|a7dc16|            }
1078|3070d1|            
1079|a5bb65|            let selection = textView.selectedRange
1080|b3d375|            let text = textView.text ?? ""
1081|3070d1|            
1082|e88a70|            // Only highlight when there's a selection (word selected)
1083|e3e49b|            guard selection.length > 0 else { return }
1084|3070d1|            
1085|4d2541|            // Get occurrences
1086|b477a5|            let occurrences = WordOccurrenceHighlighter.shared.findOccurrences(in: text, selection: selection)
1087|3070d1|            
1088|c2b3b8|            // Need at least 2 occurrences (including the selected one) to show highlights
1089|b28715|            guard occurrences.count >= 2 else { return }
1090|3070d1|            
1091|6035ba|            let theme = ThemeManager.shared.currentTheme
1092|1cf7af|            let highlightColor = WordOccurrenceHighlighter.highlightColor(for: theme)
1093|3070d1|            
1094|bf8605|            // Apply highlights to all occurrences EXCEPT the current selection
1095|f25c3b|            for occurrence in occurrences {
1096|509884|                // Skip the currently selected occurrence
1097|2e9f1b|                if occurrence.range.location == selection.location && occurrence.range.length == selection.length {
1098|f41bef|                    continue
1099|4e2d32|                }
1100|216278|                
1101|8fcb2f|                textView.textStorage.addAttribute(.backgroundColor, value: highlightColor, range: occurrence.range)
1102|2e5540|                wordOccurrenceRanges.append(occurrence.range)
1103|a7dc16|            }
1104|5f3077|        }
1105|27e597|    }
1106|adc83b|
1107|b31277|}
1108|adc83b|
1109|918e07|// MARK: - FoldingLayoutManager
1110|d694db|/// TextKit layout manager that collapses line fragments for lines marked folded in CodeFoldingManager.
1111|a841a1|/// This is a view-level folding implementation (it does NOT modify the underlying text).
1112|bc1fac|final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
1113|41027e|    weak var ownerTextView: EditorTextView?
1114|adc83b|
1115|b3c6ad|    override init() {
1116|15cfe8|        super.init()
1117|95d040|        self.delegate = self
1118|27e597|    }
1119|adc83b|
1120|7ca09a|    required init?(coder: NSCoder) {
1121|68dada|        super.init(coder: coder)
1122|95d040|        self.delegate = self
1123|27e597|    }
1124|adc83b|
1125|efe359|    func layoutManager(
1126|809adb|        _ layoutManager: NSLayoutManager,
1127|1c55e7|        shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<CGRect>,
1128|98c806|        lineFragmentUsedRect: UnsafeMutablePointer<CGRect>,
1129|bc48e6|        baselineOffset: UnsafeMutablePointer<CGFloat>,
1130|fcdc4d|        in textContainer: NSTextContainer,
1131|1874c5|        forGlyphRange glyphRange: NSRange
1132|54d8bb|    ) -> Bool {
1133|04c681|        guard let owner = ownerTextView,
1134|059837|              let foldingManager = owner.foldingManager,
1135|e73db4|              let fileId = owner.fileId
1136|4ebc7a|        else {
1137|e2e187|            return false
1138|5f3077|        }
1139|adc83b|
1140|9de2dc|        // Convert glyphRange -> characterRange so we can compute the line index.
1141|9471e8|        let charRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
1142|e786e2|        let loc = max(0, charRange.location)
1143|adc83b|
1144|b1964a|        let full = (self.textStorage?.string ?? "") as NSString
1145|ca159a|        let lineIndex = FoldingLayoutManager.lineIndex(atUTF16Location: loc, in: full)
1146|adc83b|
1147|7b763c|        if foldingManager.isLineFolded(fileId: fileId, line: lineIndex) {
1148|2e29aa|            // Collapse this visual line fragment.
1149|52dd91|            lineFragmentRect.pointee.size.height = 0
1150|3edd23|            lineFragmentUsedRect.pointee.size.height = 0
1151|eaeafe|            baselineOffset.pointee = 0
1152|40cfc4|            return true
1153|5f3077|        }
1154|adc83b|
1155|dc1500|        return false
1156|27e597|    }
1157|adc83b|
1158|8aab29|    private static func lineIndex(atUTF16Location loc: Int, in text: NSString) -> Int {
1159|470ca2|        if loc <= 0 { return 0 }
1160|adc83b|
1161|cdd09d|        let capped = min(loc, text.length)
1162|d609cf|        var line = 0
1163|d0a79c|        var searchStart = 0
1164|adc83b|
1165|bbb957|        while searchStart < capped {
1166|fc657a|            let r = text.range(of: "\n", options: [], range: NSRange(location: searchStart, length: capped - searchStart))
1167|d8b23a|            if r.location == NSNotFound { break }
1168|e2b919|            line += 1
1169|dae32a|            let next = r.location + 1
1170|af699d|            if next >= capped { break }
1171|317174|            searchStart = next
1172|5f3077|        }
1173|adc83b|
1174|bf9a21|        return line
1175|27e597|    }
1176|b31277|}
1177|adc83b|
1178|a127b1|// Custom text view to handle key commands, indent guides, and line highlighting
1179|18bca5|class EditorTextView: MultiCursorTextView {
1180|acd1a2|    var onPeekDefinition: (() -> Void)?
1181|ef0a79|    var onEscape: (() -> Void)?
1182|22fb3d|    var onGoToLine: (() -> Void)?
1183|b4687f|    
1184|0f5f3c|    // Custom action closures for context menu
1185|4c15cf|    var onGoToDefinition: (() -> Void)?
1186|5447b2|    var onFindReferences: (() -> Void)?
1187|b72303|    var onFormatDocument: (() -> Void)?
1188|2979b6|    var onToggleComment: (() -> Void)?
1189|80603a|    var onFold: (() -> Void)?
1190|0b7785|    var onUnfold: (() -> Void)?
1191|adc83b|
1192|d75d7a|    // Autocomplete key handling hooks are inherited from MultiCursorTextView
1193|b4687f|    
1194|0083cf|    // Code folding support - required by FoldingLayoutManager
1195|162913|    weak var foldingManager: CodeFoldingManager?
1196|8c3523|    var fileId: String?
1197|b4687f|    
1198|a9b0bc|    // FEAT-039 & FEAT-043
1199|9ee960|    private var indentGuideColor: UIColor = .separator
1200|05be8a|    private var activeIndentGuideColor: UIColor = .label
1201|b1d04a|    private var currentLineHighlightColor: UIColor = .clear
1202|adc83b|
1203|962413|    // PERF: Cached values to avoid recalculating on every draw()
1204|7c8890|    private var cachedTabSize: Int = 4
1205|f4b8fb|    private var cachedSpaceWidth: CGFloat = 0
1206|d80209|    private var cachedIndentWidth: CGFloat = 0
1207|5701f5|    private var lastCachedFont: UIFont?
1208|b4687f|    
1209|499ec8|    override init(frame: CGRect, textContainer: NSTextContainer?) {
1210|634221|        super.init(frame: frame, textContainer: textContainer)
1211|060ac2|        setup()
1212|27e597|    }
1213|b4687f|    
1214|7ca09a|    required init?(coder: NSCoder) {
1215|68dada|        super.init(coder: coder)
1216|060ac2|        setup()
1217|27e597|    }
1218|b4687f|    
1219|d96c9e|    private func setup() {
1220|33a06f|        // Ensure we redraw when bounds/selection change
1221|d5b778|        contentMode = .redraw
1222|a1b6f8|        updateCachedMeasurements()
1223|27e597|    }
1224|b4687f|    
1225|c9b21a|    /// PERF: Update cached measurements - call when font changes
1226|8fc774|    func updateCachedMeasurements() {
1227|f0afaf|        let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
1228|74cd4b|        cachedTabSize = storedTabSize > 0 ? storedTabSize : 4
1229|d6ed84|        
1230|c3b9c1|        if let font = self.font, font != lastCachedFont {
1231|b5607b|            cachedSpaceWidth = " ".size(withAttributes: [.font: font]).width
1232|e153ec|            cachedIndentWidth = cachedSpaceWidth * CGFloat(cachedTabSize)
1233|e4afb8|            lastCachedFont = font
1234|5f3077|        }
1235|27e597|    }
1236|b4687f|    
1237|dbd59f|    func updateThemeColors(theme: Theme) {
1238|76e4f1|        self.indentGuideColor = UIColor(theme.indentGuide)
1239|d8e2fd|        self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
1240|b5a371|        self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
1241|795ff7|        setNeedsDisplay()
1242|27e597|    }
1243|b4687f|    
1244|d2b333|    override func draw(_ rect: CGRect) {
1245|639754|        guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
1246|4a5554|            super.draw(rect)
1247|bef5d6|            return
1248|5f3077|        }
1249|d6ed84|        
1250|415bc0|        // 1. Draw Current Line Highlight (FEAT-043)
1251|74adf6|        if let selectedRange = selectedTextRange {
1252|7fa241|            // Get the line rect for the cursor position
1253|932ab1|            let caretRect = self.caretRect(for: selectedRange.start)
1254|e06ba0|            let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
1255|3070d1|            
1256|aa054f|            context.setFillColor(currentLineHighlightColor.cgColor)
1257|1dd6e0|            context.fill(lineRect)
1258|5f3077|        }
1259|adc83b|
1260|f3c903|        // 2. Draw Text (super implementation)
1261|3d66d7|        super.draw(rect)
1262|d6ed84|        
1263|d6aec6|        // 3. Draw Indent Guides (FEAT-039)
1264|3ab75e|        // We iterate visible lines and draw vertical lines for indentation
1265|681431|        // Optimization: Only draw for visible range
1266|adc83b|
1267|1d7f57|        context.setLineWidth(1.0)
1268|adc83b|
1269|e80b61|        // PERF: Use cached values instead of recalculating on every draw
1270|941b29|        // Update cache if font changed
1271|a631b4|        if font != lastCachedFont {
1272|307569|            updateCachedMeasurements()
1273|5f3077|        }
1274|311946|        let tabSize = cachedTabSize
1275|20f068|        let indentWidth = cachedIndentWidth
1276|adc83b|
1277|863314|        // Determine active indent level for caret line (for indentGuideActive)
1278|07bc5e|        var activeIndentLevel: Int = 0
1279|61a19e|        if let selected = selectedTextRange {
1280|1cab60|            let caretPos = offset(from: beginningOfDocument, to: selected.start)
1281|cf79dd|            let nsText = (self.text ?? "") as NSString
1282|fd77d0|            let safeLoc = min(max(0, caretPos), nsText.length)
1283|470b22|            let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
1284|6cfe35|            let caretLineText = nsText.substring(with: caretLineRange)
1285|adc83b|
1286|df7672|            var spaces = 0
1287|4d29bc|            for ch in caretLineText {
1288|af773c|                if ch == " " { spaces += 1 }
1289|7653c8|                else if ch == "\t" { spaces += tabSize }
1290|901b7b|                else { break }
1291|a7dc16|            }
1292|1af420|            activeIndentLevel = spaces / tabSize
1293|5f3077|        }
1294|adc83b|
1295|1e4e8b|        // Iterate visible glyphs/lines
1296|c3abeb|        let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
1297|0c80d7|        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
1298|adc83b|
1299|136432|        let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }
1300|adc83b|


Let me search for keyCommands in the EditorTextView:



---

## 🔧 TOOL RESULTS

[read_file]
snapshot: ea6e3a2199bd
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/SyntaxHighlightingTextView.swift (lines 1301-1600 of 2463)
────────────────────────────────────────
1301|94624b|        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
1302|d986b7|            // Get text for this line
1303|20a100|            guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
1304|a2180e|                  let text = self.text as NSString? else { return }
1305|adc83b|
1306|68b6de|            let lineText = text.substring(with: range)
1307|adc83b|
1308|f06157|            // Calculate indentation level
1309|df7672|            var spaces = 0
1310|f682c2|            for char in lineText {
1311|7263e1|                if char == " " { spaces += 1 }
1312|fda1ac|                else if char == "\t" { spaces += tabSize } // Handle tabs if present
1313|901b7b|                else { break }
1314|a7dc16|            }
1315|adc83b|
1316|102b14|            let indentLevel = spaces / tabSize
1317|bca2b5|            guard indentLevel > 0 else { return }
1318|adc83b|
1319|a6ba69|            let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5
1320|adc83b|
1321|b7ae78|            for i in 1...indentLevel {
1322|b2f2f5|                let x = CGFloat(i) * indentWidth + self.textContainerInset.left
1323|1e6263|                let startPoint = CGPoint(x: x, y: rect.minY)
1324|89a6f8|                let endPoint = CGPoint(x: x, y: rect.maxY)
1325|adc83b|
1326|ca7c17|                let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
1327|f814c1|                context.setStrokeColor(stroke.cgColor)
1328|adc83b|
1329|8432ac|                context.move(to: startPoint)
1330|0ba2ff|                context.addLine(to: endPoint)
1331|54f669|                context.strokePath()
1332|a7dc16|            }
1333|5f3077|        }
1334|27e597|    }
1335|b4687f|    
1336|7c24d6|    override var keyCommands: [UIKeyCommand]? {
1337|4440e3|        // NOTE: Only define text-editing specific shortcuts here.
1338|965c4e|        // App-level shortcuts (Cmd+B, Cmd+P, Cmd+N, Cmd+S, Cmd+W, Cmd+F, etc.)
1339|116db9|        // are defined in the Menus/ folder via SwiftUI's .keyboardShortcut().
1340|186d9b|        // See: KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
1341|d144e6|        // Defining them here AND in Menus/ causes duplicate conflicts.
1342|d6ed84|        
1343|17c9a0|        var commands = super.keyCommands ?? []
1344|d6ed84|        
1345|ac19c5|        // Peek Definition: Option+D (editor-specific, not in menus)
1346|7020ca|        commands.append(UIKeyCommand(
1347|d361df|            input: "d",
1348|722957|            modifierFlags: .alternate,
1349|f8e7a8|            action: #selector(handlePeekDefinition)
1350|813e75|        ))
1351|adc83b|
1352|2dd864|        // NOTE: Cmd+G (Go to Line) is defined in GoMenuCommands.swift - DO NOT ADD HERE
1353|adc83b|
1354|0751e9|        // Tab: accept autocomplete if visible, else insert tab
1355|7020ca|        commands.append(UIKeyCommand(
1356|b3d893|            input: "\t",
1357|af20c6|            modifierFlags: [],
1358|c4b06d|            action: #selector(handleTab)
1359|813e75|        ))
1360|d6ed84|        
1361|7c5ea5|        // Escape: dismiss autocomplete/peek if visible
1362|7020ca|        commands.append(UIKeyCommand(
1363|aa55b4|            input: UIKeyCommand.inputEscape,
1364|af20c6|            modifierFlags: [],
1365|4c4ea9|            action: #selector(handleEscape)
1366|813e75|        ))
1367|d6ed84|        
1368|fa4905|        // Fold: Cmd+Opt+[
1369|7020ca|        commands.append(UIKeyCommand(
1370|b5f331|            input: "[",
1371|3e5503|            modifierFlags: [.command, .alternate],
1372|424085|            action: #selector(handleFold)
1373|813e75|        ))
1374|d6ed84|        
1375|17acbb|        // Unfold: Cmd+Opt+]
1376|7020ca|        commands.append(UIKeyCommand(
1377|8b0008|            input: "]",
1378|3e5503|            modifierFlags: [.command, .alternate],
1379|a2225f|            action: #selector(handleUnfold)
1380|813e75|        ))
1381|d6ed84|        
1382|da29c7|        // Toggle Terminal: Cmd+J (not in standard system menus, safe to define here)
1383|a60c7e|        let toggleTerminalCmd = UIKeyCommand(
1384|f01b26|            input: "j",
1385|791043|            modifierFlags: .command,
1386|e6ca50|            action: #selector(handleToggleTerminal),
1387|1af0a9|            discoverabilityTitle: "Toggle Panel"
1388|3143a4|        )
1389|021006|        toggleTerminalCmd.wantsPriorityOverSystemBehavior = true
1390|329329|        commands.append(toggleTerminalCmd)
1391|d6ed84|        
1392|1b3a07|        // AI Assistant: Cmd+Shift+A (not conflicting with system Select All which is Cmd+A)
1393|7020ca|        commands.append(UIKeyCommand(
1394|177757|            input: "a",
1395|8d9971|            modifierFlags: [.command, .shift],
1396|1dee45|            action: #selector(handleShowAIAssistant),
1397|92b3dc|            discoverabilityTitle: "AI Assistant"
1398|813e75|        ))
1399|d6ed84|        
1400|876d9a|        // MARK: - App-Level Shortcuts that conflict with UITextView defaults
1401|417f86|        // These MUST be defined here with wantsPriorityOverSystemBehavior to override
1402|b023b0|        // UITextView's built-in handlers (Bold=Cmd+B, Italic=Cmd+I, Print=Cmd+P, etc.)
1403|d6ed84|        
1404|0789a5|        // Toggle Sidebar: Cmd+B (overrides UITextView's "Bold" command)
1405|f34626|        let toggleSidebarCmd = UIKeyCommand(
1406|c21f91|            input: "b",
1407|791043|            modifierFlags: .command,
1408|fd9c9d|            action: #selector(handleToggleSidebar),
1409|8f6ce0|            discoverabilityTitle: "Toggle Sidebar"
1410|3143a4|        )
1411|767005|        toggleSidebarCmd.wantsPriorityOverSystemBehavior = true
1412|adcd07|        commands.append(toggleSidebarCmd)
1413|d6ed84|        
1414|7aaf15|        // Command Palette: Cmd+Shift+P (VS Code's most important shortcut)
1415|84ad03|        let cmdPaletteCmd = UIKeyCommand(
1416|022265|            input: "p",
1417|8d9971|            modifierFlags: [.command, .shift],
1418|1339c8|            action: #selector(handleShowCommandPalette),
1419|37ea80|            discoverabilityTitle: "Command Palette"
1420|3143a4|        )
1421|84edb1|        cmdPaletteCmd.wantsPriorityOverSystemBehavior = true
1422|1f0c8e|        commands.append(cmdPaletteCmd)
1423|d6ed84|        
1424|a9230e|        // Quick Open: Cmd+P (overrides system "Print" command)
1425|c94963|        let quickOpenCmd = UIKeyCommand(
1426|022265|            input: "p",
1427|791043|            modifierFlags: .command,
1428|6a1edf|            action: #selector(handleShowQuickOpen),
1429|5f77d9|            discoverabilityTitle: "Quick Open"
1430|3143a4|        )
1431|dccd84|        quickOpenCmd.wantsPriorityOverSystemBehavior = true
1432|ab20ff|        commands.append(quickOpenCmd)
1433|d6ed84|        
1434|f2a6a7|        // New File: Cmd+N
1435|239cbd|        let newFileCmd = UIKeyCommand(
1436|0549ea|            input: "n",
1437|791043|            modifierFlags: .command,
1438|ae138f|            action: #selector(handleNewFile),
1439|d350d6|            discoverabilityTitle: "New File"
1440|3143a4|        )
1441|91d006|        newFileCmd.wantsPriorityOverSystemBehavior = true
1442|1d3599|        commands.append(newFileCmd)
1443|d6ed84|        
1444|c16fdb|        // Save: Cmd+S
1445|10fa85|        let saveCmd = UIKeyCommand(
1446|a1985e|            input: "s",
1447|791043|            modifierFlags: .command,
1448|6ba66c|            action: #selector(handleSaveFile),
1449|863fd2|            discoverabilityTitle: "Save"
1450|3143a4|        )
1451|26081a|        saveCmd.wantsPriorityOverSystemBehavior = true
1452|5dd1cb|        commands.append(saveCmd)
1453|d6ed84|        
1454|976d1c|        // Close Tab: Cmd+W
1455|e61690|        let closeTabCmd = UIKeyCommand(
1456|0880cc|            input: "w",
1457|791043|            modifierFlags: .command,
1458|9f0305|            action: #selector(handleCloseTab),
1459|6df774|            discoverabilityTitle: "Close Tab"
1460|3143a4|        )
1461|2c1c6b|        closeTabCmd.wantsPriorityOverSystemBehavior = true
1462|41d3f0|        commands.append(closeTabCmd)
1463|d6ed84|        
1464|bcc592|        // Find: Cmd+F
1465|4a10ea|        let findCmd = UIKeyCommand(
1466|6c041a|            input: "f",
1467|791043|            modifierFlags: .command,
1468|ecd0ee|            action: #selector(handleFind),
1469|d0ec0f|            discoverabilityTitle: "Find"
1470|3143a4|        )
1471|bea84d|        findCmd.wantsPriorityOverSystemBehavior = true
1472|0b235f|        commands.append(findCmd)
1473|d6ed84|        
1474|a05812|        // Undo: Cmd+Z
1475|546e2c|        let undoCmd = UIKeyCommand(
1476|9b11b3|            input: "z",
1477|791043|            modifierFlags: .command,
1478|fe6402|            action: #selector(handleUndo),
1479|5badd2|            discoverabilityTitle: "Undo"
1480|3143a4|        )
1481|fd81bb|        undoCmd.wantsPriorityOverSystemBehavior = true
1482|d37784|        commands.append(undoCmd)
1483|d6ed84|        
1484|dda763|        // Redo: Cmd+Shift+Z
1485|40379c|        let redoCmd = UIKeyCommand(
1486|9b11b3|            input: "z",
1487|8d9971|            modifierFlags: [.command, .shift],
1488|5a175a|            action: #selector(handleRedo),
1489|fd37b5|            discoverabilityTitle: "Redo"
1490|3143a4|        )
1491|42f687|        redoCmd.wantsPriorityOverSystemBehavior = true
1492|d9b0e4|        commands.append(redoCmd)
1493|d6ed84|        
1494|abb5c6|        return commands
1495|27e597|    }
1496|b4687f|    
1497|ecb34f|    @objc func handlePeekDefinition() {
1498|e16a0b|        onPeekDefinition?()
1499|27e597|    }
1500|adc83b|
1501|555859|    @objc func handleGoToLine() {
1502|78ec47|        onGoToLine?()
1503|27e597|    }
1504|adc83b|
1505|4b7ac3|    @objc func handleTab() {
1506|ea72c6|        // Defer to next runloop iteration to avoid modifying @Binding during view update cycle
1507|928fc1|        // Using asyncAfter(.now()) instead of async to guarantee execution AFTER current cycle completes
1508|67bc8a|        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
1509|2baf81|            guard let self = self else { return }
1510|81b4e0|            if self.onAcceptAutocomplete?() == true {
1511|53ab34|                return
1512|a7dc16|            }
1513|b446a2|            self.insertText("\t")
1514|5f3077|        }
1515|27e597|    }
1516|b4687f|    
1517|28ccc2|    @objc func handleEscape() {
1518|077afb|        if onDismissAutocomplete?() == true {
1519|bef5d6|            return
1520|5f3077|        }
1521|7749f6|        onEscape?()
1522|27e597|    }
1523|b4687f|    
1524|98edf7|    @objc func handleFold() {
1525|d303f9|        onFold?()
1526|27e597|    }
1527|b4687f|    
1528|035096|    @objc func handleUnfold() {
1529|e6e3b2|        onUnfold?()
1530|27e597|    }
1531|adc83b|
1532|db75df|    // MARK: - Undo / Redo
1533|adc83b|
1534|74a433|    @objc func handleUndo() {
1535|fe4807|        undoManager?.undo()
1536|27e597|    }
1537|adc83b|
1538|bddc81|    @objc func handleRedo() {
1539|af088f|        undoManager?.redo()
1540|27e597|    }
1541|b4687f|    
1542|46d349|    // MARK: - App-Level Shortcut Handlers
1543|b4687f|    
1544|21f1bc|    @objc func handleShowCommandPalette() {
1545|fbe0c5|        NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
1546|27e597|    }
1547|b4687f|    
1548|46f792|    @objc func handleToggleTerminal() {
1549|10178b|        NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
1550|27e597|    }
1551|b4687f|    
1552|0dcf1e|    @objc func handleShowAIAssistant() {
1553|59910a|        NotificationCenter.default.post(name: NSNotification.Name("ShowAIAssistant"), object: nil)
1554|27e597|    }
1555|b4687f|    
1556|30a71a|    @objc func handleToggleSidebar() {
1557|2114eb|        NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
1558|27e597|    }
1559|b4687f|    
1560|991940|    @objc func handleShowQuickOpen() {
1561|5b0f35|        NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
1562|27e597|    }
1563|b4687f|    
1564|c28d1b|    @objc func handleNewFile() {
1565|387109|        NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
1566|27e597|    }
1567|b4687f|    
1568|212d04|    @objc func handleSaveFile() {
1569|eb35b9|        NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
1570|27e597|    }
1571|b4687f|    
1572|24f8f9|    @objc func handleCloseTab() {
1573|c4ac53|        NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
1574|27e597|    }
1575|b4687f|    
1576|4767e4|    @objc func handleFind() {
1577|6bd372|        NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
1578|27e597|    }
1579|b4687f|    
1580|824153|    @objc func handleZoomIn() {
1581|6d51cf|        NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
1582|27e597|    }
1583|b4687f|    
1584|185408|    @objc func handleZoomOut() {
1585|80759b|        NotificationCenter.default.post(name: NSNotification.Name("ZoomOut"), object: nil)
1586|27e597|    }
1587|b4687f|    
1588|bc9ff0|    // MARK: - Custom Actions
1589|b4687f|    
1590|5c40d8|    @objc private func goToDefinition(_ sender: Any?) {
1591|d96981|        onGoToDefinition?()
1592|27e597|    }
1593|b4687f|    
1594|66c805|    @objc private func peekDefinition(_ sender: Any?) {
1595|e16a0b|        onPeekDefinition?()
1596|27e597|    }
1597|b4687f|    
1598|99279f|    @objc private func findReferences(_ sender: Any?) {
1599|556cb2|        onFindReferences?()
1600|27e597|    }


Now I have enough information to write my report. I've found the root cause of the duplicate keyboard shortcuts.

>>>REPORT
## Duplicate Keyboard Shortcut Investigation Report

### Summary
Keyboard shortcuts are being registered in **THREE separate locations**, causing duplicate registration warnings.

### 1. Where Commands Are Defined

**Location 1: VSCodeiPadOSApp.swift (lines 135-168)** - SwiftUI `.keyboardShortcut()` modifiers:
- Command Palette: `Cmd+Shift+P` (line 141)
- Toggle Sidebar: `Cmd+B` (line 148)
- Toggle Terminal: `Cmd+`` (line 153)
- Zoom In: `Cmd+=` (line 160)
- Zoom Out: `Cmd+-` (line 165)

**Location 2: SyntaxHighlightingTextView.swift - EditorTextView.keyCommands (lines 1336-1495)**:
- Toggle Sidebar: `Cmd+B` (lines 1405-1412)
- Command Palette: `Cmd+Shift+P` (lines 1415-1422)
- Toggle Terminal: `Cmd+J` (lines 1382-1390)
- Plus: Quick Open, New File, Save, Close Tab, Find, Undo, Redo

**Location 3: RunestoneEditorView.swift - VSCodeRunestoneTextView.keyCommands (lines 30-138)**:
- Toggle Sidebar: `Cmd+B` (lines 38-45)
- Command Palette: `Cmd+Shift+P` (lines 47-55)
- Toggle Terminal: `Cmd+J` (lines 107-115)
- Plus: Quick Open, New File, Save, Close Tab, Find, Undo, Redo

### 2. Why They Are Duplicated

The code has contradictory comments and implementation. Line 1336-1342 in SyntaxHighlightingTextView.swift states:
```swift
// NOTE: Only define text-editing specific shortcuts here.
// App-level shortcuts (Cmd+B, Cmd+P, Cmd+N, Cmd+S, Cmd+W, Cmd+F, etc.)
// are defined in the Menus/ folder via SwiftUI's .keyboardShortcut().
// Defining them here AND in Menus/ causes duplicate conflicts.
```

**But then the code DOES define those same shortcuts starting at line 1400!**

The reason: UITextView has built-in handlers for Cmd+B (Bold), Cmd+I (Italic), Cmd+P (Print). To override these, `wantsPriorityOverSystemBehavior = true` is needed on UIKeyCommand. But SwiftUI menus ALSO define `.keyboardShortcut()` for the same keys, creating duplicates.

### 3. How to Fix the Duplicates

**Option A (Recommended): Remove `.keyboardShortcut()` from SwiftUI menus for overridden shortcuts**

In `VSCodeiPadOSApp.swift`, remove these `.keyboardShortcut()` modifiers since they're already handled by `keyCommands`:
- Line 141: Remove `.keyboardShortcut("p", modifiers: [.command, .shift])` (Command Palette)
- Line 148: Remove `.keyboardShortcut("b", modifiers: .command)` (Toggle Sidebar)
- Line 153: Remove `.keyboardShortcut("`", modifiers: .command)` (Toggle Terminal)

Keep the menu Buttons, just remove the shortcut assignment - the keyCommands in EditorTextView/VSCodeRunestoneTextView will handle the actual keyboard input.

**Option B: Remove duplicate keyCommands from text views**

Remove the app-level shortcuts from `EditorTextView.keyCommands` (lines 1400-1492) and `VSCodeRunestoneTextView.keyCommands` (lines 38-135), keeping only editor-specific shortcuts. However, this breaks shortcuts when UITextView has focus because UITextView intercepts Cmd+B/Cmd+P/etc.

### 4. For Zoom In/Out Specifically

Zoom In/Out (`Cmd+=`, `Cmd+-`) are ONLY defined in VSCodeiPadOSApp.swift (lines 160, 165). They aren't in keyCommands. If they're showing as duplicates, the SwiftUI menu system may be instantiating multiple times. Verify only one WindowGroup exists with the `.commands` modifier.

### Files to Modify

1. **VSCodeiPadOSApp.swift** - Remove `.keyboardShortcut()` for shortcuts that are also in keyCommands
2. **SyntaxHighlightingTextView.swift** (lines 1400-1492) - OR remove these duplicates
3. **RunestoneEditorView.swift** (lines 38-135) - OR remove these duplicates (keep in sync with option chosen)

The existing comment at line 1336-1342 already identifies the correct approach - the implementation just doesn't follow it.
>>>END
