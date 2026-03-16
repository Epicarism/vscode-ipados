import SwiftUI

// MARK: - Output Line View

/// Renders a single output line with ANSI color support and stream type styling
struct OutputLineView: View {
    let line: OutputLine
    let showTimestamp: Bool
    let wordWrap: Bool
    
    @State private var attributedString: AttributedString?
    
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            // Stream type indicator
            streamTypeIndicator
            
            // Timestamp (if enabled)
            if showTimestamp {
                timestampView
            }
            
            // Content with ANSI color support
            contentView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .id(line.id)
    }
    
    @ViewBuilder
    private var streamTypeIndicator: some View {
        switch line.streamType {
        case .stdout:
            Image(systemName: "arrow.right")
                .font(.system(size: 8))
                .foregroundColor(.blue)
                .frame(width: 12)
                .accessibilityHidden(true)
        case .stderr:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 8))
                .foregroundColor(.orange)
                .frame(width: 12)
                .accessibilityHidden(true)
        }
    }
    
    @ViewBuilder
    private var timestampView: some View {
        Text(formatTimestamp(line.timestamp))
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if line.isAnsiFormatted, let attributes = line.ansiAttributes {
            // Render with ANSI colors
            ansiAttributedText(attributes: attributes)
        } else {
            // Plain text with stream type color
            Text(line.text)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(textColor)
                .lineLimit(wordWrap ? nil : 1)
        }
    }
    
    private var textColor: Color {
        switch line.streamType {
        case .stdout: return .primary
        case .stderr: return .orange
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    /// Creates SwiftUI AttributedString from ANSI attributes
    private func ansiAttributedText(attributes: [NSRange: [NSAttributedString.Key: Any]]) -> some View {
        var result = AttributedString(line.text)
        
        for (range, attrs) in attributes {
            guard let swiftRange = Range(range, in: line.text) else { continue }
            guard let lowerBound = AttributedString.Index(swiftRange.lowerBound, within: result),
                  let upperBound = AttributedString.Index(swiftRange.upperBound, within: result) else { continue }
            let attrRange = lowerBound..<upperBound
            
            var container = AttributeContainer()
            
            if let color = attrs[.foregroundColor] as? Color {
                container.foregroundColor = color
            }
            if let bgColor = attrs[.backgroundColor] as? Color {
                container.backgroundColor = bgColor
            }
            if let font = attrs[.font] as? Font {
                container.font = font
            }
            
            result[attrRange].setAttributes(container)
        }
        
        return Text(result)
            .font(.system(size: 12, design: .monospaced))
            .lineLimit(wordWrap ? nil : 1)
    }
}

// MARK: - Progress Indicator View

struct RemoteProgressView: View {
    @ObservedObject var outputManager = OutputPanelManager.shared
    
    var body: some View {
        if outputManager.remoteExecutionStatus.isRunning {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
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
                        
                        if let startTime = outputManager.remoteExecutionStatus.startTime {
                            Text("Running for \(Int(Date().timeIntervalSince(startTime)))s")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Cancel action would go here
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
            .background(Color.purple.opacity(0.1))
            .overlay(
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.purple)
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
    @ObservedObject var outputManager = OutputPanelManager.shared
    @State private var localQuery: String = ""
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            
            TextField("Search output...", text: $localQuery)
                .font(.system(size: 12))
                .textFieldStyle(.plain)
                .accessibilityLabel("Search output")
                .onChange(of: localQuery) { newValue in
                    outputManager.setSearchQuery(newValue)
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
                    .foregroundColor(.secondary)
                    .accessibilityLabel("\(stats.filtered) of \(stats.total) output lines visible")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(6)
    }
}

// MARK: - Main Output View

struct OutputView: View {
    @ObservedObject private var outputManager = OutputPanelManager.shared
    @State private var showingSearchBar: Bool = false

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
            
            // Optional search bar
            if showingSearchBar {
                searchBarSection
                Divider()
            }
            
            // Output content
            outputBody
        }
        .background(Color(UIColor.systemBackground))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Output panel")
    }

    private var header: some View {
        HStack(spacing: 12) {
            // Channel selector
            Menu {
                ForEach(OutputChannel.allCases) { channel in
                    Button(action: {
                        outputManager.selectedChannel = channel
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
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(UIColor.tertiarySystemFill))
                .cornerRadius(4)
            }
            .accessibilityLabel("Output channel: \(outputManager.selectedChannel.rawValue)")
            .accessibilityHint("Double tap to select an output channel")
            
            Spacer()
            
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
                    .foregroundColor(showingSearchBar ? .blue : .secondary)
            }
            .accessibilityLabel("Search in output")
            .accessibilityHint("Double tap to \(showingSearchBar ? "hide" : "show") the output search bar")
            
            // Word wrap toggle
            Button(action: {
                outputManager.toggleWordWrap()
            }) {
                Image(systemName: outputManager.wordWrapEnabled ? "text.wrap" : "text.badge.xmark")
                    .font(.system(size: 12))
                    .foregroundColor(outputManager.wordWrapEnabled ? .blue : .secondary)
            }
            .accessibilityLabel("Toggle word wrap, currently \(outputManager.wordWrapEnabled ? "on" : "off")")
            .accessibilityHint("Double tap to toggle word wrap")
            
            // Timestamp toggle
            Button(action: {
                outputManager.toggleTimestamps()
            }) {
                Image(systemName: outputManager.showTimestamps ? "clock.fill" : "clock")
                    .font(.system(size: 12))
                    .foregroundColor(outputManager.showTimestamps ? .blue : .secondary)
            }
            .accessibilityLabel("Toggle timestamps, currently \(outputManager.showTimestamps ? "on" : "off")")
            .accessibilityHint("Double tap to show or hide timestamps")
            
            // Auto-scroll toggle
            Button(action: {
                outputManager.toggleAutoScroll()
            }) {
                Image(systemName: outputManager.isAutoScrollEnabled ? "lock.open.fill" : "lock")
                    .font(.system(size: 12))
                    .foregroundColor(outputManager.isAutoScrollEnabled ? .blue : .secondary)
            }
            .accessibilityLabel("Toggle auto-scroll, currently \(outputManager.isAutoScrollEnabled ? "on" : "off")")
            .accessibilityHint("Double tap to toggle auto-scroll to latest output")
            
            Divider()
                .frame(height: 16)
                .accessibilityHidden(true)
            
            // Clear button
            Button(action: { outputManager.clear(outputManager.selectedChannel) }) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .accessibilityLabel("Clear output")
            .accessibilityHint("Double tap to clear all output in the current channel")
        }
        .padding(6)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private var searchBarSection: some View {
        HStack {
            OutputSearchBar()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(UIColor.secondarySystemBackground))
    }

    private var outputBody: some View {
        let channel = outputManager.selectedChannel
        let lines = outputManager.lines(for: channel)

        return ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(lines) { line in
                        OutputLineView(
                            line: line,
                            showTimestamp: outputManager.showTimestamps,
                            wordWrap: outputManager.wordWrapEnabled
                        )
                        .padding(.vertical, 1)
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: lines.count) { _ in
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

// MARK: - Preview

#Preview {
    OutputView()
        .frame(height: 400)
}
