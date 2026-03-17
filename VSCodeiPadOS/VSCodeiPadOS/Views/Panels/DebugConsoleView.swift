import SwiftUI
import UIKit

// MARK: - Debug Console Entry View

struct DebugConsoleEntryView: View {
    let entry: DebugManager.ConsoleEntry
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var isExpanded: Bool = false
    
    private var theme: Theme { themeManager.currentTheme }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top, spacing: 6) {
                // Prefix/icon
                Text(entry.prefix)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(prefixColor)
                    .frame(width: 18, alignment: .leading)
                
                // Main content
                VStack(alignment: .leading, spacing: 4) {
                    if entry.kind == .error {
                        // Errors get a subtle background highlight
                        Text(entry.text)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(color(for: entry.kind))
                            .textSelection(.enabled)
                            .lineLimit(isExpanded ? nil : 10)
                            .padding(4)
                            .background(theme.selection.opacity(0.15))
                            .cornerRadius(3)
                    } else {
                        Text(entry.text)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(color(for: entry.kind))
                            .textSelection(.enabled)
                            .lineLimit(isExpanded ? nil : 10)
                    }
                    
                    // Show expand button if text is long
                    if entry.text.count > 200 {
                        Button(action: { isExpanded.toggle() }) {
                            Text(isExpanded ? "Show less" : "Show more...")
                                .font(.system(size: 10))
                                .foregroundColor(theme.infoForeground)
                        }
                    }
                    
                    // Timestamp for non-input entries
                    if entry.kind != .input {
                        Text(formatTimestamp(entry.timestamp))
                            .font(.system(size: 9))
                            .foregroundColor(theme.comment.opacity(0.6))
                    }
                }
                
                Spacer(minLength: 0)
            }
            .id(entry.id)
        }
        .padding(.vertical, 2)
    }
    
    private var prefixColor: Color {
        switch entry.kind {
        case .input: return theme.keyword
        case .output: return theme.comment
        case .error: return theme.errorForeground
        case .warning: return theme.warningForeground
        case .info: return theme.infoForeground
        case .system: return theme.comment.opacity(0.7)
        }
    }
    
    private func color(for kind: DebugManager.ConsoleEntry.Kind) -> Color {
        switch kind {
        case .input:
            return theme.editorForeground
        case .output:
            return theme.editorForeground.opacity(0.9)
        case .error:
            return theme.errorForeground
        case .warning:
            return theme.warningForeground
        case .info:
            return theme.infoForeground
        case .system:
            return theme.comment
        }
    }
    
    private static let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()
    
    private func formatTimestamp(_ date: Date) -> String {
        Self.timestampFormatter.string(from: date)
    }
}

// MARK: - Debug Console View

/// Debug Console (REPL-style) panel with enhanced debugging features.
struct DebugConsoleView: View {
    @ObservedObject private var debugManager = DebugManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var input: String = ""
    @State private var commandHistory: [String] = []
    @State private var historyIndex: Int = -1
    @FocusState private var isInputFocused: Bool
    @State private var isAutoScrollEnabled = true


    private var theme: Theme { themeManager.currentTheme }

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        if debugManager.consoleEntries.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 6) {
                                    Text("Debug Console")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(theme.comment)
                                    Text("Type expressions to evaluate, or type \"help\" for commands.")
                                        .font(.system(size: 11))
                                        .foregroundColor(theme.comment.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 40)
                                Spacer()
                            }
                        }

                        ForEach(debugManager.consoleEntries) { entry in
                            DebugConsoleEntryView(entry: entry)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(theme.editorBackground)
                .onChange(of: debugManager.consoleEntries.count) { _, _ in
                    if isAutoScrollEnabled, let last = debugManager.consoleEntries.last {
                        withAnimation(.easeOut(duration: 0.12)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }

                }
            }

            Divider()

            inputBar
        }
        .background(theme.editorBackground)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("DEBUG CONSOLE")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(theme.tabActiveForeground)
            
            // Status indicator
            if debugManager.state == .running || debugManager.state == .paused {
                HStack(spacing: 4) {
                    Circle()
                        .fill(debugManager.state == .running ? Color(UIColor.systemGreen) : Color(UIColor.systemOrange))
                        .frame(width: 6, height: 6)
                    Text(debugManager.state.displayName)
                        .font(.system(size: 10))
                        .foregroundColor(theme.comment)
                }
            }

            Spacer()
            
            // Entry count
            if !debugManager.consoleEntries.isEmpty {
                Text("\(debugManager.consoleEntries.count) entries")
                    .font(.system(size: 10))
                    .foregroundColor(theme.comment)
            }

            Button {
                isAutoScrollEnabled.toggle()
            } label: {
                Image(systemName: isAutoScrollEnabled ? "arrow.down.circle.fill" : "arrow.down.circle")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
            }
            .buttonStyle(.plain)
            .help(isAutoScrollEnabled ? "Auto-scroll On" : "Auto-scroll Off")


            Button {
                debugManager.copyConsoleToClipboard()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
            }
            .buttonStyle(.plain)
            .help("Copy Console")

            Button(role: .destructive) {
                debugManager.clearConsole()
                commandHistory.removeAll()
                historyIndex = -1
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(theme.comment)
            }
            .buttonStyle(.plain)
            .help("Clear")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(theme.tabBarBackground)
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            // Quick evaluation buttons (visible when paused)
            if debugManager.state == .paused {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        Text("Quick eval:")
                            .font(.system(size: 10))
                            .foregroundColor(theme.comment)
                        
                        ForEach(debugManager.remoteDebugger != nil ? ["frame", "args", "locals", "registers"] : ["this", "arguments", "locals", "globals"], id: \.self) { expr in
                            Button(action: {
                                input = expr
                                submit()
                            }) {
                                Text(expr)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(theme.keyword)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(theme.selection)
                                    .cornerRadius(3)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .background(theme.editorBackground.opacity(0.5))
                
                Divider()
            }
            
            // Input field
            HStack(spacing: 8) {
                Text(">")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(theme.keyword)

                TextField("Evaluate expression…", text: $input)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(theme.editorForeground)
                    .accentColor(theme.cursor)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isInputFocused)
                    .onSubmit {
                        submit()
                    }
                    .onAppear {
                        isInputFocused = true
                    }

                // History navigation buttons
                if !commandHistory.isEmpty {
                    HStack(spacing: 4) {
                        Button(action: navigateHistoryUp) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 10))
                                .foregroundColor(theme.comment)
                        }
                        .disabled(historyIndex >= commandHistory.count - 1)
                        
                        Button(action: navigateHistoryDown) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(theme.comment)
                        }
                        .disabled(historyIndex < 0)
                    }
                }
                
                Button("Run") {
                    submit()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(theme.tabBarBackground)
        }
    }

    private func submit() {
        let expr = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !expr.isEmpty else { return }
        
        // Add to history
        commandHistory.insert(expr, at: 0)
        if commandHistory.count > 50 {
            commandHistory.removeLast()
        }
        historyIndex = -1
        
        // Submit to debug manager
        debugManager.submitConsole(input: expr)
        input = ""
        
        // Keep focus on input
        isInputFocused = true
    }
    
    private func navigateHistoryUp() {
        guard !commandHistory.isEmpty else { return }
        if historyIndex < commandHistory.count - 1 {
            historyIndex += 1
            input = commandHistory[historyIndex]
        }
    }
    
    private func navigateHistoryDown() {
        if historyIndex > 0 {
            historyIndex -= 1
            input = commandHistory[historyIndex]
        } else if historyIndex == 0 {
            historyIndex = -1
            input = ""
        }
    }
}

#Preview {
    DebugConsoleView()
}
