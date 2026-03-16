//
//  VSCodeTunnelView.swift
//  VSCodeiPadOS
//
//  Connected Mode: Full VS Code experience via tunnel/code-server
//  Real folding, git, terminal, extensions - everything.
//

import SwiftUI
import WebKit

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
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
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
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: VSCodeWebView
        
        init(_ parent: VSCodeWebView) {
            self.parent = parent
        }
        
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
