//
//  LargeFileHandler.swift
//  VSCodeiPadOS
//
//  Handles large files efficiently with viewport-based loading, memory-mapped I/O,
//  and automatic feature degradation for files with millions of lines.
//

import Foundation
import Combine
import UIKit
import os

// MARK: - Performance Tier

enum EditorPerformanceTier: Int, Comparable {
    case full = 0           // < 10K lines — all features enabled
    case large = 1          // 10K–100K lines — reduced minimap, fold detection
    case veryLarge = 2      // 100K–500K lines — no minimap, no indent guides
    case massive = 3        // 500K–1M lines — viewport-only syntax, no overlays
    case extreme = 4        // > 1M lines — viewport-only everything, minimal features
    
    static func < (lhs: EditorPerformanceTier, rhs: EditorPerformanceTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    var description: String {
        switch self {
        case .full: return "Full (all features)"
        case .large: return "Large file mode"
        case .veryLarge: return "Very large file mode"
        case .massive: return "Massive file mode"
        case .extreme: return "Extreme size mode"
        }
    }
    
    // Feature flags per tier
    var enableMinimap: Bool { self <= .large }
    var enableIndentGuides: Bool { self <= .large }
    var enableFoldDetection: Bool { self <= .veryLarge }
    var enableFullSyntaxHighlight: Bool { self <= .large }
    var enableGitGutter: Bool { self <= .veryLarge }
    var enableInlayHints: Bool { self <= .full }
    var enableBracketGuides: Bool { self <= .veryLarge }
    var enableStickyHeaders: Bool { self <= .large }
    
    /// How many lines above/below viewport to syntax-highlight
    var syntaxHighlightBuffer: Int {
        switch self {
        case .full: return 2000
        case .large: return 500
        case .veryLarge: return 200
        case .massive: return 100
        case .extreme: return 50
        }
    }
    
    /// How many lines above/below viewport to detect folds
    var foldDetectionBuffer: Int {
        switch self {
        case .full: return Int.max  // entire file
        case .large: return 5000
        case .veryLarge: return 1000
        case .massive, .extreme: return 0  // disabled
        }
    }
}

// MARK: - File Size Info

struct FileSizeInfo {
    let byteCount: Int
    let lineCount: Int
    let tier: EditorPerformanceTier
    let warningMessage: String?
    let fileId: String?
    
    var humanReadableSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(byteCount))
    }
}

// MARK: - Large File Handler

@MainActor
final class LargeFileHandler: ObservableObject {
    static let shared = LargeFileHandler()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "LargeFileHandler")
    
    @Published var currentTier: EditorPerformanceTier = .full
    @Published var currentFileInfo: FileSizeInfo?
    @Published var isLoadingLargeFile = false
    @Published var loadProgress: Double = 0
    
    // Thresholds
    private let byteSizeThresholds: [(Int, EditorPerformanceTier)] = [
        (50_000_000, .extreme),    // > 50MB
        (10_000_000, .massive),    // > 10MB
        (1_000_000, .veryLarge),   // > 1MB
        (100_000, .large),         // > 100KB
    ]
    
    private let lineCountThresholds: [(Int, EditorPerformanceTier)] = [
        (1_000_000, .extreme),     // > 1M lines
        (500_000, .massive),       // > 500K lines
        (100_000, .veryLarge),     // > 100K lines
        (10_000, .large),          // > 10K lines
    ]
    
    // Line offset index for O(1) random access
    private var lineOffsets: [Int] = []
    private var lineOffsetsFileId: String?
    
    // Persistent memory mapping
    private var persistentMapping: Data?
    private var persistentMappingURL: URL?
    
    // Cancellable loading task
    private var loadingTask: Task<Void, Never>?
    
    // Cache to skip redundant O(n) analysis
    private var lastAnalyzedFileId: String?
    private var lastAnalyzedSize: Int = -1

    private init() {
        // Wire memory pressure notifications
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleMemoryPressure()
            }
        }
    }
    
    // MARK: - Analyze File
    
    /// Analyze a file and determine the performance tier
    func analyzeFile(content: String, fileId: String) -> FileSizeInfo {
        // Fast skip: if we already analyzed this file at same size, return cached
        let utf16Len = content.utf16.count  // O(1) for NSString-backed strings
        if fileId == lastAnalyzedFileId, utf16Len == lastAnalyzedSize, let cached = currentFileInfo {
            return cached
        }
        lastAnalyzedFileId = fileId
        lastAnalyzedSize = utf16Len
        
        let byteCount = content.utf8.count
        let lineCount = countLinesFast(content)
        
        // Determine tier from worst (highest) match
        var tier: EditorPerformanceTier = .full
        
        for (threshold, tierValue) in byteSizeThresholds {
            if byteCount > threshold {
                tier = max(tier, tierValue)
                break
            }
        }
        
        for (threshold, tierValue) in lineCountThresholds {
            if lineCount > threshold {
                tier = max(tier, tierValue)
                break
            }
        }
        
        let warning: String?
        switch tier {
        case .full:
            warning = nil
        case .large:
            warning = "Large file (\(formatCount(lineCount)) lines). Some features may be reduced."
        case .veryLarge:
            warning = "Very large file (\(formatCount(lineCount)) lines). Minimap and some overlays disabled."
        case .massive:
            warning = "⚠️ Massive file (\(formatCount(lineCount)) lines). Operating in viewport-only mode."
        case .extreme:
            warning = "⚠️ Extremely large file (\(formatCount(lineCount)) lines). Minimal features active."
        }
        
        let info = FileSizeInfo(byteCount: byteCount, lineCount: lineCount, tier: tier, warningMessage: warning, fileId: fileId)
        
        self.currentTier = tier
        self.currentFileInfo = info
        
        if tier >= .large {
            Self.logger.info("File \(fileId): \(byteCount) bytes, \(lineCount) lines → tier \(tier.description)")
        }
        
        // Build line offset index for large files (in background)
        if tier >= .large {
            buildLineOffsetIndex(content: content, fileId: fileId)
        }
        
        return info
    }
    
    /// Analyze a file URL without loading full content
    func analyzeFileURL(_ url: URL) -> EditorPerformanceTier {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attrs[.size] as? Int ?? 0
            
            for (threshold, tier) in byteSizeThresholds {
                if fileSize > threshold {
                    return tier
                }
            }
        } catch {
            Self.logger.error("Failed to get file attributes: \(error.localizedDescription)")
        }
        return .full
    }
    
    // MARK: - Feature Gating
    
    /// Editor feature categories for tier-based gating
    enum PerformanceFeature {
        case syntaxHighlighting
        case codeFolding
        case minimap
        case inlayHints
        case bracketMatching
        case wordWrap
        case gitGutter
        case indentGuides
        case stickyHeaders
    }
    
    /// Check if a feature should be enabled for the current file size/tier
    func shouldEnableFeature(_ feature: PerformanceFeature) -> Bool {
        switch feature {
        case .syntaxHighlighting: return currentTier.enableFullSyntaxHighlight
        case .codeFolding: return currentTier.enableFoldDetection
        case .minimap: return currentTier.enableMinimap
        case .inlayHints: return currentTier.enableInlayHints
        case .bracketMatching: return currentTier.enableBracketGuides
        case .wordWrap: return currentTier <= .veryLarge
        case .gitGutter: return currentTier.enableGitGutter
        case .indentGuides: return currentTier.enableIndentGuides
        case .stickyHeaders: return currentTier.enableStickyHeaders
        }
    }
    
    /// Check if a feature should be enabled for a specific file size
    func shouldEnableFeature(_ feature: PerformanceFeature, for fileSize: Int) -> Bool {
        var tier: EditorPerformanceTier = .full
        for (threshold, tierValue) in byteSizeThresholds {
            if fileSize > threshold {
                tier = max(tier, tierValue)
                break
            }
        }
        // Temporarily check with the computed tier
        switch feature {
        case .syntaxHighlighting: return tier.enableFullSyntaxHighlight
        case .codeFolding: return tier.enableFoldDetection
        case .minimap: return tier.enableMinimap
        case .inlayHints: return tier.enableInlayHints
        case .bracketMatching: return tier.enableBracketGuides
        case .wordWrap: return tier <= .veryLarge
        case .gitGutter: return tier.enableGitGutter
        case .indentGuides: return tier.enableIndentGuides
        case .stickyHeaders: return tier.enableStickyHeaders
        }
    }
    
    /// Get total line count, building index on demand if needed
    var lineCount: Int {
        if lineOffsets.isEmpty {
            return currentFileInfo?.lineCount ?? 0
        }
        return lineOffsets.count + 1  // offsets track newline positions; +1 for last line
    }
    
    // MARK: - Viewport-Based Content Loading
    
    /// Get text for a specific line range (for viewport-based rendering)
    /// Handles edge cases: empty file, range beyond file, negative start
    func getLines(from startLine: Int, count: Int, in text: String) -> String {
        guard !text.isEmpty, count > 0 else { return "" }
        let effectiveStart = max(0, startLine)
        // PERF: Use line offset index when available for O(1) start position
        // Build index on-demand if needed and we have persistent mapping
        if !lineOffsets.isEmpty {
            let nsText = text as NSString
            let startOffset: Int
            if effectiveStart == 0 {
                startOffset = 0
            } else if effectiveStart - 1 < lineOffsets.count {
                startOffset = lineOffsets[effectiveStart - 1]
            } else {
                return "" // Beyond indexed lines
            }
            
            let endLine = effectiveStart + count
            let endOffset: Int
            if endLine - 1 < lineOffsets.count {
                endOffset = lineOffsets[endLine - 1]
            } else {
                endOffset = nsText.length
            }
            
            let safeStart = min(startOffset, nsText.length)
            let safeEnd = min(endOffset, nsText.length)
            guard safeEnd > safeStart else { return "" }
            let range = NSRange(location: safeStart, length: safeEnd - safeStart)
            return nsText.substring(with: range)
        }
        
        // Fallback: O(n) iteration — also builds line offset index for next call
        let nsText = text as NSString
        var currentLine = 0
        var lineStart = 0
        var resultStart = -1
        var resultEnd = nsText.length
        
        // Build offset index as we iterate (amortized)
        var buildingOffsets: [Int] = []
        if lineOffsets.isEmpty && nsText.length > 100_000 {
            buildingOffsets.reserveCapacity(nsText.length / 40)
        }
        
        while lineStart < nsText.length && currentLine < effectiveStart + count {
            let lineRange = nsText.lineRange(for: NSRange(location: lineStart, length: 0))
            
            if currentLine == effectiveStart {
                resultStart = lineRange.location
            }
            if currentLine == effectiveStart + count - 1 {
                resultEnd = lineRange.location + lineRange.length
                break
            }
            
            // Track newline offsets while we're iterating
            if !buildingOffsets.isEmpty || (lineOffsets.isEmpty && nsText.length > 100_000) {
                buildingOffsets.append(lineRange.location + lineRange.length)
            }
            
            lineStart = lineRange.location + lineRange.length
            currentLine += 1
        }
        
        if resultStart < 0 { resultStart = 0 }
        let range = NSRange(location: resultStart, length: min(resultEnd - resultStart, nsText.length - resultStart))
        return nsText.substring(with: range)
    }
    
    /// Get line offset for a specific line number using cached index
    func lineOffset(for lineNumber: Int) -> Int? {
        guard lineNumber > 0 else { return 0 }
        guard lineNumber - 1 < lineOffsets.count else { return nil }
        return lineOffsets[lineNumber - 1]
    }
    
    // MARK: - Memory-Mapped File Reading
    
    /// Read a file using memory mapping for efficient access to very large files
    func memoryMappedRead(url: URL) throws -> Data {
        return try Data(contentsOf: url, options: .mappedIfSafe)
    }
    
    /// Read a specific byte range, reusing persistent memory mapping
    func readRange(url: URL, offset: Int, length: Int) throws -> Data {
        // Reuse persistent mapping if same URL
        let data: Data
        if persistentMappingURL == url, let existing = persistentMapping {
            data = existing
        } else {
            data = try memoryMappedRead(url: url)
            persistentMapping = data
            persistentMappingURL = url
        }
        let safeOffset = min(offset, data.count)
        let safeLength = min(length, data.count - safeOffset)
        return data[safeOffset..<(safeOffset + safeLength)]
    }
    
    // MARK: - Incremental Loading
    
    /// Load a large file incrementally, calling progress callbacks
    func loadFileIncrementally(
        url: URL,
        chunkSize: Int = 65536,
        progress: @Sendable @escaping (Double) -> Void,
        completion: @Sendable @escaping (Result<String, Error>) -> Void
    ) {
        isLoadingLargeFile = true
        loadProgress = 0
        
        // Cancel any previous loading task
        loadingTask?.cancel()
        
        let task = Task.detached(priority: .userInitiated) {
            do {
                let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                let fileSize = attrs[.size] as? Int ?? 0
                
                let handle = try FileHandle(forReadingFrom: url)
                defer { handle.closeFile() }
                
                var result = Data()
                result.reserveCapacity(fileSize)
                var bytesRead = 0
                
                while true {
                    let chunk = handle.readData(ofLength: chunkSize)
                    if chunk.isEmpty { break }
                    
                    result.append(chunk)
                    bytesRead += chunk.count
                    
                    let pct = Double(bytesRead) / Double(max(1, fileSize))
                    await MainActor.run { [weak self] in
                        self?.loadProgress = pct
                        progress(pct)
                    }
                }
                
                let text = String(data: result, encoding: .utf8) ?? String(data: result, encoding: .ascii) ?? ""
                
                await MainActor.run { [weak self] in
                    self?.isLoadingLargeFile = false
                    self?.loadProgress = 1.0
                    completion(.success(text))
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.isLoadingLargeFile = false
                    completion(.failure(error))
                }
            }
        }
        loadingTask = task
    }
    
    // MARK: - Line Offset Index
    
    /// Build a line offset index for fast random access
    private func buildLineOffsetIndex(content: String, fileId: String) {
        Task.detached(priority: .utility) { [weak self] in
            let startTime = CFAbsoluteTimeGetCurrent()
            
            var offsets: [Int] = []
            offsets.reserveCapacity(content.count / 40)  // Estimate ~40 chars per line
            
            var offset = 0
            for codeUnit in content.utf16 {
                if codeUnit == 0x000A { // newline in UTF-16
                    offsets.append(offset + 1)  // Start of next line
                }
                offset += 1
            }
            
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            
            await MainActor.run { [weak self] in
                self?.lineOffsets = offsets
                self?.lineOffsetsFileId = fileId
                LargeFileHandler.logger.info("Built line offset index: \(offsets.count) lines in \(String(format: "%.2f", elapsed * 1000))ms")
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Fast line counting using UTF-8 byte scan
    private func countLinesFast(_ text: String) -> Int {
        guard !text.isEmpty else { return 1 }
        var count = 1
        for byte in text.utf8 {
            if byte == UInt8(ascii: "\n") { count += 1 }
        }
        return count
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
    
    // MARK: - Memory Pressure
    
    /// Called when system is under memory pressure - release caches
    func handleMemoryPressure() {
        lineOffsets = []
        lineOffsetsFileId = nil
        currentFileInfo = nil
        persistentMapping = nil
        persistentMappingURL = nil
        loadingTask?.cancel()
        loadingTask = nil
        Self.logger.info("Released large file handler caches due to memory pressure")
    }
}
