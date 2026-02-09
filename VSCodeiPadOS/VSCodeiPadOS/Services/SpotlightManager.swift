import Foundation
import CoreSpotlight
import MobileCoreServices
import UniformTypeIdentifiers

/// Manages CoreSpotlight indexing for opened files
class SpotlightManager {
    static let shared = SpotlightManager()
    
    private let searchableIndex = CSSearchableIndex.default()
    private let domainIdentifier = "com.vscode.ipados.files"
    
    private init() {}
    
    // MARK: - Public API
    
    /// Index a file that was opened in the editor
    /// - Parameters:
    ///   - url: The file URL
    ///   - content: The file content
    ///   - fileName: The file name
    func indexFile(url: URL, content: String, fileName: String) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
        
        // Basic attributes
        attributeSet.title = fileName
        attributeSet.displayName = fileName
        attributeSet.contentDescription = generateContentPreview(from: content)
        
        // Path and URL
        attributeSet.path = url.path
        attributeSet.contentURL = url
        
        // Content
        attributeSet.textContent = content
        
        // File metadata
        let fileExtension = url.pathExtension
        attributeSet.keywords = [fileName, fileExtension, "code", "editor"]
        
        // Determine content type based on extension
        if let utType = UTType(filenameExtension: fileExtension) {
            attributeSet.contentType = utType.identifier
        }
        
        // Add language/syntax info if available
        if let language = detectLanguage(from: fileExtension) {
            attributeSet.keywords?.append(language)
        }
        
        // Timestamps
        attributeSet.contentModificationDate = Date()
        attributeSet.addedDate = Date()
        
        // Create searchable item
        let uniqueIdentifier = url.path
        let searchableItem = CSSearchableItem(
            uniqueIdentifier: uniqueIdentifier,
            domainIdentifier: domainIdentifier,
            attributeSet: attributeSet
        )
        
        // Set expiration - files remain indexed for 30 days after last open
        searchableItem.expirationDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
        
        // Index the item
        searchableIndex.indexSearchableItems([searchableItem]) { error in
            if let error = error {
                print("Spotlight indexing error: \(error.localizedDescription)")
            } else {
                print("Successfully indexed file: \(fileName)")
            }
        }
    }
    
    /// Update the index for a file (e.g., after saving)
    /// - Parameters:
    ///   - url: The file URL
    ///   - content: The updated file content
    ///   - fileName: The file name
    func updateFile(url: URL, content: String, fileName: String) {
        // Re-indexing with the same uniqueIdentifier updates the existing entry
        indexFile(url: url, content: content, fileName: fileName)
    }
    
    /// Remove a file from the Spotlight index
    /// - Parameter url: The file URL to remove
    func removeFile(url: URL) {
        let uniqueIdentifier = url.path
        searchableIndex.deleteSearchableItems(withIdentifiers: [uniqueIdentifier]) { error in
            if let error = error {
                print("Error removing from Spotlight index: \(error.localizedDescription)")
            } else {
                print("Successfully removed from index: \(url.lastPathComponent)")
            }
        }
    }
    
    /// Remove all indexed files for this app
    func clearAllIndexes() {
        searchableIndex.deleteSearchableItems(withDomainIdentifiers: [domainIdentifier]) { error in
            if let error = error {
                print("Error clearing Spotlight indexes: \(error.localizedDescription)")
            } else {
                print("Successfully cleared all Spotlight indexes")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Generate a preview of the file content (first few lines)
    private func generateContentPreview(from content: String, maxLines: Int = 5, maxLength: Int = 200) -> String {
        let lines = content.components(separatedBy: .newlines)
        let previewLines = lines.prefix(maxLines).joined(separator: " ")
        
        if previewLines.count > maxLength {
            let index = previewLines.index(previewLines.startIndex, offsetBy: maxLength)
            return String(previewLines[..<index]) + "..."
        }
        
        return previewLines
    }
    
    /// Detect programming language from file extension
    private func detectLanguage(from extension: String) -> String? {
        let languageMap: [String: String] = [
            "swift": "Swift",
            "js": "JavaScript",
            "ts": "TypeScript",
            "jsx": "React",
            "tsx": "React TypeScript",
            "py": "Python",
            "java": "Java",
            "kt": "Kotlin",
            "cpp": "C++",
            "c": "C",
            "h": "C Header",
            "hpp": "C++ Header",
            "cs": "C#",
            "rb": "Ruby",
            "go": "Go",
            "rs": "Rust",
            "php": "PHP",
            "html": "HTML",
            "css": "CSS",
            "scss": "SCSS",
            "json": "JSON",
            "xml": "XML",
            "md": "Markdown",
            "txt": "Plain Text",
            "yaml": "YAML",
            "yml": "YAML",
            "sh": "Shell",
            "bash": "Bash",
            "sql": "SQL"
        ]
        
        return languageMap[`extension`.lowercased()]
    }
}
