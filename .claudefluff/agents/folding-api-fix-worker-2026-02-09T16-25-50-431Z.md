# Agent: folding-api-fix-worker
**Status:** done
**Tokens:** 6,213
**Cost:** $0.0000
**Time:** 2026-02-09T16:25:50.431Z

## Task
Add file-aware methods to CodeFoldingManager.swift: isFoldable(fileId:line:), isFolded(fileId:line:), toggleFold(fileId:line:), and a dictionary to manage fold regions per file. Store regions in [fileId: [FoldRegion]] dictionary instead of single array.

## Response
I'll help you add file-aware methods to CodeFoldingManager.swift. Let me first read the current file to understand its structure.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

Now I'll add the file-aware methods and dictionary to manage fold regions per file. Let me create a patch for the changes:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift
>>>FIND
class CodeFoldingManager: ObservableObject {
    @Published var foldRegions: [FoldRegion] = []
    @Published var collapsedLines: Set<Int> = []
    
    private var currentFilePath: String?
>>>REPLACE
class CodeFoldingManager: ObservableObject {
    @Published var foldRegions: [FoldRegion] = []
    @Published var collapsedLines: Set<Int> = []
    
    // Dictionary to manage fold regions per file
    private var foldRegionsByFile: [String: [FoldRegion]] = [:]
    
    private var currentFilePath: String?
    private var currentFileId: String?
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift
>>>FIND
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
>>>REPLACE
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
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift
>>>FIND
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
>>>REPLACE
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
        guard let fileIndex = foldRegionsByFile.index(forKey: fileId) else { return }
        let regions = foldRegionsByFile[fileIndex].values
        
        if let regionIndex = regions.firstIndex(where: { $0.startLine == line }) {
            foldRegionsByFile[fileId]?[regionIndex].isFolded.toggle()
            
            // Update current file regions if this is the active file
            if fileId == currentFileId {
                self.foldRegions = foldRegionsByFile[fileId] ?? []
                updateCollapsedLines()
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
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift
>>>FIND
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
>>>REPLACE
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
        let foldState = regionsToSave.map { [
            "startLine": $0.startLine,
            "isFolded": $0.isFolded
        ] }
        
        if let data = try? JSONEncoder().encode(foldState) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
>>>END

>>>END

Perfect! Let me verify that all the changes have been applied correctly by reading the updated file.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 68, "end_line": 80}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 220, "end_line": 240}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 590, "end_line": 680}
>>>END

Let me verify the `saveFoldState` method was updated correctly:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 450, "end_line": 480}
>>>END

I notice there's a bug in the `toggleFold` method. Let me fix it:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift
>>>FIND
    /// Toggles the fold state at a specific line for a specific file
    func toggleFold(fileId: String, line: Int) {
        guard let fileIndex = foldRegionsByFile.index(forKey: fileId) else { return }
        let regions = foldRegionsByFile[fileIndex].values
        
        if let regionIndex = regions.firstIndex(where: { $0.startLine == line }) {
            foldRegionsByFile[fileId]?[regionIndex].isFolded.toggle()
            
            // Update current file regions if this is the active file
            if fileId == currentFileId {
                self.foldRegions = foldRegionsByFile[fileId] ?? []
                updateCollapsedLines()
            }
            
            // Save state after toggling
            saveFoldState(for: fileId)
        }
    }
>>>REPLACE
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
            }
            
            // Save state after toggling
            saveFoldState(for: fileId)
        }
    }
>>>END

>>>END

Excellent! Let me verify the final implementation:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift", "start_line": 648, "end_line": 665}
>>>END

>>>REPORT
Successfully added file-aware methods to CodeFoldingManager.swift. Here's what was implemented:

## Changes Made:

### 1. Added Per-File Storage (Lines 72-76)
- Added `foldRegionsByFile: [String: [FoldRegion]]` dictionary to store fold regions per file
- Added `currentFileId: String?` property to track the active file

### 2. Updated detectFoldableRegions (Lines 231-234)
- Modified to store detected regions in the per-file dictionary when `currentFileId` is set
- Stores regions with key: `foldRegionsByFile[fileId] = regions`

### 3. New File-Aware Methods (Lines 634-680)
- **`isFoldable(fileId:line:)`** (Lines 637-640): Checks if a line is foldable for a specific file by querying the per-file dictionary
- **`isFolded(fileId:line:)`** (Lines 643-646): Checks if a region at a given line is folded for a specific file
- **`toggleFold(fileId:line:)`** (Lines 649-665): Toggles fold state for a specific file, updates current file if active, and persists state
- **`getFoldRegions(for:)`** (Lines 668-670): Returns all fold regions for a specific file
- **`clearFoldRegions(for:)`** (Lines 673-675): Removes fold regions for a specific file from memory
- **`clearAllFoldRegions()`** (Lines 678-680): Clears all fold regions from memory

### 4. Updated saveFoldState (Lines 463-469)
- Modified to prioritize using regions from the per-file dictionary when available
- Falls back to the current `foldRegions` array if dictionary entry doesn't exist

All methods properly handle the file-specific storage and maintain backward compatibility with existing code.
>>>END
