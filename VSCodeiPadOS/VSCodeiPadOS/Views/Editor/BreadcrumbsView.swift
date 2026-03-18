import SwiftUI

struct BreadcrumbsView: View {
    @ObservedObject var editorCore: EditorCore
    let tab: Tab
    
    var pathComponents: [String] {
        if let url = tab.url {
            return url.pathComponents.filter { $0 != "/" }
        }
        // For untitled files, use the first path component from the URL or a generic name
        let folderName = tab.url?.deletingLastPathComponent().lastPathComponent ?? "Workspace"
        return [folderName, tab.fileName]
    }
    
    /// Attempt to detect the current symbol name from the file content near the cursor
    var currentSymbolName: String {
        let content = tab.content
        guard !content.isEmpty else { return tab.fileName.components(separatedBy: ".").first ?? tab.fileName }
        
        let lines = content.components(separatedBy: .newlines)
        let cursorLine = max(0, min(editorCore.cursorPosition.line, lines.count - 1))
        
        // Search backwards from cursor to find the nearest symbol declaration
        let symbolPatterns = [
            // Swift
            "(class|struct|enum|protocol|extension|func|var|let)\\s+(\\w+)",
            // JS/TS
            "(function|class|const|let|var|interface|type)\\s+(\\w+)",
            // Python
            "(def|class)\\s+(\\w+)",
            // Rust
            "(fn|struct|enum|impl|trait|mod)\\s+(\\w+)",
        ]
        let combinedPattern = symbolPatterns.joined(separator: "|")
        guard let regex = try? NSRegularExpression(pattern: combinedPattern) else {
            return tab.fileName.components(separatedBy: ".").first ?? tab.fileName
        }
        
        // Search backwards from cursor line
        for lineIdx in stride(from: cursorLine, through: max(0, cursorLine - 100), by: -1) {
            guard lineIdx < lines.count else { continue }
            let line = lines[lineIdx]
            let nsLine = line as NSString
            if let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: nsLine.length)) {
                // Find the last non-empty capture group (the name)
                for groupIdx in stride(from: match.numberOfRanges - 1, through: 1, by: -1) {
                    let range = match.range(at: groupIdx)
                    if range.location != NSNotFound {
                        return nsLine.substring(with: range)
                    }
                }
            }
        }
        
        return tab.fileName.components(separatedBy: ".").first ?? tab.fileName
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(Array(pathComponents.enumerated()), id: \.offset) { index, component in
                    let isLast = index == pathComponents.count - 1
                    
                    // Breadcrumb item
                    HStack(spacing: 4) {
                        if index == 0 {
                            Image(systemName: "folder")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else if isLast {
                            Image(systemName: fileIcon(for: component))
                                .font(.caption2)
                                .foregroundColor(fileColor(for: component))
                        }
                        
                        Text(component)
                            .font(.system(size: 11))
                            .foregroundColor(isLast ? .primary : .secondary)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Navigate to \(component)")
                    .accessibilityHint("Navigate to folder/file name")
                    .onTapGesture {
                        if isLast {
                            return
                        }
                        let dirPath = "/" + pathComponents[...index].joined(separator: "/")

                        NotificationCenter.default.post(
                            name: Notification.Name("navigateToDirectory"),
                            object: nil,
                            userInfo: ["path": dirPath]
                        )
                    }
                    
                    // Separator
                    if !isLast {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding(.horizontal, 2)
                    }
                }
                
                // Current symbol
                Image(systemName: "chevron.right")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary.opacity(0.5))
                    .padding(.horizontal, 2)
                    
                HStack(spacing: 2) {
                    Image(systemName: "curlybraces")
                        .font(.caption2)
                        .foregroundColor(.purple)
                    Text(currentSymbolName)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 26)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
        .overlay(Divider(), alignment: .bottom)
    }
}
