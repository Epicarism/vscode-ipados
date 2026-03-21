import SwiftUI

struct StickyHeaderView: View {
    let text: String
    let currentLine: Int
    let theme: Theme
    let lineHeight: CGFloat
    var foldRegions: [FoldRegion] = []
    let onSelect: (Int) -> Void
    
    @State private var stickyLines: [(line: Int, content: String, depth: Int, foldType: FoldRegion.FoldType?)] = []
    @State private var previousStickyLineCount: Int = 0
    @State private var updateTask: Task<Void, Never>?
    
    /// Maximum number of sticky header lines shown simultaneously
    private static let maxStickyLines = 3

    /// Declaration prefixes — iterated with hasPrefix (Set gives dedup, not O(1) prefix matching)
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

    /// Fold types that are relevant for sticky scope headers (skip comments, imports, regions)
    private static let scopeRelevantTypes: Set<FoldRegion.FoldType> = [
        .function,
        .classOrStruct,
        .extension,
        .enumDeclaration,
        .protocolDeclaration,
        .controlFlow,
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
                HStack(spacing: 0) {
                    // Scope icon based on fold type
                    scopeIcon(for: item.foldType)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(scopeIconColor(for: item.foldType))
                        .frame(width: 16, alignment: .center)
                    
                    Text(item.content)
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.editorForeground.opacity(0.85))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.leading, CGFloat(item.depth) * 12 + 2)
                        .padding(.vertical, 2)
                    
                    Spacer()
                }
                .frame(height: lineHeight)
                .background(
                    Rectangle()
                        .fill(stickyHeaderBackground(for: item.depth, total: stickyLines.count))
                )
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(theme.editorForeground.opacity(0.08)),
                    alignment: .bottom
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(item.line)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
                .animation(.easeInOut(duration: 0.15), value: item.line)
            }
        }
        .clipped()
        .onChange(of: currentLine) { _, _ in
            scheduleUpdate()
        }
        .onChange(of: text) { _, _ in
            updateTask?.cancel()
            updateTask = Task {
                try? await Task.sleep(nanoseconds: 200_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { updateStickyLines() }
            }
        }
        .onChange(of: foldRegions.count) { _, _ in
            updateTask?.cancel()
            updateTask = Task {
                try? await Task.sleep(nanoseconds: 100_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { updateStickyLines() }
            }
        }
        .onAppear { updateStickyLines() }
    }
    
    // MARK: - Scope Icon
    
    @ViewBuilder
    private func scopeIcon(for foldType: FoldRegion.FoldType?) -> some View {
        if let type = foldType {
            Text(iconForType(type))
        } else {
            Text("·")
        }
    }
    
    private func iconForType(_ type: FoldRegion.FoldType) -> String {
        switch type {
        case .function: return "ƒ"
        case .classOrStruct: return "C"
        case .extension: return "E"
        case .enumDeclaration: return "E"
        case .protocolDeclaration: return "P"
        case .controlFlow: return "◆"
        case .comment: return "//"
        case .region: return "#"
        case .importStatement: return "i"
        case .genericBlock: return "{"
        }
    }

    private func scopeIconColor(for foldType: FoldRegion.FoldType?) -> Color {
        guard let type = foldType else { return theme.editorForeground.opacity(0.5) }
        switch type {
        case .function: return theme.function
        case .classOrStruct, .extension, .enumDeclaration: return theme.type
        case .protocolDeclaration: return theme.keyword
        case .controlFlow: return theme.keyword
        default: return theme.editorForeground.opacity(0.5)
        }
    }
    
    // MARK: - Background Styling (VS Code-inspired)
    
    /// Returns a slightly darker background for sticky headers, getting darker for outer scopes
    private func stickyHeaderBackground(for depth: Int, total: Int) -> Color {
        // VS Code sticky headers have a slightly darker background than the editor
        // Outermost scope gets the darkest tint; inner scopes are slightly lighter
        let baseOpacity = 0.06 + Double(total - depth) * 0.02
        return theme.editorForeground.opacity(min(baseOpacity, 0.15))
    }
    
    // MARK: - Update Logic
    
    private func scheduleUpdate() {
        updateTask?.cancel()
        updateTask = Task {
            try? await Task.sleep(nanoseconds: 50_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { updateStickyLines() }
        }
    }
    
    private func updateStickyLines() {
        // Strategy: Use fold regions when available for accurate scope boundaries,
        // fall back to text-based indentation scanning otherwise.
        
        if !foldRegions.isEmpty {
            updateFromFoldRegions()
        } else {
            updateFromTextScan()
        }
        
        // Update animation tracking
        previousStickyLineCount = stickyLines.count
    }
    
    /// Update sticky lines using CodeFoldingManager's fold regions for accurate scope boundaries.
    /// This approach is more precise than text scanning — it uses actual parsed fold regions
    /// to determine which scopes contain the current line.
    private func updateFromFoldRegions() {
        // Filter to scope-relevant types only (skip comments, imports, regions)
        let scopeRegions = foldRegions.filter { Self.scopeRelevantTypes.contains($0.type) }
        
        // Find all fold regions that contain the current line
        // A region contains the line if: startLine <= currentLine <= endLine
        let containingRegions = scopeRegions.filter {
            $0.startLine <= currentLine && $0.endLine >= currentLine
        }
        
        // Build the content lines from the text
        let lines = extractLines(from: text, through: currentLine + 20)
        
        // Sort containing regions by startLine (earlier = outer scope, later = deeper nesting)
        let sorted = containingRegions.sorted { $0.startLine < $1.startLine }
        
        var result: [(line: Int, content: String, depth: Int, foldType: FoldRegion.FoldType?)] = []
        
        for (index, region) in sorted.enumerated() {
            guard region.startLine < lines.count else { continue }
            let content = lines[region.startLine].trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines and single-line scopes
            guard !content.isEmpty && (region.endLine - region.startLine) > 1 else { continue }
            
            result.append((
                line: region.startLine,
                content: content,
                depth: index,
                foldType: region.type
            ))
        }
        
        // Limit to max sticky lines (keep the deepest/most-relevant ones)
        if result.count > Self.maxStickyLines {
            result = Array(result.suffix(Self.maxStickyLines))
        }
        
        // Recalculate depth after truncation
        result = result.enumerated().map { (i, item) in
            (line: item.line, content: item.content, depth: i, foldType: item.foldType)
        }
        
        self.stickyLines = result
    }
    
    /// Fallback: update sticky lines by scanning text for declaration indentation.
    /// Used when CodeFoldingManager hasn't detected fold regions yet.
    private func updateFromTextScan() {
        let lines = extractLines(from: text, through: currentLine)
        guard currentLine < lines.count else { return }
        
        var found: [(line: Int, content: String, depth: Int, foldType: FoldRegion.FoldType?)] = []
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
                    let inferredType = inferFoldType(from: trimmed)
                    found.append((i, trimmed, indent, inferredType))
                    minIndent = indent
                }
            }
            
            if minIndent == 0 { break }
        }
        
        // Reverse since we scanned backwards (avoids O(n) insert-at-0)
        found.reverse()
        
        // Limit to max sticky lines
        if found.count > Self.maxStickyLines {
            found = Array(found.suffix(Self.maxStickyLines))
        }
        
        // Recalculate depth after truncation
        found = found.enumerated().map { (i, item) in
            (line: item.line, content: item.content, depth: i, foldType: item.foldType)
        }
        
        self.stickyLines = found
    }
    
    /// Infer fold type from a declaration line's text content
    private func inferFoldType(from trimmed: String) -> FoldRegion.FoldType? {
        let lower = trimmed.lowercased()
        if lower.contains("func ") || lower.contains("fn ") || lower.contains("def ") {
            return .function
        }
        if lower.contains("class ") || lower.contains("struct ") {
            return .classOrStruct
        }
        if lower.contains("enum ") {
            return .enumDeclaration
        }
        if lower.contains("protocol ") {
            return .protocolDeclaration
        }
        if lower.contains("extension ") {
            return .extension
        }
        if lower.hasPrefix("if ") || lower.hasPrefix("guard ") ||
           lower.hasPrefix("for ") || lower.hasPrefix("while ") ||
           lower.hasPrefix("switch ") || lower.hasPrefix("do ") {
            return .controlFlow
        }
        return nil
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
