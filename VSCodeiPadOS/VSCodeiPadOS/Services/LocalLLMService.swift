//
//  LocalLLMService.swift
//  VSCodeiPadOS
//
//  Local LLM inference using MLX Swift v2.x
//  Supports multiple models via LocalModels.json config
//

import Foundation
import SwiftUI
import UIKit
import os
import MLXLMCommon
import MLX
import Hub

// MARK: - Model Configuration (from JSON)

struct LocalModelConfig: Codable, Identifiable {
    let id: String
    let name: String
    let repo: String
    let contextLength: Int
    let estimatedMemoryMB: Int
    let chatTemplate: String
    let description: String
}

struct LocalModelsConfig: Codable {
    let version: Int
    let defaultModelId: String
    let models: [LocalModelConfig]
}

// Type alias to avoid conflict with AIManager's ChatSession
typealias MLXChatSession = MLXLMCommon.ChatSession

// MARK: - Local LLM Service

@MainActor
class LocalLLMService: ObservableObject {
    static let shared = LocalLLMService()
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "VSCodeiPadOS",
        category: "LocalLLM"
    )
    private var memoryWarningObserver: NSObjectProtocol?
    
    // Published state
    @Published var isModelLoaded = false
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var statusMessage = "Model not loaded"
    @Published var currentResponse = ""
    @Published var availableModels: [LocalModelConfig] = []
    @Published var currentModelId: String = ""
    @Published var isGenerating = false
    
    // Model container
    private var modelContainer: ModelContainer?
    private var modelConfig: LocalModelConfig?
    private var chatSession: MLXChatSession?
    
    // Generation parameters - using the correct init signature
    private var generateParams: GenerateParameters {
        GenerateParameters(
            maxTokens: 2048,
            temperature: 0.7,
            topP: 0.9,
            repetitionPenalty: 1.1,
            repetitionContextSize: 64
        )
    }
    
    // System prompt
    private let defaultSystemPrompt = "You are a helpful coding assistant. You MUST always respond in English. Never respond in Chinese. Keep answers concise and technical."
    
    // MARK: - Initialization
    
    init() {
        // Observe iOS memory warnings to reduce the chance of OOM termination.
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            
            self.logger.warning(
                "Received memory warning. isModelLoaded=\(self.isModelLoaded, privacy: .public) isGenerating=\(self.isGenerating, privacy: .public)"
            )
            
            // If we're actively generating, don't kill inference mid-flight.
            // If we're idle, unload to free memory.
            guard self.isModelLoaded else { return }
            
            if self.isGenerating {
                self.logger.warning("Memory warning during inference; keeping model loaded.")
            } else {
                self.logger.warning("Model idle during memory warning; unloading model to reclaim memory.")
                self.unloadModel()
                self.statusMessage = "Model unloaded due to low memory"
            }
        }
        
        loadModelsConfig()
    }
    
    deinit {
        if let memoryWarningObserver {
            NotificationCenter.default.removeObserver(memoryWarningObserver)
        }
    }
    
    // MARK: - Config Loading
    
    private func loadModelsConfig() {
        guard let url = Bundle.main.url(forResource: "LocalModels", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(LocalModelsConfig.self, from: data) else {
            print("[LocalLLM] Failed to load LocalModels.json, using defaults")
            setupDefaultModels()
            return
        }
        
        availableModels = config.models
        currentModelId = config.defaultModelId
        print("[LocalLLM] Loaded \(config.models.count) models from config")
    }
    
    private func setupDefaultModels() {
        availableModels = [
            LocalModelConfig(
                id: "nanbeige-3b-4bit",
                name: "Nanbeige 4.1 3B (Q4)",
                repo: "mlx-community/Nanbeige4.1-3B-heretic-4bit",
                contextLength: 32768,
                estimatedMemoryMB: 1800,
                chatTemplate: "chatml",
                description: "DEFAULT - SOTA 3B model"
            )
        ]
        currentModelId = "nanbeige-3b-4bit"
    }
    
    // MARK: - Model Management
    
    /// Configure MLX's GPU cache limit based on device RAM.
    ///
    /// Note: this controls MLX's *cache* memory, not total process memory, but it can reduce
    /// peak memory pressure and help prevent iOS terminating the app.
    private func configureMemoryLimits() {
        let physical = ProcessInfo.processInfo.physicalMemory
        let gib: UInt64 = 1024 * 1024 * 1024
        
        // Memory budget tiers:
        // 16GB devices (iPad Pro M4): 8GB for model - can run 7B Q8 or 13B Q4
        // 8GB devices: 4GB for model - can run 3-7B Q4
        // 4GB devices: 2GB for model - small models only
        let budgetBytes: UInt64
        if physical >= 16 * gib {
            budgetBytes = 8 * gib
        } else if physical >= 8 * gib {
            budgetBytes = 4 * gib
        } else if physical >= 4 * gib {
            budgetBytes = 2 * gib
        } else {
            budgetBytes = min(physical / 2, 2 * gib)
        }
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        
        let physicalStr = formatter.string(fromByteCount: Int64(physical))
        let budgetStr = formatter.string(fromByteCount: Int64(budgetBytes))
        
        let previous = MLX.GPU.cacheLimit
        MLX.GPU.set(cacheLimit: Int(budgetBytes))
        
        let previousStr = formatter.string(fromByteCount: Int64(previous))
        logger.info(
            "Configured MLX.GPU cacheLimit. physical=\(physicalStr, privacy: .public) previous=\(previousStr, privacy: .public) new=\(budgetStr, privacy: .public)"
        )
    }
    
    func loadModel(modelId: String? = nil) async {
        let targetId = modelId ?? currentModelId
        
        guard let config = availableModels.first(where: { $0.id == targetId }) else {
            statusMessage = "Model not found: \(targetId)"
            return
        }
        
        // Unload current model if different
        if isModelLoaded && currentModelId != targetId {
            unloadModel()
        }
        
        guard !isModelLoaded else { return }
        
        modelConfig = config
        currentModelId = targetId
        
        // Apply memory-related tuning before any heavy allocations occur.
        configureMemoryLimits()
        
        isDownloading = true
        statusMessage = "Downloading \(config.name)..."
        downloadProgress = 0
        
        do {
            // Step 1: Download model files via HubApi
            let hub = HubApi(downloadBase: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first)
            let repo = Hub.Repo(id: config.repo)
            
            statusMessage = "Downloading \(config.name)..."
            let modelDir = try await hub.snapshot(from: repo, matching: ["*.json", "*.safetensors", "*.jinja"]) { [weak self] progress in
                Task { @MainActor in
                    self?.downloadProgress = progress.fractionCompleted
                    self?.statusMessage = "Downloading... \(Int(progress.fractionCompleted * 100))%"
                }
            }
            
            // Step 2: Patch tokenizer_config.json if needed
            let tokenizerConfigURL = modelDir.appending(path: "tokenizer_config.json")
            if FileManager.default.fileExists(atPath: tokenizerConfigURL.path) {
                try patchTokenizerConfig(at: tokenizerConfigURL)
            }
            
            // Step 3: Load from patched local directory
            statusMessage = "Loading \(config.name)..."
            modelContainer = try await loadModelContainer(directory: modelDir) { [weak self] progress in
                Task { @MainActor in
                    self?.statusMessage = "Loading model..."
                }
            }
            
            // Create chat session with system prompt
            if let container = modelContainer {
                chatSession = MLXChatSession(container, instructions: defaultSystemPrompt, generateParameters: generateParams)
            }
            
            isModelLoaded = true
            isDownloading = false
            statusMessage = "\(config.name) ready"
            print("[LocalLLM] Model loaded: \(config.repo)")
            
        } catch {
            isDownloading = false
            print("[LocalLLM] Load failed for \(config.repo): \(error)")
            
            // Auto-fallback: try next model in the list
            if let currentIndex = availableModels.firstIndex(where: { $0.id == targetId }) {
                let nextIndex = availableModels.index(after: currentIndex)
                if nextIndex < availableModels.endIndex {
                    let fallback = availableModels[nextIndex]
                    print("[LocalLLM] Trying fallback: \(fallback.name)")
                    statusMessage = "Trying \(fallback.name)..."
                    currentModelId = fallback.id
                    await loadModel(modelId: fallback.id)
                    return
                }
            }
            statusMessage = "Failed: \(error.localizedDescription)"
        }
    }
    
    /// Patch tokenizer_config.json to fix known issues with MLX community models.
    ///
    /// ## Nanbeige 4.1 Chat Template Fix
    ///
    /// **Problem:** `mlx-community/Nanbeige4.1-3B-heretic-4bit` is missing the `chat_template`
    /// field entirely in its `tokenizer_config.json`. The official `Nanbeige/Nanbeige4.1-3B` has
    /// the template, but the MLX community quantization stripped it out. Without a chat template,
    /// the model receives raw unformatted text instead of properly delimited messages, causing
    /// broken/looping output.
    ///
    /// **Root Cause:** Nanbeige uses non-standard STX/ETX control characters (U+0002/U+0003)
    /// as message delimiters instead of ChatML's `<|im_start|>/<|im_end|>` tokens. Format:
    /// ```
    /// ␂system\n{system_prompt}␃\n
    /// ␂user\n{user_message}␃\n
    /// ␂assistant\n{response}␃\n
    /// ```
    /// The official template also defaults to Chinese system prompts ("你是南北阁...").
    ///
    /// **Fix:** Two cases:
    /// 1. MLX version (no template): Inject full Jinja template with STX/ETX tokens + English defaults
    /// 2. Official version (Chinese defaults): String-replace Chinese prompts with English equivalents
    ///
    /// ## TokenizerClass Fix
    ///
    /// The MLX version also uses `"TokenizersBackend"` as `tokenizer_class`, which
    /// `swift-transformers` doesn't recognize. We patch it to `"PreTrainedTokenizerFast"`.
    ///
    /// - Parameter url: Path to the downloaded `tokenizer_config.json`
    private func patchTokenizerConfig(at url: URL) throws {
        let data = try Data(contentsOf: url)
        guard var json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        
        var needsWrite = false
        let tokenizerClass = json["tokenizer_class"] as? String ?? ""
        
        // Fix non-standard tokenizer classes that swift-transformers doesn't recognize
        if tokenizerClass == "TokenizersBackend" {
            json["tokenizer_class"] = "PreTrainedTokenizerFast"
            print("[LocalLLM] Patched tokenizer_class: \(tokenizerClass) -> PreTrainedTokenizerFast")
            needsWrite = true
        }
        
        // Nanbeige MLX version is MISSING chat_template entirely - must add full template
        let existingTemplate = json["chat_template"] as? String
        let isNanbeige = url.path.lowercased().contains("nanbeige")
        
        if isNanbeige && (existingTemplate == nil || existingTemplate?.isEmpty == true) {
            // Full Nanbeige template with English defaults (from official repo)
            // Uses special tokens: ␂system, ␃, ␂user, ␂assistant, etc.
            let nanbeigeTemplate = """
{%- if messages[0]['role'] == 'system' -%}
{{- '\u{0002}system\n' + messages[0]['content'] + '\u{0003}\n' -}}
{%- else -%}
{{- '\u{0002}system\nYou are a helpful coding assistant. Always respond in English.\u{0003}\n' -}}
{%- endif -%}
{%- for message in messages -%}
{%- if message['role'] == 'user' -%}
{{- '\u{0002}user\n' + message['content'] + '\u{0003}\n' -}}
{%- elif message['role'] == 'assistant' -%}
{{- '\u{0002}assistant\n' + message['content'] + '\u{0003}\n' -}}
{%- endif -%}
{%- endfor -%}
{%- if add_generation_prompt -%}
{{- '\u{0002}assistant\n' -}}
{%- endif -%}
"""
            json["chat_template"] = nanbeigeTemplate
            print("[LocalLLM] Added Nanbeige chat_template (was missing in MLX version)")
            needsWrite = true
        } else if let template = existingTemplate, template.contains("你是南北阁") {
            // Official version has template but with Chinese - replace with English
            var patched = template
            patched = patched.replacingOccurrences(
                of: "你是南北阁，一款由BOSS直聘自主研发并训练的专业大语言模型。",
                with: "You are a helpful coding assistant. Always respond in English."
            )
            patched = patched.replacingOccurrences(
                of: "你是一位工具函数调用专家，你会得到一个问题和一组可能的工具函数。根据问题，你需要进行一个或多个函数/工具调用以实现目的，请尽量尝试探索通过工具解决问题。\n如果没有一个函数可以使用，请直接使用自然语言回复用户。\n如果给定的问题缺少函数所需的参数，请使用自然语言进行提问，向用户询问必要信息。\n如果调用结果已经足够回答用户问题，请对历史结果进行总结，使用自然语言回复用户。",
                with: "You are a tool function expert. Based on the question, make function calls to achieve the goal. Always respond in English."
            )
            json["chat_template"] = patched
            print("[LocalLLM] Patched Nanbeige: replaced Chinese defaults with English")
            needsWrite = true
        }
        
        if needsWrite {
            let patched = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
            try patched.write(to: url)
        }
    }
    
    func unloadModel() {
        modelContainer = nil
        chatSession = nil
        modelConfig = nil
        isModelLoaded = false
        statusMessage = "Model not loaded"
        print("[LocalLLM] Model unloaded")
    }
    
    /// Clear all cached models to force re-download with fixed templates
    func clearModelCache() {
        unloadModel()
        
        // Clear HuggingFace Hub cache in Caches directory
        if let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let hubCache = cachesDir.appendingPathComponent("huggingface")
            do {
                if FileManager.default.fileExists(atPath: hubCache.path) {
                    try FileManager.default.removeItem(at: hubCache)
                    print("[LocalLLM] Cleared model cache at \(hubCache.path)")
                    statusMessage = "Cache cleared - models will re-download"
                }
            } catch {
                print("[LocalLLM] Failed to clear cache: \(error)")
                statusMessage = "Failed to clear cache"
            }
        }
    }

    func switchModel(to modelId: String) async {
        unloadModel()
        await loadModel(modelId: modelId)
    }
    
    // MARK: - Chat Interface (non-streaming)
    //
    // IMPORTANT: MLXChatSession.respond(to:) OVERWRITES the internal messages array
    // with just [.user(prompt)], losing any system instructions set during init.
    // The system prompt set via `instructions:` only survives through KV cache on
    // subsequent calls within the SAME session, but on a fresh session it's lost
    // entirely because respond() replaces messages BEFORE the first generate() call.
    //
    // FIX: We embed the system prompt directly into the user message text so it
    // always reaches the model regardless of how ChatSession handles messages.
    // This works reliably with all chat templates (ChatML, Nanbeige STX/ETX, etc.)
    // because the instructions appear as user content.
    //
    // For conversation history, we also embed prior messages since ChatSession
    // only processes the last user message.
    
    func chat(messages: [(role: String, content: String)], systemPrompt: String? = nil) async throws -> String {
        guard isModelLoaded, let container = modelContainer else {
            throw LocalLLMError.modelNotLoaded
        }
        
        guard !isGenerating else {
            throw LocalLLMError.alreadyGenerating
        }
        
        isGenerating = true
        defer { isGenerating = false }
        
        let system = systemPrompt ?? defaultSystemPrompt
        
        // Build a comprehensive prompt that includes system instructions + conversation history.
        // We embed everything into the user message because MLXChatSession.respond()
        // overwrites the messages array, losing system instructions.
        let augmentedPrompt = buildAugmentedPrompt(system: system, messages: messages)
        
        // Create a fresh session for each call (no stale KV cache issues)
        let session = MLXChatSession(container, generateParameters: generateParams)
        let response = try await session.respond(to: augmentedPrompt)
        
        // Strip thinking tags
        let cleaned = stripThinkingTags(response)
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Build a single prompt string that includes system instructions and conversation history.
    /// Uses Nanbeige's native format: \u{0002}role\n{content}\u{0003}\n
    /// This ensures the model sees everything regardless of ChatSession's message handling.
    private func buildAugmentedPrompt(system: String, messages: [(role: String, content: String)]) -> String {
        // Nanbeige uses STX (\u{0002}) and ETX (\u{0003}) control characters
        let STX = "\u{0002}"  // Start of Text
        let ETX = "\u{0003}"  // End of Text
        
        var prompt = ""
        
        // System instructions first
        prompt += "\(STX)system\n\(system)\(ETX)\n"
        
        // Conversation history
        for msg in messages {
            switch msg.role.lowercased() {
            case "user":
                prompt += "\(STX)user\n\(msg.content)\(ETX)\n"
            case "assistant":
                prompt += "\(STX)assistant\n\(msg.content)\(ETX)\n"
            case "system":
                // Already handled above, skip duplicate system messages
                continue
            default:
                // Treat unknown as user
                prompt += "\(STX)user\n\(msg.content)\(ETX)\n"
            }
        }
        
        // Add generation prompt - tells model to start assistant response
        prompt += "\(STX)assistant\n"
        
        return prompt
    }
    
    // MARK: - Streaming Chat (for UI)
    
    func chatStream(messages: [(role: String, content: String)], systemPrompt: String? = nil) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task { @MainActor in
                guard self.isModelLoaded, let container = self.modelContainer else {
                    continuation.finish(throwing: LocalLLMError.modelNotLoaded)
                    return
                }
                
                guard !self.isGenerating else {
                    continuation.finish(throwing: LocalLLMError.alreadyGenerating)
                    return
                }
                
                self.isGenerating = true
                self.currentResponse = ""
                
                do {
                    let system = systemPrompt ?? self.defaultSystemPrompt
                    let augmentedPrompt = self.buildAugmentedPrompt(system: system, messages: messages)
                    
                    // Fresh session — no stale KV cache, system prompt embedded in user text
                    let session = MLXChatSession(container, generateParameters: self.generateParams)
                    
                    // Stream response
                    for try await chunk in session.streamResponse(to: augmentedPrompt) {
                        if !chunk.isEmpty {
                            self.currentResponse += chunk
                            continuation.yield(chunk)
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
                
                self.isGenerating = false
                self.currentResponse = ""
            }
        }
    }
    
    // MARK: - Memory Estimation
    
    func estimateMemoryUsage() -> Int {
        return modelConfig?.estimatedMemoryMB ?? 0
    }
    
    func canFitInMemory(modelId: String, availableMemoryMB: Int) -> Bool {
        guard let config = availableModels.first(where: { $0.id == modelId }) else {
            return false
        }
        return config.estimatedMemoryMB <= availableMemoryMB
    }
    
    // MARK: - Think Tag Filtering
    
    /// Strip <think>...</think> blocks from model output
    /// These are chain-of-thought tags used by reasoning models (DeepSeek, Qwen thinking, etc.)
    private func stripThinkingTags(_ text: String) -> String {
        var result = text
        
        // Remove complete <think>...</think> blocks (including multiline)
        let thinkPattern = #"<think>[\s\S]*?</think>"#
        if let regex = try? NSRegularExpression(pattern: thinkPattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(result.startIndex..., in: result),
                withTemplate: ""
            )
        }
        
        // Remove incomplete opening <think> tag at end (partial streaming)
        if let range = result.range(of: "<think>") {
            if !result[range.upperBound...].contains("</think>") {
                result = String(result[..<range.lowerBound])
            }
        }
        
        // Remove stray </think> tags
        result = result.replacingOccurrences(of: "</think>", with: "")
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Message Conversion
    
    /// Convert tuple messages to Chat.Message history for ChatSession
    private func convertToHistory(messages: [(role: String, content: String)]) -> [Chat.Message] {
        var history: [Chat.Message] = []
        
        for msg in messages {
            switch msg.role.lowercased() {
            case "user":
                history.append(.user(msg.content))
            case "assistant":
                history.append(.assistant(msg.content))
            case "system":
                // System is handled via instructions parameter, skip here
                continue
            default:
                // Treat unknown roles as user
                history.append(.user(msg.content))
            }
        }
        
        return history
    }
    
    // MARK: - Reset Chat Context
    
    func resetChat() {
        guard let container = modelContainer else { return }
        chatSession = MLXChatSession(container, instructions: defaultSystemPrompt, generateParameters: generateParams)
    }
}

// MARK: - Errors

enum LocalLLMError: LocalizedError {
    case modelNotLoaded
    case alreadyGenerating
    case generationFailed(String)
    case downloadFailed(String)
    case invalidModelConfig
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Local model is not loaded. Please load the model first."
        case .alreadyGenerating:
            return "Already generating a response. Please wait."
        case .generationFailed(let reason):
            return "Generation failed: \(reason)"
        case .downloadFailed(let reason):
            return "Download failed: \(reason)"
        case .invalidModelConfig:
            return "Invalid model configuration."
        }
    }
}
