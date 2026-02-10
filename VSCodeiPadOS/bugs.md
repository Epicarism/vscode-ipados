# Known Bugs - VSCodeiPadOS

## 🔴 Critical

### 0. Typing Lag in Large Documents - STILL BROKEN
**Status:** 🔴 CRITICAL - NOT FIXED  
**Symptoms:**
- Typing is STILL ultra laggy/slow in documents with ~1000+ lines
- App becomes unusable for real-world code editing
- Even with visible-range highlighting fix, still too slow

**Fixes Attempted (NOT ENOUGH):**
- Adaptive debounce (80ms-1.5s based on file size)
- Background thread highlighting
- Visible-range-only highlighting for large files

**Root Cause (from performance audit):**
- `components(separatedBy:)` runs O(n) on EVERY keystroke in updateLineCount/updateCursorPosition
- `applySyntaxHighlighting` called 8 TIMES on file open
- TextKit 1 compatibility mode triggered (performance penalty)
- Matching bracket highlight scans entire document

**MUST FIX:**
- Cache line count, don't recalculate on every keystroke
- Defer cursor position updates
- Remove TextKit 1 fallback / migrate to TextKit 2
- Disable bracket matching for large files

---

### 0c. CRASH When Accepting Autocomplete with Tab
**Status:** 🔴 CRITICAL - CRASH  
**Symptoms:**
- App CRASHES when pressing Tab to accept autocomplete suggestion
- Reproduction: Type "imp" to trigger autocomplete, press Tab to accept
- App terminates and returns to home screen

**Likely Cause:**
- Tab key handler in handleTab() may be crashing
- Autocomplete insertion logic issue
- Check AutocompleteManager or handleTab in EditorTextView

**Files to investigate:**
- `Views/Editor/SyntaxHighlightingTextView.swift` - handleTab()
- `Services/AutocompleteManager.swift`

---

### 0b. Code Folding is BROKEN
**Status:** 🔴 CRITICAL - REGRESSION  
**Symptoms:**
- Code folding used to work, now it's broken
- Cmd+Opt+[ (fold) and Cmd+Opt+] (unfold) not working
- Fold indicators may not be showing

**Likely Cause:**
- Recent changes may have broken CodeFoldingManager
- EditorTextView changes may have affected fold rendering
- Check if fold regions are being calculated

**Files to investigate:**
- `Services/CodeFoldingManager.swift`
- `Views/Editor/SyntaxHighlightingTextView.swift` - handleFold/handleUnfold
- Check if folding UI is being rendered

---

### 1. Scrolling is Broken / Jaggy
**Status:** Active  
**Symptoms:**
- Scrolling fights with the current line view
- If cursor is on a different line, editor wants to keep that line in focus
- Results in jaggy/jumpy scrolling behavior

**Likely Cause:**
- `scrollToLine()` or cursor position tracking in SyntaxHighlightingTextView
- `updateUIView` may be resetting scroll position on every update
- Conflict between user scroll and programmatic scroll to cursor

**Files to investigate:**
- `SyntaxHighlightingTextView.swift` - scrollToLine, updateScrollPosition
- `ContentView.swift` - scrollPosition binding
- MinimapView scroll sync

---

### 2. Syntax Highlighting Only Appears When Typing
**Status:** Active  
**Symptoms:**
- Syntax highlighting doesn't appear on file open
- Only shows up after user starts typing
- Even then, highlighting is inconsistent/partial

**Likely Cause:**
- `applySyntaxHighlighting()` not called on initial load
- Highlighting may be getting cleared/overwritten
- Theme not applied until text changes trigger delegate

**Files to investigate:**
- `SyntaxHighlightingTextView.swift` - makeUIView, applySyntaxHighlighting
- When/how highlighting is triggered on file load vs on edit

---

### 3. File Type Icons Missing from Sidebar
**Status:** Active  
**Symptoms:**
- No file type icons showing in file explorer sidebar
- VS Code style icons for html, js, json, md, swift, etc. not visible

**Expected:**
- Downloaded VS Code icons should display next to filenames
- Different icons for different file extensions

**Files to investigate:**
- FileNavigator / FileExplorerView
- Assets.xcassets - check if icons were added
- Icon mapping logic

---

### 4. Keyboard Shortcuts Were Broken (Cmd+J, Cmd+Shift+A, etc.)
**Status:** ✅ FIXED  
**What happened:**
- Accidentally removed UIKeyCommands thinking they were duplicates
- UITextView captures keyboard, so UIKeyCommands ARE needed there
- Restored all shortcuts: Cmd+J, Cmd+Shift+A, Cmd+B, Cmd+P, Cmd+S, Cmd+W, Cmd+F, Cmd+N, Cmd+=, Cmd+-

---

## 🟡 Medium Priority (Phase 2/3)

### 5. Markdown Highlighting & Preview
**Status:** Active - Phase 2  
**Symptoms:**
- Markdown syntax highlighting is wrong/incomplete
- Headers, bold, italic, code blocks, links not properly styled
- Need VS Code quality markdown highlighting
- Consider adding live markdown preview panel (like VS Code's Cmd+Shift+V)

**Expected:**
- Perfect markdown highlighting matching VS Code
- Optional: Split view with live preview
- Support for: headers, bold, italic, strikethrough, code blocks, links, lists, tables

**Files to investigate:**
- `Extensions/NSAttributedStringSyntaxHighlighter.swift` - add markdown rules
- `Views/Editor/MarkdownPreviewView.swift` - exists but may need work
- Consider GFM (GitHub Flavored Markdown) support

---

### 6. AI Assistant Returns Hardcoded Default Message
**Status:** Active - Phase 2  
**Symptoms:**
- AI Assistant panel opens but replies with same default message over and over
- Not actually connecting to AI backend or processing input
- Model list is OUTDATED (needs current models: Claude 3.5, GPT-4o, etc.)

**Likely Cause:**
- Hardcoded placeholder response in AIManager or AIAssistantView
- No actual API integration implemented yet
- Model list is static/hardcoded

**Files to investigate:**
- `Services/AIManager.swift` - check for API calls vs hardcoded responses
- `Views/Panels/AIAssistantView.swift` - check response handling
- Update model list to current options

---

### 6. Multi-cursor / Selection State Sync
**Status:** Active  
**Notes:** EditorCore.multiCursorState needs to stay in sync with UITextView selection

---

## 🟢 Fixed (This Session)

- ✅ Fatal crash: Range requires lowerBound <= upperBound
- ✅ Duplicate keyboard shortcuts (UIMenu conflicts)
- ✅ Invalid SF Symbol 'f.curlybraces'
- ✅ "Publishing changes from within view updates" warnings - wrapped @Binding updates in DispatchQueue.main.async
- ✅ Undo manager crash (NSInternalInconsistencyException: enableUndoRegistration invalid state) - added reentrancy guard and defer pattern
- ✅ NativeGit files not in Xcode project - added NativeGitReader.swift and NativeGitWriter.swift to build
- ✅ iOS deployment target too low (15.0) - updated to iOS 16.0 for scrollDisabled() API

---

## Notes

Last updated: 2026-02-10
