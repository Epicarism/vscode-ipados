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
final class LocalLLMService: ObservableObject {
    static let shared = LocalLLMService()
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "VSCodeiPadOS",
        category: "LocalLLM"
    )
    nonisolated(unsafe) private var memoryWarningObserver: NSObjectProtocol?
    
    // Published state
    @Published var isModelLoaded = false
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var statusMessage = "Model not loaded"
    @Published var currentResponse = ""
    @Published var availableModels: [LocalModelConfig] = []
    @Published var currentModelId: String = ""
    @Published var isGenerating = false
    @Published var didTruncateContext = false
    
    // Context window tracking
    private var approximateTokenCount: Int = 0
    
    // HuggingFace token for gated models (stored in Keychain)
    @Published var hfToken: String = "" {
        didSet { KeychainHelper.shared.set(hfToken, forKey: KeychainHelper.hfToken) }
    }
    
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
        // Load HuggingFace token from Keychain
        hfToken = KeychainHelper.shared.get(KeychainHelper.hfToken) ?? ""

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
            AppLogger.ai.error("Failed to load LocalModels.json, using defaults")
            setupDefaultModels()
            return
        }
        
        availableModels = config.models
        currentModelId = config.defaultModelId
        AppLogger.ai.info("Loaded \(config.models.count) models from config")
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
        // 16GB devices (iPad Pro M4): 12GB for model - leaves ~4GB for iOS + app UI
        //   Can run 7B Q8, 13B Q4, even 14B Q4 models
        //   Memory warning handler will unload if we get too close
        // 8GB devices: 5GB for model - can run 7B Q4
        // 4GB devices: 2GB for model - small models only
        let budgetBytes: UInt64
        if physical >= 16 * gib {
            budgetBytes = 12 * gib
        } else if physical >= 8 * gib {
            budgetBytes = 5 * gib
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
            logger.error("Model not found: '\(targetId, privacy: .public)'")
            logger.debug("Available model IDs: \(self.availableModels.map { $0.id }.joined(separator: ", "), privacy: .public)")
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
            // Step 1: Download model files via HubApi (with optional HF token for gated models)
            let hub = HubApi(
                downloadBase: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
                hfToken: hfToken.isEmpty ? nil : hfToken
            )
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
            logger.info("Model loaded: \(config.repo, privacy: .public)")
            
        } catch {
            isDownloading = false
            let errorStr = String(describing: error)
            logger.error("Load failed for \(config.repo, privacy: .public): \(error.localizedDescription, privacy: .public)")
            
            // Check for common HuggingFace errors
            if errorStr.contains("401") || errorStr.contains("403") || errorStr.contains("unauthorized") || errorStr.contains("gated") {
                logger.warning("Auth error detected. HF Token set: \(!self.hfToken.isEmpty, privacy: .public)")
                statusMessage = "Auth error - check HF token in settings"
            }
            
            // Auto-fallback: try next model in the list
            if let currentIndex = availableModels.firstIndex(where: { $0.id == targetId }) {
                let nextIndex = availableModels.index(after: currentIndex)
                if nextIndex < availableModels.endIndex {
                    let fallback = availableModels[nextIndex]
                    logger.info("Trying fallback model: \(fallback.name, privacy: .public)")
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
            AppLogger.ai.info("Patched tokenizer_class: \(tokenizerClass) -> PreTrainedTokenizerFast")
            needsWrite = true
        }
        
        // Nanbeige: SIMPLE template - MLX Swift can't handle complex Jinja (namespace, slicing, etc)
        let isNanbeige = url.path.lowercased().contains("nanbeige")
        AppLogger.ai.debug("patchTokenizerConfig: path=\(url.path), isNanbeige=\(isNanbeige)")
        
        if isNanbeige {
            // Use standard ChatML format - proven to work with swift-jinja
            // Nanbeige's STX/ETX format causes gibberish, ChatML is universal
            let chatmlTemplate = """
{% for message in messages %}{% if loop.first and message['role'] != 'system' %}<|im_start|>system
You are a helpful coding assistant. Always respond in English.<|im_end|>
{% endif %}<|im_start|>{{ message['role'] }}
{{ message['content'] }}<|im_end|>
{% endfor %}{% if add_generation_prompt %}<|im_start|>assistant
{% endif %}
"""
            let existingTemplate = json["chat_template"] as? String
            AppLogger.ai.debug("Nanbeige existing: \(existingTemplate?.prefix(50) ?? "nil")")
            
            json["chat_template"] = chatmlTemplate
            AppLogger.ai.info("Set Nanbeige to ChatML format")
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
        approximateTokenCount = 0
        isModelLoaded = false
        statusMessage = "Model not loaded"
        AppLogger.ai.info("Model unloaded")
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
                    AppLogger.ai.info("Cleared model cache at \(hubCache.path)")
                    statusMessage = "Cache cleared - models will re-download"
                }
            } catch {
                AppLogger.ai.error("Failed to clear cache: \(error)")
                statusMessage = "Failed to clear cache"
            }
        }
    }

    func switchModel(to modelId: String) async {
        unloadModel()
        await loadModel(modelId: modelId)
    }
    
    // MARK: - Context Window Management
    
    /// Check if the approximate token count exceeds 75% of the context window.
    /// If so, reset the session to avoid quality degradation from truncation.
    private func checkAndTruncateIfNeeded() {
        let contextLength = modelConfig?.contextLength ?? 32768
        let threshold = contextLength * 3 / 4
        if approximateTokenCount > threshold {
            logger.warning(
                "Context window approaching limit: ~\(self.approximateTokenCount, privacy: .public) tokens / \(contextLength, privacy: .public) max. Resetting session."
            )
            resetChat()
            approximateTokenCount = 0
            didTruncateContext = true
        }
    }
    
    /// Returns the approximate context window usage as a percentage (0.0 to 1.0+).
    public func contextUsagePercent() -> Double {
        let contextLength = modelConfig?.contextLength ?? 32768
        guard contextLength > 0 else { return 0 }
        return Double(approximateTokenCount) / Double(contextLength)
    }
    
    // MARK: - Chat Interface (non-streaming)

    func chat(messages: [(role: String, content: String)], systemPrompt: String? = nil) async throws -> String {
        guard isModelLoaded, let container = modelContainer else {
            throw LocalLLMError.modelNotLoaded
        }
        
        guard !isGenerating else {
            throw LocalLLMError.alreadyGenerating
        }
        
        isGenerating = true
        defer { isGenerating = false }
        
        // Check context window before processing this message
        checkAndTruncateIfNeeded()
        
        let system = systemPrompt ?? defaultSystemPrompt
        logger.debug("chat() systemPrompt length: \(system.count, privacy: .public)")
        
        // Reuse existing chat session for conversation continuity
        // Only create new session if none exists
        if chatSession == nil {
            chatSession = MLXChatSession(container, instructions: system, generateParameters: generateParams)
        }
        guard let session = chatSession else {
            throw LocalLLMError.modelNotLoaded
        }
        
        // Get last user message only
        let lastUserMessage = messages.last(where: { $0.role == "user" })?.content ?? ""
        logger.debug("chat() user message: '\(String(lastUserMessage.prefix(100)), privacy: .public)'")
        
        let response = try await session.respond(to: lastUserMessage)
        logger.debug("chat() raw response length: \(response.count, privacy: .public)")
        
        // Estimate tokens from this exchange (rough 4 chars per token)
        approximateTokenCount += (lastUserMessage.count + response.count) / 4
        logger.debug("Approximate token count after chat(): ~\(self.approximateTokenCount, privacy: .public)")
        
        // Strip thinking tags
        let cleaned = stripThinkingTags(response)
        logger.debug("chat() cleaned response length: \(cleaned.count, privacy: .public)")
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
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
                    self.logger.debug("chatStream starting with systemPrompt length: \(system.count, privacy: .public)")
                    
                    // Check context window before processing this message
                    self.checkAndTruncateIfNeeded()
                    
                    // Reuse existing chat session for conversation continuity
                    if self.chatSession == nil {
                        self.chatSession = MLXChatSession(container, instructions: system, generateParameters: self.generateParams)
                    }
                    guard let session = self.chatSession else {
                        continuation.finish(throwing: LocalLLMError.modelNotLoaded)
                        return
                    }
                    self.logger.debug("Using existing MLXChatSession")
                    
                    // Get last user message only
                    let lastUserMessage = messages.last(where: { $0.role == "user" })?.content ?? ""
                    
                    // Track tokens for the user message
                    self.approximateTokenCount += lastUserMessage.count / 4
                    
                    // Stream response
                    var chunkCount = 0
                    var totalChars = 0
                    self.logger.debug("Starting streamResponse...")
                    for try await chunk in session.streamResponse(to: lastUserMessage) {
                        chunkCount += 1
                        totalChars += chunk.count
                        if chunkCount <= 3 {
                            self.logger.debug("Chunk \(chunkCount, privacy: .public): '\(String(chunk.prefix(50)), privacy: .public)'")
                        }
                        if !chunk.isEmpty {
                            self.currentResponse += chunk
                            continuation.yield(chunk)
                        }
                    }
                    self.logger.info("Stream finished: \(chunkCount, privacy: .public) chunks, \(totalChars, privacy: .public) chars total")
                    
                    // Estimate tokens from streamed response
                    self.approximateTokenCount += totalChars / 4
                    self.logger.debug("Approximate token count after chatStream(): ~\(self.approximateTokenCount, privacy: .public)")
                    
                    continuation.finish()
                } catch {
                    self.logger.error("chatStream error: \(error.localizedDescription, privacy: .public)")
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
    
    /// Strip <think...</think blocks from model output
    /// These are chain-of-thought tags used by reasoning models (DeepSeek, Qwen thinking, etc.)
    private func stripThinkingTags(_ text: String) -> String {
        var result = text
        
        // First, try to extract content AFTER </think tags (the actual response)
        // If model outputs: <think reasoning</think actual response
        // We want: actual response
        let thinkPattern = #"<think[\s\S]*?</think"#
        if let regex = try? NSRegularExpression(pattern: thinkPattern, options: []) {
            let stripped = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(result.startIndex..., in: result),
                withTemplate: ""
            ).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // If stripping leaves us with content, use it
            if !stripped.isEmpty {
                result = stripped
            } else {
                // Model put EVERYTHING in <think tags with no actual response
                // Extract what's INSIDE the think tags as the response
                AppLogger.ai.warning("Model output was entirely in think tags, extracting content...")
                let extractPattern = #"<think([\s\S]*?)</think"#
                if let extractRegex = try? NSRegularExpression(pattern: extractPattern, options: []),
                   let match = extractRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                   let contentRange = Range(match.range(at: 1), in: text) {
                    result = String(text[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    AppLogger.ai.debug("Extracted \(result.count) chars from think block")
                }
            }
        }
        
        // Remove incomplete opening <think tag at end (partial streaming)
        if let range = result.range(of: "<think") {
            if !result[range.upperBound...].contains("</think") {
                result = String(result[..<range.lowerBound])
            }
        }
        
        // Remove stray <think tags
        result = result.replacingOccurrences(of: "</think", with: "")
        result = result.replacingOccurrences(of: "<think", with: "")
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Reset Chat Context
    
    func resetChat() {
        guard let container = modelContainer else { return }
        chatSession = MLXChatSession(container, instructions: defaultSystemPrompt, generateParameters: generateParams)
        approximateTokenCount = 0
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
