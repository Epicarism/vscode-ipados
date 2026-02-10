import SwiftUI

struct PeekDefinitionView: View {
    @ObservedObject var editorCore: EditorCore
    let targetFile: String
    let targetLine: Int
    let content: String
    let onClose: () -> Void
    let onOpen: () -> Void
    
    @State private var attributedContent: NSAttributedString = NSAttributedString(string: "")
    
    var body: some View {
        VStack(spacing: 0) {
            // Title Bar
            HStack {
                Text(targetFile)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onOpen) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .help("Open in Editor")
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .help("Close")
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .border(width: 1, edges: [.bottom], color: Color(UIColor.separator))
            
            // Mini Editor Context
            ScrollView {
                Text(AttributedString(attributedContent))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(UIColor.systemBackground))
        }
        .frame(height: 200)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: 1)
        )
        .shadow(radius: 10)
        .onAppear {
            loadContent()
        }
    }
    
    private func loadContent() {
        // Extract context: 5 lines before, definition, 5 lines after
        let lines = content.components(separatedBy: .newlines)
        let startLine = max(0, targetLine - 5)
        let endLine = min(lines.count - 1, targetLine + 5)
        
        let contextLines = lines[startLine...endLine]
        let contextString = contextLines.joined(separator: "\n")
        
        // Highlight
        let highlighter = VSCodeSyntaxHighlighter(theme: ThemeManager.shared.currentTheme)
        attributedContent = highlighter.highlight(contextString, filename: targetFile)
    }
}

// Extension to support specific border sides
extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat { edge == .trailing ? rect.width - width : 0 }
            var y: CGFloat { edge == .bottom ? rect.height - width : 0 }
            var w: CGFloat { edge == .leading || edge == .trailing ? width : rect.width }
            var h: CGFloat { edge == .top || edge == .bottom ? width : rect.height }
            path.addRect(CGRect(x: x, y: y, width: w, height: h))
        }
        return path
    }
}