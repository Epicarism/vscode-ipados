//
//  FindReferencesService.swift
//  VSCodeiPadOS
//
//  Service for finding symbol references across the workspace.
//  Searches all source files (.swift, .js, .ts, .py, .go, .rs, etc.)
//  Returns references with file, line, column, and line text.
//

import Foundation

/// Result of a find-references search
public struct ReferenceLocation: Codable, Hashable, Identifiable {
    public let id = UUID()
    public let file: String
    public let line: Int        // 1-based line number
    public let column: Int      // 1-based column number
    public let lineText: String
    
    public init(file: String, line: Int, column: Int, lineText: String) {
        self.file = file
        self.line = line
        self.column = column
        self.lineText = lineText
    }
}

/// Service that finds references to a symbol across all source files in a workspace.
/// Uses whole-word matching to find occurrences of the symbol name.
@MainActor
public final class FindReferencesService: ObservableObject {
    
    // MARK: - Published State
    
    @Published public private(set) var isSearching: Bool = false
    @Published public private(set) var progress: Double = 0
    @Published public private(set) var results: [ReferenceLocation] = []
    @Published public private(set) var lastError: String? = nil
    
    // MARK: - Configuration
    
    // MARK: - Configuration
    
    /// Source file extensions to search
    nonisolated public static let sourceFileExtensions: Set<String> = [
        "swift", "js", "ts", "jsx", "tsx", "py", "go", "rs", "java", "kt", "kts",
        "c", "cpp", "cc", "cxx", "h", "hpp", "hxx", "m", "mm",
        "cs", "rb", "php", "lua", "r", "scala", "sc",
        "sh", "bash", "zsh", "fish",
        "json", "yaml", "yml", "xml", "toml", "ini", "conf", "cfg",
        "md", "markdown", "txt", "rst"
    ]
    
    /// Directories to exclude from search
    nonisolated private static let excludedDirectories: Set<String> = [
        ".git", ".svn", ".hg",
        "node_modules", "bower_components",
        "DerivedData", "build", "Build", "out", "bin", "obj",
        ".build", ".venv", "venv", "__pycache__", ".tox",
        "Pods", "Carthage", "Checkouts",
        ".swiftpm", ".spi", ".upm",
        "dist", "target", "vendor"
    ]
    
    // MARK: - Private
    
    private var searchTask: Task<Void, Never>? = nil
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Public API
    
    /// Cancel any in-flight search
    public func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
        isSearching = false
    }
    
    /// Clear results
    public func clearResults() {
        results = []
        lastError = nil
    }
    
    /// Find references to a symbol across all source files in the workspace.
    /// - Parameters:
    ///   - symbol: The symbol name to search for
    ///   - rootURL: The workspace root directory to search within
    ///   - fileURLs: Optional pre-resolved file list (if nil, will enumerate from rootURL)
    /// - Returns: Array of reference locations
    @MainActor
    public func findReferences(
        symbol: String,
        in rootURL: URL,
        fileURLs: [URL]? = nil
    ) {
        let trimmed = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            lastError = "Symbol name is empty"
            return
        }
        
        cancelSearch()
        lastError = nil
        results = []
        progress = 0
        isSearching = true
        
        searchTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            
            do {
                // Get list of source files
                let sourceFiles = try await self.resolveSourceFiles(rootURL: rootURL, provided: fileURLs)
                let total = max(sourceFiles.count, 1)
                
                var allResults: [ReferenceLocation] = []
                allResults.reserveCapacity(min(sourceFiles.count * 5, 1000))
                
                // Search each file
                for (idx, url) in sourceFiles.enumerated() {
                    try Task.checkCancellation()
                    
                    if let fileResults = try self.searchFile(url: url, rootURL: rootURL, symbol: trimmed) {
                        allResults.append(contentsOf: fileResults)
                    }
                    
                    // Update progress
                    let p = Double(idx + 1) / Double(total)
                    await MainActor.run {
                        self.progress = p
                    }
                }
                
                // Sort results by file path, then line number
                allResults.sort { lhs, rhs in
                    if lhs.file != rhs.file {
                        return lhs.file < rhs.file
                    }
                    return lhs.line < rhs.line
                }
                
                await MainActor.run {
                    self.results = allResults
                    self.isSearching = false
                    self.progress = 1
                }
                
            } catch is CancellationError {
                await MainActor.run {
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.isSearching = false
                }
            }
        }
    }
    
    /// Synchronous version that returns results directly (blocking)
    public func findReferencesSync(
        symbol: String,
        in rootURL: URL,
        fileURLs: [URL]? = nil
    ) throws -> [ReferenceLocation] {
        let trimmed = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return []
        }
        
        let sourceFiles = try resolveSourceFilesSync(rootURL: rootURL, provided: fileURLs)
        var allResults: [ReferenceLocation] = []
        
        for url in sourceFiles {
            if let fileResults = try searchFile(url: url, rootURL: rootURL, symbol: trimmed) {
                allResults.append(contentsOf: fileResults)
            }
        }
        
        allResults.sort { lhs, rhs in
            if lhs.file != rhs.file {
                return lhs.file < rhs.file
            }
            return lhs.line < rhs.line
        }
        
        return allResults
    }
    
    // MARK: - File Resolution
    
    nonisolated private func resolveSourceFiles(rootURL: URL, provided: [URL]?) async throws -> [URL] {
        // If files provided, filter them; otherwise enumerate
        let all: [URL]
        if let provided {
            all = provided
        } else {
            all = try enumerateSourceFiles(rootURL: rootURL)
        }
        
        // Filter to only source files
        return all.filter { url in
            let ext = url.pathExtension.lowercased()
            return Self.sourceFileExtensions.contains(ext)
        }
    }
    
    nonisolated private func resolveSourceFilesSync(rootURL: URL, provided: [URL]?) throws -> [URL] {
        let all: [URL]
        if let provided {
            all = provided
        } else {
            all = try enumerateSourceFiles(rootURL: rootURL)
        }
        
        return all.filter { url in
            let ext = url.pathExtension.lowercased()
            return Self.sourceFileExtensions.contains(ext)
        }
    }
    
    nonisolated private func enumerateSourceFiles(rootURL: URL) throws -> [URL] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey, .nameKey],
            options: [.skipsHiddenFiles],
            errorHandler: { url, error in
                // Continue on errors
                AppLogger.fileSystem.debug("Enumerator error at \(url.path): \(error.localizedDescription)")
                return true
            }
        ) else {
            return []
        }
        
        var urls: [URL] = []
        
        for case let url as URL in enumerator {
            do {
                let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey, .nameKey])
                
                // Skip excluded directories
                if values.isDirectory == true {
                    if let name = values.name, Self.excludedDirectories.contains(name) {
                        enumerator.skipDescendants()
                        continue
                    }
                    continue
                }
                
                // Only include regular files
                if values.isRegularFile == true {
                    urls.append(url)
                }
            } catch {
                // Skip files we can't read
                continue
            }
        }
        
        return urls
    }
    
    // MARK: - File Search
    
    nonisolated private func searchFile(
        url: URL,
        rootURL: URL,
        symbol: String
    ) throws -> [ReferenceLocation]? {
        // Skip large files (>10MB)
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        if let fileSize = attrs?[.size] as? Int, fileSize > 10_000_000 {
            return nil
        }
        
        // Read file content
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            return nil
        }
        
        // Try UTF-8 decoding
        guard let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        // Compute relative path
        let relPath: String
        if url.path.hasPrefix(rootURL.path) {
            relPath = String(url.path.dropFirst(rootURL.path.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        } else {
            relPath = url.path
        }
        
        // Find all occurrences with whole-word matching
        let matches = findWholeWordMatches(in: text, symbol: symbol)
        
        guard !matches.isEmpty else { return nil }
        
        // Convert to reference locations
        return matches.map { line, column, lineText in
            ReferenceLocation(file: relPath, line: line, column: column, lineText: lineText)
        }
    }
    
    /// Find all whole-word matches of a symbol in text
    /// - Returns: Array of (line, column, lineText) tuples (1-based)
    nonisolated private func findWholeWordMatches(in text: String, symbol: String) -> [(line: Int, column: Int, lineText: String)] {
        guard !symbol.isEmpty else { return [] }
        
        // Build a regex for whole-word matching
        // \b matches word boundaries
        let pattern = "\\b" + NSRegularExpression.escapedPattern(for: symbol) + "\\b"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let nsText = text as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)
        
        let matches = regex.matches(in: text, options: [], range: fullRange)
        guard !matches.isEmpty else { return [] }
        
        // Build line index for converting offsets to line/column
        let lineIndex = ReferenceLineIndex(text)
        var results: [(line: Int, column: Int, lineText: String)] = []
        results.reserveCapacity(matches.count)
        
        for match in matches {
            guard match.range.location != NSNotFound else { continue }
            
            let (line, col) = lineIndex.lineAndColumn(utf16Offset: match.range.location)
            let lineText = lineIndex.lineText(line: line)
            
            results.append((line: line, column: col, lineText: lineText))
        }
        
        return results
    }
}

// MARK: - Line Index Helper

/// Helper for converting UTF-16 offsets to line/column numbers
private struct ReferenceLineIndex {
    private let nsText: NSString
    private var lineStarts: [Int] = [0]
    private var lines: [String] = []
    
    init(_ text: String) {
        self.nsText = text as NSString
        
        // Build line start offsets
        var idx = 0
        var currentLine = 1
        while idx < nsText.length {
            let r = nsText.lineRange(for: NSRange(location: idx, length: 0))
            let lineStr = nsText.substring(with: r).trimmingCharacters(in: CharacterSet.newlines)
            if lines.count < currentLine {
                lines.append(lineStr)
            } else {
                lines[currentLine - 1] = lineStr
            }
            
            idx = NSMaxRange(r)
            if idx < nsText.length {
                lineStarts.append(idx)
                currentLine += 1
            }
        }
        
        if nsText.length == 0 {
            lines = [""]
            lineStarts = [0]
        } else if lines.isEmpty {
            lines = [text]
            lineStarts = [0]
        }
    }
    
    /// Convert UTF-16 offset to 1-based line and column
    func lineAndColumn(utf16Offset: Int) -> (line: Int, column: Int) {
        // Binary search for line
        var lo = 0
        var hi = lineStarts.count - 1
        while lo <= hi {
            let mid = (lo + hi) / 2
            let v = lineStarts[mid]
            if v == utf16Offset {
                return (mid + 1, 1)
            } else if v < utf16Offset {
                lo = mid + 1
            } else {
                hi = mid - 1
            }
        }
        
        let lineIndex = max(hi, 0)
        let lineStart = lineStarts[lineIndex]
        let col = max(utf16Offset - lineStart, 0) + 1
        return (lineIndex + 1, col)
    }
    
    /// Get the text of a specific line (1-based)
    func lineText(line: Int) -> String {
        let i = max(1, line) - 1
        if i >= 0 && i < lines.count {
            return lines[i]
        }
        return ""
    }
}
