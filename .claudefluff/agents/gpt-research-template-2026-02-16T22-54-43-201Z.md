# Agent: gpt-research-template
**Status:** done
**Tokens:** 0
**Cost:** $0.0000
**Time:** 2026-02-16T22:54:43.201Z

## Task
Research: What is the EXACT Jinja2 chat_template format that works with HuggingFace swift-transformers for ChatML models? Find working examples from Qwen, Llama, or similar. The template must work with MLXLMCommon.ChatSession. Return the exact template string.

## Response




---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg/PLAYGROUND/vscode-ipados" not found




---

## 🔧 TOOL RESULTS

[run_command]
/Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS/VSCodeiPadOS
total 256
drwxr-xr-x@ 27 danielswagg  staff    864 Feb 16 13:58 .
drwxr-xr-x@ 18 danielswagg  staff    576 Feb 16 21:11 ..
-rw-r--r--@  1 danielswagg  staff   6148 Feb 10 18:17 .DS_Store
-rw-r--r--@  1 danielswagg  staff     50 Feb  9 12:00 .tooling_note.txt
drwxr-xr-x@  5 danielswagg  staff    160 Feb 10 12:29 App
drwxr-xr-x@  4 danielswagg  staff    128 Feb  8 20:24 Assets.xcassets
drwxr-xr-x@  4 danielswagg  staff    128 Feb 10 22:02 Commands
-rw-r--r--@  1 danielswagg  staff  57021 Feb 16 15:03 ContentView.swift
-rw-r--r--@  1 danielswagg  staff   8323 Feb  8 20:10 ContentView_shift_arrow.patch
drwxr-xr-x@ 15 danielswagg  staff    480 Feb 10 16:19 Docs
drwxr-xr-x@ 10 danielswagg  staff    320 Feb  9 13:03 Extensions
-rw-r--r--@  1 danielswagg  staff   2347 Feb  8 20:20 FIX_SUMMARY.md
-rw-r--r--@  1 danielswagg  staff   2876 Feb  8 20:16 IMPLEMENTATION_SUMMARY.md
-rw-r--r--@  1 danielswagg  staff    764 Feb 10 22:19 Info.plist
-rw-r--r--@  1 danielswagg  staff   3689 Feb 10 12:27 KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
-rw-r--r--@  1 danielswagg  staff   1208 Feb  8 20:09 KeyboardShortcuts.md
-rw-r--r--@  1 danielswagg  staff   6849 Feb  9 17:28 MULTI_WINDOW_IMPLEMENTATION.md
drwxr-xr-x@ 10 danielswagg  staff    320 Feb  9 11:31 Models
-rw-r--r--@  1 danielswagg  staff   6200 Feb  9 17:27 MultiWindowSupport.md
drwxr-xr-x@  5 danielswagg  staff    160 Feb 16 20:30 Resources
-rw-r--r--@  1 danielswagg  staff   7275 Feb  9 17:20 SceneDelegate.swift
drwxr-xr-x@ 46 danielswagg  staff   1472 Feb 16 20:05 Services
-rw-r--r--@  1 danielswagg  staff   2389 Feb  8 20:05 SyntaxHighlighter_Optimizations.md
drwxr-xr-x@  2 danielswagg  staff     64 Feb  9 16:52 Tests
drwxr-xr-x@ 14 danielswagg  staff    448 Feb  9 20:58 UITests
drwxr-xr-x@  5 danielswagg  staff    160 Feb 10 16:12 Utils
drwxr-xr-x@ 25 danielswagg  staff    800 Feb 16 21:21 Views





---

## 🔧 TOOL RESULTS

[search]
Found 30 matches:
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Services_LocalLLMService.swift.2026-02-16T22-47-21-340Z.bak:11:import MLXLMCommon
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Services_LocalLLMService.swift.2026-02-16T22-47-21-340Z.bak:34:typealias MLXChatSession = MLXLMCommon.ChatSession
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Services_LocalLLMService.swift.2026-02-16T22-47-21-357Z.bak:11:import MLXLMCommon
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Services_LocalLLMService.swift.2026-02-16T22-47-21-357Z.bak:34:typealias MLXChatSession = MLXLMCommon.ChatSession
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Services_LocalLLMService.swift.2026-02-16T22-47-21-273Z.bak:11:import MLXLMCommon
.patch-backups/VSCodeiPadOS_VSCodeiPadOS_Services_LocalLLMService.swift.2026-02-16T22-47-21-273Z.bak:34:typealias MLXChatSession = MLXLMCommon.ChatSession
VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj:518:				89659703AAAA0004005B984D /* MLXLMCommon */,
VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj:983:		89659703AAAA0004005B984D /* MLXLMCommon */ = {
VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj:986:			productName = MLXLMCommon;
VSCodeiPadOS/VSCodeiPadOS/Services/LocalLLMService.swift:11:import MLXLMCommon
VSCodeiPadOS/VSCodeiPadOS/Services/LocalLLMService.swift:34:typealias MLXChatSession = MLXLMCommon.ChatSession
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:547:MLXLMCommon, MLXLLM, MLXVLM and MLXEmbedders have moved to a new repository
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:1185:import MLXLMCommon
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:1279:import MLXLMCommon
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:1399:import MLXLMCommon
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:2015:The MLXLLM, MLXVLM, MLXLMCommon, and MLXEmbedders libraries are available
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:2046:See also [MLXLMCommon](Libraries/MLXLMCommon). You can get started with a wide
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:2076:🌐 https://raw.githubusercontent.com/ml-explore/mlx-swift-lm/main/Libraries/MLXLMCommon/ChatSession.swift
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:2381:                    let (stream, task) = MLXLMCommon.generateTask(
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:2458:🌐 https://raw.githubusercontent.com/ml-explore/mlx-swift-lm/main/Libraries/MLXLMCommon/Load.swift
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:2574:🌐 https://raw.githubusercontent.com/ml-explore/mlx-swift-lm/main/Libraries/MLXLMCommon/ModelContainer.swift
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:2750:            try MLXLMCommon.generate(
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:2802:import MLXLMCommon
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:3312:🌐 https://raw.githubusercontent.com/ml-explore/mlx-swift-lm/main/Libraries/MLXLMCommon/ModelFactory.swift
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:3631:/// API in MLXLMCommon use code present in MLXLLM:
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:3635:///     public static func modelFactory() -> (any MLXLMCommon.ModelFactory)? {
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:3724:import MLXLMCommon
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:3755:import MLXLMCommon
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:3811:- mlx-swift-lm/Libraries/MLXLMCommon/ChatSession.swift - Core API
.claudefluff/agents/opus-fixer-3-2026-02-16T22-47-11-218Z.md:3812:- mlx-swift-lm/Libraries/MLXLMCommon/ModelFactory.swift - Loading functions




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 6321ad5d9c01
File: VSCodeiPadOS/VSCodeiPadOS/Services/LocalLLMService.swift (lines 2-260 of 464)
────────────────────────────────────────
2|bcb3c8|//  LocalLLMService.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|cbf07f|//  Local LLM inference using MLX Swift v2.x
6|ddd2ce|//  Supports multiple models via LocalModels.json config
7|8d0643|//
8|adc83b|
9|8b6b78|import Foundation
10|d755ba|import SwiftUI
11|87bf5b|import MLXLMCommon
12|fcdaf9|import MLX
13|1414ec|import Hub
14|adc83b|
15|661042|// MARK: - Model Configuration (from JSON)
16|adc83b|
17|58b895|struct LocalModelConfig: Codable, Identifiable {
18|2dd15d|    let id: String
19|a5193b|    let name: String
20|016b4e|    let repo: String
21|6b86e5|    let contextLength: Int
22|c7f3cc|    let estimatedMemoryMB: Int
23|d32790|    let chatTemplate: String
24|8dc0c7|    let description: String
25|b31277|}
26|adc83b|
27|4e8ff8|struct LocalModelsConfig: Codable {
28|5d06c6|    let version: Int
29|593433|    let defaultModelId: String
30|729498|    let models: [LocalModelConfig]
31|b31277|}
32|adc83b|
33|69d19c|// Type alias to avoid conflict with AIManager's ChatSession
34|e4b95c|typealias MLXChatSession = MLXLMCommon.ChatSession
35|adc83b|
36|7d4134|// MARK: - Local LLM Service
37|adc83b|
38|69d728|@MainActor
39|f6f34f|class LocalLLMService: ObservableObject {
40|321987|    static let shared = LocalLLMService()
41|b4687f|    
42|701d46|    // Published state
43|b8250f|    @Published var isModelLoaded = false
44|c7af8c|    @Published var isDownloading = false
45|d26f25|    @Published var downloadProgress: Double = 0
46|7b4963|    @Published var statusMessage = "Model not loaded"
47|602e38|    @Published var currentResponse = ""
48|36741b|    @Published var availableModels: [LocalModelConfig] = []
49|05a5ff|    @Published var currentModelId: String = ""
50|e0d026|    @Published var isGenerating = false
51|b4687f|    
52|4bf2dd|    // Model container
53|e94929|    private var modelContainer: ModelContainer?
54|4955f3|    private var modelConfig: LocalModelConfig?
55|b1331c|    private var chatSession: MLXChatSession?
56|b4687f|    
57|06e368|    // Generation parameters - using the correct init signature
58|b849fb|    private var generateParams: GenerateParameters {
59|c3e037|        GenerateParameters(
60|4d6978|            maxTokens: 2048,
61|349726|            temperature: 0.7,
62|d2098b|            topP: 0.9,
63|55b699|            repetitionPenalty: 1.1,
64|95249f|            repetitionContextSize: 64
65|3143a4|        )
66|27e597|    }
67|b4687f|    
68|ecdc78|    // System prompt
69|b4f832|    private let defaultSystemPrompt = "You are a helpful coding assistant running locally on iPad. You MUST always respond in English. Help with code, explain concepts, and assist with development tasks. Be concise and accurate. Never output raw thinking tags."
70|b4687f|    
71|7dca75|    // MARK: - Initialization
72|b4687f|    
73|359b1b|    init() {
74|3003b9|        loadModelsConfig()
75|27e597|    }
76|b4687f|    
77|f19d5a|    // MARK: - Config Loading
78|b4687f|    
79|2f6cb1|    private func loadModelsConfig() {
80|e6fb45|        guard let url = Bundle.main.url(forResource: "LocalModels", withExtension: "json"),
81|e288ad|              let data = try? Data(contentsOf: url),
82|cf5947|              let config = try? JSONDecoder().decode(LocalModelsConfig.self, from: data) else {
83|785945|            print("[LocalLLM] Failed to load LocalModels.json, using defaults")
84|6870dc|            setupDefaultModels()
85|bef5d6|            return
86|5f3077|        }
87|d6ed84|        
88|1f2230|        availableModels = config.models
89|5372cf|        currentModelId = config.defaultModelId
90|419996|        print("[LocalLLM] Loaded \(config.models.count) models from config")
91|27e597|    }
92|b4687f|    
93|13e10e|    private func setupDefaultModels() {
94|6dd3a6|        availableModels = [
95|cf3972|            LocalModelConfig(
96|8fca83|                id: "nanbeige-3b-4bit",
97|77da0e|                name: "Nanbeige 4.1 3B (Q4)",
98|65751c|                repo: "mlx-community/Nanbeige4.1-3B-heretic-4bit",
99|2df97e|                contextLength: 32768,
100|c7b40b|                estimatedMemoryMB: 1800,
101|ccf8e8|                chatTemplate: "chatml",
102|ca92af|                description: "DEFAULT - SOTA 3B model"
103|43d041|            )
104|220505|        ]
105|09761b|        currentModelId = "nanbeige-3b-4bit"
106|27e597|    }
107|b4687f|    
108|37fc5c|    // MARK: - Model Management
109|b4687f|    
110|640adb|    func loadModel(modelId: String? = nil) async {
111|95cf61|        let targetId = modelId ?? currentModelId
112|d6ed84|        
113|b9b915|        guard let config = availableModels.first(where: { $0.id == targetId }) else {
114|dc472a|            statusMessage = "Model not found: \(targetId)"
115|bef5d6|            return
116|5f3077|        }
117|d6ed84|        
118|da870d|        // Unload current model if different
119|5a3ada|        if isModelLoaded && currentModelId != targetId {
120|cd434f|            unloadModel()
121|5f3077|        }
122|d6ed84|        
123|4ff039|        guard !isModelLoaded else { return }
124|d6ed84|        
125|b90fe7|        modelConfig = config
126|1c6000|        currentModelId = targetId
127|56467d|        isDownloading = true
128|b65fa8|        statusMessage = "Downloading \(config.name)..."
129|c966df|        downloadProgress = 0
130|d6ed84|        
131|4da690|        do {
132|4c4fa1|            // Step 1: Download model files via HubApi
133|1f7f11|            let hub = HubApi(downloadBase: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first)
134|b11ac8|            let repo = Hub.Repo(id: config.repo)
135|3070d1|            
136|43588f|            statusMessage = "Downloading \(config.name)..."
137|5ad138|            let modelDir = try await hub.snapshot(from: repo, matching: ["*.json", "*.safetensors", "*.jinja"]) { [weak self] progress in
138|df2890|                Task { @MainActor in
139|70839c|                    self?.downloadProgress = progress.fractionCompleted
140|5e7594|                    self?.statusMessage = "Downloading... \(Int(progress.fractionCompleted * 100))%"
141|4e2d32|                }
142|a7dc16|            }
143|3070d1|            
144|1e8fbf|            // Step 2: Patch tokenizer_config.json if needed
145|b7866c|            let tokenizerConfigURL = modelDir.appending(path: "tokenizer_config.json")
146|0323bb|            if FileManager.default.fileExists(atPath: tokenizerConfigURL.path) {
147|fde120|                try patchTokenizerConfig(at: tokenizerConfigURL)
148|a7dc16|            }
149|3070d1|            
150|f3c70d|            // Step 3: Load from patched local directory
151|ebd7b6|            statusMessage = "Loading \(config.name)..."
152|0f15d7|            modelContainer = try await loadModelContainer(directory: modelDir) { [weak self] progress in
153|df2890|                Task { @MainActor in
154|5f40ba|                    self?.statusMessage = "Loading model..."
155|4e2d32|                }
156|a7dc16|            }
157|3070d1|            
158|cb2e88|            // Create chat session with system prompt
159|d5b266|            if let container = modelContainer {
160|030c8b|                chatSession = MLXChatSession(container, instructions: defaultSystemPrompt, generateParameters: generateParams)
161|a7dc16|            }
162|3070d1|            
163|6175de|            isModelLoaded = true
164|87d390|            isDownloading = false
165|2c5418|            statusMessage = "\(config.name) ready"
166|ebf689|            print("[LocalLLM] Model loaded: \(config.repo)")
167|3070d1|            
168|853889|        } catch {
169|87d390|            isDownloading = false
170|a0c97a|            print("[LocalLLM] Load failed for \(config.repo): \(error)")
171|3070d1|            
172|f47b9b|            // Auto-fallback: try next model in the list
173|b7591e|            if let currentIndex = availableModels.firstIndex(where: { $0.id == targetId }) {
174|93d823|                let nextIndex = availableModels.index(after: currentIndex)
175|f96cce|                if nextIndex < availableModels.endIndex {
176|72a6b6|                    let fallback = availableModels[nextIndex]
177|534871|                    print("[LocalLLM] Trying fallback: \(fallback.name)")
178|0f36bf|                    statusMessage = "Trying \(fallback.name)..."
179|cdb863|                    currentModelId = fallback.id
180|be616a|                    await loadModel(modelId: fallback.id)
181|d253ab|                    return
182|4e2d32|                }
183|a7dc16|            }
184|883796|            statusMessage = "Failed: \(error.localizedDescription)"
185|5f3077|        }
186|27e597|    }
187|b4687f|    
188|1f4350|    /// Patch tokenizer_config.json ONLY if completely missing chat_template
189|e6a0f0|    /// Qwen3 and most models have working templates - DON'T OVERWRITE THEM
190|bbb846|    private func patchTokenizerConfig(at url: URL) throws {
191|7dcb26|        let data = try Data(contentsOf: url)
192|9f35b7|        guard var json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
193|d6ed84|        
194|5d331a|        var needsWrite = false
195|65d968|        let tokenizerClass = json["tokenizer_class"] as? String ?? ""
196|d6ed84|        
197|e4affc|        // Fix non-standard tokenizer classes that swift-transformers doesn't recognize
198|697e82|        if tokenizerClass == "TokenizersBackend" {
199|9c6f93|            json["tokenizer_class"] = "PreTrainedTokenizerFast"
200|fdd298|            print("[LocalLLM] Patched tokenizer_class: \(tokenizerClass) -> PreTrainedTokenizerFast")
201|8b1a9f|            needsWrite = true
202|5f3077|        }
203|d6ed84|        
204|18c95b|        // ONLY add template if COMPLETELY MISSING - never overwrite existing ones
205|c727fd|        let existingTemplate = json["chat_template"] as? String
206|b4481b|        if existingTemplate == nil {
207|76ffac|            // Minimal ChatML fallback
208|c5473e|            let fallbackTemplate = "{%- for message in messages %}\n<|im_start|>{{ message.role }}\n{{ message.content }}<|im_end|>\n{%- endfor %}\n<|im_start|>assistant\n"
209|8a5fa6|            json["chat_template"] = fallbackTemplate
210|0feae6|            print("[LocalLLM] Added MISSING chat_template")
211|8b1a9f|            needsWrite = true
212|b31999|        } else {
213|cc2afb|            print("[LocalLLM] Using model's native chat_template")
214|5f3077|        }
215|d6ed84|        
216|9bb1a4|        if needsWrite {
217|087460|            let patched = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
218|a03c25|            try patched.write(to: url)
219|5f3077|        }
220|27e597|    }
221|b4687f|    
222|d04b10|    func unloadModel() {
223|f29fa7|        modelContainer = nil
224|2e6390|        chatSession = nil
225|3f48d8|        modelConfig = nil
226|fdc6e5|        isModelLoaded = false
227|4b42b2|        statusMessage = "Model not loaded"
228|677ae9|        print("[LocalLLM] Model unloaded")
229|27e597|    }
230|b4687f|    
231|26f7b8|    /// Clear all cached models to force re-download with fixed templates
232|302181|    func clearModelCache() {
233|e5b060|        unloadModel()
234|d6ed84|        
235|bd4342|        // Clear HuggingFace Hub cache in Caches directory
236|0aa2ea|        if let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
237|933ded|            let hubCache = cachesDir.appendingPathComponent("huggingface")
238|71cc09|            do {
239|27c422|                if FileManager.default.fileExists(atPath: hubCache.path) {
240|0151c7|                    try FileManager.default.removeItem(at: hubCache)
241|06b3b3|                    print("[LocalLLM] Cleared model cache at \(hubCache.path)")
242|d66464|                    statusMessage = "Cache cleared - models will re-download"
243|4e2d32|                }
244|91b9a2|            } catch {
245|558db7|                print("[LocalLLM] Failed to clear cache: \(error)")
246|b3742c|                statusMessage = "Failed to clear cache"
247|a7dc16|            }
248|5f3077|        }
249|27e597|    }
250|adc83b|
251|9a1e51|    func switchModel(to modelId: String) async {
252|e5b060|        unloadModel()
253|cb54b2|        await loadModel(modelId: modelId)
254|27e597|    }
255|b4687f|    
256|72eb88|    // MARK: - Chat Interface (non-streaming)
257|b4687f|    
258|07dae2|    func chat(messages: [(role: String, content: String)], systemPrompt: String? = nil) async throws -> String {
259|ec510f|        guard isModelLoaded, let container = modelContainer else {
260|57ecf6|            throw LocalLLMError.modelNotLoaded




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/ml-explore/mlx-swift-lm/main/Libraries/MLXLMCommon/ChatSession.swift

// Copyright © 2025 Apple Inc.

import CoreGraphics
import Foundation
import MLX
import Tokenizers

/// Simplified API for multi-turn conversations with LLMs and VLMs.
///
/// For example:
///
/// ```swift
/// let modelContainer = try await loadModelContainer(id: "mlx-community/Qwen3-4B-4bit")
/// let session = ChatSession(modelContainer)
/// print(try await session.respond(to: "What are two things to see in San Francisco?"))
/// print(try await session.respond(to: "How about a great place to eat?"))
/// ```
///
/// - Note: `ChatSession` is not thread-safe. Each session should be used from a single
///   task/thread at a time. The underlying `ModelContainer` handles thread safety for
///   model operations.
public final class ChatSession {

    enum Cache {
        case empty
        case kvcache([KVCache])
        case history([Chat.Message])
    }

    private let model: ModelContainer
    public var instructions: String?
    private let cache: SerialAccessContainer
    public var processing: UserInput.Processing
    public var generateParameters: GenerateParameters
    public var additionalContext: [String: any Sendable]?
    public var tools: [ToolSpec]?

    /// Initialize the `ChatSession`.
    ///
    /// - Parameters:
    ///   - model: the ``ModelContainer``
    ///   - instructions: optional system instructions for the session
    ///   - generateParameters: parameters that control generation
    ///   - processing: media processing configuration for images/videos
    ///   - additionalContext: optional model-specific context
    public init(
        _ model: ModelContainer,
        instructions: String? = nil,
        generateParameters: GenerateParameters = .init(),
        processing: UserInput.Processing = .init(resize: CGSize(width: 512, height: 512)),
        tools: [ToolSpec]? = nil,
        additionalContext: [String: any Sendable]? = nil
    ) {
        self.model = model
        self.instructions = instructions
        self.cache = .init(.empty)
        self.processing = processing
        self.generateParameters = generateParameters
        self.tools = tools
        self.additionalContext = additionalContext
    }

    /// Initialize the `ChatSession`.
    ///
    /// - Parameters:
    ///   - model: the ``ModelContext``
    ///   - instructions: optional system instructions for the session
    ///   - generateParameters: parameters that control generation
    ///   - processing: media processing configuration for images/videos
    ///   - tools: optional tool specifications
    ///   - additionalContext: optional model-specific context
    public init(
        _ model: ModelContext,
        instructions: String? = nil,
        generateParameters: GenerateParameters = .init(),
        processing: UserInput.Processing = .init(resize: CGSize(width: 512, height: 512)),
        tools: [ToolSpec]? = nil,
        additionalContext: [String: any Sendable]? = nil
    ) {
        self.model = ModelContainer(context: model)
        self.instructions = instructions
        self.cache = .init(.empty)
        self.processing = processing
        self.generateParameters = generateParameters
        self.tools = tools
        self.additionalContext = additionalContext
    }

    /// Initialize the `ChatSession` with an existing message history.
    ///
    /// This enables "Prompt Re-hydration" for persistent chat applications.
    ///
    /// - Parameters:
    ///   - model: the ``ModelContainer``
    ///   - history: The full array of messages to restore (including system prompt)
    ///   - generateParameters: parameters that control generation
    ///   - processing: media processing configuration for images/videos
    ///   - additionalContext: optional model-specific context
    public init(
        _ model: ModelContainer,
        instructions: String? = nil,
        history: consuming [Chat.Message],
        generateParameters: GenerateParameters = .init(),
        processing: UserInput.Processing = .init(resize: CGSize(width: 512, height: 512)),
        tools: [ToolSpec]? = nil,
        additionalContext: [String: any Sendable]? = nil
    ) {
        self.model = model
        self.instructions = instructions
        self.cache = .init(.history(history))
        self.processing = processing
        self.generateParameters = generateParameters
        self.tools = tools
        self.additionalContext = additionalContext
    }

    /// Initialize the `ChatSession` with an existing message history.
    ///
    /// This enables "Prompt Re-hydration" for persistent chat applications.
    ///
    /// - Parameters:
    ///   - model: the ``ModelContext``
    ///   - history: The full array of messages to restore (including system prompt)
    ///   - generateParameters: parameters that control generation
    ///   - processing: media processing configuration for images/videos
    ///   - tools: optional tool specifications
    ///   - additionalContext: optional model-specific context
    public init(
        _ model: ModelContext,
        instructions: String? = nil,
        history: [Chat.Message],
        generateParameters: GenerateParameters = .init(),
        processing: UserInput.Processing = .init(resize: CGSize(width: 512, height: 512)),
        tools: [ToolSpec]? = nil,
        additionalContext: [String: any Sendable]? = nil
    ) {
        self.model = ModelContainer(context: model)
        self.instructions = instructions
        self.cache = .init(.history(history))
        self.processing = processing
        self.generateParameters = generateParameters
        self.tools = tools
        self.additionalContext = additionalContext
    }

    /// Produces a response to a prompt.
    ///
    /// - Parameters:
    ///   - prompt: the user prompt
    ///   - images: list of images (for use with VLMs)
    ///   - videos: list of videos (for use with VLMs)
    /// - Returns: the model's response
    public func respond(
        to prompt: String,
        images: consuming [UserInput.Image],
        videos: consuming [UserInput.Video]
    ) async throws -> String {
        var output = ""
        for try await chunk in streamResponse(to: prompt, images: images, videos: videos) {
            output += chunk
        }
        return output
    }

    /// Produces a response to a prompt.
    ///
    /// - Parameters:
    ///   - prompt: the user prompt
    ///   - image: optional image (for use with VLMs)
    ///   - video: optional video (for use with VLMs)
    /// - Returns: the model's response
    public func respond(
        to prompt: String,
        image: UserInput.Image? = nil,
        video: UserInput.Video? = nil
    ) async throws -> String {
        try await respond(
            to: prompt,
            images: image.map { [$0] } ?? [],
            videos: video.map { [$0] } ?? []
        )
    }

    /// Produces a streaming response to a prompt as Strings.
    ///
    /// - Parameters:
    ///   - prompt: the user prompt
    ///   - images: list of images (for use with VLMs)
    ///   - videos: list of videos (for use with VLMs)
    /// - Returns: a stream of string chunks from the model
    public func streamResponse(
        to prompt: String,
        images: consuming [UserInput.Image],
        videos: consuming [UserInput.Video]
    ) -> AsyncThrowingStream {
        streamMap(to: prompt, images: images, videos: videos) {
            $0.chunk
        }
    }

    /// Produces a streaming response to a prompt as `Generation`.
    ///
    /// - Parameters:
    ///   - prompt: the user prompt
    ///   - images: list of images (for use with VLMs)
    ///   - videos: list of videos (for use with VLMs)
    /// - Returns: a stream of `Generation` from the model
    public func streamDetails(
        to prompt: String,
        images: consuming [UserInput.Image],
        videos: consuming [UserInput.Video]
    ) -> AsyncThrowingStream {
        streamMap(to: prompt, images: images, videos: videos) {
            $0
        }
    }

    /// Produces a streaming response to a prompt by transforming the
    /// raw `Generation` values.
    ///
    /// - Parameters:
    ///   - prompt: the user prompt
    ///   - images: list of images (for use with VLMs)
    ///   - videos: list of videos (for use with VLMs)
    /// - Returns: a stream of transformed values from the model
    private func streamMap(
        to prompt: String,
        images: consuming [UserInput.Image],
        videos: consuming [UserInput.Video],
        transform: @Sendable @escaping (Generation) -> R?
    ) -> AsyncThrowingStream {
        let (stream, continuation) = AsyncThrowingStream.makeStream()

        // images and videos are not Sendable (MLXArray) but they are consumed
        // and are only being sent to the inner async
        let message = SendableBox(
            .user(prompt, images: images, videos: videos)
        )

        let task = Task {
            [
                model,
                instructions, processing, tools, additionalContext, cache, generateParameters
            ] in
            do {
                try await cache.update { cache in

                    // these are all Sendable
                    let processor = await model.processor
                    let tokenizer = await model.tokenizer
                    let modelConfiguration = await model.configuration

                    var messages: [Chat.Message] = []
                    if let instructions {
                        messages.append(.system(instructions))
                    }

                    // prepare the cache, if needed.  note:
                    // this is using the LanguageModel (not Sendable) outside
                    // the protective lock.  Assuming the weights are not
                    // being mutated behind the scenes, this will obey the MLXArray
                    // contract that they be evaluated if used across threads.
                    // This is internal to the implementation and this technique
                    // should not be used in calling code.
                    //
                    // The benefit is that callers can be running multiple
                    // ChatSessions in parallel, as long as the instances
                    // are distinct.  In particular the KVCache cannot
                    // be shared and that is the lock that is held here.

                    let model = await model.perform { context in
                        SendableBox(context.model)
                    }.consume()

                    var kvCache: [KVCache]
                    switch cache {
                    case .empty:
                        kvCache = model.newCache(parameters: generateParameters)
                        cache = .kvcache(kvCache)

                    case .kvcache(let array):
                        kvCache = array

                    case .history(let history):
                        // the KVCache is represented by a chat history
                        kvCache = model.newCache(parameters: generateParameters)
                        cache = .kvcache(kvCache)
                        messages.append(contentsOf: history)
                    }

                    // prepare the input
                    messages.append(message.consume())

                    let userInput = UserInput(
                        chat: messages, processing: processing,
                        tools: tools, additionalContext: additionalContext)
                    let input = try await processor.prepare(input: userInput)

                    // generate output
                    let iterator = try TokenIterator(
                        input: input, model: model, cache: kvCache,
                        parameters: generateParameters)

                    let (stream, task) = MLXLMCommon.generateTask(
                        promptTokenCount: input.text.tokens.size,
                        modelConfiguration: modelConfiguration,
                        tokenizer: tokenizer,
                        iterator: iterator
                    )

                    for await item in stream {
                        if let value = transform(item) {
                            if case .terminated = continuation.yield(value) {
                                break
                            }
                        }
                    }

                    // wait for the task to complete -- this is important in
                    // the case where we broke the loop early as the generation
                    // work may continue (briefly) and use the KVCache
                    await task.value

                    continuation.finish()
                }
            } catch {
                continuation.finish(throwing: error)
            }
        }

        continuation.onTermination = { _ in
            task.cancel()
        }

        return stream
    }

    /// Produces a streaming response to a prompt.
    ///
    /// - Parameters:
    ///   - prompt: the user prompt
    ///   - image: optional image (for use with VLMs)
    ///   - video: optional video (for use with VLMs)
    /// - Returns: a stream of string chunks from the model
    public func streamResponse(
        to prompt: String,
        image: UserInput.Image? = nil,
        video: UserInput.Video? = nil
    ) -> AsyncThrowingStream {
        streamResponse(
            to: prompt,
            images: image.map { [$0] } ?? [],
            videos: video.map { [$0] } ?? []
        )
    }

    /// Clear the session history and cache, preserving system instructions.
    public func clear() async {
        await cache.update { cache in
            cache = .empty
        }
    }

    /// Wait for exclusive access to the KVCache.
    ///
    /// This is useful for cases where a program is terminating and wants to ensure that any
    /// async operations are complete.
    public func synchronize() async {
        await cache.read { _ in }
    }
}




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/ml-explore/mlx-swift-lm/main/Libraries/MLXLMCommon/Chat.swift

// Copyright © 2025 Apple Inc.

public enum Chat {
    public struct Message {
        /// The role of the message sender.
        public var role: Role

        /// The content of the message.
        public var content: String

        /// Array of image data associated with the message.
        public var images: [UserInput.Image]

        /// Array of video data associated with the message.
        public var videos: [UserInput.Video]

        public init(
            role: Role, content: String, images: [UserInput.Image] = [],
            videos: [UserInput.Video] = []
        ) {
            self.role = role
            self.content = content
            self.images = images
            self.videos = videos
        }

        public static func system(
            _ content: String, images: [UserInput.Image] = [], videos: [UserInput.Video] = []
        ) -> Self {
            Self(role: .system, content: content, images: images, videos: videos)
        }

        public static func assistant(
            _ content: String, images: [UserInput.Image] = [], videos: [UserInput.Video] = []
        ) -> Self {
            Self(role: .assistant, content: content, images: images, videos: videos)
        }

        public static func user(
            _ content: String, images: [UserInput.Image] = [], videos: [UserInput.Video] = []
        ) -> Self {
            Self(role: .user, content: content, images: images, videos: videos)
        }

        public static func tool(_ content: String) -> Self {
            Self(role: .tool, content: content)
        }

        public enum Role: String, Sendable {
            case user
            case assistant
            case system
            case tool
        }
    }
}

/// Protocol for something that can convert structured
/// ``Chat.Message`` into model specific ``Message``
/// (raw dictionary) format.
///
/// Typically this is owned and used by a ``UserInputProcessor``:
///
/// ```swift
/// public func prepare(input: UserInput) async throws -> LMInput {
///     let messages = Qwen2VLMessageGenerator().generate(from: input)
///     ...
/// ```
public protocol MessageGenerator: Sendable {

    /// Generates messages from the input.
    func generate(from input: UserInput) -> [Message]

    /// Returns array of `[String: any Sendable]` aka ``Message``
    func generate(messages: [Chat.Message]) -> [Message]

    /// Returns `[String: any Sendable]`, aka ``Message``.
    func generate(message: Chat.Message) -> Message
}

extension MessageGenerator {

    public func generate(message: Chat.Message) -> Message {
        [
            "role": message.role.rawValue,
            "content": message.content,
        ]
    }

    public func generate(messages: [Chat.Message]) -> [Message] {
        var rawMessages: [Message] = []

        for message in messages {
            let raw = generate(message: message)
            rawMessages.append(raw)
        }

        return rawMessages
    }

    public func generate(from input: UserInput) -> [Message] {
        switch input.prompt {
        case .text(let text):
            generate(messages: [.user(text)])
        case .messages(let messages):
            messages
        case .chat(let messages):
            generate(messages: messages)
        }
    }
}

/// Default implementation of ``MessageGenerator`` that produces a
/// `role` and `content`.
///
/// ```swift
/// [
///     "role": message.role.rawValue,
///     "content": message.content,
/// ]
/// ```
public struct DefaultMessageGenerator: MessageGenerator {
    public init() {}

    public func generate(message: Chat.Message) -> Message {
        [
            "role": message.role.rawValue,
            "content": message.content,
        ]
    }
}

/// Implementation of ``MessageGenerator`` that produces a
/// `role` and `content` but omits `system` roles.
///
/// ```swift
/// [
///     "role": message.role.rawValue,
///     "content": message.content,
/// ]
/// ```
public struct NoSystemMessageGenerator: MessageGenerator {
    public init() {}

    public func generate(messages: [Chat.Message]) -> [Message] {
        messages
            .filter { $0.role != .system }
            .map { generate(message: $0) }
    }
}




---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "site:raw.githubusercontent.com ml-explore/mlx-swift-lm applyChatTemplate" (4 results):

1. **raw.githubusercontent.com**
   https://raw.githubusercontent.com/modelcontextprotocol/servers/refs/heads/main/README.md
   Analyze customer attributes, manage audience targeting, and explore your workspace without switching tabs.

2. **GitHub: Let&#x27;s build from here · GitHub**
   https://raw.githubusercontent.com/Squidly271/community.applications/master/plugins/community.applications.plg
   ###2024.12.05 - Fixed: cURL encoding fallback issue on certain versions of the OS

3. **raw.githubusercontent.com**
   https://raw.githubusercontent.com/vladmandic/automatic/master/CHANGELOG.md
   *What&#x27;s else*? **Chroma** is in its final form, there are several new **Qwen-Image** variants and **Nunchaku** hit version 1.0! Also, there are quite a few offloading improvements and many quality-of-life changes to UI and overal workflows And check out new **history** tab in the right panel, it now shows visualization of entire processing timeline!

4. **raw.githubusercontent.com**
   https://raw.githubusercontent.com/mcmonkeyprojects/SwarmUI/refs/heads/master/README.md
   # SwarmUI **SwarmUI v0.9.7 Beta**. *Formerly known as StableSwarmUI.* A Modular AI Image Generation Web-User-Interface, with an emphasis on making powertools easily ...




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/Qwen/Qwen2.5-7B-Instruct/raw/main/tokenizer_config.json

{
  "add_bos_token": false,
  "add_prefix_space": false,
  "added_tokens_decoder": {
    "151643": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151644": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151645": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151646": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151647": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151648": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151649": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151650": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151651": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151652": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151653": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151654": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151655": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151656": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151657": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "151658": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "151659": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "151660": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "151661": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "151662": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "151663": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "151664": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    }
  },
  "additional_special_tokens": [
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    ""
  ],
  "bos_token": null,
  "chat_template": "{%- if tools %}\n    {{- 'system\\n' }}\n    {%- if messages[0]['role'] == 'system' %}\n        {{- messages[0]['content'] }}\n    {%- else %}\n        {{- 'You are Qwen, created by Alibaba Cloud. You are a helpful assistant.' }}\n    {%- endif %}\n    {{- \"\\n\\n# Tools\\n\\nYou may call one or more functions to assist with the user query.\\n\\nYou are provided with function signatures within  XML tags:\\n\" }}\n    {%- for tool in tools %}\n        {{- \"\\n\" }}\n        {{- tool | tojson }}\n    {%- endfor %}\n    {{- \"\\n\\n\\nFor each function call, return a json object with function name and arguments within  XML tags:\\n\\n{\\\"name\\\": , \\\"arguments\\\": }\\n\\n\" }}\n{%- else %}\n    {%- if messages[0]['role'] == 'system' %}\n        {{- 'system\\n' + messages[0]['content'] + '\\n' }}\n    {%- else %}\n        {{- 'system\\nYou are Qwen, created by Alibaba Cloud. You are a helpful assistant.\\n' }}\n    {%- endif %}\n{%- endif %}\n{%- for message in messages %}\n    {%- if (message.role == \"user\") or (message.role == \"system\" and not loop.first) or (message.role == \"assistant\" and not message.tool_calls) %}\n        {{- '' + message.role + '\\n' + message.content + '' + '\\n' }}\n    {%- elif message.role == \"assistant\" %}\n        {{- '' + message.role }}\n        {%- if message.content %}\n            {{- '\\n' + message.content }}\n        {%- endif %}\n        {%- for tool_call in message.tool_calls %}\n            {%- if tool_call.function is defined %}\n                {%- set tool_call = tool_call.function %}\n            {%- endif %}\n            {{- '\\n\\n{\"name\": \"' }}\n            {{- tool_call.name }}\n            {{- '\", \"arguments\": ' }}\n            {{- tool_call.arguments | tojson }}\n            {{- '}\\n' }}\n        {%- endfor %}\n        {{- '\\n' }}\n    {%- elif message.role == \"tool\" %}\n        {%- if (loop.index0 == 0) or (messages[loop.index0 - 1].role != \"tool\") %}\n            {{- 'user' }}\n        {%- endif %}\n        {{- '\\n\\n' }}\n        {{- message.content }}\n        {{- '\\n' }}\n        {%- if loop.last or (messages[loop.index0 + 1].role != \"tool\") %}\n            {{- '\\n' }}\n        {%- endif %}\n    {%- endif %}\n{%- endfor %}\n{%- if add_generation_prompt %}\n    {{- 'assistant\\n' }}\n{%- endif %}\n",
  "clean_up_tokenization_spaces": false,
  "eos_token": "",
  "errors": "replace",
  "model_max_length": 131072,
  "pad_token": "",
  "split_special_tokens": false,
  "tokenizer_class": "Qwen2Tokenizer",
  "unk_token": null
}




---

## 🔧 TOOL RESULTS

[web_fetch]
Error: https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct/raw/main/tokenizer_config.json returned 401




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 63b631805833
File: VSCodeiPadOS/VSCodeiPadOS/Services/LocalLLMService.swift (lines 257-464 of 465)
────────────────────────────────────────
257|72eb88|    // MARK: - Chat Interface (non-streaming)
258|b4687f|    
259|07dae2|    func chat(messages: [(role: String, content: String)], systemPrompt: String? = nil) async throws -> String {
260|ec510f|        guard isModelLoaded, let container = modelContainer else {
261|57ecf6|            throw LocalLLMError.modelNotLoaded
262|5f3077|        }
263|d6ed84|        
264|4e596a|        guard !isGenerating else {
265|9094d3|            throw LocalLLMError.alreadyGenerating
266|5f3077|        }
267|d6ed84|        
268|446c05|        isGenerating = true
269|8830ac|        defer { isGenerating = false }
270|d6ed84|        
271|ce5ae1|        // Convert prior messages to Chat.Message history (excluding the last user message)
272|f32e1d|        let system = systemPrompt ?? defaultSystemPrompt
273|799055|        let history = convertToHistory(messages: Array(messages.dropLast()))
274|d6ed84|        
275|da2f93|        // Create session with history - ChatSession will handle templating
276|9f5158|        let session = MLXChatSession(container, instructions: system, history: history, generateParameters: generateParams)
277|d6ed84|        
278|ebc1b2|        // Get the last user message to respond to
279|308cc9|        let lastUserMessage = messages.last(where: { $0.role == "user" })?.content ?? ""
280|d6ed84|        
281|994770|        // ChatSession handles end tokens automatically
282|3ff51d|        let response = try await session.respond(to: lastUserMessage)
283|d6ed84|        
284|9a7492|        // Strip thinking tags only - ChatSession handles end tokens
285|198207|        let cleaned = stripThinkingTags(response)
286|d35461|        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
287|27e597|    }
288|b4687f|    
289|47ed15|    // MARK: - Streaming Chat (for UI)
290|b4687f|    
291|6476ec|    func chatStream(messages: [(role: String, content: String)], systemPrompt: String? = nil) -> AsyncThrowingStream<String, Error> {
292|731cf1|        AsyncThrowingStream { continuation in
293|270dfc|            Task { @MainActor in
294|e99810|                guard self.isModelLoaded, let container = self.modelContainer else {
295|98baf4|                    continuation.finish(throwing: LocalLLMError.modelNotLoaded)
296|d253ab|                    return
297|4e2d32|                }
298|216278|                
299|b4aa24|                guard !self.isGenerating else {
300|20ee93|                    continuation.finish(throwing: LocalLLMError.alreadyGenerating)
301|d253ab|                    return
302|4e2d32|                }
303|216278|                
304|30f28d|                self.isGenerating = true
305|02acf8|                self.currentResponse = ""
306|216278|                
307|a9ed45|                do {
308|8d9e95|                    let system = systemPrompt ?? self.defaultSystemPrompt
309|dd2193|                    
310|641e49|                    // Convert prior messages to history (excluding last user message)
311|260c73|                    let history = self.convertToHistory(messages: Array(messages.dropLast()))
312|dd2193|                    
313|9d3790|                    // Create session with full conversation history
314|6e6ab6|                    let session = MLXChatSession(container, instructions: system, history: history, generateParameters: self.generateParams)
315|dd2193|                    
316|bf6dd8|                    // Get last user message to respond to
317|efae57|                    let lastUserMessage = messages.last(where: { $0.role == "user" })?.content ?? ""
318|dd2193|                    
319|6381d3|                    // Stream response - ChatSession handles end tokens
320|c5bebd|                    var insideThinkBlock = false
321|cde578|                    var thinkBuffer = ""
322|dd2193|                    
323|135b42|                    for try await chunk in session.streamResponse(to: lastUserMessage) {
324|3a0c9f|                        // Handle <think> blocks in real-time
325|a70e78|                        if chunk.contains("<think>") {
326|c7ed2c|                            insideThinkBlock = true
327|5bbf9f|                            thinkBuffer = ""
328|84d6cb|                            continue
329|392b35|                        }
330|956cfe|                        
331|978c88|                        if insideThinkBlock {
332|ea529a|                            thinkBuffer += chunk
333|d4375e|                            if thinkBuffer.contains("</think>") {
334|6bf821|                                insideThinkBlock = false
335|b31bea|                                // Extract anything after </think>
336|65f725|                                if let range = thinkBuffer.range(of: "</think>") {
337|ba0bd7|                                    let after = String(thinkBuffer[range.upperBound...])
338|13f042|                                    if !after.isEmpty {
339|7e340e|                                        self.currentResponse += after
340|d7de9c|                                        continuation.yield(after)
341|8ab74d|                                    }
342|f83e05|                                }
343|d05bf7|                                thinkBuffer = ""
344|89d40a|                            }
345|84d6cb|                            continue
346|392b35|                        }
347|956cfe|                        
348|2e7cea|                        // Normal text - yield it
349|ac5a80|                        if !chunk.isEmpty {
350|ec52aa|                            self.currentResponse += chunk
351|81451f|                            continuation.yield(chunk)
352|392b35|                        }
353|c9717a|                    }
354|dd2193|                    
355|c65a9a|                    continuation.finish()
356|6bf1ca|                } catch {
357|39aec1|                    continuation.finish(throwing: error)
358|4e2d32|                }
359|216278|                
360|22b947|                self.isGenerating = false
361|02acf8|                self.currentResponse = ""
362|a7dc16|            }
363|5f3077|        }
364|27e597|    }
365|b4687f|    
366|d2b3e4|    // MARK: - Memory Estimation
367|b4687f|    
368|dda2b5|    func estimateMemoryUsage() -> Int {
369|7588d6|        return modelConfig?.estimatedMemoryMB ?? 0
370|27e597|    }
371|b4687f|    
372|436b74|    func canFitInMemory(modelId: String, availableMemoryMB: Int) -> Bool {
373|c40366|        guard let config = availableModels.first(where: { $0.id == modelId }) else {
374|e2e187|            return false
375|5f3077|        }
376|321e36|        return config.estimatedMemoryMB <= availableMemoryMB
377|27e597|    }
378|b4687f|    
379|0f23ba|    // MARK: - Think Tag Filtering
380|b4687f|    
381|ab0000|    /// Strip <think>...</think> blocks from model output
382|0a2ec3|    /// These are chain-of-thought tags used by reasoning models (DeepSeek, Qwen thinking, etc.)
383|5c7352|    private func stripThinkingTags(_ text: String) -> String {
384|f89754|        var result = text
385|d6ed84|        
386|9c7200|        // Remove complete <think>...</think> blocks (including multiline)
387|42757a|        let thinkPattern = #"<think>[\s\S]*?</think>"#
388|2fe825|        if let regex = try? NSRegularExpression(pattern: thinkPattern, options: []) {
389|852aad|            result = regex.stringByReplacingMatches(
390|1532fe|                in: result,
391|8a934d|                range: NSRange(result.startIndex..., in: result),
392|57eb34|                withTemplate: ""
393|43d041|            )
394|5f3077|        }
395|d6ed84|        
396|1852a1|        // Remove incomplete opening <think> tag at end (partial streaming)
397|a66ec3|        if let range = result.range(of: "<think>") {
398|e6c93a|            if !result[range.upperBound...].contains("</think>") {
399|1542dd|                result = String(result[..<range.lowerBound])
400|a7dc16|            }
401|5f3077|        }
402|d6ed84|        
403|f1a415|        // Remove stray </think> tags
404|b10ad5|        result = result.replacingOccurrences(of: "</think>", with: "")
405|d6ed84|        
406|ae4b06|        return result.trimmingCharacters(in: .whitespacesAndNewlines)
407|27e597|    }
408|b4687f|    
409|8843e0|    // MARK: - Message Conversion
410|b4687f|    
411|7356fa|    /// Convert tuple messages to Chat.Message history for ChatSession
412|b91bc9|    private func convertToHistory(messages: [(role: String, content: String)]) -> [Chat.Message] {
413|97c167|        var history: [Chat.Message] = []
414|d6ed84|        
415|0c7100|        for msg in messages {
416|2398bd|            switch msg.role.lowercased() {
417|bab5dd|            case "user":
418|db3088|                history.append(.user(msg.content))
419|d5fa87|            case "assistant":
420|898b14|                history.append(.assistant(msg.content))
421|df5e21|            case "system":
422|c2d406|                // System is handled via instructions parameter, skip here
423|1df510|                continue
424|ea3438|            default:
425|2ebd25|                // Treat unknown roles as user
426|db3088|                history.append(.user(msg.content))
427|a7dc16|            }
428|5f3077|        }
429|d6ed84|        
430|fb4ac8|        return history
431|27e597|    }
432|b4687f|    
433|ade3be|    // MARK: - Reset Chat Context
434|b4687f|    
435|5123c4|    func resetChat() {
436|00c6d4|        guard let container = modelContainer else { return }
437|a656d8|        chatSession = MLXChatSession(container, instructions: defaultSystemPrompt, generateParameters: generateParams)
438|27e597|    }
439|b31277|}
440|adc83b|
441|2dbcb6|// MARK: - Errors
442|adc83b|
443|c14feb|enum LocalLLMError: LocalizedError {
444|18d2a0|    case modelNotLoaded
445|ed579d|    case alreadyGenerating
446|e9f7cc|    case generationFailed(String)
447|d8ed80|    case downloadFailed(String)
448|44edfd|    case invalidModelConfig
449|b4687f|    
450|242b78|    var errorDescription: String? {
451|2e6d08|        switch self {
452|e82c65|        case .modelNotLoaded:
453|de6e05|            return "Local model is not loaded. Please load the model first."
454|5bf469|        case .alreadyGenerating:
455|3173b9|            return "Already generating a response. Please wait."
456|9746bf|        case .generationFailed(let reason):
457|1d68f3|            return "Generation failed: \(reason)"
458|8012b0|        case .downloadFailed(let reason):
459|a055fe|            return "Download failed: \(reason)"
460|c983b2|        case .invalidModelConfig:
461|04ba6c|            return "Invalid model configuration."
462|5f3077|        }
463|27e597|    }
464|b31277|}




---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "site:github.com apple swift-transformers Tokenizers ChatTemplate" (10 results):

1. **GitHub - huggingface/swift-transformers: Swift Package to implement a ...**
   https://github.com/huggingface/swift-transformers
   Examples The most commonly used modules from swift-transformers are Tokenizers and Hub, which allow fast tokenization and model downloads from the Hugging Face Hub.

2. **GitHub - ensan-hcl/swift-tokenizers: A fork of huggingface/swift ...**
   https://github.com/ensan-hcl/swift-tokenizers
   Other Tools swift-chat, a simple app demonstrating how to use this package. exporters, a Core ML conversion package for transformers models, based on Apple&#x27;s coremltools. transformers-to-coreml, a no-code Core ML conversion tool built on exporters.

3. **swift-transformers/Sources/Tokenizers/Tokenizer.swift at main ...**
   https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/Tokenizer.swift
   /// /// - Parameters: /// - messages: Array of message dictionaries representing the conversation /// - chatTemplate: Optional chat template specification /// - addGenerationPrompt: Whether to add a generation prompt for the assistant /// - truncation: Whether to truncate if the result exceeds maximum length /// - maxLength: Maximum allowed ...

4. **GitHub - unok/swift-tokenizers: A fork of huggingface/swift ...**
   https://github.com/unok/swift-tokenizers
   This is a collection of utilities to help adopt language models in Swift apps. It tries to follow the Python transformers API and abstractions whenever possible, but it also aims to provide an idiomatic Swift interface and does not assume prior familiarity with transformers or tokenizers.

5. **swift-tokenizers/README.md at main · ensan-hcl/swift-tokenizers - GitHub**
   https://github.com/ensan-hcl/swift-tokenizers/blob/main/README.md
   swift-transformers This is a collection of utilities to help adopt language models in Swift apps. It tries to follow the Python transformers API and abstractions whenever possible, but it also aims to provide an idiomatic Swift interface and does not assume prior familiarity with transformers or tokenizers.

6. **GitHub - freeblow/swift-transformers**
   https://github.com/freeblow/swift-transformers
   Examples The most commonly used modules from swift-transformers are Tokenizers and Hub, which allow fast tokenization and model downloads from the Hugging Face Hub.

7. **swift-transformers/README.md at main - GitHub**
   https://github.com/huggingface/swift-transformers/blob/main/README.md
   swift-transformers This is a collection of utilities to help adopt language models in Swift apps. It tries to follow the Python transformers API and abstractions whenever possible, but it also aims to provide an idiomatic Swift interface and does not assume prior familiarity with transformers or tokenizers.

8. **GitHub - fkatada/hf-swift-transformers: Swift Package to implement a ...**
   https://github.com/fkatada/hf-swift-transformers
   swift-transformers This is a collection of utilities to help adopt language models in Swift apps. It tries to follow the Python transformers API and abstractions whenever possible, but it also aims to provide an idiomatic Swift interface and does not assume prior familiarity with transformers or tokenizers.

9. **GitHub - charwliu/swift-transformers**
   https://github.com/charwliu/swift-transformers
   swift-transformers This is a collection of utilities to help adopt language models in Swift apps. It tries to follow the Python transformers API and abstractions whenever possible, but it also aims to provide an idiomatic Swift interface and does not assume prior familiarity with transformers or tokenizers.

10. **How to use customized tokenizer? · Issue #140 · huggingface/swift ...**
   https://github.com/huggingface/swift-transformers/issues/140
   I think the way to go here would be to convert the custom tokenizers to the &quot;fast&quot; format supported by the tokenizers library, which would be immediately compatible with swift-transformers, rather than porting each custom tokenizer and requiring additional dependencies. For example, the original Llama 4 models use a tiktoken tokenizer. When those models are converted to transformers format ...




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/huggingface/swift-transformers/main/Sources/Tokenizers/Tokenizer.swift

//
//  Tokenizer.swift
//
//
//  Created by Pedro Cuenca on 6/5/23.
//

import Foundation
import Hub
import Jinja

/// A type alias for chat messages, represented as key-value pairs.
public typealias Message = [String: any Sendable]

/// A type alias for tool specifications used in chat templating.
public typealias ToolSpec = [String: any Sendable]

/// Errors that can occur during tokenizer operations.
public enum TokenizerError: LocalizedError {
    case missingConfig
    case missingTokenizerClassInConfig
    case unsupportedTokenizer(String)
    case missingVocab
    case malformedVocab
    case chatTemplate(String)
    case missingChatTemplate
    case tooLong(String)
    case mismatchedConfig(String)

    public var errorDescription: String? {
        switch self {
        case .missingConfig:
            String(localized: "Tokenizer configuration is missing.", comment: "Error when tokenizer config cannot be found")
        case .missingTokenizerClassInConfig:
            String(localized: "The tokenizer class is not specified in the configuration.", comment: "Error when tokenizer_class is missing in config")
        case let .unsupportedTokenizer(name):
            String(localized: "The tokenizer type '\(name)' is not supported.", comment: "Error when tokenizer type is not supported")
        case .missingVocab:
            String(localized: "Vocabulary file is missing from the tokenizer configuration.", comment: "Error when vocab file is missing")
        case .malformedVocab:
            String(localized: "The vocabulary file is malformed or corrupted.", comment: "Error when vocab file is malformed")
        case let .chatTemplate(message):
            String(localized: "Chat template error: \(message)", comment: "Error with chat template")
        case .missingChatTemplate:
            String(localized: "This tokenizer does not have a chat template, and no template was passed.")
        case let .tooLong(message):
            String(localized: "Input is too long: \(message)", comment: "Error when input exceeds maximum length")
        case let .mismatchedConfig(message):
            String(localized: "Tokenizer configuration mismatch: \(message)", comment: "Error when tokenizer configuration is inconsistent")
        }
    }
}

/// A protocol defining the core tokenization functionality.
///
/// This protocol defines the fundamental operations that any tokenization model must support,
/// including converting between text and tokens, and between tokens and their numeric IDs.
public protocol TokenizingModel {
    /// Tokenizes the input text into a sequence of tokens.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of tokens as strings
    func tokenize(text: String) -> [String]

    /// Alias for `tokenize` that allows the instance to be called as a function.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of tokens as strings
    func callAsFunction(_ text: String) -> [String]

    /// Converts a token string to its corresponding numeric ID.
    ///
    /// - Parameter token: The token string to convert
    /// - Returns: The numeric ID of the token, or nil if the token is not in the vocabulary
    func convertTokenToId(_ token: String) -> Int?

    /// Converts multiple token strings to their corresponding numeric IDs.
    ///
    /// - Parameter tokens: An array of token strings to convert
    /// - Returns: An array of numeric IDs, with nil values for tokens not in the vocabulary
    func convertTokensToIds(_ tokens: [String]) -> [Int?]

    /// Converts a numeric token ID back to its string representation.
    ///
    /// - Parameter id: The numeric token ID to convert
    /// - Returns: The token string, or nil if the ID is not valid
    func convertIdToToken(_ id: Int) -> String?

    /// Converts multiple numeric token IDs back to their string representations.
    ///
    /// - Parameter ids: An array of numeric token IDs to convert
    /// - Returns: An array of token strings, with nil values for invalid IDs
    func convertIdsToTokens(_ ids: [Int]) -> [String?]

    /// The beginning-of-sequence token string, if defined.
    var bosToken: String? { get }

    /// The numeric ID of the beginning-of-sequence token, if defined.
    var bosTokenId: Int? { get }

    /// The end-of-sequence token string, if defined.
    var eosToken: String? { get }

    /// The numeric ID of the end-of-sequence token, if defined.
    var eosTokenId: Int? { get }

    /// The unknown token string used for out-of-vocabulary words.
    var unknownToken: String? { get }

    /// The numeric ID of the unknown token.
    var unknownTokenId: Int? { get }

    /// Whether consecutive unknown tokens should be fused together.
    var fuseUnknownTokens: Bool { get }
}

/// Helper - possibly to be moved somewhere else
func addedTokenAsString(_ addedToken: Config?) -> String? {
    guard let addedToken else { return nil }
    if let stringValue = addedToken.string() {
        return stringValue
    }
    // This is possibly a serialization of the AddedToken class
    // TODO: support lstrip, rstrip, normalized, etc.
    return addedToken.content.string()
}

public extension TokenizingModel {
    func callAsFunction(_ text: String) -> [String] {
        tokenize(text: text)
    }

    func convertTokensToIds(_ tokens: [String]) -> [Int?] {
        tokens.map { convertTokenToId($0) }
    }

    func convertIdsToTokens(_ ids: [Int]) -> [String?] {
        ids.map { convertIdToToken($0) }
    }
}

/// A tokenizer model that can be initialized from Hugging Face Hub configuration data.
///
/// This protocol extends `TokenizingModel` with the ability to be created from configuration
/// files typically found in tokenizer repositories on the Hugging Face Hub.
public protocol PreTrainedTokenizerModel: TokenizingModel {
    /// Initializes a tokenizer model from configuration data.
    ///
    /// - Parameters:
    ///   - tokenizerConfig: The tokenizer configuration (typically from tokenizer_config.json)
    ///   - tokenizerData: The tokenizer data (typically from tokenizer.json)
    ///   - addedTokens: A dictionary mapping added token strings to their IDs
    /// - Throws: `TokenizerError` if the configuration is invalid or missing required data
    init(tokenizerConfig: Config, tokenizerData: Config, addedTokens: [String: Int]) throws
}

enum TokenizerModel {
    static let knownTokenizers: [String: PreTrainedTokenizerModel.Type] = [
        "BertTokenizer": BertTokenizer.self,
        "CodeGenTokenizer": BPETokenizer.self,
        "CodeLlamaTokenizer": BPETokenizer.self,
        "CohereTokenizer": BPETokenizer.self,
        "DistilbertTokenizer": BertTokenizer.self,
        "DistilBertTokenizer": BertTokenizer.self,
        "FalconTokenizer": BPETokenizer.self,
        "GemmaTokenizer": BPETokenizer.self,
        "GPT2Tokenizer": BPETokenizer.self,
        "LlamaTokenizer": BPETokenizer.self,
        "RobertaTokenizer": BPETokenizer.self,
        "T5Tokenizer": T5Tokenizer.self,
        "TokenizersBackend": BPETokenizer.self,
        "PreTrainedTokenizer": BPETokenizer.self,
        "Qwen2Tokenizer": BPETokenizer.self,
        "WhisperTokenizer": BPETokenizer.self,
        "XLMRobertaTokenizer": UnigramTokenizer.self,
    ]

    static func unknownToken(from tokenizerConfig: Config) -> String? {
        tokenizerConfig.unkToken.content.string() ?? tokenizerConfig.unkToken.string()
    }

    static func from(tokenizerConfig: Config, tokenizerData: Config, addedTokens: [String: Int], strict: Bool = true) throws -> TokenizingModel {
        guard let tokenizerClassName = tokenizerConfig.tokenizerClass.string() else {
            throw TokenizerError.missingTokenizerClassInConfig
        }

        // Some tokenizer_class entries use a Fast suffix
        let tokenizerName = tokenizerClassName.replacingOccurrences(of: "Fast", with: "")
        // Fallback to BPETokenizer if class is not explicitly registered
        let tokenizerClass = TokenizerModel.knownTokenizers[tokenizerName] ?? BPETokenizer.self
        if TokenizerModel.knownTokenizers[tokenizerName] == nil {
            if strict {
                throw TokenizerError.unsupportedTokenizer(tokenizerName)
            } else {
                print("Warning: Tokenizer model class \(tokenizerName) is not registered, falling back to a standard BPE implementation.")
            }
        }
        return try tokenizerClass.init(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, addedTokens: addedTokens)
    }
}

/// Arguments for specifying chat templates when applying chat formatting.
public enum ChatTemplateArgument {
    /// A Jinja template to use for the conversation.
    ///
    /// Normally it is not necessary to provide a template, since it will be read from the tokenizer config.
    case literal(String)

    /// For models whose tokenizer config includes multiple chat templates, the template can be specified by name.
    ///
    /// Normally this is not necessary.
    case name(String)
}

/// A complete tokenizer interface supporting encoding, decoding, and chat template functionality.
///
/// This is the main protocol that defines all tokenizer operations, including text processing,
/// chat template application, and special token handling.
public protocol Tokenizer: Sendable {
    /// Tokenizes the input text into a sequence of tokens.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of tokens as strings
    func tokenize(text: String) -> [String]

    /// Encodes text into token IDs with special tokens included by default.
    ///
    /// This is the main entry point for most tokenization tasks.
    ///
    /// - Parameter text: The input text to encode
    /// - Returns: An array of token IDs
    func encode(text: String) -> [Int]

    /// Encodes text into token IDs with optional special token handling.
    ///
    /// - Parameters:
    ///   - text: The input text to encode
    ///   - addSpecialTokens: Whether to add special tokens (e.g., BOS, EOS)
    /// - Returns: An array of token IDs
    func encode(text: String, addSpecialTokens: Bool) -> [Int]

    /// Function call syntax for encoding text.
    ///
    /// - Parameters:
    ///   - text: The input text to encode
    ///   - addSpecialTokens: Whether to add special tokens
    /// - Returns: An array of token IDs
    func callAsFunction(_ text: String, addSpecialTokens: Bool) -> [Int]

    /// Decodes token IDs back into text with special tokens included.
    ///
    /// - Parameter tokens: The token IDs to decode
    /// - Returns: The decoded text string
    func decode(tokens: [Int]) -> String

    /// Decodes token IDs back into text with optional special token handling.
    ///
    /// - Parameters:
    ///   - tokens: The token IDs to decode
    ///   - skipSpecialTokens: Whether to skip special tokens in the output
    /// - Returns: The decoded text string
    func decode(tokens: [Int], skipSpecialTokens: Bool) -> String

    /// Converts a token string to its corresponding numeric ID.
    ///
    /// - Parameter token: The token string to convert
    /// - Returns: The numeric ID of the token, or nil if not found
    func convertTokenToId(_ token: String) -> Int?

    /// Converts multiple token strings to their corresponding numeric IDs.
    ///
    /// - Parameter tokens: An array of token strings to convert
    /// - Returns: An array of numeric IDs, with nil values for unknown tokens
    func convertTokensToIds(_ tokens: [String]) -> [Int?]

    /// Converts a numeric token ID back to its string representation.
    ///
    /// - Parameter id: The numeric token ID to convert
    /// - Returns: The token string, or nil if the ID is invalid
    func convertIdToToken(_ id: Int) -> String?

    /// Converts multiple numeric token IDs back to their string representations.
    ///
    /// - Parameter ids: An array of numeric token IDs to convert
    /// - Returns: An array of token strings, with nil values for invalid IDs
    func convertIdsToTokens(_ ids: [Int]) -> [String?]

    /// The beginning-of-sequence token string, if defined.
    var bosToken: String? { get }

    /// The numeric ID of the beginning-of-sequence token, if defined.
    var bosTokenId: Int? { get }

    /// The end-of-sequence token string, if defined.
    var eosToken: String? { get }

    /// The numeric ID of the end-of-sequence token, if defined.
    var eosTokenId: Int? { get }

    /// The unknown token string used for out-of-vocabulary words.
    var unknownToken: String? { get }

    /// The numeric ID of the unknown token.
    var unknownTokenId: Int? { get }

    /// Whether this tokenizer has a chat template configured.
    var hasChatTemplate: Bool { get }

    /// Applies the configured chat template to format messages for model input.
    ///
    /// - Parameter messages: Array of message dictionaries representing the conversation
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails or no template is available
    func applyChatTemplate(messages: [Message]) throws -> [Int]

    /// Applies the configured chat template with optional tool specifications.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - tools: Optional array of tool specifications for function calling
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails or no template is available
    func applyChatTemplate(messages: [Message], tools: [ToolSpec]?) throws -> [Int]

    /// Applies the configured chat template with tools and additional context.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - tools: Optional array of tool specifications for function calling
    ///   - additionalContext: Additional context variables for template rendering
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails or no template is available
    func applyChatTemplate(messages: [Message], tools: [ToolSpec]?, additionalContext: [String: any Sendable]?) throws -> [Int]

    /// Applies a specific chat template to format messages.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: The chat template to use (literal template or template name)
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(messages: [Message], chatTemplate: ChatTemplateArgument) throws -> [Int]

    /// Applies a chat template provided as a literal string.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: The Jinja template string to use for formatting
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(messages: [Message], chatTemplate: String) throws -> [Int]

    /// Applies a chat template with full control over all parameters.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: Optional chat template specification
    ///   - addGenerationPrompt: Whether to add a generation prompt for the assistant
    ///   - truncation: Whether to truncate if the result exceeds maximum length
    ///   - maxLength: Maximum allowed token length
    ///   - tools: Optional array of tool specifications for function calling
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument?,
        addGenerationPrompt: Bool,
        truncation: Bool,
        maxLength: Int?,
        tools: [ToolSpec]?
    ) throws -> [Int]

    /// Applies a chat template with full control over all parameters including additional context.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: Optional chat template specification
    ///   - addGenerationPrompt: Whether to add a generation prompt for the assistant
    ///   - truncation: Whether to truncate if the result exceeds maximum length
    ///   - maxLength: Maximum allowed token length
    ///   - tools: Optional array of tool specifications for function calling
    ///   - additionalContext: Additional context variables for template rendering
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument?,
        addGenerationPrompt: Bool,
        truncation: Bool,
        maxLength: Int?,
        tools: [ToolSpec]?,
        additionalContext: [String: any Sendable]?
    ) throws -> [Int]
}

extension Tokenizer {
    public var hasChatTemplate: Bool { false }

    /// Call previous signature for backwards compatibility
    func applyChatTemplate(
        messages: [Message],
        // A chat template can optionally be provided or specified by name when several templates are included in the tokenizer config. Normally this is not necessary.
        chatTemplate: ChatTemplateArgument?,
        addGenerationPrompt: Bool,
        truncation: Bool,
        maxLength: Int?,
        tools: [ToolSpec]?,
        additionalContext: [String: any Sendable]?
    ) throws -> [Int] {
        if additionalContext == nil {
            try applyChatTemplate(
                messages: messages, chatTemplate: chatTemplate, addGenerationPrompt: addGenerationPrompt, truncation: truncation, maxLength: maxLength,
                tools: tools
            )
        } else {
            throw TokenizerError.chatTemplate("Not implemented")
        }
    }
}

public extension Tokenizer {
    func callAsFunction(_ text: String, addSpecialTokens: Bool = true) -> [Int] {
        encode(text: text, addSpecialTokens: addSpecialTokens)
    }

    func decode(tokens: [Int]) -> String {
        decode(tokens: tokens, skipSpecialTokens: false)
    }

    func convertTokensToIds(_ tokens: [String]) -> [Int?] {
        tokens.map { convertTokenToId($0) }
    }

    func convertIdsToTokens(_ ids: [Int]) -> [String?] {
        ids.map { convertIdToToken($0) }
    }
}

let specialTokenAttributes: [String] = [
    "bos_token",
    "eos_token",
    "unk_token",
    "sep_token",
    "pad_token",
    "cls_token",
    "mask_token",
    "additional_special_tokens",
]

/// A comprehensive tokenizer implementation supporting pre-trained models from Hugging Face.
///
/// This class provides a complete tokenizer implementation that can be initialized from
/// Hugging Face Hub configuration files and supports all standard tokenization operations
/// including chat template application, normalization, pre-tokenization, and post-processing.
public class PreTrainedTokenizer: @unchecked Sendable, Tokenizer {
    let model: TokenizingModel

    public var bosToken: String? { model.bosToken }
    public var bosTokenId: Int? { model.bosTokenId }
    public var eosToken: String? { model.eosToken }
    public var eosTokenId: Int? { model.eosTokenId }
    public var unknownToken: String? { model.unknownToken }
    public var unknownTokenId: Int? { model.unknownTokenId }
    public var fuseUnknownTokens: Bool { model.fuseUnknownTokens }

    let addedTokens: Set
    let specialTokens: [String: Int]
    let addedTokensRegex: NSRegularExpression?

    private let preTokenizer: PreTokenizer?
    private let normalizer: Normalizer?
    private let postProcessor: PostProcessor?
    private let decoder: Decoder?
    private let tokenizerConfig: Config

    private let cleanUpTokenizationSpaces: Bool

    /// Cache for compiled Jinja templates keyed by their literal template string
    private var compiledChatTemplateCache: [String: Template] = [:]

    /// Lock to protect the compiled chat template cache from concurrent access
    private let cacheLock = NSLock()

    /// Initializes a tokenizer from Hugging Face configuration files.
    ///
    /// - Parameters:
    ///   - tokenizerConfig: Configuration from tokenizer_config.json
    ///   - tokenizerData: Configuration from tokenizer.json
    ///   - strict: Whether to enforce strict validation of tokenizer types
    /// - Throws: `TokenizerError` if configuration is invalid or tokenizer type is unsupported
    public required init(tokenizerConfig: Config, tokenizerData: Config, strict: Bool = true) throws {
        var addedTokens: [String: Int] = [:]
        var specialTokens: [String: Int] = [:]
        for addedToken in tokenizerData["addedTokens"].array(or: []) {
            guard let id = addedToken["id"].integer() else { continue } // malformed: token with no id
            guard let content = addedToken.content.string() else { continue } // malformed: token with no content
            addedTokens[content] = id

            if addedToken["special"].boolean(or: false) {
                specialTokens[content] = id
            }
        }

        // Convert to tuples for easier access, then sort by length (descending) to avoid early partial matches
        // (https://github.com/xenova/transformers.js/commit/c305c3824f628f1f02806a6310bd3b18b0f7f8f5)
        let unwrappedAddedTokens: [(content: String, prefix: Bool, suffix: Bool)] = (tokenizerData["addedTokens"].array(or: [])).compactMap { addedToken -> (String, Bool, Bool)? in
            guard let content = addedToken.content.string() else { return nil }
            let prefix = addedToken["lstrip"].boolean(or: false)
            let suffix = addedToken["rstrip"].boolean(or: false)
            return (content: content, prefix: prefix, suffix: suffix)
        }.sorted {
            $0.content.count > $1.content.count
        }

        // then concatenate into regular expression
        let addedTokensRegexString = unwrappedAddedTokens.map {
            let token = NSRegularExpression.escapedPattern(for: $0.content)
            let prefix = $0.prefix ? #"\s*"# : ""
            let suffix = $0.suffix ? #"\s*"# : ""
            return "\(prefix)(\(token))\(suffix)"
        }.joined(separator: "|")
        addedTokensRegex = try? NSRegularExpression(pattern: addedTokensRegexString, options: [])

        self.specialTokens = specialTokens
        self.addedTokens = Set(addedTokens.keys)

        preTokenizer = PreTokenizerFactory.fromConfig(config: tokenizerData["preTokenizer"])
        normalizer = NormalizerFactory.fromConfig(config: tokenizerData["normalizer"])
        postProcessor = PostProcessorFactory.fromConfig(config: tokenizerData["postProcessor"])
        decoder = DecoderFactory.fromConfig(config: tokenizerData["decoder"], addedTokens: self.addedTokens)
        cleanUpTokenizationSpaces = tokenizerConfig.cleanUpTokenizationSpaces.boolean(or: true)
        self.tokenizerConfig = tokenizerConfig

        model = try TokenizerModel.from(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, addedTokens: addedTokens, strict: strict)
    }

    private func compiledTemplate(for templateString: String) throws -> Template {
        // Fast path: check cache under lock
        cacheLock.lock()
        if let cached = compiledChatTemplateCache[templateString] {
            cacheLock.unlock()
            return cached
        }
        cacheLock.unlock()

        // Compile template outside of lock to avoid holding lock during expensive operation
        let compiled = try Template(templateString)

        // Insert into cache under lock (using double-checked locking pattern)
        cacheLock.lock()
        defer { cacheLock.unlock() }

        // Check again in case another thread compiled the same template
        if let cached = compiledChatTemplateCache[templateString] {
            return cached
        }

        compiledChatTemplateCache[templateString] = compiled
        return compiled
    }

    func preTokenize(_ text: String, options: PreTokenizerOptions) -> [String] {
        guard let preTokenizer else { return [text] }
        return preTokenizer(text: text, options: options)
    }

    func normalize(_ text: String) -> String {
        guard let normalizer else { return text }
        return normalizer(text: text)
    }

    func postProcess(_ tokens: [String], addSpecialTokens: Bool = true) -> [String] {
        guard let postProcessor else { return tokens }
        return postProcessor(tokens: tokens, addSpecialTokens: addSpecialTokens)
    }

    func decodeTokens(_ tokens: [String]) -> [String] {
        guard let tokenDecoder = decoder else { return tokens }
        return tokenDecoder(tokens: tokens)
    }

    /// Clean up a list of simple English tokenization artifacts like spaces before punctuations and abbreviated forms
    func cleanUp(text: String) -> String {
        guard cleanUpTokenizationSpaces else { return text }

        return
            text
            .replacingOccurrences(of: " .", with: ".")
            .replacingOccurrences(of: " ?", with: "?")
            .replacingOccurrences(of: " !", with: "!")
            .replacingOccurrences(of: " ,", with: ",")
            .replacingOccurrences(of: " ' ", with: "'")
            .replacingOccurrences(of: " n't", with: "n't")
            .replacingOccurrences(of: " 'm", with: "'m")
            .replacingOccurrences(of: " 's", with: "'s")
            .replacingOccurrences(of: " 've", with: "'ve")
            .replacingOccurrences(of: " 're", with: "'re")
    }

    func fuseUnknown(_ tokens: [String]) -> [String] {
        guard fuseUnknownTokens else { return tokens }
        let (fused, _) = tokens.reduce((fused: [String](), previousIsUnknown: false)) { result, token in
            var (fused, previousIsUnknown) = result
            let isUnknown = model.convertTokenToId(token) == model.unknownTokenId
            if isUnknown {
                if !previousIsUnknown { fused.append(token) }
            } else {
                fused.append(token)
            }
            return (fused, isUnknown)
        }
        return fused
    }

    /// Tokenizes input text using the configured normalization and pre-tokenization steps.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of token strings
    public func tokenize(text: String) -> [String] {
        // Take care of special tokens first
        let sections: [String] =
            if let regex = addedTokensRegex {
                text.split(by: regex)
            } else {
                [text]
            }
        return sections.enumerated().map { section, x in
            if addedTokens.contains(x) { return [x] }
            return preTokenize(normalize(x), options: section == 0 ? [.firstSection] : []).flatMap { model($0) }
        }.flatMap { fuseUnknown($0) }
    }

    /// Encodes input text into token IDs with optional special token handling.
    ///
    /// This is the main entry point for text encoding operations.
    ///
    /// - Parameters:
    ///   - text: The input text to encode
    ///   - addSpecialTokens: Whether to add special tokens during post-processing
    /// - Returns: An array of token IDs
    public func encode(text: String, addSpecialTokens: Bool = true) -> [Int] {
        postProcess(tokenize(text: text), addSpecialTokens: addSpecialTokens).map { model.convertTokenToId($0)! }
    }

    /// Encodes input text into token IDs with special tokens included by default.
    ///
    /// - Parameter text: The input text to encode
    /// - Returns: An array of token IDs
    public func encode(text: String) -> [Int] {
        encode(text: text, addSpecialTokens: true)
    }

    /// Decodes token IDs back into human-readable text.
    ///
    /// - Parameters:
    ///   - tokens: The token IDs to decode
    ///   - skipSpecialTokens: Whether to exclude special tokens from the output text
    /// - Returns: The decoded text string
    public func decode(tokens: [Int], skipSpecialTokens: Bool = false) -> String {
        // IDs to tokens
        let tokenStrings: [String]
        if skipSpecialTokens {
            let specialTokenIDs = Set(specialTokens.values)
            tokenStrings =
                tokens
                .filter { !specialTokenIDs.contains($0) }
                .compactMap { model.convertIdToToken($0) }
        } else {
            tokenStrings = tokens.compactMap { model.convertIdToToken($0) }
        }
        let decoded = decodeTokens(tokenStrings)
        // At this point we should have a single String
        return cleanUp(text: decoded.joined(separator: ""))
    }

    /// Converts a token string to its corresponding numeric ID.
    ///
    /// - Parameter token: The token string to convert
    /// - Returns: The numeric ID of the token, or nil if not found in the vocabulary
    public func convertTokenToId(_ token: String) -> Int? {
        model.convertTokenToId(token)
    }

    /// Converts a numeric token ID back to its string representation.
    ///
    /// - Parameter id: The numeric token ID to convert
    /// - Returns: The token string, or nil if the ID is invalid
    public func convertIdToToken(_ id: Int) -> String? {
        model.convertIdToToken(id)
    }

    /// Whether this tokenizer has a chat template configured.
    public var hasChatTemplate: Bool {
        !tokenizerConfig.chatTemplate.isNull()
    }

    public func applyChatTemplate(messages: [Message]) throws -> [Int] {
        try applyChatTemplate(messages: messages, addGenerationPrompt: true)
    }

    public func applyChatTemplate(messages: [Message], tools: [ToolSpec]? = nil) throws -> [Int] {
        try applyChatTemplate(messages: messages, addGenerationPrompt: true, tools: tools)
    }

    public func applyChatTemplate(messages: [Message], tools: [ToolSpec]? = nil, additionalContext: [String: any Sendable]? = nil) throws
        -> [Int]
    {
        try applyChatTemplate(
            messages: messages,
            addGenerationPrompt: true,
            tools: tools,
            additionalContext: additionalContext
        )
    }

    public func applyChatTemplate(messages: [Message], chatTemplate: ChatTemplateArgument) throws -> [Int] {
        try applyChatTemplate(messages: messages, chatTemplate: chatTemplate, addGenerationPrompt: true)
    }

    public func applyChatTemplate(messages: [Message], chatTemplate: String) throws -> [Int] {
        try applyChatTemplate(messages: messages, chatTemplate: .literal(chatTemplate), addGenerationPrompt: true)
    }

    public func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument? = nil,
        addGenerationPrompt: Bool = false,
        truncation: Bool = false,
        maxLength: Int? = nil,
        tools: [ToolSpec]? = nil
    ) throws -> [Int] {
        try applyChatTemplate(
            messages: messages, chatTemplate: chatTemplate, addGenerationPrompt: addGenerationPrompt, truncation: truncation, maxLength: maxLength,
            tools: tools, additionalContext: nil
        )
    }

    public func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument? = nil,
        addGenerationPrompt: Bool = false,
        truncation: Bool = false,
        maxLength: Int? = nil,
        // A list of tools (callable functions) that will be accessible to the model. If the template does not
        // support function calling, this argument will have no effect. Each tool should be passed as a JSON Schema,
        // giving the name, description and argument types for the tool. See the
        // [chat templating guide](https://huggingface.co/docs/transformers/main/en/chat_templating#automated-function-conversion-for-tool-use)
        // for more information.
        tools: [ToolSpec]? = nil,
        additionalContext: [String: any Sendable]? = nil
    ) throws -> [Int] {
        var selectedChatTemplate: String?
        if let chatTemplate, case let .literal(template) = chatTemplate {
            // Use chat template from argument
            selectedChatTemplate = template
        } else if !tokenizerConfig.chatTemplate.isNull() {
            let valueFromConfig: Config = tokenizerConfig.chatTemplate
            if let arrayValue = valueFromConfig.array() {
                // If the config specifies a list of chat templates, convert them to a dictionary
                let templateDict = [String: String](
                    uniqueKeysWithValues: arrayValue.compactMap { item in
                        guard let name = item["name"].string(), let template = item["template"].string() else {
                            return nil
                        }
                        return (name, template)
                    })
                if let chatTemplate, case let .name(name) = chatTemplate {
                    // Select chat template from config by name
                    if let matchingDictEntry = templateDict[name] {
                        selectedChatTemplate = matchingDictEntry
                    } else {
                        throw TokenizerError.chatTemplate("No chat template named \"\(name)\" was found in the tokenizer config")
                    }
                } else if let tools, !tools.isEmpty, let toolUseTemplate = templateDict["tool_use"] {
                    // Use tool use chat template from config
                    selectedChatTemplate = toolUseTemplate
                } else if let defaultChatTemplate = templateDict["default"] {
                    // Use default chat template from config
                    selectedChatTemplate = defaultChatTemplate
                }
            } else if let stringValue = valueFromConfig.string() {
                // Use chat template from config
                selectedChatTemplate = stringValue
            }
        }

        guard let selectedChatTemplate else {
            throw TokenizerError.missingChatTemplate
        }

        let template = try compiledTemplate(for: selectedChatTemplate)
        var context: [String: Jinja.Value] = try [
            "messages": .array(messages.map { try Value(any: $0) }),
            "add_generation_prompt": .boolean(addGenerationPrompt),
        ]
        if let tools {
            context["tools"] = try .array(tools.map { try Value(any: $0) })
        }
        if let additionalContext {
            // Additional keys and values to be added to the context provided to the prompt templating engine.
            // For example, the app could set "tools_in_user_message" to false for Llama 3.1 and 3.2 if a system message is provided.
            // The default value is true in the Llama 3.1 and 3.2 chat templates, but these models will perform better if the tools are included in a system message.
            for (key, value) in additionalContext {
                context[key] = try Value(any: value)
            }
        }

        for (key, value) in tokenizerConfig.dictionary(or: [:]) {
            if specialTokenAttributes.contains(key.string), !value.isNull() {
                if let stringValue = value.string() {
                    context[key.string] = .string(stringValue)
                } else if let dictionary = value.dictionary() {
                    if let addedTokenString = addedTokenAsString(Config(dictionary)) {
                        context[key.string] = .string(addedTokenString)
                    }
                } else if let array: [String] = value.get() {
                    context[key.string] = .array(array.map { .string($0) })
                } else {
                    context[key.string] = try Value(any: value)
                }
            }
        }

        let rendered = try template.render(context)
        var encodedTokens = encode(text: rendered, addSpecialTokens: false)
        var maxLength = maxLength ?? encodedTokens.count
        maxLength = min(maxLength, tokenizerConfig.modelMaxLength.integer() ?? maxLength)
        if encodedTokens.count > maxLength {
            if truncation {
                encodedTokens = Array(encodedTokens.prefix(maxLength))
            }
        }

        return encodedTokens
    }
}

// MARK: - Building

/// A namespace for automatically creating appropriate tokenizer instances.
///
/// `AutoTokenizer` provides static methods for loading pre-trained tokenizers
/// from the Hugging Face Hub or local directories. It automatically selects
/// the appropriate tokenizer class based on the configuration.
public enum AutoTokenizer {}

enum PreTrainedTokenizerClasses {
    /// Class overrides for custom behaviour
    /// Not to be confused with the TokenizerModel classes defined in TokenizerModel
    static let tokenizerClasses: [String: PreTrainedTokenizer.Type] = [
        "LlamaTokenizer": LlamaPreTrainedTokenizer.self
    ]
}

public extension AutoTokenizer {
    /// Determines the appropriate tokenizer class for the given configuration.
    ///
    /// - Parameter tokenizerConfig: The tokenizer configuration
    /// - Returns: The appropriate `PreTrainedTokenizer` subclass
    internal static func tokenizerClass(for tokenizerConfig: Config) -> PreTrainedTokenizer.Type {
        guard let tokenizerClassName = tokenizerConfig.tokenizerClass.string() else {
            return PreTrainedTokenizer.self
        }

        // Some tokenizer_class entries use a Fast suffix
        let tokenizerName = tokenizerClassName.replacingOccurrences(of: "Fast", with: "")
        if let tokenizerClass = PreTrainedTokenizerClasses.tokenizerClasses[tokenizerName] {
            return tokenizerClass
        }

        return PreTrainedTokenizer.self
    }

    /// Creates a tokenizer from configuration objects.
    ///
    /// - Parameters:
    ///   - tokenizerConfig: The tokenizer configuration (from tokenizer_config.json)
    ///   - tokenizerData: The tokenizer data (from tokenizer.json)
    ///   - strict: Whether to enforce strict validation
    /// - Returns: A configured `Tokenizer` instance
    /// - Throws: `TokenizerError` if configuration is invalid
    static func from(tokenizerConfig: Config, tokenizerData: Config, strict: Bool = true) throws -> Tokenizer {
        let tokenizerClass = tokenizerClass(for: tokenizerConfig)
        return try tokenizerClass.init(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, strict: strict)
    }

    /// Loads a tokenizer from a pre-trained model on the Hugging Face Hub.
    ///
    /// - Parameters:
    ///   - model: The model identifier (e.g., "bert-base-uncased")
    ///   - hubApi: The Hub API instance to use for downloading
    ///   - strict: Whether to enforce strict validation
    /// - Returns: A configured `Tokenizer` instance
    /// - Throws: `TokenizerError` if the model cannot be loaded or configured
    static func from(
        pretrained model: String,
        hubApi: HubApi = .shared,
        strict: Bool = true
    ) async throws -> Tokenizer {
        let config = LanguageModelConfigurationFromHub(modelName: model, hubApi: hubApi)
        guard let tokenizerConfig = try await config.tokenizerConfig else { throw TokenizerError.missingConfig }
        let tokenizerData = try await config.tokenizerData

        return try AutoTokenizer.from(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, strict: strict)
    }

    /// Loads a tokenizer from a local model folder.
    ///
    /// - Parameters:
    ///   - modelFolder: The URL path to the local model folder
    ///   - hubApi: The Hub API instance to use (unused for local loading)
    ///   - strict: Whether to enforce strict validation
    /// - Returns: A configured `Tokenizer` instance
    /// - Throws: `TokenizerError` if the model folder is invalid or missing files
    static func from(
        modelFolder: URL,
        hubApi: HubApi = .shared,
        strict: Bool = true
    ) async throws -> Tokenizer {
        let config = LanguageModelConfigurationFromHub(modelFolder: modelFolder, hubApi: hubApi)
        guard let tokenizerConfig = try await config.tokenizerConfig else { throw TokenizerError.missingConfig }
        let tokenizerData = try await config.tokenizerData

        return try PreTrainedTokenizer(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, strict: strict)
    }
}

// MARK: - Tokenizer model classes

class T5Tokenizer: UnigramTokenizer, @unchecked Sendable {}

// MARK: - PreTrainedTokenizer classes

let sentencePieceUnderline = "▁"

/// Hack for Llama tokenizers, see https://github.com/huggingface/transformers/blob/bcb841f0073fcd7a4fb88ea8064313c17dcab04a/src/transformers/models/llama/tokenization_llama_fast.py#L181
/// Return updated config, or nil
func maybeUpdatePostProcessor(tokenizerConfig: Config, processorConfig: Config?) throws -> Config? {
    // If it's already a Template processor (instead of a ByteLevel one), assume it's correct
    let postProcessor = PostProcessorFactory.fromConfig(config: processorConfig)
    guard !(postProcessor is TemplateProcessing) else { return nil }

    let addBosToken = tokenizerConfig.addBosToken.boolean(or: false)
    let bosToken = addedTokenAsString(tokenizerConfig.bosToken)
    if addBosToken, bosToken == nil {
        throw TokenizerError.mismatchedConfig("add_bos_token is True but bos_token is nil")
    }

    let addEosToken = tokenizerConfig.addEosToken.boolean(or: false)
    let eosToken = addedTokenAsString(tokenizerConfig.eosToken)
    if addEosToken, eosToken == nil {
        throw TokenizerError.mismatchedConfig("add_eos_token is True but eos_token is nil")
    }

    // alt implementation
    var single: [[String: Any]] = []
    if addBosToken {
        single = single + [["SpecialToken": ["id": bosToken!, "type_id": 0]]]
    }
    single = single + [["Sequence": ["id": "A", "type_id": 0]]]
    if addEosToken {
        single = single + [["SpecialToken": ["id": eosToken!, "type_id": 0]]]
    }

    var pair: [[String: Any]] = single
    if addBosToken {
        pair = pair + [["SpecialToken": ["id": bosToken!, "type_id": 1]]]
    }
    pair = pair + [["Sequence": ["id": "B", "type_id": 1]]]
    if addEosToken {
        pair = pair + [["SpecialToken": ["id": eosToken!, "type_id": 1]]]
    }

    let postProcessorConfig = Config(["type": PostProcessorType.TemplateProcessing.rawValue, "single": single, "pair": pair])
    return postProcessorConfig
}

/// See https://github.com/xenova/transformers.js/blob/1a9964fb09b8f54fcbeac46dc6aae8d76795809d/src/tokenizers.js#L3203 for these exceptions
class LlamaPreTrainedTokenizer: PreTrainedTokenizer, @unchecked Sendable {
    let isLegacy: Bool

    required init(tokenizerConfig: Config, tokenizerData: Config, strict: Bool = true) throws {
        isLegacy = tokenizerConfig.legacy.boolean(or: true)
        var configDictionary = tokenizerData.dictionary(or: [:])
        if !isLegacy {
            _ = configDictionary.removeValue(forKey: "normalizer")
            configDictionary["pre_tokenizer"] = [
                "type": "Metaspace", "replacement": .init(sentencePieceUnderline), "add_prefix_space": true, "prepend_scheme": "first",
            ]
        }

        if let postProcessorConfig = try maybeUpdatePostProcessor(tokenizerConfig: tokenizerConfig, processorConfig: tokenizerData["postProcessor"]) {
            configDictionary["post_processor"] = .init(postProcessorConfig.dictionary(or: [:]))
        }

        let updatedData = Config(configDictionary)
        try super.init(tokenizerConfig: tokenizerConfig, tokenizerData: updatedData, strict: strict)
    }

    /// If `isLegacy` is `False`, a prefix token is added unless the first token is special.
    /// https://github.com/huggingface/transformers/blob/e6dcf8abd6f65bb4b6dfc1831b20d9ba49ce00e2/src/transformers/models/t5/tokenization_t5.py#L374-L387
    override func tokenize(text: String) -> [String] {
        if isLegacy || text.isEmpty {
            return super.tokenize(text: text)
        }

        let tokens = super.tokenize(text: sentencePieceUnderline + text.replacingOccurrences(of: sentencePieceUnderline, with: " "))
        if tokens.first == sentencePieceUnderline, let second = tokens.dropFirst().first, specialTokens[second] != nil {
            return Array(tokens[1...])
        }
        return tokens
    }
}




---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "mlx-swift-lm applyChatTemplate(messages" (10 results):

1. **GitHub - ml-explore/mlx-swift: Swift API for MLX**
   https://github.com/ml-explore/mlx-swift/
   MLX Swift is a Swift API for MLX. MLX is an array framework for machine learning on Apple silicon. MLX Swift expands MLX to the Swift language, making research and experimentation easier on Apple silicon. MNISTTrainer: An example that runs on both iOS and macOS that downloads MNIST training data and ...

2. **GitHub - ml-explore/mlx-swift-lm: LLMs and VLMs with MLX Swift**
   https://github.com/ml-explore/mlx-swift-lm
   LLMs and VLMs with MLX Swift. Contribute to ml-explore/mlx-swift-lm development by creating an account on GitHub.

3. **mlx-libraries - Swift Package Index**
   https://swiftpackageindex.com/ml-explore/mlx-swift-examples
   MLX Swift Examples Example MLX Swift programs. The language model examples use models implemented in MLX Swift LM. MNISTTrainer: An example that runs on both iOS and macOS that downloads MNIST training data and trains a LeNet. LLMBasic: A minimal LLM chat example application. It has only two features: load the model and evaluate a prompt.

4. **mlx-libraries - Swift Package Registry**
   https://swiftpackageregistry.com/ml-explore/mlx-swift-examples
   MLX Swift Examples Example MLX Swift programs. MNISTTrainer: An example that runs on both iOS and macOS that downloads MNIST training data and trains a LeNet. LLMEval: An example that runs on both iOS and macOS that downloads an LLM and tokenizer from Hugging Face and generates text from a given prompt.

5. **MLX - Day 3: Running the MLX sample app on macOS, iOS and visionOS**
   https://antran.app/2024/mlx_swift_examples/
   MLX - Day 3: Running the MLX sample app on macOS, iOS and visionOS April 25, 2024 • 5 min read • # swift, # ios, # mlx, # llm In the previous article, we could install and run a sample program using the Swift APIs from the MLX library. Those API provides low level functionalities to create, train and evaluate machine learning models.

6. **MLX**
   https://mlx-framework.org/
   MLX LM - a Python package for generating text and fine-tuning language models on Apple silicon. MLX Whisper - a Python package for speech transcription using OpenAI&#x27;s Whisper models. MLX Examples - standalone examples in the MLX framework including image generation, speech and music generation, language model training and many more. MLX Swift Examples - examples in MLX Swift including LLM ...

7. **Adding New Models | ml-explore/mlx-swift-examples | DeepWiki**
   https://deepwiki.com/ml-explore/mlx-swift-examples/8.3-adding-new-models
   Important: Most model implementations reside in the external mlx-swift-lm repository. This guide primarily addresses how to register and use those models in the examples, rather than implementing new model architectures from scratch.

8. **Native ML with Swift: An Introduction to the MLX Framework**
   https://typevar.dev/articles/ml-explore/mlx-swift-examples
   MLX Swift is a powerful framework that brings the MLX machine learning library to the Swift programming language. Think of it as a bridge that allows you to easily integrate high-performance machine learning models directly into your Apple applications (iOS, macOS, watchOS, etc.) without needing to rely on Python.

9. **GitHub - ml-explore/mlx-swift-examples: Examples using MLX Swift**
   https://github.com.qwqc.cc/ml-explore/mlx-swift-examples
   Examples using MLX Swift. Contribute to ml-explore/mlx-swift-examples development by creating an account on GitHub.

10. **mlx-community (MLX Community) - Hugging Face**
   https://huggingface.co/mlx-community
   MLX Community A community org for MLX model weights that run on Apple Silicon. This organization hosts ready-to-use models compatible with: mlx-lm - A Python package for LLM text generation and fine-tuning with MLX. mlx-swift-examples - a Swift package to run MLX models. mlx-vlm - A Python package for inference and fine-tuning of Vision Language Models (VLMs) using MLX. mlx-audio - A ...




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/raw/main/tokenizer_config.json

{
  "add_prefix_space": true,
  "backend": "tokenizers",
  "bos_token": "",
  "clean_up_tokenization_spaces": false,
  "eos_token": "",
  "is_local": true,
  "legacy": true,
  "max_length": null,
  "model_max_length": 1000000000000000019884624838656,
  "pad_to_multiple_of": null,
  "pad_token": "",
  "pad_token_type_id": 0,
  "padding_side": "left",
  "sp_model_kwargs": {},
  "spaces_between_special_tokens": false,
  "tokenizer_class": "TokenizersBackend",
  "tool_parser_type": "json_tools",
  "unk_token": "",
  "use_default_system_prompt": false
}




---

## 🔧 TOOL RESULTS

[web_search]
Error: DuckDuckGo returned 403




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/NousResearch/Hermes-2-Pro-Mistral-7B/raw/main/tokenizer_config.json

{
  "add_bos_token": true,
  "add_eos_token": false,
  "add_prefix_space": true,
  "added_tokens_decoder": {
    "0": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "1": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "2": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "32000": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "32001": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32002": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32003": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32004": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32005": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32006": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32007": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32008": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32009": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32010": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32011": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32012": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32013": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32014": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32015": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32016": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32017": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32018": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32019": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32020": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32021": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32022": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32023": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32024": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32025": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32026": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32027": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32028": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32029": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32030": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "32031": {
      "content": "
",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": false
    }
  },
  "additional_special_tokens": [],
  "bos_token": "",
  "chat_template": [
    {
      "name": "default",
      "template": "{{bos_token}}{% for message in messages %}{{'' + message['role'] + '\n' + message['content'] + '' + '\n'}}{% endfor %}{% if add_generation_prompt %}{{ 'assistant\n' }}{% endif %}"
    },
    {
      "name": "tool_use",
      "template": "{%- macro json_to_python_type(json_spec) %}\n{%- set basic_type_map = {\n    \"string\": \"str\",\n    \"number\": \"float\",\n    \"integer\": \"int\",\n    \"boolean\": \"bool\"\n} %}\n\n{%- if basic_type_map[json_spec.type] is defined %}\n    {{- basic_type_map[json_spec.type] }}\n{%- elif json_spec.type == \"array\" %}\n    {{- \"list[\" +  json_to_python_type(json_spec|items) + \"]\"}}\n{%- elif json_spec.type == \"object\" %}\n    {%- if json_spec.additionalProperties is defined %}\n        {{- \"dict[str, \" + json_to_python_type(json_spec.additionalProperties) + ']'}}\n    {%- else %}\n        {{- \"dict\" }}\n    {%- endif %}\n{%- elif json_spec.type is iterable %}\n    {{- \"Union[\" }}\n    {%- for t in json_spec.type %}\n      {{- json_to_python_type({\"type\": t}) }}\n      {%- if not loop.last %}\n        {{- \",\" }} \n    {%- endif %}\n    {%- endfor %}\n    {{- \"]\" }}\n{%- else %}\n    {{- \"Any\" }}\n{%- endif %}\n{%- endmacro %}\n\n\n{{- bos_token }}\n{{- 'system\n' }}\n{{- \"You are a function calling AI model. You are provided with function signatures within  XML tags. You may call one or more functions to assist with the user query. Don't make assumptions about what values to plug into functions. Here are the available tools:  \" }}\n{%- for tool in tools %}\n    {%- if tool.function is defined %}\n        {%- set tool = tool.function %}\n    {%- endif %}\n    {{- '{\"type\": \"function\", \"function\": ' }}\n    {{- '{\"name\": \"' + tool.name + '\", ' }}\n    {{- '\"description\": \"' + tool.name + '(' }}\n    {%- for param_name, param_fields in tool.parameters.properties|items %}\n        {{- param_name + \": \" + json_to_python_type(param_fields) }}\n        {%- if not loop.last %}\n            {{- \", \" }}\n        {%- endif %}\n    {%- endfor %}\n    {{- \")\" }}\n    {%- if tool.return is defined %}\n        {{- \" -> \" + json_to_python_type(tool.return) }}\n    {%- endif %}\n    {{- \" - \" + tool.description + \"\n\n\" }}\n    {%- for param_name, param_fields in tool.parameters.properties|items %}\n        {%- if loop.first %}\n            {{- \"    Args:\n\" }}\n        {%- endif %}\n        {{- \"        \" + param_name + \"(\" + json_to_python_type(param_fields) + \"): \" + param_fields.description|trim }}\n    {%- endfor %}\n    {%- if tool.return is defined and tool.return.description is defined %}\n        {{- \"\n    Returns:\n        \" + tool.return.description }}\n    {%- endif %}\n    {{- '\"' }}\n    {{- ', \"parameters\": ' }}\n    {%- if tool.parameters.properties | length == 0 %}\n        {{- \"{}\" }}\n    {%- else %}\n        {{- tool.parameters|tojson }}\n    {%- endif %}\n    {{- \"}\" }}\n    {%- if not loop.last %}\n        {{- \"\n\" }}\n    {%- endif %}\n{%- endfor %}\n{{- \" \" }}\n{{- 'Use the following pydantic model json schema for each tool call you will make: {\"properties\": {\"name\": {\"title\": \"Name\", \"type\": \"string\"}, \"arguments\": {\"title\": \"Arguments\", \"type\": \"object\"}}, \"required\": [\"name\", \"arguments\"], \"title\": \"FunctionCall\", \"type\": \"object\"}}\n' }}\n{{- \"For each function call return a json object with function name and arguments within  XML tags as follows:\n\" }}\n{{- \"\n\" }}\n{{- '{\"name\": , \"arguments\": }\n' }}\n{{- '\n' }}\n{%- for message in messages %}\n    {%- if message.role == \"user\" or message.role == \"system\" or (message.role == \"assistant\" and message.tool_calls is not defined) %}\n        {{- '' + message.role + '\n' + message.content + '' + '\n' }}\n    {%- elif message.role == \"assistant\" %}\n        {{- '' + message.role }}\n    {%- for tool_call in message.tool_calls %}\n       {{- '\n\n' }}           {%- if tool_call.function is defined %}\n                {%- set tool_call = tool_call.function %}\n            {%- endif %}\n            {{- '{' }}\n            {{- '\"name\": \"' }}\n            {{- tool_call.name }}\n            {{- '\"' }}\n            {{- ', '}}\n            {%- if tool_call.arguments is defined %}\n                {{- '\"arguments\": ' }}\n                {%- if tool_call.arguments is string %}\n                    {{- tool_call.arguments }}\n                {%- else %}\n                    {{- tool_call.arguments|tojson }}\n                {%- endif %}\n            {%- endif %}\n             {{- '}' }}\n            {{- '\n' }}\n    {%- endfor %}\n        {{- '\n' }}\n    {%- elif message.role == \"tool\" %}\n        {%- if loop.previtem and loop.previtem.role != \"tool\" %}\n            {{- 'tool\n' }}\n        {%- endif %}\n        {{- '\n' }}\n        {{- message.content }}\n        {%- if not loop.last %}\n            {{- '\n\n' }}\n        {%- else %}\n            {{- '\n' }}\n        {%- endif %}\n        {%- if not loop.last and loop.nextitem.role != \"tool\" %}\n            {{- '' }}\n        {%- elif loop.last %}\n            {{- '' }}\n        {%- endif %}\n    {%- endif %}\n{%- endfor %}\n{%- if add_generation_prompt %}\n    {{- 'assistant\n' }}\n{%- endif %}\n"    
    }
  ],
  "clean_up_tokenization_spaces": true,
  "eos_token": "",
  "legacy": true,
  "model_max_length": 1000000000000000019884624838656,
  "pad_token": "",
  "sp_model_kwargs": {},
  "spaces_between_special_tokens": false,
  "tokenizer_class": "LlamaTokenizer",
  "unk_token": "",
  "use_default_system_prompt": false,
  "use_fast": true
}




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B/raw/main/tokenizer_config.json

{
  "add_bos_token": true,
  "add_eos_token": false,
  "bos_token": {
    "__type": "AddedToken",
    "content": "",
    "lstrip": false,
    "normalized": true,
    "rstrip": false,
    "single_word": false
  },
  "clean_up_tokenization_spaces": false,
  "eos_token": {
    "__type": "AddedToken",
    "content": "",
    "lstrip": false,
    "normalized": true,
    "rstrip": false,
    "single_word": false
  },
  "legacy": true,
  "model_max_length": 16384,
  "pad_token": {
    "__type": "AddedToken",
    "content": "",
    "lstrip": false,
    "normalized": true,
    "rstrip": false,
    "single_word": false
  },
  "sp_model_kwargs": {},
  "unk_token": null,
  "tokenizer_class": "LlamaTokenizerFast",
  "chat_template": "{% if not add_generation_prompt is defined %}{% set add_generation_prompt = false %}{% endif %}{% set ns = namespace(is_first=false, is_tool=false, is_output_first=true, system_prompt='') %}{%- for message in messages %}{%- if message['role'] == 'system' %}{% set ns.system_prompt = message['content'] %}{%- endif %}{%- endfor %}{{bos_token}}{{ns.system_prompt}}{%- for message in messages %}{%- if message['role'] == 'user' %}{%- set ns.is_tool = false -%}{{'' + message['content']}}{%- endif %}{%- if message['role'] == 'assistant' and message['content'] is none %}{%- set ns.is_tool = false -%}{%- for tool in message['tool_calls']%}{%- if not ns.is_first %}{{'' + tool['type'] + '' + tool['function']['name'] + '\\n' + '```json' + '\\n' + tool['function']['arguments'] + '\\n' + '```' + ''}}{%- set ns.is_first = true -%}{%- else %}{{'\\n' + '' + tool['type'] + '' + tool['function']['name'] + '\\n' + '```json' + '\\n' + tool['function']['arguments'] + '\\n' + '```' + ''}}{{''}}{%- endif %}{%- endfor %}{%- endif %}{%- if message['role'] == 'assistant' and message['content'] is not none %}{%- if ns.is_tool %}{{'' + message['content'] + ''}}{%- set ns.is_tool = false -%}{%- else %}{% set content = message['content'] %}{% if '' in content %}{% set content = content.split('')[-1] %}{% endif %}{{'' + content + ''}}{%- endif %}{%- endif %}{%- if message['role'] == 'tool' %}{%- set ns.is_tool = true -%}{%- if ns.is_output_first %}{{'' + message['content'] + ''}}{%- set ns.is_output_first = false %}{%- else %}{{'\\n' + message['content'] + ''}}{%- endif %}{%- endif %}{%- endfor -%}{% if ns.is_tool %}{{''}}{% endif %}{% if add_generation_prompt and not ns.is_tool %}{{'\\n'}}{% endif %}"
}




---

## 🔧 TOOL RESULTS

[web_search]
No results found for: "site:raw.githubusercontent.com/ml-explore/mlx-swift-lm applyChatTemplate("




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/Qwen/Qwen1.5-7B-Chat/raw/main/tokenizer_config.json

{
  "add_prefix_space": false,
  "added_tokens_decoder": {
    "151643": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151644": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "151645": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    }
  },
  "additional_special_tokens": ["", ""],
  "bos_token": null,
  "chat_template": "{% for message in messages %}{% if loop.first and messages[0]['role'] != 'system' %}{{ 'system\nYou are a helpful assistant.\n' }}{% endif %}{{'' + message['role'] + '\n' + message['content'] + '' + '\n'}}{% endfor %}{% if add_generation_prompt %}{{ 'assistant\n' }}{% endif %}",
  "clean_up_tokenization_spaces": false,
  "eos_token": "",
  "errors": "replace",
  "model_max_length": 32768,
  "pad_token": "",
  "split_special_tokens": false,
  "tokenizer_class": "Qwen2Tokenizer",
  "unk_token": null
}




⛔ ABORTED by user
