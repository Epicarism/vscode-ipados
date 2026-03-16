import SwiftUI

// MARK: - AI Assistant View

struct AIAssistantView: View {
    @StateObject private var aiManager = AIManager()
    @ObservedObject var editorCore: EditorCore
    var fileNavigator: FileSystemNavigator?
    @State private var userInput = ""
    @State private var showSettings = false
    @State private var showHistory = false
    @State private var showTools = false
    @FocusState private var isInputFocused: Bool
    
    // Tool executor - created per-use in sendMessage() to strongly capture fileNavigator
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AIAssistantHeader(
                aiManager: aiManager,
                showSettings: $showSettings,
                showHistory: $showHistory,
                onClose: { editorCore.showAIAssistant = false },
                onNewChat: { aiManager.createNewSession() }
            )
            
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(aiManager.currentSession.messages) { message in
                            ChatMessageView(message: message, onInsertCode: insertCode)
                                .id(message.id)
                        }
                        
                        // Streaming response / loading indicator
                        if aiManager.isLoading {
                            if !aiManager.streamingResponse.isEmpty {
                                // Show streaming tokens as an in-progress assistant message bubble
                                HStack(alignment: .top, spacing: 12) {
                                    // Avatar
                                    Circle()
                                        .fill(Color.purple)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "brain")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        // Role label with streaming indicator
                                        HStack(spacing: 6) {
                                            Text("Assistant")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.secondary)
                                            ProgressView()
                                                .scaleEffect(0.6)
                                        }
                                        
                                        // Streaming message content with markdown-like rendering
                                        MessageContentView(
                                            content: aiManager.streamingResponse,
                                            codeBlocks: [],
                                            onInsertCode: insertCode
                                        )
                                        .opacity(0.9)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                                .id("streaming")
                            } else {
                                // Show thinking spinner before tokens start arriving
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Text("Thinking...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding()
                                .id("loading")
                            }
                        }
                        
                        // Error message
                        if let error = aiManager.error {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: aiManager.currentSession.messages.count) { _, _ in
                    withAnimation {
                        if let lastId = aiManager.currentSession.messages.last?.id {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: aiManager.streamingResponse) { _, _ in
                    // Auto-scroll as streaming tokens arrive
                    if aiManager.isLoading {
                        withAnimation(.easeOut(duration: 0.15)) {
                            if !aiManager.streamingResponse.isEmpty {
                                proxy.scrollTo("streaming", anchor: .bottom)
                            } else {
                                proxy.scrollTo("loading", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Quick Actions
            QuickActionsBar(aiManager: aiManager, editorCore: editorCore)
            
            // Input Area
            ChatInputArea(
                userInput: $userInput,
                isInputFocused: _isInputFocused,
                isLoading: aiManager.isLoading,
                onSend: sendMessage,
                onStop: { aiManager.cancelStreaming() }
            )
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showSettings) {
            AISettingsView(aiManager: aiManager)
        }
        .sheet(isPresented: $showHistory) {
            ChatHistoryView(aiManager: aiManager, isPresented: $showHistory)
        }
        .onAppear {
            isInputFocused = true
        }
    }
    
    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let message = userInput
        userInput = ""
        
        // Build rich context for the AI
        let context = buildAgentContext()
        
        // Create executor once per send; it strongly holds fileNavigator for the entire async call
        let executor = AIToolExecutor(editorCore: editorCore, fileNavigator: fileNavigator)
        
        Task {
            await aiManager.sendMessage(message, context: context, toolExecutor: executor)
        }
    }
    
    private func buildAgentContext() -> String {
        var sections: [String] = []
        
        // Workspace info
        if let rootURL = fileNavigator?.rootURL {
            sections.append("## Workspace")
            sections.append("Path: \(rootURL.path)")
            sections.append("Name: \(rootURL.lastPathComponent)")
        }
        
        // Open tabs
        if !editorCore.tabs.isEmpty {
            sections.append("\n## Open Tabs")
            for tab in editorCore.tabs {
                let marker = tab.id == editorCore.activeTabId ? "→ " : "  "
                let unsaved = tab.isUnsaved ? " ●" : ""
                sections.append("\(marker)\(tab.fileName) [\(tab.language.displayName)]\(unsaved)")
            }
        }
        
        // Current file with full content
        if let tab = editorCore.activeTab {
            sections.append("\n## Current File: \(tab.fileName)")
            sections.append("Language: \(tab.language.displayName)")
            sections.append("Lines: \(tab.lineCount)")
            sections.append("Cursor: Line \(editorCore.cursorPosition.line), Column \(editorCore.cursorPosition.column)")
            
            // Include file content (truncated if very large)
            let content = tab.content
            let lines = content.components(separatedBy: "\n")
            if lines.count <= 500 {
                sections.append("\n```\(tab.language.rawValue)\n\(content)\n```")
            } else {
                // Show context around cursor
                let cursorLine = editorCore.cursorPosition.line
                let startLine = max(0, cursorLine - 100)
                let endLine = min(lines.count, cursorLine + 100)
                let visibleContent = lines[startLine..<endLine].joined(separator: "\n")
                sections.append("\n(Showing lines \(startLine+1)-\(endLine) of \(lines.count))")
                sections.append("```\(tab.language.rawValue)\n\(visibleContent)\n```")
            }
        }
        
        // Selected text
        let selection = editorCore.currentSelection; if !selection.isEmpty {
            sections.append("\n## Selected Text")
            sections.append("```\n\(selection)\n```")
        }
        
        return sections.joined(separator: "\n")
    }
    
    private func insertCode(_ code: String) {
        if let index = editorCore.activeTabIndex {
            // Insert at cursor position
            let content = editorCore.tabs[index].content
            let lines = content.components(separatedBy: "\n")
            let cursorLine = min(editorCore.cursorPosition.line, lines.count)
            
            // Build new content with code inserted at cursor line
            var newLines = lines
            let insertionCode = "\n" + code + "\n"
            if cursorLine < newLines.count {
                newLines.insert(insertionCode, at: cursorLine + 1)
            } else {
                newLines.append(insertionCode)
            }
            editorCore.tabs[index].content = newLines.joined(separator: "\n")
            
            // Post notification for visual feedback
            NotificationCenter.default.post(name: .codeInserted, object: nil, userInfo: ["code": code])
            AppLogger.editor.debug("[AI] Inserted \(code.count) chars at line \(cursorLine)")
        } else {
            // No active tab - create a new one with the code
            let ext = detectExtension(from: code)
            editorCore.addTab(fileName: "Generated.\(ext)", content: code)
        }
    }
    
    private func detectExtension(from code: String) -> String {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.contains("import swift") || trimmed.contains("func ") || trimmed.contains("struct ") || trimmed.contains("class ") { return "swift" }
        if trimmed.contains("function ") || trimmed.contains("const ") || trimmed.contains("let ") || trimmed.contains("=>") { return "js" }
        if trimmed.contains("def ") || trimmed.contains("import ") || trimmed.contains("print(") { return "py" }
        if trimmed.contains("<html") || trimmed.contains("<div") { return "html" }
        if trimmed.contains("#include") { return "c" }
        return "swift"
    }
}

// MARK: - Header

struct AIAssistantHeader: View {
    @ObservedObject var aiManager: AIManager
    @Binding var showSettings: Bool
    @Binding var showHistory: Bool
    let onClose: () -> Void
    let onNewChat: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain")
                .font(.title2)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Assistant")
                    .font(.headline)
                HStack(spacing: 4) {
                    Image(systemName: aiManager.selectedProvider.iconName)
                        .font(.caption2)
                    Text(aiManager.selectedModel.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // New chat button
            Button(action: onNewChat) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16))
            }
            .foregroundColor(.secondary)
            .accessibilityLabel("New Chat")
            .accessibilityHint("Double tap to start a new conversation")
            
            // History button
            Button(action: { showHistory = true }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16))
            }
            .foregroundColor(.secondary)
            .accessibilityLabel("Chat History")
            .accessibilityHint("Double tap to view conversation history")
            
            // Settings button
            Button(action: { showSettings = true }) {
                Image(systemName: "gear")
                    .font(.system(size: 16))
            }
            .foregroundColor(.secondary)
            .accessibilityLabel("AI Settings")
            .accessibilityHint("Double tap to configure AI provider and model")
            
            // Close button
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
            .accessibilityLabel("Close AI Assistant")
            .accessibilityHint("Double tap to close the AI assistant panel")
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
}

// MARK: - Chat Message View

struct ChatMessageView: View {
    let message: ChatMessage
    let onInsertCode: (String) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            Circle()
                .fill(message.role == .user ? Color.blue : Color.purple)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: message.role == .user ? "person.fill" : "brain")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                // Role label
                Text(message.role == .user ? "You" : "Assistant")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                // Message content with markdown-like rendering
                MessageContentView(content: message.content, codeBlocks: message.codeBlocks, onInsertCode: onInsertCode)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Message Content View

struct MessageContentView: View {
    let content: String
    let codeBlocks: [CodeBlock]
    let onInsertCode: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Parse and render content
            let parts = parseContent(content)
            
            ForEach(parts.indices, id: \.self) { index in
                let part = parts[index]
                if part.isCode {
                    CodeBlockView(language: part.language, code: part.content, onInsert: onInsertCode)
                } else {
                    Text(part.content)
                        .font(.system(size: 14))
                        .textSelection(.enabled)
                }
            }
        }
    }
    
    private func parseContent(_ text: String) -> [ContentPart] {
        var parts: [ContentPart] = []
        let pattern = "```(\\w*)\\n([\\s\\S]*?)```"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [ContentPart(content: text, isCode: false, language: "")]
        }
        
        var lastEnd = text.startIndex
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        for match in matches {
            // Add text before code block
            if let beforeRange = Range(NSRange(location: NSRange(lastEnd..., in: text).location, length: match.range.location - NSRange(lastEnd..., in: text).location), in: text) {
                let beforeText = String(text[beforeRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !beforeText.isEmpty {
                    parts.append(ContentPart(content: beforeText, isCode: false, language: ""))
                }
            }
            
            // Add code block
            if let langRange = Range(match.range(at: 1), in: text),
               let codeRange = Range(match.range(at: 2), in: text) {
                let language = String(text[langRange])
                let code = String(text[codeRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                parts.append(ContentPart(content: code, isCode: true, language: language))
            }
            
            if let matchRange = Range(match.range, in: text) {
                lastEnd = matchRange.upperBound
            }
        }
        
        // Add remaining text
        let remainingText = String(text[lastEnd...]).trimmingCharacters(in: .whitespacesAndNewlines)
        if !remainingText.isEmpty {
            parts.append(ContentPart(content: remainingText, isCode: false, language: ""))
        }
        
        if parts.isEmpty {
            parts.append(ContentPart(content: text, isCode: false, language: ""))
        }
        
        return parts
    }
}

struct ContentPart {
    let content: String
    let isCode: Bool
    let language: String
}

// MARK: - Code Block View

struct CodeBlockView: View {
    let language: String
    let code: String
    let onInsert: (String) -> Void
    @State private var copied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(language.isEmpty ? "code" : language)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = code
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copied = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied" : "Copy")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Button(action: { onInsert(code) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.doc")
                        Text("Insert")
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.tertiarySystemBackground))
            
            // Code content
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(size: 12, design: .monospaced))
                    .padding(12)
                    .textSelection(.enabled)
            }
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Quick Actions Bar

struct QuickActionsBar: View {
    @ObservedObject var aiManager: AIManager
    @ObservedObject var editorCore: EditorCore
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                QuickActionButton(icon: "doc.text.magnifyingglass", title: "Explain") {
                    performAction { code, lang in
                        await aiManager.explainCode(code, language: lang)
                    }
                }
                
                QuickActionButton(icon: "wrench.and.screwdriver", title: "Fix") {
                    performAction { code, lang in
                        await aiManager.fixCode(code, language: lang)
                    }
                }
                
                QuickActionButton(icon: "testtube.2", title: "Tests") {
                    performAction { code, lang in
                        await aiManager.generateTests(code, language: lang)
                    }
                }
                
                QuickActionButton(icon: "arrow.triangle.2.circlepath", title: "Refactor") {
                    performAction { code, lang in
                        await aiManager.refactorCode(code, language: lang, instruction: "Improve code quality and readability")
                    }
                }
                
                QuickActionButton(icon: "doc.plaintext", title: "Document") {
                    performAction { code, lang in
                        await aiManager.documentCode(code, language: lang)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private func performAction(action: @escaping (String, String) async -> String) {
        guard let tab = editorCore.activeTab else { return }

        // FEAT-111/112: Use selected code when available; otherwise fall back to whole file.
        let code: String
        if let range = editorCore.currentSelectionRange,
           range.length > 0,
           !editorCore.currentSelection.isEmpty {
            code = editorCore.currentSelection
        } else {
            code = tab.content
        }

        let language = tab.language.displayName
        
        Task {
            let response = await action(code, language)
            await MainActor.run {
                let message = ChatMessage(role: .assistant, content: response)
                aiManager.currentSession.messages.append(message)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(UIColor.tertiarySystemFill))
            .cornerRadius(16)
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Chat Input Area

struct ChatInputArea: View {
    @Binding var userInput: String
    @FocusState var isInputFocused: Bool
    let isLoading: Bool
    let onSend: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask about your code...", text: $userInput)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(20)
                .lineLimit(5)
                .focused($isInputFocused)
                .onSubmit {
                    if !isLoading { onSend() }
                }
                .accessibilityLabel("Message input")
                .accessibilityHint("Type your question about code here")
            
            Button(action: { isLoading ? onStop() : onSend() }) {
                Image(systemName: isLoading ? "stop.circle.fill" : "paperplane.fill")
                    .font(.system(size: 24))
                    .foregroundColor(userInput.isEmpty && !isLoading ? .gray : .accentColor)
            }
            .disabled(userInput.isEmpty && !isLoading)
            .accessibilityLabel(isLoading ? "Stop generating" : "Send message")
            .accessibilityHint(isLoading ? "Double tap to stop AI response" : "Double tap to send your message")
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - AI Settings View

struct AISettingsView: View {
    @ObservedObject var aiManager: AIManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Provider Selection
                Section(header: Text("AI Provider")) {
                    Picker("Provider", selection: Binding(
                        get: { aiManager.selectedProvider },
                        set: { aiManager.selectedProvider = $0 }
                    )) {
                        ForEach(AIProvider.allCases) { provider in
                            HStack {
                                Image(systemName: provider.iconName)
                                Text(provider.rawValue)
                            }
                            .tag(provider)
                        }
                    }
                }
                
                // Model Selection
                Section(header: Text("Model")) {
                    Picker("Model", selection: Binding(
                        get: { aiManager.selectedModel },
                        set: { aiManager.selectedModel = $0 }
                    )) {
                        ForEach(aiManager.selectedProvider.models) { model in
                            Text(model.name).tag(model)
                        }
                    }
                }
                
                // API Keys
                Section(header: Text("API Keys")) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: AIProvider.openai.iconName)
                            Text("OpenAI API Key")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        SecureField("sk-...", text: $aiManager.openAIKey)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: AIProvider.anthropic.iconName)
                            Text("Anthropic API Key")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        SecureField("sk-ant-...", text: $aiManager.anthropicKey)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: AIProvider.google.iconName)
                            Text("Google API Key")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        SecureField("AIza...", text: $aiManager.googleKey)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "message.circle")
                            Text("Kimi API Key")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        SecureField("sk-...", text: $aiManager.kimiKey)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "brain.fill")
                            Text("GLM API Key")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        SecureField("...", text: $aiManager.glmKey)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: AIProvider.groq.iconName)
                            Text("Groq API Key")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        SecureField("gsk_...", text: $aiManager.groqKey)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: AIProvider.deepseek.iconName)
                            Text("DeepSeek API Key")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        SecureField("sk-...", text: $aiManager.deepseekKey)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: AIProvider.mistral.iconName)
                            Text("Mistral API Key")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        SecureField("...", text: $aiManager.mistralKey)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                
                // Ollama Settings
                Section(header: Text("Ollama (Local)")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ollama Host URL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("http://localhost:11434", text: $aiManager.ollamaHost)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    Text("Run Ollama on your Mac and connect over WiFi")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Local AI Settings
                Section(header: Text("Local AI (On-Device)")) {
                    // HuggingFace Token for gated models
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HuggingFace Token")
                            .font(.subheadline)
                        SecureField("hf_...", text: Binding(
                            get: { UserDefaults.standard.string(forKey: "hfToken") ?? "" },
                            set: { UserDefaults.standard.set($0, forKey: "hfToken") }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        Text("Required for some gated models like Nanbeige2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Link("Get token from huggingface.co/settings/tokens", destination: URL(string: "https://huggingface.co/settings/tokens")!)
                            .font(.caption)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Model Cache")
                            Text("Clear to fix chat template issues")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Clear Cache") {
                            LocalLLMService.shared.clearModelCache()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    
                    Text("Models will re-download on next use with fixed chat templates.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Info
                Section(header: Text("Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API keys are stored locally on your device.")
                        Text("Get your API keys from:")
                        Link("• OpenAI Platform", destination: URL(string: "https://platform.openai.com/api-keys")!)
                        Link("• Anthropic Console", destination: URL(string: "https://console.anthropic.com/")!)
                        Link("• Google AI Studio", destination: URL(string: "https://makersuite.google.com/app/apikey")!)
                        Link("• Moonshot AI (Kimi)", destination: URL(string: "https://platform.moonshot.cn/")!)
                        Link("• Zhipu AI (GLM)", destination: URL(string: "https://open.bigmodel.cn/")!)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("AI Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Chat History View

struct ChatHistoryView: View {
    @ObservedObject var aiManager: AIManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(aiManager.sessions) { session in
                    Button(action: {
                        aiManager.selectSession(session)
                        isPresented = false
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(.headline)
                                .lineLimit(1)
                            
                            HStack {
                                Text("\(session.messages.count) messages")
                                Spacer()
                                Text(session.updatedAt, style: .relative)
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .foregroundColor(.primary)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        aiManager.deleteSession(aiManager.sessions[index])
                    }
                }
            }
            .navigationTitle("Chat History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { isPresented = false }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { aiManager.createNewSession() }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct AIAssistantView_Previews: PreviewProvider {
    static var previews: some View {
        AIAssistantView(editorCore: EditorCore())
            .frame(width: 400, height: 600)
    }
}


