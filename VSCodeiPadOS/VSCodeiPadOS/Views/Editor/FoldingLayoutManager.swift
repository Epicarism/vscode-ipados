import UIKit

/// TextKit layout manager that collapses line fragments for lines marked folded in CodeFoldingManager.
/// This is a view-level folding implementation (it does NOT modify the underlying text).

final class FoldingLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
    weak var ownerTextView: EditorTextView?
    private var foldingObserver: NSObjectProtocol?
    /// PERF: Cached newline offsets for O(log n) line index lookup instead of O(n) scanning
    private var cachedLineStartOffsets: [Int] = [0]
    private var cachedTextLength: Int = -1

    override init() {
        super.init()
        self.delegate = self
        setupFoldingObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        setupFoldingObserver()
    }

    deinit {
        if let observer = foldingObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupFoldingObserver() {
        foldingObserver = NotificationCenter.default.addObserver(
            forName: .codeFoldingDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.invalidateFoldingLayout()
        }
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
        // Rebuild line offset cache if text changed
        if full.length != cachedTextLength {
            rebuildLineOffsets(for: full)
        }
        let lineIndex = binarySearchLineIndex(for: loc)

        // Check both the legacy isLineFolded and new isLineHidden
        if foldingManager.isLineFolded(fileId: fileId, line: lineIndex) ||
           foldingManager.isLineHidden(fileId: fileId, line: lineIndex) {
            // Collapse this visual line fragment.
            lineFragmentRect.pointee.size.height = 0
            lineFragmentUsedRect.pointee.size.height = 0
            baselineOffset.pointee = 0
            return true
        }

        return false
    }

    // PERF: O(log n) binary search for line index using cached offsets
    private func binarySearchLineIndex(for utf16Offset: Int) -> Int {
        var lo = 0
        var hi = cachedLineStartOffsets.count
        while lo < hi {
            let mid = (lo + hi) / 2
            if cachedLineStartOffsets[mid] <= utf16Offset {
                lo = mid + 1
            } else {
                hi = mid
            }
        }
        return max(0, lo - 1)
    }
    
    /// Rebuild newline offset cache from text storage
    private func rebuildLineOffsets(for text: NSString) {
        var offsets: [Int] = [0]
        offsets.reserveCapacity(text.length / 40)
        for i in 0..<text.length {
            if text.character(at: i) == 0x0A { // '\n'
                offsets.append(i + 1)
            }
        }
        cachedLineStartOffsets = offsets
        cachedTextLength = text.length
    }
    
    /// Legacy O(n) fallback (kept for reference)
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

    /// Invalidate layout to reflect fold state changes.
    /// Call this after toggling fold regions.
    func invalidateFoldingLayout() {
        guard let textStorage = self.textStorage else { return }
        let fullRange = NSRange(location: 0, length: textStorage.length)
        self.invalidateLayout(forCharacterRange: fullRange, actualCharacterRange: nil)
        self.invalidateDisplay(forCharacterRange: fullRange)
    }
}
