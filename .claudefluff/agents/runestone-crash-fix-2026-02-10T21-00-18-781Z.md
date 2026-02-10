# Agent: runestone-crash-fix
**Status:** done
**Tokens:** 4,545
**Cost:** $0.0000
**Time:** 2026-02-10T21:00:18.781Z

## Task
The crash is at Runestone/TextEditHelper.swift:27 - a force unwrap on lineManager.linePosition(). Read RunestoneEditorView.swift thoroughly. The issue is calling setState() corrupts internal state. Find where setState is being called and ensure it's ONLY called on initial setup or file switch, NEVER during active editing. The current guard for isFirstResponder isn't working.

## Response
I'll read the RunestoneEditorView.swift file thoroughly to understand the setState() issue.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift"}
>>>END

Now I understand the problem. Looking at the code:

1. **Line 146-148**: The `isFirstResponder` guard is supposed to prevent setState() during editing
2. **Lines 156-159**: setState() is called when text differs from the binding
3. **The bug**: The debounced text sync (line 332) sets `parent.text = textView.text`, which triggers SwiftUI to call `updateUIView`. By the time `updateUIView` runs, `isUpdatingFromTextView` is already `false` (due to `defer`), and `isFirstResponder` can be unreliable during SwiftUI's update cycle.

The fix: Track the filename and ONLY call `setState()` when the file actually changes (file switch), never for same-file updates. Let me apply the patch:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift
>>>FIND
    class Coordinator: NSObject, TextViewDelegate {
        var parent: RunestoneEditorView
        weak var textView: TextView?
        var isUpdatingFromTextView = false
        var lastFontSize: CGFloat = 14.0
        var lastThemeId: String = ""
        var currentLanguage: Language?
>>>REPLACE
    class Coordinator: NSObject, TextViewDelegate {
        var parent: RunestoneEditorView
        weak var textView: TextView?
        var isUpdatingFromTextView = false
        var lastFontSize: CGFloat = 14.0
        var lastThemeId: String = ""
        var currentLanguage: Language?
        var lastFilename: String = ""  // Track filename to detect file switches
        var hasBeenEdited: Bool = false  // Track if user has ever edited this file
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift
>>>FIND
        init(_ parent: RunestoneEditorView) {
            self.parent = parent
            self.lastFontSize = parent.fontSize
            self.lastThemeId = ThemeManager.shared.currentTheme.id
        }
>>>REPLACE
        init(_ parent: RunestoneEditorView) {
            self.parent = parent
            self.lastFontSize = parent.fontSize
            self.lastThemeId = ThemeManager.shared.currentTheme.id
            self.lastFilename = parent.filename
        }
>>>END

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift
>>>FIND
        func textViewDidChange(_ textView: TextView) {
            // Cancel any pending debounced update
            textSyncWorkItem?.cancel()
            
            // Create new debounced work item
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.isUpdatingFromTextView = true
                defer { self.isUpdatingFromTextView = false }
                
                // Update text binding (debounced - only after typing stops)
                self.parent.text = textView.text
                
                // Update line count
                DispatchQueue.main.async {
                    self.parent.totalLines = self.parent.countLines(in: textView.text)
                }
            }
>>>REPLACE
        func textViewDidChange(_ textView: TextView) {
            // Mark that user has edited - prevents setState() calls for this file
            hasBeenEdited = true
            
            // Cancel any pending debounced update
            textSyncWorkItem?.cancel()
            
            // Create new debounced work item
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.isUpdatingFromTextView = true
                defer { self.isUpdatingFromTextView = false }
                
                // Update text binding (debounced - only after typing stops)
                self.parent.text = textView.text
                
                // Update line count
                DispatchQueue.main.async {
                    self.parent.totalLines = self.parent.countLines(in: textView.text)
                }
            }
>>>END

Now the critical fix - update the `updateUIView` to only call setState on file switches:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift
>>>FIND
    func updateUIView(_ textView: TextView, context: Context) {
        // Update coordinator's parent reference for current bindings
        context.coordinator.parent = self
        
        // Update theme if changed
        let currentThemeId = ThemeManager.shared.currentTheme.id
        if context.coordinator.lastThemeId != currentThemeId {
            context.coordinator.lastThemeId = currentThemeId
            textView.theme = makeRunestoneTheme()
            textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
        }
        
        // Update font size if changed
        if context.coordinator.lastFontSize != fontSize {
            context.coordinator.lastFontSize = fontSize
            textView.theme = makeRunestoneTheme()
        }
        
        // CRITICAL: Never update text while user is actively editing!
        // Calling setState() during editing corrupts Runestone's line manager
        // and causes a crash in TextEditHelper.swift:27 (force unwrap on linePosition)
        guard !textView.isFirstResponder else {
            return
        }
        
        // Update text if changed externally (not by user typing)
        let currentText = textView.text
        if currentText != text && !context.coordinator.isUpdatingFromTextView {
            let selectedRange = textView.selectedRange
            
            // Update text with language support
            if let language = getTreeSitterLanguage(for: filename) {
                let state = TextViewState(text: text, language: language)
                textView.setState(state)
            } else {
                // No language support - fallback to plain text
                textView.text = text
            }
            
            // Restore selection if valid
            let textLength = (text as NSString).length
            if selectedRange.location <= textLength {
                let safeLength = min(selectedRange.length, textLength - selectedRange.location)
                textView.selectedRange = NSRange(location: selectedRange.location, length: safeLength)
            }
            
            // Update line count
            DispatchQueue.main.async {
                self.totalLines = self.countLines(in: text)
            }
        }
    }
>>>REPLACE
    func updateUIView(_ textView: TextView, context: Context) {
        // Update coordinator's parent reference for current bindings
        context.coordinator.parent = self
        
        // Update theme if changed
        let currentThemeId = ThemeManager.shared.currentTheme.id
        if context.coordinator.lastThemeId != currentThemeId {
            context.coordinator.lastThemeId = currentThemeId
            textView.theme = makeRunestoneTheme()
            textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
        }
        
        // Update font size if changed
        if context.coordinator.lastFontSize != fontSize {
            context.coordinator.lastFontSize = fontSize
            textView.theme = makeRunestoneTheme()
        }
        
        // CRITICAL FIX: Detect file switch by comparing filenames
        // setState() can ONLY be called on file switch, NEVER during active editing
        // Calling setState() at any other time corrupts Runestone's internal line manager
        // and causes a crash in TextEditHelper.swift:27 (force unwrap on linePosition)
        let isFileSwitch = context.coordinator.lastFilename != filename
        
        if isFileSwitch {
            // File switch detected - safe to call setState() to load new file
            context.coordinator.lastFilename = filename
            context.coordinator.hasBeenEdited = false  // Reset edit flag for new file
            
            // Load new file with language support
            if let language = getTreeSitterLanguage(for: filename) {
                let state = TextViewState(text: text, language: language)
                textView.setState(state)
            } else {
                textView.text = text
            }
            
            // Reset cursor to start of file
            textView.selectedRange = NSRange(location: 0, length: 0)
            
            // Update line count
            DispatchQueue.main.async {
                self.totalLines = self.countLines(in: text)
            }
            return
        }
        
        // SAME FILE: Never call setState() once user has started editing
        // The isFirstResponder check was unreliable - SwiftUI's update cycle
        // can call updateUIView when isFirstResponder is temporarily false
        if context.coordinator.hasBeenEdited {
            // User has edited this file - ignore all external text updates
            // to prevent corrupting Runestone's internal state
            return
        }
        
        // File hasn't been edited yet - safe to update for external changes
        // (e.g., initial load variations, programmatic updates before first edit)
        if !textView.isFirstResponder && !context.coordinator.isUpdatingFromTextView {
            let currentText = textView.text
            if currentText != text {
                // Use direct text assignment, not setState(), to be safer
                textView.text = text
                
                // Update line count
                DispatchQueue.main.async {
                    self.totalLines = self.countLines(in: text)
                }
            }
        }
    }
>>>END

>>>REPORT
## Fix Applied: Runestone setState() Crash

### Root Cause
The crash at `TextEditHelper.swift:27` was caused by calling `setState()` during active editing, which corrupts Runestone's internal `lineManager` state. The existing `isFirstResponder` guard was unreliable because:

1. SwiftUI's `updateUIView` can be called during state transitions when `isFirstResponder` is temporarily false
2. The debounced text sync sets `parent.text`, triggering `updateUIView`, but `isUpdatingFromTextView` is already cleared by `defer`
3. Race conditions between SwiftUI's update cycle and UIKit's responder chain

### Solution
Implemented a more robust protection mechanism:

1. **Track filename** (`lastFilename`) to detect actual file switches - the ONLY time `setState()` should be called
2. **Track edit state** (`hasBeenEdited`) - once a user types anything, block ALL `setState()` calls for that file
3. **File switch logic** - only call `setState()` when `filename != lastFilename`, then reset `hasBeenEdited`
4. **Fallback safety** - for unedited files, use `textView.text = text` instead of `setState()` for minor updates

### Files Modified
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift`

### Changes Made
1. Added `lastFilename` and `hasBeenEdited` to Coordinator (lines 301-302)
2. Initialize `lastFilename` in Coordinator's init
3. Set `hasBeenEdited = true` in `textViewDidChange()` 
4. Complete rewrite of `updateUIView()` with proper file-switch detection and edit-state protection
>>>END
