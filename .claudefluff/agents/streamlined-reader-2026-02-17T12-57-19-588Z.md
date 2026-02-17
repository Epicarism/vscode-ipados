# Agent: streamlined-reader
**Status:** done
**Tokens:** 1,298
**Cost:** $0.0000
**Time:** 2026-02-17T12:57:19.588Z

## Task
Read /Users/danielswagg/Library/Developer/Xcode/DerivedData/VSCodeiPadOS-glroxkvivluzfgakbxxynkqxddup/SourcePackages/checkouts/mlx-swift-examples/Libraries/MLXLMCommon/Streamlined.swift fully. Report: how it handles chat sessions, system prompts, and message formatting.

## Response




---

## 🔧 TOOL RESULTS

[search]
No matches found for "Streamlined"




---

## 🔧 TOOL RESULTS

[run_command]
/Users/danielswagg/Library/Developer/Xcode/DerivedData/VSCodeiPadOS-glroxkvivluzfgakbxxynkqxddup/SourcePackages/checkouts/mlx-swift-examples/Tests/MLXLMTests/StreamlinedTests.swift
/Users/danielswagg/Library/Developer/Xcode/DerivedData/VSCodeiPadOS-glroxkvivluzfgakbxxynkqxddup/SourcePackages/checkouts/mlx-swift-examples/Libraries/MLXLMCommon/Streamlined.swift





---

## 🔧 TOOL RESULTS

[run_command]
// Copyright © 2025 Apple Inc.

import Foundation
import MLX

/// Implementation of simplified API -- see ``ChatSession``.
private class Generator {
    enum Model {
        case container(ModelContainer)
        case context(ModelContext)
    }

    let model: Model
    var messages = [Chat.Message]()
    let processing: UserInput.Processing
    let generateParameters: GenerateParameters
    var cache: [KVCache]

    init(
        model: Model, instructions: String?, prompt: String, image: UserInput.Image?,
        video: UserInput.Video?, processing: UserInput.Processing,
        generateParameters: GenerateParameters
    ) {
        self.model = model
        self.messages = []
        if let instructions = instructions {
            messages.append(.system(instructions))
        }
        messages.append(
            .user(
                prompt, images: image.flatMap { [$0] } ?? [], videos: video.flatMap { [$0] } ?? []))
        self.processing = processing
        self.generateParameters = generateParameters
        self.cache = []
    }

    init(
        model: Model, instructions: String?, processing: UserInput.Processing,
        generateParameters: GenerateParameters
    ) {
        self.model = model
        if let instructions {
            self.messages = [.system(instructions)]
        } else {
            self.messages = []
        }
        self.processing = processing
        self.generateParameters = generateParameters
        self.cache = []
    }

    func generate() async throws -> String {
        func generate(context: ModelContext) async throws -> String {
            // prepare the input -- first the structured messages,
            // next the tokens
            let userInput = UserInput(chat: messages, processing: processing)
            let input = try await context.processor.prepare(input: userInput)

            if cache.isEmpty {
                cache = context.model.newCache(parameters: generateParameters)
            }

            // generate the output
            let iterator = try TokenIterator(
                input: input, model: context.model, cache: cache, parameters: generateParameters)
            let result: GenerateResult = MLXLMCommon.generate(
                input: input, context: context, iterator: iterator
            ) { _ in .more }

            Stream.gpu.synchronize()

            return result.output
        }

        switch model {
        case .container(let container):
            return try await container.perform { context in
                try await generate(context: context)
            }
        case .context(let context):
            return try await generate(context: context)
        }
    }

    func stream() -> AsyncThrowingStream<String, Error> {
        func stream(
            context: ModelContext,
            continuation: AsyncThrowingStream<String, Error>.Continuation
        ) async {
            do {
                // prepare the input -- first the structured messages,
                // next the tokens
                let userInput = UserInput(chat: messages, processing: processing)
                let input = try await context.processor.prepare(input: userInput)

                if cache.isEmpty {
                    cache = context.model.newCache(parameters: generateParameters)
                }

                // stream the responses back
                for await item in try MLXLMCommon.generate(
                    input: input, cache: cache, parameters: generateParameters, context: context)
                {
                    if let chunk = item.chunk {
                        continuation.yield(chunk)
                    }
                }

                Stream.gpu.synchronize()

                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }

        return AsyncThrowingStream { continuation in
            Task { [model, continuation] in
                switch model {
                case .container(let container):
                    await container.perform { context in
                        await stream(context: context, continuation: continuation)
                    }
                case .context(let context):
                    await stream(context: context, continuation: continuation)
                }
            }
        }
    }
}

/// Simplified API for loading models and preparing responses to prompts
/// for both LLMs and VLMs.
///
/// For example:
///
/// ```swift
/// let model = try await loadModel(id: "mlx-community/Qwen3-4B-4bit")
/// let session = ChatSession(model)
/// print(try await session.respond(to: "What are two things to see in San Francisco?")
/// print(try await session.respond(to: "How about a great place to eat?")
/// ```
///
/// This manages the chat context (KVCache) and can produce both single string responses or
/// streaming responses.
public class ChatSession {

    private let generator: Generator

    /// Initialize the `ChatSession`.
    ///
    /// - Parameters:
    ///   - model: the ``ModelContainer``
    ///   - instructions: optional instructions to the chat session, e.g. describing what type of responses to give
    ///   - generateParameters: parameters that control the generation of output, e.g. token limits and temperature
    ///   - processing: optional media processing instructions
    public init(
        _ model: ModelContainer, instructions: String? = nil,
        generateParameters: GenerateParameters = .init(),
        processing: UserInput.Processing = .init(resize: CGSize(width: 512, height: 512))
    ) {
        self.generator = .init(
            model: .container(model), instructions: instructions, processing: processing,
            generateParameters: generateParameters)
    }

    /// Initialize the `ChatSession`.
    ///
    /// - Parameters:
    ///   - model: the ``ModelContext``
    ///   - instructions: optional instructions to the chat session, e.g. describing what type of responses to give
    ///   - generateParameters: parameters that control the generation of output, e.g. token limits and temperature
    ///   - processing: optional media processing instructions
    public init(
        _ model: ModelContext, instructions: String? = nil,
        generateParameters: GenerateParameters = .init(),
        processing: UserInput.Processing = .init(resize: CGSize(width: 512, height: 512))
    ) {
        self.generator = .init(
            model: .context(model), instructions: instructions, processing: processing,
            generateParameters: generateParameters)
    }

    /// Produces a response to a prompt.
    ///
    /// - Parameters:
    ///   - prompt: the prompt
    ///   - images: list of image (for use with VLMs)
    ///   - videos: list of video (for use with VLMs)
    /// - Returns: response from the model
    public func respond(
        to prompt: String,
        images: [UserInput.Image],
        videos: [UserInput.Video]
    ) async throws -> String {
        generator.messages = [
            .user(
                prompt,
                images: images,
                videos: videos
            )
        ]
        return try await generator.generate()
    }

    /// Produces a response to a prompt.
    ///
    /// - Parameters:
    ///   - prompt: the prompt
    ///   - images: optional image (for use with VLMs)
    ///   - videos: optional video (for use with VLMs)
    /// - Returns: response from the model
    public func respond(
        to prompt: String,
        image: UserInput.Image? = nil,
        video: UserInput.Video? = nil
    ) async throws -> String {
        try await respond(
            to: prompt,
            images: image.flatMap { [$0] } ?? [],
            videos: video.flatMap { [$0] } ?? []
        )
    }

    /// Produces a response to a prompt.
    ///
    /// - Parameters:
    ///   - prompt: the prompt
    ///   - images: list of image (for use with VLMs)
    ///   - videos: list of video (for use with VLMs)
    /// - Returns: a stream of tokens (as Strings) from the model
    public func streamResponse(
        to prompt: String,
        images: [UserInput.Image],
        videos: [UserInput.Video]
    ) -> AsyncThrowingStream<String, Error> {
        generator.messages = [
            .user(
                prompt,
                images: images,
                videos: videos
            )
        ]
        return generator.stream()
    }

    /// Produces a response to a prompt.
    ///
    /// - Parameters:
    ///   - prompt: the prompt
    ///   - image: optional image (for use with VLMs)
    ///   - video: optional video (for use with VLMs)
    /// - Returns: a stream of tokens (as Strings) from the model
    public func streamResponse(
        to prompt: String,
        image: UserInput.Image? = nil,
        video: UserInput.Video? = nil
    ) -> AsyncThrowingStream<String, Error> {
        streamResponse(
            to: prompt,
            images: image.flatMap { [$0] } ?? [],
            videos: video.flatMap { [$0] } ?? []
        )
    }
}



Now let me read the supporting types to complete the picture:



---

## 🔧 TOOL RESULTS

[run_command]
// Copyright © 2024 Apple Inc.

import AVFoundation
import CoreImage
import Foundation
import MLX
import Tokenizers

public typealias Message = [String: Any]

/// Container for raw user input.
///
/// A ``UserInputProcessor`` can convert this to ``LMInput``.
/// See also ``ModelContext``.
public struct UserInput: Sendable {

    /// Representation of a prompt or series of messages (conversation).
    ///
    /// This may be a single string with a user prompt or a series of back
    /// and forth responses representing a conversation.
    public enum Prompt: Sendable, CustomStringConvertible {
        /// a single string
        case text(String)

        /// model specific array of dictionaries
        case messages([Message])

        /// model agnostic structured chat (series of messages)
        case chat([Chat.Message])

        public var description: String {
            switch self {
            case .text(let text):
                return text
            case .messages(let messages):
                return messages.map { $0.description }.joined(separator: "\n")
            case .chat(let messages):
                return messages.map(\.content).joined(separator: "\n")
            }
        }
    }

    /// Representation of a video resource.
    public enum Video: Sendable {
        case avAsset(AVAsset)
        case url(URL)

        public func asAVAsset() -> AVAsset {
            switch self {
            case .avAsset(let asset):
                return asset
            case .url(let url):
                return AVAsset(url: url)
            }
        }
    }

    /// Representation of an image resource.
    public enum Image: Sendable {
        case ciImage(CIImage)
        case url(URL)
        case array(MLXArray)

        public func asCIImage() throws -> CIImage {
            switch self {
            case .ciImage(let image):
                return image

            case .url(let url):
                if let image = CIImage(contentsOf: url) {
                    return image
                }
                throw UserInputError.unableToLoad(url)

            case .array(let array):
                guard array.ndim == 3 else {
                    throw UserInputError.arrayError("array must have 3 dimensions: \(array.ndim)")
                }

                var array = array

                // convert to 0 .. 255
                if array.max().item(Float.self) <= 1.0 {
                    array = array * 255
                }

                // planar -> pixels
                switch array.dim(0) {
                case 3, 4:
                    // channels first (planar)
                    array = array.transposed(1, 2, 0)
                default:
                    break
                }

                // 4 components per pixel
                switch array.dim(-1) {
                case 3:
                    // pad to 4 bytes per pixel
                    array = padded(array, widths: [0, 0, [0, 1]], value: MLXArray(255))
                case 4:
                    // good
                    break
                default:
                    throw UserInputError.arrayError(
                        "channel dimension must be last and 3/4: \(array.shape)")
                    break
                }

                let arrayData = array.asData()
                let (H, W, C) = array.shape3
                let cs = CGColorSpace(name: CGColorSpace.sRGB)!

                return CIImage(
                    bitmapData: arrayData.data, bytesPerRow: W * 4,
                    size: .init(width: W, height: H),
                    format: .RGBA8, colorSpace: cs)
            }
        }
    }

    /// Representation of processing to apply to media.
    public struct Processing: Sendable {
        public var resize: CGSize?

        public init(resize: CGSize? = nil) {
            self.resize = resize
        }
    }

    /// The prompt to evaluate.
    public var prompt: Prompt {
        didSet {
            switch prompt {
            case .text, .messages:
                // no action
                break
            case .chat(let messages):
                // rebuild images & videos
                self.images = messages.reduce(into: []) { result, message in
                    result.append(contentsOf: message.images)
                }
                self.videos = messages.reduce(into: []) { result, message in
                    result.append(contentsOf: message.videos)
                }
            }
        }
    }

    /// The images associated with the `UserInput`.
    ///
    /// If the ``prompt-swift.property`` is a ``Prompt-swift.enum/chat(_:)`` this will
    /// collect the images from the chat messages, otherwise these are the stored images with the ``UserInput``.
    public var images = [Image]()

    /// The images associated with the `UserInput`.
    ///
    /// If the ``prompt-swift.property`` is a ``Prompt-swift.enum/chat(_:)`` this will
    /// collect the videos from the chat messages, otherwise these are the stored videos with the ``UserInput``.
    public var videos = [Video]()

    public var tools: [ToolSpec]?

    /// Additional values provided for the chat template rendering context
    public var additionalContext: [String: Any]?
    public var processing: Processing = .init()

    /// Initialize the `UserInput` with a single text prompt.
    ///
    /// - Parameters:
    ///   - prompt: text prompt
    ///   - images: optional images
    ///   - videos: optional videos
    ///   - tools: optional tool specifications
    ///   - additionalContext: optional context (model specific)
    /// ### See Also
    /// - ``Prompt-swift.enum/text(_:)``
    /// - ``init(chat:tools:additionalContext:)``
    public init(
        prompt: String, images: [Image] = [Image](), videos: [Video] = [Video](),
        tools: [ToolSpec]? = nil,
        additionalContext: [String: Any]? = nil
    ) {
        self.prompt = .chat([
            .user(prompt, images: images, videos: videos)
        ])
        self.tools = tools
        self.additionalContext = additionalContext
    }

    /// Initialize the `UserInput` with model specific mesage structures.
    ///
    /// For example, the Qwen2VL model wants input in this format:
    ///
    /// ```
    /// [
    ///     [
    ///         "role": "user",
    ///         "content": [
    ///             [
    ///                 "type": "text",
    ///                 "text": "What is this?"
    ///             ],
    ///             [
    ///                 "type": "image",
    ///             ],
    ///         ]
    ///     ]
    /// ]
    /// ```
    ///
    /// Typically the ``init(chat:tools:additionalContext:)`` should be used instead
    /// along with a model specific ``MessageGenerator`` (supplied by the ``UserInputProcessor``).
    ///
    /// - Parameters:
    ///   - messages: array of dictionaries representing the prompt in a model specific format
    ///   - images: optional images
    ///   - videos: optional videos
    ///   - tools: optional tool specifications
    ///   - additionalContext: optional context (model specific)
    /// ### See Also
    /// - ``Prompt-swift.enum/text(_:)``
    /// - ``init(chat:tools:additionalContext:)``
    public init(
        messages: [Message], images: [Image] = [Image](), videos: [Video] = [Video](),
        tools: [ToolSpec]? = nil,
        additionalContext: [String: Any]? = nil
    ) {
        self.prompt = .messages(messages)
        self.images = images
        self.videos = videos
        self.tools = tools
        self.additionalContext = additionalContext
    }

    /// Initialize the `UserInput` with a model agnostic structured context.
    ///
    /// For example:
    ///
    /// ```
    /// let chat: [Chat.Message] = [
    ///     .system("You are a helpful photographic assistant."),
    ///     .user("Please describe the photo.", images: [image1]),
    /// ]
    /// let userInput = UserInput(chat: chat)
    /// ```
    ///
    /// A model specific ``MessageGenerator`` (supplied by the ``UserInputProcessor``)
    /// is used to convert this into a model specific format.
    ///
    /// - Parameters:
    ///   - chat: structured content
    ///   - tools: optional tool specifications
    ///   - processing: optional processing to be applied to media
    ///   - additionalContext: optional context (model specific)
    /// ### See Also
    /// - ``Prompt-swift.enum/text(_:)``
    /// - ``init(chat:tools:additionalContext:)``
    public init(
        chat: [Chat.Message],
        processing: Processing = .init(),
        tools: [ToolSpec]? = nil,
        additionalContext: [String: Any]? = nil
    ) {
        self.prompt = .chat(chat)

        // note: prompt.didSet is not triggered in init
        self.images = chat.reduce(into: []) { result, message in
            result.append(contentsOf: message.images)
        }
        self.videos = chat.reduce(into: []) { result, message in
            result.append(contentsOf: message.videos)
        }

        self.processing = processing
        self.tools = tools
        self.additionalContext = additionalContext
    }

    /// Initialize the `UserInput` with a preconfigured ``Prompt-swift.enum``.
    ///
    /// ``init(chat:tools:additionalContext:)`` is the preferred mechanism.
    ///
    /// - Parameters:
    ///   - prompt: the prompt
    ///   - images: optional images
    ///   - videos: optional videos
    ///   - tools: optional tool specifications
    ///   - processing: optional processing to be applied to media
    ///   - additionalContext: optional context (model specific)
    /// ### See Also
    /// - ``Prompt-swift.enum/text(_:)``
    /// - ``init(chat:tools:additionalContext:)``
    public init(
        prompt: Prompt,
        images: [Image] = [Image](),
        videos: [Video] = [Video](),
        processing: Processing = .init(),
        tools: [ToolSpec]? = nil, additionalContext: [String: Any]? = nil
    ) {
        self.prompt = prompt
        switch prompt {
        case .text, .messages:
            self.images = images
            self.videos = videos
        case .chat:
            break
        }
        self.processing = processing
        self.tools = tools
        self.additionalContext = additionalContext
    }
}

/// Protocol for a type that can convert ``UserInput`` to ``LMInput``.
///
/// See also ``ModelContext``.
public protocol UserInputProcessor {
    func prepare(input: UserInput) async throws -> LMInput
}

private enum UserInputError: LocalizedError {
    case notImplemented
    case unableToLoad(URL)
    case arrayError(String)

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return String(localized: "This functionality is not implemented.")
        case .unableToLoad(let url):
            return String(localized: "Unable to load image from URL: \(url.path).")
        case .arrayError(let message):
            return String(localized: "Error processing image array: \(message).")
        }
    }
}

/// A do-nothing ``UserInputProcessor``.
public struct StandInUserInputProcessor: UserInputProcessor {
    public init() {}

    public func prepare(input: UserInput) throws -> LMInput {
        throw UserInputError.notImplemented
    }
}





---

## 🔧 TOOL RESULTS

[run_command]
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

        public enum Role: String {
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
public protocol MessageGenerator {

    /// Generates messages from the input.
    func generate(from input: UserInput) -> [Message]

    /// Returns array of `[String: Any]` aka ``Message``
    func generate(messages: [Chat.Message]) -> [Message]

    /// Returns `[String: Any]` aka ``Message``.
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



>>>REPORT
## Streamlined.swift — Chat Sessions, System Prompts, and Message Formatting

**File:** `/Users/danielswagg/Library/Developer/Xcode/DerivedData/VSCodeiPadOS-glroxkvivluzfgakbxxynkqxddup/SourcePackages/checkouts/mlx-swift-examples/Libraries/MLXLMCommon/Streamlined.swift`

### Architecture Overview

The file contains two types:
1. **`Generator`** (private class) — the internal engine that holds state and performs generation.
2. **`ChatSession`** (public class) — the simplified public API wrapping `Generator`.

---

### Chat Sessions (`ChatSession`)

- `ChatSession` is initialized with either a `ModelContainer` or `ModelContext`, plus optional `instructions` (system prompt), `GenerateParameters`, and media `Processing`.
- It holds a single `Generator` instance for its lifetime.
- **KVCache is maintained across calls** — `Generator.cache` is a `[KVCache]` that persists, initialized empty and lazily populated on first generation (`if cache.isEmpty { cache = context.model.newCache(...) }`).
- Two response modes:
  - **`respond(to:)`** — async, returns a complete `String` via `Generator.generate()`.
  - **`streamResponse(to:)`** — returns `AsyncThrowingStream<String, Error>` via `Generator.stream()`.

**Critical behavior on each call:** Both `respond()` and `streamResponse()` **replace** `generator.messages` with only the new user message:
```swift
generator.messages = [
    .user(prompt, images: images, videos: videos)
]
```
This means **the message array is reset each turn** — it does NOT accumulate conversation history. However, **the KVCache persists**, so the model retains context from prior turns through the cache, not through re-sending all messages.

---

### System Prompts

- System prompts are handled via the `instructions` parameter at init time.
- In `Generator.init` (the two-arg version used by `ChatSession`), if `instructions` is non-nil, it's prepended as `.system(instructions)` to the messages array.
- However, since `ChatSession.respond()` and `streamResponse()` **replace** `generator.messages` entirely with just the user message, the system prompt is only included in the **first** generation (when `Generator.init` sets it up). On subsequent calls, the messages array is overwritten without the system message.
- This is intentional: the KVCache preserves the system prompt's effect from the first call, so it doesn't need to be re-sent.

There's also a separate `Generator.init` (the one-shot version with prompt/image/video params) that builds the full message array inline — this path is **not used** by `ChatSession` but exists for standalone use.

---

### Message Formatting Pipeline

The formatting chain is:

1. **`Chat.Message`** (from `Chat.swift`) — model-agnostic structured messages with `Role` enum (`.user`, `.assistant`, `.system`, `.tool`) plus content, images, and videos. Has convenience static factories: `.system(...)`, `.user(...)`, `.assistant(...)`, `.tool(...)`.

2. **`UserInput`** — created from `[Chat.Message]` via `UserInput(chat: messages, processing: processing)`. The `.chat` prompt type collects images/videos from all messages automatically.

3. **`MessageGenerator` protocol** — converts `Chat.Message` → `[String: Any]` (model-specific dictionary format). Default implementation (`DefaultMessageGenerator`) produces `["role": role.rawValue, "content": content]`. Models can override (e.g., `Qwen2VLMessageGenerator` for VLM-specific formats). A `NoSystemMessageGenerator` variant filters out system messages.

4. **`UserInputProcessor.prepare(input:)`** — the model-specific processor converts `UserInput` → `LMInput` (tokenized). This is where chat templates are applied (via the tokenizer's `applyChatTemplate`).

5. **Token generation** — `LMInput` feeds into `TokenIterator` → `MLXLMCommon.generate()`.

---

### Key Files Examined
- `Streamlined.swift` — main file (full content read)
- `Chat.swift` — `Chat.Message` struct, `MessageGenerator` protocol, `DefaultMessageGenerator`, `NoSystemMessageGenerator`
- `UserInput.swift` — `UserInput` struct, `Prompt` enum (`.text`, `.messages`, `.chat`), `UserInputProcessor` protocol

### Summary of Design Decisions
1. **Stateful KVCache, stateless messages** — Each turn overwrites messages but reuses cache, avoiding redundant re-tokenization of history.
2. **System prompt is fire-once** — Set at init, included in first generation, then implicitly retained through KVCache.
3. **Model-agnostic abstraction** — `Chat.Message` provides a unified interface; model-specific formatting is deferred to `MessageGenerator` implementations and `UserInputProcessor.prepare()`.
4. **VLM support built-in** — Images and videos are first-class citizens at every level (Chat.Message, UserInput, ChatSession API).
>>>END
