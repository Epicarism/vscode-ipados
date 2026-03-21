//
//  EditorConfigService.swift
//  VSCodeiPadOS
//
//  Parses .editorconfig (INI with glob patterns) and .prettierrc (JSON).
//  Provides per-file settings that override global CodeFormatter defaults.
//

import Foundation
import os

// MARK: - Per-File Editor Settings

/// Settings resolved for a specific file, combining .editorconfig, .prettierrc,
/// and global defaults. `nil` values mean "use global default".
struct EditorConfigFileSettings {
    var indentStyle: String?      // "space" or "tab"
    var indentSize: Int?          // number of columns per indent
    var tabWidth: Int?            // display width of a tab character
    var endOfLine: String?        // "lf", "cr", or "crlf"
    var trimTrailingWhitespace: Bool?
    var insertFinalNewline: Bool?
    var maxLineLength: Int?       // from prettierrc printWidth

    /// Apply these settings onto CodeFormatter, overriding only non-nil values.
    /// Returns true if any setting was changed.
    @discardableResult
    @MainActor func apply(to formatter: CodeFormatter) -> Bool {
        var changed = false
        if let style = indentStyle {
            let useTabs = (style == "tab")
            if formatter.useTabs != useTabs {
                formatter.useTabs = useTabs
                changed = true
            }
        }
        if let size = indentSize {
            if formatter.tabSize != size {
                formatter.tabSize = size
                changed = true
            }
        }
        if let trim = trimTrailingWhitespace {
            if formatter.trimTrailingWhitespace != trim {
                formatter.trimTrailingWhitespace = trim
                changed = true
            }
        }
        if let newline = insertFinalNewline {
            if formatter.insertFinalNewline != newline {
                formatter.insertFinalNewline = newline
                changed = true
            }
        }
        return changed
    }
}

// MARK: - EditorConfig Service

actor EditorConfigService {
    static let shared = EditorConfigService()

    private static let logger = Logger(subsystem: "com.codepad.app", category: "EditorConfig")

    /// Parsed .editorconfig entries keyed by directory path.
    private var editorConfigs: [String: [EditorConfigSection]] = [:]

    /// Parsed .prettierrc entries keyed by directory path.
    private var prettierConfigs: [String: PrettierConfig] = [:]

    /// In-memory cache of resolved settings per file path.
    private var resolvedCache: [String: EditorConfigFileSettings] = [:]

    /// Maximum number of resolved settings to cache.
    private let maxResolvedCacheSize = 200

    // MARK: - Public API

    /// Load and parse config files for a given workspace/project directory.
    func loadConfigs(for directory: String) {
        loadEditorConfig(for: directory)
        loadPrettierConfig(for: directory)
        // Clear resolved cache since configs changed
        resolvedCache.removeAll()
        Self.logger.info("Loaded editor configs for directory: \(directory)")
    }

    /// Resolve settings for a specific file path. Walks up from file to
    /// workspace root, applying .editorconfig sections that match the file's glob.
    func settingsForFile(at filePath: String) -> EditorConfigFileSettings {
        // Check cache
        if let cached = resolvedCache[filePath] {
            return cached
        }

        var settings = EditorConfigFileSettings()

        // Walk up directories to find applicable .editorconfig files
        let directories = ancestorDirectories(of: filePath)
        for dir in directories {
            // Apply .editorconfig rules
            if let sections = editorConfigs[dir] {
                applyEditorConfigSections(sections, filePath: filePath, settings: &settings)
            }
            // Apply .prettierrc
            if let prettier = prettierConfigs[dir] {
                applyPrettierConfig(prettier, settings: &settings)
            }
        }

        // Cache the result
        cacheResolved(filePath, settings: settings)

        return settings
    }

    /// Clear all cached configs (e.g., when switching workspaces).
    func clearCache() {
        editorConfigs.removeAll()
        prettierConfigs.removeAll()
        resolvedCache.removeAll()
        Self.logger.info("Cleared all editor config caches")
    }

    /// Invalidate resolved cache for a specific file.
    func invalidateFile(_ filePath: String) {
        resolvedCache.removeValue(forKey: filePath)
    }

    // MARK: - .editorconfig Parsing

    /// A single [section] from an .editorconfig file.
    private struct EditorConfigSection {
        let pattern: String   // glob pattern (e.g., "*.swift", "src/**")
        let properties: [String: String]
    }

    /// Load and parse .editorconfig from the given directory.
    private func loadEditorConfig(for directory: String) {
        let configPath = (directory as NSString).appendingPathComponent(".editorconfig")
        let fm = FileManager.default
        guard fm.fileExists(atPath: configPath),
              let content = try? String(contentsOfFile: configPath, encoding: .utf8) else {
            editorConfigs.removeValue(forKey: directory)
            return
        }

        let sections = parseEditorConfig(content)
        editorConfigs[directory] = sections
        Self.logger.debug("Parsed \(sections.count) .editorconfig sections from \(configPath)")
    }

    /// Parse .editorconfig INI content into sections.
    private func parseEditorConfig(_ content: String) -> [EditorConfigSection] {
        var sections: [EditorConfigSection] = []
        var currentPattern: String?
        var currentProps: [String: String] = [:]

        let lines = content.components(separatedBy: .newlines)
        for rawLine in lines {
            // Strip comments and trim
            let trimmed = rawLine
                .components(separatedBy: "#")[0]   // remove # comments
                .components(separatedBy: ";")[0]    // remove ; comments
                .trimmingCharacters(in: .whitespaces)

            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                // Save previous section
                if let pattern = currentPattern, !currentProps.isEmpty {
                    sections.append(EditorConfigSection(pattern: pattern, properties: currentProps))
                }
                currentPattern = String(trimmed.dropFirst().dropLast())
                currentProps = [:]
            } else if let eqIndex = trimmed.firstIndex(of: "=") {
                let key = String(trimmed[..<eqIndex]).trimmingCharacters(in: .whitespaces).lowercased()
                let value = String(trimmed[eqIndex...].dropFirst()).trimmingCharacters(in: .whitespaces)
                currentProps[key] = value
            }
        }

        // Save last section
        if let pattern = currentPattern, !currentProps.isEmpty {
            sections.append(EditorConfigSection(pattern: pattern, properties: currentProps))
        }

        return sections
    }

    /// Apply matching .editorconfig sections to settings.
    private func applyEditorConfigSections(
        _ sections: [EditorConfigSection],
        filePath: String,
        settings: inout EditorConfigFileSettings
    ) {
        let fileName = (filePath as NSString).lastPathComponent

        for section in sections {
            guard editorConfigGlobMatches(section.pattern, filePath: filePath, fileName: fileName) else {
                continue
            }

            // indent_style
            if let val = section.properties["indent_style"],
               val == "space" || val == "tab" {
                settings.indentStyle = val
            }

            // indent_size
            if let val = section.properties["indent_size"], let size = Int(val) {
                settings.indentSize = size
            }

            // tab_width
            if let val = section.properties["tab_width"], let width = Int(val) {
                settings.tabWidth = width
            }

            // end_of_line
            if let val = section.properties["end_of_line"] {
                let lowered = val.lowercased()
                if ["lf", "crlf", "cr"].contains(lowered) {
                    settings.endOfLine = lowered
                }
            }

            // trim_trailing_whitespace
            if let val = section.properties["trim_trailing_whitespace"] {
                settings.trimTrailingWhitespace = (val.lowercased() == "true")
            }

            // insert_final_newline
            if let val = section.properties["insert_final_newline"] {
                settings.insertFinalNewline = (val.lowercased() == "true")
            }

            // max_line_length
            if let val = section.properties["max_line_length"], let len = Int(val) {
                settings.maxLineLength = len
            }
        }
    }

    /// Simple glob matching for .editorconfig patterns.
    /// Supports: *, **, ?, [charset], {alt1,alt2}
    private func editorConfigGlobMatches(_ pattern: String, filePath: String, fileName: String) -> Bool {
        // Root section (*) matches everything
        if pattern == "*" { return true }

        let target = filePath

        // Convert .editorconfig glob to a simple matching function
        // Pattern can be relative to the .editorconfig location

        // Handle {a,b} alternatives by splitting
        if pattern.contains("{") && pattern.contains("}") {
            let alternatives = extractAlternatives(pattern)
            return alternatives.contains { alt in
                globMatch(alt, against: target) || globMatch(alt, against: fileName)
            }
        }

        return globMatch(pattern, against: target) || globMatch(pattern, against: fileName)
    }

    /// Extract alternatives from {a,b,c} patterns.
    private func extractAlternatives(_ pattern: String) -> [String] {
        var result: [String] = []
        guard let braceOpen = pattern.firstIndex(of: "{"),
              let braceClose = pattern.firstIndex(of: "}") else {
            return [pattern]
        }
        let prefix = String(pattern[..<braceOpen])
        let suffix = String(pattern[braceClose...].dropFirst())
        let inner = String(pattern[pattern.index(after: braceOpen)..<braceClose])
        for alt in inner.components(separatedBy: ",") {
            result.append(prefix + alt.trimmingCharacters(in: .whitespaces) + suffix)
        }
        return result
    }

    /// Minimal glob matching: supports * (any chars), ** (any path segments), ? (single char).
    private func globMatch(_ pattern: String, against target: String) -> Bool {
        // Fast path: exact match
        if pattern == target { return true }

        // Fast path: *.ext
        if pattern.hasPrefix("*") && !pattern.contains("**") && !pattern.contains("?") {
            let suffix = String(pattern.dropFirst())
            return target.hasSuffix(suffix)
        }

        // Convert to regex for full matching
        var regexStr = "^"
        var i = pattern.startIndex
        while i < pattern.endIndex {
            let ch = pattern[i]
            if ch == "*" {
                if i < pattern.index(before: pattern.endIndex) &&
                   pattern[pattern.index(after: i)] == "*" {
                    // ** -> match anything including /
                    regexStr += ".*"
                    i = pattern.index(i, offsetBy: 2)
                    continue
                } else {
                    // * -> match anything except /
                    regexStr += "[^/]*"
                }
            } else if ch == "?" {
                regexStr += "[^/]"
            } else if ".+^${}()|[]\\".contains(ch) {
                regexStr += "\\" + String(ch)
            } else {
                regexStr += String(ch)
            }
            i = pattern.index(after: i)
        }
        regexStr += "$"

        guard let regex = try? NSRegularExpression(pattern: regexStr, options: []) else {
            return false
        }
        let range = NSRange(target.startIndex..., in: target)
        return regex.firstMatch(in: target, options: [], range: range) != nil
    }

    // MARK: - .prettierrc Parsing

    /// Parsed .prettierrc configuration.
    private struct PrettierConfig {
        let tabWidth: Int?
        let useTabs: Bool?
        let printWidth: Int?
        let endOfLine: String?
        let semi: Bool?           // semicolons (not applied to editor settings)
        let singleQuote: Bool?    // quotes (not applied to editor settings)
    }

    /// Load and parse .prettierrc (JSON or YAML-like JSON) from the given directory.
    private func loadPrettierConfig(for directory: String) {
        let fm = FileManager.default
        let prettierNames = [".prettierrc", ".prettierrc.json", ".prettierrc.json5", ".prettierrc.yml"]

        for name in prettierNames {
            let configPath = (directory as NSString).appendingPathComponent(name)
            guard fm.fileExists(atPath: configPath),
                  let content = try? String(contentsOfFile: configPath, encoding: .utf8) else {
                continue
            }

            if let config = parsePrettierConfig(content) {
                prettierConfigs[directory] = config
                Self.logger.debug("Parsed .prettierrc from \(configPath)")
                return  // Use the first one found
            }
        }

        prettierConfigs.removeValue(forKey: directory)
    }

    /// Parse .prettierrc JSON content.
    private func parsePrettierConfig(_ content: String) -> PrettierConfig? {
        // Strip potential BOM and comments for JSON5-like support
        var cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("\u{FEFF}") { cleaned.removeFirst() }

        // Remove single-line comments (// ...)
        cleaned = cleaned.components(separatedBy: "\n").map { line in
            if let slashRange = line.range(of: "//") {
                return String(line[..<slashRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
            return line
        }.joined(separator: "\n")

        // Remove trailing commas before } or ]
        cleaned = cleaned.replacingOccurrences(of: ",\\s*([}\\]])", with: "$1", options: .regularExpression)

        guard let data = cleaned.data(using: .utf8) else { return nil }

        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return nil
            }

            return PrettierConfig(
                tabWidth: json["tabWidth"] as? Int,
                useTabs: json["useTabs"] as? Bool,
                printWidth: json["printWidth"] as? Int,
                endOfLine: json["endOfLine"] as? String,
                semi: json["semi"] as? Bool,
                singleQuote: json["singleQuote"] as? Bool
            )
        } catch {
            Self.logger.warning("Failed to parse .prettierrc: \(error.localizedDescription)")
            return nil
        }
    }

    /// Apply .prettierrc settings to file settings (only if not already set by .editorconfig).
    private func applyPrettierConfig(_ config: PrettierConfig, settings: inout EditorConfigFileSettings) {
        if let useTabs = config.useTabs {
            settings.indentStyle = useTabs ? "tab" : "space"
        }
        if let tabWidth = config.tabWidth {
            // Only set indentSize if not already set by editorconfig
            if settings.indentSize == nil {
                settings.indentSize = tabWidth
            }
            settings.tabWidth = tabWidth
        }
        if let printWidth = config.printWidth {
            if settings.maxLineLength == nil {
                settings.maxLineLength = printWidth
            }
        }
        if let eol = config.endOfLine {
            if settings.endOfLine == nil {
                let mapped: String?
                switch eol.lowercased() {
                case "lf": mapped = "lf"
                case "crlf": mapped = "crlf"
                case "cr": mapped = "cr"
                case "auto": mapped = nil  // let system decide
                default: mapped = nil
                }
                settings.endOfLine = mapped
            }
        }
    }

    // MARK: - Utilities

    /// Get all ancestor directories from file path up to root.
    private func ancestorDirectories(of filePath: String) -> [String] {
        var dirs: [String] = []
        var current = (filePath as NSString).deletingLastPathComponent
        while !current.isEmpty && current != "/" {
            dirs.append(current)
            let parent = (current as NSString).deletingLastPathComponent
            if parent == current { break }
            current = parent
        }
        return dirs.reversed()  // root first, closest to file last
    }

    /// Cache a resolved setting, evicting old entries if needed.
    private func cacheResolved(_ filePath: String, settings: EditorConfigFileSettings) {
        if resolvedCache.count >= maxResolvedCacheSize {
            // Simple eviction: remove oldest half
            let keysToRemove = Array(resolvedCache.keys.prefix(maxResolvedCacheSize / 2))
            for key in keysToRemove {
                resolvedCache.removeValue(forKey: key)
            }
        }
        resolvedCache[filePath] = settings
    }
}
