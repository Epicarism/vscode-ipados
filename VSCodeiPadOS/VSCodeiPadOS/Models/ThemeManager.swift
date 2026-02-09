import SwiftUI
import Combine

class ThemeManager: ObservableObject {
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
            switchTheme(to: themes.first!)
            return
        }
        let nextIndex = (currentIndex + 1) % themes.count
        switchTheme(to: themes[nextIndex])
    }
    
    // Cycle to previous theme
    func previousTheme() {
        let themes = Theme.allThemes
        guard let currentIndex = themes.firstIndex(where: { $0.id == currentTheme.id }) else {
            switchTheme(to: themes.first!)
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
        case "swift": return .orange
        case "js", "jsx": return .yellow
        case "ts", "tsx": return .blue
        case "py": return .green
        case "html", "htm": return .red
        case "css", "scss": return .purple
        case "json": return .green
        case "md": return .blue
        default: return currentTheme.isDark ? .white : .black
        }
    }
}