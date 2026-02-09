import SwiftUI

/// Unified focused value keys for menu commands
/// These allow menu items to access app state through the focused scene

// MARK: - EditorCore Key

struct MenuEditorCoreKey: FocusedValueKey {
    typealias Value = EditorCore
}

// MARK: - FocusedValues Extension

extension FocusedValues {
    /// Access the EditorCore from menu commands
    var menuEditorCore: EditorCore? {
        get { self[MenuEditorCoreKey.self] }
        set { self[MenuEditorCoreKey.self] = newValue }
    }
}

// MARK: - Scene Extension for EditorCore

extension View {
    /// Exposes EditorCore to the scene's focused values
    func focusedSceneEditorCore(_ editorCore: EditorCore) -> some View {
        self.focusedSceneValue(\.menuEditorCore, editorCore)
    }
}
