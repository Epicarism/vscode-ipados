//
//  TunnelFileSystemBridge.swift
//  VSCodeiPadOS
//
//  Remote file system provider over the tunnel WebSocket.
//  Provides file CRUD, directory listing, watching, and LRU caching.
//

import Foundation
import Combine
import os

// MARK: - File System Types

enum RemoteFileType: String, Codable {
    case file
    case directory
    case symlink
    case unknown
}

struct RemoteFileStat: Codable, Equatable {
    let type: RemoteFileType
    let size: Int64
    let createdAt: Date
    let modifiedAt: Date
    let permissions: UInt16
    let isSymlink: Bool
    let isReadOnly: Bool
    
    init(
        type: RemoteFileType = .file,
        size: Int64 = 0,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        permissions: UInt16 = 0o644,
        isSymlink: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.type = type
        self.size = size
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.permissions = permissions
        self.isSymlink = isSymlink
        self.isReadOnly = isReadOnly
    }
}

struct RemoteDirectoryEntry: Codable, Identifiable, Equatable {
    var id: String { path }
    let name: String
    let path: String
    let type: RemoteFileType
    let size: Int64?
    let modifiedAt: Date?
    let isHidden: Bool
    
    init(
        name: String,
        path: String,
        type: RemoteFileType,
        size: Int64? = nil,
        modifiedAt: Date? = nil,
        isHidden: Bool = false
    ) {
        self.name = name
        self.path = path
        self.type = type
        self.size = size
        self.modifiedAt = modifiedAt
        self.isHidden = isHidden
    }
}

enum RemoteFileChangeType: String, Codable {
    case created
    case changed
    case deleted
}

struct RemoteFileChangeEvent: Codable {
    let type: RemoteFileChangeType
    let path: String
    let timestamp: Date
    let stat: RemoteFileStat?
}

// MARK: - File System Errors

enum RemoteFileError: Error, LocalizedError {
    case fileNotFound(String)
    case permissionDenied(String)
    case directoryNotEmpty(String)
    case alreadyExists(String)
    case notADirectory(String)
    case notAFile(String)
    case ioError(String)
    case networkError(String)
    case quotaExceeded
    case pathTooLong(String)
    case encodingError(String)
    case tunnelNotConnected
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let p): return "File not found: \(p)"
        case .permissionDenied(let p): return "Permission denied: \(p)"
        case .directoryNotEmpty(let p): return "Directory not empty: \(p)"
        case .alreadyExists(let p): return "Already exists: \(p)"
        case .notADirectory(let p): return "Not a directory: \(p)"
        case .notAFile(let p): return "Not a file: \(p)"
        case .ioError(let msg): return "I/O error: \(msg)"
        case .networkError(let msg): return "Network error: \(msg)"
        case .quotaExceeded: return "Disk quota exceeded"
        case .pathTooLong(let p): return "Path too long: \(p)"
        case .encodingError(let msg): return "Encoding error: \(msg)"
        case .tunnelNotConnected: return "Tunnel not connected"
        case .timeout: return "File operation timed out"
        }
    }
}

// MARK: - File System Provider Protocol

protocol RemoteFileProvider: AnyObject {
    func readFile(at path: String) async throws -> Data
    func readFileString(at path: String, encoding: String.Encoding) async throws -> String
    func writeFile(at path: String, content: Data, createParents: Bool) async throws
    func stat(path: String) async throws -> RemoteFileStat
    func readDirectory(path: String) async throws -> [RemoteDirectoryEntry]
    func createDirectory(path: String, recursive: Bool) async throws
    func delete(path: String, recursive: Bool) async throws
    func rename(from: String, to: String, overwrite: Bool) async throws
    func copy(from: String, to: String, overwrite: Bool) async throws
    func exists(path: String) async throws -> Bool
    func watch(path: String, recursive: Bool) -> AsyncStream<RemoteFileChangeEvent>
}

// MARK: - LRU File Cache

private actor FileCache {
    private struct CacheEntry {
        let data: Data
        let stat: RemoteFileStat
        let cachedAt: Date
        var lastAccessedAt: Date
        var accessCount: Int
        
        var sizeBytes: Int { data.count + 256 }  // data + overhead
    }
    
    private var cache: [String: CacheEntry] = [:]
    private var accessOrder: [String] = []  // LRU (most recent last)
    private var currentSizeBytes: Int = 0
    
    private let maxSizeBytes: Int = 100 * 1024 * 1024  // 100MB
    private let maxEntries: Int = 500
    private let entryTTL: TimeInterval = 120  // 2 minutes
    
    func get(_ path: String) -> (Data, RemoteFileStat)? {
        guard var entry = cache[path] else { return nil }
        
        // Check TTL
        if Date().timeIntervalSince(entry.cachedAt) > entryTTL {
            remove(path)
            return nil
        }
        
        // Update access tracking
        entry.lastAccessedAt = Date()
        entry.accessCount += 1
        cache[path] = entry
        
        // Move to end of access order
        accessOrder.removeAll { $0 == path }
        accessOrder.append(path)
        
        return (entry.data, entry.stat)
    }
    
    func put(_ path: String, data: Data, stat: RemoteFileStat) {
        // Don't cache very large files
        guard data.count < 10 * 1024 * 1024 else { return }  // Skip > 10MB
        
        // Evict if necessary
        while currentSizeBytes + data.count > maxSizeBytes || cache.count >= maxEntries {
            evictOldest()
        }
        
        let entry = CacheEntry(
            data: data,
            stat: stat,
            cachedAt: Date(),
            lastAccessedAt: Date(),
            accessCount: 1
        )
        
        // Remove old entry if exists
        if let old = cache[path] {
            currentSizeBytes -= old.sizeBytes
        }
        
        cache[path] = entry
        currentSizeBytes += entry.sizeBytes
        accessOrder.removeAll { $0 == path }
        accessOrder.append(path)
    }
    
    func invalidate(_ path: String) {
        remove(path)
    }
    
    func invalidateDirectory(_ dirPath: String) {
        let prefix = dirPath.hasSuffix("/") ? dirPath : dirPath + "/"
        let toRemove = cache.keys.filter { $0.hasPrefix(prefix) || $0 == dirPath }
        for key in toRemove {
            remove(key)
        }
    }
    
    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
        currentSizeBytes = 0
    }
    
    private func remove(_ path: String) {
        if let entry = cache.removeValue(forKey: path) {
            currentSizeBytes -= entry.sizeBytes
        }
        accessOrder.removeAll { $0 == path }
    }
    
    private func evictOldest() {
        guard let oldest = accessOrder.first else { return }
        remove(oldest)
    }
}

// MARK: - Metadata Cache

private actor MetadataCache {
    private var statCache: [String: (RemoteFileStat, Date)] = [:]  // path -> (stat, cachedAt)
    private var dirCache: [String: ([RemoteDirectoryEntry], Date)] = [:]
    private let ttl: TimeInterval = 30  // 30 seconds for metadata
    
    func getStat(_ path: String) -> RemoteFileStat? {
        guard let (stat, cachedAt) = statCache[path],
              Date().timeIntervalSince(cachedAt) < ttl else {
            statCache.removeValue(forKey: path)
            return nil
        }
        return stat
    }
    
    func putStat(_ path: String, stat: RemoteFileStat) {
        statCache[path] = (stat, Date())
    }
    
    func getDirectory(_ path: String) -> [RemoteDirectoryEntry]? {
        guard let (entries, cachedAt) = dirCache[path],
              Date().timeIntervalSince(cachedAt) < ttl else {
            dirCache.removeValue(forKey: path)
            return nil
        }
        return entries
    }
    
    func putDirectory(_ path: String, entries: [RemoteDirectoryEntry]) {
        dirCache[path] = (entries, Date())
    }
    
    func invalidate(_ path: String) {
        statCache.removeValue(forKey: path)
        let dir = (path as NSString).deletingLastPathComponent
        dirCache.removeValue(forKey: dir)
        dirCache.removeValue(forKey: path)
    }
    
    func clear() {
        statCache.removeAll()
        dirCache.removeAll()
    }
}

// MARK: - Tunnel File System Bridge

@MainActor
final class TunnelFileSystemBridge: ObservableObject, RemoteFileProvider {
    static let shared = TunnelFileSystemBridge()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "TunnelFS")
    
    // MARK: - Published State
    
    @Published var isConnected: Bool = false
    @Published var currentRoot: String = "/"
    @Published var pendingOperations: Int = 0
    @Published var lastError: String?
    
    // MARK: - Private State
    
    private let webSocket: TunnelWebSocketClient
    private let fileCache = FileCache()
    private let metadataCache = MetadataCache()
    private var watchers: [String: Task<Void, Never>] = [:]
    
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    // MARK: - Init
    
    private init(webSocket: TunnelWebSocketClient = .shared) {
        self.webSocket = webSocket
    }
    
    // MARK: - File Operations
    
    func readFile(at path: String) async throws -> Data {
        // Check cache first
        if let (data, _) = await fileCache.get(path) {
            Self.logger.debug("Cache hit: \(path)")
            return data
        }
        
        Self.logger.debug("Reading file: \(path)")
        pendingOperations += 1
        defer { pendingOperations -= 1 }
        
        let response = try await webSocket.fileSystemRequest(
            method: "readFile",
            path: path
        )
        
        try checkResponseError(response, path: path)
        
        guard let content = response.payload["content"]?.dataValue else {
            throw RemoteFileError.ioError("No content in response")
        }
        
        // Parse stat from response if available
        let stat = try parseStatFromPayload(response.payload) ?? RemoteFileStat(
            type: .file,
            size: Int64(content.count)
        )
        
        // Cache the result
        await fileCache.put(path, data: content, stat: stat)
        
        return content
    }
    
    func readFileString(at path: String, encoding: String.Encoding = .utf8) async throws -> String {
        let data = try await readFile(at: path)
        guard let string = String(data: data, encoding: encoding) else {
            throw RemoteFileError.encodingError("Cannot decode file as \(encoding)")
        }
        return string
    }
    
    func writeFile(at path: String, content: Data, createParents: Bool = true) async throws {
        Self.logger.debug("Writing file: \(path) (\(content.count) bytes)")
        pendingOperations += 1
        defer { pendingOperations -= 1 }
        
        let response = try await webSocket.fileSystemRequest(
            method: "writeFile",
            path: path,
            params: [
                "content": AnyCodable(content.base64EncodedString()),
                "createParents": AnyCodable(createParents)
            ]
        )
        
        try checkResponseError(response, path: path)
        
        // Invalidate caches
        await fileCache.invalidate(path)
        await metadataCache.invalidate(path)
    }
    
    func stat(path: String) async throws -> RemoteFileStat {
        // Check metadata cache
        if let cached = await metadataCache.getStat(path) {
            return cached
        }
        
        pendingOperations += 1
        defer { pendingOperations -= 1 }
        
        let response = try await webSocket.fileSystemRequest(
            method: "stat",
            path: path
        )
        
        try checkResponseError(response, path: path)
        
        guard let stat = try parseStatFromPayload(response.payload) else {
            throw RemoteFileError.ioError("Invalid stat response")
        }
        
        await metadataCache.putStat(path, stat: stat)
        return stat
    }
    
    func readDirectory(path: String) async throws -> [RemoteDirectoryEntry] {
        // Check metadata cache
        if let cached = await metadataCache.getDirectory(path) {
            return cached
        }
        
        Self.logger.debug("Reading directory: \(path)")
        pendingOperations += 1
        defer { pendingOperations -= 1 }
        
        let response = try await webSocket.fileSystemRequest(
            method: "readDirectory",
            path: path
        )
        
        try checkResponseError(response, path: path)
        
        // Parse entries from response
        let entries = try parseDirectoryEntries(response.payload, basePath: path)
        
        await metadataCache.putDirectory(path, entries: entries)
        return entries
    }
    
    func createDirectory(path: String, recursive: Bool = true) async throws {
        Self.logger.debug("Creating directory: \(path)")
        pendingOperations += 1
        defer { pendingOperations -= 1 }
        
        let response = try await webSocket.fileSystemRequest(
            method: "createDirectory",
            path: path,
            params: ["recursive": AnyCodable(recursive)]
        )
        
        try checkResponseError(response, path: path)
        await metadataCache.invalidate(path)
    }
    
    func delete(path: String, recursive: Bool = false) async throws {
        Self.logger.debug("Deleting: \(path) (recursive: \(recursive))")
        pendingOperations += 1
        defer { pendingOperations -= 1 }
        
        let response = try await webSocket.fileSystemRequest(
            method: "delete",
            path: path,
            params: ["recursive": AnyCodable(recursive)]
        )
        
        try checkResponseError(response, path: path)
        
        await fileCache.invalidate(path)
        await fileCache.invalidateDirectory(path)
        await metadataCache.invalidate(path)
    }
    
    func rename(from: String, to: String, overwrite: Bool = false) async throws {
        Self.logger.debug("Renaming: \(from) -> \(to)")
        pendingOperations += 1
        defer { pendingOperations -= 1 }
        
        let response = try await webSocket.fileSystemRequest(
            method: "rename",
            path: from,
            params: [
                "newPath": AnyCodable(to),
                "overwrite": AnyCodable(overwrite)
            ]
        )
        
        try checkResponseError(response, path: from)
        
        await fileCache.invalidate(from)
        await fileCache.invalidate(to)
        await metadataCache.invalidate(from)
        await metadataCache.invalidate(to)
    }
    
    func copy(from: String, to: String, overwrite: Bool = false) async throws {
        Self.logger.debug("Copying: \(from) -> \(to)")
        pendingOperations += 1
        defer { pendingOperations -= 1 }
        
        let response = try await webSocket.fileSystemRequest(
            method: "copy",
            path: from,
            params: [
                "destination": AnyCodable(to),
                "overwrite": AnyCodable(overwrite)
            ]
        )
        
        try checkResponseError(response, path: from)
        
        await metadataCache.invalidate(to)
    }
    
    func exists(path: String) async throws -> Bool {
        do {
            let _ = try await stat(path: path)
            return true
        } catch {
            if case RemoteFileError.fileNotFound = error {
                return false
            }
            throw error
        }
    }
    
    // MARK: - File Watching
    
    func watch(path: String, recursive: Bool = true) -> AsyncStream<RemoteFileChangeEvent> {
        return AsyncStream { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            
            // Subscribe to file system events for this path
            let stream = self.webSocket.subscribeChannel(path, type: .fileSystemEvent)
            
            let task = Task {
                for await message in stream {
                    if let event = self.parseFileChangeEvent(message, watchPath: path, recursive: recursive) {
                        // Invalidate caches for changed files
                        await self.fileCache.invalidate(event.path)
                        await self.metadataCache.invalidate(event.path)
                        
                        continuation.yield(event)
                    }
                }
                continuation.finish()
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    // MARK: - Cache Management
    
    func clearCaches() async {
        await fileCache.clear()
        await metadataCache.clear()
    }
    
    func invalidatePath(_ path: String) async {
        await fileCache.invalidate(path)
        await metadataCache.invalidate(path)
    }
    
    // MARK: - Private Helpers
    
    private func checkResponseError(_ response: TunnelMessage, path: String) throws {
        guard let errorCode = response.payload["error"]?.stringValue else { return }
        
        switch errorCode {
        case "ENOENT", "FileNotFound":
            throw RemoteFileError.fileNotFound(path)
        case "EACCES", "PermissionDenied":
            throw RemoteFileError.permissionDenied(path)
        case "ENOTEMPTY":
            throw RemoteFileError.directoryNotEmpty(path)
        case "EEXIST":
            throw RemoteFileError.alreadyExists(path)
        case "ENOTDIR":
            throw RemoteFileError.notADirectory(path)
        case "EISDIR":
            throw RemoteFileError.notAFile(path)
        case "EDQUOT":
            throw RemoteFileError.quotaExceeded
        case "ENAMETOOLONG":
            throw RemoteFileError.pathTooLong(path)
        default:
            let message = response.payload["message"]?.stringValue ?? errorCode
            throw RemoteFileError.ioError(message)
        }
    }
    
    private func parseStatFromPayload(_ payload: [String: AnyCodable]) throws -> RemoteFileStat? {
        guard let typeStr = payload["type"]?.stringValue,
              let type = RemoteFileType(rawValue: typeStr) else {
            return nil
        }
        
        return RemoteFileStat(
            type: type,
            size: Int64(payload["size"]?.intValue ?? 0),
            createdAt: Date(timeIntervalSince1970: payload["created"]?.doubleValue ?? 0),
            modifiedAt: Date(timeIntervalSince1970: payload["modified"]?.doubleValue ?? 0),
            permissions: UInt16(payload["permissions"]?.intValue ?? 0o644),
            isSymlink: payload["isSymlink"]?.boolValue ?? false,
            isReadOnly: payload["isReadOnly"]?.boolValue ?? false
        )
    }
    
    private func parseDirectoryEntries(
        _ payload: [String: AnyCodable],
        basePath: String
    ) throws -> [RemoteDirectoryEntry] {
        // Expect entries as an array in the payload
        guard let entriesValue = payload["entries"]?.value as? [[String: Any]] else {
            return []
        }
        
        return entriesValue.compactMap { dict -> RemoteDirectoryEntry? in
            guard let name = dict["name"] as? String,
                  let typeStr = dict["type"] as? String,
                  let type = RemoteFileType(rawValue: typeStr) else {
                return nil
            }
            
            let fullPath = basePath.hasSuffix("/")
                ? basePath + name
                : basePath + "/" + name
            
            return RemoteDirectoryEntry(
                name: name,
                path: fullPath,
                type: type,
                size: dict["size"] as? Int64,
                modifiedAt: (dict["modified"] as? Double).map { Date(timeIntervalSince1970: $0) },
                isHidden: name.hasPrefix(".")
            )
        }
    }
    
    private nonisolated func parseFileChangeEvent(
        _ message: TunnelMessage,
        watchPath: String,
        recursive: Bool
    ) -> RemoteFileChangeEvent? {
        guard let typeStr = message.payload["changeType"]?.stringValue,
              let changeType = RemoteFileChangeType(rawValue: typeStr),
              let path = message.payload["path"]?.stringValue else {
            return nil
        }
        
        // Filter by watch path
        if recursive {
            let prefix = watchPath.hasSuffix("/") ? watchPath : watchPath + "/"
            guard path.hasPrefix(prefix) || path == watchPath else { return nil }
        } else {
            let dir = (path as NSString).deletingLastPathComponent
            guard dir == watchPath || path == watchPath else { return nil }
        }
        
        return RemoteFileChangeEvent(
            type: changeType,
            path: path,
            timestamp: message.timestamp,
            stat: nil  // Stat fetched lazily if needed
        )
    }
}
