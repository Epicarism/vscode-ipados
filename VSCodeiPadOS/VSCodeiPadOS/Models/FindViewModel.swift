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
final class FindViewModel: ObservableObject {
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

    // Search scope
    @Published var searchScope: SearchScope = .currentFile

    enum SearchScope: String, CaseIterable {
        case currentFile = "Current File"
        case openFiles = "Open Files"
        case workspace = "Workspace"
    }

    /// Bound externally by EditorCore
    weak var editorCore: EditorCore?

    private var searchWorkItem: DispatchWorkItem?

    // MARK: - Public API

    /// Performs search with current query
    func performSearch() {
        // Cancel any pending search
        searchWorkItem?.cancel()

        guard !searchQuery.isEmpty else {
            searchResults = []
            currentResultIndex = 0
            isSearching = false
            return
        }

        isSearching = true

        // Debounce search
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            let results = self.executeSearch()
            DispatchQueue.main.async {
                self.searchResults = results
                self.currentResultIndex = min(self.currentResultIndex, max(0, results.count - 1))
                self.isSearching = false
            }
        }

        searchWorkItem = workItem
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.15, execute: workItem)
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

        guard let tabIndex = core.activeTabIndex else { return }
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
    func replaceAll() {
        guard isReplaceMode,
              let core = editorCore,
              let regex = buildRegex()
        else { return }

        switch searchScope {
        case .currentFile:
            guard let idx = core.activeTabIndex else { return }
            let content = core.tabs[idx].content
            let replaced = regex.stringByReplacingMatches(
                in: content,
                range: NSRange(location: 0, length: (content as NSString).length),
                withTemplate: replaceQuery
            )
            core.updateActiveTabContent(replaced)

        case .openFiles:
            for i in core.tabs.indices {
                let content = core.tabs[i].content
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
            // Best-effort: replace in open tabs + on-disk workspace files.
            var urls: [URL] = []
            if let tree = core.fileNavigator?.fileTree {
                urls = collectFileURLs(from: tree)
            }

            for url in urls {
                // If open, update tab.
                if let tabIndex = core.tabs.firstIndex(where: { $0.url == url }) {
                    let content = core.tabs[tabIndex].content
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
                if let content = try? String(contentsOf: url, encoding: .utf8) {
                    let replaced = regex.stringByReplacingMatches(
                        in: content,
                        range: NSRange(location: 0, length: (content as NSString).length),
                        withTemplate: replaceQuery
                    )
                    if replaced != content {
                        try? replaced.write(to: url, atomically: true, encoding: .utf8)
                    }
                }
            }
        }

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

                results.append(
                    SearchResult(
                        filePath: target.filePath,
                        fileName: target.fileName,
                        url: target.url,
                        lineNumber: lineNumber,
                        lineContent: lineContent,
                        matchRange: swiftRange,
                        matchNSRange: r,
                        contextBefore: nil,
                        contextAfter: nil
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

        let finalPattern = isWholeWord ? "\\b\(pattern)\\b" : pattern
        let options: NSRegularExpression.Options = isCaseSensitive ? [] : [.caseInsensitive]

        return try? NSRegularExpression(pattern: finalPattern, options: options)
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
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($searchFieldFocused)
                    .onSubmit {
                        viewModel.performSearch()
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
                Button(action: viewModel.clearSearch) {
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
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Replace buttons
                    Button("Replace", action: viewModel.replaceCurrent)
                        .disabled(viewModel.searchResults.isEmpty)
                    
                    Button("Replace All", action: viewModel.replaceAll)
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
        .onChange(of: viewModel.searchQuery) { _ in
            viewModel.performSearch()
        }
        .onChange(of: viewModel.isCaseSensitive) { _ in
            viewModel.performSearch()
        }
        .onChange(of: viewModel.isWholeWord) { _ in
            viewModel.performSearch()
        }
        .onChange(of: viewModel.useRegex) { _ in
            viewModel.performSearch()
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
