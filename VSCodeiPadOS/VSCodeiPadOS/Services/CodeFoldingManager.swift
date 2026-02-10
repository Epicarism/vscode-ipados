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
        case `extension`
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
    static let shared = CodeFoldingManager()
    
    @Published var foldRegions: [FoldRegion] = []
    @Published var collapsedLines: Set<Int> = []
    
    // Dictionary to manage fold regions per file
    private var foldRegionsByFile: [String: [FoldRegion]] = [:]
    
    private var currentFilePath: String?
    private var currentFileId: String?
    
    // MARK: - Enhanced Fold Detection
    
    /// Detects all foldable regions in the given code
    func detectFoldableRegions(in code: String, filePath: String? = nil) {
        self.currentFilePath = filePath
        self.currentFileId = filePath
        
        let lines = code.components(separatedBy: .newlines)
        var regions: [FoldRegion] = []
        
        // Track different types of blocks
        var blockStack: [(type: FoldRegion.FoldType, startLine: Int, label: String?)] = []
        var commentStack: [(startLine: Int, isMultiline: Bool)] = []
        var regionStack: [(startLine: Int, label: String)] = []

        // If we detect a declaration/function/control-flow whose opening brace is on a later line,
        // we mark that brace line so it won't be treated as a standalone generic block.
        var braceLinesClaimed: Set<Int> = []

        // Used to prevent duplicate regions for grouped constructs (imports, // comments)
        var previousNonEmptyWasImport = false
        var previousNonEmptyWasSingleLineComment = false
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let leadingWhitespace = line.prefix { $0 == " " || $0 == "\t" }.count
            
            // Skip empty lines for most detections
            guard !trimmed.isEmpty else { continue }

            // MARK: - Close blocks BEFORE opening new ones (handles "} else {" correctly)
            if trimmed.hasPrefix("}") {
                // Count consecutive leading '}' so we can pop multiple blocks for lines like "}}"
                let closeCount = max(1, trimmed.prefix { $0 == "}" }.count)
                for _ in 0..<closeCount {
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
            
            // MARK: - Region Detection (#region, #pragma mark, MARK:)
            if let label = detectRegionStart(trimmed) {
                regionStack.append((index, label))
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
            
            // MARK: - Import Statement Detection (group consecutive imports once)
            if trimmed.hasPrefix("import ") {
                if !previousNonEmptyWasImport {
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
                previousNonEmptyWasImport = true
            } else {
                previousNonEmptyWasImport = false
            }
            
            // MARK: - Comment Detection
            if detectCommentStart(trimmed) {
                commentStack.append((index, true))
                previousNonEmptyWasSingleLineComment = false
            } else if trimmed.starts(with: "//") {
                // Only create a fold region at the start of a consecutive // block
                if !previousNonEmptyWasSingleLineComment {
                    let commentEnd = findConsecutiveComments(from: index, in: lines)
                    if commentEnd > index {
                        regions.append(FoldRegion(
                            startLine: index,
                            endLine: commentEnd,
                            type: .comment,
                            label: "Comment"
                        ))
                    }
                }
                previousNonEmptyWasSingleLineComment = true
            } else if detectCommentEnd(trimmed) {
                previousNonEmptyWasSingleLineComment = false
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
            } else {
                previousNonEmptyWasSingleLineComment = false
            }
            
            // MARK: - Class/Struct/Enum/Protocol/Extension Detection
            if let declaration = detectDeclaration(trimmed) {
                if trimmed.contains("{") {
                    blockStack.append((declaration.type, index, declaration.label))
                } else {
                    // Declaration without opening brace - look ahead for it
                    if let braceLine = findOpeningBrace(from: index + 1, in: lines) {
                        braceLinesClaimed.insert(braceLine)
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
                        braceLinesClaimed.insert(braceLine)
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
                        braceLinesClaimed.insert(braceLine)
                        blockStack.append((.controlFlow, index, controlFlowLabel))
                    }
                }
            }
            
            // MARK: - Generic Block Detection
            // Avoid adding a generic block for a standalone "{" that belongs to a previously detected declaration.
            if trimmed.hasSuffix("{"),
               trimmed != "{",
               !braceLinesClaimed.contains(index),
               !isDeclarationLine(trimmed),
               !isFunctionLine(trimmed) {
                blockStack.append((.genericBlock, index, nil))
            }

            _ = leadingWhitespace // keep param for potential future heuristics
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
        
        // Store regions in the per-file dictionary
        if let fileId = currentFileId {
            foldRegionsByFile[fileId] = regions
        }
        
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
        func matchName(pattern: String) -> String? {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
            guard let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                  match.numberOfRanges >= 2,
                  let r = Range(match.range(at: 1), in: line)
            else { return nil }
            return String(line[r])
        }

        // Allow leading attributes like "@MainActor", "@available(...)"
        // Allow common modifiers in any order (best-effort).
        let prefix = #"^(?:\s*@\w+(?:\([^\)]*\))?\s+)*(?:\s*(?:public|private|internal|fileprivate|open|final|indirect|lazy|static|override|mutating|nonmutating)\s+)*"#

        // IMPORTANT: avoid treating "class func"/"class var" as a type declaration.
        if let name = matchName(pattern: prefix + #"class\s+(?!func\b|var\b|let\b)([A-Za-z_]\w*)"#) {
            return (.classOrStruct, name)
        }

        // Actor (Swift concurrency) – fold like a class/struct
        if let name = matchName(pattern: prefix + #"actor\s+([A-Za-z_]\w*)"#) {
            return (.classOrStruct, name)
        }

        if let name = matchName(pattern: prefix + #"struct\s+([A-Za-z_]\w*)"#) {
            return (.classOrStruct, name)
        }

        if let name = matchName(pattern: prefix + #"enum\s+([A-Za-z_]\w*)"#) {
            return (.enumDeclaration, name)
        }

        if let name = matchName(pattern: prefix + #"protocol\s+([A-Za-z_]\w*)"#) {
            return (.protocolDeclaration, name)
        }

        // Extensions can include dotted names (Foo.Bar)
        if let name = matchName(pattern: prefix + #"extension\s+([A-Za-z_][A-Za-z0-9_\.]*)"#) {
            return (.extension, name)
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
        
        // Use regions from the dictionary if available
        let regionsToSave: [FoldRegion]
        if let fileId = currentFileId, let storedRegions = foldRegionsByFile[fileId] {
            regionsToSave = storedRegions
        } else {
            regionsToSave = foldRegions
        }
        
        // Create a simplified representation for storage
        let foldState = regionsToSave.map { FoldStateEntry(startLine: $0.startLine, isFolded: $0.isFolded) }
        
        if let data = try? JSONEncoder().encode(foldState) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    /// Restores fold state from UserDefaults
    private func restoreFoldState(for filePath: String) {
        let key = UserDefaultsKeys.foldStatePrefix + filePath
        
        guard let data = UserDefaults.standard.data(forKey: key),
              let foldState = try? JSONDecoder().decode([FoldStateEntry].self, from: data) else {
            return
        }
        
        // Apply saved state to current regions
        for savedState in foldState {
            if let index = foldRegions.firstIndex(where: { $0.startLine == savedState.startLine }) {
                foldRegions[index].isFolded = savedState.isFolded
            }
        }
    }
    
    /// Helper struct for persisting fold state
    private struct FoldStateEntry: Codable {
        let startLine: Int
        let isFolded: Bool
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
    
    /// Folds the region containing the given cursor line
    func foldAtLine(_ cursorLine: Int) {
        // Find the innermost region containing this line
        if let region = foldRegions.filter({ 
            cursorLine >= $0.startLine && cursorLine <= $0.endLine && !$0.isFolded
        }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
            collapseRegion(at: region.startLine)
        }
    }
    
    /// Unfolds the region containing the given cursor line
    func unfoldAtLine(_ cursorLine: Int) {
        // Find any folded region that starts at or contains this line
        if let region = foldRegions.first(where: { 
            $0.isFolded && ($0.startLine == cursorLine || (cursorLine >= $0.startLine && cursorLine <= $0.endLine))
        }) {
            expandRegion(at: region.startLine)
        }
    }
    
    /// Toggle fold at cursor line - convenience method
    func toggleFoldAtLine(_ cursorLine: Int) {
        // First check if we're on a fold start line
        if let region = foldRegions.first(where: { $0.startLine == cursorLine }) {
            toggleFold(at: region.startLine)
            return
        }
        
        // Otherwise find the innermost region containing this line
        if let region = foldRegions.filter({ 
            cursorLine >= $0.startLine && cursorLine <= $0.endLine
        }).min(by: { ($0.endLine - $0.startLine) < ($1.endLine - $1.startLine) }) {
            toggleFold(at: region.startLine)
        }
    }
    
    // MARK: - Legacy/Convenience Methods (for keyboard shortcuts)
    
    /// Folds at the current line (uses line 0 as fallback - caller should use foldAtLine(_:) with actual cursor)
    func foldCurrentLine() {
        // This is called from keyboard shortcuts - fold at line 0 or first available region
        if let firstUnfolded = foldRegions.first(where: { !$0.isFolded }) {
            collapseRegion(at: firstUnfolded.startLine)
        }
    }
    
    /// Unfolds at the current line (uses line 0 as fallback - caller should use unfoldAtLine(_:) with actual cursor)
    func unfoldCurrentLine() {
        // This is called from keyboard shortcuts - unfold first folded region
        if let firstFolded = foldRegions.first(where: { $0.isFolded }) {
            expandRegion(at: firstFolded.startLine)
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
    
    /// Checks if a line is currently folded (for the currently active file in `foldRegions`)
    func isLineFolded(line: Int) -> Bool {
        return collapsedLines.contains(line)
    }

    /// Checks if a line should be hidden for a specific file (does not rely on `collapsedLines`)
    func isLineFolded(fileId: String, line: Int) -> Bool {
        guard let regions = foldRegionsByFile[fileId] else { return false }
        for region in regions where region.isFolded {
            if line > region.startLine && line <= region.endLine {
                return true
            }
        }
        return false
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
    
    // MARK: - File-Aware Methods
    
    /// Checks if a line is foldable for a specific file
    func isFoldable(fileId: String, line: Int) -> Bool {
        guard let regions = foldRegionsByFile[fileId] else { return false }
        return regions.contains { $0.startLine == line }
    }
    
    /// Checks if a region at a given line is folded for a specific file
    func isFolded(fileId: String, line: Int) -> Bool {
        guard let regions = foldRegionsByFile[fileId] else { return false }
        return regions.first { $0.startLine == line }?.isFolded ?? false
    }
    
    /// Toggles the fold state at a specific line for a specific file
    func toggleFold(fileId: String, line: Int) {
        guard var regions = foldRegionsByFile[fileId] else { return }
        
        if let regionIndex = regions.firstIndex(where: { $0.startLine == line }) {
            regions[regionIndex].isFolded.toggle()
            foldRegionsByFile[fileId] = regions
            
            // Update current file regions if this is the active file
            if fileId == currentFileId {
                self.foldRegions = regions
                updateCollapsedLines()
            } else {
                // Ensure SwiftUI updates for gutters rendering using file-aware queries.
                objectWillChange.send()
            }
            
            // Save state after toggling
            saveFoldState(for: fileId)
        }
    }
    
    /// Gets fold regions for a specific file
    func getFoldRegions(for fileId: String) -> [FoldRegion] {
        return foldRegionsByFile[fileId] ?? []
    }
    
    /// Clears fold regions for a specific file from memory
    func clearFoldRegions(for fileId: String) {
        foldRegionsByFile.removeValue(forKey: fileId)
    }
    
    /// Clears all fold regions from memory
    func clearAllFoldRegions() {
        foldRegionsByFile.removeAll()
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
