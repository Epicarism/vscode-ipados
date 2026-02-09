//  QuickOpen.swift
//  VSCodeiPadOS
//
//  VS Code-style Quick Open (Cmd+P) for file navigation
//

import SwiftUI
import Foundation

// MARK: - Quick Open View

struct QuickOpenView: View {
    @ObservedObject var editorCore: EditorCore
    @ObservedObject var fileNavigator: FileSystemNavigator

    @State private var searchText = ""
    @State private var selectedIndex = 0
    @FocusState private var isSearchFocused: Bool
    @State private var recentFiles: [QuickOpenItem] = []

    // Deterministic items for XCUITests (driven by launch argument: "-uiTesting")
    @State private var uiTestItems: [QuickOpenItem] = QuickOpenView.makeUITestItemsIfNeeded()

    private static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTesting")
    }

    private static func makeUITestItemsIfNeeded() -> [QuickOpenItem] {
        guard isUITesting else { return [] }
        return makeUITestItems()
    }

    private static func makeUITestItems() -> [QuickOpenItem] {
        // Create a small, stable set of files that are safe to open.
        let fm = FileManager.default
        let baseDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("VSCodeiPadOS-UITests", isDirectory: true)

        try? fm.createDirectory(at: baseDir, withIntermediateDirectories: true)

        func ensureFile(_ name: String, contents: String) -> URL {
            let url = baseDir.appendingPathComponent(name)
            if !fm.fileExists(atPath: url.path) {
                try? contents.write(to: url, atomically: true, encoding: .utf8)
            }
            return url
        }

        let fileA = ensureFile("UITest-A.txt", contents: "A")
        let fileB = ensureFile("UITest-B.txt", contents: "B")

        return [
            QuickOpenItem(name: "UITest-A.txt", path: "", url: fileA, isOpen: false, language: CodeLanguage(from: "txt")),
            QuickOpenItem(name: "UITest-B.txt", path: "", url: fileB, isOpen: false, language: CodeLanguage(from: "txt"))
        ]
    }

    private var allFiles: [QuickOpenItem] {
        if Self.isUITesting {
            return uiTestItems
        }

        var items: [QuickOpenItem] = []

        // Add open tabs as recent files
        for tab in editorCore.tabs {
            items.append(QuickOpenItem(
                name: tab.fileName,
                path: tab.url?.deletingLastPathComponent().path ?? "",
                url: tab.url,
                isOpen: true,
                language: tab.language
            ))
        }

        // Add files from file navigator
        if let tree = fileNavigator.fileTree {
            collectFiles(from: tree, items: &items, basePath: "")
        }

        return items
    }

    private func collectFiles(from node: FileTreeNode, items: inout [QuickOpenItem], basePath: String) {
        let currentPath = basePath.isEmpty ? node.name : "\(basePath)/\(node.name)"

        if !node.isDirectory {
            // Skip if already in tabs
            if !editorCore.tabs.contains(where: { $0.url == node.url }) {
                items.append(QuickOpenItem(
                    name: node.name,
                    path: basePath,
                    url: node.url,
                    isOpen: false,
                    language: CodeLanguage(from: node.fileExtension)
                ))
            }
        }

        for child in node.children {
            collectFiles(from: child, items: &items, basePath: currentPath)
        }
    }

    private var filteredFiles: [QuickOpenItem] {
        if searchText.isEmpty {
            // Show open files first, then recent
            return allFiles.sorted { a, b in
                if a.isOpen && !b.isOpen { return true }
                if !a.isOpen && b.isOpen { return false }
                return a.name < b.name
            }
        }

        return allFiles
            .compactMap { item -> (QuickOpenItem, Int)? in
                // Score against filename and path
                let nameScore = FuzzyMatcher.score(query: searchText, target: item.name) ?? 0
                let pathScore = (FuzzyMatcher.score(query: searchText, target: item.fullPath) ?? 0) / 2
                let totalScore = max(nameScore, pathScore)

                guard totalScore > 0 else { return nil }
                return (item, totalScore)
            }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }

    private func dismiss() {
        editorCore.showQuickOpen = false
    }

    private func openFile(_ item: QuickOpenItem) {
        if let url = item.url {
            editorCore.openFile(from: url)
        } else {
            // For tabs without URL
            if let tab = editorCore.tabs.first(where: { $0.fileName == item.name }) {
                editorCore.selectTab(id: tab.id)
            }
        }
        dismiss()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Header
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                TextField("", text: $searchText, prompt: Text("Search files by name").foregroundColor(.secondary))
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .accessibilityIdentifier("QuickOpen.SearchField")
                    .onSubmit {
                        if let file = selectedIndex < filteredFiles.count ? filteredFiles[selectedIndex] : nil {
                            openFile(file)
                        }
                    }
                    .modifier(QuickOpenKeyboardModifier(
                        selectedIndex: $selectedIndex,
                        maxIndex: filteredFiles.count - 1,
                        onEscape: { dismiss() }
                    ))

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("QuickOpen.Clear")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))

            Divider()

            // Files List
            if filteredFiles.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No matching files")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 200)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Section header for open files
                            if searchText.isEmpty && filteredFiles.contains(where: { $0.isOpen }) {
                                HStack {
                                    Text("open editors")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color(UIColor.tertiarySystemBackground))
                            }

                            ForEach(Array(filteredFiles.enumerated()), id: \.element.id) { index, file in
                                QuickOpenRowView(
                                    item: file,
                                    searchQuery: searchText,
                                    isSelected: index == selectedIndex
                                )
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(file.name)
                                .accessibilityValue(index == selectedIndex ? "selected" : "unselected")
                                .accessibilityIdentifier("QuickOpen.Row.\(file.name)")
                                .id(index)
                                .onTapGesture {
                                    openFile(file)
                                }

                                // Section divider between open and other files
                                if searchText.isEmpty {
                                    let openFiles = filteredFiles.filter { $0.isOpen }
                                    if index == openFiles.count - 1 && openFiles.count < filteredFiles.count {
                                        HStack {
                                            Text("workspace files")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .textCase(.uppercase)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .background(Color(UIColor.tertiarySystemBackground))
                                    }
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

            // Footer with hints
            HStack(spacing: 16) {
                FooterHint(keys: ["↑", "↓"], description: "navigate")
                FooterHint(keys: ["↵"], description: "open")
                FooterHint(keys: ["esc"], description: "close")
                Spacer()
                Text("\(filteredFiles.count) files")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(UIColor.tertiarySystemBackground))
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("QuickOpen.Root")
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
    }
}

// MARK: - Quick Open Item

struct QuickOpenItem: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let url: URL?
    let isOpen: Bool
    let language: CodeLanguage

    var fullPath: String {
        path.isEmpty ? name : "\(path)/\(name)"
    }

    var fileExtension: String {
        (name as NSString).pathExtension.lowercased()
    }
}

// MARK: - Quick Open Row View

struct QuickOpenRowView: View {
    let item: QuickOpenItem
    let searchQuery: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            // File icon
            Image(systemName: item.language.iconName)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? .white : item.language.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                // File name with highlighting
                highlightedName

                // Path
                if !item.path.isEmpty {
                    Text(item.path)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Open indicator
            if item.isOpen {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundColor(isSelected ? .white : .accentColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor : Color.clear)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 1)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var highlightedName: some View {
        if searchQuery.isEmpty {
            Text(item.name)
                .font(.system(size: 13))
                .foregroundColor(isSelected ? .white : .primary)
        } else {
            let parts = FuzzyMatcher.highlight(query: searchQuery, in: item.name)
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

// MARK: - Keyboard Navigation Modifier

private struct QuickOpenKeyboardModifier: ViewModifier {
    @Binding var selectedIndex: Int
    let maxIndex: Int
    let onEscape: () -> Void

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onKeyPress(.upArrow) {
                    if selectedIndex > 0 { selectedIndex -= 1 }
                    return .handled
                }
                .onKeyPress(.downArrow) {
                    if selectedIndex < maxIndex { selectedIndex += 1 }
                    return .handled
                }
                .onKeyPress(.escape) {
                    onEscape()
                    return .handled
                }
        } else {
            content
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.opacity(0.5)
        QuickOpenView(
            editorCore: EditorCore(),
            fileNavigator: FileSystemNavigator()
        )
    }
}
