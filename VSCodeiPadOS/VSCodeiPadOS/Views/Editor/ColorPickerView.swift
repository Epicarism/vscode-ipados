import SwiftUI

struct ColorPickerView: View {
    @ObservedObject var manager = ColorPickerManager.shared
    
    var body: some View {
        Group {
            if manager.state.isVisible {
                VStack(spacing: 12) {
                    ColorPicker("Pick Color", selection: Binding(
                        get: { manager.state.selectedColor },
                        set: { manager.updateColor($0) }
                    ))
                    .labelsHidden()
                    .frame(height: 200)
                    
                    Button("Close") {
                        manager.hideColorPicker()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(radius: 10)
                .frame(width: 250)
                .position(x: manager.state.position.x, y: manager.state.position.y + 120)
            }
        }
    }
}
