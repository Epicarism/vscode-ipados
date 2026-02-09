import SwiftUI

struct StickyHeaderView: View {
    let text: String
    let currentLine: Int
    let theme: Theme
    let lineHeight: CGFloat
    let onSelect: (Int) -> Void
    
    @State private var stickyLines: [(line: Int, content: String, depth: Int)] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(stickyLines, id: \.line) { item in
                HStack {
                    Text(item.content.trimmingCharacters(in: .whitespaces))
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
        .onChange(of: currentLine) { _ in updateStickyLines() }
        .onAppear { updateStickyLines() }
    }
    
    private func updateStickyLines() {
        // Simplified logic: scan upwards from currentLine for class/func definitions
        // In a real app, use AST or Symbol Table
        
        let lines = text.components(separatedBy: .newlines)
        guard currentLine < lines.count else { return }
        
        var found: [(line: Int, content: String, depth: Int)] = []
        var minIndent = Int.max
        
        // Scan upwards
        for i in stride(from: currentLine, through: 0, by: -1) {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty || trimmed.hasPrefix("//") { continue }
            
            let indent = line.prefix(while: { $0 == " " }).count / 4
            
            // Heuristic: declarations usually have less indentation than current scope
            // and contain keywords
            if indent < minIndent {
                if trimmed.hasPrefix("class ") || 
                   trimmed.hasPrefix("struct ") || 
                   trimmed.hasPrefix("enum ") || 
                   trimmed.hasPrefix("func ") || 
                   trimmed.hasPrefix("extension ") ||
                   trimmed.contains(" body: some View") {
                    
                    found.insert((i, line, indent), at: 0)
                    minIndent = indent
                }
            }
            
            if minIndent == 0 { break }
        }
        
        // Limit to 3 levels to avoid clutter
        if found.count > 3 {
            found = Array(found.suffix(3))
        }
        
        self.stickyLines = found
    }
}