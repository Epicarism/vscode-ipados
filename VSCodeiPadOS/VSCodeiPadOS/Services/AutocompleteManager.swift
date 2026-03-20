import SwiftUI
import Foundation

// Type aliases for external use
typealias AutocompleteSuggestion = AutocompleteManager.Suggestion
typealias AutocompleteSuggestionKind = AutocompleteManager.SuggestionKind

/// FEAT-045/046/047
/// - Basic autocomplete dropdown state (showSuggestions/selectedIndex)
/// - Current file symbol extraction
/// - Swift stdlib completions (top-level + a small set of member completions)
final class AutocompleteManager: ObservableObject {

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

    private let keywords: [String] = [
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

    private let stdlibTopLevel: [String] = [
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
    func updateSuggestions(for text: String, cursorPosition: Int) {
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
        text.replaceSubrange(replacementRange, with: suggestion.insertText)

        // Move cursor to end of inserted text.
        let newCursorOffset = text.distance(from: text.startIndex, to: replacementRange.lowerBound) + suggestion.insertText.count
        cursorPosition = min(newCursorOffset, text.count)

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
        // Very lightweight symbol extraction: looks for common declarations.
        // Intentionally best-effort; keeps FEAT-046 self-contained.
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

        // func Foo
        addMatches(pattern: "\\bfunc\\s+([A-Za-z_][A-Za-z0-9_]*)")
        // class/struct/enum/protocol/typealias Foo
        addMatches(pattern: "\\b(?:class|struct|enum|protocol|typealias)\\s+([A-Za-z_][A-Za-z0-9_]*)")
        // let/var foo (captures first name before : = , )
        addMatches(pattern: "\\b(?:let|var)\\s+([A-Za-z_][A-Za-z0-9_]*)(?=\\s*[:=,])")

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
}

// MARK: - Safe Array Access
