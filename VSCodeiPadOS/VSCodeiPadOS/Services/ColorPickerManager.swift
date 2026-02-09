import SwiftUI
import Combine

struct ColorPickerState {
    var isVisible: Bool = false
    var selectedColor: Color = .white
    var originalText: String = ""
    var range: NSRange = NSRange(location: 0, length: 0)
    var position: CGPoint = .zero
}

class ColorPickerManager: ObservableObject {
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

extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if a != 1.0 {
            return String(format: "#%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}