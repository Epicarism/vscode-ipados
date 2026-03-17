//
//  SwiftTermView.swift
//  VSCodeiPadOS
//
//  SwiftTerm UIViewRepresentable wrapper for real terminal emulation
//

import SwiftUI
import UIKit

#if canImport(SwiftTerm)
import SwiftTerm

// MARK: - SwiftTerm UIViewRepresentable Wrapper

/// Wraps SwiftTerm's TerminalView for use in SwiftUI.
/// Provides a real VT100/xterm terminal emulator with proper cursor positioning,
/// ANSI escape handling, scrollback, and keyboard input.
struct SwiftTerminalView: UIViewRepresentable {
    @ObservedObject var terminalManager: TerminalManager
    var fontSize: CGFloat = 14
    var fontFamily: String = "Menlo"
    var theme: TerminalTheme = .default
    
    struct TerminalTheme {
        var foreground: UIColor
        var background: UIColor
        var cursor: UIColor
        
        static let `default` = TerminalTheme(
            foreground: .white,
            background: UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0),
            cursor: UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
        )
    }
    
    // MARK: - Coordinator
    
    @MainActor class Coordinator: NSObject, TerminalViewDelegate {
        var parent: SwiftTerminalView
        weak var terminalView: SwiftTerm.TerminalView?
        private nonisolated(unsafe) var sshOutputObserver: NSObjectProtocol?
        
        init(_ parent: SwiftTerminalView) {
            self.parent = parent
            super.init()
        }
        
        deinit {
            if let observer = sshOutputObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
        // MARK: - TerminalViewDelegate
        
        nonisolated func sizeChanged(source: SwiftTerm.TerminalView, newCols: Int, newRows: Int) {
            // Forward terminal size changes to SSH
            Task { @MainActor in
                try? await SSHManager.shared.resizeTerminal(cols: newCols, rows: newRows)
            }
        }
        
        nonisolated func setTerminalTitle(source: SwiftTerm.TerminalView, title: String) {
            let t = title
            Task { @MainActor [weak self] in
                self?.parent.terminalManager.title = t
            }
        }
        
        nonisolated func send(source: SwiftTerm.TerminalView, data: ArraySlice<UInt8>) {
            // Forward user keystrokes to SSH
            let bytes = Array(data)
            guard let str = String(bytes: bytes, encoding: .utf8), !str.isEmpty else {
                // Send raw bytes for non-UTF8 sequences
                let rawStr = bytes.map { String(format: "%c", $0) }.joined()
                Task { @MainActor in
                    SSHManager.shared.send(command: rawStr)
                }
                return
            }
            // Use sendInput for raw data (no newline appended)
            Task {
                try? await SSHManager.shared.sendInput(str)
            }
        }
        
        nonisolated func scrolled(source: SwiftTerm.TerminalView, position: Double) {
            // Could update UI scroll indicators if needed
        }
        
        nonisolated func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {
            // Could update terminal tab title with current directory
        }
        
        nonisolated func requestOpenLink(source: SwiftTerm.TerminalView, link: String, params: [String: String]) {
            if let url = URL(string: link) {
                Task { @MainActor in
                    UIApplication.shared.open(url)
                }
            }
        }
        
        nonisolated func rangeChanged(source: SwiftTerm.TerminalView, startY: Int, endY: Int) {
            // Selection range changed — could update copy state
        }
        
        nonisolated func clipboardCopy(source: SwiftTerm.TerminalView, content: Data) {
            Task { @MainActor in
                UIPasteboard.general.setData(content, forPasteboardType: "public.utf8-plain-text")
            }
        }
        
        // MARK: - SSH Data Feed
        
        /// Feed raw data from SSH into the terminal emulator
        func feedData(_ text: String) {
            guard let tv = terminalView else { return }
            let bytes = ArraySlice(Array(text.utf8))
            tv.feed(byteArray: bytes)
        }
        
        /// Feed raw bytes from SSH into the terminal emulator
        func feedBytes(_ data: Data) {
            guard let tv = terminalView else { return }
            let bytes = ArraySlice(Array(data))
            tv.feed(byteArray: bytes)
        }
        
        /// Set up observation of SSH output
        func setupSSHDataPipeline() {
            // The TerminalManager's SSHManagerDelegate methods will call
            // our feedData method when SSH output arrives.
            // We wire this up via the terminalManager's swiftTermFeed callback.
            parent.terminalManager.swiftTermFeedHandler = { [weak self] text in
                DispatchQueue.main.async {
                    self?.feedData(text)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> SwiftTerm.TerminalView {
        let tv = SwiftTerm.TerminalView(frame: .zero)
        tv.terminalDelegate = context.coordinator
        context.coordinator.terminalView = tv
        
        // Configure font
        let font = UIFont(name: fontFamily, size: fontSize)
            ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        tv.font = font
        
        // Configure colors
        tv.nativeForegroundColor = theme.foreground
        tv.nativeBackgroundColor = theme.background
        tv.backgroundColor = theme.background
        
        // Setup SSH data pipeline
        context.coordinator.setupSSHDataPipeline()
        
        // Show welcome message if not connected
        if !terminalManager.isConnected {
            let welcome = "\u{1b}[1;36m" + // Bold cyan
                "CodePad Terminal\r\n" +
                "\u{1b}[0m" + // Reset
                "Type 'ssh' to connect to a remote server, or use the built-in commands.\r\n" +
                "\r\n$ "
            let bytes = ArraySlice(Array(welcome.utf8))
            tv.feed(byteArray: bytes)
        }
        
        return tv
    }
    
    func updateUIView(_ uiView: SwiftTerm.TerminalView, context: Context) {
        // Update font if changed
        let font = UIFont(name: fontFamily, size: fontSize)
            ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        if uiView.font != font {
            uiView.font = font
        }
        
        // Update colors if theme changed
        if uiView.nativeForegroundColor != theme.foreground {
            uiView.nativeForegroundColor = theme.foreground
            uiView.nativeBackgroundColor = theme.background
            uiView.backgroundColor = theme.background
        }
    }
}

#else

// MARK: - Fallback when SwiftTerm is not available

/// Placeholder view shown when SwiftTerm package is not linked.
/// The app falls back to the built-in ScrollView-based terminal.
struct SwiftTerminalView: View {
    @ObservedObject var terminalManager: TerminalManager
    var fontSize: CGFloat = 14
    var fontFamily: String = "Menlo"
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "terminal")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("SwiftTerm not available")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(.gray)
            Text("Using built-in terminal renderer.")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray.opacity(0.7))
            Text("Add SwiftTerm SPM package for full terminal emulation.")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.gray.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)))
    }
}

#endif
