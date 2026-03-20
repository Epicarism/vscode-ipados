import SwiftUI

struct StickyHeaderView: View {
    let text: String
    let currentLine: Int
    let theme: Theme
    let lineHeight: CGFloat
    let onSelect: (Int) -> Void
    
    @State private var stickyLines: [(line: Int, content: String, depth: Int)] = []
    @State private var updateTask: Task<Void, Never>?

    // Declaration prefixes — iterated with hasPrefix (Set gives dedup, not O(1) prefix matching)
    private static let declarationPrefixes: Set<String> = [
        // Swift
        "class ", "struct ", "enum ", "func ", "extension ", "protocol ",
        // JavaScript / TypeScript
        "function ", "const ", "export ", "module ", "async function ", "var ", "let ",
        // Python
        "def ", "async def ",
        // Rust
        "fn ", "impl ", "trait ", "mod ",
        "pub fn ", "pub struct ", "pub enum ", "pub trait ", "pub mod ", "pub async fn ",
        // Go
        "type ", "package ", "import ",
        // C / C++
        "void ", "int ", "namespace ", "template ", "typedef ",
        // Ruby
        "require ", "attr_",
        // Java / Kotlin
        "interface ", "fun ", "public ", "private ", "protected ",
        "object ", "companion object ",
    ]

    /// Check if a trimmed, lowercased line looks like a declaration
    private static func isDeclaration(_ trimmed: String) -> Bool {
        // Special checks that aren't simple prefix matches
        if trimmed.hasPrefix("@") { return true }
        if trimmed.hasPrefix("#include") || trimmed.hasPrefix("#define") { return true }
        if trimmed.contains(" body: some View") { return true }
        // Check known prefixes
        let lower = trimmed.lowercased()
        for prefix in declarationPrefixes {
            if lower.hasPrefix(prefix) { return true }
        }
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(stickyLines, id: \.line) { item in
                HStack {
                    Text(item.content)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.editorForeground)
                        .padding(.leading, CGFloat(item.depth) * 16 + 4)
                        .padding(.vertical, 2)
                    Spacer()
                }
                .frame(height: lineHeight)
                .background(theme.editorBackground.opacity(0.95))
                .overlay(Rectangle().frame(height: 1).foregroundColor(theme.sidebarBackground), alignment: .bottom)
                .onTapGesture {
                    onSelect(item.line)
                }
            }
        }
        .onChange(of: currentLine) { _, _ in updateStickyLines() }
        .onChange(of: text) { _, _ in
            updateTask?.cancel()
            updateTask = Task {
                try? await Task.sleep(nanoseconds: 200_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { updateStickyLines() }
            }
        }
        .onAppear { updateStickyLines() }
    }
    
    private func updateStickyLines() {
        // PERF: Extract only lines 0...currentLine instead of splitting entire document.
        // For a 1M-line file with cursor at line 500, this only scans 500 lines, not 1M.
        let lines = extractLines(from: text, through: currentLine)
        guard currentLine < lines.count else { return }
        
        var found: [(line: Int, content: String, depth: Int)] = []
        var minIndent = Int.max
        
        // Scan upwards
        for i in stride(from: min(currentLine, lines.count - 1), through: 0, by: -1) {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty || trimmed.hasPrefix("//") { continue }
            
            let spaceCount = line.prefix(while: { $0 == " " || $0 == "\t" }).reduce(0) { $0 + ($1 == "\t" ? 4 : 1) }
            let indent = spaceCount / 4
            
            if indent < minIndent {
                if Self.isDeclaration(trimmed) {
                    found.append((i, trimmed, indent))
                    minIndent = indent
                }
            }
            
            if minIndent == 0 { break }
        }
        
        // Reverse since we scanned backwards (avoids O(n) insert-at-0)
        found.reverse()
        
        // Limit to 3 levels to avoid clutter
        if found.count > 3 {
            found = Array(found.suffix(3))
        }
        
        self.stickyLines = found
    }

    /// PERF: Extract lines 0...throughLine without splitting the entire document.
    /// Returns an array of line strings up to and including the target line.
    private func extractLines(from text: String, through targetLine: Int) -> [String] {
        var lines: [String] = []
        lines.reserveCapacity(min(targetLine + 1, 1000))
        var lineStart = text.startIndex
        var currentLine = 0
        var i = text.startIndex
        while i < text.endIndex {
            if text[i] == "\n" {
                lines.append(String(text[lineStart..<i]))
                if currentLine >= targetLine { return lines }
                currentLine += 1
                lineStart = text.index(after: i)
            }
            i = text.index(after: i)
        }
        // Last line
        if currentLine <= targetLine {
            lines.append(String(text[lineStart..<text.endIndex]))
        }
        return lines
    }
}
