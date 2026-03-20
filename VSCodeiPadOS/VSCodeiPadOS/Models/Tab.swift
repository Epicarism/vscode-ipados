//
//  Tab.swift
//  VSCodeiPadOS
//
//  Created by AI Assistant
//  A model representing an editor tab with file content and metadata
//

import Foundation
import SwiftUI

/// Represents an open editor tab containing file content
struct Tab: Identifiable, Equatable, Hashable, Codable {
    // MARK: - Properties
    
    /// Unique identifier for the tab
    let id: UUID
    
    /// Display name of the file
    var fileName: String
    
    /// Current content of the file
    var content: String {
        didSet { _updateCaches() }
    }
    
    /// Programming language/file type
    var language: CodeLanguage
    
    /// File system URL (nil for unsaved new files)
    var url: URL?
    
    /// Remote path on the SSH server (nil for local files)
    var remotePath: String?
    
    /// Remote host identifier (nil for local files)
    var remoteHost: String?
    
    /// Whether the file has unsaved changes
    var isUnsaved: Bool
    
    /// Whether this tab is currently active/selected
    var isActive: Bool
    
    /// Whether this tab is pinned
    var isPinned: Bool
    
    /// Whether this tab is in preview mode
    var isPreview: Bool
    
    /// Encoding used when the file was read (stored as String.Encoding.rawValue).
    /// Defaults to UTF-8. When saving, the same encoding is used to preserve the
    /// original file encoding.
    var fileEncoding: UInt

    // MARK: - Per-Tab Editor State (not persisted, transient UI state)

    /// Saved scroll offset (pixels) — restored when switching back to this tab.
    /// Excluded from Codable via CodingKeys.
    var savedScrollOffset: CGFloat = 0

    /// Saved cursor character index — restored when switching back to this tab.
    /// Excluded from Codable via CodingKeys.
    var savedCursorIndex: Int = 0

    // MARK: - Cached Derived State (not persisted, excluded from CodingKeys)

    /// Cached line count — O(1) read; O(n) scan runs only when `content` changes.
    private var _cachedLineCount: Int = 1

    /// Cached UTF-8 byte count — O(1) read; updated only when `content` changes.
    private var _cachedContentSize: Int = 0

    // FIX: Exclude transient UI state from Codable encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, fileName, content, language, url
        case remotePath, remoteHost
        case isUnsaved, isActive, isPinned, isPreview
        case fileEncoding
    }
    
    /// Convenience accessor for the encoding as a Foundation String.Encoding
    var stringEncoding: String.Encoding {
        get { String.Encoding(rawValue: fileEncoding) }
        set { fileEncoding = newValue.rawValue }
    }
    
    // MARK: - Initialization
    
    /// Creates a new tab
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided)
    ///   - fileName: Display name for the file
    ///   - content: File content (empty by default)
    ///   - language: Programming language (auto-detected from fileName if not provided)
    ///   - url: File system URL (nil for new unsaved files)
    ///   - isUnsaved: Whether file has unsaved changes (false by default)
    ///   - isActive: Whether this is the active tab (false by default)
    ///   - isPinned: Whether the tab is pinned (false by default)
    ///   - isPreview: Whether the tab is in preview mode (false by default)
    ///   - fileEncoding: Encoding used when reading the file (defaults to UTF-8)
    ///   - remotePath: Remote server path (nil for local files)
    ///   - remoteHost: Remote host identifier (nil for local files)
    init(
        id: UUID = UUID(),
        fileName: String,
        content: String = "",
        language: CodeLanguage? = nil,
        url: URL? = nil,
        isUnsaved: Bool = false,
        isActive: Bool = false,
        isPinned: Bool = false,
        isPreview: Bool = false,
        fileEncoding: UInt = String.Encoding.utf8.rawValue,
        remotePath: String? = nil,
        remoteHost: String? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.content = content
        self.url = url
        self.isUnsaved = isUnsaved
        self.isActive = isActive
        self.isPinned = isPinned
        self.isPreview = isPreview
        self.fileEncoding = fileEncoding
        self.remotePath = remotePath
        self.remoteHost = remoteHost
        
        // Auto-detect language from file extension if not provided
        if let language = language {
            self.language = language
        } else {
            let fileExtension = (fileName as NSString).pathExtension
            self.language = CodeLanguage(from: fileExtension)
        }
        // Seed caches manually — `didSet` does not fire during `init`
        _cachedLineCount   = Tab.computeLineCount(for: content)
        _cachedContentSize = content.utf8.count
    }
    
    /// Convenience initializer that accepts language as String
    init(
        id: UUID = UUID(),
        fileName: String,
        content: String = "",
        language: String,
        url: URL? = nil,
        isUnsaved: Bool = false,
        isActive: Bool = false,
        isPinned: Bool = false,
        isPreview: Bool = false,
        fileEncoding: UInt = String.Encoding.utf8.rawValue,
        remotePath: String? = nil,
        remoteHost: String? = nil
    ) {
        self.init(
            id: id,
            fileName: fileName,
            content: content,
            language: CodeLanguage(from: language),
            url: url,
            isUnsaved: isUnsaved,
            isActive: isActive,
            isPinned: isPinned,
            isPreview: isPreview,
            fileEncoding: fileEncoding,
            remotePath: remotePath,
            remoteHost: remoteHost
        )
    }

    /// Custom Codable decoder that re-seeds derived caches after decoding,
    /// since `didSet` observers do not fire during `init`.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(UUID.self,            forKey: .id)
        fileName           = try c.decode(String.self,          forKey: .fileName)
        content            = try c.decode(String.self,          forKey: .content)
        language           = try c.decode(CodeLanguage.self,    forKey: .language)
        url                = try c.decodeIfPresent(URL.self,    forKey: .url)
        remotePath         = try c.decodeIfPresent(String.self, forKey: .remotePath)
        remoteHost         = try c.decodeIfPresent(String.self, forKey: .remoteHost)
        isUnsaved          = try c.decode(Bool.self,            forKey: .isUnsaved)
        isActive           = try c.decode(Bool.self,            forKey: .isActive)
        isPinned           = try c.decode(Bool.self,            forKey: .isPinned)
        isPreview          = try c.decode(Bool.self,            forKey: .isPreview)
        fileEncoding       = try c.decode(UInt.self,            forKey: .fileEncoding)
        // Transient UI state — always starts fresh after a decode
        savedScrollOffset  = 0
        savedCursorIndex   = 0
        // Seed caches — `didSet` does not fire during `init`
        _cachedLineCount   = Tab.computeLineCount(for: content)
        _cachedContentSize = content.utf8.count
    }

    // MARK: - Computed Properties
    
    /// File extension (e.g., "swift", "js")
    var fileExtension: String {
        (fileName as NSString).pathExtension.lowercased()
    }
    
    /// Display title for the tab (includes unsaved indicator)
    var displayTitle: String {
        isUnsaved ? "● \(fileName)" : fileName
    }
    
    /// Number of lines in the content.
    /// O(1) — the cache is refreshed via `_updateCaches()` on every `content` mutation.
    var lineCount: Int { _cachedLineCount }
    
    /// File size in bytes.
    /// O(1) — the cache is refreshed via `_updateCaches()` on every `content` mutation.
    var contentSize: Int { _cachedContentSize }
    
    // MARK: - Equatable & Hashable
    
    /// Tabs are equal if they have the same ID
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Hash based on ID only
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Private Cache Helpers

    /// Recomputes all O(n) derived values whenever `content` is mutated.
    /// Called automatically via the `content` property's `didSet` observer.
    private mutating func _updateCaches() {
        _cachedLineCount   = Tab.computeLineCount(for: content)
        _cachedContentSize = content.utf8.count
    }

    /// Counts '\n' (0x0A) bytes via a single, allocation-free UTF-8 scan.
    /// O(n) in content length — but called only on mutation, never on read.
    private static func computeLineCount(for text: String) -> Int {
        if text.isEmpty { return 0 }
        var count = 1
        for byte in text.utf8 where byte == 0x0A {
            count += 1
        }
        return count
    }
}

// MARK: - CodeLanguage

/// Supported programming languages and file types
enum CodeLanguage: String, CaseIterable, Codable {
    case swift = "swift"
    case javascript = "javascript"
    case typescript = "typescript"
    case python = "python"
    case html = "html"
    case css = "css"
    case json = "json"
    case markdown = "markdown"
    case yaml = "yaml"
    case xml = "xml"
    case plainText = "plaintext"
    
    // MARK: - Initialization
    
    /// Detects language from file extension
    /// - Parameter fileExtension: File extension (e.g., "swift", "js")
    init(from fileExtension: String) {
        let ext = fileExtension.lowercased()
        switch ext {
        case "swift":
            self = .swift
        case "js", "jsx", "mjs":
            self = .javascript
        case "ts", "tsx":
            self = .typescript
        case "py", "pyw":
            self = .python
        case "html", "htm":
            self = .html
        case "css", "scss", "sass", "less":
            self = .css
        case "json":
            self = .json
        case "md", "markdown":
            self = .markdown
        case "yml", "yaml":
            self = .yaml
        case "xml":
            self = .xml
        default:
            self = .plainText
        }
    }
    
    // MARK: - Display Properties
    
    /// Human-readable display name
    var displayName: String {
        switch self {
        case .swift: return "Swift"
        case .javascript: return "JavaScript"
        case .typescript: return "TypeScript"
        case .python: return "Python"
        case .html: return "HTML"
        case .css: return "CSS"
        case .json: return "JSON"
        case .markdown: return "Markdown"
        case .yaml: return "YAML"
        case .xml: return "XML"
        case .plainText: return "Plain Text"
        }
    }
    
    /// Icon name for SF Symbols
    var iconName: String {
        switch self {
        case .swift: return "swift"
        case .javascript, .typescript: return "curlybraces"
        case .python: return "chevron.left.forwardslash.chevron.right"
        case .html: return "globe"
        case .css: return "paintbrush"
        case .json: return "curlybraces.square"
        case .markdown: return "doc.richtext"
        case .yaml, .xml: return "doc.text"
        case .plainText: return "doc"
        }
    }
    
    /// Color associated with the language
    var color: Color {
        switch self {
        case .swift: return .orange
        case .javascript: return .yellow
        case .typescript: return .blue
        case .python: return .green
        case .html: return .red
        case .css: return .purple
        case .json: return .green
        case .markdown: return .blue
        case .yaml: return .cyan
        case .xml: return .orange
        case .plainText: return .gray
        }
    }
}
// MARK: - String.Encoding Display Name

extension String.Encoding {
    /// Human-readable display name for common text encodings (like VS Code's status bar).
    var displayName: String {
        switch self {
        case .utf8: return "UTF-8"
        case .utf16: return "UTF-16"
        case .utf16LittleEndian: return "UTF-16 LE"
        case .utf16BigEndian: return "UTF-16 BE"
        case .utf32: return "UTF-32"
        case .utf32LittleEndian: return "UTF-32 LE"
        case .utf32BigEndian: return "UTF-32 BE"
        case .isoLatin1: return "ISO 8859-1"
        case .isoLatin2: return "ISO 8859-2"
        case .ascii: return "ASCII"
        case .nextstep: return "NextStep"
        case .japaneseEUC: return "EUC-JP"
        case .shiftJIS: return "Shift_JIS"
        case .nonLossyASCII: return "Non-lossy ASCII"
        default:
            let cfEncoding = CFStringEncoding(rawValue)
            if let name = CFStringGetNameOfEncoding(cfEncoding) {
                return String(name)
            }
            return "Unknown"
        }
    }
}
