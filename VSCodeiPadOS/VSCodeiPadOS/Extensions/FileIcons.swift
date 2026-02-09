import SwiftUI

func fileIcon(for filename: String, isDirectory: Bool = false, isExpanded: Bool = false) -> String {
    if isDirectory {
        return isExpanded ? "folder.fill.badge.minus" : "folder.fill"
    }
    
    // Special files check (exact match)
    switch filename {
    case "package.json": return "shippingbox.fill"
    case "package-lock.json": return "lock.fill"
    case "tsconfig.json": return "gearshape.fill"
    case ".gitignore": return "eye.slash"
    case "README.md": return "book.fill"
    case "LICENSE": return "doc.badge.ellipsis"
    case "Dockerfile": return "shippingbox"
    case ".env": return "key.fill"
    case "Makefile": return "hammer.fill"
    case "Podfile": return "p.circle.fill"
    case "Gemfile": return "diamond.fill"
    case "Cargo.toml": return "gearshape.2.fill"
    default: break
    }
    
    let ext = (filename as NSString).pathExtension.lowercased()
    
    switch ext {
    case "swift": return "swift"
    case "js", "jsx": return "curlybraces"
    case "ts", "tsx": return "curlybraces"
    case "py": return "chevron.left.forwardslash.chevron.right"
    case "rb": return "diamond.fill"
    case "go": return "g.circle"
    case "rs": return "gearshape.2"
    case "java": return "cup.and.saucer.fill"
    case "c", "cpp", "h", "hpp", "cc": return "c.circle"
    case "cs": return "number"
    case "php": return "p.circle"
    case "html", "htm": return "globe"
    case "css", "scss", "sass": return "paintbrush.fill"
    case "json": return "curlybraces.square"
    case "yaml", "yml": return "doc.text"
    case "xml": return "chevron.left.forwardslash.chevron.right"
    case "md", "markdown": return "doc.richtext"
    case "sh", "bash", "zsh": return "terminal"
    case "sql": return "cylinder"
    case "graphql", "gql": return "circle.hexagongrid"
    case "dockerfile": return "shippingbox"
    case "png", "jpg", "jpeg", "gif", "svg", "bmp", "tiff", "ico": return "photo"
    case "mp4", "mov", "avi", "mkv", "webm": return "film"
    case "mp3", "wav", "aac", "flac", "m4a": return "speaker.wave.2"
    case "zip", "tar", "gz", "rar", "7z": return "archivebox"
    case "ttf", "otf", "woff", "woff2": return "textformat"
    case "pdf": return "doc.fill"
    case "conf", "config", "ini", "cfg": return "gearshape"
    default: return "doc.text"
    }
}

func fileColor(for filename: String, isDirectory: Bool = false) -> Color {
    if isDirectory {
        return .yellow
    }
    
    // Special files check
    switch filename {
    case "package.json": return .green
    case "package-lock.json": return .gray
    case "tsconfig.json": return .blue
    case ".gitignore": return .gray
    case "README.md": return .blue
    case "LICENSE": return .gray
    case "Dockerfile": return .blue
    case ".env": return .yellow
    case "Makefile": return .gray
    case "Podfile": return .orange
    case "Gemfile": return .red
    case "Cargo.toml": return .orange
    default: break
    }
    
    let ext = (filename as NSString).pathExtension.lowercased()
    
    switch ext {
    case "swift": return .orange
    case "js", "jsx": return .yellow
    case "ts", "tsx": return .blue
    case "py": return .blue
    case "rb": return .red
    case "go": return .cyan
    case "rs": return .orange
    case "java": return .red
    case "c", "cpp", "h", "hpp", "cc": return .blue
    case "cs": return .purple
    case "php": return .purple
    case "html", "htm": return .orange
    case "css", "scss", "sass": return .purple
    case "json": return .yellow
    case "yaml", "yml": return .red
    case "xml": return .orange
    case "md", "markdown": return .blue
    case "sh", "bash", "zsh": return .green
    case "sql": return .blue
    case "graphql", "gql": return .pink
    case "dockerfile": return .blue
    case "png", "jpg", "jpeg", "gif", "svg", "bmp", "tiff", "ico": return .purple
    case "mp4", "mov", "avi", "mkv", "webm": return .red
    case "mp3", "wav", "aac", "flac", "m4a": return .green
    case "zip", "tar", "gz", "rar", "7z": return .brown
    case "ttf", "otf", "woff", "woff2": return .gray
    case "pdf": return .red
    case "conf", "config", "ini", "cfg": return .gray
    default: return .gray
    }
}
