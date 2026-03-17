// SnippetManager.swift
// VSCodeiPadOS
//
// Comprehensive code snippet manager with tab-stop navigation.
// Built-in snippets for Swift, JavaScript/TypeScript, Python, HTML, CSS.
//
// INTEGRATION NOTES:
// 1. AutocompleteManager.swift: Add `case snippet` to SuggestionKind enum.
//    In updateSuggestions(for:cursorPosition:), after other candidates:
//      if let lang = currentLanguage?.rawValue {
//          let hits = SnippetManager.shared.autocompleteSuggestions(
//              matchingPrefix: prefixLower, language: lang)
//          candidates.append(contentsOf: hits.map {
//              Suggestion(kind: .snippet, displayText: $0.displayText,
//                         insertText: $0.trigger, score: 950)
//          })
//      }
//
// 2. RunestoneEditorView.Coordinator - shouldChangeTextIn (Tab key):
//    if text == "	", SnippetManager.shared.hasActiveSession {
//        if let range = SnippetManager.shared.advanceTabStop() {
//            textView.selectedRange = range
//            textView.scrollRangeToVisible(range)
//            return false
//        }
//    }
//
// 3. After inserting expanded snippet text at cursor:
//    SnippetManager.shared.beginTabStopSession(snippet:insertedAt:)
//
// 4. SnippetPickerView bridge:
//    SnippetManager.shared.asLegacySnippets(for:) -> [Snippet]

import Foundation

// MARK: - CodeSnippet

/// A rich snippet with VSCode-compatible tab stops ($1, $2, ..., $0).
///
/// Tab stop conventions:
///   $1, $2  Visited ascending on Tab. $0 = final cursor position.
///   ${1:x}  Tab stop with default placeholder text.
struct CodeSnippet: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var trigger: String
    var body: String
    var language: String
    var description: String
    var name: String

    init(
        id: UUID = UUID(),
        trigger: String,
        body: String,
        language: String,
        description: String,
        name: String? = nil
    ) {
        self.id = id
        self.trigger = trigger
        self.body = body
        self.language = language
        self.description = description
        self.name = name ?? (String(trigger.prefix(1)).uppercased() + String(trigger.dropFirst()))
    }

    /// Converts to legacy Snippet type used by SnippetsManager / SnippetPickerView.
    var asSnippet: Snippet {
        Snippet(name: name, prefix: trigger, body: body, description: description)
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - TabStopSession

/// Tracks active tab-stop navigation for one snippet insertion.
final class TabStopSession {
    struct TabStop {
        let number: Int   // 1-based; $0 sorted last
        let offset: Int   // offset in expanded (marker-free) text
        let length: Int   // 0 when no ${N:placeholder}
    }

    private let tabStops: [TabStop]
    private(set) var currentIndex: Int = 0
    let insertionOffset: Int

    init(tabStops: [TabStop], insertionOffset: Int) {
        self.tabStops = tabStops
        self.insertionOffset = insertionOffset
    }

    var isFinished: Bool { currentIndex >= tabStops.count }

    /// Returns the absolute NSRange for the current stop and advances the index.
    func nextTabStop() -> NSRange? {
        guard currentIndex < tabStops.count else { return nil }
        let stop = tabStops[currentIndex]
        currentIndex += 1
        return NSRange(location: insertionOffset + stop.offset, length: stop.length)
    }

    func reset() { currentIndex = 0 }
}

// MARK: - SnippetManager

/// Central manager for built-in snippets and active tab-stop session.
/// Complements SnippetsManager (user-created custom snippets).
@MainActor final class SnippetManager: ObservableObject {

    static let shared = SnippetManager()
    private init() {}

    // MARK: Active Tab-Stop Session

    @Published private(set) var activeSession: TabStopSession?
    var hasActiveSession: Bool { activeSession != nil }

    // MARK: - Built-in Snippets

    // Swift
    let swiftSnippets: [CodeSnippet] = [
        CodeSnippet(trigger: "func", body: "func $1($2) {\n    $3\n}", language: "swift", description: "Define a function", name: "Function"),
        CodeSnippet(trigger: "functhrows", body: "func $1($2) throws -> $3 {\n    $4\n}", language: "swift", description: "Throwing function", name: "Throwing Function"),
        CodeSnippet(trigger: "funcasync", body: "func $1($2) async -> $3 {\n    $4\n}", language: "swift", description: "Async function", name: "Async Function"),
        CodeSnippet(trigger: "guardlet", body: "guard let $1 = $2 else {\n    $3\n}", language: "swift", description: "guard let binding", name: "Guard Let"),
        CodeSnippet(trigger: "iflet", body: "if let $1 = $2 {\n    $3\n}", language: "swift", description: "if let binding", name: "If Let"),
        CodeSnippet(trigger: "switch", body: "switch $1 {\ncase $2:\n    $3\ndefault:\n    $4\n}", language: "swift", description: "switch statement", name: "Switch"),
        CodeSnippet(trigger: "struct", body: "struct $1 {\n    $2\n}", language: "swift", description: "Define a struct", name: "Struct"),
        CodeSnippet(trigger: "class", body: "class $1 {\n    $2\n}", language: "swift", description: "Define a class", name: "Class"),
        CodeSnippet(trigger: "enum", body: "enum $1 {\n    case $2\n}", language: "swift", description: "Define an enum", name: "Enum"),
        CodeSnippet(trigger: "protocol", body: "protocol $1 {\n    $2\n}", language: "swift", description: "Define a protocol", name: "Protocol"),
        CodeSnippet(trigger: "extension", body: "extension $1 {\n    $2\n}", language: "swift", description: "Define an extension", name: "Extension"),
        CodeSnippet(trigger: "init", body: "init($1) {\n    $2\n}", language: "swift", description: "Initializer", name: "Init"),
        CodeSnippet(trigger: "forEach", body: "$1.forEach { $2 in\n    $3\n}", language: "swift", description: "forEach loop", name: "forEach"),
        CodeSnippet(trigger: "map", body: "let $1 = $2.map { $3 in\n    $4\n}", language: "swift", description: "map transform", name: "map"),
        CodeSnippet(trigger: "compactMap", body: "let $1 = $2.compactMap { $3 in\n    $4\n}", language: "swift", description: "compactMap transform", name: "compactMap"),
        CodeSnippet(trigger: "filter", body: "let $1 = $2.filter { $3 in\n    $4\n}", language: "swift", description: "filter collection", name: "filter"),
        CodeSnippet(trigger: "do", body: "do {\n    $1\n} catch {\n    $2\n}", language: "swift", description: "do-catch error handling", name: "do-catch"),
        CodeSnippet(trigger: "task", body: "Task {\n    $1\n}", language: "swift", description: "Concurrency Task", name: "Task"),
        CodeSnippet(trigger: "actor", body: "actor $1 {\n    $2\n}", language: "swift", description: "Define an actor", name: "Actor"),
        CodeSnippet(trigger: "mark", body: "// MARK: - $1", language: "swift", description: "MARK comment", name: "MARK"),
        CodeSnippet(trigger: "todo", body: "// TODO: $1", language: "swift", description: "TODO comment", name: "TODO"),
        CodeSnippet(trigger: "print", body: "print(\"$1\")", language: "swift", description: "print to console", name: "print"),
        CodeSnippet(trigger: "computed", body: "var $1: $2 {\n    $3\n}", language: "swift", description: "Computed property", name: "Computed Property"),
    ]

    // JavaScript / TypeScript
    let javascriptSnippets: [CodeSnippet] = [
        CodeSnippet(trigger: "function", body: "function $1($2) {\n    $3\n}", language: "javascript", description: "Named function", name: "Function"),
        CodeSnippet(trigger: "arrow", body: "const $1 = ($2) => {\n    $3\n}", language: "javascript", description: "Arrow function", name: "Arrow Function"),
        CodeSnippet(trigger: "const", body: "const $1 = $2", language: "javascript", description: "const declaration", name: "const"),
        CodeSnippet(trigger: "let", body: "let $1 = $2", language: "javascript", description: "let declaration", name: "let"),
        CodeSnippet(trigger: "if", body: "if ($1) {\n    $2\n}", language: "javascript", description: "if statement", name: "if"),
        CodeSnippet(trigger: "ifelse", body: "if ($1) {\n    $2\n} else {\n    $3\n}", language: "javascript", description: "if-else statement", name: "if-else"),
        CodeSnippet(trigger: "for", body: "for (let $1 = 0; $1 < $2; $1++) {\n    $3\n}", language: "javascript", description: "for loop", name: "for"),
        CodeSnippet(trigger: "forof", body: "for (const $1 of $2) {\n    $3\n}", language: "javascript", description: "for-of loop", name: "for-of"),
        CodeSnippet(trigger: "forEach", body: "$1.forEach(($2) => {\n    $3\n})", language: "javascript", description: "Array forEach", name: "forEach"),
        CodeSnippet(trigger: "map", body: "const $1 = $2.map(($3) => {\n    return $4\n})", language: "javascript", description: "Array map", name: "map"),
        CodeSnippet(trigger: "filter", body: "const $1 = $2.filter(($3) => {\n    return $4\n})", language: "javascript", description: "Array filter", name: "filter"),
        CodeSnippet(trigger: "class", body: "class $1 {\n    constructor($2) {\n        $3\n    }\n\n    $4\n}", language: "javascript", description: "Class declaration", name: "Class"),
        CodeSnippet(trigger: "import", body: "import { $1 } from '$2'", language: "javascript", description: "Named import", name: "import"),
        CodeSnippet(trigger: "importdefault", body: "import $1 from '$2'", language: "javascript", description: "Default import", name: "Default Import"),
        CodeSnippet(trigger: "export", body: "export { $1 }", language: "javascript", description: "Named export", name: "export"),
        CodeSnippet(trigger: "exportdefault", body: "export default $1", language: "javascript", description: "Default export", name: "Default Export"),
        CodeSnippet(trigger: "async", body: "async function $1($2) {\n    $3\n}", language: "javascript", description: "Async function", name: "Async Function"),
        CodeSnippet(trigger: "await", body: "const $1 = await $2", language: "javascript", description: "await expression", name: "await"),
        CodeSnippet(trigger: "try", body: "try {\n    $1\n} catch ($2) {\n    $3\n}", language: "javascript", description: "try-catch block", name: "try-catch"),
        CodeSnippet(trigger: "log", body: "console.log($1)", language: "javascript", description: "console.log", name: "console.log"),
        CodeSnippet(trigger: "logjson", body: "console.log(JSON.stringify($1, null, 2))", language: "javascript", description: "Pretty JSON log", name: "console.log JSON"),
        CodeSnippet(trigger: "promise", body: "new Promise(($1resolve, $2reject) => {\n    $3\n})", language: "javascript", description: "new Promise", name: "Promise"),
        CodeSnippet(trigger: "switch", body: "switch ($1) {\n    case $2:\n        $3\n        break\n    default:\n        $4\n}", language: "javascript", description: "switch statement", name: "switch"),
        CodeSnippet(trigger: "settimeout", body: "setTimeout(() => {\n    $1\n}, $2)", language: "javascript", description: "setTimeout", name: "setTimeout"),
        CodeSnippet(trigger: "setinterval", body: "setInterval(() => {\n    $1\n}, $2)", language: "javascript", description: "setInterval", name: "setInterval"),
    ]

    // Python
    let pythonSnippets: [CodeSnippet] = [
        CodeSnippet(trigger: "def", body: "def $1($2):\n    $3", language: "python", description: "Define a function", name: "def"),
        CodeSnippet(trigger: "deftyped", body: "def $1($2) -> $3:\n    $4", language: "python", description: "Typed function", name: "def (typed)"),
        CodeSnippet(trigger: "asyncdef", body: "async def $1($2):\n    $3", language: "python", description: "Async function", name: "async def"),
        CodeSnippet(trigger: "class", body: "class $1:\n    def __init__(self$2):\n        $3", language: "python", description: "Class definition", name: "class"),
        CodeSnippet(trigger: "classinherit", body: "class $1($2):\n    def __init__(self$3):\n        super().__init__($4)\n        $5", language: "python", description: "Class with inheritance", name: "class (inherit)"),
        CodeSnippet(trigger: "if", body: "if $1:\n    $2", language: "python", description: "if statement", name: "if"),
        CodeSnippet(trigger: "ifelse", body: "if $1:\n    $2\nelse:\n    $3", language: "python", description: "if-else statement", name: "if-else"),
        CodeSnippet(trigger: "for", body: "for $1 in $2:\n    $3", language: "python", description: "for loop", name: "for"),
        CodeSnippet(trigger: "forrange", body: "for $1 in range($2):\n    $3", language: "python", description: "for range loop", name: "for range"),
        CodeSnippet(trigger: "while", body: "while $1:\n    $2", language: "python", description: "while loop", name: "while"),
        CodeSnippet(trigger: "with", body: "with $1 as $2:\n    $3", language: "python", description: "with context manager", name: "with"),
        CodeSnippet(trigger: "try", body: "try:\n    $1\nexcept $2 as $3:\n    $4", language: "python", description: "try-except block", name: "try-except"),
        CodeSnippet(trigger: "tryfinally", body: "try:\n    $1\nexcept $2 as $3:\n    $4\nfinally:\n    $5", language: "python", description: "try-except-finally", name: "try-except-finally"),
        CodeSnippet(trigger: "import", body: "import $1", language: "python", description: "import statement", name: "import"),
        CodeSnippet(trigger: "from", body: "from $1 import $2", language: "python", description: "from ... import ...", name: "from import"),
        CodeSnippet(trigger: "print", body: "print($1)", language: "python", description: "print statement", name: "print"),
        CodeSnippet(trigger: "listcomp", body: "[$1 for $2 in $3]", language: "python", description: "List comprehension", name: "List Comprehension"),
        CodeSnippet(trigger: "dictcomp", body: "{$1: $2 for $3 in $4}", language: "python", description: "Dict comprehension", name: "Dict Comprehension"),
        CodeSnippet(trigger: "setcomp", body: "{$1 for $2 in $3}", language: "python", description: "Set comprehension", name: "Set Comprehension"),
        CodeSnippet(trigger: "lambda", body: "lambda $1: $2", language: "python", description: "Lambda expression", name: "lambda"),
        CodeSnippet(trigger: "main", body: "if __name__ == '__main__':\n    $1", language: "python", description: "main guard", name: "__main__"),
        CodeSnippet(trigger: "property", body: "@property\ndef $1(self):\n    return self._$1", language: "python", description: "@property decorator", name: "@property"),
        CodeSnippet(trigger: "dataclass", body: "from dataclasses import dataclass\n\n@dataclass\nclass $1:\n    $2: $3", language: "python", description: "dataclass", name: "@dataclass"),
    ]

    // HTML
    let htmlSnippets: [CodeSnippet] = [
        CodeSnippet(trigger: "html5", body: "<!DOCTYPE html>\n<html lang=\"$1\">\n<head>\n    <meta charset=\"UTF-8\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n    <title>$2</title>\n</head>\n<body>\n    $3\n</body>\n</html>", language: "html", description: "HTML5 boilerplate", name: "HTML5 Boilerplate"),
        CodeSnippet(trigger: "div", body: "<div class=\"$1\">\n    $2\n</div>", language: "html", description: "div element", name: "div"),
        CodeSnippet(trigger: "section", body: "<section class=\"$1\">\n    $2\n</section>", language: "html", description: "section element", name: "section"),
        CodeSnippet(trigger: "nav", body: "<nav class=\"$1\">\n    $2\n</nav>", language: "html", description: "nav element", name: "nav"),
        CodeSnippet(trigger: "ul", body: "<ul>\n    <li>$1</li>\n    <li>$2</li>\n</ul>", language: "html", description: "Unordered list", name: "ul"),
        CodeSnippet(trigger: "ol", body: "<ol>\n    <li>$1</li>\n    <li>$2</li>\n</ol>", language: "html", description: "Ordered list", name: "ol"),
        CodeSnippet(trigger: "form", body: "<form action=\"$1\" method=\"$2\">\n    $3\n    <button type=\"submit\">$4</button>\n</form>", language: "html", description: "form element", name: "form"),
        CodeSnippet(trigger: "input", body: "<input type=\"$1\" name=\"$2\" id=\"$3\" placeholder=\"$4\">", language: "html", description: "input element", name: "input"),
        CodeSnippet(trigger: "a", body: "<a href=\"$1\">$2</a>", language: "html", description: "anchor link", name: "a"),
        CodeSnippet(trigger: "img", body: "<img src=\"$1\" alt=\"$2\" width=\"$3\" height=\"$4\">", language: "html", description: "image element", name: "img"),
        CodeSnippet(trigger: "table", body: "<table>\n    <thead>\n        <tr><th>$1</th></tr>\n    </thead>\n    <tbody>\n        <tr><td>$2</td></tr>\n    </tbody>\n</table>", language: "html", description: "table element", name: "table"),
        CodeSnippet(trigger: "script", body: "<script>\n    $1\n</script>", language: "html", description: "script block", name: "script"),
        CodeSnippet(trigger: "link", body: "<link rel=\"stylesheet\" href=\"$1\">", language: "html", description: "CSS link", name: "link (CSS)"),
        CodeSnippet(trigger: "button", body: "<button type=\"$1\" class=\"$2\">$3</button>", language: "html", description: "button element", name: "button"),
        CodeSnippet(trigger: "meta", body: "<meta name=\"$1\" content=\"$2\">", language: "html", description: "meta tag", name: "meta"),
    ]

    // CSS
    let cssSnippets: [CodeSnippet] = [
        CodeSnippet(trigger: "rule", body: "$1 {\n    $2\n}", language: "css", description: "CSS rule block", name: "CSS Rule"),
        CodeSnippet(trigger: "flexbox", body: "display: flex;\njustify-content: $1;\nalign-items: $2;", language: "css", description: "Flexbox layout", name: "Flexbox"),
        CodeSnippet(trigger: "grid", body: "display: grid;\ngrid-template-columns: $1;\ngrid-gap: $2;", language: "css", description: "CSS Grid", name: "Grid"),
        CodeSnippet(trigger: "media", body: "@media ($1) {\n    $2\n}", language: "css", description: "Media query", name: "Media Query"),
        CodeSnippet(trigger: "animation", body: "@keyframes $1 {\n    from {\n        $2\n    }\n    to {\n        $3\n    }\n}", language: "css", description: "CSS keyframe animation", name: "Animation"),
        CodeSnippet(trigger: "transition", body: "transition: $1 $2ms $3;", language: "css", description: "transition property", name: "Transition"),
        CodeSnippet(trigger: "variable", body: "--$1: $2;", language: "css", description: "CSS custom property", name: "CSS Variable"),
    ]

    // MARK: - Autocomplete Suggestions

    // MARK: - Snippet Access

    /// All built-in snippets for a given language identifier string.
    func snippets(forLanguage language: String?) -> [CodeSnippet] {
        guard let language = language else { return [] }
        switch language.lowercased() {
        case "swift":                    return swiftSnippets
        case "javascript", "js":         return javascriptSnippets
        case "typescript", "ts":         return javascriptSnippets
        case "python":                   return pythonSnippets
        case "html":                     return htmlSnippets
        case "css":                      return cssSnippets
        default:                         return []
        }
    }

    /// Built-in snippets for a typed CodeLanguage value.
    func snippets(for language: CodeLanguage) -> [CodeSnippet] {
        snippets(forLanguage: language.rawValue)
    }

    /// Finds a snippet by exact trigger and language.
    func snippet(forTrigger trigger: String, language: String) -> CodeSnippet? {
        snippets(forLanguage: language).first { $0.trigger == trigger }
    }

    // MARK: - Autocomplete Integration

    /// Snippet suggestions whose trigger starts with prefix for the given language.
    ///
    /// Wire-up in AutocompleteManager.updateSuggestions(for:cursorPosition:):
    ///   1. Add `case snippet` to the SuggestionKind enum.
    ///   2. After gathering existing candidates:
    ///      if let lang = currentLanguage?.rawValue {
    ///          let hits = SnippetManager.shared.autocompleteSuggestions(
    ///              matchingPrefix: prefixLower, language: lang)
    ///          candidates.append(contentsOf: hits.map {
    ///              Suggestion(kind: .snippet, displayText: $0.displayText,
    ///                         insertText: $0.trigger, score: 950)
    ///          })
    ///      }
    func autocompleteSuggestions(
        matchingPrefix prefix: String,
        language: String
    ) -> [(displayText: String, trigger: String, description: String)] {
        snippets(forLanguage: language)
            .filter { $0.trigger.lowercased().hasPrefix(prefix.lowercased()) }
            .map { snippet in
                (displayText: snippet.name + "  " + snippet.trigger,
                 trigger: snippet.trigger,
                 description: snippet.description)
            }
    }

    // MARK: - Snippet Expansion

    /// Expands a CodeSnippet body, resolving ${N:placeholder} and $N markers.
    /// Returns (expandedText, tabStops) with stops in visitation order ($0 last).
    func expand(_ snippet: CodeSnippet) -> (text: String, tabStops: [TabStopSession.TabStop]) {
        expand(body: snippet.body)
    }

    /// Overload that works with a raw body string (compatible with legacy Snippet).
    func expand(body: String) -> (text: String, tabStops: [TabStopSession.TabStop]) {
        var output = ""
        var tabStopMap: [Int: TabStopSession.TabStop] = [:]
        var i = body.startIndex

        while i < body.endIndex {
            let ch = body[i]

            guard ch == "$" else {
                output.append(ch)
                i = body.index(after: i)
                continue
            }

            let afterDollar = body.index(after: i)
            guard afterDollar < body.endIndex else {
                output.append(ch)
                i = body.index(after: i)
                continue
            }

            if body[afterDollar] == "{" {
                // Parse ${N:placeholder} or ${N}
                var j = body.index(after: afterDollar)
                var digits = ""
                while j < body.endIndex, body[j].isNumber {
                    digits.append(body[j])
                    j = body.index(after: j)
                }
                if !digits.isEmpty, let n = Int(digits), j < body.endIndex {
                    if body[j] == ":" {
                        j = body.index(after: j)
                        var placeholder = ""
                        var depth = 1
                        while j < body.endIndex {
                            let c = body[j]
                            if c == "{" { depth += 1 }
                            if c == "}" { depth -= 1; if depth == 0 { j = body.index(after: j); break } }
                            placeholder.append(c)
                            j = body.index(after: j)
                        }
                        if tabStopMap[n] == nil {
                            tabStopMap[n] = TabStopSession.TabStop(
                                number: n, offset: output.count, length: placeholder.count)
                        }
                        output.append(contentsOf: placeholder)
                        i = j; continue
                    } else if body[j] == "}" {
                        j = body.index(after: j)
                        if tabStopMap[n] == nil {
                            tabStopMap[n] = TabStopSession.TabStop(
                                number: n, offset: output.count, length: 0)
                        }
                        i = j; continue
                    }
                }
                output.append(ch)
                i = body.index(after: i)
            } else {
                // Parse plain $N
                var j = afterDollar
                var digits = ""
                while j < body.endIndex, body[j].isNumber {
                    digits.append(body[j])
                    j = body.index(after: j)
                }
                if !digits.isEmpty, let n = Int(digits) {
                    if tabStopMap[n] == nil {
                        tabStopMap[n] = TabStopSession.TabStop(
                            number: n, offset: output.count, length: 0)
                    }
                    i = j; continue
                }
                output.append(ch)
                i = body.index(after: i)
            }
        }

        // Sort: ascending by number, $0 always last
        let sorted = tabStopMap.values.sorted {
            if $0.number == 0 { return false }
            if $1.number == 0 { return true }
            return $0.number < $1.number
        }
        return (output, sorted)
    }

    // MARK: - Tab-Stop Session Management

    /// Begins a tab-stop session after a CodeSnippet is inserted into the editor.
    ///
    /// - Parameters:
    ///   - snippet: The CodeSnippet that was just expanded and inserted.
    ///   - insertionOffset: Absolute character offset in the document where the snippet begins.
    /// - Returns: The activated TabStopSession (also accessible via activeSession).
    @discardableResult
    func beginTabStopSession(snippet: CodeSnippet, insertedAt insertionOffset: Int) -> TabStopSession {
        let (_, tabStops) = expand(snippet)
        let session = TabStopSession(tabStops: tabStops, insertionOffset: insertionOffset)
        activeSession = session
        return session
    }

    /// Begins a session from a legacy Snippet (SnippetsManager body format).
    @discardableResult
    func beginTabStopSession(legacySnippet: Snippet, insertedAt insertionOffset: Int) -> TabStopSession {
        let (_, tabStops) = expand(body: legacySnippet.body)
        let session = TabStopSession(tabStops: tabStops, insertionOffset: insertionOffset)
        activeSession = session
        return session
    }

    /// Advances the active session to the next tab stop.
    ///
    /// Call in RunestoneEditorView.Coordinator shouldChangeTextIn when text == "	":
    ///   if text == "	", SnippetManager.shared.hasActiveSession {
    ///       if let range = SnippetManager.shared.advanceTabStop() {
    ///           textView.selectedRange = range
    ///           textView.scrollRangeToVisible(range)
    ///           return false
    ///       }
    ///   }
    ///
    /// - Returns: NSRange to select, or nil when the session is complete.
    func advanceTabStop() -> NSRange? {
        guard let session = activeSession else { return nil }
        let range = session.nextTabStop()
        if session.isFinished { activeSession = nil }
        return range
    }

    /// Immediately ends the active session (e.g. Escape, click away, or file switch).
    func endTabStopSession() {
        activeSession = nil
    }

    // MARK: - Legacy SnippetsManager Bridge

    /// Returns built-in snippets as the legacy Snippet type for SnippetPickerView.
    ///
    /// To show built-ins for all languages in SnippetPickerView, update
    /// SnippetsManager.allSnippets(language:) to:
    ///   func allSnippets(language: CodeLanguage?) -> [Snippet] {
    ///       let builtIns = SnippetManager.shared.asLegacySnippets(for: language)
    ///       return builtIns + customSnippets
    ///   }
    func asLegacySnippets(for language: CodeLanguage?) -> [Snippet] {
        guard let language = language else { return [] }
        return snippets(for: language).map { $0.asSnippet }
    }
}

// MARK: - Language Detection Helper

extension SnippetManager {

    /// Infers the language string from a filename extension.
    /// Returns nil for unsupported / unknown extensions.
    static func language(forFilename filename: String) -> String? {
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
}
