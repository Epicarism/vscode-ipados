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
    @State private var recomputeTask: Task<Void, Never>?

    // PERF: Cache charWidth per fontSize to avoid recomputing on every layout
    private static var _charWidthCache: [CGFloat: CGFloat] = [:]

    var body: some View {
        GeometryReader { geo in
            let charWidth = Self.cachedCharWidth(for: fontSize)
            let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
            let fontLineHeight = font.lineHeight
            let baselineAdjustment = max(0, (lineHeight - fontLineHeight) / 2)
            let maxVisibleLines = Int(ceil(geo.size.height / max(lineHeight, 1))) + 2

            // PERF: Filter hints to visible range BEFORE ForEach (avoids SwiftUI structural instability)
            let visibleHints = hints.filter { $0.line >= scrollPosition && $0.line <= (scrollPosition + maxVisibleLines) }

            ZStack(alignment: .topLeading) {
                // PERF: Pre-compute line texts to avoid O(H×L) extractLine calls inside ForEach
                let lineTexts: [Int: String] = {
                    var dict = [Int: String]()
                    for hint in visibleHints {
                        if dict[hint.line] == nil {
                            dict[hint.line] = extractLine(from: code, at: hint.line)
                        }
                    }
                    return dict
                }()

                ForEach(visibleHints) { hint in
                    let lineText = lineTexts[hint.line] ?? ""
                    let visualCol = visualColumn(in: lineText, utf16Column: hint.column, tabSize: tabSize)

                    let x = gutterWidth + textInsets.left + (CGFloat(visualCol) * charWidth)
                    let y = textInsets.top + baselineAdjustment + (CGFloat(hint.line - scrollPosition) * lineHeight)

                    Text(hint.text)
                        .font(.system(size: fontSize, design: .monospaced))
                        .foregroundColor(Color.secondary.opacity(0.42))
                        .offset(x: x, y: y)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
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
        .onChange(of: code) { _, _ in
            recomputeTask?.cancel()
            recomputeTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { recompute() }
            }
        }
        .onChange(of: language) { _, _ in recompute() }
    }

    private func recompute() {
        hints = InlayHintsManager.shared.hints(for: code, language: language)
    }

    // PERF: Cached charWidth avoids UIFont + NSString measurement on every layout
    private static func cachedCharWidth(for size: CGFloat) -> CGFloat {
        if let cached = _charWidthCache[size] { return cached }
        let font = UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
        let w = (" " as NSString).size(withAttributes: [.font: font]).width
        _charWidthCache[size] = w
        return w
    }

    /// PERF: Extract a single line by index without splitting the entire document.
    /// O(lineIndex) scan for newlines — far cheaper than O(N) full split for large files.
    private func extractLine(from text: String, at lineIndex: Int) -> String {
        var currentLine = 0
        var lineStart = text.startIndex
        var i = text.startIndex
        while i < text.endIndex {
            if text[i] == "\n" {
                if currentLine == lineIndex {
                    return String(text[lineStart..<i])
                }
                currentLine += 1
                lineStart = text.index(after: i)
            }
            i = text.index(after: i)
        }
        // Last line (no trailing newline)
        if currentLine == lineIndex {
            return String(text[lineStart..<text.endIndex])
        }
        return ""
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
