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
        case .output: return "list.bullet.rectangle"
        case .javascript: return "curlybraces"
        case .python: return "chevron.left.forwardslash.chevron.right"
        case .remote: return "cloud"
        case .debug: return "ant.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .output: return .primary
        case .javascript: return .yellow
        case .python: return .blue
        case .remote: return .purple
        case .debug: return .orange
        }
    }
}

/// A single line of output
struct OutputLine: Identifiable {
    let id: UUID
    let text: String
    let timestamp: Date
    let streamType: StreamType
    let channel: OutputChannel
    var isAnsiFormatted: Bool = false
    var ansiAttributes: [NSRange: [NSAttributedString.Key: Any]]?
    
    init(
        text: String,
        streamType: StreamType = .stdout,
        channel: OutputChannel = .output,
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.text = text
        self.timestamp = timestamp
        self.streamType = streamType
        self.channel = channel
    }
}

/// Status of remote execution
struct RemoteExecutionStatus {
    var isRunning: Bool = false
    var command: String?
    var progressMessage: String?
    var startTime: Date?
}

// MARK: - OutputPanelManager

/// Manages output panel state and content for multiple channels
@MainActor
class OutputPanelManager: ObservableObject {
    static let shared = OutputPanelManager()
    
    // MARK: - Published Properties
    
    @Published var selectedChannel: OutputChannel = .output
    @Published var showTimestamps: Bool = false
    @Published var wordWrapEnabled: Bool = true
    @Published var isAutoScrollEnabled: Bool = true
    @Published var remoteExecutionStatus = RemoteExecutionStatus()
    
    // MARK: - Private Properties
    
    private var outputLines: [OutputChannel: [OutputLine]] = [:]
    private var searchQuery: String = ""
    
    // MARK: - Initialization
    
    private init() {
        // Initialize empty arrays for each channel
        for channel in OutputChannel.allCases {
            outputLines[channel] = []
        }
    }
    
    // MARK: - Public Methods
    
    /// Append a line to a channel
    func append(_ text: String, to channel: OutputChannel, streamType: StreamType = .stdout) {
        let line = OutputLine(text: text, streamType: streamType, channel: channel)
        outputLines[channel, default: []].append(line)
    }
    
    /// Append multiple lines
    func appendLines(_ lines: [String], to channel: OutputChannel, streamType: StreamType = .stdout) {
        for text in lines {
            append(text, to: channel, streamType: streamType)
        }
    }
    
    /// Get lines for a channel, optionally filtered
    func lines(for channel: OutputChannel) -> [OutputLine] {
        let allLines = outputLines[channel] ?? []
        if searchQuery.isEmpty {
            return allLines
        }
        return allLines.filter { $0.text.localizedCaseInsensitiveContains(searchQuery) }
    }
    
    /// Clear a specific channel
    func clear(_ channel: OutputChannel) {
        outputLines[channel] = []
    }
    
    /// Clear all channels
    func clearAll() {
        for channel in OutputChannel.allCases {
            outputLines[channel] = []
        }
    }
    
    /// Set search/filter query
    func setSearchQuery(_ query: String) {
        searchQuery = query
    }
    
    /// Clear the filter
    func clearFilter() {
        searchQuery = ""
    }
    
    /// Get filter stats
    func filterStats(for channel: OutputChannel) -> (filtered: Int, total: Int) {
        let allLines = outputLines[channel] ?? []
        let filteredLines = lines(for: channel)
        return (filteredLines.count, allLines.count)
    }
    
    /// Toggle word wrap
    func toggleWordWrap() {
        wordWrapEnabled.toggle()
    }
    
    /// Toggle timestamps
    func toggleTimestamps() {
        showTimestamps.toggle()
    }
    
    /// Toggle auto-scroll
    func toggleAutoScroll() {
        isAutoScrollEnabled.toggle()
    }
    
    // MARK: - Execution Status
    
    /// Start remote execution tracking
    func startExecution(command: String) {
        remoteExecutionStatus = RemoteExecutionStatus(
            isRunning: true,
            command: command,
            progressMessage: "Starting...",
            startTime: Date()
        )
    }
    
    /// Update execution progress
    func updateExecutionProgress(_ message: String) {
        remoteExecutionStatus.progressMessage = message
    }
    
    /// End execution tracking
    func endExecution() {
        remoteExecutionStatus = RemoteExecutionStatus()
    }
}
