import SwiftUI
import SwiftUI
import Foundation

// MARK: - Models

enum DiffLineType {
    case context
    case addition
    case deletion
    case header
}

struct DiffLine: Identifiable {
    let id = UUID()
    let type: DiffLineType
    let content: String
    let oldLineNumber: Int?
    let newLineNumber: Int?
}

struct DiffHunk: Identifiable {
    let id = UUID()
    let header: String
    let lines: [DiffLine]
}

struct DiffFile: Identifiable {
    let id = UUID()
    let fileName: String
    let status: String
    let hunks: [DiffHunk]
}

enum DiffViewMode: Hashable {
    case inline
    case sideBySide
}

// MARK: - Diff Builder (working copy vs HEAD)

private enum _DiffEdit {
    case equal(String)
    case insert(String)
    case delete(String)
}

struct DiffBuilder {
    static func build(fileName: String, status: String, old: String, new: String) -> DiffFile {
        let oldLines = splitLines(old)
        let newLines = splitLines(new)
        let edits = diffEdits(oldLines, newLines)

        var lines: [DiffLine] = []
        lines.reserveCapacity(edits.count)

        var oldLineNumber = 1
        var newLineNumber = 1

        for edit in edits {
            switch edit {
            case let .equal(text):
                lines.append(.init(type: .context, content: text, oldLineNumber: oldLineNumber, newLineNumber: newLineNumber))
                oldLineNumber += 1
                newLineNumber += 1

            case let .delete(text):
                lines.append(.init(type: .deletion, content: text, oldLineNumber: oldLineNumber, newLineNumber: nil))
                oldLineNumber += 1

            case let .insert(text):
                lines.append(.init(type: .addition, content: text, oldLineNumber: nil, newLineNumber: newLineNumber))
                newLineNumber += 1
            }
        }

        let header = "@@ -1,\(oldLines.count) +1,\(newLines.count) @@"
        let hunk = DiffHunk(header: header, lines: lines)
        return DiffFile(fileName: fileName, status: status, hunks: [hunk])
    }

    private static func splitLines(_ text: String) -> [String] {
        var lines = text.components(separatedBy: "\n")
        // Drop trailing empty line if file ends with newline.
        if lines.last == "" {
            lines.removeLast()
        }
        return lines
    }

    private static func diffEdits(_ old: [String], _ new: [String]) -> [_DiffEdit] {
        let n = old.count
        let m = new.count

        if n == 0 { return new.map { .insert($0) } }
        if m == 0 { return old.map { .delete($0) } }

        // LCS DP (simple + deterministic). Replace with Myers later if needed.
        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 1...n {
            for j in 1...m {
                if old[i - 1] == new[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        var edits: [_DiffEdit] = []
        edits.reserveCapacity(n + m)

        var i = n
        var j = m
        while i > 0 || j > 0 {
            if i > 0, j > 0, old[i - 1] == new[j - 1] {
                edits.append(.equal(old[i - 1]))
                i -= 1
                j -= 1
            } else if j > 0, i == 0 || dp[i][j - 1] >= dp[i - 1][j] {
                edits.append(.insert(new[j - 1]))
                j -= 1
            } else if i > 0 {
                edits.append(.delete(old[i - 1]))
                i -= 1
            }
        }

        return edits.reversed()
    }
}

// MARK: - Diff Viewer (Inline / Side-by-side)

struct DiffViewer: View {
    let file: DiffFile
    @State private var mode: DiffViewMode = .inline

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            Picker("Mode", selection: $mode) {
                Text("Inline").tag(DiffViewMode.inline)
                Text("Side by Side").tag(DiffViewMode.sideBySide)
            }
            .pickerStyle(.segmented)
            .padding(12)

            Divider()

            ScrollView([.vertical, .horizontal]) {
                Group {
                    switch mode {
                    case .inline:
                        InlineDiffView(file: file)
                    case .sideBySide:
                        SideBySideDiffView(file: file)
                    }
                }
                .padding(12)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(file.fileName)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)

            Spacer()

            Text(file.status)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(6)
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
    }
}

// MARK: - Sheet wrapper for GitView

struct GitDiffSheet: View {
    let entry: GitStatusEntry

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var gitManager = GitManager.shared

    @State private var isLoading = true
    @State private var diffFile: DiffFile?

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading diff…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let diffFile {
                    DiffViewer(file: diffFile)
                } else {
                    Text("No diff available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            isLoading = true
            diffFile = await gitManager.diffWorkingCopyToHEAD(path: entry.path, kind: entry.kind)
            isLoading = false
        }
    }
}

// MARK: - Inline Diff View

struct InlineDiffView: View {
    let file: DiffFile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(file.hunks) { hunk in
                HunkHeaderView(text: hunk.header)
                
                ForEach(hunk.lines) { line in
                    InlineDiffLineView(line: line)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .border(Color.gray.opacity(0.2))
    }
}

struct InlineDiffLineView: View {
    let line: DiffLine
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Line Numbers
            HStack(spacing: 0) {
                Text(line.oldLineNumber.map(String.init) ?? "")
                    .frame(width: 30, alignment: .trailing)
                    .padding(.trailing, 4)
                Text(line.newLineNumber.map(String.init) ?? "")
                    .frame(width: 30, alignment: .trailing)
                    .padding(.trailing, 4)
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            .background(Color(UIColor.secondarySystemBackground))
            
            // Content
            Text(line.content)
                .font(.system(.caption, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                .padding(.vertical, 1)
        }
        .background(backgroundColor)
    }
    
    var backgroundColor: Color {
        switch line.type {
        case .addition: return Color.green.opacity(0.15)
        case .deletion: return Color.red.opacity(0.15)
        case .header: return Color.blue.opacity(0.1)
        case .context: return Color.clear
        }
    }
}

// MARK: - Side By Side Diff View

struct SideBySideDiffView: View {
    let file: DiffFile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(file.hunks) { hunk in
                HunkHeaderView(text: hunk.header)
                
                ForEach(hunk.lines) { line in
                    SideBySideDiffLineView(line: line)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .border(Color.gray.opacity(0.2))
    }
}

struct SideBySideDiffLineView: View {
    let line: DiffLine
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Column (Old)
            HStack(spacing: 0) {
                if line.type != .addition {
                    Text(line.oldLineNumber.map(String.init) ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .trailing)
                        .padding(.trailing, 4)
                        .background(Color(UIColor.secondarySystemBackground))
                    
                    Text(line.content)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .background(leftBackgroundColor)
            
            Divider()
            
            // Right Column (New)
            HStack(spacing: 0) {
                if line.type != .deletion {
                    Text(line.newLineNumber.map(String.init) ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .trailing)
                        .padding(.trailing, 4)
                        .background(Color(UIColor.secondarySystemBackground))
                    
                    Text(line.content)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .background(rightBackgroundColor)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var leftBackgroundColor: Color {
        if line.type == .deletion { return Color.red.opacity(0.15) }
        if line.type == .addition { return Color(UIColor.systemGray6) }
        return Color.clear
    }
    
    var rightBackgroundColor: Color {
        if line.type == .addition { return Color.green.opacity(0.15) }
        if line.type == .deletion { return Color(UIColor.systemGray6) }
        return Color.clear
    }
}

// MARK: - Shared Components

struct HunkHeaderView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.vertical, 4)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
    }
}

// MARK: - Previews

struct DiffComponents_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLines = [
            DiffLine(type: .context, content: "import SwiftUI", oldLineNumber: 1, newLineNumber: 1),
            DiffLine(type: .deletion, content: "struct OldView: View {", oldLineNumber: 2, newLineNumber: nil),
            DiffLine(type: .addition, content: "struct NewView: View {", oldLineNumber: nil, newLineNumber: 2),
            DiffLine(type: .context, content: "    var body: some View {", oldLineNumber: 3, newLineNumber: 3)
        ]
        let hunk = DiffHunk(header: "@@ -1,3 +1,3 @@", lines: sampleLines)
        let file = DiffFile(fileName: "ContentView.swift", status: "modified", hunks: [hunk])
        
        VStack(spacing: 20) {
            Text("Inline")
            InlineDiffView(file: file)
            
            Text("Side by Side")
            SideBySideDiffView(file: file)
        }
        .padding()
    }
}
