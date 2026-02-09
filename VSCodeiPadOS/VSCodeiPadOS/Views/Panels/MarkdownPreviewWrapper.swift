import SwiftUI

struct MarkdownPreviewWrapper: View {
    @ObservedObject var editorCore: EditorCore
    let tab: Tab
    
    @State private var content: String = ""
    
    var body: some View {
        MarkdownPreviewView(content: $content)
            .onAppear {
                content = tab.content
            }
            .onChange(of: tab.content) { newContent in
                content = newContent
            }
    }
}