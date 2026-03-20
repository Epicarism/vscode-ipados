//
//  VSCodeTunnelView.swift
//  VSCodeiPadOS
//
//  Connected Mode: Full VS Code experience via tunnel/code-server
//  Real folding, git, terminal, extensions - everything.
//

import SwiftUI
import WebKit
import os

private let logger = Logger(subsystem: "com.codepad.app", category: "VSCodeWebView")

// MARK: - WebView Wrapper

struct VSCodeWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @Binding var needsReload: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // Allow inline media playback (for terminal)
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Enable JavaScript
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // Persist cookies and storage across sessions
        config.websiteDataStore = .default()
        
        // Add JS console capture handler
        let contentController = config.userContentController
        contentController.add(context.coordinator, name: "consoleLog")
        contentController.add(context.coordinator, name: "consoleError")
        contentController.add(context.coordinator, name: "consoleWarn")
        
        // Inject console capture script
        let consoleScript = WKUserScript(
            source: """
            (function() {
                var origLog = console.log;
                var origError = console.error;
                var origWarn = console.warn;
                console.log = function() {
                    origLog.apply(console, arguments);
                    window.webkit.messageHandlers.consoleLog.postMessage(Array.from(arguments).map(String).join(' '));
                };
                console.error = function() {
                    origError.apply(console, arguments);
                    window.webkit.messageHandlers.consoleError.postMessage(Array.from(arguments).map(String).join(' '));
                };
                console.warn = function() {
                    origWarn.apply(console, arguments);
                    window.webkit.messageHandlers.consoleWarn.postMessage(Array.from(arguments).map(String).join(' '));
                };
                window.onerror = function(msg, url, line, col, error) {
                    window.webkit.messageHandlers.consoleError.postMessage('JS Error: ' + msg + ' at ' + url + ':' + line);
                };
                window.onunhandledrejection = function(event) {
                    window.webkit.messageHandlers.consoleError.postMessage('Unhandled Promise: ' + event.reason);
                };
            })();
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        contentController.addUserScript(consoleScript)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        
        // Custom user agent to identify as desktop for best experience
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        
        // Load the URL
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only reload if URL changed
        if webView.url != url {
            webView.load(URLRequest(url: url))
        }
        // Handle explicit reload request from parent
        if needsReload {
            webView.reload()
            DispatchQueue.main.async {
                self.needsReload = false
            }
        }
    }
    
    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "consoleLog")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "consoleError")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "consoleWarn")
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: VSCodeWebView
        
        init(_ parent: VSCodeWebView) {
            self.parent = parent
        }
        
        // MARK: - WKScriptMessageHandler
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? String else { return }
            switch message.name {
            case "consoleLog":
                logger.debug("[WebView] \(body)")
            case "consoleError":
                logger.error("[WebView] \(body)")
            case "consoleWarn":
                logger.warning("[WebView] \(body)")
            default:
                break
            }
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.errorMessage = nil
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.errorMessage = error.localizedDescription
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.errorMessage = error.localizedDescription
        }
        
        // MARK: - WKUIDelegate
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async {
            logger.info("[WebView Alert] \(message)")
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: nil,
                        message: message,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        continuation.resume()
                    })
                    Self.topmostViewController(from: webView).present(alert, animated: true)
                }
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async -> Bool {
            logger.info("[WebView Confirm] \(message)")
            return await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: nil,
                        message: message,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                        continuation.resume(returning: false)
                    })
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        continuation.resume(returning: true)
                    })
                    Self.topmostViewController(from: webView).present(alert, animated: true)
                }
            }
        }
        
        private static func topmostViewController(from webView: WKWebView) -> UIViewController {
            let root: UIViewController?
            if let windowRoot = webView.window?.rootViewController {
                root = windowRoot
            } else {
                root = UIApplication.shared.connectedScenes
                    .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
                    .first
            }
            var presenter = root ?? UIViewController()
            while let presented = presenter.presentedViewController {
                presenter = presented
            }
            return presenter
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Handle popup windows by loading in the same webview
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

// MARK: - Main Connected Mode View

struct VSCodeTunnelView: View {
    @StateObject var tunnelManager = TunnelManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAddTunnel = false
    @State private var webViewNeedsReload = false
    @State private var reloadToken = UUID()
    
    var body: some View {
        Group {
            if let config = tunnelManager.activeConfig {
                switch tunnelManager.connectionState {
                case .connected, .reconnecting:
                    connectedView(config: config)
                case .connecting:
                    connectingView(config: config)
                case .error(let message):
                    errorView(message: message, config: config)
                case .disconnected:
                    disconnectedView
                }
            } else {
                disconnectedView
            }
        }
        .overlay(alignment: .bottom) {
            // Connection state banner
            if case .reconnecting(let attempt) = tunnelManager.connectionState {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Reconnecting (\(attempt)/3)...")
                        .font(.caption)
                        .accessibilityLabel("Reconnecting, attempt \(attempt) of 3")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - Connected View (WebView)
    
    @ViewBuilder
    private func connectedView(config: TunnelConfig) -> some View {
        ZStack {
            // FIX: Prefer tunnelManager.webViewURL (resolved URL after SSH/port-forward)
            // Fall back to config.url if webViewURL not yet set
            let resolvedURL = tunnelManager.webViewURL ?? URL(string: config.url)
            if let url = resolvedURL {
                if config.tunnelMode == .webview {
                    // Enhanced tunnel WebView with iPad bridge
                    TunnelWebView(url: url)
                        .id(reloadToken)
                        .ignoresSafeArea()
                } else {
                    // Legacy WebView
                    VSCodeWebView(
                        url: url,
                        isLoading: $isLoading,
                        errorMessage: $errorMessage,
                        needsReload: $webViewNeedsReload
                    )
                    .ignoresSafeArea()
                }
            }
            
            // Loading overlay — show for legacy WebView (isLoading) or
            // for .webview mode when tunnel state is still .connecting
            let showLoading = isLoading || (config.tunnelMode == .webview && tunnelManager.connectionState == .connecting)
            if showLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Connecting to \(config.name)...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(themeManager.currentTheme.editorBackground.opacity(0.9))
            }
            
            // Error overlay — show for legacy WebView or tunnel-level errors
            let displayError = errorMessage ?? tunnelManager.lastError
            if let error = displayError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text("Connection Failed")
                        .font(.headline)
                        .accessibilityLabel("Connection failed")
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .accessibilityLabel("Error: \(error)")
                    
                    Button("Disconnect") {
                        tunnelManager.disconnect()
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Disconnect from server")
                    .accessibilityHint("Returns to the server list")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(themeManager.currentTheme.editorBackground)
            }
            
            // ── Glove Mode native toolbar ──────────────────────────────────────
            VStack(spacing: 0) {
                gloveModeToolbar(config: config)
                Spacer()
            }
        }
    }
    
    // MARK: - Glove Mode Native Toolbar

    @ViewBuilder
    private func gloveModeToolbar(config: TunnelConfig) -> some View {
        HStack(spacing: 12) {

            // ── Connection status dot ──────────────────────────────────────────
            HStack(spacing: 6) {
                Circle()
                    .fill(connectionDotColor)
                    .frame(width: 8, height: 8)
                    .shadow(color: connectionDotColor.opacity(0.6), radius: 3)
                    .accessibilityHidden(true)

                Text(config.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Divider()
                .frame(height: 14)

            // ── Current file name (from tunnelEditorState) ────────────────────
            HStack(spacing: 4) {
                if let state = tunnelManager.tunnelEditorState, !state.fileName.isEmpty {
                    if state.isDirty {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 6, height: 6)
                            .accessibilityLabel("Unsaved changes")
                    }
                    Text(state.fileName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text("Ln \(state.cursorLine), Col \(state.cursorColumn)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                    if !state.language.isEmpty {
                        Text(state.language)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(.quaternary, in: Capsule())
                    }
                } else {
                    Text("No file open")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // ── Settings gear ─────────────────────────────────────────────────
            Button(action: {
                // Reserved for native settings panel
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
            .accessibilityHint("Opens VS Code settings")

            // ── Reload ────────────────────────────────────────────────────────
            Button(action: { reloadToken = UUID(); webViewNeedsReload = true }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reload VS Code")
            .accessibilityHint("Reloads the VS Code web view")

            // ── Disconnect ────────────────────────────────────────────────────
            Button(action: { tunnelManager.disconnect() }) {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                    Text("Disconnect")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.red.opacity(0.85))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.red.opacity(0.10), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Disconnect from \(config.name)")
            .accessibilityHint("Closes the VS Code session and returns to the server list")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.4)
        }
    }

    /// The colour of the connection-status dot in the glove mode toolbar.
    private var connectionDotColor: Color {
        switch tunnelManager.connectionState {
        case .connected:              return .green
        case .connecting:             return .yellow
        case .reconnecting:           return .orange
        case .disconnected, .error:   return .red
        }
    }

    // MARK: - Connecting View
    
    private func connectingView(config: TunnelConfig) -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Connecting to \(config.name)...")
                .font(.headline)
            Text("Validating server connection")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Cancel") {
                tunnelManager.disconnect()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Error View
    
    private func errorView(message: String, config: TunnelConfig) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
            Text("Connection Failed")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                Button("Retry") {
                    tunnelManager.connect(to: config)
                }
                .buttonStyle(.borderedProminent)
                Button("Disconnect") {
                    tunnelManager.disconnect()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Disconnected View (Server List)
    
    private var disconnectedView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Connected Mode")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Connect to VS Code Server for full IDE features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { showingAddTunnel = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .accessibilityLabel("Add server")
                .accessibilityHint("Configure a new VS Code tunnel, code-server, or Codespace")
            }
            .padding()
            .background(themeManager.currentTheme.sidebarBackground)
            
            Divider()
            
            if tunnelManager.configs.isEmpty {
                emptyStateView
            } else {
                serverListView
            }
        }
        .background(themeManager.currentTheme.editorBackground)
        .sheet(isPresented: $showingAddTunnel) {
            AddTunnelSheet()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "server.rack")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Servers Configured")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Add a VS Code tunnel, code-server, or\nGitHub Codespace to get started.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddTunnel = true }) {
                Label("Add Server", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Add server")
            .accessibilityHint("Configure a new VS Code tunnel, code-server, or Codespace")
            
            Spacer()
            
            // Help text
            VStack(alignment: .leading, spacing: 12) {
                helpItem(icon: "bolt.fill", title: "VS Code Tunnel", description: "Run `code tunnel` on your machine")
                helpItem(icon: "server.rack", title: "code-server", description: "Self-hosted VS Code in browser")
                helpItem(icon: "cloud.fill", title: "Codespaces", description: "GitHub's cloud dev environments")
            }
            .padding()
            .background(themeManager.currentTheme.sidebarBackground.opacity(0.5))
            .cornerRadius(12)
            .padding()
        }
    }
    
    private func helpItem(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var serverListView: some View {
        List {
            ForEach(tunnelManager.configs) { config in
                Button(action: { tunnelManager.connect(to: config) }) {
                    HStack(spacing: 12) {
                        Image(systemName: config.type.icon)
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(config.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(config.url)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            if let lastUsed = config.lastUsed {
                                Text("Last used: \(lastUsed.formatted(.relative(presentation: .named)))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Connect to \(config.name)")
                .accessibilityHint("Opens \(config.url) in the VS Code web view")
            }
            .onDelete { indexSet in
                for index in indexSet {
                    tunnelManager.removeConfig(tunnelManager.configs[index])
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Preview

#Preview {
    VSCodeTunnelView()
        .environmentObject(ThemeManager.shared)
}
