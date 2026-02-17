import Foundation
import SwiftUI

// MARK: - AI Provider Enum

enum AIProvider: String, CaseIterable, Identifiable {
    case openai = "OpenAI"
    case anthropic = "Anthropic"
    case google = "Google"
    case kimi = "Kimi"
    case glm = "GLM"
    case groq = "Groq"
    case deepseek = "DeepSeek"
    case mistral = "Mistral"
    case ollama = "Ollama (Local)"
    case localMLX = "Local AI (On-Device)"
    
    var id: String { rawValue }
    
    var models: [AIModel] {
        switch self {
        case .openai:
            return [
                AIModel(id: "gpt-4o", name: "GPT-4o", provider: .openai),
                AIModel(id: "gpt-4.5-preview", name: "GPT-4.5 Preview", provider: .openai),
                AIModel(id: "o3-mini", name: "o3-mini", provider: .openai),
                AIModel(id: "gpt-4o-mini", name: "GPT-4o Mini", provider: .openai),
                AIModel(id: "gpt-4-turbo", name: "GPT-4 Turbo", provider: .openai),
                AIModel(id: "gpt-3.5-turbo", name: "GPT-3.5 Turbo", provider: .openai)
            ]
        case .anthropic:
            return [
                AIModel(id: "claude-sonnet-4-20250514", name: "Claude Sonnet 4", provider: .anthropic),
                AIModel(id: "claude-3-7-sonnet", name: "Claude 3.7 Sonnet", provider: .anthropic),
                AIModel(id: "claude-3-5-sonnet-20241022", name: "Claude 3.5 Sonnet", provider: .anthropic),
                AIModel(id: "claude-3-5-haiku-20241022", name: "Claude 3.5 Haiku", provider: .anthropic),
                AIModel(id: "claude-3-opus-20240229", name: "Claude 3 Opus", provider: .anthropic)
            ]
        case .google:
            return [
                AIModel(id: "gemini-2.5-pro", name: "Gemini 2.5 Pro", provider: .google),
                AIModel(id: "gemini-2.0-flash", name: "Gemini 2.0 Flash", provider: .google),
                AIModel(id: "gemini-1.5-pro", name: "Gemini 1.5 Pro", provider: .google),
                AIModel(id: "gemini-1.5-flash", name: "Gemini 1.5 Flash", provider: .google),
                AIModel(id: "gemini-pro", name: "Gemini Pro", provider: .google)
            ]
        case .kimi:
            return [
                AIModel(id: "kimi-k2.5", name: "Kimi K2.5 (Most Intelligent)", provider: .kimi),
                AIModel(id: "kimi-k2", name: "Kimi K2 (Code & Agents)", provider: .kimi),
                AIModel(id: "kimi-k2-thinking", name: "Kimi K2 Thinking (Deep Reasoning)", provider: .kimi),
                AIModel(id: "moonshot-v1-128k", name: "Moonshot V1 128K", provider: .kimi),
                AIModel(id: "moonshot-v1-32k", name: "Moonshot V1 32K", provider: .kimi),
                AIModel(id: "moonshot-v1-8k", name: "Moonshot V1 8K", provider: .kimi)
            ]
        case .glm:
            return [
                AIModel(id: "glm-4", name: "GLM-4", provider: .glm),
                AIModel(id: "glm-4-flash", name: "GLM-4 Flash", provider: .glm),
                AIModel(id: "glm-3-turbo", name: "GLM-3 Turbo", provider: .glm)
            ]
        case .ollama:
            return [
                AIModel(id: "codellama", name: "Code Llama", provider: .ollama),
                AIModel(id: "llama3", name: "Llama 3", provider: .ollama),
                AIModel(id: "mistral", name: "Mistral", provider: .ollama),
                AIModel(id: "deepseek-coder", name: "DeepSeek Coder", provider: .ollama)
            ]
        case .localMLX:
            return [
                AIModel(id: "nanbeige-3b-4bit", name: "Nanbeige 4.1 3B (Q4)", provider: .localMLX),
                AIModel(id: "qwen3-1.7b-4bit", name: "Qwen3 1.7B (Q4)", provider: .localMLX),
                AIModel(id: "qwen3-0.6b-4bit", name: "Qwen3 0.6B (Q4)", provider: .localMLX),
                AIModel(id: "qwen3-4b-4bit", name: "Qwen3 4B (Q4)", provider: .localMLX),
                AIModel(id: "nanbeige-1b-4bit", name: "Nanbeige 4.1 1B (Q4)", provider: .localMLX)
            ]
        case .groq:
            return [
                AIModel(id: "llama-3.3-70b-versatile", name: "Llama 3.3 70B Versatile", provider: .groq),
                AIModel(id: "llama-3.1-8b-instant", name: "Llama 3.1 8B Instant", provider: .groq),
                AIModel(id: "mixtral-8x7b-32768", name: "Mixtral 8x7B 32768", provider: .groq),
                AIModel(id: "gemma-2-9b-it", name: "Gemma 2 9B IT", provider: .groq)
            ]
        case .deepseek:
            return [
                AIModel(id: "deepseek-chat", name: "DeepSeek Chat", provider: .deepseek),
                AIModel(id: "deepseek-reasoner", name: "DeepSeek Reasoner", provider: .deepseek),
                AIModel(id: "deepseek-coder", name: "DeepSeek Coder", provider: .deepseek)
            ]
        case .mistral:
            return [
                AIModel(id: "mistral-large-latest", name: "Mistral Large", provider: .mistral),
                AIModel(id: "pixtral-large-latest", name: "Pixtral Large", provider: .mistral),
                AIModel(id: "codestral-latest", name: "Codestral", provider: .mistral),
                AIModel(id: "ministral-8b-latest", name: "Ministral 8B", provider: .mistral)
            ]
        }
    }
    
    var baseURL: String {
        switch self {
        case .openai: return "https://api.openai.com/v1"
        case .anthropic: return "https://api.anthropic.com/v1"
        case .google: return "https://generativelanguage.googleapis.com/v1beta"
        case .kimi: return "https://api.moonshot.cn/v1"
        case .glm: return "https://open.bigmodel.cn/api/paas/v4"
        case .groq: return "https://api.groq.com/openai/v1"
        case .deepseek: return "https://api.deepseek.com/v1"
        case .mistral: return "https://api.mistral.ai/v1"
        case .ollama: return "http://localhost:11434/api"
        case .localMLX: return "local://mlx"
        }
    }
    
    var iconName: String {
        switch self {
        case .openai: return "brain.head.profile"
        case .anthropic: return "sparkles"
        case .google: return "g.circle"
        case .kimi: return "message.circle"
        case .glm: return "brain.fill"
        case .groq: return "bolt.fill"
        case .deepseek: return "fish.fill"
        case .mistral: return "wind"
        case .ollama: return "laptopcomputer"
        case .localMLX: return "cpu"
        }
    }
    
    /// Whether this provider supports native function/tool calling via API
    var supportsNativeTools: Bool {
        switch self {
        case .openai, .anthropic, .groq, .deepseek, .mistral, .kimi, .glm:
            return true
        case .google, .ollama, .localMLX:
            return false
        }
    }
    
    /// Whether this provider uses OpenAI-compatible chat completions format
    var isOpenAICompatible: Bool {
        switch self {
        case .openai, .groq, .deepseek, .mistral, .kimi, .glm:
            return true
        default:
            return false
        }
    }
}

// MARK: - AI Model

struct AIModel: Identifiable, Hashable {
    let id: String
    let name: String
    let provider: AIProvider
}

// MARK: - Chat Message

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    var codeBlocks: [CodeBlock]
    
    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date(), codeBlocks: [CodeBlock] = []) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.codeBlocks = codeBlocks
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

struct CodeBlock: Identifiable, Codable {
    let id: UUID
    let language: String
    let code: String
    
    init(id: UUID = UUID(), language: String, code: String) {
        self.id = id
        self.language = language
        self.code = code
    }
}

// MARK: - Chat Session

struct ChatSession: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String = "New Chat", messages: [ChatMessage] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - AI Manager

class AIManager: ObservableObject {
    // API Keys stored in UserDefaults (consider Keychain for production)
    @AppStorage("openai_api_key") var openAIKey: String = ""
    @AppStorage("anthropic_api_key") var anthropicKey: String = ""
    @AppStorage("google_api_key") var googleKey: String = ""
    @AppStorage("kimi_api_key") var kimiKey: String = ""
    @AppStorage("glm_api_key") var glmKey: String = ""
    @AppStorage("groq_api_key") var groqKey: String = ""
    @AppStorage("deepseek_api_key") var deepseekKey: String = ""
    @AppStorage("mistral_api_key") var mistralKey: String = ""
    @AppStorage("ollama_host") var ollamaHost: String = "http://localhost:11434"
    
    @AppStorage("selected_provider") private var selectedProviderRaw: String = AIProvider.openai.rawValue
    @AppStorage("selected_model_id") private var selectedModelId: String = "gpt-4o"
    
    @Published var currentSession: ChatSession = ChatSession()
    @Published var sessions: [ChatSession] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var streamingResponse = ""
    
    /// Maximum number of tool-call rounds before forcing a text response
    private let maxToolRounds = 5
    
    var selectedProvider: AIProvider {
        get { AIProvider(rawValue: selectedProviderRaw) ?? .openai }
        set { selectedProviderRaw = newValue.rawValue }
    }
    
    var selectedModel: AIModel {
        get {
            selectedProvider.models.first { $0.id == selectedModelId } ?? selectedProvider.models[0]
        }
        set { selectedModelId = newValue.id }
    }
    
    init() {
        loadSessions()
        if sessions.isEmpty {
            createNewSession()
        } else {
            currentSession = sessions[0]
        }
    }
    
    // MARK: - Session Management
    
    func createNewSession() {
        let session = ChatSession()
        sessions.insert(session, at: 0)
        currentSession = session
        saveSessions()
    }
    
    func selectSession(_ session: ChatSession) {
        currentSession = session
    }
    
    func deleteSession(_ session: ChatSession) {
        sessions.removeAll { $0.id == session.id }
        if currentSession.id == session.id {
            currentSession = sessions.first ?? ChatSession()
            if sessions.isEmpty {
                sessions.append(currentSession)
            }
        }
        saveSessions()
    }
    
    func clearCurrentSession() {
        currentSession.messages.removeAll()
        updateSession()
    }
    
    private func updateSession() {
        currentSession.updatedAt = Date()
        if let index = sessions.firstIndex(where: { $0.id == currentSession.id }) {
            sessions[index] = currentSession
        }
        saveSessions()
    }
    
    // MARK: - Persistence
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "ai_chat_sessions")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "ai_chat_sessions"),
           let decoded = try? JSONDecoder().decode([ChatSession].self, from: data) {
            sessions = decoded
        }
    }
    
    // MARK: - API Key Validation
    
    func hasValidAPIKey() -> Bool {
        switch selectedProvider {
        case .openai: return !openAIKey.isEmpty
        case .anthropic: return !anthropicKey.isEmpty
        case .google: return !googleKey.isEmpty
        case .kimi: return !kimiKey.isEmpty
        case .glm: return !glmKey.isEmpty
        case .groq: return !groqKey.isEmpty
        case .deepseek: return !deepseekKey.isEmpty
        case .mistral: return !mistralKey.isEmpty
        case .ollama: return true
        case .localMLX: return true
        }
    }
    
    func getAPIKey() -> String {
        switch selectedProvider {
        case .openai: return openAIKey
        case .anthropic: return anthropicKey
        case .google: return googleKey
        case .kimi: return kimiKey
        case .glm: return glmKey
        case .groq: return groqKey
        case .deepseek: return deepseekKey
        case .mistral: return mistralKey
        case .ollama: return ""
        case .localMLX: return ""
        }
    }
    
    /// Whether the current provider supports tool/function calling
    var supportsToolCalling: Bool {
        return selectedProvider.supportsNativeTools
    }
    
    // MARK: - Send Message
    
    @MainActor
    func sendMessage(_ content: String, context: String? = nil, toolExecutor: AIToolExecutor? = nil) async {
        guard hasValidAPIKey() else {
            error = "Please set your API key in settings"
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: content)
        currentSession.messages.append(userMessage)
        updateSession()
        
        // Update title if first message
        if currentSession.messages.count == 1 {
            currentSession.title = String(content.prefix(50))
            updateSession()
        }
        
        isLoading = true
        error = nil
        streamingResponse = ""
        
        do {
            let response: String
            if let executor = toolExecutor {
                response = try await makeToolAwareRequest(messages: currentSession.messages, context: context, toolExecutor: executor)
            } else if selectedProvider == .localMLX {
                response = try await callLocalMLXStreaming(messages: currentSession.messages, context: context, agentMode: false)
            } else {
                response = try await makeAPIRequest(messages: currentSession.messages, context: context, agentMode: false)
            }
            let assistantMessage = ChatMessage(role: .assistant, content: response, codeBlocks: extractCodeBlocks(from: response))
            currentSession.messages.append(assistantMessage)
            updateSession()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Tool-Aware Request (works for ALL providers)
    
    @MainActor
    private func makeToolAwareRequest(messages: [ChatMessage], context: String?, toolExecutor: AIToolExecutor) async throws -> String {
        if selectedProvider.supportsNativeTools {
            // Native tool calling: OpenAI, Anthropic, Groq, DeepSeek, Mistral, Kimi, GLM
            switch selectedProvider {
            case .anthropic:
                return try await callAnthropicWithTools(messages: messages, context: context, toolExecutor: toolExecutor)
            default:
                // All OpenAI-compatible providers
                return try await callOpenAICompatibleWithTools(messages: messages, context: context, toolExecutor: toolExecutor)
            }
        } else {
            // Text-based tool calling: Google, Ollama, Local MLX
            return try await callWithTextBasedTools(messages: messages, context: context, toolExecutor: toolExecutor)
        }
    }
    
    // MARK: - OpenAI-Compatible with Tools (OpenAI, Groq, DeepSeek, Mistral, Kimi, GLM)
    
    private func callOpenAICompatibleWithTools(messages: [ChatMessage], context: String?, toolExecutor: AIToolExecutor) async throws -> String {
        let provider = selectedProvider
        let baseURL: String
        let apiKey: String
        
        switch provider {
        case .openai:
            baseURL = AIProvider.openai.baseURL
            apiKey = openAIKey
        case .groq:
            baseURL = AIProvider.groq.baseURL
            apiKey = groqKey
        case .deepseek:
            baseURL = AIProvider.deepseek.baseURL
            apiKey = deepseekKey
        case .mistral:
            baseURL = AIProvider.mistral.baseURL
            apiKey = mistralKey
        case .kimi:
            baseURL = AIProvider.kimi.baseURL
            apiKey = kimiKey
        case .glm:
            baseURL = AIProvider.glm.baseURL
            apiKey = glmKey
        default:
            return try await makeAPIRequest(messages: messages, context: context, agentMode: true)
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        let systemPrompt = buildAgentSystemPrompt(context: context)
        let tools = AITool.allCases.map { $0.openAIFunction }
        
        // Build initial messages
        var conversationHistory: [[String: Any]] = [
            ["role": "system", "content": systemPrompt]
        ]
        for msg in messages {
            conversationHistory.append(["role": msg.role.rawValue, "content": msg.content])
        }
        
        // Tool loop — allow up to maxToolRounds of tool calls
        for round in 0..<maxToolRounds {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var body: [String: Any] = [
                "model": selectedModel.id,
                "messages": conversationHistory,
                "tools": tools,
                "tool_choice": round < maxToolRounds - 1 ? "auto" : "none",
                "max_tokens": 4096,
                "temperature": 0.7
            ]
            
            // Some providers don't support tool_choice "none", use "auto" for last round too
            if provider == .groq || provider == .glm {
                body["tool_choice"] = "auto"
            }
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw AIError.apiError(message)
                }
                throw AIError.httpError(httpResponse.statusCode)
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let choices = json?["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any] else {
                throw AIError.invalidResponse
            }
            
            // Check for tool calls
            if let toolCalls = message["tool_calls"] as? [[String: Any]], !toolCalls.isEmpty {
                // Add the assistant message with tool calls to history
                conversationHistory.append(message)
                
                // Execute each tool and add results
                for toolCallData in toolCalls {
                    guard let function = toolCallData["function"] as? [String: Any],
                          let toolName = function["name"] as? String,
                          let tool = AITool(rawValue: toolName),
                          let argsString = function["arguments"] as? String,
                          let argsData = argsString.data(using: .utf8),
                          let args = try? JSONSerialization.jsonObject(with: argsData) as? [String: Any] else {
                        continue
                    }
                    
                    let toolCallId = toolCallData["id"] as? String ?? UUID().uuidString
                    let stringArgs = args.mapValues { "\($0)" }
                    let toolCall = ToolCall(id: toolCallId, tool: tool, arguments: stringArgs)
                    
                    let result = await toolExecutor.execute(toolCall)
                    let resultContent = result.success ? result.output : "Error: \(result.error ?? "Unknown error")"
                    
                    // Add tool result to conversation history in OpenAI format
                    conversationHistory.append([
                        "role": "tool",
                        "tool_call_id": toolCallId,
                        "content": resultContent
                    ])
                }
                
                // Continue loop — model will see tool results and can call more tools or respond
                continue
            }
            
            // No tool calls — return the text content
            if let content = message["content"] as? String {
                return content
            }
            
            throw AIError.invalidResponse
        }
        
        // Exceeded max rounds — do one final request with no tools
        return try await makeAPIRequest(messages: messages, context: context, agentMode: true)
    }
    
    // MARK: - Anthropic with Tools (proper tool loop)
    
    private func callAnthropicWithTools(messages: [ChatMessage], context: String?, toolExecutor: AIToolExecutor) async throws -> String {
        let url = URL(string: "\(AIProvider.anthropic.baseURL)/messages")!
        let systemPrompt = buildAgentSystemPrompt(context: context)
        let tools = AITool.allCases.map { $0.anthropicTool }
        
        // Build initial messages
        var conversationHistory: [[String: Any]] = []
        for msg in messages where msg.role != .system {
            conversationHistory.append(["role": msg.role.rawValue, "content": msg.content])
        }
        
        // Tool loop
        for _ in 0..<maxToolRounds {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(anthropicKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "model": selectedModel.id,
                "max_tokens": 4096,
                "system": systemPrompt,
                "messages": conversationHistory,
                "tools": tools
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw AIError.apiError(message)
                }
                throw AIError.httpError(httpResponse.statusCode)
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let contentBlocks = json?["content"] as? [[String: Any]] else {
                throw AIError.invalidResponse
            }
            
            let stopReason = json?["stop_reason"] as? String
            
            var textParts: [String] = []
            var hasToolUse = false
            var assistantContent: [[String: Any]] = []
            var toolResultContent: [[String: Any]] = []
            
            for block in contentBlocks {
                guard let type = block["type"] as? String else { continue }
                
                if type == "text", let text = block["text"] as? String {
                    textParts.append(text)
                    assistantContent.append(["type": "text", "text": text])
                } else if type == "tool_use" {
                    hasToolUse = true
                    assistantContent.append(block)
                    
                    guard let toolName = block["name"] as? String,
                          let tool = AITool(rawValue: toolName),
                          let input = block["input"] as? [String: Any],
                          let toolUseId = block["id"] as? String else {
                        continue
                    }
                    
                    let stringArgs = input.mapValues { "\($0)" }
                    let toolCall = ToolCall(id: toolUseId, tool: tool, arguments: stringArgs)
                    let result = await toolExecutor.execute(toolCall)
                    let resultContent = result.success ? result.output : "Error: \(result.error ?? "Unknown error")"
                    
                    toolResultContent.append([
                        "type": "tool_result",
                        "tool_use_id": toolUseId,
                        "content": resultContent
                    ])
                }
            }
            
            if hasToolUse {
                // Add assistant message with tool_use blocks
                conversationHistory.append(["role": "assistant", "content": assistantContent])
                // Add user message with tool_result blocks
                conversationHistory.append(["role": "user", "content": toolResultContent])
                // Continue loop
                continue
            }
            
            // No tool use or stop_reason == "end_turn" — return text
            if !textParts.isEmpty {
                return textParts.joined(separator: "\n")
            }
            
            // Fallback if stop_reason indicates we're done
            if stopReason == "end_turn" {
                return textParts.joined(separator: "\n")
            }
            
            throw AIError.invalidResponse
        }
        
        // Exceeded max rounds
        return try await makeAPIRequest(messages: messages, context: context, agentMode: true)
    }
    
    // MARK: - Text-Based Tools (Google, Ollama, Local MLX)
    // For providers without native tool APIs, we include tools in the system prompt
    // and parse structured JSON tool calls from the model's text output.
    
    private func callWithTextBasedTools(messages: [ChatMessage], context: String?, toolExecutor: AIToolExecutor) async throws -> String {
        let systemPrompt = buildTextToolSystemPrompt(context: context)
        
        var conversationMessages = messages
        
        for _ in 0..<maxToolRounds {
            let response = try await makeAPIRequest(messages: conversationMessages, context: nil, agentMode: false, systemOverride: systemPrompt)
            
            // Parse tool calls using the universal parser
            let parsedTools = ToolCallParser.parse(response)
            
            if parsedTools.isEmpty {
                // No tool calls found — return the response as-is
                return response
            }
            
            // Execute parsed tool calls
            var toolResults: [String] = []
            for parsed in parsedTools {
                guard let tool = parsed.tool else { continue }
                let toolCall = ToolCall(tool: tool, arguments: parsed.stringArguments)
                let result = await toolExecutor.execute(toolCall)
                if result.success {
                    toolResults.append("<tool_result name=\"\(tool.rawValue)\">\n\(result.output)\n</tool_result>")
                } else {
                    toolResults.append("<tool_result name=\"\(tool.rawValue)\" error=\"true\">\n\(result.error ?? "Unknown error")\n</tool_result>")
                }
            }
            
            // Add assistant response and tool results to conversation
            conversationMessages.append(ChatMessage(role: .assistant, content: response))
            conversationMessages.append(ChatMessage(role: .user, content: "Tool results:\n\n\(toolResults.joined(separator: "\n\n"))\n\nContinue based on these results."))
        }
        
        // Final round without tools
        return try await makeAPIRequest(messages: conversationMessages, context: nil, agentMode: false, systemOverride: systemPrompt)
    }
    
    // Old parseTextToolCalls removed - now using ToolCallParser.parse()
    
    // MARK: - Agent System Prompts
    
    /// System prompt for providers with native tool calling
    private func buildAgentSystemPrompt(context: String?) -> String {
        var prompt = """
You are an expert AI coding assistant integrated into VS Code for iPadOS. You have access to tools that let you interact with the user's workspace.

## YOUR TOOLS
You have the following tools available:
- **read_file**: Read file contents by path
- **write_file**: Write/overwrite a file (provide COMPLETE content)
- **create_file**: Create a new file with content
- **list_directory**: List files in a directory
- **search_files**: Search text across workspace files
- **get_current_file**: Get the active file's content and metadata
- **get_open_tabs**: List all open tabs
- **get_workspace_info**: Get workspace name, path, file/folder counts
- **insert_code**: Insert code at the cursor position
- **replace_selection**: Replace currently selected text

## RULES
1. When the user asks to modify code, USE TOOLS to actually make changes. Don't just show code — apply it.
2. Use read_file FIRST to see a file's current state before writing changes.
3. Use search_files to find code across the project.
4. write_file must contain the COMPLETE file content (it overwrites).
5. Use insert_code for adding new code at cursor, replace_selection for replacing selected text.
6. You can call multiple tools in sequence to accomplish complex tasks.
7. Provide clear explanations of what you did after making changes.
8. Ask for clarification if the request is ambiguous.
"""
        
        if let context = context, !context.isEmpty {
            prompt += "\n\n--- CURRENT CONTEXT ---\n\(context)"
        }
        
        return prompt
    }
    
    /// System prompt for providers WITHOUT native tool calling (tools described in text)
    /// Uses XML format that most local models understand
    private func buildTextToolSystemPrompt(context: String?) -> String {
        var prompt = """
You are an expert AI coding assistant in VS Code for iPadOS. You have tools to interact with files. Always respond in English.

## TOOL CALLING FORMAT
To call a tool, use this XML format:

<tool_call>
{"name": "tool_name", "arguments": {"arg": "value"}}
</tool_call>

## IMPORTANT: FILE PATHS
Use the EXACT filename shown in the file list. Examples:
- "Welcome.swift" ✓
- "example.js" ✓  
- "/Users/..." ✗ (never use absolute paths)

## AVAILABLE TOOLS

**list_directory** - See available files (use "" for root)
<tool_call>
{"name": "list_directory", "arguments": {"path": ""}}
</tool_call>

**read_file** - Read a file's contents
<tool_call>
{"name": "read_file", "arguments": {"path": "Welcome.swift"}}
</tool_call>

**write_file** - Update a file (provide COMPLETE content)
<tool_call>
{"name": "write_file", "arguments": {"path": "file.swift", "content": "full content here"}}
</tool_call>

**create_file** - Create new file
<tool_call>
{"name": "create_file", "arguments": {"path": "new.swift", "content": "content"}}
</tool_call>

**search_files** - Search in files
<tool_call>
{"name": "search_files", "arguments": {"query": "text", "glob": "*.swift"}}
</tool_call>

**get_current_file** - Get the active file
<tool_call>
{"name": "get_current_file", "arguments": {}}
</tool_call>

**get_open_tabs** - List open tabs
<tool_call>
{"name": "get_open_tabs", "arguments": {}}
</tool_call>

## WORKFLOW
1. First call list_directory to see available files
2. Use read_file before modifying a file
3. write_file must contain the COMPLETE new file content
4. After tool results, explain what you did
"""
        
        if let context = context, !context.isEmpty {
            prompt += "\n\n--- CURRENT FILE ---\n\(context)"
        }
        
        return prompt
    }
    
    // MARK: - Code Actions
    
    @MainActor
    func explainCode(_ code: String, language: String) async -> String {
        let prompt = "Explain the following \(language) code in detail. What does it do, and how does it work?\n\n```\(language)\n\(code)\n```"
        return await sendAndGetResponse(prompt)
    }
    
    @MainActor
    func fixCode(_ code: String, language: String, errorMessage: String? = nil) async -> String {
        var prompt = "Fix any issues in the following \(language) code and explain what was wrong:\n\n```\(language)\n\(code)\n```"
        if let error = errorMessage {
            prompt += "\n\nError message: \(error)"
        }
        return await sendAndGetResponse(prompt)
    }
    
    @MainActor
    func generateTests(_ code: String, language: String) async -> String {
        let prompt = "Generate comprehensive unit tests for the following \(language) code. Include edge cases and typical usage:\n\n```\(language)\n\(code)\n```"
        return await sendAndGetResponse(prompt)
    }
    
    @MainActor
    func refactorCode(_ code: String, language: String, instruction: String) async -> String {
        let prompt = "Refactor the following \(language) code according to this instruction: \(instruction)\n\n```\(language)\n\(code)\n```"
        return await sendAndGetResponse(prompt)
    }
    
    @MainActor
    func documentCode(_ code: String, language: String) async -> String {
        let prompt = "Add comprehensive documentation/comments to the following \(language) code:\n\n```\(language)\n\(code)\n```"
        return await sendAndGetResponse(prompt)
    }
    
    @MainActor
    private func sendAndGetResponse(_ prompt: String) async -> String {
        guard hasValidAPIKey() else {
            return "Error: Please set your API key in settings"
        }
        
        isLoading = true
        error = nil
        
        do {
            let messages = [ChatMessage(role: .user, content: prompt)]
            let response = try await makeAPIRequest(messages: messages, context: nil, agentMode: false)
            isLoading = false
            return response
        } catch {
            isLoading = false
            return "Error: \(error.localizedDescription)"
        }
    }
    
    // MARK: - API Request (non-tool path)
    
    private func makeAPIRequest(messages: [ChatMessage], context: String?, agentMode: Bool, systemOverride: String? = nil) async throws -> String {
        switch selectedProvider {
        case .openai:
            return try await callOpenAI(messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        case .anthropic:
            return try await callAnthropic(messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        case .google:
            return try await callGoogle(messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        case .kimi:
            return try await callOpenAICompatible(provider: .kimi, apiKey: kimiKey, messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        case .glm:
            return try await callOpenAICompatible(provider: .glm, apiKey: glmKey, messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        case .groq:
            return try await callOpenAICompatible(provider: .groq, apiKey: groqKey, messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        case .deepseek:
            return try await callOpenAICompatible(provider: .deepseek, apiKey: deepseekKey, messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        case .mistral:
            return try await callOpenAICompatible(provider: .mistral, apiKey: mistralKey, messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        case .ollama:
            return try await callOllama(messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        case .localMLX:
            return try await callLocalMLX(messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
        }
    }
    
    // MARK: - OpenAI API
    
    private func callOpenAI(messages: [ChatMessage], context: String?, agentMode: Bool, systemOverride: String? = nil) async throws -> String {
        return try await callOpenAICompatible(provider: .openai, apiKey: openAIKey, messages: messages, context: context, agentMode: agentMode, systemOverride: systemOverride)
    }
    
    // MARK: - Unified OpenAI-Compatible Call
    
    private func callOpenAICompatible(provider: AIProvider, apiKey: String, messages: [ChatMessage], context: String?, agentMode: Bool, systemOverride: String? = nil) async throws -> String {
        let url = URL(string: "\(provider.baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var apiMessages: [[String: String]] = []
        
        let systemPrompt = systemOverride ?? (agentMode ? buildAgentSystemPrompt(context: context) : buildSystemPrompt(context: context))
        apiMessages.append(["role": "system", "content": systemPrompt])
        
        for msg in messages {
            apiMessages.append(["role": msg.role.rawValue, "content": msg.content])
        }
        
        let body: [String: Any] = [
            "model": selectedModel.id,
            "messages": apiMessages,
            "max_tokens": 4096,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw AIError.apiError(message)
            }
            throw AIError.httpError(httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        
        return content
    }
    
    // MARK: - Anthropic API
    
    private func callAnthropic(messages: [ChatMessage], context: String?, agentMode: Bool, systemOverride: String? = nil) async throws -> String {
        let url = URL(string: "\(AIProvider.anthropic.baseURL)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anthropicKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var apiMessages: [[String: String]] = []
        for msg in messages where msg.role != .system {
            apiMessages.append(["role": msg.role.rawValue, "content": msg.content])
        }
        
        let systemPrompt = systemOverride ?? (agentMode ? buildAgentSystemPrompt(context: context) : buildSystemPrompt(context: context))
        
        let body: [String: Any] = [
            "model": selectedModel.id,
            "max_tokens": 4096,
            "system": systemPrompt,
            "messages": apiMessages
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw AIError.apiError(message)
            }
            throw AIError.httpError(httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let content = json?["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIError.invalidResponse
        }
        
        return text
    }
    
    // MARK: - Google API
    
    private func callGoogle(messages: [ChatMessage], context: String?, agentMode: Bool, systemOverride: String? = nil) async throws -> String {
        let url = URL(string: "\(AIProvider.google.baseURL)/models/\(selectedModel.id):generateContent?key=\(googleKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var parts: [[String: Any]] = []
        
        let systemPrompt = systemOverride ?? (agentMode ? buildTextToolSystemPrompt(context: context) : buildSystemPrompt(context: context))
        parts.append(["text": "System: \(systemPrompt)"])
        
        for msg in messages {
            let role = msg.role == .assistant ? "Model" : "User"
            parts.append(["text": "\(role): \(msg.content)"])
        }
        
        let body: [String: Any] = [
            "contents": [
                ["parts": parts]
            ],
            "generationConfig": [
                "maxOutputTokens": 4096,
                "temperature": 0.7
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw AIError.apiError(message)
            }
            throw AIError.httpError(httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let candidates = json?["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let respParts = content["parts"] as? [[String: Any]],
              let firstPart = respParts.first,
              let text = firstPart["text"] as? String else {
            throw AIError.invalidResponse
        }
        
        return text
    }
    
    // MARK: - Ollama API
    
    private func callOllama(messages: [ChatMessage], context: String?, agentMode: Bool, systemOverride: String? = nil) async throws -> String {
        let url = URL(string: "\(ollamaHost)/api/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var apiMessages: [[String: String]] = []
        
        let systemPrompt = systemOverride ?? (agentMode ? buildTextToolSystemPrompt(context: context) : buildSystemPrompt(context: context))
        apiMessages.append(["role": "system", "content": systemPrompt])
        
        for msg in messages {
            apiMessages.append(["role": msg.role.rawValue, "content": msg.content])
        }
        
        let body: [String: Any] = [
            "model": selectedModel.id,
            "messages": apiMessages,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            throw AIError.httpError(httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let message = json?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        
        return content
    }
    
    // MARK: - Local MLX (On-Device)
    
    private func isOutOfMemoryError(_ error: Error) -> Bool {
        let ns = error as NSError
        let haystack = "\(ns.domain) \(ns.code) \(ns.localizedDescription)".lowercased()
        
        // Heuristics for common OOM / allocation failures coming from Metal / MLX / libc.
        return haystack.contains("out of memory")
            || haystack.contains("not enough memory")
            || haystack.contains("oom")
            || haystack.contains("allocation failed")
            || haystack.contains("malloc")
            || haystack.contains("metal")
            || haystack.contains("resource exhausted")
    }
    
    @MainActor
    private func callLocalMLX(messages: [ChatMessage], context: String?, agentMode: Bool, systemOverride: String? = nil) async throws -> String {
        let localLLM = LocalLLMService.shared
        
        // Auto-load model if not loaded
        if !localLLM.isModelLoaded {
            await localLLM.loadModel()
        }
        
        guard localLLM.isModelLoaded else {
            throw AIError.apiError("Failed to load local model")
        }
        
        let systemPrompt = systemOverride ?? (agentMode ? buildTextToolSystemPrompt(context: context) : buildSystemPrompt(context: context))
        var chatMessages: [(role: String, content: String)] = []
        
        for msg in messages {
            chatMessages.append((role: msg.role.rawValue, content: msg.content))
        }
        
        do {
            let response = try await localLLM.chat(messages: chatMessages, systemPrompt: systemPrompt)
            return response
        } catch {
            if isOutOfMemoryError(error) {
                // Free memory for next attempt.
                localLLM.unloadModel()
                return "Model ran out of memory. Try a smaller model or close other apps."
            }
            throw error
        }
    }
    
    // MARK: - Local MLX Streaming
    
    @MainActor
    private func callLocalMLXStreaming(messages: [ChatMessage], context: String?, agentMode: Bool, systemOverride: String? = nil) async throws -> String {
        let localLLM = LocalLLMService.shared
        
        // Auto-load model if not loaded
        if !localLLM.isModelLoaded {
            await localLLM.loadModel()
        }
        
        guard localLLM.isModelLoaded else {
            throw AIError.apiError("Failed to load local model")
        }
        
        let systemPrompt = systemOverride ?? (agentMode ? buildTextToolSystemPrompt(context: context) : buildSystemPrompt(context: context))
        var chatMessages: [(role: String, content: String)] = []
        
        for msg in messages {
            chatMessages.append((role: msg.role.rawValue, content: msg.content))
        }
        
        do {
            // Use streaming chat
            let stream = localLLM.chatStream(messages: chatMessages, systemPrompt: systemPrompt)
            
            var fullResponse = ""
            // Incremental think-tag stripping state
            var insideThinkBlock = false
            var pendingBuffer = ""  // Buffer for potential partial tags
            
            for try await chunk in stream {
                fullResponse += chunk
            
            // Incremental think-tag stripping
            pendingBuffer += chunk
            
            // Process buffer for think tags
            while true {
                if insideThinkBlock {
                    // Look for closing </think> tag
                    if let closeRange = pendingBuffer.range(of: "</think>") {
                        // Discard everything up to and including </think>
                        pendingBuffer = String(pendingBuffer[closeRange.upperBound...])
                        insideThinkBlock = false
                    } else if pendingBuffer.count > 20 {
                        // Keep only last few chars in case </think> is split across chunks
                        let keepCount = min(pendingBuffer.count, 8)
                        pendingBuffer = String(pendingBuffer.suffix(keepCount))
                        break
                    } else {
                        break
                    }
                } else {
                    // Look for opening <think> tag
                    if let openRange = pendingBuffer.range(of: "<think>") {
                        // Emit text before <think>
                        let before = String(pendingBuffer[pendingBuffer.startIndex..<openRange.lowerBound])
                        if !before.isEmpty {
                            streamingResponse += before
                        }
                        pendingBuffer = String(pendingBuffer[openRange.upperBound...])
                        insideThinkBlock = true
                    } else {
                        // No <think> found — check for partial tag at end
                        // e.g. buffer ends with "<thi" which could be start of "<think>"
                        let tagPrefix = "<think>"
                        var safeEnd = pendingBuffer.count
                        for i in 1..<tagPrefix.count {
                            if pendingBuffer.hasSuffix(String(tagPrefix.prefix(i))) {
                                safeEnd = pendingBuffer.count - i
                                break
                            }
                        }
                        if safeEnd > 0 {
                            let safeText = String(pendingBuffer.prefix(safeEnd))
                            if !safeText.isEmpty {
                                streamingResponse += safeText
                            }
                            pendingBuffer = String(pendingBuffer.suffix(pendingBuffer.count - safeEnd))
                        }
                        break
                    }
                }
            }
        }
        
        // Flush remaining buffer (if not inside a think block)
        if !insideThinkBlock && !pendingBuffer.isEmpty {
            // Final check: strip any stray </think> tags
            let cleaned = pendingBuffer.replacingOccurrences(of: "</think>", with: "")
            if !cleaned.isEmpty {
                streamingResponse += cleaned
            }
        }
        
            // Return the clean display text (what was streamed to the UI)
            let finalResponse = streamingResponse.trimmingCharacters(in: .whitespacesAndNewlines)
            return finalResponse.isEmpty ? fullResponse.trimmingCharacters(in: .whitespacesAndNewlines) : finalResponse
        } catch {
            if isOutOfMemoryError(error) {
                // Free memory for next attempt.
                localLLM.unloadModel()
                let message = "Model ran out of memory. Try a smaller model or close other apps."
                streamingResponse = message
                return message
            }
            throw error
        }
    }
    
    // MARK: - Helpers
    
    private func buildSystemPrompt(context: String?) -> String {
        var prompt = """
You are an expert coding assistant integrated into a code editor on iPadOS. You help developers write, debug, explain, and improve their code. Always respond in English.

Guidelines:
- Provide clear, concise explanations
- Use code blocks with proper language tags for code snippets
- Suggest best practices and optimizations
- Be helpful with debugging and error resolution
- When generating code, ensure it's complete and runnable
- ALWAYS respond in English regardless of input language
- Never output raw XML tags like <think> or </think>
"""
        
        if let context = context, !context.isEmpty {
            prompt += "\n\nCurrent file context:\n```\n\(context)\n```"
        }
        
        return prompt
    }
    
    private func extractCodeBlocks(from text: String) -> [CodeBlock] {
        var blocks: [CodeBlock] = []
        let pattern = "```(\\w*)\\n([\\s\\S]*?)```"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return blocks
        }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        for match in matches {
            if let langRange = Range(match.range(at: 1), in: text),
               let codeRange = Range(match.range(at: 2), in: text) {
                let language = String(text[langRange])
                let code = String(text[codeRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                blocks.append(CodeBlock(language: language.isEmpty ? "text" : language, code: code))
            }
        }
        
        return blocks
    }
}

// MARK: - AI Errors

enum AIError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case noAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from AI service"
        case .httpError(let code): return "HTTP Error: \(code)"
        case .apiError(let message): return message
        case .noAPIKey: return "No API key configured"
        }
    }
}
