import SwiftUI
import Foundation

// MARK: - Timeline Models

/// Represents a single change in a file's history (Git commit, local save, etc.).
struct TimelineEntry: Identifiable, Hashable {
    enum Source: String, CaseIterable, Hashable {
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

    struct DiffSummary: Hashable {
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

    init(
        id: UUID = UUID(),
        timestamp: Date,
        source: Source,
        author: String,
        message: String,
        diff: DiffSummary? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.source = source
        self.author = author
        self.message = message
        self.diff = diff
    }
}

// MARK: - Provider (structure for future Git integration)

/// Abstraction point for later wiring to real Git history / local save tracking.
protocol TimelineProviding {
    /// - Parameter filePath: A workspace-relative file path (or identifier) to fetch history for.
    func timelineEntries(for filePath: String?) async -> [TimelineEntry]
}

/// Mock provider used for now.
struct MockTimelineProvider: TimelineProviding {
    func timelineEntries(for filePath: String?) async -> [TimelineEntry] {
        let now = Date()
        // NOTE: Mock data only. Replace with real Git + local-save sources later.
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
                diff: .init(added: 18, deleted: 6)
            ),
            TimelineEntry(
                timestamp: now.addingTimeInterval(-60 * 60 * 8),
                source: .git,
                author: "alex",
                message: "Add Timeline panel skeleton",
                diff: .init(added: 124, deleted: 0)
            ),
            TimelineEntry(
                timestamp: now.addingTimeInterval(-60 * 60 * 24),
                source: .git,
                author: "sam",
                message: "Initial commit",
                diff: .init(added: 980, deleted: 0)
            )
        ]
    }
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

    private let provider: any TimelineProviding
    private let filePath: String?

    init(filePath: String? = nil, provider: any TimelineProviding = MockTimelineProvider()) {
        self.filePath = filePath
        self.provider = provider
    }

    var filteredEntries: [TimelineEntry] {
        entries
            .filter { filter.includes($0.source) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        entries = await provider.timelineEntries(for: filePath)
    }
}

// MARK: - Timeline View

/// VS Code-style Timeline panel: shows file history and allows filtering by source.
struct TimelineView: View {
    @StateObject private var viewModel: TimelineViewModel

    init(filePath: String? = nil, provider: any TimelineProviding = MockTimelineProvider()) {
        _viewModel = StateObject(wrappedValue: TimelineViewModel(filePath: filePath, provider: provider))
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

            Picker("Source", selection: $viewModel.filter) {
                ForEach(TimelineViewModel.SourceFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 320)
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
        TimelineView()
            .frame(width: 420, height: 600)
    }
}
