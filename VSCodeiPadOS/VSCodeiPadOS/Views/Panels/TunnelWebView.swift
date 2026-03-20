//
//  TunnelWebView.swift
//  VSCodeiPadOS
//
//  SwiftUI WebView wrapper for VS Code tunnel connections.
//  Provides a native WKWebView that loads vscode.dev / code-server
//  with a JavaScript bridge for native ↔ web communication.
//

import SwiftUI
import WebKit
import os

// MARK: - Weak Script Message Proxy

/// Prevents WKUserContentController → Coordinator retain cycle.
private class WeakScriptMessageProxy: NSObject, WKScriptMessageHandler {
    private weak var handler: WKScriptMessageHandler?
    
    init(handler: WKScriptMessageHandler) {
        self.handler = handler
        super.init()
    }
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        handler?.userContentController(userContentController, didReceive: message)
    }
}

// MARK: - Tunnel WebView

struct TunnelWebView: UIViewRepresentable {
    
    @ObservedObject var tunnelManager = TunnelManager.shared
    let url: URL
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "TunnelWebView")
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Enable clipboard access for VS Code
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        
        // WebSocket support for tunnel communication
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        // Data store — persist session across launches
        config.websiteDataStore = .default()
        
        // Add message handler via weak proxy (avoids retain cycle)
        let contentController = config.userContentController
        let proxy = WeakScriptMessageProxy(handler: context.coordinator)
        contentController.add(proxy, name: "vscodeBridge")
        
        // Inject bridge script
        let bridgeScript = WKUserScript(
            source: Self.bridgeJavaScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(bridgeScript)
        
        // Inject iPad-specific CSS overrides
        let cssScript = WKUserScript(
            source: Self.iPadCSSOverrides,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(cssScript)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
        
        // Store reference for JS evaluation
        context.coordinator.webView = webView
        
        // Load the tunnel URL
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webView.load(request)
        
        Self.logger.info("Loading tunnel URL: \(url.absoluteString)")
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only reload if URL actually changed
        if webView.url?.host != url.host || webView.url?.path != url.path {
            webView.load(URLRequest(url: url))
        }
    }
    
    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "vscodeBridge")
        webView.configuration.userContentController.removeAllUserScripts()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.stopLoading()
        coordinator.webView = nil
        logger.info("TunnelWebView dismantled")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(tunnelManager: tunnelManager)
    }
    
    // MARK: - Bridge JavaScript
    
    static var bridgeJavaScript: String {
        """
        (function() {
            'use strict';
            if (window.__iPadBridgeInjected) return;
            window.__iPadBridgeInjected = true;
            
            window.iPadBridge = {
                // Notify native side when a file is opened
                openFile: function(path) {
                    window.webkit.messageHandlers.vscodeBridge.postMessage({
                        type: 'openFile', path: path
                    });
                },
                
                // Save file content through native side
                saveFile: function(path, content) {
                    window.webkit.messageHandlers.vscodeBridge.postMessage({
                        type: 'saveFile', path: path, content: content
                    });
                },
                
                // Request native theme info
                getTheme: function() {
                    window.webkit.messageHandlers.vscodeBridge.postMessage({
                        type: 'getTheme'
                    });
                },
                
                // Report VS Code ready state
                reportReady: function() {
                    window.webkit.messageHandlers.vscodeBridge.postMessage({
                        type: 'ready'
                    });
                },
                
                // Report current editor state
                reportEditorState: function(state) {
                    window.webkit.messageHandlers.vscodeBridge.postMessage({
                        type: 'editorState',
                        state: state
                    });
                },
                
                // Execute VS Code command
                executeCommand: function(command, args) {
                    window.webkit.messageHandlers.vscodeBridge.postMessage({
                        type: 'command',
                        command: command,
                        args: args || []
                    });
                }
            };
            
            // Monitor VS Code ready state via DOM observation
            var readyObserver = new MutationObserver(function(mutations) {
                if (document.querySelector('.monaco-workbench')) {
                    window.iPadBridge.reportReady();
                    readyObserver.disconnect();
                    
                    // Monitor active editor changes
                    setupEditorMonitor();
                }
            });
            
            if (document.body) {
                readyObserver.observe(document.body, { childList: true, subtree: true });
            }
            
            // Check if already loaded
            if (document.querySelector('.monaco-workbench')) {
                window.iPadBridge.reportReady();
                setupEditorMonitor();
            }
            
            function setupEditorMonitor() {
                // Watch for active editor tab changes
                var tabObserver = new MutationObserver(function() {
                    var activeTab = document.querySelector('.tab.active .label-name');
                    if (activeTab) {
                        var title = activeTab.textContent || '';
                        window.iPadBridge.reportEditorState({
                            activeFile: title,
                            timestamp: Date.now()
                        });
                    }
                });
                
                var tabContainer = document.querySelector('.tabs-container');
                if (tabContainer) {
                    tabObserver.observe(tabContainer, {
                        childList: true, subtree: true, attributes: true,
                        attributeFilter: ['class']
                    });
                }
            }
            
            console.log('[iPadBridge] Bridge injected successfully');
        })();
        """
    }
    
    // MARK: - iPad CSS Overrides
    
    static var iPadCSSOverrides: String {
        """
        (function() {
            var style = document.createElement('style');
            style.id = 'ipad-overrides';
            style.textContent = `
                /* Smoother scrolling on iPad */
                .editor-scrollable {
                    -webkit-overflow-scrolling: touch !important;
                }
                
                /* Better touch targets in gutter */
                .monaco-editor .margin {
                    touch-action: none;
                    min-width: 44px;
                }
                
                /* Larger scrollbar for touch */
                .monaco-editor .decorationsOverviewRuler {
                    width: 14px !important;
                }
                
                /* Activity bar touch targets */
                .activitybar .action-item {
                    min-height: 44px;
                    min-width: 44px;
                }
                
                /* Better sidebar touch experience */
                .explorer-item {
                    min-height: 32px;
                    padding: 4px 0;
                }
                
                /* Prevent text selection issues on touch */
                .monaco-editor .view-overlays {
                    -webkit-user-select: none;
                }
                
                /* Hide elements not useful on iPad */
                .monaco-editor .minimap-shadow-visible {
                    display: none !important;
                }
            `;
            if (!document.getElementById('ipad-overrides')) {
                document.head.appendChild(style);
            }
        })();
        """
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        
        private static let logger = Logger(subsystem: "com.codepad.app", category: "TunnelWebViewCoordinator")
        
        var tunnelManager: TunnelManager
        weak var webView: WKWebView?
        private var loadStartTime: CFAbsoluteTime = 0
        
        init(tunnelManager: TunnelManager) {
            self.tunnelManager = tunnelManager
            super.init()
        }
        
        // MARK: - WKScriptMessageHandler
        
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard let body = message.body as? [String: Any],
                  let type = body["type"] as? String else {
                Self.logger.warning("Invalid bridge message format")
                return
            }
            
            Self.logger.debug("Bridge message: \(type)")
            
            switch type {
            case "ready":
                DispatchQueue.main.async { [weak self] in
                    self?.tunnelManager.isWebViewReady = true
                    Self.logger.info("VS Code WebView ready")
                }
                
            case "openFile":
                if let path = body["path"] as? String {
                    DispatchQueue.main.async { [weak self] in
                        self?.tunnelManager.currentRemoteFile = path
                    }
                }
                
            case "saveFile":
                if let path = body["path"] as? String,
                   let content = body["content"] as? String {
                    handleFileSave(path: path, content: content)
                }
                
            case "getTheme":
                sendThemeToWebView()
                
            case "editorState":
                if let state = body["state"] as? [String: Any],
                   let activeFile = state["activeFile"] as? String {
                    DispatchQueue.main.async { [weak self] in
                        self?.tunnelManager.currentRemoteFile = activeFile
                    }
                }
                
            case "command":
                if let command = body["command"] as? String {
                    Self.logger.info("VS Code command: \(command)")
                }
                
            default:
                Self.logger.warning("Unknown bridge message type: \(type)")
            }
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            loadStartTime = CFAbsoluteTimeGetCurrent()
            Self.logger.info("Navigation started")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let elapsed = CFAbsoluteTimeGetCurrent() - loadStartTime
            Self.logger.info("Navigation finished in \(String(format: "%.1f", elapsed))s")
        }
        
        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            Self.logger.error("Navigation failed: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.tunnelManager.lastError = "Navigation failed: \(error.localizedDescription)"
            }
        }
        
        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            Self.logger.error("Provisional navigation failed: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.tunnelManager.lastError = "Connection failed: \(error.localizedDescription)"
            }
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            // Allow all same-origin navigation; open external links in Safari
            if let requestURL = navigationAction.request.url,
               let currentHost = webView.url?.host,
               requestURL.host != currentHost,
               navigationAction.navigationType == .linkActivated {
                UIApplication.shared.open(requestURL)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
        
        func webView(
            _ webView: WKWebView,
            respondTo challenge: URLAuthenticationChallenge
        ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
            // Accept self-signed certificates for local tunnel servers
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
               let trust = challenge.protectionSpace.serverTrust {
                return (.useCredential, URLCredential(trust: trust))
            }
            return (.performDefaultHandling, nil)
        }
        
        // MARK: - WKUIDelegate
        
        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            Self.logger.info("JS Alert: \(message)")
            completionHandler()
        }
        
        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            completionHandler(true)
        }
        
        func webView(
            _ webView: WKWebView,
            runJavaScriptTextInputPanelWithPrompt prompt: String,
            defaultText: String?,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (String?) -> Void
        ) {
            completionHandler(defaultText)
        }
        
        // MARK: - Bridge Helpers
        
        private func handleFileSave(path: String, content: String) {
            Self.logger.info("Save file via bridge: \(path) (\(content.count) bytes)")
            Task {
                do {
                    guard let data = content.data(using: .utf8) else {
                        Self.logger.error("Failed to encode file content as UTF-8: \(path)")
                        return
                    }
                    try await TunnelFileSystemBridge.shared.writeFile(at: path, content: data)
                    Self.logger.info("File saved via tunnel bridge: \(path)")
                } catch {
                    Self.logger.error("Failed to save file via tunnel: \(path) — \(error.localizedDescription)")
                }
            }
        }
        
        private func sendThemeToWebView() {
            guard let webView = webView else { return }
            let isDark = UITraitCollection.current.userInterfaceStyle == .dark
            let theme = isDark ? "vs-dark" : "vs"
            let js = "document.body.setAttribute('data-vscode-theme-kind', '\(theme)');"
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    Self.logger.error("Failed to set theme: \(error.localizedDescription)")
                }
            }
        }
        
        // MARK: - Public JS Evaluation
        
        func executeVSCodeCommand(_ command: String, args: [String] = []) {
            guard let webView = webView else { return }
            let argsJSON = (try? JSONSerialization.data(withJSONObject: args))?.base64EncodedString() ?? "W10="
            let js = """
            (function() {
                try {
                    var args = JSON.parse(atob('\(argsJSON)'));
                    if (window.vscode && window.vscode.commands) {
                        window.vscode.commands.executeCommand('\(command)', ...args);
                    }
                } catch(e) { console.error('Command failed:', e); }
            })();
            """
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    Self.logger.error("Command '\(command)' failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Tunnel Connection View

struct TunnelConnectionView: View {
    
    @ObservedObject var tunnelManager = TunnelManager.shared
    let config: TunnelConfig
    
    var body: some View {
        Group {
            switch tunnelManager.connectionState {
            case .disconnected:
                disconnectedView
                
            case .connecting:
                connectingView
                
            case .connected:
                connectedView
                
            case .error(let message):
                errorView(message: message)
                
            case .reconnecting(let attempt):
                reconnectingView(attempt: attempt)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - State Views
    
    private var disconnectedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "network.slash")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            
            Text("Not Connected")
                .font(.title2.bold())
            
            Text("Connect to \(config.name) to start coding")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { tunnelManager.connect(to: config) }) {
                Label("Connect", systemImage: "bolt.fill")
                    .font(.headline)
                    .frame(minWidth: 160)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    private var connectingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.8)
            
            Text("Connecting to \(config.name)...")
                .font(.headline)
            
            Text(config.url)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding()
    }
    
    @ViewBuilder
    private var connectedView: some View {
        if let url = tunnelManager.buildTunnelURL(for: config) {
            ZStack(alignment: .top) {
                TunnelWebView(url: url)
                    .ignoresSafeArea()
                
                // Loading indicator while WebView initializes
                if !tunnelManager.isWebViewReady {
                    VStack {
                        ProgressView("Loading VS Code...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                    .transition(.opacity)
                }
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                Text("Invalid tunnel URL")
                    .font(.headline)
                Text(config.url)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundColor(.orange)
            
            Text("Connection Error")
                .font(.title2.bold())
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            HStack(spacing: 16) {
                Button("Retry") {
                    tunnelManager.connect(to: config)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Dismiss") {
                    tunnelManager.disconnect()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    private func reconnectingView(attempt: Int) -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Reconnecting...")
                .font(.headline)
            
            Text("Attempt \(attempt) of 3")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Preview

#if DEBUG
struct TunnelConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        TunnelConnectionView(
            config: TunnelConfig(
                name: "My MacBook",
                url: "https://vscode.dev/tunnel/macbook",
                type: .vscodeDevTunnel
            )
        )
        .preferredColorScheme(.dark)
    }
}
#endif
