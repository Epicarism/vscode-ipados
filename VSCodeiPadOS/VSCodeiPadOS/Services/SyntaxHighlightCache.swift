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

// MARK: - Persistence Helpers (Codable versions for disk storage)

/// Codable representation of NSRange for JSON serialization.
struct CodableNSRange: Codable {
    let location: Int
    let length: Int
    init(_ range: NSRange) { self.location = range.location; self.length = range.length }
    var nsRange: NSRange { NSRange(location: location, length: length) }
}

/// Codable representation of HighlightToken for disk persistence.
struct PersistedToken: Codable {
    let range: CodableNSRange
    let tokenType: String
    let line: Int
    init(from token: HighlightToken) {
        self.range = CodableNSRange(token.range)
        self.tokenType = token.tokenType
        self.line = token.line
    }
    var highlightToken: HighlightToken {
        HighlightToken(range: range.nsRange, tokenType: tokenType, line: line)
    }
}

/// Codable representation of a cache entry for disk persistence.
struct PersistedEntry: Codable {
    let fileId: String
    let lineStart: Int
    let lineEnd: Int
    let language: String
    let tokens: [PersistedToken]
    let createdAt: Double  // Unix timestamp

    init(from entry: HighlightCacheEntry) {
        self.fileId = entry.fileId
        self.lineStart = entry.lineRange.lowerBound
        self.lineEnd = entry.lineRange.upperBound
        self.language = entry.language
        self.tokens = entry.tokens.map { PersistedToken(from: $0) }
        self.createdAt = entry.createdAt.timeIntervalSince1970
    }

    var cacheEntry: HighlightCacheEntry {
        HighlightCacheEntry(
            fileId: fileId,
            lineRange: lineStart..<lineEnd,
            language: language,
            tokens: tokens.map { $0.highlightToken },
            createdAt: Date(timeIntervalSince1970: createdAt),
            lastAccessedAt: Date(),
            accessCount: 1
        )
    }
}

/// Tracks file modification dates for cache invalidation on reload.
struct FileModMetadata: Codable {
    let path: String
    let modDate: Date
    let fileSize: Int64
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
    
    // MARK: - Convenience: cache-aside highlighting

    /// Cache-aside wrapper: returns cached tokens if available, otherwise calls `compute`,
    /// stores the result, and returns it.  Callers (e.g. VSCodeSyntaxHighlighter) use this
    /// so they never need to call get/put separately.
    func cachedHighlight(
        fileId: String,
        startLine: Int,
        endLine: Int,
        language: String,
        compute: () -> [HighlightToken]
    ) -> [HighlightToken] {
        if let cached = get(fileId: fileId, startLine: startLine, endLine: endLine, language: language) {
            return cached
        }
        let tokens = compute()
        put(fileId: fileId, startLine: startLine, endLine: endLine, language: language, tokens: tokens)
        return tokens
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

    // MARK: - Disk Persistence

    /// Directory where cached highlight data is stored on disk.
    private var persistenceDirectory: URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent("com.codepad.highlightCache", isDirectory: true)
    }

    /// Path to the file containing persisted cache entries.
    private var entriesFileURL: URL {
        persistenceDirectory.appendingPathComponent("entries.json")
    }

    /// Path to the file containing metadata (mod dates) for cache validation.
    private var metadataFileURL: URL {
        persistenceDirectory.appendingPathComponent("fileMetadata.json")
    }

    /// Ensure the persistence directory exists.
    private func ensurePersistenceDirectory() {
        try? FileManager.default.createDirectory(at: persistenceDirectory, withIntermediateDirectories: true)
    }

    /// Save all current cache entries and file metadata to disk.
    /// Called when the app backgrounds to persist highlights for fast reload.
    func saveToDisk() async {
        guard !cache.isEmpty else {
            Self.logger.debug("Cache empty, skipping disk save")
            return
        }

        ensurePersistenceDirectory()

        // Serialize all entries
        let entries = cache.values.map { PersistedEntry(from: $0) }
        do {
            let data = try JSONEncoder().encode(entries)
            // Limit disk usage to 20MB max
            guard data.count < 20 * 1024 * 1024 else {
                Self.logger.warning("Cache data too large for disk (\(data.count / 1024)KB), skipping")
                return
            }
            try data.write(to: entriesFileURL, options: .atomic)
            Self.logger.info("Saved \(entries.count) highlight cache entries to disk (\(data.count / 1024)KB)")
        } catch {
            Self.logger.error("Failed to save highlight cache to disk: \(error.localizedDescription)")
        }

        // Save file metadata for staleness checks
        saveMetadataToDisk()
    }

    /// Load cached entries from disk. Called on app launch.
    /// Returns the number of entries loaded (after filtering stale ones).
    @discardableResult
    func loadFromDisk() async -> Int {
        ensurePersistenceDirectory()

        // Load metadata first for staleness validation
        let metadata = loadMetadataFromDisk()
        let metadataMap = Dictionary(uniqueKeysWithValues: metadata.map { ($0.path, $0) })

        guard FileManager.default.fileExists(atPath: entriesFileURL.path) else {
            Self.logger.debug("No persisted cache found on disk")
            return 0
        }

        do {
            let data = try Data(contentsOf: entriesFileURL)
            let entries = try JSONDecoder().decode([PersistedEntry].self, from: data)

            var loadedCount = 0
            var skippedStale = 0

            for persisted in entries {
                // Validate against current file modification date
                if let meta = metadataMap[persisted.fileId] {
                    let fm = FileManager.default
                    if fm.fileExists(atPath: persisted.fileId) {
                        if let attrs = try? fm.attributesOfItem(atPath: persisted.fileId),
                           let modDate = attrs[.modificationDate] as? Date {
                            if modDate > meta.modDate {
                                // File was modified since cache was saved — skip this entry
                                skippedStale += 1
                                continue
                            }
                        }
                    }
                }

                // Check entry age — skip entries older than 1 hour
                let entryDate = Date(timeIntervalSince1970: persisted.createdAt)
                if Date().timeIntervalSince(entryDate) > 3600 {
                    skippedStale += 1
                    continue
                }

                // Restore to in-memory cache
                let entry = persisted.cacheEntry
                let key = cacheKey(fileId: entry.fileId, startLine: entry.lineRange.lowerBound,
                                  endLine: entry.lineRange.upperBound, language: entry.language)
                cache[key] = entry
                let node = LRUNode(key: key)
                nodeMap[key] = node
                appendToTail(node)
                currentSizeBytes += entry.approximateSizeBytes
                loadedCount += 1
            }

            Self.logger.info("Loaded \(loadedCount) highlight entries from disk (skipped \(skippedStale) stale)")
            evictIfNeeded()
            return loadedCount
        } catch {
            Self.logger.error("Failed to load highlight cache from disk: \(error.localizedDescription)")
            // Corrupted file — remove it
            try? FileManager.default.removeItem(at: entriesFileURL)
            return 0
        }
    }

    /// Record a file's modification date for staleness tracking.
    func recordFileMetadata(path: String) {
        var metadata = loadMetadataFromDisk()
        if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
           let modDate = attrs[.modificationDate] as? Date,
           let size = attrs[.size] as? Int64 {
            metadata = metadata.filter { $0.path != path }
            metadata.append(FileModMetadata(path: path, modDate: modDate, fileSize: size))
            saveMetadataToDisk(metadata)
        }
    }

    // MARK: - Metadata Helpers

    private func loadMetadataFromDisk() -> [FileModMetadata] {
        guard FileManager.default.fileExists(atPath: metadataFileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: metadataFileURL)
            return try JSONDecoder().decode([FileModMetadata].self, from: data)
        } catch {
            return []
        }
    }

    private func saveMetadataToDisk(_ metadata: [FileModMetadata]? = nil) {
        let meta = metadata ?? buildCurrentMetadata()
        ensurePersistenceDirectory()
        do {
            let data = try JSONEncoder().encode(meta)
            try data.write(to: metadataFileURL, options: .atomic)
        } catch {
            Self.logger.error("Failed to save file metadata: \(error.localizedDescription)")
        }
    }

    /// Build metadata for all files currently in the cache.
    private func buildCurrentMetadata() -> [FileModMetadata] {
        let uniquePaths = Set(cache.values.map { $0.fileId })
        var result: [FileModMetadata] = []
        let fm = FileManager.default
        for p in uniquePaths {
            if let attrs = try? fm.attributesOfItem(atPath: p),
               let modDate = attrs[.modificationDate] as? Date,
               let size = attrs[.size] as? Int64 {
                result.append(FileModMetadata(path: p, modDate: modDate, fileSize: size))
            }
        }
        return result
    }
}
