//
//  RenameService.swift
//  VSCodeiPadOS
//
//  Handles symbol renaming UI state management.
//  The actual LSP rename call goes through TunnelLSPProxy directly.
//

import Foundation
import Combine

/// Manages rename refactoring UI state. The actual rename operation
/// is invoked via TunnelLSPProxy.shared.rename() from the call site.
@MainActor
final class RenameService: ObservableObject {
    static let shared = RenameService()

    @Published var isRenaming = false
    @Published var showRenameDialog = false
    @Published var currentSymbol: String = ""
    @Published var errorMessage: String?

    /// Start rename flow — shows dialog
    func startRename(symbol: String) {
        currentSymbol = symbol
        showRenameDialog = true
    }

    /// Mark rename as complete
    func finishRename() {
        isRenaming = false
        showRenameDialog = false
    }
}
