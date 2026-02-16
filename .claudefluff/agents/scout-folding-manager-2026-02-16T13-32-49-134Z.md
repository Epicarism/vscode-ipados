# Agent: scout-folding-manager
**Status:** done
**Tokens:** 857
**Cost:** $0.0000
**Time:** 2026-02-16T13:32:49.134Z

## Task
Read CodeFoldingManager.swift completely. Report: 1) How folds are stored, 2) What toggleFold does, 3) How it communicates fold state to the editor, 4) Any notifications or bindings used.

## Response


>>>REPORT
## CodeFoldingManager.swift Analysis

### 1) How Folds Are Stored

**In-Memory Storage:**
- **`foldRegions: [FoldRegion]`** (line 77) - `@Published` array of `FoldRegion` structs for the currently active file
- **`foldRegionsByFile: [String: [FoldRegion]]`** (line 81) - Dictionary mapping file identifiers to their fold regions
- **`collapsedLines: Set<Int>`** (line 78) - `@Published` set of line numbers currently hidden due to folding

**FoldRegion Model (lines 5-60):**
```swift
struct FoldRegion: Identifiable, Codable {
    let id = UUID()
    let startLine: Int
    let endLine: Int
    var isFolded: Bool = false
    let type: FoldType
    let label: String?
}
```

**Persistence (lines 516-574):**
- Fold states saved to `UserDefaults` with key prefix `"codeFoldingState_"` + filePath
- Uses `FoldStateEntry` helper struct (lines 556-559) storing only `startLine` and `isFolded`
- Full serialization via `JSONEncoder`/`JSONDecoder`

### 2) What toggleFold Does

**`toggleFold(at line: Int)` (lines 579-589):**
1. Finds region index where `startLine == line`
2. Toggles `isFolded` boolean: `foldRegions[regionIndex].isFolded.toggle()`
3. Calls `updateCollapsedLines()` to recalculate hidden lines
4. Saves state to UserDefaults via `saveFoldState(for: currentFilePath)`

**File-aware variant `toggleFold(fileId:line:)` (lines 774-793):**
- Operates on `foldRegionsByFile[fileId]` dictionary
- Syncs to `foldRegions` if `fileId == currentFileId`
- Calls `objectWillChange.send()` for non-active files to trigger SwiftUI updates

### 3) How It Communicates Fold State to the Editor

**Primary Mechanisms:**
1. **`@Published` properties** - SwiftUI auto-subscribes to `foldRegions` and `collapsedLines` changes
2. **`NotificationCenter`** (line 859): Posts `.codeFoldingDidChange` notification after `updateCollapsedLines()`
3. **Query methods for editors:**
   - `isLineFolded(line:)` / `isLineFolded(fileId:line:)` - checks if line is in `collapsedLines`
   - `getFoldedLineRanges()` (lines 812-823) - returns `[ClosedRange<Int>]` of hidden line ranges
   - `isFoldable(line:)` / `isFoldable(fileId:line:)` - checks if line can be folded
   - `getRegion(at:)` / `getFoldRegions(for:)` - retrieves region data

### 4) Notifications and Bindings Used

**Notification (lines 68-70):**
```swift
extension Notification.Name {
    static let codeFoldingDidChange = Notification.Name("codeFoldingDidChange")
}
```
- Posted in `updateCollapsedLines()` (line 859)
- Observed by `FoldingLayoutManager` (per comment on line 858)

**SwiftUI Bindings:**
- `@Published var foldRegions: [FoldRegion]` - array of all fold regions
- `@Published var collapsedLines: Set<Int>` - set of currently hidden line numbers
- Conforms to `ObservableObject` (line 73)
- Uses `objectWillChange.send()` explicitly for cross-file updates (line 787)

**Singleton Pattern:**
- `static let shared = CodeFoldingManager()` (line 75)

**UI Components (lines 884-940):**
- `FoldButton` - SwiftUI View for fold toggle UI
- `LineNumberViewWithFolding` - combines fold button with line number display
>>>END
