//
import os
//  RunestoneEditorView.swift
//  VSCodeiPadOS
//
//  High-performance code editor using Runestone with TreeSitter syntax highlighting.
//  Provides native line numbers, code folding, and efficient rendering for large files.
//

import SwiftUI
import UIKit
import Runestone
import TreeSitterSwiftRunestone
import TreeSitterJavaScriptRunestone
import TreeSitterPythonRunestone
import TreeSitterJSONRunestone
import TreeSitterHTMLRunestone
import TreeSitterCSSRunestone
import TreeSitterGoRunestone
import TreeSitterRustRunestone

// Feature flag now uses centralized FeatureFlags.useRunestoneEditor

/// UIViewRepresentable wrapper for Runestone's TextView
/// Provides native TreeSitter syntax highlighting, line numbers, and code folding
struct RunestoneEditorView: UIViewRepresentable {
    @Binding var text: String
    let filename: String
    @Binding var scrollOffset: CGFloat
    @Binding var totalLines: Int
    @Binding var currentLineNumber: Int
    @Binding var currentColumn: Int
    @Binding var cursorIndex: Int
    @Binding var lineHeight: CGFloat
    let isActive: Bool
    let fontSize: CGFloat
    @EnvironmentObject var editorCore: EditorCore
    
    // Settings from AppStorage
    @AppStorage("wordWrap") private var wordWrapEnabled: Bool = true
    @AppStorage("showLineNumbers") private var showLineNumbers: Bool = true
    @AppStorage("tabSize") private var tabSize: Int = 4
    @AppStorage("insertSpaces") private var insertSpaces: Bool = true
    @AppStorage("showInvisibleCharacters") private var showInvisibleCharacters: Bool = false
    
    /// Autocomplete key handling hooks (return true if handled)
    let onAcceptAutocomplete: (() -> Bool)?
    let onDismissAutocomplete: (() -> Bool)?
    
    init(
        text: Binding<String>,
        filename: String,
        scrollOffset: Binding<CGFloat> = .constant(0),
        totalLines: Binding<Int>,
        currentLineNumber: Binding<Int>,
        currentColumn: Binding<Int>,
        cursorIndex: Binding<Int> = .constant(0),
        lineHeight: Binding<CGFloat> = .constant(0),
        isActive: Bool,
        fontSize: CGFloat = 14.0,
        onAcceptAutocomplete: (() -> Bool)? = nil,
        onDismissAutocomplete: (() -> Bool)? = nil
    ) {
        self._text = text
        self.filename = filename
        self._scrollOffset = scrollOffset
        self._totalLines = totalLines
        self._currentLineNumber = currentLineNumber
        self._currentColumn = currentColumn
        self._cursorIndex = cursorIndex
        self._lineHeight = lineHeight
        self.isActive = isActive
        self.fontSize = fontSize
        self.onAcceptAutocomplete = onAcceptAutocomplete
        self.onDismissAutocomplete = onDismissAutocomplete
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> TextView {
        let textView = TextView()
        textView.editorDelegate = context.coordinator
        
        // Enable Runestone's built-in line numbers and line height multiplier for code folding support
        textView.showLineNumbers = true
        textView.lineHeightMultiplier = 1.3
        textView.lineSelectionDisplayType = .line
        
        // Configure line wrapping (from settings)
        textView.isLineWrappingEnabled = wordWrapEnabled

        // Apply tab size (indentStrategy controls how Tab key inserts indent)
        textView.indentStrategy = insertSpaces
            ? .space(length: tabSize)
            : .tab(length: tabSize)

        // Show/hide invisible characters (tabs, spaces, line breaks)
        textView.showTabs = showInvisibleCharacters
        textView.showSpaces = showInvisibleCharacters
        textView.showLineBreaks = showInvisibleCharacters

        // Configure editing
        textView.isEditable = true
        textView.isSelectable = true
        
        // Disable autocorrect/autocapitalize for code editing
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.spellCheckingType = .no
        
        // Configure keyboard
        textView.keyboardType = .asciiCapable
        textView.keyboardDismissMode = .interactive
        
        // Content insets for padding
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Set text with TreeSitter language support FIRST
        if let language = getTreeSitterLanguage(for: filename) {
            let state = TextViewState(text: text, language: language)
            textView.setState(state)
        } else {
            // No language support - fallback to plain text
            textView.text = text
        }
        
        // Set theme AFTER setState to ensure it takes effect
        // setState may reset internal rendering state, so theme must come after
        textView.theme = makeRunestoneTheme()
        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
        
        // Store reference for coordinator
        context.coordinator.textView = textView

        // Accessibility
        textView.accessibilityLabel = "Code editor"
        textView.accessibilityHint = "Edit code here. Use rotor to navigate by line."
        textView.isAccessibilityElement = true
        
        // Initial line count
        DispatchQueue.main.async {
            self.totalLines = self.countLines(in: text)
        }
        
        return textView
    }
    
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
        
        // Sync Runestone's built-in line numbers with the user setting
        textView.showLineNumbers = showLineNumbers
        // Word wrap toggle still works
        if textView.isLineWrappingEnabled != wordWrapEnabled {
            textView.isLineWrappingEnabled = wordWrapEnabled
        }

        // Tab size / indent strategy
        let expectedStrategy: IndentStrategy = insertSpaces
            ? .space(length: tabSize)
            : .tab(length: tabSize)
        // IndentStrategy isn't Equatable — always re-apply; it's cheap
        textView.indentStrategy = expectedStrategy

        // Invisible characters toggle
        if textView.showTabs != showInvisibleCharacters {
            textView.showTabs = showInvisibleCharacters
        }
        if textView.showSpaces != showInvisibleCharacters {
            textView.showSpaces = showInvisibleCharacters
        }
        if textView.showLineBreaks != showInvisibleCharacters {
            textView.showLineBreaks = showInvisibleCharacters
        }

        // CRITICAL: Only call setState() when safe (not during active editing)
        // Calling setState() during editing corrupts Runestone's lineManager
        // and causes crash at TextEditHelper.swift:27 (force unwrap on linePosition)
        
        let isFileSwitching = context.coordinator.lastFilename != filename
        let currentText = textView.text
        let textChanged = currentText != text
        let isActivelyEditing = textView.isFirstResponder
        
        // CRITICAL: Cancel any pending debounced updates before tab switch to prevent
        // race condition where stale content overwrites new tab's content
        if isFileSwitching {
            context.coordinator.cancelPendingTextSync()
            
            // User switched to a different file - safe to call setState()
            context.coordinator.lastFilename = filename
            context.coordinator.hasBeenEdited = false
            
            if let language = getTreeSitterLanguage(for: filename) {
                let state = TextViewState(text: text, language: language)
                textView.setState(state)
            } else {
                textView.text = text
            }
            
            // CRITICAL: Re-apply theme AFTER setState - setState may reset rendering state
            textView.theme = makeRunestoneTheme()
            
            // Reset cursor to start for new file
            textView.selectedRange = NSRange(location: 0, length: 0)
            
            // Update line count
            DispatchQueue.main.async {
                self.totalLines = self.countLines(in: text)
            }
        } else if textChanged && !context.coordinator.hasBeenEdited && !isActivelyEditing && !context.coordinator.isUpdatingFromTextView {
            // Text changed externally (e.g., initial load, external modification)
            // Safe to update since user hasn't started editing yet
            if let language = getTreeSitterLanguage(for: filename) {
                let state = TextViewState(text: text, language: language)
                textView.setState(state)
            } else {
                textView.text = text
            }
            
            // CRITICAL: Re-apply theme AFTER setState - setState may reset rendering state
            textView.theme = makeRunestoneTheme()
            
            // Update line count
            DispatchQueue.main.async {
                self.totalLines = self.countLines(in: text)
            }
        }
        // If user HAS edited OR is actively editing, DO NOTHING
        // Let the user's edits remain - don't corrupt the lineManager

        // MARK: Minimap tap-to-scroll: apply external scroll offset changes
        // This fires when the minimap (or any external source) writes to scrollOffset.
        // We guard with isExternalScroll to break the feedback loop.
        if abs(textView.contentOffset.y - scrollOffset) > 1.0 {
            context.coordinator.isExternalScroll = true
            textView.setContentOffset(
                CGPoint(x: textView.contentOffset.x, y: scrollOffset),
                animated: false
            )
            context.coordinator.isExternalScroll = false
        }

        // Report line height back so minimap and gutter use the correct value.
        // Only update when lineHeight binding is writable (not .constant(0)).
        let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let computedLineHeight = ceil(font.lineHeight * 1.4)
        if lineHeight != 0 && abs(lineHeight - computedLineHeight) > 0.5 {
            DispatchQueue.main.async {
                self.lineHeight = computedLineHeight
            }
        }

        // MARK: Find/Replace - jump to match
        // When FindViewModel sets editorCore.requestedSelection, scroll to and select that range.
        if let range = editorCore.requestedSelection,
           range != context.coordinator.lastHandledSelection {
            context.coordinator.lastHandledSelection = range
            let textLength = (textView.text as NSString).length
            let safeRange = NSRange(
                location: min(range.location, textLength),
                length: min(range.length, max(0, textLength - range.location))
            )
            textView.selectedRange = safeRange
            textView.scrollRangeToVisible(safeRange)
            DispatchQueue.main.async {
                editorCore.requestedSelection = nil
            }
        }
    }
    
    // MARK: - Runestone Theme Factory
    
    private func makeRunestoneTheme() -> RunestoneEditorTheme {
        let appTheme = ThemeManager.shared.currentTheme
        return RunestoneEditorTheme(
            fontSize: fontSize,
            backgroundColor: UIColor(appTheme.editorBackground),
            textColor: UIColor(appTheme.editorForeground),
            gutterBackgroundColor: UIColor(appTheme.editorBackground),
            gutterHairlineColor: UIColor(appTheme.lineNumber).withAlphaComponent(0.3),
            lineNumberColor: UIColor(appTheme.lineNumber),
            selectedLineBackgroundColor: UIColor(appTheme.currentLineHighlight),
            selectedLinesLineNumberColor: UIColor(appTheme.lineNumberActive),
            selectedLinesGutterBackgroundColor: UIColor(appTheme.currentLineHighlight),
            invisibleCharactersColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.3),
            pageGuideHairlineColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.1),
            pageGuideBackgroundColor: UIColor(appTheme.editorBackground),
            markedTextBackgroundColor: UIColor(appTheme.selection).withAlphaComponent(0.5),
            keywordColor: UIColor(appTheme.keyword),
            stringColor: UIColor(appTheme.string),
            numberColor: UIColor(appTheme.number),
            commentColor: UIColor(appTheme.comment),
            functionColor: UIColor(appTheme.function),
            typeColor: UIColor(appTheme.type),
            variableColor: UIColor(appTheme.variable)
        )
    }
    
    // MARK: - Language Mode Mapping
    
    /// Gets the actual TreeSitter Language object for a given filename
    /// Returns nil for plain text files (no syntax highlighting)
    private func getTreeSitterLanguage(for filename: String) -> Runestone.TreeSitterLanguage? {
        let ext = (filename as NSString).pathExtension.lowercased()
        let lastComponent = (filename as NSString).lastPathComponent.lowercased()
        
        // Special-case filenames without extensions
        if lastComponent == "dockerfile" || lastComponent.hasPrefix("dockerfile.") {
            return nil // Bash support not in package list yet
        }
        if lastComponent == ".env" || lastComponent.hasPrefix(".env.") {
            return nil // Plain text
        }
        if lastComponent == "makefile" || lastComponent == "gnumakefile" {
            return nil // Bash support not in package list yet
        }
        if lastComponent == "podfile" || lastComponent == "gemfile" {
            return nil // Ruby support not in package list yet
        }
        if lastComponent == "package.json" || lastComponent == "tsconfig.json" {
            return TreeSitterLanguage.json
        }
        
        switch ext {
        // Swift
        case "swift":
            return TreeSitterLanguage.swift
        
        // JavaScript
        case "js", "mjs", "cjs", "jsx":
            return TreeSitterLanguage.javaScript
        
        // TypeScript - use JavaScript as fallback
        case "ts", "mts", "cts", "tsx":
            return TreeSitterLanguage.javaScript
        
        // Python
        case "py", "pyw", "pyi":
            return TreeSitterLanguage.python
        
        // Go
        case "go":
            return TreeSitterLanguage.go
        
        // Rust
        case "rs":
            return TreeSitterLanguage.rust
        
        // JSON
        case "json", "jsonc":
            return TreeSitterLanguage.json
        
        // HTML
        case "html", "htm", "xhtml":
            return TreeSitterLanguage.html
        
        // CSS
        case "css", "scss":
            return TreeSitterLanguage.css
        
        // XML - use HTML as fallback
        case "xml", "plist", "svg":
            return TreeSitterLanguage.html
        
        // Default - no syntax highlighting
        default:
            return nil
        }
    }

    
    // MARK: - Helpers
    
    private func countLines(in text: String) -> Int {
        guard !text.isEmpty else { return 1 }
        // Use NSString for efficient newline counting (avoids char-by-char iteration)
        let ns = text as NSString
        var count = 1
        var searchRange = NSRange(location: 0, length: ns.length)
        while searchRange.location < ns.length {
            let found = ns.range(of: "\n", range: searchRange)
            if found.location == NSNotFound { break }
            count += 1
            searchRange.location = found.location + found.length
            searchRange.length = ns.length - searchRange.location
        }
        return count
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, TextViewDelegate, @unchecked Sendable {
        var parent: RunestoneEditorView
        weak var textView: TextView?
        var isUpdatingFromTextView = false
        var isExternalScroll = false
        var lastFontSize: CGFloat = 14.0
        var lastThemeId: String = ""
        var currentLanguage: Language?
        
        // Track file identity to know when to call setState()
        var lastFilename: String = ""
        var hasBeenEdited: Bool = false

        // Find/Replace: track last handled selection to avoid re-applying
        var lastHandledSelection: NSRange? = nil
        
        // Debounced text sync to avoid SwiftUI re-renders on every keystroke
        private var textSyncWorkItem: DispatchWorkItem?
        private let debounceInterval: TimeInterval = 0.5 // 500ms
        private var forceSyncObserver: NSObjectProtocol?
        private var editorActionObservers: [NSObjectProtocol] = []

        // MARK: - Bracket Matching Highlight
        /// Overlay layer used to draw subtle background boxes on matched bracket pairs.
        private let bracketHighlightLayer: CAShapeLayer = {
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.systemYellow.withAlphaComponent(0.22).cgColor
            layer.strokeColor = UIColor.systemYellow.withAlphaComponent(0.50).cgColor
            layer.lineWidth = 1.0
            layer.zPosition = 100
            return layer
        }()
        
        init(_ parent: RunestoneEditorView) {
            self.parent = parent
            self.lastFontSize = parent.fontSize
            self.lastThemeId = ""  // Will be set on first update from MainActor
            self.lastFilename = parent.filename
            super.init()

            // bracketHighlightLayer is installed lazily in textViewDidBeginEditing
            // so we have a valid superlayer before trying to draw.

            // Listen for force sync requests (e.g., before save)
            forceSyncObserver = NotificationCenter.default.addObserver(
                forName: .forceEditorSync,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.syncTextImmediately()
                }
            }
            
            // Listen for editor action notifications (keyboard shortcuts)
            let actions: [Notification.Name] = [
                .toggleComment, .deleteLine, .moveLineUp, .moveLineDown,
                .duplicateLineUp, .duplicateLineDown, .addNextOccurrence, .selectAllOccurrences
            ]
            for name in actions {
                editorActionObservers.append(
                    NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] notif in
                        let notifName = notif.name
                        MainActor.assumeIsolated {
                            self?.handleEditorAction(notifName)
                        }
                    }
                )
            }

            // Listen for code folding notifications from EditorCore
            editorActionObservers.append(
                NotificationCenter.default.addObserver(forName: .collapseAllFolds, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        self?.handleCollapseAllFolds()
                    }
                }
            )
            editorActionObservers.append(
                NotificationCenter.default.addObserver(forName: .expandAllFolds, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        self?.handleExpandAllFolds()
                    }
                }
            )
        }
        
        deinit {
            // Cancel any pending debounced updates
            textSyncWorkItem?.cancel()
            if let observer = forceSyncObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            for observer in editorActionObservers {
                NotificationCenter.default.removeObserver(observer)
            }
            editorActionObservers.removeAll()
        }
        
        // MARK: - TextViewDelegate
        
        func textViewDidChange(_ textView: TextView) {
            // Mark that user has edited - blocks setState() calls until file switch
            hasBeenEdited = true
            
            // Cancel any pending debounced update
            textSyncWorkItem?.cancel()
            
            // Create new debounced work item
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                MainActor.assumeIsolated {
                    self.isUpdatingFromTextView = true
                    defer { self.isUpdatingFromTextView = false }
                    
                    // Update text binding (debounced - only after typing stops)
                    self.parent.text = textView.text
                    
                    // Update line count
                    self.parent.totalLines = self.parent.countLines(in: textView.text)
                }
            }
            
            // Schedule the update after debounce interval
            textSyncWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
        }
        
        /// Immediately sync text to SwiftUI binding (call on save/tab-switch)
        func syncTextImmediately() {
            // Cancel any pending debounced update
            textSyncWorkItem?.cancel()
            
            guard let textView = textView else { return }
            
            isUpdatingFromTextView = true
            defer { isUpdatingFromTextView = false }
            
            // Immediate sync
            MainActor.assumeIsolated {
                parent.text = textView.text
                parent.totalLines = parent.countLines(in: textView.text)
            }
        }
        
        /// Cancel pending text sync without syncing - used when switching tabs
        /// to prevent stale content from overwriting new tab's content
        func cancelPendingTextSync() {
            textSyncWorkItem?.cancel()
            textSyncWorkItem = nil
        }

        // MARK: - Code Folding

        /// Handles the collapseAllFolds notification from EditorCore.
        /// Uses respondsToSelector to call Runestone's fold API if available,
        /// otherwise falls back to a no-op (Runestone 0.5.x has no built-in
        /// code folding, but this is future-proofed for newer versions).
        private func handleCollapseAllFolds() {
            guard let textView = textView else { return }
            // Runestone 0.6+ may add collapseAllFolds() — call it dynamically if present
            let sel = NSSelectorFromString("collapseAllFolds")
            if textView.responds(to: sel) {
                _ = textView.perform(sel)
            } else {
                // No built-in fold support in current Runestone version.
                // Post a notification so UI can reflect the intent if needed.
                NotificationCenter.default.post(name: .codeFoldingDidChange, object: nil)
            }
        }

        /// Handles the expandAllFolds notification from EditorCore.
        /// Uses respondsToSelector to call Runestone's unfold API if available,
        /// otherwise falls back to a no-op (Runestone 0.5.x has no built-in
        /// code folding, but this is future-proofed for newer versions).
        private func handleExpandAllFolds() {
            guard let textView = textView else { return }
            // Runestone 0.6+ may add expandAllFolds() — call it dynamically if present
            let sel = NSSelectorFromString("expandAllFolds")
            if textView.responds(to: sel) {
                _ = textView.perform(sel)
            } else {
                // No built-in fold support in current Runestone version.
                // Post a notification so UI can reflect the intent if needed.
                NotificationCenter.default.post(name: .codeFoldingDidChange, object: nil)
            }
        }
        
        func textViewDidChangeSelection(_ textView: TextView) {
            updateCursorPosition(in: textView)
            updateBracketHighlight(in: textView)
        }
        
        func textViewDidBeginEditing(_ textView: TextView) {
            // Install the bracket-highlight overlay layer once the view is in the hierarchy
            if bracketHighlightLayer.superlayer == nil {
                textView.layer.addSublayer(bracketHighlightLayer)
            }
        }
        
        func textViewDidEndEditing(_ textView: TextView) {
            // Could be used for focus handling
        }
        
        func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

            // ---------------------------------------------------------------
            // MARK: Tab key
            // ---------------------------------------------------------------
            if text == "\t" {
                // First give autocomplete a chance to accept
                let accepted = MainActor.assumeIsolated {
                    parent.onAcceptAutocomplete?()
                }
                if accepted == true { return false }

                // Emmet abbreviation expansion (HTML/CSS files only)
                if let (expansion, abbrevRange) = EmmetEngine.shared.tryExpand(
                    in: textView.text,
                    cursorLocation: range.location,
                    filename: parent.filename
                ) {
                    let ms = NSMutableString(string: textView.text)
                    ms.replaceCharacters(in: abbrevRange, with: expansion)
                    textView.text = ms as String
                    let cursorPos = abbrevRange.location + (expansion as NSString).length
                    textView.selectedRange = NSRange(location: cursorPos, length: 0)
                    textViewDidChange(textView)
                    return false
                }

                // Insert spaces (or a real tab) according to settings
                let tabSz = max(1, parent.tabSize)
                let spaces = parent.insertSpaces
                let indentStr = spaces ? String(repeating: " ", count: tabSz) : "\t"
                let ms = NSMutableString(string: textView.text)
                ms.replaceCharacters(in: range, with: indentStr)
                textView.text = ms as String
                textView.selectedRange = NSRange(location: range.location + indentStr.count, length: 0)
                textViewDidChange(textView)
                return false
            }

            // ---------------------------------------------------------------
            // MARK: Auto-indent on Enter
            // ---------------------------------------------------------------
            if text == "\n" {
                let nsText = textView.text as NSString
                // Range of the current line
                let lineRange = nsText.lineRange(for: NSRange(location: range.location, length: 0))
                // Text from line-start up to cursor
                let lineUpToCursor = nsText.substring(with:
                    NSRange(location: lineRange.location,
                            length: range.location - lineRange.location))

                // Leading whitespace of current line
                var indent = ""
                for ch in lineUpToCursor {
                    if ch == " " || ch == "\t" { indent.append(ch) } else { break }
                }

                // Does the (trimmed) line end with an opener?
                let trimmed = lineUpToCursor.trimmingCharacters(in: .whitespaces)
                let endsWithOpener = trimmed.hasSuffix("{") || trimmed.hasSuffix("(")
                                  || trimmed.hasSuffix("[") || trimmed.hasSuffix(":")

                let tabSz = max(1, parent.tabSize)
                let spaces = parent.insertSpaces
                let oneLevel = spaces ? String(repeating: " ", count: tabSz) : "\t"

                let ms = NSMutableString(string: nsText)
                let insertion: String
                var newCursor: Int

                if endsWithOpener {
                    // Peek at the character immediately after the cursor
                    let afterCursor: String = range.location < nsText.length
                        ? nsText.substring(with: NSRange(location: range.location, length: 1))
                        : ""
                    let isCloser = (afterCursor == "}" || afterCursor == ")" || afterCursor == "]")
                    if isCloser {
                        // Split: <newline><indent+1>  <cursor>  <newline><indent>
                        insertion = "\n" + indent + oneLevel + "\n" + indent
                        ms.replaceCharacters(in: range, with: insertion)
                        textView.text = ms as String
                        newCursor = range.location + 1 + indent.count + oneLevel.count
                    } else {
                        insertion = "\n" + indent + oneLevel
                        ms.replaceCharacters(in: range, with: insertion)
                        textView.text = ms as String
                        newCursor = range.location + insertion.count
                    }
                } else {
                    insertion = "\n" + indent
                    ms.replaceCharacters(in: range, with: insertion)
                    textView.text = ms as String
                    newCursor = range.location + insertion.count
                }

                textView.selectedRange = NSRange(location: newCursor, length: 0)
                textViewDidChange(textView)
                return false
            }

            // ---------------------------------------------------------------
            // MARK: Bracket / Quote Auto-Close
            // ---------------------------------------------------------------
            let pairs: [(open: String, close: String)] = [
                ("{", "}"), ("(", ")"), ("[", "]"),
                ("\"", "\""), ("'", "'"), ("`", "`")
            ]
            let allClosers = Set(pairs.map { $0.close })

            // Skip-over: if the user types the closing char and the next char is already that closer
            if allClosers.contains(text) && range.length == 0 {
                let nsText = textView.text as NSString
                if range.location < nsText.length {
                    let nextChar = nsText.substring(with: NSRange(location: range.location, length: 1))
                    if nextChar == text {
                        textView.selectedRange = NSRange(location: range.location + 1, length: 0)
                        return false
                    }
                }
            }

            // Auto-insert matching closer when an opener is typed
            if let pair = pairs.first(where: { $0.open == text }), range.length == 0 {
                let nsText = textView.text as NSString

                // For symmetric pairs (quotes), skip auto-close if we're already inside one.
                // Heuristic: count unescaped occurrences of the same quote before cursor.
                // Odd count → inside a string → don't double-close.
                if text == "\"" || text == "'" || text == "`" {
                    let before = nsText.substring(to: range.location)
                    var count = 0
                    var i = before.startIndex
                    while i < before.endIndex {
                        let c = String(before[i])
                        if c == "\\" {
                            // skip the escaped character
                            let ni = before.index(after: i)
                            if ni < before.endIndex { i = before.index(after: ni) } else { break }
                            continue
                        }
                        if c == text { count += 1 }
                        i = before.index(after: i)
                    }
                    if count % 2 == 1 {
                        // Inside a string — just insert the raw character
                        return true
                    }
                }

                let insertion = text + pair.close
                let ms = NSMutableString(string: nsText)
                ms.replaceCharacters(in: range, with: insertion)
                textView.text = ms as String
                textView.selectedRange = NSRange(location: range.location + text.count, length: 0)
                textViewDidChange(textView)
                return false
            }

            // Handle Escape key for autocomplete dismissal
            // Note: Escape key events are typically handled via key commands, not here

            // ---------------------------------------------------------------
            // MARK: Smart Paste — re-indent pasted text to match cursor indent
            // ---------------------------------------------------------------
            // Detect a paste: replacement contains newlines AND is longer than a
            // single keystroke could produce (> 2 chars that include a newline).
            let isPaste = text.contains("\n") && text.count > 2
            if isPaste {
                // --- 1. Read tab/space settings ---
                let tabSz = max(1, parent.tabSize)
                let spaces = parent.insertSpaces

                // --- 2. Get indentation of the current line at the cursor ---
                let nsText = textView.text as NSString
                let lineRange = nsText.lineRange(for: NSRange(location: range.location, length: 0))
                let lineUpToCursor = nsText.substring(with:
                    NSRange(location: lineRange.location,
                            length: range.location - lineRange.location))

                var targetIndent = ""
                for ch in lineUpToCursor {
                    if ch == " " || ch == "\t" { targetIndent.append(ch) } else { break }
                }

                // --- 3. Helper: measure indent width in spaces ---
                func indentWidth(_ s: String) -> Int {
                    var w = 0
                    for ch in s {
                        if ch == " "  { w += 1 }
                        else if ch == "\t" { w += tabSz }
                        else { break }
                    }
                    return w
                }

                // --- 4. Find the leading indent of the first non-blank pasted line ---
                let pastedLines = text.components(separatedBy: "\n")
                var firstNonBlankIndent = ""
                for line in pastedLines {
                    if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                        var ind = ""
                        for ch in line {
                            if ch == " " || ch == "\t" { ind.append(ch) } else { break }
                        }
                        firstNonBlankIndent = ind
                        break
                    }
                }

                let sourceWidth = indentWidth(firstNonBlankIndent)
                let targetWidth = indentWidth(targetIndent)
                let delta       = targetWidth - sourceWidth   // positive = add indent, negative = remove

                // --- 5. Helper: build an indent string for a given column width ---
                func buildIndent(width: Int) -> String {
                    let w = max(0, width)
                    if spaces {
                        return String(repeating: " ", count: w)
                    } else {
                        let tabs     = w / tabSz
                        let leftover = w % tabSz
                        return String(repeating: "\t", count: tabs) + String(repeating: " ", count: leftover)
                    }
                }

                // --- 6. Re-indent every line of the pasted text ---
                var reindentedLines: [String] = []
                for (idx, line) in pastedLines.enumerated() {
                    // The very first segment sits right at the cursor column, so we
                    // leave it untouched — the surrounding code already has the right
                    // indentation context.
                    if idx == 0 {
                        reindentedLines.append(line)
                        continue
                    }

                    let trimmed = line.trimmingCharacters(in: CharacterSet(charactersIn: " \t"))
                    if trimmed.isEmpty {
                        // Keep blank lines empty
                        reindentedLines.append("")
                        continue
                    }

                    // Measure this line's own current indent
                    var lineIndentStr = ""
                    for ch in line {
                        if ch == " " || ch == "\t" { lineIndentStr.append(ch) } else { break }
                    }
                    let lineWidth = indentWidth(lineIndentStr)
                    let newWidth  = lineWidth + delta
                    reindentedLines.append(buildIndent(width: newWidth) + trimmed)
                }

                let reindentedText = reindentedLines.joined(separator: "\n")

                // --- 7. Insert re-indented text and position cursor at its end ---
                let ms = NSMutableString(string: nsText)
                ms.replaceCharacters(in: range, with: reindentedText)
                textView.text = ms as String
                let newCursorPos = range.location + (reindentedText as NSString).length
                textView.selectedRange = NSRange(location: newCursorPos, length: 0)
                textViewDidChange(textView)
                return false
            }

            return true
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Only propagate scroll events that originate from the user.
            // When isExternalScroll is true we triggered setContentOffset ourselves
            // (e.g. from a minimap tap) and must not write back to avoid a loop.
            guard !isExternalScroll else { return }
            MainActor.assumeIsolated {
                parent.scrollOffset = scrollView.contentOffset.y
            }
        }
        
        // MARK: - Bracket Matching Highlight

        /// Returns the rect (in the text view's own coordinate space) for one UTF-16 character.
        private func charRect(at offset: Int, in textView: TextView) -> CGRect? {
            guard let textInput = textView as? UITextInput else { return nil }
            guard
                let start = textInput.position(from: textInput.beginningOfDocument, offset: offset),
                let end   = textInput.position(from: start, offset: 1),
                let tRange = textInput.textRange(from: start, to: end)
            else { return nil }
            return textInput.firstRect(for: tRange)
        }

        /// Walks the string to find the bracket that matches the one at `pos`.
        private func matchingBracketOffset(in str: NSString, pos: Int) -> Int? {
            let opens:  [unichar] = [
                UInt16(UnicodeScalar("{").value),
                UInt16(UnicodeScalar("(").value),
                UInt16(UnicodeScalar("[").value)
            ]
            let closes: [unichar] = [
                UInt16(UnicodeScalar("}").value),
                UInt16(UnicodeScalar(")").value),
                UInt16(UnicodeScalar("]").value)
            ]
            let ch = str.character(at: pos)
            if let idx = opens.firstIndex(of: ch) {
                let close = closes[idx]
                var depth = 1; var i = pos + 1
                while i < str.length {
                    let c = str.character(at: i)
                    if c == ch { depth += 1 } else if c == close { depth -= 1; if depth == 0 { return i } }
                    i += 1
                }
            } else if let idx = closes.firstIndex(of: ch) {
                let open = opens[idx]
                var depth = 1; var i = pos - 1
                while i >= 0 {
                    let c = str.character(at: i)
                    if c == ch { depth += 1 } else if c == open { depth -= 1; if depth == 0 { return i } }
                    i -= 1
                }
            }
            return nil
        }

        private func updateBracketHighlight(in textView: TextView) {
            // Make sure the layer is installed
            guard bracketHighlightLayer.superlayer != nil else { return }

            let cursor = textView.selectedRange.location
            let nsText = textView.text as NSString

            let bracketChars: [unichar] = [
                UInt16(UnicodeScalar("{").value), UInt16(UnicodeScalar("}").value),
                UInt16(UnicodeScalar("(").value), UInt16(UnicodeScalar(")").value),
                UInt16(UnicodeScalar("[").value), UInt16(UnicodeScalar("]").value)
            ]

            // Check character to the left of cursor, then to the right
            var sourcePos: Int? = nil
            for candidate in [cursor - 1, cursor] where candidate >= 0 && candidate < nsText.length {
                if bracketChars.contains(nsText.character(at: candidate)) {
                    sourcePos = candidate
                    break
                }
            }

            guard let src = sourcePos, let matchPos = matchingBracketOffset(in: nsText, pos: src) else {
                bracketHighlightLayer.path = nil
                return
            }

            let path = CGMutablePath()
            let inset: CGFloat = 1.0
            for offset in [src, matchPos] {
                if let r = charRect(at: offset, in: textView) {
                    path.addRoundedRect(in: r.insetBy(dx: inset, dy: inset),
                                        cornerWidth: 2, cornerHeight: 2)
                }
            }
            bracketHighlightLayer.path = path
        }

        // MARK: - Cursor Position Calculation

        private func updateCursorPosition(in textView: TextView) {
            MainActor.assumeIsolated {
                let selectedRange = textView.selectedRange
                let text = textView.text as NSString
                let cursorLocation = selectedRange.location
                
                var lineNumber = 1
                var columnNumber = 1
                
                // Get line range for cursor position - O(1) via NSString
                let lineRange = text.lineRange(for: NSRange(location: cursorLocation, length: 0))
                columnNumber = cursorLocation - lineRange.location + 1
                
                // Count newlines before this line's start using NSString range search - O(lines) not O(chars)
                let lineStart = lineRange.location
                var searchPos = 0
                while searchPos < lineStart {
                    let r = text.range(of: "\n", options: [], range: NSRange(location: searchPos, length: lineStart - searchPos))
                    if r.location == NSNotFound { break }
                    lineNumber += 1
                    searchPos = r.location + r.length
                }
                
                // Update bindings
                parent.cursorIndex = cursorLocation
                parent.currentLineNumber = lineNumber
                parent.currentColumn = columnNumber
            }
        }
        
        // MARK: - Editor Action Handlers (Keyboard Shortcuts)
        
        private func handleEditorAction(_ name: Notification.Name) {
            guard let textView = textView else { return }
            switch name {
            case .toggleComment: performToggleComment(textView)
            case .deleteLine: performDeleteLine(textView)
            case .moveLineUp: performMoveLineUp(textView)
            case .moveLineDown: performMoveLineDown(textView)
            case .duplicateLineUp: performDuplicateLine(textView, above: true)
            case .duplicateLineDown: performDuplicateLine(textView, above: false)
            case .addNextOccurrence: performAddNextOccurrence(textView)
            case .selectAllOccurrences: performSelectAllOccurrences(textView)
            default: break
            }
        }
        
        /// Get the line range (start index, length) for lines touched by the selection
        private func currentLineRange(in textView: TextView) -> NSRange {
            let text = textView.text as NSString
            return text.lineRange(for: textView.selectedRange)
        }
        
        /// Detect comment prefix based on current filename
        private func commentPrefix() -> String {
            let ext = (parent.filename as NSString).pathExtension.lowercased()
            switch ext {
            case "py", "pyw", "pyi", "rb", "sh", "bash", "zsh", "yml", "yaml", "toml", "r":
                return "#"
            case "lua":
                return "--"
            case "sql":
                return "--"
            case "css", "scss", "less":
                return "/*"  // block comments handled separately
            default:
                return "//"
            }
        }
        
        /// Returns (prefix, suffix) for block comment languages, nil for line comments
        private func blockCommentWrappers() -> (prefix: String, suffix: String)? {
            let ext = (parent.filename as NSString).pathExtension.lowercased()
            switch ext {
            case "html", "htm", "xml", "svg":
                return ("<!-- ", " -->")
            case "css", "scss", "less":
                return ("/* ", " */")
            default:
                return nil
            }
        }
        
        private func performToggleComment(_ textView: TextView) {
            // Block comment languages (HTML, CSS, etc.) use wrapping instead of line prefix
            if let (blockPrefix, blockSuffix) = blockCommentWrappers() {
                performToggleBlockComment(textView, prefix: blockPrefix, suffix: blockSuffix)
                return
            }
            
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            let linesText = text.substring(with: lineRange)
            var lines = linesText.components(separatedBy: "\n")
            let prefix = commentPrefix()
            
            // Remove trailing empty element from split (if text ends with \n)
            let hadTrailingNewline = linesText.hasSuffix("\n")
            if hadTrailingNewline && lines.last == "" { lines.removeLast() }
            
            // Check if all non-empty lines have the comment prefix
            let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            guard !nonEmptyLines.isEmpty else { return }
            
            let allCommented = nonEmptyLines.allSatisfy {
                $0.trimmingCharacters(in: .whitespaces).hasPrefix(prefix)
            }
            
            if allCommented {
                // Uncomment: remove first occurrence of prefix (with optional space)
                lines = lines.map { line in
                    if let range = line.range(of: prefix + " ") {
                        var r = line; r.removeSubrange(range); return r
                    } else if let range = line.range(of: prefix) {
                        var r = line; r.removeSubrange(range); return r
                    }
                    return line
                }
            } else {
                // Comment: find minimum indent, insert prefix there
                let minIndent = nonEmptyLines.map { $0.prefix(while: { $0 == " " || $0 == "\t" }).count }.min() ?? 0
                lines = lines.map { line in
                    if line.trimmingCharacters(in: .whitespaces).isEmpty { return line }
                    let idx = line.index(line.startIndex, offsetBy: min(minIndent, line.count))
                    var r = line; r.insert(contentsOf: prefix + " ", at: idx); return r
                }
            }
            
            var newText = lines.joined(separator: "\n")
            if hadTrailingNewline { newText += "\n" }
            
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: lineRange, with: newText)
            textView.text = fullText as String
            
            // Adjust selection
            let lengthDiff = newText.count - linesText.count
            textView.selectedRange = NSRange(
                location: min(selectedRange.location + (allCommented ? -(prefix.count + 1) : (prefix.count + 1)), max(0, (textView.text as NSString).length)),
                length: max(0, selectedRange.length + lengthDiff)
            )
            textViewDidChange(textView)
        }
        
        private func performToggleBlockComment(_ textView: TextView, prefix: String, suffix: String) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            let linesText = text.substring(with: lineRange)
            var lines = linesText.components(separatedBy: "\n")
            
            // Remove trailing empty element from split (if text ends with \n)
            let hadTrailingNewline = linesText.hasSuffix("\n")
            if hadTrailingNewline && lines.last == "" { lines.removeLast() }
            
            guard !lines.isEmpty else { return }
            
            // Find first and last non-empty lines
            guard let firstIdx = lines.firstIndex(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }),
                  let lastIdx = lines.lastIndex(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) else { return }
            
            let firstTrimmed = lines[firstIdx].trimmingCharacters(in: .whitespaces)
            let lastTrimmed = lines[lastIdx].trimmingCharacters(in: .whitespaces)
            let isCommented = firstTrimmed.hasPrefix(prefix) && lastTrimmed.hasSuffix(suffix)
            
            if isCommented {
                // Uncomment: remove prefix from first non-empty line, suffix from last non-empty line
                if let range = lines[firstIdx].range(of: prefix) {
                    lines[firstIdx].removeSubrange(range)
                }
                if lastIdx != firstIdx {
                    if let range = lines[lastIdx].range(of: suffix, options: .backwards) {
                        lines[lastIdx].removeSubrange(range)
                    }
                }
            } else {
                // Comment: wrap with block comment markers
                let firstWS = String(lines[firstIdx].prefix(while: { $0 == " " || $0 == "\t" }))
                lines[firstIdx] = firstWS + prefix + String(lines[firstIdx].dropFirst(firstWS.count))
                
                let lastWS = String(lines[lastIdx].prefix(while: { $0 == " " || $0 == "\t" }))
                lines[lastIdx] = lastWS + String(lines[lastIdx].dropFirst(lastWS.count)) + suffix
            }
            
            var newText = lines.joined(separator: "\n")
            if hadTrailingNewline { newText += "\n" }
            
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: lineRange, with: newText)
            textView.text = fullText as String
            textViewDidChange(textView)
        }
        
        private func performDeleteLine(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: lineRange, with: "")
            textView.text = fullText as String
            textView.selectedRange = NSRange(location: min(lineRange.location, max(0, (textView.text as NSString).length)), length: 0)
            textViewDidChange(textView)
        }
        
        private func performMoveLineUp(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            
            guard lineRange.location > 0 else { return } // Already at top
            
            let prevLineRange = text.lineRange(for: NSRange(location: lineRange.location - 1, length: 0))
            let currentLine = text.substring(with: lineRange)
            let prevLine = text.substring(with: prevLineRange)
            
            let combinedRange = NSUnionRange(prevLineRange, lineRange)
            let fullText = NSMutableString(string: textView.text)
            
            // Swap lines, preserving newline structure
            var swap = currentLine
            if !swap.hasSuffix("\n") && prevLine.hasSuffix("\n") {
                swap += "\n"
                let prevTrimmed = String(prevLine.dropLast())
                fullText.replaceCharacters(in: combinedRange, with: swap + prevTrimmed)
            } else {
                fullText.replaceCharacters(in: combinedRange, with: currentLine + prevLine)
            }
            textView.text = fullText as String
            
            let newLocation = prevLineRange.location + (selectedRange.location - lineRange.location)
            textView.selectedRange = NSRange(location: newLocation, length: selectedRange.length)
            textViewDidChange(textView)
        }
        
        private func performMoveLineDown(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            
            let lineEnd = lineRange.location + lineRange.length
            guard lineEnd < text.length else { return } // Already at bottom
            
            let nextLineRange = text.lineRange(for: NSRange(location: lineEnd, length: 0))
            let currentLine = text.substring(with: lineRange)
            let nextLine = text.substring(with: nextLineRange)
            
            let combinedRange = NSUnionRange(lineRange, nextLineRange)
            let fullText = NSMutableString(string: textView.text)
            
            // Swap: next line first, then current line
            var swap = nextLine
            if !swap.hasSuffix("\n") && currentLine.hasSuffix("\n") {
                swap += "\n"
                let curTrimmed = String(currentLine.dropLast())
                fullText.replaceCharacters(in: combinedRange, with: swap + curTrimmed)
            } else {
                fullText.replaceCharacters(in: combinedRange, with: nextLine + currentLine)
            }
            textView.text = fullText as String
            
            let newLocation = lineRange.location + nextLine.count + (selectedRange.location - lineRange.location)
            textView.selectedRange = NSRange(location: min(newLocation, (textView.text as NSString).length), length: selectedRange.length)
            textViewDidChange(textView)
        }
        
        private func performDuplicateLine(_ textView: TextView, above: Bool) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            var lineText = text.substring(with: lineRange)
            
            if !lineText.hasSuffix("\n") { lineText += "\n" }
            
            let fullText = NSMutableString(string: textView.text)
            if above {
                fullText.insert(lineText, at: lineRange.location)
                textView.text = fullText as String
                // Cursor stays on original line (now shifted down)
                textView.selectedRange = NSRange(location: selectedRange.location + lineText.count, length: selectedRange.length)
            } else {
                let insertAt = lineRange.location + lineRange.length
                fullText.insert(lineText, at: insertAt)
                textView.text = fullText as String
                // Cursor moves to duplicated line below
                textView.selectedRange = NSRange(location: selectedRange.location + lineText.count, length: selectedRange.length)
            }
            textViewDidChange(textView)
        }
        
        private func performAddNextOccurrence(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            guard selectedRange.length > 0 else { return }
            
            let selectedText = text.substring(with: selectedRange)
            let searchStart = selectedRange.location + selectedRange.length
            let searchRange = NSRange(location: searchStart, length: text.length - searchStart)
            let found = text.range(of: selectedText, options: [], range: searchRange)
            
            if found.location != NSNotFound {
                textView.selectedRange = found
            } else {
                // Wrap around
                let wrapRange = NSRange(location: 0, length: selectedRange.location)
                let wrapFound = text.range(of: selectedText, options: [], range: wrapRange)
                if wrapFound.location != NSNotFound {
                    textView.selectedRange = wrapFound
                }
            }
        }
        
        private func performSelectAllOccurrences(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            guard selectedRange.length > 0 else { return }
            
            let selectedText = text.substring(with: selectedRange)
            var lastFound = selectedRange
            var searchRange = NSRange(location: 0, length: text.length)
            
            while searchRange.location < text.length {
                let found = text.range(of: selectedText, options: [], range: searchRange)
                if found.location == NSNotFound { break }
                lastFound = found
                searchRange.location = found.location + found.length
                searchRange.length = text.length - searchRange.location
            }
            // Without true multi-cursor, jump to last occurrence
            textView.selectedRange = lastFound
        }
    }
}

// MARK: - Runestone Theme Implementation

/// Custom theme implementation for Runestone that maps app theme colors to editor appearance
class RunestoneEditorTheme: Runestone.Theme {
    let fontSize: CGFloat
    
    // Core colors
    private let _backgroundColor: UIColor
    private let _textColor: UIColor
    private let _gutterBackgroundColor: UIColor
    private let _gutterHairlineColor: UIColor
    private let _lineNumberColor: UIColor
    private let _selectedLineBackgroundColor: UIColor
    private let _selectedLinesLineNumberColor: UIColor
    private let _selectedLinesGutterBackgroundColor: UIColor
    private let _invisibleCharactersColor: UIColor
    private let _pageGuideHairlineColor: UIColor
    private let _pageGuideBackgroundColor: UIColor
    private let _markedTextBackgroundColor: UIColor
    
    // Syntax colors
    private let _keywordColor: UIColor
    private let _stringColor: UIColor
    private let _numberColor: UIColor
    private let _commentColor: UIColor
    private let _functionColor: UIColor
    private let _typeColor: UIColor
    private let _variableColor: UIColor
    
    init(
        fontSize: CGFloat,
        backgroundColor: UIColor,
        textColor: UIColor,
        gutterBackgroundColor: UIColor,
        gutterHairlineColor: UIColor,
        lineNumberColor: UIColor,
        selectedLineBackgroundColor: UIColor,
        selectedLinesLineNumberColor: UIColor,
        selectedLinesGutterBackgroundColor: UIColor,
        invisibleCharactersColor: UIColor,
        pageGuideHairlineColor: UIColor,
        pageGuideBackgroundColor: UIColor,
        markedTextBackgroundColor: UIColor,
        keywordColor: UIColor,
        stringColor: UIColor,
        numberColor: UIColor,
        commentColor: UIColor,
        functionColor: UIColor,
        typeColor: UIColor,
        variableColor: UIColor
    ) {
        self.fontSize = fontSize
        self._backgroundColor = backgroundColor
        self._textColor = textColor
        self._gutterBackgroundColor = gutterBackgroundColor
        self._gutterHairlineColor = gutterHairlineColor
        self._lineNumberColor = lineNumberColor
        self._selectedLineBackgroundColor = selectedLineBackgroundColor
        self._selectedLinesLineNumberColor = selectedLinesLineNumberColor
        self._selectedLinesGutterBackgroundColor = selectedLinesGutterBackgroundColor
        self._invisibleCharactersColor = invisibleCharactersColor
        self._pageGuideHairlineColor = pageGuideHairlineColor
        self._pageGuideBackgroundColor = pageGuideBackgroundColor
        self._markedTextBackgroundColor = markedTextBackgroundColor
        self._keywordColor = keywordColor
        self._stringColor = stringColor
        self._numberColor = numberColor
        self._commentColor = commentColor
        self._functionColor = functionColor
        self._typeColor = typeColor
        self._variableColor = variableColor
    }
    
    // MARK: - Theme Protocol Properties
    
    var font: UIFont {
        UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }
    
    var textColor: UIColor {
        _textColor
    }
    
    var gutterBackgroundColor: UIColor {
        _gutterBackgroundColor
    }
    
    var gutterHairlineColor: UIColor {
        _gutterHairlineColor
    }
    
    var lineNumberColor: UIColor {
        _lineNumberColor
    }
    
    var lineNumberFont: UIFont {
        UIFont.monospacedSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
    }
    
    var selectedLineBackgroundColor: UIColor {
        _selectedLineBackgroundColor
    }
    
    var selectedLinesLineNumberColor: UIColor {
        _selectedLinesLineNumberColor
    }
    
    var selectedLinesGutterBackgroundColor: UIColor {
        _selectedLinesGutterBackgroundColor
    }
    
    var invisibleCharactersColor: UIColor {
        _invisibleCharactersColor
    }
    
    var pageGuideHairlineColor: UIColor {
        _pageGuideHairlineColor
    }
    
    var pageGuideBackgroundColor: UIColor {
        _pageGuideBackgroundColor
    }
    
    var markedTextBackgroundColor: UIColor {
        _markedTextBackgroundColor
    }
    
    // MARK: - Syntax Highlighting
    
    func textColor(for rawHighlightName: String) -> UIColor? {
        // Map TreeSitter highlight names to colors
        // See: https://tree-sitter.github.io/tree-sitter/syntax-highlighting#highlights
        let highlightName = rawHighlightName.lowercased()
        
        #if DEBUG
        AppLogger.editor.debug("HIGHLIGHT: '\(rawHighlightName, privacy: .public)'")
        #endif
        
        // Keywords
        if highlightName.contains("keyword") {

            return _keywordColor
        }
        
        // JSON/Object keys - MUST return color for specific patterns
        // TreeSitter JSON emits BOTH "string.special.key" AND "string" for keys
        // We handle specific patterns first, then skip generic "string" to avoid overwrite
        if highlightName.hasPrefix("string.special") ||
           highlightName.contains("label") ||
           highlightName.contains("property.definition") {

            return _variableColor  // Light blue #9CDCFE for keys
        }
        
        // Strings - but NOT if it's JUST "string" (let specific matches win)
        // Only color strings that are clearly values, not potential keys
        if highlightName.contains("string") {

            return _stringColor  // Orange #CE9178 for string values
        }
        
        // Numbers and constants
        if highlightName.contains("number") || highlightName == "constant.numeric" {

            return _numberColor
        }
        
        // Comments
        if highlightName.contains("comment") {
            return _commentColor
        }
        
        // Functions and methods
        if highlightName.contains("function") || highlightName.contains("method") {
            return _functionColor
        }
        
        // Types, classes, structs
        if highlightName.contains("type") || highlightName.contains("class") ||
           highlightName.contains("struct") || highlightName.contains("interface") ||
           highlightName.contains("enum") {
            return _typeColor
        }
        
        // Variables, parameters, properties
        if highlightName.contains("variable") || highlightName.contains("parameter") ||
           highlightName.contains("property") || highlightName.contains("field") {
            return _variableColor
        }
        
        // Constants and booleans - use keyword color
        if highlightName.contains("constant") || highlightName.contains("boolean") {
            return _keywordColor
        }
        
        // Operators - use keyword color
        if highlightName.contains("operator") {
            return _keywordColor
        }
        
        // Namespaces and modules - use type color
        if highlightName.contains("namespace") || highlightName.contains("module") {
            return _typeColor
        }
        
        // Tags (HTML, XML) - use type color
        if highlightName.contains("tag") {
            return _typeColor
        }
        
        // Attributes - use variable color
        if highlightName.contains("attribute") {
            return _variableColor
        }
        
        // Spell checking highlights - ignore (return nil to use default)
        if highlightName.contains("spell") {
            return nil
        }
        
        // Include/import statements - use keyword color
        if highlightName.contains("include") {
            return _keywordColor
        }
        
        // Default: use standard text color

        return nil
    }
    
    func fontTraits(for rawHighlightName: String) -> FontTraits {
        let highlightName = rawHighlightName.lowercased()
        
        // Make comments italic
        if highlightName.contains("comment") {
            return .italic
        }
        
        // Make keywords bold
        if highlightName.contains("keyword") {
            return .bold
        }
        
        return []
    }
}



// MARK: - Preview
#if DEBUG
struct RunestoneEditorView_Previews: PreviewProvider {
    @State static var text = """
    func hello() {
        print("Hello, World!")
    }
    
    // This is a comment
    let number = 42
    let string = "test"
    """
    @State static var scrollOffset: CGFloat = 0
    @State static var totalLines = 7
    @State static var currentLineNumber = 1
    @State static var currentColumn = 1
    @State static var cursorIndex = 0
    
    static var previews: some View {
        RunestoneEditorView(
            text: $text,
            filename: "test.swift",
            scrollOffset: $scrollOffset,
            totalLines: $totalLines,
            currentLineNumber: $currentLineNumber,
            currentColumn: $currentColumn,
            cursorIndex: $cursorIndex,
            isActive: true,
            fontSize: 14
        )
        .environmentObject(EditorCore())
    }
}
#endif
