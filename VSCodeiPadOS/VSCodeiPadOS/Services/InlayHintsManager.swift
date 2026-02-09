import Foundation

/// A lightweight inlay-hints engine used to show inline type annotations.
///
/// Scope (FEAT-133):
/// - Detect simple Swift variable declarations without explicit types.
/// - Infer basic types from the initializer expression.
/// - Return hint objects with line/column + a display string (e.g. ": Int").
final class InlayHintsManager {
    static let shared = InlayHintsManager()
    private init() {}

    // MARK: - Models

    struct InlayHint: Identifiable, Equatable {
        let id = UUID()

        /// 0-based line index.
        let line: Int

        /// 0-based UTF16 column index within the line.
        let column: Int

        /// Render-ready hint text (e.g. ": Int").
        let text: String
    }

    // MARK: - Public API

    func hints(for code: String, language: CodeLanguage) -> [InlayHint] {
        guard language == .swift else { return [] }
        return swiftTypeHints(for: code)
    }

    // MARK: - Swift parsing

    private func swiftTypeHints(for code: String) -> [InlayHint] {
        let lines = code.components(separatedBy: .newlines)
        var result: [InlayHint] = []

        // Matches:
        //   let x = 5
        //   var name = "abc"
        // Avoids explicit type annotations because the pattern does not accept `:` before `=`.
        let pattern = "^\\s*(?:let|var)\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*=\\s*(.+)$"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        for (lineIndex, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.hasPrefix("//"), !trimmed.isEmpty else { continue }

            let nsLine = line as NSString
            let range = NSRange(location: 0, length: nsLine.length)
            guard let match = regex?.firstMatch(in: line, options: [], range: range) else { continue }
            guard match.numberOfRanges >= 3 else { continue }

            let nameRange = match.range(at: 1)
            let rhsRange = match.range(at: 2)
            if nameRange.location == NSNotFound || rhsRange.location == NSNotFound { continue }

            // Basic sanity checks: ignore tuple bindings like `let (a, b) = ...`
            let name = nsLine.substring(with: nameRange)
            guard !name.isEmpty else { continue }

            // RHS, stripped of trailing `//` comments (naive but practical).
            var rhs = nsLine.substring(with: rhsRange)
            if let commentRange = rhs.range(of: "//") {
                rhs = String(rhs[..<commentRange.lowerBound])
            }
            rhs = rhs.trimmingCharacters(in: .whitespacesAndNewlines)

            // Infer a type. If we can’t infer, don’t create a hint.
            guard let inferred = inferSwiftType(from: rhs) else { continue }

            // Column for hint placement = end of identifier.
            let hintColumn = nameRange.location + nameRange.length
            result.append(InlayHint(line: lineIndex, column: hintColumn, text: ": \(inferred)"))
        }

        return result
    }

    // MARK: - Swift type inference (basic)

    private func inferSwiftType(from rawExpression: String) -> String? {
        let expr = rawExpression.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !expr.isEmpty else { return nil }

        // Bool
        if expr == "true" || expr == "false" { return "Bool" }

        // String literal (simple)
        if expr.hasPrefix("\"") { return "String" }

        // Numeric: Int
        if matches(expr, pattern: "^-?\\d+$") { return "Int" }
        if matches(expr, pattern: "^-?0x[0-9A-Fa-f]+$") { return "Int" }
        if matches(expr, pattern: "^-?0b[01]+$") { return "Int" }
        if matches(expr, pattern: "^-?0o[0-7]+$") { return "Int" }

        // Numeric: Double (Swift defaults floating-point literals to Double)
        if matches(expr, pattern: "^-?\\d+\\.\\d+(?:[eE][-+]?\\d+)?$") { return "Double" }
        if matches(expr, pattern: "^-?\\d+(?:[eE][-+]?\\d+)$") { return "Double" }

        // Array / Dictionary literals
        if expr.hasPrefix("[") {
            if let dictType = inferDictionaryType(from: expr) { return dictType }
            if let arrayType = inferArrayType(from: expr) { return arrayType }
        }

        // Constructor-looking calls: `TypeName(...)` (biased toward UpperCamelCase types)
        if let typeName = firstRegexGroup(expr, pattern: "^([A-Z][A-Za-z0-9_]*)\\s*\\(") {
            return typeName
        }

        // Enum/static member: `TypeName.member`
        if let typeName = firstRegexGroup(expr, pattern: "^([A-Z][A-Za-z0-9_]*)\\.[A-Za-z_][A-Za-z0-9_]*$") {
            return typeName
        }

        return nil
    }

    private func inferArrayType(from expr: String) -> String? {
        let trimmed = expr.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("[") && trimmed.hasSuffix("]") else { return nil }

        let inner = trimmed.dropFirst().dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        if inner.isEmpty { return "[Any]" }

        // Take the first top-level element (naive: split by comma).
        let firstPart = inner.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true).first
        guard let first = firstPart.map(String.init)?.trimmingCharacters(in: .whitespacesAndNewlines), !first.isEmpty else {
            return "[Any]"
        }

        if let elementType = inferSwiftType(from: first) {
            return "[\(elementType)]"
        }

        return "[Any]"
    }

    private func inferDictionaryType(from expr: String) -> String? {
        let trimmed = expr.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("[") && trimmed.hasSuffix("]") else { return nil }

        // Fast check: dictionary literals must contain `:` somewhere.
        guard trimmed.contains(":") else { return nil }

        let inner = trimmed.dropFirst().dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        if inner.isEmpty { return "[AnyHashable: Any]" }

        // Grab the first `key: value` pair (naive: up to first comma).
        let firstPair = inner.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true).first.map(String.init) ?? ""
        guard let colonIndex = firstPair.firstIndex(of: ":") else { return nil }

        let keyExpr = String(firstPair[..<colonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        let valueExpr = String(firstPair[firstPair.index(after: colonIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)

        let keyType = inferSwiftType(from: keyExpr) ?? "AnyHashable"
        let valueType = inferSwiftType(from: valueExpr) ?? "Any"
        return "[\(keyType): \(valueType)]"
    }

    // MARK: - Regex helpers

    private func matches(_ text: String, pattern: String) -> Bool {
        (try? NSRegularExpression(pattern: pattern, options: []))?.firstMatch(
            in: text,
            options: [],
            range: NSRange(location: 0, length: (text as NSString).length)
        ) != nil
    }

    private func firstRegexGroup(_ text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let ns = text as NSString
        let range = NSRange(location: 0, length: ns.length)
        guard let match = regex.firstMatch(in: text, options: [], range: range), match.numberOfRanges >= 2 else { return nil }
        let r = match.range(at: 1)
        guard r.location != NSNotFound else { return nil }
        return ns.substring(with: r)
    }
}
