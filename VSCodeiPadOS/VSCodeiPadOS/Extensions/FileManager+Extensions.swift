import Foundation
import UniformTypeIdentifiers

extension FileManager {
    func createFileIfNeeded(at url: URL, contents: String = "") {
        if !fileExists(atPath: url.path) {
            try? contents.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    func isDirectory(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    func contentsOfDirectory(at url: URL, includingHidden: Bool = false) -> [URL] {
        guard let contents = try? contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: includingHidden ? [] : .skipsHiddenFiles) else {
            return []
        }
        return contents.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
    
    func createDirectory(at url: URL) {
        try? createDirectory(at: url, withIntermediateDirectories: true)
    }
}

// File type detection
extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
    }
    
    var fileType: UTType {
        UTType(filenameExtension: pathExtension) ?? .plainText
    }
    
    var icon: String {
        if isDirectory {
            return "folder.fill"
        }
        
        switch pathExtension.lowercased() {
        case "swift":
            return "swift"
        case "js", "javascript", "jsx":
            return "doc.text.fill"
        case "py", "python":
            return "doc.text.fill"
        case "html", "htm":
            return "globe"
        case "css", "scss", "sass":
            return "paintbrush.fill"
        case "json":
            return "curlybraces"
        case "xml":
            return "chevron.left.forwardslash.chevron.right"
        case "md", "markdown":
            return "text.alignleft"
        case "png", "jpg", "jpeg", "gif", "webp":
            return "photo.fill"
        case "mp4", "mov", "avi":
            return "video.fill"
        case "mp3", "wav", "aac":
            return "music.note"
        case "pdf":
            return "doc.richtext.fill"
        case "zip", "tar", "gz":
            return "archivebox.fill"
        default:
            return "doc.text.fill"
        }
    }
    
    var iconColor: String {
        if isDirectory {
            return "blue"
        }
        
        switch pathExtension.lowercased() {
        case "swift":
            return "orange"
        case "js", "javascript", "jsx":
            return "yellow"
        case "py", "python":
            return "blue"
        case "html", "htm":
            return "orange"
        case "css", "scss", "sass":
            return "purple"
        case "json":
            return "green"
        case "xml":
            return "orange"
        case "md", "markdown":
            return "gray"
        case "png", "jpg", "jpeg", "gif", "webp":
            return "green"
        case "mp4", "mov", "avi":
            return "purple"
        case "mp3", "wav", "aac":
            return "pink"
        case "pdf":
            return "red"
        case "zip", "tar", "gz":
            return "brown"
        default:
            return "gray"
        }
    }
}
