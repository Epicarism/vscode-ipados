import SwiftUI

/// Canonical source of truth for file/directory icon names and colors.
/// All file icon and color lookups should go through `FileIcons`.
enum FileIcons {

    // MARK: - File Icon (by extension)

    /// Returns an SF Symbol name for the given file.
    static func icon(for fileName: String) -> String {
        // Special files (exact filename match)
        switch fileName {
        case "package.json":       return "shippingbox.fill"
        case "package-lock.json":  return "lock.fill"
        case "tsconfig.json":      return "gearshape.fill"
        case ".gitignore":         return "eye.slash"
        case "README.md":          return "book.fill"
        case "LICENSE":            return "doc.badge.ellipsis"
        case "Dockerfile":         return "shippingbox"
        case ".env":               return "key.fill"
        case "Makefile":           return "hammer.fill"
        case "Podfile":            return "p.circle.fill"
        case "Gemfile":            return "diamond.fill"
        case "Cargo.toml":         return "gearshape.2.fill"
        default: break
        }

        let ext = (fileName as NSString).pathExtension.lowercased()

        switch ext {
        // Programming languages
        case "swift":                              return "swift"
        case "js", "jsx":                          return "curlybraces"
        case "ts", "tsx":                          return "curlybraces"
        case "py":                                 return "chevron.left.forwardslash.chevron.right"
        case "rb":                                 return "diamond.fill"
        case "go":                                 return "g.circle"
        case "rs":                                 return "gearshape.2"
        case "java":                               return "cup.and.saucer.fill"
        case "c", "cpp", "h", "hpp", "cc":        return "c.circle"
        case "cs":                                 return "number"
        case "php":                                return "p.circle"

        // Markup / style
        case "html", "htm":                        return "globe"
        case "css", "scss", "sass":                return "paintbrush.fill"

        // Data formats
        case "json":                               return "curlybraces.square"
        case "yaml", "yml":                        return "doc.text"
        case "xml":                                return "chevron.left.forwardslash.chevron.right"

        // Documentation
        case "md", "markdown":                     return "doc.richtext"

        // Shell
        case "sh", "bash", "zsh":                  return "terminal"

        // Database
        case "sql":                                return "cylinder"

        // API
        case "graphql", "gql":                     return "circle.hexagongrid"

        // DevOps / config
        case "dockerfile":                         return "shippingbox"
        case "conf", "config", "ini", "cfg":       return "gearshape"

        // Images
        case "png", "jpg", "jpeg", "gif", "svg",
             "bmp", "tiff", "ico", "webp":         return "photo"

        // Video
        case "mp4", "mov", "avi", "mkv", "webm":   return "film"

        // Audio
        case "mp3", "wav", "aac", "flac", "m4a":   return "speaker.wave.2"

        // Archives
        case "zip", "tar", "gz", "rar", "7z":      return "archivebox"

        // Fonts
        case "ttf", "otf", "woff", "woff2":        return "textformat"

        // Documents
        case "pdf":                                return "doc.fill"

        default:                                   return "doc.text"
        }
    }

    // MARK: - File Color (by extension)

    /// Returns a `Color` for the given file.
    static func color(for fileName: String) -> Color {
        // Special files (exact filename match)
        switch fileName {
        case "package.json":       return .green
        case "package-lock.json":  return .gray
        case "tsconfig.json":      return .blue
        case ".gitignore":         return .gray
        case "README.md":          return .blue
        case "LICENSE":            return .gray
        case "Dockerfile":         return .blue
        case ".env":               return .yellow
        case "Makefile":           return .gray
        case "Podfile":            return .orange
        case "Gemfile":            return .red
        case "Cargo.toml":         return .orange
        default: break
        }

        let ext = (fileName as NSString).pathExtension.lowercased()

        switch ext {
        // Programming languages
        case "swift":                              return .orange
        case "js", "jsx":                          return .yellow
        case "ts", "tsx":                          return .blue
        case "py":                                 return .blue
        case "rb":                                 return .red
        case "go":                                 return .cyan
        case "rs":                                 return .orange
        case "java":                               return .red
        case "c", "cpp", "h", "hpp", "cc":        return .blue
        case "cs":                                 return .purple
        case "php":                                return .purple

        // Markup / style
        case "html", "htm":                        return .orange
        case "css", "scss", "sass":                return .purple

        // Data formats
        case "json":                               return .yellow
        case "yaml", "yml":                        return .red
        case "xml":                                return .orange

        // Documentation
        case "md", "markdown":                     return .blue

        // Shell
        case "sh", "bash", "zsh":                  return .green

        // Database
        case "sql":                                return .blue

        // API
        case "graphql", "gql":                     return .pink

        // DevOps / config
        case "dockerfile":                         return .blue
        case "conf", "config", "ini", "cfg":       return .gray

        // Images
        case "png", "jpg", "jpeg", "gif", "svg",
             "bmp", "tiff", "ico", "webp":         return .purple

        // Video
        case "mp4", "mov", "avi", "mkv", "webm":   return .red

        // Audio
        case "mp3", "wav", "aac", "flac", "m4a":   return .green

        // Archives
        case "zip", "tar", "gz", "rar", "7z":      return .brown

        // Fonts
        case "ttf", "otf", "woff", "woff2":        return .gray

        // Documents
        case "pdf":                                return .red

        default:                                   return .gray
        }
    }

    // MARK: - Directory Icon

    /// Returns an SF Symbol name for a directory.
    static func icon(forDirectory name: String, isExpanded: Bool = false) -> String {
        isExpanded ? "folder.fill.badge.minus" : "folder.fill"
    }

    // MARK: - Directory Color

    /// Returns the standard color used for directory icons.
    static let directoryColor: Color = .yellow
}

// MARK: - Backward-compatible free functions

/// Backward-compatible wrapper – prefer `FileIcons.icon(for:)`.
func fileIcon(for filename: String, isDirectory: Bool = false, isExpanded: Bool = false) -> String {
    if isDirectory {
        return FileIcons.icon(forDirectory: filename, isExpanded: isExpanded)
    }
    return FileIcons.icon(for: filename)
}

/// Backward-compatible wrapper – prefer `FileIcons.color(for:)`.
func fileColor(for filename: String, isDirectory: Bool = false) -> Color {
    if isDirectory {
        return FileIcons.directoryColor
    }
    return FileIcons.color(for: filename)
}
