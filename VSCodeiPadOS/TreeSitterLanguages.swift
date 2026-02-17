// TreeSitterLanguages configuration
// Maps file extensions to TreeSitter language parsers

import Foundation

struct TreeSitterLanguageConfig {
    static let supportedLanguages: [String: String] = [
        "swift": "swift",
        "js": "javascript",
        "ts": "typescript",
        "tsx": "tsx",
        "jsx": "javascript",
        "py": "python",
        "rs": "rust",
        "go": "go",
        "c": "c",
        "cpp": "cpp",
        "h": "c",
        "hpp": "cpp",
        "java": "java",
        "rb": "ruby",
        "html": "html",
        "css": "css",
        "json": "json",
        "yaml": "yaml",
        "yml": "yaml",
        "md": "markdown",
        "sh": "bash",
        "bash": "bash",
        "toml": "toml",
    ]
    
    static func language(for fileExtension: String) -> String? {
        supportedLanguages[fileExtension.lowercased()]
    }
}
