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
        case .javascript: return "curlybraces"
        case .python: return "chevron.left.forwardslash.chevron.right"
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

// MARK: - ANSI Parser

/// Parses ANSI escape codes from text and extracts color attributes
enum ANSIParser {
    /// ANSI escape sequence pattern: ESC [ ... m
    private static let ansiPattern = "\\x1B\\[[0-9;]*m"
    
    /// Check if text contains ANSI escape codes
    static func containsANSICodes(_ text: String) -> Bool {
        return text.contains("\u{1B}[")
    }
    
    /// Strip ANSI escape codes from text
    static func stripANSICodes(from text: String) -> String {
        guard containsANSICodes(text) else { return text }
        return text.replacingOccurrences(
            of: ansiPattern,
            with: "",
            options: .regularExpression
        )
    }
    
    /// Parse ANSI codes and return stripped text with color attributes
    static func parseANSI(_ text: String) -> (strippedText: String, attributes: [NSRange: [NSAttributedString.Key: Any]]) {
        guard containsANSICodes(text) else {
            return (text, [:])
        }
        
        var attributes: [NSRange: [NSAttributedString.Key: Any]] = [:]
        var strippedText = ""
        var currentAttrs: [NSAttributedString.Key: Any] = [:]
        var scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil
        
        while !scanner.isAtEnd {
            // Scan up to escape character
            if let plainText = scanner.scanUpToString("\u{1B}") {
                let startIndex = strippedText.count
                strippedText += plainText
                if !currentAttrs.isEmpty {
                    let range = NSRange(location: startIndex, length: plainText.count)
                    attributes[range] = currentAttrs
                }
            }
            
            // Check if we have an escape sequence
            if scanner.scanString("\u{1B}") != nil {
                if scanner.scanString("[") != nil {
                    // Parse CSI sequence
                    var codeString = ""
                    while !scanner.isAtEnd {
                        if let char = scanner.scanCharacter(), char.isNumber || char == ";" {
                            codeString.append(char)
                        } else {
                            // End of sequence (should be 'm' for SGR)
                            break
                        }
                    }
                    
                    // Parse SGR codes
                    let codes = codeString.split(separator: ";").compactMap { Int($0) }
                    currentAttrs = parseSGRCodes(codes, currentAttrs: currentAttrs)
                }
            } else if !scanner.isAtEnd {
                // No escape found, take rest of string
                let remaining = String(text[scanner.currentIndex...])
                let startIndex = strippedText.count
                strippedText += remaining
                if !currentAttrs.isEmpty {
                    let range = NSRange(location: startIndex, length: remaining.count)
                    attributes[range] = currentAttrs
                }
                break
            }
        }
        
        return (strippedText, attributes)
    }
    
    /// Parse SGR (Select Graphic Rendition) codes into attributes
    private static func parseSGRCodes(_ codes: [Int], currentAttrs: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attrs = currentAttrs
        
        for code in codes {
            switch code {
            case 0: // Reset
                attrs = [:]
            case 1: // Bold
                attrs[.font] = UIFont.boldSystemFont(ofSize: 12)
            case 4: // Underline
                attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
            case 30: attrs[.foregroundColor] = UIColor.black
            case 31: attrs[.foregroundColor] = UIColor.red
            case 32: attrs[.foregroundColor] = UIColor.green
            case 33: attrs[.foregroundColor] = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Yellow/Orange
            case 34: attrs[.foregroundColor] = UIColor.blue
            case 35: attrs[.foregroundColor] = UIColor.magenta
            case 36: attrs[.foregroundColor] = UIColor.cyan
            case 37: attrs[.foregroundColor] = UIColor.white
            case 90: attrs[.foregroundColor] = UIColor.darkGray // Bright black
            case 91: attrs[.foregroundColor] = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0) // Bright red
            case 92: attrs[.foregroundColor] = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0) // Bright green
            case 93: attrs[.foregroundColor] = UIColor(red: 1.0, green: 1.0, blue: 0.4, alpha: 1.0) // Bright yellow
            case 94: attrs[.foregroundColor] = UIColor(red: 0.4, green: 0.4, blue: 1.0, alpha: 1.0) // Bright blue
            case 95: attrs[.foregroundColor] = UIColor(red: 1.0, green: 0.4, blue: 1.0, alpha: 1.0) // Bright magenta
            case 96: attrs[.foregroundColor] = UIColor(red: 0.4, green: 1.0, blue: 1.0, alpha: 1.0) // Bright cyan
            case 97: attrs[.foregroundColor] = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // Bright white
            case 40: attrs[.backgroundColor] = UIColor.black
            case 41: attrs[.backgroundColor] = UIColor.red
            case 42: attrs[.backgroundColor] = UIColor.green
            case 43: attrs[.backgroundColor] = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Yellow bg
            case 44: attrs[.backgroundColor] = UIColor.blue
            case 45: attrs[.backgroundColor] = UIColor.magenta
            case 46: attrs[.backgroundColor] = UIColor.cyan
            case 47: attrs[.backgroundColor] = UIColor.white
            default: break
            }
        }
        
        return attrs
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

    /// Maximum lines per channel to prevent unbounded memory growth
    private let maxLinesPerChannel = 5000

    private var outputLines: [OutputChannel: [OutputLine]] = [
        .output: [],
        .javascript: [],
        .python: [],
        .remote: [],
        .debug: []
    ]

    /// Counter that increments on every mutation to trigger SwiftUI updates
    @Published private var _lineUpdateCounter: Int = 0

    /// Notify SwiftUI that output content changed
    private func notifyLinesChanged() {
        _lineUpdateCounter += 1
    }

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
        // Parse ANSI codes if present
        let isAnsiFormatted = ANSIParser.containsANSICodes(line)
        let (strippedText, ansiAttributes) = isAnsiFormatted 
            ? ANSIParser.parseANSI(line)
            : (line, nil)
        
        // Infer log level from stripped text (avoids false positives from escape sequences)
        let effectiveLogLevel = inferLogLevel(from: isAnsiFormatted ? strippedText : line, streamType: streamType)
        
        let outputLine = OutputLine(
            text: strippedText,
            logLevel: effectiveLogLevel,
            streamType: streamType,
            timestamp: Date(),
            isAnsiFormatted: isAnsiFormatted && !(ansiAttributes?.isEmpty ?? true),
            ansiAttributes: ansiAttributes
        )

        var current = outputLines[channel] ?? []
        current.append(outputLine)

        // Enforce line limit to prevent unbounded memory growth
        if current.count > maxLinesPerChannel {
            current.removeFirst(current.count - maxLinesPerChannel)
        }

        outputLines[channel] = current
        notifyLinesChanged()
    }

    /// Clear all lines in a channel
    func clear(_ channel: OutputChannel) {
        outputLines[channel] = []
        notifyLinesChanged()
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
