import Foundation
import CommonCrypto

/// Cache entry containing a suggestion with its expiration timestamp
private final class CacheEntry {
    let suggestion: String
    let expirationDate: Date
    let contextHash: String
    
    init(suggestion: String, contextHash: String, ttl: TimeInterval) {
        self.suggestion = suggestion
        self.contextHash = contextHash
        self.expirationDate = Date().addingTimeInterval(ttl)
    }
    
    var isExpired: Bool {
        return Date() > expirationDate
    }
}

/// Thread-safe LRU cache for inline code suggestions with TTL expiration
/// Maximum 100 entries, 5 minute expiration
final class SuggestionCache {
    // MARK: - Constants
    
    static let maxEntries = 100
    static let expirationInterval: TimeInterval = 300 // 5 minutes
    
    // MARK: - Properties
    
    private var cache: [String: CacheEntry] = [:]
    /// Ordered list to track LRU access order (least recently used at the beginning)
    private var lruOrder: [String] = []
    
    /// Thread-safe queue for cache operations using concurrent queue with barriers
    private let cacheQueue = DispatchQueue(label: "com.vscodeipados.suggestioncache", attributes: .concurrent)
    
    // MARK: - Singleton
    
    static let shared = SuggestionCache()
    
    private init() {}
    
    // MARK: - Key Generation
    
    /// Generates a SHA256 hash from the code context string
    /// - Parameter context: The code context to hash
    /// - Returns: A hex-encoded SHA256 hash string
    private func hashContext(_ context: String) -> String {
        let data = Data(context.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { bytes in
            CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    // MARK: - Public API
    
    /// Retrieves a cached suggestion for the given code context if it exists and hasn't expired.
    /// Updates LRU order on successful retrieval.
    /// - Parameter context: The code context string to look up
    /// - Returns: The cached suggestion string, or nil if not found or expired
    func get(context: String) -> String? {
        let key = hashContext(context)
        
        return cacheQueue.sync {
            guard let entry = cache[key] else {
                return nil
            }
            
            // Check if entry has expired
            if entry.isExpired {
                // Remove expired entry
                cache.removeValue(forKey: key)
                removeFromLRU(key)
                return nil
            }
            
            // Update LRU order - move to end (most recently used)
            updateLRUOrder(key)
            
            return entry.suggestion
        }
    }
    
    /// Stores a suggestion for the given code context in the cache.
    /// Evicts oldest entry if cache is at max capacity.
    /// - Parameters:
    ///   - context: The code context string (used as cache key via SHA256 hash)
    ///   - suggestion: The AI suggestion to cache
    func set(context: String, suggestion: String) {
        let key = hashContext(context)
        
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // Create new entry with TTL
            let entry = CacheEntry(
                suggestion: suggestion,
                contextHash: key,
                ttl: Self.expirationInterval
            )
            
            // Check if this is an update to existing entry
            if self.cache[key] != nil {
                // Update existing entry
                self.cache[key] = entry
                self.updateLRUOrder(key)
            } else {
                // Check if we need to evict oldest entry
                if self.cache.count >= Self.maxEntries {
                    self.evictLRUEntry()
                }
                
                // Add new entry
                self.cache[key] = entry
                self.lruOrder.append(key)
            }
        }
    }
    
    /// Clears all entries from the cache.
    func clear() {
        cacheQueue.async(flags: .barrier) { [weak self] in
            self?.cache.removeAll()
            self?.lruOrder.removeAll()
        }
    }
    
    // MARK: - Private Helpers
    
    /// Removes a key from the LRU order tracking
    private func removeFromLRU(_ key: String) {
        lruOrder.removeAll { $0 == key }
    }
    
    /// Updates LRU order by moving the accessed key to the end (most recently used)
    private func updateLRUOrder(_ key: String) {
        removeFromLRU(key)
        lruOrder.append(key)
    }
    
    /// Evicts the least recently used entry from the cache
    private func evictLRUEntry() {
        guard !lruOrder.isEmpty else { return }
        
        let oldestKey = lruOrder.removeFirst()
        cache.removeValue(forKey: oldestKey)
    }
    
    // MARK: - Debug/Testing
    
    /// Returns the current number of cached entries (for testing/debugging purposes)
    var count: Int {
        return cacheQueue.sync {
            // Clean up expired entries before counting
            let now = Date()
            let expiredKeys = cache.filter { $0.value.expirationDate < now }.map { $0.key }
            for key in expiredKeys {
                cache.removeValue(forKey: key)
                removeFromLRU(key)
            }
            return cache.count
        }
    }
    
    /// Removes all expired entries from the cache
    func cleanupExpired() {
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let now = Date()
            let expiredKeys = self.cache.filter { $0.value.expirationDate < now }.map { $0.key }
            
            for key in expiredKeys {
                self.cache.removeValue(forKey: key)
                self.removeFromLRU(key)
            }
        }
    }
}
