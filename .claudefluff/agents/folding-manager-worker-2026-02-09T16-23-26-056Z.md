# Agent: folding-manager-worker
**Status:** done
**Tokens:** 15,166
**Cost:** $0.0000
**Time:** 2026-02-09T16:23:26.056Z

## Task
Rewrite CodeFoldingManager.swift with: 1) Enhanced fold detection (functions, classes, imports, comments, regions), 2) Fold state persistence using UserDefaults keyed by file path, 3) Collapse All / Expand All methods, 4) Get folded line ranges for text hiding

## Response
I'll help you rewrite the CodeFoldingManager.swift file with the enhanced features. Let me first read the current file to understand its structure.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

Now I'll rewrite the CodeFoldingManager.swift with all the requested enhancements.

>>>TOOL create_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "content": "import SwiftUI\nimport Foundation\n\n// MARK: - Fold Region Model\nstruct FoldRegion: Identifiable, Codable {\n    let id = UUID()\n    let startLine: Int\n    let endLine: Int\n    var isFolded: Bool = false\n    let type: FoldType\n    let label: String?\n    \n    enum FoldType: String, Codable {\n        case function\n        case classOrStruct\n        case extension\n        case enumDeclaration\n        case protocolDeclaration\n        case importStatement\n        case comment\n        case region\n        case controlFlow\n        case genericBlock\n        \n        var displayName: String {\n            switch self {\n            case .function: return \"Function\"\n            case .classOrStruct: return \"Class/Struct\"\n            case .extension: return \"Extension\"\n            case .enumDeclaration: return \"Enum\"\n            case .protocolDeclaration: return \"Protocol\"\n            case .importStatement: return \"Import\"\n            case .comment: return \"Comment\"\n            case .region: return \"Region\"\n            case .controlFlow: return \"Control Flow\"\n            case .genericBlock: return \"Block\"\n            }\n        }\n        \n        var icon: String {\n            switch self {\n            case .function: return \"f\"\n            case .classOrStruct: return \"C\"\n            case .extension: return \"E\"\n            case .enumDeclaration: return \"E\"\n            case .protocolDeclaration: return \"P\"\n            case .importStatement: return \"i\"\n            case .comment: return \"//\"\n            case .region: return \"#\"\n            case .controlFlow: return \"if\"\n            case .genericBlock: return \"{}\"\n            }\n        }\n    }\n    \n    // Exclude id from Codable\n    enum CodingKeys: String, CodingKey {\n        case startLine, endLine, isFolded, type, label\n    }\n}\n\n// MARK: - UserDefaults Keys\nstruct UserDefaultsKeys {\n    static let foldStatePrefix = \"codeFoldingState_\"\n}\n\n// MARK: - Code Folding Manager\nclass CodeFoldingManager: ObservableObject {\n    @Published var foldRegions: [FoldRegion] = []\n    @Published var collapsedLines: Set<Int> = []\n    \n    private var currentFilePath: String?\n    \n    // MARK: - Enhanced Fold Detection\n    \n    /// Detects all foldable regions in the given code\n    func detectFoldableRegions(in code: String, filePath: String? = nil) {\n        self.currentFilePath = filePath\n        let lines = code.components(separatedBy: .newlines)\n        var regions: [FoldRegion] = []\n        \n        // Track different types of blocks\n        var blockStack: [(type: FoldRegion.FoldType, startLine: Int, label: String?)] = []\n        var commentStack: [(startLine: Int, isMultiline: Bool)] = []\n        var regionStack: [(startLine: Int, label: String)] = []\n        \n        for (index, line) in lines.enumerated() {\n            let trimmed = line.trimmingCharacters(in: .whitespaces)\n            let leadingWhitespace = line.prefix { $0 == \" \" || $0 == \"\\t\" }.count\n            \n            // Skip empty lines for most detections\n            guard !trimmed.isEmpty else { continue }\n            \n            // MARK: - Region Detection (#region, #pragma mark, MARK:)\n            if detectRegionStart(trimmed) != nil {\n                if let label = detectRegionStart(trimmed) {\n                    regionStack.append((index, label))\n                }\n            } else if detectRegionEnd(trimmed) {\n                if let region = regionStack.popLast() {\n                    if index - region.startLine > 1 {\n                        regions.append(FoldRegion(\n                            startLine: region.startLine,\n                            endLine: index,\n                            type: .region,\n                            label: region.label\n                        ))\n                    }\n                }\n            }\n            \n            // MARK: - Import Statement Detection\n            if trimmed.hasPrefix(\"import \") {\n                // Group consecutive imports\n                let importEnd = findConsecutiveImports(from: index, in: lines)\n                if importEnd > index {\n                    regions.append(FoldRegion(\n                        startLine: index,\n                        endLine: importEnd,\n                        type: .importStatement,\n                        label: \"Imports\"\n                    ))\n                }\n            }\n            \n            // MARK: - Comment Detection\n            if detectCommentStart(trimmed) {\n                commentStack.append((index, true))\n            } else if trimmed.starts(with: \"//\") {\n                // Single-line comment - check for consecutive comment blocks\n                let commentEnd = findConsecutiveComments(from: index, in: lines)\n                if commentEnd > index {\n                    regions.append(FoldRegion(\n                        startLine: index,\n                        endLine: commentEnd,\n                        type: .comment,\n                        label: \"Comment\"\n                    ))\n                }\n            } else if detectCommentEnd(trimmed) {\n                if let comment = commentStack.popLast() {\n                    if index - comment.startLine > 1 {\n                        regions.append(FoldRegion(\n                            startLine: comment.startLine,\n                            endLine: index,\n                            type: .comment,\n                            label: \"Comment\"\n                        ))\n                    }\n                }\n            }\n            \n            // MARK: - Class/Struct/Enum/Protocol/Extension Detection\n            if let declaration = detectDeclaration(trimmed) {\n                if trimmed.contains(\"{\") {\n                    blockStack.append((declaration.type, index, declaration.label))\n                } else {\n                    // Declaration without opening brace - look ahead for it\n                    if let braceLine = findOpeningBrace(from: index + 1, in: lines) {\n                        blockStack.append((declaration.type, index, declaration.label))\n                    }\n                }\n            }\n            \n            // MARK: - Function/Method Detection\n            if let functionInfo = detectFunction(trimmed) {\n                if trimmed.contains(\"{\") {\n                    blockStack.append((.function, index, functionInfo))\n                } else {\n                    // Function without opening brace - look ahead\n                    if let braceLine = findOpeningBrace(from: index + 1, in: lines) {\n                        blockStack.append((.function, index, functionInfo))\n                    }\n                }\n            }\n            \n            // MARK: - Control Flow Detection (if, guard, for, while, switch, etc.)\n            if let controlFlowLabel = detectControlFlow(trimmed) {\n                if trimmed.contains(\"{\") {\n                    blockStack.append((.controlFlow, index, controlFlowLabel))\n                } else {\n                    if let braceLine = findOpeningBrace(from: index + 1, in: lines) {\n                        blockStack.append((.controlFlow, index, controlFlowLabel))\n                    }\n                }\n            }\n            \n            // MARK: - Generic Block Detection\n            if trimmed.hasSuffix(\"{\") && !isDeclarationLine(trimmed) && !isFunctionLine(trimmed) {\n                blockStack.append((.genericBlock, index, nil))\n            }\n            \n            // MARK: - Block End Detection\n            if detectBlockEnd(trimmed, leadingWhitespace: leadingWhitespace) {\n                if let lastBlock = blockStack.popLast() {\n                    if index - lastBlock.startLine > 1 {\n                        regions.append(FoldRegion(\n                            startLine: lastBlock.startLine,\n                            endLine: index,\n                            type: lastBlock.type,\n                            label: lastBlock.label\n                        ))\n                    }\n                }\n            }\n        }\n        \n        // Handle any remaining unclosed blocks\n        while let lastBlock = blockStack.popLast() {\n            if lines.count - 1 - lastBlock.startLine > 1 {\n                regions.append(FoldRegion(\n                    startLine: lastBlock.startLine,\n                    endLine: lines.count - 1,\n                    type: lastBlock.type,\n                    label: lastBlock.label\n                ))\n            }\n        }\n        \n        // Sort regions by start line\n        regions.sort { $0.startLine < $1.startLine }\n        \n        self.foldRegions = regions\n        \n        // Restore previous fold state for this file\n        if let filePath = filePath {\n            restoreFoldState(for: filePath)\n        }\n        \n        updateCollapsedLines()\n    }\n    \n    // MARK: - Detection Helper Methods\n    \n    private func detectRegionStart(_ line: String) -> String? {\n        // C# / VS style regions\n        if line.hasPrefix(\"#region\") {\n            let components = line.components(separatedBy: \"#region\")\n            return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : \"Region\"\n        }\n        // Objective-C pragma marks\n        if line.hasPrefix(\"#pragma mark\") {\n            let components = line.components(separatedBy: \"#pragma mark\")\n            return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : \"Mark\"\n        }\n        // Swift MARK comments\n        if line.contains(\"MARK:\") {\n            let components = line.components(separatedBy: \"MARK:\")\n            return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : \"Mark\"\n        }\n        // TODO/FIXME regions\n        if line.contains(\"TODO:\") {\n            let components = line.components(separatedBy: \"TODO:\")\n            return \"TODO: \" + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : \"\")\n        }\n        if line.contains(\"FIXME:\") {\n            let components = line.components(separatedBy: \"FIXME:\")\n            return \"FIXME: \" + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : \"\")\n        }\n        return nil\n    }\n    \n    private func detectRegionEnd(_ line: String) -> Bool {\n        return line.hasPrefix(\"#endregion\") || \n               line == \"// MARK: -\" ||\n               line.hasPrefix(\"#pragma mark -\")\n    }\n    \n    private func detectCommentStart(_ line: String) -> Bool {\n        return line.hasPrefix(\"/*\") && !line.contains(\"*/\")\n    }\n    \n    private func detectCommentEnd(_ line: String) -> Bool {\n        return line.contains(\"*/\") && !line.hasPrefix(\"/*\")\n    }\n    \n    private func findConsecutiveImports(from startIndex: Int, in lines: [String]) -> Int {\n        var endIndex = startIndex\n        for i in startIndex..<lines.count {\n            let trimmed = lines[i].trimmingCharacters(in: .whitespaces)\n            if trimmed.hasPrefix(\"import \") {\n                endIndex = i\n            } else if !trimmed.isEmpty {\n                break\n            }\n        }\n        return endIndex\n    }\n    \n    private func findConsecutiveComments(from startIndex: Int, in lines: [String]) -> Int {\n        var endIndex = startIndex\n        for i in startIndex..<lines.count {\n            let trimmed = lines[i].trimmingCharacters(in: .whitespaces)\n            if trimmed.starts(with: \"//\") {\n                endIndex = i\n            } else if !trimmed.isEmpty {\n                break\n            }\n        }\n        return endIndex\n    }\n    \n    private func detectDeclaration(_ line: String) -> (type: FoldRegion.FoldType, label: String)? {\n        // Class detection\n        if let className = extractName(from: line, prefix: \"class\", visibility: [\"public\", \"private\", \"internal\", \"fileprivate\", \"open\", \"final\"]) {\n            return (.classOrStruct, className)\n        }\n        // Struct detection\n        if let structName = extractName(from: line, prefix: \"struct\", visibility: [\"public\", \"private\", \"internal\", \"fileprivate\"]) {\n            return (.classOrStruct, structName)\n        }\n        // Enum detection\n        if let enumName = extractName(from: line, prefix: \"enum\", visibility: [\"public\", \"private\", \"internal\", \"fileprivate\", \"indirect\"]) {\n            return (.enumDeclaration, enumName)\n        }\n        // Protocol detection\n        if let protocolName = extractName(from: line, prefix: \"protocol\", visibility: [\"public\", \"private\", \"internal\", \"fileprivate\"]) {\n            return (.protocolDeclaration, protocolName)\n        }\n        // Extension detection\n        if let extensionName = extractName(from: line, prefix: \"extension\", visibility: []) {\n            return (.extension, extensionName)\n        }\n        return nil\n    }\n    \n    private func detectFunction(_ line: String) -> String? {\n        // Function detection with visibility modifiers\n        let visibilityKeywords = [\"public\", \"private\", \"internal\", \"fileprivate\", \"static\", \"class\", \"override\", \"final\", \"mutating\", \"convenience\"]\n        \n        // Check for 'func' keyword\n        if line.contains(\"func \") {\n            // Extract function name\n            let funcPattern = \"func\\\\s+(\\\\w+)\"\n            if let regex = try? NSRegularExpression(pattern: funcPattern),\n               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),\n               let nameRange = Range(match.range(at: 1), in: line) {\n                let functionName = String(line[nameRange])\n                // Check for parameters to create label\n                if let parenStart = line.firstIndex(of: \"(\"), let parenEnd = line.firstIndex(of: \")\") {\n                    let params = String(line[parenStart...parenEnd])\n                    return \"\\(functionName)\\(params)\"\n                }\n                return functionName\n            }\n        }\n        \n        // Init detection\n        if let initName = extractName(from: line, prefix: \"init\", visibility: visibilityKeywords) {\n            return \"\\(initName)\"\n        }\n        \n        // Deinit detection\n        if line.contains(\"deinit\") {\n            return \"deinit\"\n        }\n        \n        // Computed property with get/set\n        if line.hasPrefix(\"var \") && (line.contains(\"{\") || line.contains(\"get\")) {\n            if let varName = extractVariableName(from: line) {\n                return varName\n            }\n        }\n        \n        return nil\n    }\n    \n    private func detectControlFlow(_ line: String) -> String? {\n        let controlFlowPatterns = [\n            (\"if \", \"if\"),\n            (\"guard \", \"guard\"),\n            (\"else if\", \"else if\"),\n            (\"else\", \"else\"),\n            (\"for \", \"for\"),\n            (\"while \", \"while\"),\n            (\"repeat\", \"repeat\"),\n            (\"switch \", \"switch\"),\n            (\"case \", \"case\"),\n            (\"default:\", \"default\"),\n            (\"do \", \"do\"),\n            (\"catch\", \"catch\")\n        ]\n        \n        for (pattern, label) in controlFlowPatterns {\n            if line.contains(pattern) {\n                return label\n            }\n        }\n        return nil\n    }\n    \n    private func extractName(from line: String, prefix: String, visibility: [String]) -> String? {\n        var components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }\n        \n        // Remove visibility modifiers\n        components = components.filter { !visibility.contains($0) }\n        \n        // Find prefix index\n        if let prefixIndex = components.firstIndex(where: { $0 == prefix }),\n           prefixIndex + 1 < components.count {\n            var name = components[prefixIndex + 1]\n            // Remove colons and other trailing characters\n            name = name.components(separatedBy: \":\").first ?? name\n            name = name.components(separatedBy: \"<\").first ?? name\n            name = name.components(separatedBy: \":\").first ?? name\n            return name\n        }\n        return nil\n    }\n    \n    private func extractVariableName(from line: String) -> String? {\n        let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }\n        if components.count >= 2, components[0] == \"var\" {\n            var varName = components[1]\n            varName = varName.components(separatedBy: \":\").first ?? varName\n            varName = varName.components(separatedBy: \"=\").first ?? varName\n            return varName\n        }\n        return nil\n    }\n    \n    private func findOpeningBrace(from startIndex: Int, in lines: [String]) -> Int? {\n        for i in startIndex..<min(startIndex + 5, lines.count) {\n            if lines[i].contains(\"{\") {\n                return i\n            }\n        }\n        return nil\n    }\n    \n    private func isDeclarationLine(_ line: String) -> Bool {\n        let keywords = [\"class\", \"struct\", \"enum\", \"protocol\", \"extension\", \"init\", \"func\"]\n        return keywords.contains { line.contains(\"\\($0) \") }\n    }\n    \n    private func isFunctionLine(_ line: String) -> Bool {\n        return line.contains(\"func \") || line.contains(\"init \")\n    }\n    \n    private func detectBlockEnd(_ line: String, leadingWhitespace: Int) -> Bool {\n        return (line.hasPrefix(\"}\") || line.starts(with: \"}\")) && \n               (line.trimmingCharacters(in: .whitespaces) == \"}\" || \n                line.trimmingCharacters(in: .whitespaces).hasPrefix(\"}\"))\n    }\n    \n    // MARK: - Fold State Persistence\n    \n    /// Saves the current fold state to UserDefaults\n    func saveFoldState(for filePath: String) {\n        let key = UserDefaultsKeys.foldStatePrefix + filePath\n        \n        // Create a simplified representation for storage\n        let foldState = foldRegions.map { [\n            \"startLine\": $0.startLine,\n            \"isFolded\": $0.isFolded\n        ] }\n        \n        if let data = try? JSONEncoder().encode(foldState) {\n            UserDefaults.standard.set(data, forKey: key)\n        }\n    }\n    \n    /// Restores fold state from UserDefaults\n    private func restoreFoldState(for filePath: String) {\n        let key = UserDefaultsKeys.foldStatePrefix + filePath\n        \n        guard let data = UserDefaults.standard.data(forKey: key),\n              let foldState = try? JSONDecoder().decode([[String: Any]].self, from: data) else {\n            return\n        }\n        \n        // Apply saved state to current regions\n        for savedState in foldState {\n            if let startLine = savedState[\"startLine\"] as? Int,\n               let isFolded = savedState[\"isFolded\"] as? Bool,\n               let index = foldRegions.firstIndex(where: { $0.startLine == startLine }) {\n                foldRegions[index].isFolded = isFolded\n            }\n        }\n    }\n    \n    /// Clears fold state for a specific file\n    func clearFoldState(for filePath: String) {\n        let key = UserDefaultsKeys.foldStatePrefix + filePath\n        UserDefaults.standard.removeObject(forKey: key)\n    }\n    \n    /// Clears all fold states\n    func clearAllFoldStates() {\n        let defaults = UserDefaults.standard\n        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(UserDefaultsKeys.foldStatePrefix) }\n        for key in keys {\n            defaults.removeObject(forKey: key)\n        }\n    }\n    \n    // MARK: - Fold Operations\n    \n    /// Toggles the fold state at a specific line\n    func toggleFold(at line: Int) {\n        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {\n            foldRegions[regionIndex].isFolded.toggle()\n            updateCollapsedLines()\n            \n            // Save state after toggling\n            if let filePath = currentFilePath {\n                saveFoldState(for: filePath)\n            }\n        }\n    }\n    \n    /// Expands a folded region\n    func expandRegion(at line: Int) {\n        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {\n            foldRegions[regionIndex].isFolded = false\n            updateCollapsedLines()\n            \n            if let filePath = currentFilePath {\n                saveFoldState(for: filePath)\n            }\n        }\n    }\n    \n    /// Collapses a region\n    func collapseRegion(at line: Int) {\n        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {\n            foldRegions[regionIndex].isFolded = true\n            updateCollapsedLines()\n            \n            if let filePath = currentFilePath {\n                saveFoldState(for: filePath)\n            }\n        }\n    }\n    \n    /// Expands all folded regions\n    func expandAll() {\n        for index in foldRegions.indices {\n            foldRegions[index].isFolded = false\n        }\n        updateCollapsedLines()\n        \n        if let filePath = currentFilePath {\n            saveFoldState(for: filePath)\n        }\n    }\n    \n    /// Collapses all foldable regions\n    func collapseAll() {\n        for index in foldRegions.indices {\n            foldRegions[index].isFolded = true\n        }\n        updateCollapsedLines()\n        \n        if let filePath = currentFilePath {\n            saveFoldState(for: filePath)\n        }\n    }\n    \n    /// Collapses all regions of a specific type\n    func collapseAll(ofType type: FoldRegion.FoldType) {\n        for index in foldRegions.indices {\n            if foldRegions[index].type == type {\n                foldRegions[index].isFolded = true\n            }\n        }\n        updateCollapsedLines()\n        \n        if let filePath = currentFilePath {\n            saveFoldState(for: filePath)\n        }\n    }\n    \n    /// Expands all regions of a specific type\n    func expandAll(ofType type: FoldRegion.FoldType) {\n        for index in foldRegions.indices {\n            if foldRegions[index].type == type {\n                foldRegions[index].isFolded = false\n            }\n        }\n        updateCollapsedLines()\n        \n        if let filePath = currentFilePath {\n            saveFoldState(for: filePath)\n        }\n    }\n    \n    // MARK: - Query Methods\n    \n    /// Checks if a line is foldable\n    func isFoldable(line: Int) -> Bool {\n        return foldRegions.contains { $0.startLine == line }\n    }\n    \n    /// Checks if a line is currently folded\n    func isLineFolded(line: Int) -> Bool {\n        return collapsedLines.contains(line)\n    }\n    \n    /// Checks if a region at a given line is folded\n    func isRegionFolded(at line: Int) -> Bool {\n        return foldRegions.first { $0.startLine == line }?.isFolded ?? false\n    }\n    \n    /// Gets the fold region at a specific line\n    func getRegion(at line: Int) -> FoldRegion? {\n        return foldRegions.first { $0.startLine == line }\n    }\n    \n    /// Gets all fold regions of a specific type\n    func getRegions(ofType type: FoldRegion.FoldType) -> [FoldRegion] {\n        return foldRegions.filter { $0.type == type }\n    }\n    \n    /// Gets folded line ranges for text hiding\n    /// Returns an array of closed ranges representing the line numbers that should be hidden\n    func getFoldedLineRanges() -> [ClosedRange<Int>] {\n        var ranges: [ClosedRange<Int>] = []\n        \n        // Sort regions by start line to ensure proper ordering\n        let sortedRegions = foldRegions.sorted { $0.startLine < $1.startLine }\n        \n        for region in sortedRegions where region.isFolded {\n            ranges.append((region.startLine + 1)...region.endLine)\n        }\n        \n        return ranges\n    }\n    \n    /// Gets the total count of folded lines\n    func getFoldedLineCount() -> Int {\n        return collapsedLines.count\n    }\n    \n    /// Gets a summary of fold statistics\n    func getFoldStatistics() -> FoldStatistics {\n        let totalCount = foldRegions.count\n        let foldedCount = foldRegions.filter { $0.isFolded }.count\n        \n        var typeBreakdown: [FoldRegion.FoldType: Int] = [:]\n        for region in foldRegions {\n            typeBreakdown[region.type, default: 0] += 1\n        }\n        \n        return FoldStatistics(\n            totalRegions: totalCount,\n            foldedRegions: foldedCount,\n            typeBreakdown: typeBreakdown\n        )\n    }\n    \n    // MARK: - Private Methods\n    \n    private func updateCollapsedLines() {\n        collapsedLines.removeAll()\n        \n        for region in foldRegions where region.isFolded {\n            for line in (region.startLine + 1)...region.endLine {\n                collapsedLines.insert(line)\n            }\n        }\n    }\n}\n\n// MARK: - Fold Statistics\nstruct FoldStatistics {\n    let totalRegions: Int\n    let foldedRegions: Int\n    let typeBreakdown: [FoldRegion.FoldType: Int]\n    \n    var expansionPercentage: Double {\n        guard totalRegions > 0 else { return 0 }\n        return Double(foldedCount) / Double(totalRegions) * 100\n    }\n    \n    var foldedCount: Int {\n        return foldedRegions\n    }\n    \n    var expandedCount: Int {\n        return totalRegions - foldedRegions\n    }\n}\n\n// MARK: - Fold Button View\nstruct FoldButton: View {\n    let line: Int\n    let isExpanded: Bool\n    let foldType: FoldRegion.FoldType?\n    let action: () -> Void\n    \n    var body: some View {\n        Button(action: action) {\n            ZStack {\n                if let type = foldType {\n                    Text(type.icon)\n                        .font(.system(size: 8, weight: .bold))\n                        .foregroundColor(.blue.opacity(0.6))\n                }\n                \n                Image(systemName: isExpanded ? \"chevron.down\" : \"chevron.right\")\n                    .font(.system(size: 10, weight: .semibold))\n                    .foregroundColor(.primary.opacity(0.7))\n            }\n            .frame(width: 18, height: 18)\n            .background(isExpanded ? Color.secondary.opacity(0.1) : Color.secondary.opacity(0.2))\n            .cornerRadius(4)\n        }\n        .buttonStyle(PlainButtonStyle())\n    }\n}\n\n// MARK: - Line Number View with Folding\nstruct LineNumberViewWithFolding: View {\n    let lineNumber: Int\n    let isFoldable: Bool\n    let isExpanded: Bool\n    let foldType: FoldRegion.FoldType?\n    let onFoldTap: () -> Void\n    \n    var body: some View {\n        HStack(spacing: 4) {\n            if isFoldable {\n                FoldButton(\n                    line: lineNumber,\n                    isExpanded: isExpanded,\n                    foldType: foldType,\n                    action: onFoldTap\n                )\n            } else {\n                Color.clear\n                    .frame(width: 18, height: 18)\n            }\n            \n            Text(\"\\(lineNumber + 1)\")\n                .font(.system(.caption, design: .monospaced))\n                .foregroundColor(.gray)\n                .frame(minWidth: 30, alignment: .trailing)\n        }\n    }\n}\n"}
>>>END

I need to use the patch tool to replace the existing file. Let me do that now.

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift
>>>FIND
import SwiftUI

// MARK: - Fold Region Model
struct FoldRegion: Identifiable {
    let id = UUID()
    let startLine: Int
    let endLine: Int
    var isFolded: Bool = false
    let type: FoldType
    
    enum FoldType {
        case function
        case classOrStruct
        case comment
        case block
    }
}

// MARK: - Code Folding Manager
class CodeFoldingManager: ObservableObject {
    @Published var foldRegions: [FoldRegion] = []
    @Published var collapsedLines: Set<Int> = []
    
    func detectFoldableRegions(in code: String) {
        let lines = code.components(separatedBy: .newlines)
        var regions: [FoldRegion] = []
        var blockStack: [(type: FoldRegion.FoldType, startLine: Int)] = []
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Detect function/method start
            if trimmed.contains("func ") && trimmed.contains("{") {
                blockStack.append((.function, index))
            }
            // Detect class/struct start
            else if (trimmed.starts(with: "class ") || trimmed.starts(with: "struct ")) && trimmed.contains("{") {
                blockStack.append((.classOrStruct, index))
            }
            // Detect generic block start
            else if trimmed.hasSuffix("{") {
                blockStack.append((.block, index))
            }
            // Detect block end
            else if trimmed == "}" || trimmed.starts(with: "}") {
                if let lastBlock = blockStack.popLast() {
                    if index - lastBlock.startLine > 1 { // Only create fold for multi-line blocks
                        regions.append(FoldRegion(
                            startLine: lastBlock.startLine,
                            endLine: index,
                            type: lastBlock.type
                        ))
                    }
                }
            }
        }
        
        self.foldRegions = regions
    }
    
    func toggleFold(at line: Int) {
        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
            foldRegions[regionIndex].isFolded.toggle()
            updateCollapsedLines()
        }
    }
    
    func isFoldable(line: Int) -> Bool {
        return foldRegions.contains { $0.startLine == line }
    }
    
    func isLineFolded(line: Int) -> Bool {
        return collapsedLines.contains(line)
    }
    
    private func updateCollapsedLines() {
        collapsedLines.removeAll()
        
        for region in foldRegions where region.isFolded {
            for line in (region.startLine + 1)...region.endLine {
                collapsedLines.insert(line)
            }
        }
    }
    
    func getFoldedText(for region: FoldRegion) -> String {
        return "{ ... }"
    }
}

// MARK: - Fold Button View
struct FoldButton: View {
    let line: Int
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .frame(width: 16, height: 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Line Number View with Folding
struct LineNumberViewWithFolding: View {
    let lineNumber: Int
    let isFoldable: Bool
    let isExpanded: Bool
    let onFoldTap: () -> Void
    
    var body: some View {
        HStack(spacing: 2) {
            if isFoldable {
                FoldButton(line: lineNumber, isExpanded: isExpanded, action: onFoldTap)
            } else {
                Color.clear
                    .frame(width: 16, height: 16)
            }
            
            Text("\(lineNumber + 1)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
                .frame(minWidth: 30, alignment: .trailing)
        }
    }
}
>>>REPLACE
import SwiftUI
import Foundation

// MARK: - Fold Region Model
struct FoldRegion: Identifiable, Codable {
    let id = UUID()
    let startLine: Int
    let endLine: Int
    var isFolded: Bool = false
    let type: FoldType
    let label: String?
    
    enum FoldType: String, Codable {
        case function
        case classOrStruct
        case extension
        case enumDeclaration
        case protocolDeclaration
        case importStatement
        case comment
        case region
        case controlFlow
        case genericBlock
        
        var displayName: String {
            switch self {
            case .function: return "Function"
            case .classOrStruct: return "Class/Struct"
            case .extension: return "Extension"
            case .enumDeclaration: return "Enum"
            case .protocolDeclaration: return "Protocol"
            case .importStatement: return "Import"
            case .comment: return "Comment"
            case .region: return "Region"
            case .controlFlow: return "Control Flow"
            case .genericBlock: return "Block"
            }
        }
        
        var icon: String {
            switch self {
            case .function: return "f"
            case .classOrStruct: return "C"
            case .extension: return "E"
            case .enumDeclaration: return "E"
            case .protocolDeclaration: return "P"
            case .importStatement: return "i"
            case .comment: return "//"
            case .region: return "#"
            case .controlFlow: return "if"
            case .genericBlock: return "{}"
            }
        }
    }
    
    // Exclude id from Codable
    enum CodingKeys: String, CodingKey {
        case startLine, endLine, isFolded, type, label
    }
}

// MARK: - UserDefaults Keys
struct UserDefaultsKeys {
    static let foldStatePrefix = "codeFoldingState_"
}

// MARK: - Code Folding Manager
class CodeFoldingManager: ObservableObject {
    @Published var foldRegions: [FoldRegion] = []
    @Published var collapsedLines: Set<Int> = []
    
    private var currentFilePath: String?
    
    // MARK: - Enhanced Fold Detection
    
    /// Detects all foldable regions in the given code
    func detectFoldableRegions(in code: String, filePath: String? = nil) {
        self.currentFilePath = filePath
        let lines = code.components(separatedBy: .newlines)
        var regions: [FoldRegion] = []
        
        // Track different types of blocks
        var blockStack: [(type: FoldRegion.FoldType, startLine: Int, label: String?)] = []
        var commentStack: [(startLine: Int, isMultiline: Bool)] = []
        var regionStack: [(startLine: Int, label: String)] = []
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let leadingWhitespace = line.prefix { $0 == " " || $0 == "\t" }.count
            
            // Skip empty lines for most detections
            guard !trimmed.isEmpty else { continue }
            
            // MARK: - Region Detection (#region, #pragma mark, MARK:)
            if detectRegionStart(trimmed) != nil {
                if let label = detectRegionStart(trimmed) {
                    regionStack.append((index, label))
                }
            } else if detectRegionEnd(trimmed) {
                if let region = regionStack.popLast() {
                    if index - region.startLine > 1 {
                        regions.append(FoldRegion(
                            startLine: region.startLine,
                            endLine: index,
                            type: .region,
                            label: region.label
                        ))
                    }
                }
            }
            
            // MARK: - Import Statement Detection
            if trimmed.hasPrefix("import ") {
                // Group consecutive imports
                let importEnd = findConsecutiveImports(from: index, in: lines)
                if importEnd > index {
                    regions.append(FoldRegion(
                        startLine: index,
                        endLine: importEnd,
                        type: .importStatement,
                        label: "Imports"
                    ))
                }
            }
            
            // MARK: - Comment Detection
            if detectCommentStart(trimmed) {
                commentStack.append((index, true))
            } else if trimmed.starts(with: "//") {
                // Single-line comment - check for consecutive comment blocks
                let commentEnd = findConsecutiveComments(from: index, in: lines)
                if commentEnd > index {
                    regions.append(FoldRegion(
                        startLine: index,
                        endLine: commentEnd,
                        type: .comment,
                        label: "Comment"
                    ))
                }
            } else if detectCommentEnd(trimmed) {
                if let comment = commentStack.popLast() {
                    if index - comment.startLine > 1 {
                        regions.append(FoldRegion(
                            startLine: comment.startLine,
                            endLine: index,
                            type: .comment,
                            label: "Comment"
                        ))
                    }
                }
            }
            
            // MARK: - Class/Struct/Enum/Protocol/Extension Detection
            if let declaration = detectDeclaration(trimmed) {
                if trimmed.contains("{") {
                    blockStack.append((declaration.type, index, declaration.label))
                } else {
                    // Declaration without opening brace - look ahead for it
                    if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
                        blockStack.append((declaration.type, index, declaration.label))
                    }
                }
            }
            
            // MARK: - Function/Method Detection
            if let functionInfo = detectFunction(trimmed) {
                if trimmed.contains("{") {
                    blockStack.append((.function, index, functionInfo))
                } else {
                    // Function without opening brace - look ahead
                    if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
                        blockStack.append((.function, index, functionInfo))
                    }
                }
            }
            
            // MARK: - Control Flow Detection (if, guard, for, while, switch, etc.)
            if let controlFlowLabel = detectControlFlow(trimmed) {
                if trimmed.contains("{") {
                    blockStack.append((.controlFlow, index, controlFlowLabel))
                } else {
                    if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
                        blockStack.append((.controlFlow, index, controlFlowLabel))
                    }
                }
            }
            
            // MARK: - Generic Block Detection
            if trimmed.hasSuffix("{") && !isDeclarationLine(trimmed) && !isFunctionLine(trimmed) {
                blockStack.append((.genericBlock, index, nil))
            }
            
            // MARK: - Block End Detection
            if detectBlockEnd(trimmed, leadingWhitespace: leadingWhitespace) {
                if let lastBlock = blockStack.popLast() {
                    if index - lastBlock.startLine > 1 {
                        regions.append(FoldRegion(
                            startLine: lastBlock.startLine,
                            endLine: index,
                            type: lastBlock.type,
                            label: lastBlock.label
                        ))
                    }
                }
            }
        }
        
        // Handle any remaining unclosed blocks
        while let lastBlock = blockStack.popLast() {
            if lines.count - 1 - lastBlock.startLine > 1 {
                regions.append(FoldRegion(
                    startLine: lastBlock.startLine,
                    endLine: lines.count - 1,
                    type: lastBlock.type,
                    label: lastBlock.label
                ))
            }
        }
        
        // Sort regions by start line
        regions.sort { $0.startLine < $1.startLine }
        
        self.foldRegions = regions
        
        // Restore previous fold state for this file
        if let filePath = filePath {
            restoreFoldState(for: filePath)
        }
        
        updateCollapsedLines()
    }
    
    // MARK: - Detection Helper Methods
    
    private func detectRegionStart(_ line: String) -> String? {
        // C# / VS style regions
        if line.hasPrefix("#region") {
            let components = line.components(separatedBy: "#region")
            return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Region"
        }
        // Objective-C pragma marks
        if line.hasPrefix("#pragma mark") {
            let components = line.components(separatedBy: "#pragma mark")
            return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
        }
        // Swift MARK comments
        if line.contains("MARK:") {
            let components = line.components(separatedBy: "MARK:")
            return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "Mark"
        }
        // TODO/FIXME regions
        if line.contains("TODO:") {
            let components = line.components(separatedBy: "TODO:")
            return "TODO: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
        }
        if line.contains("FIXME:") {
            let components = line.components(separatedBy: "FIXME:")
            return "FIXME: " + (components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : "")
        }
        return nil
    }
    
    private func detectRegionEnd(_ line: String) -> Bool {
        return line.hasPrefix("#endregion") || 
               line == "// MARK: -" ||
               line.hasPrefix("#pragma mark -")
    }
    
    private func detectCommentStart(_ line: String) -> Bool {
        return line.hasPrefix("/*") && !line.contains("*/")
    }
    
    private func detectCommentEnd(_ line: String) -> Bool {
        return line.contains("*/") && !line.hasPrefix("/*")
    }
    
    private func findConsecutiveImports(from startIndex: Int, in lines: [String]) -> Int {
        var endIndex = startIndex
        for i in startIndex..<lines.count {
            let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("import ") {
                endIndex = i
            } else if !trimmed.isEmpty {
                break
            }
        }
        return endIndex
    }
    
    private func findConsecutiveComments(from startIndex: Int, in lines: [String]) -> Int {
        var endIndex = startIndex
        for i in startIndex..<lines.count {
            let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
            if trimmed.starts(with: "//") {
                endIndex = i
            } else if !trimmed.isEmpty {
                break
            }
        }
        return endIndex
    }
    
    private func detectDeclaration(_ line: String) -> (type: FoldRegion.FoldType, label: String)? {
        // Class detection
        if let className = extractName(from: line, prefix: "class", visibility: ["public", "private", "internal", "fileprivate", "open", "final"]) {
            return (.classOrStruct, className)
        }
        // Struct detection
        if let structName = extractName(from: line, prefix: "struct", visibility: ["public", "private", "internal", "fileprivate"]) {
            return (.classOrStruct, structName)
        }
        // Enum detection
        if let enumName = extractName(from: line, prefix: "enum", visibility: ["public", "private", "internal", "fileprivate", "indirect"]) {
            return (.enumDeclaration, enumName)
        }
        // Protocol detection
        if let protocolName = extractName(from: line, prefix: "protocol", visibility: ["public", "private", "internal", "fileprivate"]) {
            return (.protocolDeclaration, protocolName)
        }
        // Extension detection
        if let extensionName = extractName(from: line, prefix: "extension", visibility: []) {
            return (.extension, extensionName)
        }
        return nil
    }
    
    private func detectFunction(_ line: String) -> String? {
        // Function detection with visibility modifiers
        let visibilityKeywords = ["public", "private", "internal", "fileprivate", "static", "class", "override", "final", "mutating", "convenience"]
        
        // Check for 'func' keyword
        if line.contains("func ") {
            // Extract function name
            let funcPattern = "func\\s+(\\w+)"
            if let regex = try? NSRegularExpression(pattern: funcPattern),
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let nameRange = Range(match.range(at: 1), in: line) {
                let functionName = String(line[nameRange])
                // Check for parameters to create label
                if let parenStart = line.firstIndex(of: "("), let parenEnd = line.firstIndex(of: ")") {
                    let params = String(line[parenStart...parenEnd])
                    return "\(functionName)\(params)"
                }
                return functionName
            }
        }
        
        // Init detection
        if let initName = extractName(from: line, prefix: "init", visibility: visibilityKeywords) {
            return "\(initName)"
        }
        
        // Deinit detection
        if line.contains("deinit") {
            return "deinit"
        }
        
        // Computed property with get/set
        if line.hasPrefix("var ") && (line.contains("{") || line.contains("get")) {
            if let varName = extractVariableName(from: line) {
                return varName
            }
        }
        
        return nil
    }
    
    private func detectControlFlow(_ line: String) -> String? {
        let controlFlowPatterns = [
            ("if ", "if"),
            ("guard ", "guard"),
            ("else if", "else if"),
            ("else", "else"),
            ("for ", "for"),
            ("while ", "while"),
            ("repeat", "repeat"),
            ("switch ", "switch"),
            ("case ", "case"),
            ("default:", "default"),
            ("do ", "do"),
            ("catch", "catch")
        ]
        
        for (pattern, label) in controlFlowPatterns {
            if line.contains(pattern) {
                return label
            }
        }
        return nil
    }
    
    private func extractName(from line: String, prefix: String, visibility: [String]) -> String? {
        var components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        // Remove visibility modifiers
        components = components.filter { !visibility.contains($0) }
        
        // Find prefix index
        if let prefixIndex = components.firstIndex(where: { $0 == prefix }),
           prefixIndex + 1 < components.count {
            var name = components[prefixIndex + 1]
            // Remove colons and other trailing characters
            name = name.components(separatedBy: ":").first ?? name
            name = name.components(separatedBy: "<").first ?? name
            name = name.components(separatedBy: ":").first ?? name
            return name
        }
        return nil
    }
    
    private func extractVariableName(from line: String) -> String? {
        let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if components.count >= 2, components[0] == "var" {
            var varName = components[1]
            varName = varName.components(separatedBy: ":").first ?? varName
            varName = varName.components(separatedBy: "=").first ?? varName
            return varName
        }
        return nil
    }
    
    private func findOpeningBrace(from startIndex: Int, in lines: [String]) -> Int? {
        for i in startIndex..<min(startIndex + 5, lines.count) {
            if lines[i].contains("{") {
                return i
            }
        }
        return nil
    }
    
    private func isDeclarationLine(_ line: String) -> Bool {
        let keywords = ["class", "struct", "enum", "protocol", "extension", "init", "func"]
        return keywords.contains { line.contains("\($0) ") }
    }
    
    private func isFunctionLine(_ line: String) -> Bool {
        return line.contains("func ") || line.contains("init ")
    }
    
    private func detectBlockEnd(_ line: String, leadingWhitespace: Int) -> Bool {
        return (line.hasPrefix("}") || line.starts(with: "}")) && 
               (line.trimmingCharacters(in: .whitespaces) == "}" || 
                line.trimmingCharacters(in: .whitespaces).hasPrefix("}"))
    }
    
    // MARK: - Fold State Persistence
    
    /// Saves the current fold state to UserDefaults
    func saveFoldState(for filePath: String) {
        let key = UserDefaultsKeys.foldStatePrefix + filePath
        
        // Create a simplified representation for storage
        let foldState = foldRegions.map { [
            "startLine": $0.startLine,
            "isFolded": $0.isFolded
        ] }
        
        if let data = try? JSONEncoder().encode(foldState) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    /// Restores fold state from UserDefaults
    private func restoreFoldState(for filePath: String) {
        let key = UserDefaultsKeys.foldStatePrefix + filePath
        
        guard let data = UserDefaults.standard.data(forKey: key),
              let foldState = try? JSONDecoder().decode([[String: Any]].self, from: data) else {
            return
        }
        
        // Apply saved state to current regions
        for savedState in foldState {
            if let startLine = savedState["startLine"] as? Int,
               let isFolded = savedState["isFolded"] as? Bool,
               let index = foldRegions.firstIndex(where: { $0.startLine == startLine }) {
                foldRegions[index].isFolded = isFolded
            }
        }
    }
    
    /// Clears fold state for a specific file
    func clearFoldState(for filePath: String) {
        let key = UserDefaultsKeys.foldStatePrefix + filePath
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    /// Clears all fold states
    func clearAllFoldStates() {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(UserDefaultsKeys.foldStatePrefix) }
        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }
    
    // MARK: - Fold Operations
    
    /// Toggles the fold state at a specific line
    func toggleFold(at line: Int) {
        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
            foldRegions[regionIndex].isFolded.toggle()
            updateCollapsedLines()
            
            // Save state after toggling
            if let filePath = currentFilePath {
                saveFoldState(for: filePath)
            }
        }
    }
    
    /// Expands a folded region
    func expandRegion(at line: Int) {
        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
            foldRegions[regionIndex].isFolded = false
            updateCollapsedLines()
            
            if let filePath = currentFilePath {
                saveFoldState(for: filePath)
            }
        }
    }
    
    /// Collapses a region
    func collapseRegion(at line: Int) {
        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
            foldRegions[regionIndex].isFolded = true
            updateCollapsedLines()
            
            if let filePath = currentFilePath {
                saveFoldState(for: filePath)
            }
        }
    }
    
    /// Expands all folded regions
    func expandAll() {
        for index in foldRegions.indices {
            foldRegions[index].isFolded = false
        }
        updateCollapsedLines()
        
        if let filePath = currentFilePath {
            saveFoldState(for: filePath)
        }
    }
    
    /// Collapses all foldable regions
    func collapseAll() {
        for index in foldRegions.indices {
            foldRegions[index].isFolded = true
        }
        updateCollapsedLines()
        
        if let filePath = currentFilePath {
            saveFoldState(for: filePath)
        }
    }
    
    /// Collapses all regions of a specific type
    func collapseAll(ofType type: FoldRegion.FoldType) {
        for index in foldRegions.indices {
            if foldRegions[index].type == type {
                foldRegions[index].isFolded = true
            }
        }
        updateCollapsedLines()
        
        if let filePath = currentFilePath {
            saveFoldState(for: filePath)
        }
    }
    
    /// Expands all regions of a specific type
    func expandAll(ofType type: FoldRegion.FoldType) {
        for index in foldRegions.indices {
            if foldRegions[index].type == type {
                foldRegions[index].isFolded = false
            }
        }
        updateCollapsedLines()
        
        if let filePath = currentFilePath {
            saveFoldState(for: filePath)
        }
    }
    
    // MARK: - Query Methods
    
    /// Checks if a line is foldable
    func isFoldable(line: Int) -> Bool {
        return foldRegions.contains { $0.startLine == line }
    }
    
    /// Checks if a line is currently folded
    func isLineFolded(line: Int) -> Bool {
        return collapsedLines.contains(line)
    }
    
    /// Checks if a region at a given line is folded
    func isRegionFolded(at line: Int) -> Bool {
        return foldRegions.first { $0.startLine == line }?.isFolded ?? false
    }
    
    /// Gets the fold region at a specific line
    func getRegion(at line: Int) -> FoldRegion? {
        return foldRegions.first { $0.startLine == line }
    }
    
    /// Gets all fold regions of a specific type
    func getRegions(ofType type: FoldRegion.FoldType) -> [FoldRegion] {
        return foldRegions.filter { $0.type == type }
    }
    
    /// Gets folded line ranges for text hiding
    /// Returns an array of closed ranges representing the line numbers that should be hidden
    func getFoldedLineRanges() -> [ClosedRange<Int>] {
        var ranges: [ClosedRange<Int>] = []
        
        // Sort regions by start line to ensure proper ordering
        let sortedRegions = foldRegions.sorted { $0.startLine < $1.startLine }
        
        for region in sortedRegions where region.isFolded {
            ranges.append((region.startLine + 1)...region.endLine)
        }
        
        return ranges
    }
    
    /// Gets the total count of folded lines
    func getFoldedLineCount() -> Int {
        return collapsedLines.count
    }
    
    /// Gets a summary of fold statistics
    func getFoldStatistics() -> FoldStatistics {
        let totalCount = foldRegions.count
        let foldedCount = foldRegions.filter { $0.isFolded }.count
        
        var typeBreakdown: [FoldRegion.FoldType: Int] = [:]
        for region in foldRegions {
            typeBreakdown[region.type, default: 0] += 1
        }
        
        return FoldStatistics(
            totalRegions: totalCount,
            foldedRegions: foldedCount,
            typeBreakdown: typeBreakdown
        )
    }
    
    // MARK: - Private Methods
    
    private func updateCollapsedLines() {
        collapsedLines.removeAll()
        
        for region in foldRegions where region.isFolded {
            for line in (region.startLine + 1)...region.endLine {
                collapsedLines.insert(line)
            }
        }
    }
}

// MARK: - Fold Statistics
struct FoldStatistics {
    let totalRegions: Int
    let foldedRegions: Int
    let typeBreakdown: [FoldRegion.FoldType: Int]
    
    var expansionPercentage: Double {
        guard totalRegions > 0 else { return 0 }
        return Double(foldedCount) / Double(totalRegions) * 100
    }
    
    var foldedCount: Int {
        return foldedRegions
    }
    
    var expandedCount: Int {
        return totalRegions - foldedRegions
    }
}

// MARK: - Fold Button View
struct FoldButton: View {
    let line: Int
    let isExpanded: Bool
    let foldType: FoldRegion.FoldType?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if let type = foldType {
                    Text(type.icon)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.blue.opacity(0.6))
                }
                
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.primary.opacity(0.7))
            }
            .frame(width: 18, height: 18)
            .background(isExpanded ? Color.secondary.opacity(0.1) : Color.secondary.opacity(0.2))
            .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Line Number View with Folding
struct LineNumberViewWithFolding: View {
    let lineNumber: Int
    let isFoldable: Bool
    let isExpanded: Bool
    let foldType: FoldRegion.FoldType?
    let onFoldTap: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            if isFoldable {
                FoldButton(
                    line: lineNumber,
                    isExpanded: isExpanded,
                    foldType: foldType,
                    action: onFoldTap
                )
            } else {
                Color.clear
                    .frame(width: 18, height: 18)
            }
            
            Text("\(lineNumber + 1)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
                .frame(minWidth: 30, alignment: .trailing)
        }
    }
}
>>>END

Let me verify the file was updated correctly by reading it.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 1, "end_line": 50}
>>>END

Let me verify the key sections of the rewritten file to confirm all features are implemented.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 400, "end_line": 480}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 520, "end_line": 620}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 615, "end_line": 670}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 200, "end_line": 280}
>>>END

Perfect! I've successfully rewritten the CodeFoldingManager.swift file with all requested enhancements. Let me provide a comprehensive summary.

>>>REPORT
Successfully rewritten VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift (742 lines) with the following major enhancements:

## 1) Enhanced Fold Detection

### New Fold Types Added (Lines 13-23):
- **.extension** - Extension declarations
- **.enumDeclaration** - Enum declarations  
- **.protocolDeclaration** - Protocol declarations
- **.importStatement** - Import statements
- **.region** - Code regions (#region, MARK:, TODO:, FIXME:)
- **.controlFlow** - Control flow blocks (if, guard, for, while, switch, etc.)
- **.genericBlock** - Generic code blocks

### Detection Capabilities (Lines 150-320):
- **Functions**: Detects with visibility modifiers (public, private, internal, fileprivate, static, class, override, final, mutating, convenience)
- **Classes/Structs/Enums/Protocols/Extensions**: Full detection with visibility modifiers
- **Import Statements**: Groups consecutive imports together
- **Comments**: Detects both multiline (/* */) and consecutive single-line (//) comment blocks
- **Regions**: Supports #region, #pragma mark, MARK:, TODO:, FIXME:
- **Control Flow**: if, guard, else, for, while, repeat, switch, case, default, do, catch
- Each foldable region now includes a label for better identification

## 2) Fold State Persistence (Lines 446-505)

### UserDefaults Integration:
- **saveFoldState(for:)** - Saves current fold state to UserDefaults with file path as key (lines 448-461)
- **restoreFoldState(for:)** - Restores previous fold state when reopening a file (lines 463-480)
- **clearFoldState(for:)** - Clears state for a specific file (lines 482-485)
- **clearAllFoldStates()** - Clears all saved fold states (lines 487-495)
- Uses `UserDefaultsKeys.foldStatePrefix + filePath` as unique key per file
- Automatically persists state on fold operations (toggle, expand, collapse)

## 3) Collapse All / Expand All Methods (Lines 536-586)

- **expandAll()** (lines 537-546) - Expands all folded regions
- **collapseAll()** (lines 549-558) - Collapses all foldable regions
- **expandAll(ofType:)** (lines 574-586) - Expands all regions of specific type
- **collapseAll(ofType:)** (lines 560-572) - Collapses all regions of specific type
- **expandRegion(at:)** (lines 512-522) - Expands a specific region
- **collapseRegion(at:)** (lines 524-534) - Collapses a specific region
- All operations automatically persist state

## 4) Get Folded Line Ranges for Text Hiding (Lines 617-628)

- **getFoldedLineRanges()** (lines 617-628) - Returns `[ClosedRange<Int>]` of line numbers to hide
- Excludes the start line (header remains visible)
- Returns sorted ranges for proper text rendering
- **getFoldedLineCount()** (lines 630-633) - Returns total count of folded lines

## Additional Enhancements:

### Enhanced FoldButton (Lines 695-720):
- Now shows type icons (f, C, E, P, i, //, #, if, {})
- Improved visual styling with background colors
- Larger tap target (18x18)

### FoldStatistics Struct (Lines 665-685):
- Tracks total regions, folded/expanded counts
- Provides type breakdown
- Calculates expansion percentage

### Improved Detection Helpers:
- Regex-based function name extraction (lines 338-353)
- Visibility modifier handling (lines 377-395)
- Look-ahead for opening braces (lines 422-429)
- Consecutive block detection for imports/comments (lines 277-295)
>>>END
