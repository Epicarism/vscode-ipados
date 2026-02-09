import SwiftUI

func fileIcon(for filename: String) -> String {
    let ext = (filename as NSString).pathExtension.lowercased()
    switch ext {
    case "swift": return "swift"
    case "js", "jsx", "ts", "tsx": return "curlybraces"
    case "py": return "chevron.left.forwardslash.chevron.right"
    case "html", "htm": return "globe"
    case "css", "scss": return "paintbrush"
    case "json": return "curlybraces.square"
    case "md": return "doc.richtext"
    default: return "doc.text"
    }
}

func fileColor(for filename: String) -> Color {
    let ext = (filename as NSString).pathExtension.lowercased()
    switch ext {
    case "swift": return .orange
    case "js", "jsx": return .yellow
    case "ts", "tsx": return .blue
    case "py": return .green
    case "html", "htm": return .red
    case "css", "scss": return .purple
    case "json": return .green
    default: return .gray
    }
}