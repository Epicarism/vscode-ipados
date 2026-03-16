//
//  TimelineView.swift
//  VSCodeiPadOS
//
//  Timeline panel showing Git history and local save tracking
//

import SwiftUI
import Foundation
import Combine

// MARK: - Timeline Models

/// Represents a single change in a file's history (Git commit, local save, etc.).
struct TimelineEntry: Identifiable, Hashable, Sendable {
    enum Source: String, CaseIterable, Hashable, Sendable {
        case git = "Git"
        case local = "Local"

        var label: String { rawValue }

        var systemImage: String {
            switch self {
            case .git: return "arrow.triangle.branch"
            case .local: return "internaldrive"
            }
        }

        var tint: Color {
            switch self {
            case .git: return .blue
            case .local: return .orange
            }
        }
    }

    struct DiffSummary: Hashable, Sendable {
        var added: Int
        var deleted: Int

        var isEmpty: Bool { added == 0 && deleted == 0 }

        var text: String {
            // VS Code-ish compact summary: +12 −4
            let plus = added > 0 ? "+\(added)" : nil
            let minus = deleted > 0 ? "−\(deleted)" : nil
            return [plus, minus].compactMap { $0 }.joined(separator: " ")
        }
    }

    let id: UUID
    let timestamp: Date
    let source: Source
    /// "Author" for git; "Device/User" for local saves.
    let author: String
    /// Short change description (commit message, save reason, etc.)
    let message: String
    /// Optional diff summary if available.
    let diff: DiffSummary?
    /// SHA for git commits (used for identification)
    let commitSHA: String?

    init(
        id: UUID = UUID(),
        timestamp: Date,
        source: Source,
        author: String,
        message: String,
        diff: DiffSummary? = nil,
        commitSHA: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.source = source
        self.author = author
        self.message = message
        self.diff = diff
        self.commitSHA = commitSHA
    }
}

// MARK: - Provider (Git integration)

/// Abstraction point for Git history / local save tracking.
protocol TimelineProviding: Sendable {
    /// - Parameter filePath: A workspace-relative file path (or identifier) to fetch history for.
    func timelineEntries(for filePath: String?, workingDirectory: String?) async -> [TimelineEntry]
}

/// Real Git provider that uses SSH to fetch git log with diff stats
final class GitTimelineProvider: TimelineProviding, @unchecked Sendable {
    
    /// Escape single quotes in shell arguments to prevent injection
    private func shellEscape(_ str: String) -> String {
        str.replacingOccurrences(of: "'", with: "'\\''")
    }
    
    func timelineEntries(for filePath: String?, workingDirectory: String?) async -> [TimelineEntry] {
        let ssh = SSHManager.shared
        
        // Must have SSH connection to fetch git history
        guard ssh.isConnected else {
            return []
        }
        
        // Build the git log command with numstat for diff info
        // Format: SHA|||author|||subject|||ISO8601 date
        var command: String
        if let dir = workingDirectory {
            let escapedDir = shellEscape(dir)
            if let path = filePath, !path.isEmpty {
                let escapedPath = shellEscape(path)
                command = "cd '\(escapedDir)' && git log --format='%H|||%an|||%s|||%aI' --numstat -30 -- '\(escapedPath)'"
            } else {
                command = "cd '\(escapedDir)' && git log --format='%H|||%an|||%s|||%aI' --numstat -30"
            }
        } else {
            // No working directory - can't run git log
            return []
        }
        
        do {
            let result = try await ssh.executeCommand(command, timeout: 30)
            
            guard result.isSuccess else {
                return []
            }
            
            return parseGitLogOutput(result.stdout)
        } catch {
            return []
        }
    }
    
    private func parseGitLogOutput(_ output: String) -> [TimelineEntry] {
        var entries: [TimelineEntry] = []
        
        // Split by commit blocks (each commit starts with the format line)
        // Output format:
        // SHA|||author|||subject|||ISO8601
        // added\tdeleted\tfilepath
        // added\tdeleted\tfilepath
        // (empty line)
        // SHA|||author|||subject|||ISO8601
        // ...
        
        let lines = output.components(separatedBy: "\n")
        var currentEntry: (sha: String, author: String, message: String, date: Date, added: Int, deleted: Int)?
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Check if this is a commit header line (contains |||)
            if trimmed.contains("|||") {
                // Save previous entry if exists
                if let entry = currentEntry {
                    entries.append(TimelineEntry(
                        timestamp: entry.date,
                        source: .git,
                        author: entry.author,
                        message: entry.message,
                        diff: TimelineEntry.DiffSummary(added: entry.added, deleted: entry.deleted),
                        commitSHA: entry.sha
                    ))
                }
                
                // Parse new commit header
                let parts = trimmed.components(separatedBy: "|||")
                if parts.count >= 4 {
                    let sha = parts[0].trimmingCharacters(in: .whitespaces)
                    let author = parts[1].trimmingCharacters(in: .whitespaces)
                    let message = parts[2].trimmingCharacters(in: .whitespaces)
                    let dateStr = parts[3].trimmingCharacters(in: .whitespaces)
                    
                    // Parse ISO8601 date (try with fractional seconds first, then without)
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    let date = formatter.date(from: dateStr)
                        ?? ISO8601DateFormatter().date(from: dateStr)
                        ?? Date()
                    
                    currentEntry = (sha: sha, author: author, message: message, date: date, added: 0, deleted: 0)
                } else {
                    currentEntry = nil
                }
            } else if !trimmed.isEmpty, let _ = currentEntry {
                // This might be a numstat line: added\tdeleted\tfilepath
                let numstatParts = trimmed.components(separatedBy: "\t")
                if numstatParts.count >= 2 {
                    let added = Int(numstatParts[0]) ?? 0
                    let deleted = Int(numstatParts[1]) ?? 0
                    
                    // Accumulate diff stats for this commit
                    if let entry = currentEntry {
                        currentEntry = (
                            sha: entry.sha,
                            author: entry.author,
                            message: entry.message,
                            date: entry.date,
                            added: entry.added + added,
                            deleted: entry.deleted + deleted
                        )
                    }
                }
            }
        }
        
        // Don't forget the last entry
        if let entry = currentEntry {
            entries.append(TimelineEntry(
                timestamp: entry.date,
                source: .git,
                author: entry.author,
                message: entry.message,
                diff: TimelineEntry.DiffSummary(added: entry.added, deleted: entry.deleted),
                commitSHA: entry.sha
            ))
        }
        
        return entries
    }
}

// MARK: - Local Save Entry

/// Represents a local save event tracked in the timeline
struct LocalSaveEntry: Identifiable, Hashable, Sendable {
    let id: UUID
    let timestamp: Date
    let filePath: String
    
    init(id: UUID = UUID(), timestamp: Date = Date(), filePath: String) {
        self.id = id
        self.timestamp = timestamp
        self.filePath = filePath
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let fileSaved = Notification.Name("com.codepad.fileSaved")
}

// MARK: - View Model

@MainActor
final class TimelineViewModel: ObservableObject {
    enum SourceFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case git = "Git"
        case local = "Local"

        var id: String { rawValue }

        func includes(_ source: TimelineEntry.Source) -> Bool {
            switch self {
            case .all: return true
            case .git: return source == .git
            case .local: return source == .local
            }
        }
    }

    @Published var filter: SourceFilter = .all
    @Published private(set) var entries: [TimelineEntry] = []
    @Published private(set) var isLoading: Bool = false
    @Published var localSaves: [LocalSaveEntry] = []

    private let provider: any TimelineProviding
    private let filePath: String?
    private let workingDirectory: String?
    private var cancellables = Set<AnyCancellable>()

    init(filePath: String? = nil, workingDirectory: String? = nil, provider: (any TimelineProviding)? = nil) {
        self.filePath = filePath
        self.workingDirectory = workingDirectory
        // Default to GitTimelineProvider for real git data
        self.provider = provider ?? GitTimelineProvider()
        
        // Listen for file save notifications
        NotificationCenter.default.publisher(for: .fileSaved)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let savedPath = notification.userInfo?["filePath"] as? String {
                    self.recordLocalSave(filePath: savedPath)
                }
            }
            .store(in: &cancellables)
    }
    
    /// Record a local save event
    func recordLocalSave(filePath: String) {
        let save = LocalSaveEntry(filePath: filePath)
        localSaves.append(save)
        
        // Also add to entries if this is the file we're tracking
        if self.filePath == filePath || self.filePath == nil {
            let entry = TimelineEntry(
                timestamp: save.timestamp,
                source: .local,
                author: "This iPad",
                message: "Saved",
                diff: nil,
                commitSHA: nil
            )
            entries.insert(entry, at: 0)
        }
    }

    var filteredEntries: [TimelineEntry] {
        entries
            .filter { filter.includes($0.source) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        // Fetch git entries
        var allEntries = await provider.timelineEntries(for: filePath, workingDirectory: workingDirectory)
        
        // Add local saves for this file
        if let path = filePath {
            let localEntries = localSaves
                .filter { $0.filePath == path }
                .map { save in
                    TimelineEntry(
                        timestamp: save.timestamp,
                        source: .local,
                        author: "This iPad",
                        message: "Saved",
                        diff: nil,
                        commitSHA: nil
                    )
                }
            allEntries.append(contentsOf: localEntries)
        } else {
            // No specific file - show all local saves
            let localEntries = localSaves.map { save in
                TimelineEntry(
                    timestamp: save.timestamp,
                    source: .local,
                    author: "This iPad",
                    message: "Saved \(save.filePath)",
                    diff: nil,
                    commitSHA: nil
                )
            }
            allEntries.append(contentsOf: localEntries)
        }
        
        entries = allEntries
    }
    
    func refresh() async {
        await load()
    }
}

// MARK: - Timeline View

/// VS Code-style Timeline panel: shows file history and allows filtering by source.
struct TimelineView: View {
    @StateObject private var viewModel: TimelineViewModel

    init(filePath: String? = nil, workingDirectory: String? = nil, provider: (any TimelineProviding)? = nil) {
        _viewModel = StateObject(wrappedValue: TimelineViewModel(filePath: filePath, workingDirectory: workingDirectory, provider: provider))
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if viewModel.isLoading {
                loading
            } else if viewModel.filteredEntries.isEmpty {
                empty
            } else {
                list
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 12) {
            Text("Timeline")
                .font(.headline)

            Spacer()
            
            // Refresh button
            Button {
                Task {
                    await viewModel.refresh()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Refresh timeline")

            Picker("Source", selection: $viewModel.filter) {
                ForEach(TimelineViewModel.SourceFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 200)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }

    // MARK: Content

    private var list: some View {
        List {
            ForEach(viewModel.filteredEntries) { entry in
                TimelineRow(entry: entry)
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            }
        }
        .listStyle(.plain)
    }

    private var loading: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading history…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        .background(Color(.systemBackground))
    }

    private var empty: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("No timeline entries")
                .font(.headline)
            Text("Try changing the filter or select a file with history.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        .background(Color(.systemBackground))
    }
}

// MARK: - Row

private struct TimelineRow: View {
    let entry: TimelineEntry

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            sourceIcon

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(entry.message)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Spacer(minLength: 8)

                    if let diff = entry.diff, !diff.isEmpty {
                        DiffBadge(diff: diff)
                    }
                    
                    if let sha = entry.commitSHA {
                        Text(String(sha.prefix(7)))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(Color(.tertiaryLabel))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.quaternarySystemFill))
                            .cornerRadius(4)
                    }
                }

                HStack(spacing: 8) {
                    Text(entry.author)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(Self.timestampFormatter.string(from: entry.timestamp))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text(entry.source.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Timeline entry: \(entry.message). By \(entry.author). \(entry.source.label). \(Self.timestampFormatter.string(from: entry.timestamp))")
        .accessibilityHint("Timeline entry")
        // Future: selection / open diff action hook.
    }

    private var sourceIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(entry.source.tint.opacity(0.12))
                .frame(width: 28, height: 28)

            Image(systemName: entry.source.systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(entry.source.tint)
        }
        .padding(.top, 2)
        .accessibilityHidden(true)
    }

    private static let timestampFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
}

private struct DiffBadge: View {
    let diff: TimelineEntry.DiffSummary

    var body: some View {
        Text(diff.text)
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.tertiarySystemFill))
            )
            .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var parts: [String] = []
        if diff.added > 0 { parts.append("\(diff.added) added") }
        if diff.deleted > 0 { parts.append("\(diff.deleted) deleted") }
        return parts.isEmpty ? "No changes" : parts.joined(separator: ", ")
    }
}

// MARK: - Previews

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            // Preview with mock data using a custom provider
            TimelineView(filePath: "test.swift", workingDirectory: nil, provider: PreviewTimelineProvider())
        }
        .frame(width: 420, height: 600)
        .previewDisplayName("With Preview Data")
        
        // Preview with real git (will show empty if no repo/SSH)
        TimelineView()
            .frame(width: 420, height: 600)
            .previewDisplayName("With Git (Empty)")
    }
}

// MARK: - Preview Provider

/// Preview provider for SwiftUI previews only
private struct PreviewTimelineProvider: TimelineProviding {
    func timelineEntries(for filePath: String?, workingDirectory: String?) async -> [TimelineEntry] {
        let now = Date()
        return [
            TimelineEntry(
                timestamp: now.addingTimeInterval(-60 * 5),
                source: .local,
                author: "This iPad",
                message: "Saved",
                diff: .init(added: 2, deleted: 0)
            ),
            TimelineEntry(
                timestamp: now.addingTimeInterval(-60 * 22),
                source: .local,
                author: "This iPad",
                message: "Auto Save",
                diff: .init(added: 0, deleted: 1)
            ),
            TimelineEntry(
                timestamp: now.addingTimeInterval(-60 * 60 * 3),
                source: .git,
                author: "alex",
                message: "Fix layout for timeline rows",
                diff: .init(added: 18, deleted: 6),
                commitSHA: "abc123def456"
            ),
            TimelineEntry(
                timestamp: now.addingTimeInterval(-60 * 60 * 8),
                source: .git,
                author: "alex",
                message: "Add Timeline panel skeleton",
                diff: .init(added: 124, deleted: 0),
                commitSHA: "def456abc789"
            ),
            TimelineEntry(
                timestamp: now.addingTimeInterval(-60 * 60 * 24),
                source: .git,
                author: "sam",
                message: "Initial commit",
                diff: .init(added: 980, deleted: 0),
                commitSHA: "123456789abc"
            )
        ]
    }
}
