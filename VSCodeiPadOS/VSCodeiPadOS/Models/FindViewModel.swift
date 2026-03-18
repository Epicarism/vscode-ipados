//
//  FindViewModel.swift
//  VSCodeiPadOS
//
//  Created by Swarm Agent on 2/8/26.
//

import Foundation
import SwiftUI

/// Represents a single search result
struct SearchResult: Identifiable {
    let id = UUID()

    /// Full path for display + identity. For unsaved tabs, this may be the file name.
    let filePath: String

    /// Display name (usually lastPathComponent)
    let fileName: String

    /// Backing URL when available (workspace/opened files)
    let url: URL?

    /// 1-based line number
    let lineNumber: Int

    /// The full line content containing the match
    let lineContent: String

    /// Match range in String indices
    let matchRange: Range<String.Index>

    /// Match range in UTF16 space (UITextView / NSAttributedString compatible)
    let matchNSRange: NSRange

    let contextBefore: String?
    let contextAfter: String?
}

/// View model for Find/Replace functionality
@MainActor final class FindViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var replaceQuery: String = ""
    @Published var searchResults: [SearchResult] = []
    @Published var currentResultIndex: Int = 0
    @Published var isSearching: Bool = false
    @Published var isReplaceMode: Bool = false

    // Search options
    @Published var isCaseSensitive: Bool = false
    @Published var isWholeWord: Bool = false
    @Published var useRegex: Bool = false
    @Published var searchInSelection: Bool = false

    // Replace-all confirmation (workspace scope)
    @Published var showReplaceAllConfirmation = false
    @Published var pendingReplaceAllCount = 0
    @Published var pendingReplaceAllFileCount = 0

    /// Error message when regex pattern is invalid
    @Published var regexError: String?

    /// User-facing error feedback from replace-all operations
    @Published var replaceAllError: String?

    // Search scope
    @Published var searchScope: SearchScope = .currentFile

    enum SearchScope: String, CaseIterable {
        case currentFile = "Current File"
        case openFiles = "Open Files"
        case workspace = "Workspace"
    }

    /// Bound externally by EditorCore
    weak var editorCore: EditorCore?

    private var searchTask: Task<Void, Never>?

    // MARK: - Public API

    /// Performs search with current query
    func performSearch() {
        // Cancel any pending search
        searchTask?.cancel()

        guard !searchQuery.isEmpty else {
            searchResults = []
            currentResultIndex = 0
            isSearching = false
            return
        }

        isSearching = true

        // Debounce search using Task
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 150_000_000) // 0.15s
            guard !Task.isCancelled, let self else { return }
            let results = self.executeSearch()
            self.searchResults = results
            self.currentResultIndex = min(self.currentResultIndex, max(0, results.count - 1))
            self.isSearching = false
        }
    }

    /// Moves to next search result
    func nextResult() {
        guard !searchResults.isEmpty else { return }
        currentResultIndex = (currentResultIndex + 1) % searchResults.count
        jumpToResult(at: currentResultIndex)
    }

    /// Moves to previous search result
    func previousResult() {
        guard !searchResults.isEmpty else { return }
        if currentResultIndex > 0 {
            currentResultIndex -= 1
        } else {
            currentResultIndex = searchResults.count - 1
        }
        jumpToResult(at: currentResultIndex)
    }

    /// Jumps to a specific result (opens file if needed, selects match)
    func jumpToResult(at index: Int) {
        guard index >= 0, index < searchResults.count else { return }
        guard let core = editorCore else { return }

        let result = searchResults[index]

        // Ensure file is open/active.
        if let url = result.url {
            core.openFile(from: url)
        } else if let tab = core.tabs.first(where: { $0.fileName == result.fileName }) {
            core.selectTab(id: tab.id)
        }

        // Request selection reveal.
        core.requestedSelection = result.matchNSRange
    }

    /// Replaces current occurrence (active tab)
    func replaceCurrent() {
        guard isReplaceMode,
              currentResultIndex >= 0,
              currentResultIndex < searchResults.count,
              let core = editorCore,
              let regex = buildRegex()
        else { return }

        let result = searchResults[currentResultIndex]

        // Only replace in open tabs / current file (workspace files can be opened first).
        if let url = result.url {
            core.openFile(from: url)
        }

        guard let tabIndex = core.activeTabIndex,
              tabIndex < core.tabs.count else { return }
        var content = core.tabs[tabIndex].content

        guard let match = regex.firstMatch(in: content, options: [], range: result.matchNSRange) else { return }
        let replacement: String
        if useRegex {
            replacement = regex.replacementString(for: match, in: content, offset: 0, template: replaceQuery)
        } else {
            replacement = replaceQuery
        }

        let mutable = NSMutableString(string: content)
        mutable.replaceCharacters(in: match.range, with: replacement)
        content = mutable as String

        core.updateActiveTabContent(content)

        // Refresh results and keep selection moving.
        performSearch()
        if currentResultIndex < searchResults.count {
            jumpToResult(at: currentResultIndex)
        }
    }

    /// Replaces all occurrences in the chosen scope.
    /// For workspace scope, shows confirmation first.
    func replaceAll() {
        guard isReplaceMode, let _ = editorCore, let _ = buildRegex()
        else { return }

        guard searchScope == .workspace else {
            executeReplaceAll()
            return
        }
        prepareReplaceAll()
    }

    /// Tallies workspace matches, sets pending counts, and presents the confirmation.
    private func prepareReplaceAll() {
        guard let core = editorCore, let regex = buildRegex() else { return }

        var urls: [URL] = []
        if let tree = core.fileNavigator?.fileTree {
            urls = collectFileURLs(from: tree)
        }

        var totalMatches = 0
        var affectedFiles = 0
        for url in urls {
            let content: String
            if let tabIndex = core.tabs.firstIndex(where: { $0.url == url }),
               let openTab = core.tabs[safe: tabIndex] {
                content = openTab.content
            } else if let diskContent = try? String(contentsOf: url, encoding: .utf8) {
                content = diskContent
            } else {
                continue
            }
            let count = regex.numberOfMatches(
                in: content,
                options: [],
                range: NSRange(location: 0, length: (content as NSString).length)
            )
            if count > 0 {
                totalMatches += count
                affectedFiles += 1
            }
        }

        pendingReplaceAllCount = totalMatches
        pendingReplaceAllFileCount = affectedFiles
        showReplaceAllConfirmation = true
    }

    /// Actually performs the replacement (called after user confirms or for non-workspace scopes).
    func executeReplaceAll() {
        guard isReplaceMode,
              let core = editorCore,
              let regex = buildRegex()
        else { return }

        replaceAllError = nil

        switch searchScope {
        case .currentFile:
            guard let idx = core.activeTabIndex,
                  idx < core.tabs.count else { return }
            let content = core.tabs[idx].content
            let replaced = regex.stringByReplacingMatches(
                in: content,
                range: NSRange(location: 0, length: (content as NSString).length),
                withTemplate: replaceQuery
            )
            core.updateActiveTabContent(replaced)

        case .openFiles:
            for i in core.tabs.indices {
                guard i < core.tabs.count,
                      let tab = core.tabs[safe: i] else { continue }
                let content = tab.content
                let replaced = regex.stringByReplacingMatches(
                    in: content,
                    range: NSRange(location: 0, length: (content as NSString).length),
                    withTemplate: replaceQuery
                )
                if replaced != content {
                    core.tabs[i].content = replaced
                    if core.tabs[i].url != nil { core.tabs[i].isUnsaved = true }
                }
            }

        case .workspace:
            // Replace in open tabs + on-disk workspace files; track failures.
            var urls: [URL] = []
            if let tree = core.fileNavigator?.fileTree {
                urls = collectFileURLs(from: tree)
            }

            var failedFiles: [String] = []

            for url in urls {
                // If open, update tab.
                if let tabIndex = core.tabs.firstIndex(where: { $0.url == url }),
                   tabIndex < core.tabs.count,
                   let existingTab = core.tabs[safe: tabIndex] {
                    let content = existingTab.content
                    let replaced = regex.stringByReplacingMatches(
                        in: content,
                        range: NSRange(location: 0, length: (content as NSString).length),
                        withTemplate: replaceQuery
                    )
                    if replaced != content {
                        core.tabs[tabIndex].content = replaced
                        core.tabs[tabIndex].isUnsaved = true
                    }
                    continue
                }

                // Otherwise, attempt to update on disk.
                guard let content = (try? String(contentsOf: url, encoding: .utf8)) else {
                    failedFiles.append(url.lastPathComponent)
                    continue
                }
                let replaced = regex.stringByReplacingMatches(
                    in: content,
                    range: NSRange(location: 0, length: (content as NSString).length),
                    withTemplate: replaceQuery
                )
                if replaced != content {
                    do {
                        try replaced.write(to: url, atomically: true, encoding: .utf8)
                    } catch {
                        failedFiles.append(url.lastPathComponent)
                        AppLogger.general.error("Failed to write replacement to \(url.lastPathComponent): \(error.localizedDescription)")
                    }
                }
            }

            if !failedFiles.isEmpty {
                replaceAllError = "Failed to replace in \(failedFiles.count) file\(failedFiles.count == 1 ? "" : "s"): \(failedFiles.joined(separator: ", "))"
            }
        }

        showReplaceAllConfirmation = false
        performSearch()
    }

    /// Clears search
    func clearSearch() {
        searchQuery = ""
        replaceQuery = ""
        searchResults = []
        currentResultIndex = 0
        isSearching = false
    }

    // MARK: - Core search implementation

    private func executeSearch() -> [SearchResult] {
        guard let core = editorCore else { return [] }
        guard let regex = buildRegex() else { return [] }

        struct Target {
            let url: URL?
            let filePath: String
            let fileName: String
            let content: String
        }

        let targets: [Target] = {
            switch searchScope {
            case .currentFile:
                guard let tab = core.activeTab else { return [] }
                let path = tab.url?.path ?? tab.fileName
                return [Target(url: tab.url, filePath: path, fileName: tab.fileName, content: tab.content)]

            case .openFiles:
                return core.tabs.map { tab in
                    let path = tab.url?.path ?? tab.fileName
                    return Target(url: tab.url, filePath: path, fileName: tab.fileName, content: tab.content)
                }

            case .workspace:
                guard let tree = core.fileNavigator?.fileTree else { return [] }
                let urls = collectFileURLs(from: tree)
                return urls.compactMap { url in
                    guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }
                    return Target(url: url, filePath: url.path, fileName: url.lastPathComponent, content: content)
                }
            }
        }()

        var results: [SearchResult] = []
        results.reserveCapacity(64)

        for target in targets {
            let text = target.content
            let nsText = text as NSString

            let searchRange: NSRange
            if searchInSelection,
               searchScope == .currentFile,
               let selection = core.currentSelectionRange {
                searchRange = selection
            } else {
                searchRange = NSRange(location: 0, length: nsText.length)
            }

            let matches = regex.matches(in: text, options: [], range: searchRange)
            for match in matches {
                let r = match.range
                guard let swiftRange = Range(r, in: text) else { continue }

                // 1-based line number
                let prefix = nsText.substring(to: min(r.location, nsText.length))
                let lineNumber = prefix.components(separatedBy: "\n").count

                // Full line content
                let lineRange = nsText.lineRange(for: r)
                var lineContent = nsText.substring(with: lineRange)
                lineContent = lineContent.trimmingCharacters(in: .newlines)
                // --- Surrounding-line context extraction ---
                // contextBefore: up to 2 lines immediately before the match line
                var contextBefore: String? = nil
                if lineRange.location > 0 {
                    let beforeEnd = lineRange.location
                    let beforeStart = max(0, beforeEnd - 500)
                    let beforeRange = NSRange(location: beforeStart, length: beforeEnd - beforeStart)
                    let beforeText = nsText.substring(with: beforeRange)
                    let lines = beforeText.components(separatedBy: "\n")
                    let tail = lines.suffix(3)
                    let contextLines = tail.dropLast()
                    let trimmed = contextLines
                        .map { $0.trimmingCharacters(in: .newlines) }
                        .filter { !$0.isEmpty }
                        .suffix(2)
                    if !trimmed.isEmpty {
                        contextBefore = trimmed.joined(separator: "\n")
                    }
                }

                // contextAfter: up to 2 lines immediately after the match line
                var contextAfter: String? = nil
                let afterStart = NSMaxRange(lineRange)
                if afterStart < nsText.length {
                    let afterEnd = min(nsText.length, afterStart + 500)
                    let afterRange = NSRange(location: afterStart, length: afterEnd - afterStart)
                    let afterText = nsText.substring(with: afterRange)
                    let lines = afterText.components(separatedBy: "\n")
                    let trimmed = lines
                        .map { $0.trimmingCharacters(in: .newlines) }
                        .filter { !$0.isEmpty }
                        .prefix(2)
                    if !trimmed.isEmpty {
                        contextAfter = trimmed.joined(separator: "\n")
                    }
                }

                results.append(
                    SearchResult(
                        filePath: target.filePath,
                        fileName: target.fileName,
                        url: target.url,
                        lineNumber: lineNumber,
                        lineContent: lineContent,
                        matchRange: swiftRange,
                        matchNSRange: r,
                        contextBefore: contextBefore,
                        contextAfter: contextAfter
                    )
                )
            }
        }

        return results
    }

    private func buildRegex() -> NSRegularExpression? {
        guard !searchQuery.isEmpty else { return nil }

        let pattern: String
        if useRegex {
            pattern = searchQuery
        } else {
            pattern = NSRegularExpression.escapedPattern(for: searchQuery)
        }

        let finalPattern = (isWholeWord && !useRegex) ? "\\b\(pattern)\\b" : pattern
        let options: NSRegularExpression.Options = isCaseSensitive ? [] : [.caseInsensitive]

        do {
            let regex = try NSRegularExpression(pattern: finalPattern, options: options)
            regexError = nil
            return regex
        } catch {
            if useRegex {
                regexError = "Invalid regex: \(error.localizedDescription)"
            } else {
                regexError = nil
            }
            return nil
        }
    }

    private func collectFileURLs(from node: FileTreeNode) -> [URL] {
        if node.isDirectory {
            return node.children.flatMap { collectFileURLs(from: $0) }
        }
        return [node.url]
    }
}

// MARK: - Find/Replace UI Components

struct FindReplaceView: View {
    @ObservedObject var viewModel: FindViewModel
    var onDismiss: (() -> Void)? = nil
    @FocusState private var searchFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                // Toggle replace mode
                Button(action: {
                    viewModel.isReplaceMode.toggle()
                }) {
                    Image(systemName: viewModel.isReplaceMode ? "chevron.down" : "chevron.right")
                        .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Search field
                TextField("Find", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .focused($searchFieldFocused)
                    .onSubmit {
                        if viewModel.searchResults.isEmpty {
                            viewModel.performSearch()
                        } else {
                            viewModel.nextResult()
                        }
                    }
                
                // Regex error display
                if let error = viewModel.regexError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                // Result count
                if !viewModel.searchResults.isEmpty {
                    Text("\(viewModel.currentResultIndex + 1) of \(viewModel.searchResults.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Navigation buttons
                Button(action: viewModel.previousResult) {
                    Image(systemName: "chevron.up")
                }
                .disabled(viewModel.searchResults.isEmpty)
                
                Button(action: viewModel.nextResult) {
                    Image(systemName: "chevron.down")
                }
                .disabled(viewModel.searchResults.isEmpty)
                
                // Options menu
                Menu {
                    Toggle("Case Sensitive", isOn: $viewModel.isCaseSensitive)
                    Toggle("Whole Word", isOn: $viewModel.isWholeWord)
                    Toggle("Use Regex", isOn: $viewModel.useRegex)
                    Divider()
                    Picker("Search In", selection: $viewModel.searchScope) {
                        ForEach(FindViewModel.SearchScope.allCases, id: \.self) { scope in
                            Text(scope.rawValue).tag(scope)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                
                // Close button
                Button(action: {
                    viewModel.clearSearch()
                    onDismiss?()
                }) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(8)
            
            // Replace bar (when in replace mode)
            if viewModel.isReplaceMode {
                HStack {
                    // Spacer to align with search field
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 20)
                    
                    // Replace field
                    TextField("Replace", text: $viewModel.replaceQuery)
                        .textFieldStyle(.roundedBorder)
                    
                    // Replace buttons
                    Button("Replace", action: viewModel.replaceCurrent)
                        .disabled(viewModel.searchResults.isEmpty)
                    
                    Button(viewModel.searchScope == .workspace ? "Replace All\u{2026}" : "Replace All", action: viewModel.replaceAll)
                        .disabled(viewModel.searchResults.isEmpty)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear {
            searchFieldFocused = true
        }
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.performSearch()
        }
        .onChange(of: viewModel.isCaseSensitive) { _, _ in
            viewModel.performSearch()
        }
        .onChange(of: viewModel.isWholeWord) { _, _ in
            viewModel.performSearch()
        }
        .onChange(of: viewModel.useRegex) { _, _ in
            viewModel.performSearch()
        }
        .alert("Replace All?", isPresented: $viewModel.showReplaceAllConfirmation) {
            Button("Cancel", role: .cancel) {
                viewModel.showReplaceAllConfirmation = false
            }
            Button("Replace All", role: .destructive) {
                viewModel.executeReplaceAll()
            }
        } message: {
            Text("Replace \(viewModel.pendingReplaceAllCount) occurrence\(viewModel.pendingReplaceAllCount == 1 ? "" : "s") in \(viewModel.pendingReplaceAllFileCount) file\(viewModel.pendingReplaceAllFileCount == 1 ? "" : "s")?")
        }
    }
}

struct SearchResultsListView: View {
    @ObservedObject var viewModel: FindViewModel
    
    var body: some View {
        List(viewModel.searchResults) { result in
            VStack(alignment: .leading, spacing: 4) {
                // File path
                HStack {
                    Text(result.fileName)
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(":\(result.lineNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                // Line content with highlighted match
                Text(result.lineContent)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .onTapGesture {
                if let index = viewModel.searchResults.firstIndex(where: { $0.id == result.id }) {
                    viewModel.currentResultIndex = index
                    viewModel.jumpToResult(at: index)
                }
            }
        }
    }
}
