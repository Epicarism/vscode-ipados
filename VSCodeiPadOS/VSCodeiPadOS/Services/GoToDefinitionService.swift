import Foundation
import Combine

/// Service for go-to-definition using LSP or local fallback.
/// The actual LSP provider is injected via `setDefinitionProvider(_:)`
/// to avoid a compile-time dependency on TunnelLSPProxy types.
@MainActor
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

    /// A lightweight location tuple, avoiding LSP type coupling.
    typealias DefinitionLocation = (uri: String, line: Int, character: Int)

    /// Type-erased definition provider. Wired up by TunnelLSPProxy at startup.
    private var definitionProvider: ((String, Int, Int, String) async throws -> [DefinitionLocation])?

    /// Register the LSP-backed definition provider.
    func setDefinitionProvider(
        _ provider: @escaping (String, Int, Int, String) async throws -> [DefinitionLocation]
    ) {
        self.definitionProvider = provider
    }

    @Published var results: [DefinitionResult] = []
    @Published var isLoading = false
    @Published var showPeek = false
    @Published var errorMessage: String?

    func goToDefinition(uri: String, line: Int, character: Int, languageId: String) {
        isLoading = true
        errorMessage = nil
        results = []

        guard let provider = definitionProvider else {
            // No LSP provider registered — fall back to local search
            let localResults = localDefinitionSearch(symbol: "", uri: uri)
            results = localResults
            isLoading = false
            if !localResults.isEmpty { showPeek = true }
            return
        }

        Task {
            defer { isLoading = false }

            do {
                let locations = try await provider(uri, line, character, languageId)
                results = locations.map { loc in
                    DefinitionResult(
                        uri: loc.uri,
                        line: loc.line,
                        character: loc.character,
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
