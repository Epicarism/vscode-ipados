import SwiftUI
import UIKit

/// Renders inline ghost text suggestions with fade animations and multi-line support.
///
/// This view displays AI-generated code suggestions as semi-transparent gray text
/// positioned at the cursor location. Users can accept suggestions with the Tab key.
///
/// Features:
/// - Ghost text overlay with proper positioning based on cursor location
/// - Multi-line suggestion support with line breaks
/// - Fade in/out animations for smooth appearance/disappearance
/// - "Tab to accept" indicator
/// - Integration with InlineSuggestionManager via @EnvironmentObject
/// - Proper handling of partial accept state
struct InlineSuggestionView: View {
    /// The code content being edited (needed for positioning calculations)
    let code: String
    
    /// Language for syntax context (affects styling)
    let language: CodeLanguage
    
    /// Current scroll position (line index) of the editor
    let scrollPosition: Int
    
    /// Height of each line in the editor
    let lineHeight: CGFloat
    
    /// Font size used in the editor
    let fontSize: CGFloat
    
    /// Width reserved for the gutter (line numbers)
    var gutterWidth: CGFloat = 60
    
    /// Insets used by the underlying UITextView
    var textInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    /// Width reserved at the right edge (e.g. minimap)
    var rightReservedWidth: CGFloat = 0
    
    /// How many spaces a tab visually represents
    var tabSize: Int = 4
    
    /// Animation duration for fade in/out
    var animationDuration: Double = 0.15
    
    /// The manager that provides suggestion state
    @EnvironmentObject var suggestionManager: InlineSuggestionManager
    
    /// Controls the visibility animation state
    @State private var isVisible: Bool = false
    
    /// The ghost text to display (filtered to show only unaccepted portion)
    private var ghostText: String {
        suggestionManager.ghostText
    }
    
    /// Whether there is an active suggestion to display
    private var hasSuggestion: Bool {
        !ghostText.isEmpty
    }
    
    /// The cursor position for rendering
    private var cursorPosition: InlineSuggestionManager.CursorPosition {
        suggestionManager.cursorPosition
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                if isVisible && hasSuggestion {
                    suggestionContent(geometry: geo)
                }
            }
            .frame(
                width: max(0, geo.size.width - rightReservedWidth),
                height: geo.size.height,
                alignment: .topLeading
            )
            .clipped()
        }
        .allowsHitTesting(false)
        .onAppear {
            updateVisibility()
        }
        .onChange(of: ghostText) { _ in
            updateVisibility()
        }
        .onChange(of: suggestionManager.currentSuggestion) { _ in
            updateVisibility()
        }
    }
    
    /// Renders the suggestion content with positioning and styling
    private func suggestionContent(geometry geo: GeometryProxy) -> some View {
        let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let charWidth = (" " as NSString).size(withAttributes: [.font: font]).width
        let fontLineHeight = font.lineHeight
        let baselineAdjustment = max(0, (lineHeight - fontLineHeight) / 2)
        
        let lines = code.components(separatedBy: .newlines)
        
        // Calculate the starting position
        let startX: CGFloat
        let startY: CGFloat
        
        // Get the current line text up to cursor position
        let currentLineIndex = min(cursorPosition.line, max(0, lines.count - 1))
        let currentLine = lines.indices.contains(currentLineIndex) ? lines[currentLineIndex] : ""
        
        // Calculate visual column for current position
        let visualColumn = visualColumn(in: currentLine, utf16Column: cursorPosition.column, tabSize: tabSize)
        
        // Calculate starting X position (gutter + insets + character offset)
        startX = gutterWidth + textInsets.left + (CGFloat(visualColumn) * charWidth)
        
        // Calculate starting Y position (adjusted for scroll)
        let visibleLineIndex = currentLineIndex - scrollPosition
        startY = textInsets.top + baselineAdjustment + (CGFloat(visibleLineIndex) * lineHeight)
        
        // Split ghost text into lines
        let ghostLines = ghostText.components(separatedBy: .newlines)
        
        return ZStack(alignment: .topLeading) {
            // Render each line of the suggestion
            ForEach(Array(ghostLines.enumerated()), id: \.offset) { index, line in
                // For multi-line suggestions, only the first line starts at cursor X
                // Subsequent lines start from the left margin
                let xOffset: CGFloat = index == 0 ? startX : gutterWidth + textInsets.left
                let yOffset: CGFloat = startY + (CGFloat(index) * lineHeight)
                
                // For lines after the first, include a visual indicator that it's a continuation
                let displayText = line
                
                Text(displayText)
                    .font(.system(size: fontSize, design: .monospaced))
                    .foregroundColor(Color.gray.opacity(0.6))
                    .offset(x: xOffset, y: yOffset)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            
            // Tab to accept indicator
            tabIndicatorView(
                startX: startX,
                startY: startY,
                ghostLines: ghostLines,
                charWidth: charWidth,
                font: font
            )
        }
        .transition(
            .asymmetric(
                insertion: .opacity.animation(.easeIn(duration: animationDuration)),
                removal: .opacity.animation(.easeOut(duration: animationDuration))
            )
        )
    }
    
    /// Renders the "Tab to accept" indicator
    private func tabIndicatorView(
        startX: CGFloat,
        startY: CGFloat,
        ghostLines: [String],
        charWidth: CGFloat,
        font: UIFont
    ) -> some View {
        // Calculate indicator position (below the suggestion or at the end of single line)
        let indicatorY: CGFloat
        let indicatorX: CGFloat
        
        if ghostLines.count > 1 {
            // For multi-line, show indicator at the end of last line
            let lastLine = ghostLines.last ?? ""
            let lastLineWidth = (lastLine as NSString).size(withAttributes: [.font: font]).width
            indicatorX = startX + lastLineWidth
            indicatorY = startY + (CGFloat(ghostLines.count - 1) * lineHeight)
        } else {
            // For single line, show indicator at the end of the text
            let lineWidth = (ghostText as NSString).size(withAttributes: [.font: font]).width
            indicatorX = startX + lineWidth + 8 // Small gap after text
            indicatorY = startY
        }
        
        return HStack(spacing: 4) {
            Image(systemName: "arrow.right.to.line")
                .font(.system(size: fontSize * 0.7))
            
            Text("Tab")
                .font(.system(size: fontSize * 0.7, weight: .medium))
        }
        .foregroundColor(Color.gray.opacity(0.5))
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.1))
        )
        .offset(x: indicatorX, y: indicatorY + (lineHeight - font.lineHeight) / 2)
        .opacity(0.7)
    }
    
    /// Updates the visibility state with animation
    private func updateVisibility() {
        let shouldBeVisible = hasSuggestion && isCursorVisible()
        
        if shouldBeVisible != isVisible {
            withAnimation(.easeInOut(duration: animationDuration)) {
                isVisible = shouldBeVisible
            }
        }
    }
    
    /// Checks if the cursor is currently visible in the viewport
    private func isCursorVisible() -> Bool {
        let cursorLine = cursorPosition.line
        // Allow some margin for visibility (show if within viewport ± a few lines)
        let visibleRange = scrollPosition...(scrollPosition + 50) // Assuming ~50 visible lines
        return visibleRange.contains(cursorLine)
    }
    
    /// Calculates the visual column position accounting for tabs
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

// MARK: - Preview Support

#if DEBUG
struct InlineSuggestionView_Previews: PreviewProvider {
    static let mockManager: InlineSuggestionManager = {
        let manager = InlineSuggestionManager()
        manager.currentSuggestion = "\n    print(\"Hello, World!\")\n    return true"
        manager.cursorPosition = InlineSuggestionManager.CursorPosition(line: 5, column: 12)
        return manager
    }()
    
    static var previews: some View {
        ZStack {
            // Background simulating editor
            Color.black.opacity(0.9)
            
            // Mock code lines
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<10) { i in
                    Text("Line \(i + 1): Some code here...")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(height: 20, alignment: .leading)
                }
            }
            .padding(.leading, 60)
            
            // Inline suggestion overlay
            InlineSuggestionView(
                code: "func example() {\n    let x = 10\n    return x\n}",
                language: .swift,
                scrollPosition: 0,
                lineHeight: 20,
                fontSize: 14
            )
            .environmentObject(mockManager)
        }
        .frame(width: 400, height: 300)
    }
}
#endif
