import SwiftUI

struct MinimapView: View {
    let content: String
    @Binding var scrollOffset: CGFloat
    @Binding var scrollViewHeight: CGFloat
    let totalContentHeight: CGFloat
    
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    
    private let minimapHeight: CGFloat = 300
    private let minimapWidth: CGFloat = 60
    private let lineHeight: CGFloat = 2
    private let spacing: CGFloat = 1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Background
                Rectangle()
                    .fill(Color(white: 0.15))
                
                // Code preview lines
                VStack(alignment: .leading, spacing: spacing) {
                    ForEach(Array(content.split(separator: "\n").prefix(100).enumerated()), id: \.offset) { index, line in
                        Rectangle()
                            .fill(Color(white: 0.3).opacity(lineOpacity(for: String(line))))
                            .frame(width: lineWidth(for: String(line)), height: lineHeight)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                
                // Visible region indicator box
                Rectangle()
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 1)
                    )
                    .frame(width: minimapWidth, height: visibleRegionHeight)
                    .offset(y: visibleRegionOffset)
            }
            .frame(width: minimapWidth, height: minimapHeight)
            .clipShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDrag(value: value)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
        .frame(width: minimapWidth, height: minimapHeight)
    }
    
    private var visibleRegionHeight: CGFloat {
        guard totalContentHeight > 0 else { return 0 }
        let ratio = scrollViewHeight / totalContentHeight
        return minimapHeight * min(ratio, 1.0)
    }
    
    private var visibleRegionOffset: CGFloat {
        guard totalContentHeight > 0 else { return 0 }
        let scrollRatio = scrollOffset / (totalContentHeight - scrollViewHeight)
        return scrollRatio * (minimapHeight - visibleRegionHeight)
    }
    
    private func handleDrag(value: DragGesture.Value) {
        isDragging = true
        updateScroll(for: value.location.y)
    }
    
    private func updateScroll(for yPosition: CGFloat) {
        let clampedY = max(0, min(yPosition, minimapHeight))
        let ratio = clampedY / minimapHeight
        scrollOffset = ratio * (totalContentHeight - scrollViewHeight)
    }
    
    private func lineWidth(for line: String) -> CGFloat {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return 5 }
        
        let maxWidth = minimapWidth - 8 // Padding
        let ratio = min(1.0, CGFloat(trimmed.count) / 80.0)
        return maxWidth * ratio
    }
    
    private func lineOpacity(for line: String) -> Double {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return 0.1 }
        if trimmed.hasPrefix("//") || trimmed.hasPrefix("#") { return 0.4 }
        if trimmed.hasPrefix("import") || trimmed.hasPrefix("struct") || trimmed.hasPrefix("class") { return 0.8 }
        return 0.6
    }
}
