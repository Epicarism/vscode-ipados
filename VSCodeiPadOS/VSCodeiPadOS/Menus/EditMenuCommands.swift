import SwiftUI

/// Edit menu commands for the iPadOS VS Code editor.
/// Provides standard editing operations and search functionality.
struct EditMenuCommands: Commands {
    // MARK: - Core Dependencies
    
    @FocusedValue(\.menuEditorCore) private var editorCore: EditorCore?
    @FocusedValue(\.undoManager) private var undoManager: UndoManager?
    
    // MARK: - Body
    
    var body: some Commands {
        CommandMenu("Edit") {
            // MARK: - Undo/Redo
            
            Section {
                Button("Undo") {
                    undoManager?.undo()
                }
                // Note: UITextView has built-in Cmd+Z support, removed duplicate
                .disabled(undoManager?.canUndo ?? false)
                
                Button("Redo") {
                    undoManager?.redo()
                }
                // Note: UITextView has built-in Cmd+Shift+Z support, removed duplicate
                .disabled(undoManager?.canRedo ?? false)
            }
            
            Divider()
            
            // MARK: - Clipboard Operations
            
            Section {
                Button("Cut") {
                    // System responder chain handles cut operation
                    NotificationCenter.default.post(name: .cutAction, object: nil)
                }
                // Note: UITextView has built-in Cmd+X support, removed duplicate
                
                Button("Copy") {
                    // System responder chain handles copy operation
                    NotificationCenter.default.post(name: .copyAction, object: nil)
                }
                // Note: UITextView has built-in Cmd+C support, removed duplicate
                
                Button("Paste") {
                    // System responder chain handles paste operation
                    NotificationCenter.default.post(name: .pasteAction, object: nil)
                }
                // Note: UITextView has built-in Cmd+V support, removed duplicate
            }
            
            Divider()
            
            // MARK: - Find and Replace
            
            Section {
                Button("Find") {
                    editorCore?.toggleSearch()
                }
                .keyboardShortcut("f", modifiers: .command)
                
                Button("Find in Files") {
                    editorCore?.toggleSearch()
                    editorCore?.focusExplorer()
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
                
                Button("Replace") {
                    editorCore?.toggleSearch()
                    editorCore?.togglePanel()
                }
                .keyboardShortcut("f", modifiers: [.command, .option])
                
                Button("Find and Replace") {
                    editorCore?.toggleSearch()
                    editorCore?.togglePanel()
                }
                .keyboardShortcut("h", modifiers: .command)
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let cutAction = Notification.Name("cutAction")
    static let copyAction = Notification.Name("copyAction")
    static let pasteAction = Notification.Name("pasteAction")
}

// MARK: - Uses MenuFocusedValues.swift for EditorCore access
