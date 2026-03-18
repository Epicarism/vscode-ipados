import SwiftUI
import os

// TunnelConfig and TunnelManager moved to Services/VSCodeTunnelManager.swift

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
    @Environment(\.dismiss) private var dismiss
    
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
            .background(
                Button("") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
                    .opacity(0)
                    .allowsHitTesting(false)
            )
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
            .background(
                Button("") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
                    .opacity(0)
                    .allowsHitTesting(false)
            )
        }
    }
}

struct SettingsDetailView: View {
    let category: SettingsView.SettingsCategory
    let searchText: String
    @ObservedObject var themeManager: ThemeManager

    @ObservedObject private var aiManager = AIManager.shared
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
    @AppStorage("showInvisibleCharacters") private var showInvisibleCharacters: Bool = false
    @AppStorage("stickyScroll") private var stickyScroll: Bool = true
    @AppStorage("formatOnSave") private var formatOnSave: Bool = false
    @AppStorage("bracketPairColorization") private var bracketPairColorization: Bool = true
    @AppStorage("indentGuides") private var indentGuides: Bool = true
    @AppStorage("inlineSuggestions") private var inlineSuggestions: Bool = true
    
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

                    if matchesSearch("Sticky Scroll") {
                        Toggle("Sticky Scroll", isOn: $stickyScroll)
                            .accessibilityHint("Show the current scope/function name pinned at the top of the editor while scrolling")
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
                        .onChange(of: lineNumbersStyle) { _, newValue in
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

                    if matchesSearch("Show Invisible Characters") {
                        Toggle("Show Invisible Characters", isOn: $showInvisibleCharacters)
                            .accessibilityHint("Show tabs, spaces, and line breaks as visible glyphs in the editor")
                    }
                }
            }
            
            if shouldShow(category: .workbench) {
                Section(header: Text("Workbench").accessibilityAddTraits(.isHeader)) {
                    if matchesSearch("Follow System Appearance") || matchesSearch("System") || matchesSearch("Appearance") || matchesSearch("Theme") {
                        Toggle("Follow System Appearance", isOn: $themeManager.followSystemAppearance)
                            .accessibilityHint("Automatically switch between light and dark themes based on the system appearance setting")
                    }
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
                    
                    if matchesSearch("Format On Save") {
                        Toggle("Format On Save", isOn: $formatOnSave)
                            .accessibilityHint("Automatically format the document when saving")
                    }
                    
                    if matchesSearch("Bracket Pair Colorization") {
                        Toggle("Bracket Pair Colorization", isOn: $bracketPairColorization)
                            .accessibilityHint("Colorize matching bracket pairs with distinct colors")
                    }
                    
                    if matchesSearch("Indent Guides") {
                        Toggle("Indent Guides", isOn: $indentGuides)
                            .accessibilityHint("Show vertical indent guide lines in the editor")
                    }
                    
                    if matchesSearch("Inline Suggestions") {
                        Toggle("Inline Suggestions", isOn: $inlineSuggestions)
                            .accessibilityHint("Show AI-powered inline code suggestions while typing")
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
                return matchesSearch("Font Size") || matchesSearch("Font Family") || matchesSearch("Tab Size") || matchesSearch("Word Wrap") || matchesSearch("Minimap") || matchesSearch("Sticky Scroll") || matchesSearch("Line Numbers") || matchesSearch("Trim Whitespace") || matchesSearch("Final Newline") || matchesSearch("Show Invisible Characters")
            }
            if category == .workbench {
                return matchesSearch("Theme") || matchesSearch("Follow System Appearance") || matchesSearch("System") || matchesSearch("Appearance")
            }
            if category == .connectedMode {
                return matchesSearch("Tunnel") || matchesSearch("Server") || matchesSearch("VS Code") || matchesSearch("Connected")
            }
            if category == .features {
                return matchesSearch("Auto Save") || matchesSearch("Format On Save") || matchesSearch("Bracket Pair Colorization") || matchesSearch("Indent Guides") || matchesSearch("Inline Suggestions")
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



#Preview {
    SettingsView()
}
