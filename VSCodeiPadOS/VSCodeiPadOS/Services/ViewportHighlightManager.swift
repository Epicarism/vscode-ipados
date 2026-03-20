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

enum SemanticTokenType: String, CaseIterable, Codable {
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

enum SemanticTokenModifier: String, CaseIterable, Codable {
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

struct SemanticToken: Equatable {
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
    private var lastScrollOffset: CGFloat = 0
    private var lastViewportUpdate: Date = .distantPast
    
    // Token storage per file
    private var tokensByFile: [String: [Int: [SemanticToken]]] = [:]  // fileId -> (line -> tokens)
    private var dirtyLines: [String: Set<Int>] = [:]  // fileId -> dirty line numbers
    
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
        processingTask?.cancel()
        processingTask = Task { [weak self] in
            guard let self = self else { return }
            
            var totalLinesProcessed = 0
            
            while !Task.isCancelled, let request = self.highlightQueue.first {
                self.highlightQueue.removeFirst()
                self.isHighlightingActive = true
                
                let startTime = CACurrentMediaTime()
                let requestLineCount = request.lineRange.count
                
                // Process highlighting for this range
                await self.processHighlightRequest(request)
                
                let elapsed = (CACurrentMediaTime() - startTime) * 1000
                self.recordHighlightTiming(elapsed)
                totalLinesProcessed += requestLineCount
                
                // Yield to UI if we've been processing too long OR exceeded per-frame line limit
                if elapsed > 8 || totalLinesProcessed >= self.maxHighlightLinesPerFrame {
                    try? await Task.sleep(nanoseconds: 1_000_000)  // 1ms yield
                    totalLinesProcessed = 0  // Reset for next batch
                }
            }
            
            self.isHighlightingActive = false
        }
    }
    
    private func processHighlightRequest(_ request: HighlightRequest) async {
        let range = request.lineRange
        
        // Collect visible tokens from storage
        let fileTokens = tokensByFile[request.fileId] ?? [:]
        var visibleTokens: [SemanticToken] = []
        
        for line in range {
            if let lineTokens = fileTokens[line] {
                visibleTokens.append(contentsOf: lineTokens)
            }
        }
        
        // Update published tokens if these are visible-priority
        if request.priority == .visible {
            visibleSemanticTokens = visibleTokens
            highlightedLineRange = range
        }
    }
    
    // MARK: - Token Management

    /// Convert HighlightTokens (from SyntaxHighlightCache) into SemanticTokens and
    /// populate tokensByFile.  Call this after a highlighting pass completes so that
    /// updateScrollPosition / processHighlightRequest have data to work with.
    func ingestHighlightTokens(_ tokens: [HighlightToken], fileId: String) {
        guard !tokens.isEmpty else { return }
        let semanticTokens: [SemanticToken] = tokens.map { tok in
            SemanticToken(
                line: tok.line,
                startColumn: tok.range.location,
                length: tok.range.length,
                tokenType: Self.semanticType(for: tok.tokenType),
                modifiers: []
            )
        }
        setTokens(semanticTokens, fileId: fileId)
    }

    /// Map a TreeSitter highlight name to a SemanticTokenType.
    private static func semanticType(for treeSitterName: String) -> SemanticTokenType {
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

    /// Set semantic tokens for a file (from LSP or TreeSitter)
    /// Uses incremental merge: only replaces lines present in the new token set,
    /// preserving tokens for lines not included in this update.
    func setTokens(_ tokens: [SemanticToken], fileId: String, fullReplacement: Bool = false) {
        var lineMap: [Int: [SemanticToken]] = [:]
        for token in tokens {
            lineMap[token.line, default: []].append(token)
        }
        
        if fullReplacement || tokensByFile[fileId] == nil {
            // Full replacement: first load or explicit full refresh
            tokensByFile[fileId] = lineMap
        } else {
            // Incremental merge: only update lines that have new tokens
            for (line, lineTokens) in lineMap {
                tokensByFile[fileId]?[line] = lineTokens
            }
        }
        
        // Refresh visible tokens if this is the current file
        if let viewport = currentViewport {
            refreshVisibleTokens(viewport: viewport, fileId: fileId)
        }
    }
    
    /// Update tokens for specific lines (incremental update)
    func updateTokens(_ tokens: [SemanticToken], forLines lines: ClosedRange<Int>, fileId: String) {
        for line in lines {
            tokensByFile[fileId]?[line] = tokens.filter { $0.line == line }
        }
        dirtyLines[fileId, default: []].formUnion(Set(lines))
        
        // Refresh if dirty lines are visible
        if let viewport = currentViewport {
            let fileDirty = dirtyLines[fileId] ?? []
            let dirtyVisible = fileDirty.filter { viewport.contains(line: $0) }
            if !dirtyVisible.isEmpty {
                refreshVisibleTokens(viewport: viewport, fileId: fileId)
                dirtyLines[fileId]?.subtract(dirtyVisible)
            }
        }
    }
    
    /// Invalidate tokens for a range of lines
    func invalidateLines(_ lines: ClosedRange<Int>, fileId: String) {
        for line in lines {
            tokensByFile[fileId]?.removeValue(forKey: line)
        }
        dirtyLines[fileId, default: []].formUnion(Set(lines))
    }
    
    /// Clear all tokens for a file
    func clearTokens(fileId: String) {
        tokensByFile.removeValue(forKey: fileId)
        visibleSemanticTokens.removeAll()
    }
    
    // MARK: - Overlay Application
    
    /// Apply semantic token overlays to a text view for the current viewport
    func applySemanticOverlays(
        to textView: UITextView,
        in viewport: ViewportRegion,
        baseFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    ) {
        guard enableSemanticTokens, !visibleSemanticTokens.isEmpty else { return }
        
        let textStorage = textView.textStorage
        let text = textStorage.string
        
        // Find the range of lines we actually need offsets for
        var minLine = Int.max
        var maxLine = 0
        for token in visibleSemanticTokens {
            minLine = min(minLine, token.line)
            maxLine = max(maxLine, token.line)
        }
        guard minLine <= maxLine else { return }
        
        // Walk text counting newlines only up to maxLine+1 — O(viewport) not O(file)
        // Use UTF-16 view since NSAttributedString/NSRange use UTF-16 offsets
        let utf16 = text.utf16
        var lineStartOffsets: [Int: Int] = [:] // line number -> UTF-16 offset
        lineStartOffsets.reserveCapacity(maxLine - minLine + 2)
        var currentLine = 0
        var utf16Offset = 0
        
        if minLine == 0 {
            lineStartOffsets[0] = 0
        }
        
        for ch in utf16 {
            if currentLine > maxLine { break } // Stop early — don't scan rest of file
            utf16Offset += 1
            if ch == 0x0A { // newline
                currentLine += 1
                if currentLine >= minLine && currentLine <= maxLine {
                    lineStartOffsets[currentLine] = utf16Offset
                }
            }
        }
        
        // Build a quick line-length lookup for bounds checking
        // We need the length of each line in the token range
        var lineLengths: [Int: Int] = [:]
        lineLengths.reserveCapacity(maxLine - minLine + 1)
        for line in minLine...maxLine {
            guard let start = lineStartOffsets[line] else { continue }
            // Find end of this line
            var endOffset = start
            let startIdx = utf16.index(utf16.startIndex, offsetBy: start)
            var idx = startIdx
            while idx < utf16.endIndex && utf16[idx] != 0x0A {
                endOffset += 1
                idx = utf16.index(after: idx)
            }
            lineLengths[line] = endOffset - start
        }
        
        let totalUTF16 = text.utf16.count
        
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
        
        // Keep only current file tokens
        if let viewport = currentViewport {
            // Remove far buffer tokens
            for (fileId, lineTokens) in tokensByFile {
                let kept = lineTokens.filter { viewport.bufferedRange.contains($0.key) }
                tokensByFile[fileId] = kept
            }
        } else {
            tokensByFile.removeAll()
        }
        
        highlightQueue.removeAll()
        highlightTimings.removeAll()
        dirtyLines.removeAll()
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
    
    private func refreshVisibleTokens(viewport: ViewportRegion, fileId: String) {
        guard let fileTokens = tokensByFile[fileId] else { return }
        
        var tokens: [SemanticToken] = []
        for line in viewport.visibleRange {
            if let lineTokens = fileTokens[line] {
                tokens.append(contentsOf: lineTokens)
            }
        }
        visibleSemanticTokens = tokens
    }
}
