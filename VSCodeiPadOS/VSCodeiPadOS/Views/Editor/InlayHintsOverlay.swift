import SwiftUI
import UIKit

/// Renders inlay hints as subtle inline text inside the editor area.
///
/// This is a lightweight overlay that approximates text positions using monospaced font metrics.
struct InlayHintsOverlay: View {
    let code: String
    let language: CodeLanguage

    /// 0-based top visible line index.
    let scrollPosition: Int

    let lineHeight: CGFloat
    let fontSize: CGFloat

    /// Width reserved for the gutter (line numbers).
    var gutterWidth: CGFloat = 60

    /// Insets used by the underlying UITextView.
    var textInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    /// Width reserved at the right edge (e.g. minimap).
    var rightReservedWidth: CGFloat = 0

    /// How many spaces a tab visually represents.
    var tabSize: Int = 4

    @State private var hints: [InlayHintsManager.InlayHint] = []

    var body: some View {
        GeometryReader { geo in
            let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
            let charWidth = (" " as NSString).size(withAttributes: [.font: font]).width
            let fontLineHeight = font.lineHeight
            let baselineAdjustment = max(0, (lineHeight - fontLineHeight) / 2)
            let maxVisibleLines = Int(ceil(geo.size.height / max(lineHeight, 1))) + 2

            let lines = code.components(separatedBy: .newlines)

            ZStack(alignment: .topLeading) {
                ForEach(hints) { hint in
                    if hint.line >= scrollPosition && hint.line <= (scrollPosition + maxVisibleLines) {
                        let lineText = (hint.line >= 0 && hint.line < lines.count) ? lines[hint.line] : ""
                        let visualColumn = visualColumn(in: lineText, utf16Column: hint.column, tabSize: tabSize)

                        let x = gutterWidth + textInsets.left + (CGFloat(visualColumn) * charWidth)
                        let y = textInsets.top + baselineAdjustment + (CGFloat(hint.line - scrollPosition) * lineHeight)

                        Text(hint.text)
                            .font(.system(size: fontSize, design: .monospaced))
                            .foregroundColor(Color.secondary.opacity(0.42))
                            .offset(x: x, y: y)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
            }
            // Avoid drawing under minimap (or other right-side UI)
            .frame(
                width: max(0, geo.size.width - rightReservedWidth),
                height: geo.size.height,
                alignment: .topLeading
            )
            .clipped()
        }
        .allowsHitTesting(false)
        .onAppear { recompute() }
        .onChange(of: code) { _ in recompute() }
        .onChange(of: language) { _ in recompute() }
    }

    private func recompute() {
        hints = InlayHintsManager.shared.hints(for: code, language: language)
    }

    private func visualColumn(in line: String, utf16Column: Int, tabSize: Int) -> Int {
        let ns = line as NSString
        let clamped = max(0, min(utf16Column, ns.length))
        let prefix = ns.substring(with: NSRange(location: 0, length: clamped))

        var col = 0
        for ch in prefix {
            if ch == "\t" {
                col += tabSize
            } else {
                col += 1
            }
        }
        return col
    }
}
