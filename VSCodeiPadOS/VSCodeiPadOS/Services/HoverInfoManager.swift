import SwiftUI
import Combine

/// Represents the data to be displayed in the hover popup
struct HoverInfo: Equatable, Identifiable {
    let id = UUID()
    let signature: String
    let typeInfo: String?
    let documentation: String
    let range: NSRange?
    let language: String
}

/// Manages the state and data fetching for hover documentation
class HoverInfoManager: ObservableObject {
    @Published var currentInfo: HoverInfo? = nil
    @Published var isVisible: Bool = false
    @Published var position: CGPoint = .zero
    
    static let shared = HoverInfoManager()
    
    private init() {}
    
    /// Show hover info for a given word at a specific location
    func showHover(for word: String, at point: CGPoint, language: String = "swift") {
        // In a real app, this would be an async call to an LSP or language service
        if let info = fetchMockDocumentation(for: word, language: language) {
            DispatchQueue.main.async {
                self.currentInfo = info
                self.position = point
                self.isVisible = true
            }
        }
    }
    
    /// Hide the hover popup
    func hideHover() {
        DispatchQueue.main.async {
            self.isVisible = false
            self.currentInfo = nil
        }
    }
    
    /// Toggle visibility manually (e.g. via keyboard shortcut)
    func toggleHover() {
        if isVisible {
            hideHover()
        }
    }
    
    // MARK: - Mock Data Service
    
    private func fetchMockDocumentation(for word: String, language: String) -> HoverInfo? {
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanWord.isEmpty else { return nil }
        
        // Mock dictionary for demonstration
        let swiftDocs: [String: HoverInfo] = [
            "print": HoverInfo(
                signature: "func print(_ items: Any..., separator: String = \" \", terminator: String = \"\\n\")",
                typeInfo: "Standard Library",
                documentation: "Writes the textual representations of the given items into the standard output.",
                range: nil,
                language: "swift"
            ),
            "String": HoverInfo(
                signature: "struct String",
                typeInfo: "Swift.String",
                documentation: "A Unicode string value that is a collection of characters.",
                range: nil,
                language: "swift"
            ),
            "View": HoverInfo(
                signature: "protocol View",
                typeInfo: "SwiftUI.View",
                documentation: "A type that represents part of your app's user interface and provides modifiers that you use to configure views.",
                range: nil,
                language: "swift"
            )
        ]
        
        return swiftDocs[cleanWord]
    }
}
