import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension FileManager {
    func documentsDirectory() -> URL {
        guard let url = urls(for: .documentDirectory, in: .userDomainMask).first else {
            return URL(fileURLWithPath: NSTemporaryDirectory())
        }
        return url
    }

    func createProjectStructure(at url: URL) throws {
        try createDirectory(at: url, withIntermediateDirectories: true)
        
        // Create src directory
        let srcDir = url.appendingPathComponent("src")
        try createDirectory(at: srcDir, withIntermediateDirectories: true)
        
        // Create index.html
        let indexHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>My Project</title>
            <link rel="stylesheet" href="src/style.css">
        </head>
        <body>
            <h1>Welcome to Your Project</h1>
            <script src="src/script.js"></script>
        </body>
        </html>
        """
        try indexHTML.write(to: url.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)
        
        // Create style.css
        let styleCSS = """
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            margin: 40px;
            background-color: #f5f5f7;
        }
        
        h1 {
            color: #1d1d1f;
        }
        """
        try styleCSS.write(to: srcDir.appendingPathComponent("style.css"), atomically: true, encoding: .utf8)
        
        // Create script.js
        let scriptJS = """
        console.log('Project initialized!');
        
        // Your code here
        """
        try scriptJS.write(to: srcDir.appendingPathComponent("script.js"), atomically: true, encoding: .utf8)
    }

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
            return FileIcons.icon(forDirectory: lastPathComponent)
        }
        return FileIcons.icon(for: lastPathComponent)
    }
    
    var iconColor: Color {
        if isDirectory {
            return FileIcons.directoryColor
        }
        return FileIcons.color(for: lastPathComponent)
    }
}
