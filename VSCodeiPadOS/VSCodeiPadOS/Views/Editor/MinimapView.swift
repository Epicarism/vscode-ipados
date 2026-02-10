import SwiftUI

/// VS Code–style minimap with:
/// - syntax-colored tiny preview
/// - visible region overlay
/// - tap/drag to scroll
/// - optional git diff indicators (added/modified/deleted)
struct MinimapView: View {
    // MARK: - External inputs

    let content: String
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

    // MARK: - View

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let minimapHeight = max(1, size.height)
            let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
            let lineCount = max(lines.count, 1)

            ZStack(alignment: .topLeading) {
                // Background
                Rectangle()
                    .fill(Color(white: 0.13))

                // Syntax-colored code preview
                Canvas { context, canvasSize in
                    drawMinimapPreview(
                        in: &context,
                        size: canvasSize,
                        lines: lines
                    )
                }
                .allowsHitTesting(false)

                // Git diff indicators (thin left bars)
                diffIndicatorsLayer(
                    minimapHeight: minimapHeight,
                    lineCount: lineCount
                )
                .allowsHitTesting(false)

                // Visible region highlight
                visibleRegionLayer(minimapHeight: minimapHeight)
                    .allowsHitTesting(false)
            }
            .frame(width: minimapWidth, height: minimapHeight)
            .clipShape(Rectangle())
            .contentShape(Rectangle())
            // Click-to-scroll + drag scrolling (DragGesture(minDistance: 0) captures taps too)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        isInteracting = true
                        updateScroll(forMinimapY: value.location.y, minimapHeight: minimapHeight)
                    }
                    .onEnded { _ in
                        isInteracting = false
                    }
            )
        }
        .frame(width: minimapWidth)
    }

    // MARK: - Layers

    @ViewBuilder
    private func visibleRegionLayer(minimapHeight: CGFloat) -> some View {
        let height = visibleRegionHeight(minimapHeight: minimapHeight)
        let offset = visibleRegionOffset(minimapHeight: minimapHeight, visibleHeight: height)

        Rectangle()
            .fill(Color.accentColor.opacity(isInteracting ? 0.22 : 0.16))
            .overlay(
                Rectangle()
                    .stroke(Color.accentColor.opacity(0.65), lineWidth: 1)
            )
            .frame(width: minimapWidth, height: height)
            .offset(y: offset)
    }

    @ViewBuilder
    private func diffIndicatorsLayer(minimapHeight: CGFloat, lineCount: Int) -> some View {
        // VS Code minimap diff markers are thin and pinned to the left.
        let barWidth: CGFloat = 2

        // Guard against division by zero
        if lineCount > 0 {
            ForEach(diffIndicators) { indicator in
                let startLine = max(0, min(indicator.lineRange.lowerBound, lineCount - 1))
                let endLineExclusive = max(startLine + 1, min(indicator.lineRange.upperBound, lineCount))

                let startY = (CGFloat(startLine) / CGFloat(max(lineCount, 1))) * minimapHeight
                let endY = (CGFloat(endLineExclusive) / CGFloat(max(lineCount, 1))) * minimapHeight
                let height = max(2, endY - startY)

                Rectangle()
                    .fill(diffColor(for: indicator.kind).opacity(0.95))
                    .frame(width: barWidth, height: height)
                    .offset(x: 0, y: startY)
            }
        }
    }

    // MARK: - Visible region math

    private func visibleRegionHeight(minimapHeight: CGFloat) -> CGFloat {
        guard totalContentHeight > 0 else { return 0 }
        let ratio = scrollViewHeight / totalContentHeight
        return minimapHeight * min(max(ratio, 0), 1.0)
    }

    private func visibleRegionOffset(minimapHeight: CGFloat, visibleHeight: CGFloat) -> CGFloat {
        let scrollable = max(0, totalContentHeight - scrollViewHeight)
        guard scrollable > 0 else { return 0 }

        let scrollRatio = min(max(scrollOffset / scrollable, 0), 1.0)
        return scrollRatio * max(0, minimapHeight - visibleHeight)
    }

    // MARK: - Interaction

    /// Requests scroll so that the main editor's visible region is centered around the minimap Y position.
    /// Uses callback to parent - minimap never directly controls editor scroll (prevents jitter).
    private func updateScroll(forMinimapY yPosition: CGFloat, minimapHeight: CGFloat) {
        guard totalContentHeight > 0 else { return }
        guard let onScrollRequested = onScrollRequested else { return }

        let clampedY = max(0, min(yPosition, minimapHeight))
        let ratio = (minimapHeight > 0) ? (clampedY / minimapHeight) : 0

        // Target a center position (VS Code behavior).
        let targetCenter = ratio * totalContentHeight
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
        lines: [Substring]
    ) {
        let paddingX: CGFloat = 4
        let paddingY: CGFloat = 2

        let contentWidth = max(0, size.width - (paddingX * 2))
        let contentHeight = max(0, size.height - (paddingY * 2))

        guard contentWidth > 0, contentHeight > 0 else { return }

        let lineCount = max(lines.count, 1)
        
        // FIXED: Use fixed pixels per line (VS Code style) instead of stretching to fill
        // This ensures the minimap always shows a tiny preview regardless of file size
        let targetPixelsPerLine: CGFloat = 2.5
        let pixelsPerLine = targetPixelsPerLine
        
        // Calculate how many lines we can show in the minimap
        let visibleLines = Int(contentHeight / pixelsPerLine)
        
        // Calculate scroll offset to show the right portion of the document
        // Use scrollOffset and totalContentHeight to calculate current position
        let scrollRatio = totalContentHeight > 0 ? Double(scrollOffset) / Double(max(totalContentHeight - scrollViewHeight, 1)) : 0
        let startLine = max(0, Int(scrollRatio * Double(max(0, lineCount - visibleLines))))

        // Token-block mode (colored rectangles) - VS Code style minimap
        let minBarHeight: CGFloat = 1
        let barHeight = max(minBarHeight, pixelsPerLine)

        // Approximate "characters" across minimap width.
        let maxChars: CGFloat = 120
        let charWidth = contentWidth / maxChars

        // Render lines starting from startLine (scrolls with document)
        let endLine = min(startLine + visibleLines + 1, lineCount)
        
        // Guard against invalid range (endLine must be >= startLine)
        guard endLine >= startLine else { return }
        
        for i in startLine..<endLine {
            let displayIndex = i - startLine
            let y = paddingY + (CGFloat(displayIndex) * pixelsPerLine)
            if y > size.height { break }

            let line = lines.indices.contains(i) ? lines[i] : Substring("")
            let tokens = tokenize(line)

            var x = paddingX
            let yAligned = y.rounded(FloatingPointRoundingRule.down)

            if tokens.isEmpty {
                // Render faint whitespace line.
                let rect = CGRect(x: x, y: yAligned, width: max(4, contentWidth * 0.15), height: barHeight)
                context.fill(Path(rect), with: .color(Color(white: 0.45).opacity(0.10)))
                continue
            }

            for token in tokens {
                guard x < (paddingX + contentWidth) else { break }
                let w = max(1, CGFloat(token.text.count) * charWidth)
                let rect = CGRect(x: x, y: yAligned, width: min(w, paddingX + contentWidth - x), height: barHeight)
                context.fill(Path(rect), with: .color(token.color.opacity(0.80)))
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

        var color: Color {
            switch kind {
            case .plain:
                return Color(white: 0.70)
            case .keyword:
                return Color(red: 0.78, green: 0.53, blue: 0.95) // purple-ish
            case .string:
                return Color(red: 0.80, green: 0.72, blue: 0.43) // yellow-ish
            case .comment:
                return Color(red: 0.46, green: 0.60, blue: 0.50) // green-ish
            case .number:
                return Color(red: 0.40, green: 0.73, blue: 0.92) // blue-ish
            case .typeName:
                return Color(red: 0.45, green: 0.83, blue: 0.70) // teal-ish
            }
        }
    }

    private func makeAttributedLine(from line: Substring, fontSize: CGFloat) -> AttributedString {
        let tokens = tokenize(line)

        var out = AttributedString()
        for token in tokens {
            var chunk = AttributedString(String(token.text))
            chunk.font = .system(size: fontSize, weight: .regular, design: .monospaced)
            chunk.foregroundColor = token.color
            out.append(chunk)
        }

        if out.characters.isEmpty {
            // Preserve a tiny amount of "whitespace presence" so empty lines still show.
            var chunk = AttributedString(" ")
            chunk.font = .system(size: fontSize, weight: .regular, design: .monospaced)
            chunk.foregroundColor = Color(white: 0.7).opacity(0.25)
            out.append(chunk)
        }

        return out
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

    private func isKeyword(_ word: Substring) -> Bool {
        // Small superset of common Swift/JS/Python keywords.
        // (We can't depend on a full parser here.)
        let keywords: Set<String> = [
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
            "const", "function", "async", "await", "new", "this",
            "def", "pass", "lambda", "None"
        ]
        return keywords.contains(String(word))
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
            return Color.red
        case .deleted:
            // VS Code uses red-ish for deletions too; keep distinct via slightly different tone.
            return Color(red: 1.0, green: 0.35, blue: 0.35)
        }
    }
}
