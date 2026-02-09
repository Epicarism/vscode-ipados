import SwiftUI

struct EditorSplitView: View {
    @ObservedObject var editorCore: EditorCore
    let tab: Tab
    let theme: Theme
    @State private var showPreview = false
    
    private var isMarkdown: Bool {
        tab.fileName.lowercased().hasSuffix(".md")
    }

    var body: some View {
        HStack(spacing: 0) {
            IDEEditorView(editorCore: editorCore, tab: tab, theme: theme)
                .frame(maxWidth: showPreview ? UIScreen.main.bounds.width * 0.5 : .infinity)
            
            if showPreview && isMarkdown {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1)
                
                MarkdownPreviewWrapper(editorCore: editorCore, tab: tab)
                    .frame(maxWidth: .infinity)
            }
        }
        .overlay(alignment: .topTrailing) {
            if isMarkdown {
                Button(action: { showPreview.toggle() }) {
                    Image(systemName: showPreview ? "eye.slash" : "eye")
                        .padding(8)
                        .background(theme.editorBackground.opacity(0.8))
                        .cornerRadius(6)
                }
                .padding(8)
            }
        }
    }
}