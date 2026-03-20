//
//  SyntaxHighlightCache.swift
//  VSCodeiPadOS
//
//  LRU cache for syntax highlighting tokens with incremental invalidation,
//  memory pressure handling, and background pre-highlighting.
//  Performance: O(1) get/put/evict via doubly-linked list + hash map.
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

// MARK: - LRU Doubly-Linked List Node

private final class LRUNode {
    let key: String
    var prev: LRUNode?
    var next: LRUNode?
    
    init(key: String) {
        self.key = key
    }
}

// MARK: - Syntax Highlight Cache

actor SyntaxHighlightCache {
    static let shared = SyntaxHighlightCache()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "SyntaxHighlightCache")
    
    // Cache storage
    private var cache: [String: HighlightCacheEntry] = [:]  // key -> entry
    
    // O(1) LRU tracking via doubly-linked list + hash map
    private var nodeMap: [String: LRUNode] = [:]  // key -> node for O(1) lookup
    private var lruHead: LRUNode?  // Least recently used (evict from here)
    private var lruTail: LRUNode?  // Most recently used (insert here)
    
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
    
    // MARK: - LRU List Operations (all O(1))
    
    /// Remove a node from the doubly-linked list
    private func removeNode(_ node: LRUNode) {
        let prev = node.prev
        let next = node.next
        prev?.next = next
        next?.prev = prev
        if lruHead === node { lruHead = next }
        if lruTail === node { lruTail = prev }
        node.prev = nil
        node.next = nil
    }
    
    /// Append a node to the tail (most recently used)
    private func appendToTail(_ node: LRUNode) {
        node.prev = lruTail
        node.next = nil
        lruTail?.next = node
        lruTail = node
        if lruHead == nil { lruHead = node }
    }
    
    /// Move an existing node to tail (mark as most recently used)
    private func moveToTail(_ node: LRUNode) {
        guard lruTail !== node else { return }  // Already at tail
        removeNode(node)
        appendToTail(node)
    }
    
    /// Remove and return the head node (least recently used)
    private func removeHead() -> LRUNode? {
        guard let head = lruHead else { return nil }
        removeNode(head)
        return head
    }
    
    // MARK: - Get/Put
    
    /// Look up cached highlight tokens for a line range - O(1)
    func get(fileId: String, startLine: Int, endLine: Int, language: String) -> [HighlightToken]? {
        let key = cacheKey(fileId: fileId, startLine: startLine, endLine: endLine, language: language)
        
        guard var entry = cache[key] else {
            missCount += 1
            return nil
        }
        
        // Check TTL
        if Date().timeIntervalSince(entry.createdAt) > entryTTLSeconds {
            cache.removeValue(forKey: key)
            if let node = nodeMap.removeValue(forKey: key) {
                removeNode(node)
            }
            currentSizeBytes = max(0, currentSizeBytes - entry.approximateSizeBytes)
            missCount += 1
            return nil
        }
        
        // Update access tracking
        entry.lastAccessedAt = Date()
        entry.accessCount += 1
        cache[key] = entry
        
        // Move to end of LRU list - O(1)
        if let node = nodeMap[key] {
            moveToTail(node)
        }
        
        hitCount += 1
        return entry.tokens
    }
    
    /// Store highlight tokens in cache - O(1)
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
        
        // Remove old entry if exists - O(1)
        if let old = cache[key] {
            currentSizeBytes = max(0, currentSizeBytes - old.approximateSizeBytes)
            if let node = nodeMap[key] {
                removeNode(node)
            }
        }
        
        cache[key] = entry
        let node = LRUNode(key: key)
        nodeMap[key] = node
        appendToTail(node)
        currentSizeBytes += entry.approximateSizeBytes
        
        // Evict if over limits
        evictIfNeeded()
    }
    
    // MARK: - Invalidation
    
    /// Invalidate cache entries for a specific file - O(k) where k = entries for file
    func invalidateFile(_ fileId: String) {
        let prefix = fileId + ":"
        let keysToRemove = cache.keys.filter { $0.hasPrefix(prefix) }
        for key in keysToRemove {
            if let entry = cache.removeValue(forKey: key) {
                currentSizeBytes = max(0, currentSizeBytes - entry.approximateSizeBytes)
            }
            if let node = nodeMap.removeValue(forKey: key) {
                removeNode(node)
            }
        }
    }
    
    /// Invalidate cache entries that overlap with changed lines
    func invalidateLines(fileId: String, changedRange: Range<Int>, contextLines: Int = 5) {
        let invalidStart = max(0, changedRange.lowerBound - contextLines)
        let invalidEnd = changedRange.upperBound + contextLines
        let prefix = fileId + ":"
        
        let keysToRemove = cache.keys.filter { key in
            guard key.hasPrefix(prefix) else { return false }
            guard let entry = cache[key] else { return false }
            return entry.lineRange.overlaps(invalidStart..<invalidEnd)
        }
        
        for key in keysToRemove {
            if let entry = cache.removeValue(forKey: key) {
                currentSizeBytes = max(0, currentSizeBytes - entry.approximateSizeBytes)
            }
            if let node = nodeMap.removeValue(forKey: key) {
                removeNode(node)
            }
        }
    }
    
    /// Clear entire cache
    func clear() {
        cache.removeAll()
        nodeMap.removeAll()
        lruHead = nil
        lruTail = nil
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
        while cache.count > maxEntries {
            guard let evicted = evictLRUEntry() else { break }
            _ = evicted
        }
        
        // Evict if over max size
        evictUntilSize(maxCacheSizeBytes)
    }
    
    private func evictUntilSize(_ targetSize: Int) {
        while currentSizeBytes > targetSize {
            guard let _ = evictLRUEntry() else { break }
        }
    }
    
    /// Evict the least recently used entry - O(1)
    @discardableResult
    private func evictLRUEntry() -> String? {
        guard let head = removeHead() else { return nil }
        let key = head.key
        if let entry = cache.removeValue(forKey: key) {
            currentSizeBytes = max(0, currentSizeBytes - entry.approximateSizeBytes)
            evictionCount += 1
        }
        nodeMap.removeValue(forKey: key)
        return key
    }
}
