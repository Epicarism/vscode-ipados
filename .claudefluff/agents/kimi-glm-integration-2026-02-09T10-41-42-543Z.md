# Agent: kimi-glm-integration
**Status:** done
**Tokens:** 4,323
**Cost:** $0.0000
**Time:** 2026-02-09T10:41:42.543Z

## Task
Add Kimi (Moonshot AI) and GLM (Zhipu AI) providers to AIManager.swift:

1. Add new cases to AIProvider enum:
   - .kimi = "Kimi" with baseURL https://api.moonshot.cn/v1
   - .glm = "GLM" with baseURL https://open.bigmodel.cn/api/paas/v4

2. Add models for each:
   - Kimi: moonshot-v1-8k, moonshot-v1-32k, moonshot-v1-128k
   - GLM: glm-4, glm-4-flash, glm-3-turbo

3. Add @AppStorage properties:
   - @AppStorage("kimi_api_key") var kimiKey: String = ""
   - @AppStorage("glm_api_key") var glmKey: String = ""

4. Update hasValidAPIKey() and getAPIKey() to include both providers

5. Add callKimi() and callGLM() methods (similar to OpenAI format - both use OpenAI-compatible API)

6. Update makeAPIRequest switch to handle .kimi and .glm cases

7. Add iconNames: kimi -> "message.circle", glm -> "brain.fill"

## Response
>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/AIManager.swift"}
>>>END

Now I'll add the Kimi and GLM providers to AIManager.swift. I'll create patches for each section that needs to be modified.

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/AIManager.swift
>>>FIND
enum AIProvider: String, CaseIterable, Identifiable {
    case openai = "OpenAI"
    case anthropic = "Anthropic"
    case google = "Google"
    case ollama = "Ollama (Local)"
    
    var id: String { rawValue }
>>>REPLACE
enum AIProvider: String, CaseIterable, Identifiable {
    case openai = "OpenAI"
    case anthropic = "Anthropic"
    case google = "Google"
    case ollama = "Ollama (Local)"
    case kimi = "Kimi"
    case glm = "GLM"
    
    var id: String { rawValue }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/AIManager.swift
>>>FIND
        case .ollama:
            return [
                AIModel(id: "codellama", name: "Code Llama", provider: .ollama),
                AIModel(id: "llama3", name: "Llama 3", provider: .ollama),
                AIModel(id: "mistral", name: "Mistral", provider: .ollama),
                AIModel(id: "deepseek-coder", name: "DeepSeek Coder", provider: .ollama)
            ]
        }
    }
>>>REPLACE
        case .ollama:
            return [
                AIModel(id: "codellama", name: "Code Llama", provider: .ollama),
                AIModel(id: "llama3", name: "Llama 3", provider: .ollama),
                AIModel(id: "mistral", name: "Mistral", provider: .ollama),
                AIModel(id: "deepseek-coder", name: "DeepSeek Coder", provider: .ollama)
            ]
        case .kimi:
            return [
                AIModel(id: "moonshot-v1-8k", name: "Moonshot v1 8K", provider: .kimi),
                AIModel(id: "moonshot-v1-32k", name: "Moonshot v1 32K", provider: .kimi),
                AIModel(id: "moonshot-v1-128k", name: "Moonshot v1 128K", provider: .kimi)
            ]
        case .glm:
            return [
                AIModel(id: "glm-4", name: "GLM-4", provider: .glm),
                AIModel(id: "glm-4-flash", name: "GLM-4 Flash", provider: .glm),
                AIModel(id: "glm-3-turbo", name: "GLM-3 Turbo", provider: .glm)
            ]
        }
    }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/AIManager.swift
>>>FIND
    var baseURL: String {
        switch self {
        case .openai: return "https://api.openai.com/v1"
        case .anthropic: return "https://api.anthropic.com/v1"
        case .google: return "https://generativelanguage.googleapis.com/v1beta"
        case .ollama: return "http://localhost:11434/api"
        }
    }
>>>REPLACE
    var baseURL: String {
        switch self {
        case .openai: return "https://api.openai.com/v1"
        case .anthropic: return "https://api.anthropic.com/v1"
        case .google: return "https://generativelanguage.googleapis.com/v1beta"
        case .ollama: return "http://localhost:11434/api"
        case .kimi: return "https://api.moonshot.cn/v1"
        case .glm: return "https://open.bigmodel.cn/api/paas/v4"
        }
    }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/AIManager.swift
>>>FIND
    var iconName: String {
        switch self {
        case .openai: return "brain.head.profile"
        case .anthropic: return "sparkles"
        case .google: return "g.circle"
        case .ollama: return "laptopcomputer"
        }
    }
>>>REPLACE
    var iconName: String {
        switch self {
        case .openai: return "brain.head.profile"
        case .anthropic: return "sparkles"
        case .google: return "g.circle"
        case .ollama: return "laptopcomputer"
        case .kimi: return "message.circle"
        case .glm: return "brain.fill"
        }
    }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/AIManager.swift
>>>FIND
    // API Keys stored in UserDefaults (consider Keychain for production)
    @AppStorage("openai_api_key") var openAIKey: String = ""
    @AppStorage("anthropic_api_key") var anthropicKey: String = ""
    @AppStorage("google_api_key") var googleKey: String = ""
    @AppStorage("ollama_host") var ollamaHost: String = "http://localhost:11434"
>>>REPLACE
    // API Keys stored in UserDefaults (consider Keychain for production)
    @AppStorage("openai_api_key") var openAIKey: String = ""
    @AppStorage("anthropic_api_key") var anthropicKey: String = ""
    @AppStorage("google_api_key") var googleKey: String = ""
    @AppStorage("ollama_host") var ollamaHost: String = "http://localhost:11434"
    @AppStorage("kimi_api_key") var kimiKey: String = ""
    @AppStorage("glm_api_key") var glmKey: String = ""
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/AIManager.swift
>>>FIND
    func hasValidAPIKey() -> Bool {
        switch selectedProvider {
        case .openai: return !openAIKey.isEmpty
        case .anthropic: return !anthropicKey.isEmpty
        case .google: return !googleKey.isEmpty
        case .ollama: return true // Ollama doesn't require API key
        }
    }
    
    func getAPIKey() -> String {
        switch selectedProvider {
        case .openai: return openAIKey
        case .anthropic: return anthropicKey
        case .google: return googleKey
        case .ollama: return ""
        }
    }
>>>REPLACE
    func hasValidAPIKey() -> Bool {
        switch selectedProvider {
        case .openai: return !openAIKey.isEmpty
        case .anthropic: return !anthropicKey.isEmpty
        case .google: return !googleKey.isEmpty
        case .ollama: return true // Ollama doesn't require API key
        case .kimi: return !kimiKey.isEmpty
        case .glm: return !glmKey.isEmpty
        }
    }
    
    func getAPIKey() -> String {
        switch selectedProvider {
        case .openai: return openAIKey
        case .anthropic: return anthropicKey
        case .google: return googleKey
        case .ollama: return ""
        case .kimi: return kimiKey
        case .glm: return glmKey
        }
    }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/AIManager.swift
>>>FIND
    private func makeAPIRequest(messages: [ChatMessage], context: String?) async throws -> String {
        switch selectedProvider {
        case .openai:
            return try await callOpenAI(messages: messages, context: context)
        case .anthropic:
            return try await callAnthropic(messages: messages, context: context)
        case .google:
            return try await callGoogle(messages: messages, context: context)
        case .ollama:
            return try await callOllama(messages: messages, context: context)
        }
    }
>>>REPLACE
    private func makeAPIRequest(messages: [ChatMessage], context: String?) async throws -> String {
        switch selectedProvider {
        case .openai:
            return try await callOpenAI(messages: messages, context: context)
        case .anthropic:
            return try await callAnthropic(messages: messages, context: context)
        case .google:
            return try await callGoogle(messages: messages, context: context)
        case .ollama:
            return try await callOllama(messages: messages, context: context)
        case .kimi:
            return try await callKimi(messages: messages, context: context)
        case .glm:
            return try await callGLM(messages: messages, context: context)
        }
    }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/AIManager.swift
>>>FIND
        return content
    }
    
    // MARK: - Helpers
    
    private func buildSystemPrompt(context: String?) -> String {
>>>REPLACE
        return content
    }
    
    // MARK: - Kimi API (Moonshot AI)
    
    private func callKimi(messages: [ChatMessage], context: String?) async throws -> String {
        let url = URL(string: "\(AIProvider.kimi.baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(kimiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var apiMessages: [[String: String]] = []
        
        // Add system message with context
        let systemPrompt = buildSystemPrompt(context: context)
        apiMessages.append(["role": "system", "content": systemPrompt])
        
        // Add conversation messages
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
    
    // MARK: - GLM API (Zhipu AI)
    
    private func callGLM(messages: [ChatMessage], context: String?) async throws -> String {
        let url = URL(string: "\(AIProvider.glm.baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(glmKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var apiMessages: [[String: String]] = []
        
        // Add system message with context
        let systemPrompt = buildSystemPrompt(context: context)
        apiMessages.append(["role": "system", "content": systemPrompt])
        
        // Add conversation messages
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
    
    // MARK: - Helpers
    
    private func buildSystemPrompt(context: String?) -> String {
>>>END

>>>REPORT
Successfully added Kimi (Moonshot AI) and GLM (Zhipu AI) providers to AIManager.swift with the following changes:

1. **AIProvider enum** (lines 6-11): Added `.kimi = "Kimi"` and `.glm = "GLM"` cases

2. **Models** (lines 36-48): Added models for each provider:
   - Kimi: moonshot-v1-8k, moonshot-v1-32k, moonshot-v1-128k
   - GLM: glm-4, glm-4-flash, glm-3-turbo

3. **Base URLs** (lines 46-53): Added:
   - Kimi: https://api.moonshot.cn/v1
   - GLM: https://open.bigmodel.cn/api/paas/v4

4. **Icon names** (lines 55-62): Added:
   - Kimi: "message.circle"
   - GLM: "brain.fill"

5. **API key storage** (lines 131-136): Added:
   - `@AppStorage("kimi_api_key") var kimiKey: String = ""`
   - `@AppStorage("glm_api_key") var glmKey: String = ""`

6. **hasValidAPIKey()** (lines 220-228): Added cases for `.kimi` and `.glm`

7. **getAPIKey()** (lines 229-237): Added cases for `.kimi` and `.glm`

8. **makeAPIRequest()** (lines 330-341): Added routing for `.kimi` and `.glm` cases

9. **API methods**: Added `callKimi()` and `callGLM()` methods that use OpenAI-compatible API format with:
   - Bearer token authentication
   - Standard chat completions endpoint structure
   - Same error handling pattern as existing providers
>>>END
