import SwiftUI

// CommandPaletteView is defined in CommandPalette.swift to avoid redeclaration.
// This file contains supporting types used by CommandPaletteView.

struct PalettePaletteCommandCategory {
    let name: String
    let commands: [CommandItem]
}

struct CommandItem {
    let title: String
    let icon: String
    let shortcut: String
    let keywords: [String]
    let action: () -> Void
}

// Preview
struct CommandPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        CommandPaletteView(editorCore: EditorCore(), showSettings: .constant(false), showTerminal: .constant(false))
    }
}
