import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {
    @AppStorage("selectedThemeId") var selectedThemeId: String = "dark_plus"
    @AppStorage("followSystemAppearance") var followSystemAppearance: Bool = true
    @Published var currentTheme: Theme
    
    static let shared = ThemeManager()
    
    // Quick access to current theme
    static var current: Theme { shared.currentTheme }
    
    init() {
        let themeId = UserDefaults.standard.string(forKey: "selectedThemeId") ?? "dark_plus"
        self.currentTheme = Theme.allThemes.first(where: { $0.id == themeId }) ?? .darkPlus
    }
    
    func switchTheme(to themeId: String) {
        if let theme = Theme.allThemes.first(where: { $0.id == themeId }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.currentTheme = theme
            }
            self.selectedThemeId = themeId
        }
    }
    
    func switchTheme(to theme: Theme) {
        switchTheme(to: theme.id)
    }
    
    // MARK: - System Appearance
    
    /// Called when system color scheme changes. Auto-switches theme if followSystemAppearance is enabled.
    func applySystemAppearance(_ colorScheme: ColorScheme) {
        guard followSystemAppearance else { return }
        if colorScheme == .dark {
            // Switch to a dark theme if we're currently on a light one
            if !currentTheme.isDark {
                let preferred = Theme.allThemes.first(where: { $0.id == "monokai" }) ?? .darkPlus
                switchTheme(to: preferred)
            }
        } else {
            // Switch to a light theme if we're currently on a dark one
            if currentTheme.isDark {
                let preferred = Theme.allThemes.first(where: { $0.id == "github_light" })
                    ?? Theme.allThemes.first(where: { !$0.isDark })
                    ?? .lightPlus
                switchTheme(to: preferred)
            }
        }
    }
    
    /// Preferred color scheme to propagate to SwiftUI based on the current theme.
    var preferredColorScheme: ColorScheme? {
        currentTheme.isDark ? .dark : .light
    }
    
    // Cycle to next theme
    func nextTheme() {
        let themes = Theme.allThemes
        guard let currentIndex = themes.firstIndex(where: { $0.id == currentTheme.id }) else {
            switchTheme(to: themes.first ?? .darkPlus)
            return
        }
        let nextIndex = (currentIndex + 1) % themes.count
        switchTheme(to: themes[nextIndex])
    }
    
    // Cycle to previous theme
    func previousTheme() {
        let themes = Theme.allThemes
        guard let currentIndex = themes.firstIndex(where: { $0.id == currentTheme.id }) else {
            switchTheme(to: themes.first ?? .darkPlus)
            return
        }
        let prevIndex = currentIndex == 0 ? themes.count - 1 : currentIndex - 1
        switchTheme(to: themes[prevIndex])
    }
    
    // Get themes by category
    var darkThemes: [Theme] {
        Theme.allThemes.filter { $0.isDark }
    }
    
    var lightThemes: [Theme] {
        Theme.allThemes.filter { !$0.isDark }
    }
    
    // Helper for file colors that adapts to theme
    func color(for filename: String) -> Color {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        // Swift
        case "swift": return .orange
        
        // JavaScript/TypeScript
        case "js", "jsx": return .yellow
        case "ts", "tsx": return .blue
        
        // Python
        case "py": return .green
        
        // Web
        case "html", "htm": return .red
        case "css", "scss": return .purple
        case "json": return .green
        case "xml", "svg": return .orange
        
        // Markdown
        case "md": return .blue
        
        // C/C++
        case "c", "cpp", "h", "hpp": return .blue
        
        // Java/Kotlin
        case "java", "kt": return .orange
        
        // Rust
        case "rs": return .orange
        
        // Go
        case "go": return .cyan
        
        // Shell scripts
        case "sh", "bash", "zsh": return .green
        
        // SQL
        case "sql": return .yellow
        
        // Config files
        case "yaml", "yml", "toml": return .red
        
        // Ruby
        case "rb": return .red
        
        // PHP
        case "php": return .purple
        
        // C#
        case "cs": return .green
        
        // R
        case "r": return .blue
        
        // Lua
        case "lua": return .blue
        
        // Dart
        case "dart": return .blue
        
        // Scala
        case "scala": return .red
        
        // Elixir
        case "ex", "exs": return .purple
        
        // Zig
        case "zig": return .orange
        
        // Vlang
        case "v": return .blue
        
        // Nim
        case "nim": return .yellow
        
        default: return currentTheme.isDark ? .white : .black
        }
    }
}