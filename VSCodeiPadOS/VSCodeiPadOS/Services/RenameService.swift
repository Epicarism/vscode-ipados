//
//  RenameService.swift
//  VSCodeiPadOS
//
//  Handles symbol renaming via LSP or local find-replace.
//

import Foundation
import Combine

/// Handles symbol renaming via LSP or local find-replace
final class RenameService: ObservableObject {
    static let shared = RenameService()

    @Published var isRenaming = false
    @Published var showRenameDialog = false
    @Published var currentSymbol: String = ""
    @Published var errorMessage: String?

    struct RenameEdit {
        let uri: String
        let range: LSPRange
        let newText: String
    }

    /// Start rename flow — shows dialog
    func startRename(symbol: String, uri: String, line: Int, character: Int, languageId: String) {
        currentSymbol = symbol
        showRenameDialog = true
    }

    /// Execute rename via LSP
    func executeRename(newName: String, uri: String, line: Int, character: Int, languageId: String) {
        isRenaming = true
        Task { @MainActor in
            defer { isRenaming = false; showRenameDialog = false }
            let lsp = TunnelLSPProxy.shared
            guard lsp.isInitialized else {
                // Fallback: local find-replace of exact symbol
                errorMessage = "LSP not connected. Use Find & Replace for local rename."
                return
            }
            do {
                let edits = try await lsp.rename(
                    uri: uri,
                    position: LSPPosition(line: line, character: character),
                    languageId: languageId,
                    newName: newName
                )
                // Apply edits... post notification with results
                NotificationCenter.default.post(name: .renameCompleted, object: nil, userInfo: ["edits": edits as Any])
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
