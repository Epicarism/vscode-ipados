import Foundation
import os

// MARK: - RecentFileManager

/// Manages a persistent list of recently opened files, backed by
/// security-scoped URL bookmarks so files remain accessible after
/// app relaunch (even across sandbox boundaries).
@MainActor
final class RecentFileManager: ObservableObject {

    // MARK: – Singleton

    static let shared = RecentFileManager()

    // MARK: – Public state

    @Published private(set) var recentFiles: [URL] = []

    // MARK: – Constants

    private let maxRecentFiles = 20
    private let bookmarksKey = "recentFileBookmarks"

    // MARK: – Internal bookmark cache (bookmark data → resolved URL)

    /// We keep the bookmark Data around so we can re-resolve URLs later
    /// (e.g. after the app is backgrounded and the security scope expires).
    private var bookmarkCache: [URL: Data] = [:]

    // MARK: – Init

    private init() {
        loadRecentFiles()
    }

    // MARK: – Public API

    /// Add (or re-promote) a URL to the top of the recent-files list.
    ///
    /// The caller **must** already hold a valid security-scoped resource
    /// access for `url` (obtained via `startAccessingSecurityScopedResource`)
    /// at the time of the call. A bookmark is created immediately and
    /// persisted so the URL can be re-opened in a future session.
    func addRecentFile(_ url: URL) {
        // Remove existing entry (if present) so it moves to the top
        recentFiles.removeAll { $0 == url }
        bookmarkCache.removeValue(forKey: url)

        // Create a security-scoped bookmark for this URL
        guard let bookmarkData = createBookmark(for: url) else {
            // If bookmark creation fails, skip this URL entirely
            AppLogger.editor.warning("[RecentFileManager] Could not create bookmark for \(url.path)")
            saveRecentFiles()
            return
        }

        // Insert at front
        recentFiles.insert(url, at: 0)
        bookmarkCache[url] = bookmarkData

        // Trim to limit
        if recentFiles.count > maxRecentFiles {
            let removed = recentFiles.suffix(from: maxRecentFiles)
            for url in removed {
                bookmarkCache.removeValue(forKey: url)
            }
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }

        saveRecentFiles()
    }

    /// Remove a specific URL from the recent-files list.
    func removeRecentFile(url: URL) {
        recentFiles.removeAll { $0 == url }
        bookmarkCache.removeValue(forKey: url)
        saveRecentFiles()
    }

    /// Remove all recent files.
    func clearRecents() {
        recentFiles.removeAll()
        bookmarkCache.removeAll()
        UserDefaults.standard.removeObject(forKey: bookmarksKey)
    }

    /// Clear all recent files (alias for Swift API naming consistency).
    func clearRecentFiles() {
        clearRecents()
    }

    // MARK: – Bookmark helpers

    /// Create a security-scoped bookmark for the given URL.
    ///
    /// The bookmark includes the app-scoped flag so it can be resolved
    /// without user intervention on subsequent launches.
    private func createBookmark(for url: URL) -> Data? {
        do {
            let data = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            return data
        } catch {
            AppLogger.editor.error("[RecentFileManager] bookmarkData failed for \(url.path): \(error)")
            return nil
        }
    }
    
    /// Resolve bookmark data back into a `URL` and start accessing the
    /// security-scoped resource.
    private func resolveBookmark(_ data: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            // Attempt to start accessing – this may fail if the file was moved/deleted
            let didStart = url.startAccessingSecurityScopedResource()
            defer {
                if didStart {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            guard FileManager.default.fileExists(atPath: url.path) else {
                return nil
            }

            // If the bookmark was stale, create a fresh one for next time
            if isStale {
                if let freshData = createBookmark(for: url) {
                    bookmarkCache[url] = freshData
                }
            }

            return url
        } catch {
            AppLogger.editor.error("[RecentFileManager] resolveBookmark failed: \(error)")
            return nil
        }
    }

    // MARK: – Persistence

    private func saveRecentFiles() {
        // Save only the bookmark data – URLs can be re-derived from bookmarks
        let savedBookmarks = recentFiles.compactMap { bookmarkCache[$0] }
        UserDefaults.standard.set(savedBookmarks, forKey: bookmarksKey)
    }

    private func loadRecentFiles() {
        guard let savedBookmarks = UserDefaults.standard.array(forKey: bookmarksKey) as? [Data] else {
            return
        }

        var urls: [URL] = []
        var newCache: [URL: Data] = [:]

        for bookmarkData in savedBookmarks {
            guard let url = resolveBookmark(bookmarkData) else {
                // File no longer exists or bookmark is invalid – skip
                continue
            }
            urls.append(url)
            newCache[url] = bookmarkData
        }

        recentFiles = urls
        bookmarkCache = newCache
    }
}
