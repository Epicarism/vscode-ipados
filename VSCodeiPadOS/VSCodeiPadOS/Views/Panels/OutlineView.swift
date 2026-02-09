import SwiftUI

// MARK: - Outline Panel

/// Shows a tree of symbols (classes/structs/enums + their members, functions, vars/lets) for the current file.
///
/// Note: This view parses symbols from the *current editor tab content* (no LSP).
struct OutlineView: View {
    @ObservedObject var editorCore: EditorCore

    /// Called when the user selects a symbol.
    /// Expected behavior: scroll editor to `line` (1-indexed).
    var onJumpToLine: (Int) -> Void = { _ in }

    enum SortMode: String, CaseIterable, Identifiable {
        case position = "Position"
        case alphabetical = "A–Z"
        var id: String { rawValue }
    }

    @State private var filterText: String = ""
    @State private var sortMode: SortMode = .position

    // Persist expansion by stable key (not UUID) so it survives reparses.
    @State private var expandedKeys: Set<String> = []

    @State private var parsedRootItems: [OutlineItem] = []
    @State private var parseWorkItem: DispatchWorkItem?

    private var activeTab: Tab? { editorCore.activeTab }
    private var activeContent: String { activeTab?.content ?? "" }
    private var activeLanguage: CodeLanguage { activeTab?.language ?? .plainText }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            filterField
            sortPicker

            Divider()

            if activeTab == nil {
                emptyState(title: "No file open", systemImage: "doc")
            } else if parsedRootItems.isEmpty {
                emptyState(title: "No symbols", systemImage: "list.bullet.rectangle")
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(displayItems) { item in
                            OutlineRow(
                                item: item,
                                level: 0,
                                expandedKeys: $expandedKeys,
                                onSelect: { selected in
                                    onJumpToLine(selected.line)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear { scheduleParse() }
        .onChange(of: editorCore.activeTabId) { _ in scheduleParse() }
        .onChange(of: activeContent) { _ in scheduleParse() }
    }

    // MARK: - UI

    private var header: some View {
        HStack {
            Text("OUTLINE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Spacer()

            Button {
                scheduleParse(immediate: true)
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Refresh")
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private var filterField: some View {
        HStack(spacing: 6) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(.secondary)
                .font(.caption)

            TextField("Filter symbols", text: $filterText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))

            if !filterText.isEmpty {
                Button { filterText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(6)
        .padding(.horizontal, 12)
    }

    private var sortPicker: some View {
        Picker("Sort", selection: $sortMode) {
            ForEach(SortMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 12)
    }

    private func emptyState(title: String, systemImage: String) -> some View {
        VStack(spacing: 10) {
            Spacer(minLength: 10)
            Image(systemName: systemImage)
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.6))
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer(minLength: 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    // MARK: - Display items (filter + sort)

    private var displayItems: [OutlineItem] {
        let filtered = OutlineTree.filter(items: parsedRootItems, query: filterText)
        return OutlineTree.sort(items: filtered, mode: sortMode)
    }

    // MARK: - Parsing

    private func scheduleParse(immediate: Bool = false) {
        parseWorkItem?.cancel()

        let work = DispatchWorkItem {
            let items = OutlineParser.parseOutlineItems(from: activeContent, language: activeLanguage)
            DispatchQueue.main.async {
                self.parsedRootItems = items
                // Keep expanded keys only for still-present nodes.
                let existingKeys = Set(OutlineTree.allKeys(in: items))
                self.expandedKeys = self.expandedKeys.intersection(existingKeys)
            }
        }

        parseWorkItem = work

        if immediate {
            DispatchQueue.global(qos: .userInitiated).async(execute: work)
        } else {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.25, execute: work)
        }
    }
}

// MARK: - Outline Models

struct OutlineItem: Identifiable, Hashable {
    /// Stable key used for list identity + expansion persistence.
    let id: String

    let name: String
    let type: SymbolType
    let line: Int
    let column: Int

    var children: [OutlineItem]

    var isContainer: Bool {
        switch type {
        case .class, .struct, .enum, .protocol, .interface, .namespace, .module, .type:
            return true
        default:
            return !children.isEmpty
        }
    }
}

// MARK: - Outline Tree helpers

private enum OutlineTree {
    static func filter(items: [OutlineItem], query: String) -> [OutlineItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return items }

        func matches(_ item: OutlineItem) -> Bool {
            item.name.lowercased().contains(q) || item.type.rawValue.lowercased().contains(q)
        }

        func filterItem(_ item: OutlineItem) -> OutlineItem? {
            let filteredChildren = item.children.compactMap(filterItem)
            if matches(item) || !filteredChildren.isEmpty {
                return OutlineItem(
                    id: item.id,
                    name: item.name,
                    type: item.type,
                    line: item.line,
                    column: item.column,
                    children: filteredChildren
                )
            }
            return nil
        }

        return items.compactMap(filterItem)
    }

    static func sort(items: [OutlineItem], mode: OutlineView.SortMode) -> [OutlineItem] {
        func sortKey(_ a: OutlineItem, _ b: OutlineItem) -> Bool {
            switch mode {
            case .position:
                if a.line != b.line { return a.line < b.line }
                return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            case .alphabetical:
                let cmp = a.name.localizedCaseInsensitiveCompare(b.name)
                if cmp != .orderedSame { return cmp == .orderedAscending }
                return a.line < b.line
            }
        }

        return items
            .sorted(by: sortKey)
            .map { item in
                OutlineItem(
                    id: item.id,
                    name: item.name,
                    type: item.type,
                    line: item.line,
                    column: item.column,
                    children: sort(items: item.children, mode: mode)
                )
            }
    }

    static func allKeys(in items: [OutlineItem]) -> [String] {
        var out: [String] = []
        func walk(_ items: [OutlineItem]) {
            for item in items {
                out.append(item.id)
                if !item.children.isEmpty { walk(item.children) }
            }
        }
        walk(items)
        return out
    }
}

// MARK: - Outline Row

private struct OutlineRow: View {
    let item: OutlineItem
    let level: Int
    @Binding var expandedKeys: Set<String>
    let onSelect: (OutlineItem) -> Void

    private var isExpanded: Bool {
        expandedKeys.contains(item.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            row

            if item.isContainer && isExpanded {
                ForEach(item.children) { child in
                    OutlineRow(item: child, level: level + 1, expandedKeys: $expandedKeys, onSelect: onSelect)
                }
            }
        }
    }

    private var row: some View {
        Button {
            // Clicking container name selects it; clicking chevron expands/collapses.
            onSelect(item)
        } label: {
            HStack(spacing: 6) {
                Spacer().frame(width: CGFloat(level) * 14)

                if item.isContainer {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                        .contentShape(Rectangle())
                        .onTapGesture { toggleExpanded() }
                } else {
                    Spacer().frame(width: 12)
                }

                Image(systemName: item.type.icon)
                    .font(.system(size: 12))
                    .foregroundColor(item.type.color)
                    .frame(width: 16)

                Text(item.name)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                Text("\(item.line)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Jump to Line \(item.line)") { onSelect(item) }
            if item.isContainer {
                Button(isExpanded ? "Collapse" : "Expand") { toggleExpanded() }
            }
        }
    }

    private func toggleExpanded() {
        if isExpanded {
            expandedKeys.remove(item.id)
        } else {
            expandedKeys.insert(item.id)
        }
    }
}

// MARK: - Parsing

private enum OutlineParser {
    static func parseOutlineItems(from content: String, language: CodeLanguage) -> [OutlineItem] {
        switch language {
        case .swift:
            return SwiftOutlineParser.parse(content)
        case .javascript, .typescript:
            return JSOutlineParser.parse(content)
        case .python:
            return PythonOutlineParser.parse(content)
        default:
            return GenericOutlineParser.parse(content)
        }
    }
}

// MARK: - Swift Outline Parser

private enum SwiftOutlineParser {
    private struct ContainerFrame {
        let key: String
        let depth: Int
        let kind: SymbolType
    }

    final class Node {
        var id: String
        var name: String
        var type: SymbolType
        var line: Int
        var column: Int
        var children: [Node] = []
        init(id: String, name: String, type: SymbolType, line: Int, column: Int) {
            self.id = id
            self.name = name
            self.type = type
            self.line = line
            self.column = column
        }
    }

    static func parse(_ content: String) -> [OutlineItem] {
        let lines = content.components(separatedBy: .newlines)

        var roots: [Node] = []
        var stack: [(frame: ContainerFrame, node: Node)] = []
        var braceDepth = 0

        // Patterns are intentionally conservative.
        let patterns: [(regex: NSRegularExpression, type: SymbolType, nameGroup: Int)] = {
            let list: [(String, SymbolType, Int)] = [
                // Containers
                (#"^\s*(?:public |private |internal |fileprivate |open )?(?:final )?class\s+(\w+)"#, .class, 1),
                (#"^\s*(?:public |private |internal |fileprivate |open )?struct\s+(\w+)"#, .struct, 1),
                (#"^\s*(?:public |private |internal |fileprivate |open )?enum\s+(\w+)"#, .enum, 1),
                (#"^\s*(?:public |private |internal |fileprivate |open )?protocol\s+(\w+)"#, .protocol, 1),
                (#"^\s*(?:public |private |internal |fileprivate |open )?extension\s+([\w\.]+)"#, .type, 1),

                // Members
                (#"^\s*(?:@\w+\s+)*(?:public |private |internal |fileprivate |open )?(?:static |class )?func\s+(\w+)"#, .function, 1),
                (#"^\s*(?:@\w+\s+)*(?:public |private |internal |fileprivate |open )?(?:static |class )?(?:var|let)\s+(\w+)"#, .property, 1),
                (#"^\s*(?:public |private |internal |fileprivate |open )?(?:required |convenience )?init\b"#, .constructor, 0)
            ]

            return list.compactMap { pattern, type, group in
                guard let re = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
                return (re, type, group)
            }
        }()

        func isContainerType(_ type: SymbolType) -> Bool {
            switch type {
            case .class, .struct, .enum, .protocol, .interface, .namespace, .module, .type:
                return true
            default:
                return false
            }
        }

        func stableKey(type: SymbolType, name: String, line: Int, containerKey: String?) -> String {
            let container = containerKey ?? "<root>"
            return "\(container)|\(type.rawValue)|\(name)|\(line)"
        }

        func addNode(_ node: Node) {
            if let last = stack.last {
                last.node.children.append(node)
            } else {
                roots.append(node)
            }
        }

        for (idx, rawLine) in lines.enumerated() {
            let lineNumber = idx + 1

            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//") {
                braceDepth += braceDelta(in: rawLine)
                popContainersIfNeeded(newDepth: braceDepth, stack: &stack)
                continue
            }

            var foundContainerNode: Node?
            var foundContainerKind: SymbolType?

            for entry in patterns {
                if let match = entry.regex.firstMatch(in: rawLine, options: [], range: NSRange(rawLine.startIndex..., in: rawLine)) {
                    let name: String
                    if entry.type == .constructor {
                        name = "init"
                    } else if entry.nameGroup > 0,
                              let range = Range(match.range(at: entry.nameGroup), in: rawLine) {
                        name = String(rawLine[range])
                    } else {
                        continue
                    }

                    var finalType = entry.type
                    if finalType == .function, let containerKind = stack.last?.frame.kind, isContainerType(containerKind) {
                        finalType = .method
                    }

                    let containerKey = stack.last?.frame.key
                    let key = stableKey(type: finalType, name: name, line: lineNumber, containerKey: containerKey)
                    let node = Node(id: key, name: name, type: finalType, line: lineNumber, column: 1)
                    addNode(node)

                    if isContainerType(entry.type) {
                        foundContainerNode = node
                        foundContainerKind = entry.type
                    }
                    break
                }
            }

            braceDepth += braceDelta(in: rawLine)

            if let containerNode = foundContainerNode,
               let kind = foundContainerKind,
               rawLine.contains("{") {
                stack.append((ContainerFrame(key: containerNode.id, depth: braceDepth, kind: kind), containerNode))
            }

            popContainersIfNeeded(newDepth: braceDepth, stack: &stack)
        }

        return roots.map(toItem)
    }

    private static func toItem(_ node: Node) -> OutlineItem {
        OutlineItem(
            id: node.id,
            name: node.name,
            type: node.type,
            line: node.line,
            column: node.column,
            children: node.children.map(toItem)
        )
    }

    private static func popContainersIfNeeded(newDepth: Int, stack: inout [(frame: ContainerFrame, node: Node)]) {
        while let last = stack.last, newDepth < last.frame.depth {
            stack.removeLast()
        }
    }

    private static func braceDelta(in line: String) -> Int {
        let withoutStrings = stripQuotedStrings(line)
        let opens = withoutStrings.filter { $0 == "{" }.count
        let closes = withoutStrings.filter { $0 == "}" }.count
        return opens - closes
    }

    private static func stripQuotedStrings(_ line: String) -> String {
        var result = ""
        var inString = false
        var escape = false
        for ch in line {
            if escape {
                escape = false
                continue
            }
            if ch == "\\" {
                escape = true
                continue
            }
            if ch == "\"" {
                inString.toggle()
                continue
            }
            if !inString {
                result.append(ch)
            }
        }
        return result
    }
}

// MARK: - JS/TS Outline Parser

private enum JSOutlineParser {
    private struct ContainerFrame {
        let key: String
        let depth: Int
        let kind: SymbolType
    }

    final class Node {
        var id: String
        var name: String
        var type: SymbolType
        var line: Int
        var column: Int
        var children: [Node] = []
        init(id: String, name: String, type: SymbolType, line: Int, column: Int) {
            self.id = id
            self.name = name
            self.type = type
            self.line = line
            self.column = column
        }
    }

    static func parse(_ content: String) -> [OutlineItem] {
        let lines = content.components(separatedBy: .newlines)

        var roots: [Node] = []
        var stack: [(frame: ContainerFrame, node: Node)] = []
        var braceDepth = 0

        let patterns: [(NSRegularExpression, SymbolType, Int)] = {
            let list: [(String, SymbolType, Int)] = [
                (#"^\s*(?:export\s+)?(?:default\s+)?class\s+(\w+)"#, .class, 1),
                (#"^\s*(?:export\s+)?interface\s+(\w+)"#, .interface, 1),
                (#"^\s*(?:export\s+)?type\s+(\w+)"#, .type, 1),
                (#"^\s*(?:export\s+)?enum\s+(\w+)"#, .enum, 1),
                (#"^\s*(?:export\s+)?(?:async\s+)?function\s+(\w+)"#, .function, 1),
                (#"^\s*(?:export\s+)?(?:const|let|var)\s+(\w+)\s*="#, .variable, 1),
                // method (best-effort)
                (#"^\s*(?:public|private|protected)?\s*(?:static\s+)?(?:async\s+)?(\w+)\s*\("#, .method, 1)
            ]
            return list.compactMap { p, t, g in
                guard let re = try? NSRegularExpression(pattern: p, options: []) else { return nil }
                return (re, t, g)
            }
        }()

        func stableKey(type: SymbolType, name: String, line: Int, containerKey: String?) -> String {
            let container = containerKey ?? "<root>"
            return "\(container)|\(type.rawValue)|\(name)|\(line)"
        }

        func addNode(_ node: Node) {
            if let last = stack.last {
                last.node.children.append(node)
            } else {
                roots.append(node)
            }
        }

        func isInClassScope() -> Bool {
            stack.last?.frame.kind == .class
        }

        for (idx, rawLine) in lines.enumerated() {
            let lineNumber = idx + 1
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//") {
                braceDepth += braceDelta(in: rawLine)
                popContainersIfNeeded(newDepth: braceDepth, stack: &stack)
                continue
            }

            var foundContainerNode: Node?
            var foundContainerKind: SymbolType?

            for (re, type, group) in patterns {
                guard let match = re.firstMatch(in: rawLine, options: [], range: NSRange(rawLine.startIndex..., in: rawLine)) else { continue }
                guard let range = Range(match.range(at: group), in: rawLine) else { continue }
                let name = String(rawLine[range])

                if type == .method, ["if", "for", "while", "switch", "catch", "function", "constructor"].contains(name) {
                    continue
                }

                var finalType = type
                if type == .method, !isInClassScope() {
                    finalType = .function
                }

                let containerKey = stack.last?.frame.key
                let key = stableKey(type: finalType, name: name, line: lineNumber, containerKey: containerKey)
                let node = Node(id: key, name: name, type: finalType, line: lineNumber, column: 1)
                addNode(node)

                if [.class, .interface, .namespace, .module, .type].contains(type) {
                    foundContainerNode = node
                    foundContainerKind = type
                }
                break
            }

            braceDepth += braceDelta(in: rawLine)

            if let containerNode = foundContainerNode, let kind = foundContainerKind, rawLine.contains("{") {
                stack.append((ContainerFrame(key: containerNode.id, depth: braceDepth, kind: kind), containerNode))
            }

            popContainersIfNeeded(newDepth: braceDepth, stack: &stack)
        }

        return roots.map(toItem)
    }

    private static func toItem(_ node: Node) -> OutlineItem {
        OutlineItem(
            id: node.id,
            name: node.name,
            type: node.type,
            line: node.line,
            column: node.column,
            children: node.children.map(toItem)
        )
    }

    private static func popContainersIfNeeded(newDepth: Int, stack: inout [(frame: ContainerFrame, node: Node)]) {
        while let last = stack.last, newDepth < last.frame.depth {
            stack.removeLast()
        }
    }

    private static func braceDelta(in line: String) -> Int {
        let withoutStrings = stripQuotedStrings(line)
        let opens = withoutStrings.filter { $0 == "{" }.count
        let closes = withoutStrings.filter { $0 == "}" }.count
        return opens - closes
    }

    private static func stripQuotedStrings(_ line: String) -> String {
        var result = ""
        var inSingle = false
        var inDouble = false
        var escape = false
        for ch in line {
            if escape {
                escape = false
                continue
            }
            if ch == "\\" {
                escape = true
                continue
            }
            if ch == "'" && !inDouble {
                inSingle.toggle(); continue
            }
            if ch == "\"" && !inSingle {
                inDouble.toggle(); continue
            }
            if !inSingle && !inDouble { result.append(ch) }
        }
        return result
    }
}

// MARK: - Python Outline Parser (indent-based)

private enum PythonOutlineParser {
    private struct Frame {
        let key: String
        let indent: Int
        let kind: SymbolType
    }

    final class Node {
        var id: String
        var name: String
        var type: SymbolType
        var line: Int
        var column: Int
        var children: [Node] = []
        init(id: String, name: String, type: SymbolType, line: Int, column: Int) {
            self.id = id
            self.name = name
            self.type = type
            self.line = line
            self.column = column
        }
    }

    static func parse(_ content: String) -> [OutlineItem] {
        let lines = content.components(separatedBy: .newlines)

        var roots: [Node] = []
        var stack: [(frame: Frame, node: Node)] = []

        let classRe = try? NSRegularExpression(pattern: #"^\s*class\s+(\w+)"#, options: [])
        let defRe = try? NSRegularExpression(pattern: #"^\s*(?:async\s+)?def\s+(\w+)"#, options: [])

        func stableKey(type: SymbolType, name: String, line: Int, containerKey: String?) -> String {
            let container = containerKey ?? "<root>"
            return "\(container)|\(type.rawValue)|\(name)|\(line)"
        }

        func addNode(_ node: Node) {
            if let last = stack.last {
                last.node.children.append(node)
            } else {
                roots.append(node)
            }
        }

        for (idx, rawLine) in lines.enumerated() {
            let lineNumber = idx + 1
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            let indent = leadingIndent(rawLine)

            while let last = stack.last, indent <= last.frame.indent {
                stack.removeLast()
            }

            if let classRe,
               let match = classRe.firstMatch(in: rawLine, options: [], range: NSRange(rawLine.startIndex..., in: rawLine)),
               let range = Range(match.range(at: 1), in: rawLine) {

                let name = String(rawLine[range])
                let containerKey = stack.last?.frame.key
                let key = stableKey(type: .class, name: name, line: lineNumber, containerKey: containerKey)
                let node = Node(id: key, name: name, type: .class, line: lineNumber, column: 1)
                addNode(node)

                stack.append((Frame(key: node.id, indent: indent, kind: .class), node))
                continue
            }

            if let defRe,
               let match = defRe.firstMatch(in: rawLine, options: [], range: NSRange(rawLine.startIndex..., in: rawLine)),
               let range = Range(match.range(at: 1), in: rawLine) {

                let name = String(rawLine[range])
                let containerKey = stack.last?.frame.key
                let type: SymbolType = (stack.last?.frame.kind == .class) ? .method : .function

                let key = stableKey(type: type, name: name, line: lineNumber, containerKey: containerKey)
                let node = Node(id: key, name: name, type: type, line: lineNumber, column: 1)
                addNode(node)

                stack.append((Frame(key: node.id, indent: indent, kind: type), node))
                continue
            }

            if stack.isEmpty {
                if let varName = parsePythonAssignmentName(rawLine) {
                    let key = stableKey(type: .variable, name: varName, line: lineNumber, containerKey: nil)
                    let node = Node(id: key, name: varName, type: .variable, line: lineNumber, column: 1)
                    addNode(node)
                }
            }
        }

        return roots.map(toItem)
    }

    private static func toItem(_ node: Node) -> OutlineItem {
        OutlineItem(
            id: node.id,
            name: node.name,
            type: node.type,
            line: node.line,
            column: node.column,
            children: node.children.map(toItem)
        )
    }

    private static func leadingIndent(_ line: String) -> Int {
        var count = 0
        for ch in line {
            if ch == " " { count += 1 }
            else if ch == "\t" { count += 4 }
            else { break }
        }
        return count
    }

    private static func parsePythonAssignmentName(_ line: String) -> String? {
        // simplistic: <name> =
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard let eq = trimmed.firstIndex(of: "=") else { return nil }
        let lhs = trimmed[..<eq].trimmingCharacters(in: .whitespaces)
        guard !lhs.isEmpty else { return nil }
        // reject `==`
        let afterEq = trimmed.index(after: eq)
        if afterEq < trimmed.endIndex, trimmed[afterEq] == "=" { return nil }
        if lhs.contains(" ") { return nil }
        // identifier check
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        guard lhs.unicodeScalars.allSatisfy({ allowed.contains($0) }) else { return nil }
        return String(lhs)
    }
}

// MARK: - Generic Outline Parser

private enum GenericOutlineParser {
    static func parse(_ content: String) -> [OutlineItem] {
        // Fallback: use the existing SymbolParser (flat list).
        let symbols = SymbolParser.parseSymbols(from: content, language: .plainText)
        return symbols
            .map { sym in
                let key = "<root>|\(sym.type.rawValue)|\(sym.name)|\(sym.line)"
                return OutlineItem(id: key, name: sym.name, type: sym.type, line: sym.line, column: sym.column, children: [])
            }
    }
}
