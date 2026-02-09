import Foundation
import SwiftUI
import UIKit

@MainActor
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - AppStorage keys

    @AppStorage("fontSize") var fontSize: Double = 14 {
        willSet { objectWillChange.send() }
    }

    @AppStorage("fontFamily") var fontFamily: String = "Menlo" {
        willSet { objectWillChange.send() }
    }

    @AppStorage("tabSize") var tabSize: Int = 4 {
        willSet { objectWillChange.send() }
    }

    @AppStorage("wordWrap") var wordWrap: Bool = true {
        willSet { objectWillChange.send() }
    }

    /// Mirrors SettingsView's picker tags: off / afterDelay / onFocusChange / onWindowChange
    @AppStorage("autoSave") var autoSaveRaw: String = AutoSaveMode.off.rawValue {
        willSet { objectWillChange.send() }
    }

    @AppStorage("minimapEnabled") var minimapEnabled: Bool = true {
        willSet { objectWillChange.send() }
    }

    private init() {}

    // MARK: - Types

    enum AutoSaveMode: String, CaseIterable {
        case off
        case afterDelay
        case onFocusChange
        case onWindowChange
    }

    var autoSaveMode: AutoSaveMode {
        get { AutoSaveMode(rawValue: autoSaveRaw) ?? .off }
        set { autoSaveRaw = newValue.rawValue }
    }

    /// Delay used when `autoSaveMode == .afterDelay`.
    let autoSaveDelay: TimeInterval = 1.0

    // MARK: - Derived editor styling

    var clampedTabSize: Int {
        max(1, min(tabSize, 16))
    }

    var editorUIFont: UIFont {
        font(forFamily: fontFamily, size: CGFloat(fontSize))
    }

    func font(forFamily family: String, size: CGFloat) -> UIFont {
        // Try common iOS font PostScript names first.
        let candidates: [String]
        switch family {
        case "Menlo":
            candidates = ["Menlo-Regular", "Menlo"]
        case "Courier New":
            candidates = ["CourierNewPSMT", "Courier New"]
        case "SF Mono":
            candidates = ["SFMono-Regular", "SF Mono", ".SFMono-Regular"]
        case "Fira Code":
            candidates = ["FiraCode-Regular", "Fira Code"]
        case "JetBrains Mono":
            candidates = ["JetBrainsMono-Regular", "JetBrains Mono"]
        default:
            candidates = [family]
        }

        for name in candidates {
            if let font = UIFont(name: name, size: size) {
                // Ensure monospaced feel if available; otherwise return as-is.
                return font
            }
        }

        // Fallback
        return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }

    /// A stable key used to detect when re-highlighting is necessary.
    var editorStyleKey: String {
        "\(fontFamily)|\(Int(fontSize))|\(clampedTabSize)"
    }
}
