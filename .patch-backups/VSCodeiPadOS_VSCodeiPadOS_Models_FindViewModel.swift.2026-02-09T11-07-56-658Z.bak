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
    let filePath: String
    let fileName: String
    let lineNumber: Int
    let lineContent: String
    let matchRange: Range<String.Index>
    let contextBefore: String?
    let contextAfter: String?
}

/// View model for Find/Replace functionality
class FindViewModel: ObservableObject {
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
    
    private var searchWorkItem: DispatchWorkItem?
    
    /// Performs search with current query
    func performSearch() {
        // Cancel any pending search
        searchWorkItem?.cancel()
        
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        // Debounce search
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.searchResults = self.executeSearch()
                self.isSearching = false
            }
        }
        
        searchWorkItem = workItem
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    /// Executes the actual search
    private func executeSearch() -> [SearchResult] {
        // This would integrate with the actual file system and editor
        // For now, return mock results
        return []
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
    
    /// Jumps to a specific result
    func jumpToResult(at index: Int) {
        guard index < searchResults.count else { return }
        let result = searchResults[index]
        // This would integrate with the editor to jump to the file/line
        print("Jump to \(result.fileName):\(result.lineNumber)")
    }
    
    /// Replaces current occurrence
    func replaceCurrent() {
        guard isReplaceMode,
              currentResultIndex < searchResults.count else { return }
        
        // This would integrate with the editor to replace text
        let result = searchResults[currentResultIndex]
        print("Replace at \(result.fileName):\(result.lineNumber)")
        
        // Remove from results and move to next
        searchResults.remove(at: currentResultIndex)
        if currentResultIndex >= searchResults.count && !searchResults.isEmpty {
            currentResultIndex = searchResults.count - 1
        }
    }
    
    /// Replaces all occurrences
    func replaceAll() {
        guard isReplaceMode else { return }
        
        // This would integrate with the editor to replace all
        let count = searchResults.count
        searchResults.removeAll()
        currentResultIndex = 0
        
        print("Replaced \(count) occurrences")
    }
    
    /// Clears search
    func clearSearch() {
        searchQuery = ""
        replaceQuery = ""
        searchResults = []
        currentResultIndex = 0
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
