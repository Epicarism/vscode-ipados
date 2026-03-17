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
    /// - On iOS (non-Catalyst): uses NativeGitReader for offline diff computation.
    static var `default`: GitGutterDataSource {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        return .nativeGit
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

    /// Native git data source (uses NativeGitReader for offline, iOS-compatible diff).
    /// Compares the working copy against HEAD. Blame is not yet supported natively.
    static var nativeGit: GitGutterDataSource {
        GitGutterDataSource(
            diff: { fileURL, force in
                if force { await NativeGitDiffService.shared.invalidate(forFile: fileURL) }
                return try await NativeGitDiffService.shared.lineChanges(forFile: fileURL)
            },
            blame: { _, _ in [] }
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

// MARK: - Native Git Diff (iOS, offline via NativeGitReader)

/// Find the git repository root containing the given file by walking up directories.
private func findRepoRoot(containing fileURL: URL) -> URL? {
    var dir = fileURL.deletingLastPathComponent()
    let fm = FileManager.default

    while true {
        let gitDir = dir.appendingPathComponent(".git")
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: gitDir.path, isDirectory: &isDir), isDir.boolValue {
            return dir
        }
        let parent = dir.deletingLastPathComponent()
        if parent.path == dir.path { break }
        dir = parent
    }
    return nil
}

private actor NativeGitDiffService {
    static let shared = NativeGitDiffService()

    private var cache: [String: [GitLineChange]] = [:]

    func invalidate(forFile fileURL: URL) async {
        if let repoRoot = findRepoRoot(containing: fileURL) {
            let relPath = GitDiffService.relativePath(fileURL, repoRoot)
            let key = repoRoot.path + "::" + relPath
            cache.removeValue(forKey: key)
        }
    }

    func lineChanges(forFile fileURL: URL) async throws -> [GitLineChange] {
        guard let repoRoot = findRepoRoot(containing: fileURL) else {
            return []
        }
        let relPath = GitDiffService.relativePath(fileURL, repoRoot)
        let key = repoRoot.path + "::" + relPath

        if let cached = cache[key] { return cached }

        guard let reader = NativeGitReader(repositoryURL: repoRoot) else {
            return []
        }

        // Get file contents at HEAD via native git object reading
        let headText = reader.fileContentsString(atPath: relPath) ?? ""
        // Read current working copy from disk
        let workingText = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""

        let changes = Self.computeLineChanges(old: headText, new: workingText)
        cache[key] = changes
        return changes
    }

    // MARK: - LCS Diff

    private enum _Edit {
        case equal
        case delete
        case insert
    }

    /// Compute [GitLineChange] from old (HEAD) and new (working copy) text.
    /// Uses an LCS-based diff algorithm with prefix/suffix trimming optimisations.
    /// Classification rules:
    /// - Pure insert (no preceding delete) -> .added
    /// - Delete followed by insert (replacement) -> .modified on the inserted lines
    /// - Pure delete (no following insert) -> .deleted marker at the new-file line boundary
    private static func computeLineChanges(old: String, new: String) -> [GitLineChange] {
        let oldLines = Self.splitLines(old)
        let newLines = Self.splitLines(new)

        if oldLines == newLines { return [] }
        if oldLines.isEmpty && !newLines.isEmpty {
            return newLines.enumerated().map { .init(line: $0.offset + 1, kind: .added) }
        }
        if !oldLines.isEmpty && newLines.isEmpty {
            return [.init(line: 1, kind: .deleted)]
        }

        let edits = lcsDiff(oldLines, newLines)

        var results: [GitLineChange] = []
        var oldLine = 1
        var newLine = 1
        var i = 0

        while i < edits.count {
            switch edits[i] {
            case .equal:
                oldLine += 1
                newLine += 1
                i += 1

            case .delete:
                // Count consecutive deletes
                var deleteCount = 0
                while i < edits.count, case .delete = edits[i] {
                    deleteCount += 1
                    i += 1
                }

                // Check if followed by inserts (replacement -> modified)
                var insertCount = 0
                while i < edits.count, case .insert = edits[i] {
                    insertCount += 1
                    i += 1
                }

                if insertCount > 0 {
                    // Replacement: inserted lines are modifications
                    for j in 0..<insertCount {
                        results.append(.init(line: newLine + j, kind: .modified))
                    }
                } else {
                    // Pure deletion
                    results.append(.init(line: max(1, newLine), kind: .deleted))
                }

                oldLine += deleteCount
                newLine += insertCount

            case .insert:
                // Pure addition (no preceding delete)
                var insertCount = 0
                while i < edits.count, case .insert = edits[i] {
                    insertCount += 1
                    i += 1
                }
                for j in 0..<insertCount {
                    results.append(.init(line: newLine + j, kind: .added))
                }
                newLine += insertCount
            }
        }

        // De-dupe: prefer .modified over .added on collision
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

    // MARK: - Helpers

    private static func splitLines(_ text: String) -> [String] {
        var lines = text.components(separatedBy: "\n")
        if lines.last == "" { lines.removeLast() }
        return lines
    }

    /// LCS-based diff with prefix/suffix trimming (mirrors DiffBuilder algorithm).
    private static func lcsDiff(_ old: [String], _ new: [String]) -> [_Edit] {
        let n = old.count
        let m = new.count

        // Size guard
        if n * m >= 2_500_000 {
            return Array(repeating: _Edit.delete, count: n) + Array(repeating: _Edit.insert, count: m)
        }

        // Common prefix/suffix trimming
        var prefixCount = 0
        while prefixCount < n && prefixCount < m && old[prefixCount] == new[prefixCount] {
            prefixCount += 1
        }
        var suffixCount = 0
        while suffixCount < (n - prefixCount) && suffixCount < (m - prefixCount)
                && old[n - 1 - suffixCount] == new[m - 1 - suffixCount] {
            suffixCount += 1
        }

        let trimmedOld = Array(old[prefixCount..<(n - suffixCount)])
        let trimmedNew = Array(new[prefixCount..<(m - suffixCount)])

        if trimmedOld.isEmpty && trimmedNew.isEmpty {
            return Array(repeating: _Edit.equal, count: n)
        }

        let tn = trimmedOld.count
        let tm = trimmedNew.count

        // Early-exit: one side is entirely new additions or deletions after trimming.
        // Without these guards, `for i in 1...0` below creates an invalid Swift
        // ClosedRange (1...0) and traps at runtime whenever lines are appended to
        // the end of a file or the tail is deleted (a very common editing pattern).
        if tn == 0 {
            // All trimmed-middle lines are pure insertions.
            var out: [_Edit] = []
            out.reserveCapacity(prefixCount + tm + suffixCount)
            for _ in 0..<prefixCount { out.append(.equal) }
            for _ in 0..<tm          { out.append(.insert) }
            for _ in 0..<suffixCount { out.append(.equal) }
            return out
        }
        if tm == 0 {
            // All trimmed-middle lines are pure deletions.
            var out: [_Edit] = []
            out.reserveCapacity(prefixCount + tn + suffixCount)
            for _ in 0..<prefixCount { out.append(.equal) }
            for _ in 0..<tn          { out.append(.delete) }
            for _ in 0..<suffixCount { out.append(.equal) }
            return out
        }

        // LCS DP table (tn >= 1 and tm >= 1, so 1...tn / 1...tm are valid)
        var dp = Array(repeating: Array(repeating: 0, count: tm + 1), count: tn + 1)
        for i in 1...tn {
            for j in 1...tm {
                if trimmedOld[i - 1] == trimmedNew[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        // Back-track to produce edit script
        var edits: [_Edit] = []
        edits.reserveCapacity(tn + tm)
        var i = tn
        var j = tm
        while i > 0 || j > 0 {
            if i > 0, j > 0, trimmedOld[i - 1] == trimmedNew[j - 1] {
                edits.append(.equal)
                i -= 1; j -= 1
            } else if j > 0, i == 0 || dp[i][j - 1] >= dp[i - 1][j] {
                edits.append(.insert)
                j -= 1
            } else if i > 0 {
                edits.append(.delete)
                i -= 1
            }
        }

        let middleEdits = edits.reversed()

        // Reassemble: prefix (equal) + middle + suffix (equal)
        var result: [_Edit] = []
        result.reserveCapacity(prefixCount + middleEdits.count + suffixCount)
        for _ in 0..<prefixCount { result.append(.equal) }
        result.append(contentsOf: middleEdits)
        for _ in 0..<suffixCount { result.append(.equal) }

        return result
    }
}
