//
//  SyntaxHighlightingTextView.swift
//  VSCodeiPadOS
//
//  Upgraded syntax highlighting with VSCode-like colors
//

import SwiftUI
import UIKit

/// File-level regex cache: NSRegularExpression is thread-safe once created,
/// so we compile each pattern+options pair exactly once and reuse across all highlight passes.
private nonisolated(unsafe) var syntaxRegexCache: [String: NSRegularExpression] = [:]

/// UITextView wrapper with syntax highlighting support
struct SyntaxHighlightingTextView: UIViewRepresentable {
    @Binding var text: String
    let filename: String
    @Binding var scrollPosition: Int
    /// Pixel scroll offset (contentOffset.y) for smooth gutter alignment.
    @Binding var scrollOffset: CGFloat
    @Binding var totalLines: Int
    @Binding var visibleLines: Int
    @Binding var currentLineNumber: Int
    @Binding var currentColumn: Int
    @Binding var cursorIndex: Int
    @Binding var lineHeight: CGFloat
    @Binding var requestedLineSelection: Int?
    @Binding var requestedCursorIndex: Int?

    /// Autocomplete key handling hooks (return true if handled)
    let onAcceptAutocomplete: (() -> Bool)?
    let onDismissAutocomplete: (() -> Bool)?

    let isActive: Bool
    let fontSize: CGFloat  // Explicit parameter to trigger SwiftUI updates
    @EnvironmentObject var editorCore: EditorCore

    init(
        text: Binding<String>,
        filename: String,
        scrollPosition: Binding<Int>,
        scrollOffset: Binding<CGFloat> = .constant(0),
        totalLines: Binding<Int>,
        visibleLines: Binding<Int>,
        currentLineNumber: Binding<Int>,
        currentColumn: Binding<Int>,
        cursorIndex: Binding<Int> = .constant(0),
        lineHeight: Binding<CGFloat>,
        isActive: Bool,
        fontSize: CGFloat = 14.0,
        requestedLineSelection: Binding<Int?> = .constant(nil),
        requestedCursorIndex: Binding<Int?> = .constant(nil),
        onAcceptAutocomplete: (() -> Bool)? = nil,
        onDismissAutocomplete: (() -> Bool)? = nil
    ) {
        self._text = text
        self.filename = filename
        self._scrollPosition = scrollPosition
        self._scrollOffset = scrollOffset
        self._totalLines = totalLines
        self._visibleLines = visibleLines
        self._currentLineNumber = currentLineNumber
        self._currentColumn = currentColumn
        self._cursorIndex = cursorIndex
        self._lineHeight = lineHeight
        self.isActive = isActive
        self.fontSize = fontSize
        self._requestedLineSelection = requestedLineSelection
        self._requestedCursorIndex = requestedCursorIndex
        self.onAcceptAutocomplete = onAcceptAutocomplete
        self.onDismissAutocomplete = onDismissAutocomplete
    }
    
    // Compatibility init for older call sites (e.g. SplitEditorView) that pass editorCore explicitly.
    init(
        text: Binding<String>,
        filename: String,
        scrollPosition: Binding<Int>,
        scrollOffset: Binding<CGFloat> = .constant(0),
        totalLines: Binding<Int>,
        visibleLines: Binding<Int>,
        currentLineNumber: Binding<Int>,
        currentColumn: Binding<Int>,
        cursorIndex: Binding<Int> = .constant(0),
        lineHeight: Binding<CGFloat>,
        isActive: Bool,
        editorCore: EditorCore,
        requestedLineSelection: Binding<Int?> = .constant(nil),
        requestedCursorIndex: Binding<Int?> = .constant(nil),
        onAcceptAutocomplete: (() -> Bool)? = nil,
        onDismissAutocomplete: (() -> Bool)? = nil
    ) {
        self.init(
            text: text,
            filename: filename,
            scrollPosition: scrollPosition,
            scrollOffset: scrollOffset,
            totalLines: totalLines,
            visibleLines: visibleLines,
            currentLineNumber: currentLineNumber,
            currentColumn: currentColumn,
            cursorIndex: cursorIndex,
            lineHeight: lineHeight,
            isActive: isActive,
            fontSize: editorCore.editorFontSize,
            requestedLineSelection: requestedLineSelection,
            requestedCursorIndex: requestedCursorIndex,
            onAcceptAutocomplete: onAcceptAutocomplete,
            onDismissAutocomplete: onDismissAutocomplete
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        // Create custom TextKit stack with FoldingLayoutManager for code folding support
        let textStorage = NSTextStorage()
        let foldingLayoutManager = FoldingLayoutManager()
        textStorage.addLayoutManager(foldingLayoutManager)
        
        let textContainer = NSTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        foldingLayoutManager.addTextContainer(textContainer)
        
        let textView = EditorTextView(frame: .zero, textContainer: textContainer)
        
        // Connect FoldingLayoutManager to EditorTextView
        foldingLayoutManager.ownerTextView = textView
        
        textView.delegate = context.coordinator
        textView.editorCore = editorCore
        
        // Code folding support
        textView.foldingManager = CodeFoldingManager.shared
        textView.fileId = filename

        // Autocomplete hooks
        textView.onAcceptAutocomplete = onAcceptAutocomplete
        textView.onDismissAutocomplete = onDismissAutocomplete

        textView.onPeekDefinition = {
            context.coordinator.handlePeekDefinition(in: textView)
        }

        textView.onEscape = {
            context.coordinator.handleEscape()
        }

        textView.onGoToLine = {
            self.editorCore.showGoToLine = true
        }
        
        // Wire up custom context menu actions
        textView.onGoToDefinition = {
            context.coordinator.handleGoToDefinition(in: textView)
        }
        
        textView.onFindReferences = {
            context.coordinator.handleFindReferences(in: textView)
        }
        
        textView.onFormatDocument = {
            context.coordinator.handleFormatDocument(in: textView)
        }
        
        textView.onToggleComment = {
            context.coordinator.handleToggleComment(in: textView)
        }
        
        textView.onFold = {
            context.coordinator.handleFold(in: textView)
        }
        
        textView.onUnfold = {
            context.coordinator.handleUnfold(in: textView)
        }
        
        // Add pinch gesture for zoom (with delegate to allow simultaneous text selection)
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        pinchGesture.delegate = context.coordinator
        textView.addGestureRecognizer(pinchGesture)
        context.coordinator.pinchGesture = pinchGesture
        
        // Configure text view
        textView.isEditable = true
        textView.isSelectable = true
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.spellCheckingType = .no
        
        // Set font and appearance (use editorCore.editorFontSize)
        textView.font = UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
        textView.textColor = UIColor(ThemeManager.shared.currentTheme.editorForeground)
        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
        textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
        textView.keyboardType = .default
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        // Apply tab size via paragraph style tab stops
        let tabSizeValue = UserDefaults.standard.integer(forKey: "tabSize")
        let resolvedTabSize = tabSizeValue > 0 ? tabSizeValue : 4
        let monoFont = textView.font ?? UIFont.monospacedSystemFont(ofSize: editorCore.editorFontSize, weight: .regular)
        let charWidth = (" " as NSString).size(withAttributes: [.font: monoFont]).width
        let tabInterval = CGFloat(resolvedTabSize) * charWidth
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops = []
        paragraphStyle.defaultTabInterval = tabInterval
        textView.typingAttributes[.paragraphStyle] = paragraphStyle
        
        // Enable line wrapping
        textView.textContainer.lineBreakMode = .byCharWrapping
        textView.textContainer.widthTracksTextView = true
        
        // Calculate line height
        if let font = textView.font {
            self.lineHeight = font.lineHeight
        }
        
        // Set initial text with syntax highlighting
        textView.text = text
        // For very large files, only highlight the visible range on initial load
        // to avoid blocking the main thread. Scroll-triggered highlighting covers the rest.
        if text.count > 50000 {
            context.coordinator.applyVisibleRangeHighlighting(to: textView)
        } else {
            context.coordinator.applySyntaxHighlighting(to: textView)
        }
        context.coordinator.updateLineCount(textView)
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        // CRITICAL: Update coordinator's parent reference to current struct
        // SwiftUI creates new struct instances on each update, so this keeps
        // coordinator in sync with current bindings and properties
        context.coordinator.parent = self
        
        // CRITICAL FIX: Apply initial highlighting FIRST on the very first updateUIView call
        // This fixes the bug where syntax highlighting only appears after typing.
        // makeUIView applies it, but the view may not be fully in hierarchy yet,
        // causing the attributed text to be lost. This ensures it's applied reliably.
        if !context.coordinator.hasAppliedInitialHighlighting && !textView.text.isEmpty {
            // For large files, use visible-range-only highlighting to avoid blocking the main thread.
            // A deferred full/visible pass runs after a short delay to cover remaining content.
            if textView.text.count > 50000 {
                context.coordinator.applyVisibleRangeHighlighting(to: textView)
            } else {
                context.coordinator.applySyntaxHighlighting(to: textView)
            }
            context.coordinator.hasAppliedInitialHighlighting = true
            // Seed the scroll-highlight tracker so the very first scroll triggers a re-highlight
            context.coordinator.lastHighlightedScrollY = textView.contentOffset.y
        }
        
        // Update colors when theme changes
        // NOTE: Only set backgroundColor and tintColor here. Do NOT set textColor
        // as it interferes with attributedText syntax highlighting colors.
        // The foreground color is handled entirely by the attributedText.
        textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
        textView.tintColor = UIColor(ThemeManager.shared.currentTheme.cursor)
        
        if let editorView = textView as? EditorTextView {
            editorView.updateThemeColors(theme: ThemeManager.shared.currentTheme)
        }
        
        // Update font size if changed (using explicit fontSize parameter for proper SwiftUI updates)
        if let currentFont = textView.font, currentFont.pointSize != fontSize {
            let selectedRange = textView.selectedRange
            textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
            context.coordinator.applySyntaxHighlighting(to: textView)
            textView.selectedRange = selectedRange
            
            // Update line height
            if let font = textView.font {
                self.lineHeight = font.lineHeight
            }
        }

        // Re-apply tab interval whenever font or tab size may have changed
        let tabSizeValue = UserDefaults.standard.integer(forKey: "tabSize")
        let resolvedTabSize = tabSizeValue > 0 ? tabSizeValue : 4
        let monoFont2 = textView.font ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let charWidth2 = (" " as NSString).size(withAttributes: [.font: monoFont2]).width
        let tabInterval2 = CGFloat(resolvedTabSize) * charWidth2
        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.tabStops = []
        paragraphStyle2.defaultTabInterval = tabInterval2
        textView.typingAttributes[.paragraphStyle] = paragraphStyle2
        
        // Update text if changed externally
        if textView.text != text {
            let selectedRange = textView.selectedRange
            textView.text = text
            // Use visible-range-only highlighting for very large files to avoid main-thread stall
            if text.count > 50000 {
                context.coordinator.applyVisibleRangeHighlighting(to: textView)
            } else {
                context.coordinator.applySyntaxHighlighting(to: textView)
            }
            context.coordinator.hasAppliedInitialHighlighting = true
            context.coordinator.lastHighlightedScrollY = textView.contentOffset.y
            textView.selectedRange = selectedRange
        } else if context.coordinator.lastThemeId != ThemeManager.shared.currentTheme.id {
            // Re-apply highlighting if theme changed
            if text.count > 50000 {
                context.coordinator.applyVisibleRangeHighlighting(to: textView)
            } else {
                context.coordinator.applySyntaxHighlighting(to: textView)
            }
        }
        
        // Handle minimap scrolling - but ONLY if user is NOT actively scrolling
        // This prevents the editor from fighting against user scroll due to async binding lag
        if scrollPosition != context.coordinator.lastKnownScrollPosition && scrollPosition >= 0 && !context.coordinator.isUserScrolling {
            // Update lastKnownScrollPosition FIRST to prevent race condition
            // where user scroll gets overridden by stale binding value
            context.coordinator.lastKnownScrollPosition = scrollPosition
            context.coordinator.scrollToLine(scrollPosition, in: textView)
        }

        // Handle line selection requests (e.g. tapping line numbers)
        if let requested = requestedLineSelection,
           requested != context.coordinator.lastRequestedLineSelection {
            context.coordinator.lastRequestedLineSelection = requested
            context.coordinator.scrollToAndSelectLine(requested, in: textView)
            // Defer @Binding update to avoid "Publishing changes from within view updates"
            DispatchQueue.main.async {
                self.requestedLineSelection = nil
            }
        }

        // Handle cursor index requests (e.g. accepting autocomplete)
        if let requested = requestedCursorIndex,
           requested != context.coordinator.lastRequestedCursorIndex {
            context.coordinator.lastRequestedCursorIndex = requested
            // Use UTF-16 count for NSRange compatibility
            let textLength = (textView.text as NSString?)?.length ?? 0
            let safeIndex = max(0, min(requested, textLength))
            textView.selectedRange = NSRange(location: safeIndex, length: 0)
            
            // Ensure cursor is visible by scrolling to it
            textView.scrollRangeToVisible(textView.selectedRange)
            
            // Defer @Binding update to avoid "Publishing changes from within view updates"
            DispatchQueue.main.async {
                self.requestedCursorIndex = nil
            }

            // Update SwiftUI state
            context.coordinator.updateCursorPosition(textView)
            context.coordinator.updateScrollPosition(textView)
        }
        
        // Handle find/replace selection requests (jump to match)
        if let range = editorCore.requestedSelection,
           range != context.coordinator.lastHandledSelection {
            context.coordinator.lastHandledSelection = range
            let textLength = (textView.text as NSString?)?.length ?? 0
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

        // Note: updateLineCount is called in textViewDidChange, no need to call here
        // as it causes unnecessary state churn on every updateUIView
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
        var parent: SyntaxHighlightingTextView
        var lastKnownScrollPosition: Int = 0
        var lastThemeId: String = ""
        var lastRequestedLineSelection: Int? = nil
        var lastRequestedCursorIndex: Int? = nil
        var lastHandledSelection: NSRange? = nil
        private var isUpdatingFromMinimap = false
        private var highlightDebouncer: Timer?
        weak var pinchGesture: UIPinchGestureRecognizer?
        private var initialFontSize: CGFloat = 0
        
        // Track user scroll to prevent programmatic scroll fighting back
        private var userScrollDebouncer: Timer?
        var isUserScrolling = false

        // FEAT-044: Matching bracket highlight state
        private var bracketHighlightRanges: [NSRange] = []
        
        // FEAT-NEW: Word occurrence highlight state
        private var wordOccurrenceRanges: [NSRange] = []
        private var wordOccurrenceDebouncer: Timer?

        // Track if initial highlighting has been applied (fixes highlighting not appearing on file open)
        var hasAppliedInitialHighlighting = false
        
        // PERF: Track last line to avoid unnecessary redraws
        private var lastKnownLineNumber: Int = -1
        
        // PERF: Debounce bracket matching to avoid O(n) scans on every cursor move
        private var bracketMatchDebouncer: Timer?
        
        // PERFORMANCE: Large file highlighting optimization
        // Files larger than this threshold get deferred full highlighting
        private let largeFileThreshold = 10000  // 10k characters
        private var largeFileHighlightDebouncer: Timer?
        // Track if we have pending full highlight (for large files)
        private var hasPendingFullHighlight = false

        // PERF: Debounce scroll-triggered re-highlighting for large files
        private var scrollHighlightTimer: Timer?
        var lastHighlightedScrollY: CGFloat = -99999
        /// When true, a scroll-triggered re-highlight was requested while an async
        /// highlight pass was already in-flight.  Checked after the pass completes
        /// so the newly-visible range is highlighted without a second user gesture.
        private var pendingScrollHighlight = false
        
        // PERF: Debounce SwiftUI binding updates to avoid view re-renders on every keystroke
        private var textUpdateWorkItem: DispatchWorkItem?
        private let textUpdateDebounceInterval: TimeInterval = 0.3  // 300ms
        
        init(_ parent: SyntaxHighlightingTextView) {
            self.parent = parent
        }
        
        // MARK: - UIGestureRecognizerDelegate
        
        // Allow pinch gesture to work simultaneously with text selection gestures
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // Allow pinch to work alongside native text selection gestures
            return true
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            // Ensure syntax highlighting is current when user begins editing
            // This handles cases where text was set but highlighting hasn't run yet
            applySyntaxHighlighting(to: textView)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            // Flush any pending debounced text update immediately when the user stops editing.
            // This ensures auto-save, tab content syncing, etc. always see the latest text.
            textUpdateWorkItem?.cancel()
            textUpdateWorkItem = nil
            parent.text = textView.text ?? ""
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // PERF: Debounce SwiftUI binding update — cancel previous, schedule new with 300ms delay.
            // Immediate propagation is handled by textViewDidEndEditing and syncTextImmediately().
            textUpdateWorkItem?.cancel()
            let capturedText = textView.text ?? ""
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.parent.text = capturedText
            }
            textUpdateWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + textUpdateDebounceInterval, execute: workItem)
            
            // Set typing attributes IMMEDIATELY so new characters have proper base styling
            // This prevents flicker during the debounce period
            let theme = ThemeManager.shared.currentTheme
            let fontSize = parent.editorCore.editorFontSize
            textView.typingAttributes = [
                .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
                .foregroundColor: UIColor(theme.editorForeground)
            ]
            
            // PERFORMANCE FIX: Aggressive debounce strategy based on document size
            // For large files, syntax highlighting is EXTREMELY expensive and causes lag
            let textLength = textView.text.count
            
            // Large file threshold - above this, skip highlighting during active typing entirely
            let largeFileThreshold = 10000
            // Very large file threshold - above this, use extended delay
            let veryLargeFileThreshold = 50000
            
            highlightDebouncer?.invalidate()
            
            if textLength > veryLargeFileThreshold {
                // VERY LARGE FILES (50k+): Wait 1.5 seconds of idle before highlighting
                // This prevents UI blocking entirely during active typing
                highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.applyVisibleRangeHighlighting(to: textView)
                    }
                }
            } else if textLength > largeFileThreshold {
                // LARGE FILES (10k-50k): Wait 1 second of idle, then highlight visible range only
                highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.applyVisibleRangeHighlighting(to: textView)
                    }
                }
            } else if textLength > 5000 {
                // MEDIUM FILES (5k-10k): 300ms debounce, full highlighting on background thread
                highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.applyHighlightingAsync(to: textView)
                    }
                }
            } else {
                // SMALL FILES (<5k): 80ms debounce, direct highlighting (fast enough)
                highlightDebouncer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.applySyntaxHighlighting(to: textView)
                    }
                }
            }
            
            updateLineCount(textView)
            updateCursorPosition(textView)
        }
        
        /// Async highlighting for large files - processes on background thread
        func applyHighlightingAsync(to textView: UITextView) {
            guard !isApplyingHighlighting else { return }
            isApplyingHighlighting = true
            
            let text = textView.text ?? ""
            let filename = parent.filename
            let theme = ThemeManager.shared.currentTheme
            let fontSize = parent.editorCore.editorFontSize
            let selectedRange = textView.selectedRange
            
            // Process highlighting on background thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
                let attributedText = highlighter.highlight(text, filename: filename)
                
                // Apply on main thread
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isApplyingHighlighting = false
                    
                    // Only apply if text hasn't changed while we were processing
                    guard textView.text == text else { return }
                    
                    // Apply highlighting directly to textStorage to avoid polluting the undo stack
                    let textStorage = textView.textStorage
                    textStorage.beginEditing()
                    attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { attrs, range, _ in
                        textStorage.setAttributes(attrs, range: range)
                    }
                    textStorage.endEditing()
                    textView.selectedRange = selectedRange
                    
                    textView.typingAttributes = [
                        .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
                        .foregroundColor: UIColor(theme.editorForeground)
                    ]
                    
                    self.lastThemeId = theme.id
                    
                    // If a scroll-triggered highlight was requested while we were busy,
                    // re-highlight now for the current visible range.
                    if self.pendingScrollHighlight {
                        self.pendingScrollHighlight = false
                        self.applyVisibleRangeHighlighting(to: textView)
                    }
                }
            }
        }
        
        /// PERFORMANCE: Visible-range-only highlighting for very large files
        /// Only highlights the text that's currently visible on screen, dramatically reducing lag
        func applyVisibleRangeHighlighting(to textView: UITextView) {
            guard !isApplyingHighlighting else {
                // Don't silently drop – mark pending so we re-highlight after the
                // in-flight pass finishes. This prevents scrolled text staying unstyled.
                pendingScrollHighlight = true
                return
            }
            pendingScrollHighlight = false
            isApplyingHighlighting = true
            
            let text = textView.text ?? ""
            let filename = parent.filename
            let theme = ThemeManager.shared.currentTheme
            let fontSize = parent.editorCore.editorFontSize
            let selectedRange = textView.selectedRange
            
            // Calculate visible range with buffer
            // Use contentOffset-based visible rect for accurate scroll position
            let visibleRect = CGRect(
                x: textView.contentOffset.x,
                y: textView.contentOffset.y,
                width: textView.bounds.width,
                height: textView.bounds.height
            )

            let layoutManager = textView.layoutManager
            let textContainer = textView.textContainer
            
            // PERF: Use glyphRange(forBoundingRect:) instead of enumerateLineFragments
            // The old approach was O(n) — it walked ALL line fragments from glyph 0.
            // glyphRange(forBoundingRect:) is O(log n) and directly returns visible glyphs.
            let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
            
            // Convert glyph range to character range
            var visibleCharRange = layoutManager.characterRange(forGlyphRange: visibleGlyphRange, actualGlyphRange: nil)
            
            // Add buffer of ~50 lines before and after for smooth scrolling
            let bufferChars = 5000
            let rangeStart = max(0, visibleCharRange.location - bufferChars)
            let rangeEnd = min(text.utf16.count, visibleCharRange.location + visibleCharRange.length + bufferChars)
            visibleCharRange = NSRange(location: rangeStart, length: rangeEnd - rangeStart)
            
            // Process highlighting on background thread
            let capturedCharRange = visibleCharRange
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                // Extract the visible portion of text
                let nsText = text as NSString
                let safeRange = NSRange(
                    location: capturedCharRange.location,
                    length: min(capturedCharRange.length, nsText.length - capturedCharRange.location)
                )
                guard safeRange.length > 0 else {
                    DispatchQueue.main.async {
                        self?.isApplyingHighlighting = false
                    }
                    return
                }
                
                let visibleText = nsText.substring(with: safeRange)
                
                // Highlight only the visible portion
                let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: fontSize)
                let highlightedVisible = highlighter.highlight(visibleText, filename: filename)
                
                // Apply on main thread
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isApplyingHighlighting = false
                    
                    // Only apply if text hasn't changed while we were processing
                    guard textView.text == text else { return }
                    
                    // Apply highlighting directly to textStorage to avoid polluting the undo stack
                    let textStorage = textView.textStorage
                    let baseFont = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
                    let baseColor = UIColor(theme.editorForeground)
                    let safeApplyRange = NSRange(location: safeRange.location, length: min(safeRange.length, textStorage.length - safeRange.location))
                    
                    textStorage.beginEditing()
                    // Apply base styling only to the range we're about to re-highlight
                    textStorage.addAttribute(.font, value: baseFont, range: safeApplyRange)
                    textStorage.addAttribute(.foregroundColor, value: baseColor, range: safeApplyRange)
                    
                    // Apply highlighted attributes only to visible range
                    highlightedVisible.enumerateAttributes(in: NSRange(location: 0, length: highlightedVisible.length), options: []) { attrs, range, _ in
                        let targetRange = NSRange(location: safeRange.location + range.location, length: range.length)
                        if targetRange.location + targetRange.length <= textStorage.length {
                            for (key, value) in attrs {
                                textStorage.addAttribute(key, value: value, range: targetRange)
                            }
                        }
                    }
                    textStorage.endEditing()
                    textView.selectedRange = selectedRange
                    
                    textView.typingAttributes = [
                        .font: baseFont,
                        .foregroundColor: baseColor
                    ]
                    
                    self.lastThemeId = theme.id
                    
                    // If a scroll-triggered highlight was requested while we were busy,
                    // re-highlight now for the current visible range.
                    if self.pendingScrollHighlight {
                        self.pendingScrollHighlight = false
                        self.applyVisibleRangeHighlighting(to: textView)
                    }
                }
            }
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            if !isUpdatingFromMinimap {
                updateCursorPosition(textView)
                updateScrollPosition(textView)

                // FEAT-044: Matching bracket highlight - PERF: debounced to avoid O(n) scan spam
                bracketMatchDebouncer?.invalidate()
                bracketMatchDebouncer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.updateMatchingBracketHighlight(textView)
                    }
                }
                
                // FEAT-NEW: Word occurrence highlighting - debounced for performance
                wordOccurrenceDebouncer?.invalidate()
                wordOccurrenceDebouncer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.updateWordOccurrenceHighlights(textView)
                    }
                }

                // PERF: Only trigger redraw when line actually changes (not on every cursor move)
                let currentLine = parent.currentLineNumber
                if currentLine != lastKnownLineNumber {
                    lastKnownLineNumber = currentLine
                    (textView as? EditorTextView)?.setNeedsDisplay()
                }

                // Update selection in EditorCore for multi-cursor support
                // Defer @Published property updates to avoid "Publishing changes from within view updates"
                let range = textView.selectedRange
                let currentText = textView.text ?? ""
                let isMultiCursor = parent.editorCore.multiCursorState.isMultiCursor
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.parent.editorCore.updateSelection(range: range, text: currentText)

                    // Keep EditorCore.multiCursorState in sync with UIKit selection.
                    // Important: Don't clear the anchor when there's an active selection, otherwise Cmd+D
                    // loses the "first occurrence" selection and multi-cursor typing won't replace all occurrences.
                    if !isMultiCursor {
                        if range.length > 0 {
                            self.parent.editorCore.multiCursorState.cursors = [
                                Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)
                            ]
                        } else {
                            self.parent.editorCore.multiCursorState.reset(to: range.location)
                        }
                    }
                }
            }
        }
        
        // MARK: - UIScrollViewDelegate methods for reliable user scroll detection
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            // User started dragging - set flag immediately to prevent programmatic scroll fighting
            isUserScrolling = true
            userScrollDebouncer?.invalidate()
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            // If not decelerating, user stopped scrolling
            if !decelerate {
                // Small delay to let any final scroll events settle
                userScrollDebouncer?.invalidate()
                userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.isUserScrolling = false
                    }
                }
                
                // Re-highlight visible range when drag ends without deceleration (large files)
                if let textView = scrollView as? UITextView, (textView.text?.count ?? 0) > 10000 {
                    scrollHighlightTimer?.invalidate()
                    lastHighlightedScrollY = scrollView.contentOffset.y
                    applyVisibleRangeHighlighting(to: textView)
                }
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            // Deceleration finished - user scroll is complete
            userScrollDebouncer?.invalidate()
            userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isUserScrolling = false
                }
            }
            
            // Re-highlight visible range when deceleration ends (large files)
            if let textView = scrollView as? UITextView, (textView.text?.count ?? 0) > 10000 {
                scrollHighlightTimer?.invalidate()
                lastHighlightedScrollY = scrollView.contentOffset.y
                applyVisibleRangeHighlighting(to: textView)
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let textView = scrollView as? UITextView, !isUpdatingFromMinimap else { return }
            
            // Note: isUserScrolling is now set by scrollViewWillBeginDragging for reliable detection
            // We still use debouncer as a fallback for edge cases
            if isUserScrolling {
                userScrollDebouncer?.invalidate()
                userScrollDebouncer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.isUserScrolling = false
                    }
                }
            }
            
            // PERF: Debounced re-highlighting during scroll for large files
            // When scrolling through a large file, new visible text may be unstyled.
            // We debounce at 200ms so highlighting runs shortly after scroll settles,
            // but only if the scroll position changed meaningfully (>50pt).
            let textLength = textView.text?.count ?? 0
            if textLength > 10000 {
                let scrollY = scrollView.contentOffset.y
                let scrollDelta = abs(scrollY - lastHighlightedScrollY)
                if scrollDelta > 50 {
                    scrollHighlightTimer?.invalidate()
                    scrollHighlightTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.lastHighlightedScrollY = scrollY
                            self.applyVisibleRangeHighlighting(to: textView)
                        }
                    }
                }
            }
            
            updateScrollPosition(textView)
        }
        
        func updateLineCount(_ textView: UITextView) {
            let text = textView.text ?? ""
            // PERF: Single Objective-C call — far faster than iterating every Swift Character
            let lineCount = (text as NSString).components(separatedBy: "\n").count
            DispatchQueue.main.async {
                self.parent.totalLines = lineCount
            }
        }
        
        func updateCursorPosition(_ textView: UITextView) {
            guard let selectedRange = textView.selectedTextRange else { return }
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            
            // PERF: Count newlines directly instead of creating substring + array
            let text = textView.text ?? ""
            var lineNumber = 1
            var columnStart = 0
            
            let endIndex = text.index(text.startIndex, offsetBy: min(cursorPosition, text.count), limitedBy: text.endIndex) ?? text.endIndex
            for (i, char) in text[..<endIndex].enumerated() {
                if char == "\n" {
                    lineNumber += 1
                    columnStart = i + 1
                }
            }
            
            let column = cursorPosition - columnStart + 1
            
            DispatchQueue.main.async {
                self.parent.currentLineNumber = lineNumber
                self.parent.currentColumn = column
                self.parent.cursorIndex = cursorPosition
            }
        }
        
        func updateScrollPosition(_ textView: UITextView) {
            guard let font = textView.font else { return }
            let lineHeight = font.lineHeight
            let yOffset = textView.contentOffset.y
            let line = Int(yOffset / lineHeight)

            // Update lastKnownScrollPosition synchronously to prevent feedback loops
            lastKnownScrollPosition = line
            
            // Defer @Binding updates to avoid "Publishing changes from within view updates"
            DispatchQueue.main.async {
                self.parent.scrollPosition = line
                self.parent.scrollOffset = yOffset
            }
        }
        
        func scrollToLine(_ line: Int, in textView: UITextView) {
            guard !isUpdatingFromMinimap else { return }
            isUpdatingFromMinimap = true
            
            // Optimized: Use NSString enumeration instead of splitting entire text
            let nsText = textView.text as NSString
            var currentLine = 0
            var characterPosition = 0
            var foundLine = false
            
            nsText.enumerateSubstrings(in: NSRange(location: 0, length: nsText.length), options: [.byLines, .substringNotRequired]) { _, substringRange, _, stop in
                if currentLine == line {
                    characterPosition = substringRange.location
                    foundLine = true
                    stop.pointee = true
                    return
                }
                currentLine += 1
            }
            
            guard foundLine || (line == 0 && nsText.length == 0) else {
                isUpdatingFromMinimap = false
                return
            }
            
            if let position = textView.position(from: textView.beginningOfDocument, offset: characterPosition) {
                let rect = textView.caretRect(for: position)
                let targetY = max(0, rect.origin.y)
                textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isUpdatingFromMinimap = false
            }
        }

        func scrollToAndSelectLine(_ line: Int, in textView: UITextView) {
            // Optimized: Use NSString enumeration instead of splitting entire text
            let nsText = textView.text as NSString
            var currentLine = 0
            var characterPosition = 0
            var lineLength = 0
            var foundLine = false
            
            nsText.enumerateSubstrings(in: NSRange(location: 0, length: nsText.length), options: .byLines) { substring, substringRange, _, stop in
                if currentLine == line {
                    characterPosition = substringRange.location
                    lineLength = substringRange.length
                    foundLine = true
                    stop.pointee = true
                    return
                }
                currentLine += 1
            }
            
            guard foundLine else { return }

            // FEAT-041: select entire line (excluding trailing newline)
            let range = NSRange(location: characterPosition, length: lineLength)
            textView.selectedRange = range

            // Ensure it's visible
            scrollToLine(line, in: textView)

            // Update SwiftUI state
            updateCursorPosition(textView)
            updateScrollPosition(textView)
        }

        /// Lock protecting `_isApplyingHighlighting` across threads.
        private let highlightingLock = NSLock()
        private var _isApplyingHighlighting = false
        private var isApplyingHighlighting: Bool {
            get { highlightingLock.lock(); defer { highlightingLock.unlock() }; return _isApplyingHighlighting }
            set { highlightingLock.lock(); defer { highlightingLock.unlock() }; _isApplyingHighlighting = newValue }
        }
        
        func applySyntaxHighlighting(to textView: UITextView) {
            // Guard against reentrancy - this can happen if attributedText assignment
            // triggers delegate callbacks that call this method again
            guard !isApplyingHighlighting else { return }
            isApplyingHighlighting = true
            defer { isApplyingHighlighting = false }
            
            let theme = ThemeManager.shared.currentTheme
            lastThemeId = theme.id

            let highlighter = VSCodeSyntaxHighlighter(theme: theme, fontSize: parent.editorCore.editorFontSize)
            let attributedText = highlighter.highlight(textView.text, filename: parent.filename)

            let selectedRange = textView.selectedRange

            // Apply highlighting directly to textStorage to avoid polluting the undo stack.
            // Using textStorage.beginEditing()/endEditing() with attribute changes doesn't
            // register undo operations, unlike setting textView.attributedText.
            let textStorage = textView.textStorage
            textStorage.beginEditing()
            attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { attrs, range, _ in
                textStorage.setAttributes(attrs, range: range)
            }
            textStorage.endEditing()
            textView.selectedRange = selectedRange

            // Set typing attributes so newly typed characters have correct base styling
            // This prevents flicker during the debounce period before full highlighting runs
            let fontSize = parent.editorCore.editorFontSize
            textView.typingAttributes = [
                .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
                .foregroundColor: UIColor(theme.editorForeground)
            ]

            // FEAT-044: restore matching bracket highlight after re-attributing text
            updateMatchingBracketHighlight(textView)
        }
        
        func handlePeekDefinition(in textView: UITextView) {
            guard let selectedRange = textView.selectedTextRange else { return }
            let text = textView.text ?? ""
            
            if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
                 let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
                 
                 let prefix = String(text.prefix(location))
                 let sourceLine = prefix.components(separatedBy: CharacterSet.newlines).count - 1
                 
                 parent.editorCore.triggerPeekDefinition(
                     file: parent.filename,
                     line: sourceLine,
                     content: text,
                     sourceLine: sourceLine
                 )
            }
        }
        
        func handleEscape() {
            if parent.editorCore.peekState != nil {
                parent.editorCore.closePeekDefinition()
            } else {
                parent.editorCore.escapeMultiCursor()
            }
        }
        
        func handleGoToDefinition(in textView: UITextView) {
            // Reuse the peek definition logic for now
            handlePeekDefinition(in: textView)
        }
        
        func handleFindReferences(in textView: UITextView) {
            guard let selectedRange = textView.selectedTextRange else { return }
            
            // Extract the word at the current cursor position using the tokenizer
            if let range = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .word, inDirection: UITextDirection(rawValue: 1)) {
                let word = textView.text(in: range) ?? ""
                let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                
                // Delegate to EditorCore which searches all open tabs and opens the search sidebar
                parent.editorCore.performFindReferences(symbol: trimmed)
            }
        }
        
        func handleFormatDocument(in textView: UITextView) {
            guard let text = textView.text, !text.isEmpty else { return }
            
            // Use the shared CodeFormatter for proper multi-language formatting
            let formatter = CodeFormatter.shared
            let formattedText = formatter.format(code: text, filename: parent.filename)
            
            // Only update if formatting changed something
            guard formattedText != text else {
                AppLogger.editor.info("Format Document: No changes needed")
                return
            }
            
            textView.undoManager?.beginUndoGrouping()
            let fullRange = NSRange(location: 0, length: (textView.text as NSString).length)
            textView.textStorage.replaceCharacters(in: fullRange, with: formattedText)
            textView.undoManager?.endUndoGrouping()
            
            // Update parent binding and editor state
            parent.text = formattedText
            parent.editorCore.objectWillChange.send()
            
            // Re-apply syntax highlighting after formatting
            applySyntaxHighlighting(to: textView)
            
            let ext = (parent.filename as NSString).pathExtension.lowercased()
            AppLogger.editor.info("Format Document: Applied formatting for .\(ext) file")
        }
        
        func handleToggleComment(in textView: UITextView) {
            guard let selectedRange = textView.selectedTextRange else { return }
            let text = textView.text ?? ""
            let nsText = text as NSString
            
            // Determine comment prefix/suffix based on file language
            let commentPrefix = commentPrefixForFilename(parent.filename)
            let commentSuffix = commentSuffixForFilename(parent.filename)
            
            // Get the full range of selected text in NSRange
            let selStart = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            let selEnd = textView.offset(from: textView.beginningOfDocument, to: selectedRange.end)
            
            // Block comment languages (HTML, CSS) use wrap/unwrap instead of line-prefix
            if let suffix = commentSuffix {
                handleBlockToggleComment(in: textView, nsText: nsText, selStart: selStart, selEnd: selEnd, prefix: commentPrefix, suffix: suffix)
                return
            }
            
            // Find all line ranges that intersect with the selection
            var lineRanges: [NSRange] = []
            
            // If no selection (cursor only), just use the current line
            if selStart == selEnd {
                if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
                    let loc = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
                    let len = textView.offset(from: lineRange.start, to: lineRange.end)
                    lineRanges.append(NSRange(location: loc, length: len))
                }
            } else {
                // Find all lines in selection
                let fullRange = NSRange(location: selStart, length: selEnd - selStart)
                nsText.enumerateSubstrings(in: fullRange, options: [.byLines, .substringNotRequired]) { _, substringRange, _, _ in
                    lineRanges.append(substringRange)
                }
                // If enumerateSubstrings returned nothing, fall back to paragraph
                if lineRanges.isEmpty {
                    if let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
                        let loc = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
                        let len = textView.offset(from: lineRange.start, to: lineRange.end)
                        lineRanges.append(NSRange(location: loc, length: len))
                    }
                }
            }
            
            guard !lineRanges.isEmpty else { return }
            
            // Determine if we should add or remove comments
            // If ALL lines are commented, remove comments; otherwise add
            let allCommented = lineRanges.allSatisfy { range in
                guard range.location + range.length <= nsText.length else { return false }
                let lineText = nsText.substring(with: range)
                return lineText.trimmingCharacters(in: .whitespaces).hasPrefix(commentPrefix)
            }
            
            // Apply changes in reverse order to preserve offsets
            textView.undoManager?.beginUndoGrouping()
            let textStorage = textView.textStorage
            
            for lineRange in lineRanges.reversed() {
                guard lineRange.location + lineRange.length <= nsText.length else { continue }
                let lineText = nsText.substring(with: lineRange)
                
                let newLineText: String
                if allCommented {
                    // Remove comment prefix
                    if let range = lineText.range(of: commentPrefix + " ") {
                        newLineText = lineText.replacingCharacters(in: range, with: "")
                    } else if let range = lineText.range(of: commentPrefix) {
                        newLineText = lineText.replacingCharacters(in: range, with: "")
                    } else {
                        newLineText = lineText
                    }
                } else {
                    // Add comment prefix with a space
                    newLineText = commentPrefix + " " + lineText
                }
                
                textStorage.replaceCharacters(in: lineRange, with: newLineText)
            }
            
            textView.undoManager?.endUndoGrouping()
            
            // Update parent binding
            parent.text = textView.text
        }
        
        /// Handles block comment toggle (wrap/unwrap) for languages like HTML and CSS
        private func handleBlockToggleComment(in textView: UITextView, nsText: NSString, selStart: Int, selEnd: Int, prefix: String, suffix: String) {
            // Determine the range to wrap: either the selection or the current line
            let wrapRange: NSRange
            if selStart == selEnd {
                // No selection - wrap the current line
                if let selectedRange = textView.selectedTextRange,
                   let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .paragraph, inDirection: UITextDirection(rawValue: 1)) {
                    let loc = textView.offset(from: textView.beginningOfDocument, to: lineRange.start)
                    let len = textView.offset(from: lineRange.start, to: lineRange.end)
                    wrapRange = NSRange(location: loc, length: len)
                } else {
                    return
                }
            } else {
                wrapRange = NSRange(location: selStart, length: selEnd - selStart)
            }
            
            guard wrapRange.location + wrapRange.length <= nsText.length else { return }
            let selectedText = nsText.substring(with: wrapRange)
            let trimmed = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            textView.undoManager?.beginUndoGrouping()
            let textStorage = textView.textStorage
            
            // Check if already wrapped with block comment
            if trimmed.hasPrefix(prefix) && trimmed.hasSuffix(suffix) {
                // Unwrap: remove prefix and suffix
                var unwrapped = selectedText
                // Remove prefix (with optional trailing space)
                if let range = unwrapped.range(of: prefix + " ") {
                    unwrapped = unwrapped.replacingCharacters(in: range, with: "")
                } else if let range = unwrapped.range(of: prefix) {
                    unwrapped = unwrapped.replacingCharacters(in: range, with: "")
                }
                // Remove suffix (with optional leading space)
                if let range = unwrapped.range(of: " " + suffix, options: .backwards) {
                    unwrapped = unwrapped.replacingCharacters(in: range, with: "")
                } else if let range = unwrapped.range(of: suffix, options: .backwards) {
                    unwrapped = unwrapped.replacingCharacters(in: range, with: "")
                }
                textStorage.replaceCharacters(in: wrapRange, with: unwrapped)
            } else {
                // Wrap with prefix ... suffix
                let wrapped = prefix + " " + selectedText + " " + suffix
                textStorage.replaceCharacters(in: wrapRange, with: wrapped)
            }
            
            textView.undoManager?.endUndoGrouping()
            
            // Update parent binding
            parent.text = textView.text
        }
        
        /// Returns the correct single-line comment prefix for the given filename.
        private func commentPrefixForFilename(_ filename: String) -> String {
            let ext = (filename as NSString).pathExtension.lowercased()
            switch ext {
            case "py", "pyw", "rb", "sh", "bash", "zsh", "fish", "yaml", "yml", "toml", "r", "pl", "pm":
                return "#"
            case "lua", "sql", "hs":
                return "--"
            case "html", "xml", "svg":
                return "<!--" // Note: block comment, but best single-line approximation
            case "css", "scss", "less":
                return "/*" // CSS doesn't have single-line comments
            case "bat", "cmd":
                return "REM"
            case "vim":
                return "\""
            case "lisp", "clj", "cljs", "el":
                return ";"
            default:
                // Swift, JS, TS, C, C++, Java, Kotlin, Rust, Go, etc.
                return "//"
            }
        }
        
        /// Returns the closing comment suffix for block-comment languages, or nil for line-comment languages.
        private func commentSuffixForFilename(_ filename: String) -> String? {
            let ext = (filename as NSString).pathExtension.lowercased()
            switch ext {
            case "html", "xml", "svg":
                return "-->"
            case "css", "scss", "less":
                return "*/"
            default:
                return nil
            }
        }
        
        func handleFold(in textView: UITextView) {
            // Get the current cursor line (0-indexed)
            let cursorLine = parent.currentLineNumber - 1
            CodeFoldingManager.shared.foldAtLine(cursorLine)
        }
        
        func handleUnfold(in textView: UITextView) {
            // Get the current cursor line (0-indexed)
            let cursorLine = parent.currentLineNumber - 1
            CodeFoldingManager.shared.unfoldAtLine(cursorLine)
        }

        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard gesture.view is UITextView else { return }

            switch gesture.state {
            case .began:
                // Store the initial font size when pinch begins
                initialFontSize = parent.editorCore.editorFontSize

            case .changed:
                // Calculate new font size based on pinch scale
                let newSize = initialFontSize * gesture.scale

                // Clamp font size between 8 and 32
                let clampedSize = min(max(newSize, 8), 32)

                // Update EditorCore's font size (this will trigger updateUIView)
                parent.editorCore.editorFontSize = clampedSize

            case .ended, .cancelled:
                // Optional: snap to nearest whole number or standard size
                let finalSize = round(parent.editorCore.editorFontSize)
                parent.editorCore.editorFontSize = min(max(finalSize, 8), 32)

            default:
                break
            }
        }

        // MARK: - FEAT-044 Matching Bracket Highlight

        private func updateMatchingBracketHighlight(_ textView: UITextView) {
            // Clear any existing highlights
            if !bracketHighlightRanges.isEmpty {
                for r in bracketHighlightRanges {
                    textView.textStorage.removeAttribute(.backgroundColor, range: r)
                    textView.textStorage.removeAttribute(.underlineStyle, range: r)
                }
                bracketHighlightRanges.removeAll()
            }

            // Only highlight when there's a caret (no selection)
            let selection = textView.selectedRange
            guard selection.length == 0 else { return }

            let nsText = (textView.text ?? "") as NSString
            let length = nsText.length
            guard length > 0 else { return }

            let caret = selection.location

            // Candidate bracket location: char before caret, else at caret
            let candidateIndices: [Int] = [
                caret - 1,
                caret
            ].filter { $0 >= 0 && $0 < length }

            func isBracket(_ c: unichar) -> Bool {
                c == 123 || c == 125 || c == 40 || c == 41 || c == 91 || c == 93 // { } ( ) [ ]
            }

            var bracketIndex: Int?
            var bracketChar: unichar = 0

            for idx in candidateIndices {
                let c = nsText.character(at: idx)
                if isBracket(c) {
                    bracketIndex = idx
                    bracketChar = c
                    break
                }
            }

            guard let idx = bracketIndex else { return }

            // Define bracket pairs
            let openToClose: [unichar: unichar] = [123: 125, 40: 41, 91: 93] // { -> }, ( -> ), [ -> ]
            let closeToOpen: [unichar: unichar] = [125: 123, 41: 40, 93: 91] // } -> {, ) -> (, ] -> [

            let theme = ThemeManager.shared.currentTheme
            let bg = UIColor(theme.selection).withAlphaComponent(theme.isDark ? 0.35 : 0.22)

            var matchIndex: Int?

            if let close = openToClose[bracketChar] {
                // Opening bracket: scan forward
                var depth = 0
                var i = idx + 1
                while i < length {
                    let c = nsText.character(at: i)
                    if c == bracketChar {
                        depth += 1
                    } else if c == close {
                        if depth == 0 {
                            matchIndex = i
                            break
                        } else {
                            depth -= 1
                        }
                    }
                    i += 1
                }
            } else if let open = closeToOpen[bracketChar] {
                // Closing bracket: scan backward
                var depth = 0
                var i = idx - 1
                while i >= 0 {
                    let c = nsText.character(at: i)
                    if c == bracketChar {
                        depth += 1
                    } else if c == open {
                        if depth == 0 {
                            matchIndex = i
                            break
                        } else {
                            depth -= 1
                        }
                    }
                    i -= 1
                }
            }

            guard let match = matchIndex else { return }

            let r1 = NSRange(location: idx, length: 1)
            let r2 = NSRange(location: match, length: 1)

            textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r1)
            textView.textStorage.addAttribute(.backgroundColor, value: bg, range: r2)

            textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r1)
            textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: r2)

            bracketHighlightRanges = [r1, r2]
        }
        
        // MARK: - FEAT-NEW Word Occurrence Highlighting
        
        private func updateWordOccurrenceHighlights(_ textView: UITextView) {
            // Clear existing highlights
            if !wordOccurrenceRanges.isEmpty {
                for r in wordOccurrenceRanges {
                    textView.textStorage.removeAttribute(.backgroundColor, range: r)
                }
                wordOccurrenceRanges.removeAll()
            }
            
            let selection = textView.selectedRange
            let text = textView.text ?? ""
            
            // Only highlight when there's a selection (word selected)
            guard selection.length > 0 else { return }
            
            // Get occurrences
            let occurrences = WordOccurrenceHighlighter.shared.findOccurrences(in: text, selection: selection)
            
            // Need at least 2 occurrences (including the selected one) to show highlights
            guard occurrences.count >= 2 else { return }
            
            let theme = ThemeManager.shared.currentTheme
            let highlightColor = WordOccurrenceHighlighter.highlightColor(for: theme)
            
            // Apply highlights to all occurrences EXCEPT the current selection
            for occurrence in occurrences {
                // Skip the currently selected occurrence
                if occurrence.range.location == selection.location && occurrence.range.length == selection.length {
                    continue
                }
                
                textView.textStorage.addAttribute(.backgroundColor, value: highlightColor, range: occurrence.range)
                wordOccurrenceRanges.append(occurrence.range)
            }
        }
    }

}

// MARK: - FoldingLayoutManager
/// TextKit layout manager that collapses line fragments for lines marked folded in CodeFoldingManager.
/// This is a view-level folding implementation (it does NOT modify the underlying text).
final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
    weak var ownerTextView: EditorTextView?

    override init() {
        super.init()
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
    }

    func layoutManager(
        _ layoutManager: NSLayoutManager,
        shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<CGRect>,
        lineFragmentUsedRect: UnsafeMutablePointer<CGRect>,
        baselineOffset: UnsafeMutablePointer<CGFloat>,
        in textContainer: NSTextContainer,
        forGlyphRange glyphRange: NSRange
    ) -> Bool {
        guard let owner = ownerTextView else { return false }
        let (foldingManager, fileId) = MainActor.assumeIsolated {
            (owner.foldingManager, owner.fileId)
        }
        guard let foldingManager, let fileId
        else {
            return false
        }

        // Convert glyphRange -> characterRange so we can compute the line index.
        let charRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        let loc = max(0, charRange.location)

        let full = (self.textStorage?.string ?? "") as NSString
        let lineIndex = FoldingLayoutManager.lineIndex(atUTF16Location: loc, in: full)

        if foldingManager.isLineFolded(fileId: fileId, line: lineIndex) {
            // Collapse this visual line fragment.
            lineFragmentRect.pointee.size.height = 0
            lineFragmentUsedRect.pointee.size.height = 0
            baselineOffset.pointee = 0
            return true
        }

        return false
    }

    private static func lineIndex(atUTF16Location loc: Int, in text: NSString) -> Int {
        if loc <= 0 { return 0 }

        let capped = min(loc, text.length)
        var line = 0
        var searchStart = 0

        while searchStart < capped {
            let r = text.range(of: "\n", options: [], range: NSRange(location: searchStart, length: capped - searchStart))
            if r.location == NSNotFound { break }
            line += 1
            let next = r.location + 1
            if next >= capped { break }
            searchStart = next
        }

        return line
    }
}

// Custom text view to handle key commands, indent guides, and line highlighting
class EditorTextView: MultiCursorTextView {
    var onPeekDefinition: (() -> Void)?
    var onEscape: (() -> Void)?
    var onGoToLine: (() -> Void)?
    
    // Custom action closures for context menu
    var onGoToDefinition: (() -> Void)?
    var onFindReferences: (() -> Void)?
    var onFormatDocument: (() -> Void)?
    var onToggleComment: (() -> Void)?
    var onFold: (() -> Void)?
    var onUnfold: (() -> Void)?

    // Autocomplete key handling hooks are inherited from MultiCursorTextView
    
    // Code folding support - required by FoldingLayoutManager
    weak var foldingManager: CodeFoldingManager?
    var fileId: String?
    
    // FEAT-039 & FEAT-043
    private var indentGuideColor: UIColor = .separator
    private var activeIndentGuideColor: UIColor = .label
    private var currentLineHighlightColor: UIColor = .clear

    // PERF: Cached values to avoid recalculating on every draw()
    private var cachedTabSize: Int = 4
    private var cachedSpaceWidth: CGFloat = 0
    private var cachedIndentWidth: CGFloat = 0
    private var lastCachedFont: UIFont?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Ensure we redraw when bounds/selection change
        contentMode = .redraw
        updateCachedMeasurements()
    }
    
    /// PERF: Update cached measurements - call when font changes
    func updateCachedMeasurements() {
        let storedTabSize = UserDefaults.standard.integer(forKey: "tabSize")
        cachedTabSize = storedTabSize > 0 ? storedTabSize : 4
        
        if let font = self.font, font != lastCachedFont {
            cachedSpaceWidth = " ".size(withAttributes: [.font: font]).width
            cachedIndentWidth = cachedSpaceWidth * CGFloat(cachedTabSize)
            lastCachedFont = font
        }
    }
    
    func updateThemeColors(theme: Theme) {
        self.indentGuideColor = UIColor(theme.indentGuide)
        self.activeIndentGuideColor = UIColor(theme.indentGuideActive)
        self.currentLineHighlightColor = UIColor(theme.currentLineHighlight)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let font = self.font else {
            super.draw(rect)
            return
        }
        
        // 1. Draw Current Line Highlight (FEAT-043)
        if let selectedRange = selectedTextRange {
            // Get the line rect for the cursor position
            let caretRect = self.caretRect(for: selectedRange.start)
            let lineRect = CGRect(x: 0, y: caretRect.minY, width: bounds.width, height: caretRect.height)
            
            context.setFillColor(currentLineHighlightColor.cgColor)
            context.fill(lineRect)
        }

        // 2. Draw Text (super implementation)
        super.draw(rect)
        
        // 3. Draw Indent Guides (FEAT-039)
        // We iterate visible lines and draw vertical lines for indentation
        // Optimization: Only draw for visible range

        context.setLineWidth(1.0)

        // PERF: Use cached values instead of recalculating on every draw
        // Update cache if font changed
        if font != lastCachedFont {
            updateCachedMeasurements()
        }
        let tabSize = cachedTabSize
        let indentWidth = cachedIndentWidth

        // Determine active indent level for caret line (for indentGuideActive)
        var activeIndentLevel: Int = 0
        if let selected = selectedTextRange {
            let caretPos = offset(from: beginningOfDocument, to: selected.start)
            let nsText = (self.text ?? "") as NSString
            let safeLoc = min(max(0, caretPos), nsText.length)
            let caretLineRange = nsText.lineRange(for: NSRange(location: safeLoc, length: 0))
            let caretLineText = nsText.substring(with: caretLineRange)

            var spaces = 0
            for ch in caretLineText {
                if ch == " " { spaces += 1 }
                else if ch == "\t" { spaces += tabSize }
                else { break }
            }
            activeIndentLevel = spaces / tabSize
        }

        // Iterate visible glyphs/lines
        let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)

        let caretY = selectedTextRange.map { caretRect(for: $0.start).minY }

        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
            // Get text for this line
            guard let range = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil) as NSRange?,
                  let text = self.text as NSString? else { return }

            let lineText = text.substring(with: range)

            // Calculate indentation level
            var spaces = 0
            for char in lineText {
                if char == " " { spaces += 1 }
                else if char == "\t" { spaces += tabSize } // Handle tabs if present
                else { break }
            }

            let indentLevel = spaces / tabSize
            guard indentLevel > 0 else { return }

            let isCaretLine = (caretY != nil) && abs(rect.minY - (caretY ?? 0)) < 0.5

            for i in 1...indentLevel {
                let x = CGFloat(i) * indentWidth + self.textContainerInset.left
                let startPoint = CGPoint(x: x, y: rect.minY)
                let endPoint = CGPoint(x: x, y: rect.maxY)

                let stroke = (isCaretLine && i == activeIndentLevel) ? self.activeIndentGuideColor : self.indentGuideColor
                context.setStrokeColor(stroke.cgColor)

                context.move(to: startPoint)
                context.addLine(to: endPoint)
                context.strokePath()
            }
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        // NOTE: Only define text-editing specific shortcuts here.
        // App-level shortcuts (Cmd+B, Cmd+P, Cmd+N, Cmd+S, Cmd+W, Cmd+F, etc.)
        // are defined in the Menus/ folder via SwiftUI's .keyboardShortcut().
        // See: KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
        // Defining them here AND in Menus/ causes duplicate conflicts.
        
        var commands = super.keyCommands ?? []
        
        // Peek Definition: Option+D (editor-specific, not in menus)
        commands.append(UIKeyCommand(
            input: "d",
            modifierFlags: .alternate,
            action: #selector(handlePeekDefinition)
        ))

        // NOTE: Cmd+G (Go to Line) is defined in GoMenuCommands.swift - DO NOT ADD HERE

        // Tab: accept autocomplete if visible, else insert tab
        commands.append(UIKeyCommand(
            input: "\t",
            modifierFlags: [],
            action: #selector(handleTab)
        ))
        
        // Escape: dismiss autocomplete/peek if visible
        commands.append(UIKeyCommand(
            input: UIKeyCommand.inputEscape,
            modifierFlags: [],
            action: #selector(handleEscape)
        ))
        
        // Fold: Cmd+Opt+[
        commands.append(UIKeyCommand(
            input: "[",
            modifierFlags: [.command, .alternate],
            action: #selector(handleFold)
        ))
        
        // Unfold: Cmd+Opt+]
        commands.append(UIKeyCommand(
            input: "]",
            modifierFlags: [.command, .alternate],
            action: #selector(handleUnfold)
        ))
        
        // NOTE: Cmd+Shift+P, Cmd+Shift+A, Cmd+J, Cmd+B are now handled
        // globally via AppDelegate.buildMenu() so they work regardless of focus.
        
        // Undo: Cmd+Z
        commands.append(UIKeyCommand(
            input: "z",
            modifierFlags: .command,
            action: #selector(handleUndo)
        ))
        
        // Redo: Cmd+Shift+Z
        commands.append(UIKeyCommand(
            input: "z",
            modifierFlags: [.command, .shift],
            action: #selector(handleRedo)
        ))
        
        return commands
    }
    
    @objc func handlePeekDefinition() {
        onPeekDefinition?()
    }

    @objc func handleGoToLine() {
        onGoToLine?()
    }

    @objc func handleTab() {
        // Defer to next runloop iteration to avoid modifying @Binding during view update cycle
        // Using asyncAfter(.now()) instead of async to guarantee execution AFTER current cycle completes
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let self = self else { return }
            if self.onAcceptAutocomplete?() == true {
                return
            }
            self.insertText("\t")
        }
    }
    
    @objc func handleEscape() {
        if onDismissAutocomplete?() == true {
            return
        }
        onEscape?()
    }
    
    @objc func handleFold() {
        onFold?()
    }
    
    @objc func handleUnfold() {
        onUnfold?()
    }

    // MARK: - Undo / Redo

    @objc func handleUndo() {
        undoManager?.undo()
    }

    @objc func handleRedo() {
        undoManager?.redo()
    }
    
    // MARK: - App-Level Shortcut Handlers
    
    @objc func handleShowCommandPalette() {
        NotificationCenter.default.post(name: .showCommandPalette, object: nil)
    }
    
    @objc func handleToggleTerminal() {
        NotificationCenter.default.post(name: .toggleTerminal, object: nil)
    }
    
    @objc func handleShowAIAssistant() {
        NotificationCenter.default.post(name: .showAIAssistant, object: nil)
    }
    
    @objc func handleToggleSidebar() {
        NotificationCenter.default.post(name: .toggleSidebar, object: nil)
    }
    
    @objc func handleShowQuickOpen() {
        NotificationCenter.default.post(name: .showQuickOpen, object: nil)
    }
    
    @objc func handleNewFile() {
        NotificationCenter.default.post(name: .newFile, object: nil)
    }
    
    @objc func handleSaveFile() {
        NotificationCenter.default.post(name: .saveFile, object: nil)
    }
    
    @objc func handleCloseTab() {
        NotificationCenter.default.post(name: .closeTab, object: nil)
    }
    
    @objc func handleFind() {
        NotificationCenter.default.post(name: .showFind, object: nil)
    }
    
    @objc func handleZoomIn() {
        NotificationCenter.default.post(name: .zoomIn, object: nil)
    }
    
    @objc func handleZoomOut() {
        NotificationCenter.default.post(name: .zoomOut, object: nil)
    }
    
    // MARK: - Custom Actions
    
    @objc private func goToDefinition(_ sender: Any?) {
        onGoToDefinition?()
    }
    
    @objc private func peekDefinition(_ sender: Any?) {
        onPeekDefinition?()
    }
    
    @objc private func findReferences(_ sender: Any?) {
        onFindReferences?()
    }
    
    @objc private func formatDocument(_ sender: Any?) {
        onFormatDocument?()
    }
    
    @objc private func toggleComment(_ sender: Any?) {
        onToggleComment?()
    }
    
    // MARK: - Menu Support
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Enable custom actions
        if action == #selector(goToDefinition(_:)) {
            return onGoToDefinition != nil
        }
        if action == #selector(peekDefinition(_:)) {
            return onPeekDefinition != nil
        }
        if action == #selector(findReferences(_:)) {
            return onFindReferences != nil
        }
        if action == #selector(formatDocument(_:)) {
            return onFormatDocument != nil
        }
        if action == #selector(toggleComment(_:)) {
            return onToggleComment != nil
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        guard builder.menu(for: .text) != nil else { return }
        
        // Create custom menu items
        let goToDefinitionAction = UIAction(
            title: "Go to Definition",
            image: UIImage(systemName: "arrow.forward.circle"),
            identifier: UIAction.Identifier("com.vscode.goToDefinition"),
            handler: { [weak self] _ in
                self?.goToDefinition(nil)
            }
        )
        
        let peekDefinitionAction = UIAction(
            title: "Peek Definition",
            image: UIImage(systemName: "eye"),
            identifier: UIAction.Identifier("com.vscode.peekDefinition"),
            handler: { [weak self] _ in
                self?.peekDefinition(nil)
            }
        )
        
        let findReferencesAction = UIAction(
            title: "Find All References",
            image: UIImage(systemName: "magnifyingglass"),
            identifier: UIAction.Identifier("com.vscode.findReferences"),
            handler: { [weak self] _ in
                self?.findReferences(nil)
            }
        )
        
        let formatDocumentAction = UIAction(
            title: "Format Document",
            image: UIImage(systemName: "text.alignleft"),
            identifier: UIAction.Identifier("com.vscode.formatDocument"),
            handler: { [weak self] _ in
                self?.formatDocument(nil)
            }
        )
        
        let toggleCommentAction = UIAction(
            title: "Toggle Comment",
            image: UIImage(systemName: "text.quote"),
            identifier: UIAction.Identifier("com.vscode.toggleComment"),
            handler: { [weak self] _ in
                self?.toggleComment(nil)
            }
        )
        
        // Group custom actions
        let customMenu = UIMenu(
            title: "",
            identifier: UIMenu.Identifier("com.vscode.customActions"),
            options: [.displayInline],
            children: [
                goToDefinitionAction,
                peekDefinitionAction,
                findReferencesAction,
                formatDocumentAction,
                toggleCommentAction
            ]
        )
        
        // Insert custom menu after standard edit menu
        builder.insertChild(customMenu, atStartOfMenu: .text)
    }
}

// MARK: - VSCode-Style Syntax Highlighter

enum SyntaxLanguage {
    case swift

    case javascript
    case typescript
    case jsx
    case tsx

    case python
    case ruby
    case go
    case rust
    case java
    case kotlin

    case c
    case cpp
    case objectiveC

    case html
    case css
    case scss
    case less
    case json
    case xml
    case yaml
    case sql

    case shell
    case dockerfile
    case graphql
    case markdown
    case php
    case env

    case plainText
}

struct VSCodeSyntaxHighlighter {
    private let baseFontSize: CGFloat
    let theme: Theme
    
    init(theme: Theme, fontSize: CGFloat = 14) {
        self.theme = theme
        self.baseFontSize = fontSize
    }
    
    func highlight(_ text: String, filename: String) -> NSAttributedString {
        let language = detectLanguage(from: filename)
        return highlight(text, language: language)
    }
    
    private func detectLanguage(from filename: String) -> SyntaxLanguage {
        let lower = filename.lowercased()
        let ext = (filename as NSString).pathExtension.lowercased()

        // Special-case filenames without extensions
        if (filename as NSString).lastPathComponent.lowercased() == "dockerfile" { return .dockerfile }
        if (filename as NSString).lastPathComponent.lowercased() == ".env" { return .env }
        if lower.hasSuffix("/.env") { return .env }

        switch ext {
        case "swift": return .swift

        case "js", "mjs", "cjs": return .javascript
        case "jsx": return .jsx
        case "ts", "mts", "cts": return .typescript
        case "tsx": return .tsx

        case "py", "pyw": return .python
        case "rb", "ruby": return .ruby
        case "go": return .go
        case "rs": return .rust
        case "java": return .java
        case "kt", "kts": return .kotlin

        case "c", "h": return .c
        case "cpp", "cc", "cxx", "hpp", "hh", "hxx": return .cpp
        case "m", "mm": return .objectiveC

        case "html", "htm": return .html
        case "css": return .css
        case "scss", "sass": return .scss
        case "less": return .less
        case "json", "jsonc": return .json
        case "xml", "plist", "svg": return .xml
        case "yml", "yaml": return .yaml
        case "sql": return .sql

        case "sh", "bash", "zsh", "fish": return .shell
        case "dockerfile": return .dockerfile

        case "graphql", "gql": return .graphql

        case "md", "markdown": return .markdown
        case "php": return .php
        case "env": return .env

        default: return .plainText
        }
    }
    
    private func highlight(_ text: String, language: SyntaxLanguage) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: text.utf16.count)
        
        // Base attributes
        let baseFont = UIFont.monospacedSystemFont(ofSize: baseFontSize, weight: .regular)
        attributed.addAttribute(.font, value: baseFont, range: fullRange)
        attributed.addAttribute(.foregroundColor, value: UIColor(theme.editorForeground), range: fullRange)
        
        // Apply language-specific highlighting
        switch language {
        case .swift: highlightSwift(attributed, text: text)
        case .javascript, .jsx: highlightJavaScript(attributed, text: text, isTS: false)
        case .typescript, .tsx: highlightJavaScript(attributed, text: text, isTS: true)
        case .python: highlightPython(attributed, text: text)
        case .html, .xml: highlightHTML(attributed, text: text)
        case .css, .scss, .less: highlightCSS(attributed, text: text)
        case .json: highlightJSON(attributed, text: text)
        case .markdown: highlightMarkdown(attributed, text: text)
        case .rust: highlightRust(attributed, text: text)
        case .go: highlightGo(attributed, text: text)
        case .java, .kotlin: highlightJava(attributed, text: text)
        case .c, .cpp, .objectiveC: highlightCpp(attributed, text: text)
        case .ruby: highlightRuby(attributed, text: text)
        case .php: highlightPHP(attributed, text: text)
        case .shell, .dockerfile: highlightShell(attributed, text: text)
        case .yaml, .env: highlightYAML(attributed, text: text)
        case .sql: highlightSQL(attributed, text: text)
        case .graphql: highlightGraphQL(attributed, text: text)
        case .plainText: break
        }
        
        // FEAT-038: Bracket Pair Colorization (applied last)
        highlightBracketPairs(attributed, text: text)
        
        return attributed
    }
    
    // MARK: - Bracket Pair Colorization
    
    private func highlightBracketPairs(_ attributed: NSMutableAttributedString, text: String) {
        let brackets: [Character] = ["{", "}", "[", "]", "(", ")"]
        let pairs: [Character: Character] = ["}": "{", "]": "[", ")": "("]
        
        var stack: [(char: Character, index: Int, depth: Int)] = []
        let colors = [
            UIColor(theme.bracketPair1),
            UIColor(theme.bracketPair2),
            UIColor(theme.bracketPair3),
            UIColor(theme.bracketPair4),
            UIColor(theme.bracketPair5),
            UIColor(theme.bracketPair6)
        ]
        
        // Colors to skip: brackets inside strings or comments should not be colorized
        let stringColor = UIColor(theme.string)
        let commentColor = UIColor(theme.comment)
        
        // Optimization: Use scanner or direct iteration
        let nsString = text as NSString
        var index = 0
        
        while index < text.utf16.count {
            let char = nsString.character(at: index)
            if let scalar = UnicodeScalar(char) {
                let c = Character(scalar)
                
                if brackets.contains(c) {
                    // Check if this bracket is inside a string or comment by examining
                    // the foreground color already applied by syntax highlighting.
                    // Since bracket colorization runs LAST, existing colors indicate
                    // the token type from the syntax highlighter.
                    let existingAttrs = attributed.attributes(at: index, effectiveRange: nil)
                    if let existingColor = existingAttrs[.foregroundColor] as? UIColor {
                        if existingColor == stringColor || existingColor == commentColor {
                            // Skip brackets inside strings/comments
                            index += 1
                            continue
                        }
                    }
                    
                    if let open = pairs[c] { // Closing bracket
                        if let last = stack.last, last.char == open {
                            // Match found
                            let depth = last.depth
                            let color = colors[depth % colors.count]
                            
                            attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
                            attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: last.index, length: 1))
                            
                            stack.removeLast()
                        } else {
                            // Mismatched or extra closing bracket - unexpected
                            // Keep default color or mark red? Default for now.
                        }
                    } else { // Opening bracket
                        let depth = stack.count
                        stack.append((c, index, depth))
                        
                        // Color tentatively based on depth.
                        let color = colors[depth % colors.count]
                        attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
                    }
                }
            }
            index += 1
        }
    }
    
    // MARK: - Swift Highlighting
    
    private func highlightSwift(_ attributed: NSMutableAttributedString, text: String) {
        // Keywords (purple/pink)
        let keywords = ["func", "var", "let", "if", "else", "for", "while", "return",
                       "class", "struct", "enum", "protocol", "extension", "import",
                       "private", "public", "internal", "fileprivate", "open",
                       "static", "final", "override", "mutating", "nonmutating",
                       "init", "deinit", "subscript", "typealias", "associatedtype",
                       "where", "throws", "rethrows", "async", "await", "actor",
                       "guard", "defer", "do", "try", "catch", "throw",
                       "switch", "case", "default", "break", "continue", "fallthrough",
                       "in", "is", "as", "inout", "some", "any", "Self",
                       "get", "set", "willSet", "didSet", "lazy", "weak", "unowned",
                       "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject",
                       "@Environment", "@EnvironmentObject", "@ViewBuilder", "@MainActor",
                       "@escaping", "@autoclosure", "@available", "@objc", "@discardableResult"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        // Types (teal) - CamelCase words that aren't keywords
        let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
        highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
        
        // Function calls (yellow)
        let funcCallPattern = "\\b([a-z][a-zA-Z0-9]*)\\s*\\("
        highlightPattern(attributed, pattern: funcCallPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
        
        // Constants (blue)
        let constants = ["true", "false", "nil", "self", "super"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        // Comments MUST come late (green) - they override everything
        highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
        
        // Strings AFTER comments (orange)
        highlightStrings(attributed, text: text)
        
        // Numbers (light green)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - JavaScript/TypeScript Highlighting
    
    private func highlightJavaScript(_ attributed: NSMutableAttributedString, text: String, isTS: Bool) {
        var keywords = ["function", "var", "let", "const", "if", "else", "for", "while",
                       "return", "class", "extends", "new", "this", "super", "import",
                       "export", "default", "from", "as", "async", "await", "yield",
                       "try", "catch", "finally", "throw", "typeof", "instanceof",
                       "switch", "case", "break", "continue", "do", "in", "of",
                       "get", "set", "static", "constructor", "delete", "void",
                       "with", "debugger"]
        
        if isTS {
            keywords += ["interface", "type", "enum", "namespace", "module", "declare",
                        "implements", "public", "private", "protected", "readonly",
                        "abstract", "override", "keyof", "infer", "never", "unknown",
                        "any", "asserts", "is"]
        }
        
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        // Constants
        let constants = ["true", "false", "null", "undefined", "NaN", "Infinity"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        // Function names (yellow) - regular calls + arrow functions
        let funcNamePattern = "\\b([a-zA-Z_$][a-zA-Z0-9_$]*)\\b(?=\\s*(?:\\(|=>))"
        highlightPattern(attributed, pattern: funcNamePattern, color: UIColor(theme.function), text: text, captureGroup: 1)
        
        // Types (teal)
        let typePattern = "\\b[A-Z][a-zA-Z0-9]*\\b"
        highlightPattern(attributed, pattern: typePattern, color: UIColor(theme.type), text: text)
        
        highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
        highlightStrings(attributed, text: text)
        highlightJSTemplateLiterals(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - Python Highlighting
    
    private func highlightPython(_ attributed: NSMutableAttributedString, text: String) {
        let keywords = ["def", "class", "if", "elif", "else", "for", "while", "return",
                       "import", "from", "as", "try", "except", "finally", "raise",
                       "with", "assert", "yield", "lambda", "pass", "break", "continue",
                       "global", "nonlocal", "del", "in", "not", "and", "or", "is",
                       "async", "await", "match", "case"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        let constants = ["True", "False", "None", "self", "cls"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        // Decorators (yellow)
        let decoratorPattern = "@[a-zA-Z_][a-zA-Z0-9_\\.]*"
        highlightPattern(attributed, pattern: decoratorPattern, color: UIColor(theme.function), text: text)
        
        // Function definitions (yellow)
        let funcDefPattern = "(?<=def\\s)[a-zA-Z_][a-zA-Z0-9_]*"
        highlightPattern(attributed, pattern: funcDefPattern, color: UIColor(theme.function), text: text)
        
        // Class names (teal)
        let classPattern = "(?<=class\\s)[a-zA-Z_][a-zA-Z0-9_]*"
        highlightPattern(attributed, pattern: classPattern, color: UIColor(theme.type), text: text)
        
        // Built-in functions (yellow)
        let builtins = ["print", "len", "range", "str", "int", "float", "list", "dict", "set",
                       "tuple", "bool", "type", "isinstance", "hasattr", "getattr", "setattr",
                       "open", "input", "map", "filter", "reduce", "zip", "enumerate",
                       "sorted", "reversed", "min", "max", "sum", "abs", "round",
                       "super", "object", "Exception", "ValueError", "TypeError"]
        highlightKeywords(attributed, keywords: builtins, color: UIColor(theme.function), text: text)
        
        highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
        highlightPythonStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - HTML Highlighting
    
    private func highlightHTML(_ attributed: NSMutableAttributedString, text: String) {
        // Tags (blue)
        let tagPattern = "</?\\s*([a-zA-Z][a-zA-Z0-9-]*)(?=[\\s>])"
        highlightPattern(attributed, pattern: tagPattern, color: UIColor(theme.keyword), text: text)
        
        // Attributes (light blue)
        let attrPattern = "\\s([a-zA-Z][a-zA-Z0-9-]*)\\s*="
        highlightPattern(attributed, pattern: attrPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
        
        // Angle brackets
        let bracketPattern = "[<>/?]"
        highlightPattern(attributed, pattern: bracketPattern, color: UIColor.gray, text: text)
        
        // Comments
        highlightHTMLComments(attributed, text: text)
        
        // Strings
        highlightStrings(attributed, text: text)
    }
    
    // MARK: - CSS Highlighting
    
    private func highlightCSS(_ attributed: NSMutableAttributedString, text: String) {
        // Selectors (yellow)
        let selectorPattern = "([.#]?[a-zA-Z][a-zA-Z0-9_-]*)\\s*\\{"
        highlightPattern(attributed, pattern: selectorPattern, color: UIColor(theme.function), text: text, captureGroup: 1)
        
        // Properties (light blue)
        let propertyPattern = "([a-zA-Z-]+)\\s*:"
        highlightPattern(attributed, pattern: propertyPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
        
        // Values with units
        let unitPattern = "\\b(\\d+)(px|em|rem|%|vh|vw|pt|cm|mm|in)\\b"
        highlightPattern(attributed, pattern: unitPattern, color: UIColor(theme.number), text: text)
        
        // Colors
        let hexPattern = "#[0-9a-fA-F]{3,8}\\b"
        highlightPattern(attributed, pattern: hexPattern, color: UIColor(theme.number), text: text)
        
        // Keywords
        let keywords = ["important", "inherit", "initial", "unset", "none", "auto",
                       "block", "inline", "flex", "grid", "absolute", "relative", "fixed"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        highlightComments(attributed, text: text, singleLine: nil, multiLineStart: "/*", multiLineEnd: "*/")
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - JSON Highlighting
    
    private func highlightJSON(_ attributed: NSMutableAttributedString, text: String) {
        // Keys (light blue)
        let keyPattern = "\"([^\"]+)\"\\s*:"
        highlightPattern(attributed, pattern: keyPattern, color: UIColor(theme.variable), text: text, captureGroup: 1)
        
        // String values (orange)
        highlightStrings(attributed, text: text)
        
        // Numbers (light green)
        highlightNumbers(attributed, text: text)
        
        // Booleans and null (use keyword color)
        let constants = ["true", "false", "null"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.keyword), text: text)
    }
    
    // MARK: - Markdown Highlighting
    
    private func highlightMarkdown(_ attributed: NSMutableAttributedString, text: String) {
        // Headers (blue + bold)
        let headerPattern = "^#{1,6}\\s+.+$"
        highlightPattern(attributed, pattern: headerPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
        
        // Bold (orange)
        let boldPattern = "\\*\\*[^*]+\\*\\*|__[^_]+__"
        highlightPattern(attributed, pattern: boldPattern, color: UIColor(theme.string), text: text)
        
        // Italic
        let italicPattern = "(?<!\\*)\\*[^*]+\\*(?!\\*)|(?<!_)_[^_]+_(?!_)"
        highlightPattern(attributed, pattern: italicPattern, color: UIColor.secondaryLabel, text: text)
        
        // Code blocks (green)
        let codeBlockPattern = "```[\\s\\S]*?```|`[^`]+`"
        highlightPattern(attributed, pattern: codeBlockPattern, color: UIColor(theme.comment), text: text)
        
        // Links (light blue)
        let linkPattern = "\\[[^\\]]+\\]\\([^)]+\\)"
        highlightPattern(attributed, pattern: linkPattern, color: UIColor(theme.variable), text: text)
        
        // Lists
        let listPattern = "^\\s*[-*+]\\s"
        highlightPattern(attributed, pattern: listPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
    }
    
    // MARK: - Rust Highlighting
    
    private func highlightRust(_ attributed: NSMutableAttributedString, text: String) {
        let keywords = ["fn", "let", "mut", "const", "if", "else", "match", "loop", "while", "for",
                       "return", "struct", "enum", "impl", "trait", "type", "use", "mod", "pub",
                       "self", "Self", "super", "crate", "as", "in", "ref", "move", "async", "await",
                       "where", "unsafe", "extern", "dyn", "static", "break", "continue"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        let types = ["i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize",
                    "f32", "f64", "bool", "char", "str", "String", "Vec", "Option", "Result", "Box"]
        highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
        
        let constants = ["true", "false", "None", "Some", "Ok", "Err"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        // Macros (yellow)
        let macroPattern = "[a-zA-Z_][a-zA-Z0-9_]*!"
        highlightPattern(attributed, pattern: macroPattern, color: UIColor(theme.function), text: text)
        
        // Lifetimes (orange)
        let lifetimePattern = "'[a-zA-Z_][a-zA-Z0-9_]*"
        highlightPattern(attributed, pattern: lifetimePattern, color: UIColor(theme.string), text: text)
        
        highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - Go Highlighting
    
    private func highlightGo(_ attributed: NSMutableAttributedString, text: String) {
        let keywords = ["func", "var", "const", "type", "struct", "interface", "map", "chan",
                       "if", "else", "for", "range", "switch", "case", "default", "select",
                       "return", "break", "continue", "goto", "fallthrough", "defer", "go",
                       "package", "import"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        let types = ["int", "int8", "int16", "int32", "int64", "uint", "uint8", "uint16", "uint32", "uint64",
                    "float32", "float64", "complex64", "complex128", "byte", "rune", "string", "bool", "error"]
        highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
        
        let constants = ["true", "false", "nil", "iota"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - Java Highlighting
    
    private func highlightJava(_ attributed: NSMutableAttributedString, text: String) {
        let keywords = ["public", "private", "protected", "class", "interface", "extends", "implements",
                       "static", "final", "abstract", "native", "synchronized", "volatile", "transient",
                       "if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue",
                       "return", "throw", "throws", "try", "catch", "finally", "new", "this", "super",
                       "import", "package", "instanceof", "assert", "enum", "void"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        let types = ["int", "long", "short", "byte", "float", "double", "char", "boolean",
                    "String", "Integer", "Long", "Double", "Boolean", "Object", "List", "Map", "Set"]
        highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
        
        let constants = ["true", "false", "null"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        // Annotations
        let annotationPattern = "@[a-zA-Z][a-zA-Z0-9]*"
        highlightPattern(attributed, pattern: annotationPattern, color: UIColor(theme.function), text: text)
        
        highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - C/C++ Highlighting
    
    private func highlightCpp(_ attributed: NSMutableAttributedString, text: String) {
        let keywords = ["auto", "break", "case", "catch", "class", "const", "continue", "default",
                       "delete", "do", "else", "enum", "explicit", "extern", "for", "friend", "goto",
                       "if", "inline", "mutable", "namespace", "new", "operator", "private", "protected",
                       "public", "register", "return", "sizeof", "static", "struct", "switch", "template",
                       "this", "throw", "try", "typedef", "typename", "union", "using", "virtual",
                       "volatile", "while", "constexpr", "nullptr", "override", "final", "noexcept"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        let types = ["void", "int", "long", "short", "char", "float", "double", "bool", "signed", "unsigned",
                    "int8_t", "int16_t", "int32_t", "int64_t", "uint8_t", "uint16_t", "uint32_t", "uint64_t",
                    "size_t", "string", "vector", "map", "set", "unique_ptr", "shared_ptr"]
        highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
        
        let constants = ["true", "false", "NULL", "nullptr"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        // Preprocessor directives
        let preprocPattern = "^\\s*#\\s*(include|define|ifdef|ifndef|endif|if|else|elif|pragma|error|warning).*$"
        highlightPattern(attributed, pattern: preprocPattern, color: UIColor(theme.keyword), text: text, options: .anchorsMatchLines)
        
        highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - Ruby Highlighting
    
    private func highlightRuby(_ attributed: NSMutableAttributedString, text: String) {
        let keywords = ["def", "class", "module", "if", "elsif", "else", "unless", "case", "when",
                       "while", "until", "for", "do", "end", "begin", "rescue", "ensure", "raise",
                       "return", "yield", "break", "next", "redo", "retry", "self", "super",
                       "require", "require_relative", "include", "extend", "attr_reader", "attr_writer", "attr_accessor",
                       "public", "private", "protected", "alias", "and", "or", "not", "in"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        let constants = ["true", "false", "nil"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        // Symbols (orange)
        let symbolPattern = ":[a-zA-Z_][a-zA-Z0-9_]*"
        highlightPattern(attributed, pattern: symbolPattern, color: UIColor(theme.string), text: text)
        
        // Instance variables (light blue)
        let ivarPattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
        highlightPattern(attributed, pattern: ivarPattern, color: UIColor(theme.variable), text: text)
        
        highlightComments(attributed, text: text, singleLine: "#", multiLineStart: "=begin", multiLineEnd: "=end")
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - PHP Highlighting
    
    private func highlightPHP(_ attributed: NSMutableAttributedString, text: String) {
        let keywords = ["function", "class", "interface", "trait", "extends", "implements", "use",
                       "public", "private", "protected", "static", "final", "abstract", "const",
                       "if", "else", "elseif", "switch", "case", "default", "for", "foreach", "while", "do",
                       "return", "break", "continue", "throw", "try", "catch", "finally",
                       "new", "clone", "instanceof", "echo", "print", "die", "exit",
                       "require", "require_once", "include", "include_once", "namespace"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        let constants = ["true", "false", "null", "TRUE", "FALSE", "NULL"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        // Variables (light blue)
        let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
        highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
        
        highlightComments(attributed, text: text, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/")
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - Shell Highlighting
    
    private func highlightShell(_ attributed: NSMutableAttributedString, text: String) {
        let keywords = ["if", "then", "else", "elif", "fi", "for", "while", "do", "done", "case", "esac",
                       "function", "return", "exit", "break", "continue", "local", "export", "readonly",
                       "source", "alias", "unalias", "set", "unset", "shift", "eval", "exec",
                       "echo", "printf", "read", "cd", "pwd", "ls", "mkdir", "rm", "cp", "mv"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        // Variables (light blue)
        let varPattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*|\\$\\{[^}]+\\}"
        highlightPattern(attributed, pattern: varPattern, color: UIColor(theme.variable), text: text)
        
        highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - YAML Highlighting
    
    private func highlightYAML(_ attributed: NSMutableAttributedString, text: String) {
        // Keys (light blue)
        let keyPattern = "^\\s*([a-zA-Z_][a-zA-Z0-9_-]*)\\s*:"
        highlightPattern(attributed, pattern: keyPattern, color: UIColor(theme.variable), text: text, options: .anchorsMatchLines, captureGroup: 1)
        
        // Booleans and null
        let constants = ["true", "false", "yes", "no", "on", "off", "null", "~"]
        highlightKeywords(attributed, keywords: constants, color: UIColor(theme.variable), text: text)
        
        highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - SQL Highlighting
    
    private func highlightSQL(_ attributed: NSMutableAttributedString, text: String) {
        let keywords = ["SELECT", "FROM", "WHERE", "AND", "OR", "NOT", "IN", "LIKE", "BETWEEN",
                       "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE", "CREATE", "ALTER", "DROP",
                       "TABLE", "INDEX", "VIEW", "DATABASE", "SCHEMA", "PRIMARY", "KEY", "FOREIGN", "REFERENCES",
                       "JOIN", "INNER", "LEFT", "RIGHT", "OUTER", "FULL", "ON", "AS", "DISTINCT",
                       "ORDER", "BY", "ASC", "DESC", "GROUP", "HAVING", "LIMIT", "OFFSET", "UNION",
                       "NULL", "IS", "TRUE", "FALSE", "CASE", "WHEN", "THEN", "ELSE", "END",
                       "COUNT", "SUM", "AVG", "MIN", "MAX", "COALESCE", "CAST",
                       "select", "from", "where", "and", "or", "not", "in", "like", "between",
                       "insert", "into", "values", "update", "set", "delete", "create", "alter", "drop",
                       "table", "index", "view", "database", "schema", "primary", "key", "foreign", "references",
                       "join", "inner", "left", "right", "outer", "full", "on", "as", "distinct",
                       "order", "by", "asc", "desc", "group", "having", "limit", "offset", "union",
                       "null", "is", "true", "false", "case", "when", "then", "else", "end"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        let types = ["INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT", "FLOAT", "DOUBLE", "DECIMAL",
                    "VARCHAR", "CHAR", "TEXT", "BLOB", "DATE", "TIME", "DATETIME", "TIMESTAMP", "BOOLEAN",
                    "int", "integer", "bigint", "smallint", "tinyint", "float", "double", "decimal",
                    "varchar", "char", "text", "blob", "date", "time", "datetime", "timestamp", "boolean"]
        highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
        
        highlightComments(attributed, text: text, singleLine: "--", multiLineStart: "/*", multiLineEnd: "*/")
        highlightStrings(attributed, text: text)
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - GraphQL Highlighting
    
    private func highlightGraphQL(_ attributed: NSMutableAttributedString, text: String) {
        // Keywords
        let keywords = ["query", "mutation", "subscription", "fragment", "on", "type", 
                       "interface", "union", "enum", "scalar", "input", "extend", 
                       "directive", "schema", "implements"]
        highlightKeywords(attributed, keywords: keywords, color: UIColor(theme.keyword), text: text)
        
        // Built-in scalar types
        let types = ["Int", "Float", "String", "Boolean", "ID"]
        highlightKeywords(attributed, keywords: types, color: UIColor(theme.type), text: text)
        
        // Variables ($name)
        let variablePattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
        highlightPattern(attributed, pattern: variablePattern, color: UIColor(theme.variable), text: text)
        
        // Directives (@deprecated, @skip, @include, etc.)
        let directivePattern = "@[a-zA-Z_][a-zA-Z0-9_]*"
        highlightPattern(attributed, pattern: directivePattern, color: UIColor(theme.function), text: text)
        
        // Comments (# single line)
        highlightComments(attributed, text: text, singleLine: "#", multiLineStart: nil, multiLineEnd: nil)
        
        // Strings
        highlightStrings(attributed, text: text)
        
        // Numbers
        highlightNumbers(attributed, text: text)
    }
    
    // MARK: - Helper Methods
    
    private func highlightKeywords(_ attributed: NSMutableAttributedString, keywords: [String], color: UIColor, text: String) {
        for keyword in keywords {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            highlightPattern(attributed, pattern: pattern, color: color, text: text)
        }
    }
    
    // Static cache: NSRegularExpression is thread-safe once created, so we compile each
    // pattern+options pair exactly once and reuse it across all highlight passes.
    // With 50-100 calls per highlight pass this eliminates nearly all regex compilation cost.
    // regexCache moved to file-level private global to satisfy concurrency safety

    private func highlightPattern(_ attributed: NSMutableAttributedString, pattern: String, color: UIColor, text: String, options: NSRegularExpression.Options = [], captureGroup: Int = 0) {
        // Cache key encodes both the pattern and the option flags so different option
        // combinations don't collide.
        let cacheKey = "\(options.rawValue):\(pattern)"
        let regex: NSRegularExpression
        if let cached = syntaxRegexCache[cacheKey] {
            regex = cached
        } else {
            guard let compiled = try? NSRegularExpression(pattern: pattern, options: options) else { return }
            syntaxRegexCache[cacheKey] = compiled
            regex = compiled
        }
        let range = NSRange(location: 0, length: text.utf16.count)

        regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            let matchRange = captureGroup > 0 && match.numberOfRanges > captureGroup
                ? match.range(at: captureGroup)
                : match.range
            if matchRange.location != NSNotFound {
                attributed.addAttribute(.foregroundColor, value: color, range: matchRange)
            }
        }
    }
    
    private func highlightStrings(_ attributed: NSMutableAttributedString, text: String) {
        // Double-quoted strings
        let doublePattern = "\"(?:[^\"\\\\]|\\\\.)*\""
        highlightPattern(attributed, pattern: doublePattern, color: UIColor(theme.string), text: text)
        
        // Single-quoted strings
        let singlePattern = "'(?:[^'\\\\]|\\\\.)*'"
        highlightPattern(attributed, pattern: singlePattern, color: UIColor(theme.string), text: text)
    }
    
    private func highlightPythonStrings(_ attributed: NSMutableAttributedString, text: String) {
        // Triple-quoted strings first
        let tripleDoublePattern = "\"\"\"[\\s\\S]*?\"\"\""
        highlightPattern(attributed, pattern: tripleDoublePattern, color: UIColor(theme.string), text: text)
        
        let tripleSinglePattern = "'''[\\s\\S]*?'''"
        highlightPattern(attributed, pattern: tripleSinglePattern, color: UIColor(theme.string), text: text)
        
        // Then regular strings
        highlightStrings(attributed, text: text)
        
        // F-strings (with expressions highlighted differently)
        let fstringPattern = "f\"[^\"]*\"|f'[^']*'"
        highlightPattern(attributed, pattern: fstringPattern, color: UIColor(theme.string), text: text)
    }
    
    private func highlightJSTemplateLiterals(_ attributed: NSMutableAttributedString, text: String) {
        // Template literals
        let templatePattern = "`[^`]*`"
        highlightPattern(attributed, pattern: templatePattern, color: UIColor(theme.string), text: text)
    }
    
    private func highlightComments(_ attributed: NSMutableAttributedString, text: String, singleLine: String?, multiLineStart: String?, multiLineEnd: String?) {
        // Single-line comments
        if let single = singleLine {
            let pattern = "\(NSRegularExpression.escapedPattern(for: single)).*$"
            highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text, options: .anchorsMatchLines)
        }
        
        // Multi-line comments
        if let start = multiLineStart, let end = multiLineEnd {
            let pattern = "\(NSRegularExpression.escapedPattern(for: start))[\\s\\S]*?\(NSRegularExpression.escapedPattern(for: end))"
            highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
        }
    }
    
    private func highlightHTMLComments(_ attributed: NSMutableAttributedString, text: String) {
        let pattern = "<!--[\\s\\S]*?-->"
        highlightPattern(attributed, pattern: pattern, color: UIColor(theme.comment), text: text)
    }
    
    private func highlightNumbers(_ attributed: NSMutableAttributedString, text: String) {
        // Hex numbers
        let hexPattern = "\\b0[xX][0-9a-fA-F]+\\b"
        highlightPattern(attributed, pattern: hexPattern, color: UIColor(theme.number), text: text)
        
        // Binary numbers
        let binPattern = "\\b0[bB][01]+\\b"
        highlightPattern(attributed, pattern: binPattern, color: UIColor(theme.number), text: text)
        
        // Octal numbers
        let octPattern = "\\b0[oO][0-7]+\\b"
        highlightPattern(attributed, pattern: octPattern, color: UIColor(theme.number), text: text)
        
        // Decimal numbers (including floats and scientific notation)
        let decPattern = "\\b\\d+\\.?\\d*([eE][+-]?\\d+)?\\b"
        highlightPattern(attributed, pattern: decPattern, color: UIColor(theme.number), text: text)
    }
}