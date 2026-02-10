import SwiftUI

// MARK: - Theme Model

struct Theme: Identifiable, Hashable {
    let id: String
    let name: String
    let isDark: Bool
    
    // Editor colors
    let backgroundColor: Color
    let textColor: Color
    let lineNumberColor: Color
    let selectionColor: Color
    let cursorColor: Color
    
    // Syntax colors
    let keywordColor: Color
    let stringColor: Color
    let commentColor: Color
    let numberColor: Color
    let functionColor: Color
    let typeColor: Color
    let variableColor: Color
    let operatorColor: Color
    
    // UI colors
    let sidebarBackground: Color
    let tabBarBackground: Color
    let statusBarBackground: Color
    let borderColor: Color
    
    // Predefined themes
    static let defaultDark = Theme(
        id: "dark-default",
        name: "Dark+ (default)",
        isDark: true,
        backgroundColor: Color(hex: "1e1e1e"),
        textColor: Color(hex: "d4d4d4"),
        lineNumberColor: Color(hex: "858585"),
        selectionColor: Color(hex: "264f78"),
        cursorColor: Color(hex: "aeafad"),
        keywordColor: Color(hex: "569cd6"),
        stringColor: Color(hex: "ce9178"),
        commentColor: Color(hex: "6a9955"),
        numberColor: Color(hex: "b5cea8"),
        functionColor: Color(hex: "dcdcaa"),
        typeColor: Color(hex: "4ec9b0"),
        variableColor: Color(hex: "9cdcfe"),
        operatorColor: Color(hex: "d4d4d4"),
        sidebarBackground: Color(hex: "252526"),
        tabBarBackground: Color(hex: "252526"),
        statusBarBackground: Color(hex: "007acc"),
        borderColor: Color(hex: "3c3c3c")
    )
    
    static let defaultLight = Theme(
        id: "light-default",
        name: "Light+ (default)",
        isDark: false,
        backgroundColor: Color(hex: "ffffff"),
        textColor: Color(hex: "000000"),
        lineNumberColor: Color(hex: "237893"),
        selectionColor: Color(hex: "add6ff"),
        cursorColor: Color(hex: "000000"),
        keywordColor: Color(hex: "0000ff"),
        stringColor: Color(hex: "a31515"),
        commentColor: Color(hex: "008000"),
        numberColor: Color(hex: "098658"),
        functionColor: Color(hex: "795e26"),
        typeColor: Color(hex: "267f99"),
        variableColor: Color(hex: "001080"),
        operatorColor: Color(hex: "000000"),
        sidebarBackground: Color(hex: "f3f3f3"),
        tabBarBackground: Color(hex: "f3f3f3"),
        statusBarBackground: Color(hex: "007acc"),
        borderColor: Color(hex: "e7e7e7")
    )
    
    static let monokai = Theme(
        id: "monokai",
        name: "Monokai",
        isDark: true,
        backgroundColor: Color(hex: "272822"),
        textColor: Color(hex: "f8f8f2"),
        lineNumberColor: Color(hex: "90908a"),
        selectionColor: Color(hex: "49483e"),
        cursorColor: Color(hex: "f8f8f0"),
        keywordColor: Color(hex: "f92672"),
        stringColor: Color(hex: "e6db74"),
        commentColor: Color(hex: "75715e"),
        numberColor: Color(hex: "ae81ff"),
        functionColor: Color(hex: "a6e22e"),
        typeColor: Color(hex: "66d9ef"),
        variableColor: Color(hex: "f8f8f2"),
        operatorColor: Color(hex: "f92672"),
        sidebarBackground: Color(hex: "21201d"),
        tabBarBackground: Color(hex: "1e1f1c"),
        statusBarBackground: Color(hex: "75715e"),
        borderColor: Color(hex: "3b3a32")
    )
    
    static let solarizedDark = Theme(
        id: "solarized-dark",
        name: "Solarized Dark",
        isDark: true,
        backgroundColor: Color(hex: "002b36"),
        textColor: Color(hex: "839496"),
        lineNumberColor: Color(hex: "586e75"),
        selectionColor: Color(hex: "073642"),
        cursorColor: Color(hex: "839496"),
        keywordColor: Color(hex: "859900"),
        stringColor: Color(hex: "2aa198"),
        commentColor: Color(hex: "586e75"),
        numberColor: Color(hex: "d33682"),
        functionColor: Color(hex: "268bd2"),
        typeColor: Color(hex: "b58900"),
        variableColor: Color(hex: "839496"),
        operatorColor: Color(hex: "839496"),
        sidebarBackground: Color(hex: "00252e"),
        tabBarBackground: Color(hex: "003847"),
        statusBarBackground: Color(hex: "073642"),
        borderColor: Color(hex: "073642")
    )
    
    static let allThemes: [Theme] = [.defaultDark, .defaultLight, .monokai, .solarizedDark]
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.id, forKey: "selectedThemeId")
        }
    }
    
    @Published var availableThemes: [Theme] = Theme.allThemes
    
    private init() {
        // Load saved theme or use default
        let savedThemeId = UserDefaults.standard.string(forKey: "selectedThemeId") ?? Theme.defaultDark.id
        currentTheme = Theme.allThemes.first { $0.id == savedThemeId } ?? Theme.defaultDark
    }
    
    func setTheme(_ theme: Theme) {
        currentTheme = theme
    }
    
    func setTheme(id: String) {
        if let theme = availableThemes.first(where: { $0.id == id }) {
            currentTheme = theme
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
