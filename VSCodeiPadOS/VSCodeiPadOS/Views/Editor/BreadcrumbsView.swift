import SwiftUI

struct BreadcrumbsView: View {
    @ObservedObject var editorCore: EditorCore
    let tab: Tab

    // PERF: Static regex — compiled once instead of on every render
    private static let symbolRegex: NSRegularExpression? = {
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
        return try? NSRegularExpression(pattern: symbolPatterns.joined(separator: "|"))
    }()
    
    var pathComponents: [String] {
        if let url = tab.url {
            return url.pathComponents.filter { $0 != "/" }
        }
        // For untitled files, use the first path component from the URL or a generic name
        let folderName = tab.url?.deletingLastPathComponent().lastPathComponent ?? "Workspace"
        return [folderName, tab.fileName]
    }
    
    /// Attempt to detect the current symbol name from the file content near the cursor.
    /// PERF: Uses targeted line extraction instead of splitting the entire document.
    var currentSymbolName: String {
        let content = tab.content
        guard !content.isEmpty else { return tab.fileName.components(separatedBy: ".").first ?? tab.fileName }
        guard let regex = Self.symbolRegex else { return tab.fileName.components(separatedBy: ".").first ?? tab.fileName }
        
        let cursorLine = editorCore.cursorPosition.line
        let searchStart = max(0, cursorLine - 100)
        
        // PERF: Extract only lines [searchStart...cursorLine] instead of splitting entire document
        let lines = extractLinesRange(from: content, start: searchStart, through: cursorLine)
        
        // Search backwards from cursor to find the nearest symbol declaration
        for lineIdx in stride(from: lines.count - 1, through: 0, by: -1) {
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

    /// PERF: Extract lines in range [start...through] without splitting the entire document.
    private func extractLinesRange(from text: String, start startLine: Int, through endLine: Int) -> [String] {
        var lines: [String] = []
        lines.reserveCapacity(endLine - startLine + 1)
        var currentLine = 0
        var lineStart = text.startIndex
        var i = text.startIndex
        while i < text.endIndex {
            if text[i] == "\n" {
                if currentLine >= startLine && currentLine <= endLine {
                    lines.append(String(text[lineStart..<i]))
                }
                if currentLine >= endLine { return lines }
                currentLine += 1
                lineStart = text.index(after: i)
            }
            i = text.index(after: i)
        }
        // Last line
        if currentLine >= startLine && currentLine <= endLine {
            lines.append(String(text[lineStart..<text.endIndex]))
        }
        return lines
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
