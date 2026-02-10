import SwiftUI

@main
struct VSCodeiPadOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var editorCore = EditorCore()
    @State private var showSettings = false
    @State private var showTerminal = false
    @State private var windowTitle: String = "VS Code"
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(editorCore)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WindowTitleDidChange"))) { notification in
                    if let userInfo = notification.userInfo,
                       let title = userInfo["title"] as? String {
                        windowTitle = title
                        updateWindowTitle(title)
                    }
                }
        }
        .commands {
            // VS Code-style menu bar
            FileMenuCommands()
            EditMenuCommands()
            SelectionMenuCommands()
            ViewMenuCommands()
            GoMenuCommands()
            RunMenuCommands()
            TerminalMenuCommands()
            HelpMenuCommands()
        }
    }
    
    private func updateWindowTitle(_ title: String) {
        // Update the window title for the scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.title = title
        }
    }
}

// MARK: - File Menu Commands

struct FileMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("File") {
            Button("New File") {
                NotificationCenter.default.post(name: NSNotification.Name("NewFile"), object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)
            
            Button("New Window") {
                // Request new window via UIKit
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Open...") {
                NotificationCenter.default.post(name: NSNotification.Name("OpenFile"), object: nil)
            }
            .keyboardShortcut("o", modifiers: .command)
            
            Divider()
            
            Button("Save") {
                NotificationCenter.default.post(name: NSNotification.Name("SaveFile"), object: nil)
            }
            .keyboardShortcut("s", modifiers: .command)
            
            Button("Save All") {
                NotificationCenter.default.post(name: NSNotification.Name("SaveAllFiles"), object: nil)
            }
            .keyboardShortcut("s", modifiers: [.command, .option])
            
            Divider()
            
            Button("Close Tab") {
                NotificationCenter.default.post(name: NSNotification.Name("CloseTab"), object: nil)
            }
            .keyboardShortcut("w", modifiers: .command)
        }
    }
}

// MARK: - Edit Menu Commands

struct EditMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Edit") {
            Button("Undo") {
                NotificationCenter.default.post(name: NSNotification.Name("Undo"), object: nil)
            }
            .keyboardShortcut("z", modifiers: .command)
            
            Button("Redo") {
                NotificationCenter.default.post(name: NSNotification.Name("Redo"), object: nil)
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Cut") {
                NotificationCenter.default.post(name: NSNotification.Name("Cut"), object: nil)
            }
            .keyboardShortcut("x", modifiers: .command)
            
            Button("Copy") {
                NotificationCenter.default.post(name: NSNotification.Name("Copy"), object: nil)
            }
            .keyboardShortcut("c", modifiers: .command)
            
            Button("Paste") {
                NotificationCenter.default.post(name: NSNotification.Name("Paste"), object: nil)
            }
            .keyboardShortcut("v", modifiers: .command)
            
            Divider()
            
            Button("Find") {
                NotificationCenter.default.post(name: NSNotification.Name("ShowFind"), object: nil)
            }
            .keyboardShortcut("f", modifiers: .command)
            
            Button("Replace") {
                NotificationCenter.default.post(name: NSNotification.Name("ShowReplace"), object: nil)
            }
            .keyboardShortcut("h", modifiers: [.command, .option])
        }
    }
}

// MARK: - Selection Menu Commands

struct SelectionMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Selection") {
            Button("Select All") {
                NotificationCenter.default.post(name: NSNotification.Name("SelectAll"), object: nil)
            }
            .keyboardShortcut("a", modifiers: .command)
            
            Divider()
            
            Button("Add Cursor Above") {
                NotificationCenter.default.post(name: NSNotification.Name("AddCursorAbove"), object: nil)
            }
            .keyboardShortcut(.upArrow, modifiers: [.command, .option])
            
            Button("Add Cursor Below") {
                NotificationCenter.default.post(name: NSNotification.Name("AddCursorBelow"), object: nil)
            }
            .keyboardShortcut(.downArrow, modifiers: [.command, .option])
        }
    }
}

// MARK: - View Menu Commands

struct ViewMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("View") {
            Button("Command Palette") {
                NotificationCenter.default.post(name: NSNotification.Name("ShowCommandPalette"), object: nil)
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Toggle Sidebar") {
                NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
            }
            .keyboardShortcut("b", modifiers: .command)
            
            Button("Toggle Terminal") {
                NotificationCenter.default.post(name: NSNotification.Name("ToggleTerminal"), object: nil)
            }
            .keyboardShortcut("`", modifiers: .control)
            
            Divider()
            
            Button("Zoom In") {
                NotificationCenter.default.post(name: NSNotification.Name("ZoomIn"), object: nil)
            }
            .keyboardShortcut("+", modifiers: .command)
            
            Button("Zoom Out") {
                NotificationCenter.default.post(name: NSNotification.Name("ZoomOut"), object: nil)
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
                NotificationCenter.default.post(name: NSNotification.Name("ShowQuickOpen"), object: nil)
            }
            .keyboardShortcut("p", modifiers: .command)
            
            Button("Go to Symbol...") {
                NotificationCenter.default.post(name: NSNotification.Name("ShowGoToSymbol"), object: nil)
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])
            
            Button("Go to Line...") {
                NotificationCenter.default.post(name: NSNotification.Name("ShowGoToLine"), object: nil)
            }
            .keyboardShortcut("g", modifiers: .control)
            
            Divider()
            
            Button("Go to Definition") {
                NotificationCenter.default.post(name: NSNotification.Name("GoToDefinition"), object: nil)
            }
            .keyboardShortcut(.return, modifiers: .command)
            
            Button("Go Back") {
                NotificationCenter.default.post(name: NSNotification.Name("GoBack"), object: nil)
            }
            .keyboardShortcut("[", modifiers: .control)
            
            Button("Go Forward") {
                NotificationCenter.default.post(name: NSNotification.Name("GoForward"), object: nil)
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
                NotificationCenter.default.post(name: NSNotification.Name("StartDebugging"), object: nil)
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
            
            Button("Run Without Debugging") {
                NotificationCenter.default.post(name: NSNotification.Name("RunWithoutDebugging"), object: nil)
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Toggle Breakpoint") {
                NotificationCenter.default.post(name: NSNotification.Name("ToggleBreakpoint"), object: nil)
            }
            .keyboardShortcut("b", modifiers: [.command, .shift])
        }
    }
}

// MARK: - Terminal Menu Commands

struct TerminalMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Terminal") {
            Button("New Terminal") {
                NotificationCenter.default.post(name: NSNotification.Name("NewTerminal"), object: nil)
            }
            .keyboardShortcut("`", modifiers: [.control, .shift])
            
            Button("Clear Terminal") {
                NotificationCenter.default.post(name: NSNotification.Name("ClearTerminal"), object: nil)
            }
            .keyboardShortcut("k", modifiers: .command)
        }
    }
}

// MARK: - Help Menu Commands

struct HelpMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Help") {
            Button("Documentation") {
                if let url = URL(string: "https://code.visualstudio.com/docs") {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Keyboard Shortcuts") {
                NotificationCenter.default.post(name: NSNotification.Name("ShowKeyboardShortcuts"), object: nil)
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])
            
            Divider()
            
            Button("About VS Code for iPad") {
                NotificationCenter.default.post(name: NSNotification.Name("ShowAbout"), object: nil)
            }
        }
    }
}
