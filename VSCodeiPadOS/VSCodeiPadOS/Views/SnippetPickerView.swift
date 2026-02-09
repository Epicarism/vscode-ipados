import SwiftUI

struct SnippetPickerView: View {
    @ObservedObject var editorCore: EditorCore
    @ObservedObject private var snippetsManager = SnippetsManager.shared

    @State private var searchText = ""
    @State private var selectedIndex = 0
    @FocusState private var isSearchFocused: Bool

    private var language: CodeLanguage? {
        editorCore.activeTab?.language
    }

    private var allSnippets: [Snippet] {
        snippetsManager.allSnippets(language: language)
    }

    private var filteredSnippets: [Snippet] {
        guard !searchText.isEmpty else { return allSnippets }

        return allSnippets
            .compactMap { snip -> (Snippet, Int)? in
                let haystack = "\(snip.name) \(snip.prefix) \(snip.description)"
                guard let score = FuzzyMatcher.score(query: searchText, target: haystack) else {
                    return nil
                }
                return (snip, score)
            }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }

    private func dismiss() {
        editorCore.showSnippetPicker = false
    }

    private func insert(_ snippet: Snippet) {
        editorCore.pendingSnippetInsertion = snippet
        dismiss()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Header
            HStack(spacing: 12) {
                Image(systemName: "text.badge.plus")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                TextField("", text: $searchText, prompt: Text("Search snippets...").foregroundColor(.secondary))
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .onSubmit {
                        if let snippet = filteredSnippets[safe: selectedIndex] {
                            insert(snippet)
                        }
                    }

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))

            Divider()

            // Snippets list
            if filteredSnippets.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No matching snippets")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 200)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(filteredSnippets.enumerated()), id: \.element.id) { index, snippet in
                                SnippetRowView(
                                    snippet: snippet,
                                    searchQuery: searchText,
                                    isSelected: index == selectedIndex
                                )
                                .id(index)
                                .onTapGesture {
                                    insert(snippet)
                                }
                            }
                        }
                    }
                    .onChange(of: selectedIndex) { newIndex in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                .frame(maxHeight: 350)
            }

            // Footer
            HStack(spacing: 16) {
                FooterHint(keys: ["↑", "↓"], description: "navigate")
                FooterHint(keys: ["↵"], description: "insert")
                FooterHint(keys: ["esc"], description: "close")
                Spacer()
                Text("\(filteredSnippets.count) snippets")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(UIColor.tertiarySystemBackground))
        }
        .frame(width: 600)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
        .onAppear {
            isSearchFocused = true
            selectedIndex = 0
        }
        .onChange(of: searchText) { _ in
            selectedIndex = 0
        }
        .modifier(KeyPressModifier(
            onUp: {
                if selectedIndex > 0 { selectedIndex -= 1 }
            },
            onDown: {
                if selectedIndex < filteredSnippets.count - 1 { selectedIndex += 1 }
            },
            onEscape: { dismiss() }
        ))
    }
}

// iOS 17+ key press support
private struct KeyPressModifier: ViewModifier {
    let onUp: () -> Void
    let onDown: () -> Void
    let onEscape: () -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onKeyPress(.upArrow) { onUp(); return .handled }
                .onKeyPress(.downArrow) { onDown(); return .handled }
                .onKeyPress(.escape) { onEscape(); return .handled }
        } else {
            content
        }
    }
}

private struct SnippetRowView: View {
    let snippet: Snippet
    let searchQuery: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "curlybraces")
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .white : .accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                highlightedTitle

                HStack(spacing: 8) {
                    Text(snippet.prefix)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isSelected ? Color.white.opacity(0.2) : Color(UIColor.tertiarySystemFill))
                        )

                    if !snippet.description.isEmpty {
                        Text(snippet.description)
                            .font(.system(size: 11))
                            .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor : Color.clear)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 1)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var highlightedTitle: some View {
        if searchQuery.isEmpty {
            Text(snippet.name)
                .font(.system(size: 13))
                .foregroundColor(isSelected ? .white : .primary)
        } else {
            let parts = FuzzyMatcher.highlight(query: searchQuery, in: snippet.name)
            HStack(spacing: 0) {
                ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                    Text(part.0)
                        .font(.system(size: 13, weight: part.1 ? .bold : .regular))
                        .foregroundColor(isSelected ? .white : (part.1 ? .accentColor : .primary))
                }
            }
        }
    }
}

// MARK: - Safe Array Access

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
