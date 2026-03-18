import SwiftUI

@main
struct VSCodeiPadOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var editorCore = EditorCore()
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSettings = false
    @State private var showTerminal = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var windowTitle: String = "CodePad"
    
    var body: some Scene {
        WindowGroup {
            KeyCommandBridge {
                ContentView()
                    .environmentObject(editorCore)
                    .preferredColorScheme(themeManager.preferredColorScheme)
                    .onReceive(NotificationCenter.default.publisher(for: .windowTitleDidChange)) { notification in
                        if let userInfo = notification.userInfo,
                           let title = userInfo["title"] as? String {
                            windowTitle = title
                            updateWindowTitle(title)
                        }
                    }
                    .onChange(of: colorScheme) { _, newScheme in
                        themeManager.applySystemAppearance(newScheme)
                    }
                    .onAppear {
                        themeManager.applySystemAppearance(colorScheme)
                    }
                    // ── First-launch onboarding ──────────────────────
                    .fullScreenCover(isPresented: Binding(
                        get: { !hasCompletedOnboarding },
                        set: { _ in }
                    )) {
                        OnboardingView()
                            .environmentObject(themeManager)
                    }
                    // ── Deep-link / open-in handler ──────────────────
                    .onOpenURL { url in
                        // Handles files shared from Files app, Safari, or other apps
                        // (complements SceneDelegate's UIKit open-URL path).
                        AppLogger.editor.info("Received deep-link URL: \(url.absoluteString)")
                        if url.isFileURL {
                            let didStart = url.startAccessingSecurityScopedResource()
                            editorCore.openFile(from: url)
                            if didStart { url.stopAccessingSecurityScopedResource() }
                        } else {
                            // Non-file deep link — forward via notification for interested handlers
                            NotificationCenter.default.post(
                                name: .openFile,
                                object: nil,
                                userInfo: ["url": url]
                            )
                        }
                    }
            }
        }
        .commands {
            // Hide conflicting system text editing menu
            CommandGroup(replacing: .textEditing) { }
            // VS Code-style menu bar (our custom menus)
            FileMenuCommands()
            EditMenuCommands()
            SelectionMenuCommands()
            ViewMenuCommands()
            GoMenuCommands()
            RunMenuCommands()
            TerminalMenuCommands()
            HelpMenuCommands()
        }
        // ── Scene phase handling ─────────────────────────────────
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                // Trigger auto-save of all open files and persist window state.
                // Complements AppDelegate.applicationDidEnterBackground which
                // calls SceneDelegate.saveWindowState per UIKit scene.
                AppLogger.editor.info("Scene → background: saving all open files")
                editorCore.saveAllTabs()
                AutoSaveManager.shared.appDidResignActive()
                // Capture current editor state for every connected window
                for scene in UIApplication.shared.connectedScenes {
                    guard let windowScene = scene as? UIWindowScene else { continue }
                    let windowId = windowScene.session.windowId
                    WindowStateManager.shared.captureState(
                        from: editorCore,
                        windowId: windowId,
                        workspacePath: editorCore.fileNavigator?.rootPath
                    )
                }
            case .inactive:
                // Pause focus-change auto-saves to avoid spurious writes while
                // the app is transitioning (e.g. notification centre appearing).
                AppLogger.editor.debug("Scene → inactive: flushing focus-change saves")
                AutoSaveManager.shared.editorDidLoseFocus()
            case .active:
                // Re-read open files that may have been edited externally.
                AppLogger.editor.debug("Scene → active: refreshing files from disk")
                refreshOpenFilesFromDisk()
            @unknown default:
                break
            }
        }
    }
    
    private func updateWindowTitle(_ title: String) {
        // Update the window title for the scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.title = title
        }
    }

    /// Re-read open files that may have been modified externally while CodePad
    /// was inactive (e.g. edited in Files or Working Copy).
    /// Only reloads tabs with no local unsaved changes, to avoid data loss.
    private func refreshOpenFilesFromDisk() {
        for index in editorCore.tabs.indices {
            let tab = editorCore.tabs[index]
            guard let url = tab.url,
                  !tab.isUnsaved,
                  FileManager.default.fileExists(atPath: url.path),
                  let data = try? Data(contentsOf: url),
                  let diskContent = String(data: data, encoding: tab.stringEncoding),
                  diskContent != tab.content else { continue }
            // Content differs from what is in memory — reload silently
            AppLogger.editor.info("External change detected for \(tab.fileName) — reloading from disk")
            editorCore.tabs[index].content = diskContent
        }
    }
}

// MARK: - File Menu Commands

struct FileMenuCommands: Commands {
    var body: some Commands {
        // Add to existing system File menu
        CommandGroup(replacing: .newItem) {
            Button("New File") {
                NotificationCenter.default.post(name: .newFile, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)
            
            Button("New Window") {
                UIApplication.shared.requestSceneSessionActivation(
                    nil, userActivity: nil, options: nil, errorHandler: { error in
                        AppLogger.editor.error("Failed to create new window: \(error)")
                    }
                )
            }
            .keyboardShortcut("n", modifiers: [.command, .option])
        }
        
        CommandGroup(after: .newItem) {
            Divider()
            
            Button("Open...") {
                NotificationCenter.default.post(name: .openFile, object: nil)
            }
            
            Divider()
            
            Button("Save") {
                NotificationCenter.default.post(name: .saveFile, object: nil)
            }
            .keyboardShortcut("s", modifiers: .command)
            
            Button("Save All") {
                NotificationCenter.default.post(name: .saveAllFiles, object: nil)
            }
            .keyboardShortcut("s", modifiers: [.command, .option])
            
            Divider()
            
            Button("Close Tab") {
                NotificationCenter.default.post(name: .closeTab, object: nil)
            }
            .keyboardShortcut("w", modifiers: .command)
        }
    }
}

// MARK: - Edit Menu Commands

struct EditMenuCommands: Commands {
    var body: some Commands {
        // Add Find/Replace to existing Edit menu (after pasteboard operations)
        CommandGroup(after: .pasteboard) {
            Divider()
            
            Button("Toggle Comment") {
                NotificationCenter.default.post(name: .toggleComment, object: nil)
            }
            .keyboardShortcut("/", modifiers: .command)
            
            Divider()
            
            Button("Find") {
                NotificationCenter.default.post(name: .showFind, object: nil)
            }
            .keyboardShortcut("f", modifiers: .command)
            
            Button("Replace") {
                NotificationCenter.default.post(name: .showReplace, object: nil)
            }
            .keyboardShortcut("f", modifiers: [.command, .option])
            
            Button("Search in Files") {
                NotificationCenter.default.post(name: .showGlobalSearch, object: nil)
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }
}

// MARK: - Selection Menu Commands

struct SelectionMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Selection") {
            Button("Add Next Occurrence") {
                NotificationCenter.default.post(name: .addNextOccurrence, object: nil)
            }
            .keyboardShortcut("d", modifiers: .command)
            
            Button("Select All Occurrences") {
                NotificationCenter.default.post(name: .selectAllOccurrences, object: nil)
            }
            .keyboardShortcut("l", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Add Cursor Above") {
                NotificationCenter.default.post(name: .addCursorAbove, object: nil)
            }
            .keyboardShortcut(.upArrow, modifiers: [.command, .option])
            
            Button("Add Cursor Below") {
                NotificationCenter.default.post(name: .addCursorBelow, object: nil)
            }
            .keyboardShortcut(.downArrow, modifiers: [.command, .option])
        }
    }
}

// MARK: - View Menu Commands

struct ViewMenuCommands: Commands {
    var body: some Commands {
        // Add to existing system View menu
        CommandGroup(replacing: .sidebar) {
            Button("Toggle Sidebar") {
                NotificationCenter.default.post(name: .toggleSidebar, object: nil)
            }
            // Note: Cmd+B shortcut handled by UIKeyCommand in editor to override Bold
        }
        
        CommandGroup(after: .sidebar) {
            Button("Command Palette") {
                NotificationCenter.default.post(name: .showCommandPalette, object: nil)
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
            
            Button("Toggle Terminal") {
                NotificationCenter.default.post(name: .toggleTerminal, object: nil)
            }
            .keyboardShortcut("j", modifiers: .command)
            
            Button("AI Assistant") {
                NotificationCenter.default.post(name: .showAIAssistant, object: nil)
            }
            .keyboardShortcut("a", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Zoom In") {
                NotificationCenter.default.post(name: .zoomIn, object: nil)
            }
            .keyboardShortcut("+", modifiers: .command)
            
            Button("Zoom Out") {
                NotificationCenter.default.post(name: .zoomOut, object: nil)
            }
            .keyboardShortcut("-", modifiers: .command)
        }
    }
}

// MARK: - Go Menu Commands

struct GoMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Go") {
            Button("Go to File...") {
                NotificationCenter.default.post(name: .showQuickOpen, object: nil)
            }
            .keyboardShortcut("p", modifiers: .command)
            
            Button("Go to Symbol...") {
                NotificationCenter.default.post(name: .showGoToSymbol, object: nil)
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])
            
            Button("Go to Line...") {
                NotificationCenter.default.post(name: .showGoToLine, object: nil)
            }
            .keyboardShortcut("g", modifiers: .control)
            
            Divider()
            
            Button("Go to Definition") {
                NotificationCenter.default.post(name: .goToDefinition, object: nil)
            }
            .keyboardShortcut(".", modifiers: .command)
            
            Button("Insert Line Below") {
                NotificationCenter.default.post(name: .insertLineBelow, object: nil)
            }
            .keyboardShortcut(.return, modifiers: .command)
            
            Button("Insert Line Above") {
                NotificationCenter.default.post(name: .insertLineAbove, object: nil)
            }
            .keyboardShortcut(.return, modifiers: [.command, .shift])
            
            Button("Go Back") {
                NotificationCenter.default.post(name: .goBack, object: nil)
            }
            .keyboardShortcut("[", modifiers: .control)
            
            Button("Go Forward") {
                NotificationCenter.default.post(name: .goForward, object: nil)
            }
            .keyboardShortcut("]", modifiers: .control)
        }
    }
}

// MARK: - Run Menu Commands

struct RunMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Run") {
            Button("Start Debugging") {
                NotificationCenter.default.post(name: .startDebugging, object: nil)
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
            
            Button("Run Without Debugging") {
                NotificationCenter.default.post(name: .runWithoutDebugging, object: nil)
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Toggle Breakpoint") {
                NotificationCenter.default.post(name: .toggleBreakpoint, object: nil)
            }
            .keyboardShortcut("b", modifiers: [.command, .shift])
            
            #if DEBUG
            Divider()
            
            Button("Run Sample WASM") {
                NotificationCenter.default.post(name: .runSampleWASM, object: nil)
            }
            
            Button("Run JavaScript") {
                NotificationCenter.default.post(name: .runJavaScript, object: nil)
            }
            #endif
        }
    }
}

// MARK: - Terminal Menu Commands

struct TerminalMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Terminal") {
            Button("New Terminal") {
                NotificationCenter.default.post(name: .newTerminal, object: nil)
            }
            .keyboardShortcut("`", modifiers: [.control, .shift])
            
            Button("Clear Terminal") {
                NotificationCenter.default.post(name: .clearTerminal, object: nil)
            }
            .keyboardShortcut("k", modifiers: .command)
        }
    }
}

// MARK: - Help Menu Commands

struct HelpMenuCommands: Commands {
    var body: some Commands {
        // Replace system Help menu content
        CommandGroup(replacing: .help) {
            Button("Documentation") {
                if let url = URL(string: "https://code.visualstudio.com/docs") {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Keyboard Shortcuts") {
                NotificationCenter.default.post(name: .showKeyboardShortcuts, object: nil)
            }
            .keyboardShortcut("/", modifiers: [.command, .shift])
            
            Divider()
            
            Button("About CodePad") {
                NotificationCenter.default.post(name: .showAbout, object: nil)
            }
        }
    }
}
