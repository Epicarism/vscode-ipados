import Foundation
import SwiftUI

// MARK: - FEAT-071 Git gutter indicators + FEAT-072 Inline blame
//
// This file is self-contained and provides:
// - FEAT-071: Git gutter indicators (added/modified/deleted)
// - FEAT-072: Inline blame label (for selected/caret line)
//
// IMPORTANT (integration):
// - Host editor must overlay/place this view aligned to the text content.
// - Host editor should provide:
//   - fileURL
//   - visibleLineRange (1-based, end-exclusive)
//   - lineHeight
//   - contentTopInset
//   - selectedLine (1-based)
//   - refreshToken (bump to refresh when content/git state changes)
// - If your app already has git diff/blame services, inject them via `dataSource`.

// MARK: Models

public enum GitLineChangeKind: Hashable, Sendable {
    case added
    case modified
    /// Represents a deletion marker at a line boundary (typically drawn between lines).
    case deleted
}

public struct GitLineChange: Hashable, Sendable {
    public var line: Int // 1-based (new-file line number)
    public var kind: GitLineChangeKind

    public init(line: Int, kind: GitLineChangeKind) {
        self.line = line
        self.kind = kind
    }
}

public struct GitBlameLine: Hashable, Sendable {
    public var line: Int // 1-based
    public var commit: String
    public var author: String
    public var authorTime: Date?
    public var summary: String

    public init(line: Int, commit: String, author: String, authorTime: Date?, summary: String) {
        self.line = line
        self.commit = commit
        self.author = author
        self.authorTime = authorTime
        self.summary = summary
    }
}

// MARK: - Data source (injectable)

public struct GitGutterDataSource {
    public var diff: @Sendable (_ fileURL: URL, _ forceRefresh: Bool) async throws -> [GitLineChange]
    public var blame: @Sendable (_ fileURL: URL, _ forceRefresh: Bool) async throws -> [GitBlameLine]

    public init(
        diff: @escaping @Sendable (_ fileURL: URL, _ forceRefresh: Bool) async throws -> [GitLineChange],
        blame: @escaping @Sendable (_ fileURL: URL, _ forceRefresh: Bool) async throws -> [GitBlameLine]
    ) {
        self.diff = diff
        self.blame = blame
    }
}

public extension GitGutterDataSource {
    /// Default behavior:
    /// - On macOS/Mac Catalyst/Linux: attempts to run `git diff` and `git blame` via `Process`.
    /// - On iOS (non-Catalyst): returns empty results (host should inject a real dataSource).
    static var `default`: GitGutterDataSource {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        return .empty
        #else
        return .gitCLI
        #endif
    }

    static var empty: GitGutterDataSource {
        GitGutterDataSource(
            diff: { _, _ in [] },
            blame: { _, _ in [] }
        )
    }

    /// Git CLI-backed data source (uses `git diff` / `git blame`).
    static var gitCLI: GitGutterDataSource {
        GitGutterDataSource(
            diff: { fileURL, force in
                if force { await GitDiffService.shared.invalidate(forFile: fileURL) }
                return try await GitDiffService.shared.lineChanges(forFile: fileURL)
            },
            blame: { fileURL, force in
                if force { await GitBlameService.shared.invalidate(forFile: fileURL) }
                return try await GitBlameService.shared.blame(forFile: fileURL)
            }
        )
    }
}

// MARK: - View

/// Gutter view that renders git diff indicators (added/modified/deleted) and an optional inline blame label.
public struct GitGutterView: View {
    public struct Configuration {
        public var showsDiffIndicators: Bool = true
        public var showsInlineBlame: Bool = true

        public var gutterWidth: CGFloat = 6
        public var gutterCornerRadius: CGFloat = 1

        public var inlineBlameLeadingPadding: CGFloat = 8
        public var inlineBlameTrailingPadding: CGFloat = 8
        public var inlineBlameFont: Font = .system(size: 11, weight: .regular, design: .monospaced)
        public var inlineBlameMaxWidth: CGFloat = 420

        public var addedColor: Color = Color(red: 0.20, green: 0.78, blue: 0.35)
        public var modifiedColor: Color = Color(red: 0.20, green: 0.55, blue: 0.95)
        public var deletedColor: Color = Color(red: 0.92, green: 0.30, blue: 0.24)

        public var inlineBlameTextColor: Color = .secondary
        public var inlineBlameBackground: Color = Color.secondary.opacity(0.10)
        public var inlineBlameCornerRadius: CGFloat = 6

        public init() {}
    }

    private let fileURL: URL
    private let visibleLineRange: Range<Int> // 1-based, end-exclusive
    private let lineHeight: CGFloat
    private let contentTopInset: CGFloat
    private let selectedLine: Int?
    private let refreshToken: AnyHashable
    private let configuration: Configuration
    private let dataSource: GitGutterDataSource

    @State private var changesByLine: [Int: GitLineChangeKind] = [:]
    @State private var deletedMarkers: Set<Int> = []
    @State private var blameByLine: [Int: GitBlameLine] = [:]

    public init(
        fileURL: URL,
        visibleLineRange: Range<Int>,
        lineHeight: CGFloat,
        contentTopInset: CGFloat = 0,
        selectedLine: Int? = nil,
        refreshToken: AnyHashable = 0,
        configuration: Configuration = .init(),
        dataSource: GitGutterDataSource = .default
    ) {
        self.fileURL = fileURL
        self.visibleLineRange = visibleLineRange
        self.lineHeight = lineHeight
        self.contentTopInset = contentTopInset
        self.selectedLine = selectedLine
        self.refreshToken = refreshToken
        self.configuration = configuration
        self.dataSource = dataSource
    }

    public var body: some View {
        HStack(spacing: 0) {
            if configuration.showsDiffIndicators {
                diffGutter
                    .frame(width: configuration.gutterWidth)
            }

            if configuration.showsInlineBlame {
                inlineBlameColumn
            }
        }
        // Reload when:
        // - file changes
        // - refreshToken changes (host signals content/git refresh)
        .task(id: fileURL) {
            await reloadAll(force: true)
        }
        .task(id: refreshToken) {
            await reloadAll(force: true)
        }
    }

    private var diffGutter: some View {
        GeometryReader { _ in
            Canvas { context, size in
                guard !visibleLineRange.isEmpty else { return }

                let w = size.width
                let corner = configuration.gutterCornerRadius

                for line in visibleLineRange {
                    if let kind = changesByLine[line] {
                        let y = contentTopInset + CGFloat(line - visibleLineRange.lowerBound) * lineHeight
                        let rect = CGRect(x: 0, y: y, width: w, height: max(1, lineHeight))
                        let path = Path(roundedRect: rect, cornerRadius: corner)
                        context.fill(path, with: .color(color(for: kind)))
                    }

                    // Deleted markers are drawn as triangles at the boundary.
                    if deletedMarkers.contains(line) {
                        let y = contentTopInset + CGFloat(line - visibleLineRange.lowerBound) * lineHeight
                        var p = Path()
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: w, y: y + (lineHeight * 0.5)))
                        p.addLine(to: CGPoint(x: 0, y: y + lineHeight))
                        p.closeSubpath()
                        context.fill(p, with: .color(configuration.deletedColor))
                    }
                }
            }
        }
        .accessibilityLabel("Git diff gutter")
    }

    private var inlineBlameColumn: some View {
        ZStack(alignment: .topLeading) {
            if let selectedLine,
               let blame = blameByLine[selectedLine],
               visibleLineRange.contains(selectedLine) {
                let y = contentTopInset + CGFloat(selectedLine - visibleLineRange.lowerBound) * lineHeight

                inlineBlameLabel(for: blame)
                    .frame(maxWidth: configuration.inlineBlameMaxWidth, alignment: .leading)
                    .offset(x: configuration.inlineBlameLeadingPadding, y: y)
                    .allowsHitTesting(false)
            }
        }
        .padding(.trailing, configuration.inlineBlameTrailingPadding)
        .accessibilityLabel("Inline git blame")
    }

    @ViewBuilder
    private func inlineBlameLabel(for blame: GitBlameLine) -> some View {
        let commitShort = String(blame.commit.prefix(8))
        let author = blame.author.isEmpty ? "Unknown" : blame.author
        let summary = blame.summary

        Text("\(author) \(commitShort) — \(summary)")
            .font(configuration.inlineBlameFont)
            .foregroundStyle(configuration.inlineBlameTextColor)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(configuration.inlineBlameBackground)
            .clipShape(RoundedRectangle(cornerRadius: configuration.inlineBlameCornerRadius, style: .continuous))
    }

    private func color(for kind: GitLineChangeKind) -> Color {
        switch kind {
        case .added: return configuration.addedColor
        case .modified: return configuration.modifiedColor
        case .deleted: return configuration.deletedColor
        }
    }

    // MARK: Reload

    @MainActor
    private func reloadAll(force: Bool) async {
        // Diff
        if configuration.showsDiffIndicators {
            do {
                let diff = try await dataSource.diff(fileURL, force)
                var byLine: [Int: GitLineChangeKind] = [:]
                var deletions: Set<Int> = []

                for c in diff {
                    switch c.kind {
                    case .deleted:
                        deletions.insert(max(1, c.line))
                    case .added, .modified:
                        byLine[c.line] = c.kind
                    }
                }

                self.changesByLine = byLine
                self.deletedMarkers = deletions
            } catch {
                self.changesByLine = [:]
                self.deletedMarkers = []
            }
        }

        // Blame
        if configuration.showsInlineBlame {
            do {
                let blame = try await dataSource.blame(fileURL, force)
                self.blameByLine = Dictionary(uniqueKeysWithValues: blame.map { ($0.line, $0) })
            } catch {
                self.blameByLine = [:]
            }
        }
    }
}

// MARK: - Minimal Git wrappers (CLI-backed)

private enum GitError: Error, LocalizedError {
    case notARepository
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .notARepository:
            return "Not a git repository"
        case .commandFailed(let msg):
            return "Git command failed: \(msg)"
        }
    }
}

private struct GitShell {
    static func runGit(args: [String], in workingDirectory: URL) async throws -> String {
        #if os(macOS) || targetEnvironment(macCatalyst) || os(Linux)
        return try await withCheckedThrowingContinuation { cont in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["git"] + args
            process.currentDirectoryURL = workingDirectory

            let outPipe = Pipe()
            let errPipe = Pipe()
            process.standardOutput = outPipe
            process.standardError = errPipe

            do {
                try process.run()
            } catch {
                cont.resume(throwing: GitError.commandFailed("Unable to launch git"))
                return
            }

            process.terminationHandler = { p in
                let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

                let out = String(data: outData, encoding: .utf8) ?? ""
                let err = String(data: errData, encoding: .utf8) ?? ""

                if p.terminationStatus == 0 {
                    cont.resume(returning: out)
                } else {
                    let msg = err.trimmingCharacters(in: .whitespacesAndNewlines)
                    cont.resume(throwing: GitError.commandFailed(msg.isEmpty ? out : msg))
                }
            }
        }
        #else
        throw GitError.commandFailed("Git execution is not available on this platform")
        #endif
    }

    static func repoRoot(containing fileURL: URL) async throws -> URL {
        let dir = fileURL.deletingLastPathComponent()
        let out = try await runGit(args: ["-C", dir.path, "rev-parse", "--show-toplevel"], in: dir)
        let rootPath = out.trimmingCharacters(in: .whitespacesAndNewlines)
        if rootPath.isEmpty { throw GitError.notARepository }
        return URL(fileURLWithPath: rootPath)
    }
}

// MARK: - Diff

private actor GitDiffService {
    static let shared = GitDiffService()

    private var cache: [String: [GitLineChange]] = [:] // key: repoRoot + fileRelPath

    func invalidate(forFile fileURL: URL) async {
        do {
            let repoRoot = try await GitShell.repoRoot(containing: fileURL)
            let relPath = Self.relativePath(fileURL, repoRoot)
            let key = repoRoot.path + "::" + relPath
            cache.removeValue(forKey: key)
        } catch {
            // ignore
        }
    }

    func lineChanges(forFile fileURL: URL) async throws -> [GitLineChange] {
        let repoRoot = try await GitShell.repoRoot(containing: fileURL)
        let relPath = Self.relativePath(fileURL, repoRoot)
        let key = repoRoot.path + "::" + relPath

        if let cached = cache[key] { return cached }

        // Unified=0 makes hunks contain only the changed lines, simplifying mapping.
        let diff = try await GitShell.runGit(
            args: ["-C", repoRoot.path, "diff", "--unified=0", "--no-color", "--", relPath],
            in: repoRoot
        )

        let parsed = Self.parseUnifiedZeroDiff(diff)
        cache[key] = parsed
        return parsed
    }

    fileprivate static func relativePath(_ fileURL: URL, _ repoRoot: URL) -> String {
        let filePath = fileURL.standardizedFileURL.path
        let rootPath = repoRoot.standardizedFileURL.path
        if filePath.hasPrefix(rootPath + "/") {
            return String(filePath.dropFirst(rootPath.count + 1))
        }
        return fileURL.lastPathComponent
    }

    /// Parse output from: `git diff --unified=0 --no-color -- <file>`.
    ///
    /// Heuristic classification per hunk:
    /// - oldCount==0,newCount>0 -> .added on new range
    /// - oldCount>0,newCount>0 -> .modified on new range
    /// - oldCount>0,newCount==0 -> .deleted marker at newStart
    private static func parseUnifiedZeroDiff(_ text: String) -> [GitLineChange] {
        var results: [GitLineChange] = []

        // Example hunk header (unified=0):
        // @@ -12,2 +12,3 @@
        // or @@ -12 +12 @@
        for raw in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(raw)
            guard line.hasPrefix("@@"), let h = parseHunkHeader(line) else { continue }

            if h.oldCount == 0 && h.newCount > 0 {
                for n in 0..<h.newCount {
                    results.append(.init(line: h.newStart + n, kind: .added))
                }
            } else if h.oldCount > 0 && h.newCount > 0 {
                for n in 0..<h.newCount {
                    results.append(.init(line: h.newStart + n, kind: .modified))
                }
            } else if h.oldCount > 0 && h.newCount == 0 {
                results.append(.init(line: max(1, h.newStart), kind: .deleted))
            }
        }

        // De-dupe (prefer modified over added if collision).
        var byLine: [Int: GitLineChangeKind] = [:]
        var deleted: Set<Int> = []
        for r in results {
            switch r.kind {
            case .deleted:
                deleted.insert(r.line)
            case .added:
                if byLine[r.line] == nil { byLine[r.line] = .added }
            case .modified:
                byLine[r.line] = .modified
            }
        }

        var merged: [GitLineChange] = []
        for (line, kind) in byLine { merged.append(.init(line: line, kind: kind)) }
        for d in deleted { merged.append(.init(line: d, kind: .deleted)) }

        return merged.sorted { $0.line < $1.line }
    }

    private struct Hunk {
        var oldStart: Int
        var oldCount: Int
        var newStart: Int
        var newCount: Int
    }

    private static func parseHunkHeader(_ header: String) -> Hunk? {
        // Header format: @@ -oldStart,oldCount +newStart,newCount @@ ...
        // Counts may be omitted: -12 +12
        guard let rangeStart = header.range(of: "@@") else { return nil }
        guard let rangeEnd = header.range(of: "@@", options: [], range: rangeStart.upperBound..<header.endIndex) else { return nil }
        let body = header[rangeStart.upperBound..<rangeEnd.lowerBound].trimmingCharacters(in: .whitespaces)

        let parts = body.split(separator: " ")
        guard parts.count >= 2 else { return nil }

        func parsePart(_ s: Substring, prefix: Character) -> (Int, Int)? {
            guard s.first == prefix else { return nil }
            let rest = s.dropFirst()
            if let comma = rest.firstIndex(of: ",") {
                let a = rest[..<comma]
                let b = rest[rest.index(after: comma)...]
                guard let start = Int(a), let count = Int(b) else { return nil }
                return (start, count)
            } else {
                guard let start = Int(rest) else { return nil }
                return (start, 1)
            }
        }

        guard let old = parsePart(parts[0], prefix: "-") else { return nil }
        guard let new = parsePart(parts[1], prefix: "+") else { return nil }
        return Hunk(oldStart: old.0, oldCount: old.1, newStart: new.0, newCount: new.1)
    }
}

// MARK: - Blame

private actor GitBlameService {
    static let shared = GitBlameService()

    private var cache: [String: [GitBlameLine]] = [:] // key: repoRoot + fileRelPath

    func invalidate(forFile fileURL: URL) async {
        do {
            let repoRoot = try await GitShell.repoRoot(containing: fileURL)
            let relPath = GitDiffService.relativePath(fileURL, repoRoot)
            let key = repoRoot.path + "::" + relPath
            cache.removeValue(forKey: key)
        } catch {
            // ignore
        }
    }

    func blame(forFile fileURL: URL) async throws -> [GitBlameLine] {
        let repoRoot = try await GitShell.repoRoot(containing: fileURL)
        let relPath = GitDiffService.relativePath(fileURL, repoRoot)
        let key = repoRoot.path + "::" + relPath

        if let cached = cache[key] { return cached }

        let out = try await GitShell.runGit(
            args: ["-C", repoRoot.path, "blame", "--line-porcelain", "--", relPath],
            in: repoRoot
        )

        let parsed = Self.parseLinePorcelain(out)
        cache[key] = parsed
        return parsed
    }

    private static func parseLinePorcelain(_ text: String) -> [GitBlameLine] {
        // Format (porcelain):
        // <sha> <origLine> <finalLine> <numLines>
        // author <name>
        // author-time <unix>
        // summary <text>
        // ...
        // \t<source line>
        // (then additional \t lines if <numLines> > 1)

        var results: [GitBlameLine] = []

        var currentCommit: String = ""
        var currentAuthor: String = ""
        var currentAuthorTime: Date?
        var currentSummary: String = ""

        var pendingFinalLine: Int?
        var pendingRemaining: Int = 0

        func isHexString(_ s: Substring) -> Bool {
            !s.isEmpty && s.allSatisfy { $0.isHexDigit }
        }

        func emitOneLineIfPossible() {
            guard pendingRemaining > 0,
                  let ln = pendingFinalLine,
                  !currentCommit.isEmpty else { return }

            results.append(
                GitBlameLine(
                    line: ln,
                    commit: currentCommit,
                    author: currentAuthor,
                    authorTime: currentAuthorTime,
                    summary: currentSummary
                )
            )

            pendingFinalLine = ln + 1
            pendingRemaining -= 1

            if pendingRemaining == 0 {
                pendingFinalLine = nil
                currentCommit = ""
                currentAuthor = ""
                currentAuthorTime = nil
                currentSummary = ""
            }
        }

        for raw in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(raw)

            if line.hasPrefix("\t") {
                emitOneLineIfPossible()
                continue
            }

            // Header line:
            // <sha> <origLine> <finalLine> <numLines>
            // (some variants may omit <numLines>; treat as 1)
            let parts = line.split(separator: " ")
            if parts.count >= 3,
               isHexString(parts[0]),
               Int(parts[1]) != nil,
               let final = Int(parts[2]) {
                currentCommit = String(parts[0])
                pendingFinalLine = final
                pendingRemaining = (parts.count >= 4 ? Int(parts[3]) : nil) ?? 1
                continue
            }

            if line.hasPrefix("author ") {
                currentAuthor = String(line.dropFirst("author ".count))
            } else if line.hasPrefix("author-time ") {
                let ts = String(line.dropFirst("author-time ".count))
                if let t = TimeInterval(ts) {
                    currentAuthorTime = Date(timeIntervalSince1970: t)
                }
            } else if line.hasPrefix("summary ") {
                currentSummary = String(line.dropFirst("summary ".count))
            }
        }

        return results.sorted { $0.line < $1.line }
    }
}
