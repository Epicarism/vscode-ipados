import SwiftUI

/// VS Code–style minimap with:
/// - syntax-colored tiny preview
/// - visible region overlay
/// - tap/drag to scroll
/// - fold-aware rendering (hidden folded lines)
/// - optional git diff indicators (added/modified/deleted)
struct MinimapView: View {
    // MARK: - External inputs

    let content: String
    /// File identifier for fold-aware rendering. When nil, folding is ignored.
    var fileId: String? = nil
    /// Current scroll offset (read-only for display). Minimap FOLLOWS the editor, never fights it.
    let scrollOffset: CGFloat
    /// Visible viewport height (read-only for display)
    let scrollViewHeight: CGFloat
    let totalContentHeight: CGFloat
    
    /// Callback when user taps/drags on minimap to request scroll. 
    /// Parent handles actual scrolling - prevents bidirectional binding jitter.
    var onScrollRequested: ((CGFloat) -> Void)? = nil

    /// Optional indicators to render as thin bars on the left side of the minimap.
    /// Note: call sites can ignore this (default empty) without breaking compilation.
    var diffIndicators: [MinimapDiffIndicator] = []

    /// Fixed width; height expands to the container.
    var minimapWidth: CGFloat = 60

    // MARK: - Internal state

    @State private var isInteracting: Bool = false
    @State private var cachedLines: [Substring] = []
    @State private var cachedVisibleIndices: [Int] = []
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var foldingManager = CodeFoldingManager.shared

    // MARK: - Types

    struct MinimapDiffIndicator: Identifiable, Hashable {
        enum Kind: Hashable {
            case added
            case modified
            case deleted
        }

        var id = UUID()
        /// 0-based line range in the current `content`.
        var lineRange: Range<Int>
        var kind: Kind

        init(lineRange: Range<Int>, kind: Kind) {
            self.lineRange = lineRange
            self.kind = kind
        }
    }

    // MARK: - Layout computation
    
    /// Shared layout values so canvas, indicator, and tap handler all use the same coordinate system.
    private struct MinimapLayout {
        let pixelsPerLine: CGFloat
        let totalRenderedHeight: CGFloat
        let fitsInMinimap: Bool
        let startIdx: Int
        let endIdx: Int
        let linesRendered: Int
        let visibleLineCount: Int
        let viewportStartLine: CGFloat
        let viewportLineCount: CGFloat
    }
    
    private func computeLayout(minimapHeight: CGFloat, visibleCount: Int) -> MinimapLayout {
        let pixelsPerLine: CGFloat = 2.5
        let totalRenderedHeight = CGFloat(visibleCount) * pixelsPerLine
        let fitsInMinimap = totalRenderedHeight <= minimapHeight
        
        // How many source lines are visible in the editor viewport
        let lineHeightEstimate = visibleCount > 0 ? totalContentHeight / CGFloat(visibleCount) : 20.0
        let viewportLineCount = max(1, scrollViewHeight / max(lineHeightEstimate, 1))
        
        // Current scroll ratio
        let scrollable = max(0, totalContentHeight - scrollViewHeight)
        let scrollRatio = scrollable > 0 ? min(max(scrollOffset / scrollable, 0), 1.0) : 0
        
        // Which line is at the top of the viewport
        let viewportStartLine = scrollRatio * CGFloat(max(0, visibleCount - Int(viewportLineCount)))
        let viewportCenterLine = viewportStartLine + viewportLineCount / 2
        
        let startIdx: Int
        let endIdx: Int
        let linesInView = Int(minimapHeight / pixelsPerLine)
        
        if fitsInMinimap {
            // Entire file fits — render all lines
            startIdx = 0
            endIdx = visibleCount
        } else {
            // File too large — center minimap window around viewport center
            let halfView = linesInView / 2
            var start = Int(viewportCenterLine) - halfView
            start = max(0, min(start, visibleCount - linesInView))
            startIdx = start
            endIdx = min(start + linesInView, visibleCount)
        }
        
        return MinimapLayout(
            pixelsPerLine: pixelsPerLine,
            totalRenderedHeight: totalRenderedHeight,
            fitsInMinimap: fitsInMinimap,
            startIdx: startIdx,
            endIdx: endIdx,
            linesRendered: endIdx - startIdx,
            visibleLineCount: visibleCount,
            viewportStartLine: viewportStartLine,
            viewportLineCount: viewportLineCount
        )
    }

    // MARK: - View

    /// Recompute cached lines from content
    private func recomputeLines() {
        var lines = Array(content.split(separator: "\n", omittingEmptySubsequences: false))
        // For very large files, sample every Nth line to keep minimap responsive
        if lines.count > 100_000 {
            let step = max(2, lines.count / 50_000)
            var sampled: [Substring] = []
            sampled.reserveCapacity(lines.count / step + 1)
            var i = 0
            while i < lines.count {
                sampled.append(lines[i])
                i += step
            }
            lines = sampled
        }
        cachedLines = lines
        recomputeVisibleIndices()
    }
    
    /// Recompute visible line indices from cached lines + folding state
    private func recomputeVisibleIndices() {
        // Skip fold filtering for very large files — O(n) isLineFolded too expensive
        guard cachedLines.count <= 50_000, let fid = fileId else {
            cachedVisibleIndices = Array(0..<cachedLines.count)
            return
        }
        var indices: [Int] = []
        indices.reserveCapacity(cachedLines.count)
        for i in 0..<cachedLines.count {
            if !foldingManager.isLineFolded(fileId: fid, line: i) {
                indices.append(i)
            }
        }
        cachedVisibleIndices = indices
    }


    @ViewBuilder
    var body: some View {
        if LargeFileHandler.shared.currentTier.enableMinimap {
        GeometryReader { geometry in
            let size = geometry.size
            let minimapHeight = max(1, size.height)
            let lines = cachedLines
            let visible = cachedVisibleIndices
            let visibleCount = max(visible.count, 1)
            let layout = computeLayout(minimapHeight: minimapHeight, visibleCount: visibleCount)

            ZStack(alignment: .topLeading) {
                // Background
                Rectangle()
                    .fill(themeManager.currentTheme.editorBackground)

                // Syntax-colored code preview
                Canvas { context, canvasSize in
                    drawMinimapPreview(
                        in: &context,
                        size: canvasSize,
                        lines: lines,
                        visibleIndices: visible,
                        layout: layout
                    )
                }
                .allowsHitTesting(false)

                // Git diff indicators (thin left bars)
                diffIndicatorsLayer(
                    minimapHeight: minimapHeight,
                    lineCount: visibleCount,
                    layout: layout
                )
                .allowsHitTesting(false)

                // Visible region highlight
                visibleRegionLayer(minimapHeight: minimapHeight, layout: layout)
                    .allowsHitTesting(false)
            }
            .frame(width: minimapWidth, height: minimapHeight)
            .clipShape(Rectangle())
            .contentShape(Rectangle())
            .accessibilityLabel("Code minimap")
            .accessibilityHint("Scroll to position")
            // Click-to-scroll + drag scrolling (DragGesture(minDistance: 0) captures taps too)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        isInteracting = true
                        updateScroll(forMinimapY: value.location.y, minimapHeight: minimapHeight, layout: layout)
                    }
                    .onEnded { _ in
                        isInteracting = false
                    }
            )
        }
        .frame(width: minimapWidth)
        .onAppear { recomputeLines() }
        .onChange(of: content) { _, _ in recomputeLines() }
        .onChange(of: foldingManager.collapsedLines) { _, _ in recomputeVisibleIndices() }
    } // if enableMinimap
    }

    // MARK: - Layers

    @ViewBuilder
    private func visibleRegionLayer(minimapHeight: CGFloat, layout: MinimapLayout) -> some View {
        let height = visibleRegionHeight(minimapHeight: minimapHeight, layout: layout)
        let offset = visibleRegionOffset(minimapHeight: minimapHeight, visibleHeight: height, layout: layout)

        Rectangle()
            .fill(Color.accentColor.opacity(isInteracting ? 0.08 : 0.04))
            .overlay(
                Rectangle()
                    .stroke(Color.accentColor.opacity(isInteracting ? 0.5 : 0.35), lineWidth: 1.5)
            )
            .frame(width: minimapWidth, height: max(8, height))
            .offset(y: offset)
    }

    @ViewBuilder
    private func diffIndicatorsLayer(minimapHeight: CGFloat, lineCount: Int, layout: MinimapLayout) -> some View {
        // VS Code minimap diff markers are thin and pinned to the left.
        let barWidth: CGFloat = 2

        // Guard against division by zero
        if lineCount > 0 {
            ForEach(Array(diffIndicators.enumerated()), id: \.element.id) { _, indicator in
                let startLine = max(0, min(indicator.lineRange.lowerBound, lineCount - 1))
                let endLineExclusive = max(startLine + 1, min(indicator.lineRange.upperBound, lineCount))
                let startY = diffIndicatorY(line: startLine, layout: layout)
                let endY = diffIndicatorY(line: endLineExclusive, layout: layout)
                let height = max(2, endY - startY)

                if startY >= 0 && startY < minimapHeight {
                    Rectangle()
                        .fill(diffColor(for: indicator.kind).opacity(0.95))
                        .frame(width: barWidth, height: height)
                        .offset(x: 0, y: startY)
                }
            }
        }
    }

    private func diffIndicatorY(line: Int, layout: MinimapLayout) -> CGFloat {
        if layout.fitsInMinimap {
            return CGFloat(line) * layout.pixelsPerLine + 2
        } else {
            return CGFloat(line - layout.startIdx) * layout.pixelsPerLine + 2
        }
    }

    // MARK: - Visible region math (unified with canvas coordinate system)

    private func visibleRegionHeight(minimapHeight: CGFloat, layout: MinimapLayout) -> CGFloat {
        guard totalContentHeight > 0, layout.visibleLineCount > 0 else { return 0 }
        
        // Height in pixels = number of editor-visible lines * pixelsPerLine
        let height = layout.viewportLineCount * layout.pixelsPerLine
        
        if layout.fitsInMinimap {
            // Entire file rendered — indicator height is proportional
            return min(height, minimapHeight * 0.8)
        } else {
            // Windowed — indicator height still based on viewport lines
            return min(height, minimapHeight * 0.8)
        }
    }

    private func visibleRegionOffset(minimapHeight: CGFloat, visibleHeight: CGFloat, layout: MinimapLayout) -> CGFloat {
        guard totalContentHeight > 0, layout.visibleLineCount > 0 else { return 0 }
        
        if layout.fitsInMinimap {
            // Entire file fits — offset is simply the viewport start line * pixelsPerLine
            let offset = layout.viewportStartLine * layout.pixelsPerLine
            // Clamp so indicator doesn't go past the bottom
            return min(offset, minimapHeight - visibleHeight)
        } else {
            // Windowed mode — viewport start line relative to the rendered window
            let relativeStartLine = layout.viewportStartLine - CGFloat(layout.startIdx)
            let offset = relativeStartLine * layout.pixelsPerLine
            return max(0, min(offset, minimapHeight - visibleHeight))
        }
    }

    // MARK: - Interaction

    /// Requests scroll so that the main editor's visible region is centered around the minimap Y position.
    /// Uses callback to parent - minimap never directly controls editor scroll (prevents jitter).
    private func updateScroll(forMinimapY yPosition: CGFloat, minimapHeight: CGFloat, layout: MinimapLayout) {
        guard totalContentHeight > 0 else { return }
        guard let onScrollRequested = onScrollRequested else { return }

        let clampedY = max(0, min(yPosition, minimapHeight))
        
        // Convert tap Y to a line number
        let tappedLine: CGFloat
        if layout.fitsInMinimap {
            tappedLine = clampedY / layout.pixelsPerLine
        } else {
            tappedLine = CGFloat(layout.startIdx) + clampedY / layout.pixelsPerLine
        }
        
        // Convert line number to document scroll offset
        let lineRatio = tappedLine / CGFloat(max(layout.visibleLineCount, 1))
        let targetCenter = lineRatio * totalContentHeight
        let desiredOffset = targetCenter - (scrollViewHeight / 2)

        let maxOffset = max(0, totalContentHeight - scrollViewHeight)
        let newOffset = min(max(desiredOffset, 0), maxOffset)
        
        // Request scroll via callback - parent controls the actual scroll
        onScrollRequested(newOffset)
    }

    // MARK: - Rendering (Canvas)

    private func drawMinimapPreview(
        in context: inout GraphicsContext,
        size: CGSize,
        lines: [Substring],
        visibleIndices: [Int],
        layout: MinimapLayout
    ) {
        let paddingX: CGFloat = 4
        let paddingY: CGFloat = 2

        let contentWidth = max(0, size.width - (paddingX * 2))
        let contentHeight = max(0, size.height - (paddingY * 2))

        guard contentWidth > 0, contentHeight > 0 else { return }
        guard layout.endIdx >= layout.startIdx else { return }

        // Token-block mode (colored rectangles) - VS Code style minimap
        let minBarHeight: CGFloat = 1
        let barHeight = max(minBarHeight, layout.pixelsPerLine)

        // Approximate "characters" across minimap width.
        let maxChars: CGFloat = 120
        let charWidth = contentWidth / maxChars

        // PERF: Only tokenize lines in the visible window
        for i in layout.startIdx..<layout.endIdx {
            let displayIndex = i - layout.startIdx
            let y = paddingY + (CGFloat(displayIndex) * layout.pixelsPerLine)
            if y > size.height { break }

            // Map from visible index back to original line index
            let originalLineIndex = visibleIndices.indices.contains(i) ? visibleIndices[i] : 0
            let line = lines.indices.contains(originalLineIndex) ? lines[originalLineIndex] : Substring("")
            let tokens = tokenize(line)

            var x = paddingX
            let yAligned = y.rounded(FloatingPointRoundingRule.down)

            if tokens.isEmpty {
                // Render faint whitespace line.
                let rect = CGRect(x: x, y: yAligned, width: max(4, contentWidth * 0.15), height: barHeight)
                context.fill(Path(rect), with: .color(themeManager.currentTheme.editorForeground.opacity(0.10)))
                continue
            }

            for token in tokens {
                guard x < (paddingX + contentWidth) else { break }
                let w = max(1, CGFloat(token.text.count) * charWidth)
                let rect = CGRect(x: x, y: yAligned, width: min(w, paddingX + contentWidth - x), height: barHeight)
                context.fill(Path(rect), with: .color(tokenColor(for: token).opacity(0.80)))
                x += w
            }
        }
    }

    // MARK: - Syntax highlighting (lightweight)

    private struct Token {
        enum Kind {
            case plain
            case keyword
            case string
            case comment
            case number
            case typeName
        }

        var text: Substring
        var kind: Kind

        func color(for theme: Theme) -> Color {
            switch kind {
            case .plain:
                return theme.editorForeground
            case .keyword:
                return theme.keyword
            case .string:
                return theme.string
            case .comment:
                return theme.comment
            case .number:
                return theme.number
            case .typeName:
                return theme.type
            }
        }
    }

    private func tokenColor(for token: Token) -> Color {
        token.color(for: themeManager.currentTheme)
    }

    private func tokenize(_ line: Substring) -> [Token] {
        // Extremely lightweight tokenizer:
        // - full-line comment if first non-space is # (python-like)
        // - inline comment starting at //
        // - strings in "..." or '...'
        // - numbers
        // - keywords
        // - PascalCase tokens treated as type names
        var tokens: [Token] = []
        var i = line.startIndex

        func peek(_ offset: Int = 0) -> Character? {
            var idx = i
            for _ in 0..<offset {
                guard idx < line.endIndex else { return nil }
                idx = line.index(after: idx)
            }
            return idx < line.endIndex ? line[idx] : nil
        }

        func advance(_ n: Int = 1) {
            for _ in 0..<n {
                guard i < line.endIndex else { return }
                i = line.index(after: i)
            }
        }

        // Detect python/shebang-like comment lines: first non-whitespace is '#'
        if let firstNonSpace = line.firstIndex(where: { !$0.isWhitespace }),
           line[firstNonSpace] == "#" {
            tokens.append(Token(text: line[line.startIndex..<line.endIndex], kind: .comment))
            return tokens
        }

        while i < line.endIndex {
            let ch = line[i]

            // Inline comment: //
            if ch == "/", peek(1) == "/" {
                let range = i..<line.endIndex
                tokens.append(Token(text: line[range], kind: .comment))
                return tokens
            }

            // Whitespace
            if ch.isWhitespace {
                let start = i
                while i < line.endIndex, line[i].isWhitespace { advance() }
                tokens.append(Token(text: line[start..<i], kind: .plain))
                continue
            }

            // String literals
            if ch == "\"" || ch == "'" {
                let quote = ch
                let start = i
                advance()
                var escaped = false
                while i < line.endIndex {
                    let c = line[i]
                    if escaped {
                        escaped = false
                        advance()
                        continue
                    }
                    if c == "\\" {
                        escaped = true
                        advance()
                        continue
                    }
                    if c == quote {
                        advance()
                        break
                    }
                    advance()
                }
                tokens.append(Token(text: line[start..<i], kind: .string))
                continue
            }

            // Numbers
            if ch.isNumber {
                let start = i
                while i < line.endIndex, line[i].isNumber || line[i] == "." { advance() }
                tokens.append(Token(text: line[start..<i], kind: .number))
                continue
            }

            // Identifiers / keywords
            if ch.isLetter || ch == "_" {
                let start = i
                advance()
                while i < line.endIndex {
                    let c = line[i]
                    if c.isLetter || c.isNumber || c == "_" { advance() } else { break }
                }
                let word = line[start..<i]
                let kind: Token.Kind

                if isKeyword(word) {
                    kind = .keyword
                } else if looksLikeTypeName(word) {
                    kind = .typeName
                } else {
                    kind = .plain
                }

                tokens.append(Token(text: word, kind: kind))
                continue
            }

            // Operators / punctuation
            let start = i
            advance()
            tokens.append(Token(text: line[start..<i], kind: .plain))
        }

        return tokens
    }

    // PERF: Static keyword set — compiled once, not on every call
    private static let keywordSet: Set<String> = [
        "import", "export", "from", "as",
        "struct", "class", "enum", "protocol", "extension", "func", "var", "let",
        "if", "else", "for", "while", "repeat", "switch", "case", "default",
        "break", "continue", "return", "throw", "throws", "try", "catch",
        "do", "in", "where", "guard", "defer",
        "public", "private", "fileprivate", "internal", "open",
        "static", "final", "override", "mutating", "nonmutating",
        "async", "await",
        "true", "false", "nil",
        "self", "super",
        // JS/Python-ish
        "const", "function", "new", "this",
        "def", "pass", "lambda", "None"
    ]

    private func isKeyword(_ word: Substring) -> Bool {
        // PERF: Compare Substring directly via String init avoided — use contains with String
        // Swift's Set.contains uses hash, so String(word) is needed, but word is typically short
        word.count < 20 && Self.keywordSet.contains(String(word))
    }

    private func looksLikeTypeName(_ word: Substring) -> Bool {
        // Simple heuristic: PascalCase (leading uppercase).
        guard let first = word.first else { return false }
        return first.isUppercase
    }

    // MARK: - Diff colors

    private func diffColor(for kind: MinimapDiffIndicator.Kind) -> Color {
        switch kind {
        case .added:
            return Color.green
        case .modified:
            return Color(red: 0.89, green: 0.75, blue: 0.55)
        case .deleted:
            // VS Code uses red-ish for deletions too; keep distinct via slightly different tone.
            return Color(red: 1.0, green: 0.35, blue: 0.35)
        }
    }
}
