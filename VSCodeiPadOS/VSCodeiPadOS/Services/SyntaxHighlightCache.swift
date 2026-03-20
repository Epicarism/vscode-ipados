//
//  SyntaxHighlightCache.swift
//  VSCodeiPadOS
//
//  LRU cache for syntax highlighting tokens with incremental invalidation,
//  memory pressure handling, and background pre-highlighting.
//

import Foundation
import os

// MARK: - Cache Entry

struct HighlightCacheEntry {
    let fileId: String
    let lineRange: Range<Int>
    let language: String
    let tokens: [HighlightToken]
    let createdAt: Date
    var lastAccessedAt: Date
    var accessCount: Int
    
    var approximateSizeBytes: Int {
        tokens.count * 32 + 64  // ~32 bytes per token + overhead
    }
}

// MARK: - Highlight Token

struct HighlightToken: Sendable {
    let range: NSRange         // Character range in the text
    let tokenType: String      // TreeSitter highlight name
    let line: Int              // Line number (0-based)
}

// MARK: - Syntax Highlight Cache

actor SyntaxHighlightCache {
    static let shared = SyntaxHighlightCache()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "SyntaxHighlightCache")
    
    // Cache storage
    private var cache: [String: HighlightCacheEntry] = [:]  // key -> entry
    private var accessOrder: [String] = []  // LRU order (most recent last)
    
    // Configuration
    private let maxCacheSizeBytes: Int = 50 * 1024 * 1024  // 50MB
    private let maxEntries: Int = 1000
    private let entryTTLSeconds: TimeInterval = 300  // 5 minutes
    
    // Stats
    private(set) var hitCount: Int = 0
    private(set) var missCount: Int = 0
    private(set) var evictionCount: Int = 0
    private(set) var currentSizeBytes: Int = 0
    
    // MARK: - Cache Key
    
    private func cacheKey(fileId: String, startLine: Int, endLine: Int, language: String) -> String {
        "\(fileId):\(startLine)-\(endLine):\(language)"
    }
    
    // MARK: - Get/Put
    
    /// Look up cached highlight tokens for a line range
    func get(fileId: String, startLine: Int, endLine: Int, language: String) -> [HighlightToken]? {
        let key = cacheKey(fileId: fileId, startLine: startLine, endLine: endLine, language: language)
        
        guard var entry = cache[key] else {
            missCount += 1
            return nil
        }
        
        // Check TTL
        if Date().timeIntervalSince(entry.createdAt) > entryTTLSeconds {
            cache.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            currentSizeBytes -= entry.approximateSizeBytes
            missCount += 1
            return nil
        }
        
        // Update access tracking
        entry.lastAccessedAt = Date()
        entry.accessCount += 1
        cache[key] = entry
        
        // Move to end of LRU list
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
        
        hitCount += 1
        return entry.tokens
    }
    
    /// Store highlight tokens in cache
    func put(fileId: String, startLine: Int, endLine: Int, language: String, tokens: [HighlightToken]) {
        let key = cacheKey(fileId: fileId, startLine: startLine, endLine: endLine, language: language)
        
        let entry = HighlightCacheEntry(
            fileId: fileId,
            lineRange: startLine..<endLine,
            language: language,
            tokens: tokens,
            createdAt: Date(),
            lastAccessedAt: Date(),
            accessCount: 1
        )
        
        // Remove old entry if exists
        if let old = cache[key] {
            currentSizeBytes -= old.approximateSizeBytes
            accessOrder.removeAll { $0 == key }
        }
        
        cache[key] = entry
        accessOrder.append(key)
        currentSizeBytes += entry.approximateSizeBytes
        
        // Evict if over limits
        evictIfNeeded()
    }
    
    // MARK: - Invalidation
    
    /// Invalidate cache entries for a specific file
    func invalidateFile(_ fileId: String) {
        let keysToRemove = cache.keys.filter { $0.hasPrefix(fileId + ":") }
        for key in keysToRemove {
            if let entry = cache.removeValue(forKey: key) {
                currentSizeBytes -= entry.approximateSizeBytes
            }
            accessOrder.removeAll { $0 == key }
        }
    }
    
    /// Invalidate cache entries that overlap with changed lines
    func invalidateLines(fileId: String, changedRange: Range<Int>, contextLines: Int = 5) {
        let invalidStart = max(0, changedRange.lowerBound - contextLines)
        let invalidEnd = changedRange.upperBound + contextLines
        
        let keysToRemove = cache.keys.filter { key in
            guard key.hasPrefix(fileId + ":") else { return false }
            guard let entry = cache[key] else { return false }
            // Remove if the entry's line range overlaps with the invalidation range
            return entry.lineRange.overlaps(invalidStart..<invalidEnd)
        }
        
        for key in keysToRemove {
            if let entry = cache.removeValue(forKey: key) {
                currentSizeBytes -= entry.approximateSizeBytes
            }
            accessOrder.removeAll { $0 == key }
        }
    }
    
    /// Clear entire cache
    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
        currentSizeBytes = 0
        Self.logger.info("Cache cleared")
    }
    
    // MARK: - Memory Pressure
    
    /// Evict entries to reduce memory usage (called on memory warning)
    func handleMemoryPressure() {
        let targetSize = maxCacheSizeBytes / 4  // Reduce to 25%
        evictUntilSize(targetSize)
        Self.logger.info("Memory pressure: evicted to \(self.currentSizeBytes / 1024)KB")
    }
    
    // MARK: - Stats
    
    var hitRate: Double {
        let total = hitCount + missCount
        return total > 0 ? Double(hitCount) / Double(total) : 0
    }
    
    var entryCount: Int { cache.count }
    
    func resetStats() {
        hitCount = 0
        missCount = 0
        evictionCount = 0
    }
    
    // MARK: - Eviction
    
    private func evictIfNeeded() {
        // Evict if over max entries
        while cache.count > maxEntries, let key = accessOrder.first {
            evictEntry(key: key)
        }
        
        // Evict if over max size
        evictUntilSize(maxCacheSizeBytes)
    }
    
    private func evictUntilSize(_ targetSize: Int) {
        while currentSizeBytes > targetSize, let key = accessOrder.first {
            evictEntry(key: key)
        }
    }
    
    private func evictEntry(key: String) {
        if let entry = cache.removeValue(forKey: key) {
            currentSizeBytes -= entry.approximateSizeBytes
            evictionCount += 1
        }
        accessOrder.removeAll { $0 == key }
    }
}
