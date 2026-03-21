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
import TreeSitterTypeScriptRunestone
import TreeSitterTSXRunestone
import TreeSitterPythonRunestone
import TreeSitterJSONRunestone
import TreeSitterHTMLRunestone
import TreeSitterCSSRunestone
import TreeSitterSCSSRunestone
import TreeSitterGoRunestone
import TreeSitterRustRunestone
import TreeSitterBashRunestone
import TreeSitterCRunestone
import TreeSitterCPPRunestone
import TreeSitterCSharpRunestone
import TreeSitterJavaRunestone
import TreeSitterRubyRunestone
import TreeSitterPHPRunestone
import TreeSitterYAMLRunestone
import TreeSitterTOMLRunestone
import TreeSitterMarkdownRunestone
import TreeSitterSQLRunestone
import TreeSitterLuaRunestone
import TreeSitterAstroRunestone
import TreeSitterElixirRunestone
import TreeSitterElmRunestone
import TreeSitterHaskellRunestone
import TreeSitterJSON5Runestone
import TreeSitterJuliaRunestone
import TreeSitterLaTeXRunestone
import TreeSitterOCamlRunestone
import TreeSitterPerlRunestone
import TreeSitterRRunestone
import TreeSitterSvelteRunestone
import TreeSitterMarkdownInlineRunestone
// Injection grammars (auto-used by parent languages, no standalone case needed)
import TreeSitterCommentRunestone
import TreeSitterJSDocRunestone
import TreeSitterRegexRunestone

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
    @AppStorage("lineNumbersStyle") private var lineNumbersStyle: String = "on"
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
        
        // Custom fold-aware gutter handles line numbers — disable Runestone's built-in
        textView.showLineNumbers = false
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
        // PERF: Disable TreeSitter for very large files (100K+ lines) to prevent parser OOM
        let tier = LargeFileHandler.shared.currentTier
        if tier.enableFullSyntaxHighlight, let language = getTreeSitterLanguage(for: filename) {
            let state = TextViewState(text: text, language: language)
            textView.setState(state)
        } else {
            // No language support or file too large - fallback to plain text
            textView.text = text
        }
        
        // Set theme AFTER setState to ensure it takes effect
        // setState may reset internal rendering state, so theme must come after
        textView.theme = makeRunestoneTheme()
        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
        
        // Store reference for coordinator
        context.coordinator.textView = textView
        context.coordinator.multiCursorManager.textView = textView

        // Wire code-folding text mutation for Runestone path.
        // CodeFoldingManager.shared.currentText must stay in sync with what is displayed.
        // onTextMutation is called by applyTextFold/revertTextFold after mutating text;
        // we push the new text into Runestone's textView and immediately sync the binding.
        CodeFoldingManager.shared.currentText = text
        let coordinator = context.coordinator
        CodeFoldingManager.shared.onTextMutation = { [weak coordinator] newText in
            guard let coordinator = coordinator,
                  let tv = coordinator.textView else { return }
            coordinator.isFoldMutation = true
            // Disable undo registration so fold/unfold doesn't pollute the undo stack
            tv.undoManager?.disableUndoRegistration()
            tv.text = newText
            tv.undoManager?.enableUndoRegistration()
            coordinator.isFoldMutation = false
            // Sync binding and line count immediately (fold is a discrete user action)
            coordinator.isUpdatingFromTextView = true
            coordinator.parent.text = newText
            coordinator.parent.totalLines = coordinator.lineCount
            coordinator.isUpdatingFromTextView = false
            // Rebuild newline cache so cursor positions stay correct
            coordinator.rebuildNewlineOffsets(for: newText as NSString)
            NotificationCenter.default.post(name: .codeFoldingDidChange, object: nil)
        }

        // Accessibility
        textView.accessibilityLabel = "Code editor"
        textView.accessibilityHint = "Edit code here. Use rotor to navigate by line."
        textView.isAccessibilityElement = true
        
        // Initial line count
        DispatchQueue.main.async {
            self.totalLines = self.countLines(in: text)
        }
        
        // Initial fold region detection — detect foldable regions for the loaded file
        let capturedFilename = filename
        let capturedText = text
        DispatchQueue.main.async {
            CodeFoldingManager.shared.detectFoldableRegions(in: capturedText, filePath: capturedFilename)
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
        
        // Custom fold-aware gutter always shown — Runestone built-in line numbers off
        textView.showLineNumbers = false
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
        
        // Guard: skip setState during SwiftUI teardown (view removed from hierarchy)
        guard textView.window != nil else { return }
        
        let isFileSwitching = context.coordinator.lastFilename != filename
        let currentText = textView.text
        let textChanged = currentText != text
        let isActivelyEditing = textView.isFirstResponder
        
        // CRITICAL: Cancel any pending debounced updates before tab switch to prevent
        // race condition where stale content overwrites new tab's content
        if isFileSwitching {
            context.coordinator.cancelPendingTextSync()
            context.coordinator.multiCursorManager.reset()
            
            // User switched to a different file - safe to call setState()
            context.coordinator.lastFilename = filename
            context.coordinator.hasBeenEdited = false
            // Keep CodeFoldingManager's shadow text in sync for the new file
            CodeFoldingManager.shared.currentText = text
            
            // PERF: Skip TreeSitter for very large files
            let tier = LargeFileHandler.shared.currentTier
            if tier.enableFullSyntaxHighlight, let language = getTreeSitterLanguage(for: filename) {
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
            
            // Detect foldable regions for the newly loaded file
            let switchedFilename = filename
            let switchedText = text
            DispatchQueue.main.async {
                CodeFoldingManager.shared.detectFoldableRegions(in: switchedText, filePath: switchedFilename)
            }
        } else if textChanged && !context.coordinator.hasBeenEdited && !isActivelyEditing && !context.coordinator.isUpdatingFromTextView {
            // Text changed externally (e.g., initial load, external modification)
            // Safe to update since user hasn't started editing yet
            // Keep CodeFoldingManager's shadow text in sync
            CodeFoldingManager.shared.currentText = text
            // PERF: Skip TreeSitter for very large files
            let tier2 = LargeFileHandler.shared.currentTier
            if tier2.enableFullSyntaxHighlight, let language = getTreeSitterLanguage(for: filename) {
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
        let computedLineHeight = ceil(font.lineHeight * 1.3)
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
            return TreeSitterLanguage.ruby
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
        
        // TypeScript
        case "ts", "mts", "cts":
            return TreeSitterLanguage.typeScript
        
        // TSX - use dedicated TSX grammar
        case "tsx":
            return TreeSitterLanguage.tsx
        
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
        
        // JSON5 - dedicated grammar with relaxed syntax
        case "json5":
            return TreeSitterLanguage.json5
        
        // HTML / HTML-like templates
        case "html", "htm", "xhtml":
            return TreeSitterLanguage.html
        
        // Jinja/Django/EJS templates - use HTML as closest match
        case "jinja", "jinja2", "j2", "ejs", "hbs", "handlebars", "mustache":
            return TreeSitterLanguage.html
        
        // CSS
        case "css":
            return TreeSitterLanguage.css
        
        // SCSS - dedicated grammar for variables, nesting, mixins
        case "scss", "sass", "less":
            return TreeSitterLanguage.scss
        
        // XML / XML-like formats - use HTML grammar (closest available match)
        case "xml", "plist", "svg", "xsl", "xslt", "xaml", "wsdl", "rss", "atom":
            return TreeSitterLanguage.html
        
        // Shell scripts
        case "sh", "bash", "zsh", "fish", "ksh", "csh", "tcsh", "command":
            return TreeSitterLanguage.bash
        
        // Ruby
        case "rb", "rake", "gemspec", "podspec", "rbw":
            return TreeSitterLanguage.ruby
        
        // Java
        case "java":
            return TreeSitterLanguage.java
        
        // Kotlin - no grammar available; plain text
        // To add: import TreeSitterKotlinRunestone and return TreeSitterLanguage.kotlin
        case "kt", "kts":
            return nil
        
        // C / C++
        case "c", "h":
            return TreeSitterLanguage.c
        case "cpp", "cc", "cxx", "c++", "hpp", "hxx", "hh":
            return TreeSitterLanguage.cpp
        
        // C#
        case "cs":
            return TreeSitterLanguage.cSharp
        
        // PHP
        case "php", "phtml", "php3", "php4", "php5", "php7", "php8":
            return TreeSitterLanguage.php
        
        // YAML
        case "yaml", "yml":
            return TreeSitterLanguage.yaml
        
        // TOML
        case "toml":
            return TreeSitterLanguage.toml
        
        // Markdown
        case "md", "markdown", "mdx":
            return TreeSitterLanguage.markdown
        
        // SQL
        case "sql", "ddl", "dml":
            return TreeSitterLanguage.sql
        
        // Lua
        case "lua":
            return TreeSitterLanguage.lua
        
        // Elixir
        case "ex", "exs":
            return TreeSitterLanguage.elixir
        
        // Elm
        case "elm":
            return TreeSitterLanguage.elm
        
        // Haskell
        case "hs", "lhs":
            return TreeSitterLanguage.haskell
        
        // Julia
        case "jl":
            return TreeSitterLanguage.julia
        
        // LaTeX
        case "tex", "latex", "sty", "cls", "bib":
            return TreeSitterLanguage.latex
        
        // OCaml
        case "ml", "mli":
            return TreeSitterLanguage.ocaml
        
        // Perl
        case "pl", "pm", "t":
            return TreeSitterLanguage.perl
        
        // R
        case "r", "rmd", "rprofile":
            return TreeSitterLanguage.r
        
        // Astro
        case "astro":
            return TreeSitterLanguage.astro
        
        // Svelte
        case "svelte":
            return TreeSitterLanguage.svelte
        
        // GraphQL - no dedicated grammar, use plain text
        case "graphql", "gql":
            return nil
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
    @MainActor class Coordinator: NSObject, @preconcurrency TextViewDelegate, @unchecked Sendable {
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
        /// Set to true while CodeFoldingManager is mutating text for a fold/unfold.
        /// Prevents textViewDidChange from marking the document as user-edited or
        /// debounce-syncing stale content back to the SwiftUI binding.
        var isFoldMutation = false


        // Find/Replace: track last handled selection to avoid re-applying
        var lastHandledSelection: NSRange? = nil
        
        // Debounced text sync to avoid SwiftUI re-renders on every keystroke
        // SAFETY: These are marked nonisolated(unsafe) because Coordinator is not @MainActor,
        // but they are ONLY accessed from the main thread (textViewDidChange, cancelPendingTextSync,
        // deinit, and DispatchQueue.main.asyncAfter callbacks). This is safe but fragile —
        // any future access from a background thread would be a data race.
        nonisolated(unsafe) private var textSyncWorkItem: DispatchWorkItem?
        private let debounceInterval: TimeInterval = 0.5 // 500ms
        nonisolated(unsafe) private var forceSyncObserver: NSObjectProtocol?
        nonisolated(unsafe) private var editorActionObservers: [NSObjectProtocol] = []

        // MARK: - Multi-Cursor
        let multiCursorManager = RunestoneMultiCursorManager()
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

            // Multi-cursor: Add Cursor Above/Below (Cmd+Option+Up/Down)
            editorActionObservers.append(
                NotificationCenter.default.addObserver(forName: .addCursorAbove, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        self?.multiCursorManager.addCursorAbove()
                    }
                }
            )
            editorActionObservers.append(
                NotificationCenter.default.addObserver(forName: .addCursorBelow, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        self?.multiCursorManager.addCursorBelow()
                    }
                }
            )
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
            // Listen for single-line fold/unfold notifications
            editorActionObservers.append(
                NotificationCenter.default.addObserver(forName: .foldCurrentLine, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        guard let self, let tv = self.textView else { return }
                        let line = max(0, self.parent.currentLineNumber - 1)
                        // Sync shadow text before mutation
                        CodeFoldingManager.shared.currentText = tv.text
                        CodeFoldingManager.shared.foldAtLine(line)
                        // onTextMutation handles textView update; notify overlays
                        self.notifyFoldingChanged()
                    }
                }
            )
            editorActionObservers.append(
                NotificationCenter.default.addObserver(forName: .unfoldCurrentLine, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        guard let self, let tv = self.textView else { return }
                        let line = max(0, self.parent.currentLineNumber - 1)
                        // Sync shadow text before mutation
                        CodeFoldingManager.shared.currentText = tv.text
                        CodeFoldingManager.shared.unfoldAtLine(line)
                        // onTextMutation handles textView update; notify overlays
                        self.notifyFoldingChanged()
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
            // Escape key: exit multi-cursor mode (also hides search)
            editorActionObservers.append(
                NotificationCenter.default.addObserver(forName: .hideSearch, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        self?.multiCursorManager.reset()
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
            // Fold mutations must not mark the document dirty or trigger debounced sync
            guard !isFoldMutation else { return }

            // Mark that user has edited - blocks setState() calls until file switch
            hasBeenEdited = true

            // Record text layout timing for performance monitoring
            let layoutStart = CACurrentMediaTime()
            // Cancel any pending debounced update
            textSyncWorkItem?.cancel()
            
            // Create new debounced work item
            // Capture filename at creation time to detect stale updates after tab switch
            let capturedFilename = self.parent.filename
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                MainActor.assumeIsolated {
                    // Guard: skip if file changed since this work item was created
                    guard self.parent.filename == capturedFilename else { return }
                    // Guard: skip if textView was removed from hierarchy
                    guard self.textView?.window != nil else { return }
                    
                    self.isUpdatingFromTextView = true
                    defer { self.isUpdatingFromTextView = false }
                    
                    // Update text binding (debounced - only after typing stops)
                    self.parent.text = textView.text
                    // Keep CodeFoldingManager's shadow text in sync with user edits
                    CodeFoldingManager.shared.currentText = textView.text

                    // Invalidate syntax highlight cache for this file
                    let filename = self.parent.filename
                    Task {
                        await SyntaxHighlightCache.shared.invalidateFile(filename)
                    }

                    // PERF: Use cached newline offsets instead of re-scanning
                    self.parent.totalLines = self.newlineOffsets.count + 1

                    // Incremental fold region detection after text change
                    let editedLine = self.parent.currentLineNumber
                    let totalLineCount = self.newlineOffsets.count + 1
                    let foldEditRange = max(0, editedLine - 3)...min(editedLine + 3, max(0, totalLineCount - 1))
                    CodeFoldingManager.shared.incrementalUpdateFoldRegions(
                        in: textView.text,
                        editedLineRange: foldEditRange,
                        filePath: filename
                    )
                }
            }
            
            // Schedule the update after debounce interval
            textSyncWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)

            // Record layout time for perf monitor degradation decisions
            let layoutMs = (CACurrentMediaTime() - layoutStart) * 1000
            EditorPerformanceMonitor.shared.recordTextLayoutTime(layoutMs)
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

        /// Adjust BreakpointStore when a text replacement may change line numbers.
        /// Pass the pre-edit NSString, the replaced range, and the replacement string.
        private func adjustBreakpointsForEdit(range: NSRange, replacementText: String, in preEditText: NSString) {
            let deletedNewlines = (preEditText.substring(with: range) as NSString)
                .components(separatedBy: "\n").count - 1
            let insertedNewlines = (replacementText as NSString)
                .components(separatedBy: "\n").count - 1
            let delta = insertedNewlines - deletedNewlines
            if delta != 0 || deletedNewlines > 0 {
                let editedLine = lineNumber(forOffset: range.location)
                BreakpointStore.shared.adjustForEdit(
                    in: parent.filename,
                    editedLine: editedLine,
                    linesDelta: delta
                )
            }
        }

        // MARK: - Code Folding

        /// Handles the collapseAllFolds notification from EditorCore.
        @MainActor private func handleCollapseAllFolds() {
            // Ensure shadow text is current before fold mutation
            if let tv = textView { CodeFoldingManager.shared.currentText = tv.text }
            CodeFoldingManager.shared.collapseAll()
            // onTextMutation callback handles text/binding update; just notify overlays
            notifyFoldingChanged()
        }

        /// Handles the expandAllFolds notification from EditorCore.
        @MainActor private func handleExpandAllFolds() {
            // Ensure shadow text is current before unfold mutation
            if let tv = textView { CodeFoldingManager.shared.currentText = tv.text }
            CodeFoldingManager.shared.expandAll()
            // onTextMutation callback handles text/binding update; just notify overlays
            notifyFoldingChanged()
        }

        /// Notify the gutter, minimap, and other overlays that fold state changed.
        /// CodeFoldingManager.applyTextFold/revertTextFold already mutated the text and called
        /// onTextMutation to push the change into Runestone's textView and the SwiftUI binding.
        /// This method just signals visual consumers (gutter, minimap, breakpoints) to re-render.
        @MainActor private func notifyFoldingChanged() {
            // Post notification so gutter, minimap, breakpoints, etc. re-render
            NotificationCenter.default.post(name: .codeFoldingDidChange, object: nil)
            // Force SwiftUI to re-evaluate overlays
            parent.editorCore.objectWillChange.send()
        }

        // MARK: - Format Document

        private func handleFormatDocument() {
            guard let textView = textView else { return }
            let text = textView.text
            guard !text.isEmpty else { return }
            
            // Resolve document URI and language ID from the active tab
            let filename = parent.filename
            let uri: String?
            let languageId: String
            if let tabIdx = parent.editorCore.activeTabIndex,
               tabIdx < parent.editorCore.tabs.count {
                let tab = parent.editorCore.tabs[tabIdx]
                uri = tab.url?.absoluteString
                languageId = tab.language.rawValue
            } else {
                uri = nil
                languageId = CodeFormatter.shared.detectLanguage(from: filename)
            }
            
            // If we have a URI, try LSP formatting (async) first
            if let uri = uri {
                Task { @MainActor in
                    let formatter = CodeFormatter.shared
                    let formatted = await formatter.formatWithLSP(
                        uri: uri,
                        languageId: languageId,
                        text: text,
                        filename: filename
                    )
                    self.applyFormattedText(formatted, originalText: text, filename: filename)
                }
            } else {
                // No URI — use local-only formatting
                let formatted = MainActor.assumeIsolated {
                    CodeFormatter.shared.format(code: text, filename: filename)
                }
                applyFormattedText(formatted, originalText: text, filename: filename)
            }
        }
        
        /// Apply formatted text to the text view, wrapping the mutation in an undo group.
        private func applyFormattedText(_ formatted: String, originalText: String, filename: String) {
            guard let textView = textView else { return }
            guard formatted != originalText else {
                AppLogger.editor.info("Format Document: No changes needed")
                return
            }
            
            // Wrap the mutation in an undo group so Format Document is
            // reversible with a single Cmd+Z (undo) / Cmd+Shift+Z (redo).
            textView.undoManager?.beginUndoGrouping()
            textView.undoManager?.registerUndo(withTarget: self) { coordinator in
                guard let tv = coordinator.textView else { return }
                tv.text = originalText
                coordinator.parent.text = originalText
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
            
            let ext = (filename as NSString).pathExtension.lowercased()
            AppLogger.editor.info("Format Document: Applied formatting for .\(ext) file")
        }
        
        func textViewDidChangeSelection(_ textView: TextView) {
            updateCursorPosition(in: textView)
            updateBracketHighlight(in: textView)
            // Refresh multi-cursor overlay positions (they move when primary cursor moves on scroll/layout)
            if multiCursorManager.isActive {
                multiCursorManager.updateDisplay()
            }
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
            // MARK: Multi-cursor text input interception
            // ---------------------------------------------------------------
            if multiCursorManager.isActive {
                if text.isEmpty && range.length > 0 {
                    // Backspace/delete - handle at all cursors
                    if multiCursorManager.deleteBackward() {
                        textViewDidChange(textView)
                        return false
                    }
                } else if !text.isEmpty {
                    // Text insertion - handle at all cursors
                    if multiCursorManager.insertText(text) {
                        textViewDidChange(textView)
                        return false
                    }
                }
            }
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

                // Snippet tab-stop navigation
                if SnippetManager.shared.hasActiveSession {
                    if let stopRange = SnippetManager.shared.advanceTabStop() {
                        textView.selectedRange = stopRange
                        return false
                    }
                }

                // Emmet abbreviation expansion (HTML/CSS files only)
                if let (expansion, abbrevRange) = EmmetEngine.shared.tryExpand(
                    in: textView.text,
                    cursorLocation: range.location,
                    filename: parent.filename
                ) {
                    textView.text = (textView.text as NSString).replacingCharacters(in: abbrevRange, with: expansion)
                    let cursorPos = abbrevRange.location + (expansion as NSString).length
                    textView.selectedRange = NSRange(location: cursorPos, length: 0)
                    textViewDidChange(textView)
                    return false
                }

                // Insert spaces (or a real tab) according to settings
                let tabSz = max(1, parent.tabSize)
                let spaces = parent.insertSpaces
                let indentStr = spaces ? String(repeating: " ", count: tabSz) : "\t"
                textView.text = (textView.text as NSString).replacingCharacters(in: range, with: indentStr)
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
                        textView.text = nsText.replacingCharacters(in: range, with: insertion)
                        newCursor = range.location + 1 + indent.count + oneLevel.count
                    } else {
                        insertion = "\n" + indent + oneLevel
                        textView.text = nsText.replacingCharacters(in: range, with: insertion)
                        newCursor = range.location + insertion.count
                    }
                } else {
                    insertion = "\n" + indent
                    textView.text = nsText.replacingCharacters(in: range, with: insertion)
                    newCursor = range.location + insertion.count
                }

                textView.selectedRange = NSRange(location: newCursor, length: 0)
                adjustBreakpointsForEdit(range: range, replacementText: insertion, in: nsText)
                textViewDidChange(textView)
                return false
            }

            // ---------------------------------------------------------------
            // MARK: Surround Selection with Brackets/Quotes
            // ---------------------------------------------------------------
            let surroundPairs: [(open: String, close: String)] = [
                ("{", "}"), ("(", ")"), ("[", "]"),
                ("\"", "\""), ("'", "'"), ("`", "`")
            ]
            if range.length > 0, let pair = surroundPairs.first(where: { $0.open == text }) {
                let nsText = textView.text as NSString
                let selected = nsText.substring(with: range)
                let wrapped = pair.open + selected + pair.close
                textView.text = nsText.replacingCharacters(in: range, with: wrapped)
                // Select the wrapped content (excluding the brackets)
                textView.selectedRange = NSRange(location: range.location + 1, length: selected.count)
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
                    // Bounded backward scan — only check last 2000 chars for quote parity
                    // Avoids O(n) full-file copy that kills performance on large files
                    let scanStart = max(0, range.location - 2000)
                    let scanLen = range.location - scanStart
                    let before = nsText.substring(with: NSRange(location: scanStart, length: scanLen))
                    var count = 0
                    var i = before.startIndex
                    while i < before.endIndex {
                        let c = String(before[i])
                        if c == "\\" {
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
                let result = nsText.replacingCharacters(in: range, with: insertion)
                textView.text = result
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
                textView.text = nsText.replacingCharacters(in: range, with: reindentedText)
                let newCursorPos = range.location + (reindentedText as NSString).length
                textView.selectedRange = NSRange(location: newCursorPos, length: 0)
                adjustBreakpointsForEdit(range: range, replacementText: reindentedText, in: nsText)
                textViewDidChange(textView)
                return false
            }

            // Incrementally update newline cache for the edit Runestone will apply
            updateNewlineOffsets(
                editRange: range,
                replacementText: text as NSString,
                in: (textView.text as NSString)  // pre-edit text; updateNewlineOffsets accounts for delta
            )

            // Adjust breakpoints for line insertions/deletions
            adjustBreakpointsForEdit(range: range, replacementText: text, in: textView.text as NSString)

            return true
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Only propagate scroll events that originate from the user.
            // When isExternalScroll is true we triggered setContentOffset ourselves
            // (e.g. from a minimap tap) and must not write back to avoid a loop.
            guard !isExternalScroll else { return }
            parent.scrollOffset = scrollView.contentOffset.y
            // Refresh multi-cursor overlay positions on scroll
            if multiCursorManager.isActive {
                multiCursorManager.updateDisplay()
            }
            // Viewport-aware highlighting optimization
            let estimatedLineHeight: CGFloat = max(1, CGFloat(parent.fontSize) * 1.3)
            ViewportHighlightManager.shared.updateScrollPosition(
                offset: scrollView.contentOffset.y,
                viewportHeight: scrollView.bounds.height,
                lineHeight: estimatedLineHeight,
                totalLines: max(1, Int(scrollView.contentSize.height / estimatedLineHeight))
            )
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
            // Bound bracket scan to ±10K chars (~300 lines) to avoid O(N) on large files
            let maxScanDistance = 10_000
            if let idx = opens.firstIndex(of: ch) {
                let close = closes[idx]
                var depth = 1; var i = pos + 1
                let scanLimit = min(str.length, pos + maxScanDistance)
                while i < scanLimit {
                    let c = str.character(at: i)
                    if c == ch { depth += 1 } else if c == close { depth -= 1; if depth == 0 { return i } }
                    i += 1
                }
            } else if let idx = closes.firstIndex(of: ch) {
                let open = opens[idx]
                var depth = 1; var i = pos - 1
                let scanLimit = max(0, pos - maxScanDistance)
                while i >= scanLimit {
                    let c = str.character(at: i)
                    if c == ch { depth += 1 } else if c == open { depth -= 1; if depth == 0 { return i } }
                    i -= 1
                }
            }
            return nil
        }

        private func updateBracketHighlight(in textView: TextView) {
            // Respect bracketPairColorization setting
            guard UserDefaults.standard.object(forKey: "bracketPairColorization") as? Bool ?? true else {
                bracketHighlightLayer.path = nil
                bracketGuideLayer.path = nil
                return
            }
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
            case .addNextOccurrence: multiCursorManager.addNextOccurrence()
            case .selectAllOccurrences: multiCursorManager.selectAllOccurrences()
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
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performToggleBlockComment(_ textView: TextView, prefix: String, suffix: String) {
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performDeleteLine(_ textView: TextView) {
            let oldText = textView.text
            let text = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = text.lineRange(for: selectedRange)
            
            textView.undoManager?.beginUndoGrouping()
            let fullText = NSMutableString(string: textView.text)
            fullText.replaceCharacters(in: lineRange, with: "")
            textView.text = fullText as String
            textView.selectedRange = NSRange(location: min(lineRange.location, max(0, (textView.text as NSString).length)), length: 0)
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performMoveLineUp(_ textView: TextView) {
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performMoveLineDown(_ textView: TextView) {
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performDuplicateLine(_ textView: TextView, above: Bool) {
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
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
                    guard let scalar = Unicode.Scalar(ch) else { break }
                    if wordChars.contains(scalar) { wordStart -= 1 } else { break }
                }
                while wordEnd < nsText.length {
                    let ch = nsText.character(at: wordEnd)
                    guard let scalar = Unicode.Scalar(ch) else { break }
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
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performOutdentLines(_ textView: TextView) {
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performJoinLines(_ textView: TextView) {
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performInsertLineBelow(_ textView: TextView) {
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
            textView.undoManager?.endUndoGrouping()
            textViewDidChange(textView)
        }
        
        private func performInsertLineAbove(_ textView: TextView) {
            let oldText = textView.text
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
            textView.undoManager?.registerUndo(withTarget: textView) { tv in
                tv.text = oldText
            }
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
