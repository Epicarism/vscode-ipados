import SwiftUI
import Foundation

// Type aliases for external use
typealias AutocompleteSuggestion = AutocompleteManager.Suggestion
typealias AutocompleteSuggestionKind = AutocompleteManager.SuggestionKind

/// FEAT-045/046/047
/// - Basic autocomplete dropdown state (showSuggestions/selectedIndex)
/// - Current file symbol extraction
/// - Swift stdlib completions (top-level + a small set of member completions)
/// - LSP-powered completions when a tunnel is connected
final class AutocompleteManager: ObservableObject {

    /// Current filename for language detection (set by editor)
    var currentFilename: String = ""

    /// Current file URI for LSP document synchronization (set by editor)
    var currentFileURI: String = ""

    // MARK: - UI-facing legacy API (kept for existing views)

    /// A simple list used by existing UI.
    @Published var suggestions: [String] = []
    @Published var showSuggestions = false
    @Published var selectedIndex = 0

    // MARK: - Rich suggestion model (for future UI)

    enum SuggestionKind: String, Hashable {
        case keyword
        case stdlib
        case symbol
        case member
        case snippet
        case lsp
    }

    struct Suggestion: Identifiable, Hashable {
        var id: String { "\(kind.rawValue):\(insertText)" }
        let kind: SuggestionKind
        let displayText: String
        let insertText: String
        let score: Int

        init(kind: SuggestionKind, displayText: String, insertText: String? = nil, score: Int) {
            self.kind = kind
            self.displayText = displayText
            self.insertText = insertText ?? displayText
            self.score = score
        }
    }

    /// Structured suggestions (not currently required by UI, but provides plumbing).
    @Published private(set) var suggestionItems: [Suggestion] = []

    // MARK: - Completion sources

    // Swift keywords
    private let swiftKeywords: [String] = [
        "import", "func", "var", "let", "class", "struct", "enum",
        "if", "else", "for", "while", "switch", "case", "return",
        "true", "false", "nil", "self", "super", "init", "deinit",
        "extension", "protocol", "typealias", "static", "private",
        "public", "internal", "fileprivate", "open", "final",
        "guard", "defer", "break", "continue", "fallthrough",
        "throws", "throw", "try", "catch", "do", "as", "is",
        "in", "where", "associatedtype", "mutating", "nonmutating",
        "convenience", "required", "override"
    ]

    // TypeScript/JavaScript keywords
    private let tsKeywords: [String] = [
        "const", "let", "var", "function", "class", "interface", "type",
        "enum", "if", "else", "for", "while", "switch", "case", "return",
        "import", "export", "default", "async", "await", "try", "catch",
        "throw", "new", "this", "typeof", "instanceof", "void",
        "null", "undefined", "true", "false", "extends", "implements",
        "abstract", "readonly", "private", "public", "protected", "static",
        "declare", "namespace", "module", "require", "yield", "delete",
        "in", "of", "break", "continue", "do", "finally", "super",
        "as", "from", "satisfies", "keyof", "infer"
    ]

    // Python keywords
    private let pyKeywords: [String] = [
        "def", "class", "if", "elif", "else", "for", "while", "return",
        "import", "from", "as", "try", "except", "finally", "raise",
        "with", "pass", "break", "continue", "yield", "lambda",
        "and", "or", "not", "in", "is", "True", "False", "None",
        "global", "nonlocal", "assert", "del", "async", "await",
        "match", "case", "type"
    ]

    /// Language-aware keyword lookup
    private var keywords: [String] {
        switch currentLanguageId {
        case "typescript", "javascript", "typescriptreact", "javascriptreact":
            return tsKeywords
        case "python":
            return pyKeywords
        default:
            return swiftKeywords
        }
    }

    // Swift stdlib
    private let swiftStdlib: [String] = [
        // Common types
        "Any", "AnyObject", "Never", "Void",
        "Bool",
        "Int", "Int8", "Int16", "Int32", "Int64",
        "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
        "Float", "Double",
        "String", "Character", "Substring",
        "Array", "Dictionary", "Set", "Optional", "Result",

        // Common protocols
        "Equatable", "Hashable", "Comparable",
        "Sequence", "Collection", "BidirectionalCollection", "RandomAccessCollection",
        "IteratorProtocol",
        "Encodable", "Decodable", "Codable",
        "Identifiable", "CaseIterable",
        "Error",

        // Concurrency (Swift stdlib)
        "Task", "MainActor", "Actor", "Sendable",

        // Common functions
        "print", "debugPrint", "dump",
        "assert", "assertionFailure", "precondition", "preconditionFailure", "fatalError",
        "min", "max", "abs", "zip", "stride"
    ]

    // TypeScript/JavaScript stdlib
    private let tsStdlib: [String] = [
        // Built-in types
        "Array", "Map", "Set", "WeakMap", "WeakSet", "Promise",
        "Object", "String", "Number", "Boolean", "Symbol", "BigInt",
        "Date", "RegExp", "Error", "TypeError", "RangeError", "SyntaxError",
        "JSON", "Math", "Proxy", "Reflect",
        // DOM / Web APIs
        "console", "document", "window", "navigator",
        "setTimeout", "setInterval", "clearTimeout", "clearInterval",
        "fetch", "Request", "Response", "Headers",
        "URL", "URLSearchParams", "FormData", "Blob",
        // Node.js
        "Buffer", "process", "require", "module", "exports",
        "__dirname", "__filename",
        // Common utility
        "parseInt", "parseFloat", "isNaN", "isFinite",
        "encodeURIComponent", "decodeURIComponent", "atob", "btoa",
        // Iterators
        "Iterator", "Generator", "AsyncGenerator",
        // TS-specific
        "Partial", "Required", "Readonly", "Record",
        "Pick", "Omit", "Exclude", "Extract",
        "NonNullable", "ReturnType", "Parameters", "InstanceType",
        "Awaited", "ConstructorParameters"
    ]

    // Python stdlib
    private let pyStdlib: [String] = [
        // Built-in functions
        "print", "len", "range", "enumerate", "zip", "map", "filter",
        "sorted", "reversed", "list", "dict", "set", "tuple", "frozenset",
        "str", "int", "float", "bool", "bytes", "bytearray", "complex",
        "type", "isinstance", "issubclass", "super", "property",
        "staticmethod", "classmethod", "abs", "min", "max", "sum",
        "any", "all", "open", "input", "format", "repr", "hash",
        "id", "dir", "vars", "getattr", "setattr", "hasattr", "delattr",
        "iter", "next", "callable", "round", "pow", "divmod",
        "hex", "oct", "bin", "ord", "chr", "ascii",
        // Common modules
        "os", "sys", "json", "re", "math", "datetime", "pathlib",
        "collections", "itertools", "functools", "typing",
        "dataclasses", "enum", "abc", "copy", "io", "logging",
        "unittest", "pytest", "asyncio", "aiohttp",
        // Common types
        "Optional", "Union", "List", "Dict", "Tuple", "Set",
        "Any", "Callable", "TypeVar", "Generic", "Protocol",
        "dataclass", "field",
        // Exception types
        "Exception", "ValueError", "TypeError", "KeyError",
        "IndexError", "AttributeError", "RuntimeError", "IOError",
        "FileNotFoundError", "ImportError", "StopIteration"
    ]

    /// Language-aware stdlib lookup
    private var stdlibTopLevel: [String] {
        switch currentLanguageId {
        case "typescript", "javascript", "typescriptreact", "javascriptreact":
            return tsStdlib
        case "python":
            return pyStdlib
        default:
            return swiftStdlib
        }
    }

    /// Detect current language from filename
    private var currentLanguageId: String {
        Self.lspLanguageId(forFilename: currentFilename) ?? "swift"
    }

    private let memberCompletions: [String: [String]] = [
        // MARK: - Strings & Collections
        "String": [
            "count", "isEmpty", "startIndex", "endIndex",
            "uppercased()", "lowercased()",
            "hasPrefix(\"\")", "hasSuffix(\"\")",
            "contains(\"\")",
            "split(separator:)",
            "trimmingCharacters(in:)",
            "replacingOccurrences(of:with:)",
            "prefix(_:)", "suffix(_:)", "dropFirst()", "dropLast()"
        ],
        "Array": [
            "count", "isEmpty", "first", "last",
            "append(_:)", "insert(_:at:)",
            "removeLast()", "removeAll()",
            "map(_:)", "compactMap(_:)", "flatMap(_:)", "filter(_:)", "reduce(_:_:)",
            "forEach(_:)", "sorted()", "sorted(by:)"
        ],
        "Dictionary": [
            "count", "isEmpty", "keys", "values",
            "updateValue(_:forKey:)", "removeValue(forKey:)",
            "mapValues(_:)"
        ],
        "Set": [
            "count", "isEmpty",
            "insert(_:)", "remove(_:)", "contains(_:)",
            "union(_:)", "intersection(_:)", "subtracting(_:)"
        ],
        "Optional": [
            "map(_:)", "flatMap(_:)"
        ],
        "Result": [
            "get()", "map(_:)", "mapError(_:)"
        ],

        // MARK: - Numeric Types
        "Int": [
            "abs", "magnitude",
            "description", "isNaN",
            "advanced(by:)", "distance(to:)",
            "stride(to:)", "stride(through:)"
        ],
        "Double": [
            "isNaN", "isInfinite", "isFinite", "isZero",
            "abs", "magnitude", "sign",
            "squareRoot()", "rounded()", "rounded(_:)",
            "floor()", "ceil()", "trunc(_:)",
            "description",
            "advanced(by:)", "distance(to:)",
            "stride(to:)", "stride(through:)"
        ],
        "Bool": [
            "toggle()", "description"
        ],

        // MARK: - Foundation Types
        "URL": [
            "absoluteString", "absoluteURL", "scheme", "host", "port", "path",
            "query", "fragment", "baseURL",
            "isFileURL", "lastPathComponent",
            "deletingLastPathComponent()", "deletingPathExtension()",
            "appendingPathComponent(_:)", "appendingPathExtension(_:)",
            "appendingQueryItem(_:)"
        ],
        "Data": [
            "count", "isEmpty", "capacity",
            "map(_:)", "filter(_:)", "reduce(_:_:)",
            "base64EncodedString()", "base64EncodedData()",
            "append(_:)", "append(contentsOf:)"
        ],
        "Date": [
            "timeIntervalSince1970", "timeIntervalSinceNow", "timeIntervalSinceReferenceDate",
            "description",
            "addingTimeInterval(_:)",
            "formatted()", "formatted(date:time:)",
            "ISO8601Format()"
        ],

        // MARK: - Concurrency
        "Task": [
            "isCancelled", "cancel()", "value",
            "priority", "description"
        ],

        // MARK: - SwiftUI View Modifiers (common)
        "View": [
            // Layout
            "padding()", "padding(_:)", "padding(_:_:)",
            "frame(width:height:)", "frame(maxWidth:maxHeight:)", "frame(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:alignment:)",
            "fixedSize()", "fixedSize(horizontal:vertical:)",
            // Background & Overlay
            "background(_:)", "background(_:_:)",
            "overlay(_:)", "overlay(_:_:)",
            // Color & Style
            "foregroundColor(_:)", "foregroundStyle(_:)", "tint(_:)",
            "backgroundStyle(_1:)",
            // Borders & Shapes
            "clipShape(_:)", "cornerRadius(_1:)",
            "border(_:width:)", "shadow(color:radius:x:y:)",
            "mask(_:)",
            // Opacity & Visibility
            "opacity(_1:)", "hidden()", "disabled(_1:)",
            // Font & Text
            "font(_1:)", "fontWeight(_1:)", "fontDesign(_1:)",
            "lineLimit(_1:)", "lineSpacing(_1:)", "multilineTextAlignment(_1:)",
            "minimumScaleFactor(_1:)", "truncationMode(_1:)",
            "kerning(_1:)", "tracking(_1:)", "baselineOffset(_1:)",
            // Interaction
            "onTapGesture(count:perform:)", "onTapGesture(_1:)",
            "onLongPressGesture(minimumDuration:maximumDistance:perform:)",
            "gesture(_1:)", "highPriorityGesture(_1:)", "simultaneousGesture(_1:)",
            "onHover(perform:)",
            // Lifecycle
            "onAppear(perform:)", "onDisappear(perform:)",
            "task(id:priority:_1:)",
            // Sheets & Alerts
            "sheet(isPresented:onDismiss:content:)", "sheet(item:onDismiss:content:)",
            "fullScreenCover(isPresented:onDismiss:content:)", "fullScreenCover(item:onDismiss:content:)",
            "alert(_1:isPresented:actions:)", "alert(_1:isPresented:presenting:actions:)",
            "confirmationDialog(_1:isPresented:titleVisibility:actions:)",
            // Navigation
            "navigationTitle(_1:)", "navigationBarTitleDisplayMode(_1:)",
            "toolbar(_1:)", "toolbarBackground(_1:for:)", "toolbarColorScheme(_1:for:)",
            "navigationDestination(for:destination:)",
            // Environment
            "environment(_1:)", "environmentObject(_1:)",
            "preferredColorScheme(_1:)",
            // Conditional modifiers
            "id(_1:)", "tag(_1:)",
            "transition(_1:)", "animation(_1:)", "animation(_1:value:)",
            // Transforms
            "rotationEffect(_1:)", "scaleEffect(_1:)", "offset(x:y:)", "offset(_1:)",
            "position(_1:)", "zIndex(_1:)",
            // Drawing
            "drawingGroup()", "coordinateSpace(_1:)", "transformEffect(_1:)",
            // Scrolling
            "scrollDismissesKeyboard(_1:)",
            // Reactive
            "onReceive(_1:perform:)", "onChange(of:initial:_1:)",
            "allowsHitTesting(_1:)",
            // Accessibility
            "accessibilityLabel(_1:)", "accessibilityHint(_1:)", "accessibilityValue(_1:)",
            "accessibilityHidden(_1:)", "accessibilityElement(children:)",
            "accessibilityAddTraits(_1:)", "accessibilityRemoveTraits(_1:)"
        ],
        "Text": [
            // Font & Style
            "font(_1:)", "fontWeight(_1:)", "bold()", "italic()",
            "underline()", "underline(_1:color:)",
            "strikethrough()", "strikethrough(_1:color:)",
            "monospaced()", "monospacedDigit()",
            "baselineOffset(_1:)", "kerning(_1:)", "tracking(_1:)", "textCase(_1:)",
            // Color & Background
            "foregroundColor(_1:)", "foregroundStyle(_1:)", "tint(_1:)",
            "background(_1:_:)",
            // Text Specific
            "multilineTextAlignment(_1:)", "lineLimit(_1:)", "lineSpacing(_1:)",
            "minimumScaleFactor(_1:)", "allowsTightening(_1:)", "truncationMode(_1:)",
            "fixedSize()", "scaleEffect(_1:)",
            // Interaction
            "onTapGesture(count:perform:)",
            // Layout
            "padding()", "padding(_1:)", "padding(_1:_1:)",
            "frame(width:height:)", "frame(maxWidth:maxHeight:)"
        ],
        "NavigationStack": [
            "navigationTitle(_1:)",
            "navigationBarTitleDisplayMode(_1:)",
            "toolbar(_1:)", "toolbarBackground(_1:for:)", "toolbarColorScheme(_1:for:)",
            "navigationDestination(for:destination:)",
            "preferredColorScheme(_1:)"
        ]
    ]

    // MARK: - Public API

    /// Updates suggestions based on the current text and cursor.
    ///
    /// FEAT-046: extracts symbols from `text` and mixes them into the suggestion list.
    /// FEAT-047: adds a curated set of Swift stdlib completions.
    /// LSP completions are requested asynchronously in parallel.
    func updateSuggestions(for text: String, cursorPosition: Int) {
        // Fire off LSP completions asynchronously (non-blocking).
        // Must happen before any early returns so LSP always fires when connected.
        let lspURI = currentFileURI
        let lspFilename = currentFilename
        if !lspURI.isEmpty, let lspLangId = Self.lspLanguageId(forFilename: lspFilename) {
            requestLSPCompletions(uri: lspURI, languageId: lspLangId, text: text, cursorOffset: cursorPosition)
        }

        let safeCursor = max(0, min(cursorPosition, text.count))
        guard let context = completionContext(in: text, cursorPosition: safeCursor) else {
            apply(items: [])
            return
        }

        let prefixLower = context.prefix.lowercased()
        guard !prefixLower.isEmpty else {
            // If user just typed a dot, show members even with empty prefix.
            if context.isMemberCompletion, let base = context.memberBase {
                let members = memberCandidates(forBase: base)
                let items = members.map { Suggestion(kind: .member, displayText: $0, score: 1000) }
                apply(items: items)
            } else {
                apply(items: [])
            }
            return
        }

        var candidates: [Suggestion] = []

        // FEAT-046: current file symbols
        let symbols = extractSymbols(from: text)
        candidates.append(contentsOf: symbols
            .compactMap { sym -> Suggestion? in
                guard let fuzzyScore = FuzzyMatcher.score(query: context.prefix, target: sym) else { return nil }
                return Suggestion(kind: .symbol, displayText: sym, score: 900 + fuzzyScore / 10)
            })

        // Keywords
        candidates.append(contentsOf: keywords
            .compactMap { kw -> Suggestion? in
                guard let fuzzyScore = FuzzyMatcher.score(query: context.prefix, target: kw) else { return nil }
                return Suggestion(kind: .keyword, displayText: kw, score: 800 + fuzzyScore / 10)
            })

        // FEAT-047: Swift stdlib (top level)
        candidates.append(contentsOf: stdlibTopLevel
            .compactMap { item -> Suggestion? in
                guard let fuzzyScore = FuzzyMatcher.score(query: context.prefix, target: item) else { return nil }
                return Suggestion(kind: .stdlib, displayText: item, score: 700 + fuzzyScore / 10)
            })

        // Member completions (very small heuristic-based set)
        if context.isMemberCompletion, let base = context.memberBase {
            let members = memberCandidates(forBase: base)
            candidates.append(contentsOf: members
                .compactMap { m -> Suggestion? in
                    guard let fuzzyScore = FuzzyMatcher.score(query: context.prefix, target: m) else { return nil }
                    return Suggestion(kind: .member, displayText: m, score: 1000 + fuzzyScore / 10)
                })
        }

        // Snippet completions — language detection done inline to avoid @MainActor crossing
        let snippetLang = Self.snippetLanguage(forFilename: currentFilename)
        if let lang = snippetLang {
            let snippetMatches = Self.builtinSnippetTriggers[lang, default: []]
            candidates.append(contentsOf: snippetMatches.compactMap { (trigger, name, desc) -> Suggestion? in
                guard let fuzzyScore = FuzzyMatcher.score(query: context.prefix, target: trigger) else { return nil }
                return Suggestion(kind: .snippet, displayText: "\(trigger) — \(desc)",
                                  insertText: trigger, score: 950 + fuzzyScore / 10)
            })
        }

        // De-dupe + rank
        let merged = mergeAndSort(candidates)
        apply(items: merged)
    }

    func selectNext() {
        guard showSuggestions else { return }
        if selectedIndex < suggestions.count - 1 {
            selectedIndex += 1
        }
    }

    func selectPrevious() {
        guard showSuggestions else { return }
        if selectedIndex > 0 {
            selectedIndex -= 1
        }
    }

    func getCurrentSuggestion() -> String? {
        guard showSuggestions, selectedIndex < suggestions.count else { return nil }
        return suggestions[selectedIndex]
    }

    func hideSuggestions() {
        apply(items: [])
    }

    /// Optional helper for inserting the currently-selected suggestion into the text.
    /// (Not wired by default; added as plumbing for FEAT-045 dropdown selection.)
    func commitCurrentSuggestion(into text: inout String, cursorPosition: inout Int) {
        guard let suggestion = suggestionItems[safe: selectedIndex], showSuggestions else { return }
        let safeCursor = max(0, min(cursorPosition, text.count))
        guard let context = completionContext(in: text, cursorPosition: safeCursor) else { return }

        let replacementRange = context.replacementRange
        let insertionOffset = text.distance(from: text.startIndex, to: replacementRange.lowerBound)

        // Snippet suggestions: expand body with tab-stop placeholders and begin session
        if suggestion.kind == .snippet {
            let lang = Self.snippetLanguage(forFilename: currentFilename) ?? "swift"
            if let snippet = SnippetManager.shared.snippet(forTrigger: suggestion.insertText, language: lang) {
                let (expandedText, tabStops) = SnippetManager.shared.expand(snippet)
                text.replaceSubrange(replacementRange, with: expandedText)
                // Activate tab-stop navigation so Tab key advances through $1, $2, …
                SnippetManager.shared.beginTabStopSession(snippet: snippet, insertedAt: insertionOffset)
                // Position cursor at the first tab stop ($1) without advancing the session
                if let firstStop = tabStops.first {
                    cursorPosition = min(insertionOffset + firstStop.offset, text.count)
                } else {
                    cursorPosition = min(insertionOffset + expandedText.count, text.count)
                }
                hideSuggestions()
                return
            }
        }

        text.replaceSubrange(replacementRange, with: suggestion.insertText)
        cursorPosition = min(insertionOffset + suggestion.insertText.count, text.count)

        hideSuggestions()
    }

    // MARK: - Internals

    private struct CompletionContext {
        let prefix: String
        let replacementRange: Range<String.Index>
        let isMemberCompletion: Bool
        let memberBase: String?
    }

    private func completionContext(in text: String, cursorPosition: Int) -> CompletionContext? {
        guard !text.isEmpty else { return nil }
        
        // Safety check: ensure cursorPosition is within bounds
        let safeCursor = max(0, min(cursorPosition, text.count))
        let cursorIndex = text.index(text.startIndex, offsetBy: safeCursor)

        // Find start of current identifier (letters/digits/_).
        var start = cursorIndex
        while start > text.startIndex {
            let prev = text.index(before: start)
            if isIdentifierChar(text[prev]) {
                start = prev
            } else {
                break
            }
        }

        let prefix = String(text[start..<cursorIndex])

        // Member completion if immediately preceded by '.'
        var isMember = false
        var memberBase: String? = nil

        if start > text.startIndex {
            let dotIndex = text.index(before: start)
            if text[dotIndex] == "." {
                isMember = true

                // Parse identifier before '.'
                let baseEnd = dotIndex
                var baseStart = baseEnd
                while baseStart > text.startIndex {
                    let prev = text.index(before: baseStart)
                    if isIdentifierChar(text[prev]) {
                        baseStart = prev
                    } else {
                        break
                    }
                }
                let base = String(text[baseStart..<baseEnd])
                if !base.isEmpty {
                    memberBase = base
                }
            }
        }

        return CompletionContext(prefix: prefix,
                                 replacementRange: start..<cursorIndex,
                                 isMemberCompletion: isMember,
                                 memberBase: memberBase)
    }

    private func isIdentifierChar(_ c: Character) -> Bool {
        // Swift identifiers are more complex, but this is enough for basic autocomplete.
        return c.isLetter || c.isNumber || c == "_"
    }

    private func memberCandidates(forBase base: String) -> [String] {
        // Basic heuristic: only match known stdlib types by exact name.
        if let members = memberCompletions[base] { return members }
        return []
    }

    private func extractSymbols(from text: String) -> [String] {
        // Multi-language symbol extraction: detects declarations for the current language.
        var results = Set<String>()

        func addMatches(pattern: String) {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
            let ns = text as NSString
            let range = NSRange(location: 0, length: ns.length)
            regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match, match.numberOfRanges >= 2 else { return }
                let nameRange = match.range(at: 1)
                guard nameRange.location != NSNotFound else { return }
                let name = ns.substring(with: nameRange)
                if !name.isEmpty { results.insert(name) }
            }
        }

        switch currentLanguageId {
        case "typescript", "javascript", "typescriptreact", "javascriptreact":
            // function declarations
            addMatches(pattern: "\\b(?:async\\s+)?function\\s*\\*?\\s+([A-Za-z_$][A-Za-z0-9_$]*)")
            // arrow functions assigned to const/let/var
            addMatches(pattern: "\\b(?:const|let|var)\\s+([A-Za-z_$][A-Za-z0-9_$]*)\\s*=\\s*(?:async\\s+)?(?:\\([^)]*\\)|[A-Za-z_$])\\s*=>")
            // class/interface/type/enum
            addMatches(pattern: "\\b(?:class|interface|type|enum)\\s+([A-Za-z_$][A-Za-z0-9_$]*)")
            // const/let/var declarations
            addMatches(pattern: "\\b(?:const|let|var)\\s+([A-Za-z_$][A-Za-z0-9_$]*)\\s*[=:]")
            // export declarations
            addMatches(pattern: "\\bexport\\s+(?:default\\s+)?(?:class|interface|type|enum|function|const|let|var)\\s+([A-Za-z_$][A-Za-z0-9_$]*)")

        case "python":
            // def function
            addMatches(pattern: "\\b(?:async\\s+)?def\\s+([A-Za-z_][A-Za-z0-9_]*)")
            // class
            addMatches(pattern: "\\bclass\\s+([A-Za-z_][A-Za-z0-9_]*)")
            // top-level assignments (UPPER_CASE = constants)
            addMatches(pattern: "^([A-Z][A-Z0-9_]*)\\s*=")
            // regular variable assignments at module level
            addMatches(pattern: "^([A-Za-z_][A-Za-z0-9_]*)\\s*[=:]")

        default:
            // Swift: func Foo
            addMatches(pattern: "\\bfunc\\s+([A-Za-z_][A-Za-z0-9_]*)")
            // class/struct/enum/protocol/typealias Foo
            addMatches(pattern: "\\b(?:class|struct|enum|protocol|typealias)\\s+([A-Za-z_][A-Za-z0-9_]*)")
            // let/var foo (captures first name before : = , )
            addMatches(pattern: "\\b(?:let|var)\\s+([A-Za-z_][A-Za-z0-9_]*)(?=\\s*[:=,])")
        }

        return results.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private func mergeAndSort(_ items: [Suggestion]) -> [Suggestion] {
        // Keep highest-scored entry per id.
        var bestById: [String: Suggestion] = [:]
        for item in items {
            if let existing = bestById[item.id] {
                if item.score > existing.score {
                    bestById[item.id] = item
                }
            } else {
                bestById[item.id] = item
            }
        }

        return bestById.values.sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            return $0.displayText.localizedCaseInsensitiveCompare($1.displayText) == .orderedAscending
        }
    }

    private func apply(items: [Suggestion]) {
        suggestionItems = items
        suggestions = items.map { $0.displayText }
        showSuggestions = !items.isEmpty
        selectedIndex = 0
    }

    // MARK: - LSP Integration

    /// Maps file extensions to LSP language identifiers.
    /// Covers Swift, TypeScript, Python, JavaScript, and other common languages.
    static func lspLanguageId(forFilename filename: String) -> String? {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "swift":                     return "swift"
        case "js":                        return "javascript"
        case "jsx":                       return "javascriptreact"
        case "mjs", "cjs":               return "javascript"
        case "ts":                        return "typescript"
        case "tsx":                       return "typescriptreact"
        case "py", "pyw":                return "python"
        case "c":                         return "c"
        case "cpp", "cc", "cxx":         return "cpp"
        case "h":                         return "c"
        case "hpp", "hxx":               return "cpp"
        case "go":                        return "go"
        case "rs":                        return "rust"
        case "rb":                        return "ruby"
        case "java":                      return "java"
        case "kt", "kts":                return "kotlin"
        case "json":                      return "json"
        case "html", "htm":              return "html"
        case "css", "scss":              return "css"
        default:                           return nil
        }
    }

    /// Tracks which documents have been opened with the LSP server (uri -> version).
    private var lspDocumentVersions: [String: Int] = [:]

    /// The currently in-flight LSP completion request (cancelled on each keystroke).
    private var lspCompletionTask: Task<Void, Never>?

    /// Converts a cursor offset into LSP (line, character) coordinates.
    private func lspPosition(in text: String, cursorOffset: Int) -> (line: Int, character: Int) {
        let safeOffset = min(max(0, cursorOffset), text.count)
        let cursorIdx = text.index(text.startIndex, offsetBy: safeOffset)

        let preceding = text[text.startIndex..<cursorIdx]
        let lineNumber = preceding.filter { $0 == "\n" }.count

        let lastNewline = preceding.lastIndex(of: "\n")
        let charOffset: Int
        if let lastNL = lastNewline {
            charOffset = preceding.distance(from: preceding.index(after: lastNL), to: cursorIdx)
        } else {
            charOffset = preceding.distance(from: preceding.startIndex, to: cursorIdx)
        }
        return (lineNumber, charOffset)
    }

    /// Requests completions from the remote LSP server and merges them with
    /// any already-displayed local suggestions.  LSP results arrive
    /// asynchronously and replace/extend the current list.
    func requestLSPCompletions(
        uri: String,
        languageId: String,
        text: String,
        cursorOffset: Int
    ) {
        // Cancel any previous in-flight request so we only keep the latest.
        lspCompletionTask?.cancel()
        lspCompletionTask = Task { @MainActor in
            let proxy = TunnelLSPProxy.shared
            guard proxy.isInitialized,
                  proxy.activeLSPServers.contains(languageId) else { return }

            let (line, character) = lspPosition(in: text, cursorOffset: cursorOffset)
            let position = LSPPosition(line: line, character: character)

            do {
                let items = try await proxy.completion(
                    uri: uri,
                    position: position,
                    languageId: languageId
                )

                // Guard against cancellation after the await.
                guard !Task.isCancelled else { return }

                // Map LSP items → Suggestion with high scores so they sort above local results.
                let lspSuggestions: [Suggestion] = items.map { item in
                    let displayText: String
                    if let detail = item.detail, !detail.isEmpty {
                        displayText = "\(item.label)  \(detail)"
                    } else {
                        displayText = item.label
                    }
                    let insertText = item.insertText ?? item.label
                    let score: Int
                    if item.preselect == true {
                        score = 1200
                    } else if let sortText = item.sortText, let sortVal = Int(sortText) {
                        score = min(1199, 1100 + sortVal)
                    } else {
                        score = 1150
                    }
                    return Suggestion(kind: .lsp, displayText: displayText,
                                      insertText: insertText, score: score)
                }

                // Merge with whatever local suggestions are currently displayed.
                let existing = self.suggestionItems
                let merged = self.mergeAndSort(existing + lspSuggestions)
                self.apply(items: merged)
            } catch {
                // LSP request failed — local suggestions remain visible, nothing to do.
            }
        }
    }

    /// Sends `textDocument/didOpen` or `textDocument/didChange` to the LSP
    /// server so that it stays in sync with the editor buffer.
    ///
    /// ContentView should call this on every text change and on tab switch.
    func notifyLSPDocumentChange(uri: String, languageId: String, text: String, version: Int) {
        Task { @MainActor in
            let proxy = TunnelLSPProxy.shared
            guard proxy.isInitialized,
                  proxy.activeLSPServers.contains(languageId) else { return }

            let wasOpen = lspDocumentVersions[uri] != nil
            lspDocumentVersions[uri] = version

            if wasOpen {
                // Full-sync didChange
                let change = LSPTextDocumentContentChange(range: nil, rangeLength: nil, text: text)
                proxy.didChange(uri: uri, languageId: languageId, version: version, changes: [change])
            } else {
                // First time → didOpen
                proxy.didOpen(uri: uri, languageId: languageId, version: version, text: text)
            }
        }
    }
}

// MARK: - Snippet Support (nonisolated)

extension AutocompleteManager {
    /// Language detection for snippets (nonisolated — no @MainActor dependency)
    static func snippetLanguage(forFilename filename: String) -> String? {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "swift":                    return "swift"
        case "js", "jsx", "mjs", "cjs": return "javascript"
        case "ts", "tsx":               return "typescript"
        case "py", "pyw":               return "python"
        case "html", "htm":             return "html"
        case "css", "scss":             return "css"
        default:                        return nil
        }
    }

    /// Static lookup of built-in snippet triggers per language.
    /// Avoids accessing @MainActor SnippetManager during autocomplete.
    static let builtinSnippetTriggers: [String: [(trigger: String, name: String, desc: String)]] = {
        // Mirror SnippetManager's built-in snippets as lightweight tuples
        return [
            "swift": [
                ("func", "Function", "Define a function"),
                ("functhrows", "Throwing Function", "Throwing function"),
                ("funcasync", "Async Function", "Async function"),
                ("guardlet", "Guard Let", "guard let binding"),
                ("iflet", "If Let", "if let binding"),
                ("switch", "Switch", "switch statement"),
                ("struct", "Struct", "Define a struct"),
                ("class", "Class", "Define a class"),
                ("enum", "Enum", "Define an enum"),
                ("protocol", "Protocol", "Define a protocol"),
                ("extension", "Extension", "Define an extension"),
                ("init", "Init", "Initializer"),
                ("do", "do-catch", "do-catch error handling"),
                ("task", "Task", "Concurrency Task"),
                ("actor", "Actor", "Define an actor"),
                ("mark", "MARK", "MARK comment"),
                ("todo", "TODO", "TODO comment"),
                ("print", "print", "print to console"),
            ],
            "javascript": [
                ("function", "Function", "Named function"),
                ("arrow", "Arrow Function", "Arrow function"),
                ("const", "const", "const declaration"),
                ("let", "let", "let declaration"),
                ("if", "if", "if statement"),
                ("ifelse", "if-else", "if-else statement"),
                ("for", "for", "for loop"),
                ("forof", "for-of", "for-of loop"),
                ("forEach", "forEach", "Array forEach"),
                ("class", "Class", "Class declaration"),
                ("import", "import", "Named import"),
                ("async", "Async Function", "Async function"),
                ("try", "try-catch", "try-catch block"),
                ("log", "console.log", "console.log"),
                ("promise", "Promise", "new Promise"),
                ("switch", "switch", "switch statement"),
            ],
            "typescript": [
                ("function", "Function", "Named function"),
                ("arrow", "Arrow Function", "Arrow function"),
                ("const", "const", "const declaration"),
                ("interface", "Interface", "Interface declaration"),
                ("type", "Type Alias", "Type alias"),
                ("class", "Class", "Class declaration"),
                ("import", "import", "Named import"),
                ("async", "Async Function", "Async function"),
                ("try", "try-catch", "try-catch block"),
                ("log", "console.log", "console.log"),
            ],
            "python": [
                ("def", "Function", "Define a function"),
                ("class", "Class", "Define a class"),
                ("if", "if", "if statement"),
                ("for", "for", "for loop"),
                ("while", "while", "while loop"),
                ("try", "try-except", "try-except block"),
                ("with", "with", "with statement"),
                ("import", "import", "import module"),
                ("main", "main", "if __name__ == __main__"),
                ("print", "print", "print to console"),
            ],
            "html": [
                ("html", "HTML5", "HTML5 boilerplate"),
                ("div", "div", "div element"),
                ("link", "link", "link stylesheet"),
                ("script", "script", "script tag"),
                ("img", "img", "image element"),
                ("a", "anchor", "anchor link"),
            ],
            "css": [
                ("flex", "Flexbox", "Flexbox container"),
                ("grid", "Grid", "Grid container"),
                ("media", "Media Query", "Media query"),
            ],
        ]
    }()
}

// MARK: - Safe Array Access
