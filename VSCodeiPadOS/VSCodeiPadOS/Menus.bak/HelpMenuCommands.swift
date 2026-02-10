import SwiftUI

/// Commands for the Help menu in VS Code iPadOS
struct HelpMenuCommands: Commands {
    // Environment objects to interact with app state
    @FocusedBinding(\.showCommandPalette) private var showCommandPalette
    @FocusedBinding(\.showAIAssistant) private var showAIAssistant
    
    var body: some Commands {
        CommandMenu("Help") {
            // Welcome - Opens welcome tab
            Button("Welcome") {
                openWelcome()
            }
            .keyboardShortcut("?", modifiers: [.shift, .command])
            
            Divider()
            
            // Show All Commands (Command Palette)
            // NOTE: Shortcut Cmd+Shift+P is defined in ViewMenuCommands.swift
            Button("Show All Commands") {
                showCommandPalette?.toggle()
            }
            // No shortcut here - it's in ViewMenuCommands as "Command Palette"
            
            Divider()
            
            // Documentation - Opens VS Code documentation
            Button("Documentation") {
                openDocumentation()
            }
            
            // Release Notes - Opens release notes
            Button("Release Notes") {
                openReleaseNotes()
            }
            
            Divider()
            
            // Keyboard Shortcuts Reference
            Button("Keyboard Shortcuts Reference") {
                openKeyboardShortcuts()
            }
            
            // Tips and Tricks
            Button("Tips and Tricks") {
                openTipsAndTricks()
            }
            
            Divider()
            
            // Report Issue
            Button("Report Issue") {
                reportIssue()
            }
            
            // Toggle Developer Tools
            Button("Toggle Developer Tools") {
                toggleDeveloperTools()
            }
            .keyboardShortcut("i", modifiers: [.option, .command])
            
            Divider()
            
            // About
            Button("About VS Code iPadOS") {
                showAbout()
            }
        }
    }
    
    // MARK: - Action Methods
    
    /// Opens the Welcome tab with helpful information
    private func openWelcome() {
        // Post notification to open welcome tab
        NotificationCenter.default.post(
            name: .openWelcome,
            object: nil
        )
    }
    
    /// Opens VS Code documentation in browser
    private func openDocumentation() {
        if let url = URL(string: "https://code.visualstudio.com/docs") {
            UIApplication.shared.open(url)
        }
    }
    
    /// Opens release notes for the current version
    private func openReleaseNotes() {
        if let url = URL(string: "https://code.visualstudio.com/updates") {
            UIApplication.shared.open(url)
        }
    }
    
    /// Opens keyboard shortcuts reference
    private func openKeyboardShortcuts() {
        if let url = URL(string: "https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf") {
            UIApplication.shared.open(url)
        }
    }
    
    /// Opens tips and tricks documentation
    private func openTipsAndTricks() {
        if let url = URL(string: "https://code.visualstudio.com/docs/getstarted/tips-and-tricks") {
            UIApplication.shared.open(url)
        }
    }
    
    /// Opens GitHub issue reporter
    private func reportIssue() {
        if let url = URL(string: "https://github.com/microsoft/vscode/issues/new") {
            UIApplication.shared.open(url)
        }
    }
    
    /// Toggles developer tools panel
    private func toggleDeveloperTools() {
        // Post notification to toggle developer tools
        NotificationCenter.default.post(
            name: .toggleDeveloperTools,
            object: nil
        )
    }
    
    /// Shows about dialog
    private func showAbout() {
        // Post notification to show about dialog
        NotificationCenter.default.post(
            name: .showAbout,
            object: nil
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openWelcome = Notification.Name("openWelcome")
    static let toggleDeveloperTools = Notification.Name("toggleDeveloperTools")
    static let showAbout = Notification.Name("showAbout")
}

// MARK: - Focused Values

struct FocusedCommandPaletteKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

struct FocusedAIAssistantKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

extension FocusedValues {
    var showCommandPalette: FocusedCommandPaletteKey.Value? {
        get { self[FocusedCommandPaletteKey.self] }
        set { self[FocusedCommandPaletteKey.self] = newValue }
    }
    
    var showAIAssistant: FocusedAIAssistantKey.Value? {
        get { self[FocusedAIAssistantKey.self] }
        set { self[FocusedAIAssistantKey.self] = newValue }
    }
}
