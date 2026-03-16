import SwiftUI
import WebKit

struct MarkdownPreviewView: View {
    @Binding var content: String
    @State private var webView = WKWebView()
    
    // MARK: - Embedded CSS (no CDN required)
    private static let embeddedCSS: String = """
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        padding: 20px;
        line-height: 1.6;
        color: #333;
        background-color: #ffffff;
        max-width: 100%;
        overflow-wrap: break-word;
        word-wrap: break-word;
    }
    h1, h2, h3, h4, h5, h6 {
        margin-top: 1.5em;
        margin-bottom: 0.5em;
        font-weight: 600;
        line-height: 1.3;
        color: #1a1a1a;
    }
    h1 { font-size: 2em; border-bottom: 1px solid #e0e0e0; padding-bottom: 0.3em; }
    h2 { font-size: 1.5em; border-bottom: 1px solid #e8e8e8; padding-bottom: 0.25em; }
    h3 { font-size: 1.25em; }
    h4 { font-size: 1.1em; }
    h5 { font-size: 1em; }
    h6 { font-size: 0.9em; color: #666; }
    h1:first-child, h2:first-child, h3:first-child, h4:first-child, h5:first-child, h6:first-child { margin-top: 0; }
    p { margin-bottom: 1em; }
    a { color: #0969da; text-decoration: none; }
    a:hover { text-decoration: underline; }
    strong { font-weight: 600; }
    em { font-style: italic; }
    img { max-width: 100%; height: auto; border-radius: 4px; }
    hr { border: none; border-top: 1px solid #d0d7de; margin: 1.5em 0; }
    blockquote {
        border-left: 4px solid #d0d7de;
        margin: 0 0 1em 0;
        padding: 0.5em 1em;
        color: #57606a;
        background-color: #f6f8fa;
        border-radius: 0 6px 6px 0;
    }
    blockquote p:last-child { margin-bottom: 0; }
    ul, ol { margin-bottom: 1em; padding-left: 2em; }
    li { margin-bottom: 0.25em; }
    li > ul, li > ol { margin-top: 0.25em; margin-bottom: 0; }
    code {
        font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;
        font-size: 85%;
        background-color: rgba(175, 184, 193, 0.2);
        padding: 0.2em 0.4em;
        border-radius: 3px;
    }
    pre {
        background-color: #f6f8fa;
        padding: 16px;
        border-radius: 6px;
        overflow-x: auto;
        margin-bottom: 1em;
        border: 1px solid #e1e4e8;
    }
    pre code {
        background-color: transparent;
        padding: 0;
        border-radius: 0;
        font-size: 100%;
    }
    table {
        border-collapse: collapse;
        width: 100%;
        margin-bottom: 1em;
        overflow-x: auto;
        display: block;
    }
    th, td {
        border: 1px solid #d0d7de;
        padding: 8px 13px;
        text-align: left;
    }
    th {
        background-color: #f6f8fa;
        font-weight: 600;
    }
    tr:nth-child(even) { background-color: #f6f8fa; }

    /* Dark theme */
    @media (prefers-color-scheme: dark) {
        body {
            background-color: #1e1e1e;
            color: #d4d4d4;
        }
        h1, h2, h3, h4, h5, h6 { color: #e0e0e0; }
        h1 { border-bottom-color: #444; }
        h2 { border-bottom-color: #3a3a3a; }
        a { color: #3794ff; }
        a:hover { color: #58a6ff; }
        hr { border-top-color: #444; }
        blockquote {
            border-left-color: #555;
            color: #8b949e;
            background-color: #2d2d2d;
        }
        code { background-color: rgba(175, 184, 193, 0.15); }
        pre { background-color: #2d2d2d; border-color: #444; }
        th { background-color: #2d2d2d; }
        tr:nth-child(even) { background-color: #252525; }
        th, td { border-color: #444; }
    }
    """

    // MARK: - Embedded Markdown Parser (no CDN required)
    private static let embeddedMarkdownJS: String = """
    (function() {
        function parseMarkdown(md) {
            var html = md;
            // Store code blocks and inline code to prevent processing
            var codeBlocks = [];
            var inlineCodes = [];
            // Extract fenced code blocks ```...```
            html = html.replace(/```([\\s\\S]*?)```/g, function(m, code) {
                codeBlocks.push('<pre><code>' + escapeHtml(code.replace(/^\\n|\\n$/g, '')) + '</code></pre>');
                return '%%CODEBLOCK_' + (codeBlocks.length - 1) + '%%';
            });
            // Extract inline code `...`
            html = html.replace(/`([^`]+)`/g, function(m, code) {
                inlineCodes.push('<code>' + escapeHtml(code) + '</code>');
                return '%%INLINECODE_' + (inlineCodes.length - 1) + '%%';
            });
            // Blockquotes
            html = html.replace(/^> (.+)$/gm, '<blockquote><p>$1</p></blockquote>');
            html = html.replace(/<\\/blockquote>\\n<blockquote>/g, '\\n');
            // Headings
            html = html.replace(/^###### (.+)$/gm, '<h6>$1</h6>');
            html = html.replace(/^##### (.+)$/gm, '<h5>$1</h5>');
            html = html.replace(/^#### (.+)$/gm, '<h4>$1</h4>');
            html = html.replace(/^### (.+)$/gm, '<h3>$1</h3>');
            html = html.replace(/^## (.+)$/gm, '<h2>$1</h2>');
            html = html.replace(/^# (.+)$/gm, '<h1>$1</h1>');
            // Horizontal rules
            html = html.replace(/^(---+|===+|\\*\\*\\*+)$/gm, '<hr>');
            // Images (before links so ![...](...) isn't caught by link regex)
            html = html.replace(/!\\[([^\\]]*)\\]\\(([^)]+)\\)/g, '<img src="$2" alt="$1">');
            // Links
            html = html.replace(/\\[([^\\]]+)\\]\\(([^)]+)\\)/g, '<a href="$2">$1</a>');
            // Bold and Italic
            html = html.replace(/\\*\\*\\*(.+?)\\*\\*\\*/g, '<strong><em>$1</em></strong>');
            html = html.replace(/\\*\\*(.+?)\\*\\*/g, '<strong>$1</strong>');
            html = html.replace(/\\*(.+?)\\*/g, '<em>$1</em>');
            html = html.replace(/___(.+?)___/g, '<strong><em>$1</em></strong>');
            html = html.replace(/__(.+?)__/g, '<strong>$1</strong>');
            html = html.replace(/_(.+?)_/g, '<em>$1</em>');
            // Strikethrough
            html = html.replace(/~~(.+?)~~/g, '<del>$1</del>');
            // Tables
            html = parseTables(html);
            // Unordered lists
            html = html.replace(/^([\\*\\-\\+]) (.+)$/gm, '<li>$2</li>');
            html = wrapListItems(html, 'ul');
            // Ordered lists
            html = html.replace(/^\\d+\\. (.+)$/gm, '<li>$1</li>');
            html = html.replace(/(<li>.+<\\/li>\\n?)+/g, function(match) {
                if (match.indexOf('<ul>') !== -1) return match;
                return '<ol>' + match + '</ol>';
            });
            // Paragraphs — wrap lines not already in block elements
            html = html.replace(/^(?!<[hupob]|<li|<t|<hr|%%)(.*\\S.*)$/gm, '<p>$1</p>');
            // Restore code blocks and inline code
            for (var i = 0; i < codeBlocks.length; i++) {
                html = html.replace('%%CODEBLOCK_' + i + '%%', codeBlocks[i]);
            }
            for (var j = 0; j < inlineCodes.length; j++) {
                html = html.replace('%%INLINECODE_' + j + '%%', inlineCodes[j]);
            }
            return html;
        }
        function parseTables(html) {
            var lines = html.split('\\n');
            var result = [];
            var i = 0;
            while (i < lines.length) {
                if (lines[i].match(/^\\|(.+)\\|$/) && i + 1 < lines.length && lines[i + 1].match(/^\\|[\\s\\\\-:|]+\\|$/)) {
                    var headerLine = lines[i].replace(/^\\|/, '').replace(/\\|$/, '').split('|').map(function(s) { return s.trim(); });
                    i++;
                    i++; // skip separator
                    var rows = [];
                    while (i < lines.length && lines[i].match(/^\\|(.+)\\|$/)) {
                        var cells = lines[i].replace(/^\\|/, '').replace(/\\|$/, '').split('|').map(function(s) { return s.trim(); });
                        rows.push(cells);
                        i++;
                    }
                    var table = '<table><thead><tr>';
                    headerLine.forEach(function(h) { table += '<th>' + h + '</th>'; });
                    table += '</tr></thead><tbody>';
                    rows.forEach(function(row) {
                        table += '<tr>';
                        row.forEach(function(cell) { table += '<td>' + cell + '</td>'; });
                        table += '</tr>';
                    });
                    table += '</tbody></table>';
                    result.push(table);
                } else {
                    result.push(lines[i]);
                    i++;
                }
            }
            return result.join('\\n');
        }
        function wrapListItems(html, tag) {
            var re = new RegExp('(<li>.*<\\/li>\\n?)+', 'g');
            return html.replace(re, function(match) {
                return '<' + tag + '>' + match + '</' + tag + '>';
            });
        }
        function escapeHtml(text) {
            return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }
        return parseMarkdown;
    })()
    """

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
        let css = MarkdownPreviewView.embeddedCSS
        let parser = MarkdownPreviewView.embeddedMarkdownJS
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                \(css)
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                var markdownParser = \(parser);
                document.getElementById('content').innerHTML = markdownParser(`\(escapeContent(content))`);
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
