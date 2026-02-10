import UIKit

/// TextKit layout manager that collapses line fragments for lines marked folded in CodeFoldingManager.
///
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
        guard let owner = ownerTextView,
              let foldingManager = owner.foldingManager,
              let fileId = owner.fileId
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
