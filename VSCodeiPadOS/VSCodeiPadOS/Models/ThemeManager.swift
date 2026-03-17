import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {
    @AppStorage("selectedThemeId") var selectedThemeId: String = "dark_plus"
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