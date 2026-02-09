import SwiftUI

// MARK: - Fold Region Model
struct FoldRegion: Identifiable {
    let id = UUID()
    let startLine: Int
    let endLine: Int
    var isFolded: Bool = false
    let type: FoldType
    
    enum FoldType {
        case function
        case classOrStruct
        case comment
        case block
    }
}

// MARK: - Code Folding Manager
class CodeFoldingManager: ObservableObject {
    @Published var foldRegions: [FoldRegion] = []
    @Published var collapsedLines: Set<Int> = []
    
    func detectFoldableRegions(in code: String) {
        let lines = code.components(separatedBy: .newlines)
        var regions: [FoldRegion] = []
        var blockStack: [(type: FoldRegion.FoldType, startLine: Int)] = []
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Detect function/method start
            if trimmed.contains("func ") && trimmed.contains("{") {
                blockStack.append((.function, index))
            }
            // Detect class/struct start
            else if (trimmed.starts(with: "class ") || trimmed.starts(with: "struct ")) && trimmed.contains("{") {
                blockStack.append((.classOrStruct, index))
            }
            // Detect generic block start
            else if trimmed.hasSuffix("{") {
                blockStack.append((.block, index))
            }
            // Detect block end
            else if trimmed == "}" || trimmed.starts(with: "}") {
                if let lastBlock = blockStack.popLast() {
                    if index - lastBlock.startLine > 1 { // Only create fold for multi-line blocks
                        regions.append(FoldRegion(
                            startLine: lastBlock.startLine,
                            endLine: index,
                            type: lastBlock.type
                        ))
                    }
                }
            }
        }
        
        self.foldRegions = regions
    }
    
    func toggleFold(at line: Int) {
        if let regionIndex = foldRegions.firstIndex(where: { $0.startLine == line }) {
            foldRegions[regionIndex].isFolded.toggle()
            updateCollapsedLines()
        }
    }
    
    func isFoldable(line: Int) -> Bool {
        return foldRegions.contains { $0.startLine == line }
    }
    
    func isLineFolded(line: Int) -> Bool {
        return collapsedLines.contains(line)
    }
    
    private func updateCollapsedLines() {
        collapsedLines.removeAll()
        
        for region in foldRegions where region.isFolded {
            for line in (region.startLine + 1)...region.endLine {
                collapsedLines.insert(line)
            }
        }
    }
    
    func getFoldedText(for region: FoldRegion) -> String {
        return "{ ... }"
    }
}

// MARK: - Fold Button View
struct FoldButton: View {
    let line: Int
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .frame(width: 16, height: 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Line Number View with Folding
struct LineNumberViewWithFolding: View {
    let lineNumber: Int
    let isFoldable: Bool
    let isExpanded: Bool
    let onFoldTap: () -> Void
    
    var body: some View {
        HStack(spacing: 2) {
            if isFoldable {
                FoldButton(line: lineNumber, isExpanded: isExpanded, action: onFoldTap)
            } else {
                Color.clear
                    .frame(width: 16, height: 16)
            }
            
            Text("\(lineNumber + 1)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
                .frame(minWidth: 30, alignment: .trailing)
        }
    }
}
