import Foundation
import Combine

/// Manages inline code suggestions with debouncing, throttling, and cancellation support.
/// Uses Combine operators to prevent excessive API calls while maintaining responsive UX.
/// 
/// Request Flow:
/// 1. User types → typingSubject receives event
/// 2. Cancel any pending request immediately (prevent stale results)
/// 3. Debounce: Wait 300ms after user stops typing
/// 4. Throttle: Max 1 request per 2 seconds (drop events if under throttle window)
/// 5. Filter: Remove duplicates and empty contexts
/// 6. Fetch: Execute API request with cancellation support
/// 7. Update: Publish result to currentSuggestion
@MainActor
final class InlineSuggestionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The current inline suggestion text to display, if any.
    @Published var currentSuggestion: String?
    
    /// The current cursor position in the document.
    @Published var cursorPosition: CursorPosition = CursorPosition(line: 0, column: 0)
    
    /// Whether a suggestion request is currently in progress.
    @Published var isLoading: Bool = false
    
    /// The last error that occurred during suggestion fetching.
    @Published var lastError: Error?
    
    // MARK: - Configuration
    
    /// Debounce interval after user stops typing (300ms).
    /// This prevents firing requests while user is actively typing.
    private let debounceInterval: TimeInterval = 0.3
    
    /// Throttle interval for maximum request rate (2 seconds).
    /// This ensures max 1 request per 2 seconds, preventing API abuse.
    private let throttleInterval: TimeInterval = 2.0
    
    // MARK: - Combine Pipeline
    
    /// Subject for user typing events.
    /// Uses unlimited buffer to ensure no events are dropped.
    private let typingSubject = PassthroughSubject<TextChangeEvent, Never>()
    
    /// The Combine pipeline subscription.
    private var pipelineCancellable: AnyCancellable?
    
    /// Set to store all subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// Current async task handle for fetching suggestions.
    /// Used to cancel in-flight requests.
    private var fetchTask: Task<String?, Never>?
    
    // MARK: - Partial Accept State
    
    /// Tracks the current position within a partially accepted suggestion.
    /// This is the offset into `currentSuggestion` that has already been accepted.
    @Published var partialAcceptPosition: Int = 0
    
    /// The text that has been partially accepted so far.
    var acceptedText: String {
        guard let suggestion = currentSuggestion,
              partialAcceptPosition > 0,
              partialAcceptPosition <= suggestion.count else {
            return ""
        }
        let endIndex = suggestion.index(suggestion.startIndex, offsetBy: partialAcceptPosition)
        return String(suggestion[..<endIndex])
    }
    
    /// The remaining unaccepted portion of the suggestion.
    var remainingSuggestionText: String {
        guard let suggestion = currentSuggestion,
              partialAcceptPosition < suggestion.count else {
            return ""
        }
        let startIndex = suggestion.index(suggestion.startIndex, offsetBy: partialAcceptPosition)
        return String(suggestion[startIndex...])
    }
    
    // MARK: - Types
    
    /// Represents a cursor position in the editor.
    struct CursorPosition: Equatable, Hashable {
        let line: Int
        let column: Int
        
        var isValid: Bool {
            return line >= 0 && column >= 0
        }
    }
    
    /// Represents a text change event with all context needed for suggestions.
    struct TextChangeEvent: Equatable {
        let content: String
        let position: CursorPosition
        let timestamp: Date
        
        static func == (lhs: TextChangeEvent, rhs: TextChangeEvent) -> Bool {
            lhs.content == rhs.content &&
            lhs.position == rhs.position
        }
    }
    
    /// Extracted context for suggestion requests.
    struct SuggestionContext: Equatable {
        let currentLine: String
        let precedingCode: String
        let cursorPosition: CursorPosition
        let language: String?
    }
    
    // MARK: - Initialization
    
    init() {
        setupSuggestionPipeline()
    }
    
    deinit {
        pipelineCancellable?.cancel()
        fetchTask?.cancel()
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Methods
    
    /// Requests a suggestion for the given content at the current cursor position.
    /// 
    /// This method:
    /// 1. Immediately cancels any pending request (keystroke takes priority)
    /// 2. Updates the cursor position
    /// 3. Sends event through the Combine pipeline (debounce + throttle)
    ///
    /// - Parameters:
    ///   - content: The full text content of the document.
    ///   - position: The current cursor position.
    func requestSuggestion(for content: String, at position: CursorPosition) {
        // CRITICAL: Cancel any in-flight request immediately on new keystroke
        // This prevents stale suggestions from appearing when user types quickly
        cancelPendingRequest()
        
        // Update cursor position
        self.cursorPosition = position
        
        // Create text change event
        let event = TextChangeEvent(
            content: content,
            position: position,
            timestamp: Date()
        )
        
        // Send through Combine pipeline (debounce + throttle will be applied)
        typingSubject.send(event)
    }
    
    /// Cancels any pending suggestion request and clears loading state.
    func cancelPendingRequest() {
        fetchTask?.cancel()
        fetchTask = nil
        isLoading = false
    }
    
    /// Clears the current suggestion.
    func clearSuggestion() {
        currentSuggestion = nil
        partialAcceptPosition = 0
        lastError = nil
    }
    
    /// Accepts the next word of the current inline suggestion.
    /// - Returns: The text that was accepted in this call, or nil if no suggestion is active
    @discardableResult
    func partialAccept() -> String? {
        guard let suggestion = currentSuggestion else {
            return nil
        }
        
        // Check if we've already fully accepted the suggestion
        guard partialAcceptPosition < suggestion.count else {
            clearSuggestion()
            return nil
        }
        
        // Find the next word boundary from current position
        let remainingText = remainingSuggestionText
        let charsToAccept = findNextWordEnd(in: remainingText)
        
        // Get the text to accept
        let startIndex = suggestion.index(suggestion.startIndex, offsetBy: partialAcceptPosition)
        let endIndex = suggestion.index(startIndex, offsetBy: charsToAccept)
        let textToAccept = String(suggestion[startIndex..<endIndex])
        
        // Update the partial accept position
        partialAcceptPosition += charsToAccept
        
        return textToAccept
    }
    
    /// Resets the partial accept state to start from the beginning.
    func resetPartialAcceptState() {
        partialAcceptPosition = 0
    }
    
    /// Checks if the suggestion has been fully accepted.
    var isSuggestionFullyAccepted: Bool {
        guard let suggestion = currentSuggestion else { return false }
        return partialAcceptPosition >= suggestion.count
    }
    
    /// Returns the ghost text to display (remaining unaccepted portion).
    var ghostText: String {
        return remainingSuggestionText
    }
    
    /// Updates the cursor position without triggering a suggestion request.
    func updateCursorPosition(_ position: CursorPosition) {
        self.cursorPosition = position
    }
    
    // MARK: - Private Methods
    
    /// Sets up the Combine pipeline with debounce and throttle operators.
    /// 
    /// Pipeline flow:
    /// 1. typingSubject receives events
    /// 2. debounce(0.3s): Wait 300ms after user stops typing
    /// 3. throttle(2.0s): Max 1 event per 2 seconds (latest=true for responsive updates)
    /// 4. removeDuplicates: Filter identical events
    /// 5. filter: Remove empty/unworthy contexts
    /// 6. flatMap: Execute async fetch with cancellation support
    private func setupSuggestionPipeline() {
        pipelineCancellable = typingSubject
            // STEP 1: DEBOUNCE (300ms)
            // Wait 300ms after user stops typing before processing
            // This prevents firing requests while user is actively typing
            .debounce(for: .seconds(debounceInterval), scheduler: DispatchQueue.main)
            
            // STEP 2: THROTTLE (2 seconds)
            // Maximum 1 request per 2 seconds
            // latest=true ensures we get the most recent event if multiple occur within throttle window
            .throttle(for: .seconds(throttleInterval), scheduler: DispatchQueue.main, latest: true)
            
            // STEP 3: REMOVE DUPLICATES
            // Filter out events with identical content and position
            // This prevents duplicate API calls for the same context
            .removeDuplicates()
            
            // STEP 4: FILTER WORTHY CONTEXTS
            // Only proceed if we have meaningful content to get suggestions for
            .filter { [weak self] event in
                guard let self = self else { return false }
                let context = self.extractContext(from: event.content, at: event.position)
                return self.shouldRequestSuggestion(context: context)
            }
            
            // STEP 5: FLATMAP TO ASYNC FETCH
            // Transform each event into a publisher that fetches suggestions
            // This creates a new async context that can be cancelled
            .flatMap { [weak self] event -> AnyPublisher<String?, Never> in
                guard let self = self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                let context = self.extractContext(from: event.content, at: event.position)
                return self.createFetchPublisher(for: context)
            }
            // Ensure we receive on main thread for UI updates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] suggestion in
                self?.currentSuggestion = suggestion
                self?.isLoading = false
            }
    }
    
    /// Creates a Combine publisher that performs the async suggestion fetch.
    /// This allows the fetch to be cancelled when new events arrive.
    private func createFetchPublisher(for context: SuggestionContext) -> AnyPublisher<String?, Never> {
        // Cancel any existing fetch task
        fetchTask?.cancel()
        
        // Create new async task for fetching
        let task = Task { [weak self] () -> String? in
            guard let self = self else { return nil }
            
            await MainActor.run {
                self.isLoading = true
                self.lastError = nil
            }
            
            do {
                // Perform the actual fetch
                let suggestion = try await self.fetchSuggestion(for: context)
                
                // Check if cancelled before updating UI
                try Task.checkCancellation()
                return suggestion
            } catch is CancellationError {
                // Task was cancelled - return nil silently
                return nil
            } catch {
                await MainActor.run {
                    self.lastError = error
                }
                return nil
            }
        }
        
        fetchTask = task
        
        // Convert the async task to a publisher
        return Future<String?, Never> { promise in
            Task {
                let result = await task.value
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Fetches a suggestion from the completion service.
    private func fetchSuggestion(for context: SuggestionContext) async throws -> String? {
        // Simulate network delay - replace with actual API call
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Check for cancellation before returning
        try Task.checkCancellation()
        
        // Placeholder: Return nil or mock suggestion based on context
        // This should be replaced with actual LLM or completion service integration
        return nil
    }
    
    /// Fetches a suggestion from the completion service.
    /// This is a placeholder that should be replaced with actual implementation.
    private func fetchSuggestion(for context: SuggestionContext) async throws -> String? {
        // Simulate network delay - replace with actual API call
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Check for cancellation
        try Task.checkCancellation()
        
        // Placeholder: Return nil or mock suggestion based on context
        // This should be replaced with actual LLM or completion service integration
        return nil
    }
    
    /// Extracts context information from the content at the given position.
    private func extractContext(from content: String, at position: CursorPosition) -> SuggestionContext {
        let lines = content.components(separatedBy: .newlines)
        
        // Get current line
        let currentLineIndex = min(position.line, max(0, lines.count - 1))
        let currentLine = lines.indices.contains(currentLineIndex) ? lines[currentLineIndex] : ""
        
        // Get preceding code (all lines before current)
        let precedingLines = lines.prefix(currentLineIndex)
        let precedingCode = precedingLines.joined(separator: "\n")
        
        // Detect language from file extension or content (placeholder)
        let language = detectLanguage(from: content)
        
        return SuggestionContext(
            currentLine: currentLine,
            precedingCode: precedingCode,
            cursorPosition: position,
            language: language
        )
    }
    
    /// Detects the programming language from content.
    /// This is a simple placeholder implementation.
    private func detectLanguage(from content: String) -> String? {
        // Basic heuristics for language detection
        // In a real implementation, this would use file extension or more sophisticated detection
        
        if content.contains("import Swift") || content.contains("func ") && content.contains("->") {
            return "swift"
        } else if content.contains("function") || content.contains("const ") || content.contains("let ") {
            return "javascript"
        } else if content.contains("def ") || content.contains("import ") && content.contains("print(") {
            return "python"
        }
        
        return nil
    }
    
    /// Determines if a suggestion should be requested based on context.
    /// This can be used to avoid requesting suggestions in inappropriate contexts.
    private func shouldRequestSuggestion(context: SuggestionContext) -> Bool {
        // Don't suggest on empty lines unless there's preceding context
        if context.currentLine.trimmingCharacters(in: .whitespaces).isEmpty {
            return !context.precedingCode.isEmpty
        }
        
        // Minimum content length to trigger suggestions
        let minContextLength = 10
        let totalContextLength = context.precedingCode.count + context.currentLine.count
        
        return totalContextLength >= minContextLength
    }
    
    // MARK: - Word Boundary Helpers for Partial Accept
    
    /// Finds the end position of the next word in the given text.
    /// A word is defined as a sequence of characters up to and including:
    /// - The next whitespace character (space, tab, newline)
    /// - The end of the punctuation after a word
    /// - The next punctuation boundary
    private func findNextWordEnd(in text: String) -> Int {
        guard !text.isEmpty else { return 0 }
        
        let characters = Array(text)
        var position = 0
        
        // Skip leading whitespace (accept it as part of the word if present)
        var leadingWhitespaceCount = 0
        while position < characters.count && characters[position].isWhitespace {
            position += 1
            leadingWhitespaceCount += 1
        }
        
        // If we only had whitespace, return that
        if position >= characters.count {
            return position
        }
        
        // Get the current character type
        let firstChar = characters[position]
        
        if firstChar.isLetter || firstChar.isNumber {
            // Word character: consume all word characters
            while position < characters.count && (characters[position].isLetter || characters[position].isNumber) {
                position += 1
            }
            
            // Also consume any trailing punctuation attached to the word (like "word.")
            while position < characters.count && isWordPunctuation(characters[position]) {
                position += 1
            }
            
            // Include trailing whitespace after the word (just one space)
            if position < characters.count && characters[position].isWhitespace {
                position += 1
            }
        } else if isPunctuation(firstChar) {
            // Punctuation: consume all consecutive punctuation
            while position < characters.count && isPunctuation(characters[position]) {
                position += 1
            }
            
            // Include trailing whitespace (just one space)
            if position < characters.count && characters[position].isWhitespace {
                position += 1
            }
        } else if firstChar.isWhitespace {
            // Multiple whitespace: accept all consecutive whitespace
            while position < characters.count && characters[position].isWhitespace {
                position += 1
            }
        } else {
            // Other characters: just consume one character
            position += 1
        }
        
        // Ensure we always accept at least one non-whitespace character
        // or all leading whitespace if that's all there is
        return max(position, leadingWhitespaceCount > 0 ? leadingWhitespaceCount : 1)
    }
    
    /// Checks if a character is punctuation that can be part of a word (like period, comma, etc.)
    private func isWordPunctuation(_ char: Character) -> Bool {
        let wordPunctuation = CharacterSet(charactersIn: ".,;:!?-_'")
        guard let scalar = char.unicodeScalars.first else { return false }
        return wordPunctuation.contains(scalar)
    }
    
    /// Checks if a character is general punctuation or symbol
    private func isPunctuation(_ char: Character) -> Bool {
        return char.isPunctuation || char.isSymbol
    }
}

// MARK: - Error Types

enum InlineSuggestionError: Error {
    case requestThrottled
    case noContextAvailable
    case serviceUnavailable
    case cancelled
}

// MARK: - UIKeyCommand Extensions for Partial Accept

/// Extension to provide keyboard shortcut bindings for partial accept functionality.
/// Bind to Ctrl+Right Arrow or Option+Right Arrow.
extension UIResponder {
    
    /// Registers keyboard commands for inline suggestions partial accept.
    /// Call this from your editor view controller to enable Ctrl+Right and Option+Right shortcuts.
    static func registerInlineSuggestionKeyCommands() -> [UIKeyCommand] {
        // Ctrl+Right Arrow for partial accept
        let ctrlRightCommand = UIKeyCommand(
            input: UIKeyCommand.inputRightArrow,
            modifierFlags: .control,
            action: #selector(performPartialAccept(_:))
        )
        ctrlRightCommand.wantsPriorityOverSystemBehavior = true
        
        // Option+Right Arrow for partial accept (alternative binding)
        let optRightCommand = UIKeyCommand(
            input: UIKeyCommand.inputRightArrow,
            modifierFlags: .alternate,
            action: #selector(performPartialAccept(_:))
        )
        optRightCommand.wantsPriorityOverSystemBehavior = true
        
        return [ctrlRightCommand, optRightCommand]
    }
    
    @objc private func performPartialAccept(_ sender: UIKeyCommand) {
        // Access the shared manager and perform partial accept
        // This requires the editor to insert the accepted text at cursor position
        NotificationCenter.default.post(
            name: .inlineSuggestionPartialAccept,
            object: nil
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when partial accept should be performed.
    /// Bind your editor's insert method to this notification.
    static let inlineSuggestionPartialAccept = Notification.Name("inlineSuggestionPartialAccept")
}
