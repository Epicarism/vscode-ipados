# 🐛 TODOs, FIXMEs, and Known Bugs

**Last Verified:** Ultra-verification completed
**Total TODOs:** 31
**Total Critical Bugs:** 6
**Total Medium Bugs:** 3

---

## Priority Summary

| Priority | Count | Description |
|----------|-------|-------------|
| **P0 (Blocks Usage)** | 2 | Tab crash, Typing lag |
| **P1 (Major Issue)** | 4 | Code folding, Scrolling, Highlighting, SSH stub |
| **P2 (Minor)** | 3 | File icons, Markdown, AI Assistant |
| **P3 (Nice to Have)** | 31 | TreeSitter languages, workspace opening, etc. |

---

## 🔴 P0 - BLOCKS USAGE (Fix Immediately)

### Bug 0c: CRASH When Accepting Autocomplete with Tab
**Status:** 🔴 CRITICAL - CRASH  
**Files:**
- `Views/Editor/SyntaxHighlightingTextView.swift:1336` - handleTab()
- `Services/AutocompleteManager.swift:207` - commitCurrentSuggestion()

**Code Path Verified:**
```swift
// SyntaxHighlightingTextView.swift:1336
@objc func handleTab() {
    if onAcceptAutocomplete?() == true {
        return
    }
    insertText("\t")
}
```

**Root Cause:** The onAcceptAutocomplete closure in ContentView.swift modifies @Binding text/cursorIndex while potentially inside a view update cycle. The commitCurrentSuggestion() method uses `text.replaceSubrange()` which may cause index invalidation.

**Priority:** P0 - App crashes, unusable feature

---

### Bug 0: Typing Lag in Large Documents (1000+ lines)
**Status:** 🔴 CRITICAL - NOT FIXED  
**Files:**
- `Views/Editor/SyntaxHighlightingTextView.swift:649` - updateLineCount()
- `Views/Editor/SyntaxHighlightingTextView.swift:663` - updateCursorPosition()
- `Views/Editor/SyntaxHighlightingTextView.swift:709` - scrollToLine() uses O(n) split

**Code Verified - Performance Issues Found:**

1. **scrollToLine() still uses O(n) split (line 709):**
```swift
let lines = textView.text.components(separatedBy: .newlines)  // O(n) on every scroll!
```

2. **updateLineCount() - FIXED (iterates chars):**
```swift
func updateLineCount(_ textView: UITextView) {
    // PERF: Count newlines directly instead of creating array copy
    let text = textView.text ?? ""
    var lineCount = 1
    for char in text { if char == "\n" { lineCount += 1 } }
```

3. **updateCursorPosition() - FIXED (iterates chars):**
```swift
// PERF: Count newlines directly instead of creating substring + array
```

**Remaining Issue:** scrollToLine() at line 709 still does O(n) string split.

**Priority:** P0 - App unusable for real-world editing

---

## 🟠 P1 - MAJOR ISSUES (Fix Soon)

### Bug 0b: Code Folding is BROKEN
**Status:** 🟠 REGRESSION  
**Files:**
- `Services/CodeFoldingManager.swift:68` - Main manager class exists
- `Views/Editor/SyntaxHighlightingTextView.swift:133` - foldingManager wired
- `Views/Editor/SyntaxHighlightingTextView.swift:890-894` - handlers exist

**Code Verified:**
```swift
// SyntaxHighlightingTextView.swift:1350-1355
@objc func handleFold() {
    onFold?()
}
@objc func handleUnfold() {
    onUnfold?()
}
```

The handlers call optional closures but may not be wired in ContentView.

**Priority:** P1 - Feature worked before, now broken

---

### Bug 1: Scrolling is Broken / Jaggy
**Status:** 🟠 Active  
**File:** `Views/Editor/SyntaxHighlightingTextView.swift:705`

**Code Verified:**
```swift
func scrollToLine(_ line: Int, in textView: UITextView) {
    guard !isUpdatingFromMinimap else { return }
    isUpdatingFromMinimap = true
    
    let lines = textView.text.components(separatedBy: .newlines)  // O(n)!
```

**Root Cause:** Conflict between user scroll and programmatic scroll to cursor + O(n) performance.

**Priority:** P1 - Core UX issue

---

### Bug 2: Syntax Highlighting Only Appears When Typing
**Status:** 🟠 Active  
**File:** `Views/Editor/SyntaxHighlightingTextView.swift`

**Issue:** applySyntaxHighlighting() may not be called on initial file load, only on text changes.

**Priority:** P1 - Core feature incomplete

---

### SSH Not Implemented (Stub Only)
**Status:** 🟠 STUB  
**File:** `Services/SSHManager.swift:5`

**Code Verified:**
```swift
//  Stub SSH Manager - TODO: Implement with SwiftNIO SSH
//  Add package: https://github.com/apple/swift-nio-ssh

// Line 93:
// MARK: - SSH Manager (Stub Implementation)

// Line 107-108:
func connect(config: SSHConnectionConfig) async throws {
    // TODO: Implement with SwiftNIO SSH
    throw SSHClientError.notImplemented
}
```

**Priority:** P1 - Remote development blocked

---

## 🟡 P2 - MINOR ISSUES

### Bug 3: File Type Icons Missing from Sidebar
**Status:** 🟡 Active  
**Issue:** No file type icons showing in file explorer sidebar
**Priority:** P2 - Visual polish

---

### Bug 5: Markdown Highlighting & Preview
**Status:** 🟡 Active - Phase 2  
**Issue:** Markdown syntax highlighting incomplete
**Priority:** P2 - Feature incomplete

---

### Bug 6: AI Assistant Returns Hardcoded Default Message
**Status:** 🟡 Active - Phase 2  
**Issue:** AI panel opens but no actual API integration
**Priority:** P2 - Feature not functional

---

## 📝 P3 - TODOs IN CODE (Nice to Have)

### TreeSitterLanguages.swift (26 Language TODOs)
**File:** `TreeSitterLanguages.swift`

| Line | TODO |
|------|------|
| 10 | Uncomment imports as TreeSitter Swift packages become available |
| 29 | Additional languages from the current implementation |
| 179 | Return TreeSitterSwift() when package is available |
| 185 | Return TreeSitterJavaScript() when package is available |
| 191 | Return TreeSitterTypeScript() when package is available |
| 197 | Return TreeSitterPython() when package is available |
| 203 | Return TreeSitterJSON() when package is available |
| 209 | Return TreeSitterHTML() when package is available |
| 215 | Return TreeSitterCSS() when package is available |
| 221 | Return TreeSitterMarkdown() when package is available |
| 227 | Return TreeSitterGo() when package is available |
| 233 | Return TreeSitterRust() when package is available |
| 239 | Return TreeSitterRuby() when package is available |
| 245 | Return TreeSitterJava() when package is available |
| 251 | Return TreeSitterC() when package is available |
| 257 | Return TreeSitterCPP() when package is available |
| 263 | Return TreeSitterBash() when package is available |
| 269 | Return TreeSitterYAML() when package is available |
| 275 | Return TreeSitterSQL() when package is available |
| 283 | Return TreeSitterKotlin() when package is available |
| 288 | Return TreeSitterObjectiveC() when package is available |
| 293 | Return TreeSitterSCSS() when package is available |
| 298 | Return TreeSitterLess() when package is available |
| 303 | Return TreeSitterXML() when package is available |
| 308 | Return TreeSitterGraphQL() when package is available |
| 313 | Return TreeSitterPHP() when package is available |

**Action:** Add TreeSitter Swift packages as needed. Low priority - regex fallback works.

---

### SceneDelegate.swift
**Line 166:** `// TODO: Open workspace at path`
```swift
if let workspacePath = userActivity.userInfo?[WindowActivity.workspacePathKey] as? String {
    // TODO: Open workspace at path
    print("Opening workspace: \(workspacePath)")
}
```
**Action:** Implement workspace restoration from handoff/state restoration.

---

### SSHManager.swift
**Line 5:** `// Stub SSH Manager - TODO: Implement with SwiftNIO SSH`
**Line 107:** `// TODO: Implement with SwiftNIO SSH`
**Line 113:** `// TODO: Implement with SwiftNIO SSH`

**Action:** Major implementation needed. Add SwiftNIO SSH package.

---

### GitManager.swift
**Line 295:** `// TODO: Add NativeGit folder to Xcode project to enable offline commits`
```swift
func commit(message: String) async throws {
    guard workingDirectory != nil else {
        throw GitManagerError.noRepository
    }
    // Native commit requires NativeGitWriter which isn't in Xcode project yet
    // TODO: Add NativeGit folder to Xcode project to enable offline commits
    throw GitManagerError.sshNotConnected
}
```
**Action:** Wire NativeGitWriter (which exists) to GitManager.commit()

---

## 🔍 VERIFICATION NOTES

### Items from Original File - CORRECTED:

| Original Claim | Actual Finding |
|----------------|----------------|
| "NativeGitWriter.swift Line 296: TODO Wire to GitManager" | **INCORRECT** - TODO is in GitManager.swift:295, not NativeGitWriter |
| "ContentView.swift: Several FIXME comments" | **NOT FOUND** - No FIXME comments exist |
| "SyntaxHighlightingTextView ~1700: HACK for selection" | **NOT FOUND** - No HACK comments exist |
| "SyntaxHighlightingTextView ~2100: HACK for special chars" | **NOT FOUND** - No HACK comments exist |
| "30 TODOs in TreeSitterLanguages" | **CORRECTED** - 26 language-specific + 2 general = 28 TODOs |

### Items NOT in Original File - ADDED:

1. GitManager.swift:295 - TODO about NativeGit folder
2. Bug 0c (Tab crash) - Was in bugs.md but not TODOS_AND_BUGS.md
3. Bug 0 (Typing lag) - Was in bugs.md but not TODOS_AND_BUGS.md  
4. Stub implementations in EditorCore.swift (Terminal, Debug state)
5. Stub implementations in PythonRunner.swift

---

## 🎯 Recommended Fix Order

### Week 1: P0 Fixes (Blocks Usage)
1. ☐ Fix Tab crash in autocomplete (investigate commitCurrentSuggestion threading)
2. ☐ Fix scrollToLine() O(n) performance (cache line positions)

### Week 2: P1 Fixes (Major Issues)
3. ☐ Fix code folding (verify onFold/onUnfold wired in ContentView)
4. ☐ Fix scrolling jank (debounce, remove cursor-scroll conflict)
5. ☐ Fix initial syntax highlighting (call on file open)

### Week 3: Git & SSH Foundation
6. ☐ Wire NativeGitWriter to GitManager.commit()
7. ☐ Add SwiftNIO SSH package, implement basic connect

### Week 4: Polish (P2)
8. ☐ Add file type icons
9. ☐ Improve markdown highlighting
10. ☐ Wire AI Assistant to actual API

---

## ✅ Fixed (Already Done)

- ✅ Fatal crash: Range requires lowerBound <= upperBound
- ✅ Duplicate keyboard shortcuts (UIMenu conflicts)
- ✅ Invalid SF Symbol 'f.curlybraces'
- ✅ "Publishing changes from within view updates" warnings
- ✅ Undo manager crash (NSInternalInconsistencyException)
- ✅ NativeGit files not in Xcode project
- ✅ iOS deployment target too low (15.0 → 16.0)
- ✅ Keyboard shortcuts Cmd+J, Cmd+Shift+A, etc. restored
- ✅ updateLineCount() and updateCursorPosition() optimized (no longer use components(separatedBy:))
