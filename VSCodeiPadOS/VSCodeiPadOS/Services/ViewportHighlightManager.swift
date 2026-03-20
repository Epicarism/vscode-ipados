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
        
        let viewport = ViewportRegion(
            firstVisibleLine: firstLine,
            lastVisibleLine: lastLine,
            bufferLinesBefore: bufferLines,
            bufferLinesAfter: bufferLines,
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
        
        if isFastScrolling {
            // During fast scroll: only highlight visible lines, skip buffer
            enqueueHighlightRequest(
                lineRange: viewport.visibleRange,
                priority: .visible,
                fileId: "current",
                language: "unknown"
            )
        } else {
            // Normal scroll: highlight visible + buffer zones
            enqueueHighlightRequest(
                lineRange: viewport.visibleRange,
                priority: .visible,
                fileId: "current",
                language: "unknown"
            )
            
            // Near buffer (±bufferLines/2)
            let nearStart = max(0, viewport.firstVisibleLine - bufferLines / 2)
            let nearEnd = min(viewport.totalLines - 1, viewport.lastVisibleLine + bufferLines / 2)
            if nearStart < viewport.firstVisibleLine || nearEnd > viewport.lastVisibleLine {
                enqueueHighlightRequest(
                    lineRange: nearStart...nearEnd,
                    priority: .nearBuffer,
                    fileId: "current",
                    language: "unknown"
                )
            }
            
            // Far buffer (full buffer range)
            let farRange = viewport.bufferedRange
            if farRange.lowerBound < nearStart || farRange.upperBound > nearEnd {
                enqueueHighlightRequest(
                    lineRange: farRange,
                    priority: .farBuffer,
                    fileId: "current",
                    language: "unknown"
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
            
            while !Task.isCancelled, let request = self.highlightQueue.first {
                self.highlightQueue.removeFirst()
                self.isHighlightingActive = true
                
                let startTime = CACurrentMediaTime()
                
                // Process highlighting for this range
                await self.processHighlightRequest(request)
                
                let elapsed = (CACurrentMediaTime() - startTime) * 1000
                self.recordHighlightTiming(elapsed)
                
                // Yield to UI if we've been processing too long
                if elapsed > 8 {  // Half a frame at 60fps
                    try? await Task.sleep(nanoseconds: 1_000_000)  // 1ms yield
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
    
    /// Set semantic tokens for a file (from LSP or TreeSitter)
    func setTokens(_ tokens: [SemanticToken], fileId: String) {
        var lineMap: [Int: [SemanticToken]] = [:]
        for token in tokens {
            lineMap[token.line, default: []].append(token)
        }
        tokensByFile[fileId] = lineMap
        
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
        let lines = text.components(separatedBy: "\n")
        
        // Pre-compute line start offsets O(n) once, then O(1) per token
        var lineStartOffsets = [0]
        lineStartOffsets.reserveCapacity(lines.count)
        var runningOffset = 0
        for line in lines {
            runningOffset += line.count + 1  // +1 for newline
            lineStartOffsets.append(runningOffset)
        }
        
        textStorage.beginEditing()
        
        for token in visibleSemanticTokens {
            guard token.line < lines.count else { continue }
            
            // O(1) character offset lookup
            let charOffset = lineStartOffsets[token.line]
            
            let nsRange = NSRange(
                location: charOffset + token.startColumn,
                length: min(token.length, lines[token.line].count - token.startColumn)
            )
            
            guard nsRange.location + nsRange.length <= text.count else { continue }
            
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
