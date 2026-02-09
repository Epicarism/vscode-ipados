import SwiftUI

struct CommandPaletteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var editorCore: EditorCore
    @State private var searchText = ""
    @State private var commandCategories: [CommandCategory] = []
    
    var filteredCommands: [CommandCategory] {
        if searchText.isEmpty {
            return commandCategories
        }
        return commandCategories.map { category in
            CommandCategory(
                name: category.name,
                commands: category.commands.filter { command in
                    command.title.localizedCaseInsensitiveContains(searchText) ||
                    command.keywords.contains { $0.localizedCaseInsensitiveContains(searchText) }
                }
            )
        }.filter { !$0.commands.isEmpty }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredCommands, id: \.name) { category in
                    Section(header: Text(category.name)) {
                        ForEach(category.commands, id: \.title) { command in
                            Button(action: {
                                command.action()
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: command.icon)
                                        .foregroundColor(.accentColor)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(command.title)
                                            .font(.body)
                                        if !command.shortcut.isEmpty {
                                            Text(command.shortcut)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Command Palette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search commands...")
        }
        .onAppear {
            loadCommands()
        }
    }
    
    private func loadCommands() {
        commandCategories = [
            CommandCategory(name: "Editor", commands: [
                CommandItem(
                    title: "Collapse All",
                    icon: "arrow.turn.down.right",
                    shortcut: "Cmd+K Cmd+0",
                    keywords: ["fold", "collapse", "hide"],
                    action: { editorCore.collapseAllFolds() }
                ),
                CommandItem(
                    title: "Expand All",
                    icon: "arrow.turn.up.right",
                    shortcut: "Cmd+K Cmd+J",
                    keywords: ["unfold", "expand", "show"],
                    action: { editorCore.expandAllFolds() }
                ),
                CommandItem(
                    title: "Toggle Sidebar",
                    icon: "sidebar.left",
                    shortcut: "Cmd+B",
                    keywords: ["sidebar", "panel"],
                    action: { editorCore.toggleSidebar() }
                ),
                CommandItem(
                    title: "Toggle Zen Mode",
                    icon: "rectangle.compress.vertical",
                    shortcut: "Cmd+K Z",
                    keywords: ["zen", "focus", "distraction"],
                    action: { editorCore.toggleZenMode() }
                ),
                CommandItem(
                    title: "Go to Line...",
                    icon: "arrow.right.to.line",
                    shortcut: "Ctrl+G",
                    keywords: ["goto", "line", "navigate"],
                    action: { editorCore.showGoToLine.toggle() }
                ),
            ]),
            
            CommandCategory(name: "View", commands: [
                CommandItem(
                    title: "Zoom In",
                    icon: "plus.magnifyingglass",
                    shortcut: "Cmd++",
                    keywords: ["zoom", "font", "size", "increase"],
                    action: { editorCore.zoomIn() }
                ),
                CommandItem(
                    title: "Zoom Out",
                    icon: "minus.magnifyingglass",
                    shortcut: "Cmd+-",
                    keywords: ["zoom", "font", "size", "decrease"],
                    action: { editorCore.zoomOut() }
                ),
            ]),
            
            CommandCategory(name: "Navigation", commands: [
                CommandItem(
                    title: "Focus Explorer",
                    icon: "folder",
                    shortcut: "Cmd+Shift+E",
                    keywords: ["explorer", "files", "sidebar"],
                    action: { editorCore.focusExplorer() }
                ),
                CommandItem(
                    title: "Focus Git",
                    icon: "branch",
                    shortcut: "Cmd+Shift+G",
                    keywords: ["git", "source", "control"],
                    action: { editorCore.focusGit() }
                ),
            ]),
            
            CommandCategory(name: "Tabs", commands: [
                CommandItem(
                    title: "Next Tab",
                    icon: "chevron.right",
                    shortcut: "Cmd+Option+Right",
                    keywords: ["tab", "next", "forward"],
                    action: { editorCore.nextTab() }
                ),
                CommandItem(
                    title: "Previous Tab",
                    icon: "chevron.left",
                    shortcut: "Cmd+Option+Left",
                    keywords: ["tab", "previous", "back"],
                    action: { editorCore.previousTab() }
                ),
                CommandItem(
                    title: "Close Tab",
                    icon: "xmark",
                    shortcut: "Cmd+W",
                    keywords: ["tab", "close"],
                    action: { 
                        if let id = editorCore.activeTabId {
                            editorCore.closeTab(id: id)
                        }
                    }
                ),
            ]),
        ]
    }
}

struct CommandCategory {
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
        CommandPaletteView(editorCore: EditorCore())
    }
}
