//
//  VSCodeiPadOS
//
//  Renders thin vertical indentation guide lines over the code editor area.
//  Each guide line sits at a tab-stop column (every `tabSize` spaces / 1 tab)
//  for lines that have at least that many levels of indentation.
//
//  Implementation notes:
//  ─────────────────────
//  • Uses a SwiftUI Canvas (single draw pass) rather than individual Shape views
//    so it has negligible impact on frame rate even for large files.
//  • The overlay is positioned by the same scroll-offset binding that drives
//    the LineNumbers gutter and GitGutterView, so it stays in sync without
//    any additional scroll synchronisation logic.
//  • hit-testing is disabled – the overlay is purely decorative.
//  • PERF: Only visible lines are processed. charWidth is cached per fontSize.
//    Indent depths are computed once per visible line and reused.
//  • The guide at the cursor's indent level is drawn brighter/thicker to
//    indicate the current scope (mirrors VS Code's active indent guide).
//  • Folded line ranges are excluded from guide rendering so guides don't
//    extend through collapsed regions.

import SwiftUI
import UIKit

/// Cache for charWidth keyed by fontSize to avoid measuring every render.
private nonisolated(unsafe) var _cachedCharWidths: [CGFloat: CGFloat] = [:]

struct IndentGuidesOverlay: View {

    // MARK: - Inputs

    /// Full document text (used to count indent levels per line).
    let code: String

    /// 0-based index of the first fully visible line.
    let scrollPosition: Int

    /// Height of a single editor line (pt), synced from the text view.
    let lineHeight: CGFloat

    /// Editor font size (pt).
    let fontSize: CGFloat

    /// Number of spaces that count as one indent level (matches editor setting).
    var tabSize: Int = 4

    /// Width of the gutter area to the left of the code (line-numbers column).
    var gutterWidth: CGFloat = 0

    /// Horizontal inset that the underlying UITextView applies to its content.
    var textInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    /// Width reserved at the right edge (minimap, etc.) – guides are clipped here.
    var rightReservedWidth: CGFloat = 0

    /// Colour used for inactive guide lines.  Keep opacity very low (≈ 0.10).
    var guideColor: Color = Color.primary.opacity(0.10)

    /// Colour used for the active scope guide (the indent level at the cursor).
    /// Should be more prominent than `guideColor` (≈ 0.30–0.45 opacity).
    var activeGuideColor: Color = Color.primary.opacity(0.35)

    /// 1-based line number where the cursor currently sits.
    /// Used to determine which indent guide to highlight as "active scope".
    /// Pass `nil` to disable active scope highlighting.
    var currentLine: Int? = nil

    /// Ranges of folded (collapsed) line numbers (0-based, closed ranges).
    /// Guides will not render through folded regions.
    var foldedLineRanges: [Range<Int>] = []

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            // PERF: Cache charWidth per fontSize — avoid NSString.size() every render
            let charWidth: CGFloat = {
                if let cached = _cachedCharWidths[fontSize] { return cached }
                let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
                let w = (" " as NSString).size(withAttributes: [.font: font]).width
                _cachedCharWidths[fontSize] = w
                return w
            }()
            let topInset    = textInsets.top
            let leftInset   = textInsets.left

            // How many lines fit in the viewport (add a buffer so guides extend
            // a little beyond the last fully-visible row).
            let visibleCount = Int(ceil(geo.size.height / max(lineHeight, 1))) + 2

            // PERF: Extract only the visible portion of the document without
            // splitting the entire string. Walk from the Nth newline to the
            // (N + visibleCount)th newline.
            let firstLine = max(0, scrollPosition)
            let visibleLines = extractVisibleLines(from: code, startLine: firstLine, count: visibleCount)

            Canvas { ctx, size in
                let lineCount = visibleLines.count
                guard lineCount > 0 else { return }

                // PERF: Compute indent depths once into an array, reuse everywhere
                let depths = visibleLines.map { indentDepth(of: $0, tabSize: tabSize) }
                let maxDepth = depths.max() ?? 0
                guard maxDepth > 0 else { return }

                let guideUIColor = UIColor(guideColor)
                let guideCGColor = guideUIColor.cgColor

                let activeUIColor = UIColor(activeGuideColor)
                let activeCGColor = activeUIColor.cgColor

                // Determine the active indent depth: look at the cursor line's depth.
                // The cursor line may be within the visible window or just above/below.
                // We compute it from the actual document text for accuracy.
                let activeDepth: Int? = {
                    guard let cursorLine = currentLine else { return nil }
                    // Convert 1-based to 0-based
                    let zeroBased = cursorLine - 1
                    // If the cursor line falls within the visible range, use the
                    // already-computed depth (fast path).
                    if zeroBased >= firstLine && zeroBased < firstLine + lineCount {
                        let localIdx = zeroBased - firstLine
                        let d = depths[localIdx]
                        return d > 0 ? d : nil
                    }
                    // Slow path: extract just that one line from the document.
                    let cursorLineText = extractVisibleLines(from: code, startLine: zeroBased, count: 1)
                    guard let text = cursorLineText.first else { return nil }
                    let d = indentDepth(of: text, tabSize: tabSize)
                    return d > 0 ? d : nil
                }()

                // Build a set of folded line indices (0-based) for O(1) lookup.
                var foldedSet: Set<Int>?
                if !foldedLineRanges.isEmpty {
                    var s = Set<Int>()
                    s.reserveCapacity(foldedLineRanges.reduce(0) { $0 + $1.count })
                    for range in foldedLineRanges {
                        for line in range {
                            s.insert(line)
                        }
                    }
                    foldedSet = s
                }

                ctx.withCGContext { cgCtx in
                    for level in 1...maxDepth {
                        // X position: gutter + textView left inset + column offset
                        let x = gutterWidth + leftInset + CGFloat(level * tabSize) * charWidth

                        // Only draw within the clipped content width
                        guard x < size.width - rightReservedWidth else { continue }

                        let isActiveLevel = activeDepth.map { level <= $0 } ?? false

                        // Use active color + slightly thicker line for the active scope guides
                        if isActiveLevel {
                            cgCtx.setStrokeColor(activeCGColor)
                            cgCtx.setLineWidth(1.0)
                        } else {
                            cgCtx.setStrokeColor(guideCGColor)
                            cgCtx.setLineWidth(0.5)
                        }

                        // Draw one continuous vertical line for this level,
                        // but only through rows that actually have this indent depth.
                        var segStart: CGFloat? = nil

                        func flushSegment(end: CGFloat) {
                            if let start = segStart {
                                cgCtx.move(to:    CGPoint(x: x, y: start))
                                cgCtx.addLine(to: CGPoint(x: x, y: end))
                                cgCtx.strokePath()
                            }
                            segStart = nil
                        }

                        for idx in 0..<lineCount {
                            let absoluteLine = firstLine + idx

                            // Skip lines inside folded regions — don't draw guides
                            // through collapsed code blocks.
                            if let folded = foldedSet, folded.contains(absoluteLine) {
                                // Flush any segment before the fold and start fresh after
                                let rowY = topInset + CGFloat(idx) * lineHeight
                                flushSegment(end: rowY)
                                continue
                            }

                            let rowY = topInset + CGFloat(idx) * lineHeight
                            if depths[idx] >= level {
                                if segStart == nil { segStart = rowY }
                            } else {
                                flushSegment(end: rowY)
                            }
                        }
                        flushSegment(end: topInset + CGFloat(lineCount) * lineHeight)
                    }
                }
            }
            .frame(
                width:  max(0, geo.size.width - rightReservedWidth),
                height: geo.size.height,
                alignment: .topLeading
            )
            .clipped()
        }
        .allowsHitTesting(false)
    }

    // MARK: - Helpers

    /// Extract visible lines from the document without splitting the entire string.
    /// Walks to the `startLine`-th newline, then collects `count` lines.
    private func extractVisibleLines(from text: String, startLine: Int, count: Int) -> [Substring] {
        guard !text.isEmpty, count > 0, startLine >= 0 else { return [] }
        
        var lines: [Substring] = []
        lines.reserveCapacity(count)
        
        var currentLine = 0
        var lineStart = text.startIndex
        var i = text.startIndex
        
        while i < text.endIndex {
            if text[i] == "\n" {
                if currentLine >= startLine {
                    lines.append(text[lineStart..<i])
                    if lines.count >= count { return lines }
                }
                currentLine += 1
                lineStart = text.index(after: i)
            }
            i = text.index(after: i)
        }
        
        // Handle last line (no trailing newline)
        if currentLine >= startLine && lines.count < count {
            lines.append(text[lineStart..<text.endIndex])
        }
        
        return lines
    }

    /// Count the indentation depth of a line in units of `tabSize`.
    ///
    /// - A leading tab counts as one full indent level.
    /// - Leading spaces are summed and divided by `tabSize`.
    /// - Mixed tabs and spaces: tabs are expanded to the next tab stop first.
    /// - Empty lines return 0 (guides bridge over blank lines naturally since
    ///   segments remain open until a shallower line closes them).
    private func indentDepth(of line: Substring, tabSize: Int) -> Int {
        guard !line.isEmpty else { return 0 }
        var spaces = 0
        for ch in line {
            switch ch {
            case " ":
                spaces += 1
            case "\t":
                // Each tab advances to the next tab stop
                spaces = ((spaces / tabSize) + 1) * tabSize
            default:
                // First non-whitespace character — stop counting
                return spaces / max(1, tabSize)
            }
        }
        // Blank / whitespace-only line: treat as depth 0 so guides bridge over it
        return 0
    }
}
