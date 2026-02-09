import Foundation

// MARK: - Snippet Model

struct Snippet: Identifiable, Codable, Equatable {
    var id: UUID = UUID()

    /// Display name shown in pickers.
    var name: String

    /// The trigger text typed in the editor (expanded via prefix + Tab).
    var prefix: String

    /// The snippet template. Supports $1, $2 ... placeholders.
    var body: String

    /// Optional description shown in the UI.
    var description: String
}

// MARK: - Snippets Manager

final class SnippetsManager: ObservableObject {
    static let shared = SnippetsManager()

    @Published private(set) var customSnippets: [Snippet] = []

    /// Built-in snippets (currently Swift-only).
    let builtInSwiftSnippets: [Snippet] = [
        Snippet(
            name: "Function",
            prefix: "func",
            body: "func $1($2) {\n    $3\n}",
            description: "Create a function"
        ),
        Snippet(
            name: "Guard",
            prefix: "guard",
            body: "guard $1 else {\n    $2\n}",
            description: "guard ... else { ... }"
        ),
        Snippet(
            name: "If Let",
            prefix: "iflet",
            body: "if let $1 = $2 {\n    $3\n}",
            description: "if let ... { ... }"
        ),
        Snippet(
            name: "Struct",
            prefix: "struct",
            body: "struct $1 {\n    $2\n}",
            description: "Create a struct"
        ),
        Snippet(
            name: "Class",
            prefix: "class",
            body: "class $1 {\n    $2\n}",
            description: "Create a class"
        ),
        Snippet(
            name: "Enum",
            prefix: "enum",
            body: "enum $1 {\n    case $2\n}",
            description: "Create an enum"
        )
    ]

    private let userDefaultsKey = "customSnippets"

    private init() {
        loadCustomSnippets()
    }

    // MARK: - Public API

    func allSnippets(language: CodeLanguage?) -> [Snippet] {
        // Swift-only built-ins for now.
        let builtIns: [Snippet]
        if language == .swift || language == nil {
            builtIns = builtInSwiftSnippets
        } else {
            builtIns = []
        }
        return builtIns + customSnippets
    }

    func snippet(forPrefix prefix: String, language: CodeLanguage?) -> Snippet? {
        let normalized = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }

        // Prefer custom override, then built-ins.
        if let match = customSnippets.first(where: { $0.prefix == normalized }) {
            return match
        }

        if language == .swift || language == nil {
            return builtInSwiftSnippets.first(where: { $0.prefix == normalized })
        }

        return nil
    }

    func addCustomSnippet(_ snippet: Snippet) {
        // If the same prefix exists, replace it.
        if let idx = customSnippets.firstIndex(where: { $0.prefix == snippet.prefix }) {
            customSnippets[idx] = snippet
        } else {
            customSnippets.append(snippet)
        }
        saveCustomSnippets()
    }

    func deleteCustomSnippet(id: UUID) {
        customSnippets.removeAll { $0.id == id }
        saveCustomSnippets()
    }

    // MARK: - Persistence

    func loadCustomSnippets() {
        // Prefer JSON file if present, else fallback to UserDefaults.
        if let fileSnippets = loadFromJSONFile() {
            customSnippets = fileSnippets
            return
        }

        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            customSnippets = []
            return
        }

        do {
            customSnippets = try JSONDecoder().decode([Snippet].self, from: data)
        } catch {
            customSnippets = []
        }
    }

    func saveCustomSnippets() {
        do {
            let data = try JSONEncoder().encode(customSnippets)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            saveToJSONFile(data: data)
        } catch {
            // Ignore persistence errors.
        }
    }

    private func snippetsFileURL() -> URL? {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return docs.appendingPathComponent("snippets.json")
    }

    private func loadFromJSONFile() -> [Snippet]? {
        guard let url = snippetsFileURL(), FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Snippet].self, from: data)
        } catch {
            return nil
        }
    }

    private func saveToJSONFile(data: Data) {
        guard let url = snippetsFileURL() else { return }
        do {
            try data.write(to: url, options: [.atomic])
        } catch {
            // Ignore.
        }
    }
}

// MARK: - Snippet Expansion

extension SnippetsManager {
    /// Expands a snippet body and returns:
    /// - text: body with $1/$2... placeholders removed
    /// - cursorOffset: position of $1 if present, else end of expanded text
    func expand(_ snippet: Snippet) -> (text: String, cursorOffset: Int) {
        let body = snippet.body

        var output = ""
        var i = body.startIndex
        var placeholderOffsets: [Int: Int] = [:]

        while i < body.endIndex {
            let ch = body[i]
            if ch == "$" {
                var j = body.index(after: i)
                var digits = ""
                while j < body.endIndex, body[j].isNumber {
                    digits.append(body[j])
                    j = body.index(after: j)
                }

                if !digits.isEmpty, let n = Int(digits) {
                    if placeholderOffsets[n] == nil {
                        placeholderOffsets[n] = output.count
                    }
                    i = j
                    continue
                }
            }

            output.append(ch)
            i = body.index(after: i)
        }

        let cursorOffset = placeholderOffsets[1] ?? output.count
        return (output, cursorOffset)
    }
}
