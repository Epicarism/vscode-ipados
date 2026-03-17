//
//  WorkspaceSettings.swift
//  VSCodeiPadOS
//

import Foundation

/// Per-workspace user settings (persisted via JSON).
struct WorkspaceSettings: Codable, Equatable {
    /// Maximum number of recent files to retain.
    static let defaultMaxRecentFiles = 20

    /// Ordered list of recently opened file paths (most-recent first).
    var recentFiles: [String] = []

    /// Upper bound for the recentFiles list.  When set, callers should
    /// trim the list to this count.  Default is `defaultMaxRecentFiles`.
    var maxRecentFiles: Int = defaultMaxRecentFiles

    /// Adds a file path to the recent-files list, handling deduplication
    /// and enforcing the `maxRecentFiles` limit.
    ///
    /// - If the path is already present it is moved to the front.
    /// - If the list exceeds `maxRecentFiles` after insertion, the tail
    ///   is trimmed.
    mutating func addRecentFile(_ path: String) {
        // Deduplicate: remove any existing entry so it can be re-inserted
        // at the front, preserving most-recent-first ordering.
        recentFiles.removeAll { $0 == path }

        // Insert at the front (most recently used).
        recentFiles.insert(path, at: 0)

        // Enforce the limit.
        if recentFiles.count > maxRecentFiles {
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }
    }

    /// Removes a file path from the recent-files list.
    mutating func removeRecentFile(_ path: String) {
        recentFiles.removeAll { $0 == path }
    }

    /// Clears all recent files.
    mutating func clearRecentFiles() {
        recentFiles.removeAll()
    }

    /// An empty / default settings instance.
    static let empty = WorkspaceSettings()
}
