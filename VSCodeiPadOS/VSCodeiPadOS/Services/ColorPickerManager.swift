import SwiftUI
import Combine

struct ColorPickerState {
    var isVisible: Bool = false
    var selectedColor: Color = .white
    var originalText: String = ""
    var range: NSRange = NSRange(location: 0, length: 0)
    var position: CGPoint = .zero
}

@MainActor
final class ColorPickerManager: ObservableObject {
    static let shared = ColorPickerManager()
    
    @Published var state = ColorPickerState()
    
    // Callback for when color changes
    var onColorChanged: ((Color, String) -> Void)?
    
    private init() {}
    
    func showColorPicker(at point: CGPoint, color: Color, originalText: String, range: NSRange) {
        state.position = point
        state.selectedColor = color
        state.originalText = originalText
        state.range = range
        state.isVisible = true
    }
    
    func hideColorPicker() {
        state.isVisible = false
    }
    
    func updateColor(_ color: Color) {
        state.selectedColor = color
        if let onColorChanged = onColorChanged {
            // Convert color back to appropriate string format based on original format
            // For now assuming hex or rgb
            let hex = color.toHex()
            onColorChanged(color, hex ?? "#FFFFFF")
        }
    }
}