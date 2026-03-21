import SwiftUI

struct BreadcrumbsView: View {
    @ObservedObject var editorCore: EditorCore
    let tab: Tab

    /// Parsed outline items for the current file (re-parsed on content change).
    @State private var outlineItems: [OutlineItem] = []
    @State private var parseWorkItem: DispatchWorkItem?

    /// Build the full chain of symbols the cursor is inside.
    /// Walks the outline tree to find the deepest symbol that contains the cursor line.
    private var symbolHierarchy: [OutlineItem] {
        let cursorLine = editorCore.cursorPosition.line + 1 // 1-indexed
        guard !outlineItems.isEmpty else { return [] }

        var chain: [OutlineItem] = []

        func walk(_ items: [OutlineItem]) {
            for item in items {
                if item.line <= cursorLine {
                    // Check if any child also contains the cursor (deeper scope)
                    let containingChildren = item.children.filter { $0.line <= cursorLine }
                    if !containingChildren.isEmpty {
                        chain.append(item)
                        // Recurse into children that contain cursor — pick the deepest
                        walk(containingChildren)
                        return
                    }
                    // No children contain cursor; this is the leaf scope
                    chain.append(item)
                }
            }
        }

        walk(outlineItems)
        return chain
    }

    var pathComponents: [String] {
        if let url = tab.url {
            return url.pathComponents.filter { $0 != "/" }
        }
        let folderName = tab.url?.deletingLastPathComponent().lastPathComponent ?? "Workspace"
        return [folderName, tab.fileName]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                // ── File path segments ──
                ForEach(Array(pathComponents.enumerated()), id: \.offset) { index, component in
                    let isLast = index == pathComponents.count - 1

                    HStack(spacing: 4) {
                        if index == 0 {
                            Image(systemName: "folder")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else if isLast {
                            Image(systemName: fileIcon(for: component))
                                .font(.caption2)
                                .foregroundColor(fileColor(for: component))
                        }

                        Text(component)
                            .font(.system(size: 11))
                            .foregroundColor(isLast ? .primary : .secondary)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Navigate to \(component)")
                    .accessibilityHint("Navigate to folder/file name")
                    .onTapGesture {
                        if isLast { return }
                        let dirPath = "/" + pathComponents[...index].joined(separator: "/")
                        NotificationCenter.default.post(
                            name: Notification.Name("navigateToDirectory"),
                            object: nil,
                            userInfo: ["path": dirPath]
                        )
                    }

                    if !isLast {
                        chevronSeparator
                    }
                }

                // ── Symbol hierarchy segments ──
                let hierarchy = symbolHierarchy
                if !hierarchy.isEmpty {
                    chevronSeparator

                    ForEach(Array(hierarchy.enumerated()), id: \.element.id) { index, symbol in
                        let isCurrentSymbol = index == hierarchy.count - 1

                        HStack(spacing: 3) {
                            Image(systemName: symbol.type.icon)
                                .font(.system(size: 9))
                                .foregroundColor(symbol.type.color)
                            Text(symbol.name)
                                .font(.system(size: 11, weight: isCurrentSymbol ? .bold : .regular))
                                .foregroundColor(isCurrentSymbol ? .primary : .secondary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 4)
                        .contentShape(Rectangle())
                        .accessibilityLabel("\(symbol.type.rawValue) \(symbol.name)")
                        .accessibilityHint("Jump to line \(symbol.line)")
                        .onTapGesture {
                            editorCore.requestedGoToLine = symbol.line
                        }

                        if !isCurrentSymbol {
                            chevronSeparator
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 26)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
        .overlay(Divider(), alignment: .bottom)
        .onAppear { scheduleParse() }
        .onChange(of: tab.content) { _, _ in scheduleParse() }
        .onChange(of: editorCore.cursorPosition.line) { _, _ in
            // Force re-render for symbol hierarchy update (derived from cursor position)
        }
    }

    // MARK: - Helpers

    private var chevronSeparator: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 8))
            .foregroundColor(.secondary.opacity(0.5))
            .padding(.horizontal, 2)
    }

    // MARK: - Outline Parsing (reuse OutlineParser from OutlineView)

    private func scheduleParse() {
        parseWorkItem?.cancel()

        let content = tab.content
        let language = tab.language

        let work = DispatchWorkItem {
            let items = OutlineParser.parseOutlineItems(from: content, language: language)
            DispatchQueue.main.async {
                self.outlineItems = items
            }
        }

        parseWorkItem = work
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.3, execute: work)
    }
}
