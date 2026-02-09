import Foundation

// MARK: - Workspace Settings

/// Workspace (per-project) settings that override global settings.
///
/// These correspond loosely to VS Code's `.vscode/settings.json` keys:
/// - editor.tabSize
/// - editor.insertSpaces
/// - editor.formatOnSave
/// - workbench.colorTheme
/// - editor.fontFamily
/// - editor.fontSize
struct WorkspaceSettings: Codable, Equatable {
    /// Number of spaces that a tab represents.
    var tabSize: Int?

    /// Insert spaces when pressing tab.
    var insertSpaces: Bool?

    /// Format the document on save.
    var formatOnSave: Bool?

    /// Theme identifier (app-specific). Stored under `workbench.colorTheme`.
    var theme: String?

    /// Editor font family name.
    var fontFamily: String?

    /// Editor font size.
    var fontSize: Double?

    static let empty = WorkspaceSettings()
}

/// Concrete, fully-resolved settings after merging global + workspace overrides.
struct ResolvedWorkspaceSettings: Equatable {
    var tabSize: Int
    var insertSpaces: Bool
    var formatOnSave: Bool
    var theme: String
    var fontFamily: String
    var fontSize: Double
}

// MARK: - Workspace Manager

@MainActor
final class WorkspaceManager: ObservableObject {
    static let shared = WorkspaceManager()

    @Published private(set) var workspaceRootURL: URL?
    @Published private(set) var workspaceSettings: WorkspaceSettings = .empty

    @Published var lastErrorMessage: String?

    private init() {}

    // MARK: - Workspace

    func setWorkspaceRoot(_ url: URL?) {
        workspaceRootURL = url
        reload()
    }

    // MARK: - Global settings

    /// Reads global (app) settings from `UserDefaults`.
    func globalSettings() -> ResolvedWorkspaceSettings {
        let defaults = UserDefaults.standard

        let tabSize = defaults.object(forKey: "tabSize") as? Int ?? 4

        // Defaults to true when unset.
        let insertSpaces: Bool
        if defaults.object(forKey: "insertSpaces") == nil {
            insertSpaces = true
        } else {
            insertSpaces = defaults.bool(forKey: "insertSpaces")
        }

        let formatOnSave: Bool
        if defaults.object(forKey: "formatOnSave") == nil {
            formatOnSave = false
        } else {
            formatOnSave = defaults.bool(forKey: "formatOnSave")
        }

        let theme = defaults.string(forKey: "selectedThemeId") ?? "dark_plus"
        let fontFamily = defaults.string(forKey: "fontFamily") ?? "Menlo"
        let fontSize = defaults.object(forKey: "fontSize") as? Double ?? 14

        return ResolvedWorkspaceSettings(
            tabSize: tabSize,
            insertSpaces: insertSpaces,
            formatOnSave: formatOnSave,
            theme: theme,
            fontFamily: fontFamily,
            fontSize: fontSize
        )
    }

    /// Workspace overrides global.
    func effectiveSettings() -> ResolvedWorkspaceSettings {
        let global = globalSettings()
        let ws = workspaceSettings

        return ResolvedWorkspaceSettings(
            tabSize: ws.tabSize ?? global.tabSize,
            insertSpaces: ws.insertSpaces ?? global.insertSpaces,
            formatOnSave: ws.formatOnSave ?? global.formatOnSave,
            theme: ws.theme ?? global.theme,
            fontFamily: ws.fontFamily ?? global.fontFamily,
            fontSize: ws.fontSize ?? global.fontSize
        )
    }

    // MARK: - Load

    func reload() {
        lastErrorMessage = nil
        workspaceSettings = .empty

        guard let root = workspaceRootURL else { return }

        let settingsURL = root
            .appendingPathComponent(".vscode", isDirectory: true)
            .appendingPathComponent("settings.json", isDirectory: false)

        do {
            let data = try Data(contentsOf: settingsURL)
            let raw = String(decoding: data, as: UTF8.self)
            let stripped = Self.stripJSONComments(raw)
            let obj = try JSONSerialization.jsonObject(with: Data(stripped.utf8), options: [])

            guard let dict = obj as? [String: Any] else {
                lastErrorMessage = "Couldn’t parse .vscode/settings.json"
                return
            }

            workspaceSettings = Self.parseWorkspaceSettings(from: dict)
        } catch {
            // Not an error if settings.json doesn't exist.
            // Only show an error if the file exists but couldn't be read.
            if FileManager.default.fileExists(atPath: settingsURL.path) {
                lastErrorMessage = "Couldn’t load .vscode/settings.json"
            }
        }
    }

    // MARK: - Save

    func saveWorkspaceSettings(_ newSettings: WorkspaceSettings) {
        workspaceSettings = newSettings
        save()
    }

    func save() {
        lastErrorMessage = nil
        guard let root = workspaceRootURL else {
            lastErrorMessage = "No workspace folder is open"
            return
        }

        let vscodeDir = root.appendingPathComponent(".vscode", isDirectory: true)
        let settingsURL = vscodeDir.appendingPathComponent("settings.json", isDirectory: false)

        do {
            try FileManager.default.createDirectory(at: vscodeDir, withIntermediateDirectories: true)

            let dict = Self.serializeWorkspaceSettings(workspaceSettings)
            let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])

            // Add trailing newline for nicer diffs.
            var out = String(decoding: data, as: UTF8.self)
            if !out.hasSuffix("\n") { out += "\n" }

            try out.data(using: .utf8)?.write(to: settingsURL, options: [.atomic])
        } catch {
            lastErrorMessage = "Couldn’t save .vscode/settings.json"
        }
    }

    // MARK: - JSON mapping

    private static func parseWorkspaceSettings(from dict: [String: Any]) -> WorkspaceSettings {
        func int(_ key: String) -> Int? {
            dict[key] as? Int
        }
        func bool(_ key: String) -> Bool? {
            dict[key] as? Bool
        }
        func string(_ key: String) -> String? {
            dict[key] as? String
        }
        func double(_ key: String) -> Double? {
            if let d = dict[key] as? Double { return d }
            if let i = dict[key] as? Int { return Double(i) }
            return nil
        }

        return WorkspaceSettings(
            tabSize: int("editor.tabSize"),
            insertSpaces: bool("editor.insertSpaces"),
            formatOnSave: bool("editor.formatOnSave"),
            theme: string("workbench.colorTheme"),
            fontFamily: string("editor.fontFamily"),
            fontSize: double("editor.fontSize")
        )
    }

    private static func serializeWorkspaceSettings(_ settings: WorkspaceSettings) -> [String: Any] {
        var dict: [String: Any] = [:]

        if let tabSize = settings.tabSize { dict["editor.tabSize"] = tabSize }
        if let insertSpaces = settings.insertSpaces { dict["editor.insertSpaces"] = insertSpaces }
        if let formatOnSave = settings.formatOnSave { dict["editor.formatOnSave"] = formatOnSave }
        if let theme = settings.theme, !theme.isEmpty { dict["workbench.colorTheme"] = theme }
        if let fontFamily = settings.fontFamily, !fontFamily.isEmpty { dict["editor.fontFamily"] = fontFamily }
        if let fontSize = settings.fontSize { dict["editor.fontSize"] = fontSize }

        return dict
    }

    // MARK: - JSONC helpers

    /// VS Code `settings.json` can contain JSON with comments (JSONC). This strips
    /// both `//` line comments and `/* ... */` block comments.
    private static func stripJSONComments(_ input: String) -> String {
        let blockPattern = "/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/"
        let linePattern = "(?m)//.*$"

        let withoutBlocks = input.replacingOccurrences(of: blockPattern, with: "", options: .regularExpression)
        let withoutLines = withoutBlocks.replacingOccurrences(of: linePattern, with: "", options: .regularExpression)
        return withoutLines
    }
}
