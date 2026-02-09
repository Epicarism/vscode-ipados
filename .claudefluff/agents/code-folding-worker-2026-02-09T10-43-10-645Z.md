# Agent: code-folding-worker
**Status:** done
**Tokens:** 7,094
**Cost:** $0.0000
**Time:** 2026-02-09T10:43:10.645Z

## Task
Add Fold All / Unfold All functionality to VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift:
1. Add `func foldAll()` method that sets isFolded=true for all regions and updates collapsedLines
2. Add `func unfoldAll()` method that sets isFolded=false for all regions and clears collapsedLines
3. Add `func foldLevel(_ level: Int)` to fold blocks at a specific nesting level
4. Track nesting level in FoldRegion struct
5. Update detectFoldableRegions to calculate nesting levels
6. Add these commands to the command palette in ContentView.swift

## Response
>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift"}
>>>END

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/ContentView.swift"}
>>>END

Let me search for the CommandPaletteView that's being used:

>>>TOOL search
{"query": "struct CommandPaletteView", "glob": "*.swift"}
>>>END

>>>TOOL search
{"query": "CommandPaletteView", "glob": "*.swift"}
>>>END

>>>TOOL search
{"query": "CommandPalette", "glob": "*.swift"}
>>>END

Let me search for where CommandPaletteView is defined:

>>>TOOL search
{"query": "CommandPaletteView", "glob": "*.swift"}
>>>END

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS"}
>>>END

I can see from the ContentView.swift I already read that there's an `IDECommandPalette` struct at lines 542-569 that contains the command rows. However, line 65 references `CommandPaletteView` which might be defined elsewhere. Since I can only modify the two specified files, I'll:

1. Update CodeFoldingManager.swift with the new functionality
2. Add fold commands to `IDECommandPalette` in ContentView.swift

Let me start with the CodeFoldingManager.swift update:

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
>>>REPLACE
import SwiftUI

// MARK: - Fold Region Model
struct FoldRegion: Identifiable {
    let id = UUID()
    let startLine: Int
    let endLine: Int
    var isFolded: Bool = false
    let type: FoldType
    let nestingLevel: Int
    
    enum FoldType {
        case function
        case classOrStruct
        case comment
        case block
    }
}
>>>END

Now update the detectFoldableRegions method to track nesting levels:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift
>>>FIND
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
>>>REPLACE
    func detectFoldableRegions(in code: String) {
        let lines = code.components(separatedBy: .newlines)
        var regions: [FoldRegion] = []
        var blockStack: [(type: FoldRegion.FoldType, startLine: Int, nestingLevel: Int)] = []
        var currentNestingLevel = 0
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Detect function/method start
            if trimmed.contains("func ") && trimmed.contains("{") {
                blockStack.append((.function, index, currentNestingLevel))
                currentNestingLevel += 1
            }
            // Detect class/struct start
            else if (trimmed.starts(with: "class ") || trimmed.starts(with: "struct ")) && trimmed.contains("{") {
                blockStack.append((.classOrStruct, index, currentNestingLevel))
                currentNestingLevel += 1
            }
            // Detect generic block start
            else if trimmed.hasSuffix("{") {
                blockStack.append((.block, index, currentNestingLevel))
                currentNestingLevel += 1
            }
            // Detect block end
            else if trimmed == "}" || trimmed.starts(with: "}") {
                if let lastBlock = blockStack.popLast() {
                    currentNestingLevel = max(0, currentNestingLevel - 1)
                    if index - lastBlock.startLine > 1 { // Only create fold for multi-line blocks
                        regions.append(FoldRegion(
                            startLine: lastBlock.startLine,
                            endLine: index,
                            type: lastBlock.type,
                            nestingLevel: lastBlock.nestingLevel
                        ))
                    }
                }
            }
        }
        
        self.foldRegions = regions
    }
>>>END

Now add the foldAll, unfoldAll, and foldLevel methods:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift
>>>FIND
    func toggleFold(at line: Int) {
        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
            foldRegions[regionIndex].isFolded.toggle()
            updateCollapsedLines()
        }
    }
>>>REPLACE
    func toggleFold(at line: Int) {
        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
            foldRegions[regionIndex].isFolded.toggle()
            updateCollapsedLines()
        }
    }
    
    /// Folds all foldable regions
    func foldAll() {
        for index in foldRegions.indices {
            foldRegions[index].isFolded = true
        }
        updateCollapsedLines()
    }
    
    /// Unfolds all foldable regions
    func unfoldAll() {
        for index in foldRegions.indices {
            foldRegions[index].isFolded = false
        }
        collapsedLines.removeAll()
    }
    
    /// Folds all blocks at a specific nesting level
    /// - Parameter level: The nesting level to fold (0 = top level, 1 = nested once, etc.)
    func foldLevel(_ level: Int) {
        for index in foldRegions.indices {
            if foldRegions[index].nestingLevel == level {
                foldRegions[index].isFolded = true
            }
        }
        updateCollapsedLines()
    }
    
    /// Unfolds all blocks at a specific nesting level
    /// - Parameter level: The nesting level to unfold
    func unfoldLevel(_ level: Int) {
        for index in foldRegions.indices {
            if foldRegions[index].nestingLevel == level {
                foldRegions[index].isFolded = false
            }
        }
        updateCollapsedLines()
    }
    
    /// Returns the maximum nesting level in the current document
    var maxNestingLevel: Int {
        foldRegions.map { $0.nestingLevel }.max() ?? 0
    }
>>>END

Now let me update the IDECommandPalette in ContentView.swift to add the fold commands. First I need to make the foldingManager accessible. Looking at the code, the foldingManager is local to IDEEditorView. We need to add fold commands to the command palette. Let me update the IDECommandPalette struct:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
struct IDECommandPalette: View {
    @ObservedObject var editorCore: EditorCore
    @Binding var showSettings: Bool
    @Binding var showTerminal: Bool
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
            }.padding().background(Color(UIColor.secondarySystemBackground))
            Divider()
            ScrollView {
                VStack(spacing: 0) {
                    CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
                    CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
                    CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
                    CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
                    CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
                    CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
                    CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
                    CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
                }.padding(.vertical, 8)
            }
        }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
    }
}
>>>REPLACE
struct IDECommandPalette: View {
    @ObservedObject var editorCore: EditorCore
    @Binding var showSettings: Bool
    @Binding var showTerminal: Bool
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Type a command...", text: $searchText).textFieldStyle(.plain)
            }.padding().background(Color(UIColor.secondarySystemBackground))
            Divider()
            ScrollView {
                VStack(spacing: 0) {
                    CommandRow(icon: "doc.badge.plus", name: "New File", shortcut: "⌘N") { editorCore.addTab(); editorCore.showCommandPalette = false }
                    CommandRow(icon: "folder", name: "Open File", shortcut: "⌘O") { editorCore.showFilePicker = true; editorCore.showCommandPalette = false }
                    CommandRow(icon: "square.and.arrow.down", name: "Save File", shortcut: "⌘S") { editorCore.saveActiveTab(); editorCore.showCommandPalette = false }
                    CommandRow(icon: "sidebar.left", name: "Toggle Sidebar", shortcut: "⌘B") { editorCore.toggleSidebar(); editorCore.showCommandPalette = false }
                    CommandRow(icon: "brain", name: "AI Assistant", shortcut: "⌘⇧A") { editorCore.showAIAssistant = true; editorCore.showCommandPalette = false }
                    CommandRow(icon: "terminal", name: "Toggle Terminal", shortcut: "⌘`") { showTerminal.toggle(); editorCore.showCommandPalette = false }
                    CommandRow(icon: "gear", name: "Settings", shortcut: "⌘,") { showSettings = true; editorCore.showCommandPalette = false }
                    CommandRow(icon: "number", name: "Go to Line", shortcut: "⌘G") { editorCore.showGoToLine = true; editorCore.showCommandPalette = false }
                    // Code Folding Commands
                    CommandRow(icon: "chevron.down.square", name: "Fold All", shortcut: "⌘K ⌘0") { 
                        NotificationCenter.default.post(name: .foldAllRegions, object: nil)
                        editorCore.showCommandPalette = false 
                    }
                    CommandRow(icon: "chevron.up.square", name: "Unfold All", shortcut: "⌘K ⌘J") { 
                        NotificationCenter.default.post(name: .unfoldAllRegions, object: nil)
                        editorCore.showCommandPalette = false 
                    }
                    CommandRow(icon: "1.square", name: "Fold Level 1", shortcut: "⌘K ⌘1") { 
                        NotificationCenter.default.post(name: .foldLevel, object: 0)
                        editorCore.showCommandPalette = false 
                    }
                    CommandRow(icon: "2.square", name: "Fold Level 2", shortcut: "⌘K ⌘2") { 
                        NotificationCenter.default.post(name: .foldLevel, object: 1)
                        editorCore.showCommandPalette = false 
                    }
                    CommandRow(icon: "3.square", name: "Fold Level 3", shortcut: "⌘K ⌘3") { 
                        NotificationCenter.default.post(name: .foldLevel, object: 2)
                        editorCore.showCommandPalette = false 
                    }
                }.padding(.vertical, 8)
            }
        }.frame(width: 500, height: 400).background(Color(UIColor.systemBackground)).cornerRadius(12).shadow(radius: 20)
    }
}
>>>END

Now add the notification names at the top of ContentView.swift:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Helper Functions
// Moved to Extensions/FileHelpers.swift
>>>REPLACE
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Notification Names for Code Folding
extension Notification.Name {
    static let foldAllRegions = Notification.Name("foldAllRegions")
    static let unfoldAllRegions = Notification.Name("unfoldAllRegions")
    static let foldLevel = Notification.Name("foldLevel")
}

// MARK: - Helper Functions
// Moved to Extensions/FileHelpers.swift
>>>END

Now update IDEEditorView to listen for these notifications:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/ContentView.swift
>>>FIND
        .onAppear {
            text = tab.content
            foldingManager.detectFoldableRegions(in: text)
        }
        .onChange(of: tab.id) { _ in
            text = tab.content
            foldingManager.detectFoldableRegions(in: text)
        }
        .onChange(of: currentLineNumber) { line in
            editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
        }
        .onChange(of: currentColumn) { col in
            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
        }
    }
>>>REPLACE
        .onAppear {
            text = tab.content
            foldingManager.detectFoldableRegions(in: text)
        }
        .onChange(of: tab.id) { _ in
            text = tab.content
            foldingManager.detectFoldableRegions(in: text)
        }
        .onChange(of: currentLineNumber) { line in
            editorCore.cursorPosition = CursorPosition(line: line, column: currentColumn)
        }
        .onChange(of: currentColumn) { col in
            editorCore.cursorPosition = CursorPosition(line: currentLineNumber, column: col)
        }
        .onReceive(NotificationCenter.default.publisher(for: .foldAllRegions)) { _ in
            foldingManager.foldAll()
        }
        .onReceive(NotificationCenter.default.publisher(for: .unfoldAllRegions)) { _ in
            foldingManager.unfoldAll()
        }
        .onReceive(NotificationCenter.default.publisher(for: .foldLevel)) { notification in
            if let level = notification.object as? Int {
                foldingManager.foldLevel(level)
            }
        }
    }
>>>END

>>>REPORT
## Summary

I've successfully added Fold All / Unfold All functionality to the codebase:

### Changes to `VSCodeiPadOS/VSCodeiPadOS/Services/CodeFoldingManager.swift`:

1. **Added `nestingLevel` property to `FoldRegion` struct** (line 9) - Tracks the nesting depth of each foldable region.

2. **Updated `detectFoldableRegions()` method** - Now tracks nesting level as blocks are opened and closed using a modified `blockStack` that includes the nesting level.

3. **Added new methods:**
   - `foldAll()` - Sets `isFolded=true` for all regions and updates `collapsedLines`
   - `unfoldAll()` - Sets `isFolded=false` for all regions and clears `collapsedLines`
   - `foldLevel(_ level: Int)` - Folds all blocks at a specific nesting level (0=top level)
   - `unfoldLevel(_ level: Int)` - Unfolds blocks at a specific level
   - `maxNestingLevel` computed property - Returns the deepest nesting level found

### Changes to `VSCodeiPadOS/VSCodeiPadOS/ContentView.swift`:

1. **Added Notification.Name extensions** (lines 4-9) - Defined notification names for fold commands:
   - `.foldAllRegions`
   - `.unfoldAllRegions`
   - `.foldLevel`

2. **Added folding commands to `IDECommandPalette`** (lines 565-580) - Added 5 new command rows:
   - "Fold All" (⌘K ⌘0)
   - "Unfold All" (⌘K ⌘J)
   - "Fold Level 1" (⌘K ⌘1)
   - "Fold Level 2" (⌘K ⌘2)
   - "Fold Level 3" (⌘K ⌘3)

3. **Added notification observers in `IDEEditorView`** - The editor now listens for fold notifications and calls the appropriate `foldingManager` methods.

### Architecture Note:
Since the `foldingManager` is local to each `IDEEditorView` instance, I used `NotificationCenter` to communicate fold commands from the command palette to the active editor. This is a common pattern in SwiftUI when views need to communicate without direct references.
>>>END
