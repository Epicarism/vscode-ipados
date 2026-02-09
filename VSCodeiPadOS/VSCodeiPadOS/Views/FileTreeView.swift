import SwiftUI
import UniformTypeIdentifiers

// MARK: - File Tree View

struct FileTreeView: View {
    let root: FileTreeNode
    @ObservedObject var fileNavigator: FileSystemNavigator
    @ObservedObject var editorCore: EditorCore
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                FileTreeRowView(
                    node: root,
                    level: 0,
                    fileNavigator: fileNavigator,
                    editorCore: editorCore
                )
            }
        }
    }
}

// MARK: - File Tree Row View

struct FileTreeRowView: View {
    let node: FileTreeNode
    let level: Int
    @ObservedObject var fileNavigator: FileSystemNavigator
    @ObservedObject var editorCore: EditorCore
    
    @State private var isHovered = false
    @State private var showingRenameAlert = false
    @State private var newName = ""
    
    private var isExpanded: Bool {
        fileNavigator.expandedPaths.contains(node.url.path)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Row content
            HStack(spacing: 4) {
                // Indentation
                if level > 0 {
                    Spacer()
                        .frame(width: CGFloat(level) * 16)
                }
                
                // Expand/collapse button for directories
                if node.isDirectory {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            fileNavigator.toggleExpanded(path: node.url.path)
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption2)
                            .frame(width: 12)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer().frame(width: 12)
                }
                
                // File/folder icon
                Image(systemName: node.isDirectory ? (isExpanded ? "folder.fill" : "folder") : "doc")
                    .foregroundColor(node.isDirectory ? .blue : .gray)
                    .frame(width: 16)
                
                // Name
                Text(node.name)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(isHovered ? Color.gray.opacity(0.2) : Color.clear)
            .contentShape(Rectangle())
            .modifier(DraggableToFileModifier(fileURL: node.url, isDirectory: node.isDirectory))
            .onTapGesture {
                if node.isDirectory {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        fileNavigator.toggleExpanded(path: node.url.path)
                    }
                } else {
                    editorCore.openFile(from: node.url)
                }
            }
            .onHover { hovering in
                isHovered = hovering
            }
            .contextMenu {
                // New File
                Button {
                    // TODO: Add createFile method to FileSystemNavigator
                    // fileNavigator.createFile(in: node.isDirectory ? node.url : node.url.deletingLastPathComponent())
                } label: {
                    Label("New File", systemImage: "doc.badge.plus")
                }
                
                // New Folder
                Button {
                    // TODO: Add createFolder method to FileSystemNavigator
                    // fileNavigator.createFolder(in: node.isDirectory ? node.url : node.url.deletingLastPathComponent())
                } label: {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }
                
                // Rename
                Button {
                    newName = node.name
                    showingRenameAlert = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                
                Divider()
                
                // Delete
                Button(role: .destructive) {
                    // TODO: Add deleteItem method to FileSystemNavigator
                    // fileNavigator.deleteItem(at: node.url)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Divider()
                
                // Copy Path
                Button {
                    #if os(iOS)
                    UIPasteboard.general.string = node.url.path
                    #elseif os(macOS)
                    NSPasteboard.general.setString(node.url.path, forType: .string)
                    #endif
                } label: {
                    Label("Copy Path", systemImage: "doc.on.doc")
                }
                
                // Reveal in Finder
                #if os(macOS)
                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([node.url])
                } label: {
                    Label("Reveal in Finder", systemImage: "folder")
                }
                #endif
            }
            .alert("Rename", isPresented: $showingRenameAlert) {
                TextField("Name", text: $newName)
                Button("Cancel", role: .cancel) { }
                Button("Rename") {
                    // TODO: Add renameItem method to FileSystemNavigator
                    // fileNavigator.renameItem(at: node.url, to: newName)
                }
            }
            
            // Children
            if node.isDirectory && isExpanded {
                ForEach(node.children.sorted(by: { lhs, rhs in
                    // Directories first, then alphabetical
                    if lhs.isDirectory != rhs.isDirectory {
                        return lhs.isDirectory
                    }
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                })) { child in
                    FileTreeRowView(
                        node: child,
                        level: level + 1,
                        fileNavigator: fileNavigator,
                        editorCore: editorCore
                    )
                }
            }
        }
    }
}

// MARK: - Draggable To File Modifier

struct DraggableToFileModifier: ViewModifier {
    let fileURL: URL
    let isDirectory: Bool
    
    func body(content: Content) -> some View {
        if !isDirectory {
            content.onDrag {
                NSItemProvider(object: fileURL.path as NSString)
            }
        } else {
            content
        }
    }
}

// MARK: - Draggable To New Window Modifier

extension View {
    func draggableToNewWindow(fileURL: URL) -> some View {
        self.onDrag {
            NSItemProvider(object: fileURL.path as NSString)
        }
    }
}

// MARK: - UTType Extension

extension UTType {
    static let vscodeFilePathPayload = UTType(exportedAs: "com.vscode.ipados.filepath")
}
