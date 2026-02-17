//
//  ExtensionManager.swift
//  VSCodeiPadOS
//
//  Manages IDE extensions (themes, snippets, language support)
//  Provides a curated catalog + installed extension tracking
//

import Foundation
import SwiftUI

// MARK: - Extension Model

struct IDEExtension: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let publisher: String
    let displayName: String
    let description: String
    let version: String
    let category: ExtensionCategory
    let iconName: String // SF Symbol name
    let downloadCount: Int
    let rating: Double // 0-5
    var isInstalled: Bool = false
    var isEnabled: Bool = true
    
    var fullId: String { "\(publisher).\(id)" }
    
    static func == (lhs: IDEExtension, rhs: IDEExtension) -> Bool {
        lhs.id == rhs.id && lhs.publisher == rhs.publisher
    }
}

enum ExtensionCategory: String, Codable, CaseIterable {
    case themes = "Themes"
    case languages = "Programming Languages"
    case snippets = "Snippets"
    case linters = "Linters"
    case formatters = "Formatters"
    case debuggers = "Debuggers"
    case keymaps = "Keymaps"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .themes: return "paintpalette"
        case .languages: return "chevron.left.forwardslash.chevron.right"
        case .snippets: return "text.snippet"
        case .linters: return "exclamationmark.triangle"
        case .formatters: return "text.alignleft"
        case .debuggers: return "ladybug"
        case .keymaps: return "keyboard"
        case .other: return "puzzlepiece"
        }
    }
}

enum ExtensionFilter: String, CaseIterable {
    case installed = "Installed"
    case recommended = "Recommended"
    case popular = "Popular"
    case all = "All"
}

// MARK: - Extension Manager

@MainActor
class ExtensionManager: ObservableObject {
    static let shared = ExtensionManager()
    
    @Published var installedExtensions: [IDEExtension] = []
    @Published var catalogExtensions: [IDEExtension] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: ExtensionFilter = .installed
    @Published var selectedCategory: ExtensionCategory? = nil
    @Published var isLoading: Bool = false
    
    private let installedKey = "installedExtensionIds"
    
    init() {
        loadCatalog()
        loadInstalledState()
    }
    
    // MARK: - Filtered Results
    
    var filteredExtensions: [IDEExtension] {
        var results: [IDEExtension]
        
        switch selectedFilter {
        case .installed:
            results = catalogExtensions.filter { $0.isInstalled }
        case .recommended:
            results = catalogExtensions.filter { !$0.isInstalled && $0.rating >= 4.0 }
        case .popular:
            results = catalogExtensions.sorted { $0.downloadCount > $1.downloadCount }
        case .all:
            results = catalogExtensions
        }
        
        if let category = selectedCategory {
            results = results.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(query) ||
                $0.displayName.lowercased().contains(query) ||
                $0.publisher.lowercased().contains(query) ||
                $0.description.lowercased().contains(query)
            }
        }
        
        return results
    }
    
    var installedCount: Int {
        catalogExtensions.filter { $0.isInstalled }.count
    }
    
    // MARK: - Install / Uninstall
    
    func install(_ extension_: IDEExtension) {
        if let index = catalogExtensions.firstIndex(where: { $0.id == extension_.id }) {
            catalogExtensions[index].isInstalled = true
            catalogExtensions[index].isEnabled = true
            saveInstalledState()
            NotificationCenter.default.post(
                name: .extensionInstalled,
                object: nil,
                userInfo: ["extension": extension_.displayName]
            )
        }
    }
    
    func uninstall(_ extension_: IDEExtension) {
        if let index = catalogExtensions.firstIndex(where: { $0.id == extension_.id }) {
            catalogExtensions[index].isInstalled = false
            catalogExtensions[index].isEnabled = false
            saveInstalledState()
            NotificationCenter.default.post(
                name: .extensionUninstalled,
                object: nil,
                userInfo: ["extension": extension_.displayName]
            )
        }
    }
    
    func toggleEnabled(_ extension_: IDEExtension) {
        if let index = catalogExtensions.firstIndex(where: { $0.id == extension_.id }) {
            catalogExtensions[index].isEnabled.toggle()
            saveInstalledState()
        }
    }
    
    // MARK: - Persistence
    
    private func saveInstalledState() {
        let installed = catalogExtensions.filter { $0.isInstalled }.map { $0.fullId }
        let disabled = catalogExtensions.filter { $0.isInstalled && !$0.isEnabled }.map { $0.fullId }
        UserDefaults.standard.set(installed, forKey: installedKey)
        UserDefaults.standard.set(disabled, forKey: "disabledExtensionIds")
    }
    
    private func loadInstalledState() {
        let installed = Set(UserDefaults.standard.stringArray(forKey: installedKey) ?? defaultInstalledIds)
        let disabled = Set(UserDefaults.standard.stringArray(forKey: "disabledExtensionIds") ?? [])
        for i in catalogExtensions.indices {
            catalogExtensions[i].isInstalled = installed.contains(catalogExtensions[i].fullId)
            if disabled.contains(catalogExtensions[i].fullId) {
                catalogExtensions[i].isEnabled = false
            }
        }
    }
    
    // Extensions that come "pre-installed"
    private var defaultInstalledIds: [String] {
        [
            "vscode.swift-lang",
            "vscode.python-lang",
            "vscode.javascript-lang",
            "vscode.typescript-lang",
            "vscode.dark-modern",
            "vscode.git-integration",
            "vscode.markdown-preview"
        ]
    }
    
    // MARK: - Catalog
    
    private func loadCatalog() {
        catalogExtensions = Self.builtInCatalog
    }
    
    /// Curated extension catalog matching real VS Code extensions
    static let builtInCatalog: [IDEExtension] = [
        // MARK: Themes
        IDEExtension(
            id: "dark-modern", name: "dark-modern", publisher: "vscode",
            displayName: "Dark Modern", description: "Dark Modern color theme (default)",
            version: "1.0.0", category: .themes, iconName: "paintpalette.fill",
            downloadCount: 50_000_000, rating: 4.8
        ),
        IDEExtension(
            id: "one-dark-pro", name: "one-dark-pro", publisher: "zhuangtongfa",
            displayName: "One Dark Pro", description: "Atom's iconic One Dark theme for VS Code",
            version: "3.17.0", category: .themes, iconName: "paintpalette.fill",
            downloadCount: 18_500_000, rating: 4.7
        ),
        IDEExtension(
            id: "dracula-theme", name: "dracula-theme", publisher: "dracula-theme",
            displayName: "Dracula Official", description: "Official Dracula Theme. A dark theme for many editors.",
            version: "2.25.1", category: .themes, iconName: "paintpalette.fill",
            downloadCount: 12_300_000, rating: 4.6
        ),
        IDEExtension(
            id: "github-theme", name: "github-theme", publisher: "github",
            displayName: "GitHub Theme", description: "GitHub theme for VS Code",
            version: "6.3.5", category: .themes, iconName: "paintpalette.fill",
            downloadCount: 10_200_000, rating: 4.5
        ),
        IDEExtension(
            id: "catppuccin", name: "catppuccin-vsc", publisher: "catppuccin",
            displayName: "Catppuccin", description: "Soothing pastel theme for VS Code",
            version: "3.15.0", category: .themes, iconName: "paintpalette.fill",
            downloadCount: 5_800_000, rating: 4.9
        ),
        
        // MARK: Languages
        IDEExtension(
            id: "swift-lang", name: "swift-lang", publisher: "vscode",
            displayName: "Swift", description: "Swift language support with syntax highlighting and snippets",
            version: "1.0.0", category: .languages, iconName: "swift",
            downloadCount: 3_200_000, rating: 4.5
        ),
        IDEExtension(
            id: "python-lang", name: "python-lang", publisher: "vscode",
            displayName: "Python", description: "Python language support with IntelliSense, linting, and debugging",
            version: "2024.2.0", category: .languages, iconName: "chevron.left.forwardslash.chevron.right",
            downloadCount: 112_000_000, rating: 4.6
        ),
        IDEExtension(
            id: "javascript-lang", name: "javascript-lang", publisher: "vscode",
            displayName: "JavaScript", description: "JavaScript and JSX language support",
            version: "1.0.0", category: .languages, iconName: "chevron.left.forwardslash.chevron.right",
            downloadCount: 45_000_000, rating: 4.7
        ),
        IDEExtension(
            id: "typescript-lang", name: "typescript-lang", publisher: "vscode",
            displayName: "TypeScript", description: "TypeScript language support with IntelliSense",
            version: "1.0.0", category: .languages, iconName: "chevron.left.forwardslash.chevron.right",
            downloadCount: 32_000_000, rating: 4.7
        ),
        IDEExtension(
            id: "rust-analyzer", name: "rust-analyzer", publisher: "rust-lang",
            displayName: "rust-analyzer", description: "Rust language support via rust-analyzer",
            version: "0.3.1845", category: .languages, iconName: "gearshape.2",
            downloadCount: 8_400_000, rating: 4.8
        ),
        IDEExtension(
            id: "go", name: "go", publisher: "golang",
            displayName: "Go", description: "Rich Go language support with IntelliSense and debugging",
            version: "0.42.0", category: .languages, iconName: "chevron.left.forwardslash.chevron.right",
            downloadCount: 14_500_000, rating: 4.6
        ),
        IDEExtension(
            id: "clangd", name: "clangd", publisher: "llvm",
            displayName: "clangd", description: "C/C++ language support powered by clangd",
            version: "0.1.29", category: .languages, iconName: "c.square",
            downloadCount: 4_200_000, rating: 4.4
        ),
        IDEExtension(
            id: "java", name: "java", publisher: "redhat",
            displayName: "Language Support for Java", description: "Java IntelliSense, debugging, and more",
            version: "1.36.0", category: .languages, iconName: "cup.and.saucer",
            downloadCount: 19_800_000, rating: 4.3
        ),
        
        // MARK: Linters & Formatters
        IDEExtension(
            id: "eslint", name: "eslint", publisher: "dbaeumer",
            displayName: "ESLint", description: "Integrates ESLint JavaScript into VS Code",
            version: "3.0.10", category: .linters, iconName: "exclamationmark.triangle",
            downloadCount: 35_600_000, rating: 4.5
        ),
        IDEExtension(
            id: "prettier", name: "prettier-vscode", publisher: "esbenp",
            displayName: "Prettier", description: "Code formatter using Prettier",
            version: "11.0.0", category: .formatters, iconName: "text.alignleft",
            downloadCount: 42_100_000, rating: 4.3
        ),
        IDEExtension(
            id: "swiftlint", name: "swiftlint", publisher: "vknabel",
            displayName: "SwiftLint", description: "Swift linting and style checking",
            version: "1.5.0", category: .linters, iconName: "exclamationmark.triangle",
            downloadCount: 680_000, rating: 4.4
        ),
        IDEExtension(
            id: "pylint", name: "pylint", publisher: "ms-python",
            displayName: "Pylint", description: "Python linting support using Pylint",
            version: "2024.0.0", category: .linters, iconName: "exclamationmark.triangle",
            downloadCount: 8_900_000, rating: 4.2
        ),
        
        // MARK: Snippets
        IDEExtension(
            id: "es7-snippets", name: "es7-react-js-snippets", publisher: "dsznajder",
            displayName: "ES7+ React/Redux Snippets", description: "Extensions for React, React-Native and Redux snippets",
            version: "4.4.3", category: .snippets, iconName: "text.snippet",
            downloadCount: 13_200_000, rating: 4.5
        ),
        IDEExtension(
            id: "swift-snippets", name: "swift-snippets", publisher: "vscode",
            displayName: "Swift Snippets", description: "Common Swift code snippets for iOS/macOS development",
            version: "1.0.0", category: .snippets, iconName: "text.snippet",
            downloadCount: 450_000, rating: 4.3
        ),
        
        // MARK: Debuggers
        IDEExtension(
            id: "codelldb", name: "codelldb", publisher: "vadimcn",
            displayName: "CodeLLDB", description: "Native debugger powered by LLDB for C++, Rust and others",
            version: "1.11.0", category: .debuggers, iconName: "ladybug",
            downloadCount: 6_700_000, rating: 4.7
        ),
        IDEExtension(
            id: "debugpy", name: "debugpy", publisher: "ms-python",
            displayName: "Python Debugger", description: "Python debugging support using debugpy",
            version: "2024.12.0", category: .debuggers, iconName: "ladybug",
            downloadCount: 22_000_000, rating: 4.5
        ),
        
        // MARK: Other
        IDEExtension(
            id: "git-integration", name: "git-integration", publisher: "vscode",
            displayName: "Git Integration", description: "Built-in Git source control management",
            version: "1.0.0", category: .other, iconName: "arrow.triangle.branch",
            downloadCount: 50_000_000, rating: 4.8
        ),
        IDEExtension(
            id: "markdown-preview", name: "markdown-preview", publisher: "vscode",
            displayName: "Markdown Preview", description: "Built-in Markdown preview with live updates",
            version: "1.0.0", category: .other, iconName: "doc.richtext",
            downloadCount: 50_000_000, rating: 4.7
        ),
        IDEExtension(
            id: "gitlens", name: "gitlens", publisher: "eamodio",
            displayName: "GitLens", description: "Supercharge Git — Visualize code authorship via blame annotations and more",
            version: "15.6.0", category: .other, iconName: "eye",
            downloadCount: 34_100_000, rating: 4.5
        ),
        IDEExtension(
            id: "remote-ssh", name: "remote-ssh", publisher: "ms-vscode",
            displayName: "Remote - SSH", description: "Open folders on remote machines using SSH",
            version: "0.115.0", category: .other, iconName: "network",
            downloadCount: 26_800_000, rating: 4.4
        ),
        IDEExtension(
            id: "copilot", name: "copilot", publisher: "github",
            displayName: "GitHub Copilot", description: "AI pair programmer that suggests code completions",
            version: "1.245.0", category: .other, iconName: "sparkles",
            downloadCount: 21_500_000, rating: 4.6
        ),
        IDEExtension(
            id: "docker", name: "docker", publisher: "ms-azuretools",
            displayName: "Docker", description: "Build, manage, and deploy containerized applications",
            version: "1.29.3", category: .other, iconName: "shippingbox",
            downloadCount: 18_900_000, rating: 4.5
        ),
        IDEExtension(
            id: "vim", name: "vim", publisher: "vscodevim",
            displayName: "Vim", description: "Vim emulation for VS Code",
            version: "1.28.1", category: .keymaps, iconName: "keyboard",
            downloadCount: 15_200_000, rating: 4.2
        ),
    ]
}

// MARK: - Notifications

extension Notification.Name {
    static let extensionInstalled = Notification.Name("extensionInstalled")
    static let extensionUninstalled = Notification.Name("extensionUninstalled")
}

// MARK: - Download Count Formatting

extension IDEExtension {
    var formattedDownloads: String {
        if downloadCount >= 1_000_000 {
            return String(format: "%.1fM", Double(downloadCount) / 1_000_000)
        } else if downloadCount >= 1_000 {
            return String(format: "%.0fK", Double(downloadCount) / 1_000)
        }
        return "\(downloadCount)"
    }
    
    var ratingStars: String {
        let full = Int(rating)
        let half = (rating - Double(full)) >= 0.5
        var stars = String(repeating: "★", count: full)
        if half { stars += "½" }
        return stars
    }
}
