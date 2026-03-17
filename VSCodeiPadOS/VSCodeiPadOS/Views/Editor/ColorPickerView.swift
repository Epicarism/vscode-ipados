import SwiftUI
import UIKit

struct ColorPickerView: View {
    @ObservedObject var manager = ColorPickerManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    // Local state for sliders (synced with manager)
    @State private var redValue: Double = 255
    @State private var greenValue: Double = 255
    @State private var blueValue: Double = 255
    @State private var opacityValue: Double = 100
    @State private var hexText: String = "#FFFFFF"
    @State private var copiedFeedback = false
    
    // Recent colors persisted in AppStorage as JSON
    @AppStorage("colorPickerRecentColors") private var recentColorsJSON: String = "[]"
    
    // Preset colors
    private let presetColors: [(String, Color)] = [
        ("White",   Color(hex: "#FFFFFF")),
        ("Black",   Color(hex: "#000000")),
        ("Red",     Color(hex: "#FF0000")),
        ("Green",   Color(hex: "#00FF00")),
        ("Blue",    Color(hex: "#0000FF")),
        ("Yellow",  Color(hex: "#FFFF00")),
        ("Cyan",    Color(hex: "#00FFFF")),
        ("Magenta", Color(hex: "#FF00FF"))
    ]
    
    private var theme: Theme { themeManager.currentTheme }
    
    // Computed recent colors
    private var recentColors: [Color] {
        guard let data = recentColorsJSON.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return array.map { Color(hex: $0) }
    }
    
    var body: some View {
        Group {
            if manager.state.isVisible {
                GeometryReader { geo in
                    let safeWidth = min(geo.size.width - 32, 340)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header
                            headerBar
                            
                            // Large preview swatch
                            previewSwatch
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                            
                            // Native ColorPicker
                            nativeColorPickerSection
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                            
                            // Hex input + Copy button
                            hexInputRow
                                .padding(.horizontal, 16)
                                .padding(.top, 10)
                            
                            // RGB Sliders
                            rgbSlidersSection
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                            
                            // Opacity slider
                            opacitySliderSection
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                            
                            // Preset colors
                            presetColorsSection
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                            
                            // Recent colors
                            if !recentColors.isEmpty {
                                recentColorsSection
                                    .padding(.horizontal, 16)
                                    .padding(.top, 10)
                            }
                            
                            // Bottom spacing
                            Spacer(minLength: 12)
                        }
                        .frame(width: safeWidth)
                    }
                    .frame(width: safeWidth).frame(maxHeight: 580)
                    .background(theme.sidebarBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(theme.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 8)
                    .position(x: manager.state.position.x, y: manager.state.position.y + 30)
                    .onChange(of: manager.state.selectedColor) {
                        syncSlidersFromColor(manager.state.selectedColor)
                        syncHexFromColor(manager.state.selectedColor)
                    }
                    .onChange(of: manager.state.isVisible) {
                        if manager.state.isVisible {
                            syncSlidersFromColor(manager.state.selectedColor)
                            syncHexFromColor(manager.state.selectedColor)
                        }
                    }
                    .onAppear {
                        syncSlidersFromColor(manager.state.selectedColor)
                        syncHexFromColor(manager.state.selectedColor)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: manager.state.isVisible)
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.tabActiveForeground)
            
            Text("Color Picker")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.tabActiveForeground)
            
            Spacer()
            
            Button(action: {
                addToRecentColors()
                manager.hideColorPicker()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(theme.disabledForeground)
                    .frame(width: 24, height: 24)
                    .background(theme.tabActiveBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(theme.tabActiveBackground.opacity(0.6))
    }
    
    // MARK: - Preview Swatch
    
    private var previewSwatch: some View {
        ZStack {
            // Checkerboard background for alpha visibility
            CheckerboardView()
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(height: 64)
            
            // Color fill
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(manager.state.selectedColor)
                .frame(height: 64)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(theme.border, lineWidth: 0.5)
                )
            
            // Hex label overlay
            VStack(spacing: 2) {
                Text(manager.state.selectedColor.toHex() ?? "#FFFFFF")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                
                Text("\(Int(opacityValue))% opacity")
                    .font(.system(size: 10, weight: .medium))
                    .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
            }
            .foregroundStyle(textColorForBackground(manager.state.selectedColor))
        }
    }
    
    // MARK: - Native ColorPicker
    
    private var nativeColorPickerSection: some View {
        ColorPicker("", selection: Binding(
            get: { manager.state.selectedColor },
            set: { newColor in
                manager.updateColor(newColor)
            }
        ))
        .labelsHidden()
        .frame(height: 44)
    }
    
    // MARK: - Hex Input Row
    
    private var hexInputRow: some View {
        HStack(spacing: 8) {
            Text("#")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(theme.disabledForeground)
            
            TextField("RRGGBB", text: $hexText)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(theme.tabActiveForeground)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(theme.tabActiveBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(theme.border, lineWidth: 0.5)
                )
                .onChange(of: hexText) {
                    applyHexText(hexText)
                }
                .onSubmit {
                    applyHexText(hexText)
                }
            
            Button(action: copyHexToClipboard) {
                HStack(spacing: 4) {
                    Image(systemName: copiedFeedback ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 11, weight: .semibold))
                    Text(copiedFeedback ? "Copied" : "Copy")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(theme.tabActiveForeground)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(theme.activeBorder.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(theme.activeBorder.opacity(0.5), lineWidth: 0.5)
                )
                .animation(.easeInOut(duration: 0.15), value: copiedFeedback)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - RGB Sliders
    
    private var rgbSlidersSection: some View {
        VStack(spacing: 6) {
            sliderRow(label: "R", value: $redValue, range: 0...255, color: .red)
            sliderRow(label: "G", value: $greenValue, range: 0...255, color: .green)
            sliderRow(label: "B", value: $blueValue, range: 0...255, color: .blue)
        }
        .onChange(of: redValue) { updateColorFromSliders() }
        .onChange(of: greenValue) { updateColorFromSliders() }
        .onChange(of: blueValue) { updateColorFromSliders() }
    }
    
    private func sliderRow(label: String, value: Binding<Double>, range: ClosedRange<Double>, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .frame(width: 14, alignment: .trailing)
            
            Slider(value: value, in: range, step: 1)
                .tint(color)
            
            Text("\(Int(value.wrappedValue))")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(theme.disabledForeground)
                .frame(width: 28, alignment: .trailing)
        }
    }
    
    // MARK: - Opacity Slider
    
    private var opacitySliderSection: some View {
        HStack(spacing: 8) {
            Text("A")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(theme.disabledForeground)
                .frame(width: 14, alignment: .trailing)
            
            Slider(value: $opacityValue, in: 0...100, step: 1)
                .tint(theme.activeBorder)
            
            Text("\(Int(opacityValue))%")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(theme.disabledForeground)
                .frame(width: 32, alignment: .trailing)
        }
        .onChange(of: opacityValue) { updateColorFromSliders() }
    }
    
    // MARK: - Preset Colors
    
    private var presetColorsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("Presets")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 8), spacing: 6) {
                ForEach(presetColors, id: \.0) { item in
                    presetColorButton(color: item.1, name: item.0)
                }
            }
        }
    }
    
    private func presetColorButton(color: Color, name: String) -> some View {
        Button {
            selectPreset(color)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(color)
                    .frame(height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(theme.border, lineWidth: 0.5)
                    )
            }
        }
        .buttonStyle(.plain)
        .help(name)
    }
    
    // MARK: - Recent Colors
    
    private var recentColorsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                sectionLabel("Recent")
                Spacer()
                Button(action: clearRecentColors) {
                    Text("Clear")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(theme.disabledForeground)
                }
                .buttonStyle(.plain)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 8), spacing: 6) {
                ForEach(Array(recentColors.enumerated()), id: \.offset) { _, color in
                    Button {
                        selectPreset(color)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(color)
                                .frame(height: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .stroke(theme.border, lineWidth: 0.5)
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(theme.disabledForeground)
            .tracking(0.5)
    }
    
    private func textColorForBackground(_ color: Color) -> Color {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = (0.299 * r + 0.587 * g + 0.114 * b) * a + (1 - a) * 0.5
        return luminance > 0.5 ? .black : .white
    }
    
    // MARK: - Sync Logic
    
    private func syncSlidersFromColor(_ color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return }
        redValue = round(r * 255)
        greenValue = round(g * 255)
        blueValue = round(b * 255)
        opacityValue = round(a * 100)
    }
    
    private func syncHexFromColor(_ color: Color) {
        hexText = color.toHex()?.replacingOccurrences(of: "#", with: "") ?? "FFFFFF"
    }
    
    private func updateColorFromSliders() {
        let newColor = Color(
            .sRGB,
            red: redValue / 255,
            green: greenValue / 255,
            blue: blueValue / 255,
            opacity: opacityValue / 100
        )
        manager.updateColor(newColor)
        syncHexFromColor(newColor)
    }
    
    private func applyHexText(_ text: String) {
        let cleaned = text.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6 || cleaned.count == 3 else { return }
        
        var hexToParse = cleaned
        if cleaned.count == 3 {
            let chars = Array(cleaned)
            let c0 = String(chars[0])
            let c1 = String(chars[1])
            let c2 = String(chars[2])
            hexToParse = c0 + c0 + c1 + c1 + c2 + c2
        }
        
        guard let intValue = UInt64(hexToParse, radix: 16) else { return }
        let r = Double((intValue >> 16) & 0xFF)
        let g = Double((intValue >> 8) & 0xFF)
        let b = Double(intValue & 0xFF)
        
        redValue = r
        greenValue = g
        blueValue = b
        
        let newColor = Color(
            .sRGB,
            red: r / 255,
            green: g / 255,
            blue: b / 255,
            opacity: opacityValue / 100
        )
        manager.updateColor(newColor)
    }
    
    private func selectPreset(_ color: Color) {
        manager.updateColor(color)
        syncSlidersFromColor(color)
        syncHexFromColor(color)
    }
    
    // MARK: - Recent Colors Management
    
    private func addToRecentColors() {
        let hex = manager.state.selectedColor.toHex() ?? "#FFFFFF"
        let rgbHex: String
        if hex.count > 7 {
            rgbHex = String(hex.dropLast(hex.count - 7))
        } else {
            rgbHex = hex
        }
        
        var colors: [String] = []
        if let data = recentColorsJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            colors = decoded.filter { $0 != rgbHex }
        }
        colors.insert(rgbHex, at: 0)
        if colors.count > 8 { colors = Array(colors.prefix(8)) }
        
        if let encoded = try? JSONEncoder().encode(colors),
           let json = String(data: encoded, encoding: .utf8) {
            recentColorsJSON = json
        }
    }
    
    private func clearRecentColors() {
        recentColorsJSON = "[]"
    }
    
    // MARK: - Clipboard
    
    private func copyHexToClipboard() {
        let hex = manager.state.selectedColor.toHex() ?? "#FFFFFF"
        UIPasteboard.general.string = hex
        
        copiedFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copiedFeedback = false
        }
    }
}

// MARK: - Checkerboard Background

private struct CheckerboardView: View {
    let squareSize: CGFloat = 8
    let color1 = Color.white
    let color2 = Color(white: 0.85)
    
    var body: some View {
        Canvas { context, size in
            let rows = Int(ceil(size.height / squareSize))
            let cols = Int(ceil(size.width / squareSize))
            for row in 0..<rows {
                for col in 0..<cols {
                    let isEven = (row + col) % 2 == 0
                    let rect = CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    context.fill(
                        Path(rect),
                        with: .color(isEven ? color1 : color2)
                    )
                }
            }
        }
    }
}
