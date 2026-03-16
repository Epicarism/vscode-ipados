import Foundation
import SwiftUI

// MARK: - Output Types

/// Stream type for output lines
enum StreamType {
    case stdout
    case stderr
}

/// Output channel categories
enum OutputChannel: String, CaseIterable, Identifiable {
    case output = "Output"
    case javascript = "JavaScript"
    case python = "Python"
    case remote = "Remote"
    case debug = "Debug"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .output: return "terminal"
        case .javascript: return "js"
        case .python: return "snake"
        case .remote: return "network"
        case .debug: return "ladybug"
        }
    }

    var color: Color {
        switch self {
        case .output: return .primary
        case .javascript: return .yellow
        case .python: return .blue
        case .remote: return .purple
        case .debug: return .green
        }
    }
}

// MARK: - Log Level

/// Log level for output lines
enum LogLevel: String, CaseIterable, Identifiable {
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
    case debug = "Debug"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        case .debug: return "ant"
        }
    }

    var color: Color {
        switch self {
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .debug: return .secondary
        }
    }
}

// MARK: - Output Line

/// A single output line with metadata
struct OutputLine: Identifiable {
    let id: UUID
    let text: String
    let logLevel: LogLevel
    let streamType: StreamType
    let timestamp: Date
    let isAnsiFormatted: Bool
    let ansiAttributes: [NSRange: [NSAttributedString.Key: Any]]?

    init(
        text: String,
        logLevel: LogLevel = .info,
        streamType: StreamType = .stdout,
        timestamp: Date = Date(),
        isAnsiFormatted: Bool = false,
        ansiAttributes: [NSRange: [NSAttributedString.Key: Any]]? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.logLevel = logLevel
        self.streamType = streamType
        self.timestamp = timestamp
        self.isAnsiFormatted = isAnsiFormatted
        self.ansiAttributes = ansiAttributes
    }
}

// MARK: - Remote Execution Status

/// Tracks the state of remote execution for progress indication
struct RemoteExecutionStatus: Equatable {
    let isRunning: Bool
    let command: String?
    let startTime: Date?
    let progressMessage: String?

    static let idle = RemoteExecutionStatus(isRunning: false, command: nil, startTime: nil, progressMessage: nil)
}

// MARK: - Output Panel Manager

/// Manages output panel state: channels, lines, filtering, and settings.
@MainActor
final class OutputPanelManager: ObservableObject {
    static let shared = OutputPanelManager()

    // MARK: - Published Properties

    @Published var selectedChannel: OutputChannel = .output
    @Published var isAutoScrollEnabled: Bool = true
    @Published var showTimestamps: Bool = false
    @Published var wordWrapEnabled: Bool = true
    @Published var searchQuery: String = ""
    @Published private(set) var remoteExecutionStatus: RemoteExecutionStatus = .idle

    /// Which log levels are visible in the filter
    @Published var selectedLogLevels: Set<LogLevel> = Set(LogLevel.allCases)

    // MARK: - Storage

    private var outputLines: [OutputChannel: [OutputLine]] = [
        .output: [],
        .javascript: [],
        .python: [],
        .remote: [],
        .debug: []
    ]

    // MARK: - Init

    private init() {}

    // MARK: - Append / Clear

    /// Append a block of text to a channel, splitting on newlines
    func append(_ text: String, to channel: OutputChannel, streamType: StreamType = .stdout) {
        let lines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)

        for line in lines {
            appendLine(line, to: channel, streamType: streamType)
        }
    }

    /// Append a single line to a channel
    func appendLine(_ line: String, to channel: OutputChannel, streamType: StreamType = .stdout) {
        let logLevel: LogLevel = inferLogLevel(from: line, streamType: streamType)

        let outputLine = OutputLine(
            text: line,
            logLevel: logLevel,
            streamType: streamType,
            timestamp: Date()
        )

        var current = outputLines[channel] ?? []
        current.append(outputLine)
        outputLines[channel] = current
    }

    /// Clear all lines in a channel
    func clear(_ channel: OutputChannel) {
        outputLines[channel] = []
    }

    // MARK: - Remote Execution

    func startRemoteExecution(command: String) {
        remoteExecutionStatus = RemoteExecutionStatus(
            isRunning: true,
            command: command,
            startTime: Date(),
            progressMessage: "Running: \(command)"
        )
        clear(.remote)
        selectedChannel = .remote
    }

    func finishRemoteExecution(exitMessage: String? = nil) {
        if let message = exitMessage {
            appendLine(message, to: .remote)
        }
        remoteExecutionStatus = .idle
    }

    func updateProgressMessage(_ message: String) {
        guard remoteExecutionStatus.isRunning else { return }
        remoteExecutionStatus = RemoteExecutionStatus(
            isRunning: true,
            command: remoteExecutionStatus.command,
            startTime: remoteExecutionStatus.startTime,
            progressMessage: message
        )
    }

    // MARK: - Filtering

    /// Get lines for a channel, filtered by search query and log level
    func lines(for channel: OutputChannel) -> [OutputLine] {
        let lines = outputLines[channel] ?? []

        let filtered = lines.filter { line in
            // Log level filter
            guard selectedLogLevels.contains(line.logLevel) else { return false }

            // Search query filter
            guard searchQuery.isEmpty || line.text.lowercased().contains(searchQuery.lowercased()) else { return false }

            return true
        }

        return filtered
    }

    /// Get log level counts for a channel (unfiltered by log level, but filtered by search)
    func logLevelCounts(for channel: OutputChannel) -> [LogLevel: Int] {
        let lines = outputLines[channel] ?? []
        var counts: [LogLevel: Int] = [:]

        let searchFiltered = lines.filter { line in
            searchQuery.isEmpty || line.text.lowercased().contains(searchQuery.lowercased())
        }

        for line in searchFiltered {
            counts[line.logLevel, default: 0] += 1
        }

        return counts
    }

    /// Get filter stats
    func filterStats(for channel: OutputChannel) -> (filtered: Int, total: Int) {
        let total = outputLines[channel]?.count ?? 0
        let filtered = lines(for: channel).count
        return (filtered, total)
    }

    // MARK: - Settings Toggles

    func toggleAutoScroll() {
        isAutoScrollEnabled.toggle()
    }

    func toggleTimestamps() {
        showTimestamps.toggle()
    }

    func toggleWordWrap() {
        wordWrapEnabled.toggle()
    }

    func setSearchQuery(_ query: String) {
        searchQuery = query
    }

    func clearFilter() {
        searchQuery = ""
    }

    // MARK: - Log Level Filter

    func toggleLogLevel(_ level: LogLevel) {
        if selectedLogLevels.contains(level) {
            selectedLogLevels.remove(level)
        } else {
            selectedLogLevels.insert(level)
        }
    }

    func resetLogLevelFilters() {
        selectedLogLevels = Set(LogLevel.allCases)
    }

    // MARK: - Clipboard

    func copyToClipboard(channel: OutputChannel) {
        let allText = (outputLines[channel] ?? []).map { $0.text }.joined(separator: "\n")
        UIPasteboard.general.string = allText
    }

    // MARK: - Private Helpers

    private func inferLogLevel(from text: String, streamType: StreamType) -> LogLevel {
        if streamType == .stderr {
            return .error
        }
        let lower = text.lowercased()
        if lower.contains("[error]") || lower.contains("[exception]") || lower.contains("error:") {
            return .error
        }
        if lower.contains("[warn]") || lower.contains("[warning]") || lower.contains("warning:") {
            return .warning
        }
        if lower.contains("[debug]") || lower.contains("debug:") {
            return .debug
        }
        return .info
    }
}
