import Foundation
import Combine

/// Service for go-to-definition using LSP or local fallback
final class GoToDefinitionService: ObservableObject {
    static let shared = GoToDefinitionService()

    struct DefinitionResult: Identifiable {
        let id = UUID()
        let uri: String
        let line: Int
        let character: Int
        let preview: String

        var fileName: String {
            (uri as NSString).lastPathComponent
        }
    }

    @Published var results: [DefinitionResult] = []
    @Published var isLoading = false
    @Published var showPeek = false
    @Published var errorMessage: String?

    func goToDefinition(uri: String, line: Int, character: Int, languageId: String) {
        isLoading = true
        errorMessage = nil
        results = []

        Task { @MainActor in
            defer { isLoading = false }

            let lsp = TunnelLSPProxy.shared
            guard lsp.isInitialized else {
                // Fallback: local symbol search
                let localResults = localDefinitionSearch(symbol: "", uri: uri)
                results = localResults
                if !localResults.isEmpty { showPeek = true }
                return
            }

            do {
                let locations = try await lsp.definition(
                    uri: uri,
                    position: LSPPosition(line: line, character: character),
                    languageId: languageId
                )

                results = locations.map { loc in
                    DefinitionResult(
                        uri: loc.uri,
                        line: loc.range.start.line,
                        character: loc.range.start.character,
                        preview: ""
                    )
                }

                if !results.isEmpty {
                    showPeek = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func localDefinitionSearch(symbol: String, uri: String) -> [DefinitionResult] {
        // Placeholder for local regex-based search
        return []
    }

    func navigateToFirst() -> DefinitionResult? {
        return results.first
    }

    func clear() {
        results = []
        showPeek = false
        errorMessage = nil
    }
}
