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
    var onAcceptInlineSuggestion: (() -> Bool)?
    
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
        onDismissAutocomplete: (() -> Bool)? = nil,
        onAcceptInlineSuggestion: (() -> Bool)? = nil
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
        self.onAcceptInlineSuggestion = onAcceptInlineSuggestion
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
        
        // Update theme if changed (consolidated: single makeRunestoneTheme call
        // even when both theme AND font change in the same SwiftUI update)
        let currentThemeId = ThemeManager.shared.currentTheme.id
        let themeChanged = context.coordinator.lastThemeId != currentThemeId
        let fontChanged = context.coordinator.lastFontSize != fontSize
        if themeChanged || fontChanged {
            if themeChanged { context.coordinator.lastThemeId = currentThemeId }
            if fontChanged { context.coordinator.lastFontSize = fontSize }
            textView.theme = makeRunestoneTheme()
            if themeChanged {
                textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
            }
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
            
            // Rebuild newline offset cache for the new file
            context.coordinator.rebuildNewlineOffsets(for: text as NSString)
            
            // Update line count
            DispatchQueue.main.async {
                self.totalLines = context.coordinator.lineCount
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
            
            // Rebuild newline offset cache for externally changed text
            context.coordinator.rebuildNewlineOffsets(for: text as NSString)
            
            // Update line count
            DispatchQueue.main.async {
                self.totalLines = context.coordinator.lineCount
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
        if let range = editorCore.requestedSelection {
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
            return nil // No Bash/Dockerfile grammar available in current package set
        }
        if lastComponent == ".env" || lastComponent.hasPrefix(".env.") {
            return nil // No dotenv grammar available; plain text
        }
        if lastComponent == "makefile" || lastComponent == "gnumakefile" {
            return nil // No Makefile grammar available in current package set
        }
        if lastComponent == "podfile" || lastComponent == "gemfile" {
            return nil // No Ruby grammar available in current package set
        }
        if lastComponent == "package.json" || lastComponent == "tsconfig.json"
            || lastComponent == "tsconfig.base.json" || lastComponent == "jsconfig.json"
            || lastComponent == ".babelrc" || lastComponent == ".eslintrc"
            || lastComponent == ".prettierrc" {
            return TreeSitterLanguage.json
        }
        
        switch ext {
        // Swift
        case "swift":
            return TreeSitterLanguage.swift
        
        // JavaScript
        case "js", "mjs", "cjs", "jsx":
            return TreeSitterLanguage.javaScript
        
        // TypeScript - use JavaScript grammar (closest available match; captures keywords/strings/comments)
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
        
        // JSON / JSON-like config formats
        case "json", "jsonc", "json5":
            return TreeSitterLanguage.json
        
        // HTML / HTML-like templates
        case "html", "htm", "xhtml":
            return TreeSitterLanguage.html
        
        // Jinja/Django/EJS templates - use HTML as closest match
        case "jinja", "jinja2", "j2", "ejs", "hbs", "handlebars", "mustache":
            return TreeSitterLanguage.html
        
        // CSS
        case "css":
            return TreeSitterLanguage.css
        
        // CSS preprocessors - use CSS grammar (captures selectors/properties/values)
        case "scss", "sass", "less":
            return TreeSitterLanguage.css
        
        // XML / XML-like formats - use HTML grammar (closest available match)
        case "xml", "plist", "svg", "xsl", "xslt", "xaml", "wsdl", "rss", "atom":
            return TreeSitterLanguage.html
        
        // Shell scripts - no shell grammar available; plain text
        // To add: import TreeSitterBashRunestone and return TreeSitterLanguage.bash
        case "sh", "bash", "zsh", "fish", "ksh", "csh", "tcsh", "command":
            return nil
        
        // Ruby - no grammar available; plain text
        // To add: import TreeSitterRubyRunestone and return TreeSitterLanguage.ruby
        case "rb", "rake", "gemspec", "podspec", "rbw":
            return nil
        
        // Java - no grammar available; plain text
        // To add: import TreeSitterJavaRunestone and return TreeSitterLanguage.java
        case "java":
            return nil
        
        // Kotlin - no grammar available; plain text
        // To add: import TreeSitterKotlinRunestone and return TreeSitterLanguage.kotlin
        case "kt", "kts":
            return nil
        
        // C / C++ - no grammar available; plain text
        // To add: import TreeSitterCRunestone / TreeSitterCPPRunestone
        case "c", "h", "cpp", "cc", "cxx", "c++", "hpp", "hxx", "hh":
            return nil
        
        // C# - no grammar available; plain text
        // To add: import TreeSitterCSharpRunestone and return TreeSitterLanguage.cSharp
        case "cs":
            return nil
        
        // PHP - no grammar available; plain text
        // To add: import TreeSitterPHPRunestone and return TreeSitterLanguage.php
        case "php", "phtml", "php3", "php4", "php5", "php7", "php8":
            return nil
        
        // YAML - no grammar available; plain text
        // To add: import TreeSitterYAMLRunestone and return TreeSitterLanguage.yaml
        case "yaml", "yml":
            return nil
        
        // TOML - no grammar available; plain text
        // To add: import TreeSitterTOMLRunestone and return TreeSitterLanguage.toml
        case "toml":
            return nil
        
        // Markdown - no grammar available; plain text
        // To add: import TreeSitterMarkdownRunestone and return TreeSitterLanguage.markdown
        case "md", "markdown", "mdx":
            return nil
        
        // GraphQL - use JavaScript grammar (shares enough syntax: braces, strings, comments)
        case "graphql", "gql":
            return TreeSitterLanguage.javaScript
        
        // Default - no syntax highlighting
        default:
            return nil
        }
    }

    
    // MARK: - Helpers
    
    /// PERF: Use the coordinator's cached newline offsets when available,
    /// otherwise fall back to a quick UTF-8 byte scan (no NSString allocation).
    private func countLines(in text: String) -> Int {
        guard !text.isEmpty else { return 1 }
        var count = 1
        for byte in text.utf8 {
            if byte == UInt8(ascii: "\n") { count += 1 }
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

        // MARK: - Newline Index Cache for O(log n) Cursor Position
        /// Sorted array of character offsets where each newline ('\n') occurs.
        /// Built once on file load / setState, updated incrementally on edits.
        /// Binary-searched in updateCursorPosition to find line number in O(log n).
        private var newlineOffsets: [Int] = []
        /// The text length when newlineOffsets was last fully rebuilt.
        /// Used to detect when a full rebuild is needed (e.g. file switch).
        private var newlineOffsetsTextLength: Int = -1
        /// O(1) line count derived from the cached newline offset array.
        var lineCount: Int { newlineOffsets.count + 1 }

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

        /// Overlay layer that draws a vertical guide line between matched bracket pairs.
        private let bracketGuideLayer: CAShapeLayer = {
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = UIColor.systemYellow.withAlphaComponent(0.35).cgColor
            layer.lineWidth = 1.0
            layer.lineDashPattern = nil
            layer.zPosition = 99
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
                .duplicateLineUp, .duplicateLineDown, .addNextOccurrence, .selectAllOccurrences,
                .selectLine, .indentLines, .outdentLines, .joinLines,
                .insertLineBelow, .insertLineAbove,
                .expandSelection, .shrinkSelection
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

            // Listen for format document notification
            editorActionObservers.append(
                NotificationCenter.default.addObserver(forName: .formatDocument, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        self?.handleFormatDocument()
                    }
                }
            )
            // Show Problems relay (Cmd+Shift+M)
            editorActionObservers.append(
                NotificationCenter.default.addObserver(forName: .showProblems, object: nil, queue: .main) { _ in
                    MainActor.assumeIsolated {
                        NotificationCenter.default.post(name: .switchToProblemsPanel, object: nil)
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
                    
                    // PERF: Use cached newline offsets instead of re-scanning
                    self.parent.totalLines = self.newlineOffsets.count + 1
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
                // PERF: Use cached newline offsets instead of re-scanning
                parent.totalLines = self.newlineOffsets.count + 1
            }
        }
        
        /// Cancel pending text sync without syncing - used when switching tabs
        /// to prevent stale content from overwriting new tab's content
        func cancelPendingTextSync() {
            textSyncWorkItem?.cancel()
            textSyncWorkItem = nil
        }

        // MARK: - Newline Index Helpers

        /// Fully rebuild the newline offset cache from scratch.
        /// Called on file load, file switch, or when the cache is invalidated.
        func rebuildNewlineOffsets(for text: NSString) {
            newlineOffsets.removeAll()
            var searchRange = NSRange(location: 0, length: text.length)
            while searchRange.location < text.length {
                let found = text.range(of: "\n", range: searchRange)
                if found.location == NSNotFound { break }
                newlineOffsets.append(found.location)
                searchRange.location = found.location + 1
                searchRange.length = text.length - searchRange.location
            }
            newlineOffsetsTextLength = text.length
        }

        /// Incrementally update the newline offset cache after a text edit.
        /// `editRange` is the range that was replaced, `replacementLength` is the length
        /// of the replacement string. This avoids a full O(n) rescan on every keystroke.
        func updateNewlineOffsets(editRange: NSRange, replacementText: NSString, in fullText: NSString) {
            let editEnd = editRange.location + editRange.length
            let delta = replacementText.length - editRange.length

            // 1. Remove offsets that fell inside the deleted range
            //    Find the index range of newlines within [editRange.location, editEnd)
            let removeStart = lowerBound(for: editRange.location)
            let removeEnd = lowerBound(for: editEnd)
            if removeStart < removeEnd {
                newlineOffsets.removeSubrange(removeStart..<removeEnd)
            }

            // 2. Shift all offsets after the edit by delta
            if delta != 0 {
                for i in removeStart..<newlineOffsets.count {
                    newlineOffsets[i] += delta
                }
            }

            // 3. Insert new newline offsets from the replacement text
            if replacementText.length > 0 {
                var insertOffsets: [Int] = []
                var sr = NSRange(location: 0, length: replacementText.length)
                while sr.location < replacementText.length {
                    let found = replacementText.range(of: "\n", range: sr)
                    if found.location == NSNotFound { break }
                    insertOffsets.append(editRange.location + found.location)
                    sr.location = found.location + 1
                    sr.length = replacementText.length - sr.location
                }
                if !insertOffsets.isEmpty {
                    // Insert at the correct position (removeStart) to maintain sorted order
                    newlineOffsets.insert(contentsOf: insertOffsets, at: removeStart)
                }
            }

            newlineOffsetsTextLength = fullText.length + delta
        }

        /// Binary search: find index of first element >= value
        private func lowerBound(for value: Int) -> Int {
            var lo = 0, hi = newlineOffsets.count
            while lo < hi {
                let mid = (lo + hi) / 2
                if newlineOffsets[mid] < value {
                    lo = mid + 1
                } else {
                    hi = mid
                }
            }
            return lo
        }

        /// Find line number (1-based) for a given character offset using binary search. O(log n).
        private func lineNumber(forOffset offset: Int) -> Int {
            // The line number is 1 + (number of newlines before offset)
            // lowerBound gives us the first newline at or after offset,
            // so the count of newlines strictly before offset is lowerBound(offset).
            return lowerBound(for: offset) + 1
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

        // MARK: - Format Document

        private func handleFormatDocument() {
            guard let textView = textView else { return }
            let text = textView.text
            guard !text.isEmpty else { return }
            
            let formatted = MainActor.assumeIsolated {
                let formatter = CodeFormatter.shared
                return formatter.format(code: text, filename: parent.filename)
            }
            
            guard formatted != text else {
                AppLogger.editor.info("Format Document: No changes needed")
                return
            }
            
            // Wrap the mutation in an undo group so Format Document is
            // reversible with a single Cmd+Z (undo) / Cmd+Shift+Z (redo).
            textView.undoManager?.beginUndoGrouping()
            textView.undoManager?.registerUndo(withTarget: self) { coordinator in
                guard let tv = coordinator.textView else { return }
                tv.text = text
                coordinator.parent.text = text
                MainActor.assumeIsolated {
                    coordinator.parent.editorCore.objectWillChange.send()
                }
            }
            textView.undoManager?.endUndoGrouping()
            
            textView.text = formatted
            parent.text = formatted
            MainActor.assumeIsolated {
                parent.editorCore.objectWillChange.send()
            }
            
            let ext = (parent.filename as NSString).pathExtension.lowercased()
            AppLogger.editor.info("Format Document: Applied formatting for .\(ext) file")
        }
        
        func textViewDidChangeSelection(_ textView: TextView) {
            updateCursorPosition(in: textView)
            updateBracketHighlight(in: textView)
        }
        
        func textViewDidBeginEditing(_ textView: TextView) {
            // Install the bracket-highlight overlay layers once the view is in the hierarchy
            if bracketHighlightLayer.superlayer == nil {
                textView.layer.addSublayer(bracketHighlightLayer)
            }
            if bracketGuideLayer.superlayer == nil {
                textView.layer.addSublayer(bracketGuideLayer)
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
                // First check inline suggestion
                let inlineAccepted = MainActor.assumeIsolated {
                    parent.onAcceptInlineSuggestion?()
                }
                if inlineAccepted == true { return false }
                // Then give autocomplete a chance to accept
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

            // Incrementally update newline cache for the edit Runestone will apply
            updateNewlineOffsets(
                editRange: range,
                replacementText: text as NSString,
                in: (textView.text as NSString)  // pre-edit text; updateNewlineOffsets accounts for delta
            )
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
                bracketGuideLayer.path = nil
                return
            }

            let highlightPath = CGMutablePath()
            let inset: CGFloat = 1.0

            var srcRect: CGRect? = nil
            var matchRect: CGRect? = nil

            for offset in [src, matchPos] {
                if let r = charRect(at: offset, in: textView) {
                    highlightPath.addRoundedRect(in: r.insetBy(dx: inset, dy: inset),
                                                 cornerWidth: 2, cornerHeight: 2)
                    if offset == src { srcRect = r }
                    else { matchRect = r }
                }
            }
            bracketHighlightLayer.path = highlightPath

            // Draw a vertical guide line between the two matched brackets
            if let top = srcRect, let bottom = matchRect {
                // Determine which bracket is above the other
                let upperRect = top.minY <= bottom.minY ? top : bottom
                let lowerRect = top.minY <= bottom.minY ? bottom : top

                // Only draw a guide when the brackets are on different lines
                if lowerRect.minY - upperRect.maxY > 1 {
                    // Guide X: left edge of the opening bracket, centered in its character
                    let guideX = upperRect.midX

                    let guidePath = CGMutablePath()
                    guidePath.move(to: CGPoint(x: guideX, y: upperRect.maxY))
                    guidePath.addLine(to: CGPoint(x: guideX, y: lowerRect.minY))
                    bracketGuideLayer.path = guidePath
                } else {
                    bracketGuideLayer.path = nil
                }
            } else {
                bracketGuideLayer.path = nil
            }
        }

        // MARK: - Cursor Position Calculation

        private func updateCursorPosition(in textView: TextView) {
            MainActor.assumeIsolated {
                let selectedRange = textView.selectedRange
                let text = textView.text as NSString
                let cursorLocation = selectedRange.location
                
                // Lazily rebuild the newline cache if it hasn't been built yet
                // (e.g. first cursor move after app launch, or after an external
                // text replacement that bypassed shouldChangeTextIn)
                if newlineOffsetsTextLength != text.length {
                    rebuildNewlineOffsets(for: text)
                }
                
                // O(log n) line number via binary search on cached newline offsets
                let line = lineNumber(forOffset: cursorLocation)
                
                // Column: distance from the start of the current line
                // The start of line N (1-based) is either 0 (line 1) or
                // newlineOffsets[N-2] + 1 (the character after the previous newline)
                let lineStartOffset: Int
                if line <= 1 {
                    lineStartOffset = 0
                } else {
                    let idx = line - 2  // index into newlineOffsets for previous line's newline
                    if idx < newlineOffsets.count {
                        lineStartOffset = newlineOffsets[idx] + 1
                    } else {
                        lineStartOffset = 0
                    }
                }
                let columnNumber = cursorLocation - lineStartOffset + 1
                
                // Update bindings
                parent.cursorIndex = cursorLocation
                parent.currentLineNumber = line
                parent.currentColumn = max(1, columnNumber)
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
            case .selectLine: performSelectLine(textView)
            case .indentLines: performIndentLines(textView)
            case .outdentLines: performOutdentLines(textView)
            case .joinLines: performJoinLines(textView)
            case .insertLineBelow: performInsertLineBelow(textView)
            case .insertLineAbove: performInsertLineAbove(textView)
            case .expandSelection: performExpandSelection(textView)
            case .shrinkSelection: performShrinkSelection(textView)
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
            
            textView.undoManager?.beginUndoGrouping()
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: lineRange, with: newText)
            textView.text = fullText as String
            
            // Adjust selection
            let lengthDiff = newText.count - linesText.count
            textView.selectedRange = NSRange(
                location: min(selectedRange.location + (allCommented ? -(prefix.count + 1) : (prefix.count + 1)), max(0, (textView.text as NSString).length)),
                length: max(0, selectedRange.length + lengthDiff)
            )
            textView.undoManager?.endUndoGrouping()
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
            
            textView.undoManager?.beginUndoGrouping()
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: lineRange, with: newText)
            textView.text = fullText as String
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performDeleteLine(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            
            textView.undoManager?.beginUndoGrouping()
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: lineRange, with: "")
            textView.text = fullText as String
            textView.selectedRange = NSRange(location: min(lineRange.location, max(0, (textView.text as NSString).length)), length: 0)
            textView.undoManager?.endUndoGrouping()
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
            textView.undoManager?.beginUndoGrouping()
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
            textView.undoManager?.endUndoGrouping()
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
            textView.undoManager?.beginUndoGrouping()
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
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performDuplicateLine(_ textView: TextView, above: Bool) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            var lineText = text.substring(with: lineRange)
            
            if !lineText.hasSuffix("\n") { lineText += "\n" }
            
            textView.undoManager?.beginUndoGrouping()
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
            textView.undoManager?.endUndoGrouping()
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
            let nsText = textView.text as NSString
            let selectedRange = textView.selectedRange

            // If nothing selected, try to select the word under the cursor
            var searchText: String
            if selectedRange.length > 0 {
                searchText = nsText.substring(with: selectedRange)
            } else {
                // Expand to word under cursor
                let loc = selectedRange.location
                var wordStart = loc
                var wordEnd = loc
                let wordChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
                while wordStart > 0 {
                    let ch = nsText.character(at: wordStart - 1)
                    let scalar = Unicode.Scalar(ch)!
                    if wordChars.contains(scalar) { wordStart -= 1 } else { break }
                }
                while wordEnd < nsText.length {
                    let ch = nsText.character(at: wordEnd)
                    let scalar = Unicode.Scalar(ch)!
                    if wordChars.contains(scalar) { wordEnd += 1 } else { break }
                }
                guard wordEnd > wordStart else { return }
                searchText = nsText.substring(with: NSRange(location: wordStart, length: wordEnd - wordStart))
            }

            guard !searchText.isEmpty else { return }

            // Find all occurrences
            var occurrences: [NSRange] = []
            var searchRange = NSRange(location: 0, length: nsText.length)
            while searchRange.location < nsText.length {
                let found = nsText.range(of: searchText, options: [], range: searchRange)
                if found.location == NSNotFound { break }
                occurrences.append(found)
                searchRange.location = found.location + found.length
                searchRange.length = nsText.length - searchRange.location
            }

            guard !occurrences.isEmpty else { return }

            // Highlight all occurrences with a background overlay using a CALayer
            showOccurrenceHighlights(occurrences: occurrences, in: textView)

            // Move cursor to first occurrence
            textView.selectedRange = occurrences[0]

            // Show count badge
            showOccurrenceBadge(count: occurrences.count, in: textView)
        }

        /// Renders translucent highlight rectangles over all found occurrences using CAShapeLayer.
        private func showOccurrenceHighlights(occurrences: [NSRange], in textView: TextView) {
            // Remove any previous occurrence highlight layer
            textView.layer.sublayers?.removeAll(where: { $0.name == "occurrenceHighlight" })

            guard !occurrences.isEmpty else { return }

            let highlightLayer = CAShapeLayer()
            highlightLayer.name = "occurrenceHighlight"
            highlightLayer.fillColor = UIColor.systemBlue.withAlphaComponent(0.25).cgColor
            highlightLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.55).cgColor
            highlightLayer.lineWidth = 1.0
            highlightLayer.zPosition = 98
            textView.layer.addSublayer(highlightLayer)

            let path = CGMutablePath()
            for range in occurrences {
                if let startRect = charRect(at: range.location, in: textView),
                   range.length > 0,
                   let endRect = charRect(at: range.location + range.length - 1, in: textView) {
                    // Build a rect spanning from start to end of the occurrence on the same line
                    let highlightRect = CGRect(
                        x: startRect.minX,
                        y: startRect.minY,
                        width: endRect.maxX - startRect.minX,
                        height: max(startRect.height, endRect.height)
                    ).insetBy(dx: 0, dy: 1)
                    path.addRoundedRect(in: highlightRect, cornerWidth: 2, cornerHeight: 2)
                }
            }
            highlightLayer.path = path

            // Auto-remove highlights after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak textView] in
                textView?.layer.sublayers?.removeAll(where: { $0.name == "occurrenceHighlight" })
                textView?.layer.sublayers?.removeAll(where: { $0.name == "occurrenceBadge" })
            }
        }

        /// Shows a small count badge ("X occurrences") near the top-right of the text view.
        private func showOccurrenceBadge(count: Int, in textView: TextView) {
            // Remove previous badge
            textView.layer.sublayers?.removeAll(where: { $0.name == "occurrenceBadge" })

            let label = UILabel()
            label.text = "\(count) occurrence\(count == 1 ? "" : "s")"
            label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            label.textColor = .white
            label.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            label.textAlignment = .center
            label.sizeToFit()
            let padding: CGFloat = 8
            label.frame = label.frame.insetBy(dx: -padding, dy: -3)
            label.frame.origin = CGPoint(
                x: textView.bounds.width - label.frame.width - 12,
                y: (textView.contentOffset.y) + 12
            )
            textView.addSubview(label)
            label.layer.name = "occurrenceBadge"

            // Fade out after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIView.animate(withDuration: 0.4) { label.alpha = 0 } completion: { _ in label.removeFromSuperview() }
            }
        }
        
        private func performSelectLine(_ textView: TextView) {
            let text = textView.text as NSString
            let lineRange = text.lineRange(for: textView.selectedRange)
            textView.selectedRange = lineRange
        }

        private func performExpandSelection(_ textView: TextView) {
            let text = textView.text as NSString
            let fullRange = NSRange(location: 0, length: text.length)
            let sel = textView.selectedRange

            // If nothing selected, select the current word
            if sel.length == 0 {
                if let uiTextView = textView as? UITextView,
                   let pos = uiTextView.position(from: uiTextView.beginningOfDocument, offset: sel.location) {
                    let wordRange = uiTextView.tokenizer.rangeEnclosingPosition(
                        pos,
                        with: .word,
                        inDirection: UITextDirection(rawValue: UITextStorageDirection.forward.rawValue)
                    )
                    if let wordRange = wordRange {
                        let start = uiTextView.offset(from: uiTextView.beginningOfDocument, to: wordRange.start)
                        let length = uiTextView.offset(from: wordRange.start, to: wordRange.end)
                        let nsRange = NSRange(location: start, length: length)
                        if nsRange.length > 0 {
                            textView.selectedRange = nsRange
                            return
                        }
                    }
                }
                // Fallback: expand to line
                textView.selectedRange = text.lineRange(for: sel)
                return
            }

            // If selection is already the full document, nothing to expand
            if sel == fullRange { return }

            // Compute line range for current selection
            let lineRange = text.lineRange(for: sel)

            // If selection already covers the full line range, expand to all
            if sel.location == lineRange.location && sel.length == lineRange.length {
                textView.selectedRange = fullRange
                return
            }

            // Otherwise expand to line range
            textView.selectedRange = lineRange
        }

        private func performShrinkSelection(_ textView: TextView) {
            let text = textView.text as NSString
            let fullRange = NSRange(location: 0, length: text.length)
            let sel = textView.selectedRange

            // Nothing to shrink if cursor
            if sel.length == 0 { return }

            // If all selected, shrink to current line (use midpoint to pick a line)
            if sel.location == fullRange.location && sel.length == fullRange.length {
                let midpoint = NSRange(location: text.length / 2, length: 0)
                textView.selectedRange = text.lineRange(for: midpoint)
                return
            }

            // If selection equals its own line range, try to shrink to word
            let lineRange = text.lineRange(for: sel)
            if sel.location == lineRange.location && sel.length == lineRange.length {
                if let uiTextView = textView as? UITextView,
                   let pos = uiTextView.position(from: uiTextView.beginningOfDocument, offset: sel.location) {
                    let wordRange = uiTextView.tokenizer.rangeEnclosingPosition(
                        pos,
                        with: .word,
                        inDirection: UITextDirection(rawValue: UITextStorageDirection.forward.rawValue)
                    )
                    if let wordRange = wordRange {
                        let start = uiTextView.offset(from: uiTextView.beginningOfDocument, to: wordRange.start)
                        let length = uiTextView.offset(from: wordRange.start, to: wordRange.end)
                        let nsRange = NSRange(location: start, length: length)
                        if nsRange.length > 0 {
                            textView.selectedRange = nsRange
                            return
                        }
                    }
                }
                // Fallback: collapse to cursor
                textView.selectedRange = NSRange(location: sel.location, length: 0)
                return
            }

            // Otherwise collapse to cursor (start of selection)
            textView.selectedRange = NSRange(location: sel.location, length: 0)
        }

        private func performIndentLines(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            let linesText = text.substring(with: lineRange)
            var lines = linesText.components(separatedBy: "\n")
            
            let hadTrailingNewline = linesText.hasSuffix("\n")
            if hadTrailingNewline && lines.last == "" { lines.removeLast() }
            
            let tabSz = max(1, parent.tabSize)
            let indent = parent.insertSpaces ? String(repeating: " ", count: tabSz) : "\t"
            lines = lines.map { line in
                if line.trimmingCharacters(in: .whitespaces).isEmpty { return line }
                return indent + line
            }
            
            var newText = lines.joined(separator: "\n")
            if hadTrailingNewline { newText += "\n" }
            
            textView.undoManager?.beginUndoGrouping()
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: lineRange, with: newText)
            textView.text = fullText as String
            
            // Adjust selection to cover the indented lines
            let lengthDiff = newText.count - linesText.count
            textView.selectedRange = NSRange(
                location: selectedRange.location + indent.count,
                length: max(0, selectedRange.length + lengthDiff - indent.count)
            )
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performOutdentLines(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            let linesText = text.substring(with: lineRange)
            var lines = linesText.components(separatedBy: "\n")
            
            let hadTrailingNewline = linesText.hasSuffix("\n")
            if hadTrailingNewline && lines.last == "" { lines.removeLast() }
            
            // Track how many chars removed from the first line (for cursor adjustment)
            let tabSz = max(1, parent.tabSize)
            var firstLineRemoved = 0
            var totalRemoved = 0
            
            lines = lines.enumerated().map { (index, line) in
                var removed = 0
                var result = line
                // Remove up to tabSize leading spaces or 1 leading tab
                if result.hasPrefix("\t") {
                    result = String(result.dropFirst())
                    removed = 1
                } else {
                    while removed < tabSz && result.hasPrefix(" ") {
                        result = String(result.dropFirst())
                        removed += 1
                    }
                }
                if index == 0 { firstLineRemoved = removed }
                totalRemoved += removed
                return result
            }
            
            guard totalRemoved > 0 else { return } // Nothing to outdent
            
            var newText = lines.joined(separator: "\n")
            if hadTrailingNewline { newText += "\n" }
            
            textView.undoManager?.beginUndoGrouping()
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: lineRange, with: newText)
            textView.text = fullText as String
            
            // Adjust selection
            let newLocation = max(lineRange.location, selectedRange.location - firstLineRemoved)
            let lengthDiff = newText.count - linesText.count
            textView.selectedRange = NSRange(
                location: newLocation,
                length: max(0, selectedRange.length + lengthDiff + firstLineRemoved)
            )
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performJoinLines(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: NSRange(location: selectedRange.location, length: 0))
            
            let lineEnd = lineRange.location + lineRange.length
            guard lineEnd < text.length else { return } // No next line to join
            
            // Find the newline at the end of the current line and remove it,
            // along with leading whitespace on the next line, replacing with a single space.
            let nextLineRange = text.lineRange(for: NSRange(location: lineEnd, length: 0))
            let nextLineText = text.substring(with: nextLineRange)
            let trimmedNextLine = nextLineText.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
            
            // Current line without its trailing newline
            var currentLineText = text.substring(with: lineRange)
            if currentLineText.hasSuffix("\n") {
                currentLineText = String(currentLineText.dropLast())
            }
            
            // Join with a single space (unless next line is empty)
            let joined = trimmedNextLine.isEmpty ? currentLineText + "\n" : currentLineText + " " + trimmedNextLine
            
            let combinedRange = NSUnionRange(lineRange, nextLineRange)
            textView.undoManager?.beginUndoGrouping()
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: combinedRange, with: joined)
            textView.text = fullText as String
            
            // Place cursor at the join point
            textView.selectedRange = NSRange(location: currentLineText.count, length: 0)
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performInsertLineBelow(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: NSRange(location: selectedRange.location, length: 0))
            
            // Get current line's indentation
            let currentLine = text.substring(with: lineRange)
            let indent = currentLine.prefix(while: { $0 == " " || $0 == "\t" })
            
            // Insert newline + indent after the end of the current line content
            // lineRange includes the trailing \n, so insert before it to keep the newline order correct
            let lineEnd = currentLine.hasSuffix("\n") ? lineRange.location + lineRange.length - 1 : lineRange.location + lineRange.length
            let insertText = "\n" + String(indent)
            
            textView.undoManager?.beginUndoGrouping()
            let fullText = NSMutableString(string: textView.text)
            fullText.insert(insertText, at: lineEnd)
            textView.text = fullText as String
            
            // Place cursor at end of new line (after indent)
            let newCursorPos = lineEnd + 1 + indent.count
            textView.selectedRange = NSRange(location: newCursorPos, length: 0)
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performInsertLineAbove(_ textView: TextView) {
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: NSRange(location: selectedRange.location, length: 0))
            
            // Get current line's indentation
            let currentLine = text.substring(with: lineRange)
            let indent = currentLine.prefix(while: { $0 == " " || $0 == "\t" })
            
            // Insert newline + indent before current line
            let insertText = String(indent) + "\n"
            
            textView.undoManager?.beginUndoGrouping()
            let fullText = NSMutableString(string: textView.text)
            fullText.insert(insertText, at: lineRange.location)
            textView.text = fullText as String
            
            // Place cursor at end of indent on the new line
            let newCursorPos = lineRange.location + indent.count
            textView.selectedRange = NSRange(location: newCursorPos, length: 0)
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
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
