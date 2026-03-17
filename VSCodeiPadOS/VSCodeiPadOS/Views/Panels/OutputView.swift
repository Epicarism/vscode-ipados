import SwiftUI

// MARK: - Output Line View

/// Renders a single output line with log level colors and ANSI support
struct OutputLineView: View {
    let line: OutputLine
    let showTimestamp: Bool
    let wordWrap: Bool
    let theme: Theme

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            // Log level indicator
            logLevelIndicator
            
            // Timestamp (if enabled)
            if showTimestamp {
                timestampView
            }
            
            // Content with ANSI color support
            contentView
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .id(line.id)
    }
    
    @ViewBuilder
    private var logLevelIndicator: some View {
        Image(systemName: line.logLevel.icon)
            .font(.system(size: 9))
            .foregroundColor(line.logLevel.color)
            .frame(width: 14)
            .accessibilityHidden(true)
    }
    
    @ViewBuilder
    private var timestampView: some View {
        Text(formatTimestamp(line.timestamp))
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(.secondary.opacity(0.7))
            .frame(minWidth: 65)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let attributes = line.ansiAttributes, !attributes.isEmpty {
            // Render with ANSI colors
            ansiAttributedText(attributes: attributes)
        } else {
            // Plain text with log level color
            Text(line.text)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(textColor)
                .lineLimit(wordWrap ? nil : 1)
        }
    }
    
    private var textColor: Color {
        switch line.logLevel {
        case .error: return theme.errorForeground
        case .warning: return theme.warningForeground
        case .debug: return theme.comment
        case .info: return theme.editorForeground
        }
    }
    
    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    private func formatTimestamp(_ date: Date) -> String {
        Self.timestampFormatter.string(from: date)
    }
    
    /// Creates SwiftUI AttributedString from ANSI attributes
    private func ansiAttributedText(attributes: [NSRange: [NSAttributedString.Key: Any]]) -> some View {
        // Start with the default monospaced font and theme foreground color
        let defaultFont = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        
        var result = AttributedString(line.text)
        // Set the base style for the entire string so unstyled portions use theme colors
        result.font = .init(defaultFont)
        result.foregroundColor = theme.editorForeground
        
        for (range, attrs) in attributes {
            guard let swiftRange = Range(range, in: line.text) else { continue }
            guard let lowerBound = AttributedString.Index(swiftRange.lowerBound, within: result),
                  let upperBound = AttributedString.Index(swiftRange.upperBound, within: result) else { continue }
            let attrRange = lowerBound..<upperBound
            
            var container = AttributeContainer()
            
            // Only override color if the ANSI sequence explicitly set one
            if let uiColor = attrs[.foregroundColor] as? UIColor {
                container.foregroundColor = Color(uiColor)
            }
            if let uiBgColor = attrs[.backgroundColor] as? UIColor {
                container.backgroundColor = Color(uiBgColor)
            }
            // Preserve custom fonts (e.g. bold from ANSI SGR code 1)
            if let uiFont = attrs[.font] as? UIFont {
                container.font = Font(uiFont)
            }
            // Apply underline style if present
            if let underlineRaw = attrs[.underlineStyle] as? Int {
                container.underlineStyle = NSUnderlineStyle(rawValue: underlineRaw)
            }
            
            result[attrRange].mergeAttributes(container, mergePolicy: .keepNew)
        }
        
        return Text(result)
            .lineLimit(wordWrap ? nil : 1)
    }
}

// MARK: - Progress Indicator View

struct RemoteProgressView: View {
    @StateObject var outputManager = OutputPanelManager.shared
    
    var body: some View {
        if outputManager.remoteExecutionStatus.isRunning {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemPurple)))
                        .scaleEffect(0.8)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if let command = outputManager.remoteExecutionStatus.command {
                            Text(command)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        
                        if let message = outputManager.remoteExecutionStatus.progressMessage {
                            Text(message)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        SwiftUI.TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            if let startTime = outputManager.remoteExecutionStatus.startTime {
                                Text("Running for \(Int(context.date.timeIntervalSince(startTime)))s")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        NotificationCenter.default.post(name: .cancelRemoteExecution, object: nil)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Cancel remote execution")
                    .accessibilityHint("Double tap to cancel the running remote command")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(Color(UIColor.systemPurple).opacity(0.1))
            .overlay(
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(UIColor.systemPurple))
                        .frame(width: 3)
                    Spacer()
                }
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Remote execution in progress")
        }
    }
}

// MARK: - Search Bar View

struct OutputSearchBar: View {
    @StateObject var outputManager = OutputPanelManager.shared
    @StateObject var themeManager = ThemeManager.shared
    @State private var localQuery: String = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            
            TextField("Search output...", text: $localQuery)
                .font(.system(size: 12))
                .textFieldStyle(.plain)
                .focused($isSearchFocused)
                .accessibilityLabel("Search output")
                .onChange(of: localQuery) { _, newValue in
                    outputManager.setSearchQuery(newValue)
                }
                .onAppear {
                    localQuery = outputManager.searchQuery
                }
            
            if !localQuery.isEmpty {
                Button(action: {
                    localQuery = ""
                    outputManager.clearFilter()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
                .accessibilityHint("Double tap to clear the search text and reset filter")
            }
            
            let stats = outputManager.filterStats(for: outputManager.selectedChannel)
            if stats.filtered != stats.total {
                Text("\(stats.filtered)/\(stats.total)")
                    .font(.system(size: 10))
                    .monospacedDigit()
                    .foregroundColor(.secondary)
                    .accessibilityLabel("\(stats.filtered) of \(stats.total) output lines visible")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(themeManager.currentTheme.tabBarBackground)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Log Level Filter View

struct LogLevelFilterView: View {
    @StateObject var outputManager = OutputPanelManager.shared
    @StateObject var themeManager = ThemeManager.shared
    var body: some View {
        HStack(spacing: 8) {
            Text("Filter:")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            ForEach(LogLevel.allCases) { level in
                let counts = outputManager.logLevelCounts(for: outputManager.selectedChannel)
                let count = counts[level] ?? 0
                let isSelected = outputManager.selectedLogLevels.contains(level)
                
                Button(action: {
                    outputManager.toggleLogLevel(level)
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: level.icon)
                            .font(.system(size: 8))
                        Text("\(count)")
                            .font(.system(size: 10, weight: .medium))
                            .monospacedDigit()
                    }
                    .foregroundColor(isSelected ? level.color : .secondary.opacity(0.5))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        isSelected ? level.color.opacity(0.15) : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .disabled(count == 0)
                .accessibilityLabel("\(level.rawValue): \(count) entries")
                .accessibilityHint(isSelected ? "Double tap to hide" : "Double tap to show")
            }
            
            if outputManager.selectedLogLevels.count != LogLevel.allCases.count {
                Button(action: {
                    outputManager.resetLogLevelFilters()
                }) {
                    Text("Reset")
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.currentTheme.keyword)
                }
                .accessibilityLabel("Reset log level filters")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State View

private struct OutputEmptyStateView: View {
    let channel: OutputChannel
    let isFiltered: Bool
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 36))
                .foregroundColor(theme.comment.opacity(0.6))
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(theme.editorForeground.opacity(0.6))
            
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(theme.comment.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var iconName: String {
        if isFiltered {
            return "magnifyingglass"
        }
        switch channel {
        case .output: return "terminal"
        case .javascript: return "chevron.left.forwardslash.chevron.right"
        case .python: return "number"
        case .remote: return "network"
        case .debug: return "ladybug"
        }
    }
    
    private var title: String {
        if isFiltered {
            return "No matching output"
        }
        return "No output yet"
    }
    
    private var subtitle: String {
        if isFiltered {
            return "Try adjusting your search or log level filter"
        }
        return "Output from \(channel.rawValue) tasks will appear here"
    }
}

// MARK: - Main Output View

struct OutputView: View {
    @StateObject private var outputManager = OutputPanelManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingSearchBar: Bool = false
    @State private var showingLogLevelFilter: Bool = false
    @State private var showCopyConfirmation: Bool = false
    @State private var copyTask: Task<Void, Never>?

    private var theme: Theme { themeManager.currentTheme }
    
    /// Whether the current view is actively filtered
    private var isFiltered: Bool {
        !outputManager.searchQuery.isEmpty ||
        outputManager.selectedLogLevels.count != LogLevel.allCases.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Remote execution progress indicator
            if outputManager.selectedChannel == .remote {
                RemoteProgressView()
                Divider()
            }
            
            // Main header with controls
            header
            
            Divider()
            
            // Optional log level filter
            if showingLogLevelFilter {
                LogLevelFilterView()
                Divider()
            }
            
            // Optional search bar
            if showingSearchBar {
                searchBarSection
                Divider()
            }
            
            // Output content
            outputBody
        }
        .background(theme.editorBackground)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Output panel")
        .onReceive(NotificationCenter.default.publisher(for: .cancelRemoteExecution)) { _ in
            outputManager.finishRemoteExecution(exitMessage: "[Execution cancelled by user]")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            // Channel selector
            Menu {
                ForEach(OutputChannel.allCases) { channel in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            outputManager.selectedChannel = channel
                        }
                    }) {
                        HStack {
                            Image(systemName: channel.icon)
                            Text(channel.rawValue)
                            Spacer()
                            if outputManager.selectedChannel == channel {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10))
                            }
                        }
                    }
                    .accessibilityLabel(channel.rawValue)
                    .accessibilityHint("Double tap to switch to \(channel.rawValue) output")
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: outputManager.selectedChannel.icon)
                        .font(.system(size: 10))
                        .foregroundColor(outputManager.selectedChannel.color)
                    Text(outputManager.selectedChannel.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(theme.editorForeground)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                        .foregroundColor(theme.comment)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(theme.tabBarBackground)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .accessibilityLabel("Output channel: \(outputManager.selectedChannel.rawValue)")
            .accessibilityHint("Double tap to select an output channel")
            
            Spacer()
            
            // Filter toggle
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    showingLogLevelFilter.toggle()
                }
            }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 12))
                    .foregroundColor(showingLogLevelFilter ? theme.keyword : theme.comment)
            }
            .accessibilityLabel("Log level filter")
            .accessibilityHint("Double tap to \(showingLogLevelFilter ? "hide" : "show") log level filter")
            
            // Search toggle
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    showingSearchBar.toggle()
                    if !showingSearchBar {
                        outputManager.clearFilter()
                    }
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(showingSearchBar ? theme.keyword : theme.comment)
            }
            .accessibilityLabel("Search in output")
            .accessibilityHint("Double tap to \(showingSearchBar ? "hide" : "show") the output search bar")
            
            // Word wrap toggle
            Button(action: {
                outputManager.toggleWordWrap()
            }) {
                Image(systemName: outputManager.wordWrapEnabled ? "text.wrap" : "text.badge.xmark")
                    .font(.system(size: 12))
                    .foregroundColor(outputManager.wordWrapEnabled ? theme.keyword : theme.comment)
            }
            .accessibilityLabel("Toggle word wrap, currently \(outputManager.wordWrapEnabled ? "on" : "off")")
            .accessibilityHint("Double tap to toggle word wrap")
            
            // Timestamp toggle
            Button(action: {
                outputManager.toggleTimestamps()
            }) {
                Image(systemName: outputManager.showTimestamps ? "clock.fill" : "clock")
                    .font(.system(size: 12))
                    .foregroundColor(outputManager.showTimestamps ? theme.keyword : theme.comment)
            }
            .accessibilityLabel("Toggle timestamps, currently \(outputManager.showTimestamps ? "on" : "off")")
            .accessibilityHint("Double tap to show or hide timestamps")
            
            // Auto-scroll toggle
            Button(action: {
                outputManager.toggleAutoScroll()
            }) {
                Image(systemName: outputManager.isAutoScrollEnabled ? "arrow.down.circle.fill" : "arrow.down.circle")
                    .font(.system(size: 12))
                    .foregroundColor(outputManager.isAutoScrollEnabled ? theme.keyword : theme.comment)
            }
            .accessibilityLabel("Toggle auto-scroll, currently \(outputManager.isAutoScrollEnabled ? "on" : "off")")
            .accessibilityHint("Double tap to toggle auto-scroll to latest output")
            
            Divider()
                .frame(height: 16)
                .accessibilityHidden(true)
            
            // Copy button
            Button(action: {
                outputManager.copyToClipboard(channel: outputManager.selectedChannel)
                showCopyConfirmation = true
                copyTask?.cancel()
                copyTask = Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    if !Task.isCancelled {
                        showCopyConfirmation = false
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: showCopyConfirmation ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundColor(showCopyConfirmation ? Color(UIColor.systemGreen) : theme.comment)
                    if showCopyConfirmation {
                        Text("Copied")
                            .font(.system(size: 10))
                            .foregroundColor(Color(UIColor.systemGreen))
                    }
                }
            }
            .accessibilityLabel("Copy output")
            .accessibilityHint("Double tap to copy all output to clipboard")
            
            // Clear button
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.2)) {
                    outputManager.clear(outputManager.selectedChannel)
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
            }
            .accessibilityLabel("Clear output")
            .accessibilityHint("Double tap to clear all output in the current channel")
        }
        .padding(6)
        .background(theme.tabBarBackground)
    }
    
    private var searchBarSection: some View {
        HStack {
            OutputSearchBar()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(theme.tabBarBackground)
    }

    private var outputBody: some View {
        let channel = outputManager.selectedChannel
        let lines = outputManager.lines(for: channel)

        return Group {
            if lines.isEmpty {
                OutputEmptyStateView(
                    channel: channel,
                    isFiltered: isFiltered,
                    theme: theme
                )
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 1) {
                            ForEach(lines) { line in
                                OutputLineView(
                                    line: line,
                                    showTimestamp: outputManager.showTimestamps,
                                    wordWrap: outputManager.wordWrapEnabled,
                                    theme: theme
                                )
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: lines.count) { _, _ in
                        guard !lines.isEmpty && outputManager.isAutoScrollEnabled else { return }
                        withAnimation(.easeOut(duration: 0.1)) {
                            if let lastLine = lines.last {
                                proxy.scrollTo(lastLine.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .background(theme.editorBackground)
    }
}

// MARK: - Preview

#Preview {
    OutputView()
        .frame(height: 400)
}
