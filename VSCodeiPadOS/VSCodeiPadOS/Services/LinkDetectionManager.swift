//
//  LinkDetectionManager.swift
//  VSCodeiPadOS
//
//  Detects clickable URLs and file paths in editor text.
//  Provides Cmd+Click interaction to open links in Safari or navigate to local files.
//

import Foundation
import UIKit
import os

// MARK: - Detected Link

/// Represents a detected link in editor text.
struct DetectedLink: Hashable {
    let range: NSRange          // UTF-16 range in the text
    let url: URL?               // Non-nil for http/https/ftp URLs
    let filePath: String?       // Non-nil for local file paths
    let displayText: String

    var isURL: Bool { url != nil }
    var isFilePath: Bool { filePath != nil }
}

// MARK: - Link Detection Manager

/// Scans editor text for URLs and file paths, caches results, and provides
/// Cmd+Click interaction support for opening links.
@MainActor
final class LinkDetectionManager {

    static let shared = LinkDetectionManager()

    private static let logger = Logger(subsystem: "com.codepad.app", category: "LinkDetection")

    // MARK: - Configuration

    /// Whether link detection is enabled.
    var isEnabled: Bool = true

    /// URLs detected in the current text (keyed by a simple content hash to avoid re-scanning).
    private var cachedLinks: [DetectedLink] = []
    private var cachedTextHash: Int = 0

    // MARK: - Link Styling

    /// The underline color for detected links.
    private(set) var linkColor: UIColor = .systemBlue

    /// The underline style for detected links.
    private(set) var linkUnderlineStyle: NSUnderlineStyle = .single

    // MARK: - Regex Patterns (pre-compiled)

    /// Matches http, https, ftp, ftps URLs.
    private static let urlPattern: NSRegularExpression = {
        // Match URLs starting with http/https/ftp/ftps
        let pattern = #"(https?|ftps?)://[^\s<>\[\]()\"']+"#
        try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }()

    /// Matches relative or absolute file paths.
    /// Matches paths like: ./foo, ../bar, /usr/local, ~/Documents, src/file.swift
    private static let filePathPattern: NSRegularExpression = {
        let pattern = #"(?:\.{1,2}/|\~/|/)(?:[A-Za-z0-9_\-.]+/)*[A-Za-z0-9_\-.]+\.[A-Za-z0-9]{1,10}"#
        try! NSRegularExpression(pattern: pattern, options: [])
    }()

    private init() {}

    // MARK: - Public API

    /// Detect all links in the given text. Uses a content-length hash to avoid
    /// re-scanning when text hasn't changed (rapid calls during typing).
    func detectLinks(in text: String) -> [DetectedLink] {
        guard isEnabled else { return [] }

        let nsText = text as NSString
        let currentHash = nsText.length

        // Quick skip: if text length hasn't changed and we still have cached links
        // that all fall within bounds, reuse them.
        if currentHash == cachedTextHash && !cachedLinks.isEmpty {
            let allInRange = cachedLinks.allSatisfy {
                $0.range.location + $0.range.length <= currentHash
            }
            if allInRange { return cachedLinks }
        }

        var links: [DetectedLink] = []

        // Detect URLs
        let urlMatches = Self.urlPattern.matches(
            in: text,
            options: [],
            range: NSRange(location: 0, length: nsText.length)
        )
        for match in urlMatches {
            guard match.range.location != NSNotFound else { continue }
            let linkText = nsText.substring(with: match.range)

            // Trim trailing punctuation that is likely not part of the URL
            let trimmed = linkText.trimmingTrailingPunctuation()
            let trimmedRange = NSRange(
                location: match.range.location,
                length: trimmed.count
            )

            guard let url = URL(string: trimmed) else { continue }
            links.append(DetectedLink(
                range: trimmedRange,
                url: url,
                filePath: nil,
                displayText: trimmed
            ))
        }

        // Detect file paths (skip ranges already covered by URLs)
        let filePathMatches = Self.filePathPattern.matches(
            in: text,
            options: [],
            range: NSRange(location: 0, length: nsText.length)
        )
        let urlRanges = Set(urlMatches.map { $0.range })

        for match in filePathMatches {
            guard match.range.location != NSNotFound else { continue }

            // Skip if this range overlaps with a detected URL
            let overlaps = urlRanges.contains { urlRange in
                NSIntersectionRange(match.range, urlRange).length > 0
            }
            if overlaps { continue }

            let pathText = nsText.substring(with: match.range)
            links.append(DetectedLink(
                range: match.range,
                url: nil,
                filePath: pathText,
                displayText: pathText
            ))
        }

        cachedLinks = links
        cachedTextHash = currentHash

        Self.logger.debug("Detected \(links.count) links in text (\(currentHash) chars)")

        return links
    }

    /// Find the link at a given UTF-16 offset, if any.
    func linkAt(offset: Int) -> DetectedLink? {
        cachedLinks.first { link in
            NSLocationInRange(offset, link.range)
        }
    }

    /// Clear cached links (e.g. when file changes).
    func clearCache() {
        cachedLinks.removeAll()
        cachedTextHash = 0
    }

    // MARK: - Styling

    /// Apply subtle link underline styling to all detected links in the text storage.
    /// Call after syntax highlighting is applied so links take visual priority.
    func applyLinkStyling(to textStorage: NSTextStorage) {
        guard isEnabled, !cachedLinks.isEmpty else { return }

        textStorage.beginEditing()
        for link in cachedLinks {
            let safeRange = NSRange(
                location: link.range.location,
                length: min(link.range.length, textStorage.length - link.range.location)
            )
            guard safeRange.length > 0 else { continue }
            textStorage.addAttribute(.underlineStyle, value: linkUnderlineStyle.rawValue, range: safeRange)
            textStorage.addAttribute(.underlineColor, value: linkColor, range: safeRange)
        }
        textStorage.endEditing()
    }

    // MARK: - Action

    /// Open a detected link. URLs open in Safari; file paths attempt to navigate
    /// to the file via a notification.
    func openLink(_ link: DetectedLink, workspaceRoot: String? = nil) {
        if let url = link.url {
            Self.logger.info("Opening URL: \(url.absoluteString)")
            UIApplication.shared.open(url)
        } else if let filePath = link.filePath {
            // Resolve the path relative to workspace root if it's relative
            let resolvedPath: String
            if filePath.hasPrefix("/") || filePath.hasPrefix("~") {
                resolvedPath = (filePath as NSString).expandingTildeInPath
            } else if let root = workspaceRoot, !root.isEmpty {
                resolvedPath = (root as NSString).appendingPathComponent(filePath)
            } else {
                resolvedPath = (filePath as NSString).expandingTildeInPath
            }

            Self.logger.info("Navigating to file path: \(resolvedPath)")
            // Post notification for the editor to handle file navigation
            NotificationCenter.default.post(
                name: .init("com.codepad.openFilePath"),
                object: nil,
                userInfo: ["path": resolvedPath]
            )
        }
    }
}

// MARK: - String Helpers

private extension String {
    /// Trim trailing characters that are unlikely to be part of a URL.
    func trimmingTrailingPunctuation() -> String {
        let trimChars: Set<Character> = [".", ",", ":", ";", "!", "?", ")", "]", "}"]
        var result = self
        while let last = result.last, trimChars.contains(last) {
            result.removeLast()
        }
        return result
    }
}

// MARK: - NSRange Helpers

private extension NSRange {
    /// Check if a location falls within this range.
    func containsLocation(_ location: Int) -> Bool {
        return location >= self.location && location < self.location + self.length
    }
}
