import SwiftUI
import WebKit

struct MarkdownPreviewView: View {
    @Binding var content: String
    @State private var webView = WKWebView()
    
    var body: some View {
        WebView(webView: webView)
            .onAppear {
                loadMarkdown()
            }
            .onChange(of: content) { _ in
                loadMarkdown()
            }
    }
    
    private func loadMarkdown() {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    padding: 20px;
                    line-height: 1.6;
                    color: #333;
                }
                pre {
                    background-color: #f6f8fa;
                    padding: 16px;
                    border-radius: 6px;
                    overflow-x: auto;
                }
                code {
                    font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;
                    font-size: 85%;
                }
                @media (prefers-color-scheme: dark) {
                    body {
                        background-color: #1e1e1e;
                        color: #d4d4d4;
                    }
                    pre {
                        background-color: #2d2d2d;
                    }
                    a {
                        color: #3794ff;
                    }
                }
            </style>
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
        </head>
        <body>
            <div id="content"></div>
            <script>
                document.getElementById('content').innerHTML = marked.parse(`\(escapeContent(content))`);
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func escapeContent(_ text: String) -> String {
        text.replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
    }
}

struct WebView: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
