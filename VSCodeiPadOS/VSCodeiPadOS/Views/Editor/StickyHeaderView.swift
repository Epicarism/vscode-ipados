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
        .onChange(of: currentLine) { _, _ in updateStickyLines() }
        .onAppear { updateStickyLines() }
    }
    
    private func updateStickyLines() {
        // Scan upwards from currentLine for declaration keywords
        // Supports: Swift, JavaScript/TypeScript, Python, Rust, Go, C/C++, Ruby, Java/Kotlin
        
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
            // Supports: Swift, JavaScript/TypeScript, Python, Rust, Go, C/C++, Ruby, Java/Kotlin
            if indent < minIndent {
                let lower = trimmed.lowercased()
                let isDeclaration =
                    // Swift
                    lower.hasPrefix("class ") ||
                    lower.hasPrefix("struct ") ||
                    lower.hasPrefix("enum ") ||
                    lower.hasPrefix("func ") ||
                    lower.hasPrefix("extension ") ||
                    lower.hasPrefix("protocol ") ||
                    trimmed.contains(" body: some View") ||
                    // JavaScript / TypeScript
                    lower.hasPrefix("function ") ||
                    lower.hasPrefix("class ") ||
                    lower.hasPrefix("const ") ||
                    lower.hasPrefix("export ") ||
                    lower.hasPrefix("module ") ||
                    lower.hasPrefix("async function ") ||
                    lower.hasPrefix("var ") ||
                    lower.hasPrefix("let ") ||
                    // Python
                    lower.hasPrefix("def ") ||
                    lower.hasPrefix("class ") ||
                    lower.hasPrefix("async def ") ||
                    lower.hasPrefix("@") ||
                    // Rust
                    lower.hasPrefix("fn ") ||
                    lower.hasPrefix("struct ") ||
                    lower.hasPrefix("enum ") ||
                    lower.hasPrefix("impl ") ||
                    lower.hasPrefix("trait ") ||
                    lower.hasPrefix("mod ") ||
                    lower.hasPrefix("pub fn ") ||
                    lower.hasPrefix("pub struct ") ||
                    lower.hasPrefix("pub enum ") ||
                    lower.hasPrefix("pub trait ") ||
                    lower.hasPrefix("pub mod ") ||
                    lower.hasPrefix("pub async fn ") ||
                    // Go
                    lower.hasPrefix("func ") ||
                    lower.hasPrefix("type ") ||
                    lower.hasPrefix("package ") ||
                    lower.hasPrefix("import ") ||
                    // C / C++
                    lower.hasPrefix("void ") ||
                    lower.hasPrefix("int ") ||
                    lower.hasPrefix("class ") ||
                    lower.hasPrefix("struct ") ||
                    lower.hasPrefix("namespace ") ||
                    lower.hasPrefix("template ") ||
                    lower.hasPrefix("typedef ") ||
                    lower.hasPrefix("#include") ||
                    lower.hasPrefix("#define") ||
                    // Ruby
                    lower.hasPrefix("def ") ||
                    lower.hasPrefix("class ") ||
                    lower.hasPrefix("module ") ||
                    lower.hasPrefix("require ") ||
                    lower.hasPrefix("attr_") ||
                    // Java / Kotlin
                    lower.hasPrefix("class ") ||
                    lower.hasPrefix("interface ") ||
                    lower.hasPrefix("fun ") ||
                    lower.hasPrefix("public ") ||
                    lower.hasPrefix("private ") ||
                    lower.hasPrefix("protected ") ||
                    lower.hasPrefix("object ") ||
                    lower.hasPrefix("companion object ") ||
                    lower.hasPrefix("@")
                
                if isDeclaration {
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
