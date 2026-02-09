import Foundation

class RecentFileManager: ObservableObject {
    static let shared = RecentFileManager()
    
    @Published var recentFiles: [URL] = []
    private let maxRecentFiles = 10
    private let defaultsKey = "recentFileURLs"
    
    private init() {
        loadRecentFiles()
    }
    
    func addRecentFile(_ url: URL) {
        // Remove existing if present to move it to top
        recentFiles.removeAll { $0 == url }
        
        // Add to front
        recentFiles.insert(url, at: 0)
        
        // Trim
        if recentFiles.count > maxRecentFiles {
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }
        
        saveRecentFiles()
    }
    
    private func saveRecentFiles() {
        let urlStrings = recentFiles.map { $0.absoluteString }
        UserDefaults.standard.set(urlStrings, forKey: defaultsKey)
    }
    
    private func loadRecentFiles() {
        guard let urlStrings = UserDefaults.standard.stringArray(forKey: defaultsKey) else { return }
        recentFiles = urlStrings.compactMap { URL(string: $0) }
    }
    
    func clearRecents() {
        recentFiles.removeAll()
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
}
