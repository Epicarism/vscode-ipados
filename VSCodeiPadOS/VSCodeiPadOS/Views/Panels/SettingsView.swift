import SwiftUI
import os
import SwiftUI
import WebKit

// MARK: - Tunnel Configuration

struct TunnelConfig: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var url: String
    var type: TunnelType
    var lastUsed: Date?
    
    enum TunnelType: String, Codable, CaseIterable {
        case vscodeDevTunnel = "VS Code Tunnel"
        case codeServer = "code-server"
        case codespaces = "GitHub Codespaces"
        case custom = "Custom URL"
        
        var icon: String {
            switch self {
            case .vscodeDevTunnel: return "bolt.fill"
            case .codeServer: return "server.rack"
            case .codespaces: return "cloud.fill"
            case .custom: return "link"
            }
        }
        
        var placeholder: String {
            switch self {
            case .vscodeDevTunnel: return "https://vscode.dev/tunnel/machine-name"
            case .codeServer: return "https://your-server.com:8080"
            case .codespaces: return "https://codespace-name.github.dev"
            case .custom: return "https://..."
            }
        }
    }
}

// MARK: - Tunnel Manager

class TunnelManager: ObservableObject, @unchecked Sendable {
    nonisolated(unsafe) static let shared = TunnelManager()
    
    @Published var configs: [TunnelConfig] = []
    @Published var activeConfig: TunnelConfig?
    @Published var isConnected = false
    
    private let configsKey = "tunnelConfigs"
    private let activeConfigKey = "activeTunnelConfigId"
    
    private init() {
        loadConfigs()
    }
    
    func loadConfigs() {
        if let data = UserDefaults.standard.data(forKey: configsKey),
           let decoded = try? JSONDecoder().decode([TunnelConfig].self, from: data) {
            configs = decoded
        }
        
        if let activeId = UserDefaults.standard.string(forKey: activeConfigKey),
           let uuid = UUID(uuidString: activeId) {
            activeConfig = configs.first { $0.id == uuid }
        }
    }
    
    func saveConfigs() {
        if let encoded = try? JSONEncoder().encode(configs) {
            UserDefaults.standard.set(encoded, forKey: configsKey)
        }
    }
    
    func addConfig(_ config: TunnelConfig) {
        configs.append(config)
        saveConfigs()
    }
    
    func removeConfig(_ config: TunnelConfig) {
        configs.removeAll { $0.id == config.id }
        if activeConfig?.id == config.id {
            activeConfig = nil
            isConnected = false
        }
        saveConfigs()
    }
    
    func connect(to config: TunnelConfig) {
        var updatedConfig = config
        updatedConfig.lastUsed = Date()
        
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = updatedConfig
            saveConfigs()
        }
        
        activeConfig = updatedConfig
        UserDefaults.standard.set(config.id.uuidString, forKey: activeConfigKey)
        isConnected = true
    }
    
    func disconnect() {
        isConnected = false
    }
}

// MARK: - Add Tunnel Sheet

struct AddTunnelSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var tunnelManager = TunnelManager.shared
    
    @State private var name = ""
    @State private var url = ""
    @State private var selectedType: TunnelConfig.TunnelType = .vscodeDevTunnel
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TunnelConfig.TunnelType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                        .accessibilityHint("Select the type of server to connect to")
                    
                    TextField("Name", text: $name, prompt: Text("My MacBook"))
                        .accessibilityHint("Enter a display name for this server")
                    
                    TextField("URL", text: $url, prompt: Text(selectedType.placeholder))
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .accessibilityHint("Enter the server URL to connect to")
                }
                
                Section {
                    Button("Add Server") {
                        let config = TunnelConfig(
                            name: name.isEmpty ? selectedType.rawValue : name,
                            url: url,
                            type: selectedType
                        )
                        tunnelManager.addConfig(config)
                        dismiss()
                    }
                    .disabled(url.isEmpty)
                        .accessibilityHint("Add this server configuration")
                }
                
                Section(header: Text("Help").accessibilityAddTraits(.isHeader)) {
                    switch selectedType {
                    case .vscodeDevTunnel:
                        Text("Run `code tunnel` on your machine, then copy the vscode.dev URL.")
                            .font(.caption)
                    case .codeServer:
                        Text("Install code-server on your server and enter its URL with port.")
                            .font(.caption)
                    case .codespaces:
                        Text("Open your Codespace on github.com, then copy the URL.")
                            .font(.caption)
                    case .custom:
                        Text("Enter any URL that serves VS Code or Monaco editor.")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityHint("Dismiss without adding a server")
                }
            }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @State private var searchText = ""
    @State private var selectedCategory: SettingsCategory? = .editor
    
    init(themeManager: ThemeManager = ThemeManager.shared) {
        self.themeManager = themeManager
    }
    
    enum SettingsCategory: String, CaseIterable, Identifiable {
        case editor = "Editor"
        case workbench = "Workbench"
        case features = "Features"
        case connectedMode = "Connected Mode"
        case extensions = "Extensions"
        case accounts = "Accounts"
        
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .editor: return "text.cursor"
            case .workbench: return "sidebar.left"
            case .features: return "star"
            case .connectedMode: return "bolt.horizontal.fill"
            case .extensions: return "puzzlepiece.extension"
            case .accounts: return "person.crop.circle"
            }
        }
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationSplitView {
                List(SettingsCategory.allCases, selection: $selectedCategory) {
                    category in
                    NavigationLink(value: category) {
                        Label(category.rawValue, systemImage: category.icon)
                    }
                }
                .navigationTitle("Settings")
                .listStyle(.sidebar)
            } detail: {
                if let category = selectedCategory {
                    SettingsDetailView(category: category, searchText: searchText, themeManager: themeManager)
                } else {
                    Text("Select a category")
                        .foregroundColor(.secondary)
                }
            }
            .searchable(text: $searchText, placement: .sidebar)
        } else {
            NavigationView {
                List(SettingsCategory.allCases, selection: $selectedCategory) {
                    category in
                    NavigationLink(
                        destination: SettingsDetailView(category: category, searchText: searchText, themeManager: themeManager),
                        tag: category,
                        selection: $selectedCategory
                    ) {
                        Label(category.rawValue, systemImage: category.icon)
                    }
                }
                .navigationTitle("Settings")
                .listStyle(.sidebar)
                
                // Initial detail view
                SettingsDetailView(category: .editor, searchText: searchText, themeManager: themeManager)
            }
            .searchable(text: $searchText)
        }
    }
}

struct SettingsDetailView: View {
    let category: SettingsView.SettingsCategory
    let searchText: String
    @ObservedObject var themeManager: ThemeManager

    @StateObject private var aiManager = AIManager()
    @State private var showAISettings = false
    
    @AppStorage("fontSize") private var fontSize: Double = 14
    @AppStorage("fontFamily") private var fontFamily: String = "Menlo"
    @AppStorage("tabSize") private var tabSize: Int = 4
    @AppStorage("wordWrap") private var wordWrap: Bool = true
    @AppStorage("autoSave") private var autoSave: String = "off"
    @AppStorage("autoSaveDelay") private var autoSaveDelay: Int = 1000
    @AppStorage("minimapEnabled") private var minimapEnabled: Bool = true
    @AppStorage("showLineNumbers") private var showLineNumbers: Bool = true
    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
    @AppStorage("trimTrailingWhitespace") private var trimTrailingWhitespace: Bool = false
    @AppStorage("insertFinalNewline") private var insertFinalNewline: Bool = false
    
    var body: some View {
        Form {
            if shouldShow(category: .editor) {
                Section(header: Text("Editor").accessibilityAddTraits(.isHeader)) {
                    if matchesSearch("Font Size") {
                        VStack(alignment: .leading) {
                            Text("Font Size: \(Int(fontSize))")
                            Slider(value: $fontSize, in: 8...32, step: 1) {
                                Text("Font Size")
                            } minimumValueLabel: {
                                Text("8")
                            } maximumValueLabel: {
                                Text("32")
                            }
                            .accessibilityLabel("Font Size: \(Int(fontSize))")
                            .accessibilityHint("Adjust the editor font size between 8 and 32")
                        }
                    }
                    
                    if matchesSearch("Font Family") {
                        Picker("Font Family", selection: $fontFamily) {
                            Text("Menlo").tag("Menlo")
                            Text("Courier New").tag("Courier New")
                            Text("SF Mono").tag("SF Mono")
                            Text("Fira Code").tag("Fira Code")
                            Text("JetBrains Mono").tag("JetBrains Mono")
                        }
                        .accessibilityHint("Select the editor font family")
                    }
                    
                    if matchesSearch("Tab Size") {
                        Stepper("Tab Size: \(tabSize)", value: $tabSize, in: 1...8)
                            .accessibilityHint("Adjust the number of spaces per tab, from 1 to 8")
                    }
                    
                    if matchesSearch("Word Wrap") {
                        Toggle("Word Wrap", isOn: $wordWrap)
                            .accessibilityHint("Toggle word wrap in the editor")
                    }
                    
                    if matchesSearch("Minimap") {
                        Toggle("Minimap", isOn: $minimapEnabled)
                            .accessibilityHint("Toggle the minimap sidebar in the editor")
                    }
                    
                    if matchesSearch("Line Numbers") {
                        Picker("Line Numbers", selection: $lineNumbersStyle) {
                            Text("On").tag("on")
                            Text("Off").tag("off")
                            Text("Relative").tag("relative")
                            Text("Interval").tag("interval")
                        }
                        .accessibilityHint("Choose how line numbers are displayed")
                        // Sync with boolean for backward compatibility
                        .onChange(of: lineNumbersStyle) { newValue in
                            showLineNumbers = (newValue != "off")
                        }
                    }
                    
                    if matchesSearch("Trim Whitespace") {
                        Toggle("Trim Trailing Whitespace", isOn: $trimTrailingWhitespace)
                            .accessibilityHint("Remove trailing whitespace on save")
                    }
                    
                    if matchesSearch("Final Newline") {
                        Toggle("Insert Final Newline", isOn: $insertFinalNewline)
                            .accessibilityHint("Insert a newline at end of file on save")
                    }
                }
            }
            
            if shouldShow(category: .workbench) {
                Section(header: Text("Workbench").accessibilityAddTraits(.isHeader)) {
                    if matchesSearch("Theme") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Color Theme").font(.headline)
                            
                            // Dark Themes
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Dark Themes").font(.subheadline).foregroundColor(.secondary)
                                ForEach(Theme.allThemes.filter { $0.isDark }) { theme in
                                    ThemeRow(theme: theme, isSelected: themeManager.currentTheme.id == theme.id) {
                                        themeManager.switchTheme(to: theme.id)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Light Themes
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Light Themes").font(.subheadline).foregroundColor(.secondary)
                                ForEach(Theme.allThemes.filter { !$0.isDark }) { theme in
                                    ThemeRow(theme: theme, isSelected: themeManager.currentTheme.id == theme.id) {
                                        themeManager.switchTheme(to: theme.id)
                                    }
                                }
                            }
                            
                            // Theme Preview
                            ThemePreviewView(theme: themeManager.currentTheme)
                                .accessibilityLabel("Theme preview for \(themeManager.currentTheme.name)")
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            
            if shouldShow(category: .features) {
                Section(header: Text("Features").accessibilityAddTraits(.isHeader)) {
                    if matchesSearch("Auto Save") {
                        Picker("Auto Save", selection: $autoSave) {
                            Text("Off").tag("off")
                            Text("After Delay").tag("afterDelay")
                            Text("On Focus Change").tag("onFocusChange")
                            Text("On Window Change").tag("onWindowChange")
                        }
                        .accessibilityHint("Choose when files are automatically saved")
                        
                        if autoSave == "afterDelay" {
                            HStack {
                                Text("Auto Save Delay")
                                Spacer()
                                Text("\(autoSaveDelay)ms")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: Binding(
                                get: { Double(autoSaveDelay) },
                                set: { autoSaveDelay = Int($0) }
                            ), in: 500...5000, step: 100) {
                                Text("Delay")
                            }
                            .accessibilityLabel("Auto Save Delay: \(autoSaveDelay) milliseconds")
                            .accessibilityHint("Adjust the delay before auto-saving, from 500 to 5000 milliseconds")
                        }
                    }
                }
            }

            if shouldShow(category: .connectedMode) {
                Section(header: Text("Connected Mode").accessibilityAddTraits(.isHeader)) {
                    if matchesSearch("Tunnel") || matchesSearch("Server") || matchesSearch("VS Code") || matchesSearch("Connected") {
                        ConnectedModeSettingsSection()
                    }
                }
            }
            if shouldShow(category: .accounts) {
                Section(header: Text("GitHub Account").accessibilityAddTraits(.isHeader)) {
                    if matchesSearch("GitHub") || matchesSearch("Account") || matchesSearch("Login") {
                        GitHubLoginView()
                    }
                }
            }

            if shouldShow(category: .extensions) {
                Section(header: Text("Extensions").accessibilityAddTraits(.isHeader)) {
                    if matchesSearch("AI Assistant") {
                        Button("AI Assistant Settings…") { showAISettings = true }
                            .accessibilityHint("Open AI assistant configuration and API key settings")
                    }
                }
            }
        }
        .navigationTitle(searchText.isEmpty ? category.rawValue : "Search Results")
        .sheet(isPresented: $showAISettings) {
            AISettingsView(aiManager: aiManager)
        }
    }
    
    private func shouldShow(category: SettingsView.SettingsCategory) -> Bool {
        if !searchText.isEmpty {
            if category == .editor {
                return matchesSearch("Font Size") || matchesSearch("Font Family") || matchesSearch("Tab Size") || matchesSearch("Word Wrap") || matchesSearch("Minimap") || matchesSearch("Line Numbers") || matchesSearch("Trim Whitespace") || matchesSearch("Final Newline")
            }
            if category == .workbench {
                return matchesSearch("Theme")
            }
            if category == .connectedMode {
                return matchesSearch("Tunnel") || matchesSearch("Server") || matchesSearch("VS Code") || matchesSearch("Connected")
            }
            if category == .features {
                return matchesSearch("Auto Save")
            }
            if category == .extensions {
                return matchesSearch("AI Assistant")
            }
            if category == .accounts {
                return matchesSearch("GitHub") || matchesSearch("Account") || matchesSearch("Login")
            }
        }
        return self.category == category
    }
    
    private func matchesSearch(_ item: String) -> Bool {
        searchText.isEmpty || item.localizedCaseInsensitiveContains(searchText)
    }
}

struct ThemeRow: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(theme.editorBackground)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(theme.statusBarBackground, lineWidth: 2)
                    )
                Text(theme.name)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.name) theme\(isSelected ? ", currently selected" : "")")
        .accessibilityHint("Double tap to apply this theme")
    }
}

struct ThemePreviewView: View {
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 0) {
            // Activity Bar
            Rectangle()
                .fill(theme.activityBarBackground)
                .frame(width: 40)
                .overlay(
                    VStack(spacing: 15) {
                        Image(systemName: "doc.on.doc")
                        Image(systemName: "magnifyingglass")
                        Image(systemName: "gearshape")
                        Spacer()
                    }
                    .foregroundColor(theme.activityBarForeground)
                    .padding(.top, 20)
                )
            
            // Sidebar
            Rectangle()
                .fill(theme.sidebarBackground)
                .frame(width: 80)
                .overlay(
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EXPLORER")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(theme.sidebarForeground.opacity(0.7))
                            .padding(.top, 10)
                            .padding(.leading, 8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                Text("Project")
                                    .font(.caption)
                            }
                            .foregroundColor(theme.sidebarForeground)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "swift")
                                    .font(.caption2)
                                Text("App.swift")
                                    .font(.caption)
                            }
                            .foregroundColor(theme.sidebarForeground)
                            .padding(.leading, 12)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                    }
                )
            
            // Editor
            Rectangle()
                .fill(theme.editorBackground)
                .overlay(
                    VStack(alignment: .leading, spacing: 0) {
                        // Tabs
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(theme.tabActiveBackground)
                                .frame(width: 80, height: 25)
                                .overlay(
                                    HStack(spacing: 4) {
                                        Image(systemName: "swift")
                                            .font(.caption2)
                                            .foregroundColor(theme.tabActiveForeground)
                                        Text("App.swift")
                                            .font(.caption2)
                                            .foregroundColor(theme.tabActiveForeground)
                                    }
                                )
                            Rectangle()
                                .fill(theme.tabBarBackground)
                        }
                        .frame(height: 25)
                        
                        // Content
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 0) {
                                Text("1")
                                    .font(.caption2)
                                    .foregroundColor(theme.lineNumber)
                                    .frame(width: 20)
                                Text("import")
                                    .font(.caption2)
                                    .foregroundColor(theme.keyword)
                                Text(" SwiftUI")
                                    .font(.caption2)
                                    .foregroundColor(theme.editorForeground)
                            }
                            
                            HStack(spacing: 0) {
                                Text("2")
                                    .font(.caption2)
                                    .foregroundColor(theme.lineNumber)
                                    .frame(width: 20)
                            }
                            
                            HStack(spacing: 0) {
                                Text("3")
                                    .font(.caption2)
                                    .foregroundColor(theme.lineNumberActive)
                                    .frame(width: 20)
                                Text("struct")
                                    .font(.caption2)
                                    .foregroundColor(theme.keyword)
                                Text(" App")
                                    .font(.caption2)
                                    .foregroundColor(theme.type)
                                Text(": ")
                                    .font(.caption2)
                                    .foregroundColor(theme.editorForeground)
                                Text("View")
                                    .font(.caption2)
                                    .foregroundColor(theme.type)
                                Text(" {")
                                    .font(.caption2)
                                    .foregroundColor(theme.editorForeground)
                            }
                            
                            Spacer()
                        }
                        .padding(4)
                        
                        // Status Bar
                        HStack {
                            Text("main")
                                .font(.caption2)
                            Spacer()
                            Text("Ln 3, Col 1")
                                .font(.caption2)
                        }
                        .foregroundColor(theme.statusBarForeground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(theme.statusBarBackground)
                    }
                )
        }
    }
}

// MARK: - Connected Mode Settings Section

struct ConnectedModeSettingsSection: View {
    @ObservedObject var tunnelManager = TunnelManager.shared
    @State private var showingAddTunnel = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connect to VS Code Server for full IDE features like code folding, git, terminal, and extensions.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if tunnelManager.configs.isEmpty {
                Button(action: { showingAddTunnel = true }) {
                    Label("Add Server", systemImage: "plus.circle")
                }
                .accessibilityHint("Add a new server connection")
            } else {
                ForEach(tunnelManager.configs) { config in
                    HStack {
                        Image(systemName: config.type.icon)
                            .foregroundColor(.accentColor)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading) {
                            Text(config.name)
                                .font(.subheadline)
                            Text(config.url)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button("Connect") {
                            tunnelManager.connect(to: config)
                        }
                        .accessibilityLabel("Connect to \(config.name)")
                        .accessibilityHint("Connect to \(config.type.rawValue) at \(config.url)")
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("\(config.name), \(config.type.rawValue)")
                    .padding(.vertical, 4)
                }
                
                Button(action: { showingAddTunnel = true }) {
                    Label("Add Another Server", systemImage: "plus")
                }
                .font(.caption)
                .accessibilityHint("Add another server connection")
            }
        }
        .sheet(isPresented: $showingAddTunnel) {
            AddTunnelSheet()
        }
    }
}

// MARK: - VS Code WebView (WKWebView with JS debugging)

// WebKit already imported at top of file

class SettingsWebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var parent: SettingsWebView
    
    init(_ parent: SettingsWebView) {
        self.parent = parent
    }
    
    // MARK: - JavaScript Console Capture
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "consoleLog" {
            AppLogger.editor.debug("[JS Console] \(message.body)")
        } else if message.name == "consoleError" {
            AppLogger.editor.error("[JS ERROR] \(message.body)")
        } else if message.name == "vsCodeError" {
            AppLogger.editor.error("[VS Code Error] \(message.body)")
        }
    }
    
    // MARK: - Navigation Delegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        AppLogger.editor.debug("[WebView] Started loading: \(webView.url?.absoluteString ?? "unknown")")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        AppLogger.editor.debug("[WebView] Finished loading: \(webView.url?.absoluteString ?? "unknown")")
        // Inject error catcher after page loads
        let errorCatcher = """
        window.onerror = function(msg, url, line, col, error) {
            window.webkit.messageHandlers.vsCodeError.postMessage(
                'Error: ' + msg + ' at ' + url + ':' + line + ':' + col
            );
            return false;
        };
        window.onunhandledrejection = function(event) {
            window.webkit.messageHandlers.vsCodeError.postMessage(
                'Unhandled Promise: ' + event.reason
            );
        };
        """
        webView.evaluateJavaScript(errorCatcher, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        AppLogger.editor.debug("[WebView] Navigation failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        AppLogger.editor.debug("[WebView] Provisional navigation failed: \(error.localizedDescription)")
    }
    
    // MARK: - UI Delegate (handle alerts, confirms, prompts)
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        AppLogger.editor.debug("[JS Alert] \(message)")
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        AppLogger.editor.debug("[JS Confirm] \(message)")
        completionHandler(true)
    }
    
    // Handle new window requests (popups) - open in same webview
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        AppLogger.editor.debug("[WebView] Popup requested: \(navigationAction.request.url?.absoluteString ?? "unknown")")
        // Load popup URL in same webview instead of blocking
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}

struct SettingsWebView: UIViewRepresentable {
    let url: URL
    let onDismiss: () -> Void
    
    func makeCoordinator() -> SettingsWebViewCoordinator {
        SettingsWebViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // Configure for VS Code web
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default() // Persist cookies/storage
        
        // Enable required features
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        
        // JavaScript message handlers for debugging
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "consoleLog")
        contentController.add(context.coordinator, name: "consoleError")
        contentController.add(context.coordinator, name: "vsCodeError")
        
        // Intercept console.log and console.error
        let consoleScript = WKUserScript(source: """
            (function() {
                var originalLog = console.log;
                var originalError = console.error;
                var originalWarn = console.warn;
                
                console.log = function() {
                    var args = Array.prototype.slice.call(arguments);
                    window.webkit.messageHandlers.consoleLog.postMessage(args.map(String).join(' '));
                    originalLog.apply(console, arguments);
                };
                
                console.error = function() {
                    var args = Array.prototype.slice.call(arguments);
                    window.webkit.messageHandlers.consoleError.postMessage(args.map(String).join(' '));
                    originalError.apply(console, arguments);
                };
                
                console.warn = function() {
                    var args = Array.prototype.slice.call(arguments);
                    window.webkit.messageHandlers.consoleLog.postMessage('[WARN] ' + args.map(String).join(' '));
                    originalWarn.apply(console, arguments);
                };
            })();
        """, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(consoleScript)
        
        config.userContentController = contentController
        
        // Allow inline media playback
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        
        // Custom user agent to avoid mobile detection issues
        webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        // Load the URL
        AppLogger.editor.debug("[WebView] Loading: \(url.absoluteString)")
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only reload if URL changed significantly
    }
    
    static func dismantleUIView(_ webView: WKWebView, coordinator: SettingsWebViewCoordinator) {
        // Remove script message handlers to break the retain cycle
        // WKUserContentController retains the handler strongly
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "consoleLog")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "consoleError")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "vsCodeError")
    }
}
    

#Preview {
    SettingsView()
}
