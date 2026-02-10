import SwiftUI

struct FileIconView: View {
    let filename: String
    let isDirectory: Bool
    let isOpen: Bool
    
    init(filename: String, isDirectory: Bool = false, isOpen: Bool = false) {
        self.filename = filename
        self.isDirectory = isDirectory
        self.isOpen = isOpen
    }
    
    var body: some View {
        Group {
            if isDirectory {
                folderIcon
            }
            else {
                fileIcon
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var folderIcon: some View {
        Image(systemName: isOpen ? "folder.fill" : "folder")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.blue)
    }
    
    private var fileIcon: some View {
        let ext = (filename as NSString).pathExtension.lowercased()
        let fullLower = filename.lowercased()
        
        // Exact filename matches
        if fullLower == "dockerfile" {
            return AnyView(icon(systemName: "shippingbox.fill", color: .blue))
        }
        if fullLower == ".gitignore" {
            return AnyView(icon(systemName: "eye.slash.fill", color: .gray))
        }
        if fullLower == "package.json" {
            return AnyView(icon(systemName: "shippingbox.fill", color: .red))
        }
        if fullLower.starts(with: "readme") {
            return AnyView(icon(systemName: "book.fill", color: .blue))
        }
        if fullLower.starts(with: "license") {
            return AnyView(icon(systemName: "key.fill", color: .yellow))
        }
        
        // Extension matches
        switch ext {
        case "swift":
            return AnyView(badgeIcon(text: "SW", color: .orange))
        case "js":
            return AnyView(badgeIcon(text: "JS", color: .yellow))
        case "ts":
            return AnyView(badgeIcon(text: "TS", color: .blue))
        case "jsx":
            return AnyView(badgeIcon(text: "JSX", color: .cyan))
        case "tsx":
            return AnyView(badgeIcon(text: "TSX", color: .cyan))
        case "py":
            return AnyView(badgeIcon(text: "PY", color: Color(red: 0.2, green: 0.4, blue: 0.6)))
        case "rb":
            return AnyView(badgeIcon(text: "RB", color: .red))
        case "go":
            return AnyView(badgeIcon(text: "GO", color: .cyan))
        case "rs":
            return AnyView(badgeIcon(text: "RS", color: .orange))
        case "java":
            return AnyView(badgeIcon(text: "JA", color: .red))
        case "kt":
            return AnyView(badgeIcon(text: "KT", color: .purple))
        case "c":
            return AnyView(badgeIcon(text: "C", color: .blue))
        case "cpp", "cc", "cxx":
            return AnyView(badgeIcon(text: "C++", color: .blue))
        case "h", "hpp":
            return AnyView(badgeIcon(text: "H", color: .purple))
        case "m":
            return AnyView(badgeIcon(text: "M", color: .gray))
        case "html":
            return AnyView(icon(systemName: "chevron.left.forwardslash.chevron.right", color: .orange))
        case "css":
            return AnyView(icon(systemName: "number", color: .blue))
        case "scss":
            return AnyView(icon(systemName: "paintbrush.fill", color: .pink))
        case "json":
            return AnyView(badgeIcon(text: "{}", color: .yellow))
        case "xml":
            return AnyView(icon(systemName: "chevron.left.forwardslash.chevron.right", color: .green))
        case "yaml", "yml":
            return AnyView(badgeIcon(text: "YML", color: .purple))
        case "md":
            return AnyView(icon(systemName: "doc.text.fill", color: .blue))
        case "txt":
            return AnyView(icon(systemName: "doc.text", color: .gray))
        case "pdf":
            return AnyView(icon(systemName: "doc.fill", color: .red))
        case "png", "jpg", "jpeg", "svg", "gif":
            return AnyView(icon(systemName: "photo.fill", color: .purple))
        case "sh", "bash", "zsh":
            return AnyView(icon(systemName: "terminal.fill", color: .green))
        case "sql":
            return AnyView(icon(systemName: "server.rack", color: .blue))
        default:
            return AnyView(icon(systemName: "doc", color: .secondary))
        }
    }
    
    private func icon(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(color)
    }
    
    private func badgeIcon(text: String, color: Color) -> some View {
        ZStack {
            Image(systemName: "doc.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(color)
            
            GeometryReader { geo in
                Text(text)
                    .font(.system(size: geo.size.height * 0.35, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.6)
            }
        }
    }
}

struct FileIconView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                FileIconView(filename: "main.swift")
                FileIconView(filename: "app.ts")
                FileIconView(filename: "index.html")
                FileIconView(filename: "style.css")
            }
            .frame(height: 50)
            
            HStack {
                FileIconView(filename: "Docker", isDirectory: true)
                FileIconView(filename: "Dockerfile")
                FileIconView(filename: "README.md")
                FileIconView(filename: "image.png")
            }
            .frame(height: 50)
        }
        .padding()
    }
}
