//
//  ViewportHighlightManager.swift
//  VSCodeiPadOS
//
//  Viewport-aware syntax highlighting optimization manager.
//  Computes visible line ranges, manages priority-based highlighting,
//  provides semantic token overlays, and pre-fetches for scroll regions.
//

import Foundation
import UIKit
import Combine
import os

// MARK: - Viewport Region

struct ViewportRegion: Equatable {
    let firstVisibleLine: Int
    let lastVisibleLine: Int
    let bufferLinesBefore: Int
    let bufferLinesAfter: Int
    let totalLines: Int
    
    var visibleRange: ClosedRange<Int> {
        max(0, firstVisibleLine)...min(totalLines - 1, lastVisibleLine)
    }
    
    var bufferedRange: ClosedRange<Int> {
        let start = max(0, firstVisibleLine - bufferLinesBefore)
        let end = min(totalLines - 1, lastVisibleLine + bufferLinesAfter)
        return start...end
    }
    
    var visibleLineCount: Int {
        lastVisibleLine - firstVisibleLine + 1
    }
    
    var bufferedLineCount: Int {
        bufferedRange.count
    }
    
    func contains(line: Int) -> Bool {
        visibleRange.contains(line)
    }
    
    func isInBuffer(line: Int) -> Bool {
        bufferedRange.contains(line)
    }
}

// MARK: - Semantic Token Types

enum SemanticTokenType: String, CaseIterable, Codable, Sendable {
    case namespace
    case type
    case `class`
    case `enum`
    case interface
    case `struct`
    case typeParameter
    case parameter
    case variable
    case property
    case enumMember
    case event
    case function
    case method
    case macro
    case keyword
    case modifier
    case comment
    case string
    case number
    case regexp
    case `operator`
    case decorator
    
    var defaultColor: UIColor {
        switch self {
        case .keyword, .modifier: return .systemPurple
        case .type, .class, .struct, .enum, .interface: return .systemTeal
        case .function, .method: return .systemYellow
        case .variable, .parameter, .property: return .systemBlue
        case .string: return .systemGreen
        case .number: return .systemOrange
        case .comment: return .systemGray
        case .operator: return .white
        case .namespace, .macro, .decorator: return .systemCyan
        case .enumMember, .event: return .systemIndigo
        case .typeParameter: return .systemMint
        case .regexp: return .systemRed
        }
    }
}

enum SemanticTokenModifier: String, CaseIterable, Codable, Sendable {
    case declaration
    case definition
    case readonly
    case `static`
    case deprecated
    case abstract
    case async
    case modification
    case documentation
    case defaultLibrary
}

struct SemanticToken: Equatable, Sendable {
    let line: Int
    let startColumn: Int
    let length: Int
    let tokenType: SemanticTokenType
    let modifiers: Set<SemanticTokenModifier>
    
    var endColumn: Int { startColumn + length }
}

// MARK: - Highlight Priority

enum HighlightPriority: Int, Comparable {
    case visible = 3
    case nearBuffer = 2
    case farBuffer = 1
    case background = 0
    
    static func < (lhs: HighlightPriority, rhs: HighlightPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct HighlightRequest: Comparable {
    let lineRange: ClosedRange<Int>
    let priority: HighlightPriority
    let fileId: String
    let language: String
    let requestedAt: Date
    
    static func < (lhs: HighlightRequest, rhs: HighlightRequest) -> Bool {
        if lhs.priority != rhs.priority {
            return lhs.priority > rhs.priority  // Higher priority first
        }
        return lhs.requestedAt < rhs.requestedAt  // Earlier request first
    }
}

// MARK: - Thread-Safe Token Cache Actor

/// Actor providing thread-safe access to per-file semantic token storage.
/// All heavy token processing (indexing, merging, filtering) happens inside
/// this actor, running off the MainActor.
private actor TokenCache {
    // fileId -> (line -> tokens)
    private var tokensByFile: [String: [Int: [SemanticToken]]] = [:]
    // fileId -> dirty line numbers
    private var dirtyLines: [String: Set<Int>] = [:]
    
    /// Build a line→tokens map from a flat token array.
    /// This is the pure computational step that should run off MainActor.
    func buildLineMap(from tokens: [SemanticToken]) -> [Int: [SemanticToken]] {
        var lineMap: [Int: [SemanticToken]] = [:]
        lineMap.reserveCapacity(tokens.count)
        for token in tokens {
            lineMap[token.line, default: []].append(token)
        }
        return lineMap
    }
    
    /// Set tokens for a file. If `fullReplacement` is true the old map is
    /// discarded entirely; otherwise new lines are merged incrementally.
    func setTokens(_ lineMap: [Int: [SemanticToken]], fileId: String, fullReplacement: Bool) {
        if fullReplacement || tokensByFile[fileId] == nil {
            tokensByFile[fileId] = lineMap
        } else {
            for (line, lineTokens) in lineMap {
                tokensByFile[fileId]?[line] = lineTokens
            }
        }
    }
    
    /// Update tokens for specific lines (incremental).
    func updateTokens(_ tokens: [SemanticToken], forLines lines: ClosedRange<Int>, fileId: String) {
        // Build a quick line lookup from the flat token array
        var byLine: [Int: [SemanticToken]] = [:]
        for token in tokens {
            byLine[token.line, default: []].append(token)
        }
        for line in lines {
            tokensByFile[fileId]?[line] = byLine[line] ?? []
        }
        dirtyLines[fileId, default: []].formUnion(Set(lines))
    }
    
    /// Mark a range of lines as invalid (remove cached tokens).
    func invalidateLines(_ lines: ClosedRange<Int>, fileId: String) {
        for line in lines {
            tokensByFile[fileId]?.removeValue(forKey: line)
        }
        dirtyLines[fileId, default: []].formUnion(Set(lines))
    }
    
    /// Remove all cached data for a file.
    func clearTokens(fileId: String) {
        tokensByFile.removeValue(forKey: fileId)
    }
    
    /// Collect tokens for the visible range of a given viewport/file.
    func visibleTokens(for viewport: ViewportRegion, fileId: String) -> [SemanticToken] {
        guard let fileTokens = tokensByFile[fileId] else { return [] }
        var tokens: [SemanticToken] = []
        tokens.reserveCapacity(viewport.visibleLineCount * 4) // rough estimate
        for line in viewport.visibleRange {
            if let lineTokens = fileTokens[line] {
                tokens.append(contentsOf: lineTokens)
            }
        }
        return tokens
    }
    
    /// Pop dirty line numbers that are currently visible. The caller should
    /// refresh tokens for those lines and then call `clearDirtyLines`.
    func dirtyLinesInViewport(viewport: ViewportRegion, fileId: String) -> Set<Int> {
        let fileDirty = dirtyLines[fileId] ?? []
        return Set(fileDirty.filter { viewport.contains(line: $0) })
    }
    
    func clearDirtyLines(_ lines: Set<Int>, fileId: String) {
        dirtyLines[fileId]?.subtract(lines)
    }
    
    /// Handle memory pressure: evict tokens outside the buffered range,
    /// clear dirty state.
    func handleMemoryPressure(viewport: ViewportRegion?) {
        if let viewport = viewport {
            for (fileId, lineTokens) in tokensByFile {
                let kept = lineTokens.filter { viewport.bufferedRange.contains($0.key) }
                tokensByFile[fileId] = kept
            }
        } else {
            tokensByFile.removeAll()
        }
        dirtyLines.removeAll()
    }
}

// MARK: - Scroll Velocity Tracker

private class ScrollVelocityTracker {
    private var scrollPositions: [(offset: CGFloat, time: CFTimeInterval)] = []
    private let maxSamples = 10
    
    var currentVelocity: CGFloat {
        guard scrollPositions.count >= 2 else { return 0 }
        
        let recent = scrollPositions.suffix(3)
        guard let first = recent.first, let last = recent.last else { return 0 }
        
        let dt = last.time - first.time
        guard dt > 0 else { return 0 }
        
        return abs(last.offset - first.offset) / CGFloat(dt)
    }
    
    var isFastScrolling: Bool {
        currentVelocity > 2000  // points per second
    }
    
    func recordPosition(_ offset: CGFloat) {
        let now = CACurrentMediaTime()
        scrollPositions.append((offset, now))
        if scrollPositions.count > maxSamples {
            scrollPositions.removeFirst()
        }
        // Remove old samples (> 500ms)
        scrollPositions.removeAll { now - $0.time > 0.5 }
    }
    
    func reset() {
        scrollPositions.removeAll()
    }
}

// MARK: - Viewport Highlight Manager

@MainActor
final class ViewportHighlightManager: ObservableObject {
    static let shared = ViewportHighlightManager()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "ViewportHighlight")
    
    // MARK: - Published State
    
    @Published var currentViewport: ViewportRegion?
    @Published var visibleSemanticTokens: [SemanticToken] = []
    @Published var isHighlightingActive: Bool = false
    @Published var isFastScrolling: Bool = false
    @Published var highlightedLineRange: ClosedRange<Int>?
    
    // MARK: - Configuration
    
    var bufferLines: Int = 50
    var scrollDebounceMs: Int = 16
    var fastScrollDebounceMs: Int = 100
    var maxHighlightLinesPerFrame: Int = 200
    var enableSemanticTokens: Bool = true
    var currentFileId: String = "current"
    var currentLanguage: String = ""
    
    // MARK: - Private State
    
    private let velocityTracker = ScrollVelocityTracker()
    private var scrollDebounceTimer: Timer?
    private var highlightQueue: [HighlightRequest] = []
    private var processingTask: Task<Void, Never>?
    private var ingestTask: Task<Void, Never>?
    private var lastScrollOffset: CGFloat = 0
    private var lastViewportUpdate: Date = .distantPast
    
    /// Thread-safe token storage — all reads/writes go through this actor.
    private let tokenCache = TokenCache()
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // Performance tracking
    private var highlightTimings: [Double] = []
    private let maxTimingSamples = 30
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Scroll Position Updates
    
    /// Called from RunestoneEditorView's scrollViewDidScroll
    func updateScrollPosition(
        offset: CGFloat,
        viewportHeight: CGFloat,
        lineHeight: CGFloat,
        totalLines: Int
    ) {
        guard lineHeight > 0, totalLines > 0 else { return }
        
        velocityTracker.recordPosition(offset)
        let wasFastScrolling = isFastScrolling
        isFastScrolling = velocityTracker.isFastScrolling
        
        // Calculate visible lines
        let firstLine = max(0, Int(offset / lineHeight))
        let visibleLineCount = Int(ceil(viewportHeight / lineHeight))
        let lastLine = min(totalLines - 1, firstLine + visibleLineCount)
        
        // Adaptive buffer: reduce during fast scroll to minimize wasted work
        let effectiveBuffer = isFastScrolling ? 20 : bufferLines
        
        let viewport = ViewportRegion(
            firstVisibleLine: firstLine,
            lastVisibleLine: lastLine,
            bufferLinesBefore: effectiveBuffer,
            bufferLinesAfter: effectiveBuffer,
            totalLines: totalLines
        )
        
        // Debounce viewport updates
        let debounce = isFastScrolling
            ? TimeInterval(fastScrollDebounceMs) / 1000.0
            : TimeInterval(scrollDebounceMs) / 1000.0
        
        scrollDebounceTimer?.invalidate()
        scrollDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounce, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleViewportChange(viewport)
            }
        }
        
        // Immediate update if scrolling direction changed or stopped fast scrolling
        if wasFastScrolling && !isFastScrolling {
            handleViewportChange(viewport)
        }
        
        lastScrollOffset = offset
    }
    
    // MARK: - Viewport Change Handling
    
    private func handleViewportChange(_ viewport: ViewportRegion) {
        let previousViewport = currentViewport
        currentViewport = viewport
        
        // Only request new highlighting if viewport changed significantly
        guard shouldUpdateHighlighting(previous: previousViewport, current: viewport) else { return }
        
        lastViewportUpdate = Date()
        
        // Detect scroll direction for directional pre-fetch
        let scrollingDown = viewport.firstVisibleLine >= (previousViewport?.firstVisibleLine ?? 0)
        
        if isFastScrolling {
            // During fast scroll: only highlight visible lines, skip buffer
            enqueueHighlightRequest(
                lineRange: viewport.visibleRange,
                priority: .visible,
                fileId: currentFileId,
                language: currentLanguage
            )
        } else {
            // Normal scroll: highlight visible + directionally-biased buffer zones
            enqueueHighlightRequest(
                lineRange: viewport.visibleRange,
                priority: .visible,
                fileId: currentFileId,
                language: currentLanguage
            )
            
            // Directional near buffer: bias 2/3 in scroll direction, 1/3 behind
            let bufferAhead = bufferLines * 2 / 3
            let bufferBehind = bufferLines / 3
            let nearStart: Int
            let nearEnd: Int
            if scrollingDown {
                nearStart = max(0, viewport.firstVisibleLine - bufferBehind)
                nearEnd = min(viewport.totalLines - 1, viewport.lastVisibleLine + bufferAhead)
            } else {
                nearStart = max(0, viewport.firstVisibleLine - bufferAhead)
                nearEnd = min(viewport.totalLines - 1, viewport.lastVisibleLine + bufferBehind)
            }
            if nearStart < viewport.firstVisibleLine || nearEnd > viewport.lastVisibleLine {
                enqueueHighlightRequest(
                    lineRange: nearStart...nearEnd,
                    priority: .nearBuffer,
                    fileId: currentFileId,
                    language: currentLanguage
                )
            }
            
            // Far buffer (full buffer range)
            let farRange = viewport.bufferedRange
            if farRange.lowerBound < nearStart || farRange.upperBound > nearEnd {
                enqueueHighlightRequest(
                    lineRange: farRange,
                    priority: .farBuffer,
                    fileId: currentFileId,
                    language: currentLanguage
                )
            }
        }
        
        processHighlightQueue()
    }
    
    private func shouldUpdateHighlighting(
        previous: ViewportRegion?,
        current: ViewportRegion
    ) -> Bool {
        guard let previous = previous else { return true }
        
        // Update if visible range changed by more than 5 lines
        let lineDelta = abs(current.firstVisibleLine - previous.firstVisibleLine)
        return lineDelta >= 5
    }
    
    // MARK: - Highlight Queue
    
    private func enqueueHighlightRequest(
        lineRange: ClosedRange<Int>,
        priority: HighlightPriority,
        fileId: String,
        language: String
    ) {
        let request = HighlightRequest(
            lineRange: lineRange,
            priority: priority,
            fileId: fileId,
            language: language,
            requestedAt: Date()
        )
        
        // Remove duplicate/overlapping requests with lower priority
        highlightQueue.removeAll { existing in
            existing.fileId == fileId &&
            existing.priority <= priority &&
            existing.lineRange.overlaps(lineRange)
        }
        
        highlightQueue.append(request)
        highlightQueue.sort()  // Priority ordering
        
        // Cap queue size
        if highlightQueue.count > 20 {
            highlightQueue = Array(highlightQueue.prefix(20))
        }
    }
    
    private func processHighlightQueue() {
        // Cancel any previous processing task — viewport changed
        processingTask?.cancel()
        
        let cache = tokenCache
        let queueSnapshot = highlightQueue
        highlightQueue.removeAll()
        
        processingTask = Task { [weak self] in
            var totalLinesProcessed = 0
            
            for request in queueSnapshot {
                guard !Task.isCancelled else { break }
                guard let self = self else { break }
                
                self.isHighlightingActive = true
                
                let startTime = CACurrentMediaTime()
                let requestLineCount = request.lineRange.count
                
                // Collect tokens on the cache actor (off MainActor)
                let tokens = await cache.visibleTokens(
                    for: request,
                    fileId: request.fileId
                )
                
                // Update published properties back on MainActor
                await MainActor.run { [weak self] in
                    guard let self = self, !Task.isCancelled else { return }
                    if request.priority == .visible {
                        self.visibleSemanticTokens = tokens
                        self.highlightedLineRange = request.lineRange
                    }
                }
                
                let elapsed = (CACurrentMediaTime() - startTime) * 1000
                await MainActor.run { [weak self] in
                    self?.recordHighlightTiming(elapsed)
                }
                totalLinesProcessed += requestLineCount
                
                // Yield to UI if we've been processing too long
                if elapsed > 8 || totalLinesProcessed >= await MainActor.run(body: { [weak self] in
                    self?.maxHighlightLinesPerFrame ?? 200
                }) {
                    try? await Task.sleep(nanoseconds: 1_000_000)  // 1ms yield
                    totalLinesProcessed = 0
                }
            }
            
            await MainActor.run { [weak self] in
                self?.isHighlightingActive = false
            }
        }
    }
    
    // MARK: - Token Management

    /// Convert HighlightTokens (from SyntaxHighlightCache) into SemanticTokens and
    /// populate the token cache.  Call this after a highlighting pass completes so that
    /// updateScrollPosition / processHighlightRequest have data to work with.
    ///
    /// The heavy mapping work runs on a detached background task; previous ingest
    /// tasks are cancelled to avoid stale writes.
    func ingestHighlightTokens(_ tokens: [HighlightToken], fileId: String) {
        guard !tokens.isEmpty else { return }
        
        // Cancel any previous in-flight ingest
        ingestTask?.cancel()
        
        let cache = tokenCache
        let currentFileId = self.currentFileId
        let currentViewport = self.currentViewport
        
        ingestTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard !Task.isCancelled else { return }
            
            // Pure computation — map raw tokens into semantic tokens
            let semanticTokens: [SemanticToken] = tokens.map { tok in
                SemanticToken(
                    line: tok.line,
                    startColumn: tok.range.location,
                    length: tok.range.length,
                    tokenType: ViewportHighlightManager.semanticType(for: tok.tokenType),
                    modifiers: []
                )
            }
            
            guard !Task.isCancelled else { return }
            
            // Build line map inside the actor (thread-safe)
            let lineMap = await cache.buildLineMap(from: semanticTokens)
            
            guard !Task.isCancelled else { return }
            
            // Store and refresh visible tokens
            await cache.setTokens(lineMap, fileId: fileId, fullReplacement: false)
            
            guard !Task.isCancelled else { return }
            
            // Refresh visible tokens on MainActor
            if fileId == currentFileId, let viewport = currentViewport {
                let refreshed = await cache.visibleTokens(for: viewport, fileId: fileId)
                await MainActor.run { [weak self] in
                    guard let self = self, !Task.isCancelled else { return }
                    self.visibleSemanticTokens = refreshed
                }
            }
        }
    }

    /// Map a TreeSitter highlight name to a SemanticTokenType.
    nonisolated private static func semanticType(for treeSitterName: String) -> SemanticTokenType {
        switch treeSitterName {
        case "keyword", "keyword.control", "keyword.operator",
             "keyword.other", "storage.type", "storage.modifier":
            return .keyword
        case "entity.name.function", "support.function", "meta.function":
            return .function
        case "entity.name.type", "entity.name.class",
             "support.class", "meta.class":
            return .type
        case "entity.name.type.struct":
            return .struct
        case "entity.name.type.enum":
            return .enum
        case "entity.name.type.protocol":
            return .interface
        case "variable", "variable.other", "meta.definition.variable":
            return .variable
        case "variable.parameter", "meta.parameter":
            return .parameter
        case "variable.other.property", "support.variable.property":
            return .property
        case "string", "string.quoted", "string.template":
            return .string
        case "constant.numeric", "constant.language.number":
            return .number
        case "comment", "comment.line", "comment.block":
            return .comment
        case "keyword.operator", "punctuation.operator":
            return .operator
        case "entity.name.namespace", "meta.namespace":
            return .namespace
        case "meta.decorator", "punctuation.decorator":
            return .decorator
        default:
            return .variable
        }
    }

    /// Set semantic tokens for a file (from LSP or TreeSitter).
    /// Uses incremental merge: only replaces lines present in the new token set,
    /// preserving tokens for lines not included in this update.
    ///
    /// Heavy indexing runs off MainActor via the token cache actor.
    func setTokens(_ tokens: [SemanticToken], fileId: String, fullReplacement: Bool = false) {
        guard !tokens.isEmpty || fullReplacement else { return }
        
        let cache = tokenCache
        let currentFileId = self.currentFileId
        let currentViewport = self.currentViewport
        
        Task.detached(priority: .userInitiated) { [weak self] in
            let lineMap = await cache.buildLineMap(from: tokens)
            await cache.setTokens(lineMap, fileId: fileId, fullReplacement: fullReplacement)
            
            // Refresh visible tokens if this is the current file
            if fileId == currentFileId, let viewport = currentViewport {
                let refreshed = await cache.visibleTokens(for: viewport, fileId: fileId)
                await MainActor.run { [weak self] in
                    self?.visibleSemanticTokens = refreshed
                }
            }
        }
    }
    
    /// Update tokens for specific lines (incremental update).
    /// The indexing and cache update run off MainActor.
    func updateTokens(_ tokens: [SemanticToken], forLines lines: ClosedRange<Int>, fileId: String) {
        let cache = tokenCache
        let currentViewport = self.currentViewport
        
        Task.detached(priority: .userInitiated) { [weak self] in
            await cache.updateTokens(tokens, forLines: lines, fileId: fileId)
            
            // Refresh if dirty lines are visible
            if let viewport = currentViewport {
                let dirtyVisible = await cache.dirtyLinesInViewport(viewport: viewport, fileId: fileId)
                if !dirtyVisible.isEmpty {
                    let refreshed = await cache.visibleTokens(for: viewport, fileId: fileId)
                    await cache.clearDirtyLines(dirtyVisible, fileId: fileId)
                    await MainActor.run { [weak self] in
                        self?.visibleSemanticTokens = refreshed
                    }
                }
            }
        }
    }
    
    /// Invalidate tokens for a range of lines.
    func invalidateLines(_ lines: ClosedRange<Int>, fileId: String) {
        let cache = tokenCache
        Task.detached(priority: .userInitiated) {
            await cache.invalidateLines(lines, fileId: fileId)
        }
    }
    
    /// Clear all tokens for a file.
    func clearTokens(fileId: String) {
        visibleSemanticTokens.removeAll()
        let cache = tokenCache
        Task.detached(priority: .userInitiated) {
            await cache.clearTokens(fileId: fileId)
        }
    }
    
    // MARK: - Overlay Application
    
    /// Apply semantic token overlays to a text view for the current viewport.
    /// This MUST run on MainActor because it touches UITextStorage.
    ///
    /// - Parameter newlineOffsets: Optional sorted array of UTF-16 offsets for each '\n'.
    ///   When provided, line start lookups are O(1) instead of scanning from file start.
    ///   This cache is maintained by RunestoneEditorView.Coordinator.
    func applySemanticOverlays(
        to textView: UITextView,
        in viewport: ViewportRegion,
        baseFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular),
        newlineOffsets: [Int]? = nil
    ) {
        guard enableSemanticTokens, !visibleSemanticTokens.isEmpty else { return }
        
        let textStorage = textView.textStorage
        let text = textStorage.string
        let totalUTF16 = text.utf16.count
        
        // Find the range of lines we actually need offsets for
        var minLine = Int.max
        var maxLine = 0
        for token in visibleSemanticTokens {
            minLine = min(minLine, token.line)
            maxLine = max(maxLine, token.line)
        }
        guard minLine <= maxLine else { return }
        
        // Build line start offsets and line lengths
        var lineStartOffsets: [Int: Int] = [:] // line number -> UTF-16 offset
        var lineLengths: [Int: Int] = [:]
        lineStartOffsets.reserveCapacity(maxLine - minLine + 2)
        lineLengths.reserveCapacity(maxLine - minLine + 1)
        
        if let offsets = newlineOffsets {
            // ── O(1) per line using cached newline positions ──
            // offsets[i] = UTF-16 position of the i-th '\n' character.
            // Line 0 starts at 0. Line N (N>0) starts at offsets[N-1] + 1.
            // Line N ends at offsets[N] (exclusive) or totalUTF16 for the last line.
            for line in minLine...maxLine {
                let start: Int
                if line == 0 {
                    start = 0
                } else if line - 1 < offsets.count {
                    start = offsets[line - 1] + 1
                } else {
                    continue // line out of range
                }
                guard start <= totalUTF16 else { continue }
                lineStartOffsets[line] = start
                
                let end: Int
                if line < offsets.count {
                    end = offsets[line]
                } else {
                    end = totalUTF16
                }
                lineLengths[line] = end - start
            }
        } else {
            // ── Fallback: walk text counting newlines up to maxLine ──
            let utf16 = text.utf16
            var currentLine = 0
            var utf16Offset = 0
            
            if minLine == 0 {
                lineStartOffsets[0] = 0
            }
            
            for ch in utf16 {
                if currentLine > maxLine { break }
                utf16Offset += 1
                if ch == 0x0A {
                    currentLine += 1
                    if currentLine >= minLine && currentLine <= maxLine {
                        lineStartOffsets[currentLine] = utf16Offset
                    }
                }
            }
            
            // Build line lengths by scanning each line
            for line in minLine...maxLine {
                guard let start = lineStartOffsets[line] else { continue }
                var endOffset = start
                let startIdx = utf16.index(utf16.startIndex, offsetBy: start)
                var idx = startIdx
                while idx < utf16.endIndex && utf16[idx] != 0x0A {
                    endOffset += 1
                    idx = utf16.index(after: idx)
                }
                lineLengths[line] = endOffset - start
            }
        }
        
        textStorage.beginEditing()
        
        for token in visibleSemanticTokens {
            guard let lineStart = lineStartOffsets[token.line],
                  let lineLen = lineLengths[token.line] else { continue }
            
            let tokenEnd = token.startColumn + token.length
            guard token.startColumn < lineLen else { continue }
            let clampedLength = min(token.length, lineLen - token.startColumn)
            
            let nsRange = NSRange(
                location: lineStart + token.startColumn,
                length: clampedLength
            )
            
            guard nsRange.location + nsRange.length <= totalUTF16 else { continue }
            
            // Apply color
            textStorage.addAttribute(.foregroundColor, value: token.tokenType.defaultColor, range: nsRange)
            
            // Apply modifiers
            if token.modifiers.contains(.deprecated) {
                textStorage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
            }
            if token.modifiers.contains(.declaration) || token.modifiers.contains(.definition) {
                let boldFont = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .semibold)
                textStorage.addAttribute(.font, value: boldFont, range: nsRange)
            }
        }
        
        textStorage.endEditing()
    }
    
    // MARK: - Memory Pressure
    
    func handleMemoryPressure() {
        Self.logger.warning("Memory pressure: clearing viewport highlight caches")
        
        // Cancel any in-flight processing
        processingTask?.cancel()
        ingestTask?.cancel()
        
        let cache = tokenCache
        let viewport = currentViewport
        
        Task.detached(priority: .userInitiated) {
            await cache.handleMemoryPressure(viewport: viewport)
        }
        
        highlightQueue.removeAll()
        highlightTimings.removeAll()
    }
    
    // MARK: - Performance
    
    var averageHighlightTimeMs: Double {
        guard !highlightTimings.isEmpty else { return 0 }
        return highlightTimings.reduce(0, +) / Double(highlightTimings.count)
    }
    
    private func recordHighlightTiming(_ ms: Double) {
        highlightTimings.append(ms)
        if highlightTimings.count > maxTimingSamples {
            highlightTimings.removeFirst()
        }
    }
    
    // MARK: - Private Helpers
    
    /// Refresh visible tokens from the cache for the given viewport.
    /// Runs the cache read off MainActor, then publishes results back.
    private func refreshVisibleTokens(viewport: ViewportRegion, fileId: String) {
        let cache = tokenCache
        Task.detached(priority: .userInitiated) { [weak self] in
            let tokens = await cache.visibleTokens(for: viewport, fileId: fileId)
            await MainActor.run { [weak self] in
                self?.visibleSemanticTokens = tokens
            }
        }
    }
}
