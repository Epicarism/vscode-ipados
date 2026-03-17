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
    
    var body: some View {
        Group {
            if let config = tunnelManager.activeConfig, tunnelManager.isConnected {
                connectedView(config: config)
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
            if let url = URL(string: config.url) {
                VSCodeWebView(
                    url: url,
                    isLoading: $isLoading,
                    errorMessage: $errorMessage
                )
                .ignoresSafeArea()
            }
            
            // Loading overlay
            if isLoading {
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
            
            // Error overlay
            if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text("Connection Failed")
                        .font(.headline)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Disconnect") {
                        tunnelManager.disconnect()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(themeManager.currentTheme.editorBackground)
            }
            
            // Disconnect button (top-left corner)
            VStack {
                HStack {
                    Button(action: { tunnelManager.disconnect() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Exit")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                    
                    Spacer()
                }
                Spacer()
            }
        }
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
