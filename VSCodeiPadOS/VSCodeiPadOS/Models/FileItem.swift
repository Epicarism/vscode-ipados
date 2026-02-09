import Foundation
import SwiftUI

/// Represents a file or directory in the file system
struct FileItem: Identifiable, Hashable {
    let id: UUID
    var name: String
    var url: URL?
    var path: String
    var isDirectory: Bool
    var children: [FileItem]?
    var isExpanded: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        url: URL? = nil,
        path: String = "",
        isDirectory: Bool = false,
        children: [FileItem]? = nil,
        isExpanded: Bool = false
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.path = path.isEmpty ? (url?.path ?? "") : path
        self.isDirectory = isDirectory
        self.children = children
        self.isExpanded = isExpanded
    }
    
    var fileExtension: String {
        (name as NSString).pathExtension.lowercased()
    }
    
    var icon: String {
        FileItem.getFileIcon(for: name, isDirectory: isDirectory, isExpanded: isExpanded)
    }
    
    var iconColor: Color {
        FileItem.getFileColor(for: name, isDirectory: isDirectory)
    }
    
    // MARK: - File Icon Helpers (inline to avoid dependency issues)
    
    static func getFileIcon(for filename: String, isDirectory: Bool = false, isExpanded: Bool = false) -> String {
        if isDirectory {
            return isExpanded ? "folder.fill.badge.minus" : "folder.fill"
        }
        
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "swift": return "swift"
        case "js", "jsx", "ts", "tsx": return "curlybraces"
        case "py": return "chevron.left.forwardslash.chevron.right"
        case "html", "htm": return "globe"
        case "css", "scss": return "paintbrush.fill"
        case "json": return "curlybraces.square"
        case "md", "markdown": return "doc.richtext"
        default: return "doc.text"
        }
    }
    
    static func getFileColor(for filename: String, isDirectory: Bool = false) -> Color {
        if isDirectory {
            return .yellow
        }
        
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "swift": return .orange
        case "js", "jsx": return .yellow
        case "ts", "tsx": return .blue
        case "py": return .green
        case "html", "htm": return .red
        case "css", "scss": return .purple
        case "json": return .green
        case "md", "markdown": return .blue
        default: return .gray
        }
    }
}
