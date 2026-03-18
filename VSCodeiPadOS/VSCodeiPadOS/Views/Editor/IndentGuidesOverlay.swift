//  IndentGuidesOverlay.swift
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
//
//  TODO (future): For pixel-perfect column alignment when the active editor
//  uses proportional fonts or when word-wrap is on, measure actual glyph
//  advances instead of using the monospaced character width approximation.

import SwiftUI
import UIKit

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

    /// Colour used for guide lines.  Keep opacity very low (≈ 0.10).
    var guideColor: Color = Color.primary.opacity(0.10)

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let font        = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
            let charWidth   = (" " as NSString).size(withAttributes: [.font: font]).width
            let topInset    = textInsets.top
            let leftInset   = textInsets.left

            // How many lines fit in the viewport (add a buffer so guides extend
            // a little beyond the last fully-visible row).
            let visibleCount = Int(ceil(geo.size.height / max(lineHeight, 1))) + 2

            // Slice only the visible portion of the document to keep work O(visible).
            let lines = splitLines(code)
            let firstLine = max(0, scrollPosition)
            let lastLine  = min(lines.count, firstLine + visibleCount)
            let visibleLines = Array(lines[firstLine..<lastLine])

            Canvas { ctx, size in
                // Determine the maximum indent depth across all visible lines so
                // we only iterate once per indent level (not once per line).
                var guideColumns = Set<Int>()
                for line in visibleLines {
                    let depth = indentDepth(of: line, tabSize: tabSize)
                    for level in 1...max(1, depth) {
                        guideColumns.insert(level)
                    }
                }

                let guideUIColor = UIColor(guideColor)
                let cgColor = guideUIColor.cgColor

                ctx.withCGContext { cgCtx in
                    cgCtx.setStrokeColor(cgColor)
                    cgCtx.setLineWidth(0.5)

                    for level in guideColumns {
                        // X position: gutter + textView left inset + column offset
                        let x = gutterWidth + leftInset + CGFloat(level * tabSize) * charWidth

                        // Only draw within the clipped content width
                        guard x < size.width - rightReservedWidth else { continue }

                        // Draw one continuous vertical line for this level,
                        // but only through rows that actually have this indent depth.
                        // This matches VS Code's behaviour (guides only appear on
                        // lines that are at least this deeply indented).
                        var segStart: CGFloat? = nil

                        func flushSegment(end: CGFloat) {
                            if let start = segStart {
                                cgCtx.move(to:    CGPoint(x: x, y: start))
                                cgCtx.addLine(to: CGPoint(x: x, y: end))
                                cgCtx.strokePath()
                            }
                            segStart = nil
                        }

                        for (idx, line) in visibleLines.enumerated() {
                            let depth = indentDepth(of: line, tabSize: tabSize)
                            let rowY = topInset + CGFloat(idx) * lineHeight

                            if depth >= level {
                                if segStart == nil { segStart = rowY }
                            } else {
                                flushSegment(end: rowY)
                            }
                        }
                        flushSegment(end: topInset + CGFloat(visibleLines.count) * lineHeight)
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

    /// Split document into lines without copying the whole string repeatedly.
    private func splitLines(_ text: String) -> [Substring] {
        text.split(separator: "\n", omittingEmptySubsequences: false)
    }

    /// Count the indentation depth of a line in units of `tabSize`.
    ///
    /// - A leading tab counts as one full indent level.
    /// - Leading spaces are summed and divided by `tabSize`.
    /// - Mixed tabs and spaces: tabs are expanded to the next tab stop first.
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
