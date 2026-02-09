import Foundation
import SwiftUI

@MainActor
final class WorkspaceTrustManager: ObservableObject {
    static let shared = WorkspaceTrustManager()
    
    @Published private(set) var trustedPaths: Set<String> = []
    
    private let trustedPathsKey = "workspace.trustedPaths"
    
    private init() {
        loadTrustedPaths()
    }
    
    func isTrusted(url: URL) -> Bool {
        return trustedPaths.contains(url.path)
    }
    
    func trust(url: URL) {
        trustedPaths.insert(url.path)
        saveTrustedPaths()
    }
    
    func revoke(url: URL) {
        trustedPaths.remove(url.path)
        saveTrustedPaths()
    }
    
    private func loadTrustedPaths() {
        if let saved = UserDefaults.standard.array(forKey: trustedPathsKey) as? [String] {
            trustedPaths = Set(saved)
        }
    }
    
    private func saveTrustedPaths() {
        UserDefaults.standard.set(Array(trustedPaths), forKey: trustedPathsKey)
    }
}
