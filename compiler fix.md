# Swift Compiler Error Fix Plan

## 🚨 THE PROBLEM

**Error Location:** `VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift:294`

**Error Message:**
```
error: the compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions
    var body: some View {
                        ^
```

## 🔬 ROOT CAUSE ANALYSIS

The `SearchView` struct has a `body` property that spans approximately **380+ lines** (lines 294-676). This is a classic Swift type-checker complexity explosion issue.

### Why This Happens:
1. **SwiftUI's View Builder** uses result builders that require the compiler to infer types across the entire expression
2. **Exponential complexity** - each nested view/conditional doubles type inference work
3. **The body contains:**
   - Deeply nested VStacks/HStacks/ZStacks
   - Multiple `if/else` conditionals
   - `ForEach` loops with complex closures
   - Inline computed properties and method calls
   - ~15+ view modifiers chained together

## ✅ FIX STRATEGY

### Phase 1: Extract Major Sections into Sub-Views (CRITICAL)

Break the monolithic `body` into these separate components:

| New Component | Lines to Extract | Description |
|--------------|------------------|-------------|
| `SearchHeaderView` | 296-336 | Title bar with SEARCH label, regex indicator, clear button |
| `SearchInputSection` | 341-505 | Search/replace text fields with toggle icons |
| `SearchProgressSection` | 534-548 | Progress indicator during search |
| `FileFilterSection` | 550-587 | Files to include/exclude inputs |
| `SearchResultsSection` | 599-650 | Results list with grouping logic |

### Phase 2: Use @ViewBuilder Helper Functions

Convert inline conditionals to extracted functions:

```swift
// BEFORE (causes type explosion):
var body: some View {
    VStack {
        if showReplace {
            // 50 lines of replace UI
        }
        if useRegex {
            // 30 lines of regex help
        }
        // ... hundreds more lines
    }
}

// AFTER (compiles fast):
var body: some View {
    VStack {
        searchHeader
        searchInputSection
        if showReplace { replaceSection }
        if useRegex { regexHelpSection }
        resultsSection
    }
}

@ViewBuilder
private var searchHeader: some View {
    // 40 lines max
}

@ViewBuilder  
private var replaceSection: some View {
    // 50 lines max
}
```

### Phase 3: Add Explicit Type Annotations

Help the compiler with explicit types where inference is complex:

```swift
// BEFORE:
let _ = NotificationCenter.default.publisher(for: .collapseAllSearchResults)
    .sink { _ in isExpanded = false }

// AFTER:
let _: AnyCancellable = NotificationCenter.default.publisher(for: .collapseAllSearchResults)
    .sink { _ in isExpanded = false }
```

## 📋 DETAILED TASK LIST FOR AGENTS

### Agent 1: Extract Search Header (OPUS)
**File:** `SearchView.swift`
**Task:** Extract lines 296-336 into a new `@ViewBuilder private var searchHeader: some View`

### Agent 2: Extract Search Input Section (OPUS)
**File:** `SearchView.swift`  
**Task:** Extract lines 341-505 into a new `@ViewBuilder private var searchInputSection: some View`

### Agent 3: Extract Replace Section (OPUS)
**File:** `SearchView.swift`
**Task:** Extract the replace TextField and buttons (lines 474-505) into `@ViewBuilder private var replaceSection: some View`

### Agent 4: Extract Results Section (OPUS)
**File:** `SearchView.swift`
**Task:** Extract lines 593-650 into `@ViewBuilder private var resultsSection: some View`

### Agent 5: Create Final Refactored Body (OPUS)
**File:** `SearchView.swift`
**Task:** Assemble the new slim `body` that calls all extracted components

## 🎯 TARGET ARCHITECTURE

```swift
struct SearchView: View {
    // ... properties stay the same ...
    
    var body: some View {
        VStack(spacing: 0) {
            searchHeader
            ScrollView {
                VStack(spacing: 12) {
                    searchInputSection
                    Divider()
                    resultsSection
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
        .onChange(of: processedResults) { _ in
            navigationItems = buildNavigationItems()
        }
    }
    
    // MARK: - Extracted View Sections
    
    @ViewBuilder
    private var searchHeader: some View {
        // ~40 lines - Header with title and clear button
    }
    
    @ViewBuilder
    private var searchInputSection: some View {
        // ~80 lines - Search field, replace field, toggle icons
    }
    
    @ViewBuilder
    private var searchButtonRow: some View {
        // ~25 lines - Search button and result count
    }
    
    @ViewBuilder
    private var fileFilterSection: some View {
        // ~40 lines - Include/exclude file patterns
    }
    
    @ViewBuilder
    private var resultsSection: some View {
        // ~50 lines - Results list with grouping
    }
}
```

## ⚠️ RULES FOR AGENTS

1. **Each @ViewBuilder section should be <100 lines**
2. **Don't change functionality** - only restructure
3. **Preserve all @State, @Binding, and other property wrappers**
4. **Keep keyboard shortcuts attached to the main body**
5. **Test compilation after each extraction**

## 🔧 EXECUTION ORDER

1. **First:** Create backup of SearchView.swift
2. **Second:** Extract smallest/simplest sections first (searchHeader)
3. **Third:** Extract larger sections (searchInputSection)
4. **Fourth:** Refactor the conditional sections (replace, regex help)
5. **Fifth:** Extract results section
6. **Sixth:** Assemble final body and verify compilation

## 📊 EXPECTED OUTCOME

- **Before:** 380+ line body, compiler times out
- **After:** ~30 line body calling 6-8 extracted sections
- **Compile time:** Should drop from "infinite" to <5 seconds

## 🚀 SPAWN COMMAND FOR COORDINATOR

```json
{
  "agents": [
    {
      "name": "search-view-refactor",
      "task": "Refactor SearchView.swift body into smaller @ViewBuilder sections. Extract: 1) searchHeader (lines 296-336), 2) searchInputSection (lines 341-505), 3) resultsSection (lines 593-650). Keep each section under 100 lines. Preserve all functionality.",
      "tools": "read_write",
      "model": "opus",
      "files": ["VSCodeiPadOS/VSCodeiPadOS/Views/Panels/SearchView.swift"]
    }
  ],
  "silent": true
}
```
